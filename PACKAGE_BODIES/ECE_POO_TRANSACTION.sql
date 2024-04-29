--------------------------------------------------------
--  DDL for Package Body ECE_POO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_POO_TRANSACTION" AS
-- $Header: ECEPOOB.pls 120.10.12010000.3 2013/02/26 12:19:44 venuthot ship $

iOutput_width              INTEGER              :=  4000; -- 2823215
iKey_count                 NUMBER               :=  0;
xHeaderCount               NUMBER		:=  0;
i_path                     VARCHAR2(1000);
i_filename                 VARCHAR2(1000);
   PROCEDURE extract_poo_outbound(errbuf              OUT NOCOPY   VARCHAR2,
                                  retcode             OUT NOCOPY   VARCHAR2,
                                  cOutput_Path        IN    VARCHAR2,
                                  cOutput_Filename    IN    VARCHAR2,
                                  cPO_Number_From     IN    VARCHAR2,
                                  cPO_Number_To       IN    VARCHAR2,
                                  cCDate_From         IN    VARCHAR2,
                                  cCDate_To           IN    VARCHAR2,
                                  cPC_Type            IN    VARCHAR2,
                                  cVendor_Name        IN    VARCHAR2,
                                  cVendor_Site_Code   IN    VARCHAR2,
                                  v_debug_mode        IN    NUMBER   DEFAULT 0) IS

      xProgress                  VARCHAR2(80);
      iRun_id                    NUMBER               :=  0;
      iOutput_width              INTEGER              :=  4000;
      cTransaction_Type          VARCHAR2(120)        := 'POO';
      cCommunication_Method      VARCHAR2(120)        := 'EDI';
      cHeader_Interface          VARCHAR2(120)        := 'ECE_PO_INTERFACE_HEADERS';
      cLine_Interface            VARCHAR2(120)        := 'ECE_PO_INTERFACE_LINES';
      cShipment_Interface        VARCHAR2(120)        := 'ECE_PO_INTERFACE_SHIPMENTS';
      cDistribution_Interface    VARCHAR2(120)        := 'ECE_PO_DISTRIBUTIONS';     --Bug 1891291
      l_line_text                VARCHAR2(2000);

      cCreat_Date_From           DATE                 := TO_DATE(cCDate_From,'YYYY/MM/DD HH24:MI:SS');
      cCreat_Date_To             DATE                 := TO_DATE(cCDate_To  ,'YYYY/MM/DD HH24:MI:SS') + 1;
      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;
      --xHeaderCount               NUMBER;
      cFilename                  VARCHAR2(30)        := NULL;  --2430822


      CURSOR c_output IS
         SELECT   text
         FROM     ece_output
         WHERE    run_id = iRun_id
         ORDER BY line_id;

      BEGIN
         xProgress := 'POO-10-1000';
         ec_debug.enable_debug(v_debug_mode);
 	  if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO.Extract_POO_Outbound');
         ec_debug.pl(3,'cOutput_Path: '     ,cOutput_Path);
         ec_debug.pl(3,'cOutput_Filename: ' ,cOutput_Filename);
         ec_debug.pl(3,'cPO_Number_From: '  ,cPO_Number_From);
         ec_debug.pl(3,'cPO_Number_To: '    ,cPO_Number_To);
         ec_debug.pl(3,'cCDate_From: '      ,cCDate_From);
         ec_debug.pl(3,'cCDate_To: '        ,cCDate_To);
         ec_debug.pl(3,'cPC_Type: '         ,cPC_Type);
         ec_debug.pl(3,'cVendor_Name: '     ,cVendor_Name);
         ec_debug.pl(3,'cVendor_Site_Code: ',cVendor_Site_Code);
         ec_debug.pl(3,'v_debug_mode: '     ,v_debug_mode);
        end if;
         /* Check to see if the transaction is enabled. If not, abort */
         xProgress := 'POO-10-1005';
         fnd_profile.get('ECE_' || cTransaction_Type || '_ENABLED',cEnabled);

         xProgress := 'POO-10-1010';
         IF cEnabled = 'N' THEN
            xProgress := 'POO-10-1015';
            RAISE ece_transaction_disabled;
         END IF;

         xProgress := 'POO-10-1020';
         BEGIN
            SELECT   ece_output_runs_s.NEXTVAL
            INTO     iRun_id
            FROM     DUAL;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_OUTPUT_RUNS_S');

         END;

         xProgress := 'POO-10-1025';
	  if ec_debug.G_debug_level >= 1 then
           ec_debug.pl(3,'iRun_id: ',iRun_id);
           ec_debug.pl(1,'EC','ECE_POO_START',NULL);
           ec_debug.pl(1,'EC','ECE_RUN_ID','RUN_ID',iRun_id);
	  end if;


	 xProgress := 'POO-10-1026';

         ece_poo_transaction.project_sel_c:=0;		--Bug 2490109

	 IF cOutput_Filename IS NULL THEN		   --Bug 2430822
          cFilename := 'POO' || iRun_id || '.dat';
	 ELSE
          cFilename := cOutput_Filename;
         END IF;

	     -- Open the file for write.
         xProgress := 'POO-10-1030';
	 if ec_debug.G_debug_level = 1 then
	   ec_debug.pl(1,'Output File:',cFilename);
	   ec_debug.pl(1,'Open Output file');            --Bug 2034376
         end if;
         i_path := cOutput_Path;
         i_filename := cFilename;
--	  ece_poo_transaction.uFile_type := utl_file.fopen(cOutput_Path,cFilename,'W',32767); --Bug 2887790

	  xProgress := 'POO-10-1040';
	  if ec_debug.G_debug_level = 1 then
           ec_debug.pl(1,'Call Populate Poo Trx procedure');     --Bug 2034376
          end if;

         ece_poo_transaction.populate_poo_trx(
            cCommunication_Method,
            cTransaction_Type,
            iOutput_width,
            SYSDATE,
            iRun_id,
            cHeader_Interface,
            cLine_Interface,
            cShipment_Interface,
            cDistribution_Interface,
            cCreat_Date_From,
            cCreat_Date_To,
            cVendor_Name,
            cVendor_Site_Code,
            cPC_Type,
            cPO_Number_From,
            cPO_Number_To);

    /*     xProgress := 'POO-10-1035';
	 if ec_debug.G_debug_level = 1 then
          ec_debug.pl(1,'Call Put To Output Table procedure');   --Bug 2034376
         end if;

	 select count(*)
         into xHeaderCount
         from ECE_PO_INTERFACE_HEADERS
         where run_id = iRun_id;
    */
	 if ec_debug.G_debug_level = 1 then
          ec_debug.pl(1,'NUMBER OF RECORDS PROCESSED IS ',xHeaderCount);
         end if;





       /*
	xProgress := 'POO-10-1041';

         ece_poo_transaction.put_data_to_output_table(
               cCommunication_Method,
               cTransaction_Type,
               iOutput_width,
               iRun_id,
               cHeader_Interface,
               cLine_Interface,
               cShipment_Interface,
               cDistribution_Interface);
	 */

         xProgress := 'POO-10-1042';
     if (utl_file.is_open(ece_poo_transaction.uFile_type)) then
         utl_file.fclose(ece_poo_transaction.uFile_type);
     end if;

         IF ec_mapping_utils.ec_get_trans_upgrade_status(cTransaction_Type) = 'U' THEN
            ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
            retcode := 1;
         END IF;

	 if ec_debug.G_debug_level >= 2 then
          ec_debug.pop('ECE_POO.Extract_POO_Outbound');
         end if;

         ec_debug.disable_debug;

         COMMIT;


      EXCEPTION
         WHEN ece_transaction_disabled THEN
            ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',cTransaction_type);
            retcode := 1;
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN utl_file.write_error THEN
            ec_debug.pl(0,'EC','ECE_UTL_WRITE_ERROR',NULL);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
	    if (utl_file.is_open(ece_poo_transaction.uFile_type))
	    then
            utl_file.fclose(ece_poo_transaction.uFile_type);
	    end if;
            ece_poo_transaction.uFile_type := utl_file.fopen(cOutput_Path,cFilename,'W',32767);
	    utl_file.fclose(ece_poo_transaction.uFile_type);
            ROLLBACK;

         WHEN utl_file.invalid_path THEN
            ec_debug.pl(0,'EC','ECE_UTIL_INVALID_PATH',NULL);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
            ROLLBACK;

         WHEN utl_file.invalid_operation THEN
            ec_debug.pl(0,'EC','ECE_UTIL_INVALID_OPERATION',NULL);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
	    if (utl_file.is_open(ece_poo_transaction.uFile_type))
	    then
            utl_file.fclose(ece_poo_transaction.uFile_type);
	    end if;
            ece_poo_transaction.uFile_type := utl_file.fopen(cOutput_Path,cFilename,'W',32767);
	    utl_file.fclose(ece_poo_transaction.uFile_type);
            ROLLBACK;

         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            retcode := 2;
            ec_debug.disable_debug;
	    if (utl_file.is_open(ece_poo_transaction.uFile_type))
	    then
            utl_file.fclose(ece_poo_transaction.uFile_type);
	    end if;
            ece_poo_transaction.uFile_type := utl_file.fopen(cOutput_Path,cFilename,'W',32767);
	    utl_file.fclose(ece_poo_transaction.uFile_type);
            ROLLBACK;

      END extract_poo_outbound;

   PROCEDURE populate_poo_trx(cCommunication_Method   IN VARCHAR2,
                              cTransaction_Type       IN VARCHAR2,
                              iOutput_width           IN INTEGER,
                              dTransaction_date       IN DATE,
                              iRun_id                 IN INTEGER,
                              cHeader_Interface       IN VARCHAR2,
                              cLine_Interface         IN VARCHAR2,
                              cShipment_Interface     IN VARCHAR2,
                              cDistribution_Interface IN VARCHAR2,
                              cCreate_Date_From       IN DATE,
                              cCreate_Date_To         IN DATE,
                              cSupplier_Name          IN VARCHAR2,
                              cSupplier_Site          IN VARCHAR2,
                              cDocument_Type          IN VARCHAR2,
                              cPO_Number_From         IN VARCHAR2,
                              cPO_Number_To           IN VARCHAR2) IS

      xProgress                  VARCHAR2(30);
      v_LevelProcessed           VARCHAR2(40);

      cAtt_Header_Interface      VARCHAR2(120) := 'ECE_ATTACHMENT_HEADERS';
      cAtt_Detail_Interface      VARCHAR2(120) := 'ECE_ATTACHMENT_DETAILS';

      l_header_tbl               ece_flatfile_pvt.Interface_tbl_type;
      l_line_tbl                 ece_flatfile_pvt.Interface_tbl_type;
      l_shipment_tbl             ece_flatfile_pvt.Interface_tbl_type;
      l_key_tbl                  ece_flatfile_pvt.Interface_tbl_type;

      l_hdr_att_hdr_tbl          ece_flatfile_pvt.Interface_tbl_type;
      l_hdr_att_dtl_tbl          ece_flatfile_pvt.Interface_tbl_type;
      l_ln_att_hdr_tbl           ece_flatfile_pvt.Interface_tbl_type;
      l_ln_att_dtl_tbl           ece_flatfile_pvt.Interface_tbl_type;
      l_mi_att_hdr_tbl           ece_flatfile_pvt.Interface_tbl_type;
      l_mi_att_dtl_tbl           ece_flatfile_pvt.Interface_tbl_type;
      l_msi_att_hdr_tbl          ece_flatfile_pvt.Interface_tbl_type;
      l_msi_att_dtl_tbl          ece_flatfile_pvt.Interface_tbl_type;
      l_shp_att_hdr_tbl          ece_flatfile_pvt.Interface_tbl_type;
      l_shp_att_dtl_tbl          ece_flatfile_pvt.Interface_tbl_type;

      iAtt_hdr_pos               NUMBER := 0;
      iAtt_ln_pos                NUMBER := 0;
      iAtt_mi_pos                NUMBER := 0;
      iAtt_msi_pos               NUMBER := 0;
      iAtt_shp_pos               NUMBER := 0;

      v_project_acct_installed   BOOLEAN;
      v_project_acct_short_name  VARCHAR2(2) := 'PA';
      v_project_acct_status      VARCHAR2(120);
      v_project_acct_industry    VARCHAR2(120);
      v_project_acct_schema      VARCHAR2(120);

      v_att_enabled              VARCHAR2(10);
      v_header_att_enabled       VARCHAR2(10);
      v_line_att_enabled         VARCHAR2(10);
      v_mitem_att_enabled        VARCHAR2(10);
      v_iitem_att_enabled        VARCHAR2(10);
      v_ship_att_enabled         VARCHAR2(10);
      n_att_seg_size             NUMBER;

      v_entity_name              VARCHAR2(120);
      v_pk1_value                VARCHAR2(120);
      v_pk2_value                VARCHAR2(120);

      header_sel_c               INTEGER;
      line_sel_c                 INTEGER;
      shipment_sel_c             INTEGER;

      cHeader_select             VARCHAR2(32000);
      cLine_select               VARCHAR2(32000);
      cShipment_select           VARCHAR2(32000);

      cHeader_from               VARCHAR2(32000);
      cLine_from                 VARCHAR2(32000);
      cShipment_from             VARCHAR2(32000);

      cHeader_where              VARCHAR2(32000);
      cLine_where                VARCHAR2(32000);
      cShipment_where            VARCHAR2(32000);

      iHeader_count              NUMBER := 0;
      iLine_count                NUMBER := 0;
      iShipment_count            NUMBER := 0;
      --iKey_count                 NUMBER := 0;

      l_header_fkey              NUMBER;
      l_line_fkey                NUMBER;
      l_shipment_fkey            NUMBER;

      nHeader_key_pos            NUMBER;
      nLine_key_pos              NUMBER;
      nShipment_key_pos          NUMBER;

      nTrans_code_pos            NUMBER;   -- 2823215

      c_file_common_key          VARCHAR2(255);  -- 2823215

      dummy                      INTEGER;
      n_trx_date_pos             NUMBER;
      nDocument_type_pos         NUMBER;
      nPO_Number_pos             NUMBER;
      nPO_Type_pos               NUMBER;
      nVendor_Site_Id_pos        NUMBER; --Bug 15880908 fix
      nRelease_num_pos           NUMBER;
      nRelease_ID_pos            NUMBER;
      nLine_num_pos              NUMBER;
      nLine_Location_ID_pos      NUMBER;
      -- Bug 2823215
      nShip_Line_Location_ID_pos NUMBER;
      nShip_Release_Num_pos      NUMBER;
      nLine_uom_code_pos         NUMBER;
      nLine_Location_uom_pos     NUMBER;
      nLp_att_cat_pos            NUMBER;
      nLp_att1_pos               NUMBER;
      nLp_att2_pos               NUMBER;
      nLp_att3_pos               NUMBER;
      nLp_att4_pos               NUMBER;
      nLp_att5_pos               NUMBER;
      nLp_att6_pos               NUMBER;
      nLp_att7_pos               NUMBER;
      nLp_att8_pos               NUMBER;
      nLp_att9_pos               NUMBER;
      nLp_att10_pos               NUMBER;
      nLp_att11_pos               NUMBER;
      nLp_att12_pos               NUMBER;
      nLp_att13_pos               NUMBER;
      nLp_att14_pos               NUMBER;
      nLp_att15_pos               NUMBER;
      nSt_cust_name_pos           NUMBER;
      nSt_cont_name_pos           NUMBER;
      nSt_cont_phone_pos          NUMBER;
      nSt_cont_fax_pos            NUMBER;
      nSt_cont_email_pos          NUMBER;
      nShipping_Instruct_pos      NUMBER;
      nPacking_Instruct_pos       NUMBER;
      nShipping_method_pos        NUMBER;
      nCust_po_num_pos            NUMBER;
      nCust_po_line_num_pos       NUMBER;
      nCust_po_ship_num_pos       NUMBER;
      nCust_prod_desc_pos         NUMBER;
      nDeliv_cust_loc_pos         NUMBER;
      nDeliv_cust_name_pos        NUMBER;
      nDeliv_cont_name_pos        NUMBER;
      nDeliv_cont_phone_pos       NUMBER;
      nDeliv_cont_fax_pos         NUMBER;
      nDeliv_cust_addr_pos        NUMBER;
      nDeliv_cont_email_pos       NUMBER;
      --Bug 2823215
      nShp_uom_pos                NUMBER;
      nLine_uom_pos               NUMBER;
      l_document_type            VARCHAR2(30);
      nOrganization_ID           NUMBER;
      nItem_ID_pos               NUMBER;

      -- Timezone enhancement
      nRel_date_pos            pls_integer;
      nRel_dt_tz_pos           pls_integer;
      nRel_dt_off_pos          pls_integer;
      nCrtn_date_pos           pls_integer;
      nCrtn_dt_tz_pos          pls_integer;
      nCrtn_dt_off_pos         pls_integer;
      nRev_date_pos            pls_integer;
      nRev_dt_tz_pos           pls_integer;
      nRev_dt_off_pos          pls_integer;
      nAcc_due_dt_pos          pls_integer;
      nAcc_due_tz_pos          pls_integer;
      nAcc_due_off_pos         pls_integer;
      nBlkt_srt_dt_pos         pls_integer;
      nBlkt_srt_tz_pos         pls_integer;
      nBlkt_srt_off_pos        pls_integer;
      nBlkt_end_dt_pos         pls_integer;
      nBlkt_end_tz_pos         pls_integer;
      nBlkt_end_off_pos        pls_integer;
      nPcard_exp_dt_pos        pls_integer;
      nPcard_exp_tz_pos        pls_integer;
      nPcard_exp_off_pos       pls_integer;
      nLine_can_dt_pos         pls_integer;
      nLine_can_tz_pos         pls_integer;
      nLine_can_off_pos        pls_integer;
      nExprn_dt_pos            pls_integer;
      nExprn_tz_pos            pls_integer;
      nExprn_off_pos           pls_integer;
      nShip_need_dt_pos        pls_integer;
      nShip_need_tz_pos        pls_integer;
      nShip_need_off_pos       pls_integer;
      nShip_prom_dt_pos        pls_integer;
      nShip_prom_tz_pos        pls_integer;
      nShip_prom_off_pos       pls_integer;
      nShip_accept_dt_pos      pls_integer;
      nShip_accept_tz_pos      pls_integer;
      nShip_accept_off_pos     pls_integer;
      nShp_can_dt_pos          pls_integer;
      nShp_can_tz_pos          pls_integer;
      nShp_can_off_pos         pls_integer;
      nShp_strt_dt_pos         pls_integer;
      nShp_strt_tz_pos         pls_integer;
      nShp_strt_off_pos        pls_integer;
      nShp_end_dt_pos          pls_integer;
      nShp_end_tz_pos          pls_integer;
      nShp_end_off_pos         pls_integer;
       -- Timezone enhancement

      v_drop_ship_flag                  NUMBER;
      rec_order_line_info               OE_DROP_SHIP_GRP.Order_Line_Info_Rec_Type;   --2887790
      nHeader_Cancel_Flag_pos           NUMBER;
      nLine_Cancel_Flag_pos             NUMBER;
      nShipment_Cancel_Flag_pos         NUMBER;
      v_header_cancel_flag              VARCHAR2(10);
      v_line_cancel_flag                VARCHAR2(10);
      v_shipment_cancel_flag            VARCHAR2(10);

      init_msg_list              VARCHAR2(20);
      simulate                   VARCHAR2(20);
      validation_level           VARCHAR2(20);
      commt                      VARCHAR2(20);
      return_status              VARCHAR2(20);
      msg_count                  NUMBER;
      msg_data                   VARCHAR2(2000);  -- 3650215

      line_part_number           VARCHAR2(80);
      line_part_attrib_category  VARCHAR2(80);

      -- bug 6511409
      line_part_attribute1      MTL_ITEM_FLEXFIELDS.ATTRIBUTE1%TYPE;
      line_part_attribute2      MTL_ITEM_FLEXFIELDS.ATTRIBUTE2%TYPE;
      line_part_attribute3      MTL_ITEM_FLEXFIELDS.ATTRIBUTE3%TYPE;
      line_part_attribute4      MTL_ITEM_FLEXFIELDS.ATTRIBUTE4%TYPE;
      line_part_attribute5      MTL_ITEM_FLEXFIELDS.ATTRIBUTE5%TYPE;
      line_part_attribute6      MTL_ITEM_FLEXFIELDS.ATTRIBUTE6%TYPE;
      line_part_attribute7      MTL_ITEM_FLEXFIELDS.ATTRIBUTE7%TYPE;
      line_part_attribute8      MTL_ITEM_FLEXFIELDS.ATTRIBUTE8%TYPE;
      line_part_attribute9      MTL_ITEM_FLEXFIELDS.ATTRIBUTE9%TYPE;
      line_part_attribute10     MTL_ITEM_FLEXFIELDS.ATTRIBUTE10%TYPE;
      line_part_attribute11     MTL_ITEM_FLEXFIELDS.ATTRIBUTE11%TYPE;
      line_part_attribute12     MTL_ITEM_FLEXFIELDS.ATTRIBUTE12%TYPE;
      line_part_attribute13     MTL_ITEM_FLEXFIELDS.ATTRIBUTE13%TYPE;
      line_part_attribute14     MTL_ITEM_FLEXFIELDS.ATTRIBUTE14%TYPE;
      line_part_attribute15     MTL_ITEM_FLEXFIELDS.ATTRIBUTE15%TYPE;

      d_dummy_date               DATE;

      iMap_ID                    NUMBER;
      c_header_common_key_name   VARCHAR2(40);
      c_line_common_key_name     VARCHAR2(40);
      c_shipment_key_name        VARCHAR2(40);
      n_header_common_key_pos    NUMBER;
      n_line_common_key_pos    NUMBER;
      n_ship_common_key_pos    NUMBER;

      fail_convert_to_ext        EXCEPTION;

      CURSOR c_org_id(p_line_id  NUMBER) IS
         SELECT   DISTINCT ship_to_organization_id
         FROM     po_line_locations
         WHERE    po_line_id = p_line_id;

      BEGIN
	if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO_TRANSACTION.POPULATE_POO_TRX');
         ec_debug.pl(3,'cCommunication_Method: ',cCommunication_Method);
         ec_debug.pl(3,'cTransaction_Type: '    ,cTransaction_Type);
         ec_debug.pl(3,'iOutput_width: '        ,iOutput_width);
         ec_debug.pl(3,'dTransaction_date: '    ,dTransaction_date);
         ec_debug.pl(3,'iRun_id: '              ,iRun_id);
         ec_debug.pl(3,'cHeader_Interface: '    ,cHeader_Interface);
         ec_debug.pl(3,'cLine_Interface: '      ,cLine_Interface);
         ec_debug.pl(3,'cShipment_Interface: '  ,cShipment_Interface);
         ec_debug.pl(3,'cDistribution_Interface: '   ,cDistribution_Interface);
         ec_debug.pl(3,'cCreate_Date_From: '    ,cCreate_Date_From);
         ec_debug.pl(3,'cCreate_Date_To: '      ,cCreate_Date_To);
         ec_debug.pl(3,'cSupplier_Name: '       ,cSupplier_Name);
         ec_debug.pl(3,'cSupplier_Site: '       ,cSupplier_Site);
         ec_debug.pl(3,'cDocument_Type: '       ,cDocument_Type);
         ec_debug.pl(3,'cPO_Number_From: '      ,cPO_Number_From);
         ec_debug.pl(3,'cPO_Number_To: '        ,cPO_Number_To);
	end if;

         xProgress := 'POOB-10-1000';
         BEGIN
            SELECT inventory_organization_id
            INTO   norganization_id
            FROM   financials_system_parameters;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(0,
                          'EC',
                          'ECE_NO_ROW_SELECTED',
                          'PROGRESS_LEVEL',
                           xProgress,
                          'INFO',
                          'INVENTORY ORGANIZATION ID',
                          'TABLE_NAME',
                          'FINANCIALS_SYSTEM_PARAMETERS');
         END;
	  if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'norganization_id: ',norganization_id);
        end if;
--Bug 1891291 begin
         -- Let's See if Project Accounting is Installed
         xProgress := 'POOB-10-1001';
       /*  v_project_acct_installed := fnd_installation.get_app_info(
                                       v_project_acct_short_name, -- i.e. 'PA'
                                       v_project_acct_status,     -- 'I' means it's installed
                                       v_project_acct_industry,
                                       v_project_acct_schema);

         v_project_acct_status := NVL(v_project_acct_status,'X');
         ec_debug.pl(3,'v_project_acct_status: '  ,v_project_acct_status);
         ec_debug.pl(3,'v_project_acct_industry: ',v_project_acct_industry);
         ec_debug.pl(3,'v_project_acct_schema: '  ,v_project_acct_schema);
       */
