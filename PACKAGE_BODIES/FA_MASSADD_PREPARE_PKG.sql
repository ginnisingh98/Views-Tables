--------------------------------------------------------
--  DDL for Package Body FA_MASSADD_PREPARE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_MASSADD_PREPARE_PKG" as
  /* $Header: FAMAPREPB.pls 120.6.12010000.3 2009/10/14 13:11:22 anujain ship $ */

  -- Private type declarations

  -- Private constant declarations

  -- Private variable declarations
  g_log_level_rec fa_api_types.log_level_rec_type;
  -- Function and procedure implementations

  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  function update_mass_additions(p_mass_add_rec_tbl FA_MASSADD_PREPARE_PKG.mass_add_rec_tbl,
                                 p_log_level_rec    IN FA_API_TYPES.log_level_rec_type default null)
    return boolean is
    TYPE mass_add_tbl IS TABLE OF fa_mass_additions%ROWTYPE INDEX BY PLS_INTEGER;
    l_mass_add_tbl mass_add_tbl;
    type num_tbl is table of number index by pls_integer;
    l_mass_add_id_tbl num_tbl;
    l_debug_str       varchar2(1000);
    l_errors          NUMBER;
    l_calling_fn      varchar2(40) := 'update_mass_additions';
    dml_errors EXCEPTION;
    PRAGMA exception_init(dml_errors, -24381);

  begin
    l_debug_str := 'Updating Mass Addions';
    if (p_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       l_debug_str,
                       '',
                       p_log_level_rec => p_log_level_rec);
    end if;
    for counter in 1 .. p_mass_add_rec_tbl.count loop

      l_mass_add_id_tbl(counter) := p_mass_add_rec_tbl(counter)
                                   .mass_addition_id;
      l_mass_add_tbl(counter).mass_addition_id := p_mass_add_rec_tbl(counter)
                                                 .mass_addition_id;
      l_mass_add_tbl(counter).ASSET_NUMBER := p_mass_add_rec_tbl(counter)
                                             .ASSET_NUMBER;
      l_mass_add_tbl(counter).TAG_NUMBER := p_mass_add_rec_tbl(counter)
                                           .TAG_NUMBER;
      l_mass_add_tbl(counter).DESCRIPTION := p_mass_add_rec_tbl(counter)
                                            .DESCRIPTION;
      l_mass_add_tbl(counter).ASSET_CATEGORY_ID := p_mass_add_rec_tbl(counter)
                                                  .ASSET_CATEGORY_ID;
      l_mass_add_tbl(counter).MANUFACTURER_NAME := p_mass_add_rec_tbl(counter)
                                                  .MANUFACTURER_NAME;
      l_mass_add_tbl(counter).SERIAL_NUMBER := p_mass_add_rec_tbl(counter)
                                              .SERIAL_NUMBER;
      l_mass_add_tbl(counter).MODEL_NUMBER := p_mass_add_rec_tbl(counter)
                                             .MODEL_NUMBER;
      l_mass_add_tbl(counter).BOOK_TYPE_CODE := p_mass_add_rec_tbl(counter)
                                               .BOOK_TYPE_CODE;
      l_mass_add_tbl(counter).DATE_PLACED_IN_SERVICE := p_mass_add_rec_tbl(counter)
                                                       .DATE_PLACED_IN_SERVICE;
      l_mass_add_tbl(counter).FIXED_ASSETS_COST := p_mass_add_rec_tbl(counter)
                                                  .FIXED_ASSETS_COST;
      l_mass_add_tbl(counter).PAYABLES_UNITS := p_mass_add_rec_tbl(counter)
                                               .PAYABLES_UNITS;
      l_mass_add_tbl(counter).FIXED_ASSETS_UNITS := p_mass_add_rec_tbl(counter)
                                                   .FIXED_ASSETS_UNITS;
      l_mass_add_tbl(counter).PAYABLES_CODE_COMBINATION_ID := p_mass_add_rec_tbl(counter)
                                                             .PAYABLES_CODE_COMBINATION_ID;
      l_mass_add_tbl(counter).EXPENSE_CODE_COMBINATION_ID := p_mass_add_rec_tbl(counter)
                                                            .EXPENSE_CODE_COMBINATION_ID;
      l_mass_add_tbl(counter).LOCATION_ID := p_mass_add_rec_tbl(counter)
                                            .LOCATION_ID;
      l_mass_add_tbl(counter).ASSIGNED_TO := p_mass_add_rec_tbl(counter)
                                            .ASSIGNED_TO;
      l_mass_add_tbl(counter).FEEDER_SYSTEM_NAME := p_mass_add_rec_tbl(counter)
                                                   .FEEDER_SYSTEM_NAME;
      l_mass_add_tbl(counter).CREATE_BATCH_DATE := p_mass_add_rec_tbl(counter)
                                                  .CREATE_BATCH_DATE;
      l_mass_add_tbl(counter).CREATE_BATCH_ID := p_mass_add_rec_tbl(counter)
                                                .CREATE_BATCH_ID;
      l_mass_add_tbl(counter).LAST_UPDATE_DATE := p_mass_add_rec_tbl(counter)
                                                 .LAST_UPDATE_DATE;
      l_mass_add_tbl(counter).LAST_UPDATED_BY := p_mass_add_rec_tbl(counter)
                                                .LAST_UPDATED_BY;
      l_mass_add_tbl(counter).REVIEWER_COMMENTS := p_mass_add_rec_tbl(counter)
                                                  .REVIEWER_COMMENTS;
      l_mass_add_tbl(counter).INVOICE_NUMBER := p_mass_add_rec_tbl(counter)
                                               .INVOICE_NUMBER;
      l_mass_add_tbl(counter).INVOICE_LINE_NUMBER := p_mass_add_rec_tbl(counter).INVOICE_LINE_NUMBER; -- bug8984263
      l_mass_add_tbl(counter).INVOICE_DISTRIBUTION_ID := p_mass_add_rec_tbl(counter).INVOICE_DISTRIBUTION_ID; -- bug8984263
      l_mass_add_tbl(counter).VENDOR_NUMBER := p_mass_add_rec_tbl(counter)
                                              .VENDOR_NUMBER;
      l_mass_add_tbl(counter).PO_VENDOR_ID := p_mass_add_rec_tbl(counter)
                                             .PO_VENDOR_ID;
      l_mass_add_tbl(counter).PO_NUMBER := p_mass_add_rec_tbl(counter)
                                          .PO_NUMBER;
      l_mass_add_tbl(counter).POSTING_STATUS := p_mass_add_rec_tbl(counter)
                                               .POSTING_STATUS;
      l_mass_add_tbl(counter).QUEUE_NAME := p_mass_add_rec_tbl(counter)
                                           .QUEUE_NAME;
      l_mass_add_tbl(counter).INVOICE_DATE := p_mass_add_rec_tbl(counter)
                                             .INVOICE_DATE;
      l_mass_add_tbl(counter).INVOICE_CREATED_BY := p_mass_add_rec_tbl(counter)
                                                   .INVOICE_CREATED_BY;
      l_mass_add_tbl(counter).INVOICE_UPDATED_BY := p_mass_add_rec_tbl(counter)
                                                   .INVOICE_UPDATED_BY;
      l_mass_add_tbl(counter).PAYABLES_COST := p_mass_add_rec_tbl(counter)
                                              .PAYABLES_COST;
      l_mass_add_tbl(counter).INVOICE_ID := p_mass_add_rec_tbl(counter)
                                           .INVOICE_ID;
      l_mass_add_tbl(counter).PAYABLES_BATCH_NAME := p_mass_add_rec_tbl(counter)
                                                    .PAYABLES_BATCH_NAME;
      l_mass_add_tbl(counter).DEPRECIATE_FLAG := p_mass_add_rec_tbl(counter)
                                                .DEPRECIATE_FLAG;
      l_mass_add_tbl(counter).PARENT_MASS_ADDITION_ID := p_mass_add_rec_tbl(counter)
                                                        .PARENT_MASS_ADDITION_ID;
      l_mass_add_tbl(counter).PARENT_ASSET_ID := p_mass_add_rec_tbl(counter)
                                                .PARENT_ASSET_ID;
      l_mass_add_tbl(counter).SPLIT_MERGED_CODE := p_mass_add_rec_tbl(counter)
                                                  .SPLIT_MERGED_CODE;
      l_mass_add_tbl(counter).AP_DISTRIBUTION_LINE_NUMBER := p_mass_add_rec_tbl(counter)
                                                            .AP_DISTRIBUTION_LINE_NUMBER;
      l_mass_add_tbl(counter).POST_BATCH_ID := p_mass_add_rec_tbl(counter)
                                              .POST_BATCH_ID;
      l_mass_add_tbl(counter).ADD_TO_ASSET_ID := p_mass_add_rec_tbl(counter)
                                                .ADD_TO_ASSET_ID;
      l_mass_add_tbl(counter).AMORTIZE_FLAG := p_mass_add_rec_tbl(counter)
                                              .AMORTIZE_FLAG;
      l_mass_add_tbl(counter).NEW_MASTER_FLAG := p_mass_add_rec_tbl(counter)
                                                .NEW_MASTER_FLAG;
      l_mass_add_tbl(counter).ASSET_KEY_CCID := p_mass_add_rec_tbl(counter)
                                               .ASSET_KEY_CCID;
      l_mass_add_tbl(counter).ASSET_TYPE := p_mass_add_rec_tbl(counter)
                                           .ASSET_TYPE;
      l_mass_add_tbl(counter).DEPRN_RESERVE := p_mass_add_rec_tbl(counter)
                                              .DEPRN_RESERVE;
      l_mass_add_tbl(counter).YTD_DEPRN := p_mass_add_rec_tbl(counter)
                                          .YTD_DEPRN;
      l_mass_add_tbl(counter).BEGINNING_NBV := p_mass_add_rec_tbl(counter)
                                              .BEGINNING_NBV;
      l_mass_add_tbl(counter).CREATED_BY := p_mass_add_rec_tbl(counter)
                                           .CREATED_BY;
      l_mass_add_tbl(counter).CREATION_DATE := p_mass_add_rec_tbl(counter)
                                              .CREATION_DATE;
      l_mass_add_tbl(counter).LAST_UPDATE_LOGIN := p_mass_add_rec_tbl(counter)
                                                  .LAST_UPDATE_LOGIN;
      l_mass_add_tbl(counter).SALVAGE_VALUE := p_mass_add_rec_tbl(counter)
                                              .SALVAGE_VALUE;
      l_mass_add_tbl(counter).ACCOUNTING_DATE := p_mass_add_rec_tbl(counter)
                                                .ACCOUNTING_DATE;
      l_mass_add_tbl(counter).ATTRIBUTE1 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE1;
      l_mass_add_tbl(counter).ATTRIBUTE2 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE2;
      l_mass_add_tbl(counter).ATTRIBUTE3 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE3;
      l_mass_add_tbl(counter).ATTRIBUTE4 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE4;
      l_mass_add_tbl(counter).ATTRIBUTE5 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE5;
      l_mass_add_tbl(counter).ATTRIBUTE6 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE6;
      l_mass_add_tbl(counter).ATTRIBUTE7 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE7;
      l_mass_add_tbl(counter).ATTRIBUTE8 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE8;
      l_mass_add_tbl(counter).ATTRIBUTE9 := p_mass_add_rec_tbl(counter)
                                           .ATTRIBUTE9;
      l_mass_add_tbl(counter).ATTRIBUTE10 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE10;
      l_mass_add_tbl(counter).ATTRIBUTE11 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE11;
      l_mass_add_tbl(counter).ATTRIBUTE12 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE12;
      l_mass_add_tbl(counter).ATTRIBUTE13 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE13;
      l_mass_add_tbl(counter).ATTRIBUTE14 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE14;
      l_mass_add_tbl(counter).ATTRIBUTE15 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE15;
      l_mass_add_tbl(counter).ATTRIBUTE_CATEGORY_CODE := p_mass_add_rec_tbl(counter)
                                                        .ATTRIBUTE_CATEGORY_CODE;
      l_mass_add_tbl(counter).FULLY_RSVD_REVALS_COUNTER := p_mass_add_rec_tbl(counter)
                                                          .FULLY_RSVD_REVALS_COUNTER;
      l_mass_add_tbl(counter).MERGE_INVOICE_NUMBER := p_mass_add_rec_tbl(counter)
                                                     .MERGE_INVOICE_NUMBER;
      l_mass_add_tbl(counter).MERGE_VENDOR_NUMBER := p_mass_add_rec_tbl(counter)
                                                    .MERGE_VENDOR_NUMBER;
      l_mass_add_tbl(counter).PRODUCTION_CAPACITY := p_mass_add_rec_tbl(counter)
                                                    .PRODUCTION_CAPACITY;
      l_mass_add_tbl(counter).REVAL_AMORTIZATION_BASIS := p_mass_add_rec_tbl(counter)
                                                         .REVAL_AMORTIZATION_BASIS;
      l_mass_add_tbl(counter).REVAL_RESERVE := p_mass_add_rec_tbl(counter)
                                              .REVAL_RESERVE;
      l_mass_add_tbl(counter).UNIT_OF_MEASURE := p_mass_add_rec_tbl(counter)
                                                .UNIT_OF_MEASURE;
      l_mass_add_tbl(counter).UNREVALUED_COST := p_mass_add_rec_tbl(counter)
                                                .UNREVALUED_COST;
      l_mass_add_tbl(counter).YTD_REVAL_DEPRN_EXPENSE := p_mass_add_rec_tbl(counter)
                                                        .YTD_REVAL_DEPRN_EXPENSE;
      l_mass_add_tbl(counter).ATTRIBUTE16 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE16;
      l_mass_add_tbl(counter).ATTRIBUTE17 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE17;
      l_mass_add_tbl(counter).ATTRIBUTE18 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE18;
      l_mass_add_tbl(counter).ATTRIBUTE19 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE19;
      l_mass_add_tbl(counter).ATTRIBUTE20 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE20;
      l_mass_add_tbl(counter).ATTRIBUTE21 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE21;
      l_mass_add_tbl(counter).ATTRIBUTE22 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE22;
      l_mass_add_tbl(counter).ATTRIBUTE23 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE23;
      l_mass_add_tbl(counter).ATTRIBUTE24 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE24;
      l_mass_add_tbl(counter).ATTRIBUTE25 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE25;
      l_mass_add_tbl(counter).ATTRIBUTE26 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE26;
      l_mass_add_tbl(counter).ATTRIBUTE27 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE27;
      l_mass_add_tbl(counter).ATTRIBUTE28 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE28;
      l_mass_add_tbl(counter).ATTRIBUTE29 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE29;
      l_mass_add_tbl(counter).ATTRIBUTE30 := p_mass_add_rec_tbl(counter)
                                            .ATTRIBUTE30;
      l_mass_add_tbl(counter).MERGED_CODE := p_mass_add_rec_tbl(counter)
                                            .MERGED_CODE;
      l_mass_add_tbl(counter).SPLIT_CODE := p_mass_add_rec_tbl(counter)
                                           .SPLIT_CODE;
      l_mass_add_tbl(counter).MERGE_PARENT_MASS_ADDITIONS_ID := p_mass_add_rec_tbl(counter)
                                                               .MERGE_PARENT_MASS_ADD_ID;
      l_mass_add_tbl(counter).SPLIT_PARENT_MASS_ADDITIONS_ID := p_mass_add_rec_tbl(counter)
                                                               .SPLIT_PARENT_MASS_ADD_ID;
      l_mass_add_tbl(counter).PROJECT_ASSET_LINE_ID := p_mass_add_rec_tbl(counter)
                                                      .PROJECT_ASSET_LINE_ID;
      l_mass_add_tbl(counter).PROJECT_ID := p_mass_add_rec_tbl(counter)
                                           .PROJECT_ID;
      l_mass_add_tbl(counter).TASK_ID := p_mass_add_rec_tbl(counter)
                                        .TASK_ID;
      l_mass_add_tbl(counter).SUM_UNITS := p_mass_add_rec_tbl(counter)
                                          .SUM_UNITS;
      l_mass_add_tbl(counter).DIST_NAME := p_mass_add_rec_tbl(counter)
                                          .DIST_NAME;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE1 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE1;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE2 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE2;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE3 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE3;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE4 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE4;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE5 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE5;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE6 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE6;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE7 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE7;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE8 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE8;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE9 := p_mass_add_rec_tbl(counter)
                                                  .GLOBAL_ATTRIBUTE9;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE10 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE10;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE11 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE11;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE12 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE12;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE13 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE13;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE14 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE14;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE15 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE15;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE16 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE16;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE17 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE17;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE18 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE18;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE19 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE19;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE20 := p_mass_add_rec_tbl(counter)
                                                   .GLOBAL_ATTRIBUTE20;
      l_mass_add_tbl(counter).GLOBAL_ATTRIBUTE_CATEGORY := p_mass_add_rec_tbl(counter)
                                                          .GLOBAL_ATTRIBUTE_CATEGORY;
      l_mass_add_tbl(counter).CONTEXT := p_mass_add_rec_tbl(counter)
                                        .CONTEXT;
      l_mass_add_tbl(counter).INVENTORIAL := p_mass_add_rec_tbl(counter)
                                            .INVENTORIAL;
      l_mass_add_tbl(counter).SHORT_FISCAL_YEAR_FLAG := p_mass_add_rec_tbl(counter)
                                                       .SHORT_FISCAL_YEAR_FLAG;
      l_mass_add_tbl(counter).CONVERSION_DATE := p_mass_add_rec_tbl(counter)
                                                .CONVERSION_DATE;
      l_mass_add_tbl(counter).ORIGINAL_DEPRN_START_DATE := p_mass_add_rec_tbl(counter)
                                                          .ORIGINAL_DEPRN_START_DATE;
      l_mass_add_tbl(counter).GROUP_ASSET_ID := p_mass_add_rec_tbl(counter)
                                               .GROUP_ASSET_ID;
      l_mass_add_tbl(counter).CUA_PARENT_HIERARCHY_ID := p_mass_add_rec_tbl(counter)
                                                        .CUA_PARENT_HIERARCHY_ID;
      l_mass_add_tbl(counter).UNITS_TO_ADJUST := p_mass_add_rec_tbl(counter)
                                                .UNITS_TO_ADJUST;
      l_mass_add_tbl(counter).BONUS_YTD_DEPRN := p_mass_add_rec_tbl(counter)
                                                .BONUS_YTD_DEPRN;
      l_mass_add_tbl(counter).BONUS_DEPRN_RESERVE := p_mass_add_rec_tbl(counter)
                                                    .BONUS_DEPRN_RESERVE;
      l_mass_add_tbl(counter).AMORTIZE_NBV_FLAG := p_mass_add_rec_tbl(counter)
                                                  .AMORTIZE_NBV_FLAG;
      l_mass_add_tbl(counter).AMORTIZATION_START_DATE := p_mass_add_rec_tbl(counter)
                                                        .AMORTIZATION_START_DATE;
      l_mass_add_tbl(counter).TRANSACTION_TYPE_CODE := p_mass_add_rec_tbl(counter)
                                                      .TRANSACTION_TYPE_CODE;
      l_mass_add_tbl(counter).TRANSACTION_DATE := p_mass_add_rec_tbl(counter)
                                                 .TRANSACTION_DATE;
      l_mass_add_tbl(counter).WARRANTY_ID := p_mass_add_rec_tbl(counter)
                                            .WARRANTY_ID;
      l_mass_add_tbl(counter).LEASE_ID := p_mass_add_rec_tbl(counter)
                                         .LEASE_ID;
      l_mass_add_tbl(counter).LESSOR_ID := p_mass_add_rec_tbl(counter)
                                          .LESSOR_ID;
      l_mass_add_tbl(counter).PROPERTY_TYPE_CODE := p_mass_add_rec_tbl(counter)
                                                   .PROPERTY_TYPE_CODE;
      l_mass_add_tbl(counter).PROPERTY_1245_1250_CODE := p_mass_add_rec_tbl(counter)
                                                        .PROPERTY_1245_1250_CODE;
      l_mass_add_tbl(counter).IN_USE_FLAG := p_mass_add_rec_tbl(counter)
                                            .IN_USE_FLAG;
      l_mass_add_tbl(counter).OWNED_LEASED := p_mass_add_rec_tbl(counter)
                                             .OWNED_LEASED;
      l_mass_add_tbl(counter).NEW_USED := p_mass_add_rec_tbl(counter)
                                         .NEW_USED;
      l_mass_add_tbl(counter).ASSET_ID := p_mass_add_rec_tbl(counter)
                                         .ASSET_ID;
      l_mass_add_tbl(counter).MATERIAL_INDICATOR_FLAG := p_mass_add_rec_tbl(counter)
                                                        .MATERIAL_INDICATOR_FLAG;
    end loop;

    forall i in 1 .. l_mass_add_tbl.count SAVE EXCEPTIONS
      update fa_mass_additions
         set ROW = l_mass_add_tbl(i)
       where mass_addition_id = l_mass_add_id_tbl(i);
    l_mass_add_id_tbl.delete;
    commit;
    return true;
  exception
    WHEN dml_errors THEN
      l_errors := SQL%BULK_EXCEPTIONS.COUNT;
      if (p_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         'Number of errors is ',
                         l_errors,
                         p_log_level_rec => p_log_level_rec);
      end if;

      FOR i IN 1 .. l_errors LOOP

        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           'Error ' || i || ' occurred during ' ||
                           'iteration ',
                           SQL%BULK_EXCEPTIONS(i).ERROR_INDEX,
                           p_log_level_rec => p_log_level_rec);
        end if;
        fa_debug_pkg.add(l_calling_fn,
                         'Oracle error is ',
                         SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),
                         p_log_level_rec => p_log_level_rec);
        if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           'Oracle error is ',
                           SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE),
                           p_log_level_rec => p_log_level_rec);
        end if;

      END LOOP;
      commit;
      return false; /*need to check */
  end;

  /*===============================End Of FUNCTION/PROCEDURE===============================*/
  /*main procedure for concurrent program*/
  procedure prepare_mass_additions(
                errbuf                  OUT NOCOPY VARCHAR2,
                retcode                 OUT NOCOPY NUMBER,
                p_book_type_code        IN varchar2) is

    l_mass_add_rec FA_MASSADD_PREPARE_PKG.mass_add_rec;

    l_procedure_name varchar2(4000);
    l_label          varchar2(4000);
    l_request_id     NUMBER;

    l_batch_size number := 500;
    l_count      number;
    l_debug_str  varchar2(1000);

    --type mass_add_dist_tbl is table of mass_add_dist_rec;

    TYPE v30_tbl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    TYPE num_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE date_tbl IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    TYPE v100_tbl IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

    l_mass_add_rec_tbl  FA_MASSADD_PREPARE_PKG.mass_add_rec_tbl;
    --l_mass_add_dist_tbl mass_add_dist_tbl;

    status                    varchar2(15);
    l_dist_MASSADD_DIST_ID    num_tbl;
    l_dist_UNITS              num_tbl;
    l_dist_DEPRN_EXPENSE_CCID num_tbl;
    l_dist_LOCATION_ID        num_tbl;
    l_dist_EMPLOYEE_ID        num_tbl;

    l_prev_category_id    number := -1;
    l_prev_asset_key_ccid number := -1;
    l_curr_category_id    number := 0;
    l_curr_asset_key_ccid number := 0;
    merge_cost            number;
    --l_distributions_table fa_mass_add_dist_tbl;

    old_expense_ccid number := -1;
    new_expense_ccid number := -1;

    l_lookup_rule_value varchar2(60);
    l_status            number;
    l_calling_fn        varchar2(40) := 'prepare_mass_additions';
    mass_prepare EXCEPTION;
    --Cursor to get all mass_addition lines
    --check about the book_type_code
    cursor get_mass_add(l_book_type_code varchar2) is
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
             INVOICE_LINE_NUMBER,-- bug8984263
	     INVOICE_DISTRIBUTION_ID,-- bug8984263
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
        FROM fa_mass_additions mass_add
       where posting_status in ('NEW', 'ON HOLD', 'POST')
         and book_type_code = l_book_type_code
         and nvl(merged_code, '1') not in ('MC');

    CURSOR lookup_cur(c_lookup_type varchar2) IS
      select lookup_code
        from fa_lookups
       where lookup_type = c_lookup_type
         and enabled_flag = 'Y'
         and nvl(end_date_active, sysdate) >= sysdate
         and rownum = 1;

  begin

    l_procedure_name := 'fa.plsql.FA_AUTO_PREP_PKG.do_prepare_mass_addtions';
    l_label          := 'fa.plsql.FA_AUTO_PREP_PKG.do_prepare_mass_addtions.';

    --Call log header
    if (not g_log_level_rec.initialized) then
      if (NOT
          fa_util_pub.get_log_level_rec(x_log_level_rec => g_log_level_rec)) then
        raise mass_prepare;
      end if;
    end if;

    Savepoint Work;
    /*         ------------------------------------------------------------------------------
              | Get the package type for all attributes. Assumption here is that it will    |
              | return either DEFAULT or CUSTOM or ENERGY as lookup code                    |
               ------------------------------------------------------------------------------
    */

    FOR rec IN lookup_cur('MASS ADD PREPARE RULES') LOOP
      l_lookup_rule_value := rec.lookup_code;
    END LOOP;

    /*         ------------------------------------------------------------------------------
              |  Call to prepare the asset key and category. The function will internally    |
              |  call either the package for common customers which will be empty stubs for  |
              |  now or will call the package for Energy Cutomers which will have code to    |
              |  prepare Asset Key and Category_id.                                          |
               ------------------------------------------------------------------------------
    */

    l_debug_str := 'Calling prepare_asset_key_category';
    if (g_log_level_rec.statement_level) then
      fa_debug_pkg.add(l_calling_fn,
                       l_debug_str,
                       '',
                       p_log_level_rec => g_log_level_rec);
    end if;

      if (g_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           'l_lookup_rule_value',
                           l_lookup_rule_value,
                           p_log_level_rec => g_log_level_rec);
        end if;

    /*call the asset key function deprneding upon the package*/
    if (l_lookup_rule_value = 'CUSTOM ENERGY') then

      if not
          FA_MASSADD_PREP_ENERGY_PKG.prep_asset_key_category(p_book_type_code,
                                                             p_log_level_rec => g_log_level_rec) then
        l_debug_str := 'Energy prepare asset key returned failure';

      end if;

      /*         ------------------------------------------------------------------------------
                |  Call to merge the mass additions lines. The functionw ill internally call   |
                |  either the package for common customers which will be standard merge code   |
                |  or will call the package for Energy Cutomers which will have code to merge  |
                |  to merge the lines with identical Asset Key and Category_id.                |
                 ------------------------------------------------------------------------------
      */
      l_debug_str := 'Calling merge_mass_additions';
      if (g_log_level_rec.statement_level) then
        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => g_log_level_rec);
      end if;

      if not
          FA_MASSADD_PREP_ENERGY_PKG.merge_lines(p_book_type_code,
                                                 p_log_level_rec => g_log_level_rec) then
        l_debug_str := 'Energy merge_lines returned failure';
      end if;
    end if;

    /*         ------------------------------------------------------------------------------
              |  Loop through all the mass additions lines and call the main attribute       |
              |  fucntion which will process the all other attributes of the mass addition   |
              |  lines. The fucntion will internally call either the package for the common  |
              |  customers or the package for energy customers which will have an extra call |
              |  to the group function which will further call the Create Summary Assets     |
              |  fucntion to process Create Summary Asset.                                   |
               ------------------------------------------------------------------------------
    */
    l_debug_str := 'Processing mass additons lines for other attributes';
    --Open the cursor for the mass additions
    open GET_MASS_ADD(p_book_type_code);

    -- Process all the records
    while true loop

      l_debug_str := 'In Loop';
      --fetch the records as per batch size
      fetch GET_MASS_ADD BULK COLLECT
        INTO l_mass_add_rec_tbl limit l_batch_size;

      --exit from the loop if no more records
      if (GET_MASS_ADD%NOTFOUND) and (l_mass_add_rec_tbl.count < 1) then
        exit;
      end if;

      --Loop to get process each mass addition line
      for l_count in 1 .. l_mass_add_rec_tbl.count loop
        l_debug_str := 'Calling prepare_attributes';
        if (g_log_level_rec.statement_level) then
          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => g_log_level_rec);
        end if;
        if (l_lookup_rule_value = 'DEFAULT') then
          if not
              FA_MASSADD_PREP_DEFAULT_PKG.prepare_attributes(l_mass_add_rec_tbl(l_count),
                                                             p_log_level_rec => g_log_level_rec) then
            l_debug_str := 'Custom prepare attributes returned failure';

            if (g_log_level_rec.statement_level) then
              fa_debug_pkg.add(l_calling_fn,
                               l_debug_str,
                               '',
                               p_log_level_rec => g_log_level_rec);
            end if;
          end if;

        elsif (l_lookup_rule_value = 'CUSTOM') then
          if not
              FA_MASSADD_PREP_CUSTOM_PKG.prepare_attributes(l_mass_add_rec_tbl(l_count),
                                                            p_log_level_rec => g_log_level_rec) then
            l_debug_str := 'Custom prepare attributes returned failure';
            if (g_log_level_rec.statement_level) then

              fa_debug_pkg.add(l_calling_fn,
                               l_debug_str,
                               '',
                               p_log_level_rec => g_log_level_rec);
            end if;
          end if;
        elsif (l_lookup_rule_value = 'CUSTOM ENERGY') then
          if not
              FA_MASSADD_PREP_ENERGY_PKG.prepare_attributes(l_mass_add_rec_tbl(l_count),
                                                            p_log_level_rec => g_log_level_rec) then
            l_debug_str := 'Energy prepare attributes returned failure';
            if (g_log_level_rec.statement_level) then

              fa_debug_pkg.add(l_calling_fn,
                               l_debug_str,
                               '',
                               p_log_level_rec => g_log_level_rec);
            end if;
          end if;
        end if;
      end loop;
      l_debug_str := 'Calling update_mass_additions';
      if (g_log_level_rec.statement_level) then

        fa_debug_pkg.add(l_calling_fn,
                         l_debug_str,
                         '',
                         p_log_level_rec => g_log_level_rec);
      end if;
      if not update_mass_additions(l_mass_add_rec_tbl,
                                   p_log_level_rec => g_log_level_rec) then
        l_debug_str := 'error in update_mass_additions';
        if (g_log_level_rec.statement_level) then

          fa_debug_pkg.add(l_calling_fn,
                           l_debug_str,
                           '',
                           p_log_level_rec => g_log_level_rec);
        end if;
      end if;
    end loop;
    commit;
    retcode := 0;

  exception
    WHEN others THEN
      retcode := 2;
      rollback;
      FA_SRVR_MSG.ADD_MESSAGE(CALLING_FN      => 'FA_MASSADD_PREPARE_PKG.prepare_mass_additions',
                              p_log_level_rec => g_log_level_rec);

  end;
  /*===============================End Of FUNCTION/PROCEDURE===============================*/
end FA_MASSADD_PREPARE_PKG;

/
