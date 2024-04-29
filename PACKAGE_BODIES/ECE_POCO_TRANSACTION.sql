--------------------------------------------------------
--  DDL for Package Body ECE_POCO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_POCO_TRANSACTION" AS
-- $Header: ECPOCOB.pls 120.10.12010000.1 2008/07/25 07:25:44 appldev ship $
iOutput_width              INTEGER              :=  4000; -- 2823215
i_path                     VARCHAR2(1000);
i_filename                 VARCHAR2(1000);
   PROCEDURE extract_poco_outbound(errbuf            OUT NOCOPY VARCHAR2,
                                   retcode           OUT NOCOPY VARCHAR2,
                                   cOutput_Path      IN  VARCHAR2,
                                   cOutput_Filename  IN  VARCHAR2,
                                   cPO_Number_From   IN  VARCHAR2,
                                   cPO_Number_To     IN  VARCHAR2,
                                   cRDate_From       IN  VARCHAR2,
                                   cRDate_To         IN  VARCHAR2,
                                   cPC_Type          IN  VARCHAR2,
                                   cVendor_Name      IN  VARCHAR2,
                                   cVendor_Site_Code IN  VARCHAR2,
                                   v_debug_mode      IN  NUMBER DEFAULT 0) IS

      xProgress                  VARCHAR2(80);
      v_LevelProcessed           VARCHAR2(40);
      iRun_id                    NUMBER         := 0;
      iOutput_width              INTEGER        :=  4000;
      cTransaction_Type          VARCHAR2(120)  := 'POCO';
      cCommunication_Method      VARCHAR2(120)  := 'EDI';
      cHeader_Interface          VARCHAR2(120)  := 'ECE_PO_INTERFACE_HEADERS';
      cLine_Interface            VARCHAR2(120)  := 'ECE_PO_INTERFACE_LINES';
      cShipment_Interface        VARCHAR2(120)  := 'ECE_PO_INTERFACE_SHIPMENTS';
      cProject_Interface         VARCHAR2(120)  := 'ECE_PO_DISTRIBUTIONS'; -- Bug 1891291
      l_line_text                VARCHAR2(2000);
      cRevised_Date_From         DATE           := TO_DATE(cRDate_From,'YYYY/MM/DD HH24:MI:SS');
      cRevised_Date_To           DATE           := TO_DATE(cRDate_To,  'YYYY/MM/DD HH24:MI:SS') + 1;
      cEnabled                   VARCHAR2(1)    := 'Y';
      ece_transaction_disabled   EXCEPTION;
      xHeaderCount               NUMBER;
      cFilename                  VARCHAR2(30)        := NULL;  --2430822


      CURSOR c_output IS
         SELECT   text
         FROM     ece_output
         WHERE    run_id = iRun_id
         ORDER BY line_id;

      BEGIN
         xProgress := 'POCO-10-1000';
         ec_debug.enable_debug(v_debug_mode);
         ec_debug.push('ECE_POCO_TRANSACTION.EXTRACT_POCO_OUTBOUND' );
         ec_debug.pl(3,'cOutput_Path: ',     cOutput_Path );
         ec_debug.pl(3,'cOutput_Filename: ', cOutput_Filename );
         ec_debug.pl(3,'cPO_Number_From: ',  cPO_Number_From );
         ec_debug.pl(3,'cPO_Number_To: ',    cPO_Number_To );
         ec_debug.pl(3,'cRDate_From: ',      cRDate_From );
         ec_debug.pl(3,'cRDate_To: ',        cRDate_To );
         ec_debug.pl(3,'cPC_Type: ',         cPC_Type );
         ec_debug.pl(3,'cVendor_Name: ',     cVendor_Name );
         ec_debug.pl(3,'cVendor_Site_Code: ',cVendor_Site_Code );
         ec_debug.pl(3,'v_debug_mode: ',     v_debug_mode );

         /* Check to see if the transaction is enabled. If not, abort */
         xProgress := 'POCO-10-1001';
         fnd_profile.get('ECE_' || cTransaction_Type || '_ENABLED',cEnabled);

         xProgress := 'POCO-10-1002';
         IF cEnabled = 'N' THEN
            xProgress := 'POCO-10-1003';
            RAISE ece_transaction_disabled;
         END IF;

         xProgress := 'POCO-10-1004';
         BEGIN
            SELECT   ece_output_runs_s.NEXTVAL
            INTO     iRun_id
            FROM     DUAL;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_OUTPUT_RUNS_S');

         END;

         ec_debug.pl(3,'iRun_id: ',iRun_id);

         xProgress := 'POCO-10-1005';
         ec_debug.pl(0,'EC','ECE_POCO_START',NULL);

         xProgress := 'POCO-10-1010';
         ec_debug.pl(0,'EC','ECE_RUN_ID','RUN_ID',iRun_id);

	 ece_poo_transaction.project_sel_c:=0;               --Bug 2490109

	 IF cOutput_Filename IS NULL THEN		   --Bug 2430822
          cFilename := 'POCO' || iRun_id || '.dat';
	 ELSE
          cFilename := cOutput_Filename;
         END IF;

         	     -- Open the file for write.
         xProgress := 'POO-10-1040';
	 if ec_debug.G_debug_level = 1 then
	   ec_debug.pl(1,'Output File:',cFilename);
	   ec_debug.pl(1,'path --> ', cOutput_Path);
	--   ec_debug.pl(1,'Open Output file');            --Bug 2034376
         end if;
         i_path := cOutput_Path;
         i_filename := cFilename;
       -- ece_poo_transaction.uFile_type := utl_file.fopen(cOutput_Path,cFilename,'W',32767); --Bug 2887790

         xProgress := 'POCO-10-1020';
         ec_debug.pl(1,'Call Populate Poco Trx procedure');     --Bug 2034376
         ece_poco_transaction.populate_poco_trx(
            cCommunication_Method,
            cTransaction_Type,
            iOutput_width,
            SYSDATE,
            iRun_id,
            cHeader_Interface,
            cLine_Interface,
            cShipment_Interface,
            cProject_Interface,
            cRevised_Date_From,
            cRevised_Date_To,
            cVendor_Name,
            cVendor_Site_Code,
            cPC_Type,
            cPO_Number_From,
            cPO_Number_To);

   /*      xProgress := 'POCO-10-1030';
	 ec_debug.pl(1,'Call Put To Output Table procedure');   --Bug 2034376

         select count(*)
         into xHeaderCount
         from ECE_PO_INTERFACE_HEADERS
         where run_id = iRun_id;  */



-- 2823215

