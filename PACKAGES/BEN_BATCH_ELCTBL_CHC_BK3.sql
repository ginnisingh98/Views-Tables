--------------------------------------------------------
--  DDL for Package BEN_BATCH_ELCTBL_CHC_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BATCH_ELCTBL_CHC_BK3" AUTHID CURRENT_USER as
/* $Header: bebecapi.pkh 120.0 2005/05/28 00:37:14 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_elctbl_chc_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_elctbl_chc_b
  (p_batch_elctbl_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_batch_elctbl_chc_a >------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_batch_elctbl_chc_a
  (p_batch_elctbl_id                in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date);
--
end ben_batch_elctbl_chc_bk3;

 

/
