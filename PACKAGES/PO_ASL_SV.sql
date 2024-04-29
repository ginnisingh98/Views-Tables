--------------------------------------------------------
--  DDL for Package PO_ASL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_SV" AUTHID CURRENT_USER as
/* $Header: POXA1LSS.pls 115.7 2003/11/06 03:46:13 bao ship $ */

  TYPE orgTab IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  x_ship_to_org_list  orgTab;

-- <ASL ERECORD FPJ START>

G_EVENT_INSERT CONSTANT VARCHAR2(10) := 'INSERT';
G_EVENT_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';

-- <ASL ERECORD FPJ END>


/*===========================================================================
  PACKAGE NAME:		po_asl_sv

  DESCRIPTION:		General server-side utilities for Approved Supplier List.

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:                Liza Broadbent

  PROCEDURE NAMES:	get_startup_values()
			check_asl_action()

===========================================================================*/
/*===========================================================================
  FUNCTION NAME:	check_asl_action

  RETURN VALUE:	        number


  DESCRIPTION:     	Checks to see whether a given action (e.g. PO
			Approval) is valid based on the ASL status for
			the supplier-item combination.

			If the supplier-item combination does not exist
			in the ASL, then this routine returns TRUE.

  PARAMETERS:		action	         varchar2 -- Actions are lookup_codes
						  -- in po_lookup_codes where
						  -- lookup_type =
						  -- 'ASL_STATUS_BUSINESS_RULES'
			vendor_id        number	  -- Required
			vendor_site_id   number	  -- Optional
			item_id          number	  -- Either an item or category_id
						  -- is required.
			category_id      number   -- Note:  this is associated with
						  -- the PO Category Set.
			ship_to_org_list orgTable -- This is a PL/SQL table that can
						  -- take a list of ship-to orgs
						  -- for cases where it makes sense
						  -- to return a single results for
						  -- multiple organizations. An
						  -- example of this is the test for
						  -- PO Approval where a single PO
						  -- header can have multiple ship-to
						  -- locations.  This also accepts
						  -- a single organization_id for the
						  -- simple case.

  CHANGE HISTORY:  	21-May-96	lbroadbe	Created

===============================================================================*/

function check_asl_action(x_action	     varchar2,
			  x_vendor_id	     number,
			  x_vendor_site_id   number,
			  x_item_id	     number,
			  x_category_id      number,
                          x_ship_to_org      number) return number;

--pragma restrict_references (check_asl_action,WNDS,RNPS,WNPS);

/*===========================================================================
  PROCEDURE NAME:       update_vendor_status


  DESCRIPTION:          Updates the vendor status to that what is passed in.

  PARAMETERS:

             x_organiazation_id     input     required
             x_vendor_id            input     required
             x_status               input     required
             x_vendor_site_id       input     optional
             x_item_id              input     optional
             x_global_asl_update    input     optional
             x_org_id               input     optional
             x_return_code          in out    'S' for success 'F' for failure

  CHANGE HISTORY:       30-JUL-97       vpawar  Created

24-MAY-02       davidng Fix for 2386912
			Change x_vendor_site_id to number default null from number
			Change x_item_id to number default null from number
			Change x_org_id to number default null from number

===============================================================================*/

procedure update_vendor_status(x_organization_id        in     number,
                               x_vendor_id              in     number,
                               x_status                 in     varchar2,
                               x_vendor_site_id         in     number default null,
                               x_item_id                in     number default null,
                               x_global_asl_update      in     varchar2 := 'N',
                               x_org_id                 in     number default null,
                               x_return_code            in out NOCOPY varchar2);

/*===========================================================================
  PROCEDURE NAME:	get_startup_values


  DESCRIPTION:     	Gets all startup values for the Approved Supplier List.


  CHANGE HISTORY:  	21-May-96	lbroadbe	Created

===============================================================================*/

procedure get_startup_values(x_current_form_org		  in     number,
			     x_po_item_master_org_id	  in out NOCOPY number,
			     x_po_category_set_id	  in out NOCOPY number,
			     x_po_structure_id		  in out NOCOPY number,
			     x_default_status_id	  in out NOCOPY number,
			     x_default_status		  in out NOCOPY varchar2,
			     x_default_business_code	  in out NOCOPY varchar2,
			     x_default_business		  in out NOCOPY varchar2,
			     x_chv_install  		  in out NOCOPY varchar2,
			     x_chv_cum_flag		  in out NOCOPY varchar2);

/*===========================================================================
  PROCEDURE NAME:	check_record_unique


  DESCRIPTION:     	Determines whether record contains unique combination
			of using_organization_id, vendor, and item/commodity.


  CHANGE HISTORY:  	28-Jun-96	cmok		Created

===============================================================================*/

function check_record_unique(x_manufacturer_id	   number,
			  x_vendor_id	           number,
			  x_vendor_site_id         number,
			  x_item_id	           number,
			  x_category_id            number,
			  x_using_organization_id  number) return boolean;


-- <ASL ERECORD FPJ START>
/*===========================================================================
  PROCEDURE NAME:	raise_asl_eres_event


  DESCRIPTION:     	Call QA api to raise an event for eRecord creation. This
                    procedure will also acknowledge the eRecord.


  CHANGE HISTORY:  	01-Oct-2003   bao       Created

=============================================================================*/
PROCEDURE raise_asl_eres_event
( x_return_status     OUT NOCOPY VARCHAR2,
  p_asl_id            IN         NUMBER,
  p_action            IN         VARCHAR2,
  p_calling_from      IN         VARCHAR2,
  p_ackn_note         IN         VARCHAR2,
  p_autonomous_commit IN         VARCHAR2
);


/*===========================================================================
  PROCEDURE NAME:	init_asl_activity_tbl


  DESCRIPTION:     	Initialize the table that captures ASL changes (insert
                        or update).


  CHANGE HISTORY:  	05-Nov-2003   bao       Created

=============================================================================*/

PROCEDURE init_asl_activity_tbl;


/*===========================================================================
  PROCEDURE NAME:	add_asl_activity


  DESCRIPTION:          Populate ASL changes (insert or update) to the table


  CHANGE HISTORY:  	05-Nov-2003   bao       Created

=============================================================================*/

PROCEDURE add_asl_activity
( p_asl_id IN NUMBER,
  p_action IN VARCHAR2
);


/*===========================================================================
  PROCEDURE NAME:	process_asl_activity_tbl


  DESCRIPTION:          Raise ERES event for each ASL change logged in the
                        table


  CHANGE HISTORY:  	05-Nov-2003   bao       Created

=============================================================================*/

PROCEDURE process_asl_activity_tbl;

-- <ASL ERECORD FPJ END>

END PO_ASL_SV;

 

/
