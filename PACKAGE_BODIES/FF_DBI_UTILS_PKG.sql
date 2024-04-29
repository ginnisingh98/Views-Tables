--------------------------------------------------------
--  DDL for Package Body FF_DBI_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FF_DBI_UTILS_PKG" as
/* $Header: ffdbiutl.pkb 120.4 2007/03/29 09:58:11 alogue noship $ */

--
-- Maximum length of a database item name in characters (not bytes).
--
C_DBI_NAME_LEN constant number := 160;

--
-- Legislation rule for translations support.
--
C_TRANS_LEG_RULE constant varchar2(64) := 'FF_TRANSLATE_DATABASE_ITEMS';

--
-- Caches for supported and unsupported translations.
--
type t_vc2_16 is table of varchar2(16) index by binary_integer;
g_trans_supported t_vc2_16;
g_got_supported   boolean := false;

------------------------------ str2dbiname -------------------------------
function str2dbiname
(p_str in varchar2
) return varchar2 is
l_dbi_name   varchar2(2000);
l_underscore varchar2(30) := ' -';
l_remove     varchar2(30) := '"()''.';
l_rgeflg     varchar2(10);
l_debug      boolean := hr_utility.debug_enabled;
begin
  -- Get rid of leading and trailing spaces.
  l_dbi_name := ltrim(rtrim(p_str));

  -- Process characters to be replaced  by underscores.
  l_dbi_name :=
  translate(l_dbi_name, l_underscore, lpad('_', length(l_underscore), '_'));

  -- Process characters to be removed.
  l_dbi_name :=
  translate(l_dbi_name, l_remove, lpad('"', length(l_remove), '"'));
  l_dbi_name := replace(l_dbi_name, '"', '');

  -- Uppercase.
  l_dbi_name := upper(l_dbi_name);

  -- Shorten to maximum allowable length.
  l_dbi_name := substr(l_dbi_name, 1, C_DBI_NAME_LEN);
  --
  if l_debug then
    if length(l_dbi_name) < length(p_str) then
      hr_utility.trace('DBI name: ' || p_str || ' shortened to ' || l_dbi_name);
    end if;
  end if;

  -- Get rid of leading and trailing spaces.
  l_dbi_name := ltrim(rtrim(l_dbi_name));

  -- CHECKFORMAT
  begin
    hr_chkfmt.checkformat
    (value   => l_dbi_name
    ,format  => 'DB_ITEM_NAME'
    ,output  => l_dbi_name
    ,minimum => null
    ,maximum => null
    ,nullok  => 'N'
    ,rgeflg  => l_rgeflg
    ,curcode => null
    );
  exception
    when others then
      --
      -- Not in the standard name format so convert to quoted format.
      --
      l_dbi_name :=
      '"' || rtrim(ltrim(substr(l_dbi_name, 1, C_DBI_NAME_LEN - 2))) || '"';

      if l_debug then
        hr_utility.trace('Necessary to quote name ' || l_dbi_name);
      end if;
  end;

  return l_dbi_name;
end str2dbiname;

--------------------------- get_supported_trans --------------------------
-- NAME
--   get_supported_trans
--
-- DESCRIPTION
--   One-off call to get the legislations supported translations from
--   PAY_LEGISLATION_RULES.
--
procedure get_supported_trans is
cursor csr_get_leg_rules(p_rule_mode in varchar2) is
select plr.legislation_code
from   pay_legislation_rules plr
where  plr.rule_type = C_TRANS_LEG_RULE
and    plr.rule_mode = p_rule_mode
;
begin
  --
  -- Fetch legislations where translations are supported.
  --
  open csr_get_leg_rules(p_rule_mode => 'Y');
  fetch csr_get_leg_rules bulk collect
  into  g_trans_supported
  ;
  close csr_get_leg_rules;
end get_supported_trans;

------------------------- translations_supported -------------------------
function translations_supported
(p_legislation_code in varchar2
) return boolean is
begin
  --
  -- Get the legislations that support translations.
  --
  if not g_got_supported then
    get_supported_trans;
  end if;

  --
  -- Look in cache to see if the legislation supports translations.
  --
  for i in 1 .. g_trans_supported.count loop
    if p_legislation_code = g_trans_supported(i) then
      return true;
    end if;
  end loop;

  --
  -- Translations are not supported.
  --
  return false;
end translations_supported;

------------------------- translations_supported -------------------------
function translation_supported
(p_legislation_code in varchar2
) return varchar2 is
begin
  --
  -- Get the legislations that support translations.
  --
  if not g_got_supported then
    get_supported_trans;
  end if;

  --
  -- Look in cache to see if the legislation supports translations.
  --
  for i in 1 .. g_trans_supported.count loop
    if p_legislation_code = g_trans_supported(i) then
      return 'Y';
    end if;
  end loop;

  --
  -- Translations are not supported.
  --
  return 'N';
end translation_supported;


end ff_dbi_utils_pkg;

/
