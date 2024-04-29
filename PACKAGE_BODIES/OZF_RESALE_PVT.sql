--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_PVT" AS
/* $Header: ozfvrssb.pls 120.6.12010000.3 2010/03/04 06:17:14 hbandi ship $ */

-- Package name     : OZF_RESALE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OZF_RESALE_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(30) := 'ozfvssb.pls';

OZF_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON  BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

CURSOR g_org_id_csr(p_id number) IS
SELECT org_id
  FROM ozf_resale_batches_all
 WHERE resale_batch_id = p_id;


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment
--
-- PURPOSE
--    This procedure to initiate payment process for a batch.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Initiate_Payment (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Initiate_Payment';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;

l_batch_type        varchar2(30);
l_org_id            number;
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  INITIATE_PAYMENT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN g_org_id_csr (p_resale_batch_id);
   FETCH g_org_id_csr into l_org_id;
   CLOSE g_org_id_csr;

   IF l_org_id is not null THEN
      fnd_client_info.set_org_context(to_char(l_org_id));
   ELSE
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OPEN OZF_RESALE_COMMON_PVT.g_batch_type_csr(p_resale_batch_id);
   FETCH OZF_RESALE_COMMON_PVT.g_batch_type_csr into l_batch_type;
   CLOSE OZF_RESALE_COMMON_PVT.g_batch_type_csr;

   IF l_batch_type is null THEN
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_BATCH_TYPE_NULL');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_batch_type = OZF_RESALE_COMMON_PVT.G_CHARGEBACK THEN

      OZF_CHARGEBACK_PVT.Initiate_Payment(
          p_api_version     => 1
         ,p_init_msg_list   => FND_API.G_FALSE
         ,p_commit          => FND_API.G_FALSE
         ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id => p_resale_batch_id
         ,x_return_status   => l_return_status
         ,x_msg_data        => l_msg_data
         ,x_msg_count       => l_msg_count
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_CHBK_PAYMNT_ERR');
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_CHBK_PAYMNT_ERR');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_SPECIAL_PRICING THEN

      OZF_SPECIAL_PRICING_PVT.Initiate_Payment(
          p_api_version     => 1
         ,p_init_msg_list   => FND_API.G_FALSE
         ,p_commit          => FND_API.G_FALSE
         ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id => p_resale_batch_id
         ,x_return_status   => l_return_status
         ,x_msg_data        => l_msg_data
         ,x_msg_count       => l_msg_count
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_SPP_PAYMNT_ERR');
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_SPP_PAYMNT_ERR');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_TRACING  THEN

      OZF_TRACING_ORDER_PVT.Initiate_Payment(
          p_api_version     => 1
         ,p_init_msg_list   => FND_API.G_FALSE
         ,p_commit          => FND_API.G_FALSE
         ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id => p_resale_batch_id
         ,x_return_status   => l_return_status
         ,x_msg_data        => l_msg_data
         ,x_msg_count       => l_msg_count
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_TRAC_PAYMNT_ERR');
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_TRAC_PAYMNT_ERR');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
     OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
     p_encoded => FND_API.G_FALSE,
     p_count => x_msg_count,
     p_data  => x_msg_data
   );
   x_return_status := l_return_status;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO INITIATE_PAYMENT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO INITIATE_PAYMENT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
   WHEN OTHERS THEN
      ROLLBACK TO INITIATE_PAYMENT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count => x_msg_count,
         p_data  => x_msg_data
      );
END Initiate_Payment;

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_WFL
--
-- PURPOSE
--    This procedure is called by a workflow to allow user to start the data process
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_WFL(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Initiate_Payment_WFL';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
   l_resultout           VARCHAR2(30);
   l_resale_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   l_error_msg   varchar2(4000);
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   IF (funcmode = 'RUN') THEN
      l_resale_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'RESALE_BATCH_ID');
      Initiate_Payment (
          p_api_version      => 1.0
         ,p_init_msg_list    => FND_API.G_FALSE
         ,p_commit           => FND_API.G_FALSE
         ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id  => l_resale_batch_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => l_msg_data
         ,x_msg_count        => l_msg_count
      );
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('subscribe process iface is complete ');
      END IF;
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:Y';
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:Y';

   ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:Y';

   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:Y';
   END IF;
   resultout := l_resultout;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );

     WF_CORE.context(
         'OZF_RESALE_PVT'
        ,'INITIATE_PAYMENT_WFL'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:N';
     RETURN;

   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);
      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END Initiate_Payment_WFL;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Iface
--
-- PURPOSE
--    This procedure to initiate data process of records in resales table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Iface (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name        CONSTANT VARCHAR2(30) := 'Process_Iface';
l_api_version     CONSTANT NUMBER := 1.0;
l_full_name       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status   varchar2(30);
l_msg_data        varchar2(2000);
l_msg_count       number;
--
l_batch_status    VARCHAR2(30);
l_batch_count     number;

l_batch_type      varchar2(30);
i                 number;
l_open_lines_tbl  OZF_RESALE_COMMON_PVT.interface_lines_tbl_type;
--
l_disputed_count number;
l_duplicate_count number;
l_dup_line_id number;
l_dup_adjustment_id number;
l_reprocessing boolean;
l_org_id number;
--
/*
CURSOR open_lines_csr(p_id IN NUMBER) IS
SELECT *
  FROM ozf_resale_lines_int
 WHERE status_code =OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
   AND resale_batch_id = p_id;
*/

CURSOR batch_count_csr(pc_batch_id NUMBER) IS
SELECT NVL(batch_count,0)
  FROM ozf_resale_batches
 WHERE resale_batch_id = pc_batch_id;

CURSOR duplicate_count_csr(p_id NUMBER) IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DUPLICATED
   AND resale_batch_id = p_id;

CURSOR disputed_count_csr(p_id number) IS
SELECT count(1)
  FROM ozf_resale_lines_int
 WHERE status_code = OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_DISPUTED
   AND resale_batch_id = p_id;
--
BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  PROCESS_IFACE;
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
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN g_org_id_csr (p_resale_batch_id);
   FETCH g_org_id_csr into l_org_id;
   CLOSE g_org_id_csr;

   IF l_org_id is not null THEN
      fnd_client_info.set_org_context(to_char(l_org_id));
   ELSE
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_ORG_ID_NOTFOUND');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OPEN OZF_RESALE_COMMON_PVT.g_batch_type_csr(p_resale_batch_id);
   FETCH OZF_RESALE_COMMON_PVT.g_batch_type_csr into l_batch_type;
   CLOSE OZF_RESALE_COMMON_PVT.g_batch_type_csr;

   -- Make sure that batch type is not null
   IF l_batch_type is null THEN
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_BATCH_TYPE_NULL');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Remove any log associated with this batch
   BEGIN
      DELETE FROM ozf_resale_logs_all
      WHERE resale_id_type = 'BATCH'
      AND resale_id = p_resale_batch_id;
   EXCEPTION
      WHEN OTHERS THEN
         OZF_UTILITY_PVT.error_message('OZF_RESALE_DEL_LOG_ERR');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- Varify the line information for this batch
   OZF_RESALE_COMMON_PVT.Validate_batch(
      p_api_version        => 1
     ,p_init_msg_list      => FND_API.G_FALSE
     ,p_commit             => FND_API.G_FALSE
     ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
     ,p_resale_batch_id    => p_resale_batch_id
     ,x_batch_status       => l_batch_status
     ,x_return_status      => l_return_status
     ,x_msg_data           => l_msg_data
     ,x_msg_count          => l_msg_count
   );

   IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_BATCH_VALIDATE_ERR');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- set disputed_code to null for the lines to be processed.
   update ozf_resale_lines_int
   set dispute_code = null
   where resale_batch_id = p_resale_batch_id
   and status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN;

   -- update tracing order lines to processed for this order to be processed
   update ozf_resale_lines_int
   set status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_PROCESSED
   where resale_batch_id = p_resale_batch_id
   and status_code= OZF_RESALE_COMMON_PVT.G_BATCH_ADJ_OPEN
   and tracing_flag = 'T';

/*
   i := 1;
   OPEN open_lines_csr(p_resale_batch_id);
   LOOP
      exit when open_lines_csr%NOTFOUND;
      FETCH open_lines_csr into l_open_lines_tbl(i);
      i:= i+1;
   END LOOP;
   CLOSE open_lines_csr;
*/
   OZF_RESALE_COMMON_PVT.Update_Duplicates (
      p_api_version        => 1.0,
      p_init_msg_list      => FND_API.G_FALSE,
      p_commit             => FND_API.G_FALSE,
      p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
      p_resale_batch_id    => p_resale_batch_id,
      p_resale_batch_type  => l_batch_type,
      p_batch_status       => l_batch_status,
      x_batch_status       => l_batch_status,
      x_return_status      => l_return_status,
      x_msg_count          => l_msg_count,
      x_msg_data           => l_msg_data);
   --
   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED THEN
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('OZF_RESALE_REJECTED');
      END IF;
   ELSE
      -- Varify the line information for this batch
      OZF_RESALE_COMMON_PVT.Validate_Order_Record(
         p_api_version        => 1
        ,p_init_msg_list      => FND_API.G_FALSE
        ,p_commit             => FND_API.G_FALSE
        ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
        ,p_resale_batch_id    => p_resale_batch_id
        ,x_return_status      => l_return_status
        ,x_msg_data           => l_msg_data
        ,x_msg_count          => l_msg_count
      );
      IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_VALIDATE_ERR');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Call different validation here.
      -- calling chargeback validation for this batch
      IF l_batch_type = OZF_RESALE_COMMON_PVT.G_TP_ACCRUAL THEN
         OZF_TP_ACCRUAL_PVT.Validate_Order_Record(
            p_api_version        => 1
           ,p_init_msg_list      => FND_API.G_FALSE
           ,p_commit             => FND_API.G_FALSE
           ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
           ,p_resale_batch_id    => p_resale_batch_id
           ,p_caller_type        => OZF_TP_ACCRUAL_PVT.G_IFACE_CALLER
           ,x_return_status      => l_return_status
           ,x_msg_data           => l_msg_data
           ,x_msg_count          => l_msg_count
          );
          IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
             OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_TP_VALIDATE_ERR');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_CHARGEBACK THEN
         OZF_CHARGEBACK_PVT.Validate_Order_Record(
           p_api_version        => 1
          ,p_init_msg_list      => FND_API.G_FALSE
          ,p_commit             => FND_API.G_FALSE
          ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
          ,p_resale_batch_id    => p_resale_batch_id
          ,x_return_status      => l_return_status
          ,x_msg_data           => l_msg_data
          ,x_msg_count          => l_msg_count
         );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_CHBK_VALIDATE_ERR');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_SPECIAL_PRICING THEN
         OZF_SPECIAL_PRICING_PVT.Validate_Order_Record(
           p_api_version        => 1
          ,p_init_msg_list      => FND_API.G_FALSE
          ,p_commit             => FND_API.G_FALSE
          ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
          ,p_resale_batch_id    => p_resale_batch_id
          ,x_return_status      => l_return_status
          ,x_msg_data           => l_msg_data
          ,x_msg_count          => l_msg_count
         );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_SPP_VALIDATE_ERR');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_TRACING THEN
         OZF_TRACING_ORDER_PVT.Validate_Order_Record(
           p_api_version        => 1
          ,p_init_msg_list      => FND_API.G_FALSE
          ,p_commit             => FND_API.G_FALSE
          ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
          ,p_resale_batch_id    => p_resale_batch_id
          ,x_return_status      => l_return_status
          ,x_msg_data           => l_msg_data
          ,x_msg_count          => l_msg_count
         );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_TRAC_VALIDATE_ERR');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_WNG_BATCH_TYPE');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

/*
   OPEN duplicate_count_csr (p_resale_batch_id);
   FETCH duplicate_count_csr into l_duplicate_count;
   CLOSE duplicate_count_csr;

   OPEN batch_count_csr (p_resale_batch_id);
   FETCH batch_count_csr into l_batch_count;
   CLOSE batch_count_csr;

   IF l_duplicate_count = l_batch_count THEN
      update ozf_resale_batches_all
      set status_code = OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED
      where resale_batch_id = p_resale_batch_id;
   ELSE
*/
      IF l_batch_type = OZF_RESALE_COMMON_PVT.G_TP_ACCRUAL THEN
         OZF_TP_ACCRUAL_PVT.Process_Order(
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => p_resale_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
         );

         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_TP_PROC_ERR');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_CHARGEBACK THEN
         OZF_CHARGEBACK_PVT.Process_Order(
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => p_resale_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
         );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_CHBK_PROC_ERR');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_SPECIAL_PRICING THEN
         OZF_SPECIAL_PRICING_PVT.Process_Order(
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => p_resale_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
         );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_SPP_PROC_ERR');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_batch_type = OZF_RESALE_COMMON_PVT.G_TRACING THEN
         OZF_TRACING_ORDER_PVT.Process_Order(
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => p_resale_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
         );

         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_TRAC_PROC_ERR');
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_WNG_BATCH_TYPE');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;  -- IF status is not rejected.

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
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
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
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
        ROLLBACK TO PROCESS_IFACE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Process_Iface;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Iface_WFL
--
-- PURPOSE
--    This procedure is called by a workflow to allow user to start the data process
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Process_Iface_WFL(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
l_api_name        CONSTANT VARCHAR2(30) := 'Process_Iface_WFL';
l_api_version     CONSTANT NUMBER := 1.0;
l_full_name       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
   l_resultout           VARCHAR2(30);
   l_resale_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   l_error_msg   varchar2(4000);
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   IF (funcmode = 'RUN') THEN
      l_resale_batch_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'RESALE_BATCH_ID');
      Process_iface (
          p_api_version      => 1.0
         ,p_init_msg_list    => FND_API.G_FALSE
         ,p_commit           => FND_API.G_FALSE
         ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id  => l_resale_batch_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => l_msg_data
         ,x_msg_count        => l_msg_count
      );
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:Y';
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:Y';

   ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:Y';

   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:Y';
   END IF;
   resultout := l_resultout;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     FND_MSG_PUB.count_and_get (
         p_encoded   => FND_API.g_false
        ,p_count     => l_msg_count
        ,p_data      => l_msg_data
     );
     WF_CORE.context(
         'OZF_RESALE_PVT'
        ,'PROCESS_IFACE_WFL'
        ,itemtype
        ,itemkey
        ,actid
        ,l_error_msg
     );
     resultout := 'COMPLETE:N';
     RETURN;

   WHEN OTHERS THEN
      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;
END Process_Iface_WFL;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    This procedure to initiate data process of records in resales table.
--
--    AT the point, we only suppor the process of Third party accrual for resale data.
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Resale (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Resale';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;

l_batch_type        varchar2(30);

l_batch_number               VARCHAR2(30);

CURSOR csr_batch_number(cv_batch_id IN NUMBER) IS
  SELECT batch_number
  FROM ozf_resale_batches
  WHERE resale_batch_id = cv_batch_id;

BEGIN

   -- Standard begin of API savepoint
   SAVEPOINT  PROCESS_RESALE;
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

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(p_message_text => l_full_name||': Start');
   END IF;

   IF p_resale_batch_id is null THEN
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_BATCH_ID_NULL');
      FND_MESSAGE.set_name('OZF', 'OZF_RESALE_BATCH_ID_NULL');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : '||FND_MESSAGE.get);
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      GOTO PROC_RESALE_END;
   END IF;

   OPEN csr_batch_number(p_resale_batch_id);
   FETCH csr_batch_number INTO l_batch_number;
   CLOSE csr_batch_number;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Batch Number               : '||l_batch_number);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');

   OPEN OZF_RESALE_COMMON_PVT.g_batch_type_csr(p_resale_batch_id);
   FETCH OZF_RESALE_COMMON_PVT.g_batch_type_csr into l_batch_type;
   CLOSE OZF_RESALE_COMMON_PVT.g_batch_type_csr;

   IF l_batch_type is null THEN
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_BATCH_TYPE_NULL');
      FND_MESSAGE.set_name('OZF', 'OZF_RESALE_BATCH_TYPE_NULL');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '   Error : '||FND_MESSAGE.get);
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      GOTO PROC_RESALE_END;
   END IF;

   /*
   IF l_batch_type = OZF_RESALE_COMMON_PVT.G_TP_ACCRUAL THEN
      OZF_UTILITY_PVT.error_message(p_message_name => 'OZF_RESALE_DUP_PROCESS_TP');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   */

   -- Only third party accrual is available for resale processing.
   OZF_TP_ACCRUAL_PVT.process_resale(
       p_api_version     => 1
      ,p_init_msg_list   => FND_API.G_FALSE
      ,p_commit          => FND_API.G_FALSE
      ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
      ,p_resale_batch_id => p_resale_batch_id
      ,x_return_status   => l_return_status
      ,x_msg_data        => l_msg_data
      ,x_msg_count       => l_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   <<PROC_RESALE_END>>

   -- Debug Message
    IF OZF_DEBUG_HIGH_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
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
        ROLLBACK TO  PROCESS_RESALE;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Process_Resale;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    This procedure to initiate data process of records in resales table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Resale (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_start_date             IN  DATE
   ,p_end_date               IN  DATE
   ,p_partner_cust_account_id  IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Process_Resale';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;

l_start_date        date:= p_start_date;
l_end_date          date:= p_end_date;

CURSOR range_without_customer_csr(p_start_date date, p_end_date date) is
SELECT resale_batch_id
FROM ozf_resale_batches
WHERE report_start_date >= p_start_date
AND   report_end_date <= p_end_date
AND   status_code = 'CLOSED';

CURSOR range_with_customer_csr(p_start_date date, p_end_date date, p_cust_account_id NUMBER) is
SELECT resale_batch_id
FROM ozf_resale_batches
WHERE report_start_date >= p_start_date
AND   report_end_date <= p_end_date
AND   partner_cust_account_id = p_cust_account_id
AND   status_code = 'CLOSED';

CURSOR csr_customer_batches(cv_cust_account_id IN NUMBER) IS
  SELECT resale_batch_id
  FROM ozf_resale_batches
  WHERE partner_cust_account_id = cv_cust_account_id
  AND   status_code = 'CLOSED';


TYPE batch_id_tbl_type is table of NUMBER index by binary_integer;
l_batch_id_tbl batch_id_tbl_type;

i number;
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  PROCESS_RESALE_ALL;
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

    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Debug Message
    IF OZF_DEBUG_HIGH_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
    END IF;

   -- Bug 4518607 (+)
   /*
   IF l_start_date is NULL THEN
      l_start_date := sysdate;
   END IF;

   IF l_end_date is NULL THEN
      l_end_date := sysdate;
   END IF;
   */

   IF l_start_date IS NOT NULL AND
      l_end_date IS NULL THEN
      l_end_date := SYSDATE;
   END IF;

   IF l_end_date IS NOT NULL AND
      l_start_date IS NULL THEN
      l_start_date := SYSDATE;
   END IF;

   IF l_start_date IS NOT NULL AND
      l_end_date IS NOT NULL AND
      l_start_date > l_end_date THEN
      ozf_utility_pvt.error_message('OZF_RESALE_WNG_DATE_RANGE');
      FND_MESSAGE.set_name('OZF', 'OZF_RESALE_WNG_DATE_RANGE');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Error : '||FND_MESSAGE.get);
      --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      GOTO PROC_RESALE_2_END;
   END IF;
   -- Bug 4518607 (-)

   IF p_partner_cust_account_id IS NULL THEN
      -- Bug 4518607 (+)
      IF l_start_date IS NOT NULL AND
         l_end_date IS NOT NULL THEN
         OPEN range_without_customer_csr(l_start_date, l_end_date);
         FETCH range_without_customer_csr BULK COLLECT INTO l_batch_id_tbl;
         CLOSE range_without_customer_csr;
      END IF;
      -- Bug 4518607 (-)
   ELSE
      -- Bug 4518607 (+)
      IF l_start_date IS NULL THEN
         OPEN csr_customer_batches(p_partner_cust_account_id);
         FETCH csr_customer_batches BULK COLLECT INTO l_batch_id_tbl;
         CLOSE csr_customer_batches;
      ELSIF l_start_date IS NOT NULL AND
            l_end_date IS NOT NULL THEN
      -- Bug 4518607 (-)
        OPEN range_with_customer_csr(l_start_date, l_end_date, p_partner_cust_account_id);
        FETCH range_with_customer_csr BULK COLLECT INTO l_batch_id_tbl;
        CLOSE range_with_customer_csr;
      END IF;
   END IF;

   i:= 1;

   IF l_batch_id_tbl.exists(1) THEN
      FOR j in 1..l_batch_id_tbl.LAST LOOP
         process_resale(
             p_api_version     => 1
            ,p_init_msg_list   => FND_API.G_FALSE
            ,p_commit          => FND_API.G_FALSE
            ,p_validation_level=> FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id  => l_batch_id_tbl(j)
            ,x_return_status   => l_return_status
            ,x_msg_data        => l_msg_data
            ,x_msg_count       => l_msg_count
          );
          IF l_return_status = FND_API.g_ret_sts_error THEN
             ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
             RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
             ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END LOOP;
   ELSE
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('No batch is specified.');
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'No batches found to be process.');
   END IF;


   <<PROC_RESALE_2_END>>

    -- Debug Message
    IF OZF_DEBUG_HIGH_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': End');
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
    );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
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
        ROLLBACK TO PROCESS_RESALE_ALL;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Process_Resale;

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Process_Resale
--
-- PURPOSE
--    This procedure starts to process batches from interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Process_Resale (
    ERRBUF                           OUT NOCOPY VARCHAR2,
    RETCODE                          OUT NOCOPY NUMBER,
    p_resale_batch_id                IN  NUMBER,
    p_start_date                     IN  VARCHAR2, -- hbandi Changed date to VARCHAR2 for the BUG #9412705
    p_end_date                       IN  VARCHAR2,  --hbandi Changed date to VARCHAR2 for the BUG #9412705
    p_partner_cust_account_id        IN  NUMBER
)
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_Process_Resale';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;

