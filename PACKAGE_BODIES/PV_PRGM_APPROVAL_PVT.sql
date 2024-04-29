--------------------------------------------------------
--  DDL for Package Body PV_PRGM_APPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_APPROVAL_PVT" AS
/* $Header: pvxvpapb.pls 120.13 2006/08/10 18:16:03 speddu ship $*/



   --  Start of Comments
   --
   -- NAME
   --   pv_prgm_approval_pvt
   --
   -- PURPOSE
   --   This package contains all approval related procedures for Partner Programs
      --
   -- HISTORY
   --   05/23/2002  pukken          CREATION
   --   06/23/2002  pukken    added start workflow for child programs
   --   12/04/2002  SVEERAVE  added Process_errored_requests that will
   --                               be called from conc. request.
   --   02/25/2003  pukken    added Code to fix bug 2821087 regarding showing partner name
   --   02/25/2003  pukken    Fixed Bug 2821062
   --   05/20/2003  pukken    Fixed Bug 2999737 and Bug 2999721
   --   10/24/2003  pukken    Made calls to the new workflow api and also made changes to create_history call
   --   11/26/2003  pukken    Added validation to call welcome notification in default memb api only
   --                         if atleast one primary user exist
   --   02/26/2004  pukken    Modified procedure getstart_end_date to fix bug 3454657
   --   10/05/2005  pukken    Took out the reference to contract_id in checkcontract_status()
   --   12/19/2005  ktsao     Fixed for bug 4868295 - performance issue(SQL ID 15006635). Added "and apdt.approval_type='CONCEPT'" to improve performance.

   -- NOTE        :
   -- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
   --                          All rights reserved.

   g_pkg_name    CONSTANT VARCHAR2 (30) := 'pv_prgm_approval_pvt';
   g_file_name   CONSTANT VARCHAR2 (15) := 'pvxvpapb.pls';
   g_program_mode   CONSTANT VARCHAR2 (15) := 'WORKFLOW';
   g_isApproverInList boolean:=false;
   g_approver_response VARCHAR2(30):=NULL;

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Write_Log(p_which number, p_mssg  varchar2) IS
BEGIN
    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);
END Write_Log;

PROCEDURE CheckApprInTempApprTable
(   p_enrl_request_id              IN NUMBER
    , p_approver_id                IN NUMBER
    , x_entity_approver_id         OUT NOCOPY NUMBER
    , x_objNo                      OUT NOCOPY NUMBER
    , x_approval_status_code       OUT NOCOPY VARCHAR2
) IS
   CURSOR temp_appr_csr(enrl_id NUMBER ,apprid NUMBER )IS
   SELECT entity_approver_id, object_version_number,approval_status_code
   FROM   pv_ge_temp_approvers
   WHERE  APPR_FOR_ENTITY_ID =enrl_id
   AND    ARC_APPR_FOR_ENTITY_CODE='ENRQ'
   AND    APPROVER_ID=DECODE( APPROVER_TYPE_CODE,'PERSON',apprid,'USER',FND_GLOBAL.USER_ID,null );


BEGIN
   OPEN temp_appr_csr( p_enrl_request_id,p_approver_id );
      FETCH temp_appr_csr INTO x_entity_approver_id, x_objNo,x_approval_status_code ;
   CLOSE temp_appr_csr;
EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CheckApprInTempApprTable;

  --------------------------------------------------------------------------
   -- FUNCTION
   --   isPartnerType
   --
   -- PURPOSE
   --   Checks whether the partner is of partner type passed in
   -- IN
   --   enrollment_request_id NUMBER
   --   partner_type         VARCHAR
   -- OUT
   --   ame_util.booleanAttributeTrue if exists
   --   ame_util.booleanAttributeFalse if not exists
   -- USED BY
   --   Program Approval API, and Activate API.
   -- HISTORY
   --   12/13/2002                CREATION
   --------------------------------------------------------------------------

FUNCTION isPartnerType(p_partner_id IN NUMBER,p_partner_type IN VARCHAR2)
RETURN VARCHAR2 IS
  CURSOR partnerType_cur(p_part_id number,p_ptr_type varchar2) IS
    SELECT  'Y'
    FROM   DUAL
    WHERE  EXISTS (SELECT 1
    FROM   pv_enty_attr_values
    WHERE  entity = 'PARTNER'
    AND    attribute_id = 3
    AND    latest_flag = 'Y'
    AND    entity_id = p_part_id
    AND    attr_value= p_ptr_type
    AND    attr_value_extn = 'Y'
    );



    l_exists_flag VARCHAR2(1) := 'N';

BEGIN
  OPEN partnerType_cur(p_partner_id,p_partner_type);
     FETCH partnerType_cur INTO l_exists_flag;
  CLOSE partnerType_cur;
  IF l_exists_flag='Y' THEN
     RETURN ame_util.booleanAttributeTrue;
  ELSE
     RETURN ame_util.booleanAttributeFalse;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ame_util.booleanAttributeFalse;
  WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END isPartnerType;


FUNCTION getUserId(p_user_name IN VARCHAR2)
RETURN NUMBER IS
   CURSOR user_csr(uname VARCHAR2) IS
   SELECT user_id
   FROM   fnd_user
   WHERE  user_name=uname;
   l_user_id NUMBER;
BEGIN
   OPEN user_csr(p_user_name);
      FETCH user_csr INTO l_user_id;
   CLOSE user_csr;
   RETURN l_user_id;
EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END getUserId;
--------------------------------------------------------------------------
   -- FUNCTION
   --   isnumber
   --
   -- PURPOSE
   --   Simple function to check whether value entered is a number
   --   returns null if value entered is not a number
   -- IN
   --   l_value   VARCHAR2

   -- OUT
   --    l_number NUMBER or null if value entered is not a number
   -- HISTORY
   --   18-APR-2003 pukken         CREATION
--------------------------------------------------------------------------

FUNCTION isnumber (
   l_value   VARCHAR2
)
   RETURN NUMBER IS
   l_number   NUMBER;
BEGIN
   BEGIN
      l_number := l_value;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   RETURN l_number;
END isnumber;


FUNCTION getenddate(p_program_id in number,p_previous_enr_end_date in DATE) return DATE is
    l_program_end_date DATE;
    l_membership_end_date DATE;
    l_start_date DATE;
    cursor rec_cur(p_prgm_id number,start_date date) is
          select program_end_date,
                 decode(  membership_period_unit
                         ,'DAY',start_date+membership_valid_period
                         ,'MONTH',add_months(start_date,membership_valid_period)
                         ,'YEAR',add_months(start_date,12*membership_valid_period)
                         ,null
                       )  membership_end_date
          from pv_partner_program_b
          where program_id=p_prgm_id;


 BEGIN


     OPEN rec_cur(p_program_id,p_previous_enr_end_date);
        FETCH rec_cur into l_program_end_date,l_membership_end_date;
        if rec_cur%found THEN
           if l_membership_end_date is NULL then--this should never happen.. clarify the business logic.
              l_membership_end_date:=l_program_end_date;
           end if;
        end if;
     CLOSE rec_cur;
     return  l_membership_end_date;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END getenddate;


FUNCTION getGlobalenddate(p_partner_id in number,p_dependent_program_id in number,p_enrollment_type in VARCHAR,p_start_date in DATE) return DATE is
   CURSOR enrtype_new_csr(g_ptr_id NUMBER,dependent_id NUMBER) IS
   SELECT min(original_end_date)
   FROM  pv_pg_memberships
   WHERE partner_id=g_ptr_id
   AND   membership_status_code='ACTIVE'
   AND   program_id IN
         (
            SELECT   distinct(change_to_program_id)
            FROM     pv_pg_enrl_change_rules
            START WITH change_from_program_id=dependent_id
            AND      change_direction_code='UPGRADE'
            AND      ACTIVE_FLAG='Y'
            AND      nvl(EFFECTIVE_TO_DATE,sysdate+1)>=sysdate
            CONNECT BY change_from_program_id=PRIOR change_to_program_id
            AND      change_direction_code='UPGRADE'
            AND      ACTIVE_FLAG='Y'
            AND      nvl(EFFECTIVE_TO_DATE,sysdate+1)>=sysdate
            UNION
            SELECT dependent_id
            FROM
            DUAL
         );

   CURSOR enrtype_renew_csr(g_ptr_id NUMBER,dependent_id NUMBER) IS
   SELECT min(original_end_date)
   FROM  pv_pg_memberships
   WHERE partner_id=g_ptr_id
   AND   membership_status_code='FUTURE'
   AND   program_id IN
         (
            SELECT   distinct(change_to_program_id)
            FROM     pv_pg_enrl_change_rules
            START WITH change_from_program_id=dependent_id
            AND      change_direction_code='UPGRADE'
            AND      ACTIVE_FLAG='Y'
            AND      nvl(EFFECTIVE_TO_DATE,sysdate+1)>=sysdate
            CONNECT BY change_from_program_id=PRIOR change_to_program_id
            AND      change_direction_code='UPGRADE'
            AND      ACTIVE_FLAG='Y'
            AND      nvl(EFFECTIVE_TO_DATE,sysdate+1)>=sysdate
            UNION
            SELECT dependent_id
            FROM
            DUAL
         );

   CURSOR get_global_csr( sub_ptr_id NUMBER) IS
   SELECT glob.partner_id
   FROM   pv_partner_profiles glob
          , hz_relationships  rel
          , pv_partner_profiles sub
   WHERE  glob.partner_party_id= rel.object_id
   AND    rel.subject_id=sub.partner_party_id
   AND    sub.partner_id=sub_ptr_id
   AND    relationship_type='PARTNER_HIERARCHY'
   AND    rel.status='A'
   AND    NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND    NVL(rel.end_date, SYSDATE) >= SYSDATE ;

   l_global_ptr_id NUMBER;
   l_end_date DATE:=null;

   BEGIN
      --get the global partner_id
      OPEN get_global_csr(p_partner_id);
         FETCH get_global_csr INTO l_global_ptr_id;
      CLOSE get_global_csr;
      /**if enrollment type is new,upgrade or if its renewal after membership expiry,
         get the min(original_end_date)of global membership in the dependent program or any other program
         in the upgrade path
         if its early renewal,check whether global has a future membership in any program in the
         upgrade path
      */
      IF l_global_ptr_id IS NOT NULL THEN
         IF ( p_start_date>sysdate AND p_enrollment_type ='RENEW' ) THEN
         	--its early renewal
            OPEN enrtype_renew_csr(l_global_ptr_id,p_dependent_program_id );
               FETCH enrtype_renew_csr INTO l_end_date;
            CLOSE enrtype_renew_csr;
         END IF;

         IF l_end_date IS NULL THEN
            OPEN enrtype_new_csr(l_global_ptr_id,p_dependent_program_id );
               FETCH enrtype_new_csr INTO l_end_date;
            CLOSE enrtype_new_csr;
         END IF;
      END IF;

      IF l_end_date IS NULL THEN
        l_end_date:=sysdate;
      END IF;
      RETURN l_end_date;

   EXCEPTION
      WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END getGlobalenddate;

PROCEDURE getstart_and_end_date( p_api_version_number         IN   NUMBER
                                ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
                                ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
                                ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
                                ,enrl_request_id   IN NUMBER
                                ,x_start_date      OUT NOCOPY DATE
                                ,x_end_date        OUT NOCOPY DATE
                                ,x_return_status   OUT NOCOPY  VARCHAR2
                                ,x_msg_count       OUT NOCOPY  NUMBER
                                ,x_msg_data        OUT NOCOPY  VARCHAR2
                               ) IS
l_prev_end_date DATE :=null;
l_prev_membership_id NUMBER;
l_tentative_start_date DATE:=null;
l_tentative_end_date DATE:=null;
l_request_status_code VARCHAR2(30);
p_enrollment_type  VARCHAR2(30);
p_program_id       NUMBER;
l_memb_start_date  DATE:=null;
l_memb_end_date    DATE:=null;
l_api_name                  CONSTANT  VARCHAR2(30) := 'getstart_and_end_date';
l_partner_id NUMBER;
l_dependent_program_id NUMBER;

l_memb_type    VARCHAR2(30);
CURSOR  prev_memb_date_cur(p_enrl_req_id number) IS
   SELECT nvl(actual_end_date,original_end_date) prev_end_date
   FROM  pv_pg_memberships memb,pv_pg_enrq_init_sources eni
   WHERE eni.prev_membership_id=memb.membership_id
   AND   eni.enrl_request_id=p_enrl_req_id;

CURSOR enr_requests_dtl_cur (p_enrl_req_id number) IS
   SELECT enrollment_type_code,program_id,tentative_start_date,tentative_end_date,request_status_code,partner_id,dependent_program_id
   FROM   pv_pg_enrl_requests
   WHERE enrl_request_id=p_enrl_req_id;

CURSOR memb_type_cur(p_ptnr_id IN NUMBER)  IS
   SELECT attr_value
   FROM pv_enty_attr_values
   WHERE  entity_id=p_ptnr_id
   AND    attribute_id=6
   AND    latest_flag='Y'
   AND    entity='PARTNER';

CURSOR appr_enrl_req_csr( p_enrl_req_id number ) IS
   SELECT start_date start_date
          , nvl(actual_end_date,original_end_date) end_date
   FROM  pv_pg_memberships memb
   WHERE enrl_request_id=p_enrl_req_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN enr_requests_dtl_cur(enrl_request_id);
      FETCH enr_requests_dtl_cur
         INTO  p_enrollment_type
               , p_program_id
               , x_start_date
               , x_end_date
               , l_request_status_code
               , l_partner_id
               , l_dependent_program_id ;
      CLOSE enr_requests_dtl_cur ;

   --if membership is aleady created,get the start and end date from memberships table
   OPEN appr_enrl_req_csr( enrl_request_id );
      FETCH appr_enrl_req_csr INTO x_start_date,x_end_date;
   CLOSE appr_enrl_req_csr;

   IF(  x_start_date is  NULL OR x_end_date is  NULL )  THEN

      IF p_enrollment_type in ('NEW','UPGRADE','DOWNGRADE') THEN
         x_start_date:=sysdate;
      ELSIF p_enrollment_type='RENEW' THEN
         OPEN prev_memb_date_cur(enrl_request_id);
            FETCH prev_memb_date_cur INTO l_prev_end_date;
         CLOSE prev_memb_date_cur;
         IF l_prev_end_date<sysdate THEN
            x_start_date:=sysdate;
         ELSE
            x_start_date:=l_prev_end_date;
         END IF;
      END IF;
      IF x_end_date IS NULL  THEN
         x_end_date  :=getenddate(p_program_id,x_start_date);
      END IF;
      -- check whether the partner is Subsidiary and also check the dependent program id.
      -- if dependent program id has a value it means that the partner enrolled is because of global's
      -- membership in this program or any other global membership in the upgrade hierarchy.
      -- we should not check the global membership required flag for the enrolling program, instead the dependent program id.
      OPEN memb_type_cur(l_partner_id);
         FETCH memb_type_cur INTO l_memb_type;
      CLOSE memb_type_cur;
      IF l_memb_type='SUBSIDIARY' THEN
         IF l_dependent_program_id IS NOT NULL THEN
            --get the membership end_date from global partner
            x_end_date  :=getGlobalenddate(l_partner_id,l_dependent_program_id,p_enrollment_type, x_start_date);
            --this should never happen.
            IF x_start_date>x_end_date THEN
               x_start_date:=x_end_date;
            END IF;
         END IF;
      END IF;
   END IF; --end of if else, if enrollment request is not approved.

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END getstart_and_end_date;

FUNCTION iscontract_exists(p_program_id IN number) RETURN boolean IS
    l_temp varchar2(1);
    isrecord boolean:=false ;
    CURSOR rec_cur(p_prgm_id number) IS
         SELECT 'X'
         FROM dual
         WHERE EXISTS
         ( SELECT 'X'
           FROM pv_program_contracts
           WHERE program_id = p_prgm_id
         );

 BEGIN
     OPEN rec_cur(p_program_id);
        FETCH rec_cur INTO  l_temp;
        IF rec_cur%FOUND THEN
           isrecord:=true;
        END IF;
     CLOSE rec_cur;
     RETURN  isrecord;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END iscontract_exists;

FUNCTION ispayment_exists(p_program_id IN number) RETURN boolean IS
    no_fee varchar2(1);
    CURSOR rec_cur(p_prgm_id number) IS
         SELECT no_fee_flag
         FROM pv_partner_program_b
         WHERE program_id = p_prgm_id;


 BEGIN
     OPEN rec_cur(p_program_id);
        FETCH rec_cur into  no_fee;
     CLOSE rec_cur;
     IF  no_fee IS NOT NULL AND no_fee='N' THEN
          RETURN TRUE;
     ELSE
         RETURN FALSE;
     END IF;


EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END ispayment_exists;


FUNCTION getCustomSetupID(p_program_id IN number) RETURN number IS
    l_customSetupID number:=null;
    l_any_contract  boolean;
    l_any_payment   boolean;

 BEGIN
    l_any_contract:=isContract_Exists(p_program_id);
    l_any_payment:=isPayment_Exists(p_program_id);
    IF (l_any_contract) THEN

          --with contract, with payment
          IF (l_any_payment) THEN
              l_customSetupID := 7004;
          ELSE --with contract, no payment
              l_customSetupID := 7006;
          END IF;

     ELSE
         --no contract, with payment
          IF  (l_any_payment) THEN
              l_customSetupID := 7005;
          ELSE  --no contract, no payment
               l_customSetupID := 7007;
          END IF;

     END IF;

     return l_customSetupID;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END getCustomSetupID;



FUNCTION check_pending_default(p_enrollment_req_id in number) return boolean is
    l_temp varchar2(1);
    isrecord boolean:=false ;
    cursor rec_cur(p_enrl_req_id number) is
           select 'X' from dual where exists (
               select entity_approver_id from pv_ge_temp_approvers
               where appr_for_entity_id=p_enrl_req_id
               and approval_status_code='PENDING_DEFAULT');

 BEGIN

     OPEN rec_cur(p_enrollment_req_id);
        FETCH rec_cur into  l_temp;
        if rec_cur%found THEN

           isrecord:=true;
        end if;
      CLOSE rec_cur;
      return  isrecord;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_pending_default;


FUNCTION check_record_exists(p_enrollment_req_id in number) return boolean is
    l_temp varchar2(1);
    isrecord boolean:=false ;
    cursor rec_cur(p_enrl_req_id number) is
          select 'X' from dual where exists
          ( select entity_approver_id from pv_ge_temp_approvers where appr_for_entity_id=p_enrl_req_id);

 BEGIN
     OPEN rec_cur(p_enrollment_req_id);
        FETCH rec_cur into  l_temp;
        if rec_cur%found THEN
           isrecord:=true;
        end if;
      CLOSE rec_cur;
      return  isrecord;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_record_exists;


FUNCTION isApproverInList (p_enrollment_req_id in number,p_approver_id in number) return boolean is

    l_isApproverInList  boolean:=false;
    x_nextApproversOut ame_util.approversTable2;
    xitemIndexesOut ame_util.idList;
    xitemClassesOut ame_util.stringList;
    xitemIdsOut ame_util.stringList;
    xitemSourcesOut ame_util.longStringList;
    x_approvalProcessCompleteYNOut VARCHAR2(100);
	currApprRec ame_util.approverRecord2;

 BEGIN
      -- get all the approver list and loop till you find the matching
      -- and set the flag to true if you find any.
      ----DBMS_OUTPUT.PUT_LINE('before  get all approvers');

      /** Following is required as we expect AME to return their new statuses. Bug # 4879218  **/
      ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;

      ame_api2.getAllApprovers1
      (   applicationIdIn =>691,
          transactionTypeIn => 'ENRQ',
          transactionIdIn => p_enrollment_req_id,
          approvalProcessCompleteYNOut =>  x_approvalProcessCompleteYNOut,
          approversOut => x_nextApproversOut,
          itemIndexesOut => xitemIndexesOut,
          itemClassesOut => xitemClassesOut,
          itemIdsOut => xitemIdsOut,
          itemSourcesOut => xitemSourcesOut

      );
      FOR i IN 1..x_nextApproversOut.COUNT LOOP
         currApprRec := x_nextApproversOut(i);
         IF p_approver_id=currApprRec.orig_system_id THEN
            ----DBMS_OUTPUT.PUT_LINE('inside if');
            l_isApproverInList:=true;
            exit;
         END IF;
      END LOOP;

      return l_isApproverInList;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isApproverInList;




FUNCTION check_pending_approval (p_enrollment_req_id in number) return boolean is
    l_temp varchar2(1);
    isPendingApproval boolean:=false;
    cursor rec_cur(p_enrl_req_id number) is
          select 'X' from dual where exists (
               select entity_approver_id from pv_ge_temp_approvers
               where appr_for_entity_id=p_enrl_req_id
               and approval_status_code in ('PENDING_APPROVAL'));
 BEGIN
     OPEN rec_cur(p_enrollment_req_id);
        FETCH rec_cur into  l_temp;
        if rec_cur%found THEN
           isPendingApproval:=true;
        end if;
      CLOSE rec_cur;
      return isPendingApproval;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END check_pending_approval;



