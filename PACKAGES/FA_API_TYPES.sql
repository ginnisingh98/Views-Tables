--------------------------------------------------------
--  DDL for Package FA_API_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_API_TYPES" AUTHID CURRENT_USER as
/* $Header: FAPTYPES.pls 120.33.12010000.7 2010/03/04 14:06:33 deemitta ship $   */

-----------------------------------------
-- Public Types Used Only Within Types --
-----------------------------------------

-------------------------
-- Standard Who Record --
-------------------------

TYPE standard_who_rec_type IS RECORD (
      last_update_date   DATE       DEFAULT sysdate,
      last_updated_by    NUMBER(15) DEFAULT fnd_global.user_id,
      created_by         NUMBER(15) DEFAULT fnd_global.user_id,
      creation_date      DATE       DEFAULT sysdate,
      last_update_login  NUMBER(15) DEFAULT fnd_global.login_id);

-----------------------------
-- Descriptive Flex Record --
-----------------------------

TYPE desc_flex_rec_type IS RECORD (
      attribute1              VARCHAR2(150)   ,
      attribute2              VARCHAR2(150)   ,
      attribute3              VARCHAR2(150)   ,
      attribute4              VARCHAR2(150)   ,
      attribute5              VARCHAR2(150)   ,
      attribute6              VARCHAR2(150)   ,
      attribute7              VARCHAR2(150)   ,
      attribute8              VARCHAR2(150)   ,
      attribute9              VARCHAR2(150)   ,
      attribute10             VARCHAR2(150)   ,
      attribute11             VARCHAR2(150)   ,
      attribute12             VARCHAR2(150)   ,
      attribute13             VARCHAR2(150)   ,
      attribute14             VARCHAR2(150)   ,
      attribute15             VARCHAR2(150)   ,
      attribute16             VARCHAR2(150)   ,
      attribute17             VARCHAR2(150)   ,
      attribute18             VARCHAR2(150)   ,
      attribute19             VARCHAR2(150)   ,
      attribute20             VARCHAR2(150)   ,
      attribute21             VARCHAR2(150)   ,
      attribute22             VARCHAR2(150)   ,
      attribute23             VARCHAR2(150)   ,
      attribute24             VARCHAR2(150)   ,
      attribute25             VARCHAR2(150)   ,
      attribute26             VARCHAR2(150)   ,
      attribute27             VARCHAR2(150)   ,
      attribute28             VARCHAR2(150)   ,
      attribute29             VARCHAR2(150)   ,
      attribute30             VARCHAR2(150)   ,
      attribute_category_code VARCHAR2(210)   ,
      context                 VARCHAR2(210)
     );

------------------
-- Public Types --
------------------

-- Asset Transaction Recordure
TYPE trans_rec_type IS RECORD (
      transaction_header_id         NUMBER                           ,
      transaction_type_code         VARCHAR2(20)                     ,
      transaction_date_entered      DATE                             ,
      transaction_name              VARCHAR2(30)                     ,
      source_transaction_header_id  NUMBER                           ,
      mass_reference_id             NUMBER                           ,
      transaction_subtype           VARCHAR2(9)                      ,
      transaction_key               VARCHAR2(2)                      ,
      amortization_start_date       DATE                             ,
      calling_interface             VARCHAR2(30)     DEFAULT 'CUSTOM',
      mass_transaction_id           NUMBER                           ,
      deprn_override_flag           VARCHAR2(1)      DEFAULT 'N'     ,
      member_transaction_header_id  NUMBER                           ,
      trx_reference_id              NUMBER                           ,
      event_id                      NUMBER                           ,
      desc_flex                     DESC_FLEX_rec_type               ,
      who_info                      STANDARD_WHO_rec_type
     );

--------------------------------------------------------
-- Information used to uniquely identify an asset     --
-- Neither asset_id and book_type_code cannot be null --
--------------------------------------------------------

TYPE asset_hdr_rec_type IS RECORD (
      asset_id            NUMBER(15)     ,
      book_type_code      VARCHAR2(15)   ,
      set_of_books_id     NUMBER(15)     ,
      period_of_addition  VARCHAR2(1)
     );
-----------------------------------
-- Descriptive asset information --
-----------------------------------

TYPE asset_desc_rec_type IS RECORD (
      asset_number            VARCHAR2(15)                                          ,
      description             VARCHAR2(80)                                          ,
      tag_number              VARCHAR2(15)                                          ,
      serial_number           VARCHAR2(35)                                          ,
      asset_key_ccid          NUMBER                                                ,
      parent_asset_id         NUMBER                                                ,
      manufacturer_name       VARCHAR2(360)                                          ,
      model_number            VARCHAR2(40)                                          ,
      warranty_id             NUMBER                                                ,
      lease_id                NUMBER                                                ,
      in_use_flag             VARCHAR2(3)                                           ,
      inventorial             VARCHAR2(3)                                           ,
      commitment              VARCHAR2(150)                                         ,
      investment_law          VARCHAR2(150)                                         ,
      property_type_code      VARCHAR2(10)                                          ,
      property_1245_1250_code VARCHAR2(4)                                           ,
      owned_leased            VARCHAR2(15)                                          ,
      new_used                VARCHAR2(4)                                           ,
      current_units           NUMBER                                                ,
      unit_adjustment_flag    VARCHAR2(3)                                           ,
      add_cost_je_flag        VARCHAR2(3)                                           ,
      status                  VARCHAR2(150)                                         ,
      lease_desc_flex         DESC_FLEX_rec_type,
      global_desc_flex        DESC_FLEX_rec_type
     );

TYPE asset_type_rec_type IS RECORD (
      asset_type          VARCHAR2(11)    DEFAULT 'CAPITALIZED'
     );

TYPE asset_cat_rec_type IS RECORD (
      category_id              NUMBER                ,
      desc_flex                DESC_FLEX_REC_TYPE
     );

