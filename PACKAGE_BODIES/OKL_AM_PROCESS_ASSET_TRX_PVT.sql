--------------------------------------------------------
--  DDL for Package Body OKL_AM_PROCESS_ASSET_TRX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_PROCESS_ASSET_TRX_PVT" AS
/* $Header: OKLRAMAB.pls 120.21.12010000.2 2008/08/28 14:20:00 rpillay ship $ */


-- Start of comments
--
-- Procedure Name  : process_transactions_wrap
-- Description     : This procedure is used to execute OKL_AM_PROCESS_ASSET_TRX_PVT
--                   as a concurrent program. It has all the input parameters for
--                   OKL_AM_PROCESS_ASSET_TRX_PVT and 2 standard OUT parameters - ERRBUF and RETCODE
-- Business Rules  :
-- Parameters      :  p_contract_id                  - contract id
--                    p_asset_id                     - asset_id
--                    p_kle_id                       - line id
--                    p_salvage_writedown_yn         - flag indicating whether to process salvage valye transactions
--
-- Version         : 1.0
-- History         : SECHAWLA 16-JAN-03 Bug # 2754280
--                      Changed the app name from OKL to OKC for g_unexpected_error
-- End of comments

  PROCEDURE process_transactions_wrap(   ERRBUF                  OUT 	NOCOPY VARCHAR2,
                                         RETCODE                 OUT    NOCOPY VARCHAR2 ,
                                         p_api_version           IN  	NUMBER,
           		 	                     p_init_msg_list         IN  	VARCHAR2,
                                         p_contract_id           IN     NUMBER   ,
                                         p_asset_id              IN     NUMBER   ,
                                         p_kle_id                IN     VARCHAR2 ,
                                         p_salvage_writedown_yn  IN     VARCHAR2
           			            )    IS


   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_api_name            CONSTANT VARCHAR2(30) := 'process_transactions_wrap';
   l_total_count         NUMBER;
   l_processed_count     NUMBER;
   l_error_count         NUMBER;
   lx_error_rec          OKL_API.error_rec_type;
   l_msg_idx             INTEGER := FND_MSG_PUB.G_FIRST;

   BEGIN

                         process_transactions(
                                p_api_version           => p_api_version,
           			            p_init_msg_list         => p_init_msg_list ,
           			            x_return_status         => l_return_status,
           			            x_msg_count             => l_msg_count,
           			            x_msg_data              => l_msg_data,
				                p_contract_id    	    => p_contract_id ,
                                p_asset_id              => p_asset_id,
                                p_kle_id                => TO_NUMBER(p_kle_id),
                                p_salvage_writedown_yn  => p_salvage_writedown_yn,
                                x_total_count           => l_total_count,
                                x_processed_count       => l_processed_count,
                                x_error_count           => l_error_count);


                        -- Add couple of blank lines
                         fnd_file.new_line(fnd_file.log,2);
                         fnd_file.new_line(fnd_file.output,2);

                        -- Get the messages in the log
                        LOOP

                            fnd_msg_pub.get(
                            p_msg_index     => l_msg_idx,
                            p_encoded       => FND_API.G_FALSE,
                            p_data          => lx_error_rec.msg_data,
                            p_msg_index_out => lx_error_rec.msg_count);

                            IF (lx_error_rec.msg_count IS NOT NULL) THEN

                                fnd_file.put_line(fnd_file.log,  lx_error_rec.msg_data);
                                fnd_file.put_line(fnd_file.output,  lx_error_rec.msg_data);

                            END IF;

                            EXIT WHEN ((lx_error_rec.msg_count = FND_MSG_PUB.COUNT_MSG)
                                    OR (lx_error_rec.msg_count IS NULL));

                            l_msg_idx := FND_MSG_PUB.G_NEXT;
                        END LOOP;


                        fnd_file.new_line(fnd_file.log,2);
                        fnd_file.new_line(fnd_file.output,2);

                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                           fnd_file.put_line(fnd_file.log, 'FA ADJUSTMENTS Failed, None of the transactions got processed');
                           fnd_file.put_line(fnd_file.output, 'FA ADJUSTMENTS Failed, None of the transactions got processed');
                        END IF;

                        IF l_total_count = 0 THEN
                            fnd_file.put_line(fnd_file.log, 'There were no Asset Management transactions to process.');
                            fnd_file.put_line(fnd_file.output,'There were no Asset Management transactions to process.');
                        ELSE

                            fnd_file.put_line(fnd_file.log, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.log, 'Transactions Failed : '||l_error_count);

                            fnd_file.put_line(fnd_file.output, 'Total Transactions : '||l_total_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Processed Successfully : '||l_processed_count);
                            fnd_file.put_line(fnd_file.output, 'Transactions Failed : '||l_error_count);

                        END IF;


       EXCEPTION
           WHEN OTHERS THEN
                -- unexpected error
                -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
                OKL_API.set_message(p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);

 END process_transactions_wrap;

   -- Start of comments
--
-- Procedure Name  : process_transactions
-- Description     : This procedure is used to process amortization(AMT), Evergreen(AED) and
--                   Salvage Value writedown(FSC) transactions. By default this procedure
--                   will process only AMT and AED transactions. However, if  the
--                   parameter p_salvage_writedown_yn is set to 'Y', it will process
--                   salvage value writedown transactions as well in Fixed Assets
-- Business Rules  :
-- Parameters      :  p_contract_id                  - contract id
--                    p_asset_id                     - aseet_id
--                    p_kle_id                       - line id
--                    p_salvage_writedown_yn         - flag indicating whether to process salvage valye transactions
--                    x_transaction_status           - reflects the overall status of all transactions
-- Version         : 1.0
-- History         : SECHAWLA 09-DEC-02 Bug # 2701440
--                     Added code to adjust the asset in all the tax books that the asset belongs to
--                     SECHAWLA 06-MAY-04 Bug # 3578894
--                     Process the depreciate flag updates independent of all other updates (dep method,
--                     life, cost, sv) This is required because FA does not allow updating depreciation flag
--                     with any other attribute. Details in bug 3501172
--                     Re-wrote this procedure as we have a new logic in place to process amortization transactions
--                   SECHAWLA 10-MAY-04 Bug # 3578894
--                     for Asset depreciation transactions, check the depreciate flag before updating it
--                   SECHAWLA 17-DEC-04 Bug # 4028371  update asset line transaction with FA trx date
--                   rmunjulu Bug 4150696 Added code to set transaction_date_entered with Date Transaction Occurred
--                   before calling the FA_ADJUSTMENT_PUB API
--                   RBRUNO 23-Aug-07 Bug # 6360770 Added code to set
--                   contract_id number when calling FA Adjustment API
--                   sechawla 14-dec-07 6690811 Removed code to disassociate the contract_id from FA asset
--
-- End of comments
 PROCEDURE process_transactions(
                                p_api_version           IN  	NUMBER,
           		 	            p_init_msg_list         IN  	VARCHAR2,
           			            x_return_status         OUT 	NOCOPY VARCHAR2,
           			            x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
                                p_contract_id 		    IN 	    NUMBER ,
                                p_asset_id              IN      NUMBER ,
                                p_kle_id                IN      NUMBER ,
                                p_salvage_writedown_yn  IN      VARCHAR2 ,
                                x_total_count           OUT     NOCOPY NUMBER,
                                x_processed_count       OUT     NOCOPY NUMBER,
                                x_error_count           OUT     NOCOPY NUMBER )    IS

   -- SECHAWLA Bug # 2701440  : new declarations
   TYPE books_tbl_type IS TABLE OF VARCHAR2(15) INDEX BY BINARY_INTEGER;
   l_books_tbl                  books_tbl_type;
   l_empty_books_tbl            books_tbl_type;
   l_book_type_code             VARCHAR2(15);
   i                            NUMBER;
   l_asset_books_error          EXCEPTION;


   SUBTYPE   thpv_rec_type   IS  okl_trx_assets_pub.thpv_rec_type;

   lp_thpv_rec                  thpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   l_total_count                NUMBER;
   l_sysdate                    DATE;

   --SECHAWLA 17-DEC-04 Bug # 4028371
   SUBTYPE   tlpv_rec_type   IS  okl_txl_assets_pub.tlpv_rec_type;

   lp_tlpv_rec                  tlpv_rec_type;
   lx_tlpv_rec                  tlpv_rec_type;


   -- SECHAWLA 06-MAY-04 3578894 : Created a new cursor to get all the assets that need to be processed
   -- This cursor picks up the amortization ,evergreen depreciation and salvage value writedown transactions to be
   -- processed in Fixed Assets. AMT - amortization, AED - evergreen, FSC - Salvage value writedown.
   CURSOR l_distinctasset_csr(cp_date IN DATE, p_org_id NUMBER) IS
   SELECT DISTINCT l.asset_number, l.kle_id, b.authoring_org_id
   FROM   OKL_TRX_ASSETS h, OKL_TXL_ASSETS_B l  -- SECHAWLA 19-FEB-04 3439647 : Use base tables instead of views
          ,okc_k_headers_all_b b /* Bug 6459571 */
   WHERE  h.id = l.tas_id
   AND    h.tsu_code in('ENTERED','ERROR')  -- SMODUGA 07-FEB-05 3578894 : process trx in entered and error status only
   AND    h.date_trans_occurred <= cp_date
   -- SECHAWLA 06-MAY-04 3578894 : Removing 'AED' as evergreen transactions are not created
   AND    (   (p_salvage_writedown_yn = 'N' AND  h.tas_type in ('AMT','AUD','AUS'))  OR
              (p_salvage_writedown_yn = 'Y' AND  h.tas_type in ('AMT','AUD','AUS','FSC'))
          )-- SECHAWLA 06-MAY-04 3578894 : Added new tas types 'AUD','AUS' to above 2 conditions
   AND    (
             --  all 3 parameter values are provided
            ( p_contract_id IS NOT NULL AND p_asset_id IS NOT NULL AND p_kle_id IS NOT NULL AND
              l.dnz_khr_id = p_contract_id AND l.dnz_asset_id= p_asset_id AND l.kle_id = p_kle_id)
            OR
            -- none of the parameter values are provided
            ( p_contract_id IS NULL AND p_asset_id IS NULL AND p_kle_id IS NULL)
            OR
            -- contract Id is provided, asset_id and kle_id not provided
            (p_contract_id IS NOT NULL AND l.dnz_khr_id = p_contract_id AND p_asset_id IS NULL AND p_kle_id IS NULL)
            OR
            -- contract Id and asset Id are provided, kle_id not provided
            (p_contract_id IS NOT NULL AND l.dnz_khr_id = p_contract_id AND p_asset_id IS NOT NULL AND l.dnz_asset_id= p_asset_id AND p_kle_id IS NULL)
            OR
            -- contarct Id and kle_id are provided, asset Id not provided
            (p_contract_id IS NOT NULL AND l.dnz_khr_id = p_contract_id AND p_asset_id IS NULL AND p_kle_id IS NOT NULL AND l.kle_id = p_kle_id)
            OR
            -- asset Id is provided, cntract ID and kle Id not provided
            (p_contract_id IS NULL AND p_asset_id IS NOT NULL AND  l.dnz_asset_id= p_asset_id AND p_kle_id IS NULL)
            OR
            -- asset Id and kle Id are provided, contract Id not provided
            (p_contract_id IS NULL AND p_asset_id IS NOT NULL AND  l.dnz_asset_id= p_asset_id AND p_kle_id IS NOT NULL AND l.kle_id = p_kle_id)
            OR
            -- kle Id is provided, contarct Id and asset Id not provided
            (p_contract_id IS NULL AND p_asset_id IS NULL AND p_kle_id IS NOT NULL AND l.kle_id = p_kle_id)
          )
    AND  l.dnz_khr_id = b.id(+)
    AND  NVL(b.AUTHORING_ORG_ID, P_ORG_ID ) =  P_ORG_ID
   ORDER BY  asset_number;

   -- SECHAWLA 06-MAY-04 3578894 : Modified cursor definition to include tax transactions
   -- Separated SVW transactions from this cursor
   CURSOR l_assettrx_csr(cp_date IN DATE, cp_asset_number IN VARCHAR2) IS
   SELECT h.id, l.id line_id, -- 17-DEC-04 SECHAWLA 4028371 : Added l.id
          h.tas_type, FL.MEANING TAS_TYPE_MEANING, h.date_trans_occurred, l.depreciate_yn, l.dnz_asset_id,
          decode(d.tax_book,NULL,l.CORPORATE_BOOK,d.tax_book ) ASSET_BOOK, fbc.book_class ASSET_BOOK_TYPE,
          l.in_service_date, l.deprn_method, l.life_in_months, l.deprn_rate, --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
          --nvl(l.depreciation_cost,0) depreciation_cost ,
          l.depreciation_cost,
          l.asset_number, nvl(l.salvage_value,0) salvage_value, nvl(l.old_salvage_value,0) old_salvage_value, l.kle_id,
          to_char(h.trans_number) trans_number -- SECHAWLA 17-DEC-04 4028371 : added for stamping
          --,l.currency_code func_currency_code -- SECHAWLA 29-JUL-05 4456005 : added
          --,l.DNZ_KHR_ID    -- SECHAWLA 29-JUL-05 4456005 : added
          -- SGORANTL 22-MAR-06 5097643: changes made by kbbhavsa for bug 4717511 has been reversed
          ,h.try_id --akrangan added for sla populate sources cr
   FROM   OKL_TRX_ASSETS h, OKL_TXL_ASSETS_B l, OKL_TXD_ASSETS_B d, fa_book_controls fbc, FND_LOOKUPS fl -- SECHAWLA 19-FEB-04 3439647 : Use base tables instead of views
   WHERE  h.id = l.tas_id
   AND    l.id = d.tal_id(+)
   AND    FL.LOOKUP_CODE = h.TAS_TYPE AND FL.LOOKUP_TYPE = 'OKL_TRANS_HEADER_TYPE'
   AND    decode(d.tax_book,NULL,  l.CORPORATE_BOOK,d.tax_book ) = fbc.book_type_code
   AND    h.tsu_code IN ('ENTERED','ERROR')  -- SMODUGA 07-FEB-05 4144322 : process trx in entered and error status only
   AND    h.date_trans_occurred <= cp_date
   -- SECHAWLA 06-MAY-04 3578894 : Separate SVW transactions from Amortization transactions
   AND    h.tas_type in ('AMT','AUD','AUS')
   -- SECHAWLA 06-MAY-04 3578894 : Added new tas types 'AUD','AUS' to above 2 conditions
   AND    l.asset_number = cp_asset_number
   ORDER BY  asset_book_type , date_trans_occurred, tas_type;


   -- SECHAWLA 06-MAY-04 3578894 : Created separate cursor to process SVW transactions
   -- As of now, SVW transactions are created only in corporate book.
   CURSOR l_assetsvtrx_csr(cp_date IN DATE, cp_asset_number IN VARCHAR2) IS
   SELECT h.id, h.tas_type, FL.MEANING TAS_TYPE_MEANING, h.date_trans_occurred, l.depreciate_yn, l.dnz_asset_id,
          decode(d.tax_book,NULL,l.CORPORATE_BOOK,d.tax_book ) ASSET_BOOK, fbc.book_class ASSET_BOOK_TYPE,
          l.in_service_date, l.deprn_method, l.life_in_months, l.deprn_rate, --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
          --nvl(l.depreciation_cost,0) depreciation_cost ,
          l.depreciation_cost,
          l.asset_number, nvl(l.salvage_value,0) salvage_value, nvl(l.old_salvage_value,0) old_salvage_value, l.kle_id
          --,l.currency_code func_currency_code -- SECHAWLA 29-JUL-05 4456005 : added
          --,l.DNZ_KHR_ID    -- SECHAWLA 29-JUL-05 4456005 : added
          -- SGORANTL 22-MAR-06 5097643: changes made by kbbhavsa for bug 4717511 has been reversed
          ,h.try_id --akrangan added for sla populate sources cr
          ,l.id line_id --akrangan added for sla populate sources cr
   FROM   OKL_TRX_ASSETS h, OKL_TXL_ASSETS_B l, OKL_TXD_ASSETS_B d, fa_book_controls fbc, FND_LOOKUPS fl -- SECHAWLA 19-FEB-04 3439647 : Use base tables instead of views
   WHERE  h.id = l.tas_id
   AND    l.id = d.tal_id(+)
   AND    FL.LOOKUP_CODE = h.TAS_TYPE AND FL.LOOKUP_TYPE = 'OKL_TRANS_HEADER_TYPE'
   AND    decode(d.tax_book,NULL,  l.CORPORATE_BOOK,d.tax_book ) = fbc.book_type_code
   AND    h.tsu_code IN ('ENTERED','ERROR')  -- SMODUGA 07-FEB-05 4144322 : process trx in entered and error status only
   AND    h.date_trans_occurred <= cp_date
   AND    h.tas_type = 'FSC'
   AND    l.asset_number = cp_asset_number
   ORDER BY  asset_book_type;



   -- Get the cost and sv for an asset
   -- SECHAWLA 10-MAY-04 3578894 : added depreciate flag, deprn_method_code, fb.life_in_months to this cursor
   CURSOR l_facostsv_csr(cp_asset_number IN VARCHAR2, cp_book_type_code IN VARCHAR2) IS
   --SECHAWLA 28-MAY-04 3645574 : Added adjusted_rate
   SELECT fb.cost, fb.salvage_value, fb.depreciate_flag, fb.deprn_method_code, fb.life_in_months, fb.adjusted_rate
   FROM   fa_books fb, fa_additions_b fab
   WHERE  fb.transaction_header_id_out is null
   AND    fb.book_type_code = cp_book_type_code
   AND    fab.asset_id = fb.asset_id
   AND    fab.asset_number = cp_asset_number;


   -- This cursor is used to check if an accepted termination quote exists for an asset line.
   CURSOR  l_quotes_csr(p_kle_id IN NUMBER) IS
   SELECT  l.asset_number
   FROM    okl_trx_quotes_b qh, okl_txl_quote_lines_b ql, okx_asset_lines_v l
   WHERE   qh.id = ql.qte_id
   AND     qh.qst_code = 'ACCEPTED'
   AND     ql.qlt_code = 'AMCFIA'
   AND     ql.kle_id  = l.parent_line_id
   AND     ql.kle_id = p_kle_id;


   -- SECHAWLA 06-MAY-04 3578894 : Do not need this cursor for off lease trx , as tax trx are now created separately
   -- SECHAWLA Bug # 2701440  : added a new cursor
   -- This cursor is still being used for SVW transactions
   -- This cursor is used to find all the tax books that an asset belongs to
  /* SECHAWLA 28-DEC-05 4374620 : do not process SVW transactions in tax books
   CURSOR l_fabookcntrl_csr(p_asset_id IN NUMBER) IS
   SELECT a.book_type_code
   FROM   fa_books a, fa_book_controls b
   WHERE  a.asset_id = p_asset_id
   AND    a.book_type_code = b.book_type_code
   AND    b.book_class = 'TAX'
   AND    a.date_ineffective IS NULL
   AND    a.transaction_header_id_out IS NULL;
   */


   -- SECHAWLA 19-FEB-04 3439647 : New Declarations
   -- get the deal type from the contract
   CURSOR l_dealtype_csr(p_financial_asset_id IN NUMBER) IS
   SELECT lkhr.id, lkhr.deal_type, khr.contract_number
   FROM   okl_k_headers lkhr, okc_k_lines_b cle, okc_k_headers_b khr
   WHERE  khr.id = cle.chr_id
   AND    lkhr.id = khr.id
   AND    cle.id = p_financial_asset_id;

   -- SECHAWLA 14-FEB-05 3950089 : get the salvage type
   CURSOR l_booksalvagetype_csr(cp_asset_id IN NUMBER, cp_booktype_code IN VARCHAR2) IS
   SELECT salvage_type
   FROM   fa_books
   WHERE  asset_id = cp_asset_id
   AND    book_type_code = cp_booktype_code
   AND    transaction_header_id_out IS NULL
   AND    date_ineffective IS NULL;

   l_salvage_type       VARCHAR2(30);
   -- SECHAWLA 14-FEB-05 3950089 : end new declarations


   l_deal_type          VARCHAR2(30);
   l_chr_id             NUMBER;
   l_contract_number    VARCHAR2(120);

   l_rulv_rec           okl_rule_pub.rulv_rec_type;

   -- SECHAWLA 19-FEB-04 3439647 : End New Declarations


   l_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name                   CONSTANT VARCHAR2(30) := 'process_transactions';

   l_trans_rec			        FA_API_TYPES.trans_rec_type;

   -- SECHAWLA 06-MAY-04 3578894
   l_trans_empty_rec			FA_API_TYPES.trans_rec_type;

   l_asset_hdr_rec		        FA_API_TYPES.asset_hdr_rec_type;

   -- SECHAWLA 06-MAY-04 3578894
   l_asset_hdr_empty_rec        FA_API_TYPES.asset_hdr_rec_type;

   l_asset_fin_rec_adj		    FA_API_TYPES.asset_fin_rec_type;
   -- SECHAWLA 06-MAY-04 3578894
   l_asset_fin_rec_empty_adj    FA_API_TYPES.asset_fin_rec_type;

   l_asset_fin_rec_new		    FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new	    FA_API_TYPES.asset_fin_tbl_type;

   l_inv_trans_rec		        FA_API_TYPES.inv_trans_rec_type;
   l_inv_tbl			        FA_API_TYPES.inv_tbl_type;
   l_asset_deprn_rec_adj	    FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new	    FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new	FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;
   l_method_code		        fa_methods.method_code%TYPE;
   l_fa_cost                    NUMBER;
   l_fa_salvage_value           NUMBER;
   l_delta_cost                 NUMBER;
   l_delta_salvage_value        NUMBER;
   l_api_version                CONSTANT NUMBER := 1;
   l_transaction_status         VARCHAR2(1);

   l_process_count              NUMBER;
   l_asset_number               VARCHAR2(15);
   l_trx_count                  NUMBER;

   -- SGORANTL 22-MAR-06 5097643: changes made by kbbhavsa for bug 4717511 has been reversed
   l_dep_cost                 NUMBER;
   l_sal_value                NUMBER;


   TYPE trxassets_rec_type IS RECORD( id                 NUMBER       DEFAULT OKL_API.G_MISS_NUM,
                                      asset_number       VARCHAR2(15) DEFAULT OKL_API.G_MISS_CHAR,
                                      asset_book         VARCHAR2(70) DEFAULT OKL_API.G_MISS_CHAR,
                                      tas_type_meaning   VARCHAR2(80) DEFAULT OKL_API.G_MISS_CHAR
                                    );

   TYPE trxassets_tbl_type IS TABLE OF trxassets_rec_type INDEX BY BINARY_INTEGER;

   l_trxassets_tbl              trxassets_tbl_type;
   l_trxassets_empty_tbl        trxassets_tbl_type;
   l_pos                        NUMBER;

   l_update_status              VARCHAR2(1);
   j                            NUMBER;

   -- SECHAWLA 10-MAY-04 3578894 : new declarations
   l_fa_depreciate_flag         VARCHAR2(10);
   l_fa_deprn_method_code       VARCHAR2(12);
   l_fa_life_in_months          NUMBER;

   --SECHAWLA 28-MAY-04 3645574 : new declaration
   l_fa_deprn_rate              NUMBER;

   -- 17-DEC-04 SECHAWLA 4028371 : new declarations
   l_fa_trx_date 				DATE;
      --akrangan sla populate sources cr start
      l_fxhv_rec         okl_fxh_pvt.fxhv_rec_type;
      l_fxlv_rec         okl_fxl_pvt.fxlv_rec_type;
   --akrangan sla populate sources cr end

   -- Bug 6459571
   l_org_id                     NUMBER;
 BEGIN

 l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);

 IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
 END IF;



 SELECT SYSDATE INTO l_sysdate  FROM DUAL;
 -- transaction information
 -- SECHAWLA 06-MAY-04 3578894 : Moved the following statement inside the loop
 -- l_trans_rec.transaction_subtype := G_TRANS_SUBTYPE;


 l_total_count := 0;
 l_process_count := 0;

 -- Bug 6459571: Start
 -- Fetch the Operating Unit for the Concurrent Program
 l_org_id := mo_global.get_current_org_id();
  -- Bug 6459571: End
 FOR l_distinctasset_rec IN l_distinctasset_csr(l_sysdate, l_org_id) LOOP
   l_transaction_status  :=  OKC_API.G_RET_STS_SUCCESS;
   l_trx_count := 0;
   l_trxassets_tbl := l_trxassets_empty_tbl;
   l_pos := 0;


   BEGIN   -- process amortization transactions begin

      SAVEPOINT asset_updates;

      -- loop thru all the transactions in the OKL tables and process them in FA
      FOR l_assettrx_rec IN l_assettrx_csr(l_sysdate, l_distinctasset_rec.asset_number) LOOP

         --l_transaction_status  :=  OKC_API.G_RET_STS_SUCCESS;
         l_total_count := l_total_count + 1;
         l_trx_count := l_trx_count + 1;

         /*-- initialize all the structures to null values
         l_asset_fin_rec_adj.depreciate_flag := NULL;
         l_asset_fin_rec_adj.deprn_method_code :=  NULL;
         l_asset_fin_rec_adj.life_in_months := NULL;
         l_asset_fin_rec_adj.cost :=  NULL;
         l_asset_fin_rec_adj.salvage_value := NULL;
         */ -- -- SECHAWLA 06-MAY-04 3578894
         l_asset_fin_rec_adj := l_asset_fin_rec_empty_adj ;


         -- SECHAWLA 06-MAY-04 3578894 : Initialize the amortization start date before every call to FA API.
         -- This is required to avoid YTD and Accumulated depreciation calculation as per clarification
         -- received from FA, bug 3559993
         --l_trans_rec.amortization_start_date := NULL;
         l_trans_rec := l_trans_empty_rec;
         -- SECHAWLA 06-MAY-04 3578894 : Moved the following statement inside the loop
         l_trans_rec.transaction_subtype := G_TRANS_SUBTYPE;


         -- SECHAWLA 17-DEC-04 4028371 : stamp FA trx with OKL trx type
         l_trans_rec.calling_interface  := 'OKL:'||'Off Lease Amort:'||l_assettrx_rec.tas_type;
         l_trans_rec.transaction_name := substr(l_assettrx_rec.TRANS_NUMBER,1,30);


         -- SECHWLA 06-MAY-04 3578894 : Initialize all record types
         l_asset_hdr_rec := l_asset_hdr_empty_rec;

		 -- SECHAWLA 17-DEC-04 4028371 : initailize l_fa_trx_date
         l_fa_trx_date := NULL;


         -- get the deal type from the contract
         OPEN  l_dealtype_csr(l_assettrx_rec.kle_id);
         FETCH l_dealtype_csr INTO l_chr_id, l_deal_type, l_contract_number;
         IF  l_dealtype_csr%NOTFOUND OR l_deal_type IS NULL OR l_deal_type = OKL_API.G_MISS_CHAR THEN
             -- Can not find deal type for asset ASSET_NUMBER.
             OKC_API.set_message(  p_app_name      => 'OKL',
                                   p_msg_name      => 'OKL_AM_DEAL_TYPE_NOT_FOUND',
                                   p_token1        => 'ASSET_NUMBER',
                                   p_token1_value  => l_assettrx_rec.asset_number);

             l_transaction_status  := OKC_API.G_RET_STS_ERROR;
         ELSE

             IF  l_assettrx_rec.asset_book IS NULL OR l_assettrx_rec.asset_book = OKL_API.G_MISS_CHAR THEN
                  --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER as FIELD is missing.
                  OKC_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_ASSET_BOOK',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'FIELD',
                                     p_token3_value  => 'Asset Book');

                  l_transaction_status  := OKC_API.G_RET_STS_ERROR;
             -- SECHAWLA 06-MAY-04 3578894 Added new tas types 'AUD','AUS'  to following condition
             ELSIF (l_assettrx_rec.tas_type IN ('AMT','AUD','AUS')) AND (l_assettrx_rec.depreciate_yn IS NULL OR
                                                                         l_assettrx_rec.depreciate_yn = OKL_API.G_MISS_CHAR) THEN
                 --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as depreciate (Y/N) flag is missing.
                 OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        => 'TRX_TYPE',
                                     p_token1_value  => l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assettrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Depreciate (Y/N) flag');

                  l_transaction_status  := OKC_API.G_RET_STS_ERROR;
             ELSIF  l_assettrx_rec.dnz_asset_id IS NULL OR l_assettrx_rec.dnz_asset_id = OKL_API.G_MISS_NUM THEN
                  --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as Asset ID
                  -- is missing.
                  OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        => 'TRX_TYPE',
                                     p_token1_value  => l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assettrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Asset ID');

                  l_transaction_status  := OKC_API.G_RET_STS_ERROR;

              ELSE

                  OPEN  l_facostsv_csr(l_assettrx_rec.asset_number, l_assettrx_rec.asset_book);
                  -- SECHAWLA 10-MAY-04 3578894 : added l_depreciate_flag, l_deprn_method_code, l_life_in_months
                  FETCH l_facostsv_csr INTO l_fa_cost, l_fa_salvage_value, l_fa_depreciate_flag, l_fa_deprn_method_code,
                        l_fa_life_in_months, l_fa_deprn_rate; --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate

                  IF (l_facostsv_csr%NOTFOUND) THEN
                     --This combination of Asset ASSET and Book BOOK is invalid.

                      OKL_API.set_message(
                        p_app_name      => 'OKL',
                        p_msg_name      => 'OKL_AM_INVALID_ASSET_BOOK',
                        p_token1        => 'ASSET_NUMBER',
                        p_token1_value  => l_assettrx_rec.asset_number,
                        p_token2        => 'BOOK',
                        p_token2_value  => l_assettrx_rec.asset_book);

                     l_transaction_status  := OKL_API.G_RET_STS_ERROR;

                  ELSIF (l_fa_life_in_months IS NULL AND l_fa_deprn_rate IS NULL)  THEN

                     --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as Cost / salvage Value
                     -- is missing.
                     OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        => 'TRX_TYPE',
                                     p_token1_value  => l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assettrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Life In Months / Adjusted Rate');

                     l_transaction_status  := OKL_API.G_RET_STS_ERROR;


                   -- SECHAWLA 06-MAY-04 3578894 : Added this scenario to just stop the depreciation
                  ELSIF l_assettrx_rec.tas_type = 'AUD' AND l_assettrx_rec.depreciate_yn = 'N' THEN

                       IF l_fa_depreciate_flag <> 'NO' THEN  -- SECHAWLA 10-MAY-04 3578894 : FA update fails
                                                             -- if we try to update the flag to the same value
                            --  Operating Lease hold period, DF Lease hold period : 1st trx -  stop depreciation
                            -- asset header information
                            l_asset_hdr_rec.asset_id := l_assettrx_rec.dnz_asset_id;

                            -- financial information
                            l_asset_fin_rec_adj.depreciate_flag := 'NO';
                            -- ? need to add another validation to make sure that depreciation has already been run for this asset
                            -- ? for the current open period. Which means we can not stop depreciation for an asset in the middle of the
                            -- ? period.



                            l_asset_hdr_rec.book_type_code := l_assettrx_rec.asset_book;

                            -- rmunjulu Bug 4150696 Added code to set transaction_date_entered with Date Transaction Occurred
                            l_trans_rec.transaction_date_entered := l_assettrx_rec.date_trans_occurred;

                            -- rbruno Bug 6360770 Added code to set contract_id
                            -- sechawla 14-dec-07 6690811 : Removed code to set contract id
                            --l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;

                            fa_adjustment_pub.do_adjustment(
                                   p_api_version              => p_api_version,
    		                       p_init_msg_list            => OKC_API.G_FALSE,
    		                       p_commit                   => FND_API.G_FALSE,
    		                       p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
    		                       p_calling_fn               => NULL,
    		                       x_return_status            => l_return_status,
    		                       x_msg_count                => x_msg_count,
    		                       x_msg_data                 => x_msg_data,
    		                       px_trans_rec               => l_trans_rec,
    		                       px_asset_hdr_rec           => l_asset_hdr_rec,
    		                       p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
    		                       x_asset_fin_rec_new        => l_asset_fin_rec_new,
    		                       x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
    		                       px_inv_trans_rec           => l_inv_trans_rec,
    		                       px_inv_tbl                 => l_inv_tbl,
    		                       p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
    		                       x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
    		                       x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                   p_group_reclass_options_rec => l_group_reclass_options_rec);

                            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                                -- Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.
                                OKC_API.set_message(  p_app_name      => 'OKL',
                                        p_msg_name      => 'OKL_AM_AMT_TRANS_FAILED',
                                        p_token1        =>  'TRX_TYPE',
                                        p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                        p_token2        =>  'ASSET_NUMBER',
                                        p_token2_value  =>  l_assettrx_rec.asset_number,
                                        p_token3        =>  'BOOK', -- SECHAWLA Bug # 2701440  : Added token2
                                        p_token3_value  =>  l_assettrx_rec.asset_book); -- SECHAWLA Bug # 2701440  : Added token2 value
                                l_transaction_status  := l_return_status;
                            ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                                l_fa_trx_date := l_trans_rec.transaction_date_entered;
                            END IF;
			    --akrangan populate sources cr changes start
                    -- header record
           l_fxhv_rec.source_id    := l_assettrx_rec.id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id := l_chr_id;
           l_fxhv_rec.try_id := l_assettrx_rec.try_id;
           --line record
           l_fxlv_rec.source_id         := l_assettrx_rec.line_id;
           l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           l_fxlv_rec.asset_id     :=  l_assettrx_rec.dnz_asset_id;
           l_fxlv_rec.kle_id   :=  l_assettrx_rec.kle_id;
           l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
           l_fxlv_rec.asset_book_type_name := l_assettrx_rec.asset_book;
           --call api
           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = okc_api.g_ret_sts_unexp_error)
           THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okc_api.g_ret_sts_error)
           THEN
             RAISE okl_api.g_exception_error;
           END IF;
          --akrangan populate sources cr end
                       ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                            OKL_ACCOUNTING_UTIL.get_fa_trx_date(
							              p_book_type_code => l_assettrx_rec.asset_book,
      									  x_return_status  => l_return_status,
   										  x_fa_trx_date    => l_fa_trx_date);

   	  						IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          					    l_transaction_status  := l_return_status;
      						END IF;

                      END IF;


                     -- SECHAWLA 06-MAY-04 3578894 : Changed the tas_type in the condition to AUS to handle
                     -- DF/Sales lease, hold period scenario, 2nd trx - to only updaet the asset cost

                 ELSIF l_assettrx_rec.tas_type = 'AUS' AND l_assettrx_rec.depreciate_yn = 'N' THEN

                       --  DF/Sales lease, hold period, 2nd trx - update asset cost
                       -- asset header information


                       -- SECHAWLA 07-SEP-05 4596776 : The following check should use dep cost in functional currency
                       -- So first convert the amount and then compare
                       /*IF l_fa_cost <> l_assettrx_rec.depreciation_cost THEN  -- SECHAWLA 10-MAY-04 3578894 : FA update fails
                                         -- if we try to update the cost with the same value
                       */
                       -- SECHAWLA 19-FEB-04 3439647 : Write asset cost up to NIV when we stop the depreciation, for DF/Sales lease
                       IF l_deal_type IN ('LEASEDF','LEASEST') THEN
                               -- 5097643 27-mar-06 5029064: changes made by kbbhavsa for bug 4717511 has been reversed
                     	        --SECHAWLA 21-DEC-05 4899337 : end
                                l_dep_cost := l_assettrx_rec.depreciation_cost; -- sgorantl 27-mar-06 5097643

                                IF l_fa_cost <>  l_dep_cost THEN --SECHAWLA 21-DEC-05 4899337: added
                    		 -- kbbhavsa : added for bug 4717511 -- end

                                	l_delta_cost :=  l_dep_cost - l_fa_cost;
                                	l_asset_fin_rec_adj.cost := l_delta_cost;

                                	l_asset_hdr_rec.asset_id := l_assettrx_rec.dnz_asset_id;
                                	l_asset_hdr_rec.book_type_code := l_assettrx_rec.asset_book;
                            -- rbruno Bug 6360770 Added code to set contract_id
                            -- sechawla 14-dec-07 6690811 : Removed code to set contract id
                            -- l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;
                                    -- Bug 6965689 start
                                    l_trans_rec.transaction_date_entered := l_assettrx_rec.date_trans_occurred;
                                    -- Bug 6965689 end
                                	fa_adjustment_pub.do_adjustment(
                                   			p_api_version              => p_api_version,
    		                       			p_init_msg_list            => OKC_API.G_FALSE,
    		                       			p_commit                   => FND_API.G_FALSE,
    		                       			p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
    		                       			p_calling_fn               => NULL,
    		                       			x_return_status            => l_return_status,
    		                       			x_msg_count                => x_msg_count,
    		                       			x_msg_data                 => x_msg_data,
    		                       			px_trans_rec               => l_trans_rec,
    		                       			px_asset_hdr_rec           => l_asset_hdr_rec,
    		                       			p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
    		                       			x_asset_fin_rec_new        => l_asset_fin_rec_new,
    		                       			x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
    		                       			px_inv_trans_rec           => l_inv_trans_rec,
    		                       			px_inv_tbl                 => l_inv_tbl,
    		                       			p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
    		                       			x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
    		                       			x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                   			p_group_reclass_options_rec => l_group_reclass_options_rec);

                                	IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                                    	--  Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.
                                    	OKC_API.set_message(  p_app_name      => 'OKL',
                                        		p_msg_name      => 'OKL_AM_AMT_TRANS_FAILED',
                                        		p_token1        =>  'TRX_TYPE',
                                        		p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                        		p_token2        =>  'ASSET_NUMBER', -- SECHAWLA Bug # 2701440  : Added token2 value
                                        		p_token2_value  =>  l_assettrx_rec.asset_number,
                                        		p_token3        =>  'BOOK',
                                        		p_token3_value  =>  l_assettrx_rec.asset_book
                                        		);
                                    		l_transaction_status  := l_return_status;

                                	ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                                			l_fa_trx_date := l_trans_rec.transaction_date_entered;
                                	END IF;
