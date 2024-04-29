--------------------------------------------------------
--  DDL for Package BEN_CUSTOM_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CUSTOM_FORMULA" AUTHID CURRENT_USER as
/* $Header: bencustf.pkh 120.0 2005/05/28 03:55:58 appldev noship $ */
/*
This package is to be used to deliver custom formula examples.
see bencustf.sql for delivering formula functions.

Function overview
*****************
contact_valid
-------------
  This function allows formula to test validity of
  contact types. I.E. Do I have a spouse who is over
  25 years old. If so if she causes a boundary event
  then create a temporal event.
*/
  --
  function contact_valid
    (p_assignment_id      in number, -- Context
     p_effective_date     in date,   -- Context
     p_business_group_id  in number,   -- Context
     p_pgm_id             in number, -- Context
     p_pl_typ_id          in number, -- Context
     p_pl_id              in number, -- Context
     p_opt_id             in number, -- Context
     p_contact_type       in varchar2,
     p_min_age_val        in number,
     p_max_age_val        in number,
     p_age_det_cd         in varchar2,
     p_age_det_rl         in number,
     p_age_uom            in varchar2,
     p_rndg_cd            in varchar2,
     p_rndg_rl            in number,
     p_create_tmprl_event in varchar2 default 'N') return varchar2;
  --
end ben_custom_formula;
--

 

/
