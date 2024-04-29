--------------------------------------------------------
--  DDL for Package PAY_CORE_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CORE_MLS" AUTHID CURRENT_USER as
/* $Header: pycormls.pkh 115.3 2003/01/10 12:46:30 adhunter ship $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    pay_core_mls
  NOTES
    MLS functions for core payroll
  MODIFIED
--
    N.Bristow  17-JUN-1999  115.0  Created
    PMFLETCH   11-DEC-2002  115.2  Added get_nls_language function
    --
* ---------------------------------------------------------------------------
*/
  function get_srs_lang return varchar2;
--
  function get_nls_language
             ( p_language_code in fnd_languages.language_code%TYPE
             ) return varchar2;
--
end pay_core_mls;

 

/