l_start_date        date;
l_end_date          date;
BEGIN

   SAVEPOINT Start_PROC_RESALE;
   RETCODE := 0;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*======================================================================================================*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Starts On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Request Id                 : '||FND_GLOBAL.CONC_REQUEST_ID);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Resale Batch Id            : '||TO_CHAR(p_resale_batch_id));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Start Date                 : '||p_start_date);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'End Date                   : '||p_end_date);
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Cust Account Id            : '||TO_CHAR(p_partner_cust_account_id));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, ' ');
   -- Debug Message
    IF OZF_DEBUG_LOW_ON THEN
      ozf_utility_PVT.debug_message(l_full_name||': start');
    END IF;

   IF p_resale_batch_id is NULL THEN

	  --hbandi added below code for convert start_date and end_date values from varchar2 to canonical date formate.For the BUG #9412705(+)
	  IF p_start_date IS NOT NULL THEN
		   l_start_date :=  FND_DATE.CANONICAL_TO_DATE(p_start_date);
	  END IF;

	  IF p_end_date IS NOT NULL THEN
		   l_end_date :=  FND_DATE.CANONICAL_TO_DATE(p_end_date);
	  END IF;
	  --hbandi added below code for convert start_date and end_date values from varchar2 to canonical date formate.For the BUG #9412705(-)

      Process_resale (
          p_api_version     => 1.0
         ,p_init_msg_list   => FND_API.G_FALSE
         ,p_commit          => FND_API.G_FALSE
         ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
         ,p_start_date       => l_start_date
         ,p_end_date         => l_end_date
         ,p_partner_cust_account_id => p_partner_cust_account_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => l_msg_data
         ,x_msg_count        => l_msg_count
      );

      IF l_return_status = FND_API.g_ret_sts_error THEN
         ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   ELSE
      Process_resale (
          p_api_version     => 1.0
         ,p_init_msg_list   => FND_API.G_FALSE
         ,p_commit          => FND_API.G_FALSE
         ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id     => p_resale_batch_id
         ,x_return_status    => l_return_status
         ,x_msg_data         => l_msg_data
         ,x_msg_count        => l_msg_count
      );
      IF l_return_status = FND_API.g_ret_sts_error THEN
         ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
         RAISE FND_API.g_exc_error;
      ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
         ozf_utility_pvt.error_message('OZF_PROC_RESALE_ERR');
         RAISE FND_API.g_exc_unexpected_error;
      END IF;
   END IF;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': end');
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*------------------------------------------------------------------------------------------------------*');
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Execution Ends On: ' || to_char(sysdate,'MM-DD-YYYY HH24:MI:SS'));
   FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '*======================================================================================================*');

   -- Write all messages to a log
   OZF_UTILITY_PVT.Write_Conc_Log;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 1;

  WHEN FND_API.g_exc_unexpected_error THEN
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;

  WHEN OTHERS THEN
    ROLLBACK TO Start_PROC_RESALE;
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;
END Start_Process_Resale;

