--------------------------------------------------------
--  DDL for Package Body BEN_EXT_ADV_CT_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EXT_ADV_CT_CHECK" as
/* $Header: benxadct.pkb 120.0 2006/05/03 23:25:47 rbingi noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
        Extract Advanced Conditions
Purpose
       THIS PACKKAGE CAN NOT BE EDITED WITHOUT PERMISSION FORM EXTRACT OWNER

History
        Date      Version  Who         What?
        ----      -------  ----------- ----------------------------------------
        25-APR-06  115.0    tjesumic   Created.
*/
--
g_package              varchar2(30) := ' ben_ext_adv_ct_check.';
--
--
Procedure rcd_in_file(p_ext_rcd_in_file_id in number,
                          p_sprs_cd in varchar2,
                          p_exclude_this_rcd_flag out nocopy boolean) is

--
l_proc     varchar2(72) := g_package||'rcd_in_file';
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--
end rcd_in_file;
--
-- ----------------------------------------------------------------------------
-- |--------------------< data_elmt_in_rcd >-----------------------------------|
-- ----------------------------------------------------------------------------
--
Procedure data_elmt_in_rcd(p_ext_rcd_id in number,
                           p_exclude_this_rcd_flag out nocopy boolean) is
--

l_proc     varchar2(72) := g_package||'data_elmt_in_rcd';
--
Begin
--
  hr_utility.set_location('Entering'||l_proc, 5);
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--
end data_elmt_in_rcd;
--
--


Procedure chk_val(p_ext_where_clause_id                in number,
                  p_oper_cd                     in varchar2,
                  p_val                         in varchar2,
                  p_effective_date              in date
                  ) is

   l_proc     varchar2(72) := g_package||'chk_val';
Begin

 --
  hr_utility.set_location('Entering'||l_proc, 5);
--
  hr_utility.set_location('Exiting'||l_proc, 15);
--


End  chk_val ;


End BEN_EXT_ADV_CT_CHECK ;

/
