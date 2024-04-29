--------------------------------------------------------
--  DDL for Package FA_DEFERRED_DEPRN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEFERRED_DEPRN_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXDEFS.pls 120.3.12010000.2 2009/07/19 14:22:43 glchen ship $ */


Procedure do_deferred (errbuf                OUT NOCOPY     VARCHAR2,
                       retcode               OUT NOCOPY     NUMBER,
                       p_tax_book_type_code  IN varchar2,
                       p_tax_period_name     IN varchar2,
                       p_corp_period_name    IN varchar2);

END FA_DEFERRED_DEPRN_PKG;

/
