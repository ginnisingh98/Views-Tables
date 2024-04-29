--------------------------------------------------------
--  DDL for Package Body OZF_PRE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PRE_PROCESS_PVT" AS
/* $Header: ozfvprsb.pls 120.28.12010000.3 2009/05/07 06:40:46 ateotia ship $ */
-------------------------------------------------------------------------------
-- PACKAGE:
-- OZF_PRE_PROCESS_PVT
--
-- PURPOSE:
-- Private API for Pre-Processing of IDSM Batch.
--
-- HISTORY:
-- 24-Feb-2005  mchang    Bug# 4186465 fixed.
--                        1. bill_to_party_id should not be erased if account
--                           doesn't exist.
--                        2. derive bill/ship to party_name based on party_id.
-- 06-May-2009  ateotia   Bug# 8489216 fixed.
-------------------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ozf_pre_process_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvprsb.pls';

OZF_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR   CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error);
OZF_ERROR         CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_error);

-- Processing global variables
G_BATCH_STATUS                   VARCHAR2(30) := NULL;
G_BATCH_CURRENCY_CODE            VARCHAR2(30) := NULL;
G_INVENTORY_TRACKING_FLAG        VARCHAR2(1)  := NULL;
G_ADMIN_EMAIL                    VARCHAR2(100);

G_DQM_CONTACT_RULE           NUMBER := FND_PROFILE.value('OZF_RESALE_CONTACT_DQM_RULE');
G_DQM_PARTY_RULE             NUMBER := FND_PROFILE.value('OZF_RESALE_PARTY_DQM_RULE');
G_DQM_PARTY_SITE_RULE        NUMBER := FND_PROFILE.value('OZF_RESALE_PARTY_SITE_DQM_RULE');
G_ITEM_ORG_ID                NUMBER := FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');
G_DEFAULT_ORG_ID             NUMBER := FND_PROFILE.value('DEFAULT_ORG_ID');

-- Private Procedure
PROCEDURE Number_Mapping_Required(
    p_internal_code_tbl     IN  NUMBER_TABLE,
    x_mapping_flag          OUT NOCOPY VARCHAR2
);

FUNCTION set_line_status(
    p_count          IN  NUMBER,
    p_status_code    IN  VARCHAR2
) RETURN   VARCHAR2_TABLE;

PROCEDURE Mapping_Required(
    p_internal_code_tbl     IN  VARCHAR2_TABLE,
    p_external_code_tbl     IN  VARCHAR2_TABLE,
    x_mapping_flag          OUT NOCOPY VARCHAR2
);

--
PROCEDURE process_xmlgt_inbwf
(
   itemtype   IN VARCHAR2,
   itemkey    IN VARCHAR2,
   actid      IN NUMBER,
   funcmode   IN VARCHAR2,
   resultout  IN OUT NOCOPY VARCHAR2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'process_xmlgt_inbwf';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_batch_status        VARCHAR2(30);
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('In: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   IF (funcmode = 'RUN') THEN

     IF  itemtype = g_xml_import_workflow THEN

        l_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'PARAMETER1');

     ELSIF  itemtype = g_data_process_workflow THEN

        l_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_RESALE_BATCH_ID');

     END IF;

      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('Batch ID '|| l_batch_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN

           resale_pre_process
          (
           p_api_version_number  => 1.0,
           p_init_msg_list       => FND_API.G_FALSE,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           p_batch_id            => l_batch_id,
           x_batch_status        => l_batch_status,
           x_return_status       => l_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data
          );

         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('Pre Process is complete '||l_return_status);
         END IF;

         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS then
            l_resultout := 'COMPLETE:ERROR';
            IF itemtype = g_xml_import_workflow THEN
               wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'ECX_ADMINISTRATOR',
                                      avalue   => G_ADMIN_EMAIL );
            ELSIF itemtype = g_data_process_workflow THEN
               wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'WF_ADMINISTRATOR',
                                      avalue   => G_ADMIN_EMAIL );
            END IF;
         ELSE
            IF  l_batch_status IS NOT NULL THEN
               IF l_batch_status <> 'OPEN' THEN
                  l_resultout := 'COMPLETE:ERROR';
               ELSE
                  l_resultout := 'COMPLETE:SUCCESS';
               END IF;
            END IF;
         END IF;
      ELSE
         l_resultout := 'COMPLETE:SUCCESS';
      END IF;

 ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE';

 ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE';

 ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE';

 END IF;

 resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END process_xmlgt_inbwf;

PROCEDURE webadi_import (
   p_batch_number       IN  VARCHAR2,
   x_return_status      OUT NOCOPY VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'webadi_import';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(32000);
   l_batch_id            NUMBER;
   l_batch_status        VARCHAR2(30);

   CURSOR  get_batch_id (pc_batch_no VARCHAR2)
   IS
   select resale_batch_id
   from ozf_resale_batches
   where batch_number = pc_batch_no;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_batch_number IS NOT NULL THEN

       OPEN get_batch_id (p_batch_number);
       FETCH get_batch_id INTO l_batch_id;
       CLOSE get_batch_id;

       IF l_batch_id IS NOT NULL THEN

           resale_pre_process
          (
           p_api_version_number  => 1.0,
           p_init_msg_list       => FND_API.G_FALSE,
           p_commit              => FND_API.G_FALSE,
           p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
           p_batch_id            => l_batch_id,
           x_batch_status        => l_batch_status,
           x_return_status       => x_return_status,
           x_msg_count           => l_msg_count,
           x_msg_data            => l_msg_data
          );

         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('Pre Process is complete '|| x_return_status);
         END IF;

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
        IF  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
             IF l_batch_status = g_batch_open THEN

                -- Call Data Processing Event
                raise_event
                (
                  p_batch_id            =>   l_batch_id,
                  p_event_name          =>   g_webadi_data_process_event,
                  x_return_status       =>   x_return_status
                );
                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;
         END IF;

      END IF; -- l_batch_id is not null

    END IF;  -- p_batch_number is not null

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => l_msg_count,
            p_data    => l_msg_data
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
            p_count   => l_msg_count,
            p_data    => l_msg_data
     );

END Webadi_import;

PROCEDURE Resale_Pre_Process (
   p_api_version_number      IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2  := FND_API.G_FALSE,
   p_commit                  IN  VARCHAR2  := FND_API.G_FALSE,
   p_validation_level        IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   p_batch_id                IN  NUMBER,
   x_batch_status            OUT NOCOPY  VARCHAR2,
   x_return_status           OUT NOCOPY  VARCHAR2,
   x_msg_count               OUT NOCOPY  NUMBER,
   x_msg_data                OUT NOCOPY  VARCHAR2
)
IS
l_api_name                   CONSTANT VARCHAR2(30) := 'resale_pre_process';
l_api_version_number         CONSTANT NUMBER   := 1.0;

l_resale_batch_rec           ozf_resale_batches_all%rowtype;
l_line_record                resale_line_int_rec_type;

l_status                     VARCHAR2(30) := NULL;
l_dispute_reason             VARCHAR2(100);
l_batch_org_id               NUMBER;
l_org_id                     NUMBER;

CURSOR get_count (pc_batch_id IN NUMBER) IS
SELECT COUNT(DECODE(b.status_code, 'DISPUTED', 1, NULL)),
       COUNT(b.status_code)
FROM   ozf_resale_batches_all a
,      ozf_resale_lines_int_all b
WHERE a.resale_batch_id = b.resale_batch_id
AND a.resale_batch_id = pc_batch_id;

CURSOR get_batch_org(cv_resale_batch_id IN NUMBER) IS
  SELECT org_id
  FROM ozf_resale_batches_all
  WHERE resale_batch_id = cv_resale_batch_id;

BEGIN

   --SAVEPOINT resale_pre_process;

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

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- R12 MOAC Enhancement (+)
   OPEN get_batch_org(p_batch_id);
   FETCH get_batch_org INTO l_batch_org_id;
   CLOSE get_batch_org;

   l_org_id := MO_GLOBAL.get_valid_org(l_batch_org_id);

   IF l_org_id IS NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   MO_GLOBAL.set_policy_context('S', l_org_id);
   -- R12 MOAC Enhancement (-)


   -- Delete logs from previous runs
   OZF_RESALE_COMMON_PVT.Delete_Log(
       p_api_version       => 1.0
      ,p_init_msg_list     => FND_API.G_FALSE
      ,p_commit            => FND_API.G_FALSE
      ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id   => p_batch_id
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
      ,x_msg_data          => x_msg_data
   );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Validates and Updates Ozf_Resale_Batches_all
   Batch_Update
  ( p_api_version_number  => 1.0,
    p_init_msg_list       => FND_API.G_FALSE,
    p_commit              => FND_API.G_FALSE,
    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
    p_batch_id            => p_batch_id,
    x_resale_batch_rec    => l_resale_batch_rec,
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data
  );
  --
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  --
  IF  l_resale_batch_rec.resale_batch_id IS NOT NULL THEN
     -- Validates and Updates Ozf_Resale_Lines_Int_All
     Lines_Update
    (
     p_batch_id              => p_batch_id,
     px_batch_record         => l_resale_batch_rec,
     x_return_status         => x_return_status,
     x_msg_count             => x_msg_count,
     x_msg_data              => x_msg_data
    );
  --
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
  --
  -- Final Checking  of  mandatory items
    IF l_resale_batch_rec.batch_type IS NULL THEN
        l_resale_batch_rec.batch_type := ozf_resale_common_pvt.G_TRACING;
    END IF;
    IF  l_resale_batch_rec.status_code IS NULL THEN
        l_resale_batch_rec.status_code := g_batch_open;
    END IF;

    OPEN  get_count(p_batch_id);
    FETCH get_count INTO l_resale_batch_rec.lines_disputed
                       , l_resale_batch_rec.batch_count;
    CLOSE  get_count;

    IF  l_resale_batch_rec.lines_disputed > 0 THEN
        l_resale_batch_rec.status_code := g_batch_disputed;
    ELSE
        l_resale_batch_rec.status_code := g_batch_open;
    END IF;

    -- [BEGIN OF BUG 4301466 FIXING]
    /*
    IF  l_resale_batch_rec.lines_disputed > 0 THEN
        l_resale_batch_rec.status_code := g_batch_disputed;
    ELSE
        l_resale_batch_rec.status_code := g_batch_open;
    END IF;
   */
    IF l_resale_batch_rec.lines_disputed = l_resale_batch_rec.batch_count THEN
        l_resale_batch_rec.status_code := g_batch_disputed;
    ELSE
        l_resale_batch_rec.status_code := g_batch_open;
    END IF;
    -- [END OF BUG 4301466 FIXING]

    x_batch_status :=  l_resale_batch_rec.status_code;
  -- Batch is updated with all the derived values OR status as 'REJECTED'
  -- -----------------------------------------------------------------
      Update_interface_batch
     ( p_api_version_number    => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       P_Commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       p_int_batch_rec         => l_resale_batch_rec,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data
     );
     --
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;
    x_batch_status :=  l_resale_batch_rec.status_code;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     --ROLLBACK TO resale_pre_process;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_batch_status := OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED;
     Update ozf_resale_batches
     SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
     WHERE resale_batch_id = p_batch_id;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --ROLLBACK TO resale_pre_process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_batch_status := OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED;
     Update ozf_resale_batches
     SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
     WHERE resale_batch_id = p_batch_id;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);
  WHEN OTHERS THEN
     --ROLLBACK TO resale_pre_process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_batch_status := OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED;
     Update ozf_resale_batches
     SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
     WHERE resale_batch_id = p_batch_id;

     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data);

END Resale_pre_process;

PROCEDURE Batch_Update (
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2  := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   p_batch_id              IN  NUMBER,
   x_resale_batch_rec      OUT NOCOPY  ozf_resale_batches_all%rowtype,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Batch_Update';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  l_resale_batch_rec          ozf_resale_batches_all%rowtype;
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(32000);
  l_batch_status              VARCHAR2(30);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- Fetch the Batch Record for the given  Batch ID
-- -----------------------------------------------------------------
   Batch_Fetch
   (  p_batch_id           => p_batch_id,
      x_resale_batch_rec   => l_resale_batch_rec,
      x_return_status      => x_return_status
   );
   --
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   --
--
-- Validate the Batch for the required values
-- -----------------------------------------------------------------
   IF l_resale_batch_rec.resale_batch_id IS NOT NULL THEN
      Validate_Batch(
       p_api_version_number    => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       p_commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       p_resale_batch_rec      => l_resale_batch_rec,
       x_batch_status          => l_batch_status,
       x_return_status         => x_return_status,
       x_msg_count             => l_msg_count,
       x_msg_data              => l_msg_data
      );
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('Batch Status from Validate Batch ' || l_batch_status);
      END IF;
     --
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
     --
--
-- If the required values are null then the batch is rejected OR
-- if all the values are present the defaulting rules are
-- applied to the batch in  Batch_Defaulting
-- -----------------------------------------------------------------

       IF l_batch_status = G_BATCH_REJECTED THEN
         l_resale_batch_rec.status_code := G_BATCH_REJECTED;
         G_BATCH_STATUS :=  g_batch_rejected;
       ELSE
          l_resale_batch_rec.status_code := l_batch_status;
          Batch_Defaulting
         ( p_api_version_number    => 1.0,
           p_init_msg_list         => FND_API.G_FALSE,
           p_commit                => FND_API.G_FALSE,
           p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
           px_resale_batch_rec     => l_resale_batch_rec,
           x_return_status         => x_return_status,
           x_msg_count             => l_msg_count,
           x_msg_data              => l_msg_data
      );
         --
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         --
       END IF;   -- l_batch_status = G_BATCH_REJECTED
       x_resale_batch_rec :=  l_resale_batch_rec;
   ELSE
       x_resale_batch_rec := NULL;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Batch_Update;

PROCEDURE Batch_Fetch
(
   p_batch_id              IN  NUMBER,
   x_resale_batch_rec      OUT NOCOPY  ozf_resale_batches_all%rowtype,
   x_return_status         OUT NOCOPY  VARCHAR2
)
IS

  l_api_name                  CONSTANT VARCHAR2(30) := 'Batch_Fetch';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  CURSOR csr_get_batch_info(cv_batch_id NUMBER)
  IS
  SELECT  *
    FROM  ozf_resale_batches_all
   WHERE  resale_batch_id = cv_batch_id;

  CURSOR get_ecx_party_id ( pc_party_site NUMBER)
  IS
  SELECT party_id
       , party_site_id
       , company_admin_email
    FROM ecx_tp_headers_v
   WHERE party_site_id = pc_party_site
  UNION
  SELECT party_id
       , party_site_id
       , company_admin_email
    FROM ecx_tp_headers_v hdr
       , ecx_tp_details_v dtl
   WHERE hdr.tp_header_id = dtl.tp_header_id
     AND source_tp_location_code = to_char(pc_party_site);

  time               NUMBER;
  l_partner_party_id NUMBER;
  l_party_site_id    NUMBER;
  l_admin_email      VARCHAR2(3000);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': Start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Fetch the batch record
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('p_batch_id ' || p_batch_id );
   END IF;

   OPEN  csr_get_batch_info ( p_batch_id);
   FETCH csr_get_batch_info INTO x_resale_batch_rec;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('after batch fetch');
   END IF;

   IF csr_get_batch_info%NOTFOUND THEN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('No records found');
      END IF;

      insert_resale_log(
         p_id_value       => p_batch_id,
         p_id_type        => 'BATCH',
         p_error_code     => 'OZF_BATCH_RECORD_EMPTY',
         p_column_name    => NULL,
         p_column_value   => NULL,
         x_return_status  => x_return_status
      );
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('x_return_status from insert resale log' ||x_return_status );
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      x_resale_batch_rec := NULL;
   END IF;
   CLOSE csr_get_batch_info;

   -- Users may not be giving party id while submitting XML Message
   -- And the location code they give is also may be Trading Partner's Party Site ID
   -- OR it could be User defined Location Code, in that case based on
   -- location code trading partner party id and party site id are retrieved from
   -- Trading Partner Header
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('ECX fetch');
      ozf_utility_pvt.debug_message('x_resale_batch_rec.partner_site_id'||x_resale_batch_rec.partner_site_id);
   END IF;

   OPEN  get_ecx_party_id (x_resale_batch_rec.partner_site_id);
   FETCH get_ecx_party_id
   INTO l_partner_party_id,l_party_site_id, l_admin_email;
   CLOSE get_ecx_party_id;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Trading Partner Party ID'||l_partner_party_id);
      ozf_utility_pvt.debug_message('Trading Partner Site ID'||l_party_site_id);
      ozf_utility_pvt.debug_message('Admin Email'||l_admin_email);
   END IF;

   IF  x_resale_batch_rec.partner_party_id IS NULL THEN
       x_resale_batch_rec.partner_party_id := l_partner_party_id;
       x_resale_batch_rec.partner_site_id  := l_party_site_id;
       G_ADMIN_EMAIL       :=    l_admin_email;
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': End');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Batch_Fetch;

PROCEDURE Validate_Batch
(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_resale_batch_rec      IN  ozf_resale_batches_all%rowtype,
   x_batch_status          OUT NOCOPY  VARCHAR2,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Batch';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  CURSOR chk_cust_account ( pc_account_id NUMBER)
  IS
    SELECT 'X'
    FROM hz_cust_accounts
    WHERE cust_account_id = pc_account_id;

  l_chk_flag                 VARCHAR2(1) := NULL;
  time                       NUMBER;
BEGIN
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': Start');
   END IF;

 --  ========================================================================
 --   NULL Checks
 --  ========================================================================

 --    Partner id is null
   IF OZF_DEBUG_LOW_ON THEN
      time  := DBMS_UTILITY.GET_TIME;
      ozf_utility_pvt.debug_message('Start Time (in Seconds) in  '|| l_api_name || ' '|| time/100);
   END IF;

   IF  p_resale_batch_rec.partner_party_id IS NULL THEN
     IF p_resale_batch_rec.partner_cust_account_id IS NULL THEN

        IF OZF_DEBUG_LOW_ON THEN
           ozf_utility_pvt.debug_message ( 'Partner Party ID is null ');
        END IF;

        insert_resale_log
         (p_id_value       => p_resale_batch_rec.resale_batch_id,
          p_id_type        => 'BATCH',
          p_error_code     => 'OZF_BATCH_PARTNER_NULL',
          p_column_name    => NULL,
          p_column_value   => NULL,
          x_return_status  => x_return_status);

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       x_batch_status   :=  'REJECTED';
     END IF;
   END IF;    --    l_partner_party_id is null

 --   Report Start Date is null
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'Report Start Date '||p_resale_batch_rec.report_start_date);
   END IF;

   IF  (x_batch_status IS NULL OR x_batch_status <> G_BATCH_REJECTED )
   AND p_resale_batch_rec.report_start_date IS NULL THEN

      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message ( 'Report Start Date is null ');
      END IF;

      insert_resale_log
      ( p_id_value      => p_resale_batch_rec.resale_batch_id,
        p_id_type       => 'BATCH',
        p_error_code    => 'OZF_REPORT_START_DATE_NULL',
        p_column_name   => NULL,
        p_column_value  => NULL,
        x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

       x_batch_status   :=  'REJECTED';

    END IF;  -- Report Start Date null

 --   Report End Date is null
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_pvt.debug_message ( 'Report End Date '||p_resale_batch_rec.report_end_date);
    END IF;

    IF  (x_batch_status IS NULL OR x_batch_status <> G_BATCH_REJECTED )
    AND p_resale_batch_rec.report_end_date IS NULL THEN

       IF OZF_DEBUG_LOW_ON THEN
          ozf_utility_pvt.debug_message ( 'Report End Date is null ');
       END IF;

       insert_resale_log
       (p_id_value      => p_resale_batch_rec.resale_batch_id,
        p_id_type       => 'BATCH',
        p_error_code    => 'OZF_REPORT_END_DATE_NULL',
        p_column_name   => NULL,
        p_column_value  => NULL,
        x_return_status => x_return_status
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       x_batch_status   :=  'REJECTED';

    END IF;   -- Report End Date null

    -- Report Start Date and End Date range check
    IF ( x_batch_status IS NULL OR x_batch_status <> G_BATCH_REJECTED )
    AND p_resale_batch_rec.report_start_date IS NOT NULL
    AND p_resale_batch_rec.report_end_date IS NOT NULL
    AND p_resale_batch_rec.report_start_date > p_resale_batch_rec.report_end_date
    THEN
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message ( 'Report start date is less than Report end date ');
         END IF;
          insert_resale_log
          (p_id_value      => p_resale_batch_rec.resale_batch_id,
           p_id_type       => 'BATCH',
           p_error_code    => 'OZF_RESALE_WNG_DATE_RANGE',
           p_column_name   => 'REPORT_END_DATE',
           p_column_value  =>  p_resale_batch_rec.report_end_date,
           x_return_status => x_return_status
          );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

    x_batch_status   :=  'REJECTED';

    END IF;     -- Date Check

 --  ========================================================================
 --   Validitity Checks
 --  ========================================================================

 --  Partner Cust Account ID Validity Check

    IF  (x_batch_status IS NULL OR x_batch_status <> G_BATCH_REJECTED )
    AND p_resale_batch_rec.partner_cust_account_id IS NOT NULL
    THEN

        OPEN  chk_cust_account ( p_resale_batch_rec.partner_cust_account_id );
        FETCH chk_cust_account  INTO l_chk_flag;
        CLOSE chk_cust_account;

        IF l_chk_flag IS NULL THEN
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message ( 'Partner Customer Account ID is invalid ');
          END IF;

          insert_resale_log
          (p_id_value      => p_resale_batch_rec.resale_batch_id,
           p_id_type       => 'BATCH',
           p_error_code    => 'OZF_BATCH_PARTNER_ERR',
           p_column_name   => 'PARTNER_CUST_ACCOUNT_ID',
           p_column_value  =>  p_resale_batch_rec.partner_cust_account_id,
           x_return_status => x_return_status
          );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

         x_batch_status   :=  'REJECTED';
        END IF;  -- l_chk_flag is NULL

    END IF;   -- partner_cust_account_id NOT NULL

    -- Batch Type OR  Transaction Type Code is null
    IF  (x_batch_status IS NULL OR x_batch_status <> G_BATCH_REJECTED )
    AND  p_resale_batch_rec.transaction_type_code IS NULL
    AND  p_resale_batch_rec.batch_type IS NULL THEN
     --
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message ( 'Batch Type and transaction_type_code is null ');
          END IF;

          insert_resale_log
          (p_id_value      => p_resale_batch_rec.resale_batch_id,
           p_id_type       => 'BATCH',
           p_error_code    => 'OZF_BATCH_TYPE_NULL',
           p_column_name   => 'BATCH_TYPE',
           p_column_value  =>  p_resale_batch_rec.batch_type,
           x_return_status => x_return_status
          );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

         x_batch_status   :=  'REJECTED';
    END IF;

    IF x_batch_status IS NULL OR x_batch_status <> G_BATCH_REJECTED THEN
       x_batch_status :=  g_batch_open;
    END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('End Time (in Seconds) in  '|| l_api_name || ' '|| (DBMS_UTILITY.GET_TIME - time)/100);
   END IF;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Validate_Batch;

PROCEDURE Batch_Defaulting
(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE,
   p_commit                IN  VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   px_resale_batch_rec     IN  OUT NOCOPY ozf_resale_batches_all%rowtype,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER,
   x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Batch_Defaulting';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  CURSOR get_partner_id(pc_party_id NUMBER)
  IS
    SELECT pvpp.partner_id
     FROM pv_partner_profiles pvpp
    WHERE pvpp.partner_party_id = pc_party_id;

  CURSOR get_partner_party_id ( pc_account_id NUMBER )
  IS
    SELECT party_id
    FROM   hz_cust_accounts
    WHERE  cust_account_id = pc_account_id;

  l_party_contact_id          NUMBER;
  l_party_id                  NUMBER;
  l_party_site_id             NUMBER;
  l_resale_batch_rec          ozf_resale_batches_all%rowtype := px_resale_batch_rec;
  l_partner_cntct_rec         party_cntct_rec_type;
  l_partner_rec               party_rec_type;
  l_dqm_contact_rule          VARCHAR2(100);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': Start');
   END IF;
--
-- Transaction Type Defaulting
-- -----------------------------------------------------------------
   IF px_resale_batch_rec.transaction_type_code IS NULL THEN
     -- derive if null based on batch type (will happen when loaded from WebADI)
        IF  px_resale_batch_rec.batch_type IS NOT NULL THEN
            IF  px_resale_batch_rec.batch_type = OZF_RESALE_COMMON_PVT.G_CHARGEBACK THEN
                l_resale_batch_rec.transaction_type_code :=  g_req_for_credit;
            ELSIF  px_resale_batch_rec.batch_type =  OZF_RESALE_COMMON_PVT.G_SPECIAL_PRICING THEN
                l_resale_batch_rec.transaction_type_code :=  g_resale;
            ELSIF  px_resale_batch_rec.batch_type =  OZF_RESALE_COMMON_PVT.G_TRACING THEN
                l_resale_batch_rec.transaction_type_code :=  g_product_transfer;
            END IF;
        END IF;
        IF OZF_DEBUG_LOW_ON THEN
           ozf_utility_pvt.debug_message ( 'Batch Type is '|| l_resale_batch_rec.batch_type);
        END IF;
   ELSE
--
-- Batch Type Defaulting
-- -----------------------------------------------------------------
        IF  px_resale_batch_rec.batch_type IS NULL THEN
            IF  px_resale_batch_rec.transaction_type_code =  g_req_for_credit THEN
                l_resale_batch_rec.batch_type := OZF_RESALE_COMMON_PVT.G_CHARGEBACK;
            ELSIF px_resale_batch_rec.transaction_type_code =  g_resale  THEN
                l_resale_batch_rec.batch_type :=  OZF_RESALE_COMMON_PVT.G_SPECIAL_PRICING;
            ELSIF px_resale_batch_rec.transaction_type_code =  g_product_transfer  THEN
                l_resale_batch_rec.batch_type :=  OZF_RESALE_COMMON_PVT.G_TRACING;
            END IF;
        END IF;
        IF OZF_DEBUG_LOW_ON THEN
           ozf_utility_pvt.debug_message ( 'transaction_type_code is '|| l_resale_batch_rec.transaction_type_code);
        END IF;
   END IF;

--
-- Report Date Defaulting
-- -----------------------------------------------------------------
   IF  px_resale_batch_rec.report_date IS NULL THEN
       l_resale_batch_rec.report_date := TO_DATE(TO_CHAR(SYSDATE,'MM/DD/YYYY'),'MM/DD/YYYY');
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'Report Date is '|| l_resale_batch_rec.report_date);
   END IF;
--
-- Transaction Purpose Code Defaulting
-- -----------------------------------------------------------------
   IF px_resale_batch_rec.transaction_purpose_code IS NULL THEN
      l_resale_batch_rec.transaction_purpose_code := g_original;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'transaction_purpose_code is '|| l_resale_batch_rec.transaction_purpose_code);
   END IF;
--
-- Partner Type Defaulting
-- -----------------------------------------------------------------
   IF px_resale_batch_rec.partner_type IS NULL THEN
      l_resale_batch_rec.partner_type := g_distributor;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'partner_type is '|| l_resale_batch_rec.partner_type);
   END IF;

   IF px_resale_batch_rec.batch_count IS NULL THEN
      l_resale_batch_rec.batch_count := 0;
   END IF;
--
-- Cust Account ID Derivation
-- -----------------------------------------------------------------
   IF px_resale_batch_rec.partner_cust_account_id IS NULL THEN
      IF  px_resale_batch_rec.partner_party_id IS NOT NULL THEN

         Get_Customer_Accnt_Id
         (
           p_party_id      => px_resale_batch_rec.partner_party_id,
           p_party_site_id => px_resale_batch_rec.partner_site_id,
           x_return_status => x_return_status,
           x_cust_acct_id  => l_resale_batch_rec.partner_cust_account_id
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message ( 'partner_cust_account_id is '|| l_resale_batch_rec.partner_cust_account_id);
         END IF;
     END IF;

   ELSE
      IF  px_resale_batch_rec.partner_party_id IS NULL THEN
         OPEN  get_partner_party_id (px_resale_batch_rec.partner_cust_account_id);
         FETCH get_partner_party_id INTO l_resale_batch_rec.partner_party_id;
         CLOSE get_partner_party_id;
      END IF;
   END IF;

   OPEN  get_partner_id (px_resale_batch_rec.partner_party_id);
   FETCH get_partner_id INTO l_resale_batch_rec.partner_id;
   CLOSE get_partner_id;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'partner_id is '|| l_resale_batch_rec.partner_id);
   END IF;
--
-- Contact Party ID derivation from DQM
-- -----------------------------------------------------------------

   IF (   l_resale_batch_rec.partner_party_id  IS NOT NULL
       OR px_resale_batch_rec.partner_party_id IS NOT NULL
      )
      AND
      (    px_resale_batch_rec.partner_contact_party_id IS NULL
      -- [BEGIN OF BUG 4355728 FIXING]
       AND px_resale_batch_rec.partner_contact_name IS NOT NULL
      -- [END OF BUG 4355728 FIXING]
      ) THEN
       IF   px_resale_batch_rec.partner_party_id IS NOT NULL THEN
          l_partner_rec.party_id                   :=  px_resale_batch_rec.partner_party_id;
       ELSIF  l_resale_batch_rec.partner_party_id IS NOT NULL THEN
          l_partner_rec.party_id                   :=  l_resale_batch_rec.partner_party_id;
       END IF;
       l_partner_cntct_rec.contact_name         :=  px_resale_batch_rec.partner_contact_name;
       l_partner_cntct_rec.party_email_id       :=  px_resale_batch_rec.partner_email;
       l_partner_cntct_rec.party_phone          :=  px_resale_batch_rec.partner_phone;
       l_partner_cntct_rec.party_fax            :=  px_resale_batch_rec.partner_fax;
       l_dqm_contact_rule                 := G_DQM_CONTACT_RULE; --fnd_profile.value('OZF_RESALE_CONTACT_DQM_RULE');
       IF OZF_DEBUG_LOW_ON THEN
          ozf_utility_pvt.debug_message ( 'DQM Contact Rule '|| l_dqm_contact_rule);
       END IF;
       IF  l_dqm_contact_rule IS NOT NULL THEN

          l_partner_cntct_rec.contact_rule_name    :=  l_dqm_contact_rule;
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message ( 'DQM Contact Rule '|| l_partner_cntct_rec.contact_rule_name);
          END IF;
          IF l_partner_cntct_rec.contact_name IS NOT NULL THEN

             DQM_Processing (
             p_api_version_number  => 1.0,
             p_init_msg_list       => FND_API.G_FALSE,
             P_Commit              => FND_API.G_FALSE,
             p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
             p_party_rec           => l_partner_rec,
             p_party_site_rec      => NULL,
             p_contact_rec         => l_partner_cntct_rec,
             x_party_id            => l_party_id,
             x_party_site_id       => l_party_site_id,
             x_party_contact_id    => l_party_contact_id,
             x_return_status       => x_return_status,
             x_msg_count           => x_msg_count,
             x_msg_data            => x_msg_data);

             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 insert_resale_log
                 (p_id_value        => px_resale_batch_rec.resale_batch_id,
                  p_id_type         => 'BATCH',
                  p_error_code      => 'OZF_DQM_PROCESS_ERROR',
                  p_column_name     => 'P_PARTNER_CONTACT_NAME',
                  p_column_value    =>  px_resale_batch_rec.batch_type,
                  x_return_status   => x_return_status
                 );

                 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF  l_party_contact_id IS NULL THEN
                l_resale_batch_rec.partner_contact_party_id := l_party_contact_id;
             ELSE
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('DQM did not return any contacts ' );
                END IF;
             END IF;

          ELSE
             IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('Partner Contact name is null ' );
             END IF;
          END IF; --l_partner_cntct_rec.contact_name
       ELSE
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message('DQM rules are not setup ' );
          END IF;
      END IF;
   END IF;  -- px_resale_batch_rec.partner_contact_party_id

--
-- Status Defaulting
-- -----------------------------------------------------------------
   IF  l_resale_batch_rec.status_code = 'NEW'
   OR  l_resale_batch_rec.status_code IS NULL THEN
       l_resale_batch_rec.status_code        := 'OPEN';
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'Status Code '|| l_resale_batch_rec.status_code);
   END IF;

--
-- Org ID Defaulting
-- -----------------------------------------------------------------

   IF  l_resale_batch_rec.org_id IS NULL THEN
       l_resale_batch_rec.org_id := G_DEFAULT_ORG_ID; --FND_PROFILE.value('DEFAULT_ORG_ID');
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ( 'Org ID '|| l_resale_batch_rec.org_id);
   END IF;
--  Derived Record Assignment
-- -----------------------------------------------------------------
   px_resale_batch_rec := l_resale_batch_rec;

   g_batch_currency_code := l_resale_batch_rec.currency_code;

-- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message(l_api_name||': End');
   END IF;

--Standard call to get message count AND IF count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );
--
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Batch_Defaulting;


