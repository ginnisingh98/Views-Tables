--------------------------------------------------------
--  DDL for Package FA_MASS_DPR_RSV_ADJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASS_DPR_RSV_ADJ_PKG" AUTHID CURRENT_USER AS
/* $Header: FAMTRSVS.pls 120.2.12010000.2 2009/07/19 09:50:42 glchen ship $   */

/* Bug 4597471 -- Added one more parameter "p_mode" which shows whether called from
   PREVIEW or RUN . Both have the same calculations but RUN mode updates the core tables
   whereas PREVIEW only updates the interface table
*/

PROCEDURE Do_Deprn_Adjustment
               (p_mass_tax_adjustment_id  IN      NUMBER,
                p_mode                    IN      varchar2,
                p_parent_request_id       IN      NUMBER,
                p_total_requests          IN      NUMBER,
                p_request_number          IN      NUMBER,
                x_success_count              OUT NOCOPY NUMBER,
                x_failure_count              OUT NOCOPY NUMBER,
                x_worker_jobs                OUT NOCOPY NUMBER,
                x_return_status              OUT NOCOPY NUMBER);

PROCEDURE LOAD_WORKERS
            (p_mass_tax_adjustment_id IN NUMBER,
             p_book_type_code         IN VARCHAR2,
             p_parent_request_id      IN NUMBER,
             p_total_requests         IN NUMBER,
             x_worker_jobs               OUT NOCOPY NUMBER,
             x_return_status             OUT NOCOPY NUMBER);

END FA_MASS_DPR_RSV_ADJ_PKG;

/
