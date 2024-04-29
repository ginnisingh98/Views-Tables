--------------------------------------------------------
--  DDL for Package Body HRBISORGPARAMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRBISORGPARAMS" as
/* $Header: hrbistab.pkb 115.11 2004/06/16 06:07:00 prasharm ship $ */
  --
  -- Declare Package Globals
  --
  g_commit_count     NUMBER;
  --
  --------------------------------------------------------------------------
  --
  -- This procedure does a commit every 100 times it is called;
  --
  --------------------------------------------------------------------------
  --
  PROCEDURE CommitCount IS
  BEGIN
    if MOD(g_commit_count,100) = 0 THEN

      /* bug 1723733 HRI_ORG_PARAM_UK1 was being violated */
      /* added exception handler to write exception to conc. log file */
      begin
           COMMIT;
      exception
        when others then
          fnd_file.put_line(fnd_file.log,
            'HrBisOrgParams - Failed on Commit statement in CommitCount procedure: ');
          fnd_file.put_line(fnd_file.log,sqlerrm||' '||sqlcode);
      end;


    END IF;
    g_commit_count := g_commit_count + 1;
  END;
  --
  --------------------------------------------------------------------------
  --
  -- This function returns the next value on the sequence hri_org_param_s
  --
  --------------------------------------------------------------------------
  --
  function GetNextOrgParamID
  return Number is
    cursor c_next is
	  select hri_org_params_s.nextval
	  from   dual;

	l_org_param_id  hri_org_params.org_param_id%TYPE;

  begin
    open c_next;
	fetch c_next into l_org_param_id;
	close c_next;

	return l_org_param_id;
  end GetNextOrgParamID;
  --
  --------------------------------------------------------------------------
  --
  -- The GetOrgStructureID returns an organization_structure_id for a
  -- given org_structure_version_id
  --
  --------------------------------------------------------------------------
  --
  function GetOrgStructureID
    ( p_org_structure_version_id  IN  Number )
  return Number is
    cursor c_ost
      ( cp_osv_id  Number )
    is
      select osv.organization_structure_id
      from   per_org_structure_versions  osv
      where  osv.org_structure_version_id = cp_osv_id
      and    trunc(sysdate) between nvl(osv.date_from,trunc(sysdate)) and nvl(osv.date_to,sysdate);

    l_ost_id  per_organization_structures.organization_structure_id%TYPE;

  begin
    open c_ost (p_org_structure_version_id);
	fetch c_ost into l_ost_id;
	close c_ost;

	return l_ost_id;

  end GetOrgStructureID;
  --
  --------------------------------------------------------------------------
  --
  -- The function GetOrgStructureVersionID returns an
  -- organization_structure_version_id for a given org_structure_id.
  --
  --------------------------------------------------------------------------
  --
  function GetOrgStructureVersionID
    ( p_organization_structure_id  IN  Number )
  return Number is
    cursor c_osv
      ( cp_ost_id  Number )
    is
      select osv.org_structure_version_id
      from   per_organization_structures ost
      ,      per_org_structure_versions  osv
      where  ost.organization_structure_id = cp_ost_id
      and    ost.organization_structure_id = osv.organization_structure_id
      and    trunc(sysdate) between nvl(osv.date_from,trunc(sysdate)) and nvl(osv.date_to,sysdate);

    l_osv_id  per_org_structure_versions.org_structure_version_id%TYPE;

  begin
    open c_osv (p_organization_structure_id);
	fetch c_osv into l_osv_id;
	close c_osv;

	return l_osv_id;

  end GetOrgStructureVersionID;

----------------------------------------------------------------------------------------------

  function GetOrgParamID
  return Number is

    l_ost_id  		Number;
    l_org_param_id  	hri_org_params.org_param_id%TYPE := null;

  begin

-- Added by S.Bhattal, version 115.4, 01-OCT-1999
    l_ost_id := HrFastAnswers.GetReportingHierarchy;

    l_org_param_id := GetOrgParamID
      ( p_organization_structure_id => l_ost_id
      , p_organization_id           => -1
      , p_organization_process      => 'ISNR' );

    return (l_org_param_id);

  end GetOrgParamID;

