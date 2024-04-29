--------------------------------------------------------
--  DDL for Package FND_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RELEASE" AUTHID CURRENT_USER as
/* $Header: AFINRELS.pls 120.3.12000000.1 2007/01/18 13:20:28 appldev ship $ */


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
  --

  function get_release (release_name       out nocopy varchar2,
                        other_release_info out nocopy varchar2)
  return boolean;

  pragma restrict_references (get_release, wnds);

  --
  -- returns the result of the initialization.
  -- see get_release.
  --
  function result return boolean;

  pragma restrict_references (result, wnds);

  --
  -- returns the release_name returned by get_release
  -- will return null if no rows exist in fnd_product_groups.
  --
  function release_name return varchar2;

  pragma restrict_references (release_name, wnds);

  --
  -- returns the release_info returned by get_release
  -- will return null if no rows exist in fnd_product_groups
  -- or no additional information exists in release_name.
  --
  function release_info return varchar2;

  pragma restrict_references (release_info, wnds);

  --
  -- returns the major version number of the release_name
  -- if an error occurs while parsing the release_name,
  -- this value and minor_version will both be 0 and
  -- point_version will be the sqlcode
  --
  function major_version return integer;

  pragma restrict_references (major_version, wnds);

  --
  -- returns the minor version number of the release_name
  -- if an error occurs while parsing the release_name,
  -- this value and major_version will both be 0 and
  -- point_version will be the sqlcode
  --
  function minor_version return integer;

  pragma restrict_references (minor_version, wnds);

  --
  -- returns the point version number of the release_name
  -- if an error occurs while parsing the release_name,
  -- this value will contain the sqlcode and
  -- both major_version and minor_version will be 0.
  --
  function point_version return integer;

  pragma restrict_references (point_version, wnds);


end fnd_release;

 

/