TYPE asset_hierarchy_rec_type IS RECORD (
      parent_hierarchy_id      NUMBER
     );

TYPE asset_hr_attr_rec_type IS RECORD (
     category_id         NUMBER       ,
     serial_number       VARCHAR2(35) ,
     lease_id            NUMBER       ,
     asset_key_ccid      NUMBER       ,
     dist_set_id         NUMBER       ,
     life_in_months      NUMBER       ,
     prorate_date        DATE         );

TYPE asset_hr_options_rec_type IS RECORD (
     event_code                VARCHAR2(30),
     status_code               VARCHAR2(2),
     source_entity_name        VARCHAR2(30),
     source_entity_value       VARCHAR2(30),
     source_attribute_name     VARCHAR2(30),
     source_attribute_old_id   VARCHAR2(30),
     source_attribute_new_id   VARCHAR2(30),
     amortization_start_date   DATE,
     amortize_flag             VARCHAR2(3),
     description               VARCHAR2(50),
     rejection_reason_code     VARCHAR2(30),
     concurrent_request_id     NUMBER,
     batch_id                  NUMBER
     );

---------------------------------
-- Asset Financial Information --
---------------------------------

TYPE asset_fin_rec_type IS RECORD (
      set_of_books_id               NUMBER,
      date_placed_in_service        DATE,
      deprn_start_date              DATE,
      deprn_method_code             VARCHAR2(12),
      life_in_months                NUMBER,
      rate_adjustment_factor        NUMBER,
      adjusted_cost                 NUMBER,
      cost                          NUMBER,
      original_cost                 NUMBER,
      salvage_value                 NUMBER,
      prorate_convention_code       VARCHAR2(10),
      prorate_date                  DATE,
      cost_change_flag              VARCHAR2(3),
      adjustment_required_status    VARCHAR2(4),
      capitalize_flag               VARCHAR2(3),
      retirement_pending_flag       VARCHAR2(3),
      depreciate_flag               VARCHAR2(3),
      disabled_flag                     VARCHAR2(1), --HH group enable disable
      itc_amount_id                 NUMBER,
      itc_amount                    NUMBER,
      retirement_id                 NUMBER,
      tax_request_id                NUMBER,
      itc_basis                     NUMBER,
      basic_rate                    NUMBER,
      adjusted_rate                 NUMBER,
      bonus_rule                    VARCHAR2(30),
      ceiling_name                  VARCHAR2(30),
      recoverable_cost              NUMBER,
      adjusted_capacity             NUMBER,
      fully_rsvd_revals_counter     NUMBER,
      idled_flag                    VARCHAR2(3),
      period_counter_capitalized    NUMBER,
      period_counter_fully_reserved NUMBER,
      period_counter_fully_retired  NUMBER,
      production_capacity           NUMBER,
      reval_amortization_basis      NUMBER,
      reval_ceiling                 NUMBER,
      unit_of_measure               VARCHAR2(25),
      unrevalued_cost               NUMBER,
      annual_deprn_rounding_flag    VARCHAR2(5),
      percent_salvage_value         NUMBER,
      allowed_deprn_limit           NUMBER,
      allowed_deprn_limit_amount    NUMBER,
      period_counter_life_complete  NUMBER,
      adjusted_recoverable_cost     NUMBER,
      annual_rounding_flag          VARCHAR2(5),
      eofy_adj_cost                 NUMBER,
      eofy_formula_factor           NUMBER,
      short_fiscal_year_flag        VARCHAR2(3),
      conversion_date               DATE,
      orig_deprn_start_date         DATE,
      remaining_life1               NUMBER,
      remaining_life2               NUMBER,
      group_asset_id                NUMBER ,
      old_adjusted_cost             NUMBER,
      formula_factor                NUMBER,
      -- start new fields for group
      salvage_type                  VARCHAR2(30),
      deprn_limit_type              VARCHAR2(30),
      over_depreciate_option        VARCHAR2(30),
      super_group_id                NUMBER,
      reduction_rate                NUMBER,
      reduce_addition_flag          VARCHAR2(1),
      reduce_adjustment_flag        VARCHAR2(1),
      reduce_retirement_flag        VARCHAR2(1),
      -- start of modificaton by toru
      recognize_gain_loss           VARCHAR2(30),
      recapture_reserve_flag        VARCHAR2(1),
      limit_proceeds_flag           VARCHAR2(1),
      terminal_gain_loss            VARCHAR2(30),
      tracking_method               VARCHAR2(30),
      exclude_fully_rsv_flag        VARCHAR2(1),
      excess_allocation_option      VARCHAR2(30),
      depreciation_option           VARCHAR2(30),
      member_rollup_flag            VARCHAR2(1),
      ytd_proceeds                  NUMBER,
      ltd_proceeds                  NUMBER,
      allocate_to_fully_rsv_flag    VARCHAR2(1),
      allocate_to_fully_ret_flag    VARCHAR2(1),
      eofy_reserve                  NUMBER,
      cip_cost                      NUMBER,
      terminal_gain_loss_amount     NUMBER,
      ltd_cost_of_removal           NUMBER,
      -- end of modificaton by toru
      -- start of modification by hsugimot
      prior_eofy_reserve            NUMBER,
      eop_adj_cost                  NUMBER,
      eop_formula_factor            NUMBER,
      -- end of modification by hsugimot
      -- start of modification by hhiraga
      exclude_proceeds_from_basis   VARCHAR2(1),
      retirement_deprn_option       VARCHAR2(30),
      -- end of modification by hhiraga
      terminal_gain_loss_flag       VARCHAR2(1),
      -- ias36 impairment variables
      cash_generating_unit_id       NUMBER,
      -- end ias36
      extended_deprn_flag           VARCHAR2(1),  -- Japan Tax phase3
      extended_depreciation_period  NUMBER,       -- Japan Tax phase3
      period_counter_fully_extended NUMBER,       -- Japan Bug 6645061
     nbv_at_switch                 NUMBER,       -- -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy Start
     prior_deprn_limit_type        VARCHAR2(30) ,
     prior_deprn_limit_amount      NUMBER   ,
     prior_deprn_limit             NUMBER   ,
     period_full_reserve           VARCHAR2(30),
     period_extd_deprn             VARCHAR2(30),
     prior_deprn_method            VARCHAR2(30) ,
     prior_life_in_months          NUMBER   ,
     prior_basic_rate              NUMBER   ,
     prior_adjusted_rate           NUMBER   ,
     rate_in_use                   NUMBER   ,  --phase5
     mass_addition_id              NUMBER,       -- Changes made as per the ER No.s 6606548 and 6606552 by Sbyreddy End
      dry_hole_flag                 VARCHAR2(1), --- For AFE Reclass
      contract_id                   Number,      -- Bug:6021567
      contract_change_flag          boolean DEFAULT FALSE,    -- Bug:6950629
      global_attribute1             VARCHAR2(150) ,
      global_attribute2             VARCHAR2(150) ,
      global_attribute3             VARCHAR2(150) ,
      global_attribute4             VARCHAR2(150) ,
      global_attribute5             VARCHAR2(150) ,
      global_attribute6             VARCHAR2(150) ,
      global_attribute7             VARCHAR2(150) ,
      global_attribute8             VARCHAR2(150) ,
      global_attribute9             VARCHAR2(150) ,
      global_attribute10            VARCHAR2(150) ,
      global_attribute11            VARCHAR2(150) ,
      global_attribute12            VARCHAR2(150) ,
      global_attribute13            VARCHAR2(150) ,
      global_attribute14            VARCHAR2(150) ,
      global_attribute15            VARCHAR2(150) ,
      global_attribute16            VARCHAR2(150) ,
      global_attribute17            VARCHAR2(150) ,
      global_attribute18            VARCHAR2(150) ,
      global_attribute19            VARCHAR2(150) ,
      global_attribute20            VARCHAR2(150) ,
      global_attribute_category     VARCHAR2(150)
     );

