--------------------------------------------------------
--  DDL for Package ZX_EVNT_OPTIONS_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_EVNT_OPTIONS_MIGRATE_PKG" AUTHID CURRENT_USER as
/* $Header: zxevntoptmigpkgs.pls 120.2.12010000.1 2008/07/28 13:31:37 appldev ship $ */
 PROCEDURE MIGRATE_EVNT_CLS_OPTIONS(x_return_status OUT NOCOPY VARCHAR2);

END ZX_EVNT_OPTIONS_MIGRATE_PKG;

/
