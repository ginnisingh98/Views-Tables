--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_RELOCATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_RELOCATION_PVT" AS
/* $Header: OKLRAREB.pls 120.5 2005/12/29 22:05:58 sechawla noship $ */




  SUBTYPE transaction_rec		    IS csi_datastructures_pub.transaction_rec;

  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Relocate_Installed_item
  -- Description     : This procedure is used to relocate an asset in Installed Base
  -- Business Rules  :
  -- Parameters      :  p_ialo_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------

  PROCEDURE Relocate_Installed_Item
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_ialo_tbl                     IN  ialo_tbl_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_loop_counter                 NUMBER :=0;

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);
    IF (p_ialo_tbl.COUNT > 0) THEN

      l_loop_counter  := p_ialo_tbl.FIRST;
      LOOP

         IF  p_ialo_tbl(l_loop_counter).p_instance_id IS NULL OR
             p_ialo_tbl(l_loop_counter).p_instance_id = OKL_API.G_MISS_NUM THEN

             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- asset_id is required
             OKC_API.set_message(    p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'INSTANCE_ID');
             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         IF  p_ialo_tbl(l_loop_counter).p_location_id IS NULL OR
             p_ialo_tbl(l_loop_counter).p_location_id = OKL_API.G_MISS_NUM THEN

             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- asset_id is required
             OKC_API.set_message(    p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'LOCATION_ID');
             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         change_item_location (p_api_version => p_api_version,
							   	                p_init_msg_list		=> p_init_msg_list,
							  	                x_msg_count        	=> x_msg_count,
								                x_msg_data			=> x_msg_data,
								                x_return_status		=> x_return_status,
								                p_instance_id		=> p_ialo_tbl(l_loop_counter).p_instance_id,
								                p_location_id		=> p_ialo_tbl(l_loop_counter).p_location_id,
								                p_install_location_id	=> p_ialo_tbl(l_loop_counter).p_install_location_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        EXIT WHEN (l_loop_counter  = p_ialo_tbl.LAST);
        l_loop_counter  := p_ialo_tbl.NEXT(l_loop_counter );

      END LOOP;

    END IF;
    x_return_status := l_return_status;

  EXCEPTION

   WHEN OTHERS THEN
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Relocate_Installed_Item;



  ----------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Relocate_Fixed_Asset
  -- Description     : This procedure is used to relocate an asset in FA
  -- Business Rules  :
  -- Parameters      :  p_falo_tbl
  -- Version         : 1.0
  -- End of comments
  ----------------------------------------------------------------------------------

  PROCEDURE Relocate_Fixed_Asset
    ( p_api_version                  IN  NUMBER
    , p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    , x_return_status                OUT NOCOPY VARCHAR2
    , x_msg_count                    OUT NOCOPY NUMBER
    , x_msg_data                     OUT NOCOPY VARCHAR2
    , p_falo_tbl                     IN  falo_tbl_type) IS

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_asset_status                 VARCHAR2(100);

  BEGIN

    OKC_API.init_msg_list(p_init_msg_list);

    Change_FA_Location (   p_api_version		=> p_api_version,
							   	                p_init_msg_list		=> p_init_msg_list,
							  	                x_msg_count        	=> x_msg_count,
								                x_msg_data			=> x_msg_data,
								                x_return_status		=> x_return_status,
                                                p_assets_tbl        => p_falo_tbl );


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

   WHEN OTHERS THEN
        Okl_api.set_message( p_app_name      => g_app_name
                           , p_msg_name      => g_unexpected_error
                           , p_token1        => g_sqlcode_token
                           , p_token1_value  => SQLCODE
                           , p_token2        => g_sqlerrm_token
                           , p_token2_value  => SQLERRM
                           ) ;
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END Relocate_Fixed_Asset;

  ---------------------------------------------------------------------------
    -- Start of comments
  --
  -- Procedure Name  : Change_FA_Location
  -- Description     : This procedure is used to relocate an asset in FA
  -- Business Rules  :
  -- Parameters      :  p_assets_tbl
  -- Version         : 1.0
  -- History         : sechawla 19-dec-2005 4895439 : Raise an exception and
  --                   set return status to 'E' if location change can not be
  --                   performed
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Change_FA_Location(
                                p_api_version           IN  	NUMBER,
           			            p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
           		 	            x_return_status         OUT 	NOCOPY VARCHAR2,
           			            x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
                                p_assets_tbl            IN      falo_tbl_type )    IS

   SUBTYPE   thpv_rec_type   IS  okl_trx_assets_pub.thpv_rec_type;
   SUBTYPE   tlpv_rec_type   IS  okl_txl_assets_pub.tlpv_rec_type;

   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;

   l_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name                   CONSTANT VARCHAR2(30) := 'Change_FA_Location';

   l_original_cost              okl_txl_assets_v.original_cost%TYPE;



   l_tsu_code                   VARCHAR2(30);

   l_try_id  			        okl_trx_types_v.id%TYPE;
   lp_thpv_rec                  thpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   lp_tlpv_rec			        tlpv_rec_type;
   lx_tlpv_rec			        tlpv_rec_type;
   i                            NUMBER;
   l_ret                        VARCHAR2(1);
   l_count_source               NUMBER := 0;
   l_count_tax                  NUMBER := 0;
   l_api_version                CONSTANT NUMBER := 1;
   l_sysdate                    DATE;



   --   This cursor is used to validate the new location Id
   CURSOR l_location_csr(p_location_id NUMBER, p_sysdate DATE) IS
   SELECT 'x'
   FROM   fa_locations
   WHERE  location_id = p_location_id
   AND    enabled_flag = 'Y'
   AND    p_sysdate BETWEEN NVL(START_DATE_ACTIVE,p_sysdate) AND NVL(END_DATE_ACTIVE,p_sysdate);

   -- This cursor is used to get all the tax books for an asset
   CURSOR l_taxbooks_csr(p_source VARCHAR2) IS
   SELECT book_type_code
   FROM   fa_book_controls
   WHERE  distribution_source_book = p_source
   AND    book_class = 'TAX'
   AND    date_ineffective IS NULL;

   -- This cursor is used to check if the depreciation has alraedy been run for an asset in any of the books
   CURSOR l_deprnbookcnt_csr(p_book_type_code VARCHAR2,p_asset_id NUMBER)  IS
   SELECT count(*)
   FROM   fa_deprn_summary ds, fa_book_controls bc
   WHERE  bc.book_type_code = p_book_type_code
   AND    ds.book_type_code = bc.book_type_code
   AND    ds.period_counter = bc.last_period_counter + 1
   AND    ds.asset_id = p_asset_id
   AND    ds.deprn_source_code = 'DEPRN';



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

      SELECT SYSDATE INTO l_sysdate FROM DUAL;

      okl_am_util_pvt.get_transaction_id(p_try_name       => 'Asset Relocation',
                                         x_return_status  => x_return_status,
                                         x_try_id         => l_try_id);
       IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
            -- Unable to find a transaction type for this transaction .
            OKL_API.set_message(p_app_name    => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => 'Asset Relocation');
            RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;



      IF p_assets_tbl.COUNT > 0 THEN
         i := p_assets_tbl.FIRST;
         -- loop thru all the records in the input table, validate the data and then call FA transfer
         -- API to relocate the asset
         LOOP
            IF p_assets_tbl(i).p_cle_id IS NULL OR p_assets_tbl(i).p_cle_id = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- cle_id is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CLE_ID');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_asset_id IS NULL OR p_assets_tbl(i).p_asset_id = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- asset_id is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_ID');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_asset_number IS NULL THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- asset_number is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_NUMBER');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_corporate_book IS NULL THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- corporate_book is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CORPORATE_BOOK');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_current_units IS NULL OR p_assets_tbl(i).p_current_units = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- current_units is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CURRENT_UNITS');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_distribution_id IS NULL OR p_assets_tbl(i).p_distribution_id = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- Distribution Id is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'DISTRIBUTION_ID');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_units_assigned IS NULL OR p_assets_tbl(i).p_units_assigned = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- Units Assigned is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'UNITS_ASSIGNED');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_code_combination_id IS NULL OR p_assets_tbl(i).p_code_combination_id = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- Code Combination Id is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'CODE_COMBINATION_ID');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_old_location_id IS NULL OR p_assets_tbl(i).p_old_location_id = okl_api.G_MISS_NUM THEN

                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- Old Location Id is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'OLD_LOCATION_ID');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_new_location_id IS NULL OR p_assets_tbl(i).p_new_location_id = okl_api.G_MISS_NUM THEN
                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- New Location Id is required
                  OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'NEW_LOCATION_ID');
                  RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF p_assets_tbl(i).p_new_location_id = p_assets_tbl(i).p_old_location_id  THEN
                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- Can not create identical distributions. New Location Id should be different from the
                  -- Old Distribution Id
                  OKL_API.set_message(     p_app_name      => 'OKL',
                                           p_msg_name      => 'OKL_AM_IDENTICAL_DIST_LINES');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;

            OPEN  l_location_csr(p_assets_tbl(i).p_new_location_id, l_sysdate);
            FETCH l_location_csr INTO l_ret;

            IF l_location_csr%NOTFOUND THEN
               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- New Location Id is Invalid
               OKC_API.set_message(  p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'NEW_LOCATION_ID');
               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
            CLOSE l_location_csr;

            -- check if depreciation has already been run for this asset in the distribution_source_book
            OPEN  l_deprnbookcnt_csr(p_assets_tbl(i).p_corporate_book,p_assets_tbl(i).p_asset_id);
            FETCH l_deprnbookcnt_csr INTO l_count_source;
            CLOSE l_deprnbookcnt_csr;



            -- check if depreciation has already been run for this asset in any of the tax books
            FOR l_taxbooks_rec IN l_taxbooks_csr(p_assets_tbl(i).p_corporate_book) LOOP

               OPEN  l_deprnbookcnt_csr(l_taxbooks_rec.book_type_code,p_assets_tbl(i).p_asset_id);
               FETCH l_deprnbookcnt_csr INTO l_count_tax;
               CLOSE l_deprnbookcnt_csr;

               IF l_count_tax > 0 then
                  EXIT;
               END IF;

            END LOOP;


            IF l_count_source > 0  OR l_count_tax > 0 THEN
                    -- Store the transaction in 'Error' if depreciation has already been run for the asset in
                    -- corporate book or any of the tax books

                    -- Depreciation has already been run for the asset ASSET_NUMBER in either corporate book or
                    -- one or more tax books.  Can not perform relocation.

                    x_return_status := OKL_API.G_RET_STS_ERROR; -- sechawla 19-dec-2005 4895439 : added

                    OKL_API.set_message(   p_app_name      => 'OKL',
                                           p_msg_name      => 'OKL_AM_DEPRN_RAN_ALREADY',
                                           p_token1        => 'ASSET_NUMBER',
                                           p_token1_value  => p_assets_tbl(i).p_asset_number);

                    RAISE OKC_API.G_EXCEPTION_ERROR; -- sechawla 19-dec-2005 4895439 : added

                    -- The following code will be commented out till we add an additional column in okl_txl_assets_v
                    -- to hold distribution Id
                    /*
                    l_tsu_code := 'ERROR';

                     -- create transaction header
                    lp_thpv_rec.tas_type := 'ALG';
                    lp_thpv_rec.tsu_code := l_tsu_code;
                    lp_thpv_rec.try_id   :=  l_try_id;
                    lp_thpv_rec.date_trans_occurred := l_sysdate;
                    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => p_init_msg_list,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_thpv_rec		        => lp_thpv_rec,
						                            x_thpv_rec		        => lx_thpv_rec);

     	            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                    -- Create transaction Line
                    lp_tlpv_rec.tas_id 			        := lx_thpv_rec.id; 		-- FK
                    lp_tlpv_rec.ilo_id 			        := p_assets_tbl(i).p_new_location_id;
                    lp_tlpv_rec.ilo_id_old  	        := p_assets_tbl(i).p_old_location_id;
                    lp_tlpv_rec.kle_id 			        := p_assets_tbl(i).p_cle_id;
   	                lp_tlpv_rec.line_number 		    := 1;
                    lp_tlpv_rec.tal_type 		        := 'AGL';
                    lp_tlpv_rec.asset_number 		    := p_assets_tbl(i).p_asset_number;
                    lp_tlpv_rec.corporate_book 		    := p_assets_tbl(i).p_corporate_book;
	               -- lp_tlpv_rec.original_cost 		    := l_original_cost;
	                lp_tlpv_rec.current_units 		    := p_assets_tbl(i).p_current_units;
	                lp_tlpv_rec.dnz_asset_id		    := p_assets_tbl(i).p_asset_id;



	                OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => p_init_msg_list,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
                   */


            ELSE   -- deprn has not been run for this asset in any of the books
                  -- This piece of code needs to stay commented out till FA transfer API gets fixed

                    -- transaction information
                    l_trans_rec.transaction_type_code := 'TRANSFER';
                    l_trans_rec.transaction_date_entered := NULL;

                    --SECHAWLA 29-DEC-05 3827148 : added
      				l_trans_rec.calling_interface  := 'OKL:'||'Asset Relocation:';


                    -- header information
                    l_asset_hdr_rec.asset_id :=  p_assets_tbl(i).p_asset_id;
                    l_asset_hdr_rec.book_type_code :=  p_assets_tbl(i).p_corporate_book;
                    -- l_asset_hdr_rec.period_of_addition := null;



                    l_asset_dist_tbl.DELETE;

                    -- source distribution line
                    l_asset_dist_tbl(1).distribution_id := p_assets_tbl(i).p_distribution_id;
                    l_asset_dist_tbl(1).transaction_units :=  -(p_assets_tbl(i).p_units_assigned);

                    -- destination distribution line
                    l_asset_dist_tbl(2).transaction_units := p_assets_tbl(i).p_units_assigned;
                    l_asset_dist_tbl(2).assigned_to := p_assets_tbl(i).p_assigned_to;
                    l_asset_dist_tbl(2).expense_ccid := p_assets_tbl(i).p_code_combination_id;
                    l_asset_dist_tbl(2).location_ccid := p_assets_tbl(i).p_new_location_id;

                    FA_TRANSFER_PUB.do_transfer(  p_api_version       => p_api_version,
                                        p_init_msg_list      => p_init_msg_list,
                                        p_commit             => FND_API.G_FALSE,
                                        p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn         => NULL,
                                        x_return_status      => x_return_status,
                                        x_msg_count          => x_msg_count,
                                        x_msg_data           => x_msg_data,
                                        px_trans_rec         => l_trans_rec,
                                        px_asset_hdr_rec     => l_asset_hdr_rec,
                                        px_asset_dist_tbl    => l_asset_dist_tbl);


                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
   		               RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;




                    -- This code will be commented out until we add an additional column in okl_txl_assets_v
                    -- to hold distribution Id
                    /*
                    -- store the transaction in OKL with status = 'PROCESSED'
                    l_tsu_code := 'PROCESSED';

                    --Currently we store only one transaction on OKL for both multiple and single distribution assets

                    -- create transaction header
                    lp_thpv_rec.tas_type := 'ALG';
                    lp_thpv_rec.tsu_code := l_tsu_code;
                    lp_thpv_rec.try_id   :=  l_try_id;
                    lp_thpv_rec.date_trans_occurred := l_sysdate;
                    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => p_init_msg_list,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_thpv_rec		        => lp_thpv_rec,
						                            x_thpv_rec		        => lx_thpv_rec);

     	            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                    -- Create transaction Line
                    lp_tlpv_rec.tas_id 			        := lx_thpv_rec.id; 		-- FK
                    lp_tlpv_rec.ilo_id 			        := p_assets_tbl(i).p_new_location_id;
                    lp_tlpv_rec.ilo_id_old  	        := p_assets_tbl(i).p_old_location_id;
                    lp_tlpv_rec.kle_id 			        := p_assets_tbl(i).p_cle_id;
   	                lp_tlpv_rec.line_number 		    := 1;
                    lp_tlpv_rec.tal_type 		        := 'AGL';
                    lp_tlpv_rec.asset_number 		    := p_assets_tbl(i).p_asset_number;
                    lp_tlpv_rec.corporate_book 		    := p_assets_tbl(i).p_corporate_book;
	               -- lp_tlpv_rec.original_cost 		    := l_original_cost;
	                lp_tlpv_rec.current_units 		    := p_assets_tbl(i).p_current_units;
	                lp_tlpv_rec.dnz_asset_id		    := p_assets_tbl(i).p_asset_id;
                    --lp_tlpv_rec.dnz_khr_id 		    := p_contract_id;


	                OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
           			       		                    p_init_msg_list         => p_init_msg_list,
           					                        x_return_status         => x_return_status,
           					                        x_msg_count             => x_msg_count,
           					                        x_msg_data              => x_msg_data,
						                            p_tlpv_rec		        => lp_tlpv_rec,
						                            x_tlpv_rec		        => lx_tlpv_rec);

                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
                    */

               END IF;


           EXIT WHEN (i = p_assets_tbl.LAST);
           i := p_assets_tbl.NEXT(i);
         END LOOP;
       ELSE
         -- There were no Asset Relocation transactions to process.
         OKL_API.set_message(p_app_name           => 'OKL',
                            p_msg_name            => 'OKL_AM_NO_RELOC_TRX');
       END IF; -- if assets_tbl.count > 0

       OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
       EXCEPTION
                WHEN OKC_API.G_EXCEPTION_ERROR THEN


                IF l_location_csr%ISOPEN THEN
                   CLOSE l_location_csr;
                END IF;
                IF l_taxbooks_csr%ISOPEN THEN
                   CLOSE l_taxbooks_csr;
                END IF;
                IF l_deprnbookcnt_csr%ISOPEN THEN
                   CLOSE l_deprnbookcnt_csr;
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

                    IF l_location_csr%ISOPEN THEN
                        CLOSE l_location_csr;
                    END IF;
                    IF l_taxbooks_csr%ISOPEN THEN
                        CLOSE l_taxbooks_csr;
                    END IF;
                    IF l_deprnbookcnt_csr%ISOPEN THEN
                        CLOSE l_deprnbookcnt_csr;
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

                    IF l_location_csr%ISOPEN THEN
                        CLOSE l_location_csr;
                    END IF;
                    IF l_taxbooks_csr%ISOPEN THEN
                        CLOSE l_taxbooks_csr;
                    END IF;
                    IF l_deprnbookcnt_csr%ISOPEN THEN
                        CLOSE l_deprnbookcnt_csr;
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

  END Change_FA_Location ;


  ---------------------------------------------------------------------------
    -- Start of comments
  --
  -- Procedure Name  : initialize_txn_rec
  -- Description     : This procedure is used to initialize a transaction record
  -- Business Rules  :
  -- Parameters      :  px_txn_rec
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE initialize_txn_rec (
		px_txn_rec	IN OUT NOCOPY transaction_rec) IS
  BEGIN

	px_txn_rec.transaction_id		:= NULL;
	px_txn_rec.transaction_date		:= SYSDATE;
	px_txn_rec.source_transaction_date	:= SYSDATE;
	px_txn_rec.transaction_type_id		:= 1;
	px_txn_rec.txn_sub_type_id		:= NULL;
	px_txn_rec.source_group_ref_id		:= NULL;
	px_txn_rec.source_group_ref		:= '';
	px_txn_rec.source_header_ref_id		:= NULL;
	px_txn_rec.source_header_ref		:= '';
	px_txn_rec.source_line_ref_id		:= NULL;
	px_txn_rec.source_line_ref		:= '';
	px_txn_rec.source_dist_ref_id1		:= NULL;
	px_txn_rec.source_dist_ref_id2		:= NULL;
	px_txn_rec.inv_material_transaction_id	:= NULL;
	px_txn_rec.transaction_quantity		:= NULL;
	px_txn_rec.transaction_uom_code		:= '';
	px_txn_rec.transacted_by		:= NULL;
	px_txn_rec.transaction_status_code	:= '';
	px_txn_rec.transaction_action_code	:= '';
	px_txn_rec.message_id			:= NULL;
	px_txn_rec.context			:= '';
	px_txn_rec.attribute1			:= '';
	px_txn_rec.attribute2			:= '';
	px_txn_rec.attribute3			:= '';
	px_txn_rec.attribute4			:= '';
	px_txn_rec.attribute5			:= '';
	px_txn_rec.attribute6			:= '';
	px_txn_rec.attribute7			:= '';
	px_txn_rec.attribute8			:= '';
	px_txn_rec.attribute9			:= '';
	px_txn_rec.attribute10			:= '';
	px_txn_rec.attribute11			:= '';
	px_txn_rec.attribute12			:= '';
	px_txn_rec.attribute13			:= '';
	px_txn_rec.attribute14			:= '';
	px_txn_rec.attribute15			:= '';
	px_txn_rec.object_version_number	:= NULL;
	px_txn_rec.split_reason_code		:= '';

  END initialize_txn_rec;

   ---------------------------------------------------------------------------
    -- Start of comments
  --
  -- Procedure Name  : Change_Item_Location
  -- Description     : This procedure is used to update the item in Installed Base
  -- Business Rules  :
  -- Parameters      :  p_instance_id, p_location_id,  p_install_location_id
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------



  PROCEDURE Change_Item_Location (
		p_api_version	IN  NUMBER,
		p_init_msg_list	IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
		x_msg_count	OUT NOCOPY NUMBER,
		x_msg_data	OUT NOCOPY VARCHAR2,
		x_return_status	OUT NOCOPY VARCHAR2,
		p_instance_id	IN NUMBER,
		p_location_id	IN NUMBER,
		p_install_location_id	IN NUMBER DEFAULT NULL) IS

    SUBTYPE instance_rec			    IS csi_datastructures_pub.instance_rec;
    SUBTYPE id_tbl			        IS csi_datastructures_pub.id_tbl;
    SUBTYPE instance_query_rec	    IS csi_datastructures_pub.instance_query_rec;
    SUBTYPE party_query_rec		    IS csi_datastructures_pub.party_query_rec;
    SUBTYPE party_account_query_rec	IS csi_datastructures_pub.party_account_query_rec;
    SUBTYPE instance_header_tbl		IS csi_datastructures_pub.instance_header_tbl;
    SUBTYPE extend_attrib_values_tbl	IS csi_datastructures_pub.extend_attrib_values_tbl;
    SUBTYPE party_tbl			        IS csi_datastructures_pub.party_tbl;
    SUBTYPE party_account_tbl		    IS csi_datastructures_pub.party_account_tbl;
    SUBTYPE pricing_attribs_tbl		IS csi_datastructures_pub.pricing_attribs_tbl;
    SUBTYPE organization_units_tbl	IS csi_datastructures_pub.organization_units_tbl;
    SUBTYPE instance_asset_tbl		IS csi_datastructures_pub.instance_asset_tbl;

	-- Get Item Instance parameters
	l_instance_query_rec	instance_query_rec;
	l_party_query_rec	party_query_rec;
	l_account_query_rec	party_account_query_rec;
	l_instance_header_tbl	instance_header_tbl;

	-- Update Item Instance generic parameters
	l_instance_rec		instance_rec;
	l_txn_rec		transaction_rec;
	l_instance_id_lst	id_tbl;

	-- Update Item Instance specific parameters
	l_ext_attrib_values_tbl	extend_attrib_values_tbl;
	l_party_tbl		party_tbl;
	l_account_tbl		party_account_tbl;
	l_pricing_attrib_tbl	pricing_attribs_tbl;
	l_org_assignments_tbl	organization_units_tbl;
	l_asset_assignment_tbl	instance_asset_tbl;

	l_return_status		VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;
	l_overall_status	VARCHAR2(1)	:= OKL_API.G_RET_STS_SUCCESS;

	l_api_name		CONSTANT VARCHAR2(30) := 'change_item_location';
	l_api_version		CONSTANT NUMBER	:= G_API_VERSION;
	l_msg_count		NUMBER		:= FND_API.G_MISS_NUM;
	l_msg_data		VARCHAR2(2000);

  BEGIN

	-- ***************************************************************
	-- Check API version, initialize message list and create savepoint
	-- ***************************************************************

	l_return_status := OKL_API.START_ACTIVITY (
		l_api_name,
		G_PKG_NAME,
		p_init_msg_list,
		l_api_version,
		p_api_version,
		'_PVT',
		x_return_status);

	IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- ************************
	-- Get Item Instance record
	-- ************************

	l_instance_query_rec.instance_id	:= p_instance_id;

	csi_item_instance_pub.get_item_instances (
		p_api_version		=> l_api_version,
		p_commit		=> FND_API.G_FALSE,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
		p_instance_query_rec	=> l_instance_query_rec,
		p_party_query_rec	=> l_party_query_rec,
		p_account_query_rec	=> l_account_query_rec,
		p_transaction_id	=> NULL,
		p_resolve_id_columns	=> FND_API.G_FALSE,
		p_active_instance_only	=> FND_API.G_TRUE,
		x_instance_header_tbl	=> l_instance_header_tbl,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data);

	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	ELSIF (NVL (l_instance_header_tbl.COUNT, 0) <> 1) THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

	-- *************************************
	-- Initialize parameters to be passed in
	-- *************************************

	l_instance_rec.instance_id		:=
			l_instance_header_tbl(1).instance_id;
	l_instance_rec.object_version_number	:=
			l_instance_header_tbl(1).object_version_number;
	l_instance_rec.quantity			:=
			l_instance_header_tbl(1).quantity;

	IF (p_location_id IS NULL)
	OR (p_location_id = OKL_API.G_MISS_NUM) THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	ELSE
      -- GKADARKA - fixes for bug 3569441
        IF (l_instance_header_tbl(1).location_type_code = 'HZ_LOCATIONS') THEN
          l_instance_rec.location_id      :=  p_location_id;
       ELSIF l_instance_header_tbl(1).location_type_code = 'HZ_PARTY_SITES' THEN
          l_instance_rec.location_id      := p_install_location_id;
       END IF;
      -- GKADARKA - fixes for bug 3569441

		--l_instance_rec.location_id	:= p_location_id;
	END IF;

	IF (p_install_location_id IS NULL)
	OR (p_install_location_id = OKL_API.G_MISS_NUM) THEN
		NULL;
	ELSE
  --- GKADARKA - fixes for bug 3569441   - Start

       IF (l_instance_header_tbl(1).install_location_type_code = 'HZ_LOCATIONS') THEN
           l_instance_rec.install_location_id      :=       p_location_id;
       ELSE
           l_instance_rec.install_location_id      :=      p_install_location_id;
       END IF;
  --- GKADARKA - fixes for bug 3569441  -End
	END IF;

	initialize_txn_rec (l_txn_rec);

	-- **************************************
	-- Call Installed Base API to update item
	-- **************************************

	csi_item_instance_pub.update_item_instance (
		p_api_version		=> l_api_version,
		p_commit		=> FND_API.G_FALSE,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
		p_instance_rec		=> l_instance_rec,
		p_ext_attrib_values_tbl	=> l_ext_attrib_values_tbl,
		p_party_tbl		=> l_party_tbl,
		p_account_tbl		=> l_account_tbl,
		p_pricing_attrib_tbl	=> l_pricing_attrib_tbl,
		p_org_assignments_tbl	=> l_org_assignments_tbl,
		p_asset_assignment_tbl	=> l_asset_assignment_tbl,
		p_txn_rec		=> l_txn_rec,
		x_instance_id_lst	=> l_instance_id_lst,
		x_return_status		=> l_return_status,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_msg_data);

	IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
		RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	-- **************
	-- Return results
	-- **************

	x_return_status := l_overall_status;

	OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

  EXCEPTION

	WHEN OKL_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
			(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
			);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
		x_return_status :=OKL_API.HANDLE_EXCEPTIONS
			(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
			);

	WHEN OTHERS THEN

		x_return_status :=OKL_API.HANDLE_EXCEPTIONS
			(
			l_api_name,
			G_PKG_NAME,
			'OTHERS',
			x_msg_count,
			x_msg_data,
			'_PVT'
			);

  END Change_Item_Location;

END OKL_AM_ASSET_RELOCATION_PVT;

/
