--------------------------------------------------------
--  DDL for Package Body OE_ACKNOWLEDGMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ACKNOWLEDGMENT_PUB" AS
/* $Header: OEXPACKB.pls 120.9.12010000.11 2010/10/08 05:35:34 srsunkar ship $ */

/* -----------------------------------------------------------------
--  API name    OE_Acknowledgment_Pub
--
--  Type        Public
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
--  ----------------------------------------------------------------
*/

--  Global constant holding the package name

G_PKG_NAME		CONSTANT VARCHAR2(30) := 'OE_Acknowledgment_Pub';

-- { Start of the data type declaration for the Bulk Collect
-- DATA TYPES (RECORD/TABLE TYPES)

TYPE number_arr IS TABLE OF number;
TYPE char50_arr IS TABLE OF varchar2(50);

TYPE Order_Rec_Type IS RECORD
( header_id               number_arr := number_arr()
, sold_to_org_id          number_arr := number_arr()
, order_number            number_arr := number_arr()
, orig_sys_document_ref   char50_arr := char50_arr()
, order_source_id         number_arr := number_arr()
, change_sequence         char50_arr := char50_arr()
, org_id                  number_arr := number_arr()
);

Procedure  is_line_exists
(p_line_id IN NUMBER,
x_exists_flag OUT NOCOPY VARCHAR2);           -- Bug 9685021


-- End of the data type declaration for the Bulk Collect}

Function Get_Orig_Sys_Document_Ref
(p_header_id              In    Number := Null,
 p_line_id                In    Number := Null
) Return Varchar2
Is
  l_orig_sys_document_ref  Varchar2(50) := Null;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin

  If p_header_id Is Not Null Then
    Select orig_sys_document_ref
    Into   l_orig_sys_document_ref
    From   oe_order_headers
    Where  header_id = p_header_id;
  Else
    Select orig_sys_document_ref
    Into   l_orig_sys_document_ref
    From   oe_order_lines
    Where  line_id = p_line_id;
  End If;

  Return l_orig_sys_document_ref;

Exception
 When Others Then
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_ORIG_SYS_DOCUMENT_REF IS NOT DERIVED , OTHERS EXCEPTION' ) ;
   END IF;
   IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_orig_sys_document_ref');
   End if;
   Return l_orig_sys_document_ref;

End Get_Orig_Sys_Document_Ref;


Function Get_Header_Id
(p_orig_sys_document_ref  In    Varchar2 := Null,
 p_line_id                In    Number   := Null,
 p_sold_to_org_id         In    Number
) Return Number
Is
 l_header_id         Number := 0;
 l_customer_key_profile VARCHAR2(1) :=  'N';
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
Begin
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING OEXPACKB GET_HEADER_ID' ) ;
   END IF;

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;

   If p_orig_sys_document_ref Is Not Null Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_ORIG_SYS_DOCUMENT_REF IS NOT NULL'||P_ORIG_SYS_DOCUMENT_REF ) ;
    END IF;
    Select header_id
    Into   l_header_id
    From   oe_order_headers
    Where  order_source_id       = G_XML_ORDER_SOURCE_ID
    And    orig_sys_document_ref = p_orig_sys_document_ref
    AND decode(l_customer_key_profile, 'Y',
        nvl(sold_to_org_id,                  -999), 1)
      = decode(l_customer_key_profile, 'Y',
        nvl(p_sold_to_org_id,                -999), 1)
    And    rownum                = 1;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER_ID FOR THE ORIG_SYS_DOCUMENT => ' || L_HEADER_ID ) ;
    END IF;
  Elsif p_line_id Is Not Null Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_LINE_ID IS NOT NULL' ) ;
    END IF;
    Select header_id
    Into   l_header_id
    From   oe_order_lines
    Where  line_id               = p_line_id
    And    order_source_id       = G_XML_ORDER_SOURCE_ID
    And    rownum                = 1;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'HEADER_ID FOR THE LINE_ID => ' || L_HEADER_ID ) ;
    END IF;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OEXPACKB GET_HEADER_ID' ) ;
  END IF;
  return l_header_id;

Exception
 When Others Then
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_HEADER_ID IS NOT DERIVED , OTHERS EXCEPTION' ) ;
   END IF;
   IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_header_id');
   End if;
   Return l_header_id;
End Get_Header_Id;


--{Start of Procedure to raise 3a4/3a9 event from Order Import
Procedure Raise_Event_From_Oeoi
( p_transaction_type      In    Varchar2,
  p_orig_sys_document_ref In    Varchar2,
  p_request_id            In    Number,
  p_order_imported        In    Varchar2,
  p_sold_to_org_id        In    Number,
  p_change_sequence       In    Varchar2,
  p_org_id                In    Number, --arihan
  p_xml_message_id        In    Number,
  p_start_from_flow       In    Varchar2,
  p_check_for_delivery    In    Varchar2,
  x_return_status         Out NOCOPY /* file.sql.39 change */   Varchar2
)
Is
  --Pragma AUTONOMOUS_TRANSACTION;
  l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
  l_itemtype            Varchar2(6);
  l_itemkey             Number;
  l_event_name          Varchar2(50);
  l_start_from_flow     Varchar2(4) := p_start_from_flow;
  l_send_date           Date := SYSDATE + .0005;
  l_party_id            NUMBER;
  l_party_site_id       NUMBER;
  l_is_delivery_reqd    Varchar2(1);
  l_return_status       Varchar2(30);
  l_user_key            Varchar2(240);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING RAISE_EVENT_FROM_OEOI' ) ;
  END IF;

  l_event_name      := 'oracle.apps.ont.oi.po_ack.create';

  If l_start_from_flow is null then
  l_start_from_flow := OE_ORDER_IMPORT_WF.G_WFI_IMPORT_PGM;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_START_FROM_FLOW = '||L_START_FROM_FLOW ) ;
  END IF;

    IF OE_Code_Control.Code_Release_Level >= '110510' THEN
     IF p_check_for_delivery = 'Y' THEN
      OE_Acknowledgment_Pub.Is_Delivery_Required
                        (
                         p_customer_id          => p_sold_to_org_id,
                         p_transaction_type     => G_TRANSACTION_TYPE,
                         p_transaction_subtype  => G_TRANSACTION_POA,
			 p_org_id               => p_org_id,
                         x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_reqd,
                         x_return_status        => l_return_status
                        );
      If nvl(l_is_delivery_reqd, 'N') = 'N' Then
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
      End If;
     END IF;
  END IF;
  Select Oe_Xml_Message_Seq_S.nextval
  Into   l_itemkey
  From   dual;
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'L_ITEMKEY = '||L_ITEMKEY || ' ORG ID passed in is ' || p_org_id ) ;
  END IF;


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
    l_user_key := p_orig_sys_document_ref || ',' || to_char(p_sold_to_org_id) || ',' || p_change_sequence || ',' || p_transaction_type;
 Else
    l_user_key := p_orig_sys_document_ref || ',' || to_char(p_sold_to_org_id) || ',' || p_transaction_type;
 End If;


  wf_event.AddParameterToList(p_name=>          'ORIG_SYS_DOCUMENT_REF',
                              p_value=>         p_orig_sys_document_ref,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'PARAMETER3',
                              p_value=>         p_transaction_type,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'PARAMETER4',
                              p_value=>         p_sold_to_org_id,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'PARAMETER7',
                              p_value=>         p_change_sequence,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'START_FROM_FLOW',
                              p_value=>         l_start_from_flow,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'REQ_ID',
                              p_value=>         p_request_id,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'ORDER_IMPORTED',
                              p_value=>         p_order_imported,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'USER_KEY',
                              p_value=>         l_user_key,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'ORG_ID',
                              p_value=>         p_org_id,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'PARAMETER5',
                              p_value=>         p_xml_message_id,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'ECX_PARTY_ID',
                              p_value=>         l_party_id,
                              p_parameterlist=> l_parameter_list);
  wf_event.AddParameterToList(p_name=>          'ECX_PARTY_SITE_ID',
                              p_value=>         l_party_site_id,
                              p_parameterlist=> l_parameter_list);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE RAISE EVENT ORACLE.APPS.ONT.OI.PO_ACK.CREATE' ) ;
  END IF;
  wf_event.raise( p_event_name => l_event_name,
                  p_event_key =>  l_itemkey,
                  p_parameters => l_parameter_list);
                  --p_send_date  => l_send_date);

  l_parameter_list.DELETE;

-- Up to your own code to commit the transaction
  If l_itemtype <>  OE_ORDER_IMPORT_WF.G_WFI_IMPORT_PGM then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE COMMIT' ) ;
     END IF;
     Commit;
  End if;

-- Remove this after finding the cause
-- Autonomous transaction
     Commit;

-- Up to your code to handle any major exceptions
-- The Business Event System is unlikely to return any errors
-- As long as the Raise can be submitted, any errors will be placed
-- on the WF_ERROR queue and a notification sent to SYSADMIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING RAISE_EVENT_FROM_OEOI' ) ;
    END IF;
Exception
  when others then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENCOUNTERED OTHERS EXCEPTION IN RAISE_EVENT_FROM_OEOI' ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME, 'OE_Acknowledgment_Pub.Raise_Event_From_Oeoi');
    END IF;


End Raise_Event_From_Oeoi;


--{Start of Procedure to raise 3a6 event
Procedure Raise_Event_Showso
( p_header_id             In    Number,
  p_line_id               In    Number,
  p_customer_id           In    Number,
  p_orig_sys_document_ref In    Varchar2,
  p_change_sequence       In    Varchar2,
  p_itemtype              In    Varchar2,
  p_itemkey               In    Number,
  p_party_id              In    Number,
  p_party_site_id         In    Number,
  p_transaction_type      In    Varchar2,
  p_request_id            In    Number,
  p_commit_flag           In    Varchar2,
  p_org_id                In    Number,
  x_return_status         Out NOCOPY /* file.sql.39 change */   Varchar2
)
Is
  l_parameter_list              wf_parameter_list_t := wf_parameter_list_t();
  l_orig_sys_document_ref       Varchar2(50);
  l_itemtype                    Varchar2(6);
  l_itemkey                     Number;
  l_org_id                      Number;
  l_transaction_type            Varchar2(6) := p_transaction_type;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
Begin


-- We know that we are going to raise an event, so
-- we will set some parameters now, these will become
-- item attributes in any workflow processes that called
-- by the business event system due to this business event
-- Up to 100 name/value pairs. The fewer the parameters the
-- better performance will be.

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING RAISE_EVENT_SHOWSO' ) ;
  END IF;

if p_itemkey is null then

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'passed-in itemkey was null...pulling value from sequence') ;
end if;

   select OE_XML_MESSAGE_SEQ_S.nextval
   into l_itemkey
   from dual;
else

l_itemkey := p_itemkey;

end if;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ITEMKEY (request_id) => ' || l_itemkey) ;
end if;

  If p_orig_sys_document_ref Is Null Then
    l_orig_sys_document_ref :=  Get_Orig_Sys_document_Ref
                                   (p_header_id     => p_header_id,
                                    p_line_id       => p_line_id);
  Else
    l_orig_sys_document_ref := p_orig_sys_document_ref;
  End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER GET_ORIG_SYS_DOCUMENT_REF => ' || L_ORIG_SYS_DOCUMENT_REF ) ;
  END IF;

  wf_event.AddParameterToList(p_name=>          'ORG_ID',
                              p_value=>         p_org_id,
                              p_parameterlist=> l_parameter_list);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER ADDING ORG_ID PARAMETER..ORG_ID IS => ' || L_ORG_ID ) ;
  END IF;

  wf_event.AddParameterToList(p_name=>          'HEADER_ID',
                              p_value=>         p_header_id,
                              p_parameterlist=> l_parameter_list);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER ADDING HEADER_ID PARAMETER..HEADER_ID IS => ' || P_HEADER_ID ) ;
  END IF;
  wf_event.AddParameterToList(p_name=>		'ORIG_SYS_DOCUMENT_REF',
                              p_value=>		l_orig_sys_document_ref,
			      p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'LINE_ID',
                              p_value=>         p_line_id,
                              p_parameterlist=> l_parameter_list);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER ADDING LINE_ID PARAMETER..LINE_ID IS => ' || P_LINE_ID ) ;
  END IF;
  wf_event.AddParameterToList(p_name=>          'CUSTOMER_ID',
                              p_value=>         p_customer_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'PARAMETER4',
                              p_value=>         p_customer_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'PARAMETER7',
                              p_value=>         p_change_sequence,
                              p_parameterlist=> l_parameter_list);


  wf_event.AddParameterToList(p_name=>          'ECX_PARTY_ID',
                              p_value=>         p_party_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ECX_PARTY_SITE_ID',
                              p_value=>         p_party_site_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ECX_DOCUMENT_ID',
                              p_value=>         p_itemkey,
                              p_parameterlist=> l_parameter_list);

  If l_transaction_type Is NULL Then
     l_transaction_type := G_TRANSACTION_SSO;  -- we default to SSO, but it can also be passed in as CSO
  End If;

  wf_event.AddParameterToList(p_name=>          'PARAMETER3',
                              p_value=>         l_transaction_type,
                              p_parameterlist=> l_parameter_list);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER ADD PARAMETERS' ) ;
  END IF;

  If p_itemtype Is Null Then
    l_itemtype := OE_ORDER_IMPORT_WF.G_WFI_PROC;
  Else
    l_itemtype := p_itemtype;
  End If;
  wf_event.AddParameterToList(p_name=>          'START_FROM_FLOW',
                              p_value=>         l_itemtype,
                              p_parameterlist=> l_parameter_list);

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'start_from_flow:' || l_itemtype) ;
  END IF;

  IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
     IF l_itemtype = OE_ORDER_IMPORT_WF.G_WFI_CONC_PGM THEN
        wf_event.AddParameterToList(p_name=>          'REQ_ID',
                                    p_value=>         p_request_id,
                                    p_parameterlist=> l_parameter_list);
     END IF;
  END IF;

  /* Not needed now with unique itemkey, remove after testing
   -- Purge any existing workflow with the same itemkey/itemtype
    oe_order_import_wf.call_wf_purge(p_itemtype     => 'OESO',
                                   p_itemkey      => l_itemkey);
  */
  -- Raise the event with no XML document, if an XML
  -- document is required to be generated, the Generate Function
  -- will automatically be run

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE RAISE EVENT ORACLE.APPS.ONT.OI.SHOW_SO.CREATE' ) ;
  END IF;
  wf_event.raise( p_event_name => 'oracle.apps.ont.oi.show_so.create',
                  p_event_key =>  l_itemkey,
                  p_parameters => l_parameter_list);

  l_parameter_list.DELETE;

-- Up to your own code to commit the transaction
  If l_itemtype <>  OE_ORDER_IMPORT_WF.G_WFI_PROC AND
     p_commit_flag = 'Y' then
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'BEFORE COMMIT' ) ;
     END IF;
     Commit;
  End if;

-- Up to your code to handle any major exceptions
-- The Business Event System is unlikely to return any errors
-- As long as the Raise can be submitted, any errors will be placed
-- on the WF_ERROR queue and a notification sent to SYSADMIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING RAISE_EVENT_SHOWSO' ) ;
    END IF;
Exception
  when others then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ENCOUNTERED OTHERS EXCEPTION IN RAISE_EVENT_SHOWSO: ' || sqlerrm) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
       FND_MSG_PUB.Add_Exc_Msg
          (G_PKG_NAME, 'OE_Acknowledgment_Pub.Raise_Event_Showso');
    END IF;

End Raise_Event_Showso;
-- End of Procedure to raise 3a6 event}

