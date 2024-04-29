--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_TURNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_TURNS_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDEIVTNS.pls 115.0 2004/01/29 10:21:10 bthammin noship $ */

	PROCEDURE Refresh_Inventory_Turns (errbuf OUT NOCOPY VARCHAR2,
									   retcode OUT NOCOPY NUMBER);

END opi_dbi_inv_turns_pkg;

 

/
