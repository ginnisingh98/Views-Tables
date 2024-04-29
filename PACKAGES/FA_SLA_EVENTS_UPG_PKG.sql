--------------------------------------------------------
--  DDL for Package FA_SLA_EVENTS_UPG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SLA_EVENTS_UPG_PKG" AUTHID CURRENT_USER as
/* $Header: FAEVUPGS.pls 120.5.12010000.2 2009/07/19 14:41:55 glchen ship $   */

Procedure Upgrade_Inv_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            );

Procedure Upgrade_Group_Trxn_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            );

Procedure Upgrade_Trxn_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            );

Procedure Upgrade_Deprn_Events (
             p_mode                    IN            varchar,
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            );

Procedure Upgrade_Deferred_Events (
             p_start_rowid             IN            rowid,
             p_end_rowid               IN            rowid,
             p_batch_size              IN            number,
             x_success_count              OUT NOCOPY number,
             x_failure_count              OUT NOCOPY number,
             x_return_status              OUT NOCOPY number
            );

END FA_SLA_EVENTS_UPG_PKG;

/