PROCEDURE Process_Acknowledgment
(p_api_version_number            IN  NUMBER
,p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE

,p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_REC
,p_header_val_rec                IN  OE_Order_Pub.Header_Val_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_VAL_REC
,p_Header_Adj_tbl                IN  OE_Order_Pub.Header_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_TBL
,p_Header_Adj_val_tbl            IN  OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL
,p_Header_Scredit_tbl            IN  OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL
,p_Header_Scredit_val_tbl        IN  OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL
,p_line_tbl                      IN  OE_Order_Pub.Line_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_TBL
,p_line_val_tbl                  IN  OE_Order_Pub.Line_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_VAL_TBL
,p_Line_Adj_tbl                  IN  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_TBL
,p_Line_Adj_val_tbl              IN  OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL
,p_Line_Scredit_tbl              IN  OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL
,p_Line_Scredit_val_tbl          IN  OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL
,p_Lot_Serial_tbl                IN  OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_TBL
,p_Lot_Serial_val_tbl            IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL
,p_action_request_tbl	    	 IN  OE_Order_Pub.Request_Tbl_Type :=
 				     OE_Order_Pub.G_MISS_REQUEST_TBL

,p_old_header_rec                IN  OE_Order_Pub.Header_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_REC
,p_old_header_val_rec            IN  OE_Order_Pub.Header_Val_Rec_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_VAL_REC
,p_old_Header_Adj_tbl            IN  OE_Order_Pub.Header_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_TBL
,p_old_Header_Adj_val_tbl        IN  OE_Order_Pub.Header_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_ADJ_VAL_TBL
,p_old_Header_Scredit_tbl        IN  OE_Order_Pub.Header_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_TBL
,p_old_Header_Scredit_val_tbl    IN  OE_Order_Pub.Header_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_HEADER_SCREDIT_VAL_TBL
,p_old_line_tbl                  IN  OE_Order_Pub.Line_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_TBL
,p_old_line_val_tbl              IN  OE_Order_Pub.Line_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_VAL_TBL
,p_old_Line_Adj_tbl              IN  OE_Order_Pub.Line_Adj_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_TBL
,p_old_Line_Adj_val_tbl          IN  OE_Order_Pub.Line_Adj_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_ADJ_VAL_TBL
,p_old_Line_Scredit_tbl          IN  OE_Order_Pub.Line_Scredit_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_TBL
,p_old_Line_Scredit_val_tbl      IN  OE_Order_Pub.Line_Scredit_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LINE_SCREDIT_VAL_TBL
,p_old_Lot_Serial_tbl            IN  OE_Order_Pub.Lot_Serial_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_TBL
,p_old_Lot_Serial_val_tbl        IN  OE_Order_Pub.Lot_Serial_Val_Tbl_Type :=
                                     OE_Order_Pub.G_MISS_LOT_SERIAL_VAL_TBL

,p_buyer_seller_flag             IN  VARCHAR2
,p_reject_order                  IN  VARCHAR2

,x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
    l_api_version_number     CONSTANT NUMBER := 1.0;
    l_api_name               CONSTANT VARCHAR2(30):= 'Process_Acknowledgment';
    l_control_rec            OE_GLOBALS.Control_Rec_Type;
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN

    --  Standard call to check for call compatibility

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Entering Process Acknowledgment');
        END IF;
    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPACKB COMPATIBLE_API_CALL' ) ;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'BEFORE CALLING PRIVATE ACKNOWLEDGMENT API' ) ;
    END IF;

    OE_Acknowledgment_Pvt.Process_Acknowledgment
    (   p_api_version_number          => 1.0
    ,   p_init_msg_list               => p_init_msg_list

    ,   p_header_rec                  => p_header_rec
    ,   p_header_val_rec              => p_header_val_rec
    ,   p_header_adj_tbl              => p_header_adj_tbl
    ,   p_header_adj_val_tbl          => p_header_adj_val_tbl
    ,   p_header_scredit_tbl          => p_header_scredit_tbl
    ,   p_header_scredit_val_tbl      => p_header_scredit_val_tbl
    ,   p_line_tbl                    => p_line_tbl
    ,   p_line_val_tbl                => p_line_val_tbl
    ,   p_line_adj_tbl                => p_line_adj_tbl
    ,   p_line_adj_val_tbl            => p_line_adj_val_tbl
    ,   p_line_scredit_tbl            => p_line_scredit_tbl
    ,   p_line_scredit_val_tbl        => p_line_scredit_val_tbl
    ,   p_lot_serial_tbl              => p_lot_serial_tbl
    ,   p_lot_serial_val_tbl          => p_lot_serial_val_tbl
    ,   p_action_request_tbl          => p_action_request_tbl

    ,   p_old_header_rec              => p_old_header_rec
    ,   p_old_header_val_rec          => p_old_header_val_rec
    ,   p_old_header_adj_tbl          => p_old_header_adj_tbl
    ,   p_old_header_adj_val_tbl      => p_old_header_adj_val_tbl
    ,   p_old_header_scredit_tbl      => p_old_header_scredit_tbl
    ,   p_old_header_scredit_val_tbl  => p_old_header_scredit_val_tbl
    ,   p_old_line_tbl                => p_old_line_tbl
    ,   p_old_line_val_tbl            => p_old_line_val_tbl
    ,   p_old_line_adj_tbl            => p_old_line_adj_tbl
    ,   p_old_line_adj_val_tbl        => p_old_line_adj_val_tbl
    ,   p_old_line_scredit_tbl        => p_old_line_scredit_tbl
    ,   p_old_line_scredit_val_tbl    => p_old_line_scredit_val_tbl
    ,   p_old_lot_serial_tbl          => p_old_lot_serial_tbl
    ,   p_old_lot_serial_val_tbl      => p_old_lot_serial_val_tbl

    ,   p_buyer_seller_flag           => p_buyer_seller_flag
    ,   p_reject_order                => p_reject_order

    ,   x_return_status               => l_return_status
    );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AFTER CALLING PRIVATE ACKNOWLEDGMENT API' ) ;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED ERROR EXCEPTION' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED UNEXPECTED ERROR EXCEPTION' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'ENCOUNTERED OTHERS ERROR EXCEPTION IN OE_ACKNOWLEDGMENT_PUB.PROCESS_ACKNOWLEDGMENT: '|| SQLERRM ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            	(G_PKG_NAME, 'OE_Acknowledgment_Pub.Process_Acknowledgment');
        END IF;


END Process_Acknowledgment;

-- aksingh 3A4 Start

-- {Start of function to get the index for the tbl for give line_id
FUNCTION Get_Line_Index
( p_line_tbl               IN OE_Order_Pub.Line_Tbl_Type,
  p_line_id                IN Number
)
RETURN NUMBER
IS
   i      pls_integer;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERNING: OEXPACK FUNCTION GET_LINE_INDEX' ) ;
   END IF;
   -- Following For loop is changed to while because of new Notify_OC change
   -- for i in 1..p_line_tbl.count
   -- loop
   i := p_line_tbl.First;
   while i is not null loop
       if p_line_tbl(i).line_id     = p_line_id
       then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'EXITING: OEXPACK FUNCTION GET_LINE_INDEX - RETURNING ' || I ) ;
          END IF;
          return i;
       end if;
       i := p_line_tbl.Next(i);
    end loop;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING: OEXPACK FUNCTION GET_LINE_INDEX - RETURNING 0' ) ;
    END IF;
    return 0;
EXCEPTION
   WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'get_line_index');
        END IF;
END Get_Line_Index;

-- {Start of procedure Insert_Header
PROCEDURE Insert_Header
( p_header_rec             IN   OE_Order_Pub.Header_Rec_Type,
  p_header_status          IN   Varchar2,
  p_ack_type               IN   Varchar2,
  p_itemkey                IN   Number,
  x_return_status          OUT NOCOPY /* file.sql.39 change */  Varchar2
)
IS

 l_header_status             varchar2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERNING: OEXPACK PROCEDURE INSERT_HEADER' ) ;
   END IF;

   l_header_status := p_header_status;

         If p_header_rec.flow_status_code = 'CANCELLED' then
              l_header_status := 'CANCELLED';
         Elsif p_header_rec.flow_status_code = 'CLOSED' then
              l_header_status := 'CLOSED';
         Else
             l_header_status := 'OPEN';
         End If;



   Insert Into OE_HEADER_ACKS (header_id, acknowledgment_type, last_ack_code, request_id, sold_to_org_id, change_sequence)
   Values (p_header_rec.header_id, p_ack_type, l_header_status, p_itemkey, --p_header_rec.request_id
           p_header_rec.sold_to_org_id, p_header_rec.change_sequence);

   if sql%rowcount > 0 then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSERTED HEADER_ID => ' || P_HEADER_REC.HEADER_ID ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NOT INSERTED HEADER_ID => ' || P_HEADER_REC.HEADER_ID ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING: OEXPACK PROCEDURE INSERT_HEADER' ) ;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'insert_header');
        END IF;
END Insert_Header;
-- End of procedure Insert_Header }

-- {Start of procedure Insert_Line
PROCEDURE Insert_Line
( p_line_rec               IN   OE_Order_Pub.Line_Rec_Type,
  p_line_status            IN   Varchar2,
  p_ack_type               IN   Varchar2,
  p_itemkey                IN   Number,
  x_return_status          OUT NOCOPY /* file.sql.39 change */  Varchar2
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERNING: OEXPACK PROCEDURE INSERT_LINE' ) ;
   END IF;

   Insert Into OE_LINE_ACKS (header_id,           line_id,
                             acknowledgment_type, last_ack_code, request_id,
			     sold_to_org_id, change_sequence)
   Values (p_line_rec.header_id, p_line_rec.line_id,
           p_ack_type,           p_line_status,
           p_itemkey,  --p_line_rec.request_id
  	   p_line_rec.sold_to_org_id,
           p_line_rec.change_sequence
          );
   if sql%rowcount > 0 then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INSERTED LINE_ID => ' || P_LINE_REC.LINE_ID ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NOT INSERTED LINE_ID => ' || P_LINE_REC.LINE_ID ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
   end if;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING: OEXPACK PROCEDURE INSERT_LINE' ) ;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'insert_line');
        END IF;
END Insert_Line;
-- End of procedure Insert_Line }


-- {Start of procedure Query Interface Records
PROCEDURE Query_Inf_Records
( p_order_source_id        IN   Number    := 20,
  p_orig_sys_document_ref  IN   Varchar2,
  p_sold_to_org_id         IN   Number,
  p_change_sequence        IN   Varchar2,
  p_msg_id                 IN   Number    := NULL,
  p_request_id             IN   Number    := NuLL,
  p_xml_transaction_type_code IN Varchar2,
  x_header_rec             OUT NOCOPY /* file.sql.39 change */  OE_Order_Pub.Header_Rec_Type,
  x_header_val_rec         OUT NOCOPY /* file.sql.39 change */  OE_Order_Pub.Header_Val_Rec_Type,
  x_line_tbl               OUT NOCOPY /* file.sql.39 change */  OE_Order_Pub.Line_Tbl_Type,
  x_line_val_tbl           OUT NOCOPY /* file.sql.39 change */  OE_Order_Pub.Line_Val_Tbl_Type)
IS
  l_header_rec                  OE_Order_Pub.Header_Rec_Type;
  l_header_val_rec              OE_Order_Pub.Header_Val_Rec_Type;
  l_line_rec                    OE_Order_Pub.Line_Rec_Type;
  l_line_tbl                    OE_Order_Pub.Line_Tbl_Type;
  l_line_count                  Number := 0;
  l_order_source_id 	        Number;
  l_orig_sys_document_ref       Varchar2(50);
  l_change_sequence             Varchar2(50);
  l_return_status               Varchar2(1) := fnd_api.g_ret_sts_success;
  l_customer_key_profile VARCHAR2(1) :=  'N';


  -- { Start of Header Interface Cursor
  CURSOR l_header_cursor IS
  SELECT order_source_id               , orig_sys_document_ref
       , change_sequence               , booked_flag
       , customer_number               , customer_po_number
       , freight_terms_code            , freight_terms
       , fob_point_code                , fob_point
       , invoice_to_org_id             , invoice_to_org
       , invoice_address1              , invoice_address2
       , invoice_address3              , invoice_city
       , invoice_state                 , invoice_postal_code
       , invoice_county                , invoice_country
       , ship_from_org_id              , ship_from_org
-- ?? Should we add all the ship from address columns??
       , ship_to_org_id                , ship_to_org
       , ship_to_address1              , ship_to_address2
       , ship_to_address3              , ship_to_city
       , ship_to_state                 , ship_to_postal_code
       , ship_to_county                , ship_to_country
-- ?? Should we add all the sold to address columns??
       , sold_to_org_id                , sold_to_org
       , org_id                        , request_id
       , xml_message_id                , payment_term
    FROM oe_headers_interface
   WHERE order_source_id            = p_order_source_id
     AND orig_sys_document_ref      = p_orig_sys_document_ref
     AND decode(l_customer_key_profile, 'Y',
	 nvl(sold_to_org_id,                  -999), 1)
         = decode(l_customer_key_profile, 'Y',
	 nvl(p_sold_to_org_id,                -999), 1)
     AND nvl(change_sequence,                 ' ')
       = nvl(p_change_sequence,               ' ')
     AND nvl(request_id,                      -999)
       = nvl(p_request_id,                    -999)
     AND xml_transaction_type_code  = p_xml_transaction_type_code
     AND error_flag                 = 'Y'
--  FOR UPDATE NOWAIT
;
  -- End of Header Interface Cursor}

  -- { Start of Line Interface Cursor
  CURSOR l_line_cursor IS
  SELECT order_source_id               , orig_sys_document_ref
       , customer_item_name            , customer_item_id
       , customer_po_number            , orig_sys_line_ref
       , ordered_quantity              , order_quantity_uom
       , request_date                  , orig_sys_shipment_ref
       , org_id                        , request_id
       , change_sequence               , sold_to_org_id
       , customer_line_number          , customer_shipment_number
    FROM oe_lines_interface
   WHERE order_source_id            = p_order_source_id
     AND orig_sys_document_ref      = p_orig_sys_document_ref
     AND decode(l_customer_key_profile, 'Y',
	 nvl(sold_to_org_id,                  -999), 1)
         = decode(l_customer_key_profile, 'Y',
	 nvl(p_sold_to_org_id,                -999), 1)
     AND nvl(change_sequence,                 ' ')
       = nvl(p_change_sequence,               ' ')
     AND nvl(request_id,                      -999)
       = nvl(p_request_id,                    -999)
     AND xml_transaction_type_code  = p_xml_transaction_type_code
--  FOR UPDATE NOWAIT
  ORDER BY orig_sys_line_ref, orig_sys_shipment_ref;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'START OF QUERY_INF_RECORDS' ) ;
   END IF;



 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Key Information');
      oe_debug_pub.add('Order Source Id:' || p_order_source_id);
      oe_debug_pub.add( 'Orig Sys Document Ref:' || p_orig_sys_document_ref);
      oe_debug_pub.add( 'Sold To Org Id:' || p_sold_to_org_id);
      oe_debug_pub.add( 'Change Sequence:' || p_change_sequence);
      oe_debug_pub.add( 'Request Id:' || p_request_id);
      oe_debug_pub.add( 'XML Transaction Type Code:' || p_xml_transaction_type_code);
  END IF;
  -- { Start of header fetch
  --HEADER-----------HEADER---------------HEADER----------------HEADER---------

  OPEN l_header_cursor;
   FETCH l_header_cursor
   INTO
     l_header_rec.order_source_id,          l_header_rec.orig_sys_document_ref
   , l_header_rec.change_sequence,          l_header_rec.booked_flag
   , l_header_val_rec.customer_number,      l_header_rec.cust_po_number
   , l_header_rec.freight_terms_code,       l_header_val_rec.freight_terms
   , l_header_rec.fob_point_code,           l_header_val_rec.fob_point
   , l_header_rec.invoice_to_org_id,        l_header_val_rec.invoice_to_org
   , l_header_val_rec.invoice_to_address1,  l_header_val_rec.invoice_to_address2
   , l_header_val_rec.invoice_to_address3,  l_header_val_rec.invoice_to_city
   , l_header_val_rec.invoice_to_state,     l_header_val_rec.invoice_to_zip
   , l_header_val_rec.invoice_to_county,    l_header_val_rec.invoice_to_country
   , l_header_rec.ship_from_org_id,         l_header_val_rec.ship_from_org
   , l_header_rec.ship_to_org_id,           l_header_val_rec.ship_to_org
   , l_header_val_rec.ship_to_address1,     l_header_val_rec.ship_to_address2
   , l_header_val_rec.ship_to_address3,     l_header_val_rec.ship_to_city
   , l_header_val_rec.ship_to_state,        l_header_val_rec.ship_to_zip
   , l_header_val_rec.ship_to_county,       l_header_val_rec.ship_to_country
   , l_header_rec.sold_to_org_id,           l_header_val_rec.sold_to_org
   , l_header_rec.org_id,                   l_header_rec.request_id
   , l_header_rec.xml_message_id,           l_header_val_rec.payment_term
   ;

   l_order_source_id 	     := l_header_rec.order_source_id;
   l_orig_sys_document_ref   := l_header_rec.orig_sys_document_ref;
   l_change_sequence         := l_header_rec.change_sequence;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ORDER SOURCE ID: ' || L_ORDER_SOURCE_ID ) ;
       oe_debug_pub.add(  'ORIG SYS REFERENCE: '|| L_ORIG_SYS_DOCUMENT_REF ) ;
       oe_debug_pub.add(  'CHANGE SEQUENCE: ' || L_CHANGE_SEQUENCE ) ;
   END IF;

  -- { Start of line fetch
  --LINE---------------------LINE-----------------LINE----------------LINE-----
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE LINES LOOP' ) ;
  END IF;

  l_line_count := 0;

  OPEN l_line_cursor;
  LOOP
   FETCH l_line_cursor
   INTO
     l_line_rec.order_source_id,            l_line_rec.orig_sys_document_ref
   , l_line_rec.ordered_item,               l_line_rec.ordered_item_id
   , l_line_rec.cust_po_number,             l_line_rec.orig_sys_line_ref
   , l_line_rec.ordered_quantity,           l_line_rec.order_quantity_uom
   , l_line_rec.request_date,               l_line_rec.orig_sys_shipment_ref
   , l_line_rec.org_id,                     l_line_rec.request_id
   , l_line_rec.change_sequence,            l_line_rec.sold_to_org_id
   , l_line_rec.customer_line_number,       l_line_rec.customer_shipment_number
   ;
  EXIT WHEN l_line_cursor%NOTFOUND;

    ----------------  <Increase the Record Counter> --------------------------
    l_line_count := l_line_count + 1;
    ----------------  </Increase the Record Counter> -------------------------
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ASSIGNING RECORD TO LINE TABLE....LINE COUNT = ' || L_LINE_COUNT ) ;
    END IF;
    ----------------  <Assign record to line table> --------------------------
    l_line_tbl(l_line_count)             := l_line_rec;
    ----------------  </Assign record to line table> -------------------------

  END LOOP;
  CLOSE l_line_cursor;
  --LINE---------------------LINE-----------------LINE----------------LINE-----
  -- End of line fetch}

  CLOSE l_header_cursor;
  --HEADER-----------HEADER---------------HEADER----------------HEADER---------
  -- End of Header fetch}


  ------------------  <Assign data to out variable> --------------------------
  x_header_rec                           := l_header_rec;
  x_header_val_rec                       := l_header_val_rec;
  x_line_tbl                             := l_line_tbl;
  ------------------  </Assign data to out variable> -------------------------

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'END OF QUERY_INF_RECORDS' ) ;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
   IF l_debug_level  > 0 THEN
             oe_debug_pub.add ('In others exception in query inf:' || SQLERRM);
   END IF;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'query_inf_records');
        END IF;
END Query_Inf_Records;
-- End of procedure Query Interface Records }