TYPE asset_deprn_rec_type IS RECORD (
      set_of_books_id          NUMBER,
      deprn_amount             NUMBER,
      ytd_deprn                NUMBER,
      deprn_reserve            NUMBER,
      prior_fy_expense         NUMBER,
      bonus_deprn_amount       NUMBER,
      bonus_ytd_deprn          NUMBER,
      bonus_deprn_reserve      NUMBER,
      prior_fy_bonus_expense   NUMBER,
      reval_amortization       NUMBER,
      reval_amortization_basis NUMBER,
      reval_deprn_expense      NUMBER,
      reval_ytd_deprn          NUMBER,
      reval_deprn_reserve      NUMBER,
      production               NUMBER,
      ytd_production           NUMBER,
      ltd_production           NUMBER,
      impairment_amount        NUMBER,
      ytd_impairment           NUMBER,
      impairment_reserve       NUMBER,
		allow_taxup_flag         BOOLEAN
     );

TYPE asset_dist_rec_type IS RECORD (
      distribution_id   NUMBER,
      units_assigned    NUMBER,
      transaction_units NUMBER,
      assigned_to       NUMBER,
      expense_ccid      NUMBER,
      location_ccid     NUMBER
     );

TYPE asset_dist_tbl_type IS TABLE OF asset_dist_rec_type index by binary_integer;


-- Reclass Options
TYPE reclass_options_rec_type IS RECORD(
     copy_cat_desc_flag       VARCHAR2(3),
     redefault_flag           VARCHAR2(3),
     -- redefault_group_flag  VARCHAR2(3),
     mass_request_id          NUMBER  );

-- Group Reclass Options
TYPE group_reclass_options_rec_type IS RECORD (
     transfer_flag            varchar2(3),
     manual_flag              varchar2(3),
     manual_amount            number,
     group_reclass_type       varchar2(30),
     reserve_amount           number,
     source_exp_amount        number,
     destination_exp_amount   number,
     source_eofy_reserve      number,
     destination_eofy_reserve number);

-- Revaluation Options
TYPE reval_options_rec_type IS RECORD (
     reval_percent            NUMBER,
     value_type               VARCHAR2(3),      -- Bug#6666666 SORP
     mass_reval_id            NUMBER,           -- Bug#6666666 SORP
     linked_flag              VARCHAR2(3),      -- Bug#6666666 SORP
     reval_type_flag          VARCHAR2(3),      -- Bug#6666666 SORP
     override_defaults_flag   VARCHAR2(1),
     reval_fully_rsvd_flag    VARCHAR2(1),
     life_extension_factor    NUMBER,
     life_extension_ceiling   NUMBER,
     max_fully_rsvd_revals    NUMBER,
     run_mode                 VARCHAR2(15));

-- The following record types have been introduced by Retirement API

-- Sub record type
TYPE asset_retire_det_rec_type IS RECORD (
        asset_id                        NUMBER,
        book_type_code                  VARCHAR2(15),
        transaction_header_id_in        NUMBER,
        transaction_header_id_out       NUMBER,
        nbv_retired                     NUMBER,
        gain_loss_amount                NUMBER,
        gain_loss_type_code             VARCHAR2(15),
        itc_recaptured                  NUMBER,
        itc_recapture_id                NUMBER,
        stl_method_code                 VARCHAR2(12),
        stl_life_in_months              NUMBER,
        stl_deprn_amount                NUMBER,
        reval_reserve_retired           NUMBER,
        unrevalued_cost_retired         NUMBER,
        bonus_reserve_retired           NUMBER,
        recapture_amount                NUMBER,
        row_id                          VARCHAR2(150)
        );

