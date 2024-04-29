--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_CONTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_CONTRACTS_PVT" as
/* $Header: pvxvpcob.pls 120.3 2005/09/07 10:25:44 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Contracts_PVT
-- Purpose
--
-- History
--        18-DEC-2002    Karen.Tsao     Made a call to PV_Partner_Geo_Match_PVT.Get_Matched_Geo_Hierarchy_Id
--                                      to get the geography hierarchy id.
--        28-DEC-2003    Karen.Tsao     Modified the query in cursor c_get_contract_id.
--        01-APR-2004    Karen.Tsao     Fixed for bug 3540615. Added API Is_Contract_Exists.
--        29-JUN-2004    Karen.Tsao     Fixed for sql repository issue (8944997).
--        09-DEC-2004    Karen.Tsao     Modified for 11.5.11.
--        02-MAY-2004    Karen.Tsao     Took out Is_Contract_Exists() because it is not used.
--        02-MAY-2004    Karen.Tsao     Modified for language enhancement.
--        06-SEP-2004    Karen.Tsao     Added more debug messages.
--
-- NOTE
--
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Partner_Contracts_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpcob.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Get_Appropriate_Contract
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--      p_partner_party_id           IN   NUMBER
--      p_program_id                 IN   NUMBER
--
--   OUT
--      x_contract_id                OUT  NUMBER
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   End of Comments
--   ==============================================================================

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

function get_contract_response_options( p_geo_hierarchy_id in varchar2 )
  return varchar2
  is
      l_str  varchar2(2000) default null;
      l_sep  varchar2(2) default null;
  begin
      for x in ( select MEANING
                 from PV_PROGRAM_PAYMENT_MODE pm, PV_LOOKUPS lk
                 where pm.GEO_HIERARCHY_ID = p_geo_hierarchy_id
                 and pm.MODE_TYPE = 'CONTRACT'
                 and lk.lookup_type = 'PV_CONTRACT_RESPONSE'
                 and lk.lookup_code = pm.mode_of_payment
                 and lk.enabled_flag = 'Y'
                 and NVL(lk.start_date_active, SYSDATE) <= SYSDATE
                 and NVL(lk.end_date_active, SYSDATE) >= SYSDATE
                 order by meaning) loop
          l_str := l_str || l_sep || x.MEANING;
          l_sep := ', ';
      end loop;
      return l_str;
  end;

PROCEDURE Is_Contract_Exist_Then_Create(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2

   ,p_program_id                 IN   NUMBER
   ,p_partner_id                 IN   NUMBER
   ,p_enrl_request_id            IN   NUMBER

   ,x_exist                      OUT  NOCOPY  VARCHAR2

   --,x_contract_status_tbl        OUT  NOCOPY  JTF_VARCHAR2_TABLE_100
   --,x_program_name_tbl           OUT  NOCOPY  JTF_VARCHAR2_TABLE_100
   --,x_program_id_tbl             OUT  NOCOPY  JTF_NUMBER_TABLE
   --,x_enrl_request_id_tbl        OUT  NOCOPY  JTF_NUMBER_TABLE
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Is_Contract_Exist_Then_Create';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

   CURSOR c_get_partner_party_id IS
      SELECT partner_party_id
      FROM   pv_partner_profiles
      WHERE  partner_id = p_partner_id;

   CURSOR c_get_geo_hierarchy_id (cv_partner_id NUMBER, cv_program_id NUMBER) IS
      SELECT   ppc.geo_hierarchy_id
      FROM     pv_enty_attr_values eav, pv_program_contracts ppc, okc_terms_templates_all term
      WHERE    eav.entity_id = cv_partner_id
      AND      eav.attribute_id = 6
      AND      eav.entity = 'PARTNER'
      AND      eav.latest_flag = 'Y'
      AND      eav.enabled_flag = 'Y'
      AND      ppc.member_type_code = eav.attr_value
      AND      program_id = cv_program_id
      AND      ppc.contract_id = term.template_id
      AND      term.start_date <= sysdate
      AND      (term.end_date is null or term.end_date > sysdate);

   CURSOR c_get_contract_id (cv_partner_id NUMBER, cv_program_id NUMBER, cv_geo_hierarchy_id NUMBER) IS
      SELECT   ppc.contract_id
      FROM     pv_enty_attr_values eav, pv_program_contracts ppc, okc_terms_templates_all term
      WHERE    eav.entity_id = cv_partner_id
      AND      eav.attribute_id = 6
      AND      eav.entity = 'PARTNER'
      AND      eav.latest_flag = 'Y'
      AND      eav.enabled_flag = 'Y'
      AND      ppc.member_type_code = eav.attr_value
      AND      program_id = cv_program_id
      AND      ppc.contract_id = term.template_id
      AND      term.start_date <= sysdate
      AND      (term.end_date is null or term.end_date > sysdate)
      AND      ppc.geo_hierarchy_id = cv_geo_hierarchy_id;


   l_geo_hierarchy_id_tbl		JTF_NUMBER_TABLE   		:= JTF_NUMBER_TABLE();
   l_contract_id  		      NUMBER;
   l_geo_hierarchy_id         NUMBER;
   l_geo_cnt                  NUMBER;
   l_partner_party_id         NUMBER;
   l_template_id              NUMBER;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Is_Contract_Exist_Then_Create;

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

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('p_program_id = ' || p_program_id);
   END IF;

   l_geo_cnt := 1;
   FOR x IN c_get_geo_hierarchy_id (p_partner_id, p_program_id) LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('x.GEO_HIERARCHY_ID:' || x.GEO_HIERARCHY_ID);
      END IF;

      l_geo_hierarchy_id_tbl.extend;
      l_geo_hierarchy_id_tbl(l_geo_cnt) := x.GEO_HIERARCHY_ID;
      l_geo_cnt := l_geo_cnt + 1;
   END LOOP;

   FOR x IN c_get_partner_party_id LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('x.partner_party_id:' || x.partner_party_id);
      END IF;

      l_partner_party_id := x.partner_party_id;
   END LOOP;

   PV_Partner_Geo_Match_PVT.Get_Matched_Geo_Hierarchy_Id(
        p_api_version_number      => 1.0
       ,p_init_msg_list           => FND_API.G_FALSE
       ,x_return_status           => x_return_status
       ,x_msg_count               => x_msg_count
       ,x_msg_data                => x_msg_data
       ,p_partner_party_id        => l_partner_party_id
       ,p_geo_hierarchy_id        => l_geo_hierarchy_id_tbl
       ,x_geo_hierarchy_id        => l_geo_hierarchy_id
   );
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      FND_MESSAGE.SET_NAME('PV','PV_GET_MATCHED_GEO_HIER_ID');
      FND_MSG_PUB.Add;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF l_geo_hierarchy_id is not null THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('l_geo_hierarchy_id is not null');
         PVX_UTILITY_PVT.debug_message('l_geo_hierarchy_id = ' || l_geo_hierarchy_id);
      END IF;

      FOR y IN c_get_contract_id (p_partner_id, p_program_id, l_geo_hierarchy_id)
      LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('y.contract_id = ' || y.contract_id);
         END IF;

         OKC_TERMS_UTIL_GRP.get_translated_template(
             p_api_version                   => 1.0
            ,p_init_msg_list                 => FND_API.G_FALSE
            ,p_template_id                   => y.contract_id
            ,p_language                      => userenv('LANG')
            ,p_document_type	               => 'PV_PARTNER_PROGRAM'
            ,p_validity_date	               => SYSDATE
            ,x_return_status                 => x_return_status
            ,x_msg_data                      => x_msg_data
            ,x_msg_count                     => x_msg_count
            ,x_template_id                   => l_template_id
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PV','PV_GET_TRANS_TMPL_ERROR_OUT');
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('l_template_id = ' || l_template_id);
         END IF;

         -- If there is an appropriate contract, instantiate the T's and C's here
         OKC_TERMS_COPY_GRP.COPY_TERMS(
             p_api_version                   => 1.0
            ,p_init_msg_list                 => FND_API.G_FALSE
            ,p_commit                        => FND_API.G_FALSE
            ,p_template_id                   => l_template_id
            ,p_target_doc_type               => 'PV_PARTNER_PROGRAM'
            ,p_target_doc_id	               => p_enrl_request_id
            ,p_article_effective_date	      => null
            ,p_retain_deliverable	         => null
            ,p_target_contractual_doctype	   => null
            ,p_target_response_doctype 	   => null
            ,p_internal_party_id	            => null
            ,p_internal_contact_id	         => null
            ,p_external_party_id	            => null
            ,p_external_party_site_id	      => null
            ,p_external_contact_id	         => null
            ,p_validate_commit	            => null
            ,p_validation_string	            => null
            ,p_document_number	            => p_enrl_request_id
            ,x_return_status                 => x_return_status
            ,x_msg_data                      => x_msg_data
            ,x_msg_count                     => x_msg_count
         );

         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('x_return_status: ' || x_return_status);
         END IF;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            FND_MESSAGE.SET_NAME('PV','PV_COPY_TERMS_ERROR_OUT');
            FND_MSG_PUB.Add;
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END LOOP;
      x_exist := 'Y';
   ELSE
      IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message('l_geo_hierarchy_id is not null');
        PVX_UTILITY_PVT.debug_message('x_exist is N');
      END IF;
      x_exist := 'N';
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Is_Contract_Exist_Then_Create;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Is_Contract_Exist_Then_Create;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Is_Contract_Exist_Then_Create;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

END Is_Contract_Exist_Then_Create;

PROCEDURE Get_Contract_Response_Options(
     p_partner_party_id           IN   NUMBER
    ,x_cntr_resp_opt_tbl          OUT  NOCOPY   JTF_VARCHAR2_TABLE_200
)
IS
  l_api_name    CONSTANT  VARCHAR2(45) := 'Get_Contract_Response_Options';
  l_full_name   CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


  CURSOR c_cntr_geo_hierarchy_ids IS
     SELECT geo_hierarchy_id
     FROM PV_PROGRAM_PAYMENT_MODE
     where program_id is null
     and   MODE_TYPE = 'CONTRACT'
     group by geo_hierarchy_id;

  CURSOR c_get_cntr_resp_opt(l_geo_hierarchy_Id NUMBER) IS
     SELECT l.lookup_code, l.meaning
     from pv_lookups l, PV_PROGRAM_PAYMENT_MODE p
     where l.lookup_code = p.mode_of_payment
     and l.lookup_type = 'PV_CONTRACT_RESPONSE'
     and l.enabled_flag = 'Y'
     and p.program_id is null
     and  p.geo_hierarchy_id = l_geo_hierarchy_Id
     and p.MODE_TYPE = 'CONTRACT'
     AND NVL(l.start_date_active, SYSDATE)<=SYSDATE
     AND NVL(l.end_date_active, SYSDATE)>=SYSDATE
     AND l.lookup_code <> 'REJECT'
     union all
     SELECT l.lookup_code, l.meaning
     from pv_lookups l
     where l.lookup_type = 'PV_CONTRACT_RESPONSE'
     and l.enabled_flag = 'Y'
     AND NVL(l.start_date_active, SYSDATE)<=SYSDATE
     AND NVL(l.end_date_active, SYSDATE)>=SYSDATE
     AND l.lookup_code = 'REJECT'
     order by meaning;

  CURSOR c_get_all_cntr_resp_opt IS
     SELECT lookup_code, meaning
     from pv_lookups l
     where l.lookup_type = 'PV_CONTRACT_RESPONSE'
     and l.enabled_flag = 'Y'
     AND NVL(l.start_date_active, SYSDATE)<=SYSDATE
     AND NVL(l.end_date_active, SYSDATE)>=SYSDATE
     order by meaning;

  l_geo_hierarchy_ids_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_geo_hierarchy_id        NUMBER;
  l_get_all_cntr_types    boolean := false;
  l_msg_count        number;
  l_msg_data         varchar2(200);
  l_return_status    VARCHAR2(1);


BEGIN

   x_cntr_resp_opt_tbl := JTF_VARCHAR2_TABLE_200();

   for x in c_cntr_geo_hierarchy_ids loop
         l_geo_hierarchy_ids_tbl.extend;
         l_geo_hierarchy_ids_tbl(l_geo_hierarchy_ids_tbl.count) := x.geo_hierarchy_id;
   end loop;


   IF l_geo_hierarchy_ids_tbl.count > 0 THEN

      PV_Partner_Geo_Match_PVT.get_Matched_Geo_Hierarchy_Id(
        p_api_version_number         =>  1.0
       ,p_init_msg_list              =>  FND_API.G_TRUE
       ,x_return_status              =>  l_return_status
       ,x_msg_count                  =>  l_msg_count
       ,x_msg_data                   =>  l_msg_Data
       ,p_partner_party_id           =>  p_partner_party_id
       ,p_geo_hierarchy_id           =>  l_geo_hierarchy_ids_tbl
       ,x_geo_hierarchy_id           =>  l_geo_hierarchy_id
      );

      IF l_return_Status <> FND_API.G_RET_STS_SUCCESS or  l_geo_hierarchy_id is null THEN
        l_get_all_cntr_types := TRUE;
      END IF;
   ELSE
      l_get_all_cntr_types := TRUE;
   END IF;


   IF l_get_all_cntr_types THEN
     for x in c_get_all_cntr_resp_opt loop
       x_cntr_resp_opt_tbl.extend;
       x_cntr_resp_opt_tbl(x_cntr_resp_opt_tbl.count) := x.lookup_code||'%'||x.meaning;
      END loop;
   ELSE
     for x in c_get_cntr_resp_opt(l_geo_hierarchy_Id) loop
       x_cntr_resp_opt_tbl.extend;
       x_cntr_resp_opt_tbl(x_cntr_resp_opt_tbl.count) := x.lookup_code||'%'||x.meaning;
     END loop;
   END IF;

  END Get_Contract_Response_Options;

END PV_Partner_Contracts_PVT;

/
