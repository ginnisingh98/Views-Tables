--------------------------------------------------------
--  DDL for Package Body AMW_FINSTMT_CERT_MIG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_FINSTMT_CERT_MIG_PKG" AS
/* $Header: amwfmigb.pls 120.0 2005/09/09 14:50:09 appldev noship $  */

--G_USER_ID NUMBER   := FND_GLOBAL.USER_ID;
--G_LOGIN_ID NUMBER  := FND_GLOBAL.CONC_LOGIN_ID;

G_PKG_NAME    CONSTANT VARCHAR2 (30) := 'AMW_FINSTMT_CERT_MIG_PKG';
G_API_NAME   CONSTANT VARCHAR2 (15) := 'amwfmigb.pls';



PROCEDURE POPULATE_PROC_HIERARCHY(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
P_CERTIFICATION_ID NUMBER,
P_PROCESS_ID NUMBER,
P_ORGANIZATION_ID NUMBER,
p_account_process_flag VARCHAR2,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
 )IS

  l_count NUMBER;

  l_api_name           CONSTANT VARCHAR2(30) := 'POPULATE_PROC_HIERARCHY';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

  BEGIN

  SAVEPOINT POPULATE_PROC_HIERARCHY;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT COUNT(1) INTO l_count FROM AMW_FIN_PROCESS_FLAT
  WHERE PARENT_PROCESS_ID = P_PROCESS_ID
  AND ORGANIZATION_ID = P_ORGANIZATION_ID
  AND FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

  --process directly associates to the account which belongs to this financial statement
  -- to simplify the query, try amw_org_hierarchy_denorm
  IF(l_count = 0 or l_count is null) THEN
  		IF  p_account_process_flag = 'Y' THEN
   INSERT INTO AMW_FIN_PROCESS_FLAT
                    (
                     FIN_CERTIFICATION_ID,
                     PARENT_PROCESS_ID,
                     CHILD_PROCESS_ID,
                     ORGANIZATION_ID,
                     CREATED_BY ,
                     CREATION_DATE  ,
                     LAST_UPDATED_BY  ,
                     LAST_UPDATE_DATE  ,
                     LAST_UPDATE_LOGIN  ,
                     SECURITY_GROUP_ID ,
                     OBJECT_VERSION_NUMBER )
                     select P_CERTIFICATION_ID, process_id,  parent_child_id, organization_id, 1, sysdate, 1, sysdate, 1, null, 1
                     from amw_org_hierarchy_denorm
                     where organization_id = P_ORGANIZATION_ID
                  	and hierarchy_type = 'A'
                  	and process_id = P_PROCESS_ID
                  	and (up_down_ind = 'D'
                  	or (parent_child_id = -2 and  up_down_ind= 'U'));
                 ELSE
                    INSERT INTO AMW_FIN_PROCESS_FLAT
                    (
                     FIN_CERTIFICATION_ID,
                     PARENT_PROCESS_ID,
                     CHILD_PROCESS_ID,
                     ORGANIZATION_ID,
                     CREATED_BY ,
                     CREATION_DATE  ,
                     LAST_UPDATED_BY  ,
                     LAST_UPDATE_DATE  ,
                     LAST_UPDATE_LOGIN  ,
                     SECURITY_GROUP_ID ,
                     OBJECT_VERSION_NUMBER )
                     select P_CERTIFICATION_ID, process_id,  parent_child_id, organization_id, 1, sysdate, 1, sysdate, 1, null, 1
                      from amw_org_hierarchy_denorm
                  	where organization_id = P_ORGANIZATION_ID
                  	and hierarchy_type = 'A'
                  	and process_id = P_PROCESS_ID
                  	and up_down_ind = 'D';

                     END IF;

    END IF;

--process directly associates to the account which belongs to this financial statement
-- to be deleted because it's a less efficient solution
-- Note: select p_process_id is very important. it's different from select parent_id
/*
  IF  p_account_process_flag = 'Y' THEN
  INSERT INTO AMW_FIN_PROCESS_FLAT
  (CERTIFICATION_ID,
   PARENT_PROCESS_ID,
   CHILD_PROCESS_ID,
   ORGANIZATION_ID)
   (SELECT  distinct P_CERTIFICATION_ID, P_PROCESS_ID, child_id, organization_id
   FROM    AMW_APPROVED_HIERARCHIES
   START WITH parent_id = P_PROCESS_ID
   AND organization_id = P_ORGANIZATION_ID
   CONNECT BY prior child_id = parent_id
   AND  prior organization_id = organization_id
   UNION ALL
   SELECT P_CERTIFICATION_ID, P_PROCESS_ID, -1, P_ORGANIZATION_ID FROM DUAL);
  -- sub processes of the process which directly links to the account
  ELSE
  INSERT INTO AMW_FIN_PROCESS_FLAT
  (CERTIFICATION_ID,
   PARENT_PROCESS_ID,
   CHILD_PROCESS_ID,
   ORGANIZATION_ID)
   SELECT  distinct P_CERTIFICATION_ID, P_PROCESS_ID, child_id, organization_id
   FROM    AMW_APPROVED_HIERARCHIES
   START WITH parent_id = P_PROCESS_ID
   AND organization_id = P_ORGANIZATION_ID
   CONNECT BY prior child_id = parent_id
   AND  prior organization_id = organization_id;
   END IF;

      **********************/

if(p_commit <> FND_API.g_false)
then commit;
end if;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO POPULATE_PROC_HIERARCHY;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

 END POPULATE_PROC_HIERARCHY;

 ----------------------------- ********************************** ----------------------
-- this procedure build a flat table for financial certification, item, account, process
-- it contains the whole structure of financial information no matter weather process associated to it or not
-- it contains 3 layesr joins for 4 situations.
-- layer 1: join certification  with fin_stmnt_items
-- layter 2: join resultset of layer1 with key_account
-- layer 3: join resultset of layer2 with process hierarchy via account_association

