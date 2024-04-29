--------------------------------------------------------
--  DDL for Package Body PV_PG_ENRL_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_ENRL_REQUESTS_PVT" as
/* $Header: pvxvperb.pls 120.7 2006/02/08 09:21:50 dgottlie ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrl_Requests_PVT
-- Purpose
--
-- History
--          20-OCT-2002    Karen.Tsao      Created
--          27-NOV-2002    Karen.Tsao      1. Modified to change datatype for order_header_id.
--                                         2. Debug message to be wrapped with IF check.
--                                         3. Replace of COPY with NOCOPY string.
--          27-AUG-2003    Karen.Tsao      Update the Create_Pg_Enrl_Requests, Update_Pg_Enrl_Requests,
--                                         and Complete_Enrl_Request_Rec with two new columns in
--                                         pv_pg_enrl_requests: membership_fee, transactional_curr_code
--          29-AUG-2003    Karen.Tsao      Modified for column name change: transactional_curr_code to trans_curr_code
--          26-SEP-2003    pukken	       Added dependent_program_id column in  pv_pg_enrl_requests record
--          23-FEB-2004    pukken          Modified code in is_payment_exists function.
--          01-APR-2004    Karen.Tsao      Modified Is_Contract_Exists for bug 3540615.
--          20-APR-2005    Karen.Tsao      Modified for R12.
--	    05-JUL-2005    kvattiku	   Added trxn_extension_id column in  pv_pg_enrl_requests record
--          06-SEP-2005    Karen.Tsao      Move the return call to the end of Is_Contract_Exists.
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pg_Enrl_Requests_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvperb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--


PROCEDURE Default_Enrl_Request_Items (
   p_enrl_request_rec IN  enrl_request_rec_type ,
   x_enrl_request_rec OUT NOCOPY enrl_request_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pg_Enrl_Requests
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enrl_request_rec            IN   enrl_request_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PV_DEBUG_HIGH_ON CONSTANT BOOLEAN := Fnd_Msg_Pub.CHECK_MSG_LEVEL(Fnd_Msg_Pub.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT BOOLEAN := Fnd_Msg_Pub.CHECK_MSG_LEVEL(Fnd_Msg_Pub.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := Fnd_Msg_Pub.CHECK_MSG_LEVEL(Fnd_Msg_Pub.G_MSG_LVL_DEBUG_MEDIUM);


FUNCTION Is_Payment_Exists(p_enrl_request_rec IN OUT  NOCOPY enrl_request_rec_type)
RETURN VARCHAR2 IS

any_payment 		VARCHAR2(1);
l_order_header_id       NUMBER;
l_waive_fee_flag        VARCHAR2(1);
l_memb_type             VARCHAR2(30);

CURSOR fee_csr(p_prg_id NUMBER) IS
SELECT no_fee_flag,waive_subsidiary_fee_flag
FROM pv_partner_program_b
WHERE program_id = p_prg_id;

CURSOR order_csr(p_inv_id NUMBER) IS
SELECT order_header_id
FROM   PV_PG_INVITE_HEADERS_b
WHERE  invite_header_id=p_inv_id;

CURSOR membertype_csr(p_ptr_id NUMBER) IS
SELECT attr_value
FROM   pv_enty_attr_values
WHERE  entity='PARTNER'
AND    entity_id=p_ptr_id
AND    attribute_id=6
AND    latest_flag='Y';



BEGIN

   OPEN fee_csr(p_enrl_request_rec.program_id);
      FETCH fee_csr INTO any_payment,l_waive_fee_flag;
   CLOSE fee_csr;

   IF (any_payment = 'Y') THEN
      RETURN 'N';
   END IF;

   --if invitea headre id exists then payment exists
   -- if paymenst exists , then we should populate order header id
   --and payment status as ' AUTHORIZED_PAYMENT'--check
   IF  p_enrl_request_rec.invite_header_id is not NULL THEN
       --means payment exists
   OPEN order_csr (p_enrl_request_rec.invite_header_id);
      FETCH order_csr INTO l_order_header_id;
   CLOSE order_csr;
      IF (l_order_header_id is not NULL) THEN
         p_enrl_request_rec.order_header_id:=l_order_header_id;
         p_enrl_request_rec.payment_status_code:= 'AUTHORIZED_PAYMENT';
         RETURN 'Y';
      END IF;
   END IF;
   OPEN membertype_csr(p_enrl_request_rec.partner_id);
      FETCH membertype_csr INTO l_memb_type;
   CLOSE membertype_csr;
   IF l_memb_type='SUBSIDIARY' AND l_waive_fee_flag='Y' THEN
      RETURN 'N';
   ELSE
      RETURN 'Y';
   END IF;

END Is_Payment_Exists;

FUNCTION Is_Contract_Exists(p_program_id IN NUMBER, p_partner_id IN NUMBER, p_enrl_request_id IN NUMBER)
RETURN VARCHAR2 IS
   x_return_status   VARCHAR2(32767);
   x_msg_count       NUMBER;
   x_msg_data        VARCHAR2(32767);
   l_contract_id     NUMBER;
   x_exist           VARCHAR2(1);
   L_API_NAME        CONSTANT VARCHAR2(30) := 'Is_Contract_Exists';

BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      PVX_UTILITY_PVT.debug_message('p_program_id = ' || p_program_id);
      PVX_UTILITY_PVT.debug_message('p_partner_id = ' || p_partner_id);
      PVX_UTILITY_PVT.debug_message('p_enrl_request_id = ' || p_enrl_request_id);
   END IF;

   PV_Partner_Contracts_PVT.Is_Contract_Exist_Then_Create(
           p_api_version_number      => 1.0
          ,p_init_msg_list           => FND_API.G_FALSE
          ,x_return_status           => x_return_status
          ,x_msg_count               => x_msg_count
          ,x_msg_data                => x_msg_data
          ,p_partner_id              => p_partner_id
          ,p_program_id              => p_program_id
          ,p_enrl_request_id         => p_enrl_request_id
          ,x_exist                   => x_exist
   );


   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('x_exist: ' || x_exist);
      PVX_UTILITY_PVT.debug_message('x_return_status: ' || x_return_status);
   END IF;

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   FND_MSG_PUB.Count_And_Get
   ( p_encoded => FND_API.G_FALSE,
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
   );

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

   RETURN x_exist;

EXCEPTION

   WHEN Fnd_Api.G_EXC_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME, l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
     );

END Is_Contract_Exists;


FUNCTION Get_Custom_Setup_Id(p_enrl_request_id IN NUMBER, p_enrl_request_rec IN OUT NOCOPY enrl_request_rec_type )
RETURN NUMBER IS

custom_setup_id 	NUMBER;
any_contract 		VARCHAR2(1);
any_payment 		VARCHAR2(1);
BEGIN
     any_contract := Is_Contract_Exists(p_enrl_request_rec.program_id, p_enrl_request_rec.partner_id, p_enrl_request_id);
     any_payment := Is_Payment_Exists(p_enrl_request_rec);
     IF (any_contract = 'Y') THEN

          IF (any_payment = 'Y') THEN

               --WITH contract, WITH payment
               custom_setup_id := 7004;

          ELSE

               --WITH contract, no payment
               custom_setup_id := 7006;
          END IF;

     ELSE

          IF (any_payment = 'Y') THEN

               --no contract, WITH payment
               custom_setup_id := 7005;

          ELSE

               --no contract, no payment
               custom_setup_id := 7007;
          END IF;

	 END IF;
     RETURN custom_setup_id;


END Get_Custom_Setup_Id;



PROCEDURE Create_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_request_rec              IN   enrl_request_rec_type  := g_miss_enrl_request_rec,
    x_enrl_request_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Pg_Enrl_Requests';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := Fnd_Api.G_MISS_NUM;
   l_enrl_request_id              NUMBER;
   l_custom_setup_id			  NUMBER;
   l_score_result_code         VARCHAR2(30) := p_enrl_request_rec.score_result_code;
   l_dummy                     NUMBER;
   l_enrl_request_rec  enrl_request_rec_type:= g_miss_enrl_request_rec;
   CURSOR c_id IS
      SELECT pv_pg_enrl_requests_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_PG_ENRL_REQUESTS
      WHERE enrl_request_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_pg_enrl_requests_pvt;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF Fnd_Global.USER_ID IS NULL
      THEN
        FND_MESSAGE.Set_Name ('PV', 'USER_PROFILE_MISSING');
        FND_MSG_PUB.Add;
        RAISE Fnd_Api.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          Pvx_Utility_Pvt.debug_message('PRIVATE API: Validate_Pg_Enrl_Requests');
          END IF;

          -- Invoke validation procedures
          Validate_pg_enrl_requests(
            p_api_version_number     => 1.0,
            p_init_msg_list    => Fnd_Api.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => Jtf_Plsql_Api.g_create,
            p_enrl_request_rec  =>  p_enrl_request_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_enrl_request_rec.enrl_request_id IS NULL OR p_enrl_request_rec.enrl_request_id = Fnd_Api.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_enrl_request_id;
         CLOSE c_id;

         OPEN c_id_exists(l_enrl_request_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_enrl_request_id := p_enrl_request_rec.enrl_request_id;
   END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message( 'PRIVATE API: Calling CREATE TABLE handler');
      END IF;

      IF l_score_result_code IS NULL THEN
         l_score_result_code := 'NOT_EVALUATED';
      END IF;
      l_enrl_request_rec:=p_enrl_request_rec;
      l_custom_setup_id := Get_Custom_Setup_Id(l_enrl_request_id, l_enrl_request_rec);


      -- Invoke table handler(Pv_Pg_Enrl_Requests_Pkg.Insert_Row)
      Pv_Pg_Enrl_Requests_Pkg.Insert_Row(
          px_enrl_request_id  => l_enrl_request_id,
          px_object_version_number  => l_object_version_number,
          p_program_id  => p_enrl_request_rec.program_id,
          p_partner_id  => p_enrl_request_rec.partner_id,
          p_custom_setup_id  => l_custom_setup_id,
          p_requestor_resource_id  => p_enrl_request_rec.requestor_resource_id,
          p_request_status_code  => p_enrl_request_rec.request_status_code,
          p_enrollment_type_code  => p_enrl_request_rec.enrollment_type_code,
          p_request_submission_date  => p_enrl_request_rec.request_submission_date,
          p_order_header_id  => l_enrl_request_rec.order_header_id,
          p_contract_id  => p_enrl_request_rec.contract_id,
          p_request_initiated_by_code  => p_enrl_request_rec.request_initiated_by_code,
          p_invite_header_id  => p_enrl_request_rec.invite_header_id,
          p_tentative_start_date  => p_enrl_request_rec.tentative_start_date,
          p_tentative_end_date  => p_enrl_request_rec.tentative_end_date,
          p_contract_status_code  => p_enrl_request_rec.contract_status_code,
          p_payment_status_code  => l_enrl_request_rec.payment_status_code,
          p_score_result_code  => l_score_result_code,
          p_created_by  => Fnd_Global.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => Fnd_Global.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => Fnd_Global.conc_login_id,
          p_membership_fee  => p_enrl_request_rec.membership_fee,
          p_dependent_program_id  => p_enrl_request_rec.dependent_program_id,
          p_trans_curr_code  => p_enrl_request_rec.trans_curr_code,
          p_contract_binding_contact_id  => p_enrl_request_rec.contract_binding_contact_id,
          p_contract_signed_date  => p_enrl_request_rec.contract_signed_date,
          p_trxn_extension_id  => p_enrl_request_rec.trxn_extension_id,
	  p_attribute1 => p_enrl_request_rec.attribute1,
	  p_attribute2 => p_enrl_request_rec.attribute2,
	  p_attribute3 => p_enrl_request_rec.attribute3,
	  p_attribute4 => p_enrl_request_rec.attribute4,
	  p_attribute5 => p_enrl_request_rec.attribute5,
	  p_attribute6 => p_enrl_request_rec.attribute6,
	  p_attribute7 => p_enrl_request_rec.attribute7,
	  p_attribute8 => p_enrl_request_rec.attribute8,
	  p_attribute9 => p_enrl_request_rec.attribute9,
	  p_attribute10 => p_enrl_request_rec.attribute10,
	  p_attribute11 => p_enrl_request_rec.attribute11,
	  p_attribute12 => p_enrl_request_rec.attribute12,
	  p_attribute13 => p_enrl_request_rec.attribute13,
	  p_attribute14 => p_enrl_request_rec.attribute14,
	  p_attribute15 => p_enrl_request_rec.attribute15
);

          x_enrl_request_id := l_enrl_request_id;
      IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

      -- invoke Create_Gc_Responses_Rec
      Pv_Ge_Chklst_Resp_Pvt.Create_Enrq_Responses(
            p_api_version_number  => 1.0,
            p_init_msg_list       => Fnd_Api.G_FALSE,
            p_commit              =>Fnd_Api.G_FALSE,
            p_validation_level    => p_validation_level,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_programId           => p_enrl_request_rec.program_id,
            p_enrollmentId        => l_enrl_request_id);

      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

--
-- End of API body
--

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'END');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
        FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
        FND_MSG_PUB.Add;

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Create_Pg_Enrl_Requests;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pg_Enrl_Requests
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enrl_request_rec            IN   enrl_request_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN  NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_request_rec               IN    enrl_request_rec_type
    )

 IS


CURSOR c_get_pg_enrl_requests(enrl_request_id NUMBER) IS
    SELECT *
    FROM  PV_PG_ENRL_REQUESTS
    WHERE  enrl_request_id = p_enrl_request_rec.enrl_request_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Pg_Enrl_Requests';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_enrl_request_id    NUMBER;
l_ref_enrl_request_rec  c_get_Pg_Enrl_Requests%ROWTYPE ;
l_tar_enrl_request_rec  enrl_request_rec_type := P_enrl_request_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_pg_enrl_requests_pvt;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: - OPEN CURSOR TO SELECT');
      END IF;

      OPEN c_get_Pg_Enrl_Requests( l_tar_enrl_request_rec.enrl_request_id);

      FETCH c_get_Pg_Enrl_Requests INTO l_ref_enrl_request_rec  ;

       IF ( c_get_Pg_Enrl_Requests%NOTFOUND) THEN
         FND_MESSAGE.Set_Name ('PV', 'API_MISSING_UPDATE_TARGET');
         FND_MESSAGE.Set_Token('INFO', 'Pg_Enrl_Requests');
         FND_MSG_PUB.Add;
         RAISE Fnd_Api.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       Pvx_Utility_Pvt.debug_message('PRIVATE API: - CLOSE CURSOR');
       END IF;
       CLOSE     c_get_Pg_Enrl_Requests;


      IF (l_tar_enrl_request_rec.object_version_number IS NULL OR
          l_tar_enrl_request_rec.object_version_number = Fnd_Api.G_MISS_NUM ) THEN
         FND_MESSAGE.Set_Name ('PV', 'API_VERSION_MISSING');
         FND_MESSAGE.Set_Token('INFO', 'Pg_Enrl_Requests');
         FND_MSG_PUB.Add;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      -- Check Whether record has been changed by someone else
      IF (l_tar_enrl_request_rec.object_version_number <> l_ref_enrl_request_rec.object_version_number) THEN
         FND_MESSAGE.Set_Name ('PV', 'API_RECORD_CHANGED');
         FND_MESSAGE.Set_Token('INFO', 'Pg_Enrl_Requests');
         FND_MSG_PUB.Add;
         RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


      IF ( P_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          Pvx_Utility_Pvt.debug_message('PRIVATE API: Validate_Pg_Enrl_Requests');
          END IF;

          -- Invoke validation procedures
          Validate_pg_enrl_requests(
            p_api_version_number     => 1.0,
            p_init_msg_list    => Fnd_Api.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => Jtf_Plsql_Api.g_update,
            p_enrl_request_rec  =>  p_enrl_request_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: Calling UPDATE TABLE handler');
      END IF;

      IF p_enrl_request_rec.tentative_end_date is not null and ( p_enrl_request_rec.tentative_start_date>p_enrl_request_rec.tentative_end_date ) THEN
         FND_MESSAGE.set_name('PV', 'PV_END_DATE_SMALL_START_DATE');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(Pv_Pg_Enrl_Requests_Pkg.Update_Row)
      Pv_Pg_Enrl_Requests_Pkg.Update_Row(
          p_enrl_request_id  => p_enrl_request_rec.enrl_request_id,
          p_object_version_number  => p_enrl_request_rec.object_version_number,
          p_program_id  => p_enrl_request_rec.program_id,
          p_partner_id  => p_enrl_request_rec.partner_id,
          p_custom_setup_id  => p_enrl_request_rec.custom_setup_id,
          p_requestor_resource_id  => p_enrl_request_rec.requestor_resource_id,
          p_request_status_code  => p_enrl_request_rec.request_status_code,
          p_enrollment_type_code  => p_enrl_request_rec.enrollment_type_code,
          p_request_submission_date  => p_enrl_request_rec.request_submission_date,
          p_contract_id  => p_enrl_request_rec.contract_id,
          p_request_initiated_by_code  => p_enrl_request_rec.request_initiated_by_code,
          p_invite_header_id  => p_enrl_request_rec.invite_header_id,
          p_tentative_start_date  => p_enrl_request_rec.tentative_start_date,
          p_tentative_end_date  => p_enrl_request_rec.tentative_end_date,
          p_contract_status_code  => p_enrl_request_rec.contract_status_code,
          p_payment_status_code  => p_enrl_request_rec.payment_status_code,
          p_score_result_code  => p_enrl_request_rec.score_result_code,
          p_last_updated_by  => Fnd_Global.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => Fnd_Global.conc_login_id,
          p_order_header_id  => p_enrl_request_rec.order_header_id,
          p_membership_fee  => p_enrl_request_rec.membership_fee,
          p_dependent_program_id  => p_enrl_request_rec.dependent_program_id,
          p_trans_curr_code  => p_enrl_request_rec.trans_curr_code,
          p_contract_binding_contact_id  => p_enrl_request_rec.contract_binding_contact_id,
          p_contract_signed_date  => p_enrl_request_rec.contract_signed_date,
          p_trxn_extension_id  => p_enrl_request_rec.trxn_extension_id,
	  p_attribute1 => p_enrl_request_rec.attribute1,
	  p_attribute2 => p_enrl_request_rec.attribute2,
	  p_attribute3 => p_enrl_request_rec.attribute3,
	  p_attribute4 => p_enrl_request_rec.attribute4,
	  p_attribute5 => p_enrl_request_rec.attribute5,
	  p_attribute6 => p_enrl_request_rec.attribute6,
	  p_attribute7 => p_enrl_request_rec.attribute7,
	  p_attribute8 => p_enrl_request_rec.attribute8,
	  p_attribute9 => p_enrl_request_rec.attribute9,
	  p_attribute10 => p_enrl_request_rec.attribute10,
	  p_attribute11 => p_enrl_request_rec.attribute11,
	  p_attribute12 => p_enrl_request_rec.attribute12,
	  p_attribute13 => p_enrl_request_rec.attribute13,
	  p_attribute14 => p_enrl_request_rec.attribute14,
	  p_attribute15 => p_enrl_request_rec.attribute15
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'END');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION
   WHEN PVX_Utility_PVT.API_RECORD_CHANGED THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (PV_DEBUG_HIGH_ON) THEN
         Pvx_Utility_Pvt.debug_message('PRIVATE API: - OPEN CURSOR');
      END IF;
      OPEN c_get_Pg_Enrl_Requests( l_tar_enrl_request_rec.enrl_request_id);
      FETCH c_get_Pg_Enrl_Requests INTO l_ref_enrl_request_rec;
      IF ( c_get_Pg_Enrl_Requests%NOTFOUND) THEN
         FND_MESSAGE.Set_Name ('PV', 'API_MISSING_UPDATE_TARGET');
         FND_MESSAGE.Set_Token('INFO', 'Pg_Enrl_Requests');
         FND_MSG_PUB.Add;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
           Pvx_Utility_Pvt.debug_message('PRIVATE API: - CLOSE CURSOR');
       END IF;
       CLOSE     c_get_Pg_Enrl_Requests;
       IF (l_tar_enrl_request_rec.object_version_number <> l_ref_enrl_request_rec.object_version_number) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name ('PV', 'API_RECORD_CHANGED');
         FND_MESSAGE.Set_Token('INFO', 'Pv_Pg_Enrl_Requests');
         FND_MSG_PUB.Add;
       END IF;
      Fnd_Msg_Pub.Count_And_Get (
                p_encoded => Fnd_Api.G_FALSE,
                p_count   => x_msg_count,
                p_data    => x_msg_data
         );

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
        FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
        FND_MSG_PUB.Add;
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Update_Pg_Enrl_Requests;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pg_Enrl_Requests
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enrl_request_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrl_request_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Pg_Enrl_Requests';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_pg_enrl_requests_pvt;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message( 'PRIVATE API: Calling DELETE TABLE handler');
      END IF;

      -- Invoke table handler(Pv_Pg_Enrl_Requests_Pkg.Delete_Row)
      Pv_Pg_Enrl_Requests_Pkg.Delete_Row(
          p_enrl_request_id  => p_enrl_request_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'END');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
     FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
     FND_MSG_PUB.Add;

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Delete_Pg_Enrl_Requests;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pg_Enrl_Requests
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_enrl_request_rec            IN   enrl_request_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_request_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Pg_Enrl_Requests';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_enrl_request_id                  NUMBER;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
Pv_Pg_Enrl_Requests_Pkg.Lock_Row(l_enrl_request_id,p_object_version);


 -------------------- finish --------------------------
  Fnd_Msg_Pub.count_and_get(
    p_encoded => Fnd_Api.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  Pvx_Utility_Pvt.debug_message(l_full_name ||': END');
  END IF;
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
       x_return_status := Fnd_Api.g_ret_sts_error;
      FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
      FND_MSG_PUB.Add;

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Pg_Enrl_Requests_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Lock_Pg_Enrl_Requests;




PROCEDURE check_Enrl_Request_Uk_Items(
    p_enrl_request_rec               IN   enrl_request_rec_type,
    p_validation_mode            IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := Fnd_Api.g_ret_sts_success;
      IF p_validation_mode = Jtf_Plsql_Api.g_create
      AND p_enrl_request_rec.enrl_request_id IS NOT NULL
      THEN
         l_valid_flag := Pvx_Utility_Pvt.check_uniqueness(
         'pv_pg_enrl_requests',
         'enrl_request_id = ''' || p_enrl_request_rec.enrl_request_id ||''''
         );
      END IF;

      IF l_valid_flag = Fnd_Api.g_false THEN
         FND_MESSAGE.Set_Name ('PV', 'PV_enrl_request_id_DUPLICATE');
         FND_MSG_PUB.Add;
      END IF;

END check_Enrl_Request_Uk_Items;



PROCEDURE check_Enrl_Request_Req_Items(
    p_enrl_request_rec               IN  enrl_request_rec_type,
    p_validation_mode IN VARCHAR2 := Jtf_Plsql_Api.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN

      IF p_enrl_request_rec.program_id = Fnd_Api.G_MISS_NUM OR p_enrl_request_rec.program_id IS NULL THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'PROGRAM_ID');
               FND_MSG_PUB.Add;

               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.partner_id = Fnd_Api.G_MISS_NUM OR p_enrl_request_rec.partner_id IS NULL THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'PARTNER_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

      IF p_enrl_request_rec.requestor_resource_id = Fnd_Api.G_MISS_NUM OR p_enrl_request_rec.requestor_resource_id IS NULL THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'REQUESTOR_RESOURCE_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.request_status_code = Fnd_Api.g_miss_char OR p_enrl_request_rec.request_status_code IS NULL THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'REQUEST_STATUS_CODE');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.enrollment_type_code = Fnd_Api.g_miss_char OR p_enrl_request_rec.enrollment_type_code IS NULL THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'ENROLLMENT_TYPE_CODE');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.request_initiated_by_code = Fnd_Api.g_miss_char OR p_enrl_request_rec.request_initiated_by_code IS NULL THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'REQUEST_INITIATED_BY_CODE');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


   ELSE


      IF p_enrl_request_rec.enrl_request_id = Fnd_Api.G_MISS_NUM THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'ENRL_REQUEST_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.object_version_number = Fnd_Api.G_MISS_NUM THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'OBJECT_VERSION_NUMBER');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.program_id = Fnd_Api.G_MISS_NUM THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'PROGRAM_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.partner_id = Fnd_Api.G_MISS_NUM THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'PARTNER_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.custom_setup_id = Fnd_Api.G_MISS_NUM THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'CUSTOM_SETUP_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.requestor_resource_id = Fnd_Api.G_MISS_NUM THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'REQUESTOR_RESOURCE_ID');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.request_status_code = Fnd_Api.g_miss_char THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'REQUEST_STATUS_CODE');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.enrollment_type_code = Fnd_Api.g_miss_char THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'ENROLLMENT_TYPE_CODE');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrl_request_rec.request_initiated_by_code = Fnd_Api.g_miss_char THEN
               FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
               FND_MESSAGE.Set_Token('MISS_FIELD', 'REQUEST_INITIATED_BY_CODE');
               FND_MSG_PUB.Add;
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;
   END IF;

END check_Enrl_Request_Req_Items;



PROCEDURE check_Enrl_Request_Fk_Items(
    p_enrl_request_rec IN enrl_request_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   -- Enter custom code here

END check_Enrl_Request_Fk_Items;



PROCEDURE CHECK_ENRL_REQ_LOOKUP_ITEMS(
    p_enrl_request_rec IN enrl_request_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   -- Enter custom code here

END CHECK_ENRL_REQ_LOOKUP_ITEMS;



PROCEDURE Check_Enrl_Request_Items (
    P_enrl_request_rec     IN    enrl_request_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := Fnd_Api.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Enrl_request_Uk_Items(
      p_enrl_request_rec => p_enrl_request_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_enrl_request_req_items(
      p_enrl_request_rec => p_enrl_request_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_enrl_request_FK_items(
      p_enrl_request_rec => p_enrl_request_rec,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   CHECK_ENRL_REQ_LOOKUP_ITEMS(
      p_enrl_request_rec => p_enrl_request_rec,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_enrl_request_Items;





PROCEDURE Complete_Enrl_Request_Rec (
   p_enrl_request_rec IN enrl_request_rec_type,
   x_complete_rec OUT NOCOPY enrl_request_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_pg_enrl_requests
      WHERE enrl_request_id = p_enrl_request_rec.enrl_request_id;
   l_enrl_request_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_enrl_request_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_enrl_request_rec;
   CLOSE c_complete;

   -- enrl_request_id
   IF p_enrl_request_rec.enrl_request_id IS NULL THEN
      x_complete_rec.enrl_request_id := l_enrl_request_rec.enrl_request_id;
   END IF;

   -- object_version_number
   IF p_enrl_request_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_enrl_request_rec.object_version_number;
   END IF;

   -- program_id
   IF p_enrl_request_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_enrl_request_rec.program_id;
   END IF;

   -- partner_id
   IF p_enrl_request_rec.partner_id IS NULL THEN
      x_complete_rec.partner_id := l_enrl_request_rec.partner_id;
   END IF;

   -- custom_setup_id
   IF p_enrl_request_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_enrl_request_rec.custom_setup_id;
   END IF;

   -- requestor_resource_id
   IF p_enrl_request_rec.requestor_resource_id IS NULL THEN
      x_complete_rec.requestor_resource_id := l_enrl_request_rec.requestor_resource_id;
   END IF;

   -- request_status_code
   IF p_enrl_request_rec.request_status_code IS NULL THEN
      x_complete_rec.request_status_code := l_enrl_request_rec.request_status_code;
   END IF;

   -- enrollment_type_code
   IF p_enrl_request_rec.enrollment_type_code IS NULL THEN
      x_complete_rec.enrollment_type_code := l_enrl_request_rec.enrollment_type_code;
   END IF;

   -- request_submission_date
   IF p_enrl_request_rec.request_submission_date IS NULL THEN
      x_complete_rec.request_submission_date := l_enrl_request_rec.request_submission_date;
   END IF;

   -- contract_id
   IF p_enrl_request_rec.contract_id IS NULL THEN
      x_complete_rec.contract_id := l_enrl_request_rec.contract_id;
   END IF;

   -- request_initiated_by_code
   IF p_enrl_request_rec.request_initiated_by_code IS NULL THEN
      x_complete_rec.request_initiated_by_code := l_enrl_request_rec.request_initiated_by_code;
   END IF;

   -- invite_header_id
   IF p_enrl_request_rec.invite_header_id IS NULL THEN
      x_complete_rec.invite_header_id := l_enrl_request_rec.invite_header_id;
   END IF;

   -- tentative_start_date
   IF p_enrl_request_rec.tentative_start_date IS NULL THEN
      x_complete_rec.tentative_start_date := l_enrl_request_rec.tentative_start_date;
   END IF;

   -- tentative_end_date
   IF p_enrl_request_rec.tentative_end_date IS NULL THEN
      x_complete_rec.tentative_end_date := l_enrl_request_rec.tentative_end_date;
   END IF;

   -- contract_status_code
   IF p_enrl_request_rec.contract_status_code IS NULL THEN
      x_complete_rec.contract_status_code := l_enrl_request_rec.contract_status_code;
   END IF;

   -- payment_status_code
   IF p_enrl_request_rec.payment_status_code IS NULL THEN
      x_complete_rec.payment_status_code := l_enrl_request_rec.payment_status_code;
   END IF;

   -- score_result_code
   IF p_enrl_request_rec.score_result_code IS NULL THEN
      x_complete_rec.score_result_code := l_enrl_request_rec.score_result_code;
   END IF;

   -- created_by
   IF p_enrl_request_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_enrl_request_rec.created_by;
   END IF;

   -- creation_date
   IF p_enrl_request_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_enrl_request_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_enrl_request_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_enrl_request_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_enrl_request_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_enrl_request_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_enrl_request_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_enrl_request_rec.last_update_login;
   END IF;

   -- order_header_id
   IF p_enrl_request_rec.order_header_id IS NULL THEN
      x_complete_rec.order_header_id := l_enrl_request_rec.order_header_id;
   END IF;

   -- membership_fee
   IF p_enrl_request_rec.membership_fee IS NULL THEN
      x_complete_rec.membership_fee := l_enrl_request_rec.membership_fee;
   END IF;


   -- dependent_program_id
   IF p_enrl_request_rec.dependent_program_id IS NULL THEN
      x_complete_rec.dependent_program_id := l_enrl_request_rec.dependent_program_id;
   END IF;


   -- trans_curr_code
   IF p_enrl_request_rec.trans_curr_code IS NULL THEN
      x_complete_rec.trans_curr_code := l_enrl_request_rec.trans_curr_code;
   END IF;

   -- contract_binding_contact_id
   IF p_enrl_request_rec.contract_binding_contact_id IS NULL THEN
      x_complete_rec.contract_binding_contact_id := l_enrl_request_rec.contract_binding_contact_id;
   END IF;

   -- contract_signed_date
   IF p_enrl_request_rec.contract_signed_date IS NULL THEN
      x_complete_rec.contract_signed_date := l_enrl_request_rec.contract_signed_date;
   END IF;

   -- trxn_extension_id
   IF p_enrl_request_rec.trxn_extension_id IS NULL THEN
      x_complete_rec.trxn_extension_id := l_enrl_request_rec.trxn_extension_id;
   END IF;


   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Enrl_Request_Rec;




PROCEDURE Default_Enrl_Request_Items ( p_enrl_request_rec IN enrl_request_rec_type ,
                                x_enrl_request_rec OUT NOCOPY enrl_request_rec_type )
IS
   l_enrl_request_rec enrl_request_rec_type := p_enrl_request_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Pg_Enrl_Requests(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN   NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
    p_enrl_request_rec               IN   enrl_request_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Pg_Enrl_Requests';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_enrl_request_rec       enrl_request_rec_type;
l_enrl_request_rec_out   enrl_request_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_pg_enrl_requests_;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;


      IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
              Check_enrl_request_Items(
                 p_enrl_request_rec        => p_enrl_request_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
              ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
         Default_Enrl_Request_Items (p_enrl_request_rec => p_enrl_request_rec ,
                                x_enrl_request_rec => l_enrl_request_rec) ;
      END IF ;


      Complete_enrl_request_Rec(
         p_enrl_request_rec        => l_enrl_request_rec,
         x_complete_rec            => l_enrl_request_rec_out
      );

      l_enrl_request_rec := l_enrl_request_rec_out;

      IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
         Validate_enrl_request_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => Fnd_Api.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_enrl_request_rec           =>    l_enrl_request_rec);

              IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                 RAISE Fnd_Api.G_EXC_ERROR;
              ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                 RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'START');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: ' || l_api_name || 'END');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
        FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
        FND_MSG_PUB.Add;

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Pg_Enrl_Requests_;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Pg_Enrl_Requests_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Pg_Enrl_Requests_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Validate_Pg_Enrl_Requests;


PROCEDURE Validate_Enrl_Request_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrl_request_rec               IN    enrl_request_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('PRIVATE API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_enrl_request_Rec;

END Pv_Pg_Enrl_Requests_Pvt;

/
