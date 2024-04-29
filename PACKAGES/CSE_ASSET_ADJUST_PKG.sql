--------------------------------------------------------
--  DDL for Package CSE_ASSET_ADJUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ASSET_ADJUST_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEFADJS.pls 120.0 2005/05/24 17:41:17 appldev noship $

PROCEDURE process_adjustment_trans(
 x_return_code            OUT NOCOPY VARCHAR2
,x_err_buffer             OUT NOCOPY VARCHAR2
,p_inv_org_id               IN NUMBER
,p_inventory_item_id        IN NUMBER,
 p_conc_request_id          IN NUMBER DEFAULT NULL );

PROCEDURE retire_asset (
 p_ret_asset_rec             IN   cse_datastructures_pub.asset_query_rec
,p_ret_dist_tbl              IN   cse_datastructures_pub.distribution_tbl
,p_transaction_id            IN   NUMBER
,x_return_status             OUT NOCOPY  VARCHAR2
,x_error_msg                 OUT NOCOPY  VARCHAR2);

PROCEDURE insert_retirement (
  p_ext_ret_rec           IN OUT NOCOPY fa_mass_ext_retirements%ROWTYPE
, x_return_status         OUT NOCOPY    VARCHAR2
, x_error_msg             OUT NOCOPY    VARCHAR2) ;

PROCEDURE create_inv_rets(p_asset_id IN NUMBER,
             p_mass_ext_retire_id    IN NUMBER,
             p_mtl_cost              IN OUT NOCOPY NUMBER,
             p_non_mtl_cost          IN OUT NOCOPY NUMBER,
             x_return_status         OUT NOCOPY VARCHAR2,
             x_error_msg             OUT NOCOPY VARCHAR2) ;

END CSE_ASSET_ADJUST_PKG ;

 

/