FUNCTION checkcontract_status (p_enrollment_req_id in number) return boolean is
    l_temp varchar2(30);
    isApprovable boolean:=false;
    CURSOR rec_cur(p_enrl_req_id number) IS
       SELECT contract_status_code
       FROM   pv_pg_enrl_requests
   	 WHERE  enrl_request_id=p_enrl_req_id;

 BEGIN
     OPEN rec_cur(p_enrollment_req_id);
        FETCH rec_cur into l_temp;
        IF (l_temp='SIGNED' or l_temp='NOT_SIGNED') THEN
           isApprovable:=true;
        END IF;
      CLOSE rec_cur;
      return isApprovable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END checkcontract_status;



FUNCTION checklist_status(p_enrollment_req_id in number) return boolean is
    l_temp varchar2(1);

    isChecked boolean:=false;
    CURSOR rec_cur(p_enrl_req_id number) IS
         SELECT prgm.allow_enrl_wout_chklst_flag
	        FROM   pv_pg_enrl_requests enrq, pv_partner_program_b prgm
         WHERE  enrq.program_id=prgm.program_id
         AND    enrl_request_id=p_enrl_req_id;

   CURSOR checklistresponse_cur(p_enrl_req_id number) IS
       SELECT 'X' from dual
       where  EXISTS
              (  SELECT checklist_item_id
	                FROM   pv_ge_chklst_responses
		               WHERE  response_for_entity_id = p_enrl_req_id
		               AND    RESPONSE_FLAG='N'
	              );


 BEGIN
     OPEN rec_cur(p_enrollment_req_id);
        FETCH rec_cur into  l_temp;
     CLOSE rec_cur;
     IF l_temp='N' THEN
        OPEN checklistresponse_cur(p_enrollment_req_id);
           FETCH checklistresponse_cur into l_temp;
           IF checklistresponse_cur%found THEN
              isChecked:=false;
           ELSE
              isChecked:=true;
           END IF;
        CLOSE checklistresponse_cur;
     ELSE
        isChecked:=true;
     END IF;

     return isChecked;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END checklist_status;

-- Fixed for bug 4868295
FUNCTION isApproverExists (p_program_type_id in number) return boolean is
    l_temp varchar2(1);
    isavailable boolean:=false ;
    cursor app_cur(p_prgm_type_id varchar) is
          select 'X' from dual where exists
           (select approver_id from ams_approvers appr,ams_approval_details apdt
                where  nvl(appr.start_date_active,sysdate)<=sysdate
                and nvl(appr.end_date_active,sysdate)>=sysdate
                and appr.ams_approval_detail_id =apdt.approval_detail_id
                and apdt.approval_object_type=p_prgm_type_id
                and apdt.approval_object='PRGT'
		and apdt.approval_type='CONCEPT'
	        and nvl(apdt.active_flag,'Y') = 'Y'
		and nvl(appr.active_flag,'Y')='Y'
           );
 BEGIN
     OPEN app_cur(to_char(p_program_type_id));
        FETCH app_cur into l_temp;
        if app_cur%found THEN
           isavailable:=true;
        end if;
      CLOSE app_cur;
      return isavailable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isApproverExists;


FUNCTION isParentApproved (p_parent_program_id in number) return boolean is

    l_parent_program_status varchar2(30);
    isApproved boolean:=false ;
    cursor parentprogramstatus_cur(p_parent_prgm_id number) is
          select  PROGRAM_STATUS_CODE from pv_partner_program_b where program_id=p_parent_prgm_id and ENABLED_FLAG='Y';
 BEGIN
     OPEN parentprogramstatus_cur(p_parent_program_id);
        FETCH parentprogramstatus_cur into l_parent_program_status;
        if parentprogramstatus_cur%found THEN
           if  l_parent_program_status in ('APPROVED','ACTIVE') THEN
               isApproved:=true;
           end if;
        end if;
     CLOSE parentprogramstatus_cur;
     return isApproved;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isParentApproved;
--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_FYI
--
-- PURPOSE
--   Generate the FYI Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle Partner Programs Generic Apporval
-- HISTORY
--   05/22/2002        pukken        CREATION

   PROCEDURE notify_requestor_fyi (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           VARCHAR2 (61)
                                     :=    g_pkg_name
                                        || 'Notify_Requestor_FYI';
      l_program_id            NUMBER;

      l_program_name          VARCHAR2 (200);
      l_hyphen_pos1        NUMBER;
      l_fyi_notification   VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (3000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_end_date         DATE;
      l_owner_name             VARCHAR2 (300);
      l_level_meaning         VARCHAR2 (150);
      l_program_description       VARCHAR2 (240);
      l_company_name          VARCHAR2 (360);
      l_requester          VARCHAR2 (30);
      l_string2            VARCHAR2 (2500);


      CURSOR c_program_rec (p_program_id IN NUMBER) IS
         SELECT PROGRAM_NAME,MEANING,PROGRAM_START_DATE,PROGRAM_END_DATE,SOURCE_NAME,PROGRAM_DESCRIPTION,SOURCE_BUSINESS_GRP_NAME
                FROM PV_PARTNER_PROGRAM_VL ,JTF_RS_RESOURCE_EXTNS,FND_LOOKUP_VALUES_VL
                WHERE PROGRAM_ID =p_program_id
                AND PROGRAM_OWNER_RESOURCE_ID =RESOURCE_ID
	        AND   LOOKUP_CODE=PROGRAM_LEVEL_CODE
                AND    LOOKUP_TYPE='PV_PROGRAM_LEVEL';

   BEGIN
      ams_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_program_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );
      OPEN c_program_rec (l_program_id);
      FETCH c_program_rec INTO l_program_name,l_level_meaning,l_start_date,l_end_date,l_owner_name,l_program_description, l_company_name;
      CLOSE c_program_rec;

      fnd_message.set_name ('PV', 'PV_WF_NTF_REQUESTER_FYI_SUB');
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);

      l_string      := SUBSTR(fnd_message.get,1,1000);

      fnd_message.set_name ('PV', 'PV_WF_NTF_PROGRAM_REQ_INFO');
      fnd_message.set_token ('COMPANY_NAME', l_company_name, FALSE);
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
      fnd_message.set_token ('PROGRAM_LEVEL', l_level_meaning, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date, FALSE);
      fnd_message.set_token ('OWNER', l_owner_name, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_program_description, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);


      l_fyi_notification         :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_fyi_notification;
      document_type              := 'text/plain';
      RETURN;

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'Notify_requestor_FYI',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_requestor_fyi;


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of Approval
--
-- PURPOSE
--   Generate the Approval Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        pukken        CREATION
----------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_approval (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           VARCHAR2 (61)
                                     :=    g_pkg_name
                                        || 'Notify_Requestor_of_approval' ;
      l_program_id            NUMBER;

      l_program_name          VARCHAR2 (200);
      l_hyphen_pos1        NUMBER;
      l_appr_notification   VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (3000);
      l_approver_notes     VARCHAR2 (3000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_end_date         DATE;
      l_owner_name             VARCHAR2 (300);
      l_level_meaning         VARCHAR2 (150);
      l_program_description       VARCHAR2 (240);
      l_company_name          VARCHAR2 (360);
      l_requester          VARCHAR2 (30);
      l_string2            VARCHAR2 (2500);


      CURSOR c_program_rec (p_program_id IN NUMBER) IS
        SELECT PROGRAM_NAME,MEANING,PROGRAM_START_DATE,PROGRAM_END_DATE,SOURCE_NAME,PROGRAM_DESCRIPTION,SOURCE_BUSINESS_GRP_NAME
                FROM PV_PARTNER_PROGRAM_VL ,JTF_RS_RESOURCE_EXTNS,FND_LOOKUP_VALUES_VL
                WHERE PROGRAM_ID =p_program_id
                AND PROGRAM_OWNER_RESOURCE_ID =RESOURCE_ID
	        AND   LOOKUP_CODE=PROGRAM_LEVEL_CODE
                AND    LOOKUP_TYPE='PV_PROGRAM_LEVEL';

   BEGIN
      ams_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_program_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );

      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );

       l_approver_notes                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'APPROVAL_NOTE'
            );

      OPEN c_program_rec (l_program_id);
      FETCH c_program_rec INTO l_program_name,l_level_meaning,l_start_date,l_end_date,l_owner_name,l_program_description, l_company_name;
      CLOSE c_program_rec;

      fnd_message.set_name ('PV', 'PV_WF_NTF_REQUESTER_APP_SUB');
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);

      l_string      := SUBSTR(fnd_message.get,1,1000);

      fnd_message.set_name ('PV', 'PV_WF_NTF_PROGRAM_REQ_INFO_REQ');
      fnd_message.set_token ('COMPANY_NAME', l_company_name, FALSE);
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
      fnd_message.set_token ('PROGRAM_LEVEL', l_level_meaning, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date, FALSE);
      fnd_message.set_token ('OWNER', l_owner_name, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_program_description, FALSE);
      fnd_message.set_token ('APPROVER', l_approver , FALSE);
      fnd_message.set_token ('APPR_NOTES', l_approver_notes , FALSE);


      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);

      --  IF (display_type = 'text/plain') THEN
      l_appr_notification        :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_appr_notification;
      document_type              := 'text/plain';
      RETURN;
    EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'Notify_Requestor_of_approval',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_requestor_of_approval;


--------------------------------------------------------------------------
-- PROCEDURE
--   Notify_requestor_of rejection
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        pukken        CREATION
-------------------------------------------------------------------------------

   PROCEDURE notify_requestor_of_rejection (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name           VARCHAR2 (100)
                            :=    g_pkg_name
                               || 'Notify_Requestor_of_rejection';
      l_program_id            NUMBER;

      l_program_name          VARCHAR2 (200);
      l_hyphen_pos1        NUMBER;
      l_rej_notification    VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_approver_notes     VARCHAR2 (3000);
      l_note               VARCHAR2 (3000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_end_date         DATE;
      l_owner_name             VARCHAR2 (300);
      l_level_meaning         VARCHAR2 (150);
      l_program_description       VARCHAR2 (240);
      l_company_name          VARCHAR2 (360);
      l_requester          VARCHAR2 (30);
      l_string2            VARCHAR2 (2500);


      CURSOR c_program_rec (p_program_id IN NUMBER) IS
        SELECT PROGRAM_NAME,MEANING,PROGRAM_START_DATE,PROGRAM_END_DATE,SOURCE_NAME,PROGRAM_DESCRIPTION,SOURCE_BUSINESS_GRP_NAME
                FROM PV_PARTNER_PROGRAM_VL ,JTF_RS_RESOURCE_EXTNS,FND_LOOKUP_VALUES_VL
                WHERE PROGRAM_ID =p_program_id
                AND PROGRAM_OWNER_RESOURCE_ID =RESOURCE_ID
	        AND   LOOKUP_CODE=PROGRAM_LEVEL_CODE
                AND    LOOKUP_TYPE='PV_PROGRAM_LEVEL';

   BEGIN
      ams_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_program_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );

      l_approver_notes                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'APPROVAL_NOTE'
            );

      OPEN c_program_rec (l_program_id);
      FETCH c_program_rec INTO l_program_name,l_level_meaning,l_start_date,l_end_date,l_owner_name,l_program_description, l_company_name;
      CLOSE c_program_rec;

      fnd_message.set_name ('PV', 'PV_WF_NTF_REQUESTER_REJ_SUB');
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);

      l_string      := SUBSTR(fnd_message.get,1,1000);

      fnd_message.set_name ('PV', 'PV_WF_NTF_PROGRAM_REQ_INFO_REJ');
      fnd_message.set_token ('COMPANY_NAME', l_company_name, FALSE);
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
      fnd_message.set_token ('PROGRAM_LEVEL', l_level_meaning, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date, FALSE);
      fnd_message.set_token ('OWNER', l_owner_name, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_program_description, FALSE);
      fnd_message.set_token ('APPROVER', l_approver , FALSE);
      fnd_message.set_token ('APPR_NOTES', l_approver_notes , FALSE);


      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);

      l_rej_notification         :=    SUBSTR(l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2,1,10000);
      document                   :=    document
                                    || l_rej_notification;
      document_type              := 'text/plain';
      RETURN;


   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'Notify_requestor_of_rejection',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_requestor_of_rejection;


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_approval_required
--
-- PURPOSE
--   Generate the Notify Approval Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        pukken        CREATION


   PROCEDURE notify_approval_required (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              VARCHAR2 (100)
                                 :=    g_pkg_name
                                    || 'Notify_approval_required';
      l_program_id            NUMBER;

      l_program_name          VARCHAR2 (200);
      l_hyphen_pos1        NUMBER;
      l_appreq_notification    VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (3000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_end_date         DATE;
      l_owner_name             VARCHAR2 (300);
      l_level_meaning         VARCHAR2 (150);
      l_program_description       VARCHAR2 (240);
      l_requester          VARCHAR2 (30);
      l_string2            VARCHAR2 (2500);
      l_company_name          VARCHAR2 (360);
      l_url1                 VARCHAR2 (360);
      l_url2                 VARCHAR2 (360);

      CURSOR c_program_rec (p_program_id IN NUMBER) IS
          SELECT PROGRAM_NAME,MEANING,PROGRAM_START_DATE,PROGRAM_END_DATE,SOURCE_NAME,PROGRAM_DESCRIPTION,SOURCE_BUSINESS_GRP_NAME
                FROM PV_PARTNER_PROGRAM_VL ,JTF_RS_RESOURCE_EXTNS,FND_LOOKUP_VALUES_VL
                WHERE PROGRAM_ID =p_program_id
                AND PROGRAM_OWNER_RESOURCE_ID =RESOURCE_ID
	        AND   LOOKUP_CODE=PROGRAM_LEVEL_CODE
                AND    LOOKUP_TYPE='PV_PROGRAM_LEVEL';

   BEGIN
      ams_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_program_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );
      l_url1  := FND_PROFILE.VALUE('PV_WORKFLOW_RESPOND_URL');
      l_url2  := FND_PROFILE.VALUE('PV_WORKFLOW_RESPOND_SELF_SERVICE_URL');

      OPEN c_program_rec (l_program_id);
      FETCH c_program_rec INTO l_program_name,l_level_meaning,l_start_date,l_end_date,l_owner_name,l_program_description, l_company_name;
      CLOSE c_program_rec;

      fnd_message.set_name ('PV', 'PV_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);

      l_string      := SUBSTR(fnd_message.get,1,1000);

      fnd_message.set_name ('PV', 'PV_WF_NTF_PROGRAM_REQ_INFO_AP1');
      fnd_message.set_token ('COMPANY_NAME', l_company_name, FALSE);
      fnd_message.set_token ('URL1', l_url1, FALSE);
      fnd_message.set_token ('URL2', l_url2, FALSE);
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
      fnd_message.set_token ('PROGRAM_LEVEL', l_level_meaning, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date, FALSE);
      fnd_message.set_token ('OWNER', l_owner_name, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_program_description, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);


      l_appreq_notification      :=    l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2;
      document                   :=    document
                                    || l_appreq_notification;
      document_type              := 'text/plain';
      RETURN;

    EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'notify_approval_required',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_approval_required;


--------------------------------------------------------------------------
-- PROCEDURE
--   notify_appr_req_reminder
--
-- PURPOSE
--   Generate the Rejection Document for display in messages, either
--   text or html
-- IN
--   document_id  - Item Key
--   display_type - either 'text/plain' or 'text/html'
--   document     - document buffer
--   document_type   - type of document buffer created, either 'text/plain'
--         or 'text/html'
-- OUT
-- USED BY
--                      - Oracle MArketing Generic Apporval
-- HISTORY
--   03/15/2001        pukken        CREATION

   PROCEDURE notify_appr_req_reminder (
      document_id     IN       VARCHAR2,
      display_type    IN       VARCHAR2,
      document        IN OUT NOCOPY   VARCHAR2,
      document_type   IN OUT NOCOPY   VARCHAR2
   ) IS
      l_api_name              VARCHAR2 (100)
                                 :=    g_pkg_name
                                    || 'notify_appr_req_reminder';
      l_program_id            NUMBER;

      l_program_name          VARCHAR2 (200);
      l_hyphen_pos1        NUMBER;
      l_apprem_notification  VARCHAR2 (10000);
      l_activity_type      VARCHAR2 (30);
      l_item_type          VARCHAR2 (100);
      l_item_key           VARCHAR2 (100);
      l_approval_type      VARCHAR2 (30);
      l_approver           VARCHAR2 (200);
      l_note               VARCHAR2 (3000);
      l_string             VARCHAR2 (1000);
      l_string1            VARCHAR2 (2500);
      l_start_date         DATE;
      l_end_date         DATE;
      l_owner_name             VARCHAR2 (300);
      l_level_meaning         VARCHAR2 (150);
      l_program_description       VARCHAR2 (240);
      l_requester          VARCHAR2 (30);
      l_string2            VARCHAR2 (2500);
      l_company_name          VARCHAR2 (360);
      l_url1                 VARCHAR2 (360);
      l_url2                 VARCHAR2 (360);

      CURSOR c_program_rec (p_program_id IN NUMBER) IS
          SELECT PROGRAM_NAME,MEANING,PROGRAM_START_DATE,PROGRAM_END_DATE,SOURCE_NAME,PROGRAM_DESCRIPTION,SOURCE_BUSINESS_GRP_NAME
                FROM PV_PARTNER_PROGRAM_VL ,JTF_RS_RESOURCE_EXTNS,FND_LOOKUP_VALUES_VL
                WHERE PROGRAM_ID =p_program_id
                AND PROGRAM_OWNER_RESOURCE_ID =RESOURCE_ID
	        AND   LOOKUP_CODE=PROGRAM_LEVEL_CODE
                AND    LOOKUP_TYPE='PV_PROGRAM_LEVEL';

   BEGIN
      ams_utility_pvt.debug_message (
            l_api_name
         || 'Entering'
         || 'document id '
         || document_id
      );
      document_type              := 'text/plain';
      -- parse document_id for the ':' dividing item type name from item key value
      -- document_id value will take the form <ITEMTYPE>:<ITEMKEY> starting with
      -- release 2.5 version of this demo
      l_hyphen_pos1              := INSTR (document_id, ':');
      l_item_type                :=
                                 SUBSTR (document_id, 1,   l_hyphen_pos1
                                                         - 1);
      l_item_key                 := SUBSTR (document_id,   l_hyphen_pos1
                                                         + 1);
      l_activity_type            :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_TYPE'
            );
      l_program_id                  :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_ACTIVITY_ID'
            );

      l_note                     :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_NOTES_FROM_REQUESTOR'
            );
      l_approver                 :=
            wf_engine.getitemattrtext (
               itemtype=> l_item_type,
               itemkey=> l_item_key,
               aname => 'AMS_APPROVER_DISPLAY_NAME'
            );
      l_url1  := FND_PROFILE.VALUE('PV_WORKFLOW_RESPOND_URL');
      l_url2  := FND_PROFILE.VALUE('PV_WORKFLOW_RESPOND_SELFSERVICE_URL');

      OPEN c_program_rec (l_program_id);
      FETCH c_program_rec INTO l_program_name,l_level_meaning,l_start_date,l_end_date,l_owner_name,l_program_description, l_company_name;
      CLOSE c_program_rec;

      fnd_message.set_name ('PV', 'PV_WF_NTF_APPROVER_OF_REQ_SUB');
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);

      l_string      := SUBSTR(fnd_message.get,1,1000);

      fnd_message.set_name ('PV', 'PV_WF_NTF_PROGRAM_REQ_INFO_RM1');
      fnd_message.set_token ('COMPANY_NAME', l_company_name, FALSE);
      fnd_message.set_token ('URL1', l_url1, FALSE);
      fnd_message.set_token ('URL2', l_url2, FALSE);
      fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
      fnd_message.set_token ('PROGRAM_LEVEL', l_level_meaning, FALSE);
      fnd_message.set_token ('START_DATE', l_start_date, FALSE);
      fnd_message.set_token ('END_DATE', l_end_date, FALSE);
      fnd_message.set_token ('OWNER', l_owner_name, FALSE);
      fnd_message.set_token ('DESCRIPTION', l_program_description, FALSE);
      l_string1 := SUBSTR(FND_MESSAGE.Get,1,2500);

      l_apprem_notification      :=    l_string
                                    || fnd_global.local_chr (10)
                                    || l_string1
                                    || fnd_global.local_chr (10)
                                    || l_string2;
      document                   :=    document
                                    || l_apprem_notification;
      document_type              := 'text/plain';
      RETURN;



   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context (
            'AMSGAPP',
            'notify_appr_req_reminder',
            l_item_type,
            l_item_key
         );
         RAISE;
   END notify_appr_req_reminder;