----------------------------------------------------------------------------------------------

  function GetOrgParamID
    ( p_organization_structure_id  IN  Number
    , p_organization_id            IN  Number
    , p_organization_process       IN  Varchar2 )
  return Number is

    cursor c_toporg
      ( cp_ost_id  Number )
    is
      select ose.organization_id_parent
      from   per_organization_structures ost
      ,      per_org_structure_versions  osv
      ,      per_org_structure_elements  ose
      where  ost.organization_structure_id = cp_ost_id
      and    ost.organization_structure_id = osv.organization_structure_id
      and    osv.org_structure_version_id  = ose.org_structure_version_id
      and    trunc(sysdate) between nvl(osv.date_from,trunc(sysdate)) and nvl(osv.date_to,sysdate)
      and    not exists
               ( select null
                 from   per_org_structure_elements ose2
                 where  ose2.org_structure_version_id = osv.org_structure_version_id
                 and    ose.organization_id_parent    = ose2.organization_id_child );

	cursor c_prm
	  ( cp_ost_id  Number
	  , cp_org_id  Number
	  , cp_orgprc  Varchar2 )
	is
	  select bop.org_param_id
	  from   hri_org_params bop
	  where  bop.organization_structure_id = cp_ost_id
	  and    bop.organization_id           = cp_org_id
	  and    bop.organization_process      = cp_orgprc;

    l_ost_id        Number      := p_organization_structure_id;
    l_org_id        Number      := p_organization_id;
	l_orgprc        Varchar2(4) := p_organization_process;

	l_org_param_id  hri_org_params.org_param_id%TYPE := null;

  begin
    if (l_org_id = -1)
    then
      open c_toporg (l_ost_id);
      fetch c_toporg into l_org_id;
      close c_toporg;
      l_orgprc := 'IS'||substr(l_orgprc,3);
    end if;

    open c_prm (l_ost_id, l_org_id, l_orgprc);
	fetch c_prm into l_org_param_id;
	close c_prm;

	return l_org_param_id;

  end GetOrgParamID;