/*         ec_debug.pl(1,'NUMBER OF RECORDS PROCESSED IS ',xHeaderCount);
         ece_poco_transaction.put_data_to_output_table(
            cCommunication_Method,
            cTransaction_Type,
            iOutput_width,
            iRun_id,
            cHeader_Interface,
            cLine_Interface,
            cShipment_Interface,
            cProject_Interface); */

         xProgress := 'POCO-10-1090';
	 ec_debug.pl(1,'Close Output file');		--Bug 2034376
          if (utl_file.is_open(ece_poo_transaction.uFile_type)) then
              utl_file.fclose(ece_poo_transaction.uFile_type);
          end if;



      IF ec_mapping_utils.ec_get_trans_upgrade_status(cTransaction_Type)  = 'U' THEN
         ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
         retcode := 1;
      END IF;

         ec_debug.pop('ECE_POCO_TRANSACTION.EXTRACT_POCO_OUTBOUND');
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

      END extract_poco_outbound;

   PROCEDURE populate_poco_trx(cCommunication_Method   IN VARCHAR2,
                               cTransaction_Type       IN VARCHAR2,
                               iOutput_width           IN INTEGER,
                               dTransaction_date       IN DATE,
                               iRun_id                 IN INTEGER,
                               cHeader_Interface       IN VARCHAR2,
                               cLine_Interface         IN VARCHAR2,
                               cShipment_Interface     IN VARCHAR2,
                               cProject_Interface      IN VARCHAR2,
                               cRevised_Date_From      IN DATE,
                               cRevised_Date_To        IN DATE,
                               cSupplier_Name          IN VARCHAR2,
                               cSupplier_Site          IN VARCHAR2,
                               cDocument_Type          IN VARCHAR2,
                               cPO_Number_From         IN VARCHAR2,
                               cPO_Number_To           IN VARCHAR2) IS

      xProgress                  VARCHAR2(80);
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

      dummy                      INTEGER;
      n_trx_date_pos             NUMBER;
      nDocument_type_pos         NUMBER;
      nPO_Number_pos             NUMBER;
      nPO_Type_pos               NUMBER;
      nRelease_num_pos           NUMBER;
      nRelease_ID_pos            NUMBER;
      nLine_num_pos              NUMBER;
      nLine_Location_ID_pos      NUMBER;
      nShip_Line_Location_ID_pos NUMBER;
      nQuantity_pending_pos      NUMBER;
      nCancel_Flag_pos   NUMBER;
      nCancel_Date_pos   NUMBER;
      nCancel_Date_posl  NUMBER;
      l_document_type            VARCHAR2(30);
      nOrganization_ID           NUMBER;
      nItem_ID_pos               NUMBER;

      v_drop_ship_flag                  NUMBER;
      rec_order_line_info               OE_DROP_SHIP_GRP.Order_Line_Info_Rec_Type;   --2887790
      nHeader_Cancel_Flag_pos           NUMBER;
      nLine_Cancel_Flag_pos             NUMBER;
      nShipment_Cancel_Flag_pos         NUMBER;
      v_header_cancel_flag              VARCHAR2(10);
      v_line_cancel_flag                VARCHAR2(10);
      v_shipment_cancel_flag            VARCHAR2(10);

      nTrans_code_pos            NUMBER;        -- 2823215

      c_file_common_key          VARCHAR2(255);  -- 2823215

      -- Bug 2823215

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
      nHeader_cancel_date_pos     NUMBER;
      --Bug 2823215

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

      nShp_uom_pos                NUMBER;
      nLine_uom_pos               NUMBER;
      init_msg_list              VARCHAR2(20);
      simulate                   VARCHAR2(20);
      validation_level           VARCHAR2(20);
      commt                      VARCHAR2(20);
      return_status              VARCHAR2(20);
      msg_count                  NUMBER;
      msg_data                   VARCHAR2(2000);  -- 3650215

      cline_part_number          VARCHAR2(80);
      cline_part_attrib_category VARCHAR2(80);

      -- bug 6511409
      cline_part_attribute1      MTL_ITEM_FLEXFIELDS.ATTRIBUTE1%TYPE;
      cline_part_attribute2      MTL_ITEM_FLEXFIELDS.ATTRIBUTE2%TYPE;
      cline_part_attribute3      MTL_ITEM_FLEXFIELDS.ATTRIBUTE3%TYPE;
      cline_part_attribute4      MTL_ITEM_FLEXFIELDS.ATTRIBUTE4%TYPE;
      cline_part_attribute5      MTL_ITEM_FLEXFIELDS.ATTRIBUTE5%TYPE;
      cline_part_attribute6      MTL_ITEM_FLEXFIELDS.ATTRIBUTE6%TYPE;
      cline_part_attribute7      MTL_ITEM_FLEXFIELDS.ATTRIBUTE7%TYPE;
      cline_part_attribute8      MTL_ITEM_FLEXFIELDS.ATTRIBUTE8%TYPE;
      cline_part_attribute9      MTL_ITEM_FLEXFIELDS.ATTRIBUTE9%TYPE;
      cline_part_attribute10     MTL_ITEM_FLEXFIELDS.ATTRIBUTE10%TYPE;
      cline_part_attribute11     MTL_ITEM_FLEXFIELDS.ATTRIBUTE11%TYPE;
      cline_part_attribute12     MTL_ITEM_FLEXFIELDS.ATTRIBUTE12%TYPE;
      cline_part_attribute13     MTL_ITEM_FLEXFIELDS.ATTRIBUTE13%TYPE;
      cline_part_attribute14     MTL_ITEM_FLEXFIELDS.ATTRIBUTE14%TYPE;
      cline_part_attribute15     MTL_ITEM_FLEXFIELDS.ATTRIBUTE15%TYPE;

      d_dummy_date               DATE;
      counter                    NUMBER;
      cancel_flag_value          VARCHAR2(1);
      cancel_date_value          DATE;
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
         ec_debug.push('ECE_POCO_TRANSACTION.POPULATE_POCO_TRX');
         ec_debug.pl(3,'cCommunication_Method: ',cCommunication_Method);
         ec_debug.pl(3,'cTransaction_Type: '    ,cTransaction_Type);
         ec_debug.pl(3,'iOutput_width: '        ,iOutput_width);
         ec_debug.pl(3,'dTransaction_date: '    ,dTransaction_date);
         ec_debug.pl(3,'iRun_id: '              ,iRun_id);
         ec_debug.pl(3,'cHeader_Interface: '    ,cHeader_Interface);
         ec_debug.pl(3,'cLine_Interface: '      ,cLine_Interface);
         ec_debug.pl(3,'cShipment_Interface: '  ,cShipment_Interface);
         ec_debug.pl(3,'cProject_Interface: '   ,cProject_Interface);
         ec_debug.pl(3,'cRevised_Date_From: '   ,cRevised_Date_From);
         ec_debug.pl(3,'cRevised_Date_To: '     ,cRevised_Date_To);
         ec_debug.pl(3,'cSupplier_Name: '       ,cSupplier_Name);
         ec_debug.pl(3,'cSupplier_Site: '       ,cSupplier_Site);
         ec_debug.pl(3,'cDocument_Type: '       ,cDocument_Type);
         ec_debug.pl(3,'cPO_Number_From: '      ,cPO_Number_From);
         ec_debug.pl(3,'cPO_Number_To: '        ,cPO_Number_To);

         xProgress := 'POCOB-10-1000';
         BEGIN
            SELECT inventory_organization_id
            INTO   nOrganization_ID
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
                          'FINANCIALS_SYSTERM_PARAMETERS');
         END;
	      ec_debug.pl(3,'nOrganization_ID: ',nOrganization_ID);

         -- Let's See if Project Accounting is Installed
         xProgress := 'POCOB-10-1001';
         v_project_acct_installed := fnd_installation.get_app_info(
                                       v_project_acct_short_name, -- i.e. 'PA'
                                       v_project_acct_status,     -- 'I' means it's installed
                                       v_project_acct_industry,
                                       v_project_acct_schema);

         v_project_acct_status := NVL(v_project_acct_status,'X');
         ec_debug.pl(3,'v_project_acct_status: '  ,v_project_acct_status);
         ec_debug.pl(3,'v_project_acct_industry: ',v_project_acct_industry);
         ec_debug.pl(3,'v_project_acct_schema: '  ,v_project_acct_schema);

         -- Get Profile Option Values for Attachments
         xProgress := 'POCOB-10-1002';
         fnd_profile.get('ECE_' || cTransaction_Type || '_HEAD_ATT',v_header_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_LINE_ATT',v_line_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_MITEM_ATT',v_mitem_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_IITEM_ATT',v_iitem_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_SHIP_ATT',v_ship_att_enabled);
         fnd_profile.get('ECE_' || cTransaction_Type || '_ATT_SEG_SIZE',n_att_seg_size);

         -- Check to see if any attachments are enabled
         xProgress := 'POCOB-10-1004';
         IF NVL(v_header_att_enabled,'N') = 'Y' OR
            NVL(v_mitem_att_enabled,'N') = 'Y' OR
            NVL(v_iitem_att_enabled,'N') = 'Y' OR
            NVL(v_ship_att_enabled,'N') = 'Y' THEN
            v_att_enabled := 'Y';
         END IF;

         IF v_att_enabled = 'Y' THEN
            BEGIN
               IF n_att_seg_size < 1 OR n_att_seg_size > ece_poo_transaction.G_MAX_ATT_SEG_SIZE OR n_att_seg_size IS NULL THEN
                  RAISE invalid_number;
               END IF;

            EXCEPTION
               WHEN value_error OR invalid_number THEN
                  ec_debug.pl(0,'EC','ECE_INVALID_SEGMENT_NUM','SEGMENT_VALUE',n_att_seg_size,'SEGMENT_DEFAULT',ece_poo_transaction.G_DEFAULT_ATT_SEG_SIZE);
                  n_att_seg_size := ece_poo_transaction.G_DEFAULT_ATT_SEG_SIZE;
            END;
         END IF;

         ec_debug.pl(3,'v_header_att_enabled: ',v_header_att_enabled);
         ec_debug.pl(3,'v_line_att_enabled: '  ,v_line_att_enabled);
         ec_debug.pl(3,'v_mitem_att_enabled: ' ,v_mitem_att_enabled);
         ec_debug.pl(3,'v_iitem_att_enabled: ' ,v_iitem_att_enabled);
         ec_debug.pl(3,'v_ship_att_enabled: '  ,v_ship_att_enabled);
         ec_debug.pl(3,'v_att_enabled: '       ,v_att_enabled);
         ec_debug.pl(3,'n_att_seg_size: '      ,n_att_seg_size);

         xProgress  := 'POCOB-10-1010';
         ece_flatfile_pvt.init_table(cTransaction_Type,cHeader_Interface,NULL,FALSE,l_header_tbl,l_key_tbl);

         xProgress  := 'POCOB-10-1020';
         l_key_tbl  := l_header_tbl;

         xProgress  := 'POCOB-10-1025';
         --iKey_count := l_header_tbl.COUNT;
         --ec_debug.pl(3,'iKey_count: ',iKey_count );

         xProgress  := 'POCOB-10-1030';
         ece_flatfile_pvt.init_table(cTransaction_Type,cLine_Interface,NULL,TRUE,l_line_tbl,l_key_tbl);

         xProgress  := 'POCOB-10-1040';
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
         xProgress := 'POCOB-10-1050';
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

         xProgress := 'POCOB-10-1060';
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

         xProgress := 'POCOB-10-1070';
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
         xProgress := 'POCOB-10-1080';
         cHeader_where    := cHeader_where            ||
                           ' communication_method = ' ||  ':cComm_Method';

         xProgress := 'POCOB-10-1090';
         IF cRevised_Date_From IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' revised_date >= '        ||  ':cRevised_Dt_From';
         END IF;

         xProgress := 'POCOB-10-1100';
         IF cRevised_Date_To IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' revised_date <= '        ||  ':cRevised_Dt_To';
         END IF;

         xProgress := 'POCOB-10-1110';
         IF cSupplier_Name IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' supplier_number = '      || ':cSuppl_Name';
         END IF;

         xProgress := 'POCOB-10-1120';
         IF cSupplier_Site IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' vendor_site_id = '       || ':cSuppl_Site';
         END IF;

         xProgress := 'POCOB-10-1130';
         IF cDocument_Type IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' document_type = '        || ':cDoc_Type';
         END IF;

         xProgress := 'POCOB-10-1140';
         IF cPO_Number_From IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' po_number >= '           || ':cPO_Num_From';
         END IF;

         xProgress := 'POCOB-10-1150';
         IF cPO_Number_To IS NOT NULL THEN
            cHeader_where := cHeader_where            || ' AND ' ||
                           ' po_number <= '           || ':cPO_Num_To';
         END IF;

         xProgress := 'POCOB-10-1160';
         cHeader_where := cHeader_where                                                   ||
                          ' ORDER BY po_number, por_release_num';

         xProgress := 'POCOB-10-1170';
         cLine_where := cLine_where                                                        ||
                        ' ece_poco_lines_v.po_header_id = :po_header_id AND'               ||
                        ' ece_poco_lines_v.por_release_num = :por_release_num '         ||
                        ' ORDER BY line_num';

         xProgress := 'POCOB-10-1180';
          cShipment_where := cShipment_where                                               ||
                            ' ece_poco_shipments_v.po_header_id = :po_header_id AND'       ||
                            ' ece_poco_shipments_v.po_line_id = :po_line_id AND'           ||
                            ' ece_poco_shipments_v.por_release_id = :por_release_id'   ||
         --4645680          ' ece_poo_shipments_v.por_release_id = :por_release_id'   ||
                            ' ORDER BY shipment_number';   --2823215
         -- 3957851
         --                   ' ece_poco_shipments_v.por_release_id = :por_release_id AND'   ||
         --                   ' ((ece_poco_shipments_v.por_release_id = 0) OR'               ||
         --                   ' (ece_poco_shipments_v.por_release_id <> 0 AND'               ||
         --                   ' ece_poco_shipments_v.shipment_number = :shipment_number))'   ||
         --                   ' ORDER BY shipment_number';   --2823215

         xProgress := 'POCOB-10-1190';
         cHeader_select   := cHeader_select                                               ||
                             cHeader_from                                                 ||
                             cHeader_where;
         ec_debug.pl(3,'cHeader_select: ',cHeader_select);

         cLine_select     := cLine_select                                                 ||
                             cLine_from                                                   ||
                             cLine_where;
         ec_debug.pl(3,'cLine_select: ',cLine_select);

         cShipment_select := cShipment_select                                             ||
                             cShipment_from                                               ||
                             cShipment_where;
         ec_debug.pl(3,'cShipment_select: ',cShipment_select);

         -- ***************************************************
         -- ***   Get data setup for the dynamic SQL call.
         -- ***   Open a cursor for each of the SELECT call
         -- ***   This tells the database to reserve spaces
         -- ***   for the data returned by the SQL statement
         -- ***************************************************
         xProgress      := 'POCOB-10-1200';
         header_sel_c   := dbms_sql.open_cursor;

         xProgress      := 'POCOB-10-1210';
         line_sel_c     := dbms_sql.open_cursor;

         xProgress      := 'POCOB-10-1220';
         shipment_sel_c := dbms_sql.open_cursor;

         -- ***************************************************
         -- Parse each of the SELECT statement
         -- so the database understands the command
         -- ***************************************************
         xProgress := 'POCOB-10-1230';
         BEGIN
            dbms_sql.parse(header_sel_c,cHeader_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_select);
               app_exception.raise_exception;
         END;

         xProgress := 'POCOB-10-1240';
         BEGIN
            dbms_sql.parse(line_sel_c,cLine_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_select);
               app_exception.raise_exception;
         END;

         xProgress := 'POCOB-10-1250';
         BEGIN
            dbms_sql.parse(shipment_sel_c,cShipment_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cShipment_select);
               app_exception.raise_exception;
         END;

         -- ************
         -- set counter
         -- ************
         xProgress       := 'POCOB-10-1260';
         iHeader_count   := l_header_tbl.COUNT;
         ec_debug.pl(3,'iHeader_count: ',iHeader_count);

         xProgress       := 'POCOB-10-1270';
         iLine_count     := l_line_tbl.COUNT;
         ec_debug.pl(3,'iLine_count: ',iLine_count);

         xProgress       := 'POCOB-10-1280';
         iShipment_count := l_shipment_tbl.COUNT;
         ec_debug.pl(3,'iShipment_count: ',iShipment_count);

         -- ******************************************************
         --  Define TYPE for every columns in the SELECT statement
         --  For each piece of the data returns, we need to tell
         --  the database what type of information it will be.
         --  e.g. ID is NUMBER, due_date is DATE
         --  However, for simplicity, we will convert
         --  everything to varchar2.
         -- ******************************************************
         xProgress := 'POCOB-10-1290';
         ece_flatfile_pvt.define_interface_column_type(header_sel_c,cHeader_select,ece_extract_utils_PUB.G_MaxColWidth,l_header_tbl);

         xProgress := 'POCOB-10-1300';
         ece_flatfile_pvt.define_interface_column_type(line_sel_c,cLine_select,ece_extract_utils_PUB.G_MaxColWidth,l_line_tbl);

         xProgress := 'POCOB-10-1310';
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
         xProgress := 'POCOB-10-1320';
         ece_extract_utils_pub.find_pos(l_header_tbl,ece_extract_utils_pub.G_TRANSACTION_DATE,n_trx_date_pos);
         ec_debug.pl(3,'n_trx_date_pos: ',n_trx_date_pos);

         xProgress := 'POCOB-10-1330';
         ece_extract_utils_pub.find_pos(l_header_tbl,'PO_HEADER_ID',nHeader_key_pos);
         ec_debug.pl(3,'nHeader_key_pos: ',nHeader_key_pos);

         xProgress := 'POCOB-10-1340';
         ece_extract_utils_pub.find_pos(l_header_tbl,'DOCUMENT_TYPE',nDocument_type_pos);
         ec_debug.pl(3,'nDocument_type_pos: ',nDocument_type_pos);

         xProgress := 'POCOB-10-1350';
         ece_extract_utils_pub.find_pos(l_header_tbl,'PO_NUMBER',nPO_Number_pos);
         ec_debug.pl(3,'nPO_Number_pos: ',nPO_Number_pos);

         xProgress := 'POCOB-10-1360';
         ece_extract_utils_pub.find_pos(l_header_tbl,'PO_TYPE',nPO_Type_pos);
         ec_debug.pl(3,'nPO_Type_pos: ',nPO_Type_pos);

         xProgress := 'POCOB-10-1370';
         ece_extract_utils_pub.find_pos(l_header_tbl,'POR_RELEASE_NUM',nRelease_num_pos);
         ec_debug.pl(3,'nRelease_num_pos: ',nRelease_num_pos);

         xProgress := 'POCOB-10-1380';
         ece_extract_utils_pub.find_pos(l_header_tbl,'POR_RELEASE_ID',nRelease_id_pos);
         ec_debug.pl(3,'nRelease_id_pos: ',nRelease_id_pos);

	  xProgress := 'POCOB-10-1381';
         ece_extract_utils_pub.find_pos(l_header_tbl,'CANCEL_FLAG',nHeader_Cancel_Flag_pos);

	 xProgress := 'POOB-10-1382';
	 ece_flatfile_pvt.find_pos(l_header_tbl,ece_flatfile_pvt.G_Translator_Code,nTrans_code_pos); --2823215

	 XProgress := 'POCOB-10-1283';
         ece_flatfile_pvt.find_pos(l_header_tbl,'PO_CANCELLED_DATE',nHeader_cancel_date_pos); --2823215

         -- Line Level Positions
         xProgress := 'POCOB-10-1390';
         ece_extract_utils_pub.find_pos(l_line_tbl,'PO_LINE_LOCATION_ID',nLine_Location_ID_pos);
         ec_debug.pl(3,'nLine_Location_ID_pos: ',nLine_Location_ID_pos);

         xProgress := 'POCOB-10-1400';
         ece_extract_utils_pub.find_pos(l_line_tbl,'LINE_NUM',nLine_num_pos);
         ec_debug.pl(3,'nLine_num_pos: ',nLine_num_pos);

         xProgress := 'POCOB-10-1402';
         ece_extract_utils_pub.find_pos(l_line_tbl,'PO_LINE_ID',nLine_key_pos);
         ec_debug.pl(3,'nLine_key_pos: ',nLine_key_pos);

         xProgress := 'POCOB-10-1404';
         ece_extract_utils_pub.find_pos(l_line_tbl,'ITEM_ID',nItem_id_pos);
         ec_debug.pl(3,'nItem_id_pos: ',nItem_id_pos);

	 xProgress := 'POCOB-10-1405';
         ece_extract_utils_pub.find_pos(l_line_tbl,'CANCEL_FLAG',nLine_Cancel_Flag_pos);

	 xProgress := 'POCOB-10-1406';
         ece_extract_utils_pub.find_pos(l_line_tbl,'UOM_CODE',nLine_uom_code_pos);

         xProgress := 'POCOB-10-1407';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE_CATEGORY',nLp_att_cat_pos);

	 xProgress := 'POCOB-10-1408';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE1',nLp_att1_pos);

	 xProgress := 'POCOB-10-1409';
         ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE2',nLp_att2_pos);

	 xProgress := 'POCOB-10-1410';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE3',nLp_att3_pos);

	 xProgress := 'POCOB-10-1411';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE4',nLp_att4_pos);

	 xProgress := 'POCOB-10-1412';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE5',nLp_att5_pos);

	 xProgress := 'POCOB-10-1413';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE6',nLp_att6_pos);

	 xProgress := 'POCOB-10-1414';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE7',nLp_att7_pos);

	 xProgress := 'POCOB-10-1415';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE8',nLp_att8_pos);

	 xProgress := 'POCOB-10-1416';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE9',nLp_att9_pos);

	 xProgress := 'POCOB-10-1417';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE10',nLp_att10_pos);

	 xProgress := 'POCOB-10-1418';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE11',nLp_att11_pos);

	 xProgress := 'POCOB-10-1419';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE12',nLp_att12_pos);

	 xProgress := 'POCOB-10-1420';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE13',nLp_att13_pos);

	 xProgress := 'POCOB-10-1421';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE14',nLp_att14_pos);

	 xProgress := 'POCOB-10-1422';
	 ece_extract_utils_pub.find_pos(l_line_tbl,'LP_ATTRIBUTE15',nLp_att15_pos);


         -- Shipment Level Positions
         xProgress := 'POCOB-10-1406';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'LINE_LOCATION_ID',nShip_Line_Location_ID_pos);
         ec_debug.pl(3,'nShip_Line_Location_ID_pos: ',nShip_Line_Location_ID_pos);

         xProgress := 'POCOB-10-1407';
         ece_extract_utils_pub.find_pos(l_Shipment_tbl,'QUANTITY_PENDING',nQuantity_pending_pos);

	  xProgress := 'POCOB-10-1408';
         ece_extract_utils_pub.find_pos(l_shipment_tbl,'CANCELLED_FLAG',nShipment_Cancel_Flag_pos);

	 --2823215

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
         xProgress := 'POCOB-10-1448';
         ece_flatfile_pvt.find_pos(l_line_tbl,'UOM_CODE',nLine_uom_pos);

         xProgress := 'POCOB-10-1449';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'CODE_UOM',nShp_uom_pos);
