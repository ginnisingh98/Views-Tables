--------------------------------------------------------
--  DDL for Package Body OKL_CONS_BILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CONS_BILL" AS
/* $Header: OKLRKONB.pls 120.27.12010000.2 2008/12/12 20:28:19 cklee ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.BILLING';
  L_DEBUG_ENABLED VARCHAR2(10);
--  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

--This function checks for the existence of an consolidated invoice
-- in okl_cnsld_ar_hdrs_v

--This procedure creates a new consolidated invoice header
--based on the parameters passed

PROCEDURE process_break(
           p_contract_number    IN  VARCHAR2,
           p_commit             IN  VARCHAR2,
           saved_bill_rec       IN OUT NOCOPY saved_bill_rec_type,
           l_update_tbl         IN OUT NOCOPY update_tbl_type)
IS

    l_old_cnr_id                NUMBER;
    l_old_lln_id                NUMBER;
    l_cnr_amount                okl_cnsld_ar_hdrs_v.amount%TYPE;
    l_lln_amount                okl_cnsld_ar_lines_v.amount%TYPE;

    CURSOR cnr_amt_csr ( p_cnr_id IN NUMBER ) IS
            SELECT SUM(lsm.amount)
            FROM okl_cnsld_ar_hdrs_b cnr,
                 okl_cnsld_ar_lines_b lln,
                 okl_cnsld_ar_strms_b lsm
            WHERE cnr.id = p_cnr_id   AND
                  cnr.id = lln.cnr_id AND
                  lln.id = lsm.lln_id;

    CURSOR lln_amt_csr ( p_lln_id IN NUMBER ) IS
            SELECT SUM(lsm.amount)
            FROM okl_cnsld_ar_lines_b lln,
                 okl_cnsld_ar_strms_b lsm
            WHERE lln.id = p_lln_id   AND
                  lln.id = lsm.lln_id;


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

    IF (L_DEBUG_ENABLED='Y' and  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'Process_Break Begin(+)');
    END IF;

   -- ------------------------------------
   -- Start header break detection logic
   -- ------------------------------------

   -- If there was no error processing any records then
   IF l_update_tbl.COUNT > 0 THEN

                 FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.cnr_id '||l_update_tbl(m).cnr_id);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.cons_inv_number '||l_update_tbl(m).cons_inv_number);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.lln_id '||l_update_tbl(m).lln_id);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.lsm_id '||l_update_tbl(m).lsm_id);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.asset_number '||l_update_tbl(m).asset_number);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.invoice_format '||l_update_tbl(m).invoice_format);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.line_type '||l_update_tbl(m).line_type);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.sty_name '||l_update_tbl(m).sty_name);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.contract_number '||l_update_tbl(m).contract_number);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.lsm_amount '||l_update_tbl(m).lsm_amount);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.xsi_id '||l_update_tbl(m).xsi_id);
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'l_update_tbl.xls_id '||l_update_tbl(m).xls_id);
                    END IF;
                 END LOOP;

        IF saved_bill_rec.l_overall_status IS NULL THEN

                 l_old_cnr_id := -9;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Updating Consolidated Invoice Header');
                 END IF;
                 FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                       IF l_update_tbl(m).cnr_id <> l_old_cnr_id THEN
                          l_cnr_amount := NULL;
                          OPEN  cnr_amt_csr ( l_update_tbl(m).cnr_id );
                          FETCH cnr_amt_csr INTO l_cnr_amount;
                          CLOSE cnr_amt_csr;

                          UPDATE okl_cnsld_ar_hdrs_b
                          SET trx_status_code = 'PROCESSED',
                              amount = l_cnr_amount,
                              last_update_date = sysdate,
                              last_updated_by = Fnd_Global.USER_ID,
                              last_update_login = Fnd_Global.LOGIN_ID
                          WHERE id = l_update_tbl(m).cnr_id;

                          l_old_cnr_id := l_update_tbl(m).cnr_id;
                       END IF;
                 END LOOP;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Done updating Consolidated Invoice Header');
                 END IF;

                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Updating Consolidated Invoice Line');
                 END IF;
                 l_old_lln_id  := -9;
                 FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                       IF l_update_tbl(m).lln_id <> l_old_lln_id THEN
                          l_lln_amount := NULL;
                          OPEN  lln_amt_csr( l_update_tbl(m).lln_id );
                          FETCH lln_amt_csr INTO l_lln_amount;
                          CLOSE lln_amt_csr;

                          UPDATE okl_cnsld_ar_lines_b
                          SET amount = l_lln_amount,
                              last_update_date = sysdate,
                              last_updated_by = Fnd_Global.USER_ID,
                              last_update_login = Fnd_Global.LOGIN_ID
                          WHERE id = l_update_tbl(m).lln_id;

                          l_old_lln_id := l_update_tbl(m).lln_id;
                       END IF;
                 END LOOP;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Done updating Consolidated Invoice Line');
                 END IF;

                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Updating External Transaction Header');
                 END IF;
                 IF p_contract_number IS NULL THEN
                        FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                              UPDATE Okl_Ext_Sell_Invs_b
                              SET TRX_STATUS_CODE = 'WORKING',
                                  XTRX_INVOICE_PULL_YN = 'Y',
                                  last_update_date = sysdate,
                                  last_updated_by = Fnd_Global.USER_ID,
                                  last_update_login = Fnd_Global.LOGIN_ID
                              WHERE id = l_update_tbl(m).xsi_id;
                        END LOOP;
                  ELSE
                        FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                              UPDATE Okl_Ext_Sell_Invs_b
                              SET TRX_STATUS_CODE = 'ENTERED',
                                  XTRX_INVOICE_PULL_YN = 'Y',
                                  last_update_date = sysdate,
                                  last_updated_by = Fnd_Global.USER_ID,
                                  last_update_login = Fnd_Global.LOGIN_ID
                              WHERE id = l_update_tbl(m).xsi_id;
                        END LOOP;
                  END IF;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Done updating External Transaction Header');
                 END IF;

                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Updating External Transaction Line');
                 END IF;
                  FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                      UPDATE Okl_Ext_Sell_Invs_tl
                      SET XTRX_CONS_INVOICE_NUMBER = l_update_tbl(m).cons_inv_number,
                          XTRX_FORMAT_TYPE = l_update_tbl(m).invoice_format,
                          XTRX_PRIVATE_LABEL = l_update_tbl(m).private_label,
                          last_update_date = sysdate,
                          last_updated_by = Fnd_Global.USER_ID,
                          last_update_login = Fnd_Global.LOGIN_ID
                      WHERE id = l_update_tbl(m).xsi_id;

                      UPDATE Okl_Xtl_Sell_Invs_b
                      SET LSM_ID = l_update_tbl(m).LSM_ID,
--                          XTRX_CONS_LINE_NUMBER = l_update_tbl(m).line_number,
                          XTRX_CONS_STREAM_ID = l_update_tbl(m).lsm_id,
                          last_update_date = sysdate,
                          last_updated_by = Fnd_Global.USER_ID,
                          last_update_login = Fnd_Global.LOGIN_ID
                      WHERE id = l_update_tbl(m).xls_id;

                      UPDATE Okl_Xtl_Sell_Invs_tl
                      SET XTRX_CONTRACT = l_update_tbl(m).contract_number,
                          XTRX_ASSET = l_update_tbl(m).asset_number,
                          XTRX_STREAM_TYPE = l_update_tbl(m).sty_name,
                          XTRX_STREAM_GROUP = l_update_tbl(m).line_type,
                          last_update_date = sysdate,
                          last_updated_by = Fnd_Global.USER_ID,
                          last_update_login = Fnd_Global.LOGIN_ID
                      WHERE id = l_update_tbl(m).xls_id;
                  END LOOP;
                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Done updating External Transaction Line');
                 END IF;
        ELSE -- goes with check of overall status

                 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Updating Concolidated Header Status to Error');
                 END IF;
                  l_old_cnr_id := -9;
                  FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                       IF l_update_tbl(m).cnr_id <> l_old_cnr_id THEN

                          UPDATE okl_cnsld_ar_hdrs_b
                          SET trx_status_code = 'ERROR',
                              amount = l_cnr_amount,
                              last_update_date = sysdate,
                              last_updated_by = Fnd_Global.USER_ID,
                              last_update_login = Fnd_Global.LOGIN_ID
                          WHERE id = l_update_tbl(m).cnr_id;

                          l_old_cnr_id := l_update_tbl(m).cnr_id;
                       END IF;
                  END LOOP;

                  -- ----------------------------------------------
                  -- Delete LSM LLN and CNR records
                  -- ----------------------------------------------
                  FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                        DELETE FROM okl_cnsld_ar_strms_b
                        WHERE id = l_update_tbl(m).lsm_id;

                        DELETE FROM okl_cnsld_ar_strms_tl
                        WHERE id = l_update_tbl(m).lsm_id;

                  END LOOP;

                  FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                        DELETE FROM okl_cnsld_ar_lines_b
                        WHERE id = l_update_tbl(m).lln_id;

                        DELETE FROM okl_cnsld_ar_lines_tl
                        WHERE id = l_update_tbl(m).lln_id;
                  END LOOP;

                  FOR m in l_update_tbl.FIRST..l_update_tbl.LAST LOOP
                        DELETE FROM okl_cnsld_ar_hdrs_b
                        WHERE id = l_update_tbl(m).cnr_id;

                        DELETE FROM okl_cnsld_ar_hdrs_tl
                        WHERE id = l_update_tbl(m).cnr_id;

                  END LOOP;
        END IF;

        -- ------------------------------------
        -- End header break detection logic
        -- ------------------------------------
   END IF;-- If any records exist for updating

   IF saved_bill_rec.l_commit_cnt > G_Commit_Max THEN
         IF FND_API.To_Boolean( p_commit ) THEN
              COMMIT;
         END IF;
         saved_bill_rec.l_commit_cnt := 0;
   END IF;

    IF (L_DEBUG_ENABLED='Y' and  FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'Process_Break End(-)');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF (L_DEBUG_ENABLED='Y' and  FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION (OTHERS) :'||SQLERRM);
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'EXCEPTION in Procedure Process_Break: '||SQLERRM);
     END IF;
END process_break;

FUNCTION get_invoice_group(p_khr_id NUMBER)
RETURN VARCHAR2 IS
CURSOR grp_csr ( cp_khr_id NUMBER ) IS
    select RULE_INFORMATION1
    from okc_rule_groups_v      rgp,
        okc_rules_v            rul
    where rgp.dnz_chr_id = cp_khr_id AND
    rgp.chr_id             = rgp.dnz_chr_id                  AND
    rgp.id                 = rul.rgp_id                      AND
    rgp.cle_id             IS NULL                           AND
    rgp.rgd_code           = 'LABILL'                        AND
    rul.rule_information_category = 'LAINVD';

    l_grp    okc_rules_v.rule_information1%type:= 'NONE';

BEGIN

    OPEN grp_csr(p_khr_id);
    FETCH grp_csr INTO l_grp;
    CLOSE grp_csr;

    return l_grp;

END get_invoice_group;

PROCEDURE create_new_invoice(
		  		p_ibt_id            IN NUMBER,
		  		p_ixx_id            IN NUMBER,
		  		p_currency_code     IN VARCHAR2,
		  		p_irm_id            IN NUMBER,
		  		p_inf_id	     IN NUMBER,
		  		p_set_of_books_id   IN NUMBER,
		  		p_private_label     IN VARCHAR2,
				p_date_consolidated IN DATE,
				p_org_id	     IN NUMBER,
				p_legal_entity_id   IN NUMBER,       -- for LE Uptake project 08-11-2006
				x_cnr_id	     OUT NOCOPY NUMBER,
                                x_cons_inv_num      OUT NOCOPY VARCHAR2
			   )
IS

   x_cnrv_rec Okl_Cnr_Pvt.cnrv_rec_type;
   x_cnrv_tbl Okl_Cnr_Pvt.cnrv_tbl_type;

   p_cnrv_rec  Okl_Cnr_Pvt.cnrv_rec_type;
   p_cnrv_tbl  Okl_Cnr_Pvt.cnrv_tbl_type;

   p_imav_rec  Okl_ima_pvt.imav_rec_type;
   x_imav_rec  Okl_ima_pvt.imav_rec_type;


   p_api_version                  NUMBER := 1.0;
   p_init_msg_list                VARCHAR2(1) := Okl_Api.g_false;
   x_return_status                VARCHAR2(1);
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);
   -- For automatic generation of sequence numbers from
   -- the database
   l_Invoice_Number          NUMBER    := '';
   l_document_category 		 VARCHAR2(100):= 'OKL Lease Receipt Invoices';
   l_application_id 	 	 NUMBER(3) := 540 ;
   x_dbseqnm 				 VARCHAR2(100):= NULL;
   x_dbseqid 				 NUMBER;

   -- fmiao 5232919 modification start
   -- Added clause to restrict based on consolidated invoice date
   CURSOR msg_csr (cp_consolidated_inv_date DATE) IS
   		  SELECT id,
		  		 priority,
		  		 pkg_name,
				 proc_name
		  FROM okl_invoice_mssgs_v
                  WHERE cp_consolidated_inv_date
                         BETWEEN NVL(START_DATE,cp_consolidated_inv_date) AND
                                 NVL(END_DATE,cp_consolidated_inv_date);
   -- fmiao 5232919 change end

   l_save_priority			 okl_invoice_mssgs_v.priority%TYPE;
   l_save_ims_id			 okl_invoice_mssgs_v.id%TYPE;

   l_priority				 okl_invoice_mssgs_v.priority%TYPE;
   l_pkg_name				 okl_invoice_mssgs_v.pkg_name%TYPE;
   l_proc_name				 okl_invoice_mssgs_v.proc_name%TYPE;

   l_bind_proc               VARCHAR2(3000);
   l_msg_return				 VARCHAR2(1); --BOOLEAN;
   l_ims_id					 okl_invoice_mssgs_v.id%TYPE;


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** HEADER RECORD CREATION FOR : ***');
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CUSTOMER_ID: '||p_ixx_id||' CURRENCY: '||p_currency_code);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  BILL_TO_SITE: '||p_ibt_id||' PAYMENT_METHOD: '||p_irm_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  PRIVATE_LABEL: '||p_private_label||' DATE_CONSOLIDATED: '||p_date_consolidated);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  INF_ID: '||p_inf_id||' SET_OF_BOOKS_ID: '||p_set_of_books_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  ORG_ID: '||p_org_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
  END IF;

	 p_cnrv_rec.IBT_ID                          := p_ibt_id;
	 p_cnrv_rec.IXX_ID                          := p_ixx_id;
	 p_cnrv_rec.CURRENCY_CODE                   := p_currency_code;
	 p_cnrv_rec.IRM_ID                          := p_irm_id;
	 p_cnrv_rec.INF_ID                          := p_inf_id;
	 p_cnrv_rec.SET_OF_BOOKS_ID                 := p_set_of_books_id;
	 p_cnrv_rec.ORG_ID                 	    := p_org_id;
	 p_cnrv_rec.LEGAL_ENTITY_ID                 := p_legal_entity_id; -- for LE Uptake project 08-11-2006
	 -- Added to support date in the consolidation hierarchy
	 -- 02/28/2002
	 p_cnrv_rec.date_consolidated               := p_date_consolidated;


	 -- DB generated sequence number for the Consolidated Invoice
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====> Generating Cons Bill SEQUENCE');
     END IF;
   	 l_Invoice_Number := Fnd_Seqnum.get_next_sequence (l_application_id,
   					   								 l_document_category,
   													 p_set_of_books_id,
   													 'A',
  													 SYSDATE,
  													 x_dbseqnm,
  													 x_dbseqid);

     p_cnrv_rec.CONSOLIDATED_INVOICE_NUMBER  := TO_CHAR(l_invoice_number);

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====> Cons Bill Number: '||p_cnrv_rec.CONSOLIDATED_INVOICE_NUMBER);
     END IF;

   	 p_cnrv_rec.INVOICE_PULL_YN                 := 'Y';
   	 p_cnrv_rec.PRIVATE_LABEL_LOGO_URL          := p_private_label;
   	 p_cnrv_rec.trx_status_code          	   := 'SUBMITTED';

-- Start of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Hdrs_Pub.INSERT_CNSLD_AR_HDRS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call Okl_Cnsld_Ar_Hdrs_Pub.INSERT_CNSLD_AR_HDRS ');
    END;
  END IF;
   	 Okl_Cnsld_Ar_Hdrs_Pub.INSERT_CNSLD_AR_HDRS(
     					 p_api_version
    					,p_init_msg_list
    					,x_return_status
    					,x_msg_count
    					,x_msg_data
    					,p_cnrv_rec
    					,x_cnrv_rec
     );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call Okl_Cnsld_Ar_Hdrs_Pub.INSERT_CNSLD_AR_HDRS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Hdrs_Pub.INSERT_CNSLD_AR_HDRS

   IF ( x_return_status = 'S' ) THEN
       BEGIN
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> Consolidated Header Record Created');
         END IF;

	     -- Find message with the highest priority
	  	 l_save_priority := NULL;
                 -- fmiao - Bug#5232919 - Modified - Start
                 -- Added clause to restrict based on consolidated invoice date
	  	 FOR msg_csr_rec IN msg_csr(TRUNC(p_date_consolidated)) LOOP
                 --fmiao - Bug#5232919 - Modified - end
	  	  	 l_ims_id      := msg_csr_rec.id;
   	  	  	 l_priority	:= msg_csr_rec.priority;
   		  	 l_pkg_name	:= msg_csr_rec.pkg_name;
   		  	 l_proc_name	:= msg_csr_rec.proc_name;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
             	 	  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> IMS_ID: '||l_ims_id);
    	 	  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> PKG: '||l_pkg_name);
    	 	  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> PROC: '||l_proc_name);
         END IF;

             l_bind_proc := 'BEGIN OKL_QUAL_INV_MSGS.'||l_proc_name||'(:1,:2); END;';

--             EXECUTE IMMEDIATE l_bind_proc USING IN x_cnrv_rec.id RETURNING INTO l_msg_return;

             BEGIN
                 EXECUTE IMMEDIATE l_bind_proc USING IN x_cnrv_rec.id, OUT l_msg_return;
             EXCEPTION
                 WHEN OTHERS THEN
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Invoice Message error -- '||SQLERRM);
                  END IF;
             END;


		  	 IF (l_msg_return = '1' ) THEN
		  	 	IF l_save_priority IS NULL THEN
		  	 	   l_save_priority := l_priority;
				   l_save_ims_id   := l_ims_id;
		     	ELSE
		     		IF (l_priority < l_save_priority) THEN
		  	 	   	   l_save_priority := l_priority;
				   	   l_save_ims_id   := l_ims_id;
			 		END IF;
		        END IF;
		     END IF;
  	     END LOOP;
		  -- Create Intersection Record
		  IF (l_save_priority IS NOT NULL) THEN
		   	  p_imav_rec.CNR_ID  := x_cnrv_rec.id;
 			  p_imav_rec.IMS_ID  := l_save_ims_id;

-- Start of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
    END;
  END IF;
		  	  okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT(
	  	  		     p_api_version
    				,p_init_msg_list
    				,x_return_status
    				,x_msg_count
    				,x_msg_data
    				,p_imav_rec
    				,x_imav_rec
			  );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for okl_inv_mssg_att_pub.INSERT_INV_MSSG_ATT
   			  IF ( x_return_status = 'S' ) THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    		  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> Message Created.');
            END IF;
			  ELSE
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    		  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> FAILED:Message Creation');
            END IF;
			  END IF;
		  ELSE
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    	  	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> NO Message Qualified');
            END IF;
		  END IF;
	   EXCEPTION
	   		WHEN OTHERS THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    	  	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====> PROBLEMS WITH MESSAGING');
            END IF;
	   END;
   ELSE
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> FAILED: Consolidated Header NOT Created.');
      END IF;
   END IF;

   x_cnr_id := x_cnrv_rec.id;
   x_cons_inv_num := p_cnrv_rec.CONSOLIDATED_INVOICE_NUMBER;

EXCEPTION
     --Seed FND_MESSAGE like 'Could NOT CREATE Header RECORD'
	 WHEN OTHERS THEN
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(H1): '||SQLERRM);
     END IF;
   	      Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	      			   p_msg_name => G_OTHERS);
END create_new_invoice;

--This function checks for the existence of an consolidated invoice line
-- in okl_cnsld_ar_lines_v.This function is called when the
-- group_by_assets flag is set to 'Y'
PROCEDURE line_exist (p_cnr_id  		      IN NUMBER,
		 			  p_khr_id			 	  IN NUMBER,
					  p_kle_id				  IN NUMBER,
					  p_ilt_id			 	  IN NUMBER,
					  p_sequence_number 	  IN NUMBER,
					  p_group_by_contract_yn  IN VARCHAR2,
					  p_group_by_assets_yn    IN VARCHAR2,
					  x_lln_id			 	  OUT NOCOPY NUMBER,
					  exists_flag		 	  OUT NOCOPY VARCHAR2
		 			 )
IS

   	  CURSOR check_line1 ( p_cnr_id NUMBER, p_khr_id NUMBER, p_ilt_id NUMBER, p_sequence_number NUMBER ) IS
 	   		 SELECT id
	   		 FROM okl_cnsld_ar_lines_v
	   		 WHERE cnr_id 	       = p_cnr_id		 AND
	   	  	 	   khr_id 	  	   = p_khr_id		 AND
   		  	 	   ilt_id	  	   = p_ilt_id		 AND
		  	 	   sequence_number = p_sequence_number;

   	  CURSOR check_line2 (p_cnr_id NUMBER, p_khr_id NUMBER, p_kle_id NUMBER, p_ilt_id NUMBER ) IS
	   	  	 SELECT id
	   	  	 FROM okl_cnsld_ar_lines_v
	   	  	 WHERE cnr_id 	       = p_cnr_id		 AND
	   	  	 	   khr_id 	  	   = p_khr_id		 AND
			 	   kle_id 	  	   = p_kle_id		 AND
   		  		   ilt_id	  	   = p_ilt_id		 AND
		  		   sequence_number = p_sequence_number;

	  CURSOR check_line3 ( p_cnr_id NUMBER, p_khr_id NUMBER, p_ilt_id NUMBER, p_sequence_number NUMBER ) IS
	   	  	 SELECT id
	   	  	 FROM okl_cnsld_ar_lines_v
	   	  	 WHERE cnr_id 	       = p_cnr_id		 AND
	   	  	 	   khr_id 	  	   = p_khr_id		 AND
			 	   kle_id 	  	   IS NULL 		 	 AND
   		  	 	   ilt_id	  	   = p_ilt_id		 AND
		  	 	   sequence_number = p_sequence_number;

	  CURSOR check_line4 ( p_cnr_id NUMBER, p_ilt_id NUMBER, p_sequence_number NUMBER ) IS
	   		 SELECT id
	   		 FROM okl_cnsld_ar_lines_v
	   		 WHERE cnr_id 	       = p_cnr_id		 AND
   		  	 	   ilt_id	  	   = p_ilt_id		 AND
		  	 	   sequence_number = p_sequence_number;


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
	 -- Prime Local Variable
	 exists_flag := 'Y';
	 x_lln_id := NULL;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CONSOLIDATED LINES CHECK: if a line exists for the following: ***');
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CNR_ID: '||p_cnr_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  KHR_ID: '||p_khr_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  KLE_ID: '||p_kle_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  ILT_ID: '||p_ilt_id);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  SEQUENCE_NUMBER: '||p_sequence_number);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  GROUP_BY_CONTRACT_YN: '||p_group_by_contract_yn);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  GROUP_BY_ASSETS_YN: '||p_group_by_assets_yn);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  GROUP_BY_ASSETS_YN: '||p_group_by_assets_yn);
  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** End Invoice Group Details        ***');
  END IF;


--Consider making this a cursor
IF p_group_by_contract_yn  = 'Y' THEN
   IF p_group_by_assets_yn = 'Y' THEN

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Using SQL in check_line1 ');
  	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> SELECT id FROM okl_cnsld_ar_lines_v');
  	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
  	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>       khr_id 	       = '||p_khr_id||' AND ');
     	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> 	  ilt_id	  	   = '||p_ilt_id||'	AND ');
  	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>	   sequence_number = '||p_sequence_number||';');
   END IF;


      OPEN check_line1 ( p_cnr_id, p_khr_id, p_ilt_id, p_sequence_number );
	  FETCH check_line1 INTO x_lln_id;
	  CLOSE check_line1;

   ELSE
   	   IF p_kle_id IS NOT NULL THEN
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Using SQL in check_line2 ');
       END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> SELECT id FROM okl_cnsld_ar_lines_v');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>       khr_id 	       = '||p_khr_id||' AND ');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>       kle_id 	       = '||p_kle_id||'	AND ');
     	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> 	  ilt_id	  	   = '||p_ilt_id||'	AND ');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>	   sequence_number = '||p_sequence_number||';');
       END IF;

	   	  OPEN check_line2 ( p_cnr_id, p_khr_id, p_kle_id, p_ilt_id );
		  FETCH check_line2 INTO x_lln_id;
		  CLOSE check_line2;

	   ELSE
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Using SQL in check_line3 ');
       END IF;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
         	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> SELECT id FROM okl_cnsld_ar_lines_v');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>       khr_id 	       = '||p_khr_id||' AND ');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>       kle_id 	       is null			AND ');
     	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> 	  ilt_id	  	   = '||p_ilt_id||'	AND ');
  	   	  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>	   sequence_number = '||p_sequence_number||';');
       END IF;

	      OPEN check_line3 ( p_cnr_id, p_khr_id, p_ilt_id, p_sequence_number );
		  FETCH check_line3 INTO x_lln_id;
		  CLOSE check_line3;

       END IF;
   END IF;
ELSE
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Using SQL in check_line4 ');
  	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> SELECT id FROM okl_cnsld_ar_lines_v');
  	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> WHERE cnr_id 	       = '||p_cnr_id||' AND ');
     	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********> 	   ilt_id	  	   = '||p_ilt_id||'	AND ');
  	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'=***********>	   sequence_number = '||p_sequence_number||';');
       END IF;

	   OPEN check_line4 ( p_cnr_id, p_ilt_id, p_sequence_number );
	   FETCH check_line4 INTO  x_lln_id;
	   CLOSE check_line4;

END IF;

IF ( x_lln_id IS NULL ) THEN
   exists_flag := 'N';
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  No Line Exists for this combination.  ');
   END IF;
ELSE
   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Found an existing line for this combination. The id is '||x_lln_id);
   END IF;
END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** END CONSOLIDATED LINES CHECK                                      ***');
 END IF;
EXCEPTION
  	 		  WHEN NO_DATA_FOUND THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              	    	  	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(L1): '||SQLERRM);
            END IF;
	  		  	   Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	              				p_msg_name => G_NO_DATA_FOUND);

  				   exists_flag		:= 'N';
 	 		  WHEN TOO_MANY_ROWS THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              	    	  	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(L2): '||SQLERRM);
            END IF;
	  		  	   Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	              				p_msg_name => G_TOO_MANY_ROWS);

  				   exists_flag		:= NULL;
			  WHEN OTHERS THEN
            IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              	    	  	   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(L3): '||SQLERRM);
            END IF;
	  		  	   Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	              				p_msg_name => G_OTHERS);
				   exists_flag := NULL;

END line_exist;

--This procedure creates a new consolidated invoice line
--based on the parameters passed
PROCEDURE create_new_line(
				p_khr_id 			IN NUMBER,
				p_cnr_id		    IN NUMBER,
				p_kle_id		    IN NUMBER,
				p_ilt_id		    IN NUMBER,
				p_currency_code 	IN VARCHAR2,
				p_sequence_number	IN NUMBER,
				p_line_type			IN VARCHAR2,
				p_group_by_contract_yn IN VARCHAR2,
				p_group_by_assets_yn   IN VARCHAR2,
				p_contract_level_yn    IN VARCHAR2,
				x_lln_id		 OUT NOCOPY NUMBER
			  )

IS

   x_llnv_rec Okl_Lln_Pvt.llnv_rec_type;
   x_llnv_tbl Okl_Lln_Pvt.llnv_tbl_type;

   p_llnv_rec  Okl_Lln_Pvt.llnv_rec_type;
   p_llnv_tbl  Okl_Lln_Pvt.llnv_tbl_type;


   p_api_version                  NUMBER := 1.0;
   p_init_msg_list                VARCHAR2(1) := Okl_Api.g_false;
   x_return_status                VARCHAR2(1);
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

   -- Null out values for khr_id and kle_id so that
   -- it doesn't get set to g_miss_num
   p_llnv_rec.KHR_ID := NULL;
   p_llnv_rec.KLE_ID := NULL;


   IF (p_group_by_contract_yn  = 'Y' OR p_contract_level_yn = 'N') THEN
   	  p_llnv_rec.KHR_ID          := p_khr_id;
   	  IF p_group_by_assets_yn = 'N' THEN
	  	 p_llnv_rec.KLE_ID          := p_kle_id;
      END IF;
   END IF;

   p_llnv_rec.CNR_ID          := p_cnr_id;
   p_llnv_rec.ILT_ID          := p_ilt_id;

   IF ( p_sequence_number IS NULL ) THEN
      p_llnv_rec.SEQUENCE_NUMBER := 1;
   ELSE
      p_llnv_rec.SEQUENCE_NUMBER := p_sequence_number;
   END IF;

   p_llnv_rec.LINE_TYPE	   	  := SUBSTR(p_line_type,1,50);

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** LINE RECORD CREATION FOR : ***');
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  KHR_ID: '||p_llnv_rec.KHR_ID||' KLE_ID: '||p_llnv_rec.KLE_ID);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CNR_ID: '||p_llnv_rec.CNR_ID||' ILT_ID: '||p_llnv_rec.ILT_ID);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  SEQUENCE_NUMBER: '||p_llnv_rec.SEQUENCE_NUMBER||' LINE_TYPE: '||p_llnv_rec.LINE_TYPE);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
   END IF;


-- Start of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Lines_Pub.INSERT_CNSLD_AR_LINES
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call Okl_Cnsld_Ar_Lines_Pub.INSERT_CNSLD_AR_LINES  ');
    END;
  END IF;
   Okl_Cnsld_Ar_Lines_Pub.INSERT_CNSLD_AR_LINES (
     p_api_version
    ,p_init_msg_list
    ,x_return_status
    ,x_msg_count
    ,x_msg_data
    ,p_llnv_rec
    ,x_llnv_rec
   );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call Okl_Cnsld_Ar_Lines_Pub.INSERT_CNSLD_AR_LINES  ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Lines_Pub.INSERT_CNSLD_AR_LINES

   IF ( x_return_status = 'S' ) THEN
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====>  Consolidated Line Created.');
      END IF;
   ELSE
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> FAILED: Consolidated Line NOT Created.');
      END IF;
   END IF;

   x_lln_id := x_llnv_rec.id;

EXCEPTION
     --Seed FND_MESSAGE like 'Could NOT CREATE Line RECORD'
	 WHEN OTHERS THEN
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(L1): '||SQLERRM);
     END IF;
   	      Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	      			   p_msg_name => G_OTHERS);
END create_new_line;


--This procedure creates a new consolidated invoice streams
--based on the parameters passed
PROCEDURE create_new_streams(
				p_lln_id 		IN NUMBER,
				p_sty_id		IN NUMBER,
				p_kle_id		IN NUMBER,
				p_khr_id		IN NUMBER,
				p_amount		IN NUMBER,
                p_sel_id        IN NUMBER,
				x_lsm_id	 OUT NOCOPY NUMBER,
				x_return_status OUT NOCOPY VARCHAR2
			  )

IS

   x_lsmv_rec Okl_Lsm_Pvt.lsmv_rec_type;
   x_lsmv_tbl Okl_Lsm_Pvt.lsmv_tbl_type;

   p_lsmv_rec  Okl_Lsm_Pvt.lsmv_rec_type;
   p_lsmv_tbl  Okl_Lsm_Pvt.lsmv_tbl_type;


   p_api_version                  NUMBER := 1.0;
   p_init_msg_list                VARCHAR2(1) := Okl_Api.g_false;
   x_msg_count                    NUMBER;
   x_msg_data                     VARCHAR2(2000);


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

   p_lsmv_rec.KLE_ID                          := p_kle_id;
   p_lsmv_rec.KHR_ID                          := p_khr_id;
   p_lsmv_rec.STY_ID                          := p_sty_id;
   p_lsmv_rec.LLN_ID                          := p_lln_id;
   p_lsmv_rec.AMOUNT                          := p_amount;
   p_lsmv_rec.SEL_ID                          := p_sel_id;
   p_lsmv_rec.receivables_invoice_id          := -99999;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** STREAM RECORD CREATION FOR : ***');
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  KHR_ID: '||p_lsmv_rec.KHR_ID||' KLE_ID: '||p_lsmv_rec.KLE_ID);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  STY_ID: '||p_lsmv_rec.STY_ID||' LLN_ID: '||p_lsmv_rec.LLN_ID);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  AMOUNT: '||p_lsmv_rec.AMOUNT);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
   END IF;

-- Start of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Strms_Pub.INSERT_CNSLD_AR_STRMS
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call Okl_Cnsld_Ar_Strms_Pub.INSERT_CNSLD_AR_STRMS ');
    END;
  END IF;
   Okl_Cnsld_Ar_Strms_Pub.INSERT_CNSLD_AR_STRMS(
      	    p_api_version
	  	   ,p_init_msg_list
      	   ,x_return_status
       	   ,x_msg_count
      	   ,x_msg_data
      	   ,p_lsmv_rec
      	   ,x_lsmv_rec
   );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRKONB.pls call Okl_Cnsld_Ar_Strms_Pub.INSERT_CNSLD_AR_STRMS ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Strms_Pub.INSERT_CNSLD_AR_STRMS

   IF ( x_return_status = 'S' ) THEN
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'====>  Consolidated Streams Created.');
     END IF;
   ELSE
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	  	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> FAILED: Consolidated Streams NOT Created.');
     END IF;
   END IF;

   x_lsm_id := x_lsmv_rec.id;
EXCEPTION
     --Seed FND_MESSAGE like 'Could NOT CREATE Stream RECORD'
	 WHEN OTHERS THEN
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(D1): '||SQLERRM);
     END IF;
   	      Okl_Api.SET_MESSAGE( p_app_name => G_APP_NAME,
        	      			   p_msg_name => G_OTHERS);
END create_new_streams;


PROCEDURE process_cons_bill_tbl(
           p_contract_number	IN  VARCHAR2,
	       p_api_version        IN NUMBER,
    	   p_init_msg_list      IN VARCHAR2,
           p_commit             IN  VARCHAR2,
    	   x_return_status      OUT NOCOPY VARCHAR2,
    	   x_msg_count          OUT NOCOPY NUMBER,
    	   x_msg_data           OUT NOCOPY VARCHAR2,
           p_cons_bill_tbl      IN OUT NOCOPY cons_bill_tbl_type,
           p_saved_bill_rec     IN OUT NOCOPY saved_bill_rec_type,
           p_update_tbl         IN OUT NOCOPY update_tbl_type)
IS


    l_api_name	                 CONSTANT VARCHAR2(30)  := 'process_cons_bill_tbl';
    l_format_name                okl_invoice_formats_v.name%TYPE;
	l_contract_level_yn			 VARCHAR2(3);
	l_group_asset_yn			 VARCHAR2(3);
	l_group_by_contract_yn		 VARCHAR2(3);
	l_ilt_id					 NUMBER;
	l_cnr_id					 NUMBER;
    l_lln_id					 NUMBER;
	l_lsm_id					 NUMBER;

	l_line_name					 VARCHAR2(150);
	l_ity_id					 NUMBER;
    l_format_type                okl_invoice_types_v.name%TYPE;

	l_sequence_number	         okl_invc_line_types_v.sequence_number%TYPE;
 	l_cons_line_name			 VARCHAR2(150);
	l_stream_name				 VARCHAR2(150);
    i                            NUMBER;
    l_funct_return	 		     VARCHAR2(1);

    l_cons_inv_num               okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE;
    l_cnr_amount                 okl_cnsld_ar_hdrs_v.amount%TYPE;
    l_lln_amount                 okl_cnsld_ar_lines_v.amount%TYPE;
    l_legal_entity_id            okl_ext_sell_invs_v.legal_entity_id%TYPE; -- for LE Uptake project 08-11-2006

    l_update_tbl                 update_tbl_type;

    l_kle_id 		             NUMBER;
    l_top_kle_id                 NUMBER;
    l_chr_id                     okc_k_lines_b.chr_id%TYPE;
    l_asset_name                 okc_k_lines_v.name%TYPE;

    CURSOR check_top_line ( p_cle_id NUMBER ) IS
       SELECT chr_id
       FROM okc_k_lines_b
       WHERE id = p_cle_id;

    CURSOR top_line_asset ( p_cle_id NUMBER ) IS
            SELECT name
            FROM  okc_k_lines_v
            WHERE id = p_cle_id;

    CURSOR derive_top_line_id (p_lsm_id   NUMBER) IS
           SELECT FA.ID
           FROM OKC_K_HEADERS_B CHR,
                OKC_K_LINES_B TOP_CLE,
                OKC_LINE_STYLES_b TOP_LSE,
                OKC_K_LINES_B SUB_CLE,
                OKC_LINE_STYLES_b SUB_LSE,
                OKC_K_ITEMS CIM,
                OKC_K_LINES_V  FA,
                OKC_LINE_STYLES_B AST_LSE,
                OKL_CNSLD_AR_STRMS_B LSM
            WHERE
                CHR.ID           = TOP_CLE.DNZ_CHR_ID              AND
                TOP_CLE.LSE_ID   = TOP_LSE.ID                      AND
                TOP_LSE.LTY_CODE IN('SOLD_SERVICE','FEE')          AND
                TOP_CLE.ID       = SUB_CLE.CLE_ID                  AND
                SUB_CLE.LSE_ID   = SUB_LSE.ID                      AND
                SUB_LSE.LTY_CODE IN ('LINK_SERV_ASSET', 'LINK_FEE_ASSET') AND
                SUB_CLE.ID       =  LSM.KLE_ID                     AND
                LSM.ID           =  p_lsm_id                       AND
                CIM.CLE_ID       = SUB_CLE.ID                      AND
                CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'              AND
                CIM.OBJECT1_ID1  = FA.ID                           AND
                FA.LSE_ID        = AST_LSE.ID                      AND
                AST_LSE.LTY_CODE = 'FREE_FORM1';


    CURSOR inv_format_csr ( p_format_id IN NUMBER, p_stream_id IN NUMBER ) IS
		      SELECT
				inf.name inf_name,
				inf.contract_level_yn,
				ity.id ity_id,
		        ity.name ity_name,
				ity.group_asset_yn,
				ity.group_by_contract_yn,
				ilt.id	ilt_id,
				ilt.sequence_number,
				ilt.name ilt_name,
       			sty.name sty_name
	           FROM   okl_invoice_formats_v   inf,
       			      okl_invoice_types_v     ity,
       			      okl_invc_line_types_v   ilt,
       			      okl_invc_frmt_strms_v   frs,
       			      okl_strm_type_v         sty
		      WHERE   inf.id                  = p_format_id
		      AND     ity.inf_id              = inf.id
		      AND     ilt.ity_id              = ity.id
		      AND     frs.ilt_id              = ilt.id
		      AND     sty.id                  = frs.sty_id
		      AND	  frs.sty_id		      = p_stream_id;

    CURSOR inv_format_default_csr ( p_format_id IN NUMBER ) IS
	 	     SELECT
    		  	inf.name inf_name,
    			inf.contract_level_yn,
    			ity.id ity_id,
            	ity.name ity_name,
    			ity.group_asset_yn,
    			ity.group_by_contract_yn,
    			ilt.id ilt_id,
    			ilt.sequence_number,
    			ilt.name ilt_name
       		 FROM    okl_invoice_formats_v   inf,
      		  		 okl_invoice_types_v     ity,
            		 okl_invc_line_types_v   ilt
    		 WHERE   inf.id                 = p_format_id
    		 AND     ity.inf_id             = inf.id
    		 AND     ilt.ity_id             = ity.id
    		 AND 	inf.ilt_id 				= ilt.id;

    l_cons_invoice_num 	OKL_CNSLD_AR_HDRS_B.CONSOLIDATED_INVOICE_NUMBER%TYPE;
    l_invoice_format	OKL_INVOICE_FORMATS_V.NAME%TYPE;
    l_sty_name          OKL_STRM_TYPE_V.NAME%TYPE;

    l_old_cnr_id        NUMBER;
    l_old_lln_id        NUMBER;
    l_cnt               NUMBER;

    CURSOR cnr_amt_csr ( p_cnr_id IN NUMBER ) IS
            SELECT SUM(lsm.amount)
            FROM okl_cnsld_ar_hdrs_b cnr,
                 okl_cnsld_ar_lines_b lln,
                 okl_cnsld_ar_strms_b lsm
            WHERE cnr.id = p_cnr_id   AND
                  cnr.id = lln.cnr_id AND
                  lln.id = lsm.lln_id;

    CURSOR lln_amt_csr ( p_lln_id IN NUMBER ) IS
            SELECT SUM(lsm.amount)
            FROM okl_cnsld_ar_lines_b lln,
                 okl_cnsld_ar_strms_b lsm
            WHERE lln.id = p_lln_id   AND
                  lln.id = lsm.lln_id;

    CURSOR strm_csr ( p_id NUMBER ) IS
	       SELECT name
	       FROM okl_strm_type_v
	       WHERE id = p_id;

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'Total rec count is : '||p_cons_bill_tbl.count);
   END IF;

    FOR k IN p_cons_bill_tbl.FIRST..p_cons_bill_tbl.LAST LOOP


        l_sty_name := NULL;
        OPEN  strm_csr ( p_cons_bill_tbl(k).sty_id );
        FETCH strm_csr INTO l_sty_name;
        CLOSE strm_csr;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CONSOLIDATION DETAILS      ***');
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** PREVIOUS RECORD WAS FOR:     ***');
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CUSTOMER_ID: '||p_saved_bill_rec.l_customer_id||' CURRENCY: '||p_saved_bill_rec.l_currency);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  BILL_TO_SITE: '||p_saved_bill_rec.l_bill_to_site||' PAYMENT_METHOD: '||p_saved_bill_rec.l_payment_method);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  PRIVATE_LABEL: '||NVL(p_saved_bill_rec.l_private_label,'N/A')||' DATE_CONSOLIDATED: '||TRUNC(p_saved_bill_rec.l_date_consolidated));
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CONTRACT_ID: '||p_saved_bill_rec.l_prev_khr_id||' INVOICE GROUP ID: '||p_saved_bill_rec.l_saved_format_id);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  ORIGINAL CONS INV (For credit memos): '||p_saved_bill_rec.l_saved_prev_cons_num);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  Overall Error Status: '||p_saved_bill_rec.l_overall_status);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
     END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CURRENT RECORD IS FOR:     ***');
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CUSTOMER_ID: '||p_cons_bill_tbl(k).customer_id||' CURRENCY: '||p_cons_bill_tbl(k).currency);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  BILL_TO_SITE: '||p_cons_bill_tbl(k).bill_to_site||' PAYMENT_METHOD: '||p_cons_bill_tbl(k).payment_method);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  PRIVATE_LABEL: '||NVL(p_cons_bill_tbl(k).private_label,'N/A')||' DATE_CONSOLIDATED: '||TRUNC(p_cons_bill_tbl(k).date_consolidated));
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CONTRACT_ID: '||p_cons_bill_tbl(k).contract_id||' INVOICE GROUP ID: '||p_cons_bill_tbl(k).inf_id);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  ORIGINAL CONS INV (For credit memos): '||p_cons_bill_tbl(k).prev_cons_invoice_num);
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
      	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** END CONSOLIDATION DETAILS  ***');
     END IF;


		i:= 0;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Invoice Groups: Checking If Stream assigned to a Line Type.');
     END IF;
	    FOR inv_format IN inv_format_csr (p_cons_bill_tbl(k).inf_id , p_cons_bill_tbl(k).sty_id) LOOP
			i := i+1;
			l_format_name 		   := inv_format.inf_name;
			l_contract_level_yn    := inv_format.contract_level_yn;
			l_ity_id			   := inv_format.ity_id;
			l_format_type		   := inv_format.ity_name;
			l_group_asset_yn	   := inv_format.group_asset_yn;
			l_group_by_contract_yn := inv_format.group_by_contract_yn;
			l_ilt_id			   := inv_format.ilt_id;
			l_sequence_number	   := inv_format.sequence_number;
			l_cons_line_name 	   := inv_format.ilt_name;
       		l_stream_name		   := inv_format.sty_name;
		END LOOP;

		IF i = 0 THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
             		   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Invoice Groups: Stream not assigned to a Line Type.');
     		   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  Invoice Groups: Checking If Default Line Type exists. ');
        END IF;
    	   FOR inv_format_default IN inv_format_default_csr(p_cons_bill_tbl(k).inf_id) LOOP
			  	i := i + 1;

   				l_format_name 		   :=  inv_format_default.inf_name;
				l_contract_level_yn    := inv_format_default.contract_level_yn;
				l_ity_id			   := inv_format_default.ity_id;
				l_format_type		   := inv_format_default.ity_name;
				l_group_asset_yn	   := inv_format_default.group_asset_yn;
				l_group_by_contract_yn := inv_format_default.group_by_contract_yn;
				l_ilt_id			   := inv_format_default.ilt_id;
				l_sequence_number	   := inv_format_default.sequence_number;
				l_cons_line_name 	   := inv_format_default.ilt_name;
           END LOOP;
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** Qualifying Invoice Group Details ***');
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  NAME: '||l_format_name);
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  CONTRACT_LEVEL_YN: '||l_contract_level_yn);
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  INVOICE TYPE NAME: '||l_format_type||' With Id of:  '||l_ity_id);
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  GROUP_ASSET_YN: '||l_group_asset_yn);
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  LINE NAME: '||l_cons_line_name||' With Id of: '||l_ilt_id);
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*    ====>  SEQUENCE NUMBER: '||l_sequence_number);
     		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** End Invoice Group Details        ***');
     END IF;

     	IF ( 	(p_cons_bill_tbl(k).customer_id   = p_saved_bill_rec.l_customer_id)
            AND (p_cons_bill_tbl(k).currency      = p_saved_bill_rec.l_currency)
            AND (p_cons_bill_tbl(k).bill_to_site  = p_saved_bill_rec.l_bill_to_site)
            AND (NVL(p_cons_bill_tbl(k).payment_method,-999)= NVL(p_saved_bill_rec.l_payment_method,-999))
            AND (NVL(p_cons_bill_tbl(k).private_label,'N/A') = NVL(p_saved_bill_rec.l_private_label,'N/A'))
            AND (TRUNC(p_cons_bill_tbl(k).date_consolidated) = TRUNC(p_saved_bill_rec.l_date_consolidated) )
            AND	(p_cons_bill_tbl(k).inf_id = p_saved_bill_rec.l_saved_format_id)
            AND (p_cons_bill_tbl(k).prev_cons_invoice_num = p_saved_bill_rec.l_saved_prev_cons_num)
	       )
        THEN
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            		        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====>  No Break Detected, Check Contract Level YN: '||l_contract_level_yn);
          END IF;
	        	-- -------------------------------------------------------------------
	        	-- Check multi-contract invoices
	        	-- -------------------------------------------------------------------
	        	IF ( p_saved_bill_rec.l_prev_khr_id <> p_cons_bill_tbl(k).contract_id ) THEN

                    IF (l_contract_level_yn = 'Y') THEN
                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====> Reusing CNR_ID, as Contract Level YN is Y : '||p_saved_bill_rec.l_cnr_id);
                        END IF;
                    ELSE
                        -- ---------------------------
                        -- Process Header Break Logic
                        -- ---------------------------
                        process_break(p_contract_number,
	                                  p_commit,
                                      p_saved_bill_rec,
                                      p_update_tbl);

                        -- Reset update table after processing
                        p_update_tbl     := l_update_tbl;

                        -- ------------------------------------
                        -- Finish post header break detection logic
                        -- ------------------------------------

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====> Create new Invoice as Contract Level YN is N.');
                        END IF;
                        l_cnr_id := NULL;

                        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE HEADER ***');
                        END IF;
                        l_cons_inv_num := NULL;
			-- for LE Uptake project 08-11-2006
                        IF (p_cons_bill_tbl(k).legal_entity_id IS NULL OR (p_cons_bill_tbl(k).legal_entity_id = Okl_Api.G_MISS_NUM)) THEN
			  l_legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_cons_bill_tbl(k).contract_id);
		        ELSE
                        l_legal_entity_id :=  p_cons_bill_tbl(k).legal_entity_id;
                        END IF;
			-- for LE Uptake project 08-11-2006
			create_new_invoice(
					    p_cons_bill_tbl(k).bill_to_site,
		  			    p_cons_bill_tbl(k).customer_id,
		  			    p_cons_bill_tbl(k).currency,
		  			    p_cons_bill_tbl(k).payment_method,
		  			    p_cons_bill_tbl(k).inf_id,
		  			    p_cons_bill_tbl(k).set_of_books_id,
		  			    p_cons_bill_tbl(k).private_label,
					    p_cons_bill_tbl(k).date_consolidated,
					    p_cons_bill_tbl(k).org_id,
                                            l_legal_entity_id, -- for LE Uptake project 08-11-2006
					    l_cnr_id,
                                            l_cons_inv_num);

                       p_saved_bill_rec.l_cnr_id        := l_cnr_id;
                       p_saved_bill_rec.l_cons_inv_num  := l_cons_inv_num;

                    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      	                   OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '
					   ||l_cnr_id||' ***'||'p_saved_bill_rec.l_cons_inv_num: '||p_saved_bill_rec.l_cons_inv_num );
                    END IF;
                    END IF;
	        	ELSE
                    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                  	       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====> Reusing CNR_ID (Same Contract) : '||l_cnr_id);
                    END IF;
	        	END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	        	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
  	        	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CHECK IF A CONSOLIDATED LINE EXISTS ***');
          END IF;
	        	l_lln_id := NULL;
	        	line_exist (l_cnr_id,
		  	 	    p_cons_bill_tbl(k).contract_id,
					p_cons_bill_tbl(k).kle_id,
					l_ilt_id,
					l_sequence_number,
					l_group_by_contract_yn,
					l_group_asset_yn,
					l_lln_id,
					l_funct_return
					);

                p_saved_bill_rec.l_lln_id := l_lln_id;

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	        	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** END CHECK FOR CONSOLIDATED LINE ***');
  	        	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** ++++++++++++++++++++++++++++ ***');
          END IF;

	        	IF l_funct_return = 'N' THEN
                    -- -----------------------------------------------------
                    -- Line break detected, update LLN record with amount
                    -- -----------------------------------------------------

              IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                	        	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID: '||l_cnr_id);
              END IF;
	        	    l_lln_id := NULL;
                    l_cnr_id := p_saved_bill_rec.l_cnr_id;

	        	    create_new_line(
					  	 p_cons_bill_tbl(k).contract_id,
					  	 l_cnr_id,
					  	 p_cons_bill_tbl(k).kle_id,
					  	 l_ilt_id,
					  	 p_cons_bill_tbl(k).currency,
					  	 l_sequence_number,
					  	 'CHARGE',
						 l_group_by_contract_yn,
						 l_group_asset_yn,
						 l_contract_level_yn,
						 l_lln_id
		 			  	 );
                p_saved_bill_rec.l_lln_id := l_lln_id;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	        	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
          END IF;
	        	END IF;
	ELSE -- 'ELSE' for the Uppermost level 'IF' for hierarchy checks


        -- ------------------------------------
        -- Start header break detection logic
        -- ------------------------------------
                        process_break(p_contract_number,
	                                  p_commit,
                                      p_saved_bill_rec,
                                      p_update_tbl);

        -- Reset update table after processing
        p_update_tbl     := l_update_tbl;

         -- ------------------------------------
         -- Finish post header break detection logic
         -- ------------------------------------


        -- -----------------------------------
		-- Break detected
        -- -----------------------------------

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
    		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '====> Break Detected.');
     	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE HEADER ***');
  END IF;
		-- Null out current value in local variable.
		l_cnr_id        := NULL;
        l_cons_inv_num  := NULL;
   -- for LE Uptake project 08-11-2006
   IF (p_cons_bill_tbl(k).legal_entity_id IS NULL OR (p_cons_bill_tbl(k).legal_entity_id = Okl_Api.G_MISS_NUM)) THEN
	l_legal_entity_id := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_cons_bill_tbl(k).contract_id);
   ELSE
   l_legal_entity_id :=  p_cons_bill_tbl(k).legal_entity_id;
   END IF;
   -- for LE Uptake project 08-11-2006
	create_new_invoice(
			 p_cons_bill_tbl(k).bill_to_site,
			 p_cons_bill_tbl(k).customer_id,
			 p_cons_bill_tbl(k).currency,
	 		 p_cons_bill_tbl(k).payment_method,
		  	 p_cons_bill_tbl(k).inf_id,
		  	 p_cons_bill_tbl(k).set_of_books_id,
		  	 p_cons_bill_tbl(k).private_label,
			 p_cons_bill_tbl(k).date_consolidated,
			 p_cons_bill_tbl(k).org_id,
			 l_legal_entity_id,       -- for LE Uptake project 08-11-2006
			 l_cnr_id,
                         l_cons_inv_num);

        p_saved_bill_rec.l_cnr_id        := l_cnr_id;
        p_saved_bill_rec.l_cons_inv_num  := l_cons_inv_num;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '||l_cnr_id||' ***'||'p_saved_bill_rec.l_cons_inv_num: '||p_saved_bill_rec.l_cons_inv_num );
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
             	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID '||l_cnr_id);
        END IF;
		-- Null out current value in local variable.
		l_lln_id := NULL;

        l_cnr_id := p_saved_bill_rec.l_cnr_id;
  	 	create_new_line(
		  	 p_cons_bill_tbl(k).contract_id,
		  	 l_cnr_id,
		  	 p_cons_bill_tbl(k).kle_id,
		  	 l_ilt_id,
		  	 p_cons_bill_tbl(k).currency,
		  	 l_sequence_number,
		  	 'CHARGE',
			 l_group_by_contract_yn,
			 l_group_asset_yn,
			 l_contract_level_yn,
			 l_lln_id);

        p_saved_bill_rec.l_lln_id := l_lln_id;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
        END IF;
	END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
     	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE STREAMS *** for CNR_ID: '||l_cnr_id||' and LLN_ID: '||l_lln_id);
  END IF;
	--Null out local variable.
	l_lsm_id := null;

    l_lln_id := p_saved_bill_rec.l_lln_id;

	create_new_streams(
	  		l_lln_id,
	  		p_cons_bill_tbl(k).sty_id,
	  		p_cons_bill_tbl(k).kle_id,
			p_cons_bill_tbl(k).contract_id,
			p_cons_bill_tbl(k).amount,
            p_cons_bill_tbl(k).sel_id,
			l_lsm_id,
			x_return_status);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE STREAMS.Assigned Id: '||l_lsm_id||' ***');
    END IF;



	--Set local variables to cursor values for
	--comparison purposes
	p_saved_bill_rec.l_customer_id   		 := p_cons_bill_tbl(k).customer_id;
  	p_saved_bill_rec.l_currency	   	 	     := p_cons_bill_tbl(k).currency;
	p_saved_bill_rec.l_bill_to_site		 	 := p_cons_bill_tbl(k).bill_to_site;
	p_saved_bill_rec.l_payment_method		 := p_cons_bill_tbl(k).payment_method;
	p_saved_bill_rec.l_private_label		 := p_cons_bill_tbl(k).private_label;
	p_saved_bill_rec.l_date_consolidated	 := p_cons_bill_tbl(k).date_consolidated;
	p_saved_bill_rec.l_saved_format_id       := p_cons_bill_tbl(k).inf_id;
	p_saved_bill_rec.l_prev_khr_id           := p_cons_bill_tbl(k).contract_id;
	p_saved_bill_rec.l_saved_prev_cons_num   := p_cons_bill_tbl(k).prev_cons_invoice_num;
    p_saved_bill_rec.l_commit_cnt            := NVL(p_saved_bill_rec.l_commit_cnt,0) + 1;

    -- -----------------------
    -- Work out asset name
    -- -----------------------
    l_chr_id := NULL;

    OPEN  check_top_line( p_cons_bill_tbl(k).kle_id );
    FETCH check_top_line INTO l_chr_id;
    CLOSE check_top_line;

    IF l_chr_id IS NOT NULL THEN
        l_kle_id := p_cons_bill_tbl(k).kle_id;
    ELSE
        l_top_kle_id := NULL;
        OPEN  derive_top_line_id ( l_lsm_id );
        FETCH derive_top_line_id INTO l_top_kle_id;
        CLOSE derive_top_line_id;
        l_kle_id := l_top_kle_id;
    END IF;

    l_asset_name := NULL;
    OPEN  top_line_asset ( l_kle_id );
    FETCH top_line_asset INTO l_asset_name;
    CLOSE top_line_asset;

    -- --------------------------
    -- Index counter
    -- --------------------------
    l_cnt := p_update_tbl.count;
    l_cnt := l_cnt + 1;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'DEL Updates (p_saved_bill_rec.l_cons_inv_num)'||p_saved_bill_rec.l_cons_inv_num);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, 'DEL Updates (l_format_name)'||l_format_name);
    END IF;

    p_update_tbl(l_cnt).cnr_id			    := p_saved_bill_rec.l_cnr_id;
    p_update_tbl(l_cnt).cons_inv_number     := p_saved_bill_rec.l_cons_inv_num;
    p_update_tbl(l_cnt).lln_id			    := p_saved_bill_rec.l_lln_id;
    p_update_tbl(l_cnt).lsm_id			    := l_lsm_id;
    p_update_tbl(l_cnt).asset_number        := l_asset_name;
    p_update_tbl(l_cnt).invoice_format      := l_format_name;
    p_update_tbl(l_cnt).line_type           := l_cons_line_name;
    p_update_tbl(l_cnt).sty_name            := l_sty_name;
    p_update_tbl(l_cnt).contract_number     := p_cons_bill_tbl(k).contract_number;

    -- Start; Bug 4525643; STMATHEW
    p_update_tbl(l_cnt).private_label     := p_cons_bill_tbl(k).private_label;
    -- End; Bug 4525643; STMATHEW

    p_update_tbl(l_cnt).lsm_amount          := p_cons_bill_tbl(k).amount;
    p_update_tbl(l_cnt).xsi_id			    := p_cons_bill_tbl(k).xsi_id;
    p_update_tbl(l_cnt).xls_id			    := p_cons_bill_tbl(k).xls_id;

    END LOOP;


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN OTHERS THEN
        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'OTHERS');
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(O3): '||SQLERRM);
     END IF;
        x_return_status := 'E';

END process_cons_bill_tbl;

PROCEDURE create_cons_bill(
	       p_api_version                  IN  NUMBER,
    	   p_init_msg_list                IN  VARCHAR2,
           p_commit                       IN  VARCHAR2,
    	   x_return_status                OUT NOCOPY VARCHAR2,
    	   x_msg_count                    OUT NOCOPY NUMBER,
    	   x_msg_data                     OUT NOCOPY VARCHAR2,
           p_contract_number	          IN VARCHAR2 DEFAULT NULL,
           p_inv_msg                      IN VARCHAR2,
           p_assigned_process             IN VARCHAR2
        )

IS

--Removed Cursor C , C1 def'n
--Fixed Bug #5484903
---------------------------------------------------------------------------
-- Cursor for consolidated invoices having only headers and lines for a txn
-- Only for UBB billing
---------------------------------------------------------------------------
CURSOR ubb_csr IS SELECT
	   	 		xsi.customer_id			   	 customer_id,
				xsi.currency_code   		 currency,
				xsi.customer_address_id		 bill_to_site,
				xsi.receipt_method_id		 payment_method,
				xsi.xtrx_private_label		 private_label,
				TRUNC(xsi.TRX_DATE)			 date_consolidated,
				tai.khr_id					 contract_id, -- get contract Id
				xsi.org_id					 org_id,
				tai.clg_id					 clg_id,
				xsi.set_of_books_id			 set_of_books_id,
				til.kle_id					 kle_id,
				tld.sty_id					 stream_id, -- to get the line seq #
				til.line_number				 ubb_line_number,
				xsi.id						 xsi_id,
				xls.id						 xls_id,
				xls.amount					 ubb_amount,
                xls.sel_id                   sel_id
                --vthiruva added for bug#4438971 fix..24-JUN-2005
                ,xsi.inf_id                   inf_id
		,xsi.legal_entity_id          legal_entity_id -- for LE Uptake project 08-11-2006
	     	FROM
				okl_ext_sell_invs_v	   xsi,
				okl_xtl_sell_invs_v	   xls,
				okl_txd_ar_ln_dtls_v   tld,
				okl_txl_ar_inv_lns_v   til,
				okl_trx_ar_invoices_v  tai,
                okc_k_headers_b	       chr,
                okl_parallel_processes pws
			WHERE
				xsi.TRX_STATUS_CODE    = 'SUBMITTED' AND
				xls.xsi_id_details 	   = xsi.id		AND
				tld.id				   = xls.tld_id AND
				til.id				   = tld.TIL_ID_DETAILS AND
				tai.id				   = til.tai_id 		AND
                tai.khr_id             = chr.id
                AND
                -- Contract Specific consolidation
                chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
                -- Contract Specific consolidation
				tai.clg_id			   IS NOT NULL			AND
				xls.amount > 0                                AND
                PWS.OBJECT_TYPE = 'CUSTOMER'             AND
                XSI.CUSTOMER_ID = TO_NUMBER(pws.object_value) AND
                PWS.ASSIGNED_PROCESS = P_ASSIGNED_PROCESS
			ORDER BY 1,2,3,4,5,6,7,8;


---------------------------------------------------------------------------
-- Cursor for consolidated invoices having only headers and lines for a txn
-- Only for Termination Quote billing
---------------------------------------------------------------------------
CURSOR qte_csr IS SELECT
                -- Start Bug 4731187 (changed Order by)
				tai.qte_id					 qte_id,
				TRUNC(xsi.TRX_DATE)			 date_consolidated,
				xls.amount					 qte_amount,
	   	 		xsi.customer_id			   	 customer_id,
				xsi.currency_code   		 currency,
				xsi.customer_address_id		 bill_to_site,
				xsi.receipt_method_id		 payment_method,
				xsi.xtrx_private_label		 private_label,
				tai.khr_id					 contract_id,
				xsi.org_id					 org_id,
				xsi.set_of_books_id			 set_of_books_id,
				til.kle_id					 kle_id,
				til.sty_id					 stream_id,
				til.line_number				 qte_line_number,
                til.description              description,
				xsi.id						 xsi_id,
				xls.id						 xls_id,
                xls.sel_id                   sel_id
                --vthiruva added for bug#4438971 fix..24-JUN-2005
               ,xsi.inf_id                   inf_id
	       ,xsi.legal_entity_id          legal_entity_id -- for LE Uptake project 08-11-2006
	     	 FROM
				okl_ext_sell_invs_v	   xsi,
				okl_xtl_sell_invs_v	   xls,
				okl_txl_ar_inv_lns_v   til,
				okl_trx_ar_invoices_v  tai,
                okc_k_headers_b	       chr,
                okl_parallel_processes pws
			 WHERE
				xsi.TRX_STATUS_CODE    = 'SUBMITTED' AND
				xls.xsi_id_details 	   = xsi.id		AND
				til.id				   = xls.til_id AND
				tai.id				   = til.tai_id AND
                tai.khr_id             = chr.id
                AND
                -- Contract Specific consolidation
                chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
                -- Contract Specific consolidation
				tai.qte_id			   IS NOT NULL			  AND
                PWS.OBJECT_TYPE = 'CUSTOMER'             AND
                XSI.CUSTOMER_ID = TO_NUMBER(pws.object_value) AND
                PWS.ASSIGNED_PROCESS = P_ASSIGNED_PROCESS
			 ORDER BY 1,2,3,4,5,6,7,8,9;
                -- End Bug 4731187 (changed Order by)

---------------------------------------------------------------------------
-- Cursor for consolidated invoices having only headers and lines for a txn
-- Only for Collecetions Billing
---------------------------------------------------------------------------
CURSOR cpy_csr IS SELECT
	   	 		xsi.customer_id			   	 customer_id,
				xsi.currency_code   		 currency,
				xsi.customer_address_id		 bill_to_site,
				xsi.receipt_method_id		 payment_method,
				xsi.xtrx_private_label		 private_label,
				tai.khr_id					 contract_id,
				TRUNC(xsi.TRX_DATE)			 date_consolidated,
				tai.cpy_id					 cpy_id,
				xsi.org_id					 org_id,
				xsi.set_of_books_id			 set_of_books_id,
				til.kle_id					 kle_id,
				til.sty_id					 stream_id,
				til.line_number				 cpy_line_number,
				xsi.id						 xsi_id,
				xls.id						 xls_id,
				xls.amount					 cpy_amount,
                xls.sel_id                   sel_id
                --vthiruva added for bug#4438971 fix..24-JUN-2005
                ,xsi.inf_id                   inf_id
		,xsi.legal_entity_id          legal_entity_id -- for LE Uptake project 08-11-2006
	     	 FROM
				okl_ext_sell_invs_v	   xsi,
				okl_xtl_sell_invs_v	   xls,
				okl_txl_ar_inv_lns_v   til,
				okl_trx_ar_invoices_v  tai,
                okc_k_headers_b	       chr,
                okl_parallel_processes pws
			 WHERE
				xsi.TRX_STATUS_CODE    = 'SUBMITTED' AND
				xls.xsi_id_details 	   = xsi.id		AND
				til.id				   = xls.til_id AND
				tai.id				   = til.tai_id AND
                tai.khr_id             = chr.id
                AND
                -- Contract Specific consolidation
                chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
                -- Contract Specific consolidation
				tai.cpy_id			   IS NOT NULL	AND
				xls.amount > 0                      AND
                PWS.OBJECT_TYPE = 'CUSTOMER'             AND
                XSI.CUSTOMER_ID = TO_NUMBER(pws.object_value) AND
                PWS.ASSIGNED_PROCESS = P_ASSIGNED_PROCESS
			 ORDER BY 1,2,3,4,5,6,7,8;
--start changed by abhsaxen for Bug#6174484
CURSOR cm_two_lvl_csr IS
SELECT xsi.customer_id customer_id,
  xsi.currency_code currency,
  xsi.customer_address_id bill_to_site,
  xsi.receipt_method_id payment_method,
  xsi.xtrx_private_label private_label,
  TRUNC(xsi.trx_date) date_consolidated,
  tai.khr_id contract_id,
  CHR.contract_number contract_number,
  xsi.inf_id inf_id,
  '-9958' prev_cons_invoice_num,
  xsi.org_id org_id,
  xsi.set_of_books_id set_of_books_id,
  til.kle_id kle_id,
  til.sty_id stream_id,
  xsi.id xsi_id,
  xls.id xls_id,
  xls.amount cm2_amount,
  xls.sel_id sel_id,
  xsi.legal_entity_id legal_entity_id --FOR le uptake project 8 -11 -2006
FROM okl_ext_sell_invs_v xsi,
  okl_xtl_sell_invs_b xls,
  okl_txl_ar_inv_lns_b til,
  okl_trx_ar_invoices_b tai,
  okc_k_headers_all_b CHR,
  okl_parallel_processes pws
WHERE xsi.trx_status_code = 'SUBMITTED'
 AND xls.xsi_id_details = xsi.id
 AND til.id = xls.til_id
 AND tai.id = til.tai_id
 AND tai.khr_id = CHR.id
 AND --contract specific consolidation
CHR.contract_number = nvl(p_contract_number,   CHR.contract_number)
 AND --contract specific consolidation
tai.qte_id IS NULL
 AND xls.amount < 0
 AND til.til_id_reverses IS NULL
 AND pws.object_type = 'CUSTOMER'
 AND xsi.customer_id = to_number(pws.object_value)
 AND pws.assigned_process = p_assigned_process
UNION
SELECT xsi.customer_id customer_id,
  xsi.currency_code currency,
  xsi.customer_address_id bill_to_site,
  xsi.receipt_method_id payment_method,
  xsi.xtrx_private_label private_label,
  TRUNC(xsi.trx_date) date_consolidated,
  tai.khr_id contract_id,
  CHR.contract_number contract_number,
  xsi.inf_id inf_id,
  xsir.xtrx_cons_invoice_number prev_cons_invoice_num,
  xsi.org_id org_id,
  xsi.set_of_books_id set_of_books_id,
  til.kle_id kle_id,
  til.sty_id stream_id,
  xsi.id xsi_id,
  xls.id xls_id,
  xls.amount cm2_amount,
  xls.sel_id sel_id,
  xsi.legal_entity_id legal_entity_id --FOR le uptake project 8 -11 -2006
FROM okl_ext_sell_invs_v xsi,
  okl_ext_sell_invs_v xsir,
  okl_xtl_sell_invs_b xls,
  okl_xtl_sell_invs_b xlsr,
  okl_txl_ar_inv_lns_b til,
  okl_trx_ar_invoices_b tai,
  okc_k_headers_all_b CHR,
  okl_parallel_processes pws
WHERE xsi.trx_status_code = 'SUBMITTED'
 AND xls.xsi_id_details = xsi.id
 AND til.id = xls.til_id
 AND tai.id = til.tai_id
 AND tai.khr_id = CHR.id
 AND --contract specific consolidation
CHR.contract_number = nvl(p_contract_number,   CHR.contract_number)
 AND --contract specific consolidation
tai.qte_id IS NULL
 AND xls.amount <= 0
 AND til.til_id_reverses = xlsr.til_id
 AND xlsr.xsi_id_details = xsir.id
 AND pws.object_type = 'CUSTOMER'
 AND xsi.customer_id = to_number(pws.object_value)
 AND pws.assigned_process = p_assigned_process
ORDER BY 1,  2,  3,  4,  5,  6,  7,  8,  9,  10;
--end changed by abhsaxen for Bug#6174484
CURSOR cm_three_lvl_csr IS
                        SELECT
                                xsi.customer_id                          customer_id,
                                xsi.currency_code                currency,
                                xsi.customer_address_id          bill_to_site,
                                xsi.receipt_method_id            payment_method,
                                xsi.xtrx_private_label           private_label,
                                TRUNC(xsi.TRX_DATE)                      date_consolidated,
                                tai.khr_id                                       contract_id, -- get contract Id
                chr.contract_number          contract_number,
                xsi.inf_id                   inf_id,
                '-9958'                      prev_cons_invoice_num,
                                xsi.org_id                                       org_id,
                                xsi.set_of_books_id                      set_of_books_id,
                                til.kle_id                                       kle_id,
                                tld.sty_id                                       stream_id, -- to get the line seq #
                                xsi.id                                           xsi_id,
                                xls.id                                           xls_id,
                                xls.amount                                       cm3_amount,
                xls.sel_id                   sel_id
                ,xsi.legal_entity_id          legal_entity_id -- for LE Uptake project 08-11-2006
                FROM
                                okl_ext_sell_invs_v        xsi,
                                okl_xtl_sell_invs_v        xls,
                                okl_txd_ar_ln_dtls_v   tld,
                                okl_txl_ar_inv_lns_v   til,
                                okl_trx_ar_invoices_v  tai,
                okc_k_headers_b        chr,
                okl_parallel_processes pws
                        WHERE
                                xsi.TRX_STATUS_CODE    = 'SUBMITTED' AND
                                xls.xsi_id_details         = xsi.id              AND
                                tld.id                             = xls.tld_id  AND
                                til.id                             = tld.TIL_ID_DETAILS AND
                                tai.id                             = til.tai_id  AND
                tai.khr_id             = chr.id
                AND
                -- Contract Specific consolidation
                chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
                -- Contract Specific consolidation
                                xls.amount < 0                                           AND
                tld.tld_id_reverses    IS NULL                AND
                PWS.OBJECT_TYPE = 'CUSTOMER'             AND
                XSI.CUSTOMER_ID = TO_NUMBER(pws.object_value) AND
                PWS.ASSIGNED_PROCESS = P_ASSIGNED_PROCESS
            UNION
                        SELECT
                                xsi.customer_id                          customer_id,
                                xsi.currency_code                currency,
                                xsi.customer_address_id          bill_to_site,
                                xsi.receipt_method_id            payment_method,
                                xsi.xtrx_private_label           private_label,
                                TRUNC(xsi.TRX_DATE)                      date_consolidated,
                                tai.khr_id                                       contract_id, -- get contract Id
                chr.contract_number          contract_number,
                xsi.inf_id                   inf_id,
                xsir.xtrx_cons_invoice_number prev_cons_invoice_num,
                                xsi.org_id                                       org_id,
                                xsi.set_of_books_id                      set_of_books_id,
                                til.kle_id                                       kle_id,
                                tld.sty_id                                       stream_id, -- to get the line seq #
                                xsi.id                                           xsi_id,
                                xls.id                                           xls_id,
                                xls.amount                                       cm3_amount,
                xls.sel_id                   sel_id
                ,xsi.legal_entity_id          legal_entity_id -- for LE Uptake project 08-11-2006
                FROM
                                okl_ext_sell_invs_v        xsi,
                                okl_ext_sell_invs_v        xsir,
                                okl_xtl_sell_invs_v        xls,
                                okl_xtl_sell_invs_v        xlsr,
                                okl_txd_ar_ln_dtls_v   tld,
                                okl_txl_ar_inv_lns_v   til,
                                okl_trx_ar_invoices_v  tai,
                okc_k_headers_b        chr,
                okl_parallel_processes pws
                        WHERE
                                xsi.TRX_STATUS_CODE    = 'SUBMITTED' AND
                                xls.xsi_id_details         = xsi.id              AND
                                tld.id                             = xls.tld_id  AND
                                til.id                             = tld.TIL_ID_DETAILS AND
                                tai.id                             = til.tai_id  AND
                tai.khr_id             = chr.id
                AND
                -- Contract Specific consolidation
                chr.contract_number    = NVL(p_contract_number,chr.contract_number) AND
                -- Contract Specific consolidation
                                xls.amount <= 0                                          AND
                tld.tld_id_reverses    IS NOT NULL                      AND
                xlsr.tld_id = tld.tld_id_reverses                       AND
                xsir.id     = xlsr.xsi_id_details             AND
                PWS.OBJECT_TYPE = 'CUSTOMER'             AND
               XSI.CUSTOMER_ID = TO_NUMBER(pws.object_value) AND
                PWS.ASSIGNED_PROCESS = P_ASSIGNED_PROCESS
                        ORDER BY 1,2,3,4,5,6,7,8,9,10;

-- Billing performance fix
cons_bill_tbl        cons_bill_tbl_type;
saved_bill_rec       saved_bill_rec_type;
l_init_bill_rec      saved_bill_rec_type;

l_update_tbl         update_tbl_type;

L_FETCH_SIZE         NUMBER := 1000;

l_cons_inv_num               okl_cnsld_ar_hdrs_v.consolidated_invoice_number%TYPE;
-- Billing performance fix

CURSOR line_seq_csr(p_cnr_id NUMBER) IS
	SELECT *
	FROM okl_cnsld_ar_lines_v
	WHERE cnr_id = p_cnr_id
	ORDER BY sequence_number;

CURSOR format_id_csr (p_format_name VARCHAR2) IS
	SELECT id
	FROM okl_invoice_formats_v
	WHERE name = p_format_name;

CURSOR asset_line_csr (p_lsm_id   NUMBER) IS
        SELECT ASSET_NUMBER
        FROM
              OKL_CNSLD_AR_STRMS_B LSM
             ,OKX_ASSET_LINES_V  KLE

        WHERE   LSM.ID   = p_lsm_id
        AND     KLE.PARENT_LINE_ID   = LSM.KLE_ID;

CURSOR service_asset_csr (p_lsm_id   NUMBER) IS
       SELECT FA.NAME
       FROM OKC_K_HEADERS_B CHR,
            OKC_K_LINES_B TOP_CLE,
            OKC_LINE_STYLES_b TOP_LSE,
            OKC_K_LINES_B SUB_CLE,
            OKC_LINE_STYLES_b SUB_LSE,
            OKC_K_ITEMS CIM,
            OKC_K_LINES_V  FA,
            OKC_LINE_STYLES_B AST_LSE,
            OKL_CNSLD_AR_STRMS_B LSM
       WHERE
            CHR.ID           = TOP_CLE.DNZ_CHR_ID              AND
            TOP_CLE.LSE_ID   = TOP_LSE.ID                      AND
            TOP_LSE.LTY_CODE IN('SOLD_SERVICE','FEE')          AND
            TOP_CLE.ID       = SUB_CLE.CLE_ID                  AND
            SUB_CLE.LSE_ID   = SUB_LSE.ID                      AND
            SUB_LSE.LTY_CODE IN ('LINK_SERV_ASSET', 'LINK_FEE_ASSET') AND
            SUB_CLE.ID       =  LSM.KLE_ID                     AND
            LSM.ID           =  p_lsm_id                       AND
            CIM.CLE_ID       = SUB_CLE.ID                      AND
            CIM.JTOT_OBJECT1_CODE = 'OKX_COVASST'              AND
            CIM.OBJECT1_ID1  = FA.ID                           AND
            FA.LSE_ID        = AST_LSE.ID                      AND
            AST_LSE.LTY_CODE = 'FREE_FORM1';

	l_cnr_id					 NUMBER;
	l_lln_id					 NUMBER;
	l_lsm_id					 NUMBER;
	l_seq_num					 NUMBER;


	l_line_amount				NUMBER;
	l_consbill_amount			NUMBER;

    TYPE cnr_update_rec_type IS RECORD (
	 cnr_id			NUMBER,
	 lln_id			NUMBER,
	 lsm_id			NUMBER,
	 xsi_id			NUMBER,
	 xls_id			NUMBER,
	 return_status  VARCHAR2(1)
	);

    TYPE cnr_update_tbl_type IS TABLE OF cnr_update_rec_type
	     INDEX BY BINARY_INTEGER;

	cnr_update_tbl 				 cnr_update_tbl_type;
	cnr_tab_idx	  		NUMBER;

    -- In and Out records for the external sell invoice tables
	l_xsiv_rec     Okl_Xsi_Pvt.xsiv_rec_type;
	x_xsiv_rec     Okl_Xsi_Pvt.xsiv_rec_type;
 	null_xsiv_rec  Okl_Xsi_Pvt.xsiv_rec_type;

	l_xlsv_rec     Okl_Xls_Pvt.xlsv_rec_type;
	x_xlsv_rec     Okl_Xls_Pvt.xlsv_rec_type;
	null_xlsv_rec  Okl_Xls_Pvt.xlsv_rec_type;

	-- For Updating header and line amnounts and sequences
	u_cnrv_rec 	   Okl_Cnr_Pvt.cnrv_rec_type;
	x_cnrv_rec 	   Okl_Cnr_Pvt.cnrv_rec_type;
	null_cnrv_rec  Okl_Cnr_Pvt.cnrv_rec_type;

	u_llnv_rec 	   Okl_Lln_Pvt.llnv_rec_type;
	x_llnv_rec 	   Okl_Lln_Pvt.llnv_rec_type;
	null_llnv_rec  Okl_Lln_Pvt.llnv_rec_type;

    --All the below variables for a successful rules invocation
    l_rul_format_name	OKC_RULES_B.RULE_INFORMATION1%TYPE;
	l_init_msg_list 	VARCHAR2(1) ;
	l_msg_count 		NUMBER ;
	l_msg_data 			VARCHAR2(2000);
	l_rulv_rec			Okl_Rule_Apis_Pvt.rulv_rec_type;
	null_rulv_rec		Okl_Rule_Apis_Pvt.rulv_rec_type;

	------------------------------------------------------------
	-- Declare variables required by UBB Billing Consolidation
	------------------------------------------------------------
	l_clg_id			NUMBER;

	------------------------------------------------------------
	-- Declare variables required by Termination Quote Billing
	------------------------------------------------------------
	l_qte_id   			NUMBER := -1;

	l_qte_cust_id 		okl_ext_sell_invs_v.Customer_id%TYPE;
	------------------------------------------------------------
	-- Declare variables required by Collections Billing
	------------------------------------------------------------
	l_cpy_id   			NUMBER := -1;

	------------------------------------------------------------
	-- Declare variables required by APIs
	------------------------------------------------------------

	l_api_version	CONSTANT NUMBER := 1;
	l_api_name	CONSTANT VARCHAR2(30)  := 'CONSOLIDATED BILLING';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

CURSOR cntrct_csr ( p_id NUMBER ) IS
	   SELECT contract_number
	   FROM okc_k_headers_b
	   WHERE id = p_id;

CURSOR strm_csr ( p_id NUMBER ) IS
	   SELECT name
	   FROM okl_strm_type_v
	   WHERE id = p_id;

	   l_contract_number   	  okc_k_headers_b.contract_number%TYPE;
	   l_stream_name1		  okl_strm_type_v.name%TYPE;

	   l_temp_khr_id		  NUMBER;

CURSOR get_khr_id ( p_lsm_id NUMBER ) IS
	   SELECT khr_id
	   FROM okl_cnsld_ar_strms_b
	   WHERE id = p_lsm_id;


-- Variable to track commit record size
l_commit_cnt        NUMBER;

-- --------------------------------------------
-- Get distinct currencies processed in a run
-- --------------------------------------------
CURSOR curr_csr( p_request_id NUMBER ) IS
       SELECT DISTINCT CURRENCY_CODE
       FROM okl_cnsld_ar_hdrs_v
       WHERE request_id = p_request_id;

CURSOR cnr_cnt_csr( p_request_id NUMBER, p_trx_sts VARCHAR2, p_curr_code VARCHAR2 ) IS
       SELECT count(*)
       FROM okl_cnsld_ar_hdrs_v
       WHERE request_id = p_request_id
       AND TRX_STATUS_CODE = p_trx_sts
       AND CURRENCY_CODE = p_curr_code;

-- --------------------------------------------------------
-- To Print log messages
-- --------------------------------------------------------
l_request_id      NUMBER;

CURSOR req_id_csr IS
  SELECT
        DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
  FROM dual;

------------------------------------------------------------
-- Operating Unit
------------------------------------------------------------
--Fixed Bug 5484903.
CURSOR op_unit_csr IS
       SELECT name
       FROM hr_operating_units
       WHERE organization_id = mo_global.get_current_org_id();


l_succ_cnt          NUMBER;
l_err_cnt           NUMBER;
l_op_unit_name      hr_operating_units.name%TYPE;
lx_msg_data         VARCHAR2(450);
l_msg_index_out     NUMBER :=0;
processed_sts       okl_cnsld_ar_hdrs_v.trx_status_code%TYPE;
error_sts           okl_cnsld_ar_hdrs_v.trx_status_code%TYPE;

    -- -----------------------------
    -- New fields
    -- -----------------------------
    l_old_cnr_id        NUMBER;
    l_old_lln_id        NUMBER;
    l_cnr_amount        okl_cnsld_ar_hdrs_v.amount%TYPE;
    l_lln_amount        okl_cnsld_ar_lines_v.amount%TYPE;

    CURSOR cnr_amt_csr ( p_cnr_id IN NUMBER ) IS
            SELECT SUM(lsm.amount)
            FROM okl_cnsld_ar_hdrs_b cnr,
                 okl_cnsld_ar_lines_b lln,
                 okl_cnsld_ar_strms_b lsm
            WHERE cnr.id = p_cnr_id   AND
                  cnr.id = lln.cnr_id AND
                  lln.id = lsm.lln_id;

    CURSOR lln_amt_csr ( p_lln_id IN NUMBER ) IS
            SELECT SUM(lsm.amount)
            FROM okl_cnsld_ar_lines_b lln,
                 okl_cnsld_ar_strms_b lsm
            WHERE lln.id = p_lln_id   AND
                  lln.id = lsm.lln_id;

  -- Start Bug 4731187
  l_qte_trx_date    DATE;
  -- End Bug 4731187


BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;

    L_DEBUG_ENABLED := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;

    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'Begin(+)');
    END IF;

    -- ------------------------
    -- Print Input variables
    -- ------------------------
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_commit '||p_commit);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'p_contract_number '||p_contract_number);
    END IF;

	------------------------------------------------------------
	-- Start processing
	------------------------------------------------------------

	x_return_status := Okl_Api.G_RET_STS_SUCCESS;

	l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
		RAISE Okl_Api.G_EXCEPTION_ERROR;
	END IF;

 IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== **** BEGIN PROGRAM EXECUTION **** ============');
 END IF;

--    IF p_contract_number IS NULL THEN

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== START: Three LEVEL Processing ============');
        END IF;
        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;

/* MDOKAL   -- This logic now executed separately
        OPEN c;
        LOOP
        cons_bill_tbl.delete;
        FETCH C BULK COLLECT INTO cons_bill_tbl LIMIT L_FETCH_SIZE;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'C cons_bill_tbl count is: '||cons_bill_tbl.COUNT);
        IF cons_bill_tbl.COUNT > 0 THEN
            process_cons_bill_tbl(
                p_contract_number	=> p_contract_number,
	            p_api_version       => p_api_version,
    	        p_init_msg_list     => p_init_msg_list,
                p_commit            => p_commit,
    	        x_return_status     => x_return_status,
    	        x_msg_count         => x_msg_count,
    	        x_msg_data          => x_msg_data,
                p_cons_bill_tbl     => cons_bill_tbl,
                p_saved_bill_rec    => saved_bill_rec,
                p_update_tbl        => l_update_tbl);
        END IF;
        EXIT WHEN C%NOTFOUND;
        END LOOP;
        CLOSE C;

        -- -----------------------------
        -- Process Last set of records
        -- -----------------------------
        process_break(p_contract_number,
                      p_commit,
                      saved_bill_rec,
                      l_update_tbl);

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT;
        END IF;

        PRINT_TO_LOG( '========== END: Three LEVEL Processing ============');

        PRINT_TO_LOG( '========== START: Two LEVEL Processing ============');
        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;
*/

        OKL_BILLING_CONTROLLER_PVT.create_cons_bill(
           p_contract_number  => p_contract_number,
	       p_api_version      => p_api_version,
    	   p_init_msg_list    => p_init_msg_list,
           p_commit           => p_commit,
           p_inv_msg          => p_inv_msg,
           p_assigned_process => p_assigned_process,
    	   x_return_status    => l_return_status,
   	       x_msg_count        => x_msg_count,
    	   x_msg_data         => x_msg_data);

	   IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
	    	RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
	    	RAISE Okl_Api.G_EXCEPTION_ERROR;
	   END IF;

