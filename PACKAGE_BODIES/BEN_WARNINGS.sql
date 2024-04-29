--------------------------------------------------------
--  DDL for Package Body BEN_WARNINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_WARNINGS" as
/* $Header: benwarng.pkb 120.2 2006/11/23 13:57:40 gsehgal noship $ */
--
g_package   varchar2(80) := 'ben_warnings';
----------------------------------------------------------------------------
--  exist_warning -- bug 4120426
--  exist_warning checks for duplicate message for the same person
----------------------------------------------------------------------------
Function exist_warning
   ( p_application_short_name   in varchar2,
     p_message_name             in varchar2,
     p_parm1     in number   default null,
     p_parm2     in number   default null,
     p_parma     in varchar2 default null,
     p_parmb     in varchar2 default null,
     p_parmc     in varchar2 default null,
     p_person_id in number   default null) return boolean is

   l_package varchar2(80) :=g_package||'.exist_warning';
 BEGIN
   hr_utility.set_location ('Entering '||l_package,10);
    --
    if (g_oab_warnings.first) is not null then
      --
      for i in g_oab_warnings.first..g_oab_warnings.last loop
          --
	  if ( g_oab_warnings(i).application_short_name          = p_application_short_name) and
	     ( g_oab_warnings(i).message_name                    = p_message_name) and
	     ( nvl( g_oab_warnings(i).parm1,hr_api.g_number)     = nvl(p_parm1,hr_api.g_number) ) and
	     ( nvl( g_oab_warnings(i).parm2,hr_api.g_number)     = nvl(p_parm2,hr_api.g_number) ) and
	     ( nvl( g_oab_warnings(i).parma,hr_api.g_varchar2)   = nvl( p_parma,hr_api.g_varchar2) ) and
	     ( nvl( g_oab_warnings(i).parmb,hr_api.g_varchar2)   = nvl( p_parmb,hr_api.g_varchar2) ) and
	     ( nvl( g_oab_warnings(i).parmc,hr_api.g_varchar2)   = nvl( p_parmc,hr_api.g_varchar2) ) and
	     ( nvl( g_oab_warnings(i).person_id,hr_api.g_number) = nvl(p_person_id,hr_api.g_number) )
	   then
	       	  return true;
           end if;
	  --
      end loop;
      --
    end if;
    --
   hr_utility.set_location ('Leaving '||l_package,20);
   return false;
 END exist_warning;


----------------------------------------------------------------------------
--  load_warning
----------------------------------------------------------------------------
PROCEDURE load_warning
    (p_application_short_name  in varchar2,
     p_message_name            in varchar2,
     p_parm1     in number default null,
     p_parm2     in number default null,
     p_parma     in varchar2 default null,
     p_parmb     in varchar2 default null,
     p_parmc     in varchar2 default null, --bug 4120426
     p_person_id in number   default null) is

  l_package varchar2(80) := g_package||'.load_warning';
  l_oab_warnings_index number;
BEGIN
  hr_utility.set_location ('Entering '||l_package,10);

  l_oab_warnings_index := nvl(g_oab_warnings.count,0) + 1;

  if not exist_warning
       ( p_application_short_name => p_application_short_name,
         p_message_name           => p_message_name,
         p_parm1                  => p_parm1,
	 p_parm2                  => p_parm2,
	 p_parma                  => p_parma,
	 p_parmb                  => p_parmb,
	 p_parmc                  => p_parmc,
         p_person_id              => p_person_id
       )then
  g_oab_warnings(l_oab_warnings_index).application_short_name :=
           p_application_short_name;
  g_oab_warnings(l_oab_warnings_index).message_name := p_message_name;
  g_oab_warnings(l_oab_warnings_index).parm1 := p_parm1;
  g_oab_warnings(l_oab_warnings_index).parm2 := p_parm2;
  g_oab_warnings(l_oab_warnings_index).parma := p_parma;
  g_oab_warnings(l_oab_warnings_index).parmb := p_parmb;
  g_oab_warnings(l_oab_warnings_index).parmc := p_parmc;
  g_oab_warnings(l_oab_warnings_index).person_id := p_person_id;

  end if;

  hr_utility.set_location ('Leaving '||l_package,10);

END load_warning;
----------------------------------------------------------------------------
--  trim_warnings
----------------------------------------------------------------------------
PROCEDURE trim_warnings(p_trim in number) is
  l_package varchar2(80) := g_package||'.trim_warnings';
  l_trim_begin number;
  l_trim_end   number;
begin
  hr_utility.set_location ('Entering '||l_package,10);

  -- 'p_trim' indicates the number of records that we want to delete from
  -- the end of the table.

  l_trim_begin := p_trim - 1;
  l_trim_end := g_oab_warnings.count;

  g_oab_warnings.delete(l_trim_begin,l_trim_end);

  hr_utility.set_location ('Leaving '||l_package,10);

end trim_warnings;

----------------------------------------------------------------------------
--  empty_warnings
----------------------------------------------------------------------------
PROCEDURE empty_warnings is

  l_package varchar2(80) := g_package||'.empty_warnings';
BEGIN
  hr_utility.set_location ('Entering '||l_package,10);

  g_oab_warnings.delete;

  hr_utility.set_location ('Leaving '||l_package,10);

END empty_warnings;
----------------------------------------------------------------------------
--  set_warning
----------------------------------------------------------------------------
PROCEDURE set_warning
    (p_index number) is

  l_package varchar2(80) := g_package||'.set_warning';
