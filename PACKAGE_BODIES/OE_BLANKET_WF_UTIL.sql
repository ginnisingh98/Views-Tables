--------------------------------------------------------
--  DDL for Package Body OE_BLANKET_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_BLANKET_WF_UTIL" AS
/* $Header: OEXUBWFB.pls 120.1.12010000.2 2009/08/21 08:28:23 nitagarw ship $ */
G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Blanket_wf_Util';

PROCEDURE create_and_start_flow ( p_header_id                IN NUMBER,
                                  p_transaction_phase_code   IN VARCHAR2,
                                  p_blanket_number           IN NUMBER,
                                  x_return_status            OUT NOCOPY VARCHAR2,
                                  x_msg_count                OUT NOCOPY NUMBER,
                                  x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_header_rec  OE_Blanket_Pub.header_rec_type;
l_control_rec OE_Blanket_Pub.control_rec_type;
x_header_rec  OE_Blanket_Pub.header_rec_type;
l_header_id   NUMBER;
l_count       NUMBER;
l_item_type   varchar2(20);
l_sales_doc_type_code varchar2(10) := 'B';
l_flow_status_code    varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   if l_debug_level > 0 then
      oe_debug_pub.ADD('Entering create_and_start_flow ', 1);
   end if;

   /* OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'BLANKET_HEADER_WF'
        ,p_entity_id                    => p_header_id
        ,p_header_id                    => p_header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id            => null
        ,p_source_document_type_id    => null); */

 --  if x_return_status = FND_API.G_RET_STS_SUCCESS   THEN

   if l_debug_level > 0 then
      oe_debug_pub.ADD('Entering create_and_start_flow '||x_return_status,2 );
   end if;
   IF p_transaction_phase_code = 'F' then
     l_item_type := 'OEBH';
   ELSE
     l_item_type := 'OENH';
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_order_wf_util.createstart_hdrinternal( P_ITEM_TYPE => l_item_type,
                                             P_HEADER_ID => p_header_id,
                                             P_TRANSACTION_NUMBER => p_blanket_number,
                                             P_SALES_DOCUMENT_TYPE_CODE => l_sales_doc_type_code);
   oe_order_wf_util.Start_All_Flows;

      IF p_transaction_phase_code = 'F' then

         if l_debug_level > 0 then
             oe_debug_pub.ADD('Entering create_and_start_flow in full '||x_return_status,3 );
         end if;

         select count(1)
         into l_count
         from wf_items
         where item_type  = OE_GLOBALS.G_WFI_NGO
         and item_key     = to_char(p_header_id);

         if l_count = 0
         then
            l_flow_status_code := 'ENTERED';
            oe_order_wf_util.update_flow_status_code (
                                P_HEADER_ID => p_header_id,
                                P_LINE_ID => null,
                                P_FLOW_STATUS_CODE => l_flow_status_code,
                                P_ITEM_TYPE => l_item_type,
                                P_SALES_DOCUMENT_TYPE_CODE => l_sales_doc_type_code,
                                X_RETURN_STATUS => x_return_status );
         if l_debug_level > 0 then
             oe_debug_pub.ADD('Exiting create_and_start_flow in full '||x_return_status,3 );
         end if;
         END IF;

   -- Call workflow api to update the flow

      ELSE
         if l_debug_level > 0 then
             oe_debug_pub.ADD('Entering create_and_start_flow in neg '||x_return_status,3 );
         end if;
         l_flow_status_code := 'DRAFT';
         oe_order_wf_util.update_flow_status_code (
                                P_HEADER_ID => p_header_id,
                                P_LINE_ID   => null,
                                P_FLOW_STATUS_CODE => l_flow_status_code,
                                P_ITEM_TYPE => l_item_type,
                                P_SALES_DOCUMENT_TYPE_CODE => l_sales_doc_type_code,
                                X_RETURN_STATUS => x_return_status );
         if l_debug_level > 0 then
             oe_debug_pub.ADD('Exiting create_and_start_flow in neg '||x_return_status,3 );
         end if;

   -- Call workflow api to update the flow

      END IF;

  --  Get message count and data
  --  end if;
      oe_debug_pub.ADD(' Exsiting create_and_start_flow '||x_return_status,2 );

EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         /* IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'create_and_start_flow');
          END IF; */
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end create_and_start_flow;

PROCEDURE Submit_Draft ( p_header_id                IN NUMBER,
                         p_transaction_phase_code   IN VARCHAR2,
                         x_return_status            OUT NOCOPY VARCHAR2,
                         x_msg_count                OUT NOCOPY NUMBER,
                         x_msg_data                 OUT NOCOPY VARCHAR2)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
submit_draft_exception    exception;
l_return_status   varchar2(1);
l_qa_return_status varchar2(1) := 'Y';
l_msg_count number;
l_msg_data varchar2(2000);
l_blanket_lock_control number;
l_Last_Updated_By  number; --bug6627904
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft ', 1);
   end if;
   OE_MSG_PUB.initialize;
   OE_MSG_PUB.set_msg_context(
         p_entity_code                  => 'BLANKET_HEADER'
        ,p_entity_id                    => p_header_id
        ,p_header_id                    => p_header_id
        ,p_line_id                      => null
        ,p_orig_sys_document_ref        => null
        ,p_orig_sys_document_line_ref   => null
        ,p_change_sequence              => null
        ,p_source_document_id           => null
        ,p_source_document_line_id      => null
        ,p_order_source_id            => null
        ,p_source_document_type_id    => null);

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Calling Q and A Contracts
   -- qa_articles is called with NORMAL mode
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft before QA'||to_char(p_header_id));
   end if;

   l_qa_return_status := 'S'; --- Temporally setting this value .



   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft after QA'||to_char(p_header_id));
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft after QA l_qa_R '||l_qa_return_status);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft after QA l_r'||l_return_status);
   end if;
 ---  If the Qand A is passed

   IF p_transaction_phase_code = 'N'
   THEN
      OE_NEGOTIATE_WF.submit_draft(p_header_id     => p_header_id,
                                   x_return_status => l_return_status);
      if l_debug_level > 0 then
         oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft after Neg ret'||l_return_status);
      end if;
   ELSE
      oe_blanket_wf.submit_draft(p_header_id  => p_header_id,
                                 p_transaction_phase_code => p_transaction_phase_code,
                                 x_return_status => l_return_status);
      if l_debug_level > 0 then
         oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Submit_draft after Ful ret'||l_return_status);
      end if;
   END IF;
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
          x_return_status := l_return_status;
          RAISE submit_draft_exception;
   else
          x_return_status := l_return_status;
           l_Last_Updated_By  := Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1);--bug6627904
     update oe_blanket_headers
     set lock_control = lock_control + 1,
         Last_Updated_By = l_Last_Updated_By,
         LAST_UPDATE_DATE = sysdate
     where header_id = p_header_id;
   END IF;
   --  Get message count and data

   OE_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data => x_msg_data);

   if l_debug_level > 0 then
    oe_debug_pub.ADD('End OE_BLANKET_WF_UTIL.Submit_draft return status'||l_return_status);
    oe_debug_pub.ADD('End OE_BLANKET_WF_UTIL.Submit_draft qa return status'||l_qa_return_status);
   end if;