/*
        OPEN C1;
        LOOP
        cons_bill_tbl.delete;
        FETCH C1 BULK COLLECT INTO cons_bill_tbl LIMIT L_FETCH_SIZE;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'C1 cons_bill_tbl count is: '||cons_bill_tbl.COUNT);
        IF cons_bill_tbl.COUNT > 0 THEN
            process_cons_bill_tbl(
                p_contract_number	=> p_contract_number,
	            p_api_version       => p_api_version,
    	        p_init_msg_list     => p_init_msg_list,
                p_commit            => p_commit,
    	        x_return_status     => x_return_status,
    	        x_msg_count         => x_msg_count,
    	        x_msg_data          => x_msg_data,
                p_cons_bill_tbl     => cons_bill_tbl,
                p_saved_bill_rec    => saved_bill_rec,
                p_update_tbl        => l_update_tbl);
        END IF;
        EXIT WHEN C1%NOTFOUND;
        END LOOP;
        CLOSE C1;

        -- -----------------------------
        -- Process Last set of records
        -- -----------------------------
        process_break(p_contract_number,
                      p_commit,
                      saved_bill_rec,
                      l_update_tbl);

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT;
        END IF;

        PRINT_TO_LOG( '========== END: Two LEVEL Processing ============');

        PRINT_TO_LOG( '========== START: CREDIT MEMO Two LEVEL Processing ============');
        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;
*/
        OPEN cm_two_lvl_csr;
        LOOP
        cons_bill_tbl.delete;
        FETCH cm_two_lvl_csr BULK COLLECT INTO cons_bill_tbl LIMIT L_FETCH_SIZE;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'cm_two_lvl_csr cons_bill_tbl count is: '||cons_bill_tbl.COUNT);
        IF cons_bill_tbl.COUNT > 0 THEN
            process_cons_bill_tbl(
                p_contract_number	=> p_contract_number,
	            p_api_version       => p_api_version,
    	        p_init_msg_list     => p_init_msg_list,
                p_commit            => p_commit,
    	        x_return_status     => x_return_status,
    	        x_msg_count         => x_msg_count,
    	        x_msg_data          => x_msg_data,
                p_cons_bill_tbl     => cons_bill_tbl,
                p_saved_bill_rec    => saved_bill_rec,
                p_update_tbl        => l_update_tbl);
        END IF;
        EXIT WHEN cm_two_lvl_csr%NOTFOUND;
        END LOOP;
        CLOSE cm_two_lvl_csr;

        -- -----------------------------
        -- Process Last set of records
        -- -----------------------------
        process_break(p_contract_number,
                      p_commit,
                      saved_bill_rec,
                      l_update_tbl);

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== END: CREDIT MEMO Two LEVEL Processing ============');
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== START: CREDIT MEMO Three LEVEL Processing ============');
        END IF;

        -- ---------------------------------------
        -- Initialize table and record parameters
        -- ---------------------------------------
        saved_bill_rec := l_init_bill_rec;
        cons_bill_tbl.delete;
        l_update_tbl.delete;

        OPEN cm_three_lvl_csr;
        LOOP
        cons_bill_tbl.delete;
        FETCH cm_three_lvl_csr BULK COLLECT INTO cons_bill_tbl LIMIT L_FETCH_SIZE;

        FND_FILE.PUT_LINE (FND_FILE.LOG, 'cm_three_lvl_csr cons_bill_tbl count is: '||cons_bill_tbl.COUNT);
        IF cons_bill_tbl.COUNT > 0 THEN
            process_cons_bill_tbl(
                p_contract_number	=> p_contract_number,
	            p_api_version       => p_api_version,
    	        p_init_msg_list     => p_init_msg_list,
                p_commit            => p_commit,
    	        x_return_status     => x_return_status,
    	        x_msg_count         => x_msg_count,
    	        x_msg_data          => x_msg_data,
                p_cons_bill_tbl     => cons_bill_tbl,
                p_saved_bill_rec    => saved_bill_rec,
                p_update_tbl        => l_update_tbl);
        END IF;
        EXIT WHEN cm_three_lvl_csr%NOTFOUND;
        END LOOP;
        CLOSE cm_three_lvl_csr;

        -- -----------------------------
        -- Process Last set of records
        -- -----------------------------
        process_break(p_contract_number,
                      p_commit,
                      saved_bill_rec,
                      l_update_tbl);

        IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT;
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== END: CREDIT MEMO Three LEVEL Processing ============');
        END IF;

