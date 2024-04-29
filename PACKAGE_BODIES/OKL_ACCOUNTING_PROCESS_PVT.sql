--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_PROCESS_PVT" AS
/* $Header: OKLRAECB.pls 120.13 2007/12/05 19:38:28 smereddy noship $ */
-- Start of wraper code generated automatically by Debug code generator

  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.PROCESS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator

-- Added by Santonyr on 28-Jan-2003 for reporting purpose

  TYPE trx_err_rec_type IS RECORD (
    trx_number                    okl_trx_contracts.trx_number%TYPE,
    source_table                  okl_ae_lines.source_table%TYPE,
    period_name			    VARCHAR2(30),
    source_id                     okl_ae_lines.source_id%TYPE,
    gl_date                       DATE);

  TYPE trx_err_tbl_type IS TABLE OF trx_err_rec_type
  INDEX BY BINARY_INTEGER;

  l_trx_err_tbl     trx_err_tbl_type;
  l_total_headers   NUMBER := 0;
  l_total_lines     NUMBER := 0;
  l_error_msg_rec     Okl_Accounting_Util.ERROR_MESSAGE_TYPE;



--Added by Keerthi for formating the output in the report

  TYPE report_rec_type IS RECORD(
    transaction_date          VARCHAR2(51),
    contract_number	 	VARCHAR2(105),
    transaction_number		VARCHAR2(60),
    transaction_line_number	VARCHAR2(30),
    accounting_date		VARCHAR2(36),
    dr_cr_flag                VARCHAR2(18),
    accounted_amount		VARCHAR2(72),
    account             VARCHAR2(90),
    currency			VARCHAR2(24));

  TYPE err_report_rec_type IS RECORD(
    transaction_date          VARCHAR2(36),
    contract_number	 	VARCHAR2(90),
    transaction_number		VARCHAR2(45),
    transaction_line_number	VARCHAR2(21),
    accounting_date		VARCHAR2(36),
    accounting_period		VARCHAR2(60),
    amount			      VARCHAR2(57),
    currency			VARCHAR2(24));

--- Variables to hold length

-- Fixed bug 3861943 on 9-Sep-2004

   l_transaction_date_len           CONSTANT NUMBER := 15;
   l_contract_number_len	 	CONSTANT NUMBER := 30;
   l_transaction_number_len		CONSTANT NUMBER := 20;
   l_transaction_line_number_len	CONSTANT NUMBER :=  7;
   l_accounting_date_len		CONSTANT NUMBER := 12;
   l_dr_cr_flag_len                 CONSTANT NUMBER := 6;
   l_accounted_amount_len		CONSTANT NUMBER := 24;
   l_account_len				CONSTANT NUMBER := 90;
   l_currency_len				CONSTANT NUMBER := 8;
   l_amount_len			 	CONSTANT NUMBER := 16;
   l_accounting_period_len		CONSTANT NUMBER := 12;

   header_report_rec          	report_rec_type;
   header_report_rec2          	report_rec_type;

   proc_report_rec 			report_rec_type;
   dr_cr_report_rec  			report_rec_type;
   invalid_acc_report_rec   		report_rec_type;

   header_err_report_rec		err_report_rec_type;
   header_err_report_rec2		err_report_rec_type;

   non_proc_report_rec			err_report_rec_type;


PROCEDURE DO_CLEANUP(p_aetv_rec       IN   aetv_rec_type,
                     x_return_status  OUT NOCOPY  VARCHAR2)

IS

  CURSOR dist_csr(v_aet_id       NUMBER) IS
  SELECT ID
  FROM  OKL_TRNS_ACC_DSTRS
  WHERE aet_id       = v_aet_id;

  l_tabv_tbl           TABV_TBL_TYPE;
  x_tabv_tbl           TABV_TBL_TYPE;

  i                    NUMBER := 0;
  l_return_status      VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_api_version        NUMBER := 1.0;
  l_init_msg_list      VARCHAR2(1);
  l_msg_count          NUMBER ;
  l_msg_data           VARCHAR2(2000);

BEGIN

--- Deleting Accounting Event API would also delete all its child

   Okl_Acct_Event_Pub.delete_acct_event(p_api_version    => l_api_version,
                                        p_init_msg_list  => l_init_msg_list,
                                        x_return_status  => l_return_status,
                                        x_msg_count      => l_msg_count,
                                        x_msg_data       => l_msg_data,
                                        p_aetv_rec       => p_aetv_rec);

   IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN

       FOR dist_rec IN dist_csr(p_aetv_rec.accounting_event_id)
       LOOP
           i := i + 1;
           l_tabv_tbl(i).ID         := dist_rec.ID;
           l_tabv_tbl(i).posted_yn  := 'N';
           l_tabv_tbl(i).aet_id     := NULL;

       END LOOP;

       Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs(p_api_version    => l_api_version,
                                                    p_init_msg_list  => l_init_msg_list,
                                                    x_return_status  => l_return_status,
                                                    x_msg_count      => l_msg_count,
                                                    x_msg_data       => l_msg_data,
                                                    p_tabv_tbl       => l_tabv_tbl,
                                                    x_tabv_tbl       => x_tabv_tbl);

   END IF;

   x_return_status := l_return_status;


END DO_CLEANUP;




-- This Procedure will create the accounting events. It will select the record
-- from Distribution table having posted_yn = 'S' and create accounting events
-- for distinct combination of source id, source table and reverse event flag



PROCEDURE CREATE_EVENTS(p_api_version                  IN  NUMBER,
                        p_init_msg_list                IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                        x_return_status                OUT NOCOPY VARCHAR2,
                        x_msg_count                    OUT NOCOPY NUMBER,
                        x_msg_data                     OUT NOCOPY VARCHAR2,
                        x_total_events                 OUT NOCOPY NUMBER)

IS

  CURSOR dists_csr IS
  SELECT DISTINCT source_id,
                  source_table,
                  reverse_event_flag
  FROM OKL_TRNS_ACC_DSTRS
  WHERE posted_yn = 'S';

  CURSOR dist_csr(v_source_id    NUMBER,
                  v_source_table VARCHAR2,
                  v_rev_flag     VARCHAR2) IS
  SELECT ID,
         template_id,
         TRUNC(gl_date) gl_date
  FROM OKL_TRNS_ACC_DSTRS
  WHERE source_id          = v_source_id
  AND   source_table       = v_source_table
  AND   reverse_event_flag = v_rev_flag;

  CURSOR trx_csr(v_source_id NUMBER) IS
  SELECT tcn.trx_number,
         try.trx_type_class
  FROM OKL_TXL_CNTRCT_LNS tcl,
  	OKL_TRX_CONTRACTS tcn,
       OKL_TRX_TYPES_V try
  WHERE tcl.id = v_source_id
  AND   tcl.tcn_id = tcn.id
  AND   tcn.try_id = try.id;

  CURSOR tal_csr(v_source_id NUMBER) IS
  SELECT tas.trans_number,
         try.trx_type_class
  FROM OKL_TXL_ASSETS_B tal,
       OKL_TRX_ASSETS tas,
       OKL_TRX_TYPES_V try
  WHERE tal.id = v_source_id
  AND   tal.tas_id = tas.id
  AND   tas.try_id = try.id;


  CURSOR aet_csr (v_source_id NUMBER,
                  v_source_table VARCHAR2) IS
  SELECT NVL(MAX(event_number),0)
  FROM OKL_ACCOUNTING_EVENTS
  WHERE source_id    = v_source_id
  AND   source_table = v_source_table;


  l_dist_tbl_in    tabv_tbl_type;
  l_dist_tbl_out   tabv_tbl_type;
  l_tabv_tbl       tabv_tbl_type;
  x_tabv_tbl       tabv_tbl_type;

  l_try_id           NUMBER;
  l_aet_id           NUMBER;
  i                  NUMBER := 0;
  l_event_number     NUMBER := 0;
  l_api_version      NUMBER := 1.0;
  l_total_events     NUMBER := 0;
  l_trx_number       OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE;

  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_overall_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  l_event_type_code  OKL_ACCOUNTING_EVENTS.EVENT_TYPE_CODE%TYPE;
  l_event_rec_in     AETV_REC_TYPE;
  l_event_rec_out    AETV_REC_TYPE;
  l_trx_type_class   OKL_TRX_TYPES_V.TRX_TYPE_CLASS%TYPE;
  l_try_id           NUMBER;
  l_gl_date          DATE;
  l_tab_count        NUMBER := 0;


  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    FOR dists_rec IN dists_csr

    LOOP

        BEGIN
           i := 0;
           l_tabv_tbl.DELETE;

           FOR dist_rec IN dist_csr(dists_rec.source_id,
                                    dists_rec.source_table,
                                    dists_rec.reverse_event_flag)
           LOOP

               i := i + 1;
               l_tabv_tbl(i).ID          := dist_rec.ID;
               l_tabv_tbl(i).template_id := dist_rec.template_id;
               l_tabv_tbl(i).gl_date     := dist_rec.gl_date;
               l_gl_date                 := dist_rec.gl_date;

           END LOOP;

           IF (dists_rec.source_table = 'OKL_TXL_CNTRCT_LNS') THEN
               OPEN trx_csr(dists_rec.source_id);
               FETCH trx_csr INTO l_trx_number,
                                  l_trx_type_class;
               IF (trx_csr%NOTFOUND) THEN
                   Fnd_File.PUT_LINE(Fnd_File.LOG, 'Could not get transaction Number and Transaction type Class');
                   CLOSE trx_csr;
                   RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;

               CLOSE trx_csr;

           ELSIF (dists_rec.source_table = 'OKL_TXL_ASSETS_B') THEN

               OPEN tal_csr(dists_rec.source_id);
               FETCH tal_csr INTO l_trx_number,
                                  l_trx_type_class;
               IF (tal_csr%NOTFOUND) THEN
                  Fnd_File.PUT_LINE(Fnd_File.LOG, 'Could not get transaction Number and Transaction type Class');
                  CLOSE tal_csr;
                  RAISE Okl_Api.G_EXCEPTION_ERROR;
               END IF;
               CLOSE tal_csr;
           ELSE
               Fnd_File.PUT_LINE(Fnd_File.LOG, 'Invalid Source Table ' || dists_rec.source_table || ' found');
               RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;

        --      Get the max event number for this source id  and table combination

           OPEN aet_csr(dists_rec.source_id,
                        dists_rec.source_table);
           FETCH aet_csr INTO l_event_number;
           CLOSE aet_csr;

           l_event_rec_in.EVENT_NUMBER                := l_event_number + 1;

           IF (dists_rec.reverse_event_flag = 'Y') THEN
              l_event_rec_in.EVENT_TYPE_CODE             := l_trx_type_class || '_REV';
           ELSE
              l_event_rec_in.EVENT_TYPE_CODE             := l_trx_type_class;
           END IF;

           l_event_rec_in.SOURCE_ID                   := dists_rec.source_id;
           l_event_rec_in.EVENT_STATUS_CODE           := 'CREATED';
           l_event_rec_in.ACCOUNTING_DATE             := l_gl_date;
           l_event_rec_in.SOURCE_TABLE                := dists_rec.source_table;


