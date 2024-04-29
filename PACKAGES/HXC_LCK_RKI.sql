--------------------------------------------------------
--  DDL for Package HXC_LCK_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LCK_RKI" AUTHID CURRENT_USER as
/* $Header: hxclocktypesrhi.pkh 120.0 2005/05/29 06:26:19 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_locker_type_id               in number
  ,p_locker_type                  in varchar2
  ,p_process_type                 in varchar2
  );
end hxc_lck_rki;

 

/
