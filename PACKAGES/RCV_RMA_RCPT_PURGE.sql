--------------------------------------------------------
--  DDL for Package RCV_RMA_RCPT_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_RMA_RCPT_PURGE" AUTHID CURRENT_USER AS
/* $Header: RCVPURGS.pls 115.2 2002/11/22 21:57:10 sbull ship $*/

/*===========================================================================
  PACKAGE NAME:		RCV_RMA_RCPT_PURGE

  DESCRIPTION :      API's for purging recipts against RMA's

  CLIENT/SERVER:	Server

  PROCEDURE NAMES:	Check_Open_Receipts()
			Purge_Receipts()
===========================================================================*/
/*===========================================================================
  PROCEDURE NAME: Check_Open_Receipts()

  DESCRIPTION:
	This procedure checks if the receipts against an RMA can be purged
        or not.

  PARAMETERS:  rma line id, return status(TRUE or FALSE) , reason

  DESIGN REFERENCES: Generic

  CHANGE HISTORY:   7-JUN-2000	dreddy Created
===========================================================================*/

PROCEDURE Check_Open_Receipts(x_order_line_id  IN  NUMBER,
                              x_status   OUT NOCOPY  VARCHAR2,
                              x_message  OUT NOCOPY  VARCHAR2);



/*===========================================================================
  PROCEDURE NAME: Purge_Receipts()

  DESCRIPTION:
	This procedure deletes all the rcv table data for the correponding
        rma line

  PARAMETERS:  rma line id, return status(TRUE or FALSE)

  DESIGN REFERENCES: Generic

  CHANGE HISTORY:   7-JUN-2000	dreddy Created
===========================================================================*/


PROCEDURE Purge_Receipts(x_order_line_id  IN  NUMBER,
                         x_status   OUT NOCOPY  VARCHAR2,
                         x_message  OUT NOCOPY  VARCHAR2);
END RCV_RMA_RCPT_PURGE;

 

/
