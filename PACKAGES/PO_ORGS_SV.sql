--------------------------------------------------------
--  DDL for Package PO_ORGS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ORGS_SV" AUTHID CURRENT_USER as
/* $Header: POXCOO2S.pls 115.3 2002/11/25 23:39:01 sbull ship $*/

/* bao - global variables */
  TYPE USER_DEF_DATE_REC IS RECORD(v_enable_date DATE,
                                   v_disable_date DATE,
                                   v_organization_code VARCHAR2(3));

  TYPE USER_DEF_DATE_TABLE IS TABLE OF USER_DEF_DATE_REC
    INDEX BY BINARY_INTEGER;

  x_date_table USER_DEF_DATE_TABLE;


/*===========================================================================
  PROCEDURE NAME:	get_org_info()


  DESCRIPTION:   Given a Org ID and Set of Books ID, bring back the
                 Org Code and Org Name from Org_Organization_Definitions
                 Entity.
                 This is currently used to get the Ship-To Org Code, Name
                 and Org Id in Enter Purchase Orders.
	         Called from the POXCOVEB.pls package.

  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      Sudha Iyer         05/95

===============================================================================*/

   PROCEDURE get_org_info(X_org_id IN NUMBER, X_set_of_books_id IN NUMBER,
                          X_org_code IN OUT NOCOPY varchar2,
                          X_org_name IN OUT NOCOPY varchar2 );



/*===========================================================================
  FUNCTION NAME:	val_dest_org()


  DESCRIPTION:   	Validate that the organization
			for the current destination type , item
			and item_revision.

			This function return TRUE for
			valid organizations otherwise
			it returns FALSE. An null org_id
			is considered invalid by this function.

  PARAMETERS:		x_org_id	IN NUMBER
			x_item_id	IN NUMBER
			x_item_rev	IN VARCHAR2
			x_dest_type	IN VARCHAR2

  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     	Ramana Y. Mulpury         06/95

===============================================================================*/

   FUNCTION  val_dest_org(x_org_id 	IN     NUMBER,
			  x_item_id	IN     NUMBER,
			  x_item_rev	IN     VARCHAR2,
			  x_dest_type   IN     VARCHAR2,
			  x_sob_id	IN     NUMBER)
   RETURN BOOLEAN;



/*===========================================================================
  FUNCTION NAME:	val_src_org()


  DESCRIPTION:   	Validate that the source organization
			is valid for the current item, destination
			organization, destination type and set of books.

			This function return TRUE for
			valid organizations otherwise
			it returns FALSE. An null org_id
			is considered invalid by this function.

  PARAMETERS:		x_src_org_id	IN NUMBER
			x_dest_org_id   IN NUMBER
			x_dest_type     IN VARCHAR2
			x_item_id	IN NUMBER
			x_mrp_planned_item IN VARCHAR2
			x_sob_id	IN NUMBER

  DESIGN REFERENCES:	POXRQERQ.doc


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:     	Ramana Y. Mulpury         06/95

===============================================================================*/
FUNCTION val_source_org(X_src_org_id		IN    NUMBER,
                        X_dest_org_id		IN    NUMBER,
			X_dest_type		IN    VARCHAR2,
                        X_item_id		IN    VARCHAR2,
			X_mrp_planned_item	IN    VARCHAR2,
			X_sob_id		IN    NUMBER)
RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:  validate_org_info()


  DESCRIPTION:     Validate the components of the organization record and return
                   error status and error messages depending on success or failure.


  PARAMETERS:      p_org_record IN OUT RCV_SHIPMENT_OBJECT_SV.Organization_id_record_type

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:           Uses dbms_sql to create the WHERE clause based on organization record
                   components that have not null values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      10/24/96         Raj Bhakta

===============================================================================*/

 PROCEDURE validate_org_info(p_org_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Organization_id_record_type);

/*===========================================================================
  PROCEDURE NAME:  derive_org_info()


  DESCRIPTION:     Derive the components of the organization record that are null
                   based on components that have not null values.


  PARAMETERS:      p_org_record IN OUT RCV_SHIPMENT_HEADER_SV.OrgRecType

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:           Uses dbms_sql to create the WHERE clause based on organization record
                   components that have not null values

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      10/24/96         Raj Bhakta

===============================================================================*/

 PROCEDURE derive_org_info(p_org_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Organization_id_record_type);


END PO_ORGS_SV;

 

/
