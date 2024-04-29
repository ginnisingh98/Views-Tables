--------------------------------------------------------
--  DDL for Package HXC_LKR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LKR_RKU" AUTHID CURRENT_USER as
/* $Header: hxclockrulesrhi.pkh 120.0 2005/05/29 06:25:55 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_locker_type_owner_id         in number
  ,p_locker_type_requestor_id     in number
  ,p_grant_lock                   in varchar2
  ,p_grant_lock_o                 in varchar2
  );
--
end hxc_lkr_rku;

 

/
