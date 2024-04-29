--------------------------------------------------------
--  DDL for Package BEN_UPDATE_PRTT_RT_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_UPDATE_PRTT_RT_VAL" AUTHID CURRENT_USER as
/* $Header: benupprv.pkh 120.0 2005/05/28 09:33:20 appldev noship $ */
procedure update_element_entry_value(p_element_type_id IN NUMBER,
                                     p_element_entry_id in number,
                                     p_creator_id in Number,
                                     p_effective_date in date);
end ben_update_prtt_rt_val;

 

/
