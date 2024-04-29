--------------------------------------------------------
--  DDL for Package Body FA_CUA_HR_REINSTATEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HR_REINSTATEMENTS_PKG" as
/* $Header: FACHRINMB.pls 120.2.12010000.2 2009/07/19 12:34:00 glchen ship $ \ */

g_log_level_rec fa_api_types.log_level_rec_type;

PROCEDURE reinstate ( x_batch_num            IN NUMBER
                    , x_conc_request_id      IN NUMBER
                    , x_book_type_code       IN VARCHAR2
                    , x_retirement_date      IN DATE
                    , x_currency_code        IN VARCHAR2
                    , x_fy_start_date        IN DATE
                    , x_fy_end_date          IN DATE
                    , x_attribute_category   IN VARCHAR2
                    , x_attribute1           IN VARCHAR2
                    , x_attribute2           IN VARCHAR2
                    , x_attribute3           IN VARCHAR2
                    , x_attribute4           IN VARCHAR2
                    , x_attribute5           IN VARCHAR2
                    , x_attribute6           IN VARCHAR2
                    , x_attribute7           IN VARCHAR2
                    , x_attribute8           IN VARCHAR2
                    , x_attribute9           IN VARCHAR2
                    , x_attribute10          IN VARCHAR2
                    , x_attribute11          IN VARCHAR2
                    , x_attribute12          IN VARCHAR2
                    , x_attribute13          IN VARCHAR2
                    , x_attribute14          IN VARCHAR2
                    , x_attribute15          IN VARCHAR2
                    , TH_attribute_category  IN VARCHAR2
                    , TH_attribute1          IN VARCHAR2
                    , TH_attribute2          IN VARCHAR2
                    , TH_attribute3          IN VARCHAR2
                    , TH_attribute4          IN VARCHAR2
                    , TH_attribute5          IN VARCHAR2
                    , TH_attribute6          IN VARCHAR2
                    , TH_attribute7          IN VARCHAR2
                    , TH_attribute8          IN VARCHAR2
                    , TH_attribute9          IN VARCHAR2
                    , TH_attribute10         IN VARCHAR2
                    , TH_attribute11         IN VARCHAR2
                    , TH_attribute12         IN VARCHAR2
                    , TH_attribute13         IN VARCHAR2
                    , TH_attribute14         IN VARCHAR2
                    , TH_attribute15         IN VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  /* Local Variables holding Mass Retirements Information */

  LV_Retirement_Rowid        rowid;
  LV_Created_By              fa_mass_retirements.Created_By%TYPE;
  LV_Last_Update_Login       fa_mass_retirements.Last_Update_Login%TYPE;
  LV_Asset_Id                fa_additions.asset_id%TYPE;
  LV_Retirement_Status       fa_retirements.status%TYPE;
  LV_Retirement_Id           fa_retirements.retirement_id%TYPE;
  LV_Transaction_Header_In   fa_retirements.transaction_header_id_in%TYPE;
  LV_Transaction_Header_out  fa_retirements.transaction_header_id_out%TYPE;
  LV_Cost_Retired            fa_retirements.cost_retired%TYPE;
  LV_Units                   fa_retirements.units%TYPE;
  LV_date_effective          fa_retirements.date_effective%TYPE;
  LV_Ret_Prorate_Convention  fa_retirements.retirement_prorate_convention%TYPE;
  LV_Nbv_Retired             fa_retirements.nbv_retired%TYPE;
  LV_Gain_Loss_Amount        fa_retirements.gain_loss_amount%TYPE;
  LV_Proceeds_Of_Sale        fa_retirements.proceeds_of_sale%TYPE;
  LV_Cost_Of_Removal         fa_retirements.cost_of_removal%TYPE;
  LV_Gain_Loss_Type_Code     fa_retirements.gain_loss_type_code%TYPE;
  LV_Retirement_Type_Code    fa_retirements.retirement_type_code%TYPE;
  LV_Itc_Recaptured          fa_retirements.itc_recaptured%TYPE;
  LV_Itc_Recapture_Id        fa_retirements.itc_recapture_id%TYPE;
  LV_Stl_Method_Code         fa_retirements.stl_method_code%TYPE;
  LV_Stl_Life_In_Months      fa_retirements.stl_life_in_months%TYPE;
  LV_Stl_Deprn_Amount        fa_retirements.stl_deprn_amount%TYPE;
  LV_Reval_Reserve_Retired   fa_retirements.reval_reserve_retired%TYPE;
  LV_Unrevalued_Cost_Retired fa_retirements.unrevalued_cost_retired%TYPE;

  LV_Precision             NUMBER;
  LV_Ext_Precision         NUMBER;
  LV_Min_Acct_Unit         NUMBER;
  LV_Mass_Reference_Id     NUMBER;

  /* Control Variables */
  LV_Varchar2_Dummy        VARCHAR2(80);
  LV_Number_Dummy          NUMBER(15);
  LV_Today_Datetime        DATE;
  LV_Today_Date            DATE;
  v_sysdate                DATE;
  v_user                   NUMBER;
  v_last_update_login      NUMBER;
  lv_book_type_code        varchar2(30);
  lv_current_cost          number;
  l_api_version           number       := 1;
  l_init_msg_list         varchar2(1)  := FND_API.G_FALSE;
  l_commit                varchar2(1)  := FND_API.G_FALSE;
  l_validation_level      number       := FND_API.G_VALID_LEVEL_FULL;
  l_return_status         varchar2(1) := FND_API.G_FALSE;
  l_msg_count             number := 0;
  l_msg_data              varchar2(512);
  l_trans_rec              FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
  l_asset_retire_rec       FA_API_TYPES.asset_retire_rec_type;
  l_asset_dist_tbl         FA_API_TYPES.asset_dist_tbl_type;
  l_subcomp_tbl            FA_API_TYPES.subcomp_tbl_type;
  l_inv_tbl                FA_API_TYPES.inv_tbl_type;

CURSOR qualified_assets IS
   SELECT  ret.asset_id,
           ret.rowid,
           ret.status,
           ret.retirement_id,
           ret.transaction_header_id_in,
        -- ret.transaction_header_id_out
           ret.cost_retired,
           ret.units,
           ret.date_effective,
           ret.retirement_prorate_convention,
           ret.nbv_retired,
           ret.gain_loss_amount,
           ret.proceeds_of_sale,
           ret.cost_of_removal,
           ret.gain_loss_type_code,
           ret.retirement_type_code,
           ret.itc_recaptured ,
           ret.itc_recapture_id ,
           ret.stl_method_code ,
           ret.stl_life_in_months ,
           ret.stl_deprn_amount ,
           ret.reval_reserve_retired,
           ret.unrevalued_cost_retired,
           ret.book_type_code,
           ihrd.current_cost
      FROM fa_retirements	  ret,
       fa_hr_retirement_details ihrd
     WHERE ihrd.batch_id = x_batch_num
       AND ret.retirement_id = ihrd.retirement_id
       AND ret.transaction_header_id_out IS NULL
       AND ret.date_retired BETWEEN x_fy_Start_Date
                                AND x_fy_End_Date
       FOR UPDATE NOWAIT;

   CURSOR C_dist_lines IS
     SELECT distribution_id,
            units_Assigned,
            transaction_header_id_in,
            transaction_units,
            transaction_header_id_out
     FROM fa_distribution_history
     WHERE retirement_id = LV_retirement_id
     FOR UPDATE NOWAIT ;

  TYPE ErrorRecTyp IS RECORD(
	rejection_reason	VARCHAR2(250) );

  TYPE ErrorTabTyp IS TABLE OF ErrorRecTyp
  INDEX BY BINARY_INTEGER;

  v_Error_Tab  ErrorTabTyp;  -- error table

  BEGIN -- hr_Reinstate

     -- initializing parameters
     v_sysdate:= sysdate;
     v_user:= nvl(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
     v_last_update_login:= nvl(TO_NUMBER(fnd_profile.value('LOGIN_ID')),-1);

    -- use the concurrent request id as the mass reference.
    LV_Mass_Reference_Id := x_Conc_Request_Id;

    FND_CURRENCY.GET_INFO(x_Currency_Code,
                         LV_Precision,
                         LV_Ext_Precision,
                         LV_Min_Acct_Unit);

     OPEN qualified_assets;
     LOOP -- qualified_assets
     FETCH qualified_assets INTO    LV_Asset_Id,
                                    LV_retirement_rowid,
                                    LV_Retirement_Status,
                                    LV_Retirement_Id,
                                    LV_Transaction_Header_In,
                                 --   LV_transaction_header_out,
                                    LV_Cost_Retired,
                                    LV_units,
                                    LV_date_effective,
                                    LV_ret_prorate_convention,
                                    LV_nbv_retired,
                                    LV_gain_loss_amount,
                                    LV_proceeds_of_sale,
                                    LV_cost_of_removal,
                                    LV_gain_loss_type_code,
                                    LV_retirement_type_code,
                                    LV_itc_recaptured ,
                                    LV_itc_recapture_id ,
                                    LV_stl_method_code ,
                                    LV_stl_life_in_months ,
                                    LV_stl_deprn_amount ,
                                    LV_reval_reserve_retired,
                                    LV_unrevalued_cost_retired,
                                    LV_book_type_code,
                                    LV_current_cost;
    EXIT WHEN qualified_assets%NOTFOUND;

      l_asset_retire_rec.retirement_id := LV_Retirement_Id;

      IF LV_Retirement_Status = 'PENDING' THEN

         FA_RETIREMENT_PUB.undo_retirement(
                  p_api_version               => l_api_version
                 ,p_init_msg_list             => l_init_msg_list
                 ,p_commit                    => l_commit
                 ,p_validation_level          => l_validation_level
                 ,p_calling_fn                => 'FA_CUA_HR_REINSTATEMENTS_PKG.Reinstate'
                 ,x_return_status             => l_return_status
                 ,x_msg_count                 => l_msg_count
                 ,x_msg_data                  => l_msg_data

                 ,px_trans_rec                => l_trans_rec
                 ,px_asset_hdr_rec            => l_asset_hdr_rec
                 ,px_asset_retire_rec         => l_asset_retire_rec);

      ELSIF LV_Retirement_Status = 'PROCESSED' THEN

         FA_RETIREMENT_PUB.do_reinstatement(
                   p_api_version               => l_api_version
                  ,p_init_msg_list             => l_init_msg_list
                  ,p_commit                    => l_commit
                  ,p_validation_level          => l_validation_level
                  ,p_calling_fn                => 'FA_CUA_HR_REINSTATEMENTS_PKG.Reinstate'
                  ,x_return_status             => l_return_status
                  ,x_msg_count                 => l_msg_count
                  ,x_msg_data                  => l_msg_data

                  ,px_trans_rec                => l_trans_rec
                  ,px_asset_hdr_rec            => l_asset_hdr_rec
                  ,px_asset_retire_rec         => l_asset_retire_rec
                  ,p_asset_dist_tbl            => l_asset_dist_tbl
                  ,p_subcomp_tbl               => l_subcomp_tbl
                  ,p_inv_tbl                   => l_inv_tbl);

      END IF; -- LV_Retirement_Status

      IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) then
         rollback;

         UPDATE fa_hr_retirement_headers
         set status_code = 'RF'  -- Reinstatement Failed
         where batch_id = x_batch_num;
      END IF;

    END LOOP; -- qualified_assets
    CLOSE qualified_assets;

    update fa_hr_retirement_headers
    set status_code = 'RC' -- reinstatement completed
    where batch_id = x_batch_num;

    update fa_hr_retirement_details
    set status_code = 'RI' -- reinstated
    where batch_id = x_batch_num;

    commit;
  EXCEPTION -- hr_Reinstate
    WHEN Others THEN
      rollback;

      UPDATE fa_hr_retirement_headers
      set status_code = 'RF'  -- Reinstatement Failed
      where batch_id = x_batch_num;
  END Reinstate;
  --

  PROCEDURE conc_request( ERRBUF OUT NOCOPY VARCHAR2,
                          RETCODE OUT NOCOPY VARCHAR2,
                          x_from_batch_num IN NUMBER,
                          x_to_batch_num IN NUMBER) IS

    CURSOR hr_reinstatement IS
    SELECT ihrh.batch_id,
           ihrh.concurrent_request_id,
           ihrh.book_type_code,
           ihrh.retire_date ,
           sob.currency_code,
           ffy.start_date,
           ffy.end_date
           , ihrh.attribute_category
           , ihrh.attribute1
           , ihrh.attribute2
           , ihrh.attribute3
           , ihrh.attribute4
           , ihrh.attribute5
           , ihrh.attribute6
           , ihrh.attribute7
           , ihrh.attribute8
           , ihrh.attribute9
           , ihrh.attribute10
           , ihrh.attribute11
           , ihrh.attribute12
           , ihrh.attribute13
           , ihrh.attribute14
           , ihrh.attribute15
           , ihrh.TH_attribute_category
           , ihrh.TH_attribute1
           , ihrh.TH_attribute2
           , ihrh.TH_attribute3
           , ihrh.TH_attribute4
           , ihrh.TH_attribute5
           , ihrh.TH_attribute6
           , ihrh.TH_attribute7
           , ihrh.TH_attribute8
           , ihrh.TH_attribute9
           , ihrh.TH_attribute10
           , ihrh.TH_attribute11
           , ihrh.TH_attribute12
           , ihrh.TH_attribute13
           , ihrh.TH_attribute14
           , ihrh.TH_attribute15
      FROM fa_hr_retirement_headers ihrh,
           fa_book_controls       fbc,
           gl_sets_of_books       sob,
           fa_fiscal_year         ffy
     WHERE ihrh.batch_id >= nvl(x_from_batch_num, ihrh.batch_id )
       AND ihrh.batch_id <= nvl(x_to_batch_num, ihrh.batch_id)
       AND ihrh.status_code IN ( 'RP', 'CP', 'RC')  --completely processed or completely reinstated
       AND ihrh.book_type_code = fbc.book_type_code
       AND fbc.set_of_books_id = sob.set_of_books_id
       AND ffy.fiscal_year_name = fbc.fiscal_year_name
       AND ffy.fiscal_year = fbc.current_fiscal_year
       FOR UPDATE NOWAIT;

  BEGIN

     FOR hrh_rec IN  hr_reinstatement LOOP

       update fa_hr_retirement_headers
       set status_code = 'RP'
       where batch_id = hrh_rec.batch_id;

       update fa_hr_retirement_details
       set status_code = 'RP'
       where batch_id = hrh_rec.batch_id;

       commit;

       reinstate ( hrh_rec.batch_id,
                   hrh_rec.concurrent_request_id,
                   hrh_rec.book_type_code,
                   hrh_rec.retire_date,
                   hrh_rec.currency_code,
                   hrh_rec.start_date,
                   hrh_rec.end_date
                   , hrh_rec.attribute_category
                   , hrh_rec.attribute1
                   , hrh_rec.attribute2
                   , hrh_rec.attribute3
                   , hrh_rec.attribute4
                   , hrh_rec.attribute5
                   , hrh_rec.attribute6
                   , hrh_rec.attribute7
                   , hrh_rec.attribute8
                   , hrh_rec.attribute9
                   , hrh_rec.attribute10
                   , hrh_rec.attribute11
                   , hrh_rec.attribute12
                   , hrh_rec.attribute13
                   , hrh_rec.attribute14
                   , hrh_rec.attribute15
                   , hrh_rec.TH_attribute_category
                   , hrh_rec.TH_attribute1
                   , hrh_rec.TH_attribute2
                   , hrh_rec.TH_attribute3
                   , hrh_rec.TH_attribute4
                   , hrh_rec.TH_attribute5
                   , hrh_rec.TH_attribute6
                   , hrh_rec.TH_attribute7
                   , hrh_rec.TH_attribute8
                   , hrh_rec.TH_attribute9
                   , hrh_rec.TH_attribute10
                   , hrh_rec.TH_attribute11
                   , hrh_rec.TH_attribute12
                   , hrh_rec.TH_attribute13
                   , hrh_rec.TH_attribute14
                   , hrh_rec.TH_attribute15
                   , g_log_level_rec);
    END LOOP;
  END conc_request;

END FA_CUA_HR_REINSTATEMENTS_PKG;

/
