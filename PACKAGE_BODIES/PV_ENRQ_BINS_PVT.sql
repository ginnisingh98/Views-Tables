--------------------------------------------------------
--  DDL for Package Body PV_ENRQ_BINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENRQ_BINS_PVT" as
   /* $Header: pvxvbinb.pls 120.5 2006/05/11 11:54:47 dgottlie ship $*/
   --  Start of Comments
   --
   -- NAME
   --   Pv_Enrq_Bins_PVT
   --
   -- PURPOSE
   --   This package contains  API's for displaying data in program enrollment bins.
      --
   -- HISTORY
   --   11/12/2002        pukken          CREATION
   --   08/01/2003        pukken  changed the API for 11.15.10 changes
   --   18-FEB-2004       pukken  fix for bug 3443733
   --   15-jun-2004       pukken  fix for bug 3695436
   --   04-MAR-2005       pukken to develop ER 4208712
   --   22-NOV-2005       ktsao   fix for bug 4749395
   --   18-JAN-2006       ktsao   fix for bug 4948563
   --   28-MAR-2006       ktsao   fix for bug 5116650
   -- NOTE        :
   -- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
   --                          All rights reserved.

   g_pkg_name    CONSTANT VARCHAR2 (30) := 'Pv_Enrq_Bins_PVT';
   g_file_name   CONSTANT VARCHAR2 (15) := 'pvxvbinb.pls';
   g_program_mode   CONSTANT VARCHAR2 (15) := 'BINS';

   PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
   PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
   PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


FUNCTION getInviteHeaderId(p_partner_id in number,p_program_id in NUMBER,p_invite_type_code in VARCHAR2)
RETURN NUMBER is
   l_invite_header_id NUMBER:=null ;

   CURSOR rec_cur(p_ptr_id number,p_prgm_id number,p_inv_type_code VARCHAR2) IS
   SELECT max(invite_header_id)
   FROM   PV_PG_INVITE_HEADERS_b
   WHERE  partner_id=p_ptr_id
   AND    nvl(invite_end_date,sysdate+1)>sysdate
   AND    invite_for_program_id =p_prgm_id
   AND    invite_type_code =p_inv_type_code;



BEGIN
   OPEN rec_cur(p_partner_id,p_program_id,p_invite_type_code);
      FETCH rec_cur into l_invite_header_id;
   CLOSE rec_cur;
   RETURN  l_invite_header_id;

EXCEPTION

   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END getInviteHeaderId;


--------------------------------------------------------------------------
   -- FUNCTION
   --   isGlobalEnrolled
   --
   -- PURPOSE
   --   To check whether the global partner of the given subsidiary partner has active or future membership
   --   In a given program or in the upgrade path of the given program
   -- IN
   --   p_program_id       NUMBER
   --   p_subs_partner_id  NUMBER  this should be subsidiary partner Id
   -- OUT
   --     is a boolean value

FUNCTION isGlobalEnrolled(p_program_id in NUMBER, p_subs_partner_id in number)
RETURN BOOLEAN IS

   CURSOR isenroll_csr(p_prgm_id NUMBER,p_global_ptr_id NUMBER) IS
   Select 'X' from dual
   WHERE EXISTS
   (
      select membership_id from pv_pg_memberships
      where membership_status_code in ('ACTIVE','FUTURE')
      AND  partner_id=p_global_ptr_id
      AND program_id IN
      (
         select CHANGE_to_program_id from pv_pg_enrl_change_rules
         where change_direction_code='UPGRADE'
         AND  ACTIVE_FLAG='Y'
         START with  change_from_program_id=p_prgm_id
         CONNECT by CHANGE_FROM_PROGRAM_id=PRIOR CHANGE_to_program_id
         and CHANGE_TO_PROGRAM_ID<>PRIOR CHANGE_FROM_PROGRAM_Id
         union select p_prgm_id FROM DUAL
       )
   );


   CURSOR global_id_csr(p_sub_ptr_id NUMBER) IS
   SELECT   glob_prof.partner_id
   FROM     pv_partner_profiles subs_prof
           ,pv_partner_profiles glob_prof
           ,hz_relationships rel
   WHERE  rel.subject_id=subs_prof.partner_party_id
   AND    rel.relationship_code = 'SUBSIDIARY_OF'
   AND    rel.relationship_type = 'PARTNER_HIERARCHY'
   AND    rel.status = 'A'
   AND    NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND    NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND    subs_prof.partner_id=p_sub_ptr_id
   AND    REL.OBJECT_ID=glob_prof.partner_party_id;

   l_global_ptr_id NUMBER;
   l_global_enrolled VARCHAR2(1);
   is_global_enrolled boolean:=false;

BEGIN


   OPEN global_id_csr(p_subs_partner_id);
      FETCH global_id_csr INTO l_global_ptr_id;
   CLOSE global_id_csr;

   IF  l_global_ptr_id IS NOT NULL THEN

      OPEN isenroll_csr(p_program_id,l_global_ptr_id);
         FETCH isenroll_csr INTO l_global_enrolled;
      CLOSE isenroll_csr;

      IF l_global_enrolled='X' THEN

         is_global_enrolled:=true;
      END IF;
   END IF;
   RETURN is_global_enrolled;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END isGlobalEnrolled;

