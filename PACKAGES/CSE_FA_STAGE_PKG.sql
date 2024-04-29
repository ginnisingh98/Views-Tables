--------------------------------------------------------
--  DDL for Package CSE_FA_STAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_FA_STAGE_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEPFASS.pls 120.3 2006/08/18 23:14:38 brmanesh noship $ */

  g_pkg_name  constant varchar2(30)  := 'cse_fa_stage_pkg';

  PROCEDURE stage_addition(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_desc_rec    IN     fa_api_types.asset_desc_rec_type,
    p_asset_fin_rec     IN     fa_api_types.asset_fin_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type);

  PROCEDURE stage_unit_adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type);

  PROCEDURE stage_adjustment(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_fin_rec_adj IN     fa_api_types.asset_fin_rec_type,
    p_inv_tbl           IN     fa_api_types.inv_tbl_type);

  PROCEDURE stage_transfer(
    p_trans_rec         IN     fa_api_types.trans_rec_type,
    p_asset_hdr_rec     IN     fa_api_types.asset_hdr_rec_type,
    p_asset_dist_tbl    IN     fa_api_types.asset_dist_tbl_type);

 PROCEDURE stage_retirement(
    p_asset_id          IN     number,
    p_book_type_code    IN     varchar2,
    p_retirement_id     IN     number,
    p_retirement_date   IN     date,
    p_retirement_units  IN     number);

  PROCEDURE stage_reinstatement(
    p_asset_id            IN   number,
    p_book_type_code      IN   varchar2,
    p_retirement_id       IN   number,
    p_reinstatement_date  IN   date,
    p_reinstatement_units IN   number);

  PROCEDURE get_report_clob (
    p_report_clob     IN            clob,
    p_display_type    IN            varchar2,
    x_document        IN OUT NOCOPY clob,
    x_document_type   IN OUT NOCOPY varchar2);

  PROCEDURE notify_users(
    errbuf                 OUT NOCOPY VARCHAR2,
    retcode                OUT NOCOPY NUMBER);

END cse_fa_stage_pkg;

 

/
