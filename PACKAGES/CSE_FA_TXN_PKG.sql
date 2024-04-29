--------------------------------------------------------
--  DDL for Package CSE_FA_TXN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_FA_TXN_PKG" AUTHID CURRENT_USER AS
/* $Header: CSEASTXS.pls 120.4 2006/06/20 21:56:31 brmanesh noship $   */
  g_pkg_name constant varchar2(30) := 'cse_fa_txn_pkg';


  PROCEDURE asset_retirement(
    p_instance_id           IN     NUMBER,
    p_book_type_code        IN     VARCHAR2,
    p_asset_id              IN     NUMBER,
    p_units                 IN     NUMBER,
    p_trans_date            IN     DATE,
    p_trans_by              IN     NUMBER,
    px_txn_rec              IN OUT NOCOPY csi_datastructures_pub.transaction_rec,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_error_message            OUT NOCOPY VARCHAR2);

  PROCEDURE asset_reinstatement(
    p_retirement_id         IN     NUMBER,
    p_book_type_code        IN     VARCHAR2,
    p_asset_id              IN     NUMBER,
    p_units                 IN     NUMBER,
    p_trans_date            IN     DATE,
    p_trans_by              IN     NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2,
    x_error_message            OUT NOCOPY VARCHAR2);

  PROCEDURE populate_retirement_interface(
    p_csi_txn_id            IN     number,
    p_asset_id              IN     number,
    p_book_type_code        IN     varchar2,
    p_fa_location_id        IN     number,
    p_proceeds_of_sale      IN     number,
    p_cost_of_removal       IN     number,
    p_retirement_units      IN     number,
    p_retirement_date       IN     date,
    x_return_status            OUT nocopy varchar2);

END cse_fa_txn_pkg;

 

/
