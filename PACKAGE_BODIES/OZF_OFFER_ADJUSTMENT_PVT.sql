--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJUSTMENT_PVT" as
/* $Header: ozfvoadb.pls 120.6.12010000.2 2009/12/03 08:42:41 nepanda ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adjustment_PVT
-- Purpose
--
-- History
--   Thu Mar 30 2006:1/23 PM RSSHARMA New Adjustment changes. While activating, user offer_backdate api to get final status and budget updated flag.
--  Mon May 22 2006:12/1 PM RSSHARMA Fixed debug to print only on debug high
-- Tue Aug 15 2006:3/26 PM RSSHARMA Fixed bug # 5468261. Fixed query for if_lines_exist
-- Thu Dec 3rd 2009 NEPANDA : fix for bug 9149865
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Adjustment_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvoadb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Offer_Adj_Items (
   p_offer_adj_rec IN  offer_adj_rec_type ,
   x_offer_adj_rec OUT NOCOPY offer_adj_rec_type
) ;



--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           get_budget_start_date
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_qp_list_header_id      IN   NUMBER     Required
--
--   RETURNS
--       Min Start Date of all the budgets attached to the offer
--   History
--   Thu May 27 2004:2/29 PM RSSJARMA Created
--   NOTE
--      Concious decision to return min start date as this makes sure that all the budgets are active by the date of adjustment
--   End of Comments
--   ==============================================================================
FUNCTION get_budget_start_date
( p_qp_list_header_id IN NUMBER)
RETURN DATE
IS
CURSOR c_budget_start_date(p_qp_list_header_id NUMBER) is
SELECT MIN(start_date_active) FROM ozf_funds_all_b
WHERE fund_id IN ( SELECT budget_source_id FROM ozf_act_budgets where arc_act_budget_used_by = 'OFFR' and act_budget_used_by_id = p_qp_list_header_id);
l_budget_start_date DATE;
BEGIN
OPEN c_budget_start_date(p_qp_list_header_id );
FETCH c_budget_start_date INTO l_budget_start_date;
CLOSE c_budget_start_date;
RETURN l_budget_start_date;
END get_budget_start_date;

FUNCTION isBudgetOffer(p_listHeaderId NUMBER)
RETURN VARCHAR2
IS
CURSOR c_budgetOffer(cp_listHeaderId NUMBER) IS
SELECT nvl(budget_offer_yn,'N')
FROM ozf_offers
WHERE qp_list_header_id = cp_listHeaderId;
l_budgetOffer VARCHAR2(1);
BEGIN
OPEN c_budgetOffer(cp_listHeaderId => p_listHeaderId);
FETCH c_budgetOffer INTO l_budgetOffer;
IF c_budgetOffer%NOTFOUND THEN
    l_budgetOffer := 'U';
END IF;
CLOSE c_budgetOffer;
return l_budgetOffer;
END isBudgetOffer;


PROCEDURE raise_event(p_id IN NUMBER)
IS
l_item_key varchar2(30);
l_parameter_list wf_parameter_list_t;
BEGIN
  l_item_key := p_id ||'_'|| TO_CHAR(SYSDATE,'DDMMRRRRHH24MISS');
  l_parameter_list := WF_PARAMETER_LIST_T();

OZF_Offer_Adj_Line_PVT.debug_message('Id is :'||p_id );
  wf_event.AddParameterToList(p_name           => 'P_ID',
                              p_value          => p_id,
                              p_parameterlist  => l_parameter_list);
OZF_Offer_Adj_Line_PVT.debug_message('Item Key is  :'||l_item_key);
  wf_event.raise( p_event_name => 'oracle.apps.ozf.offer.OfferAdjApproval',
                  p_event_key  => l_item_key,
                  p_parameters => l_parameter_list);
EXCEPTION
WHEN OTHERS THEN
RAISE Fnd_Api.g_exc_error;
OZF_Offer_Adj_Line_PVT.debug_message('Exception in raising business event');
END;

-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Offer_Adjustment
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
--       p_offer_adj_rec           IN   offer_adj_rec_type  Required
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

PROCEDURE Create_Offer_Adjustment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adj_rec              IN   offer_adj_rec_type  := g_miss_offer_adj_rec,
    x_offer_adjustment_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Offer_Adjustment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_adjustment_id       NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ozf_offer_adjustments_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_OFFER_ADJUSTMENTS_B
      WHERE offer_adjustment_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_offer_adjustment_pvt;

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
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_offer_adj_rec.offer_adjustment_id IS NULL OR p_offer_adj_rec.offer_adjustment_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_offer_adjustment_id;
         CLOSE c_id;

         OPEN c_id_exists(l_offer_adjustment_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_offer_adjustment_id := p_offer_adj_rec.offer_adjustment_id;
   END IF;

--  OZF_Offer_Adj_Line_PVT.debug_message('Private API: offer_adjustment_id: '  || p_offer_adj_rec.offer_adjustment_id || '::l_offer_adjustment_id: '||l_offer_adjustment_id);    -- sangara

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_Offer_Adj_Line_PVT.debug_message('Private API: Validate_Offer_Adjustment');

          -- Invoke validation procedures
          Validate_offer_adjustment(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_offer_adj_rec  =>  p_offer_adj_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message( 'Private API: Calling create table handler ');

      -- Invoke table handler(OZF_Offer_Adjustment_Pkg.Insert_Row)
      OZF_Offer_Adjustment_Pkg.Insert_Row(
          px_offer_adjustment_id  => l_offer_adjustment_id,
          p_effective_date  => p_offer_adj_rec.effective_date,
          p_approved_date  => p_offer_adj_rec.approved_date,
          p_settlement_code  => p_offer_adj_rec.settlement_code,
          p_status_code  => p_offer_adj_rec.status_code,
          p_list_header_id  => p_offer_adj_rec.list_header_id,
          p_version  => p_offer_adj_rec.version,
          p_budget_adjusted_flag  => p_offer_adj_rec.budget_adjusted_flag,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_attribute1  => p_offer_adj_rec.attribute1,
          p_attribute2  => p_offer_adj_rec.attribute2,
          p_attribute3  => p_offer_adj_rec.attribute3,
          p_attribute4  => p_offer_adj_rec.attribute4,
          p_attribute5  => p_offer_adj_rec.attribute5,
          p_attribute6  => p_offer_adj_rec.attribute6,
          p_attribute7  => p_offer_adj_rec.attribute7,
          p_attribute8  => p_offer_adj_rec.attribute8,
          p_attribute9  => p_offer_adj_rec.attribute9,
          p_attribute10  => p_offer_adj_rec.attribute10,
          p_attribute11  => p_offer_adj_rec.attribute11,
          p_attribute12  => p_offer_adj_rec.attribute12,
          p_attribute13  => p_offer_adj_rec.attribute13,
          p_attribute14  => p_offer_adj_rec.attribute14,
          p_attribute15  => p_offer_adj_rec.attribute15
          ,p_offer_adjustment_name  => p_offer_adj_rec.offer_adjustment_name,
          p_description  => p_offer_adj_rec.description
);

          x_offer_adjustment_id := l_offer_adjustment_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
     --    OZF_Offer_Adj_Line_PVT.debug_message('Problemo hereo: ');
      --    RAISE FND_API.G_EXC_ERROR;
         COMMIT WORK;
       END IF;


      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Offer_Adjustment_PVT;
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
End Create_Offer_Adjustment;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Offer_Adjustment
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
--       p_offer_adj_rec            IN   offer_adj_rec_type  Required
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

PROCEDURE Update_Offer_Adjustment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adj_rec              IN    offer_adj_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS


CURSOR c_get_offer_adjustment(offer_adjustment_id NUMBER) IS
    SELECT *
    FROM  OZF_OFFER_ADJUSTMENTS_B
    WHERE  offer_adjustment_id = p_offer_adj_rec.offer_adjustment_id;
    -- Hint: Developer need to provide Where clause


CURSOR c_if_lines_exist(p_offer_adjustment_id NUMBER) IS
    select 1
    from ozf_offer_adjustment_lines
    where offer_adjustment_id = p_offer_adjustment_id
    union
    select 1
    from ozf_offer_adjustment_tiers
    where offer_adjustment_id=  p_offer_adjustment_id
    union
    SELECT 1
    FROM ozf_offer_adj_new_lines
    WHERE offer_adjustment_id = p_offer_adjustment_id
    UNION
    SELECT 1
    FROM ozf_offer_adjustment_products
    WHERE offer_adjustment_id = p_offer_adjustment_id;


-- code added by mthumu
CURSOR c_get_offer_status(p_offer_adjustment_id NUMBER) IS
    SELECT status_code
    FROM  ozf_offer_adjustments_b
    WHERE  offer_adjustment_id = p_offer_adjustment_id ;
-- end mthumu

CURSOR c_custom_setup_id(p_list_header_id NUMBER) IS
     SELECT custom_setup_id ,NVL(budget_offer_yn, 'N')
    FROM ozf_offers
    WHERE qp_list_header_id=p_list_header_id;
-- code to get custom setup for approval
CURSOR c_attr_available_flag(p_custom_setup_id NUMBER) IS
    SELECT attr_available_flag
    FROM ams_custom_setup_attr
    WHERE custom_setup_id = p_custom_setup_id
      AND object_attribute = 'ADJA';

CURSOR c_backdate_flag(p_list_header_id NUMBER, p_offer_adjustment_id NUMBER, p_effective_date DATE) IS
    SELECT 1
    FROM OZF_OFFER_ADJUSTMENTS_VL
    WHERE (p_effective_date<SYSDATE)
          AND list_header_id = p_list_header_id
                AND offer_adjustment_id = p_offer_adjustment_id;


-- end of code

l_custom_setup_id    NUMBER;
l_budget_offer_yn    VARCHAR2(1);
l_attr_available_flag    VARCHAR2(1);
l_backdate_flag        VARCHAR2(1);

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Offer_Adjustment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_offer_adjustment_id        NUMBER;
l_ref_offer_adj_rec  c_get_Offer_Adjustment%ROWTYPE ;
l_tar_offer_adj_rec  offer_adj_rec_type := P_offer_adj_rec;
l_rowid  ROWID;
l_if_lines_exist        NUMBER;


-- code added by mthumu
l_current_status_code VARCHAR2(30);
l_new_status_code     VARCHAR2(30);
l_approve_date          DATE;
l_budgetAdjFlag     VARCHAR2(1);
-- end mthumu

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_offer_adjustment_pvt;

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
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize Object_Version_Number
      l_object_version_number := p_offer_adj_rec.object_version_number ;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Offer_Adjustment( l_tar_offer_adj_rec.offer_adjustment_id);

      FETCH c_get_Offer_Adjustment INTO l_ref_offer_adj_rec  ;

       If ( c_get_Offer_Adjustment%NOTFOUND) THEN
       OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
        p_token_name   => 'INFO',
        p_token_value  => 'Offer_Adjustment') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       OZF_Offer_Adj_Line_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Offer_Adjustment;


      If (l_tar_offer_adj_rec.object_version_number is NULL or
          l_tar_offer_adj_rec.object_version_number = FND_API.G_MISS_NUM ) Then
    OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
       p_token_name   => 'COLUMN',
       p_token_value  => 'Last_Update_Date') ;
        raise FND_API.G_EXC_ERROR;
      End if;


      -- Check Whether record has been changed by someone else

      If (l_tar_offer_adj_rec.object_version_number <> l_ref_offer_adj_rec.object_version_number) Then
    OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
        p_token_name   => 'INFO',
        p_token_value  => 'Offer_Adjustment') ;
        raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_Offer_Adj_Line_PVT.debug_message('Private API: Validate_Offer_Adjustment');

          -- Invoke validation procedures
          Validate_offer_adjustment(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_offer_adj_rec  =>  p_offer_adj_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- code added by mthumu to call the budget approval
    OPEN c_get_offer_status(p_offer_adj_rec.offer_adjustment_id);
    FETCH c_get_offer_status INTO l_current_status_code;
    CLOSE c_get_offer_status;

    l_new_status_code := p_offer_adj_rec.status_code;

    IF    ( l_current_status_code <> l_new_status_code )
    THEN

       IF ( l_new_status_code = 'ACTIVE' )
       THEN

        -- Submit
        OPEN c_if_lines_exist( p_offer_adj_rec.offer_adjustment_id );
        FETCH c_if_lines_exist INTO l_if_lines_exist;
        CLOSE c_if_lines_exist;

        IF l_if_lines_exist IS NULL THEN
            OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFRADJ_DISCRULE');

            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Call Approval Work Flow
        -- Select attr_available_flag
        -- from ams_custom_setup_attr
        -- where custom_setup_id = 91
        -- and object_attribute = 'ADJA';

        -- have to get the custom setup from offers table from another cursor

        -- IF attr_available_flag= 'Y' Then
        --  call workflow;
        -- else
        --  call update offer discounts; ( API as shown below)
        -- end if;


        OPEN c_custom_setup_id( p_offer_adj_rec.list_header_id );
        FETCH c_custom_setup_id INTO l_custom_setup_id, l_budget_offer_yn;
        CLOSE c_custom_setup_id;

        OPEN c_attr_available_flag(l_custom_setup_id);
        FETCH c_attr_available_flag INTO l_attr_available_flag;
        CLOSE c_attr_available_flag;

      raise_event(p_id => p_offer_adj_rec.offer_adjustment_id );
        OZF_Offer_Adj_Line_PVT.debug_message(' l_attr_available_flag ' || l_attr_available_flag);
        -- mthumu approve date fix
        l_new_status_code := 'ACTIVE';
        l_approve_date := sysdate;

        IF l_budget_offer_yn = 'Y' THEN
          AMS_GEN_APPROVAL_PVT.StartProcess
          (p_activity_type  => 'FAB_ADJ'
          ,p_activity_id    => p_offer_adj_rec.offer_adjustment_id
          ,p_approval_type  => 'BUDGET'
          ,p_object_version_number  =>p_offer_adj_rec.object_version_number
          ,p_orig_stat_id           => 0
          ,p_new_stat_id            => 0
          ,p_reject_stat_id         => 0
          ,p_requester_userid       => OZF_Utility_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
          ,p_notes_from_requester   => p_offer_adj_rec.description
          ,p_workflowprocess        => 'AMSGAPP'
          ,p_item_type              => 'AMSGAPP');

          l_new_status_code := 'PENDING';
        ELSIF l_attr_available_flag = 'Y' THEN
            AMS_GEN_APPROVAL_PVT.StartProcess
             (p_activity_type  => 'OFFR'
              ,p_activity_id    => p_offer_adj_rec.offer_adjustment_id
              ,p_approval_type  => 'BUDGET'
              ,p_object_version_number  =>p_offer_adj_rec.object_version_number
              ,p_orig_stat_id           => 0
              ,p_new_stat_id            => 0
              ,p_reject_stat_id         => 0
              ,p_requester_userid       => OZF_Utility_PVT.get_resource_id(NVL(FND_GLOBAL.user_id,-1))
              ,p_notes_from_requester   => p_offer_adj_rec.description
              ,p_workflowprocess        => 'AMSGAPP'
              ,p_item_type              => 'AMSGAPP');

               l_new_status_code := 'PENDING';
         ELSE
            OZF_Offer_Backdate_PVT.Update_Offer_Discounts (
                                                            p_init_msg_list => FND_API.G_FALSE
                                                            ,p_api_version   => 1.0
                                                            ,p_commit        =>  FND_API.G_FALSE
                                                            ,x_return_status => x_return_status
                                                            ,x_msg_count     => x_msg_count
                                                            ,x_msg_data      => x_msg_data
                                                            ,p_offer_adjustment_id  => p_offer_adj_rec.offer_adjustment_id
--                                                            ,p_close_adj     => 'Y'
                                                            ) ;
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
            OZF_Offer_Backdate_PVT.getCloseAdjustmentParams
                (
                    p_offer_adjustment_id  => p_offer_adj_rec.offer_adjustment_id
                    ,x_return_status => x_return_status
                    ,x_msg_count     => x_msg_count
                    ,x_msg_data      => x_msg_data
                    ,x_newStatus     => l_new_status_code
                    ,x_budgetAdjFlag => l_budgetAdjFlag
                );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;
        END IF;
       END IF;
    END IF;
     -- end of code mthumu
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW||'Private API: Calling update table handler');
      -- Invoke table handler(OZF_Offer_Adjustment_Pkg.Update_Row)
      OZF_Offer_Adjustment_Pkg.Update_Row(
          p_offer_adjustment_id  => p_offer_adj_rec.offer_adjustment_id,
          p_effective_date  => p_offer_adj_rec.effective_date,
          p_approved_date  => l_approve_date,--p_offer_adj_rec.approved_date,
          p_settlement_code  => p_offer_adj_rec.settlement_code,
          p_status_code  => l_new_status_code,  -- p_offer_adj_rec.status_code,
          p_list_header_id  => p_offer_adj_rec.list_header_id,
          p_version  => p_offer_adj_rec.version,
          p_budget_adjusted_flag  => l_budgetAdjFlag,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number,
          p_attribute1  => p_offer_adj_rec.attribute1,
          p_attribute2  => p_offer_adj_rec.attribute2,
          p_attribute3  => p_offer_adj_rec.attribute3,
          p_attribute4  => p_offer_adj_rec.attribute4,
          p_attribute5  => p_offer_adj_rec.attribute5,
          p_attribute6  => p_offer_adj_rec.attribute6,
          p_attribute7  => p_offer_adj_rec.attribute7,
          p_attribute8  => p_offer_adj_rec.attribute8,
          p_attribute9  => p_offer_adj_rec.attribute9,
          p_attribute10  => p_offer_adj_rec.attribute10,
          p_attribute11  => p_offer_adj_rec.attribute11,
          p_attribute12  => p_offer_adj_rec.attribute12,
          p_attribute13  => p_offer_adj_rec.attribute13,
          p_attribute14  => p_offer_adj_rec.attribute14,
          p_attribute15  => p_offer_adj_rec.attribute15
          ,p_offer_adjustment_name  => p_offer_adj_rec.offer_adjustment_name,
          p_description  => p_offer_adj_rec.description
);

   x_object_version_number := l_object_version_number;
      --
      -- End of API body.
      --
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');
EXCEPTION
   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Offer_Adjustment_PVT;
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
End Update_Offer_Adjustment;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offer_Adjustment
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
--       p_offer_adjustment_id                IN   NUMBER
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

PROCEDURE Delete_Offer_Adjustment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_adjustment_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offer_Adjustment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_offer_adjustment_pvt;

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
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(OZF_Offer_Adjustment_Pkg.Delete_Row)
      OZF_Offer_Adjustment_Pkg.Delete_Row(
          p_offer_adjustment_id  => p_offer_adjustment_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Offer_Adjustment_PVT;
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
End Delete_Offer_Adjustment;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Offer_Adjustment
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
--       p_offer_adj_rec            IN   offer_adj_rec_type  Required
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

PROCEDURE Lock_Offer_Adjustment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adjustment_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offer_Adjustment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_offer_adjustment_id                  NUMBER;

BEGIN

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
OZF_Offer_Adjustment_Pkg.Lock_Row(l_offer_adjustment_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Offer_Adj_Line_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Offer_Adjustment_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Offer_Adjustment_PVT;
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
End Lock_Offer_Adjustment;




PROCEDURE check_Offer_Adj_Uk_Items(
    p_offer_adj_rec               IN   offer_adj_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
                            -- Cursor to check, if 2 adjustments exist with same effective date
   CURSOR c_adj_exists_oncreate (l_objid IN NUMBER, l_effdt IN DATE) IS
      SELECT 1
      FROM OZF_OFFER_ADJUSTMENTS_B
      WHERE list_header_id  = l_objid
              AND effective_date = l_effdt
        AND status_code NOT IN ('CANCELLED' ,'CLOSED');

   CURSOR c_adj_exists_onupdate (l_objid IN NUMBER, l_adjid IN NUMBER, l_effdt IN DATE) IS
      SELECT 1
      FROM OZF_OFFER_ADJUSTMENTS_B
      WHERE  list_header_id  = l_objid
         AND offer_adjustment_id <>  l_adjid
              AND effective_date = l_effdt
         AND status_code NOT IN ('CANCELLED' ,'CLOSED');

   l_valid_flag  VARCHAR2(1);
   l_dup_effective_dt NUMBER;
   l_strClosed VARCHAR2(20) := ' ''CLOSED'' ';
   l_strTerminated VARCHAR2(20) := ' ''TERMINATED'' ';

--nepanda : fix for bug 9149865
   CURSOR c_check_uniqeness_create
     IS
     SELECT 1 from ozf_offer_adjustments_vl
     WHERE offer_adjustment_name = p_offer_adj_rec.offer_adjustment_name
     AND list_header_id = p_offer_adj_rec.list_header_id;

   CURSOR c_check_uniqeness_update
      IS
      SELECT 1 from ozf_offer_adjustments_vl
      WHERE offer_adjustment_name = p_offer_adj_rec.offer_adjustment_name
      AND list_header_id = p_offer_adj_rec.list_header_id
      AND offer_adjustment_id <> p_offer_adj_rec.offer_adjustment_id;

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
        OZF_Offer_Adj_Line_PVT.debug_message('Inside Uk_Items::Create');
	--nepanda : fix for bug 9149865
	/*l_valid_flag := OZF_Utility_PVT.check_uniqueness(
            ' ozf_offer_adjustments_vl ',
            ' list_header_id = '||' '|| p_offer_adj_rec.list_header_id ||
            ' AND offer_adjustment_name  ='||' '|| p_offer_adj_rec.offer_adjustment_name||''
            );*/

	    OPEN c_check_uniqeness_create;
		FETCH c_check_uniqeness_create INTO l_valid_flag;
	    CLOSE c_check_uniqeness_create;
                                        -- Check for, 2 adjustments with same effective date -sangara

        -- l_dup_effective_dt := OZF_Utility_PVT.check_uniqueness(
        --    'ozf_offer_adjustments_b',
        --    ' list_header_id  = '||' '|| p_offer_adj_rec.list_header_id ||''||
        --    ' AND status_code <> '||' '|| l_strTerminated ||''||
        --    ' OR  status_code <> '||' '|| l_strClosed ||''||
        --    ' AND effective_date = '||' '|| p_offer_adj_rec.effective_date
        --    );

        OPEN c_adj_exists_oncreate(p_offer_adj_rec.list_header_id, p_offer_adj_rec.effective_date);
        FETCH c_adj_exists_oncreate INTO l_dup_effective_dt ;
        CLOSE c_adj_exists_oncreate;

      ELSE
	--nepanda : fix for bug 9149865
	/* l_valid_flag := OZF_Utility_PVT.check_uniqueness(
            ' ozf_offer_adjustments_vl ',
            ' list_header_id = '||' '|| p_offer_adj_rec.list_header_id ||
            ' AND offer_adjustment_id  <> '||' '|| p_offer_adj_rec.offer_adjustment_id||' '||
            ' AND offer_adjustment_name  ='||' '|| p_offer_adj_rec.offer_adjustment_name||''
            );*/

    	    OPEN c_check_uniqeness_update;
		FETCH c_check_uniqeness_update INTO l_valid_flag;
	    CLOSE c_check_uniqeness_update;

                                        -- Check for, 2 adjustments with same effective date -sangara
        -- l_dup_effective_dt := OZF_Utility_PVT.check_uniqueness(
        --    'ozf_offer_adjustments_b',
        --    'list_header_id =' ||  p_offer_adj_rec.list_header_id ||
        --    ' AND offer_adjustment_id <>  '||' '|| p_offer_adj_rec.offer_adjustment_id||' '||
        --    ' AND status_code <> '||' '|| l_strTerminated ||''||
        --    ' OR status_code <> '||' '|| l_strClosed ||''||
        --    ' AND effective_date = '||' '|| p_offer_adj_rec.effective_date
        --    );


        OPEN c_adj_exists_onupdate(p_offer_adj_rec.list_header_id, p_offer_adj_rec.offer_adjustment_id, p_offer_adj_rec.effective_date);
        FETCH c_adj_exists_onupdate INTO l_dup_effective_dt ;
        CLOSE c_adj_exists_onupdate;

      END IF;


      IF l_valid_flag = 1 THEN --FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_ADJ_NAME_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      OZF_Offer_Adj_Line_PVT.debug_message('check_Offer_Adj_Uk_Items :: l_dup_effective_dt ' || l_dup_effective_dt  );

      IF l_dup_effective_dt IS NOT NULL THEN
       IF l_dup_effective_dt  = 1 THEN                -- Show error, if 2 adjs. with same eff date exists. - sangara
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFADJ_DUP_EFFDT');
        x_return_status := FND_API.g_ret_sts_error;
       END IF;
       END IF;