EXCEPTION

    WHEN SUBMIT_DRAFT_EXCEPTION THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN
      if l_debug_level > 0 then
         oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
         oe_debug_pub.ADD('In Blanket Workflow Exception QA return Status'||l_qa_return_Status);
         oe_debug_pub.ADD('In Blanket Workflow Exception l return Status'||l_return_Status);
      end if;

      x_return_status := l_return_status;

        /* IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
        'Submit_Draft');
        END IF; */
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Submit_Draft;

PROCEDURE Blanket_Date_Changed ( p_header_id     IN NUMBER,
                                 x_return_status OUT NOCOPY VARCHAR2)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
l_status               VARCHAR2(30);
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Blanket_Date_Changed ', 1);
   end if;

   -- Bug 3217417
   -- Call Extend API if status is Expired and Date is Changed
   -- For all other statuses, call Date_Changed API
   select flow_status_code
     into l_status
     from oe_blanket_headers
    where header_id = p_header_id;

   IF l_status = 'EXPIRED' THEN
    oe_blanket_wf.Extend(p_header_id     => p_header_id,
                        x_return_status => x_return_status);
   ELSE
    oe_blanket_wf.Blanket_Date_Changed(p_header_id     => p_header_id,
                                       x_return_status => x_return_status);
   END IF;
 /*  OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data); */


EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Blanket_Date_Changed');
          END IF;
          /* OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                                   ,   p_data      =>      x_msg_data); */

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Blanket_Date_Changed;

PROCEDURE customer_acceptance (p_header_id     IN NUMBER,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count                OUT NOCOPY NUMBER,
                               x_msg_data                 OUT NOCOPY VARCHAR2)

IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Accepted ', 1);
   end if;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OE_NEGOTIATE_WF.Customer_Accepted(p_header_id     => p_header_id,
                                     x_return_status => x_return_status);
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);


EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Customer_Accepted');
          END IF;
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Customer_acceptance;

PROCEDURE Customer_Rejected (p_header_id           IN NUMBER,
                             p_entity_code         IN VARCHAR2,
                             p_version_number      IN NUMBER,
                             p_reason_type         IN VARCHAR2,
                             p_reason_code         IN VARCHAR2,
                             p_reason_comments     IN VARCHAR2,
                             x_return_status       OUT NOCOPY VARCHAR2,
                             x_msg_count           OUT NOCOPY NUMBER,
                             x_msg_data            OUT NOCOPY VARCHAR2)
IS
l_header_id number := p_header_id;
l_entity_id varchar2(240) := p_entity_code;
l_version_number number := p_version_number;
l_reason_type varchar2(240) := p_reason_type;
l_reason_code varchar2(240) := p_reason_code;
l_reason_comments varchar2(2000) := p_reason_comments;
l_return_status varchar2(1);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Rejected ', 1);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Rejected HID'||l_header_id);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Rejected VNUM'||l_version_number);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Rejected RTYPE'||l_reason_type);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Rejected RCODE'||l_reason_code);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_Rejected RCOMM'||l_reason_comments);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Customer_RejecteD RETSTAT'||x_return_status);
   end if;
   OE_NEGOTIATE_WF.Customer_Rejected(p_header_id => l_header_id,
                                     p_entity_code => l_entity_id,
                                     p_version_number => l_version_number,
                                     p_reason_type => l_reason_type,
                                     p_reason_code => l_reason_code,
                                     p_reason_comments => l_reason_comments,
                                     x_return_status => x_return_status);
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_Rejected ', 1);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_Rejected HID '||l_header_id);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_Rejected VNUM '||l_version_number);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_Rejected RTYPE '||l_reason_type);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_Rejected RCODE '||l_reason_code);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_Rejected RCOMM '||l_reason_comments);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.Customer_RejecteD RETSTAT '||x_return_status);
   end if;

   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);


EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Customer_Rejected');
          END IF;
                  OE_MSG_PUB.Count_And_Get
                (   p_count     =>      x_msg_count
                ,   p_data      =>      x_msg_data
                );

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Customer_Rejected;

PROCEDURE check_release (p_blanket_number IN NUMBER,
                 x_return_status OUT NOCOPY VARCHAR2)
IS

--
l_dumy varchar2(10) := 'FALSE';
l_return_status varchar2(10);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Check_release ', 1);
   end if;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   if p_blanket_number is not null then

       SELECT  'TRUE'
       INTO    l_dumy
       FROM    oe_order_headers
       WHERE   blanket_number = p_blanket_number
       AND     open_flag = 'Y'
       AND     ROWNUM = 1;
       IF l_dumy = 'TRUE' THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          fnd_message.set_name('ONT', 'OE_BKT_NO_DATE_CHANGE');
          oe_msg_pub.add;
       END IF;

       IF l_dumy = 'FALSE' THEN
          SELECT 'TRUE'
          INTO  l_dumy
          FROM oe_order_lines
          WHERE blanket_number = p_blanket_number
          AND     open_flag = 'Y'
          AND ROWNUM = 1;
          IF l_dumy = 'TRUE' THEN
             l_return_status := FND_API.G_RET_STS_ERROR;
             fnd_message.set_name('ONT', 'OE_BKT_NO_DATE_CHANGE');
             oe_msg_pub.add;
          END IF;
       END IF;
   x_return_status := l_return_status;
   end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status := l_return_status;

    WHEN OTHERS THEN
        x_return_status :='P';
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Check Release');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CHECK_RELEASE;