--Bug 1891291 end
         -- Get Profile Option Values for Attachments
         xProgress := 'POOB-10-1002';
         fnd_profile.get('ECE_' || cTransaction_Type || '_HEAD_ATT',v_header_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_LINE_ATT',v_line_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_MITEM_ATT',v_mitem_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_IITEM_ATT',v_iitem_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_SHIP_ATT',v_ship_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_ATT_SEG_SIZE',n_att_seg_size);

         -- Check to see if any attachments are enabled
         xProgress := 'POOB-10-1004';
         IF NVL(v_header_att_enabled,'N') = 'Y' OR
            NVL(v_mitem_att_enabled,'N') = 'Y' OR
            NVL(v_iitem_att_enabled,'N') = 'Y' OR
            NVL(v_ship_att_enabled,'N') = 'Y' THEN
            v_att_enabled := 'Y';
         END IF;

         IF v_att_enabled = 'Y' THEN
            BEGIN
               IF n_att_seg_size < 1 OR n_att_seg_size > G_MAX_ATT_SEG_SIZE OR n_att_seg_size IS NULL THEN
                  RAISE invalid_number;
               END IF;

            EXCEPTION
               WHEN value_error OR invalid_number THEN
                  ec_debug.pl(0,'EC','ECE_INVALID_SEGMENT_NUM','SEGMENT_VALUE',n_att_seg_size,'SEGMENT_DEFAULT',G_DEFAULT_ATT_SEG_SIZE);
                  n_att_seg_size := G_DEFAULT_ATT_SEG_SIZE;
            END;
         END IF;
	  if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'v_header_att_enabled: ',v_header_att_enabled);
         ec_debug.pl(3,'v_line_att_enabled: '  ,v_line_att_enabled);
         ec_debug.pl(3,'v_mitem_att_enabled: ' ,v_mitem_att_enabled);
         ec_debug.pl(3,'v_iitem_att_enabled: ' ,v_iitem_att_enabled);
         ec_debug.pl(3,'v_ship_att_enabled: '  ,v_ship_att_enabled);
         ec_debug.pl(3,'v_att_enabled: '       ,v_att_enabled);
         ec_debug.pl(3,'n_att_seg_size: '      ,n_att_seg_size);
	  end if;

         xProgress  := 'POOB-10-1010';
         ece_flatfile_pvt.init_table(cTransaction_Type,cHeader_Interface,NULL,FALSE,l_header_tbl,l_key_tbl);

         xProgress  := 'POOB-10-1020';
         l_key_tbl  := l_header_tbl;

         xProgress  := 'POOB-10-1025';
         --iKey_count := l_header_tbl.COUNT;
         --ec_debug.pl(3,'iKey_count: ',iKey_count );

         xProgress  := 'POOB-10-1030';
         ece_flatfile_pvt.init_table(cTransaction_Type,cLine_Interface,NULL,TRUE,l_line_tbl,l_key_tbl);

         xProgress  := 'POOB-10-1040';
         ece_flatfile_pvt.init_table(cTransaction_Type,cShipment_Interface,NULL,TRUE,l_shipment_tbl,l_key_tbl);

         -- ****************************************************************************
         -- Here, I am building the SELECT, FROM, and WHERE  clauses for the dynamic SQL
         -- call. The ece_extract_utils_pub.select_clause uses the EDI data dictionary
         -- for the build.
         -- ****************************************************************************

	 BEGIN
	     SELECT map_id
             INTO iMap_ID
	     FROM ece_mappings
	     WHERE map_code = 'EC_' || cTransaction_Type || '_FF';
         EXCEPTION
	 WHEN OTHERS THEN
	 NULL;
         END;
         xProgress := 'POOB-10-1050';
         ece_extract_utils_pub.select_clause(cTransaction_Type,
                                             cCommunication_Method,
                                             cHeader_Interface,
                                             l_header_tbl,
                                             cHeader_select,
                                             cHeader_from,
                                             cHeader_where);
        BEGIN
	    SELECT   eit.key_column_name
            INTO     c_header_common_key_name
            FROM     ece_interface_tables eit
            WHERE    eit.transaction_type     = cTransaction_Type AND
                     eit.interface_table_name = cHeader_Interface AND
                     eit.map_id               = iMap_ID;
        EXCEPTION
	 WHEN OTHERS THEN
	 NULL;
        END;

         xProgress := 'POOB-10-1060';
         ece_extract_utils_pub.select_clause(cTransaction_Type,
                                             cCommunication_Method,
                                             cLine_Interface,
                                             l_line_tbl,
                                             cLine_select,
                                             cLine_from,
                                             cLine_where);
       BEGIN
	    SELECT   eit.key_column_name
            INTO     c_line_common_key_name
            FROM     ece_interface_tables eit
            WHERE    eit.transaction_type     = cTransaction_Type AND
                     eit.interface_table_name = cLine_Interface AND
                     eit.map_id               = iMap_ID;
       EXCEPTION
	 WHEN OTHERS THEN
	 NULL;
       END;

         xProgress := 'POOB-10-1070';
         ece_extract_utils_pub.select_clause(cTransaction_Type,
                                             cCommunication_Method,
                                             cShipment_Interface,
                                             l_shipment_tbl,
                                             cShipment_select,
                                             cShipment_from,
                                             cShipment_where);
          BEGIN
	    SELECT   eit.key_column_name
            INTO     c_shipment_key_name
            FROM     ece_interface_tables eit
            WHERE    eit.transaction_type     = cTransaction_Type AND
                     eit.interface_table_name = cShipment_Interface AND
                     eit.map_id               = iMap_ID;
          EXCEPTION
	    WHEN OTHERS THEN
	    NULL;
          END;

         -- **************************************************************************
         -- Here, I am customizing the WHERE clause to join the Interface tables together.
         -- i.e. Headers -- Lines -- Line Details
         --
         -- Select   Data1, Data2, Data3...........
         -- From  Header_View
         -- Where A.Transaction_Record_ID = D.Transaction_Record_ID (+)
         -- and   B.Transaction_Record_ID = E.Transaction_Record_ID (+)
         -- and   C.Transaction_Record_ID = F.Transaction_Record_ID (+)
         -- ******* (Customization should be added here) ********
         -- and   A.Communication_Method = 'EDI'
         -- and   A.xxx = B.xxx   ........
         -- and   B.yyy = C.yyy   .......
         -- **************************************************************************
         -- **************************************************************************
         -- :po_header_id is a place holder for foreign key value.
         -- A PL/SQL table (list of values) will be used to store data.
         -- Procedure ece_flatfile.Find_pos will be used to locate the specific
         -- data value in the PL/SQL table.
         -- dbms_sql (Native Oracle db functions that come with every Oracle Apps)
         -- dbms_sql.bind_variable will be used to assign data value to :transaction_id.
         --
         -- Let's use the above example:
         --
         -- 1. Execute dynamic SQL 1 for headers (A) data
         --    Get value of A.xxx (foreign key to B)
         --
         -- 2. bind value A.xxx to variable B.xxx
         --
         -- 3. Execute dynamic SQL 2 for lines (B) data
         --    Get value of B.yyy (foreigh key to C)
         --
         -- 4. bind value B.yyy to variable C.yyy
         --
         -- 5. Execute dynamic SQL 3 for line_details (C) data
         -- **************************************************************************
         -- **************************************************************************
         --   Change the following few lines as needed
         -- **************************************************************************
         xProgress := 'POOB-10-1080';
         cHeader_where := cHeader_where                              ||
                          'ece_poo_headers_v.communication_method =' ||
                          ':cComm_Method';


         xProgress := 'POOB-10-1090';
         IF cCreate_Date_From IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.creation_date >='    ||
                             ':cCreate_Dt_From';
         END IF;

         xProgress := 'POOB-10-1100';
         IF cCreate_Date_To IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.creation_date <='    ||
                             ':cCreate_Dt_To';
         END IF;

         xProgress := 'POOB-10-1110';
         IF cSupplier_Name IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.supplier_number ='   ||
                             ':cSuppl_Name';
         END IF;

         xProgress := 'POOB-10-1120';
         IF cSupplier_Site IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.vendor_site_id ='    ||
                             ':cSuppl_Site';
         END IF;

         xProgress := 'POOB-10-1130';
         IF cDocument_Type IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.document_type ='     ||
                             ':cDoc_Type';
         END IF;

         xProgress := 'POOB-10-1140';
         IF cPO_Number_From IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.po_number >='        ||
                             ':cPO_Num_From';
         END IF;

         xProgress := 'POOB-10-1150';
         IF cPO_Number_To IS NOT NULL THEN
            cHeader_where := cHeader_where                           ||
                             ' AND '                                 ||
                             'ece_poo_headers_v.po_number <='        ||
                             ':cPO_Num_To';
         END IF;

         xProgress := 'POOB-10-1160';
         cHeader_where := cHeader_where                                                   ||
                          ' ORDER BY po_number, por_release_num';

         xProgress := 'POOB-10-1170';
         cLine_where := cLine_where                                                       ||
                        ' ece_poo_lines_v.po_header_id = :po_header_id AND'               ||
                        ' ece_poo_lines_v.por_release_num = :por_release_num '         ||
                        ' ORDER BY line_num';

         xProgress := 'POOB-10-1180';

         cShipment_where := cShipment_where                                               ||
                            ' ece_poo_shipments_v.po_header_id = :po_header_id AND'       ||
                            ' ece_poo_shipments_v.po_line_id = :po_line_id AND'           ||
                            ' ece_poo_shipments_v.por_release_id = :por_release_id'   ||
                            ' ORDER BY shipment_number';   --2823215

         -- 3957851
         --                   ' ece_poo_shipments_v.por_release_id = :por_release_id AND'   ||
         --                   ' ((ece_poo_shipments_v.por_release_id = 0) OR'               ||
         --                   ' (ece_poo_shipments_v.por_release_id <> 0 AND'               ||
         --                   ' ece_poo_shipments_v.shipment_number = :shipment_number))'   ||
         --                   ' ORDER BY shipment_number';   --2823215


         xProgress := 'POOB-10-1190';
         cHeader_select   := cHeader_select                                               ||
                             cHeader_from                                                 ||
                             cHeader_where;

         cLine_select     := cLine_select                                                 ||
                             cLine_from                                                   ||
                             cLine_where;

         cShipment_select := cShipment_select                                             ||
                             cShipment_from                                               ||
                             cShipment_where;
	   if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'cHeader_select: ',cHeader_select);
         ec_debug.pl(3,'cLine_select: ',cLine_select);
         ec_debug.pl(3,'cShipment_select: ',cShipment_select);
         end if;
         -- ***************************************************
         -- ***   Get data setup for the dynamic SQL call.
         -- ***   Open a cursor for each of the SELECT call
         -- ***   This tells the database to reserve spaces
         -- ***   for the data returned by the SQL statement
         -- ***************************************************
         xProgress      := 'POOB-10-1200';
         header_sel_c   := dbms_sql.open_cursor;

         xProgress      := 'POOB-10-1210';
         line_sel_c     := dbms_sql.open_cursor;

         xProgress      := 'POOB-10-1220';
         shipment_sel_c := dbms_sql.open_cursor;

         -- ***************************************************
         -- Parse each of the SELECT statement
         -- so the database understands the command
         -- ***************************************************
         xProgress := 'POOB-10-1230';
         BEGIN
            dbms_sql.parse(header_sel_c,
                           cHeader_select,
                           dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                        cHeader_select);
               app_exception.raise_exception;
         END;

         xProgress := 'POOB-10-1240';
         BEGIN
            dbms_sql.parse(line_sel_c,
                           cLine_select,
                           dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                        cLine_select);
               app_exception.raise_exception;
         END;

         xProgress := 'POOB-10-1250';
         BEGIN
            dbms_sql.parse(shipment_sel_c,
                           cShipment_select,
                           dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                        cShipment_select);
               app_exception.raise_exception;
         END;

         -- ************
         -- set counter
         -- ************
         xProgress       := 'POOB-10-1260';
         iHeader_count   := l_header_tbl.COUNT;


         xProgress       := 'POOB-10-1270';
         iLine_count     := l_line_tbl.COUNT;


         xProgress       := 'POOB-10-1280';
         iShipment_count := l_shipment_tbl.COUNT;
	   if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'iHeader_count: ',iHeader_count);
         ec_debug.pl(3,'iLine_count: ',iLine_count);
         ec_debug.pl(3,'iShipment_count: ',iShipment_count);
         end if;

         -- ******************************************************
         --  Define TYPE for every columns in the SELECT statement
         --  For each piece of the data returns, we need to tell
         --  the database what type of information it will be.
         --  e.g. ID is NUMBER, due_date is DATE
         --  However, for simplicity, we will convert
         --  everything to varchar2.
         -- ******************************************************
         xProgress := 'POOB-10-1290';
         ece_flatfile_pvt.define_interface_column_type(header_sel_c,cHeader_select,ece_extract_utils_PUB.G_MaxColWidth,l_header_tbl);

         xProgress := 'POOB-10-1300';
         ece_flatfile_pvt.define_interface_column_type(line_sel_c,cLine_select,ece_extract_utils_PUB.G_MaxColWidth,l_line_tbl);

         xProgress := 'POOB-10-1310';
         ece_flatfile_pvt.define_interface_column_type(shipment_sel_c,cShipment_select,ece_extract_utils_PUB.G_MaxColWidth,l_shipment_tbl);

         -- **************************************************************
         -- ***  The following is custom tailored for this transaction
         -- ***  It finds the values and use them in the WHERE clause to
         -- ***  join tables together.
         -- **************************************************************
         -- ***************************************************
         -- To complete the Line SELECT statement,
         --  we will need values for the join condition.
         -- ***************************************************
         -- Header Level Positions
         xProgress := 'POOB-10-1320';
         ece_extract_utils_pub.find_pos(l_header_tbl,ece_extract_utils_pub.G_TRANSACTION_DATE,n_trx_date_pos);

         xProgress := 'POOB-10-1330';
         ece_extract_utils_pub.find_pos(l_header_tbl,'PO_HEADER_ID',nHeader_key_pos);

         xProgress := 'POOB-10-1340';
         ece_extract_utils_pub.find_pos(l_header_tbl,'DOCUMENT_TYPE',nDocument_type_pos);

         xProgress := 'POOB-10-1350';
         ece_extract_utils_pub.find_pos(l_header_tbl,'PO_NUMBER',nPO_Number_pos);

	 xProgress := 'POOB-10-1351';
         ece_extract_utils_pub.find_pos(l_header_tbl,'VENDOR_SITE_ID',nVendor_Site_Id_pos); --Added as part of the bug 15880908 fix

         xProgress := 'POOB-10-1360';
         ece_extract_utils_pub.find_pos(l_header_tbl,'PO_TYPE',nPO_Type_pos);

         xProgress := 'POOB-10-1370';
         ece_extract_utils_pub.find_pos(l_header_tbl,'POR_RELEASE_NUM',nRelease_num_pos);

         xProgress := 'POOB-10-1380';
         ece_extract_utils_pub.find_pos(l_header_tbl,'POR_RELEASE_ID',nRelease_id_pos);

	  xProgress := 'POOB-10-1381';
         ece_extract_utils_pub.find_pos(l_header_tbl,'CANCEL_FLAG',nHeader_Cancel_Flag_pos);

	 xProgress := 'POOB-10-1382';
	 ece_flatfile_pvt.find_pos(l_header_tbl,ece_flatfile_pvt.G_Translator_Code,nTrans_code_pos);  --2823215

         -- Line Level Positions
         xProgress := 'POOB-10-1390';
         ece_extract_utils_pub.find_pos(l_line_tbl,'PO_LINE_LOCATION_ID',nLine_Location_ID_pos);

         xProgress := 'POOB-10-1400';
         ece_extract_utils_pub.find_pos(l_line_tbl,'LINE_NUM',nLine_num_pos);

         xProgress := 'POOB-10-1402';
         ece_extract_utils_pub.find_pos(l_line_tbl,'PO_LINE_ID',nLine_key_pos);

         xProgress := 'POOB-10-1404';
         ece_extract_utils_pub.find_pos(l_line_tbl,'ITEM_ID',nItem_id_pos);

	 xProgress := 'POOB-10-1405';
         ece_extract_utils_pub.find_pos(l_line_tbl,'CANCEL_FLAG',nLine_Cancel_Flag_pos);
      -- 2823215
	 xProgress := 'POOB-10-1406';
         ece_extract_utils_pub.find_pos(l_line_tbl,'UOM_CODE',nLine_uom_code_pos);

         xProgress := 'POOB-10-1407';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE_CATEGORY',nLp_att_cat_pos);

	 xProgress := 'POOB-10-1408';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE1',nLp_att1_pos);

	 xProgress := 'POOB-10-1409';
         ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE2',nLp_att2_pos);

	 xProgress := 'POOB-10-1410';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE3',nLp_att3_pos);

	 xProgress := 'POOB-10-1411';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE4',nLp_att4_pos);

	 xProgress := 'POOB-10-1412';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE5',nLp_att5_pos);

	 xProgress := 'POOB-10-1413';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE6',nLp_att6_pos);

	 xProgress := 'POOB-10-1414';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE7',nLp_att7_pos);

	 xProgress := 'POOB-10-1415';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE8',nLp_att8_pos);

	 xProgress := 'POOB-10-1416';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE9',nLp_att9_pos);

	 xProgress := 'POOB-10-1417';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE10',nLp_att10_pos);

	 xProgress := 'POOB-10-1418';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE11',nLp_att11_pos);

	 xProgress := 'POOB-10-1419';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE12',nLp_att12_pos);

	 xProgress := 'POOB-10-1420';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE13',nLp_att13_pos);

	 xProgress := 'POOB-10-1421';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE14',nLp_att14_pos);

	 xProgress := 'POOB-10-1422';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE15',nLp_att15_pos); -- 2823215


         -- Shipment Level Positions
         xProgress := 'POOB-10-1423';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'LINE_LOCATION_ID',nShip_Line_Location_ID_pos);

	 xProgress := 'POOB-10-1424';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'CANCELLED_FLAG',nShipment_Cancel_Flag_pos);

	 xProgress := 'POOB-10-1025';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'POR_RELEASE_NUM',nShip_Release_Num_pos);

	 xProgress := 'POOB-10-1026';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'UOM_CODE',nLine_Location_uom_pos);

	 xProgress := 'POOB-10-1427';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'SHIPMENT_NUMBER',nShipment_key_pos);

	 xProgress := 'POOB-10-1428';
	 ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIP_TO_CUSTOMER_NAME',nSt_cust_name_pos);

         xProgress := 'POOB-10-1429';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIP_TO_CONTACT_NAME',nSt_cont_name_pos);

         xProgress := 'POOB-10-1430';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIP_TO_CONTACT_PHONE',nSt_cont_phone_pos);

         xProgress := 'POOB-10-1431';
	 ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIP_TO_CONTACT_FAX',nSt_cont_fax_pos);

         xProgress := 'POOB-10-1432';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIP_TO_CONTACT_EMAIL',nSt_cont_email_pos);

         xProgress := 'POOB-10-1433';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPPING_INSTRUCTIONS',nShipping_Instruct_pos);

	 xProgress := 'POOB-10-1434';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'PACKING_INSTRUCTIONS',nPacking_Instruct_pos);

	 xProgress := 'POOB-10-1435';
	 ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPPING_METHOD',nShipping_method_pos);

	 xProgress := 'POOB-10-1437';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'CUSTOMER_PO_NUMBER',nCust_po_num_pos);

	 xProgress := 'POOB-10-1438';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'CUSTOMER_PO_LINE_NUM',nCust_po_line_num_pos);

	 xProgress := 'POOB-10-1439';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'CUSTOMER_PO_SHIPMENT_NUM',nCust_po_ship_num_pos);

	 xProgress := 'POOB-10-1440';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'CUSTOMER_ITEM_DESCRIPTION',nCust_prod_desc_pos);

	 xProgress := 'POOB-10-1441';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_LOCATION',nDeliv_cust_loc_pos);

         xProgress := 'POOB-10-1442';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_CUSTOMER_NAME',nDeliv_cust_name_pos);

	 xProgress := 'POOB-10-1443';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_CONTACT_NAME',nDeliv_cont_name_pos);

	 xProgress := 'POOB-10-1444';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_CONTACT_PHONE',nDeliv_cont_phone_pos);

	 xProgress := 'POOB-10-1445';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_CONTACT_FAX',nDeliv_cont_fax_pos);

	 xProgress := 'POOB-10-1446';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_CUSTOMER_ADDRESS',nDeliv_cust_addr_pos);

	 xProgress := 'POOB-10-1447';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'DELIVER_TO_CONTACT_EMAIL',nDeliv_cont_email_pos);

-- 2823215
         xProgress := 'POOB-10-1448';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'CODE_UOM',nShp_uom_pos);

	 xProgress := 'POOB-10-1449';
         ece_flatfile_pvt.find_pos(l_line_tbl,'UOM_CODE',nLine_uom_pos);

	 if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'n_trx_date_pos: ',n_trx_date_pos);
          ec_debug.pl(3,'nHeader_key_pos: ',nHeader_key_pos);
          ec_debug.pl(3,'nDocument_type_pos: ',nDocument_type_pos);
          ec_debug.pl(3,'nPO_Number_pos: ',nPO_Number_pos);
          ec_debug.pl(3,'nPO_Type_pos: ',nPO_Type_pos);
          ec_debug.pl(3,'nRelease_num_pos: ',nRelease_num_pos);
          ec_debug.pl(3,'nRelease_id_pos: ',nRelease_id_pos);
          ec_debug.pl(3,'nLine_Location_ID_pos: ',nLine_Location_ID_pos);
          ec_debug.pl(3,'nLine_num_pos: ',nLine_num_pos);
          ec_debug.pl(3,'nLine_key_pos: ',nLine_key_pos);
          ec_debug.pl(3,'nItem_id_pos: ',nItem_id_pos);
          ec_debug.pl(3,'nShip_Line_Location_ID_pos: ',nShip_Line_Location_ID_pos);
         end if;

         -- Timezone enhancement
	 xProgress := 'POOB-TZ-1000';
        ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_DATE', nRel_date_pos);

	xProgress := 'POOB-TZ-1001';
        ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_DT_TZ_CODE',nRel_dt_tz_pos);

	xProgress := 'POOB-TZ-1002';
        ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_DT_OFF',nRel_dt_off_pos);

	xProgress := 'POOB-TZ-1003';
        ece_flatfile_pvt.find_pos(l_header_tbl,'CREATION_DATE',nCrtn_date_pos);

	xProgress := 'POOB-TZ-1004';
        ece_flatfile_pvt.find_pos(l_header_tbl,'CREATION_DT_TZ_CODE',nCrtn_dt_tz_pos);

	xProgress := 'POOB-TZ-1005';
        ece_flatfile_pvt.find_pos(l_header_tbl,'CREATION_DT_OFF',nCrtn_dt_off_pos);

	xProgress := 'POOB-TZ-1006';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_REVISION_DATE',nRev_date_pos);

        xProgress := 'POOB-TZ-1007';
        ece_flatfile_pvt.find_pos(l_header_tbl,'REVISION_DT_TZ_CODE',nRev_dt_tz_pos);

	xProgress := 'POOB-TZ-1008';
        ece_flatfile_pvt.find_pos(l_header_tbl,'REVISION_DT_OFF',nRev_dt_off_pos);

	xProgress := 'POOB-TZ-1009';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_ACCEPTANCE_DUE_BY_DATE',nAcc_due_dt_pos);

	xProgress := 'POOB-TZ-1010';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_ACCEPT_DUE_TZ_CODE',nAcc_due_tz_pos);

	xProgress := 'POOB-TZ-1011';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_ACCEPT_DUE_OFF',nAcc_due_off_pos);

	xProgress := 'POOB-TZ-1012';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_START_DATE',nBlkt_srt_dt_pos);

	xProgress := 'POOB-TZ-1013';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_SRT_DT_TZ_CODE',nBlkt_srt_tz_pos);

	xProgress := 'POOB-TZ-1014';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_SRT_DT_OFF',nBlkt_srt_off_pos);

	xProgress := 'POOB-TZ-1015';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_END_DATE',nBlkt_end_dt_pos);

	xProgress := 'POOB-TZ-1016';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_END_DT_TZ_CODE',nBlkt_end_tz_pos);

	xProgress := 'POOB-TZ-1017';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_END_DT_OFF',nBlkt_end_off_pos);

	xProgress := 'POOB-TZ-1018';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PCARD_EXPIRATION_DATE',nPcard_exp_dt_pos);

	xProgress := 'POOB-TZ-1019';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PCARD_EXPRN_DT_TZ_CODE',nPcard_exp_tz_pos);

	xProgress := 'POOB-TZ-1020';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PCARD_EXPRN_DT_OFF',nPcard_exp_off_pos);


        xProgress := 'POOB-TZ-1021';
        ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_CANCELLED_DATE',nLine_can_dt_pos);

	xProgress := 'POOB-TZ-1022';
        ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_CANCEL_DT_TZ_CODE',nLine_can_tz_pos);

	xProgress := 'POOB-TZ-1023';
        ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_CANCEL_DT_OFF',nLine_can_off_pos);

	xProgress := 'POOB-TZ-1024';
        ece_flatfile_pvt.find_pos(l_line_tbl,'EXPIRATION_DATE',nExprn_dt_pos);

	xProgress := 'POOB-TZ-1025';
        ece_flatfile_pvt.find_pos(l_line_tbl,'EXPIRATION_DT_TZ_CODE',nExprn_tz_pos);

	xProgress := 'POOB-TZ-1026';
        ece_flatfile_pvt.find_pos(l_line_tbl,'EXPIRATION_DT_OFF',nExprn_off_pos);

        xProgress := 'POOB-TZ-1027';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_NEED_BY_DATE',nShip_need_dt_pos);

	xProgress := 'POOB-TZ-1028';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_NEED_DT_TZ_CODE',nShip_need_tz_pos);

	xProgress := 'POOB-TZ-1029';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_NEED_DT_OFF',nShip_need_off_pos);

	xProgress := 'POOB-TZ-1030';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_PROMISED_DATE',nShip_prom_dt_pos);

	xProgress := 'POOB-TZ-1031';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_PROM_DT_TZ_CODE',nShip_prom_tz_pos);

	xProgress := 'POOB-TZ-1032';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_PROM_DT_OFF',nShip_prom_off_pos);

	xProgress := 'POOB-TZ-1033';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_LAST_ACCEPTABLE_DATE',nShip_accept_dt_pos);

	xProgress := 'POOB-TZ-1034';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_LAST_ACC_DT_TZ_CODE',nShip_accept_tz_pos);

	xProgress := 'POOB-TZ-1035';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_LAST_ACC_DT_OFF',nShip_accept_off_pos);

        xProgress := 'POOB-TZ-1036';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'CANCELLED_DATE',nShp_can_dt_pos);

	xProgress := 'POOB-TZ-1037';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'CANCEL_DT_TZ_CODE',nShp_can_tz_pos);

	xProgress := 'POOB-TZ-1038';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'CANCEL_DT_OFF',nShp_can_off_pos);

	xProgress := 'POOB-TZ-1039';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'START_DATE',nShp_strt_dt_pos);

        xProgress := 'POOB-TZ-1040';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'START_DT_TZ_CODE',nShp_strt_tz_pos);

	xProgress := 'POOB-TZ-1041';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'START_DT_OFF',nShp_strt_off_pos);

	xProgress := 'POOB-TZ-1042';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'END_DATE',nShp_end_dt_pos);

	xProgress := 'POOB-TZ-1043';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'END_DT_TZ_CODE',nShp_end_tz_pos);

	xProgress := 'POOB-TZ-1044';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'END_DT_OFF',nShp_end_off_pos);
        -- Timezone enhancement
         xProgress := 'POOB-09-1400';
        ece_flatfile_pvt.find_pos(l_header_tbl,c_header_common_key_name,n_header_common_key_pos);

         xProgress := 'POOB-09-1401';
        ece_flatfile_pvt.find_pos(l_line_tbl,c_line_common_key_name,n_line_common_key_pos);

        xProgress := 'POOB-09-1402';
	ece_flatfile_pvt.find_pos(l_shipment_tbl,c_shipment_key_name,n_ship_common_key_pos);

         xProgress := 'POOB-10-1407';
         -- bind variables
         dbms_sql.bind_variable(header_sel_c,'cComm_Method',cCommunication_Method);
         IF cCreate_Date_From IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cCreate_Dt_From',cCreate_Date_From);
         END IF;

         IF cCreate_Date_To IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cCreate_Dt_To',cCreate_Date_To);
         END IF;

         IF cSupplier_Name IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cSuppl_Name',cSupplier_Name);
         END IF;

         IF cSupplier_Site IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cSuppl_Site',cSupplier_Site);
         END IF;

         IF cDocument_Type IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cDoc_Type',cDocument_Type);
         END IF;

         IF cPO_Number_From IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cPO_Num_From',cPO_Number_From);
         END IF;

         IF cPO_Number_To IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cPO_Num_To',cPO_Number_To);
         END IF;

         --  dbms_sql.bind_variable(line_sel_c,'l_nOrganization_ID',nOrganization_ID);

         iKey_count := 0;
         if ec_debug.G_debug_level = 3 then
         	ec_debug.pl(3,'iKey_count: ',iKey_count);
         end if;

         -- EXECUTE the SELECT statement
         xProgress := 'POOB-10-1408';
         dummy := dbms_sql.execute(header_sel_c);

         -- ***************************************************
         -- The model is:
         -- HEADER - LINE - SHIPMENT ...
         -- With data for each HEADER line, populate the header
         -- interfacetable then get all LINES that belongs
         -- to the HEADER. Then get all
         -- SHIPMENTS that belongs to the LINE.
         -- ***************************************************
         xProgress := 'POOB-10-1430';
         WHILE dbms_sql.fetch_rows(Header_sel_c) > 0 LOOP           -- Header

            -- **************************************
            --  store internal values in pl/sql table
            -- **************************************
            if (NOT utl_file.is_open(ece_poo_transaction.uFile_type)) then
                ece_poo_transaction.uFile_type := utl_file.fopen(i_path,i_filename,'W',32767);
            end if;
            xProgress := 'POOB-10-1431';
            ece_flatfile_pvt.assign_column_value_to_tbl(Header_sel_c,0,l_header_tbl,l_key_tbl);

            -- ***************************************************
            --  also need to populate transaction_date and run_id
            -- ***************************************************
            xProgress := 'POOB-10-1432';
            l_header_tbl(n_trx_date_pos).value := TO_CHAR(dTransaction_date,'YYYYMMDD HH24MISS');

            --  The application specific feedback logic begins here.
            xProgress := 'POOB-10-1440';
            BEGIN
		/* Bug 2396394 Added the document type CONTRACT in SQL below */
               SELECT   DECODE(l_header_tbl(nDocument_type_pos).value,
                              'BLANKET'         ,'NB',
                              'STANDARD'        ,'NS',
                              'PLANNED'         ,'NP',
                              'RELEASE'         ,'NR',
                              'BLANKET RELEASE' ,'NR',
                              'CONTRACT'        ,'NC',
                              'NR')
               INTO     l_document_type
               FROM     DUAL;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,
                             'EC',
                             'ECE_DECODE_FAILED',
                             'PROGRESS_LEVEL',
                              xProgress,
                             'CODE',
                              l_header_tbl(nDocument_type_pos).value);
            END;
	    if ec_debug.G_debug_level = 3 then
            ec_debug.pl(3, 'l_document_type: ',l_document_type);
            end if;
            xProgress := 'POOB-10-1450';


            ece_poo_transaction.update_po(l_document_type,
                                          l_header_tbl(nPO_Number_pos).value,
                                          l_header_tbl(nPO_type_pos).value,
                                          l_header_tbl(nRelease_num_pos).value);

            xProgress := 'POOB-TZ-1500';
            ece_timezone_api.get_server_timezone_details(
              to_date(l_header_tbl(nRel_date_pos).value,'YYYYMMDD HH24MISS'),
              l_header_tbl(nRel_dt_off_pos).value,
	      l_header_tbl(nRel_dt_tz_pos).value
            );

	    xProgress := 'POOB-TZ-1510';

            ece_timezone_api.get_server_timezone_details
            (
              to_date(l_header_tbl(nCrtn_date_pos).value,'YYYYMMDD HH24MISS'),
              l_header_tbl(nCrtn_dt_off_pos).value,
	      l_header_tbl(nCrtn_dt_tz_pos).value
            );

	    xProgress := 'POOB-TZ-1520';

            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nRev_date_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nRev_dt_off_pos).value,
	     l_header_tbl(nRev_dt_tz_pos).value
            );

	    xProgress := 'POOB-TZ-1530';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nAcc_due_dt_pos).value,'YYYYMMDD HH24MISS'),
	     l_header_tbl(nAcc_due_off_pos).value,
             l_header_tbl(nAcc_due_tz_pos).value
            );

	    xProgress := 'POOB-TZ-1540';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nBlkt_srt_dt_pos).value,'YYYYMMDD HH24MISS'),
	     l_header_tbl(nBlkt_srt_off_pos).value,
             l_header_tbl(nBlkt_srt_tz_pos).value
            );

	    xProgress := 'POOB-TZ-1550';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nBlkt_end_dt_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nBlkt_end_off_pos).value,
	     l_header_tbl(nBlkt_end_tz_pos).value
            );

	    xProgress := 'POOB-TZ-1560';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nPcard_exp_dt_pos).value,'YYYYMMDD HH24MISS'),
	     l_header_tbl(nPcard_exp_off_pos).value,
             l_header_tbl(nPcard_exp_tz_pos).value
            );

            -- pass the pl/sql table in for xref
            xProgress := 'POOB-10-1460';
            ec_code_conversion_pvt.populate_plsql_tbl_with_extval(p_api_version_number => 1.0,
                                                                  p_init_msg_list      => init_msg_list,
                                                                  p_simulate           => simulate,
                                                                  p_commit             => commt,
                                                                  p_validation_level   => validation_level,
                                                                  p_return_status      => return_status,
                                                                  p_msg_count          => msg_count,
                                                                  p_msg_data           => msg_data,
                                                                  p_key_tbl            => l_key_tbl,
                                                                  p_tbl                => l_header_tbl);

            -- ***************************
            -- insert into interface table
            -- ***************************
            xProgress := 'POOB-10-1480';
            BEGIN
               SELECT   ece_poo_header_s.NEXTVAL
               INTO     l_header_fkey
               FROM     DUAL;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,
                             'EC',
                             'ECE_GET_NEXT_SEQ_FAILED',
                             'PROGRESS_LEVEL',
                              xProgress,
                             'SEQ',
                             'ECE_POO_HEADER_S');

            END;
            ec_debug.pl(3,'l_header_fkey: ',l_header_fkey);
--2823215
            xProgress := 'POOB-10-1490';

            c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),1,25),25);

            xProgress         := 'POOB-10-1491';
            c_file_common_key := c_file_common_key ||
                                 RPAD(SUBSTRB(NVL(l_header_tbl(n_header_common_key_pos).value,' '),1,22),22) || RPAD(' ',22) || RPAD(' ',22);

            ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);


           /*  ece_extract_utils_pub.insert_into_interface_tbl(iRun_id,
                                                            cTransaction_Type,
                                                            cCommunication_Method,
                                                            cHeader_Interface,
                                                            l_header_tbl,
                                                            l_header_fkey);  */

            -- Now update the columns values of which have been obtained
            -- thru the procedure calls.

            -- ********************************************************
            -- Call custom program stub to populate the extension table
            -- ********************************************************
            xProgress := 'POOB-10-1492';
            ece_poo_x.populate_ext_header(l_header_fkey,l_header_tbl);