PROCEDURE Process_Xml_Acknowledgment
(  p_api_version_number            IN  NUMBER   := 1,
   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
   p_order_source_id               IN  NUMBER   := G_XML_ORDER_SOURCE_ID,
   p_orig_sys_document_ref         IN  VARCHAR2,
   p_sold_to_org_id                IN  NUMBER,
   p_change_sequence               IN  VARCHAR2,
   p_header_id                     IN  NUMBER   := NULL,
   p_line_id                       IN  NUMBER   := NULL,
   p_msg_id                        IN  NUMBER   := NULL,
   p_request_id                    IN  NUMBER   := NULL,
   p_itemtype                      IN  VARCHAR2 := OE_ORDER_IMPORT_WF.G_WFI_ORDER_ACK,
   p_start_from_flow               IN  VARCHAR2 := OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT,
   p_transaction_type              IN  VARCHAR2 := NULL,
   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS


   -- (iii) Delete_row need not to be changed, discuss with Sameer.

   -- (iv)  Make sure raise event is raised only for the Xml order source

   -- (v)   Code to check if the acknowledgment is setup for the TP

  l_header_rec                  OE_Order_Pub.Header_Rec_Type;
  l_header_val_rec              OE_Order_Pub.Header_Val_Rec_Type;
  l_line_rec                    OE_Order_Pub.Line_Rec_Type;
  l_line_tbl                    OE_Order_Pub.Line_Tbl_Type;
  l_line_val_rec                OE_Order_Pub.Line_Val_Rec_Type;
  l_line_val_tbl                OE_Order_Pub.Line_Val_Tbl_Type;
  l_header_id                   Number;
  l_header_last_ack_code        Varchar2(30);
  l_reject_order                Varchar2(1) := 'Y';
  l_return_status               Varchar2(1) := fnd_api.g_ret_sts_success;
  l_line_id                     Number;
  l_line_ack_id                 Number;
  l_line_last_ack_code          Varchar2(30);
  l_ind_cntr                    Number;
  l_acknowledgment_type         Varchar2(6);
  l_orig_sys_document_ref       Varchar2(50);
  l_request_id                  Number := p_request_id;
  l_cancelled_flag              Varchar2(1);
  i                             pls_integer;
  j                             pls_integer;
  k                             pls_integer;
  l_customer_key_profile        Varchar2(1) :=  'N';
  l_hold_result     VARCHAR2(30);
  l_hold_id           NUMBER := 56;
  l_msg_count       NUMBER := 0;
  l_msg_data        VARCHAR2(2000);

  Cursor Line_Ack_Cur Is
         Select Line_Id
         From   oe_line_acks
         Where  header_id           =  l_header_id
         And    acknowledgment_type =  l_acknowledgment_type
         And decode(l_customer_key_profile, 'Y',
	     nvl(sold_to_org_id,                  -999), 1)
           = decode(l_customer_key_profile, 'Y',
	     nvl(p_sold_to_org_id,                -999), 1);

  Cursor Cancel_Line_Ack_Cur Is
         Select Line_Id
         From   oe_order_lines
         Where  request_id             = l_request_id
         And    header_id              = l_header_id
         And decode(l_customer_key_profile, 'Y',
             nvl(sold_to_org_id,                  -999), 1)
           = decode(l_customer_key_profile, 'Y',
	     nvl(p_sold_to_org_id,                -999), 1);

  Cursor SSO_Line_Ack_Cur Is
         Select Line_Id, Last_Ack_Code
         From   oe_line_acks
         Where  header_id           =  l_header_id
         And    acknowledgment_type =  l_acknowledgment_type
         And    request_id          =  l_request_id
         And decode(l_customer_key_profile, 'Y',
	     nvl(sold_to_org_id,                  -999), 1)
           = decode(l_customer_key_profile, 'Y',
	     nvl(p_sold_to_org_id,                -999), 1);

         --
         l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
         --
BEGIN

   -- { Check what parameters are passed
   -- If Data has to be extracted from interface table p_header_id
   -- should be null (as order never got created), otherwise use
   -- header_id to query the data from the base tables

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: ENTERING PROCESS_XML_ACKNOWLEDGMENT' ) ;
   END IF;
   l_acknowledgment_type := p_transaction_type;

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;

    IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'request_id passed in:' || l_request_id ) ;
     END IF;

--If transaction is 3a6, the order has already been accepted.
   If p_transaction_type = G_TRANSACTION_SSO or p_transaction_type = G_TRANSACTION_CSO then
   l_reject_order := 'N';
   End If;

   -- { Start of p_header_id is null
   If p_header_id  is NULL Then

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPACKB: HEADER ID IS NULL' ) ;
     END IF;
     -- We need to check here to make sure if the order is created or rejected
     Begin
       Select  orig_sys_document_ref
       into    l_orig_sys_document_ref
       From    oe_headers_interface
       Where   order_source_id       =  G_XML_ORDER_SOURCE_ID
       And     orig_sys_document_ref = p_orig_sys_document_ref
       And     decode(l_customer_key_profile, 'Y',
	       nvl(sold_to_org_id,                  -999), 1)
               = decode(l_customer_key_profile, 'Y',
	       nvl(p_sold_to_org_id,                -999), 1)
       AND nvl(change_sequence,               ' ')
         = nvl(p_change_sequence,             ' ')
       And     xml_transaction_type_code = p_transaction_type
       And     request_id            = p_request_id;
       -- change sequence should go here, so should customer.

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPACKB: GOT THE ORIG SYS DOCUMENT REF => ' || L_ORIG_SYS_DOCUMENT_REF ) ;
       END IF;

     Exception
       When NO_DATA_FOUND Then
         -- This means we are accepting the order let us set the flag
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPACKB: L_REJECT_ORDER IS SET TO N' ) ;
         END IF;
         l_reject_order := 'N';
       When OTHERS Then
         -- Code here to raise error as not able to find the orig_sys_document_ref
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPACKB: OTHERS IN SELECT FROM OE_HEADERS_INTERFACE' ) ;
         END IF;
	 fnd_message.set_name ('ONT', 'OE_OI_ACK_DATA_NOT_FOUND');
	 fnd_message.set_token ('TABLE', 'oe_headers_interface');
	 oe_msg_pub.add;
     End;


     -- { Start of l_reject_order = 'Y'
     If l_reject_order = 'Y' Then
       query_inf_records( p_order_source_id       => p_order_source_id,
                         p_orig_sys_document_ref => p_orig_sys_document_ref,
                         p_sold_to_org_id        => p_sold_to_org_id,
                         p_change_sequence       => p_change_sequence,
                         p_msg_id                => p_msg_id,
                         p_request_id            => p_request_id,
                         p_xml_transaction_type_code => p_transaction_type,
                         x_header_rec            => l_header_rec,
                         x_header_val_rec        => l_header_val_rec,
                         x_line_tbl              => l_line_tbl,
                         x_line_val_tbl          => l_line_val_tbl);

      Else

        Begin
        Select  header_id
        into    l_header_id
        From    oe_order_headers
        Where   order_source_id       =  G_XML_ORDER_SOURCE_ID
        And     orig_sys_document_ref = p_orig_sys_document_ref
        And decode(l_customer_key_profile, 'Y',
	    nvl(sold_to_org_id,                  -999), 1)
          = decode(l_customer_key_profile, 'Y',
	    nvl(p_sold_to_org_id,                -999), 1);
--removing because change_sequence isn't needed and  could have changed before this processing takes place
/*        And nvl(change_sequence,                 ' ')
          = nvl(p_change_sequence,               ' ');
*/
        -- start bug 4195533
        OE_MSG_PUB.update_msg_context(
           p_header_id            => l_header_id
           );
        -- end bug 4195533

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPACKB: GOT THE HEADER ID => ' || L_HEADER_ID ) ;
        END IF;

        Exception
        When OTHERS Then
         -- Code here to raise error as not able to find the header id
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPACKB: OTHERS IN SELECT FROM OE_ORDER_HEADERS' ) ;
         END IF;
	 fnd_message.set_name ('ONT', 'OE_OI_ACK_DATA_NOT_FOUND');
	 fnd_message.set_token ('TABLE', 'oe_order_headers');
	 oe_msg_pub.add;
        End;

       End If;
       -- End of l_reject_order = 'Y'}

      End If;
      -- End of p_header_id is null }

   -- {If p_header_id is not null
   If p_header_id Is Not Null OR (l_header_id is not null AND l_reject_order = 'N') Then

	if p_header_id is not null then
	   l_header_id := p_header_id;
	end if;

     --{Call Query Row procedure to get the Header Data from Base
     -- OE_ORDER_HEADERS_ALL table
     Begin
       oe_header_util.query_row ( p_header_id  => l_header_id,
                                x_header_rec => l_header_rec);

       Begin
          If l_header_rec.payment_term_id Is Not Null Then
             l_header_val_rec.payment_term := OE_Id_To_Value.Payment_Term
                                            (p_payment_term_id => l_header_rec.payment_term_id);

           End If;
       Exception
         When Others Then
           If l_debug_level  > 0 THEN
             oe_debug_pub.add ('Error in deriving value for Payment Term ' || SQLERRM);
           End If;
       End;

   --retrieving seeded header status in case of 3a6 generated from PROC
   If p_transaction_type = G_TRANSACTION_SSO Or p_transaction_type = G_TRANSACTION_CSO Then


      If p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_PROC Then

      Select last_ack_code
      into l_header_last_ack_code
      from oe_header_acks
      where acknowledgment_type = p_transaction_type
      and header_id = l_header_id
      and request_id = l_request_id;

         IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'RETRIEVED HEADER LAST_ACK_CODE: ' || L_HEADER_LAST_ACK_CODE ) ;
         END IF;
      l_header_rec.last_ack_code := l_header_last_ack_code;
      Else
-- 3a6 generated from concurrent program
        If ((l_header_rec.flow_status_code = 'CANCELLED') or
            (l_header_rec.flow_status_code = 'CLOSED'))    then
            l_header_rec.last_ack_code := l_header_rec.flow_status_code;
         End If;
      End If;

   End If;

     Exception
       When Others Then
         x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;--FND_API.G_RET_STS_SUCCESS;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'QUERY FROM OE_ORDER_HEADERS_ALL TABLE FAILED. ACK. NOT SEND: ' || sqlerrm) ;
         END IF;
	 fnd_message.set_name ('ONT', 'OE_OI_ACK_DATA_NOT_FOUND');
	 fnd_message.set_token ('TABLE', 'oe_order_headers');
	 oe_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         --RETURN;
     End;
     -- End Header query}

     --{Call Query Row procedure to get the Line Data from Base
     -- OE_ORDER_LINES_ALL table

	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'ORDER_SOURCE_ID' || L_HEADER_REC.ORDER_SOURCE_ID ) ;
	    oe_debug_pub.add(  'P_START_FROM_FLOW' || P_START_FROM_FLOW ) ;
	    oe_debug_pub.add(  'TRANSACTION_TYPE ' || P_TRANSACTION_TYPE ) ;
	END IF;

     Begin
     If  (p_start_from_flow = Oe_Globals.G_WFI_LIN And p_line_id Is Not Null)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT And p_transaction_type = G_TRANSACTION_POI)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_IMPORT_PGM And p_transaction_type = G_TRANSACTION_POI)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_CONC_PGM And p_transaction_type = G_TRANSACTION_SSO)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_CONC_PGM And p_transaction_type = G_TRANSACTION_CSO) Then
      	IF l_debug_level  > 0 THEN
      	    oe_debug_pub.add(  'IN IF STATEMENT' ) ;
	    oe_debug_pub.add(  P_START_FROM_FLOW || ' FLOW , WITH LINE_ID => ' || P_LINE_ID ) ;
	    oe_debug_pub.add(  'TRANSACTION_TYPE ' || P_TRANSACTION_TYPE ) ;
	END IF;
        l_line_id := p_line_id;
        oe_line_util.query_rows ( p_header_id  => l_header_id,
                                 p_line_id    => l_line_id,
                                 x_line_tbl   => l_line_tbl);

-- checking for 'CLOSED' or 'CANCELLED' line status for 3a6

        If p_transaction_type = G_TRANSACTION_SSO Then

    j := l_line_tbl.First;
   while j is not null loop
      if ((l_line_tbl(j).flow_status_code = 'CANCELLED') or
         (l_line_tbl(j).flow_status_code = 'CLOSED'))    then
         l_line_tbl(j).last_ack_code := l_line_tbl(j).flow_status_code;
      end if;
      j := l_line_tbl.Next(j);
   end loop;

        End If;

      End If;

     -- Start line query for 3A9
     -- Send all the lines if the Order is Cancelled or else send only the Partially cancelled lines
     -- We reuse same logic for 3a8 i.e. only ack back the changed lines, which are derived using the request id
     -- so we pick all lines which have the same request id as the header because we know these were changed last
     If (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT And p_transaction_type = G_TRANSACTION_CPO)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_IMPORT_PGM And p_transaction_type = G_TRANSACTION_CPO)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_ORDER_IMPORT And p_transaction_type = G_TRANSACTION_CHO)
      Or (p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_IMPORT_PGM And p_transaction_type = G_TRANSACTION_CHO) Then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'IN IF STATEMENT WITH TRANSACTION TYPE = '|| p_transaction_type ) ;
	END IF;
     Begin
         Select cancelled_flag
         Into   l_cancelled_flag
         From   oe_order_headers
         Where  header_id  =  l_header_id;
	 IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'HEADER_ID: ' || L_HEADER_ID ) ;
	 END IF;

         If nvl(l_cancelled_flag, 'N') = 'N' Then
           l_ind_cntr := 0;
           Open Cancel_Line_Ack_Cur;
           Loop
             Fetch Cancel_Line_Ack_Cur
             Into  l_line_ack_id;
             Exit When Cancel_Line_Ack_Cur%NOTFOUND;
             IF l_line_ack_id IS NOT NULL THEN -- bug 3363327
	        IF l_debug_level  > 0 THEN
	           oe_debug_pub.add(  'FETCHED LINE ACK ID: ' || L_LINE_ACK_ID ) ;
	        END IF;

                l_line_rec := oe_line_util.query_row ( p_line_id    => l_line_ack_id);
             END IF;                           -- end bug 3363327

             l_ind_cntr := l_ind_cntr + 1;
             l_line_tbl(l_ind_cntr) := l_line_rec;
           End Loop;
           Close Cancel_Line_Ack_Cur;
          End If;
        Exception
          When Others Then
            x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR; --FND_API.G_RET_STS_SUCCESS;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'QUERY FROM OE_ORDER_LINES_ALL TABLE FAILED. ACK. NOT SEND' ) ;
            END IF;
	    fnd_message.set_name ('ONT', 'OE_OI_ACK_DATA_NOT_FOUND');
            fnd_message.set_token ('TABLE', 'oe_order_lines');
	    oe_msg_pub.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            --RETURN;
        End;

      End If;

     If p_start_from_flow = OE_ORDER_IMPORT_WF.G_WFI_PROC Then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'G_WFI_PROC FLOW' ) ;
        END IF;
        -- l_acknowledgment_type := G_TRANSACTION_SSO;
        l_ind_cntr := 0;

--get only lines for this request if this is for 3a6
if p_transaction_type = G_TRANSACTION_SSO Or p_transaction_type = G_TRANSACTION_CSO then
 Open sso_line_ack_cur;
        Loop
        Fetch sso_line_ack_cur
        Into  l_line_ack_id, l_line_last_ack_code;
          If l_line_ack_id is Not Null Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'G_WFI_PROC FLOW , L_LINE_ACK_ID => ' || L_LINE_ACK_ID ) ;
                 oe_debug_pub.add(  'RETRIEVED LINE LAST_ACK_CODE: ' || L_LINE_LAST_ACK_CODE ) ;
             END IF;
             l_line_rec :=
              oe_line_util.query_row ( p_line_id    => l_line_ack_id);
             l_line_rec.last_ack_code := l_line_last_ack_code;
          End If;
        Exit When sso_line_ack_cur%notfound;
          l_ind_cntr := l_ind_cntr + 1;
          l_line_tbl(l_ind_cntr) := l_line_rec;
        End Loop;
        Close sso_line_ack_cur;
else
        Open line_ack_cur;
        Loop
        Fetch line_ack_cur
        Into  l_line_ack_id;
          If l_line_ack_id is Not Null Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'G_WFI_PROC FLOW , L_LINE_ACK_ID => ' || L_LINE_ACK_ID ) ;
             END IF;
             l_line_rec :=
              oe_line_util.query_row ( p_line_id    => l_line_ack_id);
          End If;
        Exit When line_ack_cur%notfound;
          l_ind_cntr := l_ind_cntr + 1;
          l_line_tbl(l_ind_cntr) := l_line_rec;
        End Loop;
        Close line_ack_cur;
end if;

     End If;
     Exception
       When Others Then
         x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;--FND_API.G_RET_STS_SUCCESS;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'QUERY FROM OE_ORDER_LINES_ALL TABLE FAILED. ACK. NOT SEND' ) ;
         END IF;
         fnd_message.set_name ('ONT', 'OE_OI_ACK_DATA_NOT_FOUND');
	 fnd_message.set_token ('TABLE', 'oe_order_lines');
	 oe_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         --RETURN;
     End;
     -- End Line query}

   End If;
   -- End of p_header_id is not null}

--begin setting request_id to eventkey for 3a6 to allow unique identification in acks tables;
--now also sets change sequence because passed value from workflow should
--sync with the value inserted into the acks table since a change sequence
--pulled from the base table could change in the interim

if p_transaction_type = G_TRANSACTION_SSO Or p_transaction_type = G_TRANSACTION_CSO then
    l_header_rec.request_id := l_request_id;
    l_header_rec.change_sequence := p_change_sequence;

   i := l_line_tbl.First;
   while i is not null loop
      l_line_tbl(i).request_id := l_request_id;
      l_line_tbl(i).change_sequence := p_change_sequence;
      i := l_line_tbl.Next(i);
   end loop;
--end of setting request id and change sequence for 3a6
else
--set only change sequence for other transaction types
    l_header_rec.change_sequence := p_change_sequence;

   i := l_line_tbl.First;
   while i is not null loop
      l_line_tbl(i).change_sequence := p_change_sequence;
      i := l_line_tbl.Next(i);
   end loop;

end if;


   OE_Header_Ack_Util.Insert_Row
     ( p_header_rec            =>  l_header_rec
     , p_header_val_rec        =>  l_header_val_rec
     , p_old_header_rec        =>  l_header_rec
     , p_old_header_val_rec    =>  l_header_val_rec
     , p_reject_order          =>  l_reject_order
     , p_ack_type              =>  l_acknowledgment_type
     , x_return_status         =>  l_return_status
     );
   If l_return_status = fnd_api.g_ret_sts_unexp_error Then
      raise fnd_api.g_exc_unexpected_error;
   Elsif l_return_status = fnd_api.g_ret_sts_error Then
      raise fnd_api.g_exc_error;
   End If;
   -- End of Header data insert into ack header table}

   -- { Start of Line data insert into ack header table
   OE_Line_Ack_Util.Insert_Row
     ( p_line_tbl             =>  l_line_tbl
     , p_line_val_tbl         =>  l_line_val_tbl
     , p_old_line_tbl         =>  l_line_tbl
     , p_old_line_val_tbl     =>  l_line_val_tbl
     , p_buyer_seller_flag    =>  'B'
     , p_reject_order         =>  l_reject_order
     , p_ack_type             =>  l_acknowledgment_type
     , x_return_status        =>  l_return_status
     );
   If l_return_status = fnd_api.g_ret_sts_unexp_error Then
      raise fnd_api.g_exc_unexpected_error;
   Elsif l_return_status = fnd_api.g_ret_sts_error Then
      raise fnd_api.g_exc_error;
   End If;
   -- End of Line data insert into ack header table}

END Process_Xml_Acknowledgment;

