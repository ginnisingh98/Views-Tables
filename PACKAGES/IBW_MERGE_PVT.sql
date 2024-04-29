--------------------------------------------------------
--  DDL for Package IBW_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBW_MERGE_PVT" AUTHID CURRENT_USER As
/* $Header: ibwvmrgs.pls 120.2 2005/12/23 03:48:46 pakrishn noship $ */


 /*------------------------------------------------------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                                                                                     |
|                  MERGE_PAGES -- 				                                                                                                       |
|			     API  registered to merge, party_id and party_relationship_id in ibw_page_views
|          These API's will be called when party_id in the HZ_parties will be merged.
*--------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE MERGE_PAGES(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT NOCOPY   NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY  VARCHAR2
				) ;


 /*------------------------------------------------------------------------------------------------------------------------*
| PUBLIC PROCEDURES                                                                                                                     |
|                  MERGE_SITES -- 				                                                                                                       |
|			     API  registered to merge, party_id  in ibw_site_visits
|          These API's will be called when party_id in the HZ_parties will be merged.
*--------------------------------------------------------------------------------------------------------------------------*/



PROCEDURE MERGE_SITES(
			P_entity_name		IN		VARCHAR2,
			P_from_id			IN		NUMBER,
			X_to_id			OUT NOCOPY   NUMBER,
			P_from_fk_id		IN		NUMBER,
			P_to_fk_id			IN		NUMBER,
			P_parent_entity_name	IN		VARCHAR2,
			P_batch_id			IN		NUMBER,
			P_batch_party_id		IN		NUMBER,
			X_return_status		OUT NOCOPY  VARCHAR2
				);





END IBW_MERGE_PVT;

 

/