-- 2823215
            ece_poo_transaction.write_to_file(cTransaction_Type,
                                              cCommunication_Method,
                                              cHeader_Interface,
                                              l_header_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              c_file_common_key,
                                              l_header_fkey);

-- 2823215
            -- Header Level Attachment Handler
            xProgress := 'POOB-10-1501';
            IF v_header_att_enabled = 'Y' THEN
               xProgress := 'POOB-10-1502';
               IF l_document_type = 'NR' THEN -- If this is a Release PO.
                  xProgress := 'POOB-10-1503';
                  v_entity_name := 'PO_RELEASES';
                  v_pk1_value := l_header_tbl(nRelease_id_pos).value;
	            if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'release_id: ',l_header_tbl(nRelease_id_pos).value);
                    end if;
               ELSE -- If this is a non-Release PO.
                  xProgress := 'POOB-10-1504';
                  v_entity_name := 'PO_HEADERS';
                  v_pk1_value := l_header_tbl(nHeader_key_pos).value;
	            if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'po_header_id: ',l_header_tbl(nHeader_key_pos).value);
                    end if;
               END IF;

               xProgress := 'POOB-10-1505';
               ece_poo_transaction.populate_text_attachment(cCommunication_Method,
                                                            cTransaction_Type,
                                                            iRun_id,
                                                            2,
                                                            3,
                                                            cAtt_Header_Interface,
                                                            cAtt_Detail_Interface,
                                                            v_entity_name,
                                                            'VENDOR',
                                                            v_pk1_value,
                                                            C_ANY_VALUE,
                                                            C_ANY_VALUE,
                                                            C_ANY_VALUE,
                                                            C_ANY_VALUE,
                                                            n_att_seg_size,
                                                            l_key_tbl,
							    c_file_common_key,
                                                            l_hdr_att_hdr_tbl,
                                                            l_hdr_att_dtl_tbl,
                                                            iAtt_hdr_pos); -- 2823215
	    --Start of code changes for the bug 15880908
	    --Added this logic to retrieve the Vendor Site Level Attachments
	    if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3, 'Vendor Site ID Value : ',l_header_tbl(nVendor_Site_Id_pos).value);
            end if;

            v_entity_name := 'PO_VENDOR_SITES';
            v_pk1_value := l_header_tbl(nVendor_Site_Id_pos).Value;
            ece_poo_transaction.populate_text_attachment(cCommunication_Method,
                                                            cTransaction_Type,
                                                            iRun_id,
                                                            2,
                                                            3,
                                                            cAtt_Header_Interface,
                                                            cAtt_Detail_Interface,
                                                            v_entity_name,
                                                            'VENDOR',
                                                            v_pk1_value,
                                                            C_ANY_VALUE,
                                                            C_ANY_VALUE,
                                                            C_ANY_VALUE,
                                                            C_ANY_VALUE,
                                                            n_att_seg_size,
                                                            l_key_tbl,
                                                            c_file_common_key,
                                                            l_hdr_att_hdr_tbl,
                                                            l_hdr_att_dtl_tbl,
                                                            iAtt_hdr_pos);
	    --End of code changes for the bug 15880908
            END IF;

            -- ***************************************************
            -- From Header data, we can assign values to
            -- place holders (foreign keys) in Line_select and
            -- Line_detail_Select
            -- set values into binding variables
            -- ***************************************************

            -- use the following bind_variable feature as you see fit.
            xProgress := 'POOB-10-1510';
            dbms_sql.bind_variable(line_sel_c,'po_header_id',l_header_tbl(nHeader_key_pos).value);

            xProgress := 'POOB-10-1515';
            dbms_sql.bind_variable(line_sel_c,'por_release_num',l_header_tbl(nRelease_num_pos).value);

            xProgress := 'POOB-10-1520';
            dbms_sql.bind_variable(Shipment_sel_c,'po_header_id',l_header_tbl(nHeader_key_pos).value);

            xProgress := 'POOB-10-1525';
            dbms_sql.bind_variable(Shipment_sel_c,'por_release_id',l_header_tbl(nRelease_id_pos).value); --2823215

            xProgress := 'POOB-10-1530';
            dummy := dbms_sql.execute(line_sel_c);

            -- ***************************
            -- Line Level Loop Starts Here
            -- ***************************
            xProgress := 'POOB-10-1540';
            WHILE dbms_sql.fetch_rows(line_sel_c) > 0 LOOP     --- Line

               -- ****************************
               -- store values in pl/sql table
               -- ****************************
               xProgress := 'POOB-10-1550';
               ece_flatfile_pvt.assign_column_value_to_tbl(line_sel_c,iHeader_count,l_line_tbl,l_key_tbl);

               -- The following procedure gets the part number for the
               -- item ID returned
               xProgress := 'POOB-10-1560';
               ece_inventory.get_item_number(l_line_tbl(nItem_ID_pos).value,
                                             nOrganization_ID,
                                             line_part_number,
                                             line_part_attrib_category,
                                             line_part_attribute1,
                                             line_part_attribute2,
                                             line_part_attribute3,
                                             line_part_attribute4,
                                             line_part_attribute5,
                                             line_part_attribute6,
                                             line_part_attribute7,
                                             line_part_attribute8,
                                             line_part_attribute9,
                                             line_part_attribute10,
                                             line_part_attribute11,
                                             line_part_attribute12,
                                             line_part_attribute13,
                                             line_part_attribute14,
                                             line_part_attribute15);

               begin

               select uom_code into l_line_tbl(nLine_uom_pos).value
	       from mtl_units_of_measure
	       where unit_of_measure = l_line_tbl(nLine_uom_code_pos).value;
	       exception
	       when others then
	       null;
	       end;


               xProgress := 'POOB-TZ-2500';
	       ece_timezone_api.get_server_timezone_details
               (
                to_date(l_line_tbl(nLine_can_dt_pos).value,'YYYYMMDD HH24MISS'),
                l_line_tbl(nLine_can_off_pos).value,
		l_line_tbl(nLine_can_tz_pos).value
                );

	       xProgress := 'POOB-TZ-2510';

               ece_timezone_api.get_server_timezone_details
               (
                to_date(l_line_tbl(nExprn_dt_pos).value,'YYYYMMDD HH24MISS'),
                l_line_tbl(nExprn_off_pos).value,
		l_line_tbl(nExprn_tz_pos).value
               );

	       -- pass the pl/sql table in for xref
               xProgress := 'POOB-10-1570';
               ec_code_conversion_pvt.populate_plsql_tbl_with_extval(
                  p_api_version_number => 1.0,
                  p_init_msg_list      => init_msg_list,
                  p_simulate           => simulate,
                  p_commit             => commt,
                  p_validation_level   => validation_level,
                  p_return_status      => return_status,
                  p_msg_count          => msg_count,
                  p_msg_data           => msg_data,
                  p_key_tbl            => l_key_tbl,
                  p_tbl                => l_line_tbl);

               xProgress := 'POOB-10-1590';
               BEGIN
                  SELECT   ece_poo_line_s.NEXTVAL INTO l_line_fkey
                  FROM     DUAL;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_POO_LINE_S');

               END;
               ec_debug.pl(3,'l_line_fkey: ',l_line_fkey);

	       if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'line_part_number: '         ,line_part_number);
               ec_debug.pl(3,'line_part_attrib_category: ',line_part_attrib_category);
               ec_debug.pl(3,'line_part_attribute1: '     ,line_part_attribute1);
               ec_debug.pl(3,'line_part_attribute2: '     ,line_part_attribute2);
               ec_debug.pl(3,'line_part_attribute3: '     ,line_part_attribute3);
               ec_debug.pl(3,'line_part_attribute4: '     ,line_part_attribute4);
               ec_debug.pl(3,'line_part_attribute5: '     ,line_part_attribute5);
               ec_debug.pl(3,'line_part_attribute6: '     ,line_part_attribute6);
               ec_debug.pl(3,'line_part_attribute7: '     ,line_part_attribute7);
               ec_debug.pl(3,'line_part_attribute8: '     ,line_part_attribute8);
               ec_debug.pl(3,'line_part_attribute9: '     ,line_part_attribute9);
               ec_debug.pl(3,'line_part_attribute10: '    ,line_part_attribute10);
               ec_debug.pl(3,'line_part_attribute11: '    ,line_part_attribute11);
               ec_debug.pl(3,'line_part_attribute12: '    ,line_part_attribute12);
               ec_debug.pl(3,'line_part_attribute13: '    ,line_part_attribute13);
               ec_debug.pl(3,'line_part_attribute14: '    ,line_part_attribute14);
               ec_debug.pl(3,'line_part_attribute15: '    ,line_part_attribute15);
              end if;

	       xProgress := 'POOB-10-1591';
               l_line_tbl(nLp_att_cat_pos).value := line_part_attrib_category;
	       l_line_tbl(nLp_att1_pos).value := line_part_attribute1;
               l_line_tbl(nLp_att2_pos).value := line_part_attribute2;
	       l_line_tbl(nLp_att3_pos).value := line_part_attribute3;
	       l_line_tbl(nLp_att4_pos).value := line_part_attribute4;
	       l_line_tbl(nLp_att5_pos).value := line_part_attribute5;
	       l_line_tbl(nLp_att6_pos).value := line_part_attribute6;
	       l_line_tbl(nLp_att7_pos).value := line_part_attribute7;
	       l_line_tbl(nLp_att8_pos).value := line_part_attribute8;
	       l_line_tbl(nLp_att9_pos).value := line_part_attribute9;
	       l_line_tbl(nLp_att10_pos).value := line_part_attribute10;
	       l_line_tbl(nLp_att11_pos).value := line_part_attribute11;
	       l_line_tbl(nLp_att12_pos).value := line_part_attribute12;
	       l_line_tbl(nLp_att13_pos).value := line_part_attribute13;
	       l_line_tbl(nLp_att14_pos).value := line_part_attribute14;
	       l_line_tbl(nLp_att15_pos).value := line_part_attribute15;

               xProgress := 'POOB-10-1600';
	        c_file_common_key := RPAD(SUBSTRB(NVL
                                                (l_header_tbl(nTrans_code_pos).value,' '),
                                                 1,
                                                 25),25) ||
                                          RPAD(SUBSTRB(NVL
                                                (l_header_tbl(n_header_common_key_pos).value,' '),
                                                 1,
                                                 22),22) ||
                                          RPAD(SUBSTRB(NVL
                                                (l_line_tbl(n_line_common_key_pos).value,' '),
                                                 1,
                                                 22),22) ||
                                          RPAD(' ',22);

              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'c_file_common_key: ',c_file_common_key);
              end if;

               xProgress := 'POOB-10-1620';
               ece_poo_x.populate_ext_line(l_line_fkey,l_line_tbl);
-- 2823215
               xProgress := 'POOB-10-1621';
               ece_poo_transaction.write_to_file( cTransaction_Type,
                                                  cCommunication_Method,
                                                  cLine_Interface,
                                                  l_line_tbl,
                                                  iOutput_width,
                                                  iRun_id,
                                                  c_file_common_key,
                                                  l_line_fkey);

--2823215
               -- Insert into Interface Table
  /*             xProgress := 'POOB-10-1600';
               ece_extract_utils_pub.insert_into_interface_tbl(iRun_id,cTransaction_Type,cCommunication_Method,cLine_Interface,l_line_tbl,l_line_fkey); */



               /***************************
               *  Line LEVEL Attachments  *
               ***************************/
               IF v_line_att_enabled = 'Y' THEN
                  xProgress := 'POOB-10-1621';
            /*      IF l_document_type = 'NR' THEN -- If this is a Release PO.
                     xProgress := 'POOB-10-1622';
                     v_entity_name := 'PO_SHIPMENTS';
                     v_pk1_value := l_line_tbl(nLine_Location_ID_pos).value; -- LINE_LOCATION_ID
	               if ec_debug.G_debug_level = 3 then
                     ec_debug.pl(3,'PO_LINE_LOCATION_ID: ',l_line_tbl(nLine_Location_ID_pos).value);
                     end if;
                  ELSE -- If this is a non-Release PO. */  --Bug 2187958
                     xProgress := 'POOB-10-1623';
                     v_entity_name := 'PO_LINES';
                     v_pk1_value := l_line_tbl(nLine_key_pos).value; -- LINE_ID
                	   if ec_debug.G_debug_level = 3 then
                     ec_debug.pl(3,'PO_LINE_ID: ',l_line_tbl(nLine_key_pos).value);
             --        end if;
                  END IF;

                  xProgress := 'POOB-10-1624';
                  ece_poo_transaction.populate_text_attachment(cCommunication_Method,
                                                               cTransaction_Type,
                                                               iRun_id,
                                                               5,
                                                               6,
                                                               cAtt_Header_Interface,
                                                               cAtt_Detail_Interface,
                                                               v_entity_name,
                                                               'VENDOR',
                                                               v_pk1_value,
                                                               C_ANY_VALUE,
                                                               C_ANY_VALUE,
                                                               C_ANY_VALUE,
                                                               C_ANY_VALUE,
                                                               n_att_seg_size,
                                                               l_key_tbl,
							       c_file_common_key,
                                                               l_ln_att_hdr_tbl,
                                                               l_ln_att_dtl_tbl,
                                                               iAtt_ln_pos);

               END IF;

               /***************************
               *  Master Org Attachments  *
               ***************************/
               IF v_mitem_att_enabled = 'Y' THEN
                  xProgress := 'POOB-10-1625';
                  v_entity_name := 'MTL_SYSTEM_ITEMS';
                  v_pk1_value := nOrganization_ID; -- Master Inventory Org ID

                  v_pk2_value := l_line_tbl(nitem_id_pos).value; -- Item ID
	            if ec_debug.G_debug_level = 3 then
                  ec_debug.pl(3,'Master Org ID: ',v_pk1_value);
                  ec_debug.pl(3,'Item ID: ',v_pk2_value);
                  end if;

                  xProgress := 'POOB-10-1626';
                  ece_poo_transaction.populate_text_attachment(cCommunication_Method,
                                                               cTransaction_Type,
                                                               iRun_id,
                                                               7,
                                                               8,
                                                               cAtt_Header_Interface,
                                                               cAtt_Detail_Interface,
                                                               v_entity_name,
                                                               'VENDOR',
                                                               v_pk1_value,
                                                               v_pk2_value,
                                                               NULL,
                                                               NULL,
                                                               NULL,
                                                               n_att_seg_size,
                                                               l_key_tbl,
							       c_file_common_key,
                                                               l_mi_att_hdr_tbl,
                                                               l_mi_att_dtl_tbl,
                                                               iAtt_mi_pos);
               END IF;

               /******************************
               *  Inventory Org Attachments  *
               ******************************/
	       /* Bug 3550723
               IF v_iitem_att_enabled = 'Y' THEN
                  xProgress := 'POOB-10-1627';
                  v_entity_name := 'MTL_SYSTEM_ITEMS';
                  v_pk2_value := l_line_tbl(nitem_id_pos).value; -- Item ID
	            if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'Item ID: ',v_pk2_value);
                  end if;

                  xProgress := 'POOB-10-1628';
                  FOR v_org_id IN c_org_id(l_line_tbl(nLine_key_pos).value) LOOP -- Value passed is the Line ID
                     IF v_org_id.ship_to_organization_id <> nOrganization_ID THEN -- Only do this if it is not the same as the Master Org ID
                        v_pk1_value := v_org_id.ship_to_organization_id;
	                  if ec_debug.G_debug_level = 3 then
                        ec_debug.pl(3,'Inventory Org ID: ',v_pk1_value);
                        end if;

                        xProgress := 'POOB-10-1626';
                        ece_poo_transaction.populate_text_attachment(cCommunication_Method,
                                                                     cTransaction_Type,
                                                                     iRun_id,
                                                                     9,
                                                                     10,
                                                                     cAtt_Header_Interface,
                                                                     cAtt_Detail_Interface,
                                                                     v_entity_name,
                                                                     'VENDOR',
                                                                     v_pk1_value,
                                                                     v_pk2_value,
                                                                     NULL,
                                                                     NULL,
                                                                     NULL,
                                                                     n_att_seg_size,
                                                                     l_key_tbl,
								     c_file_common_key,
                                                                     l_msi_att_hdr_tbl,
                                                                     l_msi_att_dtl_tbl,
                                                                     iAtt_msi_pos);
                     END IF;
                  END LOOP;
               END IF;
	       */

               -- **********************
               -- set LINE_NUMBER values
               -- **********************
 --  Removed based on bug:3957851
 --               xProgress := 'POOB-10-1627';
 --              dbms_sql.bind_variable(shipment_sel_c,'shipment_number',l_line_tbl(nLine_num_pos).value);

               xProgress := 'POOB-10-1630';
               dbms_sql.bind_variable(shipment_sel_c,'po_line_id',l_line_tbl(nLine_key_pos).value);

               xProgress := 'POOB-10-1640';
               dummy := dbms_sql.execute(shipment_sel_c);

               -- *************************
               -- Shipment loop starts here
               -- *************************
               xProgress := 'POOB-10-1650';
               WHILE dbms_sql.fetch_rows(shipment_sel_c) > 0 LOOP    --- Shipment

                  -- ****************************
                  -- store values in pl/sql table
                  -- ****************************
                  xProgress := 'POOB-10-1660';
                  ece_flatfile_pvt.assign_column_value_to_tbl(shipment_sel_c,iHeader_count + iLine_count,l_shipment_tbl,l_key_tbl);

                  xProgress := 'POOB-10-1670';
                  BEGIN
                     SELECT   ece_poo_shipment_s.NEXTVAL INTO l_shipment_fkey
                     FROM     DUAL;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_POO_SHIPMENT_S');
                  END;
	            if ec_debug.G_debug_level = 3 then
                  ec_debug.pl(3, 'l_shipment_fkey: ',l_shipment_fkey);
                  end if;

                  l_shipment_tbl(nLine_Location_uom_pos).value := l_line_tbl(nLine_uom_code_pos).value;   -- bug 2823215

                  l_shipment_tbl(nShip_Release_Num_pos).value := l_header_tbl(nRelease_num_pos).value;     -- bug 2823215

		  l_shipment_tbl(nShp_uom_pos).value := l_line_tbl(nLine_uom_pos).value;

		  xProgress := 'POOB-TZ-3500';
		  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShip_need_dt_pos).value,'YYYYMMDD HH24MISS'),
                   l_shipment_tbl(nShip_need_off_pos).value,
		   l_shipment_tbl(nShip_need_tz_pos).value
                  );

		  xProgress := 'POOB-TZ-3510';
                  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShip_prom_dt_pos).value,'YYYYMMDD HH24MISS'),
                   l_shipment_tbl(nShip_prom_off_pos).value,
		   l_shipment_tbl(nShip_prom_tz_pos).value
                  );

		  xProgress := 'POOB-TZ-3520';
                  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShip_accept_dt_pos).value,'YYYYMMDD HH24MISS'),
                   l_shipment_tbl(nShip_accept_off_pos).value,
		   l_shipment_tbl(nShip_accept_tz_pos).value
                  );

		  xProgress := 'POOB-TZ-3530';
                  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShp_can_dt_pos).value,'YYYYMMDD HH24MISS'),
                   l_shipment_tbl(nShp_can_off_pos).value,
		   l_shipment_tbl(nShp_can_tz_pos).value
                   );

		   xProgress := 'POOB-TZ-3540';
                   ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShp_strt_dt_pos).value,'YYYYMMDD HH24MISS'),
                   l_shipment_tbl(nShp_strt_off_pos).value,
		   l_shipment_tbl(nShp_strt_tz_pos).value
                   );

		   xProgress := 'POOB-TZ-3550';
                   ece_timezone_api.get_server_timezone_details
                   (
                    to_date(l_shipment_tbl(nShp_end_dt_pos).value,'YYYYMMDD HH24MISS'),
                    l_shipment_tbl(nShp_end_off_pos).value,
		    l_shipment_tbl(nShp_end_tz_pos).value
                   );
                  -- pass the pl/sql table in for xref
                  xProgress := 'POOB-10-1680';
                  ec_code_conversion_pvt.populate_plsql_tbl_with_extval(p_api_version_number => 1.0,
                                                                        p_init_msg_list      => init_msg_list,
                                                                        p_simulate           => simulate,
                                                                        p_commit             => commt,
                                                                        p_validation_level   => validation_level,
                                                                        p_return_status      => return_status,
                                                                        p_msg_count          => msg_count,
                                                                        p_msg_data           => msg_data,
                                                                        p_key_tbl            => l_key_tbl,
                                                                        p_tbl                => l_shipment_tbl);

          /*        xProgress := 'POOB-10-1690';

                  ece_extract_utils_pub.insert_into_interface_tbl(iRun_id,cTransaction_Type,cCommunication_Method,cShipment_Interface,l_shipment_tbl,l_shipment_fkey); */

                   xProgress := 'POOB-10-1690';
		   c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value    ,' '),1,25),25) ||
                                       RPAD(SUBSTRB(NVL(l_header_tbl(n_header_common_key_pos).value    ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_line_tbl(n_line_common_key_pos).value        ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_shipment_tbl(n_ship_common_key_pos).value,' '),1,22),22);
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);
                  end if;


                  xProgress := 'POOB-10-1700';
                  ece_poo_x.populate_ext_shipment(l_shipment_fkey,l_shipment_tbl);


                  -- Drop shipment
                  xProgress := 'POOB-10-1691';
                  v_drop_ship_flag := OE_DROP_SHIP_GRP.PO_Line_Location_Is_Drop_Ship(l_shipment_tbl(nShip_Line_Location_ID_pos).value);
                  xProgress := 'POOB-10-1692';

                  if ec_debug.G_debug_level = 3 then
                  ec_debug.pl(3, 'Drop Ship Flag:',v_drop_ship_flag);
                  end if;

                  IF (v_drop_ship_flag is NOT NULL) THEN

                  v_header_cancel_flag := l_header_tbl(nHeader_Cancel_Flag_pos).value;
                  v_line_cancel_flag := l_line_tbl(nLine_Cancel_Flag_pos).value;
                  v_shipment_cancel_flag := l_shipment_tbl(nShipment_Cancel_Flag_pos).value;

		  if ec_debug.G_debug_level = 3 then
		   ec_debug.pl(3,'v_header_cancel_flag:',v_header_cancel_flag);
		   ec_debug.pl(3,'v_line_cancel_flag:',v_line_cancel_flag);
		   ec_debug.pl(3,'v_shipment_cancel_flag:',v_shipment_cancel_flag);
		  END IF;

                  if ((nvl(v_header_cancel_flag,'N') <> 'Y')
                     and (nvl(v_line_cancel_flag,'N') <> 'Y')
                     and (nvl(v_shipment_cancel_flag,'N') <> 'Y')) then

                  xProgress := 'POOB-10-1696';
                  OE_DROP_SHIP_GRP.GET_ORDER_LINE_INFO(1.0,
                                                       l_header_tbl(nHeader_key_pos).value,
                                                       l_line_tbl(nLine_key_pos).value,
                                                       l_shipment_tbl(nShip_Line_Location_ID_pos).value,
                                                       l_header_tbl(nRelease_id_pos).value,
                                                       2,
                                                       rec_order_line_info,
                                                       msg_data,
                                                       msg_count,
                                                       return_status
                                                       );
                  xProgress := 'POOB-10-1670';

		  if ec_debug.G_debug_level = 3 then
		   ec_debug.pl(3,'Ship to Customer Name:',rec_order_line_info.ship_to_customer_name);
		   ec_debug.pl(3,'Ship to Contact Name:',rec_order_line_info.ship_to_contact_name);
		   ec_debug.pl(3,'Ship to Contact Phone:',rec_order_line_info.ship_to_contact_phone);
                   ec_debug.pl(3,'Ship to Contact Fax:',rec_order_line_info.ship_to_contact_fax);
		   ec_debug.pl(3,'Ship to Contact Email:',rec_order_line_info.ship_to_contact_email);
		   ec_debug.pl(3,'Shipping Instructions:',rec_order_line_info.shipping_instructions);
		   ec_debug.pl(3,'Packing Instructions:',rec_order_line_info.packing_instructions);
		   ec_debug.pl(3,'Shipping Method:',rec_order_line_info.shipping_method);
		   ec_debug.pl(3,'Customer PO Number:',rec_order_line_info.customer_po_number);
		   ec_debug.pl(3,'Customer PO Line Number:',rec_order_line_info.customer_po_line_number);
		   ec_debug.pl(3,'Customer PO Shipment Num:',rec_order_line_info.customer_po_shipment_number);
		   ec_debug.pl(3,'Customer Item Description:',rec_order_line_info.customer_product_description);
		   ec_debug.pl(3,'Deliver to Location:',rec_order_line_info.deliver_to_customer_location);
		   ec_debug.pl(3,'Deliver to Customer Name:',rec_order_line_info.deliver_to_customer_name);
		   ec_debug.pl(3,'Deliver to Contact Name:',rec_order_line_info.deliver_to_customer_name);
		   ec_debug.pl(3,'Deliver to Contact Phone:',rec_order_line_info.deliver_to_contact_phone);
		   ec_debug.pl(3,'Deliver to Contact Fax:',rec_order_line_info.deliver_to_contact_fax);
		   ec_debug.pl(3,'Deliver to Customer Address:',rec_order_line_info.deliver_to_customer_address);
		   ec_debug.pl(3,'Deliver to Contact Email:', rec_order_line_info.deliver_to_contact_email);
		   end if;

                  -- 2823215
                    l_shipment_tbl(nSt_cust_name_pos).value := rec_order_line_info.ship_to_customer_name;
                    l_shipment_tbl(nSt_cont_name_pos).value := rec_order_line_info.ship_to_contact_name;
                    l_shipment_tbl(nSt_cont_phone_pos).value := rec_order_line_info.ship_to_contact_phone;
                    l_shipment_tbl(nSt_cont_fax_pos).value := rec_order_line_info.ship_to_contact_fax;
                    l_shipment_tbl(nSt_cont_email_pos).value := rec_order_line_info.ship_to_contact_email;
                    l_shipment_tbl(nShipping_Instruct_pos).value := rec_order_line_info.shipping_instructions;
                    l_shipment_tbl(nPacking_Instruct_pos).value := rec_order_line_info.packing_instructions;
                    l_shipment_tbl(nShipping_method_pos).value := rec_order_line_info.shipping_method;
                    l_shipment_tbl(nCust_po_num_pos).value := rec_order_line_info.customer_po_number;
                    l_shipment_tbl(nCust_po_line_num_pos).value := rec_order_line_info.customer_po_line_number;
                    l_shipment_tbl(nCust_po_ship_num_pos).value := rec_order_line_info.customer_po_shipment_number;
                    l_shipment_tbl(nCust_prod_desc_pos).value := rec_order_line_info.customer_product_description;
                    l_shipment_tbl(nDeliv_cust_loc_pos).value := rec_order_line_info.deliver_to_customer_location;
                    l_shipment_tbl(nDeliv_cust_name_pos).value := rec_order_line_info.deliver_to_customer_name;
                    l_shipment_tbl(nDeliv_cont_name_pos).value := rec_order_line_info.deliver_to_contact_name;
                    l_shipment_tbl(nDeliv_cont_phone_pos).value := rec_order_line_info.deliver_to_contact_phone;
                    l_shipment_tbl(nDeliv_cont_fax_pos).value := rec_order_line_info.deliver_to_contact_fax;
                    l_shipment_tbl(nDeliv_cust_addr_pos).value := rec_order_line_info.deliver_to_customer_address;
                    l_shipment_tbl(nDeliv_cont_email_pos).value := rec_order_line_info.deliver_to_contact_email;
                   -- 2823215
                   end if;

                  END IF;

-- 2823215
		  ece_poo_transaction.write_to_file(cTransaction_Type,
                                                    cCommunication_Method,
                                                    cShipment_Interface,
                                                    l_shipment_tbl,
                                                    iOutput_width,
                                                    iRun_id,
                                                    c_file_common_key,
                                                    l_shipment_fkey);
