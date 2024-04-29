--------------------------------------------------------
--  DDL for Package FA_FADI_SHARED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FADI_SHARED_PKG" AUTHID CURRENT_USER as
/* $Header: farfadis.pls 120.1.12010000.2 2009/07/19 10:53:19 glchen ship $ */

PROCEDURE GET_ACCT_SEGMENT_NUMBERS (
   BOOK				IN	VARCHAR2,
   BALANCING_SEGNUM	 OUT NOCOPY NUMBER,
   ACCOUNT_SEGNUM	 OUT NOCOPY NUMBER,
   CC_SEGNUM		 OUT NOCOPY NUMBER,
   CALLING_FN			IN	VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_FADI_SHARED_PKG;

/
