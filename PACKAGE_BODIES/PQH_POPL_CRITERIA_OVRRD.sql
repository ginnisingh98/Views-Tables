--------------------------------------------------------
--  DDL for Package Body PQH_POPL_CRITERIA_OVRRD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_POPL_CRITERIA_OVRRD" as
/* $Header: pqrbcovd.pkb 120.1 2005/09/02 12:17 srajakum noship $ */
--
g_package                 varchar2(33) := 'pqh_popl_criteria_ovrrd';  -- Global package name
g_last_criteria_index     number(15);
--

-------------------------< init_criteria_override_tbl >----------------------------------
Procedure init_criteria_override_tbl is
--
l_proc             varchar2(72) := g_package||'init_criteria_override_tbl';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_criteria_count := 0;
  g_last_criteria_index := 0;
  g_criteria_override_val.DELETE;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;


Procedure insert_criteria_override(p_crit_ovrrd_val_rec IN g_crit_ovrrd_val_rec) is
--
l_proc             varchar2(72) := g_package||'insert_criteria_override';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_last_criteria_index := g_last_criteria_index +1;
  g_criteria_count := g_last_criteria_index;
  g_criteria_override_val(g_last_criteria_index).criteria_short_code := p_crit_ovrrd_val_rec.criteria_short_code;
  g_criteria_override_val(g_last_criteria_index).number_value1 := p_crit_ovrrd_val_rec.number_value1;
  g_criteria_override_val(g_last_criteria_index).number_value2 := p_crit_ovrrd_val_rec.number_value2;
  g_criteria_override_val(g_last_criteria_index).char_value1 := p_crit_ovrrd_val_rec.char_value1;
  g_criteria_override_val(g_last_criteria_index).char_value2 := p_crit_ovrrd_val_rec.char_value2;
  g_criteria_override_val(g_last_criteria_index).date_value1 := p_crit_ovrrd_val_rec.date_value1;
  g_criteria_override_val(g_last_criteria_index).date_value2 := p_crit_ovrrd_val_rec.date_value2;

  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;


Procedure get_criteria_override(p_crit_ovrrd_val_rec OUT nocopy g_crit_ovrrd_val_rec) is
--
l_proc             varchar2(72) := g_package||'get_criteria_override';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  g_last_criteria_index := g_last_criteria_index +1;
  --
  p_crit_ovrrd_val_rec.criteria_short_code := g_criteria_override_val(g_last_criteria_index).criteria_short_code ;
  p_crit_ovrrd_val_rec.number_value1 := g_criteria_override_val(g_last_criteria_index).number_value1 ;
  p_crit_ovrrd_val_rec.number_value2 :=  g_criteria_override_val(g_last_criteria_index).number_value2 ;
  p_crit_ovrrd_val_rec.char_value1 := g_criteria_override_val(g_last_criteria_index).char_value1 ;
  p_crit_ovrrd_val_rec.char_value2 := g_criteria_override_val(g_last_criteria_index).char_value2 ;
  p_crit_ovrrd_val_rec.date_value1 := g_criteria_override_val(g_last_criteria_index).date_value1 ;
  p_crit_ovrrd_val_rec.date_value2 := g_criteria_override_val(g_last_criteria_index).date_value2 ;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
End;
--
End pqh_popl_criteria_ovrrd;

/
