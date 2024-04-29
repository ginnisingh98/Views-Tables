--------------------------------------------------------
--  DDL for Package Body BEN_UPDATE_PRTT_RT_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_UPDATE_PRTT_RT_VAL" as
/* $Header: benupprv.pkb 115.1 2003/02/12 12:08:46 rpgupta noship $ */
procedure update_element_entry_value(p_element_type_id IN NUMBER,
                                     p_element_entry_id in number,
                                     p_creator_id in Number,
                                     p_effective_date in date) is
--
--
cursor c_prv is
select prv.prtt_rt_val_id,
       prv.business_group_id,
       prv.rt_strt_dt,
       prv.object_version_number,
       abr.input_value_id
from  ben_prtt_rt_val prv,
      ben_acty_base_rt_f abr
where prv.prtt_enrt_rslt_id = p_creator_id
and   prv.rt_end_dt = to_date('31-12-4712','dd-mm-yyyy')
and   prv.acty_base_rt_id = abr.acty_base_rt_id
and   abr.element_type_id = p_element_type_id
and   p_effective_date between abr.effective_start_date
      and abr.effective_end_date;
--
cursor get_entry_value
    (p_element_entry_id IN NUMBER
    ,p_input_value_id   IN NUMBER
    ,p_effective_date   IN DATE
    )
  is
    select element_entry_value_id
    from   pay_element_entry_values_f
    where  element_entry_id = p_element_entry_id
    and    input_value_id   = p_input_value_id
    and    p_effective_date between effective_start_date
    and    effective_end_date;
--
l_element_entry_value_id number;
l_prv  c_prv%rowtype;

begin
  open c_prv;
  loop
    fetch c_prv into l_prv;
    if c_prv%NOTFOUND then
       exit;
    end if;
    --
    l_element_entry_value_id := null;
    open get_entry_value (p_element_entry_id=>p_element_entry_id,
                            p_input_value_id => l_prv.input_value_id,
                            p_effective_date => p_effective_date);
    fetch get_entry_value into l_element_entry_value_id;
    close get_entry_value;
    if l_element_entry_value_id is not null then
        ben_prtt_rt_val_api.update_prtt_rt_val
         (p_validate                => false
         ,p_prtt_rt_val_id          => l_prv.prtt_rt_val_id
         ,p_business_group_id       => l_prv.business_group_id
         ,p_element_entry_value_id  => l_element_entry_value_id
         ,p_object_version_number   => l_prv.object_version_number
         ,p_effective_date          => l_prv.rt_strt_dt
   );

    end if;
    --
  End loop;
  close c_prv;
end update_element_entry_value;
end ben_update_prtt_rt_val;

/