--    ELSE -- Null value for contract specific consolidation
--        NULL;
--    END IF;







--Initialize the local variables to null, start afresh


	-- Set the table index to the next value
	cnr_tab_idx := NVL (cnr_update_tbl.LAST, 0) + 1;

    ------------------------------------------------------------
	-- Prime UBB Tracker
	------------------------------------------------------------
	l_clg_id   := -1;
 	l_cnr_id   := NULL;
IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== START: UBB Processing ============');
END IF;

l_commit_cnt := 0;

FOR  ubb_rec IN ubb_csr LOOP
         l_commit_cnt := l_commit_cnt + 1;

	 	 l_contract_number := null;
		 l_stream_name1    := null;

		 OPEN  cntrct_csr ( ubb_rec.contract_id );
 		 FETCH cntrct_csr INTO l_contract_number;
		 CLOSE cntrct_csr;

	 	 OPEN  strm_csr ( ubb_rec.stream_id );
		 FETCH strm_csr INTO l_stream_name1;
		 CLOSE strm_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, ' Processing Contract: '||l_contract_number||' ,Stream: '||l_stream_name1);
      END IF;

		 -- Start Fresh for Creating next UBB
		 l_lln_id   := NULL;
		 l_lsm_id   := NULL;

		--------------------------------------------
		-- Create an Invoice Header if first time
		-- Or break detected
		--------------------------------------------
 		IF ( l_clg_id <> ubb_rec.clg_id ) THEN
		   --------------------------------
		   -- Reset CNR ID for new Value
		   -------------------------------

           -- Commit and reset if the limit reached
           IF l_commit_cnt > G_Commit_Max THEN
              IF FND_API.To_Boolean( p_commit ) THEN
                 COMMIT;
              END IF;
              l_commit_cnt := 0;
           END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	   	   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE HEADER ***');
         END IF;
			l_cnr_id := NULL;
	        create_new_invoice(
					 ubb_rec.bill_to_site,
		  			 ubb_rec.customer_id,
		  			 ubb_rec.currency,
		  			 ubb_rec.payment_method,
                     --vthiruva bug#4438971 fix start..24-JUN-2005..passing fetched inf_id
                     --NULL,
                     ubb_rec.inf_id,
                     --vthiruva bug#4438971 fix end
		  			 ubb_rec.set_of_books_id,
		  			 ubb_rec.private_label,
					 ubb_rec.date_consolidated,
					 ubb_rec.org_id,
					 ubb_rec.legal_entity_id, -- for LE Uptake project 08-11-2006
					 l_cnr_id,
                     l_cons_inv_num);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '||l_cnr_id||' ***');
         END IF;


		   -----------------------------------
		   -- Save CLG ID for break detection
		   -----------------------------------
			l_clg_id := ubb_rec.clg_id;

		 END IF;


         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              	     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID '||l_cnr_id);
         END IF;
		 -- Null out current value in local variable.
		 l_lln_id := NULL;
		 create_new_line(
					  	 ubb_rec.contract_id,
					  	 l_cnr_id,
					  	 ubb_rec.kle_id,
					  	 NULL,
					  	 ubb_rec.currency,
					  	 ubb_rec.ubb_line_number,
					  	 'CHARGE',
						 'Y',
						 'N',
						 'N',
						 l_lln_id
		 			  	 );
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
         END IF;



   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE STREAMS *** for CNR_ID: '||l_cnr_id||' and LLN_ID: '||l_lln_id);
   END IF;
		--Null out local variable.
		l_lsm_id := null;
		create_new_streams(
	  		l_lln_id,
	  		ubb_rec.stream_id,
	  		ubb_rec.kle_id,
			ubb_rec.contract_id,
			ubb_rec.ubb_amount,
            ubb_rec.sel_id,
			l_lsm_id,
			x_return_status);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE STREAMS.Assigned Id: '||l_lsm_id||' ***');
        END IF;

		-- Build a PL/SQL table for later Updates
		cnr_update_tbl(cnr_tab_idx).cnr_id := l_cnr_id;
		cnr_update_tbl(cnr_tab_idx).lln_id := l_lln_id;
		cnr_update_tbl(cnr_tab_idx).lsm_id := l_lsm_id;
		cnr_update_tbl(cnr_tab_idx).xsi_id := ubb_rec.xsi_id;
		cnr_update_tbl(cnr_tab_idx).xls_id := ubb_rec.xls_id;
		cnr_update_tbl(cnr_tab_idx).return_status := x_return_status;

		-- Increment the PL/SQL table index for updates
		cnr_tab_idx := cnr_tab_idx + 1;
