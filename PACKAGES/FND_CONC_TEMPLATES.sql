--------------------------------------------------------
--  DDL for Package FND_CONC_TEMPLATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONC_TEMPLATES" AUTHID CURRENT_USER as
/* $Header: AFCPTPLS.pls 120.3.12010000.5 2014/08/04 21:06:30 pferguso ship $ */
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
  -- Exceptions

  --
  -- PRIVATE FUNCTIONS
  --
  --

  --
  -- PUBLIC VARIABLES
  --

  -- Exceptions

  -- Exception Pragmas

  --
  -- PUBLIC FUNCTIONS
  --

  -- NAME
  --    get_template_information
  -- Purpose
  --    Called to retrieve the xml template details needed for OPP
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
              format_type       IN OUT NOCOPY varchar2 );

  -- NAME
  --    fill_no_def_template
  -- Purpose
  --    Called to obtain the info for templates which does not
  --    have default template set in fnd_concurrent_program table
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
              def_output_type   IN OUT NOCOPY varchar2 );


  -- NAME
  --    fill_default_template
  -- Purpose
  --    Called to obtain the info for templates which does
  --    have default template set in fnd_concurrent_program table
  --

  procedure fill_default_template(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              def_templ_code IN varchar2,
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
              def_output_type   IN OUT NOCOPY varchar2 );

  -- NAME
  --    fill_special_def_template
  -- Purpose
  --    Called to obtain the info for templates which require a specific query
  --

procedure fill_special_def_template(
              prog_app_name     IN varchar2,
              conc_prog_name    IN varchar2,
              def_templ_code IN varchar2,
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
              def_output_type   IN OUT NOCOPY varchar2 );

  -- NAME
  --    find_the_format
  -- Purpose
  --    Called to obtain the correct lookup value for the associated tag.
  --

  procedure find_the_format(
              format_type       IN  varchar2,
              format            IN OUT NOCOPY varchar2 );

  -- NAME
  --    get_iso_lang_and_terr
  -- Purpose
  --    Called to obtain the iso codes for the specific language and territory
  --

  procedure get_iso_lang_and_terr(
                        nls_lang IN varchar2,
                        nls_terr IN varchar2,
                        iso_lang IN OUT NOCOPY varchar2,
                        iso_terr IN OUT NOCOPY varchar2 );

  -- NAME
  --    get_iso_lang_and_terr
  -- Purpose
  --    Called to obtain the default iso territory code for the specific lang
  --

  procedure get_def_iso_terr(
                        nls_lang     IN varchar2,
                        def_iso_terr IN OUT NOCOPY varchar2 );



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
              format_type       IN OUT NOCOPY varchar2 );

  -- NAME
  --    def_template_check
  --    no_def_template_check
  -- Purpose
  --    setup to call proc data, return true if template info obtained

  function def_template_check (
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
           return boolean;

  function no_def_template_check (
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
           return boolean;


end FND_CONC_TEMPLATES;

/
