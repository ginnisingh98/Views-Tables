--------------------------------------------------------
--  DDL for Package PQH_GENERIC_HIERARCHY_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GENERIC_HIERARCHY_PACKAGE" AUTHID CURRENT_USER as
/* $Header: pqghrpkg.pkh 120.0 2005/05/29 01:56:16 appldev noship $ */
-- ----------------------------------------------------------------------------
-- |---------------------------< chk_type_context >---------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: Checks whether a context value is defined in the Context Field
-- values for a descriptive flexfield.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_type		            Y    varchar2 Context to be checked
--   p_flexfield_name		    Y    varchar2 Flexfield Name
--
-- Post Success:
--   Returns 'Y' or 'N' based on whether the context exists or not.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function chk_type_context(p_type varchar2,
                          p_flexfield_name varchar2)
return varchar2;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_if_parent_node_type >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:Checks if a node type is a parent of any other node type
--  in the hierarchy type structure.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_node_type                    Y    varchar2 Node Type to be checked
--   p_hierarchy_type		    Y    varchar2 Hierarchy Type of Node Type
--
--
-- Post Success:
--   Returns 'Y' or 'N' based on whether the node_type is a parent or not.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
function chk_if_parent_node_type(p_node_type       in varchar2,
			         p_hierarchy_type  in varchar2)
return varchar2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< node_value_set_dyn_query >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: Returns the value set query for a level in the hierarchy
-- based on the parent_node_id and child_node_type from the entry in the
-- PER_GEN_HIER_NODE_TYPES table for the hierarchy type.
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_child_node_type              Y    varchar2 Node type selected for
--						  the level.
--   p_parent_node_id               Y    number   Id of the parent node.
--   p_hierarchy_type		    Y    varchar2 Type of the hierarchy.
--
--
-- Post Success:
--  Returns the value set query if the level in the hierarchy has validation
--  and the value set is found.If the value set is not found, 'INVALID' is
--  returned. If there is no validation, 'NULL' is returned.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Function Node_Value_Set_Dyn_Query(p_child_node_type IN Varchar2,
                                  p_parent_node_id  IN Number,
                                  p_hierarchy_type  IN Varchar2)
Return Varchar2;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_node_value >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: Gets the actual node value stored as entity id.
--
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_enity_id                     Y    varchar2 Entity id of the node.
--   p_parent_node_id               Y    number   Id of the parent node.
--   p_child_node_id		    Y    number   Id of the node.
--
--
-- Post Success:
-- Returns the node value stored.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
Function Get_Node_Value (p_entity_id       IN varchar2,
                         p_parent_node_id  IN Number,
                         p_child_node_id   IN Number)
Return varchar2;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< get_node_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:Returns the node_type of a hierarchy version node provided
-- the hierarchy_node_id.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_node_id            Y    number   Id of the node.
--
--
-- Post Success:Returns the node_type of the stored node.
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Function Get_Node_Type(p_hierarchy_node_id IN Number)
Return Varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_hierarchy_type >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:Returns the hierarchy type of the hierarchy to which a node
-- belongs.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd  Type     Description
--   p_hirarchy_node_id               Y   number   Id of the node.
--
--
-- Post Success:Returns the hierarchy type for the node.
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Function Get_Hierarchy_Type(p_hierarchy_node_id IN Number)
Return Varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< get_value_set_id >----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:This function retrieves the value set for a level in a
-- hierarchy. It does this by identifying the entry for the level in the table
-- PER_GEN_HIER_NODE_TYPES.
--
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_child_node_type              Y    varchar2 Type of the node at current
--                                                level.
--   p_parent_node_id               Y    number   Id of the parent node to
--                                                identify its type.
--   p_hirarchy_type                Y    varchar2 Hierarchy Type.
--
--
-- Post Success: Returns value set id for the level.If the value set is not
-- found, it returns -1. If the value set is invalid it returns -2.
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

Function Get_Value_Set_Id (p_child_node_type IN Varchar2,
                           p_parent_node_id  IN Number,
                           p_hierarchy_type  IN Varchar2 )
