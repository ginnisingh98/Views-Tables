--------------------------------------------------------
--  DDL for Package OKE_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_PARTY_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: OKEVPMGS.pls 115.4 2002/11/21 20:48:19 syho ship $ */



--
-- Procedure: pool_party_merge
--
-- Description: This routine takes care of the party merge for OKE_POOL_PARTIES table
--

PROCEDURE pool_party_merge(p_merge_name			IN		VARCHAR2					,
   			   p_from_id			IN		NUMBER						,
   			   p_to_id			OUT	NOCOPY 	NUMBER						,
   			   p_from_fk_id			IN		NUMBER						,
   			   p_to_fk_id			IN		NUMBER						,
			   p_parent_entity_name		IN		VARCHAR2					,
		           p_batch_id		 	IN		NUMBER						,
		           p_batch_party_id		IN		NUMBER						,
		           x_return_status	        OUT	NOCOPY	VARCHAR2
 			  );


--
-- Procedure: funding_party_merge
--
-- Description: This routine takes care of the party merge for OKE_K_FUNDING_SOURCES table
--

PROCEDURE funding_party_merge(p_merge_name		IN		VARCHAR2					,
   			      p_from_id			IN		NUMBER						,
   			      p_to_id			OUT	NOCOPY	NUMBER						,
   			      p_from_fk_id		IN		NUMBER						,
   			      p_to_fk_id		IN		NUMBER						,
			      p_parent_entity_name	IN		VARCHAR2					,
		              p_batch_id		IN		NUMBER						,
		              p_batch_party_id		IN		NUMBER						,
		              x_return_status	        OUT	NOCOPY	VARCHAR2
 			    );


--
-- Procedure: funding_party_h_merge
--
-- Description: This routine takes care of the party merge for OKE_K_FUNDING_SOURCES_H table
--

PROCEDURE funding_party_h_merge(p_merge_name		IN		VARCHAR2					,
   			        p_from_id		IN		NUMBER						,
   			        p_to_id			OUT	NOCOPY	NUMBER						,
   			        p_from_fk_id		IN		NUMBER						,
   			        p_to_fk_id		IN		NUMBER						,
			        p_parent_entity_name	IN		VARCHAR2					,
		                p_batch_id		IN		NUMBER						,
		                p_batch_party_id	IN		NUMBER						,
		                x_return_status	        OUT	NOCOPY	VARCHAR2
 			      );


end OKE_PARTY_MERGE_PKG;

 

/