PROCEDURE Lines_Update
(
   p_batch_id              IN  NUMBER,
   px_batch_record         IN  OUT NOCOPY ozf_resale_batches_all%rowtype,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER
)
IS

  l_api_name                  CONSTANT VARCHAR2(30) := 'Lines_Update';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  CURSOR csr_get_line_info(cv_batch_id NUMBER)
  IS
  SELECT resale_line_int_id
       , object_version_number
       , resale_batch_id
       , status_code
       , resale_transfer_type
       , product_transfer_movement_type
       , tracing_flag
       , ship_from_cust_account_id
       , ship_from_site_id
       , ship_from_party_name
       , ship_from_location
       , ship_from_address
       , ship_from_city
       , ship_from_state
       , ship_from_postal_code
       , ship_from_country
       , ship_from_contact_party_id
       , ship_from_contact_name
       , ship_from_email
       , ship_from_fax
       , ship_from_phone
       , sold_from_cust_account_id
       , sold_from_site_id
       , sold_from_party_name
       , sold_from_location
       , sold_from_address
       , sold_from_city
       , sold_from_state
       , sold_from_postal_code
       , sold_from_country
       , sold_from_contact_party_id
       , sold_from_contact_name
       , sold_from_email
       , sold_from_phone
       , sold_from_fax
       , bill_to_cust_account_id
       , bill_to_site_use_id
       , bill_to_party_id
       , bill_to_party_site_id
       , bill_to_party_name
       , bill_to_duns_number
       , bill_to_location
       , bill_to_address
       , bill_to_city
       , bill_to_state
       , bill_to_postal_code
       , bill_to_country
       , bill_to_contact_party_id
       , bill_to_contact_name
       , bill_to_email
       , bill_to_phone
       , bill_to_fax
       , ship_to_cust_account_id
       , ship_to_site_use_id
       , ship_to_party_id
       , ship_to_party_site_id
       , ship_to_party_name
       , ship_to_duns_number
       , ship_to_location
       , ship_to_address
       , ship_to_city
       , ship_to_country
       , ship_to_postal_code
       , ship_to_state
       , ship_to_contact_party_id
       , ship_to_contact_name
       , ship_to_email
       , ship_to_phone
       , ship_to_fax
       , end_cust_party_id
       , end_cust_site_use_id
       , end_cust_site_use_code
       , end_cust_party_site_id
       , end_cust_party_name
       , end_cust_location
       , end_cust_address
       , end_cust_city
       , end_cust_state
       , end_cust_postal_code
       , end_cust_country
       , end_cust_contact_party_id
       , end_cust_contact_name
       , end_cust_email
       , end_cust_phone
       , end_cust_fax
       , direct_customer_flag
       , order_type_id
       , order_type
       , order_category
       , agreement_type
       , agreement_id
       , agreement_name
       , agreement_price
       , agreement_uom_code
       , corrected_agreement_id
       , corrected_agreement_name
       , price_list_id
       , orig_system_currency_code
       , orig_system_selling_price
       , orig_system_quantity
       , orig_system_uom
       , orig_system_purchase_uom
       , orig_system_purchase_curr
       , orig_system_purchase_price
       , orig_system_purchase_quantity
       , orig_system_agreement_uom
       , orig_system_agreement_name
       , orig_system_agreement_type
       , orig_system_agreement_curr
       , orig_system_agreement_price
       , orig_system_agreement_quantity
       , orig_system_item_number
       , currency_code
       , exchange_rate_type
       , exchange_rate_date
       , exchange_rate
       , order_number
       , date_ordered
       , claimed_amount
       , total_claimed_amount
       , purchase_price
       , acctd_purchase_price
       , purchase_uom_code
       , selling_price
       , acctd_selling_price
       , uom_code
       , quantity
       , inventory_item_id
       , item_number
       , dispute_code
       , data_source_code
       , org_id
       , response_code
    FROM  ozf_resale_lines_int
   WHERE  resale_batch_id = cv_batch_id
    -- AND  status_code IN ('NEW', 'OPEN', 'DUPLICATED', 'DISPUTED', 'PROCESSED')
     --------------------------------------------------------------
     -- We're going to process all the lines regardless of the status
     -- Since there is no closed line, we don't need status code clause
     --------------------------------------------------------------
   ORDER BY resale_line_int_id;

  l_line_record     resale_line_int_rec_type;
  l_array_size      NUMBER    DEFAULT 10;
  l_done            BOOLEAN;
  l_cnt             NUMBER    DEFAULT 0;
  l_line_count      NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': Start');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OPEN  csr_get_line_info ( p_batch_id);
   LOOP
      -- bulk fetch the lines data
      FETCH csr_get_line_info
      BULK COLLECT INTO   l_line_record.resale_line_int_id
                        , l_line_record.object_version_number
                        , l_line_record.resale_batch_id
                        , l_line_record.status_code
                        , l_line_record.resale_transfer_type
                        , l_line_record.product_transfer_movement_type
                        , l_line_record.tracing_flag
                        , l_line_record.ship_from_cust_account_id
                        , l_line_record.ship_from_site_id
                        , l_line_record.ship_from_party_name
                        , l_line_record.ship_from_location
                        , l_line_record.ship_from_address
                        , l_line_record.ship_from_city
                        , l_line_record.ship_from_state
                        , l_line_record.ship_from_postal_code
                        , l_line_record.ship_from_country
                        , l_line_record.ship_from_contact_party_id
                        , l_line_record.ship_from_contact_name
                        , l_line_record.ship_from_email
                        , l_line_record.ship_from_fax
                        , l_line_record.ship_from_phone
                        , l_line_record.sold_from_cust_account_id
                        , l_line_record.sold_from_site_id
                        , l_line_record.sold_from_party_name
                        , l_line_record.sold_from_location
                        , l_line_record.sold_from_address
                        , l_line_record.sold_from_city
                        , l_line_record.sold_from_state
                        , l_line_record.sold_from_postal_code
                        , l_line_record.sold_from_country
                        , l_line_record.sold_from_contact_party_id
                        , l_line_record.sold_from_contact_name
                        , l_line_record.sold_from_email
                        , l_line_record.sold_from_phone
                        , l_line_record.sold_from_fax
                        , l_line_record.bill_to_cust_account_id
                        , l_line_record.bill_to_site_use_id
                        , l_line_record.bill_to_party_id
                        , l_line_record.bill_to_party_site_id
                        , l_line_record.bill_to_party_name
                        , l_line_record.bill_to_duns_number
                        , l_line_record.bill_to_location
                        , l_line_record.bill_to_address
                        , l_line_record.bill_to_city
                        , l_line_record.bill_to_state
                        , l_line_record.bill_to_postal_code
                        , l_line_record.bill_to_country
                        , l_line_record.bill_to_contact_party_id
                        , l_line_record.bill_to_contact_name
                        , l_line_record.bill_to_email
                        , l_line_record.bill_to_phone
                        , l_line_record.bill_to_fax
                        , l_line_record.ship_to_cust_account_id
                        , l_line_record.ship_to_site_use_id
                        , l_line_record.ship_to_party_id
                        , l_line_record.ship_to_party_site_id
                        , l_line_record.ship_to_party_name
                        , l_line_record.ship_to_duns_number
                        , l_line_record.ship_to_location
                        , l_line_record.ship_to_address
                        , l_line_record.ship_to_city
                        , l_line_record.ship_to_country
                        , l_line_record.ship_to_postal_code
                        , l_line_record.ship_to_state
                        , l_line_record.ship_to_contact_party_id
                        , l_line_record.ship_to_contact_name
                        , l_line_record.ship_to_email
                        , l_line_record.ship_to_phone
                        , l_line_record.ship_to_fax
                        , l_line_record.end_cust_party_id
                        , l_line_record.end_cust_site_use_id
                        , l_line_record.end_cust_site_use_code
                        , l_line_record.end_cust_party_site_id
                        , l_line_record.end_cust_party_name
                        , l_line_record.end_cust_location
                        , l_line_record.end_cust_address
                        , l_line_record.end_cust_city
                        , l_line_record.end_cust_state
                        , l_line_record.end_cust_postal_code
                        , l_line_record.end_cust_country
                        , l_line_record.end_cust_contact_party_id
                        , l_line_record.end_cust_contact_name
                        , l_line_record.end_cust_email
                        , l_line_record.end_cust_phone
                        , l_line_record.end_cust_fax
                        , l_line_record.direct_customer_flag
                        , l_line_record.order_type_id
                        , l_line_record.order_type
                        , l_line_record.order_category
                        , l_line_record.agreement_type
                        , l_line_record.agreement_id
                        , l_line_record.agreement_name
                        , l_line_record.agreement_price
                        , l_line_record.agreement_uom_code
                        , l_line_record.corrected_agreement_id
                        , l_line_record.corrected_agreement_name
                        , l_line_record.price_list_id
                        , l_line_record.orig_system_currency_code
                        , l_line_record.orig_system_selling_price
                        , l_line_record.orig_system_quantity
                        , l_line_record.orig_system_uom
                        , l_line_record.orig_system_purchase_uom
                        , l_line_record.orig_system_purchase_curr
                        , l_line_record.orig_system_purchase_price
                        , l_line_record.orig_system_purchase_quantity
                        , l_line_record.orig_system_agreement_uom
                        , l_line_record.orig_system_agreement_name
                        , l_line_record.orig_system_agreement_type
                        , l_line_record.orig_system_agreement_curr
                        , l_line_record.orig_system_agreement_price
                        , l_line_record.orig_system_agreement_quantity
                        , l_line_record.orig_system_item_number
                        , l_line_record.currency_code
                        , l_line_record.exchange_rate_type
                        , l_line_record.exchange_rate_date
                        , l_line_record.exchange_rate
                        , l_line_record.order_number
                        , l_line_record.date_ordered
                        , l_line_record.claimed_amount
                        , l_line_record.total_claimed_amount
                        , l_line_record.purchase_price
                        , l_line_record.acctd_purchase_price
                        , l_line_record.purchase_uom_code
                        , l_line_record.selling_price
                        , l_line_record.acctd_selling_price
                        , l_line_record.uom_code
                        , l_line_record.quantity
                        , l_line_record.inventory_item_id
                        , l_line_record.item_number
                        , l_line_record.dispute_code
                        , l_line_record.data_source_code
                        , l_line_record.org_id
                        , l_line_record.response_code
      LIMIT l_array_size;
      l_done := csr_get_line_info%notfound;
      l_cnt := l_cnt + l_line_record.resale_line_int_id.count;
      l_line_count := l_line_record.resale_line_int_id.count;

      -- if the batch status is  rejected, update all line status to Rejected
      -- without processing

      IF l_cnt = 0 OR px_batch_record.status_code = g_batch_rejected THEN
         l_line_record.status_code  :=  set_line_status
                                      ( l_line_count
                                       ,'REJECTED');
         IF  l_cnt = 0 THEN
             px_batch_record.status_code :=  g_batch_rejected;
         END IF;
      ELSE
         -- Initialize line status to 'OPEN' for all the lines
         l_line_record.status_code  :=  set_line_status
                                      ( l_line_count
                                       ,'OPEN');
         -- Process the lines
         Lines_Process
         (
           p_line_count     =>  l_line_record.resale_line_int_id.count,
           px_batch_record  =>  px_batch_record,
           px_line_record   =>  l_line_record,
           x_return_status  =>  x_return_status,
           x_msg_count      =>  x_msg_count,
           x_msg_data       =>  x_msg_data
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

     END IF;

     -- Bulk update the lines with processed values
     Lines_Bulk_Update
     (
       p_batch_id      => p_batch_id,
       p_line_record   => l_line_record,
       x_return_status => x_return_status
     );
     EXIT WHEN (l_done);
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END LOOP;
   CLOSE csr_get_line_info;
   -- Total Line Count
 /*  IF px_batch_record.batch_count IS NULL
   OR    px_batch_record.batch_count = 0 THEN
         px_batch_record.batch_count :=  l_cnt;
   ELSE
      IF px_batch_record.batch_set_id_code = 'WEBADI' THEN
         IF l_cnt > 0 THEN
            px_batch_record.batch_count := px_batch_record.batch_count + l_cnt;
          END IF;
      ELSE
         px_batch_record.batch_count :=  l_cnt;
      END IF;
   END IF;     */
   -- Setting Dispute Status and Disputed Line Count
 /*  IF G_DISPUTED_LINE_COUNT > 0 THEN
      px_batch_record.status_code      :=  g_batch_disputed;
      px_batch_record.lines_disputed   :=  g_disputed_line_count;
   END IF;
   -- if the processed lines is equal to number of lines fetched then set the batch status to
   -- 'OPEN'
   IF G_LINES_PROCESSED = l_cnt THEN
      px_batch_record.status_code      :=  g_batch_open;
   END IF;      */
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Total Line Count '|| l_cnt);
   END IF;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': End');
   END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
END Lines_Update;