-- Main record type
TYPE asset_retire_rec_type IS RECORD (
        retirement_id                   NUMBER,
        date_retired                    DATE,
        units_retired                   NUMBER,
        cost_retired                    NUMBER,
        proceeds_of_sale                NUMBER,
        cost_of_removal                 NUMBER,
        retirement_type_code            VARCHAR2(15),
        retirement_prorate_convention   VARCHAR2(10),
        sold_to                         VARCHAR2(30),
        trade_in_asset_id               VARCHAR2(15),
        reference_num                   VARCHAR2(15),
        status                          VARCHAR2(15),
        recognize_gain_loss             VARCHAR2(30),
        recapture_reserve_flag          VARCHAR2(1),
        limit_proceeds_flag             VARCHAR2(1),
        terminal_gain_loss              VARCHAR2(30),
        reserve_retired                 NUMBER,
        eofy_reserve                    NUMBER,
        reduction_rate                  NUMBER,
        calculate_gain_loss             varchar2(1),
        detail_info                     asset_retire_det_rec_type,
        desc_flex                       desc_flex_rec_type
        );

-- Information used to retire subcomponents of an asset.
TYPE subcomp_rec_type IS RECORD
     (asset_id        NUMBER,
      parent_flag     varchar2(1) := FND_API.G_FALSE
     );

TYPE subcomp_tbl_type IS TABLE OF subcomp_rec_type index by binary_integer;

-- Record type used to store (current) period info
TYPE period_rec_type IS RECORD
     (period_name                 VARCHAR2(15),
      period_counter              NUMBER,
      period_open_date            DATE,
      period_close_date           DATE,
      calendar_period_open_date   DATE,
      calendar_period_close_date  DATE,
      deprn_run                   VARCHAR2(1),
      period_num                  NUMBER,
      fiscal_year                 NUMBER,
      fy_start_date               DATE,
      fy_end_date                 DATE
     );

-- end of Retirement API

----------------------------------------------------------------------------
-- Invoice info - because tbl_typeles of invoice exist, we could not include
--                the descriptive flex rec_typeure due to PLS-507
----------------------------------------------------------------------------

------------------------------
-- MRC conversion rate info --
------------------------------

TYPE inv_rate_rec_type IS RECORD (
      inv_indicator                   NUMBER  ,
      set_of_books_id                 NUMBER  ,
      exchange_rate                   NUMBER  ,
      cost                            NUMBER
     );

TYPE inv_rate_tbl_type IS TABLE OF inv_rate_rec_type  index by binary_integer;

TYPE inv_rec_type IS RECORD (
      po_vendor_id                   NUMBER,
      asset_invoice_id               NUMBER,
      fixed_assets_cost              NUMBER,
      deleted_flag                   varchar2(3),
      po_number                      varchar2(20),
      invoice_number                 varchar2(50),
      payables_batch_name            varchar2(50),
      payables_code_combination_id   NUMBER,
      feeder_system_name             varchar2(40),
      create_batch_date              DATE,
      create_batch_id                NUMBER,
      invoice_date                   DATE,
      payables_cost                  NUMBER,
      post_batch_id                  NUMBER,
      invoice_id                     NUMBER,
      ap_distribution_line_number    NUMBER,
      payables_units                 NUMBER,
      split_merged_code              varchar2(3),
      description                    varchar2(80),
      parent_mass_addition_id        VARCHAR2(15),
      unrevalued_cost                NUMBER,
      merged_code                    varchar2(3),
      split_code                     varchar2(3),
      merge_parent_mass_additions_id NUMBER,
      split_parent_mass_additions_id NUMBER,
      project_asset_line_id          NUMBER,
      project_id                     NUMBER,
      task_id                        NUMBER,
      source_line_id                 NUMBER,
      prior_source_line_id           NUMBER,
      material_indicator_flag        varchar2(1),
      attribute1                     varchar2(150),
      attribute2                     varchar2(150),
      attribute3                     varchar2(150),
      attribute4                     varchar2(150),
      attribute5                     varchar2(150),
      attribute6                     varchar2(150),
      attribute7                     varchar2(150),
      attribute8                     varchar2(150),
      attribute9                     varchar2(150),
      attribute10                    varchar2(150),
      attribute11                    varchar2(150),
      attribute12                    varchar2(150),
      attribute13                    varchar2(150),
      attribute14                    varchar2(150),
      attribute15                    varchar2(150),
      attribute_category_code        varchar2(150),

      cip_cost                       NUMBER,
      depreciate_in_group_flag       varchar2(1),

      inv_indicator                  NUMBER ,
      ytd_deprn                      NUMBER ,
      deprn_reserve                  NUMBER ,
      bonus_ytd_deprn                NUMBER ,
      bonus_deprn_reserve            NUMBER ,
      reval_amortization_basis       NUMBER ,
      reval_ytd_deprn                NUMBER ,
      reval_deprn_reserve            NUMBER ,
      source_dest_code               VARCHAR2(15),
      invoice_distribution_id        NUMBER,
      invoice_line_number            NUMBER,
      po_distribution_id             NUMBER,
      inv_rate_tbl                   inv_rate_tbl_type
     );

TYPE inv_tbl_type IS TABLE OF inv_rec_type index by binary_integer;


---------------------------------
-- Tax Reserve Adjustment info --
---------------------------------

TYPE asset_tax_rsv_adj_rec_type IS RECORD (
      fiscal_year              NUMBER,
      adjusted_ytd_deprn       NUMBER,
      deprn_basis_formula      VARCHAR2(30),
      deprn_adj_factor         NUMBER,
      max_period_ctr_adjusted  NUMBER,
      min_period_ctr_adjusted  NUMBER,
      run_mode                 VARCHAR2(15)
     );


