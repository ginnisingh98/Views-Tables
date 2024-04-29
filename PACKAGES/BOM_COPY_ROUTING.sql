--------------------------------------------------------
--  DDL for Package BOM_COPY_ROUTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_COPY_ROUTING" AUTHID CURRENT_USER AS
/* $Header: BOMCPYRS.pls 120.10 2006/05/17 21:07:41 earumuga noship $ */
/*#
* This API contains the methods for copying Routing.
* @rep:scope private
* @rep:product BOM
* @rep:displayname Routing Copy
* @rep:lifecycle active
* @rep:category BUSINESS_ENTITY BOM_MFG_ROUTING
*/
/*==========================================================================+
|   Copyright (c) 1995 Oracle Corporation, California, USA                  |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : BOMCPYRS.pls                                               |
| Description  : Routing copy package specification                         |
| Created By   : Manu Chadha                                                |
|                                                                           |
|   from_org_id     Copy from org id                                        |
|   to_org_id       Copy to org id                                          |
|   from_sequence_id    Copy from routing sequence id                       |
|   to_sequence_id      Copy to routing sequence id                         |
|   display_option      copy option                                         |
|               1 - all (not supported from form)                           |
|               2 - current                                                 |
|               3 - current + future                                        |
|   user_id         user id                                                 |
|   to_item_id      Copy to item id                                         |
|   direction       direction of copy                                       |
|               1 - BOM to BOM                                              |
|               2 - BOM to ENG                                              |
|               3 - ENG to ENG                                              |
|               2 - ENG to BOM                                              |
|   to_alternate        Copy to alternate designator                        |
|   rev_date        Revision date to copy                                   |
|   err_msg         Error message                                           |
|   error_code      Error code                                              |
|                                                                           |
|   30-Jun-2005    Ezhilarasan  Added new overloaded procedure to support   |
|                               copy routing in context of eco              |
+==========================================================================*/
/*#
* copy_routing will copy a routing for a given item to the item id supplied.
* @param to_sequence_id Destination Sequence Id to which routing will be copied
* @param from_sequence_id Source Sequence Id from which routing will be copied
* @param from_org_id Source Organization Id from which routing will be copied
* @param to_org_id Destination Organization Id to which routing will be copied
* @param display_option Effectivity Filter criteria for routing operations (all, current, current+future)
* @param user_id user id
* @param to_item_id item id to which routing is copied
* @param direction direction of copy (BOM to BOM, BOM to ENG,ENG to BOM,ENG to ENG)
* @param to_alternate Copy to alternate designator
* @param rev_date Revision date to copy
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Copy Routing
*/
   PROCEDURE copy_routing (
      to_sequence_id     IN   NUMBER,
      from_sequence_id   IN   NUMBER,
      from_org_id        IN   NUMBER,
      to_org_id          IN   NUMBER,
      display_option     IN   NUMBER DEFAULT 2,
      user_id            IN   NUMBER DEFAULT -1,
      to_item_id         IN   NUMBER,
      direction          IN   NUMBER,
      to_alternate       IN   VARCHAR2,
      rev_date                DATE
   );

/*#
* switch_to_primary_rtg will set alternate routing designator in bom_operational_routings.
* @param p_org_id Organization id
* @param p_ass_itm_id Assembly Item Id
* @param p_alt_rtg_desg Alternate Routings Designator
* @param p_alt_desg_for_prim_rtg Alternate Routings Designator for primary routing
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Switch To Primary Routing
*/
   PROCEDURE switch_to_primary_rtg (
      p_org_id                  IN   NUMBER,
      p_ass_itm_id              IN   NUMBER,
      p_alt_rtg_desg            IN   VARCHAR2,
      p_alt_desg_for_prim_rtg   IN   VARCHAR2
   );