PROCEDURE  Lines_Process
(
   p_line_count            IN  NUMBER,
   px_batch_record         IN  OUT NOCOPY ozf_resale_batches_all%rowtype,
   px_line_record          IN  OUT NOCOPY  resale_line_int_rec_type,
   x_return_status         OUT NOCOPY  VARCHAR2,
   x_msg_data              OUT NOCOPY  VARCHAR2,
   x_msg_count             OUT NOCOPY  NUMBER
)
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Lines_Process';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'ozf.idsm.workflow.preprocess.lines_process',
         'Private API: ' || l_api_name || ' start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- julou 6165855: changed the order of Code_ID_Mapping and Line_Defaulting
   -- Apply the defaulting rules to the line
   Line_Defaulting(
    p_line_count    => p_line_count,
    px_line_record  => px_line_record,
    x_return_status => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- For all the external codes get the internal code
   Code_ID_Mapping(
    p_batch_record  =>  px_batch_record,
    px_line_record  =>  px_line_record,
    x_return_status =>  x_return_status,
    x_msg_count     =>  x_msg_count,
    x_msg_data      =>  x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- Validate the line with supplied values
   Line_Validations(
     p_line_count     => p_line_count,
     px_batch_record  => px_batch_record,
     px_line_record   => px_line_record,
     x_return_status  => x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'ozf.idsm.workflow.preprocess.lines_process',
         'Private API: ' || l_api_name || ' end');
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
END Lines_Process;

PROCEDURE  Lines_Bulk_Update
(
  p_batch_id       IN  NUMBER,
  p_line_record    IN  resale_line_int_rec_type,
  x_return_status  OUT NOCOPY  VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Lines_Bulk_Update';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   cnt                         NUMBER := 0;

BEGIN
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Batch ID ' || p_batch_id);
      ozf_utility_pvt.debug_message('Line Count in line bulk update ' || p_line_record.resale_line_int_id.COUNT);
   END IF;

   FORALL i IN 1 .. p_line_record.resale_line_int_id.COUNT
     UPDATE ozf_resale_lines_int_all
     SET    object_version_number         = p_line_record.object_version_number(i)
     ,      resale_batch_id               = p_line_record.resale_batch_id(i)
     ,      status_code                   = p_line_record.status_code(i)
     ,      resale_transfer_type          = p_line_record.resale_transfer_type(i)
     ,      product_transfer_movement_type= p_line_record.product_transfer_movement_type(i)
     ,      tracing_flag                  = p_line_record.tracing_flag(i)
     ,      ship_from_cust_account_id     = p_line_record.ship_from_cust_account_id(i)
     ,      ship_from_site_id             = p_line_record.ship_from_site_id(i)
     ,      ship_from_party_name          = p_line_record.ship_from_party_name(i)
     ,      ship_from_location            = p_line_record.ship_from_location(i)
     ,      ship_from_address             = p_line_record.ship_from_address(i)
     ,      ship_from_city                = p_line_record.ship_from_city(i)
     ,      ship_from_state               = p_line_record.ship_from_state(i)
     ,      ship_from_postal_code         = p_line_record.ship_from_postal_code(i)
     ,      ship_from_country             = p_line_record.ship_from_country(i)
     ,      ship_from_contact_party_id    = p_line_record.ship_from_contact_party_id(i)
     ,      ship_from_contact_name        = p_line_record.ship_from_contact_name(i)
     ,      ship_from_email               = p_line_record.ship_from_email(i)
     ,      ship_from_fax                 = p_line_record.ship_from_fax(i)
     ,      ship_from_phone               = p_line_record.ship_from_phone(i)
     ,      sold_from_cust_account_id     = p_line_record.sold_from_cust_account_id(i)
     ,      sold_from_site_id             = p_line_record.sold_from_site_id(i)
     ,      sold_from_party_name          = p_line_record.sold_from_party_name(i)
     ,      sold_from_location            = p_line_record.sold_from_location(i)
     ,      sold_from_address             = p_line_record.sold_from_address(i)
     ,      sold_from_city                = p_line_record.sold_from_city(i)
     ,      sold_from_state               = p_line_record.sold_from_state(i)
     ,      sold_from_postal_code         = p_line_record.sold_from_postal_code(i)
     ,      sold_from_country             = p_line_record.sold_from_country(i)
     ,      sold_from_contact_party_id    = p_line_record.sold_from_contact_party_id(i)
     ,      sold_from_contact_name        = p_line_record.sold_from_contact_name(i)
     ,      sold_from_email               = p_line_record.sold_from_email(i)
     ,      sold_from_phone               = p_line_record.sold_from_phone(i)
     ,      sold_from_fax                 = p_line_record.sold_from_fax(i)
     ,      bill_to_cust_account_id       = p_line_record.bill_to_cust_account_id(i)
     ,      bill_to_site_use_id           = p_line_record.bill_to_site_use_id(i)
     ,      bill_to_party_id              = p_line_record.bill_to_party_id(i)
     ,      bill_to_party_site_id         = p_line_record.bill_to_party_site_id(i)
     ,      bill_to_party_name            = p_line_record.bill_to_party_name(i)
     ,      bill_to_duns_number           = p_line_record.bill_to_duns_number(i)
     ,      bill_to_location              = p_line_record.bill_to_location(i)
     ,      bill_to_address               = p_line_record.bill_to_address(i)
     ,      bill_to_city                  = p_line_record.bill_to_city(i)
     ,      bill_to_state                 = p_line_record.bill_to_state(i)
     ,      bill_to_postal_code           = p_line_record.bill_to_postal_code(i)
     ,      bill_to_country               = p_line_record.bill_to_country(i)
     ,      bill_to_contact_party_id      = p_line_record.bill_to_contact_party_id(i)
     ,      bill_to_contact_name          = p_line_record.bill_to_contact_name(i)
     ,      bill_to_email                 = p_line_record.bill_to_email(i)
     ,      bill_to_phone                 = p_line_record.bill_to_phone(i)
     ,      bill_to_fax                   = p_line_record.bill_to_fax(i)
     ,      ship_to_cust_account_id       = p_line_record.ship_to_cust_account_id(i)
     ,      ship_to_site_use_id           = p_line_record.ship_to_site_use_id(i)
     ,      ship_to_party_id              = p_line_record.ship_to_party_id(i)
     ,      ship_to_party_site_id         = p_line_record.ship_to_party_site_id(i)
     ,      ship_to_party_name            = p_line_record.ship_to_party_name(i)
     ,      ship_to_duns_number           = p_line_record.ship_to_duns_number(i)
     ,      ship_to_location              = p_line_record.ship_to_location(i)
     ,      ship_to_address               = p_line_record.ship_to_address(i)
     ,      ship_to_city                  = p_line_record.ship_to_city(i)
     ,      ship_to_country               = p_line_record.ship_to_country(i)
     ,      ship_to_postal_code           = p_line_record.ship_to_postal_code(i)
     ,      ship_to_state                 = p_line_record.ship_to_state(i)
     ,      ship_to_contact_party_id      = p_line_record.ship_to_contact_party_id(i)
     ,      ship_to_contact_name          = p_line_record.ship_to_contact_name(i)
     ,      ship_to_email                 = p_line_record.ship_to_email(i)
     ,      ship_to_phone                 = p_line_record.ship_to_phone(i)
     ,      ship_to_fax                   = p_line_record.ship_to_fax(i)
     ,      end_cust_party_id             = p_line_record.end_cust_party_id(i)
     ,      end_cust_site_use_id          = p_line_record.end_cust_site_use_id(i)
     ,      end_cust_site_use_code        = p_line_record.end_cust_site_use_code(i)
     ,      end_cust_party_site_id        = p_line_record.end_cust_party_site_id(i)
     ,      end_cust_party_name           = p_line_record.end_cust_party_name(i)
     ,      end_cust_location             = p_line_record.end_cust_location(i)
     ,      end_cust_address              = p_line_record.end_cust_address(i)
     ,      end_cust_city                 = p_line_record.end_cust_city(i)
     ,      end_cust_state                = p_line_record.end_cust_state(i)
     ,      end_cust_postal_code          = p_line_record.end_cust_postal_code(i)
     ,      end_cust_country              = p_line_record.end_cust_country(i)
     ,      end_cust_contact_party_id     = p_line_record.end_cust_contact_party_id(i)
     ,      end_cust_contact_name         = p_line_record.end_cust_contact_name(i)
     ,      end_cust_email                = p_line_record.end_cust_email(i)
     ,      end_cust_phone                = p_line_record.end_cust_phone(i)
     ,      end_cust_fax                  = p_line_record.end_cust_fax(i)
     ,      direct_customer_flag          = p_line_record.direct_customer_flag(i)
     ,      order_type_id                 = p_line_record.order_type_id(i)
     ,      order_type                    = p_line_record.order_type(i)
     ,      order_category                = p_line_record.order_category(i)
     ,      agreement_type                = p_line_record.agreement_type(i)
     ,      agreement_id                  = p_line_record.agreement_id(i)
     ,      agreement_name                = p_line_record.agreement_name(i)
     ,      agreement_price               = p_line_record.agreement_price(i)
     ,      agreement_uom_code            = p_line_record.agreement_uom_code(i)
     ,      corrected_agreement_id        = p_line_record.corrected_agreement_id(i)
     ,      corrected_agreement_name      = p_line_record.corrected_agreement_name(i)
     ,      price_list_id                 = p_line_record.price_list_id(i)
     ,      orig_system_currency_code     = p_line_record.orig_system_currency_code(i)
     ,      orig_system_selling_price     = p_line_record.orig_system_selling_price(i)
     ,      orig_system_quantity          = p_line_record.orig_system_quantity(i)
     ,      orig_system_uom               = p_line_record.orig_system_uom(i)
     ,      orig_system_purchase_uom      = p_line_record.orig_system_purchase_uom(i)
     ,      orig_system_purchase_curr     = p_line_record.orig_system_purchase_curr(i)
     ,      orig_system_purchase_price    = p_line_record.orig_system_purchase_price(i)
     ,      orig_system_purchase_quantity = p_line_record.orig_system_purchase_quantity(i)
     ,      orig_system_agreement_uom     = p_line_record.orig_system_agreement_uom(i)
     ,      orig_system_agreement_name    = p_line_record.orig_system_agreement_name(i)
     ,      orig_system_agreement_type    = p_line_record.orig_system_agreement_type(i)
     ,      orig_system_agreement_curr    = p_line_record.orig_system_agreement_curr(i)
     ,      orig_system_agreement_price   = p_line_record.orig_system_agreement_price(i)
     ,      orig_system_agreement_quantity= p_line_record.orig_system_agreement_quantity(i)
     ,      orig_system_item_number       = p_line_record.orig_system_item_number(i)
     ,      currency_code                 = p_line_record.currency_code(i)
     ,      exchange_rate_type            = p_line_record.exchange_rate_type(i)
     ,      exchange_rate                 = p_line_record.exchange_rate(i)
     ,      order_number                  = p_line_record.order_number(i)
     ,      date_ordered                  = p_line_record.date_ordered(i)
     ,      claimed_amount                = p_line_record.claimed_amount(i)
     ,      total_claimed_amount          = p_line_record.total_claimed_amount(i)
     ,      purchase_price                = p_line_record.purchase_price(i)
     ,      acctd_purchase_price          = p_line_record.acctd_purchase_price(i)
     ,      purchase_uom_code             = p_line_record.purchase_uom_code(i)
     ,      selling_price                 = p_line_record.selling_price(i)
     ,      acctd_selling_price           = p_line_record.acctd_selling_price(i)
     ,      uom_code                      = p_line_record.uom_code(i)
     ,      quantity                      = p_line_record.quantity(i)
     ,      inventory_item_id             = p_line_record.inventory_item_id(i)
     ,      item_number                   = p_line_record.item_number(i)
     ,      dispute_code                  = p_line_record.dispute_code(i)
     ,      data_source_code              = p_line_record.data_source_code(i)
     ,      org_id                        = p_line_record.org_id(i)
     ,      response_code                 = p_line_record.response_code(i)
     WHERE  resale_batch_id = p_batch_id
     AND    resale_line_int_id = p_line_record.resale_line_int_id(i);

     IF OZF_DEBUG_HIGH_ON THEN
        ozf_utility_pvt.debug_message('SQL%RowCount ' || SQL%ROWCOUNT);
        ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
     END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Lines_Bulk_Update;

PROCEDURE Line_Defaulting
(
  p_line_count    IN  NUMBER,
  px_line_record  IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Line_Defaulting';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_batch_type                         VARCHAR2(30);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Inventory Tracking Flag

   OPEN OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
   FETCH OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr INTO g_inventory_tracking_flag;
   CLOSE OZF_RESALE_COMMON_PVT.g_inventory_tracking_csr;
   IF  g_inventory_tracking_flag IS NULL THEN
       g_inventory_tracking_flag := 'F';
   END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Inventory Tracking Flag ' || g_inventory_tracking_flag);
   END IF;
  -- Derive the currency from batch if the line currency is null
  -- and the purchase price and selling price is dervied by applying the
  -- currency conversion if the currencies are different for purchase, agreement and selling price

  Line_Currency_Price_Derivation
  (
    p_line_count     => p_line_count,
    px_line_record   => px_line_record,
    x_return_status  => x_return_status
  );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF  p_line_count > 0 THEN
     OPEN OZF_RESALE_COMMON_PVT.g_batch_type_csr(px_line_record.resale_batch_id(1));
     FETCH OZF_RESALE_COMMON_PVT.g_batch_type_csr INTO l_batch_type;
     CLOSE OZF_RESALE_COMMON_PVT.g_batch_type_csr;

     FOR i IN 1 .. p_line_count
     LOOP

        -- Derive ORG ID
        IF  px_line_record.org_id(i) IS NULL THEN
            px_line_record.org_id(i) := G_DEFAULT_ORG_ID; --FND_PROFILE.value('DEFAULT_ORG_ID');
        END IF;
        -- Derive Quantity from External Quantity
        IF  px_line_record.quantity(i) IS NULL THEN
           IF px_line_record.orig_system_quantity(i) IS NOT NULL THEN
              px_line_record.quantity(i) := px_line_record.orig_system_quantity(i);
           END IF;
        END IF;
        -- Derive Product Transfer Movement Type from Order Category OR Quantity
        IF px_line_record.product_transfer_movement_type(i) IS NULL THEN
           IF  px_line_record.order_category(i) IS NOT NULL THEN
               IF  px_line_record.order_category(i) = 'ORDER' THEN
                   px_line_record.product_transfer_movement_type(i) := g_mvmt_dist_to_cust;
               ELSIF px_line_record.order_category(i) = 'RETURN' THEN
                   px_line_record.product_transfer_movement_type(i) := g_mvmt_cust_to_dist;
               END IF;
           ELSE
               IF px_line_record.quantity(i) < 0  THEN
                  px_line_record.product_transfer_movement_type(i) := g_mvmt_cust_to_dist;
               ELSE
                  px_line_record.product_transfer_movement_type(i) := g_mvmt_dist_to_cust;
               END IF;
           END IF; -- sign(p_quantity(i)) = -1
        END IF;
        IF OZF_DEBUG_LOW_ON THEN
           ozf_utility_pvt.debug_message('Movement Type ' || px_line_record.product_transfer_movement_type(i));
        END IF;

        -- Derive Resale Transfer Type

        IF px_line_record.resale_transfer_type(i) IS NULL THEN
           -- BUG 4558568 (+)
           IF SIGN(px_line_record.quantity(i)) = -1 AND
              px_line_record.product_transfer_movement_type(i) = g_mvmt_cust_to_dist THEN
              px_line_record.resale_transfer_type(i) := g_tsfr_return;
           ELSE
           -- BUG 4558568 (-)
              IF  px_line_record.agreement_name(i) IS NOT NULL
              OR  px_line_record.agreement_id(i) IS NOT NULL THEN
                  px_line_record.resale_transfer_type(i)   := g_tsfr_ship_debit_sale;
              ELSE
                  IF px_line_record.product_transfer_movement_type(i)
                                             IN (g_mvmt_tsfr_in,g_mvmt_tsfr_out) THEN
                      px_line_record.resale_transfer_type(i) := g_tsfr_inter_branch;
                  ELSIF  px_line_record.product_transfer_movement_type(i) = g_mvmt_cust_to_dist  THEN
                      px_line_record.resale_transfer_type(i) := g_tsfr_return;
                  ELSIF px_line_record.product_transfer_movement_type(i) = g_mvmt_dist_to_cust THEN
                      px_line_record.resale_transfer_type(i) := g_tsfr_stock_sale;
                  END IF; -- px_line_record.product_transfer_movement_type
              END IF; -- p_agreement_name(i) IS NOT NULL
           END IF;
        END IF;  -- px_line_record.resale_transfer_type(i) IS NULL

        IF OZF_DEBUG_LOW_ON THEN
           ozf_utility_pvt.debug_message('resale_transfer_type' || px_line_record.resale_transfer_type(i));
        END IF;

        -- Derive Order Category

       IF  px_line_record.order_category(i) IS NULL THEN
          IF  px_line_record.product_transfer_movement_type(i) = g_mvmt_cust_to_dist THEN
               px_line_record.order_category(i) := 'RETURN';
          ELSIF px_line_record.product_transfer_movement_type(i) =  g_mvmt_dist_to_cust THEN
               px_line_record.order_category(i) := 'ORDER';
          END IF;

       END IF;

       IF OZF_DEBUG_LOW_ON THEN
          ozf_utility_pvt.debug_message('order_category' || px_line_record.order_category(i));
       END IF;

       OPEN  OZF_RESALE_COMMON_PVT.g_batch_type_csr(px_line_record.resale_batch_id(i));
       FETCH OZF_RESALE_COMMON_PVT.g_batch_type_csr INTO l_batch_type;
       CLOSE OZF_RESALE_COMMON_PVT.g_batch_type_csr;

       IF l_batch_type = 'TP_ACCRUAL' THEN
         IF px_line_record.agreement_type(i) IS NULL AND px_line_record.agreement_id(i) IS NULL AND px_line_record.price_list_id(i) IS NULL THEN
           px_line_record.price_list_id(i) := FND_PROFILE.value('OZF_TP_ACCRUAL_PRICE_LIST');
         END IF;
       END IF;

       IF px_line_record.price_list_id(i) IS NOT NULL AND
          px_line_record.agreement_id(i) IS NULL THEN
          px_line_record.agreement_type(i) := 'PL';
          px_line_record.agreement_id(i) := px_line_record.price_list_id(i);
       ELSIF px_line_record.price_list_id(i) IS NULL AND
             px_line_record.agreement_id(i) IS NOT NULL AND
             px_line_record.agreement_type(i) = 'PL' THEN
          px_line_record.price_list_id(i) := px_line_record.agreement_id(i);
       END IF;
       IF OZF_DEBUG_LOW_ON THEN
          ozf_utility_pvt.debug_message('agreement_id' || px_line_record.agreement_id(i));
       END IF;

        -- Derive Tracing flag
       IF px_line_record.tracing_flag(i) IS NULL THEN
          IF l_batch_type = 'TRACING' THEN
             px_line_record.tracing_flag(i) := 'T';
          ELSIF px_line_record.agreement_type(i) IS NULL AND
             px_line_record.agreement_id(i) IS NULL AND
             px_line_record.agreement_name(i) IS NULL THEN
             px_line_record.tracing_flag(i) := 'T';
          ELSE
             px_line_record.tracing_flag(i) := 'F';
          END IF;
       END IF;
       IF OZF_DEBUG_LOW_ON THEN
          ozf_utility_pvt.debug_message('tracing_flag' || px_line_record.tracing_flag(i));
       END IF;
    END LOOP;

  END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': End');
   END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Line_Defaulting;


PROCEDURE Line_Validations(
  p_line_count           IN  NUMBER,
  px_batch_record        IN  OUT NOCOPY ozf_resale_batches_all%ROWTYPE,
  px_line_record         IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status        OUT NOCOPY  VARCHAR2
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Line_Validations';
l_api_version_number        CONSTANT NUMBER   := 1.0;

CURSOR get_order_type_id(pc_date_ordered IN DATE
                        ,pc_order_type   IN VARCHAR2) IS
  SELECT transaction_type_id
  FROM oe_transaction_types_vl
  WHERE transaction_type_code = 'ORDER'
  AND TO_DATE(TO_CHAR(pc_date_ordered, 'MM/DD/YYYY'), 'MM/DD/YYYY')
  BETWEEN start_date_active AND NVL(end_date_active, SYSDATE)
  AND name = pc_order_type;

CURSOR chk_order_type (pc_order_type    IN VARCHAR2
                      ,pc_order_type_id IN NUMBER) IS
  SELECT 'X'
  FROM oe_transaction_types_vl
  WHERE transaction_type_id = pc_order_type_id
  UNION ALL
  SELECT 'X'
  FROM oe_transaction_types_vl
  WHERE name =  pc_order_type ;

CURSOR get_functional_currency IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs,
       ozf_sys_parameters osp
  WHERE gs.set_of_books_id = osp.set_of_books_id
  AND   osp.org_id = MO_GLOBAL.get_current_org_id(); -- BUG 5058027

CURSOR get_item_number ( pc_item_id IN NUMBER, pc_org_id IN NUMBER) IS
  SELECT concatenated_segments
  FROM mtl_system_items_vl
  WHERE inventory_item_id = pc_item_id
  AND organization_id = pc_org_id;

CURSOR price_list_org(cv_price_list_id IN NUMBER) IS
  SELECT b.orig_org_id
  FROM qp_list_headers_b b
     , qp_list_headers_tl tl
  WHERE b.list_header_id = tl.list_header_id
  ANd b.list_header_id = cv_price_list_id;

CURSOR spr_org(cv_reqeust_header_id IN NUMBER) IS
  SELECT org_id
  FROM ozf_request_headers_all_b
  WHERE request_header_id = cv_reqeust_header_id;

l_exchange_rate_type         VARCHAR2(100);
l_exchange_rate              NUMBER;
l_functional_currency        VARCHAR2(15);
l_dispute_code               VARCHAR2(100);
x                            VARCHAR2(1);
l_column_name                VARCHAR2(300);
l_column_value               VARCHAR2(3200);
l_msg_count                  NUMBER;
l_msg_data                   VARCHAR2(32000);
l_org_id                     NUMBER;
l_new_converted_amount       NUMBER;
l_agreement_org_id           NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Retrieval of all the party related details
   -----------------------------------------------------------------------
   Line_Party_Validations(
      p_line_count     => p_line_count,
      px_line_record   => px_line_record,
      x_return_status  => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   FOR i IN 1 ..  p_line_count  LOOP
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('Direct Customer Flag ('||i||')'|| px_line_record.direct_customer_flag(i));
      END IF;

      IF px_line_record.sold_from_cust_account_id(i) IS NULL THEN
         px_line_record.sold_from_cust_account_id(i) := px_batch_record.partner_cust_account_id;

         IF px_line_record.sold_from_cust_account_id(i) IS NULL THEN
            IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
               px_line_record.status_code(i) := 'DISPUTED';
               px_line_record.dispute_code(i) := 'OZF_RESALE_SOLD_FROM_MISS';
            END IF;

            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        => 'IFACE',
                p_error_code     =>  'OZF_RESALE_SOLD_FROM_MISS',
                p_column_name    =>  'SOLD_FROM_CUST_ACCOUNT_ID',
                p_column_value   =>  NULL,
                x_return_status  =>  x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF;

      -- Sold From Site ID
      IF px_line_record.sold_from_site_id(i) IS NULL THEN
         px_line_record.sold_from_site_id(i) := px_batch_record.partner_site_id;
      END IF;

      -- Ship From Customer Account
      IF px_line_record.ship_from_cust_account_id(i) IS NULL THEN
         px_line_record.ship_from_cust_account_id(i) := px_batch_record.partner_cust_account_id;

         IF px_line_record.ship_from_cust_account_id(i) IS NULL THEN
            IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
               px_line_record.status_code(i)       := 'DISPUTED';
               px_line_record.dispute_code(i)   := 'OZF_RESALE_SHIP_FROM_MISS';
            END IF;

            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        => 'IFACE',
                p_error_code     =>  'OZF_RESALE_SHIP_FROM_MISS',
                p_column_name    =>  'SHIP_FROM_CUST_ACCOUNT_ID',
                p_column_value   =>  NULL,
                x_return_status  =>  x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF;

      -- Ship From Site
      IF px_line_record.ship_from_site_id(i) IS NULL THEN
         px_line_record.ship_from_site_id(i) := px_batch_record.partner_site_id;
      END IF;

      --
      -- Direct Customer Flag Validations
      -- bill_to_         bill_to_  bill_to_
      -- cust_account_id  party_id  party_name  direct_customer_flag
      -- ---------------  --------  ----------  --------------------
      --       X             X          X              T
      --                     X          X              F
      --                                X              F
      --                                               F
      -----------------------------------------------------------------------
      IF px_line_record.direct_customer_flag(i) IS NULL THEN
         -- [BEGIN OF BUG 4391335 FIXING]
         IF px_line_record.bill_to_cust_account_id.exists(i) AND
            px_line_record.bill_to_cust_account_id(i) IS NOT NULL AND
            px_line_record.bill_to_party_name.exists(i) AND
            px_line_record.bill_to_party_name(i) IS NOT NULL THEN
            px_line_record.direct_customer_flag(i) := 'T';
         ELSE
            px_line_record.direct_customer_flag(i) := 'F';
         END IF;
         -- [END OF BUG 4391335 FIXING]
      END IF;

      --
      -- Bill to Customer Validations
      -----------------------------------------------------------------------
      IF px_line_record.direct_customer_flag(i) = 'T' THEN
         IF px_line_record.bill_to_cust_account_id.exists(i) AND
            px_line_record.bill_to_cust_account_id(i) IS NULL THEN
            IF px_line_record.status_code(i) <> 'DISPUTED' THEN
               px_line_record.status_code(i)     := 'DISPUTED';
               px_line_record.dispute_code(i) := 'OZF_BILL_TO_ACCT_NULL';
            END IF;

            Insert_Resale_Log(
               p_id_value        =>  px_line_record.resale_line_int_id(i),
               p_id_type         => 'IFACE',
               p_error_code      => 'OZF_BILL_TO_ACCT_NULL',
               p_column_name     => 'BILL_TO_CUST_ACCOUNT_ID',
               p_column_value    =>  NULL,
               x_return_status   =>  x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;   --  px_line_record.bill_to_cust_account_id(i)
      ELSIF px_line_record.direct_customer_flag(i) = 'F' THEN
         IF px_batch_record.batch_type = 'CHARGEBACK' OR
            px_batch_record.batch_type = 'TRACING' OR
            px_batch_record.batch_type = 'TP_ACCRUAL' THEN
            IF px_line_record.bill_to_party_name.EXISTS(i) AND
               px_line_record.bill_to_party_name(i) IS NULL THEN
               IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
                  px_line_record.status_code(i)     := 'DISPUTED';
                  px_line_record.dispute_code(i) := 'OZF_BILL_TO_PARTY_NAME_NULL';
               END IF;

               Insert_Resale_Log (
                  p_id_value        =>  px_line_record.resale_line_int_id(i),
                  p_id_type         => 'IFACE',
                  p_error_code      => 'OZF_BILL_TO_PARTY_NAME_NULL',
                  p_column_name     => 'BILL_TO_PARTY_NAME',
                  p_column_value    =>  NULL,
                  x_return_status   =>  x_return_status
               );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;   --  px_line_record.bill_to_cust_account_id(i)
         END IF;
      END IF;

      --
      -- Product Transfer Movement Type Validations
      -----------------------------------------------------------------------
      IF px_line_record.product_transfer_movement_type(i) IS NULL THEN
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i)    := 'DISPUTED';
            px_line_record.dispute_code(i)   := 'OZF_MOVEMENT_TYPE_NULL';
         END IF;

         Insert_Resale_Log (
          p_id_value       =>  px_line_record.resale_line_int_id(i),
          p_id_type        => 'IFACE',
          p_error_code     => 'OZF_MOVEMENT_TYPE_NULL',
          p_column_name    => 'PRODUCT_TRANSFER_MOVEMENT_TYPE',
          p_column_value   =>  NULL,
          x_return_status   =>  x_return_status
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- Order Number Validations
      -----------------------------------------------------------------------
      IF px_line_record.order_number(i) IS NULL THEN
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i) := 'DISPUTED';
            px_line_record.dispute_code(i) := 'OZF_RESALE_ORD_NUM_MISS';
         END IF;

         Insert_Resale_Log (
          p_id_value       => px_line_record.resale_line_int_id(i),
          p_id_type        => 'IFACE',
          p_error_code     => 'OZF_RESALE_ORD_NUM_MISS',
          p_column_name    => 'ORDER_NUMBER',
          p_column_value   =>  NULL,
          x_return_status  =>  x_return_status
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- Resale_Transfer_Type Validations
      -- 'BN': Return
      -- 'SD': Ship Debit Sale
      -- 'SS': Stock Sale
      -- 'IB': Inter Branch
      -----------------------------------------------------------------------
      IF ( px_line_record.resale_transfer_type(i) NOT IN ( 'BN', 'SD', 'SS', 'IB') )
         -- BUG 4558568 (+)
         OR
         ( px_line_record.resale_transfer_type(i) = 'BN' AND
           SIGN(px_line_record.quantity(i)) = 1 )
         OR
         ( px_line_record.resale_transfer_type(i) = 'SD' AND
           SIGN(px_line_record.quantity(i)) = -1 ) THEN
         -- BUG 4558568 (-)
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i)       := 'DISPUTED';
            px_line_record.dispute_code(i)   := 'OZF_RESALE_WRNG_TRANSFER_TYPE';
         END IF;

         Insert_Resale_Log(
             p_id_value       =>  px_line_record.resale_line_int_id(i),
             p_id_type        => 'IFACE',
             p_error_code     => 'OZF_RESALE_WRNG_TRANSFER_TYPE',
             p_column_name    => 'RESALE_TRANSFER_TYPE',
             p_column_value   =>  px_line_record.resale_transfer_type(i),
             x_return_status   =>  x_return_status
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- Order Category Validations
      -----------------------------------------------------------------------
      IF px_line_record.order_category(i) NOT IN ('ORDER', 'RETURN' ) THEN
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i) := 'DISPUTED';
            px_line_record.dispute_code(i) := 'OZF_RESALE_WRNG_ORD_CGRY';
         END IF;

         Insert_Resale_Log (
             p_id_value       =>  px_line_record.resale_line_int_id(i),
             p_id_type        => 'IFACE',
             p_error_code     => 'OZF_RESALE_WRNG_ORD_CGRY',
             p_column_name    => 'ORDER_CATEGORY',
             p_column_value   =>  px_line_record.order_category(i),
             x_return_status  =>  x_return_status
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- Date Ordered Validations
      -----------------------------------------------------------------------
      IF px_line_record.date_ordered(i) IS NULL THEN
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i) := 'DISPUTED';
            px_line_record.dispute_code(i) := 'OZF_RESALE_ORD_DATE_MISS';
         END IF;

         l_dispute_code := 'OZF_RESALE_ORD_DATE_MISS';
         l_column_name  := 'DATE_ORDERED';
         l_column_value := NULL;
      ELSIF px_line_record.date_ordered(i) < px_batch_record.report_start_date THEN
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i) := 'DISPUTED';
            px_line_record.dispute_code(i) := 'OZF_ORD_DATE_LT_START';
         END IF;
         l_dispute_code := 'OZF_ORD_DATE_LT_START';
         l_column_name  := 'DATE_ORDERED';
         l_column_value := px_line_record.date_ordered(i);
      ELSIF px_line_record.date_ordered(i) > px_batch_record.report_end_date THEN
         IF px_line_record.status_code(i) <> 'DISPUTED'  THEN
            px_line_record.status_code(i) := 'DISPUTED';
            px_line_record.dispute_code(i) := 'OZF_ORD_DATE_GT_END';
         END IF;
         l_dispute_code := 'OZF_ORD_DATE_GT_END';
         l_column_name  := 'DATE_ORDERED';
         l_column_value := px_line_record.date_ordered(i);
      --
      -- Order Type Valication
      -----------------------------------------------------------------------
      ELSE
         IF px_line_record.order_type_id(i) IS NULL THEN
            IF px_line_record.order_type(i) IS NOT NULL THEN
               OPEN  get_order_type_id(px_line_record.date_ordered(i)
                                      ,px_line_record.order_type(i));
               FETCH get_order_type_id INTO px_line_record.order_type_id(i);
               CLOSE get_order_type_id;
            END IF; -- px_line_record.order_type(i)
         ELSE
            OPEN  chk_order_type (px_line_record.order_type(i)
                                 ,px_line_record.order_type_id(i));
            FETCH chk_order_type INTO x;
            CLOSE chk_order_type;

            IF x IS NULL THEN
               l_dispute_code :=  'OZF_WRNG_ORDER_TYPE';
               IF px_line_record.order_type(i) IS NOT NULL THEN
                  l_column_name  := 'ORDER_TYPE';
                  l_column_value := px_line_record.order_type(i);
               ELSE
                  l_column_name  := 'ORDER_TYPE_ID';
                  l_column_value := px_line_record.order_type_id(i);
               END IF;
            END IF;
         END IF; -- px_line_record.order_type_id(i)
      END IF;  -- px_line_record.date_ordered

      IF l_dispute_code IS NOT NULL THEN
         Insert_Resale_Log(
             p_id_value       =>  px_line_record.resale_line_int_id(i),
             p_id_type        => 'IFACE',
             p_error_code     =>  l_dispute_code,
             p_column_name    =>  l_column_name,
             p_column_value   =>  l_column_value,
             x_return_status   => x_return_status
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      --
      -- Derive Purchase Price from OM sales transactions
      -----------------------------------------------------------------------
      IF px_line_record.purchase_price(i) IS NULL THEN
         OZF_SALES_TRANSACTIONS_PVT.Get_Purchase_Price(
             p_api_version                 => 1.0
            ,p_init_msg_list               => FND_API.G_FALSE
            ,p_validation_level            => FND_API.G_VALID_LEVEL_FULL
            ,p_order_date                  => px_line_record.date_ordered(i)
            ,p_sold_from_cust_account_id   => px_line_record.sold_from_cust_account_id(i)
            ,p_sold_from_site_id           => px_line_record.sold_from_site_id(i)
            ,p_inventory_item_id           => px_line_record.inventory_item_id(i)
            ,p_uom_code                    => px_line_record.uom_code(i)
            ,p_quantity                    => px_line_record.quantity(i)
            ,p_currency_code               => px_line_record.currency_code(i)
            ,p_x_purchase_uom_code         => px_line_record.purchase_uom_code(i)
            ,x_purchase_price              => px_line_record.purchase_price(i)
            ,x_return_status               => x_return_status
            ,x_msg_count                   => l_msg_count
            ,x_msg_data                    => l_msg_data
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF px_line_record.purchase_price(i) IS NULL THEN
            px_line_record.purchase_price(i) := px_line_record.orig_system_purchase_price(i);
         END IF;

         OPEN get_functional_currency;
         FETCH get_functional_currency INTO l_functional_currency;
         CLOSE get_functional_currency;

         IF px_line_record.purchase_price(i) IS NOT NULL THEN
            IF l_functional_currency <> px_line_record.currency_code(i) THEN
               IF px_line_record.exchange_rate(i) IS NULL THEN
                  IF px_line_record.exchange_rate_type(i) IS NULL THEN
                     OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                     FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO px_line_record.exchange_rate_type(i);
                     CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                  END IF;
                  OZF_UTILITY_PVT.Convert_Currency(
                      p_from_currency   => px_line_record.currency_code(i)
                     ,p_to_currency    => l_functional_currency
                     ,p_conv_type      => px_line_record.exchange_rate_type(i)
                     ,p_conv_rate      => px_line_record.exchange_rate(i)
                     ,p_conv_date      => px_line_record.exchange_rate_date(i)
                     ,p_from_amount    => px_line_record.purchase_price(i)
                     ,x_return_status  => x_return_status
                     ,x_to_amount      => l_new_converted_amount
                     ,x_rate           => l_exchange_rate
                  );
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                  px_line_record.acctd_purchase_price(i) := l_new_converted_amount;
               ELSE
                  px_line_record.acctd_purchase_price(i)
                      := OZF_UTILITY_PVT.CurrRound(px_line_record.purchase_price(i)*px_line_record.exchange_rate(i), l_functional_currency);
               END IF;  --   px_line_record.exchange_rate(i) IS NULL
            ELSE
               px_line_record.acctd_purchase_price(i) := px_line_record.purchase_price(i);
            END IF; -- l_functional_currency <>  px_line_record.currency_code(i)
         END IF;
      END IF;

      --
      -- Derive purchase_uom / selling_uom / UOM
      -----------------------------------------------------------------------
      IF px_line_record.purchase_uom_code(i) IS NULL THEN
         IF px_line_record.uom_code(i) IS NOT NULL THEN
            px_line_record.purchase_uom_code(i) := px_line_record.uom_code(i);
         END IF;
      END IF;

      --
      -- Derive claim amount
      -----------------------------------------------------------------------
      IF px_line_record.claimed_amount(i) IS NULL THEN
         IF px_line_record.total_claimed_amount(i) IS NOT NULL THEN
            -- Bug fixing: return orders for chargeback 4700019(+)
            --px_line_record.claimed_amount(i) :=  px_line_record.total_claimed_amount(i)/px_line_record.quantity(i);
            px_line_record.claimed_amount(i) :=  px_line_record.total_claimed_amount(i)/ABS(px_line_record.quantity(i));
            -- Bug fixing: return orders for chargeback 4700019(-)

         ELSIF px_line_record.selling_price(i) IS NOT NULL AND
               px_line_record.purchase_price(i) IS NOT NULL THEN
            px_line_record.claimed_amount(i) := px_line_record.purchase_price(i)
                                              - px_line_record.selling_price(i);
            IF SIGN(px_line_record.quantity(i)) = -1 THEN
               px_line_record.claimed_amount(i) := px_line_record.claimed_amount(i)*-1;
            END IF;
         END IF;
      END IF; -- px_line_record.claimed_amount(i)

      IF px_line_record.claimed_amount(i) IS NOT NULL THEN
         -- Bug fixing: return orders for chargeback 4700019(+)
         --px_line_record.total_claimed_amount(i) := px_line_record.claimed_amount(i)*px_line_record.quantity(i);
         --px_line_record.total_claimed_amount(i) := px_line_record.claimed_amount(i)*ABS(px_line_record.quantity(i));
         -- Bug fixing: return orders for chargeback 4700019(-)
           -- bug 5969118 Ship and Debit return order generates positive claim amount
         IF px_line_record.resale_transfer_type(i) = 'BN' THEN
           px_line_record.total_claimed_amount(i) := ABS(px_line_record.claimed_amount(i) * px_line_record.quantity(i)) * -1;
         ELSE
           px_line_record.total_claimed_amount(i) := px_line_record.claimed_amount(i)*ABS(px_line_record.quantity(i));
         END IF;
         -- bug 5969118 end
      END IF;

      --
      -- Derive Item Number
      -----------------------------------------------------------------------
      IF px_line_record.inventory_item_id(i) IS NOT NULL AND
         px_line_record.item_number(i) IS NULL THEN
         -- Bug 4520881 (+)
         l_org_id := G_ITEM_ORG_ID; --FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');
         -- SELECT NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99)
         -- INTO l_org_id  FROM DUAL;
         -- Bug 4520881 (-)
         OPEN get_item_number( px_line_record.inventory_item_id(i)
                             , l_org_id);
         FETCH  get_item_number INTO   px_line_record.item_number(i);
         CLOSE  get_item_number;
      END IF;

      -- BUG 4938403 (+)
      -- Item/Order Date/UOM/Quantity Validation for Inventory Tracking
      -----------------------------------------------------------------------
      IF g_inventory_tracking_flag = 'T' THEN
         l_dispute_code := NULL;
         IF px_line_record.inventory_item_id(i) IS NULL THEN
            l_dispute_code :=  'OZF_IDSM_INV_ITEM_REQ';
            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        =>  'IFACE',
                p_error_code     =>  'OZF_IDSM_INV_ITEM_REQ',
                p_column_name    =>  'INVENTORY_ITEM_ID',
                p_column_value   =>  NULL,
                x_return_status   => x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF px_line_record.date_ordered(i) IS NULL THEN
            l_dispute_code :=  'OZF_IDSM_INV_ORDER_DATE_REQ';
            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        =>  'IFACE',
                p_error_code     =>  'OZF_IDSM_INV_ORDER_DATE_REQ',
                p_column_name    =>  'DATE_ORDERED',
                p_column_value   =>  NULL,
                x_return_status   => x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF px_line_record.uom_code(i) IS NULL THEN
            l_dispute_code :=  'OZF_IDSM_INV_UOM_REQ';
            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        =>  'IFACE',
                p_error_code     =>  'OZF_IDSM_INV_UOM_REQ',
                p_column_name    =>  'UOM_CODE',
                p_column_value   =>  NULL,
                x_return_status   => x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF px_line_record.quantity(i) IS NULL THEN
            l_dispute_code :=  'OZF_IDSM_INV_QTY_REQ';
            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        =>  'IFACE',
                p_error_code     =>  'OZF_IDSM_INV_QTY_REQ',
                p_column_name    =>  'QUANTITY',
                p_column_value   =>  NULL,
                x_return_status   => x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;

         IF l_dispute_code IS NOT NULL THEN
            IF px_line_record.status_code(i) <> 'DISPUTED' THEN
               px_line_record.status_code(i) := 'DISPUTED';
               px_line_record.dispute_code(i) := 'OZF_SALES_TRANS_MISS';
            END IF;
         END IF;
      END IF;
      -- BUG 4938403 (-)

      -- BUG 5153273 (+)
      -- Agreement Operating Unit Validation
      -----------------------------------------------------------------------
      IF px_line_record.agreement_id(i) IS NOT NULL AND
         px_line_record.agreement_type(i) IS NOT NULL THEN
         l_agreement_org_id := NULL;

         IF px_line_record.agreement_type(i) = 'PL' THEN
            OPEN price_list_org(px_line_record.agreement_id(i));
            FETCH price_list_org INTO l_agreement_org_id;
            CLOSE price_list_org;
         ELSIF px_line_record.agreement_type(i) = 'SPO' THEN
            OPEN spr_org(px_line_record.agreement_id(i));
            FETCH spr_org INTO l_agreement_org_id;
            CLOSE spr_org;
         END IF;

         IF l_agreement_org_id IS NOT NULL AND
            l_agreement_org_id <> px_line_record.org_id(i) THEN
            l_dispute_code :=  'OZF_AGRM_MISMATCH_OU';
            Insert_Resale_Log(
                p_id_value       =>  px_line_record.resale_line_int_id(i),
                p_id_type        =>  'IFACE',
                p_error_code     =>  'OZF_IDSM_AGRM_MISMATCH_OU',
                p_column_name    =>  'AGREEMENT_NAME',
                p_column_value   =>  NULL,
                x_return_status  => x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END IF;
      -- BUG 5153273 (-)

      IF px_line_record.status_code(i) = 'DISPUTED' THEN
         px_line_record.response_code(i) := 'N';
      ELSIF px_line_record.status_code(i) = 'OPEN' THEN
         px_line_record.response_code(i) := 'Y';
      END IF;

   END LOOP;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Line_Validations;


PROCEDURE End_Cust_Party_Mapping
(
  p_party_id               IN     NUMBER,
  p_cust_account_id        IN     NUMBER,
  p_party_name_tbl         IN OUT NOCOPY VARCHAR2_TABLE,
  p_location_tbl           IN OUT NOCOPY VARCHAR2_TABLE,
  px_site_use_code_tbl     IN OUT NOCOPY VARCHAR2_TABLE,
  px_site_use_id_tbl       IN OUT NOCOPY NUMBER_TABLE,
  px_party_id_tbl          IN OUT NOCOPY NUMBER_TABLE,
  px_party_site_id_tbl     IN OUT NOCOPY NUMBER_TABLE,
  x_return_status          OUT NOCOPY VARCHAR2
)
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'End_Cust_Party_Mapping';
   l_api_version_number     CONSTANT NUMBER   := 1.0;

   l_mapping_flag           VARCHAR2(1);
   l_site_mapping_flag      VARCHAR2(1);

   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

   l_party_tbl              VARCHAR2_TABLE;
   l_party_site_tbl         VARCHAR2_TABLE;

   l_party_id               NUMBER;
   l_cust_account_id        NUMBER;

   CURSOR get_account_id (pc_party_Id NUMBER)
   IS
   SELECT   cust.cust_account_id
     FROM   hz_cust_accounts  cust
    WHERE   cust.party_id = pc_party_Id;

   CURSOR get_site_use_id ( pc_cust_account_id NUMBER
                          , pc_site_use    VARCHAR2 )
   IS
   SELECT   hcsu.site_use_id
     FROM   hz_cust_acct_sites hcs --hz_cust_acct_sites_all  hcs
        ,   hz_cust_site_uses  hcsu --,   hz_cust_site_uses_all  hcsu
    WHERE   hcsu.cust_acct_site_id = hcs.cust_acct_site_id
      AND   hcs.cust_account_id    = pc_cust_account_id
      AND   hcsu.site_use_code     = pc_site_use
      AND   hcsu.primary_flag= 'Y'
      AND   hcsu.status = 'A';

CURSOR get_party_acc_id (cv_party_site_id IN NUMBER) IS
   SELECT   hp.party_id , hc.cust_account_id
     FROM   hz_party_sites hps
        ,   hz_parties hp
        ,   hz_cust_accounts hc
    WHERE   hps.party_id           = hp.party_id
      AND   hp.party_id            = hc.party_id (+)
      AND   hps.party_site_id      = cv_party_site_id;


BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

--  Party Site Code Conversions
    IF  px_site_use_id_tbl.COUNT > 0 THEN

       FOR i IN 1 ..  px_site_use_id_tbl.COUNT
       LOOP
          IF  px_site_use_id_tbl(i) IS NOT NULL THEN
             l_site_mapping_flag := 'N';
             --exit;
          ELSE
             IF  px_party_site_id_tbl(i) IS NOT NULL THEN
                 l_site_mapping_flag := 'N';
                 --exit;
             ELSIF  p_location_tbl(i) IS NOT NULL THEN
                 l_site_mapping_flag := 'Y';
                 exit;
             END IF;
          END IF;
       END LOOP;
    END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Mapping Flag ' || l_mapping_flag);
   END IF;

    IF  l_site_mapping_flag = 'Y' AND p_location_tbl.COUNT > 0 THEN

        code_conversion
       (
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_PARTY_SITE_CODES',
         p_external_code_tbl     => p_location_tbl,
         x_internal_code_tbl     => l_party_site_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => l_msg_count ,
         x_msg_data              => l_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF  l_party_site_tbl.COUNT  > 0 THEN
           FOR i IN 1 .. l_party_site_tbl.COUNT
           LOOP
              IF l_party_site_tbl.exists(i) AND l_party_site_tbl(i) IS NOT NULL THEN
                 px_party_site_id_tbl(i) := to_number(l_party_site_tbl(i));

                 OPEN get_party_acc_id(px_party_site_id_tbl(i));
                 FETCH get_party_acc_id INTO l_party_id, l_cust_account_id;
                 CLOSE get_party_acc_id;

                 IF px_party_id_tbl(i) IS NULL THEN
                    px_party_id_tbl(i)        :=  l_party_id;
                 END IF;

                 IF l_cust_account_id IS NOT NULL THEN
                    OPEN get_site_use_id ( l_cust_account_id, 'BILL_TO');
                    FETCH get_site_use_id INTO px_site_use_id_tbl(i);
                    CLOSE get_site_use_id;
                 END IF;
              END IF;
           END LOOP;
       END IF;
     END IF;   -- l_site_mapping_flag = 'Y'

--  Party Code Conversions
    IF  px_party_id_tbl.COUNT > 0 THEN

       FOR i IN 1 ..  px_party_id_tbl.COUNT
       LOOP
          IF  px_party_site_id_tbl(i) IS NOT NULL THEN
             l_mapping_flag := 'N';
             --exit;
          ELSE
             IF  px_party_id_tbl(i) IS NOT NULL THEN
                 l_mapping_flag := 'N';
                 --exit;
             ELSIF  p_party_name_tbl(i) IS NOT NULL THEN
                 l_mapping_flag := 'Y';
                 exit;
             END IF;
          END IF;
       END LOOP;
    END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Mapping Flag ' || l_mapping_flag);
   END IF;

    IF  l_mapping_flag = 'Y' AND p_party_name_tbl.COUNT > 0 THEN

        code_conversion
       (
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_PARTY_CODES',
         p_external_code_tbl     => p_party_name_tbl,
         x_internal_code_tbl     => l_party_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => l_msg_count ,
         x_msg_data              => l_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF l_party_tbl.COUNT > 0 THEN
          FOR  i IN 1 .. l_party_tbl.COUNT
          LOOP
             IF l_party_tbl.EXISTS(i) AND l_party_tbl(i) IS NOT NULL THEN
               px_party_id_tbl(i)  := to_number(l_party_tbl(i));
               /*
               OPEN  get_account_id ( px_party_id_tbl(i)) ;
               FETCH get_account_id INTO px_cust_account_id_tbl(i);
               CLOSE get_account_id;
               */
            END IF;
         END LOOP;
       END IF;
    END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END End_Cust_Party_Mapping;


PROCEDURE Code_ID_Mapping
(
  p_batch_record  IN  ozf_resale_batches_all%ROWTYPE,
  px_line_record  IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_data      OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER
)
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Code_ID_Mapping';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
    Agreement_Default
   (
     p_party_id               => p_batch_record.partner_party_id,
     p_cust_account_id        => p_batch_record.partner_cust_account_id,
     p_batch_type             => p_batch_record.batch_type,
     p_interface_line_id_tbl  => px_line_record.resale_line_int_id,
     p_ext_agreement_name     => px_line_record.orig_system_agreement_name,
     p_ext_agreement_type     => px_line_record.orig_system_agreement_type,
     px_int_agreement_name    => px_line_record.agreement_name,
     px_int_agreement_type    => px_line_record.agreement_type,
     px_agreement_id          => px_line_record.agreement_id,
     px_corrected_agreement_id => px_line_record.corrected_agreement_id,
     px_corrected_agreement_name => px_line_record.corrected_agreement_name,
     px_status_tbl            => px_line_record.status_code,
     px_dispute_code_tbl      => px_line_record.dispute_code,
     p_resale_transfer_type   => px_line_record.resale_transfer_type,
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data,
     x_msg_count              => x_msg_count
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   Product_validations
   (
     p_party_id               => p_batch_record.partner_party_id,
     p_cust_account_id        => p_batch_record.partner_cust_account_id,
     p_interface_line_id_tbl  => px_line_record.resale_line_int_id,
     p_ext_item_number_tbl    => px_line_record.orig_system_item_number,
     p_item_number_tbl        => px_line_record.item_number,
     px_item_id_tbl           => px_line_record.inventory_item_id,
     px_status_tbl            => px_line_record.status_code,
     px_dispute_code_tbl      => px_line_record.dispute_code,
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data,
     x_msg_count              => x_msg_count
  );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  UOM_Code_Mapping
  (
     p_party_id               => p_batch_record.partner_party_id,
     p_cust_account_id        => p_batch_record.partner_cust_account_id,
     p_interface_line_id_tbl  => px_line_record.resale_line_int_id,
     p_ext_purchase_uom       => px_line_record.orig_system_purchase_uom,
     p_ext_uom                => px_line_record.orig_system_uom,
     p_ext_agreement_uom      => px_line_record.orig_system_agreement_uom,
     px_int_purchase_uom      => px_line_record.purchase_uom_code,
     px_int_uom               => px_line_record.uom_code,
     px_int_agreement_uom     => px_line_record.agreement_uom_code,
     px_status_tbl            => px_line_record.status_code,
     px_dispute_code_tbl      => px_line_record.dispute_code,
     x_return_status          => x_return_status,
     x_msg_data               => x_msg_data,
     x_msg_count              => x_msg_count
  );

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   Party_Mapping
   (
     p_party_id               => p_batch_record.partner_party_id,
     p_cust_account_id        => p_batch_record.partner_cust_account_id,
     p_party_type             => 'SHIP_TO',
     p_party_name_tbl         => px_line_record.ship_to_party_name,
     p_location_tbl           => px_line_record.ship_to_location,
     px_cust_account_id_tbl   => px_line_record.ship_to_cust_account_id,
     px_site_use_id_tbl       => px_line_record.ship_to_site_use_id,
     px_party_id_tbl          => px_line_record.ship_to_party_id,
     px_party_site_id_tbl     => px_line_record.ship_to_party_site_id,
     x_return_status          => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   Party_Mapping
   (
     p_party_id               => p_batch_record.partner_party_id,
     p_cust_account_id        => p_batch_record.partner_cust_account_id,
     p_party_type             => 'BILL_TO',
     p_party_name_tbl         => px_line_record.bill_to_party_name,
     p_location_tbl           => px_line_record.bill_to_location,
     px_cust_account_id_tbl    => px_line_record.bill_to_cust_account_id,
     px_site_use_id_tbl        => px_line_record.bill_to_site_use_id,
     px_party_id_tbl          => px_line_record.bill_to_party_id,
     px_party_site_id_tbl     => px_line_record.bill_to_party_site_id,
     x_return_status          => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Add code to derive bill_to based on ship_to jxwu

   -- Bug 4469837 (+)
   End_Cust_Party_Mapping(
     p_party_id               => p_batch_record.partner_party_id,
     p_cust_account_id        => p_batch_record.partner_cust_account_id,
     p_party_name_tbl         => px_line_record.end_cust_party_name,
     p_location_tbl           => px_line_record.end_cust_location,
     px_site_use_code_tbl     => px_line_record.end_cust_site_use_code,
     px_site_use_id_tbl       => px_line_record.end_cust_site_use_id,
     px_party_id_tbl          => px_line_record.end_cust_party_id,
     px_party_site_id_tbl     => px_line_record.end_cust_party_site_id,
     x_return_status          => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Bug 4469837 (-)


   -- end
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': End');
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
END Code_ID_Mapping;


PROCEDURE Line_Party_Validations
(
  p_line_count    IN  NUMBER,
  px_line_record  IN  OUT NOCOPY resale_line_int_rec_type,
  x_return_status OUT NOCOPY  VARCHAR2
)
IS
  l_api_name                  CONSTANT VARCHAR2(50) := 'Line_Party_Validations';
  l_api_version_number        CONSTANT NUMBER   := 1.0;

  l_party_site_id             NUMBER_TABLE;
  l_party_id                  NUMBER_TABLE;
  l_site_use_type             VARCHAR2_TABLE;
  l_null_flag                 VARCHAR2(1);


BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ----------------------------------------------------------
   -- SHIP_FROM Customer
   -- ----------------------------------------------------------
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ SHIP FROM Customer ++++++++++++++ (+)');
   END IF;
   Party_Validations
   (  p_resale_line_int_id      => px_line_record.resale_line_int_id
   ,  p_location                => px_line_record.ship_from_location
   ,  p_address                 => px_line_record.ship_from_address
   ,  p_city                    => px_line_record.ship_from_city
   ,  p_state                   => px_line_record.ship_from_state
   ,  p_postal_code             => px_line_record.ship_from_postal_code
   ,  p_country                 => px_line_record.ship_from_country
   ,  p_contact_name            => px_line_record.ship_from_contact_name
   ,  p_email                   => px_line_record.ship_from_email
   ,  p_fax                     => px_line_record.ship_from_fax
   ,  p_phone                   => px_line_record.ship_from_phone
   ,  p_site_use_type           => l_site_use_type
   ,  p_direct_customer_flag    => px_line_record.direct_customer_flag
   ,  p_party_type              => 'SHIP_FROM'
   ,  p_line_count              => p_line_count
   ,  px_party_name             => px_line_record.ship_from_party_name
   ,  px_cust_account_id        => px_line_record.ship_from_cust_account_id
   ,  px_site_use_id            => px_line_record.ship_from_site_id
   ,  px_party_id               => l_party_id
   ,  px_party_site_id          => l_party_site_id
   ,  px_contact_party_id       => px_line_record.ship_from_contact_party_id
   ,  px_status_code_tbl        => px_line_record.status_code
   ,  px_dispute_code_tbl       => px_line_record.dispute_code
   ,  x_return_status           => x_return_status
   );
   IF OZF_DEBUG_LOW_ON THEN
      FOR i IN 1..px_line_record.ship_from_cust_account_id.count LOOP
         ozf_utility_pvt.debug_message ('ship_from_cust_account_id ('||i||')'||px_line_record.ship_from_cust_account_id(i));
         ozf_utility_pvt.debug_message ('ship_from_site_id ('||i||')'||px_line_record.ship_from_site_id(i));
      END LOOP;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   l_party_site_id.delete;
   l_party_id.delete;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ SHIP FROM Customer ++++++++++++++ (-)');
   END IF;


   -- ----------------------------------------------------------
   -- SOLD_FROM Customer
   -- Derive from ship_from if null
   -- ----------------------------------------------------------
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ SOLD FROM Customer ++++++++++++++ (+)');
   END IF;
   l_null_flag := NULL;
   chk_party_record_null
   (  p_line_count             => p_line_count
   ,  p_party_type             => 'SOLD_FROM'
   ,  p_cust_account_id        => px_line_record.sold_from_cust_account_id
   ,  p_acct_site_id           => px_line_record.sold_from_site_id
   ,  p_party_id               => l_party_id
   ,  p_party_site_id          => l_party_site_id
   ,  p_location               => px_line_record.sold_from_location
   ,  p_party_name             => px_line_record.sold_from_party_name
   ,  x_null_flag              => l_null_flag
   ,  x_return_status          => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_null_flag = 'Y' THEN
      Derive_party
      ( p_resale_line_int_id      => px_line_record.resale_line_int_id
      , p_line_count              => p_line_count
      , p_party_type              => 'SOLD_FROM'
      , p_cust_account_id         => px_line_record.ship_from_cust_account_id
      , p_site_id                 => px_line_record.ship_from_site_id
      , x_cust_account_id         => px_line_record.sold_from_cust_account_id
      , x_site_id                 => px_line_record.sold_from_site_id
      , x_site_use_id             => l_party_site_id
      , x_party_id                => l_party_id
      , x_party_name              => px_line_record.sold_from_party_name
      , px_status_code_tbl        => px_line_record.status_code
      , px_dispute_code_tbl       => px_line_record.dispute_code
      , x_return_status           => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   ELSIF l_null_flag IS NULL OR l_null_flag = 'N' THEN
      Party_Validations
      (  p_resale_line_int_id      => px_line_record.resale_line_int_id
      ,  p_location                => px_line_record.sold_from_location
      ,  p_address                 => px_line_record.sold_from_address
      ,  p_city                    => px_line_record.sold_from_city
      ,  p_state                   => px_line_record.sold_from_state
      ,  p_postal_code             => px_line_record.sold_from_postal_code
      ,  p_country                 => px_line_record.sold_from_country
      ,  p_contact_name            => px_line_record.sold_from_contact_name
      ,  p_email                   => px_line_record.sold_from_email
      ,  p_fax                     => px_line_record.sold_from_fax
      ,  p_phone                   => px_line_record.sold_from_phone
      ,  p_site_use_type           => l_site_use_type
      ,  p_direct_customer_flag    => px_line_record.direct_customer_flag
      ,  p_party_type              => 'SOLD_FROM'
      ,  p_line_count              => p_line_count
      ,  px_party_name             => px_line_record.sold_from_party_name
      ,  px_cust_account_id        => px_line_record.sold_from_cust_account_id
      ,  px_site_use_id            => px_line_record.sold_from_site_id
      ,  px_party_id               => l_party_id
      ,  px_party_site_id          => l_party_site_id
      ,  px_contact_party_id       => px_line_record.sold_from_contact_party_id
      ,  px_status_code_tbl        => px_line_record.status_code
      ,  px_dispute_code_tbl       => px_line_record.dispute_code
      ,  x_return_status           => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      FOR i IN 1..px_line_record.sold_from_cust_account_id.count LOOP
         ozf_utility_pvt.debug_message ('sold_from_cust_account_id ('||i||')'||px_line_record.sold_from_cust_account_id(i));
         ozf_utility_pvt.debug_message ('sold_from_site_id ('||i||')'||px_line_record.sold_from_site_id(i));
      END LOOP;
   END IF;
   l_party_site_id.delete;
   l_party_id.delete;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ SOLD FROM Customer ++++++++++++++ (-)');
   END IF;


   -- ----------------------------------------------------------
   -- SHIP_TO Customer
   -- ----------------------------------------------------------
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ SHIP TO Customer ++++++++++++++ (+)');
   END IF;
   Party_Validations
   (   p_resale_line_int_id      => px_line_record.resale_line_int_id
   ,  p_location                => px_line_record.ship_to_location
   ,  p_address                 => px_line_record.ship_to_address
   ,  p_city                    => px_line_record.ship_to_city
   ,  p_state                   => px_line_record.ship_to_state
   ,  p_postal_code             => px_line_record.ship_to_postal_code
   ,  p_country                 => px_line_record.ship_to_country
   ,  p_contact_name            => px_line_record.ship_to_contact_name
   ,  p_email                   => px_line_record.ship_to_email
   ,  p_fax                     => px_line_record.ship_to_fax
   ,  p_phone                   => px_line_record.ship_to_phone
   ,  p_site_use_type           => l_site_use_type
   ,  p_direct_customer_flag    => px_line_record.direct_customer_flag
   ,  p_party_type              => 'SHIP_TO'
   ,  p_line_count              => p_line_count
   ,  px_party_name             => px_line_record.ship_to_party_name
   ,  px_cust_account_id        => px_line_record.ship_to_cust_account_id
   ,  px_site_use_id            => px_line_record.ship_to_site_use_id
   ,  px_party_id               => px_line_record.ship_to_party_id
   ,  px_party_site_id          => px_line_record.ship_to_party_site_id
   ,  px_contact_party_id       => px_line_record.ship_to_contact_party_id
   ,  px_status_code_tbl        => px_line_record.status_code
   ,  px_dispute_code_tbl       => px_line_record.dispute_code
   ,  x_return_status           => x_return_status
   );
   IF OZF_DEBUG_LOW_ON THEN
      FOR i IN 1..px_line_record.ship_to_cust_account_id.count LOOP
         ozf_utility_pvt.debug_message ('ship_to_cust_account_id ('||i||')'||px_line_record.ship_to_cust_account_id(i));
         ozf_utility_pvt.debug_message ('ship_to_site_use_id ('||i||')'||px_line_record.ship_to_site_use_id(i));
         ozf_utility_pvt.debug_message ('ship_to_party_id ('||i||')'||px_line_record.ship_to_party_id(i));
         ozf_utility_pvt.debug_message ('ship_to_party_site_id ('||i||')'||px_line_record.ship_to_party_site_id(i));
      END LOOP;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ SHIP TO Customer ++++++++++++++ (-)');
   END IF;

   -- ----------------------------------------------------------
   -- BILL_TO Customer
   -- Derive from ship_from if null
   -- ----------------------------------------------------------
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ BILL TO Customer ++++++++++++++ (+)');
   END IF;
   l_null_flag := NULL;
   chk_party_record_null
   (  p_line_count             => p_line_count
   ,  p_party_type             => 'BILL_TO'
   ,  p_cust_account_id        => px_line_record.bill_to_cust_account_id
   ,  p_acct_site_id           => px_line_record.bill_to_site_use_id
   ,  p_party_id               => px_line_record.bill_to_party_id
   ,  p_party_site_id          => px_line_record.bill_to_party_site_id
   ,  p_location               => px_line_record.bill_to_location
   ,  p_party_name             => px_line_record.bill_to_party_name
   ,  x_null_flag              => l_null_flag
   ,  x_return_status          => x_return_status
   );
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ('Null Flag '||l_null_flag);
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF  l_null_flag = 'Y' THEN
      Derive_Party
      (  p_resale_line_int_id      => px_line_record.resale_line_int_id
      , p_line_count              => p_line_count
      , p_party_type              => 'BILL_TO'
      , p_cust_account_id         => px_line_record.ship_to_cust_account_id
      , p_site_id                 => px_line_record.ship_to_site_use_id
      , x_cust_account_id         => px_line_record.bill_to_cust_account_id
      , x_site_id                 => px_line_record.bill_to_party_site_id
      , x_site_use_id             => px_line_record.bill_to_site_use_id
      , x_party_id                => px_line_record.bill_to_party_id
      , x_party_name              => px_line_record.bill_to_party_name
      , px_status_code_tbl        => px_line_record.status_code
      , px_dispute_code_tbl       => px_line_record.dispute_code
      , x_return_status           => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   ELSIF l_null_flag IS NULL OR l_null_flag = 'N' THEN
      Party_Validations
      (  p_resale_line_int_id      => px_line_record.resale_line_int_id
      ,  p_location                => px_line_record.bill_to_location
      ,  p_address                 => px_line_record.bill_to_address
      ,  p_city                    => px_line_record.bill_to_city
      ,  p_state                   => px_line_record.bill_to_state
      ,  p_postal_code             => px_line_record.bill_to_postal_code
      ,  p_country                 => px_line_record.bill_to_country
      ,  p_contact_name            => px_line_record.bill_to_contact_name
      ,  p_email                   => px_line_record.bill_to_email
      ,  p_fax                     => px_line_record.bill_to_fax
      ,  p_phone                   => px_line_record.bill_to_phone
      ,  p_site_use_type           => l_site_use_type
      ,  p_direct_customer_flag    => px_line_record.direct_customer_flag
      ,  p_party_type              => 'BILL_TO'
      ,  p_line_count              => p_line_count
      ,  px_party_name             => px_line_record.bill_to_party_name
      ,  px_cust_account_id        => px_line_record.bill_to_cust_account_id
      ,  px_site_use_id            => px_line_record.bill_to_site_use_id
      ,  px_party_id               => px_line_record.bill_to_party_id
      ,  px_party_site_id          => px_line_record.bill_to_party_site_id
      ,  px_contact_party_id       => px_line_record.bill_to_contact_party_id
      ,  px_status_code_tbl        => px_line_record.status_code
      ,  px_dispute_code_tbl       => px_line_record.dispute_code
      ,  x_return_status           => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      FOR i IN 1 ..  px_line_record.ship_to_cust_account_id.count
      LOOP
         ozf_utility_pvt.debug_message ('bill_to_cust_account_id ('||i||')'||px_line_record.bill_to_cust_account_id(i));
         ozf_utility_pvt.debug_message ('bill_to_site_use_id ('||i||')'||px_line_record.bill_to_site_use_id(i));
         ozf_utility_pvt.debug_message ('bill_to_party_id ('||i||')'||px_line_record.bill_to_party_id(i));
         ozf_utility_pvt.debug_message ('bill_to_party_site_id ('||i||')'||px_line_record.bill_to_party_site_id(i));
      END LOOP;
      ozf_utility_pvt.debug_message('++++++++++++++ BILL TO Customer ++++++++++++++ (-)');
   END IF;


   -- ----------------------------------------------------------
   -- END Customer
   -- ----------------------------------------------------------
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ END Customer ++++++++++++++ (+)');
   END IF;
   Party_Validations
   (  p_resale_line_int_id      => px_line_record.resale_line_int_id
   ,  p_location                => px_line_record.end_cust_location
   ,  p_address                 => px_line_record.end_cust_address
   ,  p_city                    => px_line_record.end_cust_city
   ,  p_state                   => px_line_record.end_cust_state
   ,  p_postal_code             => px_line_record.end_cust_postal_code
   ,  p_country                 => px_line_record.end_cust_country
   ,  p_contact_name            => px_line_record.end_cust_contact_name
   ,  p_email                   => px_line_record.end_cust_email
   ,  p_fax                     => px_line_record.end_cust_fax
   ,  p_phone                   => px_line_record.end_cust_phone
   ,  p_site_use_type           => px_line_record.end_cust_site_use_code
   ,  p_direct_customer_flag    => px_line_record.direct_customer_flag
   ,  p_party_type              => 'END_CUST'
   ,  p_line_count              => p_line_count
   ,  px_party_name             => px_line_record.end_cust_party_name
   ,  px_cust_account_id        => l_party_id
   ,  px_site_use_id            => px_line_record.end_cust_site_use_id
   ,  px_party_id               => px_line_record.end_cust_party_id
   ,  px_party_site_id          => px_line_record.end_cust_party_site_id
   ,  px_contact_party_id       => px_line_record.end_cust_contact_party_id
   ,  px_status_code_tbl        => px_line_record.status_code
   ,  px_dispute_code_tbl       => px_line_record.dispute_code
   ,  x_return_status           => x_return_status
   );
   IF OZF_DEBUG_LOW_ON THEN
      FOR i IN 1..px_line_record.ship_to_cust_account_id.count LOOP
         ozf_utility_pvt.debug_message ('end_cust_party_id ('||i||')'||px_line_record.end_cust_party_id(i));
         ozf_utility_pvt.debug_message ('end_cust_site_use_id ('||i||')'||px_line_record.end_cust_site_use_id(i));
         ozf_utility_pvt.debug_message ('bill_to_party_id ('||i||')'||px_line_record.bill_to_party_id(i));
      END LOOP;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('++++++++++++++ END Customer ++++++++++++++ (-)');
   END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Line_Party_Validations;



PROCEDURE Line_Currency_Price_Derivation
(
    p_line_count             IN  NUMBER,
    px_line_record           IN  OUT NOCOPY resale_line_int_rec_type,
    x_return_status          OUT NOCOPY  VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(50) := 'Line_Currency_Price_Derivation';
   l_api_version_number      CONSTANT NUMBER   := 1.0;

   l_mapping_flag            VARCHAR2(1);
   l_acctd_price_tbl         NUMBER_TABLE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Selling Price and Currency Derivation

   Currency_Price_Derivation(
     p_line_count          => p_line_count,
     p_conversion_type     => 'ORIG_SYSTEM',
     p_int_line_id_tbl     => px_line_record.resale_line_int_id,
     p_external_price_tbl  => px_line_record.orig_system_selling_price,
     p_conversion_date_tbl => px_line_record.exchange_rate_date,
     p_ext_currency_tbl    => px_line_record.orig_system_currency_code,
     px_internal_price_tbl => px_line_record.selling_price,
     px_currency_tbl       => px_line_record.currency_code,
     px_exchange_rate_tbl  => px_line_record.exchange_rate,
     px_rate_type_tbl      => px_line_record.exchange_rate_type,
     x_accounted_price_tbl => px_line_record.acctd_selling_price,
     px_status_tbl         => px_line_record.status_code,
     px_dispute_code_tbl   => px_line_record.dispute_code,
     x_return_status       => x_return_status
   );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Agreement Price and Currency Derivation
   Currency_Price_Derivation(
     p_line_count          => p_line_count,
     p_conversion_type     => 'AGREEMENT',
     p_int_line_id_tbl     => px_line_record.resale_line_int_id,
     p_external_price_tbl  => px_line_record.orig_system_agreement_price,
     p_conversion_date_tbl => px_line_record.exchange_rate_date,
     p_ext_currency_tbl    => px_line_record.orig_system_agreement_curr,
     px_internal_price_tbl => px_line_record.agreement_price,
     px_currency_tbl       => px_line_record.currency_code,
     px_exchange_rate_tbl  => px_line_record.exchange_rate,
     px_rate_type_tbl      => px_line_record.exchange_rate_type,
     x_accounted_price_tbl => l_acctd_price_tbl,
     px_status_tbl         => px_line_record.status_code,
     px_dispute_code_tbl   => px_line_record.dispute_code,
     x_return_status       => x_return_status
   );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Purchase Price and Currency Derivation
   Currency_Price_Derivation(
     p_line_count          => p_line_count,
     p_conversion_type     => 'PURCHASE',
     p_int_line_id_tbl     => px_line_record.resale_line_int_id,
     p_external_price_tbl  => px_line_record.orig_system_purchase_price,
     p_conversion_date_tbl => px_line_record.exchange_rate_date,
     p_ext_currency_tbl    => px_line_record.orig_system_purchase_curr,
     px_internal_price_tbl => px_line_record.purchase_price,
     px_currency_tbl       => px_line_record.currency_code,
     px_exchange_rate_tbl  => px_line_record.exchange_rate,
     px_rate_type_tbl      => px_line_record.exchange_rate_type,
     x_accounted_price_tbl => px_line_record.acctd_purchase_price,
     px_status_tbl         => px_line_record.status_code,
     px_dispute_code_tbl   => px_line_record.dispute_code,
     x_return_status       => x_return_status
   );
   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Line_Currency_Price_Derivation;

PROCEDURE Currency_Price_Derivation
(
  p_line_count          IN   NUMBER,
  p_conversion_type     IN   VARCHAR2,
  p_int_line_id_tbl     IN   NUMBER_TABLE,
  p_external_price_tbl  IN   NUMBER_TABLE,
  p_conversion_date_tbl IN   DATE_TABLE,
  p_ext_currency_tbl    IN   VARCHAR2_TABLE,
  px_internal_price_tbl IN OUT NOCOPY   NUMBER_TABLE,
  px_currency_tbl       IN OUT NOCOPY   VARCHAR2_TABLE,
  px_exchange_rate_tbl  IN OUT NOCOPY   NUMBER_TABLE,
  px_rate_type_tbl      IN OUT NOCOPY   VARCHAR2_TABLE,
  x_accounted_price_tbl OUT NOCOPY  NUMBER_TABLE,
  px_status_tbl         IN OUT NOCOPY   VARCHAR2_TABLE,
  px_dispute_code_tbl   IN OUT NOCOPY   VARCHAR2_TABLE,
  x_return_status       OUT NOCOPY VARCHAR2
)
IS


l_api_name                  CONSTANT VARCHAR2(30) := 'Currency_Price_Derivation';
l_api_version_number        CONSTANT NUMBER   := 1.0;

CURSOR get_functional_currency
IS
  SELECT gs.currency_code
  FROM gl_sets_of_books gs,
       ozf_sys_parameters osp
  WHERE gs.set_of_books_id = osp.set_of_books_id
  AND osp.org_id = MO_GLOBAL.get_current_org_id();


l_set_of_books_id           NUMBER;
l_sob_type_code             VARCHAR2(30);
l_functional_currency       VARCHAR2(15);

l_internal_currency         VARCHAR2(15);
l_internal_price            NUMBER;
l_exchange_rate_type        VARCHAR2(100);
l_exchange_rate             NUMBER;

CURSOR get_currency_code_csr(p_name in VARCHAR2) IS
SELECT currency_code
FROM fnd_currencies_vl
WHERE name = p_name;

l_converted_currency  VARCHAR2(15);
l_converted_amount    NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
      ozf_utility_pvt.debug_message('Line Count ' || p_line_count);
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN get_functional_currency;
   FETCH get_functional_currency INTO l_functional_currency;
   CLOSE get_functional_currency;

   FOR i IN 1 .. px_internal_price_tbl.COUNT LOOP

      -- This logic is OK since currency code is the only colum that will be populated.
      IF px_currency_tbl(i) IS NULL THEN
         IF p_ext_currency_tbl(i) IS NOT NULL THEN
            OPEN get_currency_code_csr(p_ext_currency_tbl(i));
            FETCH get_currency_code_csr INTO l_converted_currency;
            CLOSE get_currency_code_csr;
            px_currency_tbl(i) :=  l_converted_currency;
         ELSE
            px_currency_tbl(i) := G_BATCH_CURRENCY_CODE;
         END IF;
      END IF;

      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('Internal Price Tbl ('|| i ||') '|| px_internal_price_tbl(i));
         ozf_utility_pvt.debug_message('External Price Tbl ('|| i ||') '|| p_external_price_tbl(i));
      END IF;
      IF px_internal_price_tbl(i) IS NOT NULL THEN
         NULL;
      ELSIF p_external_price_tbl(i) IS NOT NULL  THEN
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('External Price Tbl ('|| i ||') '|| p_external_price_tbl(i));
            ozf_utility_pvt.debug_message('External Currency Tbl ('|| i ||') '|| p_ext_currency_tbl(i));
         END IF;
         IF p_conversion_type = 'ORIG_SYSTEM' THEN
            px_internal_price_tbl(i) := p_external_price_tbl(i);
         ELSE
            -- Don't understand why this has anything to do with invnetory tracking
            -- IF ( g_inventory_tracking_flag = 'F' AND p_conversion_type = 'PURCHASE' )
            -- OR p_conversion_type = 'AGREEMENT' THEN
               l_exchange_rate_type := NULL;
               l_exchange_rate      := NULL;
               l_converted_currency := NULL;
               -- convert the orig_system to internal code and then compare
               OPEN get_currency_code_csr(p_ext_currency_tbl(i));
               FETCH get_currency_code_csr INTO l_converted_currency;
               CLOSE get_currency_code_csr;

               IF l_converted_currency IS NULL OR
                  l_converted_currency = px_currency_tbl(i) THEN
                  px_internal_price_tbl(i) := p_external_price_tbl(i);
               ELSE
                  IF l_converted_currency <> px_currency_tbl(i) THEN
                     IF px_exchange_rate_tbl(i) IS NULL THEN
                        IF px_rate_type_tbl(i) IS NULL THEN
                           OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                           FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO px_rate_type_tbl(i);
                           CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                        END IF;

                        IF OZF_DEBUG_LOW_ON THEN
                           ozf_utility_pvt.debug_message('Exchange Rate Type ('|| i ||') '|| px_rate_type_tbl(i));
                           ozf_utility_pvt.debug_message('Calling convert currency');
                        END IF;

                        OZF_UTILITY_PVT.Convert_Currency(
                           p_from_currency   => l_converted_currency
                          ,p_to_currency     => px_currency_tbl(i)
                          ,p_conv_type       => px_rate_type_tbl(i)
                          ,p_conv_rate       => NULL
                          ,p_conv_date       => nvl(p_conversion_date_tbl(i),sysdate)
                          ,p_from_amount     => p_external_price_tbl(i)
                          ,x_return_status   => x_return_status
                          ,x_to_amount       => l_converted_amount
                          ,x_rate            => l_exchange_rate);

                        IF OZF_DEBUG_LOW_ON THEN
                           ozf_utility_pvt.debug_message('Exchange Rate Type ('|| i ||') '|| px_rate_type_tbl(i));
                        END IF;

                        IF x_return_status <> FND_API.g_ret_sts_success THEN
                           IF px_status_tbl(i) <> 'DISPUTED'  THEN
                              px_status_tbl(i)        := 'DISPUTED';
                              px_dispute_code_tbl(i)  := 'OZF_CURR_CONV_ERROR';
                           END IF;
                           insert_resale_log (
                              p_id_value          => p_int_line_id_tbl(i),
                              p_id_type           => 'IFACE',
                              p_error_code        => 'OZF_CURR_CONV_ERROR',
                              p_column_name       => 'CURRENCY_CODE',
                              p_column_value      => p_ext_currency_tbl(i),
                              x_return_status     =>  x_return_status
                           );
                           IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                              RAISE FND_API.G_EXC_ERROR;
                           ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                           END IF;
                        END IF;

                        IF l_exchange_rate IS NOT NULL THEN
                           px_exchange_rate_tbl(i) :=  l_exchange_rate;
                        END IF;
                        px_internal_price_tbl(i) := l_converted_amount;
                     ELSE
                        px_internal_price_tbl(i) := OZF_UTILITY_PVT.CurrRound(p_external_price_tbl(i)*px_exchange_rate_tbl(i), px_currency_tbl(i));
                     END IF; -- px_exchange_rate_tbl(i) IS NULL
                  ELSE
                     px_internal_price_tbl(i) :=p_external_price_tbl(i);
                  END IF; -- l_convert_currency = internal currency
               END IF; -- l_converted_currency IS NULL
            -- END IF;   -- g_inventory_tracking_flag
         END IF; -- p_conversion_type = 'ORIG_SYSTEM'
      END IF;  -- p_external_price_tbl(i)

      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('p_external_price_tbl ('||i||')'|| p_external_price_tbl(i));
         ozf_utility_pvt.debug_message('p_conversion_date_tbl ('||i||')'|| p_conversion_date_tbl(i));
         ozf_utility_pvt.debug_message('p_ext_currency_tbl ('||i||')'|| p_ext_currency_tbl(i));
         ozf_utility_pvt.debug_message('l_converted_concurrency:'|| l_converted_currency);
         ozf_utility_pvt.debug_message('px_currency_tbl ('||i||')'|| px_currency_tbl(i));
         ozf_utility_pvt.debug_message('px_rate_type_tbl ('||i||')'|| px_rate_type_tbl(i));
         ozf_utility_pvt.debug_message('px_internal_price_tbl ('||i||')'|| px_internal_price_tbl(i));
         ozf_utility_pvt.debug_message('px_exchange_rate_tbl ('||i||')'|| px_exchange_rate_tbl(i));
      END IF;

      --
      -- --------------------- Accounted Price Calculations -------------------------
      -- ----------------------------------------------------------------------------
      IF  px_internal_price_tbl.exists(i) AND px_internal_price_tbl(i) IS NOT NULL THEN
         IF   l_functional_currency <>  px_currency_tbl(i) THEN
            IF px_exchange_rate_tbl(i) IS NULL THEN
               IF  px_rate_type_tbl(i)  IS NULL THEN
                  OPEN OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
                  FETCH OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr INTO px_rate_type_tbl(i);
                  CLOSE OZF_RESALE_COMMON_PVT.g_exchange_rate_type_csr;
               END IF;
               OZF_UTILITY_PVT.Convert_Currency(
                  p_from_currency   => px_currency_tbl(i)
                 ,p_to_currency     => l_functional_currency
                 ,p_conv_type       => px_rate_type_tbl(i)
                 ,p_conv_rate       => px_exchange_rate_tbl(i)
                 ,p_conv_date       => nvl(p_conversion_date_tbl(i),sysdate)
                 ,p_from_amount     => px_internal_price_tbl(i)
                 ,x_return_status   => x_return_status
                 ,x_to_amount       => l_converted_amount
                 ,x_rate            => l_exchange_rate);
               IF x_return_status <> FND_API.g_ret_sts_success THEN
                  IF px_status_tbl(i) <> 'DISPUTED'  THEN
                     px_status_tbl(i)        := 'DISPUTED';
                     px_dispute_code_tbl(i)  := 'OZF_CURR_CONV_ERROR';
                  END IF;
                  insert_resale_log (
                     p_id_value          => p_int_line_id_tbl(i),
                     p_id_type           => 'IFACE',
                     p_error_code        => 'OZF_CURR_CONV_ERROR',
                     p_column_name       => 'CURRENCY_CODE',
                     p_column_value      => px_currency_tbl(i),
                     x_return_status     =>  x_return_status
                  );
                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;
               x_accounted_price_tbl(i) := l_converted_amount;
            ELSE
               x_accounted_price_tbl(i) := OZF_UTILITY_PVT.CurrRound(px_internal_price_tbl(i)*px_exchange_rate_tbl(i), l_functional_currency);
            END IF;
         ELSE
            x_accounted_price_tbl(i) := px_internal_price_tbl(i);
         END IF;
      ELSE
         x_accounted_price_tbl(i) := NULL;
      END IF;
   END LOOP;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Currency_Price_Derivation;


---------------------------------------------------------------------
-- PROCEDURE
--    Get_Agreement_Name
--
-- PURPOSE
-- This procedure derives the name of an agreement based on agreement id.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Agreement_Name
(
   p_type                IN VARCHAR2,
   p_agreement_id        IN NUMBER,
   x_agreement_name      OUT NOCOPY VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Get_Agreement_Name';
l_api_version_number        CONSTANT NUMBER   := 1.0;

CURSOR get_pl_agreement_name_csr(pc_agreement_id NUMBER)
IS
SELECT name
 FROM qp_list_headers_vl
WHERE list_header_id = pc_agreement_id
  AND list_type_code = 'PRL';

CURSOR get_spo_agreement_name_csr(pc_agreement_id NUMBER)
IS
SELECT agreement_number
 FROM ozf_request_headers_all_b
WHERE request_header_id = pc_agreement_id;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_agreement_name := NULL;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_api_name||': Start');
   END IF;

   -- ??? What to do if no name is found.
   IF p_type = 'PL' THEN
      OPEN get_pl_agreement_name_csr (p_agreement_id);
      FETCH get_pl_agreement_name_csr INTO x_agreement_name;
      CLOSE get_pl_agreement_name_csr;
   ELSIF p_type = 'SPO' THEN
      OPEN get_spo_agreement_name_csr (p_agreement_id);
      FETCH get_spo_agreement_name_csr INTO x_agreement_name;
      CLOSE get_spo_agreement_name_csr;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Get_Agreement_Name;


---------------------------------------------------------------------
-- PROCEDURE
--    Agreement_Default
--
-- PURPOSE
-- This procedure assigns values for agreement related columns. We are not
-- considering update from WEBADI at this point as most of the other columns.
-- We need to come up with a strategy to deal with this issue for all the columns.
-- Notice there is no way AGREEMENT_NAME exists without agreement_id.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Agreement_Default
(
   p_party_id               IN  NUMBER,
   p_cust_account_id        IN  NUMBER,
   p_batch_type             IN  VARCHAR2,
   p_interface_line_id_tbl  IN  NUMBER_TABLE,
   p_ext_agreement_name     IN  VARCHAR2_TABLE,
   p_ext_agreement_type     IN  VARCHAR2_TABLE,
   px_int_agreement_name    IN  OUT NOCOPY VARCHAR2_TABLE,
   px_int_agreement_type    IN  OUT NOCOPY  VARCHAR2_TABLE,
   px_agreement_id          IN  OUT NOCOPY NUMBER_TABLE,
   px_corrected_agreement_id IN OUT NOCOPY  NUMBER_TABLE,
   px_corrected_agreement_name IN OUT NOCOPY  VARCHAR2_TABLE,
   px_status_tbl            IN  OUT NOCOPY  VARCHAR2_TABLE,
   px_dispute_code_tbl      IN  OUT NOCOPY  VARCHAR2_TABLE,
   p_resale_transfer_type   IN  VARCHAR2_TABLE,
   x_return_status          OUT NOCOPY  VARCHAR2,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Agreement_Default';
l_api_version_number        CONSTANT NUMBER   := 1.0;

l_agreement_id_str  VARCHAR2(200);

CURSOR get_spo_agreement_csr (pc_agreement_name VARCHAR2)
IS
SELECT  request_header_id
 FROM  ozf_request_headers_all_b
WHERE  agreement_number =  pc_agreement_name;

/*

CURSOR chk_pl_agreement ( pc_agreement_id NUMBER )
IS
SELECT 'X'
 FROM qp_list_headers_vl
WHERE list_header_id = pc_agreement_id
  AND list_type_code = 'PRL';

CURSOR chk_spo_agreement ( pc_agreement_id NUMBER )
IS
SELECT 'X'
 FROM ozf_request_headers_all_b
WHERE request_header_id = pc_agreement_id;
*/

-- [BEGINN OF BUG FIXING: Agreement is null]
CURSOR get_pl_agreement_id(pc_agreement_name VARCHAR2)
IS
SELECT list_header_id
 FROM qp_list_headers_vl
WHERE name = pc_agreement_name
  AND list_type_code = 'PRL';
--*/
-- [END OF BUG FIXING: Agreement is null]

-- [BEGIN OF BUG 4237990 FIXING]
CURSOR get_spo_agreement_id(cv_agreement_name VARCHAR) IS
  SELECT a.request_header_id
  FROM  ozf_request_headers_all_b a
  , qp_list_headers_vl b
  WHERE a.offer_id = b.list_header_id
  AND a.status_code = 'APPROVED'
  AND b.name = cv_agreement_name;
-- [END OF BUG 4237990 FIXING]

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF px_int_agreement_type.COUNT > 0 AND
      px_int_agreement_type.EXISTS(1) THEN
      FOR i IN 1 .. px_int_agreement_type.COUNT LOOP
         IF px_int_agreement_type(i) IS NULL THEN
            IF p_ext_agreement_type(i) IS NULL AND
               ( px_int_agreement_name(i) IS NOT NULL OR
                 px_agreement_id(i) IS NOT NULL ) THEN
               IF p_batch_type = 'CHARGEBACK' THEN
                  px_int_agreement_type(i) :=  'PL';
               ELSIF  p_batch_type = 'SHIP_DEBIT' THEN
                  px_int_agreement_type(i) :=  'SPO';
               END IF;  -- p_batch_type
            ELSE
               px_int_agreement_type(i) := p_ext_agreement_type(i) ;
            END IF; -- p_ext_agreement_type(i)
         END IF; -- px_int_agreement_type(i) IS NULL

         IF px_int_agreement_type(i) IS NOT NULL AND
            px_int_agreement_type(i) NOT IN ( G_SPECIAL_PRICE, G_PRICE_LIST ) THEN
            IF px_status_tbl(i) <> 'DISPUTED'  THEN
               px_status_tbl(i)        := 'DISPUTED';
               px_dispute_code_tbl(i)  := 'OZF_INVALID_AGREEMENT_TYPE';
            END IF;
            Insert_Resale_Log(
               p_id_value          =>  p_interface_line_id_tbl(i),
               p_id_type           => 'IFACE',
               p_error_code        => 'OZF_INVALID_AGREEMENT_TYPE',
               p_column_name       => 'AGREEMENT_TYPE',
               p_column_value      =>  px_int_agreement_type(i),
               x_return_status     =>  x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         ELSIF px_int_agreement_type(i) = G_SPECIAL_PRICE THEN
            IF p_ext_agreement_name.EXISTS(i) AND
               p_ext_agreement_name(i) IS NOT NULL AND
               px_int_agreement_name(i) IS NULL THEN -- bug 5331553
               px_int_agreement_name(i):= p_ext_agreement_name(i);
            END IF;
         END IF; --  px_int_agreement_type(i) NOT IN

         IF px_corrected_agreement_id(i) IS NOT NULL THEN
            IF px_corrected_agreement_name(i) IS NOT NULL THEN
               NULL;
            ELSE
               -- popluate the px_int_agreement_name(i);
               Get_Agreement_Name(
                  p_type           => px_int_agreement_type(i),
                  p_agreement_id   => px_corrected_agreement_id(i),
                  x_agreement_name => px_corrected_agreement_name(i),
                  x_return_status  =>  x_return_status
               );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
         ELSE --px_corrected_agreement_id(i) is NULL

            IF px_agreement_id(i) IS NOT NULL THEN
               IF px_int_agreement_name(i) IS NOT NULL THEN
                  NULL;
               ELSE
                  -- popluate the px_int_agreement_name(i);
                  Get_Agreement_Name(
                     p_type           => px_int_agreement_type(i),
                     p_agreement_id   => px_agreement_id(i),
                     x_agreement_name => px_int_agreement_name(i),
                     x_return_status  =>  x_return_status
                  );
                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               END IF;
               -- assign values to corrected_agreement
               px_corrected_agreement_id(i) := px_agreement_id(i);
               px_corrected_agreement_name(i) := px_int_agreement_name(i);
            ELSE -- px_agreement_id(i) is NULL
               -- Where there is no internal agreement id,
               -- then we need to check the external agreement
               IF px_int_agreement_type(i) IS NOT NULL AND
                  px_int_agreement_name(i) IS NOT NULL THEN
                  IF px_int_agreement_type(i) = 'PL' THEN
                     OPEN get_pl_agreement_id(px_int_agreement_name(i));
                     FETCH get_pl_agreement_id INTO px_agreement_id(i);
                     CLOSE get_pl_agreement_id;
                  ELSIF px_int_agreement_type(i) = 'SPO' THEN
                     OPEN get_spo_agreement_id(px_int_agreement_name(i));
                     FETCH get_spo_agreement_id INTO px_agreement_id(i);
                     CLOSE get_spo_agreement_id;
                  END IF;
                  px_corrected_agreement_id(i) := px_agreement_id(i);
                  px_corrected_agreement_name(i) := px_int_agreement_name(i);
               END IF;

               IF px_int_agreement_name(i) IS NULL AND
                  px_corrected_agreement_id(i) IS NULL AND
                  px_corrected_agreement_name(i) IS NULL AND
                  p_ext_agreement_name(i) IS NOT NULL THEN
                  -- convert external code to internal code
                  -- get agreement_id based on agreement_type
                  IF px_int_agreement_type(i) = 'PL' THEN
                     OZF_CODE_CONVERSION_PVT.Convert_Code(
                          p_cust_account_id       => p_cust_account_id,
                          p_party_id              => p_party_id,
                          p_code_conversion_type  => 'OZF_AGREEMENT_CODES',
                          p_external_code         => p_ext_agreement_name(i),
                          x_internal_code         => l_agreement_id_str,
                          x_return_status         => x_return_status,
                          x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data
                     );
                     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                        RAISE FND_API.G_EXC_ERROR;
                     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                     px_agreement_id(i) := TO_NUMBER(l_agreement_id_str);
                  ELSIF px_int_agreement_type(i) = 'SPO' THEN
                     -- get id
                     OPEN get_spo_agreement_csr(p_ext_agreement_name(i));
                     FETCH get_spo_agreement_csr INTO px_agreement_id(i);
                     CLOSE get_spo_agreement_csr;
                     -- ????? What to do if no id is found.
                  END IF;
                  -- popluate the px_int_agreement_name(i) in both case
                  Get_Agreement_Name(
                     p_type           => px_int_agreement_type(i),
                     p_agreement_id   => px_agreement_id(i),
                     x_agreement_name => px_int_agreement_name(i),
                     x_return_status  => x_return_status
                  );
                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  px_corrected_agreement_id(i) := px_agreement_id(i);
                  px_corrected_agreement_name(i) := px_int_agreement_name(i);
               END IF;
            END IF;
         END IF;

         IF px_corrected_agreement_id(i) IS NULL THEN
           -- FINISAR mandatory agreement fix
           -- TRACING and SHIP_DEBIT/stock sale don't need agreement
           -- Third party accrual batch doesn't need agreement
           IF p_batch_type = 'TRACING' THEN
             NULL;
           ELSIF p_batch_type = 'SHIP_DEBIT' AND p_resale_transfer_type(i) = g_tsfr_stock_sale THEN
             NULL;
           ELSIF p_batch_type = 'SHIP_DEBIT' AND p_resale_transfer_type(i) = g_tsfr_return THEN
             NULL;
           ELSIF p_batch_type = 'TP_ACCRUAL' THEN
             NULL;
           ELSE
             IF px_status_tbl(i) <> 'DISPUTED'  THEN
               px_status_tbl(i)        := 'DISPUTED';
               px_dispute_code_tbl(i)  := 'OZF_AGREEMENT_MISS';
               Insert_Resale_Log(
                   p_id_value          =>  p_interface_line_id_tbl(i),
                   p_id_type           => 'IFACE',
                   p_error_code        => 'OZF_AGREEMENT_MISS',
                   p_column_name       => 'AGREEMENT_NAME',
                   p_column_value      =>  NULL,
                   x_return_status     =>  x_return_status
               );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
             END IF;
           END IF;
        END IF;

      END LOOP;
   END IF;  --   px_int_agreement_type.COUNT > 0
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END Agreement_Default;


PROCEDURE Product_validations
(
    p_party_id              IN  VARCHAR2,
    p_cust_account_id       IN  VARCHAR2,
    p_interface_line_id_tbl IN  NUMBER_TABLE,
    p_ext_item_number_tbl   IN  VARCHAR2_TABLE,
    p_item_number_tbl       IN  VARCHAR2_TABLE,
    px_item_id_tbl          IN  OUT NOCOPY NUMBER_TABLE,
    px_status_tbl           IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_dispute_code_tbl     IN  OUT NOCOPY  VARCHAR2_TABLE,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'product_validations';
l_api_version_number        CONSTANT NUMBER   := 1.0;

l_item_number_tbl           VARCHAR2_TABLE;
l_org_id                    NUMBER;
l_mapping_flag              VARCHAR2(1);
l_check_flag                VARCHAR2(1);

CURSOR get_inventory_item_id( pc_item_number IN VARCHAR2
                            , pc_org_id IN NUMBER
                            ) IS
  SELECT inventory_item_id
  FROM mtl_system_items_vl
  WHERE concatenated_segments = pc_item_number
  AND organization_id = pc_org_id;

CURSOR chk_inventory_item_id (pc_item_id IN NUMBER) IS
  SELECT 'X'
  FROM mtl_system_items
  WHERE inventory_item_id = pc_item_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF px_item_id_tbl.COUNT > 0 THEN
      FOR i IN 1 ..  px_item_id_tbl.COUNT LOOP
         IF p_ext_item_number_tbl(i) IS NOT NULL AND
            p_item_number_tbl(i) IS NULL THEN -- bug 5331553
            l_mapping_flag := 'Y';
            EXIT;
         ELSE
            IF px_item_id_tbl(i) IS NOT NULL THEN
               l_mapping_flag := 'N';
               --exit;
            ELSIF p_item_number_tbl(i) IS NOT NULL THEN
               l_mapping_flag := 'N';
               --exit;
            END IF;
         END IF;
      END LOOP;
   END IF;

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Mapping Flag ' || l_mapping_flag);
   END IF;

   IF l_mapping_flag = 'Y' AND
      p_ext_item_number_tbl.COUNT > 0 THEN
      Code_Conversion(
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_PRODUCT_CODES',
         p_external_code_tbl     => p_ext_item_number_tbl,
         x_internal_code_tbl     => l_item_number_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;

   IF p_item_number_tbl.COUNT > 0 THEN
      FOR i IN 1..p_item_number_tbl.COUNT LOOP
         IF p_item_number_tbl(i) IS NOT NULL THEN
            l_org_id := G_ITEM_ORG_ID; --FND_PROFILE.value('AMS_ITEM_ORGANIZATION_ID');
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_pvt.debug_message('p_item_number_tbl(i) ' || p_item_number_tbl(i));
            END IF;
            OPEN   get_inventory_item_id(p_item_number_tbl(i),
                                         l_org_id);
            FETCH  get_inventory_item_id INTO px_item_id_tbl(i);
            CLOSE  get_inventory_item_id;
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_pvt.debug_message('px_item_id_tbl(i) ' || px_item_id_tbl(i));
            END IF;

         ELSIF px_item_id_tbl(i) IS NOT NULL  THEN
            OPEN   chk_inventory_item_id( px_item_id_tbl(i));
            FETCH  chk_inventory_item_id INTO  l_check_flag;
            CLOSE  chk_inventory_item_id;

            IF l_check_flag IS NULL THEN
               IF px_status_tbl(i) <> 'DISPUTED'  THEN
                  px_status_tbl(i)         := 'DISPUTED';
                  px_dispute_code_tbl(i)   := 'OZF_RESALE_PRODUCT_NOT_IN_DB';
               END IF;
               Insert_Resale_Log(
                    p_id_value        =>  p_interface_line_id_tbl(i),
                    p_id_type         => 'IFACE',
                    p_error_code      => 'OZF_RESALE_PRODUCT_NOT_IN_DB',
                    p_column_name     => 'INVENTORY_ITEM_ID',
                    p_column_value    =>  p_ext_item_number_tbl(i),
                    x_return_status   =>  x_return_status
               );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;  -- l_check_flag IS NULL

         ELSIF l_mapping_flag = 'Y' THEN
            IF l_item_number_tbl.EXISTS(i) AND
               l_item_number_tbl(i) IS NOT NULL THEN
               px_item_id_tbl(i) := TO_NUMBER(l_item_number_tbl(i));
            ELSIF p_item_number_tbl(i) IS NULL AND
                  px_item_id_tbl(i) IS NULL AND
                  l_item_number_tbl(i) IS NULL THEN
               IF px_status_tbl(i) <> 'DISPUTED'  THEN
                  px_status_tbl(i)         := 'DISPUTED';
                  px_dispute_code_tbl(i)   := 'OZF_PRODUCT_CODE_MAP_MISS';
               END IF;
               Insert_Resale_Log(
                   p_id_value        =>  p_interface_line_id_tbl(i),
                   p_id_type         => 'IFACE',
                   p_error_code      => 'OZF_PRODUCT_CODE_MAP_MISS',
                   p_column_name     => 'INVENTORY_ITEM_ID',
                   p_column_value    =>  p_ext_item_number_tbl(i),
                   x_return_status   =>  x_return_status
               );
               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            END IF;
         END IF;   -- px_item_id_tbl(i) IS NOT NULL

         IF px_item_id_tbl(i) IS NULL THEN
            IF px_status_tbl(i) <> 'DISPUTED'  THEN
               px_status_tbl(i)         := 'DISPUTED';
               px_dispute_code_tbl(i)   := 'OZF_RESALE_PRODUCT_ID_MISS';
            END IF;

            Insert_Resale_Log(
               p_id_value        =>  p_interface_line_id_tbl(i),
               p_id_type         => 'IFACE',
               p_error_code      => 'OZF_RESALE_PRODUCT_ID_MISS',
               p_column_name     => 'INVENTORY_ITEM_ID',
               p_column_value    =>  p_item_number_tbl(i),
               x_return_status   =>  x_return_status
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;    -- px_item_id_tbl(i) IS NULL
      END LOOP;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
     p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END Product_Validations;


PROCEDURE UOM_Code_Mapping(
    p_party_id               IN  NUMBER,
    p_cust_account_id        IN  NUMBER,
    p_interface_line_id_tbl  IN  NUMBER_TABLE,
    p_ext_purchase_uom       IN  VARCHAR2_TABLE,
    p_ext_uom                IN  VARCHAR2_TABLE,
    p_ext_agreement_uom      IN  VARCHAR2_TABLE,
    px_int_purchase_uom      IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_int_uom               IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_int_agreement_uom     IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_status_tbl            IN  OUT NOCOPY  VARCHAR2_TABLE,
    px_dispute_code_tbl      IN  OUT NOCOPY  VARCHAR2_TABLE,
    x_return_status          OUT NOCOPY  VARCHAR2,
    x_msg_count              OUT NOCOPY  NUMBER,
    x_msg_data               OUT NOCOPY  VARCHAR2
)
IS
l_api_name                   CONSTANT VARCHAR2(30) := 'UOM_Code_Mapping';
l_api_version_number         CONSTANT NUMBER   := 1.0;

l_mapping_flag               VARCHAR2(1);
l_temp_code_tbl              VARCHAR2_TABLE;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ': start');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_mapping_flag := 'N';
   Mapping_Required(
       p_internal_code_tbl     => px_int_purchase_uom
     , p_external_code_tbl     => p_ext_purchase_uom
     , x_mapping_flag          => l_mapping_flag
   );
   IF l_mapping_flag = 'Y' THEN
      Code_Conversion(
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_UOM_CODES',
         p_external_code_tbl     => p_ext_purchase_uom,
         x_internal_code_tbl     => l_temp_code_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_temp_code_tbl.EXISTS(1) THEN
         FOR i IN 1..l_temp_code_tbl.COUNT LOOP
            IF px_int_purchase_uom(i) IS NULL THEN
               IF l_temp_code_tbl(i) IS NULL THEN
                  IF px_status_tbl(i) <> 'DISPUTED'  THEN
                     px_status_tbl(i)       := 'DISPUTED';
                     px_dispute_code_tbl(i) := 'OZF_UOM_CODE_MAP_MISS';
                  END IF;

                  Insert_Resale_Log(
                      p_id_value       =>  p_interface_line_id_tbl(i),
                      p_id_type        => 'IFACE',
                      p_error_code     => 'OZF_UOM_CODE_MAP_MISS',
                      p_column_name    => 'PURCHASE_UOM',
                      p_column_value   =>  p_ext_purchase_uom(i),
                      x_return_status  =>  x_return_status
                  );
                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               ELSE
                  px_int_purchase_uom(i) := l_temp_code_tbl(i);
               END IF;
            END IF;
         END LOOP;
      ELSE
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('External purchase uom might be null ');
         END IF;
      END IF;
   END IF;

   l_temp_code_tbl.DELETE;
   l_mapping_flag := 'N';
   Mapping_Required(
       p_internal_code_tbl     => px_int_uom
     , p_external_code_tbl     => p_ext_uom
     , x_mapping_flag          => l_mapping_flag
   );
   IF l_mapping_flag = 'Y' THEN
      Code_Conversion(
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_UOM_CODES',
         p_external_code_tbl     => p_ext_uom,
         x_internal_code_tbl     => l_temp_code_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_temp_code_tbl.EXISTS(1) THEN
         FOR i IN 1 .. l_temp_code_tbl.COUNT LOOP
            IF px_int_uom(i) IS NULL THEN
               IF l_temp_code_tbl(i) IS NULL THEN
                  IF px_status_tbl(i) <> 'DISPUTED'  THEN
                     px_status_tbl(i)       := 'DISPUTED';
                     px_dispute_code_tbl(i) := 'OZF_UOM_CODE_MAP_MISS';
                  END IF;

                  Insert_Resale_Log(
                      p_id_value       =>  p_interface_line_id_tbl(i),
                      p_id_type        => 'IFACE',
                      p_error_code     => 'OZF_UOM_CODE_MAP_MISS',
                      p_column_name    => 'UOM',
                      p_column_value   =>  p_ext_uom(i),
                      x_return_status  =>  x_return_status
                  );
                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               ELSE
                  px_int_uom(i) := l_temp_code_tbl(i);
               END IF;
            END IF;
         END LOOP;
      ELSE
         IF OZF_DEBUG_HIGH_ON THEN
            ozf_utility_pvt.debug_message('External  uom might be null ');
         END IF;
      END IF;
   END IF;

   l_temp_code_tbl.DELETE;
   l_mapping_flag := 'N';
   Mapping_Required(
       p_internal_code_tbl     => px_int_agreement_uom
     , p_external_code_tbl     => p_ext_agreement_uom
     , x_mapping_flag          => l_mapping_flag
   );
   IF l_mapping_flag = 'Y' THEN
      Code_Conversion(
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_UOM_CODES',
         p_external_code_tbl     => p_ext_agreement_uom,
         x_internal_code_tbl     => l_temp_code_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF l_temp_code_tbl.EXISTS(1) THEN
         FOR i IN 1 .. l_temp_code_tbl.COUNT LOOP
            IF px_int_agreement_uom(i) IS NULL THEN
               IF l_temp_code_tbl(i) IS NULL THEN
                  IF px_status_tbl(i) <> 'DISPUTED'  THEN
                     px_status_tbl(i)       := 'DISPUTED';
                     px_dispute_code_tbl(i) := 'OZF_UOM_CODE_MAP_MISS';
                  END IF;

                  Insert_Resale_Log(
                      p_id_value       =>  p_interface_line_id_tbl(i),
                      p_id_type        => 'IFACE',
                      p_error_code     => 'OZF_UOM_CODE_MAP_MISS',
                      p_column_name    => 'AGREEMENT_UOM',
                      p_column_value   =>  p_ext_agreement_uom(i),
                      x_return_status  =>  x_return_status
                  );
                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               ELSE
                  px_int_agreement_uom(i) := l_temp_code_tbl(i);
               END IF;
            END IF;
         END LOOP;
      ELSE
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('External  uom might be null ');
         END IF;
      END IF;

    END IF;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END UOM_Code_Mapping;

PROCEDURE Party_Mapping
(
  p_party_id               IN     NUMBER,
  p_cust_account_id        IN     NUMBER,
  p_party_type             IN     VARCHAR2,
  p_party_name_tbl         IN OUT NOCOPY VARCHAR2_TABLE,
  p_location_tbl           IN OUT NOCOPY VARCHAR2_TABLE,
  px_cust_account_id_tbl   IN OUT NOCOPY NUMBER_TABLE,
  px_site_use_id_tbl       IN OUT NOCOPY NUMBER_TABLE,
  px_party_id_tbl          IN OUT NOCOPY NUMBER_TABLE,
  px_party_site_id_tbl     IN OUT NOCOPY NUMBER_TABLE,
  x_return_status          OUT NOCOPY VARCHAR2
)
IS
   l_api_name               CONSTANT VARCHAR2(30) := 'Party_Mapping';
   l_api_version_number     CONSTANT NUMBER   := 1.0;

   l_mapping_flag           VARCHAR2(1);
   l_site_mapping_flag      VARCHAR2(1);

   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(2000);

   l_party_tbl              VARCHAR2_TABLE;
   l_party_site_tbl         VARCHAR2_TABLE;

   l_party_id               NUMBER;
   l_cust_account_id        NUMBER;

   CURSOR get_account_id (pc_party_Id NUMBER)
   IS
   SELECT   cust.cust_account_id
     FROM   hz_cust_accounts  cust
    WHERE   cust.party_id = pc_party_Id;

   CURSOR get_site_use_id ( pc_cust_account_id NUMBER
                          , pc_site_use    VARCHAR2 )
   IS
   SELECT   hcsu.site_use_id
     FROM   hz_cust_acct_sites hcs --hz_cust_acct_sites_all  hcs
        ,   hz_cust_site_uses  hcsu --,   hz_cust_site_uses_all  hcsu
    WHERE   hcsu.cust_acct_site_id = hcs.cust_acct_site_id
      AND   hcs.cust_account_id    = pc_cust_account_id
      AND   hcsu.site_use_code     = pc_site_use
      AND   hcsu.primary_flag= 'Y'
      AND   hcsu.status = 'A';

   /*
   SELECT   hcsu.site_use_id , hp.party_id , hc.cust_account_id
     FROM   hz_cust_acct_sites hcs --hz_cust_acct_sites_all  hcs
        ,   hz_cust_site_uses  hcsu --,   hz_cust_site_uses_all  hcsu
        ,   hz_party_sites hps
        ,   hz_parties hp
        ,   hz_cust_accounts hc
    WHERE   hcsu.cust_acct_site_id = hcs.cust_acct_site_id
      AND   hcs.party_site_id      = hps.party_site_id
      AND   hps.party_id           = hp.party_id
      AND   hcs.cust_account_id    = hc.cust_account_id
      AND   hc.party_id            = hp.party_id
      AND   hcsu.site_use_code     = pc_site_use
      AND   hps.party_site_id      = pc_party_site_id;
   */

CURSOR get_party_acc_id (cv_party_site_id IN NUMBER) IS
   SELECT   hp.party_id , hc.cust_account_id
     FROM   hz_party_sites hps
        ,   hz_parties hp
        ,   hz_cust_accounts hc
    WHERE   hps.party_id           = hp.party_id
      AND   hp.party_id            = hc.party_id (+)
      AND   hps.party_site_id      = cv_party_site_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- -----------
   -- Party Site
   -- -----------
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_pvt.debug_message('+++ Party Site Mapping +++');
       FOR i IN 1 ..  px_site_use_id_tbl.COUNT LOOP
       ozf_utility_pvt.debug_message('px_site_use_id_tbl('||i||')='||px_site_use_id_tbl(i));
       ozf_utility_pvt.debug_message('px_party_site_id_tbl('||i||')='||px_party_site_id_tbl(i));
       ozf_utility_pvt.debug_message('p_location_tbl('||i||')='||p_location_tbl(i));
       END LOOP;
    END IF;

    IF  px_site_use_id_tbl.COUNT > 0 THEN
       l_site_mapping_flag := 'N';
       FOR i IN 1 ..  px_site_use_id_tbl.COUNT
       LOOP
          IF  px_site_use_id_tbl(i) IS NOT NULL THEN
             l_site_mapping_flag := 'N';
             --exit;
          ELSE
             IF px_party_site_id_tbl(i) IS NOT NULL THEN
                 l_site_mapping_flag := 'N';
                 --exit;
             ELSIF  p_location_tbl(i) IS NOT NULL THEN
                 l_site_mapping_flag := 'Y';
                 exit;
             END IF;
          END IF;
       END LOOP;
    END IF;
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_pvt.debug_message('PARTY SITE Code Mapping Flag ' || l_site_mapping_flag);
    ENd IF;
    IF  l_site_mapping_flag = 'Y' AND p_location_tbl.COUNT > 0 THEN

        code_conversion
       (
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_PARTY_SITE_CODES',
         p_external_code_tbl     => p_location_tbl,
         x_internal_code_tbl     => l_party_site_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => l_msg_count ,
         x_msg_data              => l_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       IF  l_party_site_tbl.COUNT  > 0 THEN
           FOR i IN 1 .. l_party_site_tbl.COUNT
           LOOP
              IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('l_party_site_tbl('||i||')='||l_party_site_tbl(i));
              END IF;

              IF l_party_site_tbl.exists(i) AND l_party_site_tbl(i) IS NOT NULL THEN

                 px_party_site_id_tbl(i) := to_number(l_party_site_tbl(i));

                 OPEN get_party_acc_id(px_party_site_id_tbl(i));
                 FETCH get_party_acc_id INTO l_party_id, l_cust_account_id;
                 CLOSE get_party_acc_id;

                 IF px_cust_account_id_tbl(i) IS NULL THEN
                    px_cust_account_id_tbl(i) :=  l_cust_account_id;
                 END IF;

                 IF px_party_id_tbl(i) IS NULL THEN
                    px_party_id_tbl(i)        :=  l_party_id;
                 END IF;

                 IF l_cust_account_id IS NOT NULL THEN
                    OPEN get_site_use_id ( l_cust_account_id, p_party_type);
                    FETCH get_site_use_id INTO px_site_use_id_tbl(i);
                    CLOSE get_site_use_id;
                 END IF;
              END IF;
           END LOOP;
       END IF;
     END IF;   -- l_site_mapping_flag = 'Y'

   -- ------
   -- Party
   -- ------
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_pvt.debug_message('+++ Party Mapping +++');
       FOR i IN 1 ..  px_cust_account_id_tbl.COUNT LOOP
          ozf_utility_pvt.debug_message('px_cust_account_id_tbl('||i||')='||px_cust_account_id_tbl(i));
          ozf_utility_pvt.debug_message('px_party_id_tbl('||i||')='||px_party_id_tbl(i));
          ozf_utility_pvt.debug_message('p_party_name_tbl('||i||')='||p_party_name_tbl(i));
       END LOOP;
    END IF;

    IF  px_cust_account_id_tbl.COUNT > 0 THEN
       l_mapping_flag := 'N';
       FOR i IN 1 ..  px_cust_account_id_tbl.COUNT
       LOOP
          IF  px_cust_account_id_tbl(i) IS NOT NULL THEN
             l_mapping_flag := 'N';
             --exit;
          ELSE
             IF px_party_id_tbl(i) IS NOT NULL THEN
                 l_mapping_flag := 'N';
                 --exit;
             ELSIF  p_party_name_tbl(i) IS NOT NULL THEN
                 l_mapping_flag := 'Y';
                 exit;
             END IF;
          END IF;
       END LOOP;
    END IF;
    IF OZF_DEBUG_LOW_ON THEN
       ozf_utility_pvt.debug_message('PARTY Code Mapping Flag ' || l_mapping_flag);
    END IF;
    IF  l_mapping_flag = 'Y' AND p_party_name_tbl.COUNT > 0 THEN
        code_conversion
       (
         p_party_id              => p_party_id,
         p_cust_account_id       => p_cust_account_id ,
         p_mapping_type          => 'OZF_PARTY_CODES',
         p_external_code_tbl     => p_party_name_tbl,
         x_internal_code_tbl     => l_party_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => l_msg_count ,
         x_msg_data              => l_msg_data
       );
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       IF l_party_tbl.COUNT > 0 THEN
          FOR  i IN 1 .. l_party_tbl.COUNT
          LOOP
              IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('l_party_tbl('||i||')='||l_party_tbl(i));
              END IF;

             IF l_party_tbl.EXISTS(i) AND l_party_tbl(i) IS NOT NULL THEN

                px_party_id_tbl(i)  := to_number(l_party_tbl(i));

               OPEN  get_account_id ( px_party_id_tbl(i)) ;
               FETCH get_account_id INTO px_cust_account_id_tbl(i);
               CLOSE get_account_id;
            END IF;
         END LOOP;
       END IF;

    END IF;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
END Party_Mapping;


PROCEDURE Party_Validations
 (
     p_resale_line_int_id      IN NUMBER_TABLE,
     p_location                IN VARCHAR2_TABLE,
     p_address                 IN VARCHAR2_TABLE,
     p_city                    IN VARCHAR2_TABLE,
     p_state                   IN VARCHAR2_TABLE,
     p_postal_code             IN VARCHAR2_TABLE,
     p_country                 IN VARCHAR2_TABLE,
     p_contact_name            IN VARCHAR2_TABLE,
     p_email                   IN VARCHAR2_TABLE,
     p_fax                     IN VARCHAR2_TABLE,
     p_phone                   IN VARCHAR2_TABLE,
     p_site_use_type           IN VARCHAR2_TABLE,
     p_direct_customer_flag    IN VARCHAR2_TABLE,
     p_party_type              IN VARCHAR2,
     p_line_count              IN NUMBER,
     px_party_name             IN OUT NOCOPY VARCHAR2_TABLE,
     px_cust_account_id        IN OUT NOCOPY NUMBER_TABLE,
     px_site_use_id            IN OUT NOCOPY NUMBER_TABLE,
     px_party_id               IN OUT NOCOPY NUMBER_TABLE,
     px_party_site_id          IN OUT NOCOPY NUMBER_TABLE,
     px_contact_party_id       IN OUT NOCOPY NUMBER_TABLE,
     px_status_code_tbl        IN OUT NOCOPY VARCHAR2_TABLE,
     px_dispute_code_tbl       IN OUT NOCOPY VARCHAR2_TABLE,
     x_return_status           OUT NOCOPY VARCHAR2
 )
 IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Party_Validations';
l_api_version_number        CONSTANT NUMBER   := 1.0;

l_party_rec                 party_rec_type;
l_party_site_rec            party_site_rec_type;
l_party_cntct_rec           party_cntct_rec_type;

l_site_use_code             VARCHAR2(100);
l_dispute_code              VARCHAR2(100) := NULL;
l_run_dqm_flag              VARCHAR2(1);
l_site_id                   NUMBER := null;
l_party_site_id             NUMBER;
l_dqm_party_rule            VARCHAR2(50);
l_dqm_party_site_rule       VARCHAR2(50);
l_dqm_contact_rule          VARCHAR2(50);
l_party_id                  NUMBER;
l_rule_id                   NUMBER;
l_search_context_id         NUMBER;
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_num_matches               NUMBER;
l_org_contact_id            NUMBER(15);
l_contact_point_id          NUMBER(15);
l_creation_date             DATE;
l_score                     NUMBER;
l_highest_score_cnt         NUMBER := 0;
l_party_contact_id          NUMBER;
l_party_number              VARCHAR2(30);
l_party_site_number         VARCHAR2(30);
l_chk_flag                  VARCHAR2(1);
l_no_cust_account           VARCHAR2(1) := 'N';
l_cust_account_id           NUMBER := null;
l_no_loc_run_flag           VARCHAR2(1);

l_acct_site_id              NUMBER := null;
l_p_party_id                NUMBER := Null;

CURSOR get_party_id(pc_account_Id NUMBER) IS
   SELECT   cust.party_id
          , pt.party_name
   FROM hz_cust_accounts  cust, hz_parties pt
   WHERE cust_account_id = pc_account_Id
   AND   cust.party_id = pt.party_id ;



CURSOR get_site_use_from_acct ( pc_account_id NUMBER
                              , pc_location   VARCHAR2
                              , pc_site_use   VARCHAR2 ) IS
   SELECT  hcsu.site_use_id
         , hcas.party_site_id
         , hp.party_id
   FROM  hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
         hz_cust_site_uses hcsu, --  hz_cust_site_uses_all hcsu,
           hz_party_sites hps,
           hz_parties hp
   WHERE   hcas.party_site_id        = hps.party_site_id
   AND   hcsu.cust_acct_site_id    = hcas.cust_acct_site_id
   AND   hps.party_id              = hp.party_id
   AND   hcas.cust_account_id      = pc_account_id
   AND   hcsu.location             = pc_location
   AND   hcsu.site_use_code        = pc_site_use;

CURSOR get_site_from_acct ( pc_account_id NUMBER
                          , pc_location   VARCHAR2
                          , pc_site_use   VARCHAR2 ) IS
   SELECT  hcas.cust_acct_site_id
   FROM  hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
         hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
         hz_party_sites hps
   WHERE   hcas.party_site_id        = hps.party_site_id
   AND   hcsu.cust_acct_site_id    = hcas.cust_acct_site_id
   AND   hcas.cust_account_id      = pc_account_id
   AND   hcsu.location             = pc_location
   AND   hcsu.site_use_code        = pc_site_use;

CURSOR get_acct_from_site_use ( pc_site_use_id NUMBER ) IS
   SELECT  hcas.cust_account_id
      , hps.party_site_id
      , hp.party_id
      , hp.party_name
   FROM  hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_party_sites hps,
        hz_parties hp
   WHERE   hcas.party_site_id        = hps.party_site_id
   AND   hcsu.cust_acct_site_id    = hcas.cust_acct_site_id
   AND   hps.party_id              = hp.party_id
   AND   hcsu.site_use_id          = pc_site_use_id;

CURSOR get_acct_from_site ( pc_site_id NUMBER ) IS
   SELECT  hcas.cust_account_id
     ,  hp.party_id
     ,  hp.party_name
   FROM  hz_cust_acct_sites_all hcas,
        hz_party_sites hps,
        hz_parties  hp
   WHERE   hcas.party_site_id        = hps.party_site_id
   AND   hps.party_id              = hp.party_id
   AND   hcas.cust_acct_site_id    = pc_site_id;

CURSOR get_party_site_id ( pc_site_use_id NUMBER ) IS
   SELECT  hps.party_site_id
   FROM  hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_party_sites hps
   WHERE   hcas.party_site_id        = hps.party_site_id
   AND   hcsu.cust_acct_site_id    = hcas.cust_acct_site_id
   AND   hcsu.cust_acct_site_id    = pc_site_use_id
   UNION
   SELECT  hps.party_site_id
   FROM  hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_party_sites hps
   WHERE   hcas.party_site_id        = hps.party_site_id
   AND   hcsu.cust_acct_site_id    = hcas.cust_acct_site_id
   AND   hcsu.site_use_id          = pc_site_use_id;

CURSOR get_acct_site_info ( pc_address_id NUMBER ) IS
   SELECT hca.cust_account_id,
       hp.party_id,
       hcas.cust_acct_site_id,
       hp.party_name
   FROM hz_cust_accounts hca,
       hz_parties hp,
       hz_cust_acct_sites_all hcas,
       hz_party_sites hps
   WHERE  hcas.party_site_id        = hps.party_site_id
   AND  hcas.cust_account_id      = hca.cust_account_id
   AND  hp.party_id               = hca.party_id
   AND  hps.party_site_id         = pc_address_id;

CURSOR get_acct_site_use_info ( pc_address_id NUMBER,
                                pc_site_use VARCHAR2 )IS
   SELECT  hca.cust_account_id,
        hcsu.site_use_id,
        hp.party_id,
        hcas.party_site_id,
        hp.party_name
   FROM  hz_cust_accounts hca,
        hz_parties hp,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_party_sites hps,
        hz_locations hl
   WHERE  hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
   AND  hcas.party_site_id       = hps.party_site_id
   AND  hcsu.status              = 'A'
   AND  hps.location_id          = hl.location_id
   AND  hcas.cust_account_id     = hca.cust_account_id
   AND  hp.party_id              = hca.party_id
   AND  hps.party_site_id        = pc_address_id
   AND  hcsu.site_use_code       = pc_site_use;

CURSOR get_party_from_location ( pc_location   VARCHAR2
                               , pc_site_use   VARCHAR2
                               , pc_party_name VARCHAR2 ) IS
   SELECT  hca.cust_account_id,
       decode(p_party_type, 'SHIP_FROM',hcas.cust_acct_site_id,
                            'SOLD_FROM',hcas.cust_acct_site_id,
                            'BILL_TO', hcsu.site_use_id,
                            'SHIP_TO', hcsu.site_use_id,
                            'END_CUST', hcsu.site_use_id ) site_id,
        decode(p_party_type,'SHIP_FROM', NULL,
                            'SOLD_FROM', NULL,
                             hps.party_site_id)   party_site_id,
        hp.party_id
   FROM  hz_cust_accounts hca,
        hz_parties hp,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_party_sites hps,
        hz_locations hl
   WHERE  hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
   AND  hcas.party_site_id       = hps.party_site_id
   AND  hcsu.status              = 'A'
   AND  hps.location_id          = hl.location_id
   AND  hcas.cust_account_id     = hca.cust_account_id
   AND  hp.party_id              = hca.party_id
   AND  hcsu.location            = pc_location
   AND  hcsu.site_use_code       = pc_site_use
   AND  hp.party_name            = pc_party_name;


CURSOR get_location_details ( pc_location   VARCHAR2
                            , pc_site_use   VARCHAR2 ) IS
   SELECT  hca.cust_account_id,
       decode('SHIP_FROM', 'SHIP_FROM',hcas.cust_acct_site_id,
                            'SOLD_FROM',hcas.cust_acct_site_id,
                            'BILL_TO', hcsu.site_use_id,
                            'SHIP_TO', hcsu.site_use_id,
                            'END_CUST', hcsu.site_use_id ) site_id,
        decode('SHIP_FROM','SHIP_FROM', NULL,
                            'SOLD_FROM', NULL,
                             hps.party_site_id)   party_site_id,
        hp.party_id,
        hp.party_name
   FROM  hz_cust_accounts hca,
        hz_parties hp,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_party_sites hps
   WHERE  hcsu.cust_acct_site_id       = hcas.cust_acct_site_id
   AND  hcas.party_site_id           = hps.party_site_id
   AND  hcsu.status                  = 'A'
   AND  hps.status                   = 'A'
   AND  hp.status                    = 'A'
   AND  hcsu.primary_flag            = 'Y'
   AND  hcas.cust_account_id         = hca.cust_account_id
   AND  hp.party_id                  = hca.party_id
   AND  hcsu.location                = pc_location
   AND  hcsu.site_use_code           = pc_site_use;

CURSOR get_location ( pc_location   VARCHAR2
                    , pc_site_use   VARCHAR2 ) IS
   SELECT  hca.cust_account_id,
       decode('SHIP_FROM', 'SHIP_FROM',hcas.cust_acct_site_id,
                            'SOLD_FROM',hcas.cust_acct_site_id,
                            'BILL_TO', hcsu.site_use_id,
                            'SHIP_TO', hcsu.site_use_id,
                            'END_CUST', hcsu.site_use_id ) site_id,
        decode('SHIP_FROM','SHIP_FROM', NULL,
                            'SOLD_FROM', NULL,
                             hps.party_site_id)   party_site_id,
        hp.party_id,
        hp.party_name
   FROM  hz_cust_accounts hca,
        hz_parties hp,
        hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
        hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
        hz_party_sites hps
   WHERE  hcsu.cust_acct_site_id       = hcas.cust_acct_site_id
   AND  hcas.party_site_id           = hps.party_site_id
   AND  hcsu.status                  = 'A'
   AND  hps.status                   = 'A'
   AND  hp.status                    = 'A'
   AND  hcas.cust_account_id         = hca.cust_account_id
   AND  hp.party_id                  = hca.party_id
   AND  hcsu.location                = pc_location
   AND  hcsu.site_use_code           = pc_site_use;


CURSOR get_acct_site_use_id ( pc_party_id       NUMBER,
                             pc_party_site_id  NUMBER,
                             pc_site_use_type  VARCHAR2) IS
   SELECT  hca.cust_account_id,
       decode(p_party_type, 'SHIP_FROM',hcas.cust_acct_site_id,
                            'SOLD_FROM',hcas.cust_acct_site_id,
                             hcsu.site_use_id) site_id,
        decode(p_party_type,'SHIP_FROM', NULL,
                            'SOLD_FROM', NULL,
                             hps.party_site_id)   party_site_id,
        hp.party_id
   FROM  hz_cust_accounts hca,
      hz_parties hp,
      hz_cust_site_uses hcsu, --hz_cust_site_uses_all hcsu,
      hz_cust_acct_sites hcas, --hz_cust_acct_sites_all hcas,
      hz_party_sites hps,
      hz_locations hl
   WHERE  hcsu.cust_acct_site_id   = hcas.cust_acct_site_id
   AND  hcas.party_site_id       = hps.party_site_id
   AND  hcsu.status              = 'A'
   AND  hps.location_id          = hl.location_id
   AND  hcas.cust_account_id     = hca.cust_account_id
   AND  hp.party_id              = hca.party_id
   AND  hp.party_id              = pc_party_id
   AND  hps.party_site_id        = pc_party_site_id
   AND  hcsu.site_use_code       = pc_site_use_type;

-- [BEGIN OF BUG 4186465 FIXING]
CURSOR get_party_name(cv_party_id IN NUMBER) IS
   SELECT party_name
   FROM hz_parties
   WHERE party_id = cv_party_id;
-- [END OF BUG 4186465 FIXING]

-- Bug 5201195 (+)
CURSOR get_end_cust_location( cv_site_number IN VARCHAR2
                            , cv_site_use_type IN VARCHAR2) IS
    SELECT NULL
         , use.party_site_use_id
         , site.party_site_id
         , party.party_id
         , party.party_name
    FROM hz_parties party
       , hz_party_sites site
       , hz_locations loc
       , hz_party_site_uses use
    WHERE  site.location_id = loc.location_id
    AND    party.party_id = site.party_id
    AND    party.status = 'A'
    AND    party.party_type = 'ORGANIZATION'
    AND    site.party_site_id = use.party_site_id
    AND    use.site_use_type = cv_site_use_type
    AND    site.party_site_number = cv_site_number;
-- Bug 5201195 (-)


 BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

--   Site Use Code Defaulting
     IF p_party_type IN ('BILL_TO', 'SHIP_TO') THEN
        l_site_use_code :=  p_party_type;
     ELSIF p_party_type = 'SOLD_FROM' THEN
        l_site_use_code :=  'BILL_TO';
     ELSIF   p_party_type = 'SHIP_FROM' THEN
        l_site_use_code :=  'SHIP_TO';
     ELSIF  p_party_type = 'END_CUST' THEN
        l_site_use_code :=  NULL;
     END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Line Count ' || p_line_count);
   END IF;

     IF  p_line_count > 0 THEN

       FOR i IN  1 .. p_line_count
       LOOP
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message('p_location('||i||') '||p_location(i) || ' for '||p_party_type);
          END IF;
           l_run_dqm_flag       := NULL;
           l_cust_account_id    := NULL;
           l_party_site_id      := NULL;
           l_site_id            := NULL;

           IF  p_party_type = 'END_CUST' THEN
               l_site_use_code :=  p_site_use_type(i);
           END IF;
           IF px_cust_account_id.exists(i) AND px_cust_account_id(i) IS NOT NULL THEN

           IF OZF_DEBUG_LOW_ON THEN
              ozf_utility_pvt.debug_message('px_cust_account_id('||i||')'||px_cust_account_id(i));
           END IF;
              OPEN  get_party_id (px_cust_account_id(i));
              FETCH get_party_id INTO l_party_rec.party_id,
                                      px_party_name(i);

              IF get_party_id%NOTFOUND THEN

                  IF px_status_code_tbl(i) <> 'DISPUTED'  THEN
                     px_status_code_tbl(i)         := 'DISPUTED';
                     px_dispute_code_tbl(i)  := 'OZF_CLAIM_CUST_NOT_IN_DB';
                  END IF;

                  insert_resale_log
                     (p_id_value       =>  p_resale_line_int_id(i),
                      p_id_type        => 'IFACE',
                      p_error_code     =>  'OZF_CLAIM_CUST_NOT_IN_DB',
                      p_column_name    =>  p_party_type||'_CUST_ACCOUNT_ID',
                      p_column_value   =>  px_cust_account_id(i),
                      x_return_status  =>  x_return_status);

              ELSE
                 l_party_rec.party_name :=  px_party_name(i);
                 IF px_party_id.exists(i)AND px_party_id(i) IS NULL THEN
                   px_party_id(i)         :=  l_party_rec.party_id;
                 END IF;
                 IF px_site_use_id.exists(i) AND px_site_use_id(i) IS NULL THEN
                   IF p_location(i) IS NOT NULL THEN
                      IF p_party_type IN ('SHIP_FROM', 'SOLD_FROM') THEN
                         OPEN  get_site_from_acct (px_cust_account_id(i), p_location(i),l_site_use_code );
                         FETCH get_site_from_acct INTO px_site_use_id(i);
                         CLOSE get_site_from_acct;
                         IF OZF_DEBUG_LOW_ON THEN
                            ozf_utility_pvt.debug_message('getting ship from information ');
                            ozf_utility_pvt.debug_message('px_site_use_id('||i||') '||px_site_use_id(i));
                         END IF;
                      ELSE
                         IF px_party_site_id.exists(i) AND px_party_site_id(i) IS NOT NULL THEN
                            IF OZF_DEBUG_LOW_ON THEN
                               ozf_utility_pvt.debug_message('Site Use Information is not present for bill to and ship to ');
                            END IF;
                         ELSE
                            OPEN  get_site_use_from_acct (px_cust_account_id(i), p_location(i),l_site_use_code );
                            FETCH get_site_use_from_acct INTO px_site_use_id(i) , px_party_site_id(i), px_party_id(i);
                            CLOSE get_site_use_from_acct;
                         END IF;
                      END IF; --   p_party_type IN ('SHIP_FROM', 'SOLD_FROM')
                   END IF; --  p_location(i) IS NOT NULL
                END IF;  --  px_site_use_id.exists(i) AND px_site_use_id(i) IS NULL
              END IF; -- get_party_id%NOTFOUND
              CLOSE get_party_id;

           ELSIF  px_site_use_id.exists(i) AND px_site_use_id(i) IS NOT NULL  THEN
               IF  p_party_type IN ('SHIP_FROM', 'SOLD_FROM') THEN
                   OPEN  get_acct_from_site (px_site_use_id(i));
                   FETCH get_acct_from_site INTO l_cust_account_id
                                               , l_party_rec.party_id
                                               , px_party_name(i);
                   CLOSE get_acct_from_site;
               ELSE

                    OPEN  get_acct_from_site_use (px_site_use_id(i));
                    FETCH get_acct_from_site_use INTO l_cust_account_id
                                                    , l_site_id
                                                    , l_party_rec.party_id
                                                    , px_party_name(i);

                    IF  get_acct_from_site_use%NOTFOUND THEN
                        IF  p_party_type IN ('BILL_TO','SHIP_TO') THEN
                            IF px_status_code_tbl(i) <> 'DISPUTED'  THEN
                               px_status_code_tbl(i)     := 'DISPUTED';
                                px_dispute_code_tbl(i)   := 'OZF_CLAIM_'||p_party_type||'_ST_WRNG';
                             END IF;

                             insert_resale_log
                            (p_id_value         =>  p_resale_line_int_id(i),
                             p_id_type          => 'IFACE',
                             p_error_code       =>  'OZF_CLAIM_'||p_party_type||'_ST_WRNG',
                             p_column_name      =>  p_party_type||'_SITE_USE_ID',
                             p_column_value     =>  px_site_use_id(i),
                             x_return_status    =>  x_return_status);
                        END IF;
                    ELSE
                       IF px_party_site_id.EXISTS(i) AND px_party_site_id(i) IS NULL THEN
                          IF l_site_id IS NOT NULL THEN
                             px_party_site_id(i) := l_site_id;
                          END IF;
                       END IF;
                    END IF; --   get_acct_from_site_use%NOTFOUND
                    CLOSE get_acct_from_site_use;
                    IF OZF_DEBUG_LOW_ON THEN
                       ozf_utility_pvt.debug_message('px_site_use_id('||i||') '||px_site_use_id(i));
                    END IF;
                 END IF;
                 IF  px_party_id.exists(i) AND px_party_id(i) IS NULL THEN
                      px_party_id(i) := l_party_rec.party_id;
                 END IF;
                 IF px_cust_account_id.exists(i) AND px_cust_account_id(i) IS NULL  THEN
                    IF  l_cust_account_id IS NOT NULL  THEN
                       px_cust_account_id(i) :=  l_cust_account_id;
                    END IF;
                 END IF;
           ELSIF   p_location(i) IS  NOT NULL THEN
              IF p_party_type IN ('BILL_TO', 'SHIP_TO') THEN
                  IF px_party_site_id.exists(i) AND px_party_site_id(i) IS NULL THEN
                     l_no_loc_run_flag := 'Y';
                  END IF;
              ELSE
                     l_no_loc_run_flag := 'Y';
              END IF;
              IF OZF_DEBUG_LOW_ON THEN
                 ozf_utility_pvt.debug_message('Location ('||i||')' || p_location(i));
              END IF;
              IF l_no_loc_run_flag  = 'Y' THEN

                  Get_party_site_from_ECX
                  ( p_location       => p_location(i),
                    x_party_site_id  => l_party_site_id,
                    x_return_status  => x_return_status
                  );
                  IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_pvt.debug_message('Party Site ID from ECX API ' || l_party_site_id);
                  END IF;
                  IF l_party_site_id IS NOT NULL THEN
                     IF p_party_type IN ('SHIP_FROM', 'SOLD_FROM') THEN

                        OPEN  get_acct_site_info( l_party_site_id );
                        FETCH get_acct_site_info
                        INTO  l_cust_account_id
                             ,l_party_rec.party_id
                             ,px_site_use_id(i)
                             ,px_party_name(i);
                        CLOSE get_acct_site_info;
                     ELSE

                        OPEN  get_acct_site_use_info( l_party_site_id
                                                     ,p_party_type );
                        FETCH get_acct_site_use_info
                         INTO  l_cust_account_id
                             , px_site_use_id(i)
                             , px_party_id(i)
                             , px_party_site_id(i)
                             , px_party_name(i);
                        CLOSE get_acct_site_use_info;
                     END IF;  -- p_party_type IN ('SHIP_FROM', 'SOLD_FROM')
                     IF l_cust_account_id IS NOT NULL THEN
                        px_cust_account_id(i) :=  l_cust_account_id;
                     END IF;

                     l_party_site_rec.party_site_id :=  l_party_site_id;

                  ELSE  -- l_party_site_id IS NOT NULL

                    IF  px_party_name.exists(i) AND
                        px_party_name(i) IS NOT NULL AND
                        -- Bug 4469837 (+)
                        l_site_use_code IS NOT NULL THEN
                        -- Bug 4469837 (-)
                        OPEN  get_party_from_location( p_location(i)
                                                     , l_site_use_code
                                                     , px_party_name(i) );
                        FETCH get_party_from_location
                         INTO  l_cust_account_id
                             , px_site_use_id(i)
                             , px_party_site_id(i)
                             , px_party_id(i);
                        CLOSE get_party_from_location;
                        IF px_cust_account_id(i) IS NULL THEN
                           px_cust_account_id(i) :=  l_cust_account_id;
                        END IF;
                        IF OZF_DEBUG_LOW_ON THEN
                           ozf_utility_pvt.debug_message('px_cust_account_id('||i||')'||px_cust_account_id(i));
                           ozf_utility_pvt.debug_message('l_site_use_code ('||i||')'||l_site_use_code);
                           ozf_utility_pvt.debug_message('px_site_use_id ('||i||')'||px_site_use_id(i));
                        END IF;
                        IF  px_party_id.exists(i) AND px_party_id(i) IS NOT NULL THEN
                          l_party_rec.party_id           :=  px_party_id(i);
                        END IF;
-- To be commented
                     -- Bug 4469837 (+)
                     --ELSE
                     -- Bug 4469837 (-)
                     ELSIF l_site_use_code IS NOT NULL THEN
                        -- Bug 5201195 (+)
                        IF p_party_type = 'END_CUST' THEN
                           OPEN get_end_cust_location( p_location(i)
                                                     , l_site_use_code);
                           FETCH get_end_cust_location INTO l_cust_account_id
                                                          , px_site_use_id(i)
                                                          , px_party_site_id(i)
                                                          , px_party_id(i)
                                                          , px_party_name(i);
                           CLOSE get_end_cust_location;
                        -- Bug 5201195 (-)
                        ELSE
                            OPEN  get_location_details( p_location(i)
                                                      , l_site_use_code);

                            FETCH get_location_details
                             INTO  l_cust_account_id
                                 , px_site_use_id(i)
                                 , px_party_site_id(i)
                                 , px_party_id(i)
                                 , px_party_name(i);
                            CLOSE get_location_details;
                        END IF;

                        IF OZF_DEBUG_LOW_ON THEN
                           ozf_utility_pvt.debug_message('l_site_use_code '||l_site_use_code);
                           ozf_utility_pvt.debug_message('p_location('||i||') '||p_location(i));
                        END IF;
                        IF l_cust_account_id IS NULL THEN
                           OPEN  get_location( p_location(i)
                                             , l_site_use_code
                                             );
                           FETCH get_location
                           INTO  l_cust_account_id
                               , px_site_use_id(i)
                               , px_party_site_id(i)
                               , px_party_id(i)
                               , px_party_name(i);
                           CLOSE get_location;

                        END IF;

                        IF px_cust_account_id.EXISTS(i) AND px_cust_account_id(i) IS NULL THEN
                           px_cust_account_id(i) :=  l_cust_account_id;
                        END IF;
                        IF  px_party_id.exists(i) AND px_party_id(i) IS NOT NULL THEN
                          l_party_rec.party_id           :=  px_party_id(i);
                        END IF;
--
                     END IF;
                   END IF; --  l_party_site_id IS NOT NULL
              END IF;   -- -- l_no_loc_run_flag
          END IF;  -- p_location(i) is null

          --Bug# 8489216 fixed by ateotia(+)
          --We should run the DQM irrespective of Direct Customer Flag.
          /*
          IF p_direct_customer_flag.exists(i) AND  p_direct_customer_flag(i) = 'F' THEN
             IF p_party_type IN ('BILL_TO', 'SHIP_TO') THEN
                l_run_dqm_flag := 'N';
             END IF;
          END IF;
          */
          --Bug# 8489216 fixed by ateotia(-)

          IF l_run_dqm_flag IS NULL OR l_run_dqm_flag = 'Y' THEN
             IF px_cust_account_id.exists(i) AND px_cust_account_id(i) IS NOT NULL THEN
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('px_cust_account_id('||i||')'||px_cust_account_id(i));
                END IF;
                IF  px_party_id.exists(i) AND px_party_id(i) IS NULL  THEN
                    OPEN  get_party_id (px_cust_account_id(i));
                    FETCH get_party_id INTO l_party_rec.party_id,
                                            l_party_rec.party_name;
                    CLOSE get_party_id;
                    IF OZF_DEBUG_LOW_ON THEN
                       ozf_utility_pvt.debug_message('l_party_rec.party_id '||l_party_rec.party_id);
                       ozf_utility_pvt.debug_message('l_party_rec.party_name '||l_party_rec.party_name);
                    END IF;
                END IF;
             ELSIF  px_party_id.exists(i) AND px_party_id(i) IS NOT NULL THEN
                l_party_rec.party_id :=  px_party_id(i);
                -- [BEGIN OF BUG 4186465 FIXING]
                OPEN get_party_name(l_party_rec.party_id);
                FETCH get_party_name INTO px_party_name(i);
                CLOSE get_party_name;
                -- [END OF BUG 4186465 FIXING]
             ELSIF   px_party_name(i) IS NOT NULL THEN
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('px_party_name('||i||') '||px_party_name(i));
                END IF;
                l_party_rec.party_id                    := NULL;
                l_party_rec.party_name                  :=    px_party_name(i);

                l_party_site_rec.address                :=    p_address(i);
                l_party_site_rec.city                   :=    p_city(i);
                l_party_site_rec.state                  :=    p_state(i);
                l_party_site_rec.postal_code            :=    p_postal_code(i);
                l_party_site_rec.country                :=    p_country(i);
             ELSE
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('party record is null ');
                   ozf_utility_pvt.debug_message('px_party_name('||i||') for  '||l_site_use_code||' '||px_party_name(i));
                END IF;
                l_party_rec.party_name := NULL;
                l_party_rec.party_id   := NULL;
             END IF;
             IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('Address starting .......................');
             END IF;
             IF  px_party_site_id.exists(i) AND  px_party_site_id(i) IS NOT NULL THEN
                 l_party_site_rec.party_site_id     :=   px_party_site_id(i);
                 IF OZF_DEBUG_LOW_ON THEN
                    ozf_utility_pvt.debug_message('px_party_site_id('||i||') '||px_party_site_id(i));
                 END IF;
             ELSIF px_site_use_id.exists(i) AND   px_site_use_id(i) IS NOT NULL THEN


                 OPEN  get_party_site_id (px_site_use_id(i) );
                 FETCH get_party_site_id INTO px_party_site_id(i);
                 CLOSE get_party_site_id;
                 IF  px_party_site_id.exists(i) AND  px_party_site_id(i) IS NOT NULL  THEN
                     l_party_site_rec.party_site_id       :=   px_party_site_id(i);
                     IF OZF_DEBUG_LOW_ON THEN
                        ozf_utility_pvt.debug_message('px_party_site_id('||i||') '||px_party_site_id(i));
                     END IF;
                 ELSE
                     px_party_site_id(i) := NULL;
                 END IF;
             ELSIF   p_address(i) IS NOT NULL THEN
                 IF OZF_DEBUG_LOW_ON THEN
                    ozf_utility_pvt.debug_message('p_address('||i||') '||p_address(i));
                 END IF;
                 l_party_site_rec.party_site_id          :=    null;
                 l_party_site_rec.address                :=    p_address(i);
                 l_party_site_rec.city                   :=    p_city(i);
                 l_party_site_rec.state                  :=    p_state(i);
                 l_party_site_rec.postal_code            :=    p_postal_code(i);
                 l_party_site_rec.country                :=    p_country(i);
            ELSE
                 IF OZF_DEBUG_LOW_ON THEN
                    ozf_utility_pvt.debug_message('Address is null ');
                 END IF;
            END IF;

            IF    px_contact_party_id.exists(i) AND px_contact_party_id(i) IS NULL THEN
                IF  p_contact_name.exists(i) AND p_contact_name(i) IS NOT NULL THEN

                   l_party_cntct_rec.contact_name          :=   p_contact_name(i);
                   l_party_cntct_rec.party_email_id        :=   p_email(i);
                   l_party_cntct_rec.party_phone           :=   p_phone(i);
                   l_party_cntct_rec.party_fax             :=   p_fax(i);
                END IF;
            END IF;
         END IF;

         IF  l_run_dqm_flag IS NULL  AND l_party_rec.party_id IS NULL   THEN
            IF l_party_rec.party_name IS NOT NULL THEN
               l_run_dqm_flag := 'Y';
            END IF;
        END IF;

        IF  l_run_dqm_flag IS NULL THEN
          IF  l_party_rec.party_id IS NOT NULL THEN
             IF  l_party_site_rec.address IS NOT NULL AND
                 l_party_site_rec.party_site_id IS NULL AND
                 -- Bug 4469837 (+)
                 p_party_type IN ('BILL_TO', 'SHIP_TO', 'SOLD_FROM', 'SHIP_FROM') THEN
                 -- Bug 4469837 (-)
                 l_run_dqm_flag := 'Y';
             END IF;
          END IF;
          IF  px_contact_party_id.exists(i) AND px_contact_party_id(i) IS NULL THEN
              IF  l_party_rec.party_id IS NOT NULL
              AND p_contact_name.exists(i)
              AND p_contact_name(i) IS NOT NULL THEN
                 l_run_dqm_flag := 'Y';
             END IF;
          END IF; -- px_contact_party_id(i) IS NULL

        END IF;


        IF l_run_dqm_flag = 'Y'  THEN

          l_dqm_party_rule      := G_DQM_PARTY_RULE; --fnd_profile.value('OZF_RESALE_PARTY_DQM_RULE');
          l_dqm_party_site_rule := G_DQM_PARTY_SITE_RULE; --fnd_profile.value('OZF_RESALE_PARTY_SITE_DQM_RULE');
          l_dqm_contact_rule    := G_DQM_CONTACT_RULE; --fnd_profile.value('OZF_RESALE_CONTACT_DQM_RULE');

          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message( 'Party DQM Rule '||   l_dqm_party_rule );
             ozf_utility_pvt.debug_message( 'Party Site DQM Rule '|| l_dqm_party_site_rule );
             ozf_utility_pvt.debug_message( 'Contact DQM Rule '|| l_dqm_contact_rule );
          END IF;
       -- Rules
       --
          IF l_party_rec.party_id IS NULL THEN
             IF l_dqm_party_rule IS NULL THEN
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('Party DQM Search Rule cannot be null,please set OZF:Resale DQM Party Rule profile with a valid value');
                END IF;
                l_dispute_code := 'OZF_NO_PARTY_DQM_RULE';
             END IF ;
          END IF;
          IF l_party_site_rec.party_site_id IS NULL THEN
             IF  l_dispute_code IS NULL AND l_dqm_party_site_rule IS NULL
             AND l_party_site_rec.address IS NOT NULL THEN
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('Party Site DQM Search Rule cannot be null,please set OZF:Resale DQM Party Site Rule profile with a valid value');
                END IF;
                l_dispute_code := 'OZF_NO_SITE_DQM_RULE';
             END IF ;
          END IF;
          IF l_party_cntct_rec.contact_name IS NOT NULL AND
             l_dispute_code IS NULL AND l_dqm_contact_rule IS NULL THEN
             IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('Contact DQM Search Rule cannot be null,please set OZF:Resale DQM Contact Rule profile with a valid value');
             END IF;
             l_dispute_code := 'OZF_NO_CONTACT_DQM_RULE';
          END IF ;


          IF  l_dispute_code IS NULL AND l_run_dqm_flag = 'Y'   THEN
            --
             l_party_rec.party_rule_name              := l_dqm_party_rule;
             l_party_site_rec.party_site_rule_name    := l_dqm_party_site_rule;
             l_party_cntct_rec.contact_rule_name      := l_dqm_contact_rule;
           --
           IF OZF_DEBUG_LOW_ON THEN
              ozf_utility_pvt.debug_message('DQM Process started ........');
           END IF;
            l_party_id        := NULL;
            l_party_site_id   := NULL;
            l_party_contact_id:= NULL;

             DQM_Processing (
                p_api_version_number  => 1.0,
                p_init_msg_list       => FND_API.G_FALSE,
                P_Commit              => FND_API.G_FALSE,
                p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
                p_party_rec           => l_party_rec,
                p_party_site_rec      => l_party_site_rec,
                p_contact_rec         => l_party_cntct_rec,
                x_party_id            => l_party_id,
                x_party_site_id       => l_party_site_id,
                x_party_contact_id    => l_party_contact_id,
                x_return_status       => x_return_status,
                x_msg_count           => l_msg_count,
                x_msg_data            => l_msg_data);

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   l_dispute_code := 'OZF_DQM_PROCESS_ERROR';
                ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
                px_contact_party_id(i) := NVL( l_party_contact_id,'');
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message( 'Party ID '||   l_party_id );
                   ozf_utility_pvt.debug_message( 'Party Site ID '|| l_party_site_id );
                END IF;
                IF l_party_site_rec.party_site_id IS NULL THEN
                   IF  l_party_id IS NOT NULL AND l_party_site_id IS NOT NULL THEN
                     IF p_party_type IN ('SOLD_FROM','SHIP_FROM','BILL_TO','SHIP_TO') THEN

                        -- Initialzing
                        l_cust_account_id := NULL;
                        l_acct_site_id    := NULL;
                        l_p_party_id      := NULL;
                        l_site_id         := NULL;

                        OPEN  get_acct_site_use_id( l_party_id
                                                   ,l_party_site_id
                                                   ,l_site_use_code );
                        FETCH get_acct_site_use_id
                        INTO  l_cust_account_id
                            , l_acct_site_id
                            , l_site_id
                            , l_p_party_id ;
                        CLOSE get_acct_site_use_id;

                        IF OZF_DEBUG_LOW_ON THEN
                           ozf_utility_pvt.debug_message( 'Account ID from get_acct_site_use_id '||   l_cust_account_id );
                           ozf_utility_pvt.debug_message( 'Site Use ID from get_acct_site_use_id'|| l_acct_site_id );
                           ozf_utility_pvt.debug_message( 'Party ID from get_acct_site_use_id '||   l_p_party_id );
                           ozf_utility_pvt.debug_message( 'Party Site ID from get_acct_site_use_id '|| l_site_id );
                        END IF;

                        IF l_cust_account_id IS NOT NULL THEN
                          px_cust_account_id(i) :=  l_cust_account_id;
                        END IF;
                        IF  l_acct_site_id   IS NOT NULL THEN
                           px_site_use_id(i) :=  l_acct_site_id;
                        END IF;

                        IF l_site_id IS NOT NULL THEN
                            px_party_site_id(i) := l_site_id;
                        ELSE
                            px_party_site_id(i) := l_party_site_id;
                        END IF;

                        IF  l_p_party_id IS NOT NULL THEN
                            px_party_id(i) := l_p_party_id;
                        ELSE
                            px_party_id(i) := l_party_id;
                        END IF;
                     ELSE   -- p_party_type IN ('SOLD_FROM','SHIP_FROM','BILL_TO','SHIP_TO')
                        px_party_id(i)       := l_party_id;
                        px_party_site_id(i)  := l_party_site_id;
                     END IF;
                  --Bug# 8489216 fixed by ateotia(+)
                  ELSIF l_party_id IS NOT NULL AND l_party_site_id IS NULL THEN
                     IF px_party_id.exists(i) AND px_party_id(i) IS NULL THEN
                        px_party_id(i) := l_party_id;
                     END IF;
                  --Bug# 8489216 fixed by ateotia(-)
                  ELSE
                     IF px_site_use_id.exists(i) AND px_site_use_id(i) IS NULL THEN
                        px_site_use_id(i)    := NULL;
                     END IF;
                     IF px_party_site_id.exists(i) AND px_party_site_id(i) IS NULL THEN
                        px_party_site_id(i)  := NULL;
                     END IF;
                     IF   px_party_id.exists(i) AND px_party_id(i) IS NULL THEN
                        px_party_id(i)       := NULL;
                     END IF;
                  END IF;      -- l_party_id IS NOT NULL AND l_party_site_id IS NOT NULL
                END IF;
           END IF;
         END IF;   -- l_run_dqm_flag = 'Y'
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('px_status_code ('||i||') '||px_status_code_tbl(i));
            ozf_utility_pvt.debug_message('px_dispute_code_tbl ('||i||') '||px_dispute_code_tbl(i));
         END IF;
 --        ozf_utility_pvt.debug_message(lower(p_party_type)||'_cust_account_id('||i||')'||px_cust_account_id(i));
--         ozf_utility_pvt.debug_message(lower(p_party_type)||'_party_site_id('||i||')'||px_party_site_id(i));
  --       ozf_utility_pvt.debug_message(lower(p_party_type)||'_party_id('||i||')'||px_party_id(i));
 --        ozf_utility_pvt.debug_message(lower(p_party_type)||'_site_use_id('||i||')'||px_site_use_id(i));

         IF  l_dispute_code IS NOT NULL THEN
            IF px_status_code_tbl(i) <> 'DISPUTED'  THEN
               px_status_code_tbl(i)   := 'DISPUTED';
               px_dispute_code_tbl(i)  := l_dispute_code;
            END IF;

             insert_resale_log
            (p_id_value       =>  p_resale_line_int_id(i),
             p_id_type        => 'IFACE',
             p_error_code     =>  l_dispute_code,
             p_column_name    =>  NULL,
             p_column_value   =>  NULL,
             x_return_status  =>  x_return_status);

             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
         END IF;
    END LOOP;
  END IF;  -- p_line_count > 0
    -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
 END Party_Validations;


PROCEDURE DQM_Processing (
    p_api_version_number    IN         NUMBER,
    p_init_msg_list         IN         VARCHAR2     := FND_API.G_FALSE,
    p_Commit                IN         VARCHAR2     := FND_API.G_FALSE,
    p_validation_level      IN         NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_party_rec             IN         party_rec_type,
    p_party_site_rec        IN         party_site_rec_type,
    p_contact_rec           IN         party_cntct_rec_type,
    x_party_id              OUT NOCOPY NUMBER,
    x_party_site_id         OUT NOCOPY NUMBER,
    x_party_contact_id      OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2
)
IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'DQM_processing';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

 -- Cursor for getting matched party_id from hz_matched_parties_gt
   CURSOR C_matched_party ( pc_search_id NUMBER)
   IS
   SELECT party_id
     FROM ( SELECT hzmp.party_id,
                 score
           FROM  hz_matched_parties_gt hzmp,
                 hz_parties hzp
           WHERE search_context_id = pc_search_id
             AND hzp.party_id = hzmp.party_id
        ORDER BY score desc, hzp.creation_date desc )
    WHERE rownum = 1;

    -- Cursor for getting matched party_site from hz_matched_party_sites_gt
   CURSOR C_matched_party_sites  ( pc_search_id NUMBER)
   IS
    SELECT  hzmps.party_id,
            hzmps.party_site_id,
            score ,
            hzps.creation_date
      FROM  hz_matched_party_sites_gt hzmps,
            hz_party_sites hzps
     WHERE  search_context_id = pc_search_id
       AND  hzps.party_site_id = hzmps.party_site_id
       AND  hzps.party_id = hzmps.party_id
   ORDER BY score desc, hzps.creation_date desc;

   -- Cursor for getting matched contacts from hz_matched_contacts_gt
   CURSOR C_matched_contacts ( pc_search_id NUMBER)
   IS
   SELECT hzmc.party_id,
          hzmc.org_contact_id,
          score
     FROM hz_matched_contacts_gt hzmc
    WHERE search_context_id = pc_search_id;


   CURSOR get_match_rule ( pc_rule_name VARCHAR2)
   IS
   SELECT match_rule_id
     FROM hz_match_rules_vl
    WHERE active_flag = 'Y'
      AND compilation_flag = 'C'
      AND rule_name = pc_rule_name;

  -- DQM Record Types
  l_party_cond                HZ_PARTY_SEARCH.PARTY_SEARCH_REC_TYPE;
  l_party_site_cond           HZ_PARTY_SEARCH.PARTY_SITE_LIST;
  l_contact_cond              HZ_PARTY_SEARCH.CONTACT_LIST;
  l_contact_point_cond        HZ_PARTY_SEARCH.CONTACT_POINT_LIST;


  l_rule_id                   NUMBER;
  l_partner_id                NUMBER;
  l_search_context_id         NUMBER;
  l_return_status             VARCHAR2(1);
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(2000);
  l_num_matches               NUMBER;
  l_org_contact_id            NUMBER(15);
  l_party_id                  NUMBER(15);
  l_party_site_id             NUMBER(15);
  l_contact_point_id          NUMBER(15);
  l_creation_date             DATE;
  l_score                     NUMBER;
  l_highest_score_cnt         NUMBER := 0;
  l_create_party              VARCHAR2(1);
  l_create_party_site         VARCHAR2(1);
  l_create_contact            VARCHAR2(1);
  l_index                     NUMBER;



BEGIN

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
  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
  END IF;
  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Data Assignment to DQM datatypes
--
-- 1. Pass Party search criteria in party_cond
-- -------------------------------------------------------------------

--   l_party_cond.party_type  := p_party_rec.party_type;
   l_party_cond.duns_number_c := p_party_rec.duns_number;
   l_party_cond.party_name    := p_party_rec.party_name;

--
-- 2. Pass Party Site search criteria in party_site_cond
-- --------------------------------------------------------------------
   l_party_site_cond(1).address      := p_party_site_rec.address;
   l_party_site_cond(1).city         := p_party_site_rec.city;
   l_party_site_cond(1).postal_code  := p_party_site_rec.postal_code;
 --  l_party_site_cond(1).country    := p_party_site_rec.country;
--   l_party_site_cond(1).state      := p_party_site_rec.state;

--
-- 3. Pass Contact search criteria in contact_cond
-- -------------------------------------------------------------------
   l_contact_cond(1).contact_name := p_contact_rec.contact_name;

--
-- 4. Pass Contact Point search criteria in contact_point_cond
-- -------------------------------------------------------------------
   l_index := 1;
   IF p_contact_rec.party_email_id IS NOT NULL THEN
      l_contact_point_cond(l_index).CONTACT_POINT_TYPE := 'EMAIL';
      l_contact_point_cond(l_index).EMAIL_ADDRESS := p_contact_rec.party_email_id;
      l_index := l_index+1;
   END IF;

   IF p_contact_rec.party_phone IS NOT NULL THEN
      l_contact_point_cond(l_index).CONTACT_POINT_TYPE := 'PHONE';
      l_contact_point_cond(l_index).RAW_PHONE_NUMBER := p_contact_rec.party_phone;
      l_index := l_index+1;
   END IF;

   IF p_contact_rec.party_fax IS NOT NULL THEN
      l_contact_point_cond(l_index).CONTACT_POINT_TYPE := 'PHONE';
      l_contact_point_cond(l_index).PHONE_LINE_TYPE := 'FAX';
      l_contact_point_cond(l_index).raw_phone_number:= p_contact_rec.party_fax;
      l_index := l_index+1;
    END IF;

   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message (' Party Rule name '|| p_party_rec.party_rule_name);
      ozf_utility_pvt.debug_message ('Party Name '||  p_party_rec.party_name );
      ozf_utility_pvt.debug_message ('Party ID '||  p_party_rec.party_id );
   END IF;
--
-- Party DQM Search
-- -------------------------------------------------------------------------------
    IF p_party_rec.party_id IS NULL THEN

       l_rule_id := p_party_rec.party_rule_name;

       IF  l_rule_id IS NOT NULL THEN

          IF p_party_rec.party_name IS NOT NULL
          OR p_party_rec.duns_number IS NOT NULL
          THEN
             IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message ('calling find parties ');
             END IF;
             HZ_PARTY_SEARCH.find_parties
            (p_init_msg_list        =>  'T',
             x_rule_id              =>  l_rule_id,
             p_party_search_rec     =>  l_party_cond,
             p_party_site_list      =>  l_party_site_cond,
             p_contact_list         =>  l_contact_cond ,
             p_contact_point_list   =>  l_contact_point_cond,
             p_restrict_sql         =>  NULL,
             p_search_merged        =>  'N',
             x_search_ctx_id        =>  l_search_context_id,
             x_num_matches          =>  l_num_matches,
             x_return_status        =>  l_return_status,
             x_msg_count            =>  l_msg_count,
             x_msg_data             =>  l_msg_data);

             IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
             ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
             IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('Number of matches'|| l_num_matches);
             END IF;
             IF l_num_matches >= 1 THEN

                OPEN C_matched_party(l_search_context_id);
                LOOP
                   FETCH C_matched_party INTO l_party_id;
                   EXIT WHEN  C_matched_party%NOTFOUND;
                   l_highest_score_cnt  := l_highest_score_cnt +1;
                END LOOP;
                CLOSE C_matched_party;
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('Matched party - '||to_char(l_party_id)||' score '||to_char(l_score));
                END IF;
                x_party_id := l_party_id;  --assign the matched party_id

              ELSIF l_num_matches = 0 AND p_party_rec.party_id IS NULL THEN
                 IF OZF_DEBUG_LOW_ON THEN
                     ozf_utility_pvt.debug_message('No party match found !');
                 END IF;
              END IF;   --  l_num_matches >= 1

         ELSE
           IF OZF_DEBUG_LOW_ON THEN
              ozf_utility_pvt.debug_message('Party Name/DUNS Number is not supplied. DQM Search cannot be performed');
           END IF;

         END IF;   --   p_party_rec.party_name IS NOT NULL

      ELSE
           IF OZF_DEBUG_LOW_ON THEN
              ozf_utility_pvt.debug_message('Match Rule for Party Search is not active or uncompiled. Check the match rule');
           END IF;
           RAISE FND_API.g_exc_error;
      END IF;   -- l_rule_id IS NOT NULL

    ELSE
        l_party_id := p_party_rec.party_id;
        x_party_id := l_party_id;  --assign the matched party_id
    END IF;    --  p_party_rec.party_id IS NULL


   l_rule_id := NULL;
-- ----------------------------------------- End PARTY SEARCH --------------------------------------
--
-- Party Site DQM Search
-- -------------------------------------------------------------------------------------------------


   IF   p_party_site_rec.party_site_id IS NULL THEN

       IF  l_party_id IS NOT NULL AND p_party_site_rec.address IS NOT NULL THEN
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message ('Site Rule name '|| p_party_site_rec.party_site_rule_name);
          END IF;
           l_rule_id := p_party_site_rec.party_site_rule_name;

           IF  l_rule_id IS NOT NULL THEN

              IF  p_party_site_rec.address IS NOT NULL
              AND (p_party_site_rec.postal_code IS NOT NULL
              OR  ( p_party_site_rec.city IS NOT NULL
                   AND
                   p_party_site_rec.state IS NOT NULL ))
               THEN

                   HZ_PARTY_SEARCH.get_matching_party_sites
                  ('T',
                   l_rule_id,
                   l_party_id,
                   l_party_site_cond,
                   l_contact_point_cond,
                   l_search_context_id,
                   l_return_status,
                   l_msg_count,
                   l_msg_data);

                   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

                   OPEN  C_matched_party_sites(l_search_context_id);
                   FETCH C_matched_party_sites INTO l_party_id,
                                                    l_party_site_id,
                                                    l_score,
                                                    l_creation_date;
                   CLOSE C_matched_party_sites;

                   IF l_party_site_id IS NOT NULL THEN
                      x_party_site_id :=  l_party_site_id;
                   ELSE
                      IF OZF_DEBUG_LOW_ON THEN
                         ozf_utility_pvt.debug_message('No party site found !');
                      END IF;
                      l_create_party_site := 'Y';
                   END IF;
              ELSE
                 IF OZF_DEBUG_LOW_ON THEN
                    ozf_utility_pvt.debug_message('Required parameters are missing. DQM Search for party site cannot be performed');
                 END IF;

              END IF;    -- party site check

           ELSE --if rule_id is null then
              IF OZF_DEBUG_LOW_ON THEN
                 ozf_utility_pvt.debug_message('Match Rule for Party Site is not active or uncompiled. Check the match rule');
              END IF;
              RAISE FND_API.g_exc_error;
           END IF;

           l_rule_id := NULL;

       END IF;   --   l_party_id IS NOT NULL
   ELSE

      l_party_site_id := p_party_site_rec.party_site_id;
      x_party_site_id :=  l_party_site_id;

   END IF;    -- p_party_site_rec.party_site_id IS NULL

-- ------------------------------------------ End Party Site Search --------------------------------
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message ('Contact Rule name '|| p_contact_rec.contact_rule_name);
   END IF;

   l_rule_id := null;


-- Contact DQM Search
-- -------------------------------------------------------------------------------------------------
   l_rule_id := p_contact_rec.contact_rule_name;

    IF  p_party_rec.party_id IS NOT NULL THEN
        l_party_id := p_party_rec.party_id;
    END IF;

    IF l_party_id IS NOT NULL THEN

       IF l_rule_id IS NOT NULL THEN
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message('contact name ........'|| l_contact_cond(1).contact_name);
             ozf_utility_pvt.debug_message('Email ........'|| p_contact_rec.party_email_id );
             ozf_utility_pvt.debug_message('Phone ........'||p_contact_rec.party_phone );
             ozf_utility_pvt.debug_message('Fax ........'||p_contact_rec.party_fax );
          END IF;

         IF  p_contact_rec.contact_name IS NOT NULL THEN

            HZ_PARTY_SEARCH.get_matching_contacts
           (p_init_msg_list        => 'T',
            p_rule_id              =>  l_rule_id,
            p_party_id             =>  l_party_id,
            p_contact_list         =>  l_contact_cond,
            p_contact_point_list   =>  l_contact_point_cond,
            x_search_ctx_id        =>  l_search_context_id,
            x_return_status        =>  l_return_status,
            x_msg_count            =>  l_msg_count,
            x_msg_data             =>  l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_pvt.debug_message('l_search_context_id ........'|| l_search_context_id );
            END IF;


             OPEN C_matched_contacts(l_search_context_id);
             FETCH C_matched_contacts INTO l_party_id, l_org_contact_id, l_score;
             CLOSE C_matched_contacts;
             IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('contact info from DQM ........'|| l_party_id || ' : '||l_org_contact_id);
             END IF;

             IF l_org_contact_id is not null THEN
                 x_party_contact_id :=  l_org_contact_id;
             ELSE
                IF OZF_DEBUG_LOW_ON THEN
                   ozf_utility_pvt.debug_message('No contact match found !');
                END IF;
             END IF;
        ELSE
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_pvt.debug_message('DQM Search for contact cannot be performed');
            END IF;
        END IF;    --p_contact_rec.contact_name IS NOT NULL


     ELSE
        IF OZF_DEBUG_LOW_ON THEN
           ozf_utility_pvt.debug_message('Match Rule for Party Contact is not active or uncompiled. Check the match rule');
        END IF;
        RAISE FND_API.g_exc_error;
     END IF; -- l_rule_id IS NOT NULL

   END IF; -- l_party_id IS NOT NULL
   ------------------------------------------ End CONTACT SEARCH ---------------------------------------

   -- Standard check for p_commit


   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END DQM_Processing;


--  =========================================================================================
--  Code Conversions
--  =========================================================================================

PROCEDURE code_conversion
(
    p_party_id              IN  VARCHAR2,
    p_cust_account_id       IN  VARCHAR2,
    p_mapping_type          IN  VARCHAR2,
    p_external_code_tbl     IN  VARCHAR2_TABLE,
    x_internal_code_tbl     OUT NOCOPY  VARCHAR2_TABLE,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
)
IS

    l_api_name                  CONSTANT VARCHAR2(30) := 'code_conversion';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

    l_mapping_flag              VARCHAR2(1);
    l_previous_code             VARCHAR2(3200) := NULL;
    l_temp_code_tbl             VARCHAR2_TABLE;
    idx                         NUMBER;

BEGIN

      -- Debug Message
  IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
  END IF;

      -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF  p_external_code_tbl.COUNT > 0 THEN

       FOR i IN 1 .. p_external_code_tbl.COUNT
       LOOP
           IF  p_external_code_tbl(i) IS NOT NULL THEN
              IF OZF_DEBUG_LOW_ON THEN
                  ozf_utility_pvt.debug_message('Party ID: ' || p_party_id);
                  ozf_utility_pvt.debug_message('p_cust_account_id ' || p_cust_account_id);
                  ozf_utility_pvt.debug_message('External Code: ' || p_external_code_tbl(i));
                  ozf_utility_pvt.debug_message('Length of External Code: ' || length(p_external_code_tbl(i)));
                  ozf_utility_pvt.debug_message('Mapping Type: ' || p_mapping_type);
               END IF;
               SELECT dbms_utility.get_hash_value( p_external_code_tbl(i),1, 2048)
               INTO   idx
               FROM DUAL;
               IF  l_temp_code_tbl.exists(idx) THEN
                   x_internal_code_tbl(i) :=  l_temp_code_tbl(idx);
                   IF OZF_DEBUG_LOW_ON THEN
                      ozf_utility_pvt.debug_message('Internal Code: ' || x_internal_code_tbl(i));
                   END IF;

               ELSE
                     OZF_CODE_CONVERSION_PVT.convert_code
                    (p_cust_account_id       => p_cust_account_id,
                     p_party_id              => p_party_id,
                     p_code_conversion_type  => p_mapping_type,
                     p_external_code         => p_external_code_tbl(i),
                     x_internal_code         => x_internal_code_tbl(i),
                     x_return_status         => x_return_status,
                     x_msg_count             => x_msg_count,
                     x_msg_data              => x_msg_data);

                    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                       RAISE FND_API.G_EXC_ERROR;
                    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;
                    IF OZF_DEBUG_LOW_ON THEN
                       ozf_utility_pvt.debug_message('Internal Code'||x_internal_code_tbl(i));
                    END IF;

                    IF  x_internal_code_tbl(i) IS NOT NULL THEN
                        l_temp_code_tbl(idx) := x_internal_code_tbl(i);
                    ELSE
                        l_temp_code_tbl(idx) := '';
                    END IF;
               END IF;
           ELSE
              IF OZF_DEBUG_LOW_ON THEN
                ozf_utility_pvt.debug_message('Code Conversion cannot be performed ');
             END IF;
             x_internal_code_tbl(i) := NULL;
           END IF;  -- p_external_code_tbl(i) IS NOT NULL
       END LOOP;

   END IF;   -- p_external_code_tbl.COUNT > 0

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END Code_Conversion;

PROCEDURE Mapping_Required
(
    p_internal_code_tbl     IN  VARCHAR2_TABLE,
    p_external_code_tbl     IN  VARCHAR2_TABLE,
    x_mapping_flag          OUT NOCOPY VARCHAR2
)
IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Mapping_Required';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
 BEGIN

    IF  p_internal_code_tbl.COUNT > 0 THEN
       FOR i IN 1 ..  p_internal_code_tbl.COUNT
       LOOP
          IF  p_internal_code_tbl.EXISTS(i) AND
              p_internal_code_tbl(i) IS NOT NULL THEN
             x_mapping_flag := 'N';
          ELSIF p_external_code_tbl.EXISTS(i) AND
                p_external_code_tbl(i) IS NOT NULL THEN
             x_mapping_flag := 'Y';
             exit;
          ELSE
             x_mapping_flag := 'N';
          END IF;
       END LOOP;
    END IF;
 END Mapping_Required;


 PROCEDURE Number_Mapping_Required
 (
    p_internal_code_tbl     IN  NUMBER_TABLE,
    x_mapping_flag          OUT NOCOPY VARCHAR2
 )
 IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Number_Mapping_Required';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
 BEGIN

    IF  p_internal_code_tbl.COUNT > 0 THEN
       FOR i IN 1 ..  p_internal_code_tbl.COUNT
       LOOP
          IF  p_internal_code_tbl(i) IS NOT NULL THEN
             x_mapping_flag := 'N';
             exit;
          ELSE
             x_mapping_flag := 'Y';
          END IF;
       END LOOP;
    END IF;
 END Number_Mapping_Required;


 FUNCTION set_line_status
 ( p_count          IN  NUMBER,
   p_status_code    IN  VARCHAR2)
 RETURN   VARCHAR2_TABLE
 IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'set_line_status';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

    l_tbl                       VARCHAR2_TABLE;
BEGIN
   FOR i IN 1 .. p_count
   loop
      l_tbl(i) := p_status_code;
   END LOOP;
   RETURN l_tbl;
END set_line_status;


 PROCEDURE Get_Customer_Accnt_Id(
   p_party_id      IN  NUMBER,
   p_party_site_id IN  NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_cust_acct_id  OUT NOCOPY NUMBER
 )
 IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Get_Customer_Accnt_Id';
    l_api_version_number        CONSTANT NUMBER   := 1.0;

   CURSOR c_get_cust_accnt_id(pc_party_site_id NUMBER)
   IS
     SELECT s.cust_account_id
       FROM hz_cust_acct_sites  s
      WHERE s.party_site_id = pc_party_site_id
        AND status   = 'A';

   CURSOR c_get_customer_accnt_id(pc_party_id NUMBER)
   IS
     SELECT a.cust_account_id
       FROM hz_cust_accounts  a
      WHERE a.party_id = pc_party_id
        AND status   = 'A';

    l_msg_count        number;
    l_msg_data         varchar2(200);
    l_return_status    VARCHAR2(1);

 BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_party_id IS NULL AND
    p_party_site_id IS NULL
 THEN
    FND_MESSAGE.set_name('OZF', 'OZF_BATCH_PARTNER_NULL');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
 END IF;

 -- get customer account based on party site id
 IF p_party_site_id is not null THEN
    OPEN c_get_cust_accnt_id(p_party_site_id);
    FETCH c_get_cust_accnt_id INTO x_cust_acct_id;
    CLOSE c_get_cust_accnt_id;
 END IF;

 IF x_cust_acct_id is null THEN
    IF p_party_id is not null THEN
       OPEN c_get_customer_accnt_id(p_party_id);
       FETCH c_get_customer_accnt_id INTO x_cust_acct_id;
       CLOSE c_get_customer_accnt_id;
    END IF;
 END IF;

 IF x_cust_acct_id IS NULL   THEN
    ozf_utility_pvt.error_message('OZF_BATCH_PARTNER_NULL');
 END IF;

 EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
 END Get_Customer_Accnt_Id;

 PROCEDURE Get_party_site_from_ECX
 (
   p_location       IN VARCHAR2,
   x_party_site_id  OUT NOCOPY  NUMBER,
   x_return_status  OUT NOCOPY  VARCHAR2
 )
 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Get_party_site_from_ECX';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_address_id      NUMBER;
   l_ecx_org_id      NUMBER;
   l_return_code     PLS_INTEGER;
   l_return_message  VARCHAR2(32000);

 BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     ECX_TRADING_PARTNER_PVT.Get_Address_id
     (
        p_location_code_ext      => p_location,
        p_info_type              => ECX_Trading_Partner_PVT.G_CUSTOMER,
        p_entity_address_id      => l_address_id,
        p_org_id                 => l_ecx_org_id,
        retcode                  => l_return_code,
        retmsg                   => l_return_message
     );
     IF OZF_DEBUG_LOW_ON THEN
        ozf_utility_pvt.debug_message('Address ID '|| l_address_id || 'Return Code '|| l_return_code);
     END IF;

     IF l_return_code = 0 THEN
        x_party_site_id :=  l_address_id;
     ELSE
        x_party_site_id :=  NULL;
     END IF;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' End');
   END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END Get_party_site_from_ECX;

PROCEDURE Chk_party_record_null(
   p_line_count             IN  NUMBER,
   p_party_type             IN  VARCHAR2,
   p_cust_account_id        IN  NUMBER_TABLE,
   p_acct_site_id           IN  NUMBER_TABLE,
   p_party_id               IN  NUMBER_TABLE,
   p_party_site_id          IN  NUMBER_TABLE,
   p_location               IN  VARCHAR2_TABLE,
   p_party_name             IN  VARCHAR2_TABLE,
   x_null_flag              OUT NOCOPY  VARCHAR2,
   x_return_status          OUT NOCOPY  VARCHAR2
)
IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Chk_party_record_null';
l_api_version_number        CONSTANT NUMBER   := 1.0;

BEGIN

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_null_flag := 'Y';

   IF p_line_count > 0 THEN
      FOR i IN 1 .. p_line_count LOOP
         IF OZF_DEBUG_LOW_ON THEN
            IF p_cust_account_id.exists(i) THEN
               ozf_utility_pvt.debug_message('p_cust_account_id  = '||p_cust_account_id(i));
            END IF;
            IF p_acct_site_id.exists(i) THEN
               ozf_utility_pvt.debug_message('p_acct_site_id     = '||p_acct_site_id(i));
            END IF;
            IF p_party_id.exists(i) THEN
               ozf_utility_pvt.debug_message('p_party_id         = '||p_party_id(i));
            END IF;
            IF p_party_site_id.exists(i) THEN
               ozf_utility_pvt.debug_message('p_party_site_id    = '||p_party_site_id(i));
            END IF;
            IF p_location.exists(i) THEN
               ozf_utility_pvt.debug_message('p_location         = '||p_location(i));
            END IF;
            IF p_party_name.exists(i) THEN
               ozf_utility_pvt.debug_message('p_party_name       = '||p_party_name(i));
            END IF;
         END IF;


         IF p_cust_account_id.exists(i) AND p_cust_account_id(i) IS NOT NULL THEN
            x_null_flag := 'N';
         ELSE
            IF p_acct_site_id.exists(i) AND p_acct_site_id(i) IS NOT NULL THEN
               x_null_flag := 'N';
            ELSE
               IF p_location.exists(i) AND p_location(i) IS NOT NULL THEN
                  x_null_flag := 'N';
               ELSE
                  --IF p_party_type = 'SHIP_TO' THEN -- [Bug 4186465 Fixing]
                     IF p_party_site_id.exists(i) AND p_party_site_id(i) IS NOT NULL THEN
                        x_null_flag := 'N';
                     ELSE
                        IF p_party_id.exists(i) AND p_party_id(i) IS NOT NULL THEN
                           x_null_flag := 'N';
                        ELSE
                           IF p_party_name.exists(i) AND p_party_name(i) IS NOT NULL THEN
                              x_null_flag := 'N';
                           ELSE
                              x_null_flag := 'Y';
                           END IF; -- p_party_name
                        END IF; -- p_party_id
                     END IF; -- p_party_site_id
                  --END IF; -- [Bug 4186465 Fixing]
                  --IF x_null_flag IS NULL AND p_party_name.exists(i) AND p_party_name(i) IS NOT NULL THEN
                  --   x_null_flag := 'N';
                  --ELSIF p_party_name.exists(i) AND p_party_name(i) IS NULL THEN
                  --   x_null_flag := 'Y';
                  --END IF;  -- p_party_name
               END IF; -- p_location
           END IF;  --  p_acct_site_id
         END IF; -- p_cust_account_id
     END LOOP;
  END IF;

  IF OZF_DEBUG_HIGH_ON THEN
     ozf_utility_pvt.debug_message('x_null_flag in check party record: ' || x_null_flag);
     ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END Chk_party_record_null;


PROCEDURE Derive_Party
(  p_resale_line_int_id   IN   NUMBER_TABLE
 , p_line_count           IN   NUMBER
 , p_party_type           IN   VARCHAR2
 , p_cust_account_id      IN   NUMBER_TABLE
 , p_site_id              IN   NUMBER_TABLE
 , x_cust_account_id      OUT NOCOPY   NUMBER_TABLE
 , x_site_id              OUT NOCOPY   NUMBER_TABLE
 , x_site_use_id          OUT NOCOPY   NUMBER_TABLE
 , x_party_id             OUT NOCOPY   NUMBER_TABLE
 , x_party_name           OUT NOCOPY   VARCHAR2_TABLE
 , px_status_code_tbl     IN OUT NOCOPY   VARCHAR2_TABLE
 , px_dispute_code_tbl    IN OUT NOCOPY   VARCHAR2_TABLE
 , x_return_status        OUT NOCOPY   VARCHAR2
)
IS
l_api_name                   CONSTANT VARCHAR2(30) := 'Derive_Party';
l_api_version_number         CONSTANT NUMBER   := 1.0;

-- SOLD_FROM (ship_from_cust_account_id)
CURSOR get_sf_cust(cv_cust_account_id IN NUMBER) IS
   SELECT hcas.cust_account_id
        , hps.party_site_id
        , hp.party_id
        , hp.party_name
   FROM hz_cust_acct_sites hcas,
        hz_cust_site_uses hcsu,
        hz_party_sites hps,
        hz_parties hp
   WHERE hp.party_id = hcas.cust_account_id
   AND   hp.party_id = hps.party_id
   AND   hps.party_site_id = hcas.party_site_id
   AND   hcas.cust_account_id = cv_cust_account_id
   AND   hcas.cust_acct_site_id  = hcsu.cust_acct_site_id
   AND   hcsu.primary_flag = 'Y'
   AND   hcsu.site_use_code = 'BILL_TO';

-- SOLD_FROM (ship_from_cust_account_id, ship_from_site_id)
CURSOR get_sf_cust_and_site(cv_cust_account_id IN NUMBER) IS
   SELECT hp.party_id
        , hp.party_name
   FROM hz_cust_accounts hca,
        hz_parties hp
   WHERE hp.party_id = hca.party_id
   AND   hca.cust_account_id = cv_cust_account_id;

-- SOLD_FROM (ship_from_site_id)
CURSOR get_sf_site(cv_party_site_id IN NUMBER) IS
   SELECT hcas.cust_account_id
        , hps.party_site_id
        , hp.party_id
        , hp.party_name
   FROM hz_cust_acct_sites hcas,
        hz_cust_site_uses hcsu,
        hz_party_sites hps,
        hz_parties hp
   WHERE hp.party_id = hcas.cust_account_id
   AND   hp.party_id = hps.party_id
   AND   hps.party_site_id = hcas.party_site_id
   AND   hcas.cust_acct_site_id  = hcsu.cust_acct_site_id
   AND   hcas.party_site_id = cv_party_site_id
   AND   hcsu.site_use_code = 'BILL_TO';

-- BILL_TO (ship_to_cust_account_id)
CURSOR get_bt_cust(cv_cust_account_id IN NUMBER) IS
   SELECT hcas.cust_account_id
        , hcsu.site_use_id
        , hps.party_site_id
        , hp.party_id
        , hp.party_name
   FROM hz_cust_acct_sites hcas,
        hz_cust_site_uses hcsu,
        hz_party_sites hps,
        hz_parties hp
   WHERE hp.party_id = hcas.cust_account_id
   AND   hp.party_id = hps.party_id
   AND   hps.party_site_id = hcas.party_site_id
   AND   hcas.cust_account_id = cv_cust_account_id
   AND   hcas.cust_acct_site_id  = hcsu.cust_acct_site_id
   AND   hcsu.primary_flag = 'Y'
   AND   hcsu.site_use_code = 'BILL_TO';


-- BILL_TO (ship_to_cust_account_id, ship_to_site_use_id)
CURSOR get_bt_cust_and_site(cv_cust_account_id IN NUMBER
                           ,cv_site_use_id IN NUMBER) IS
   SELECT hcas.cust_account_id
        , hcsu.site_use_id
        , hps.party_site_id
        , hp.party_id
        , hp.party_name
   FROM hz_cust_acct_sites hcas,
        hz_cust_site_uses hcsu,
        hz_party_sites hps,
        hz_parties hp,
        hz_cust_site_uses shcsu
   WHERE hp.party_id = hcas.cust_account_id
   AND   hp.party_id = hps.party_id
   AND   hps.party_site_id = hcas.party_site_id
   AND   hcas.cust_account_id = cv_cust_account_id
   AND   hcas.cust_acct_site_id  = hcsu.cust_acct_site_id
   AND   hcsu.site_use_code = 'BILL_TO'
   AND   shcsu.bill_to_site_use_id = hcsu.site_use_id
   AND   shcsu.site_use_code = 'SHIP_TO'
   AND   shcsu.site_use_id = cv_site_use_id;

-- BILL_TO (ship_to_site_use_id)
CURSOR get_bt_site(cv_site_use_id IN NUMBER) IS
   SELECT hcas.cust_account_id
        , hcsu.site_use_id
        , hps.party_site_id
        , hp.party_id
        , hp.party_name
   FROM hz_cust_acct_sites hcas,
        hz_cust_site_uses hcsu,
        hz_party_sites hps,
        hz_parties hp,
        hz_cust_acct_sites shcas,
        hz_cust_site_uses shcsu
   WHERE hp.party_id = hcas.cust_account_id
   AND   hp.party_id = hps.party_id
   AND   hps.party_site_id = hcas.party_site_id
   AND   hcas.cust_acct_site_id  = hcsu.cust_acct_site_id
   AND   hcsu.site_use_code = 'BILL_TO'
   AND   hcas.cust_account_id = shcas.cust_account_id
   AND   shcas.cust_acct_site_id = shcsu.cust_acct_site_id
   AND   shcsu.bill_to_site_use_id = hcsu.site_use_id
   AND   shcsu.site_use_code = 'SHIP_TO'
   AND   shcsu.site_use_id = cv_site_use_id;

l_cust_account_id            NUMBER;
l_site_use_id                NUMBER;
l_party_site_id              NUMBER;
l_party_id                   NUMBER;
l_party_name                 VARCHAR2(1000);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_line_count > 0 THEN
      IF OZF_DEBUG_LOW_ON THEN
         FOR  i IN 1 .. p_line_count LOOP
            ozf_utility_pvt.debug_message('p_cust_account_id('||i||')'||p_cust_account_id(i));
            ozf_utility_pvt.debug_message('p_site_id('||i||')'||p_site_id(i));
         END LOOP;
      END IF;

      FOR i IN 1 .. p_line_count LOOP
         x_cust_account_id(i) := NULL;
         x_site_id(i)         := NULL;
         x_party_name(i)      := NULL;
         x_site_use_id(i)     := NULL;
         x_party_id(i)        := NULL;

         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('px_status_code_tbl('||i||')'||px_status_code_tbl(i));
            ozf_utility_pvt.debug_message('px_dispute_code_tbl('||i||')'||px_dispute_code_tbl(i));
         END IF;

         IF p_party_type = 'SOLD_FROM' AND
            px_status_code_tbl(i) = 'DISPUTED' AND
            px_dispute_code_tbl(i) = 'OZF_SHIP_FROM_ACCOUNT_NULL' THEN
            EXIT;
         ELSE
            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_pvt.debug_message('p_party_type'||p_party_type);
               ozf_utility_pvt.debug_message('p_cust_account_id('||i||')'||p_cust_account_id(i));
               ozf_utility_pvt.debug_message('p_site_id('||i||')'||p_site_id(i));
            END IF;

            IF p_cust_account_id.exists(i) AND
               p_cust_account_id(i) IS NOT NULL THEN
               IF p_site_id.exists(i) AND
                  p_site_id(i) IS NOT NULL THEN
                  IF p_party_type = 'SOLD_FROM' THEN
                     x_cust_account_id(i) := p_cust_account_id(i);
                     x_site_id(i) := p_site_id(i);
                     x_site_use_id(i) := NULL;

                     OPEN  get_sf_cust_and_site (p_cust_account_id(i));
                     FETCH get_sf_cust_and_site INTO x_party_id(i)
                                                   , x_party_name(i);
                     CLOSE get_sf_cust_and_site;
                  ELSE
                     OPEN  get_bt_cust_and_site (p_cust_account_id(i), p_site_id(i));
                     FETCH get_bt_cust_and_site INTO x_cust_account_id(i)
                                                   , x_site_use_id(i)
                                                   , x_site_id(i)
                                                   , x_party_id(i)
                                                   , x_party_name(i);
                     CLOSE get_bt_cust_and_site;
                  END IF;
               ELSE
                  IF p_party_type = 'SOLD_FROM' THEN
                     x_site_use_id(i) := NULL;
                     OPEN  get_sf_cust(p_cust_account_id(i));
                     FETCH get_sf_cust INTO x_cust_account_id(i)
                                          , x_site_id(i)
                                          , x_party_id(i)
                                          , x_party_name(i);
                     CLOSE get_sf_cust;
                  ELSE
                     OPEN  get_bt_cust_and_site (p_cust_account_id(i), p_site_id(i));
                     FETCH get_bt_cust_and_site INTO x_cust_account_id(i)
                                                   , x_site_use_id(i)
                                                   , x_site_id(i)
                                                   , x_party_id(i)
                                                   , x_party_name(i);
                     CLOSE get_bt_cust_and_site;
                  END IF;
               END IF;
            ELSE
               IF p_site_id.exists(i) AND
                  p_site_id(i) IS NOT NULL THEN
                  IF p_party_type = 'SOLD_FROM' THEN
                     x_site_use_id(i) := NULL;
                     OPEN  get_sf_site (p_site_id(i));
                     FETCH get_sf_site INTO x_cust_account_id(i)
                                          , x_site_id(i)
                                          , x_party_id(i)
                                          , x_party_name(i);
                     CLOSE get_sf_site;
                  ELSE
                     x_site_use_id(i) := NULL;
                     OPEN  get_bt_site (p_site_id(i));
                     FETCH get_bt_site INTO x_cust_account_id(i)
                                          , x_site_use_id(i)
                                          , x_site_id(i)
                                          , x_party_id(i)
                                          , x_party_name(i);
                     CLOSE get_bt_site;
                  END IF;
               END IF;
            END IF;

            IF OZF_DEBUG_LOW_ON THEN
               ozf_utility_pvt.debug_message('-------');
               ozf_utility_pvt.debug_message('x_cust_account_id('||i||')'||x_cust_account_id(i));
               ozf_utility_pvt.debug_message('x_site_id('||i||')'||x_site_id(i));
               ozf_utility_pvt.debug_message('x_party_name('||i||')'||x_party_name(i));
               ozf_utility_pvt.debug_message('x_site_use_id('||i||')'||x_site_use_id(i));
               ozf_utility_pvt.debug_message('x_party_id('||i||')'||x_party_id(i));
            END IF;

         END IF;
      END LOOP;
   END IF; -- end of if p_line_count > 0

   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;

END derive_party;

PROCEDURE Update_interface_line
(
   p_api_version_number    IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE,
   p_Commit                IN  VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_int_line_tbl          IN  resale_line_int_tbl_type,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'update_interface_line';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      -- Debug Message
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;
       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
      IF   p_int_line_tbl.count > 0 THEN

       FOR l_count in p_int_line_tbl.FIRST .. p_int_line_tbl.LAST
       LOOP
          IF OZF_DEBUG_LOW_ON THEN
             ozf_utility_pvt.debug_message('p_int_line_tbl(l_count).resale_line_int_id ' || p_int_line_tbl(l_count).resale_line_int_id );
          END IF;

          OZF_RESALE_LINES_INT_PKG.Update_Row(
          p_resale_line_int_id                =>  p_int_line_tbl(l_count).resale_line_int_id,
          p_object_version_number             =>  p_int_line_tbl(l_count).object_version_number,
          p_last_update_date                  =>  p_int_line_tbl(l_count).last_update_date,
          p_last_updated_by                   =>  p_int_line_tbl(l_count).last_updated_by,
          p_request_id                        =>  p_int_line_tbl(l_count).request_id,
          p_created_from                      =>  p_int_line_tbl(l_count).created_from,
          p_last_update_login                 =>  p_int_line_tbl(l_count).last_update_login,
          p_program_application_id            =>  p_int_line_tbl(l_count).program_application_id,
          p_program_update_date               =>  p_int_line_tbl(l_count).program_update_date,
          p_program_id                        =>  p_int_line_tbl(l_count).program_id,
          p_response_type                     =>  p_int_line_tbl(l_count).response_type,
          p_response_code                     =>  p_int_line_tbl(l_count).response_code,
          p_reject_reason_code                =>  p_int_line_tbl(l_count).reject_reason_code,
          p_followup_action_code              =>  p_int_line_tbl(l_count).followup_action_code,
          p_resale_transfer_type              =>  p_int_line_tbl(l_count).resale_transfer_type,
          p_product_trans_movement_type       =>  p_int_line_tbl(l_count).product_transfer_movement_type,
          p_product_transfer_date             =>  p_int_line_tbl(l_count).product_transfer_date,
          p_resale_batch_id                   =>  p_int_line_tbl(l_count).resale_batch_id,
          p_status_code                       =>  p_int_line_tbl(l_count).status_code,
          p_end_cust_party_id                 =>  p_int_line_tbl(l_count).end_cust_party_id,
          p_end_cust_site_use_id              =>  p_int_line_tbl(l_count).end_cust_site_use_id,
          p_end_cust_site_use_code            =>  p_int_line_tbl(l_count).end_cust_site_use_code,
          p_end_cust_party_site_id            =>  p_int_line_tbl(l_count).end_cust_party_site_id,
          p_end_cust_party_name               =>  p_int_line_tbl(l_count).end_cust_party_name,
          p_end_cust_location                 =>  p_int_line_tbl(l_count).end_cust_location,
          p_end_cust_address                  =>  p_int_line_tbl(l_count).end_cust_address,
          p_end_cust_city                     =>  p_int_line_tbl(l_count).end_cust_city,
          p_end_cust_state                    =>  p_int_line_tbl(l_count).end_cust_state,
          p_end_cust_postal_code              =>  p_int_line_tbl(l_count).end_cust_postal_code,
          p_end_cust_country                  =>  p_int_line_tbl(l_count).end_cust_country,
          p_end_cust_contact_party_id         =>  p_int_line_tbl(l_count).end_cust_contact_party_id,
          p_end_cust_contact_name             =>  p_int_line_tbl(l_count).end_cust_contact_name,
          p_end_cust_email                    =>  p_int_line_tbl(l_count).end_cust_email,
          p_end_cust_phone                    =>  p_int_line_tbl(l_count).end_cust_phone,
          p_end_cust_fax                      =>  p_int_line_tbl(l_count).end_cust_fax,
          p_bill_to_cust_account_id           =>  p_int_line_tbl(l_count).bill_to_cust_account_id,
          p_bill_to_site_use_id               =>  p_int_line_tbl(l_count).bill_to_site_use_id,
          p_bill_to_PARTY_NAME                =>  p_int_line_tbl(l_count).bill_to_party_name,
          p_bill_to_PARTY_ID                  =>  p_int_line_tbl(l_count).bill_to_PARTY_ID,
          p_bill_to_PARTY_site_id             =>  p_int_line_tbl(l_count).bill_to_PARTY_site_id,
          p_bill_to_location                  =>  p_int_line_tbl(l_count).bill_to_location,
          p_bill_to_duns_number               =>  p_int_line_tbl(l_count).bill_to_duns_number,
          p_bill_to_address                   =>  p_int_line_tbl(l_count).bill_to_address,
          p_bill_to_city                      =>  p_int_line_tbl(l_count).bill_to_city,
          p_bill_to_state                     =>  p_int_line_tbl(l_count).bill_to_state,
          p_bill_to_postal_code               =>  p_int_line_tbl(l_count).bill_to_postal_code,
          p_bill_to_country                   =>  p_int_line_tbl(l_count).bill_to_country,
          p_bill_to_contact_party_id          =>  p_int_line_tbl(l_count).bill_to_contact_party_id,
          p_bill_to_contact_name              =>  p_int_line_tbl(l_count).bill_to_contact_name,
          p_bill_to_email                     =>  p_int_line_tbl(l_count).bill_to_email,
          p_bill_to_phone                     =>  p_int_line_tbl(l_count).bill_to_phone,
          p_bill_to_fax                       =>  p_int_line_tbl(l_count).bill_to_fax,
          p_ship_to_cust_account_id           =>  p_int_line_tbl(l_count).ship_to_cust_account_id,
          p_ship_to_site_use_id               =>  p_int_line_tbl(l_count).ship_to_site_use_id,
          p_ship_to_party_name                =>  p_int_line_tbl(l_count).ship_to_party_name,
          p_ship_to_party_id                  =>  p_int_line_tbl(l_count).ship_to_party_id,
          p_ship_to_party_site_id             =>  p_int_line_tbl(l_count).ship_to_party_site_id,
          p_ship_to_duns_number               =>  p_int_line_tbl(l_count).ship_to_duns_number,
          p_ship_to_location                  =>  p_int_line_tbl(l_count).ship_to_location,
          p_ship_to_address                   =>  p_int_line_tbl(l_count).ship_to_address,
          p_ship_to_city                      =>  p_int_line_tbl(l_count).ship_to_city,
          p_ship_to_state                     =>  p_int_line_tbl(l_count).ship_to_state,
          p_ship_to_postal_code               =>  p_int_line_tbl(l_count).ship_to_postal_code,
          p_ship_to_country                   =>  p_int_line_tbl(l_count).ship_to_country,
          p_ship_to_contact_party_id          =>  p_int_line_tbl(l_count).ship_to_contact_party_id,
          p_ship_to_contact_name              =>  p_int_line_tbl(l_count).ship_to_contact_name,
          p_ship_to_email                     =>  p_int_line_tbl(l_count).ship_to_email,
          p_ship_to_phone                     =>  p_int_line_tbl(l_count).ship_to_phone,
          p_ship_to_fax                       =>  p_int_line_tbl(l_count).ship_to_fax,
          p_ship_from_cust_account_id         =>  p_int_line_tbl(l_count).ship_from_cust_account_id,
          p_ship_from_site_id                 =>  p_int_line_tbl(l_count).ship_from_site_id,
          p_ship_from_party_name              =>  p_int_line_tbl(l_count).ship_from_party_name,
          p_ship_from_location                =>  p_int_line_tbl(l_count).ship_from_location,
          p_ship_from_address                 =>  p_int_line_tbl(l_count).ship_from_address,
          p_ship_from_city                    =>  p_int_line_tbl(l_count).ship_from_city,
          p_ship_from_state                   =>  p_int_line_tbl(l_count).ship_from_state,
          p_ship_from_postal_code             =>  p_int_line_tbl(l_count).ship_from_postal_code,
          p_ship_from_country                 =>  p_int_line_tbl(l_count).ship_from_country,
          p_ship_from_contact_party_id        =>  p_int_line_tbl(l_count).ship_from_contact_party_id,
          p_ship_from_contact_name            =>  p_int_line_tbl(l_count).ship_from_contact_name,
          p_ship_from_email                   =>  p_int_line_tbl(l_count).ship_from_email,
          p_ship_from_phone                   =>  p_int_line_tbl(l_count).ship_from_phone,
          p_ship_from_fax                     =>  p_int_line_tbl(l_count).ship_from_fax,
          p_sold_from_cust_account_id         =>  p_int_line_tbl(l_count).sold_from_cust_account_id,
          p_sold_from_site_id                 =>  p_int_line_tbl(l_count).sold_from_site_id,
          p_sold_from_party_name              =>  p_int_line_tbl(l_count).sold_from_party_name,
          p_sold_from_location                =>  p_int_line_tbl(l_count).sold_from_location,
          p_sold_from_address                 =>  p_int_line_tbl(l_count).sold_from_address,
          p_sold_from_city                    =>  p_int_line_tbl(l_count).sold_from_city,
          p_sold_from_state                   =>  p_int_line_tbl(l_count).sold_from_state,
          p_sold_from_postal_code             =>  p_int_line_tbl(l_count).sold_from_postal_code,
          p_sold_from_country                 =>  p_int_line_tbl(l_count).sold_from_country,
          p_sold_from_contact_party_id        =>  p_int_line_tbl(l_count).sold_from_contact_party_id,
          p_sold_from_contact_name            =>  p_int_line_tbl(l_count).sold_from_contact_name,
          p_sold_from_email                   =>  p_int_line_tbl(l_count).sold_from_email,
          p_sold_from_phone                   =>  p_int_line_tbl(l_count).sold_from_phone,
          p_sold_from_fax                     =>  p_int_line_tbl(l_count).sold_from_fax,
          p_order_number                      =>  p_int_line_tbl(l_count).order_number,
          p_date_ordered                      =>  p_int_line_tbl(l_count).date_ordered,
          p_po_number                         =>  p_int_line_tbl(l_count).po_number,
          p_po_release_number                 =>  p_int_line_tbl(l_count).po_release_number,
          p_po_type                           =>  p_int_line_tbl(l_count).po_type,
          p_agreement_id                      =>  p_int_line_tbl(l_count).agreement_id,
          p_agreement_name                    =>  p_int_line_tbl(l_count).agreement_name,
          p_agreement_type                    =>  p_int_line_tbl(l_count).agreement_type,
          p_agreement_price                   =>  p_int_line_tbl(l_count).agreement_price,
          p_agreement_uom_code                =>  p_int_line_tbl(l_count).agreement_uom_code,
          p_corrected_agreement_id            =>  p_int_line_tbl(l_count).corrected_agreement_id,
          p_corrected_agreement_name          =>  p_int_line_tbl(l_count).corrected_agreement_name,
          p_price_list_id                     =>  p_int_line_tbl(l_count).price_list_id,
          p_price_list_name                   =>  p_int_line_tbl(l_count).price_list_name,
          p_orig_system_quantity              =>  p_int_line_tbl(l_count).orig_system_quantity,
          p_orig_system_uom                   =>  p_int_line_tbl(l_count).orig_system_uom,
          p_orig_system_currency_code         =>  p_int_line_tbl(l_count).orig_system_currency_code,
          p_orig_system_selling_price         =>  p_int_line_tbl(l_count).orig_system_selling_price,
          p_orig_system_reference             =>  p_int_line_tbl(l_count).orig_system_reference,
          p_orig_system_line_reference        =>  p_int_line_tbl(l_count).orig_system_line_reference,
          p_orig_system_purchase_uom          =>  p_int_line_tbl(l_count).orig_system_purchase_uom,
          p_orig_system_purchase_curr         =>  p_int_line_tbl(l_count).orig_system_purchase_curr,
          p_orig_system_purchase_price        =>  p_int_line_tbl(l_count).orig_system_purchase_price,
          p_orig_system_purchase_quant        =>  p_int_line_tbl(l_count).orig_system_purchase_quantity,
          p_orig_system_agreement_uom         =>  p_int_line_tbl(l_count).orig_system_agreement_uom,
          p_orig_system_agreement_name        =>  p_int_line_tbl(l_count).orig_system_agreement_name,
          p_orig_system_agreement_type        =>  p_int_line_tbl(l_count).orig_system_agreement_type,
          p_orig_system_agreement_status      =>  p_int_line_tbl(l_count).orig_system_agreement_status,
          p_orig_system_agreement_curr        =>  p_int_line_tbl(l_count).orig_system_agreement_curr,
          p_orig_system_agreement_price       =>  p_int_line_tbl(l_count).orig_system_agreement_price,
          p_orig_system_agreement_quant       =>  p_int_line_tbl(l_count).orig_system_agreement_quantity,
          p_orig_system_item_number           =>  p_int_line_tbl(l_count).orig_system_item_number,
          p_quantity                          =>  p_int_line_tbl(l_count).quantity,
          p_uom_code                          =>  p_int_line_tbl(l_count).uom_code,
          p_currency_code                     =>  p_int_line_tbl(l_count).currency_code,
          p_exchange_rate                     =>  p_int_line_tbl(l_count).exchange_rate,
          p_exchange_rate_type                =>  p_int_line_tbl(l_count).exchange_rate_type,
          p_exchange_rate_date                =>  p_int_line_tbl(l_count).exchange_rate_date,
          p_selling_price                     =>  p_int_line_tbl(l_count).selling_price,
          p_purchase_uom_code                 =>  p_int_line_tbl(l_count).purchase_uom_code,
          p_invoice_number                    =>  p_int_line_tbl(l_count).invoice_number,
          p_date_invoiced                     =>  p_int_line_tbl(l_count).date_invoiced,
          p_date_shipped                      =>  p_int_line_tbl(l_count).date_shipped,
          p_credit_advice_date                =>  p_int_line_tbl(l_count).credit_advice_date,
          p_product_category_id               =>  p_int_line_tbl(l_count).product_category_id,
          p_category_name                     =>  p_int_line_tbl(l_count).category_name,
          p_inventory_item_segment1           =>  p_int_line_tbl(l_count).inventory_item_segment1,
          p_inventory_item_segment2           =>  p_int_line_tbl(l_count).inventory_item_segment2,
          p_inventory_item_segment3           =>  p_int_line_tbl(l_count).inventory_item_segment3,
          p_inventory_item_segment4           =>  p_int_line_tbl(l_count).inventory_item_segment4,
          p_inventory_item_segment5           =>  p_int_line_tbl(l_count).inventory_item_segment5,
          p_inventory_item_segment6           =>  p_int_line_tbl(l_count).inventory_item_segment6,
          p_inventory_item_segment7           =>  p_int_line_tbl(l_count).inventory_item_segment7,
          p_inventory_item_segment8           =>  p_int_line_tbl(l_count).inventory_item_segment8,
          p_inventory_item_segment9           =>  p_int_line_tbl(l_count).inventory_item_segment9,
          p_inventory_item_segment10          =>  p_int_line_tbl(l_count).inventory_item_segment10,
          p_inventory_item_segment11          =>  p_int_line_tbl(l_count).inventory_item_segment11,
          p_inventory_item_segment12          =>  p_int_line_tbl(l_count).inventory_item_segment12,
          p_inventory_item_segment13          =>  p_int_line_tbl(l_count).inventory_item_segment13,
          p_inventory_item_segment14          =>  p_int_line_tbl(l_count).inventory_item_segment14,
          p_inventory_item_segment15          =>  p_int_line_tbl(l_count).inventory_item_segment15,
          p_inventory_item_segment16          =>  p_int_line_tbl(l_count).inventory_item_segment16,
          p_inventory_item_segment17          =>  p_int_line_tbl(l_count).inventory_item_segment17,
          p_inventory_item_segment18          =>  p_int_line_tbl(l_count).inventory_item_segment18,
          p_inventory_item_segment19          =>  p_int_line_tbl(l_count).inventory_item_segment19,
          p_inventory_item_segment20          =>  p_int_line_tbl(l_count).inventory_item_segment20,
          p_inventory_item_id                 =>  p_int_line_tbl(l_count).inventory_item_id,
          p_item_description                  =>  p_int_line_tbl(l_count).item_description,
          p_upc_code                          =>  p_int_line_tbl(l_count).upc_code,
          p_item_number                       =>  p_int_line_tbl(l_count).item_number,
          p_claimed_amount                    =>  p_int_line_tbl(l_count).claimed_amount,
          p_purchase_price                    =>  p_int_line_tbl(l_count).purchase_price,
          p_acctd_purchase_price              =>  p_int_line_tbl(l_count).acctd_purchase_price,
          p_net_adjusted_amount               =>  p_int_line_tbl(l_count).net_adjusted_amount,
          p_accepted_amount                   =>  p_int_line_tbl(l_count).accepted_amount,
          p_total_accepted_amount             =>  p_int_line_tbl(l_count).total_accepted_amount,
          p_allowed_amount                    =>  p_int_line_tbl(l_count).allowed_amount,
          p_total_allowed_amount              =>  p_int_line_tbl(l_count).total_allowed_amount,
          p_calculated_price                  =>  p_int_line_tbl(l_count).calculated_price,
          p_acctd_calculated_price            =>  p_int_line_tbl(l_count).acctd_calculated_price,
          p_calculated_amount                 =>  p_int_line_tbl(l_count).calculated_amount,
          p_line_tolerance_amount             =>  p_int_line_tbl(l_count).line_tolerance_amount,
          p_total_claimed_amount              =>  p_int_line_tbl(l_count).total_claimed_amount,
          p_credit_code                       =>  p_int_line_tbl(l_count).credit_code,
          p_direct_customer_flag              =>  p_int_line_tbl(l_count).direct_customer_flag,
          p_duplicated_line_id                =>  p_int_line_tbl(l_count).duplicated_line_id,
          p_duplicated_adjustment_id          =>  p_int_line_tbl(l_count).duplicated_adjustment_id,
          p_order_type_id                     =>  p_int_line_tbl(l_count).order_type_id,
          p_order_type                        =>  p_int_line_tbl(l_count).order_type,
          p_order_category                    =>  p_int_line_tbl(l_count).order_category,
          p_dispute_code                      =>  p_int_line_tbl(l_count).dispute_code,
          p_data_source_code                     =>  p_int_line_tbl(l_count).data_source_code,
          p_tracing_flag                      =>  p_int_line_tbl(l_count).tracing_flag,
          p_header_attribute_category         =>  p_int_line_tbl(l_count).header_attribute_category,
          p_header_attribute1                 =>  p_int_line_tbl(l_count).header_attribute1,
          p_header_attribute2                 =>  p_int_line_tbl(l_count).header_attribute2,
          p_header_attribute3                 =>  p_int_line_tbl(l_count).header_attribute3,
          p_header_attribute4                 =>  p_int_line_tbl(l_count).header_attribute4,
          p_header_attribute5                 =>  p_int_line_tbl(l_count).header_attribute5,
          p_header_attribute6                 =>  p_int_line_tbl(l_count).header_attribute6,
          p_header_attribute7                 =>  p_int_line_tbl(l_count).header_attribute7,
          p_header_attribute8                 =>  p_int_line_tbl(l_count).header_attribute8,
          p_header_attribute9                 =>  p_int_line_tbl(l_count).header_attribute9,
          p_header_attribute10                =>  p_int_line_tbl(l_count).header_attribute10,
          p_header_attribute11                =>  p_int_line_tbl(l_count).header_attribute11,
          p_header_attribute12                =>  p_int_line_tbl(l_count).header_attribute12,
          p_header_attribute13                =>  p_int_line_tbl(l_count).header_attribute13,
          p_header_attribute14                =>  p_int_line_tbl(l_count).header_attribute14,
          p_header_attribute15                =>  p_int_line_tbl(l_count).header_attribute15,
          p_line_attribute_category           =>  p_int_line_tbl(l_count).line_attribute_category,
          p_line_attribute1                   =>  p_int_line_tbl(l_count).line_attribute1,
          p_line_attribute2                   =>  p_int_line_tbl(l_count).line_attribute2,
          p_line_attribute3                   =>  p_int_line_tbl(l_count).line_attribute3,
          p_line_attribute4                   =>  p_int_line_tbl(l_count).line_attribute4,
          p_line_attribute5                   =>  p_int_line_tbl(l_count).line_attribute5,
          p_line_attribute6                   =>  p_int_line_tbl(l_count).line_attribute6,
          p_line_attribute7                   =>  p_int_line_tbl(l_count).line_attribute7,
          p_line_attribute8                   =>  p_int_line_tbl(l_count).line_attribute8,
          p_line_attribute9                   =>  p_int_line_tbl(l_count).line_attribute9,
          p_line_attribute10                  =>  p_int_line_tbl(l_count).line_attribute10,
          p_line_attribute11                  =>  p_int_line_tbl(l_count).line_attribute11,
          p_line_attribute12                  =>  p_int_line_tbl(l_count).line_attribute12,
          p_line_attribute13                  =>  p_int_line_tbl(l_count).line_attribute13,
          p_line_attribute14                  =>  p_int_line_tbl(l_count).line_attribute14,
          p_line_attribute15                  =>  p_int_line_tbl(l_count).line_attribute15,
          p_org_id                            =>  p_int_line_tbl(l_count).org_id );


      END LOOP;
    END IF;
       EXCEPTION

          WHEN OTHERS THEN
             OZF_UTILITY_PVT.error_message('OZF_API_DEBUG_MESSAGE','TEXT','Problem with updating line record'||sqlcode ||' '||sqlerrm);
             RAISE FND_API.G_EXC_ERROR;

       END;

         -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;


     -- Debug Message
     IF OZF_DEBUG_HIGH_ON THEN
        ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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


END Update_interface_line;


procedure Update_interface_batch (
   p_api_version_number    IN    NUMBER,
   p_init_msg_list         IN    VARCHAR2     := FND_API.G_FALSE,
   p_Commit                IN    VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN    NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_int_batch_rec         IN    ozf_resale_batches_all%rowtype,
   x_return_status         OUT   NOCOPY VARCHAR2,
   x_msg_count             OUT   NOCOPY NUMBER,
   x_msg_data              OUT   NOCOPY VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'update_interface_batch';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
BEGIN
       -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('x_return_status '||x_return_status);
   END IF;

   BEGIN
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('Resale Batch ID ' || p_int_batch_rec.resale_batch_id);
      END IF;
         OZF_RESALE_BATCHES_PKG.Update_Row(
          p_resale_batch_id                =>   p_int_batch_rec.resale_batch_id,
          p_object_version_number          =>   p_int_batch_rec.object_version_number ,
          p_last_update_date               =>   p_int_batch_rec.last_update_date,
          p_last_updated_by                =>   p_int_batch_rec.last_updated_by,
          p_request_id                     =>   p_int_batch_rec.request_id,
          p_created_from                   =>   p_int_batch_rec.created_from,
          p_last_update_login              =>   p_int_batch_rec.last_update_login,
          p_program_application_id         =>   p_int_batch_rec.program_application_id,
          p_program_update_date            =>   p_int_batch_rec.program_update_date,
          p_program_id                     =>   p_int_batch_rec.program_id,
          p_batch_number                   =>   p_int_batch_rec.batch_number,
          p_batch_type                     =>   p_int_batch_rec.batch_type,
          p_batch_count                    =>   p_int_batch_rec.batch_count,
          p_year                           =>   p_int_batch_rec.year,
          p_month                          =>   p_int_batch_rec.month,
          p_report_date                    =>   p_int_batch_rec.report_date,
          p_report_start_date              =>   p_int_batch_rec.report_start_date,
          p_report_end_date                =>   p_int_batch_rec.report_end_date,
          p_status_code                    =>   p_int_batch_rec.status_code,
          -- p_date_source_code               =>   p_int_batch_rec.data_source_code, -- BUG 5077213
          p_reference_type                 =>   p_int_batch_rec.reference_type,
          p_reference_number               =>   p_int_batch_rec.reference_number,
          p_comments                       =>   p_int_batch_rec.comments,
          p_partner_claim_number           =>   p_int_batch_rec.partner_claim_number,
          p_transaction_purpose_code       =>   p_int_batch_rec.transaction_purpose_code,
          p_transaction_type_code          =>   p_int_batch_rec.transaction_type_code,
          p_partner_type                   =>   p_int_batch_rec.partner_type,
          p_partner_id                     =>   p_int_batch_rec.partner_id,
          p_partner_party_id               =>   p_int_batch_rec.partner_party_id,
          p_partner_cust_account_id        =>   p_int_batch_rec.partner_cust_account_id,
          p_partner_site_id                =>   p_int_batch_rec.partner_site_id,
          p_partner_contact_party_id       =>   p_int_batch_rec.partner_contact_party_id,
          p_partner_contact_name           =>   p_int_batch_rec.partner_contact_name,
          p_partner_email                  =>   p_int_batch_rec.partner_email,
          p_partner_phone                  =>   p_int_batch_rec.partner_phone,
          p_partner_fax                    =>   p_int_batch_rec.partner_fax,
          p_header_tolerance_operand       =>   p_int_batch_rec.header_tolerance_operand,
          p_header_tolerance_calc_code     =>   p_int_batch_rec.header_tolerance_calc_code,
          p_line_tolerance_operand         =>   p_int_batch_rec.line_tolerance_operand,
          p_line_tolerance_calc_code       =>   p_int_batch_rec.line_tolerance_calc_code,
          p_currency_code                  =>   p_int_batch_rec.currency_code,
          p_claimed_amount                 =>   p_int_batch_rec.claimed_amount,
          p_allowed_amount                 =>   p_int_batch_rec.allowed_amount,
          p_paid_amount                    =>   p_int_batch_rec.paid_amount,
          p_disputed_amount                =>   p_int_batch_rec.disputed_amount,
          p_accepted_amount                =>   p_int_batch_rec.accepted_amount,
          p_lines_invalid                  =>   p_int_batch_rec.lines_invalid,
          p_lines_w_tolerance              =>   p_int_batch_rec.lines_w_tolerance,
          p_lines_disputed                 =>   p_int_batch_rec.lines_disputed,
          p_batch_set_id_code              =>   p_int_batch_rec.batch_set_id_code,
          p_credit_code                    =>   p_int_batch_rec.credit_code,
          p_credit_advice_date             =>   p_int_batch_rec.credit_advice_date,
          p_purge_flag                     =>   p_int_batch_rec.purge_flag,
          p_attribute_category             =>   p_int_batch_rec.attribute_category,
          p_attribute1                     =>   p_int_batch_rec.attribute1,
          p_attribute2                     =>   p_int_batch_rec.attribute2,
          p_attribute3                     =>   p_int_batch_rec.attribute3,
          p_attribute4                     =>   p_int_batch_rec.attribute4,
          p_attribute5                     =>   p_int_batch_rec.attribute5,
          p_attribute6                     =>   p_int_batch_rec.attribute6,
          p_attribute7                     =>   p_int_batch_rec.attribute7,
          p_attribute8                     =>   p_int_batch_rec.attribute8,
          p_attribute9                     =>   p_int_batch_rec.attribute9,
          p_attribute10                    =>   p_int_batch_rec.attribute10,
          p_attribute11                    =>   p_int_batch_rec.attribute11,
          p_attribute12                    =>   p_int_batch_rec.attribute12,
          p_attribute13                    =>   p_int_batch_rec.attribute13,
          p_attribute14                    =>   p_int_batch_rec.attribute14,
          p_attribute15                    =>   p_int_batch_rec.attribute15,
          p_org_id                         =>   p_int_batch_rec.org_id  );

       EXCEPTION

          WHEN OTHERS THEN
             OZF_UTILITY_PVT.error_message('OZF_API_DEBUG_MESSAGE','TEXT','Problem with updating batch record'||sqlcode ||' '||sqlerrm);
             RAISE FND_API.G_EXC_ERROR;

       END;

         -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit )
     THEN
         COMMIT WORK;
     END IF;
     -- Debug Message
     IF OZF_DEBUG_HIGH_ON THEN
        ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
END update_interface_batch;

PROCEDURE Confirm_BOD_Enabled
(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Confirm_BOD_Enabled';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_trans_type      ecx_tp_details_v.transaction_type%TYPE;
   l_trans_subtype   ecx_tp_details_v.transaction_subtype%TYPE;
   l_party_id        ecx_tp_headers_v.party_id%TYPE;
   l_party_site_id   ecx_tp_headers_v.party_site_id%TYPE;
   l_resale_batch_id NUMBER;

   l_enabled         NUMBER;
   l_admin_email     VARCHAR2(1000);

   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_return_status       VARCHAR2(1);
   CURSOR get_confirmation (  pc_party_id NUMBER
                            , pc_site_id  NUMBER
                            , pc_transaction_type VARCHAR2
                            , pc_txn_sub_type VARCHAR2 )
   IS
     SELECT etd.confirmation, eth.company_admin_email
       FROM ecx_tp_headers_v eth
          , ecx_tp_details_v etd
       WHERE eth.tp_header_id = etd.tp_header_id
         AND eth.party_id  = pc_party_id
         AND eth.party_site_id = pc_site_id
         AND etd.transaction_type = pc_transaction_type
         AND etd.transaction_subtype = pc_txn_sub_type;

  CURSOR get_party ( pc_batch_id NUMBER )
  IS
    SELECT partner_party_id
         , partner_site_id
      FROM ozf_resale_batches
     WHERE resale_batch_id = pc_batch_id;



BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('In: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

  IF (funcmode = 'RUN') THEN

    l_party_id       := wf_engine.GetItemAttrText(itemtype =>itemtype,
                                                  itemkey =>itemkey,
                                                  aname =>'PARAMETER2');

    l_party_site_id  := wf_engine.GetItemAttrText(itemtype =>itemtype,
                                                  itemkey =>itemkey,
                                                  aname =>'PARAMETER3');

    l_trans_type     := wf_engine.GetItemAttrText(itemtype =>itemtype,
                                                  itemkey =>itemkey,
                                                  aname =>'PARAMETER4');

    l_trans_subtype  := wf_engine.GetItemAttrText(itemtype =>itemtype,
                                                  itemkey =>itemkey,
                                                  aname =>'PARAMETER5');

    IF  l_party_id IS NULL AND l_party_site_id IS NULL THEN
        l_resale_batch_id    := wf_engine.GetItemAttrText(itemtype =>itemtype,
                                                          itemkey =>itemkey,
                                                          aname =>'PARAMETER1');
        IF   l_resale_batch_id IS NOT NULL THEN
             OPEN   get_party ( l_resale_batch_id );
             FETCH  get_party INTO  l_party_id, l_party_site_id ;
             CLOSE  get_party;
        END IF;
        l_trans_type       := 'OZF';
        l_trans_subtype    := 'POSI';

    END IF;

    OPEN   get_confirmation ( l_party_id
                            , l_party_site_id
                            , l_trans_type
                            , l_trans_subtype);
    FETCH  get_confirmation INTO  l_enabled, l_admin_email;
    CLOSE  get_confirmation;

  END IF;
  IF (l_enabled = 0 or l_enabled= 1) THEN
     result := 'F';
  ELSE
    result := 'T';

    Wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'ECX_ADMINISTRATOR',
                              avalue   => l_admin_email);

  END IF;

  return;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END Confirm_BOD_Enabled;

PROCEDURE Send_Success_CBOD
(
    itemtype  in VARCHAR2,
    itemkey   in VARCHAR2,
    actid     in NUMBER,
    funcmode  in VARCHAR2,
    result    in out NOCOPY VARCHAR2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Send_Success_CBOD';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_event_name      VARCHAR2(120);
   l_icn             NUMBER;
   l_event_key       VARCHAR2(30);
   l_msg_count       NUMBER;
   l_msg_data        VARCHAR2(2000);
   l_return_status   VARCHAR2(1);

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('In: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;
   IF( funcmode = 'RUN' )  THEN

     l_event_key :=   wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'EVENTKEY');


     raise_event
    (
      p_batch_id            =>   to_number(l_event_key),
      p_event_name          =>   g_xml_confirm_bod_event,
      x_return_status       =>   l_return_status
    );

   result := 'COMPLETE';

 ELSIF (funcmode = 'CANCEL') THEN
      result := 'COMPLETE';

 ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      result := 'COMPLETE';

 ELSIF (funcmode = 'TIMEOUT') THEN
      result := 'COMPLETE';

 END IF;
 return;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END Send_Success_CBOD;

PROCEDURE Send_Outbound
(
   itemtype   IN VARCHAR2,
   itemkey    IN VARCHAR2,
   actid      IN NUMBER,
   funcmode   IN VARCHAR2,
   resultout  IN OUT NOCOPY VARCHAR2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Send_Outbound';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_batch_status        VARCHAR2(30);
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('In: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   IF (funcmode = 'RUN') THEN

     IF  itemtype = g_xml_import_workflow THEN

        l_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'PARAMETER1');

     ELSIF  itemtype = g_data_process_workflow THEN

        l_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'OZF_RESALE_BATCH_ID');

     END IF;
     IF OZF_DEBUG_LOW_ON THEN
        ozf_utility_pvt.debug_message('Batch ID '|| l_batch_id);
     END IF;
      IF l_batch_id IS NOT NULL THEN

          raise_event
         (
           p_batch_id            =>   l_batch_id ,
           p_event_name          =>   g_xml_outbound_event ,
           x_return_status       =>   l_return_status
         );
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('Pre Process is complete '||l_return_status);
         END IF;

      END IF;

      l_resultout := 'COMPLETE:SUCCESS';

 ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:SUCCESS';

 ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:SUCCESS';

 ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:SUCCESS';

 END IF;

 resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END Send_Outbound;

PROCEDURE Raise_data_process
(
   itemtype   IN VARCHAR2,
   itemkey    IN VARCHAR2,
   actid      IN NUMBER,
   funcmode   IN VARCHAR2,
   resultout  IN OUT NOCOPY VARCHAR2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Raise_data_process';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_batch_status        VARCHAR2(30);
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('In: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   IF (funcmode = 'RUN') THEN

      l_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'PARAMETER1');
      IF OZF_DEBUG_LOW_ON THEN
         ozf_utility_pvt.debug_message('Batch ID '|| l_batch_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN

          raise_event
         (
           p_batch_id            =>   l_batch_id ,
           p_event_name          =>   g_xml_data_process_event ,
           x_return_status       =>   l_return_status
         );
         IF OZF_DEBUG_LOW_ON THEN
            ozf_utility_pvt.debug_message('Pre Process is complete '||l_return_status);
         END IF;

      END IF;

      l_resultout := 'COMPLETE';

 ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE';

 ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE';

 ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE';

 END IF;

 resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END Raise_data_process;


PROCEDURE raise_event
(
  p_batch_id            IN  NUMBER,
  p_event_name          IN  VARCHAR2,
  x_return_status       OUT NOCOPY VARCHAR2
)
IS

   l_api_name              CONSTANT VARCHAR2(30) := 'raise_event';
   l_api_version_number    CONSTANT NUMBER   := 1.0;

   l_event_name            VARCHAR2 (120);
   l_event_key             VARCHAR2 (100);

   l_Return_Status         VARCHAR2 (1);
   l_transaction_code      VARCHAR2 (100);
   l_org_id                NUMBER;
   l_party_id              NUMBER;
   l_party_site_id         NUMBER;
   l_confirm_descrtn       VARCHAR2 (4000);
   l_msg_parameter_list    WF_PARAMETER_LIST_T;

   CURSOR get_batch ( pc_batch_id NUMBER)
   IS
     SELECT partner_party_id
          , partner_site_id
       FROM ozf_resale_batches
      WHERE resale_batch_id =  pc_batch_id;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_pvt.debug_message('p_batch_id ' || p_batch_id);
      ozf_utility_pvt.debug_message('Event : ' || p_event_name || ' start');
   END IF;

   IF p_batch_id IS NOT NULL THEN
      -- XML Outbound Event

      IF   p_event_name = g_xml_outbound_event THEN
         OPEN  get_batch ( p_batch_id );
         FETCH get_batch INTO  l_party_id, l_party_site_id;
         CLOSE get_batch;


         IF  l_party_id IS NOT NULL AND l_party_site_id IS NOT NULL THEN

             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_ID',
                                          p_value => l_party_id,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARTY_SITE_ID',
                                          p_value => l_party_site_id,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'DOCUMENT_ID',
                                          p_value => p_batch_id,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_TYPE',
                                          p_value => 'OZF',
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_TRANSACTION_SUBTYPE',
                                          p_value => 'POSO',
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER1',
                                          p_value => null,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER2',
                                          p_value => null,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER3',
                                          p_value => null,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER4',
                                          p_value => null,
                                          p_parameterlist => l_msg_parameter_list);
             WF_EVENT.AddParameterToList (p_name  => 'ECX_PARAMETER5',
                                          p_value => null,
                                          p_parameterlist => l_msg_parameter_list);

             WF_EVENT.AddParameterToList(p_name=>'ECX_DEBUG_LEVEL',
                                         p_value=>'3',
                                         p_parameterlist=>l_msg_parameter_list);

             l_event_key :=  p_batch_id||'-POSO-'||to_char(sysdate,'MM/DD/YYYY HH:MI:SS');

         END IF;
      END IF;
      IF p_event_name = g_xml_data_process_event  THEN

          WF_EVENT.AddParameterToList( p_name            => 'OZF_RESALE_BATCH_ID',
                                       p_value           => p_batch_id,
                                       p_parameterlist   => l_msg_parameter_list);

          WF_EVENT.AddParameterToList( p_name            => 'OZF_RESALE_BATCH_CALLER',
                                       p_value           => 'XML',
                                       p_parameterlist   => l_msg_parameter_list);
          IF p_event_name = g_xml_data_process_event THEN
             l_event_key   :=  p_batch_id ||'-'||to_char(sysdate,'MM/DD/YYYY HH:MI:SS');
          ELSE
             l_event_key   :=  'Payment - '||p_batch_id ||'-'||to_char(sysdate,'MM/DD/YYYY HH:MI:SS');
          END IF;
      END IF;
      IF p_event_name = g_webadi_data_process_event  THEN

          WF_EVENT.AddParameterToList( p_name            => 'OZF_RESALE_BATCH_ID',
                                       p_value           => p_batch_id,
                                       p_parameterlist   => l_msg_parameter_list);

          WF_EVENT.AddParameterToList( p_name            => 'OZF_RESALE_BATCH_CALLER',
                                       p_value           => 'WEBADI',
                                       p_parameterlist   => l_msg_parameter_list);

          l_event_key   :=  p_batch_id ||'-'||to_char(sysdate,'MM/DD/YYYY HH:MI:SS');

      END IF;

      IF  p_event_name =  g_xml_confirm_bod_event THEN

          WF_EVENT.AddParameterToList( p_name=>'ECX_TRANSACTION_TYPE',
                                       p_value=>'ECX',
                                       p_parameterlist=>l_msg_parameter_list);

          WF_EVENT.AddParameterToList( p_name=>'ECX_TRANSACTION_SUBTYPE',
                                       p_value=>'CBODO',
                                       p_parameterlist=>l_msg_parameter_list);


          WF_EVENT.AddParameterToList( p_name=>'CONFIRM_STATUSLVL',
                                       p_value=>'00',
                                       p_parameterlist=>l_msg_parameter_list);

          FND_MESSAGE.set_name('OZF', 'OZF_XML_CONFIRM_INBOUND');
          l_confirm_descrtn := FND_MESSAGE.get;

          WF_EVENT.AddParameterToList( p_name=>'CONFIRM_DESCRTN',
                                       p_value=>l_confirm_descrtn,
                                       p_parameterlist=>l_msg_parameter_list);


          WF_EVENT.AddParameterToList( p_name=>'ECX_DEBUG_LEVEL',
                                       p_value=>'3',
                                       p_parameterlist=>l_msg_parameter_list);

          WF_EVENT.AddParameterToList( p_name=>'ECX_DOCUMENT_ID',
                                       p_value=>p_batch_id,
                                       p_parameterlist=>l_msg_parameter_list);



          l_event_key := p_batch_id||'CBODO';
      END IF;

      WF_EVENT.raise ( p_event_name => p_event_name,
                       p_event_key  => l_event_key,
                       p_parameters => l_msg_parameter_list );

   END IF;
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message('Private API: ' || l_api_name || ' end');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN

        OZF_UTILITY_PVT.error_message('OZF_API_DEBUG_MESSAGE','TEXT',sqlcode ||' '||sqlerrm);
         x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
END raise_event;


PROCEDURE Insert_Resale_Log (
  p_id_value      IN VARCHAR2,
  p_id_type       IN VARCHAR2,
  p_error_code    IN VARCHAR2,
  p_column_name   IN VARCHAR2,
  p_column_value  IN VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2 )
IS
  l_api_name                  CONSTANT VARCHAR2(30) := 'Insert_Resale_Log';
  l_api_version_number        CONSTANT NUMBER   := 1.0;
  l_log_id                    NUMBER;
  l_org_id                    NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message(l_api_name||': Start');
   END IF;
   --
   IF p_error_code IS NOT NULL THEN
      BEGIN

      SELECT ozf_resale_logs_all_s.nextval into l_log_id from dual;

      -- julou bug 6317120. get org_id from table
      IF p_id_type = 'BATCH' THEN
        OPEN  OZF_RESALE_COMMON_PVT.gc_batch_org_id(p_id_value);
        FETCH OZF_RESALE_COMMON_PVT.gc_batch_org_id INTO l_org_id;
        CLOSE OZF_RESALE_COMMON_PVT.gc_batch_org_id;
      ELSIF p_id_type = 'LINE' THEN
        OPEN  OZF_RESALE_COMMON_PVT.gc_line_org_id(p_id_value);
        FETCH OZF_RESALE_COMMON_PVT.gc_line_org_id INTO l_org_id;
        CLOSE OZF_RESALE_COMMON_PVT.gc_line_org_id;
      ELSIF p_id_type = 'IFACE' THEN
        OPEN  OZF_RESALE_COMMON_PVT.gc_iface_org_id(p_id_value);
        FETCH OZF_RESALE_COMMON_PVT.gc_iface_org_id INTO l_org_id;
        CLOSE OZF_RESALE_COMMON_PVT.gc_iface_org_id;
      END IF;

      OZF_RESALE_LOGS_PKG.Insert_Row(
         px_resale_log_id           => l_log_id,
         p_resale_id                => p_id_value,
         p_resale_id_type           => p_id_type,
         p_error_code               => p_error_code,
         p_error_message            => fnd_message.get_string('OZF',p_error_code),
         p_column_name              => p_column_name,
         p_column_value             => p_column_value,
         --px_org_id                  => OZF_RESALE_COMMON_PVT.g_org_id
         px_org_id                  => l_org_id
      );
      EXCEPTION
         WHEN OTHERS THEN
            OZF_UTILITY_PVT.error_message('OZF_INS_RESALE_LOG_WRG');
            RAISE FND_API.g_exc_unexpected_error;
      END;
   END IF;
   --
   IF OZF_DEBUG_HIGH_ON THEN
      ozf_utility_pvt.debug_message(l_api_name||': End');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Insert_Resale_Log;

END OZF_PRE_PROCESS_PVT;

/
