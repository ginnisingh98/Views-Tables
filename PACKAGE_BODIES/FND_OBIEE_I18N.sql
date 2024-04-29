--------------------------------------------------------
--  DDL for Package Body FND_OBIEE_I18N
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OBIEE_I18N" as
/* $Header: AFOBIEEB.pls 120.0.12010000.3 2011/02/10 09:52:39 nareshku noship $ */

-- Convert language codes between ORACLE, OBIEE, DLF. currently only provides the following conversion:
-- ORACLE->OBIEE
-- OBIEE->ORACLE
-- OBIEE->DLF
-- DLF->OBIEE
-- Note that all the conversion types specified have to be in upper cases.
-- Unrecognized conversion types will return null.
function obiee_convert_langcode (from_type varchar2, to_type varchar2, lang_code varchar2) return varchar2 is
  target_lang_code varchar2(10) := null;
  pos integer;
  lang_code_length integer;
  u_lang_code varchar2(20) := null;
  l_lang_code varchar2(20) := null;
  target_lang varchar2(10) := null;
  target_terr varchar2(10) := null;

begin

  -- Convert Oracle language code to OBIEE language code.
  -- Most commonly it would the corresponding ISO language code, except for
  -- languages with suffix in OBIEE: 'ptb'->'pt-br', 'zht'->'zh-tw'
  -- and Hebrew 'iw'->'iw'.
  -- Return 'en' if an exception is encountered
  if (from_type = 'ORACLE') and (to_type = 'OBIEE') then
    begin
      if lang_code is null then
        return 'en';
      else
        u_lang_code := upper(lang_code);
      end if;

      select decode(fl.language_code,
          'PTB', fl.ISO_LANGUAGE||'-'||fl.ISO_TERRITORY,
          'ZHT', fl.ISO_LANGUAGE||'-'||fl.ISO_TERRITORY,
          'IW','IW',
          fl.iso_language)
      into target_lang_code
      from fnd_languages fl
      where u_lang_code = fl.language_code;

      return lower(target_lang_code);
    exception
      when others then
        return 'en';
    end;

  -- Convert OBIEE language code to Oracle language code.
  -- Most commonly it would be the Oracle language code with the matching
  -- ISO language code, with the following exceptions:
  -- 1. Hebrew, 'iw'->'IW'
  -- 2. OBIEE language code with suffix, then it would be the Oracle language
  --    code with matching ISO language and default ISO territory
  -- 3. Multiple Oracle language codes have the same ISO language code, then
  --    the mapping is hard-coded.
  -- Unrecognized input code including null will return 'US'.
  elsif (from_type = 'OBIEE') and (to_type = 'ORACLE') then
    begin
      if lang_code is null then
        return 'US';
      else
        pos := instr(lang_code, '-');
        lang_code_length := length(lang_code);
        u_lang_code := upper(lang_code);
        l_lang_code := lower(lang_code);
      end if;

      if l_lang_code = 'iw' then
        return 'IW';
      end if;

      -- OBIEE language code has language suffix
      if pos > 0 then
        begin
          target_lang := substr(u_lang_code, 1, pos-1);
          target_terr := substr(u_lang_code, pos+1, lang_code_length-pos);

          if (target_lang is null) or (target_terr is null) then
            return 'US';
          end if;

          select fl.language_code
          into target_lang_code
          from fnd_languages fl
          where fl.iso_language = target_lang
            and fl.iso_territory = target_terr;

          return target_lang_code;
        exception
          when others then
            return 'US';
        end;
      else
        begin
          -- for OBIEE code that matches Oracle ISO lang code with a unique
          -- record in fnd_languages
          select fl.language_code
          into target_lang_code
          from fnd_languages fl
          where fl.iso_language = u_lang_code;

          return target_lang_code;
        exception
          -- there are multiple entries in fnd_languages with the matching ISO code
          -- for the following OBIEE language codes, hardcode the mapping since
          -- there is no systematic way of finding the mapping and the language codes
          -- are not expected to change.
          when too_many_rows then
            if l_lang_code = 'en' then
              return 'US';
            elsif l_lang_code = 'es' then
              return 'E';
            elsif l_lang_code = 'fr' then
              return 'F';
            elsif l_lang_code = 'pt' then
              return 'PT';
            elsif l_lang_code = 'zh' then
              return 'ZHS';
            else
              return 'US';
            end if;
          when others then
            return 'US';
        end;
      end if;
    exception
      when others then
        return 'US';
    end;

  -- OBIEE and .DLF file both use ISO language codes with the following exceptions:
  -- 1. Simplified Chinese 'zh'->'zh-CN'
  -- 2. Hebrew 'iw'->'he'
  -- 3. Language suffix is in lower case in OBIEE, while it is in upper case in .DLF file
  -- Other input language codes are returned as is (in lower case form).
  -- Unrecognized iput language codes are returned as is (in lower case form)
  -- as well, just like the general matching case, since there isn't a list of valid
  -- DLF language codes in the db for validation.
  elsif (from_type = 'OBIEE') and (to_type = 'DLF') then
    begin
      if lang_code is null then
        return 'en';
      else
        pos := instr(lang_code, '-');
        lang_code_length := length(lang_code);
        u_lang_code := upper(lang_code);
        l_lang_code := lower(lang_code);
      end if;

      if l_lang_code = 'zh' then
        return 'zh-CN';
      elsif l_lang_code = 'iw' then
        return 'he';
      -- for OBIEE language code with suffix, the territory part of the code is in lower case,
      -- but for DLF, the territory part of the code is in upper case.
      elsif pos > 0 then
        begin
          target_lang := substr(lang_code, 1, pos-1);
          target_terr := substr(lang_code, pos+1, lang_code_length-pos);

          if (target_lang is null) or (target_terr is null) then
            return 'en';
          else
            target_lang_code := lower(target_lang) || '-' || upper(target_terr);
            return target_lang_code;
          end if;
        exception
          -- input code is invalid, return 'en'.
          when others then
            return 'en';
        end;
      -- OBIEE and DLF codes are the same;
      -- or unrecognized code, return as is.
      else
        return l_lang_code;
      end if;
    exception
      when others then
        return 'en';
    end;

  -- .DLF file and OBIEE both use ISO language codes with the following exceptions:
  -- 1. Simplified Chinese 'zh-CN'->'zh'
  -- 2. Hebrew 'he'->'iw'
  -- 3. Language suffix is in lower case in OBIEE, while it is in upper case in .DLF file
  -- Other input language codes are returned as is (in lower case form).
  -- Unrecognized/invalid input language codes are returned as is (in lower case form)
  -- as well, just like the general matching case, since there isn't a list of valid
  -- OBIEE language codes in the db for validation.
  elsif (from_type = 'DLF') and (to_type = 'OBIEE') then
    begin
      if lang_code is null then
        return 'en';
      else
        pos := instr(lang_code, '-');
        lang_code_length := length(lang_code);
        u_lang_code := upper(lang_code);
        l_lang_code := lower(lang_code);
      end if;

      if l_lang_code = 'zh-cn' then
        return 'zh';
      elsif l_lang_code = 'he' then
        return 'iw';
      elsif pos > 0 then
        begin
          target_lang := substr(l_lang_code, 1, pos-1);
          target_terr := substr(l_lang_code, pos+1, lang_code_length-pos);

          if (target_lang is null) or (target_terr is null) then
            return 'en';
          else
            target_lang_code := target_lang || '-' || target_terr;
            return target_lang_code;
          end if;
        exception
          -- input code is invalid, return 'en'.
          when others then
            return 'en';
        end;
      -- DLF and OBIEE codes are the same;
      -- or input code is invalid, return as is.
      else
        return l_lang_code;
      end if;
    exception
      when others then
        return 'en';
    end;

  -- Invalid or unsupported conversion type
  else
    return null;
  end if;

  return target_lang_code;