-- 2412921 begin

         xProgress := 'POCOB-10-1410';
         ece_extract_utils_pub.find_pos(l_header_tbl,'CANCEL_DATE',nCancel_Date_pos);
ec_debug.pl(3,'nCancel_Date_pos -> ', nCancel_Date_pos);

         xProgress := 'POCOB-10-1412';
         ece_extract_utils_pub.find_pos(l_line_tbl,'CANCEL_DATE',nCancel_Date_posl);
ec_debug.pl(3,'nCancel_Date_posl -> ', nCancel_Date_posl);
-- 2412921 end


	 -- Timezone enhancement
	 xProgress := 'POCOB-TZ-1000';
        ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_DATE', nRel_date_pos);

	xProgress := 'POCOB-TZ-1001';
        ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_DT_TZ_CODE',nRel_dt_tz_pos);

	xProgress := 'POCOB-TZ-1002';
        ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_DT_OFF',nRel_dt_off_pos);

	xProgress := 'POCOB-TZ-1003';
        ece_flatfile_pvt.find_pos(l_header_tbl,'CREATION_DATE',nCrtn_date_pos);

	xProgress := 'POCOB-TZ-1004';
        ece_flatfile_pvt.find_pos(l_header_tbl,'CREATION_DT_TZ_CODE',nCrtn_dt_tz_pos);

	xProgress := 'POCOB-TZ-1005';
        ece_flatfile_pvt.find_pos(l_header_tbl,'CREATION_DT_OFF',nCrtn_dt_off_pos);

	xProgress := 'POCOB-TZ-1006';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_REVISION_DATE',nRev_date_pos);

        xProgress := 'POCOB-TZ-1007';
        ece_flatfile_pvt.find_pos(l_header_tbl,'REVISION_DT_TZ_CODE',nRev_dt_tz_pos);

	xProgress := 'POCOB-TZ-1008';
        ece_flatfile_pvt.find_pos(l_header_tbl,'REVISION_DT_OFF',nRev_dt_off_pos);

	xProgress := 'POCOB-TZ-1009';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_ACCEPTANCE_DUE_BY_DATE',nAcc_due_dt_pos);

	xProgress := 'POCOB-TZ-1010';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_ACCEPT_DUE_TZ_CODE',nAcc_due_tz_pos);

	xProgress := 'POCOB-TZ-1011';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PO_ACCEPT_DUE_OFF',nAcc_due_off_pos);

	xProgress := 'POCOB-TZ-1012';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_START_DATE',nBlkt_srt_dt_pos);

	xProgress := 'POCOB-TZ-1013';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_SRT_DT_TZ_CODE',nBlkt_srt_tz_pos);

	xProgress := 'POCOB-TZ-1014';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_SRT_DT_OFF',nBlkt_srt_off_pos);

	xProgress := 'POCOB-TZ-1015';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_END_DATE',nBlkt_end_dt_pos);

	xProgress := 'POCOB-TZ-1016';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_END_DT_TZ_CODE',nBlkt_end_tz_pos);

	xProgress := 'POCOB-TZ-1017';
        ece_flatfile_pvt.find_pos(l_header_tbl,'BLANKET_END_DT_OFF',nBlkt_end_off_pos);

	xProgress := 'POCOB-TZ-1018';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PCARD_EXPIRATION_DATE',nPcard_exp_dt_pos);

	xProgress := 'POCOB-TZ-1019';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PCARD_EXPRN_DT_TZ_CODE',nPcard_exp_tz_pos);

	xProgress := 'POCOB-TZ-1020';
        ece_flatfile_pvt.find_pos(l_header_tbl,'PCARD_EXPRN_DT_OFF',nPcard_exp_off_pos);


        xProgress := 'POCOB-TZ-1021';
        ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_CANCELLED_DATE',nLine_can_dt_pos);

	xProgress := 'POCOB-TZ-1022';
        ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_CANCEL_DT_TZ_CODE',nLine_can_tz_pos);

	xProgress := 'POCOB-TZ-1023';
        ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_CANCEL_DT_OFF',nLine_can_off_pos);

	xProgress := 'POCOB-TZ-1024';
        ece_flatfile_pvt.find_pos(l_line_tbl,'EXPIRATION_DATE',nExprn_dt_pos);

	xProgress := 'POCOB-TZ-1025';
        ece_flatfile_pvt.find_pos(l_line_tbl,'EXPIRATION_DT_TZ_CODE',nExprn_tz_pos);

	xProgress := 'POCOB-TZ-1026';
        ece_flatfile_pvt.find_pos(l_line_tbl,'EXPIRATION_DT_OFF',nExprn_off_pos);

        xProgress := 'POCOB-TZ-1027';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_NEED_BY_DATE',nShip_need_dt_pos);

	xProgress := 'POCOB-TZ-1028';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_NEED_DT_TZ_CODE',nShip_need_tz_pos);

	xProgress := 'POCOB-TZ-1029';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_NEED_DT_OFF',nShip_need_off_pos);

	xProgress := 'POCOB-TZ-1030';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_PROMISED_DATE',nShip_prom_dt_pos);

	xProgress := 'POCOB-TZ-1031';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_PROM_DT_TZ_CODE',nShip_prom_tz_pos);

	xProgress := 'POCOB-TZ-1032';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_PROM_DT_OFF',nShip_prom_off_pos);

	xProgress := 'POCOB-TZ-1033';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_LAST_ACCEPTABLE_DATE',nShip_accept_dt_pos);

	xProgress := 'POCOB-TZ-1034';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_LAST_ACC_DT_TZ_CODE',nShip_accept_tz_pos);

	xProgress := 'POCOB-TZ-1035';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'SHIPMENT_LAST_ACC_DT_OFF',nShip_accept_off_pos);

        xProgress := 'POCOB-TZ-1036';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'CANCELLED_DATE',nShp_can_dt_pos);

	xProgress := 'POCOB-TZ-1037';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'CANCEL_DT_TZ_CODE',nShp_can_tz_pos);

	xProgress := 'POCOB-TZ-1038';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'CANCEL_DT_OFF',nShp_can_off_pos);

	xProgress := 'POCOB-TZ-1039';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'START_DATE',nShp_strt_dt_pos);

        xProgress := 'POCOB-TZ-1040';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'START_DT_TZ_CODE',nShp_strt_tz_pos);

	xProgress := 'POCOB-TZ-1041';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'START_DT_OFF',nShp_strt_off_pos);

	xProgress := 'POCOB-TZ-1042';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'END_DATE',nShp_end_dt_pos);

	xProgress := 'POCOB-TZ-1043';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'END_DT_TZ_CODE',nShp_end_tz_pos);

	xProgress := 'POCOB-TZ-1044';
        ece_flatfile_pvt.find_pos(l_shipment_tbl,'END_DT_OFF',nShp_end_off_pos);
        -- Timezone enhancement
        xProgress := 'POCOB-09-1400';
        ece_flatfile_pvt.find_pos(l_header_tbl,c_header_common_key_name,n_header_common_key_pos);

         xProgress := 'POCOB-09-1401';
        ece_flatfile_pvt.find_pos(l_line_tbl,c_line_common_key_name,n_line_common_key_pos);

        xProgress := 'POCOB-09-1402';
	ece_flatfile_pvt.find_pos(l_shipment_tbl,c_shipment_key_name,n_ship_common_key_pos);

         xProgress := 'POCOB-10-1413';
           dbms_sql.bind_variable(header_sel_c,'cComm_Method',cCommunication_Method);
         IF cRevised_Date_From IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cRevised_Dt_From',cRevised_Date_From);
         END IF;

         IF cRevised_Date_To IS NOT NULL THEN
           dbms_sql.bind_variable(header_sel_c,'cRevised_Dt_To',cRevised_Date_To);
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

         -- EXECUTE the SELECT statement
         xProgress := 'POCOB-10-1414';
         dummy := dbms_sql.execute(header_sel_c);

         -- ***************************************************
         -- The model is:
         -- HEADER - LINE - SHIPMENT ...
         -- With data for each HEADER line, populate the header
         -- interfacetable then get all LINES that belongs
         -- to the HEADER. Then get all
         -- SHIPMENTS that belongs to the LINE.
         -- ***************************************************
         xProgress := 'POCOB-10-1410';
         WHILE dbms_sql.fetch_rows(header_sel_c) > 0 LOOP           -- Header

            if (NOT utl_file.is_open(ece_poo_transaction.uFile_type)) then
                ece_poo_transaction.uFile_type := utl_file.fopen(i_path,i_filename,'W',32767);
            end if;
         counter := 0;
            -- **************************************
            --  store internal values in pl/sql table
            -- **************************************
            xProgress := 'POCOB-10-1420';
            ece_flatfile_pvt.assign_column_value_to_tbl(header_sel_c,0,l_header_tbl,l_key_tbl);

            -- ***************************************************
            --  also need to populate transaction_date and run_id
            -- ***************************************************
            xProgress := 'POCOB-10-1430';
            l_header_tbl(n_trx_date_pos).value := TO_CHAR(dTransaction_date,'YYYYMMDD HH24MISS');

            --  The application specific feedback logic begins here.
            xProgress := 'POCOB-10-1440';
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
            ec_debug.pl(3, 'l_document_type: ',l_document_type);

            xProgress := 'POCOB-10-1450';
            ece_poo_transaction.update_po(l_document_type,
                                          l_header_tbl(nPO_Number_pos).value,
                                          l_header_tbl(nPO_type_pos).value,
                                          l_header_tbl(nRelease_num_pos).value);
            xProgress := 'POCOB-TZ-1500';
            ece_timezone_api.get_server_timezone_details(
              to_date(l_header_tbl(nRel_date_pos).value,'YYYYMMDD HH24MISS'),
              l_header_tbl(nRel_dt_off_pos).value,
	      l_header_tbl(nRel_dt_tz_pos).value
            );

	    xProgress := 'POCOB-TZ-1510';

            ece_timezone_api.get_server_timezone_details
            (
              to_date(l_header_tbl(nCrtn_date_pos).value,'YYYYMMDD HH24MISS'),
              l_header_tbl(nCrtn_dt_off_pos).value,
	      l_header_tbl(nCrtn_dt_tz_pos).value
            );

	    xProgress := 'POCOB-TZ-1520';

            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nRev_date_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nRev_dt_off_pos).value,
	     l_header_tbl(nRev_dt_tz_pos).value
            );

	    xProgress := 'POCOB-TZ-1530';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nAcc_due_dt_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nAcc_due_off_pos).value,
	     l_header_tbl(nAcc_due_tz_pos).value
            );

	    xProgress := 'POCOB-TZ-1540';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nBlkt_srt_dt_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nBlkt_srt_off_pos).value,
	     l_header_tbl(nBlkt_srt_tz_pos).value
            );

	    xProgress := 'POCOB-TZ-1550';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nBlkt_end_dt_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nBlkt_end_off_pos).value,
	     l_header_tbl(nBlkt_end_tz_pos).value
            );

	    xProgress := 'POCOB-TZ-1560';
            ece_timezone_api.get_server_timezone_details
            (
             to_date(l_header_tbl(nPcard_exp_dt_pos).value,'YYYYMMDD HH24MISS'),
             l_header_tbl(nPcard_exp_off_pos).value,
	     l_header_tbl(nPcard_exp_tz_pos).value
            );


    -- pass the pl/sql table in for xref
            xProgress := 'POCOB-10-1460';
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
            xProgress := 'POCOB-10-1480';
            BEGIN
               SELECT   ece_poco_header_s.NEXTVAL
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
                             'ECE_POCO_HEADER_S');

            END;
            ec_debug.pl(3,'l_header_fkey: ',l_header_fkey);

                    xProgress := 'POOB-10-1490';
	    --2823215
            c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),1,25),25);

            xProgress         := 'POOB-10-1491';
            c_file_common_key := c_file_common_key ||
                                 RPAD(SUBSTRB(NVL(l_header_tbl(n_header_common_key_pos).value,' '),1,22),22) || RPAD(' ',22) || RPAD(' ',22);

            ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);
           /* ece_extract_utils_pub.insert_into_interface_tbl(
               iRun_id,
               cTransaction_Type,
               cCommunication_Method,
               cHeader_Interface,
               l_header_tbl,
               l_header_fkey); */

            -- Now update the columns values of which have been obtained
            -- thru the procedure calls.

            -- ********************************************************
            -- Call custom program stub to populate the extension table
            -- ********************************************************
            xProgress := 'POCOB-10-1500';
            ece_poco_x.populate_ext_header(l_header_fkey,l_header_tbl);

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
            xProgress := 'POCOB-10-1501';
            IF v_header_att_enabled = 'Y' THEN
               xProgress := 'POCOB-10-1502';
               IF l_document_type = 'NR' THEN -- If this is a Release PO.
                  xProgress := 'POCOB-10-1503';
                  v_entity_name := 'PO_RELEASES';
                  v_pk1_value := l_header_tbl(nRelease_id_pos).value;
                  ec_debug.pl(3,'release_id: ',l_header_tbl(nRelease_id_pos).value);
               ELSE -- If this is a non-Release PO.
                  xProgress := 'POCOB-10-1504';
                  v_entity_name := 'PO_HEADERS';
                  v_pk1_value := l_header_tbl(nHeader_key_pos).value;
                  ec_debug.pl(3,'po_header_id: ',l_header_tbl(nHeader_key_pos).value);
               END IF;

               xProgress := 'POCOB-10-1505';
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
                                                            ECE_POO_TRANSACTION.C_ANY_VALUE, -- BUG:5367903
                                                            ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                            ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                            ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                            n_att_seg_size,
                                                            l_key_tbl,
							    c_file_common_key,
                                                            l_hdr_att_hdr_tbl,
                                                            l_hdr_att_dtl_tbl,
                                                            iAtt_hdr_pos);  -- 2823215
            END IF;

            -- ***************************************************
            -- From Header data, we can assign values to
            -- place holders (foreign keys) in Line_select and
            -- Line_detail_Select
            -- set values into binding variables
            -- ***************************************************

            -- use the following bind_variable feature as you see fit.
            xProgress := 'POCOB-10-1510';
            dbms_sql.bind_variable(line_sel_c,'po_header_id',l_header_tbl(nHeader_key_pos).value);

            xProgress := 'POCOB-10-1515';
            dbms_sql.bind_variable(line_sel_c,'por_release_num',l_header_tbl(nRelease_num_pos).value);

            xProgress := 'POCOB-10-1520';
            dbms_sql.bind_variable(Shipment_sel_c,'po_header_id',l_header_tbl(nHeader_key_pos).value);

            xProgress := 'POOB-10-1525';
            dbms_sql.bind_variable(Shipment_sel_c,'por_release_id',l_header_tbl(nRelease_id_pos).value); --2823215

            xProgress := 'POCOB-10-1530';
            dummy := dbms_sql.execute(line_sel_c);

            -- *********************
            -- Line Level Loop Starts Here
            -- *********************
            xProgress := 'POCOB-10-1540';
            WHILE dbms_sql.fetch_rows(line_sel_c) > 0 LOOP     --- Line

               -- ****************************
               -- store values in pl/sql table
               -- ****************************
               xProgress := 'POCOB-10-1550';
               ece_flatfile_pvt.assign_column_value_to_tbl(line_sel_c,iHeader_count,l_line_tbl,l_key_tbl);

               -- The following procedure gets the part number for the
               -- item ID returned
               xProgress := 'POCOB-10-1640';
               ece_inventory.get_item_number(l_line_tbl(nItem_ID_pos).value,
                                             nOrganization_ID,
                                             cline_part_number,
                                             cline_part_attrib_category,
                                             cline_part_attribute1,
                                             cline_part_attribute2,
                                             cline_part_attribute3,
                                             cline_part_attribute4,
                                             cline_part_attribute5,
                                             cline_part_attribute6,
                                             cline_part_attribute7,
                                             cline_part_attribute8,
                                             cline_part_attribute9,
                                             cline_part_attribute10,
                                             cline_part_attribute11,
                                             cline_part_attribute12,
                                             cline_part_attribute13,
                                             cline_part_attribute14,
                                             cline_part_attribute15);

               begin

               select uom_code into l_line_tbl(nLine_uom_pos).value
	       from mtl_units_of_measure
	       where unit_of_measure = l_line_tbl(nLine_uom_code_pos).value;
	       exception
	       when others then
	       null;
	       end;

               xProgress := 'POCOB-TZ-2500';
	       ece_timezone_api.get_server_timezone_details
               (
                to_date(l_line_tbl(nLine_can_dt_pos).value,'YYYYMMDD HH24MISS'),
                l_line_tbl(nLine_can_off_pos).value,
                l_line_tbl(nLine_can_tz_pos).value
                );

	       xProgress := 'POCOB-TZ-2510';

               ece_timezone_api.get_server_timezone_details
               (
                to_date(l_line_tbl(nExprn_dt_pos).value,'YYYYMMDD HH24MISS'),
		l_line_tbl(nExprn_off_pos).value,
                l_line_tbl(nExprn_tz_pos).value
               );
               -- pass the pl/sql table in for xref
               xProgress := 'POCOB-10-1570';
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

               xProgress := 'POCOB-10-1590';
               BEGIN
                  SELECT   ece_poco_line_s.NEXTVAL INTO l_line_fkey
                  FROM     DUAL;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_POCO_LINE_S');

               END;
               ec_debug.pl(3,'l_line_fkey: ',l_line_fkey);

               -- Insert into Interface Table
      /*         xProgress := 'POCOB-10-1600';
               ece_extract_utils_pub.insert_into_interface_tbl(
                  iRun_id,
                  cTransaction_Type,
                  cCommunication_Method,
                  cLine_Interface,
                  l_line_tbl,
                  l_line_fkey); */  -- 2823215

               if ec_debug.G_debug_level = 3 then
               ec_debug.pl(3,'cline_part_number: '         ,cline_part_number);
               ec_debug.pl(3,'cline_part_attrib_category: ',cline_part_attrib_category);
               ec_debug.pl(3,'cline_part_attribute1: '     ,cline_part_attribute1);
               ec_debug.pl(3,'cline_part_attribute2: '     ,cline_part_attribute2);
               ec_debug.pl(3,'cline_part_attribute3: '     ,cline_part_attribute3);
               ec_debug.pl(3,'cline_part_attribute4: '     ,cline_part_attribute4);
               ec_debug.pl(3,'cline_part_attribute5: '     ,cline_part_attribute5);
               ec_debug.pl(3,'cline_part_attribute6: '     ,cline_part_attribute6);
               ec_debug.pl(3,'cline_part_attribute7: '     ,cline_part_attribute7);
               ec_debug.pl(3,'cline_part_attribute8: '     ,cline_part_attribute8);
               ec_debug.pl(3,'cline_part_attribute9: '     ,cline_part_attribute9);
               ec_debug.pl(3,'cline_part_attribute10: '    ,cline_part_attribute10);
               ec_debug.pl(3,'cline_part_attribute11: '    ,cline_part_attribute11);
               ec_debug.pl(3,'cline_part_attribute12: '    ,cline_part_attribute12);
               ec_debug.pl(3,'cline_part_attribute13: '    ,cline_part_attribute13);
               ec_debug.pl(3,'cline_part_attribute14: '    ,cline_part_attribute14);
               ec_debug.pl(3,'cline_part_attribute15: '    ,cline_part_attribute15);
               END if;

	       xProgress := 'POOB-10-1591';
	       -- 2823215
               l_line_tbl(nLp_att_cat_pos).value := cline_part_attrib_category;
	       l_line_tbl(nLp_att1_pos).value := cline_part_attribute1;
               l_line_tbl(nLp_att2_pos).value := cline_part_attribute2;
	       l_line_tbl(nLp_att3_pos).value := cline_part_attribute3;
	       l_line_tbl(nLp_att4_pos).value := cline_part_attribute4;
	       l_line_tbl(nLp_att5_pos).value := cline_part_attribute5;
	       l_line_tbl(nLp_att6_pos).value := cline_part_attribute6;
	       l_line_tbl(nLp_att7_pos).value := cline_part_attribute7;
	       l_line_tbl(nLp_att8_pos).value := cline_part_attribute8;
	       l_line_tbl(nLp_att9_pos).value := cline_part_attribute9;
	       l_line_tbl(nLp_att10_pos).value := cline_part_attribute10;
	       l_line_tbl(nLp_att11_pos).value := cline_part_attribute11;
	       l_line_tbl(nLp_att12_pos).value := cline_part_attribute12;
	       l_line_tbl(nLp_att13_pos).value := cline_part_attribute13;
	       l_line_tbl(nLp_att14_pos).value := cline_part_attribute14;
	       l_line_tbl(nLp_att15_pos).value := cline_part_attribute15;

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

	       xProgress := 'POOB-10-1621';

              -- 2823215

               -- Now update the columns values of which have been obtained thru the procedure calls.
        /*       xProgress := 'POCOB-10-1610';
               UPDATE   ece_po_interface_lines
               SET      line_part_number          = cline_part_number,
                        line_part_attrib_category = cline_part_attrib_category,
                        line_part_attribute1      = cline_part_attribute1,
                        line_part_attribute2      = cline_part_attribute2,
                        line_part_attribute3      = cline_part_attribute3,
                        line_part_attribute4      = cline_part_attribute4,
                        line_part_attribute5      = cline_part_attribute5,
                        line_part_attribute6      = cline_part_attribute6,
                        line_part_attribute7      = cline_part_attribute7,
                        line_part_attribute8      = cline_part_attribute8,
                        line_part_attribute9      = cline_part_attribute9,
                        line_part_attribute10     = cline_part_attribute10,
                        line_part_attribute11     = cline_part_attribute11,
                        line_part_attribute12     = cline_part_attribute12,
                        line_part_attribute13     = cline_part_attribute13,
                        line_part_attribute14     = cline_part_attribute14,
                        line_part_attribute15     = cline_part_attribute15
               WHERE    transaction_record_id     = l_line_fkey;  */

