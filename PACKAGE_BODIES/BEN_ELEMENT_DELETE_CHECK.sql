--------------------------------------------------------
--  DDL for Package Body BEN_ELEMENT_DELETE_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ELEMENT_DELETE_CHECK" as
/* $Header: beneedck.pkb 115.4 2003/02/05 19:27:43 mmudigon noship $ */
procedure check_element_delete(p_element_entry_id IN NUMBER) is
--
-- This cursor checks that there are no rates
-- that are attached to the same element we are trying to
-- delete the element entry for.
-- If element entry is for a rate, error condition is thrown
--
cursor c_abr is
select 1
from   ben_acty_base_rt_f
where  element_type_id in
    (select el.element_type_id
     from   pay_element_entries_f ee
          , pay_element_links_f el
     where el.element_link_id = ee.element_link_id
     and   ee.element_entry_id = p_element_entry_id
     --Bug 2673501 fixes added this to see if it is creation by benefits process.
     --We show this error for the rows created by the benefits process.
     and   ee.creator_id in
       ( select pen.prtt_enrt_rslt_id
         from ben_prtt_enrt_rslt_f pen ));
l_temp number;
begin
  open c_abr;
  fetch c_abr into l_temp;
  if c_abr%FOUND then
    close c_abr;
    fnd_message.set_name('BEN','BEN_93109_ELEMENT_USED_BY_RT');
    fnd_message.raise_error;
  else
    close c_abr;
  end if;
end check_element_delete;
end ben_element_delete_check;

/
