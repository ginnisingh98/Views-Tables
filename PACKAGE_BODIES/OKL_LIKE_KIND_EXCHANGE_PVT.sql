--------------------------------------------------------
--  DDL for Package Body OKL_LIKE_KIND_EXCHANGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LIKE_KIND_EXCHANGE_PVT" AS
/* $Header: OKLRLKXB.pls 120.10 2006/11/27 13:21:04 kthiruva noship $ */

  FUNCTION GET_TOTAL_MATCH_AMT (p_asset_id IN NUMBER,
                                p_tax_book IN VARCHAR2) RETURN NUMBER IS

	l_asset_id            NUMBER;
	l_total_match_amount  NUMBER;

    CURSOR get_total_match_amt_csr (p_req_asset_id NUMBER, p_tax_book_code VARCHAR2) IS
	SELECT trx.req_asset_id, sum(trx.total_match_amount)
	FROM okl_trx_assets trx, okl_txl_assets_v txl, okl_txd_assets_v txd
    WHERE trx.id = txl.tas_id
	AND txl.id = txd.tal_id
	AND trx.total_match_amount IS NOT NULL
    AND txd.tax_book = p_tax_book_code
    AND trx.req_asset_id = p_req_asset_id
    GROUP BY trx.req_asset_id;

  BEGIN

    OPEN get_total_match_amt_csr(p_asset_id, p_tax_book);
	FETCH get_total_match_amt_csr INTO l_asset_id, l_total_match_amount;
	IF get_total_match_amt_csr%NOTFOUND THEN
	  CLOSE get_total_match_amt_csr;
	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    RETURN(l_total_match_amount);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RETURN NULL;

  END GET_TOTAL_MATCH_AMT;

  FUNCTION GET_BALANCE_SALE_PROCEEDS (p_asset_id IN NUMBER,
                                    p_tax_book IN VARCHAR2) RETURN NUMBER IS

    l_bal_sale_proceeds   NUMBER;
	l_total_match_amount  NUMBER;
	l_sale_proceeds       NUMBER;

    CURSOR get_sale_proceeds_csr (p_req_asset_id NUMBER, p_tax_book_code VARCHAR2) IS
	SELECT proceeds_of_sale
	FROM OKL_LIKE_KIND_EXCHANGE_V
	WHERE asset_id = p_req_asset_id
	AND book_type_code = p_tax_book_code;

  BEGIN

    l_total_match_amount := GET_TOTAL_MATCH_AMT(p_asset_id, p_tax_book);
	IF l_total_match_amount IS NULL THEN
	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    OPEN get_sale_proceeds_csr(p_asset_id, p_tax_book);
	FETCH get_sale_proceeds_csr INTO l_sale_proceeds;
	IF get_sale_proceeds_csr%NOTFOUND THEN
	  CLOSE get_sale_proceeds_csr;
	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    l_bal_sale_proceeds := l_sale_proceeds - l_total_match_amount;

    RETURN(l_bal_sale_proceeds);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RETURN NULL;

  END GET_BALANCE_SALE_PROCEEDS;

  FUNCTION GET_DEFERRED_GAIN (p_asset_id IN VARCHAR2,
                            p_tax_book IN VARCHAR2) RETURN NUMBER IS

    l_bal_sale_proceeds   NUMBER;
	l_orig_gain_loss      NUMBER;
	l_orig_sale_proceeds  NUMBER;
	l_deferred_gain       NUMBER;

    CURSOR get_orig_amounts_csr (p_req_asset_id NUMBER, p_tax_book_code VARCHAR2) IS
	SELECT proceeds_of_sale, gain_loss_amount
	FROM OKL_LIKE_KIND_EXCHANGE_V
	WHERE asset_id = p_req_asset_id
	AND book_type_code = p_tax_book_code;

  BEGIN

    OPEN get_orig_amounts_csr(p_asset_id, p_tax_book);
	FETCH get_orig_amounts_csr INTO l_orig_sale_proceeds, l_orig_gain_loss;
	IF get_orig_amounts_csr%NOTFOUND THEN
	  CLOSE get_orig_amounts_csr;
	  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    l_bal_sale_proceeds := GET_BALANCE_SALE_PROCEEDS(p_asset_id,p_tax_book);
    l_deferred_gain := ROUND((l_bal_sale_proceeds/l_orig_sale_proceeds)*l_orig_gain_loss,2);

    RETURN(l_deferred_gain);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    RETURN NULL;

    WHEN OTHERS THEN
    RETURN NULL;

  END GET_DEFERRED_GAIN;

  -------------------------------------------------------------------------------
  --Function to get FA location id. An asset after being sent to FA may have been
  -- assigned to different FA locations. Since OKL takes only only one FA location
  --right now , we will pick up only one location.
  ------------------------------------------------------------------------------
  FUNCTION get_fa_location (p_asset_id IN VARCHAR2,
                          p_book_type_code IN VARCHAR2,
                          x_location_id OUT NOCOPY NUMBER) RETURN VARCHAR2 IS
    CURSOR fa_location_curs(p_asset_id       IN VARCHAR2,
                            p_book_type_code IN VARCHAR2) is
    SELECT location_id
    FROM   okx_ast_dst_hst_v
    WHERE  asset_id = p_asset_id
    AND    book_type_code = p_book_type_code
    AND    status = 'A'
    AND    nvl(start_date_active,sysdate) <= sysdate
    AND    nvl(end_date_active,sysdate+1) > sysdate
    AND    transaction_header_id_out is null
    AND    retirement_id is null
    AND    rownum < 2;
    -- sgiyer 03-JUN-02 Copied from
	-- from okl we are creating an asset with one location only. Verified
	-- with AVSINGH.
    --This is strange way to get one location
    --since asset can be assigned to multiple
    --fa locations. But till we know what we have to do
    --this is it.
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_location_id   NUMBER default Null;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    OPEN fa_location_curs(p_asset_id,
                          p_book_type_code);
    FETCH fa_location_curs
    INTO  l_location_id;
    IF fa_location_curs%NotFound THEN
      NULL; --location not found that is not a problem
            --as it is not a mandatory field
    END IF;
    CLOSE fa_location_curs;
    RETURN(l_return_status);
    EXCEPTION
    WHEN Others THEN
         -- notify caller of an UNEXPECTED error
         l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
         OKL_API.set_message(
            G_APP_NAME,
            G_UNEXPECTED_ERROR,
            G_SQLCODE_TOKEN,
            SQLCODE,
            G_SQLERRM_TOKEN,
            SQLERRM);
         -- if the cursor is open
         IF fa_location_curs%ISOPEN THEN
            CLOSE fa_location_curs;
          END IF;
     RETURN(l_return_status);
  END Get_fa_Location;