end obiee_convert_langcode;

-- Convert between OBIEE language code and Oracle language (long form, e.g. 'AMERICAN').
-- Note that all the conversion types specified have to be in upper cases.
-- Invalid conversion types will return null;
-- Unrecognized language input will return 'en' or 'AMERICAN'.
function obiee_convert_language (from_type varchar2, to_type varchar2, lang varchar2) return varchar2 is
  target_language varchar2(30) := null;
  target_lang_code varchar2(10) := null;
begin

  if from_type = 'ORACLE' and to_type = 'OBIEE' then
    begin
      if lang is null then
        return 'en';
      end if;

      select fl.language_code
      into target_lang_code
      from fnd_languages fl
      where fl.nls_language = upper(lang);

      return obiee_convert_langcode('ORACLE', 'OBIEE', target_lang_code);
    exception
      when others then
        return 'en';
    end;
  elsif from_type = 'OBIEE' and to_type = 'ORACLE' then
    begin
      if lang is null then
        return 'AMERICAN';
      end if;

      target_lang_code := obiee_convert_langcode ('OBIEE', 'ORACLE', lang);

      select fl.nls_language
      into target_language
      from fnd_languages fl
      where fl.language_code = upper(target_lang_code);

      return target_language;
    exception
      when others then
        return 'AMERICAN';
    end;
  -- invalid/unsupported conversion type
  else
    return null;
  end if;