END LOOP; -- UBB Processing

IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
END IF;

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== END: UBB Processing ============');
END IF;

  ---------------------------------------------------
  -- Process all Termination Quote requests		   --
  ---------------------------------------------------
	-- Set the table index to the next value
  cnr_tab_idx := NVL (cnr_update_tbl.LAST, 0) + 1;

  ------------------------------------------------------------
  -- Prime QTE Tracker
  ------------------------------------------------------------
  l_qte_id   	  	:= -1;
  l_qte_cust_id     := -1;

  -- Start Bug 4731187
  l_qte_trx_date    := (sysdate - 732000);
  -- End Bug 4731187
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== START: TERMINATION QUOTE Processing ============');
  END IF;

  l_commit_cnt := 0;

  FOR qte_rec in qte_csr LOOP

         l_commit_cnt := l_commit_cnt + 1;

	 	 l_contract_number := null;
		 l_stream_name1    := null;

		 OPEN  cntrct_csr ( qte_rec.contract_id );
 		 FETCH cntrct_csr INTO l_contract_number;
		 CLOSE cntrct_csr;

	 	 OPEN  strm_csr ( qte_rec.stream_id );
		 FETCH strm_csr INTO l_stream_name1;
		 CLOSE strm_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, ' Processing Contract: '||l_contract_number||' ,Stream: '||l_stream_name1);
      END IF;

		 -- Start Fresh for Creating next UBB
		 l_lln_id   := NULL;
		 l_lsm_id   := NULL;

		--------------------------------------------
		-- Create an Invoice Header if first time
		-- Or break detected
		--------------------------------------------
        -- Start Bug 4731187
 		IF (     (l_qte_id <> qte_rec.qte_id)
              Or (l_qte_cust_id <> qte_rec.customer_id)
              Or ( l_qte_id = qte_rec.qte_id AND l_qte_trx_date <> qte_rec.date_consolidated )

           ) THEN
        -- End Bug 4731187
		   --------------------------------
		   -- Reset CNR ID for new Value
		   -------------------------------

            -- Commit and reset if the limit reached
            IF l_commit_cnt > G_Commit_Max THEN
               IF FND_API.To_Boolean( p_commit ) THEN
                    COMMIT;
               END IF;
               l_commit_cnt := 0;
            END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	   	   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE HEADER ***');
         END IF;
			l_cnr_id := NULL;
	        create_new_invoice(
					 qte_rec.bill_to_site,
		  			 qte_rec.customer_id,
		  			 qte_rec.currency,
		  			 qte_rec.payment_method,
                     --vthiruva bug#4438971 fix start..24-JUN-2005..passing fetched inf_id
                     --NULL,
                     qte_rec.inf_id,
                     --vthiruva bug#4438971 fix end
		  			 qte_rec.set_of_books_id,
		  			 qte_rec.private_label,
					 qte_rec.date_consolidated,
					 qte_rec.org_id,
					 qte_rec.legal_entity_id, -- for LE Uptake project 08-11-2006
					 l_cnr_id,
                     l_cons_inv_num);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '||l_cnr_id||' ***');
         END IF;


		   -----------------------------------
		   -- Save QTE ID for break detection
		   -----------------------------------
			l_qte_id 	  := qte_rec.qte_id;
			l_qte_cust_id := qte_rec.customer_id;

            -- Start Bug 4731187
            l_qte_trx_date := qte_rec.date_consolidated;
            -- End Bug 4731187
		 END IF;


         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              	     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID '||l_cnr_id);
         END IF;
		 -- Null out current value in local variable.
		 l_lln_id := NULL;
		 create_new_line(
					  	 qte_rec.contract_id,
					  	 l_cnr_id,
					  	 qte_rec.kle_id,
					  	 NULL,
					  	 qte_rec.currency,
					  	 qte_rec.qte_line_number,
					  	 qte_rec.description,
						 'Y',
						 'N',
						 'N',
						 l_lln_id
		 			  	 );
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
         END IF;



   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE STREAMS *** for CNR_ID: '||l_cnr_id||' and LLN_ID: '||l_lln_id);
   END IF;
		--Null out local variable.
		l_lsm_id := null;
		create_new_streams(
	  		l_lln_id,
	  		qte_rec.stream_id,
	  		qte_rec.kle_id,
			qte_rec.contract_id,
			qte_rec.qte_amount,
            qte_rec.sel_id,
			l_lsm_id,
			x_return_status);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE STREAMS.Assigned Id: '||l_lsm_id||' ***');
        END IF;

		-- Build a PL/SQL table for later Updates
		cnr_update_tbl(cnr_tab_idx).cnr_id := l_cnr_id;
		cnr_update_tbl(cnr_tab_idx).lln_id := l_lln_id;
		cnr_update_tbl(cnr_tab_idx).lsm_id := l_lsm_id;
		cnr_update_tbl(cnr_tab_idx).xsi_id := qte_rec.xsi_id;
		cnr_update_tbl(cnr_tab_idx).xls_id := qte_rec.xls_id;
		cnr_update_tbl(cnr_tab_idx).return_status := x_return_status;

		-- Increment the PL/SQL table index for updates
		cnr_tab_idx := cnr_tab_idx + 1;

  END LOOP;
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== END: TERMINATION QUOTE Processing ============');
  END IF;

  -----------------------------------
  --Processing Collections Records
  -----------------------------------

	-- Set the table index to the next value
  cnr_tab_idx := NVL (cnr_update_tbl.LAST, 0) + 1;

  ------------------------------------------------------------
  -- Prime CPY Tracker
  ------------------------------------------------------------
  l_cpy_id   := -1;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== START: Collections Records Processing ============');
  END IF;

  l_commit_cnt := 0;

  FOR cpy_rec in cpy_csr LOOP

         l_commit_cnt := l_commit_cnt + 1;

	 	 l_contract_number := null;
		 l_stream_name1    := null;

		 OPEN  cntrct_csr ( cpy_rec.contract_id );
 		 FETCH cntrct_csr INTO l_contract_number;
		 CLOSE cntrct_csr;

	 	 OPEN  strm_csr ( cpy_rec.stream_id );
		 FETCH strm_csr INTO l_stream_name1;
		 CLOSE strm_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            	 OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, ' Processing Contract: '||l_contract_number||' ,Stream: '||l_stream_name1);
      END IF;

		 -- Start Fresh for Creating next UBB
		 l_lln_id   := NULL;
		 l_lsm_id   := NULL;

		--------------------------------------------
		-- Create an Invoice Header if first time
		-- Or break detected
		--------------------------------------------
 		IF ( l_cpy_id <> cpy_rec.cpy_id ) THEN
		   --------------------------------
		   -- Reset CNR ID for new Value
		   -------------------------------
            -- Commit and reset if the limit reached
            IF l_commit_cnt > G_Commit_Max THEN
               IF FND_API.To_Boolean( p_commit ) THEN
                    COMMIT;
               END IF;
               l_commit_cnt := 0;
            END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	   	   	OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE HEADER ***');
         END IF;
			l_cnr_id := NULL;
	        create_new_invoice(
					 cpy_rec.bill_to_site,
		  			 cpy_rec.customer_id,
		  			 cpy_rec.currency,
		  			 cpy_rec.payment_method,
                     --vthiruva bug#4438971 fix start..24-JUN-2005..passing fetched inf_id
                     --NULL,
                     cpy_rec.inf_id,
                     --vthiruva bug#4438971 fix end
		  			 cpy_rec.set_of_books_id,
		  			 cpy_rec.private_label,
					 cpy_rec.date_consolidated,
					 cpy_rec.org_id,
					 cpy_rec.legal_entity_id, -- for LE Uptake project 08-11-2006
					 l_cnr_id,
                     l_cons_inv_num);
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
           	        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE HEADER.Assigned Id: '||l_cnr_id||' ***');
         END IF;


		   -----------------------------------
		   -- Save QTE ID for break detection
		   -----------------------------------
			l_cpy_id := cpy_rec.cpy_id;

		 END IF;

         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              	     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE LINE *** for CNR_ID '||l_cnr_id);
         END IF;
		 -- Null out current value in local variable.
		 l_lln_id := NULL;
		 create_new_line(
					  	 cpy_rec.contract_id,
					  	 l_cnr_id,
					  	 cpy_rec.kle_id,
					  	 NULL,
					  	 cpy_rec.currency,
					  	 cpy_rec.cpy_line_number,
					  	 'CHARGE',
						 'Y',
						 'N',
						 'N',
						 l_lln_id
		 			  	 );
         IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE LINE.Assigned Id: '||l_lln_id||' ***');
         END IF;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      		OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** CREATE CONSOLIDATED INVOICE STREAMS *** for CNR_ID: '||l_cnr_id||' and LLN_ID: '||l_lln_id);
   END IF;
		--Null out local variable.
		l_lsm_id := null;
		create_new_streams(
	  		l_lln_id,
	  		cpy_rec.stream_id,
	  		cpy_rec.kle_id,
			cpy_rec.contract_id,
			cpy_rec.cpy_amount,
            cpy_rec.sel_id,
			l_lsm_id,
			x_return_status);
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '*** DONE CREATION OF CONSOLIDATED INVOICE STREAMS.Assigned Id: '||l_lsm_id||' ***');
        END IF;

		-- Build a PL/SQL table for later Updates
		cnr_update_tbl(cnr_tab_idx).cnr_id := l_cnr_id;
		cnr_update_tbl(cnr_tab_idx).lln_id := l_lln_id;
		cnr_update_tbl(cnr_tab_idx).lsm_id := l_lsm_id;
		cnr_update_tbl(cnr_tab_idx).xsi_id := cpy_rec.xsi_id;
		cnr_update_tbl(cnr_tab_idx).xls_id := cpy_rec.xls_id;
		cnr_update_tbl(cnr_tab_idx).return_status := x_return_status;

		-- Increment the PL/SQL table index for updates
		cnr_tab_idx := cnr_tab_idx + 1;

  END LOOP;
  IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT;
  END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== END: Collections Records Processing ============');
  END IF;

