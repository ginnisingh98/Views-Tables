--------------------------------------------------------
--  DDL for Package BEN_CWB_BDGT_CHNG_POP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_BDGT_CHNG_POP" AUTHID CURRENT_USER as
/* $Header: bencwbchngpop.pkh 120.0 2005/05/28 13:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< CLEAR_BDGT_VALS >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
-- This procedure is used to clear all the bdgt values for the Current
-- Population when population got changed.
-- (clears either distribution budget or worksheet budget depending on the
-- manager type LLM or HLM)
--
procedure clear_bdgt_vals
  (p_validate                      in     boolean  default false
  ,p_grp_per_in_ler_id             in     number
  ,p_grp_pl_id                     in     number
  ,p_current_bdgt_pop              in     varchar2
  ,p_lf_evt_ocrd_dt                in     date
  ,p_effective_date                in     date	   default sysdate
  ,p_logon_person_id               in     number
  );
--
end ben_cwb_bdgt_chng_pop;

 

/
