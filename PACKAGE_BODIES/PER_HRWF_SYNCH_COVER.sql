--------------------------------------------------------
--  DDL for Package Body PER_HRWF_SYNCH_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_HRWF_SYNCH_COVER" AS
/* $Header: perhrwfs.pkb 120.4.12010000.2 2008/11/11 09:27:14 skura ship $ */
--
  --
  g_package varchar2(30) := 'per_hrwf_synch_cover.';
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_per_wf >------------------------------|
  -- --------------------------------------------------------------------------
    procedure per_per_wf(
              p_rec                  in per_per_shd.g_rec_type,
              p_action               in varchar2) is
      --
         l_proc             varchar2(80) := g_package||'per_per_wf';
      --
    begin
      --
      --
         hr_utility.set_location('Entering '||l_proc, 10);
      --
      -- Calling the actual procedure
         per_hrwf_synch.per_per_wf(p_rec      => p_rec,
                                   p_action   => p_action);
      --
         hr_utility.set_location('Leaving '||l_proc, 20);
      --
      --
    end per_per_wf;
  --
  -- --------------------------------------------------------------------------
  -- |-----------------------------< per_pds_wf >------------------------------|
  -- --------------------------------------------------------------------------
    procedure per_pds_wf(
              p_person_id            in number,
              p_date                 in date default null,
              p_date_start           in date,
              p_action               in varchar2) is
      --
         l_proc             varchar2(80) := g_package||'per_pds_wf';
      --
    begin
      --
      --
         hr_utility.set_location('Entering '||l_proc, 10);
      --
      -- Calling the actual procedure
         per_hrwf_synch.per_pds_wf(p_person_id   => p_person_id,
                                   p_date        => p_date,
                                   p_date_start  => p_date_start,
                                   p_action      => p_action);
      --
         hr_utility.set_location('Leaving '||l_proc, 20);
      --
      --
    end per_pds_wf;
  --
--
END PER_HRWF_SYNCH_COVER;

/