Return Number;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_sql_from_vset_id >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: Provided the id of a value set, this function returns the
-- associated query.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_vset_id                      Y    number   Value set id.
--
--
-- Post Success:
-- Returns the value set query.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
FUNCTION get_sql_from_vset_id(p_vset_id IN NUMBER)
RETURN VARCHAR2;
--
-- ----------------------------------------------------------------------------
-- |------------------------< chk_if_structure_exists >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: This function checks whether there is any entry in the table
-- PER_GEN_HIER_NODE_TYPES for a given HIERARCHY_TYPE lookup.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hirarchy_type                Y    varchar2 The HIERARCHY_TYPE
--                                                lookup_code.
--
-- Post Success: Returns 'Y' if structure exists for the HIERARCHY_TYPE.
-- Else returns 'N'.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Function chk_if_structure_exists(p_hierarchy_type IN varchar2)
Return Varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< chk_version_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This procedure checks if there is any version for a hierarchy as on an
--   Effective date.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_id                 Y    number   Id of the hierarchy.
--   p_effective_date               Y    date     Effective date.
--
--
-- Post Success:
-- Returns 'Y' if there is any matching version, else returns 'N'
--
-- Post Failure:
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
Procedure chk_version_exists(p_hierarchy_id   in Number,
                             p_effective_date in Date);

--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_lookup_value >-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure HIERARCHY_TYPE or HIERARCHY_NODE_TYPE lookup values
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_lookup_type		    Y    varchar2 Lookup Type(Either HIERARCHY_TYPE
--						  or HIERARCHY_NODE_TYPE) for which
--						  the new entry is being created.
--   p_lookup_code                  Y    varchar2 The new code to be inserted.
--   p_meaning                      Y    varchar2 Meaning for the new code.
--   p_description                  N    varchar2 Description for the new code.
--
--  Out parameters:
--   Name				 Type     Description
--   p_return_status                     varchar2 Flag to identify if the procedure
--                                                succeeded or not.
--
-- Post Success:
--   The lookup entry is created. p_return_status holds 'Y'.
--
-- Post Failure:
--   The procedure does not create the lookup entry and raises an error.
--   p_return_status holds 'N'.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure create_lookup_value
  ( p_lookup_type                   in     varchar2
   ,p_lookup_code                   in     varchar2
   ,p_meaning                       in     varchar2
   ,p_description                   in     varchar2 default null
   ,p_return_status                 out    NOCOPY varchar2
 );

Procedure update_lookup_value
  ( p_lookup_type                   in     varchar2
   ,p_lookup_code                   in     varchar2
   ,p_meaning                       in     varchar2
   ,p_description                   in     varchar2
  );