--2412921 begin
ec_debug.pl(3,'document type ',l_header_tbl(nDocument_type_pos).value);
if l_header_tbl(nDocument_type_pos).value NOT IN ('RELEASE','BLANKET RELEASE') then

begin
cancel_flag_value := l_header_tbl(nHeader_Cancel_Flag_pos).value;
ec_debug.pl(3,'cancel_flag_value->' ,cancel_flag_value);

if cancel_flag_value = 'Y' then
cancel_date_value := to_date(l_line_tbl(nCancel_Date_posl).value,'YYYYMMDD HH24MISS');
ec_debug.pl(3,'cancel_date_value->' ,l_line_tbl(nCancel_Date_posl).value);
end if;

if cancel_date_value is not null then counter := counter + 1;
end if;

ec_debug.pl(3,'counter -->' ,counter);

/* If Header is already updated with cancel date from line, then no need
to update again */
if counter = 1 then
/* update ece_po_interface_headers set
po_cancelled_date = cancel_date_value
where po_header_id = l_header_tbl(nHeader_key_pos).value; */
l_header_tbl(nHeader_cancel_date_pos).value := cancel_date_value;
end if;

exception
when no_data_found then
null;
when others then
null;
end;

end if;
-- 2823215
               xProgress := 'POCOB-10-1620';
               ece_poco_x.populate_ext_line(l_line_fkey,l_line_tbl);

                   ece_poo_transaction.write_to_file( cTransaction_Type,
                                                  cCommunication_Method,
                                                  cLine_Interface,
                                                  l_line_tbl,
                                                  iOutput_width,
                                                  iRun_id,
                                                  c_file_common_key,
                                                  l_line_fkey);
