--------------------------------------------------------
--  DDL for Package PAY_BATCH_OBJECT_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BATCH_OBJECT_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: pybos.pkh 120.1 2006/09/26 14:48:26 thabara noship $ */

--
-- ----------------------------------------------------------------------------
-- get_status
--
-- Returns the status of the specified object.
-- ----------------------------------------------------------------------------
function get_status
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ) return varchar2;
--
-- ----------------------------------------------------------------------------
-- get_status_meaning
--
-- Returns the status meaning of the specified object.
-- ----------------------------------------------------------------------------
function get_status_meaning
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_default_status               in     varchar2 default null
  ) return varchar2;
--
-- ----------------------------------------------------------------------------
-- lock_batch_object
--
-- Locks the object status record.
-- If p_object_status is specified, see if the status is up to date.
-- If the batch object does not exist, the default status will be used instead.
-- ----------------------------------------------------------------------------
procedure lock_batch_object
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_object_status                in     varchar2 default null
  ,p_default_status               in     varchar2 default null
  );
--
-- ----------------------------------------------------------------------------
-- chk_complete_status
--
-- Locks the object record and see if the status is complete.
-- ----------------------------------------------------------------------------
procedure chk_complete_status
  (p_object_type                  in            varchar2
  ,p_object_id                    in            number
  );
--
-- ----------------------------------------------------------------------------
-- set_status
--
-- Sets the object status.
-- ----------------------------------------------------------------------------
procedure set_status
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_object_status                in     varchar2
  ,p_payroll_action_id            in     number   default null
  );
--
-- ----------------------------------------------------------------------------
-- delete_object_status
--
-- Deletes the object status record.
-- ----------------------------------------------------------------------------
procedure delete_object_status
  (p_object_type                  in     varchar2
  ,p_object_id                    in     number
  ,p_payroll_action_id            in     number default null
  );
-------------------------------------------------------------------------------

end pay_batch_object_status_pkg;

/