--- Create the Accounting Events
           Okl_Acct_Event_Pub.create_acct_event(p_api_version      => p_api_version,
                                                p_init_msg_list    => p_init_msg_list,
                                                x_return_status    => l_return_status,
                                                x_msg_count        => x_msg_count,
                                                x_msg_data         => x_msg_data,
                                                p_aetv_rec         => l_event_rec_in,
                                                x_aetv_rec         => l_event_rec_out);

           IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
               Fnd_File.PUT_LINE(Fnd_File.LOG,
                   'Error in Creating Accounting event for transaction Number ' || l_trx_number);
               RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;

        -- Update the accounting event id for the distributions

           FOR l_tab_count IN 1..l_tabv_tbl.COUNT
           LOOP
              l_tabv_tbl(l_tab_count).AET_ID := l_event_rec_out.accounting_event_id;

-- Added by Santonyr Bug 3925719

	    BEGIN
	      UPDATE OKL_TRNS_ACC_DSTRS
	      SET    AET_ID =l_tabv_tbl(l_tab_count).AET_ID,
		     last_update_date = SYSDATE,
		     last_updated_by = Fnd_Global.user_id,
		     last_update_login = Fnd_Global.login_id,
		     program_update_date = SYSDATE,
		     program_application_id = Fnd_Global.prog_appl_id,
		     program_id = Fnd_Global.conc_program_id,
		     request_id = Fnd_Global.conc_request_id
	       WHERE ID = l_tabv_tbl(l_tab_count).ID;

	     EXCEPTION
	       WHEN OTHERS THEN
		 l_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
		 Fnd_File.PUT_LINE(Fnd_File.LOG, SQLERRM);

	     END;

           END LOOP;

-- Commented by Santonyr Bug 3925719

/*
           Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs(p_api_version     => p_api_version,
                                                        p_init_msg_list   => p_init_msg_list,
                                                        x_return_status   => l_return_status,
                                                        x_msg_count       => x_msg_count,
                                                        x_msg_data        => x_msg_data,
                                                        p_tabv_tbl        => l_tabv_tbl,
                                                        x_tabv_tbl        => x_tabv_tbl);

*/


           IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                Fnd_File.PUT_LINE(Fnd_File.LOG,
                   'Error in Updating Distribution with accounting event id for transaction Number ' || l_trx_number);

                DO_CLEANUP(p_aetv_rec       => l_Event_rec_out,
                           x_return_status  => l_return_status);

                RAISE Okl_Api.G_EXCEPTION_ERROR;
           END IF;

           l_total_events := l_total_events + 1;

           IF MOD(l_total_events, g_commit_cycle)=0 THEN
                  COMMIT;
           END IF;

        EXCEPTION

             WHEN Okl_Api.G_EXCEPTION_ERROR THEN

                  Okl_Accounting_Util.GET_ERROR_MESSAGE(l_error_msg_rec);
                  IF (l_error_msg_rec.COUNT > 0) THEN
                       FOR m IN  l_error_msg_rec.FIRST..l_error_msg_rec.LAST
                       LOOP
                          Fnd_File.PUT_LINE(Fnd_File.LOG, l_error_msg_rec(m));
                       END LOOP;
                  END IF;

        END;

    END LOOP;

    x_total_events  := l_total_events;
    COMMIT WORK;

END CREATE_EVENTS;



FUNCTION GET_CATEGORY(p_trx_type VARCHAR2)
 RETURN VARCHAR2

IS

  l_category   GL_JE_CATEGORIES.JE_CATEGORY_NAME%TYPE;

BEGIN

/*

  IF (p_trx_type = 'BOOKING')              THEN
     l_category := 'Booking';
  ELSIF (p_trx_type = 'REBOOK')            THEN
     l_category := 'Rebook';
  ELSIF (p_trx_type = 'RENEWAL')           THEN
     l_category := 'Renewal';
  ELSIF (p_trx_type = 'SPLIT_CONTRACT')    THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'SPLIT_ASSET')       THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'RELEASE')           THEN
     l_category := 'Release';
  ELSIF (p_trx_type = 'REVERSE')           THEN
     l_category := 'Reverse';
  ELSIF (p_trx_type = 'SYNDICATION')       THEN
     l_category := 'Syndication';
  ELSIF (p_trx_type = 'VENDOR_CURE')       THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'INSURANCE')         THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'TERMINATION')       THEN
     l_category := 'Termination';
  ELSIF (p_trx_type = 'ASSET_DISPOSITION') THEN
     l_category := 'Asset Disposition';
  ELSIF (p_trx_type = 'ASSET_CONDITION')   THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'REMARKET')          THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'WRITE_DOWN')        THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'REPURCHASE')        THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'ASSET_RESIDUAL_CHANGE') THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'MISCELLANEOUS') THEN
     l_category := 'Miscellaneous';
  ELSIF (p_trx_type = 'ACCRUAL') THEN
     l_category := 'Accrual';
  ELSIF (p_trx_type = 'GENERAL_LOSS_PROVISION') THEN
     l_category := 'Loss Provision';
  ELSIF (p_trx_type = 'SPECIFIC_LOSS_PROVISION') THEN
     l_category := 'Loss Provision';
  ELSIF (p_trx_type = 'ADJUSTMENTS') THEN
     l_category := 'Adjustment';
  END IF;
*/

-- Changed by Santonyr on 15-Sep-2004
-- Fixed bug 3755410

  IF (p_trx_type IN ('ACL', 'NACL')) THEN
     l_category := 'Lease Accrual';
  ELSIF (p_trx_type = 'ALT') THEN
     l_category := 'Termination';

-- Changed by Santonyr on 23-Jul-2003
-- Fixed bug 3065524

-- Changed by Santonyr on 04-Aug-2003
-- Fixed bug 3084790

  ELSIF (p_trx_type IN ('INV', 'BKG', 'REL')) THEN
     l_category := 'Booking';
  ELSIF (p_trx_type = 'MAE') THEN
     l_category := 'Miscellaneous';
  ELSIF (p_trx_type = 'PGL') THEN
     l_category := 'Loss Provision';
  ELSIF (p_trx_type = 'PSP') THEN
     l_category := 'Loss Provision';
  ELSIF (p_trx_type = 'RVS') THEN
     l_category := 'Reverse';
  ELSIF (p_trx_type = 'SIV') THEN
     l_category := 'Syndication';
-- Changed by sgiyer on 5-Oct-2005.
-- Bug 4636977. Added RAP TCL_TYPE to Adjustment category.
-- Changed by sgiyer on 21-Mar-2006.
-- Bug 5033120. Added PAD TCL_TYPE to Adjustment category.
--Bug 6117940 Added SPA TCL_TYPE
ELSIF (p_trx_type IN ('AAJ', 'SPL', 'RAP', 'PAD','SPA')) THEN
     l_category := 'Adjustment';
  ELSIF (p_trx_type = 'TMT') THEN
     l_category := 'Termination';
  ELSIF (p_trx_type = 'TRBK') THEN
     l_category := 'Rebook';
  ELSIF (p_trx_type = 'RFL') THEN
     l_category := 'Asset Disposition';
  --akrangan bug 5354501 fix start
 	ELSIF (p_trx_type = 'EVG') THEN
 	   l_category := 'Evergreen';
  --akrangan bug 5354501 fix start
  END IF;

  RETURN (l_category);

END GET_CATEGORY;



PROCEDURE CREATE_AE_HEADER(p_api_version         IN   NUMBER,
                           p_init_msg_list       IN   VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                           x_return_status       OUT  NOCOPY VARCHAR2,
                           x_msg_count           OUT  NOCOPY NUMBER,
                           x_msg_data            OUT  NOCOPY VARCHAR2,
                           p_aetv_rec            IN   aetv_rec_type,
                           p_period_name         IN   VARCHAR2,
                           p_trx_number          IN   VARCHAR2,
                           p_trx_type	       IN   VARCHAR2,
                           x_aehv_rec            OUT  NOCOPY aehv_rec_type)

