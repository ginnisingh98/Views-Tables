--------------------------------------------------------
--  DDL for Package FA_SET_PROFILE_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_SET_PROFILE_PKG1" AUTHID CURRENT_USER as
/* $Header: faxsprfs.pls 120.2.12010000.2 2009/07/19 13:03:46 glchen ship $ */

  PROCEDURE fa_sprf (prof 	 IN OUT NOCOPY VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_SET_PROFILE_PKG1;

/