--akrangan populate sources cr changes start
                                            -- header record
           l_fxhv_rec.source_id    := l_assettrx_rec.id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id := l_chr_id;
           l_fxhv_rec.try_id := l_assettrx_rec.try_id;
           --line record
           l_fxlv_rec.source_id         := l_assettrx_rec.line_id;
           l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           l_fxlv_rec.asset_id     :=  l_assettrx_rec.dnz_asset_id;
           l_fxlv_rec.kle_id   :=  l_assettrx_rec.kle_id;
           l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
           l_fxlv_rec.asset_book_type_name := l_assettrx_rec.asset_book;
           --call api
           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = okc_api.g_ret_sts_unexp_error)
           THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okc_api.g_ret_sts_error)
           THEN
             RAISE okl_api.g_exception_error;
           END IF;
           --akrangan populate sources cr changes end
                                ELSIF l_deal_type IN ('LEASEDF','LEASEST') THEN -- 17-DEC-04 SECHAWLA 4028371  added else section
                                	OKL_ACCOUNTING_UTIL.get_fa_trx_date(
							              p_book_type_code => l_assettrx_rec.asset_book,
      									  x_return_status  => l_return_status,
   										  x_fa_trx_date    => l_fa_trx_date);

   	  					    		IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          					       			l_transaction_status  := l_return_status;
      					    		END IF;
                               	END IF;

					    END IF;

                        -- SECHAWLA 19-FEB-04 3439647 : end

                 ELSIF
                     (   -- SECHAWLA 06-MAY-04 3578894 :
                        -- Op lease, hold period, 2nd trx - update dep method, life
                        -- DF/Sales lease, hold period, 3rd trx - update dep method, life, cost, sv
                        -- DF/Sales lease, no hold period, 1st trx - update dep method, life, cost, sv

                        --(l_assettrx_rec.tas_type IN ('AMT', 'AED'))  AND (l_assettrx_rec.depreciate_yn = 'Y')
                        -- SECHAWLA 06-MAY-04 3578894 : Removing 'AED' as evergreen transactions are not created
                        (l_assettrx_rec.tas_type = 'AMT')  AND (l_assettrx_rec.depreciate_yn = 'Y')

                     ) THEN

                     IF  l_assettrx_rec.deprn_method IS NULL OR l_assettrx_rec.deprn_method = OKL_APi.G_MISS_CHAR THEN
                         -- Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as FIELD is missing.
                         OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assettrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Depreciation Method');
                         l_transaction_status  := OKC_API.G_RET_STS_ERROR;
                     ELSIF  ( (l_assettrx_rec.life_in_months IS NULL OR l_assettrx_rec.life_in_months = OKL_APi.G_MISS_NUM)
                               AND --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate check
                              (l_assettrx_rec.deprn_rate IS NULL OR l_assettrx_rec.deprn_rate = OKL_APi.G_MISS_NUM)
                             ) THEN
                         -- Can not process transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as FIELD is missing.
                        OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assettrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Life In Months / Depreciation Rate'); --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate
                        l_transaction_status  := OKC_API.G_RET_STS_ERROR;

                    ELSIF  l_assettrx_rec.salvage_value IS NULL OR l_assettrx_rec.salvage_value = OKL_APi.G_MISS_NUM THEN
                        -- Can not process transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as FIELD is missing.
                        OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assettrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assettrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Salvage Value');
                        l_transaction_status  := OKC_API.G_RET_STS_ERROR;

                    ELSE
                        -- sgorantl 27-mar-06 5097643: changes made by kbbhavsa for bug 4717511 has been reversed
	               	l_dep_cost := l_assettrx_rec.depreciation_cost;	-- sgorantl 27-mar-06 5097643

                        l_sal_value := l_assettrx_rec.salvage_value; -- sgorantl 27-mar-06 5097643
						        --SECHAWLA 21-DEC-05 4899337 : Moved this piece here   : end




                        		IF (l_fa_deprn_method_code <> l_assettrx_rec.deprn_method) OR
                           			-- SECHAWLA 28-MAY-04 3645574 : Added deprn_rate conditional checks
                           			(( l_assettrx_rec.life_in_months IS NOT NULL) AND (l_fa_life_in_months IS NULL OR l_fa_life_in_months <> l_assettrx_rec.life_in_months)) OR
                           			(( l_assettrx_rec.deprn_rate IS NOT NULL) AND (l_fa_deprn_rate IS NULL OR l_fa_deprn_rate <> l_assettrx_rec.deprn_rate)) OR
                           			--Mar 05, 2006 sgorantl - 115.35 4631549 : compare FA cost with converted cost
                           			(l_assettrx_rec.depreciation_cost IS NOT NULL  AND l_fa_cost <> l_dep_cost) OR
                           			--Mar 05, 2006 sgorantl - 115.35 4631549  : compare FA SV with converted SV
                           			(l_fa_salvage_value <> l_sal_value) THEN  -- SECHAWLA 10-MAY-04 3578894 : FA update fails


                                		-- asset header information
                                		l_asset_hdr_rec.asset_id := l_assettrx_rec.dnz_asset_id;

                                		-- SECHAWLA Bug # 2701440  : commented out the following assignment
                                		--l_asset_hdr_rec.book_type_code := l_assettrx_rec.corporate_book;


                                		l_asset_fin_rec_adj.deprn_method_code :=  l_assettrx_rec.deprn_method;

                                		--SECHAWLA 28-MAY-04 3645574 : update life or rate and nullify the other
                                		IF l_assettrx_rec.life_in_months IS NOT NULL THEN
                                   			l_asset_fin_rec_adj.life_in_months := l_assettrx_rec.life_in_months;
                                   			l_asset_fin_rec_adj.adjusted_rate := NULL;
                                   			-- SECHAWLA 07-JUN-04 3645574 : FA requires both basic_rate and adjusted_rate to be set together
                                   			l_asset_fin_rec_adj.basic_rate := NULL;
                                		ELSE
                                   			l_asset_fin_rec_adj.life_in_months := NULL;
                                   			l_asset_fin_rec_adj.adjusted_rate := l_assettrx_rec.deprn_rate;
                                   			-- SECHAWLA 07-JUN-04 3645574 : FA requires both basic_rate and adjusted_rate to be set together
                                   			-- Currently Authoring allows only those values for rates where basic rate = adjusted rate
                                   			l_asset_fin_rec_adj.basic_rate := l_assettrx_rec.deprn_rate;
                                		END IF;


                                        IF l_assettrx_rec.depreciation_cost IS NOT NULL THEN -- IF base product is DF Lease and rep product is OP lease,
                                                                             -- then AMT trx will be created for corp/tax book (not null cost)
                                                                             -- and also for rep book(null cost)

                                   			-- SECHAWLA 29-JUL-05 4456005 : convert dep cost to functional currency - end
                                   			--l_delta_cost :=  l_assettrx_rec.depreciation_cost - l_fa_cost; -- SECHAWLA 29-JUL-05 4456005

                                        	--  delta for cost is the new modified cost in OKL - original cost in FA
                                   			l_delta_cost :=  l_dep_cost - l_fa_cost; ---- SECHAWLA 29-JUL-05 4456005

                                    		l_asset_fin_rec_adj.cost := l_delta_cost;
                 						END IF;


                                   		-- SECHAWLA 29-JUL-05 4456005 : convert dep cost to functional currency - end
                                   	    --l_delta_salvage_value := l_assettrx_rec.salvage_value - l_fa_salvage_value; ---- SECHAWLA 29-JUL-05 4456005
										l_delta_salvage_value := l_sal_value - l_fa_salvage_value;
                                		l_asset_fin_rec_adj.salvage_value := l_delta_salvage_value; --SECHAWLA 14-FEB-05 3950089

                                              IF l_delta_salvage_value <> 0 THEN -- Mar 05, 2006 sgorantl - 115.35 4631549 : added this condition

                                		--SECHAWLA 14-FEB-05 3950089 : begin
                                		OPEN  l_booksalvagetype_csr(l_assettrx_rec.dnz_asset_id, l_assettrx_rec.asset_book);
                                		FETCH l_booksalvagetype_csr INTO l_salvage_type;
                                		CLOSE l_booksalvagetype_csr;

                                		IF l_salvage_type = 'AMT' then
                                   			l_asset_fin_rec_adj.salvage_value := l_delta_salvage_value;
                                		ELSIF l_salvage_type = 'PCT' THEN
                                   			l_asset_fin_rec_adj.salvage_value := l_assettrx_rec.salvage_value;
                                		END IF;
                                		l_asset_fin_rec_adj.salvage_type := 'AMT' ;
                                		--SECHAWLA 14-FEB-05 3950089 : end
                                              END IF;


                                         -- rbruno Bug 6360770 Added code to set contract_id
                                         -- sechawla 14-dec-07 6690811 : Removed code to set contract id
                                         --l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;

                                		-- rmunjulu Bug 4150696 Added code to set transaction_date_entered with Date Transaction Occurred
                                		l_trans_rec.transaction_date_entered := l_assettrx_rec.date_trans_occurred;

                                		l_asset_hdr_rec.book_type_code := l_assettrx_rec.asset_book;
                                		fa_adjustment_pub.do_adjustment(
                                            p_api_version              => p_api_version,
    		                                p_init_msg_list            => OKC_API.G_FALSE,
    		                                p_commit                   => FND_API.G_FALSE,
    		                                p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
    		                                p_calling_fn               => NULL,
    		                                x_return_status            => l_return_status,
    		                                x_msg_count                => x_msg_count,
    		                                x_msg_data                 => x_msg_data,
    		                                px_trans_rec               => l_trans_rec,
    		                                px_asset_hdr_rec           => l_asset_hdr_rec,
    		                                p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
    		                                x_asset_fin_rec_new        => l_asset_fin_rec_new,
    		                                x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
    		                                px_inv_trans_rec           => l_inv_trans_rec,
    		                                px_inv_tbl                 => l_inv_tbl,
     		                                p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
    		                                x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
    		                                x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                            p_group_reclass_options_rec => l_group_reclass_options_rec);


                                		IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                                    		-- Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.

                                    		OKC_API.set_message(  p_app_name      => 'OKL',
                                                    p_msg_name      => 'OKL_AM_AMT_TRANS_FAILED',
                                                    p_token1        =>  'TRX_TYPE',
                                                    p_token1_value  =>   l_assettrx_rec.TAS_TYPE_MEANING,
                                                    p_token2        =>  'ASSET_NUMBER',
                                                    p_token2_value  =>  l_assettrx_rec.asset_number,
                                                    p_token3        =>  'BOOK', -- SECHAWLA Bug # 2701440  : Added token2
                                                    p_token3_value  =>  l_assettrx_rec.asset_book
                                                    ); -- SECHAWLA Bug # 2701440  : Added token2 value

                                    		l_transaction_status  := l_return_status;
                                		ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                                			l_fa_trx_date := l_trans_rec.transaction_date_entered;
                                		END IF;
                                		--akrangan populate sources cr changes start
                                            -- header record
           l_fxhv_rec.source_id    := l_assettrx_rec.id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id := l_chr_id;
           l_fxhv_rec.try_id := l_assettrx_rec.try_id;
           --line record
           l_fxlv_rec.source_id         := l_assettrx_rec.line_id;
           l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           l_fxlv_rec.asset_id     :=  l_assettrx_rec.dnz_asset_id;
           l_fxlv_rec.kle_id   :=  l_assettrx_rec.kle_id;
           l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
           l_fxlv_rec.asset_book_type_name := l_assettrx_rec.asset_book;
           --call api
           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = okc_api.g_ret_sts_unexp_error)
           THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okc_api.g_ret_sts_error)
           THEN
             RAISE okl_api.g_exception_error;
           END IF;
           --akrangan populate sources cr changes end
                                ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                               			OKL_ACCOUNTING_UTIL.get_fa_trx_date(
							              p_book_type_code => l_assettrx_rec.asset_book,
      									  x_return_status  => l_return_status,
   										  x_fa_trx_date    => l_fa_trx_date);

   	  						   			IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          					       			l_transaction_status  := l_return_status;
      						   			END IF;
                               	END IF;
                    END IF;
                 ------------------------------------------------------

                 ELSIF
                    (    -- SECHAWLA 06-MAY-04 3578894 : Added this scenario for :
                         -- OP Lease, hold period, 3rd trx - start dep
                         -- DF/Sales Lease, hold period, 4th trx - start dep
                         -- DF/Sales Lease, no hold period, 2nd trx - start dep
                        (l_assettrx_rec.tas_type = 'AUD')  AND (l_assettrx_rec.depreciate_yn = 'Y')
                    ) THEN

                     IF l_fa_depreciate_flag <> 'YES' THEN  -- SECHAWLA 10-MAY-04 3578894 : if there is no hold period,
                                                         -- the dep flag will normally = YES. FA update fails with error
                                                         -- if we try to update the flag to the same value
                        -- asset header information
                        l_asset_hdr_rec.asset_id := l_assettrx_rec.dnz_asset_id;

                        -- SECHAWLA Bug # 2701440  : commented out the following assignment
                        --l_asset_hdr_rec.book_type_code := l_assettrx_rec.corporate_book;

                        -- financial information
                        -- SECHAWLA 06-MAY-04 3578894 : start the depreciation
                        l_asset_fin_rec_adj.depreciate_flag := 'YES';


                        -- rbruno Bug 6360770 Added code to set contract_id
                        -- sechawla 14-dec-07 6690811 : Removed code to set contract id
                        --l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;

                        -- rmunjulu Bug 4150696 Added code to set transaction_date_entered with Date Transaction Occurred
                        l_trans_rec.transaction_date_entered := l_assettrx_rec.date_trans_occurred;

                        l_asset_hdr_rec.book_type_code := l_assettrx_rec.asset_book;
                        fa_adjustment_pub.do_adjustment(
                                            p_api_version              => p_api_version,
    		                                p_init_msg_list            => OKC_API.G_FALSE,
    		                                p_commit                   => FND_API.G_FALSE,
    		                                p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
    		                                p_calling_fn               => NULL,
    		                                x_return_status            => l_return_status,
    		                                x_msg_count                => x_msg_count,
    		                                x_msg_data                 => x_msg_data,
    		                                px_trans_rec               => l_trans_rec,
    		                                px_asset_hdr_rec           => l_asset_hdr_rec,
    		                                p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
    		                                x_asset_fin_rec_new        => l_asset_fin_rec_new,
    		                                x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
    		                                px_inv_trans_rec           => l_inv_trans_rec,
    		                                px_inv_tbl                 => l_inv_tbl,
     		                                p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
    		                                x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
    		                                x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                            p_group_reclass_options_rec => l_group_reclass_options_rec);


                        IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                            --  Error processing TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER in book BOOK.

                            OKC_API.set_message(  p_app_name      => 'OKL',
                                                    p_msg_name      => 'OKL_AM_AMT_TRANS_FAILED',
                                                    p_token1        =>  'TRX_TYPE',
                                                    p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                                    p_token2        =>  'ASSET_NUMBER',
                                                    p_token2_value  =>  l_assettrx_rec.asset_number,
                                                    p_token3        =>  'BOOK', -- SECHAWLA Bug # 2701440  : Added token2
                                                    p_token3_value  =>  l_assettrx_rec.asset_book
                                                    ); -- SECHAWLA Bug # 2701440  : Added token2 value

                            l_transaction_status  := l_return_status;
                        ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                            l_fa_trx_date := l_trans_rec.transaction_date_entered;

                        END IF;
