--------------------------------------------------------
--  DDL for Package ASO_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_MERGE_PVT" AUTHID CURRENT_USER As
/* $Header: asovmrgs.pls 115.13 2003/05/27 22:18:28 vtariker ship $ */

/*----------------------------------------------------------------------------*
 | PUBLIC PROCEDURE                                                          |
 |             CUSTOMER_MERGE                                                |
 | DESCRIPTION                                                               |
 |             This API should be called from TCA customer merge concurrent  |
 |             program and will merge records in Order Capture tables for    |
 |             customers that being merged.                                  |
 | REQUIRES                                                                  |
 |                                                                           |
 |                                                                           |
 | EXCEPTIONS RAISED                                                         |
 |                  DIFFERENT_PARTIES -- Raises an exception when the owner  |
 |                                      parties are different for the cust   |
 |                                      accounts that are being merged.      |
 | KNOWN BUGS                                                                |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | HISTORY                                                                   |
 |  Harish Ekkirala Created 03/27/2001.                                      |
 |  Veeru Tarikere  07/18/2002  Rewrote Customer_merge                       |
 |                                                                           |
 *----------------------------------------------------------------------------*/
PROCEDURE CUSTOMER_MERGE(
                req_id                       NUMBER,
                set_num                      NUMBER,
                process_mode                 VARCHAR2
               );


/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |                  UPDATE_QUOTE_LINES                                        |
 | DESCRIPTION                                                                |
 |             This is a private procedure to update ASO_QUOTE_LINES_ALL      |
 |             table with merged to cust account id. When two cust accounts   |
 |             are merged.                                                    |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |  Vtariker 07/18/2002 Rewrote Update_Quote_Lines                            |
 |                                                                            |
 *----------------------------------------------------------------------------*/
PROCEDURE UPDATE_QUOTE_LINES(
                         req_id                       NUMBER,
                         set_num                      NUMBER,
                         process_mode                 VARCHAR2
                        );


/*----------------------------------------------------------------------------*
 | PRIVATE PROCEDURE                                                          |
 |                  UPDATE_SHIPMENTS                                          |
 | DESCRIPTION                                                                |
 |             This is a private procedure to update ASO_SHIPMENTS            |
 |             table with merged to cust account id. When two cust accounts   |
 |             are merged.                                                    |
 | REQUIRES                                                                   |
 |                                                                            |
 |                                                                            |
 | EXCEPTIONS RAISED                                                          |
 |                                                                            |
 | KNOWN BUGS                                                                 |
 |                                                                            |
 | NOTES                                                                      |
 |                                                                            |
 | HISTORY                                                                    |
 |  Harish Ekkirala Created 03/27/2001.                                       |
 |  Vtariker 07/18/2002 Rewrote Update_Shipments                              |
 |                                                                            |
 *----------------------------------------------------------------------------*/
PROCEDURE UPDATE_SHIPMENTS(
                         req_id                       NUMBER,
                         set_num                      NUMBER,
                         process_mode                 VARCHAR2
                        );


/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_QUOTE_HEADERS -- 				                 |
|			 When in ERP Parties are merged the	      	            |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		            |
|                  This procedure will update ASO_QUOTE_HEADERS_ALL table    |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Harish Ekkirala Created 02/26/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE MERGE_QUOTE_HEADERS(
			P_entity_name			IN		VARCHAR2,
			P_from_id				IN		NUMBER,
			X_to_id				OUT NOCOPY   NUMBER,
			P_from_fk_id			IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY   VARCHAR2
				);

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_QUOTE_LINES -- 				                 |
|			 When in ERP Parties are merged the	      	            |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		            |
|                  This procedure will update ASO_QUOTE_LINES_ALL table      |
|                  and will be called from party Merge concurrent program.   |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Harish Ekkirala Created 02/26/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_QUOTE_LINES(
			P_entity_name			IN		VARCHAR2,
			P_from_id				IN		NUMBER,
			X_to_id				OUT NOCOPY   NUMBER,
			P_from_fk_id			IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY   VARCHAR2
				);

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_SHIPMENTS --    				                 |
|			 When in ERP Parties are merged the	      	            |
|               The Foriegn keys to party_id and other columns               |
|			 should also be updated in iStore tables.  		            |
|               This procedure will update ASO_SHIPMENTS table      	       |
|               and will be called from party Merge concurrent program.      |
| DESCRIPTION                                                                |
|                                                                            |
| REQUIRES                                                                   |
|                                                                            |
|                                                                            |
| EXCEPTIONS RAISED                                                          |
|                                                                            |
| KNOWN BUGS                                                                 |
|                                                                            |
| NOTES                                                                      |
|                                                                            |
| HISTORY                                                                    |
|  Harish Ekkirala Created 02/26/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_SHIPMENTS(
			P_entity_name			IN		VARCHAR2,
			P_from_id				IN		NUMBER,
			X_to_id				OUT NOCOPY   NUMBER,
			P_from_fk_id			IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY   VARCHAR2
				);

End ASO_MERGE_PVT;

 

/
