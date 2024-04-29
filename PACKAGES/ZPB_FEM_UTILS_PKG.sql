--------------------------------------------------------
--  DDL for Package ZPB_FEM_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_FEM_UTILS_PKG" AUTHID CURRENT_USER AS
/* $Header: ZPBVFEMS.pls 120.4 2007/12/04 14:39:23 mbhat noship $ */

----------------------------------------------------------------------------
-- GET_MEMBER_NAME
--
-- Returns a member's name and description given the dimension ID, member ID
-- and member valueset.  User primarily for views
--
-- IN: p_dimension_id - The FEM dimension ID
--     p_member_id    - The member ID
--     p_valueset_id  - The member valueset ID
--
-- OUT: The translated (to current language) name of the member
----------------------------------------------------------------------------
function GET_MEMBER_NAME (p_dimension_id   NUMBER,
                          p_member_id      VARCHAR2,
                          p_valueset_id    NUMBER)
   return VARCHAR2;

----------------------------------------------------------------------------
-- GET_MEMBER_DESC
--
-- Returns a member's description and description given the dimension ID,
-- member ID and member valueset.  User primarily for views
--
-- IN: p_dimension_id - The FEM dimension ID
--     p_member_id    - The member ID
--     p_valueset_id  - The member valueset ID
--
-- OUT: The translated (to current language) description of the member
----------------------------------------------------------------------------
function GET_MEMBER_DESC (p_dimension_id   NUMBER,
                          p_member_id      VARCHAR2,
                          p_valueset_id    NUMBER)
   return VARCHAR2;

----------------------------------------------------------------------------
-- GET_MEMBERS
--
-- Returns the name, description pair of the dimension members in the given
-- dimension.  Expected to be used via a TABLE function call.  Function is
-- pipelined
--
-- IN: p_dimension_id    - The IF of the dimension to get the members from
--
-- OUT: ZPB_MEMBER_TABLE_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_MEMBERS (p_dimension_id   NUMBER)
   return ZPB_MEMBER_TABLE_T PIPELINED;

----------------------------------------------------------------------------
-- GET_VARCHAR_MEMBERS
--
-- Same as GET_MEMBERS, but returns the members with varchar ID's
--
-- IN: p_dimension_id    - The IF of the dimension to get the members from
--
-- OUT: ZPB_MEMBER_TABLE_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_VARCHAR_MEMBERS (p_dimension_id   NUMBER)
   return ZPB_VAR_MEMBER_TABLE_T PIPELINED;

----------------------------------------------------------------------------
-- GET_FEM_HIER_MEMBERS
--
-- Returns the name, description of the top level hierarchy members
--
-- IN: p_hier_vers_id - The hierarchy version ID
-- OUT: ZPB_MEMBER_TABLE_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_TOP_HIER_MEMBERS (p_hier_vers_id   IN NUMBER)
   return ZPB_MEMBER_TABLE_T PIPELINED;

----------------------------------------------------------------------------
-- GET_BUSAREA_HIERARCHIES
--
-- Returns the different hierarchy ID's, version IDs, and whether the
-- version should be considered the "effective" version.  Function is
-- pipelined
--
-- IN: p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
-- OUT: ZPB_HIER_VERS_T - each dimension member, description pair
----------------------------------------------------------------------------
function GET_BUSAREA_HIERARCHIES(p_business_area IN number := null,
                                 p_version_type  IN VARCHAR2 := 'P')
   return ZPB_HIER_VERS_T PIPELINED;

----------------------------------------------------------------------------
-- GET_HIERARCHY_MEMBERS
--
-- Returns the hierarchy (and hier version) member information for a given
-- dimension.  You must call INIT_HIER_MEMBER_CACHE before you call this
-- function!
--
-- IN: p_logical_dim_id  - The logical dimension ID to get the hier members for
--       (Replaced p_dimension_id with p_logical_dim_id for "Consistent Dimension"
--     p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
-- OUT: ZPB_HIER_MEMBER_T - each hierarchy node information
----------------------------------------------------------------------------
function GET_HIERARCHY_MEMBERS(p_logical_dim_id  IN NUMBER,
                               p_business_area IN NUMBER := null,
                               p_version_type  IN VARCHAR2 := 'P')
   return ZPB_HIER_MEMBER_T PIPELINED;

----------------------------------------------------------------------------
-- GET_LIST_DIM_MEMBERS
--
-- Returns the members of a list dimension for a business area
--
-- IN: p_dimension_id  - The dimension ID to get the hier members for
--     p_logical_dim_id - Logical Dim ID added for  "Consistent Dimension"
--     p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
-- OUT: each dimension member ID information
----------------------------------------------------------------------------
function GET_LIST_DIM_MEMBERS(p_dimension_id  IN NUMBER,
                              p_logical_dim_id IN NUMBER,
                              p_business_area IN NUMBER := null,
                              p_version_type  IN VARCHAR2 := 'P')
   return ZPB_VAR_MEMBER_TABLE_T PIPELINED;

----------------------------------------------------------------------------
-- INIT_HIER_MEMBER_CACHE
--
-- Initializes the cache which is used as part of GET_HIERARCHY_MEMBERS.
-- Must be called before you call GET_HIERARCHY_MEMBERS.  Will initialize
-- for all dimensions of the business area passed in
--
-- IN: p_business_area - Option Business Area ID. Defaults to sys_context
--     p_version_type  - Version draft type
----------------------------------------------------------------------------
procedure INIT_HIER_MEMBER_CACHE(p_business_area IN NUMBER := null,
                                 p_version_type  IN VARCHAR2 := 'P');

end ZPB_FEM_UTILS_PKG;

/
