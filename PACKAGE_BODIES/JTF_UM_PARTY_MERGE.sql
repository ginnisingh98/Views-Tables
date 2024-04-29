--------------------------------------------------------
--  DDL for Package Body JTF_UM_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_UM_PARTY_MERGE" as
/*$Header: JTFUMPMB.pls 115.5 2002/11/21 22:58:12 kching ship $*/

PROCEDURE MERGE_APPROVAL
          (
            p_entity_name         IN    VARCHAR2,
            p_from_id		  IN    NUMBER,
            p_to_id		  out NOCOPY   NUMBER,
            p_from_fk_id          IN    NUMBER,
            p_to_fk_id	          IN    NUMBER,
            p_parent_entity_name  IN    VARCHAR2,
            p_batch_id		  IN    NUMBER,
            p_batch_party_id      IN    NUMBER,
            p_return_status       out NOCOPY   Varchar2
	  ) IS


    CURSOR MERGE_CODE IS SELECT  MERGE_REASON_CODE FROM HZ_MERGE_BATCH
    WHERE BATCH_ID = P_BATCH_ID;
    p_merge_code VARCHAR2(30);

    cursor find_approval is select approval_id from jtf_um_approvers
    where org_party_id = p_from_FK_id;

    p_approval_id number;

    BEGIN
	p_return_status := FND_API.G_RET_STS_SUCCESS;
        p_to_id := p_from_id;

       -- Validations.

       /* Check the Merge reason. If Merge Reason is Duplicate Record then no validation
          is performed.
       */

	open MERGE_CODE;
	fetch MERGE_CODE into p_merge_code;
	close MERGE_CODE;

     if p_merge_code = 'DUPLICATE' then
	   null;
     else
       -- Perform the Merge Operation.

	  /* If the Parent has NOT changed(i.e. Parent  getting transferred)  then
	     nothing needs to be done. Set Merged To Id is  same as Merged From Id
	     and return
	  */

          if p_from_FK_id = p_to_FK_id  then
	  return;
	  end if;


         /* If the Parent has changed(i.e. Parent is getting merged), then transfer
	    the dependent record to the new parent.
	 */

	  if p_from_FK_id  <> p_to_FK_id then

	  /* End Date all the approvers in JTF_UM_APPROVERS table, who
	     belonged to previous org
	  */
		open find_approval;
	        fetch find_approval into p_approval_id;
	        close find_approval;

	        if p_approval_id is not null then

	        UPDATE JTF_UM_APPROVERS SET EFFECTIVE_END_DATE = SYSDATE,
	        LAST_UPDATE_DATE = SYSDATE, LAST_UPDATE_LOGIN = FND_GLOBAL.USER_ID
	        WHERE ORG_PARTY_ID = p_from_FK_id;

	        -- Call procedure to restart workflow

		  -- User belonging to old org

	         JTF_UM_WF_APPROVAL.approval_chain_changed
		                    (
				    p_approval_id  => p_approval_id,
				    p_org_party_id => p_from_fk_id
				    );

		  -- User belonging to new org

		JTF_UM_WF_APPROVAL.approval_chain_changed
		                    (
				    p_approval_id  => p_approval_id,
				    p_org_party_id => p_to_fk_id
				    );
	        end if;
	  end if;
    end if;

  EXCEPTION
  WHEN OTHERS THEN
		FND_MESSAGE.SET_NAME('JTF', 'JTF_UM_PARTY_MERGE');
    		FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    		FND_MSG_PUB.ADD;
    		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END MERGE_APPROVAL;
END JTF_UM_PARTY_MERGE;

/
