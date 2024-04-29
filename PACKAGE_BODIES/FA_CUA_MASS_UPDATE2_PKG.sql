--------------------------------------------------------
--  DDL for Package Body FA_CUA_MASS_UPDATE2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_MASS_UPDATE2_PKG" as
/* $Header: FACMUP2MB.pls 120.5.12010000.2 2009/07/19 12:21:25 glchen ship $ */
/*===========================================================================
 PACKAGE NAME:          FA_CUA_MASS_UPDATE2_PKG as

 DESCRIPTION:           This package contains APIs For Mass UpdateProcess

 AUTHOR:                Gautam Prothia

 DATE:                  08-Jan-1999
===========================================================================*/


Procedure UPDATE_LIFE
 (x_asset_id in number,
  x_book_type_code in varchar2,
  x_old_life in number,
  x_new_life in out nocopy number,
  x_amortization_flag in varchar2,
  x_amortization_date in date,
  x_err_code in out nocopy varchar2 ,
  x_err_stage in out nocopy varchar2 ,
  x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  l_trans_rec                FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
  l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_rec_new        FA_API_TYPES.asset_fin_rec_type;
  l_asset_fin_mrc_tbl_new    FA_API_TYPES.asset_fin_tbl_type;
  l_inv_trans_rec            FA_API_TYPES.inv_trans_rec_type;
  l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
  l_asset_deprn_rec_adj      FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_rec_new      FA_API_TYPES.asset_deprn_rec_type;
  l_asset_deprn_mrc_tbl_new  FA_API_TYPES.asset_deprn_tbl_type;
  l_inv_rec                  FA_API_TYPES.inv_rec_type;
  l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;
  l_return_status            VARCHAR2(1);
  l_mesg_count               number := 0;
  l_mesg_len                 number;
  l_mesg                     varchar2(4000);

  v_old_stack                     varchar2(600);

BEGIN


  x_err_code := '0';
  v_old_stack := x_err_stack ;
  x_err_stack := x_err_stack||'Updating Life ';

  l_asset_hdr_rec.asset_id       := x_asset_id;
  l_asset_hdr_rec.book_type_code := x_book_type_code;
  l_trans_rec.transaction_type_code      := 'ADJUSTMENT';

  IF (x_amortization_flag = 'YES') THEN
     l_trans_rec.amortization_start_date := x_amortization_date;
  END IF;

  l_asset_fin_rec_adj.life_in_months:=x_new_life;

  FA_ADJUSTMENT_PUB.do_adjustment
      (p_api_version             => 1.0,
       p_init_msg_list           => FND_API.G_FALSE,
       p_commit                  => FND_API.G_FALSE,
       p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
       x_return_status           => l_return_status,
       x_msg_count               => l_mesg_count,
       x_msg_data                => l_mesg,
       p_calling_fn              => null,
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
       p_group_reclass_options_rec => l_group_reclass_options_rec
      );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     x_err_code := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_TRUE), 1, 512);
     return;
  END IF;

  return;

Exception
  When others then
     x_err_code := sqlcode;
     return;
END UPDATE_LIFE;

END FA_CUA_MASS_UPDATE2_PKG;

/