IS

 l_header_rec_in   AEHV_REC_TYPE;
 l_header_rec_out  AEHV_REC_TYPE;
 l_aetv_rec        AETV_REC_TYPE := p_aetv_rec;

 l_start_date      DATE;
 l_end_date        DATE;

 l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;


 TYPE ref_cursor IS REF CURSOR;
 trx_csr ref_cursor;

 l_trx_type_class OKL_TRX_TYPES_V.TRX_TYPE_CLASS%TYPE;
 l_ae_category  OKL_AE_HEADERS.AE_CATEGORY%TYPE;
 l_template_id  NUMBER;
 l_try_id       NUMBER;
 l_trx_number   OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE := p_trx_number;


BEGIN

   l_ae_category := GET_CATEGORY(p_trx_type);

   IF (l_ae_category IS NULL) THEN
       Fnd_File.PUT_LINE(Fnd_File.LOG,
            'GL Category Not Found while Processing Transaction Number ' || l_trx_number);
       RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;

   l_header_rec_in.POST_TO_GL_FLAG        := 'Y';  -- Unused Flag.
   l_header_rec_in.ACCOUNTING_EVENT_ID    :=  l_aetv_rec.accounting_event_id;
   l_header_rec_in.AE_CATEGORY            :=  l_ae_category;
   l_header_rec_in.PERIOD_NAME            :=  p_period_name;
   l_header_rec_in.ACCOUNTING_DATE        :=  l_aetv_rec.accounting_date;
   l_header_rec_in.GL_TRANSFER_RUN_ID     := -1;
   l_header_rec_in.CROSS_CURRENCY_FLAG    := 'N'; --??
   l_header_rec_in.GL_TRANSFER_FLAG       := 'N';
   l_header_rec_in.SEQUENCE_ID            := NULL;
   l_header_rec_in.SEQUENCE_VALUE         := NULL;
   l_header_rec_in.DESCRIPTION            := NULL;
   l_header_rec_in.ACCOUNTING_ERROR_CODE  := NULL;
   l_header_rec_in.GL_TRANSFER_ERROR_CODE := NULL;
   l_header_rec_in.GL_REVERSAL_FLAG       := NULL;

