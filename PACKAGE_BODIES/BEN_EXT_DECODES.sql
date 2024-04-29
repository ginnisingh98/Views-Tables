--------------------------------------------------------
--  DDL for Package Body BEN_EXT_DECODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_DECODES" as
/* $Header: benxdecd.pkb 115.3 2003/02/10 11:23:24 rpgupta ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ext_decodes.';  -- Global package name
g_person_id  number;
--
--
-- ----------------------------------------------------------------------------
-- |---------< main >---------------------------------------------|
-- ----------------------------------------------------------------------------
Function  main(p_short_name         varchar2,
                p_ext_data_elmt_id   number,
                p_business_group_id  number,
                p_person_id          number,
                p_dflt_val           varchar2) return varchar2 is

   l_proc            varchar2(72) := g_package||'main';
   l_rslt_elmt       varchar2(100) := null;

begin
   --
   hr_utility.set_location('Entering'||l_proc, 5);
   --
   null;
   -- this program is no longer used and should be removed from arcs.  logic
   -- has been moved to benxfrmt.pkb.
   --
   hr_utility.set_location('Exiting'||l_proc, 15);
   --
end main; -- main
-- ------------------------------------------------------------------
-- |------------------------< apply_decode >------------------------|
-- ------------------------------------------------------------------
--
Function apply_decode(p_value              varchar2,
                      p_ext_data_elmt_id   number,
                      p_default            varchar2
                      ) Return Varchar2 Is
--
  l_proc            varchar2(72) := g_package||'apply_decode';
  l_dcd_val         varchar2(30) := null;
--

--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
   --
  null;
  -- this program is no longer used and should be removed from arcs.  logic
  -- has been moved to benxfrmt.pkb.
  --
  hr_utility.set_location(' Exiting:'||l_proc, 15);
--
End apply_decode;
--
--
--
end ben_ext_decodes;

/