-- { Start of the Is_Delivery_Required
-- This api will do following
-- 1. For the given customer_id, transaction_type and subtype
-- 2. Get the party_id, party_site_id of Usage of type  'SOLD_TO' that is primary
--    and active
-- 3. If exists then call ecx api isDeliveryRequired to validate for
--    the transaction and customer site combination.
Procedure Is_Delivery_Required
( p_customer_id          in    number,
  p_transaction_type     in    varchar2,
  p_transaction_subtype  in    varchar2,
  p_org_id               in    number,
  x_party_id             Out NOCOPY /* file.sql.39 change */   Number,
  x_party_site_id	 Out NOCOPY /* file.sql.39 change */   Number,
  x_is_delivery_required out NOCOPY /* file.sql.39 change */   varchar2,
  x_return_status        out NOCOPY /* file.sql.39 change */   varchar2
)
Is

  l_party_id           number;
  l_party_site_id      number;
  l_cust_acct_site_id  number;
  l_retcode            pls_integer;
  l_errmsg             varchar2(2000);
  l_result             boolean := FALSE;
  l_org_id             Number := p_org_id;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: ENTERING IS_DELIVERY_REQUIRED' ) ;
   END IF;

   x_is_delivery_required := 'N';
   If p_org_id IS NULL Then
     l_org_id := MO_GLOBAL.Get_Current_Org_Id;
   End If;
   -- { Start step 1 and 2
   -- Select the party_id and party_side id for the
   Select /* MOAC_SQL_CHANGE */ a.cust_acct_site_id, a.party_site_id, c.party_id
   Into   l_cust_acct_site_id, l_party_site_id,  l_party_id
   From   hz_cust_acct_sites_all a, hz_cust_site_uses_all b, hz_cust_accounts c
   Where  a.cust_acct_site_id = b.cust_acct_site_id
   And    a.cust_account_id  = p_customer_id
   And    a.cust_account_id  = c.cust_account_id
/*   And     NVL(a.org_id,NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),
            1,1),' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)) =
            NVL(TO_NUMBER(DECODE( SUBSTRB(USERENV('CLIENT_INFO'),1,1),
            ' ',NULL,SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)  */
   And    a.org_id = l_org_id
   And    b.site_use_code = 'SOLD_TO'
   And    b.primary_flag = 'Y'
   And    b.status = 'A'
   And    a.status ='A'; --bug 2752321

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'L_CUST_ACC ' || L_CUST_ACCT_SITE_ID ) ;
       oe_debug_pub.add(  'L_PARTY_ID ' || L_PARTY_ID ) ;
       oe_debug_pub.add(  'L_PARTY_SITE_ID ' || L_PARTY_SITE_ID ) ;
       oe_debug_pub.add(  'BEFORE CALL TO ISDELIVERY REQ' ) ;
   END IF;
   ecx_document.isDeliveryRequired
                         (
                         transaction_type    => p_transaction_type,
                         transaction_subtype => p_transaction_subtype,
                         party_id            => l_party_id,
                         party_site_id       => l_party_site_id,
                         resultout           => l_result,
                         retcode             => l_retcode,
                         errmsg              => l_errmsg
                         );
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'AFTER CALL TO ISDELIVERY REQ ' || L_ERRMSG ) ;
   END IF;

   IF (l_result) THEN
     x_is_delivery_required := 'Y';
     x_party_site_id := l_party_site_id;
     x_party_id      := l_party_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IS DELIVERY REQUIRED' || X_IS_DELIVERY_REQUIRED ) ;
     END IF;
   ELSE
     x_is_delivery_required := 'N';
     x_party_site_id := l_party_site_id;
     x_party_id      := l_party_id;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'IS DELIVERY REQUIRED' || X_IS_DELIVERY_REQUIRED ) ;
     END IF;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: EXITING IS_DELIVERY_REQUIRED' ) ;
   END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: EXITING IS_DELIVERY_REQUIRED WITH NO_DATA_FOUND' ) ;
   END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    -- start bug 3711152
    -- fnd_message.set_name ('ONT', 'OE_OI_TP_NOT_FOUND');
    -- fnd_message.set_token ('CUST_ID', p_customer_id);
    -- oe_msg_pub.add;
    -- end bug 3711152
  WHEN OTHERS THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPACKB: EXITING IS_DELIVERY_REQUIRED WITH OTHERS' ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Is_Delivery_Required');
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'ERROR MESSAGE : '||SUBSTR ( SQLERRM , 1 , 200 ) , 1 ) ;
    END IF;

End Is_Delivery_Required;
-- End of the Is_Delivery_Required }

