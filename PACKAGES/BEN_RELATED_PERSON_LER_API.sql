--------------------------------------------------------
--  DDL for Package BEN_RELATED_PERSON_LER_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RELATED_PERSON_LER_API" AUTHID CURRENT_USER as
/* $Header: benrllrb.pkh 120.0 2005/05/28 09:26:32 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_related_person_ler >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This event determines any impact on persons, e.g. dependents or
-- beneficiaries related to a current participant, new participant, or
-- former participant as the result of an information change to a participant,
-- e.g. death, divorce, or termination.
--
-- This process performs the following operations:
--
-- 1.	For a single person, accept a life event reason.
-- 2.	Determine if the particpant's life event has an associated related person life event.
-- 3.	If found, identify participant's related persons, if any.
-- 4.	If found, create related person's potential life event.
--
-- Prerequisites:
-- Person must have a PER_IN_LER record for the ler_id passed in.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                           boolean
--  p_person_id                      Y   number
--  p_ler_id                         Y   number    Life Event id that the person
--                                                 experienced on which we are basing
--                                                 a related person life event.
--  p_effective_date                 Y   date
--  p_business_group_id              Y   number
--  p_from_form                          varchar2  If being called in batch mode, then
--                                                 pass in a 'N'.  Otherwise we assume
--                                                 we are being called from a form.  When
--                                                 called from a form, the benutils report
--                                                 is NOT created, and the p_validate CAN
--                                                 cause a rollback.  Errors are also processed
--                                                 differently.
--
-- Post Success:
-- A record is written to ben_ptnl_ler_for_per_f.
--
-- Post Failure:
-- If p_from_form = 'N', then an error row is written to the report.
-- if p_from_form = 'Y', then the error is passed along to the form.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_related_person_ler
  (p_validate                       in  boolean   default false
  ,p_person_id                      in  number
  ,p_ler_id                         in  number
  ,p_effective_date                 in  date
  ,p_business_group_id              in  number
  ,p_csd_by_ptnl_ler_for_per_id     in  number    default null
  ,p_from_form                      in  varchar2  default 'Y' ) ;
--
end ben_Related_person_ler_api;

 

/