-- Update the XTRX columns in XSI and XLS and Resequence the
-- Consolidated bill lines

l_cnr_id  := -1;

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== START: UPDATING Processed Records ============');
END IF;

l_commit_cnt := 0;

IF (cnr_update_tbl.COUNT > 0) THEN
   cnr_tab_idx := cnr_update_tbl.FIRST;
   LOOP
   	      l_commit_cnt := l_commit_cnt + 1;

	      -- This will resequence the consolidated bill lines
		  -- and update the amounts at the line and consolidated bill
		  -- level
		  IF l_cnr_id <> cnr_update_tbl(cnr_tab_idx).cnr_id THEN
	   	  	 l_cnr_id  := cnr_update_tbl(cnr_tab_idx).cnr_id;

	   		 l_seq_num := 0;
	   		 FOR line_seq IN line_seq_csr(l_cnr_id) LOOP
			 	 l_seq_num     := l_seq_num + 1;

				 l_line_amount := 0;
				 BEGIN
				 	  SELECT SUM(amount) INTO l_line_amount
				 	  FROM okl_cnsld_ar_strms_v
				 	  WHERE lln_id = line_seq.id;
				 EXCEPTION
				 	WHEN OTHERS THEN
						 l_line_amount := 0;
				 END;

				 --Initialize records
                 u_llnv_rec := null_llnv_rec;
                 x_llnv_rec := null_llnv_rec;
				 -- Update the consolidated lines with line num
				 -- and amount
				 u_llnv_rec.id 	            := line_seq.id;
				 u_llnv_rec.sequence_number := l_seq_num;
				 u_llnv_rec.amount			:= l_line_amount;

                 UPDATE Okl_Cnsld_Ar_Lines_b
                 SET sequence_number = l_seq_num,
                     amount = l_line_amount
                 WHERE id = line_seq.id;


	   		 END LOOP;

	   		 -- Update the amount on the Cons Bill header
             l_consbill_amount := 0;
			 BEGIN
	   		 	  SELECT SUM(amount) INTO l_consbill_amount
	   		 	  FROM okl_cnsld_ar_lines_v
	   		 	  WHERE cnr_id = l_cnr_id;
			 EXCEPTION
			 	  WHEN OTHERS THEN
				  	   l_consbill_amount := 0;
			 END;

			 --Update the consolidated headers table
             --Initialize records
             u_cnrv_rec                 := null_cnrv_rec;
             x_cnrv_rec                 := null_cnrv_rec;

			 u_cnrv_rec.id 		   	    := l_cnr_id;
			 u_cnrv_rec.amount 		   	:= l_consbill_amount;
			 u_cnrv_rec.trx_status_code := 'PROCESSED';
