--------------------------------------------------------
--  DDL for Package Body PAY_ADVANCE_PAY_ELE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ADVANCE_PAY_ELE_PKG" as
/* $Header: pyadvele.pkb 115.0 2003/11/13 16:29 susivasu noship $ */
--
g_leg_code pay_legislation_rules.legislation_code%TYPE := null;
g_subpriority number := null;
--
function get_subpriority(p_leg_code      in varchar2,
                         p_creator_type  in varchar2,
                         p_subpriority   in number)
        return pay_element_entries_f.subpriority%TYPE is
--
  cursor csr_subpriority is
  select to_number(plr.rule_mode)
    from pay_legislation_rules plr
   where upper(plr.legislation_code) = upper(p_leg_code)
     and upper(plr.rule_type) = 'ADV_EE_SUBPRIORITY';
--
  l_subpriority  pay_element_entries_f.subpriority%TYPE;
--
begin
--
  if (p_creator_type not in ('AE','AD')) then
     --
     -- If the entry is other than the advanced or deducted entry then
     -- return the passed subpriority value.
     --
     l_subpriority := p_subpriority;
     --
  elsif upper(g_leg_code) = upper(p_leg_code) then
     --
     -- If the legislation code exists then use the chached value.
     --
     l_subpriority := g_subpriority;
     --
  else
     --
     -- Derive the value and then caches the derieved value.
     --
     open csr_subpriority;
     fetch csr_subpriority into l_subpriority;
     --
     if (csr_subpriority%found) then
        --
        g_subpriority := l_subpriority;
        g_leg_code := p_leg_code;
        --
     else
        l_subpriority := p_subpriority;
     end if;
     --
     close csr_subpriority;
     --
  end if;
  --
  return l_subpriority;
--
end get_subpriority;
--
End PAY_ADVANCE_PAY_ELE_PKG;

/