--situation 1: accounts have one or more children linking to a process
--situation 2: account directly assocates with a process and also links to one or more financial items
--situation 3: --- add all of childen accounts which associate with the top account which directly links to an item
--- e.g A2 is a child of A1. A1 links to an financial item which relates to fin certification
--  and P1 is associated with A2. so we want to add one record which contains A2, P1 info. in scope table

--situation 4:
-- account has sub-account, but account itself doesn't associate with any item. His parent/parent's parent links to -- -- item.
--- and its sub-account links to a process. e.g A1-A2-A3, A3-P1. so this query make A2-P

---for performance reason, we split a big query into 4 queries based on 4 situtation.
----------------------------- ********************************** ----------------------

PROCEDURE INSERT_FIN_CERT_SCOPE(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

L_COUNT NUMBER;
L_COUNT2 NUMBER;
l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_FIN_CERT_SCOPE';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT INSERT_FIN_CERT_SCOPE;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO L_COUNT FROM AMW_FIN_CERT_SCOPE
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

/** even if there is no process attached to an account. if the account belongs to the financial
**  certification, we should add it to the amw_fin_cert_scope table
SELECT COUNT(1) INTO L_COUNT2 FROM AMW_FIN_PROCESS_EVAL_SUM
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;


IF (L_COUNT2 = 0 OR L_COUNT2 IS NULL) THEN
RETURN;
END IF;
****/

IF (L_COUNT = 0 OR L_COUNT IS NULL) THEN
----add those accounts that have one or more children linking to a process
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID ,
FIN_CERTIFICATION_ID ,
STATEMENT_GROUP_ID ,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, itemaccmerge.statement_group_id, itemaccmerge.financial_statement_id, itemaccmerge.financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id, case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.STATEMENT_GROUP_ID, temp.FINANCIAL_STATEMENT_ID, temp.FINANCIAL_ITEM_ID,
 		temp.ACCOUNT_GROUP_ID,
 		case when temp.NATURAL_ACCOUNT_ID = -1 then temp.child_natural_account_id else temp.NATURAL_ACCOUNT_ID end natural_account_id,
 		ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	 (select temp2.statement_group_id, temp2.financial_statement_id, temp2.financial_item_id,
 		  temp2.account_group_id, temp2.natural_account_id, flat.child_natural_account_id
		  from AMW_FIN_KEY_ACCT_FLAT flat,
 		  (select distinct temp1.statement_group_id, temp1.financial_statement_id,
		   case when temp1.financial_item_id = -1 then temp1.child_financial_item_id
		   else temp1.financial_item_id end financial_item_id, itemaccrel.account_group_id, itemaccrel.natural_account_id
		  from  AMW_FIN_ITEMS_KEY_ACC ITEMACCREL,

      			(select -1 financial_item_id, itemb.financial_item_id child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			FROM AMW_CERTIFICATION_B cert,
     	     		     AMW_FIN_STMNT_ITEMS_B itemb
			WHERE cert.CERTIFICATION_ID = P_CERTIFICATION_ID
			and cert.statement_group_id = itemb.statement_group_id
			and cert.financial_statement_id = itemb.financial_statement_id
		UNION ALL
			select itemb.financial_item_id, itemflat.child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			from AMW_FIN_ITEM_FLAT itemflat,
     	     		        AMW_FIN_STMNT_ITEMS_B itemb,
             		     	        AMW_CERTIFICATION_B cert
			where
				cert.CERTIFICATION_ID = P_CERTIFICATION_ID
				and cert.statement_group_id = itemb.statement_group_id
				and cert.financial_statement_id = itemb.financial_statement_id
				and itemflat.parent_financial_item_id = itemb.financial_item_id
				and itemflat.statement_group_id = itemb.statement_group_id
				and itemflat.financial_statement_id = itemb.financial_statement_id) temp1
			where
    				temp1.statement_group_id = ITEMACCREL.statement_group_id (+)
   				and temp1.financial_statement_id = ITEMACCREL.financial_statement_id (+)
   				and temp1.child_financial_item_id = ITEMACCREL.financial_item_id (+)) temp2
 		   where temp2.account_group_id = flat.account_group_id
 		   and temp2.natural_account_id = flat.parent_natural_account_id) temp
 	WHERE
 		ACCREL.NATURAL_ACCOUNT_ID  = temp.CHILD_NATURAL_ACCOUNT_ID) itemaccmerge
		-- only insert those account whose childen have a link to the process
		--ACCREL.NATURAL_ACCOUNT_ID (+) = temp.CHILD_NATURAL_ACCOUNT_ID) itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id (+) = p_certification_id;

-- add account which has link to a item and also directly assocates with a process
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID ,
FIN_CERTIFICATION_ID ,
STATEMENT_GROUP_ID,
FINANCIAL_STATEMENT_ID ,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID                       ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, itemaccmerge.statement_group_id, itemaccmerge.financial_statement_id, itemaccmerge.financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id, case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.STATEMENT_GROUP_ID, temp.FINANCIAL_STATEMENT_ID, temp.FINANCIAL_ITEM_ID,
 temp.ACCOUNT_GROUP_ID,temp.NATURAL_ACCOUNT_ID,ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	(select distinct temp1.statement_group_id, temp1.financial_statement_id,
		   case when temp1.financial_item_id = -1 then temp1.child_financial_item_id
		   else temp1.financial_item_id end financial_item_id, itemaccrel.account_group_id, itemaccrel.natural_account_id
		  from  AMW_FIN_ITEMS_KEY_ACC ITEMACCREL,

      			(select -1 financial_item_id, itemb.financial_item_id child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			FROM AMW_CERTIFICATION_B cert,
     	     		     AMW_FIN_STMNT_ITEMS_B itemb
			WHERE cert.CERTIFICATION_ID = P_CERTIFICATION_ID
			and cert.statement_group_id = itemb.statement_group_id
			and cert.financial_statement_id = itemb.financial_statement_id
		UNION ALL
			select itemb.financial_item_id, itemflat.child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			from AMW_FIN_ITEM_FLAT itemflat,
     	     		        AMW_FIN_STMNT_ITEMS_B itemb,
             		     	        AMW_CERTIFICATION_B cert
			where
				cert.CERTIFICATION_ID = P_CERTIFICATION_ID
				and cert.statement_group_id = itemb.statement_group_id
				and cert.financial_statement_id = itemb.financial_statement_id
				and itemflat.parent_financial_item_id = itemb.financial_item_id
				and itemflat.statement_group_id = itemb.statement_group_id
				and itemflat.financial_statement_id = itemb.financial_statement_id) temp1
			where
    				temp1.statement_group_id = ITEMACCREL.statement_group_id (+)
   				and temp1.financial_statement_id = ITEMACCREL.financial_statement_id (+)
   				and temp1.child_financial_item_id = ITEMACCREL.financial_item_id (+)) temp
 	WHERE
		ACCREL.NATURAL_ACCOUNT_ID (+) = temp.NATURAL_ACCOUNT_ID) itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id (+) = p_certification_id;

