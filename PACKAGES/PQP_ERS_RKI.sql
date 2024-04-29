--------------------------------------------------------
--  DDL for Package PQP_ERS_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERS_RKI" AUTHID CURRENT_USER as
/* $Header: pqersrhi.pkh 115.3 2003/02/17 22:14:17 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_database_item_suffix         in varchar2
  ,p_legislation_code             in varchar2
  ,p_exception_report_period      in varchar2
  ,p_object_version_number        in number
  );
end pqp_ers_rki;

 

/
