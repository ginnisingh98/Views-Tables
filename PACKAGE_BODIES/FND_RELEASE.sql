--------------------------------------------------------
--  DDL for Package Body FND_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RELEASE" as
/* $Header: AFINRELB.pls 120.3.12000000.1 2007/01/18 13:20:27 appldev ship $ */


  -- cached result
  --
  z_result    boolean := false;

  -- cached release_name
  --
  z_release_name fnd_product_groups.release_name%type;

  -- cached release_info
  --
  z_release_info fnd_product_groups.release_name%type;

  -- cached major version number
  -- e.g. release '11.5.10', the point release is 11
  --
  z_major_version integer;

  -- cached minor version number
  -- e.g. release '11.5.10', the minor release is 5
  --
  z_minor_version integer;

  -- cached point version number
  -- e.g. release '11.5.10', the point release is 10
  --
  z_point_version integer;


  UNKNOWN constant varchar2(7) := 'Unknown';

  --
  -- Public Functions
  --

  function get_release (release_name       out nocopy varchar2,
                        other_release_info out nocopy varchar2)
  return boolean is

    cursor get_rel_cursor is
      select release_name
       from fnd_product_groups
      order by product_group_id;

    first_space number;

    l_name fnd_product_groups.release_name%type := null;
    l_info fnd_product_groups.release_name%type := null;

  begin

    -- return cached values if available
    if z_result then
      release_name := z_release_name;
      other_release_info := z_release_info;
      return z_result;
    end if;

    --
    -- get_release() will usually return TRUE
    --  with RELEASE_NAME =
    --                    contents of RELEASE_NAME column in FND_PRODUCT_GROUPS
    --  and OTHER_RELEASE_INFO = null
    --
    -- If FND_PRODUCT_GROUPS.RELEASE_NAME contains imbedded spaces:
    --
    -- get_release() will return TRUE
    --  with RELEASE_NAME = FND_PRODUCT_GROUPS.RELEASE_NAME up to but
    --   not including the first imbedded space
    --  and OTHER_RELEASE_INFO = FND_PRODUCT_GROUPS.RELEASE_NAME
    --   starting with the first non-space character after the first
    --   imbedded space
    --
    -- On failure, get_release() returns FALSE. This will be a performance issue.
    --  Both RELEASE_NAME and OTHER_RELEASE_INFO will be set to 'Unknown'.
    --  This indicates that either:
    --  1) there are no rows in fnd_product_groups
    --     - this can be resolved by populating the row and it will
    --       be queried on the next call.
    --  2) there is more than one row in fnd_product_groups
    --     - delete all but the one correct row from fnd_product_groups and it
    --       will be queried on the next call. It's possible that the values
    --       returned by release_* and *_version routines are still correct if
    --       the first row in fnd_product_groups, ordered by product_group_id,
    --       if the currect row, but this will still be a performance problem.

    release_name := UNKNOWN;
    other_release_info := UNKNOWN;

    open get_rel_cursor;
    fetch get_rel_cursor into l_name;
    z_result := get_rel_cursor%found;

    if z_result then

      -- If we got this far, we got at least one row from FPG
      -- split returned value into release name and other info

      -- remove leading and trailing blanks, if any

      l_name := rtrim(ltrim(l_name, ' '),' ');

      -- Find first space

      first_space := instr(l_name,' ');

      if first_space > 0 then
        -- There is extra info
        l_info := ltrim(substr(l_name, first_space + 1),' ');
        l_name := substr(l_name, 1, first_space - 1);
      end if;

      -- success: return values computed above
      z_release_name := l_name;
      z_release_info := l_info;

      -- Check for multiple rows in FPG

      declare
        l_temp fnd_product_groups.release_name%type := null;
      begin
        fetch get_rel_cursor into l_temp;
        -- return false if fetched another row
        z_result := get_rel_cursor%notfound;
      end;

      -- only populate the out parameters if one row exists
      if z_result then
        release_name := l_name;
        other_release_info := l_info;
      end if;

    end if;
    close get_rel_cursor;

    -- dbms_output.put_line( 'exiting get_release(): should not reach here');
    return(z_result);

  exception
    when others then
      -- dbms_output.put_line( 'exiting get_release() with following error:');
      -- dbms_output.put_line( sqlerrm );
      return(false);

  end get_release;

  --
  -- private initializer
  --
  procedure initialize is
    l_temp boolean;
    l_name fnd_product_groups.release_name%type := null;
    l_info fnd_product_groups.release_name%type := null;
  begin
    l_temp := get_release(l_name,l_info);
  end initialize;

  --
  -- returns cached result
  --
  function result
  return boolean is
  begin
    if not z_result then
      initialize;
    end if;
    return z_result;
  end result;

  --
  -- returns the release_name returned by get_release
  --
  function release_name
  return varchar2 is
  begin
    if not z_result then
      initialize;
    end if;
    return z_release_name;
  end release_name;

  --
  -- returns the release_info returned by get_release
  --
  function release_info
  return varchar2 is
  begin
    if not z_result then
      initialize;
    end if;
    return z_release_info;
  end release_info;

  --
  -- private routine to parse the release_name into major, minor and point
  -- always popuates major, minor and point releases.
  -- e.g.
  --   11 results in in major=11, minor=0, point=0
  --   11.5 results in in major=11, minor=5, point=0
  --   11.5.10 results in in major=11, minor=5, point=10
  --   parse error results in major=0, minor=0, point=sqlcode
  --

  procedure initialize_versions
  is
    first integer;
    second integer;
    third integer;
    t_release fnd_product_groups.release_name%type := z_release_name;
  begin
    -- initialize if needed
    if t_release is null then
      -- needs to be initialized
      t_release := release_name;
      if t_release is null then
        return;
      end if;
    end if;

    -- pad just in case there aren't enough dots.
    -- avoids checking return of instr and defaults
    -- missing fields to zero.
    t_release := t_release||'.0.0.0';

    -- find major.minor
    first := instr(t_release,'.',1,1);

    -- find minor.point
    second := instr(t_release,'.',1,2);

    -- find point
    third := instr(t_release,'.',1,3);

    z_major_version := to_number(substr(t_release,1,first-1));
    z_minor_version := to_number(substr(t_release,first+1,second-first-1));
    z_point_version := to_number(substr(t_release,second+1,third-second-1));

  exception
    when others then
      z_point_version := sqlcode;
      z_major_version := 0;
      z_minor_version := 0;
  end initialize_versions;

  --
  -- returns the major version number of the release_name
  --
  function major_version
  return integer is
  begin
    if z_major_version is null then
      initialize_versions;
    end if;
    return z_major_version;
  end major_version;

  --
  -- returns the minor version number of the release_name
  --
  function minor_version
  return integer is
  begin
    if z_minor_version is null then
      initialize_versions;
    end if;
    return z_minor_version;
  end minor_version;

  --
  -- returns the point version number of the release_name
  --
  function point_version
  return integer is
  begin
    if z_point_version is null then
      initialize_versions;
    end if;
    return z_point_version;
  end point_version;


end fnd_release;

/
