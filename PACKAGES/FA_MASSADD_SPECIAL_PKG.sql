--------------------------------------------------------
--  DDL for Package FA_MASSADD_SPECIAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSADD_SPECIAL_PKG" AUTHID CURRENT_USER as
/* $Header: FAMADSS.pls 120.2.12010000.2 2009/07/19 14:48:02 glchen ship $   */

G_last_book_used  varchar2(15);

PROCEDURE Do_Validation
            (p_posting_status    IN     VARCHAR2,
             p_mass_add_rec      IN     FA_MASS_ADDITIONS%ROWTYPE,
             x_return_status        OUT NOCOPY VARCHAR2
            );

PROCEDURE Update_All_Records
            (p_posting_status    IN     VARCHAR2,
             p_where_clause      IN     VARCHAR2,
             x_success_count        OUT NOCOPY NUMBER,
             x_failure_count        OUT NOCOPY NUMBER,
             x_return_status        OUT NOCOPY VARCHAR2);


END FA_MASSADD_SPECIAL_PKG;

/
