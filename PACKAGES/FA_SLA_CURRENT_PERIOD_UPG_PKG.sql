--------------------------------------------------------
--  DDL for Package FA_SLA_CURRENT_PERIOD_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SLA_CURRENT_PERIOD_UPG_PKG" AUTHID CURRENT_USER as
/* $Header: FACPUPGS.pls 120.4.12010000.2 2009/07/19 14:16:45 glchen ship $   */

Procedure Upgrade_Addition (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number,
             p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
                                                     default null
            );

Procedure Upgrade_Addition_MRC (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number,
             p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
                                                     default null
            );

Procedure Upgrade_Backdated_Trxns (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number,
             p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
                                                     default null
            );

Procedure Upgrade_Invoices (
             p_book_type_code          IN            varchar2,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number,
             p_log_level_rec           IN     FA_API_TYPES.log_level_rec_type
                                                     default null
            );

END FA_SLA_CURRENT_PERIOD_UPG_PKG;

/
