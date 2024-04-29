--------------------------------------------------------
--  DDL for Package PO_REQ_DIST_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQ_DIST_SV1" AUTHID CURRENT_USER as
/* $Header: POXRQD2S.pls 115.4 2003/12/19 18:57:32 jskim ship $ */
/*===========================================================================
  PACKAGE NAME:		po_req_dist_sv1

  DESCRIPTION:		Contains all the server side procedures
			that access the entity, PO_REQ_DISTRIBUTIONS.

  CLIENT/SERVER:	Server

  LIBRARY NAME		None

  OWNER:		MCHIHAOU

  PROCEDURE NAMES:	get_dist_num

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	get_dist_num_account

  DESCRIPTION:        	Obtain the number of distributions for
			the specified line. If there is only
                 	one distribution then the procedure also
			provides the ccid for the distribution.

  PARAMETERS:           x_requisition_line_id
			x_num_of_dist
			x_code_combination_id

  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    10/30	RMULPURY	Created
===========================================================================*/
PROCEDURE get_dist_num_account( x_requisition_line_id   IN OUT NOCOPY NUMBER,
			        x_num_of_dist		IN OUT NOCOPY NUMBER,
			        x_code_combination_id   IN OUT NOCOPY NUMBER);

/*===========================================================================
  PROCEDURE NAME:       get_dist_account

  DESCRIPTION:         Used to get the code_combination_id if the line
                       has only one distribution. Otherwise, if the line
                       has multiple distributions it will return the number
                       -11. If the line has no distributions, it will return
                       null.
                       Created in order to eliminate POST_QUERY processing,
                       by calling this function in view po_requisition_lines_v.

  PARAMETERS:           x_requisition_line_id

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    7/3/96      MCHIHAOU        Created
===========================================================================*/
FUNCTION get_dist_account( x_requisition_line_id   IN  NUMBER) return NUMBER;


--pragma restrict_references(get_dist_account,WNDS,RNPS,WNPS);

--< Bug 3265539 > Removed unused function get_project_num.

/*===========================================================================
  PROCEDURE NAME:	update_dist_quantity

  DESCRIPTION:        	Verify if the requisition line
			has only one distribution . If it
			does then the procedure updates the
			distribution quantity to match the
			line quantity only if the distribution
			is not encumbered.

  PARAMETERS:           x_requisition_line_id
			x_line_quantity


  DESIGN REFERENCES:	POXRQERQ.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    03/23	RMULPURY	Created
===========================================================================*/
PROCEDURE update_dist_quantity( x_requisition_line_id   NUMBER,
			        x_line_quantity		NUMBER);



END po_req_dist_sv1;

 

/
