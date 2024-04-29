--------------------------------------------------------
--  DDL for Package BOMPINRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOMPINRV" AUTHID CURRENT_USER as
/* $Header: BOMINRVS.pls 120.1 2005/06/21 12:14:20 rfarook noship $ */

	Type ProgramInfoStruct is record
		(userid  number := -1,     /* user id               */
                 reqstid number := 0,      /* concurrent request id */
                 appid   number := null,   /* application_id        */
                 progid  number := null,   /* program id            */
                 loginid number := null);  /* login id              */

/*--------------------------- Procedure ---------------------------------*/
/*
  NAME
	Increment_Revision
  DESCRIPTION
        Increments an item revision where possible.  It does not implement the
        revision.
  REQUIRES
	Item id - Inventory item id of the item whose revision is
        being incremented.
        Org id - Organization that the item
        belongs to.
        Date Time - Effective date of the new revision.
  MODIFIES

  RETURNS
	Out code - The new item revision.
	Error Message - PL/SQL error.
  NOTES
	Intended to be modifiable by the customer.  Encapsulation is
        enforced so that the customer can chose ones own algorithm for
        incrementing revisions without effecting calling programs.
        However, if the parameters are changed, than one must inspect
        calling programs such as BOMPKMUD.
  EXAMPLE

*/

Procedure increment_revision(
	i_item_id in mtl_item_revisions.inventory_item_id%type,
 	i_org_id in mtl_item_revisions.organization_id%type,
        i_date_time in mtl_item_revisions.effectivity_date%type,
	who in ProgramInfoStruct,
 	o_out_code in out nocopy mtl_item_revisions.revision%type,
        error_message in out nocopy varchar);

end BOMPINRV;

 

/
