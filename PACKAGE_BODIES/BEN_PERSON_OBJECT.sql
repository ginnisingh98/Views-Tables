--------------------------------------------------------
--  DDL for Package Body BEN_PERSON_OBJECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PERSON_OBJECT" as
/* $Header: benperde.pkb 120.1.12010000.4 2009/09/25 01:50:41 krupani ship $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Person Object Caching Routine
Purpose
	This package is used to return person object information.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      11-Jun-99  gperry     Created(arcsed in by bbulusu)
  115.1      16-Jun-99  gperry     Added use of person date info structure so
                                   we can cache a persons minimum effective
                                   start date and assignment minimum effective
                                   start date.
                                   Added use of a person fte info structure so
                                   we can cache FTE data.
                                   Added cache structure to store active
                                   life event.
                                   Added cache structure to store persons
                                   benefits balance.
  115.2      23-Jun-99  gperry     Added assignment extra info cache.
  115.3      24-Jun-99  gperry     Added contact cache.
  115.4      24-Jun-99  gperry     Added new caches to clear_down_cache proc.
  115.5      12-Jul-99  mhoyes   - Removed + 0s from all cursors.
                                 - Modified overloaded trace messages.
  115.6      05-Aug-99  gperry     Added last cached record logic.
  115.7      09-Aug-99  gperry     Added new cache routines.
                                   assignment_status_types
                                   soft_coding_keyflex
                                   person_type_info
  115.8      12-Aug-99  gperry     Fixed error messages.
  115.9      16-Aug-99  gperry     Used nocopy compiler directive.
  115.10     17-Aug-99  gperry     Removed business group id check from
                                   set_ast_object.
  115.11     18-Aug-99  gperry     Added new cache structures for
                                   ben_bnfts_bal_f.
  115.12     23-Aug-99  gperry     Cache full time info using assignment id.
                                   Removed trace messages.
                                   Hashing done locally now.
  115.13     26-Aug-99  gperry     Added benefits assignment cache.
                                   Added applicants assignment cache.
                                   Made assignment cache use employee
                                   assignment.
  115.14     26-Aug-99  gperry     Made applicants assignment cache multirow.
  115.15     01-Sep-99  gperry     Applicant rows return in date order.
  115.16     15-Sep-99  gperry     Fixed bug 3045. Person type returns a null
                                   row for terminated employees.
  115.17     16-Sep-99  gperry     Backport of 115.7 with 115.16 fix.
  115.18     16-Sep-99  gperry     Leapfrog of 115.16.
  115.19     08-Oct-99  gperry     Backport of 115.17 with 115.10 fix
                                   Works with version 115.8 header.
  115.20     19-Oct-99  Tmathers   Leapfrog of 115.18.
  115.21     30-Dec-99  gperry     Fixed bug 1133284 so that when you get
                                   period of service you get the latest info
                                   whether the service is active or inactive.
  115.22     08-Feb-00  lmcdonal   add g_cache_last_typ_rec to clear_down_cache
                                   bug 1167264.
  115.23     01-May-00  rchase     Performance enhancements, implemented
                                   exception capturing instead of exists clauses
                                   added "out NOCOPY" to all set procs and
                                   removed extra record assignment statements
  115.24     10-Jul-00  gperry     Added firstass cache for WWBUG 1350997.
  115.25     20-Jul-00  gperry     Removed firstass cache and added allass
                                   cache for WWBUG 1350997.
  115.26     26-Jul-00  bbulusu    Selecting all contacts for g_cache_con_rec.
                                   Fix for WW Bug #1325440.  Leapfrog based
                                   on 115.22 - for Aera Production.
  115.27     26-Jul-00  jcarpent   Leapfrog based on 115.25 with change from
                                   above.
  115.28     28-Aug-00  stee       Select all contacts where the effective
                                   date is >= date_start instead of
                                   > date_start.
  115.29     14-Sep-00  mhoyes   - Added delete calls to all asg and applicant
                                   assignment caches.
  115.30     03-Oct-00  mhoyes   - Fixed semi-colon compliance violation.
  115.31     05-Oct-00  gperry     Added ord_id to person type cache.
                                   This way we can get person type from person.
  115.32     07-Nov-00  kmahendr - Fixed cache delete in the procedure set_allass_objecT
                                   g_cache_last_allass_rec.delete in place of g_cache_last_appass_rec.
                                   delete - WWWBug#1492522
  115.33     05-Jan-01  kmahendr - Added parameter per_in_ler_id
  115.34     24-Jan-02  kmahendr - Bug#2179708- Added cursor C2 to get full_time equivalent
                                   of all the assignments
  115.35     16-Mar-02  kmahendr - added dbdrv lines
  115.36     29-Apr-02  pabodla  - Bug 1631182 : support user created
                                   person type. Added person_type_id
                                   parameter.

  115.37     03-May-02  pabodla  - In set_typ_object for person_types do not get
                                   person_type_id from per_all_peole_f
  115.38     08-Jun-02  pabodla    Do not select the contingent worker
                                   assignment when assignment data is
                                   fetched.
  115.40     10-Oct-02  tmathers   bug 2620818 set_typ_object(): cursor c1
                        mmudigon   changed order by clause from col 4 to 5
  115.41     13 Feb 03  mhoyes   - Fixed PGA memory growth bug 2800680.
  115.42     17 Feb 03  pabodla    Added debug code
  115.43     20 Apr 03  pbodla   - FONM : where ever l_env dates are used
                                   use fonm dates first.
  115.44     14-Sep-07  rtagarra - Bug 6399423 changed cursor c1 in set_ass_object
  115.45     26-Oct-08  stee       Remove fix for bug 6399423.  Issue with
                                   assignment context for formula if there
                                   are no benefit assignment. 7480790
  115.46     15-May-09  krupani  - Bug 8364720: In set_ass_object and set_benass_object,
                                   if the cursor does not return any row, then there is no need to
				   call set_object
  115.47     25-Sep-09  krupani  - Bug 8920881: If ben_per_asg_elig.g_allow_contingent_wrk is set to Y,
                                   then don't ignore contingent worker assignment in set_allass_object
  -----------------------------------------------------------------------------
*/
--
g_package varchar2(30) := 'ben_person_object.';
g_hash_key number := ben_hash_utility.get_hash_key;
g_hash_jump number := ben_hash_utility.get_hash_jump;
g_debug boolean := hr_utility.debug_enabled;
--
-- Set object routines
--
procedure set_object(p_rec in out NOCOPY per_all_people_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object per';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_per_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_per_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_per_rec(l_index):=p_rec;
--
end set_object;
--
procedure set_object(p_rec in out NOCOPY ben_bnfts_bal_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object bnb';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.bnfts_bal_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_bnb_rec(l_index).bnfts_bal_id = p_rec.bnfts_bal_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bnb_rec(l_index).bnfts_bal_id <> p_rec.bnfts_bal_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_bnb_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY hr_soft_coding_keyflex%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object hsc';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.soft_coding_keyflex_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_hsc_rec(l_index).soft_coding_keyflex_id = p_rec.soft_coding_keyflex_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_hsc_rec(l_index).soft_coding_keyflex_id <> p_rec.soft_coding_keyflex_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_hsc_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object asg';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_ass_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ass_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_ass_rec(l_index):=p_rec;
end set_object;
--
procedure set_benass_object(p_rec in out NOCOPY per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object benass';
  l_index          pls_integer;
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_benass_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_benass_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_benass_rec(l_index):=p_rec;
end set_benass_object;
--
procedure set_object(p_rec in out NOCOPY per_assignment_status_types%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object ast';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.assignment_status_type_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_ast_rec(l_index).assignment_status_type_id = p_rec.assignment_status_type_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ast_rec(l_index).assignment_status_type_id <> p_rec.assignment_status_type_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_ast_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY per_assignment_extra_info%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object aei';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.assignment_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_aei_rec(l_index).assignment_id = p_rec.assignment_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_aei_rec(l_index).assignment_id <> p_rec.assignment_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_aei_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY ben_per_in_ler%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object pil';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_pil_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pil_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_pil_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY ben_per_bnfts_bal_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object bbb';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_bal_rec.count,0)+1;
  --
  g_cache_bal_rec(l_index) := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_rec in out NOCOPY per_contact_relationships%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object ctr';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_con_rec.count,0)+1;
  --
  g_cache_con_rec(l_index) := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_appass_object(p_rec in out NOCOPY per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object appass';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_appass_rec.count,0)+1;
  --
  g_cache_appass_rec(l_index) := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_appass_object;
--
procedure set_allass_object(p_rec in out NOCOPY per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object allass';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_allass_rec.count,0)+1;
  --
  g_cache_allass_rec(l_index) := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_allass_object;
--
procedure set_object(p_rec in out NOCOPY g_person_typ_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_object ctr';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  l_index := nvl(g_cache_typ_rec.count,0)+1;
  --
  g_cache_typ_rec(l_index) := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_object;
--
procedure set_object(p_rec in out NOCOPY per_periods_of_service%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object pds';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_pps_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pps_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_pps_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY per_addresses%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_object adr';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_pad_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pad_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_pad_rec(l_index):=p_rec;
end set_object;
--
procedure set_object(p_rec in out NOCOPY g_person_date_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_object pdi';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_date_rec(l_index).person_id = p_rec.person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_date_rec(l_index).person_id <> p_rec.person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_date_rec(l_index):=p_rec;
end set_object;
--
procedure set_bal_per_object(p_rec in out NOCOPY ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_bal_per_object';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_bal_per_rec(l_index).id = p_rec.id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bal_per_rec(l_index).id <> p_rec.id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_bal_per_rec(l_index):=p_rec;
end set_bal_per_object;
--
procedure set_con_per_object(p_rec in out NOCOPY ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_con_per_object';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_con_per_rec(l_index).id = p_rec.id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_con_per_rec(l_index).id <> p_rec.id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_con_per_rec(l_index):=p_rec;
end set_con_per_object;
--
procedure set_app_ass_object(p_rec in out NOCOPY ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_appass_object';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_app_ass_rec(l_index).id = p_rec.id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_app_ass_rec(l_index).id <> p_rec.id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_app_ass_rec(l_index):=p_rec;
end set_app_ass_object;
--
procedure set_all_ass_object(p_rec in out NOCOPY ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_allass_object';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_all_ass_rec(l_index).id = p_rec.id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_all_ass_rec(l_index).id <> p_rec.id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_all_ass_rec(l_index):=p_rec;
end set_all_ass_object;
--
procedure set_typ_per_object(p_rec in out NOCOPY ben_cache.g_cache_lookup) is
  --
  l_proc           varchar2(80) := g_package||'set_typ_per_object';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_typ_per_rec(l_index).id = p_rec.id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_typ_per_rec(l_index).id <> p_rec.id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_typ_per_rec(l_index):=p_rec;
end set_typ_per_object;
--
procedure set_object(p_rec in out NOCOPY g_person_fte_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_object pfte';
  l_index          pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) get hash index
  -- 2) If hash index is not used use hash index
  -- 3) If hash index is used and correct then do nothing
  -- 4) If hash index is used and not correct then try next hash index
  --
  -- Get hashed index value
  --
  l_index := mod(p_rec.assignment_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_fte_rec(l_index).assignment_id = p_rec.assignment_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_fte_rec(l_index).assignment_id <> p_rec.assignment_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_fte_rec(l_index):=p_rec;
end set_object;
--
-- Set object alternate route routines
--
procedure set_ass_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_ass_object';
  l_found          boolean := TRUE;
  --
cursor c1 is
    select paf.*
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.business_group_id  = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    paf.assignment_type = 'E'
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
--
--  Commented out fix for bug 6399423.  If there is no benefit assignment,
--  the assignment id is null and this causes a problem for some formulas.
--
/* -- Bug 6399423
  cursor c1 is
    select paf.*
    from   per_all_assignments_f paf
          ,per_assignment_status_types ast
    where  paf.person_id = p_person_id
    and    paf.business_group_id  = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    paf.assignment_type = 'E'
    and    paf.assignment_status_type_id = ast.assignment_status_type_id
    and    ast.per_system_status <> 'TERM_ASSIGN'
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date; */

  --l_rec per_all_assignments_f%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
--      p_rec.person_id := p_person_id;  -- Bug 8364720
        l_found := FALSE;                -- Bug 8364720
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  if l_found then -- Bug 8364720
     set_object(p_rec => p_rec);
  end if;
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_ass_object;
--
procedure set_benass_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_benass_object';
  l_found          boolean := TRUE;
  --
  cursor c1 is
    select paf.*
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.business_group_id  = p_business_group_id
    and    paf.primary_flag = 'Y'
    and    paf.assignment_type = 'B'
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date;
  --
  --l_rec per_all_assignments_f%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
     -- p_rec.person_id := p_person_id; -- Bug 8364720
        l_found := FALSE;               -- Bug 8364720
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  if l_found then  -- Bug 8364720
     set_object(p_rec => p_rec);
  end if;
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_benass_object;
--
procedure set_bnb_object
  (p_bnfts_bal_id      in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy ben_bnfts_bal_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_bnb_object';
  --
  -- FONM
  l_effective_date date ;
  --
  cursor c1 is
    select bnb.*
    from   ben_bnfts_bal_f bnb
    where  bnb.bnfts_bal_id = p_bnfts_bal_id
    and    bnb.business_group_id  = p_business_group_id
    and    l_effective_date
           between bnb.effective_start_date
           and     bnb.effective_end_date;
  --
  --l_rec ben_bnfts_bal_f%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  -- FONM
  --
  l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                p_effective_date)
                           );
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
      p_rec.bnfts_bal_id := p_bnfts_bal_id;
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  set_object(p_rec => p_rec);
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_bnb_object;
--
procedure set_ast_object
  (p_assignment_status_type_id in number,
   p_rec                       in out nocopy per_assignment_status_types%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_ast_object';
  --
  cursor c1 is
    select pas.*
    from   per_assignment_status_types pas
    where  pas.assignment_status_type_id = p_assignment_status_type_id
    and    pas.active_flag = 'Y';
  --
  -- l_rec per_assignment_status_types%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
      p_rec.assignment_status_type_id := p_assignment_status_type_id;
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  set_object(p_rec => p_rec);
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_ast_object;
--
procedure set_ass_object
  (p_assignment_id     in number,
   p_rec               in out nocopy per_assignment_extra_info%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_ass_object';
  --
  cursor c1 is
    select pei.*
    from   per_assignment_extra_info pei
    where  pei.assignment_id = p_assignment_id
    and    pei.information_type = 'BEN_DERIVED';
  --
  --l_rec per_assignment_extra_info%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
      p_rec.assignment_id := p_assignment_id;
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  set_object(p_rec => p_rec);
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_ass_object;
--
procedure set_pil_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   -- added a per_in_ler_id for unrestricted enhancement
   p_per_in_ler_id     in number default null,
   p_rec               in out nocopy ben_per_in_ler%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_pil_object';
  --
  cursor c1 is
    select pil.*
    from   ben_per_in_ler pil
    where  pil.person_id = p_person_id
    and    pil.business_group_id  = p_business_group_id
    and    pil.per_in_ler_stat_cd = 'STRTD'
  --  added per_in_ler_id for unrestricted enhancement
    and    pil.per_in_ler_id = nvl(p_per_in_ler_id,pil.per_in_ler_id);
  --
  --l_rec ben_per_in_ler%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
      p_rec.person_id := p_person_id;
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  set_object(p_rec => p_rec);
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_pil_object;
--
procedure set_con_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy g_cache_con_table) is
  --
  l_proc           varchar2(80) := g_package||'set_con_object';
  --
  -- As fix for WW Bug #1325440 this cursor now picks up all contacts for
  -- the participant and does not ignore end-dated relationships.
  --
  cursor c1 is
    select con.*
    from   per_contact_relationships con,
           per_all_people_f ppf
    where  con.person_id = p_person_id
    and    con.business_group_id  = p_business_group_id
    and   nvl(con.date_start,hr_api.g_sot) <= p_effective_date
    and    ppf.person_id = con.contact_person_id
    and    ppf.business_group_id  = con.business_group_id
    and    p_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date;
  --
  l_rec         g_cache_con_table;
  l_con_per_rec ben_cache.g_cache_lookup;
  l_num_recs    number := 0;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  g_cache_last_con_rec.delete;
  --
  open c1;
    --
    loop
      --
      l_num_recs := l_num_recs + 1;
      fetch c1 into l_rec(l_num_recs);
      exit when c1%notfound;
      --
      set_object(p_rec => l_rec(l_num_recs));
      g_cache_last_con_rec(l_num_recs) := l_rec(l_num_recs);
      --
      if l_num_recs = 1 then
        --
        l_con_per_rec.starttorele_num := g_cache_con_rec.count;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- We need to set the con_per object.
  --
  l_con_per_rec.id := p_person_id;
  --
  if l_con_per_rec.starttorele_num is not null then
    --
    l_con_per_rec.endtorele_num := g_cache_con_rec.count;
    --
  end if;
  --
  set_con_per_object(p_rec => l_con_per_rec);
  --
  p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_con_object;
--
procedure set_appass_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy g_cache_ass_table) is
  --
  l_proc           varchar2(80) ;
  --
  cursor c1 is
    select paf.*
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.business_group_id  = p_business_group_id
    and    paf.assignment_type = 'A'
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
    order  by paf.effective_start_date;
  --
  l_rec         g_cache_ass_table;
  l_app_ass_rec ben_cache.g_cache_lookup;
  l_num_recs    number := 0;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'set_app_ass_object';
    hr_utility.set_location('Entering '||l_proc,10);
  end if;
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  g_cache_last_appass_rec.delete;
  --
  open c1;
    --
    loop
      --
      l_num_recs := l_num_recs + 1;
      fetch c1 into l_rec(l_num_recs);
      exit when c1%notfound;
      --
      set_appass_object(p_rec => l_rec(l_num_recs));
      g_cache_last_appass_rec(l_num_recs) := l_rec(l_num_recs);
      --
      if l_num_recs = 1 then
        --
        l_app_ass_rec.starttorele_num := g_cache_app_ass_rec.count;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- We need to set the con_per object.
  --
  l_app_ass_rec.id := p_person_id;
  --
  if l_app_ass_rec.starttorele_num is not null then
    --
    l_app_ass_rec.endtorele_num := g_cache_app_ass_rec.count;
    --
  end if;
  --
  set_app_ass_object(p_rec => l_app_ass_rec);
  --
  p_rec := l_rec;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,10);
  end if;
  --
end set_appass_object;
--
procedure set_allass_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy g_cache_ass_table) is
  --
  l_proc           varchar2(80) ;
  --
  cursor c1(p_allow_cont_wrk varchar) is
    select paf.*
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.assignment_type <> (decode(p_allow_cont_wrk,'N','C',hr_api.g_varchar2))  /* 8920881 */
    and    paf.business_group_id  = p_business_group_id
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
    order  by paf.effective_start_date;
  --
  l_rec         g_cache_ass_table;
  l_all_ass_rec ben_cache.g_cache_lookup;
  l_num_recs    number := 0;
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'set_all_ass_object';
    hr_utility.set_location('Entering '||l_proc,10);
    hr_utility.set_location('ben_per_asg_elig.g_allow_contingent_wrk '||ben_per_asg_elig.g_allow_contingent_wrk,11);
  end if;
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  g_cache_last_allass_rec.delete;
  --
  open c1(ben_per_asg_elig.g_allow_contingent_wrk);
    --
    loop
      --
      l_num_recs := l_num_recs + 1;
      fetch c1 into l_rec(l_num_recs);
      exit when c1%notfound;
      --
      set_allass_object(p_rec => l_rec(l_num_recs));
      g_cache_last_allass_rec(l_num_recs) := l_rec(l_num_recs);
      --
      if l_num_recs = 1 then
        --
        l_all_ass_rec.starttorele_num := g_cache_all_ass_rec.count;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- We need to set the con_per object.
  --
  l_all_ass_rec.id := p_person_id;
  --
  if l_all_ass_rec.starttorele_num is not null then
    --
    l_all_ass_rec.endtorele_num := g_cache_all_ass_rec.count;
    --
  end if;
  --
  set_all_ass_object(p_rec => l_all_ass_rec);
  --
  p_rec := l_rec;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,10);
  end if;
  --
end set_allass_object;
--
procedure set_typ_object
  (p_person_id         in  number,
   p_business_group_id in  number,
   p_effective_date    in  date,
   p_rec               in out nocopy g_cache_typ_table) is
  --
  l_proc           varchar2(80) ;
  --
  cursor c1 is
    select per.person_id,
           ppt.person_type_id,
           ppt.user_person_type,
           ppt.system_person_type,
           decode(ppt.system_person_type,'EMP',1,2)
    from   per_person_type_usages_f per,
           per_person_types ppt
    where  per.person_id = p_person_id
    and    p_effective_date
           between per.effective_start_date
           and     per.effective_end_date
    and    per.person_type_id = ppt.person_type_id
   --
   -- This person_type_id is the original person type  id. It is possible that
   -- this person type id may not exist in per_person_type_usages_f. So this
   -- data should not be used for profiles evaluation.
   --
   /* union
    select ppf.person_id,
           ppt.person_type_id,
           ppt.user_person_type,
           ppt.system_person_type,
           decode(ppt.system_person_type,'EMP',1,2)
    from   per_all_people_f ppf,
           per_person_types ppt
    where  ppf.person_id = p_person_id
    and    p_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date
    and    ppf.person_type_id = ppt.person_type_id */
    order  by 5;
  --
  l_rec         g_cache_typ_table;
  l_typ_per_rec ben_cache.g_cache_lookup;
  l_num_recs    number := 0;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  g_cache_last_typ_rec.delete;
  --
  open c1;
    --
    loop
      --
      l_num_recs := l_num_recs + 1;
      fetch c1 into l_rec(l_num_recs);
      --
      if c1%notfound and l_num_recs = 1 then
        --
        l_rec(l_num_recs).person_id := p_person_id;
        set_object(p_rec => l_rec(l_num_recs));
        g_cache_last_typ_rec(l_num_recs) := l_rec(l_num_recs);
        --
        if l_num_recs = 1 then
          --
          l_typ_per_rec.starttorele_num := g_cache_typ_rec.count;
          --
        end if;
        --
      end if;
      --
      exit when c1%notfound;
      --
      set_object(p_rec => l_rec(l_num_recs));
      g_cache_last_typ_rec(l_num_recs) := l_rec(l_num_recs);
      --
      if l_num_recs = 1 then
        --
        l_typ_per_rec.starttorele_num := g_cache_typ_rec.count;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- We need to set the typ_per object.
  --
  l_typ_per_rec.id := p_person_id;
  --
  if l_typ_per_rec.starttorele_num is not null then
    --
    l_typ_per_rec.endtorele_num := g_cache_typ_rec.count;
    --
  end if;
  --
  set_typ_per_object(p_rec => l_typ_per_rec);
  --
  p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_typ_object;
--
procedure set_bal_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date) is
  --
  l_proc           varchar2(80) := g_package||'set_bal_object';
  --
  cursor c1 is
    select bal.*
    from   ben_per_bnfts_bal_f bal
    where  bal.person_id = p_person_id
    and    bal.business_group_id  = p_business_group_id;
  --
  l_rec         ben_per_bnfts_bal_f%rowtype;
  l_bal_per_rec ben_cache.g_cache_lookup;
  l_num_recs    number := 0;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    loop
      --
      fetch c1 into l_rec;
      exit when c1%notfound;
      --
      set_object(p_rec => l_rec);
      --
      l_num_recs := l_num_recs +1;
      --
      if l_num_recs = 1 then
        --
        l_bal_per_rec.starttorele_num := g_cache_bal_rec.count;
        --
      end if;
      --
    end loop;
    --
  close c1;
  --
  -- We need to set the bal_per object.
  --
  l_bal_per_rec.id := p_person_id;
  --
  if l_bal_per_rec.starttorele_num is not null then
    --
    l_bal_per_rec.endtorele_num := g_cache_bal_rec.count;
    --
  end if;
  --
  set_bal_per_object(p_rec => l_bal_per_rec);
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_bal_object;
--
procedure set_pad_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_addresses%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_pad_object';
  --
  cursor c1 is
    select pad.*
    from   per_addresses pad
    where  pad.person_id = p_person_id
    and    pad.business_group_id  = p_business_group_id
    and    pad.primary_flag = 'Y'
    and    p_effective_date
           between pad.date_from
           and     nvl(pad.date_to,p_effective_date);
  --
  --l_rec per_addresses%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
      p_rec.person_id := p_person_id;
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  set_object(p_rec => p_rec);
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_pad_object;
--
procedure set_hsc_object
  (p_soft_coding_keyflex_id in number,
   p_rec                    in out nocopy hr_soft_coding_keyflex%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_hsc_object';
  --
  cursor c1 is
    select hsc.*
    from   hr_soft_coding_keyflex hsc
    where  hsc.soft_coding_keyflex_id = p_soft_coding_keyflex_id;
  --
  l_rec hr_soft_coding_keyflex%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      --l_rec.person_id := p_person_id;
      p_rec.soft_coding_keyflex_id := p_soft_coding_keyflex_id;
      --
    end if;
    --
  close c1;
  --
  --115.23 - altered to use NOCOPY record
  --set_object(p_rec => l_rec);
  set_object(p_rec => p_rec);
  --
  -- 115.23 - unnecessary, using NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
end set_hsc_object;
--
procedure set_per_object(p_person_id         in  number,
                         p_business_group_id in  number,
                         p_effective_date    in  date,
                         p_rec               in out nocopy per_all_people_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_per_object';
  l_index          pls_integer;
  --
  cursor c1 is
    select ppf.*
    from   per_all_people_f ppf
    where  ppf.person_id = p_person_id
    and    ppf.business_group_id  = p_business_group_id
    and    p_effective_date
           between ppf.effective_start_date
           and     ppf.effective_end_date;
  --
  --l_rec per_all_people_f%rowtype;
  --115.23 altered to use NOCOPY record
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    -- 115.23 altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92308_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',p_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --115.23 - removed additional call
  --set_object(p_rec => p_rec);
  l_index := mod(p_person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_per_rec(l_index).person_id = p_person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_per_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
--
  --115.23 - altered to use NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_per_rec(l_index):=p_rec;
end set_per_object;
--
procedure set_pps_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy per_periods_of_service%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'set_pps_object';
  l_index pls_integer;
  --
  cursor c1 is
    select pps.*
    from   per_periods_of_service pps
    where  pps.person_id = p_person_id
    and    pps.business_group_id  = p_business_group_id
    and    p_effective_date >= pps.date_start
    order  by pps.date_start desc;
  --
  --l_rec per_periods_of_service%rowtype;
  --115.23 - comment out unneeded record
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  open c1;
    --
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec;
    if c1%notfound then
      --
      --115.23 - altered to use NOCOPY record
      p_rec.person_id := p_person_id;
      --
    end if;
    --
  close c1;
  --115.23 - removed additional call
  --set_object(p_rec => p_rec);
  l_index := mod(p_person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_pps_rec(l_index).person_id = p_person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pps_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
--
  --115.23 - altered to use NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- set cache entry at current index location
   g_cache_pps_rec(l_index):=p_rec;
end set_pps_object;
--
procedure set_per_dates_object
  (p_person_id         in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy g_person_date_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_per_dates_object';
  l_index pls_integer;
  --
  cursor c1 is
    select min(ppf.effective_start_date)
    from   per_all_people_f ppf
    where  ppf.person_id = p_person_id
    and    ppf.business_group_id  = p_business_group_id;
  --
  cursor c2 is
    select min(paf.effective_start_date)
    from   per_all_assignments_f paf
    where  paf.person_id = p_person_id
    and    paf.assignment_type <> 'C'
    and    paf.business_group_id  = p_business_group_id
    and    paf.primary_flag = 'Y';
  --
  --l_rec g_person_date_info_rec;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --
  --115.23 - altered to use NOCOPY record
  p_rec.person_id := p_person_id;
  --
  open c1;
    -- 115.23 - altered to use NOCOPY record
    fetch c1 into p_rec.min_per_effective_start_date;
    if c1%notfound then
      --
      close c1;
      fnd_message.set_name('BEN','BEN_92308_OBJECT_NOT_FOUND');
      fnd_message.set_token('PROC',l_proc);
      fnd_message.set_token('PERSON_ID',p_person_id);
      fnd_message.set_token('BUSINESS_GROUP_ID',p_business_group_id);
      fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
      fnd_message.raise_error;
      --
    end if;
    --
  close c1;
  --
  open c2;
    --115.23 - altered to use NOCOPY record
    fetch c2 into p_rec.min_ass_effective_start_date;
    --
  close c2;
  l_index := mod(p_person_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_date_rec(l_index).person_id = p_person_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_date_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_date_rec(l_index):=p_rec;
end set_per_dates_object;
--
procedure set_per_fte_object
  (p_assignment_id     in number,
   p_business_group_id in number,
   p_effective_date    in date,
   p_rec               in out nocopy g_person_fte_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'set_per_fte_object';
  l_index pls_integer;
  --
  cursor c1(p_primary_flag varchar2) is
    select sum(pab.value)
    from   per_assignments_f paf,
           per_assignment_budget_values_f pab
    where  paf.assignment_id = p_assignment_id
    and    paf.business_group_id = p_business_group_id
    and    paf.primary_flag = nvl(p_primary_flag,paf.primary_flag)
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
    and    pab.business_group_id   = paf.business_group_id
    and    pab.assignment_id = paf.assignment_id
    and    pab.unit = 'FTE'
    and    p_effective_date
           between pab.effective_start_date
           and     pab.effective_end_date;
  --
  -- Bug#2179708 - to sum for all the assignments, person_id needs to be joined
  cursor c2 is
    select sum(pab.value)
    from   per_assignments_f paf,
           per_assignment_budget_values_f pab,
           per_assignments_f paf2
    where  paf.assignment_id = p_assignment_id
    and    paf.business_group_id = p_business_group_id
    and    p_effective_date
           between paf.effective_start_date
           and     paf.effective_end_date
    and    paf.person_id    = paf2.person_id
    and    pab.business_group_id   = paf2.business_group_id
    and    pab.assignment_id = paf2.assignment_id
    and    pab.unit = 'FTE'
    and    p_effective_date
           between pab.effective_start_date
           and     pab.effective_end_date
   and     p_effective_date
           between paf2.effective_start_date
           and     paf2.effective_end_date;

  --l_rec g_person_fte_info_rec;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get record from database.
  -- 2) If record not found then raise error.
  -- 3) Pass record to set_object routine.
  --115.23 - altered to use NOCOPY record
  --l_rec.assignment_id := p_assignment_id;
  p_rec.assignment_id := p_assignment_id;
  --
  open c1('Y');
    --115.23 - altered to use NOCOPY record
    fetch c1 into p_rec.fte;
    --
  close c1;
  --
  open c2;
    --115.23 - altered to use NOCOPY record
    fetch c2 into p_rec.total_fte;
    --
  close c2;
  --115.23 - altered to use NOCOPY record
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
  l_index := mod(p_assignment_id,g_hash_key);
  --
    -- 115.23 check for cache entry at current index.  if none exists the NO_DATA_FOUND expection will fire
    if g_cache_fte_rec(l_index).assignment_id = p_assignment_id then
       -- do nothing, cache entry already exists
       null;
    else
      --
      -- Loop through the hash using the jump routine to check further
      -- indexes
      -- 115.23 if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_fte_rec(l_index).assignment_id <> p_assignment_id loop
        --
        l_index := l_index+g_hash_jump;

      end loop;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception when NO_DATA_FOUND then
  -- 115.23 set cache entry at current index location
   g_cache_fte_rec(l_index):=p_rec;
end set_per_fte_object;
--
-- Get object routines
--
procedure get_object(p_person_id in  number,
                     p_rec       in out nocopy per_all_people_f%rowtype) is
  l_proc           varchar2(80) := g_package||'get_object per';
  l_index          pls_integer;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            per_all_people_f%rowtype;
  --
  -- FONM
  l_effective_date date;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_per_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_per_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return person_id
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_per_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_per_rec := g_cache_per_rec(l_index);
      p_rec := g_cache_last_per_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_per_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_per_rec := g_cache_per_rec(l_index);
      p_rec := g_cache_last_per_rec;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    -- Defrag all person caches to grab back PGA memory
    --
    ben_person_object.defrag_caches;
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_per_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date,
                   p_rec               => p_rec);
    --
    g_cache_last_per_rec := p_rec;
    --
    --
end get_object;
--
procedure get_object(p_bnfts_bal_id in  number,
                     p_rec          in out nocopy ben_bnfts_bal_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object bnb';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_bnfts_bal_f%rowtype;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_bnb_rec.bnfts_bal_id = p_bnfts_bal_id then
    --
    p_rec := g_cache_last_bnb_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return person_id
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_bnfts_bal_id,g_hash_key);
  --
    if g_cache_bnb_rec(l_index).bnfts_bal_id = p_bnfts_bal_id then
      --
      g_cache_last_bnb_rec := g_cache_bnb_rec(l_index);
      p_rec := g_cache_last_bnb_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bnb_rec(l_index).bnfts_bal_id <> p_bnfts_bal_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_bnb_rec := g_cache_bnb_rec(l_index);
      p_rec := g_cache_last_bnb_rec;
      --
    end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_bnb_object(p_bnfts_bal_id      => p_bnfts_bal_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM
                                             nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date),*/
                   p_rec               => p_rec);
    --
    g_cache_last_bnb_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_soft_coding_keyflex_id in  number,
                     p_rec                    in out nocopy hr_soft_coding_keyflex%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object hsc';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --l_rec            hr_soft_coding_keyflex%rowtype;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_hsc_rec.soft_coding_keyflex_id = p_soft_coding_keyflex_id then
    --
    p_rec := g_cache_last_hsc_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return person_id
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_soft_coding_keyflex_id,g_hash_key);
  --
    if g_cache_hsc_rec(l_index).soft_coding_keyflex_id = p_soft_coding_keyflex_id then
      --
      g_cache_last_hsc_rec := g_cache_hsc_rec(l_index);
      p_rec := g_cache_last_hsc_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_hsc_rec(l_index).soft_coding_keyflex_id <> p_soft_coding_keyflex_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_hsc_rec := g_cache_hsc_rec(l_index);
      p_rec := g_cache_last_hsc_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    set_hsc_object(p_soft_coding_keyflex_id => p_soft_coding_keyflex_id,
                   p_rec                    => p_rec);
    --
    g_cache_last_hsc_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_person_id  in  number,
                     p_rec        in out nocopy per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object asg';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            per_all_assignments_f%rowtype;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_ass_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_ass_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_ass_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_ass_rec := g_cache_ass_rec(l_index);
      p_rec := g_cache_last_ass_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ass_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_ass_rec := g_cache_ass_rec(l_index);
      p_rec := g_cache_last_ass_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_ass_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date),*/
                   p_rec               => p_rec);
    --
    g_cache_last_ass_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_benass_object
                    (p_person_id  in  number,
                     p_rec        in out nocopy per_all_assignments_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object benass';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            per_all_assignments_f%rowtype;
  --
  -- FONM
  l_effective_date date;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_benass_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_benass_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_benass_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_benass_rec := g_cache_benass_rec(l_index);
      p_rec := g_cache_last_benass_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_benass_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_benass_rec := g_cache_benass_rec(l_index);
      p_rec := g_cache_last_benass_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_benass_object(p_person_id         => p_person_id,
                      p_business_group_id => l_env.business_group_id,
                      p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                                 l_env.effective_date),*/
                      p_rec               => p_rec);
    --
    g_cache_last_benass_rec := p_rec;

    --p_rec := l_rec;
    --
end get_benass_object;
--
procedure get_object(p_assignment_status_type_id in  number,
                     p_rec                       in out nocopy per_assignment_status_types%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object ast';
  l_index          pls_integer;
  l_not_hash_found boolean;
  l_rec            per_assignment_status_types%rowtype;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_ast_rec.assignment_status_type_id = p_assignment_status_type_id then
    --
    p_rec := g_cache_last_ast_rec;
    return;
    --
  end if;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_assignment_status_type_id,g_hash_key);
  --
    if g_cache_ast_rec(l_index).assignment_status_type_id = p_assignment_status_type_id then
      --
      g_cache_last_ast_rec := g_cache_ast_rec(l_index);
      p_rec := g_cache_last_ast_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_ast_rec(l_index).assignment_status_type_id <> p_assignment_status_type_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_ast_rec := g_cache_ast_rec(l_index);
      p_rec := g_cache_last_ast_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    set_ast_object(p_assignment_status_type_id => p_assignment_status_type_id,
                   p_rec                       => p_rec);
    --
    g_cache_last_ast_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_assignment_id in  number,
                     p_rec           in out nocopy per_assignment_extra_info%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object aei';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  --l_rec            per_assignment_extra_info%rowtype;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_aei_rec.assignment_id = p_assignment_id then
    --
    p_rec := g_cache_last_aei_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_assignment_id,g_hash_key);
  --
    if g_cache_aei_rec(l_index).assignment_id = p_assignment_id then
      --
      g_cache_last_aei_rec := g_cache_aei_rec(l_index);
      p_rec := g_cache_last_aei_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_aei_rec(l_index).assignment_id <> p_assignment_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_aei_rec := g_cache_aei_rec(l_index);
      p_rec := g_cache_last_aei_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    set_ass_object(p_assignment_id     => p_assignment_id,
                   p_rec               => p_rec);
    --
    g_cache_last_aei_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_person_id  in  number,
  -- added per_in_ler_id for unrestricted enhancement
                     p_per_in_ler_id  in number default null,
                     p_rec        in out nocopy ben_per_in_ler%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object pil';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_per_in_ler%rowtype;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_pil_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_pil_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_pil_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_pil_rec := g_cache_pil_rec(l_index);
      p_rec := g_cache_last_pil_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pil_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_pil_rec := g_cache_pil_rec(l_index);
      p_rec := g_cache_last_pil_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_pil_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date),*/
-- added per_in_ler_id for unrestricted enhancement
                   p_per_in_ler_id     => p_per_in_ler_id,
                   p_rec               => p_rec);
    --
    g_cache_last_pil_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_person_id  in  number,
                     p_rec        in out nocopy per_addresses%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object adr';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            per_addresses%rowtype;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_pad_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_pad_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_pad_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_pad_rec := g_cache_pad_rec(l_index);
      p_rec := g_cache_last_pad_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pad_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_pad_rec := g_cache_pad_rec(l_index);
      p_rec := g_cache_last_pad_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_pad_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date), */
                   p_rec               => p_rec);
    --
    g_cache_last_pad_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_person_id  in  number,
                     p_rec        in out nocopy per_periods_of_service%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object pds';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            per_periods_of_service%rowtype;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_pps_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_pps_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_pps_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_pps_rec := g_cache_pps_rec(l_index);
      p_rec := g_cache_last_pps_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_pps_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_pps_rec := g_cache_pps_rec(l_index);
      p_rec := g_cache_last_pps_rec;
      --
    end if;
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_pps_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date), */
                   p_rec               => p_rec);
    --
    g_cache_last_pps_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_person_id      in  number,
                     p_bnfts_bal_id   in  number,
                     p_effective_date in  date,
                     p_rec            in out nocopy ben_per_bnfts_bal_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_object bbb';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            ben_per_bnfts_bal_f%rowtype;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_bal_rec.person_id = p_person_id and
     g_cache_last_bal_rec.bnfts_bal_id = p_bnfts_bal_id and
     nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
         nvl(ben_manage_life_events.g_fonm_cvg_strt_dt, p_effective_date))
     between g_cache_last_bal_rec.effective_start_date
     and     g_cache_last_bal_rec.effective_end_date then
    --
    p_rec := g_cache_last_bal_rec;
    hr_utility.set_location('g_cache_last_bal_rec '||l_proc,10);
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_bal_per_rec(l_index).id = p_person_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bal_per_rec(l_index).id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      --
    end if;
  --
  -- FONM
  --
  ben_env_object.get(p_rec => l_env);
  --
  l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                p_effective_date)
                           );
    --
    hr_utility.set_location('Before get_bal_per_object '||l_proc,10);
  get_bal_per_object
    (p_person_id      => p_person_id,
     p_bnfts_bal_id   => p_bnfts_bal_id,
     p_effective_date => l_effective_date,
     p_rec            => p_rec);
  --
  g_cache_last_bal_rec := p_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_bal_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date); /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date)); */
    --
    get_bal_per_object
      (p_person_id      => p_person_id,
       p_bnfts_bal_id   => p_bnfts_bal_id,
       p_effective_date => l_effective_date,
       p_rec            => p_rec);
    --
    g_cache_last_bal_rec := p_rec;
    --
