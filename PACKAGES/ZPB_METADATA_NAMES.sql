--------------------------------------------------------
--  DDL for Package ZPB_METADATA_NAMES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_METADATA_NAMES" AUTHID CURRENT_USER as
/* $Header: zpbmetanames.pls 120.0.12010.2 2005/12/23 08:20:15 appldev noship $ */

-------------------------------------------------------------------------------
-- GET_ALL_ANNOTATIONS_VIEW - Gets the all annotations view name
--
-- IN: p_aw       - The AW
-- OUT: The view name for all annotations
-------------------------------------------------------------------------------
function GET_ALL_ANNOTATIONS_VIEW (p_aw        in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_ALL_ANNOT_PERS_VIEW - Gets the personal all annotations view name
--
-- IN: p_aw       - The AW
-- OUT: The view name for all personal annotations
-------------------------------------------------------------------------------
function GET_ALL_ANNOT_PERS_VIEW (p_aw        in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_ATTRIBUTE_COLUMN - Gets the column name for an attribute
--
-- IN: p_dimID     - The Dimension ID in the DimDim
--     p_attribute - The Attribute ID in the AttrDim
-- OUT: The column name for the attribute
-------------------------------------------------------------------------------
function GET_ATTRIBUTE_COLUMN (p_dimID     in varchar2,
                               p_attribute in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_ATTRIBUTE_CWM2_NAME - Gets the cwm2 name for an attribute
--
-- IN: p_aw        - The AW which the contains the attribte
--     p_dimID     - The Dimension ID in the DimDim
--     p_attribute - The Attribute ID in the AttrDim
-- OUT: The cwm2 name for the attribute
-------------------------------------------------------------------------------
function GET_ATTRIBUTE_CWM2_NAME (p_aw        in varchar2,
                                  p_dimID     in varchar2,
                                  p_attribute in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_ATTRIBUTE_SCOPE_VIEW - Gets the attribute scope view name
--
-- IN: p_aw       - The AW
-- OUT: The view name for attribute scoping
-------------------------------------------------------------------------------
function GET_ATTRIBUTE_SCOPE_VIEW (p_aw        in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_CATALOG_CWM2_NAME - Gets the cwm2 name for a catalog
--
-- IN: p_aw        - The AW which the catalog contains
-- OUT: The column name for the catalog
-------------------------------------------------------------------------------
function GET_CATALOG_CWM2_NAME (p_aw in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DATA_EXCEPTION_VIEW - Gets the data exception view name
--
-- IN: p_aw - The AW
--
-- OUT: The data exception view name
-------------------------------------------------------------------------------
function GET_DATA_EXCEPTION_VIEW (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIMENSION_COLUMN - Gets the column name for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the dimension
-------------------------------------------------------------------------------
function GET_DIMENSION_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIMENSION_CWM2_NAME - Gets the cwm2 name for a dimension
--
-- IN: p_aw        - The AW where the dimension exists
--     p_dimID     - The Dimension ID in the DimDim
-- OUT: The cwm2 name for the dimension
-------------------------------------------------------------------------------
function GET_DIMENSION_CWM2_NAME (p_aw        in varchar2,
                                  p_dimID     in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIMENSION_VIEW - Gets the cwm2 name for a dimension
--
-- IN: p_aw          - The AW where the dimension exists
--     p_type        - PERSONAL or SHARED, the AW type
--     p_dimID       - The Dimension ID in the DimDim
--     p_hierarchyID - The hierarchy ID in the HierDim
-- OUT: The view name for the dimension/hierarchy
-------------------------------------------------------------------------------
function GET_DIMENSION_VIEW (p_aw          in varchar2,
                             p_type        in varchar2,
                             p_dimID       in varchar2,
                             p_hierarchyID in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_CODE_COLUMN - Gets the column name for the dimension code
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the code
-------------------------------------------------------------------------------
function GET_DIM_CODE_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_ENDDATE_COLUMN - Gets the column name for the enddate attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the enddate attribute
-------------------------------------------------------------------------------
function GET_DIM_ENDDATE_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_AGGTIME_COLUMN - Gets the column name for the agg type by time attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the agg type by time attribute
-------------------------------------------------------------------------------
function GET_DIM_AGGTIME_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_AGGOTHER_COLUMN - Gets the column name for the agg type, by dimensions
--                          other than time, attribute for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the agg type by other dims attribute
-------------------------------------------------------------------------------
function GET_DIM_AGGOTHER_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_CALENDAR_COLUMN - Gets the column name for the calendar id, used
--                           for time dimension only
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the calendar id
-------------------------------------------------------------------------------
function GET_DIM_CALENDAR_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_GID_COLUMN - Gets the column name for the GID attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim, if null, the null GID col
--     p_hierID - The Hierarchy ID, for measure views.  Null if dim view
-- OUT: The column name for the GID attribute
-------------------------------------------------------------------------------
function GET_DIM_GID_COLUMN (p_dimID  in varchar2 := null,
                             p_hierID in varchar2 := null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_LONG_NAME_COLUMN - Gets the column name for the long name attribute
--                            for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the long name attribute
-------------------------------------------------------------------------------
function GET_DIM_LONG_NAME_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_LONG_NAME_CWM2 - Gets the cwm2 name for the long name attribute
--                            for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The cwm2 name for the long name attribute
-------------------------------------------------------------------------------
function GET_DIM_LONG_NAME_CWM2 (p_aw    in varchar2,
                                 p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_ORDER_COLUMN - Gets the column name for the dimension order
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the order
-------------------------------------------------------------------------------
function GET_DIM_ORDER_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_PARENT_COLUMN - Gets the column name for the parent attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the parent attribute
-------------------------------------------------------------------------------
function GET_DIM_PARENT_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_PGID_COLUMN - Gets the column name for the PGID attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the PGID attribute
-------------------------------------------------------------------------------
function GET_DIM_PGID_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_SHORT_NAME_COLUMN - Gets the column name for the short name
--                             attribute for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the short name attribute
-------------------------------------------------------------------------------
function GET_DIM_SHORT_NAME_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_SHORT_NAME_CWM2 - Gets the cwm2 name for the short name
--                           attribute for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The cwm2 name for the short name attribute
-------------------------------------------------------------------------------
function GET_DIM_SHORT_NAME_CWM2 (p_aw    in varchar2,
                                  p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_DIM_TIMESPAN_COLUMN - Gets the column name for the timespan attribute
--                          for a dimension
--
-- IN: p_dimID - The Dimension ID in the DimDim
-- OUT: The column name for the timespan attribute
-------------------------------------------------------------------------------
function GET_DIM_TIMESPAN_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_CHECK_TBL - Gets the generic exception check table
--
-- IN: p_aw - The AW
--
-- OUT: The exception check table
-------------------------------------------------------------------------------
function GET_EXCEPTION_CHECK_TBL (p_aw in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_COLUMN - Gets the generic exception check column
--
-- OUT: The exception check column
-------------------------------------------------------------------------------
function GET_EXCEPTION_COLUMN
   return varchar2;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_MEAS_CWM2 - Gets the exception check measure cwm2 name
--
-- IN: p_aw - The AW
--     p_instance - The Instance ID
--
-- OUT: The exception check measure cwm2 name
-------------------------------------------------------------------------------
function GET_EXCEPTION_MEAS_CWM2 (p_aw in varchar2,
                                  p_instance in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_EXCEPTION_MEAS_CUBE - Gets the exception check measure cube name
--
-- IN: p_aw - The AW
--     p_instance - The Instance ID
--
-- OUT: The exception check measure cube name
-------------------------------------------------------------------------------
function GET_EXCEPTION_MEAS_CUBE (p_aw in varchar2,
                                  p_instance in varchar2)
   return varchar2;

---------------------------------------------------------------------------
-- GET_EXCH_RATES_VIEW - Gets the exchange rates view name
--
-- IN: p_aw - The AW
--
-- OUT: The exchange rates view name
-------------------------------------------------------------------------------
function GET_EXCH_RATES_VIEW (p_aw       in varchar2)
   return varchar2;

---------------------------------------------------------------------------
-- GET_EXCH_SCENARIO_VIEW - Gets the exchange scenario view name
--
-- IN: p_aw - The AW
--
-- OUT: The exchange scenario view name
-------------------------------------------------------------------------------
function GET_EXCH_SCENARIO_VIEW (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_FULL_SCOPE_COLUMN - Gets the full scope column
--
-- IN: p_aw - The AW
--
-- OUT: The full scope column
-------------------------------------------------------------------------------
function GET_FULL_SCOPE_COLUMN
   return varchar2;

-------------------------------------------------------------------------------
-- GET_FULL_SCOPE_CWM2_NAME - Gets the full scope measure
--
-- IN: p_aw - The AW
--
-- OUT: The full scope cwm2 measure name
-------------------------------------------------------------------------------
function GET_FULL_SCOPE_CWM2_NAME (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_HIERARCHY_CWM2_NAME - Gets the cwm2 hierarchy name
--
-- IN: p_dimID       - The Dimension ID in the DimDim
--     p_hierarchyID - The Hierarchy ID in the HierDim (null for
--                       hierarchy-less dims)
-- OUT: The column name for the timespan attribute
-------------------------------------------------------------------------------
function GET_HIERARCHY_CWM2_NAME (p_aw          in varchar2,
                                  p_dimID       in varchar2,
                                  p_hierarchyID in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_HIERARCHY_SCOPE_VIEW - Gets the view name for the hierarchy scoping view
--
-- IN: p_aw          - The AW where the dimension exists
--     p_dimID       - The Dimension ID in the DimDim
-- OUT: The view name for the dimension/hierarchy
-------------------------------------------------------------------------------
function GET_HIERARCHY_SCOPE_VIEW (p_aw          in varchar2,
                                   p_dimID       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_LEVEL_COLUMN - Gets the level column name
--
-- IN: p_dimID   - The Dimension ID in the DimDim
--     p_levelID - The Level ID in the LevelDim
-- OUT: The column name for the level
-------------------------------------------------------------------------------
function GET_LEVEL_COLUMN (p_dimID in varchar2,
                           p_levelID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_LEVEL_CWM2_NAME - Gets the cwm2 level name
--
-- IN: p_dimID   - The Dimension ID in the DimDim
--     p_levelID - The Level ID in the LevelDim (null for hierarchy-less dims)
-- OUT: The column name for the timespan attribute
-------------------------------------------------------------------------------
function GET_LEVEL_CWM2_NAME (p_aw          in varchar2,
                              p_dimID       in varchar2,
                              p_hierID      in varchar2 default null,
                              p_levelID     in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_LEVELREL_COLUMN - Gets the levelRel column name
--
-- IN: p_dimID   - The Dimension ID in the DimDim
-- OUT: The column name for the levelRel
-------------------------------------------------------------------------------
function GET_LEVELREL_COLUMN (p_dimID in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_LEVEL_SCOPE_VIEW - Gets the name of the view for level scoping
--
-- IN: p_aw          - The AW where the dimension exists
--     p_dimID       - The Dimension ID in the DimDim
-- OUT: The ID for the level
-------------------------------------------------------------------------------
function GET_LEVEL_SCOPE_VIEW (p_aw          in varchar2,
                               p_dimID       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_ANNOT_CWM2 - Gets the measure annotation cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The annotation measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_ANNOT_CWM2 (p_aw       in varchar2,
                                 p_instance in varchar2,
                                 p_type     in varchar2,
                                 p_template in varchar2 default null,
                                 p_approvee in varchar2 default null,
                                                                 p_currency in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_CWM2 - Gets the measure  cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_CWM2 (p_aw       in varchar2,
                           p_instance in varchar2,
                           p_type     in varchar2,
                           p_template in varchar2 default null,
                           p_approvee in varchar2 default null,
                                                   p_currency in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_FORMAT_CWM2 - Gets the measure format cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The format measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_FORMAT_CWM2 (p_aw       in varchar2,
                                  p_instance in varchar2,
                                  p_type     in varchar2,
                                  p_template in varchar2 default null,
                                  p_approvee in varchar2 default null,
                                                                  p_currency in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_INPUT_LVL_CWM2 - Gets the measure input level cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The input level measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_INPUT_LVL_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2 default null,
                                     p_approvee in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_TARGET_CWM2 - Gets the measure target cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The target measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_TARGET_CWM2 (p_aw       in varchar2,
                                  p_instance in varchar2,
                                  p_type     in varchar2,
                                  p_template in varchar2 default null,
                                  p_approvee in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_TARG_TYPE_CWM2 - Gets the measure target type cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The target type measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_TARG_TYPE_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2 default null,
                                     p_approvee in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_TYPE_ABBREV - Gets the measuure type shortname
--
-- IN: p_type - The measure type
-- OUT: The measure type shortname
-------------------------------------------------------------------------------
function GET_MEASURE_TYPE_ABBREV (p_type in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_WRITE_SEC_CWM2 - Gets the measure write security cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The write security measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_WRITE_SEC_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2 default null,
                                     p_approvee in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_MEASURE_CUR_WRITE_SEC_CWM2 - Gets the measure currency write security cwm2 name
--
-- IN: p_aw       - The AW
--     p_instance - The Instance ID
--     p_type     - The measure type, one of ('CWM', 'SHARED', 'PERSONAL',
--                  or 'APPROVAL')
-- OUT: The write security measure cwm2 name
-------------------------------------------------------------------------------
function GET_MEASURE_CUR_WRITE_SEC_CWM2 (p_aw       in varchar2,
                                     p_instance in varchar2,
                                     p_type     in varchar2,
                                     p_template in varchar2 default null,
                                     p_approvee in varchar2 default null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_OWNERMAP_COLUMN - Gets the ownermap column
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap column
-------------------------------------------------------------------------------
function GET_OWNERMAP_COLUMN
   return varchar2;

-------------------------------------------------------------------------------
-- GET_OWNERMAP_CWM2_CUBE - Gets the ownermap cube
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap cwm2 cube name
-------------------------------------------------------------------------------
function GET_OWNERMAP_CWM2_CUBE (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_OWNERMAP_CWM2_NAME - Gets the ownermap measure
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap cwm2 measure name
-------------------------------------------------------------------------------
function GET_OWNERMAP_CWM2_NAME (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------
-- GET_OWNERMAP_VIEW - Gets the ownermap view
--
-- IN: p_aw - The AW
--
-- OUT: The ownermap view name
-------------------------------------------------------------------------------
function GET_OWNERMAP_VIEW (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_SCOPE_STATUS_VIEW - Gets the scope view name
--
-- IN: p_aw - The AW
--
-- OUT: The scope status view name
-------------------------------------------------------------------------------
function GET_SCOPE_STATUS_VIEW (p_aw       in varchar2)
   return varchar2;

---------------------------------------------------------------------------
-- GET_SCOPING_VIEW - Gets the metadata scoping view
--
-- IN: p_aw - The AW
--
-- OUT: The metadata scoping view name
-------------------------------------------------------------------------------
function GET_SCOPING_VIEW (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_SECURITY_CWM2_CUBE - Gets the security (ownermap) cube
--
-- IN: p_aw - The AW
--
-- OUT: The security cwm2 cube name
-------------------------------------------------------------------------------
function GET_SECURITY_CWM2_CUBE (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_SECURITY_VIEW - Gets the security (ownermap) view
--
-- IN: p_aw - The AW
--
-- OUT: The security view name
-------------------------------------------------------------------------------
function GET_SECURITY_VIEW (p_aw       in varchar2)
   return varchar2;

---------------------------------------------------------------------------
-- GET_SOLVE_LEVEL_TABLE - Gets the solve input/output level table name
--
-- IN: p_aw - The AW
--
-- OUT: The solve input/output level table name
-------------------------------------------------------------------------------
function GET_SOLVE_LEVEL_TABLE (p_aw       in varchar2)
   return varchar2;

---------------------------------------------------------------------------
-- GET_TO_CURRENCY_VIEW - Gets the to currency view name
--
-- IN: p_aw - The AW
--
-- OUT: The to currency view name
-------------------------------------------------------------------------------
function GET_TO_CURRENCY_VIEW (p_aw       in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_VIEW_OBJECT - Gets the measure view object name
--
-- IN: p_view - The Measure or Dimension view
-- OUT: The view's object name
-------------------------------------------------------------------------------
function GET_VIEW_OBJECT(p_view in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_VIEW_TABLE - Gets the measure view table name
--
-- IN: p_view - The Measure or Dimension view
-- OUT: The view's table name
-------------------------------------------------------------------------------
function GET_VIEW_TABLE(p_view in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- UPGRADE_REPOS_NAME - Upgrades the repository name for a business area
--                      to the new name
--
-- IN: p_business_area - The Business Area ID
--     p_old_name      - The old name
--     p_new_name      - The new name
-------------------------------------------------------------------------------
procedure UPGRADE_REPOS_NAME(p_business_area IN VARCHAR2,
                             p_old_name      IN VARCHAR2,
                             p_new_name      IN VARCHAR2);

end ZPB_METADATA_NAMES;

 

/
