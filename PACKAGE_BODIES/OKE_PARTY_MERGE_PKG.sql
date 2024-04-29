--------------------------------------------------------
--  DDL for Package Body OKE_PARTY_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_PARTY_MERGE_PKG" as
/* $Header: OKEVPMGB.pls 115.5 2002/11/21 20:48:46 syho ship $ */



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
		           x_return_status	        OUT	NOCOPY 	VARCHAR2
 			  ) is
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If parent has not changed
    IF (p_from_fk_id = p_to_fk_id) THEN
    	p_to_id := p_from_id;
    	return;
    END IF;

    -- update OKE_POOL_PARTIES for the merge
    UPDATE OKE_POOL_PARTIES
    SET    party_id 		= p_to_fk_id				,
    	   last_update_date	= hz_utility_pub.last_update_date	,
           last_updated_by	= hz_utility_pub.user_id		,
           last_update_login	= hz_utility_pub.last_update_login
    WHERE  party_id = p_from_fk_id;

EXCEPTION
    WHEN OTHERS THEN
    	FND_MESSAGE.SET_NAME('OKE', 'OKE_CONTRACTS_UNEXPECTED_ERROR');
    	FND_MESSAGE.SET_TOKEN('SQLcode', SQLCODE);
    	FND_MESSAGE.SET_TOKEN('SQLerrm', SQLERRM);
    	FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END pool_party_merge;


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
 			    ) is
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If parent has not changed
    IF (p_from_fk_id = p_to_fk_id) THEN
    	p_to_id := p_from_id;
    	return;
    END IF;

    -- update OKE_K_FUNDING_SOURCES for the merge
    UPDATE OKE_K_FUNDING_SOURCES
    SET    k_party_id 		= p_to_fk_id				,
    	   last_update_date	= hz_utility_pub.last_update_date	,
           last_updated_by	= hz_utility_pub.user_id		,
           last_update_login	= hz_utility_pub.last_update_login
    WHERE  k_party_id = p_from_fk_id;

EXCEPTION
    WHEN OTHERS THEN
    	FND_MESSAGE.SET_NAME('OKE', 'OKE_CONTRACTS_UNEXPECTED_ERROR');
    	FND_MESSAGE.SET_TOKEN('SQLcode', SQLCODE);
    	FND_MESSAGE.SET_TOKEN('SQLerrm', SQLERRM);
    	FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END funding_party_merge;


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
 			      ) is
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If parent has not changed
    IF (p_from_fk_id = p_to_fk_id) THEN
    	p_to_id := p_from_id;
    	return;
    END IF;

    -- update OKE_K_FUNDING_SOURCES_H for the merge
    UPDATE OKE_K_FUNDING_SOURCES_H
    SET    k_party_id 		= p_to_fk_id				,
    	   last_update_date	= hz_utility_pub.last_update_date	,
           last_updated_by	= hz_utility_pub.user_id		,
           last_update_login	= hz_utility_pub.last_update_login
    WHERE  k_party_id = p_from_fk_id;

EXCEPTION
    WHEN OTHERS THEN
    	FND_MESSAGE.SET_NAME('OKE', 'OKE_CONTRACTS_UNEXPECTED_ERROR');
    	FND_MESSAGE.SET_TOKEN('SQLcode', SQLCODE);
    	FND_MESSAGE.SET_TOKEN('SQLerrm', SQLERRM);
    	FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END funding_party_h_merge;


end OKE_PARTY_MERGE_PKG;

/