-- Start of wraper code generated automatically by Debug code generator for OKL_ACCT_EVENT_PUB.create_acct_header
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRAECB.pls call OKL_ACCT_EVENT_PUB.create_acct_header ');
    END;
  END IF;
   Okl_Acct_Event_Pub.create_acct_header(p_api_version      => p_api_version,
                                         p_init_msg_list    => p_init_msg_list,
                                         x_return_status    => l_return_status,
                                         x_msg_count        => x_msg_count,
                                         x_msg_data         => x_msg_data,
                                         p_aehv_rec         => l_header_rec_in,
                                         x_aehv_rec         => l_header_rec_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRAECB.pls call OKL_ACCT_EVENT_PUB.create_acct_header ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCT_EVENT_PUB.create_acct_header

   x_return_status := l_return_status;
   x_aehv_rec:=l_header_rec_out;


EXCEPTION

   WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;

END CREATE_AE_HEADER;



PROCEDURE CREATE_AE_LINES(p_api_version         IN   NUMBER,
                          p_init_msg_list       IN   VARCHAR2 DEFAULT Okc_Api.G_FALSE,
                          x_return_status       OUT  NOCOPY VARCHAR2,
                          x_msg_count           OUT  NOCOPY NUMBER,
                          x_msg_data            OUT  NOCOPY VARCHAR2,
                          p_aetv_rec            IN   AETV_REC_TYPE,
                          p_trx_number          IN   VARCHAR2,
                          x_total_lines         OUT NOCOPY  NUMBER,
                          x_ret_message         OUT NOCOPY  VARCHAR2)
IS

 CURSOR dist_csr (v_aet_id    NUMBER) IS
 SELECT  ID
        ,CURRENCY_CONVERSION_TYPE
        ,CR_DR_FLAG
        ,CODE_COMBINATION_ID
        ,CURRENCY_CODE
        ,AE_LINE_TYPE
        ,TEMPLATE_ID
        ,SOURCE_ID
        ,SOURCE_TABLE
        ,AMOUNT
        ,ACCOUNTED_AMOUNT
        ,GL_DATE
        ,PERCENTAGE
        ,CURRENCY_CONVERSION_DATE
        ,CURRENCY_CONVERSION_RATE
  FROM OKL_TRNS_ACC_DSTRS
  WHERE aet_id = v_aet_id;

  CURSOR aeh_csr(v_aet_id NUMBER) IS
  SELECT ae_header_id
  FROM OKL_AE_HEADERS
  WHERE accounting_event_id = v_aet_id;

  l_aetv_rec  aetv_rec_type := p_aetv_rec;
  l_ae_header_id NUMBER;
  l_aelv_tbl_in  aelv_tbl_type;
  l_aelv_tbl_out aelv_tbl_type;
  l_error_code   OKL_AE_LINES.accounting_error_code%TYPE;
  l_line_number  NUMBER := 0;
  l_ccid_valid   VARCHAR2(1) := Okl_Api.G_TRUE;
  i              NUMBER := 0;
  l_description  OKL_AE_LINES.Description%TYPE;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  l_trx_number   OKL_TRX_CONTRACTS.TRX_NUMBER%TYPE := p_trx_number;
  l_total_lines  NUMBER;
  l_contract_number OKL_K_HEADERS_FULL_V.CONTRACT_NUMBER%TYPE;

-- Added by Santonyr Bug 3925719

CURSOR trx_cntrct_csr (p_source_id NUMBER) IS
SELECT
  tcn.try_id
FROM
  okl_txl_cntrct_lns txl,
  okl_trx_contracts tcn
WHERE
  txl.id = p_source_id AND
  txl.tcn_id = tcn.id;

CURSOR trx_asset_csr (p_source_id NUMBER) IS
SELECT
  tas.try_id
FROM
  okl_txl_assets_b txl,
  okl_trx_assets tas
WHERE
  txl.id = p_source_id AND
  txl.tas_id = tas.id;



BEGIN

  -- Get the header id
  OPEN aeh_csr(l_aetv_rec.accounting_Event_id);
  FETCH aeh_csr INTO l_ae_header_id;
  CLOSE aeh_csr;

  FOR dist_rec IN dist_csr(l_aetv_rec.accounting_event_id)
  LOOP
      i := i + 1;
      l_aelv_tbl_in(i).CODE_COMBINATION_ID         := dist_rec.code_combination_id;
      l_aelv_tbl_in(i).CURRENCY_CONVERSION_TYPE    := dist_rec.currency_conversion_type;

      l_line_number                                := l_line_number + 1;
      l_aelv_tbl_in(i).AE_LINE_NUMBER              := l_line_number;

      l_aelv_tbl_in(i).AE_HEADER_ID                := l_ae_header_id;

      l_aelv_tbl_in(i).AE_LINE_TYPE_CODE           := dist_rec.ae_line_type;
      l_aelv_tbl_in(i).SOURCE_TABLE                := dist_rec.source_table;
      l_aelv_tbl_in(i).SOURCE_ID                   := dist_rec.source_id;
      l_aelv_tbl_in(i).CURRENCY_CODE               := dist_rec.currency_code;
      l_aelv_tbl_in(i).CURRENCY_CONVERSION_DATE    := dist_rec.currency_conversion_date;
      l_aelv_tbl_in(i).CURRENCY_CONVERSION_RATE    := dist_rec.currency_conversion_rate;

      IF (dist_rec.CR_DR_FLAG = 'D') THEN
         l_aelv_tbl_in(i).ENTERED_DR               := dist_rec.amount;
         l_aelv_tbl_in(i).ACCOUNTED_DR             := dist_rec.accounted_amount;

      END IF;

      IF (dist_rec.CR_DR_FLAG = 'C') THEN
          l_aelv_tbl_in(i).ENTERED_CR              := dist_rec.amount;
          l_aelv_tbl_in(i).ACCOUNTED_CR            := dist_rec.accounted_amount;

      END IF;

      l_aelv_tbl_in(i).REFERENCE1                        := dist_rec.template_id;
      l_aelv_tbl_in(i).REFERENCE2                        := dist_rec.ID;

-- Added by santonyr bug 3925719

      IF dist_rec.source_table = 'OKL_TXL_CNTRCT_LNS' THEN
	FOR trx_cntrct_rec IN trx_cntrct_csr (dist_rec.source_id) LOOP
	  l_aelv_tbl_in(i).REFERENCE3              := trx_cntrct_rec.try_id;
	END LOOP;
      ELSIF dist_rec.source_table = 'OKL_TXL_ASSETS_B' THEN
	FOR trx_asset_rec IN trx_asset_csr (dist_rec.source_id) LOOP
	  l_aelv_tbl_in(i).REFERENCE3              := trx_asset_rec.try_id;
	END LOOP;
      END IF;

--    l_aelv_tbl_in(i).REFERENCE3                        := NULL;

      l_aelv_tbl_in(i).REFERENCE4                        := NULL;
      l_aelv_tbl_in(i).REFERENCE5                        := NULL;
      l_aelv_tbl_in(i).REFERENCE6                        := NULL;
      l_aelv_tbl_in(i).REFERENCE7                        := NULL;
      l_aelv_tbl_in(i).REFERENCE8                        := NULL;
      l_aelv_tbl_in(i).REFERENCE9                        := NULL;
      l_aelv_tbl_in(i).REFERENCE10                       := NULL;
      l_aelv_tbl_in(i).DESCRIPTION                       := l_description;
      l_aelv_tbl_in(i).THIRD_PARTY_ID                    := NULL;
      l_aelv_tbl_in(i).THIRD_PARTY_SUB_ID                := NULL;
      l_aelv_tbl_in(i).STAT_AMOUNT                       := NULL;
      l_aelv_tbl_in(i).USSGL_TRANSACTION_CODE            := NULL;
      l_aelv_tbl_in(i).SUBLEDGER_DOC_SEQUENCE_ID         := NULL;
      l_aelv_tbl_in(i).ACCOUNTING_ERROR_CODE             := NULL;
      l_aelv_tbl_in(i).GL_TRANSFER_ERROR_CODE            := NULL;
      l_aelv_tbl_in(i).GL_SL_LINK_ID                     := NULL;
      l_aelv_tbl_in(i).TAXABLE_ENTERED_DR                := NULL;
      l_aelv_tbl_in(i).TAXABLE_ENTERED_CR                := NULL;
      l_aelv_tbl_in(i).TAXABLE_ACCOUNTED_DR              := NULL;
      l_aelv_tbl_in(i).TAXABLE_ACCOUNTED_CR              := NULL;
      l_aelv_tbl_in(i).APPLIED_FROM_TRX_HDR_TABLE        := NULL;
      l_aelv_tbl_in(i).APPLIED_FROM_TRX_HDR_ID           := NULL;
      l_aelv_tbl_in(i).APPLIED_TO_TRX_HDR_TABLE          := NULL;
      l_aelv_tbl_in(i).APPLIED_TO_TRX_HDR_ID             := NULL;
      l_aelv_tbl_in(i).TAX_LINK_ID                       := NULL;
      l_aelv_tbl_in(i).ACCOUNT_OVERLAY_SOURCE_ID         := NULL;
      l_aelv_tbl_in(i).SUBLEDGER_DOC_SEQUENCE_VALUE      := NULL;
      l_aelv_tbl_in(i).TAX_CODE_ID                       := NULL;

      l_ccid_valid := Okl_Accounting_Util.validate_gl_ccid(dist_rec.code_combination_id);

      IF (l_ccid_valid = Okl_Api.G_FALSE) THEN
         l_aelv_tbl_in(i).accounting_error_code := 'INVALID_ACCOUNT';
--         l_aelv_tbl_in(i).code_combination_id   := -1;
         x_ret_message := 'INVALID ACCOUNT';
         Fnd_File.PUT_LINE(Fnd_File.LOG, 'A CCID is Invalid for Transaction Number '
                                            || l_trx_number);
      END IF;

  END LOOP;


-- Start of wraper code generated automatically by Debug code generator for OKL_ACCT_EVENT_PUB.create_acct_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRAECB.pls call OKL_ACCT_EVENT_PUB.create_acct_lines ');
    END;
  END IF;
  Okl_Acct_Event_Pub.create_acct_lines(p_api_version      => p_api_version,
                                       p_init_msg_list    => p_init_msg_list,
                                       x_return_status    => l_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data,
                                       p_aelv_tbl         => l_aelv_tbl_in,
                                       x_aelv_tbl         => l_aelv_tbl_out);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRAECB.pls call OKL_ACCT_EVENT_PUB.create_acct_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCT_EVENT_PUB.create_acct_lines

  l_total_lines := l_aelv_tbl_in.COUNT;

  x_return_status := l_return_status;
  x_total_lines   := l_total_lines;


EXCEPTION

  WHEN OTHERS THEN

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END CREATE_AE_LINES;



PROCEDURE VALIDATE_DR_CR(p_aetv_rec       IN   aetv_rec_type,
                         x_ret_message    OUT NOCOPY  VARCHAR2,
                         x_return_status  OUT  NOCOPY VARCHAR2)

IS

 CURSOR sum_csr(v_event_id NUMBER) IS
 SELECT ael.Accounted_Dr Accounted_Dr,
        ael.Accounted_Cr Accounted_Cr
 FROM OKL_AE_LINES AEL,
      OKL_AE_HEADERS AEH
 WHERE AEH.accounting_event_ID = v_event_id
 AND   AEL.ae_header_id = AEH.ae_header_id ;

 l_accounted_dr_total NUMBER := 0;
 l_accounted_cr_total NUMBER := 0;


BEGIN

 x_return_status := Okl_Api.G_RET_STS_SUCCESS;

 FOR sum_rec IN sum_csr(p_aetv_rec.Accounting_event_id)
 LOOP

   l_accounted_dr_total := l_accounted_dr_total + NVL(sum_rec.accounted_dr,0);
   l_accounted_cr_total := l_accounted_cr_total + NVL(sum_rec.accounted_cr,0);

 END LOOP;

 IF (l_accounted_dr_total <> l_accounted_cr_total) THEN
    x_ret_message := 'FAILED';

 ELSE
    x_ret_message := 'PASSED';


 END IF;


EXCEPTION

  WHEN OTHERS THEN x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END VALIDATE_DR_CR;




PROCEDURE CLEAN_EVENT_DIST

IS

  CURSOR dist_csr IS
  SELECT ID
  FROM OKL_TRNS_ACC_DSTRS
  WHERE POSTED_YN = 'S';

  dist_rec dist_csr%ROWTYPE;

  CURSOR aet_csr IS
  SELECT accounting_event_id
  FROM OKL_ACCOUNTING_EVENTS
  WHERE event_status_code = 'CREATED';

  aet_rec aet_csr%ROWTYPE;

  l_tabv_tbl TABV_TBL_TYPE;
  x_tabv_tbl TABV_TBL_TYPE;
  l_aetv_tbl Okl_Acct_Event_Pub.AETV_TBL_TYPE;
  i    NUMBER := 0;
  p_api_version  NUMBER := 1.0;
  p_init_msg_list  VARCHAR2(1) := Okl_Api.G_FALSE;
  l_return_status VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  x_msg_count     NUMBER;
  x_msg_data      VARCHAR2(2000);

BEGIN

  FOR dist_rec IN dist_csr
  LOOP
     i := i + 1;
     l_tabv_tbl(i).ID        := dist_rec.ID;
     l_tabv_tbl(i).posted_yn := 'N';
     l_tabv_tbl(i).aet_id    := NULL;
  END LOOP;

  IF (l_tabv_tbl.COUNT > 0) THEN

     Okl_Trns_Acc_Dstrs_Pub.update_trns_acc_dstrs(
                                   p_api_version                 => p_api_version,
                                   p_init_msg_list               => p_init_msg_list,
                                   x_return_status               => l_return_status,
                                   x_msg_count                   => x_msg_count,
                                   x_msg_data                    => x_msg_data,
                                   p_tabv_tbl                    => l_tabv_tbl,
                                   x_tabv_tbl                    => x_tabv_tbl);

  END IF;  ----- of l_tabv_tbl.COUNT > 0 check

  i := 0;

  FOR aet_rec IN aet_csr
  LOOP
     i := i + 1;
     l_aetv_tbl(i).accounting_event_id := aet_rec.accounting_event_id;
  END LOOP;

  IF (l_aetv_tbl.COUNT > 0) THEN

     Okl_Acct_Event_Pub.delete_acct_event(p_api_version          => p_api_version,
                                          p_init_msg_list        => p_init_msg_list,
                                          x_return_status        => l_return_status,
                                          x_msg_count            => x_msg_count,
                                          x_msg_data             => x_msg_data,
                                          p_aetv_tbl             => l_aetv_tbl);

  END IF;  ---- of l_aetv_tbl.COUNT > 0 check

END CLEAN_EVENT_DIST;



FUNCTION  GET_PROPER_LENGTH(p_input_data          IN   VARCHAR2,
                            p_input_length        IN   NUMBER,
				    p_input_type          IN   VARCHAR2)
RETURN VARCHAR2

IS

x_return_data VARCHAR2(1000);

BEGIN

IF (p_input_type = 'TITLE') THEN
    IF (p_input_data IS NOT NULL) THEN
     x_return_data := RPAD(SUBSTR(LTRIM(RTRIM(p_input_data)),1,p_input_length),p_input_length,' ');
    ELSE
     x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
ELSE
    IF (p_input_data IS NOT NULL) THEN
         IF (LENGTH(p_input_data) > p_input_length) THEN
             x_return_data := RPAD('*',p_input_length,'*');
         ELSE
             x_return_data := RPAD(p_input_data,p_input_length,' ');
         END IF;
    ELSE
         x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
END IF;

RETURN x_return_data;

END GET_PROPER_LENGTH;


PROCEDURE CREATE_REPORT(p_start_date VARCHAR2,
                        p_end_Date   VARCHAR2,
                        --gboomina..added param for bug#4648697
                        p_rpt_format VARCHAR2)


IS

  l_chart_of_accounts_id  NUMBER := Okl_Accounting_Util.get_chart_of_accounts_id;
  l_set_of_books_name     VARCHAR2(300);
  l_structure_name        VARCHAR2(300);
  l_org_name              VARCHAR2(240);
  l_org_id                NUMBER := MO_GLOBAL.GET_CURRENT_ORG_ID();
  l_entered_dr            VARCHAR2(40);
  l_entered_cr            VARCHAR2(40);
  l_line_number           NUMBER;
  l_error_ae_lines        NUMBER;
  l_error_ae_headers      NUMBER;
  l_request_id            NUMBER := Fnd_Global.CONC_REQUEST_ID;


--added for reporting purposes

  l_temp_acc_date             DATE;
  l_temp_period_name          VARCHAR2(30);
  l_temp_start_date           DATE;
  l_temp_end_date             DATE;
  l_line_length               NUMBER := 120;
  l_total_offset              NUMBER := 88;
  i NUMBER := 0;
  l_start_date      DATE;
  l_end_date        DATE;



-- Cursor to fetch the organization namd for a org id.

   CURSOR org_csr (l_org_id IN NUMBER) IS
   SELECT name
   FROM   hr_operating_units
   WHERE  organization_id = l_org_id;

--- Cursor to select the error Headers

  CURSOR ae_err_hdr_csr (p_request_id NUMBER)  IS
  SELECT COUNT(*) err_ae_headers
  FROM 	 okl_ae_headers ah
  WHERE  ah.request_id = p_request_id AND
    	 ah.accounting_error_code IS NOT NULL;


   CURSOR ae_err_line_csr (p_request_id NUMBER)  IS
   SELECT COUNT(*) err_ae_lines
   FROM   okl_ae_lines ael
   WHERE  ael.request_id = p_request_id AND
   	  ael.accounting_error_code IS NOT NULL;



--Cursor to fetch records of sucessful transactions

/*
  CURSOR proc_dst_csr(p_request_id NUMBER,
                      p_category VARCHAR2,
                      p_try_id   NUMBER,
                      p_currency_code VARCHAR2) IS
  SELECT ael.source_table                             	 source_table,
         ael.source_id                                       source_id,
         ael.ae_line_number                                  line_number,
         aeh.accounting_date                                 accounting_date,
         DECODE(ael.accounted_cr,NULL,'DR','CR')   		 dr_cr_flag,
         DECODE(ael.accounted_dr,NULL,ael.accounted_cr, ael.accounted_dr) accounted_amount,
         Okl_Accounting_Util.get_concat_segments(ael.code_combination_id) account,
         ael.currency_code                                  currency_code,
	   aeh.ae_category                                    ae_category
  FROM okl_ae_lines ael,
       okl_ae_headers aeh,
       okl_txl_cntrct_lns tcl,
       okl_trx_contracts tcn
  WHERE aeh.ae_header_id = ael.ae_header_id
  AND   aeh.accounting_error_code IS NULL
  AND   ael.accounting_error_code IS NULL
  AND   ael.request_id  = p_request_id
  AND   aeh.ae_category = p_category
  AND   ael.currency_code = p_currency_code
  AND   tcl.id = ael.source_id
  AND   tcl.tcn_id = tcn.id
  AND   tcn.try_id = p_try_id
  ORDER BY ael.source_id;


  CURSOR ae_category_csr(p_request_id NUMBER) IS
  SELECT SUM(accounted_dr) total_dr,
	   SUM(accounted_cr) total_cr,
         try.id  try_id,
         try.name  try_name,
         aeh.ae_category ae_category,
         ael.currency_code
  FROM  okl_Ae_headers aeh,
        okl_ae_lines ael,
        okl_trx_types_v try,
        okl_txl_cntrct_lns tcl,
        okl_trx_contracts tcn
  WHERE aeh.ae_header_id=ael.ae_header_id
  AND   aeh.accounting_error_code IS NULL
  AND   ael.accounting_error_code IS NULL
  AND   aeh.request_id = p_request_id
  AND   ael.source_id  = tcl.id
  AND   tcl.tcn_id = tcn.id
  AND   tcn.try_id = try.id
  GROUP BY aeh.ae_category,
           try.id,
           try.name,
           ael.currency_code
  UNION
  SELECT  SUM(accounted_dr) total_dr,
	   SUM(accounted_cr) total_cr,
         try.id try_id,
         try.name  try_name,
         aeh.ae_category ae_category,
         ael.currency_code
  FROM  okl_Ae_headers  aeh,
        okl_ae_lines     ael,
        okl_trx_types_v try,
        okl_trx_assets   tas,
        okl_txl_assets_b tal
  WHERE aeh.ae_header_id=ael.ae_header_id
  AND   aeh.accounting_error_code IS NULL
  AND   ael.accounting_error_code IS NULL
  AND   aeh.request_id = p_request_id
  AND   ael.source_id  = tal.id
  AND   tal.tas_id = tas.id
  AND   tas.try_id = try.id
  GROUP BY aeh.ae_category,
           try.id,
           try.name,
           ael.currency_code;

*/

CURSOR proc_dst_csr(p_request_id NUMBER,
                      p_category VARCHAR2,
                      p_try_id   NUMBER,
                      p_currency_code VARCHAR2) IS
SELECT
  ael.source_table,
  ael.source_id,
  ael.ae_line_number,
  aeh.accounting_date,
  DECODE(ael.accounted_cr,NULL,'DR','CR') dr_cr_flag,
  DECODE(ael.accounted_dr, NULL,ael.accounted_cr, ael.accounted_dr) accounted_amount,
  Okl_Accounting_Util.get_concat_segments(ael.code_combination_id) account,
  ael.currency_code,
  aeh.ae_category
FROM
  okl_ae_lines ael,
  okl_ae_headers aeh
WHERE
  ael.request_id  = p_request_id AND
  ael.currency_code = p_currency_code AND
  ael.reference3 = p_try_id AND
  ael.accounting_error_code IS NULL AND
  ael.ae_header_id   = aeh.ae_header_id  AND
  aeh.ae_category = p_category AND
  aeh.accounting_error_code IS NULL
ORDER BY ael.source_id;


CURSOR ae_category_csr(p_request_id NUMBER) IS
SELECT
  SUM(accounted_dr) total_dr,
  SUM(accounted_cr) total_cr,
  try.id  try_id,
  try.name  try_name,
  aeh.ae_category ae_category,
  ael.currency_code
FROM
  okl_Ae_headers aeh,
  okl_ae_lines ael,
  okl_trx_types_v try
WHERE
  aeh.request_id = p_request_id    AND
  aeh.accounting_error_code IS NULL     AND
  aeh.ae_header_id=ael.ae_header_id    AND
  ael.accounting_error_code IS NULL    AND
  ael.reference3  = try.id
GROUP BY aeh.ae_category, try.id, try.name, ael.currency_code;


ae_category_rec ae_category_csr%ROWTYPE;


CURSOR details_csr(p_source_id NUMBER)  IS
SELECT
  tcn.trx_number transaction_number,
  try.name transaction_type,
  khr.contract_number contract_number,
  tcl.line_number transaction_line_number,
  tcl.id source_id,
  tcl.currency_code currency_code,
  tcl.amount amount,
  tcn.date_transaction_occurred transaction_date
FROM
  okl_txl_cntrct_lns tcl,
  okl_trx_contracts tcn,
  okl_trx_types_v try,
  okc_k_headers_b khr
WHERE
  tcl.id = p_source_id     AND
  tcl.tcn_id =  tcn.id AND
  tcn.try_id = try.id AND
  tcn.khr_id = khr.id
UNION ALL
SELECT
  TO_CHAR(tas.trans_number) transaction_number,
  try.name transaction_type,
  khr.contract_number contract_number,
  tal.line_number transaction_line_number,
  tal.id source_id,
  tal.currency_code currency_code,
  tal.original_cost amount,
  tas.date_trans_occurred transaction_date
FROM
  okl_txl_assets_b tal,
  okl_trx_assets tas,
  okl_trx_types_v try,
  okc_k_headers_b khr
WHERE
  tal.id = p_source_id AND
  tal.tas_id =   tas.id AND
  tas.try_id = try.id AND
  tal.dnz_khr_id = khr.id;


  details_rec details_csr%ROWTYPE;

-- Cursor to fetch the records that the error INVALID ACCOUNT

CURSOR invalid_acc_dst_csr(l_request_id NUMBER) IS
SELECT
  ael.source_table,
  ael.source_id,
  ael.ae_line_number,
  aeh.accounting_date,
  DECODE(ael.accounted_cr, NULL, 'DR',  'CR')   		 dr_cr_flag,
  DECODE(ael.accounted_dr,  NULL,  ael.accounted_cr,  ael.accounted_dr) accounted_amount,
  Okl_Accounting_Util.get_concat_segments(ael.code_combination_id) account,
  ael.currency_code
FROM
  okl_ae_lines ael,
  okl_ae_headers aeh
WHERE
  ael.request_id            =  l_request_id     AND
  ael.accounting_error_code = 'INVALID_ACCOUNT'    AND
  ael.ae_header_id          =  aeh.ae_header_id      ORDER BY ael.source_id;

  invalid_acc_dst_rec invalid_acc_dst_csr%ROWTYPE;

--Cursor to fetch the records that have the error DEBIT NOT EQUAL TO CREDIT

CURSOR dr_cr_unequal_dst_csr(l_request_id NUMBER) IS
SELECT
  ael.source_table                                 source_table,
  ael.source_id                                    source_id,
  ael.ae_line_number                               line_number,
  aeh.accounting_date 				          accounting_date,
  DECODE(ael.accounted_cr,   NULL,   'DR',   'CR')   		 dr_cr_flag,
  DECODE(ael.accounted_dr,   NULL,   ael.accounted_cr,   ael.accounted_dr) accounted_amount,
  Okl_Accounting_Util.get_concat_segments(ael.code_combination_id) account,
  ael.currency_code                                currency_code
FROM
  okl_ae_headers aeh,
  okl_ae_lines ael
WHERE
  aeh.request_id = l_request_id    AND
  aeh.accounting_error_code = 'DEBIT_NOT_EQUAL_TO_CREDIT'       AND
  aeh.ae_header_id = ael.ae_header_id     ORDER BY ael.source_id;

  dr_cr_unequal_dst_rec   dr_cr_unequal_dst_csr%ROWTYPE;



BEGIN
-- santonyr

  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', 47 , ' ' ) ||
            Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCT_LEASE_MANAGEMENT')
              || RPAD(' ', 48 , ' ' ));

  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', 42 , ' ' ) ||  Okl_Accounting_Util.get_message_token
                           ('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCT_PROCESS_REPORT') || RPAD(' ', 43 , ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ',42 , ' ' ) || '-----------------------------------' || RPAD(' ', 43 , ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));

-- Derive the org name and print it on the report.

  l_set_of_books_name := Okl_Accounting_Util.get_set_of_books_name (Okl_Accounting_Util.get_set_of_books_id);

  FOR org_rec IN org_csr (l_org_id)
  LOOP
    l_org_name := org_rec.name;
  END LOOP;

  FOR ae_err_hdr_rec IN ae_err_hdr_csr (l_request_id) LOOP
    l_error_ae_headers := ae_err_hdr_rec.ERR_AE_HEADERS;
  END LOOP;

  FOR ae_err_line_rec IN ae_err_line_csr (l_request_id) LOOP
    l_error_ae_lines := ae_err_line_rec.ERR_AE_LINES;
  END LOOP;


  i := 0;


  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_SET_OF_BOOKS') ||': '||
             RPAD(SUBSTR(l_set_of_books_name, 1, 60), 60, ' ') || LPAD(' ', 18 , ' ' )
	|| Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_RUN_DATE')  ||':' ||
          SUBSTR(TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI'), 1, 27));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_OPERUNIT')
                     ||':'|| SUBSTR(l_org_name, 1, 30) );

  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS',
         'OKL_START_DATE'), 25 , ' ' ) || RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS',
                                                                  'OKL_END_DATE'), 25 , ' ' ) ||
  RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_STATUS'), 30 , ' ' ) ||
  LPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_AE_HEADERS'), 20 , ' ' ) ||
  LPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_AE_LINES'), 20 , ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length, '-' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, GET_PROPER_LENGTH(p_start_date,25,'TITLE') || GET_PROPER_LENGTH(p_end_date, 25 ,'TITLE' ) ||
   RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_PROCESSED_ENTRIES'), 30 , ' ' ) ||
  LPAD(l_total_headers, 20 , ' ' ) || LPAD(l_total_lines, 20 , ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', 25 , ' ' ) || RPAD(' ', 25 , ' ' ) ||
        RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNTED_SUCCESS'), 30 , ' ' ) ||
	LPAD((l_total_headers - l_error_ae_headers), 20 , ' ' ) || LPAD((l_total_lines - l_error_ae_lines), 20 , ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', 25 , ' ' ) || RPAD(' ', 25 , ' ' ) ||
  RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNTED_ERROR'), 30 , ' ' ) ||
	LPAD((l_error_ae_headers), 20 , ' ' ) || LPAD((l_error_ae_lines), 20 , ' ' ));


  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('=', l_line_length , '=' ));
  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));

  header_report_rec.transaction_date		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_TRANSACTION'),
           l_transaction_date_len, 'TITLE');
  header_report_rec.contract_number		 := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_CONTRACT'),
           l_contract_number_len, 'TITLE');
  header_report_rec.transaction_number	 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_TRANSACTION'),
           l_transaction_number_len, 'TITLE');
  header_report_rec.transaction_line_number := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACC_LINE'),
           l_transaction_line_number_len,'TITLE');
  header_report_rec.accounting_date         := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNT_ING'),
           l_Accounting_date_len, 'TITLE');
  header_report_rec.dr_cr_flag		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_DR_CR_FLAG'),
           l_dr_cr_flag_len, 'TITLE');
  header_report_rec.accounted_Amount		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNTED'),
           l_accounted_amount_len, 'TITLE');