PROCEDURE Extend (p_header_id     IN NUMBER,
                  x_return_status OUT NOCOPY VARCHAR2)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Extend ', 1);
   end if;
    OE_BLANKET_WF.Extend(p_header_id     => p_header_id,
                         x_return_status => x_return_status);

EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Extend');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Extend;

PROCEDURE Close (p_header_id     IN NUMBER,
                 x_return_status       OUT NOCOPY VARCHAR2,
                 x_msg_count           OUT NOCOPY NUMBER,
                 x_msg_data            OUT NOCOPY VARCHAR2)
IS

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Close ', 1);
   end if;
    OE_BLANKET_WF.Close(p_header_id     => p_header_id,
                        x_return_status => x_return_status);
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);

EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Close');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Close;

PROCEDURE Terminate (p_header_id           IN NUMBER,
                     p_terminated_by       IN NUMBER,
                     p_version_number      IN NUMBER,
                     p_reason_type         IN VARCHAR2,
                     p_reason_code         IN VARCHAR2,
                     p_reason_comments     IN VARCHAR2,
                     x_return_status       OUT NOCOPY VARCHAR2,
                     x_msg_count           OUT NOCOPY NUMBER,
                     x_msg_data            OUT NOCOPY VARCHAR2)
IS
l_header_id number := p_header_id;
l_terminated_by NUMBER := p_terminated_by;
l_version_number number := p_version_number;
l_reason_type varchar2(240) := p_reason_type;
l_reason_code varchar2(240) := p_reason_code;
l_reason_comments varchar2(2000) := p_reason_comments;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Terminate ', 1);
   end if;
   OE_BLANKET_WF.Terminate(p_header_id => l_header_id,
                             p_terminated_by => l_terminated_by,
                             p_version_number => l_version_number,
                             p_reason_type => l_reason_type,
                             p_reason_code => l_reason_code,
                             p_reason_comments => l_reason_comments,
                             x_return_status => x_return_status);
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);

EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Terminate');
          END IF;
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Terminate;

PROCEDURE Lost (p_header_id           IN NUMBER,
                p_entity_code         IN VARCHAR2,
                p_version_number      IN NUMBER,
                p_reason_type         IN VARCHAR2,
                p_reason_code         IN VARCHAR2,
                p_reason_comments     IN VARCHAR2,
                x_return_status       OUT NOCOPY VARCHAR2,
                x_msg_count           OUT NOCOPY NUMBER,
                x_msg_data            OUT NOCOPY VARCHAR2)
IS
l_header_id number := p_header_id;
l_entity_code  varchar2(100) := p_entity_code;
l_version_number number := p_version_number;
l_reason_type varchar2(240) := p_reason_type;
l_reason_code varchar2(240) := p_reason_code;
l_reason_comments varchar2(2000) := p_reason_comments;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST ', 1);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST HID'||l_header_id);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST ECODE'||l_entity_code);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST VNUM'||l_version_number);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST RTYPE'||l_reason_type);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST RCODE'||l_reason_code);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST RCOMM'||l_reason_comments);
    oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.LOST RETSTAT'||x_return_status);
   end if;
   OE_NEGOTIATE_WF.Lost(p_header_id => l_header_id,
                      p_entity_code => l_entity_code,
                      p_version_number => l_version_number,
                      p_reason_type => l_reason_type,
                      p_reason_code => l_reason_code,
                      p_reason_comments => l_reason_comments,
                      x_return_status => x_return_status);
   if l_debug_level > 0 then
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST ', 1);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST HID'||l_header_id);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST ECODE'||l_entity_code);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST VNUM'||l_version_number);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST RTYPE'||l_reason_type);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST RCODE'||l_reason_code);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST RCOMM'||l_reason_comments);
    oe_debug_pub.ADD('Entering OE_NEGOTIATE_WF.LOST RETSTAT'||x_return_status);
   end if;
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);