---------------------------------------------------------------------
-- PROCEDURE
--   set_parprgm_activity_details
--
--
-- PURPOSE
--   This Procedure will set all the item attribute details
--
--
-- IN
--
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
--
-- HISTORY
--   02/20/2001        pukken        CREATION
-- End of Comments
--------------------------------------------------------------------
   PROCEDURE set_parprgm_activity_details (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_activity_id          NUMBER;

      l_activity_type        VARCHAR2 (30)                  := 'PRGT';
      l_approval_type        VARCHAR2 (30)                  := 'CONCEPT';
      l_object_details       ams_gen_approval_pvt.objrectyp;
      l_approval_detail_id   NUMBER;
      l_approver_seq         NUMBER;
      l_return_status        VARCHAR2 (1);
      l_msg_count            NUMBER;
      l_msg_data             VARCHAR2 (4000);
      l_error_msg            VARCHAR2 (4000);
      l_orig_stat_id         NUMBER;
      x_resource_id          NUMBER;
      --l_full_name            VARCHAR2 (60);
      --l_fund_number          VARCHAR2 (30);
      --l_requested_amt        NUMBER;
      l_approver             VARCHAR2 (200);
      l_string               VARCHAR2 (3000);

      --the cursor below picks up the program type id based on the program id.
      CURSOR c_program_type_rec (p_program_id IN NUMBER) IS
         SELECT ppv.program_name,to_char(ppv.program_type_id) from pv_partner_program_vl ppv, pv_partner_program_type_vl ppt
         WHERE ppv.program_id=p_program_id
         AND   ppv.program_type_id=ppt.program_type_id;


   BEGIN
      fnd_msg_pub.initialize;
      l_activity_id              :=
            wf_engine.getitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_ACTIVITY_ID'
            );
      OPEN c_program_type_rec (l_activity_id);
      FETCH c_program_type_rec INTO l_object_details.name,
                            l_object_details.object_type;
      CLOSE c_program_type_rec;

      IF (funcmode = 'RUN') THEN
         ams_gen_approval_pvt.get_approval_details (
            p_activity_id=> l_activity_id,
            p_activity_type=> l_activity_type,
            p_approval_type=> l_approval_type,
            p_object_details=> l_object_details,
            x_approval_detail_id=> l_approval_detail_id,
            x_approver_seq=> l_approver_seq,
            x_return_status=> l_return_status
         );

         IF l_return_status = fnd_api.g_ret_sts_success THEN

            wf_engine.setitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVAL_DETAIL_ID',
               avalue=> l_approval_detail_id
            );
            wf_engine.setitemattrnumber (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'AMS_APPROVER_SEQ',
               avalue=> l_approver_seq
            );

            --- set all the subjects here
            fnd_message.set_name ('PV', 'PV_WF_NTF_REQUESTER_FYI_SUB');
            fnd_message.set_token (
               'PROGRAM_NAME',
               l_object_details.name,
               FALSE
            );


            l_string                   := fnd_message.get;
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'FYI_SUBJECT',
               avalue=> l_string
            );

            fnd_message.set_name ('PV', 'PV_WF_NTF_REQUESTER_APP_SUB');
            fnd_message.set_token ('PROGRAM_NAME', l_object_details.name, FALSE  );

            l_string                   := fnd_message.get;
            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'APRV_SUBJECT',
               avalue=> l_string
            );

            fnd_message.set_name ('PV', 'PV_WF_NTF_REQUESTER_REJ_SUB');
            fnd_message.set_token ('PROGRAM_NAME',l_object_details.name,FALSE );

            l_string                   := fnd_message.get;

            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'REJECT_SUBJECT',
               avalue=> l_string
            );
            fnd_message.set_name ('PV', 'PV_WF_NTF_APPROVER_OF_REQ_SUB');
            fnd_message.set_token (
               'PROGRAM_NAME',
               l_object_details.name,
               FALSE
            );

            l_string                   := fnd_message.get;

            wf_engine.setitemattrtext (
               itemtype=> itemtype,
               itemkey=> itemkey,
               aname => 'APP_SUBJECT',
               avalue=> l_string
            );

            resultout                  := 'COMPLETE:SUCCESS';
         ELSE
            fnd_msg_pub.count_and_get (
               p_encoded=> fnd_api.g_false,
               p_count=> l_msg_count,
               p_data=> l_msg_data
            );
            ams_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMS_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
            wf_core.context (
               'ams_gen_approval_pvt',
               'Set_Activity_Details',
               itemtype,
               itemkey,
               actid,
               l_error_msg
            );
            -- RAISE FND_API.G_EXC_ERROR;
            resultout                  := 'COMPLETE:ERROR';
         END IF;
      END IF;

      --
      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;
   --

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         wf_core.context (
            'AMS_FundApproval_pvt',
            'set_parprgm_activity_details',
            itemtype,
            itemkey,
            actid,
            funcmode,
            l_error_msg
         );
         RAISE;
      WHEN OTHERS THEN
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> l_msg_count,
            p_data=> l_msg_data
         );
         RAISE;
   END set_parprgm_activity_details;


---------------------------------------------------------------------
-- PROCEDURE
--  Update_ParProgram_Status
--
--
-- PURPOSE
--   This Procedure will update the status
--
--
-- IN
--
--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
--
-- HISTORY
--   02/20/2001        pukken        CREATION
-- End of Comments
-------------------------------------------------------------------


   PROCEDURE update_parprogram_status (
      itemtype    IN       VARCHAR2,
      itemkey     IN       VARCHAR2,
      actid       IN       NUMBER,
      funcmode    IN       VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   ) IS
      l_status_code             VARCHAR2 (15);
      l_child_prog_stat_code     VARCHAR2 (30);
      l_api_version    CONSTANT NUMBER                      := 1.0;
      l_return_status           VARCHAR2 (1)           := fnd_api.g_ret_sts_success;
      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (4000);
      l_api_name       CONSTANT VARCHAR2 (30)               := 'Update_ParProgram_Status';
      l_full_name      CONSTANT VARCHAR2 (60)               :=    g_pkg_name
                                                               || '.'
                                                               || l_api_name;
      l_program_rec             PV_PARTNER_PROGRAM_PVT.ptr_prgm_rec_type;
      l_next_status_id          NUMBER;
      l_approved_amount         NUMBER;
      l_update_status           VARCHAR2 (12);
      l_error_msg               VARCHAR2 (4000);
      l_object_version_number   NUMBER;

      l_program_id                 NUMBER;

      CURSOR citem_csr(prgm_id NUMBER) IS
      SELECT cont.object_version_number object_version_number , prog.citem_version_id citem_version_id
      FROM   ibc_citem_versions_b cont_ver, ibc_content_items cont,pv_partner_program_b prog
      WHERE  prog.program_id = prgm_id
      AND    prog.citem_version_id = cont_ver.citem_version_id
      AND    cont_ver.content_item_id = cont.content_item_id;

      l_citem_object_version_number  NUMBER;
      l_citem_version_id NUMBER;

     CURSOR c_get_partner_program(cv_program_id NUMBER) IS
      SELECT *
      FROM  PV_PARTNER_PROGRAM_B
      WHERE PROGRAM_PARENT_ID = cv_program_id
      AND ENABLED_FLAG='Y'
      AND SUBMIT_CHILD_NODES='Y'
      AND PROGRAM_STATUS_CODE='NEW';


     CURSOR c_get_status_code(cv_status_code VARCHAR2) IS
     SELECT user_status_id
          FROM AMS_USER_STATUSES_B
          where SYSTEM_STATUS_TYPE='PV_PROGRAM_STATUS'
          and SYSTEM_STATUS_CODE=cv_status_code;

     CURSOR c_get_objverno(cv_program_id NUMBER) IS
     	SELECT object_version_number
     	FROM   pv_partner_program_b
     	WHERE  program_id=cv_program_id;

     CURSOR c_get_status_child(cv_program_id NUMBER) IS
     	SELECT program_status_code,object_version_number
     	FROM   pv_partner_program_b
     	WHERE  program_id=cv_program_id;

     l_user_status_for_new                NUMBER;
     l_user_status_for_approved           NUMBER;
     l_user_status_for_rejected           NUMBER;
     l_user_status_for_pa   NUMBER;
     l_valid_approvers                    boolean :=false;
     l_check_flag                         boolean :=false;
   BEGIN
      IF funcmode = 'RUN' THEN
         l_update_status            :=
               wf_engine.getitemattrtext (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'UPDATE_GEN_STATUS'
               );


         IF l_update_status = 'APPROVED' THEN
            l_next_status_id           :=
                  wf_engine.getitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_NEW_STAT_ID'
                  );
            l_status_code:='APPROVED';

            ams_utility_pvt.debug_message (   l_full_name
                                           || l_update_status);
         ELSE
            l_next_status_id           :=
                  wf_engine.getitemattrnumber (
                     itemtype=> itemtype,
                     itemkey=> itemkey,
                     aname => 'AMS_REJECT_STAT_ID'
                  );
           l_status_code:='REJECTED';
         END IF;

          /**
          l_object_version_number    :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_OBJECT_VERSION_NUMBER'
               );

       */

         l_program_id                  :=
               wf_engine.getitemattrnumber (
                  itemtype=> itemtype,
                  itemkey=> itemkey,
                  aname => 'AMS_ACTIVITY_ID'
               );
         --   x_return_status := fnd_api.g_ret_sts_success;

         OPEN c_get_objverno(l_program_id);
           FETCH c_get_objverno INTO l_object_version_number;
         CLOSE c_get_objverno;

         l_program_rec.program_id         := l_program_id;
         l_program_rec.program_status_code     := l_status_code;
         l_program_rec.user_status_id:= l_next_status_id;
         l_program_rec.object_version_number :=   l_object_version_number;


         ams_utility_pvt.debug_message (
               l_full_name
            || l_status_code
         );



         PV_PARTNER_PROGRAM_PVT.Update_Partner_Program (
            p_api_version_number=> l_api_version,
            p_init_msg_list=> fnd_api.g_false,
            --p_commit                => FND_API.G_FALSE,
            --p_validation_level      => FND_API.g_valid_level_full,
            x_return_status=> l_return_status,
            x_msg_count=> l_msg_count,
            x_msg_data=> l_msg_data,
            p_ptr_prgm_rec=> l_program_rec
          );

        OPEN citem_csr(l_program_id);
          FETCH citem_csr INTO l_citem_object_version_number,l_citem_version_id;
        CLOSE citem_csr;

         IF l_citem_version_id is NOT NULL THEN
            IBC_CITEM_ADMIN_GRP.approve_item(
                     p_citem_ver_id           => l_citem_version_id
                    ,p_commit                 => FND_API.G_FALSE
                    ,p_init_msg_list          => FND_API.g_false
                    ,p_api_version_number     => IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
                    ,px_object_version_number => l_citem_object_version_number
                    ,x_return_status          => l_return_status
                    ,x_msg_count              => l_msg_count
                    ,x_msg_data               => l_msg_data
                );
         END IF;


         /** pick up all the child programs and check whether the parent is approved
         and check the value of submitchildnodes of each of these child programs
         if true, call startworkflow for these child programs in a loop
         */
          IF l_status_code='APPROVED' THEN
               OPEN c_get_status_code('NEW');
               FETCH c_get_status_code into l_user_status_for_new;
               IF ( c_get_status_code%NOTFOUND) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               CLOSE c_get_status_code;
               OPEN c_get_status_code('APPROVED');
               FETCH c_get_status_code into l_user_status_for_approved;
               IF ( c_get_status_code%NOTFOUND) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               CLOSE c_get_status_code;
               OPEN c_get_status_code('REJECTED');
               FETCH c_get_status_code into l_user_status_for_rejected;
               IF ( c_get_status_code%NOTFOUND) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               CLOSE c_get_status_code;

               OPEN c_get_status_code('PENDING_APPROVAL');
               FETCH c_get_status_code into l_user_status_for_pa;
               IF ( c_get_status_code%NOTFOUND) THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
               CLOSE c_get_status_code;

               for child_cur in c_get_partner_program(l_program_id) loop
                   IF l_check_flag=false THEN
                          l_valid_approvers:=isApproverExists(child_cur.PROGRAM_TYPE_ID);
                   END IF;
                   /** code needs to be written to sent another notification to the requester if
                    program type approver becomes invalid maybe sometime after the requester
                   submitted the entire node forapproval*/

                    IF l_valid_approvers=true THEN
                        ams_gen_approval_pvt.StartProcess(   p_activity_type =>'PRGT'
                                                             ,p_activity_id=>child_cur.program_id
                                                             ,p_approval_type=>'CONCEPT'
                                                             ,p_object_version_number=>child_cur.object_version_number
                                                             ,p_orig_stat_id=>l_user_status_for_new
                                                             ,p_new_stat_id=>l_user_status_for_approved
                                                             ,p_reject_stat_id=>l_user_status_for_rejected
                                                             ,p_requester_userid=>child_cur.program_owner_resource_id
                                                             ,p_notes_from_requester=>null
                                                             ,p_workflowprocess=>'AMSGAPP'
                                                             ,p_item_type=>'AMSGAPP'
                                                          );


                         OPEN c_get_status_child(child_cur.program_id);
                            FETCH c_get_status_child INTO l_child_prog_stat_code,l_object_version_number;
                         CLOSE c_get_status_child;
                         --the child program could automatically go to approved if owner and approver is same

                         IF l_child_prog_stat_code <>'APPROVED' THEN

                             update pv_partner_program_b  set PROGRAM_STATUS_CODE='PENDING_APPROVAL',
                                                          USER_STATUS_ID=l_user_status_for_pa,
                                                          object_version_number=l_object_version_number+1
                                                      where
                                                          program_id=child_cur.program_id;


                         END IF;
                    END IF;
                    l_check_flag :=true;
               end loop;

         END IF;
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            ams_gen_approval_pvt.handle_err (
               p_itemtype=> itemtype,
               p_itemkey=> itemkey,
               p_msg_count=> l_msg_count, -- Number of error Messages
               p_msg_data=> l_msg_data,
               p_attr_name=> 'AMS_ERROR_MSG',
               x_error_msg=> l_error_msg
            );
            resultout := 'COMPLETE:ERROR';
         ELSE
            resultout := 'COMPLETE:SUCCESS';
         END IF;
      END IF;

      -- CANCEL mode
      --
      IF (funcmode = 'CANCEL') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;

      --
      -- TIMEOUT mode
      --
      IF (funcmode = 'TIMEOUT') THEN
         resultout                  := 'COMPLETE:';
         RETURN;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false,
         p_count=> l_msg_count,
         p_data=> l_msg_data
      );
      ams_utility_pvt.debug_message (
            l_full_name
         || ': l_return_status'
         || l_return_status
      );
   EXCEPTION
      WHEN OTHERS THEN
         --      x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_encoded=> fnd_api.g_false,
            p_count=> l_msg_count,
            p_data=> l_msg_data
         );
         RAISE;
   END update_parprogram_status;



PROCEDURE check_approved ( itemtype  IN     VARCHAR2
                          ,itemkey   IN     VARCHAR2
                          ,actid     IN     NUMBER
                          ,funcmode  IN     VARCHAR2
                          ,resultout    OUT NOCOPY   VARCHAR2
                         ) IS


L_API_NAME     CONSTANT VARCHAR2(30) := 'CHECK_APPROVED';
l_object_id NUMBER;
l_object_type VARCHAR2(30);
l_approver_id NUMBER;
l_flag   VARCHAR2(1);

CURSOR  c_temp_appr_cur(p_obj_id IN NUMBER,p_appr_id IN NUMBER) IS
   SELECT 'X'
   FROM  pv_ge_temp_Approvers
   WHERE approval_status_code  IN ( 'APPROVED','REJECTED', 'PEER_RESPONDED','APPROVER_CHANGED')
   AND   entity_approver_id=p_obj_id
   AND   approver_id=p_appr_id
   AND   arc_appr_for_entity_code='ENRQ';
BEGIN

   l_object_id := WF_ENGINE.GetItemAttrNumber(
                                itemtype     =>    itemtype
                              , itemkey      =>    itemkey
                              , aname        =>    'OBJECT_ID'
                              );

   l_object_type := WF_ENGINE.GetItemAttrText (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'OBJECT_TYPE'
                              );

   l_approver_id := WF_ENGINE.GetItemAttrNumber (
                                itemtype   =>   itemtype
                              , itemkey    =>   itemkey
                              , aname      =>   'APPROVER_ID'
                              );


   AMS_Utility_PVT.debug_message (L_API_NAME || ' - FUNCMODE: ' || funcmode);
   --  RUN mode  - Normal Process Execution
   IF (funcmode = 'RUN') THEN

         OPEN c_temp_appr_cur(l_object_id,l_approver_id );
            FETCH c_temp_appr_cur INTO l_flag;
            IF c_temp_appr_cur%found THEN
              resultout  := 'COMPLETE:Y' ;
            ELSE
               resultout  := 'COMPLETE:N' ;
            END IF;
         CLOSE c_temp_appr_cur;
         RETURN;
   ELSIF (funcmode = 'CANCEL') THEN
      resultout  := 'COMPLETE:' ;
      RETURN;
   --  TIMEOUT mode  - Normal Process Execution
   ELSIF (funcmode = 'TIMEOUT') THEN
      resultout  := 'COMPLETE:' ;
      RETURN;
   --
   -- Other execution modes may be created in the future.  The following
   -- activity will indicate that it does not implement a mode
   -- by returning null
   --

   END IF;

   AMS_Utility_PVT.debug_message (L_API_NAME || ' - RESULT: ' || resultout);

 -- write to log
EXCEPTION
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      --write_to_enrollment_log
      wf_core.context(G_PKG_NAME,'check_approved', itemtype,itemkey,to_char(actid),funcmode);
      resultout := 'COMPLETE:' ;
      raise;

END check_approved;


PROCEDURE getAttributeValues(
     p_entity_approver_id   IN NUMBER
    ,x_partner_name         OUT NOCOPY VARCHAR2
    ,x_program_name         OUT NOCOPY VARCHAR2
    ,x_enrollment_type      OUT NOCOPY VARCHAR2
    ,x_return_status        OUT NOCOPY VARCHAR2
)
IS

/* Get the Enrollment Request details in cursor c_pg_enrl_requests */
CURSOR c_enr_cur (cv_enrl_id  IN NUMBER) IS
/**SELECT  partner.party_name
       ,ppvl.program_name
       ,fl.description enrollment_type
FROM    pv_partner_program_vl ppvl
       ,fnd_lookups  fl
       ,pv_pg_enrl_requests pper
       ,pv_partner_profiles ppp
       ,hz_parties PARTNER
WHERE  pper.partner_id = ppp.partner_id
AND    ppp.partner_id=PARTNER.party_id
AND    fl.lookup_type='PV_ENROLLMENT_REQUEST_TYPE'
AND    fl.lookup_code = pper.enrollment_type_code
AND    pper.program_id = ppvl.program_id
AND    pper.enrl_request_id =cv_enrl_request_id;
*/
SELECT  partner.party_name
       ,ppvl.program_name
       ,fl.description enrollment_type
FROM    pv_partner_program_vl ppvl
       ,fnd_lookups  fl
       ,pv_pg_enrl_requests pper
       ,pv_partner_profiles ppp
       ,hz_parties PARTNER

WHERE  pper.partner_id = ppp.partner_id
AND    ppp.partner_party_id=PARTNER.party_id
AND    fl.lookup_type='PV_ENROLLMENT_REQUEST_TYPE'
AND    fl.lookup_code = pper.enrollment_type_code
AND    pper.program_id = ppvl.program_id
AND    pper.enrl_request_id =cv_enrl_id;




BEGIN
    /* Initialize API return status to success */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_enr_cur( p_entity_approver_id );
    FETCH c_enr_cur
        INTO  x_partner_name
             ,x_program_name
             ,x_enrollment_type;
    CLOSE c_enr_cur;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END getAttributeValues;


PROCEDURE Initialize_Var
(  p_object_id           IN NUMBER
   , p_object_type       IN VARCHAR2
   , p_itemtype          IN VARCHAR2
   , p_itemkey           IN VARCHAR2
   , p_approver_id       IN NUMBER
   , p_role_name         IN VARCHAR2
   , p_display_name      IN VARCHAR2
)
IS
   l_return_status   VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);
   l_partner_name    VARCHAR2(360);
   l_program_name    VARCHAR2(60);
   l_enrollment_type VARCHAR2(30);
   l_country         VARCHAR2(100);

   l_role_name       VARCHAR2(100);
   l_display_role_name VARCHAR2(100);
   l_approver_id NUMBER;
   l_rem  NUMBER;
   l_string_sub     VARCHAR2(1000);
   l_string         VARCHAR2(3000);

BEGIN

   getAttributeValues
   (   p_entity_approver_id   =>p_object_id
       , x_partner_name       =>l_partner_name
       , x_program_name       =>l_program_name
       , x_enrollment_type    =>l_enrollment_type
       , x_return_status      =>l_return_status
   );

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   WF_ENGINE.SetItemAttrNumber
   (   itemtype      =>   p_itemtype
       , itemkey     =>   p_itemkey
       , aname       =>   'OBJECT_ID'
       , avalue      =>   p_object_id
   );

   WF_ENGINE.SetItemAttrText
   (  itemtype      =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'OBJECT_TYPE'
      , avalue      =>   p_object_type
   );

   fnd_message.set_name ('PV', 'PV_ENRQ_FYI_NOTIF_SUB');
   fnd_message.set_token ('PROGRAM_NAME', UPPER(l_program_name), FALSE);
   fnd_message.set_token ('PARTNER_NAME', UPPER(l_partner_name), FALSE);

   l_string_sub     := SUBSTR(fnd_message.get,1,1000);

   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'APPR_SUBJECT'
      , avalue      =>   l_string_sub
   );

   fnd_message.set_name ('PV', 'PV_ENRQ_FYI_NOTIF_BODY');
   fnd_message.set_token ('PARTNER_NAME', l_partner_name, FALSE);
   fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
   fnd_message.set_token ('ENROLLMENT_TYPE', l_enrollment_type, FALSE);
   l_string     := SUBSTR(fnd_message.get,1,3000);

   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'FYI_BODY'
      , avalue      =>   l_string
   );

   fnd_message.set_name ('PV', 'PV_ENRQ_FYI_REM_SUB');
   fnd_message.set_token ('PROGRAM_NAME', UPPER(l_program_name), FALSE);
   fnd_message.set_token ('PARTNER_NAME', UPPER(l_partner_name), FALSE);
   l_string_sub     := SUBSTR(fnd_message.get,1,1000);

   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'REMINDER_SUBJECT'
      , avalue      =>   l_string_sub
   );

   fnd_message.set_name ('PV', 'PV_ENRQ_FYI_REM_BODY');
   fnd_message.set_token ('PARTNER_NAME', l_partner_name, FALSE);
   fnd_message.set_token ('PROGRAM_NAME', l_program_name, FALSE);
   fnd_message.set_token ('ENROLLMENT_TYPE', l_enrollment_type, FALSE);
   l_string     := SUBSTR(fnd_message.get,1,3000);

   WF_ENGINE.SetItemAttrText(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'REMINDER_BODY'
      , avalue      =>   l_string
   );


   WF_ENGINE.SetItemAttrNumber(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'APPROVER_ID'
      , avalue      =>   p_approver_id
   );

  l_rem :=isnumber(FND_PROFILE.VALUE('PV_ENRQ_REM_DURATION'));

  IF l_rem IS NULL THEN
  	l_rem:=30;
  END IF;

  IF l_rem >180 THEN
     l_rem:=180;
  END IF;


  -- convert the days to minutes
  l_rem:=l_rem*24*60;

  WF_ENGINE.SetItemAttrNumber(
        itemtype    =>   p_itemtype
      , itemkey     =>   p_itemkey
      , aname       =>   'REMINDER_DURATION'
      , avalue      =>   l_rem
   );


   /*PV_PG_NOTIF_UTILITY_PVT.get_resource_role(
          p_resource_id         =>  p_resource_id
         ,x_role_name           =>  l_role_name
         ,x_role_display_name	=>  l_display_role_name
         ,x_return_status   	=>  l_return_status
   );
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
   END IF;
   */

   WF_ENGINE.SetItemAttrText (
          itemtype    =>   p_itemtype
         , itemkey     =>  p_itemkey
         , aname       =>  'OWNER_USERNAME'
         , avalue      =>  p_role_name  );


