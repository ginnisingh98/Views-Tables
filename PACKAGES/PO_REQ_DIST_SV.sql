--------------------------------------------------------
--  DDL for Package PO_REQ_DIST_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DIST_SV" AUTHID CURRENT_USER as
/* $Header: POXRQD1S.pls 115.2 2002/11/23 01:57:40 sbull ship $ */
/*===========================================================================
  PACKAGE NAME:		po_req_dist_sv

  DESCRIPTION:		Contains all the server side procedures
			that access the entity, PO_REQ_DISTRIBUTIONS.

  CLIENT/SERVER:	Server

  LIBRARY NAME		None

  OWNER:		MCHIHAOU

  PROCEDURE NAMES:	check_unique
			check_max_dist_num
			select_summary
		        create_dist_for_modify

===========================================================================*/



/*===========================================================================
  PROCEDURE NAME:	check_unique

  DESCRIPTION:        Checks if distribution number entered in the form
                       already exists in the database.

===========================================================================*/
  FUNCTION check_unique
                       (X_row_id                VARCHAR2,
                        X_distribution_num      NUMBER,
                        X_requisition_line_id   NUMBER)
  RETURN BOOLEAN;

/*===========================================================================
  PROCEDURE NAME:       check_unique_insert

  DESCRIPTION:        Checks if distribution number entered in the form
                       already exists in the database during the commit when
                       user is inserting rows.


===========================================================================*/
  PROCEDURE check_unique_insert
                       (X_row_id      IN OUT NOCOPY    VARCHAR2,
                        X_distribution_num      NUMBER,
                        X_requisition_line_id   NUMBER);



/*===========================================================================
  PROCEDURE NAME:	get_max_dist_num

  DESCRIPTION:       get the maximum number for the distribution lines that
                     have been committed to the Database.

  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
  FUNCTION get_max_dist_num( X_requisition_line_id   NUMBER)
  RETURN NUMBER;

/*===========================================================================
  PROCEDURE NAME:	select_summary

  DESCRIPTION:      Running total implementation for Req_line_quantity
                    implemented according to standards.

  PARAMETERS:


  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:
===========================================================================*/
  PROCEDURE select_summary( X_requisition_line_id   IN OUT NOCOPY NUMBER,
                            X_total                 IN OUT NOCOPY NUMBER);





/*===========================================================================
  PROCEDURE NAME:	update_reqs_distributions

  DESCRIPTION:          Updates requisition distributions gl_cancelled_date
                        or gl_closed_date based on control action.


  PARAMETERS:           X_req_header_id           IN     NUMBER,
			X_req_line_id             IN     NUMBER,
			X_req_control_action      IN     VARCHAR2,
     			X_req_action_date         IN     DATE,
			X_req_control_error_rc    IN OUT VARCHAR2


  DESIGN REFERENCES:	POXDOCON.dd

  ALGORITHM:            1. If control action is 'CANCEL',
                           update gl_cancelled_date to sysdate.
                        2. If control action is 'FINALLY CLOSE', update
                           gl_closed_date sysdate.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       WLAU       5/12     Created
                        WLAU       5/30/96  Bug: 361657 add action_date
===========================================================================*/
  PROCEDURE update_reqs_distributions
                       (X_req_header_id           IN     NUMBER,
                        X_req_line_id             IN     NUMBER,
                        X_req_control_action      IN     VARCHAR2,
            	        X_req_action_date         IN     DATE,
                        X_req_control_error_rc    IN OUT NOCOPY VARCHAR2);


 /*===========================================================================
   PROCEDURE NAME:	val_create_dist

   DESCRIPTION:		If a requistion line is committed then validate
			 if a distribution should  be created automatically.

   PARAMETERS:		X_line_id		  NUMBER
			 X_destination_type_code   VARCHAR2
			 X_destination_org_id	  NUMBER
			 X_req_encumbrance_flag	  VARCHAR2
			 X_gl_date		  DATE

   DESIGN REFERENCES:	MODIFY_REQS.dd
		 	POXRQERQ.doc

   ALGORITHM:

   NOTES:

   OPEN ISSUES:		DEBUG. We may not need this apis since
			 currently in Rel 10 we check if the
			 total distribution quantity is > 0 to
			 check for the existance of distributions.
			 The rest of the validation is possible on the
			 client.

   CLOSED ISSUES:

   CHANGE HISTORY:
 ===========================================================================*/

 /*
 PROCEDURE val_create_dist(X_line_id			NUMBER,
			   X_destination_type_code	VARCHAR2,
			   X_destination_org_id		NUMBER,
			   X_req_encumbrance_flag	VARCHAR2,
			   X_gl_date			DATE,
			   X_code_combination_id	NUMBER);
*/

 /*===========================================================================
   PROCEDURE NAME:	create_dist_for_modify

   DESCRIPTION:

   PARAMETERS:		x_new_req_line_id
			x_orig_req_line_id


   DESIGN REFERENCES:	MODIFY_REQS.dd

   ALGORITHM:

   NOTES:

   OPEN ISSUES:

   CLOSED ISSUES:

   CHANGE HISTORY:
 ===========================================================================*/

 PROCEDURE create_dist_for_modify (x_new_req_line_id      IN NUMBER,
				   x_orig_req_line_id     IN NUMBER,
				   x_new_line_quantity    IN NUMBER);


END po_req_dist_sv;

 

/
