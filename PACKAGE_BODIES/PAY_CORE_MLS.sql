--------------------------------------------------------
--  DDL for Package Body PAY_CORE_MLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_MLS" as
/* $Header: pycormls.pkb 115.3 2003/01/10 12:46:48 adhunter ship $ */
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
    PMFLETCH   11-DEC-2002  115.2   Added get_nls_language function
    N.Bristow  21-JUL-1999  115.1   Changed to use the language
                                    that the request was
                                    submitted in.
    N.Bristow  17-JUN-1999  115.0   Created
    --
* ---------------------------------------------------------------------------
*/
  function get_srs_lang return varchar2 is
   lang_str varchar2(30);
   req_id   number;
  begin
--
    req_id := fnd_request_info.GET_REQUEST_ID;
--
    -- Use the calling language if installed,
    -- default to US if theres a problem.
    begin
--
      select LANGUAGE_CODE
      into lang_str
      from fnd_languages           flang,
           fnd_concurrent_requests fcr
      where fcr.NLS_LANGUAGE = flang.NLS_LANGUAGE
        and fcr.request_id = req_id
        and flang.INSTALLED_FLAG in ('B', 'I');
--
    exception
       when others then
         lang_str := 'US';
    end;
--
    return (lang_str);
--
  exception
     when others then
       lang_str := 'US';
       return (lang_str);
  end;
--
-----------------------------------------------------------------------------
  function get_nls_language
             ( p_language_code in fnd_languages.language_code%TYPE
             ) return varchar2 IS
--
  cursor c_nls_language IS
    select l.nls_language
      from fnd_languages l
     where l.language_code = p_language_code;
--
  l_nls_language  fnd_languages.nls_language%TYPE;
--
  nls_language_not_found exception;
--
  begin
    open c_nls_language;
    fetch c_nls_language into l_nls_language;
    close c_nls_language;
    if ( l_nls_language IS NOT NULL ) then
      return l_nls_language;
    else
      raise nls_language_not_found;
    end if;
  exception
    when nls_language_not_found then
      hr_utility.set_location(' Cannot find nls_language, pay_core_mls.get_nls_language', 99);
      raise;
    when others then
      raise;
  end;
--
end pay_core_mls;

/