---------------------------------------------------------------------
-- PROCEDURE
--    Purge
--
-- PURPOSE
--    Purge the successfully processed records
--
-- PARAMETERS
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE Purge(
    p_api_version            IN    NUMBER
   ,p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_data_source_code       IN    VARCHAR2
   ,p_resale_batch_id        IN    NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Purge';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--

BEGIN
   -- Standard begin of API savepoint
   SAVEPOINT  Resale_Purge;
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

   -- Initialize API return status to sucess
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   IF p_resale_batch_id IS NULL THEN
      --  Purge the records that have been successfully processed
      IF p_data_source_code IS NULL OR
         p_data_source_code = 'ALL' THEN
         BEGIN
            DELETE FROM ozf_resale_lines_int_all a
            WHERE a.resale_batch_id IN (
               SELECT b.resale_batch_id
               FROM ozf_resale_batches b
               WHERE b.purge_flag IS NULL
               AND   b.status_code = 'CLOSED'
            );

            UPDATE ozf_resale_batches
            SET purge_flag = 'T'
            WHERE purge_flag IS NULL
            AND status_code = 'CLOSED';
         EXCEPTION
            WHEN OTHERS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      ELSE
         BEGIN
            DELETE FROM ozf_resale_lines_int_all a
            WHERE a.data_source_code = p_data_source_code
            AND a.resale_batch_id IN (
               SELECT b.resale_batch_id
               FROM ozf_resale_batches b
               WHERE b.purge_flag IS NULL
               AND   b.status_code = 'CLOSED'
               AND   b.data_source_code = p_data_source_code
            );

            UPDATE ozf_resale_batches
            SET purge_flag = 'T'
            WHERE purge_flag IS NULL
            AND status_code = 'CLOSED'
            AND data_source_code = p_data_source_code;
         EXCEPTION
            WHEN OTHERS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      END IF;
   ELSE -- else (if p_batch_number is not null)
      --  Purge the records that have been successfully processed
      IF p_data_source_code IS NULL OR
         p_data_source_code = 'ALL' THEN
         BEGIN
            DELETE FROM ozf_resale_lines_int_all a
            WHERE a.resale_batch_id IN (
               SELECT b.resale_batch_id
               FROM ozf_resale_batches b
               WHERE b.purge_flag IS NULL
               AND   b.resale_batch_id = p_resale_batch_id
               AND   b.status_code NOT IN ('CLOSED', 'PROCESSING', 'PENDING_PAYMENT')
            );

            DELETE FROM ozf_resale_batches_all
            WHERE resale_batch_id = p_resale_batch_id
            AND   status_code NOT IN ('CLOSED', 'PROCESSING', 'PENDING_PAYMENT');
         EXCEPTION
            WHEN OTHERS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      ELSE
         BEGIN
            DELETE FROM ozf_resale_lines_int_all a
            WHERE a.data_source_code = p_data_source_code
            AND a.resale_batch_id IN (
               SELECT b.resale_batch_id
               FROM ozf_resale_batches b
               WHERE b.purge_flag IS NULL
               AND   b.data_source_code = p_data_source_code
               AND   b.resale_batch_id = p_resale_batch_id
            );

            DELETE FROM ozf_resale_batches_all
            WHERE resale_batch_id = p_resale_batch_id
            AND   data_source_code = p_data_source_code
            AND   status_code NOT IN ('CLOSED', 'PROCESSING', 'PENDING_PAYMENT');
         EXCEPTION
            WHEN OTHERS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;
      END IF;
   END IF;


   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;
   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
   );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Resale_Purge ;

        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  Resale_Purge;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
    WHEN OTHERS THEN
        ROLLBACK TO Resale_Purge;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
        );
