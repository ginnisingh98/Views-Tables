--------------------------------------------------------
--  DDL for Package Body FND_CONC_TEMPLATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_TEMPLATES" as
/* $Header: AFCPTPLB.pls 120.5.12010000.9 2012/12/04 15:28:20 ckclark ship $ */
--
-- Package
--   FND_CONC_TEMPLATES
--
-- Purpose
--   Concurrent processing utilities for Templates and OPP
--

  --
  -- PRIVATE VARIABLES
  --
  -- 7017250 - This variable is used to determine if the new xdo columns exits.
  xdo_columns_cntr             number := null;

  default_templ_shrt_name      fnd_application.application_short_name%TYPE;
  default_templ_code           xdo_templates_b.template_code%TYPE;
  default_templ_shrt_name_opt  fnd_application.application_short_name%TYPE;
  default_templ_code_opt       xdo_templates_b.template_code%TYPE;
  l_special_template_case      varchar2(2);

  --
  -- Exception info.

  --
  -- PRIVATE FUNCTIONS
  --
  --

  -- PUBLIC FUNCTIONS
  --

  -- NAME
  --    get_template_information
  -- Purpose
  --    Called to determine the template information needed for OPP processing
  --

procedure get_template_information(
              prog_app_id       IN number,
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              nls_lang          IN varchar2,
              nls_terr          IN varchar2,
              s_nls_lang        IN varchar2,
              s_nls_terr        IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2 ) is

def_iso_territory         varchar2(2);
wo_xdo_iso_language       varchar2(2);
wo_xdo_iso_territory      varchar2(2);
terr_indep                varchar2(1);
def_output_type           varchar2(10);
l_po_output_type          varchar2(10);

