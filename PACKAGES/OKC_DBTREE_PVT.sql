--------------------------------------------------------
--  DDL for Package OKC_DBTREE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_DBTREE_PVT" AUTHID CURRENT_USER AS
/*$Header: OKCTREES.pls 120.0 2005/05/25 23:01:28 appldev noship $*/
--
--===================
-- TYPES
--===================
--

  TYPE TreeDataRec is RECORD
   (
        tree_initial_state		NUMBER
        ,tree_depth			NUMBER
        ,tree_label			VARCHAR2(255)
        ,tree_icon_name			VARCHAR2(255)
        ,tree_data			VARCHAR2(255)
        ,tree_node_id                   NUMBER
        ,tree_node_type                 VARCHAR2(4)
        ,tree_parent_node_id            NUMBER
        ,tree_level_number              NUMBER
        ,tree_num_children              NUMBER
   );

  TYPE  ResultRec IS RECORD
  (
         initial_state                  NUMBER
         ,tree_depth                    NUMBER
         ,node_label                    VARCHAR2(255)
         ,node_icon                     VARCHAR2(255)
         ,node_data                     VARCHAR2(255)
         ,node_children                 NUMBER
  );

  TYPE ErrorRec IS RECORD
   (
	 error_type			VARCHAR2(10)
	,error_message			VARCHAR2(255)
	,package_name			VARCHAR2(100)
	,program_name			VARCHAR2(100)
	,entry_point			NUMBER
   );

  TYPE IndexControlRec IS RECORD
   (
        tree_id                         NUMBER
	,node_number			NUMBER
        ,start_ind                      NUMBER
        ,end_ind                        NUMBER
        ,num_entries                    NUMBER
	,current_set			NUMBER
   );


  TYPE TreeDataTableType IS TABLE OF TreeDataRec;

  TYPE ErrorStack IS TABLE OF ErrorRec
	INDEX BY BINARY_INTEGER;

  TYPE IndexControlTable IS TABLE of IndexControlRec;

  TYPE ResultRecTableType IS TABLE OF ResultRec
        INDEX BY BINARY_INTEGER;

--
--===================
-- Table Definitions
--===================
--

  tDataTable           TreeDataTableType;

  IControlTable        IndexControlTable;

  ResultTable          ResultRectableType;

--===================
-- CONSTANTS
--===================
--
	PackageStateInd			NUMBER := 0;
	ActiveTreeID			NUMBER := 0;
        icon_name               CONSTANT VARCHAR2(08) := 'affldhdr';

--===================
-- PUBLIC VARIABLES
--===================
-- add your public global variables here if any

--===================
-- PROCEDURES AND FUNCTIONS
--===================
--
	PROCEDURE push_error
			(p_package_name		IN	VARCHAR2
			,p_program_name		IN	VARCHAR2
			,p_entry_point		IN	NUMBER
			,p_error_type		IN	VARCHAR2
			,p_error_msg		IN	VARCHAR2
			 );

	PROCEDURE pop_error
			(p_delete_flag		IN	BOOLEAN
			,p_Package_name	 OUT NOCOPY VARCHAR2
			,p_program_name	 OUT NOCOPY VARCHAR2
			,p_entry_point	 OUT NOCOPY NUMBER
			,p_error_type	 OUT NOCOPY VARCHAR2
			,p_error_msg	 OUT NOCOPY VARCHAR2
			);

	PROCEDURE clear_stack;

     FUNCTION  Get_Data_Parameter
                        (p_data_string          IN      VARCHAR2,
                         p_parm_name            IN      VARCHAR2
                        )
     RETURN VARCHAR2;

	FUNCTION  Get_Tree_ID
			(p_tree_name		IN	VARCHAR2
			)
	RETURN NUMBER;

	PROCEDURE ClearNodeCache
			(p_tree_id		IN  NUMBER
                         ,p_node_number         IN  NUMBER
			);

     PROCEDURE ProcessRootNode
                        (p_tree_id              IN  NUMBER
                         ,p_access_flag         IN  VARCHAR2);

     PROCEDURE ReturnChildrenNodes
                        (p_tree_id              IN  NUMBER
                         ,p_node_number         IN  NUMBER
                         ,p_reload_flag         IN  VARCHAR2
                         ,p_nodes_out           OUT NOCOPY NUMBER
                         ,p_Result_table        OUT NOCOPY okc_dbtree_pvt.ResultRecTableType);

        PROCEDURE LoadNodeChildren
                        (p_tree_id		IN  NUMBER
                         ,p_node_number         IN  NUMBER
                         ,p_reload_flag         IN  VARCHAR2
                         ,p_nodes_out           OUT NOCOPY NUMBER);

        PROCEDURE Initialize_Package;

END okc_dbtree_pvt;              -- end of package specification

 

/