--- add all of childen accounts which associate with the top account which directly links to an item
--- e.g A2 is a child of A1. A1 links to an financial item which relates to fin certification
--  and P1 is associated with A2. so we want to add one record which contains A2, P1 info. in scope table
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID 			,
FIN_CERTIFICATION_ID                   ,
STATEMENT_GROUP_ID		       ,
FINANCIAL_STATEMENT_ID                 ,
FINANCIAL_ITEM_ID                      ,
ACCOUNT_GROUP_ID                       ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, itemaccmerge.statement_group_id, itemaccmerge.financial_statement_id, itemaccmerge.financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id, case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.STATEMENT_GROUP_ID, temp.FINANCIAL_STATEMENT_ID, temp.FINANCIAL_ITEM_ID,
 		temp.ACCOUNT_GROUP_ID,
 		temp.child_natural_account_id natural_account_id,
 		ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	(select temp2.statement_group_id, temp2.financial_statement_id, temp2.financial_item_id,
  		flat.account_group_id, flat.child_natural_account_id
  		from AMW_FIN_KEY_ACCT_FLAT flat,
 		        (select distinct temp1.statement_group_id, temp1.financial_statement_id,
		   case when temp1.financial_item_id = -1 then temp1.child_financial_item_id
		   else temp1.financial_item_id end financial_item_id, itemaccrel.account_group_id, itemaccrel.natural_account_id
		  from  AMW_FIN_ITEMS_KEY_ACC ITEMACCREL,

      			(select -1 financial_item_id, itemb.financial_item_id child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			FROM AMW_CERTIFICATION_B cert,
     	     		     AMW_FIN_STMNT_ITEMS_B itemb
			WHERE cert.CERTIFICATION_ID = P_CERTIFICATION_ID
			and cert.statement_group_id = itemb.statement_group_id
			and cert.financial_statement_id = itemb.financial_statement_id
		UNION ALL
			select itemb.financial_item_id, itemflat.child_financial_item_id, itemb.statement_group_id, itemb.financial_statement_id
			from AMW_FIN_ITEM_FLAT itemflat,
     	     		        AMW_FIN_STMNT_ITEMS_B itemb,
             		     	        AMW_CERTIFICATION_B cert
			where
				cert.CERTIFICATION_ID = P_CERTIFICATION_ID
				and cert.statement_group_id = itemb.statement_group_id
				and cert.financial_statement_id = itemb.financial_statement_id
				and itemflat.parent_financial_item_id = itemb.financial_item_id
				and itemflat.statement_group_id = itemb.statement_group_id
				and itemflat.financial_statement_id = itemb.financial_statement_id) temp1
			where
    				temp1.statement_group_id = ITEMACCREL.statement_group_id (+)
   				and temp1.financial_statement_id = ITEMACCREL.financial_statement_id (+)
   				and temp1.child_financial_item_id = ITEMACCREL.financial_item_id (+))temp2
 		where temp2.account_group_id = flat.account_group_id
 		and temp2.natural_account_id = flat.parent_natural_account_id) temp
 	WHERE
		ACCREL.NATURAL_ACCOUNT_ID (+)  = temp.CHILD_NATURAL_ACCOUNT_ID)  itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id (+) = p_certification_id;



-- account has sub-account, but account itself doesn't associate with any item. His parent/parent's parent links to -- -- item.
--- and its sub-account links to a process. e.g A1-A2-A3, A3-P1. so this query make A2-P
insert into amw_fin_cert_scope(
FIN_CERT_SCOPE_ID 			,
FIN_CERTIFICATION_ID                   ,
STATEMENT_GROUP_ID		       ,
FINANCIAL_STATEMENT_ID                 ,
FINANCIAL_ITEM_ID                      ,
ACCOUNT_GROUP_ID                       ,
NATURAL_ACCOUNT_ID                     ,
ORGANIZATION_ID				,
PROCESS_ID				,
CREATED_BY                             ,
CREATION_DATE                          ,
LAST_UPDATED_BY                        ,
LAST_UPDATE_DATE                       ,
LAST_UPDATE_LOGIN                      ,
SECURITY_GROUP_ID                      ,
OBJECT_VERSION_NUMBER )
SELECT AMW_FIN_CERT_SCOPE_S.NEXTVAL, P_CERTIFICATION_ID, null statement_group_id, null financial_statement_id,
null financial_item_id,
itemaccmerge.account_group_id, itemaccmerge.natural_account_id,itemaccmerge.organization_id,
case when proc.child_process_id = -2 then itemaccmerge.process_id else proc.child_process_id end process_id,
1, sysdate, 1, sysdate, 1, null, 1
FROM
	AMW_FIN_PROCESS_FLAT proc,

	(SELECT temp.ACCOUNT_GROUP_ID,
 		temp.NATURAL_ACCOUNT_ID,
 		ACCREL.PK1 organization_id, ACCREL.PK2 process_id
 	 FROM
 		(SELECT NATURAL_ACCOUNT_ID, PK1, PK2 FROM AMW_ACCT_ASSOCIATIONS
 		 WHERE OBJECT_TYPE = 'PROCESS_ORG'
 		 AND APPROVAL_DATE IS NOT NULL
 		 AND DELETION_APPROVAL_DATE IS NULL
 		 ) ACCREL,

	   	(select flat.account_group_id, flat.parent_natural_account_id natural_account_id, flat.child_natural_account_id
 		from
 			(select flat.account_group_id, flat.parent_natural_account_id, flat.child_natural_account_id
				from AMW_FIN_KEY_ACCT_FLAT flat
			start with (account_group_id, parent_natural_account_id) in
			(select account_group_id, natural_account_id
 			      from amw_fin_cert_scope
 			      where fin_certification_id = P_CERTIFICATION_ID)
 			connect by parent_natural_account_id = prior child_natural_account_id
 			           and account_group_id = prior account_group_id) flat
 	       where not exists (
 		select 'Y'
 		from AMW_FIN_CERT_SCOPE  temp2
 		where flat.account_group_id = temp2.account_group_id
 		and   flat.parent_natural_account_id = temp2.natural_account_id
 		and   temp2.fin_certification_id = P_CERTIFICATION_ID) ) temp
 	WHERE
		ACCREL.NATURAL_ACCOUNT_ID (+) = temp.CHILD_NATURAL_ACCOUNT_ID)  itemaccmerge
