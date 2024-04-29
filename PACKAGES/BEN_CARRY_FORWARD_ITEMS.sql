--------------------------------------------------------
--  DDL for Package BEN_CARRY_FORWARD_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CARRY_FORWARD_ITEMS" AUTHID CURRENT_USER as
/* $Header: bencfwsu.pkh 120.0.12010000.1 2008/07/29 12:04:03 appldev ship $ */
procedure main( p_person_id            number,
                p_per_in_ler_id        number,
                p_ler_id               number,
                p_effective_date       date,
                p_lf_evt_ocrd_dt       date,
                p_business_group_id    number);
--
procedure carry_farward_results(
                p_person_id             in number,
                p_per_in_ler_id         in number,
                p_ler_id                in number,
                p_business_group_id     in number,
                p_mode                  in varchar2,
                p_effective_date        in date) ;
--
end ben_carry_forward_items;

/
