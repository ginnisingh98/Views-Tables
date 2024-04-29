--------------------------------------------------------
--  DDL for Package ZPB_OLAP_VIEWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_OLAP_VIEWS_PKG" AUTHID CURRENT_USER as
/* $Header: ZPBVOLVS.pls 120.5 2007/12/04 14:40:00 mbhat ship $ */

-------------------------------------------------------------------------------
-- COMPILE_VIEWS
--
-- Recompiles views that have become INVALID, usually due to the recompilation/
-- patch of this file.
--
-------------------------------------------------------------------------------
procedure COMPILE_VIEWS;

-------------------------------------------------------------------------------
-- CREATE_ATTRIBUTE_VIEWS
--
-- Builds the SQL mapping structures for an AW's attributes
--
-- IN:
--     p_aw         (varchar2) - The name of the AW
--     p_type       (varchar2) - The type of the AW (SHARED or PERSONAL)
--     p_attributes (varchar2) - list of attr IDs in Dimdim.  If null,
--                               all attributes are built
-------------------------------------------------------------------------------
procedure CREATE_ATTRIBUTE_VIEWS (p_aw         in varchar2,
                                  p_type       in varchar2,
                                  p_attributes in varchar2 := null);

-------------------------------------------------------------------------------
-- CREATE_CUBE_VIEW
--
-- Builds the SQL view for an empty cube
--
-- IN:
--     p_aw     (varchar2) - The name of the AW holding the cube
--     p_awType (varchar2) - PERSONAL or SHARED: the AW type
--     p_view   (varchar2) - The name of the view to create
--     p_lmap   (varchar2) - The name of the LMAP variable to use for this view
--     p_colVar (varchar2) - The name of the COLCOUNTVAR variable
--     p_dims   (varchar2) - Space sparated string of dim ID's (in the DimDim)
--                            that defined the shape of the cube
-------------------------------------------------------------------------------
procedure CREATE_CUBE_VIEW (p_aw       IN VARCHAR2,
                            p_awType   IN VARCHAR2,
                            p_view     IN VARCHAR2,
                            p_lmap     IN VARCHAR2,
                            p_colVar   IN VARCHAR2,
                            p_dims     IN VARCHAR2,
                            p_mode     IN VARCHAR2 default 'DEFAULT');

-------------------------------------------------------------------------------
-- CREATE_DIMENSION_VIEWS
--
-- Builds the SQL views which expose the dimensions
--
-- IN:
--     p_aw        (varchar2) - The name of the data AW
--     p_type      (varchar2) - The AW type (PERSONAL or SHARED)
--     p_dimension (varchar2) - A dimension to build dimension views.  If null,
--                              all dimensions are built
--     p_hierarchy (varchar2) - The hierarchy to build the view.  If null,
--                              all hierarchies
-------------------------------------------------------------------------------
procedure CREATE_DIMENSION_VIEWS (p_aw        in varchar2,
                                  p_type      in varchar2,
                                  p_dimension in varchar2 default null,
                                  p_hierarchy in varchar2 default null);

-------------------------------------------------------------------------------
-- CREATE_SECURITY_VIEW
--
-- IN: p_aw       - The AW
--     p_measures - A space-separated list of measures, valid entries are
--                  ('OWNERMAP', 'SECWRITEMAP.F', 'SECFULLSCPVW')
--     p_measView - The name of the measure view
--     p_dims     - Space-separated list of dimensions
-------------------------------------------------------------------------------
procedure CREATE_SECURITY_VIEW (p_aw          in varchar2,
                                p_measures    in varchar2,
                                p_measView    in varchar2,
                                p_dims        in varchar2);

-------------------------------------------------------------------------------
-- CREATE_VIEW_STRUCTURES
--
-- Builds the views on the shared AW for exposing EPB-specific
-- information to the middle tier
--
-- IN: p_dataAw  (varchar2) - The actual name of the data AW
--     p_annotAw (varchar2) - The actual name of the annotation AW
--
-------------------------------------------------------------------------------
procedure CREATE_VIEW_STRUCTURES (p_dataAW in varchar2,
                                  p_annotAW in varchar2);

-------------------------------------------------------------------------------
-- GET_LIMITMAP - Returns the limitmap for a dimension given.
--    DEPRECATED! Only left in to simplify upgrade of dev env's
--
-- IN:
--     p_type (varchar2) - The AW type (either 'SHARED' or 'PERSONAL')
--     p_dim  (varchar2) - The dimension (the physical AW object)
--     p_hier (varchar2) - The hierarchy ID, null denotes no hierarchy
--
-- OUT:
--     The limitmap for the parameters specified
-------------------------------------------------------------------------------
function GET_LIMITMAP (p_type        in varchar2,
                       p_dim         in varchar2,
                       p_hier        in varchar2 := null)
   return varchar2;

-------------------------------------------------------------------------------
-- INITIALIZE - Initializes the session to run SQL queries against the OLAP
--              views.  This is only needed for sessions that have not had
--              a normal OLAP startup called (ie, Apps sessions)
--
-- IN:
--     p_type (varchar2) - The AW type (either 'SHARED' or 'PERSONAL')
-------------------------------------------------------------------------------
procedure INITIALIZE (p_type        in varchar2);

-------------------------------------------------------------------------------
-- REMOVE_DIMENSION_VIEW
--
-- IN:
--     p_aw        - The AW storing the dimension
--     p_type      - PERSONAL or SHARED, the AW type
--     p_dim       - The dimension ID in the DimDim
--     p_hierarchy - The hierarchy ID in the HierDim
-- Removes the view for the dimension's hierarchy.
-------------------------------------------------------------------------------
procedure REMOVE_DIMENSION_VIEW (p_aw        in varchar2,
                                 p_type      in varchar2,
                                 p_dim       in varchar2,
                                 p_hierarchy in varchar2);
-------------------------------------------------------------------------------
-- REMOVE_BUSAREA_VIEWS
--
-- Removes all SQL views for a business area
--
-- IN:  p_business_area    - The Business Area ID
--
-------------------------------------------------------------------------------
procedure REMOVE_BUSAREA_VIEWS (p_business_area in NUMBER);

------------------------------------------------------------------------------
-- REMOVE_USER_VIEWS  -- REMOVE_USER_VIEWS
--
-- Removes all relational views for the user
-- IN: p_user varchar2 - The user ID
--     p_business_area number - The business area ID
--
------------------------------------------------------------------------------
procedure REMOVE_USER_VIEWS (p_user          in varchar2,
                             p_business_area in number);

-------------------------------------------------------------------------------
-- DROP_VIEW
--
-- Drops the view and its corresponding objects
--
-- IN: p_view (varchar2) - The name of the view
--
-------------------------------------------------------------------------------
procedure DROP_VIEW (p_view in varchar2);

end ZPB_OLAP_VIEWS_PKG;

/