end get_object;
--
procedure get_object(p_person_id      in  number,
                     p_rec            in out nocopy g_cache_con_table) is
  --
  l_proc           varchar2(80) := g_package||'get_object con';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            g_cache_con_table;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  BEGIN
    if g_cache_last_con_rec(1).person_id = p_person_id then
      --115.23 no need for for loop, just make the assignment
--      for l_count in g_cache_last_con_rec.first..
--        g_cache_last_con_rec.last loop
       --
--        p_rec(l_count) := g_cache_last_con_rec(l_count);
        p_rec := g_cache_last_con_rec;
        --
--      end loop;
      --
      return;
      --
    end if;
  EXCEPTION WHEN OTHERS THEN
     NULL;
  END;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_con_per_rec(l_index).id = p_person_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_con_per_rec(l_index).id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
    end if;
  --
  if g_cache_con_per_rec(l_index).starttorele_num is not null then
    --115.23 no need for delete, just assign later
    --g_cache_last_con_rec.delete;
    --
    for l_count in g_cache_con_per_rec(l_index).starttorele_num..
       g_cache_con_per_rec(l_index).endtorele_num loop
      --
      p_rec(p_rec.count+1) := g_cache_con_rec(l_count);
      --
    end loop;
    --115.23 move assignment outside of loop, faster
    g_cache_last_con_rec:=p_rec;
    --
  end if;
  --
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_con_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date), */
                   p_rec               => p_rec);
    --
