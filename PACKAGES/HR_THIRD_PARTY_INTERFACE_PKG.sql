--------------------------------------------------------
--  DDL for Package HR_THIRD_PARTY_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_THIRD_PARTY_INTERFACE_PKG" AUTHID CURRENT_USER AS
/* $Header: petpipkg.pkh 120.0 2005/05/31 22:16:29 appldev noship $ */
--
--
  g_payroll_extract_date date := sysdate;
--
  procedure set_extract_date(p_payroll_extract_date in date);
--
  function get_extract_date return date;
  pragma restrict_references(get_extract_date, WNPS, WNDS);
--
END HR_THIRD_PARTY_INTERFACE_PKG ;

 

/