-- Start of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Hdrs_Pub.UPDATE_CNSLD_AR_HDRS

             UPDATE Okl_Cnsld_Ar_Hdrs_b
             SET amount = l_consbill_amount,
                 trx_status_code = 'PROCESSED'
             WHERE id = l_cnr_id;

-- End of wraper code generated automatically by Debug code generator for Okl_Cnsld_Ar_Hdrs_Pub.UPDATE_CNSLD_AR_HDRS

		  END IF;

		  -- Update the xtrx_fields on XSI
          -- Initialize records
          l_xsiv_rec := null_xsiv_rec;
          x_xsiv_rec := null_xsiv_rec;

        -----------------------------------------------------------
        -- Update only if consolidation entries were created
        -----------------------------------------------------------
        IF cnr_update_tbl(cnr_tab_idx).cnr_id IS NOT NULL THEN

		  l_xsiv_rec.id := cnr_update_tbl(cnr_tab_idx).xsi_id;

          -- Initialize fields
          l_xsiv_rec.XTRX_CONS_INVOICE_NUMBER := NULL;
   		  l_xsiv_rec.XTRX_FORMAT_TYPE         := NULL;

		  BEGIN
		  	   SELECT cnr.consolidated_invoice_number,
		       	 	  inf.name
		       INTO l_xsiv_rec.XTRX_CONS_INVOICE_NUMBER,
			   		l_xsiv_rec.XTRX_FORMAT_TYPE
		       FROM    okl_cnsld_ar_hdrs_v cnr,
                                       okl_invoice_formats_b infb,
                                       okl_invoice_formats_tl inf
		       WHERE cnr.id = cnr_update_tbl(cnr_tab_idx).cnr_id
                       AND cnr.inf_id = infb.id(+)
			and   infb.id = inf.id(+)
                       and   inf.language(+) = userenv('LANG');
		  EXCEPTION
		  	WHEN OTHERS THEN
				 l_xsiv_rec.XTRX_CONS_INVOICE_NUMBER := NULL;
		   		 l_xsiv_rec.XTRX_FORMAT_TYPE := NULL;
		  END;

		l_xsiv_rec.XTRX_INVOICE_PULL_YN       := 'Y';
		--l_xsiv_rec.XTRX_INVOICE_PULL_YN       := from rule;


        IF p_contract_number IS NULL THEN
          -- ------------------------------------------------
          -- To be used by Receivable Invoice Transfer to AR
          -- ------------------------------------------------
		  l_xsiv_rec.TRX_STATUS_CODE    		  := 'WORKING';
        ELSE
          -- -------------------------------------------
          -- To be used by the real time invoice API
          -- -------------------------------------------
		  l_xsiv_rec.TRX_STATUS_CODE    		  := 'ENTERED';
        END IF;

        UPDATE Okl_Ext_Sell_Invs_b
        SET TRX_STATUS_CODE = l_xsiv_rec.TRX_STATUS_CODE,
            XTRX_INVOICE_PULL_YN = 'Y'
        WHERE id = cnr_update_tbl(cnr_tab_idx).xsi_id;


        UPDATE Okl_Ext_Sell_Invs_tl
        SET XTRX_CONS_INVOICE_NUMBER = l_xsiv_rec.XTRX_CONS_INVOICE_NUMBER,
            XTRX_FORMAT_TYPE = l_xsiv_rec.XTRX_FORMAT_TYPE
        WHERE id = cnr_update_tbl(cnr_tab_idx).xsi_id;

		-- Update the xtrx_fields on XLS
        -- Initialize records
        l_xlsv_rec := null_xlsv_rec;
        x_xlsv_rec := null_xlsv_rec;

		l_xlsv_rec.id := cnr_update_tbl(cnr_tab_idx).xls_id;

        -- Initialize fields
        l_xlsv_rec.XTRX_CONS_LINE_NUMBER := NULL;
   	    l_xlsv_rec.XTRX_CONTRACT         := NULL;
 	    l_xlsv_rec.XTRX_STREAM_GROUP     := NULL;
        l_xlsv_rec.XTRX_ASSET            := NULL;
        l_xlsv_rec.XTRX_STREAM_TYPE		 := NULL;

		BEGIN
			 SELECT TO_CHAR(lln.sequence_number),
		       		SUBSTR(CONTRACT_NUMBER,1,30),
			  		-- TO_CHAR(lln.kle_id),
                    -- Added NVL for bug 4528015
			   		NVL(ilt.name, lln.line_type)
		     INTO l_xlsv_rec.XTRX_CONS_LINE_NUMBER,
		     	  l_xlsv_rec.XTRX_CONTRACT,
			 	  -- l_xlsv_rec.XTRX_ASSET,
			 	  l_xlsv_rec.XTRX_STREAM_GROUP
		     FROM  okl_cnsld_ar_lines_v lln,
		      	   okl_invc_line_types_v ilt,
 			  	   okc_k_headers_b khr
		     WHERE lln.id = cnr_update_tbl(cnr_tab_idx).lln_id AND
		      	   khr.id = lln.khr_id						  AND
		      	   lln.ilt_id = ilt.id(+);
		EXCEPTION
			 WHEN OTHERS THEN
			 	  l_xlsv_rec.XTRX_CONS_LINE_NUMBER := NULL;
		     	  l_xlsv_rec.XTRX_CONTRACT		   := NULL;
			 	  l_xlsv_rec.XTRX_STREAM_GROUP	   := NULL;
		END;


        l_xlsv_rec.XTRX_ASSET := NULL;
        OPEN  asset_line_csr(cnr_update_tbl(cnr_tab_idx).lsm_id);
        FETCH asset_line_csr INTO l_xlsv_rec.XTRX_ASSET;
        CLOSE asset_line_csr;

        -- Check for Subline asset for Service
        IF l_xlsv_rec.XTRX_ASSET IS NULL THEN
            OPEN  service_asset_csr(cnr_update_tbl(cnr_tab_idx).lsm_id);
            FETCH service_asset_csr INTO l_xlsv_rec.XTRX_ASSET;
            CLOSE service_asset_csr;
        END IF;

		BEGIN
			 SELECT sty.name
			 INTO l_xlsv_rec.XTRX_STREAM_TYPE
			 FROM  okl_cnsld_ar_strms_v lsm,
			  	   okl_strm_type_v	   sty
		     WHERE lsm.id = cnr_update_tbl(cnr_tab_idx).lsm_id AND
			  	   sty.id = lsm.sty_id;
		EXCEPTION
			 WHEN OTHERS THEN
			 	  l_xlsv_rec.XTRX_STREAM_TYPE := NULL;
		END;


		-- Update the Contract Number using khr_id in the
		-- Streams table. This will override the xtrx_contract
		-- set in the block select above.

        -- Initialize variables
        l_temp_khr_id                  := NULL;
        l_xlsv_rec.XTRX_CONTRACT       := NULL;
	    l_xlsv_rec.LSM_ID		  	   := NULL;
		l_xlsv_rec.XTRX_CONS_STREAM_ID := NULL;


		OPEN  get_khr_id(cnr_update_tbl(cnr_tab_idx).lsm_id);
		FETCH get_khr_id INTO l_temp_khr_id;
		CLOSE get_khr_id;

		OPEN  cntrct_csr( l_temp_khr_id );
		FETCH cntrct_csr INTO l_xlsv_rec.XTRX_CONTRACT;
		CLOSE cntrct_csr;

	    l_xlsv_rec.LSM_ID		  	   := cnr_update_tbl(cnr_tab_idx).lsm_id;
		l_xlsv_rec.XTRX_CONS_STREAM_ID := cnr_update_tbl(cnr_tab_idx).lsm_id;


		-- Update the XLS