EXCEPTION
    WHEN OTHERS THEN
          if l_debug_level > 0 then
                oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
          end if;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                    'Lost');
          END IF;
   OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Lost;

PROCEDURE Complete_Negotiation (p_header_id     IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2)
                               -- x_msg_count     OUT NOCOPY NUMBER,
                               -- x_msg_data      OUT NOCOPY VARCHAR2)
IS
l_return_status                 varchar2(1);
l_result                        varchar2(1);
l_rowtype_rec                   oe_ak_blanket_headers_v%rowtype;
l_action                        number;
l_msg_count                     number;
l_msg_data                      varchar2(2000);
l_header_id                     number;
l_line_id                       number;
l_blanket_lock_control          number;
l_debug_level          CONSTANT NUMBER := oe_debug_pub.g_debug_level;               -- Bug 8816026
l_item_type                     varchar2(10) := 'OEBH';
l_sales_doc_type_code           varchar2(1)  := 'B';
l_blanket_number                number;
Blanket_Complete_Negotiation    exception;
l_Last_Updated_By  number;

cursor c_get_lines(p_header_id in number) is
select line_id from oe_blanket_lines
where header_id = p_header_id;


Begin
   l_header_id := p_header_id;
   if l_debug_level > 0 then
        oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Complete_Negotiation in WF UTIL'||l_return_status);
   end if;
   IF l_header_id is not null then

     SAVEPOINT Save_Blanket_Changes;

     -- begin fix for bug 3559904: check constraint for phase change
     IF NOT (OE_Blanket_Util.g_old_version_captured) THEN
        OE_Blanket_Util.Query_Blanket(p_header_id => p_header_id, p_x_header_rec => OE_Blanket_Util.g_old_header_hist_rec, p_x_line_tbl => OE_Blanket_Util.g_old_line_hist_tbl, x_return_status => l_return_status);
        OE_Blanket_Util.g_old_version_captured := TRUE;
     END IF;

     OE_BLANKET_UTIL.API_Rec_To_Rowtype_Rec(OE_Blanket_Util.g_old_header_hist_rec,l_rowtype_rec);

     -- Initialize security global record
     OE_Blanket_Header_Security.g_record := l_rowtype_rec;
     OE_Blanket_Header_Security.g_check_all_cols_constraint := 'Y';
     OE_Quote_Util.G_COMPLETE_NEG := 'Y';

     BEGIN
       l_result := OE_Blanket_Header_Security.Is_OP_Constrained
                               (p_operation => OE_PC_GLOBALS.UPDATE_OP
                               ,p_column_name => 'TRANSACTION_PHASE_CODE'
                               ,p_record => l_rowtype_rec
                               ,x_on_operation_action => l_action
                               );

     EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          raise fnd_api.g_exc_error;
     END;

     if l_result = OE_PC_GLOBALS.YES then
        l_return_status := FND_API.G_RET_STS_ERROR;
        raise fnd_api.g_exc_error;
     end if;

     OE_GLOBALS.G_REASON_CODE := 'SYSTEM';
     OE_GLOBALS.G_CAPTURED_REASON := 'Y';

     OE_Versioning_Util.Perform_Versioning(p_header_id => p_header_id,
                 p_document_type => 'BLANKETS',
                 x_msg_count => l_msg_count,
                 x_msg_data => l_msg_data,
                 x_return_status => l_return_status);

     OE_Blanket_Util.g_old_version_captured := FALSE;
     OE_Quote_Util.G_COMPLETE_NEG := 'N';

     l_blanket_number := OE_Blanket_Util.g_old_header_hist_rec.order_number;

     -- end fix for bug 3559904

   if l_debug_level > 0 then
        oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Complete_Negotiation in WF UTIL HDR ID'
                                                      ||l_header_id);
        oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Complete_Negotiation in WF UTIL BLKT NUM'
                                                      ||l_blanket_number);
   end if;
     OE_Blanket_Util.Lock_Row(p_blanket_id=>p_header_id
                              , p_blanket_line_id => null
                              , p_x_lock_control=>l_blanket_lock_control
                              , x_return_status => l_return_status
                              , x_msg_count => l_msg_count
                              , x_msg_data => l_msg_data);

     if l_debug_level > 0 then
        oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Complete_Negotiation after LOCKING HEADER'
                                                           ||l_return_status);
     end if;
     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := l_return_status;
        ROLLBACK TO SAVEPOINT Save_Blanket_Changes;
     END IF;

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_return_status;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
/*
                   OE_MSG_PUB.set_msg_context (p_entity_code => 'BLANKET',
                                               p_entity_id => p_header_id,
                                               p_header_id => p_header_id);
*/
     l_Last_Updated_By  := Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1);
     update oe_blanket_headers
     set TRANSACTION_PHASE_CODE = 'F',
         lock_control = lock_control + 1,
         Last_Updated_By = l_Last_Updated_By,
         LAST_UPDATE_DATE = sysdate
     where header_id = p_header_id;


