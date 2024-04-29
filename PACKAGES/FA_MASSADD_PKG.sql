--------------------------------------------------------
--  DDL for Package FA_MASSADD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSADD_PKG" AUTHID CURRENT_USER as
/* $Header: FAMAPTS.pls 120.4.12010000.2 2009/07/19 14:33:58 glchen ship $   */

-- type for table variable
type num_tbl_type  is table of number        index by binary_integer;
type char_tbl_type is table of varchar2(150) index by binary_integer;
type date_tbl_type is table of date          index by binary_integer;

-- public functions
PROCEDURE Do_Mass_Addition
            (p_book_type_code          IN     VARCHAR2,
             p_mode                    IN     VARCHAR2,
             p_loop_count              IN     NUMBER,
             p_parent_request_id       IN     NUMBER,
             p_total_requests          IN     NUMBER,
             p_request_number          IN     NUMBER,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number );

FUNCTION Do_mass_property(
             p_book_type_code               IN      VARCHAR2,
             p_rowid_tbl                    IN      char_tbl_type ,
             p_mass_addition_id_tbl         IN      num_tbl_type  ,
             px_asset_id_tbl                IN OUT  NOCOPY num_tbl_type  ,
             px_add_to_asset_id_tbl         IN OUT  NOCOPY num_tbl_type  ,
             p_asset_category_id_tbl        IN      num_tbl_type  ,
             p_asset_type_tbl               IN      char_tbl_type ,
             px_date_placed_in_service_tbl  IN OUT  NOCOPY date_tbl_type ,
             px_amortize_flag_tbl           IN OUT  NOCOPY char_tbl_type ,
             px_amortization_start_date_tbl IN OUT  NOCOPY date_tbl_type ,
             px_description_tbl             IN OUT  NOCOPY char_tbl_type ,
             p_fixed_assets_units_tbl       IN      num_tbl_type  ,
             px_units_to_adjust_tbl         IN OUT  NOCOPY num_tbl_type
           )    RETURN BOOLEAN;

PROCEDURE allocate_workers (
             p_book_type_code     IN     VARCHAR2,
             p_mode               IN     VARCHAR2,
             p_parent_request_id  IN     NUMBER,
             p_total_requests     IN     NUMBER,
             x_return_status         OUT NOCOPY NUMBER);


END FA_MASSADD_PKG;

/
