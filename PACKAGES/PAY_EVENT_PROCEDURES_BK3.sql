--------------------------------------------------------
--  DDL for Package PAY_EVENT_PROCEDURES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EVENT_PROCEDURES_BK3" AUTHID CURRENT_USER as
/* $Header: pyevpapi.pkh 120.2 2005/10/24 00:52:54 adkumar noship $ */
--
-- ---------------------------------------------------------------------
-- |---------------------< delete_event_proc_b  >-----------------------|
-- ---------------------------------------------------------------------
--
procedure delete_event_proc_b
  (p_event_procedure_id                   in     number
  ,p_object_version_number                in     number
  );
--
-- ---------------------------------------------------------------------
-- |---------------------< delete_event_proc_a  >-----------------------|
-- ---------------------------------------------------------------------
--
procedure delete_event_proc_a
  (p_event_procedure_id                   in     number
  ,p_object_version_number                in     number
  );
end pay_event_procedures_bk3;

 

/