---------------------------------------------------
-- Private Types (used within internals of APIs) --
---------------------------------------------------

TYPE asset_fin_tbl_type IS TABLE OF asset_fin_rec_type index by binary_integer;

TYPE asset_deprn_tbl_type IS TABLE OF asset_deprn_rec_type index by binary_integer;

TYPE inv_trans_rec_type IS RECORD (
      invoice_transaction_id  NUMBER     ,
      transaction_type        VARCHAR2(20)
     );

------------------------------------------
-- Standard types for FA Table Handlers --
------------------------------------------

TYPE unplanned_deprn_rec_type IS RECORD (
     code_combination_id     NUMBER,
     unplanned_amount        NUMBER,
     unplanned_type          VARCHAR2(9)
    );

TYPE trx_ref_rec_type is RECORD (
        TRX_REFERENCE_ID                NUMBER(15),
        TRANSACTION_TYPE                VARCHAR2(30),
        SRC_TRANSACTION_SUBTYPE         VARCHAR2(30),
        DEST_TRANSACTION_SUBTYPE        VARCHAR2(30),
        BOOK_TYPE_CODE                  VARCHAR2(15),
        SRC_ASSET_ID                    NUMBER(15),
        SRC_TRANSACTION_HEADER_ID       NUMBER(15),
        DEST_ASSET_ID                   NUMBER(15),
        DEST_TRANSACTION_HEADER_ID      NUMBER(15),
        MEMBER_ASSET_ID                 NUMBER(15),
        MEMBER_TRANSACTION_HEADER_ID    NUMBER(15),
        SRC_AMORTIZATION_START_DATE     DATE,
        DEST_AMORTIZATION_START_DATE    DATE,
        RESERVE_TRANSFER_AMOUNT         NUMBER,
        SRC_EXPENSE_AMOUNT              NUMBER,
        DEST_EXPENSE_AMOUNT             NUMBER,
        SRC_EOFY_RESERVE                NUMBER,
        DEST_EOFY_RESERVE               NUMBER);



