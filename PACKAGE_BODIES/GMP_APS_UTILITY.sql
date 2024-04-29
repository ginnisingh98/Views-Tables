--------------------------------------------------------
--  DDL for Package Body GMP_APS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_APS_UTILITY" as
/* $Header: GMPXUTLB.pls 120.2 2007/12/16 22:09:31 asatpute ship $ */

FUNCTION is_opm_compatible RETURN NUMBER IS
BEGIN
  RETURN 1 ;
END is_opm_compatible ;

FUNCTION gmp_util1 (p_arg1      IN VARCHAR2,
                    p_arg2      IN VARCHAR2,
                    p_arg3      IN VARCHAR2,
                    p_argv      IN NUMBER )
                    RETURN NUMBER IS
BEGIN
  RETURN 0 ;
END gmp_util1 ;

END gmp_aps_utility;

/
