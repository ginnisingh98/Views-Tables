--------------------------------------------------------
--  DDL for Package PAY_EVENT_PROCEDURES_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_PROCEDURES_BK1" AUTHID CURRENT_USER as
/* $Header: pyevpapi.pkh 120.2 2005/10/24 00:52:54 adkumar noship $ */
--
-- ---------------------------------------------------------------------
-- |-------------------< create_event_proc_b >------------------|
-- ---------------------------------------------------------------------
--
procedure create_event_proc_b
  (p_dated_table_id                 in     number
  ,p_procedure_name                 in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_column_name                    in     varchar2
  );
--
-- ----------------------------------------------------------------------
-- |------------------< create_event_proc_a >------------------|
-- ---------------------------------------------------------------------
--
procedure create_event_proc_a
  (p_dated_table_id                 in     number
  ,p_procedure_name                 in     varchar2
  ,p_business_group_id              in     number
  ,p_legislation_code               in     varchar2
  ,p_column_name                    in     varchar2
  ,p_event_procedure_id                in number
  ,p_object_version_number             in number
  );
end pay_event_procedures_bk1;

 

/