end get_object;
--
procedure get_object(p_person_id      in  number,
                     p_rec            in out nocopy g_cache_ass_table) is
  --
  l_proc           varchar2(80) := g_package||'get_object ass';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            g_cache_ass_table;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'set_typ_object';
    hr_utility.set_location('Entering '||l_proc,10);
  end if;
  --
  begin
    if g_cache_last_appass_rec(1).person_id = p_person_id then
      --115.23 take out loop
      --for l_count in g_cache_last_appass_rec.first..
        --g_cache_last_appass_rec.last loop
        --
        p_rec := g_cache_last_appass_rec;
        --
      --end loop;
      --
      return;
      --
    end if;
    --
  exception when others then
     null;
  end;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_app_ass_rec(l_index).id = p_person_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_app_ass_rec(l_index).id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
    end if;
  --
  if g_cache_app_ass_rec(l_index).starttorele_num is not null then
    --
    for l_count in g_cache_app_ass_rec(l_index).starttorele_num..
       g_cache_app_ass_rec(l_index).endtorele_num loop
      --
      p_rec(p_rec.count+1) := g_cache_appass_rec(l_count);
      --
    end loop;
      --115.23 move out of loop, faster
      g_cache_last_appass_rec:=p_rec;
    --
  end if;
  --115.23 no need
  --p_rec := l_rec;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,10);
  end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_appass_object(p_person_id         => p_person_id,
                      p_business_group_id => l_env.business_group_id,
                      p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                                 l_env.effective_date), */
                      p_rec               => p_rec);
    --
