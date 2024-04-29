--------------------------------------------------------
--  DDL for Package BEN_COLLAPSE_LIFE_EVENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COLLAPSE_LIFE_EVENT" AUTHID CURRENT_USER as
/* $Header: benclpse.pkh 120.0.12000000.1 2007/01/19 15:09:35 appldev noship $ */
  --
  procedure main(p_person_id          in number,
                 p_business_group_id  in number,
                 p_mode               in varchar2,
                 p_min_lf_evt_ocrd_dt in date,
                 p_effective_date     in date);
  --
end ben_collapse_life_event;
--

 

/