WHERE proc.organization_id (+) = itemaccmerge.organization_id
and proc.parent_process_id (+) = itemaccmerge.process_id
and proc.fin_certification_id(+) = P_CERTIFICATION_ID;

END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO INSERT_FIN_CERT_SCOPE;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);

END INSERT_FIN_CERT_SCOPE;

---------------------------------The following procedures are only for migration purpose------------
---------------------------------name convention is the regular procedure name_M ------------------
PROCEDURE Populate_Fin_Risk_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

CURSOR c_finrisks IS
SELECT
	risks.risk_id,
	risks.PK1,
	risks.PK2,
	risks.ASSOCIATION_CREATION_DATE,
	risks.APPROVAL_DATE,
	risks.DELETION_DATE,
	risks.DELETION_APPROVAL_DATE,
	risk.RISK_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_FIN_PROCESS_EVAL_SUM eval,
	AMW_RISKS_B risk
WHERE
	eval.fin_certification_id = p_certification_id
	and risk.risk_id = risks.risk_id
	and risk.CURR_APPROVED_FLAG = 'Y'
	and risks.object_type='PROCESS_ORG'
	and risks.PK1 = eval.organization_id
	and risks.PK2 = eval.process_id
	and risks.approval_date is not null
	and risks.approval_date <= sysdate
	and risks.deletion_approval_date is null
UNION ALL
SELECT
	risks.risk_id,
	risks.PK1,
	risks.PK2,
	risks.ASSOCIATION_CREATION_DATE,
	risks.APPROVAL_DATE,
	risks.DELETION_DATE,
	risks.DELETION_APPROVAL_DATE,
	risk.RISK_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_FIN_PROCESS_EVAL_SUM eval,
	AMW_RISKS_B risk
WHERE
	eval.fin_certification_id = p_certification_id
	and risk.risk_id = risks.risk_id
	and risk.CURR_APPROVED_FLAG = 'Y'
	and risks.object_type='ENTITY_RISK'
	and risks.PK1 = eval.organization_id
	and risks.approval_date is not null
	and risks.approval_date <= sysdate
	and risks.deletion_approval_date is null;

	--in risk association table, if type = 'PROCESS_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=opinion_log_id
	CURSOR last_evaluation(l_risk_id number, l_organization_id number, l_process_id number)  IS
        select distinct ao.opinion_log_id
	from    AMW_OPINIONS_LOG ao,
     		AMW_OBJECT_OPINION_TYPES aoot,
     		AMW_OPINION_TYPES_B aot,
     		FND_OBJECTS fo
	where   ao.OBJECT_OPINION_TYPE_ID = aoot.OBJECT_OPINION_TYPE_ID
		and aoot.OPINION_TYPE_ID = aot.OPINION_TYPE_ID
		and aoot.OBJECT_ID = fo.OBJECT_ID
		and fo.obj_name = 'AMW_ORG_PROCESS_RISK'
       		and aot.opinion_type_code = 'EVALUATION'
        	and ao.pk3_value = l_organization_id
        	and ao.pk4_value = l_process_id
        	and ao.pk1_value = l_risk_id
        	and ao.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = ao.object_opinion_type_id
                                     and aov2.pk3_value = ao.pk3_value
                                     and aov2.pk1_value = ao.pk1_value
                                     and aov2.pk4_value = ao.pk4_value);

l_count NUMBER;
m_opinion_log_id NUMBER;
l_error_message varchar2(4000);


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Risk_Ass_Sum_M';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT Populate_Fin_Risk_Ass_Sum_M;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT COUNT(1) INTO l_count FROM AMW_RISK_ASSOCIATIONS
	WHERE object_type = 'PROCESS_FINCERT'
	AND pk1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR risk_rec IN c_finrisks LOOP
	exit when c_finrisks%notfound;

		m_opinion_log_id := null;
		OPEN last_evaluation(risk_rec.risk_id, risk_rec.pk1, risk_rec.pk2);
		FETCH last_evaluation INTO m_opinion_log_id;
		CLOSE last_evaluation;



		INSERT INTO AMW_RISK_ASSOCIATIONS(
 			       RISK_ASSOCIATION_ID,
			       RISK_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       RISK_REV_ID)
			 VALUES ( amw_risk_associations_s.nextval,
			         risk_rec.risk_id,
			         p_certification_id,
			         risk_rec.PK1,
			         risk_rec.PK2,
			         m_opinion_log_id,
			         FND_GLOBAL.USER_ID,
			       	 SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'PROCESS_FINCERT',
			         risk_rec.ASSOCIATION_CREATION_DATE,
			         risk_rec.APPROVAL_DATE,
				 risk_rec.DELETION_DATE,
				 risk_rec.DELETION_APPROVAL_DATE,
				 risk_rec.RISK_REV_ID);

		END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;

    	END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_finrisks%ISOPEN THEN
      	close c_finrisks;
         END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_finrisks%ISOPEN THEN
      	close c_finrisks;
         END IF;
       ROLLBACK TO Populate_Fin_Risk_Ass_Sum_M;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_Risk_Ass_Sum_M;

