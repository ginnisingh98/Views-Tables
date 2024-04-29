--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_PUB" AS
/* $Header: ozfprssb.pls 120.3 2005/10/10 11:46:30 mchang ship $ */

-- Package name     : OZF_RESALE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_RESALE_PUB';
G_FILE_NAME     CONSTANT VARCHAR2(30) := 'ozfprssb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  BOOLEAN  := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Process_Iface
--
-- PURPOSE
--    This procedure to initiate data process of records in resales table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Process_Iface (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2
   ,p_commit                 IN  VARCHAR2
   ,p_validation_level       IN  NUMBER
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_Process_Iface';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR csr_batch_org_id(cv_resale_batch_id IN NUMBER) IS
  SELECT org_id
  FROM ozf_resale_batches_all
  WHERE resale_batch_id = cv_resale_batch_id;

l_resale_org_id               NUMBER;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  PROCESS_IFACE_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- R12 MOAC Enhancement (+)
   OPEN csr_batch_org_id(p_resale_batch_id);
   FETCH csr_batch_org_id INTO l_resale_org_id;
   CLOSE csr_batch_org_id;

   IF l_resale_org_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ORG_ID_NOTFOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   MO_GLOBAL.set_policy_context('S', l_resale_org_id);
   -- R12 MOAC Enhancement (-)

   BEGIN
      OZF_RESALE_WF_PVT.Start_Data_Process(
          p_resale_batch_id   => p_resale_batch_id
         ,p_caller_type       => 'UI'
      );
   EXCEPTION
      WHEN OTHERS THEN
         RAISE FND_API.g_exc_unexpected_error;
   END;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': end');
   END IF;

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO PROCESS_IFACE_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO PROCESS_IFACE_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO PROCESS_IFACE_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
      );

END Start_Process_Iface;


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Payment
--
-- PURPOSE
--    This procedure to initiate batch payment
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Payment (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2
   ,p_commit                 IN  VARCHAR2
   ,p_validation_level       IN  NUMBER
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_Payment';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     VARCHAR2(30);
l_msg_data          VARCHAR2(2000);
l_msg_count         NUMBER;

CURSOR csr_batch_org_id(cv_resale_batch_id IN NUMBER) IS
  SELECT org_id
  FROM ozf_resale_batches_all
  WHERE resale_batch_id = cv_resale_batch_id;

l_resale_org_id               NUMBER;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  BATCH_PAYMENT_PUB;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- R12 MOAC Enhancement (+)
   OPEN csr_batch_org_id(p_resale_batch_id);
   FETCH csr_batch_org_id INTO l_resale_org_id;
   CLOSE csr_batch_org_id;

   IF l_resale_org_id IS NULL THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('OZF', 'OZF_ORG_ID_NOTFOUND');
         FND_MSG_PUB.add;
      END IF;
      RAISE FND_API.g_exc_error;
   END IF;

   MO_GLOBAL.set_policy_context('S', l_resale_org_id);
   -- R12 MOAC Enhancement (-)

   BEGIN
      OZF_RESALE_WF_PVT.Start_Batch_Payment(
          p_resale_batch_id   => p_resale_batch_id
         ,p_caller_type       => 'UI'
      );
   EXCEPTION
      WHEN OTHERS THEN
         RAISE FND_API.g_exc_unexpected_error;
   END;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;


   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': end');
   END IF;

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO BATCH_PAYMENT_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO BATCH_PAYMENT_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO BATCH_PAYMENT_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Start_Payment;



---------------------------------------------------------------------
-- PROCEDURE
--    Start_Purge
--
-- PURPOSE
--    Purge the successfully processed records
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Start_Purge
(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2
   ,p_commit                 IN    VARCHAR2
   ,p_validation_level       IN    NUMBER
   ,p_data_source_code       IN    VARCHAR2
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_Purge';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  RESALE_PURGE_PUB;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
     l_api_version,
     p_api_version,
     l_api_name,
     G_PKG_NAME)
   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OZF_RESALE_PVT.Purge(
       p_api_version       => 1.0
      ,p_init_msg_list     => p_init_msg_list
      ,p_commit            => FND_API.g_false
      ,p_validation_level  => p_validation_level
      ,p_data_source_code  => p_data_source_code
      ,x_return_status     => l_return_status
      ,x_msg_data          => l_msg_data
      ,x_msg_count         => l_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_LOW_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data
   );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO RESALE_PURGE_PUB ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  RESALE_PURGE_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
   WHEN OTHERS THEN
        ROLLBACK TO RESALE_PURGE_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END Start_Purge;

END OZF_RESALE_PUB;

/
