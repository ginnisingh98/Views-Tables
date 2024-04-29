--------------------------------------------------------
--  DDL for Package CSE_FA_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_FA_INTEGRATION_GRP" AUTHID CURRENT_USER AS
/* $Header: CSEGFAIS.pls 120.0 2005/06/17 15:55:00 brmanesh noship $ */

  g_pkg_name  constant varchar2(30) := 'cse_fa_integration_grp';

  FUNCTION is_oat_enabled RETURN BOOLEAN;

  FUNCTION addition(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_desc_rec    IN     fa_api_types.asset_desc_rec_type,
    p_asset_fin_rec     IN     fa_api_types.asset_fin_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type) RETURN boolean;

  FUNCTION unit_adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type) RETURN boolean;

  FUNCTION adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_fin_rec_adj IN     fa_api_types.asset_fin_rec_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type) RETURN boolean;

  FUNCTION transfer(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type) RETURN boolean;

  FUNCTION retire(
    p_asset_id          IN     number,
    p_book_type_code    IN     varchar2,
    p_retirement_id     IN     number,
    p_retirement_date   IN     date,
    p_retirement_units  IN     number) RETURN boolean;

  FUNCTION reinstate(
    p_asset_id            IN   number,
    p_book_type_code      IN   varchar2,
    p_retirement_id       IN   number,
    p_reinstatement_date  IN   date,
    p_reinstatement_units IN   number) RETURN boolean;

END cse_fa_integration_grp;

 

/
