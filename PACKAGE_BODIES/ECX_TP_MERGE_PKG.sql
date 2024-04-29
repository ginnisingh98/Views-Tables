--------------------------------------------------------
--  DDL for Package Body ECX_TP_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_TP_MERGE_PKG" as
/* $Header: ECXPMRGB.pls 115.7 2003/07/01 21:20:18 rdiwan ship $ */
--
-- Procedure: ecx_party_merge
--
-- Description: This routine takes care of the party merge for ECX_TP_HEADERS
-- table


PROCEDURE ecx_party_merge(p_Entity_name			IN	VARCHAR2,
   			   p_from_id			IN	NUMBER,
   			   x_to_id			OUT	NOCOPY NUMBER,
		       	   p_From_FK_id			IN	NUMBER,
   			   p_To_FK_id			IN	NUMBER,
			   p_Parent_Entity_name		IN	VARCHAR2,
		           p_Batch_id		 	IN	NUMBER,
		           p_Batch_Party_id		IN	NUMBER,
		           x_return_status	        OUT	NOCOPY VARCHAR2
 			  ) is
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If parent has not changed
    IF (p_From_FK_id = p_To_FK_id) THEN
    	x_to_id := p_from_id;
    	return;
    END IF;

    -- update ECX_TP_HEADERS for the merge
    UPDATE ECX_TP_HEADERS
    SET    party_id 		= p_To_FK_id,
           last_updated_by	= hz_utility_pub.user_id,
           last_update_login	= hz_utility_pub.last_update_login
    WHERE  party_id             = p_From_FK_id
    AND    party_type           in ('C', 'E', 'CARRIER');

    -- update ECX_DOCLOGS for the merge
    UPDATE ECX_DOCLOGS
    SET    partyid              = to_char(p_To_FK_id)
    WHERE  partyid              = to_char(p_From_FK_id)
    AND    party_type           in ('C', 'E', 'CARRIER');

    -- update ECX_OUTBOUND_LOGS for the merge
    UPDATE ECX_OUTBOUND_LOGS
    SET    party_id              = to_char(p_To_FK_id)
    WHERE  party_id              = to_char(p_From_FK_id)
    AND    party_type            in ('C', 'E', 'CARRIER');

EXCEPTION
    WHEN OTHERS THEN
    	FND_MESSAGE.SET_NAME('ECX', 'ECX_MERGE_UNEXPECTED_ERROR');
    	FND_MESSAGE.SET_TOKEN('ERROR_CODE', SQLCODE);
    	FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE', SQLERRM);
    	FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END ecx_party_merge;

PROCEDURE ecx_party_sites_merge(
  			   p_Entity_name		IN	VARCHAR2,
   			   p_from_id			IN	NUMBER,
   			   x_to_id			OUT	NOCOPY NUMBER,
		       	   p_From_FK_id			IN	NUMBER,
   			   p_To_FK_id			IN	NUMBER,
			   p_Parent_Entity_name		IN	VARCHAR2,
		           p_Batch_id		 	IN	NUMBER,
		           p_Batch_Party_id		IN	NUMBER,
		           x_return_status	        OUT	NOCOPY VARCHAR2
 			  ) is
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- If parent has not changed
    IF (p_From_FK_id = p_To_FK_id) THEN
    	x_to_id := p_from_id;
    	return;
    END IF;

    -- update ECX_TP_HEADERS for the merge
    UPDATE ECX_TP_HEADERS
    SET    party_site_id 	= p_To_FK_id,
           last_updated_by	= hz_utility_pub.user_id,
           last_update_login	= hz_utility_pub.last_update_login
    WHERE  party_site_id        = p_From_FK_id
    AND    party_type           in ('C', 'E', 'CARRIER');

    -- update ECX_DOCLOGS for the merge
    UPDATE ECX_DOCLOGS
    SET    party_site_id   = to_char(p_To_FK_id)
    WHERE  party_site_id   = to_char(p_From_FK_id)
    AND    party_type      in ('C', 'E', 'CARRIER');

    -- update ECX_OUTBOUND_LOGS for the merge
    UPDATE ECX_OUTBOUND_LOGS
    SET    party_site_id   = to_char(p_To_FK_id)
    WHERE  party_site_id   = to_char(p_From_FK_id)
    AND    party_type      in ('C', 'E', 'CARRIER');

EXCEPTION
    WHEN OTHERS THEN
    	FND_MESSAGE.SET_NAME('ECX', 'ECX_MERGE_UNEXPECTED_ERROR');
    	FND_MESSAGE.SET_TOKEN('ERROR_CODE', SQLCODE);
    	FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE', SQLERRM);
    	FND_MSG_PUB.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END ecx_party_sites_merge;
END ECX_TP_MERGE_PKG;

/
