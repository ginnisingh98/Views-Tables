--------------------------------------------------------
--  DDL for Package HR_CERIDIAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CERIDIAN" AUTHID CURRENT_USER as
/* $Header: pecerpkg.pkh 120.1 2005/06/24 05:50:30 kkoh noship $ */
--
  g_cer_extract_date date;
--
  procedure set_cer_extract_date(p_cer_extract_date in date);
--
  function get_cer_extract_date return date;
  pragma restrict_references(get_cer_extract_date, WNDS, WNDS);
--
  function fica_futa_exempt(medicare_tax_exempt varchar2,
          			   ss_tax_exempt       varchar2,
					   futa_tax_exempt     varchar2)
				       return varchar2 ;
--
end hr_ceridian;

 

/
