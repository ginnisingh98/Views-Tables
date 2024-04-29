--------------------------------------------------------
--  DDL for Package Body FA_CREATE_GROUP_ASSET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CREATE_GROUP_ASSET_PKG" as
/* $Header: FACGRPAB.pls 120.5.12010000.3 2010/03/04 23:29:45 glchen ship $ */

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations
  -- Function and procedure implementations
  function create_group_asset(px_group_asset_rec IN out NOCOPY group_asset_rec_type,
                              p_log_level_rec    IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    l_debug_str  varchar2(1000);
    l_status     varchar2(5);
    l_mesg_count number;
    l_mesg       varchar2(4000);

    TYPE varchar30_tbl IS TABLE OF varchar2(30) INDEX BY BINARY_INTEGER;
    TYPE num_tbl IS TABLE OF number INDEX BY BINARY_INTEGER;
    l_seg_num      num_tbl;
    l_akey_segment varchar30_tbl;
    l_cat_segment  varchar30_tbl;

    l_mass_add_rec FA_MASSADD_PREPARE_PKG.mass_add_rec;
    l_batch_size   number := 500;

    l_here_key_seg       varchar2(30);
    l_here_key_seg_val   varchar2(30);
    l_here_key_seg_index number;

    l_major_cat_seg       varchar2(30);
    l_major_cat_seg_val   varchar2(30);
    l_major_cat_seg_index number;

    l_akey_grp_seg       varchar2(30);
    l_akey_grp_seg_val   varchar2(30);
    l_akey_grp_seg_index number;

    l_cat_grp_seg       varchar2(30);
    l_cat_grp_seg_val   varchar2(30);
    l_cat_grp_seg_index number;

    l_value_set_name varchar2(60);

    l_akey_ccid number;
    l_cat_id    number;

    l_parent_value varchar2(60);

    l_major_category varchar2(30);

    l_index number;

    l_temp number;

    l_parent_asset_id number;
    l_category_id     number;

    l_trans_rec           FA_API_TYPES.trans_rec_type;
    l_dist_trans_rec      FA_API_TYPES.trans_rec_type;
    l_asset_hdr_rec       FA_API_TYPES.asset_hdr_rec_type;
    l_asset_desc_rec      FA_API_TYPES.asset_desc_rec_type;
    l_asset_cat_rec       FA_API_TYPES.asset_cat_rec_type;
    l_asset_type_rec      FA_API_TYPES.asset_type_rec_type;
    l_asset_hierarchy_rec FA_API_TYPES.asset_hierarchy_rec_type;
    l_asset_fin_rec       FA_API_TYPES.asset_fin_rec_type;
    l_asset_deprn_rec     FA_API_TYPES.asset_deprn_rec_type;
    l_asset_dist_rec      FA_API_TYPES.asset_dist_rec_type;
    l_asset_dist_tbl      FA_API_TYPES.asset_dist_tbl_type;
    l_inv_tbl             FA_API_TYPES.inv_tbl_type;
    l_inv_rate_tbl        FA_API_TYPES.inv_rate_tbl_type;
    l_calling_fn          varchar2(40) := 'create_group_asset';

    l_asset_type                varchar2(15);
    l_CALENDAR_PERIOD_OPEN_DATE date;

    l_asset_fin_rec_adj         FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_rec_new         FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;
    l_inv_trans_rec             FA_API_TYPES.inv_trans_rec_type;
    l_asset_deprn_rec_adj       FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_rec_new       FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_mrc_tbl_new   FA_API_TYPES.asset_deprn_tbl_type;
    l_inv_rec                   FA_API_TYPES.inv_rec_type;
    l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;
    l_return_status             VARCHAR2(1);

    CURSOR lookup_cur(c_lookup_type varchar2) IS
      select lookup_code
        from fa_lookups
       where lookup_type = c_lookup_type
         and enabled_flag = 'Y';
    cursor get_group_asset(l_asset_key_ccid number, l_category_id number) is
      select asset_id, asset_category_id, parent_asset_id, asset_key_ccid
        from fa_additions
       where asset_category_id = l_category_id
         and asset_key_ccid = l_asset_key_ccid;
  begin

    if (px_group_asset_rec.rec_mode = 'PREPARE') then
      for i in 1 .. 30 loop
        l_akey_segment(i) := null;
        l_seg_num(i) := -1;
        l_cat_segment(i) := null;
      end loop;

      l_debug_str := 'Get the Hierarchy Segment Mapping';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('ASSET KEY HIERARCHY MAPPING') LOOP
        l_here_key_seg       := rec.lookup_code;
        l_here_key_seg_index := to_number(substr(l_here_key_seg, 8));
      END LOOP;

      l_debug_str := 'Get the Major Category Segment Mapping';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      if not
          FND_FLEX_APIS.get_segment_column(x_application_id  => 140,
                                           x_id_flex_code    => 'CAT#',
                                           x_id_flex_num     => 101,
                                           x_seg_attr_type   => 'BASED_CATEGORY',
                                           x_app_column_name => l_major_cat_seg) then
        null;
      end if;

      l_major_cat_seg_index := to_number(substr(l_major_cat_seg, 8));

      l_debug_str := 'Get the Asset Key Project Segment Mapping';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('ASSET KEY PROJECT MAPPING') LOOP
        l_akey_grp_seg       := rec.lookup_code;
        l_akey_grp_seg_index := to_number(substr(l_akey_grp_seg, 8));
      END LOOP;

      l_debug_str := 'Get the Asset Key Group value';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('GROUP VAL IN AKEY PROJECT') LOOP
        l_akey_grp_seg_val := rec.lookup_code;
      END LOOP;

      l_debug_str := 'Get the CAtegory Group Segment Mapping';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('GROUP MAPPING IN CAT FLEX') LOOP
        l_cat_grp_seg       := rec.lookup_code;
        l_cat_grp_seg_index := to_number(substr(l_cat_grp_seg, 8));
      END LOOP;

      l_debug_str := 'Get the Category Group value';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('GROUP VAL IN CAT FLEX') LOOP
        l_cat_grp_seg_val := rec.lookup_code;
      END LOOP;

      l_debug_str := 'Get the source for asset key bierarchy mapping';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      FOR rec IN lookup_cur('ASSET KEY HIERARCHY SOURCE') LOOP
        l_value_set_name := rec.lookup_code;
      END LOOP;

      l_debug_str := 'Processing mass addition line';
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => p_log_level_rec);
      end if;
      Select MASS_ADDITION_ID,
             ASSET_NUMBER,
             TAG_NUMBER,
             DESCRIPTION,
             ASSET_CATEGORY_ID,
             MANUFACTURER_NAME,
             SERIAL_NUMBER,
             MODEL_NUMBER,
             BOOK_TYPE_CODE,
             DATE_PLACED_IN_SERVICE,
             FIXED_ASSETS_COST,
             PAYABLES_UNITS,
             FIXED_ASSETS_UNITS,
             PAYABLES_CODE_COMBINATION_ID,
             EXPENSE_CODE_COMBINATION_ID,
             LOCATION_ID,
             ASSIGNED_TO,
             FEEDER_SYSTEM_NAME,
             CREATE_BATCH_DATE,
             CREATE_BATCH_ID,
             LAST_UPDATE_DATE,
             LAST_UPDATED_BY,
             REVIEWER_COMMENTS,
             INVOICE_NUMBER,
             INVOICE_LINE_NUMBER,
             INVOICE_DISTRIBUTION_ID,
             VENDOR_NUMBER,
             PO_VENDOR_ID,
             PO_NUMBER,
             POSTING_STATUS,
             QUEUE_NAME,
             INVOICE_DATE,
             INVOICE_CREATED_BY,
             INVOICE_UPDATED_BY,
             PAYABLES_COST,
             INVOICE_ID,
             PAYABLES_BATCH_NAME,
             DEPRECIATE_FLAG,
             PARENT_MASS_ADDITION_ID,
             PARENT_ASSET_ID,
             SPLIT_MERGED_CODE,
             AP_DISTRIBUTION_LINE_NUMBER,
             POST_BATCH_ID,
             ADD_TO_ASSET_ID,
             AMORTIZE_FLAG,
             NEW_MASTER_FLAG,
             ASSET_KEY_CCID,
             ASSET_TYPE,
             DEPRN_RESERVE,
             YTD_DEPRN,
             BEGINNING_NBV,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATE_LOGIN,
             SALVAGE_VALUE,
             ACCOUNTING_DATE,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             ATTRIBUTE_CATEGORY_CODE,
             FULLY_RSVD_REVALS_COUNTER,
             MERGE_INVOICE_NUMBER,
             MERGE_VENDOR_NUMBER,
             PRODUCTION_CAPACITY,
             REVAL_AMORTIZATION_BASIS,
             REVAL_RESERVE,
             UNIT_OF_MEASURE,
             UNREVALUED_COST,
             YTD_REVAL_DEPRN_EXPENSE,
             ATTRIBUTE16,
             ATTRIBUTE17,
             ATTRIBUTE18,
             ATTRIBUTE19,
             ATTRIBUTE20,
             ATTRIBUTE21,
             ATTRIBUTE22,
             ATTRIBUTE23,
             ATTRIBUTE24,
             ATTRIBUTE25,
             ATTRIBUTE26,
             ATTRIBUTE27,
             ATTRIBUTE28,
             ATTRIBUTE29,
             ATTRIBUTE30,
             MERGED_CODE,
             SPLIT_CODE,
             MERGE_PARENT_MASS_ADDITIONS_ID,
             SPLIT_PARENT_MASS_ADDITIONS_ID,
             PROJECT_ASSET_LINE_ID,
             PROJECT_ID,
             TASK_ID,
             SUM_UNITS,
             DIST_NAME,
             GLOBAL_ATTRIBUTE1,
             GLOBAL_ATTRIBUTE2,
             GLOBAL_ATTRIBUTE3,
             GLOBAL_ATTRIBUTE4,
             GLOBAL_ATTRIBUTE5,
             GLOBAL_ATTRIBUTE6,
             GLOBAL_ATTRIBUTE7,
             GLOBAL_ATTRIBUTE8,
             GLOBAL_ATTRIBUTE9,
             GLOBAL_ATTRIBUTE10,
             GLOBAL_ATTRIBUTE11,
             GLOBAL_ATTRIBUTE12,
             GLOBAL_ATTRIBUTE13,
             GLOBAL_ATTRIBUTE14,
             GLOBAL_ATTRIBUTE15,
             GLOBAL_ATTRIBUTE16,
             GLOBAL_ATTRIBUTE17,
             GLOBAL_ATTRIBUTE18,
             GLOBAL_ATTRIBUTE19,
             GLOBAL_ATTRIBUTE20,
             GLOBAL_ATTRIBUTE_CATEGORY,
             CONTEXT,
             INVENTORIAL,
             SHORT_FISCAL_YEAR_FLAG,
             CONVERSION_DATE,
             ORIGINAL_DEPRN_START_DATE,
             GROUP_ASSET_ID,
             CUA_PARENT_HIERARCHY_ID,
             UNITS_TO_ADJUST,
             BONUS_YTD_DEPRN,
             BONUS_DEPRN_RESERVE,
             AMORTIZE_NBV_FLAG,
             AMORTIZATION_START_DATE,
             TRANSACTION_TYPE_CODE,
             TRANSACTION_DATE,
             WARRANTY_ID,
             LEASE_ID,
             LESSOR_ID,
             PROPERTY_TYPE_CODE,
             PROPERTY_1245_1250_CODE,
             IN_USE_FLAG,
             OWNED_LEASED,
             NEW_USED,
             ASSET_ID,
             MATERIAL_INDICATOR_FLAG,
             cast(multiset (select MASSADD_DIST_ID dist_id,
                          MASS_ADDITION_ID mass_add_id,
                          UNITS,
                          DEPRN_EXPENSE_CCID,
                          LOCATION_ID,
                          EMPLOYEE_ID
                     from FA_MASSADD_DISTRIBUTIONS mass_dist
                    where mass_dist.mass_addition_id =
                          mass_add.mass_addition_id) as
                  fa_mass_add_dist_tbl) dists
        into l_mass_add_rec.MASS_ADDITION_ID,
             l_mass_add_rec.ASSET_NUMBER,
             l_mass_add_rec.TAG_NUMBER,
             l_mass_add_rec.DESCRIPTION,
             l_mass_add_rec.ASSET_CATEGORY_ID,
             l_mass_add_rec.MANUFACTURER_NAME,
             l_mass_add_rec.SERIAL_NUMBER,
             l_mass_add_rec.MODEL_NUMBER,
             l_mass_add_rec.BOOK_TYPE_CODE,
             l_mass_add_rec.DATE_PLACED_IN_SERVICE,
             l_mass_add_rec.FIXED_ASSETS_COST,
             l_mass_add_rec.PAYABLES_UNITS,
             l_mass_add_rec.FIXED_ASSETS_UNITS,
             l_mass_add_rec.PAYABLES_CODE_COMBINATION_ID,
             l_mass_add_rec.EXPENSE_CODE_COMBINATION_ID,
             l_mass_add_rec.LOCATION_ID,
             l_mass_add_rec.ASSIGNED_TO,
             l_mass_add_rec.FEEDER_SYSTEM_NAME,
             l_mass_add_rec.CREATE_BATCH_DATE,
             l_mass_add_rec.CREATE_BATCH_ID,
             l_mass_add_rec.LAST_UPDATE_DATE,
             l_mass_add_rec.LAST_UPDATED_BY,
             l_mass_add_rec.REVIEWER_COMMENTS,
             l_mass_add_rec.INVOICE_NUMBER,
             l_mass_add_rec.INVOICE_LINE_NUMBER,
             l_mass_add_rec.INVOICE_DISTRIBUTION_ID,
             l_mass_add_rec.VENDOR_NUMBER,
             l_mass_add_rec.PO_VENDOR_ID,
             l_mass_add_rec.PO_NUMBER,
             l_mass_add_rec.POSTING_STATUS,
             l_mass_add_rec.QUEUE_NAME,
             l_mass_add_rec.INVOICE_DATE,
             l_mass_add_rec.INVOICE_CREATED_BY,
             l_mass_add_rec.INVOICE_UPDATED_BY,
             l_mass_add_rec.PAYABLES_COST,
             l_mass_add_rec.INVOICE_ID,
             l_mass_add_rec.PAYABLES_BATCH_NAME,
             l_mass_add_rec.DEPRECIATE_FLAG,
             l_mass_add_rec.PARENT_MASS_ADDITION_ID,
             l_mass_add_rec.PARENT_ASSET_ID,
             l_mass_add_rec.SPLIT_MERGED_CODE,
             l_mass_add_rec.AP_DISTRIBUTION_LINE_NUMBER,
             l_mass_add_rec.POST_BATCH_ID,
             l_mass_add_rec.ADD_TO_ASSET_ID,
             l_mass_add_rec.AMORTIZE_FLAG,
             l_mass_add_rec.NEW_MASTER_FLAG,
             l_mass_add_rec.ASSET_KEY_CCID,
             l_mass_add_rec.ASSET_TYPE,
             l_mass_add_rec.DEPRN_RESERVE,
             l_mass_add_rec.YTD_DEPRN,
             l_mass_add_rec.BEGINNING_NBV,
             l_mass_add_rec.CREATED_BY,
             l_mass_add_rec.CREATION_DATE,
             l_mass_add_rec.LAST_UPDATE_LOGIN,
             l_mass_add_rec.SALVAGE_VALUE,
             l_mass_add_rec.ACCOUNTING_DATE,
             l_mass_add_rec.ATTRIBUTE1,
             l_mass_add_rec.ATTRIBUTE2,
             l_mass_add_rec.ATTRIBUTE3,
             l_mass_add_rec.ATTRIBUTE4,
             l_mass_add_rec.ATTRIBUTE5,
             l_mass_add_rec.ATTRIBUTE6,
             l_mass_add_rec.ATTRIBUTE7,
             l_mass_add_rec.ATTRIBUTE8,
             l_mass_add_rec.ATTRIBUTE9,
             l_mass_add_rec.ATTRIBUTE10,
             l_mass_add_rec.ATTRIBUTE11,
             l_mass_add_rec.ATTRIBUTE12,
             l_mass_add_rec.ATTRIBUTE13,
             l_mass_add_rec.ATTRIBUTE14,
             l_mass_add_rec.ATTRIBUTE15,
             l_mass_add_rec.ATTRIBUTE_CATEGORY_CODE,
             l_mass_add_rec.FULLY_RSVD_REVALS_COUNTER,
             l_mass_add_rec.MERGE_INVOICE_NUMBER,
             l_mass_add_rec.MERGE_VENDOR_NUMBER,
             l_mass_add_rec.PRODUCTION_CAPACITY,
             l_mass_add_rec.REVAL_AMORTIZATION_BASIS,
             l_mass_add_rec.REVAL_RESERVE,
             l_mass_add_rec.UNIT_OF_MEASURE,
             l_mass_add_rec.UNREVALUED_COST,
             l_mass_add_rec.YTD_REVAL_DEPRN_EXPENSE,
             l_mass_add_rec.ATTRIBUTE16,
             l_mass_add_rec.ATTRIBUTE17,
             l_mass_add_rec.ATTRIBUTE18,
             l_mass_add_rec.ATTRIBUTE19,
             l_mass_add_rec.ATTRIBUTE20,
             l_mass_add_rec.ATTRIBUTE21,
             l_mass_add_rec.ATTRIBUTE22,
             l_mass_add_rec.ATTRIBUTE23,
             l_mass_add_rec.ATTRIBUTE24,
             l_mass_add_rec.ATTRIBUTE25,
             l_mass_add_rec.ATTRIBUTE26,
             l_mass_add_rec.ATTRIBUTE27,
             l_mass_add_rec.ATTRIBUTE28,
             l_mass_add_rec.ATTRIBUTE29,
             l_mass_add_rec.ATTRIBUTE30,
             l_mass_add_rec.MERGED_CODE,
             l_mass_add_rec.SPLIT_CODE,
             l_mass_add_rec.MERGE_PARENT_MASS_ADD_ID,
             l_mass_add_rec.SPLIT_PARENT_MASS_ADD_ID,
             l_mass_add_rec.PROJECT_ASSET_LINE_ID,
             l_mass_add_rec.PROJECT_ID,
             l_mass_add_rec.TASK_ID,
             l_mass_add_rec.SUM_UNITS,
             l_mass_add_rec.DIST_NAME,
             l_mass_add_rec.GLOBAL_ATTRIBUTE1,
             l_mass_add_rec.GLOBAL_ATTRIBUTE2,
             l_mass_add_rec.GLOBAL_ATTRIBUTE3,
             l_mass_add_rec.GLOBAL_ATTRIBUTE4,
             l_mass_add_rec.GLOBAL_ATTRIBUTE5,
             l_mass_add_rec.GLOBAL_ATTRIBUTE6,
             l_mass_add_rec.GLOBAL_ATTRIBUTE7,
             l_mass_add_rec.GLOBAL_ATTRIBUTE8,
             l_mass_add_rec.GLOBAL_ATTRIBUTE9,
             l_mass_add_rec.GLOBAL_ATTRIBUTE10,
             l_mass_add_rec.GLOBAL_ATTRIBUTE11,
             l_mass_add_rec.GLOBAL_ATTRIBUTE12,
             l_mass_add_rec.GLOBAL_ATTRIBUTE13,
             l_mass_add_rec.GLOBAL_ATTRIBUTE14,
             l_mass_add_rec.GLOBAL_ATTRIBUTE15,
             l_mass_add_rec.GLOBAL_ATTRIBUTE16,
             l_mass_add_rec.GLOBAL_ATTRIBUTE17,
             l_mass_add_rec.GLOBAL_ATTRIBUTE18,
             l_mass_add_rec.GLOBAL_ATTRIBUTE19,
             l_mass_add_rec.GLOBAL_ATTRIBUTE20,
             l_mass_add_rec.GLOBAL_ATTRIBUTE_CATEGORY,
             l_mass_add_rec.CONTEXT,
             l_mass_add_rec.INVENTORIAL,
             l_mass_add_rec.SHORT_FISCAL_YEAR_FLAG,
             l_mass_add_rec.CONVERSION_DATE,
             l_mass_add_rec.ORIGINAL_DEPRN_START_DATE,
             l_mass_add_rec.GROUP_ASSET_ID,
             l_mass_add_rec.CUA_PARENT_HIERARCHY_ID,
             l_mass_add_rec.UNITS_TO_ADJUST,
             l_mass_add_rec.BONUS_YTD_DEPRN,
             l_mass_add_rec.BONUS_DEPRN_RESERVE,
             l_mass_add_rec.AMORTIZE_NBV_FLAG,
             l_mass_add_rec.AMORTIZATION_START_DATE,
             l_mass_add_rec.TRANSACTION_TYPE_CODE,
             l_mass_add_rec.TRANSACTION_DATE,
             l_mass_add_rec.WARRANTY_ID,
             l_mass_add_rec.LEASE_ID,
             l_mass_add_rec.LESSOR_ID,
             l_mass_add_rec.PROPERTY_TYPE_CODE,
             l_mass_add_rec.PROPERTY_1245_1250_CODE,
             l_mass_add_rec.IN_USE_FLAG,
             l_mass_add_rec.OWNED_LEASED,
             l_mass_add_rec.NEW_USED,
             l_mass_add_rec.ASSET_ID,
             l_mass_add_rec.MATERIAL_INDICATOR_FLAG,
             l_mass_add_rec.distributions_table
        FROM fa_mass_additions mass_add
       where mass_addition_id = px_group_asset_rec.mass_addition_id;

      l_akey_ccid := l_mass_add_rec.asset_key_ccid;
      SELECT segment1,
             segment2,
             segment3,
             segment4,
             segment5,
             segment6,
             segment7,
             segment8,
             segment9,
             segment10
        INTO l_akey_segment(1),
             l_akey_segment(2),
             l_akey_segment(3),
             l_akey_segment(4),
             l_akey_segment(5),
             l_akey_segment(6),
             l_akey_segment(7),
             l_akey_segment(8),
             l_akey_segment(9),
             l_akey_segment(10)
        FROM fa_asset_keywords
       WHERE code_combination_id = l_akey_ccid;

      l_here_key_seg_val := l_akey_segment(l_here_key_seg_index);

      select parent_flex_value
        into l_parent_value
        from FND_FLEX_VALUE_NORM_HIERARCHY val_norm,
             fnd_flex_value_sets           val_set
       where val_norm.flex_value_set_id = val_set.flex_value_set_id
         and val_set.flex_value_set_name = l_value_set_name
         and l_here_key_seg_val between val_norm.child_flex_value_low and
             val_norm.child_flex_value_high;

      select segment1,
             segment2,
             segment3,
             segment4,
             segment5,
             segment6,
             segment7
        into l_cat_segment(1),
             l_cat_segment(2),
             l_cat_segment(3),
             l_cat_segment(4),
             l_cat_segment(5),
             l_cat_segment(6),
             l_cat_segment(7)
        from fa_categories
       where category_id = l_mass_add_rec.asset_category_id;

      l_major_category := l_cat_segment(l_major_cat_seg_index);

      l_akey_segment(l_here_key_seg_index) := l_parent_value;
      l_akey_segment(l_akey_grp_seg_index) := l_akey_grp_seg_val;
      begin
        select code_combination_id
          into l_akey_ccid
          from fa_asset_keywords
         where decode(l_akey_segment(1), null, '-1', segment1) =
               decode(l_akey_segment(1), null, '-1', l_akey_segment(1))
           and decode(l_akey_segment(2), null, '-1', segment2) =
               decode(l_akey_segment(2), null, '-1', l_akey_segment(2))
           and decode(l_akey_segment(3), null, '-1', segment3) =
               decode(l_akey_segment(3), null, '-1', l_akey_segment(3))
           and decode(l_akey_segment(4), null, '-1', segment4) =
               decode(l_akey_segment(4), null, '-1', l_akey_segment(4))
           and decode(l_akey_segment(5), null, '-1', segment5) =
               decode(l_akey_segment(5), null, '-1', l_akey_segment(5))
           and decode(l_akey_segment(6), null, '-1', segment6) =
               decode(l_akey_segment(6), null, '-1', l_akey_segment(6))
           and decode(l_akey_segment(7), null, '-1', segment7) =
               decode(l_akey_segment(7), null, '-1', l_akey_segment(7))
           and decode(l_akey_segment(8), null, '-1', segment8) =
               decode(l_akey_segment(8), null, '-1', l_akey_segment(8))
           and decode(l_akey_segment(9), null, '-1', segment9) =
               decode(l_akey_segment(9), null, '-1', l_akey_segment(9))
           and decode(l_akey_segment(10), null,'-1', segment10) =
               decode(l_akey_segment(10), null, '-1', l_akey_segment(10));

      exception
        when no_data_found then
          null;
        when too_many_rows then
          null;
        when others then
          null;
      end;

      l_cat_segment(l_major_cat_seg_index) := l_major_category;
      l_cat_segment(l_cat_grp_seg_index) := l_cat_grp_seg_val;

      begin
        select category_id
          into l_cat_id
          from fa_categories
         where decode(l_cat_segment(1), null,'-1', segment1) =
               decode(l_cat_segment(1), null, '-1', l_cat_segment(1))
           and decode(l_cat_segment(2), null, '-1', segment2) =
               decode(l_cat_segment(2), null, '-1', l_cat_segment(2))
           and decode(l_cat_segment(3), null, '-1', segment3) =
               decode(l_cat_segment(3), null, '-1', l_cat_segment(3))
           and decode(l_cat_segment(4), null, '-1', segment4) =
               decode(l_cat_segment(4), null, '-1', l_cat_segment(4))
           and decode(l_cat_segment(5), null, '-1', segment5) =
               decode(l_cat_segment(5), null, '-1', l_cat_segment(5))
           and decode(l_cat_segment(6), null, '-1', segment6) =
               decode(l_cat_segment(6), null, '-1', l_cat_segment(6))
           and decode(l_cat_segment(7), null, '-1', segment7) =
               decode(l_cat_segment(7), null, '-1', l_cat_segment(7));
      exception
        when no_data_found then
          null;
        when too_many_rows then
          null;
        when others then
          null;
      end;
      l_temp            := 0;
      l_parent_asset_id := null;
      for rec in get_group_asset(l_akey_ccid,
                                 l_mass_add_rec.asset_category_id) loop

        l_parent_asset_id := rec.asset_id;
        select l_temp + 1
          into l_temp
          from fa_books
         where book_type_code = l_mass_add_rec.book_type_code
           and transaction_header_id_out is null
           and asset_id = rec.asset_id;
      end loop;

      if (l_temp > 1) then
        l_debug_str := 'Put the line to hold as multiple assets exists';
        update fa_mass_additions
           set posting_status = 'ON-HOLD', Queue_name = 'ON-HOLD'
         where mass_addition_id = l_mass_add_rec.mass_addition_id;
      elsif (l_temp = 0) then
        l_debug_str := 'Parent asset does not exist';
        l_debug_str := 'Call Addiiton API';

        l_asset_desc_rec.description           := 'Group Asset Created by Auto Prepare';
        l_asset_desc_rec.asset_key_ccid        := l_mass_add_rec.asset_key_ccid;
        l_asset_desc_rec.current_units         := 1;
        l_asset_cat_rec.category_id            := l_mass_add_rec.asset_category_id;
        l_asset_type_rec.asset_type            := 'GROUP';
        l_asset_fin_rec.cost                   := 0;
        l_asset_fin_rec.date_placed_in_service := l_mass_add_rec.date_placed_in_service;
        l_asset_fin_rec.depreciate_flag        := 'YES';
        l_asset_deprn_rec.ytd_deprn            := 0;
        l_asset_deprn_rec.deprn_reserve        := 0;
        l_asset_deprn_rec.bonus_ytd_deprn      := 0;
        l_asset_deprn_rec.bonus_deprn_reserve  := 0;
        l_asset_hdr_rec.book_type_code         := l_mass_add_rec.book_type_code;
        l_trans_rec.transaction_date_entered   := l_asset_fin_rec.date_placed_in_service;
        l_trans_rec.who_info.last_updated_by   := FND_GLOBAL.USER_ID;

        l_asset_dist_rec.units_assigned := 1;
        l_asset_dist_rec.expense_ccid := l_mass_add_rec.distributions_table(1).deprn_expense_ccid;
        l_asset_dist_rec.location_ccid := l_mass_add_rec.distributions_table(1).location_id;
        l_asset_dist_rec.assigned_to := null;
        l_asset_dist_rec.transaction_units := l_asset_dist_rec.units_assigned;
        l_asset_dist_tbl(1) := l_asset_dist_rec;