BEGIN
  hr_utility.set_location ('Entering '||l_package,10);

    fnd_message.set_name(g_oab_warnings(p_index).application_short_name
                        ,g_oab_warnings(p_index).message_name);

    if g_oab_warnings(p_index).parm1 is not null then
       fnd_message.set_token('PARM1',g_oab_warnings(p_index).parm1);
       if g_oab_warnings(p_index).parm2 is not null then
          fnd_message.set_token('PARM2',g_oab_warnings(p_index).parm2);
       end if;
    end if;
    if g_oab_warnings(p_index).parma is not null then
       fnd_message.set_token('PARMA',g_oab_warnings(p_index).parma);
       if g_oab_warnings(p_index).parmb is not null then
          fnd_message.set_token('PARMB',g_oab_warnings(p_index).parmb);
	  if g_oab_warnings(p_index).parmc is not null then
             fnd_message.set_token('PARMC',g_oab_warnings(p_index).parmc);
	  end if;
       end if;
    end if;

  hr_utility.set_location ('Leaving '||l_package,10);

END set_warning;
----------------------------------------------------------------------------
--  write_warnings_batch
----------------------------------------------------------------------------
PROCEDURE write_warnings_batch is

  l_package varchar2(80) := g_package||'.write_warnings_batch';

BEGIN
  hr_utility.set_location ('Entering '||l_package,10);

 if (g_oab_warnings.first) is not null then
   for i in g_oab_warnings.first..g_oab_warnings.last loop
      if g_oab_warnings(i).message_name <>  'BEN_93964_ENRO_DT_LT_LE_OCD_DT' --Bug#5030958 and Bug#5079314
       and  g_oab_warnings(i).message_name <> 'BEN_94464_ENROL_ED_DT_RANGE'
        and g_oab_warnings(i).message_name <> 'BEN_94441_ENROL_ST_DT_RANGE' then
      set_warning(p_index=> i);
      g_warning_rec.rep_typ_cd          := 'WARNING';
      g_warning_rec.error_message_code  := g_oab_warnings(i).message_name;
      g_warning_rec.text                := fnd_message.get;
      g_warning_rec.person_id           := g_oab_warnings(i).person_id;
      benutils.write(p_rec => g_warning_rec);
     end if;
    end loop;
  end if;
  empty_warnings;
  hr_utility.set_location ('Leaving '||l_package,10);

END write_warnings_batch;
----------------------------------------------------------------------------
--  write_warnings_online
----------------------------------------------------------------------------
PROCEDURE write_warnings_online (p_session_id in number) is

  l_package varchar2(80) := g_package||'.write_warnings_online';
  l_button number;
BEGIN
  hr_utility.set_location ('Entering '||l_package,10);

  if (g_oab_warnings.first) is not null then
    for i in g_oab_warnings.first..g_oab_warnings.last loop
      set_warning(p_index=> i);
        Insert into ben_online_warnings(session_id, message_text)
             values (p_session_id, fnd_message.get);
    end loop;
  end if;
  empty_warnings;

  hr_utility.set_location ('Leaving '||l_package,10);

END write_warnings_online;
----------------------------------------------------------------------------
--  delete_warnings
/*
This procedure is used to delete the warnings. warnings are deleted
based on the paramters passed.
*/
----------------------------------------------------------------------------

PROCEDURE delete_warnings (
   p_application_short_name   IN   VARCHAR2,
   p_message_name             IN   VARCHAR2,
   p_parm1                    IN   NUMBER DEFAULT NULL,
   p_parm2                    IN   NUMBER DEFAULT NULL,
   p_parma                    IN   VARCHAR2 DEFAULT NULL,
   p_parmb                    IN   VARCHAR2 DEFAULT NULL,
   p_parmc                    IN   VARCHAR2 DEFAULT NULL,
   p_person_id                IN   NUMBER DEFAULT NULL
)
IS
   curr_index      NUMBER;
   next_index      NUMBER;
   l_package       VARCHAR2 (80)         := g_package || '.delete_warnings';
BEGIN
   hr_utility.set_location ('Entering: ' || l_package, 10);
   hr_utility.set_location (p_application_short_name, 10);
   hr_utility.set_location (p_message_name, 10);
   hr_utility.set_location (p_parm1, 10);
   hr_utility.set_location (p_parm2, 10);
   hr_utility.set_location (p_parma, 10);
   hr_utility.set_location (p_parmb, 10);
   hr_utility.set_location (p_parmc, 10);
   hr_utility.set_location (p_person_id, 10);

   IF g_oab_warnings.COUNT > 0
   THEN
      hr_utility.set_location ('warnings exist ' || g_oab_warnings.COUNT, 20);
      next_index := g_oab_warnings.FIRST;

      LOOP
         curr_index := next_index;
         next_index := g_oab_warnings.NEXT (next_index);

         IF     g_oab_warnings (curr_index).application_short_name = p_application_short_name
            AND g_oab_warnings (curr_index).message_name = p_message_name
            AND NVL (g_oab_warnings (curr_index).person_id, -1) = NVL (p_person_id,-1)
            AND NVL (g_oab_warnings (curr_index).parma, '-1') = NVL (p_parma, '-1')
            AND NVL (g_oab_warnings (curr_index).parmb, '-1') = NVL (p_parmb, '-1')
            AND NVL (g_oab_warnings (curr_index).parmc, '-1') = NVL (p_parmc, '-1')
            AND NVL (g_oab_warnings (curr_index).parm1, '-1') = NVL (p_parm1, '-1')
            AND NVL (g_oab_warnings (curr_index).parm2, '-1') = NVL (p_parm2, '-1')
         THEN
            hr_utility.set_location ('Deleting warning ' || curr_index, 40);
            g_oab_warnings.DELETE (curr_index);
         END IF;

         IF next_index IS NULL
         THEN
            EXIT;
         END IF;
      END LOOP;
   END IF;

   hr_utility.set_location (' Leaving: ' || l_package, 10);
END delete_warnings;
-----
end ben_warnings;

/