/*

------------------------------------------
-- Standard types for FA Table Handlers --
------------------------------------------

--   FA_ADDITIONS

TYPE Asset_Id_tbl_type IS TABLE OF                FA_ADDITIONS_B.ASSET_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Asset_Number_tbl_type IS TABLE OF            FA_ADDITIONS_B.ASSET_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Asset_Key_Ccid_tbl_type IS TABLE OF          FA_ADDITIONS_B.ASSET_KEY_CCID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Units_tbl_type IS TABLE OF                   FA_ADDITIONS_B.CURRENT_UNITS%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Asset_Type_tbl_type IS TABLE OF              FA_ADDITIONS_B.ASSET_TYPE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Tag_Number_tbl_type IS TABLE OF              FA_ADDITIONS_B.TAG_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Description_tbl_type IS TABLE OF             FA_ADDITIONS_TL.DESCRIPTION%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Category_Id_tbl_type IS TABLE OF             FA_ADDITIONS_B.ASSET_CATEGORY_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Manufacturer_Name_tbl_type IS TABLE OF       FA_ADDITIONS_B.MANUFACTURER_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Serial_Number_tbl_type IS TABLE OF           FA_ADDITIONS_B.SERIAL_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Model_Number_tbl_type IS TABLE OF            FA_ADDITIONS_B.MODEL_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Property_Type_Code_tbl_type IS TABLE OF      FA_ADDITIONS_B.PROPERTY_TYPE_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Property_1245_1250_Code_tbl_type IS TABLE OF FA_ADDITIONS_B.PROPERTY_1245_1250_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE In_Use_Flag_tbl_type IS TABLE OF             FA_ADDITIONS_B.IN_USE_FLAG%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Owned_Leased_tbl_type IS TABLE OF            FA_ADDITIONS_B.OWNED_LEASED%TYPE
     INDEX BY BINARY_INTEGER;

TYPE New_Used_tbl_type IS TABLE OF                FA_ADDITIONS_B.NEW_USED%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Unit_Adjustment_Flag_tbl_type IS TABLE OF    FA_ADDITIONS_B.UNIT_ADJUSTMENT_FLAG%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Add_Cost_Je_Flag_tbl_type IS TABLE OF        FA_ADDITIONS_B.ADD_COST_JE_FLAG%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Attribute_tbl_type  IS TABLE OF              FA_ADDITIONS_B.ATTRIBUTE1%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Attribute_Category_Code_tbl_type IS TABLE OF FA_ADDITIONS_B.ATTRIBUTE_CATEGORY_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE gf_Attribute IS TABLE OF                     FA_ADDITIONS_B.GLOBAL_ATTRIBUTE1%TYPE
     INDEX BY BINARY_INTEGER;

TYPE gf_Attribute_Category_Code_tbl_type IS TABLE OF     FA_ADDITIONS_B.GLOBAL_ATTRIBUTE_CATEGORY%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Context_tbl_type IS TABLE OF                 FA_ADDITIONS_B.CONTEXT%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Lease_Id_tbl_type IS TABLE OF                FA_ADDITIONS_B.LEASE_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Inventorial_tbl_type IS TABLE OF             FA_ADDITIONS_B.INVENTORIAL%TYPE
     INDEX BY BINARY_INTEGER;


----------------
-- not needed --
----------------

-- TYPE Last_Update_Date_tbl_type IS TABLE OF        FA_ADDITIONS_B.LAST_UPDATE_DATE%TYPE
--      INDEX BY BINARY_INTEGER;
--
-- TYPE Last_Updated_By_tbl_type IS TABLE OF         FA_ADDITIONS_B.LAST_UPDATED_BY%TYPE
--      INDEX BY BINARY_INTEGER;
--
-- TYPE Created_By_tbl_type IS TABLE OF              FA_ADDITIONS_B.CREATED_BY%TYPE
--      INDEX BY BINARY_INTEGER;
--
-- TYPE Creation_Date_tbl_type IS TABLE OF           FA_ADDITIONS_B.CREATION_DATE%TYPE
--      INDEX BY BINARY_INTEGER;
--
-- TYPE Last_Update_Login_tbl_type IS TABLE OF       FA_ADDITIONS_B.LAST_UPDATE_LOGIN%TYPE
--      INDEX BY BINARY_INTEGER;
--


-------------
-- generic --
-------------

TYPE updated_by_tbl_type IS TABLE OF              FA_ADDITIONS_B.CREATED_BY%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Date_tbl_type IS TABLE OF                    FA_ADDITIONS_B.CREATION_DATE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Login_tbl_type IS TABLE OF                   FA_ADDITIONS_B.LAST_UPDATE_LOGIN%TYPE
     INDEX BY BINARY_INTEGER;


--------------------
-- FA_ADJUSTMENTS --
--------------------
TYPE Source_Type_Code_tbl_type IS TABLE OF        FA_ADJUSTMENTS.source_type_code%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Adjustment_Type_tbl_type IS TABLE OF         FA_ADJUSTMENTS.adjustment_type%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Debit_Credit_Flag_tbl_type IS TABLE OF       FA_ADJUSTMENTS.debit_credit_flag%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Annualized_Adjustment_tbl_type IS TABLE OF   FA_ADJUSTMENTS.annualized_adjustment%TYPE
     INDEX BY BINARY_INTEGER;



-- FA_ASSET_INVOICES

   TYPE Po_Vendor_Id_tbl_type IS TABLE OF               FA_ASSET_INVOICES.Po_Vendor_Id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Asset_Invoice_Id_tbl_type IS TABLE OF           FA_ASSET_INVOICES.Asset_Invoice_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Deleted_Flag_tbl_type IS TABLE OF               FA_ASSET_INVOICES.deleted_flag%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Po_Number_tbl_type IS TABLE OF                  FA_ASSET_INVOICES.po_number%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Invoice_Number_tbl_type IS TABLE OF             FA_ASSET_INVOICES.invoice_number%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Payables_Batch_Name_tbl_type IS TABLE OF        FA_ASSET_INVOICES.payables_batch_name%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Feeder_System_Name_tbl_type IS TABLE OF         FA_ASSET_INVOICES.feeder_system_name%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Create_Batch_Id_tbl_type IS TABLE OF            FA_ASSET_INVOICES.create_batch_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Post_Batch_Id_tbl_type IS TABLE OF              FA_ASSET_INVOICES.post_batch_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Invoice_Id_tbl_type IS TABLE OF                 FA_ASSET_INVOICES.invoice_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Ap_Dist_Line_Num_tbl_type IS TABLE OF           FA_ASSET_INVOICES.AP_DISTRIBUTION_LINE_NUMBER%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Split_Merged_Code_tbl_type IS TABLE OF          FA_ASSET_INVOICES.split_merged_code%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Mass_Addition_Id_tbl_type IS TABLE OF           FA_ASSET_INVOICES.parent_mass_addition_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Merged_Code_tbl_type IS TABLE OF                FA_ASSET_INVOICES.merged_code%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Split_Code_tbl_type IS TABLE OF                 FA_ASSET_INVOICES.split_code%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Project_Asset_Line_Id_tbl_type IS TABLE OF      FA_ASSET_INVOICES.project_asset_line_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Project_Id_tbl_type IS TABLE OF                 FA_ASSET_INVOICES.project_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Task_Id_tbl_type IS TABLE OF                    FA_ASSET_INVOICES.task_id%TYPE
     INDEX BY BINARY_INTEGER;

-----------------------------------
-- FA_ASSET_INVOICE_TRANSACTIONS --
-----------------------------------

   TYPE Invoice_thid_tbl_type IS TABLE OF         FA_INVOICE_TRANSACTIONS.invoice_transaction_id%TYPE
     INDEX BY BINARY_INTEGER;

   TYPE Transaction_Type_tbl_type IS TABLE OF     FA_INVOICE_TRANSACTIONS.transaction_type%TYPE
     INDEX BY BINARY_INTEGER;


------------------------
-- FA_ASSET_INVOICES --
------------------------


--------------
-- FA_BOOKS --
--------------

    TYPE Deprn_Method_Code_tbl_type IS TABLE OF             FA_BOOKS.Deprn_Method_Code%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Life_In_Months_tbl_type IS TABLE OF                FA_BOOKS.Life_In_Months%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Rate_Adjustment_Factor_tbl_type IS TABLE OF        FA_BOOKS.Rate_Adjustment_Factor%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Cost_tbl_type IS TABLE OF                          FA_BOOKS.cost%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Prorate_Convention_Code_tbl_type IS TABLE OF       FA_BOOKS.Prorate_Convention_Code%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Cost_Change_Flag_tbl_type IS TABLE OF              FA_BOOKS.Cost_Change_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Adjustment_Required_Status_tbl_type IS TABLE OF    FA_BOOKS.Adjustment_Required_Status%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Capitalize_Flag_tbl_type IS TABLE OF               FA_BOOKS.Capitalize_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Retirement_Pending_Flag_tbl_type IS TABLE OF       FA_BOOKS.Retirement_Pending_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Depreciate_Flag_tbl_type IS TABLE OF               FA_BOOKS.Depreciate_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Itc_Amount_Id_tbl_type IS TABLE OF                 FA_BOOKS.Itc_Amount_Id%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Itc_Amount_tbl_type IS TABLE OF                    FA_BOOKS.Itc_Amount%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Retirement_Id_tbl_type IS TABLE OF                 FA_BOOKS.Retirement_Id%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Tax_Request_Id_tbl_type IS TABLE OF                FA_BOOKS.Tax_Request_Id%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Itc_Basis_tbl_type IS TABLE OF                     FA_BOOKS.Itc_Basis%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Basic_Rate_tbl_type IS TABLE OF                    FA_BOOKS.Basic_Rate%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Adjusted_Rate_tbl_type IS TABLE OF                 FA_BOOKS.Adjusted_Rate%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Bonus_Rule_tbl_type IS TABLE OF                    FA_BOOKS.Bonus_Rule%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Ceiling_Name_tbl_type IS TABLE OF                  FA_BOOKS.Ceiling_Name%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Adjusted_Capacity_tbl_type IS TABLE OF             FA_BOOKS.Adjusted_Capacity%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Fully_Rsvd_Revals_Counter_tbl_type IS TABLE OF     FA_BOOKS.Fully_Rsvd_Revals_Counter%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Idled_Flag_tbl_type IS TABLE OF                    FA_BOOKS.Idled_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Production_Capacity_tbl_type IS TABLE OF           FA_BOOKS.Production_Capacity%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Reval_Amortization_Basis_tbl_type IS TABLE OF      FA_BOOKS.Reval_Amortization_Basis%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Reval_Ceiling_tbl_type IS TABLE OF                 FA_BOOKS.Reval_Ceiling%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Unit_Of_Measure_tbl_type IS TABLE OF               FA_BOOKS.Unit_Of_Measure%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Annual_Deprn_Rounding_Flag_tbl_type IS TABLE OF    FA_BOOKS.Annual_Deprn_Rounding_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Percent_Salvage_Value_tbl_type IS TABLE OF         FA_BOOKS.Percent_Salvage_Value%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Allowed_Deprn_Limit_tbl_type IS TABLE OF           FA_BOOKS.Allowed_Deprn_Limit%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Allowed_Deprn_Limit_Amount_tbl_type IS TABLE OF    FA_BOOKS.Allowed_Deprn_Limit_Amount%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Short_Fiscal_Year_Flag_tbl_type IS TABLE OF        FA_BOOKS.Short_Fiscal_Year_Flag%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Remaining_Life1_tbl_type IS TABLE OF               FA_BOOKS.Remaining_Life1%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Remaining_Life2_tbl_type IS TABLE OF               FA_BOOKS.Remaining_Life2%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Formula_Factor_tbl_type IS TABLE OF                FA_BOOKS.Formula_Factor%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Group_Asset_ID_tbl_type IS TABLE OF                FA_BOOKS.Group_Asset_ID%TYPE
     INDEX BY BINARY_INTEGER;


-----------------------------
-- FA_DISTRIBUTION_HISTORY --
-----------------------------

    TYPE DISTRIBUTION_ID_tbl_type IS TABLE OF               FA_DISTRIBUTION_HISTORY.DISTRIBUTION_ID%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE CODE_COMBINATION_ID_tbl_type IS TABLE OF           FA_DISTRIBUTION_HISTORY.CODE_COMBINATION_ID%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE LOCATION_ID_tbl_type IS TABLE OF                   FA_DISTRIBUTION_HISTORY.LOCATION_ID%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE ASSIGNED_TO_tbl_type IS TABLE OF                   FA_DISTRIBUTION_HISTORY.ASSIGNED_TO%TYPE
     INDEX BY BINARY_INTEGER;


----------------------
-- FA_DEPRN_SUMMARY --
----------------------


    TYPE DS_Deprn_Source_Code_tbl_type IS TABLE OF          FA_DEPRN_SUMMARY.DEPRN_SOURCE_CODE%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE Bonus_Rate_tbl_type IS TABLE OF                    FA_DEPRN_SUMMARY.BONUS_RATE%TYPE
     INDEX BY BINARY_INTEGER;



---------------------
-- FA_DEPRN_DETAIL --
---------------------

    TYPE DD_Deprn_Source_Code_tbl_type IS TABLE OF          FA_DEPRN_DETAIL.DEPRN_SOURCE_CODE%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE je_line_num_tbl_type IS TABLE OF                   FA_DEPRN_DETAIL.deprn_expense_je_line_num%TYPE
     INDEX BY BINARY_INTEGER;

    TYPE je_header_id_tbl_type IS TABLE OF                  FA_DEPRN_DETAIL.je_header_id%TYPE
     INDEX BY BINARY_INTEGER;

------------------------------
--   FA_TRANSACTION_HEADERS --
------------------------------

TYPE thid_tbl_type IS TABLE OF                          FA_TRANSACTION_HEADERS.TRANSACTION_HEADER_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE Book_Type_Code_tbl_type IS TABLE OF                FA_TRANSACTION_HEADERS.BOOK_TYPE_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE pc_tbl_type IS TABLE OF                            FA_DEPRN_PERIODS.PERIOD_COUNTER%TYPE
     INDEX BY BINARY_INTEGER;

TYPE TRANSACTION_TYPE_CODE_tbl_type IS TABLE OF         FA_TRANSACTION_HEADERS.TRANSACTION_TYPE_CODE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE TRANSACTION_NAME_tbl_type  IS TABLE OF             FA_TRANSACTION_HEADERS.TRANSACTION_NAME%TYPE
     INDEX BY BINARY_INTEGER;

TYPE INVOICE_TRANSACTION_ID_tbl_type  IS TABLE OF       FA_TRANSACTION_HEADERS.INVOICE_TRANSACTION_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE MASS_REFERENCE_ID_tbl_type  IS TABLE OF            FA_TRANSACTION_HEADERS.MASS_REFERENCE_ID%TYPE
     INDEX BY BINARY_INTEGER;

TYPE TRANSACTION_SUBTYPE_tbl_type  IS TABLE OF          FA_TRANSACTION_HEADERS.TRANSACTION_SUBTYPE%TYPE
     INDEX BY BINARY_INTEGER;

TYPE TRANSACTION_KEY_tbl_type IS TABLE OF               FA_TRANSACTION_HEADERS.TRANSACTION_KEY%TYPE
     INDEX BY BINARY_INTEGER;

-----------------------
-- FA_MASS_ADDITIONS --
-----------------------
     TYPE warranty_id_tbl_type                     IS TABLE OF FA_MASS_ADDITIONS.warranty_id%type
          index by binary_integer;
     TYPE lessor_id_tbl_type                       IS TABLE OF FA_MASS_ADDITIONS.lessor_id%type
          index by binary_integer;
     TYPE new_master_flag_tbl_type                 IS TABLE OF FA_MASS_ADDITIONS.new_master_flag%type
          index by binary_integer;
     TYPE amortize_flag_tbl_type                   IS TABLE OF FA_MASS_ADDITIONS.amortize_flag%type
          index by binary_integer;

*/