-- 2823215
                  -- ********************************************************
                  -- Call custom program stub to populate the extension table
                  -- ********************************************************
             /*     xProgress := 'POOB-10-1700';
                  ece_poo_x.populate_ext_shipment(l_shipment_fkey,l_shipment_tbl); */

                  -- Shipment Level Attachment Handler
                  xProgress := 'POOB-10-1710';
                  IF v_ship_att_enabled = 'Y' THEN
                     v_entity_name := 'PO_SHIPMENTS';
                     v_pk1_value := l_shipment_tbl(nShip_Line_Location_ID_pos).value;
	               if ec_debug.G_debug_level = 3 then
                     ec_debug.pl(3,'Ship Level Line Location ID: ',l_shipment_tbl(nShip_Line_Location_ID_pos).value);
                     end if;

                     xProgress := 'POOB-10-1720';
                     ece_poo_transaction.populate_text_attachment(cCommunication_Method,
                                                                  cTransaction_Type,
                                                                  iRun_id,
                                                                  12,
                                                                  13,
                                                                  cAtt_Header_Interface,
                                                                  cAtt_Detail_Interface,
                                                                  v_entity_name,
                                                                  'VENDOR',
                                                                  v_pk1_value,
                                                                  C_ANY_VALUE,
                                                                  C_ANY_VALUE,
                                                                  C_ANY_VALUE,
                                                                  C_ANY_VALUE,
                                                                  n_att_seg_size,
                                                                  l_key_tbl,
								  c_file_common_key,
                                                                  l_shp_att_hdr_tbl,
                                                                  l_shp_att_dtl_tbl,
                                                                  iAtt_shp_pos); -- 2823215
                  END IF;

                  -- Project Level Handler
                  xProgress := 'POOB-10-1730';
             --     IF v_project_acct_status = 'I' THEN -- Project Accounting is Installed --Bug 1891291
                     ece_poo_transaction.POPULATE_DISTRIBUTION_INFO(
                        cCommunication_Method,
                        cTransaction_Type,
                        iRun_id,
                        cDistribution_Interface,
                        l_key_tbl,
                        l_header_tbl(nHeader_key_pos).value,               -- PO_HEADER_ID
                        l_header_tbl(nRelease_id_pos).value,               -- PO_RELEASE_ID
                        l_line_tbl(nLine_key_pos).value,                   -- PO_LINE_ID
                        l_shipment_tbl(nShip_Line_Location_ID_pos).value, -- LINE_LOCATION_ID
			c_file_common_key);  --2823215
              --    END IF;  --Bug 1891291




               END LOOP; -- SHIPMENT Level Loop

               xProgress := 'POOB-10-1740';
               IF dbms_sql.last_row_count = 0 THEN
                  v_LevelProcessed := 'SHIPMENT';
                  ec_debug.pl(0,
                             'EC',
                             'ECE_NO_DB_ROW_PROCESSED',
                             'PROGRESS_LEVEL',
                              xProgress,
                             'LEVEL_PROCESSED',
                              v_LevelProcessed,
                             'TRANSACTION_TYPE',
                              cTransaction_Type);
               END IF;

            END LOOP;    -- LINE Level Loop

            xProgress := 'POOB-10-1750';
            IF(dbms_sql.last_row_count = 0) THEN
               v_LevelProcessed := 'LINE';
               ec_debug.pl(0,
                          'EC',
                          'ECE_NO_DB_ROW_PROCESSED',
                          'PROGRESS_LEVEL',
                           xProgress,
                          'LEVEL_PROCESSED',
                           v_LevelProcessed,
                          'TRANSACTION_TYPE',
                           cTransaction_Type);
            END IF;

	    xHeaderCount := xHeaderCount + 1;

         END LOOP;       -- HEADER Level Loop

         xProgress := 'POOB-10-1760';
         IF(dbms_sql.last_row_count = 0) THEN
            v_LevelProcessed := 'HEADER';
            ec_debug.pl(0,
                       'EC',
                       'ECE_NO_DB_ROW_PROCESSED',
                       'LEVEL_PROCESSED',
                        v_LevelProcessed,
                       'PROGRESS_LEVEL',
                        xProgress,
                       'TRANSACTION_TYPE',
                        cTransaction_Type);
         END IF;

         xProgress := 'POOB-10-1770';
         if (ece_poo_transaction.project_sel_c>0) then           --Bug 2819176
         dbms_sql.close_cursor(ece_poo_transaction.project_sel_c);	--Bug 2490109
         end if;
         xProgress := 'POOB-10-1780';
         dbms_sql.close_cursor(shipment_sel_c);

         xProgress := 'POOB-10-1790';
         dbms_sql.close_cursor(line_sel_c);

         xProgress := 'POOB-10-1800';
         dbms_sql.close_cursor(header_sel_c);
         ec_debug.pop('ECE_POO_TRANSACTION.POPULATE_POO_TRX');

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END populate_poo_trx;

   PROCEDURE put_data_to_output_table(cCommunication_Method   IN VARCHAR2,
                                      cTransaction_Type       IN VARCHAR2,
                                      iOutput_width           IN INTEGER,
                                      iRun_id                 IN INTEGER,
                                      cHeader_Interface       IN VARCHAR2,
                                      cLine_Interface         IN VARCHAR2,
                                      cShipment_Interface     IN VARCHAR2,
                                      cDistribution_Interface      IN VARCHAR2) IS

      xProgress                  VARCHAR2(80);
      v_LevelProcessed           VARCHAR2(40);

      cAtt_Header_Interface      VARCHAR2(120) := 'ECE_ATTACHMENT_HEADERS';
      cAtt_Detail_Interface      VARCHAR2(120) := 'ECE_ATTACHMENT_DETAILS';

      l_header_tbl               ece_flatfile_pvt.Interface_tbl_type;
      l_line_tbl                 ece_flatfile_pvt.Interface_tbl_type;
      l_shipment_tbl             ece_flatfile_pvt.Interface_tbl_type;

      l_document_type            VARCHAR2(30);

      c_header_common_key_name   VARCHAR2(40);
      c_line_common_key_name     VARCHAR2(40);
      c_shipment_key_name        VARCHAR2(40);
      c_file_common_key          VARCHAR2(255);

      nHeader_key_pos            NUMBER;
      nLine_key_pos              NUMBER;
      nShipment_key_pos          NUMBER;
      nTrans_code_pos            NUMBER;

      Header_sel_c               INTEGER;
      line_sel_c                 INTEGER;
      Shipment_sel_c             INTEGER;

      Header_del_c1              INTEGER;
      Line_del_c1                INTEGER;
      Shipment_del_c1            INTEGER;

      Header_del_c2              INTEGER;
      Line_del_c2                INTEGER;
      Shipment_del_c2            INTEGER;

      cHeader_select             VARCHAR2(32000);
      cLine_select               VARCHAR2(32000);
      cShipment_select           VARCHAR2(32000);

      cHeader_from               VARCHAR2(32000);
      cLine_from                 VARCHAR2(32000);
      cShipment_from             VARCHAR2(32000);

      cHeader_where              VARCHAR2(32000);
      cLine_where                VARCHAR2(32000);
      cShipment_where            VARCHAR2(32000);

      cHeader_delete1            VARCHAR2(32000);
      cLine_delete1              VARCHAR2(32000);
      cShipment_delete1          VARCHAR2(32000);

      cHeader_delete2            VARCHAR2(32000);
      cLine_delete2              VARCHAR2(32000);
      cShipment_delete2          VARCHAR2(32000);

      iHeader_count              NUMBER;
      iLine_count                NUMBER;
      iShipment_count            NUMBER;

      rHeader_rowid              ROWID;
      rLine_rowid                ROWID;
      rShipment_rowid            ROWID;

      cHeader_X_Interface        VARCHAR2(50);
      cLine_X_Interface          VARCHAR2(50);
      cShipment_X_Interface      VARCHAR2(50);

      rHeader_X_rowid            ROWID;
      rLine_X_rowid              ROWID;
      rShipment_X_rowid          ROWID;

      iHeader_start_num          INTEGER;
      iLine_start_num            INTEGER;
      iShipment_start_num        INTEGER;
      dummy                      INTEGER;

      nDocument_type_pos         NUMBER;
      nPos1                      NUMBER;
      nTrans_id                  NUMBER;
      n_po_header_ID             NUMBER;
      nRelease_ID                NUMBER;
      nRelease_ID_pos            NUMBER;
      n_po_line_ID               NUMBER;
      nPO_Line_Location_ID_pos   NUMBER;
      nPO_Line_Location_ID       NUMBER;
      nLine_Location_ID_pos      NUMBER;
      nLine_Location_ID          NUMBER;
      nLine_num_pos              NUMBER;
      nLine_num                  NUMBER;
      nRelease_num               NUMBER;
      nRelease_num_pos           NUMBER;
      nOrganization_ID           NUMBER;
      nItem_ID_pos               NUMBER;
      nItem_ID                   NUMBER;

      v_project_acct_installed   BOOLEAN;
      v_project_acct_short_name  VARCHAR2(2) := 'PA';
      v_project_acct_status      VARCHAR2(120);
      v_project_acct_industry    VARCHAR2(120);
      v_project_acct_schema      VARCHAR2(120);

      v_entity_name              VARCHAR2(120);
      v_pk1_value                VARCHAR2(120);
      v_pk2_value                VARCHAR2(120);

      CURSOR c_org_id(p_line_id  NUMBER) IS
         SELECT   DISTINCT ship_to_organization_id
         FROM     po_line_locations
         WHERE    po_line_id = p_line_id;

      BEGIN
         if ec_debug.G_debug_level = 3 then
          ec_debug.push('ECE_POO_TRANSACTION.PUT_DATA_TO_OUTPUT_TABLE');
          ec_debug.pl(3,'cCommunication_Method: ',cCommunication_Method);
          ec_debug.pl(3,'cTransaction_Type: '    ,cTransaction_Type);
          ec_debug.pl(3,'iOutput_width: '        ,iOutput_width);
          ec_debug.pl(3,'iRun_id: '              ,iRun_id);
          ec_debug.pl(3,'cHeader_Interface: '    ,cHeader_Interface);
          ec_debug.pl(3,'cLine_Interface: '      ,cLine_Interface);
          ec_debug.pl(3,'cShipment_Interface: '  ,cShipment_Interface);
         end if;

         BEGIN
            SELECT inventory_organization_id
            INTO   norganization_id
            FROM   financials_system_parameters;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(0,
                          'EC',
                          'ECE_NO_ROW_SELECTED',
                          'PROGRESS_LEVEL',
                           xProgress,
                          'INFO',
                          'INVENTORY ORGANIZATION ID',
                          'TABLE_NAME',
                          'FINANCIALS_SYSTEM_PARAMETERS');
         END;
        if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'norganization_id: ',norganization_id);
        end if;

         -- Let's See if Project Accounting is Installed
        /* xProgress := 'POOB-20-1000';
         v_project_acct_installed := fnd_installation.get_app_info(
                                       v_project_acct_short_name, -- i.e. 'PA'
                                       v_project_acct_status,     -- 'I' means it's installed
                                       v_project_acct_industry,
                                       v_project_acct_schema);

         v_project_acct_status := NVL(v_project_acct_status,'X');
         ec_debug.pl(3,'v_project_acct_status: '  ,v_project_acct_status);
         ec_debug.pl(3,'v_project_acct_industry: ',v_project_acct_industry);
         ec_debug.pl(3,'v_project_acct_schema: '  ,v_project_acct_schema);
*/
         xProgress := 'POOB-20-1005';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cHeader_Interface,
                                        cHeader_X_Interface,
                                        l_header_tbl,
                                        c_header_common_key_name,
                                        cHeader_select,
                                        cHeader_from,
                                        cHeader_where);

         xProgress := 'POOB-20-1010';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cLine_Interface,
                                        cLine_X_Interface,
                                        l_line_tbl,
                                        c_line_common_key_name,
                                        cLine_select,
                                        cLine_from,
                                        cLine_where);

         xProgress := 'POOB-20-1020';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cShipment_Interface,
                                        cShipment_X_Interface,
                                        l_shipment_tbl,
                                        c_shipment_key_name,
                                        cShipment_select,
                                        cShipment_from,
                                        cShipment_where);

         -- Header Level Find Positions
         xProgress := 'POOB-20-1021';
         ece_flatfile_pvt.find_pos(l_header_tbl,ece_flatfile_pvt.G_Translator_Code,nTrans_code_pos);

         xProgress := 'POOB-20-1022';
         ece_flatfile_pvt.find_pos(l_header_tbl,c_header_common_key_name,nHeader_key_pos);


         xProgress := 'POOB-20-1023';
         ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_NUMBER',nRelease_num_pos);

         xProgress := 'POOB-20-1024';
         ece_flatfile_pvt.find_pos(l_header_tbl,'PO_RELEASE_ID',nRelease_ID_pos);

         xProgress := 'POOB-20-1025';
         ece_flatfile_pvt.find_pos(l_header_tbl,'DOCUMENT_TYPE',nDocument_type_pos);

         -- Line Level Find Positions
         xProgress := 'POOB-20-1026';
         ece_flatfile_pvt.find_pos(l_line_tbl,c_line_common_key_name,nLine_key_pos);

         xProgress := 'POOB-20-1027';
         ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_NUMBER',nLine_num_pos);

         xProgress := 'POOB-20-1028';
         ece_flatfile_pvt.find_pos(l_line_tbl,'PO_LINE_LOCATION_ID',nPO_Line_Location_ID_pos);

         xProgress := 'POOB-20-1029';
         ece_flatfile_pvt.find_pos(l_line_tbl,'ITEM_ID',nItem_ID_pos);

         -- Shipment Level Find Positions
         xProgress := 'POOB-20-1030';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'LINE_LOCATION_ID',nLine_Location_ID_pos);

         xProgress := 'POOB-20-1032';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,c_shipment_key_name,nShipment_key_pos);
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'nTrans_code_pos: ',nTrans_code_pos);
          ec_debug.pl(3,'nHeader_key_pos: ',nHeader_key_pos);
          ec_debug.pl(3,'nRelease_num_pos: ',nRelease_num_pos);
          ec_debug.pl(3,'nRelease_ID_pos: ',nRelease_ID_pos);
          ec_debug.pl(3,'nDocument_type_pos: ',nDocument_type_pos);
          ec_debug.pl(3,'nLine_key_pos: ',nLine_key_pos);
          ec_debug.pl(3,'nLine_num_pos: ',nLine_num_pos);
          ec_debug.pl(3,'nPO_Line_Location_ID_pos: ',nPO_Line_Location_ID_pos);
          ec_debug.pl(3,'nItem_ID_pos: ',nItem_ID_pos);
          ec_debug.pl(3,'nLine_Location_ID_pos: ',nLine_Location_ID_pos);
          ec_debug.pl(3,'nShipment_key_pos: ',nShipment_key_pos);
         end if;
         -- Build SELECT Statement
         xProgress := 'POOB-20-1035';
         cHeader_where     := cHeader_where                               ||
                              ' AND '                                     ||
                              cHeader_Interface                           ||
                              '.run_id = '                                ||
                              ':Run_id';

         cLine_where       := cLine_where                                 ||
                              ' AND '                                     ||
                              cLine_Interface                             ||
                              '.run_id = '                                ||
                              ':Run_id'                                     ||
                              ' AND '                                     ||
                              cLine_Interface                             ||
                              '.po_header_id = :po_header_id AND '        ||
                              cLine_Interface                             ||
                              '.release_number = :por_release_num';

         cShipment_where   := cShipment_where                             ||
                              ' AND '                                     ||
                              cShipment_Interface                         ||
                              '.run_id ='                                 ||
                              ':Run_id'                                     ||
                              ' AND '                                     ||
                              cShipment_Interface                         ||
                              '.po_header_id = :po_header_id AND '        ||
                              cShipment_Interface                         ||
                              '.po_line_id = :po_line_id AND '            ||
                              cShipment_Interface                         ||
                              '.release_number = :por_release_num AND ((' ||
                              cShipment_Interface                         ||
                              '.release_number = 0) OR ('                 ||
                              cShipment_Interface                         ||
                              '.release_number <> 0 AND '                 ||
                              cShipment_Interface                         ||
                              '.shipment_number = :shipment_number))';

         xProgress := 'POOB-20-1040';
         cHeader_select    := cHeader_select                              ||
                              ','                                         ||
                              cHeader_Interface                           ||
                              '.rowid,'                                   ||
                              cHeader_X_Interface                         ||
                              '.rowid,'                                   ||
                              cHeader_Interface                           ||
                              '.po_header_id,'                            ||
                              cHeader_Interface                           ||
                              '.release_number ';

         cLine_select      := cLine_select                                ||
                              ','                                         ||
                              cLine_Interface                             ||
                              '.rowid,'                                   ||
                              cLine_X_Interface                           ||
                              '.rowid,'                                   ||
                              cLine_Interface                             ||
                              '.po_line_id,'                              ||
                              cLine_Interface                             ||
                              '.line_number ';

         cShipment_select  := cShipment_select                            ||
                              ','                                         ||
                              cShipment_Interface                         ||
                              '.rowid,'                                   ||
                              cShipment_X_Interface                       ||
                              '.rowid,'                                   ||
                              cShipment_Interface                         ||
                              '.shipment_number ';

         xProgress := 'POOB-20-1050';
         cHeader_select    := cHeader_select                              ||
                              cHeader_from                                ||
                              cHeader_where                               ||
                              ' ORDER BY '                                ||
                              cHeader_Interface                           ||
                              '.po_header_id,'                            ||
                              cHeader_Interface                           ||
                              '.release_number '                          ||
                              ' FOR UPDATE';
         ec_debug.pl(3,'cHeader_select: ',cHeader_select);

         cLine_select      := cLine_select                                ||
                              cLine_from                                  ||
                              cLine_where                                 ||
                              ' ORDER BY '                                ||
                              cLine_Interface                             ||
                              '.line_number '                             ||
                              ' FOR UPDATE';
         ec_debug.pl(3, 'cLine_select: ',cLine_select);

         cShipment_select  := cShipment_select                            ||
                              cShipment_from                              ||
                              cShipment_where                             ||
                              ' ORDER BY '                                ||
                              cShipment_Interface                         ||
                              '.shipment_number '                         ||
                              ' FOR UPDATE';
         ec_debug.pl(3, 'cShipment_select: ',cShipment_select);

         xProgress := 'POOB-20-1060';
         cHeader_delete1   := 'DELETE FROM ' || cHeader_Interface     || ' WHERE rowid = :col_rowid';

         cLine_delete1     := 'DELETE FROM ' || cLine_Interface       || ' WHERE rowid = :col_rowid';

         cShipment_delete1 := 'DELETE FROM ' || cShipment_Interface   || ' WHERE rowid = :col_rowid';

         xProgress := 'POOB-20-1070';
         cHeader_delete2   := 'DELETE FROM ' || cHeader_X_Interface   || ' WHERE rowid = :col_rowid';

         cLine_delete2     := 'DELETE FROM ' || cLine_X_Interface     || ' WHERE rowid = :col_rowid';

         cShipment_delete2 := 'DELETE FROM ' || cShipment_X_Interface || ' WHERE rowid = :col_rowid';
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'cHeader_delete1: ',cHeader_delete1);
          ec_debug.pl(3,'cLine_delete1: ',cLine_delete1);
          ec_debug.pl(3,'cShipment_delete1: ',cShipment_delete1);
          ec_debug.pl(3,'cHeader_delete2: ',cHeader_delete2);
          ec_debug.pl(3,'cLine_delete2: ',cLine_delete2);
          ec_debug.pl(3,'cShipment_delete2: ',cShipment_delete2);
         end if;

         -- ***************************************************
         -- ***   Get data setup for the dynamic SQL call.
         -- ***   Open a cursor for each of the SELECT call
         -- ***   This tells the database to reserve spaces
         -- ***   for the data returned by the SQL statement
         -- ***************************************************
         xProgress       := 'POOB-20-1080';
         Header_sel_c    := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1090';
         line_sel_c      := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1100';
         Shipment_sel_c  := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1110';
         Header_del_c1   := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1120';
         Line_del_c1     := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1130';
         Shipment_del_c1 := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1140';
         Header_del_c2   := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1150';
         Line_del_c2     := dbms_sql.open_cursor;

         xProgress       := 'POOB-20-1160';
         Shipment_del_c2 := dbms_sql.open_cursor;

         -- *****************************************
         -- Parse each of the SELECT statement
         -- so the database understands the command
         -- *****************************************
         xProgress := 'POOB-20-1170';
         BEGIN
            dbms_sql.parse(Header_sel_c,cHeader_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1180';
         BEGIN
            dbms_sql.parse(line_sel_c,cLine_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1190';
         BEGIN
            dbms_sql.parse(shipment_sel_c,cShipment_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cShipment_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1200';
         BEGIN
            dbms_sql.parse(header_del_c1,cHeader_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1210';
         BEGIN
            dbms_sql.parse(line_del_c1,cLine_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1220';
         BEGIN
            dbms_sql.parse(shipment_del_c1,cShipment_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cShipment_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1230';
         BEGIN
            dbms_sql.parse(header_del_c2,cHeader_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_delete2);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1240';
         BEGIN
            dbms_sql.parse(line_del_c2,cLine_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_delete2);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-20-1250';
         BEGIN
            dbms_sql.parse(shipment_del_c2,cShipment_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cShipment_delete2);
               app_exception.raise_exception;

         END;

         -- *************
         -- set counter
         -- *************
         xProgress       := 'POOB-20-1260';
         iHeader_count   := l_header_tbl.COUNT;
         iLine_count     := l_line_tbl.COUNT;
         iShipment_count := l_shipment_tbl.COUNT;

         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'iHeader_count: '  ,iHeader_count);
          ec_debug.pl(3,'iLine_count: '    ,iLine_count);
          ec_debug.pl(3,'iShipment_count: ',iShipment_count);
         end if;

         -- ******************************************************
         --  Define TYPE for every columns in the SELECT statement
         --  For each piece of the data returns, we need to tell
         --  the database what type of information it will be.
         --  e.g. ID is NUMBER, due_date is DATE
         --  However, for simplicity, we will convert
         --  everything to varchar2.
         -- ******************************************************
         xProgress := 'POOB-20-1270';
         ece_flatfile_pvt.define_interface_column_type(Header_sel_c,
                                                       cHeader_select,
                                                       ece_flatfile_pvt.G_MaxColWidth,
                                                       l_header_tbl);

         -- ***************************************************
         -- Need rowid for delete (Header Level)
         -- ***************************************************
         xProgress := 'POOB-20-1280';
         dbms_sql.define_column_rowid(Header_sel_c,iHeader_count + 1,rHeader_rowid);

         xProgress := 'POOB-20-1290';
         dbms_sql.define_column_rowid(Header_sel_c,iHeader_count + 2,rHeader_X_rowid);

         xProgress := 'POOB-20-1300';
         dbms_sql.define_column(Header_sel_c,iHeader_count + 3,n_po_header_ID);

         xProgress := 'POOB-20-1310';
         ece_flatfile_pvt.define_interface_column_type(line_sel_c,cLine_select,ece_flatfile_pvt.G_MaxColWidth,l_line_tbl);

         -- ***************************************************
         -- Need rowid for delete (Line Level)
         -- ***************************************************
         xProgress := 'POOB-20-1320';
         dbms_sql.define_column_rowid(line_sel_c,iLine_count + 1,rLine_rowid);

         xProgress := 'POOB-20-1330';
         dbms_sql.define_column_rowid(line_sel_c,iLine_count + 2,rLine_X_rowid);

         xProgress := 'POOB-20-1340';
         dbms_sql.define_column(line_sel_c,iLine_count + 3,n_po_line_ID);

         xProgress := 'POOB-20-1350';
         ece_flatfile_pvt.define_interface_column_type(Shipment_sel_c,cShipment_select,ece_flatfile_pvt.G_MaxColWidth,l_shipment_tbl);

         -- ***************************************************
         -- Need rowid for delete (Shipment Level)
         -- ***************************************************
         xProgress := 'POOB-20-1360';
         dbms_sql.define_column_rowid(Shipment_sel_c,iShipment_count + 1,rShipment_rowid);

         xProgress := 'POOB-20-1370';
         dbms_sql.define_column_rowid(Shipment_sel_c,iShipment_count + 2,rShipment_X_rowid);

         -- ************************************************************
         -- ***  The following is custom tailored for this transaction
         -- ***  It find the values and use them in the WHERE clause to
         -- ***  join tables together.
         -- ************************************************************
         -- *******************************************
         -- To complete the Line SELECT statement,
         -- we will need values for the join condition.
         -- *******************************************
         xProgress := 'POOB-20-1375';
         dbms_sql.bind_variable(Header_sel_c,'Run_id',iRun_id);
         dbms_sql.bind_variable(line_sel_c,'Run_id',iRun_id);
         dbms_sql.bind_variable(shipment_sel_c,'Run_id',iRun_id);

         --- EXECUTE the SELECT statement
         xProgress := 'POOB-20-1380';
         dummy := dbms_sql.execute(Header_sel_c);

         -- ********************************************************************
         -- ***   With data for each HEADER line, populate the ECE_OUTPUT table
         -- ***   then populate ECE_OUTPUT with data from all LINES that belongs
         -- ***   to the HEADER. Then populate ECE_OUTPUT with data from all
         -- ***   LINE TAX that belongs to the LINE.
         -- ********************************************************************

         -- HEADER - LINE - SHIPMENT ...
         xProgress := 'POOB-20-1390';
         WHILE dbms_sql.fetch_rows(Header_sel_c) > 0 LOOP           -- Header
            -- ******************************
            --   store values in pl/sql table
            -- ******************************
            xProgress := 'POOB-20-1400';
            ece_flatfile_pvt.assign_column_value_to_tbl(header_sel_c,l_header_tbl);

            xProgress := 'POOB-20-1410';
            dbms_sql.column_value(header_sel_c,iHeader_count + 1,rHeader_rowid);

            xProgress := 'POOB-20-1420';
            dbms_sql.column_value(header_sel_c,iHeader_count + 2,rHeader_X_rowid);

            xProgress := 'POOB-20-1430';
            dbms_sql.column_value(header_sel_c,iHeader_count + 3,n_po_header_id);

            xProgress := 'POOB-20-1440';
            nRelease_num := l_header_tbl(nRelease_num_pos).value;

            xProgress := 'POOB-20-1450';
            nRelease_ID := l_header_tbl(nRelease_id_pos).value;
           if ec_debug.G_debug_level = 3 then
            ec_debug.pl(3,'nRelease_num: ',nRelease_num);
            ec_debug.pl(3,'nRelease_ID: ',nRelease_ID);
           end if;

            BEGIN
               xProgress := 'POOB-20-1455';
		/* Bug 2396394 Added the document type CONTRACT in SQL below */

               SELECT   DECODE(l_header_tbl(nDocument_type_pos).value,
                              'BLANKET'         ,'NB',
                              'STANDARD'        ,'NS',
                              'PLANNED'         ,'NP',
                              'RELEASE'         ,'NR',
                              'BLANKET RELEASE' ,'NR',
                              'CONTRACT'        ,'NC',
                              'NR')
               INTO     l_document_type
               FROM     DUAL;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,
                             'EC',
                             'ECE_DECODE_FAILED',
                             'PROGRESS_LEVEL',
                              xProgress,
                             'CODE',
                              l_header_tbl(nDocument_type_pos).value);
            END;
            ec_debug.pl(3,'l_document_type: ',l_document_type);

            xProgress         := 'POOB-20-1460';
            c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),1,25),25);

            xProgress         := 'POOB-20-1470';
            c_file_common_key := c_file_common_key ||
                                 RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),1,22),22) || RPAD(' ',22) || RPAD(' ',22);

            ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);

            xProgress := 'POOB-20-1480';
            ece_poo_transaction.write_to_file(cTransaction_Type,
                                              cCommunication_Method,
                                              cHeader_Interface,
                                              l_header_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              c_file_common_key,
                                              null);

            IF l_document_type = 'NR' THEN -- If this is a Release PO.
               xProgress := 'POOB-20-1481';
               v_entity_name := 'PO_RELEASES';
               v_pk1_value := nRelease_ID;
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'release_id: ',nRelease_ID);
              end if;
            ELSE -- If this is a non-Release PO.
               xProgress := 'POOB-20-1482';
               v_entity_name := 'PO_HEADERS';
               v_pk1_value := n_po_header_id;
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'po_header_id: ',n_po_header_id);
              end if;
            END IF;

            xProgress := 'POOB-20-1483';
            put_att_to_output_table(cCommunication_Method,
                                    cTransaction_Type,
                                    iOutput_width,
                                    iRun_id,
                                    2,
                                    3,
                                    cAtt_Header_Interface,
                                    cAtt_Detail_Interface,
                                    v_entity_name,
                                    'VENDOR',
                                    v_pk1_value,
                                    NULL,
                                    NULL,
                                    NULL,
                                    NULL,
                                    c_file_common_key);

            -- ***************************************************
            -- With Header data at hand, we can assign values to
            -- place holders (foreign keys) in Line_select and
            -- Line_detail_Select
            -- ***************************************************
            -- ******************************************
            -- set values into binding variables
            -- ******************************************
            xProgress := 'POOB-20-1490';
            dbms_sql.bind_variable(line_sel_c,'po_header_id',n_po_header_ID);

            xProgress := 'POOB-20-1500';
            dbms_sql.bind_variable(shipment_sel_c,'po_header_id',n_po_header_ID);

            xProgress := 'POOB-20-1505';
            dbms_sql.bind_variable(line_sel_c,'por_release_num',nRelease_num);

            xProgress := 'POOB-20-1506';
            dbms_sql.bind_variable(shipment_sel_c,'por_release_num',nRelease_num);

            xProgress := 'POOB-20-1510';
            dummy := dbms_sql.execute(line_sel_c);

            -- ***************************************************
            -- line loop starts here
            -- ***************************************************
            xProgress := 'POOB-20-1520';
            WHILE dbms_sql.fetch_rows(line_sel_c) > 0 LOOP     --- Line

               -- ***************************************************
               --   store values in pl/sql table
               -- ***************************************************
               xProgress := 'POOB-20-1530';
               ece_flatfile_pvt.assign_column_value_to_tbl(line_sel_c,l_line_tbl);

               xProgress := 'POOB-20-1533';
               dbms_sql.column_value(line_sel_c,iLine_count + 1,rLine_rowid);

               xProgress := 'POOB-20-1535';
               dbms_sql.column_value(line_sel_c,iLine_count + 2,rLine_X_rowid);

               xProgress := 'POOB-20-1537';
               dbms_sql.column_value(line_sel_c,iLine_count + 3,n_po_line_id);

               xProgress := 'POOB-20-1540';
               nLine_num := l_line_tbl(nLine_num_pos).value;

               xProgress := 'POOB-20-1544';
               nPO_Line_Location_ID := l_line_tbl(nPO_Line_Location_ID_pos).value;

               xProgress := 'POOB-20-1545';
               nItem_ID := l_line_tbl(nItem_id_pos).value;
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'n_po_line_id: ',n_po_line_id);
               ec_debug.pl(3,'nLine_num: ',nLine_num);
               ec_debug.pl(3,'nPO_Line_Location_ID: ',nPO_Line_Location_ID);
               ec_debug.pl(3,'nItem_ID: ',nItem_ID);
              end if;

               xProgress := 'POOB-20-1550';
               c_file_common_key := RPAD(SUBSTRB(NVL
                                                (l_header_tbl(nTrans_code_pos).value,' '),
                                                 1,
                                                 25),25) ||
                                          RPAD(SUBSTRB(NVL
                                                (l_header_tbl(nHeader_key_pos).value,' '),
                                                 1,
                                                 22),22) ||
                                          RPAD(SUBSTRB(NVL
                                                (l_line_tbl(nLine_key_pos).value,' '),
                                                 1,
                                                 22),22) ||
                                          RPAD(' ',22);
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'c_file_common_key: ',c_file_common_key);
              end if;

               xProgress := 'POOB-20-1551';
               ece_poo_transaction.write_to_file(cTransaction_Type,
                                                 cCommunication_Method,
                                                 cLine_Interface,
                                                 l_line_tbl,
                                                 iOutput_width,
                                                 iRun_id,
                                                 c_file_common_key,
                                                 null);

               -- Line Level Attachment Handler
             /*  IF l_document_type = 'NR' THEN -- If this is a Release PO.
                  xProgress := 'POOB-20-1552';
                  v_entity_name := 'PO_SHIPMENTS';
                  v_pk1_value := nPO_Line_Location_ID; -- LINE_LOCATION_ID
               ELSE -- If this is a non-Release PO.
               END IF;
               Bug 2187958
             */
               xProgress := 'POOB-20-1553';
               v_entity_name := 'PO_LINES';
               v_pk1_value := n_po_line_id; -- LINE_ID

               xProgress := 'POOB-20-1554';
               put_att_to_output_table(cCommunication_Method,
                                       cTransaction_Type,
                                       iOutput_width,
                                       iRun_id,
                                       5,
                                       6,
                                       cAtt_Header_Interface,
                                       cAtt_Detail_Interface,
                                       v_entity_name,
                                       'VENDOR',
                                       v_pk1_value,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL,
                                       c_file_common_key);

               -- Master Item Attachment Handler
               xProgress := 'POOB-20-1555';
               v_entity_name := 'MTL_SYSTEM_ITEMS';
               v_pk1_value := nOrganization_ID; -- Master Inventory Org ID

               v_pk2_value := nItem_ID;         -- Item ID
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'Master Org ID: ',v_pk1_value);
               ec_debug.pl(3,'Item ID: ',v_pk2_value);
              end if;

               xProgress := 'POOB-20-1556';
               put_att_to_output_table(cCommunication_Method,
                                       cTransaction_Type,
                                       iOutput_width,
                                       iRun_id,
                                       7,
                                       8,
                                       cAtt_Header_Interface,
                                       cAtt_Detail_Interface,
                                       v_entity_name,
                                       'VENDOR',
                                       v_pk1_value,
                                       v_pk2_value,
                                       NULL,
                                       NULL,
                                       NULL,
                                       c_file_common_key);

	       /* Bug 3550723
               -- Inventory Item Attachment Handler
               xProgress := 'POOB-20-1557';
               FOR v_org_id IN c_org_id(n_po_line_id) LOOP -- Value passed is the Line ID
                  IF v_org_id.ship_to_organization_id <> nOrganization_ID THEN -- Only do this if it is not the same as the Master Org ID
                     v_pk1_value := v_org_id.ship_to_organization_id;

                    if ec_debug.G_debug_level = 3 then
                     ec_debug.pl(3,'Inventory Org ID: ',v_pk1_value);
                    end if;

                     xProgress := 'POOB-20-1558';
                     put_att_to_output_table(cCommunication_Method,
                                             cTransaction_Type,
                                             iOutput_width,
                                             iRun_id,
                                             9,
                                             10,
                                             cAtt_Header_Interface,
                                             cAtt_Detail_Interface,
                                             v_entity_name,
                                             'VENDOR',
                                             v_pk1_value,
                                             v_pk2_value,
                                             NULL,
                                             NULL,
                                             NULL,
                                             c_file_common_key);
                  END IF;
               END LOOP;
	       */

               -- **************************
               --   set LINE_NUMBER values
               -- **************************
               xProgress := 'POOB-20-1560';
               dbms_sql.bind_variable(shipment_sel_c,'po_line_id',n_po_line_ID);

               xProgress := 'POOB-20-1575';
               dbms_sql.bind_variable(shipment_sel_c,'shipment_number',nLine_num);

               xProgress := 'POOB-20-1580';
               dummy := dbms_sql.execute(shipment_sel_c);

               -- ****************************
               --  Shipment loop starts here
               -- ****************************
               xProgress := 'POCOB-10-1590';
               WHILE dbms_sql.fetch_rows(shipment_sel_c) > 0 LOOP    --- Shipments

                  -- *********************************
                  --  store values in pl/sql table
                  -- *********************************
                  xProgress := 'POCOB-10-1600';
                  ece_flatfile_pvt.assign_column_value_to_tbl(Shipment_sel_c,l_shipment_tbl);

                  xProgress := 'POCOB-10-1603';
                  dbms_sql.column_value(shipment_sel_c,iShipment_count + 1,rShipment_rowid);

                  xProgress := 'POCOB-10-1606';
                  dbms_sql.column_value(shipment_sel_c,iShipment_count + 2,rShipment_X_rowid);

                  xProgress := 'POCOB-10-1610';
                  nLine_Location_ID := l_shipment_tbl(nLine_Location_ID_pos).value;
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'Ship Level Line Location ID: ',nLine_Location_ID);
                  end if;

                  xProgress := 'POCOB-10-1620';
                  c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value    ,' '),1,25),25) ||
                                       RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value    ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_line_tbl(nLine_key_pos).value        ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_shipment_tbl(nShipment_key_pos).value,' '),1,22),22);
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);
                  end if;

                  xProgress := 'POOB-20-1630';
                  ece_poo_transaction.write_to_file(cTransaction_Type,
                                                    cCommunication_Method,
                                                    cShipment_Interface,
                                                    l_shipment_tbl,
                                                    iOutput_width,
                                                    iRun_id,
                                                    c_file_common_key,
                                                    null);

                  -- Shipment Level Attachment Handler
                  v_entity_name := 'PO_SHIPMENTS';
                  v_pk1_value := nLine_Location_ID;

                  xProgress := 'POOB-20-1632';
                  put_att_to_output_table(cCommunication_Method,
                                          cTransaction_Type,
                                          iOutput_width,
                                          iRun_id,
                                          12,
                                          13,
                                          cAtt_Header_Interface,
                                          cAtt_Detail_Interface,
                                          v_entity_name,
                                          'VENDOR',
                                          v_pk1_value,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          c_file_common_key);

                  -- Project Level Handler
                  xProgress := 'POOB-20-1634';
              --    IF v_project_acct_status = 'I' THEN -- Project Accounting is Installed --bug1891291
                     ece_poo_transaction.PUT_DISTDATA_TO_OUT_TBL(
                        cCommunication_Method,
                        cTransaction_Type,
                        iOutput_width,
                        iRun_id,
                        cDistribution_Interface,
                        n_po_header_ID,      -- PO_HEADER_ID
                        nRelease_ID,         -- PO_RELEASE_ID
                        n_po_line_ID,        -- PO_LINE_ID
                        nLine_Location_ID,   -- LINE_LOCATION_ID
                        c_file_common_key);
               --   END IF;  --bug 1891291

                  xProgress := 'POOB-20-1640';
                  dbms_sql.bind_variable(shipment_del_c1,'col_rowid',rShipment_rowid);

                  xProgress := 'POOB-20-1650';
                  dbms_sql.bind_variable(shipment_del_c2,'col_rowid',rShipment_X_rowid);

                  xProgress := 'POOB-20-1660';
                  dummy := dbms_sql.execute(shipment_del_c1);

                  xProgress := 'POOB-20-1670';
                  dummy := dbms_sql.execute(shipment_del_c2);

               END LOOP; -- Shipment Level

               xProgress := 'POOB-20-1674';
               IF dbms_sql.last_row_count = 0 THEN
                  v_LevelProcessed := 'SHIPMENT';
                  ec_debug.pl(0,
                              'EC',
                              'ECE_NO_DB_ROW_PROCESSED',
                              'PROGRESS_LEVEL',
                              xProgress,
                              'LEVEL_PROCESSED',
                              v_LevelProcessed,
                              'TRANSACTION_TYPE',
                              cTransaction_Type);
               END IF;

               -- *********************
               -- Use rowid for delete
               -- *********************
               xProgress := 'POOB-20-1680';
               dbms_sql.bind_variable(line_del_c1,'col_rowid',rLine_rowid);

               xProgress := 'POOB-20-1690';
               dbms_sql.bind_variable(line_del_c2,'col_rowid',rLine_X_rowid);

               xProgress := 'POOB-20-1700';
               dummy := dbms_sql.execute(line_del_c1);

               xProgress := 'POOB-20-1710';
               dummy := dbms_sql.execute(line_del_c2);

            END LOOP; -- Line Level

            xProgress := 'POOB-20-1714';
            IF dbms_sql.last_row_count = 0 THEN
               v_LevelProcessed := 'LINE';
               ec_debug.pl(0,
                           'EC',
                           'ECE_NO_DB_ROW_PROCESSED',
                           'PROGRESS_LEVEL',
                           xProgress,
                           'LEVEL_PROCESSED',
                           v_LevelProcessed,
                           'TRANSACTION_TYPE',
                           cTransaction_Type);
            END IF;

            xProgress := 'POOB-20-1720';
            dbms_sql.bind_variable(header_del_c1,'col_rowid',rHeader_rowid);

            xProgress := 'POOB-20-1730';
            dbms_sql.bind_variable(header_del_c2,'col_rowid',rHeader_X_rowid);

            xProgress := 'POOB-20-1740';
            dummy := dbms_sql.execute(header_del_c1);

            xProgress := 'POOB-20-1750';
            dummy := dbms_sql.execute(header_del_c2);

         END LOOP; -- Header Level

         xProgress := 'POOB-20-1754';
         IF dbms_sql.last_row_count = 0 THEN
            v_LevelProcessed := 'HEADER';
            ec_debug.pl(0,
                        'EC',
                        'ECE_NO_DB_ROW_PROCESSED',
                        'PROGRESS_LEVEL',
                        xProgress,
                        'LEVEL_PROCESSED',
                        v_LevelProcessed,
                        'TRANSACTION_TYPE',
                        cTransaction_Type);
         END IF;

         xProgress := 'POOB-20-1760';
         dbms_sql.close_cursor(header_sel_c);

         xProgress := 'POOB-20-1770';
         dbms_sql.close_cursor(line_sel_c);

         xProgress := 'POOB-20-1780';
         dbms_sql.close_cursor(shipment_sel_c);

         xProgress := 'POOB-20-1790';
         dbms_sql.close_cursor(header_del_c1);

         xProgress := 'POOB-20-1800';
         dbms_sql.close_cursor(line_del_c1);

         xProgress := 'POOB-20-1812';
         dbms_sql.close_cursor(shipment_del_c1);

         xProgress := 'POOB-20-1814';
         dbms_sql.close_cursor(header_del_c2);

         xProgress := 'POOB-20-1816';
         dbms_sql.close_cursor(line_del_c2);

         xProgress := 'POOB-20-1818';
         dbms_sql.close_cursor(shipment_del_c2);

         -- Bug 2490109 Closing the distribution cursors.
         xProgress := 'POOB-50-1819';
         if(ece_poo_transaction.project_sel_c>0) then   --Bug 2819176
         dbms_sql.close_cursor(ece_poo_transaction.project_sel_c);

         xProgress := 'POOB-50-1820';
         dbms_sql.close_cursor(ece_poo_transaction.project_del_c1);

         xProgress := 'POOB-50-1821';
         dbms_sql.close_cursor(ece_poo_transaction.project_del_c2);
         end if;

         xProgress := 'POOB-20-1820';
        if ec_debug.G_debug_level >= 2 then
         ec_debug.pop('ECE_POO_TRANSACTION.PUT_DATA_TO_OUTPUT_TABLE');
        end if;

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END put_data_to_output_table;


   PROCEDURE update_po(
      document_type  IN VARCHAR2,
      po_number      IN VARCHAR2,
      po_type        IN VARCHAR2,
      release_number IN VARCHAR2) IS

      xProgress            VARCHAR2(80);
      l_document_type      VARCHAR2(25);
      l_document_subtype   VARCHAR2(25);
      l_document_id        NUMBER;
      l_header_id          NUMBER;
      l_release_id         NUMBER;
      l_error_code         NUMBER;
      l_error_buf          VARCHAR2(1000);
      l_error_stack        VARCHAR2(2000);

      BEGIN
        if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO_TRANSACTION.UPDATE_PO');
         ec_debug.pl(3,'document_type: ', document_type);
         ec_debug.pl(3,'po_number: ',     po_number);
         ec_debug.pl(3,'po_type: ',       po_type);
         ec_debug.pl(3,'release_number: ',release_number);
        end if;

         xProgress := 'POOB-30-1000';
         BEGIN
            SELECT   po_header_id
            INTO     l_header_id
            FROM     po_headers
            WHERE    segment1         = po_number AND
                     type_lookup_code = po_type;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(0,'EC','ECE_NO_ROW_SELECTED','PROGRESS_LEVEL',xProgress,'INFO','PO HEADER ID','TABLE_NAME','PO_HEADERS');

         END;
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'l_header_id: ',l_header_id);
         end if;

         -- Perform the first update if this is a Standard or Blanket PO
         xProgress := 'POOB-30-1010';
         IF document_type NOT IN('NR','CR') THEN
            xProgress := 'POOB-30-1020';
            UPDATE   po_headers
            SET      last_update_date     =  SYSDATE,
                     printed_date         =  SYSDATE,
                     print_count          =  NVL(print_count,0) + 1,
                     edi_processed_flag   = 'Y'
            WHERE    po_header_id         =  l_header_id;

            IF SQL%NOTFOUND THEN
               ec_debug.pl(0,'EC','ECE_NO_ROW_UPDATED','PROGRESS_LEVEL',xProgress,'INFO','EDI PROCESSED','TABLE_NAME','PO_HEADERS');
            END IF;

            -- Perform the same update for the Archive Table.
            xProgress := 'POOB-30-1022';
            UPDATE   po_headers_archive
            SET      last_update_date     =  SYSDATE,
                     printed_date         =  SYSDATE,
                     print_count          =  NVL(print_count,0) + 1,
                     edi_processed_flag   = 'Y'
            WHERE    po_header_id         =  l_header_id AND
                     latest_external_flag = 'Y';

            IF SQL%NOTFOUND THEN
               ec_debug.pl(0,'EC','ECE_NO_ROW_UPDATED','PROGRESS_LEVEL',xProgress,'INFO','EDI PROCESSED','TABLE_NAME','PO_HEADERS_ARCHIVE');
            END IF;

         ELSE
            -- Get the po_release_id, as it is needed here for the update and
            -- later for the archive call
            xProgress := 'POOB-30-1024';
            BEGIN
               SELECT   po_release_id INTO l_release_id
               FROM     po_releases
               WHERE    release_num  = release_number AND
                        po_header_id = l_header_id;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,'EC','ECE_NO_ROW_SELECTED','PROGRESS_LEVEL',xProgress,'INFO','PO RELEASE ID','TABLE_NAME','PO_RELEASES');

            END;
           if ec_debug.G_debug_level = 3 then
             ec_debug.pl(3, 'l_release_id: ',l_release_id);
           end if;

            -- Perform this update if this is a Release PO
            xProgress := 'POOB-30-1030';
            UPDATE   po_releases
            SET      last_update_date     =  SYSDATE,
                     printed_date         =  SYSDATE,
                     print_count          =  NVL(print_count,0) + 1,
                     edi_processed_flag   = 'Y'
            WHERE    po_release_id        =  l_release_id;

            IF SQL%NOTFOUND THEN
               ec_debug.pl(0,'EC','ECE_NO_ROW_UPDATED','PROGRESS_LEVEL',xProgress,'INFO','EDI PROCESSED','TABLE_NAME','PO_RELEASES');
            END IF;

            -- Perform the same update for the Archive Table.
            xProgress := 'POOB-30-1040';
            UPDATE   po_releases_archive
            SET      last_update_date     =  SYSDATE,
                     printed_date         =  SYSDATE,
                     print_count          =  NVL(print_count,0) + 1,
                     edi_processed_flag   = 'Y'
            WHERE    po_release_id        =  l_release_id AND
                     latest_external_flag = 'Y';

            IF SQL%NOTFOUND THEN
               ec_debug.pl(0,'EC','ECE_NO_ROW_UPDATED','PROGRESS_LEVEL',xProgress,'INFO','EDI PROCESSED','TABLE_NAME','PO_RELEASES_ARCHIVE');
            END IF;
         END IF;

         -- Perform archiving by calling the archive proceedure.
         xProgress := 'POOB-30-1050';
         BEGIN
		/* Bug 2396394 Added the document type CONTRACT(NC) in SQL below */
            SELECT   DECODE
                       (document_type,
                        'NS','PO',
                        'NC','PO',
                        'CS','PO',
                        'NB','PA',
                        'CB','PA',
                        'NP','PO',
                        'CP','PO',
                        'NR','RELEASE',
                        'CR','RELEASE'),
                     DECODE
                       (document_type,
                        'NR',DECODE
                              (po_type,
                               'PLANNED','SCHEDULED',
                               'BLANKET','BLANKET'),
                        'CR',DECODE(po_type,
                               'PLANNED','SCHEDULED',
                               'BLANKET','BLANKET'),
                        po_type)
            INTO     l_document_type,l_document_subtype
            FROM     DUAL;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
              ec_debug.pl(0,'EC','ECE_DECODE_FAILED','PROGRESS_LEVEL',xProgress,'CODE',document_type);

         END;

        if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'l_document_type: ',   l_document_type);
         ec_debug.pl(3,'l_document_subtype: ',l_document_subtype);
        end if;

         xProgress := 'POOB-30-1060';
         IF document_type NOT IN ('NR','CR') THEN
            l_document_id := l_header_id;
         ELSE
            l_document_id := l_release_id;
         END IF;

         xProgress := 'POOB-30-1090';
         ece_po_archive_pkg.porarchive(
            l_document_type,
            l_document_subtype,
            l_document_id,
            'PRINT',
            l_error_code,
            l_error_buf,
            l_error_stack);

         xProgress := 'POOB-30-1100';
         -- IF l_error_code <> 0 THEN
         --    raise_application_error(-20000,l_error_buf || l_error_stack);
         -- END IF;

        if ec_debug.G_debug_level = 3 then
         ec_debug.pop('ECE_POO_TRANSACTION.UPDATE_PO');
        end if;

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;
      END update_po;

