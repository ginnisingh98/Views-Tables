--------------------------------------------------------
--  DDL for Package IBE_PURGE_QUOTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PURGE_QUOTES" AUTHID CURRENT_USER as
/* $Header: IBEPURGES.pls 120.0.12010000.2 2015/08/01 05:38:51 ytian noship $ */


procedure purgeIBEQuoteObjects(
	errbuf	OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER);

end;

/
