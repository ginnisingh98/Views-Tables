--------------------------------------------------------
--  DDL for Package Body UMX_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."UMX_PARTY_MERGE" AS
/* $Header: UMXPMRGB.pls 115.1 2004/07/27 18:54:16 cmehta noship $ */

PROCEDURE MERGE_PARTIES
          (
            p_entity_name         IN    VARCHAR2,
            p_from_id		  IN    NUMBER,
            p_to_id		  OUT   NOCOPY   NUMBER,
            p_from_fk_id          IN    NUMBER,
            p_to_fk_id	          IN    NUMBER,
            p_parent_entity_name  IN    VARCHAR2,
            p_batch_id		  IN    NUMBER,
            p_batch_party_id      IN    NUMBER,
            p_return_status       out NOCOPY   Varchar2
	  ) IS

CURSOR GET_STATUS IS SELECT STATUS_CODE FROM UMX_REG_REQUESTS
WHERE REQUESTED_FOR_PARTY_ID = p_from_fk_id
and status_code = 'PENDING';
l_status_code UMX_REG_REQUESTS.STATUS_CODE%TYPE;

BEGIN

    -- Set the return status to success unless an error occurs
    p_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check for the request status. If it is Pending, don't allow the merge
    open GET_STATUS;
    fetch GET_STATUS into l_status_code;
    if GET_STATUS%FOUND then
        p_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('FND','UMX_MERGE_NOT_ALLOWED');
	FND_MSG_PUB.ADD;
        close GET_STATUS;
	return;
    else
        close GET_STATUS;
    end if;

    -- If the parent has not changed, no need to do anything

    if p_from_FK_id = p_to_FK_id  then

       return;

    else

        if  p_parent_entity_name = 'HZ_PARTIES' then
             -- Update the table with the new party_id
             update umx_reg_requests set requested_for_party_id = p_To_FK_id,
                               last_update_date = hz_utility_pub.last_update_date,
      			 	last_updated_by = hz_utility_pub.user_id,
     			 	last_update_login = hz_utility_pub.last_update_login
                                where requested_for_party_id = p_From_FK_id;
             return;
        end if;
    end if;

EXCEPTION
  WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    		FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		FND_MSG_PUB.ADD;
    		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_PARTIES;

end UMX_PARTY_MERGE;

/