/*#
* switch_rtg_validate will set alternate routing designator in bom_operational_routings.
* @param p_org_id Organization id
* @param p_ass_itm_id Assembly Item Id
* @param p_alt_rtg_desg Alternate Routings Designator
* @param p_alt_desg_for_prim_rtg Alternate Routings Designator for primary routing
* @param x_return_status Indicating success or faliure
* @param x_message_name Message
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Switch Routing Validate
*/
/*** Added as part of Patchset I enhancement - 2544075 ***/
   PROCEDURE switch_rtg_validate (
      p_org_id                  IN              NUMBER,
      p_ass_itm_id              IN              NUMBER,
      p_alt_rtg_desg            IN              VARCHAR2,
      p_alt_desg_for_prim_rtg   IN              VARCHAR2,
      x_return_status           IN OUT NOCOPY   VARCHAR2,
      x_message_name            IN OUT NOCOPY   VARCHAR2
   );
/*#
* switch_to_primary_rtg will set alternate routing designator in bom_operational_routings.
* @param p_org_id Organization id
* @param p_ass_itm_id Assembly Item Id
* @param p_alt_rtg_desg Alternate Routings Designator
* @param p_alt_desg_for_prim_rtg Alternate Routings Designator for primary routing
* @param x_return_status Return Status to be returned back
* @param x_message_name Message to be passed back
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Switch To Primary Routing
*/
   PROCEDURE switch_to_primary_rtg (
      p_org_id                  IN              NUMBER,
      p_ass_itm_id              IN              NUMBER,
      p_alt_rtg_desg            IN              VARCHAR2,
      p_alt_desg_for_prim_rtg   IN              VARCHAR2,
      x_return_status           IN OUT NOCOPY   VARCHAR2,
      x_message_name            IN OUT NOCOPY   VARCHAR2
   );
	-- Start of comments
	--	API name 	: copy_routing
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Copies routing source sequence id to target sequence id
	--	Parameters	:
	--	IN		:	to_sequence_id IN NUMBER Required
	--				    Routing sequence Id of the target item
	--	    	    from_sequence_id IN NUMBER Required
	--				    Routing sequence Id of the source item
	--              from_org_id         IN NUMBER   Required
	--                  Source item's organization id
	--              to_org_id           IN NUMBER   Required
	--                  Target item's organization id
	--              display_option      IN NUMBER   Optional
	--				    Effectivity Filter criteria for routing operations
	--              user_id             IN NUMBER   Optional
	--                  User Id of the user who launches this process
	--              to_item_id          IN NUMBER   Required
	--                  Target routing's Item Id
	--              direction           IN NUMBER   Optional
	--                  Specifies the type of source and target routing combination
	--              to_alternate        IN VARCHAR2 Required
	--                  Target item's routing alternate name
	--              rev_date            IN DATE     Required
	--                  Date from which source item's operation needs to filterd
	--              p_e_change_notice     IN VARCHANR2  Optional
	--                  Change Notice Name
	--              p_rev_item_seq_id     IN NUMBER   Optional
	--                  Revised Item Sequence Id of Target Structure's Item
	--              p_routing_or_eco         IN NUMBER   Optional
	--                  Copy operation needs to create a structure or eco
	--              p_eco_eff_date        IN DATE     Optional
	--                  Effectivity Date for operations if copy operation creates eco
	--              p_contex_eco IN VARCHAR2 Optional
	--                  ECO context from which the source item's operations are filtered
	--              p_log_errors IN VARCHAR2 Optional
	--                  Flag which specifies whethere errors needs to be logged in mtl_interface_errors
	--              p_copy_request_id IN VARCHAR2 Optional
	--                  To group the errors which have been logged in mtl_interface_errors
	-- End of comments