END Initialize_Var ;


PROCEDURE StartProcess
(   p_object_id            IN    NUMBER    -- enrl_request_id
    , p_object_type        IN    VARCHAR2  --'ENRQ'
    , processName          IN    VARCHAR2
    , itemtype             IN    VARCHAR2
    , p_entity_approver_id IN    VARCHAR2  --this is the primary key in temp approvers table
    , p_role_name          IN    VARCHAR2
    , p_display_name       IN    VARCHAR2
    , x_itemkey            OUT   NOCOPY   VARCHAR2
)
IS


   L_API_NAME     CONSTANT VARCHAR2(30) := 'STARTPROCESS';
   l_itemtype   VARCHAR2(30) := itemtype;
   itemkey      VARCHAR2(30) := p_object_id||p_object_type||p_entity_approver_id||TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
   itemuserkey  VARCHAR2(80) := p_object_id||'-'||p_object_type;
   l_return_status VARCHAR2(1);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(4000);

   l_approver_rec        Pv_Ge_Temp_Approvers_PVT.APPROVER_REC_TYPE;

   CURSOR approver_dtl_cur (p_entity_appr_id number) IS
   SELECT object_version_number,approver_id
   FROM   pv_ge_temp_approvers
   WHERE  entity_approver_id=p_entity_appr_id;

BEGIN
 -- clear the message buffer
 FND_MSG_PUB.initialize;
 --write to logs that workflow is getting initiated.
 WF_ENGINE.CreateProcess
 (   itemtype     =>   l_itemtype
     , itemkey    =>   itemkey
     , process    =>   processName  -- 'PV_APPROVER_NOTIFICATIONS'
 );
 --add debug messages.

 OPEN  approver_dtl_cur(p_entity_approver_id);
    FETCH  approver_dtl_cur into l_approver_rec.object_version_number ,l_approver_rec.approver_id;
 CLOSE approver_dtl_cur;
 l_approver_rec.entity_approver_id:=p_entity_approver_id;

 l_approver_rec.workflow_item_key:=itemkey;

 Initialize_Var
 (   p_object_id         => p_object_id
     , p_object_type     => p_object_type
     , p_itemtype        => l_itemtype
     , p_itemkey         => itemkey
     , p_approver_id     => l_approver_rec.approver_id
     , p_role_name       => p_role_name
     , p_display_name    => p_display_name
 );

 WF_ENGINE.StartProcess
 (   itemtype    => l_itemtype
     , itemkey      => itemkey
 );


 --write to the approver logs with the itemkey for tracking purposes.
 Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
 (   p_api_version_number      => 1.0
     , p_init_msg_list         => FND_API.g_false
     , p_commit                => FND_API.G_FALSE
     , p_validation_level      => FND_API.g_valid_level_full
     , x_return_status         => l_return_status
     , x_msg_count             => l_msg_count
     , x_msg_data              => l_msg_data
     , p_approver_rec          => l_approver_rec
  );

  IF l_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
  ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
  END IF;


EXCEPTION
   -- The line below records this function call in the error system
   -- in the case of an exception.
   WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

      --write_buffer_to_log (p_object_type, p_object_id);

      wf_core.context (G_PKG_NAME, 'StartProcess',p_object_id,itemuserkey);

      raise;