-- Start of wraper code generated automatically by Debug code generator for Okl_Xtl_Sell_Invs_Pub.UPDATE_XTL_SELL_INVS
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRKONB.pls call Okl_Xtl_Sell_Invs_Pub.UPDATE_XTL_SELL_INVS ');
    END;
  END IF;

        UPDATE Okl_Xtl_Sell_Invs_b
        SET LSM_ID = l_xlsv_rec.LSM_ID,
            XTRX_CONS_LINE_NUMBER = l_xlsv_rec.XTRX_CONS_LINE_NUMBER,
            XTRX_CONS_STREAM_ID = l_xlsv_rec.XTRX_CONS_STREAM_ID
        WHERE id = l_xlsv_rec.id;

        UPDATE Okl_Xtl_Sell_Invs_tl
        SET XTRX_CONTRACT = l_xlsv_rec.XTRX_CONTRACT,
            XTRX_ASSET = l_xlsv_rec.XTRX_ASSET,
            XTRX_STREAM_TYPE = l_xlsv_rec.XTRX_STREAM_TYPE,
            XTRX_STREAM_GROUP = l_xlsv_rec.XTRX_STREAM_GROUP
        WHERE id = l_xlsv_rec.id;

  ELSE-- CNR entries not created

        UPDATE okl_ext_sell_invs_b
        SET trx_status_code = 'ERROR'
        WHERE id = cnr_update_tbl(cnr_tab_idx).xsi_id;

  END IF; -- CNR entries not created

  -- Commit and reset if the limit reached
  IF l_commit_cnt > G_Commit_Max THEN
     IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT;
     END IF;
     l_commit_cnt := 0;
  END IF;