/* Call the lines and loop around for the lock and update the transaction Phase */


     OPEN c_get_lines(l_header_id);
     LOOP
        FETCH c_get_lines INTO l_line_id;
        EXIT WHEN c_get_lines%NOTFOUND;

        OE_Blanket_Util.Lock_Row(p_blanket_id=>null
                                 , p_blanket_line_id => l_line_id
                                 , p_x_lock_control=>l_blanket_lock_control
                                 , x_return_status => l_return_status
                                 , x_msg_count => l_msg_count
                                 , x_msg_data => l_msg_data);
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           x_return_status := l_return_status;
           ROLLBACK TO SAVEPOINT Save_Blanket_Changes;
        END IF;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
           x_return_status := l_return_status;
           RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           x_return_status := l_return_status;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        update oe_blanket_lines
        set TRANSACTION_PHASE_CODE = 'F',
            lock_control = lock_control + 1,
            Last_Updated_By = l_Last_Updated_By,
            LAST_UPDATE_DATE = sysdate
        where header_id = l_header_id and line_id = l_line_id;
        if l_debug_level > 0 then
           oe_debug_pub.ADD('Entering OE_BLANKET_WF_UTIL.Complete_Negotiation after UPDATE'
                                                ||l_return_status);
        end if;
     END LOOP;
     CLOSE c_get_lines;
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        oe_order_wf_util.createstart_hdrinternal( P_ITEM_TYPE => l_item_type,
                                                  P_HEADER_ID => l_header_id,
                                                  P_TRANSACTION_NUMBER => l_blanket_number,
                                                  P_SALES_DOCUMENT_TYPE_CODE => l_sales_doc_type_code);
        oe_order_wf_util.Start_All_Flows;
        x_return_status := l_return_status;                     -- Bug 8816026

     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        x_return_status := l_return_status;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := l_return_status;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF;
     if l_debug_level > 0 then
        oe_debug_pub.ADD('End OE_BLANKET_WF_UTIL.Complete_Negotiation return status'||l_return_status);
     end if;
/*    OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data);
*/

EXCEPTION

    WHEN Blanket_Complete_Negotiation THEN
        OE_Quote_Util.G_COMPLETE_NEG := 'N';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
        OE_Quote_Util.G_COMPLETE_NEG := 'N';
        if l_debug_level > 0 then
           oe_debug_pub.ADD('In Blanket Workflow Execution error ', 1);
        end if;

        x_return_status := l_return_status;

    WHEN OTHERS THEN
        OE_Quote_Util.G_COMPLETE_NEG := 'N';

        if l_debug_level > 0 then
           oe_debug_pub.ADD('In Blanket Workflow Exception ', 1);
           oe_debug_pub.ADD('In Blanket Workflow Exception Complete Negotiation return Status'
                                                  ||l_return_Status);
        end if;

        x_return_status := l_return_status;

 /*  OE_MSG_PUB.Count_And_Get (   p_count     =>      x_msg_count
                            ,   p_data      =>      x_msg_data); */

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

end Complete_Negotiation;

end oe_blanket_wf_util;

/