-- 2823215
-- 2412921 end

               IF SQL%NOTFOUND THEN
                  ec_debug.pl(0,'EC','ECE_NO_ROW_UPDATED','PROGRESS_LEVEL',xProgress,'INFO','LINE PART','TABLE_NAME','ECE_PO_INTERFACE_LINES');
               END IF;

               -- ********************************************************
               -- Call custom program stub to populate the extension table
               -- ********************************************************

               /***************************
               *  Line Level Attachments  *
               ***************************/
               IF v_line_att_enabled = 'Y' THEN
                  xProgress := 'POCOB-10-1621';
     /* Bug 2235872  IF l_document_type = 'NR' THEN -- If this is a Release PO.
                     xProgress := 'POCOB-10-1622';
                     v_entity_name := 'PO_SHIPMENTS';
                     v_pk1_value := l_line_tbl(nLine_Location_ID_pos).value; -- LINE_LOCATION_ID
                     ec_debug.pl(3,'PO_LINE_LOCATION_ID: ',l_line_tbl(nLine_Location_ID_pos).value);
                  ELSE -- If this is a non-Release PO.  */
                     xProgress := 'POCOB-10-1623';
                     v_entity_name := 'PO_LINES';
                     v_pk1_value := l_line_tbl(nLine_key_pos).value; -- LINE_ID
                     ec_debug.pl(3,'PO_LINE_ID: ',l_line_tbl(nLine_key_pos).value);
                --  END IF;

                  xProgress := 'POCOB-10-1624';
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
                                                               ECE_POO_TRANSACTION.C_ANY_VALUE, -- BUG:5367903
                                                               ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                               ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                               ECE_POO_TRANSACTION.C_ANY_VALUE,
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
                  xProgress := 'POCOB-10-1625';
                  v_entity_name := 'MTL_SYSTEM_ITEMS';
                  v_pk1_value := nOrganization_ID; -- Master Inventory Org ID
                  ec_debug.pl(3,'Master Org ID: ',v_pk1_value);

                  v_pk2_value := l_line_tbl(nitem_id_pos).value; -- Item ID
                  ec_debug.pl(3,'Item ID: ',v_pk2_value);

                  xProgress := 'POCOB-10-1626';
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
               IF v_iitem_att_enabled = 'Y' THEN
                  xProgress := 'POCOB-10-1627';
                  v_entity_name := 'MTL_SYSTEM_ITEMS';
                  v_pk2_value := l_line_tbl(nitem_id_pos).value; -- Item ID
                  ec_debug.pl(3,'Item ID: ',v_pk2_value);

                  xProgress := 'POCOB-10-1628';
                  FOR v_org_id IN c_org_id(l_line_tbl(nLine_key_pos).value) LOOP -- Value passed is the Line ID
                     IF v_org_id.ship_to_organization_id <> nOrganization_ID THEN -- Only do this if it is not the same as the Master Org ID
                        v_pk1_value := v_org_id.ship_to_organization_id;
                        ec_debug.pl(3,'Inventory Org ID: ',v_pk1_value);

                        xProgress := 'POCOB-10-1626';
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
               -- **********************
               -- set LINE_NUMBER values
               -- **********************
 --  Removed based on bug:3957851
 --               xProgress := 'POOB-10-1627';
 --              dbms_sql.bind_variable(shipment_sel_c,'shipment_number',l_line_tbl(nLine_num_pos).value);

               xProgress := 'POCOB-10-1630';
               dbms_sql.bind_variable(shipment_sel_c,'po_line_id',l_line_tbl(nLine_key_pos).value);

               xProgress := 'POCOB-10-1640';
               dummy := dbms_sql.execute(shipment_sel_c);

               -- *************************
               -- Shipment loop starts here
               -- *************************
               xProgress := 'POCOB-10-1650';
               WHILE dbms_sql.fetch_rows(shipment_sel_c) > 0 LOOP    --- Shipment

                  -- ****************************
                  -- store values in pl/sql table
                  -- ****************************
                  xProgress := 'POCOB-10-1660';
                  ece_flatfile_pvt.assign_column_value_to_tbl(shipment_sel_c,iHeader_count + iLine_count,l_Shipment_tbl,l_key_tbl);

                  -- Calculate Pending Quantity
                  xProgress := 'POCOB-10-1665';
                  l_shipment_tbl(nQuantity_pending_pos).value := NVL(rcv_quantities_s.get_pending_qty(l_shipment_tbl(nShip_Line_location_id_pos).value),0);
                  ec_debug.pl(3,'l_Shipment_tbl(nQuantity_pending_pos).value: ',l_shipment_tbl(nQuantity_pending_pos).value);

                  xProgress := 'POCOB-10-1670';
                  BEGIN
                     SELECT   ece_poco_shipment_s.NEXTVAL INTO l_shipment_fkey
                     FROM     DUAL;

                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        ec_debug.pl(0,'EC','ECE_GET_NEXT_SEQ_FAILED','PROGRESS_LEVEL',xProgress,'SEQ','ECE_POCO_SHIPMENT_S');
                  END;
                  ec_debug.pl(3, 'l_Shipment_fkey: ',l_Shipment_fkey);

		  l_shipment_tbl(nLine_Location_uom_pos).value := l_line_tbl(nLine_uom_code_pos).value;   -- bug 2823215

                  l_shipment_tbl(nShip_Release_Num_pos).value := l_header_tbl(nRelease_num_pos).value;    -- bug 2823215

		  l_shipment_tbl(nShp_uom_pos).value := l_line_tbl(nLine_uom_pos).value;

		  xProgress := 'POCOB-TZ-3500';
		  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShip_need_dt_pos).value,'YYYYMMDD HH24MISS'),
		   l_shipment_tbl(nShip_need_off_pos).value,
                   l_shipment_tbl(nShip_need_tz_pos).value
                  );

		  xProgress := 'POCOB-TZ-3510';
                  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShip_prom_dt_pos).value,'YYYYMMDD HH24MISS'),
		   l_shipment_tbl(nShip_prom_off_pos).value,
                   l_shipment_tbl(nShip_prom_tz_pos).value
                  );

		  xProgress := 'POCOB-TZ-3520';
                  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShip_accept_dt_pos).value,'YYYYMMDD HH24MISS'),
		   l_shipment_tbl(nShip_accept_off_pos).value,
                   l_shipment_tbl(nShip_accept_tz_pos).value
                  );

		  xProgress := 'POCOB-TZ-3530';
                  ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShp_can_dt_pos).value,'YYYYMMDD HH24MISS'),
		   l_shipment_tbl(nShp_can_off_pos).value,
                   l_shipment_tbl(nShp_can_tz_pos).value
                   );

		   xProgress := 'POCOB-TZ-3540';
                   ece_timezone_api.get_server_timezone_details
                  (
                   to_date(l_shipment_tbl(nShp_strt_dt_pos).value,'YYYYMMDD HH24MISS'),
                   l_shipment_tbl(nShp_strt_off_pos).value,
                   l_shipment_tbl(nShp_strt_tz_pos).value
                   );

		   xProgress := 'POCOB-TZ-3550';
                   ece_timezone_api.get_server_timezone_details
                   (
                    to_date(l_shipment_tbl(nShp_end_dt_pos).value,'YYYYMMDD HH24MISS'),
		    l_shipment_tbl(nShp_end_off_pos).value,
                    l_shipment_tbl(nShp_end_tz_pos).value
                   );

                  -- pass the pl/sql table in for xref
                  xProgress := 'POCOB-10-1680';
                  ec_code_conversion_pvt.populate_plsql_tbl_with_extval(p_api_version_number => 1.0,
                                                                        p_init_msg_list      => init_msg_list,
                                                                        p_simulate           => simulate,
                                                                        p_commit             => commt,
                                                                        p_validation_level   => validation_level,
                                                                        p_return_status      => return_status,
                                                                        p_msg_count          => msg_count,
                                                                        p_msg_data           => msg_data,
                                                                        p_key_tbl            => l_key_tbl,
                                                                        p_tbl                => l_Shipment_tbl);

                  xProgress := 'POCOB-10-1700';
                /*  ece_extract_utils_pub.insert_into_interface_tbl(
                     iRun_id,
                     cTransaction_Type,
                     cCommunication_Method,
                     cShipment_Interface,
                     l_shipment_tbl,
                     l_shipment_fkey); */

		   xProgress := 'POOB-10-1690';
		   c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value    ,' '),1,25),25) ||
                                       RPAD(SUBSTRB(NVL(l_header_tbl(n_header_common_key_pos).value    ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_line_tbl(n_line_common_key_pos).value        ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_shipment_tbl(n_ship_common_key_pos).value,' '),1,22),22);
                  if ec_debug.G_debug_level = 3 then
                   ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);
                  end if;


                  xProgress := 'POOB-10-1700';
                  ece_poco_x.populate_ext_shipment(l_shipment_fkey,l_shipment_tbl);

  -- Drop shipment
                  xProgress := 'POCOB-10-1701';
                  v_drop_ship_flag := OE_DROP_SHIP_GRP.PO_Line_Location_Is_Drop_Ship(l_shipment_tbl(nShip_Line_Location_ID_pos).value);
                  xProgress := 'POCOB-10-1702';

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

                  xProgress := 'POCOB-10-1703';
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
                  xProgress := 'POCOB-10-1704';

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


		  ece_poo_transaction.write_to_file(cTransaction_Type,
                                                    cCommunication_Method,
                                                    cShipment_Interface,
                                                    l_shipment_tbl,
                                                    iOutput_width,
                                                    iRun_id,
                                                    c_file_common_key,
                                                    l_shipment_fkey);

                  -- ********************************************************
                  -- Call custom program stub to populate the extension table
                  -- ********************************************************
               /*   xProgress := 'POCOB-10-1710';
                  ece_poco_x.populate_ext_shipment(l_shipment_fkey,l_shipment_tbl);
                */
                  -- Shipment Level Attachment Handler
                  IF v_ship_att_enabled = 'Y' THEN
                     v_entity_name := 'PO_SHIPMENTS';
                     v_pk1_value := l_shipment_tbl(nShip_Line_Location_ID_pos).value;
                     ec_debug.pl(3,'Ship Level Line Location ID: ',l_shipment_tbl(nShip_Line_Location_ID_pos).value);

                     xProgress := 'POCOB-10-1720';
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
                                                                  ECE_POO_TRANSACTION.C_ANY_VALUE, -- BUG:5367903
                                                                  ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                                  ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                                  ECE_POO_TRANSACTION.C_ANY_VALUE,
                                                                  n_att_seg_size,
                                                                  l_key_tbl,
								  c_file_common_key,
                                                                  l_shp_att_hdr_tbl,
                                                                  l_shp_att_dtl_tbl,
                                                                  iAtt_shp_pos);
                  END IF;

                  -- Project Level Handler
                  xProgress := 'POCOB-10-1730';
 --     if project_acct_status = 'I' THEN -- Project Accounting is Installed   bug 1891291
                     ece_poo_transaction.populate_distribution_info(
                        cCommunication_Method,
                        cTransaction_Type,
                        iRun_id,
                        cProject_Interface,
                        l_key_tbl,
                        l_header_tbl(nHeader_key_pos).value,               -- PO_HEADER_ID
                        l_header_tbl(nRelease_id_pos).value,               -- PO_RELEASE_ID
                        l_line_tbl(nLine_key_pos).value,                   -- PO_LINE_ID
                        l_shipment_tbl(nShip_Line_Location_ID_pos).value,  -- LINE_LOCATION_ID
			c_file_common_key);  --2823215
 --                 END IF;

               END LOOP; -- SHIPMENT Level Loop

               xProgress := 'POCOB-10-1740';
               IF dbms_sql.last_row_count = 0 THEN
                  v_LevelProcessed := 'SHIPMENT';
                  ec_debug.pl(0,'EC','ECE_NO_DB_ROW_PROCESSED','PROGRESS_LEVEL',xProgress,'LEVEL_PROCESSED',v_LevelProcessed,'TRANSACTION_TYPE',cTransaction_Type);
               END IF;

            END LOOP;    -- LINE Level Loop

            xProgress := 'POCOB-10-1750';
            IF dbms_sql.last_row_count = 0 THEN
               v_LevelProcessed := 'LINE';
               ec_debug.pl(0,'EC','ECE_NO_DB_ROW_PROCESSED','PROGRESS_LEVEL',xProgress,'LEVEL_PROCESSED',v_LevelProcessed,'TRANSACTION_TYPE',cTransaction_Type);
            END IF;

         END LOOP;       -- HEADER Level Loop

         xProgress := 'POCOB-10-1760';
         IF dbms_sql.last_row_count = 0 THEN
            v_LevelProcessed := 'HEADER';
            ec_debug.pl(0,'EC','ECE_NO_DB_ROW_PROCESSED','LEVEL_PROCESSED',v_LevelProcessed,'PROGRESS_LEVEL',xProgress,'TRANSACTION_TYPE',cTransaction_Type);
         END IF;

         xProgress := 'POCOB-10-1770';

         if (ece_poo_transaction.project_sel_c >0) then      --Bug 2819176

         dbms_sql.close_cursor(ece_poo_transaction.project_sel_c);      --Bug 2490109
         end if;
         xProgress := 'POCOB-10-1780';

         dbms_sql.close_cursor(shipment_sel_c);

         xProgress := 'POCOB-10-1790';
         dbms_sql.close_cursor(line_sel_c);

         xProgress := 'POCOB-10-1800';
         dbms_sql.close_cursor(header_sel_c);

         ec_debug.pop('ECE_POCO_TRANSACTION.POPULATE_POCO_TRX');

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END populate_poco_trx;

   PROCEDURE put_data_to_output_table(cCommunication_Method   IN VARCHAR2,
                                      cTransaction_Type       IN VARCHAR2,
                                      iOutput_width           IN INTEGER,
                                      iRun_id                 IN INTEGER,
                                      cHeader_Interface       IN VARCHAR2,
                                      cLine_Interface         IN VARCHAR2,
                                      cShipment_Interface     IN VARCHAR2,
                                      cProject_Interface      IN VARCHAR2) IS

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

      header_sel_c               INTEGER;
      line_sel_c                 INTEGER;
      shipment_sel_c             INTEGER;

      header_del_c1              INTEGER;
      line_del_c1                INTEGER;
      shipment_del_c1            INTEGER;

      header_del_c2              INTEGER;
      line_del_c2                INTEGER;
      shipment_del_c2            INTEGER;

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
      n_po_header_id             NUMBER;
      nRelease_id                NUMBER;
      nRelease_id_pos            NUMBER;
      n_po_line_id               NUMBER;
      nPO_Line_Location_ID_pos   NUMBER;
      nPO_Line_Location_ID       NUMBER;
      nLine_Location_ID_pos      NUMBER;
      nLine_Location_ID          NUMBER;
      nLine_num_pos              NUMBER;
      nLine_num                  NUMBER;
      nRelease_num               NUMBER;
      nRelease_num_pos           NUMBER;
      nOrganization_ID           NUMBER;
      nItem_id_pos               NUMBER;
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
         ec_debug.push('ECE_POCO_TRANSACTION.PUT_DATA_TO_OUTPUT_TABLE');
         ec_debug.pl(3,'cCommunication_Method: ',cCommunication_Method);
         ec_debug.pl(3,'cTransaction_Type: '    ,cTransaction_Type);
         ec_debug.pl(3,'iOutput_width: '        ,iOutput_width);
         ec_debug.pl(3,'iRun_id: '              ,iRun_id);
         ec_debug.pl(3,'cHeader_Interface: '    ,cHeader_Interface);
         ec_debug.pl(3,'cLine_Interface: '      ,cLine_Interface);
         ec_debug.pl(3,'cShipment_Interface: '  ,cShipment_Interface);

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
         ec_debug.pl(3,'norganization_id: ',norganization_id);

         -- Let's See if Project Accounting is Installed
         xProgress := 'POCOB-20-1000';
         v_project_acct_installed := fnd_installation.get_app_info(
                                       v_project_acct_short_name, -- i.e. 'PA'
                                       v_project_acct_status,     -- 'I' means it's installed
                                       v_project_acct_industry,
                                       v_project_acct_schema);

         v_project_acct_status := NVL(v_project_acct_status,'X');
         ec_debug.pl(3,'v_project_acct_status: '  ,v_project_acct_status);
         ec_debug.pl(3,'v_project_acct_industry: ',v_project_acct_industry);
         ec_debug.pl(3,'v_project_acct_schema: '  ,v_project_acct_schema);

         xProgress := 'POCOB-20-1005';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cHeader_Interface,
                                        cHeader_X_Interface,
                                        l_header_tbl,
                                        c_header_common_key_name,
                                        cHeader_select,
                                        cHeader_from,
                                        cHeader_where);

         xProgress := 'POCOB-20-1010';
         ece_flatfile_pvt.select_clause(cTransaction_Type,
                                        cCommunication_Method,
                                        cLine_Interface,
                                        cLine_X_Interface,
                                        l_line_tbl,
                                        c_line_common_key_name,
                                        cLine_select,
                                        cLine_from,
                                        cLine_where);

         xProgress := 'POCOB-20-1020';
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
         xProgress := 'POCOB-20-1021';
         ece_flatfile_pvt.find_pos(l_header_tbl,ece_flatfile_pvt.G_Translator_Code,nTrans_code_pos);
         ec_debug.pl(3,'nTrans_code_pos: ',nTrans_code_pos);

         xProgress := 'POCOB-20-1022';
         ece_flatfile_pvt.find_pos(l_header_tbl,c_header_common_key_name,nHeader_key_pos);
         ec_debug.pl(3,'nHeader_key_pos: ',nHeader_key_pos);

         xProgress := 'POCOB-20-1023';
         ece_flatfile_pvt.find_pos(l_header_tbl,'RELEASE_NUMBER',nRelease_num_pos);
         ec_debug.pl(3,'nRelease_num_pos: ',nRelease_num_pos);

         xProgress := 'POCOB-20-1024';
         ece_flatfile_pvt.find_pos(l_header_tbl,'PO_RELEASE_ID',nRelease_id_pos);
         ec_debug.pl(3,'nRelease_id_pos: ',nRelease_id_pos);

         xProgress := 'POCOB-20-1025';
         ece_flatfile_pvt.find_pos(l_header_tbl,'DOCUMENT_TYPE',nDocument_type_pos);
         ec_debug.pl(3,'nDocument_type_pos: ',nDocument_type_pos);

         -- Line Level Find Positions
         xProgress := 'POCOB-20-1026';
         ece_flatfile_pvt.find_pos(l_line_tbl,c_line_common_key_name,nLine_key_pos);
         ec_debug.pl(3,'nLine_key_pos: ',nLine_key_pos);

         xProgress := 'POCOB-20-1027';
         ece_flatfile_pvt.find_pos(l_line_tbl,'LINE_NUMBER',nLine_num_pos);
         ec_debug.pl(3,'nLine_num_pos: ',nLine_num_pos);

         xProgress := 'POCOB-20-1028';
         ece_flatfile_pvt.find_pos(l_line_tbl,'PO_LINE_LOCATION_ID',nPO_Line_Location_ID_pos);
         ec_debug.pl(3,'nPO_Line_Location_ID_pos: ',nPO_Line_Location_ID_pos);

         xProgress := 'POCOB-20-1029';
         ece_flatfile_pvt.find_pos(l_line_tbl,'ITEM_ID',nItem_id_pos);
         ec_debug.pl(3,'nItem_id_pos: ',nItem_id_pos);

         -- Shipment Level Find Positions
         xProgress := 'POCOB-20-1030';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,'LINE_LOCATION_ID',nLine_Location_ID_pos);
         ec_debug.pl(3,'nLine_Location_ID_pos: ',nLine_Location_ID_pos);

         xProgress := 'POCOB-20-1032';
         ece_flatfile_pvt.find_pos(l_shipment_tbl,c_shipment_key_name,nShipment_key_pos);
         ec_debug.pl(3,'nShipment_key_pos: ',nShipment_key_pos);

         -- Build SELECT Statement
         xProgress := 'POCOB-20-1035';
         cHeader_where     := cHeader_where                               ||
                              ' AND '                                     ||
                              cHeader_Interface                           ||
                              '.run_id = '                                ||
                              ':Run_id';

         cLine_where       := cLine_where                                 ||
                              ' AND '                                     ||
                              cLine_Interface                             ||
                              '.run_id = '                                ||
                              ':Run_id'                                   ||
                              ' AND '                                     ||
                              cLine_Interface                             ||
                              '.po_header_id = :po_header_id AND '        ||
                              cLine_Interface                             ||
                              '.release_number = :por_release_num';

         cShipment_where   := cShipment_where                             ||
                              ' AND '                                     ||
                              cShipment_Interface                         ||
                              '.RUN_ID ='                                 ||
                              ':Run_id'                                   ||
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

         xProgress := 'POCOB-20-1040';
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

         xProgress := 'POCOB-20-1050';
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

         xProgress := 'POCOB-20-1060';
         cHeader_delete1   := 'DELETE FROM ' || cHeader_Interface     || ' WHERE rowid = :col_rowid';
         ec_debug.pl(3,'cHeader_delete1: ',cHeader_delete1);

         cLine_delete1     := 'DELETE FROM ' || cLine_Interface       || ' WHERE rowid = :col_rowid';
         ec_debug.pl(3,'cLine_delete1: ',cLine_delete1);

         cShipment_delete1 := 'DELETE FROM ' || cShipment_Interface   || ' WHERE rowid = :col_rowid';
         ec_debug.pl(3,'cShipment_delete1: ',cShipment_delete1);

         xProgress := 'POCOB-20-1070';
         cHeader_delete2   := 'DELETE FROM ' || cHeader_X_Interface   || ' WHERE rowid = :col_rowid';
         ec_debug.pl(3,'cHeader_delete2: ',cHeader_delete2);

         cLine_delete2     := 'DELETE FROM ' || cLine_X_Interface     || ' WHERE rowid = :col_rowid';
         ec_debug.pl(3,'cLine_delete2: ',cLine_delete2);

         cShipment_delete2 := 'DELETE FROM ' || cShipment_X_Interface || ' WHERE rowid = :col_rowid';
         ec_debug.pl(3,'cShipment_delete2: ',cShipment_delete2);

         -- ***************************************************
         -- ***   Get data setup for the dynamic SQL call.
         -- ***   Open a cursor for each of the SELECT call
         -- ***   This tells the database to reserve spaces
         -- ***   for the data returned by the SQL statement
         -- ***************************************************
         xProgress         := 'POCOB-20-1080';
         header_sel_c      := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1090';
         line_sel_c        := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1100';
         shipment_sel_c    := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1110';
         header_del_c1     := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1120';
         line_del_c1       := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1130';
         shipment_del_c1   := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1140';
         header_del_c2     := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1150';
         line_del_c2       := dbms_sql.open_cursor;

         xProgress         := 'POCOB-20-1160';
         shipment_del_c2   := dbms_sql.open_cursor;

         -- *****************************************
         -- Parse each of the SELECT statement
         -- so the database understands the command
         -- *****************************************
         xProgress := 'POCOB-20-1170';
         BEGIN
            dbms_sql.parse(header_sel_c,cHeader_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1180';
         BEGIN
            dbms_sql.parse(line_sel_c,cLine_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1190';
         BEGIN
            dbms_sql.parse(shipment_sel_c,cShipment_select,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cShipment_select);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1200';
         BEGIN
            dbms_sql.parse(Header_del_c1,cHeader_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1210';
         BEGIN
            dbms_sql.parse(Line_del_c1,cLine_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1220';
         BEGIN
            dbms_sql.parse(shipment_del_c1,cShipment_delete1,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cShipment_delete1);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1230';
         BEGIN
            dbms_sql.parse(header_del_c2,cHeader_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cHeader_delete2);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1240';
         BEGIN
            dbms_sql.parse(line_del_c2,cLine_delete2,dbms_sql.native);

         EXCEPTION
            WHEN OTHERS THEN
               ece_error_handling_pvt.print_parse_error(dbms_sql.last_error_position,cLine_delete2);
               app_exception.raise_exception;

         END;

         xProgress := 'POCOB-20-1250';
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
         xProgress       := 'POCOB-20-1260';
         iHeader_count   := l_header_tbl.COUNT;
         iLine_count     := l_line_tbl.COUNT;
         iShipment_count := l_shipment_tbl.COUNT;

         ec_debug.pl(3,'iHeader_count: '  ,iHeader_count);
         ec_debug.pl(3,'iLine_count: '    ,iLine_count);
         ec_debug.pl(3,'iShipment_count: ',iShipment_count);

         -- ******************************************************
         --  Define TYPE for every columns in the SELECT statement
         --  For each piece of the data returns, we need to tell
         --  the database what type of information it will be.
         --  e.g. ID is NUMBER, due_date is DATE
         --  However, for simplicity, we will convert
         --  everything to varchar2.
         -- ******************************************************
         xProgress := 'POCOB-20-1270';
         ece_flatfile_pvt.define_interface_column_type(header_sel_c,
                                                       cHeader_select,
                                                       ece_flatfile_pvt.G_MaxColWidth,
                                                       l_header_tbl);

         -- ***************************************************
         -- Need rowid for delete (Header Level)
         -- ***************************************************
         xProgress := 'POCOB-20-1280';
         dbms_sql.define_column_rowid(header_sel_c,iHeader_count + 1,rHeader_rowid);

         xProgress := 'POCOB-20-1290';
         dbms_sql.define_column_rowid(header_sel_c,iHeader_count + 2,rHeader_X_rowid);

         xProgress := 'POCOB-20-1300';
         dbms_sql.define_column(header_sel_c,iHeader_count + 3,n_po_header_id);

         xProgress := 'POCOB-20-1310';
         ece_flatfile_pvt.define_interface_column_type(line_sel_c,cLine_select,ece_flatfile_pvt.G_MaxColWidth,l_line_tbl);

         -- ***************************************************
         -- Need rowid for delete (Line Level)
         -- ***************************************************
         xProgress := 'POCOB-20-1320';
         dbms_sql.define_column_rowid(line_sel_c,iLine_count + 1,rLine_rowid);

         xProgress := 'POCOB-20-1330';
         dbms_sql.define_column_rowid(line_sel_c,iLine_count + 2,rLine_X_rowid);

         xProgress := 'POCOB-20-1340';
         dbms_sql.define_column(line_sel_c,iLine_count + 3,n_po_line_id);

         xProgress := 'POCOB-20-1350';
         ece_flatfile_pvt.define_interface_column_type(Shipment_sel_c,cShipment_select,ece_flatfile_pvt.G_MaxColWidth,l_Shipment_tbl);

         -- ***************************************************
         -- Need rowid for delete (Shipment Level)
         -- ***************************************************
         xProgress := 'POCOB-20-1360';
         dbms_sql.define_column_rowid(Shipment_sel_c,iShipment_count + 1,rShipment_rowid);

         xProgress := 'POCOB-20-1370';
         dbms_sql.define_column_rowid(Shipment_sel_c,iShipment_count + 2,rShipment_X_rowid);

         xProgress := 'POCOB-20-1375';
         dbms_sql.bind_variable(header_sel_c,'Run_id',iRun_id);
         dbms_sql.bind_variable(line_sel_c,'Run_id',iRun_id);
         dbms_sql.bind_variable(shipment_sel_c,'Run_id',iRun_id);


         --- EXECUTE the SELECT statement
         xProgress := 'POCOB-20-1380';
         dummy := dbms_sql.execute(header_sel_c);

         -- ********************************************************************
         -- ***   With data for each HEADER line, populate the ECE_OUTPUT table
         -- ***   then populate ECE_OUTPUT with data from all LINES that belongs
         -- ***   to the HEADER. Then populate ECE_OUTPUT with data from all
         -- ***   LINE TAX that belongs to the LINE.
         -- ********************************************************************

         -- HEADER - LINE - SHIPMENT ...
         xProgress := 'POCOB-20-1390';
         WHILE dbms_sql.fetch_rows(header_sel_c) > 0 LOOP           -- Header
            -- ******************************
            --   store values in pl/sql table
            -- ******************************
            xProgress := 'POCOB-20-1400';
            ece_flatfile_pvt.assign_column_value_to_tbl(header_sel_c,l_header_tbl);

            xProgress := 'POCOB-20-1410';
            dbms_sql.column_value(header_sel_c,iHeader_count + 1,rHeader_rowid);

            xProgress := 'POCOB-20-1420';
            dbms_sql.column_value(header_sel_c,iHeader_count + 2,rHeader_X_rowid);

            xProgress := 'POCOB-20-1430';
            dbms_sql.column_value(header_sel_c,iHeader_count + 3,n_po_header_id);

            xProgress := 'POCOB-20-1440';
            nRelease_num := l_header_tbl(nRelease_num_pos).value;
            ec_debug.pl(3,'nRelease_num: ',nRelease_num);

            xProgress := 'POCOB-20-1450';
            nRelease_ID := l_header_tbl(nRelease_id_pos).value;
            ec_debug.pl(3,'nRelease_ID: ',nRelease_ID);

            BEGIN
               xProgress := 'POCOB-20-1455';
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

            xProgress         := 'POCOB-20-1460';
            c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),1,25),25);

            xProgress         := 'POCOB-20-1470';
            c_file_common_key := c_file_common_key ||
                                 RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),1,22),22) || RPAD(' ',22) || RPAD(' ',22);

            ec_debug.pl(3,'c_file_common_key: ',c_file_common_key);

            xProgress := 'POCOB-20-1480';
            ece_poo_transaction.write_to_file(cTransaction_Type,
                                                 cCommunication_Method,
                                                 cHeader_Interface,
                                                 l_header_tbl,
                                                 iOutput_width,
                                                 iRun_id,
                                                 c_file_common_key,
                                                 null );

            IF l_document_type = 'NR' THEN -- If this is a Release PO.
               xProgress := 'POCOB-20-1481';
               v_entity_name := 'PO_RELEASES';
               v_pk1_value := nRelease_ID;
               ec_debug.pl(3,'release_id: ',nRelease_ID);
            ELSE -- If this is a non-Release PO.
               xProgress := 'POCOB-20-1482';
               v_entity_name := 'PO_HEADERS';
               v_pk1_value := n_po_header_id;
               ec_debug.pl(3,'po_header_id: ',n_po_header_id);
            END IF;

            xProgress := 'POCOB-20-1483';
            ece_poo_transaction.put_att_to_output_table(cCommunication_Method,
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
            xProgress := 'POCOB-20-1490';
            dbms_sql.bind_variable(line_sel_c,'po_header_id',n_po_header_id);

            xProgress := 'POCOB-20-1500';
            dbms_sql.bind_variable(shipment_sel_c,'po_header_id',n_po_header_id);

            xProgress := 'POCOB-20-1505';
            dbms_sql.bind_variable(line_sel_c,'por_release_num',nRelease_num);

            xProgress := 'POCOB-20-1506';
            dbms_sql.bind_variable(shipment_sel_c,'por_release_num',nRelease_num);

            xProgress := 'POCOB-10-1510';
            dummy := dbms_sql.execute(line_sel_c);

            -- ***************************************************
            -- line loop starts here
            -- ***************************************************
            xProgress := 'POCOB-20-1520';
            WHILE dbms_sql.fetch_rows(line_sel_c) > 0 LOOP     --- Line

               -- ***************************************************
               --   store values in pl/sql table
               -- ***************************************************
               xProgress := 'POCOB-20-1530';
               ece_flatfile_pvt.assign_column_value_to_tbl(line_sel_c,l_line_tbl);

               xProgress := 'POCOB-20-1533';
               dbms_sql.column_value(line_sel_c,iLine_count + 1,rLine_rowid);

               xProgress := 'POCOB-20-1535';
               dbms_sql.column_value(line_sel_c,iLine_count + 2,rLine_X_rowid);

               xProgress := 'POCOB-20-1537';
               dbms_sql.column_value(line_sel_c,iLine_count + 3,n_po_line_id);
               ec_debug.pl(3,'n_po_line_id: ',n_po_line_id);

               xProgress := 'POCOB-20-1540';
               nLine_num := l_line_tbl(nLine_num_pos).value;
               ec_debug.pl(3,'nLine_num: ',nLine_num);

               xProgress := 'POCOB-20-1544';
               nPO_Line_Location_ID := l_line_tbl(nPO_Line_Location_ID_pos).value;
               ec_debug.pl(3,'nPO_Line_Location_ID: ',nPO_Line_Location_ID);

               xProgress := 'POCOB-20-1545';
               nItem_ID := l_line_tbl(nItem_id_pos).value;
               ec_debug.pl(3,'nItem_ID: ',nItem_ID);

               xProgress := 'POCOB-20-1550';
               c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value,' '),1,25),25) ||
                                    RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value,' '),1,22),22) ||
                                    RPAD(SUBSTRB(NVL(l_line_tbl(nLine_key_pos).value    ,' '),1,22),22) ||
                                    RPAD(' ',22);
               ec_debug.pl(3,'c_file_common_key: ',c_file_common_key);

               xProgress := 'POCOB-20-1551';
               ece_poo_transaction.write_to_file(cTransaction_Type,
                                                    cCommunication_Method,
                                                    cLine_Interface,
                                                    l_line_tbl,
                                                    iOutput_width,
                                                    iRun_id,
                                                    c_file_common_key,
                                                    null);

               -- Line Level Attachment Handler
 /* Bug 2235872  IF l_document_type = 'NR' THEN -- If this is a Release PO.
                  xProgress := 'POCOB-20-1552';
                  v_entity_name := 'PO_SHIPMENTS';
                  v_pk1_value := nPO_Line_Location_ID; -- LINE_LOCATION_ID
               ELSE -- If this is a non-Release PO. */
                  xProgress := 'POCOB-20-1553';
                  v_entity_name := 'PO_LINES';
                  v_pk1_value := n_po_line_id; -- LINE_ID
            --   END IF;

               xProgress := 'POCOB-20-1554';
               ece_poo_transaction.put_att_to_output_table(cCommunication_Method,
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
               xProgress := 'POCOB-20-1555';
               v_entity_name := 'MTL_SYSTEM_ITEMS';
               v_pk1_value := nOrganization_ID; -- Master Inventory Org ID
               ec_debug.pl(3,'Master Org ID: ',v_pk1_value);

               v_pk2_value := nItem_ID;     -- Item ID
               ec_debug.pl(3,'Item ID: ',v_pk2_value);

               xProgress := 'POCOB-20-1556';
               ece_poo_transaction.put_att_to_output_table(cCommunication_Method,
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

               -- Inventory Item Attachment Handler
               xProgress := 'POCOB-20-1557';
               FOR v_org_id IN c_org_id(n_po_line_id) LOOP -- Value passed is the Line ID
                  IF v_org_id.ship_to_organization_id <> nOrganization_ID THEN -- Only do this if it is not the same as the Master Org ID
                     v_pk1_value := v_org_id.ship_to_organization_id;
                     ec_debug.pl(3,'Inventory Org ID: ',v_pk1_value);

                     xProgress := 'POCOB-20-1558';
                     ece_poo_transaction.put_att_to_output_table(cCommunication_Method,
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

               -- **************************
               --   set LINE_NUMBER values
               -- **************************
               xProgress := 'POCOB-20-1560';
               dbms_sql.bind_variable(shipment_sel_c,'po_line_id',n_po_line_id);

               xProgress := 'POCOB-20-1575';
               dbms_sql.bind_variable(shipment_sel_c,'shipment_number',nLine_num);

               xProgress := 'POCOB-20-1580';
               dummy := dbms_sql.execute(shipment_sel_c);

               -- ****************************
               --  Shipment loop starts here
               -- ****************************
               xProgress := 'POCOB-20-1590';
               WHILE dbms_sql.fetch_rows(shipment_sel_c) > 0 LOOP    --- Shipments

                  -- *********************************
                  --  store values in pl/sql table
                  -- *********************************
                  xProgress := 'POCOB-20-1600';
                  ece_flatfile_pvt.assign_column_value_to_tbl(shipment_sel_c,l_shipment_tbl);

                  xProgress := 'POCOB-20-1603';
                  dbms_sql.column_value(shipment_sel_c,iShipment_count + 1,rShipment_rowid);

                  xProgress := 'POCOB-20-1606';
                  dbms_sql.column_value(shipment_sel_c,iShipment_count + 2,rShipment_X_rowid);

                  xProgress := 'POCOB-20-1610';
                  nLine_Location_ID := l_shipment_tbl(nLine_Location_ID_pos).value;
                  ec_debug.pl(3,'Ship Level Line Location ID: ',nLine_Location_ID);

                  xProgress := 'POCOB-20-1620';
                  c_file_common_key := RPAD(SUBSTRB(NVL(l_header_tbl(nTrans_code_pos).value    ,' '),1,25),25) ||
                                       RPAD(SUBSTRB(NVL(l_header_tbl(nHeader_key_pos).value    ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_line_tbl(nLine_key_pos).value        ,' '),1,22),22) ||
                                       RPAD(SUBSTRB(NVL(l_shipment_tbl(nShipment_key_pos).value,' '),1,22),22);
                  ec_debug.pl(3, 'c_file_common_key: ',c_file_common_key);

                  xProgress := 'POCOB-20-1630';
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

                  xProgress := 'POCOB-20-1632';
                  ece_poo_transaction.put_att_to_output_table(cCommunication_Method,
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
                  xProgress := 'POCOB-20-1634';
        -- IF v_project_acct_status = 'I' THEN -- Project Accounting is Installed bug1891291
                     ece_poo_transaction.put_distdata_to_out_tbl(
                        cCommunication_Method,
                        cTransaction_Type,
                        iOutput_width,
                        iRun_id,
                        cProject_Interface,
                        n_po_header_ID,      -- PO_HEADER_ID
                        nRelease_ID,         -- PO_RELEASE_ID
                        n_po_line_ID,        -- PO_LINE_ID
                        nLine_Location_ID,   -- LINE_LOCATION_ID
                        c_file_common_key);
               --   END IF;

                  xProgress := 'POCOB-20-1640';
                  dbms_sql.bind_variable(shipment_del_c1,'col_rowid',rShipment_rowid);

                  xProgress := 'POCOB-20-1650';
                  dbms_sql.bind_variable(shipment_del_c2,'col_rowid',rShipment_X_rowid);

                  xProgress := 'POCOB-20-1660';
                  dummy := dbms_sql.execute(shipment_del_c1);

                  xProgress := 'POCOB-20-1670';
                  dummy := dbms_sql.execute(shipment_del_c2);

               END LOOP; -- Shipment Level

               xProgress := 'POCOB-20-1674';
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
               xProgress := 'POCOB-20-1680';
               dbms_sql.bind_variable(line_del_c1,'col_rowid',rLine_rowid);

               xProgress := 'POCOB-20-1690';
               dbms_sql.bind_variable(line_del_c2,'col_rowid',rLine_X_rowid);

               xProgress := 'POCOB-20-1700';
               dummy := dbms_sql.execute(line_del_c1);

               xProgress := 'POCOB-20-1710';
               dummy := dbms_sql.execute(line_del_c2);

            END LOOP; -- Line Level

            xProgress := 'POCOB-20-1714';
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

            xProgress := 'POCOB-20-1720';
            dbms_sql.bind_variable(header_del_c1,'col_rowid',rHeader_rowid);

            xProgress := 'POCOB-20-1730';
            dbms_sql.bind_variable(header_del_c2,'col_rowid',rHeader_X_rowid);

            xProgress := 'POCOB-20-1740';
            dummy := dbms_sql.execute(header_del_c1);

            xProgress := 'POCOB-20-1750';
            dummy := dbms_sql.execute(header_del_c2);

         END LOOP; -- Header Level

         xProgress := 'POCOB-20-1754';
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

         xProgress := 'POCOB-20-1760';
         dbms_sql.close_cursor(header_sel_c);

         xProgress := 'POCOB-20-1770';
         dbms_sql.close_cursor(line_sel_c);

         xProgress := 'POCOB-20-1780';
         dbms_sql.close_cursor(shipment_sel_c);

         xProgress := 'POCOB-20-1790';
         dbms_sql.close_cursor(header_del_c1);

         xProgress := 'POCOB-20-1800';
         dbms_sql.close_cursor(line_del_c1);

         xProgress := 'POCOB-20-1812';
         dbms_sql.close_cursor(shipment_del_c1);

         xProgress := 'POCOB-20-1814';
         dbms_sql.close_cursor(header_del_c2);

         xProgress := 'POCOB-20-1816';
         dbms_sql.close_cursor(line_del_c2);

         xProgress := 'POCOB-20-1818';
         dbms_sql.close_cursor(shipment_del_c2);

         -- Bug 2490109 Closing the distribution cursors.
         xProgress := 'POCOB-50-1819';
         if (ece_poo_transaction.project_sel_c>0) then     --Bug 2819176
         dbms_sql.close_cursor(ece_poo_transaction.project_sel_c);

         xProgress := 'POCOB-50-1820';
         dbms_sql.close_cursor(ece_poo_transaction.project_del_c1);

         xProgress := 'POCOB-50-1821';
         dbms_sql.close_cursor(ece_poo_transaction.project_del_c2);
         end if;

         xProgress := 'POCOB-20-1820';
         ec_debug.pop('ECE_POCO_TRANSACTION.PUT_DATA_TO_OUTPUT_TABLE');

      EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);

            app_exception.raise_exception;

      END put_data_to_output_table;

END ece_poco_transaction;


/