/*  header_report_rec.account			 := GET_PROPER_LENGTH(
           okl_accounting_util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNT'),
           l_account_len, 'TITLE');*/
  header_report_rec.account			 :=
              Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNT');

  header_report_rec.currency			 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_CURRENCY'),
            l_currency_len, 'TITLE');

  header_report_rec2.transaction_date		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_DATE'),
           l_transaction_date_len, 'TITLE');
  header_report_rec2.contract_number		 := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NUMBER'),
           l_contract_number_len, 'TITLE');
  header_report_rec2.transaction_number	 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NUMBER'),
           l_transaction_number_len, 'TITLE');
  header_report_rec2.transaction_line_number := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NUMBER'),
           l_transaction_line_number_len,'TITLE');
  header_report_rec2.accounting_date         := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_DATE'),
           l_Accounting_date_len, 'TITLE');

  header_report_rec2.dr_cr_flag		 := GET_PROPER_LENGTH(NULL,l_dr_cr_flag_len, 'TITLE');

  header_report_rec2.accounted_Amount		 := GET_PROPER_LENGTH(
         Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_AMOUNT'),
        l_accounted_amount_len, 'TITLE');
--  header_report_rec2.account			 := GET_PROPER_LENGTH(NULL,  l_account_len, 'TITLE');
  header_report_rec2.currency			 := GET_PROPER_LENGTH(NULL,  l_currency_len, 'TITLE');


 ---  Error Section Begins ------------------------

 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));
 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ERROR_LOG'), l_line_length , ' ' ));
 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('---------', l_line_length , ' ' ));
 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));


 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_lookup_meaning('OKL_ACCOUNTING_ERROR_CODE',
                                                   'DEBIT_NOT_EQUAL_TO_CREDIT') , l_line_length, ' ' ));
 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('---------------------------', l_line_length , ' ' ));
 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));