/*#
* copy_routing Copies routing source sequence id to target sequence id.
* @param to_sequence_id Destination Sequence Id to which routing will be copied
* @param from_sequence_id Source Sequence Id from which routing will be copied
* @param from_org_id Source Organization Id from which routing will be copied
* @param to_org_id Destination Organization Id to which routing will be copied
* @param display_option Effectivity Filter criteria for routing operations (all, current, current+future)
* @param user_id user id
* @param to_item_id item id to which routing is copied
* @param direction direction of copy (BOM to BOM, BOM to ENG,ENG to BOM,ENG to ENG)
* @param to_alternate Copy to alternate designator
* @param rev_date Revision date to copy
* @param p_e_change_notice Change Notice Name
* @param p_rev_item_seq_id  Revised Item Sequence Id of Target Structure's Item
* @param p_routing_or_eco Copy operation needs to create a structure or eco
* @param p_trgt_eff_date Target Effectivity Date for operations
* @param p_eco_eff_date Effectivity Date for operations if copy operation creates eco
* @param p_context_eco ECO context from which the source item's operations are filtered
* @param p_log_errors Flag which specifies whethere errors needs to be logged in mtl_interface_errors
* @param p_copy_request_id To group the errors which have been logged in mtl_interface_errors
* @param p_cpy_disable_fields Flag to copy disable fields
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Copy Routing
*/
   PROCEDURE copy_routing (
      to_sequence_id          IN   NUMBER,
      from_sequence_id        IN   NUMBER,
      from_org_id             IN   NUMBER,
      to_org_id               IN   NUMBER,
      display_option          IN   NUMBER DEFAULT 2,
      user_id                 IN   NUMBER DEFAULT -1,
      to_item_id              IN   NUMBER,
      direction               IN   NUMBER,
      to_alternate            IN   VARCHAR2,
      rev_date                     DATE,
      p_e_change_notice         IN   VARCHAR2,
      p_rev_item_seq_id         IN   NUMBER,
      p_routing_or_eco          IN   NUMBER DEFAULT 1,
	  p_trgt_eff_date           IN   DATE,
      p_eco_eff_date            IN   DATE,
      p_context_eco             IN   VARCHAR2,
	  p_log_errors              IN   VARCHAR2 DEFAULT 'N',
	  p_copy_request_id         IN   NUMBER DEFAULT NULL,
	  p_cpy_disable_fields      IN   VARCHAR2 DEFAULT 'N'
   );

	-- Start of comments
	--	API name 	: GET_MESSAGE
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_op_seq_num    IN NUMBER Required
	--                  Operation Sequence Number which is being processed
	-- End of comments
   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_op_seq_num IN NUMBER)
   RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: GET_MESSAGE
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_op_seq_num    IN NUMBER Required
	--                  Operation Sequence Number which is being processed
	--              p_oper_type     IN VARCHAR2 Required
	--                  Operation Type
	-- End of comments
   FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_op_seq_num IN NUMBER,
        p_oper_type IN VARCHAR2)
   RETURN VARCHAR2;

	-- Start of comments
	--	API name 	: GET_MESSAGE
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Gets message with tokens set
	--	Parameters	:
	--	IN		:	p_msg_name   	IN VARCHAR2	Required
	--				    Name of the message
	--              p_op_seq_num    IN NUMBER Required
	--                  Operation Sequence Number which is being processed
	--              p_entity_name   IN VARCHAR2 Required
	--                  Entity Name for which the error has occured
	--              p_type          IN VARCHAR2 Required
	--                  Entity type to find out the token name.
	-- End of comments
	FUNCTION GET_MESSAGE (p_msg_name IN VARCHAR2, p_op_seq_num IN NUMBER,
        p_entity_name IN VARCHAR2, p_type IN VARCHAR2)
   RETURN VARCHAR2;

   PROCEDURE switch_common_to_primary_rtg (	-- BUG 4712488
      p_org_id                  IN   NUMBER,
      p_ass_itm_id              IN   NUMBER,
      p_alt_rtg_desg            IN   VARCHAR2,
      p_alt_desg_for_prim_rtg   IN   VARCHAR2
   );

   PROCEDURE switch_common_to_alternate_rtg (	-- BUG 4712488
      p_org_id                  IN   NUMBER,
      p_ass_itm_id              IN   NUMBER,
      p_alt_desg_for_prim_rtg   IN   VARCHAR2,
      p_rtg_seq_id		IN   NUMBER
   );

	-- Start of comments
	--	API name 	: copy_routing_for_revised_item
	--	Type		: private
	--	Pre-reqs	: None.
	--	Function	: Copies routing source sequence id to target sequence id
	--                for a specific revised item
	--	Parameters	:
	--	IN		:	to_sequence_id IN NUMBER Required
	--				    Routing sequence Id of the target item
	--	    	    from_sequence_id IN NUMBER Required
	--				    Routing sequence Id of the source item
	--              from_org_id         IN NUMBER   Required
	--                  Source item's organization id
	--              to_org_id           IN NUMBER   Required
	--                  Target item's organization id
	--              user_id             IN NUMBER   Optional
	--                  User Id of the user who launches this process
	--              to_item_id          IN NUMBER   Required
	--                  Target routing's Item Id
	--              direction           IN NUMBER   Optional
	--                  Specifies the type of source and target routing combination
	--              to_alternate        IN VARCHAR2 Required
	--                  Target item's routing alternate name
	--              rev_date            IN DATE     Required
	--                  Date from which source item's operation needs to filterd
	--              p_e_change_notice     IN VARCHANR2  Optional
	--                  Change Notice Name
	--              p_rev_item_seq_id     IN NUMBER   Optional
	--                  Revised Item Sequence Id of Target Structure's Item
	--              p_routing_or_eco         IN NUMBER   Optional
	--                  Copy operation needs to create a structure or eco
	--              p_eco_eff_date        IN DATE     Optional
	--                  Effectivity Date for operations if copy operation creates eco
	--              p_contex_eco IN VARCHAR2 Optional
	--                  ECO context from which the source item's operations are filtered
	--              p_log_errors IN VARCHAR2 Optional
	--                  Flag which specifies whethere errors needs to be logged in mtl_interface_errors
	--              p_copy_request_id IN VARCHAR2 Optional
	--                  To group the errors which have been logged in mtl_interface_errors
	-- End of comments