PROCEDURE new_programs
(
   p_api_version_number          IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2
   ,p_isprereq_eval              IN   VARCHAR2     :='Y'
   ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
) IS


   CURSOR prgm_csr(ptnr_id IN NUMBER) IS
   SELECT pvppb.program_id program_id
          ,pvppb.program_name program_name
          ,pvppb.citem_version_id citem_version_id
          ,pvppb.global_mmbr_reqd_flag global_mmbr_reqd_flag
          ,pvppb.prereq_process_rule_id prereq_process_rule_id
          ,pvppb.no_fee_flag no_fee_flag
          ,pvppb.vad_invite_allow_flag vad_invite_allow_flag
   FROM   pv_partner_program_type_b pvpptb
          ,pv_partner_program_vl pvppb
   WHERE  pvppb.program_status_code = 'ACTIVE'
   AND    pvppb.program_level_code ='MEMBERSHIP'
   AND    pvppb.enabled_flag = 'Y'
   AND    nvl(pvppb.allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID
   AND    pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   -- AND    inv.invite_type_code(+)='INVITE'
   AND    EXISTS
          (
             SELECT 'X' FROM pv_program_partner_types pvppt
             WHERE pvppt.partner_type IN
             (
                SELECT attr_value
                FROM   pv_enty_attr_values pveav
                WHERE  pveav.enabled_flag = 'Y'
                AND pveav.latest_flag = 'Y'
                AND pveav.entity = 'PARTNER'
                AND pveav.entity_id =  ptnr_id
                AND pveav.attribute_id = 3
             )
	     AND    pvpptb.program_type_id = pvppt.program_type_id
          )
   AND    pvppb.program_id NOT IN
          (
             SELECT rules.change_to_program_id
             FROM   pv_pg_enrl_change_rules rules
             WHERE  change_direction_code = 'UPGRADE'
             AND    effective_from_date <= sysdate
             AND    nvl(effective_to_date, sysdate) >= sysdate
             AND    active_flag = 'Y'
          )
    /* AND   EXISTS -- check for pre-populated cache for pre-req evaluation
        ( SELECT 1
          FROM pv_pg_elig_programs elig
          WHERE elig.program_id = pvppb.program_id
          AND elig.partner_id = ptnr_id
        ) */
   	;


   CURSOR enrl_csr(ptr_id NUMBER ,prgm_id NUMBER) IS
   SELECT enrl_request_id,request_status_code,enrollment_type_code
   FROM   pv_pg_enrl_requests
   WHERE  enrl_request_id=
         (
            SELECT max(enrl_request_id)
            FROM   pv_pg_enrl_requests
            WHERE  partner_id=ptr_id
            AND    program_id=prgm_id
         );

   CURSOR memb_csr(enrl_id NUMBER) IS
   SELECT  membership_id,membership_status_code
   FROM    pv_pg_memberships
   WHERE   enrl_request_id=enrl_id;

   CURSOR prgm_wo_prereq_csr(ptnr_id IN NUMBER) IS
   SELECT pvppb.program_id program_id
         ,pvppb.global_mmbr_reqd_flag global_mmbr_reqd_flag
         ,pvppb.prereq_process_rule_id prereq_process_rule_id
         ,pvppb.no_fee_flag no_fee_flag
         ,pvppb.vad_invite_allow_flag vad_invite_allow_flag
   FROM   pv_partner_program_type_b pvpptb ,pv_partner_program_vl pvppb
   WHERE  pvppb.program_status_code = 'ACTIVE'
   AND    pvppb.program_level_code ='MEMBERSHIP'
   AND    pvppb.enabled_flag = 'Y'
   AND    nvl(pvppb.allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID
   AND    pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   AND    EXISTS
          (
             SELECT 'X' FROM pv_program_partner_types pvppt
             WHERE pvppt.partner_type IN
             (
                SELECT attr_value
                FROM   pv_enty_attr_values pveav
                WHERE  pveav.enabled_flag = 'Y'
                AND pveav.latest_flag = 'Y'
                AND pveav.entity = 'PARTNER'
                AND pveav.entity_id = ptnr_id
                AND pveav.attribute_id = 3
             )
	     AND    pvpptb.program_type_id = pvppt.program_type_id
          )
   AND    pvppb.program_id NOT IN
          (
             SELECT rules.change_to_program_id
             FROM   pv_pg_enrl_change_rules rules
             WHERE  change_direction_code = 'UPGRADE'
             AND    effective_from_date <= sysdate
             AND    nvl(effective_to_date, sysdate) >= sysdate
             AND    active_flag = 'Y'
          );


   l_enrq_param_tbl  PV_ENRL_REQ_PARAM_TBL := PV_ENRL_REQ_PARAM_TBL ();
   l_api_name           CONSTANT VARCHAR2(30) := 'new_programs';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_request_status_code  VARCHAR2(30):=null;
   l_membership_status_code VARCHAR2(30);
   l_enrl_request_id NUMBER;
   l_membership_id NUMBER;
   l_enrollment_type_code VARCHAR2(30);
   l_user_id NUMBER;
   counter NUMBER:=1;
   l_eligible_flag boolean:=true;
   TYPE csr_type IS REF CURSOR;

   prereq_csr csr_type ;
   l_query_str1  VARCHAR2(1200);

   l_cache      VARCHAR2(1);
BEGIN
   --Standard call to check for call compatibility.
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
   --l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=' || to_char(p_partner_id) || 'AND elig.program_id =';
   l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=:1' || 'AND elig.program_id =:2';

   IF p_isprereq_eval='Y' THEN -- This check is to query the pre_req cache data as well
      FOR rec_prgm in prgm_csr(p_partner_id) LOOP
         l_request_status_code:=null;
         l_enrl_request_id:=null;
         l_enrollment_type_code:=null;
         l_membership_status_code:=null;
         l_eligible_flag:=true;
         l_cache:=null;
         --prereq evalution being moved as a dynamic query becase of theissue
         --with this package getting invalidated after running the cincrurrent ptogram to refresh the cache.

          OPEN prereq_csr FOR l_query_str1 USING p_partner_id,rec_prgm.program_id;
            FETCH prereq_csr INTO l_cache;
         CLOSE prereq_csr;

         IF l_cache='X' THEN

            IF p_member_type='SUBSIDIARY' THEN
               IF rec_prgm.global_mmbr_reqd_flag='Y' THEN
                  l_eligible_flag:=isGlobalEnrolled(rec_prgm.program_id,p_partner_id);
               END IF;
            END If;

            IF l_eligible_flag=true THEN
               OPEN enrl_csr(p_partner_id,rec_prgm.program_id);
                  FETCH enrl_csr INTO l_enrl_request_id,l_request_status_code,l_enrollment_type_code;
               CLOSE enrl_csr;

               IF l_request_status_code IS NULL  THEN
                   --populate the table
                  -- ----dbms_output.PUT_LINE('inside enrollment null');
                  l_enrq_param_tbl.EXTEND(1);
                  ----dbms_output.PUT_LINE('after extend ');
                  l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM
                                              (
                                                 rec_prgm.program_id
                                                 ,rec_prgm.program_name
                                                 ,rec_prgm.citem_version_id
                                                 , getInviteHeaderId(p_partner_id ,rec_prgm.program_id , 'INVITE')
                                                -- ,rec_prgm.invite_header_id
                                                 ,null
                                                 ,null
                                                 ,null -- enrollment request id
                                                 ,null -- enrollment type  code
                                                 ,null --  enrollment custome set up id
                                                 ,rec_prgm.prereq_process_rule_id
                                                 ,rec_prgm.no_fee_flag
                                                 ,rec_prgm.vad_invite_allow_flag
                                              );


                  counter:=counter+1;
               -- Fixed for bug 4749395
               ELSIF (  l_request_status_code ='REJECTED' OR l_request_status_code='CANCELLED' ) and l_enrollment_type_code IN ('NEW') THEN
                  l_enrq_param_tbl.EXTEND(1);
                  ----dbms_output.PUT_LINE('after extend ');
                  l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM
                                              (
                                                 rec_prgm.program_id
                                                 ,rec_prgm.program_name
                                                 ,rec_prgm.citem_version_id
                                                 , getInviteHeaderId(p_partner_id ,rec_prgm.program_id , 'INVITE')
                                                 --,rec_prgm.invite_header_id
                                                 ,null
                                                 ,null
                                                 ,null -- enrollment request id
                                                 ,null -- enrollment type  code
                                                 ,null --  enrollment custome set up id
                                                 ,rec_prgm.prereq_process_rule_id
                                                 ,rec_prgm.no_fee_flag
                                                 ,rec_prgm.vad_invite_allow_flag
                                              );

                  counter:=counter+1;

               ELSIF   l_request_status_code ='APPROVED' AND l_enrollment_type_code IN ('NEW','RENEW','UPGRADE') THEN
                  OPEN memb_csr(l_enrl_request_id);
                     FETCH memb_csr INTO l_membership_id,l_membership_status_code;
                  CLOSE memb_csr;
                  IF l_membership_status_code='TERMINATED' THEN
                     l_enrq_param_tbl.EXTEND(1);
                     l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM
                                                 (
                                                      rec_prgm.program_id
                                                      ,rec_prgm.program_name
                                                      ,rec_prgm.citem_version_id
                                                      , getInviteHeaderId(p_partner_id ,rec_prgm.program_id , 'INVITE')
                                                      --,rec_prgm.invite_header_id
                                                      ,to_char(l_membership_id)
                                                      ,null
                                                      ,null -- enrollment request id
                                                      ,null -- enrollment type  code
                                                      ,null --  enrollment custome set up id
                                                      ,rec_prgm.prereq_process_rule_id
                                                      ,rec_prgm.no_fee_flag
                                                      ,rec_prgm.vad_invite_allow_flag
                                                 );

                     counter:=counter+1;
                  END IF;
               END IF;
            END IF;
         END IF; -- end of if , for pre-req evaluation..
      END LOOP;
   ELSIF p_isprereq_eval='N' THEN
      /** --this block will get all the programs that the partner is eligible to join without going
      -- against the prereq tables. This would be only called incase of invite flow where
      -- a new partner is created and wants to invite the partner into a program.
      -- At this time, the list of new programs would be given out from this block
      -- and the prereq evaluation would be done for the list of programs returned by this block
      */
      FOR rec_prgm in prgm_wo_prereq_csr(p_partner_id) LOOP
         l_eligible_flag:=true;
         IF p_member_type='SUBSIDIARY' THEN
            IF rec_prgm.global_mmbr_reqd_flag='Y' THEN
               l_eligible_flag:=isGlobalEnrolled(rec_prgm.program_id,p_partner_id);
            END IF;
         END IF;
         IF l_eligible_flag=true THEN
            l_enrq_param_tbl.EXTEND(1);
            l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM (
                                                             rec_prgm.program_id
                                                             ,null
                                                             ,null
                                                             ,null
                                                             ,null
                                                             ,null
                                                             ,null -- enrollment request id
                                                             ,null -- enrollment type  code
                                                             ,null --  enrollment custome set up id
                                                             ,rec_prgm.prereq_process_rule_id
                                                             ,rec_prgm.no_fee_flag
                                                             ,rec_prgm.vad_invite_allow_flag
                                                          );

            counter:=counter+1;
         END IF;
      END LOOP;
   END IF;

   ----dbms_output.PUT_LINE('before for looop ');

   --We'll query l_enrq_param_tbl  once all the programs related parameters are populated in l_enrq_param_tbl.

   OPEN x_enrq_param_cur  FOR  SELECT * FROM TABLE( CAST (l_enrq_param_tbl  AS PV_ENRL_REQ_PARAM_TBL)) order by upper(programname) asc;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
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
END new_programs;


PROCEDURE renewable_programs
(
   p_api_version_number          IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2
   ,p_isprereq_eval              IN   VARCHAR2     :='Y'
   ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
) IS

   CURSOR prgm_csr1(ptr_id IN NUMBER) IS
   SELECT pvppb.program_id program_id
          ,pvppb.program_name program_name
          ,pvppb.citem_version_id citem_version_id
          ,pvppb.global_mmbr_reqd_flag global_mmbr_reqd_flag
          ,pvppb.prereq_process_rule_id prereq_process_rule_id
          ,pvppb.no_fee_flag no_fee_flag
          ,pvppb.vad_invite_allow_flag vad_invite_allow_flag
          ,memb.membership_id membership_id
          ,memb.membership_status_code membership_status_code
          ,memb.original_end_date original_end_date
         -- ,inv.invite_header_id invite_header_id
   FROM   pv_partner_program_type_b pvpptb
          ,pv_partner_program_vl pvppb
          ,pv_pg_memberships  memb
         -- ,pv_pg_invite_headers_b inv
   WHERE  pvppb.program_status_code = 'ACTIVE'
   AND    pvppb.program_level_code ='MEMBERSHIP'
   AND    pvppb.enabled_flag = 'Y'
   AND    nvl(pvppb.allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID
   AND    pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   --AND    inv.partner_id (+) =  ptr_id
   --AND    inv.invite_for_program_id (+) = pvppb.program_id
  -- AND    NVL(inv.invite_end_date, sysdate+1) > sysdate
   --AND    inv.invite_type_code(+)='INVITE'
   AND    EXISTS
          (   SELECT 'X' FROM pv_program_partner_types pvppt
              WHERE pvppt.partner_type IN
              (
                 SELECT attr_value
                 FROM   pv_enty_attr_values pveav
                 WHERE  pveav.enabled_flag = 'Y'
                 AND pveav.latest_flag = 'Y'
                 AND pveav.entity = 'PARTNER'
                 AND pveav.entity_id = ptr_id
                 AND pveav.attribute_id = 3
              )
   	   AND    pvpptb.program_type_id = pvppt.program_type_id
          )
   AND    pvppb.program_id =memb.program_id
   AND    memb.membership_id =
          (   SELECT max(membership_id)
              FROM   PV_PG_MEMBERSHIPS
              WHERE  program_id=memb.program_id
              AND    partner_id=ptr_id
              AND    MEMBERSHIP_STATUS_CODE IN ('ACTIVE','EXPIRED')

          )
   /*AND EXISTS -- check for pre-populated cache for pre-req evaluation
        ( SELECT 1
          FROM pv_pg_elig_programs elig
          WHERE elig.program_id = pvppb.program_id
          AND elig.partner_id = ptr_id
        )*/
        ;

   CURSOR notify_rule_csr(program_id NUMBER) IS
   SELECT  decode(send_notif_before_unit, 'PV_MONTHS',add_months(sysdate,send_notif_before_value)
                                          ,'PV_WEEKS', sysdate+ send_notif_before_value*7
   		   		       ,'PV_DAYS', sysdate+send_notif_before_value,null) cdate

   FROM  pv_ge_notif_rules_b
   WHERE arc_notif_for_entity_code = 'PRGM'
   AND notif_for_entity_id = program_id
   AND notif_type_code = 'PG_MEM_EXP'
   AND active_flag = 'Y';

   CURSOR enrl_csr(ptr_id NUMBER ,prgm_id NUMBER) IS
   SELECT enrl_request_id,request_status_code ,enrollment_type_code
   FROM   pv_pg_enrl_requests
   WHERE  enrl_request_id=
         (
             SELECT max(enrl_request_id)
             FROM   pv_pg_enrl_requests
             WHERE	 partner_id=ptr_id
             AND    program_id=prgm_id
             AND    enrollment_type_code='RENEW'
         );


   CURSOR upgrade_rule_csr(prgm_id NUMBER,ptr_id NUMBER) IS
   SELECT  'X'
              FROM   pv_pg_enrl_change_rules rules
              WHERE  change_direction_code = 'UPGRADE'
              AND    effective_from_date <= sysdate
              AND    nvl(effective_to_date, sysdate) >= sysdate
              AND    active_flag = 'Y'
              AND    change_from_program_id=prgm_id
              AND
              EXISTS
              (   SELECT enrl_request_id
                  FROM   pv_pg_enrl_requests
                  WHERE  partner_id=ptr_id
                  AND    request_status_code IN ('AWAITING_APPROVAL','APPROVED','INCOMPLETE')
                  AND    program_id=rules.change_to_program_id
               );

   CURSOR memb_csr(enrl_id NUMBER) IS
   SELECT  membership_status_code
   FROM    pv_pg_memberships
   WHERE   enrl_request_id=enrl_id;

   l_enrq_param_tbl  PV_ENRL_REQ_PARAM_TBL := PV_ENRL_REQ_PARAM_TBL ();
   l_api_name           CONSTANT VARCHAR2(30) := 'renewable_programs';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_request_status_code  VARCHAR2(30);
   l_membership_status_code VARCHAR2(30);
   l_enrl_request_id NUMBER;
   l_membership_id NUMBER;
   counter NUMBER:=1;
   --l_flag varchar2(1):='Y';
   l_upgrade_exists varchar2(1):=null;
   l_cdate DATE:=null;
   l_enrollment_type_code VARCHAR2(30);
   l_user_id NUMBER;
   l_eligible_flag boolean:=true;
   isValid  boolean:=false;
   TYPE csr_type IS REF CURSOR;
   prereq_csr csr_type ;
   l_query_str1  VARCHAR2(1200);

   l_cache      VARCHAR2(1);

BEGIN

   --Standard call to check for call compatibility.
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
   --l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=' || to_char(p_partner_id) || 'AND elig.program_id =';
   l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=:1' || 'AND elig.program_id =:2';
   FOR rec_p in prgm_csr1(p_partner_id) LOOP
      l_eligible_flag:=true;
      l_cdate:=null ;
      l_upgrade_exists:=null;
      l_request_status_code:=null;
      isValid :=false;
      l_cache:=null;


      OPEN prereq_csr FOR l_query_str1 USING p_partner_id,rec_p.program_id;
         FETCH prereq_csr INTO l_cache;
      CLOSE prereq_csr;

      IF l_cache='X' THEN

         --this if clause is to check if the partner is eligible for early renewal
         IF rec_p.membership_status_code='ACTIVE' THEN
            OPEN notify_rule_csr(rec_p.program_id);
               FETCH notify_rule_csr INTO l_cdate;
            CLOSE notify_rule_csr;
            IF  l_cdate is not null  THEN
               IF rec_p.original_end_date>l_cdate THEN
                  l_eligible_flag:=false;
                ELSE
                  l_eligible_flag:=true;
               END IF;
            ELSE
               l_eligible_flag:=false;
            END IF;
         END IF;

         --if the member type is subsidiary,check whether global has enrolled
         IF p_member_type='SUBSIDIARY' AND rec_p.membership_status_code='EXPIRED' AND rec_p.global_mmbr_reqd_flag='Y' THEN
            l_eligible_flag:=isGlobalEnrolled(rec_p.program_id,p_partner_id);
         END IF;

         IF l_eligible_flag=true THEN
            OPEN enrl_csr(p_partner_id,rec_p.program_id);
               FETCH enrl_csr INTO l_enrl_request_id,l_request_status_code,l_enrollment_type_code;
            CLOSE enrl_csr;
            IF l_request_status_code IS NULL OR l_request_status_code IN ( 'REJECTED','CANCELLED') THEN


               --check whether there is an upgrade request from this program to some other program
               OPEN upgrade_rule_csr(rec_p.program_id,p_partner_id);
                  FETCH upgrade_rule_csr INTO l_upgrade_exists;
               CLOSE upgrade_rule_csr;

               IF l_upgrade_exists IS  NULL THEN
                  isValid:=true;

               END IF;
            ELSIF l_request_status_code='APPROVED' THEN
               OPEN memb_csr(l_enrl_request_id);
                  FETCH memb_csr INTO l_membership_status_code;
               CLOSE memb_csr;
               IF l_membership_status_code IN ( 'EXPIRED', 'DOWNGRADED' ) THEN
                  isValid:=true;
               END IF;
            END IF;
            IF isValid=true THEN
               l_enrq_param_tbl.EXTEND(1);
               l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM(
                                                               rec_p.program_id
                                                               ,rec_p.program_name
                                                               ,rec_p.citem_version_id
                                                               , getInviteHeaderId(p_partner_id ,rec_p.program_id , 'INVITE')
                                                               --,rec_p.invite_header_id
                                                               ,rec_p.membership_id
                                                               ,null
                                                               ,null -- enrollment request id
                                                               ,null -- enrollment type  code
                                                               ,null --  enrollment custome set up id
                                                               ,rec_p.prereq_process_rule_id
                                                               ,rec_p.no_fee_flag
                                                               ,rec_p.vad_invite_allow_flag

                                                            );


                counter:=counter+1;
            END IF;
         END IF;   -- end  of if , if eligible
      END IF; -- end of if for preewquite cache
   END LOOP;-- END OF FOR LOOP

   -- open ref cursor by querying l_enrq_param_tbl once all the programs related parameters are populated in l_enrq_param_tbl.
   Open x_enrq_param_cur  for  select * from TABLE(cast (l_enrq_param_tbl  as PV_ENRL_REQ_PARAM_TBL)) order by upper(programname) asc;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
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
END renewable_programs;


PROCEDURE upgradable_programs
(
   p_api_version_number          IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2
   ,p_isprereq_eval              IN   VARCHAR2     :='Y'
   ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
) IS

   /** pick up all programs of the active memberships for that partner.
   pick up the to_programs for all these programs from upgrade rules table.
   see  whether there is an Active,upgraded membership in memberships table
   if there is none,display this program.
   if this TO program exist in memberships table,don't pick it up...
   else pick it up..
   also query the prereq tables
   */
   CURSOR upgrd_prgm_csr(p_ptr_id NUMBER ) IS
   SELECT  rules.change_to_program_id program_id
       ,pvppb.program_name program_name
       ,pvppb.citem_version_id citem_version_id
       ,memb.membership_id membership_id
       ,rules.change_from_program_id change_from_program_id
       ,rules.enrl_change_rule_id enrl_change_rule_id
       ,pvppb.global_mmbr_reqd_flag global_mmbr_reqd_flag
       ,pvppb.prereq_process_rule_id prereq_process_rule_id
       ,pvppb.no_fee_flag no_fee_flag
       ,pvppb.vad_invite_allow_flag vad_invite_allow_flag
   FROM   pv_pg_enrl_change_rules rules
      ,pv_pg_memberships memb
      ,pv_partner_program_vl pvppb
      ,pv_partner_program_type_b pvpptb

   WHERE  pvppb.program_status_code = 'ACTIVE'
   AND    pvppb.program_level_code ='MEMBERSHIP'
   AND    pvppb.enabled_flag = 'Y'
   AND    nvl(pvppb.allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID
   AND    pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   AND    rules.change_from_program_id=memb.program_id
   AND    memb.partner_id=p_ptr_id
   --AND    memb.membership_status_code in ('ACTIVE' , 'UPGRADED')
   AND  memb.program_id= (
                           SELECT memb10.program_id
                           FROM   pv_pg_memberships  memb10
			   WHERE memb10.membership_id =
			   (   SELECT max(membership_id)
                               FROM   pv_pg_memberships memb9
                               WHERE  memb9.program_id=memb.program_id
                               AND    memb9.partner_id=memb.partner_id
			      )
			      AND    memb10.membership_status_code in ('ACTIVE' , 'UPGRADED')
                         )

   AND    rules.change_direction_code = 'UPGRADE'
   AND    rules.effective_from_date <= sysdate
   AND    nvl(rules.effective_to_date, sysdate) >= sysdate
   AND    rules.active_flag = 'Y'
   AND    rules.change_to_program_id=pvppb.program_id
   AND    rules.change_to_program_id not in (
                       /*SELECT memb2.program_id
                       FROM   pv_pg_memberships memb2
                       WHERE  memb2.program_id=rules.change_to_program_id
                       AND    memb2.partner_id=memb.partner_id
                       AND    memb2.membership_status_code in ('ACTIVE','UPGRADED','EXPIRED')
                       */
                       SELECT memb2.program_id
                       FROM    pv_pg_memberships memb2
                       WHERE  memb2.membership_id =
                       (
                          SELECT max(membership_id)
                          FROM   pv_pg_memberships memb3
                          WHERE  memb3.program_id=rules.change_to_program_id
                          AND    memb3.partner_id=memb.partner_id

                       )
                       AND    memb2.membership_status_code in ('ACTIVE','UPGRADED','EXPIRED','FUTURE')

                    )
   AND    EXISTS
       (   SELECT 'X' FROM pv_program_partner_types pvppt
           WHERE pvppt.partner_type IN
           (
              SELECT attr_value
              FROM   pv_enty_attr_values pveav
              WHERE  pveav.enabled_flag = 'Y'
              AND pveav.latest_flag = 'Y'
              AND pveav.entity = 'PARTNER'
              AND pveav.entity_id =p_ptr_id
              AND pveav.attribute_id = 3
           )
      AND    pvpptb.program_type_id = pvppt.program_type_id
   )
  /* AND EXISTS -- check for pre-populated cache for pre-req evaluation
           ( SELECT 1
             FROM pv_pg_elig_programs elig
             WHERE elig.program_id = pvppb.program_id
             AND elig.partner_id = p_ptr_id
           )
           */
   order by rules.change_to_program_id desc;

   CURSOR enrl_csr(ptr_id NUMBER ,prgm_id NUMBER) IS
   SELECT enrq.enrl_request_id,enrq.request_status_code,enrq.enrollment_type_code, memb.membership_status_code
   FROM   pv_pg_enrl_requests enrq
          , pv_pg_memberships memb
   WHERE  enrq.enrl_request_id=
      (
          SELECT max(enrl_request_id)
          FROM   pv_pg_enrl_requests
          WHERE	 partner_id=ptr_id
          AND    program_id=prgm_id

      )
      and enrq.enrl_request_id=memb.enrl_request_id(+);



   l_enrq_param_tbl  PV_ENRL_REQ_PARAM_TBL := PV_ENRL_REQ_PARAM_TBL ();
   l_api_name           CONSTANT VARCHAR2(30) := 'upgradable_programs';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_eligible_flag boolean:=true;
   l_memb_flag boolean:=true;
   l_request_status_code  VARCHAR2(30):=null;
   l_membership_status_code VARCHAR2(30);
   l_enrl_request_id NUMBER;
   l_membership_id NUMBER;
   l_enrollment_type_code VARCHAR2(30);
   l_prevMembrId  VARCHAR2(1000);
   l_upgrdRlId VARCHAR2(1000);
   counter NUMBER:=0;
   l_program_id NUMBER:=NULL;
   TYPE csr_type IS REF CURSOR;
   prereq_csr csr_type ;
   l_query_str1  VARCHAR2(1200);

   l_cache      VARCHAR2(1);

BEGIN

   --Standard call to check for call compatibility.
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
   --l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=' || to_char(p_partner_id) || 'AND elig.program_id =';
   l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=:1' || 'AND elig.program_id =:2';
   FOR rec_prgm in upgrd_prgm_csr(p_partner_id) LOOP
       l_eligible_flag:=true;
       l_cache:=null;
       l_memb_flag  :=true;

       OPEN prereq_csr FOR l_query_str1 USING p_partner_id,rec_prgm.program_id ;
          FETCH prereq_csr INTO l_cache;
       CLOSE prereq_csr;

       IF l_cache='X' THEN
          IF p_member_type='SUBSIDIARY'  AND rec_prgm.global_mmbr_reqd_flag='Y' THEN
             l_eligible_flag:=isGlobalEnrolled(rec_prgm.program_id,p_partner_id);
          END IF;

          IF l_eligible_flag=true THEN
             OPEN enrl_csr(p_partner_id,rec_prgm.program_id);
                FETCH enrl_csr INTO l_enrl_request_id,l_request_status_code,l_enrollment_type_code,l_membership_status_code;
             CLOSE enrl_csr;
             IF l_request_status_code IS NULL OR l_request_status_code IN ( 'REJECTED','CANCELLED', 'APPROVED' ) THEN
                -- the logic here is , the query could fetch you the same program more than once
                -- if there is multiple upgrade path. so intially l_program_id is null
                -- in the next loop, if the program_id is same, then the previous membership id and
                -- upgrade rule id is concatenated. if not , the l_enrq_param_tbl is extended and initialised
                IF l_enrollment_type_code ='APPROVED' THEN
                   IF l_membership_status_code ='ACTIVE' THEN
                      l_memb_flag :=false;
                   ELSE
                      l_memb_flag :=true;
                   END IF;
                END IF;

                IF l_memb_flag =true THEN

                   IF l_program_id=rec_prgm.program_id THEN
                      l_prevMembrId:=l_prevMembrId || ':' || to_char(rec_prgm.membership_id);
                      l_upgrdRlId:=l_upgrdRlId || ':' || to_char(rec_prgm.enrl_change_rule_id);
                      l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM(
                                                                      rec_prgm.program_id
                                                                      ,rec_prgm.program_name
                                                                      ,rec_prgm.citem_version_id
                                                                      , getInviteHeaderId(p_partner_id ,rec_prgm.program_id , 'UPGRADE')
                                                                      --,rec_prgm.invite_header_id
                                                                      ,l_prevMembrId
                                                                      , l_upgrdRlId
                                                                      ,null -- enrollment request id
                                                                      ,null -- enrollment type  code
                                                                      ,null --  enrollment custome set up id
                                                                      ,rec_prgm.prereq_process_rule_id
                                                                      ,rec_prgm.no_fee_flag
                                                                      ,rec_prgm.vad_invite_allow_flag

                                                                   );

                   ELSE
                      counter:=counter+1;
                      l_prevMembrId:=to_char(rec_prgm.membership_id);
                      l_upgrdRlId:=to_char(rec_prgm.enrl_change_rule_id);
                      l_enrq_param_tbl.EXTEND(1);
                      l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM(
                                                                      rec_prgm.program_id
                                                                      ,rec_prgm.program_name
                                                                      ,rec_prgm.citem_version_id
                                                                      ,getInviteHeaderId(p_partner_id ,rec_prgm.program_id , 'UPGRADE')
                                                                      ,to_char(rec_prgm.membership_id)
                                                                      ,to_char(rec_prgm.enrl_change_rule_id)
                                                                      ,null -- enrollment request id
                                                                      ,null -- enrollment type  code
                                                                      ,null --  enrollment custome set up id
                                                                      ,rec_prgm.prereq_process_rule_id
                                                                      ,rec_prgm.no_fee_flag
                                                                      ,rec_prgm.vad_invite_allow_flag
                                                                  );
                      l_program_id:=rec_prgm.program_id;
                   END IF;
                END IF;
             END IF;
          END IF;--end of if ,if the program is eligible
          l_request_status_code:=null;
       END IF; -- end of if for preewquite cache
   END LOOP;

   --We'll query l_enrq_param_tbl  once all the programs related parameters are populated in l_enrq_param_tbl.
   Open x_enrq_param_cur  for  select * from TABLE(cast (l_enrq_param_tbl  as PV_ENRL_REQ_PARAM_TBL)) order by upper(programname) asc;

   -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
     COMMIT;
  END IF;

EXCEPTION
   WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
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
END upgradable_programs;


PROCEDURE incomplete_programs
(
   p_api_version_number          IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2
   ,p_isprereq_eval              IN   VARCHAR2     :='Y'
   ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
)   IS

   CURSOR incomplet_csr(p_ptr_id NUMBER ) IS
   SELECT enrq.enrl_request_id
          ,enrq.enrollment_type_code
          ,enrq.program_id
          ,enrq.custom_setup_id
          ,pvppb.program_name
          ,pvppb.citem_version_id
          ,pvppb.global_mmbr_reqd_flag
          ,pvppb.prereq_process_rule_id prereq_process_rule_id
          ,pvppb.no_fee_flag no_fee_flag
          ,pvppb.vad_invite_allow_flag vad_invite_allow_flag
   FROM    pv_partner_program_type_b pvpptb
          ,pv_partner_program_vl pvppb
          ,pv_pg_enrl_requests enrq
   WHERE  pvppb.program_status_code = 'ACTIVE'
   AND    pvppb.program_level_code ='MEMBERSHIP'
   AND    pvppb.enabled_flag = 'Y'
   AND    nvl(pvppb.allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID  AND  pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   AND    EXISTS
          (   SELECT 'X'
              FROM    pv_program_partner_types pvppt
              WHERE   pvppt.partner_type
              IN     (  SELECT attr_value
                        FROM   pv_enty_attr_values pveav
                        WHERE  pveav.enabled_flag = 'Y'
                        AND    pveav.latest_flag = 'Y'
                        AND    pveav.entity = 'PARTNER'
                        AND pveav.entity_id =p_ptr_id
                        AND pveav.attribute_id = 3
                     )
              AND    pvpptb.program_type_id = pvppt.program_type_id
          )
   AND    enrq.enrl_request_id =
          (   SELECT max(enrl_request_id)
              FROM   pv_pg_enrl_requests
              WHERE  partner_id= p_ptr_id
              AND    program_id=pvppb.PROGRAM_ID
              AND   request_status_code='INCOMPLETE'
          )
   /*AND EXISTS -- check for pre-populated cache for pre-req evaluation
           ( SELECT 1
             FROM pv_pg_elig_programs elig
             WHERE elig.program_id = pvppb.program_id
             AND elig.partner_id = p_ptr_id
           )
           */
           ;

   l_enrq_param_tbl  PV_ENRL_REQ_PARAM_TBL := PV_ENRL_REQ_PARAM_TBL ();
   l_api_name           CONSTANT VARCHAR2(30) := 'incomplete_programs';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   counter NUMBER:=0;
   TYPE csr_type IS REF CURSOR;
   prereq_csr  csr_type ;
   l_query_str1  VARCHAR2(1200);

   l_cache       VARCHAR2(1);

BEGIN

   --Standard call to check for call compatibility.
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

   -- logic to get the list of new programs that partner is eligible to see goes here.
   --Add each of program, add the following parameter values to the following   table
   --l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=' || to_char(p_partner_id) || 'AND elig.program_id =';
   l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=:1' || 'AND elig.program_id =:2';
   FOR rec_prgm in incomplet_csr(p_partner_id) LOOP
       l_cache:=null;

       OPEN prereq_csr FOR l_query_str1 USING p_partner_id,rec_prgm.program_id ;
          FETCH prereq_csr INTO l_cache;
       CLOSE prereq_csr;

       IF l_cache='X' THEN
          counter:=counter+1;
          l_enrq_param_tbl.EXTEND(1);
          l_enrq_param_tbl(counter) := PV_ENRL_REQ_PARAM(  rec_prgm.program_id
                                                        ,rec_prgm.program_name
                                                        ,rec_prgm.citem_version_id
                                                        ,null -- need to clarify business logic here
                                                        ,null -- previous membership id
                                                        ,null -- upgrade rule id
                                                        ,rec_prgm.enrl_request_id -- enrollment request id
                                                        ,rec_prgm.enrollment_type_code -- enrollment type  code
                                                        ,rec_prgm.custom_setup_id --  enrollment custome set up id
                                                        ,rec_prgm.prereq_process_rule_id
                                                        ,rec_prgm.no_fee_flag
                                                        ,rec_prgm.vad_invite_allow_flag

                                                     );
      END IF; -- end of if for preewquite cache
   END LOOP;

   --We'll query l_enrq_param_tbl  once all the programs related parameters are populated in l_enrq_param_tbl.
   Open x_enrq_param_cur  for  select * from TABLE(cast (l_enrq_param_tbl  as PV_ENRL_REQ_PARAM_TBL)) order by upper(programname) asc;

   -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
     COMMIT;
  END IF;

EXCEPTION
   WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
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
END incomplete_programs;


PROCEDURE newAndInCompletePrograms
(
   p_api_version_number          IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2
   ,p_isprereq_eval              IN   VARCHAR2     :='Y'
   ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
   ,x_return_status              OUT  NOCOPY VARCHAR2
   ,x_msg_count                  OUT  NOCOPY NUMBER
   ,x_msg_data                   OUT  NOCOPY VARCHAR2
) IS
   l_api_name            CONSTANT VARCHAR2(30) := 'newAndInCompletePrograms';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_new_enrq_param_ref      enrq_param_ref;
   l_inc_enrq_param_ref      enrq_param_ref;
   --l_newinc_enrq_param_ref   enrq_param_ref;
   l_nienrq_param_tbl  PV_ENRL_REQ_PARAM_TBL := PV_ENRL_REQ_PARAM_TBL ();
   l_programId         NUMBER;
   l_programName       VARCHAR2(60);
   l_citemVersionId    NUMBER;
   l_inviteHeaderId    NUMBER;
   l_prevMembrId       VARCHAR2(1000) ;
   l_upgrdRlId         VARCHAR2(1000);
   l_enrlId            NUMBER;
   l_enrlTypeCode      VARCHAR2(30);
   l_enrlCustSetupId   NUMBER;
   l_prereqProcessRuleId NUMBER;
   l_no_fee           VARCHAR2(1);
   l_vad_invite        VARCHAR2(1);
     counter NUMBER:=1;
BEGIN
    --Standard call to check for call compatibility.
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
   new_programs
   (
      p_api_version_number          => p_api_version_number
      ,p_init_msg_list              => p_init_msg_list
      ,p_commit                     => p_commit
      ,p_validation_level           => p_validation_level
      ,p_partner_id                 => p_partner_id
      ,p_member_type                => p_member_type
      ,p_isprereq_eval              => p_isprereq_eval
      ,x_enrq_param_cur             => l_new_enrq_param_ref
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
   );
   LOOP
   -- you need to fetch all of it even though you don't neeed it.
      FETCH  l_new_enrq_param_ref  into   l_programId, l_programName, l_citemVersionId, l_inviteHeaderId,       l_prevMembrId   , l_upgrdRlId ,
            l_enrlId , l_enrlTypeCode, l_enrlCustSetupId,l_prereqProcessRuleId, l_no_fee, l_vad_invite;

      EXIT WHEN l_new_enrq_param_ref%NOTFOUND;

       IF  l_programId IS NOT NULL THEN
         l_nienrq_param_tbl.EXTEND(1);
         l_nienrq_param_tbl(counter) := PV_ENRL_REQ_PARAM(  l_programId
                                                           ,l_programName
                                                           , l_citemVersionId
                                                           , l_inviteHeaderId
                                                           ,l_prevMembrId
                                                           ,l_upgrdRlId
                                                           ,l_enrlId -- enrollment request id
                                                           ,l_enrlTypeCode -- enrollment type  code
                                                           ,l_enrlCustSetupId--  enrollment custome set up id
                                                           ,l_prereqProcessRuleId
                                                           ,l_no_fee
                                                           ,l_vad_invite

                                                        );
         counter:=counter+1;
      END IF;



   END LOOP;
   close  l_new_enrq_param_ref ;

   incomplete_programs
   (
      p_api_version_number          => p_api_version_number
      ,p_init_msg_list              => p_init_msg_list
      ,p_commit                     => p_commit
      ,p_validation_level           => p_validation_level
      ,p_partner_id                 => p_partner_id
      ,p_member_type                => p_member_type
      ,p_isprereq_eval              => p_isprereq_eval
      ,x_enrq_param_cur             => l_inc_enrq_param_ref
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
   );

   LOOP
   -- you need to fetch all of it even though you don't neeed it.
      FETCH  l_inc_enrq_param_ref   into   l_programId, l_programName, l_citemVersionId, l_inviteHeaderId,       l_prevMembrId   , l_upgrdRlId ,
            l_enrlId , l_enrlTypeCode, l_enrlCustSetupId,l_prereqProcessRuleId, l_no_fee, l_vad_invite;

      EXIT WHEN l_inc_enrq_param_ref%NOTFOUND;

       IF  l_programId IS NOT NULL THEN
         l_nienrq_param_tbl.EXTEND(1);
         l_nienrq_param_tbl(counter) := PV_ENRL_REQ_PARAM(  l_programId
                                                           ,l_programName
                                                           , l_citemVersionId
                                                           , l_inviteHeaderId
                                                           ,l_prevMembrId
                                                           ,l_upgrdRlId
                                                           ,l_enrlId -- enrollment request id
                                                           ,l_enrlTypeCode -- enrollment type  code
                                                           ,l_enrlCustSetupId--  enrollment custome set up id
                                                           ,l_prereqProcessRuleId
                                                           ,l_no_fee
                                                           ,l_vad_invite

                                                        );
         counter:=counter+1;
      END IF;



   END LOOP;
   close  l_inc_enrq_param_ref ;


   OPEN x_enrq_param_cur  FOR  SELECT * FROM TABLE( CAST (l_nienrq_param_tbl  AS PV_ENRL_REQ_PARAM_TBL)) order by upper(programname) asc;


   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

EXCEPTION
     WHEN  FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

   WHEN OTHERS THEN
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
END newAndInCompletePrograms;

PROCEDURE isPartnerEligible
(
   p_api_version_number           IN   NUMBER
   , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   , p_partner_id                 IN   NUMBER
   , p_from_program_id            IN   NUMBER
   , p_to_program_id              IN   NUMBER
   , p_enrq_type                  IN   VARCHAR  -- permitted values here are 'NEW', 'UPGRADE' for 11.5.10.
   , x_elig_flag                  OUT  NOCOPY VARCHAR2 -- PASS 'Y' if eligible, PASS 'N' if not eligible
   , x_return_status              OUT  NOCOPY VARCHAR2
   , x_msg_count                  OUT  NOCOPY NUMBER
   , x_msg_data                   OUT  NOCOPY VARCHAR2
)
IS
   l_api_name           CONSTANT VARCHAR2(30) := 'isPartnerEligible';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_global_mmbr_reqd_flag  VARCHAR2(1);
   l_eligible_flag boolean:=true;
   l_member_type          VARCHAR2(30);
   l_request_status_code  VARCHAR2(30);
   l_enrollment_type_code VARCHAR2(30);

   CURSOR memb_type( p_ptr_id NUMBER)  IS
   SELECT attr_value
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';

   CURSOR isElig( ptnr_id NUMBER, p_prgm_id NUMBER ) IS
   SELECT 'Y' , global_mmbr_reqd_flag
   FROM   pv_partner_program_type_b pvpptb
          , pv_partner_program_b pvppb
   WHERE  program_id=p_prgm_id
   AND    nvl(allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID
   AND    pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   AND    program_id NOT IN
          (
             SELECT rules.change_to_program_id
             FROM   pv_pg_enrl_change_rules rules
             WHERE  change_direction_code = 'UPGRADE'
             AND    effective_from_date <= sysdate
             AND    nvl(effective_to_date, sysdate) >= sysdate
             AND    active_flag = 'Y'
          )
   AND    EXISTS
          (
             SELECT 'X'
             FROM pv_program_partner_types pvppt
             WHERE pvppt.partner_type IN
             (
                SELECT attr_value
                FROM   pv_enty_attr_values pveav
                WHERE  pveav.enabled_flag = 'Y'
                AND pveav.latest_flag = 'Y'
                AND pveav.entity = 'PARTNER'
                AND pveav.entity_id = ptnr_id
                AND pveav.attribute_id = 3
             )
   	  AND    pvpptb.program_type_id = pvppt.program_type_id
          )
   /*AND    EXISTS -- check for pre-populated cache for pre-req evaluation
          (
             SELECT 1
             FROM pv_pg_elig_programs elig
             WHERE elig.program_id = pvppb.program_id
             AND elig.partner_id = ptnr_id
           )*/
           ;

  CURSOR c_upgrade_csr( p_ptr_id IN NUMBER, p_from_id IN NUMBER, p_to_id IN NUMBER) IS
  SELECT 'Y'
          , global_mmbr_reqd_flag
   FROM   pv_pg_enrl_change_rules rules
          , pv_pg_memberships memb
          , pv_partner_program_vl pvppb
          , pv_partner_program_type_b pvpptb
   WHERE  pvppb.program_status_code = 'ACTIVE'
   AND    pvppb.program_level_code ='MEMBERSHIP'
   AND    pvppb.enabled_flag = 'Y'
   AND    pvppb.program_id=p_to_id
   AND    nvl(pvppb.allow_enrl_until_date, sysdate) > sysdate-1
   AND    pvppb.program_type_id = pvpptb.program_type_ID
   AND    pvpptb.ACTIVE_FLAG = 'Y'
   AND    pvpptb.enabled_flag = 'Y'
   AND    memb.program_id=p_from_id
   AND    memb.partner_id=p_ptr_id
   --AND    memb.membership_status_code in ('ACTIVE' , 'UPGRADED')
   AND  memb.program_id= (
                           SELECT memb10.program_id
                           FROM   pv_pg_memberships  memb10
			   WHERE memb10.membership_id =
			   (   SELECT max(membership_id)
                               FROM   pv_pg_memberships memb9
                               WHERE  memb9.program_id=memb.program_id
                               AND    memb9.partner_id=memb.partner_id
			      )
			      AND    memb10.membership_status_code in ('ACTIVE' , 'UPGRADED')
                         )

   AND    rules.change_from_program_id =p_from_id
   AND    rules.change_direction_code = 'UPGRADE'
   AND    rules.effective_from_date <= sysdate
   AND    nvl(rules.effective_to_date, sysdate) >= sysdate
   AND    rules.active_flag = 'Y'
   AND    rules.change_to_program_id=p_to_id
   AND    rules.change_to_program_id not in
          (
             /* SELECT memb2.program_id
              FROM   pv_pg_memberships memb2
              WHERE  memb2.program_id=p_to_id
              AND    memb2.partner_id=p_ptr_id
              AND    memb2.membership_status_code in ('ACTIVE', 'UPGRADED')
              */
              SELECT memb2.program_id
              FROM    pv_pg_memberships memb2
              WHERE  memb2.membership_id =
              (
              SELECT max(membership_id)
              FROM   pv_pg_memberships memb3
              WHERE  memb3.program_id=rules.change_to_program_id
              AND    memb3.partner_id=memb.partner_id
              )
              AND    memb2.membership_status_code in ('ACTIVE','UPGRADED','EXPIRED')

          )
   AND    EXISTS
          (
             SELECT 'X'
             FROM pv_program_partner_types pvppt
             WHERE pvppt.partner_type IN
             (
                SELECT attr_value
                FROM   pv_enty_attr_values pveav
                WHERE  pveav.enabled_flag = 'Y'
                AND pveav.latest_flag = 'Y'
                AND pveav.entity = 'PARTNER'
                AND pveav.entity_id =  p_ptr_id
                AND pveav.attribute_id = 3
             )
   	  AND    pvpptb.program_type_id = pvppt.program_type_id
          )
  /* AND    EXISTS -- check for pre-populated cache for pre-req evaluation
          (
             SELECT 1
             FROM pv_pg_elig_programs elig
             WHERE elig.program_id = pvppb.program_id
             AND elig.partner_id = p_ptr_id
          )
          */
          ;

   CURSOR enrl_csr( ptr_id IN NUMBER, prgm_id IN NUMBER  ) IS
   SELECT request_status_code,enrollment_type_code
   FROM   pv_pg_enrl_requests
   WHERE  enrl_request_id=
   (
       SELECT max(enrl_request_id)
       FROM   pv_pg_enrl_requests
       WHERE	 partner_id=ptr_id
       AND    program_id=prgm_id

   );

   TYPE csr_type IS REF CURSOR;
   prereq_csr csr_type ;
   l_query_str1  VARCHAR2(1200);

   l_cache      VARCHAR2(1):=null;

BEGIN
   SAVEPOINT isPartnerEligible;
   --Standard call to check for call compatibility.
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
   x_elig_flag := 'N';

   --l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=' || to_char(p_partner_id) || 'AND elig.program_id='|| to_char( p_to_program_id);
   l_query_str1:= 'SELECT ''X''  FROM pv_pg_elig_programs elig  WHERE elig.partner_id=:1' || 'AND elig.program_id =:2';

   OPEN prereq_csr FOR l_query_str1 USING p_partner_id, p_to_program_id;
      FETCH prereq_csr INTO l_cache;
   CLOSE prereq_csr;

   IF l_cache='X' THEN
      IF p_enrq_type = 'NEW' THEN

         OPEN isElig( p_partner_id , p_to_program_id  ) ;
            FETCH isElig INTO x_elig_flag,l_global_mmbr_reqd_flag;
         CLOSE isElig;

         IF x_elig_flag= 'Y' THEN
         	OPEN memb_type( p_partner_id );
         	   FETCH memb_type INTO l_member_type;
         	CLOSE memb_type;
         	IF l_member_type='SUBSIDIARY' THEN
         	    IF l_global_mmbr_reqd_flag ='Y' THEN
                     l_eligible_flag:=isGlobalEnrolled(p_to_program_id ,p_partner_id);
                  END IF;
                  IF l_eligible_flag=false THEN
                     x_elig_flag := 'N' ;
                  END IF;
              END If;
         ELSE
            x_elig_flag := 'N' ;
         END IF;
      ELSIF p_enrq_type = 'UPGRADE' THEN
         -- start: if its upgrade
         OPEN c_upgrade_csr( p_partner_id , p_from_program_id, p_to_program_id  ) ;
            FETCH c_upgrade_csr INTO x_elig_flag,l_global_mmbr_reqd_flag;
         CLOSE c_upgrade_csr;

         IF x_elig_flag= 'Y' THEN
            OPEN enrl_csr( p_partner_id, p_to_program_id );
               FETCH enrl_csr INTO l_request_status_code,l_enrollment_type_code;
            CLOSE enrl_csr;
            --check whether there is an already an APPROVED enrollment request
            -- Fixed for bug 5116650. Only checked for AWAITING_APPROVAL by taking out the APPROVED status
            IF ( l_request_status_code IS NOT NULL AND l_request_status_code IN ( 'AWAITING_APPROVAL' ) )  THEN
              x_elig_flag :=  'N';

            END IF;

            -- check member type and if its subsidiary , check whether global has enrolled.
            IF x_elig_flag= 'Y' THEN

               OPEN memb_type( p_partner_id );
                  FETCH memb_type INTO l_member_type;
               CLOSE memb_type;
               IF l_member_type='SUBSIDIARY' THEN

         	       IF l_global_mmbr_reqd_flag ='Y' THEN
         	          l_eligible_flag:=isGlobalEnrolled(p_to_program_id ,p_partner_id);
         	       END IF;
         	       IF l_eligible_flag=false THEN
         	          x_elig_flag := 'N' ;
         	       END IF;
               END IF;
               -- end of member type check
            END IF;
         ELSE
            x_elig_flag := 'N' ;
         END IF;
      END IF; -- end : if its upgrade
   ELSE
      x_elig_flag :=  'N';
   END IF; -- end of if for preewquite cache
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;
  -- Check for commit
  IF FND_API.to_boolean(p_commit) THEN
     COMMIT;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO isPartnerEligible;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO isPartnerEligible;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );
   WHEN OTHERS THEN
   ROLLBACK TO  isPartnerEligible;
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

END isPartnerEligible;

END Pv_Enrq_Bins_PVT;

/