-- Print the Header, same as the processed one.

 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
                        header_report_rec.transaction_date||
				header_report_rec.contract_number||
				header_report_rec.transaction_number ||
				header_report_rec.transaction_line_number ||
				header_report_rec.accounting_date ||
				header_report_rec.dr_cr_flag ||
				header_report_rec.accounted_amount ||
                -- Modified by kthiruva for Bug 3861943
				--header_report_rec.account ||
				header_report_rec.currency);

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,header_report_rec2.transaction_date||
               				 header_report_rec2.contract_number||
				             header_report_rec2.transaction_number ||
				             header_report_rec2.transaction_line_number ||
				             header_report_rec2.accounting_date ||
				             header_report_rec2.dr_cr_flag ||
				             header_report_rec2.accounted_amount ||
                             -- Modified by kthiruva for Bug 3861943
				             --header_report_rec2.account ||
				             header_report_rec2.currency);




 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));

 OPEN  dr_cr_unequal_dst_csr(l_request_id);
 FETCH dr_cr_unequal_dst_csr INTO dr_cr_unequal_dst_rec;
 IF (dr_cr_unequal_dst_csr%NOTFOUND) THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
          Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NO_RECORDS'));
 ELSE
     NULL;
 END IF;

 CLOSE dr_cr_unequal_dst_csr;


 FOR dr_cr_unequal_dst_rec IN dr_cr_unequal_dst_csr(l_request_id)
 LOOP          -- For each record

     OPEN details_csr(dr_cr_unequal_dst_rec.source_id);
     FETCH details_csr INTO  details_rec;
     CLOSE details_csr;

     dr_cr_report_rec.transaction_date	:=
		 GET_PROPER_LENGTH(details_rec.transaction_date,l_transaction_date_len,'DATA');

     --Modified by kthiruva on 30-Nov-2004
     --Bug 3947025 - Start of Changes
     --To extract the First 25 characters of the Contract_Number
     dr_cr_report_rec.contract_number 	:=
		 RPAD(substr(details_rec.contract_number,1,l_contract_number_len),l_contract_number_len,' ');
     --Bug 3947025 - End of Changes
     dr_cr_report_rec.transaction_number	:=
 		 GET_PROPER_LENGTH(details_rec.transaction_number,l_transaction_number_len,'DATA');
     dr_cr_report_rec.transaction_line_number:=
		 GET_PROPER_LENGTH(details_rec.transaction_line_number,l_transaction_line_number_len,'DATA');
     dr_cr_report_rec.accounting_date	:=
		 GET_PROPER_LENGTH(dr_cr_unequal_dst_rec.accounting_date,l_accounting_date_len,'DATA');
     dr_cr_report_rec.dr_cr_flag		:=
		 GET_PROPER_LENGTH(dr_cr_unequal_dst_rec.dr_Cr_flag,l_dr_Cr_flag_len,'DATA');
     dr_cr_report_rec.accounted_amount	:=
		 GET_PROPER_LENGTH(Okl_Accounting_Util.format_amount(
                       dr_cr_unequal_dst_rec.accounted_amount, dr_cr_unequal_dst_rec.currency_code),
                          l_accounted_amount_len,'DATA');
     -- Modified by kthiruva for Bug 3861943
     /*
     dr_cr_report_rec.account			:=
		 GET_PROPER_LENGTH(dr_cr_unequal_dst_rec.account,l_account_len,'DATA');*/
     dr_cr_report_rec.account			:=  dr_cr_unequal_dst_rec.account;
     dr_cr_report_rec.currency        	:=
		 GET_PROPER_LENGTH(dr_cr_unequal_dst_rec.currency_code,l_currency_len,'DATA');


     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
					dr_cr_report_rec.transaction_date||
  					dr_cr_report_rec.contract_number ||
					dr_cr_report_rec.transaction_number ||
					dr_cr_report_rec.transaction_line_number||
					dr_cr_report_rec.accounting_date ||
					dr_cr_report_rec.dr_Cr_flag ||
				      dr_cr_report_rec.accounted_amount ||
					--dr_cr_report_rec.account ||
					dr_cr_report_rec.currency);

