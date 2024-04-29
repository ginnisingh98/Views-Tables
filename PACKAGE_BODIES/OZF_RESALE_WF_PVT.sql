--------------------------------------------------------
--  DDL for Package Body OZF_RESALE_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_RESALE_WF_PVT" AS
/* $Header: ozfvrwfb.pls 120.10.12010000.2 2010/05/04 09:29:07 rsatyava ship $ */

-- Package name     : OZF_RESALE_WF_PVT
-- Purpose          : Called from Resale Data processing and Payment initiation workflows.
-- History          : CREATED       VANSUB      02-18-2004
--                  : MODIFICATIONS SLKRISHN    02-28-2004
-- NOTE             :
-- END of Comments

G_FILE_NAME         CONSTANT VARCHAR2(30) := 'ozfvrwfb.pls';

OZF_DEBUG_HIGH_ON            BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON             BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.g_msg_lvl_debug_low);
OZF_UNEXP_ERROR     CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_unexp_error);
OZF_ERROR           CONSTANT BOOLEAN := FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.g_msg_lvl_error);

---------------------------------------------------------------------
-- PROCEDURE
--    Handle_Error
--
-- PURPOSE
--    This procedure handles workflow errors
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Handle_Error (
    p_itemtype                 IN  VARCHAR2,
    p_itemkey                  IN  VARCHAR2,
    p_msg_count                IN  NUMBER,
    p_msg_data                 IN  VARCHAR2,
    p_process_name             IN  VARCHAR2,
    x_error_msg                OUT NOCOPY VARCHAR2
)
IS
l_api_name            VARCHAR2(30) := 'Handle_Error';
l_msg_count           NUMBER ;
l_msg_data            VARCHAR2(2000);
l_error_msg           VARCHAR2(4000);
l_final_msg           VARCHAR2(4000);
l_msg_index           NUMBER;
--
l_resale_batch_id     NUMBER;
l_temp_mesg           VARCHAR2(2500);
BEGIN

   l_resale_batch_id := WF_ENGINE.GetItemAttrText(
                           itemtype => p_itemtype,
                           itemkey  => p_itemkey,
                           aname    => G_WF_ATTR_BATCH_ID);

   FOR i IN 1..p_msg_count LOOP
      FND_MSG_PUB.get(
         p_msg_index       => p_msg_count - i +1 ,
         p_encoded         => FND_API.g_false,
         p_data            => l_msg_data,
         p_msg_index_out   => l_msg_index
      );
      l_temp_mesg := l_msg_index ||': ' ||
                     l_msg_data || fnd_global.local_chr(10);
      IF length (l_final_msg ) + length (l_temp_mesg) >= 4000 THEN
         goto end_loop_error;
      END IF;
      l_final_msg := l_final_msg ||
                     l_msg_index ||': ' ||
                     l_msg_data || fnd_global.local_chr(10);

      << end_loop_error >>
      null;
   END LOOP ;
   x_error_msg   := l_final_msg;

   WF_ENGINE.SetItemAttrText(
       itemtype   => p_itemtype,
       itemkey    => p_itemkey ,
       aname      => G_WF_ATTR_ERROR_MESG,
       avalue     => l_final_msg );
EXCEPTION
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      RAISE;
END Handle_Error;