PROCEDURE POPULATE_DISTRIBUTION_INFO(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iRun_id                 IN INTEGER,
      cDistribution_Interface      IN VARCHAR2,
      l_key_tbl               IN OUT NOCOPY  ece_flatfile_pvt.Interface_tbl_type,
      cPO_Header_ID           IN NUMBER,
      cPO_Release_ID          IN NUMBER,
      cPO_Line_ID             IN NUMBER,
      cPO_Line_Location_ID    IN NUMBER,
      cFile_Common_Key        IN VARCHAR2) IS

      xProgress                  VARCHAR2(80);
      v_LevelProcessed           VARCHAR(40);

    /* Bug 2490109
      l_project_tbl              ece_flatfile_pvt.Interface_tbl_type;
      project_sel_c              INTEGER;
    */
      v_project_view_name        VARCHAR2(120) := 'ECE_PO_DISTRIBUTIONS_V'; -- Bug 1891291

      cProject_select            VARCHAR2(32000);
      cProject_from              VARCHAR2(32000);
      cProject_where             VARCHAR2(32000);

      iProject_output_level      NUMBER := 14;
      iProject_count             NUMBER := 0;
      --iKey_count                 NUMBER := 0;

      l_project_fkey             NUMBER;

      dummy                      INTEGER;

      init_msg_list              VARCHAR2(20);
      simulate                   VARCHAR2(20);
      validation_level           VARCHAR2(20);
      commt                      VARCHAR2(20);
      return_status              VARCHAR2(20);
      msg_count                  NUMBER;
      msg_data                   VARCHAR2(2000); --3650215
      v_project_acct_installed   BOOLEAN;
      v_project_acct_short_name  VARCHAR2(2) := 'PA';
      v_project_acct_status      VARCHAR2(120);
      v_project_acct_industry    VARCHAR2(120);
      v_project_acct_schema      VARCHAR2(120);
      c_project_number           VARCHAR2(25);
      c_project_type             VARCHAR2(20);
      c_task_number              VARCHAR2(25);
      c_task_id                  NUMBER; --bug 1891291
      c_project_id               NUMBER; --bug 1891291
      nTask_id_pos               NUMBER;   -- 2823215
      nProject_id_pos            NUMBER;
      nProject_num_pos           NUMBER;
      nProject_type_pos          NUMBER;
      nTask_num_pos              NUMBER;   -- 2823215
      nConv_dt_pos             pls_integer;
      nConv_tz_pos             pls_integer;
      nConv_off_pos            pls_integer;
      BEGIN
        if ec_debug.G_debug_level = 3 then
         ec_debug.push('ECE_POO_TRANSACTION.POPULATE_PROJECT_INFO');
         ec_debug.pl(3,'cCommunication_Method: ',cCommunication_Method);
         ec_debug.pl(3,'cTransaction_Type: '    ,cTransaction_Type);
         ec_debug.pl(3,'iRun_id: '              ,iRun_id);
         ec_debug.pl(3,'cDistribution_Interface: '   ,cDistribution_Interface);
         ec_debug.pl(3,'cPO_Header_ID: '        ,cPO_Header_ID);
         ec_debug.pl(3,'cPO_Release_ID: '       ,cPO_Release_ID);
         ec_debug.pl(3,'cPO_Line_ID: '          ,cPO_Line_ID);
         ec_debug.pl(3,'cPO_Line_Location_ID: ' ,cPO_Line_Location_ID);
       end if;

         -- Initialize the PL/SQL Table



v_project_acct_installed := fnd_installation.get_app_info(
                                       v_project_acct_short_name, -- i.e. 'PA'
                                       v_project_acct_status,     -- 'I' means it's installed
                                       v_project_acct_industry,
                                       v_project_acct_schema);

v_project_acct_status := NVL(v_project_acct_status,'X');

     if ece_poo_transaction.project_sel_c =0 then	--Bug 2490109
           ece_poo_transaction.project_sel_c:=-911;
     end if;

     if ece_poo_transaction.project_sel_c <0 then	--Bug 2490109

         xProgress := 'POOB-40-1000';
  	 iKey_count := l_key_tbl.COUNT;
         if ec_debug.G_debug_level = 3 then
         	ec_debug.pl(3,'iKey_count: ',iKey_count);
         END if;
         ece_flatfile_pvt.init_table(cTransaction_Type,cDistribution_Interface,iProject_output_level,TRUE,l_project_tbl,l_key_tbl);

         xProgress := 'POOB-40-1010';
         ece_extract_utils_pub.select_clause(cTransaction_Type,
                                             cCommunication_Method,
                                             cDistribution_Interface,
                                             l_project_tbl,
                                             cProject_select,
                                             cProject_from,
                                             cProject_where);

         -- Build the WHERE Clause
         xProgress := 'POOB-40-1020';
         cProject_where  := cProject_where  ||
                            'po_header_id = :po_header_id';

        cProject_where  := cProject_where  || ' AND ' ||
                            'nvl(po_release_id,0) = :po_release_id';

         cProject_where  := cProject_where  || ' AND ' ||
                            'po_line_id = :po_line_id';

         cProject_where  := cProject_where  || ' AND ' ||
                            'line_location_id = :line_location_id';

         xProgress := 'POOB-40-1030';
         cProject_where  := cProject_where  || ' ORDER BY distribution_num';

         -- Combine the SELECT, FROM and WHERE Clauses
         xProgress := 'POOB-40-1040';
         cProject_select := cProject_select ||
                            cProject_from   ||
                            cProject_where;

        if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'cProject_select: ',cProject_select);
        end if;

         -- Open the Cursor
         xProgress := 'POOB-40-1050';
         project_sel_c := dbms_sql.open_cursor;

         -- Parse the Cursor
         xProgress := 'POOB-40-1060';
         BEGIN
            dbms_sql.parse(project_sel_c,
                           cProject_select,
                           dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cProject_select);
               app_exception.raise_exception;
         END;

         -- Set Counter
         xProgress := 'POOB-40-1070';
         iProject_count := l_project_tbl.COUNT;
         ec_debug.pl(3,'iProject_count: ',iProject_count);

         xProgress := 'POOB-40-1080';
         --iKey_count := l_key_tbl.COUNT;
         --ec_debug.pl(3,'iKey_count: ',iKey_count);

         -- Define Column Types
         xProgress := 'POOB-40-1090';
         ece_flatfile_pvt.define_interface_column_type(project_sel_c,cProject_select,ece_extract_utils_PUB.G_MaxColWidth,l_project_tbl);

         -- Project Level Positions

      end if;	--Bug 2490109
      --2823215
        ece_flatfile_pvt.find_pos(l_project_tbl,'TASK_ID',nTask_id_pos);
        ece_flatfile_pvt.find_pos(l_project_tbl,'PROJECT_ID',nProject_id_pos);
        ece_flatfile_pvt.find_pos(l_project_tbl,'PROJECT_NUMBER',nProject_num_pos);
        ece_flatfile_pvt.find_pos(l_project_tbl,'PROJECT_TYPE',nProject_type_pos);
        ece_flatfile_pvt.find_pos(l_project_tbl,'TASK_NUMBER',nTask_num_pos);


       --2823215
       ece_flatfile_pvt.find_pos(l_project_tbl,'CONVERSION_DATE',nConv_dt_pos);
       ece_flatfile_pvt.find_pos(l_project_tbl,'CONVERSION_DT_TZ_CODE',nConv_tz_pos);
       ece_flatfile_pvt.find_pos(l_project_tbl,'CONVERSION_DT_OFF',nConv_off_pos);

      if ece_poo_transaction.project_sel_c >0 then           --Bug 2490109
         -- Bind Variables
         xProgress := 'POOB-40-1140';
         dbms_sql.bind_variable(project_sel_c,':po_header_id',NVL(cPO_Header_ID,0));

         xProgress := 'POOB-40-1150';
         dbms_sql.bind_variable(project_sel_c,':po_release_id',NVL(cPO_Release_ID,0));

         xProgress := 'POOB-40-1160';
         dbms_sql.bind_variable(project_sel_c,':po_line_id',NVL(cPO_Line_ID,0));

         xProgress := 'POOB-40-1170';
         dbms_sql.bind_variable(project_sel_c,':line_location_id',NVL(cPO_Line_Location_ID,0));

         -- Execute the Cursor
         xProgress := 'POOB-40-1180';
         dummy := dbms_sql.execute(project_sel_c);

         -- Fetch Data
         xProgress := 'POOB-40-1190';
         WHILE dbms_sql.fetch_rows(project_sel_c) > 0 LOOP -- Project Level Loop
            -- Store Internal Values in the PL/SQL Table
            xProgress := 'POOB-40-1200';
            ece_flatfile_pvt.assign_column_value_to_tbl(project_sel_c,iKey_count,l_project_tbl,l_key_tbl);

	    xProgress := 'POOB-TZ-4500';

	    ece_timezone_api.get_server_timezone_details
            (
             to_date(l_project_tbl(nConv_dt_pos).value,'YYYYMMDD HH24MISS'),
             l_project_tbl(nConv_off_pos).value,
	     l_project_tbl(nConv_tz_pos).value
            );

            -- Convert Internal to External Values
            xProgress := 'POOB-40-1210';
            ec_code_conversion_pvt.populate_plsql_tbl_with_extval(
               p_api_version_number => 1.0,
               p_init_msg_list      => init_msg_list,
               p_simulate           => simulate,
               p_commit             => commt,
               p_validation_level   => validation_level,
               p_return_status      => return_status,
               p_msg_count          => msg_count,
               p_msg_data           => msg_data,
               p_key_tbl            => l_key_tbl,
               p_tbl                => l_project_tbl);

            -- Get Project FKEY
            xProgress := 'POOB-40-1220';
            BEGIN
               SELECT   ece_po_project_info_s.NEXTVAL INTO l_project_fkey
               FROM     DUAL;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_PO_PROJECT_INFO_S');

            END;
           if ec_debug.G_debug_level = 3 then
            ec_debug.pl(3,'l_project_fkey: ',l_project_fkey);
           end if;

            -- Insert into Interface Table
 /*           xProgress := 'POOB-40-1230';
            ece_extract_utils_pub.insert_into_interface_tbl(
               iRun_id,
               cTransaction_Type,
               cCommunication_Method,
               cDistribution_Interface,
               l_project_tbl,
               l_project_fkey);  */

-- Bug 1891291 begin
/* Update ECE_PO_DISTRIBUTIONS
   with project related data
   based on task_id and project_id
*/

            xProgress := 'POOB-40-1240';
            IF cTransaction_Type = 'POO' THEN
               ece_poo_x.populate_ext_project(l_project_fkey,l_project_tbl);
            ELSIF cTransaction_Type = 'POCO' THEN
               ece_poco_x.populate_ext_project(l_project_fkey,l_project_tbl);
            END IF;

IF v_project_acct_status = 'I' THEN
begin


c_task_id := l_project_tbl(nTask_id_pos).value;
c_project_id := l_project_tbl(nProject_id_pos).value;

/* select task_id,project_id into
c_task_id,c_project_id
from
ECE_PO_DISTRIBUTIONS EPID
where
EPID.TRANSACTION_RECORD_ID = l_project_fkey; */


if (c_task_id is not NULL and c_project_id is not null) then
select PPE.PROJECT_NUMBER,PPE.PROJECT_TYPE,
       PAT.TASK_NUMBER INTO
       c_PROJECT_NUMBER,c_PROJECT_TYPE,
       c_TASK_NUMBER
 FROM
      PA_PROJECTS_EXPEND_V
      PPE,
      PA_TASKS
      PAT,
      ECE_PO_DISTRIBUTIONS
      EPID
