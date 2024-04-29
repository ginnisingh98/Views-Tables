--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_REVAL_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_REVAL_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzfrrs.pls 115.4 2002/11/13 23:33:16 vsidhart ship $ */

/*+=========================================================================+
  |  PUBLIC PROCEDURE                                                       |
  |    reval_rules_generator                                                |
  |      p_book_type_code         Book Type Code                            |
  |      p_mass_reval_id          Mass Revaluation Id                       |
  |                                                                         |
  |  NOTES                                                                  |
  |  This procedure calculates the rates that have to be provided to the    |
  |  revaluation process in order to calculate the inflation adjustment.    |
  |  The rate is calculated in different ways depending on the type of book.|
  |  For CIP assets, the rate must consider the fact that current period    |
  |  modifications to the asset cost must not be inflation adjusted.        |
  |                                                                         |
  +=========================================================================+*/
  PROCEDURE reval_rules_generator (errbuf OUT NOCOPY VARCHAR2
                                 , retcode OUT NOCOPY VARCHAR2
                                 , p_book_type_code   IN  VARCHAR2
                                 , p_mass_reval_id    IN  NUMBER);

END jl_zz_fa_reval_rules_pkg;

 

/