END Purge;

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Purge
--
-- PURPOSE
--    This procedure starts to remove processed date from interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Purge (
    ERRBUF                           OUT NOCOPY VARCHAR2,
    RETCODE                          OUT NOCOPY NUMBER,
    p_data_source_code               IN VARCHAR2 := NULL,
    p_resale_batch_id                IN NUMBER := NULL
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Start_Process_Purge';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;
begin

   SAVEPOINT Start_RESALE_Purge;
   RETCODE := 0;
   -- Debug Message
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message(l_full_name||': Start');
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Start to purge processed order ---*/');

   Purge (
       p_api_version      => 1.0
      ,p_init_msg_list    => FND_API.G_FALSE
      ,p_commit           => FND_API.G_FALSE
      ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
      ,p_data_source_code => p_data_source_code
      ,p_resale_batch_id  => p_resale_batch_id
      ,x_return_status    => l_return_status
      ,x_msg_data         => l_msg_data
      ,x_msg_count        => l_msg_count
   );
   IF l_return_status = FND_API.g_ret_sts_error THEN
      ozf_utility_pvt.error_message('OZF_PURGE_CHG_INT_ERR');
      RAISE FND_API.g_exc_error;
   ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
      ozf_utility_pvt.error_message('OZF_PURGE_CHG_INT_ERR');
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- End of purge processed order ---*/');

    -- Debug Message
    IF OZF_DEBUG_HIGH_ON THEN
       OZF_UTILITY_PVT.debug_message(l_full_name||': End');
   END IF;

   -- Write all messages to a log
   OZF_UTILITY_PVT.Write_Conc_Log;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO Start_RESALE_Purge;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Error happened during purge ---*/');
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 1;

  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO Start_RESALE_Purge;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Error happened during purge ---*/');
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;

  WHEN OTHERS THEN
    ROLLBACK TO Start_RESALE_Purge;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '/*--- Error happened during purge ---*/');
    OZF_UTILITY_PVT.Write_Conc_Log;
    ERRBUF  := l_msg_data;
    RETCODE := 2;

END Start_Purge;

END OZF_RESALE_PVT;

/