end get_object;
--
procedure get_allass_object(p_person_id      in  number,
                            p_rec            in out nocopy g_cache_ass_table) is
  --
  l_proc           varchar2(80) ;
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            g_cache_ass_table;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
    l_proc := g_package||'get_allass_object ass';
    hr_utility.set_location('Entering '||l_proc,10);
  end if;
  --
  begin
    if g_cache_last_allass_rec(1).person_id = p_person_id then
      --115.23 take out loop
      --for l_count in g_cache_last_appass_rec.first..
        --g_cache_last_appass_rec.last loop
        --
        p_rec := g_cache_last_allass_rec;
        --
      --end loop;
      --
      return;
      --
    end if;
    --
  exception when others then
     null;
  end;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_all_ass_rec(l_index).id = p_person_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_all_ass_rec(l_index).id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
    end if;
  --
  if g_cache_all_ass_rec(l_index).starttorele_num is not null then
    --
    for l_count in g_cache_all_ass_rec(l_index).starttorele_num..
       g_cache_all_ass_rec(l_index).endtorele_num loop
      --
      p_rec(p_rec.count+1) := g_cache_allass_rec(l_count);
      --
    end loop;
      --115.23 move out of loop, faster
      g_cache_last_allass_rec:=p_rec;
    --
  end if;
  --115.23 no need
  --p_rec := l_rec;
  --
  if g_debug then
    hr_utility.set_location('Leaving '||l_proc,10);
  end if;
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_allass_object(p_person_id         => p_person_id,
                      p_business_group_id => l_env.business_group_id,
                      p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                                 l_env.effective_date), */
                      p_rec               => p_rec);
    --
