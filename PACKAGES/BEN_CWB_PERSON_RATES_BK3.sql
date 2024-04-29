--------------------------------------------------------
--  DDL for Package BEN_CWB_PERSON_RATES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_PERSON_RATES_BK3" AUTHID CURRENT_USER as
/* $Header: bertsapi.pkh 120.3.12000000.1 2007/01/19 23:09:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_rate_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_rate_b
  (p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_rate_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_rate_a
  (p_group_per_in_ler_id           in     number
  ,p_pl_id                         in     number
  ,p_oipl_id                       in     number
  ,p_object_version_number         in     number
  );
--
end BEN_CWB_PERSON_RATES_BK3;

 

/