-- { Start of the Process_SSO
-- This api will do following
-- 1.   Check to see if the Customer is a TP and required 3A6
--      IF 'NO' Then Exit out of the procedure without doing anything else
--      IF 'YES' then go to step 2.
-- 2.   Check for the columns change which can trigger the sending of the
--      3A6.
-- 2a.  Check at the header record if any relevant column change then set the
--      Flag that Header record need to be send.
-- 2b.  Loop thru the Line table to check for the line level relevant change and
--      Keep on Inserting that records Line_Id in the Acknowledgment table, with
--      the status information because at this point we know what is the reason
--      for this information sending. Also Set the Flag that the Line Information
--      is inserted.
-- 3.   Check if flag related to Header information needed to be inserted is
--      there or Line inserted flag is there then insert the header_id too in
--      the header ack table, as you can not send line without header even nothing
--      changed for the header.
-- 4.   ....
PROCEDURE Process_SSO
(  p_api_version_number            IN  NUMBER :=1, -- GENESIS
   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE,
   p_header_rec                    IN  OE_Order_Pub.Header_Rec_Type,
   p_line_tbl                      IN  OE_Order_Pub.Line_Tbl_Type,
   p_old_header_rec                IN  OE_Order_Pub.Header_Rec_Type,
   p_old_line_tbl                  IN  OE_Order_Pub.Line_Tbl_Type,
   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
   l_is_delivery_required      varchar2(1);
   l_party_id                  Number;
   l_party_site_id             Number;
   l_header_req                varchar2(1);
   l_line_req                  varchar2(1);
   l_change_usp                varchar2(1);
   l_change_oqty               varchar2(1);
   l_change_sadt               varchar2(1);
   l_change_sqty               varchar2(1);
   l_change_ssdt               varchar2(1);
   l_change_uom                varchar2(1);

  -- GENESIS --
   l_change_fsc                varchar2(1);
   l_sync_header               VARCHAR2(1); -- := 'N';
   l_sync_line                 VARCHAR2(1); -- := 'N';
   l_insert_sync_line          VARCHAR2(1); -- := 'N';
   l_change_type               VARCHAR2(30); -- := NULL;
   l_ack_type                  VARCHAR2(30); -- := NULL;
   l_sync_header_id            NUMBER;
   l_sync_line_id              NUMBER;
   l_hdr_req_id                NUMBER;
   l_lin_req_id                NUMBER;
  -- GENESIS --

   l_header_status             varchar2(30);
   l_header_status_cso         varchar2(30);
   l_line_status               varchar2(30);
   l_line_rec                  OE_Order_Pub.Line_Rec_Type;
   i                           pls_integer;
   j                           pls_integer;
   l_return_status             varchar2(1);
   l_itemkey_sso               number;
   l_itemkey_cso               number;
   l_header_rec                OE_Order_Pub.Header_Rec_Type;
   l_line_tbl                  OE_Order_Pub.Line_Tbl_Type;
   l_is_delivery_required_cso  varchar2(1) := 'N'; -- initialized so that if the code release level
    						   -- is below 110510, then the code behaves
 						   -- exactly the same as when 3A7 transaction is not set up at all
   l_change_usp_cso            varchar2(1);  -- variables to detect when 3a7 is to be generated
   l_change_ssdt_cso           varchar2(1);
   l_change_oqty_cso           varchar2(1);
   l_change_uom_cso           varchar2(1);
   l_header_req_cso            varchar2(1);
   l_line_req_cso              varchar2(1);
   l_line_status_cso           varchar2(30);
   l_hold_result     VARCHAR2(30);
   l_hold_id           NUMBER := 56;
   l_msg_count       NUMBER := 0;
   l_msg_data        VARCHAR2(2000);
   l_cso_response_profile      varchar2(1);
   l_apply_3a7_hold            boolean := FALSE;
   l_3a7_buyer_line            boolean := FALSE;
   l_line_exists     VARCHAR2(10) := 'N';           -- Bug 9685021

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

   l_header_rec := p_header_rec;
   l_line_tbl   := p_line_tbl;

   select OE_XML_MESSAGE_SEQ_S.nextval
   into l_itemkey_sso
   from dual;

   select OE_XML_MESSAGE_SEQ_S.nextval
   into l_itemkey_cso
   from dual;

   -- no longer needed, and we also are using the actual request_id
   -- to detect which lines were changed by the buyer for 3a7

   /*    l_header_rec.request_id := l_itemkey_sso;

   k := l_line_tbl.First;
   while k is not null loop
      l_line_tbl(k).request_id := l_itemkey_sso;
      k := l_line_tbl.Next(k);
   end loop;*/

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: ENTERING PROCESS_SSO, itemkeys are ' || l_itemkey_sso || ' and ' || l_itemkey_cso ) ;
   END IF;

IF NOT(OE_GENESIS_UTIL.source_aia_enabled(p_header_rec.order_source_id)) THEN    -- GENESIS
   -- { Start step 1.
   -- Call the is_delivery_required api
   Is_Delivery_Required( p_customer_id          => l_header_rec.sold_to_org_id,
                         p_transaction_type     => 'ONT',
                         p_transaction_subtype  => G_TRANSACTION_SSO,
                         p_org_id               => p_header_rec.org_id,
 		 	 x_party_id             => l_party_id,
                         x_party_site_id        => l_party_site_id,
                         x_is_delivery_required => l_is_delivery_required,
                         x_return_status        => l_return_status
                        );

   If (OE_Code_Control.code_release_level >= '110510') Then

      Is_Delivery_Required( p_customer_id          => l_header_rec.sold_to_org_id,
                             p_transaction_type     => 'ONT',
                             p_transaction_subtype  => G_TRANSACTION_CSO,
			     p_org_id               => p_header_rec.org_id,
                             x_party_id             => l_party_id,
                             x_party_site_id        => l_party_site_id,
                             x_is_delivery_required => l_is_delivery_required_cso,
                             x_return_status        => l_return_status
                            );
      IF l_is_delivery_required_cso = 'Y' THEN
         -- populate profile only if 3a7 is set up, this will need to change if we start
         -- supporting holds via 3a6 also
         l_cso_response_profile := nvl(FND_PROFILE.VALUE ('ONT_3A7_RESPONSE_REQUIRED'), 'N');
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPACKB: is delivery required for 3a7 = ' || l_is_delivery_required_cso ) ;
         oe_debug_pub.add(  'OEXPACKB: fetched CSO Response Required profile  ' ||  l_cso_response_profile) ;
      END IF;

   End If;

   If l_is_delivery_required = 'N' And
      l_is_delivery_required_cso = 'N' AND
      NOT(OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN    -- GENESIS
      -- No delivery is required so return, no further processing is required
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPACKB: NO DELIVERY IS REQUIRED SO RETURN' ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      return;
   end if;
  END IF; -- Order source Id


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'PRINTING HEADER RECORD VALUES' ) ;
       oe_debug_pub.add(  'OLD HEADER RECORD:' ) ;
       oe_debug_pub.add(  'orig_sys_document_ref:' || p_old_header_rec.orig_sys_document_ref) ;
       oe_debug_pub.add(  'booked_flag:' || p_old_header_rec.booked_flag) ;
       oe_debug_pub.add(  'flow_status_code:' || p_old_header_rec.flow_status_code) ;
       oe_debug_pub.add(  'request_id:' || p_old_header_rec.request_id) ;
       oe_debug_pub.add(  'transaction type:' || p_old_header_rec.xml_transaction_type_code) ;
       oe_debug_pub.add(  'operation code' || p_old_header_rec.operation) ;
       oe_debug_pub.add(  'xml message id:' || p_old_header_rec.xml_message_id) ;
       oe_debug_pub.add(  'NEW HEADER RECORD:' ) ;
       oe_debug_pub.add(  'orig_sys_document_ref:' || p_header_rec.orig_sys_document_ref) ;
       oe_debug_pub.add(  'booked_flag:' || p_header_rec.booked_flag) ;
       oe_debug_pub.add(  'flow_status_code:' || p_header_rec.flow_status_code) ;
       oe_debug_pub.add(  'request_id:' || p_header_rec.request_id) ;
       oe_debug_pub.add(  'transaction type:' || p_header_rec.xml_transaction_type_code) ;
       oe_debug_pub.add(  'operation code:' || p_header_rec.operation) ;
       oe_debug_pub.add(  'xml message id:' || p_header_rec.xml_message_id) ;
       oe_debug_pub.add(  'OE_ORDER_UTIL.G_HEADER_REC:' ) ;
       oe_debug_pub.add(  'orig_sys_document_ref:' || OE_ORDER_UTIL.g_header_rec.orig_sys_document_ref) ;
       oe_debug_pub.add(  'booked_flag:' || OE_ORDER_UTIL.g_header_rec.booked_flag) ;
       oe_debug_pub.add(  'flow_status_code:' || OE_ORDER_UTIL.g_header_rec.flow_status_code) ;
       oe_debug_pub.add(  'request_id:' || OE_ORDER_UTIL.g_header_rec.request_id) ;
       oe_debug_pub.add(  'transaction type:' || OE_ORDER_UTIL.g_header_rec.xml_transaction_type_code) ;
       oe_debug_pub.add(  'operation code:' || OE_ORDER_UTIL.g_header_rec.operation) ;
       oe_debug_pub.add(  'xml message id:' || OE_ORDER_UTIL.g_header_rec.xml_message_id) ;
   END IF;

   -- End step 1. }


   -- { Start step 2.
   -- Check for the columns which will trigger the 3A6, requirement

   -- { Start step 2a.
   -- Check for the header data, right now only the flow_status_code change
   -- i.e., when order booked first time, we need to send the 3A6.
   -- let us check for that

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'P_OLD_HEADER_REC.FLOW_STATUS_CODE ' || p_old_header_rec.flow_status_code) ;
      oe_debug_pub.add(  'L_HEADER_REC.FLOW_STATUS_CODE ' || l_header_rec.flow_status_code) ;
      oe_debug_pub.add(  'OE_ORDER_UTIL.G_HEADER_REC.FLOW_STATUS_CODE ' || OE_ORDER_UTIL.g_header_rec.flow_status_code) ;
   END IF;

   l_header_req := 'N';
   l_header_req_cso := 'N';
   if l_header_rec.flow_status_code = 'BOOKED' AND
      NOT(OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN    -- GENESIS
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPACKB: L_HEADER_REC.FLOW_STATUS_CODE = BOOKED' ) ;
      END IF;
      if nvl(p_old_header_rec.flow_status_code, 'BOOKED') <> 'BOOKED' And
         nvl(OE_ORDER_UTIL.g_header_rec.flow_status_code, 'N') = 'BOOKED' Then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPACKB: P_OLD_HEADER_REC.FLOW_STATUS_CODE <> BOOKED' ) ;
      END IF;
        -- This means that order is Booked right now, and this is the condidate
        -- for 3A6, set the flag to indicate that..

        l_header_req := 'Y';
        -- set some code to indicate that this 3A6 required because of this
        -- change, we should be able to use last_ack_code. Discuss...further

        -- 3A7 changes
        -- The logic is as follows:
        -- At this point we have determined that the order has just been booked
        -- (barring any notification issues). Thus, if the XML orders accept state profile
        -- is set to 'BOOKED' then we have a change from 'Pending' to 'Accept' and thus
        -- need to send a 3A7, otherwise we turn off 3a7
        IF l_is_delivery_required_cso = 'Y' THEN
           IF nvl(FND_PROFILE.VALUE('ONT_XML_ACCEPT_STATE'), 'ENTERED') = 'ENTERED' THEN
              l_header_req_cso   := 'N'; -- i.e. 3a7 not sent on Booking if accept state is Entered,
                                         -- unless of course there are line_changes (handled later)
           ELSIF nvl(OE_GLOBALS.G_XML_TXN_CODE, G_TRANSACTION_CSO) = G_TRANSACTION_POI THEN
              l_header_req_cso   := 'N'; -- i.e. don't send 3a7 if order is booked by buyer
           ELSE
              l_header_req_cso   := 'Y';
           END IF;
        END IF;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPACKB: L_HEADER_STATUS = BOOKED' ) ;
            oe_debug_pub.add(  'OEXPACKB: L_IS_DELIVERY_REQD_CSO = ' || l_is_delivery_required_cso ) ;
        END IF;
        l_header_status     := 'BOOKED';
        l_header_status_cso := 'BOOKED';
      end if;

    -- GENESIS --
-- Commented out as a part of O2C 2.5 (8516700:R12.ONT.B).
-- Replacement code made available immediately below.
/*
       ELSIF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) AND
             l_header_rec.flow_status_code <> 'BOOKED' AND
             l_header_rec.flow_status_code  = 'CLOSED' AND
             p_old_header_rec.flow_status_code <> l_header_rec.flow_status_code THEN
*/
       ELSIF
         (
           (Oe_Genesis_Util.Source_Aia_Enabled(l_header_rec.order_source_id))
              AND
           (p_old_header_rec.flow_status_code <> l_header_rec.flow_status_code)
              AND
           (Oe_Genesis_Util.Status_Needs_Sync(l_header_rec.flow_status_code))
         )
       THEN

          l_header_req := 'Y';
          l_header_status := l_header_rec.flow_status_code;
          l_sync_header := 'Y';

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'Genesis: Set header flag for flow status code change');
             oe_debug_pub.add(  'Genesis: Order Source Id = '||l_header_rec.order_source_id);
             oe_debug_pub.add(  'Genesis: l_header_req = '||l_header_req);
             oe_debug_pub.add(  'Genesis: l_header_status = '||l_header_status);
             oe_debug_pub.add(  'Genesis: l_sync_header = '||l_sync_header);
          END IF;
    -- GENESIS --
    end if;
   -- End step 2a. }

   -- { Start step 2b.
   -- Check for the line data, unit_selling_price, ordered_qty,
   -- schedule_arrival_date, shipped_qty (that will go as status change 'SHIPPED'
   -- schedule_ship_date (this will also go as status change 'SCHEDULED'
   -- we need to send the 3A6 for above cases
   -- let us check for that

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: BEFORE THE WHILE LOOP' ) ;
   END IF;
   -- Following For loop is changed to while because of new Notify_OC change
   -- for i in 1..l_line_tbl.count
   -- loop
   i := l_line_tbl.First;
   while i is not null loop
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPACKB: INSIDE THE FOR LOOP FOR I = ' || I ) ;
     END IF;
	-- resetting whether or not a particular line is required
        -- and whether attributes have changed.      added 11/12/02  -jjmcfarl
	l_line_req := 'N';
        l_change_usp := 'N';
        l_change_oqty := 'N';
        l_change_sadt  := 'N';
        l_change_sqty  := 'N';
        l_change_ssdt  := 'N';
        l_change_uom   := 'N';
	l_change_fsc   := 'N'; -- GENESIS --
        l_change_usp_cso  := 'N';
        l_change_oqty_cso := 'N';
        l_change_uom_cso := 'N';
        l_change_ssdt_cso := 'N';
        l_line_req_cso := 'N';
        l_apply_3a7_hold := FALSE;
        l_3a7_buyer_line := FALSE;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'tested version line_id: ' || l_line_tbl(i).line_id);
            oe_debug_pub.add(  'passed in version line_id: ' || p_line_tbl(i).line_id);
            oe_debug_pub.add(  'old version line_id: ' || p_old_line_tbl(i).line_id);
        END IF;

    -- moved the derivation of the j index outside of the UPDATE if-statement that
    -- follows.  this is done so that j will be derived for both update and create
    -- operation codes, as it is needed to detect creates.  --jjmcfarl
    if l_line_tbl(i).line_id = p_old_line_tbl(i).line_id then
          j := i;
    else
          j := get_line_index(p_old_line_tbl, l_line_tbl(i).line_id);
          IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'got line index: ' || j);
          END IF;
    end if;

     -- { Start for the comparision when the operation on the Line table
     --   is UPDATE
    if l_line_tbl(i).operation = Oe_Globals.G_OPR_UPDATE then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPACKB: LINE OPERATIONS IS UPDATE' ) ;
        END IF;

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'PRINTING LINE RECORD VALUES' ) ;
       oe_debug_pub.add(  'OLD LINE RECORD:' ) ;
       oe_debug_pub.add(  '   orig_sys_document_ref: ' || p_old_line_tbl(j).orig_sys_document_ref) ;
       oe_debug_pub.add(  '   line_id              : ' || p_old_line_tbl(j).line_id) ;
       oe_debug_pub.add(  '   flow_status_code     : ' || p_old_line_tbl(j).flow_status_code) ;
       oe_debug_pub.add(  '   request_id           : ' || p_old_line_tbl(j).request_id) ;
       oe_debug_pub.add(  '   operation            : ' || p_old_line_tbl(j).operation) ;
       oe_debug_pub.add(  '   unit_selling_price   : ' || p_old_line_tbl(j).unit_selling_price) ;
       oe_debug_pub.add(  '   ordered_quantity     : ' || p_old_line_tbl(j).ordered_quantity) ;
       oe_debug_pub.add(  '   order_quantity_uom   : ' || p_old_line_tbl(j).order_quantity_uom) ;
       oe_debug_pub.add(  '   schedule_arrival_date: ' || p_old_line_tbl(j).schedule_arrival_date) ;
       oe_debug_pub.add(  '   shipped_quantity     : ' || p_old_line_tbl(j).shipped_quantity) ;
       oe_debug_pub.add(  '   schedule_ship_date   : ' || p_old_line_tbl(j).schedule_ship_date) ;
       oe_debug_pub.add(  '   transaction type     : ' || p_old_line_tbl(j).xml_transaction_type_code) ;
       oe_debug_pub.add(  'NEW LINE RECORD:' ) ;
       oe_debug_pub.add(  '   orig_sys_document_ref: ' || l_line_tbl(i).orig_sys_document_ref) ;
       oe_debug_pub.add(  '   line_id              : ' || l_line_tbl(i).line_id) ;
       oe_debug_pub.add(  '   flow_status_code     : ' || l_line_tbl(i).flow_status_code) ;
       oe_debug_pub.add(  '   request_id           : ' || l_line_tbl(i).request_id) ;
       oe_debug_pub.add(  '   operation            : ' || l_line_tbl(i).operation) ;
       oe_debug_pub.add(  '   unit_selling_price   : ' || l_line_tbl(i).unit_selling_price) ;
       oe_debug_pub.add(  '   ordered_quantity     : ' || l_line_tbl(i).ordered_quantity) ;
       oe_debug_pub.add(  '   order_quantity_uom   : ' || l_line_tbl(i).order_quantity_uom) ;
       oe_debug_pub.add(  '   schedule_arrival_date: ' || l_line_tbl(i).schedule_arrival_date) ;
       oe_debug_pub.add(  '   shipped_quantity     : ' || l_line_tbl(i).shipped_quantity) ;
       oe_debug_pub.add(  '   schedule_ship_date   : ' || l_line_tbl(i).schedule_ship_date) ;
       oe_debug_pub.add(  '   transaction type     : ' || l_line_tbl(i).xml_transaction_type_code) ;
     END IF;

        -- { start j <> 0
        if j <> 0 then

           if nvl(l_line_tbl(i).unit_selling_price, 0) <>
              nvl(p_old_line_tbl(j).unit_selling_price, 0) then
              -- set flag to indicate that unit_selling_price has changed
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET FLAG TO INDICATE THAT UNIT_SELLING_PRICE' ) ;
              END IF;
              l_change_usp := 'Y';
              l_change_usp_cso := 'Y';
           end if; -- unit_selling_price

           if nvl(l_line_tbl(i).ordered_quantity, 0) <>
              nvl(p_old_line_tbl(j).ordered_quantity, 0) then
              -- set flag to indicate that ordered_quantity has changed
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET FLAG TO INDICATE THAT ORDERED_QUANTITY' ) ;
              END IF;
              l_change_oqty := 'Y';
              l_change_oqty_cso := 'Y';
	            -- GENESIS --
	            l_sync_line := 'Y';
	            l_insert_sync_line := 'Y';
              l_change_type := 'SPLIT';
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Genesis: Set line flag for ordered quantity change');
              END IF;
	            -- GENESIS --
           end if; -- ordered_quantity

           if not oe_globals.equal (l_line_tbl(i).order_quantity_uom,
                                    p_old_line_tbl(j).order_quantity_uom) then
              -- set flag to indicate that uom has changed
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET FLAG TO INDICATE THAT ORDER_QUANTITY_UOM' ) ;
              END IF;
              l_change_uom := 'Y';
              l_change_uom_cso := 'Y';
           end if;

           if nvl(l_line_tbl(i).schedule_arrival_date, trunc(sysdate)) <>
              nvl(p_old_line_tbl(j).schedule_arrival_date, trunc(sysdate)) then
              -- set flag to indicate that schedule_arrival_date has changed
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET FLAG TO INDICATE THAT SCHEDULE_ARRIVAL_DATE' ) ;
              END IF;
              l_change_sadt := 'Y';
	            -- GENESIS --
	            l_sync_line := 'Y';
              l_insert_sync_line := 'Y';
              l_change_type := 'ARVL_DT_CHG';
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Genesis: Set line flag for schedule arrival date change');
              END IF;
	            -- GENESIS --
           end if; -- schedule_arrival_date
           if nvl(l_line_tbl(i).shipped_quantity, 0) <>
              nvl(p_old_line_tbl(j).shipped_quantity, 0) then
              -- set flag to indicate that shipped_quantity has changed
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET FLAG TO INDICATE THAT SHIPPED_QUANTITY' ) ;
              END IF;
              l_change_sqty := 'Y';
           end if; -- shipped_quantity
           if nvl(l_line_tbl(i).schedule_ship_date, trunc(sysdate)) <>
              nvl(p_old_line_tbl(j).schedule_ship_date, trunc(sysdate)) then
              -- set flag to indicate that schedule_ship_date has changed
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'SET FLAG TO INDICATE THAT SCHEDULE_SHIP_DATE' ) ;
              END IF;
              l_change_ssdt := 'Y';
              l_change_ssdt_cso := 'Y';
	            -- GENESIS --
	            l_sync_line := 'Y';
              l_insert_sync_line := 'Y';
              l_change_type := 'SHIP_DT_CHG';
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Genesis: Set line flag for schedule ship date change');
              END IF;
	            -- GENESIS --
           end if; -- schedule_ship_date

            -- O2C 25: ship from org id (Bug 8722247)
            IF Nvl(l_line_tbl(i).ship_from_org_id, -99) <>
                      Nvl(p_old_line_tbl(j).ship_from_org_id, -99) THEN

              l_sync_line         :=  'Y';
              l_insert_sync_line  :=  'Y';
              l_change_type       :=  'SHP_FRM_CHG';
              IF l_debug_level > 0 THEN
                oe_debug_pub.ADD('Genesis: set line flag for ship from org id change');
              END IF;
            END IF;
            -- O2C 25:ship from org id

           -- O2C 25: shipping_method_code (Bug 8936919 gabhatia)
            IF Nvl(l_line_tbl(i).shipping_method_code, -99) <>
                      Nvl(p_old_line_tbl(j).shipping_method_code, -99) THEN

              l_sync_line         :=  'Y';
              l_insert_sync_line  :=  'Y';
              l_change_type       :=  'SHP_MTH_CHG';
              IF l_debug_level > 0 THEN
                oe_debug_pub.ADD('Genesis: set line flag for shipping_method_code change');
              END IF;
            END IF;
            -- O2C 25:shipping_method_code (End changes for Bug 8936919 gabhatia)


           -- GENESIS --
	   IF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) AND
              -- O2C25: 8516700: Start: Commented special processing for BOOKED,
              --        and remove hardcoding on flow status codes.
              -- l_line_tbl(i).flow_status_code <> 'BOOKED' AND
	          -- l_line_tbl(i).flow_status_code  in ('FULFILLED','AWAITING_SHIPPING','SHIPPED','CLOSED','SUPPLY_ELIGIBLE') AND
                Oe_Genesis_Util.Status_Needs_Sync(l_line_tbl(i).flow_status_code) AND
              -- O2C25: 8516700: End
	            l_line_tbl(i).flow_status_code <> p_old_line_tbl(j).flow_status_code THEN

 	            l_change_fsc := 'Y';
	            l_sync_line := 'Y';
	            l_insert_sync_line := 'Y';
	            l_change_type := 'LINE_STATUS';

	            IF l_debug_level  > 0 THEN
	               oe_debug_pub.add(  'Genesis: Set line flag for line flow status code change');
	            END IF;
           END IF;

           -- Call Sync Line to process multiple lines  ZB
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Genesis:  l_sync_line '|| l_sync_line);
                 oe_debug_pub.add(  'Genesis:  l_insert_sync_line '|| l_insert_sync_line);
                 oe_debug_pub.add(  'Genesis:  order_source_id '|| l_header_rec.order_source_id);
	            END IF;

	      IF l_insert_sync_line = 'Y' and
	         (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN
	      OE_SYNC_ORDER_PVT.INSERT_SYNC_lINE(P_LINE_rec       => l_line_tbl(i),
	                                      p_change_type   => l_change_type,
		                                    p_req_id        => l_itemkey_sso,
		                                    X_RETURN_STATUS => L_RETURN_STATUS);
        END IF;
        l_insert_sync_line := 'N';
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'Genesis:  after insert :l_insert_sync_line '|| l_insert_sync_line);
        END IF;
        -- GENESIS --

           IF l_change_oqty_cso = 'Y' OR
              l_change_uom_cso  = 'Y' OR
              l_change_usp_cso  = 'Y' OR
              (l_change_ssdt_cso = 'Y' AND
               nvl(p_old_line_tbl(j).schedule_ship_date, FND_API.G_MISS_DATE) <> FND_API.G_MISS_DATE)
           THEN
              l_apply_3a7_hold := TRUE;
           END IF;
        end if; -- j <> 0
        -- end j <> 0 }
     end If; -- Update operation
     -- End for the comparison when the operation on the Line table is UPDATE }

     -- { Start of processing to see if the insert is required if YES
     --   Then what should the status be.

     --   We should insert into Line table for the following conditions
     --   a. It the operation is insert, this means the new line is added
     --      to a BOOKED order.
     --   b. If j = 0, means this line is creating during process order
     --      call, and might be a new line so send the data in 3A6 (we no longer do this)

     --   c. Any of the flag is set to 'Y', means change to the triggering
     --      columns has been made send the 3A6

     --   d. set the flag to insert the header too, if flag at header level
     --      is not set yet.

     -- { Start of a., b., c. and d.

     -- changed for bug 3424468 to check operation code on old line instead of new line

        is_line_exists(p_line_tbl(j).line_id,l_line_exists);                -- Bug 9685021

     if p_old_line_tbl(j).operation = Oe_Globals.G_OPR_INSERT or
        p_old_line_tbl(j).operation = Oe_Globals.G_OPR_CREATE or
        (l_line_exists ='N' and p_line_tbl(j).booked_flag ='Y' ) then        -- Added Condition for bug 9685021

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPACKB: LINE OPERATIONS IS INSERT' ) ;
            oe_debug_pub.add(  'OEXPACKB:  - p_old_line_id(j)'||p_old_line_tbl(j).line_id) ;
            oe_debug_pub.add(  'OEXPACKB:  - p_old_line_id(i)'||p_old_line_tbl(i).line_id) ;
            oe_debug_pub.add(  'OEXPACKB:  - p_line_id'||p_line_tbl(i).line_id ) ;
        END IF;
        ------------------------------
     -- GENESIS --
     -- Added this code to handle split case
        IF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPACKB:  - p_line_id(i).item_type_code'||p_line_tbl(i).item_type_code) ;
             oe_debug_pub.add(  'OEXPACKB:  - p_line_id(i).split_from_line_id'||p_line_tbl(i).split_from_line_id) ;
          END IF;
          l_sync_line := 'Y';
          IF (l_line_tbl(i).SPLIT_FROM_LINE_ID IS NOT NULL OR l_line_tbl(i).item_type_code <> 'CONFIG') THEN
             OE_SYNC_ORDER_PVT.INSERT_SYNC_lINE(P_LINE_rec  => l_line_tbl(i),
 	  	                                p_change_type   => l_change_type,
		                                  p_req_id        => l_itemkey_sso,
			                                X_RETURN_STATUS => L_RETURN_STATUS);
           END IF;
         END IF;
     -- GENESIS --
        ------------------------------
        l_line_req    := 'Y';
        l_line_status := 'OPEN';

        -- trigger 3A7 for new line added to booked order
        -- and apply hold, unless line was added by buyer
        if nvl(OE_ORDER_UTIL.g_header_rec.xml_transaction_type_code, G_TRANSACTION_CSO)
                    = G_TRANSACTION_CSO THEN
           l_apply_3a7_hold := TRUE;
           l_line_req_cso := 'Y';
        end if;
        l_line_status_cso := 'OPEN';
        ------------------------------
      elsif l_change_usp = 'Y' then
        ------------------------------
        l_line_req    := 'Y';
        l_line_status := 'OPEN';
        ------------------------------
      elsif (l_change_oqty = 'Y' or l_change_uom = 'Y')  then
        ------------------------------
        l_line_req    := 'Y';
        if  l_line_tbl(i).ordered_quantity = 0 then
          l_line_status := 'CANCELLED';
        else
           l_line_status := 'OPEN';
        end if;
        ------------------------------
      elsif l_change_sadt = 'Y' then
        ------------------------------
        l_line_req    := 'Y';
        if l_line_tbl(i).flow_status_code = 'CANCELLED' then
           l_line_status := 'CANCELLED';
        else
           l_line_status := 'OPEN';
        end if;
        ------------------------------
      elsif l_change_ssdt = 'Y' then
        ------------------------------
        l_line_req    := 'Y';
        l_line_status := 'OPEN';
        ------------------------------
      elsif l_change_sqty = 'Y' then
        ------------------------------
        l_line_req    := 'Y';
        l_line_status := 'SHIPPED';
        ------------------------------
      -- GENESIS --
      elsif l_change_fsc = 'Y' then
        ------------------------------
        l_line_req    := 'Y';
        l_line_status := l_line_tbl(i).flow_status_code;
        ------------------------------
      -- GENESIS --
      end if;

      --------------------------------
      -- 3A7 changes, arihan
      --------------------------------
      if l_change_usp_cso = 'Y' then
        ------------------------------
        l_line_req_cso    := 'Y';
        l_line_status_cso     := 'OPEN';
        ------------------------------
      elsif (l_change_oqty_cso = 'Y' or l_change_uom_cso = 'Y')  then
        ------------------------------
        l_line_req_cso    := 'Y';
        if  l_line_tbl(i).ordered_quantity = 0 then
          l_line_status_cso := 'CANCELLED';
        else
           l_line_status_cso := 'OPEN';
        end if;
        ------------------------------
      elsif l_change_ssdt_cso = 'Y' then
        ------------------------------
        l_line_req_cso    := 'Y';
        l_line_status_cso := 'OPEN';
        ------------------------------
      end if;

      -- checking for closed line status.  The only case we would ignore is when a line
      -- was just shipped or cancelled.  In these cases we would allow that to be
      -- the line status, as they reflect the reason for the 3a6.  Otherwise if the line
      -- is closed, we should reflect that

     if ((l_line_status <> 'SHIPPED') And
        (l_line_status <> 'CANCELLED') And
        (l_line_tbl(i).flow_status_code = 'CLOSED')) Then

        l_line_status := 'CLOSED';
        l_line_status_cso := 'CLOSED';
     end if;
     -- End of a., b. and c. }

     if l_line_req = 'Y' and
        l_header_req <> 'Y' and l_header_req <> 'D' then
        l_header_req := 'Y';
        l_header_status := 'OPEN';
     end if;

     -- GENESIS --
     IF l_sync_line = 'Y' THEN
        l_sync_header := 'Y';
     END IF;
     -- GENESIS --

     -- End of processing to see if the insert is required }


     -- the following condition tests if a line was sent by the buyer or not
     -- it compares the header request id to the line request id since
     -- Order Import will always populate these with the same value for
     -- header and line
     -- an exception is made for header-level cancellations
     IF l_is_delivery_required_cso = 'Y' THEN
         IF (OE_ORDER_UTIL.G_HEADER_REC.xml_transaction_type_code = G_TRANSACTION_CHO
         AND OE_GLOBALS.Equal (l_header_rec.request_id, l_line_tbl(i).request_id)
         AND nvl(l_header_rec.request_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) OR

        (OE_ORDER_UTIL.G_HEADER_REC.xml_transaction_type_code = G_TRANSACTION_CPO
         AND OE_GLOBALS.Equal (l_header_rec.request_id, l_line_tbl(i).request_id)
         AND nvl(l_header_rec.request_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) OR

        (OE_ORDER_UTIL.G_HEADER_REC.xml_transaction_type_code = G_TRANSACTION_CPO
         AND nvl(l_header_rec.cancelled_flag,'N') = 'Y')
     THEN
         IF l_debug_level > 0 THEN
            oe_debug_pub.add('3A7 Buyer change detected, line will not be sent or put on hold');
         END IF;
         l_3a7_buyer_line := TRUE;
         l_line_req_cso := 'N'; -- don't insert the line
     END IF;

     END IF;

      if l_line_req_cso = 'Y' and
        l_header_req_cso <> 'Y' and l_header_req_cso <> 'D' then
        l_header_req_cso := 'Y';
        l_header_status_cso := 'OPEN';
     end if;

     -- start of checking to see if 3A7 hold needs to be applied
     -- Note that we only apply a hold if line was not sent in by the buyer
     IF l_apply_3a7_hold THEN
        IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
           IF l_is_delivery_required_cso = 'Y'
              AND l_cso_response_profile = 'Y'
              AND NOT l_3a7_buyer_line
              AND nvl(OE_GLOBALS.G_XML_TXN_CODE, G_TRANSACTION_CSO) <> G_TRANSACTION_POI
              AND l_line_tbl(i).order_source_id = G_XML_ORDER_SOURCE_ID
              AND l_line_tbl(i).ordered_quantity <> 0
              AND nvl(l_line_tbl(i).booked_flag, 'N') = 'Y'
              AND nvl(l_line_tbl(i).xml_transaction_type_code, G_TRANSACTION_CSO) = G_TRANSACTION_CSO
           THEN

              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Calling OE_Acknowlegment_PUB.Apply_3A7_Hold', 2 ) ;
              END IF;
              OE_Acknowledgment_PUB.Apply_3A7_Hold
                             ( p_header_id       =>   l_line_tbl(i).header_id
                             , p_line_id         =>   l_line_tbl(i).line_id
                             , p_sold_to_org_id  =>   l_line_tbl(i).sold_to_org_id
                             , p_tp_check        =>   FND_API.G_FALSE
                             , x_return_status   =>   l_return_status);
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Return status after call to apply_3a7_hold:' || l_return_status, 2 ) ;
              END IF;
           END IF;
       END IF;
     END IF;
     -- end of 3a7 hold application

     -- { Start of l_line_req
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'START 3A6 PROCESSING ON HEADER/LINES' ) ;
	    oe_debug_pub.add(  '   L_HEADER_STATUS : ' || L_HEADER_STATUS ) ;
	    oe_debug_pub.add(  '   L_HEADER_REQ    : ' || L_HEADER_REQ ) ;
	    oe_debug_pub.add(  '   L_LINE_REQ      : ' || L_LINE_REQ ) ;
	END IF;
     if (l_line_req = 'Y') OR (l_header_status = 'BOOKED')  then
       -- Call insert routine to insert header_id and status info
       If l_header_req = 'Y' Then

         If l_header_rec.flow_status_code = 'CANCELLED' then
              l_header_status := 'CANCELLED';
         Elsif l_header_rec.flow_status_code = 'CLOSED' then
              l_header_status := 'CLOSED';
         End If;

         -- GENESIS --
	 IF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN
            l_ack_type := G_TRANSACTION_SEBL;
         ELSE
	    l_ack_type := G_TRANSACTION_SSO;
	       END IF;
	       -- GENESIS --

         If l_is_delivery_required = 'Y' Then
             Insert_Header ( p_header_rec    =>  l_header_rec,
                             p_header_status =>  l_header_status,
                             p_ack_type      =>  l_ack_type, -- GENESIS G_TRANSACTION_SSO,
                             p_itemkey       =>  l_itemkey_sso,
                             x_return_status =>  l_return_status
                            );
         End If;
          If l_return_status = FND_API.G_RET_STS_SUCCESS Then
             l_header_req := 'D';
          End If;
       End If;
        -- Call insert routine to insert line_id and status info
        -- which will later be used to populate data in line ack
        -- table
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSERTING LINE RECORD WITH INDEX = ' || I ) ;
	END IF;
        l_line_rec  := l_line_tbl(i);

    --ensure that a valid line has been pulled from the lines table
    If l_line_rec.line_id is not null then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  '   L_HEADER_STATUS : ' || L_HEADER_STATUS ) ;
	    oe_debug_pub.add(  '   L_HEADER_REQ    :  ' || L_HEADER_REQ ) ;
	    oe_debug_pub.add(  '   L_LINE_REQ      :  ' || L_LINE_REQ ) ;
	    oe_debug_pub.add(  '   L_LINE_STATUS   : ' || L_LINE_STATUS ) ;
	END IF;

        -- GENESIS --
	         oe_debug_pub.add(  'Genesis: 6.1');
	   IF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN
              l_ack_type := G_TRANSACTION_SEBL;
           ELSE
              l_ack_type := G_TRANSACTION_SSO;
           END IF;
        -- GENESIS --
        If l_is_delivery_required = 'Y' Then
           Insert_Line ( p_line_rec      =>  l_line_rec,
                         p_line_status   =>  l_line_status,
                         p_ack_type      =>  l_ack_type, -- GENESIS G_TRANSACTION_SSO,
                         p_itemkey       =>  l_itemkey_sso,
                         x_return_status =>  l_return_status
                       );
        End If;
        x_return_status := l_return_status;
    End If;
  end if;

     -- { Start of l_line_req_cso
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'START 3A7 PROCESSING ON HEADER/LINES' ) ;
	oe_debug_pub.add(  '   L_HEADER_STATUS IS : ' || L_HEADER_STATUS_CSO ) ;
	oe_debug_pub.add(  '   L_HEADER_REQ_CSO   : ' || L_HEADER_REQ_CSO ) ;
	oe_debug_pub.add(  '   L_LINE_REQ_CSO     : ' || L_LINE_REQ_CSO ) ;
     END IF;
     if (l_line_req_cso = 'Y') OR (l_header_status_cso = 'BOOKED')  then
       -- Call insert routine to insert header_id and status info
       If l_header_req_cso = 'Y' Then

         If l_header_rec.flow_status_code = 'CANCELLED' then
              l_header_status_cso := 'CANCELLED';
         Elsif l_header_rec.flow_status_code = 'CLOSED' then
              l_header_status_cso := 'CLOSED';
         End If;
         If l_is_delivery_required_cso = 'Y' Then
--             If l_order_booked_cso = 'Y' Then
                Insert_Header ( p_header_rec    =>  l_header_rec,
                                p_header_status =>  l_header_status_cso,
                                p_ack_type      =>  G_TRANSACTION_CSO,
                                p_itemkey       =>  l_itemkey_cso,
                                x_return_status =>  l_return_status
                              );
--             End If;
          End If;
          If l_return_status = FND_API.G_RET_STS_SUCCESS Then
             l_header_req_cso := 'D';
          End If;
       End If;
        -- Call insert routine to insert line_id and status info
        -- which will later be used to populate data in line ack
        -- table
        IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSERTING LINE RECORD WITH INDEX = ' || I ) ;
	END IF;
        l_line_rec  := l_line_tbl(i);

     --ensure that a valid line has been pulled from the lines table
     If l_line_rec.line_id is not null then
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  '   L_HEADER_STATUS IS : ' || L_HEADER_STATUS_CSO ) ;
	    oe_debug_pub.add(  '   L_HEADER_REQ_CSO   : ' || L_HEADER_REQ_CSO ) ;
	    oe_debug_pub.add(  '   L_LINE_REQ_CSO     : ' || L_LINE_REQ_CSO ) ;
	    oe_debug_pub.add(  '   L_LINE_STATUS      : ' || L_LINE_STATUS_CSO ) ;
	END IF;
        If l_is_delivery_required_cso = 'Y' Then
          IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510'
             AND l_cso_response_profile = 'Y' THEN
             -- Check if Hold already exists on this order line
             IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'Process SSO: Check If Hold Already Applied' ) ;
             END IF;

             OE_HOLDS_PUB.Check_Holds
                ( p_api_version    => 1.0
                , p_header_id      => l_header_rec.header_id
                , p_line_id        => l_line_tbl(i).line_id
                , p_hold_id        => l_hold_id
                , p_entity_code    => 'O'
                , p_entity_id      => l_header_rec.header_id
                , x_result_out     => l_hold_result
                , x_msg_count      => l_msg_count
                , x_msg_data       => l_msg_data
                , x_return_status  => l_return_status
                );

             IF l_hold_result = FND_API.G_TRUE THEN
                IF l_debug_level  > 0 THEN
                   oe_debug_pub.add(  'Process SSO: Hold Already Applied On Header Id:'
                                   ||l_header_rec.header_id ||': Line_Id:'||l_line_tbl(i).line_id) ;
                   oe_debug_pub.add(  'Change line status for 3A7');
                 END IF;
                 l_line_status_cso := 'ON HOLD';
             END IF ;
          END IF;

          Insert_Line ( p_line_rec    =>  l_line_rec,
                        p_line_status =>  l_line_status_cso,
                        p_ack_type      =>  G_TRANSACTION_CSO,
                        p_itemkey       =>  l_itemkey_cso,
                         x_return_status =>  l_return_status
                        );
        End If;
        x_return_status := l_return_status;
     End If;
     end if;
     -- End of l_line_req_cso }

     i := l_line_tbl.Next(i);
   end loop;
   -- End step 2b. }
   -- End step 2. }

   -- { Start of 3.
   --   Check if the Header Insert is required

   if l_header_req = 'Y' Then

         If l_header_rec.flow_status_code = 'CANCELLED' then
              l_header_status := 'CANCELLED';
         Elsif l_header_rec.flow_status_code = 'CLOSED' then
              l_header_status := 'CLOSED';
         End If;

         -- GENESIS --
	 IF (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) THEN
            l_ack_type := G_TRANSACTION_SEBL;
         ELSE
            l_ack_type := G_TRANSACTION_SSO;
         END IF;
         -- GENESIS --

         If l_is_delivery_required = 'Y' Then
          Insert_Header ( p_header_rec    =>  l_header_rec,
                          p_header_status =>  l_header_status,
                          p_ack_type      =>  l_ack_type, -- GENESIS G_TRANSACTION_SSO,
                          p_itemkey       =>  l_itemkey_sso,
                          x_return_status =>  l_return_status
                        );
       End If;
      if l_return_status = FND_API.G_RET_STS_SUCCESS Then
         l_header_req := 'D';
      end if;
   end if;
   if l_header_req_cso = 'Y' Then

         If l_header_rec.flow_status_code = 'CANCELLED' then
              l_header_status_cso := 'CANCELLED';
         Elsif l_header_rec.flow_status_code = 'CLOSED' then
              l_header_status_cso := 'CLOSED';
         End If;
       If l_is_delivery_required_cso = 'Y' Then
--          If l_order_booked_cso = 'Y' Then  -- for beta release we only want to send 3a7 on booking
             Insert_Header ( p_header_rec    =>  l_header_rec,
                             p_header_status =>  l_header_status_cso,
                             p_ack_type      =>  G_TRANSACTION_CSO,
                             p_itemkey       =>  l_itemkey_cso,
                             x_return_status =>  l_return_status
                           );
--          End If;
       End If;
      if l_return_status = FND_API.G_RET_STS_SUCCESS Then
         l_header_req_cso := 'D';
      end if;
   end if;
   if l_header_req = 'D' then
      -- Raise ShowSo Event
      If l_is_delivery_required = 'Y' Then

         IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'Raising 3a6 event with itemkey: ' || l_itemkey_sso) ;
         END IF;

         OE_Acknowledgment_Pub.Raise_Event_Showso
          (p_header_id              => l_header_rec.header_id,
           p_line_id                => Null,
           p_customer_id            => l_header_rec.sold_to_org_id,
           p_orig_sys_document_ref  => l_header_rec.orig_sys_document_ref,
	       p_change_sequence        => l_header_rec.change_sequence,
           p_itemtype               => Null,
           p_itemkey                => l_itemkey_sso,
           p_party_id               => l_party_id,
           p_party_site_id          => l_party_site_id,
           p_transaction_type       => G_TRANSACTION_SSO,
           p_org_id                 => l_header_rec.org_id, /* Bug 5472200 */
           x_return_status          => l_return_status);

     End If;
   end if;
   if l_header_req_cso = 'D' then
     If l_is_delivery_required_cso = 'Y' Then
 --         If l_order_booked_cso = 'Y' Then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'Raising 3a7 event with itemkey: ' || l_itemkey_cso) ;
             END IF;

             OE_Acknowledgment_Pub.Raise_Event_Showso
              (p_header_id              => l_header_rec.header_id,
               p_line_id                => Null,
               p_customer_id            => l_header_rec.sold_to_org_id,
               p_orig_sys_document_ref  => l_header_rec.orig_sys_document_ref,
      	       p_change_sequence        => l_header_rec.change_sequence,
               p_itemtype               => Null,
               p_itemkey                => l_itemkey_cso,
               p_party_id               => l_party_id,
               p_party_site_id          => l_party_site_id,
               p_transaction_type       => G_TRANSACTION_CSO,
               p_org_id                 => l_header_rec.org_id, /* Bug 5472200 */
               x_return_status          => l_return_status);
 --         End If;
     End If;
   end if;

   -- GENESIS --
   l_sync_header_id := NULL;
   l_hdr_req_id     := NULL;
   l_sync_line_id   := NULL;
   l_lin_req_id     := NULL;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add('GENESIS PROCESS_SSO : l_sync_header:'|| l_sync_header || ', l_sync_line:'
                                                             || l_sync_line || ', l_change_type:'
                                                             || l_change_type);
   END IF;

   IF ( (OE_GENESIS_UTIL.source_aia_enabled(l_header_rec.order_source_id)) AND l_sync_header = 'Y') THEN

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('TESTING GENESIS 15...'||l_header_rec.order_source_id);
     END IF;

     IF l_sync_header = 'Y' THEN
        l_sync_header_id := l_header_rec.header_id;
        l_hdr_req_id     := l_header_rec.request_id;
     END IF;

     IF l_sync_line = 'Y' THEN
        l_sync_line_id := l_line_rec.line_id;
        l_lin_req_id   := l_line_rec.request_id;
     END IF;

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('TESTING GENESIS 16...l_header_rec.request_id'||l_header_rec.request_id);
	      oe_debug_pub.add('TESTING GENESIS 16...l_line_rec.request_id'||l_line_rec.request_id);
	      oe_debug_pub.add('TESTING GENESIS 16...l_hdr_req_id'||l_hdr_req_id);
	      oe_debug_pub.add('TESTING GENESIS 16...l_lin_req_id'|| l_lin_req_id);
	      oe_debug_pub.add('TESTING GENESIS 16...l_line_rec.flow_status_code'||l_line_rec.flow_status_code );
     END IF;

     OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE( p_header_rec          => l_header_rec
                                        ,p_line_rec            => null
                                        ,p_hdr_req_id          => l_itemkey_sso
                                        ,p_lin_req_id          => l_itemkey_sso
                                        ,p_change_type         => l_change_type);

     l_sync_header := 'N';
     l_sync_line   := 'N';
  END IF;
  -- GENESIS --

   x_return_status := l_return_status;

   -- End of 3. }

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXPACKB: EXITING PROCESS_SSO' ) ;
   END IF;