--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : CREATE_FIXED_ASSET
--Description    : Calls FA additions api to create new like kind assets
--History        :
--                 24-Apr-2002  Shri Iyer Created
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE CREATE_FIXED_ASSET(p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_split_factor  IN  NUMBER,
							 p_rep_asset_rec IN  rep_asset_rec_type,
							 p_asdt_rec      IN  asset_details_rec_type,
                             p_txlv_rec      IN  OKL_TXL_ASSETS_PUB.tlpv_rec_type,
                             p_txdv_rec      IN  OKL_TXD_ASSETS_PUB.adpv_rec_type,
                             x_asset_hdr_rec IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT VARCHAR2(2000) := 'CREATE_FIXED_ASSET';
l_api_version          CONSTANT NUMBER := 1.0;

l_trans_rec                FA_API_TYPES.trans_rec_type;
l_dist_trans_rec           FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
l_asset_desc_rec           FA_API_TYPES.asset_desc_rec_type;
l_asset_cat_rec            FA_API_TYPES.asset_cat_rec_type;
l_asset_type_rec           FA_API_TYPES.asset_type_rec_type;
l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
l_asset_dist_rec           FA_API_TYPES.asset_dist_rec_type;
l_asset_dist_tbl           FA_API_TYPES.asset_dist_tbl_type;
l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
l_asset_hierarchy_rec      FA_API_TYPES.asset_hierarchy_rec_type;

l_split_factor             NUMBER;
l_mesg VARCHAR2(2000);
l_mesg_len NUMBER;
BEGIN

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKL_API.START_ACTIVITY (
                                l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,l_return_status);
   -- Check if activity started successfully
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   --FA_SRVR_MSG.Init_Server_Message;
   --FA_DEBUG_PKG.Initialize;

   --trans_rec_info
   l_trans_rec.transaction_type_code    := 'ADDITION';
   l_trans_rec.transaction_date_entered := p_asdt_rec.date_placed_in_service;
   l_trans_rec.who_info.last_updated_by := FND_GLOBAL.USER_ID;
   l_trans_rec.calling_interface        := l_api_name;

   --hdr_rec info
   IF p_asdt_rec.book_class = 'TAX' THEN
     l_asset_hdr_rec.asset_id := x_asset_hdr_rec.asset_id;
   END IF;
   l_asset_hdr_rec.book_type_code := p_asdt_rec.book_type_code;

   -- desc info
   l_asset_desc_rec.asset_number            := p_txlv_rec.asset_number;
   l_asset_desc_rec.description             := p_txlv_rec.description;
   l_asset_desc_rec.serial_number           := p_asdt_rec.serial_number;
   l_asset_desc_rec.asset_key_ccid          := p_asdt_rec.asset_key_ccid;
   l_asset_desc_rec.manufacturer_name       := p_asdt_rec.manufacturer_name;
   l_asset_desc_rec.model_number            := p_asdt_rec.model_number;
   l_asset_desc_rec.lease_id                := p_asdt_rec.lease_id;
   l_asset_desc_rec.in_use_flag             := p_asdt_rec.in_use_flag;
   l_asset_desc_rec.inventorial             := p_asdt_rec.inventorial;
   l_asset_desc_rec.property_type_code      := p_asdt_rec.property_type_code;
   l_asset_desc_rec.property_1245_1250_code := p_asdt_rec.property_1245_1250_code;
   l_asset_desc_rec.owned_leased            := p_asdt_rec.owned_leased;
   l_asset_desc_rec.new_used                := p_asdt_rec.new_used;
   l_asset_desc_rec.current_units           := p_txlv_rec.current_units;

   --asset_type_rec info
   l_asset_type_rec.asset_type := p_asdt_rec.asset_type;

   --asset_cat_rec_info
   l_asset_cat_rec.category_id  := p_asdt_rec.asset_category_id;

   --asset_fin_rec
   l_asset_fin_rec.date_placed_in_service := p_asdt_rec.date_placed_in_service;
   l_asset_fin_rec.deprn_method_code := p_asdt_rec.deprn_method_code;
   l_asset_fin_rec.life_in_months    := p_asdt_rec.life_in_months;
   l_asset_fin_rec.cost              := p_txlv_rec.depreciation_cost;
   l_asset_fin_rec.original_cost     := p_txlv_rec.original_cost;
   l_asset_fin_rec.prorate_convention_code := p_asdt_rec.prorate_convention_code;
   l_asset_fin_rec.depreciate_flag   := p_asdt_rec.depreciate_flag;
   l_asset_fin_rec.itc_amount_id     := p_asdt_rec.itc_amount_id;
   l_asset_fin_rec.basic_rate        := p_asdt_rec.basic_rate;
   l_asset_fin_rec.adjusted_rate     := p_asdt_rec.adjusted_rate;
   l_asset_fin_rec.bonus_rule        := p_asdt_rec.bonus_rule;
   l_asset_fin_rec.ceiling_name        := p_asdt_rec.ceiling_name;
   l_asset_fin_rec.production_capacity := p_asdt_rec.production_capacity;
   l_asset_fin_rec.unit_of_measure := p_asdt_rec.unit_of_measure;
   l_asset_fin_rec.reval_ceiling := p_asdt_rec.reval_ceiling;
   l_asset_fin_rec.unrevalued_cost := p_asdt_rec.unrevalued_cost*p_split_factor;
   l_asset_fin_rec.short_fiscal_year_flag := p_asdt_rec.short_fiscal_year_flag;
   l_asset_fin_rec.conversion_date := p_asdt_rec.conversion_date;
   l_asset_fin_rec.orig_deprn_start_date := p_asdt_rec.original_deprn_start_date;
   l_asset_fin_rec.group_asset_id := p_asdt_rec.group_asset_id;

   -- asset_deprn_rec
   IF p_asdt_rec.book_class ='CORPORATE' THEN
   -- All depreciation information is zero
   -- because when asset cost is adjusted to zero
   -- any depreciation taken is reversed and
   -- an entry is passed for the same. We do not
   -- want this to happen as technically no
   -- depreciation was taken.
     l_asset_deprn_rec.ytd_deprn           :=0;
     l_asset_deprn_rec.deprn_reserve       :=0;
     l_asset_deprn_rec.reval_deprn_reserve :=0;
   ELSIF p_asdt_rec.book_class = 'TAX' THEN
     SELECT deprn_reserve*p_split_factor,
            deprn_reserve*p_split_factor,
            reval_deprn_expense*p_split_factor
     INTO   l_asset_deprn_rec.ytd_deprn,
            l_asset_deprn_rec.deprn_reserve,
            l_asset_deprn_rec.reval_deprn_reserve
     FROM   okx_ast_dprtns_v
     WHERE  asset_id = p_asdt_rec.asset_id
     AND    book_type_code = p_asdt_rec.book_type_code
     AND    deprn_run_date = (SELECT max(deprn_run_date)
                              FROM   okx_ast_dprtns_v
                              WHERE  asset_id = p_asdt_rec.asset_id
                              AND    book_type_code = p_asdt_rec.book_type_code);

   END IF;

   --asset_dist_rec
   -- no need to prortae again as it has already been done while creating txd
   select p_txdv_rec.quantity,
          assigned_to,
          code_combination_id,
          location_id
   into   l_asset_dist_rec.units_assigned,
          l_asset_dist_rec.assigned_to,
          l_asset_dist_rec.expense_ccid,
          l_asset_dist_rec.location_ccid
   from   okx_ast_dst_hst_v
   where  asset_id = p_asdt_rec.asset_id
   and    book_type_code = p_txlv_rec.corporate_book
   and    transaction_header_id_out is null
   and    retirement_id is not null
   and    rownum < 2;

   l_asset_dist_tbl(1) := l_asset_dist_rec;

   -- call the api
   fa_addition_pub.do_addition
      (p_api_version             => 1.0,
       p_init_msg_list           => OKL_API.G_FALSE,
       p_commit                  => OKL_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_calling_fn              => null,
       px_trans_rec              => l_trans_rec,
       px_dist_trans_rec         => l_dist_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       px_asset_desc_rec         => l_asset_desc_rec,
       px_asset_type_rec         => l_asset_type_rec,
       px_asset_cat_rec          => l_asset_cat_rec,
       px_asset_hierarchy_rec    => l_asset_hierarchy_rec,
       px_asset_fin_rec          => l_asset_fin_rec,
       px_asset_deprn_rec        => l_asset_deprn_rec,
       px_asset_dist_tbl         => l_asset_dist_tbl,
       px_inv_tbl                => l_inv_tbl
      );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     x_asset_hdr_rec := l_asset_hdr_rec;
     OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
   EXCEPTION
   WHEN OKL_API.G_EXCEPTION_ERROR THEN
   x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
   WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
   x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
   WHEN OTHERS THEN
   x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END CREATE_FIXED_ASSET;

--------------------------------------------------------------------------------
--Start of Comments
--Procedure Name : ADJUST_FIXED_ASSET
--Description    : Calls FA adJUSTMENTS api to adjust the book costs
--History        :
--                 29-Apr-2002  Shri Iyer Created
-- Notes        :
-- IN Parameters
--               p_asset_id  - asset for which cost is to be adjusted
--               p_book_type_code - Book in whic cost cost is to be adjusted
--               p_adjust_cost    - cost to be adjusted
-- OUT Parameters
--               x_asset_fin_rec - asset financial info record with adjusted
--                                 costs
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE ADJUST_FIXED_ASSET(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_asset_id       IN  NUMBER,
                                p_book_type_code IN  OKL_LIKE_KIND_EXCHANGE_V.BOOK_TYPE_CODE%TYPE,
                                p_adjust_cost    IN  NUMBER,
                                x_asset_fin_rec  OUT NOCOPY FA_API_TYPES.asset_fin_rec_type) IS


  l_api_name             CONSTANT varchar2(30) := 'ADJUST_FIXED_ASSET';
  l_api_version          CONSTANT NUMBER := 1.0;
  l_trans_rec               FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec           FA_API_TYPES.asset_hdr_rec_type;
  l_asset_fin_rec_adj       FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new       FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_mrc_tbl_new   FA_API_TYPES.asset_fin_tbl_type;
  l_inv_trans_rec           FA_API_TYPES.inv_trans_rec_type;
  l_inv_tbl                 FA_API_TYPES.inv_tbl_type;
  l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
  l_inv_rec                 FA_API_TYPES.inv_rec_type;
  l_asset_deprn_rec         FA_API_TYPES.asset_deprn_rec_type;
  l_group_recalss_option_rec FA_API_TYPES.group_reclass_options_rec_type;
  l_asset_id               NUMBER := p_asset_id;
  l_book_type_code         OKL_LIKE_KIND_EXCHANGE_V.BOOK_TYPE_CODE%TYPE := p_book_type_code;
  l_adjust_cost            NUMBER := p_adjust_cost;
BEGIN
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
  -- Check if activity started successfully
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- FA_SRVR_MSG.Init_Server_Message;
  -- FA_DEBUG_PKG.Initialize;

  -- asset header info
  l_asset_hdr_rec.asset_id       := l_asset_id ;
  l_asset_hdr_rec.book_type_code := l_book_type_code;

  -- trans struct
  l_trans_rec.transaction_type_code := G_ADJ_TRX_TYPE_CODE;

  -- fin info
  l_asset_fin_rec_adj.cost := l_adjust_cost;

  FA_ADJUSTMENT_PUB.do_adjustment
      (p_api_version             => p_api_version,
       p_init_msg_list           => p_init_msg_list,
       p_commit                  => FND_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => x_return_status,
       x_msg_count               => x_msg_count,
       x_msg_data                => x_msg_data,
       p_calling_fn              => l_api_name,
       px_trans_rec              => l_trans_rec,
       px_asset_hdr_rec          => l_asset_hdr_rec,
       p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
       x_asset_fin_rec_new       => l_asset_fin_rec_new,
       x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
       px_inv_trans_rec          => l_inv_trans_rec,
       px_inv_tbl                => l_inv_tbl,
       p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
       x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
       x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
       p_group_reclass_options_rec => l_group_recalss_option_rec
      );

  --dbms_output.put_line('After Call to FA ADJUST API "'||l_return_status||'"');
  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  OKL_API.END_ACTIVITY (x_msg_count,
                        x_msg_data );
EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END ADJUST_FIXED_ASSET;

-- this procedure is used create a like kind exchange transaction
PROCEDURE CREATE_LIKE_KIND_EXCHANGE(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_corporate_book       IN  VARCHAR2
             ,p_tax_book             IN  VARCHAR2
             ,p_comments             IN  VARCHAR2
			 ,p_rep_asset_rec        IN  rep_asset_rec_type
             ,p_req_asset_tbl        IN  req_asset_tbl_type)

IS
  -- constants
  l_api_name               CONSTANT VARCHAR2(50) := 'CREATE_LIKE_KIND_EXCHANGE';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_tas_type               CONSTANT OKL_TRX_ASSETS.TAS_TYPE%TYPE    := 'LKE';
  l_tal_type               CONSTANT OKL_TXL_ASSETS_V.TAL_TYPE%TYPE    := 'LKE';
  l_tsu_code               CONSTANT OKL_TRX_CONTRACTS.TSU_CODE%TYPE := 'PROCESSED';
  l_try_name               CONSTANT OKL_TRX_TYPES_V.NAME%TYPE         := 'Like Kind Exchange';
  --variables
  l_return_status          VARCHAR2(1)   := OKL_API.G_RET_STS_SUCCESS;
  l_try_id                 OKL_TRX_TYPES_V.ID%TYPE;
  l_sysdate                DATE := SYSDATE;
  l_total_match_amount     NUMBER := 0;
  l_line_number            NUMBER := 1;
  l_adjust_cost            NUMBER := 0;
  l_balance_match          NUMBER := 0;
  l_balance_sale_proceeds  NUMBER := 0;
  l_fa_location_id         NUMBER;
  l_split_factor           NUMBER;
  l_cat_bk_exists          VARCHAR2(1) :='?';
  l_ast_bk_exists          VARCHAR2(1) :='?';
  l_mass_cpy_book          VARCHAR2(1) :='?';
  l_match_amount_found     VARCHAR2(1) := 'N';
  -- record and table structure variables
  l_req_asset_tbl          req_asset_tbl_type;
  l_tasv_rec               OKL_TRX_ASSETS_PUB.thpv_rec_type;
  l_talv_rec               OKL_TXL_ASSETS_PUB.tlpv_rec_type;
  l_txdv_rec               OKL_TXD_ASSETS_PUB.adpv_rec_type;
  x_tasv_rec               OKL_TRX_ASSETS_PUB.thpv_rec_type;
  x_talv_rec               OKL_TXL_ASSETS_PUB.tlpv_rec_type;
  x_txdv_rec               OKL_TXD_ASSETS_PUB.adpv_rec_type;
  l_asdt_rec               asset_details_rec_type;
  l_txdt_rec               asset_details_rec_type;
  l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
  l_asset_fin_rec          FA_API_TYPES.asset_fin_rec_type;

  -- cursor to get transaction type id
  CURSOR trx_types_csr IS
  SELECT id
  FROM OKL_TRX_TYPES_TL
  WHERE NAME = l_try_name
  AND LANGUAGE = 'US';

  -- cursor to get relinquished asset corporate details
  CURSOR get_asset_corp_details_csr(p_asset_id OKL_LIKE_KIND_EXCHANGE_V.ASSET_ID%TYPE
                                   ,p_book_type_code OKL_LIKE_KIND_EXCHANGE_V.BOOK_TYPE_CODE%TYPE) IS
  SELECT *
  FROM OKL_LIKE_KIND_EXCHANGE_V
  WHERE ASSET_ID = p_asset_id
  AND BOOK_TYPE_CODE = p_book_type_code;

  -- cursor to get relinquished asset tax details
  CURSOR get_asset_tax_details_csr(p_asset_id OKL_LIKE_KIND_EXCHANGE_V.ASSET_ID%TYPE
                                    ,p_book_type_code OKL_LIKE_KIND_EXCHANGE_V.BOOK_TYPE_CODE%TYPE) IS
  SELECT *
  FROM OKL_LIKE_KIND_EXCHANGE_V
  WHERE ASSET_ID = p_asset_id
  AND BOOK_TYPE_CODE = p_book_type_code;

  --Cursor to chk book validity for an asset category
  CURSOR chk_cat_bk_csr(p_book_type_code IN VARCHAR2,
                        p_category_id    IN NUMBER) is
  SELECT 'F'
  FROM   OKX_AST_CAT_BKS_V
  WHERE  CATEGORY_ID = p_category_id
  AND    BOOK_TYPE_CODE = p_book_type_code
  AND    STATUS = 'A';

  --Cursor to check if asset_id already exists in tax_book
  CURSOR chk_ast_bk_csr(p_book_type_code IN Varchar2,
                        p_asset_id       IN Number) is
  SELECT 'F'
  FROM   OKX_AST_BKS_V
  WHERE  asset_id = p_asset_id
  AND    book_type_code = p_book_type_code
  AND    status = 'A';

  --Cursor chk if corp book is the mass copy source book
  CURSOR chk_mass_cpy_book(p_corp_book IN Varchar2,
                           p_tax_book  IN Varchar2) is
  SELECT 'F'
  FROM   OKX_ASST_BK_CONTROLS_V
  WHERE  book_type_code = p_tax_book
  AND    book_class = 'TAX'
  AND    mass_copy_source_book = p_corp_book
  AND    allow_mass_copy = 'YES'
  AND    copy_additions_flag = 'YES';

  --Cursor to fetch the contract number for a given line_id
  CURSOR get_contract_number_csr(p_kle_id NUMBER)
  IS
  SELECT CHR.CONTRACT_NUMBER
  FROM OKC_K_HEADERS_B CHR,
       OKC_K_LINES_B CLE
  WHERE CLE.DNZ_CHR_ID = CHR.ID
  AND CLE.ID = p_kle_id;

  get_contract_number_rec          get_contract_number_csr%ROWTYPE;
  l_legal_entity_id                NUMBER;

BEGIN
  l_return_status := OKL_API.START_ACTIVITY(l_api_name
                                           ,G_PKG_NAME
                                           ,p_init_msg_list
                                           ,l_api_version
                                           ,p_api_version
                                           ,'_PVT'
                                           ,l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  --perform necessary validations
  -- validate corporate book
  IF (p_corporate_book IS NULL OR p_corporate_book = OKL_API.G_MISS_CHAR) THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                        p_msg_name		=> 'OKL_LKE_CORP_BOOK_ERROR');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- validate tax book
  IF (p_tax_book IS NULL OR p_tax_book = OKL_API.G_MISS_CHAR) THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                        p_msg_name		=> 'OKL_LKE_TAX_BOOK_ERROR');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- validate asset category
  IF (p_rep_asset_rec.asset_category_id IS NULL
      OR p_rep_asset_rec.asset_category_id = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                        p_msg_name		=> 'OKL_LKE_AST_CAT_ERROR');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- validate replacement asset id
  IF (p_rep_asset_rec.rep_asset_id IS NULL
      OR p_rep_asset_rec.rep_asset_id = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
 	                    p_msg_name		=> 'OKL_LKE_REP_ASSET_ID_ERROR');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- validate replacement assets current cost
  IF (p_rep_asset_rec.current_cost IS NULL
      OR p_rep_asset_rec.current_cost = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                        p_msg_name		=> 'OKL_LKE_CURR_COST_ERROR',
                        p_token1       => 'ASSET_NUMBER',
						p_token1_value => p_rep_asset_rec.rep_asset_number);
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- validate req asset id
  IF p_req_asset_tbl.COUNT = 0 THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                        p_msg_name		=> 'OKL_LKE_REQ_ASSET_ID_ERROR');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSE
    FOR i IN p_req_asset_tbl.FIRST..p_req_asset_tbl.LAST
    LOOP
      IF (p_req_asset_tbl(i).match_amount IS NOT NULL
          AND p_req_asset_tbl(i).match_amount <> 0) THEN
        l_match_amount_found := 'Y';
		l_total_match_amount := l_total_match_amount + p_req_asset_tbl(i).match_amount;
      END IF;
    END LOOP;
  END IF;
  l_req_asset_tbl := p_req_asset_tbl;

  IF l_match_amount_found = 'Y' THEN
    IF l_total_match_amount > p_rep_asset_rec.current_cost THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                           p_msg_name		=> 'OKL_LKE_MATCH_AMT_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  ELSE
    -- automatch
    l_balance_match := p_rep_asset_rec.current_cost;
    FOR i IN l_req_asset_tbl.FIRST..l_req_asset_tbl.LAST
	LOOP
      IF l_balance_match > 0 THEN
        l_balance_sale_proceeds := l_req_asset_tbl(i).balance_sale_proceeds;
        IF l_balance_sale_proceeds >= l_balance_match THEN
          l_req_asset_tbl(i).match_amount := l_balance_match;
          l_balance_match := 0;
        ELSE
          l_req_asset_tbl(i).match_amount := l_balance_sale_proceeds;
          l_balance_match := l_balance_match - l_balance_sale_proceeds;
        END IF;
      ELSE
	    l_req_asset_tbl.DELETE(i);
	  END IF;
    END LOOP;
  END IF;

  IF l_balance_match = p_rep_asset_rec.current_cost THEN
    OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                        p_msg_name		=> 'OKL_LKE_AUTO_MATCH_ERROR');
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- retrieve the transaction type id
  OPEN trx_types_csr;
  FETCH trx_types_csr INTO l_try_id;
  IF trx_types_csr%NOTFOUND THEN
    CLOSE trx_types_csr;
    -- store SQL error message on message stack for caller
    Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_AGN_TRX_TYPE_ERROR',
    					p_token1       => 'TRANSACTION_TYPE',
						p_token1_value => l_try_name);
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;
  CLOSE trx_types_csr;

  -- create relinquished trx header
  FOR i IN l_req_asset_tbl.FIRST..l_req_asset_tbl.LAST
  LOOP
    -- get relinquished asset corporate details
    OPEN get_asset_corp_details_csr (l_req_asset_tbl(i).req_asset_id, p_corporate_book);
    FETCH get_asset_corp_details_csr INTO l_asdt_rec;
    IF get_asset_corp_details_csr%NOTFOUND THEN
      CLOSE get_asset_corp_details_csr;
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_LKE_ASSET_DTLS_ERROR',
                          p_token1       => 'ASSET_NUMBER',
                          p_token1_value => l_req_asset_tbl(i).req_asset_number,
						  p_token2       => 'CORP_BOOK',
						  p_token2_value => p_corporate_book);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_asset_corp_details_csr;

    -- get relinquished asset tax details
    OPEN get_asset_tax_details_csr (l_req_asset_tbl(i).req_asset_id, p_tax_book);
    FETCH get_asset_tax_details_csr INTO l_txdt_rec;
    IF get_asset_tax_details_csr%NOTFOUND THEN
      CLOSE get_asset_tax_details_csr;
      -- store SQL error message on message stack for caller
      Okl_Api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_LKE_AST_TAX_DTLS_ERROR',
                          p_token1       => 'ASSET_NUMBER',
                          p_token1_value => l_req_asset_tbl(i).req_asset_number,
						  p_token2       => 'TAX_BOOK',
						  p_token2_value => p_tax_book);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE get_asset_tax_details_csr;

    -- calculate split factor
    l_split_factor := l_req_asset_tbl(i).match_amount/l_txdt_rec.proceeds_of_sale;

    -- populate the transaction header record
    l_tasv_rec.req_asset_id := l_req_asset_tbl(i).req_asset_id;
	l_tasv_rec.tas_type := l_tas_type;
	l_tasv_rec.tsu_code := l_tsu_code;
    l_tasv_rec.try_id   := l_try_id;
    l_tasv_rec.date_trans_occurred := l_sysdate;
    l_tasv_rec.comments := p_comments;
    l_tasv_rec.total_match_amount := l_req_asset_tbl(i).match_amount;
    --Added by kthiruva for bug 5581186 - LE Uptake project

    l_legal_entity_id   := okl_legal_entity_util.get_khr_line_le_id(l_asdt_rec.kle_id);
    IF  l_legal_entity_id IS NOT NULL THEN
       l_tasv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        OPEN get_contract_number_csr(l_asdt_rec.kle_id);
        FETCH get_contract_number_csr INTO get_contract_number_rec;
        CLOSE get_contract_number_csr;

        Okl_Api.set_message( p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			                 p_token1           =>  'CONTRACT_NUMBER',
			                 p_token1_value  =>  get_contract_number_rec.contract_number);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- call the trx assets public api to create transaction header record
    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => l_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => l_tasv_rec,
                       x_thpv_rec       => x_tasv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TRX_CRE_ERROR');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TRX_CRE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- populate the transaction line record
    l_talv_rec.tas_id                := x_tasv_rec.id;
    l_talv_rec.line_number           := l_line_number;
    l_talv_rec.tal_type              := l_tal_type;
    l_return_status := Get_Fa_Location(l_req_asset_tbl(i).req_asset_id,
                                       p_corporate_book,
                                       l_fa_location_id);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_AST_LOC_ERROR',
                          p_token1          => 'ASSET_NUMBER',
                          p_token1_value    => l_req_asset_tbl(i).req_asset_number);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_AST_LOC_ERROR',
                          p_token1          => 'ASSET_NUMBER',
                          p_token1_value    => l_req_asset_tbl(i).req_asset_number);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_talv_rec.fa_location_id        := l_fa_location_id;
    l_talv_rec.original_cost         := l_asdt_rec.original_cost*l_split_factor;
    l_talv_rec.current_units         := l_asdt_rec.current_units;
    l_talv_rec.manufacturer_name     := l_asdt_rec.manufacturer_name;

    IF l_asdt_rec.new_used = 'NEW' THEN
      l_talv_rec.used_asset_yn := 'Y';
    ELSIF l_asdt_rec.new_used = 'USED' THEN
      l_talv_rec.used_asset_yn := 'N';
    END IF;
    l_talv_rec.model_number          := l_asdt_rec.model_number;
    l_talv_rec.corporate_book        := p_corporate_book;
    l_talv_rec.in_service_date       := l_asdt_rec.date_placed_in_service;
    l_talv_rec.life_in_months        := l_asdt_rec.life_in_months;
    l_talv_rec.depreciation_id       := l_asdt_rec.asset_category_id;
    l_talv_rec.depreciation_cost     := l_asdt_rec.cost_retired*l_split_factor;
    l_talv_rec.deprn_method          := l_asdt_rec.deprn_method_code;
    l_talv_rec.deprn_rate            := l_asdt_rec.basic_rate;
    l_talv_rec.rep_asset_id          := p_rep_asset_rec.rep_asset_id;
    l_talv_rec.match_amount          := l_req_asset_tbl(i).match_amount;
    l_talv_rec.description           := p_comments;
    l_talv_rec.kle_id                := l_asdt_rec.kle_id;
    SELECT 'OKL'||OKL_FAN_SEQ.NEXTVAL INTO l_talv_rec.asset_number FROM DUAL;

    -- call the trx assets public api to create transaction header record
    OKL_TXL_ASSETS_PUB.create_txl_asset_Def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => l_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => l_talv_rec,
                       x_tlpv_rec       => x_talv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TXL_CRE_ERROR');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TXL_CRE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- populate the tax book detail record
    l_txdv_rec.tal_id              := x_talv_rec.id;
    l_txdv_rec.line_detail_number  := l_line_number;
    l_txdv_rec.quantity            := l_txdt_rec.current_units;
    l_txdv_rec.cost                := l_txdt_rec.cost_retired*l_split_factor;
    l_txdv_rec.tax_book            := p_tax_book;
    l_txdv_rec.life_in_months_tax  := l_txdt_rec.life_in_months;
    l_txdv_rec.deprn_method_tax    := l_txdt_rec.deprn_method_code;
    l_txdv_rec.deprn_rate_tax      := l_txdt_rec.adjusted_rate;
    l_txdv_rec.asset_number        := l_talv_rec.asset_number;

    --call the txd details API
    OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => l_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_adpv_rec       => l_txdv_rec,
                       x_adpv_rec       => x_txdv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TXD_CRE_ERROR');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TXD_CRE_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --check for category-id book type code validity
    OPEN chk_cat_bk_csr(p_book_type_code => x_talv_rec.corporate_book,
                        p_category_id    => x_talv_rec.depreciation_id);
    FETCH chk_cat_bk_csr into l_cat_bk_exists;
    IF chk_cat_bk_csr%NOTFOUND THEN
      NULL;
    END IF;
    CLOSE chk_cat_bk_csr;
    IF l_cat_bk_exists = '?' THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => G_FA_INVALID_BK_CAT,
                          p_token1       => G_FA_BOOK,
                          p_token1_value => l_talv_rec.corporate_book,
                          p_token2       => G_ASSET_CATEGORY,
                          p_token2_value => to_char(l_talv_rec.depreciation_id)
                         );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSE
      CREATE_FIXED_ASSET(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_split_factor  => l_split_factor,
                         p_rep_asset_rec => p_rep_asset_rec,
                         p_asdt_rec      => l_asdt_rec,
                         p_txlv_rec      => x_talv_rec,
                         p_txdv_rec      => x_txdv_rec,
                         x_asset_hdr_rec => l_asset_hdr_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                            p_msg_name		=> 'OKL_LKE_FA_CRE_ERROR',
                            p_token1        => 'CORP_BOOK',
                            p_token1_value  => p_corporate_book);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                            p_msg_name		=> 'OKL_LKE_FA_CRE_ERROR',
                            p_token1        => 'CORP_BOOK',
                            p_token1_value  => p_corporate_book);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- create asset in tax book
      l_cat_bk_exists := '?';
      OPEN chk_cat_bk_csr(p_book_type_code => x_txdv_rec.tax_book,
                          p_category_id    => x_talv_rec.depreciation_id);
      FETCH chk_cat_bk_csr INTO l_cat_bk_exists;
      IF chk_cat_bk_csr%NOTFOUND THEN
        NULL;
      END IF;
      CLOSE chk_cat_bk_csr;
      IF l_cat_bk_exists = '?' THEN
        --raise appropriate error
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
	                        p_msg_name     => G_FA_INVALID_BK_CAT,
                            p_token1       => G_FA_BOOK,
                            p_token1_value => x_txdv_rec.tax_book,
                            p_token2       => G_ASSET_CATEGORY,
                            p_token2_value => to_char(x_talv_rec.depreciation_id)
	                       );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSE
        --check if asset already exists in tax book
        l_ast_bk_exists := '?';
        OPEN chk_ast_bk_csr(p_book_type_code => x_txdv_rec.tax_book,
                            p_asset_id       => l_asset_hdr_rec.asset_id);
        FETCH chk_ast_bk_csr INTO l_ast_bk_exists;
        IF chk_ast_bk_csr%NOTFOUND THEN
          NULL;
        END IF;
        CLOSE chk_ast_bk_csr;
        IF l_ast_bk_exists = 'F' THEN --asset already exists in tax book
          NULL; --do not have to add again
        ELSE
          --chk if corp book is the mass copy book for the tax book
          l_mass_cpy_book := '?';
          OPEN chk_mass_cpy_book(p_corp_book => x_talv_rec.corporate_book,
                                 p_tax_book  => x_txdv_rec.tax_book);
          FETCH chk_mass_cpy_book INTO l_mass_cpy_book;
          IF chk_mass_cpy_book%NOTFOUND THEN
            NULL;
          END IF;
          CLOSE chk_mass_cpy_book;
          IF l_mass_cpy_book = '?' THEN
            --can not mass copy into tax book
            OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                                p_msg_name     => G_FA_TAX_CPY_NOT_ALLOWED,
                                p_token1       => G_FA_BOOK,
                                p_token1_value => x_txdv_rec.tax_book
                               );
            RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSE
            --can masscopy, create asset
            CREATE_FIXED_ASSET(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => l_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_split_factor  => l_split_factor,
				        			p_rep_asset_rec => p_rep_asset_rec,
                                    p_asdt_rec      => l_txdt_rec,
                                    p_txlv_rec      => l_talv_rec,
                                    p_txdv_rec      => l_txdv_rec,
                                    x_asset_hdr_rec => l_asset_hdr_rec);
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                                  p_msg_name		=> 'OKL_LKE_FA_TAX_CRE_ERROR',
                                  p_token1          => 'TAX_BOOK',
                                  p_token1_value    => p_tax_book);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                                  p_msg_name		=> 'OKL_LKE_FA_TAX_CRE_ERROR',
                                  p_token1          => 'TAX_BOOK',
                                  p_token1_value    => p_tax_book);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF; --can mass copy into tax book
        END IF; -- asset does not exist in tax book
      END IF; -- valid tax book for category
    END IF;

    --Tie back new asset records to OKL
    l_talv_rec := x_talv_rec;
    -- populate record with updated information
	l_talv_rec.lke_asset_id := l_asset_hdr_rec.asset_id;
	x_talv_rec := NULL;
    OKL_TXL_ASSETS_PUB.update_txl_asset_Def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => l_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => l_talv_rec,
                       x_tlpv_rec       => x_talv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TIE_BACK_ERROR');
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_TIE_BACK_ERROR');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Adjust the cost of the LKE asset in corp books to zero as we do not
	-- want it to depreciate
    l_adjust_cost := (-1) * x_talv_rec.depreciation_cost;
    -- to_make asset cost zero
    ADJUST_FIXED_ASSET
            (p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_asset_id       => l_asset_hdr_rec.asset_id,
             p_book_type_code => l_asdt_rec.book_type_code,
             p_adjust_cost    => l_adjust_cost,
             x_asset_fin_rec  => l_asset_fin_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_AST_ADJ_ERROR',
                          p_token1          => 'CORP_BOOK',
                          p_token1_value    => p_corporate_book);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_AST_ADJ_ERROR',
                          p_token1          => 'CORP_BOOK',
                          p_token1_value    => p_corporate_book);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Adjust the cost of the Replacement asset in corp books less the cost of the LKE Asset
    l_adjust_cost :=0;
    l_adjust_cost := (-1) * x_talv_rec.match_amount;
    -- to_make asset cost zero
    ADJUST_FIXED_ASSET
            (p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_asset_id       => p_rep_asset_rec.rep_asset_id,
             p_book_type_code => p_tax_book,
             p_adjust_cost    => l_adjust_cost,
             x_asset_fin_rec  => l_asset_fin_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_REP_AST_ADJ_ERROR',
                          p_token1          => 'ASSET_NUMBER',
                          p_token1_value    => l_req_asset_tbl(i).req_asset_number,
                          p_token2          => 'CORP_BOOK',
                          p_token2_value    => p_corporate_book);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
                          p_msg_name		=> 'OKL_LKE_REP_AST_ADJ_ERROR',
                          p_token1          => 'ASSET_NUMBER',
                          p_token1_value    => l_req_asset_tbl(i).req_asset_number,
                          p_token2          => 'CORP_BOOK',
                          p_token2_value    => p_corporate_book);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END LOOP;
  -- set the return status
  x_return_status := l_return_status;

  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
  -- bug 2404937. Message was being appeneded with the following text:
  -- User defined exception in package <name> procedure <name>
  -- This was because OKL_API was Okl_Api (everything needs to be caps)
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
    x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN OTHERS THEN
    x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
                               (l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');

END CREATE_LIKE_KIND_EXCHANGE;

END OKL_LIKE_KIND_EXCHANGE_PVT;

/
