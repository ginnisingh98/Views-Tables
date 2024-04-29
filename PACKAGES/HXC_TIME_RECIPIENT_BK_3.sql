--------------------------------------------------------
--  DDL for Package HXC_TIME_RECIPIENT_BK_3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIME_RECIPIENT_BK_3" AUTHID CURRENT_USER as
/* $Header: hxchtrapi.pkh 120.1 2005/10/02 02:06:55 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_recipient_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_recipient_b
  (p_time_recipient_id              in     NUMBER
  ,p_object_version_number          in     NUMBER
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_time_recipient_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_recipient_a
  (p_time_recipient_id              in     NUMBER
  ,p_object_version_number          in     NUMBER
  );
--
end hxc_time_recipient_bk_3;

 

/
