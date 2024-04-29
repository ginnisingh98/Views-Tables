--------------------------------------------------------
--  DDL for Package Body GHR_CUSTOM_WGI_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CUSTOM_WGI_VALIDATION" as
/* $Header: ghcuswgi.pkb 120.0.12010000.2 2009/05/26 10:30:44 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ghr_custom_wgi_validation.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< custom_wgi_criteria >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure custom_wgi_criteria
  (p_wgi_in_data_rec              IN     GHR_WGI_PKG.wgi_in_rec_type
  ,p_wgi_out_data_rec             IN OUT NOCOPY GHR_WGI_PKG.wgi_out_rec_type
  ) IS
--
  l_proc       varchar2(72) := g_package||'custom_wgi_criteria';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  /*************** Add custom code here **************/
    --  /**************** EXAMPLE *********************************
  -- below is an example of what you may code if you what criteria to check.
  -- This critera could do some additional eligiblity check on top of the
  -- ones done by the GHR Auto WGI process.
  -- If < Customer validation fails > then
  --        Do not process the WGI for the person
  -- 		p_wgi_out_data_rec.process_person := FALSE;
  --        return;
  -- else
  --        Process the WGI for the person
  -- 		p_wgi_out_data_rec.process_person := TRUE;
  --        return;
  -- end if;
  --
  -- NOTE: You need to set process_person to TRUE or FALSE.
  --
  -- If you set process_person to FALSE based on your check the
  -- The Auto WGI process will not process this person for giving
  -- Auto WGI.
  --
  -- If you set process_person to TRUE the Auto WGI process
  -- will process a Auto WGI for this person.
  --
  --  ***********************************************************/
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end custom_wgi_criteria;
--
end ghr_custom_wgi_validation;

/
