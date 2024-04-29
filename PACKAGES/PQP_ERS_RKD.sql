--------------------------------------------------------
--  DDL for Package PQP_ERS_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERS_RKD" AUTHID CURRENT_USER as
/* $Header: pqersrhi.pkh 115.3 2003/02/17 22:14:17 tmehra noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_database_item_suffix         in varchar2
  ,p_legislation_code             in varchar2
  ,p_exception_report_period_o    in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqp_ers_rkd;

 

/
