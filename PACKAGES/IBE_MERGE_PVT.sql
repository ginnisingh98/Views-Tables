--------------------------------------------------------
--  DDL for Package IBE_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MERGE_PVT" AUTHID CURRENT_USER As
/* $Header: IBEVMRGS.pls 115.9 2003/05/12 22:52:00 adwu ship $ */

PROCEDURE acc_merge_oneclick (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);

PROCEDURE acc_merge_active_quotes (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);


PROCEDURE acc_merge_shared_quote (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2,
        customer_type                VARCHAR2);


PROCEDURE acc_merge_shp_lists(
			 req_id 	NUMBER,
			 set_num 	NUMBER,
			 Process_MODE 	VARCHAR2,
             customer_type  VARCHAR2);


PROCEDURE CUSTOMER_MERGE(
			 Request_id 	NUMBER,
			 Set_Number 	NUMBER,
			 Process_MODE 	VARCHAR2
			);
/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_SHIP_LISTS -- 					           |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update IBE_SH_SHP_LISTS_ALL table     |
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
|  Harish Ekkirala Created 02/12/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_SHIP_LISTS(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id		    	OUT	    NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT	    NOCOPY VARCHAR2
				);

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_ONECLICK-- 						     |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update					     |
|			 IBE_ORD_ONECLICK table and will be called from party      |
|			 Merge concurrent program.   					     |
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
|  Harish Ekkirala Created 02/12/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_ONECLICK(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			   OUT	    NOCOPY 	NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
				);

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_MSITE_PARTY_ACCESS -- 					     |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update					     |
|			 IBE_MSITE_PRTY_ACCSS table and will be called from party  |
|			 Merge concurrent program.   					     |
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
|  Harish Ekkirala Created 02/12/2001.                                       |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_MSITE_PARTY_ACCESS(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			   OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
				);


/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_SHARED_QUOTE -- 					           |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update IBE_SH_QUOTE table     |
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
|  Adam Wu Created 12/05/2002.                                               |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE MERGE_SHARED_QUOTE(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			   OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
				);

/*----------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                          |
|                  MERGE_ACTIVE_QUOTE -- 					           |
|			 When in ERP Parties are merged the	      	           |
|                  The Foriegn keys to party_id and other columns            |
|			 should also be updated in iStore tables.  		     |
|                  This procedure will update IBE_ACTIVE_QUOTES_ALL table     |
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
|  Adam Wu Created 12/05/2002.                                               |
|                                                                            |
*----------------------------------------------------------------------------*/
procedure MERGE_ACTIVE_QUOTE(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT		NOCOPY NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT		NOCOPY VARCHAR2
);


End IBE_MERGE_PVT;



 

/
