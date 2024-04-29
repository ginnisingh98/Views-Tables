--------------------------------------------------------
--  DDL for Package PAY_PPE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PPE_BK3" AUTHID CURRENT_USER as
/* $Header: pyppeapi.pkh 120.1.12010000.1 2008/07/27 23:25:09 appldev ship $ */
--
-- ----------------------------------------------------------------------
-- |---------------------< delete_process_event_b >------------------|
-- ----------------------------------------------------------------------
--
procedure delete_process_event_b
 ( p_process_event_id                     in     number
  ,p_object_version_number                in     number
  );--
-- ----------------------------------------------------------------------
-- |---------------------< delete_process_event_a  >------------------|
-- ----------------------------------------------------------------------
--
procedure delete_process_event_a
 ( p_process_event_id                     in     number
  ,p_object_version_number                in     number
  );
--
end pay_ppe_bk3;

/