PROCEDURE Populate_Fin_Ctrl_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
CURSOR c_fincontrols IS

SELECT
	controls.control_id,
	controls.PK1,
	controls.PK2,
	controls.PK3,
	controls.ASSOCIATION_CREATION_DATE,
	controls.APPROVAL_DATE,
	controls.DELETION_DATE,
	controls.DELETION_APPROVAL_DATE,
	control.CONTROL_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_CONTROLS_B control
WHERE
	controls.object_type='RISK_ORG'
	and control.CURR_APPROVED_FLAG = 'Y'
	and control.control_id = controls.control_id
	and risks.PK1 = p_certification_id
	and risks.PK2 = controls.PK1
	and risks.PK3 = controls.PK2
	and controls.PK3 = risks.risk_id
	and risks.object_type = 'PROCESS_FINCERT'
UNION ALL
SELECT
	controls.control_id,
	controls.PK1,
	controls.PK2,
	controls.PK3,
	controls.ASSOCIATION_CREATION_DATE,
	controls.APPROVAL_DATE,
	controls.DELETION_DATE,
	controls.DELETION_APPROVAL_DATE,
	control.CONTROL_REV_ID
FROM
	AMW_RISK_ASSOCIATIONS risks,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_CONTROLS_B control
WHERE
	controls.object_type='ENTITY_CONTROL'
	and control.CURR_APPROVED_FLAG = 'Y'
	and control.control_id = controls.control_id
	and risks.PK1 = p_certification_id
	and risks.PK2 = controls.PK1
	and risks.PK3 IS NULL
	and controls.PK3 = risks.risk_id
	and risks.object_type = 'PROCESS_FINCERT';



--in control association table, if type = 'RISK_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=risk_id, pk5=opinion_log_id
	CURSOR last_evaluation(l_organization_id number, l_control_id number)  IS
        select distinct ao.opinion_log_id
	from
     		AMW_OPINIONS_LOG ao,
     		AMW_OBJECT_OPINION_TYPES aoot,
     		AMW_OPINION_TYPES_B aot,
     		FND_OBJECTS fo
	where ao.OBJECT_OPINION_TYPE_ID = aoot.OBJECT_OPINION_TYPE_ID
		and aoot.OPINION_TYPE_ID = aot.OPINION_TYPE_ID
		and aoot.OBJECT_ID = fo.OBJECT_ID
		and fo.obj_name = 'AMW_ORG_CONTROL'
       		and aot.opinion_type_code = 'EVALUATION'
        	and ao.pk3_value = l_organization_id
        	and ao.pk1_value = l_control_id
        	and ao.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = ao.object_opinion_type_id
                                     and aov2.pk3_value = ao.pk3_value
                                     and aov2.pk1_value = ao.pk1_value);

	l_count NUMBER;
	m_opinion_log_id NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_Ctrl_Ass_Sum_M';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

	SAVEPOINT Populate_Fin_Ctrl_Ass_Sum_M;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;


	SELECT COUNT(1) INTO l_count FROM AMW_CONTROL_ASSOCIATIONS
	WHERE OBJECT_TYPE = 'RISK_FINCERT'
	and PK1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR control_rec IN c_fincontrols LOOP
	exit when c_fincontrols%notfound;

	m_opinion_log_id := null;
	OPEN last_evaluation(control_rec.pk1, control_rec.control_id);
	FETCH last_evaluation INTO m_opinion_log_id;
	CLOSE last_evaluation;

		INSERT INTO AMW_CONTROL_ASSOCIATIONS(
 			       CONTROL_ASSOCIATION_ID,
			       CONTROL_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       PK5,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       CONTROL_REV_ID)
			 VALUES (AMW_CONTROL_ASSOCIATIONS_S.nextval,
			         control_rec.control_id,
			         p_certification_id,
			         control_rec.PK1,
			         control_rec.PK2,
			         control_rec.PK3,
			         m_opinion_log_id,
			         FND_GLOBAL.USER_ID,
			       	 SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'RISK_FINCERT',
			         control_rec.ASSOCIATION_CREATION_DATE,
	 		         control_rec.APPROVAL_DATE,
			         control_rec.DELETION_DATE,
			        control_rec.DELETION_APPROVAL_DATE,
			        control_rec.CONTROL_REV_ID);

		END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;
	END IF;
	   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_fincontrols%ISOPEN THEN
      	close c_fincontrols;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_fincontrols%ISOPEN THEN
      	close c_fincontrols;
      END IF;
       ROLLBACK TO Populate_Fin_Ctrl_Ass_Sum_M;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_Ctrl_Ass_Sum_M;


