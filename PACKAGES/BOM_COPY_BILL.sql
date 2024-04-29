--------------------------------------------------------
--  DDL for Package BOM_COPY_BILL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COPY_BILL" AUTHID CURRENT_USER AS
/* $Header: BOMCPYBS.pls 120.13.12010000.2 2011/06/16 10:06:48 gliang ship $ */
/*==========================================================================+
|   Copyright (c) 1995 Oracle Corporation, California, USA                  |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMPCPYBS.pls                                              |
| Description  : Bill copy package                                          |
| Created By   : Manu Chadha                                                |
|                                                                           |
|  from_org_id    Copy from org id                                          |
|  to_org_id      Copy to org id                                            |
|  from_sequence_id  Copy from bill sequence id                             |
|  to_sequence_id    Copy to bill sequence id                               |
|  display_option    copy option                                            |
|           1 - all (not supported from form)                               |
|           2 - current                                                     |
|           3 - current + future                                            |
|  user_id        user id                                                   |
|  to_item_id     Copy to item id                                           |
|  direction      direction of copy                                         |
|           1 - BOM to BOM                                                  |
|           2 - BOM to ENG                                                  |
|           3 - ENG to ENG                                                  |
|           4 - ENG to BOM                                                  |
|  to_alternate      Copy to alternate designator                           |
|  rev_date    Revision date to copy                                        |
|  err_msg        Error message                                             |
|  error_code     Error code                                                |
|                                                                           |
|  15-SEP-2003    Ezhilarasan   Added overloaded copy_bill                  |
|                               procedure for specific components,          |
|                               reference designators, substitute components|
|                               copy etc.,                                  |
+==========================================================================*/

   bom_application_id   CONSTANT NUMBER (3) := 702;

   PROCEDURE copy_bill (
      to_sequence_id     IN   NUMBER,
      from_sequence_id   IN   NUMBER,
      from_org_id        IN   NUMBER,
      to_org_id          IN   NUMBER,
      display_option     IN   NUMBER DEFAULT 2,
      user_id            IN   NUMBER DEFAULT -1,
      to_item_id         IN   NUMBER,
      direction          IN   NUMBER DEFAULT 1,
      to_alternate       IN   VARCHAR2,
      rev_date           IN   DATE,
      e_change_notice    IN   VARCHAR2,
      rev_item_seq_id    IN   NUMBER,
      bill_or_eco        IN   NUMBER,
      eco_eff_date       IN   DATE,
      eco_unit_number    IN   VARCHAR2 DEFAULT NULL,
      unit_number        IN   VARCHAR2 DEFAULT NULL,
      from_item_id       IN   NUMBER
   );

	-- Start of comments
	--	API name 	: copy_bill
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Copies from the source structure (from_sequence_id)
	--                to target structure (to_sequence_id).
	--	Parameters	:
	--	IN		:	to_sequence_id   	IN NUMBER	Required
	--				    Target structure's bill sequence id
	--              from_sequence_id    IN NUMBER   Required
	--                  Source structure's bill sequence id
	--              from_org_id         IN NUMBER   Required
	--                  Source structure's organization id
	--              to_org_id           IN NUMBER   Required
	--                  Target structure's organization id
	--              display_option      IN NUMBER   Optional
	--				    Effectivity Filter criteria for explosion
	--              user_id             IN NUMBER   Optional
	--                  User Id of the user who launches this process
	--              to_item_id          IN NUMBER   Required
	--                  Target Structure's Item Id
	--              direction           IN NUMBER   Optional
	--                  Specifies the type of source and target structure combination
	--              to_alternate        IN VARCHAR2 Required
	--                  Target Structure's structure name
	--              rev_date            IN DATE     Required
	--                  Date on which source structure needs to be exploded
	--              e_change_notice     IN VARCHANR2  Optional
	--                  Change Notice Name
	--              rev_item_seq_id     IN NUMBER   Optional
	--                  Revised Item Sequence Id of Target Structure's Item
	--              bill_or_eco         IN NUMBER   Optional
	--                  Copy operation needs to create a structure or eco
	--              eco_eff_date        IN DATE     Optional
	--                  Effectivity Date for components if copy operation creates eco
	--              eco_unit_number     IN VARCHAR2 Optional
	--                  Unit number for components if copy operation creates eco
	--              unit_number         IN VARCHAR2 Optional
	--                  Unit Number of the source structure components
	--              from_item_id        IN NUMBER   Required
	--                  Source structure's item id
	--              specific_copy_falg  IN VARCHAR2 Required
	--                  Flag specifies whether copy operation need to copy all or not
	--              copy_all_comps_flag  IN VARCHAR2 Optional
	--                  Flag specifies whether all components needs to be copied
	--              copy_all_rfds_flag  IN VARCHAR2 Optional
	--                  Flag specifies whether all reference designators needs to be copied
	--              copy_all_subcomps_flag  IN VARCHAR2 Optional
	--                  Flag specifies whether all substitute components needs to be copied
	--              copy_attach_flag    IN VARCHAR2 Optional
	--                  Flag specifies whether attachments needs to be copied
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	--              eco_end_item_rev_id IN NUMBER  Optional
	--                  End Item Revision Id for revision eff components in created ttm eco
	--              contex_eco IN VARCHAR2 Optional
	--                  ECO context from which the source structure has been exploded
    --              trgt_comps_eff_date IN DATE  Optional
	--                  Effectivity Date for the target structure's components
	--              trgt_comps_unit_number IN VARCHAR2  Required
	--                 Unit number for the target structure's components
	--              trgt_comps_end_item_rev_id IN NUMBER Optional
	--                 End Item Rev Id for the target structure's components
	--              p_parent_sort_order  IN VARCHAR2 Required
	--                 Sort Order of the current structure which is being processed
	-- End of comments

   PROCEDURE copy_bill (
      to_sequence_id               IN   NUMBER,
      from_sequence_id             IN   NUMBER,
      from_org_id                  IN   NUMBER,
      to_org_id                    IN   NUMBER,
      display_option               IN   NUMBER DEFAULT 2,
      user_id                      IN   NUMBER DEFAULT -1,
      to_item_id                   IN   NUMBER,
      direction                    IN   NUMBER DEFAULT 1,
      to_alternate                 IN   VARCHAR2,
      rev_date                     IN   DATE,
      e_change_notice              IN   VARCHAR2,
      rev_item_seq_id              IN   NUMBER,
      bill_or_eco                  IN   NUMBER,
      eco_eff_date                 IN   DATE,
      eco_unit_number              IN   VARCHAR2 DEFAULT NULL,
      unit_number                  IN   VARCHAR2 DEFAULT NULL,
      from_item_id                 IN   NUMBER,
      -- Flag to identify whether all the components are copied or specific components are copied.
      specific_copy_flag           IN   VARCHAR2,
      copy_all_comps_flag          IN   VARCHAR2 DEFAULT 'N',
      copy_all_rfds_flag           IN   VARCHAR2 DEFAULT 'N',
      copy_all_subcomps_flag       IN   VARCHAR2 DEFAULT 'N',
      -- copy_all_compops_flag IN VARCHAR2 DEFAULT 'N',
      copy_attach_flag             IN   VARCHAR2 DEFAULT 'Y',
      -- Request Id for this copy operation.  Value from BOM_COPY_STRUCTURE_REQUEST_S
      p_copy_request_id            IN   NUMBER,
      -- End Item Rev Id from which the copied components should be effective
      eco_end_item_rev_id          IN   NUMBER DEFAULT NULL,
      -- Structure has been exploded in context of this ECO for copying
      context_eco                  IN   VARCHAR2 DEFAULT NULL,
	  -- End Item Revision for which the source structure has been exploded
	  p_end_item_rev_id            IN   NUMBER DEFAULT NULL,
      -- Effectivity Date, End Item Unit Number and End Item Rev Id
      -- for the components which are getting copied.  Components from effectivity boundary.
      trgt_comps_eff_date          IN   DATE DEFAULT NULL,
      trgt_comps_unit_number       IN   VARCHAR2 DEFAULT NULL,
      trgt_comps_end_item_rev_id   IN   NUMBER DEFAULT NULL,
      -- Since the JOIN occurs with bom_explosions_v, there could be multiple
      -- sub-assemblies (items) in the exploded structure at different levels
      -- but if we copy once that will be suffice
      p_parent_sort_order          IN   VARCHAR2 DEFAULT NULL,
      p_cpy_disable_fields         IN   VARCHAR2 DEFAULT 'N',
	  p_trgt_str_eff_ctrl          IN   NUMBER DEFAULT 1,
	  p_trgt_str_type_id           IN   NUMBER DEFAULT NULL
   );

   /* This function is no longer required.  03-Jan-2006 Bug 4916826
	-- Start of comments
	--	API name 	: get_component_path
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the component path with '>' delimited item names from top item.
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_org_id        IN NUMBER   Required
	--                  Source sructure's organization
	--              p_explode_grp_id  IN NUMBER  Required
	--                  Explode Groupd Id of the Source Structure
	--              p_sort_order      IN VARHCAR2  Required
	--                  Component position in the exploded source structure
	-- End of comments
   FUNCTION get_component_path (
      p_item_id          IN   NUMBER,
      p_org_id           IN   NUMBER,
      p_explode_grp_id   IN   NUMBER,
      p_sort_order       IN   VARCHAR2
   )
      RETURN VARCHAR2;*/

	-- Start of comments
	--	API name 	: get_current_item_rev
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the current item rev on given date
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_org_id        IN NUMBER   Required
	--                  Source sructure's organization
	--              p_rev_date      IN DATE     Required
	--                  Date for which revision needs to be found
	-- End of comments
   FUNCTION get_current_item_rev (
      p_item_id    IN   NUMBER,
      p_org_id     IN   NUMBER,
      p_rev_date   IN   DATE
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: GET_MESSAGE
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_comp_item     IN VARCAHR2 Required
	--                  Component Item Name For which the error is being thrown
	-- End of comments
   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_comp_item IN VARCHAR2)
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: GET_MESSAGE
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_comp_item     IN VARCAHR2 Required
	--                  Component Item Name For which the error is being thrown
	--              p_assembly_item IN VARCAHR2 Required
	--                  Assembly Item Name For which the error is being thrown
	-- End of comments
   FUNCTION GET_MESSAGE (
      p_msg_name        IN   VARCHAR2,
      p_comp_item       IN   VARCHAR2,
      p_assembly_item   IN   VARCHAR2
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_cnt_message
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_assembly_item IN VARCAHR2 Required
	--                  Assembly Item Name For which the error is being thrown
	--              p_comp_count    IN NUMBER Required
	--                  Number of components For which the error is being thrown
	-- End of comments
   FUNCTION get_cnt_message (
      p_msg_name        IN   VARCHAR2,
      p_assembly_item   IN   VARCHAR2,
      p_comp_count      IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_comp_type_rule_message
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_assembly_item IN VARCAHR2 Required
	--                  Assembly Item Name For which the error is being thrown
	--              p_parent_item_type IN VARCAHR2 Required
	--                  Assembly Item's Item Type
	--              p_component_item IN VARCAHR2 Required
	--                  Component Item Name For which the error is being thrown
	--              p_component_item_type          IN VARCAHR2 Required
	--                  Component Item's Item Type
	-- End of comments
   FUNCTION get_comp_type_rule_message (
      p_msg_name            IN    VARCHAR2,
	  p_assembly_item       IN    VARCHAR2,
	  p_parent_item_type    IN    VARCHAR2,
      p_component_item      IN    VARCHAR2,
	  p_component_item_type IN    VARCHAR2
	) RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: GET_MESSAGE
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_comp_item     IN VARCAHR2 Required
	--                  Component Item Name For which the error is being thrown
	--              p_assembly_item IN VARCAHR2 Required
	--                  Assembly Item Name For which the error is being thrown
	--              p_comp_rev        IN VARCHAR2 Required
	--                  Component revision which does not exist in destination organization.
	-- End of comments
   FUNCTION GET_MESSAGE (
      p_msg_name        IN   VARCHAR2,
      p_comp_item       IN   VARCHAR2,
      p_assembly_item   IN   VARCHAR2,
      p_comp_rev        IN   VARCHAR2
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: revision_exists
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Checks whether revision exists
	--	Parameters	:
	--	IN		:	p_from_item_id	IN NUMBER Required
	--				    Source structure's item id
	--              p_from_org_id   IN NUMBER Required
	--                  Source structure's organization id
	--              p_revision_id   IN NUMBER Required
	--                  Revision Id of the assembly item
	-- End of comments
   FUNCTION revision_exists (
      p_from_item_id   IN   NUMBER,
      p_from_org_id    IN   NUMBER,
      p_revision_id    IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_max_minorrev
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the max minor revision for given item
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_org_id        IN NUMBER   Required
	--                  Source sructure's organization
	--              p_revision_id   IN NUMBER Required
	--                  Revision Id of the item
	-- End of comments
   FUNCTION get_max_minorrev (
      p_item_id       IN   NUMBER,
      p_org_id        IN   NUMBER,
      p_revision_id   IN   NUMBER
   )
      RETURN NUMBER;

	-- Start of comments
	--	API name 	: get_revision
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the revision for given item
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_org_id        IN NUMBER   Required
	--                  Source sructure's organization
	--              p_revision_id   IN NUMBER Required
	--                  Revision Id of the item
	-- End of comments
   FUNCTION get_revision (
      p_item_id       IN   NUMBER,
      p_org_id        IN   NUMBER,
      p_revision_id   IN   NUMBER
   )
      RETURN NUMBER;

	-- Start of comments
	--	API name 	: get_minor_rev_code
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the minor rev code for the given minor rev id
	--	Parameters	:
	--	IN		:	p_end_item_rev_id IN NUMBER	Required
	--				    End Item Revision Id
	--              p_end_item_minor_rev_id IN NUMBER   Required
	--                  End Item Minor Revision Id
	-- End of comments
   FUNCTION get_minor_rev_code (
      p_end_item_rev_id         IN   NUMBER,
      p_end_item_minor_rev_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: assign_items_to_copy_to_org
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Assigns the items to the target organization
	--	Parameters	:
	--	IN		:	p_cp_request_id IN NUMBER	Required
	--				    Concurrent Program Request Id
	--              p_copy_request_id IN NUMBER   Required
	--				    Copy Request Id
	--              p_from_org_id   IN NUMBER Required
	--                  Source structure's organization id
	--              p_to_org_id     IN NUMBER Required
	--                  Target structure's organization id
	--              p_to_org_code   IN VARCHAR2 Required
	--                  Target structure organization's code
	--              p_usr_id        IN NUMBER Required
	--                  User who triggered this copy process
	--              p_context_eco   IN VARCHAR2 Required
	--                  Context ECO for explosion
	-- End of comments
   PROCEDURE assign_items_to_copy_to_org (
      p_cp_request_id     IN   NUMBER,
      p_copy_request_id   IN   NUMBER,
      p_from_org_id       IN   NUMBER,
      p_to_org_id         IN   NUMBER,
      p_to_org_code       IN   VARCHAR2,
      p_usr_id            IN   NUMBER,
      p_context_eco       IN   VARCHAR2,
	  p_to_item_id        IN   NUMBER,
	  p_master_org_id     IN   NUMBER
   );

	-- Start of comments
	--	API name 	: purge_processed_copy_requests
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Purge processed copy requests for the given status
	--	Parameters	:
	--	IN		:	p_request_status IN VARCHAR2 Required
	--				    Copy Request Status
	-- End of comments
   PROCEDURE purge_processed_copy_requests (p_request_status IN VARCHAR2);

	-- Start of comments
	--	API name 	: purge_processed_request_errors
	--	Type		: private
	--	Pre-reqs	: Structure shoule be exploded.
	--	Function	: Purge processed copy request errors for the given status
	--	Parameters	:
	--	IN		:	p_request_status IN VARCHAR2 Required
	--				    Copy Request Status
	-- End of comments
   PROCEDURE purge_processed_request_errors (p_request_status IN VARCHAR2);

	-- Start of comments
	--	API name 	: get_item_exists_in
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the list of organization in which item exists
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	-- End of comments
   FUNCTION get_item_exists_in (
      p_item_id           IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_structure_exists_in
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the list of organization in which structure exists
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	-- End of comments
   FUNCTION get_structure_exists_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_common_structure_exists_in
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the list of organization in which common structure exists
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	-- End of comments
   FUNCTION get_common_structure_exists_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_assign_items_in
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the list of organization in which item needs to be assigned
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	-- End of comments
   FUNCTION get_assign_items_in (
      p_item_id           IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_copy_structures_in
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the list of organization in which structure needs to be copied
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	-- End of comments
   FUNCTION get_copy_structures_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_common_structures_in
	--	Type		: private
	--	Pre-reqs	: Structure shoule have been exploded.
	--	Function	: Gets the list of organization in which common structure needs to be created
	--	Parameters	:
	--	IN		:	p_item_id   	IN NUMBER	Required
	--				    Component's item id
	--              p_copy_request_id   IN NUMBER   Required
	--                  Request Id of the copy operation.
	-- End of comments
   FUNCTION get_common_structures_in (
      p_item_id       IN   NUMBER,
      p_copy_request_id   IN   NUMBER
   )
      RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: get_org_list_for_hierarchy
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets the list of organization in the given organization hierarchy name
	--	Parameters	:
	--	IN		:	p_hierarchy_name IN VARCHAR2	Required
	--				    Organization Hierarchy Name
	--              p_org_id   IN NUMBER Required
	--                  Organization from which the hierarchy needs to be found
	--              p_item_id  IN NUMBER Required
	--                  Target structure's item
	--              p_structure_name IN NUMBER Required
	--                  Target structure's structure name
	--  OUT     :   x_org_list_tbl OUT NUM_VARRAY
	--                  List of organization Ids
	--              x_org_code_tbl OUT VARCHAR2_VARRAY
	--                  List of organization codes
	--              x_org_name_tbl OUT VARCHAR2_VARRAY
	--                  List of organization names
	--              x_assembly_type_tbl OUT NUM_VARRAY
	--                  List of assembly types for corresponding orgs
	--              x_item_rev_tbl OUT VARCHAR2_VARRAY
	--                  List of item revisions in the corresponding orgs
	--              x_item_rev_id_tbl OUT NUM_VARRAY
	--                  List of item revision ids in the corresponding orgs
	--              x_item_rev_lbl_tbl OUT VARCHAR2_VARRAY
	--                  List of item revision labels in the corresponding orgs
	--              x_item_exists_tbl OUT VARCHAR2_ARRAY
	--                  List of flags which specifies whether p_item_id exists in corresponding orgs
	-- End of comments
    PROCEDURE get_org_list_for_hierarchy (
       p_hierarchy_name     IN     VARCHAR2,
	   p_org_id             IN     NUMBER,
	   p_item_id            IN     NUMBER,
	   p_structure_name     IN     VARCHAR2,
	   p_effectivity_date   IN     DATE,
       x_org_list_tbl       OUT    NOCOPY num_varray,
	   x_org_code_tbl       OUT    NOCOPY varchar2_varray,
	   x_org_name_tbl       OUT    NOCOPY varchar2_varray,
	   x_org_structure_tbl  OUT    NOCOPY num_varray,
	   x_assembly_type_tbl  OUT    NOCOPY num_varray,
	   x_item_rev_tbl       OUT    NOCOPY varchar2_varray,
	   x_item_rev_id_tbl    OUT    NOCOPY num_varray,
	   x_item_rev_lbl_tbl   OUT    NOCOPY varchar2_varray,
	   x_item_exists_tbl    OUT    NOCOPY varchar2_varray,
	   x_return_status      OUT NOCOPY VARCHAR2,
	   x_error_msg          OUT NOCOPY VARCHAR2
	  );

    PROCEDURE update_created_by (
	  p_user_id IN NUMBER
	  ,p_to_bill_sequence_id IN NUMBER );

    PROCEDURE copy_bill_for_revised_item
    (
      to_sequence_id               IN   NUMBER,
      from_sequence_id             IN   NUMBER,
      from_org_id                  IN   NUMBER,
      to_org_id                    IN   NUMBER,
      user_id                      IN   NUMBER DEFAULT -1,
      to_item_id                   IN   NUMBER,
      direction                    IN   NUMBER DEFAULT 1,
      to_alternate                 IN   VARCHAR2,
      rev_date                     IN   DATE,
      e_change_notice              IN   VARCHAR2,
      rev_item_seq_id              IN   NUMBER,
      eco_eff_date                 IN   DATE,
      eco_unit_number              IN   VARCHAR2 DEFAULT NULL,
      unit_number                  IN   VARCHAR2 DEFAULT NULL,
      from_item_id                 IN   NUMBER,
      -- Request Id for this copy operation.  Value from BOM_COPY_STRUCTURE_REQUEST_S
      -- To populate the errors in MTL_INTERFACE_ERRORS with this transaction id
      p_copy_request_id            IN   NUMBER,
      --  Unit number for copy to item
      eco_end_item_rev_id          IN   NUMBER DEFAULT NULL,
      -- Structure has been exploded in context of this ECO for copying
      context_eco                  IN   VARCHAR2 DEFAULT NULL,
      p_end_item_rev_id            IN   NUMBER DEFAULT NULL,
      -- Since the JOIN occurs with bom_explosions_v, there could be multiple
      -- sub-assemblies (items) in the exploded structure at different levels
      -- but if we copy once that will be suffice
      p_parent_sort_order          IN   VARCHAR2 DEFAULT NULL,
      p_trgt_str_eff_ctrl          IN   NUMBER DEFAULT 1,
      -- Flag which specifies whether past effective component needs to be copied
      -- This will be 'Y' only for first revised item created
      p_cpy_past_eff_comps         IN   VARCHAR2 DEFAULT 'Y',
	  p_trgt_str_type_id           IN   NUMBER   DEFAULT NULL
    );
	PROCEDURE copy_attachments(p_from_sequence_id IN NUMBER,
	                            p_to_sequence_id   IN NUMBER,
								p_user_id          IN NUMBER);


	-- Start of comments
	--	API name 	: check_component_type_rules
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Checks the component type rules and returns the error msg
	--                if the validation fails
	--	Parameters	:
	--	IN	  	    : p_component_item_id IN NUMBER Required
	--				   Component Item Name
	--                p_assembly_item_id IN NUMBER Required
	--                 Assembly Item Name
	--                p_organization_id IN NUMBER Required
	--                 Organization Id
	-- Returns      : Error Message if validation fails else null
	-- Purpose      : To validate the components and insert error messages
	--                to errors table if required.
	-- End of comments
	FUNCTION check_component_type_rules(p_component_item_id IN NUMBER,
	                                    p_assembly_item_id IN NUMBER,
										p_org_id IN NUMBER
									    ) RETURN VARCHAR2;

-- Bug 11868441 - sun: issue with bom commoning when any subassembly is on unimplemented eco
  PROCEDURE ASSIGN_ECO_COMP_TO_ORGS(
        p_api_version                   IN  NUMBER,
        p_organization_id               IN  NUMBER,
        p_bill_sequence_id              IN  NUMBER    DEFAULT NULL,
        x_return_status                 OUT NOCOPY   VARCHAR2,
        x_msg_data                      OUT NOCOPY  VARCHAR2);

END bom_copy_bill;

/
