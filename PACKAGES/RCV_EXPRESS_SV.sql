--------------------------------------------------------
--  DDL for Package RCV_EXPRESS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_EXPRESS_SV" AUTHID CURRENT_USER AS
/* $Header: RCVTXEXS.pls 120.0.12000000.1 2007/01/16 23:33:15 appldev ship $*/

/*===========================================================================
  PROCEDURE NAME:	val_express_transactions

  DESCRIPTION:

  PARAMETERS:		X_group_id IN NUMBER    The group of transactions
					        you wish to process

                        X_rows_succeeded OUT NUMBER
						The number of rows that
						passed validation

                        X_rows_failed OUT NUMBER
						The number of rows that
						failed validation

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:

===========================================================================*/
PROCEDURE val_express_transactions (X_group_id       IN  NUMBER,
				    X_rows_succeeded OUT NOCOPY NUMBER,
				    X_rows_failed    OUT NOCOPY NUMBER);



END RCV_EXPRESS_SV;

 

/