-- End of wraper code generated automatically by Debug code generator for Okl_Xtl_Sell_Invs_Pub.UPDATE_XTL_SELL_INVS
   EXIT WHEN (cnr_tab_idx = cnr_update_tbl.LAST);
   cnr_tab_idx := cnr_update_tbl.NEXT(cnr_tab_idx);
   END LOOP;
END IF;
IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT;
END IF;

IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== END: UPDATING Processed Records ============');
  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE, '========== **** END PROGRAM EXECUTION **** ============');
END IF;

	-- ----------------------------------------------------------
	-- Print net output by currency
	-- ----------------------------------------------------------
    -- Get the request Id
    l_request_id := NULL;
    OPEN  req_id_csr;
    FETCH req_id_csr INTO l_request_id;
    CLOSE req_id_csr;

    processed_sts       := 'PROCESSED';
    error_sts           := 'ERROR';

    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;
    OPEN  op_unit_csr;
    FETCH op_unit_csr INTO l_op_unit_name;
    CLOSE op_unit_csr;

    -- Start New Out File stmathew 15-OCT-2004
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 54, ' ')||'Oracle Leasing and Finance Management'||lpad(' ', 55, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 51, ' ')||'Receivable Bills Consolidation'||lpad(' ', 51, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 51, ' ')||'------------------------------'||lpad(' ', 51, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Operating Unit: '||l_op_unit_name);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Request Id: '||l_request_id||lpad(' ',74,' ') ||'Run Date: '||to_char(sysdate));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad('-', 132, '-'));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Processing Details:'||lpad(' ', 113, ' '));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));

    -- ----------------------------------------
    -- Loop thru consolidated invoices created
    -- ----------------------------------------
    FOR curr_rec in curr_csr( l_request_id ) LOOP

     l_succ_cnt          := 0;
     l_err_cnt           := 0;

     -- ---------------------------------------------
     -- Success Count
     -- ---------------------------------------------
     OPEN  cnr_cnt_csr( l_request_id, processed_sts, curr_rec.currency_code );
     FETCH cnr_cnt_csr INTO l_succ_cnt;
     CLOSE cnr_cnt_csr;

     -- ---------------------------------------------
     -- Error Count
     -- ---------------------------------------------
     OPEN  cnr_cnt_csr( l_request_id, error_sts, curr_rec.currency_code );
     FETCH cnr_cnt_csr INTO l_err_cnt;
     CLOSE cnr_cnt_csr;

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,'Currency '||curr_rec.currency_code);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '                Number of Consolidated Invoices Created: '||(l_succ_cnt+l_err_cnt));
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '                Number of Successful Invoice Lines     : '||l_succ_cnt);
    FND_FILE.PUT_LINE (FND_FILE.OUTPUT, '                Number of Errored Invoice Lines        : '||l_err_cnt);

    FND_FILE.PUT_LINE (FND_FILE.OUTPUT,rpad(' ', 132, ' '));


    END LOOP;

    IF x_msg_count > 0 THEN
      FOR i IN 1..x_msg_count LOOP
            IF i = 1 THEN
                FND_FILE.PUT_LINE (FND_FILE.LOG,'Details of Errored Stream Elements:'||lpad(' ', 97, ' '));
                FND_FILE.PUT_LINE (FND_FILE.LOG,rpad(' ', 132, ' '));
            END IF;

            fnd_msg_pub.get (p_msg_index => i,
                             p_encoded => 'F',
                             p_data => lx_msg_data,
                             p_msg_index_out => l_msg_index_out);

            FND_FILE.PUT_LINE (FND_FILE.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);
      END LOOP;
    END IF;

    IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,'okl_cons_bill'
									,'End(-)');
    END IF;

    -- -------------------------------------------
    -- Purge data from the Parallel process Table
    -- -------------------------------------------

    IF p_assigned_process IS NOT NULL THEN
        DELETE OKL_PARALLEL_PROCESSES
        WHERE assigned_process = p_assigned_process;
        COMMIT;
    END IF;


	------------------------------------------------------------
	-- End processing
	------------------------------------------------------------

	Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);


EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN

        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'Okl_Api.G_EXCEPTION_ERROR');
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(O1): '||SQLERRM);
     END IF;
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN

        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(O2): '||SQLERRM);
     END IF;
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN

        -- -------------------------------------------
        -- Purge data from the Parallel process Table
        -- -------------------------------------------
        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (L_DEBUG_ENABLED='Y' and FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'okl_cons_bill',
               'EXCEPTION :'||'OTHERS');
        END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'*=> Error Message(O3): '||SQLERRM);
     END IF;
		x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

END create_cons_bill;

END Okl_Cons_Bill;

/
