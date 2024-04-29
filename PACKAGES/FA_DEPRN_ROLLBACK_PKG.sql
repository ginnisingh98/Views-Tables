--------------------------------------------------------
--  DDL for Package FA_DEPRN_ROLLBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_ROLLBACK_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXDRS.pls 120.1.12010000.2 2009/07/19 14:23:42 glchen ship $ */

   PROCEDURE do_rollback(
		errbuf                  OUT NOCOPY     VARCHAR2,
		retcode                 OUT NOCOPY     NUMBER,
		p_book_type_code	IN	VARCHAR2,
		p_period_name		IN 	VARCHAR2);

END FA_DEPRN_ROLLBACK_PKG;

/
