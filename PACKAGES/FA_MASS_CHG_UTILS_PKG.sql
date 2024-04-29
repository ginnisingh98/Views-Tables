--------------------------------------------------------
--  DDL for Package FA_MASS_CHG_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_CHG_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXMCUTS.pls 120.2.12010000.2 2009/07/19 14:04:35 glchen ship $ */

TYPE mass_change_rec_type    is record(
     mass_change_id              number,
     book_type_code               varchar2(15),
     transaction_date_entered     date,
     concurrent_request_id        number,
     status                       varchar2(10),
     asset_type                   varchar2(30),
     category_id                  number,
     from_asset_number            varchar2(15),
     to_asset_number              varchar2(15),
     from_date_placed_in_service  date,
     to_date_placed_in_service    date,
     from_convention              varchar2(10),
     to_convention                varchar2(10),
     from_method_code             varchar2(12),
     to_method_code               varchar2(12),
     from_life_in_months          number,
     to_life_in_months            number,
     from_bonus_rule              varchar2(30),
     to_bonus_rule                varchar2(30),
     date_effective               date,
     from_basic_rate              number,
     to_basic_rate                number,
     from_adjusted_rate           number,
     to_adjusted_rate             number,
     from_production_capacity     number,
     to_production_capacity       number,
     from_uom                     varchar2(25),
     to_uom                       varchar2(12),
     from_group_association       varchar2(30),
     to_group_association         varchar2(30),
     from_group_asset_id          number,
     to_group_asset_id            number,
     from_group_asset_number      varchar2(15),
     to_group_asset_number        varchar2(15),
     change_fully_rsvd_assets     varchar2(3),
     amortize_flag                varchar2(1),
     created_by                   number,
     creation_date                date,
     last_updated_by              number,
     last_update_login            number,
     last_update_date             date,
     from_salvage_type            varchar2(30),
     to_salvage_type              varchar2(30),
     from_percent_salvage_value   number,
     to_percent_salvage_value     number,
     from_salvage_value           number,
     to_salvage_value             number,
     from_deprn_limit_type        varchar2(30),
     to_deprn_limit_type          varchar2(30),
     from_deprn_limit             number,
     to_deprn_limit               number,
     from_deprn_limit_amount      number,
     to_deprn_limit_amount        number
);

TYPE asset_rec_type     is record(
     asset_id                     NUMBER(15),
     asset_number                 VARCHAR2(15),
     description                  VARCHAR2(80),
     asset_type                   VARCHAR2(15),
     book_type_code               VARCHAR2(15), -- corporate/tax book for asset
     category_id                  NUMBER(15),   -- current category in database
     category                     VARCHAR2(210),-- in concatenated string
     from_convention              VARCHAR2(10), -- prorate convention
     to_convention                VARCHAR2(10), -- prorate convention
     from_method                  VARCHAR2(12),
     to_method                    VARCHAR2(12),
     from_life_in_months          NUMBER(4),
     to_life_in_months            NUMBER(4),
     from_life                    VARCHAR2(6),  -- New life year.mo
     to_life                      VARCHAR2(6),  -- New life year.mo
     from_basic_rate              NUMBER,
     to_basic_rate                NUMBER,
     from_basic_rate_pct          NUMBER,       -- in percentage(rounded)
     to_basic_rate_pct            NUMBER,       -- in percentage(rounded)
     from_adjusted_rate           NUMBER,
     to_adjusted_rate             NUMBER,
     from_adjusted_rate_pct       NUMBER,       -- in percentage(rounded)
     to_adjusted_rate_pct         NUMBER,       -- in percentage(rounded)
     from_bonus_rule              VARCHAR2(30),
     to_bonus_rule                VARCHAR2(30),
     from_capacity                NUMBER,
     to_capacity                  NUMBER,
     from_unit_of_measure         VARCHAR2(25),
     to_unit_of_measure           VARCHAR2(25),
     from_group_asset_number      VARCHAR2(15),
     to_group_asset_number        VARCHAR2(15),
     from_salvage_type            VARCHAR2(30),
     to_salvage_type              VARCHAR2(30),
     from_percent_salvage_value   NUMBER,
     to_percent_salvage_value     NUMBER,
     from_salvage_value           NUMBER,
     to_salvage_value             NUMBER,
     from_deprn_limit_type        VARCHAR2(30),
     to_deprn_limit_type          VARCHAR2(30),
     from_deprn_limit             NUMBER,
     to_deprn_limit               NUMBER,
     from_deprn_limit_amount      NUMBER,
     to_deprn_limit_amount        NUMBER
    );

TYPE asset_tbl_type     is table of asset_rec_type INDEX BY BINARY_INTEGER;


/*=====================================================================================+
|
|   Name:          Insert_Itf
|
|   Description:   Proecedure to insert an asset record into the interface table,
|                  fa_mass_changes_itf, for report exchange.
|
|   Parameters:    X_Report_Type     -- PREVIEW or REVIEW
|                  X_Request_Id      -- Concurrent request id.
|                  X_Mass_Change_Id  -- Mass change id.
|                  X_Asset_Rec       -- Asset record with all the information.
|                  X_Last_Update_Date .. X_Last_Update_Login
|                                     -- Standard who columns
|
|   Returns:
|
|   Notes:
|
+=====================================================================================*/

PROCEDURE Insert_Itf(
      X_Report_Type         IN     VARCHAR2,
      X_Request_Id          IN     NUMBER,
      X_Mass_Change_Id      IN     NUMBER,
      X_Asset_Rec           IN     ASSET_REC_TYPE,
      X_Last_Update_Date    IN     DATE,
      X_Last_Updated_By     IN     NUMBER,
      X_Created_By          IN     NUMBER,
      X_Creation_Date       IN     DATE,
      X_Last_Update_Login   IN     NUMBER
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_MASS_CHG_UTILS_PKG;

/