WHERE
      EPID.TASK_ID = PAT.TASK_ID (+) AND
      EPID.PROJECT_ID = PAT.PROJECT_ID (+) AND
      EPID.PROJECT_ID = PPE.PROJECT_ID (+) AND
      EPID.TRANSACTION_RECORD_ID = l_project_fkey;

--2823215
l_project_tbl(nProject_num_pos).value := c_project_number;
l_project_tbl(nProject_type_pos).value := c_project_type;
l_project_tbl(nTask_num_pos).value := c_task_number;
--2823215

/* UPDATE ECE_PO_DISTRIBUTIONS EPID
SET  EPID.PROJECT_NUMBER = c_PROJECT_NUMBER,
     EPID.PROJECT_TYPE =   c_PROJECT_TYPE,
     EPID.TASK_NUMBER = c_TASK_NUMBER
WHERE EPID.TRANSACTION_RECORD_ID = l_project_fkey; */

end if;
exception
when no_data_found then null;
when others then null;
end;

end if;

-- 2823215
               ece_poo_transaction.write_to_file(cTransaction_Type,
                                                 cCommunication_Method,
                                                 cDistribution_Interface,
                                                 l_project_tbl,
                                                 iOutput_width,
                                                 iRun_id,
                                                 cFile_Common_Key,
                                                 l_project_fkey);
-- 2823215
-- Bug 1891291 end
            -- Call Custom Project Stub Depending on Transaction
/*            xProgress := 'POOB-40-1240';
            IF cTransaction_Type = 'POO' THEN
               ece_poo_x.populate_ext_project(l_project_fkey,l_project_tbl);
            ELSIF cTransaction_Type = 'POCO' THEN
               ece_poco_x.populate_ext_project(l_project_fkey,l_project_tbl);
            END IF;   */

         END LOOP;

         -- Check to see if anything was processed
         xProgress := 'POOB-40-1250';
         IF(dbms_sql.last_row_count = 0) THEN
            v_LevelProcessed := 'PROJECT';
            ec_debug.pl(0,'EC','ECE_NO_DB_ROW_PROCESSED','LEVEL_PROCESSED',v_LevelProcessed,'PROGRESS_LEVEL',xProgress,'TRANSACTION_TYPE',cTransaction_Type);
         END IF;

       end if;  		--Bug 2490109

         -- Close the Cursor Bug 2490109
         -- xProgress := 'POOB-40-1260';
         -- dbms_sql.close_cursor(project_sel_c);

         -- Tell Debug that this Procedure is Done
        if ec_debug.G_debug_level = 3 then
         ec_debug.pop('ECE_POO_TRANSACTION.POPULATE_PROJECT_INFO');
        end if;

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END POPULATE_DISTRIBUTION_INFO;

   PROCEDURE PUT_DISTDATA_TO_OUT_TBL(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cDistribution_Interface      IN VARCHAR2,
      cPO_Header_ID           IN NUMBER,
      cPO_Release_ID          IN NUMBER,
      cPO_Line_ID             IN NUMBER,
      cPO_Line_Location_ID    IN NUMBER,
      cFile_Common_Key        IN VARCHAR2) IS

      xProgress                  VARCHAR2(80);
      v_LevelProcessed           VARCHAR2(40);
      c_project_common_key_name  VARCHAR2(40);

      nProject_key_pos           NUMBER;

     /* Bug 2490109
      l_project_tbl              ece_flatfile_pvt.Interface_tbl_type;
      project_sel_c              INTEGER;
      project_del_c1             INTEGER;
      project_del_c2             INTEGER;
     */

      cProject_select            VARCHAR2(32000);
      cProject_from              VARCHAR2(32000);
      cProject_where             VARCHAR2(32000);

      cProject_delete1           VARCHAR2(32000);
      cProject_delete2           VARCHAR2(32000);

      iProject_count             NUMBER;

      rProject_rowid             ROWID;
      rProject_X_rowid           ROWID;

      cProject_X_Interface       VARCHAR2(50);

      iProject_output_level      NUMBER := 14;
      iProject_start_num         INTEGER;
      dummy                      INTEGER;

      BEGIN
        if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO_TRANSACTION.PUT_PROJECT_DATA_TO_OUTPUT_TBL');
         ec_debug.pl(3,'cCommunication_Method: ',cCommunication_Method);
         ec_debug.pl(3,'cTransaction_Type: '    ,cTransaction_Type);
         ec_debug.pl(3,'iOutput_width: '        ,iOutput_width);
         ec_debug.pl(3,'iRun_id: '              ,iRun_id);
         ec_debug.pl(3,'cDistribution_Interface: '   ,cDistribution_Interface);
         ec_debug.pl(3,'cPO_Header_ID: '        ,cPO_Header_ID);
         ec_debug.pl(3,'cPO_Release_ID: '       ,cPO_Release_ID);
         ec_debug.pl(3,'cPO_Line_ID: '          ,cPO_Line_ID);
         ec_debug.pl(3,'cPO_Line_Location_ID: ' ,cPO_Line_Location_ID);
         ec_debug.pl(3,'cFile_Common_Key: '     ,cFile_Common_Key);
        end if;


        if ece_poo_transaction.project_sel_c = 0 then         -- Bug 2490109
                ece_poo_transaction.project_sel_c:=-911;
        end if;

        if ece_poo_transaction.project_sel_c < 0 then	      -- Bug 2490109
	 ece_poo_transaction.l_project_tbl.DELETE;	      -- Bug 2490109

         -- Build the SELECT, FROM, and WHERE Clauses
         xProgress := 'POOB-50-1000';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cDistribution_Interface,
                                        cProject_X_Interface,
                                        l_project_tbl,
                                        c_project_common_key_name,
                                        cProject_select,
                                        cProject_from,
                                        cProject_where,
                                        iProject_output_level);

         -- Customize the WHERE Clause
         xProgress := 'POOB-50-1010';
         cProject_where  := cProject_where       || ' AND '      ||
                            cDistribution_Interface   || '.run_id = :run_id';

         cProject_where  := cProject_where       || ' AND NVL('  ||
                            cDistribution_Interface   || '.po_header_id,0) = :po_header_id';

         cProject_where  := cProject_where       || ' AND NVL('  ||
                            cDistribution_Interface   || '.po_release_id,0) = :po_release_id';

         cProject_where  := cProject_where       || ' AND NVL('  ||
                            cDistribution_Interface   || '.po_line_id,0) = :po_line_id';

         cProject_where  := cProject_where       || ' AND NVL('  ||
                            cDistribution_Interface   || '.line_location_id,0) = :po_line_location_id';

         cProject_where  := cProject_where       || ' ORDER BY ' ||
                            cDistribution_Interface   || '.distribution_num';

         -- Customize the SELECT Clause
         cProject_select := cProject_select      || ','          ||
                            cDistribution_Interface   || '.rowid'     || ',' ||
                            cProject_X_Interface || '.rowid ';

         -- Build the Complete SQL Statement
         cProject_select := cProject_select      ||
                            cProject_from        ||
                            cProject_where       ||
                            ' FOR UPDATE';
         ec_debug.pl(3,'cProject_select: ',cProject_select);

         -- Build First DELETE SQL Statement
         cProject_delete1 := 'DELETE FROM ' || cDistribution_Interface   || ' WHERE rowid = :col_rowid';

         -- Build Second DELETE SQL Statement
         cProject_delete2 := 'DELETE FROM ' || cProject_X_Interface || ' WHERE rowid = :col_rowid';

         if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'cProject_delete1: ',cProject_delete1);
         ec_debug.pl(3,'cProject_delete2: ',cProject_delete2);
         end if;

         -- Open the Cursors
         xProgress := 'POOB-50-1020';
         project_sel_c  := dbms_sql.open_cursor;

         xProgress := 'POOB-50-1030';
         project_del_c1 := dbms_sql.open_cursor;

         xProgress := 'POOB-50-1040';
         project_del_c2 := dbms_sql.open_cursor;

         -- Parse the SQL Statements
         xProgress := 'POOB-50-1050';
         BEGIN
            xProgress := 'POOB-50-1060';
            dbms_sql.parse(project_sel_c,cProject_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cProject_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-50-1070';
         BEGIN
            xProgress := 'POOB-50-1080';
            dbms_sql.parse(project_del_c1,cProject_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cProject_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-50-1090';
         BEGIN
            xProgress := 'POOB-50-1100';
            dbms_sql.parse(project_del_c2,cProject_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cProject_delete2);
               app_exception.raise_exception;

         END;

       end if; 				--Bug 2490109

     if  ece_poo_transaction.project_sel_c > 0 then  	-- Bug 2490109

         -- Set the Counter Variables
         xProgress := 'POOB-50-1110';
         iProject_count := l_project_tbl.COUNT;
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'iProject_count: ',iProject_count);
         end if;

         -- Define Column Types
         xProgress := 'POOB-50-1120';
         ece_flatfile_pvt.define_interface_column_type(project_sel_c,
                                                       cProject_select,
                                                       ece_flatfile_pvt.G_MaxColWidth,
                                                       l_project_tbl);

         -- Define Additional Column Types
         xProgress := 'POOB-50-1130';
         dbms_sql.define_column_rowid(project_sel_c,iProject_count + 1,rProject_rowid);

         xProgress := 'POOB-50-1140';
         dbms_sql.define_column_rowid(project_sel_c,iProject_count + 2,rProject_X_rowid);

         -- Bind Variables
         xProgress := 'POOB-50-1150';
         dbms_sql.bind_variable(project_sel_c,':run_id',             iRun_id);

         xProgress := 'POOB-50-1160';
         dbms_sql.bind_variable(project_sel_c,':po_header_id',       NVL(cPO_Header_ID,0));

         xProgress := 'POOB-50-1170';
         dbms_sql.bind_variable(project_sel_c,':po_release_id',      NVL(cPO_Release_ID,0));

         xProgress := 'POOB-50-1180';
         dbms_sql.bind_variable(project_sel_c,':po_line_id',         NVL(cPO_Line_ID,0));

         xProgress := 'POOB-50-1190';
         dbms_sql.bind_variable(project_sel_c,':po_line_location_id',NVL(cPO_Line_Location_ID,0));

         -- Execute the SQL Statement
         xProgress := 'POOB-50-1200';
         dummy := dbms_sql.execute(project_sel_c);

         -- Fetch Data
         xProgress := 'POOB-50-1210';
         WHILE dbms_sql.fetch_rows(project_sel_c) > 0 LOOP -- Project Level Loop
            -- Store the Fetched Data in the PL/SQL Table
            xProgress := 'POOB-50-1220';
            ece_flatfile_pvt.assign_column_value_to_tbl(project_sel_c,l_project_tbl);

            xProgress := 'POOB-50-1230';
            dbms_sql.column_value(project_sel_c,iProject_count + 1,rProject_rowid);

            xProgress := 'POOB-50-1240';
            dbms_sql.column_value(project_sel_c,iProject_count + 2,rProject_X_rowid);

            xProgress := 'POOB-50-1250';
            ece_poo_transaction.write_to_file(cTransaction_Type,
                                              cCommunication_Method,
                                              cDistribution_Interface,
                                              l_project_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              cFile_Common_Key,
                                              null);

            -- Bind the ROWIDs for Deletion
            xProgress := 'POOB-50-1260';
            dbms_sql.bind_variable(project_del_c1,':col_rowid',rProject_rowid);

            xProgress := 'POOB-50-1270';
            dbms_sql.bind_variable(project_del_c2,':col_rowid',rProject_X_rowid);

            -- Execute the First Delete SQL
            xProgress := 'POOB-50-1280';
            dummy := dbms_sql.execute(project_del_c1);

            -- Execute the Second Delete SQL
            xProgress := 'POOB-50-1290';
            dummy := dbms_sql.execute(project_del_c2);

         END LOOP; -- Project Level

         -- Make a note if zero rows were processed
         xProgress := 'POOB-50-1300';
         IF dbms_sql.last_row_count = 0 THEN
            xProgress := 'POOB-50-1310';
            v_LevelProcessed := 'PROJECT';
            ec_debug.pl(0,
                       'EC',
                       'ECE_NO_DB_ROW_PROCESSED',
                       'PROGRESS_LEVEL',
                        xProgress,
                       'LEVEL_PROCESSED',
                        v_LevelProcessed,
                       'TRANSACTION_TYPE',
                        cTransaction_Type);
         END IF;

        end if;  		-- Bug 2490109

      /*  Bug 2490109
         -- Let's Close the Cursors
         xProgress := 'POOB-50-1320';
         dbms_sql.close_cursor(project_sel_c);

         xProgress := 'POOB-50-1330';
         dbms_sql.close_cursor(project_del_c1);

         xProgress := 'POOB-50-1340';
         dbms_sql.close_cursor(project_del_c2);
      */

         xProgress := 'POOB-50-1350';
         if ec_debug.G_debug_level >= 2 then
         ec_debug.pop('ECE_POO_TRANSACTION.PUT_PROJECT_DATA_TO_OUTPUT_TBL');
         end if;

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END PUT_DISTDATA_TO_OUT_TBL;

   PROCEDURE populate_text_attachment(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iRun_id                 IN INTEGER,
      cHeader_Output_Level    IN NUMBER,
      cDetail_Output_Level    IN NUMBER,
      cAtt_Header_Interface   IN VARCHAR2,
      cAtt_Detail_Interface   IN VARCHAR2,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cSegment_Size           IN NUMBER,
      l_key_tbl               IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      cFile_Common_Key        IN VARCHAR2,
      l_att_header_tbl        IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      l_att_detail_tbl        IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      l_key_count             IN OUT NOCOPY NUMBER) IS

      xProgress            VARCHAR2(80);

      --l_att_header_tbl     ece_flatfile_pvt.Interface_tbl_type;

      v_att_header_select  VARCHAR2(32000);
      v_att_header_from    VARCHAR2(32000);
      v_att_header_where   VARCHAR2(32000);
      v_att_view_name      VARCHAR2(120) := 'ECE_ATTACHMENT_V';

      n_att_header_sel_c   INTEGER;
      n_dummy              INTEGER;
      n_header_count       NUMBER := 0;
      n_header_fkey        NUMBER;

      n_datatype_id_pos    NUMBER;
      n_att_seq_num_pos    NUMBER;
      n_att_doc_id_pos     NUMBER;  --Bug 2187958
      n_att_hdr_count      NUMBER;
      BEGIN
         if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO_TRANSACTION.POPULATE_TEXT_ATTACHMENT');
         ec_debug.pl(3,'cEntity_Name: ', cEntity_Name);
         ec_debug.pl(3,'cName: ',        cName);
         ec_debug.pl(3,'cPK1_Value: ',   cPK1_Value);
         ec_debug.pl(3,'cPK2_Value: ',   cPK2_Value);
         ec_debug.pl(3,'cPK3_Value: ',   cPK3_Value);
         ec_debug.pl(3,'cPK4_Value: ',   cPK4_Value);
         ec_debug.pl(3,'cPK5_Value: ',   cPK5_Value);
         ec_debug.pl(3,'cSegment_Size: ',cSegment_Size);
         end if;

         xProgress := 'POOB-60-1000';
         if ( l_att_header_tbl.count = 0) then
           l_key_count := l_key_tbl.count;
           ece_flatfile_pvt.init_table(cTransaction_Type,
                                       cAtt_Header_Interface,
                                       cHeader_Output_Level,
                                       TRUE,
                                       l_att_header_tbl,
                                       l_key_tbl);
	 end if;

         if ec_debug.G_debug_level >= 3 then
            ec_debug.pl(3,'l_key_count: ', l_key_count);
         end if;

         xProgress := 'POOB-60-1005';
         -- Build the SELECT Clause.
         ece_extract_utils_pub.select_clause(cTransaction_Type,
                                             cCommunication_Method,
                                             cAtt_Header_Interface,
                                             l_att_header_tbl,
                                             v_att_header_select,
                                             v_att_header_from,
                                             v_att_header_where);

         xProgress := 'POOB-60-1010';
         -- Build the WHERE and the ORDER BY Clause.
         -- Entity Name must not be NULL.
         v_att_header_where := v_att_header_where ||
                               v_att_view_name    || '.entity_name = :cEntity_Name';

         xProgress := 'POOB-60-1020';
         -- Name must not be NULL.
         v_att_header_where := v_att_header_where || ' AND UPPER(' ||
                               v_att_view_name    || '.category_name) = UPPER(:cName)';

         xProgress := 'POOB-60-1030';
         -- cPK1 Value must not be NULL.
         v_att_header_where := v_att_header_where || ' AND ' ||
                               v_att_view_name    || '.pk1_value = :cPK1_Value';

         xProgress := 'POOB-60-1040';
/*         IF cPK2_Value IS NOT NULL THEN
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value = :cPK2_Value';
         ELSE  -- cPK2_Value IS NULL.
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value IS NULL';
         END IF; */
         -- BUG:5367903

         IF cPK2_Value IS NULL THEN
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value IS NULL';
         ELSE
           IF cPK2_Value <> C_ANY_VALUE THEN
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value = :cPK2_Value';
           END IF;
         END IF;


         xProgress := 'POOB-60-1050';
	 IF cEntity_Name <> 'MTL_SYSTEM_ITEMS' then	-- 3550723
/*           IF cPK3_Value IS NOT NULL THEN
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk3_value = :cPK3_Value';
           ELSE  -- cPK3_Value IS NULL.
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk3_value IS NULL';
           END IF;*/
           -- BUG:5367903

           IF cPK3_Value IS NULL THEN
              v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk3_value IS NULL';
           ELSE
             IF cPK3_Value <> C_ANY_VALUE THEN
              v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk3_value = :cPK3_Value';
             END IF;
           END IF;

           xProgress := 'POOB-60-1060';
           /* IF cPK4_Value IS NOT NULL THEN
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk4_value = :cPK4_Value';
           ELSE  -- cPK4_Value IS NULL.
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk4_value IS NULL';
           END IF;*/
           -- BUG:5367903

           IF cPK4_Value IS NULL THEN
              v_att_header_where := v_att_header_where || ' AND ' ||
                                    v_att_view_name    || '.pk4_value IS NULL';
           ELSE
             IF cPK4_Value <> C_ANY_VALUE THEN
              v_att_header_where := v_att_header_where || ' AND ' ||
                                    v_att_view_name    || '.pk4_value = :cPK4_Value';
             END IF;
           END IF;

           xProgress := 'POOB-60-1070';
           /* IF cPK5_Value IS NOT NULL THEN
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk5_value = :cPK5_Value';
           ELSE  -- cPK5_Value IS NULL.
            v_att_header_where := v_att_header_where || ' AND ' ||
                                  v_att_view_name    || '.pk5_value IS NULL';
           END IF;*/
           -- BUG:5367903

           IF cPK5_Value IS NULL THEN
              v_att_header_where := v_att_header_where || ' AND ' ||
                                    v_att_view_name    || '.pk5_value IS NULL';
           ELSE
             IF cPK5_Value <> C_ANY_VALUE THEN
              v_att_header_where := v_att_header_where || ' AND ' ||
                                    v_att_view_name    || '.pk5_value = :cPK5_Value';
             END IF;
           END IF;

         END IF;

         xProgress := 'POOB-60-1080';
         /*v_att_header_where := v_att_header_where || ' ORDER BY ' ||
                               v_att_view_name    || '.att_seq_num';*/

         --Bug 2187958
         v_att_header_where := v_att_header_where || ' ORDER BY ' ||
                               v_att_view_name    || '.attached_document_id';

         xProgress := 'POOB-60-1090';
         -- Now we put all the clauses together.
         v_att_header_select := v_att_header_select || v_att_header_from || v_att_header_where;

         if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'v_att_header_select: ',v_att_header_select);
         end if;

         xProgress := 'POOB-60-1092';
         ece_extract_utils_pub.find_pos(l_att_header_tbl,'DATATYPE_ID',n_datatype_id_pos);

         xProgress := 'POOB-60-1094';
         ece_extract_utils_pub.find_pos(l_att_header_tbl,'ATT_SEQ_NUM',n_att_seq_num_pos);
         if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'n_datatype_id_pos: ',n_datatype_id_pos);
         ec_debug.pl(3,'n_att_seq_num_pos: ',n_att_seq_num_pos);
         end if;

        xProgress := 'POOB-60-1096';
        ece_extract_utils_pub.find_pos(l_att_header_tbl,'ATTACHED_DOCUMENT_ID',n_att_doc_id_pos);  --Bug 2187958
        if ec_debug.G_debug_level = 3 then
        ec_debug.pl(3,'n_att_doc_id_pos: ',n_att_doc_id_pos);
        end if;

         -- Open Cursor.
         xProgress := 'POOB-60-1100';
         n_att_header_sel_c := dbms_sql.open_cursor;

         -- Parse Cursor.
         xProgress := 'POOB-60-1110';
         BEGIN
            dbms_sql.parse(n_att_header_sel_c,v_att_header_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,
                                                        v_att_header_select);
               app_exception.raise_exception;
         END;

         -- Set Counter
         xProgress := 'POOB-60-1120';
         n_header_count := l_att_header_tbl.COUNT;
         if ec_debug.G_debug_level = 3 then
         ec_debug.pl(3,'n_header_count: ',n_header_count);
         end if;

         xProgress := 'POOB-60-1130';
         ece_flatfile_pvt.define_interface_column_type(n_att_header_sel_c,
                                                       v_att_header_select,
                                                       ece_extract_utils_pub.G_MAXCOLWIDTH,
                                                       l_att_header_tbl);

         -- Bind Variables
         xProgress := 'POOB-60-1132';
         dbms_sql.bind_variable(n_att_header_sel_c,':cEntity_Name',cEntity_Name);

         xProgress := 'POOB-60-1133';
         dbms_sql.bind_variable(n_att_header_sel_c,':cName',cName);

         xProgress := 'POOB-60-1134';
         dbms_sql.bind_variable(n_att_header_sel_c,':cPK1_Value',cPK1_Value);

         IF cPK2_Value IS NOT NULL and cPK2_Value <> C_ANY_VALUE THEN
            xProgress := 'POOB-60-1135';
            dbms_sql.bind_variable(n_att_header_sel_c,':cPK2_Value',cPK2_Value);
         END IF;

	 IF cEntity_Name <> 'MTL_SYSTEM_ITEMS' then	-- 3550723
           /* IF cPK3_Value IS NOT NULL THEN */ -- BUG:5367903
           IF cPK3_Value IS NOT NULL AND  cPK3_Value <> C_ANY_VALUE THEN
            xProgress := 'POOB-60-1136';
            dbms_sql.bind_variable(n_att_header_sel_c,':cPK3_Value',cPK3_Value);
           END IF;

           /* IF cPK4_Value IS NOT NULL THEN */ -- BUG:5367903
           IF cPK4_Value IS NOT NULL AND  cPK4_Value <> C_ANY_VALUE THEN
            xProgress := 'POOB-60-1137';
            dbms_sql.bind_variable(n_att_header_sel_c,':cPK4_Value',cPK4_Value);
           END IF;

           /* IF cPK5_Value IS NOT NULL THEN */ -- BUG:5367903
           IF cPK5_Value IS NOT NULL AND  cPK5_Value <> C_ANY_VALUE THEN
            xProgress := 'POOB-60-1138';
            dbms_sql.bind_variable(n_att_header_sel_c,':cPK5_Value',cPK5_Value);
           END IF;
         END IF;

         -- Execute Cursor
         xProgress := 'POOB-60-1140';
         n_dummy := dbms_sql.execute(n_att_header_sel_c);

         xProgress := 'POOB-60-1150';
         WHILE dbms_sql.fetch_rows(n_att_header_sel_c) > 0 LOOP
            xProgress := 'POOB-60-1160';
            ece_flatfile_pvt.assign_column_value_to_tbl(n_att_header_sel_c,l_key_count,l_att_header_tbl,l_key_tbl);

            xProgress := 'POOB-60-1170';
           /* BEGIN
               SELECT   ece_attachment_headers_s.NEXTVAL INTO n_header_fkey
               FROM     DUAL;

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_ATTACHMENT_HEADERS_S');
            END; */

            xProgress := 'POOB-60-1180';
          /*  ece_extract_utils_pub.insert_into_interface_tbl(iRun_id,
                                                            cTransaction_Type,
                                                            cCommunication_Method,
                                                            cAtt_Header_Interface,
                                                            l_att_header_tbl,
                                                            n_header_fkey); */

           -- 2823215
	   ece_poo_transaction.write_to_file( cTransaction_Type,
                                              cCommunication_Method,
                                              cAtt_Header_Interface,
                                              l_att_header_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              cFile_Common_Key,
                                              n_header_fkey);
            -- 2823215
            xProgress := 'POOB-60-1190';
            -- populate_ext_att_header(n_header_fkey,l_att_header_tbl);

            xProgress := 'POOB-60-1200';
            populate_text_att_detail(
               cCommunication_Method,
               cTransaction_Type,
               iRun_id,
               cDetail_Output_Level,
               cAtt_Detail_Interface,
               l_att_header_tbl(n_att_seq_num_pos).value,
               cEntity_Name,
               cName,
               cPK1_Value,
               cPK2_Value,
               cPK3_Value,
               cPK4_Value,
               cPK5_Value,
               l_att_header_tbl(n_datatype_id_pos).value,
               cSegment_Size,
               l_key_tbl,
               l_att_header_tbl(n_att_doc_id_pos).value, -- Bug 2187958
               cFile_Common_Key,
               l_att_detail_tbl);

         END LOOP;

         xProgress := 'POOB-60-1210';
         dbms_sql.close_cursor(n_att_header_sel_c);
         if ec_debug.G_debug_level >= 2 then
         ec_debug.pop('ECE_POO_TRANSACTION.POPULATE_TEXT_ATTACHMENT');
         end if;

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;
      END populate_text_attachment;

   PROCEDURE populate_text_att_detail(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iRun_id                 IN INTEGER,
      cDetail_Output_Level    IN NUMBER,
      cAtt_Detail_Interface   IN VARCHAR2,
      cAtt_Seq_Num            IN NUMBER,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cData_Type_ID           IN NUMBER,     -- 1=Short, 2=Long
      cSegment_Size           IN NUMBER,
      l_key_tbl               IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type,
      cAtt_doc_id             IN NUMBER,
      cFile_Common_Key        IN VARCHAR2,
      l_att_detail_tbl        IN OUT NOCOPY ece_flatfile_pvt.Interface_tbl_type)  IS

      xProgress                     VARCHAR2(80);

      c_local_chr_10       VARCHAR2(1) := fnd_global.local_chr(10);
      c_local_chr_13       VARCHAR2(1) := fnd_global.local_chr(13);

      --l_att_detail_tbl              ece_flatfile_pvt.Interface_tbl_type;
      l_short_text                  VARCHAR2(32000);
      l_data_chunk                  VARCHAR2(32000);
      l_temp_text                   VARCHAR2(32000);

      v_att_detail_select           VARCHAR2(32000) := 'SELECT ';
      v_att_detail_from             VARCHAR2(32000) := ' FROM ';
      v_att_detail_where            VARCHAR2(32000) := ' WHERE ';
      v_att_view_name               VARCHAR2(120)   := 'ECE_ATTACHMENT_V';
      v_continue_flag               VARCHAR2(1);
      v_last_char                   VARCHAR2(32000);
      v_split_word                  VARCHAR2(120);

      n_att_detail_sel_c            INTEGER;
      n_dummy                       INTEGER;

      n_cr_pos                      NUMBER;
      n_lf_pos                      NUMBER;
      n_detail_count                NUMBER := 0;
      n_detail_fkey                 NUMBER;
      n_new_chunk_size              NUMBER;
      n_return_size                 NUMBER;
      n_temp_return_size            NUMBER;
      n_segment_number              NUMBER;
      n_short_text_length           NUMBER;  -- Bug 3310412
      n_cur_pos                     NUMBER;
      n_space_pos                   NUMBER;

      n_att_seq_num_pos             NUMBER;
      n_att_doc_id_pos              NUMBER;  --Bug 2187958
      n_entity_name_pos             NUMBER;
      n_name_pos                    NUMBER;
      n_pk1_value_pos               NUMBER;
      n_pk2_value_pos               NUMBER;
      n_pk3_value_pos               NUMBER;
      n_pk4_value_pos               NUMBER;
      n_pk5_value_pos               NUMBER;
      n_seg_num_pos                 NUMBER;
      n_cont_flag_pos               NUMBER;
      n_att_seg_pos                 NUMBER;
      n_run_id_pos                  NUMBER;
      n_transaction_record_id_pos   NUMBER;
      n_pr_pos                      NUMBER; -- 3618073

      BEGIN
         if ec_debug.G_debug_level = 3 then
         ec_debug.push('ECE_POO_TRANSACTION.POPULATE_TEXT_ATT_DETAIL');
         ec_debug.pl(3,'cDetail_Output_Level: ' ,cDetail_Output_Level);
         ec_debug.pl(3,'cAtt_Detail_Interface: ',cAtt_Detail_Interface);
         ec_debug.pl(3,'cAtt_Seq_Num: '         ,cAtt_Seq_Num);
         ec_debug.pl(3,'cEntity_Name: '         ,cEntity_Name);
         ec_debug.pl(3,'cName: '                ,cName);
         ec_debug.pl(3,'cPK1_Value: '           ,cPK1_Value);
         ec_debug.pl(3,'cPK2_Value: '           ,cPK2_Value);
         ec_debug.pl(3,'cPK3_Value: '           ,cPK3_Value);
         ec_debug.pl(3,'cPK4_Value: '           ,cPK4_Value);
         ec_debug.pl(3,'cPK5_Value: '           ,cPK5_Value);
         ec_debug.pl(3,'cData_Type_ID: '        ,cData_Type_ID);
         ec_debug.pl(3,'cSegment_Size: '        ,cSegment_Size);
         ec_debug.pl(3,'cAtt_doc_id: '          ,cAtt_doc_id);
         end if;

         fnd_profile.get('ECE_ATT_SPLIT_WORD_ALLOWED',v_split_word);
         v_split_word := NVL(v_split_word,'Y');
         ec_debug.pl(3,'v_split_word: ',v_split_word);

         xProgress := 'POOB-70-1000';
         if (l_att_detail_tbl.count = 0) then
         	ece_flatfile_pvt.init_table(cTransaction_Type,cAtt_Detail_Interface,cDetail_Output_Level,TRUE,l_att_detail_tbl,l_key_tbl);

	 end if;

         xProgress := 'POOB-70-1010';
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'ATT_SEQ_NUM',          n_att_seq_num_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'ENTITY_NAME',          n_entity_name_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'NAME',                 n_name_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'PK1_VALUE',            n_pk1_value_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'PK2_VALUE',            n_pk2_value_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'PK3_VALUE',            n_pk3_value_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'PK4_VALUE',            n_pk4_value_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'PK5_VALUE',            n_pk5_value_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'SEGMENT_NUMBER',       n_seg_num_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'CONTINUE_FLAG' ,       n_cont_flag_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'ATTACHMENT_SEGMENT',   n_att_seg_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'RUN_ID',               n_run_id_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'TRANSACTION_RECORD_ID',n_transaction_record_id_pos);
         ece_flatfile_pvt.find_pos(l_att_detail_tbl,'ATTACHED_DOCUMENT_ID', n_att_doc_id_pos); --Bug2187958
         xProgress := 'POOB-70-1020';
         -- Build the SELECT Clause.
         ece_extract_utils_pub.select_clause(cTransaction_Type,
                                             cCommunication_Method,
                                             cAtt_Detail_Interface ,
                                             l_att_detail_tbl,
                                             v_att_detail_select,
                                             v_att_detail_from,
                                             v_att_detail_where);

         IF cData_Type_ID = 1 THEN     -- Short Text
            v_att_detail_select := v_att_detail_select || ',short_text';
         ELSE
            v_att_detail_select := v_att_detail_select || ',long_text';
         END IF;

         xProgress := 'POOB-70-1030';
         -- Build the WHERE and the ORDER BY Clause.
         -- Entity Name must not be NULL.
         v_att_detail_where := v_att_detail_where ||
                               v_att_view_name    || '.entity_name = :cEntity_name';

         xProgress := 'POOB-70-1040';
         -- Name must not be NULL.
         v_att_detail_where := v_att_detail_where || ' AND UPPER(' ||
                               v_att_view_name    || '.category_name) = UPPER(:cName)';

         xProgress := 'POOB-70-1045';
         -- Attachment Sequence must not be NULL.
         v_att_detail_where := v_att_detail_where || ' AND ' ||
                               v_att_view_name    || '.att_seq_num = :cAtt_Seq_Num';

        --Attached document ID must not be null Bug 2187958
         v_att_detail_where := v_att_detail_where || ' AND ' ||
                               v_att_view_name    || '.attached_document_id = :cAtt_doc_id';

         xProgress := 'POOB-70-1050';
         -- PK1 Value must not be NULL.
         v_att_detail_where := v_att_detail_where || ' AND ' ||
                               v_att_view_name    || '.pk1_value = :cPK1_Value';

         xProgress := 'POOB-70-1060';
         /* IF cPK2_Value IS NOT NULL THEN
            xProgress := 'POOB-70-1070';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value = :cPK2_Value';
         ELSE  -- cPK2_Value IS NULL.
            xProgress := 'POOB-70-1080';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value IS NULL';
         END IF;*/
         -- BUG:5367903
         IF cPK2_Value IS NULL THEN
            xProgress := 'POOB-70-1070';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk2_value IS NULL';
         ELSE  -- cPK2_Value IS NOT NULL.
            xProgress := 'POOB-70-1080';
            IF CPK2_Value <> C_ANY_VALUE THEN
               v_att_detail_where := v_att_detail_where || ' AND ' ||
                                     v_att_view_name    || '.pk2_value = :cPK2_Value';
            END IF;
         END IF;

         xProgress := 'POOB-70-1090';
         IF cEntity_Name <> 'MTL_SYSTEM_ITEMS' then     -- 3550723
           /* IF cPK3_Value IS NOT NULL THEN
            xProgress := 'POOB-70-1100';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk3_value = :cPK3_Value';
           ELSE  -- cPK3_Value IS NULL.
            xProgress := 'POOB-70-1110';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk3_value IS NULL';
           END IF; */
           -- BUG:5367903

           IF cPK3_Value IS NULL THEN
              xProgress := 'POOB-70-1100';
              v_att_detail_where := v_att_detail_where || ' AND ' ||
                                    v_att_view_name    || '.pk3_value IS NULL';
           ELSE  -- cPK3_Value IS NOT NULL.
              xProgress := 'POOB-70-1110';
              IF CPK3_Value <> C_ANY_VALUE THEN
                 v_att_detail_where := v_att_detail_where || ' AND ' ||
                                       v_att_view_name    || '.pk3_value = :cPK3_Value';
              END IF;
           END IF;

           xProgress := 'POOB-70-1120';
           /*IF cPK4_Value IS NOT NULL THEN
            xProgress := 'POOB-70-1130';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk4_value = :cPK4_Value';
           ELSE  -- cPK4_Value IS NULL.
            xProgress := 'POOB-70-1140';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk4_value IS NULL';
           END IF;*/
           -- BUG:5367903
           IF cPK4_Value IS NULL THEN
              xProgress := 'POOB-70-1130';
              v_att_detail_where := v_att_detail_where || ' AND ' ||
                                    v_att_view_name    || '.pk4_value IS NULL';
           ELSE  -- cPK4_Value IS NOT NULL.
              xProgress := 'POOB-70-1140';
              IF CPK4_Value <> C_ANY_VALUE THEN
                 v_att_detail_where := v_att_detail_where || ' AND ' ||
                                       v_att_view_name    || '.pk4_value = :cPK4_Value';
              END IF;
           END IF;

           xProgress := 'POOB-70-1150';
           /* IF cPK5_Value IS NOT NULL THEN
            xProgress := 'POOB-70-1160';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk5_value = :cPK5_Value';
           ELSE  -- cPK5_Value IS NULL.
            xProgress := 'POOB-70-1170';
            v_att_detail_where := v_att_detail_where || ' AND ' ||
                                  v_att_view_name    || '.pk5_value IS NULL';
           END IF; */
           -- BUG:5367903
           IF cPK5_Value IS NULL THEN
              xProgress := 'POOB-70-1160';
              v_att_detail_where := v_att_detail_where || ' AND ' ||
                                    v_att_view_name    || '.pk5_value IS NULL';
           ELSE  -- cPK5_Value IS NOT NULL.
              xProgress := 'POOB-70-1170';
              IF CPK5_Value <> C_ANY_VALUE THEN
                 v_att_detail_where := v_att_detail_where || ' AND ' ||
                                       v_att_view_name    || '.pk5_value = :cPK5_Value';
              END IF;
           END IF;

         END IF;

         xProgress := 'POOB-70-1180';
         v_att_detail_where := v_att_detail_where || ' AND ' ||
                               v_att_view_name    || '.usage_type <> ''T''';
         --Bug 2187958
         xProgress := 'POOB-70-1190';
        /* v_att_detail_where := v_att_detail_where || ' ORDER BY ' ||
                               v_att_view_name    || '.att_seq_num';*/

        v_att_detail_where := v_att_detail_where || ' ORDER BY ' ||
                               v_att_view_name    || '.attached_document_id';

         -- Now we put all the clauses together.
         xProgress := 'POOB-70-1200';
         v_att_detail_select := v_att_detail_select || v_att_detail_from || v_att_detail_where;
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'v_att_detail_select: ',v_att_detail_select);
         end if;

         -- Open Cursor.
         xProgress := 'POOB-70-1210';
         n_att_detail_sel_c := dbms_sql.open_cursor;

         -- Parse Cursor.
         xProgress := 'POOB-70-1220';
         BEGIN
            xProgress := 'POOB-70-1230';
            dbms_sql.parse(n_att_detail_sel_c,v_att_detail_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,v_att_detail_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POOB-70-1240';
         dbms_sql.bind_variable(n_att_detail_sel_c,':cEntity_name',cEntity_name);

         xProgress := 'POOB-70-1250';
         dbms_sql.bind_variable(n_att_detail_sel_c,':cName',cName);

         xProgress := 'POOB-70-1255';
         dbms_sql.bind_variable(n_att_detail_sel_c,':cAtt_Seq_Num',cAtt_Seq_Num);

         xProgress := 'POOB-70-1258';
         dbms_sql.bind_variable(n_att_detail_sel_c,':cAtt_doc_id',cAtt_doc_id);

         xProgress := 'POOB-70-1260';
         dbms_sql.bind_variable(n_att_detail_sel_c,':cPK1_Value',cPK1_Value);

         xProgress := 'POOB-70-1270';
         /* IF cPK2_Value IS NOT NULL THEN */ -- BUG:5367903
         IF cPK2_Value IS NOT NULL AND cPK2_Value <> C_ANY_VALUE THEN
            dbms_sql.bind_variable(n_att_detail_sel_c,':cPK2_Value',cPK2_Value);
         END IF;

         IF cEntity_Name <> 'MTL_SYSTEM_ITEMS' then     -- 3550723
           xProgress := 'POOB-70-1280';
           /* IF cPK3_Value IS NOT NULL THEN */ -- BUG:5367903
           IF cPK3_Value IS NOT NULL AND cPK3_Value <> C_ANY_VALUE THEN
            dbms_sql.bind_variable(n_att_detail_sel_c,':cPK3_Value',cPK3_Value);
           END IF;

           xProgress := 'POOB-70-1290';
           /* IF cPK4_Value IS NOT NULL THEN */ -- BUG:5367903
           IF cPK4_Value IS NOT NULL AND cPK4_Value <> C_ANY_VALUE THEN
            dbms_sql.bind_variable(n_att_detail_sel_c,':cPK4_Value',cPK4_Value);
           END IF;

           xProgress := 'POOB-70-1300';
           /* IF cPK5_Value IS NOT NULL THEN */ -- BUG:5367903
           IF cPK5_Value IS NOT NULL AND cPK5_Value <> C_ANY_VALUE THEN
            dbms_sql.bind_variable(n_att_detail_sel_c,':cPK5_Value',cPK5_Value);
           END IF;
         END IF;

         -- Set Counter
         xProgress := 'POOB-70-1310';
         n_detail_count := l_att_detail_tbl.COUNT;
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'n_detail_count: ',n_detail_count);
         end if;

         -- Define Columns
         xProgress := 'POOB-70-1320';
         ece_flatfile_pvt.define_interface_column_type(n_att_detail_sel_c,
                                                       v_att_detail_select,
                                                       ece_extract_utils_pub.G_MAXCOLWIDTH,
                                                       l_att_detail_tbl);

         IF cData_Type_ID = 1 THEN -- Short Text
            xProgress := 'POOB-70-1330';
           /* dbms_sql.define_column(n_att_detail_sel_c,n_detail_count + 1,v_att_detail_select,ece_extract_utils_pub.G_MAXCOLWIDTH);*/