end obiee_convert_language;


-- Convert EBS session language to OBIEE session language code
function obiee_session_langcode return varchar2 is
begin
  return obiee_convert_langcode ('ORACLE', 'OBIEE',
fnd_global.current_language);
end obiee_session_langcode;


-- Convert EBS session language and session territory to OBIEE session locale
function obiee_session_locale return varchar2 is
  o_locale varchar2(10) := null;
begin
  select decode(lower(fl.language_code), 'iw','iw', lower(fl.ISO_LANGUAGE))
         ||'-'||lower(ft.TERRITORY_CODE)
  into o_locale
  from fnd_languages fl, FND_TERRITORIES ft
  where fnd_global.nls_language = fl.nls_language
    and fnd_global.nls_territory = ft.nls_territory;

  return o_locale;
exception
  when others then
    return 'en-us';
end obiee_session_locale;


-- Convert OBIEE language code to an installed Oracle language code;
-- i.e. if the matching Oracle language code is not installed, the Oracle
-- base language code will be returned
function oracle_installed_langcode (lang varchar2) return varchar2 is
  target_lang_code varchar2(10) := null;
  base_lang_code varchar2(10) := null;
  install_status varchar2(1) := 'D';
begin
  -- Get the base language code
  select language_code
  into base_lang_code
  from fnd_languages
  where installed_flag = 'B';

  if (lang is null) then
    return base_lang_code;
  else
    begin
      target_lang_code := obiee_convert_langcode ('OBIEE', 'ORACLE', lang);

      -- if target_lang_code was defaulted to 'US', return base language
      -- code instead of 'US'
      if (target_lang_code = 'US') and (lower(lang) <>  'en') then
        return base_lang_code;
      else
        begin
          select installed_flag
          into install_status
          from fnd_languages
          where language_code = target_lang_code;

          -- If the matching Oracle language is not installed, return
          -- the base language code.
          if (install_status = 'I') or (install_status = 'B') then
            return target_lang_code;
          else
            return base_lang_code;
          end if;
        exception
          when others then
            return base_lang_code;
        end;
      end if;
    exception
      when others then
        return base_lang_code;
    end;
  end if;

exception
  when others then
    return base_lang_code;
end oracle_installed_langcode;


-- Convert OBIEE language code to an installed Oracle language, i.e.
-- if the matching Oracle language is not installed, the Oracle
-- base language will be returned.
function oracle_installed_language (lang varchar2) return varchar2 is
  target_language varchar2(30) := null;
  target_lang_code varchar2(10) := null;
begin
  target_lang_code := oracle_installed_langcode (lang);

  select nls_language
  into target_language
  from fnd_languages
  where language_code = target_lang_code;

  return target_language;

exception
  when others then
    return null;
end oracle_installed_language;


end fnd_obiee_i18n;

/
