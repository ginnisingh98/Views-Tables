--------------------------------------------------------
--  DDL for Package PO_LINES_PKG_SCU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_LINES_PKG_SCU" AUTHID CURRENT_USER as
/* $Header: POXPIL5S.pls 115.2 2002/11/25 22:42:54 sbull ship $ */

 /* The following procedure is used to check uniqueness of Line Numbers.
 ** Created By : SIYER                                                 */

  procedure check_unique(X_rowid		      VARCHAR2,
			 X_line_num	              NUMBER,
                         X_po_header_id               NUMBER
			 );


/*===========================================================================
  PROCEDURE NAME:	select_ship_total

  DESCRIPTION:		Gets the total quantity against all shipments
                        of a given line.


  PARAMETERS:		X_po_line_id		IN	NUMBER
			X_total 		IN OUT  NUMBER
			X_total_RTOT_DB		IN OUT  NUMBER

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	SIYER            08/95  	Created

===========================================================================*/

  procedure select_ship_total ( X_po_line_id		IN	NUMBER,
			        X_total 		IN OUT NOCOPY  NUMBER,
			        X_total_RTOT_DB		IN OUT NOCOPY  NUMBER);



END PO_LINES_PKG_SCU;

 

/