end get_allass_object;
--
procedure get_object(p_person_id      in  number,
                     p_rec            in out nocopy g_cache_typ_table) is
  --
  l_proc           varchar2(80) := g_package||'get_object typ';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            g_cache_typ_table;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  begin
    --
    if g_cache_last_typ_rec(1).person_id = p_person_id then
      --115.23 remove loop, do straight assignment
      --for l_count in g_cache_last_typ_rec.first..
        --g_cache_last_typ_rec.last loop
        --
        p_rec := g_cache_last_typ_rec;
        --
      --end loop;
      --
      return;
      --
    end if;
    --
  exception when others then
     null;
  end;
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_typ_per_rec(l_index).id = p_person_id then
      --
      null;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_typ_per_rec(l_index).id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
    end if;
  --
  if g_cache_typ_per_rec(l_index).starttorele_num is not null then
    --115.23 no need for delete, assign later
    --g_cache_last_typ_rec.delete;
    --
    for l_count in g_cache_typ_per_rec(l_index).starttorele_num..
       g_cache_typ_per_rec(l_index).endtorele_num loop
      --
      p_rec(p_rec.count+1) := g_cache_typ_rec(l_count);
      --
    end loop;
    --115.23 removed from loop, faster to directly assign
      g_cache_last_typ_rec:=p_rec;
  end if;
  --115.23 unnecessary
  --p_rec := l_rec;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_typ_object(p_person_id         => p_person_id,
                   p_business_group_id => l_env.business_group_id,
                   p_effective_date    => l_effective_date, /* FONM nvl(l_env.lf_evt_ocrd_dt,
                                              l_env.effective_date), */
                   p_rec               => p_rec);
    --