Exception
  When Others Then
    IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'process_sso');
    End if;
END Process_SSO;
-- End of the Process_SSO }

-- { Start of the Process_SSO_Conc_Pgm
-- This api will do following
-- 1.   Get the Orders for the Customer (TP), range of orders,
--      range of order dates, range of customer po and order status
--      Open right now, later we might have to support Close)
-- 2.   For each order for the requested criteria raise the event to run the
--      the Show Sales Order WF, which will genrate the SSO document
PROCEDURE Process_SSO_CONC_PGM
(  errbuf                          OUT NOCOPY /* file.sql.39 change */ VARCHAR,
   retcode                         OUT NOCOPY /* file.sql.39 change */ NUMBER,
   p_operating_unit                IN  NUMBER,
   p_customer_id                   IN  NUMBER,
   p_open_orders_only              IN  VARCHAR2,
   p_closed_for_days               IN  NUMBER,
   p_so_number_from                IN  NUMBER,
   p_so_number_to                  IN  NUMBER,
   p_so_date_from                  IN  VARCHAR2,
   p_so_date_to                    IN  VARCHAR2,
   p_customer_po_no_from           IN  VARCHAR2,
   p_customer_po_no_to             IN  VARCHAR2
)
IS

  l_msg_count         NUMBER        := 0 ;
  l_msg_data          VARCHAR2(2000):= NULL ;
  l_message_text      VARCHAR2(2000);

  --l_debug_level            NUMBER       := to_number(nvl(fnd_profile.value('ONT_DEBUG_LEVEL'),'0'));
  l_filename               VARCHAR2(200);
  l_request_id             NUMBER;
  l_org_id                 NUMBER;
  l_order_rec              Order_Rec_Type;
  l_order_count            NUMBER;
  l_return_status          VARCHAR2(30);
  l_so_date_from           DATE;
  l_so_date_to             DATE;
  l_party_id               NUMBER;
  l_party_site_id          NUMBER;
  l_is_delivery_required   VARCHAR2(1);
  l_open_flag              VARCHAR2(1) := 'Y';  -- prompt on conc pgm has been changed to "Include Closed Orders", so logic must change accordingly


  -- { Start of cursor definition for the Order Selection
  CURSOR  c_order_for_customer IS
     SELECT  header_id, sold_to_org_id, order_number, orig_sys_document_ref, order_source_id, change_sequence,org_id
     FROM    oe_order_headers
     WHERE   sold_to_org_id  = p_customer_id
--   AND     open_flag       = 'Y' -- only open orders are supported currently
     AND     open_flag       IN  ('Y', l_open_flag)
     AND     order_source_id = G_XML_ORDER_SOURCE_ID
     AND     order_number BETWEEN nvl(p_so_number_from,order_number) AND nvl(p_so_number_to,order_number)
     AND     ordered_date BETWEEN nvl(l_so_date_from,ordered_date) AND nvl(l_so_date_to + 1,ordered_date + 1)
     AND     nvl(cust_po_number, -99) BETWEEN nvl(p_customer_po_no_from,nvl(cust_po_number, -99)) AND nvl(p_customer_po_no_to,nvl(cust_po_number, -99))
     AND     org_id = nvl(p_operating_unit,org_id);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPACKB: ENTERING PROCESS_SSO_CONC_PGM' ) ;
  END IF;

  IF p_operating_unit IS NOT NULL THEN
    MO_GLOBAL.set_policy_context('S',p_operating_unit);
  END IF;

-- logic here is to reflect the fact that the p_open_orders_only parameter is now actually
-- the input to the renamed prompt "Include Closed Orders".  so if the of p_open_orders_only
-- is 'Y', then  we wish to include all orders (both open and closed).

  IF p_open_orders_only = 'Y' then
     l_open_flag := 'N';
  END IF;


  l_so_date_from := fnd_date.canonical_to_date(p_so_date_from);
  l_so_date_to := fnd_date.canonical_to_date(p_so_date_to);

   -----------------------------------------------------------
   -- Log Output file
   -----------------------------------------------------------

  fnd_file.put_line(FND_FILE.OUTPUT, 'Show Sales Order Concurrent Program');
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Concurrent Program Parameters');
  fnd_file.put_line(FND_FILE.OUTPUT, 'Customer id for Trading Partner : '|| p_customer_id);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Open Orders Only: '|| p_open_orders_only);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Sales Order Number From: '||p_so_number_from);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Sales Order Number To: '||p_so_number_to);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Sales Order Date From: '||p_so_date_from);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Sales Order Date To: '||p_so_date_to);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Customer PO number From: '||p_customer_po_no_from);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Customer PO Number To: '||p_customer_po_no_to);
  fnd_file.put_line(FND_FILE.OUTPUT, 'Org Id: '||p_operating_unit);
  fnd_file.put_line(FND_FILE.OUTPUT, '');
  fnd_file.put_line(FND_FILE.OUTPUT,'Debug Level: '||l_debug_level);

   -----------------------------------------------------------
   -- Setting Debug Mode and File
   -----------------------------------------------------------

   If nvl(l_debug_level, 1) > 0 Then
      l_filename := oe_debug_pub.set_debug_mode ('FILE');
      fnd_file.put_line(FND_FILE.OUTPUT,'Debug File: ' || l_filename);
      fnd_file.put_line(FND_FILE.OUTPUT, '');
   END IF;
   l_filename := OE_DEBUG_PUB.set_debug_mode ('CONC');

   -----------------------------------------------------------
   -- Get Concurrent Request Id
   -----------------------------------------------------------

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'BEFORE GETTING REQUEST ID' ) ;
  END IF;
  fnd_profile.get('CONC_REQUEST_ID', l_request_id);
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'REQUEST ID: '|| TO_CHAR ( L_REQUEST_ID ) ) ;
  END IF;
  fnd_file.put_line(FND_FILE.OUTPUT, 'Request Id: '|| to_char(l_request_id));

    OPEN c_order_for_customer;
    FETCH c_order_for_customer BULK COLLECT
    INTO  l_order_rec.header_id
         ,l_order_rec.sold_to_org_id
         ,l_order_rec.order_number
         ,l_order_rec.orig_sys_document_ref
         ,l_order_rec.order_source_id
         ,l_order_rec.change_sequence
         ,l_order_rec.org_id;
     CLOSE c_order_for_customer;

     l_order_count := l_order_rec.header_id.count;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'COUNT: '||L_ORDER_COUNT ) ;
     END IF;
     IF l_order_count > 0 THEN

   -----------------------------------------------------------
   -- Raise event for all orders fetched
   -----------------------------------------------------------
        FOR i IN 1..l_order_count LOOP
           IF l_debug_level  > 0 THEN
               oe_debug_pub.add(  'BEFORE CALL TO OE_ACKNOWLEDGMENT_PUB.RAISE_EVENT_SHOWSO API: '||I , 2 ) ;
               oe_debug_pub.add(  'HEADER ID: '||L_ORDER_REC.HEADER_ID ( I ) , 1 ) ;
               oe_debug_pub.add(  'SOLD TO ORGID: '||L_ORDER_REC.SOLD_TO_ORG_ID ( I ) , 1 ) ;
               oe_debug_pub.add(  'SALES ORDER NUMBER: '||L_ORDER_REC.ORDER_NUMBER ( I ) , 1 ) ;
               oe_debug_pub.add(  'ORIG SYS DOCUMENT REF: '||L_ORDER_REC.ORIG_SYS_DOCUMENT_REF ( I ) , 1 ) ;
               oe_debug_pub.add(  'ORDER SOURCE ID: '||L_ORDER_REC.ORDER_SOURCE_ID ( I ) , 1 ) ;
               oe_debug_pub.add(  'ORG ID: '||L_ORDER_REC.ORG_ID ( I ) , 1 ) ;
           END IF;

           Is_Delivery_Required( p_customer_id     => p_customer_id,
                            p_transaction_type     => 'ONT',
                            p_transaction_subtype  => G_TRANSACTION_SSO,
                            p_org_id               => l_order_rec.org_id(i),
                            x_party_id             => l_party_id,
                            x_party_site_id        => l_party_site_id,
                            x_is_delivery_required => l_is_delivery_required,
                            x_return_status        => l_return_status
                          );
           If l_return_status <>  FND_API.G_RET_STS_SUCCESS
              Or l_is_delivery_required = 'N' Then
              fnd_file.put_line(FND_FILE.OUTPUT,'Show SO not enabled for TP: ' || p_customer_id);
              If l_debug_level  > 0 THEN
               oe_debug_pub.add(  'CONC PGM NOT RAISING SSO EVENT FOR TP: '|| p_customer_id);
              End If;
           Else

             OE_ACKNOWLEDGMENT_PUB.Raise_Event_Showso (
                     p_header_id               => l_order_rec.header_id(i),
                     p_line_id                 => null,
                     p_customer_id             => l_order_rec.sold_to_org_id(i),
                     p_orig_sys_document_ref   => l_order_rec.orig_sys_document_ref(i),
                     p_change_sequence         => l_order_rec.change_sequence(i),
	             p_party_id                => l_party_id,
                     p_party_site_id           => l_party_site_id,
                     p_itemtype                => OE_ORDER_IMPORT_WF.G_WFI_CONC_PGM,
                     p_request_id              => l_request_id,
                     p_org_id                  => l_order_rec.org_id(i),
                     x_return_status           => l_return_status );
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'AFTER OE_ACKNOWLEDGMENT_PUB.RAISE_EVENT_SHOWSO API: RETURN STATUS:'||L_RETURN_STATUS , 2 ) ;
              END IF;

              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 fnd_file.put_line(FND_FILE.OUTPUT,'Not able to raise the event for Document Number : ' || l_order_rec.orig_sys_document_ref(i));
                 fnd_file.put_line(FND_FILE.OUTPUT,'Error : ' || sqlerrm);
                 l_return_status := FND_API.G_RET_STS_SUCCESS;
              ELSE
                 fnd_file.put_line(FND_FILE.OUTPUT,'Successfully raised the event for Document Number : ' ||l_order_rec.orig_sys_document_ref(i));
              END IF;

           End If;
        END LOOP;
     END IF;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'EXITING OE_ACKNOWLEDGMENT_PUB.PROCESS_SSO_CONC_PGM' , 2 ) ;
        END IF;

 -- Exception Handling
