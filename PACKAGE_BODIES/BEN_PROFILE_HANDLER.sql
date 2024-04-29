--------------------------------------------------------
--  DDL for Package Body BEN_PROFILE_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROFILE_HANDLER" as
/* $Header: benprhnd.pkb 115.5 2004/02/16 02:39:52 vvprabhu ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Profile Handler
Purpose
	This package is used to handle setting of profile flags based on
        data changes that have occurred on child component tables.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        07-OCT-1999      GPERRY     115.0      Created.
        18-NOV-1999      GPERRY     115.1      Created.
        05-MAY-2003      STEE       115.3      Change dynamic sql to use
                                               bind variables. Bug 2939392.
       04-Feb-2004      vvprabhu    115.4      Bug 3431740 Parameter p_oracle_schema added
                                               to cursor cc_chk_table_exists in
                                               event_handler,
                                               the value is got by the
       				               call to fnd_installation.get_app_info
       15-Feb-2004      vvprabhu   115.8       Initialized l_application_short_name to BEN

*/
--------------------------------------------------------------------------------
g_package varchar2(80) := 'ben_profile_handler.';
--
procedure event_handler
  (p_event                       in  varchar2,
   p_base_table                  in  varchar2,
   p_base_table_column           in  varchar2,
   p_base_table_column_value     in  number,
   p_base_table_reference_column in  varchar2,
   p_reference_table             in  varchar2,
   p_reference_table_column      in  varchar2) is
  --
  l_proc        varchar2(80) := g_package||'event_handler';
  l_event       varchar2(80) := upper(p_event);
  l_dynamic_sql varchar2(32000);
  l_rows        number;
  l_status			varchar2(1);
  l_industry			varchar2(1);
  l_application_short_name	varchar2(30) := 'BEN';
  l_oracle_schema		varchar2(30);
  l_return                    boolean;
  --
  cursor c_chk_table_exists(p_table         in varchar2
                           ,p_column        in varchar2
                           ,p_oracle_schema in varchar2
                           ) is
    select 1
    from all_tab_columns
    where table_name = p_table
    and column_name = p_column
    and owner = upper(p_oracle_schema);
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc,10);
  --
  -- Debugging parameters
  --
  --hr_utility.set_location('Event '||
  --                         p_event,10);
  --hr_utility.set_location('Base Table '||
  --                         p_base_table,10);
  --hr_utility.set_location('Base Table Column '||
  --                         p_base_table_column,10);
  --hr_utility.set_location('Base Table Column Value '||
  --                         p_base_table_column_value,10);
  --hr_utility.set_location('Base Table Reference Column '||
  --                         p_base_table_reference_column,10);
  --hr_utility.set_location('Reference Table '||
  --                         p_reference_table,10);
  --hr_utility.set_location('Reference Table Column '||
  --                         p_reference_table_column,10);
  --
  -- Parameter validation
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'event',
                             p_argument_value => p_event);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'base_table',
                             p_argument_value => p_base_table);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'base_table_column',
                             p_argument_value => p_base_table_column);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'base_table_column_value',
                             p_argument_value => p_base_table_column_value);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'base_table_reference_column',
                             p_argument_value => p_base_table_reference_column);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'reference_table',
                             p_argument_value => p_reference_table);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'reference_table_column',
                             p_argument_value => p_reference_table_column);
  --
  -- Check operation is valid
  --
  if l_event not in ('CREATE','DELETE','UPGRADE') then
    --
    fnd_message.set_name('BEN','BEN_92466_EVENT_HANDLER');
    fnd_message.raise_error;
    --
  end if;
  --
  --  Check for reference table existence.
  --
  -- Bug 3431740 Parameter l_oracle_schema added to cursor c_chk_table_exists, the value is got
  -- by the  following call
  l_return := fnd_installation.get_app_info(application_short_name => l_application_short_name,
              		                    status                 => l_status,
                          	            industry               => l_industry,
                                	    oracle_schema          => l_oracle_schema);
  --
  open c_chk_table_exists(p_reference_table
                         ,p_reference_table_column,l_oracle_schema);
  if c_chk_table_exists%notfound then
    close c_chk_table_exists;
    fnd_message.set_name('BEN','BEN_93388_NO_TAB_COL');
    fnd_message.raise_error;
  else
    close c_chk_table_exists;
  end if;
  --
  --  Check for base table existence.
  --
  open c_chk_table_exists(p_base_table
                         ,p_base_table_column,l_oracle_schema);
  if c_chk_table_exists%notfound then
    close c_chk_table_exists;
    fnd_message.set_name('BEN','BEN_93388_NO_TAB_COL');
    fnd_message.raise_error;
  else
    close c_chk_table_exists;
  end if;

  --
  -- Rules
  -- =====
  -- The rules are as follows :
  -- For create we update the flag if the query returns one row as thats the
  -- one we have inserted. If the query returns more than one row then we don't
  -- care we assume the update has happened already.
  -- For delete we update the flag if the query returns zero rows as that means
  -- the only existing row was the one we deleted. If the query returns more
  -- than one row then we assume the update has already happened.
  -- For upgrade we assume that the database could be in the incorrect state
  -- thus we check and update whatever the result.
  --
  -- The SQL will look as follows :
  -- select count(*)
  -- from   :reference_table
  -- where  :reference_table_column = :base_table_column_value
  --
  -- If this is succesful then depending on the mode the following will happen
  --
  -- update :base_table
  -- set :base_table_column = :required_value
  --
  -- :required_value is set per the rules. If no rows exist then the flag is
  -- set to N. if rows exist then the flag is set to Y.
  --
  l_dynamic_sql := 'select count(*)
                    from   '||p_reference_table||' '||
                   'where  '||p_reference_table_column||' = :1';
  --
  execute immediate l_dynamic_sql  into l_rows using p_base_table_column_value;
  --
  -- Test for flag updates and if so update them
  --
  if l_event = 'CREATE' and
    l_rows = 1 then
    --
    l_dynamic_sql := 'update '||p_base_table||' '||
                     'set    '||p_base_table_reference_column||' = :1
                      where  '||p_base_table_column||' = :2';
    --
    execute immediate l_dynamic_sql using 'Y',p_base_table_column_value;
    --
  elsif l_event = 'DELETE' and
    l_rows = 0 then
    --
    l_dynamic_sql := 'update '||p_base_table||' '||
                     'set    '||p_base_table_reference_column||' = :1
                      where  '||p_base_table_column||' = :2';
    --
    execute immediate l_dynamic_sql using 'N', p_base_table_column_value;
    --
  elsif l_event = 'UPGRADE' and
    l_rows >= 1 then
    --
    l_dynamic_sql := 'update '||p_base_table||' '||
                     'set    '||p_base_table_reference_column||' = :1
                      where  '||p_base_table_column||' = :2';
    --
    execute immediate l_dynamic_sql using 'Y', p_base_table_column_value;
    --
  elsif l_event = 'UPGRADE' and
    l_rows = 0 then
    --
    l_dynamic_sql := 'update '||p_base_table||' '||
                     'set    '||p_base_table_reference_column||' = :1
                      where  '||p_base_table_column||' = :2';
    --
    execute immediate l_dynamic_sql using 'N', p_base_table_column_value;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc,10);
  --
end event_handler;
-----------------------------------------------------------------------
end ben_profile_handler;

/