--Added by kthiruva for Bug 3861943
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,header_report_rec.account||':'||dr_cr_report_rec.account );


    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));


   END LOOP;

   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));

   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_lookup_meaning('OKL_ACCOUNTING_ERROR_CODE',
                                  'INVALID_ACCOUNT'), l_line_length, ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('---------------', l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));

---- Print the Header for Invalid Account, Same as before.


   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
                        header_report_rec.transaction_date||
				header_report_rec.contract_number||
				header_report_rec.transaction_number ||
				header_report_rec.transaction_line_number ||
				header_report_rec.accounting_date ||
				header_report_rec.dr_cr_flag ||
				header_report_rec.accounted_amount ||
                -- Modified by kthiruva for Bug 3861943
				--header_report_rec.account ||
				header_report_rec.currency);

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,header_report_rec2.transaction_date||
               				 header_report_rec2.contract_number||
				             header_report_rec2.transaction_number ||
				             header_report_rec2.transaction_line_number ||
				             header_report_rec2.accounting_date ||
				             header_report_rec2.dr_cr_flag ||
				             header_report_rec2.accounted_amount ||
                             -- Modified by kthiruva for Bug 3861943
				             --header_report_rec2.account ||
				             header_report_rec2.currency);


   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));

   OPEN invalid_acc_dst_csr(l_request_id);
   FETCH invalid_acc_dst_csr INTO invalid_acc_dst_rec;
   IF (invalid_Acc_dst_csr%NOTFOUND) THEN
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
          Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NO_RECORDS'));
   ELSE
       NULL;
   END IF;
   CLOSE invalid_acc_Dst_csr;


   FOR invalid_acc_dst_rec IN invalid_acc_dst_csr(l_request_id)
   LOOP  -- For each invalid Account record

      OPEN details_csr(invalid_acc_dst_rec.source_id) ;
      FETCH details_csr INTO details_rec;
      CLOSE details_csr;

      invalid_acc_report_rec.transaction_date
		:= GET_PROPER_LENGTH(details_rec.transaction_date, l_transaction_date_len, 'DATA');
    --Modified by kthiruva on 30-Nov-2004
    --Bug 3947025 - Start of Changes
    -- To extract the first 25 characters in the Contract Number
    invalid_acc_report_rec.contract_number
		:= RPAD(substr(details_rec.contract_number, 1 , l_contract_number_len),l_contract_number_len,' ');
     --Bug 3947025 - End of Changes
	invalid_acc_report_rec.transaction_number
		:= GET_PROPER_LENGTH(details_rec.transaction_number, l_transaction_number_len, 'DATA');
	invalid_acc_report_rec.transaction_line_number
		:= GET_PROPER_LENGTH(details_Rec.transaction_line_number, l_transaction_line_number_len, 'DATA');
	invalid_Acc_report_rec.accounting_date
		:= GET_PROPER_LENGTH(invalid_acc_dst_rec.accounting_date, l_accounting_date_len, 'DATA');
	invalid_acc_report_rec.dr_Cr_Flag
		:= GET_PROPER_LENGTH(invalid_acc_dst_rec.dr_Cr_flag, l_dr_Cr_flag_len, 'DATA');
      invalid_acc_report_rec.accounted_amount
		:= GET_PROPER_LENGTH(Okl_Accounting_Util.format_amount(invalid_acc_dst_rec.accounted_amount,
                  invalid_Acc_dst_rec.currency_code), l_accounted_amount_len, 'DATA');
   -- Modified by kthiruva for Bug 3861943
	/*
    invalid_acc_report_rec.account
		:= GET_PROPER_LENGTH(invalid_acc_dst_rec.account, l_account_len, 'DATA');*/
    invalid_acc_report_rec.account
		:= invalid_acc_dst_rec.account;
	invalid_acc_report_rec.currency
		:= GET_PROPER_LENGTH(invalid_acc_dst_rec.currency_code, l_currency_len, 'DATA');


      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
		invalid_Acc_report_rec.transaction_date||
  		invalid_acc_report_rec.contract_number ||
		invalid_Acc_report_rec.transaction_number ||
		invalid_acc_report_rec.transaction_line_number||
		invalid_acc_report_rec.accounting_date ||
		invalid_acc_report_rec.dr_cr_flag ||
		invalid_acc_report_rec.accounted_amount ||
        -- Modified by kthiruva for Bug 3861943
		--invalid_acc_report_rec.account ||
		invalid_acc_report_rec.currency);

-- Added by kthiruva for Bug 3861943
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,header_report_rec.account||':'||invalid_acc_report_rec.account);

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));

   END LOOP;

   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));

   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS',
				'OKL_NON_PROCESSED_ENTRIES'), l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('---------------------', l_line_length , ' ' ));
   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));

--Assigning the headers for non-processed entries


   header_err_report_rec.transaction_date		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_TRANSACTION'),
           l_transaction_date_len, 'TITLE');
   header_err_report_rec.contract_number		 := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_CONTRACT'),
           l_contract_number_len, 'TITLE');
   header_err_report_rec.transaction_number	 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_TRANSACTION'),
           l_transaction_number_len, 'TITLE');
   header_err_report_rec.transaction_line_number := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACC_LINE'),
           l_transaction_line_number_len,'TITLE');
   header_err_report_rec.accounting_date         := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNT_ING'),
           l_Accounting_date_len, 'TITLE');
   header_err_report_rec.accounting_period		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_ACCOUNT_ING'),
           l_accounting_period_len, 'TITLE');
   header_err_report_rec.amount		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_AMOUNT'),
           l_amount_len, 'TITLE');
   header_err_report_rec.currency			 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_CURRENCY'),
            l_currency_len, 'TITLE');


   header_err_report_rec2.transaction_date		 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_DATE'),
           l_transaction_date_len, 'TITLE');
   header_err_report_rec2.contract_number		 := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NUMBER'),
           l_contract_number_len, 'TITLE');
   header_err_report_rec2.transaction_number	 := GET_PROPER_LENGTH(
           Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NUMBER'),
           l_transaction_number_len, 'TITLE');
   header_err_report_rec2.transaction_line_number := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NUMBER'),
           l_transaction_line_number_len,'TITLE');
   header_err_report_rec2.accounting_date         := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_DATE'),
           l_Accounting_date_len, 'TITLE');
   header_err_report_rec2.accounting_period		 := GET_PROPER_LENGTH(
	     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_PERIOD'),
            l_accounting_period_len, 'TITLE');
   header_err_report_rec2.amount		 := GET_PROPER_LENGTH(NULL,l_amount_len, 'TITLE');
   header_err_report_rec2.currency			 := GET_PROPER_LENGTH(NULL,l_currency_len, 'TITLE');


   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
				header_err_report_rec.transaction_date||
				header_err_report_rec.contract_number||
				header_err_report_rec.transaction_number ||
				header_err_report_rec.transaction_line_number ||
				header_err_report_rec.accounting_date ||
				header_err_report_rec.accounting_period ||
				header_err_report_rec.amount||
				header_err_report_rec.currency);

   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
				header_err_report_rec2.transaction_date||
				header_err_report_rec2.contract_number||
				header_err_report_rec2.transaction_number ||
				header_err_report_rec2.transaction_line_number ||
				header_err_report_rec2.accounting_date ||
				header_err_report_rec2.accounting_period ||
				header_err_report_rec2.amount||
				header_err_report_rec2.currency);



   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));

   IF (l_trx_err_tbl.COUNT < 1) THEN

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
          Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NO_RECORDS'));
   END IF;

--- Process the non-processed Entries

   FOR i IN 1..l_trx_err_tbl.COUNT

   LOOP

   	    OPEN details_csr(l_trx_err_tbl(i).source_id);
          FETCH details_csr INTO details_rec;
          CLOSE details_csr;

          Okl_Accounting_Util.get_period_info(l_trx_err_tbl(i).gl_date,l_temp_period_name,l_temp_start_date,l_temp_end_date);

	    non_proc_report_rec.transaction_date
		:= GET_PROPER_LENGTH(details_rec.transaction_date, l_transaction_date_len, 'DATA');

        --Modified by kthiruva on 30-Nov-2004
        --Bug 3947025 - Start of Changes
        -- To extract the first 25 characters in the Contract Number
        non_proc_report_rec.contract_number
		:= RPAD(substr(details_rec.contract_number, 1, l_contract_number_len),l_contract_number_len,' ');
        --Bug 3947025 - End of Changes

	    non_proc_report_rec.transaction_number
		:= GET_PROPER_LENGTH(details_rec.transaction_number, l_transaction_number_len, 'DATA');

	    non_proc_report_rec.transaction_line_number
		:= GET_PROPER_LENGTH(details_rec.transaction_line_number, l_transaction_line_number_len, 'DATA');

	    non_proc_report_rec.accounting_date
		:= GET_PROPER_LENGTH(l_trx_err_tbl(i).gl_date, l_accounting_date_len, 'DATA');

	    non_proc_report_rec.accounting_period
		:= GET_PROPER_LENGTH(l_temp_period_name, l_accounting_period_len, 'DATA');

          non_proc_report_rec.amount
		:= GET_PROPER_LENGTH(Okl_Accounting_Util.format_amount(details_rec.amount, details_rec.currency_code)
, l_amount_len, 'DATA');

	    non_proc_report_rec.currency
		:= GET_PROPER_LENGTH(details_rec.currency_code, l_currency_len, 'DATA');

	    Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
					non_proc_report_rec.transaction_date          ||
					non_proc_report_rec.contract_number           ||
					non_proc_report_rec.transaction_number        ||
					non_proc_report_rec.transaction_line_number   ||
					non_proc_report_rec.accounting_date           ||
					non_proc_report_rec.accounting_period         ||
				      non_proc_report_rec.amount                    ||
					non_proc_report_rec.currency);


	   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));

   END LOOP;

   Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length, '-' ));
    Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));
	Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));