--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_shared_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: Creates an entry in the shared types for a HIERARCHY_TYPE
-- lookup, with system_type_cd and shared_type_code values as the
-- HIERARCHY_TYPE lookup_code
--
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_lookup_code                  Y    varchar2 Lookup_code of the
--                                                HIERARCHY_TYPE lookup.
--   p_meaning                      Y    varchar2 Meaning of the
--                                                HIERARCHY_TYPE lookup.
--
--
-- Post Success: Creates a new entry in shared types.
--
--
-- Post Failure: Does not create any entry in shared types.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure create_shared_type
   (p_lookup_code                   in     varchar2,
    p_meaning			    in 	   varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_shared_type >--------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:Updates allow multiple versions and allow duplicate name flags
-- for a HIERARCHY_TYPE lookup in per_shared_types.
--
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_lookup_code                  Y    varchar2 Lookup_code of the
--                                                HIERARCHY_TYPE.
--   p_information2                 Y    varchar2 Allow multiple version flag.
--   p_information3                 Y    varchar2 Allow duplicate name flag.
--
--
-- Post Success: Updates the shared types entry.
--
--
-- Post Failure: Does not update the shared types entry.
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
--
Procedure update_shared_type
   (p_lookup_code                   in     varchar2,
    p_information2		    in	   varchar2,
    p_information3		    in	   varchar2
  ) ;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_lookup_and_shared_type>--------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description: This procedure creates a new HIERARCHY_TYPE lookup and also
-- creates an entry for it in the PER_SHARED_TYPES table.
--
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_lookup_code                  Y    varchar2
--   p_meaning                      Y    varchar2
--   p_description                  N    varchar2
--
-- Post Success:
--
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure create_lookup_and_shared_type
  ( p_lookup_code                   in     varchar2
   ,p_meaning                       in     varchar2
   ,p_description                   in     varchar2 default null
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This procedure creates a row in the table PER_GEN_HIER_NODE_TYPES.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_type		    Y    varchar2 Hierarchy type code.
--   p_child_value_set              Y    varchar2 Value set name.
--   p_child_node_type              Y    varchar2 Child node type code.
--   p_parent_node_type             N    varchar2 Parent Node Type code.
--
--
-- Post Success:
--   The new row is inserted into PER_GEN_HIER_NODE_TYPES.
--
-- Post Failure:
--   The procedure does not create the new row.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure create_node_type (p_hierarchy_type   in varchar2,
                            p_child_value_set  in varchar2,
                            p_child_node_type  in varchar2,
                            p_parent_node_type in varchar2 default null);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
--
--
-- {Start Of Comments}
--
-- Description:
--   This procedure updates a row in the table PER_GEN_HIER_NODE_TYPES.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_type		    Y    varchar2 Hierarchy type code.
--   p_child_value_set              Y    varchar2 Value set name.
--   p_child_node_type              Y    varchar2 Child node type code.
--   p_parent_node_type             N    varchar2 Parent Node Type code.
--
-- In out Parameters:
--   Name                           Reqd Type     Description
--   p_object_version_number        Y    number   Object version number.
--
-- Post Success:
--   The row is updated in PER_GEN_HIER_NODE_TYPES.
--
-- Post Failure:
--   The procedure does not update the row.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure update_node_type (p_hierarchy_type   in varchar2,
                            p_child_value_set  in varchar2,
                            p_child_node_type  in varchar2,
                            p_parent_node_type in varchar2 default null,
                            p_object_version_number in out NOCOPY number);

-- ----------------------------------------------------------------------------
-- |--------------------------< delete_node_type >---------------------------|
-- ----------------------------------------------------------------------------
--
--
--
-- {Start Of Comments}
--
-- Description:
--   This procedure deletes a row in the table PER_GEN_HIER_NODE_TYPES.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_type               Y    varchar2 Hierarchy type code.
--   p_child_node_type              Y    varchar2 Child node type code.
--   p_parent_node_type             N    varchar2 Parent Node Type code.
--
--
-- Post Success:
--   The row is deleted from PER_GEN_HIER_NODE_TYPES.
--
-- Post Failure:
--   The row is not deleted.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}

Procedure delete_node_type (p_hierarchy_type   in varchar2,
                            p_child_node_type  in varchar2,
                            p_parent_node_type in varchar2 default null);

--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_type_structure >-----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
--   This procedure deletes all rows for a HIERARCHY_TYPE from the table
--   PER_GEN_HIER_NODE_TYPES.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_type		    Y    varchar2 Hierarchy type code.
--
--
-- Post Success:
--   The rows for the HIERARCHY_TYPE are deleted.
--
-- Post Failure:
--   The rows are not deleted.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}

