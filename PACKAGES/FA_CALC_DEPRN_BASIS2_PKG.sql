--------------------------------------------------------
--  DDL for Package FA_CALC_DEPRN_BASIS2_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CALC_DEPRN_BASIS2_PKG" AUTHID CURRENT_USER as
/* $Header: faxcdb2s.pls 120.6.12010000.2 2009/07/19 10:45:45 glchen ship $ */
 PROCEDURE NON_STRICT_FLAT(
                           px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                           px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

 PROCEDURE FLAT_EXTENSION(
                          px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                          px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

 PROCEDURE PERIOD_AVERAGE(
                           px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                           px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

 PROCEDURE YTD_AVERAGE(
                       px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                       px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                       , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

 PROCEDURE POSITIVE_REDUCTION(
                             px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                             px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                             , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

 PROCEDURE HALF_YEAR(
                     px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                     px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

 PROCEDURE BEGINNING_PERIOD(
                           px_rule_in  IN OUT NOCOPY fa_std_types.fa_deprn_rule_in_struct ,
                           px_rule_out IN OUT NOCOPY fa_std_types.fa_deprn_rule_out_struct
                          , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_CALC_DEPRN_BASIS2_PKG;

/