EXCEPTION

   WHEN OTHERS THEN
     l_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'WHEN OTHERS - EXITING OE_ACKNOWLEDGMENT_PUB.PROCESS_SSO_CONC_PGM' , 2 ) ;
         oe_debug_pub.add(  'SQLERRM: '||SQLERRM||' SQLCODE:'||SQLCODE ) ;
     END IF;
     IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'process_sso_conc_pgm');
     End if;
End Process_SSO_CONC_PGM;
-- End of the Process_SSO_Conc_Pgm }

Procedure Raise_Event_Xmlint
(p_order_source_id         IN     Number,
 p_partner_document_num    IN     Varchar2,
 p_message_text            IN     Varchar2,
 p_document_num            IN     Number,
 p_order_type_id           IN     Number,
 p_change_sequence         IN     Varchar2,
 p_itemtype                IN     Varchar2,
 p_itemkey                 IN     Number,
 p_transaction_type        IN     Varchar2,
 p_transaction_subtype     IN     Varchar2,
 p_doc_status              IN     Varchar2,
 p_org_id                  IN     Number,
 p_sold_to_org_id          IN     Number,
 p_document_direction      IN     Varchar2,
 p_xmlg_document_id        IN     Number,
 p_xmlg_partner_type       IN     Varchar2,
 p_xmlg_party_id           IN     Number,
 p_xmlg_party_site_id      IN     Number,
 p_xmlg_icn                IN     Number,
 p_xmlg_msgid              IN     Varchar2,
 p_document_disposition    IN     Varchar2,
 p_conc_request_id         IN     Number,
 p_processing_stage        IN     Varchar2,
 p_response_flag           IN     Varchar2,
 p_header_id               IN     Number,
 p_subscriber_list         IN     Varchar2,
 p_line_ids                IN     Varchar2,
 p_failure_ack_flag        IN     Varchar2,
 x_return_status           OUT NOCOPY /* file.sql.39 change */    Varchar2
)

Is

  l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
  l_eventkey              Number;
  l_message_text          VARCHAR2(2000) := p_message_text;
  l_doc_status            VARCHAR2(240)  := p_doc_status;
  l_transaction_subtype   VARCHAR2(30) := p_transaction_subtype;
  l_transaction_type      VARCHAR2(30) := p_transaction_type;
  l_txn_token             Varchar2(50);
  l_processing_stage      VARCHAR2(30) := p_processing_stage;
  l_document_num          NUMBER := p_document_num;
  l_order_type_id         NUMBER := p_order_type_id;
  l_xmlg_icn              NUMBER := p_xmlg_icn;
  l_header_id             NUMBER := p_header_id;
  l_subscriber_list       VARCHAR2(15) := nvl(p_subscriber_list,'ONT');
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
  l_converted             VARCHAR2(100);
  i                       NUMBER;
  l_org_id                NUMBER := p_org_id;
  l_conc_request_id       NUMBER := p_conc_request_id;
  l_response_flag         VARCHAR2(1) := p_response_flag;
  l_integ_profile         VARCHAR2(10) := nvl (FND_PROFILE.VALUE ('ONT_EM_INTEG_SOURCES'), 'XML');
  l_customer_key_profile VARCHAR2(1)  :=  'N';
  l_failure_ack_flag      VARCHAR2(1)  :=  nvl(p_failure_ack_flag, 'N');
  l_order_processed_flag  VARCHAR2(1)  := 'Y';

Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING RAISE_EVENT_XMLINT' ) ;
  END IF;

  -- new profile to control which order sources can raise this event
  IF l_integ_profile = 'XML' THEN
     IF p_order_source_id <> G_XML_ORDER_SOURCE_ID THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LEAVING RAISE_EVENT_XMLINT FOR DISABLED ORDER SOURCE: '|| p_order_source_id ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
     END IF;
  ELSIF l_integ_profile = 'EDIXML' THEN
     IF p_order_source_id NOT IN (G_XML_ORDER_SOURCE_ID, OE_GLOBALS.G_ORDER_SOURCE_EDI)  THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'LEAVING RAISE_EVENT_XMLINT FOR DISABLED ORDER SOURCE: '|| p_order_source_id ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
     END IF;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ADDING PARAMETERS TO XML INTEGRATION EVENT' ) ;
  END IF;

   --generating a unique event key
  SELECT OE_XML_MESSAGE_SEQ_S.nextval
    INTO l_eventkey
    FROM dual;


  -- { begin code release level
  IF OE_Code_Control.Code_Release_Level >= '110510' THEN

  If l_subscriber_list <> 'DEFAULT' THEN

  /* error checking primarily to guard against some OI cases where we
     get G_MISS_VALUES */

     IF FND_API.G_MISS_NUM IN (p_order_source_id, p_sold_to_org_id) THEN
        l_parameter_list.DELETE;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NOT RAISING oracle.apps.ont.oi.xml_int.status without order source or sold to org id' ) ;
           oe_debug_pub.add(  'order source ' || p_order_source_id || ' or sold to org id' || p_sold_to_org_id ) ;
           oe_debug_pub.add(  'EXITING RAISE_EVENT_XMLINT' ) ;
        END IF;
        Return;
     END IF;

     IF l_conc_request_id = FND_API.G_MISS_NUM THEN
        l_conc_request_id := NULL;
        l_converted := l_converted || 'CONC_REQUEST_ID, ';
     END IF;
     IF l_header_id = FND_API.G_MISS_NUM THEN
        l_header_id := NULL;
        l_converted := l_converted || 'HEADER_ID, ';
     END IF;
     IF l_org_id = FND_API.G_MISS_NUM THEN

/*          SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
                NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10))) into l_org_id from DUAL; */
        l_org_id := MO_GLOBAL.Get_Current_Org_Id;   --moac
        l_converted := l_converted || 'ORG_ID, ';
     END IF;

     IF l_xmlg_icn IS NULL THEN
        l_xmlg_icn := l_eventkey; --reuse sequence value (mainly for generic OI)
     END IF;

     IF l_doc_status = FND_API.G_RET_STS_SUCCESS THEN -- calls from Order Import Conc Pgm
        l_doc_status := 'SUCCESS';
        l_processing_stage := 'IMPORT_SUCCESS';
     ELSIF l_doc_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
        l_doc_status := 'ERROR';
        l_processing_stage := 'IMPORT_FAILURE';
     END IF;

     IF l_transaction_subtype IS NULL THEN
        l_transaction_subtype := G_TRANSACTION_GENERIC;
     END IF;

     IF l_message_text IS NULL THEN
        IF l_processing_stage = 'IMPORT_SUCCESS' THEN
           fnd_message.set_name ('ONT', 'OE_OI_IMPORT_SUCCESS_GEN');
        ELSIF l_processing_stage = 'IMPORT_FAILURE' THEN
           fnd_message.set_name ('ONT', 'OE_OI_IMPORT_FAILURE');
        END IF;
        l_txn_token := Oe_Acknowledgment_Pub.EM_Transaction_Type (p_txn_code => l_transaction_subtype);

        If l_txn_token IS NOT NULL Then
           fnd_message.set_token ('TRANSACTION',l_txn_token || ' -');
        Else
           fnd_message.set_token ('TRANSACTION', '');
        End If;
        l_message_text := fnd_message.get;
      END IF;

    END IF;  -- end of branch on subscriber list

  END IF; -- } end code release level
  -----------------------------------------------------------
  -- Non-CLN params
  -----------------------------------------------------------
  IF OE_Code_Control.Code_Release_Level >= '110510' THEN
     IF l_processing_stage = 'IMPORT_FAILURE' THEN
        IF p_order_source_id = 20 AND l_transaction_subtype IN (G_TRANSACTION_CHO, G_TRANSACTION_CPO) THEN
 	   fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
           l_customer_key_profile := nvl(l_customer_key_profile, 'N');

           Begin
            Select order_number, order_type_id, header_id
              Into l_document_num, l_order_type_id, l_header_id
              From oe_order_headers
             Where orig_sys_document_ref = p_partner_document_num
               And order_source_id = 20
               And decode(l_customer_key_profile, 'Y',
	          nvl(sold_to_org_id,                -999), 1)
                  = decode(l_customer_key_profile, 'Y',
                  nvl(p_sold_to_org_id,                -999), 1);

            Exception
              When Others Then
                 IF l_debug_level  > 0 THEN
                    oe_debug_pub.add(  'EXCEPTION WHEN FETCH ORDER NUM' ) ;
                 END IF;

              -- could not derive info
                 l_document_num := NULL;
                 l_order_type_id := NULL;
                 l_header_id     := NULL;
            End;

        ELSE
           l_document_num := NULL;
           l_order_type_id := NULL;
           l_header_id     := NULL;
        END IF;
     END IF;

     -- order source
     wf_event.AddParameterToList(p_name=>          'ORDER_SOURCE_ID',
                                 p_value=>         p_order_source_id,
                                 p_parameterlist=> l_parameter_list);

     -- item_type, item_key under which the inbound/outbound XML is being processed
     wf_event.AddParameterToList(p_name=>          'WF_ITEM_TYPE',
                                 p_value=>         p_itemtype,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'WF_ITEM_KEY',
                                 p_value=>         p_itemkey,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'SOLD_TO_ORG_ID',
                                 p_value=>         p_sold_to_org_id,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'PROCESSING_STAGE',
                                 p_value=>         l_processing_stage,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'CONC_REQUEST_ID',
                                 p_value=>         l_conc_request_id,
                                 p_parameterlist=> l_parameter_list);

     IF p_order_source_id <> G_XML_ORDER_SOURCE_ID THEN
        l_response_flag := NULL;
     END IF;
     wf_event.AddParameterToList(p_name=>          'RESPONSE_FLAG',
                                 p_value=>         l_response_flag,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'HEADER_ID',
                                 p_value=>         l_header_id,
                                 p_parameterlist=> l_parameter_list);

  END IF;
  -----------------------------------------------------------------
  -- CLN Params
  -----------------------------------------------------------------
  -----------------------------------------------------------------
  -- START CLN KEY PARAMS
  -----------------------------------------------------------------

  If ((l_transaction_subtype = Oe_Acknowledgment_Pub.G_TRANSACTION_POI) OR
      (l_transaction_subtype = Oe_Acknowledgment_Pub.G_TRANSACTION_CPO) OR
      (l_transaction_subtype = Oe_Acknowledgment_Pub.G_TRANSACTION_CHO) OR
      (l_transaction_subtype = Oe_Acknowledgment_Pub.G_TRANSACTION_850) OR
      (l_transaction_subtype = Oe_Acknowledgment_Pub.G_TRANSACTION_860) OR
      (l_transaction_subtype = Oe_Acknowledgment_Pub.G_TRANSACTION_GENERIC)) Then

/*      l_internal_control_number := wf_engine.GetItemAttrNumber( p_itemtype
	                					, p_itemkey
                                                                , 'PARAMETER5'
                                                              );*/

     wf_event.AddParameterToList(p_name=>          'XMLG_INTERNAL_CONTROL_NUMBER',
                                 p_value=>        l_xmlg_icn,
                                 p_parameterlist=> l_parameter_list);


    -- start bug 4179657
    IF l_processing_stage <> 'IMPORT_SUCCESS' THEN
        l_order_processed_flag := 'N';
    END IF;
    -- end bug 4179657

  Else
     -- Outbound Transactions
