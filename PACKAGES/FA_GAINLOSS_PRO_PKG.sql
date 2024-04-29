--------------------------------------------------------
--  DDL for Package FA_GAINLOSS_PRO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_GAINLOSS_PRO_PKG" AUTHID CURRENT_USER AS
/* $Header: fagpros.pls 120.2.12010000.2 2009/07/19 13:57:27 glchen ship $*/

/*=============================================================================
|  NAME         fagpsa                                                        |
|                                                                             |
|  FUNCTION     This function loads the control byte and performs all the     |
|               retirement and reinstatement calculations if needed.          |
|                                                                             |
|  HISTORY      1/12/89    M Chan       Created                               |
|                                                                             |
|               01/09/97   S Behura     Rewrote in PL/SQL                     |
|============================================================================*/

Function fagpsa (ret in out nocopy fa_ret_types.ret_struct, today in date,
                 cpd_name in varchar2, cpd_ctr in number,
                 user_id in number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_GAINLOSS_PRO_PKG;

/
