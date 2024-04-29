--------------------------------------------------------
--  DDL for Package Body AR_CMGT_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CMGT_PARTY_MERGE" AS
/* $Header: ARCMGPMB.pls 120.1.12010000.2 2008/09/08 08:36:07 rviriyal ship $ */

PROCEDURE CREDIT_REQUEST_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2) AS

    l_merge_reason_code          hz_merge_batch.merge_reason_code%type;

Begin
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CMGT_CREDIT_REQUEST(+)');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Check the Merge reason. If Merge Reason is 'Duplicate Record'
    then no validation is performed.  */

	select merge_reason_code
    into   l_merge_reason_code
	from hz_merge_batch
	where batch_id = p_batch_id;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'Merge Reason Code '||l_merge_reason_code);

    if l_merge_reason_code = 'DUPLICATE' then
		  null;
    end if;


   /* Perform the Merge Operation. */

    /* If the Parent has NOT changed(i.e. Parent  getting transferred)
    then nothing needs to be done.
    Set Merged To Id is the same as Merged From Id  and return */

    if p_from_FK_id = p_to_FK_id  then
	   x_to_id := p_from_id;
       return;
    end if;


    /* If the Parent has changed(i.e. Parent is getting merged),
    then transfer the dependent record to the new parent.
    Before transferring check if a similar dependent record
    exists on the new parent . If a duplicate exists then do not
    transfer and return the id of the duplicate record as the Merged To Id.*/

    if p_from_FK_id  <> p_to_FK_id then
        if  p_parent_entity_name = 'HZ_PARTIES' then
           UPDATE ar_cmgt_credit_requests
            set   party_id = p_To_FK_id
           WHERE  party_id = p_from_fk_id;
	   end if;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'End Party Merge for AR_CMGT_CREDIT_REQUEST(-)');
    Exception
		when others then
			 FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    		 FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		 FND_MSG_PUB.ADD;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End;

PROCEDURE CONTACT_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2) AS

    l_merge_reason_code          hz_merge_batch.merge_reason_code%type;

Begin
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Contact Merge for AR_CMGT_CREDIT_REQUEST(+)');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Check the Merge reason. If Merge Reason is 'Duplicate Record'
    then no validation is performed.  */

	select merge_reason_code
    into   l_merge_reason_code
	from hz_merge_batch
	where batch_id = p_batch_id;

	if l_merge_reason_code = 'DUPLICATE' then
		  null;
    end if;


   /* Perform the Merge Operation. */

    /* If the Parent has NOT changed(i.e. Parent  getting transferred)
    then nothing needs to be done.
    Set Merged To Id is the same as Merged From Id  and return */

    if p_from_FK_id = p_to_FK_id  then
	   x_to_id := p_from_id;
       return;
    end if;


    /* If the Parent has changed(i.e. Parent is getting merged),
    then transfer the dependent record to the new parent.
    Before transferring check if a similar dependent record
    exists on the new parent . If a duplicate exists then do not
    transfer and return the id of the duplicate record as the Merged To Id.*/

    if p_from_FK_id  <> p_to_FK_id then
        if  p_parent_entity_name = 'HZ_PARTIES' then
           UPDATE ar_cmgt_credit_requests
            set   contact_party_id = p_To_FK_id
           WHERE  contact_party_id = p_from_fk_id
           AND    contact_party_id IS NOT NULL;
	   end if;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Contact Merge for AR_CMGT_CREDIT_REQUEST(-)');
    Exception
		when others then
			 FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    		 FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		 FND_MSG_PUB.ADD;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End;

PROCEDURE CASE_FOLDER_MERGE (
    p_entity_name                IN   VARCHAR2,
    p_from_id                    IN   NUMBER,
    x_to_id                      OUT  NOCOPY NUMBER,
    p_from_fk_id                 IN   NUMBER,
    p_to_fk_id                   IN   NUMBER,
    p_parent_entity_name         IN   VARCHAR2,
    p_batch_id                   IN   NUMBER,
    p_batch_party_id             IN   NUMBER,
    x_return_status              OUT  NOCOPY VARCHAR2) AS

    l_merge_reason_code          hz_merge_batch.merge_reason_code%type;