---------------------------------------------------------------------
-- PROCEDURE
--    Check_Duplicates
--
-- PURPOSE
--    This procedure validates all the lines IN the batch
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Check_Duplicates
(
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Check_Duplicates';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);
   l_batch_type          VARCHAR2(30);
   l_batch_status        VARCHAR2(30);
   l_batch_return_status        VARCHAR2(30);

CURSOR batch_status_csr(p_id number) IS
SELECT status_code
 --FROM  ozf_resale_batches
 FROM  ozf_resale_batches_all
 WHERE resale_batch_id = p_id;

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype   => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch ID '|| l_batch_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN
         l_batch_type := WF_ENGINE.GetItemAttrText (itemtype => itemType,
                                    itemkey  => itemKey,
                                    aname    => G_WF_ATTR_BATCH_TYPE);

         OPEN batch_status_csr(l_batch_id);
         FETCH batch_status_csr into l_batch_status;
         CLOSE batch_status_csr;

         IF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT THEN
           l_batch_return_status := l_batch_status;
         ELSE
           OZF_RESALE_COMMON_PVT.Update_Duplicates (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_commit             => FND_API.G_FALSE,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            p_resale_batch_id    => l_batch_id,
            p_resale_batch_type  => l_batch_type,
            p_batch_status       => l_batch_status,
            x_batch_status       => l_batch_return_status,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data);

           IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('Check duplicate line is complete '||l_return_status);
            OZF_UTILITY_PVT.debug_message('batch status '||l_batch_return_status);
           END IF;
           IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
           END IF;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      WF_ENGINE.SetItemAttrText(
         itemtype   => itemtype,
         itemkey    => itemkey ,
         aname      => G_WF_ATTR_BATCH_STATUS,
         avalue     => l_batch_return_status );

      IF l_batch_return_status not in (OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSED,
                                OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED,
                                OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED) THEN
         l_resultout := 'COMPLETE:OTHER';
      ELSE
         l_resultout := 'COMPLETE:' || l_batch_return_status;
      END IF;
      --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Check_Duplicates;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Auto_Accrual_Flag
--
-- PURPOSE
--    This procedure returns values of auto_tp_accrual_flag from system parameter
--
-- PARAMETERS
--
--
-- NOTES
--      returns F or T
---------------------------------------------------------------------
PROCEDURE Get_Auto_Accrual_Flag(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2
)IS
l_api_name            CONSTANT VARCHAR2(30) := 'Get_Auto_Accrual_Flag';
l_api_version_number  CONSTANT NUMBER   := 1.0;
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2(2000);
l_error_msg           VARCHAR2(4000);

l_resultout            VARCHAR2(30);
l_auto_tp_accrual      VARCHAR2(1);
--
CURSOR auto_tp_accrual_csr IS
SELECT auto_tp_accrual_flag
  FROM ozf_sys_parameters;

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      OPEN auto_tp_accrual_csr;
      FETCH auto_tp_accrual_csr INTO l_auto_tp_accrual;
      CLOSE auto_tp_accrual_csr;


      IF l_auto_tp_accrual is NULL THEN
         -- 11/23/04 yizhang: default flag to FALSE instead of raising an error
         l_auto_tp_accrual := 'F';
         --OZF_UTILITY_PVT.error_message('OZF_RESALE_AUTO_TP_NULL');
         --RAISE FND_API.G_EXC_ERROR;
      ELSE
      -- START: Added for bug#9598648 fix
	FND_REQUEST.set_org_id(l_batch_org_id);
      -- END: Added for bug#9598648 fix

      END IF;
      l_resultout := 'COMPLETE:' || l_auto_tp_accrual;
      --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Get_Auto_Accrual_Flag;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Batch_Caller
--
-- PURPOSE
--    This procedure returns the batch type to workflow
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Batch_Caller (
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Get_Batch_Caller';
l_api_version_number  CONSTANT NUMBER   := 1.0;

l_resultout            VARCHAR2(30);
l_batch_id             NUMBER;
l_return_status        VARCHAR2(1);
l_msg_count            NUMBER;
l_msg_data             VARCHAR2(2000);
l_error_msg            VARCHAR2(4000);
l_batch_caller         VARCHAR2(30);
l_batch_num_w_date     VARCHAR2(240);
l_batch_number         VARCHAR2(240);
l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_caller := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => G_WF_ATTR_BATCH_CALLER);

      IF l_batch_caller is NULL THEN
         -- default caller to be UI
         l_batch_caller := G_WF_LKUP_UI;
         WF_ENGINE.SetItemAttrText(
            itemtype   => itemtype,
            itemkey    => itemkey ,
            aname      => G_WF_ATTR_BATCH_CALLER,
            avalue     => l_batch_caller);
      END IF;

      IF l_batch_caller NOT IN (G_WF_LKUP_UI, G_WF_LKUP_XML, G_WF_LKUP_WEBADI)
      THEN
         OZF_UTILITY_PVT.error_message('OZF_API_DEBUG_MESSAGE','TEXT','Invalid Batch caller '|| l_batch_caller);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- SET attribute OZF_BATCH_NUM_W_DATE for event key
      l_batch_number := WF_ENGINE.GetItemAttrText(
                        itemtype => itemtype,
                        itemkey  => itemkey,
                        aname    => G_WF_ATTR_BATCH_NUMBER
                  );
      l_batch_num_w_date :='ResaleBatch:'||l_batch_number||'-'|| to_char(sysdate,'MM/DD/YYYY HH:MI:SS');

      WF_ENGINE.SetItemAttrText(
         itemtype   => itemtype,
         itemkey    => itemkey ,
         aname      => G_WF_ATTR_BATCH_NUM_W_DATE,
         avalue     => l_batch_num_w_date);

      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch caller'||   l_batch_caller );
      END IF;
      l_resultout := 'COMPLETE:' || l_batch_caller;
      --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Get_Batch_Caller;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Batch_Status
--
-- PURPOSE
--    This procedure returns the value of batch status
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Batch_Status (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2 )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_Batch_Status';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            VARCHAR2(30);
   l_batch_id             NUMBER;
   l_return_status        VARCHAR2(1);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_error_msg            VARCHAR2(4000);
   l_status_code          VARCHAR2(30);

CURSOR batch_status_csr(p_id number) IS
SELECT status_code
 --FROM  ozf_resale_batches
 FROM  ozf_resale_batches_all
 WHERE resale_batch_id = p_id;

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => G_WF_ATTR_BATCH_ID);

      OPEN batch_status_csr(l_batch_id);
      FETCH batch_status_csr into l_status_code;
      CLOSE batch_status_csr;

      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch status '||   l_status_code );
      END IF;
      IF l_status_code not in ( OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSED,
                                OZF_RESALE_COMMON_PVT.G_BATCH_REJECTED,
                                OZF_RESALE_COMMON_PVT.G_BATCH_CLOSED) THEN
         l_resultout := 'COMPLETE:OTHER';
      ELSE
         l_resultout := 'COMPLETE:' || l_status_code;
      END IF;
      --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Get_Batch_Status;

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Batch_Type
--
-- PURPOSE
--    This procedure returns the batch type to workflow
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Batch_Type (
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_Batch_Type';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            VARCHAR2(30);
   l_batch_id             NUMBER;
   l_return_status        VARCHAR2(1);
   l_msg_count            NUMBER;
   l_msg_data             VARCHAR2(2000);
   l_error_msg            VARCHAR2(4000);
   l_batch_type           VARCHAR2(30);

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_type := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => G_WF_ATTR_BATCH_TYPE);

      IF l_batch_type NOT IN (G_WF_LKUP_CHARGEBACK, G_WF_LKUP_SPECIALPRICE, G_WF_LKUP_TRACING) OR
         l_batch_type IS NULL
      THEN
         OZF_UTILITY_PVT.error_message('OZF_API_DEBUG_MESSAGE','TEXT','Invalid Batch Type '|| l_batch_type);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch Type '||   l_batch_type );
      END IF;
      l_resultout := 'COMPLETE:' || l_batch_type;
      --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Get_Batch_Type;
