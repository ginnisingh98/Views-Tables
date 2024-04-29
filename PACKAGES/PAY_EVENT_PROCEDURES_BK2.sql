--------------------------------------------------------
--  DDL for Package PAY_EVENT_PROCEDURES_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_PROCEDURES_BK2" AUTHID CURRENT_USER as
/* $Header: pyevpapi.pkh 120.2 2005/10/24 00:52:54 adkumar noship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< update_event_proc_b >------------------|
-- ---------------------------------------------------------------------
--
procedure update_event_proc_b
  (p_event_procedure_id           in     number
  ,p_object_version_number        in     number
  ,p_dated_table_id               in     number
  ,p_procedure_name               in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_column_name                  in     varchar2
  );
--
-- ----------------------------------------------------------------------
-- |---------------------< update_event_proc_a >------------------|
-- ---------------------------------------------------------------------
--
procedure update_event_proc_a
  (p_event_procedure_id           in     number
  ,p_object_version_number        in     number
  ,p_dated_table_id               in     number
  ,p_procedure_name               in     varchar2
  ,p_business_group_id            in     number
  ,p_legislation_code             in     varchar2
  ,p_column_name                  in     varchar2
  );
--
end pay_event_procedures_bk2;

 

/