--        l_trans_rec.amortization_start_date := l_asset_fin_rec.date_placed_in_service;

        fa_addition_pub.do_addition(p_api_version          => 1.0,
                                    p_init_msg_list        => FND_API.G_FALSE,
                                    p_commit               => FND_API.G_TRUE,
                                    p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                    x_return_status        => l_status,
                                    x_msg_count            => l_mesg_count,
                                    x_msg_data             => l_mesg,
                                    p_calling_fn           => null,
                                    px_trans_rec           => l_trans_rec,
                                    px_dist_trans_rec      => l_dist_trans_rec,
                                    px_asset_hdr_rec       => l_asset_hdr_rec,
                                    px_asset_desc_rec      => l_asset_desc_rec,
                                    px_asset_type_rec      => l_asset_type_rec,
                                    px_asset_cat_rec       => l_asset_cat_rec,
                                    px_asset_hierarchy_rec => l_asset_hierarchy_rec,
                                    px_asset_fin_rec       => l_asset_fin_rec,
                                    px_asset_deprn_rec     => l_asset_deprn_rec,
                                    px_asset_dist_tbl      => l_asset_dist_tbl,
                                    px_inv_tbl             => l_inv_tbl);
        if(l_status = 'E')then
          l_debug_str := 'energy addition api failure';
          if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 l_debug_str,
                                 '',
                                 p_log_level_rec => p_log_level_rec);
          end if;
        else
          l_mass_add_rec.group_asset_id := l_asset_hdr_rec.asset_id;
          update fa_mass_additions
           set posting_status = 'POST',
               Queue_name     = 'POST',
               group_asset_id = l_mass_add_rec.group_asset_id
          where mass_addition_id = l_mass_add_rec.mass_addition_id;
          px_group_asset_rec.group_asset_id := l_mass_add_rec.group_asset_id;
        end if;
      else
        l_debug_str := 'Update the mass addition line with parent asset id';
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => p_log_level_rec);
        end if;
        update fa_mass_additions
           set posting_status = 'POST',
               Queue_name     = 'POST',
               group_asset_id = l_parent_asset_id
         where mass_addition_id = l_mass_add_rec.mass_addition_id;
         px_group_asset_rec.group_asset_id := l_parent_asset_id;
      end if;
    elsif (px_group_asset_rec.rec_mode = 'INTERFACE') then
      select asset_key_ccid, asset_type, asset_category_id
        into l_akey_ccid, l_asset_type, l_category_id
        from fa_Additions
       where asset_id = px_group_asset_rec.asset_id;
      if (l_asset_type = 'GROUP') then
        return true;
      end if;
      for rec in get_group_asset(l_akey_ccid,
                                 l_mass_add_rec.asset_category_id) loop

        l_parent_asset_id := rec.asset_id;
        select l_temp + 1
          into l_temp
          from fa_books
         where book_type_code = px_group_asset_rec.book_type_code
           and transaction_header_id_out is null
           and asset_id = px_group_asset_rec.asset_id;
      end loop;
      select CALENDAR_PERIOD_OPEN_DATE
        into l_CALENDAR_PERIOD_OPEN_DATE
        from fa_deprn_periods
       where period_close_date is null
         and book_type_code = px_group_asset_rec.book_type_code;

      if (l_temp > 1) then
        l_debug_str := 'multiple assets exists';
      elsif (l_temp = 0) then
        l_debug_str := 'Parent asset does not exist';
        l_debug_str := 'Call Addiiton API';

        l_asset_desc_rec.description           := 'Group Asset Created by Auto Prepare';
        l_asset_desc_rec.asset_key_ccid        := l_akey_ccid;
        l_asset_desc_rec.current_units         := 1;
        l_asset_cat_rec.category_id            := l_category_id;
        l_asset_type_rec.asset_type            := 'GROUP';
        l_asset_fin_rec.cost                   := 0;
        l_asset_fin_rec.date_placed_in_service := l_CALENDAR_PERIOD_OPEN_DATE;
        l_asset_fin_rec.depreciate_flag        := 'YES';
        l_asset_deprn_rec.ytd_deprn            := 0;
        l_asset_deprn_rec.deprn_reserve        := 0;
        l_asset_deprn_rec.bonus_ytd_deprn      := 0;
        l_asset_deprn_rec.bonus_deprn_reserve  := 0;
        l_asset_hdr_rec.book_type_code         := px_group_asset_rec.book_type_code;
        l_trans_rec.transaction_date_entered   := l_CALENDAR_PERIOD_OPEN_DATE;
        l_trans_rec.who_info.last_updated_by   := FND_GLOBAL.USER_ID;

        l_asset_dist_rec.units_assigned := 1;

        select location_id, code_combination_id
          into l_asset_dist_rec.location_ccid,
               l_asset_dist_rec.expense_ccid
          from fa_distribution_history
         where asset_id = px_group_asset_rec.asset_id
           and book_type_code = px_group_asset_rec.book_type_code
           and date_ineffective is null;

        l_asset_dist_rec.assigned_to := null;

        l_asset_dist_tbl(1) := l_asset_dist_rec;

        l_asset_desc_rec.current_units      := 1;