---------------------------------------------------------------------
-- PROCEDURE
--    Init_attributes
--
-- PURPOSE
--    This api will be initialize the attributes used IN the workflow
--
---------------------------------------------------------------------
PROCEDURE Init_Attributes(
   itemtype    IN     VARCHAR2,
   itemkey     IN     VARCHAR2,
   actid       IN     NUMBER,
   funcmode    IN     VARCHAR2,
   result      OUT NOCOPY    VARCHAR2
)
IS
l_api_name            CONSTANT VARCHAR2(30) := 'Init_Attributes';
l_api_version_number  CONSTANT NUMBER   := 1.0;
--
l_resale_batch_id NUMBER;
--
l_batch_number         VARCHAR2(240);
l_batch_type           VARCHAR2(30);
l_last_updated_by        Number;
--
--l_emp_id          NUMBER;
--l_user_name       VARCHAR2(100);
--l_display_name    VARCHAR2(100);
l_return_status   VARCHAR2(1);
l_error_msg       VARCHAR2(4000);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(2000);
--
CURSOR batch_num_csr(p_id number) IS
 SELECT batch_number
     , batch_type
     , last_updated_by
     , org_id
 FROM ozf_resale_batches_all
 WHERE resale_batch_id = p_id;

/*
CURSOR emp_infor_csr(p_res_id NUMBER) IS
SELECT employee_id
  FROM ams_jtf_rs_emp_v
 WHERE  resource_id = p_res_id;
*/
l_batch_org_id     NUMBER;
--
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;
   IF (funcmode = 'RUN') THEN
      -- Clear the error stack for one time
      FND_MSG_PUB.initialize;

      l_resale_batch_id := WF_ENGINE.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => G_WF_ATTR_BATCH_ID
                        );
      IF l_resale_batch_id is NULL THEN
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      OPEN batch_num_csr (l_resale_batch_id);
      FETCH batch_num_csr into l_batch_number
                             , l_batch_type
                             , l_last_updated_by
                             , l_batch_org_id;
      CLOSE batch_num_csr;



      WF_ENGINE.SetItemAttrText(
          itemtype   => itemtype,
          itemkey    => itemkey ,
          aname      => G_WF_ATTR_BATCH_NUMBER,
          avalue     => l_batch_number );

      WF_ENGINE.SetItemAttrText(
          itemtype   => itemtype,
          itemkey    => itemkey ,
          aname      => G_WF_ATTR_BATCH_TYPE,
          avalue     => l_batch_type );

      WF_ENGINE.SetItemAttrText(
          itemtype   => itemtype,
          itemkey    => itemkey ,
          aname      => 'OZF_BATCH_ORG_ID',
          avalue     => l_batch_org_id
      );

      /*
      -- The following is moved to workflow first activity-Set_Batch_Status.
      OPEN emp_infor_csr(OZF_UTILITY_PVT.get_resource_id(l_last_updated_by));
      FETCH emp_infor_csr INTO l_emp_id;
      CLOSE emp_infor_csr;

      WF_DIRECTORY.GetRoleName
           ( p_orig_system      => 'PER',
             p_orig_system_id   => l_emp_id ,
             p_name             => l_user_name,
             p_display_name     => l_display_name );

      WF_ENGINE.SetItemAttrText(
          itemtype   => itemtype,
          itemkey    => itemkey ,
          aname      => G_WF_ATTR_WF_ADMINISTRATOR,
          avalue     => l_user_name);

      -- set workflow process owner
      WF_ENGINE.SetItemOwner(
          itemtype  => itemtype,
          itemkey   => itemkey,
          owner     => l_user_name);
      */
   --
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL') THEN
      RETURN;
   END IF;

   --  Other mode  - Normal Process Execution
   IF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      RETURN;
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT') THEN
      RETURN;
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Init_Attributes;

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment
--
-- PURPOSE
--    This procedure inities payment processing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment (
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Initiate_Payment';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_RESALE_PVT.Initiate_Payment (
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
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Initiate_Payment;


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_chargeback
--
-- PURPOSE
--    This procedure inities payment processing for chargeback
--
-- PARAMETERS
--
--
-- NOTES
--   returns success or error
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_chargeback (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2 )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Initiate_Payment_chargeback';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_CHARGEBACK_PVT.Initiate_Payment (
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
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Initiate_Payment_Chargeback;


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment__SPP
--
-- PURPOSE
--    This procedure inities payment processing for special pricing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_SPP(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2 )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Initiate_Payment_SPP';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_SPECIAL_PRICING_PVT.Initiate_Payment (
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
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Initiate_Payment_SPP;


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_Tracing
--
-- PURPOSE
--    This procedure inities payment processing for tracing order
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_Tracing (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2 )
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Initiate_Payment_Tracing';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;
   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_TRACING_ORDER_PVT.Initiate_Payment (
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
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Initiate_Payment_Tracing;

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Chargeback
--
-- PURPOSE
--    This procedure inities indirect sales data processing for chargeback
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Process_Chargeback (
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Process_Chargeback';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id           NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_CHARGEBACK_PVT.Process_Order(
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
         OZF_UTILITY_PVT.debug_message('subscribe process chargeback order complete ');
      END IF;
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RAISE;
END Process_Chargeback;


---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    This procedure initiates third party accrual process for resale data
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Resale(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Process_Resale';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_RESALE_PVT.Process_Resale (
          p_api_version       => 1
         ,p_init_msg_list     => FND_API.G_FALSE
         ,p_commit            => FND_API.G_FALSE
         ,p_validation_level  => FND_API.G_VALID_LEVEL_FULL
         ,p_resale_batch_id   => l_resale_batch_id
         ,x_return_status     => l_return_status
         ,x_msg_data          => l_msg_data
         ,x_msg_count         => l_msg_count
      );
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Process_Resale;


---------------------------------------------------------------------
-- PROCEDURE
--    Process_Special_Pricing
--
-- PURPOSE
--    This procedure inities indirect sales data processing for special pricing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Process_Special_Pricing(
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Process_Special_Pricing';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_SPECIAL_PRICING_PVT.Process_Order(
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
         OZF_UTILITY_PVT.debug_message('subscribe process chargeback order complete ');
      END IF;
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Process_Special_Pricing;


---------------------------------------------------------------------
-- PROCEDURE
--    Process_Tracing
--
-- PURPOSE
--    This procedure inities indirect sales data processing for tracing data
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Process_Tracing(
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Process_Tracing';
   l_api_version_number  CONSTANT NUMBER   := 1.0;
   l_resultout           VARCHAR2(30);
   l_resale_batch_id     NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_resale_batch_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      OZF_TRACING_ORDER_PVT.Process_Order(
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
         OZF_UTILITY_PVT.debug_message('subscribe process tracing order complete ');
      END IF;
      IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Process_Tracing;

---------------------------------------------------------------------
-- PROCEDURE
--    Reset_Status
--
-- PURPOSE
--    This procedure is to reset the status of a batch IN case of exceptions
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Reset_Status (
   itemtype    IN     VARCHAR2,
   itemkey     IN     VARCHAR2,
   actid       IN     NUMBER,
   funcmode    IN     VARCHAR2,
   result      OUT NOCOPY    VARCHAR2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Reset_Status';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;
--
l_resale_batch_id NUMBER;
l_batch_status        varchar2(30);
l_lines_disputed      number;
l_resultout           VARCHAR2(30);
l_error_msg           VARCHAR2(4000);
--
CURSOR batch_status_csr(p_id number) IS
SELECT status_code
     , lines_disputed
 --FROM  ozf_resale_batches
 FROM  ozf_resale_batches_all
 WHERE resale_batch_id = p_id;
--
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;
   IF (funcmode = 'RUN') THEN
      --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => G_WF_ATTR_BATCH_ID
                        );

      OPEN batch_status_csr(l_resale_batch_id);
      FETCH batch_status_csr into l_batch_status, l_lines_disputed;
      CLOSE batch_status_csr;

      IF l_batch_status is null THEN
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_STATUS_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- reset the status based on # of disputed lines
      OPEN  OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr (l_resale_batch_id);
      FETCH OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr into l_lines_disputed;
      CLOSE OZF_RESALE_COMMON_PVT.g_disputed_line_count_csr;

      IF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSING THEN
         IF l_lines_disputed = 0 THEN
            -- update status to Processed
            UPDATE ozf_resale_batches_all
               SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_OPEN
             WHERE resale_batch_id = l_resale_batch_id;
         ELSE
            -- update status to Disputed
            UPDATE ozf_resale_batches_all
               SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
             WHERE resale_batch_id = l_resale_batch_id;
         END IF;
      ELSIF l_batch_status = OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT THEN

         IF l_lines_disputed = 0 THEN
            -- update status to Processed
            UPDATE ozf_resale_batches_all
               SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSED
             WHERE resale_batch_id = l_resale_batch_id;
         ELSE
            -- update status to Disputed
            UPDATE ozf_resale_batches_all
               SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED
             WHERE resale_batch_id = l_resale_batch_id;
         END IF;
      END IF;
      l_resultout := 'COMPLETE';
      --
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL') THEN
     l_resultout := 'COMPLETE:';
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   result := l_resultout;
   RETURN;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Reset_Status;

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Batch_Status
--
-- PURPOSE
--    This procedure is to set the status of a batch
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Batch_Status (
   itemtype    IN     VARCHAR2,
   itemkey     IN     VARCHAR2,
   actid       IN     NUMBER,
   funcmode    IN     VARCHAR2,
   resultout  in OUT NOCOPY varchar2
)IS
l_api_name          CONSTANT VARCHAR2(30) := 'Set_Batch_Status';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;
--
l_resale_batch_id NUMBER;
l_batch_status        varchar2(30);
l_batch_next_status        varchar2(30);
l_lines_disputed      number;
l_resultout           VARCHAR2(30);
l_error_msg           VARCHAR2(4000);

l_last_updated_by      NUMBER;
l_emp_id               NUMBER;
l_user_name            VARCHAR2(100);
l_display_name         VARCHAR2(100);
--
CURSOR batch_status_csr(p_id number) IS
SELECT last_updated_by
,      status_code
 --FROM  ozf_resale_batches
 FROM  ozf_resale_batches_all
 WHERE resale_batch_id = p_id;

CURSOR emp_infor_csr(p_res_id NUMBER) IS
-- BUBG 4953233 (+)
  SELECT  ppl.person_id
  FROM jtf_rs_resource_extns rsc
     , per_people_f ppl
  WHERE rsc.category = 'EMPLOYEE'
  AND ppl.person_id = rsc.source_id
  AND rsc.resource_id=p_res_id;
  -- SELECT employee_id
  -- FROM jtf_rs_res_emp_vl
  -- WHERE resource_id = p_res_id ;
-- BUBG 4953233 (-)

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => G_WF_ATTR_BATCH_ID
                        );

      OPEN batch_status_csr(l_resale_batch_id);
      FETCH batch_status_csr INTO l_last_updated_by
                                , l_batch_status;
      CLOSE batch_status_csr;


      OPEN emp_infor_csr(OZF_UTILITY_PVT.get_resource_id(l_last_updated_by));
      FETCH emp_infor_csr INTO l_emp_id;
      CLOSE emp_infor_csr;

      WF_DIRECTORY.GetRoleName(
             p_orig_system      => 'PER',
             p_orig_system_id   => l_emp_id ,
             p_name             => l_user_name,
             p_display_name     => l_display_name
      );

      WF_ENGINE.SetItemAttrText(
             itemtype           => itemtype,
             itemkey            => itemkey ,
             aname              => G_WF_ATTR_WF_ADMINISTRATOR,
             avalue             => l_user_name
      );

      -- set workflow process owner
      WF_ENGINE.SetItemOwner(
             itemtype           => itemtype,
             itemkey            => itemkey,
             owner              => l_user_name
      );

      --
      IF l_batch_status is null THEN
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_STATUS_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;


      IF l_batch_status in (OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSING,
                            OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT) THEN
         l_batch_next_status := l_batch_status;
      ELSE
         IF l_batch_status IN (OZF_RESALE_COMMON_PVT.G_BATCH_OPEN,
                               OZF_RESALE_COMMON_PVT.G_BATCH_DISPUTED) THEN
            l_batch_next_status := OZF_RESALE_COMMON_PVT.G_BATCH_PROCESSING;

            UPDATE ozf_resale_batches_all
               SET status_code = l_batch_next_status
             WHERE resale_batch_id = l_resale_batch_id;

         ELSE
            OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_STATUS_ERR');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;


      l_resultout := 'COMPLETE:' || l_batch_next_status;
      --
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL') THEN
     l_resultout := 'COMPLETE:';
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;
   RETURN;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Set_Batch_Status;

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Payment_Pending
--
-- PURPOSE
--    This procedure set the batch status to Payment_Pending
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Payment_Pending(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2 )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Set_Payment_Pending';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;
--
l_resale_batch_id NUMBER;
l_resultout           VARCHAR2(30);
l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => G_WF_ATTR_BATCH_ID);

      UPDATE ozf_resale_batches_all
      SET status_code = OZF_RESALE_COMMON_PVT.G_BATCH_PENDING_PAYMENT
      WHERE resale_batch_id = l_resale_batch_id;

      l_resultout := 'COMPLETE';
      --
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL') THEN
     l_resultout := 'COMPLETE:';
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:';
   END IF;

   resultout := l_resultout;
   RETURN;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Set_Payment_Pending;

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Tolerance_Level
--
-- PURPOSE
--    This procedure set the batch status
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Tolerance_Level(
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2 )
IS
l_api_name          CONSTANT VARCHAR2(30) := 'Set_Tolerance_Level';
l_api_version       CONSTANT NUMBER := 1.0;
l_full_name         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_return_status     varchar2(30);
l_msg_data          varchar2(2000);
l_msg_count         number;
--
l_resale_batch_id NUMBER;
l_resultout           VARCHAR2(30);
l_error_msg           VARCHAR2(4000);
--
l_header_tolerance_operand   NUMBER;
l_header_tolerance_calc_code VARCHAR2(30);

l_line_tolerance_operand     NUMBER;
l_line_tolerance_calc_code   VARCHAR2(30);

l_creation_date   DATE;
l_last_update_date DATE;
l_partner_party_id       NUMBER;
l_partner_cust_account_id  NUMBER;

CURSOR batch_info_csr (p_batch_id NUMBER) IS
SELECT creation_date,
       last_update_date,
       partner_party_id,
       partner_cust_account_id
--FROM ozf_resale_batches
FROM ozf_resale_batches_all
WHERE resale_batch_id = p_batch_id;

CURSOR header_tolerance_sys_csr IS
SELECT header_tolerance_operand,
       header_tolerance_calc_code
FROM ozf_sys_parameters;

CURSOR header_tolerance_account_csr (p_cust_account_id NUMBER)IS
SELECT header_tolerance_operand,
       header_tolerance_calc_code
FROM ozf_cust_trd_prfls
WHERE cust_account_id = p_cust_account_id;

CURSOR header_tolerance_party_csr (p_party_id NUMBER)IS
SELECT header_tolerance_operand,
       header_tolerance_calc_code
FROM ozf_cust_trd_prfls
WHERE party_id = p_party_id
and  cust_account_id IS NULL;

CURSOR line_tolerance_sys_csr IS
SELECT line_tolerance_operand,
       line_tolerance_calc_code
FROM ozf_sys_parameters;

CURSOR line_tolerance_account_csr (p_cust_account_id NUMBER)IS
SELECT line_tolerance_operand,
       line_tolerance_calc_code
FROM ozf_cust_trd_prfls
WHERE cust_account_id = p_cust_account_id;

CURSOR line_tolerance_party_csr (p_party_id NUMBER)IS
SELECT line_tolerance_operand,
       line_tolerance_calc_code
FROM ozf_cust_trd_prfls
WHERE party_id = p_party_id
AND   cust_account_id IS NULL;

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_resale_batch_id := WF_ENGINE.GetItemAttrText(
                              itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => G_WF_ATTR_BATCH_ID);

      OPEN batch_info_csr (l_resale_batch_id);
      FETCH batch_info_csr INTO  l_creation_date,
                                 l_last_update_date,
                                 l_partner_party_id,
                                 l_partner_cust_account_id;
      CLOSE batch_info_csr;

      IF l_creation_date = l_last_update_date THEN
         -- It is the first time this batch is processed. default toleracne

         -- Set header tolerance
         OPEN  header_tolerance_account_csr(l_partner_cust_account_id);
         FETCH header_tolerance_account_csr into l_header_tolerance_operand,
                                                      l_header_tolerance_calc_code;
         CLOSE header_tolerance_account_csr;

         IF l_header_tolerance_calc_code is NULL THEN
            OPEN  header_tolerance_party_csr(l_partner_party_id);
            FETCH header_tolerance_party_csr into l_header_tolerance_operand,
                                                 l_header_tolerance_calc_code;
            CLOSE header_tolerance_party_csr;

            IF l_header_tolerance_calc_code is NULL THEN
               OPEN  header_tolerance_sys_csr;
               FETCH header_tolerance_sys_csr into l_header_tolerance_operand,
                                                   l_header_tolerance_calc_code;
               CLOSE header_tolerance_sys_csr;
            END IF;
         END IF;

         -- Set line tolerance
         OPEN  line_tolerance_account_csr(l_partner_cust_account_id);
         FETCH line_tolerance_account_csr into l_line_tolerance_operand,
                                                    l_line_tolerance_calc_code;
         CLOSE line_tolerance_account_csr;

         IF l_line_tolerance_calc_code is NULL THEN
            OPEN  line_tolerance_party_csr(l_partner_party_id);
            FETCH line_tolerance_party_csr into l_line_tolerance_operand,
                                                l_line_tolerance_calc_code;
            CLOSE line_tolerance_party_csr;

            IF l_line_tolerance_calc_code is NULL THEN
               OPEN  line_tolerance_sys_csr;
               FETCH line_tolerance_sys_csr into l_line_tolerance_operand,
                                                 l_line_tolerance_calc_code;
               CLOSE line_tolerance_sys_csr;
            END IF;
         END IF;

      END IF;

      UPDATE ozf_resale_batches_all
      SET   header_tolerance_operand = l_header_tolerance_operand,
            header_tolerance_calc_code = l_header_tolerance_calc_code,
            line_tolerance_operand  = l_line_tolerance_operand,
            line_tolerance_calc_code = l_line_tolerance_calc_code
      WHERE resale_batch_id = l_resale_batch_id;

      l_resultout := 'COMPLETE';
      --
   END IF;

   --  CANCEL mode  - Normal Process Execution
   IF (funcmode = 'CANCEL') THEN
     l_resultout := 'COMPLETE';
   END IF;

   --  TIMEOUT mode  - Normal Process Execution
   IF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE';
   END IF;

   resultout := l_resultout;
   RETURN;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Set_Tolerance_Level;


---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Batch
--
-- PURPOSE
--    This procedure validates the batch details
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Batch (
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Batch';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout                    VARCHAR2(30);
   l_batch_status                 VARCHAR2(30);
   l_batch_id                     NUMBER;
   l_return_status                VARCHAR2(1);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(2000);
   l_error_msg                    VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
   --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);

      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch ID '|| l_batch_id);
      END IF;
      IF l_batch_id IS NOT NULL THEN
         OZF_RESALE_COMMON_PVT.Validate_Batch (
            p_api_version         => 1.0,
            p_init_msg_list       => FND_API.G_FALSE,
            p_commit              => FND_API.G_FALSE,
            p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
            p_resale_batch_id     => l_batch_id,
            x_batch_status        => l_batch_status,
            x_return_status       => l_return_status,
            x_msg_count           => l_msg_count,
            x_msg_data            => l_msg_data );

         IF OZF_DEBUG_LOW_ON THEN
            OZF_UTILITY_PVT.debug_message('Validate Batch is complete '||l_return_status);
         END IF;
         IF l_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         l_resultout := 'COMPLETE:SUCCESS';
      ELSE
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
   --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:SUCCESS';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Validate_Batch;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order
--
-- PURPOSE
--    This procedure contains order level validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Order (
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Order';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout                    VARCHAR2(30);
   l_batch_id                     NUMBER;
   l_return_status                VARCHAR2(1);
   l_msg_count                    NUMBER;
   l_msg_data                     VARCHAR2(2000);
   l_error_msg                    VARCHAR2(4000);

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype   => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);

      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch ID '|| l_batch_id);
      END IF;
      IF l_batch_id IS NOT NULL THEN
         -- Verify the line information for this batch
         OZF_RESALE_COMMON_PVT.Validate_Order_Record (
             p_api_version        => 1.0
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => l_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
            );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message('OZF_RESALE_VALIDATE_ERR');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      l_resultout := 'COMPLETE:SUCCESS';
      --
   ELSIF (funcmode = 'CANCEL') THEN
      l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
      l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode = 'TIMEOUT') THEN
      l_resultout := 'COMPLETE:SUCCESS';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Validate_Order;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Chargeback
--
-- PURPOSE
--    This procedure contains chargeback validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Chargeback
(
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Chargeback';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype   => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch ID '|| l_batch_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN
         -- Verify the line information for this batch
         OZF_CHARGEBACK_PVT.Validate_Order_Record (
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => l_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
            );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message('OZF_RESALE_CHBK_VALIDATE_ERR');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
      --
   ELSIF (funcmode = 'CANCEL') THEN
        l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
        l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode = 'TIMEOUT') THEN
        l_resultout := 'COMPLETE:SUCCESS';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      l_resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Validate_Chargeback;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Special_Pricing
--
-- PURPOSE
--    This procedure contains special pricing validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Special_Pricing
(
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Special_Pricing';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;
BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype   => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch ID '|| l_batch_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN
         -- Verify the line information for this batch
         OZF_SPECIAL_PRICING_PVT.Validate_Order_Record (
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => l_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
            );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message('OZF_RESALE_CHBK_VALIDATE_ERR');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
      --
   ELSIF (funcmode = 'CANCEL') THEN
        l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
        l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode = 'TIMEOUT') THEN
        l_resultout := 'COMPLETE:SUCCESS';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      l_resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Validate_Special_Pricing;

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Tracing
--
-- PURPOSE
--    This procedure contains tracing data validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Tracing
(
   itemtype   IN varchar2,
   itemkey    IN varchar2,
   actid      IN number,
   funcmode   IN varchar2,
   resultout  IN OUT NOCOPY varchar2
)
IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Tracing';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout           VARCHAR2(30);
   l_batch_id            NUMBER;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);
   l_error_msg           VARCHAR2(4000);

l_batch_org_id               NUMBER;

BEGIN
   IF OZF_DEBUG_HIGH_ON THEN
      OZF_UTILITY_PVT.debug_message('IN: ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   -- R12 MOAC Enhancement (+)
   l_batch_org_id := WF_ENGINE.GetItemAttrText(
                        itemtype  => itemtype,
                        itemkey   => itemkey,
                        aname     => 'OZF_BATCH_ORG_ID'
                     );

   IF (funcmode = 'TEST_CTX') THEN
      IF (NVL(MO_GLOBAL.get_access_mode, 'NULL') <> 'S') OR
          (NVL(MO_GLOBAL.get_current_org_id, -99) <> l_batch_org_id) THEN
         resultout := 'FALSE';
      ELSE
         resultout := 'TRUE';
      END IF;
      RETURN;
   END IF;

   IF (funcmode = 'SET_CTX') THEN
      MO_GLOBAL.set_policy_context(
         p_access_mode  => 'S',
         p_org_id       => l_batch_org_id
      );
      --resultout := 'COMPLETE:';
      RETURN;
   END IF;
   -- R12 MOAC Enhancement (-)

   IF (funcmode = 'RUN') THEN
      --
      l_batch_id := WF_ENGINE.GetItemAttrText(itemtype   => itemtype,
                                              itemkey  => itemkey,
                                              aname    => G_WF_ATTR_BATCH_ID);
      IF OZF_DEBUG_LOW_ON THEN
         OZF_UTILITY_PVT.debug_message('Batch ID '|| l_batch_id);
      END IF;

      IF l_batch_id IS NOT NULL THEN
         -- Verify the line information for this batch
         OZF_TRACING_ORDER_PVT.Validate_Order_Record (
             p_api_version        => 1
            ,p_init_msg_list      => FND_API.G_FALSE
            ,p_commit             => FND_API.G_FALSE
            ,p_validation_level   => FND_API.G_VALID_LEVEL_FULL
            ,p_resale_batch_id    => l_batch_id
            ,x_return_status      => l_return_status
            ,x_msg_data           => l_msg_data
            ,x_msg_count          => l_msg_count
            );
         IF l_return_status<> FND_API.G_RET_STS_SUCCESS THEN
            OZF_UTILITY_PVT.error_message('OZF_RESALE_TRAC_VALIDATE_ERR');
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSE
         OZF_UTILITY_PVT.error_message('OZF_RESALE_BATCH_ID_NULL');
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      l_resultout := 'COMPLETE:SUCCESS';
      --
   ELSIF (funcmode = 'CANCEL') THEN
        l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode IN ('RESPOND', 'FORWARD', 'TRANSFER')) THEN
        l_resultout := 'COMPLETE:SUCCESS';
   ELSIF (funcmode = 'TIMEOUT') THEN
        l_resultout := 'COMPLETE:SUCCESS';
   END IF;

   resultout := l_resultout;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      l_resultout := 'COMPLETE:ERROR';
      RETURN;
   WHEN OTHERS THEN
      IF OZF_UNEXP_ERROR THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => l_msg_count,
          p_data  => l_msg_data
      );
      Handle_Error(
          p_itemtype     => itemtype
         ,p_itemkey      => itemkey
         ,p_msg_count    => l_msg_count
         ,p_msg_data     => l_msg_data
         ,p_process_name => l_api_name
         ,x_error_msg    => l_error_msg
      );
      WF_CORE.context( G_PKG_NAME,l_api_name,itemtype,itemkey,actid,l_error_msg);
      RAISE;
END Validate_Tracing;


PROCEDURE Start_Data_Process(
    p_resale_batch_id       IN  NUMBER
   ,p_caller_type           IN  VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30)    := 'Start_Data_Process';

l_itemtype                   VARCHAR2(8)     := 'OZFRSIFD';
l_process                    VARCHAR2(30)    := 'IFACE_DATA_PROCESS';
l_itemkey                    VARCHAR2(240);
l_itemuserkey                VARCHAR2(240);

CURSOR get_batch_info(p_resale_batch_id IN NUMBER) IS
   SELECT status_code
   ,      last_updated_by
   ,      batch_type
   ,      batch_number
   FROM  ozf_resale_batches_all
   WHERE resale_batch_id = p_resale_batch_id;

CURSOR emp_infor_csr(p_res_id NUMBER) IS
-- BUBG 4953233 (+)
  SELECT  ppl.person_id
  FROM jtf_rs_resource_extns rsc
     , per_people_f ppl
  WHERE rsc.category = 'EMPLOYEE'
  AND ppl.person_id = rsc.source_id
  AND rsc.resource_id=p_res_id;
  -- SELECT employee_id
  -- FROM jtf_rs_res_emp_vl
  -- WHERE resource_id = p_res_id ;
-- BUBG 4953233 (-)



l_batch_info                 get_batch_info%ROWTYPE;
l_emp_id                     NUMBER;
l_user_name                  VARCHAR2(100);
l_display_name               VARCHAR2(100);

BEGIN

   OPEN get_batch_info(p_resale_batch_id);
   FETCH get_batch_info INTO l_batch_info;
   CLOSE get_batch_info;

   IF l_batch_info.status_code IN ('OPEN', 'DISPUTED') THEN
      UPDATE ozf_resale_batches_all
      SET status_code = 'PROCESSING'
      WHERE resale_batch_id = p_resale_batch_id;
   END IF;
   --Bugfix: 6510872
   --l_itemkey := p_resale_batch_id||'-'||TO_CHAR(sysdate, 'YYYY-MMDD-HH24MISS');
   l_itemkey :='IDP-'|| p_resale_batch_id||'-'||TO_CHAR(sysdate, 'YYYY-MMDD-HH24MISS');
   l_itemuserkey := l_batch_info.batch_type||'-'||
                    l_batch_info.batch_number||'-'||
                    TO_CHAR(sysdate, 'YYYY-MMDD-HH24MISS');


   WF_ENGINE.CreateProcess(
         itemType   => l_itemtype,
         itemKey    => l_itemkey,
         process    => l_process
   );

   WF_ENGINE.SetItemUserKey(
         itemType   => l_itemtype,
         itemKey    => l_itemkey,
         userKey    => l_itemuserkey
   );

   OPEN emp_infor_csr(OZF_UTILITY_PVT.get_resource_id(l_batch_info.last_updated_by));
   FETCH emp_infor_csr INTO l_emp_id;
   CLOSE emp_infor_csr;

   WF_DIRECTORY.GetRoleName(
          p_orig_system      => 'PER',
          p_orig_system_id   => l_emp_id ,
          p_name             => l_user_name,
          p_display_name     => l_display_name
   );

   WF_ENGINE.SetItemOwner(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey,
          owner              => l_user_name
   );

   WF_ENGINE.SetItemAttrText(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey ,
          aname              => 'OZF_RESALE_BATCH_ID',
          avalue             => p_resale_batch_id
   );

   WF_ENGINE.SetItemAttrText(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey ,
          aname              => 'WF_ADMINISTRATOR',
          avalue             => l_user_name
   );

   WF_ENGINE.SetItemAttrText(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey ,
          aname              => 'OZF_RESALE_BATCH_CALLER',
          avalue             => p_caller_type
   );

   WF_ENGINE.StartProcess(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey
   );


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT',G_PKG_NAME||'.'||l_api_name||': Error');
    FND_MSG_PUB.Add;
   END IF;
   RAISE;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT',G_PKG_NAME||'.'||l_api_name||': Error');
    FND_MSG_PUB.Add;
   END IF;
   RAISE;
 WHEN OTHERS THEN
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
   END IF;
   RAISE;
END Start_Data_Process;


PROCEDURE Start_Batch_Payment(
    p_resale_batch_id       IN  NUMBER
   ,p_caller_type           IN  VARCHAR2
)
IS
l_api_name          CONSTANT VARCHAR2(30)    := 'Start_Batch_Payment';

l_itemtype                   VARCHAR2(8)     := 'OZFRSIFD';
l_process                    VARCHAR2(30)    := 'PAYMENT_INITIATION_PROCESS';
l_itemkey                    VARCHAR2(240);
l_itemuserkey                VARCHAR2(240);

CURSOR get_batch_info(p_resale_batch_id IN NUMBER) IS
   SELECT status_code
   ,      last_updated_by
   ,      batch_type
   ,      batch_number
   FROM  ozf_resale_batches_all
   WHERE resale_batch_id = p_resale_batch_id;

CURSOR emp_infor_csr(p_res_id NUMBER) IS
-- BUBG 4953233 (+)
  SELECT  ppl.person_id
  FROM jtf_rs_resource_extns rsc
     , per_people_f ppl
  WHERE rsc.category = 'EMPLOYEE'
  AND ppl.person_id = rsc.source_id
  AND rsc.resource_id=p_res_id;
  -- SELECT employee_id
  -- FROM jtf_rs_res_emp_vl
  -- WHERE resource_id = p_res_id ;
-- BUBG 4953233 (-)

l_batch_info                 get_batch_info%ROWTYPE;
l_emp_id                     NUMBER;
l_user_name                  VARCHAR2(100);
l_display_name               VARCHAR2(100);

BEGIN

   OPEN get_batch_info(p_resale_batch_id);
   FETCH get_batch_info INTO l_batch_info;
   CLOSE get_batch_info;

   IF l_batch_info.status_code IN ('OPEN', 'DISPUTED', 'PROCESSED') THEN
      UPDATE ozf_resale_batches_all
      SET status_code = 'PENDING_PAYMENT'
      WHERE resale_batch_id = p_resale_batch_id;
   END IF;
   --Bugfix: 6510872
   --l_itemkey := p_resale_batch_id||'-'||TO_CHAR(sysdate, 'YYYY-MMDD-HH24MISS');
   l_itemkey := 'PIP-'||p_resale_batch_id||'-'||TO_CHAR(sysdate, 'YYYY-MMDD-HH24MISS');
   l_itemuserkey := l_batch_info.batch_type||'-'||
                    l_batch_info.batch_number||'-'||
                    TO_CHAR(sysdate, 'YYYY-MMDD-HH24MISS');


   WF_ENGINE.CreateProcess(
         itemType   => l_itemtype,
         itemKey    => l_itemkey,
         process    => l_process
   );

   WF_ENGINE.SetItemUserKey(
         itemType   => l_itemtype,
         itemKey    => l_itemkey,
         userKey    => l_itemuserkey
   );

   OPEN emp_infor_csr(OZF_UTILITY_PVT.get_resource_id(l_batch_info.last_updated_by));
   FETCH emp_infor_csr INTO l_emp_id;
   CLOSE emp_infor_csr;

   WF_DIRECTORY.GetRoleName(
          p_orig_system      => 'PER',
          p_orig_system_id   => l_emp_id ,
          p_name             => l_user_name,
          p_display_name     => l_display_name
   );

   WF_ENGINE.SetItemOwner(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey,
          owner              => l_user_name
   );

   WF_ENGINE.SetItemAttrText(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey ,
          aname              => 'OZF_RESALE_BATCH_ID',
          avalue             => p_resale_batch_id
   );

   WF_ENGINE.SetItemAttrText(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey ,
          aname              => 'WF_ADMINISTRATOR',
          avalue             => l_user_name
   );

   WF_ENGINE.SetItemAttrText(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey ,
          aname              => 'OZF_RESALE_BATCH_CALLER',
          avalue             => p_caller_type
   );

   WF_ENGINE.StartProcess(
          itemtype           => l_itemtype,
          itemkey            => l_itemkey
   );


EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT',G_PKG_NAME||'.'||l_api_name||': Error');
    FND_MSG_PUB.Add;
   END IF;
   RAISE;
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
    FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT',G_PKG_NAME||'.'||l_api_name||': Error');
    FND_MSG_PUB.Add;
   END IF;
   RAISE;
 WHEN OTHERS THEN
   IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
   END IF;
   RAISE;
END Start_Batch_Payment;

END OZF_RESALE_WF_PVT;

/