Procedure delete_type_structure (p_hierarchy_type   in varchar2);
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_hierarchy_version >----------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This procedure is a wrapper over PQH_DE_OPR_GRP.copy_hierarchy_version
--   to copy a hierarchy and/or hierarchy version into another.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_type       		    Y    varchar2 Identifier Flag.
--                                                Pass 'H' to copy hierarchy
--                                                and version, 'V' for version
--                                                alone.
--   p_name 			    N    varchar2 Name of new hierarchy.
--   p_hierarchy_id                 N    number   Hierarchy Id
--   p_hierarchy_version_id         N    number   Hierarchy Version Id
--   p_version_number               N    number   Hierarchy Version Number
--   p_date_from                    N    date     Start date of hierarchy
--                                                version
--   p_date_to                      N    date     End Date of hierarchy
--                                                version
--   p_business_group_id            Y    number   Business Group Id.
--
--   Out Parameters:
--   Name                                Type     Description
--   p_new_hierarchy_id                  number   New hierarchy Id.
--   p_new_hierarchy_version_id          number   New hierarchy version id.
--
--
-- Post Success:
-- The hierarchy and/or hierarchy version is copied.
--
-- Post Failure:
-- The copy operation is not performed.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Procedure copy_hierarchy_version ( p_type              in varchar2
                                  ,p_name              in varchar2  Default null
                                  ,p_hierarchy_id      in Number Default null
                                  ,p_hierarchy_version_id in Number Default null
                                  ,p_version_number    in Number Default null
                                  ,p_date_from         in Date   Default null
                                  ,p_date_to           in Date   Default null
                                  ,p_business_group_id in Number
                                  ,p_effective_date    in Date
                                  ,p_new_hierarchy_id  out NOCOPY Number
                                  ,p_new_hierarchy_version_id out NOCOPY Number);
--
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< is_valid_sql >----------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This function identifies if a value set query is valid or not.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_sql       		    Y    varchar2 Value set query.
--
-- Post Success:
-- Returns 'Y' if the sql is valid. Else, Returns 'N'.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

Function is_valid_sql (p_sql   in varchar2)
Return Varchar2;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< validate_vets_hierarchy >---------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This function validates Vets hierarchies for reports.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_version_id         Y    Number   Id of the hierarchy version.
--
-- Post Success:
-- Returns 'Y' if the node type in the first level is 'PAR', second level
-- is 'EST', third level is 'LOC', and if the number of levels in the
-- hierarchy version is either 2 or 3.Else returns 'N'
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
Function validate_vets_hierarchy(p_hierarchy_version_id in Number)
Return Varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< get_display_value >--------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This function gets the display value for nodes.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_entity_id       		    Y    varchar2 Entity id of the node.
--   p_node_type_id                 Y    number   id of the row in
--                                                PER_GEN_HIER_NODE_TYPES
--                                                corresponding to the node.
--
-- Post Success:
-- Returns the value of the node if it has validation or the entity id itself.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

Function get_display_value(p_entity_id    IN VARCHAR2,
                           p_node_type_id IN NUMBER)
Return Varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< gen_hier_exists >-------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This function identifies if any hierarchy exists of a hierarchy type.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_type 		    Y    varchar2 Hierarchy Type
--
-- Post Success:
-- Returns 'Y' if any hierarchy exists of the given type.Else 'N'.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

--
Function gen_hier_exists(p_hierarchy_type in Varchar2)
Return Varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_multiple_versions >------------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
--   This function identifies if there are more than one version for a
--   hierarchy.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_hierarchy_id  		    Y    number   Hierarchy Id.
--
-- Post Success:
-- Returns 'Y' if more than one version exists for the hierarchy.
-- Else, Returns 'N'.
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

Function chk_multiple_versions (p_hierarchy_id in Number)
Return Varchar2 ;

Function Node_Sequence(P_Hierarchy_version_id  IN Number,
                       P_Parent_Hierarchy_Id   IN Number)
                       Return Number;

Procedure copy_Hierarchy
(P_Hierarchy_version_id             IN Number,
 P_Parent_Hierarchy_id              IN Number,
 P_Hierarchy_Id                     IN Number,
 p_Business_group_Id                IN Number,
 p_Effective_Date                   IN Date);

Procedure Main
(P_Type                             IN Varchar2,
 P_Trntype                          IN Varchar2,
 P_Code                             IN Varchar2  Default NULL,
 P_Description                      IN Varchar2  Default NULL,
 p_Code_Id                          IN Number    Default NULL,
 P_Hierarchy_version_id             IN Number    Default NULL,
 P_Parent_Hierarchy_id              IN Number    Default NULL,
 P_Hierarchy_Id                     IN Number    Default NULL,
 p_Object_Version_Number            IN Number    Default NULL,
 p_Business_group_Id                IN Number  ,
 p_Effective_Date                   IN Date);

End;

 

/