END StartProcess;

   --this procedure should be called only when u  create new membership record by passing
   -- a valid enrollment_request_id with the record
   PROCEDURE setmembershipdetails( pv_pg_memb_rec     IN OUT NOCOPY PV_Pg_Memberships_PVT.memb_rec_type
                                  ,x_return_status   OUT NOCOPY    VARCHAR2
                                  ,x_msg_count       OUT NOCOPY    NUMBER
                                  ,x_msg_data        OUT NOCOPY    VARCHAR2
                                 ) IS

   CURSOR enr_request_cur(p_enrl_req_id number) IS
   SELECT partner_id,program_id,enrollment_type_code,tentative_start_date,tentative_end_date
   FROM   pv_pg_enrl_requests
   WHERE  enrl_request_id=p_enrl_req_id;

   l_enrollment_type_code         varchar2(30);
   l_tentative_start_date        DATE:=null;
   l_tentative_end_date          DATE:=null;

   BEGIN
         ----DBMS_OUTPUT.PUT_LINE('inside  setmembership');
         OPEN enr_request_cur(pv_pg_memb_rec.enrl_request_id);
            FETCH enr_request_cur
            INTO  pv_pg_memb_rec.partner_id
                  ,pv_pg_memb_rec.program_id
                  ,l_enrollment_type_code
                  ,l_tentative_start_date
                  ,l_tentative_end_date;
         CLOSE enr_request_cur;
         getstart_and_end_date(
               p_api_version_number    => 1.0
              ,p_init_msg_list         => FND_API.g_false
              ,p_commit                => FND_API.G_FALSE
              ,p_validation_level      => FND_API.g_valid_level_full
              ,enrl_request_id         => pv_pg_memb_rec.enrl_request_id
              ,x_start_date            =>l_tentative_start_date
              ,x_end_date              =>l_tentative_end_date
              ,x_return_status         => x_return_status
              ,x_msg_count             => x_msg_count
              ,x_msg_data              => x_msg_data
             );
         pv_pg_memb_rec.start_date:=l_tentative_start_date;
         pv_pg_memb_rec.original_end_date:=l_tentative_end_date;
         IF l_enrollment_type_code in ('NEW','UPGRADE','DOWNGRADE') THEN
               pv_pg_memb_rec.membership_status_code:='ACTIVE';
         ELSIF l_enrollment_type_code='RENEW' THEN
              IF pv_pg_memb_rec.start_date>sysdate THEN
                 pv_pg_memb_rec.membership_status_code:='FUTURE';
              ELSE
                 pv_pg_memb_rec.membership_status_code:='ACTIVE';
              END IF;
         END IF;



   EXCEPTION
   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END setmembershipdetails;

   -- this  api is called when the enrollment request is finally approved or when its rejected by any approvers
   PROCEDURE process_response
   (   enrl_request_id      IN NUMBER
       , approvalStatus     IN VARCHAR2
       , x_return_status    OUT NOCOPY  VARCHAR2
       , x_msg_count        OUT NOCOPY  NUMBER
       , x_msg_data         OUT NOCOPY  VARCHAR2
   ) IS

   CURSOR approver_dtl_cur (p_enrl_req_id number) IS
   SELECT object_version_number,entity_approver_id,approver_id,approver_type_code
   FROM   pv_ge_temp_approvers
   WHERE  appr_for_entity_id=p_enrl_req_id;

   CURSOR enr_requests_dtl_cur (p_enrl_req_id number) IS
   SELECT enrq.object_version_number,enrollment_type_code,order_header_id,partner_id,program_name, enrq.program_id
   FROM   pv_pg_enrl_requests enrq
          , pv_partner_program_vl prgm
   WHERE enrq.enrl_request_id=p_enrl_req_id
   AND  enrq.program_id=prgm.program_id;

   CURSOR membership_dtl_cur(p_membership_id number) IS
   SELECT object_version_number
   FROM   pv_pg_memberships
   WHERE  membership_id=p_membership_id;

   CURSOR  prev_memb_id_cur(p_enrl_req_id number) IS
   SELECT  prev_membership_id
   FROM    pv_pg_enrq_init_sources
   WHERE   enrl_request_id=p_enrl_req_id;

   /**
   CURSOR  check_attr_exist(p_program_id NUMBER) IS
   SELECT 'X' from dual where exists( SELECT distinct(entity_attr_id)
   FROM    pv_ge_qsnr_elements_b
   WHERE   arc_used_by_entity_code='PRGM'
   AND     used_by_entity_id in
   (   SELECT      program_id
      FROM        pv_partner_program_b
      START WITH  program_id =p_program_id
      CONNECT BY  program_id = prior program_parent_id
   )
   );
   */

   CURSOR  check_attr_exist(p_program_id NUMBER) IS
   SELECT 'X' from dual where exists(  SELECT distinct(attr.attribute_id)
   FROM    pv_ge_qsnr_elements_b qsnr, pv_entity_attrs attr
   WHERE   arc_used_by_entity_code='PRGM'
   AND     attr.ENTITY_ATTR_ID=qsnr.entity_attr_id
   AND     used_by_entity_id in
      (   SELECT      program_id
          FROM        pv_partner_program_b
          START WITH  program_id =p_program_id
         CONNECT BY  program_id = prior program_parent_id
      )
   );


   CURSOR attribute_id_csr(p_program_id NUMBER) IS
   SELECT distinct(attr.attribute_id)
   FROM    pv_ge_qsnr_elements_b qsnr, pv_entity_attrs attr
   WHERE   arc_used_by_entity_code='PRGM'
   AND     attr.ENTITY_ATTR_ID=qsnr.entity_attr_id
   AND     used_by_entity_id in
   (   SELECT      program_id
      FROM        pv_partner_program_b
      START WITH  program_id =p_program_id
      CONNECT BY  program_id = prior program_parent_id
   );



   /**
   SELECT distinct(entity_attr_id)
   FROM    pv_ge_qsnr_elements_b
   WHERE   arc_used_by_entity_code='PRGM'
   AND     used_by_entity_id in
  (   SELECT      program_id
      FROM        pv_partner_program_b
      START WITH  program_id =p_program_id
      CONNECT BY  program_id = prior program_parent_id
   );
   */
   CURSOR pending_appovers_csr ( enrl_id NUMBER ) IS
      SELECT entity_approver_id,object_version_number
      FROM   pv_ge_temp_approvers
      WHERE  APPR_FOR_ENTITY_ID =enrl_id
      AND    APPROVAL_STATUS_CODE IN ('PENDING_APPROVAL','PENDING_DEFAULT');

   l_attr_id_tbl PV_ENTY_ATTR_VALUE_PUB.NUMBER_TABLE;

   pv_pg_memb_rec        PV_Pg_Memberships_PVT.memb_rec_type;
   pv_pg_prev_memb_rec   PV_Pg_Memberships_PVT.memb_rec_type;
   l_approver_rec        Pv_Ge_Temp_Approvers_PVT.APPROVER_REC_TYPE;
   l_enrq_rec            PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
   l_mmbr_tran_rec       pv_pg_mmbr_transitions_PVT.mmbr_tran_rec_type;
   l_api_name            CONSTANT VARCHAR2(30) := 'process_approved_requests';
   l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   --This value for l_default_approver_id needs to be retrieved from profile

   l_membership_id        NUMBER;
   l_entity_approver_id   NUMBER;
   l_object_version_number NUMBER(9);
   l_enrollment_type_code VARCHAR2(30);
   l_previous_membership_id NUMBER;
   l_mmbr_transition_id  NUMBER;
			l_partner_id          NUMBER;
			l_program_id          NUMBER;
   l_previous_end_date   DATE;
   l_message_code        VARCHAR2(30);
   L_ORDER_HEADER_ID    NUMBER;
   l_param_tbl_var        PVX_UTILITY_PVT.log_params_tbl_type;
   l_attr_id_exists  varchar2(1):=null;
   l_program_name    VARCHAR2(60);

   BEGIN
         -- this api is called when the enrollment request is finally approved or when its rejected by any approvers

         --update the temp approvers table with the approvalstatus
         /*OPEN  approver_dtl_cur(enrl_request_id);
         FETCH  approver_dtl_cur into
                l_approver_rec.object_version_number
               ,l_approver_rec.entity_approver_id
               ,l_approver_rec.approver_id
               ,l_approver_rec.approver_type_code;
         CLOSE approver_dtl_cur;

         ----DBMS_OUTPUT.PUT_LINE('inside process response');

         l_approver_rec.approval_status_code:=approvalStatus;

         Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr(
                p_api_version_number    => 1.0
               ,p_init_msg_list         => FND_API.g_false
               ,p_commit                => FND_API.G_FALSE
               ,p_validation_level      => FND_API.g_valid_level_full
               ,x_return_status         => x_return_status
               ,x_msg_count             => x_msg_count
               ,x_msg_data              => x_msg_data
               ,p_approver_rec          =>l_approver_rec
          );

         IF x_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
         END IF;
         */

         FOR x in pending_appovers_csr(enrl_request_id) LOOP
            l_approver_rec.entity_approver_id :=x.entity_approver_id;
            l_approver_rec.object_version_number:=x.object_version_number;
            l_approver_rec.approval_status_code:='PEER_RESPONDED';
            Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
            (   p_api_version_number      => 1.0
                , p_init_msg_list         => FND_API.g_false
                , p_commit                => FND_API.g_false
                , p_validation_level      => FND_API.g_valid_level_full
                , x_return_status         => x_return_status
                , x_msg_count             => x_msg_count
                , x_msg_data              => x_msg_data
                , p_approver_rec          =>l_approver_rec
            );
         END LOOP;

         --set the record to update enrollment requests table
         OPEN  enr_requests_dtl_cur(enrl_request_id);
            FETCH enr_requests_dtl_cur into l_enrq_rec.object_version_number,l_enrollment_type_code,l_order_header_id,l_partner_id,l_program_name, l_program_id ;
      	 CLOSE enr_requests_dtl_cur;

         l_enrq_rec.enrl_request_id:=enrl_request_id;
         l_enrq_rec.request_status_code:=approvalStatus;


         --Also update the previous membership records depending on the enrollment type of the current request
         -- Also insert into member transitions table if the current request is upgrade or renewal.
        IF approvalStatus='APPROVED' THEN
            -- call the api to create a membership  record in memberships table
            pv_pg_memb_rec.enrl_request_id:=enrl_request_id;
            ----DBMS_OUTPUT.PUT_LINE('before setting enrollment record');

            setmembershipdetails( pv_pg_memb_rec   =>  pv_pg_memb_rec
                                 ,x_return_status   =>x_return_status
                                 ,x_msg_count       =>x_msg_count
                                 ,x_msg_data        =>x_msg_data
                                );
            ----DBMS_OUTPUT.PUT_LINE('after setting enrollment record');

	    l_partner_id:=pv_pg_memb_rec.partner_id;
            l_program_id:=pv_pg_memb_rec.program_id;

            PV_Pg_Memberships_PVT.Create_Pg_memberships(
                    p_api_version_number=>1.0
                   ,p_init_msg_list       => FND_API.g_false
                   ,p_commit              => FND_API.G_FALSE
                   ,p_validation_level    => FND_API.g_valid_level_full
                   ,x_return_status       => x_return_status
                   ,x_msg_count           => x_msg_count
                   ,x_msg_data            => x_msg_data
                   ,p_memb_rec            => pv_pg_memb_rec
                   ,x_membership_id       => l_membership_id
            );

            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            ----DBMS_OUTPUT.PUT_LINE('after creating enrollment'||l_membership_id);

            --update the enrollment requests table with the approvalstatus and tentative start and end dates.
            --this api is called after creating membership record is to get the membership start and end dates
            --from the memberhip record.

            l_enrq_rec.tentative_start_date:= pv_pg_memb_rec.start_date;
            l_enrq_rec.tentative_end_date:= pv_pg_memb_rec.original_end_date;

            PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests(
                    p_api_version_number    => 1.0
                   ,p_init_msg_list         => FND_API.g_false
                   ,p_commit                => FND_API.G_FALSE
                   ,p_validation_level      => FND_API.g_valid_level_full
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data
                  ,p_enrl_request_rec       => l_enrq_rec );

            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            l_param_tbl_var(1).param_name := 'PROGRAM_NAME';
            l_param_tbl_var(1).param_value := l_program_name;

            PVX_UTILITY_PVT.create_history_log
             (    p_arc_history_for_entity_code  => 'ENRQ'
                  ,p_history_for_entity_id       => enrl_request_id
                  ,p_history_category_code       => 'APPROVAL'
                  ,p_message_code                => 'PV_ENR_REQ_APPROVED'
                  ,p_comments                    => null
                  ,p_partner_id                  => l_partner_id
                  ,p_access_level_flag           => 'P'
                  ,p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
                  ,p_log_params_tbl              => l_param_tbl_var
                  ,p_init_msg_list               => FND_API.g_false
                  ,p_commit                      => FND_API.G_FALSE
                  ,x_return_status               => x_return_status
                  ,x_msg_count                   => x_msg_count
                  ,x_msg_data                    => x_msg_data
              );

            ----DBMS_OUTPUT.PUT_LINE('after log');
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

             PVX_UTILITY_PVT.create_history_log
             (    p_arc_history_for_entity_code  => 'MEMBERSHIP'
                  ,p_history_for_entity_id       => enrl_request_id
                  ,p_history_category_code       => 'APPROVAL'
                  ,p_message_code                => 'PV_PRGM_MEMB_CREATED'
                  ,p_comments                    => null
                  ,p_partner_id                  => l_partner_id
                  ,p_access_level_flag           => 'P'
                  ,p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
                  ,p_log_params_tbl              => l_param_tbl_var
                  ,p_init_msg_list               => FND_API.g_false
                  ,p_commit                      => FND_API.G_FALSE
                  ,x_return_status               => x_return_status
                  ,x_msg_count                   => x_msg_count
                  ,x_msg_data                    => x_msg_data
              );

            ----DBMS_OUTPUT.PUT_LINE('after log');
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            IF l_enrollment_type_code='UPGRADE' THEN
               --end date the previous enrollment

               FOR rec_cur in prev_memb_id_cur(enrl_request_id)   LOOP

                  OPEN  membership_dtl_cur(rec_cur.prev_membership_id);
                     FETCH membership_dtl_cur into pv_pg_prev_memb_rec.object_version_number;
        	         CLOSE membership_dtl_cur;

                  pv_pg_prev_memb_rec.membership_id:=rec_cur.prev_membership_id;
                  pv_pg_prev_memb_rec.actual_end_date:=sysdate;
                  pv_pg_prev_memb_rec.membership_status_code:='UPGRADED';

                  PV_Pg_Memberships_PVT.Update_pg_memberships(
                        p_api_version_number    => 1.0
                       ,p_init_msg_list         => FND_API.g_false
                       ,p_commit                => FND_API.G_FALSE
                       ,p_validation_level      => FND_API.g_valid_level_full
                       ,x_return_status         => x_return_status
                       ,x_msg_count             => x_msg_count
                       ,x_msg_data              => x_msg_data
                       ,p_memb_rec             => pv_pg_prev_memb_rec
                  );


                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  --call  pv_pg_mmbr_transitions table api
                  --confirm the business logic below

                  l_mmbr_tran_rec.FROM_MEMBERSHIP_ID:=rec_cur.prev_membership_id;
                  l_mmbr_tran_rec.TO_MEMBERSHIP_ID:=l_membership_id;


                  pv_pg_mmbr_transitions_PVT.Create_Mmbr_Trans
                  (    p_api_version_number       =>1.0
                      ,p_init_msg_list            => FND_API.g_false
                      ,p_commit                   => FND_API.G_FALSE
                      ,p_validation_level         => FND_API.g_valid_level_full
                      ,x_return_status            => x_return_status
                      ,x_msg_count                => x_msg_count
                      ,x_msg_data                 => x_msg_data
                      ,p_mmbr_tran_rec            => l_mmbr_tran_rec
                      ,x_mmbr_transition_id       => l_mmbr_transition_id
                  );

                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
                  END IF;

               END LOOP  ;
            END IF;--end of processing if its upgrade

            IF l_enrollment_type_code='RENEW' THEN


               OPEN  prev_memb_id_cur(enrl_request_id);
                     FETCH prev_memb_id_cur into l_previous_membership_id;
               CLOSE prev_memb_id_cur;

               pv_pg_prev_memb_rec.membership_id:=l_previous_membership_id;

               IF  pv_pg_memb_rec.membership_status_code='ACTIVE' THEN
                    pv_pg_prev_memb_rec.membership_status_code:='RENEWED';
               END IF;

               OPEN  membership_dtl_cur(l_previous_membership_id);
                  FETCH membership_dtl_cur into pv_pg_prev_memb_rec.object_version_number;
     	       CLOSE membership_dtl_cur;


               PV_Pg_Memberships_PVT.Update_Pg_memberships(
                     p_api_version_number    => 1.0
                    ,p_init_msg_list         => FND_API.g_false
                    ,p_commit                => FND_API.G_FALSE
                    ,p_validation_level      => FND_API.g_valid_level_full
                    ,x_return_status         => x_return_status
                    ,x_msg_count             => x_msg_count
                    ,x_msg_data              => x_msg_data
                    ,p_memb_rec         => pv_pg_prev_memb_rec
               );


               IF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
               END IF;

               --call  pv_pg_mmbr_transitions table api
               l_mmbr_tran_rec.FROM_MEMBERSHIP_ID:=l_previous_membership_id;
               l_mmbr_tran_rec.TO_MEMBERSHIP_ID:=l_membership_id;

               pv_pg_mmbr_transitions_PVT.Create_Mmbr_Trans(
                         p_api_version_number    => 1.0
                        ,p_init_msg_list         => FND_API.g_false
                        ,p_commit                => FND_API.G_FALSE
                        ,p_validation_level      => FND_API.g_valid_level_full
                        ,x_return_status         => x_return_status
                        ,x_msg_count             => x_msg_count
                        ,x_msg_data              => x_msg_data
                        ,p_mmbr_tran_rec         => l_mmbr_tran_rec
                        ,x_mmbr_transition_id    => l_mmbr_transition_id
                      );


            END IF; --end of renewal if

            /* call responsiblity management api. that api will take care of granting/revoking responsibilties
                for currnet memberships or previous memberships as required */

            Pv_User_Resp_Pvt.manage_memb_resp
            (    p_api_version_number    => 1.0
                ,p_init_msg_list         => Fnd_Api.g_false
                ,p_commit                => Fnd_Api.g_false
                ,p_membership_id         => l_membership_id
                ,x_return_status         => x_return_status
                ,x_msg_count             => x_msg_count
                ,x_msg_data              => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	       RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;

            --store the attribute values at the time of enrollment approvals
	     OPEN check_attr_exist(l_program_id);
	        FETCH check_attr_exist  INTO l_attr_id_exists;
             CLOSE check_attr_exist;

            IF l_attr_id_exists='X' THEN
               OPEN attribute_id_csr(l_program_id);
	                 FETCH attribute_id_csr  BULK  COLLECT INTO l_attr_id_tbl;
               CLOSE attribute_id_csr;

	      pv_enty_attr_value_pub.copy_partner_attr_values
	     (  p_api_version_number		=>1.0
		,p_init_msg_list	      => fnd_api.g_false
		,p_commit		      => fnd_api.g_false
		,p_validation_level	      => fnd_api.g_valid_level_full
		,x_return_status	      => x_return_status
		,x_msg_count		      => x_msg_count
		,x_msg_data		      => x_msg_data
		,p_attr_id_tbl	              => l_attr_id_tbl
		,p_entity		      => 'ENRQ'
		,p_entity_id		      => enrl_request_id
		,p_partner_id		      => l_partner_id
	      );
	      ----DBMS_OUTPUT.PUT_LINE('after copy');
	      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	          RAISE FND_API.G_EXC_ERROR;
	       ELSIF x_return_status =FND_API.G_RET_STS_UNEXP_ERROR  THEN
	          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;
	    END IF; --end of if for coying attributes if there is any attribute defined


           ----DBMS_OUTPUT.PUT_LINE('after copy2');
           IF l_order_header_id is not null THEN
              ----DBMS_OUTPUT.PUT_LINE('before book order');
              PV_ORDER_MGMT_PVT.book_order
              (
                 p_api_version_number         =>1.0
                ,p_init_msg_list              => Fnd_Api.g_false
                ,p_commit                     => Fnd_Api.g_false
                ,p_order_header_id            => l_order_header_id
                ,x_return_status              => x_return_status
                ,x_msg_count                  => x_msg_count
                ,x_msg_data                   => x_msg_data
              );
              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	                RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	             END IF;
              ----DBMS_OUTPUT.PUT_LINE('after book order');
           END IF;

            -- send the welcome alert from workflow
	    ----DBMS_OUTPUT.PUT_LINE('before notify');
	    /**
            PV_PG_NOTIF_UTILITY_PVT.send_welcome_notif
	    (	 p_api_version       => 1.0
		 ,p_init_msg_list     => Fnd_Api.g_false
		 ,p_commit            => Fnd_Api.g_false
		 ,p_validation_level  => FND_API.g_valid_level_full
		 ,x_return_status     => x_return_status
		 ,x_msg_count         => x_msg_count
	 	 ,x_msg_data          => x_msg_data
		 ,p_membership_id     => l_membership_id
	    ) ;
	   */
	  -- calling the new workflow process in 11.5.10 :pukken
	 PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
          (
            p_api_version_number    => 1.0
            , p_init_msg_list       => Fnd_Api.g_false
            , p_commit              => Fnd_Api.g_false
            , p_validation_level    => FND_API.g_valid_level_full
            , p_context_id          => l_partner_id
	    , p_context_code        => 'PARTNER'
            , p_target_ctgry        => 'PARTNER'
            , p_target_ctgry_pt_id  => l_partner_id
            , p_notif_event_code    => 'PG_WELCOME'
            , p_entity_id           => enrl_request_id
	    , p_entity_code         => 'ENRQ'
            , p_wait_time           => 0
            , x_return_status       => x_return_status
            , x_msg_count           => x_msg_count
            , x_msg_data            => x_msg_data
          );

           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;





	ELSE --end of approved code
           --the code below is for enrollments that are rejected by any appprover.
           --update the enrollment requests table with the approvalstatus
           PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests(
                   p_api_version_number    => 1.0
                  ,p_init_msg_list         => FND_API.g_false
                  ,p_commit                => FND_API.G_FALSE
                  ,p_validation_level      => FND_API.g_valid_level_full
                  ,x_return_status         => x_return_status
                  ,x_msg_count             => x_msg_count
                  ,x_msg_data              => x_msg_data
                 ,p_enrl_request_rec       => l_enrq_rec
           );

           IF x_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
           ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
           END IF;


           IF l_order_header_id is not null THEN
              PV_ORDER_MGMT_PVT.cancel_order
              (
                 p_api_version_number         =>1.0
                ,p_init_msg_list              => Fnd_Api.g_false
                ,p_commit                     => Fnd_Api.g_false
                ,p_order_header_id            => l_order_header_id
                ,x_return_status              => x_return_status
                ,x_msg_count                  => x_msg_count
                ,x_msg_data                   => x_msg_data
              );
           END IF;

           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;


	    --store the attribute values at the time of enrollment approvals
	     OPEN check_attr_exist(l_program_id);
	        FETCH check_attr_exist  INTO l_attr_id_exists;
             CLOSE check_attr_exist;

            IF l_attr_id_exists='X' THEN
               OPEN attribute_id_csr(l_program_id);
	                 FETCH attribute_id_csr  BULK  COLLECT INTO l_attr_id_tbl;
               CLOSE attribute_id_csr;

	      pv_enty_attr_value_pub.copy_partner_attr_values
	     (  p_api_version_number		=>1.0
		,p_init_msg_list	      => fnd_api.g_false
		,p_commit		      => fnd_api.g_false
		,p_validation_level	      => fnd_api.g_valid_level_full
		,x_return_status	      => x_return_status
		,x_msg_count		      => x_msg_count
		,x_msg_data		      => x_msg_data
		,p_attr_id_tbl	              => l_attr_id_tbl
		,p_entity		      => 'ENRQ'
		,p_entity_id		      => enrl_request_id
		,p_partner_id		      => l_partner_id
	      );
	      ----DBMS_OUTPUT.PUT_LINE('after copy');
	      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	          RAISE FND_API.G_EXC_ERROR;
	       ELSIF x_return_status =FND_API.G_RET_STS_UNEXP_ERROR  THEN
	          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	       END IF;
	    END IF; --end of if for coying attributes if there is any attribute defined


            --send workflow notification to partner about the rejection of enrollment request
           /**PV_PG_NOTIF_UTILITY_PVT.send_rejection_notif
	    (	 p_api_version       => 1.0
		 ,p_init_msg_list     => Fnd_Api.g_false
		 ,p_commit            => Fnd_Api.g_false
		 ,p_validation_level  => FND_API.g_valid_level_full
		 ,x_return_status     => x_return_status
		 ,x_msg_count         => x_msg_count
	 	 ,x_msg_data          => x_msg_data
		 ,p_enrl_request_id   => enrl_request_id
	    ) ;
	    */
           -- calling the new workflow process in 11.5.10 pukken
          PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
          (
             p_api_version_number    => 1.0
             , p_init_msg_list       => Fnd_Api.g_false
             , p_commit              => Fnd_Api.g_false
             , p_validation_level    => FND_API.g_valid_level_full
             , p_context_id          => l_partner_id
 	     , p_context_code        => 'PARTNER'
             , p_target_ctgry        => 'PARTNER'
             , p_target_ctgry_pt_id  => l_partner_id
             , p_notif_event_code    =>  'PG_REJECT'
             , p_entity_id           => enrl_request_id
 	     , p_entity_code         => 'ENRQ'
             , p_wait_time           => 0
             , x_return_status       => x_return_status
             , x_msg_count           => x_msg_count
             , x_msg_data            => x_msg_data
           );

           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
           ----DBMS_OUTPUT.PUT_LINE('after rejection notify');

        END IF; --end of if rejected
        -- also if this is a subsidiary  need to send notifictaion to global
        -- also need to make a call to send notifictaion to VAD incase this enrollment is beacuse of VAD inviation
        -- that IMP's enrollment had been approved.
        send_notifications
        (
           p_api_version_number    => 1.0
           , p_init_msg_list       => Fnd_Api.g_false
           , p_commit              => Fnd_Api.g_false
           , p_validation_level    => FND_API.g_valid_level_full
           , p_partner_id          => l_partner_id
           , p_enrl_request_id     => enrl_request_id
           , p_memb_type           => null
           , p_enrq_status         => approvalStatus
           , x_return_status       => x_return_status
           , x_msg_count           => x_msg_count
           , x_msg_data            => x_msg_data
        );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	      RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

   EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END process_response;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   submit_enrl_req_for_approval
   --
   -- PURPOSE
   --   to submit an enrollment request for approval.
   --
   -- HISTORY
   --   09/24/2002        pukken        CREATION
   --------------------------------------------------------------------------

   PROCEDURE submit_enrl_req_for_approval
   (
      p_api_version_number          IN   NUMBER
     , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
     , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
     , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     , enrl_request_id              IN   NUMBER
     , entity_code                  IN   VARCHAR2
     , x_return_status              OUT  NOCOPY  VARCHAR2
     , x_msg_count                  OUT  NOCOPY  NUMBER
     , x_msg_data                   OUT  NOCOPY  VARCHAR2
   )IS

      CURSOR approver_dtl_cur (p_enrl_req_id number, p_person_id NUMBER,p_user_id NUMBER) IS
      SELECT object_version_number,entity_approver_id,approver_id,approver_type_code
      FROM   pv_ge_temp_approvers
      WHERE  appr_for_entity_id=p_enrl_req_id
      AND    approver_id = DECODE( APPROVER_TYPE_CODE,'PERSON',p_person_id,'USER',p_user_id,null )
      AND    arc_appr_for_entity_code='ENRQ';

      CURSOR c_resource_per_cur(p_appr_id NUMBER) IS
      SELECT res.resource_id,res.resource_name
      FROM   jtf_rs_resource_extns_vl res,fnd_user fnd
      WHERE  fnd.employee_id = p_appr_id
      AND    res.user_id=fnd.user_id;

      CURSOR c_resource_usr_cur(p_appr_id NUMBER) IS
      SELECT res.resource_id,res.resource_name
      FROM   jtf_rs_resource_extns_vl res,fnd_user fnd
      WHERE  fnd.user_id = p_appr_id
      AND    res.user_id=fnd.user_id;

      CURSOR c_enrl_cur ( enrl_id NUMBER ) IS
      SELECT partner_id
      FROM   pv_pg_enrl_requests
      WHERE  enrl_request_id=enrl_id;

      CURSOR pending_appovers_csr ( enrl_id NUMBER ) IS
      SELECT entity_approver_id,object_version_number
      FROM   pv_ge_temp_approvers
      WHERE  APPR_FOR_ENTITY_ID =enrl_id
      AND    APPROVAL_STATUS_CODE IN ('PENDING_APPROVAL','PENDING_DEFAULT');

      CURSOR person_id_csr ( p_user_id NUMBER ) IS
      SELECT person_id ,full_name
      FROM   per_all_people_f per
             , FND_USER  usr
      WHERE  user_id=p_user_id
      AND    usr.person_party_id=per.party_id;

      CURSOR is_partner_usr_csr( p_usr_id NUMBER ) IS
      SELECT 'Y'
      FROM   fnd_user usr
             ,  jtf_rs_resource_extns_vl res
      WHERE  usr.user_id=p_usr_id
      AND    usr.user_id=res.user_id
      AND    res.category='PARTY';

      l_isPartnerFlag       VARCHAR2(1);
      --nextApprover        AME_UTIL.APPROVERRECORD;
      pv_pg_memb_rec        PV_Pg_Memberships_PVT.memb_rec_type;
      pv_pg_prev_memb_rec   PV_Pg_Memberships_PVT.memb_rec_type;
      l_approver_rec        Pv_Ge_Temp_Approvers_PVT.APPROVER_REC_TYPE;
      l_check_row_pa        BOOLEAN :=FALSE;
      l_check_row           BOOLEAN:=FALSE;
      l_checkrow_pending    BOOLEAN:=FALSE;
      l_api_name            CONSTANT VARCHAR2(30) := 'submit_enrl_req_for_approval';
      l_full_name           CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
      l_api_version_number  CONSTANT NUMBER       := 1.0;
      --This value for l_default_approver_id needs to be retrieved from profile
      l_default_approver_id  NUMBER;
      l_admin_id             NUMBER;
      l_admin_type           VARCHAR2(15);
      l_approver_id          NUMBER;
      l_approver_type        VARCHAR2(15);
      l_membership_id        NUMBER;
      l_entity_approver_id   NUMBER;
      l_itemkey              VARCHAR2(30);
      l_object_version_number NUMBER(9);
      l_resource_name        VARCHAR2(360);
      l_resource_id          NUMBER;
      l_param_tbl_var        PVX_UTILITY_PVT.log_params_tbl_type;
      l_partner_id           NUMBER;
      l_display_name         VARCHAR2(240);
      l_personid             NUMBER;
      x_role_name            VARCHAR2(320);
      x_role_display_name    VARCHAR2(360);
      l_approverPersonId     NUMBER;
      l_approverUserId       NUMBER;
      l_rec_appr            Pv_Ge_Temp_Approvers_PVT.APPROVER_REC_TYPE;
      l_approval_status_code  VARCHAR2(30);
      x_approvalProcessCompleteYNOut VARCHAR2(100);
      x_nextApproversOut             ame_util.approversTable2;
      xitemIndexesOut                ame_util.idList;
      xitemClassesOut                ame_util.stringList;
      xitemIdsOut                    ame_util.stringList;
      xitemSourcesOut                ame_util.longStringList;
      xproductionIndexesOut          ame_util.idList;
      xvariableNamesOut              ame_util.stringList;
      xvariableValuesOut             ame_util.stringList;
      xtransVariableNamesOut         ame_util.stringList;
      xtransVariableValuesOut        ame_util.stringList;
      adminApprRec                   ame_util.approverRecord2;
      currApprRec                    ame_util.approverRecord2;

   BEGIN
      -- call AME api to get the next
      SAVEPOINT submit_enrl_req_for_approval;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (   l_api_version_number
          , p_api_version_number
          , l_api_name
          , G_PKG_NAME
      )
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_enrl_cur( enrl_request_id );
         FETCH c_enrl_cur INTO l_partner_id;
      CLOSE c_enrl_cur;


      /** Following is required as we expect AME to return their new statuses. Bug # 4879218  **/
      ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;

      AME_API2.getNextApprovers3
      (   applicationIdIn                => 691
          , transactionTypeIn            => 'ENRQ'
          , transactionIdIn              => enrl_request_id
          , flagApproversAsNotifiedIn    => ame_util.booleanTrue
          , approvalProcessCompleteYNOut => x_approvalProcessCompleteYNOut
          , nextApproversOut             => x_nextApproversOut
          , itemIndexesOut               => xitemIndexesOut
          , itemClassesOut               => xitemClassesOut
          , itemIdsOut                   => xitemIdsOut
          , itemSourcesOut               => xitemSourcesOut
          , productionIndexesOut         => xproductionIndexesOut
          , variableNamesOut             => xvariableNamesOut
          , variableValuesOut            => xvariableValuesOut
          , transVariableNamesOut        => xtransVariableNamesOut
          , transVariableValuesOut       => xtransVariableValuesOut
      );


       	 If x_approvalProcessCompleteYNOut=ame_util2.completeFullyApproved THEN
	  -- This means there are no more approvers to approve and approval is complete
           l_check_row_pa:=check_pending_approval(enrl_request_id);--this should be queried with status 'pending approval'
           IF l_check_row_pa =true AND g_isApproverInList=true THEN


            -- update temp approvers with status approved
            l_approverPersonId:= FND_GLOBAL.EMPLOYEE_ID;
            l_approverUserId:=  FND_GLOBAL.USER_ID;

            OPEN  approver_dtl_cur(enrl_request_id,l_approverPersonId, l_approverUserId);
               FETCH  approver_dtl_cur into l_rec_appr.object_version_number,
                                            l_rec_appr.entity_approver_id,
                                            l_rec_appr.approver_id,
                                            l_rec_appr.approver_type_code;
            CLOSE approver_dtl_cur;

            IF l_rec_appr.entity_approver_id IS NOT NULL THEN
                 l_rec_appr.approval_status_code:='APPROVED';
                 Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                  (   p_api_version_number      => 1.0
                      , p_init_msg_list         => FND_API.g_false
                      , p_commit                => FND_API.g_false
                      , p_validation_level      => FND_API.g_valid_level_full
                      , x_return_status         => x_return_status
                      , x_msg_count             => x_msg_count
                      , x_msg_data              => x_msg_data
                      , p_approver_rec          =>l_rec_appr
                  );
                  ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
            END IF;

            process_response
            (   enrl_request_id     =>enrl_request_id
                , approvalStatus    =>'APPROVED'
                , x_return_status   =>x_return_status
                , x_msg_count       =>x_msg_count
                , x_msg_data        =>x_msg_data
            );

            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

          ELSIF   l_check_row_pa =true AND g_isApproverInList=false THEN

          --call process response
                     /* there could have been approvers for the enrollment and
                        since the rule changed, they are no longer valid approvers and
                         hence their approval status should be updated
                     */
                     FOR x in pending_appovers_csr(enrl_request_id) LOOP
                        l_rec_appr.entity_approver_id :=x.entity_approver_id;
                        l_rec_appr.object_version_number:=x.object_version_number;
                        l_rec_appr.approval_status_code:='APPROVER_CHANGED';
                        Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                        (   p_api_version_number      => 1.0
                            , p_init_msg_list         => FND_API.g_false
                            , p_commit                => FND_API.g_false
                            , p_validation_level      => FND_API.g_valid_level_full
                            , x_return_status         => x_return_status
                            , x_msg_count             => x_msg_count
                            , x_msg_data              => x_msg_data
                            , p_approver_rec          =>l_rec_appr
                        );
                          ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                        IF x_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF;
                     END LOOP;

                     process_response
                     (   enrl_request_id     =>enrl_request_id
                         , approvalStatus    =>'APPROVED'
                         , x_return_status   =>x_return_status
                         , x_msg_count       =>x_msg_count
                         , x_msg_data        =>x_msg_data
                     );
                       ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;


	  END IF;


         ELSIF x_approvalProcessCompleteYNOut=ame_util2.completeNoApprovers THEN
	    -- This means no appprovers are returned by OAM  which means route the request to default approver

            /**this means that there is no rule satisfying the criteria. so find OUT  the
               the default approver from the profile value and send the FYI
               notification to the default approver. if the request
               was sent to default approver, OAM does not record that and we cannot update OAM in that case.
               We store the information in Pv_Ge_Temp_Approvers table that the request is awating approval
               from the default approver and so the approval status code is PENDING_DEFAULT
            */
            l_default_approver_id:= isnumber( FND_PROFILE.VALUE('PV_ENRQ_DEFAULT_APPR') );
            IF ( l_default_approver_id is NULL ) THEN
               FND_MESSAGE.set_name('PV', 'PV_ENRQ_APPR_NOT_SET');
               FND_MSG_PUB.add;
               RAISE FND_API.G_EXC_ERROR;
            END IF;


            l_approver_rec.arc_appr_for_entity_code :='ENRQ';
            l_approver_rec.appr_for_entity_id :=enrl_request_id;
            -- get the person id for the default approver
            OPEN person_id_csr (l_default_approver_id);
               FETCH  person_id_csr INTO l_approver_rec.approver_id,l_display_name;
            CLOSE  person_id_csr;
            l_approver_rec.approver_type_code:='PERSON';
            l_approver_rec.approval_status_code:='PENDING_DEFAULT';
            -- check whether there exists a row for this approver for this enrollment request
            CheckApprInTempApprTable(enrl_request_id,l_approver_rec.approver_id,l_entity_approver_id,l_object_version_number,l_approval_status_code );

            IF l_entity_approver_id IS NOT NULL THEN
               -- get approval status also and if its pending approval, approve it..otherwise put status as pending default
                /* rare scenario
                   if current approver approving it and if rule changed in AME and no rule satisfies ..
                   means route to default approver and if current approver is also default approver ,
                   then enrollment should be approved, else put it as pending default and sent notification
               */
               l_approver_rec.entity_approver_id :=l_entity_approver_id;
               l_approver_rec.object_version_number:=l_object_version_number;

               IF g_approver_response='APPROVED' THEN
                  l_approver_rec.approval_status_code:=g_approver_response;
                  IF l_approval_status_code='PENDING_APPROVAL' THEN
                     /* there could have been approvers for the enrollment and
                        since the rule changed, they are no longer valid approvers and
                        hence their approval status should be updated
                     */

                     Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                     (   p_api_version_number      => 1.0
                         , p_init_msg_list         => FND_API.g_false
                         , p_commit                => FND_API.g_false
                         , p_validation_level      => FND_API.g_valid_level_full
                         , x_return_status         => x_return_status
                         , x_msg_count             => x_msg_count
                         , x_msg_data              => x_msg_data
                         , p_approver_rec          =>l_approver_rec

                     );
                       ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                     --call process response
                     /* there could have been approvers for the enrollment and
                        since the rule changed, they are no longer valid approvers and
                         hence their approval status should be updated
                     */
                     FOR x in pending_appovers_csr(enrl_request_id) LOOP
                        l_rec_appr.entity_approver_id :=x.entity_approver_id;
                        l_rec_appr.object_version_number:=x.object_version_number;
                        l_rec_appr.approval_status_code:='APPROVER_CHANGED';
                        Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                        (   p_api_version_number      => 1.0
                            , p_init_msg_list         => FND_API.g_false
                            , p_commit                => FND_API.g_false
                            , p_validation_level      => FND_API.g_valid_level_full
                            , x_return_status         => x_return_status
                            , x_msg_count             => x_msg_count
                            , x_msg_data              => x_msg_data
                            , p_approver_rec          =>l_rec_appr
                        );
                          ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                        IF x_return_status = FND_API.g_ret_sts_error THEN
                           RAISE FND_API.g_exc_error;
                        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                           RAISE FND_API.g_exc_unexpected_error;
                        END IF;
                     END LOOP;

                     process_response
                     (   enrl_request_id     =>enrl_request_id
                         , approvalStatus    =>g_approver_response
                         , x_return_status   =>x_return_status
                         , x_msg_count       =>x_msg_count
                         , x_msg_data        =>x_msg_data
                     );
                       ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                  ELSE
                     Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                     (   p_api_version_number      => 1.0
                         , p_init_msg_list         => FND_API.g_false
                         , p_commit                => FND_API.g_false
                         , p_validation_level      => FND_API.g_valid_level_full
                         , x_return_status         => x_return_status
                         , x_msg_count             => x_msg_count
                         , x_msg_data              => x_msg_data
                         , p_approver_rec          =>l_approver_rec

                     );
                             ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                     WF_DIRECTORY.getrolename
                     (   p_orig_system         => 'PER'
                         , p_orig_system_id    => l_approver_rec.approver_id
                         , p_name              => x_role_name
                         , p_display_name      => x_role_display_name
                     );

                     StartProcess
                     (   p_object_id            => enrl_request_id
                         , p_object_type        => 'ENRQ'
                         , processName          => 'PV_APPROVER_NOTIFICATIONS'
                         , itemtype             => 'PVERAPNT'
                         , p_entity_approver_id => l_entity_approver_id
                         , p_role_name          => x_role_name
                         , p_display_name       => x_role_display_name
                         , x_itemkey            => l_itemkey
                     ) ;
                  END IF;
               ELSE
                  -- means if its rejected
                  l_approver_rec.approval_status_code:=g_approver_response;
                  Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                   (   p_api_version_number      => 1.0
                       , p_init_msg_list         => FND_API.g_false
                       , p_commit                => FND_API.g_false
                       , p_validation_level      => FND_API.g_valid_level_full
                       , x_return_status         => x_return_status
                       , x_msg_count             => x_msg_count
                       , x_msg_data              => x_msg_data
                       , p_approver_rec          =>l_approver_rec

                   );
                     ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                   IF x_return_status = FND_API.g_ret_sts_error THEN
                      RAISE FND_API.g_exc_error;
                   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                      RAISE FND_API.g_exc_unexpected_error;
                   END IF;
                   FOR x in pending_appovers_csr(enrl_request_id) LOOP
                      l_rec_appr.entity_approver_id :=x.entity_approver_id;
                      l_rec_appr.object_version_number:=x.object_version_number;
                      l_rec_appr.approval_status_code:='APPROVER_CHANGED';
                      Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                      (   p_api_version_number      => 1.0
                          , p_init_msg_list         => FND_API.g_false
                          , p_commit                => FND_API.g_false
                          , p_validation_level      => FND_API.g_valid_level_full
                          , x_return_status         => x_return_status
                          , x_msg_count             => x_msg_count
                          , x_msg_data              => x_msg_data
                          , p_approver_rec          =>l_rec_appr
                      );
                        ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                   END LOOP;
                    --call process response
                   process_response
                   (   enrl_request_id     =>enrl_request_id
                       , approvalStatus    =>g_approver_response
                       , x_return_status   =>x_return_status
                       , x_msg_count       =>x_msg_count
                       , x_msg_data        =>x_msg_data
                   );
                        ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END IF;
            ELSE
               /* there could have been approvers for the enrollment and
                  since the rule changed, they are no longer valid approvers and
                  hence their approval status should be updated
               */
               FOR x in pending_appovers_csr(enrl_request_id) LOOP
                  l_rec_appr.entity_approver_id :=x.entity_approver_id;
                  l_rec_appr.object_version_number:=x.object_version_number;
                  l_rec_appr.approval_status_code:='APPROVER_CHANGED';
                  Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                  (   p_api_version_number      => 1.0
                      , p_init_msg_list         => FND_API.g_false
                      , p_commit                => FND_API.g_false
                      , p_validation_level      => FND_API.g_valid_level_full
                      , x_return_status         => x_return_status
                      , x_msg_count             => x_msg_count
                      , x_msg_data              => x_msg_data
                      , p_approver_rec          =>l_rec_appr
                  );
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END LOOP;

               /* create a row for the new default approver  with status pending_default */
               Pv_Ge_Temp_Approvers_PVT.Create_Ptr_Enr_Temp_Appr
               (   p_api_version_number    =>l_api_version_number
                   , x_return_status       =>x_return_status
                   , x_msg_count           =>x_msg_count
                   , x_msg_data            =>x_msg_data
                   , p_approver_rec        =>l_approver_rec
                   , x_entity_approver_id  =>l_entity_approver_id
               );

               ----DBMS_OUTPUT.PUT_LINE('inserted into temp approvers');
               IF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
               -- also log into enrollment history  that its beem send to default approver.

               l_param_tbl_var(1).param_name := 'APPROVER_NAME';
               l_param_tbl_var(1).param_value := l_display_name;
               PVX_UTILITY_PVT.create_history_log
               (   p_arc_history_for_entity_code   => 'ENRQ'
                   , p_history_for_entity_id       => enrl_request_id
                   , p_history_category_code       => 'APPROVAL'
                   , p_message_code                => 'PV_ENR_REQ_TO_DEFAULT_APPR'
                   , p_comments                    => null
                   , p_partner_id                  => l_partner_id
                   , p_access_level_flag           => 'P'
                   , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                   , p_log_params_tbl              => l_param_tbl_var
                   , p_init_msg_list               => FND_API.g_false
                   , p_commit                      => FND_API.G_FALSE
                   , x_return_status               => x_return_status
                   , x_msg_count                   => x_msg_count
                   , x_msg_data                    => x_msg_data
               );
               IF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
               --call workflow process

               WF_DIRECTORY.getrolename
               (   p_orig_system         => 'PER'
                   , p_orig_system_id    => l_approver_rec.approver_id
                   , p_name              => x_role_name
                   , p_display_name      => x_role_display_name
               );

               StartProcess
               (   p_object_id            => enrl_request_id
                   , p_object_type        => 'ENRQ'
                   , processName          => 'PV_APPROVER_NOTIFICATIONS'
                   , itemtype             => 'PVERAPNT'
                   , p_entity_approver_id => l_entity_approver_id
                   , p_role_name          => x_role_name
                   , p_display_name       => x_role_display_name
                   , x_itemkey            => l_itemkey
               ) ;
            END IF;
            ----DBMS_OUTPUT.PUT_LINE('after finishing workflow process');

      ELSIF  x_approvalProcessCompleteYNOut = ame_util2.notCompleted THEN
         /* We need to update temp approvers table record with approved status
            for the logged in user for this enrollment request. The approval status
            for the logged in user   can be only approved in this scenario.
         */

         l_approverPersonId:= FND_GLOBAL.EMPLOYEE_ID;
         l_approverUserId:=  FND_GLOBAL.USER_ID;

         OPEN  approver_dtl_cur(enrl_request_id,l_approverPersonId, l_approverUserId);
            FETCH  approver_dtl_cur into l_rec_appr.object_version_number,
                                         l_rec_appr.entity_approver_id,
                                         l_rec_appr.approver_id,
                                         l_rec_appr.approver_type_code;
         CLOSE approver_dtl_cur;

         ----DBMS_OUTPUT.PUT_LINE('if after approval dtl _cur' || l_rec_appr.entity_approver_id );
         IF l_rec_appr.entity_approver_id IS NOT NULL THEN
            l_rec_appr.approval_status_code:=g_approver_response;
            Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
            (   p_api_version_number      => 1.0
                , p_init_msg_list         => FND_API.g_false
                , p_commit                => FND_API.g_false
                , p_validation_level      => FND_API.g_valid_level_full
                , x_return_status         => x_return_status
                , x_msg_count             => x_msg_count
                , x_msg_data              => x_msg_data
                , p_approver_rec          =>l_rec_appr
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;
         ----DBMS_OUTPUT.PUT_LINE('iafter temp');
         /**if nextApprover.approval_status = ame_util.exception, it means an error has occurred
            it may return the admin approver or it may just return a exception status
            write to enrollment logs that there is an error
         */

         IF x_nextApproversOut.COUNT>0 THEN
            adminApprRec := x_nextApproversOut(1);
            IF (adminApprRec.approval_status = ame_util.exceptionStatus) THEN
               IF adminApprRec.name IS NOT NULL THEN
                  l_admin_id := adminApprRec.orig_system_id;
                  l_admin_type:=adminApprRec.orig_system;
                  l_param_tbl_var(1).param_name := 'ADMINISTRATOR';
                  IF adminApprRec.display_name IS NULL THEN
                     l_param_tbl_var(1).param_value := adminApprRec.name;
                  ELSE
                     l_param_tbl_var(1).param_value := adminApprRec.display_name;
                  END If;
                  ----DBMS_OUTPUT.PUT_LINE('exception');
                  PVX_UTILITY_PVT.create_history_log
                  (   p_arc_history_for_entity_code   => 'ENRQ'
                      , p_history_for_entity_id       => enrl_request_id
                      , p_history_category_code       => 'APPROVAL'
                      , p_message_code                => 'PV_ERROR_ENR_APPROVAL'
                      , p_comments                    => null
                      , p_partner_id                  => l_partner_id
                      , p_access_level_flag           => 'P'
                      , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                      , p_log_params_tbl              => l_param_tbl_var
                      , p_init_msg_list               => FND_API.g_false
                      , p_commit                      => FND_API.G_FALSE
                      , x_return_status               => x_return_status
                      , x_msg_count                   => x_msg_count
                      , x_msg_data                    => x_msg_data
                  );
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  IF l_admin_id IS NOT NULL THEN
                     l_approver_rec:=NULL;
                     l_approver_rec.arc_appr_for_entity_code :='ENRQ';
                     l_approver_rec.appr_for_entity_id :=enrl_request_id;
                     l_approver_rec.approver_id :=l_admin_id;
                     l_approver_rec.approver_type_code:=l_admin_type;
                     l_approver_rec.approval_status_code:='ERROR';
                     CheckApprInTempApprTable(enrl_request_id,l_approver_rec.approver_id,l_entity_approver_id,l_object_version_number,l_approval_status_code );
                     IF l_entity_approver_id IS NOT NULL THEN
                        -- update
                        ----DBMS_OUTPUT.PUT_LINE('going for update');
                        l_approver_rec.entity_approver_id :=l_entity_approver_id;
                        l_approver_rec.object_version_number:=l_object_version_number;
                        Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                        (   p_api_version_number      => 1.0
                            , p_init_msg_list         => FND_API.g_false
                            , p_commit                => FND_API.g_false
                            , p_validation_level      => FND_API.g_valid_level_full
                            , x_return_status         => x_return_status
                            , x_msg_count             => x_msg_count
                            , x_msg_data              => x_msg_data
                            , p_approver_rec          =>l_approver_rec

                        );
                     ELSE
                        Pv_Ge_Temp_Approvers_PVT.Create_Ptr_Enr_Temp_Appr
                        (   p_api_version_number   =>l_api_version_number
                            , x_return_status      =>x_return_status
                            , x_msg_count          =>x_msg_count
                            , x_msg_data           =>x_msg_data
                            , p_approver_rec       =>l_approver_rec
                            , x_entity_approver_id =>l_entity_approver_id
                        );
                     END IF;
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                       RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                       RAISE FND_API.g_exc_unexpected_error;
                     END IF;
      	          END IF;  --end of if if no row exists in approver table for errored records.
      	       END IF; -- end of if , if adminApprover.name is not null
      	    ELSE
               /*Incase of First Responder Wins, we need to make sure to temp approvers
                 table to 'PEER_RESPONDED status' and the logic to check whether this is  First responder wins is
                 if there are more approvers and if the approval process is incomplete and if the temp
                 approvers has any record with 'PENDING_APPROVAL' status, then it needs to be updated
                 with status 'PEER_RESPONDED'
               */

               IF x_nextApproversOut.COUNT>0 and x_approvalProcessCompleteYNOut=ame_util2.notCompleted THEN
                  l_approver_rec:=NULL;
                  FOR x in pending_appovers_csr(enrl_request_id) LOOP
                     l_approver_rec.entity_approver_id :=x.entity_approver_id;
                     l_approver_rec.object_version_number:=x.object_version_number;
                     l_approver_rec.approval_status_code:='PEER_RESPONDED';
                     Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                     (   p_api_version_number      => 1.0
                         , p_init_msg_list         => FND_API.g_false
                         , p_commit                => FND_API.g_false
                         , p_validation_level      => FND_API.g_valid_level_full
                         , x_return_status         => x_return_status
                         , x_msg_count             => x_msg_count
                         , x_msg_data              => x_msg_data
                         , p_approver_rec          =>l_approver_rec
                     );
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                  END LOOP;
               END If;

               FOR i IN 1..x_nextApproversOut.COUNT LOOP
                  currApprRec := x_nextApproversOut(i);

                  IF currApprRec.orig_system='PER' THEN
                     l_personid:=currApprRec.orig_system_id;
                     l_approver_type:='PERSON';
                  ELSE
                     OPEN is_partner_usr_csr (FND_GLOBAL.USER_ID);
                        FETCH is_partner_usr_csr INTO l_isPartnerFlag;
                     CLOSE is_partner_usr_csr;
                     IF l_isPartnerFlag IS NULL THEN
                        FND_MESSAGE.set_name('PV', 'PV_ENRQ_INCAPPRMSG_TO_CM');
                     ELSE
                        FND_MESSAGE.set_name('PV', 'PV_ENRQ_INCAPPRMSG_TO_PTNR');
                     END IF;
                     FND_MSG_PUB.add;
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  IF l_personid IS NOT NULL THEN
                     l_approver_rec:=NULL;
                     -- insert into temp approvers table
                     l_approver_rec.arc_appr_for_entity_code :='ENRQ';
                     l_approver_rec.appr_for_entity_id :=enrl_request_id;
                     l_approver_rec.approver_id := l_personid;
                     l_approver_rec.approver_type_code:=l_approver_type;
                     l_approver_rec.approval_status_code:='PENDING_APPROVAL';
                     CheckApprInTempApprTable(enrl_request_id,l_approver_rec.approver_id,l_entity_approver_id,l_object_version_number,l_approval_status_code );
                     IF l_entity_approver_id IS NOT NULL THEN
                        -- update
                        ----DBMS_OUTPUT.PUT_LINE('going for update');
                        l_approver_rec.entity_approver_id :=l_entity_approver_id;
                        l_approver_rec.object_version_number:=l_object_version_number;
                        Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
                        (   p_api_version_number      => 1.0
                            , p_init_msg_list         => FND_API.g_false
                            , p_commit                => FND_API.g_false
                            , p_validation_level      => FND_API.g_valid_level_full
                            , x_return_status         => x_return_status
                            , x_msg_count             => x_msg_count
                            , x_msg_data              => x_msg_data
                            , p_approver_rec          =>l_approver_rec

                        );
                     ELSE
                        Pv_Ge_Temp_Approvers_PVT.Create_Ptr_Enr_Temp_Appr(
                            p_api_version_number =>l_api_version_number
                           ,x_return_status      =>x_return_status
                           ,x_msg_count          =>x_msg_count
                           ,x_msg_data           =>x_msg_data
                           ,p_approver_rec        =>l_approver_rec
                           ,x_entity_approver_id =>l_entity_approver_id
                        );
                     END IF;
                     IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                     END IF;
                  END If;
                  -- --DBMS_OUTPUT.PUT_LINE('before calling history for submiiting to approver');
                  -- also write to the enrolllments log  with the approver name
                  -- get the resource name of the approver to log into enrollment log
                  l_param_tbl_var(1).param_name := 'APPROVER_NAME';
                  IF currApprRec.display_name IS NULL THEN
                     l_param_tbl_var(1).param_value := currApprRec.name;
                  ELSE
                     l_param_tbl_var(1).param_value := currApprRec.display_name;
                  END If;


                  PVX_UTILITY_PVT.create_history_log
                  (   p_arc_history_for_entity_code   => 'ENRQ'
                      , p_history_for_entity_id       => enrl_request_id
                      , p_history_category_code       => 'APPROVAL'
                      , p_message_code                => 'PV_ENR_REQ_SUBMITTED_TO_APPR'
                      , p_comments                    => null
                      , p_partner_id                  => l_partner_id
                      , p_access_level_flag           => 'P'
                      , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                      , p_log_params_tbl              => l_param_tbl_var
                      , p_init_msg_list               => FND_API.g_false
                      , p_commit                      => FND_API.G_FALSE
                      , x_return_status               => x_return_status
                      , x_msg_count                   => x_msg_count
                      , x_msg_data                    => x_msg_data
                    );

                  ----DBMS_OUTPUT.PUT_LINE('after calling history for submiiting to approver');
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                        RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                        RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                  StartProcess
                  (   p_object_id            => enrl_request_id
                      , p_object_type        => 'ENRQ'
                      , processName          => 'PV_APPROVER_NOTIFICATIONS'
                      , itemtype             => 'PVERAPNT'
                      , p_entity_approver_id => l_entity_approver_id
                      , p_role_name          => currApprRec.name
                      , p_display_name       => currApprRec.display_name
                      , x_itemkey            => l_itemkey
                  ) ;


                  ----DBMS_OUTPUT.PUT_LINE('afterwlow call');
               END LOOP;
            END IF; --end of if else for admin exception or not.
         END IF;   --end of if , if approver count>0
      END IF;-- end of first if
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO submit_enrl_req_for_approval;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
     --write to enrollment log that an error has occured?. how do we handle the situation if an error occured in process
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO submit_enrl_req_for_approval;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO submit_enrl_req_for_approval;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
  END submit_enrl_req_for_approval;

--------------------------------------------------------------------------
   -- PROCEDURE
   --   update_enrl_req_status
   --
   -- PURPOSE
   --   called when approver rejects or approves an enrollment request.
   --
   -- HISTORY
   --   10/05/2002        pukken        CREATION
   --------------------------------------------------------------------------

   PROCEDURE update_enrl_req_status
   (
      p_api_version_number         IN   NUMBER
      , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      , enrl_request_id              IN   NUMBER
      , entity_code                  IN   VARCHAR2
      , approvalStatus               IN   VARCHAR2
      , start_date                   IN   DATE
      , end_date                     IN   DATE
      , x_return_status              OUT NOCOPY  VARCHAR2
      , x_msg_count                  OUT NOCOPY  NUMBER
      , x_msg_data                   OUT NOCOPY  VARCHAR2
   ) IS

      l_api_name                  CONSTANT VARCHAR2(30) := 'update_enrl_req_status';
      l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
      l_api_version_number        CONSTANT NUMBER       := 1.0;
      l_checkrow_pending boolean:=false;
      l_approver_rec          Pv_Ge_Temp_Approvers_PVT.approver_rec_type;
      pv_pg_memb_rec          PV_Pg_Memberships_PVT.memb_rec_type;
      l_enrq_rec              PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
      l_membership_id number;
      l_approvalStatus varchar2(50);
      l_approverPersonId number;
      l_approverUserId  number;
      l_message_code    varchar2(30);
      l_contract_signed boolean:=false;
      l_checklistStatus boolean:=false;
      l_allow_appr_wo_contract  varchar2(5);
      l_param_tbl_var PVX_UTILITY_PVT.log_params_tbl_type;
      l_param_tbl_default PVX_UTILITY_PVT.log_params_tbl_type;
      l_resource_name        VARCHAR2(360);
      l_resource_id          NUMBER;
      l_default_approver_id  NUMBER;
      l_default_person_id    NUMBER;
      l_partner_id           NUMBER;
      l_default_appr         VARCHAR2(60);
      x_role_name            VARCHAR2(320);
      x_role_display_name    VARCHAR2(360);
      l_display_name         VARCHAR2(360);

      CURSOR approver_dtl_cur (p_enrl_req_id number, p_person_id NUMBER,p_user_id NUMBER) IS
      SELECT object_version_number,entity_approver_id,approver_id,approver_type_code
      FROM   pv_ge_temp_approvers
      WHERE  appr_for_entity_id=p_enrl_req_id
      AND    APPROVER_ID = DECODE( APPROVER_TYPE_CODE,'PERSON',p_person_id,'USER',p_user_id,null )
      AND    ARC_APPR_FOR_ENTITY_CODE='ENRQ';

      CURSOR enrq_dtl_cur (p_enrl_req_id number) IS
      SELECT object_version_number, partner_id
      FROM pv_pg_enrl_requests
      WHERE enrl_request_id=p_enrl_req_id;

      CURSOR c_resource_per_cur(p_appr_id NUMBER) IS
      SELECT res.resource_id,res.resource_name
      FROM   jtf_rs_resource_extns_vl res,fnd_user fnd
      WHERE  fnd.employee_id = p_appr_id
      AND    res.user_id=fnd.user_id;

      CURSOR c_resource_usr_cur(p_appr_id NUMBER) IS
      SELECT res.resource_id,res.resource_name
      FROM   jtf_rs_resource_extns_vl res,fnd_user fnd
      WHERE  fnd.user_id = p_appr_id
      AND    res.user_id=fnd.user_id;

      CURSOR person_id_csr ( p_user_id NUMBER ) IS
      SELECT person_id ,full_name
      FROM   per_all_people_f per
             , FND_USER  usr
      WHERE  user_id=p_user_id
      AND    usr.person_party_id=per.party_id;

   BEGIN
      -- call AME api to get the next approver
      SAVEPOINT update_enrl_req_status;
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (   l_api_version_number
          , p_api_version_number
          , l_api_name
          , G_PKG_NAME
      )
      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )   THEN
         FND_MSG_PUB.initialize;
      END IF;
      PVX_UTILITY_PVT.debug_message('FND Global user id is'|| FND_GLOBAL.USER_ID );
      PVX_UTILITY_PVT.debug_message('FND Employee user id is'|| FND_GLOBAL.EMPLOYEE_ID );
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
         PVX_UTILITY_PVT.debug_message('FND Global user id is'|| FND_GLOBAL.USER_ID );
         PVX_UTILITY_PVT.debug_message('FND Employee user id is'|| FND_GLOBAL.EMPLOYEE_ID );
      END IF;
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      --RAISE FND_API.g_exc_error;
      g_approver_response:=approvalStatus;
      l_approverPersonId:= FND_GLOBAL.EMPLOYEE_ID;
      l_approverUserId:=  FND_GLOBAL.USER_ID;

      WF_DIRECTORY.getrolename
      (   p_orig_system         => 'PER'
          , p_orig_system_id    => l_approverPersonId
          , p_name              => x_role_name
          , p_display_name      => x_role_display_name
      );

      OPEN  enrq_dtl_cur (enrl_request_id);
         FETCH enrq_dtl_cur  into l_enrq_rec.object_version_number,l_partner_id;
      CLOSE enrq_dtl_cur;

      IF approvalStatus='APPROVED' THEN
         --check the profile value first whether the request can be approved without signing contract
         l_allow_appr_wo_contract  := FND_PROFILE.VALUE('PV_ALLOW_APPROVAL_WITHOUT_CONTRACT');
         IF l_allow_appr_wo_contract <> 'Y'  THEN
            l_contract_signed:=checkcontract_status(enrl_request_id);
            IF l_contract_signed =false THEN
                FND_MESSAGE.set_name('PV', 'PV_ENRQ_CONTRACT_NOT_SIGNED');
                FND_MSG_PUB.add;
                RAISE FND_API.G_EXC_ERROR;
             END IF;
         END IF;

         --check whther approver has checked alll the checklist items
         --depending on the flag set at the program level,raise error if they are not checked.
         l_checklistStatus:=checklist_status(enrl_request_id);
         IF l_checklistStatus=false THEN
             FND_MESSAGE.set_name('PV', 'PV_CHECKLIST_INCOMPLETE');
             --FND_MESSAGE.set_token ('CHECKLISTLINK', l_checklistlink, FALSE);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
         END IF;

         l_approvalStatus:=ame_util.approvedStatus;
         l_message_code  :='PV_ENR_REQ_APPROVED_BY_APPR';

         --update enrollments table with the start and end date
         l_enrq_rec.enrl_request_id:=enrl_request_id;
         l_enrq_rec.tentative_start_date:=start_date;
         l_enrq_rec.tentative_end_date:=end_date;

         PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests
         (   p_api_version_number      => 1.0
             , p_init_msg_list         => FND_API.g_false
             , p_commit                => FND_API.G_FALSE
             , p_validation_level      => FND_API.g_valid_level_full
             , x_return_status         => x_return_status
             , x_msg_count             => x_msg_count
             , x_msg_data              => x_msg_data
             , p_enrl_request_rec      => l_enrq_rec
         );
         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      ELSE
            l_approvalStatus:=ame_util.rejectStatus;
            l_message_code  :='PV_ENR_REQ_REJECTED';
      END IF;



      OPEN  approver_dtl_cur(enrl_request_id,l_approverPersonId, l_approverUserId);
         FETCH  approver_dtl_cur into l_approver_rec.object_version_number,
                                      l_approver_rec.entity_approver_id,
                                      l_approver_rec.approver_id,
                                      l_approver_rec.approver_type_code;
      CLOSE approver_dtl_cur;

      l_approver_rec.approval_status_code:= approvalStatus;

      -- PLEASE DO NOT ADD CODE HERE TO UPDATE TEMP APPROVERS TABLE WITH THE APPROVERS RESPONSE. IF YOU
      -- ADD ,IT WILL SCREW UP THE ENTIRE LOGIC. I HAVE ADDED CODED TO UPDATE TEMP APPROVERS TABLE WITH APPROVERS
      -- RESPONSE IN APPROPRIATE PLACES.Just before you call process_response you can update temp approvers table


      -- also log into enrollments log
      l_param_tbl_var(1).param_name := 'APPROVER_NAME';
      l_param_tbl_var(1).param_value := x_role_display_name;

      --write to enrollments log that xyz approver approved it or rejected it
      PVX_UTILITY_PVT.create_history_log
      (   p_arc_history_for_entity_code  => 'ENRQ'
          , p_history_for_entity_id       => enrl_request_id
          , p_history_category_code       => 'APPROVAL'
          , p_message_code                => l_message_code
          , p_comments                    => null
          , p_partner_id                  => l_partner_id
          , p_access_level_flag           => 'P'
          , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
          , p_log_params_tbl              => l_param_tbl_var
          , p_init_msg_list               => FND_API.g_false
          , p_commit                      => FND_API.G_FALSE
          , x_return_status               => x_return_status
          , x_msg_count                   => x_msg_count
          , x_msg_data                    => x_msg_data
      );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      l_checkrow_pending:=check_pending_default(enrl_request_id);
      -- the if block below updates OAM with the approval status . if the request
      -- was sent to default approver, OAM does not record that and we cannot update OAM in that case.

      IF l_checkrow_pending=false  THEN  --code if approver was returned by OAM
          /** check in oam whether the approver approving the request is in the list of approvers
             this could happen , if rules defined in OAM changes and thereby the list of approvers could change.
         */

         g_isApproverInList:=isApproverInList(enrl_request_id,l_approverPersonId);

         IF g_isApproverInList=true  THEN

            /** Following is required as we expect AME to return their new statuses. Bug # 4879218  **/
             ame_util2.detailedApprovalStatusFlagYN := ame_util.booleanTrue;

            ame_api2.updateApprovalStatus2
            (   applicationIdIn     => 691
                , transactionTypeIn => 'ENRQ'
                , transactionIdIn   => enrl_request_id
                , approvalStatusIn  => l_approvalStatus
                , approverNameIn    => x_role_name
                , itemClassIn       => null
                , itemIdIn          => null
                , actionTypeIdIn    => null
                , groupOrChainIdIn  => null
                , occurrenceIn      => null
                , forwardeeIn       => null
                , updateItemIn      => null
            );
            IF approvalStatus='APPROVED'  THEN

               submit_enrl_req_for_approval
               (   p_api_version_number
                   , p_init_msg_list
                   , FND_API.G_FALSE
                   , p_validation_level
                   , enrl_request_id
                   , 'ENRQ'
                   , x_return_status
                   , x_msg_count
                   , x_msg_data
               );
               IF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                  RAISE FND_API.g_exc_unexpected_error;
               END IF;
            ELSE
               -- means enrollment has been rejected
               Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
               (   p_api_version_number      => 1.0
                   , p_init_msg_list         => FND_API.g_false
                   , p_commit                => FND_API.g_false
                   , p_validation_level      => FND_API.g_valid_level_full
                   , x_return_status         => x_return_status
                   , x_msg_count             => x_msg_count
                   , x_msg_data              => x_msg_data
                   , p_approver_rec          =>l_approver_rec

               );
               IF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
               END IF;

               process_response
               (   enrl_request_id   => enrl_request_id
                   , approvalStatus  => approvalStatus
                   , x_return_status => x_return_status
                   , x_msg_count     => x_msg_count
                   , x_msg_data      => x_msg_data
               );
               IF x_return_status = FND_API.g_ret_sts_error THEN
                  RAISE FND_API.g_exc_error;
               ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                 RAISE FND_API.g_exc_unexpected_error;
               END IF;
            END IF;
         ELSE
            -- means current approver is not in the list of approvers anymore
            PVX_UTILITY_PVT.create_history_log
            (   p_arc_history_for_entity_code   => 'ENRQ'
                , p_history_for_entity_id       => enrl_request_id
                , p_history_category_code       => 'APPROVAL'
                , p_message_code                => 'PV_APPROVER_CHANGED'
                , p_comments                    => null
                , p_partner_id                  => l_partner_id
                , p_access_level_flag           => 'P'
                , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                , p_log_params_tbl              => l_param_tbl_var
                , p_init_msg_list               => FND_API.g_false
                , p_commit                      => FND_API.G_FALSE
                , x_return_status               => x_return_status
                , x_msg_count                   => x_msg_count
                , x_msg_data                    => x_msg_data
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
            submit_enrl_req_for_approval
            (   p_api_version_number
                , p_init_msg_list
                , FND_API.G_FALSE
                , p_validation_level
                , enrl_request_id
                , 'ENRQ'
                , x_return_status
                , x_msg_count
                , x_msg_data
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;
         --g_isApproverInList:=true;
      ELSE --code if approver is deafault approver
         l_default_approver_id:= isnumber(FND_PROFILE.VALUE('PV_ENRQ_DEFAULT_APPR'));
         IF ( l_default_approver_id is NULL ) THEN

            FND_MESSAGE.set_name('PV', 'PV_ENRQ_APPR_NOT_SET');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         OPEN person_id_csr (l_default_approver_id);
            FETCH  person_id_csr INTO l_default_person_id,l_display_name;
         CLOSE  person_id_csr;
         PVX_UTILITY_PVT.debug_message('FND l_default_person_id is'|| l_default_person_id );
         IF l_default_person_id=l_approverPersonId THEN
            --there is no need to call OAM if the request has gone to default approver
            /*PVX_UTILITY_PVT.create_history_log
            (   p_arc_history_for_entity_code   => 'ENRQ'
                , p_history_for_entity_id       => enrl_request_id
                , p_history_category_code       => 'APPROVAL'
                , p_message_code                => l_message_code
                , p_comments                    => null
                , p_partner_id                  => l_partner_id
                , p_access_level_flag           => 'P'
                , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                , p_log_params_tbl              => l_param_tbl_var
                , p_init_msg_list               => FND_API.g_false
                , p_commit                      => FND_API.G_FALSE
                , x_return_status               => x_return_status
                , x_msg_count                   => x_msg_count
                , x_msg_data                    => x_msg_data
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
            */
            Pv_Ge_Temp_Approvers_PVT.Update_Ptr_Enr_Temp_Appr
            (   p_api_version_number      => 1.0
                , p_init_msg_list         => FND_API.g_false
                , p_commit                => FND_API.g_false
                , p_validation_level      => FND_API.g_valid_level_full
                , x_return_status         => x_return_status
                , x_msg_count             => x_msg_count
                , x_msg_data              => x_msg_data
                , p_approver_rec          =>l_approver_rec
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;

            process_response
            (   enrl_request_id     => enrl_request_id
                , approvalStatus    => approvalStatus
                , x_return_status   => x_return_status
                , x_msg_count       => x_msg_count
                , x_msg_data        => x_msg_data
            );

            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         ELSE
            --write to the logs that the current approver for this enrollment request has changed
            PVX_UTILITY_PVT.create_history_log
            (    p_arc_history_for_entity_code   => 'ENRQ'
                 , p_history_for_entity_id       => enrl_request_id
                 , p_history_category_code       => 'APPROVAL'
                 , p_message_code                => 'PV_APPROVER_CHANGED'
                 , p_comments                    => null
                 , p_partner_id                  => l_partner_id
                 , p_access_level_flag           => 'P'
                 , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                 , p_log_params_tbl              => l_param_tbl_var
                 , p_init_msg_list               => FND_API.g_false
                 , p_commit                      => FND_API.G_FALSE
                 , x_return_status               => x_return_status
                 , x_msg_count                   => x_msg_count
                 , x_msg_data                    => x_msg_data
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
            submit_enrl_req_for_approval
            (   p_api_version_number
                , p_init_msg_list
                , FND_API.G_FALSE
                , p_validation_level
                , enrl_request_id
                , 'ENRQ'
                , x_return_status
                , x_msg_count
                , x_msg_data
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;
      END IF; -- end of  if else for approver is deafault approver
      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
      END IF;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK TO update_enrl_req_status;
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get
         (   p_encoded   => FND_API.G_FALSE
             , p_count   => x_msg_count
             , p_data    => x_msg_data
         );
         --write to enrollment log that an error has occured?. how do we handle the situation if an error occured in process
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         ROLLBACK TO update_enrl_req_status;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get
         (   p_encoded   => FND_API.G_FALSE
             , p_count   => x_msg_count
             , p_data    => x_msg_data
         );
      WHEN OTHERS THEN
         ROLLBACK TO update_enrl_req_status;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
         -- Standard call to get message count and if count=1, get the message
         FND_MSG_PUB.Count_And_Get
         (   p_encoded   => FND_API.G_FALSE
             , p_count   => x_msg_count
             , p_data    => x_msg_data
         );
   END update_enrl_req_status;


   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Process_errored_requests
   --
   -- PURPOSE
   --   Process the enrollment requests which are errored while finding next
   --   approver in OAM. This will be called by concurrent program.
   -- IN
   --   std. conc. request parameters.
   --   ERRBUF
   --   RETCODE
   -- OUT
   -- USED BY
   --   Concurrent program
   -- HISTORY
   --   12/04/2002        sveerave        CREATION
   --------------------------------------------------------------------------


PROCEDURE Process_errored_requests(
  ERRBUF                OUT NOCOPY VARCHAR2,
  RETCODE               OUT NOCOPY VARCHAR2 )
  IS
  /* Get all the errored enrollment requests. */
    CURSOR c_get_errored_requests IS
      SELECT appr.appr_for_entity_id, appr.arc_appr_for_entity_code
      FROM pv_ge_temp_approvers appr
      WHERE appr.approval_status_code = 'ERROR'
        AND appr.arc_appr_for_entity_code = 'ENRQ';
  -- local variables
  l_enrl_request_id NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count   NUMBER;
  l_msg_data      VARCHAR2(240);

BEGIN
  /*  Standard Start of API savepoint */
  SAVEPOINT Process_errored_requests;
  /* Logic to update the membership status to EXPIRE for all the EXPIRED members */
  FOR l_get_errored_requests_rec IN c_get_errored_requests LOOP
    l_enrl_request_id := l_get_errored_requests_rec.appr_for_entity_id;
    Write_log (1, 'Processing enrollment request id: '|| l_enrl_request_id);
    submit_enrl_req_for_approval(
      p_api_version_number  => 1.0
     ,p_init_msg_list       => FND_API.G_FALSE
     ,p_commit              => FND_API.G_FALSE
     ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
     ,enrl_request_id       => l_get_errored_requests_rec.appr_for_entity_id
     ,entity_code           => l_get_errored_requests_rec.arc_appr_for_entity_code
     ,x_return_status       => l_return_status
     ,x_msg_count           => l_msg_count
     ,x_msg_data            => l_msg_data );
    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;

  -- return the success code.
  retcode := '0';

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ERRBUF := ERRBUF || sqlerrm;
    RETCODE := '1';
    ROLLBACK TO Process_errored_requests;
    --l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    Write_log (1, 'Error in submitting the enrollment request id of '|| l_enrl_request_id ||' for approval');
    Write_log (1, 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100));
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ERRBUF := ERRBUF||sqlerrm;
    RETCODE := '1';
    ROLLBACK TO Process_errored_requests;
    --l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    Write_log (1, 'Unexpected Error in submitting the enrollment request id of '|| l_enrl_request_id ||' for approval');
    Write_log (1, 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100));
  WHEN OTHERS THEN
    ERRBUF := ERRBUF||sqlerrm;
    RETCODE := '2';
    ROLLBACK TO Process_errored_requests;
    --l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    Write_log (1, 'Other Exception in running the conc. program for processing the errored enrollment requests');
    Write_log (1, 'SQLCODE ' || to_char(SQLCODE) || ' SQLERRM ' || substr(SQLERRM, 1, 100));

END Process_errored_requests;

 --------------------------------------------------------------------------
   -- PROCEDURE
   --   terminate_downgrade_memb
   --
   -- PURPOSE
   --   called when user clicks upgrade or terminate
   --
   -- HISTORY
   --   10/04/2002        pukken        CREATION
   --------------------------------------------------------------------------


PROCEDURE terminate_downgrade_memb(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_membership_id              IN   NUMBER
   ,p_event_code                 IN   VARCHAR2 -- pass 'TERMINATED' or 'DOWNGRADED' depending on the event
   ,p_status_reason_code         IN   VARCHAR2 -- reason for termoination or downgrade
   ,p_comments                   IN   VARCHAR2 DEFAULT NULL
   ,p_program_id_downgraded_to   IN   NUMBER   --programid into which the partner is downgraded to.
   ,p_requestor_resource_id      IN   NUMBER   --resource_id of the user who's performing the action
   ,p_new_memb_id                OUT NOCOPY  NUMBER
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2) IS

   l_pv_pg_memb_rec     PV_Pg_Memberships_PVT.memb_rec_type;
   l_pv_pg_new_memb_rec PV_Pg_Memberships_PVT.memb_rec_type;
   l_pv_pg_enrq_rec     PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
   l_mmbr_tran_rec      pv_pg_mmbr_transitions_PVT.mmbr_tran_rec_type;
   l_partner_id         NUMBER;
   l_enrl_request_id    NUMBER;
   l_membership_id      NUMBER;
   l_original_end_date  DATE;
   l_mmbr_transition_id NUMBER;
   l_message_code       VARCHAR2(30);
   l_param_tbl_var      PVX_UTILITY_PVT.log_params_tbl_type;
   l_api_name           CONSTANT VARCHAR2(30) := 'terminate_downgrade_memb';
   l_api_version_number CONSTANT NUMBER       := 1.0;
   l_memb_active        BOOLEAN:=false;
   l_program_name       VARCHAR2(60);
   l_custom_setup_id    NUMBER;

   CURSOR membership_csr(p_memb_id NUMBER) IS
   SELECT memb.object_version_number,memb.partner_id,memb.original_end_date,enrq.custom_setup_id
   FROM   pv_pg_memberships memb,pv_pg_enrl_requests enrq
   WHERE  memb.membership_id=p_memb_id
   AND    memb.enrl_request_id=enrq.enrl_request_id;

   CURSOR program_name_csr(p_prgm_id NUMBER) IS
   SELECT program_name
   FROM   pv_partner_program_tl
   WHERE  program_id=p_prgm_id;


   BEGIN
      SAVEPOINT terminate_downgrade_memb;
       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number
                                          ,p_api_version_number
                                          ,l_api_name
                                          ,G_PKG_NAME
                                         )

      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
         RAISE FND_API.G_EXC_ERROR;
      END IF;




      -- update membership record  and call responsiblity management
      -- set the membership record to be updated
      l_pv_pg_memb_rec.membership_id:=p_membership_id;
      l_pv_pg_memb_rec.actual_end_date:=sysdate;
      l_pv_pg_memb_rec.membership_status_code:=p_event_code;
      l_pv_pg_memb_rec.status_reason_code:=p_status_reason_code;

      OPEN membership_csr(p_membership_id);
         FETCH membership_csr INTO l_pv_pg_memb_rec.object_version_number,l_partner_id,l_original_end_date,l_custom_setup_id;
      CLOSE membership_csr;


      PV_Pg_Memberships_PVT.Update_Pg_Memberships
      (    p_api_version_number    => 1.0
          ,p_init_msg_list         => Fnd_Api.g_false
          ,p_commit                => Fnd_Api.g_false
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
          ,p_memb_rec              => l_pv_pg_memb_rec
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      Pv_User_Resp_Pvt.manage_memb_resp
      (    p_api_version_number    => 1.0
          ,p_init_msg_list         => Fnd_Api.g_false
          ,p_commit                => Fnd_Api.g_false
          ,p_membership_id         => p_membership_id
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      p_new_memb_id:=null;

      IF p_event_code='DOWNGRADED' THEN

         --set message code for history logs
         l_message_code:='PV_MEMBERSHIP_DOWNGRADED';

          --create an enrollment request with approved status
         l_pv_pg_enrq_rec.partner_id:=l_partner_id;
         l_pv_pg_enrq_rec.program_id:=p_program_id_downgraded_to;
         l_pv_pg_enrq_rec.requestor_resource_id:= p_requestor_resource_id;
         l_pv_pg_enrq_rec.request_status_code:='APPROVED';
         l_pv_pg_enrq_rec.enrollment_type_code:='DOWNGRADE';
         l_pv_pg_enrq_rec.payment_status_code:='NOT_SUBMITTED';

         l_pv_pg_enrq_rec.request_submission_date:=sysdate;
         l_pv_pg_enrq_rec.request_initiated_by_code:='VENDOR';
         l_pv_pg_enrq_rec.contract_status_code:='NOT_SIGNED';
         l_pv_pg_enrq_rec.custom_setup_id:=getCustomSetupID(p_program_id_downgraded_to);

         PV_Pg_Enrl_Requests_PVT.Create_Pg_Enrl_Requests
         (    p_api_version_number  =>1.0
             ,p_init_msg_list       => FND_API.g_false
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => FND_API.g_valid_level_full
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,p_enrl_request_rec    => l_pv_pg_enrq_rec
             ,x_enrl_request_id     => l_enrl_request_id
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;


         --create a membership record with the downgraded program id and end date of the program from which it was
         --downgraded
         l_pv_pg_new_memb_rec.enrl_request_id:=l_enrl_request_id;
         l_pv_pg_new_memb_rec.start_date:=sysdate;
         l_pv_pg_new_memb_rec.original_end_date:=l_original_end_date;
         l_pv_pg_new_memb_rec.membership_status_code:='ACTIVE';
         l_pv_pg_new_memb_rec.partner_id:=l_partner_id;
         l_pv_pg_new_memb_rec.program_id:=p_program_id_downgraded_to;

         PV_Pg_Memberships_PVT.Create_Pg_memberships
         (    p_api_version_number=>1.0
             ,p_init_msg_list       => FND_API.g_false
             ,p_commit              => FND_API.G_FALSE
             ,p_validation_level    => FND_API.g_valid_level_full
             ,x_return_status       => x_return_status
             ,x_msg_count           => x_msg_count
             ,x_msg_data            => x_msg_data
             ,p_memb_rec            => l_pv_pg_new_memb_rec
             ,x_membership_id       => l_membership_id
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         p_new_memb_id :=l_membership_id;
         --insert into member transitions table
         l_mmbr_tran_rec.from_membership_id:=p_membership_id;
         l_mmbr_tran_rec.to_membership_id:=l_membership_id;
         pv_pg_mmbr_transitions_PVT.Create_Mmbr_Trans
         (    p_api_version_number       =>1.0
             ,p_init_msg_list            => FND_API.g_false
             ,p_commit                   => FND_API.G_FALSE
             ,p_validation_level         => FND_API.g_valid_level_full
             ,x_return_status            => x_return_status
             ,x_msg_count                => x_msg_count
             ,x_msg_data                 => x_msg_data
             ,p_mmbr_tran_rec            => l_mmbr_tran_rec
             ,x_mmbr_transition_id       => l_mmbr_transition_id
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

          --call responsiblity management api for the new membership
         Pv_User_Resp_Pvt.manage_memb_resp
         (    p_api_version_number    => 1.0
             ,p_init_msg_list         => Fnd_Api.g_false
             ,p_commit                => Fnd_Api.g_false
             ,p_membership_id         => l_membership_id
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      ELSIF p_event_code='TERMINATED' THEN
         --set message code for history logs
         l_message_code:='PV_MEMBERSHIP_TERMINATED';
      END IF;

      --call the history log api to capture any comments from the user
      PVX_UTILITY_PVT.create_history_log
             (    p_arc_history_for_entity_code => 'ENRQ'
                  ,p_history_for_entity_id       => l_enrl_request_id
                  ,p_history_category_code       => 'APPROVAL'
                  ,p_message_code                => l_message_code
                  ,p_comments                    => null
                  ,p_partner_id                  => l_partner_id
                  ,p_access_level_flag           => 'P'
                  ,p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
                  ,p_log_params_tbl              => l_param_tbl_var
                  ,p_init_msg_list               => FND_API.g_false
                  ,p_commit                      => FND_API.G_FALSE
                  ,x_return_status               => x_return_status
                  ,x_msg_count                   => x_msg_count
                  ,x_msg_data                     => x_msg_data
              );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;


       -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
     (    p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
     );

   EXCEPTION

      WHEN PVX_UTILITY_PVT.resource_locked THEN
        x_return_status := FND_API.g_ret_sts_error;
            PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO terminate_downgrade_memb;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => x_msg_count,
               p_data    => x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO terminate_downgrade_memb;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
        );

      WHEN OTHERS THEN
        ROLLBACK TO terminate_downgrade_memb;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
        );
End terminate_downgrade_memb;

--------------------------------------------------------------------------
   -- PROCEDURE
   --   Create_Default_Membership
   --
   -- PURPOSE
   --     Create membership into a default program . This is called when new partner is created
   -- IN
   --   p_partner_id - partner_id of the partner
   --   p_requestor_resource_id- resource_id of the user who's performing the action
   -- USED BY
   --   User Management while creating new partner
   -- HISTORY
   --   05-June-2003        pukken        CREATION
   --------------------------------------------------------------------------

PROCEDURE Create_Default_Membership (
      p_api_version_number   IN   NUMBER
     ,p_init_msg_list               IN   VARCHAR2     := FND_API.G_FALSE
     ,p_commit                        IN   VARCHAR2     := FND_API.G_FALSE
     ,p_validation_level          IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
     ,p_partner_id                       IN   NUMBER
     ,p_requestor_resource_id      IN   NUMBER   --resource_id of the user who's performing the action
     ,x_return_status               OUT NOCOPY  VARCHAR2
     ,x_msg_count                  OUT NOCOPY  NUMBER
     ,x_msg_data                    OUT NOCOPY  VARCHAR2
) IS

   pv_pg_memb_rec     PV_Pg_Memberships_PVT.memb_rec_type;
   l_pv_pg_enrq_rec   PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
   l_api_name         CONSTANT VARCHAR2(30) := 'Create_Default_Membership';
   l_full_name        CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number   CONSTANT NUMBER       := 1.0;
   l_membership_id        NUMBER;
   l_entity_approver_id   NUMBER;
   l_enrl_request_id      NUMBER;
   l_default_program_id   NUMBER:=null;
   l_param_tbl_var      PVX_UTILITY_PVT.log_params_tbl_type;
   --This value for l_default_approver_id needs to be retrieved from profile
   l_isPrimaryFlag     VARCHAR2(1);
   l_program_name      VARCHAR2(60);

   CURSOR isPrimaryExist ( ptr_id IN NUMBER ) IS
   SELECT 'Y'
   FROM dual
   WHERE EXISTS
   (
       SELECT 	user_id
       FROM 	pv_partner_primary_users_v
       WHERE   partner_id = ptr_id
   );

   CURSOR c_program_csr( prgm_id IN NUMBER ) IS
   SELECT program_name
   FROM   pv_partner_program_vl
   WHERE  program_id=prgm_id;

   BEGIN
      SAVEPOINT Create_Default_Membership;
       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number
                                          ,p_api_version_number
                                          ,l_api_name
                                          ,G_PKG_NAME
                                         )

      THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --create an enrollment request with approved status

      l_default_program_id:= isnumber(FND_PROFILE.VALUE('PV_PARTNER_DEFAULT_PROGRAM'));
      IF l_default_program_id is NOT NULL THEN
         l_pv_pg_enrq_rec.partner_id:=p_partner_id;
         l_pv_pg_enrq_rec.program_id:= l_default_program_id;
         l_pv_pg_enrq_rec.requestor_resource_id:=p_requestor_resource_id;
         l_pv_pg_enrq_rec.request_status_code:='APPROVED';
         l_pv_pg_enrq_rec.enrollment_type_code:='NEW';
         l_pv_pg_enrq_rec.request_submission_date:=sysdate;
         l_pv_pg_enrq_rec.request_initiated_by_code:='DEFAULT_ENROLLMENT';
         l_pv_pg_enrq_rec.contract_status_code:='NOT_SIGNED';
         l_pv_pg_enrq_rec.payment_status_code:='NOT_SUBMITTED';
         l_pv_pg_enrq_rec.custom_setup_id:= getCustomSetupID(l_default_program_id);

         PV_Pg_Enrl_Requests_PVT.Create_Pg_Enrl_Requests
         (    p_api_version_number  =>1.0
              ,p_init_msg_list       => FND_API.g_false
              ,p_commit              => FND_API.G_FALSE
              ,p_validation_level    => FND_API.g_valid_level_full
              ,x_return_status       => x_return_status
              ,x_msg_count           => x_msg_count
              ,x_msg_data            => x_msg_data
              ,p_enrl_request_rec    => l_pv_pg_enrq_rec
              ,x_enrl_request_id     => l_enrl_request_id
          );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;


         --create a membership record with the default program id and grant all the benefits and ----responibilities associated with this program.
         pv_pg_memb_rec.enrl_request_id:=l_enrl_request_id;

         setmembershipdetails(  pv_pg_memb_rec   =>  pv_pg_memb_rec
                               ,x_return_status   =>x_return_status
                               ,x_msg_count       =>x_msg_count
                               ,x_msg_data        =>x_msg_data
                             );

         PV_Pg_Memberships_PVT.Create_Pg_memberships
         (
                       p_api_version_number=>1.0
                      ,p_init_msg_list       => FND_API.g_false
                      ,p_commit              => FND_API.G_FALSE
                      ,p_validation_level    => FND_API.g_valid_level_full
                      ,x_return_status       => x_return_status
                      ,x_msg_count           => x_msg_count
                      ,x_msg_data            => x_msg_data
                      ,p_memb_rec            => pv_pg_memb_rec
                      ,x_membership_id       => l_membership_id
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- call responsiblity management api.

         Pv_User_Resp_Pvt.manage_memb_resp
               (    p_api_version_number    => 1.0
                   ,p_init_msg_list         => Fnd_Api.g_false
                   ,p_commit                => Fnd_Api.g_false
                   ,p_membership_id         => l_membership_id
                   ,x_return_status         => x_return_status
                   ,x_msg_count             => x_msg_count
                   ,x_msg_data              => x_msg_data
               );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         OPEN c_program_csr( l_default_program_id );
            FETCH c_program_csr INTO l_program_name;
         CLOSE c_program_csr;

         --call the history log api to capture any comments from the user
         l_param_tbl_var(1).param_name := 'PROGRAM_NAME';
         l_param_tbl_var(1).param_value := l_program_name;

         PVX_UTILITY_PVT.create_history_log
         (    p_arc_history_for_entity_code  => 'MEMBERSHIP'
              ,p_history_for_entity_id       => l_enrl_request_id
              ,p_history_category_code       => 'APPROVAL'
              ,p_message_code                => 'PV_DEFAULT_MEMBERSHIP'
              ,p_comments                    => null
              ,p_partner_id                  => p_partner_id
              ,p_access_level_flag           => 'P'
              ,p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
              ,p_log_params_tbl              => l_param_tbl_var
              ,p_init_msg_list               => FND_API.g_false
              ,p_commit                      => FND_API.G_FALSE
              ,x_return_status               => x_return_status
              ,x_msg_count                   => x_msg_count
              ,x_msg_data                    => x_msg_data
          );

          -- calling the new workflow process in 11.5.10 pukken
          -- call workflow notification only if atleast one primary user exit

          OPEN isPrimaryExist( p_partner_id );
             FETCH isPrimaryExist INTO l_isPrimaryFlag;
          ClOSE isPrimaryExist;

          IF l_isPrimaryFlag= 'Y' THEN
             PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
             (
                p_api_version_number    => 1.0
                , p_init_msg_list       => Fnd_Api.g_false
                , p_commit              => Fnd_Api.g_false
                , p_validation_level    => FND_API.g_valid_level_full
                , p_context_id          => p_partner_id
    	         , p_context_code        => 'PARTNER'
                , p_target_ctgry        => 'PARTNER'
                , p_target_ctgry_pt_id  => p_partner_id
                , p_notif_event_code    => 'PG_WELCOME'
                , p_entity_id           => l_enrl_request_id
    	        , p_entity_code         => 'ENRQ'
                , p_wait_time           => 0
                , x_return_status       => x_return_status
                , x_msg_count           => x_msg_count
                , x_msg_data            => x_msg_data
             );


            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

     END IF;
   -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit ) THEN
          COMMIT WORK;
      END IF;

EXCEPTION


      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Create_Default_Membership;
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count   => x_msg_count,
               p_data    => x_msg_data
        );

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_Default_Membership;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
        );

      WHEN OTHERS THEN
        ROLLBACK TO Create_Default_Membership;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
               p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
        );

End Create_Default_Membership;

---------------------------------------------------------------------
   -- PURPOSE
   --     1.Send thank you notification if enrollment is submiited for approval.
   --     2.Send other required notifications , which are
   --       a)  If member type is Subsidiary, then sent to global partner about subsidiaries enrolllment( sent to global)
   --       b)  IMP applies for membership into Partner Program (sent to VAD) if VAD invited IMP for this enrollment
   -- HISTORY
   --  31-Oct-2003        pukken        CREATION

PROCEDURE send_notifications
(
   p_api_version_number           IN   NUMBER
   , p_init_msg_list              IN   VARCHAR2  := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2  := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER    := FND_API.G_VALID_LEVEL_FULL
   , p_partner_id                 IN   NUMBER
   , p_enrl_request_id            IN   NUMBER    -- enrollment request id
   , p_memb_type                  IN   VARCHAR2  -- member type of the partner
   , p_enrq_status                IN   VARCHAR2  -- enrollment_status pass 'AWAITING_APPROVAL' incase submitting for approval
   , x_return_status              OUT  NOCOPY  VARCHAR2
   , x_msg_count                  OUT  NOCOPY  NUMBER
   , x_msg_data                   OUT  NOCOPY  VARCHAR2
)
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'send_notifications';
   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_memb_type              VARCHAR2(30);
   l_global_partner_id      NUMBER;
   l_notif_event_code       VARCHAR2(30);
   l_context_code           VARCHAR2(30);
   l_vad_ptr_id              NUMBER;
   l_lookup_exists           VARCHAR2(1);
   CURSOR c_vad_csr(enrl_id IN NUMBER ) IS
   SELECT invite.invited_by_partner_id
   FROM   pv_pg_invite_headers_b invite
          , pv_pg_enrl_requests enrq
   WHERE  enrq.enrl_request_id=enrl_id
   AND    enrq.invite_header_id=invite.invite_header_id;

   CURSOR  c_memb_type_csr(ptr_id NUMBER) IS
   SELECT  enty.attr_value
   FROM    pv_enty_attr_values enty
   WHERE   enty.entity = 'PARTNER'
   AND     enty.entity_id = ptr_id
   AND     enty.attribute_id = 6
   AND     enty.latest_flag = 'Y';

   CURSOR c_get_global_csr ( p_subs_partner_id IN NUMBER ) IS
   SELECT global_prof.partner_id
   FROM   pv_partner_profiles global_prof
          , pv_partner_profiles subs_prof
          , hz_relationships rel
   WHERE  subs_prof.partner_party_id=rel.subject_id
   AND    rel.relationship_code = 'SUBSIDIARY_OF'
   AND    rel.relationship_type = 'PARTNER_HIERARCHY'
   AND    rel.status = 'A'
   AND    NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND    NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND   subs_prof.partner_id=p_subs_partner_id
   AND   rel.object_id=global_prof.partner_party_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  send_notifications ;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
   (   l_api_version_number
       ,p_api_version_number
       ,l_api_name
       ,G_PKG_NAME
   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message
   PVX_UTILITY_PVT.debug_message( 'Private API: ' || l_api_name || 'start' );
   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Validate Environment
   IF FND_GLOBAL.USER_ID IS NULL   THEN
      PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

     --validate the lookupcode for target category
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type       => 'PV_ENRQ_REQUEST_STATUS_CODE'
                         ,p_lookup_code       => p_enrq_status
                       );

   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE','PV_ENRQ_REQUEST_STATUS_CODE' );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_enrq_status  );
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- send thank you notifictaion
   IF p_enrq_status ='AWAITING_APPROVAL' THEN
      PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
      (
         p_api_version_number    => p_api_version_number
         , p_init_msg_list       => p_init_msg_list
         , p_commit              => p_commit
         , p_validation_level    => p_validation_level
         , p_context_id          => p_partner_id
         , p_context_code        => 'PARTNER'
         , p_target_ctgry        => 'PARTNER'
         , p_target_ctgry_pt_id  => p_partner_id
         , p_notif_event_code    => 'PG_THANKYOU'
         , p_entity_id           => p_enrl_request_id
         , p_entity_code         => 'ENRQ'
         , p_wait_time           => 0
         , x_return_status       => x_return_status
         , x_msg_count           => x_msg_count
         , x_msg_data            => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   l_memb_type := p_memb_type;
   IF l_memb_type IS NULL THEN
      OPEN c_memb_type_csr(p_partner_id);
         FETCH c_memb_type_csr INTO l_memb_type;
      CLOSE c_memb_type_csr;
   END IF;

   IF l_memb_type = 'SUBSIDIARY' THEN
      OPEN c_get_global_csr( p_partner_id );
         FETCH  c_get_global_csr INTO l_global_partner_id;
      CLOSE  c_get_global_csr;
      -- send notification to the global partner

      IF p_enrq_status IN ( 'APPROVED', 'REJECTED' ) THEN
          l_notif_event_code := 'SUBSIDIARY_PTNR_ENROLL';
          l_context_code := p_enrq_status;
      ELSIF  p_enrq_status = 'AWAITING_APPROVAL' THEN
          l_notif_event_code := 'SUBSIDIARY_PTNR_APPLY';
          l_context_code := 'PARTNER';
      END IF;
      PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
      (
         p_api_version_number    => 1.0
         , p_init_msg_list       => FND_API.G_FALSE
         , p_commit              => FND_API.G_FALSE
         , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         , p_context_id          => p_partner_id --this should be subsidiary partner_id.
         , p_context_code        => l_context_code
         , p_target_ctgry        => 'GLOBAL'
         , p_target_ctgry_pt_id  => l_global_partner_id -- this should be global partner id
         , p_notif_event_code    => l_notif_event_code
         , p_entity_id           => p_enrl_request_id
         , p_entity_code         => 'ENRQ'
         , p_wait_time           => 0
         , x_return_status       => x_return_status
         , x_msg_count           => x_msg_count
         , x_msg_data            => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   END IF;
   -- also need to make a call to send notifictaion to VAD incase this enrollment is beacuse of VAD inviation
   -- pass notifp_notif_event_code    => 'IMP_APPLY' if its apply
   -- pass notifp_notif_event_code   => 'IMP_ACCEPTED'if its application has been accepted

   OPEN c_vad_csr(p_enrl_request_id);
      FETCH   c_vad_csr INTO l_vad_ptr_id  ;
   CLOSE c_vad_csr;

   IF l_vad_ptr_id IS NOT NULL AND  p_enrq_status IN ('APPROVED','AWAITING_APPROVAL') THEN
       IF p_enrq_status ='APPROVED' THEN
          l_notif_event_code := 'IMP_ACCEPTED';
       ELSIF  p_enrq_status = 'AWAITING_APPROVAL' THEN
           l_notif_event_code := 'IMP_APPLY';
       END IF;
       PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
      (
         p_api_version_number    => 1.0
         , p_init_msg_list       => FND_API.G_FALSE
         , p_commit              => FND_API.G_FALSE
         , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         , p_context_id          => p_partner_id --this should be partner_id.
         , p_context_code        => 'PARTNER'
         , p_target_ctgry        => 'VAD'
         , p_target_ctgry_pt_id  => l_vad_ptr_id -- this should be VAD PARTNER ID
         , p_notif_event_code    => l_notif_event_code
         , p_entity_id           => p_enrl_request_id
         , p_entity_code         => 'ENRQ'
         , p_wait_time           => 0
         , x_return_status       => x_return_status
         , x_msg_count           => x_msg_count
         , x_msg_data            => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   -- Debug Message
   PVX_UTILITY_PVT.debug_message( 'Private API: ' || l_api_name || 'end' );
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (
      p_count      =>   x_msg_count
      , p_data     =>   x_msg_data
   );
   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO  send_notifications;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO  send_notifications;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

   WHEN OTHERS THEN
   ROLLBACK TO  send_notifications;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
   END IF;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );
END send_notifications;

END pv_prgm_approval_pvt;

/