end get_object;
--
procedure get_bal_per_object
  (p_person_id      in  number,
   p_bnfts_bal_id   in  number,
   p_effective_date in  date,
   p_rec            in out nocopy ben_per_bnfts_bal_f%rowtype) is
  --
  l_proc           varchar2(80) := g_package||'get_bal_per_object';
  l_index          pls_integer;
  l_count          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  l_rec            ben_per_bnfts_bal_f%rowtype;
  l_start_index    pls_integer;
  l_end_index      pls_integer;
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return pps
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_bal_per_rec(l_index).id = p_person_id then
      --
            l_start_index := g_cache_bal_per_rec(l_index).starttorele_num;
            l_end_index := g_cache_bal_per_rec(l_index).endtorele_num;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_bal_per_rec(l_index).id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
            l_start_index := g_cache_bal_per_rec(l_index).starttorele_num;
            l_end_index := g_cache_bal_per_rec(l_index).endtorele_num;
      --
    end if;
    --
  --
  if l_start_index is null then
    --
    p_rec:=l_rec;
    --
  else
    --
    -- Lets loop through the rows and try and find a match
    --
    for l_count in l_start_index..l_end_index loop
      --
      if g_cache_bal_rec(l_count).bnfts_bal_id = p_bnfts_bal_id and
         p_effective_date
         between g_cache_bal_rec(l_count).effective_start_date
         and     g_cache_bal_rec(l_count).effective_end_date then
        --
        p_rec := g_cache_bal_rec(l_count);
        exit;
        --
      end if;
      --
    end loop;
    --
  end if;
  --
  -- hr_utility.set_location('Leaving '||l_proc,10);
  --
