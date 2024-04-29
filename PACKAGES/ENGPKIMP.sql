--------------------------------------------------------
--  DDL for Package ENGPKIMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENGPKIMP" AUTHID CURRENT_USER as
/* $Header: ENGEIMPS.pls 120.1.12010000.3 2009/06/15 14:27:08 vggarg ship $ */

    yes constant number(1) := 1;
    no  constant number(1) := 2;
    Type StringArray is table of varchar2(81) index by binary_integer;
    Type NameArray is table of varchar2(30) index by binary_integer;
    Type BooleanArray is table of number(1) index by binary_integer;
----------------------------- Procedure ---------------------------------
--
-- NAME
--      implement_revised_item
-- DESCRIPTION
--      Implements a revised item defined on an Engineering Change Order.
-- REQUIRES
--      Revised Item Sequence Id - The unique identifier of the Revised Item.
--      Who values - Information about the user enviroment for who columns.
--      Trial mode - Yes(1) or No(2).  If Yes, then all possible errors are
--      returned.  If No, aborts upon first error.
-- MODIFIES
--
-- RETURNS
--      Update WIP - Yes(1) or No(2).  Should work in progress be updated with
--      re-exploded bills of material.
--      New Item Revision High Date - High Date of Revision to use for
--      Update WIP routine.
--      Bill Sequence Id - Unique identifier of bill of material for
--      this item.
--      Error Messages - Names, tokens, values, translates and quantity of
--      message dictionary messages.
-- NOTES
--      This must be called within the C program, enlimp.  Enlimp updates work
--      in progress with a re-exploded bill of material if update_wip
--      is "yes".
-- EXAMPLE
--


TYPE Rev_op_disable_date_Rec_Type IS RECORD
   (
     Revised_Item_Id            NUMBER
   , Operation_seq_id           NUMBER
   , Disable_date               DATE
 );
TYPE Rev_Op_Disable_Date_Tbl_Type IS TABLE OF Rev_op_disable_date_Rec_Type
    INDEX BY BINARY_INTEGER ;

TYPE Rev_Comp_Disable_Date_Rec_Type IS RECORD
   (
     Revised_Item_Id            NUMBER
   , Component_seq_id                NUMBER
   , Disable_date               DATE
 );
TYPE Rev_Comp_Disable_Date_Tbl_Type IS TABLE OF Rev_Comp_Disable_Date_Rec_Type
    INDEX BY BINARY_INTEGER ;

Procedure implement_revised_item(
       revised_item in eng_revised_items.revised_item_sequence_id%type,
        trial_mode in number,
        max_messages in number, -- size of host arrays
        userid  in number,  -- user id
        reqstid in number,  -- concurrent request id
        appid   in number,  -- application id
        progid  in number,  -- program id
        loginid in number,  -- login id
        bill_sequence_id        OUT NOCOPY eng_revised_items.bill_sequence_id%type,
        routing_sequence_id     OUT NOCOPY eng_revised_items.routing_sequence_id%type,
        eco_for_production      OUT NOCOPY eng_revised_items.eco_for_production%type,
        revision_high_date      OUT NOCOPY mtl_item_revisions.effectivity_date%type,
        rtg_revision_high_date  OUT NOCOPY mtl_rtg_item_revisions.effectivity_date%type,
        update_wip              OUT NOCOPY eng_revised_items.update_wip%type,
        group_id1               OUT NOCOPY wip_job_schedule_interface.group_id%type,
        group_id2               OUT NOCOPY wip_job_schedule_interface.group_id%type,
        wip_job_name1           OUT NOCOPY wip_entities.wip_entity_name%type,
        wip_job_name2           OUT NOCOPY wip_entities.wip_entity_name%type,
        wip_job_name2_org_id    OUT NOCOPY wip_entities.organization_id%type,
        message_names OUT NOCOPY NameArray,
        token1 OUT NOCOPY NameArray,
        value1 OUT NOCOPY StringArray,
        translate1 OUT NOCOPY BooleanArray,
        token2 OUT NOCOPY NameArray,
        value2 OUT NOCOPY StringArray,
        translate2 OUT NOCOPY BooleanArray,
        msg_qty in OUT NOCOPY binary_integer,
        warnings in OUT NOCOPY number);

Procedure reverse_standard_bom(
        revised_item in eng_revised_items.revised_item_sequence_id%type,
        userid  in number,
        reqstid in number,
        appid   in number,
        progid  in number,
        loginid in number,
        bill_sequence_id     in  eng_revised_items.bill_sequence_id%type,
        routing_sequence_id  in  eng_revised_items.routing_sequence_id%type,
        return_message   OUT NOCOPY  VARCHAR2,
        return_status in OUT NOCOPY NUMBER
      );

Procedure generate_new_wip_name(
       p_wip_entity_name   IN VARCHAR2
      ,p_organization_id   IN NUMBER
      ,x_wip_entity_name1  OUT NOCOPY VARCHAR2
      ,x_wip_entity_name2  OUT NOCOPY VARCHAR2
      ,x_return_status     OUT NOCOPY NUMBER
  );

-- Added procedure for bug 4767315
/********************************************************************
 * API Name      : implement_eco_wo_revised_item
 * Parameters IN : p_change_notice
 *                 temp_organization_id
 * Parameters OUT: None
 * Purpose       : used to implement eco for which all revised items are implemented/cancelled and no mandatory tasks are left
 *********************************************************************/

PROCEDURE implement_eco_wo_revised_item
	(
		p_change_notice in varchar2,
		temp_organization_id in varchar2
	);


-- Added procedure for bug 3402607
/********************************************************************
 * API Name      : LOG_IMPLEMENT_FAILURE
 * Parameters IN : p_change_id
 *                 p_revised_item_seq_id
 * Parameters OUT: None
 * Purpose       : Used to update the lifecycle states of the header
 * and create a log in header Action Log if implementation fails.
 * In case of revised item implementation failure, updates the revised
 * item status_type
 *********************************************************************/
PROCEDURE LOG_IMPLEMENT_FAILURE(p_change_id IN NUMBER
                               ,p_revised_item_seq_id IN NUMBER -- Added parameter for bug 3720341
			       );

-- Code changes for enhancement 6084027 start

PROCEDURE LOG_IMPLEMENT_FAILURE(p_change_notice IN VARCHAR2
                                   ,p_org_id IN NUMBER
                                  , p_revised_item_seq_id IN NUMBER
                                 );
-- Code changes for enhancement 6084027 end

end ENGPKIMP;

/
