--------------------------------------------------------
--  DDL for Package Body AD_ZD_SEED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AD_ZD_SEED" AS
/* $Header: ADZDSMB.pls 120.2.12010000.3 2011/02/21 13:44:02 smadhapp noship $ */

G_PACKAGE CONSTANT VARCHAR2(80) := 'ad.plsql.ad_zd_seed.';
G_MODE NUMBER                   := MODE_DEFAULT;
G_LOG_LEVEL NUMBER              := FND_LOG.LEVEL_EXCEPTION;

/*
** --------------------------------------------------------------------
**    Internal
** --------------------------------------------------------------------
*/

/*
** Initialize logging parameters
**   x_mode       - calling module (for e.g: calling from FNDLOAD)
**   x_log_level  - log level
*/
procedure INIT_LOG(x_mode in number, x_log_level in number)
is
begin
  g_mode := x_mode;
  g_log_level := x_log_level;
end INIT_LOG;

/*
** Execute constructed SQL statement
**   x_log_level - log level
**   x_module    - calling procedure
**   x_message   - log message
*/
procedure LOG(x_log_level in number, x_module in varchar2, x_message in varchar2)
is
begin
  /* ad_zd.log(x_log_level, x_module , x_message); */
  if (mode_fndload = g_mode) then
     if (x_log_level >= g_log_level) then
        fnd_seed_stage_util.insert_msg(x_module || ': ' || x_message);
     end if;
  end if;
end LOG;

/*
** --------------------------------------------------------------------
**    Patch Event APIs - Public
** --------------------------------------------------------------------
*/

/*
** Prepare Table for Seed data patching
**   Product teams need to call this API once for every
**   seed data table a loader will insert/delete/update
**   data in.
*/
procedure PREPARE(x_table_name in varchar2)
is
    C_MODULE            varchar2(80) := g_package||'prepare';
begin
    log(fnd_log.level_procedure, c_module, x_table_name);
end PREPARE;

END AD_ZD_SEED;

/