/*Bug 2153310.
  Increased the size to 2000 since the short text attachment can have
  2000 characters */
             dbms_sql.define_column(n_att_detail_sel_c,n_detail_count + 1,v_att_detail_select,2000);
         ELSE -- Long Text
            xProgress := 'POOB-70-1340';
            dbms_sql.define_column_long(n_att_detail_sel_c,n_detail_count + 1);
         END IF;

         -- Execute Cursor
         xProgress := 'POOB-70-1350';
         n_dummy := dbms_sql.execute(n_att_detail_sel_c);

         xProgress := 'POOB-70-1360';
         WHILE dbms_sql.fetch_rows(n_att_detail_sel_c) > 0 LOOP
            xProgress := 'POOB-70-1370';
            ec_debug.pl(3,'xProgress: ',xProgress);

            ece_flatfile_pvt.assign_column_value_to_tbl(n_att_detail_sel_c,l_att_detail_tbl);

            n_segment_number := 1;
            n_cur_pos        := 1;
            n_new_chunk_size := 0;

            xProgress := 'POOB-70-1380';
            if ec_debug.G_debug_level = 3 then
             ec_debug.pl(3,'xProgress: ',xProgress);
            end if;

            IF cData_Type_ID = 1 THEN -- Short Text
               xProgress := 'POOB-70-1390';
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'xProgress: ',xProgress);
              end if;

               dbms_sql.column_value(n_att_detail_sel_c,n_detail_count + 1,l_short_text);
               -- l_short_text := LTRIM(RTRIM(l_short_text));     -- Not using this one because white spaces at front may be intentional
               l_short_text := RTRIM(l_short_text);
            END IF;

            xProgress := 'POOB-70-1400';
            ec_debug.pl(3,'xProgress: ',xProgress);
            LOOP
               xProgress := 'POOB-70-1410';
               if ec_debug.G_debug_level = 3 then
                ec_debug.pl(3,'xProgress: ',xProgress);
               end if;
               n_pr_pos := 0; -- 3618073
               IF cData_Type_ID = 1 THEN -- Short Text
                  xProgress := 'POOB-70-1420';
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;

                  l_short_text := SUBSTRB(l_short_text,n_cur_pos);
                  n_short_text_length := LENGTH(l_short_text); -- bug 3310412
                  -- l_data_chunk := SUBSTRB(l_short_text,n_cur_pos,cSegment_Size);
                  l_data_chunk := SUBSTRB(l_short_text,1,cSegment_Size);

                  n_return_size := LENGTH(l_data_chunk);

                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'n_cur_pos: ',n_cur_pos);
                   ec_debug.pl(3,'n_return_size: ',n_return_size);
                   ec_debug.pl(3,'l_short_text: ',l_short_text);
                   ec_debug.pl(3,'l_data_chunk: ',l_data_chunk);
                  end if;
               ELSIF cData_Type_ID = 2 THEN -- Long Text
                  xProgress := 'POOB-70-1430';
                  if ec_debug.G_debug_level = 3 then
                  ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;

                  --                         Cursor(I)         ,Pos(I)            ,Len(I)       ,Offset(I)    ,Value(O)    ,Value Len(O)
                  dbms_sql.column_value_long(n_att_detail_sel_c,n_detail_count + 1,cSegment_Size,n_cur_pos - 1,l_data_chunk,n_return_size);
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'n_cur_pos: ',n_cur_pos);
                   ec_debug.pl(3,'n_return_size: ',n_return_size);
                   ec_debug.pl(3,'l_data_chunk: ',l_data_chunk);
                  end if;
               END IF;

               xProgress := 'POOB-70-1440';
               if ec_debug.G_debug_level = 3 then
                ec_debug.pl(3,'xProgress: ',xProgress);
               end if;
               EXIT WHEN (n_return_size = 0 AND cData_Type_ID = 2) OR (l_short_text IS NULL AND cData_Type_ID = 1);

               xProgress := 'POOB-70-1450';
              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'xProgress: ',xProgress);
              end if;

               v_continue_flag := 'Y';
               n_cr_pos := INSTR(l_data_chunk,c_local_chr_13);
               n_lf_pos := INSTR(l_data_chunk,c_local_chr_10);

              if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'n_cr_pos: ',n_cr_pos);
               ec_debug.pl(3,'n_lf_pos: ',n_lf_pos);
              end if;

               IF n_cr_pos = 0 AND n_lf_pos = 0 THEN -- There are no CR or CRLF in the chunk...
                  xProgress := 'POOB-70-1460';
                  if ec_debug.G_debug_level = 3 then
                  ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;

                  IF v_split_word = 'N' THEN -- No I am not allowed to split a word.
                     xProgress := 'POOB-70-1470';
                     if ec_debug.G_debug_level = 3 then
                     ec_debug.pl(3,'xProgress: ',xProgress);
                     end if;

                     v_last_char := SUBSTRB(l_data_chunk,n_return_size,1);

                     IF v_last_char NOT IN ('.',',',';','-',' ') THEN
                        xProgress := 'POOB-70-1480';
                        if ec_debug.G_debug_level = 3 then
                         ec_debug.pl(3,'xProgress: ',xProgress);
                        end if;

                        n_space_pos := INSTR(l_data_chunk,' ',-1,1);

                        IF n_space_pos <> 0 THEN --Space Character Found
                           xProgress := 'POOB-70-1490';
			-- bug 3310412
                  /*  if the return size is less than the allowed segment size*/
                  /*  return the whole text as word splitting is not possible */
			  if (n_return_size < cSegment_Size) then
 			    n_new_chunk_size := n_return_size;
			  else
                        /*  If remaining length of short text is equal to segment size */
			/*  return the whole text without splitting */
			    if (cData_Type_ID = 2 and (n_short_text_length = cSegment_size)) Then
			      n_new_chunk_size := n_return_size;
                        /* Else remaining length is greater than segment size */
			/* The last word is split */
			/* Print upto the last space character */
                            else
                              n_new_chunk_size := n_space_pos;
			    end if;
                           end if;
			   -- bug 3310412
			   l_data_chunk := SUBSTRB(l_data_chunk,1,n_new_chunk_size);

          	               if ec_debug.G_debug_level = 3 then
                            ec_debug.pl(3,'xProgress: ',xProgress);
                            ec_debug.pl(3,'n_new_chunk_size: ',n_new_chunk_size);
                           end if;
                        ELSE                     --Space Chacter Not Found
                           xProgress := 'POOB-70-1492';
                           n_new_chunk_size := n_return_size;
                           if ec_debug.G_debug_level = 3 then
                            ec_debug.pl(3,'xProgress: ',xProgress);
                            ec_debug.pl(3,'n_new_chunk_size: ',n_new_chunk_size);
                           end if;
                        END IF;
                     ELSE -- Whew, last character is a breakable character...
                        xProgress := 'POOB-70-1494';

                        n_new_chunk_size := n_return_size;
                        if ec_debug.G_debug_level = 3 then
                         ec_debug.pl(3,'xProgress: ',xProgress);
                         ec_debug.pl(3,'n_new_chunk_size: ',n_new_chunk_size);
                        end if;
                     END IF;
                  ELSE -- Yes I am allowed to split a word.
                     xProgress := 'POOB-70-1496';

                     n_new_chunk_size := n_return_size;
                     if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'xProgress: ',xProgress);
                      ec_debug.pl(3,'n_new_chunk_size: ',n_new_chunk_size);
                     end if;
                  END IF;

               ELSIF n_cr_pos = 1 OR n_lf_pos = 1 THEN -- This is a blank line...
                  xProgress := 'POOB-70-1500';
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;

                  IF n_cr_pos = 1 AND n_lf_pos = 2 THEN
                     xProgress := 'POOB-70-1510';
                     if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'xProgress: ',xProgress);
                     end if;

                     n_new_chunk_size := 2;
                     n_pr_pos := 0; -- 3618073
                  ELSE
                     xProgress := 'POOB-70-1520';
                     if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'xProgress: ',xProgress);
                     end if;
                     n_new_chunk_size := 1;
                     n_pr_pos := 0;  -- 3618073
                  END IF;

                  xProgress := 'POOB-70-1530';
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;
                  l_data_chunk := '';

               ELSIF n_cr_pos > 1 OR n_lf_pos > 1 THEN -- There is a CR or LF in the chunk...
                  xProgress := 'POOB-70-1540';
                 if ec_debug.G_debug_level = 3 then
                  ec_debug.pl(3,'xProgress: ',xProgress);
                 end if;

                  IF n_cr_pos > 1 THEN
                     xProgress := 'POOB-70-1550';
                     if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'xProgress: ',xProgress);
                     end if;

                     IF n_lf_pos = n_cr_pos + 1 THEN -- This is a CRLF combo...
                        xProgress := 'POOB-70-1560';
                        if ec_debug.G_debug_level = 3 then
                         ec_debug.pl(3,'xProgress: ',xProgress);
                        end if;
                        n_new_chunk_size := n_lf_pos;
                        n_pr_pos := 2; -- 3618073
                     ELSE -- This is CR only...
                        xProgress := 'POOB-70-1570';
                        if ec_debug.G_debug_level = 3 then
                         ec_debug.pl(3,'xProgress: ',xProgress);
                        end if;

                        n_new_chunk_size := n_cr_pos;
                        n_pr_pos := 1;  --3618073
                     END IF;
                  ELSE -- This is LF only
                     xProgress := 'POOB-70-1580';
                     if ec_debug.G_debug_level = 3 then
                      ec_debug.pl(3,'xProgress: ',xProgress);
                     end if;
                     n_new_chunk_size := n_lf_pos;
                     n_pr_pos := 1;
                  END IF;

                  xProgress := 'POOB-70-1590';

                  l_data_chunk := SUBSTRB(l_data_chunk,1,n_new_chunk_size-n_pr_pos); -- 3618073

                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                   ec_debug.pl(3,'n_new_chunk_size: ',n_new_chunk_size);
                   ec_debug.pl(3,'l_data_chunk: ',l_data_chunk);
                  end if;
               END IF;

               xProgress := 'POOB-70-1600';

               l_att_detail_tbl(n_att_seg_pos).value := l_data_chunk;

               l_att_detail_tbl(n_seg_num_pos).value := n_segment_number;

               if ec_debug.G_debug_level = 3 then
                ec_debug.pl(3,'xProgress: ',xProgress);
                ec_debug.pl(3,'l_data_chunk: ',l_data_chunk);
                ec_debug.pl(3,'n_new_chunk_size: ',n_new_chunk_size);
                ec_debug.pl(3,'n_segment_number: ',n_segment_number);
                ec_debug.pl(3,'n_cur_pos: ',n_cur_pos);
               end if;

               xProgress := 'POOB-70-1610';

               IF cData_Type_ID = 1 THEN    -- Short Text
                  n_cur_pos := n_new_chunk_size + 1;
               ELSIF cData_Type_ID = 2 THEN -- Long Text
                  n_cur_pos := n_cur_pos + n_new_chunk_size;
               END IF;

               n_segment_number := n_segment_number + 1;
               if ec_debug.G_debug_level = 3 then
                ec_debug.pl(3,'New n_cur_pos: ',n_cur_pos);
                ec_debug.pl(3,'n_segment_number: ',n_segment_number);
               end if;

               BEGIN
                  xProgress := 'POOB-70-1620';
                  ec_debug.pl(3,'xProgress: ',xProgress);

                  SELECT   ece_attachment_details_s.NEXTVAL INTO n_detail_fkey
                  FROM     DUAL;
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'n_detail_fkey: ',n_detail_fkey);
                  end if;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_ATTACHMENT_DETAILS_S');
               END;

               -- I have to execute the following few lines of code because, I have no way of knowing at this point
               -- whether to set the Continue Flag 'Y' or 'N' until I loop around to the top again. This is how I find
               -- out ahead of time what the answer will be.
               IF cData_Type_ID = 1 THEN -- Short Text
                  xProgress := 'POOB-70-1622';
                 if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                 end if;
                  l_temp_text := SUBSTRB(l_short_text,n_cur_pos);
               ELSIF cData_Type_ID = 2 THEN -- Long Text
                  xProgress := 'POOB-70-1623';
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;

                  dbms_sql.column_value_long(n_att_detail_sel_c,n_detail_count + 1,cSegment_Size,n_cur_pos - 1,l_temp_text,n_temp_return_size);
               END IF;

               IF (n_temp_return_size = 0 AND cData_Type_ID = 2) OR (l_temp_text IS NULL AND cData_Type_ID = 1) THEN
                  xProgress := 'POOB-70-1624';
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3,'xProgress: ',xProgress);
                  end if;
                  v_continue_flag := 'N';
               END IF;

               l_att_detail_tbl(n_cont_flag_pos).value := v_continue_flag;
               if ec_debug.G_debug_level = 3 then
                ec_debug.pl(3,'v_continue_flag: ',v_continue_flag);
               end if;

               xProgress := 'POOB-70-1625';
               ec_debug.pl(3,'xProgress: ',xProgress);
               l_att_detail_tbl(n_att_seq_num_pos).value := cAtt_Seq_Num;
               l_att_detail_tbl(n_entity_name_pos).value := cEntity_name;
               l_att_detail_tbl(n_name_pos).value        := cName;
               l_att_detail_tbl(n_pk1_value_pos).value   := cPK1_Value;
               l_att_detail_tbl(n_pk2_value_pos).value   := cPK2_Value;
               l_att_detail_tbl(n_pk3_value_pos).value   := cPK3_Value;
               l_att_detail_tbl(n_pk4_value_pos).value   := cPK4_Value;
               l_att_detail_tbl(n_pk5_value_pos).value   := cPK5_Value;
               l_att_detail_tbl(n_run_id_pos).value      := iRun_id;
               l_att_detail_tbl(n_att_doc_id_pos).value  := cAtt_doc_id;  --Bug 2187958
               xProgress := 'POOB-70-1630';
               ec_debug.pl(3,'xProgress: ',xProgress);
              /* ece_extract_utils_pub.insert_into_interface_tbl(
                  iRun_id,
                  cTransaction_Type,
                  cCommunication_Method,
                  cAtt_Detail_Interface,
                  l_att_detail_tbl,
                  n_detail_fkey); */
-- 2823215
		   ece_poo_transaction.write_to_file(cTransaction_Type,
                                                     cCommunication_Method,
                                                     cAtt_Detail_Interface,
                                                     l_att_detail_tbl,
                                                     iOutput_width,
                                                     iRun_id,
                                                     cFile_Common_Key,
                                                     n_detail_fkey);
-- 2823215
            END LOOP;

            -- populate_ext_att_detail();

         END LOOP;

         xProgress := 'POOB-70-1640';
         dbms_sql.close_cursor(n_att_detail_sel_c);

         if ec_debug.G_debug_level >= 2 then
          ec_debug.pop('ECE_POO_TRANSACTION.POPULATE_TEXT_ATT_DETAIL');
         end if;
      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END populate_text_att_detail;

   PROCEDURE put_att_to_output_table(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_Width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cHeader_Output_Level    IN NUMBER,
      cDetail_Output_Level    IN NUMBER,
      cHeader_Interface       IN VARCHAR2,
      cDetail_Interface       IN VARCHAR2,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cFile_Common_Key        IN VARCHAR2) IS

      xProgress                  VARCHAR2(80);

      l_header_tbl               ece_flatfile_pvt.Interface_tbl_type;

      c_header_common_key_name   VARCHAR2(40);

      nSeq_Num_pos               NUMBER;
      nSeq_Num                   NUMBER;
      nDoc_ID_pos                NUMBER;
      nDoc_ID                    NUMBER;
      nAtt_Doc_ID_pos            NUMBER;
      nAtt_Doc_ID                NUMBER;
      Header_sel_c               INTEGER;
      Header_del_c1              INTEGER;
      Header_del_c2              INTEGER;
      cHeader_select             VARCHAR2(32000);
      cHeader_from               VARCHAR2(32000);
      cHeader_where              VARCHAR2(32000);
      cHeader_delete1            VARCHAR2(32000);
      cHeader_delete2            VARCHAR2(32000);

      cHeader_X_Interface        VARCHAR2(50);

      iHeader_count              NUMBER;
      dummy                      INTEGER;
      rHeader_rowid              ROWID;
      rHeader_X_rowid            ROWID;
      get_no_rows                INTEGER;
      get_no_lrows                INTEGER;
      BEGIN
        if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO_TRANSACTION.PUT_ATT_TO_OUTPUT_TABLE');
         ec_debug.pl(3,'cEntity_Name: ',cEntity_Name);
         ec_debug.pl(3,'cName: ',       cName);
         ec_debug.pl(3,'cPK1_Value: ',  cPK1_Value);
         ec_debug.pl(3,'cPK2_Value: ',  cPK2_Value);
         ec_debug.pl(3,'cPK3_Value: ',  cPK3_Value);
         ec_debug.pl(3,'cPK4_Value: ',  cPK4_Value);
         ec_debug.pl(3,'cPK5_Value: ',  cPK5_Value);
        end if;

         xProgress := 'POOB-80-1000';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cHeader_Interface,
                                        cHeader_X_Interface,
                                        l_header_tbl,
                                        c_header_common_key_name,
                                        cHeader_select,
                                        cHeader_from,
                                        cHeader_where,
                                        cHeader_Output_Level);

         -- Build the WHERE and the ORDER BY Clause.
         cHeader_where := cHeader_where     || ' AND '      ||
                          cHeader_Interface || '.run_id = :Run_id';

         -- Entity Name must not be NULL.
         cHeader_where := cHeader_where     || ' AND '           ||
                          cHeader_Interface || '.entity_name = :Entity_Name';

         -- Name must not be NULL.
         cHeader_where := cHeader_where     || ' AND ' || 'UPPER(' ||
                          cHeader_Interface || '.name) =  UPPER(:Name)';

         -- PK1 Value must not be NULL.
         cHeader_where := cHeader_where     || ' AND ' ||
                          cHeader_Interface || '.pk1_value = :PK1_Value';

         IF cPK2_Value IS NOT NULL THEN
            xProgress := 'POOB-80-1010';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk2_value = :PK2_Value';
         ELSE  -- cPK2_Value IS NULL.
            xProgress := 'POOB-80-1020';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk2_value IS NULL';
         END IF;

         IF cPK3_Value IS NOT NULL THEN
            xProgress := 'POOB-80-1030';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk3_value = :PK3_Value';
         ELSE  -- cPK3_Value IS NULL.
            xProgress := 'POOB-80-1040';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk3_value IS NULL';
         END IF;

         IF cPK4_Value IS NOT NULL THEN
            xProgress := 'POOB-80-1050';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk4_value = :PK4_Value';
         ELSE  -- cPK4_Value IS NULL.
            xProgress := 'POOB-80-1060';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk4_value IS NULL';
         END IF;

         IF cPK5_Value IS NOT NULL THEN
            xProgress := 'POOB-80-1070';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk5_value = :PK5_Value';

         ELSE  -- cPK5_Value IS NULL.
            xProgress := 'POOB-80-1080';
            cHeader_where := cHeader_where     || ' AND ' ||
                             cHeader_Interface || '.pk5_value IS NULL';
         END IF;

