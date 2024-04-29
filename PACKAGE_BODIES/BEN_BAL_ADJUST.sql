--------------------------------------------------------
--  DDL for Package Body BEN_BAL_ADJUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_BAL_ADJUST" as
/* $Header: bebaladj.pkb 120.0 2005/05/28 00:33:31 appldev noship $ */
   procedure ben_adjust_balance
     (p_effective_date             in date,
      p_batch_name                 in varchar2,
      p_consolidation_set_id       in number,
      p_action_type                in varchar2,
      p_assignment_id              in  number,
      p_element_link_id            in  number,
      p_input_value_id1            in  number   default null,
      p_input_value_id2            in  number   default null,
      p_input_value_id3            in  number   default null,
      p_input_value_id4            in  number   default null,
      p_input_value_id5            in  number   default null,
      p_input_value_id6            in  number   default null,
      p_input_value_id7            in  number   default null,
      p_input_value_id8            in  number   default null,
      p_input_value_id9            in  number   default null,
      p_input_value_id10           in  number   default null,
      p_input_value_id11           in  number   default null,
      p_input_value_id12           in  number   default null,
      p_input_value_id13           in  number   default null,
      p_input_value_id14           in  number   default null,
      p_input_value_id15           in  number   default null,
      p_entry_value1               in  varchar2 default null,
      p_entry_value2               in  varchar2 default null,
      p_entry_value3               in  varchar2 default null,
      p_entry_value4               in  varchar2 default null,
      p_entry_value5               in  varchar2 default null,
      p_entry_value6               in  varchar2 default null,
      p_entry_value7               in  varchar2 default null,
      p_entry_value8               in  varchar2 default null,
      p_entry_value9               in  varchar2 default null,
      p_entry_value10              in  varchar2 default null,
      p_entry_value11              in  varchar2 default null,
      p_entry_value12              in  varchar2 default null,
      p_entry_value13              in  varchar2 default null,
      p_entry_value14              in  varchar2 default null,
      p_entry_value15              in  varchar2 default null
     ) is
begin
   null;
end;
end;

/
