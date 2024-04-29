--------------------------------------------------------
--  DDL for Package Body OE_OEOL_GSA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_OEOL_GSA" AS
/* $Header: OEXWGSAB.pls 120.0 2005/06/04 11:12:19 appldev noship $ */

PROCEDURE OE_GSA_CHECK(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
    l_line_rec                    OE_Order_PUB.Line_Rec_Type;
BEGIN
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  OE_Line_Util.Query_Row(p_line_id=>to_number(itemkey), x_line_rec=>l_line_rec);

   OE_MSG_PUB.set_msg_context(
      p_entity_code                => 'LINE'
     ,p_entity_id                  => l_line_rec.line_id
     ,p_header_id                  => l_line_rec.header_id
     ,p_line_id                    => l_line_rec.line_id
     ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
     ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
     ,p_change_sequence            => l_line_rec.change_sequence
     ,p_source_document_id         => l_line_rec.source_document_id
     ,p_source_document_line_id    => l_line_rec.source_document_line_id
     ,p_order_source_id            => l_line_rec.order_source_id
     ,p_source_document_type_id    => l_line_rec.source_document_type_id);

  if (funcmode = 'RUN') then
     resultout := OE_GSA_UTIL.Check_GSA_Main(l_line_rec,resultout);
    return;
  end if;


  IF (funcmode = 'CANCEL') THEN
    null;
    resultout := 'COMPLETE';
    return;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_GSA_CHECK', 'OE_GSA_CHECK',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END OE_GSA_CHECK;


PROCEDURE OE_GSA_HOLD(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
    l_line_rec                    OE_Order_PUB.Line_Rec_Type;
    l_hold_source_rec             OE_Hold_Sources_Pvt.Hold_Source_REC
                        DEFAULT OE_Hold_Sources_Pvt.G_MISS_Hold_Source_REC;
    l_return_status               VARCHAR2(30);
    l_msg_count                   number;
    l_msg_data                    VARCHAR2(240);
BEGIN
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  OE_Line_Util.Query_Row(p_line_id=>to_number(itemkey),x_line_rec=>l_line_rec);

   OE_MSG_PUB.set_msg_context(
      p_entity_code                => 'LINE'
     ,p_entity_id                  => l_line_rec.line_id
     ,p_header_id                  => l_line_rec.header_id
     ,p_line_id                    => l_line_rec.line_id
     ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
     ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
     ,p_change_sequence            => l_line_rec.change_sequence
     ,p_source_document_id         => l_line_rec.source_document_id
     ,p_source_document_line_id    => l_line_rec.source_document_line_id
     ,p_order_source_id            => l_line_rec.order_source_id
     ,p_source_document_type_id    => l_line_rec.source_document_type_id);

  IF (funcmode = 'RUN') THEN
/* -----------------------------------------------------------------------
   Old version being commented out. Parameters to Apply_Holds have changed.
   -----------------------------------------------------------------------
     OE_HOLDS_PUB.Apply_Holds(p_line_id=>l_line_rec.line_id,
			     p_return_status => l_return_status,
                             p_hold_id => OE_GSA_UTIL.Get_Hold_id(0),
			     p_entity_id =>l_line_rec.line_id,
			     p_entity_code => 'O');
*/
     l_hold_source_rec.hold_id := OE_GSA_UTIL.Get_Hold_id(0);
     l_hold_source_rec.hold_entity_id := l_line_rec.line_id;
     l_hold_source_rec.hold_entity_code := 'O';

     OE_HOLDS_PUB.Apply_Holds(
		  p_api_version         => 1.0
		, p_line_id             => l_line_rec.line_id
                , p_hold_source_rec    	=> l_hold_source_rec
		, x_return_status       => l_return_status
		, x_msg_count 		=> l_msg_count
		, x_msg_data		=> l_msg_data
);

     IF l_return_status = FND_API.g_ret_sts_success THEN
        resultout := 'COMPLETE:AP_PASS';
     ELSE
        resultout := 'COMPLETE:AP_FAIL';
        -- start data fix project
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;
        -- end data fix project
     END IF;

     return;
  END IF;


  IF (funcmode = 'CANCEL') THEN
    null;
    resultout := 'COMPLETE';
    return;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_GSA_HOLD', 'OE_GSA_HOLD',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;
END OE_GSA_HOLD;


PROCEDURE OE_GSA_RELEASE_HOLD(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
    l_line_rec                    OE_Order_PUB.Line_Rec_Type;
BEGIN
  -- start data fix project
  OE_STANDARD_WF.Set_Msg_Context(actid);
  -- end data fix project
  --
  -- RUN mode - normal process execution
  --

  OE_Line_Util.Query_Row(p_line_id=>to_number(itemkey),x_line_rec=>l_line_rec);

   OE_MSG_PUB.set_msg_context(
      p_entity_code                => 'LINE'
     ,p_entity_id                  => l_line_rec.line_id
     ,p_header_id                  => l_line_rec.header_id
     ,p_line_id                    => l_line_rec.line_id
     ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
     ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
     ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
     ,p_change_sequence            => l_line_rec.change_sequence
     ,p_source_document_id         => l_line_rec.source_document_id
     ,p_source_document_line_id    => l_line_rec.source_document_line_id
     ,p_order_source_id            => l_line_rec.order_source_id
     ,p_source_document_type_id    => l_line_rec.source_document_type_id);

  IF (funcmode = 'RUN') THEN
     resultout := OE_GSA_UTIL.Release_Hold(l_line_rec,resultout);
    return;
  END IF;

  IF (funcmode = 'CANCEL') THEN
    null;
    resultout := 'COMPLETE';
    return;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context('OE_GSA_HOLD_RELEASE', 'OE_GSA_HOLD_RELEASE',
		    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;

END OE_GSA_RELEASE_HOLD;

END OE_OEOL_GSA;

/
