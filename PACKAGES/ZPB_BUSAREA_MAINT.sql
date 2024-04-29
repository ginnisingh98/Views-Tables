--------------------------------------------------------
--  DDL for Package ZPB_BUSAREA_MAINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_BUSAREA_MAINT" AUTHID CURRENT_USER AS
/* $Header: ZPBVBAMS.pls 120.9 2007/12/04 14:37:01 mbhat noship $ */

G_PKG_NAME CONSTANT VARCHAR2(17) := 'zpb_busarea_maint';

-------------------------------------------------------------------------
-- ADD_ATTRIBUTE - Adds an attribute to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_attribute_id    - The FEM Attribute ID
-------------------------------------------------------------------------
PROCEDURE ADD_ATTRIBUTE (p_version_id     IN      NUMBER,
                         p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                         p_attribute_id   IN      NUMBER);

-------------------------------------------------------------------------
-- ADD_USER - Adds a user to the Business Area
--
-- IN:  p_business_area_id   - The bsuiness area ID
--      p_user_id            - The User ID
-------------------------------------------------------------------------
PROCEDURE ADD_USER (p_business_area_id   IN      NUMBER,
                    p_user_id            IN      NUMBER);


-------------------------------------------------------------------------
-- ADD_CONDITION - Adds an attribute condition to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_attribute_id    - The FEM Attribute ID
--      p_value           - The attribute value
--      p_value_set_id    - The value set ID, for VS-enabled attributes
--      p_operation       - The operator for the condition (default null)
-------------------------------------------------------------------------
PROCEDURE ADD_CONDITION (p_version_id     IN      NUMBER,
                         p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                         p_attribute_id   IN      NUMBER,
                         p_value          IN      VARCHAR2,
                         p_value_set_id   IN      NUMBER := null,
                         p_operation      IN      VARCHAR2 := null);


-------------------------------------------------------------------------
-- ADD_DATASET - Adds a dataset to the Business Area version
--
-- IN:  p_version_id   - The version ID
--      p_dataset_id   - The FEM Dataset ID
-------------------------------------------------------------------------
PROCEDURE ADD_DATASET (p_version_id   IN      NUMBER,
                       p_dataset_id   IN      NUMBER);

-------------------------------------------------------------------------
-- ADD_DIMENSION - Adds a dimension to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_func_dim_set_id - Functional Dimension Set Id
--      p_dimension_id    - The FEM Dimension ID
-------------------------------------------------------------------------
PROCEDURE ADD_DIMENSION (p_version_id      IN  NUMBER,
                         p_func_dim_set_id IN  NUMBER := null, -- "Consistent Dimension"
                         p_dimension_id    IN  NUMBER);

-------------------------------------------------------------------------
-- ADD_HIERARCHY - Adds a hierarchy to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The FEM Hierarchy ID
-------------------------------------------------------------------------
PROCEDURE ADD_HIERARCHY (p_version_id      IN      NUMBER,
                         p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                         p_hierarchy_id    IN      NUMBER);

-------------------------------------------------------------------------
-- ADD_HIERARCHY_MEMBER - Adds a top level member to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The FEM Hierarchy ID
--      p_hier_mbr_id     - The FEM member ID
--      p_member_vset     - The FEM member valueset ID (defaults to null)
--      p_hier_version    - The FEM hierarchy version ID (defaults to null)
-------------------------------------------------------------------------
PROCEDURE ADD_HIERARCHY_MEMBER (p_version_id      IN      NUMBER,
                                p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                                p_hierarchy_id    IN      NUMBER,
                                p_member_id       IN      NUMBER,
                                p_member_vset     IN      NUMBER := null,
                                p_hier_version    IN      NUMBER := null);

-------------------------------------------------------------------------
-- ADD_HIERARCHY_VERSION - Adds a hierarchy to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The FEM Hierarchy ID
--      p_hier_vers_id    - The FEM Hierarchy Version ID
-------------------------------------------------------------------------
PROCEDURE ADD_HIERARCHY_VERSION (p_version_id      IN      NUMBER,
                                 p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                                 p_hierarchy_id    IN      NUMBER,
                                 p_hier_vers_id    IN      NUMBER);


-------------------------------------------------------------------------
-- ADD_LEDGER - Adds a ledger to the Business Area version
--
-- IN:  p_version_id   - The version ID
--      p_ledger_id    - The FEM Ledger ID
-------------------------------------------------------------------------
PROCEDURE ADD_LEDGER (p_version_id   IN      NUMBER,
                      p_ledger_id    IN      NUMBER);

-------------------------------------------------------------------------
-- ADD_LEVEL - Adds a level to the Business Area version
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_level_id        - The FEM Level ID
--      p_hierarchy_id    - The Hierarchy to add the level to
-------------------------------------------------------------------------
PROCEDURE ADD_LEVEL (p_version_id      IN      NUMBER,
                     p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                     p_level_id        IN      NUMBER,
                     p_hierarchy_id    IN      NUMBER);

