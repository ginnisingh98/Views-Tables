--------------------------------------------------------
--  DDL for Package Body BEN_CWB_CUSTOM_PERSON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_CUSTOM_PERSON_PKG" as
/* $Header: bencwbpr.pkb 120.0 2005/05/28 04:00:44 appldev noship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_custom_person_pkg.'; --Global package name
g_debug boolean := hr_utility.debug_enabled;
--
--
-- --------------------------------------------------------------------------
-- |---------------------------< get_custom_name >---------------------------|
-- --------------------------------------------------------------------------
function get_custom_name(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_name';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;

end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment1 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment1(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment1';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;

end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment2 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment2(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment2';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;

end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment3 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment3(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment3';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --   return null;
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment4 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment4(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment4';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment5 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment5(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment5';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment6 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment6(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment6';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment7 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment7(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment7';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment8 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment8(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment8';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment9 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment9(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment9';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment10 >------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment10(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return varchar2 is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment10';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment11 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment11(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment11';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment12 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment12(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment12';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment13 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment13(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment13';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --   return null;

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment14 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment14(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment4';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --

exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;



end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment15 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment15(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment15';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--

-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment16 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment16(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment16';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment17 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment17(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment17';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment18 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment18(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment18';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment19 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment19(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment19';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment20 >-------------------------|
-- --------------------------------------------------------------------------
function get_custom_segment20(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number is
--
   l_proc     varchar2(72) := g_package||'get_custom_segment20';
--
begin
   --
   if g_debug then
      hr_utility.set_location('Entering:'|| l_proc, 10);
   end if;
   --
   return null;
   --
   if g_debug then
      hr_utility.set_location(' Leaving:'|| l_proc, 99);
   end if;
   --
exception
    when others then
        hr_utility.set_location('Exception in '|| l_proc, 99);
    raise;


end;
--



end BEN_CWB_CUSTOM_PERSON_PKG;



/