-- Lease Procedure

TYPE LEASE_DETAILS_REC_TYPE IS RECORD (
        LEASE_ID                        NUMBER,
        LEASE_NUMBER                    VARCHAR2(15),
        LESSOR_ID                       NUMBER(15),
        LESSOR_NAME                     VARCHAR2(240),
        LESSOR_SITE_ID                  NUMBER(15),
        LESSOR_SITE                     VARCHAR2(15),
        LESSOR_SITE_ORG_ID              NUMBER(15),
        PAYMENT_SCHEDULE_ID             NUMBER(15),
        PAYMENT_SCHEDULE_NAME           VARCHAR2(30),
        DESCRIPTION                     VARCHAR2(30),
        CURRENCY_CODE                   VARCHAR2(5),
        LEASE_TYPE                      VARCHAR2(15),
        DIST_CODE_COMBINATION_ID        NUMBER(15),
        CON_DIST_CODE_COMBINATION       VARCHAR2(250),
        TERMS_ID                        NUMBER(15),
        PAYMENT_TERMS                   VARCHAR2(50),
        TRANSFER_OWNERSHIP              VARCHAR2(1),
        BARGAIN_PURCHASE_OPTION         VARCHAR2(1),
        FAIR_VALUE                      NUMBER,
        ASSET_LIFE                      NUMBER,
        LEASE_TERM                      NUMBER,
        DESC_FLEX                       DESC_FLEX_rec_type
);

