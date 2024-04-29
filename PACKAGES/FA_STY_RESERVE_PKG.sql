--------------------------------------------------------
--  DDL for Package FA_STY_RESERVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_STY_RESERVE_PKG" AUTHID CURRENT_USER as
/* $Header: faxstups.pls 120.1.12010000.2 2009/07/19 13:06:13 glchen ship $   */
PROCEDURE faxstur(
		errbuf		 OUT NOCOPY VARCHAR2,
		retcode		 OUT NOCOPY NUMBER,
		p_book_type_code	IN	VARCHAR2);

END FA_STY_RESERVE_PKG;

/
