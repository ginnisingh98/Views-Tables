--------------------------------------------------------
--  DDL for Package FA_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_UTIL_PUB" AUTHID CURRENT_USER as
/* $Header: FAPUTILS.pls 120.0.12010000.2 2009/07/19 09:53:28 glchen ship $   */

FUNCTION get_log_level_rec
   (x_log_level_rec        OUT NOCOPY FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_UTIL_PUB ;

/