--        l_trans_rec.amortization_start_date := l_asset_fin_rec.date_placed_in_service;

        fa_addition_pub.do_addition(p_api_version          => 1.0,
                                    p_init_msg_list        => FND_API.G_FALSE,
                                    p_commit               => FND_API.G_TRUE,
                                    p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
                                    x_return_status        => l_status,
                                    x_msg_count            => l_mesg_count,
                                    x_msg_data             => l_mesg,
                                    p_calling_fn           => null,
                                    px_trans_rec           => l_trans_rec,
                                    px_dist_trans_rec      => l_dist_trans_rec,
                                    px_asset_hdr_rec       => l_asset_hdr_rec,
                                    px_asset_desc_rec      => l_asset_desc_rec,
                                    px_asset_type_rec      => l_asset_type_rec,
                                    px_asset_cat_rec       => l_asset_cat_rec,
                                    px_asset_hierarchy_rec => l_asset_hierarchy_rec,
                                    px_asset_fin_rec       => l_asset_fin_rec,
                                    px_asset_deprn_rec     => l_asset_deprn_rec,
                                    px_asset_dist_tbl      => l_asset_dist_tbl,
                                    px_inv_tbl             => l_inv_tbl);

        if(l_status = 'E')then
          l_debug_str := 'energy addition api failure';
          if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 l_debug_str,
                                 '',
                                 p_log_level_rec => p_log_level_rec);
          end if;
        end if;

        l_asset_fin_rec_adj.group_asset_id := l_asset_hdr_rec.asset_id;

        l_asset_hdr_rec                := null;
        l_asset_hdr_rec.asset_id       := px_group_asset_rec.asset_id;
        l_asset_hdr_rec.book_type_code := px_group_asset_rec.book_type_code;

        FA_ADJUSTMENT_PUB.do_adjustment(p_api_version               => 1.0,
                                        p_init_msg_list             => FND_API.G_FALSE,
                                        p_commit                    => FND_API.G_TRUE,
                                        p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn                => 'CREATE_GROUP_ASSET',
                                        x_return_status             => l_status,
                                        x_msg_count                 => l_mesg_count,
                                        x_msg_data                  => l_mesg,
                                        px_trans_rec                => l_trans_rec,
                                        px_asset_hdr_rec            => l_asset_hdr_rec,
                                        p_asset_fin_rec_adj         => l_asset_fin_rec_adj,
                                        x_asset_fin_rec_new         => l_asset_fin_rec_new,
                                        x_asset_fin_mrc_tbl_new     => l_asset_fin_mrc_tbl_new,
                                        px_inv_trans_rec            => l_inv_trans_rec,
                                        px_inv_tbl                  => l_inv_tbl,
                                        p_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
                                        x_asset_deprn_rec_new       => l_asset_deprn_rec_new,
                                        x_asset_deprn_mrc_tbl_new   => l_asset_deprn_mrc_tbl_new,
                                        p_group_reclass_options_rec => l_group_reclass_options_rec);
        if(l_status = 'E')then
          l_debug_str := 'energy addition api failure';
          if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 l_debug_str,
                                 '',
                                 p_log_level_rec => p_log_level_rec);
          end if;
        end if;

      else

        l_asset_fin_rec_adj.group_asset_id := l_parent_asset_id;
        px_group_asset_rec.group_asset_id := l_parent_asset_id;
        l_asset_hdr_rec                := null;
        l_asset_hdr_rec.asset_id       := px_group_asset_rec.asset_id;
        l_asset_hdr_rec.book_type_code := px_group_asset_rec.book_type_code;

        FA_ADJUSTMENT_PUB.do_adjustment(p_api_version               => 1.0,
                                        p_init_msg_list             => FND_API.G_FALSE,
                                        p_commit                    => FND_API.G_TRUE,
                                        p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn                => 'CREATE_GROUP_ASSET',
                                        x_return_status             => l_return_status,
                                        x_msg_count                 => l_mesg_count,
                                        x_msg_data                  => l_mesg,
                                        px_trans_rec                => l_trans_rec,
                                        px_asset_hdr_rec            => l_asset_hdr_rec,
                                        p_asset_fin_rec_adj         => l_asset_fin_rec_adj,
                                        x_asset_fin_rec_new         => l_asset_fin_rec_new,
                                        x_asset_fin_mrc_tbl_new     => l_asset_fin_mrc_tbl_new,
                                        px_inv_trans_rec            => l_inv_trans_rec,
                                        px_inv_tbl                  => l_inv_tbl,
                                        p_asset_deprn_rec_adj       => l_asset_deprn_rec_adj,
                                        x_asset_deprn_rec_new       => l_asset_deprn_rec_new,
                                        x_asset_deprn_mrc_tbl_new   => l_asset_deprn_mrc_tbl_new,
                                        p_group_reclass_options_rec => l_group_reclass_options_rec);

        if(l_status = 'E')then
          l_debug_str := 'energy addition api failure';
          if (p_log_level_rec.statement_level) then
                fa_debug_pkg.add(l_calling_fn,
                                 l_debug_str,
                                 '',
                                 p_log_level_rec => p_log_level_rec);
          end if;
        end if;

      end if;
    end if;
    commit;
    return true;
  exception
    when others then
      return false;
  end;

end FA_CREATE_GROUP_ASSET_PKG;

/