exception
  --
  when no_data_found then
    --
    fnd_message.set_name('BEN','BEN_92309_OBJECT_NOT_FOUND');
    fnd_message.set_token('PROC',l_proc);
    fnd_message.set_token('PERSON_ID',p_person_id);
    fnd_message.set_token('BNFTS_BAL_ID',p_bnfts_bal_id);
    fnd_message.set_token('EFFECTIVE_DATE',p_effective_date);
    fnd_message.raise_error;
    --
end get_bal_per_object;
--
procedure get_object(p_person_id  in  number,
                     p_rec        in out nocopy g_person_date_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'get_object pdi';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            g_person_date_info_rec;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_date_rec.person_id = p_person_id then
    --
    p_rec := g_cache_last_date_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_person_id,g_hash_key);
  --
    if g_cache_date_rec(l_index).person_id = p_person_id then
      --
      g_cache_last_date_rec := g_cache_date_rec(l_index);
      p_rec := g_cache_last_date_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_date_rec(l_index).person_id <> p_person_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_date_rec := g_cache_date_rec(l_index);
      p_rec := g_cache_last_date_rec;
      --
    end if;
    --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_per_dates_object(p_person_id         => p_person_id,
                         p_business_group_id => l_env.business_group_id,
                         p_effective_date    => l_effective_date, /* FONMnvl(l_env.lf_evt_ocrd_dt,
                                                    l_env.effective_date), */
                         p_rec               => p_rec);
    --
    g_cache_last_date_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure get_object(p_assignment_id in  number,
                     p_rec           in out nocopy g_person_fte_info_rec) is
  --
  l_proc           varchar2(80) := g_package||'get_object pfte';
  l_index          pls_integer;
  --l_not_hash_found boolean;
  l_env            ben_env_object.g_global_env_rec_type;
  --l_rec            g_person_fte_info_rec;
  -- FONM
  l_effective_date date;
  --
  --
