--------------------------------------------------------
--  DDL for Package Body BEN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_RULES" as
/*$Header: benrules.pkb 120.1.12000000.1 2007/01/19 18:59:25 appldev ship $*/
--
/*
History
  Version Date       Author     Comment
  -------+----------+----------+---------------------------------------------------
  115.0   08-Sep-99  maagrawa   Created.
  115.1   18-Jan-00  pbodla     Fixed bug 4146(WWBUG 1120687)
                                p_business_group_id added to benutils.formula call.
  115.4   30-Jun-06  swjain     5331889 - Passed ler_id and person_id in call to
                                benutils.formula in procedure chk_person_selection.
  ---------------------------------------------------------------------------------
*/
--
g_package    varchar2(80) := 'ben_rules';
--
function chk_person_selection
    (p_person_selection_rule_id in number,
     p_person_id                in number,
     p_business_group_id        in number,
     p_effective_date           in date,
     p_ler_id                   in number) return boolean is
  --
  l_outputs       ff_exec.outputs_t;
  l_assignment_id number;
  --
begin
  --
  if p_person_selection_rule_id is null then
    --
    return true;
    --
  else
    --
    l_assignment_id := benutils.get_assignment_id
                         (p_person_id         => p_person_id,
                          p_business_group_id => p_business_group_id,
                          p_effective_date    => p_effective_date);
    --
    l_outputs := benutils.formula
      (p_formula_id     => p_person_selection_rule_id,
       p_effective_date => p_effective_date,
       p_business_group_id => p_business_group_id,
       p_assignment_id  => l_assignment_id,
       p_param1         => 'BEN_IV_PERSON_ID',           -- Bug 5331889
       p_param1_value   => to_char(p_person_id),
       p_param2         => 'BEN_LER_IV_LER_ID',
       p_param2_value   => to_char(p_ler_id)
);
    --
    if l_outputs(l_outputs.first).value = 'Y' then
      --
      return true;
      --
    elsif l_outputs(l_outputs.first).value = 'N' then
      --
      return false;
      --
    elsif l_outputs(l_outputs.first).value <> 'N' then
      --
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      raise ben_manage_life_events.g_record_error;
      --
    end if;
    --
  end if;
  --
end chk_person_selection;
--
--
--
--
function chk_comp_object_selection
           (p_oipl_id                  in number,
            p_pl_id                    in number,
            p_pgm_id                   in number,
            p_pl_typ_id                in number,
            p_opt_id                   in number,
            p_business_group_id        in number,
            p_comp_selection_rule_id   in number,
            p_effective_date           in date) return boolean is
  --
  l_package   varchar2(80) := g_package||'.chk_comp_object_selection';
  l_outputs   ff_exec.outputs_t;
  l_return    varchar2(30);
  --
begin
  --
  hr_utility.set_location ('Entering '||l_package,10);
  --
  if p_comp_selection_rule_id is not null then
    --
    -- Call formula initialise routine
    --
    hr_utility.set_location ('call formula '||l_package,20);
    l_outputs := benutils.formula
       (p_formula_id        => p_comp_selection_rule_id,
        p_effective_date    => p_effective_date,
        p_business_group_id => p_business_group_id,
        p_assignment_id     => null,
        p_organization_id   => null,
        p_pl_id             => p_pl_id,
        p_pl_typ_id         => p_pl_typ_id,
        p_pgm_id            => p_pgm_id,
        p_opt_id            => p_opt_id,
        p_jurisdiction_code => null);
    --
    -- Formula will return Y or N
    --
    l_return := l_outputs(l_outputs.first).value;
    --
    if l_return = 'N' then
      --
      hr_utility.set_location ('Ret N '||l_package,10);
      return false;
      --
    elsif l_return = 'Y' then
      --
      hr_utility.set_location ('Ret Y '||l_package,10);
      return true;
      --
    elsif l_return <> 'Y' then
      --
      -- Defensive coding for Non Y return
      --
      fnd_message.set_name('BEN','BEN_91329_FORMULA_RETURN');
      fnd_message.raise_error;
      --
    end if;
    --
  else
    --
    hr_utility.set_location ('Leaving TRUE '||l_package,10);
    return true;
    --
  end if;
  --
end chk_comp_object_selection;


end ben_rules;

/