END check_Offer_Adj_Uk_Items;



PROCEDURE check_Offer_Adj_Req_Items(
    p_offer_adj_rec               IN  offer_adj_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status             OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


  --    IF p_offer_adj_rec.offer_adjustment_id = FND_API.G_MISS_NUM OR p_offer_adj_rec.offer_adjustment_id IS NULL THEN
  --             OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_ID' );
  --            x_return_status := FND_API.g_ret_sts_error;
  --    END IF;

      -- List Header Id check
      IF p_offer_adj_rec.list_header_id = FND_API.G_MISS_NUM OR p_offer_adj_rec.list_header_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LIST_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Adjustment Name check
      IF p_offer_adj_rec.offer_adjustment_name = FND_API.G_MISS_CHAR OR p_offer_adj_rec.offer_adjustment_name IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_NAME' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Status Code check
      IF p_offer_adj_rec.status_code = FND_API.G_MISS_CHAR OR p_offer_adj_rec.offer_adjustment_name IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'STATUS_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Effective Date check
      IF p_offer_adj_rec.effective_date = FND_API.G_MISS_DATE OR p_offer_adj_rec.effective_date IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'EFFECTIVE_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE

      IF p_offer_adj_rec.offer_adjustment_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_offer_adj_rec.list_header_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LIST_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;

END check_Offer_Adj_Req_Items;



PROCEDURE check_Offer_Adj_Fk_Items(
    p_offer_adj_rec IN offer_adj_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Offer_Adj_Fk_Items;



PROCEDURE check_Offer_Adj_Lookup_Items(
    p_offer_adj_rec IN offer_adj_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Offer_Adj_Lookup_Items;



PROCEDURE Check_Offer_Adj_Items (
    P_offer_adj_rec    IN    offer_adj_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Offer_adj_Uk_Items(
      p_offer_adj_rec => p_offer_adj_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_offer_adj_req_items(
      p_offer_adj_rec => p_offer_adj_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_offer_adj_FK_items(
      p_offer_adj_rec => p_offer_adj_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_offer_adj_Lookup_items(
      p_offer_adj_rec => p_offer_adj_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_offer_adj_Items;





PROCEDURE Complete_Offer_Adj_Rec (
   p_offer_adj_rec IN offer_adj_rec_type,
   x_complete_rec OUT NOCOPY offer_adj_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_adjustments_b
      WHERE offer_adjustment_id = p_offer_adj_rec.offer_adjustment_id;
   l_offer_adj_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_offer_adj_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_offer_adj_rec;
   CLOSE c_complete;

   -- offer_adjustment_id
   IF p_offer_adj_rec.offer_adjustment_id IS NULL THEN
      x_complete_rec.offer_adjustment_id := l_offer_adj_rec.offer_adjustment_id;
   END IF;

   -- effective_date
   IF p_offer_adj_rec.effective_date IS NULL THEN
      x_complete_rec.effective_date := l_offer_adj_rec.effective_date;
   END IF;

   -- approved_date
   IF p_offer_adj_rec.approved_date IS NULL THEN
      x_complete_rec.approved_date := l_offer_adj_rec.approved_date;
   END IF;

   -- settlement_code
   IF p_offer_adj_rec.settlement_code IS NULL THEN
      x_complete_rec.settlement_code := l_offer_adj_rec.settlement_code;
   END IF;

   -- status_code
   IF p_offer_adj_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_offer_adj_rec.status_code;
   END IF;

   -- list_header_id
   IF p_offer_adj_rec.list_header_id IS NULL THEN
      x_complete_rec.list_header_id := l_offer_adj_rec.list_header_id;
   END IF;

   -- version
   IF p_offer_adj_rec.version IS NULL THEN
      x_complete_rec.version := l_offer_adj_rec.version;
   END IF;

   -- budget_adjusted_flag
   IF p_offer_adj_rec.budget_adjusted_flag IS NULL THEN
      x_complete_rec.budget_adjusted_flag := l_offer_adj_rec.budget_adjusted_flag;
   END IF;

   -- last_update_date
   IF p_offer_adj_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_offer_adj_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_offer_adj_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_offer_adj_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_offer_adj_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_offer_adj_rec.creation_date;
   END IF;

   -- created_by
   IF p_offer_adj_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_offer_adj_rec.created_by;
   END IF;

   -- last_update_login
   IF p_offer_adj_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_offer_adj_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_offer_adj_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_offer_adj_rec.object_version_number;
   END IF;

   -- attribute1
   IF p_offer_adj_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_offer_adj_rec.attribute1;
   END IF;

   -- attribute2
   IF p_offer_adj_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_offer_adj_rec.attribute2;
   END IF;

   -- attribute3
   IF p_offer_adj_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_offer_adj_rec.attribute3;
   END IF;

   -- attribute4
   IF p_offer_adj_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_offer_adj_rec.attribute4;
   END IF;

   -- attribute5
   IF p_offer_adj_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_offer_adj_rec.attribute5;
   END IF;

   -- attribute6
   IF p_offer_adj_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_offer_adj_rec.attribute6;
   END IF;

   -- attribute7
   IF p_offer_adj_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_offer_adj_rec.attribute7;
   END IF;

   -- attribute8
   IF p_offer_adj_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_offer_adj_rec.attribute8;
   END IF;

   -- attribute9
   IF p_offer_adj_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_offer_adj_rec.attribute9;
   END IF;

   -- attribute10
   IF p_offer_adj_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_offer_adj_rec.attribute10;
   END IF;

   -- attribute11
   IF p_offer_adj_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_offer_adj_rec.attribute11;
   END IF;

   -- attribute12
   IF p_offer_adj_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_offer_adj_rec.attribute12;
   END IF;

   -- attribute13
   IF p_offer_adj_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_offer_adj_rec.attribute13;
   END IF;

   -- attribute14
   IF p_offer_adj_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_offer_adj_rec.attribute14;
   END IF;

   -- attribute15
   IF p_offer_adj_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_offer_adj_rec.attribute15;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Offer_Adj_Rec;




PROCEDURE Default_Offer_Adj_Items ( p_offer_adj_rec IN offer_adj_rec_type ,
                                x_offer_adj_rec OUT NOCOPY offer_adj_rec_type )
IS
   l_offer_adj_rec offer_adj_rec_type := p_offer_adj_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Offer_Adjustment(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offer_adj_rec              IN   offer_adj_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offer_Adjustment';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offer_adj_rec  offer_adj_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_offer_adjustment_;

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


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_offer_adj_Items(
                 p_offer_adj_rec        => p_offer_adj_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Offer_Adj_Items (p_offer_adj_rec => p_offer_adj_rec ,
                                x_offer_adj_rec => l_offer_adj_rec) ;
      END IF ;


      Complete_offer_adj_Rec(
         p_offer_adj_rec        => p_offer_adj_rec,
         x_complete_rec        => l_offer_adj_rec
      );

-- If the Effective date is before the start date of any of the budgets dont create or update adjustments
      IF l_offer_adj_rec.effective_date < get_budget_start_date(l_offer_adj_rec.list_header_id) AND isBudgetOffer(p_listHeaderId => l_offer_adj_rec.list_header_id) = 'N' THEN
      ozf_utility_pvt.error_message('OZF_OFFR_ADJ_DT_LT_BUDGET_DT');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_offer_adj_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_offer_adj_rec           =>    l_offer_adj_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Adjustment_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Adjustment_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Offer_Adjustment_;
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
End Validate_Offer_Adjustment;


PROCEDURE Validate_Offer_Adj_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_adj_rec               IN    offer_adj_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      OZF_Offer_Adj_Line_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_offer_adj_Rec;

END OZF_Offer_Adjustment_PVT;

/
