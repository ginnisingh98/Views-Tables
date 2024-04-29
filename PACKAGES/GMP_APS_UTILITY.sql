--------------------------------------------------------
--  DDL for Package GMP_APS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_APS_UTILITY" AUTHID CURRENT_USER as
/* $Header: GMPXUTLS.pls 115.0 2003/10/10 21:17:22 rpatangy noship $ */

FUNCTION is_opm_compatible RETURN NUMBER ;

FUNCTION gmp_util1 (p_arg1      IN VARCHAR2,
                    p_arg2      IN VARCHAR2,
                    p_arg3      IN VARCHAR2,
                    p_argv      IN NUMBER )
                    RETURN NUMBER ;

END gmp_aps_utility;

 

/
