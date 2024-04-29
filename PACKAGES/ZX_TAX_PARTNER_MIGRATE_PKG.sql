--------------------------------------------------------
--  DDL for Package ZX_TAX_PARTNER_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TAX_PARTNER_MIGRATE_PKG" AUTHID CURRENT_USER as
/* $Header: zxptnrmigpkgs.pls 120.3 2005/09/22 09:30:37 asengupt ship $ */

 PROCEDURE MIGRATE_TAX_PARTNER(x_return_status OUT NOCOPY VARCHAR2);

END ZX_TAX_PARTNER_MIGRATE_PKG;

 

/
