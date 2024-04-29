--------------------------------------------------------
--  DDL for Package FA_SUPER_GROUP_CHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SUPER_GROUP_CHANGE_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXPSGCS.pls 120.0.12010000.2 2009/07/19 11:09:58 glchen ship $ */

   PROCEDURE do_super_group_change(
		errbuf                  OUT NOCOPY VARCHAR2,
		retcode                 OUT NOCOPY NUMBER);

END FA_SUPER_GROUP_CHANGE_PKG;

/