TYPE LEASE_SCHEDULES_REC_TYPE IS RECORD (
        PAYMENT_SCHEDULE_ID             NUMBER,
        PAYMENT_SCHEDULE_NAME           VARCHAR2(30),
        PRESENT_VALUE                   NUMBER,
        INTEREST_RATE                   NUMBER,
        LEASE_INCEPTION_DATE            DATE,
        CURRENCY_CODE                   VARCHAR2(5),
        FREQUENCY                       VARCHAR2(15)
);

TYPE    LEASE_PAYMENTS_REC_TYPE IS RECORD (
        PAYMENT_SCHEDULE_ID             NUMBER,
        START_DATE                      DATE,
        PAYMENT_AMOUNT                  NUMBER,
        NUMBER_OF_PAYMENTS              NUMBER,
        PAYMENT_TYPE                    VARCHAR2(1)
);

TYPE LEASE_PAYMENTS_TBL_TYPE IS TABLE OF LEASE_PAYMENTS_REC_TYPE
        INDEX BY BINARY_INTEGER;

TYPE LOG_LEVEL_REC_TYPE IS RECORD (
   STATEMENT_LEVEL       BOOLEAN,
   PROCEDURE_LEVEL       BOOLEAN,
   EVENT_LEVEL           BOOLEAN,
   EXCEPTION_LEVEL       BOOLEAN,
   ERROR_LEVEL           BOOLEAN,
   UNEXPECTED_LEVEL      BOOLEAN,
   CURRENT_RUNTIME_LEVEL NUMBER,
   INITIALIZED           BOOLEAN DEFAULT FALSE
);


  ---------------------------------
  -- Transaction Interface Table --
  ---------------------------------
  TYPE trans_interface_rec_type IS RECORD(
    TRANSACTION_INTERFACE_ID      NUMBER(15),
    TRANSACTION_DATE              DATE,
    TRANSACTION_TYPE_CODE         VARCHAR2(30),
    POSTING_STATUS                VARCHAR2(30),
    BOOK_TYPE_CODE                VARCHAR2(15),
    ASSET_KEY_PROJECT_VALUE       VARCHAR2(30),
    ASSET_KEY_HIERARCHY_VALUE     VARCHAR2(30),
    ASSET_KEY_NEW_HIERARCHY_VALUE VARCHAR2(30),
    REFERENCE_NUMBER              NUMBER,
    COMMENTS                      VARCHAR2(80),
    CONCURRENT_REQUEST_ID         NUMBER(15),
    CREATED_BY                    NUMBER(15),
    CREATION_DATE                 DATE,
    LAST_UPDATED_BY               NUMBER(15),
    LAST_UPDATE_DATE              DATE,
    LAST_UPDATE_LOGIN             NUMBER(15));

  --Bug 8941132: Creating new structure for Amortization InitMemberTable

  TYPE tab_num15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  TYPE tab_num_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  -----------------------------------
  -- Amortization InitMemberTable --
  -----------------------------------
  TYPE amort_init_rec_type IS RECORD(
    tmd_period_counter        tab_num15_type,
    tmd_cost                  tab_num_type,
    tm_cost                   tab_num_type,
    tmd_cip_cost              tab_num_type,
    tm_cip_cost               tab_num_type,
    tmd_salvage_value         tab_num_type,
    tm_salvage_value          tab_num_type,
    tmd_deprn_limit_amount    tab_num_type,
    tm_deprn_limit_amount     tab_num_type);

END FA_API_TYPES;


/