begin
  --
  -- hr_utility.set_location('Entering '||l_proc,10);
  --
  if g_cache_last_fte_rec.assignment_id = p_assignment_id then
    --
    p_rec := g_cache_last_fte_rec;
    return;
    --
  end if;
  -- 1) Get hashed index
  -- 2) If hashed index is correct person_id then return assignment
  -- 3) If hashed index is not correct person_id then check next index
  -- 4) Repest 3 until correct person_id found, if not found raise error.
  --
  -- Get hashed index value
  --
  l_index := mod(p_assignment_id,g_hash_key);
  --
    if g_cache_fte_rec(l_index).assignment_id = p_assignment_id then
      --
      g_cache_last_fte_rec := g_cache_fte_rec(l_index);
      p_rec := g_cache_last_fte_rec;
      --
    else
      --
      -- We need to loop through all the hashed indexes
      -- if none exists at current index the NO_DATA_FOUND expection will fire
      --
      l_index := l_index+g_hash_jump;
      while g_cache_fte_rec(l_index).assignment_id <> p_assignment_id loop
        --
        l_index := l_index+g_hash_jump;
        --
      end loop;
      --
      g_cache_last_fte_rec := g_cache_fte_rec(l_index);
      p_rec := g_cache_last_fte_rec;
      --
    end if;
    --
exception
  --
  when no_data_found then
    --
    ben_env_object.get(p_rec => l_env);
    --
    -- FONM
    --
    l_effective_date := nvl(ben_manage_life_events.g_fonm_rt_strt_dt,
                            nvl(ben_manage_life_events.g_fonm_cvg_strt_dt,
                                nvl(l_env.lf_evt_ocrd_dt,l_env.effective_date))
                           );
    --
    set_per_fte_object(p_assignment_id     => p_assignment_id,
                       p_business_group_id => l_env.business_group_id,
                       p_effective_date    => l_effective_date, /* FONMnvl(l_env.lf_evt_ocrd_dt,
                                                  l_env.effective_date), */
                       p_rec               => p_rec);
    --
    g_cache_last_fte_rec := p_rec;
    --p_rec := l_rec;
    --
end get_object;
--
procedure clear_down_cache is
  --
  l_cache_last_per_rec per_all_people_f%rowtype;
  l_cache_last_ass_rec per_all_assignments_f%rowtype;
  l_cache_last_benass_rec per_all_assignments_f%rowtype;
  l_cache_last_ast_rec per_assignment_status_types%rowtype;
  l_cache_last_pps_rec per_periods_of_service%rowtype;
  l_cache_last_pad_rec per_addresses%rowtype;
  l_cache_last_pil_rec ben_per_in_ler%rowtype;
  l_cache_last_date_rec g_person_date_info_rec;
  l_cache_last_fte_rec g_person_fte_info_rec;
  l_cache_last_bal_rec ben_per_bnfts_bal_f%rowtype;
  l_cache_last_bnb_rec ben_bnfts_bal_f%rowtype;
  l_cache_last_hsc_rec hr_soft_coding_keyflex%rowtype;
  --
begin
  --
  g_cache_per_rec.delete;
  g_cache_ass_rec.delete;
  g_cache_benass_rec.delete;
  g_cache_app_ass_rec.delete;
  --RCHASE
  g_cache_appass_rec.delete;
  g_cache_allass_rec.delete;
  --RCHASE
  g_cache_all_ass_rec.delete;
  g_cache_ast_rec.delete;
  g_cache_aei_rec.delete;
  g_cache_pps_rec.delete;
  g_cache_pad_rec.delete;
  g_cache_pil_rec.delete;
  g_cache_bal_rec.delete;
  g_cache_bnb_rec.delete;
  g_cache_hsc_rec.delete;
  g_cache_bal_per_rec.delete;
  g_cache_con_rec.delete;
  g_cache_con_per_rec.delete;
  g_cache_typ_rec.delete;
  g_cache_typ_per_rec.delete;
  g_cache_date_rec.delete;
  g_cache_fte_rec.delete;
  --
  -- Clear last cache records
  --
  g_cache_last_con_rec.delete;
  g_cache_last_per_rec := l_cache_last_per_rec;
  g_cache_last_ass_rec := l_cache_last_ass_rec;
  g_cache_last_appass_rec.delete;
  g_cache_last_allass_rec.delete;
  g_cache_last_benass_rec := l_cache_last_benass_rec;
  g_cache_last_ast_rec := l_cache_last_ast_rec;
  g_cache_last_pps_rec := l_cache_last_pps_rec;
  g_cache_last_pad_rec := l_cache_last_pad_rec;
  g_cache_last_bnb_rec := l_cache_last_bnb_rec;
  g_cache_last_pil_rec := l_cache_last_pil_rec;
  g_cache_last_hsc_rec := l_cache_last_hsc_rec;
  g_cache_last_date_rec := l_cache_last_date_rec;
  g_cache_last_fte_rec := l_cache_last_fte_rec;
  g_cache_last_typ_rec.delete;
  --
end clear_down_cache;
--
procedure defrag_caches
is
  --
  l_cache_last_per_rec per_all_people_f%rowtype;
  l_cache_last_ass_rec per_all_assignments_f%rowtype;
  l_cache_last_benass_rec per_all_assignments_f%rowtype;
  l_cache_last_ast_rec per_assignment_status_types%rowtype;
  l_cache_last_pps_rec per_periods_of_service%rowtype;
  l_cache_last_pad_rec per_addresses%rowtype;
  l_cache_last_pil_rec ben_per_in_ler%rowtype;
  l_cache_last_date_rec g_person_date_info_rec;
  l_cache_last_fte_rec g_person_fte_info_rec;
  l_cache_last_bal_rec ben_per_bnfts_bal_f%rowtype;
  l_cache_last_bnb_rec ben_bnfts_bal_f%rowtype;
  l_cache_last_hsc_rec hr_soft_coding_keyflex%rowtype;
  --
begin
  --
  if g_cache_per_rec.count > 10
  then
    --
    clear_down_cache;
    --
  end if;
  --
end defrag_caches;
--
end ben_person_object;

/
