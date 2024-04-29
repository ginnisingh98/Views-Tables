--------------------------------------------------------
--  DDL for Package PQP_ERT_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_ERT_RKD" AUTHID CURRENT_USER as
/* $Header: pqertrhi.pkh 120.5 2006/09/15 00:09:22 sshetty noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_exception_report_id          in number
  ,p_language                     in varchar2
  ,p_exception_report_name_o      in varchar2
  ,p_source_lang_o                in varchar2
  );
--
end pqp_ert_rkd;

 

/
