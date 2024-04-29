--------------------------------------------------------
--  DDL for Package HXC_LCK_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LCK_RKD" AUTHID CURRENT_USER as
/* $Header: hxclocktypesrhi.pkh 120.0 2005/05/29 06:26:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_locker_type_id               in number
  ,p_locker_type_o                in varchar2
  ,p_process_type_o               in varchar2
  );
--
end hxc_lck_rkd;

 

/