/*     l_xml_message_id := wf_engine.GetItemAttrText( p_itemtype
	       			        	  , p_itemkey
                                                  , 'ECX_MSGID_ATTR'
                                                  , TRUE
                                                  );*/
     wf_event.AddParameterToList(p_name=>          'XMLG_MESSAGE_ID',
                              p_value=>         p_xmlg_msgid,
                              p_parameterlist=> l_parameter_list);

    -- If the xml message id exists, then the document was successfully
    -- sent. However, if we are raising the event prior to document_send
    -- then we need to populate the alternate CLN key
    -- of these we populate the XMLG_INTERNAL_TXN_TYPE/SUBTYPE always (as it
    -- is part of the key for the history table),
    -- the other parameters are added in this code block
    IF OE_Code_Control.Code_Release_Level >= '110510' THEN
     wf_event.AddParameterToList(p_name=>          'DOCUMENT_DIRECTION',
                                 p_value=>         p_document_direction,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'XMLG_DOCUMENT_ID',
                                 p_value=>         p_xmlg_document_id,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'TRADING_PARTNER_TYPE',
                                 p_value=>         p_xmlg_partner_type,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'TRADING_PARTNER_ID',
                                 p_value=>         p_xmlg_party_id,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'TRADING_PARTNER_SITE',
                                 p_value=>         p_xmlg_party_site_id,
                                 p_parameterlist=> l_parameter_list);

    -- start bug 4179657
     -- if this flag is N, then  it means that the ack
     -- is being sent for a failure case, so the subscription
     -- needs to ignore the order number, header_id and order_type_id
     IF l_failure_ack_flag = 'Y' THEN
        l_order_processed_flag := 'N';
     END IF;
     -- end bug 4179657

   END IF;
  End if;
  -----------------------------------------------------------
  -- START CLN OPTIONAL PARAMS
  -----------------------------------------------------------
  --adding partner document number

  wf_event.AddParameterToList(p_name=>          'PARTNER_DOCUMENT_NO',
                              p_value=>         p_partner_document_num,
                              p_parameterlist=> l_parameter_list);
  --adding document number

  wf_event.AddParameterToList(p_name=>          'DOCUMENT_NO',
                                 p_value=>         l_document_num,
                                 p_parameterlist=> l_parameter_list);

   --adding message text

  wf_event.AddParameterToList(p_name=>          'MESSAGE_TEXT',
                                 p_value=>         l_message_text,
                                 p_parameterlist=> l_parameter_list);

  IF OE_Code_Control.Code_Release_Level >= '110510' THEN
    --transaction type
     IF l_transaction_subtype = G_TRANSACTION_CBODO THEN
        l_transaction_type := 'ECX';
        -- begin bug 4179657
        l_order_processed_flag := 'N';
        -- end bug 4179657
     END IF;

     wf_event.AddParameterToList(p_name=>          'XMLG_INTERNAL_TXN_TYPE',
                                 p_value=>         l_transaction_type,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'XMLG_INTERNAL_TXN_SUBTYPE',
                                 p_value=>         l_transaction_subtype,
                                 p_parameterlist=> l_parameter_list);

     -- these changes for CLN, per bug 3103495

     -- We will use the OM_STATUS parameter to report ACTIVE SUCCESS ERROR statuses
     -- Since CLN does not support ACTIVE, we will change that value to SUCCESS for
     -- CLN's DOC_STATUS
     wf_event.AddParameterToList(p_name=>          'ONT_DOC_STATUS',
                                 p_value=>         l_doc_status,
                                 p_parameterlist=> l_parameter_list);


     IF l_doc_status = 'ACTIVE' THEN
        l_doc_status := 'SUCCESS';
     END IF;

     wf_event.AddParameterToList(p_name=>          'DOCUMENT_STATUS',
                                 p_value=>         l_doc_status,
                                 p_parameterlist=> l_parameter_list);

     -- We also need to publish a subscriber list
     -- condition modified for bug 3433024
     IF p_order_source_id = OE_Acknowledgment_Pub.G_XML_ORDER_SOURCE_ID
        AND l_subscriber_list <> 'DEFAULT'
        AND l_processing_stage NOT IN ('OUTBOUND_TRIGGERED', 'OUTBOUND_SETUP') THEN
        l_subscriber_list := l_subscriber_list || ',CLN';
     END IF;
     wf_event.AddParameterToList(p_name=>          'SUBSCRIBER_LIST',
                                 p_value=>         l_subscriber_list,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'DOCUMENT_REVISION_NO',
                                 p_value=>         p_change_sequence,
                                 p_parameterlist=> l_parameter_list);

     wf_event.AddParameterToList(p_name=>          'ORG_ID',
                                 p_value=>         l_org_id,
                                 p_parameterlist=> l_parameter_list);


     wf_event.AddParameterToList(p_name=>          'ORDER_TYPE_ID',
                                 p_value=>         l_order_type_id,
                                 p_parameterlist=> l_parameter_list);

     If l_subscriber_list = 'DEFAULT' THEN
     wf_event.AddParameterToList(p_name=>          'LINE_IDS',
                                 p_value=>         p_line_ids,
                                 p_parameterlist=> l_parameter_list);
     Else
        -- begin bug 4179657
        wf_event.AddParameterToList(p_name=>          'ORDER_PROCESSED_FLAG',
                                    p_value=>         l_order_processed_flag,
                                    p_parameterlist=> l_parameter_list);
        -- end bug 4179657
     End If;

  END IF;


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'FINISHED ADDING PARAMETERS TO INTEGRATION EVENT' ) ;
      FOR i in 1..l_parameter_list.count LOOP
          oe_debug_pub.add ('     ' || l_parameter_list(i).name || ' : '  || l_parameter_list(i).value);
      END LOOP;
      oe_debug_pub.add(  'FINISHED PRINTING EVENT PARAMS' ) ;
      oe_debug_pub.add(  'CONVERTED LIST ' || l_converted ) ;
      oe_debug_pub.add(  'BEFORE RAISE EVENT oracle.apps.ont.oi.xml_int.status' ) ;
  END IF;

  IF OE_Code_Control.Code_Release_Level < '110510' THEN
     IF p_order_source_id <> G_XML_ORDER_SOURCE_ID OR
        l_processing_stage NOT IN ('IMPORT_SUCCESS', 'OUTBOUND_SENT') OR
        l_transaction_subtype = G_TRANSACTION_CBODO THEN
        l_parameter_list.DELETE;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'NOT RAISING oracle.apps.ont.oi.xml_int.status for this pre-110510 case' ) ;
           oe_debug_pub.add(  'EXITING RAISE_EVENT_XMLINT' ) ;
        END IF;
        Return;  -- thus we guarantee that old behaviour is preserved
     END IF;
  END IF;

  wf_event.raise( p_event_name => 'oracle.apps.ont.oi.xml_int.status',
                  p_event_key =>  l_eventkey,
                  p_parameters => l_parameter_list);


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'AFTER RAISE EVENT oracle.apps.ont.oi.xml_int.status' ) ;
      oe_debug_pub.add(  'EXITING RAISE_EVENT_XMLINT' ) ;
  END IF;


  l_parameter_list.DELETE;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  When Others Then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg (   G_PKG_NAME, 'Raise_Event_Xmlint');
    END IF;
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'WHEN OTHERS EXCEPTION IN RAISE_EVENT_XMLINT_WF' ) ;
    END IF;
End Raise_Event_Xmlint;
--End of Procedure to raise XML Integration (CLN) Event


/*----------------------------------------------------------------------
Applies 3A7 change notification hold based on the hold id passed. Uses
standard Hold APIs.
----------------------------------------------------------------------*/
Procedure Apply_3A7_Hold
(  p_header_id       IN   NUMBER
,  p_line_id         IN   NUMBER
,  p_sold_to_org_id  IN   NUMBER
,  p_tp_check        IN   VARCHAR2
,  x_return_status   OUT  NOCOPY VARCHAR2
)
IS
l_tp_check        VARCHAR2(1) := nvl(p_tp_check, FND_API.G_TRUE);
l_msg_count       NUMBER := 0;
l_msg_data        VARCHAR2(2000);
l_return_status   VARCHAR2(30) := fnd_api.g_ret_sts_success;
l_hold_result     VARCHAR2(30);
l_hold_source_rec   OE_Holds_PVT.Hold_Source_REC_type;
l_is_delivery_required_cso   VARCHAR2(1) := 'N';
l_hold_id           NUMBER := 56;
l_party_id         NUMBER;
l_party_site_id    NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Entering Apply_3A7_Hold' ) ;
   END IF;

   IF l_tp_check = FND_API.G_TRUE THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Before Calling  OE_Acknowledgment_PUB.Is_Delivery_Required') ;
      END IF;

      Is_Delivery_Required
                          ( p_customer_id          => p_sold_to_org_id,
                            p_transaction_type     => 'ONT',
                            p_transaction_subtype  => G_TRANSACTION_CSO,
                            x_party_id             => l_party_id,
                            x_party_site_id        => l_party_site_id,
                            x_is_delivery_required => l_is_delivery_required_cso,
                            x_return_status        => l_return_status
                          );

      IF l_debug_level  > 0 THEN
         oe_debug_pub.add( 'After Calling  OE_Acknowledgment_PUB.Is_Delivery_Required: is delivery required for 3a7 = ' || l_is_delivery_required_cso||': Return Status:'||l_return_status ) ;
      END IF;
      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
         IF l_is_delivery_required_cso = 'Y' THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('3A7 enabled transaction. Hold should be applied');
            END IF;
         ELSE
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add('NOT 3A7 enabled transaction. Hold should NOT be applied');
            END IF;
            RETURN;
         END IF;
      END IF;
   ELSE
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Not performing TP check for 3A7') ;
      END IF;
   END IF;

   -- Check if Hold already exists on this order line
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Check If Hold Already Applied' ) ;
   END IF;

   OE_HOLDS_PUB.Check_Holds
                ( p_api_version    => 1.0
                , p_header_id      => p_header_id
                , p_line_id        => p_line_id
                , p_hold_id        => l_hold_id
                , p_entity_code    => 'O'
                , p_entity_id      => p_header_id
                , x_result_out     => l_hold_result
                , x_msg_count      => l_msg_count
                , x_msg_data       => l_msg_data
                , x_return_status  => l_return_status
                );

   -- Return with Success if this Hold Already exists on the order line
   IF l_hold_result = FND_API.G_TRUE THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' Hold Already Applied On Header Id:' || P_HEADER_ID||': Line_Id:'||p_line_id) ;
      END IF;
      RETURN ;
   END IF ;

   -- Apply 3A7 Change Notification Hold on Order line
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Applying  3A7 Change Notification Hold on LINE ID:' || P_LINE_ID) ;
   END IF;

   l_hold_source_rec.hold_id         := l_hold_id ;  -- 3A7 Hold
   l_hold_source_rec.hold_entity_code:= 'O';         -- Order Hold
   l_hold_source_rec.hold_entity_id  := p_header_id; -- Order Header
   l_hold_source_rec.header_id  := p_header_id; -- Order Header
   l_hold_source_rec.line_id  := p_line_id; -- Order line
   OE_Holds_PUB.Apply_Holds
                  (   p_api_version       =>      1.0
                  ,   p_validation_level  =>      FND_API.G_VALID_LEVEL_NONE
                  ,   p_hold_source_rec   =>      l_hold_source_rec
                  ,   x_msg_count         =>      l_msg_count
                  ,   x_msg_data          =>      l_msg_data
                  ,   x_return_status     =>      l_return_status
                  );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Applied 3a7 Hold On Header Id:' || P_HEADER_ID||':Line_Id:'||p_line_id , 3 ) ;
   END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In G_EXC_ERROR exception - Apply_3A7_hold');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In G_EXC_UNEXPECTED_ERROR exception - Apply_3A7_hold');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In when others exception - Apply_3A7_hold');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Apply_3A7_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Apply_3A7_Hold;

/*----------------------------------------------------------------------
Releases 3A7 change notification hold on the order. Uses standard Hold APIs.
----------------------------------------------------------------------*/
Procedure Release_3A7_Hold
(  p_header_id       IN   NUMBER
,  p_line_id         IN   NUMBER
,  x_return_status   OUT  NOCOPY VARCHAR2
)
IS
l_hold_id           NUMBER := 56;
l_hold_exists       VARCHAR2(1);
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(30) := fnd_api.g_ret_sts_success;
l_release_reason    VARCHAR2(30);
l_hold_source_rec   OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_hold_result       VARCHAR2(30);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'In Release_3A7_Hold' , 3 ) ;
   END IF;

   -- Checking Existence Of 3A7 Hold
   OE_HOLDS_PUB.Check_Holds
                ( p_api_version    => 1.0
                , p_header_id      => p_header_id
                , p_line_id     => p_line_id
                , p_hold_id        => l_hold_id
                , p_entity_code    => 'O'
                , p_entity_id      => p_header_id
                , x_result_out     => l_hold_result
                , x_msg_count      => l_msg_count
                , x_msg_data       => l_msg_data
                , x_return_status  => l_return_status
                );

   -- Return with Success if this Hold exists on the order line
   IF l_hold_result = FND_API.G_TRUE THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  ' Hold Exists On Header Id:' || P_HEADER_ID||': Line_Id:'||p_line_id) ;
      END IF;
      l_hold_exists := 'Y';
   END IF ;

   IF l_hold_exists = 'Y' THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add('Releasing 3a7 Hold On Order Header Id:' || p_header_ID ||':Line_Id:'||p_line_id, 3 ) ;
      END IF;
      l_hold_source_rec.hold_id          := l_hold_id;
      l_hold_source_rec.HOLD_ENTITY_CODE := 'O';
      l_hold_source_rec.HOLD_ENTITY_ID   := p_header_id; -- Order Header
      l_hold_source_rec.header_id  := p_header_id; -- Order Header
      l_hold_source_rec.line_id  := p_line_id; -- Order line
      l_hold_release_rec.release_reason_code := '3A7_RESPONSE_RECEIVED';

      OE_Holds_PUB.Release_Holds
                (   p_api_version       =>   1.0
                ,   p_hold_source_rec   =>   l_hold_source_rec
                ,   p_hold_release_rec  =>   l_hold_release_rec
                ,   x_msg_count         =>   l_msg_count
                ,   x_msg_data          =>   l_msg_data
                ,   x_return_status     =>   l_return_status
                );

      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Released 3a7 Hold On Header Id:' || P_HEADER_ID ||':Line_Id:'||p_line_id, 3 ) ;
      END IF;

   END IF; -- hold exists
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting Release_3A7 Hold', 3 ) ;
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In G_EXC_ ERROR exception - Release_3A7_hold');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In G_EXC_UNEXPECTED_ERROR exception - Release_3A7_hold');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In when others exception - Release_3A7_hold');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Release_3A7_Hold'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Release_3A7_Hold;

/*----------------------------------------------------------------------
Processes 3A8 transaction received. This will be called during process order call
----------------------------------------------------------------------*/
Procedure Process_3A8
(  p_x_line_rec              IN OUT NOCOPY OE_Order_PUB.Line_Rec_Type
,  p_old_line_rec      IN    OE_Order_PUB.Line_Rec_Type
,  x_return_status   OUT  NOCOPY VARCHAR2
)
IS
l_msg_count         NUMBER := 0;
l_msg_data          VARCHAR2(2000);
l_return_status     VARCHAR2(30) := fnd_api.g_ret_sts_success;
l_release_3a7_hold_flag VARCHAR2(1) := 'N';
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'In OE_Acknowledgment_Pub.Process_3A8' , 3 ) ;
   END IF;

  /* 1) If independent 3A8 then release the hold.
     2) If response 3A8 then
        a)  Release the hold if columns match or qty is zero.
	b) Otherwise, raise an error. */

   IF NVL(p_x_line_rec.cso_response_flag, 'N') = 'N' then -- independent 3A8
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Independent 3A8/3A9 received, releasing hold', 3 ) ;
      END IF;
      l_release_3a7_hold_flag :='Y';
   ELSE -- it is 3A8 response
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('3A8 response attrs');
         oe_debug_pub.add('Old qty: ' || p_old_line_rec.ordered_quantity || ' New qty:' || p_x_line_rec.ordered_quantity);
         oe_debug_pub.add('Old UOM: ' || p_old_line_rec.order_quantity_uom || ' New UOM:' || p_x_line_rec.order_quantity_uom);
         oe_debug_pub.add('Old ssdt: ' || p_old_line_rec.schedule_ship_date || ' New ssdt:' || p_x_line_rec.schedule_ship_date);
         oe_debug_pub.add('Old usp: ' || p_old_line_rec.unit_selling_price || ' New cinp:' || p_x_line_rec.customer_item_net_price);
      END IF;
      IF (p_x_line_rec.ordered_quantity = 0) OR
         (p_x_line_rec.ordered_quantity = p_old_line_rec.ordered_quantity AND
          p_x_line_rec.order_quantity_uom= p_old_line_rec.order_quantity_uom AND
          p_x_line_rec.schedule_ship_date= p_old_line_rec.schedule_ship_date AND
--          p_x_line_rec.unit_selling_price= p_old_line_rec.unit_selling_price) THEN
          nvl(p_x_line_rec.customer_item_net_price, p_x_line_rec.unit_selling_price) = p_old_line_rec.unit_selling_price) THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  '3A8 response received, columns matching or zero quantity- releasing hold. ordered_quantity:' || p_x_line_rec.ordered_quantity, 3 ) ;

          END IF;
          l_release_3a7_hold_flag :='Y';
      ELSE -- columns does not match and quantity <> 0
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  '3A8 response received,  columns does not match and qty <> 0, Raise an error', 3 ) ;
          END IF;
          FND_MESSAGE.SET_NAME('ONT', 'ONT_3A8_RESPONSE_COL_MISMATCH');
          OE_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF; -- check for columns
   END IF; -- check for independent/response 3A8

   IF l_release_3a7_hold_flag = 'Y' THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'Releasing hold');
      END IF;
      Release_3A7_Hold
               (  p_header_id         => p_x_line_rec.header_id
               ,  p_line_id              => p_x_line_rec.line_id
               ,  x_return_status   => l_return_status
               );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Exiting Process_3A8', 3 ) ;
   END IF;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In G_EXC_ ERROR exception - Process_3A8');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In G_EXC_UNEXPECTED_ERROR exception - Process_3A8');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

    WHEN OTHERS THEN
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add('In when others exception - Process_3A8');
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_3A8'
            );
      END IF;

      OE_MSG_PUB.Count_And_Get
            ( p_count => l_msg_count,
              p_data  => l_msg_data
            );

END Process_3A8;


/*----------------------------------------------------------------------
Helper procedure to get the message token for a particular txn type
----------------------------------------------------------------------*/
FUNCTION EM_Transaction_Type
(   p_txn_code                 IN  VARCHAR2
) RETURN VARCHAR2
IS
  l_transaction_type            VARCHAR2(80);
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

    IF  p_txn_code IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  MEANING
    INTO    l_transaction_type
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_txn_code
    AND     LOOKUP_TYPE = 'ONT_ELECMSGS_TYPES';

    RETURN l_transaction_type;

EXCEPTION
    WHEN OTHERS THEN
	RETURN NULL;

End EM_Transaction_Type;

Procedure Raise_CBOD_Out_Event
( p_orig_sys_document_ref IN   Varchar2,
  p_sold_to_org_id        IN   Number,
  p_change_sequence       IN   Varchar2,
  p_icn                   IN   Number,
  p_org_id                IN   Number,
  p_transaction_type      IN   Varchar2,
  p_confirmation_flag     IN   Varchar2,
  p_cbod_message_text     IN   Varchar2,
  x_return_status         OUT NOCOPY VARCHAR2)
IS
l_user_key VARCHAR2(240);
l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
l_eventkey              Number;
BEGIN

  l_user_key := p_orig_sys_document_ref || ',' || to_char(p_sold_to_org_id) || ',' || p_change_sequence || ',' || p_transaction_type;

  If p_confirmation_flag = '2' Then
     wf_event.AddParameterToList(p_name=>          'ORIG_SYS_DOCUMENT_REF',
                                 p_value=>         p_orig_sys_document_ref,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'PARAMETER4',
                                 p_value=>         p_sold_to_org_id,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'PARAMETER5',
                                 p_value=>         p_icn,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'PARAMETER6',
                                 p_value=>         p_cbod_message_text,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'USER_KEY',
                                 p_value=>         l_user_key,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'ORG_ID',
                                 p_value=>         p_org_id,
                                 p_parameterlist=> l_parameter_list);
     wf_event.AddParameterToList(p_name=>          'PARAMETER7',
                                 p_value=>         p_change_sequence,
                                 p_parameterlist=> l_parameter_list);

     SELECT OE_XML_MESSAGE_SEQ_S.nextval
       INTO l_eventkey
       FROM dual;

     wf_event.raise( p_event_name => 'oracle.apps.ont.oi.cbod_out.confirm',
                     p_event_key =>  l_eventkey,
                     p_parameters => l_parameter_list);

     x_return_status := FND_API.G_RET_STS_SUCCESS;
  Else
     x_return_status := FND_API.G_RET_STS_ERROR;
  End If;

  l_parameter_list.DELETE;

Exception
  When Others Then
    l_parameter_list.DELETE;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Raise_CBOD_Out_Event;

-- Procedure added for bug 9685021

Procedure  is_line_exists(p_line_id IN NUMBER,x_exists_flag OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
temp VARCHAR2(1);
BEGIN
SELECT 'X' INTO temp FROM oe_order_lines_all WHERE line_id=p_line_id;
x_exists_flag :='Y';
COMMIT;
EXCEPTION
WHEN OTHERS THEN
       x_exists_flag :='N';
       COMMIT;
END;


END OE_Acknowledgment_Pub;

/