-------------populate control association which related to financial certification ----
PROCEDURE Populate_Fin_AP_Ass_Sum_M(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS

CURSOR c_finap IS
SELECT
	ap.AUDIT_PROCEDURE_ID,
	ap.PK1,
	ap.PK2,
	ap.PK3,
	ap.ASSOCIATION_CREATION_DATE,
	ap.APPROVAL_DATE,
	ap.DELETION_DATE,
	ap.DELETION_APPROVAL_DATE,
	apb.AUDIT_PROCEDURE_REV_ID
FROM
	AMW_AP_ASSOCIATIONS ap,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_AUDIT_PROCEDURES_B apb
WHERE
	ap.object_type='CTRL_ORG'
	and apb.CURR_APPROVED_FLAG = 'Y'
	and ap.audit_procedure_id = apb.audit_procedure_id
	and controls.PK1 = p_certification_id
	and controls.PK2 = ap.PK1
	and controls.PK2 = ap.PK2
	and controls.control_id = ap.PK3
	and controls.object_type = 'RISK_FINCERT'
UNION ALL
SELECT
	ap.AUDIT_PROCEDURE_ID,
	ap.PK1,
	ap.PK2,
	ap.PK3,
	ap.ASSOCIATION_CREATION_DATE,
	ap.APPROVAL_DATE,
	ap.DELETION_DATE,
	ap.DELETION_APPROVAL_DATE,
	apb.AUDIT_PROCEDURE_REV_ID
FROM
	AMW_AP_ASSOCIATIONS ap,
	AMW_CONTROL_ASSOCIATIONS controls,
	AMW_AUDIT_PROCEDURES_B apb
WHERE
	ap.object_type='ENTITY_CTRL_AP'
	and apb.CURR_APPROVED_FLAG = 'Y'
	and ap.audit_procedure_id = apb.audit_procedure_id
	and controls.PK1 = p_certification_id
	and controls.PK2 = ap.PK1
	--and controls.PK3 = ap.PK2
	and controls.PK3 is null
	and controls.control_id = ap.PK3
	and controls.object_type = 'RISK_FINCERT';

--need check opinion framework doc
--in ap association table, if type = 'CTRL_FINCERT', pk1=certification_id, pk2=organization_id, pk3=process_id, pk4=control_id, pk5=opinion_id
CURSOR last_evaluation(l_audit_procedure_id number, l_organization_id number, l_control_id number)  IS
SELECT 	distinct aov.opinion_id
FROM 	AMW_OPINION_M_V aov
WHERE
                aov.object_name = 'AMW_ORG_AP_CONTROL'
        AND 	aov.opinion_type_code = 'EVALUATION'
        AND 	aov.opinion_component_code = 'OVERALL'
        AND 	aov.pk3_value = l_organization_id
        AND 	aov.pk4_value = l_audit_procedure_id
        AND	aov.pk1_value = l_control_id
        AND 	aov.authored_date = (select max(aov2.authored_date)
                       	             from AMW_OPINIONS aov2
                               	     where aov2.object_opinion_type_id = aov.object_opinion_type_id
                                     and aov2.pk3_value = aov.pk3_value
                                     and aov2.pk1_value = aov.pk1_value
                                     and aov2.pk4_value = aov.pk4_value);


	l_count NUMBER;
	m_opinion_id NUMBER;


l_api_name           CONSTANT VARCHAR2(30) := 'Populate_Fin_AP_Ass_Sum_M';
l_api_version_number CONSTANT NUMBER  := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

   SAVEPOINT Populate_Fin_AP_Ass_Sum_M;

 -- Standard call to check for call compatibility.

        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;



	SELECT COUNT(1) INTO l_count FROM AMW_AP_ASSOCIATIONS
	WHERE OBJECT_TYPE = 'CTRL_FINCERT'
	and PK1 = p_certification_id;

	IF (l_count = 0) THEN
	FOR ap_rec IN c_finap LOOP
	exit when c_finap%notfound;

	m_opinion_id := null;
	OPEN last_evaluation(ap_rec.audit_procedure_id, ap_rec.pk1, ap_rec.pk3);
	FETCH last_evaluation INTO m_opinion_id;
	CLOSE last_evaluation;


		INSERT INTO AMW_AP_ASSOCIATIONS(
			       AP_ASSOCIATION_ID,
 			       AUDIT_PROCEDURE_ID,
			       PK1,
			       PK2,
			       PK3,
			       PK4,
			       PK5,
			       CREATED_BY,
			       CREATION_DATE,
			       LAST_UPDATE_DATE,
			       LAST_UPDATED_BY,
			       LAST_UPDATE_LOGIN,
			       OBJECT_VERSION_NUMBER,
			       OBJECT_TYPE,
			       ASSOCIATION_CREATION_DATE,
			       APPROVAL_DATE,
			       DELETION_DATE,
			       DELETION_APPROVAL_DATE,
			       AUDIT_PROCEDURE_REV_ID)
			 VALUES (AMW_AP_ASSOCIATIONS_S.nextval,
			         ap_rec.audit_procedure_id,
			         p_certification_id,
			         ap_rec.PK1,
			         ap_rec.PK2,
			         ap_rec.PK3,
			         m_opinion_id,
			         FND_GLOBAL.USER_ID,
			         SYSDATE,
			         SYSDATE,
			         FND_GLOBAL.USER_ID,
			         FND_GLOBAL.USER_ID,
			         1,
			         'CTRL_FINCERT',
			         ap_rec.ASSOCIATION_CREATION_DATE,
	 		         ap_rec.APPROVAL_DATE,
			         ap_rec.DELETION_DATE,
			         ap_rec.DELETION_APPROVAL_DATE,
			         ap_rec.AUDIT_PROCEDURE_REV_ID);


		END LOOP;
if(p_commit <> FND_API.g_false)
then commit;
end if;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     IF c_finap%ISOPEN THEN
      	close c_finap;
      END IF;
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
      IF c_finap%ISOPEN THEN
      	close c_finap;
      END IF;
      ROLLBACK TO Populate_Fin_AP_Ass_Sum_M;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END Populate_Fin_AP_Ass_Sum_M;

FUNCTION  Get_Proc_Verified_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_PROC_VERIFIED Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

        l_stmt := 'SELECT COUNT(1) FROM
 	(Select distinct  fin.PROCESS_ID, fin.ORGANIZATION_ID
	FROM
	AMW_OPINION_M_V aov,
	amw_fin_cert_scope fin
	WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
        and aov.object_name = ''AMW_ORG_PROCESS''
        and aov.opinion_component_code = ''OVERALL''
        and aov.PK3_VALUE = fin.ORGANIZATION_ID
        and aov.PK1_VALUE = fin.PROCESS_ID
        and fin.process_id is not null
        and fin.FIN_CERTIFICATION_ID = :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;

ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_PROC_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

        RETURN X_PROC_VERIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_Proc_Verified_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_Proc_Verified_M');
    fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_Proc_Verified_M;

FUNCTION Get_ORG_EVALUATED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_ORG_EVALUATED  Number;

BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from (
select distinct fin.ORGANIZATION_ID
FROM
AMW_OPINION_M_V aov,
amw_fin_cert_scope fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORGANIZATION''
and aov.opinion_component_code = ''OVERALL''
and aov.pk1_value = fin.organization_id
and fin.FIN_CERTIFICATION_ID= :1 ';


IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;
        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_EVALUATED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_ORG_EVALUATED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
END IF;

                RETURN X_ORG_EVALUATED;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_ORG_EVALUATED_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
    fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_ORG_EVALUATED_M');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_ORG_EVALUATED_M;

FUNCTION Get_RISKS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_RISKS_VERIFIED  Number;
BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

/*********** replace with the following query that uses opinion_log_id directly
l_stmt := 'select count(1)  from (
select distinct  fin.risk_id ,fin.organization_id, fin.Process_ID
FROM
	AMW_OPINION_M_V aov,
	amw_fin_item_acc_risk fin
WHERE
aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS_RISK''
and aov.opinion_component_code = ''OVERALL''
and aov.pk1_value = fin.risk_id
and aov.pk3_value = fin.organization_id
and aov.pk4_value = fin.process_ID
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.FIN_CERTIFICATION_ID= :1 ';
************/

l_stmt := 'select count(1)  from (
select distinct  fin.risk_id ,fin.organization_id, fin.Process_ID
FROM
	amw_opinion_m_v aov,
	amw_opinions_log aol,
	amw_fin_item_acc_risk fin
WHERE
aov.OPINION_TYPE_CODE = ''EVALUATION''
and aov.object_name = ''AMW_ORG_PROCESS_RISK''
and aov.opinion_component_code = ''OVERALL''
and aol.opinion_log_id = fin.opinion_log_id
and aol.opinion_id = aov.opinion_id
and aol.opinion_set_id = aov.opinion_set_id
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.FIN_CERTIFICATION_ID= :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_RISKS_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;


        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_RISKS_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;

        END IF;
                RETURN X_RISKS_VERIFIED;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_RISKS_VERIFIED_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_RISKS_VERIFIED_M');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;

END Get_RISKS_VERIFIED_M;

FUNCTION Get_CONTROLS_VERIFIED_M
(
P_CERTIFICATION_ID in number,
P_STATEMENT_GROUP_ID in number,
P_FINANCIAL_STATEMENT_ID in number,
P_FINANCIAL_ITEM_ID in number,
P_ACCOUNT_GROUP_ID in number,
P_ACCOUNT_ID in number,
P_OBJECT_TYPE in varchar2) RETURN NUMBER

IS
	l_stmt VARCHAR2(2000);
	l_stmt1 VARCHAR2(100);
	l_stmt2 VARCHAR2(100);
	l_sql_stmt VARCHAR2(2000);

	X_CONTROLS_VERIFIED  Number;


BEGIN

l_stmt1 := ' AND FIN.STATEMENT_GROUP_ID = :2 AND FIN.FINANCIAL_STATEMENT_ID = :3 AND FIN.FINANCIAL_ITEM_ID = :4)';
l_stmt2 := ' AND FIN.NATURAL_ACCOUNT_ID = :2)';

l_stmt := 'select count(1) from(
select distinct  fin.control_id, fin.organization_id
FROM
amw_opinion_m_v aov,
amw_opinions_log aol,
amw_fin_item_acc_ctrl fin
WHERE aov.OPINION_TYPE_CODE = ''EVALUATION''
and  aov.object_name = ''AMW_ORG_CONTROL''
and aov.opinion_component_code = ''OVERALL''
and aol.opinion_log_id = fin.OPINION_LOG_ID
and aol.opinion_id = aov.opinion_id
and aol.opinion_set_id = aov.opinion_set_id
and fin.object_type = ''' || P_OBJECT_TYPE || '''' || '
and fin.fin_certification_id = :1 ';

IF P_OBJECT_TYPE = 'FINANCIAL ITEM' THEN
        l_sql_stmt := l_stmt || l_stmt1;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_CONTROLS_VERIFIED USING P_CERTIFICATION_ID, P_STATEMENT_GROUP_ID, P_FINANCIAL_STATEMENT_ID, P_FINANCIAL_ITEM_ID ;
        --RETURN X_CONTROLS_VERIFIED;

        ELSIF P_OBJECT_TYPE = 'ACCOUNT' THEN
        l_sql_stmt := l_stmt || l_stmt2;

        EXECUTE IMMEDIATE l_sql_stmt INTO X_CONTROLS_VERIFIED USING P_CERTIFICATION_ID, P_ACCOUNT_ID ;
        --RETURN X_CONTROLS_VERIFIED;
        END IF;
        RETURN X_CONTROLS_VERIFIED;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    /*** Record doesn't exist ***/
    fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.Get_CONTROLS_VERIFIED_M');
    RETURN 0;
  WHEN OTHERS THEN
    /*** Raise any other error ***/
fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.Get_CONTROLS_VERIFIED_M');
fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
    RAISE;


END Get_CONTROLS_VERIFIED_M;

PROCEDURE INSERT_FIN_RISK(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
)IS
L_COUNT NUMBER;

l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_FIN_RISK';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN
SAVEPOINT INSERT_FIN_RISK;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO L_COUNT FROM AMW_FIN_ITEM_ACC_RISK
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

IF (L_COUNT = 0 OR L_COUNT IS NULL) THEN

insert into amw_fin_item_acc_risk(
OBJECT_TYPE,
FIN_CERTIFICATION_ID,
STATEMENT_GROUP_ID,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID,
NATURAL_ACCOUNT_ID,
ORGANIZATION_ID,
PROCESS_ID,
RISK_ID,
RISK_REV_ID,
OPINION_LOG_ID,
CREATED_BY ,
CREATION_DATE  ,
LAST_UPDATED_BY  ,
LAST_UPDATE_DATE  ,
LAST_UPDATE_LOGIN  ,
SECURITY_GROUP_ID ,
OBJECT_VERSION_NUMBER )
SELECT distinct 'ACCOUNT' OBJECT_TYPE , fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
account_group_id, natural_account_id, organization_id, process_id, risk_id, risk_rev_id, pk4 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_risk_associations risk
where risk.pk1 = scp.fin_certification_id
and  risk.object_type = 'PROCESS_FINCERT'
and scp.natural_account_id is not null
and scp.organization_id = risk.pk2
and scp.process_id = risk.pk3
and risk.pk1 = p_certification_id
union all
select distinct 'FINANCIAL ITEM' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, financial_item_id,
null account_group_id, null natural_account_id, organization_id, process_id, risk_id, risk_rev_id, pk4 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_risk_associations risk
where risk.pk1 = scp.fin_certification_id
and risk.object_type = 'PROCESS_FINCERT'
and scp.organization_id = risk.pk2
and scp.process_id = risk.pk3
and risk.pk1 = p_certification_id
union all
select distinct  'FINANCIAL STATEMENT' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
null account_group_id, null natural_account_id, organization_id, process_id, risk_id, risk_rev_id, pk4 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_risk_associations risk
where risk.pk1 = scp.fin_certification_id
and risk.object_type = 'PROCESS_FINCERT'
and scp.organization_id = risk.pk2
and scp.process_id = risk.pk3
and risk.pk1 = p_certification_id;

if(p_commit <> FND_API.g_false)
then commit;
end if;

END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO INSERT_FIN_RISK;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
                RETURN;

END INSERT_FIN_RISK;

PROCEDURE INSERT_FIN_CTRL(
p_api_version_number        IN   NUMBER   := 1.0,
p_init_msg_list             IN   VARCHAR2 := FND_API.g_false,
p_commit                    IN   VARCHAR2 := FND_API.g_false,
p_validation_level          IN   NUMBER   := fnd_api.g_valid_level_full,
p_certification_id  IN       NUMBER,
x_return_status             OUT  nocopy VARCHAR2,
x_msg_count                 OUT  nocopy NUMBER,
x_msg_data                  OUT  nocopy VARCHAR2
) IS
L_COUNT NUMBER;
l_error_message VARCHAR2(4000);
l_api_name           CONSTANT VARCHAR2(30) := 'INSERT_FIN_CTRL';
l_api_version_number CONSTANT NUMBER       := 1.0;

l_return_status VARCHAR2(32767);
l_msg_count NUMBER;
l_msg_data VARCHAR2(32767);

BEGIN

SAVEPOINT INSERT_FIN_CTRL;

 -- Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                             p_api_version_number,
                                             l_api_name,
                                             G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list )
        THEN
                FND_MSG_PUB.initialize;
        END IF;

        -- Initialize API return status to SUCCESS
        x_return_status := FND_API.G_RET_STS_SUCCESS;

SELECT COUNT(1) INTO L_COUNT FROM AMW_FIN_ITEM_ACC_CTRL
WHERE FIN_CERTIFICATION_ID = P_CERTIFICATION_ID;

IF (L_COUNT = 0 OR L_COUNT IS NULL) THEN

insert into amw_fin_item_acc_ctrl
(
OBJECT_TYPE,
FIN_CERTIFICATION_ID,
STATEMENT_GROUP_ID ,
FINANCIAL_STATEMENT_ID,
FINANCIAL_ITEM_ID,
ACCOUNT_GROUP_ID ,
NATURAL_ACCOUNT_ID ,
ORGANIZATION_ID ,
CONTROL_ID ,
CONTROL_REV_ID ,
OPINION_LOG_ID,
CREATED_BY ,
CREATION_DATE  ,
LAST_UPDATED_BY  ,
LAST_UPDATE_DATE  ,
LAST_UPDATE_LOGIN  ,
SECURITY_GROUP_ID ,
OBJECT_VERSION_NUMBER )
SELECT distinct 'ACCOUNT' OBJECT_TYPE , fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
account_group_id, natural_account_id, organization_id, control_id, control_rev_id, pk5 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_control_associations ctrl
where ctrl.pk1 = scp.fin_certification_id
and ctrl.object_type = 'RISK_FINCERT'
and scp.natural_account_id is not null
and scp.organization_id = ctrl.pk2
and scp.process_id = ctrl.pk3
and ctrl.pk1 = p_certification_id
union all
select distinct 'FINANCIAL ITEM' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, financial_item_id,
null account_group_id, null natural_account_id, organization_id, control_id,  control_rev_id, pk5 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_control_associations ctrl
where ctrl.pk1 = scp.fin_certification_id
and ctrl.object_type = 'RISK_FINCERT'
and scp.organization_id = ctrl.pk2
and scp.process_id = ctrl.pk3
and ctrl.pk1 = p_certification_id
union all
select distinct  'FINANCIAL STATEMENT' OBJECT_TYPE, fin_certification_id, statement_group_id, financial_statement_id, null financial_item_id,
null account_group_id, null natural_account_id, organization_id, control_id, control_rev_id, pk5 opinion_log_id, 1, sysdate, 1, sysdate, 1, null, 1
from amw_fin_cert_scope scp,
     amw_control_associations ctrl
where ctrl.pk1 = scp.fin_certification_id
and ctrl.object_type = 'RISK_FINCERT'
and scp.organization_id = ctrl.pk2
and scp.process_id = ctrl.pk3
and ctrl.pk1 = p_certification_id;

if(p_commit <> FND_API.g_false)
then commit;
end if;

END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     fnd_file.put_line(fnd_file.LOG, 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name );
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data := 'NO DATA FOUND IN ' || G_PKG_NAME || '.' || l_api_name ;
      WHEN OTHERS THEN
       ROLLBACK TO INSERT_FIN_CTRL;
      fnd_file.put_line(fnd_file.LOG, 'Unexpected error in ' || G_PKG_NAME || '.' || l_api_name );
      fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR (SQLERRM, 1, 2000);
                FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
                FND_MSG_PUB.Count_And_Get(
                p_encoded =>  FND_API.G_FALSE,
                p_count   =>  x_msg_count,
                p_data    =>  x_msg_data);
 		RETURN;
END INSERT_FIN_CTRL;

 END AMW_FINSTMT_CERT_MIG_PKG;

/