/* Bug 1892253
If an item has an attachment  and if this
item is used in more than 1 PO while
extracting,then the attachment information
of the item will be repeated in ece_attachment_headers
n number of times if n number of POs with the same
item are extracted.
Added code to pick up no of rows having distinct
attachment data from ece_attachment_headers and
appended this number to the where condition.
*/



if centity_name = 'MTL_SYSTEM_ITEMS' then
begin
get_no_rows := 0;

select count(distinct(att_seq_num)) into get_no_rows
from ece_attachment_headers
where pk1_value = cPK1_value
and pk2_value = cPK2_value
and entity_name like 'MTL_SYSTEM_ITEMS';
get_no_rows:=get_no_rows+1;

exception
when others then null;
end;

            cHeader_where := cHeader_where     || ' AND ' ||
                              ' rownum < ' || get_no_rows;
end if;
/* 2279486
Get the attachments(attached_document_id) pertaining only to the corrresponding
release by using line id*/
if centity_name = 'PO_LINES' then
begin
get_no_lrows := 0;

select count(distinct(attached_document_id)) into get_no_lrows
from ece_attachment_headers
where pk1_value = cPK1_value
and entity_name like 'PO_LINES';

get_no_lrows:=get_no_lrows+1;

exception
when others then null;
end;

            cHeader_where := cHeader_where     || ' AND ' ||
                              ' rownum < ' || get_no_lrows;
end if;


-- Bug 2187958
     /*cHeader_where := cHeader_where        || ' ORDER BY ' ||
                          cHeader_Interface    || '.att_seq_num';*/

           cHeader_where := cHeader_where        || ' ORDER BY ' ||
                          cHeader_Interface      || '.attached_document_id';

         cHeader_select := cHeader_select      || ','       ||
                           cHeader_Interface   || '.rowid,' ||
                           cHeader_X_Interface || '.rowid ';

         -- Now form the complete SELECT SQL...
         cHeader_select := cHeader_select || cHeader_from || cHeader_where  || ' FOR UPDATE';
         ec_debug.pl(3,'cHeader_select: ',cHeader_select);

         -- Form DELETE SQL...
         cHeader_delete1    := 'DELETE FROM ' || cHeader_Interface || ' WHERE rowid = :col_rowid';

         -- Form DELETE SQL for the Extension Table...
         cHeader_delete2    := 'DELETE FROM ' || cHeader_X_Interface || ' WHERE rowid = :col_rowid';
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'cHeader_delete1: ',cHeader_delete1);
          ec_debug.pl(3,'cHeader_delete2: ',cHeader_delete2);
         end if;

         -- Open Cursors
         xProgress := 'POOB-80-1090';
         Header_sel_c  := dbms_sql.open_cursor;

         xProgress := 'POOB-80-1100';
         Header_del_c1 := dbms_sql.open_cursor;

         xProgress := 'POOB-80-1110';
         Header_del_c2 := dbms_sql.open_cursor;

         -- Parse the SELECT SQL
         BEGIN
            xProgress := 'POOB-80-1120';
            dbms_sql.parse(Header_sel_c,cHeader_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_select);
               app_exception.raise_exception;
         END;


         -- Parse the DELETE1 SQL
         BEGIN
            xProgress := 'POOB-80-1130';
            dbms_sql.parse(Header_del_c1,cHeader_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_delete1);
               app_exception.raise_exception;
         END;

         -- Parse the DELETE2 SQL
         BEGIN
            xProgress := 'POOB-80-1140';
            dbms_sql.parse(Header_del_c2,cHeader_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_delete2);
               app_exception.raise_exception;
         END;

         --Set Counter
         xProgress := 'POOB-80-1150';
         iHeader_count := l_header_tbl.COUNT;
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'iHeader_count: ',iHeader_count);
         end if;

         xProgress := 'POOB-80-1160';
         ece_flatfile_pvt.define_interface_column_type(Header_sel_c,
                                                       cHeader_select,
                                                       ece_flatfile_pvt.G_MaxColWidth,
                                                       l_header_tbl );

         xProgress := 'POOB-80-1170';
         dbms_sql.define_column_rowid(Header_sel_c,iHeader_count + 1,rHeader_rowid);

         xProgress := 'POOB-80-1180';
         dbms_sql.define_column_rowid(Header_sel_c,iHeader_count + 2,rHeader_X_rowid);

-- Bug 2198707
         dbms_sql.bind_variable(Header_sel_c,'Run_id',iRun_id);
         dbms_sql.bind_variable(Header_sel_c,'Entity_Name',cEntity_Name);
         dbms_sql.bind_variable(Header_sel_c,'Name',cName);
         dbms_sql.bind_variable(Header_sel_c,'PK1_Value',cPK1_Value);
	IF cPK2_Value IS NOT NULL THEN
         dbms_sql.bind_variable(Header_sel_c,'PK2_Value',cPK2_Value);
	END IF;
	IF cPK3_Value IS NOT NULL THEN
         dbms_sql.bind_variable(Header_sel_c,'PK3_Value',cPK3_Value);
	END IF;
	IF cPK4_Value IS NOT NULL THEN
         dbms_sql.bind_variable(Header_sel_c,'PK4_Value',cPK4_Value);
	END IF;
	IF cPK5_Value IS NOT NULL THEN
         dbms_sql.bind_variable(Header_sel_c,'PK5_Value',cPK5_Value);
	END IF;
         --Execute the Cursor
         xProgress := 'POOB-80-1190';
         dummy := dbms_sql.execute(Header_sel_c);

         xProgress := 'POOB-80-1200';
         WHILE dbms_sql.fetch_rows(Header_sel_c) > 0 LOOP
            xProgress := 'POOB-80-1210';
            ece_flatfile_pvt.assign_column_value_to_tbl(Header_sel_c,l_header_tbl);

            xProgress := 'POOB-80-1220';
            dbms_sql.column_value(Header_sel_c,iHeader_count + 1,rHeader_rowid);

            xProgress := 'POOB-80-1230';
            dbms_sql.column_value(Header_sel_c,iHeader_count + 2,rHeader_X_rowid);

            -- Find the Position of the Attachemnt Doc ID
            xProgress := 'POOB-80-1232';
            ece_flatfile_pvt.find_pos(l_header_tbl,'DOCUMENT_ID',nDoc_ID_pos);
            nDoc_ID := l_header_tbl(nDoc_ID_pos).value;

            -- Find the Position of the Attachment Sequence Number
            xProgress := 'POOB-80-1240';
            ece_flatfile_pvt.find_pos(l_header_tbl,'ATT_SEQ_NUM',nSeq_Num_pos);
            -- Get the Attachment Sequence Number itself.
            nSeq_Num := l_header_tbl(nSeq_Num_pos).value;
-- Bug 2187958
            ece_flatfile_pvt.find_pos(l_header_tbl,'ATTACHED_DOCUMENT_ID',nAtt_Doc_ID);
            -- Get the Attachment Document ID
            nAtt_Doc_ID := l_header_tbl(nAtt_Doc_ID).value;

            if ec_debug.G_debug_level = 3 then
             ec_debug.pl(3,'nDoc_ID_pos: ',nDoc_ID_pos);
             ec_debug.pl(3,'nDoc_ID: '    ,nDoc_ID);
             ec_debug.pl(3,'nSeq_Num: ',nSeq_Num);
             ec_debug.pl(3,'nAtt_Doc_ID: ',nAtt_Doc_ID);
            end if;

            xProgress := 'POOB-80-1250';
            ece_poo_transaction.write_to_file(cTransaction_Type,
                                              cCommunication_Method,
                                              cHeader_Interface,
                                              l_header_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              cFile_Common_Key,
                                              null);

            xProgress := 'POOB-80-1260';
            dbms_sql.bind_variable(Header_del_c1,'col_rowid',rHeader_rowid);

            xProgress := 'POOB-80-1270';
            dbms_sql.bind_variable(Header_del_c2,'col_rowid',rHeader_X_rowid);

            -- Execute the Cursor that deletes from the Interface Table
            xProgress := 'POOB-80-1280';
            dummy := dbms_sql.execute(Header_del_c1);

            -- Execute the Cursor that deletes from the Extension Table
            xProgress := 'POOB-80-1290';
            dummy := dbms_sql.execute(Header_del_c2);

            xProgress := 'POOB-80-1300';
            put_att_detail_to_output_table(cCommunication_Method,
                                           cTransaction_Type,
                                           iOutput_width,
                                           iRun_id,
                                           cDetail_Output_Level,
                                           cHeader_Interface,
                                           cDetail_Interface,
                                           nSeq_Num,
                                           cEntity_Name,
                                           cName,
                                           cPK1_Value,
                                           cPK2_Value,
                                           cPK3_Value,
                                           cPK4_Value,
                                           cPK5_Value,
                                           cFile_Common_Key,
                                           nAtt_Doc_ID );
         END LOOP;

         -- Close the Cursors and Cleanup...
         xProgress := 'POOB-80-1310';
         dbms_sql.close_cursor(Header_sel_c);
         dbms_sql.close_cursor(Header_del_c1);
         dbms_sql.close_cursor(Header_del_c2);
        if ec_debug.G_debug_level >= 2 then
         ec_debug.pop ('ECE_POO_TRANSACTION.PUT_ATT_TO_OUTPUT_TABLE');
        end if;
      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END put_att_to_output_table;

   PROCEDURE put_att_detail_to_output_table(
      cCommunication_Method   IN VARCHAR2,
      cTransaction_Type       IN VARCHAR2,
      iOutput_Width           IN INTEGER,
      iRun_id                 IN INTEGER,
      cDetail_Output_Level    IN NUMBER,
      cHeader_Interface       IN VARCHAR2,
      cDetail_Interface       IN VARCHAR2,
      cAtt_Seq_Num            IN NUMBER,
      cEntity_Name            IN VARCHAR2,
      cName                   IN VARCHAR2,
      cPK1_Value              IN VARCHAR2,
      cPK2_Value              IN VARCHAR2,
      cPK3_Value              IN VARCHAR2,
      cPK4_Value              IN VARCHAR2,
      cPK5_Value              IN VARCHAR2,
      cFile_Common_Key        IN VARCHAR2,
      cAtt_Doc_ID             IN NUMBER) IS

      xProgress                  VARCHAR2(80);

      l_detail_tbl               ece_flatfile_pvt.Interface_tbl_type;

      c_detail_common_key_name   VARCHAR2(40);

      Detail_sel_c               INTEGER;
      Detail_del_c1              INTEGER;
      Detail_del_c2              INTEGER;
      cDetail_select             VARCHAR2(32000);
      cDetail_from               VARCHAR2(32000);
      cDetail_where              VARCHAR2(32000);
      cDetail_delete1            VARCHAR2(32000);
      cDetail_delete2            VARCHAR2(32000);

      cDetail_X_Interface        VARCHAR2(50);

      iDetail_count              NUMBER;
      dummy                      INTEGER;
      rDetail_rowid              ROWID;
      rDetail_X_rowid            ROWID;
      get_no_rows                INTEGER;      -- Bug 1892253
      get_no_lrows               INTEGER;
      BEGIN
        if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_POO_TRANSACTION.PUT_ATT_DETAIL_TO_OUTPUT_TABLE');
         ec_debug.pl(3,'cDetail_Output_Level: ',cDetail_Output_Level);
         ec_debug.pl(3,'cAtt_Seq_Num: ',        cAtt_Seq_Num);
         ec_debug.pl(3,'cEntity_Name: ',        cEntity_Name);
         ec_debug.pl(3,'cName: ',               cName);
         ec_debug.pl(3,'cPK1_Value: ',          cPK1_Value);
         ec_debug.pl(3,'cPK2_Value: ',          cPK2_Value);
         ec_debug.pl(3,'cPK3_Value: ',          cPK3_Value);
         ec_debug.pl(3,'cPK4_Value: ',          cPK4_Value);
         ec_debug.pl(3,'cPK5_Value: ',          cPK5_Value);
         ec_debug.pl(3,'cFile_Common_Key: ',      cFile_Common_Key);
         ec_debug.pl(3,'cAtt_Doc_ID: ' ,cAtt_Doc_ID);
        end if;

         xProgress := 'POOB-90-1000';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cDetail_Interface,
                                        cDetail_X_Interface,
                                        l_detail_tbl,
                                        c_detail_common_key_name,
                                        cDetail_select,
                                        cDetail_from,
                                        cDetail_where,
                                        cDetail_Output_Level);

         -- Build the WHERE and the ORDER BY Clause.
         xProgress := 'POOB-90-1010';
         cDetail_where := cDetail_where     || ' AND '              ||
                          cDetail_Interface || '.run_id = :iRun_id';

         -- Get the right Attachment Sequence.
         xProgress := 'POOB-90-1012';
         cDetail_where := cDetail_where     || ' AND '      ||
                          cDetail_Interface || '.att_seq_num = :cAtt_Seq_Num';
-- Bug 2187958
         -- Get the Attachment document ID.
         xProgress := 'POOB-90-1012A';
         cDetail_where := cDetail_where     || ' AND '      ||
                          cDetail_Interface || '.attached_document_id = :cAtt_Doc_ID';


         -- Entity Name must not be NULL.
         xProgress := 'POOB-90-1014';
         cDetail_where := cDetail_where     || ' AND '              ||
                          cDetail_Interface || '.entity_name = :cEntity_Name';

         -- Name must not be NULL.
         xProgress := 'POOB-90-1016';
         cDetail_where := cDetail_where     || ' AND ' || 'UPPER('  ||
                          cDetail_Interface || '.name) = UPPER(:cName)';

         -- PK1 Value must not be NULL.
         xProgress := 'POOB-90-1018';
         cDetail_where := cDetail_where     || ' AND '              ||
                          cDetail_Interface || '.pk1_value = :cPK1_Value';

         xProgress := 'POOB-90-1020';
         IF cPK2_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1030';
            cDetail_where := cDetail_where     || ' AND '              ||
                             cDetail_Interface || '.pk2_value = :cPK2_Value';
         ELSE  -- cPK2_Value IS NULL.
            xProgress := 'POOB-90-1040';
            cDetail_where := cDetail_where     || ' AND ' ||
                             cDetail_Interface || '.pk2_value IS NULL';
         END IF;

         IF cPK3_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1050';
            cDetail_where := cDetail_where     || ' AND '              ||
                             cDetail_Interface || '.pk3_value = :cPK3_Value';
         ELSE  -- cPK3_Value IS NULL.
            xProgress := 'POOB-90-1060';
            cDetail_where := cDetail_where     || ' AND ' ||
                             cDetail_Interface || '.pk3_value IS NULL';
         END IF;

         IF cPK4_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1070';
            cDetail_where := cDetail_where     || ' AND '              ||
                             cDetail_Interface || '.pk4_value = :cPK4_Value';
         ELSE  -- cPK4_Value IS NULL.
            xProgress := 'POOB-90-1080';
            cDetail_where := cDetail_where     || ' AND ' ||
                             cDetail_Interface || '.pk4_value IS NULL';
         END IF;

         IF cPK5_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1090';
            cDetail_where := cDetail_where     || ' AND '              ||
                             cDetail_Interface || '.pk5_value = :cPK5_Value';
         ELSE  -- cPK5_Value IS NULL.
            xProgress := 'POOB-90-1100';
            cDetail_where := cDetail_where     || ' AND ' ||
                             cDetail_Interface || '.pk5_value IS NULL';
         END IF;

/* Bug 1892253.
   Added query to pick the number of segments
   based on pk2_value,pk1_value and sequence
   number and append the no of segments obtained
   to cDetail_where condition
*/

if centity_name = 'MTL_SYSTEM_ITEMS' then
get_no_rows:=0;
begin

select max(segment_number) into get_no_rows
from ece_attachment_details
where pk1_value = cPK1_value
and pk2_value = cPK2_value
and entity_name like 'MTL_SYSTEM_ITEMS'
and attached_document_id = catt_doc_id;

get_no_rows := get_no_rows + 1;

exception
when others then null;
end;

     cDetail_where := cDetail_where     || ' AND ' ||
                             ' rownum <  ' || get_no_rows;
end if;
/* 2279486
Get the no of detailed line attachments pertaining only to the corrresponding
release by using line id and attached_document_id*/


if centity_name = 'PO_LINES' then
begin
get_no_lrows := 0;

select count(distinct(segment_number)) into get_no_lrows
from ece_attachment_details
where pk1_value = cPK1_value
and entity_name like 'PO_LINES'
and attached_document_id = catt_doc_id;

get_no_lrows:=get_no_lrows+1;

exception
when others then null;
end;

            cDetail_where := cDetail_where     || ' AND ' ||
                              ' rownum < ' || get_no_lrows;
end if;



         cDetail_where := cDetail_where        || ' ORDER BY ' ||
                          cDetail_Interface    || '.segment_number';

         cDetail_select := cDetail_select      || ', '       ||
                           cDetail_Interface   || '.rowid, ' ||
                           cDetail_X_Interface || '.rowid ';

         -- Now form the complete SELECT SQL...
         cDetail_select := cDetail_select || cDetail_from || cDetail_where  || ' FOR UPDATE';

         -- Form DELETE SQL...
         cDetail_delete1    := 'DELETE FROM ' || cDetail_Interface || ' WHERE rowid = :col_rowid';

         -- Form DELETE SQL for the Extension Table...
         cDetail_delete2    := 'DELETE FROM ' || cDetail_X_Interface || ' WHERE rowid = :col_rowid';
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'cDetail_select: ',cDetail_select);
          ec_debug.pl(3,'cDetail_delete1: ',cDetail_delete1);
          ec_debug.pl(3,'cDetail_delete2: ',cDetail_delete2);
         end if;

         -- Open Cursors
         xProgress := 'POOB-90-1110';
         Detail_sel_c  := dbms_sql.open_cursor;

         xProgress := 'POOB-90-1120';
         Detail_del_c1 := dbms_sql.open_cursor;

         xProgress := 'POOB-90-1130';
         Detail_del_c2 := dbms_sql.open_cursor;

         -- Parse the SELECT SQL
         BEGIN
            xProgress := 'POOB-90-1140';
            dbms_sql.parse(Detail_sel_c,cDetail_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cDetail_select);
               app_exception.raise_exception;
         END;

         -- Parse the DELETE1 SQL
         BEGIN
            xProgress := 'POOB-90-1150';
            dbms_sql.parse(Detail_del_c1,cDetail_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cDetail_delete1);
               app_exception.raise_exception;
         END;

         -- Parse the DELETE2 SQL
         BEGIN
            xProgress := 'POOB-90-1160';
            dbms_sql.parse(Detail_del_c2,cDetail_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cDetail_delete2);
               app_exception.raise_exception;
         END;

         --Set Counter
         xProgress := 'POOB-90-1170';
         iDetail_count := l_detail_tbl.COUNT;
         if ec_debug.G_debug_level = 3 then
          ec_debug.pl(3,'iDetail_count: ',iDetail_count);
         end if;

         xProgress := 'POOB-90-1180';
         ece_flatfile_pvt.define_interface_column_type(Detail_sel_c,
                                                       cDetail_select,
                                                       ece_flatfile_pvt.G_MaxColWidth,
                                                       l_detail_tbl);

         xProgress := 'POOB-90-1190';
         dbms_sql.define_column_rowid(Detail_sel_c,iDetail_count + 1,rDetail_rowid);

         xProgress := 'POOB-90-1200';
         dbms_sql.define_column_rowid(Detail_sel_c,iDetail_count + 2,rDetail_X_rowid);

         --Bind Variables
         xProgress := 'POOB-90-1201';
         dbms_sql.bind_variable(Detail_sel_c,':iRun_id',iRun_id);

         xProgress := 'POOB-90-1202';
         dbms_sql.bind_variable(Detail_sel_c,':cAtt_Seq_Num',cAtt_Seq_Num);

        xProgress := 'POOB-90-1202a';
        dbms_sql.bind_variable(Detail_sel_c,':cAtt_Doc_ID',cAtt_Doc_ID);

         xProgress := 'POOB-90-1203';
         dbms_sql.bind_variable(Detail_sel_c,':cEntity_Name',cEntity_Name);

         xProgress := 'POOB-90-1204';
         dbms_sql.bind_variable(Detail_sel_c,':cName',cName);

         xProgress := 'POOB-90-1205';
         dbms_sql.bind_variable(Detail_sel_c,':cPK1_Value',cPK1_Value);

         IF cPK2_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1206';
            dbms_sql.bind_variable(Detail_sel_c,':cPK2_Value',cPK2_Value);
         END IF;

         IF cPK3_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1207';
            dbms_sql.bind_variable(Detail_sel_c,':cPK3_Value',cPK3_Value);
         END IF;

         IF cPK4_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1208';
            dbms_sql.bind_variable(Detail_sel_c,':cPK4_Value',cPK4_Value);
         END IF;

         IF cPK5_Value IS NOT NULL THEN
            xProgress := 'POOB-90-1209';
            dbms_sql.bind_variable(Detail_sel_c,':cPK5_Value',cPK5_Value);
         END IF;

         --Execute the Cursor
         xProgress := 'POOB-90-1210';
         dummy := dbms_sql.execute(Detail_sel_c);

         xProgress := 'POOB-90-1220';
         WHILE dbms_sql.fetch_rows(Detail_sel_c) > 0 LOOP
            xProgress := 'POOB-90-1230';
            ece_flatfile_pvt.assign_column_value_to_tbl(Detail_sel_c,l_detail_tbl);

            xProgress := 'POOB-90-1240';
            dbms_sql.column_value(Detail_sel_c,iDetail_count + 1,rDetail_rowid);

            xProgress := 'POOB-90-1250';
            dbms_sql.column_value(Detail_sel_c,iDetail_count + 2,rDetail_X_rowid);

            xProgress := 'POOB-90-1260';
            ece_poo_transaction.write_to_file(cTransaction_Type,
                                              cCommunication_Method,
                                              cDetail_Interface,
                                              l_detail_tbl,
                                              iOutput_width,
                                              iRun_id,
                                              cFile_Common_Key,
                                              null);

            xProgress := 'POOB-90-1270';
            dbms_sql.bind_variable(Detail_del_c1,'col_rowid',rDetail_rowid);

            xProgress := 'POOB-90-1280';
            dbms_sql.bind_variable(Detail_del_c2,'col_rowid',rDetail_X_rowid);

            -- Execute the Cursor that deletes from the Interface Table
            xProgress := 'POOB-90-1290';
            dummy := dbms_sql.execute(Detail_del_c1);

            -- Execute the Cursor that deletes from the Extension Table
            xProgress := 'POOB-90-1300';
            dummy := dbms_sql.execute(Detail_del_c2);
         END LOOP;

         -- Close the Cursors and Cleanup...
         xProgress := 'POOB-90-1310';
         dbms_sql.close_cursor(Detail_sel_c);
         dbms_sql.close_cursor(Detail_del_c1);
         dbms_sql.close_cursor(Detail_del_c2);
         if ec_debug.G_debug_level >= 2 then
          ec_debug.pop ('ECE_POO_TRANSACTION.PUT_ATT_DETAIL_TO_OUTPUT_TABLE');
         end if;
      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END put_att_detail_to_output_table;


       PROCEDURE write_to_file(
         cTransaction_Type       IN VARCHAR2,
         cCommunication_Method   IN VARCHAR2,
         cInterface_Table        IN VARCHAR2,
         p_Interface_tbl         IN ece_flatfile_pvt.Interface_tbl_type,
         iOutput_width           IN INTEGER,
         iRun_id                 IN INTEGER,
         p_common_key            IN VARCHAR2,
         p_foreign_key           IN NUMBER) IS

         xProgress               VARCHAR2(30);
         cOutput_path            VARCHAR2(120);
         iLine_pos               INTEGER;
         iData_count             INTEGER          := p_Interface_tbl.COUNT;
         iStart_num              INTEGER;
         iRow_num                INTEGER;
         cInsert_stmt            VARCHAR2(32000);
         l_common_key            VARCHAR2(255)    := p_common_key;
         l_count                 NUMBER;
	 cValue		         VARCHAR2(32000);
	 cSrc_tbl_val_wo_newl    VARCHAR2(32000);
         cSrc_tbl_val_wo_frmf    VARCHAR2(32000);
         cSrc_tbl_val_wo_tab     VARCHAR2(32000);
	 c_local_chr_10       VARCHAR2(1) := fnd_global.local_chr(10);
         c_local_chr_13       VARCHAR2(1) := fnd_global.local_chr(13);
         c_local_chr_9        VARCHAR2(1) := fnd_global.local_chr(9);


         BEGIN
	if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.push('ECE_POO_TRANSACTION.WRITE_TO_FILE');
	end if;
            xProgress := 'POOB-WR-1020';
            FOR i IN 1..iData_count LOOP
               xProgress := 'POOB-WR-1030';
               l_count := i;
               xProgress := 'POOB-WR-1040';
               IF p_Interface_tbl(i).Record_num IS NOT NULL AND
                  p_Interface_tbl(i).position IS NOT NULL AND
                  p_Interface_tbl(i).data_length IS NOT NULL THEN
                  xProgress := 'POOB-WR-1050';
                  iRow_num := i;
                  if EC_DEBUG.G_debug_level >= 3 then
                  ec_debug.pl(3,'iRow_num : ',iRow_num);
                  end if;
                  xProgress := 'POOB-WR-1060';
               IF p_Interface_tbl(i).interface_column_name = 'RUN_ID' THEN
                  cValue := iRun_id;
               elsif
                  p_Interface_tbl(i).interface_column_name =
                                                'TRANSACTION_RECORD_ID' THEN
                  cValue := p_foreign_key;
               else
                cSrc_tbl_val_wo_newl :=
                replace(p_Interface_tbl(i).value, c_local_chr_10,'');
                cSrc_tbl_val_wo_frmf :=
                replace(cSrc_tbl_val_wo_newl, c_local_chr_13,'');
                cSrc_tbl_val_wo_tab  :=
                replace(cSrc_tbl_val_wo_frmf, c_local_chr_9,'');
		 cValue := cSrc_tbl_val_wo_tab;
               end if;

                  cInsert_stmt := cInsert_stmt || substrb(rpad(nvl(cValue,' '),
                                  TO_CHAR(p_Interface_tbl(i).data_length),' '),1,
                                  p_Interface_tbl(i).data_length);

                  -- ******************************************************
                  -- the following two lines is for testing/debug purpose
                  -- ******************************************************
                  -- cInsert_stmt := cInsert_stmt || rpad(substrb(p_Interface_tbl(i).interface_column_name,1,p_Interface_tbl(i).data_length-2)||
                  -- substrb(TO_CHAR(p_Interface_tbl(i).data_length),1,2), TO_CHAR(p_Interface_tbl(i).data_length),' ');
               END IF;

               xProgress := 'POOB-WR-1070';
               IF i < iData_count THEN
                  xProgress := 'POOB-WR-1080';
                  IF p_Interface_tbl(i).Record_num <> p_Interface_tbl(i+1).Record_num THEN
                     xProgress := 'POOB-WR-1090';
                     cInsert_stmt := l_common_key || LPAD(NVL(p_Interface_tbl(iRow_num).Record_num,0),4,'0') ||
                                                     RPAD(NVL(p_Interface_tbl(iRow_num).layout_code,' '),2) ||
                                                     RPAD(NVL(p_Interface_tbl(iRow_num).record_qualifier,' '),3) || cInsert_stmt;

                     xProgress := 'POOB-WR-1100';
                      utl_file.put_line(ece_poo_transaction.uFile_type,cInsert_stmt);
                        xProgress := 'POOB-WR-1110';
                        cInsert_stmt := NULL;
                        -- cInsert_stmt := '*' || TO_CHAR(p_Interface_tbl(i).Record_num);
                  END IF;
               ELSE
                  xProgress := 'POOB-WR-1120';
                 /* Bug# 2108977 :- Added the following codition to prevent NULL records from causing
                                    erros */

                 IF iRow_num IS NOT NULL THEN
                  cInsert_stmt := l_common_key || LPAD(NVL(p_Interface_tbl(iRow_num).Record_num,0),4,'0') ||
                                                  RPAD(NVL(p_Interface_tbl(iRow_num).layout_code,' '),2) ||
                                                  RPAD(NVL(p_Interface_tbl(iRow_num).record_qualifier,' '),3) || cInsert_stmt;

                  xProgress := 'POOB-WR-1130';
                   utl_file.put_line(ece_poo_transaction.uFile_type,cInsert_stmt);
                 END IF;
               END IF;
            END LOOP;

	if EC_DEBUG.G_debug_level >= 2 then
            ec_debug.pop('ECE_POO_TRANSACTION.WRITE_TO_FILE');
	end if;

         EXCEPTION
            WHEN utl_file.write_error THEN
             ec_debug.pl(0,'EC','ECE_UTL_WRITE_ERROR',NULL);
             ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
             app_exception.raise_exception;

            WHEN utl_file.invalid_path THEN
             ec_debug.pl(0,'EC','ECE_UTIL_INVALID_PATH',NULL);
             ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
             app_exception.raise_exception;

            WHEN utl_file.invalid_operation THEN
             ec_debug.pl(0,'EC','ECE_UTIL_INVALID_OPERATION',NULL);
             ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
             app_exception.raise_exception;

            WHEN OTHERS THEN
             ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL','ECE_POO_TRANSACTION.WRITE_TO_FILE');
             ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
             ec_debug.pl(0,'EC','ECE_ERROR_CODE','ERROR_CODE',SQLCODE);
             ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

             ec_debug.pl(0,'EC','ECE_PLSQL_POS_NOT_FOUND','COLUMN_NAME', 'to_char(l_count)');
             ec_debug.pl(0,'EC','ECE_PLSQL_VALUE','COLUMN_NAME', 'p_interface_tbl(l_count).value');
             ec_debug.pl(0,'EC','ECE_PLSQL_DATA_TYPE','COLUMN_NAME', 'p_interface_tbl(l_count).data_type');
             ec_debug.pl(0,'EC','ECE_PLSQL_COLUMN_NAME','COLUMN_NAME', 'p_interface_tbl(l_count).base_column');
             app_exception.raise_exception;

         END write_to_file;

END ECE_POO_TRANSACTION;


/
