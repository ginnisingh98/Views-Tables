--------------------------------------------------------
--  DDL for Package Body IGW_PROP_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_CHECKLIST_PVT" as
 /* $Header: igwvpchb.pls 115.7 2002/11/14 18:52:13 vmedikon ship $*/


Procedure update_prop_checklist (
 p_init_msg_list                  IN 		VARCHAR2   := FND_API.G_FALSE,
 p_commit                         IN 		VARCHAR2   := FND_API.G_FALSE,
 p_validate_only                  IN 		VARCHAR2   := FND_API.G_FALSE,
 x_rowid 		          IN 		VARCHAR2,
 p_proposal_id                    IN	 	NUMBER,
 p_document_type_code             IN		VARCHAR2,
 p_checklist_order	          IN         	NUMBER,
 p_complete 		          IN         	VARCHAR2,
 p_not_applicable	          IN		VARCHAR2,
 p_record_version_number          IN 		NUMBER,
 x_return_status                  OUT NOCOPY 		VARCHAR2,
 x_msg_count                      OUT NOCOPY 		NUMBER,
 x_msg_data                       OUT NOCOPY 		VARCHAR2)  is


  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;
  n   			     NUMBER;

BEGIN
-- create savepoint if p_commit is true
   IF p_commit = FND_API.G_TRUE THEN
        SAVEPOINT update_prop_checklist;
   END IF;

-- initialize message list if p_init_msg_list is true
   if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
        fnd_msg_pub.initialize;
   end if;

-- initialize return_status to success
    x_return_status := fnd_api.g_ret_sts_success;

-- and also check locking.
 	CHECK_LOCK
		(x_rowid			=>	x_rowid
		,p_record_version_number	=>	p_record_version_number
		,x_return_status    		=>	x_return_status);

check_errors;

------------------------------------- value_id conversion ---------------------------------

-------------------------------------------- validations -----------------------------------------------------
-- check to make sure that the user has not checked both complete and not applicable
 if ((p_complete = 'Y') and (p_not_applicable = 'Y')) then
      FND_MESSAGE.SET_NAME('IGW','IGW_SS_CANNOT_CHECK_BOTH');
      FND_MSG_PUB.Add;
  end if;

  if ((p_document_type_code = 'BUDGETS') and (p_complete = 'Y')) then
      select count(*)
      into n
      from igw_budgets
      where proposal_id = p_proposal_id
      and final_version_flag = 'Y';

      if (n = 0) then
          FND_MESSAGE.SET_NAME('IGW','IGW_NO_BUDGET_FINAL_VERSION');
          FND_MSG_PUB.Add;
      end if;
  end if;

  check_errors;

            if (NOT FND_API.TO_BOOLEAN (p_validate_only)) then
                        igw_prop_checklist_tbh.update_row (
                                    	 x_rowid			 =>	x_rowid
              				,P_PROPOSAL_ID       		 =>	P_PROPOSAL_ID
 					,P_DOCUMENT_TYPE_CODE        	 =>	P_DOCUMENT_TYPE_CODE
 					,P_CHECKLIST_ORDER		 =>	P_CHECKLIST_ORDER
 					,P_COMPLETE    		 	 =>	P_COMPLETE
 					,P_NOT_APPLICABLE		 =>	P_NOT_APPLICABLE
              				,p_mode 			 =>	'R'
              				,p_record_version_number	 =>	p_record_version_number
              				,x_return_status		 =>	x_return_status);

	    end if;

check_errors;

-- standard check of p_commit
  if fnd_api.to_boolean(p_commit) then
      commit work;
  end if;


-- standard call to get message count and if count is 1, get message info
fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			     p_data	=>	x_msg_data);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_prop_checklist;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO update_prop_checklist;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_CHECKLIST_PVT',
                            p_procedure_name    =>    'UPDATE_PROP_CHECKLIST',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END  update_prop_checklist;

------------------------------------------------------------------------------------------
PROCEDURE CHECK_LOCK
		(x_rowid			IN 	VARCHAR2
		,p_record_version_number	IN	NUMBER
		,x_return_status          	OUT NOCOPY 	VARCHAR2) is

 l_proposal_id		number;
 BEGIN
   select proposal_id
   into l_proposal_id
   from igw_prop_checklist
   where rowid = x_rowid
   and record_version_number = p_record_version_number;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;

    WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_PROP_CHECKLIST_PVT',
                            	  p_procedure_name => 'CHECK_LOCK',
                            	  p_error_text     => SUBSTRB(SQLERRM,1,240));
          raise fnd_api.g_exc_unexpected_error;

END CHECK_LOCK;

-------------------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS is
 l_msg_count 	NUMBER;
 BEGIN
       	l_msg_count := fnd_msg_pub.count_msg;
        IF (l_msg_count > 0) THEN
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

 END CHECK_ERRORS;
 -----------------------------------------------------------------------------------------------------
 PROCEDURE POPULATE_CHECKLIST (
 		P_PROPOSAL_ID  			 IN		NUMBER,
 		x_return_status                  OUT NOCOPY 		VARCHAR2) is

 BEGIN
 	insert into igw_prop_checklist (
 		proposal_id,
 		document_type_code,
 		checklist_order,
 		complete,
 		not_applicable,
 		record_version_number,
 		last_update_date,
 		last_updated_by,
 		creation_date,
 		created_by,
 		last_update_login)
 	select p_proposal_id,
 	       lookup_code,
 	       decode(lookup_code, 'BASIC_INFORMATION', 1,
 	       			   'PROGRAM', 2,
 	       			   'PERSONNEL', 3,
 	       			   'PERSON_ASSURANCES', 4,
 	       			   'PERSON_BIOSKETCH', 5,
 	       			   'PERSON_OTHER_SUPPORT', 6,
 	       			   'SPECIAL_REVIEWS', 7,
 	       			   'PARAGRAPHS', 8,
 	       			   'RESEARCH_SUBJECTS', 9,
 	       			   'ASSURANCES', 10,
 	       			   'KEYWORDS', 11,
 	       			   'BUDGETS', 12,
 	       			   'NARRATIVES', 13, 14),
 	       'N',
 	       'N',
 	       1,
 	       null,
 	       null,
 	       sysdate,
 	       fnd_global.user_id,
 	       fnd_global.user_id
 	from fnd_lookups
 	where lookup_type = 'IGW_SS_PROP_DOC_TYPES';

 EXCEPTION
 WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_PROP_CHECKLIST_PVT',
                            p_procedure_name    =>    'POPULATE_CHECKLIST',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

 END POPULATE_CHECKLIST;
 -----------------------------------------------------------------------------------------------------------
 FUNCTION GET_PERSON_NAME_FROM_USER_ID (P_USER_ID    IN      NUMBER) RETURN  VARCHAR2 IS

 l_full_name   varchar2(1000);
 BEGIN
 select ppx.last_name || ',' || ppx.first_name
 into l_full_name
 from per_all_people_f ppx,
      fnd_user fu
 where fu.user_id = p_user_id
 and   fu.employee_id = ppx.person_id
 and   rownum < 2;

 return l_full_name;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_full_name := null;
       return l_full_name;
 END GET_PERSON_NAME_FROM_USER_ID;

END IGW_PROP_CHECKLIST_PVT;

/
