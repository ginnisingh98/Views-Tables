--------------------------------------------------------
--  DDL for Package Body HR_CERIDIAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CERIDIAN" as
/* $Header: pecerpkg.pkb 120.1 2005/06/24 05:50:47 kkoh noship $ */
--
--------------------------------------------------------------------
function fica_futa_exempt(medicare_tax_exempt in varchar2,
			  ss_tax_exempt in varchar2,
			  futa_tax_exempt in varchar2)
		          return varchar2 is exempt_id varchar2(10);
---------------------------------------------------------------------
--  This function returns FICA/FUTA Exemption codes for a combination
--  of medicare_tax_exempt, ss_tax_exempt and futa_tax_exempt columns.
--  The default return value is NULL.
--
begin
	IF (medicare_tax_exempt = 'N' and ss_tax_exempt = 'Y' and
	    futa_tax_exempt = 'N') then
        exempt_id:= 'F';
	ELSIF (medicare_tax_exempt = 'N' and ss_tax_exempt = 'N' and
	    futa_tax_exempt = 'Y') then
        exempt_id:= 'U';
	ELSIF (medicare_tax_exempt = 'N' and ss_tax_exempt = 'Y' and
   	futa_tax_exempt = 'Y') then
  	exempt_id:= 'E';
	ELSE
	exempt_id:='';
	END IF;
      RETURN exempt_id;
--
end fica_futa_exempt ;
--
------------------------------------------------------------------------
procedure set_cer_extract_date (p_cer_extract_date date)
------------------------------------------------------------------------
is
-- This procedure sets the g_cer_extract_date variable to the given date.
--
begin
   g_cer_extract_date := p_cer_extract_date;
   HR_PAY_INTERFACE_PKG.g_payroll_extract_date := p_cer_extract_date;
--
end set_cer_extract_date;
--
-----------------------------------------------------------------------
function get_cer_extract_date return date
------------------------------------------------------------------------
is
-- This function returns the g_cer_extract_date set by the call to
-- set_cer_extract_date. If set_cer_extract_date is never called, it
-- returns the sysdate
--
begin
   g_cer_extract_date := nvl(g_cer_extract_date, sysdate);
   RETURN g_cer_extract_date;
--
end get_cer_extract_date;
--
end hr_ceridian;

/