Begin
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CMGT_CASE_FOLDERS(+)');
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Check the Merge reason. If Merge Reason is 'Duplicate Record'
    then no validation is performed.  */

	select merge_reason_code
    into   l_merge_reason_code
	from hz_merge_batch
	where batch_id = p_batch_id;

	if l_merge_reason_code = 'DUPLICATE' then
		  null;
    end if;


   /* Perform the Merge Operation. */

    /* If the Parent has NOT changed(i.e. Parent  getting transferred)
    then nothing needs to be done.
    Set Merged To Id is the same as Merged From Id  and return */

    if p_from_FK_id = p_to_FK_id  then
	   x_to_id := p_from_id;
       return;
    end if;


    /* If the Parent has changed(i.e. Parent is getting merged),
    then transfer the dependent record to the new parent.
    Before transferring check if a similar dependent record
    exists on the new parent . If a duplicate exists then do not
    transfer and return the id of the duplicate record as the Merged To Id.*/

    if p_from_FK_id  <> p_to_FK_id then
        if  p_parent_entity_name = 'HZ_PARTIES' then
		    -- First Delete the data record in case of
 	        -- merge otherwise it will create
 	        -- a duplicate record bug 7370428
 	            DELETE from ar_cmgt_cf_dtls
 	              WHERE case_folder_id IN (
 	                 SELECT case_folder_id
 	                 from   ar_cmgt_case_folders
 	                 WHERE  party_id = p_from_fk_id
 	                 AND   type = 'DATA' );

 	            DELETE from ar_cmgt_case_folders
 	              WHERE party_id = p_from_fk_id
 	              AND   type = 'DATA';

           UPDATE ar_cmgt_case_folders
            set   party_id = p_To_FK_id
           WHERE  party_id = p_from_fk_id;
	   end if;
    end if;
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CMGT_CASE_FOLDERS(-)');
    Exception
		when others then
			 FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    		 FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		 FND_MSG_PUB.ADD;
    		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
End;


PROCEDURE MERGE_CT_CALLS_INFO(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CUSTOMER_CALLS_ALL(+)');


x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then



    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. child  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For AR_CUSTOMER_CALLS_ALL table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with customer_id = 1000 to 2000

if p_from_fk_id  <> p_to_fk_id then


    UPDATE  AR_CUSTOMER_CALLS_ALL
    SET phone_id = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    WHERE
        phone_id = p_from_fk_id;

end if;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CUSTOMER_CALLS_ALL(-)');

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END MERGE_CT_CALLS_INFO;


PROCEDURE MERGE_CT_CALL_TOPICS_INFO(
        p_entity_name            IN   VARCHAR2,
        p_from_id            IN   NUMBER,
        x_to_id              OUT NOCOPY  NUMBER,
        p_from_fk_id             IN   NUMBER,
        p_to_fk_id           IN   NUMBER,
        p_parent_entity_name         IN   VARCHAR2,
        p_batch_id           IN   NUMBER,
        p_batch_party_id         IN   NUMBER,
        x_return_status          OUT NOCOPY  VARCHAR2) IS

l_merge_reason_code  VARCHAR2(30);

Cursor  c_duplicate Is
select  merge_reason_code
from    hz_merge_batch
where   batch_id = p_batch_id;


BEGIN

FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CUSTOMER_CALL_TOPICS_ALL(+)');

x_return_status := FND_API.G_RET_STS_SUCCESS;

open    c_duplicate;
fetch   c_duplicate into l_merge_reason_code;
close   c_duplicate;

if l_merge_reason_code <> 'DUPLICATE' then

    -- if there are any validations to be done, include it in this section
    -- if reason code is duplicate then allow the party merge to happen without
    -- any validations.

    null;

end if;

-- perform the merge operation

-- if the parent has NOT changed(i.e. child  getting transferred)  then nothing
-- needs to be done. Set merged to id (x_to_id) the same as merged from id and return

if p_from_fk_id = p_to_fk_id  then

    x_to_id := p_from_id;
    return;

end if;


   -- If the parent has changed(ie. Parent is getting merged) then transfer the
   -- dependent record to the new parent.
   -- For AR_CUSTOMER_CALLS_ALL table, if party_id 1000 got merged to party_id  2000
   -- then, we have to update all records with customer_id = 1000 to 2000

if p_from_fk_id  <> p_to_fk_id then


    UPDATE  AR_CUSTOMER_CALL_TOPICS_ALL
    SET phone_id = p_to_fk_id,
        last_update_date  = hz_utility_pub.last_update_date,
        last_updated_by   = hz_utility_pub.user_id,
        last_update_login = hz_utility_pub.last_update_login
    WHERE
        phone_id = p_from_fk_id;

end if;

FND_FILE.PUT_LINE(FND_FILE.LOG,'Start Party Merge for AR_CUSTOMER_CALL_TOPICS_ALL(-)');

exception
when others then

fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
fnd_message.set_token('ERROR' ,SQLERRM);
fnd_msg_pub.add;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END MERGE_CT_CALL_TOPICS_INFO;



END;

/