-------------------------------------------------------------------------
-- CHANGE_HIER_VERS_INCL - Should be called anytime the user changes
--                         what hierarchy versions are included in the
--                         Business Area
--
-- IN:  p_version_id      - The version ID
--      p_logical_dim_id  - Logical Dimension Id
--      p_hierarchy_id    - The Hierarchy to add the level to
-------------------------------------------------------------------------
PROCEDURE CHANGE_HIER_VERS_INCL (p_version_id      IN      NUMBER,
                                 p_logical_dim_id  IN      NUMBER,  -- "Consistent Dimension"
                                 p_hierarchy_id    IN      NUMBER);


-------------------------------------------------------------------------
-- CREATE_BUSINESS_AREA - Creates a new, empty Business Area
--
-- OUT: The created Business Area's ID
-------------------------------------------------------------------------
FUNCTION CREATE_BUSINESS_AREA
   return NUMBER;

-------------------------------------------------------------------------
-- CREATE_EMPTY VERSION - Creates a new, empty version for a Business Area.  If
--                        the version already exists, it will be overwritten
--                        (cleared).  If you want to create a version with a
--                        default definition, use COPY_VERSION instead.
--
-- IN:  p_business_area_id - The Business Area ID of the version
--      p_version_type     - The version type ('P', 'D', 'T', 'R')
--
-- OUT: The created Business Area version's ID
-------------------------------------------------------------------------
FUNCTION CREATE_EMPTY_VERSION (p_business_area_id IN     NUMBER,
                               p_version_type     IN     VARCHAR2)
   return NUMBER;

-------------------------------------------------------------------------
-- COPY_VERSION - Copies one version to another.  If the version that is to be
--                copied to does not exist, this function will create it.
--                Otherwise, it will overwrite that version's definition.
--                Returns the version ID of the version that was created or
--                overwritten.
--
-- IN:  p_from_busarea_id    - The Business Area ID that the version to copy
--                             from is associated with
--      p_from_version_type  - The version type of the version to copy from
--      p_to_busarea_id      - The Business Area ID that the version to copy
--                             to is associated with
--      p_to_version_type    - The version type of the version to copy to
--
-- OUT: The ID of the version that was copied to
-------------------------------------------------------------------------
FUNCTION COPY_VERSION (p_from_busarea_id   IN      NUMBER,
                       p_from_version_type IN      VARCHAR2,
                       p_to_busarea_id     IN      NUMBER,
                       p_to_version_type   IN      VARCHAR2)
   return NUMBER;

-------------------------------------------------------------------------
-- DELETE_BUSINESS_AREA_CR - Creates a conc. req. to deletes a Business Area
--                            including all versions
--
-- IN:  p_business_area_id - The Business Area ID
--
-- OUT: concurrent request number
-------------------------------------------------------------------------
FUNCTION DELETE_BUSINESS_AREA_CR (p_business_area_id IN     NUMBER)
   return NUMBER;

-------------------------------------------------------------------------
-- DELETE_BUSINESS_AREA - Deletes a Business Area, including all versions
--
-- IN:  p_business_area_id - The Business Area ID
-- OUT: ERRBUF - error buffer
-- OUT: RETCODE - return code
-------------------------------------------------------------------------
PROCEDURE DELETE_BUSINESS_AREA (ERRBUF          OUT NOCOPY VARCHAR2,
                                RETCODE         OUT NOCOPY VARCHAR2,
                                p_business_area_id IN     NUMBER);

-------------------------------------------------------------------------
-- LOGIN - Called when a user logs in to a Business Area
--
-- IN: p_business_area_id - The Business Area that the user logged in
--                          under
-----------------------------------------------------------------------
PROCEDURE LOGIN (p_business_area_id IN      NUMBER);

-------------------------------------------------------------------------
-- REFRESH - Submits a conc. req. to refresh a Business Area into EPB
--
-- IN:  p_business_area_id - The Business Area ID
-------------------------------------------------------------------------
FUNCTION REFRESH (p_business_area_id IN      NUMBER) return NUMBER;

-------------------------------------------------------------------------
-- REMOVE_ATTRIBUTE - Removes an attribute from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_attribute_id   - The FEM Attribute ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_ATTRIBUTE (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN      NUMBER,  -- "Consistent Dimension"
                            p_attribute_id   IN      NUMBER);

-------------------------------------------------------------------------
-- REMOVE_USER - Removes a user from the Business Area
--
-- IN:  p_business_area_id   - The business area ID
--      p_user_id - The User ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_USER (p_business_area_id   IN      NUMBER,
                       p_user_id            IN      NUMBER);