----------------------------------------------------------------------------------------------
  procedure LoadOrgHierarchy
    ( p_organization_structure_id  IN  Number
    , p_organization_id            IN  Number
    , p_organization_process       IN  Varchar2 )
  is
    ----------------------------------------------------------------------
    -- The following organization structure is used to illustarte examples
    -- at various points in this procedure:
    --
    --                    A
    --                   / \
    --                  B   C
    --                 / \
    --                D   E
    --                   / \
    --                  F   G
    --                 / \
    --                H   I
    --
    ----------------------------------------------------------------------
    -- For a given organization_structure_version_id,
    -- organization_id this cursor will
    -- return different rows depending on the process(ISNR,ISRO,SINR,SIRO).
    --
    -- Examples:
    -- ---------
    -- 1- For a given organization_structure_version_id pointing to the
    -- above org structure with an organization_id of E and process ISNR
    -- the following organization_id_start values
    -- will be returned by this cursor: E,F,G,H,I
    --
    -- 2- For a given organization_structure_version_id pointing to the
    -- above org structure with an organization_id of E and process ISRO
    -- the following organization_id_start values
    -- will be returned by this cursor: E,F,G,H,I
    --
    -- 3- For a given organization_structure_version_id pointing to the
    -- above org structure with an organization_id of E and process SINR
    -- the following organization_id_start values
    -- will be returned by this cursor: E
    --
    -- 4- For a given organization_structure_version_id pointing to the
    -- above org structure with an organization_id of E and process SIRO
    -- the following organization_id_start values
    -- will be returned by this cursor: E
    --
    -----------------------------------------------------------------------
    --
    cursor c_main
      ( cp_org_structure_version_id  Number
      , cp_organization_id           Number
      , cp_organization_process      Varchar2 )
    is
      select TREE.organization_id_start
      from   hr_all_organization_units org -- cbridge 05-DEC-2000 115.6
      ,     (select  ele.organization_id_parent organization_id_start
             from    per_org_structure_elements ele
             where   ele.org_structure_version_id = cp_org_structure_version_id
             and     cp_organization_process in ('ISNR', 'ISRO')
             connect by prior ele.organization_id_child = ele.organization_id_parent
               and ele.org_structure_version_id = cp_org_structure_version_id
             start with ele.organization_id_parent = cp_organization_id
                   and  ele.org_structure_version_id = cp_org_structure_version_id) TREE
      where  TREE.organization_id_start = org.organization_id
      UNION
      select TREE.organization_id_start
      from   hr_all_organization_units org -- cbridge 05-DEC-2000 115.6
      ,     (select ele.organization_id_child organization_id_start
             from   per_org_structure_elements ele
             where  ele.org_structure_version_id = cp_org_structure_version_id
             and    cp_organization_process in ('ISNR', 'ISRO')
             connect by prior ele.organization_id_child = ele.organization_id_parent
               and ele.org_structure_version_id = cp_org_structure_version_id
             start with ele.organization_id_parent = cp_organization_id
                   and  ele.org_structure_version_id = cp_org_structure_version_id) TREE
      where  TREE.organization_id_start = org.organization_id
      UNION
      select org.organization_id organization_id_start
      from   hr_all_organization_units org -- cbridge 05-DEC-2000 115.6
      where  org.organization_id = cp_organization_id
      order by 1;
    -----------------------------------------------------------------------
    --
    -- This cursor will for a given organization_structure_version_id, and
    -- organization_id_start this cursor will return different rows depending on the process_id
    --
    -- Examples:
    -- ---------
    -- 1- For a given organization_structure_version_id pointing to the above
    -- org structure with an organization_id_start of E and process ISNR the
    -- following organization_id_start values
    -- will be returned by this cursor: E
    --
    -- 2- For a given organization_structure_version_id pointing to the above
    -- org structure with an organization_id_start of E and process ISRO the
    -- following organization_id_start values
    -- will be returned by this cursor: E,F,G,H,I
    --
    -- 3- For a given organization_structure_version_id pointing to the above
    -- org structure with an organization_id_start of E and process SINR the
    -- following organization_id_start values
    -- will be returned by this cursor: E
    --
    -- 4- For a given organization_structure_version_id pointing to the above
    -- org structure
    -- with an organization_id_start of E and process SIRO the following
    -- organization_id_start values
    -- will be returned by this cursor: E,F,G,H,I
    --
    -----------------------------------------------------------------------
    --
    cursor c_child
      ( cp_org_structure_version_id  Number
      , cp_organization_id_start     Number
      , cp_organization_process      Varchar2 )
    is
      select TREE.organization_id_group
      ,      TREE.organization_id_child
      from   hr_all_organization_units org -- cbridge 05-DEC-2000 115.6
      ,     (select cp_organization_id_start  organization_id_group
             ,      ele.organization_id_child organization_id_child
             from   per_org_structure_elements ele
             where  ele.org_structure_version_id = cp_org_structure_version_id
             and    cp_organization_process in ('SIRO', 'ISRO')
             connect by prior ele.organization_id_child = ele.organization_id_parent
   -- JTitmas Bug# 1296567 Altered line below to keep query in same hierarchy
               and prior ele.org_structure_version_id = ele.org_structure_version_id
             start with ele.organization_id_parent = cp_organization_id_start
                   and  ele.org_structure_version_id = cp_org_structure_version_id) TREE
      where  TREE.organization_id_child = org.organization_id
      UNION
      select org.organization_id organization_id_group
      ,      org.organization_id organization_id_child
      from   hr_all_organization_units org -- cbridge 05-DEC-2000 115.6
      where  org.organization_id = cp_organization_id_start
      order by 1,2;
    --
    l_osv_id   Number       := GetOrgStructureVersionID (p_organization_structure_id);
    l_org_id   Number       := p_organization_id;
    l_orgprc   Varchar2(4)  := p_organization_process;
    --
    l_org_param_id  hri_org_params.org_param_id%TYPE;
    --
  begin
    --
    --------------------------------------------------------------------
    --
    -- This call to GetNextOrgParamID gets the next org param id from the
    -- sequence hri_org_params_s to be used as a primary key for the master
    -- table hri_org_params and part of primary key for the detail table
    -- hri_org_param_list
    --
    --------------------------------------------------------------------
    --
    l_org_param_id := GetNextOrgParamID;
    --
    --------------------------------------------------------------------
    --
    -- Create the master record in hri_org_params
    --
    --------------------------------------------------------------------
    --

    /* bug 1723733 HRI_ORG_PARAM_UK1 was being violated */
    /* added exception handler to write exception to conc. log file */

    begin

      insert into hri_org_params
        ( org_param_id
        , organization_structure_id
        , organization_id
        , organization_process )
        values
        ( l_org_param_id
        , p_organization_structure_id
        , p_organization_id
        , p_organization_process );

    exception
         when others then
          fnd_file.put_line(fnd_file.log,
              '----------------------------------------------------------- ');
          fnd_file.put_line(fnd_file.log,
            'HrBisOrgParams - Failed on insert into hri_org_params table: ');
          fnd_file.put_line(fnd_file.log,sqlerrm||' '||sqlcode);
          fnd_file.put_line(fnd_file.log,'org_param_id = '|| l_org_param_id);
          fnd_file.put_line(fnd_file.log,'organization_structure_id = '
                                          || p_organization_structure_id);
          fnd_file.put_line(fnd_file.log,'organization_id = '
                                          || p_organization_id);
          fnd_file.put_line(fnd_file.log,'organization_process = '
                                          || p_organization_process);
          fnd_file.put_line(fnd_file.log,
                '----------------------------------------------------------- ');
    end;

    --
    CommitCount;

    --
    ----------------------------------------------------------------------------
    --
    -- As described above the values returned by the following cursor (c_main)
    -- depend on the process (ISNR,ISRO,SINR,SIRO).  For a given
    -- org_structure_version_id and an organization_id of E based on the
    -- example above the values returned by the cursor will be:
    -- EFGHI, EFGHI, E, E respectively
    -- (depending on whether ISNR,ISRO,SINR,SIRO).
    --
    ----------------------------------------------------------------------------
    --
    for r_main in c_main
      ( l_osv_id, l_org_id, l_orgprc )
    loop
      --
      --------------------------------------------------------------------------
      --
      -- As described above the values returned by the following cursor
      -- (c_child) depend on the process (ISNR,ISRO,SINR,SIRO).  For a given
      -- org_structure_version_id and an organization_id_start
      -- of E based on the example above the organization_id_group returned by
      -- the cursor will be E and
      -- the organization_id_child will be:
      -- E, EFGHI, E, EFGHI respectively
      -- (depending on whether ISNR,ISRO,SINR,SIRO).
      --
      --------------------------------------------------------------------------
      --
      for r_child in c_child
        ( l_osv_id, r_main.organization_id_start, l_orgprc )
      loop
        --
        ------------------------------------------------------------------------
        --
        -- Insert the organization_id_group and organization_id_child into the
        -- hri_org_Param_list table.
        --
        ------------------------------------------------------------------------
        --

       /* bug 1723733  */
       /* added exception handler to write exception to conc. log file */

        begin
          insert into hri_org_param_list
		  ( org_param_id
		  , organization_id_group
		  , organization_id_child )
		values
                  ( l_org_param_id
		  , r_child.organization_id_group
                  , r_child.organization_id_child );
        exception
          when others then
            fnd_file.put_line(fnd_file.log,
                '----------------------------------------------------------- ');
            fnd_file.put_line(fnd_file.log,
              'HrBisOrgParams - Failed on insert into hri_org_param_list table: ');
            fnd_file.put_line(fnd_file.log,sqlerrm||' '||sqlcode);
            fnd_file.put_line(fnd_file.log,'org_param_id = ' || l_org_param_id);
            fnd_file.put_line(fnd_file.log,'organization_id_group = ' ||
                              r_child.organization_id_group);
            fnd_file.put_line(fnd_file.log,'organization_id_child = ' ||
                               r_child.organization_id_child);
            fnd_file.put_line(fnd_file.log,
                '----------------------------------------------------------- ');

        end;

        --
        CommitCount;

      end loop;
    end loop;

  end LoadOrgHierarchy;
  --
  --------------------------------------------------------------------------
  --
  -- This procedure is the main entry point to this package.  This procedure
  -- will need to be called by the concurrent manager on a regular basis or
  -- every time the organisation hierarchy is changed. The purpose of this
  -- procedure is to populate the hri_org_params and hri_org_param_list tables
  -- which are used in many HRMS BIS reports to select organisation
  -- hierarchies.
  --
  --------------------------------------------------------------------------
  --
  procedure LoadAllHierarchies
  is
    --
    -- The following cursor selects all Parent organisations
    -- (i.e. organisations at the top of
    -- the tree for each organisation structure version)
    --
    cursor c_hierarchies is
      select distinct
             ost.organization_structure_id  ost_id
      ,      ose.organization_id_parent     top_org_id
      ,      ose.org_structure_version_id   ver_id
      from   per_organization_structures ost
      ,      per_org_structure_versions  osv
      ,      per_org_structure_elements  ose
      where  ost.organization_structure_id = osv.organization_structure_id
      and    osv.org_structure_version_id  = ose.org_structure_version_id
      and    trunc(sysdate) between nvl(osv.date_from,trunc(sysdate)) and nvl(osv.date_to,sysdate)
      and    not exists
               ( select null
                 from   per_org_structure_elements ose2
                 where  ose2.org_structure_version_id = osv.org_structure_version_id
                 and    ose.organization_id_parent    = ose2.organization_id_child );
    --
    -- This cursor has org_structure_version_id passed into cp_ost_id and a
    -- top org (decribed in comment above) passed into cp_org_id This cursor
    -- returns the top level parent id passed in along with all child records
    -- for the parent/org_structure_version_id
    --
    cursor c_elements
      ( cp_ost_id  Number
  	  , cp_org_id  Number )
    is
      select organization_id_child  organization_id
      from   per_org_structure_elements
      where  org_structure_version_id = cp_ost_id
      UNION
      select organization_id
      from   hr_all_organization_units	-- S.Bhattal, 18-AUG-99, 115.2 -- cbridge 05-DEC-2000 115.6
      where  organization_id = cp_org_id;
    --
    --
      l_sql_stmt                   VARCHAR2(2000);
      l_dummy1                     VARCHAR2(2000);
      l_dummy2                     VARCHAR2(2000);
      l_schema                     VARCHAR2(400);
    --
  begin
    --
    -- Empty Org Hierarchy tables before re-creating data in them.
    --
    -- Bug 3658446 used truncate in place of delete
    --
    IF fnd_installation.get_app_info('HRI',l_dummy1, l_dummy2, l_schema) THEN
       --
       -- delete from hri_org_param_list;
       l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_ORG_PARAM_LIST';
       EXECUTE IMMEDIATE(l_sql_stmt);
       --
       -- delete from hri_org_params;
       l_sql_stmt := 'TRUNCATE TABLE ' || l_schema || '.HRI_ORG_PARAMS';
       EXECUTE IMMEDIATE(l_sql_stmt);
       --
    END IF;
    --
    -- Set the commit count to 0 so that a commit will be done for every 100 inserts
    --
    g_commit_count := 0;
    --
    -- This cursor (described above) will return 1 row for each top level
    -- organization for each org structure verion id
    --
    for r_hierarchies in c_hierarchies
    loop
      --
      --
      -- The c_elements cursor (described above) returns a row for the top
      -- level organization identified in the c_hierarchies cursor and all
      -- it's child organizations for the given org_structure_version_id
      --
      for r_elements in c_elements
        (r_hierarchies.ver_id, r_hierarchies.top_org_id)
      loop
        --
        -- The following calls to LoadOrgHierarchy are to populate the tables:
        --     hri_org_param_list
        --     hri_org_params
        -- For each row returned by the c_elements cursor a call is made to the
        -- LoadOrgHierarchy procedure for each different type of organization
        -- process (SINR, ISNR, SIRO, ISRO).
        -- These process types are described below.
        --
        -- The following examples are based on the Org structure defined below:
        --
        --                    A
        --                   / \
        --                  B   C
        --                 / \
        --                D   E
        --                   / \
        --                  F   G
        --                 / \
        --                H   I
        --
        --
        --
        -- SINR (Single Instance No Rollup)
        -- --------------------------------
        -- SINR for organization A is basically just A on it's own with none of
        -- A's sub organizations rolled into it.
        -- This should result in something like the following records being
        -- inserted into our org tables (N.B. These are not supposed to be
        -- exact records as I am using letters in place of numbers):
        --
        -- hri_org_params:
        -- +-------------+-------------------------+---------------+---------+
        -- |ORG_PARAM_ID |ORGANIZATION_STRUCTURE_ID|ORGANIZATION_ID| PROCESS |
        -- +-------------+-------------------------+---------------+---------+
        -- |33 (for e.g.)|3(for e.g.)              | A             | SINR    |
        -- +-------------+-------------------------+---------------+---------+
        --
        -- hri_org_param_list:
        -- +-------------+---------------------+---------------------+
        -- |ORG_PARAM_ID |ORGANIZATION_ID_GROUP|ORGANIZATION_ID_CHILD|
        -- +-------------+---------------------+---------------------+
        -- | 33          | A                   | A                   |
        -- +-------------+---------------------+---------------------+
        --
        --
        LoadOrgHierarchy
     	  ( r_hierarchies.ost_id
     	  , r_elements.organization_id
     	  , 'SINR');
        --
        --
        -- ISNR (Include Subordinates No Rollup)
        -- -------------------------------------
        -- ISNR for organization A is A, and all of it's sub organizations
        -- B,C,D,E,F,G,H,I
        -- reported seperately.
        -- This should result in something like the following records being
        -- inserted into our org tables (N.B. These are not supposed to be exact
        -- records as I am using letters in place of numbers):
        --
        -- hri_org_params:
        -- +-------------+-------------------------+---------------+---------+
        -- |ORG_PARAM_ID |ORGANIZATION_STRUCTURE_ID|ORGANIZATION_ID| PROCESS |
        -- +-------------+-------------------------+---------------+---------+
        -- |34 (for e.g.)|3(for e.g.)              | A             | ISNR    |
        -- +-------------+-------------------------+---------------+---------+
        --
        -- hri_org_param_list:
        -- +-------------+---------------------+---------------------+
        -- |ORG_PARAM_ID |ORGANIZATION_ID_GROUP|ORGANIZATION_ID_CHILD|
        -- +-------------+---------------------+---------------------+
        -- | 34          | A                   | A                   |
        -- | 34          | B                   | B                   |
        -- | 34          | C                   | C                   |
        -- | 34          | D                   | D                   |
        -- | 34          | E                   | E                   |
        -- | 34          | F                   | F                   |
        -- | 34          | G                   | G                   |
        -- | 34          | H                   | H                   |
        -- | 34          | I                   | I                   |
        -- +-------------+---------------------+---------------------+
        --
        --
        LoadOrgHierarchy
    	  ( r_hierarchies.ost_id
    	  , r_elements.organization_id
    	  , 'ISNR');
        --
        --
        -- SIRO (Single Instance Rollup)
        -- -------------------------------------
        -- SIRO for organization A is A, and all of it's sub organizations
        -- B,C,D,E,F,G,H,I
        -- figures included in any calculations for A.
        --
        -- This should result in something like the following records being
        -- inserted into our org tables (N.B. These are not supposed to be exact
        -- records as I am using letters in place of numbers):
        --
        -- hri_org_params:
        -- +-------------+-------------------------+---------------+---------+
        -- |ORG_PARAM_ID |ORGANIZATION_STRUCTURE_ID|ORGANIZATION_ID| PROCESS |
        -- +-------------+-------------------------+---------------+---------+
        -- |35 (for e.g.)|3(for e.g.)              | A             | ISNR    |
        -- +-------------+-------------------------+---------------+---------+
        --
        -- hri_org_param_list:
        -- +-------------+---------------------+---------------------+
        -- |ORG_PARAM_ID |ORGANIZATION_ID_GROUP|ORGANIZATION_ID_CHILD|
        -- +-------------+---------------------+---------------------+
        -- | 35          | A                   | A                   |
        -- | 35          | A                   | B                   |
        -- | 35          | A                   | C                   |
        -- | 35          | A                   | D                   |
        -- | 35          | A                   | E                   |
        -- | 35          | A                   | F                   |
        -- | 35          | A                   | G                   |
        -- | 35          | A                   | H                   |
        -- | 35          | A                   | I                   |
        -- +-------------+---------------------+---------------------+
        --
        --
        LoadOrgHierarchy
    	  ( r_hierarchies.ost_id
    	  , r_elements.organization_id
    	  , 'SIRO');
        --
        --
        -- ISRO (Include Subordinates Rollup)
        -- -------------------------------------
        -- ISRO for organization A is A, and all of it's sub organizations
        -- B,C,D,E,F,G,H,I
        -- figures included in any calculations for A, B and all of it's sub
        -- organizations D,E,F,G,H,I included in any of the calculations for B,
        -- C and all of it's sub
        -- organizations (of which it has none) included in the calculation
        -- for C and so on.
        --
        -- This should result in something like the following records being
        -- inserted into our org tables (N.B. These are not supposed to be exact
        -- records as I am using letters in place of numbers):
        --
        -- hri_org_params:
        -- +-------------+-------------------------+---------------+---------+
        -- |ORG_PARAM_ID |ORGANIZATION_STRUCTURE_ID|ORGANIZATION_ID| PROCESS |
        -- +-------------+-------------------------+---------------+---------+
        -- |35 (for e.g.)|3(for e.g.)              | A             | ISNR    |
        -- +-------------+-------------------------+---------------+---------+
        --
        -- hri_org_param_list:
        -- +-------------+---------------------+---------------------+
        -- |ORG_PARAM_ID |ORGANIZATION_ID_GROUP|ORGANIZATION_ID_CHILD|
        -- +-------------+---------------------+---------------------+
        -- | 35          | A                   | A                   |
        -- | 35          | A                   | B                   |
        -- | 35          | A                   | C                   |
        -- | 35          | A                   | D                   |
        -- | 35          | A                   | E                   |
        -- | 35          | A                   | F                   |
        -- | 35          | A                   | G                   |
        -- | 35          | A                   | H                   |
        -- | 35          | A                   | I                   |
        -- | 35          | B                   | B                   |
        -- | 35          | B                   | D                   |
        -- | 35          | B                   | E                   |
        -- | 35          | B                   | F                   |
        -- | 35          | B                   | G                   |
        -- | 35          | B                   | H                   |
        -- | 35          | B                   | I                   |
        -- | 35          | C                   | C                   |
        -- | 35          | D                   | D                   |
        -- | 35          | E                   | E                   |
        -- | 35          | E                   | F                   |
        -- | 35          | E                   | G                   |
        -- | 35          | E                   | H                   |
        -- | 35          | E                   | I                   |
        -- | 35          | F                   | F                   |
        -- | 35          | F                   | H                   |
        -- | 35          | F                   | I                   |
        -- | 35          | G                   | G                   |
        -- +-------------+---------------------+---------------------+
        --
        --
        LoadOrgHierarchy
    	  ( r_hierarchies.ost_id
    	  , r_elements.organization_id
    	  , 'ISRO');
      end loop;

    end loop;

    commit;

  end LoadAllHierarchies;

  --
  -- Overloaded version of LoadAllHierarchies
  -- The purpose of this version is to be called from
  -- the Concurrent Manager.
  --
  procedure LoadAllHierarchies
    ( errbuf                       OUT NOCOPY Varchar2
    , retcode                      OUT NOCOPY Number )
  is
  begin
    errbuf := null;
    retcode := null;
    --
    LoadAllHierarchies;
    --
  exception
    when Others then
      --
      errbuf  := sqlerrm;
      retcode := sqlcode;
      --
      delete from hri_org_param_list;
      --
      delete from hri_org_params;
      --
      fnd_file.put_line(fnd_file.log,sqlerrm||' '||sqlcode);
      --
  end LoadAllHierarchies;

----------------------------------------------------------------------------------------------
  function OrgInHierarchy
    ( p_org_param_id               IN  Number
    , p_organization_id_group      IN  Number
    , p_organization_id_child      IN  Number )
  return Number is
    cursor c_opl
      ( cp_org_param_id           Number
      , cp_organization_id_group  Number
      , cp_organization_id_child  Number )
    is
      select 1
      from   hri_org_param_list opl
      where  opl.org_param_id = cp_org_param_id
      and    opl.organization_id_group = cp_organization_id_group
      and    opl.organization_id_child = cp_organization_id_child;

    l_found  Number;
    l_organization_id_group Number := p_organization_id_group;

  begin
    if p_organization_id_group = -1 THEN
      l_organization_id_group := p_organization_id_child;
    end if;
    --
    open c_opl
      ( p_org_param_id
      , l_organization_id_group
      , p_organization_id_child );
    fetch c_opl into l_found;

    if (c_opl%notfound) then
      l_found := 0;
    end if;

    close c_opl;

    return (l_found);

  end OrgInHierarchy;

----------------------------------------------------------------------------------------------
end HrBisOrgParams;

/