--gboomina..bug#4648697	..Added condition to print
--processed records only if rpt_format is ALL.
    IF (p_rpt_format = 'ALL') THEN

	  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length, ' ' ));
	  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_PROCESSED_ENTRIES'), l_line_length, ' ' ));
	  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-----------------', l_line_length, ' ' ));
	  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));



	  OPEN ae_category_csr(l_request_id);
	  FETCH ae_category_csr INTO ae_category_rec;
	  IF (ae_category_csr%NOTFOUND) THEN

	 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
				header_report_rec.transaction_date||
					header_report_rec.contract_number||
					header_report_rec.transaction_number ||
					header_report_rec.transaction_line_number ||
					header_report_rec.accounting_date ||
					header_report_rec.dr_cr_flag ||
					header_report_rec.accounted_amount ||
			-- Modified by kthiruva for Bug 3861943
					--header_report_rec.account ||
					header_report_rec.currency);

	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,header_report_rec2.transaction_date||
						 header_report_rec2.contract_number||
						     header_report_rec2.transaction_number ||
						     header_report_rec2.transaction_line_number ||
						     header_report_rec2.accounting_date ||
						     header_report_rec2.dr_cr_flag ||
						     header_report_rec2.accounted_amount ||
				     -- Modified by kthiruva for Bug 3861943
						     --header_report_rec2.account ||
						     header_report_rec2.currency);

	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
		  Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_NO_RECORDS'));
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));


	  END IF;

	  CLOSE ae_category_csr;


	  FOR ae_category_rec IN ae_category_csr(l_request_id)

	  LOOP  -- For each journal category

	     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS',
			    'OKL_JOURNAL_CATEGORY') || ' : ' || ae_category_rec.ae_category || '     ' ||
						     Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS',
			    'OKL_TRANSACTION_TYPE') ||' : ' || ae_category_rec.try_name , l_line_length ,' '));

	     Fnd_File.PUT_LINE(Fnd_File.OUTPUT,RPAD(' ',l_line_length,' '));

	 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
				header_report_rec.transaction_date||
					header_report_rec.contract_number||
					header_report_rec.transaction_number ||
					header_report_rec.transaction_line_number ||
					header_report_rec.accounting_date ||
					header_report_rec.dr_cr_flag ||
					header_report_rec.accounted_amount ||
			-- Modified by kthiruva for Bug 3861943
					--header_report_rec.account ||
					header_report_rec.currency);

	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT,header_report_rec2.transaction_date||
						 header_report_rec2.contract_number||
						     header_report_rec2.transaction_number ||
						     header_report_rec2.transaction_line_number ||
						     header_report_rec2.accounting_date ||
						     header_report_rec2.dr_cr_flag ||
						     header_report_rec2.accounted_amount ||
				     -- Modified by kthiruva for Bug 3861943
						     --header_report_rec2.account ||
						     header_report_rec2.currency);



	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));

	      FOR proc_dst_rec IN proc_dst_csr(l_request_id, ae_category_rec.ae_category,
							     ae_category_rec.try_id,
							     ae_category_rec.currency_code)

	      LOOP

		  OPEN details_csr(proc_dst_rec.source_id) ;
		  FETCH details_csr INTO details_rec;
		  CLOSE details_csr;

		  proc_report_rec.transaction_date
				:= GET_PROPER_LENGTH(details_rec.transaction_date,l_transaction_date_len,'DATA');
		  -- Modified by kthiruva on 30-Nov-2004
		  -- Bug 3947025 - Start of Changes
		  -- To extract the first 25 characters in the Contract Number
		  proc_report_rec.contract_number
			  := RPAD(substr(details_rec.contract_number,1, l_contract_number_len),l_contract_number_len,' ');
		  -- Bug 3947025 - End of Changes
		  proc_report_rec.transaction_number
			  := GET_PROPER_LENGTH(details_rec.transaction_number,l_transaction_number_len,'DATA');
		  proc_report_rec.transaction_line_number
			  := GET_PROPER_LENGTH(details_rec.transaction_line_number,l_transaction_line_number_len,'DATA');
		  proc_report_rec.accounting_date
			  := GET_PROPER_LENGTH(proc_dst_rec.accounting_date,l_accounting_date_len,'DATA');
		  proc_report_rec.dr_cr_flag
			  := GET_PROPER_LENGTH(proc_dst_rec.dr_cr_flag,l_dr_cr_flag_len,'DATA');
		  proc_report_rec.accounted_amount
			  := GET_PROPER_LENGTH(Okl_Accounting_Util.format_amount(
					proc_dst_rec.accounted_amount,proc_dst_rec.currency_code),l_accounted_amount_len,'DATA');
		-- Modified by kthiruva for Bug 3861943
	       /* proc_report_rec.account
			  := GET_PROPER_LENGTH(proc_dst_rec.account,l_account_len,'DATA');*/
		  proc_report_rec.account
			  := proc_dst_rec.account;
		  proc_report_rec.currency
			  := GET_PROPER_LENGTH(proc_dst_rec.currency_code,l_currency_len,'DATA');


		  Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
						proc_report_rec.transaction_date ||
						proc_report_rec.contract_number ||
						proc_report_rec.transaction_number ||
						proc_report_rec.transaction_line_number ||
						proc_report_rec.accounting_date ||
						proc_report_rec.dr_cr_flag ||
					     proc_report_rec.accounted_amount ||
						--proc_report_rec.account ||
						proc_report_rec.currency);
	-- Added by kthiruva for Bug 3861943
		  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, header_report_rec.account || ' : '|| proc_report_rec.account );

		  Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));


	      END LOOP;  -- Of records for a particular journal category

	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_TOTAL')
	|| ' ' || Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_DEBIT'),l_total_offset,' ') ||
						GET_PROPER_LENGTH(Okl_Accounting_Util.format_amount(
		ae_category_rec.total_dr, ae_category_rec.currency_code), l_accounted_amount_len,'DATA') ||
				    ae_category_rec.currency_code);
	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_TOTAL')
	|| ' ' || Okl_Accounting_Util.get_message_token('OKL_LP_ACCOUNTING_PROCESS','OKL_CREDIT_AMT'),l_total_offset,' ') ||
						GET_PROPER_LENGTH(Okl_Accounting_Util.format_amount(
		     ae_category_rec.total_cr,ae_category_rec.currency_code), l_accounted_amount_len,'DATA')||
				    ae_category_rec.currency_code);

	      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD('-', l_line_length , '-' ));

	 END LOOP;   --- Of all journal categories

	 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
	 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));
	 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, RPAD(' ', l_line_length , ' ' ));


	 ---- Processed Section Complete Now--------------
    END IF; --gboomina..bug#4648697


END CREATE_REPORT;




-- This is the main procedure which runs all other procedures as required.
-- First it updates the distributions with 'S' and then calls the accounting event
-- routine to create accounting events. Then it selects all these accounting events
-- one by one and starts accounting them. At the end, it writes control statistics.
-- This program is obsolete due to uptake of Sub Ledger Architecture and is replaced
-- by the SLAs Create Accounting Program.

PROCEDURE DO_ACCOUNTING(p_errbuf           OUT NOCOPY  VARCHAR2,
                        p_retcode          OUT NOCOPY  NUMBER,
                        p_start_date       IN   VARCHAR2,
                        p_end_date         IN   VARCHAR2,
                        --gboomina..added param for bug#4648697
                        p_rpt_format       IN   VARCHAR2)

IS
BEGIN
--Stubbed out this procedure for Bug 5707866 (SLA Uptake of Accounting Entry Process concurrent program).
FND_MESSAGE.SET_NAME( application =>g_app_name , NAME => 'OKL_OBS_ACCT_ENTRY_PRG');
FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
END DO_ACCOUNTING;




PROCEDURE DO_ACCOUNTING_CON(p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            p_start_date          IN   DATE,
                            p_end_date            IN   DATE,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            x_request_id          OUT NOCOPY  NUMBER,
			    --gboomina..added param for bug#4648697
                            p_rpt_format          IN   VARCHAR2 DEFAULT 'ALL')
IS

 l_start_date  VARCHAR2(30);
 l_end_date    VARCHAR2(30);

BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_start_date := Fnd_Date.DATE_TO_CANONICAL(p_start_date);
    l_end_date   := Fnd_Date.DATE_TO_CANONICAL(p_end_date);

    x_request_id := Fnd_Request.SUBMIT_REQUEST
                    (application   => 'OKL',
                     program       => 'OKLSLACCT',
                     description   => 'Accounting Entry Process',
                     argument1     => l_start_date,
                     argument2     => l_end_date,
		     --gboomina..added param for bug#4648697
                     argument3     => p_rpt_format);


    IF x_request_id = 0 THEN

       Okc_Api.set_message(p_app_name => 'OKL',
                           p_msg_name => 'OKL_CONC_REQ_ERROR',
                           p_token1   => 'PROG_NAME',
                           p_token1_value => 'Accounting Entry Process',
                           p_token2   => 'REQUEST_ID',
                           p_token2_value => x_request_id);

       RAISE Okl_Api.g_exception_error;

    END IF;


EXCEPTION

  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    x_return_status := Okl_Api.G_RET_STS_ERROR;

END DO_ACCOUNTING_CON;


END Okl_Accounting_Process_Pvt;


/