-------------------------------------------------------------------------
-- REMOVE_CONDITION - Removes an attribute condition from the Business
--                    Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_attribute_id   - The FEM Attribute ID
--      p_value          - The attribute value
--      p_value_set_id   - The value set ID, for VS-enabled attributes
--      p_operation      - The operation of the condition
-------------------------------------------------------------------------
PROCEDURE REMOVE_CONDITION (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN      NUMBER,  -- "Consistent Dimension"
                            p_attribute_id   IN      NUMBER,
                            p_value          IN      VARCHAR2,
                            p_operation      IN      VARCHAR2,
                            p_value_set_id   IN      NUMBER := null);

-------------------------------------------------------------------------
-- REMOVE_DATASET - Removes a dataset from the Business Area version
--
-- IN:  p_version_id   - The version ID
--      p_dataset_id   - The FEM Dataset ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_DATASET (p_version_id   IN      NUMBER,
                          p_dataset_id   IN      NUMBER);

-------------------------------------------------------------------------
-- REMOVE_DIMENSION - Removes a dimension from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - The FEM Dimension ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_DIMENSION (p_version_id     IN      NUMBER,
                            p_logical_dim_id IN      NUMBER);  -- "Consistent Dimension"

-------------------------------------------------------------------------
-- REMOVE_HIERARCHY - Removes a hierarchy from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_HIERARCHY (p_version_id   IN      NUMBER,
                            p_logical_dim_id IN    NUMBER,  -- "Consistent Dimension"
                            p_hierarchy_id IN      NUMBER);

-------------------------------------------------------------------------
-- REMOVE_HIERARCHY_MEMBER - Removes a top level member to the
--                           Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
--      p_member_id      - The FEM member ID
--      p_member_vset    - The FEM member valueset ID (defaults to null)
--      p_hier_version   - The FEM hierarchy version ID (defaults to null)
-------------------------------------------------------------------------
PROCEDURE REMOVE_HIERARCHY_MEMBER (p_version_id     IN      NUMBER,
                                   p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                                   p_hierarchy_id   IN      NUMBER,
                                   p_member_id      IN      NUMBER,
                                   p_member_vset    IN      NUMBER := null,
                                   p_hier_version   IN      NUMBER := null);

-------------------------------------------------------------------------
-- REMOVE_HIERARCHY_VERSION - Removes a hierarchy to the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
--      p_hier_vers_id   - The FEM Hierarchy Version ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_HIERARCHY_VERSION (p_version_id     IN      NUMBER,
                                    p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                                    p_hierarchy_id   IN      NUMBER,
                                    p_hier_vers_id   IN      NUMBER);


-------------------------------------------------------------------------
-- REMOVE_LEDGER - Removes a ledger from the Business Area version
--
-- IN:  p_version_id  - The version ID
--      p_ledger_id   - The FEM Ledger ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_LEDGER (p_version_id  IN      NUMBER,
                         p_ledger_id   IN      NUMBER);

-------------------------------------------------------------------------
-- REMOVE_LEVEL - Removes a level from the Business Area version
--
-- IN:  p_version_id     - The version ID
--      p_logical_dim_id - Logical Dim Id
--      p_hierarchy_id   - The FEM Hierarchy ID
--      p_level_id       - The FEM Level ID
-------------------------------------------------------------------------
PROCEDURE REMOVE_LEVEL (p_version_id     IN      NUMBER,
                        p_logical_dim_id IN      NUMBER, -- "Consistent Dimension"
                        p_hierarchy_id   IN      NUMBER,
                        p_level_id       IN      NUMBER);


-------------------------------------------------------------------------
-- HANDLE_FDR_CHANGES - Handles chnages in the FDR of a BA
--                    - Added for "Consistent Dimension" Project
--
-- IN:  p_version_id         - The version ID
--      p_fdr_obj_def_id_old - Old FDR Object Definition Id
--      p_fdr_obj_def_id_new - New FDR Object Definition Id
--      p_return_status      - return status
-------------------------------------------------------------------------
PROCEDURE HANDLE_FDR_CHANGES (p_version_id          IN          NUMBER,
                              p_fdr_obj_def_id_old  IN          NUMBER,
                              p_fdr_obj_def_id_new  IN          NUMBER,
                              p_return_status       OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------
-- GENERATE_AW_DIM_NAME - Generates the AW name of a dimension
--                      - Added for "Consistent Dimension" Project
--
-- IN:  p_dim_type_code  - FEM Dimension Type Code
--      p_member_b_table - FEM XDIM Member B Table
-- OUT: p_aw_dim_name    - ZPB AW Dimension Name
-------------------------------------------------------------------------
PROCEDURE GENERATE_AW_DIM_NAME (p_dim_type_code    IN          VARCHAR2,
                                p_member_b_table   IN          VARCHAR2,
                                p_aw_dim_name      OUT NOCOPY  VARCHAR2);


END ZPB_BUSAREA_MAINT;

/