--akrangan populate sources cr changes start
                                            -- header record
           l_fxhv_rec.source_id    := l_assettrx_rec.id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id := l_chr_id;
           l_fxhv_rec.try_id := l_assettrx_rec.try_id;
           --line record
           l_fxlv_rec.source_id         := l_assettrx_rec.line_id;
           l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           l_fxlv_rec.asset_id     :=  l_assettrx_rec.dnz_asset_id;
           l_fxlv_rec.kle_id   :=  l_assettrx_rec.kle_id;
           l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
           l_fxlv_rec.asset_book_type_name := l_assettrx_rec.asset_book;
           --call api
           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = okc_api.g_ret_sts_unexp_error)
           THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okc_api.g_ret_sts_error)
           THEN
             RAISE okl_api.g_exception_error;
           END IF;
           --akrangan populate sources cr changes end
                     ELSE -- 17-DEC-04 SECHAWLA 4028371  added else section
                        OKL_ACCOUNTING_UTIL.get_fa_trx_date(
							              p_book_type_code => l_assettrx_rec.asset_book,
      									  x_return_status  => l_return_status,
   										  x_fa_trx_date    => l_fa_trx_date);

   	  				    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          			        l_transaction_status  := l_return_status;
      				    END IF;
                   END IF;


                 -- SECHAWLA 06-MAY-04 3578894 : Process FSC transactions separately
                 ------------------------------------------------------

                  END IF;  --IF l_facostsv_csr%NOTFOUND THEN
                  CLOSE l_facostsv_csr;

              END IF; --IF  l_assettrx_rec.asset_book IS NULL...


         END IF; --IF  l_dealtype_csr%NOTFOUND OR l_deal_type IS NULL OR l_deal_type = OKL_API.G_MISS_CHAR THEN
         CLOSE l_dealtype_csr;
         --------------

         -- 17-DEC-04 SECHAWLA 4028371 : update FA trx date on the trx line
         IF l_fa_trx_date IS NOT NULL THEN -- this particular asset trx was processed successfully in FA
             -- update date on the trx line
             lp_tlpv_rec.id  := l_assettrx_rec.line_id;
             lp_tlpv_rec.FA_TRX_DATE := l_fa_trx_date;

             OKL_TXL_ASSETS_PUB.update_txl_asset_Def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_tlpv_rec          => lp_tlpv_rec,
                            x_tlpv_rec          => lx_tlpv_rec);

             IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                -- Error updating Fixed Assets transaction date on TRX_TYPE transaction for asset ASSET_NUMBER in book BOOK.
                OKC_API.set_message(  p_app_name      => 'OKL',
                                      p_msg_name      => 'OKL_AM_FA_DT_UPD_ERR',
                                      p_token1        =>  'TRX_TYPE',
                                      p_token1_value  =>  l_assettrx_rec.TAS_TYPE_MEANING,
                                      p_token2        =>  'ASSET_NUMBER',
                                      p_token2_value  =>  l_assettrx_rec.asset_number,
                                      p_token3        =>  'BOOK',
                                      p_token3_value  =>  l_assettrx_rec.asset_book);

                l_transaction_status  := OKL_API.G_RET_STS_ERROR;
             END IF;
		 END IF;
		 -- 17-DEC-04 SECHAWLA 4028371 : end
		 ---------------------------------------

         l_pos := l_pos + 1;
         -- Store the transaction header ids for all the transactions for a particular asset
         l_trxassets_tbl(l_pos).id := l_assettrx_rec.id;
         l_trxassets_tbl(l_pos).asset_number := l_assettrx_rec.asset_number;
         l_trxassets_tbl(l_pos).asset_book := l_assettrx_rec.asset_book;
         l_trxassets_tbl(l_pos).tas_type_meaning := l_assettrx_rec.tas_type_meaning;


      END LOOP;

      ----------


      l_update_status := OKC_API.G_RET_STS_SUCCESS;

      IF l_transaction_status = OKC_API.G_RET_STS_SUCCESS THEN  -- all the trasnsactions for this asset were successful
         IF l_trxassets_tbl.COUNT > 0 THEN
            j := l_trxassets_tbl.FIRST;
            LOOP

               -- update the staus (tsu_code) in okl_trx_assets_v
               lp_thpv_rec.id  := l_trxassets_tbl(j).id;
               lp_thpv_rec.tsu_code := 'PROCESSED';
               OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

                IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                    -- TRX_TYPE Transaction status STATUS could not be updated in OKL for asset ASSET_NUMBER and book ASSET_BOOK.
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_TRXASSET_UPD_FAILED',
                                  p_token1        => 'TRX_TYPE',
                                  p_token1_value  => l_trxassets_tbl(j).tas_type_meaning,
                                  p_token2        => 'STATUS',
                                  p_token2_value  => 'PROCESSED',
                                  p_token3        =>  'ASSET_NUMBER',
                                  p_token3_value  =>  l_trxassets_tbl(j).asset_number,
                                  p_token4        =>  'ASSET_BOOK',
                                  p_token4_value  =>  l_trxassets_tbl(j).asset_book);

                    l_update_status := OKC_API.G_RET_STS_ERROR;

                END IF;

               EXIT WHEN (j = l_trxassets_tbl.LAST);
               j := l_trxassets_tbl.NEXT(j);
            END LOOP;

            IF l_update_status = OKC_API.G_RET_STS_SUCCESS THEN  -- trx status updated successfully for all the transactions for this asset
               COMMIT;  -- it will commit changes in FA and also in OKL (trx status update)
               -- off-lease trx have been updated for asset ASSET_NUMBER in Fixed Assets.
               OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_FA_UPD_DONE',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  l_distinctasset_rec.asset_number);

               l_process_count := l_process_count + l_trx_count;
            ELSE
               ROLLBACK TO asset_updates;  -- This will rollback FA changes and also OKL changes (trx status update, incase status was chnaged
                                           -- to PROCESSED for some of the transactions
                                           -- The transactions will stay in ENTERED status
               -- Off-Lease trasnactions were not processed for asset ASSET_NUMBER in Fixed Assets.
               OKC_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_FA_UPD_NOT_DONE',
                                     p_token1        =>  'ASSET_NUMBER',
                                     p_token1_value  =>  l_distinctasset_rec.asset_number);
            END IF;

          END IF; --IF l_trxassets_tbl.COUNT > 0 THEN


      ELSE -- IF l_transaction_status <> OKC_API.G_RET_STS_SUCCESS THEN
           -- one or more transactions errored out for this asset

           -- First rollback FA changes and then update trx status to ERROR
           ROLLBACK TO asset_updates;
           -- Off-Lease trasnactions were not processed for asset ASSET_NUMBER in Fixed Assets.
           OKC_API.set_message(   p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_FA_UPD_NOT_DONE',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  l_distinctasset_rec.asset_number);

           BEGIN

              SAVEPOINT trx_status_update;
              -- Update trx status to ERROR in OKL
              IF l_trxassets_tbl.COUNT > 0 THEN
                 j := l_trxassets_tbl.FIRST;
                 LOOP
                     -- update the staus (tsu_code) in okl_trx_assets_v
                     lp_thpv_rec.id  := l_trxassets_tbl(j).id;
                     lp_thpv_rec.tsu_code := 'ERROR';
                     OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

                      IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                         -- TRX_TYPE Transaction status STATUS could not be updated in OKL for asset ASSET_NUMBER and book ASSET_BOOK.
                         OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_TRXASSET_UPD_FAILED',
                                  p_token1        => 'TRX_TYPE',
                                  p_token1_value  => l_trxassets_tbl(j).tas_type_meaning,
                                  p_token2        => 'STATUS',
                                  p_token2_value  => 'ERROR',
                                  p_token3        =>  'ASSET_NUMBER',
                                  p_token3_value  =>  l_trxassets_tbl(j).asset_number,
                                  p_token4        =>  'ASSET_BOOK',
                                  p_token4_value  =>  l_trxassets_tbl(j).asset_book);
                          l_update_status := OKC_API.G_RET_STS_ERROR;
                       END IF;

                       EXIT WHEN (j = l_trxassets_tbl.LAST);
                       j := l_trxassets_tbl.NEXT(j);
                  END LOOP;

                  IF l_update_status = OKC_API.G_RET_STS_SUCCESS THEN -- trx status updated succesfully to 'ERROR' for all trx for this asset
                     COMMIT; -- commit the trx status upadte to ERROR
                  ELSE  -- trx status could not be updated to ERROR for one or more transactions
                     ROLLBACK to trx_status_update;  -- trx status will remain ENTERED (fa trx have already been rolled back)
                  END IF;
               END IF; --IF l_trxassets_tbl.COUNT > 0 THEN
           END;


     END IF; -- IF l_transaction_status = OKC_API.G_RET_STS_SUCCESS THEN



   END;  -- process amortization transactions end

   IF p_salvage_writedown_yn = 'Y' THEN
     -- SECHAWLA 06-MAY-04 3578894 : Process SVW transactions separately
     BEGIN  -- process SVW transactions begin
     l_transaction_status  :=  OKC_API.G_RET_STS_SUCCESS;

     -- As of now, this cursor will return only 1 row for a particulat asset. SVW transactions
     -- are being created only for corporate book but processed in all books
     FOR l_assetsvtrx_rec IN l_assetsvtrx_csr(l_sysdate, l_distinctasset_rec.asset_number) LOOP


         l_total_count := l_total_count + 1;
         --l_trx_count := l_trx_count + 1;

         -- SECHAWLA Bug # 2701440  : initialize the asset books table
         l_books_tbl := l_empty_books_tbl;


         -- get the deal type from the contract
         OPEN  l_dealtype_csr(l_assetsvtrx_rec.kle_id);
         FETCH l_dealtype_csr INTO l_chr_id, l_deal_type, l_contract_number;
         IF  l_dealtype_csr%NOTFOUND OR l_deal_type IS NULL OR l_deal_type = OKL_API.G_MISS_CHAR THEN
             -- Can not find deal type for asset ASSET_NUMBER.
             OKC_API.set_message(  p_app_name      => 'OKL',
                                   p_msg_name      => 'OKL_AM_DEAL_TYPE_NOT_FOUND',
                                   p_token1        => 'ASSET_NUMBER',
                                   p_token1_value  => l_assetsvtrx_rec.asset_number);

             l_transaction_status  := OKC_API.G_RET_STS_ERROR;
         ELSE

             IF  l_assetsvtrx_rec.asset_book IS NULL OR l_assetsvtrx_rec.asset_book = OKL_API.G_MISS_CHAR THEN
                  --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER as FIELD is missing.
                  OKC_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_ASSET_BOOK',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assetsvtrx_rec.asset_number,
                                     p_token3        => 'FIELD',
                                     p_token3_value  => 'Asset Book');

                  l_transaction_status  := OKC_API.G_RET_STS_ERROR;
             -- SECHAWLA 06-MAY-04 3578894 Added new tas types 'AUD','AUS'  to following condition



             ELSIF  l_assetsvtrx_rec.dnz_asset_id IS NULL OR l_assetsvtrx_rec.dnz_asset_id = OKL_API.G_MISS_NUM THEN
                  --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as Asset ID
                  -- is missing.
                  OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assetsvtrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assetsvtrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Asset ID');

                  l_transaction_status  := OKC_API.G_RET_STS_ERROR;

              ELSE

                  OPEN  l_facostsv_csr(l_assetsvtrx_rec.asset_number, l_assetsvtrx_rec.asset_book);
                  -- SECHAWLA 10-MAY-04 3578894 : added l_depreciate_flag, l_deprn_method_code, l_life_in_months
                  FETCH l_facostsv_csr INTO l_fa_cost, l_fa_salvage_value,l_fa_depreciate_flag, l_fa_deprn_method_code,
                        l_fa_life_in_months , l_fa_deprn_rate; --SECHAWLA 28-MAY-04 3645574 : Added deprn_rate ;
                  IF l_facostsv_csr%NOTFOUND OR l_fa_cost IS NULL OR l_fa_salvage_value IS NULL THEN
                     --Can not process TRX_TYPE transaction in Fixed Assets for asset ASSET_NUMBER and book ASSET_BOOK as Cost / Salvage Value
                     -- is missing.

                      OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        => 'TRX_TYPE',
                                     p_token1_value  => l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assetsvtrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assetsvtrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Cost / Salvage Value');


                      l_transaction_status  := OKL_API.G_RET_STS_ERROR;


                 ELSIF l_assetsvtrx_rec.salvage_value IS NULL OR l_assetsvtrx_rec.salvage_value = OKL_API.G_MISS_NUM THEN
                        -- Can not process TRX_TYPE transaction for asset ASSET_NUMBER in Fixed Assets as FIELD is missing.
                        OKC_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_DATA_REQUIRED',
                                     p_token1        =>  'TRX_TYPE',
                                     p_token1_value  =>  l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                     p_token2        => 'ASSET_NUMBER',
                                     p_token2_value  => l_assetsvtrx_rec.asset_number,
                                     p_token3        => 'ASSET_BOOK',
                                     p_token3_value  => l_assetsvtrx_rec.asset_book,
                                     p_token4        => 'FIELD',
                                     p_token4_value  => 'Salvage Value');


                        l_transaction_status  := OKC_API.G_RET_STS_ERROR;
                 ELSE

                           OPEN  l_quotes_csr(l_assetsvtrx_rec.kle_id);
                        FETCH l_quotes_csr INTO l_asset_number;
                        IF l_quotes_csr%FOUND THEN
                            -- Can not process Salvage Value for asset ASSET_NUMBER as an accepted termination quote exists for this asset.
                            OKL_API.set_message( p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_SVW_NOT_PROCESSED',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  => l_asset_number);
                            l_transaction_status  := OKC_API.G_RET_STS_ERROR;

                        ELSE


                            -- Salvage Value Writedown transaction
                            -- asset header information

                            -- SECHAWLA 06-MAY-04 3578894 : Moved the following statement inside the books loop
                            -- to first initialize the l_asset_hdr_rec structure before every call to FA API
                            -- and then assign asset id
                           -- l_asset_hdr_rec.asset_id := l_assetsvtrx_rec.dnz_asset_id;

                            -- sgorantl 27-mar-06 5097643: changes made by kbbhavsa for bug 4717511 has been reversed
                            l_sal_value := l_assetsvtrx_rec.salvage_value; -- sgorantl 27-mar-06 5097643
                             -- kbbhavsa : added for bug 4717511 -- end

                            l_delta_salvage_value := l_sal_value - l_fa_salvage_value;
                            -- SECHAWLA 06-MAY-04 3578894 : Moved the following statement inside the books loop
                            -- to first initialize the l_asset_fin_rec_adj structure before every call to FA API
                            -- and then assign SV

                            --l_asset_fin_rec_adj.salvage_value := l_delta_salvage_value;


                            	BEGIN

                                    SAVEPOINT process_fsc;
                                    -- SECHAWLA Bug # 2701440  : store all the tax books of an asset in a table
                                    -- The corporate book is at the 0th position
                                    i := 0;
                                    l_books_tbl(i) := l_assetsvtrx_rec.asset_book ; -- this will be corporate book
                                                                                  -- as SVW transactions are still being
                                                                                  -- created onl in corp book and processed
                                                                                  -- in all books
                                    /* SECHAWLA 28-DEC-05 4374620 : do not process SVW transactions in tax books
                                    FOR l_fabookcntrl_rec IN l_fabookcntrl_csr(l_assetsvtrx_rec.dnz_asset_id) LOOP
                                        i := i + 1;
                                        l_books_tbl(i) := l_fabookcntrl_rec.book_type_code;
                                    END LOOP;
                                    */
                                    -- SECHAWLA Bug # 2701440  : Loop thru all the records in the tax book table and
                                    -- call fa adjustments for each book
                                    IF l_books_tbl.COUNT > 0 THEN -- SECHAWLA 28-DEC-05 4374620 : l_books_tbl will have only 1 row for corp book
                                        i := l_books_tbl.FIRST;
                                        LOOP -- SECHAWLA 28-DEC-05 4374620 : this loop will get executed only once for the corp book
                                            -- SECHAWLA 06-MAY-04 3578894 : Initialize the structures inside the loop
                                            l_asset_fin_rec_adj := l_asset_fin_rec_empty_adj ;
                                            l_trans_rec := l_trans_empty_rec;
                                            l_asset_hdr_rec := l_asset_hdr_empty_rec;

                                            -- SECHAWLA 06-MAY-04 3578894 : Assign values after initialization
                                            l_trans_rec.transaction_subtype := G_TRANS_SUBTYPE;

                                            --SECHAWLA 29-DEC-05 3827148 : Added
                                            l_trans_rec.calling_interface  := 'OKL:'||'SVW:'||l_assetsvtrx_rec.tas_type;

                                            l_asset_hdr_rec.asset_id := l_assetsvtrx_rec.dnz_asset_id;
                                            --l_asset_fin_rec_adj.salvage_value := l_delta_salvage_value; --SECHAWLA 14-FEB-05 3950089

                                       IF l_delta_salvage_value <> 0 THEN -- Mar 05, 2006 sgorantl - 115.35 4631549  : added this condition

                                            --SECHAWLA 14-FEB-05 3950089 : begin
                                            OPEN  l_booksalvagetype_csr(l_assetsvtrx_rec.dnz_asset_id, l_books_tbl(i));
                                            FETCH l_booksalvagetype_csr INTO l_salvage_type;
                                            CLOSE l_booksalvagetype_csr;

                                            IF l_salvage_type = 'AMT' then
                                               l_asset_fin_rec_adj.salvage_value := l_delta_salvage_value;
                                            ELSIF l_salvage_type = 'PCT' THEN
                                               l_asset_fin_rec_adj.salvage_value := l_assetsvtrx_rec.salvage_value;
                                            END IF;
                                            l_asset_fin_rec_adj.salvage_type := 'AMT' ;
                                            --SECHAWLA 14-FEB-05 3950089 : end
                                        END IF;

                                            -- rbruno Bug 6360770 Added code to set contract_id
                                            -- sechawla 14-dec-07 6690811 : Removed code to set contract id
                                           --l_asset_fin_rec_adj.contract_id := FND_API.G_MISS_NUM;

                                            ------------
                                            l_asset_hdr_rec.book_type_code := l_books_tbl(i);

                                            fa_adjustment_pub.do_adjustment(
                                                p_api_version              => p_api_version,
    		                                    p_init_msg_list            => OKC_API.G_FALSE,
    		                                    p_commit                   => FND_API.G_FALSE,
    		                                    p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
    		                                    p_calling_fn               => NULL,
    		                                    x_return_status            => l_return_status,
    		                                    x_msg_count                => x_msg_count,
    		                                    x_msg_data                 => x_msg_data,
    		                                    px_trans_rec               => l_trans_rec,
    		                                    px_asset_hdr_rec           => l_asset_hdr_rec,
    		                                    p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
    		                                    x_asset_fin_rec_new        => l_asset_fin_rec_new,
    		                                    x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
    		                                    px_inv_trans_rec           => l_inv_trans_rec,
    		                                    px_inv_tbl                 => l_inv_tbl,
    		                                    p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
    		                                    x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
    		                                    x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                                p_group_reclass_options_rec => l_group_reclass_options_rec);



                                            IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                                                -- Error processing TRX_TYPE transaction for asset ASSET_NUMBER in book BOOK.
                                                -- Salvage Value Writedown transaction was not processed for this asset in Fixed Assets.
                                                OKC_API.set_message(  p_app_name      => 'OKL',
                                                    p_msg_name      => 'OKL_AM_FSC_TRANS_FAILED',
                                                    p_token1        =>  'TRX_TYPE',
                                                    p_token1_value  =>  l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                                    p_token2        =>  'ASSET_NUMBER',
                                                    p_token2_value  =>  l_assetsvtrx_rec.asset_number,
                                                    p_token3        =>  'BOOK', -- SECHAWLA Bug # 2701440  : Added token2
                                                    p_token3_value  =>  l_books_tbl(i)); -- SECHAWLA Bug # 2701440  : Added token2 value);

                                                l_transaction_status  := l_return_status;
                                                RAISE l_asset_books_error;
                                            END IF;
					                                 --akrangan populate sources cr changes start
                                            -- header record
                                            l_fxhv_rec.source_id    := l_assetsvtrx_rec.id;
                                            l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
                                            l_fxhv_rec.khr_id := l_chr_id;
                                            l_fxhv_rec.try_id := l_assetsvtrx_rec.try_id;
                                            --line record
                                            l_fxlv_rec.source_id         := l_assetsvtrx_rec.line_id;
                                            l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
                                            l_fxlv_rec.asset_id     :=  l_assetsvtrx_rec.dnz_asset_id;
                                            l_fxlv_rec.kle_id   :=  l_assetsvtrx_rec.kle_id;
                                            l_fxlv_rec.fa_transaction_id := l_trans_rec.transaction_header_id;
                                            l_fxlv_rec.asset_book_type_name := l_books_tbl(i);
                                            --call api
                                            okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                                    p_init_msg_list => okc_api.g_false,
                                                                    p_fxhv_rec      => l_fxhv_rec,
                                                                    p_fxlv_rec      => l_fxlv_rec,
                                                                    x_return_status => x_return_status,
                                                                    x_msg_count     => x_msg_count,
                                                                    x_msg_data      => x_msg_data);

                                            IF (x_return_status = okc_api.g_ret_sts_unexp_error)
                                            THEN
                                            RAISE okl_api.g_exception_unexpected_error;
                                            ELSIF (x_return_status = okc_api.g_ret_sts_error)
                                            THEN
                                            RAISE okl_api.g_exception_error;
                                            END IF;
                                      --akrangan populate sources cr ends
                                            EXIT WHEN (i = l_books_tbl.LAST);
                                            i := l_books_tbl.NEXT(i);
                                        END LOOP;
                                    END IF;
                                    EXCEPTION
                                    WHEN  l_asset_books_error THEN
                                        ROLLBACK TO process_fsc;
                              	END;


                        END IF;  -- IF l_quotes_csr%FOUND THEN
                        CLOSE l_quotes_csr;

                    --END IF; --IF  l_assetsvtrx_rec.salvage_value IS NULL OR l_assetsvtrx_rec.salvage_value = OKL_APi.G_MISS_NUM THEN

                  END IF;  --IF l_facostsv_csr%NOTFOUND THEN
                  CLOSE l_facostsv_csr;

              END IF; --IF  l_assetsvtrx_rec.asset_book IS NULL...

        --   END IF; --IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

         END IF; --IF  l_dealtype_csr%NOTFOUND OR l_deal_type IS NULL OR l_deal_type = OKL_API.G_MISS_CHAR THEN
         CLOSE l_dealtype_csr;
         --------------

         IF l_transaction_status =  OKC_API.G_RET_STS_SUCCESS THEN
             -- update the staus (tsu_code) in okl_trx_assets_v
             lp_thpv_rec.id  := l_assetsvtrx_rec.id;
             lp_thpv_rec.tsu_code := 'PROCESSED';
             OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

              IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  -- Transaction status STATUS could not be updated in OKL for asset ASSET_NUMBER
                  OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_TRXASSET_UPD_FAILED',
                                  p_token1        =>  'TRX_TYPE',
                                  p_token1_value  =>  l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                  p_token2        => 'STATUS',
                                  p_token2_value  => 'PROCESSED',
                                  p_token3        =>  'ASSET_NUMBER',
                                  p_token3_value  =>  l_assetsvtrx_rec.asset_number,
                                  p_token4        =>  'ASSET_BOOK',
                                  p_token4_value  =>  l_assetsvtrx_rec.asset_book);
              ELSE
                  l_process_count := l_process_count + 1;
                  -- Asset Details have been updated for asset ASSET_NUMBER in Fixed Assets.
                  OKC_API.set_message(  p_app_name      => 'OKL',
                                  --p_msg_name      => 'OKL_AM_FA_UPD_DONE',
                                  p_msg_name      => 'OKL_AM_SV_FA_UPD_DONE', -- SECHAWLA 06-MAY-04 3578894: Changed msg
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  l_assetsvtrx_rec.asset_number);
              END IF;
         ELSE  -- FA changes have already been rolled back at this point
              -- update the staus (tsu_code) in okl_trx_assets_v
              lp_thpv_rec.id  := l_assetsvtrx_rec.id;
              lp_thpv_rec.tsu_code := 'ERROR';
              OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => l_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

               IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                  -- Transaction status STATUS could not be updated in OKL for asset ASSET_NUMBER
                    OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      =>  'OKL_AM_TRXASSET_UPD_FAILED',
                                  p_token1        =>  'TRX_TYPE',
                                  p_token1_value  =>  l_assetsvtrx_rec.TAS_TYPE_MEANING,
                                  p_token2        =>  'STATUS',
                                  p_token2_value  =>  'ERROR',
                                  p_token3        =>  'ASSET_NUMBER',
                                  p_token3_value  =>  l_assetsvtrx_rec.asset_number,
                                  p_token4        =>  'ASSET_BOOK',
                                  p_token4_value  =>  l_assetsvtrx_rec.asset_book);


               END IF;
         END IF;



      END LOOP;

   END;  -- process SVW transactions end

 END IF; -- IF p_salvage_writedown_yn = 'Y'

 END LOOP;


 x_total_count := l_total_count;
 x_processed_count := l_process_count;
 x_error_count := l_total_count - l_process_count;

 OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 EXCEPTION

      WHEN OKC_API.G_EXCEPTION_ERROR THEN

       IF l_distinctasset_csr%ISOPEN THEN
          CLOSE l_distinctasset_csr;
       END IF;

       IF l_facostsv_csr%ISOPEN THEN
          CLOSE l_facostsv_csr;
       END IF;
       IF l_assettrx_csr%ISOPEN THEN
         CLOSE l_assettrx_csr;
       END IF;

       IF l_assetsvtrx_csr%ISOPEN THEN
         CLOSE l_assetsvtrx_csr;
       END IF;

       IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
       END IF;

       -- SECHAWLA Bug # 2701440  : close the new cursor
      /* -- SECHAWLA 28-DEC-05 4374620
	   IF l_fabookcntrl_csr%ISOPEN THEN
           CLOSE l_fabookcntrl_csr;
       END IF;
      */
       --SECHAWLA Bug # 3439647 : Close the new cursor
       IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
       END IF;


        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      IF l_distinctasset_csr%ISOPEN THEN
          CLOSE l_distinctasset_csr;
       END IF;

       IF l_facostsv_csr%ISOPEN THEN
          CLOSE l_facostsv_csr;
       END IF;
       IF l_assettrx_csr%ISOPEN THEN
         CLOSE l_assettrx_csr;
       END IF;

       IF l_assetsvtrx_csr%ISOPEN THEN
         CLOSE l_assetsvtrx_csr;
       END IF;

       IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
       END IF;

       -- SECHAWLA Bug # 2701440  : close the new cursor
       /* -- SECHAWLA 28-DEC-05 4374620
	   IF l_fabookcntrl_csr%ISOPEN THEN
           CLOSE l_fabookcntrl_csr;
       END IF;
       */

       --SECHAWLA Bug # 3439647 : Close the new cursor
       IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
       END IF;

        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
      IF l_distinctasset_csr%ISOPEN THEN
          CLOSE l_distinctasset_csr;
       END IF;

       IF l_facostsv_csr%ISOPEN THEN
          CLOSE l_facostsv_csr;
       END IF;
       IF l_assettrx_csr%ISOPEN THEN
         CLOSE l_assettrx_csr;
       END IF;

       IF l_assetsvtrx_csr%ISOPEN THEN
         CLOSE l_assetsvtrx_csr;
       END IF;

       IF l_quotes_csr%ISOPEN THEN
           CLOSE l_quotes_csr;
       END IF;

       -- SECHAWLA Bug # 2701440  : close the new cursor
       /* -- SECHAWLA 28-DEC-05 4374620
	   IF l_fabookcntrl_csr%ISOPEN THEN
           CLOSE l_fabookcntrl_csr;
       END IF;
       */

       --SECHAWLA Bug # 3439647 : Close the new cursor
       IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
       END IF;

        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );


   END process_transactions;


END;

/