/*#
* copy_routing Copies routing source sequence id to target sequence id.
* @param to_sequence_id Destination Sequence Id to which routing will be copied
* @param from_sequence_id Source Sequence Id from which routing will be copied
* @param from_org_id Source Organization Id from which routing will be copied
* @param to_org_id Destination Organization Id to which routing will be copied
* @param user_id user id
* @param to_item_id item id to which routing is copied
* @param direction direction of copy (BOM to BOM, BOM to ENG,ENG to BOM,ENG to ENG)
* @param to_alternate Copy to alternate designator
* @param rev_date Revision date to copy
* @param p_e_change_notice Change Notice Name
* @param p_rev_item_seq_id  Revised Item Sequence Id of Target Structure's Item
* @param p_routing_or_eco Copy operation needs to create a structure or eco
* @param p_trgt_eff_date Target Effectivity Date for operations
* @param p_eco_eff_date Effectivity Date for operations if copy operation creates eco
* @param p_context_eco ECO context from which the source item's operations are filtered
* @param p_log_errors Flag which specifies whethere errors needs to be logged in mtl_interface_errors
* @param p_copy_request_id To group the errors which have been logged in mtl_interface_errors
* @param p_cpy_disable_fields Flag to copy disable fields
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Copy Routing For Revised Item
*/
   PROCEDURE copy_routing_for_revised_item (
      to_sequence_id          IN   NUMBER,
      from_sequence_id        IN   NUMBER,
      from_org_id             IN   NUMBER,
      to_org_id               IN   NUMBER,
      user_id                 IN   NUMBER DEFAULT -1,
      to_item_id              IN   NUMBER,
      direction               IN   NUMBER,
      to_alternate            IN   VARCHAR2,
      rev_date                     DATE,
      p_e_change_notice         IN   VARCHAR2,
      p_rev_item_seq_id         IN   NUMBER,
      p_routing_or_eco          IN   NUMBER DEFAULT 1,
	  p_trgt_eff_date           IN   DATE,
      p_eco_eff_date            IN   DATE,
      p_context_eco             IN   VARCHAR2,
	  p_log_errors              IN   VARCHAR2 DEFAULT 'N',
	  p_copy_request_id         IN   NUMBER DEFAULT NULL,
	  p_cpy_disable_fields      IN   VARCHAR2 DEFAULT 'N'
   );

   PROCEDURE copy_attachments(p_from_sequence_id IN NUMBER,
	                           p_to_sequence_id   IN NUMBER,
	 						   p_user_id          IN NUMBER);
   PROCEDURE update_last_updated_by ( p_user_id IN NUMBER
 	                           ,p_to_sequence_id IN NUMBER );



END bom_copy_routing;

 

/