begin

   -- Get the profile option for default output type override.
   l_po_output_type := NULL;
   FND_PROFILE.GET( 'FND_DEF_TEMPL_OUTPUT_TYPE', l_po_output_type );

   get_iso_lang_and_terr(nls_lang, nls_terr,
                         wo_xdo_iso_language, wo_xdo_iso_territory);

   -- Obtain a default template if set for a conc program definition
   begin
     select template_appl_short_name, template_code
       into default_templ_shrt_name, default_templ_code
       from fnd_concurrent_programs
      where application_id = prog_app_id
        and concurrent_program_name = conc_prog_name;
     exception
       when NO_DATA_FOUND then
          default_templ_code := NULL;
          default_templ_shrt_name := NULL;
   end;

   template_obtained := 'N';

   -- 1st Default template, Request Language
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   -- 2nd Default template, Request language with territory independence
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'Y',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   -- 2-A Default template, Request language with default territory
   get_def_iso_terr(nls_lang, def_iso_territory);
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   l_special_template_case := '2B';
   -- 2-B Default template, Request language with first row for templates
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   -- 5th Default template, Session language/terr
   get_iso_lang_and_terr(s_nls_lang, s_nls_terr,
                         wo_xdo_iso_language, wo_xdo_iso_territory);
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              s_nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      request_language := nls_lang;
      GOTO check_template_output_type;
   end if;


   -- 6th Default template, Session language with territory independence
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              s_nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'Y',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      request_language := nls_lang;
      GOTO check_template_output_type;
   end if;


   l_special_template_case := '7';
   -- 7th Grab any default temp default language and territory
   if (def_template_check(
              default_templ_shrt_name, conc_prog_name, default_templ_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   get_iso_lang_and_terr(nls_lang, nls_terr,
                         wo_xdo_iso_language, wo_xdo_iso_territory);
   -- 3rd No Def Template, Request language
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   -- 4th No Def Template, Request language and territory independent
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'Y',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   get_def_iso_terr(nls_lang, def_iso_territory);
   -- 4-A Request language with default territory
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   l_special_template_case := '4B';
   -- 4-B Request language with first row for templates
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   get_iso_lang_and_terr(s_nls_lang, s_nls_terr,
                  wo_xdo_iso_language, wo_xdo_iso_territory );
   -- 8th No Default Template, session language with territory
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              s_nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      request_language := nls_lang;
      GOTO check_template_output_type;
   end if;


   -- 9th No Default template, session language with territory independence
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              s_nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'Y',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      request_language := nls_lang;
      GOTO check_template_output_type;
   end if;


   l_special_template_case := '10';
   -- 10th Final chk No Def Template, get template from xdo_templates_b
   if (no_def_template_check(
              prog_app_name, conc_prog_name,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;

   << check_template_output_type >>

   if ( template_obtained = 'Y' ) then
      -- check if new column for default output type is present
      if ( xdo_columns_cntr = 2 ) then
         -- Default output type on template definition has priority
         if ( def_output_type is NULL) then
            -- Check if profile option is set and use instead
            if (l_po_output_type is NULL) then
               -- Set the format to the value set by fnd_lookup_values_vl table
               find_the_format(format_type, format);
            else
               format := l_po_output_type;
            end if;
         else
            format := def_output_type;
         end if;
      else
         -- Check if profile option is set and use instead
         if (l_po_output_type is NULL) then
            -- Set the format to the value set by fnd_lookup_values_vl table
            find_the_format(format_type, format);
         else
            format := l_po_output_type;
         end if;
      end if;
   end if;

end get_template_information;


-- NAME
--    fill_no_def_template
-- Purpose
--    Called if default template is NOT set for defined program
--    in fnd_concurrent_program
--

procedure fill_no_def_template(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              nls_lang          IN varchar2,
              iso_lang          IN varchar2,
              iso_terr          IN varchar2,
              terr_indep        IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2,
              def_output_type   IN OUT NOCOPY varchar2 ) is

begin
   if (terr_indep = 'N') then
      if ( xdo_columns_cntr = 2 ) then
         EXECUTE IMMEDIATE
            'select a.template_name, I.NAME||'': ''||T.territory_short_name, '||
            '       b.nls_language, x.language, x.territory, '||
            '       a.application_short_name, a.template_code, '||
            '       a.template_type_code, a.default_output_type '||
            '  from xdo_lobs x, xdo_templates_vl a, fnd_languages b, '||
            '       fnd_iso_languages_vl I, fnd_territories_vl T '||
            ' where a.ds_app_short_name = :prog_app_name '||
            '   and a.data_source_code = :conc_prog_name '||
            '   and a.template_code = x.lob_code '||
            '   and lower(x.language) = lower(:iso_lang) '||
            '   and lower(x.territory) = lower(:iso_terr) '||
            '   and b.nls_language = :nls_lang '||
            '   and lower(b.iso_language) = I.iso_language_2 '||
            '   and upper(x.territory) = T.territory_code '||
            '   and file_status = ''E'' '||
            '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
            '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
            '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
            '   and rownum = 1 '
         INTO template_name, template_language, request_language,
              iso_language, iso_territory, template_app_name,
              template_code, format_type, def_output_type
         USING prog_app_name, conc_prog_name, iso_lang, iso_terr, nls_lang;
      else
         select a.template_name, I.NAME||': '||T.territory_short_name,
                b.nls_language, x.language, x.territory,
                a.application_short_name, a.template_code,
                a.template_type_code
           into template_name, template_language, request_language,
                iso_language, iso_territory, template_app_name,
                template_code, format_type
           from xdo_lobs x, xdo_templates_vl a, fnd_languages b,
                fnd_iso_languages_vl I, fnd_territories_vl T
          where a.ds_app_short_name = prog_app_name
            and a.data_source_code = conc_prog_name
            and a.template_code = x.lob_code
            and lower(x.language) = lower(iso_lang)
            and lower(x.territory) = lower(iso_terr)
            and b.nls_language = nls_lang
            and lower(b.iso_language) = I.iso_language_2
            and upper(x.territory) = T.territory_code
            and file_status = 'E'
            and lob_type in ('TEMPLATE','MLS_TEMPLATE')
            and (a.dependency_flag is NULL or a.dependency_flag = 'P')
            and sysdate between a.start_date and nvl(a.end_date,sysdate)
            and rownum = 1;
      end if;
   else
      if ( xdo_columns_cntr = 2 ) then
         EXECUTE IMMEDIATE
            'select a.template_name, I.NAME, '||
            '       b.nls_language, x.language, x.territory, '||
            '       a.application_short_name, a.template_code, '||
            '       a.template_type_code, a.default_output_type '||
            '  from xdo_lobs x, xdo_templates_vl a, fnd_languages b, '||
            '       fnd_iso_languages_vl I '||
            ' where a.ds_app_short_name = :prog_app_name '||
            '   and a.data_source_code = :conc_prog_name '||
            '   and a.template_code = x.lob_code '||
            '   and lower(x.language) = lower(:iso_lang) '||
            '   and lower(x.territory) = ''00'' '||
            '   and b.nls_language = :nls_lang '||
            '   and lower(b.iso_language) = I.iso_language_2 '||
            '   and file_status = ''E'' '||
            '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
            '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
            '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
            '   and rownum = 1 '
         INTO template_name, template_language, request_language,
              iso_language, iso_territory, template_app_name,
              template_code, format_type, def_output_type
         USING prog_app_name, conc_prog_name, iso_lang, nls_lang;
      else
         select a.template_name, I.NAME,
                b.nls_language, x.language, x.territory,
                a.application_short_name, a.template_code,
                a.template_type_code
           into template_name, template_language, request_language,
                iso_language, iso_territory, template_app_name,
                template_code, format_type
           from xdo_lobs x, xdo_templates_vl a, fnd_languages b,
                fnd_iso_languages_vl I
          where a.ds_app_short_name = prog_app_name
            and a.data_source_code = conc_prog_name
            and a.template_code = x.lob_code
            and lower(x.language) = lower(iso_lang)
            and lower(x.territory) = '00'
            and b.nls_language = nls_lang
            and lower(b.iso_language) = I.iso_language_2
            and file_status = 'E'
            and lob_type in ('TEMPLATE','MLS_TEMPLATE')
            and (a.dependency_flag is NULL or a.dependency_flag = 'P')
            and sysdate between a.start_date and nvl(a.end_date,sysdate)
            and rownum = 1;
      end if;
   end if;

   if ( sql%rowcount > 0 ) then
      template_obtained := 'Y';
   else
      template_obtained := 'N';
   end if;

   exception
      when others then
          NULL;
end fill_no_def_template;


-- NAME
--    fill_default_template
-- Purpose
--    Called if default template is set for defined program
--    in fnd_concurrent_program
--

procedure fill_default_template(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              def_templ_code    IN varchar2,
              nls_lang          IN varchar2,
              iso_lang          IN varchar2,
              iso_terr          IN varchar2,
              terr_indep        IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2,
              def_output_type   IN OUT NOCOPY varchar2 ) is

begin
   if (terr_indep = 'N') then
      if ( xdo_columns_cntr = 2 ) then
         EXECUTE IMMEDIATE
            'select a.template_name, I.NAME||'': ''||T.territory_short_name, '||
            '       b.nls_language, x.language, x.territory, '||
            '       a.application_short_name, a.template_code, '||
            '       a.template_type_code, a.default_output_type '||
            '  from xdo_lobs x, xdo_templates_vl a, fnd_languages b, '||
            '       fnd_iso_languages_vl I, fnd_territories_vl T '||
            ' where a.ds_app_short_name = :prog_app_name '||
            '   and a.data_source_code = :conc_prog_name '||
            '   and a.template_code = :def_templ_code '||
            '   and a.template_code = x.lob_code '||
            '   and lower(x.language) = lower(:iso_lang) '||
            '   and lower(x.territory) = lower(:iso_terr) '||
            '   and b.nls_language = :nls_lang '||
            '   and lower(b.iso_language) = I.iso_language_2 '||
            '   and upper(x.territory) = T.territory_code '||
            '   and file_status = ''E'' '||
            '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
            '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
            '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
            '   and rownum = 1 '
            INTO template_name, template_language, request_language,
                 iso_language, iso_territory, template_app_name, template_code,
                 format_type, def_output_type
           USING prog_app_name, conc_prog_name, def_templ_code, iso_lang,
                 iso_terr, nls_lang;
      else
         select a.template_name, I.NAME||': '||T.territory_short_name,
                b.nls_language, x.language, x.territory,
                a.application_short_name, a.template_code, a.template_type_code
           into template_name, template_language, request_language,
                iso_language, iso_territory, template_app_name, template_code,
                format_type
           from xdo_lobs x, xdo_templates_vl a, fnd_languages b,
                fnd_iso_languages_vl I, fnd_territories_vl T
          where a.ds_app_short_name = prog_app_name
            and a.data_source_code = conc_prog_name
            and a.template_code = def_templ_code
            and a.template_code = x.lob_code
            and lower(x.language) = lower(iso_lang)
            and lower(x.territory) = lower(iso_terr)
            and b.nls_language = nls_lang
            and lower(b.iso_language) = I.iso_language_2
            and upper(x.territory) = T.territory_code
            and file_status = 'E'
            and lob_type in ('TEMPLATE','MLS_TEMPLATE')
            and (a.dependency_flag is NULL or a.dependency_flag = 'P')
            and sysdate between a.start_date and nvl(a.end_date,sysdate)
            and rownum = 1;
      end if;
   else
      if ( xdo_columns_cntr = 2 ) then
         EXECUTE IMMEDIATE
            'select a.template_name, I.NAME, '||
            '       b.nls_language, x.language, x.territory, '||
            '       a.application_short_name, a.template_code, '||
            '       a.template_type_code, a.default_output_type '||
            '  from xdo_lobs x, xdo_templates_vl a, fnd_languages b, '||
            '       fnd_iso_languages_vl I '||
            ' where a.ds_app_short_name = :prog_app_name '||
            '   and a.data_source_code = :conc_prog_name '||
            '   and a.template_code = :def_templ_code '||
            '   and a.template_code = x.lob_code '||
            '   and lower(x.language) = lower(:iso_lang) '||
            '   and lower(x.territory) = ''00'' '||
            '   and b.nls_language = :nls_lang '||
            '   and lower(b.iso_language) = I.iso_language_2 '||
            '   and file_status = ''E'' '||
            '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
            '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
            '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
            '   and rownum = 1 '
         INTO template_name, template_language, request_language,
              iso_language, iso_territory, template_app_name, template_code,
              format_type, def_output_type
         USING prog_app_name, conc_prog_name, def_templ_code, iso_lang,
               nls_lang;

      else
         select a.template_name, I.NAME,
                b.nls_language, x.language, x.territory,
                a.application_short_name, a.template_code, a.template_type_code
           into template_name, template_language, request_language,
                iso_language, iso_territory, template_app_name, template_code,
                format_type
           from xdo_lobs x, xdo_templates_vl a, fnd_languages b,
                fnd_iso_languages_vl I
          where a.ds_app_short_name = prog_app_name
            and a.data_source_code = conc_prog_name
            and a.template_code = def_templ_code
            and a.template_code = x.lob_code
            and lower(x.language) = lower(iso_lang)
            and lower(x.territory) = '00'
            and b.nls_language = nls_lang
            and lower(b.iso_language) = I.iso_language_2
            and file_status = 'E'
            and lob_type in ('TEMPLATE','MLS_TEMPLATE')
            and (a.dependency_flag is NULL or a.dependency_flag = 'P')
            and sysdate between a.start_date and nvl(a.end_date,sysdate)
            and rownum = 1;
      end if;
   end if;
   if ( sql%rowcount > 0 ) then
      template_obtained := 'Y';
   else
      template_obtained := 'N';
   end if;

   exception
      when others then
          NULL;
end fill_default_template;


-- NAME
--    fill_spec_def_template
-- Purpose
--    Called if special query is requried to obtain template info
--

procedure fill_special_def_template(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              def_templ_code    IN varchar2,
              nls_lang          IN varchar2,
              iso_lang          IN varchar2,
              iso_terr          IN varchar2,
              terr_indep        IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2,
              def_output_type   IN OUT NOCOPY varchar2 ) is

begin
   if (l_special_template_case = '2B') then
      if ( xdo_columns_cntr = 2 ) then
         EXECUTE IMMEDIATE
            'select a.template_name, I.NAME, '||
            '       b.nls_language, x.language, x.territory, '||
            '       a.application_short_name, a.template_code, '||
            '       a.template_type_code, a.default_output_type '||
            '  from xdo_lobs x, xdo_templates_vl a, fnd_languages b, '||
            '       fnd_iso_languages_vl I '||
            ' where a.ds_app_short_name = :default_templ_shrt_name '||
            '   and a.data_source_code = :conc_prog_name '||
            '   and a.template_code = :def_templ_code '||
            '   and a.template_code = x.lob_code '||
            '   and lower(x.language) = lower(:iso_lang) '||
            '   and b.nls_language = :nls_lang '||
            '   and lower(b.iso_language) = I.iso_language_2 '||
            '   and file_status = ''E'' '||
            '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
            '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
            '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
            '   and rownum = 1 '
            INTO template_name, template_language, request_language,
                 iso_language, iso_territory, template_app_name, template_code,
                 format_type, def_output_type
           USING default_templ_shrt_name, conc_prog_name, def_templ_code, iso_lang,
                 nls_lang;
      else
         select a.template_name, I.NAME,
                b.nls_language, x.language, x.territory,
                a.application_short_name, a.template_code, a.template_type_code
           into template_name, template_language, request_language,
                iso_language, iso_territory, template_app_name, template_code,
                format_type
           from xdo_lobs x, xdo_templates_vl a, fnd_languages b,
                fnd_iso_languages_vl I
          where a.ds_app_short_name = default_templ_shrt_name
            and a.data_source_code = conc_prog_name
            and a.template_code = def_templ_code
            and a.template_code = x.lob_code
            and lower(x.language) = lower(iso_lang)
            and b.nls_language = nls_lang
            and lower(b.iso_language) = I.iso_language_2
            and file_status = 'E'
            and lob_type in ('TEMPLATE','MLS_TEMPLATE')
            and (a.dependency_flag is NULL or a.dependency_flag = 'P')
            and sysdate between a.start_date and nvl(a.end_date,sysdate)
            and rownum = 1;
      end if;

   elsif (l_special_template_case = '4B') then
        if ( xdo_columns_cntr = 2 ) then
           EXECUTE IMMEDIATE
              'select a.template_name, I.NAME, '||
              '       b.nls_language, x.language, x.territory, '||
              '       a.application_short_name, a.template_code, '||
              '       a.template_type_code, a.default_output_type '||
              '  from xdo_lobs x, xdo_templates_vl a, fnd_languages b, '||
              '       fnd_iso_languages_vl I '||
              ' where a.ds_app_short_name = :prog_app_name '||
              '   and a.data_source_code = :conc_prog_name '||
              '   and a.template_code = x.lob_code '||
              '   and lower(x.language) = lower(:iso_lang) '||
              '   and b.nls_language = :nls_lang '||
              '   and lower(b.iso_language) = I.iso_language_2 '||
              '   and file_status = ''E'' '||
              '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
              '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
              '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
              '   and rownum = 1 '
           INTO template_name, template_language, request_language,
                iso_language, iso_territory, template_app_name,
                template_code, format_type, def_output_type
           USING prog_app_name, conc_prog_name, iso_lang,
                 nls_lang;
        else
           select a.template_name, I.NAME,
                  b.nls_language, x.language, x.territory,
                  a.application_short_name, a.template_code,
                  a.template_type_code
             into template_name, template_language, request_language,
                  iso_language, iso_territory, template_app_name,
                  template_code, format_type
             from xdo_lobs x, xdo_templates_vl a, fnd_languages b,
                  fnd_iso_languages_vl I
            where a.ds_app_short_name = prog_app_name
              and a.data_source_code = conc_prog_name
              and a.template_code = x.lob_code
              and lower(x.language) = lower(iso_lang)
              and b.nls_language = nls_lang
              and lower(b.iso_language) = I.iso_language_2
              and file_status = 'E'
              and lob_type in ('TEMPLATE','MLS_TEMPLATE')
              and (a.dependency_flag is NULL or a.dependency_flag = 'P')
              and sysdate between a.start_date and nvl(a.end_date,sysdate)
              and rownum = 1;
        end if;
   elsif (l_special_template_case = '7') then
           if ( xdo_columns_cntr = 2 ) then
              EXECUTE IMMEDIATE
                 'select a.template_name, a.default_language, '||
                 '       a.default_territory, a.application_short_name, '||
                 '       a.template_code, a.template_type_code, '||
                 '       a.default_output_type '||
                 '  from xdo_lobs x, xdo_templates_vl a '||
                 ' where a.ds_app_short_name = :default_templ_shrt_name '||
                 '   and a.data_source_code = :conc_prog_name '||
                 '   and a.template_code = :def_templ_code  '||
                 '   and a.template_code = x.lob_code '||
                 '   and file_status = ''E''  '||
                 '   and lob_type in (''TEMPLATE'',''MLS_TEMPLATE'') '||
                 '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
                 '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
                 '   and rownum = 1 '
              INTO template_name, iso_language, iso_territory,
                   template_app_name, template_code, format_type,
                   def_output_type
              USING default_templ_shrt_name, conc_prog_name, def_templ_code;
           else
              select a.template_name, a.default_language, a.default_territory,
                     a.application_short_name, a.template_code,
                     a.template_type_code
                into template_name, iso_language, iso_territory,
                     template_app_name, template_code, format_type
                from xdo_lobs x, xdo_templates_vl a
               where a.ds_app_short_name = default_templ_shrt_name
                 and a.data_source_code = conc_prog_name
                 and a.template_code = def_templ_code
                 and a.template_code = x.lob_code
                 and file_status = 'E'
                 and lob_type in ('TEMPLATE','MLS_TEMPLATE')
                 and (a.dependency_flag is NULL or a.dependency_flag = 'P')
                 and sysdate between a.start_date and nvl(a.end_date,sysdate)
                 and rownum = 1;
            end if;

   elsif (l_special_template_case = '10') then
         if (def_templ_code is NULL) then

            --  Run for no default template
            if ( xdo_columns_cntr = 2 ) then
               EXECUTE IMMEDIATE
                  'select x.template_name, a.default_language, '||
                  '       a.default_territory, a.application_short_name, '||
                  '       a.template_code, a.template_type_code, '||
                  '       a.default_output_type '||
                  '  from xdo_templates_b a, xdo_templates_vl x '||
                  ' where a.ds_app_short_name = :prog_app_name '||
                  '   and a.data_source_code = :conc_prog_name '||
                  '   and a.template_code = x.template_code '||
                  '   and a.template_status = ''E'' '||
                  '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
                  '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
                  '   and rownum = 1 '
               INTO template_name, iso_language, iso_territory, template_app_name,
                    template_code, format_type, def_output_type
               USING prog_app_name, conc_prog_name;
            else
               select x.template_name, a.default_language, a.default_territory,
                      a.application_short_name, a.template_code,
                      a.template_type_code
                 into template_name, iso_language, iso_territory,
                      template_app_name, template_code, format_type
                 from xdo_templates_b a, xdo_templates_vl x
                where a.ds_app_short_name = prog_app_name
                  and a.data_source_code = conc_prog_name
                  and a.template_code = x.template_code
                  and a.template_status = 'E'
                  and (a.dependency_flag is NULL or a.dependency_flag = 'P')
                  and sysdate between a.start_date and nvl(a.end_date,sysdate)
                  and rownum = 1;
            end if;
         else

            if ( xdo_columns_cntr = 2 ) then
               EXECUTE IMMEDIATE
                  'select x.template_name, a.default_language, '||
                  '       a.default_territory, a.application_short_name, '||
                  '       a.template_code, a.template_type_code, '||
                  '       a.default_output_type '||
                  '  from xdo_templates_b a, xdo_templates_vl x '||
                  ' where a.ds_app_short_name = :prog_app_name '||
                  '   and a.data_source_code = :conc_prog_name '||
                  '   and a.template_code = :def_templ_code '||
                  '   and a.template_code = x.template_code '||
                  '   and a.template_status = ''E'' '||
                  '   and (a.dependency_flag is NULL or a.dependency_flag = ''P'') '||
                  '   and sysdate between a.start_date and nvl(a.end_date,sysdate) '||
                  '   and rownum = 1 '
               INTO template_name, iso_language, iso_territory, template_app_name,
                    template_code, format_type, def_output_type
               USING prog_app_name, conc_prog_name, def_templ_code;
            else
               select x.template_name, a.default_language, a.default_territory,
                      a.application_short_name, a.template_code,
                      a.template_type_code
                 into template_name, iso_language, iso_territory,
                      template_app_name, template_code, format_type
                 from xdo_templates_b a, xdo_templates_vl x
                where a.ds_app_short_name = prog_app_name
                  and a.data_source_code = conc_prog_name
                  and a.template_code = def_templ_code
                  and a.template_code = x.template_code
                  and a.template_status = 'E'
                  and (a.dependency_flag is NULL or a.dependency_flag = 'P')
                  and sysdate between a.start_date and nvl(a.end_date,sysdate)
                  and rownum = 1;
            end if;
         end if;
   end if;

   if ( sql%rowcount > 0 ) then

      if ( iso_territory = '00' ) then
         begin
            select I.name
              into template_language
              from fnd_iso_languages_vl I
             where I.iso_language_2 = lower(iso_language);
            exception
              when NO_DATA_FOUND then
                  NULL;
         end;
      else
         begin
            select I.name||': '||T.territory_short_name
              into template_language
              from fnd_iso_languages_vl I, fnd_territories_vl T
             where I.iso_language_2 = lower(iso_language)
               and T.territory_code = upper(iso_territory);
             exception
               when NO_DATA_FOUND then
                   NULL;
         end;
      end if;
      request_language := nls_lang;
      template_obtained := 'Y';
   else
      template_obtained := 'N';
   end if;

   exception
      when others then
          NULL;
end fill_special_def_template;


-- NAME
--    find_the_format
-- Purpose
--    Called to obtain the correct lookup value for the associated tag.
--

procedure find_the_format(
              format_type IN varchar2,
              format      IN OUT NOCOPY varchar2 ) is

begin

      begin
         select flv2.lookup_code
           into format
           from fnd_lookup_values_vl flv1, fnd_lookup_values_vl flv2
          where flv1.lookup_type = 'XDO_TEMPLATE_TYPE'
            and flv1.lookup_code = format_type
            and flv2.lookup_type = flv1.tag;
        exception
          when NO_DATA_FOUND then
               format := 'PDF';
          when TOO_MANY_ROWS then
               format := format_type;
      end;

end;


-- NAME
--    get_iso_lang_and_terr
-- Purpose
--    Called to obtain the iso codes for a specific language and territory
--

procedure get_iso_lang_and_terr(
                        nls_lang IN varchar2,
                        nls_terr IN varchar2,
                        iso_lang IN OUT NOCOPY varchar2,
                        iso_terr IN OUT NOCOPY varchar2 ) is

begin
   begin
      SELECT lower(L1.iso_language), upper(L2.territory_code)
        INTO iso_lang, iso_terr
        FROM FND_LANGUAGES L1, FND_TERRITORIES_VL L2
       WHERE L1.NLS_LANGUAGE = nls_lang
         AND L2.NLS_TERRITORY = nls_terr
         AND ROWNUM = 1;
      exception
        when NO_DATA_FOUND then
                NULL;
   end;
end get_iso_lang_and_terr;


-- NAME
--    get_def_iso_terr
-- Purpose
--    Called to obtain the default iso territory code for the specific lang
--

procedure get_def_iso_terr(
                    nls_lang     IN varchar2,
                    def_iso_terr IN OUT NOCOPY varchar2 ) is

begin
   begin
      SELECT upper(L2.territory_code)
        INTO def_iso_terr
        FROM FND_LANGUAGES L1, FND_TERRITORIES_VL L2
       WHERE L1.NLS_LANGUAGE = nls_lang
         AND L1.NLS_TERRITORY = L2.NLS_TERRITORY
         AND ROWNUM = 1;
      exception
        when NO_DATA_FOUND then
            NULL;
   end;
end get_def_iso_terr;


/* 7017250 */
-- NAME
--    get_template_info_options
-- Purpose
--    Called to obtain the info for templates when called from the Options
--    window and a new template has to be validated and setup in the
--    templates row
--
procedure get_template_info_options(
              prog_app_id       IN number,
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              nls_lang          IN varchar2,
              nls_terr          IN varchar2,
              s_nls_lang        IN varchar2,
              s_nls_terr        IN varchar2,
              new_template_name IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2 ) is

def_iso_territory         varchar2(2);
wo_xdo_iso_language       varchar2(2);
wo_xdo_iso_territory      varchar2(2);
terr_indep                varchar2(1);
def_output_type           varchar2(10);
l_po_output_type          varchar2(10);
new_t_app_name            varchar2(50);
new_template_code         varchar2(80);

begin

   -- Get the profile option for default output type override.
   l_po_output_type := NULL;
   FND_PROFILE.GET( 'FND_DEF_TEMPL_OUTPUT_TYPE', l_po_output_type );

   get_iso_lang_and_terr( nls_lang, nls_terr,
                          wo_xdo_iso_language, wo_xdo_iso_territory );

   begin
     SELECT application_short_name, template_code
       into new_t_app_name, new_template_code
       from xdo_templates_vl T
     where ds_app_short_name = prog_app_name
       and data_source_code = conc_prog_name
       and template_name = new_template_name;
     exception
       when no_data_found then
                  NULL;
   end;

   default_templ_shrt_name_opt := new_t_app_name;
   default_templ_code_opt      := new_template_code;
   template_obtained := 'N';
   -- 1st new template, Request Language
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   -- 2nd new template, request language with territory independence
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'Y',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;



   -- 2-A Request language with default territory
   get_def_iso_terr(nls_lang, def_iso_territory);
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;


   l_special_template_case := '2B';
   -- 2-B Request language,default template, with first row for templates
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;



   -- 5th new template, session language/terr; then no terr
   get_iso_lang_and_terr( s_nls_lang, s_nls_terr,
                          wo_xdo_iso_language, wo_xdo_iso_territory );

   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              s_nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      request_language := nls_lang;
      GOTO check_template_output_type;
    end if;



   -- 6th new template, session language with territory independence
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              s_nls_lang, wo_xdo_iso_language, wo_xdo_iso_territory,
              'Y',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      request_language := nls_lang;
      GOTO check_template_output_type;
    end if;



   l_special_template_case := '7';
   -- 7th Grab any default temp default language and territory
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;



   l_special_template_case := '10';
   -- 10th Final chk No new Template, get template from xdo_templates_b
   if (def_template_check(
              prog_app_name, conc_prog_name, new_template_code,
              nls_lang, wo_xdo_iso_language, def_iso_territory,
              'N',
              template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type ) ) then
      GOTO check_template_output_type;
   end if;

   << check_template_output_type >>

   if ( template_obtained = 'Y' ) then

      -- check if new column for default output type is present
      if ( xdo_columns_cntr = 2 ) then
         -- Default output type on template definition has priority
         if ( def_output_type is NULL ) then
            -- Check if profile option is set and use instead
            if (l_po_output_type is NULL) then
               -- Set the format to the value set by fnd_lookup_values_vl table
               find_the_format(format_type, format);
            else
               format := l_po_output_type;
            end if;
         else
            format := def_output_type;
         end if;
      else
         -- Check if profile option is set and use instead
         if (l_po_output_type is NULL) then
            -- Set the format to the value set by fnd_lookup_values_vl table
            find_the_format(format_type, format);
         else
            format := l_po_output_type;
         end if;
      end if;
   end if;

   default_templ_shrt_name_opt := NULL;
   default_templ_code_opt      := NULL;

end get_template_info_options;


-- NAME
--    def_template_check
-- Purpose
--    Setup to call proc data, return true if template is obtained
--

function def_template_check
(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              def_templ_code    IN varchar2,
              nls_lang          IN varchar2,
              iso_lang          IN varchar2,
              iso_terr          IN varchar2,
              terr_indep        IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2,
              def_output_type   IN OUT NOCOPY varchar2 )
return boolean is

begin

   -- The default is checked to not allow the queries to run if these are null
   if ( (default_templ_code is not null and
        default_templ_shrt_name is not null) or
        (default_templ_code_opt is not null and
        default_templ_shrt_name_opt is not null) ) then

      -- The special cases are queries that have where clauses that require
      -- a slight difference than the standard clauses used in the else.
      if (l_special_template_case in ('2B', '7', '10') ) then

         fill_special_def_template(
              prog_app_name, conc_prog_name, def_templ_code, nls_lang,
              iso_lang, iso_terr, terr_indep, template_obtained,
              template_name, template_language, format, request_language,
              iso_language, iso_territory, template_app_name, template_code,
              format_type, def_output_type );
      else
         fill_default_template(
              prog_app_name, conc_prog_name, def_templ_code, nls_lang,
              iso_lang, iso_terr, terr_indep, template_obtained,
              template_name, template_language, format, request_language,
              iso_language, iso_territory, template_app_name, template_code,
              format_type, def_output_type );
      end if;

      l_special_template_case := NULL;
      if (template_obtained = 'Y') then
         return(TRUE);
      else
         return(FALSE);
      end if;
   else
      return(FALSE);
   end if;

end def_template_check;


-- NAME
--    no_def_template_check
-- Purpose
--    Setup to call proc data, return true if template is obtained
--

function no_def_template_check

(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              nls_lang          IN varchar2,
              iso_lang          IN varchar2,
              iso_terr          IN varchar2,
              terr_indep        IN varchar2,
              template_obtained IN OUT NOCOPY varchar2,
              template_name     IN OUT NOCOPY varchar2,
              template_language IN OUT NOCOPY varchar2,
              format            IN OUT NOCOPY varchar2,
              request_language  IN OUT NOCOPY varchar2,
              iso_language      IN OUT NOCOPY varchar2,
              iso_territory     IN OUT NOCOPY varchar2,
              template_app_name IN OUT NOCOPY varchar2,
              template_code     IN OUT NOCOPY varchar2,
              format_type       IN OUT NOCOPY varchar2,
              def_output_type   IN OUT NOCOPY varchar2 )
return boolean is

begin

   -- The special cases are queries that have where clauses that require
   -- a slight difference than the standard clauses used in the else.
   if (l_special_template_case in ('4B') ) then

      fill_special_def_template(
              prog_app_name, conc_prog_name, NULL, nls_lang,
              iso_lang, iso_terr, terr_indep, template_obtained,
              template_name, template_language, format, request_language,
              iso_language, iso_territory, template_app_name, template_code,
              format_type, def_output_type );
   elsif (l_special_template_case in ('10') ) then
         if ( default_templ_code is not null) then
            fill_special_def_template(
              default_templ_shrt_name, conc_prog_name, default_templ_code, nls_lang,
              iso_lang, iso_terr, terr_indep, template_obtained,
              template_name, template_language, format, request_language,
              iso_language, iso_territory, template_app_name, template_code,
              format_type, def_output_type );
         else

            fill_special_def_template(
              prog_app_name, conc_prog_name, NULL, nls_lang,
              iso_lang, iso_terr, terr_indep, template_obtained,
              template_name, template_language, format, request_language,
              iso_language, iso_territory, template_app_name, template_code,
              format_type, def_output_type );
         end if;
   else
      fill_no_def_template(
              prog_app_name, conc_prog_name, nls_lang, iso_lang, iso_terr,
              terr_indep, template_obtained, template_name, template_language,
              format, request_language, iso_language, iso_territory,
              template_app_name, template_code,
              format_type, def_output_type );
   end if;

   l_special_template_case := NULL;
   if (template_obtained = 'Y') then
      return(TRUE);
   else
      return(FALSE);
   end if;

end no_def_template_check;




BEGIN

  -- Set it and Forget It!  -- Ronco
  -- Obtain the count if the default_output_type column
  -- exist in the xdo tables.
  -- Bug15935679 NZDT Logical Column Fix for 12.2 (backward compatible)
  select count(*) into xdo_columns_cntr
  from (
        select syn.table_name, col.column_name
        from user_synonyms syn, all_tab_columns col
        where syn.synonym_name in ('XDO_TEMPLATES_B', 'XDO_TEMPLATES_VL')
        and col.column_name = 'DEFAULT_OUTPUT_TYPE'
        and col.owner   =  syn.table_owner
        and col.table_name = syn.table_name
        UNION
        select col.table_name, col.column_name
        from  user_tab_columns col
        where col.table_name in ('XDO_TEMPLATES_B', 'XDO_TEMPLATES_VL')
        and col.column_name = 'DEFAULT_OUTPUT_TYPE'
       );


end FND_CONC_TEMPLATES;

/
