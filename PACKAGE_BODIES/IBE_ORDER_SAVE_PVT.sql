--------------------------------------------------------
--  DDL for Package Body IBE_ORDER_SAVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_ORDER_SAVE_PVT" AS
/* $Header: IBEVORDB.pls 120.5.12010000.9 2018/04/04 16:35:45 ytian ship $ */

 G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_Order_Save_pvt';
 l_true VARCHAR2(1)                := FND_API.G_TRUE;


PROCEDURE Get_Order_Status(p_header_id IN NUMBER
                           ,x_order_status OUT NOCOPY VARCHAR2
                           ,x_last_update_date OUT NOCOPY DATE)

IS
  CURSOR c_gethdrstatus(p_header_id NUMBER) IS
    SELECT flow_status_code,last_update_date FROM oe_order_headers_all WHERE header_id = p_header_id;


  l_gethdrstatus  c_gethdrstatus%rowtype;
  lx_order_status VARCHAR2(30) := FND_API.G_MISS_CHAR;


BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('Begin IBE_ORDER_SAVE_PVT:Get_Order_Status');
END IF;

  OPEN c_gethdrstatus(p_header_id);
  FETCH c_gethdrstatus INTO l_gethdrstatus;
  IF (c_gethdrstatus%NOTFOUND) THEN
    x_order_status:= FND_API.G_MISS_CHAR;
    x_last_update_date  := null;
  ELSE
    x_order_status := l_gethdrstatus.flow_status_code;
    x_last_update_date  := l_gethdrstatus.last_update_date;
  END IF;
  CLOSE c_gethdrstatus;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('End IBE_ORDER_SAVE_PVT:Get_Order_Status');
END IF;

END Get_Order_Status;


PROCEDURE Retrieve_OE_Messages IS
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);
  x_msg_data  VARCHAR2(2000);

  l_len_sqlerrm NUMBER;
  i             NUMBER := 1;

  l_error_index_flag            VARCHAR2(1)  := 'N';
  l_msg_index                   NUMBER := 0;
  l_msg_context                 VARCHAR2(2000);
  l_msg_entity_code             VARCHAR2(30);
  l_msg_entity_ref              VARCHAR2(50);
  l_msg_entity_id               NUMBER;
  l_msg_header_id               NUMBER;
  l_msg_line_id                 NUMBER;
  l_msg_order_source_id         NUMBER;
  l_msg_orig_sys_document_ref   VARCHAR2(50);
  l_msg_change_sequence         VARCHAR2(50);
  l_msg_orig_sys_line_ref       VARCHAR2(50);
  l_msg_orig_sys_shipment_ref   VARCHAR2(50);
  l_msg_source_document_type_id NUMBER;
  l_msg_source_document_id      NUMBER;
  l_msg_source_document_line_id NUMBER;
  l_msg_attribute_code          VARCHAR2(50);
  l_msg_constraint_id           NUMBER;
  l_msg_process_activity        NUMBER;
  l_msg_notification_flag       VARCHAR2(1);
  l_msg_type                    VARCHAR2(30);

 BEGIN
/*
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('Begin IBE_ORDER_SAVE_PVT:Retrieve_OE_Messages');
END IF;
*/
     OE_MSG_PUB.Count_And_Get
        ( p_count         =>      l_msg_count,
          p_data          =>      l_msg_data
         );

     IF l_msg_count > 0 THEN
      FOR k IN 1 .. l_msg_count LOOP
        i:=1;
        oe_msg_pub.get (
           p_msg_index     => k
          ,p_encoded       => FND_API.G_FALSE
          ,p_data          => l_msg_data
          ,p_msg_index_out => l_msg_index);

       IF (upper(l_msg_data) <> 'ORDER HAS BEEN BOOKED.') THEN  -- bug# 1935468
       BEGIN
           oe_msg_pub.get_msg_context (
           p_msg_index                    => l_msg_index
          ,x_entity_code                  => l_msg_entity_code
          ,x_entity_ref                   => l_msg_entity_ref
          ,x_entity_id                    => l_msg_entity_id
          ,x_header_id                    => l_msg_header_id
          ,x_line_id                      => l_msg_line_id
          ,x_order_source_id              => l_msg_order_source_id
          ,x_orig_sys_document_ref        => l_msg_orig_sys_document_ref
          ,x_orig_sys_line_ref            => l_msg_orig_sys_line_ref
          ,x_orig_sys_shipment_ref        => l_msg_orig_sys_shipment_ref
          ,x_change_sequence              => l_msg_change_sequence
          ,x_source_document_type_id      => l_msg_source_document_type_id
          ,x_source_document_id           => l_msg_source_document_id
          ,x_source_document_line_id      => l_msg_source_document_line_id
          ,x_attribute_code               => l_msg_attribute_code
          ,x_constraint_id                => l_msg_constraint_id
          ,x_process_activity             => l_msg_process_activity
          ,x_notification_flag            => l_msg_notification_flag
          ,x_type                         => l_msg_type
          );

        EXCEPTION
        WHEN others THEN
            l_error_index_flag := 'Y';
        END;

        IF l_error_index_flag = 'Y' THEN
           EXIT;
        END IF;

        IF oe_msg_pub.g_msg_tbl(l_msg_index).message_text IS NULL THEN
          x_msg_data := oe_msg_pub.get(l_msg_index, 'F');
        END IF;

        IF l_msg_orig_sys_line_ref IS NOT NULL AND l_msg_orig_sys_line_ref <> FND_API.G_MISS_CHAR THEN
          l_msg_context := 'Error in Line: '||rtrim(l_msg_orig_sys_line_ref)||' :';



        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_orig_sys_line_ref: '||rtrim(l_msg_orig_sys_line_ref)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_line_id: '||rtrim(l_msg_line_id)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_header_id: '||rtrim(l_msg_header_id)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_entity_code: '||rtrim(l_msg_entity_code)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_entity_ref: '||rtrim(l_msg_entity_ref)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_orig_sys_document_ref: '||rtrim(l_msg_orig_sys_document_ref)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_orig_sys_line_ref: '||rtrim(l_msg_orig_sys_line_ref)||'END');
Ibe_Util.debug('BUG26561470Retrieve_OE_Messages - l_msg_attribute_code: '||rtrim(l_msg_attribute_code)||'END');

        END IF;


        END IF;

        -- x_msg_data := l_msg_context||l_msg_data;
            x_msg_data := l_msg_data;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_Util.debug('Retrieve_OE_Messages - x_msg_data: '||x_msg_data);
        END IF;

        l_len_sqlerrm := Length(x_msg_data) ;
        WHILE l_len_sqlerrm >= i
        LOOP
          FND_MESSAGE.Set_Name('IBE', 'IBE_OM_ERROR');
          FND_MESSAGE.Set_token('MSG_TXT' , substr(x_msg_data,i,240));
          i := i + 240;
          FND_MSG_PUB.ADD;
        END LOOP;

       END IF;
     END LOOP;
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_Util.debug('End IBE_ORDER_SAVE_PVT:Retrieve_OE_Messages');
   END IF;

END Retrieve_OE_Messages;

PROCEDURE DeactivateOrder(p_party_id        IN NUMBER
                         ,p_cust_account_id IN NUMBER
                         ,p_currency_code   IN VARCHAR2
                         )

IS

BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('Begin IBE_ORDER_SAVE_PVT:Deactivate Order: ' || p_party_id || ' : '||p_cust_account_id);
END IF;


 IBE_ACTIVE_QUOTES_ALL_PKG.Update_row(
                       X_OBJECT_VERSION_NUMBER => 1,
                       X_ORDER_HEADER_ID       => null ,
                       X_PARTY_ID              => p_party_id,
                       X_CUST_ACCOUNT_ID       => p_cust_account_id,
                       X_CURRENCY_CODE         => p_currency_code,
                       X_LAST_UPDATE_DATE      => sysdate,
                       X_LAST_UPDATED_BY       => fnd_global.user_id,
                       X_LAST_UPDATE_LOGIN     => 1,
                       X_RECORD_TYPE           => 'ORDER');


IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('End IBE_ORDER_SAVE_PVT:DeactivateOrder');
END IF;

END DeactivateOrder;

PROCEDURE ActivateOrder(p_order_header_id  IN NUMBER
                         ,p_party_id        IN NUMBER
                         ,p_cust_account_id IN NUMBER
                         ,p_currency_code   IN VARCHAR2
                        )
IS

  l_pend_ret_id        NUMBER        := null;   --active pending return present in active carts table or not
  l_pr_party_id        NUMBER        := null;

  cursor c_check_pr_aqa(c_party_id number,
                        c_cust_account_id number,
                        c_currency_code varchar2
                       ) is
   select aq.order_header_id,aq.party_id
   from ibe_active_quotes aq
   where cust_account_id = c_cust_account_id
   and party_id          = c_party_id
   and currency_code     = c_currency_code
   and record_type       = 'ORDER';

 rec_check_pr_aqa          c_check_pr_aqa%rowtype;


BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('Begin IBE_ORDER_SAVE_PVT:ActivateOrder');
END IF;

  open c_check_pr_aqa( p_party_id,p_cust_account_id,p_currency_code);
  fetch c_check_pr_aqa into rec_check_pr_aqa;
  if (c_check_pr_aqa%notfound) then

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_Util.debug('Pending Return Not Exists');
       END IF;
       IBE_ACTIVE_QUOTES_ALL_PKG.Insert_row(
                X_OBJECT_VERSION_NUMBER  => 1,
                X_ORDER_HEADER_ID        => p_order_header_id,
                X_PARTY_ID               => p_party_id,
                X_CUST_ACCOUNT_ID        => p_cust_account_id,
                X_LAST_UPDATE_DATE       => sysdate,
                X_CREATION_DATE          => sysdate,
                X_CREATED_BY             => fnd_global.USER_ID,
                X_LAST_UPDATED_BY        => fnd_global.USER_ID,
                X_LAST_UPDATE_LOGIN      => fnd_global.conc_login_id,
                X_CURRENCY_CODE          => p_currency_code,
                X_RECORD_TYPE            => 'ORDER',
                X_ORG_ID                 => mo_global.GET_CURRENT_ORG_ID());


  else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_Util.debug('Pending Return Already Exists');
    END IF;

    IBE_ACTIVE_QUOTES_ALL_PKG.update_row(
                  X_OBJECT_VERSION_NUMBER  => 1,
                  X_LAST_UPDATE_DATE       => sysdate,
                  X_LAST_UPDATED_BY        => fnd_global.user_id,
                  X_LAST_UPDATE_LOGIN      => 1,
                  X_PARTY_ID               => p_party_id,
                  X_CUST_ACCOUNT_ID        => p_cust_account_id,
                  X_ORDER_HEADER_ID        => p_order_header_id,
                  X_CURRENCY_CODE          => p_currency_code,
                  X_RECORD_TYPE            => 'ORDER');


   END IF;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
 Ibe_Util.debug('End IBE_ORDER_SAVE_PVT:ActivateOrder');
END IF;

END ActivateOrder;

PROCEDURE ValidateLineShipTo(    p_siteuse_type IN  VARCHAR2
                                ,p_site_use_id  IN NUMBER
                                ,x_site_use_id  OUT NOCOPY NUMBER)
IS

l_linesite_use_id NUMBER;
 CURSOR c_get_site_use_id(c_siteuse_type VARCHAR2, c_site_use_id NUMBER)
 IS
 SELECT csu.site_use_id
 FROM hz_cust_site_uses_all csu
 WHERE csu.status = 'A'
 AND site_use_code = c_siteuse_type
 AND csu.site_use_id = c_site_use_id;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.debug('Printing input parameters ::: p_siteuse_type=='|| p_siteuse_type);
       IBE_Util.debug('Printing input parameters ::: p_site_use_id=='|| p_site_use_id);
     end if;

     OPEN c_get_site_use_id(p_siteuse_type,p_site_use_id);
     FETCH c_get_site_use_id into l_linesite_use_id;
     CLOSE c_get_site_use_id;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.debug('site use id from line: '|| l_linesite_use_id);
     end if;
     x_site_use_id := l_linesite_use_id;
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
IBE_Util.debug('Printing output parameter ::: x_site_use_id=='|| x_site_use_id);
    Ibe_Util.debug('End IBE_ORDER_SAVE_PVT:ValidateLineShipTo');
  END IF;
END ValidateLineShipTo;

PROCEDURE DefaultFromLineSiteId(p_line_tbl      IN  OE_Order_PUB.Line_Tbl_Type
                                ,p_party_id     IN  NUMBER
                                ,p_siteuse_type IN  VARCHAR2
                                ,x_site_use_id  OUT NOCOPY NUMBER)
IS

  cursor c_get_line_Info(l_lineId Number) is
    select invoice_to_org_id from oe_order_lines_all where line_id = l_lineId;


 p_line_ids varchar2(3000) := null;
 l_line_id_query varchar2(3000);
 l_tmp_query varchar2(4000);
 l_linesite_use_id NUMBER;
 l_temp_orgid NUMBER;
 l_get_line_Info c_get_line_Info%rowtype;

 Type partysite_type is REF CURSOR;
 psitetype_tmp partysite_type;

 l_parseNum NUMBER :=5;
 l_parseKey varchar2(40) :='ORDER_SAVE_LINE_IDS';

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_Util.debug('Begin IBE_ORDER_SAVE_PVT:DefaultFromLineSiteId');
  END IF;

for lineIdx in 1..p_line_tbl.count
   loop
     IF (p_siteuse_type = 'BILL_TO') THEN
       p_line_ids := p_line_ids || ','|| p_line_tbl(lineIdx).invoice_to_org_id;
    ELSIF (p_siteuse_type = 'SHIP_TO') THEN
       p_line_ids := p_line_ids || ','|| p_line_tbl(lineIdx).ship_to_org_id;
     END IF;
 end loop;


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_util.debug('p_line_ids set: '||p_line_ids);
  end if;

  /** This API is called for parsing the where condition PlSQL Bind Variables Std. **/
  IBE_LEAD_IMPORT_PVT.parseInput (p_line_ids, 'CHAR', l_parseKey,l_parseNum, l_line_id_query);

  l_tmp_query := 'SELECT csu.site_use_id '||
                 'FROM hz_cust_site_uses_all csu '||
                 'WHERE csu.status = ''A'' AND site_use_code = :siteusecode '||
                 'AND csu.site_use_id IN ('||l_line_id_query||')';


     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.debug('qry executed: '|| l_tmp_query);
     end if;
     open psitetype_tmp for l_tmp_query using p_siteuse_type,l_parseKey;
     fetch psitetype_tmp into l_linesite_use_id;
     close psitetype_tmp;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.debug('site use id from line: '|| l_linesite_use_id);
     end if;
     x_site_use_id := l_linesite_use_id;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_Util.debug('End IBE_ORDER_SAVE_PVT:DefaultFromLineSiteId');
  END IF;

END DefaultFromLineSiteId;

PROCEDURE MergeLines(
                p_header_id        IN  Number,
                p_order_line_rec   IN  OE_Order_PUB.Line_Rec_Type,
                x_line_rec         OUT NOCOPY OE_Order_PUB.Line_Rec_Type
               )
IS
       cursor c_get_lineInfo(l_lineid varchar2,l_ordhdrId varchar2,l_rethdrId number) is
       select * from oe_order_lines_all
       where header_id = l_rethdrId
       and return_attribute2 = l_lineid
       and return_attribute1 = l_ordhdrId
       and line_category_code= 'RETURN';

   l_line_rec     c_get_lineInfo%rowType;

BEGIN

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('IBE_ORDER_SAVE_PVT:MergeLines - START');
 END IF;
 open c_get_lineInfo(p_order_line_rec.return_attribute2,
                     p_order_line_rec.return_attribute1,
                     p_header_id
                    );
 Fetch c_get_lineInfo into l_line_rec;

 if (c_get_lineInfo%found) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_Util.Debug('MergeLines Already a record exists.');
       END IF;
       x_line_rec                  := OE_ORDER_PUB.G_MISS_LINE_REC;
       x_line_rec.item_type_code   := p_order_line_rec.item_type_code;
       x_line_rec.ordered_quantity := p_order_line_rec.ordered_quantity + l_line_rec.ordered_quantity;
       x_line_rec.line_id          := l_line_rec.line_id;
       x_line_rec.operation        := OE_Globals.G_OPR_UPDATE;
 else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_Util.Debug('MergeLines else part: No previous record');
    end if;
    x_line_rec           := p_order_line_rec;
    x_line_rec.operation := OE_GLOBALS.G_OPR_CREATE;
 end if;
 close c_get_lineInfo;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('End IBE_ORDER_SAVE_PVT:MergeLines');
 END IF;
END MergeLines;


PROCEDURE DefaultLineTypes(p_header_type_id IN  NUMBER
                           ,x_line_type_id  OUT NOCOPY NUMBER
                           )
IS

cursor c_linetypeinfo(header_typeid number) is
  select default_inbound_line_type_id from oe_transaction_types_all
    where transaction_type_id = header_typeid;

l_linetypeinfo   c_linetypeinfo%rowtype;

BEGIN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('BEgin IBE_ORDER_SAVE_PVT:DefaultLineTypes');
   END IF;
   open c_linetypeInfo(p_header_type_id);
   fetch c_linetypeinfo into l_linetypeinfo;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_util.debug('line type id info' || c_linetypeinfo%rowcount);
   end if;
   x_line_type_id  := l_linetypeinfo.DEFAULT_INBOUND_LINE_TYPE_ID;
   close c_linetypeinfo;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End IBE_ORDER_SAVE_PVT:DefaultLineTypes');
   END IF;

END DefaultLineTypes;


PROCEDURE DefaultLineRecord(
                p_order_line_tbl   IN  OE_Order_PUB.Line_Tbl_Type
               ,p_order_header_rec IN  OE_Order_PUB.Header_Rec_Type
               ,p_save_type        IN  NUMBER := FND_API.G_MISS_NUM
               ,x_order_line_tbl   OUT NOCOPY OE_Order_Pub.Line_Tbl_Type
                )
IS

   CURSOR c_salesrep_info(l_lineid number) IS
     SELECT salesrep_id from OE_ORDER_LINES_ALL WHERE line_id = l_lineid;

   CURSOR c_defaulthdrline_rec(c_ordhdr_typeid number) IS
    select order_type_id from oe_order_headers_all where header_id = c_ordhdr_typeid;

   CURSOR OrigOrderQtyCur(c_origqtyLineId number) IS
    select ordered_quantity
      from oe_order_lines_all
       where line_id= c_origqtyLineId;

   l_tmp_origQty       NUMBER;
   l_salesrep_info_rec c_salesrep_info%rowtype;
   l_order_line_tbl    OE_Order_PUB.Line_Tbl_Type := OE_Order_PUB.G_MISS_LINE_TBL;
   l_linetype_id       NUMBER;
   lx_line_rec         OE_Order_PUB.Line_Rec_Type;
   l_salesrep_id       NUMBER;
   l_orderhdr_typeid   NUMBER;

BEGIN

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('Begin IBE_ORDER_SAVE_PVT: DefaultLineRecord');
 END IF;
 For j IN 1..p_order_line_tbl.COUNT
 Loop
   l_order_line_tbl(j) := p_order_line_tbl(j);
 End Loop;

 -- line_type_id
 -- Here header level value is retrieved because
 -- when a new line is added to the existing return.
 -- Line_Type_id has to be fetched from the Order_type_id already present for the return.
 -- Headerlevel: update Line Level:create
 -- When update operation header may have order type id or may not have.
 -- so chk it and fetch if not present.

   l_orderhdr_typeid := p_order_header_rec.order_type_id;

 IF (l_orderhdr_typeid is null OR l_orderhdr_typeid=FND_API.G_MISS_NUM)
 THEN
   open c_defaulthdrline_rec(p_order_header_rec.header_id);
   fetch c_defaulthdrline_rec into l_orderhdr_typeid;
   close c_defaulthdrline_rec;
 END IF; -- x_orderheader_rec.operation = update

 DefaultLineTypes(p_header_type_id  =>  l_orderhdr_typeid
                 ,x_line_type_id    =>  l_linetype_id);

 IF (IBE_UTIL.G_DEBUGON = l_true) then
   IBE_util.debug('p_save_type: ' || p_save_type);
 end if;

 For i in 1..l_order_line_tbl.COUNT
 LOOP

   IF (p_save_type = SAVE_NORMAL) THEN
     l_order_line_tbl(i).operation := OE_GLOBALS.G_OPR_UPDATE;

   ELSIF (p_save_type = SAVE_ADDITEMS AND p_order_header_rec.ORDER_CATEGORY_CODE = 'RETURN') THEN

     -- salesrep_id
     --  IF (l_order_line_tbl(i).return_attribute2 is not null AND
     --    l_order_line_tbl(i).return_attribute2 <> FND_API.G_MISS_CHAR) THEN
     for l_salesrep_inforec in c_salesrep_info(l_order_line_tbl(i).return_attribute2)
     loop
       l_salesrep_id := l_salesrep_inforec.salesrep_id;
     end loop;
     --    end if;

   IF (p_order_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE) THEN
      MergeLines(p_header_id      => p_order_header_rec.HEADER_ID,
                 p_order_line_rec => l_order_line_tbl(i),
                 x_line_rec       => lx_line_rec);

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.Debug('Save:line_tbl.ordered_quantity' || lx_line_rec.ORDERED_QUANTITY);
       ibe_util.Debug('Save:line_tbl.operation '       || lx_line_rec.operation);
     END IF;
     l_order_line_tbl(i) := lx_line_rec;

     /* The following IF LOOP would be executed when there is already an active pending Return And
        the user is trying to add an item to it. So it will be 'UPDATE' at header level and
        'CREATE' at line level */

     IF (l_order_line_tbl(i).operation = OE_GLOBALS.G_OPR_CREATE) THEN
       l_order_line_tbl(i).line_category_code := 'RETURN';
       l_order_line_tbl(i).return_context     := 'ORDER';
       --Modified for bug 22542852
       --l_order_line_tbl(i).salesrep_id        := l_salesrep_id;
       l_order_line_tbl(i).salesrep_id        := FND_API.G_MISS_NUM;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.Debug('22542852--printing default salesrep-inside defaultLineRecord' || l_order_line_tbl(i).salesrep_id);
     END IF;
       l_order_line_tbl(i).source_document_type_id := 13; --iStore Account

       -- MultiOrder Flow bug# 3272918
       -- If any of the Line Record has '0' qty.
       -- Refer the original OrderedQuantity and create the line w/ the same
       for k in 1..l_order_line_tbl.count
       loop
         if(l_order_line_tbl(i).ORDERED_QUANTITY = 0) Then
           open OrigOrderQtyCur(l_order_line_tbl(i).RETURN_ATTRIBUTE2);
           fetch OrigOrderQtyCur into l_tmp_origQty;
           l_order_line_tbl(i).ORDERED_QUANTITY := l_tmp_origQty;
           close OrigOrderQtyCur;
         end if;
       end loop;

       IF(l_order_line_tbl(i).LINE_TYPE_ID is null OR
           l_order_line_tbl(i).LINE_TYPE_ID = FND_API.G_MISS_NUM)
       THEN
         IF (l_linetype_id is not null AND l_linetype_id <> FND_API.G_MISS_NUM)
         THEN
           l_order_line_tbl(i).line_type_id  := l_linetype_id;
            IF (IBE_UTIL.G_DEBUGON = l_true) then
             ibe_util.debug('line type id..'||l_order_line_tbl(i).line_type_id);
            end if;
         ELSE
           FND_Message.Set_Name('IBE', 'IBE_ERR_OT_LINE_TYPE_ID_MISS');
           FND_Msg_Pub.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       END IF;
     END IF; -- l_order_line_tbl.operation =create
   ELSE -- headerrec.operation.operation ='update'

      /* This flow will be executed when both HEader and Line level are 'CREATE'.
       ie first time creation of a Return */

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.Debug('Inside Line Values Defaulting flow');
      END IF;
      l_order_line_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;
      l_order_line_tbl(i).line_category_code := 'RETURN';
      l_order_line_tbl(i).return_context     := 'ORDER';
      --Modified for bug 22542852
      --l_order_line_tbl(i).salesrep_id        := l_salesrep_id;
      l_order_line_tbl(i).salesrep_id        := FND_API.G_MISS_NUM;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.Debug('22542852--printing default salesrep--inside defaultLineRecord' || l_order_line_tbl(i).salesrep_id);
     END IF;
      l_order_line_tbl(i).source_document_type_id := 13; --iStore Account

      -- MutliOrder Flow bug# 3272918
      -- If any of the Line Record has '0' qty.
      -- Refer the original OrderedQuantity and create the line w/ the same

      for k in 1..l_order_line_tbl.count
      loop
        if(l_order_line_tbl(i).ORDERED_QUANTITY = 0) Then
           open OrigOrderQtyCur(l_order_line_tbl(i).RETURN_ATTRIBUTE2);
           fetch OrigOrderQtyCur into l_tmp_origQty;
           l_order_line_tbl(i).ORDERED_QUANTITY := l_tmp_origQty;
           close OrigOrderQtyCur;
        end if;
      end loop;

      IF(l_order_line_tbl(i).LINE_TYPE_ID is null OR l_order_line_tbl(i).LINE_TYPE_ID = FND_API.G_MISS_NUM)
      THEN
        IF (l_linetype_id is not null AND l_linetype_id <> FND_API.G_MISS_NUM)
        THEN
          l_order_line_tbl(i).line_type_id  := l_linetype_id;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('line type id..'||l_order_line_tbl(i).line_type_id);
          end if;
        ELSE
          FND_Message.Set_Name('IBE', 'IBE_ERR_OT_LINE_TYPE_ID_MISS');
          FND_Msg_Pub.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

    END IF; -- headerrec.operation.operation ='update'

  ELSIF (p_save_type = SAVE_REMOVEITEMS) THEN
      l_order_line_tbl(i).operation := OE_GLOBALS.G_OPR_DELETE;
  END IF;

 End Loop;

 For k in 1..l_order_line_tbl.COUNT
 Loop
   x_order_line_tbl(k) := l_order_line_tbl(k);
 End Loop;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  Ibe_util.Debug('End IBE_ORDER_SAVE_PVT:DefaultLineRecord');
 END IF;

END DefaultLineRecord;


PROCEDURE GetActiveReturnOrder(p_cust_acct_id IN NUMBER
                                ,p_curr_code IN VARCHAR2
                                ,p_party_id  IN NUMBER
                                ,x_order_header_id OUT NOCOPY NUMBER)
IS
  CURSOR c_getactive_pendret(custAcctId number,currencyCode varchar2,partyId number) IS
         SELECT aq.order_header_id FROM ibe_active_quotes aq, oe_order_headers_all oh
         WHERE aq.party_id      = partyId
         AND aq.cust_account_id = custAcctId
         AND aq.currency_code   = currencyCode
         AND aq.record_type     = 'ORDER'
         AND aq.order_header_id = oh.header_id
         AND oh.flow_status_code IN ('ENTERED','WORKING');

 l_active_returnid   NUMBER:= FND_API.G_MISS_NUM;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_util.Debug('Begin IBE_ORDER_SAVE_PVT: GetActiveReturnOrder');
  END IF;

  OPEN c_getactive_pendret(p_cust_acct_id,
                           p_curr_code,
                           p_party_id);

  FETCH c_getactive_pendret INTO l_active_returnid;
  IF (c_getactive_pendret%FOUND) THEN
   x_order_header_id := l_active_returnid;
  ELSE
   x_order_header_id := FND_API.G_MISS_NUM;
  END IF;

  CLOSE c_getactive_pendret;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_util.Debug('End IBE_ORDER_SAVE_PVT: GetActiveReturnOrder');
  END IF;

END GetActiveReturnOrder;


PROCEDURE DefaultHeaderRecord(
                 p_order_header_rec IN  OE_Order_PUB.Header_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC
                ,p_party_id         IN  NUMBER
                ,p_save_type        IN  NUMBER := FND_API.G_MISS_NUM
                ,x_order_header_rec OUT NOCOPY OE_Order_PUB.Header_Rec_Type
                   )
IS

  CURSOR c_defaulthdr_rec(c_ordhdr_id number) IS
    select order_type_id from oe_order_headers_all where header_id = c_ordhdr_id;

  l_order_header_id  NUMBER := FND_API.G_MISS_NUM;
  l_ordertype_id     NUMBER;
  l_salesrep_id      VARCHAR2(360);

  l_salesrep_number  VARCHAR2(360); --MOAC Changes by ASO::Obsoletion of ASO_DEFAULT_PERSON_ID
  l_user_orgid NUMBER;

  l_flow_status_code VARCHAR2(30);
  l_last_update_date DATE;
  l_preApprove_prof  VARCHAR2(10) := 'N';

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_util.Debug('Begin IBE_ORDER_SAVE_PVT: DefaultHeaderRecord');
  END IF;

 x_order_header_rec := p_order_header_rec;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  Ibe_util.Debug('p_save_type: ' || p_save_type ||'::'||x_order_header_rec.header_id);
  Ibe_util.Debug('category_code ' || x_order_header_rec.ORDER_CATEGORY_CODE);
 END IF;


 IF (p_save_type = SAVE_ADDITEMS) THEN
   IF (x_order_header_rec.ORDER_CATEGORY_CODE  is null
         OR x_order_header_rec.ORDER_CATEGORY_CODE = FND_API.G_MISS_CHAR)
   THEN
     FND_Message.Set_Name('IBE', 'IBE_ERR_OT_ORDER_CATG_MISS');
     FND_Msg_Pub.Add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
 END IF;

 /*** Assumptions:

      -- For RemoveLine, SubmitReturn and recalculate HeaderId will be set from JSP
      -- If headerId not set, then atleaset ORDER_CATEGORY_CODE should be set
      -- For AddLines flow, No hdrId is set but ordercategcode is definitely set by Order.java

 ***/

 IF (x_order_header_rec.header_id is not null AND
      x_order_header_rec.header_id <> FND_API.G_MISS_NUM)
 THEN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_util.Debug('Header id is not null, so cheking its status');
   END IF;

   Get_Order_Status(p_header_id        => x_order_header_rec.header_id
                   ,x_order_status     => l_flow_status_code
                   ,x_last_update_date => l_last_update_date);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('last_update_date sent from ui: '||
                        to_char(x_order_header_rec.last_update_date,'dd-mm-yyyy hh:mi:ss'));
     Ibe_util.Debug('last_update_date from db: '||
                        to_char(l_last_update_date,'dd-mm-yyyy hh:mi:ss'));
     Ibe_util.Debug('l_flow_status_code: '||l_flow_status_code);
   END IF;

   IF ((l_flow_status_code = 'BOOKED' OR l_flow_status_code='CLOSED' OR
        l_flow_status_code = 'CANCELLED')
       OR l_last_update_date > x_order_header_rec.last_update_date)
       THEN
        FND_Message.Set_Name('IBE', 'IBE_ERR_OT_REFRESH_RETURN');
        FND_Msg_Pub.Add;
        RAISE FND_API.G_EXC_ERROR;
   ELSE
        x_order_header_rec.operation := OE_Globals.G_OPR_UPDATE;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_util.Debug('Return not booked loop: ' ||x_order_header_rec.operation);
        END IF;
   END IF;

 ELSIF (x_order_header_rec.ORDER_CATEGORY_CODE) = 'RETURN' THEN

   GetActiveReturnOrder(p_cust_acct_id   => x_order_header_rec.sold_to_org_id
                       ,p_curr_code        => x_order_header_rec.transactional_curr_code
                       ,p_party_id         => p_party_id
                       ,x_order_header_id  => l_order_header_id);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('Active pending Return: '||l_order_header_id);
   END IF;

   IF(l_order_header_id is null OR l_order_header_id = FND_API.G_MISS_NUM) THEN

     IF (p_save_type = SAVE_ADDITEMS) THEN

       x_order_header_rec.header_id := l_order_header_id;
       x_order_header_rec.operation := OE_Globals.G_OPR_CREATE;

       /** -- As the flow is for CREATE do set the necessary attributes -- **/

       IF (x_order_header_rec.order_type_id is null OR
           x_order_header_rec.order_type_id =  FND_API.G_MISS_NUM)
       then
         x_order_header_rec.order_type_id  := FND_PROFILE.VALUE('IBE_RETURN_TRANSACTION_TYPE');
         IF (x_order_header_rec.order_type_id IS NULL OR x_order_header_rec.order_type_id =  FND_API.G_MISS_NUM)
         THEN
           FND_Message.Set_Name('IBE', 'IBE_ERR_OT_ORDER_TYPE_ID_MISS');
           FND_Msg_Pub.Add;
           RAISE FND_API.G_EXC_ERROR;
         END IF;
       end if; -- if order type id

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('Order Type Id: ' ||x_order_header_rec.order_type_id);
       END IF;

       -- Get the User's Session ORG_ID
       l_user_orgid := mo_global.GET_CURRENT_ORG_ID();
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_util.Debug('Current Org id : ' ||l_user_orgid);
       END IF;

       -- Get the Sales Rep Number from the ASO Utility package
       l_salesrep_number := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(aso_utility_pvt.GET_DEFAULT_SALESREP,l_user_orgid);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_util.Debug('Sales Rep Number for Current Org : ' ||l_salesrep_number);
       END IF;
       -- Bug 5255625, Proper error message when default salesrep is not set
       IF (l_salesrep_number is null) THEN
         FND_Message.Set_Name('IBE', 'IBE_ERR_OT_SALESREPID_MISS');
         FND_Msg_Pub.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
       -- Get the sales rep id from the sales rep number using the JTF table
       select SALESREP_ID into l_salesrep_id from JTF_RS_SALESREPS where SALESREP_NUMBER = l_salesrep_number and ORG_ID = l_user_orgid;
       END IF;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          Ibe_util.Debug('Sales Rep Id : ' ||l_salesrep_id);
       END IF;
       --l_salesrep_id := FND_PROFILE.VALUE('ASO_DEFAULT_PERSON_ID');

       IF (l_salesrep_id is null) THEN
         FND_Message.Set_Name('IBE', 'IBE_ERR_OT_SALESREPID_MISS');
         FND_Msg_Pub.Add;
         RAISE FND_API.G_EXC_ERROR;
       ELSE
         --Modified for bug 22542852
         --x_order_header_rec.salesrep_id     := l_salesrep_id;
         x_order_header_rec.salesrep_id     := FND_API.G_MISS_NUM;
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.Debug('22542852--printing default salesrep--inside defaultHeaderRecord' || x_order_header_rec.salesrep_id);
     END IF;
       END IF;
       x_order_header_rec.source_document_type_id := 13;  -- iStore Account

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('OM::Get_Code_Release_Level: ' ||OE_CODE_CONTROL.Get_Code_Release_Level);
       END IF;

       l_preApprove_prof := FND_PROFILE.VALUE('IBE_ENABLE_RETURN_PREBOOK');
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.Debug('Enable Pre-Approval Profile value: ' ||l_preApprove_prof);
       END IF;

       IF (x_order_header_rec.order_category_code = 'RETURN' AND
           OE_CODE_CONTROL.Get_Code_Release_Level > '110509' AND
           l_preApprove_prof = 'Y') THEN
         x_order_header_rec.flow_status_code  := 'WORKING';
       END IF;

     ELSIF(p_save_type = SAVE_NORMAL OR p_save_type = SAVE_REMOVEITEMS) THEN
       FND_Message.Set_Name('IBE', 'IBE_ERR_OT_REFRESH_RETURN');
       FND_Msg_Pub.Add;
       RAISE FND_API.G_EXC_ERROR;
     END If; --save type= normal
   ELSE

      -- This flow will be reached when there is aleady an existing active pending return
      -- and the user tries to create a return without sending active pending return's HeaderId
      -- in oe_order_header_rec.header_id. So here defaulting should be done from existing active pending
      -- return's header record.

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Inside Header Record update defaulting flow');
     END IF;
     x_order_header_rec.header_id := l_order_header_id;
     open c_defaulthdr_rec(l_order_header_id);
     fetch c_defaulthdr_rec into l_ordertype_id;
     close c_defaulthdr_rec;
     if (x_order_header_rec.order_type_id is null or
         x_order_header_rec.order_type_id = FND_API.G_MISS_NUM)
     then
       x_order_header_rec.order_type_id := l_ordertype_id;
     end if;
     x_order_header_rec.operation := OE_Globals.G_OPR_UPDATE;

   END IF; -- if order_header_id

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('Operation: ' ||x_order_header_rec.operation);
   END IF;

 ELSIF (x_order_header_rec.ORDER_CATEGORY_CODE) = 'ORDER' OR (x_order_header_rec.ORDER_CATEGORY_CODE) = 'MIXED'
 THEN
 -- For future enhancements.
  null;
 END IF; --IF ORDER_CATEG_CODE

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  Ibe_util.Debug('End IBE_ORDER_SAVE_PVT:DefaultHeaderRecord');
  Ibe_util.Debug('22542852-End IBE_ORDER_SAVE_PVT:DefaultHeaderRecord-printing header salesrep_id at the end' || x_order_header_rec.salesrep_id);
 END IF;

END DefaultHeaderRecord;


PROCEDURE CancelOrder(
                  p_order_header_rec     IN  OE_Order_PUB.Header_Rec_Type
                 ,x_order_header_rec     OUT NOCOPY OE_Order_PUB.Header_Rec_Type
                )
IS
  cursor c_get_hdrInfo(l_hrdId Number) is
    select flow_status_code, order_category_code from oe_order_headers_all where header_id = l_hrdId;

  l_header_rec c_get_hdrInfo%rowtype;
  l_flow_status         VARCHAR2(30);
  l_order_category_code VARCHAR2(30);

BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('Begin IBE_Order_Save_Pvt.CancelOrder');
END IF;

x_order_header_rec := p_order_header_rec;

for l_header_rec in c_get_hdrInfo(x_order_header_rec.header_id)
loop
--   exit when c_get_hdrInfo%notfound;
   x_order_header_rec.FLOW_STATUS_CODE := l_header_rec.FLOW_STATUS_CODE;
   x_order_header_rec.ORDER_CATEGORY_CODE := l_header_rec.ORDER_CATEGORY_CODE;
end loop;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('CancelOrder - FLOW_STATUS_CODE: '||x_order_header_rec.FLOW_STATUS_CODE);
   Ibe_util.Debug('CancelOrder - ORDER_CATEGORY_CODE: '||x_order_header_rec.ORDER_CATEGORY_CODE);
END IF;

IF (x_order_header_rec.FLOW_STATUS_CODE in ('ENTERED','WORKING') AND
    x_order_header_rec.ORDER_CATEGORY_CODE = 'RETURN') THEN

  x_order_header_rec.operation            := OE_Globals.G_OPR_DELETE;
  x_order_header_rec.cancelled_flag       := FND_API.G_MISS_CHAR;

ELSE
  x_order_header_rec.operation            := OE_Globals.G_OPR_UPDATE;
  x_order_header_rec.cancelled_flag       := 'Y';
--  x_order_header_rec.change_reasons       := p_order_header_rec.change_reasons;
--  x_order_header_rec.change_comments      := p_order_header_rec.change_comments;

END IF;


IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  Ibe_util.Debug('End IBE_ORDER_SAVE_PVT:CancelOrder');
END IF;

END CancelOrder;

PROCEDURE DefaultHdrLineAddress(
            p_order_line_tbl        IN  OE_Order_PUB.Line_Tbl_Type
           ,p_order_header_rec      IN  OE_Order_PUB.Header_Rec_Type
           ,p_party_id              IN  NUMBER:=  FND_API.G_MISS_NUM
           ,p_shipto_partysite_id   IN  NUMBER:=  FND_API.G_MISS_NUM
           ,p_billto_partysite_id   IN  NUMBER:=  FND_API.G_MISS_NUM
           ,x_order_header_rec      OUT NOCOPY OE_Order_PUB.Header_Rec_Type
           ,x_order_line_tbl        OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
           ,x_return_status         OUT NOCOPY VARCHAR2
           ,x_msg_count             OUT NOCOPY NUMBER
           ,x_msg_data              OUT NOCOPY VARCHAR2
    )
IS

    cursor c_get_lineInfo(l_lineId Number) is
    select invoice_to_org_id,ship_to_org_id from oe_order_lines_all where line_id = l_lineId;

    l_line_rec c_get_lineInfo%rowtype;

    cursor c_party_type(cpt_party_id NUMBER) is
    select party_type from HZ_PARTIES where party_id = cpt_party_id;

    l_party_type VARCHAR2(30);
    lx_header_siteuse_id NUMBER;
    lx_line_siteuse_id NUMBER;
    l_api_name varchar2(40) := 'DefaultHdrLineAddress';

    l_cust_acct_role_id NUMBER;
    l_custacct_site_id    NUMBER;
    l_cust_acct_id        NUMBER;
    l_party_id            NUMBER;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('Begin IBE_ORDER_SAVE_PVT:DefaultHdrLineAddress - 25536969');
   end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  x_order_header_rec   := p_order_header_rec;


  for lineIdx in 1..p_order_line_tbl.count
  loop
    x_order_line_tbl(lineIdx) := p_order_line_tbl(lineIdx);
  end loop;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('Inside DefaultHdrLineAddress party_id' ||p_party_id);
  END IF;

  OPEN  c_party_type(p_party_id);
  FETCH c_party_type into l_party_type;
  CLOSE c_party_type;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('DefaultHdrLineAddress l_party_type'||l_party_type);
  END IF;

--  No need to default any address for line level because OE always
--  override the values at line level referencing from original order lines.

                  /********* B2B LineLevel **********/
  /* Invoice to Org Id and ShipTo Org Id will be populated
      from the referenced Order Lines.                    */
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('DefaultHdrLineAddress ---- line level ship to and bill to');
  END IF;

 IF (l_party_type = 'PARTY_RELATIONSHIP') THEN
   for j in 1..x_order_line_tbl.count
   loop
    for l_line_rec in c_get_lineInfo(x_order_line_tbl(j).return_attribute2)
     loop
      ValidateLineShipTo(p_siteuse_type => 'SHIP_TO',
                     p_site_use_id => l_line_rec.SHIP_TO_ORG_ID,
                     x_site_use_id => lx_line_siteuse_id);
                     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   Ibe_util.Debug('DefaultHdrLineAddress ---- validating line level ship to----lx_line_siteuse_id - 25536969===='||lx_line_siteuse_id);
  END IF;
        IF (lx_line_siteuse_id is not null AND lx_line_siteuse_id <> FND_API.G_MISS_NUM)
      THEN
      x_order_line_tbl(j).ship_to_org_id    := lx_line_siteuse_id;
      ELSE
      x_order_line_tbl(j).ship_to_org_id    := FND_API.G_MISS_NUM;
      END IF;
      x_order_line_tbl(j).invoice_to_org_id := l_line_rec.INVOICE_TO_ORG_ID;
     end loop;
   end loop;
  END IF;

                  /********* B2B and B2C Header Level **********/

    -- Call Get_Cust_Account_Site_Use to retrieve ship_to_org_id /invoice_to_org_id.
    -- Now start for 'SHIP_TO_ORG_ID'.


    IBE_CUSTOMER_ACCT_PVT.Get_Cust_Account_Site_Use(
                             p_cust_acct_id   =>   x_order_header_rec.sold_to_org_id
                            ,p_party_id        =>  p_party_id
                            ,p_siteuse_type    =>  'SHIP_TO'
                            ,p_partysite_id    =>  p_shipto_partysite_id
                            ,x_siteuse_id      =>  lx_header_siteuse_id
                            ,x_return_status   =>  x_return_status
                            ,x_msg_data        =>  x_msg_data
                            ,x_msg_count       =>  x_msg_count
                           );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('DefaultHdrLineAddress: 25536969 --- After call to Get_Cust_Acct_Site_Use-ShipTO '||x_return_status);
    END IF;


    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      -- raise FND_API.G_EXC_ERROR;
     FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_SHIPTO_ADDR');
     FND_Msg_Pub.Add;
     RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('DefaultHdrLineAddress: '||lx_header_siteuse_id);
    END IF;

    IF (lx_header_siteuse_id is not null AND lx_header_siteuse_id <> FND_API.G_MISS_NUM)
    THEN
      x_order_header_rec.ship_to_org_id :=   lx_header_siteuse_id;
    ELSIF (l_party_type = 'PARTY_RELATIONSHIP') THEN

         -- IF valid SiteUseId is not returned , final attempt, populate from the lines.
         -- ONLY FOR B2B flow

      DefaultFromLineSiteId(p_line_tbl     => x_order_line_tbl
                          ,p_party_id     => p_party_id
                          ,p_siteuse_type => 'SHIP_TO'
                          ,x_site_use_id  => lx_header_siteuse_id
                          );

      IF (lx_header_siteuse_id is not null AND lx_header_siteuse_id <> FND_API.G_MISS_NUM)
      THEN
        x_order_header_rec.ship_to_org_id :=   lx_header_siteuse_id;
      ELSE

         -- modified for bug 25536969
         x_order_header_rec.ship_to_org_id :=   FND_API.G_MISS_NUM;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('DefaultHdrLineAddress: Final Attempt- Ship To');
     Ibe_util.Debug('DefaultHdrLineAddress: Modified for bug 25536969');
     Ibe_util.Debug('DefaultHdrLineAddress: x_order_header_rec.ship_to_org_id -'||x_order_header_rec.ship_to_org_id);
    END IF;

        -- If final attempt also fails, no other go, Raise An Exception
      --  FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_SHIPTO_ADDR');
       -- FND_Msg_Pub.Add;
    --    RAISE FND_API.G_EXC_ERROR;  -- Error Message should indicate the
                                    -- user to select/ create a valid Shipping address
                                    -- in the profiles tab.
      END IF;
    ELSE
    -- modified for bug 25536969
         x_order_header_rec.ship_to_org_id :=   FND_API.G_MISS_NUM;
        -- FOR B2C raise an exception.
       -- FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_SHIPTO_ADDR');
      --  FND_Msg_Pub.Add;
      --  RAISE FND_API.G_EXC_ERROR;
    END IF;

    ----
    -- For 'INVOICE_TO_ORG_ID'
    ----

    IBE_CUSTOMER_ACCT_PVT.Get_Cust_Account_Site_Use(
                              p_cust_acct_id   =>  x_order_header_rec.sold_to_org_id
                             ,p_party_id       =>  p_party_id
                             ,p_siteuse_type   =>  'BILL_TO'
                             ,p_partysite_id   =>  p_billto_partysite_id
                             ,x_siteuse_id     =>  lx_header_siteuse_id
                             ,x_return_status  =>  x_return_status
                             ,x_msg_data       =>  x_msg_data
                             ,x_msg_count      =>  x_msg_count
                            );


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('DefaultHdrLineAddress: After call to Get_Cust_Acct_Site_Use-BillTO '||x_return_status);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_BILLTO_ADDR');
     FND_Msg_Pub.Add;
     RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (lx_header_siteuse_id is not null AND lx_header_siteuse_id <> FND_API.G_MISS_NUM)
    THEN
       x_order_header_rec.invoice_to_org_id :=   lx_header_siteuse_id;
    ELSIF (l_party_type = 'PARTY_RELATIONSHIP') THEN

      -- IF valid SiteUseId is not returned , final attempt, populate from the lines.
      -- ONLY FOR B2B USERS

      DefaultFromLineSiteId(p_line_tbl      => x_order_line_tbl
                           ,p_party_id     => p_party_id
                           ,p_siteuse_type => 'BILL_TO'
                           ,x_site_use_id  => lx_header_siteuse_id
                           );

      IF (lx_header_siteuse_id is not null AND lx_header_siteuse_id <> FND_API.G_MISS_NUM)
      THEN
         x_order_header_rec.invoice_to_org_id :=   lx_header_siteuse_id;
      ELSE
         -- If final attempt also fails, no other go,Raise An Exception
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('DefaultHdrLineAddress: Final Attempt- Bill To');
    END IF;

         FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_BILLTO_ADDR');
         FND_Msg_Pub.Add;
         RAISE FND_API.G_EXC_ERROR; -- Error Message should indicate the
                                    -- user to select/ create a valid Shipping address
                                     -- in the profiles tab.
      END IF;
    ELSE
        -- FOR B2C raise an exception.
        FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_BILLTO_ADDR');
        FND_Msg_Pub.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('DefaultHdrLineAddress ship_to_org_id: ' || x_order_header_rec.ship_to_org_id);
     Ibe_util.Debug('DefaultHdrLineAddress bill_to_org_id: ' || x_order_header_rec.invoice_to_org_id);
    END IF;

   /**************** B2C LineLevel  *******************/

   -- Not Required as OE always override this with orig. order lines.
   -- Populate from Header Record.


-- New Changes
   -- Invoice To Contact Id:
   -- For Lines this would be always defaulted from referenced order lines by OE.(For creation)
   -- For Header this would be fetched from hz_cust_account_roles.cust_account_role_id.
   -- This flow is only for B2B users.
   -- A B2B customer can invoice the Order/Invoice to any of the contacts.
   -- But for B2C,it is always to him, the customer.  No any contact will be present.
   -- This is the value to be populated in oe_order_headers_all.invoice_to_contact_id.
   -- How this value is retrieved ?
     -- This is hz_cust_account_roles.cust_account_role_id whose
     -- cust_acct_site_id = hz_cust_acct_sites_all.cust_acct_site_id and
     -- hz_cust_acct_sites_all.cust_acct_site_id = hz_cust_site_uses_all.cust_acct_site_id
     -- hz_cust_site_uses_all.site_use_code = 'BILL_TO' and site_use_id = <<InvoiceToOrgId>>.
     -- Also, If the address is defaulted from any of the valid lines,
     -- no need to populate the 'ContactId'.
   -- Why?
     -- The user placing the Return doesn't have any valid 'billTo' address for himself.
     -- In that case, we are trying to populate from any of the linelevel address.
     -- Since  <<InvoiceToOrgId>> is used to fetch this 'ContactId', we dont need to
     -- populate the contactId related to this 'any' address selected from the order lines.


  --for the available site_use_id fetch cust_acct_id and party_id.
  Declare
   cursor c_cust_acct_id (lin_custacct_siteuse_id number, lin_siteuse_type varchar2)
   is
    select hca.cust_acct_site_id, hca.cust_account_id,hps.party_id
    from hz_cust_acct_sites hca,hz_cust_site_uses hcu,hz_party_sites hps
    where
     hcu.site_use_id = lin_custacct_siteuse_id
     and hcu.site_use_code = lin_siteuse_type
     and hcu.cust_acct_site_id = hca.cust_acct_site_id
     and hca.party_site_id     = hps.party_site_id;
  begin
    open c_cust_acct_id(x_order_header_rec.invoice_to_org_id,'BILL_TO');
    fetch c_cust_acct_id into l_custacct_site_id,l_cust_acct_id,l_party_id;
    close c_cust_acct_id;
  end;

   if(l_cust_acct_id = x_order_header_rec.sold_to_org_id
      AND l_party_id = p_party_id) then

     IF (l_party_type = 'PARTY_RELATIONSHIP') THEN
       IBE_CUSTOMER_ACCT_PVT.Get_Cust_Acct_Role(
                        p_party_id            =>  p_party_id
                       ,p_acctsite_type       => 'BILL_TO'
                       ,p_sold_to_orgid       => x_order_header_rec.sold_to_org_id
                       ,p_custacct_siteuse_id => x_order_header_rec.invoice_to_org_id
                       ,x_cust_acct_role_id   => l_cust_acct_role_id
         ,x_return_status       => x_return_status
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
                       );

       x_order_header_rec.invoice_to_contact_id := l_cust_acct_role_id;
     END IF;
   end if;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('End IBE_ORDER_SAVE_PVT:DefaultHdrLineAddress');
   END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:DefaultHdrLineAddress()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPError IBE_ORDER_SAVE_PVT:DefaultHdrLineAddress()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Other IBE_ORDER_SAVE_PVT:DefaultHdrLineAddress()' || sqlerrm);
         END IF;

END DefaultHdrLineAddress;


PROCEDURE SetLineShipInvoiceIds(
               p_order_header_rec IN OE_Order_PUB.Header_Rec_Type := OE_Order_PUB.G_MISS_HEADER_REC,
               p_order_line_tbl IN OE_Order_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL,
               x_order_line_tbl OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
              )
IS

Cursor c_get_hdr_ids(cl_hdr_id number) IS
  select ship_to_org_id,invoice_to_org_id from oe_order_headers_all where header_id = cl_hdr_id;

l_get_hdr_ids          c_get_hdr_ids%rowtype;
l_order_line_tbl       OE_Order_PUB.Line_Tbl_Type;
l_shipto_org_id        NUMBER;
l_invoiceto_org_id     NUMBER;
l_db_shipto_org_id     NUMBER;
l_db_invoiceto_org_id  NUMBER;
l_linetbl_count        NUMBER := 0;
p_lineids_set          VARCHAR2(3000) := null;
l_all_lineids_query    VARCHAR2(3000);
l_linetmp_qry          VARCHAR2(4000);
l_lineid               NUMBER;
l_parseNum 	       NUMBER :=5;
l_parseKey varchar2(40) :='ORDER_SAVE_INVOICE_IDS';

Type lineid_type is REF CURSOR;
lineid_tmp lineid_type;

BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:setlineshipinvoiceids');
    IBE_Util.Debug('setlineshipinvoiceids invoicetoorgid: '|| p_order_header_rec.invoice_to_org_id);
END IF;

for i in 1..p_order_line_tbl.count
loop
  l_order_line_tbl(i) := p_order_line_tbl(i);
end loop;

-- This API will be called always for any updations in the Return for a B2C user.
-- IF any of the existing lines are updated,
-- those Lines would be present in the LineTbl for UPDATE operations.

-- Other Lines which are not updated, i/e those present in the Return Order but
-- didn't updated from UI:
-- These lines would be fetched from DB and for them also InvoiceToOrgId would be updated.

-- Bug# 3334581:
-- As per the impact analysis done for this bug, ShipToOrgId would not be
-- propagated for the Return Order Lines from the Return HEader.
-- So hopToOrgIds fro Return Order Lines for B2C also
--  would remain same as Original Order Lines.
-- So all ShipToorgId assignments are commented down.

-- J
-- Uncommenting all the above lines since the bug has been fixed by OM as per Bug# 3336052
-- Prereq for this is ONT.J

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:setlineshipinvoiceids');
    IBE_Util.Debug('setlineshipinvoiceids invoicetoorgid: '|| p_order_header_rec.invoice_to_org_id);
END IF;

 l_shipto_org_id := p_order_header_rec.ship_to_org_id; --Bug# 3334581
 l_invoiceto_org_id := p_order_header_rec.invoice_to_org_id;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Order header_id: '|| p_order_header_rec.header_id);
 END IF;

  for l_get_hdr_ids in c_get_hdr_ids(p_order_header_rec.header_id)
   loop
     l_db_shipto_org_id    := l_get_hdr_ids.ship_to_org_id; --Bug# 3334581
     l_db_invoiceto_org_id   := l_get_hdr_ids.invoice_to_org_id;
   end loop;

  -- Bug# 3334581
 IF (l_shipto_org_id is null OR l_shipto_org_id = FND_API.G_MISS_NUM)
 THEN
   l_shipto_org_id := l_db_shipto_org_id;
 END IF;


 IF (l_invoiceto_org_id is null OR l_invoiceto_org_id = FND_API.G_MISS_NUM)
 THEN
   l_invoiceto_org_id := l_db_invoiceto_org_id;
 END IF;

 for i in 1..l_order_line_tbl.count
 loop
   l_order_line_tbl(i).ship_to_org_id := l_shipto_org_id;
   l_order_line_tbl(i).invoice_to_org_id := l_invoiceto_org_id;
 end loop;


 -- fetch line ids NOT IN the set from oe_order_lines _all
 -- basically to update the other existing lines also.

 l_linetbl_count := l_order_line_tbl.count;
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('No. of lines to be updated: '|| l_linetbl_count);
 END IF;

 for lineIdx in 1..l_order_line_tbl.count
 loop
   p_lineids_set := p_lineids_set || ','|| l_order_line_tbl(lineIdx).line_id;
 end loop;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('Line Ids to be parsed: '|| p_lineids_set);
 END IF;

 IBE_LEAD_IMPORT_PVT.parseInput (p_lineids_set, 'CHAR', l_parseKey, l_parseNum, l_all_lineids_query);

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('After calling Lead_Import package');
 END IF;

 l_linetmp_qry := 'select line_id from oe_order_lines_all '||
                  'where header_id= :1 and '||
                  'line_id NOT IN('|| l_all_lineids_query ||')';

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('Line qry to be executed: '|| l_linetmp_qry);
 END IF;

  open lineid_tmp for l_linetmp_qry using p_order_header_rec.header_id,l_parseKey;
  loop
    fetch lineid_tmp into l_lineid;
    exit when lineid_tmp%notfound;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.debug('line id from line: '|| l_lineid);
    end if;
    l_linetbl_count := l_linetbl_count +1;
    l_order_line_tbl(l_linetbl_count)  := OE_Order_PUB.G_MISS_LINE_REC;
    l_order_line_tbl(l_linetbl_count).line_id := l_lineid;
    l_order_line_tbl(l_linetbl_count).operation := OE_Globals.G_OPR_UPDATE;
    l_order_line_tbl(l_linetbl_count).invoice_to_org_id := l_invoiceto_org_id;
    l_order_line_tbl(l_linetbl_count).ship_to_org_id := l_shipto_org_id;
 end loop;
 close lineid_tmp;


 for j in 1..l_order_line_tbl.count
 loop
  x_order_line_tbl(j) := l_order_line_tbl(j);
 end loop;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('End OE_ORDER_SAVE_PVT:setlineshipinvoiceids');
END IF;

END SetLineShipInvoiceIds;



 /******* NEW API introduced for MDL Item related operation for RETURNS. ***/
-- Whenever a MDL item is updated, then the chng would be propagated to
-- all the children belong to the parent.
-- If a Model parent is deleted then all related children alos would be deleted.
-- IMPORTANT NOTE:
-- WHEN THIS API IS REMOVED FOR ANY FUTURE ENHANCEMENTS,
-- ENSURE THAT ITEMTYPECODE IS NOT PASSED FROM UI LAYER.
-- NOW MODEL/KIT ITEMS ARE STORED AS STANDARD IN OE.
-- SO IT CANT BE OVERWRITTEN WHICH CREATES UNNECESSARY PBM WHILE BOOKING THE RETURN.
-- UNTIL OE UPTAKES MODEL/CHILDEN RELATION IN RETURN ORDERS DONT OVERRIDE.

Procedure SaveMDLRelatedOperations(p_context_type   IN  VARCHAR2,
                                  p_order_line_tbl  IN  OE_Order_PUB.Line_Tbl_Type,
                                  p_order_header_id IN  NUMBER,
                                  p_save_type       IN  VARCHAR2:=FND_API.G_MISS_CHAR,
                                  x_order_line_tbl  OUT NOCOPY OE_Order_PUB.Line_Tbl_Type
                                 )
IS

   cursor l_childlineid_cur(c_mdlop_lineid Number, c_modop_hdr_id number) is
   select line_id,ordered_quantity,line_category_code,header_id
   from oe_order_lines_all
   where ('ORDER',return_attribute1,return_attribute2) in
             (select line_category_code,header_id,line_id
              from oe_order_lines_all
              where ('RETURN',header_id, top_model_line_id) in
                      (select line_category_code,return_attribute1,return_attribute2
                       from oe_order_lines_all
                       where line_id= c_mdlop_lineid)
              and link_to_line_id is not null)
  and header_id = c_modop_hdr_id;

  -- last condn is added becos same item could have been returned twice in diffrt retns.

  cursor l_tmpparent_cur(l_mdlop_line_id number) is
    select ordered_quantity from oe_order_lines_all
    where line_id = l_mdlop_line_id;

  cursor c_linetmp_cur(c_linetmp_id number) is
    Select item_type_code from oe_order_lines_all where line_id =
      (Select return_attribute2 from oe_order_lines_all where line_id = c_linetmp_id);

   l_tmpparent_rec     l_tmpparent_cur%rowtype;
   l_childlineid_rec   l_childlineid_cur%rowtype;
   c_linetmp_rec       c_linetmp_cur%rowtype;
   l_order_line_tbl    OE_Order_PUB.Line_Tbl_Type;
   l_origparent_qty    NUMBER;
   l_origchild_qty     NUMBER;
   l_new_qty           NUMBER;
   l_linetbl_count     NUMBER;
   l_line_type         VARCHAR2(30) := '';

BEGIN

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('OE_Order_Save_PVT.SaveMDLRelatedOperations -BEGIN');
   IBE_Util.Debug('p_context_type - p_save_type: ' ||p_context_type ||' :: '||p_save_type);
 END IF;

  for i in 1.. p_order_line_tbl.COUNT
  loop
    l_order_line_tbl(i) := p_order_line_tbl(i);
  end loop;

  l_linetbl_count := (l_order_line_tbl.count);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('l_linetbl_count: '||l_linetbl_count);
  END IF;

  if p_context_type = 'SAVE' and p_save_type =SAVE_REMOVEITEMS then
    for i in 1..l_order_line_tbl.count
    loop

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('item_type_code: ' || l_order_line_tbl(i).item_type_code);
      END IF;

    if (l_order_line_tbl(i).ITEM_TYPE_CODE IN ('MODEL','KIT'))
       then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Inside MDL check loop');
        END IF;
        for l_childlineid_rec in l_childlineid_cur(l_order_line_tbl(i).LINE_ID,p_order_header_id)
        loop
          l_linetbl_count                             := l_linetbl_count+1;
          l_order_line_tbl(l_linetbl_count)           := OE_Order_PUB.G_MISS_LINE_REC;
          l_order_line_tbl(l_linetbl_count).LINE_ID   := l_childlineid_rec.LINE_ID;
          l_order_line_tbl(l_linetbl_count).OPERATION := OE_Globals.G_OPR_DELETE;
        end loop;
      end if;
    end loop;

  elsif (p_context_type = 'SAVE' AND
          (p_save_type = SAVE_ADDITEMS OR p_save_type =SAVE_NORMAL)) then

    for i in 1..l_order_line_tbl.count
    loop

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('item_type_code: ' || l_order_line_tbl(i).item_type_code);
      END IF;

      if (l_order_line_tbl(i).item_type_code IN ('MODEL','KIT'))
      then
        for l_tmpparent_rec in l_tmpparent_cur(l_order_line_tbl(i).LINE_ID)
        loop
          l_origparent_qty :=l_tmpparent_rec.ORDERED_QUANTITY;
        end loop;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('l_origparent_qty: ' || l_origparent_qty);
        END IF;

        for l_childlineid_rec in l_childlineid_cur(l_order_line_tbl(i).LINE_ID,p_order_header_id)
        loop
          l_linetbl_count                            := l_linetbl_count+1;
          l_order_line_tbl(l_linetbl_count)          := OE_Order_PUB.G_MISS_LINE_REC;
          l_order_line_tbl(l_linetbl_count).LINE_ID  := l_childlineid_rec.LINE_ID;
          l_order_line_tbl(l_linetbl_count).OPERATION := OE_Globals.G_OPR_UPDATE;

          if(l_order_line_tbl(i).ORDERED_QUANTITY is not null
             AND l_order_line_tbl(i).ORDERED_QUANTITY <> FND_API.G_MISS_NUM)
          then
            l_new_qty          := l_order_line_tbl(i).ORDERED_QUANTITY;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('Incoming qty: ' || l_new_qty);
            END IF;
            l_origchild_qty    := l_childlineid_rec.ORDERED_QUANTITY;
            IF (l_origparent_qty = 0) THEN
                l_order_line_tbl(l_linetbl_count).ORDERED_QUANTITY
                      := l_new_qty;
            END IF;
            IF (l_origchild_qty = 0) THEN
                l_order_line_tbl(l_linetbl_count).ORDERED_QUANTITY
                      := l_new_qty;
            END IF;
            IF (l_origparent_qty <> 0) AND (l_origchild_qty <> 0) THEN
                l_order_line_tbl(l_linetbl_count).ORDERED_QUANTITY
                      := (l_origchild_qty/l_origparent_qty)* l_new_qty;
            END IF;
          end if;
          if(l_order_line_tbl(i).RETURN_REASON_CODE is not null
             AND l_order_line_tbl(i).RETURN_REASON_CODE <> FND_API.G_MISS_CHAR)
          then
            l_order_line_tbl(l_linetbl_count).RETURN_REASON_CODE := l_order_line_tbl(i).RETURN_REASON_CODE;
          end if;
        end loop;
      end if;
    end loop;

  elsif p_context_type='UPDATELINES'  then

    for k in 1..l_order_line_tbl.count
    loop
       -- Check whether this line is a model parent
      for c_linetmp_rec in c_linetmp_cur(l_order_line_tbl(k).line_id)
      loop
        l_line_type := c_linetmp_rec.ITEM_TYPE_CODE;
      end loop;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_line_type: ' || l_line_type);
      END IF;

      -- if model item then propagate contactIds and OrgIds to all children
      if (l_line_type IN ('MODEL','KIT')) then
        for l_childlineid_rec in l_childlineid_cur(l_order_line_tbl(k).LINE_ID,p_order_header_id)
        loop
          l_linetbl_count                             := l_linetbl_count+1;
          l_order_line_tbl(l_linetbl_count)           := OE_Order_PUB.G_MISS_LINE_REC;
          l_order_line_tbl(l_linetbl_count).LINE_ID   := l_childlineid_rec.LINE_ID;
          l_order_line_tbl(l_linetbl_count).OPERATION := OE_Globals.G_OPR_UPDATE;

          if(l_order_line_tbl(k).ship_to_contact_id is not null AND
             l_order_line_tbl(k).ship_to_contact_id <> FND_API.G_MISS_NUM) then
             l_order_line_tbl(l_linetbl_count).ship_to_contact_id
                           := l_order_line_tbl(k).ship_to_contact_id;
          end if;
          if(l_order_line_tbl(k).ship_to_org_id is not null AND
            l_order_line_tbl(k).ship_to_org_id <> FND_API.G_MISS_NUM) then
            l_order_line_tbl(l_linetbl_count).ship_to_org_id
                                  := l_order_line_tbl(k).ship_to_org_id;
          end if;
          if(l_order_line_tbl(k).invoice_to_contact_id is not null AND
            l_order_line_tbl(k).invoice_to_contact_id <> FND_API.G_MISS_NUM) then
            l_order_line_tbl(l_linetbl_count).invoice_to_contact_id
                               := l_order_line_tbl(k).invoice_to_contact_id;
          end if;
          if(l_order_line_tbl(k).invoice_to_org_id is not null AND
            l_order_line_tbl(k).invoice_to_org_id <> FND_API.G_MISS_NUM) then
            l_order_line_tbl(l_linetbl_count).invoice_to_org_id
                                  := l_order_line_tbl(k).invoice_to_org_id;
          end if;
        end loop;
      end if;

    end loop; --main for loop
  end if;  --main if

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_order_line_tbl.count: '||l_order_line_tbl.count);
    END IF;

    for k in 1..l_order_line_tbl.count
    loop
      x_order_line_tbl(k) := l_order_line_tbl(k);
      x_order_line_tbl(k).item_type_code := FND_API.G_MISS_CHAR;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('x_order_line_tbl.LineId: '           || x_order_line_tbl(k).LINE_ID);
        IBE_Util.Debug('x_order_line_tbl.orderd_qty: '       || x_order_line_tbl(k).ORDERED_QUANTITY);
        IBE_Util.Debug('x_order_line_tbl.reason_code: '      || x_order_line_tbl(k).RETURN_REASON_CODE);
        IBE_Util.Debug('x_order_line_tbl.invoice contact: '  || x_order_line_tbl(k).INVOICE_TO_CONTACT_ID);
        IBE_Util.Debug('x_order_line_tbl.invoice org: '      || x_order_line_tbl(k).INVOICE_TO_ORG_ID);
      END IF;
    end loop;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('OE_Order_Save_PVT.SaveMDLRelatedOperations -END');
    END IF;

END SaveMDLRelatedOperations;

PROCEDURE ValidateOrderAccess(p_order_header_id  IN  NUMBER
                              ,x_return_status   OUT NOCOPY VARCHAR2
                              )

IS

cursor c_createdby_info(l_acc_hdr_id NUMBER) IS
 select created_by from oe_order_headers_all where header_id=l_acc_hdr_id;

l_env_user_id NUMBER :=FND_GLOBAL.USER_ID;
l_db_user_id  NUMBER;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Order_Save_Pvt: ValidateOrderAccess - BEGIN');
    IBE_UTIL.DEBUG('User id obtained from environment is: '||l_env_user_id);
    IBE_UTIL.DEBUG('Incoming Header Id: '||p_order_header_id);
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  open c_createdby_info(p_order_header_id);
  fetch c_createdby_info into l_db_user_id;
  close c_createdby_info;

  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('User id obtained from db is: '|| l_db_user_id);
  END IF;

  IF (l_db_user_id <> l_env_user_id)
  THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) then
       IBE_UTIL.DEBUG('Inside If');
    END IF;
    FND_Message.Set_Name('IBE', 'IBE_OT_ERR_USERACCESS');
    FND_Msg_Pub.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Order_Save_Pvt: ValidateOrderAccess - END');
  END IF;

END ValidateOrderAccess;

-- New API added for bug#3240077.
PROCEDURE CheckOverReturnQty(
    p_order_header_id          IN  NUMBER
    ,x_qtyfail_LineIds          OUT NOCOPY x_qtyfail_LineType
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    )
IS

 CURSOR QtyChkLineCur(qtychk_hdrid NUMBER) IS
    SELECT Line_id,inventory_item_id,reference_line_id,ordered_quantity,
           line_number,return_attribute1,return_attribute2
    FROM oe_order_lines_all
    WHERE header_id=qtychk_hdrid
    ORDER BY line_number;


 QtyChkLineRec      QtyChkLineCur%rowtype;
 l_order_line_tbl   OE_Order_PUB.Line_Tbl_Type;

 l_api_name         VARCHAR2(50) := 'CheckOverReturnQty';
 l_api_version      NUMBER       := 1.0;
 lineTblCnt         NUMBER       := 0;
 x_error_tbl        OE_RMA_GRP.OVER_RETURN_ERR_TBL_TYPE;
 l_order_id         VARCHAR2(240);
 l_part_number      VARCHAR2(2000);
 l_hdr_id           NUMBER;
 l_order_number     NUMBER;
 p_tmp_error_lineIds VARCHAR2(3000):=null;
 l_tmp_error_lineIds VARCHAR2(3000);
 l_qty_tmp_query     VARCHAR2(4000);
 l_tmp_index         NUMBER;
 l_index             NUMBER;
 l_tmp_index1        NUMBER;
 l_index1            NUMBER;
 l_index2            NUMBER;

 TYPE l_tmp_qtychk_line_rec IS RECORD
 (   order_number                  NUMBER
   , ordered_item                  VARCHAR2(2000)
   , item_type_code                VARCHAR2(30)
   , orig_order_line_id            NUMBER
   , return_line_id                NUMBER
   , orig_ordered_qty              NUMBER
   , current_return_qty            NUMBER
   , already_return_qty            NUMBER
   , description                   VARCHAR2(240)
 );

TYPE l_tmp_qtychk_line_tbl IS TABLE OF l_tmp_qtychk_line_rec
    INDEX BY BINARY_INTEGER;

l_tmp_order_line_tbl l_tmp_qtychk_line_tbl;
l_tmp_lineTblCnt         NUMBER       := 0;

 Type qty_error_cur_type is REF CURSOR;
 qty_error_cur qty_error_cur_type;
 l_tmp_lineId   NUMBER;
 l_tmp_orderNo  NUMBER;
 l_tmp_itemtype VARCHAR2(30);
 l_tmp_itemdesc VARCHAR2(240);
 l_tmp_pNo      VARCHAR2(2000);
 tempQty         NUMBER;
 l_tmp_qty_idx  NUMBER;
 failcnt        NUMBER :=0;
 l_parseNum 	NUMBER :=5;
 l_parseKey varchar2(40) :='ORDER_SAVE_LINE_IDS';


BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:CheckOverReturnQty()');
     IBE_Util.Debug('Incoming Order Header Id: '|| p_order_header_id);
  END IF;

 --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Start OF API body --

  /*******
     --       Info. about the major variables used in this API  ---
     -- l_order_line_tbl      --> Return Line Ids sent to OM for Qty verifications
     -- l_tmp_order_line_tbl  --> The temporary plsql table declared w/in this API.
     --                           This would have the failing Return Line Ids: only
     --                           the Model/Kit Parents' LineIds and Standard LineIds.
     --                           This is to cover the scenario where individual Child
     --                           Line Items are already returned, but parents are not.
     --                           For UI, only the related Parent Line Id need to be sent.
     -- x_error_tbl           --> It maintains all the qty validation failing Line Ids
     --                           returned from OM API call.
   ***********/

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Line Ids Sent To OM for Qty Validations');
    END IF;
    OPEN QtyChkLineCur(p_order_header_id);
    LOOP
      FETCH QtyChkLineCur INTO QtyChkLineRec;
      EXIT WHEN QtyChkLineCur%NOTFOUND;
      l_order_line_tbl(lineTblCnt)                   := OE_Order_PUB.G_MISS_LINE_REC;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Line Id: '||QtyChkLineRec.LINE_ID);
      END IF;
      l_order_line_tbl(lineTblCnt).LINE_ID           := QtyChkLineRec.LINE_ID;
      l_order_line_tbl(lineTblCnt).REFERENCE_LINE_ID := QtyChkLineRec.REFERENCE_LINE_ID;
      l_order_line_tbl(lineTblCnt).ORDERED_QUANTITY  := QtyChkLineRec.ORDERED_QUANTITY;
      l_order_line_tbl(lineTblCnt).LINE_NUMBER       := QtyChkLineRec.LINE_NUMBER;
      l_order_line_tbl(lineTblCnt).INVENTORY_ITEM_ID := QtyChkLineRec.INVENTORY_ITEM_ID;
      l_order_line_tbl(lineTblCnt).RETURN_ATTRIBUTE1 := QtyChkLineRec.RETURN_ATTRIBUTE1;
      l_order_line_tbl(lineTblCnt).RETURN_ATTRIBUTE2 := QtyChkLineRec.RETURN_ATTRIBUTE2;
      lineTblCnt := lineTblCnt+1;
    END LOOP;
    CLOSE QtyChkLineCur;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_order_line_tbl size: '|| l_order_line_tbl.COUNT);
      IBE_Util.Debug('Before Calling OE_RMA_GRP.Is_Over_Return()');
    END IF;

    OE_RMA_GRP.Is_Over_Return(p_api_version  => 1.0
                         , p_line_tbl      => l_order_line_tbl
                         , x_error_tbl     => x_error_tbl
                         , x_return_status => x_return_status
                         , x_msg_count     => x_msg_count
                         , x_msg_data      => x_msg_data
                          );


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('After Calling Is_Over_Return - return_status: '|| x_return_status);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
      IF (IBE_UTIL.G_DEBUGON = l_true) then
        IBE_UTIL.DEBUG('Error Table Count: ' || x_error_tbl.count);
      end if;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Line Quantity Validation Details Returned from OM');
      ENd IF;
      for j in 1.. x_error_tbl.count
      loop
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('line_id= '||x_error_tbl(j).line_id||' : '||
                  'prev_qty= '||x_error_tbl(j).previous_quantity||' : '||
                  'curr_qty= '||x_error_tbl(j).current_quantity||' : '||
                  'orig_qty= '||x_error_tbl(j).original_quantity||' : '||
                  'ret_stat= '||x_error_tbl(j).return_status);
        END IF;
        p_tmp_error_lineIds := p_tmp_error_lineIds || ','||x_error_tbl(j).LINE_ID;
      end loop;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('l_tmp_error_lineIds set: '||p_tmp_error_lineIds);
      end if;

      IBE_LEAD_IMPORT_PVT.parseInput (p_tmp_error_lineIds, 'CHAR', l_parseKey, l_parseNum, l_tmp_error_lineIds);

      -- this query returns the Ordernumber, partnumber necessary for the error message of the lines
      -- violating the qty. check
      -- Supppose if only one of the child w/in a MODEL is violating, then
      -- the related MODEL's LINEID would be used to generate the error message.
      -- For MODEL items, the error messg. would be generic.

      l_qty_tmp_query := 'SELECT OEH.order_number,msi.concatenated_segments,msi.DESCRIPTION,'||
                                 'OEL.line_id,OEL.item_type_code '||
                          'FROM   oe_order_lines_all OEL,'||
                                 'oe_order_headers_all OEH,'||
                                 'mtl_system_items_vl  msi '||
                          'WHERE OEL.header_id = OEH.header_id '||
                          'AND   OEL.inventory_item_id = msi.inventory_item_Id '||
                          'AND   msi.organization_id = oe_profile.value(''OE_ORGANIZATION_ID'', OEL.org_id) '||
                          'AND   OEL.line_id IN('||
                                     'SELECT nvl(top_model_line_id,line_id) '||
                                      'FROM oe_order_lines_all '||
                                      'WHERE line_id IN('||
                                                'SELECT return_attribute2 '||
                                                'FROM oe_order_lines_all '||
                                                 'WHERE line_id in('||l_tmp_error_lineIds||')))';


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.debug('qry executed: '|| l_qty_tmp_query);
      end if;

      open qty_error_cur for l_qty_tmp_query using l_parseKey;
      LOOP
        FETCH qty_error_cur INTO l_tmp_orderNo,l_tmp_pNo,l_tmp_itemdesc,l_tmp_lineId,l_tmp_itemtype;
        EXIT WHEN qty_error_cur%NOTFOUND;
        l_tmp_order_line_tbl(l_tmp_lineTblCnt).ORIG_ORDER_LINE_ID := l_tmp_lineId;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.debug('l_tmp_lineId: '|| l_tmp_lineId);
        end if;
        l_tmp_order_line_tbl(l_tmp_lineTblCnt).ORDERED_ITEM       := l_tmp_pNo;
        l_tmp_order_line_tbl(l_tmp_lineTblCnt).ORDER_NUMBER       := l_tmp_orderNo;
        l_tmp_order_line_tbl(l_tmp_lineTblCnt).ITEM_TYPE_CODE     := l_tmp_itemtype;
        l_tmp_order_line_tbl(l_tmp_lineTblCnt).description        := l_tmp_itemdesc;
        l_tmp_lineTblCnt := l_tmp_lineTblCnt+1;
       END LOOP;
       close qty_error_cur;


       -- The Original OrderNumber, Orig. LineIds returned were fetched.
       -- Now need to find the related return lineIds of these order lineIDs.
       -- As these were originally sent to OM API, can be checked using the same plsql table.

      l_tmp_index := l_tmp_order_line_tbl.FIRST;
      while l_tmp_index IS NOt NULL
      LOOP
      l_index := l_order_line_tbl.FIRST;
      while l_index IS NOT NULL
       loop
         if(l_tmp_order_line_tbl(l_tmp_index).orig_order_line_id = l_order_line_tbl(l_index).return_attribute2) then
          -- l_tmp_order_line_tbl(l_tmp_index) := l_tmp_order_line_tbl(l_tmp_index);
           l_tmp_order_line_tbl(l_tmp_index).return_line_id := l_order_line_tbl(l_index).line_id;
         end if;
         l_index := l_order_line_tbl.NEXT(l_index);
       end loop; --m loop
       l_tmp_index := l_tmp_order_line_tbl.NEXT(l_tmp_index);
      end loop;

       -- Now collected all details about the failing return line ids.(l_tmp_order_line_tbl)
       -- So need to populate the respective error messages into the FND stack
       -- l_tmp_order_line_tbl should be checked against "x_error_tbl", OM returned
       -- Error Line IDS.
       -- If STD item, then populate the error message w/ all quantity details from "x_error_tbl"
       -- If Model Item or only any of the child item, is violating,
       -- the generic error message should be populated.
       -- But only if a childitem is failing for the Qty check, we need to set the ModelParent's
       -- PartNO. into Error Message.
       -- Note: "x_error_tbl" wont be having the related Model Parents' ID but this is present in
       -- "l_tmp_order_line_tbl". - Scenario1
       -- There may be a case where only child items are failing.
       -- For instance, l_tmp_order_line_tbl --> ModParentId1 and
       -- x_error_tbl --> ChldId1,ChldId2.
       -- To identify such flows l_errorflow var is introduced.

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.debug('ibe:temp Err and OM:error Table Counts: '|| l_tmp_order_line_tbl.count|| ' , '||x_error_tbl.count);
       end if;

       ---- New Changes for sorting in sync w/ UI
       -- Setting the Quantity details as this is needed for STD item Error Message.

       l_tmp_index1 := l_tmp_order_line_tbl.FIRST;
       WHILE (l_tmp_index1 IS NOT NULL)
       LOOP
         l_index1 := x_error_tbl.FIRST;
         WHILE (l_index1 IS NOT NULL)
         LOOP
           IF (l_tmp_order_line_tbl(l_tmp_index1).return_line_id = x_error_tbl(l_index1).line_id) then
               l_tmp_order_line_tbl(l_tmp_index1).orig_ordered_qty   := x_error_tbl(l_index1).original_quantity;
               l_tmp_order_line_tbl(l_tmp_index1).current_return_qty := x_error_tbl(l_index1).current_quantity;
               l_tmp_order_line_tbl(l_tmp_index1).already_return_qty := x_error_tbl(l_index1).previous_quantity;
           END IF;
           l_index1 := x_error_tbl.NEXT(l_index1);
         END LOOP;
         l_tmp_index1:=l_tmp_order_line_tbl.NEXT(l_tmp_index1);
       END LOOP;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.debug('After retrieving the quantity details for the failing lineids from OM error table');
       end if;

    /*** Now start to Append the FND stack having the original Plsql table sent to
         OM, for qty validations, as
         the base table to maintain the UI display order***/

    l_index1 := l_order_line_tbl.FIRST;
    WHILE (l_index1 IS NOT NULL)
    LOOP
       l_index2 := l_tmp_order_line_tbl.FIRST;
       WHILE (l_index2 IS NOT NULL)
       LOOP
         IF (l_order_line_tbl(l_index1).line_id = l_tmp_order_line_tbl(l_index2).return_line_id) THEN
            IF (l_tmp_order_line_tbl(l_index2).item_type_code='STANDARD') then
                   tempQty := (l_tmp_order_line_tbl(l_index2).orig_ordered_qty) -
                          (l_tmp_order_line_tbl(l_index2).already_return_qty);

                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.debug('STD-Item: Fails for Qty: Order#='||l_tmp_order_line_tbl(l_index2).order_number
                                ||' : '||trim(l_tmp_order_line_tbl(l_index2).description)||' : '
                                ||'allowed Qty = '||tempQty);
                end if;
                FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_LINE_OVER_QTY');
                FND_MESSAGE.Set_Token('ORD', l_tmp_order_line_tbl(l_index2).order_number);
                FND_MESSAGE.Set_Token('DESC',  trim(l_tmp_order_line_tbl(l_index2).description));

                FND_MESSAGE.Set_Token('QTY', tempQty);
                FND_Msg_Pub.Add;

           ELSIF(l_tmp_order_line_tbl(l_index2).item_type_code IN ('MODEL','KIT')) then
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.debug('MDL-Item: Fails for Qty: Order#='||l_tmp_order_line_tbl(l_index2).order_number||
                                ' : '||trim(l_tmp_order_line_tbl(l_index2).description));
                end if;
               FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_MDL_LINE_OVER_QTY');
               FND_MESSAGE.Set_Token('ORD', l_tmp_order_line_tbl(l_index2).order_number);
               FND_MESSAGE.Set_Token('DESC',  trim(l_tmp_order_line_tbl(l_index2).description));
               FND_Msg_Pub.Add;
           END IF;
         END IF;
         l_index2 := l_tmp_order_line_tbl.NEXT(l_index2);
       END LOOP;
      l_index1 := l_order_line_tbl.NEXT(l_index1);
    END LOOP;

      ----------- upto here

    /**** This loop is to populate into failing Error Line Ids plsql table, OUT variable  ***/

       l_tmp_qty_idx:=l_tmp_order_line_tbl.FIRST;

       while(l_tmp_qty_idx IS NOT NULL)
       loop

        failCnt:=failCnt+1;

         x_qtyfail_LineIds(failCnt) := 'QTY:'||l_tmp_order_line_tbl(l_tmp_qty_idx).return_line_id;
         l_tmp_qty_idx := l_tmp_order_line_tbl.NEXT(l_tmp_qty_idx);
       end loop;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         raise FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     END IF;


   --
    -- End of API body
   --

  -- Standard call to get message count and if count is 1, get message info.

 FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                             p_data  =>   x_msg_data);

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('End OE_ORDER_SAVE_PVT.CheckReturnQty()');
 END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:CheckOverReturnQty()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDError IBE_ORDER_SAVE_PVT:CheckOverReturnQty()' || sqlerrm);
      END IF;
   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Other IBE_ORDER_SAVE_PVT:CheckOverReturnQty()' || sqlerrm);
         END IF;

END CheckOverReturnQty;

PROCEDURE TCA_AddressValidate(
           p_order_header_id IN NUMBER,
           p_user_type       IN VARCHAR2,
           p_site_use_type   IN VARCHAR2,
           X_failed_line_ids OUT NOCOPY x_qtyfail_LineType,
           x_return_status   OUT NOCOPY VARCHAR2
)

IS

Type Addr_error_cur_type is REF CURSOR;
Addr_error_cur    Addr_error_cur_type;

type tmp_line_id_type IS TABLE OF NUMBER
 INDEX BY BINARY_INTEGER;

l_tmpfail_line_id tmp_line_id_type;
tmpCount      NUMBER:=0;
FailLines     VARCHAR2(10):=FND_API.G_FALSE;
l_index       NUMBER;
l_addr_validate_qry  VARCHAR2(4000);
failCnt       NUMBER:=0;

BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('IBE_Order_Save_Pvt.TCA_AddressValidate BEGIN order_hdr_id: '||p_order_header_id);
  end if;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('IBE_Order_Save_Pvt.TCA_AddressValidate BEGIN site_use_type : '||p_site_use_type);
  end if;


  if(p_user_type = 'PARTY_RELATIONSHIP') then

    if (p_site_use_type ='BILL_TO') then
      l_addr_validate_qry:='SELECT LINES.LINE_ID '||
                           'FROM HZ_CUST_SITE_USES SITE, '||
                               'HZ_CUST_ACCT_SITES ACCT_SITE, '||
                               'OE_ORDER_LINES_ALL LINES '||
                               'WHERE LINES.HEADER_ID  = :InvChkHdrId '||
                               'AND SITE.SITE_USE_ID   = LINES.invoice_to_org_id '||
                               'AND SITE.SITE_USE_CODE = ''BILL_TO'' '||
                               'AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID '||
                               'AND (SITE.STATUS = ''I'' OR ACCT_SITE.STATUS = ''I'') '||
                               'AND '||
                                 'ACCT_SITE.CUST_ACCOUNT_ID in ('||
                                   'SELECT LINES.sold_to_org_id FROM DUAL '||
                                    'UNION '||
                                    'SELECT CUST_ACCOUNT_ID '||
                                    'FROM HZ_CUST_ACCT_RELATE '||
                                    'WHERE '||
                                    'RELATED_CUST_ACCOUNT_ID = LINES.sold_to_org_id '||
                                    'and bill_to_flag = ''Y'' '||
                                    'and status=''A'')';

    elsif(p_site_use_type = 'SHIP_TO') then

      l_addr_validate_qry :='SELECT LINES.LINE_ID '||
                             'FROM HZ_CUST_SITE_USES SITE, '||
                               'HZ_CUST_ACCT_SITES ACCT_SITE, '||
                               'OE_ORDER_LINES_ALL LINES '||
                               'WHERE LINES.HEADER_ID  = :shpChkHdrId '||
                               'AND SITE.SITE_USE_ID   = LINES.ship_to_org_id '||
                               'AND SITE.SITE_USE_CODE = ''SHIP_TO'' '||
                               'AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID '||
                               'AND (SITE.STATUS = ''I'' OR ACCT_SITE.STATUS = ''I'') '||
                               'AND '||
                                 'ACCT_SITE.CUST_ACCOUNT_ID in ('||
                                   'SELECT LINES.sold_to_org_id FROM DUAL '||
                                    'UNION '||
                                    'SELECT CUST_ACCOUNT_ID '||
                                    'FROM HZ_CUST_ACCT_RELATE '||
                                    'WHERE '||
                                    'RELATED_CUST_ACCOUNT_ID = LINES.sold_to_org_id '||
                                    'and ship_to_flag = ''Y'' '||
                                    'and status=''A'')';

    end if; -- if p_site_use_type

  elsif(p_user_type='PERSON') then

    if(p_site_use_type = 'BILL_TO') then
      l_addr_validate_qry := 'SELECT HDR.HEADER_ID '||
                             'FROM HZ_CUST_SITE_USES SITE, '||
                               'HZ_CUST_ACCT_SITES ACCT_SITE, '||
                               'OE_ORDER_HEADERS_ALL HDR '||
                               'WHERE HDR.HEADER_ID  = :invChkHdrId '||
                               'AND SITE.SITE_USE_ID   = HDR.invoice_to_org_id '||
                               'AND SITE.SITE_USE_CODE = ''BILL_TO'' '||
                               'AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID '||
                               'AND (SITE.STATUS = ''I'' OR ACCT_SITE.STATUS = ''I'') '||
                               'AND '||
                                 'ACCT_SITE.CUST_ACCOUNT_ID in ('||
                                   'SELECT HDR.sold_to_org_id FROM DUAL '||
                                    'UNION '||
                                    'SELECT CUST_ACCOUNT_ID '||
                                    'FROM HZ_CUST_ACCT_RELATE '||
                                    'WHERE '||
                                    'RELATED_CUST_ACCOUNT_ID = HDR.sold_to_org_id '||
                                    'and bill_to_flag = ''Y'' '||
                                    'and status=''A'')';


    elsif(p_site_use_type = 'SHIP_TO') then
      l_addr_validate_qry := 'SELECT HDR.HEADER_ID '||
                             'FROM HZ_CUST_SITE_USES SITE, '||
                               'HZ_CUST_ACCT_SITES ACCT_SITE, '||
                               'OE_ORDER_HEADERS_ALL HDR '||
                               'WHERE HDR.HEADER_ID  = :shpChkHdrId '||
                               'AND SITE.SITE_USE_ID   = HDR.ship_to_org_id '||
                               'AND SITE.SITE_USE_CODE = ''SHIP_TO'' '||
                               'AND SITE.CUST_ACCT_SITE_ID = ACCT_SITE.CUST_ACCT_SITE_ID '||
                               'AND (SITE.STATUS = ''I'' OR ACCT_SITE.STATUS = ''I'') '||
                               'AND '||
                                 'ACCT_SITE.CUST_ACCOUNT_ID in ('||
                                   'SELECT HDR.sold_to_org_id FROM DUAL '||
                                    'UNION '||
                                    'SELECT CUST_ACCOUNT_ID '||
                                    'FROM HZ_CUST_ACCT_RELATE '||
                                    'WHERE '||
                                    'RELATED_CUST_ACCOUNT_ID = HDR.sold_to_org_id '||
                                    'and ship_to_flag = ''Y'' '||
                                    'and status=''A'')';
    end if; -- if p_site_use_type
  end if; -- p_user_type

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('Qry executed for Address validation: '||l_addr_validate_qry);
   end if;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('Qry executed for Address validation: '||l_addr_validate_qry);
   end if;

  open Addr_error_cur for l_addr_validate_qry using p_order_header_id;
  loop
    fetch Addr_error_cur into l_tmpfail_line_id(tmpCount);
    Exit when Addr_error_cur%notfound;
    tmpCount := tmpCount+1;
    FailLines := FND_API.G_TRUE;
  end loop;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('Check whether any lines failed: '||FailLines);
   end if;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('Check whether any lines failed: '||FailLines);
   end if;

  if(FND_API.to_boolean(FailLines)) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_index := l_tmpfail_line_id.FIRST;
    while(l_index is not null)
    loop
      failCnt:=failCnt+1;
      if(p_site_use_type='BILL_TO' AND p_user_type = 'PARTY_RELATIONSHIP') then
         X_failed_line_ids(failCnt) := 'BILLADDR:'||l_tmpfail_line_id(l_index);
      end if;
      if(p_site_use_type='SHIP_TO' AND p_user_type = 'PARTY_RELATIONSHIP') then
         X_failed_line_ids(failCnt) := 'SHIPADDR:'||l_tmpfail_line_id(l_index);
      end if;
      if(p_site_use_type='BILL_TO' AND p_user_type = 'PERSON') then
         X_failed_line_ids(failCnt) := 'BILLADDR:HDR';
      end if;
      if(p_site_use_type='SHIP_TO' AND p_user_type = 'PERSON') then
         X_failed_line_ids(failCnt) := 'SHIPADDR:HDR';
      end if;
      l_index:=l_tmpfail_line_id.NEXT(l_index);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.debug('Line ID Failed for Addr: '|| X_failed_line_ids(failCnt));
      end if;
    end loop;
  end if;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.debug('IBE_Order_Save_Pvt.TCA_AddressValidate END '||x_return_status);
  end if;


END TCA_AddressValidate;

PROCEDURE TCA_ContactValidate(
           p_order_header_id IN NUMBER,
           p_site_use_type   IN VARCHAR2,
           X_failed_line_ids OUT NOCOPY x_qtyfail_LineType,
           x_return_status   OUT NOCOPY VARCHAR2
                          )

IS

Type Contact_error_cur_type is REF CURSOR;
Contact_error_cur    Contact_error_cur_type;

type tmp_line_id_type IS TABLE OF NUMBER
 INDEX BY BINARY_INTEGER;

l_tmpfail_line_id tmp_line_id_type;
tmpCount      NUMBER:=0;
FailLines     VARCHAR2(10):=FND_API.G_FALSE;
l_index       NUMBER;
l_contact_validate_qry VARCHAR2(4000);
failCnt       NUMBER:=0;

BEGIN

  x_return_status   := FND_API.G_RET_STS_SUCCESS;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('IBE_Order_Save_Pvt.TCA_AddressValidate BEGIN');
  end if;

    if (p_site_use_type ='BILL_TO') then
      l_contact_validate_qry:='SELECT LINES.LINE_ID '||
                              'FROM OE_ORDER_LINES_ALL LINES, '||
                              'HZ_CUST_ACCOUNT_ROLES ACCT_ROLE, '||
                              'HZ_CUST_SITE_USES_ALL   INV, '||
                              'HZ_CUST_ACCT_SITES_ALL  ADDR '||
                              'WHERE   LINES.HEADER_ID      = :InvCntChkHdrId '||
                              'AND  ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = LINES.invoice_to_contact_id '||
                              'AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID '||
                              'AND  ACCT_ROLE.ROLE_TYPE = ''CONTACT'' '||
                              'AND  ADDR.CUST_ACCT_SITE_ID = INV.CUST_ACCT_SITE_ID '||
                              'AND  INV.SITE_USE_ID = LINES.invoice_to_org_id '||
                              'AND  INV.STATUS = ''I'' '||
                              'AND  ACCT_ROLE.STATUS = ''I''';

    elsif(p_site_use_type = 'SHIP_TO') then

         l_contact_validate_qry:='SELECT LINES.LINE_ID '||
                              'FROM OE_ORDER_LINES_ALL LINES, '||
                              'HZ_CUST_ACCOUNT_ROLES ACCT_ROLE, '||
                              'HZ_CUST_SITE_USES_ALL   INV, '||
                              'HZ_CUST_ACCT_SITES_ALL  ADDR '||
                              'WHERE   LINES.HEADER_ID      = :InvCntChkHdrId '||
                              'AND  ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = LINES.ship_to_contact_id '||
                              'AND  ACCT_ROLE.CUST_ACCOUNT_ID = ADDR.CUST_ACCOUNT_ID '||
                              'AND  ACCT_ROLE.ROLE_TYPE = ''CONTACT'' '||
                              'AND  ADDR.CUST_ACCT_SITE_ID = INV.CUST_ACCT_SITE_ID '||
                              'AND  INV.SITE_USE_ID = LINES.ship_to_org_id '||
                              'AND  INV.STATUS = ''I'' '||
                              'AND  ACCT_ROLE.STATUS = ''I''';

    end if; -- if p_site_use_type

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.debug('Contact Query Executed: '||l_contact_validate_qry);
    end if;

    open Contact_error_cur for l_contact_validate_qry using p_order_header_id;
    loop
      fetch Contact_error_cur into l_tmpfail_line_id(tmpCount);
      Exit when Contact_error_cur%notfound;
      tmpCount := tmpCount+1;
      FailLines := FND_API.G_TRUE;
    end loop;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.debug('Whether Any Lines failed for Contact check: '|| FailLines);
    end if;

   if(FND_API.to_boolean(FailLines)) then
    x_return_status := FND_API.G_RET_STS_ERROR;
    l_index := l_tmpfail_line_id.FIRST;
    while(l_index is not null)
    loop
      failCnt:=failCnt+1;
      if(p_site_use_type='BILL_TO') then
         X_failed_line_ids(failCnt) := 'BILLCTNT:'||l_tmpfail_line_id(l_index);
      end if;
      if(p_site_use_type='SHIP_TO') then
         X_failed_line_ids(failCnt) := 'SHIPCTNT:'||l_tmpfail_line_id(l_index);
      end if;
      l_index:=l_tmpfail_line_id.NEXT(l_index);
    end loop;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.debug('Line Id failed for Contact check: '|| X_failed_line_ids(failCnt));
    end if;
  end if;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('IBE_Order_Save_Pvt.TCA_AddressValidate END '||x_return_status);
  end if;

END TCA_ContactValidate;


-- New API For Address and Quantity validations
-- For POST OM 11590 (OM.J) flows during submit actions.
-- Refer bug# 3272918

PROCEDURE Complete_RetOrder_Validate
        ( P_order_header_id       IN NUMBER,
          p_user_type             IN VARCHAR2,
          p_init_msg_list         IN VARCHAR2 := FND_API.G_TRUE,
          X_failed_line_ids       OUT NOCOPY JTF_VARCHAR2_TABLE_300,
          X_return_status         OUT NOCOPY VARCHAR2,
          X_msg_count             OUT NOCOPY NUMBER,
          X_msg_data              OUT NOCOPY VARCHAR2
        )

IS

l_api_name varchar2(40) := 'Complete_RetOrder_Validate';


tCount NUMBER:=0;
QtyFailLineCnt NUMBER ;
TCAFailLineCnt NUMBER;
l_inv_index  NUMBER;
l_shp_index  NUMBER;
l_inv_index1  NUMBER;
l_shp_index1  NUMBER;
FailLines     VARCHAR2(10):=FND_API.G_FALSE;
x_qtyfail_LineIds x_qtyfail_LineType;
x_TCAfail_LineIds x_qtyfail_LineType;
l_return_status   varchar2(100);
ll_return_status  varchar2(100);


BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:Complete_RetLine_Validation()');
  END IF;

   X_failed_line_ids := JTF_VARCHAR2_TABLE_300();

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;


  -- Calling Address validate API w/ BILL_TO
  -- If needed, for 'shipto' validation, add one more call w/ SHIP_TO.
  -- The user type check would be done in the TCA_Addressvalidate API.





  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Before calling TCA_AddressValidate for billto: ');
  END IF;

  TCA_AddressValidate(p_order_header_id => p_order_header_id,
                      p_user_type       => p_user_type,
                      p_site_use_type   => 'BILL_TO',
                      X_failed_line_ids => x_TCAfail_LineIds,
                      x_return_status   => l_return_status
                     );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('After calling TCA_AddressValidate Billto: '||l_return_status);
  END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Address Failing Line count Billto:'|| x_TCAfail_LineIds.count);
         END IF;
         tCount := X_failed_line_ids.count;
         TCAFailLineCnt := x_TCAfail_LineIds.FIRST;

         while (TCAFailLineCnt IS NOT NULL)
         Loop
           X_failed_line_ids.extend(1);
           tCount := tCount+1;
           X_failed_line_ids(tCount) := x_TCAfail_LineIds(TCAFailLineCnt);
           TCAFailLineCnt := x_TCAfail_LineIds.NEXT(TCAFailLineCnt);
         end loop;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Total failLine Ids in Addr Loop Bill to: '|| X_failed_line_ids.count);
           for k in 1..X_failed_line_ids.count
           loop
             IBE_Util.Debug('Total failLine Ids in Addr Loop Billto: '|| X_failed_line_ids(k));
           end loop;
         END IF;


   END IF;


  /** p_user_type is checked because if its a B2C flow,
     no need to validate the CONTACT details ***/

  if(p_user_type ='PARTY_RELATIONSHIP') THEN

     TCA_ContactValidate(p_order_header_id => p_order_header_id,
                         p_site_use_type   => 'BILL_TO',
                         X_failed_line_ids => x_TCAfail_LineIds,
                         x_return_status   => ll_return_status
                        );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('After calling TCA_ContactValidate: '||ll_return_status);
    END IF;
    IF ll_return_status = FND_API.G_RET_STS_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Failing Line count:'|| x_TCAfail_LineIds.count);
         END IF;
         tCount := X_failed_line_ids.count;
         TCAFailLineCnt := x_TCAfail_LineIds.FIRST;

         while (TCAFailLineCnt IS NOT NULL)
         Loop
           X_failed_line_ids.extend(1);
           tCount := tCount+1;
           X_failed_line_ids(tCount) := x_TCAfail_LineIds(TCAFailLineCnt);
           TCAFailLineCnt := x_TCAfail_LineIds.NEXT(TCAFailLineCnt);
         end loop;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Total failLine Ids in Contact Loop: '|| X_failed_line_ids.count);
           for k in 1..X_failed_line_ids.count
           loop
             IBE_Util.Debug('Total failLine Ids in Contact Loop: '|| X_failed_line_ids(k));
           end loop;
         END IF;

   end if;

    /*
        Set the Message if either the contact or address is invalid
    */
   if(l_return_status =FND_API.G_RET_STS_ERROR
   OR ll_return_status =FND_API.G_RET_STS_ERROR) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Invalid Billing Details- Settig the Error to FND stack');
      END IF;
      FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_INVALID_BILLDET');
      FND_Msg_Pub.Add;
   end if;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Before calling TCA_AddressValidate: BILL_TO');
   END IF;

 -- For Ship To Contact and Address Validation
   TCA_AddressValidate(p_order_header_id => p_order_header_id,
                      p_user_type       => p_user_type,
                      p_site_use_type   => 'SHIP_TO',
                      X_failed_line_ids => x_TCAfail_LineIds,
                      x_return_status   => l_return_status
                     );

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('After calling TCA_AddressValidate Ship to: '||l_return_status);
  END IF;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Address Failing Line count Shipto:'|| x_TCAfail_LineIds.count);
         END IF;
         tCount := X_failed_line_ids.count;
         TCAFailLineCnt := x_TCAfail_LineIds.FIRST;

         while (TCAFailLineCnt IS NOT NULL)
         Loop
           X_failed_line_ids.extend(1);
           tCount := tCount+1;
           X_failed_line_ids(tCount) := x_TCAfail_LineIds(TCAFailLineCnt);
           TCAFailLineCnt := x_TCAfail_LineIds.NEXT(TCAFailLineCnt);
         end loop;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Total failLine Ids in Addr Loop:Shipto '|| X_failed_line_ids.count);
           for k in 1..X_failed_line_ids.count
           loop
             IBE_Util.Debug('Total failLine Ids in Addr Loop:Shipto '|| X_failed_line_ids(k));
           end loop;
         END IF;


   END IF;

   TCA_ContactValidate(p_order_header_id => p_order_header_id,
                         p_site_use_type   => 'SHIP_TO',
                         X_failed_line_ids => x_TCAfail_LineIds,
                         x_return_status   => ll_return_status
                        );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('After calling TCA_ContactValidate: '||ll_return_status);
    END IF;
    IF ll_return_status = FND_API.G_RET_STS_ERROR THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Failing Line count:'|| x_TCAfail_LineIds.count);
         END IF;
         tCount := X_failed_line_ids.count;
         TCAFailLineCnt := x_TCAfail_LineIds.FIRST;

         while (TCAFailLineCnt IS NOT NULL)
         Loop
           X_failed_line_ids.extend(1);
           tCount := tCount+1;
           X_failed_line_ids(tCount) := x_TCAfail_LineIds(TCAFailLineCnt);
           TCAFailLineCnt := x_TCAfail_LineIds.NEXT(TCAFailLineCnt);
         end loop;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Total failLine Ids in Contact Loop: '|| X_failed_line_ids.count);
           for k in 1..X_failed_line_ids.count
           loop
             IBE_Util.Debug('Total failLine Ids in Contact Loop: '|| X_failed_line_ids(k));
           end loop;
         END IF;

   end if;

--End Ship To Contact Validation.

 --p_user_type

   END IF;


   if(l_return_status =FND_API.G_RET_STS_ERROR
   OR ll_return_status =FND_API.G_RET_STS_ERROR) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Invalid Billing Details- Settig the Error to FND stack');
      END IF;
      FND_MESSAGE.Set_Name('IBE','IBE_ERR_OT_INVALID_SHIPDET');
      FND_Msg_Pub.Add;
   end if;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Before Calling CheckOverRetQty');
   END IF;

  -- Now verify the Over Return Quantity


  CheckOverReturnQty(p_order_header_id => P_order_header_id
                    ,x_qtyfail_LineIds => x_qtyfail_LineIds
                    ,x_return_status  => x_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
                     );

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('After Calling CheckOverRetQty');
      END IF;

       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('No. of Lines failing after Qty validations:'|| x_qtyfail_LineIds.count);
         END IF;
         tCount := X_failed_line_ids.count;
         QtyFailLineCnt := x_qtyfail_LineIds.FIRST;

         while (QtyFailLineCnt IS NOT NULL)
         Loop
           X_failed_line_ids.extend(1);
           tCount := tCount+1;
           X_failed_line_ids(tCount) := x_qtyfail_LineIds(QtyFailLineCnt);
           QtyFailLineCnt := x_qtyfail_LineIds.NEXT(QtyFailLineCnt);
         end loop;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Total failLine Ids In final loop: '|| X_failed_line_ids.count);
           for k in 1..X_failed_line_ids.count
           loop
             IBE_Util.Debug('Total failLine Ids in final Loop: '|| X_failed_line_ids(k));
           end loop;
         END IF;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Total Failing LineCounts:'||tCount);
         END IF;
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug(' Total Failing LineCounts:'||tCount);
         END IF;

  -- If there are validation failing line IDs then set the status as ERROR.

      IF (X_failed_line_ids.count > 0) THEN
        raise FND_API.G_EXC_ERROR;
      ENd IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('End IBE_ORDER_SAVE_PVT:Complete_RetOrder_Validate');
   END IF;

   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:Complete_RetOrder_Validate()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPError IBE_ORDER_SAVE_PVT:Complete_RetOrder_Validate()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Other IBE_ORDER_SAVE_PVT:Complete_RetOrder_Validate()' || sqlerrm);
         END IF;

END Complete_RetOrder_Validate;


PROCEDURE Save(
     p_api_version_number       IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,p_order_header_rec         IN  OE_Order_PUB.Header_Rec_Type
    ,p_order_line_tbl           IN  OE_Order_PUB.Line_Tbl_Type
    ,p_submit_control_rec       IN  IBE_Order_W1_PVT.Control_Rec_Type
    ,p_save_type                IN  NUMBER
    ,p_party_id                 IN  NUMBER
    ,p_shipto_partysite_id      IN  NUMBER
    ,p_billto_partysite_id      IN  NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,x_order_header_id          OUT NOCOPY NUMBER
    ,x_order_number             OUT NOCOPY NUMBER
    ,x_flow_status_code         OUT NOCOPY VARCHAR2
    ,x_last_update_date         OUT NOCOPY DATE
   ,X_failed_line_ids          OUT NOCOPY JTF_VARCHAR2_TABLE_300
    )
IS

cursor c_holdid is
  select hold_id from oe_hold_definitions where name = 'STORE_HOLD';

cursor cr_persontype(cr_prtyid number) is
 select party_type from hz_parties where party_id = cr_prtyid;

l_order_header_rec     OE_Order_PUB.Header_Rec_Type:= OE_Order_PUB.G_MISS_HEADER_REC;

l_Header_Adj_tbl       OE_Order_PUB.Header_Adj_Tbl_Type := OE_Order_PUB.G_MISS_HEADER_ADJ_TBL;
l_Header_Price_Att_tbl OE_Order_PUB.Header_Price_Att_Tbl_Type :=OE_Order_PUB.G_MISS_HEADER_PRICE_ATT_TBL;
l_Header_Adj_Att_tbl   OE_Order_PUB.Header_Adj_Att_Tbl_Type :=OE_Order_PUB.G_MISS_HEADER_ADJ_ATT_TBL;
l_Header_Adj_Assoc_tbl OE_Order_PUB.Header_Adj_Assoc_Tbl_Type :=OE_Order_PUB.G_MISS_HEADER_ADJ_ASSOC_TBL;
l_Header_Scredit_tbl   OE_Order_PUB.Header_Scredit_Tbl_Type :=OE_Order_PUB.G_MISS_HEADER_SCREDIT_TBL;

l_Line_Adj_tbl         OE_Order_PUB.Line_Adj_Tbl_Type :=OE_Order_PUB.G_MISS_LINE_ADJ_TBL;
l_Line_price_Att_tbl   OE_Order_PUB.Line_Price_Att_Tbl_Type :=OE_Order_PUB.G_MISS_LINE_PRICE_ATT_TBL;
l_Line_Adj_Att_tbl     OE_Order_PUB.Line_Adj_Att_Tbl_Type :=OE_Order_PUB.G_MISS_LINE_ADJ_ATT_TBL;
l_Line_Adj_Assoc_tbl   OE_Order_PUB.Line_Adj_Assoc_Tbl_Type :=OE_Order_PUB.G_MISS_LINE_ADJ_ASSOC_TBL;
l_Line_Scredit_tbl     OE_Order_PUB.Line_Scredit_Tbl_Type :=OE_Order_PUB.G_MISS_LINE_SCREDIT_TBL;
l_Lot_Serial_tbl       OE_Order_PUB.Lot_Serial_Tbl_Type := OE_Order_PUB.G_MISS_LOT_SERIAL_TBL;
l_Action_Request_tbl   OE_Order_PUB.request_tbl_type :=OE_Order_PUB.g_miss_request_tbl;
l_header_val_rec       OE_Order_PUB.Header_Val_Rec_Type;

l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_order_line_tbl              OE_Order_PUB.Line_Tbl_Type := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_line_val_tbl                OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_request_tbl                 OE_Order_PUB.Request_Tbl_Type :=OE_Order_PUB.G_MISS_REQUEST_TBL;

lx_Header_Adj_tbl             OE_Order_PUB.Header_Adj_Tbl_Type;
lx_Header_price_Att_tbl       OE_Order_PUB.Header_Price_Att_Tbl_Type ;
lx_Header_Adj_Att_tbl         OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
lx_Header_Adj_Assoc_tbl       OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
lx_Header_Scredit_tbl         OE_Order_PUB.Header_Scredit_Tbl_Type;
lx_Line_Adj_tbl               OE_Order_PUB.Line_Adj_Tbl_Type;
lx_Line_price_Att_tbl         OE_Order_PUB.Line_Price_Att_Tbl_Type ;
lx_Line_Adj_Att_tbl           OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
lx_Line_Adj_Assoc_tbl         OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
lx_Line_Scredit_tbl           OE_Order_PUB.Line_Scredit_Tbl_Type;
lx_Lot_Serial_tbl             OE_Order_PUB.Lot_Serial_Tbl_Type;
lx_order_header_rec           OE_Order_PUB.Header_Rec_Type:= OE_Order_Pub.G_MISS_HEADER_REC;
lx_line_tbl                   OE_Order_PUB.Line_Tbl_Type;

x_mergeline_rec               OE_Order_PUB.Line_Rec_Type;
lx_line_rec                   OE_Order_PUB.Line_rec_type;
l_return_values               varchar2(2000);
l_api_name                    VARCHAR2(50) := 'Save_Order';
l_api_version                 NUMBER       := 1.0;

l_cancel_flow                 VARCHAR2(10) := FND_API.G_FALSE;
l_reqtbl_count                NUMBER;
l_apply_hold                  VARCHAR2(10);
l_hold_id                     NUMBER;
l_user_type                   VARCHAR2(30);
linetblcount                  NUMBER := 0;
l_ProcessOrder_Flow           VARCHAR2(10) := FND_API.G_TRUE;
p_api_service_level           VARCHAR2(30);

-- Delete Order when last Line deleted loop
p_dl_line_ids                 VARCHAR2(3000);
l_dl_line_id_qry              VARCHAR2(3000);
l_dl_tmp_qry                  VARCHAR2(4000);
TYPE l_dl_tmp_type is REF CURSOR;
l_dl_tmp                      l_dl_tmp_type;
No_Of_ExistingLines           NUMBER;
l_flow_status_code            VARCHAR2(30);
l_last_update_date            DATE;
l_parseNum 	       	      NUMBER :=5;
l_parseKey 		      varchar2(40)  :='ORDER_SAVE_LINE_IDS';

tCount NUMBER:=0;
QtyFailLineCnt NUMBER ;
x_qtyfail_LineIds x_qtyfail_LineType;

/****TEMP***/
--X_failed_line_ids JTF_VARCHAR2_TABLE_300;
/******/

msgRewrite boolean := false;

BEGIN

 IBE_UTIL.G_DEBUGON := l_true;

    X_failed_line_ids := JTF_VARCHAR2_TABLE_300();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:Save(): ' || p_save_type);
  END IF;


  -- Standard Start of API savepoint
  SAVEPOINT  SAVE_ORDER_SAVE_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                     P_Api_Version_Number,
                                     l_api_name,
                                     G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- Start OF API body --


 /********** Set Header Record info *************/

   l_order_header_rec := p_order_header_rec;


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin p_order_header_rec' ||p_order_header_rec.header_id ||'::'|| p_party_id);
  END IF;

  -- Call Default Header Record
     DefaultHeaderRecord(l_order_header_rec
                         ,p_party_id
                         ,p_save_type
                         ,lx_order_header_rec);

     l_order_header_rec := lx_order_header_rec;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('Save:order_hdr_rec.operation: ' || l_order_header_rec.operation);
   IBE_Util.Debug('Save:order_hdr_rec.sold_to_org_id: ' || l_order_header_rec.SOLD_TO_ORG_ID);
   IBE_Util.Debug('Save:order_hdr_rec.ship_to_org_id: ' || l_order_header_rec.SHIP_TO_ORG_ID);
   IBE_Util.Debug('Save:order_hdr_rec.Invoice_to_org_id: ' || l_order_header_rec.INVOICE_TO_ORG_ID);
   IBE_Util.Debug('Save:order_hdr_rec.header_id: ' || l_order_header_rec.HEADER_ID);
   IBE_Util.Debug('Save:order_hdr_rec.order type id: ' || l_order_header_rec.ORDER_TYPE_ID);
   IBE_Util.Debug('Save:order_hdr_rec.org id: ' || l_order_header_rec.ORG_ID);
   IBE_Util.Debug('Save:order_hdr_rec.trans_curr_code: ' || l_order_header_rec.transactional_curr_code);
   IBE_Util.Debug('Save:order_hdr_rec.flow_stat_code: ' || l_order_header_rec.flow_status_code);
   IBE_Util.Debug('Save:order_hdr_rec.Minisite_Id: ' || l_order_header_rec.Minisite_Id);
   IBE_Util.Debug('Save:lx_order_header_rec.Minisite_Id: ' || lx_order_header_rec.Minisite_Id);
 END IF;


 /********** User Authentication *************/

 IF (l_order_header_rec.header_id is not null AND
     l_order_header_rec.header_id <> FND_API.G_MISS_NUM)
 THEN
   ValidateOrderAccess(p_order_header_id        => l_order_header_rec.header_id
                      ,x_return_status          => x_return_status
                      );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         raise FND_API.G_EXC_ERROR;
   END IF;
 END IF;


 /********** Set Line Record Info *************/
   -- Default Line Record

 DefaultLineRecord(p_order_line_tbl    => p_order_line_tbl
                  ,p_order_header_rec  => l_order_header_rec
                  ,p_save_type         => p_save_type
                  ,x_order_line_tbl    => l_order_line_tbl
                  );
 IF ((l_order_header_rec.operation = OE_Globals.G_OPR_CREATE) OR
     (p_billto_partysite_id is not null AND  p_billto_partysite_id <> FND_API.G_MISS_NUM) OR
       (p_shipto_partysite_id is not null AND  p_shipto_partysite_id <> FND_API.G_MISS_NUM))
 THEN
   DefaultHdrLineAddress(p_order_line_tbl        => l_order_line_tbl
                        ,p_order_header_rec      => l_order_header_rec
                        ,p_party_id              => p_party_id
                        ,p_billto_partysite_id   => p_billto_partysite_id
                        ,p_shipto_partysite_id   => p_shipto_partysite_id
                        ,x_order_header_rec      => lx_order_header_rec
                        ,x_order_line_tbl        => lx_line_tbl
                        ,x_return_status         => x_return_status
                        ,x_msg_count             => x_msg_count
                        ,x_msg_data              => x_msg_data
                        );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
     raise FND_API.G_EXC_ERROR;
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) then
     Ibe_Util.DEBUG('ship_to_org_id returned: ' || lx_order_header_rec.ship_to_org_id);
     Ibe_Util.DEBUG('bill_to_org_id returned: ' || lx_order_header_rec.invoice_to_org_id);
   end if;

   IF(lx_order_header_rec.invoice_to_org_id is null OR lx_order_header_rec.invoice_to_org_id = FND_API.G_MISS_NUM)
   THEN
      FND_Message.Set_Name('IBE', 'IBE_ERR_OT_SHIPTO_BILLTO_MISS');
      FND_Msg_Pub.Add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   l_order_header_rec := lx_order_header_rec;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Save :order_hdr_rec.ship_to_org_id: ' || l_order_header_rec.SHIP_TO_ORG_ID);
       IBE_Util.Debug('Save :order_hdr_rec.Invoice_to_org_id: ' || l_order_header_rec.INVOICE_TO_ORG_ID);
       IBE_Util.Debug('Save :order_hdr_rec.header_id: ' || l_order_header_rec.HEADER_ID);

   END IF;
   FOR i in 1..lx_line_tbl.COUNT
   LOOP
     l_order_line_tbl(i) := lx_line_tbl(i);
   END LOOP;


END IF; -- if operation = create


   -- This flow is for the B2C user,
   -- whenever he updates the Return, 'invoicetoorgid' at header level
   -- will be populated into lines, because when creating the Returns
   -- address would have been populated from referenced order.
   -- So that has to be changed to get it from Order.


   open cr_persontype(p_party_id);
   fetch cr_persontype into l_user_type;
   close cr_persontype;


   IF ((l_user_type = 'PERSON') AND
       (l_order_header_rec.operation = OE_Globals.G_OPR_UPDATE) AND
       (p_submit_control_rec.cancel_flag <> 'Y'))
   THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) then
        Ibe_Util.DEBUG('calling SetLine ids API');
     END IF;
     SetLineShipInvoiceIds(
               p_order_header_rec => l_order_header_rec
              ,p_order_line_tbl   => l_order_line_tbl
              ,x_order_line_tbl   => lx_line_tbl);

     for j in 1..lx_line_tbl.count
     loop
        l_order_line_tbl(j) := lx_line_tbl(j);
        IF (IBE_UTIL.G_DEBUGON = l_true) then
         Ibe_Util.DEBUG('Line Level Values after setting: '||l_order_line_tbl(j).line_id||' : '||
                l_order_line_tbl(j).ship_to_org_id||' : '||l_order_line_tbl(j).invoice_to_org_id);
        END IF;
     end loop;

   END IF; -- if operation = update

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   FOR i in 1..l_order_line_tbl.COUNT
   LOOP
      IBE_Util.Debug('Save:line_tbl.operation: ' || l_order_line_tbl(i).OPERATION);
      IBE_Util.Debug('Save:line_tbl.line_id: '   || l_order_line_tbl(i).LINE_ID);
      IBE_Util.Debug('Save:line_tbl.line_type_id: '   || l_order_line_tbl(i).LINE_TYPE_ID);
      IBE_Util.Debug('Save:line_tbl.qty: '   || l_order_line_tbl(i).ORDERED_QUANTITY);
      IBE_Util.Debug('Save:line_tbl.inv to org id: '   || l_order_line_tbl(i).INVOICE_TO_ORG_ID);
      IBE_Util.Debug('Save:line_tbl.ship to org id: '   || l_order_line_tbl(i).SHIP_TO_ORG_ID);
      IBE_Util.Debug('Save:line_tbl.return_context: '   || l_order_line_tbl(i).RETURN_CONTEXT);
      IBE_Util.Debug('Save:line_tbl.line categ: '   || l_order_line_tbl(i).LINE_CATEGORY_CODE);
      IBE_Util.Debug('Save:line_tbl.ret atr1: '  || l_order_line_tbl(i).return_attribute1);
      IBE_Util.Debug('Save:line_tbl.ret atr2: '  || l_order_line_tbl(i).return_attribute2);
      IBE_Util.Debug('Save:line_tbl.rcode: '     || l_order_line_tbl(i).return_reason_code);
   END LOOP;
 END IF;


 /************ Hard Delete logic for Pending Return ****/

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('ibe_order_save_pvt:cancel_flag ' ||p_submit_control_rec.cancel_flag);
 END IF;

 if (p_submit_control_rec.cancel_flag = 'Y') then
   CancelOrder(l_order_header_rec,lx_order_header_rec);
   l_order_header_rec := lx_order_header_rec;
   IF (IBE_UTIL.G_DEBUGON = l_true) then
     ibe_util.debug('after cancelorder header_id:' ||l_order_header_rec.header_id);
     ibe_util.debug('after cancelorder operation:' ||l_order_header_rec.operation);
   end if;

   IF(l_order_header_rec.operation = OE_Globals.G_OPR_DELETE) THEN
     l_cancel_flow    := FND_API.G_TRUE;
   END IF;

end if;

 /************ Model Items Logic ******************************/

 -- Call SaveMDLRelatedOperations() if not submit or cancel
 -- This to propagate parent level changes to all children if a
 -- MDL item is updated/ removed.
 -- This is used currently by the Return-Flow-Orders alone.

   IF (l_order_header_rec.operation = OE_GLOBALS.G_OPR_UPDATE AND
       (p_submit_control_rec.submit_flag is null
       OR p_submit_control_rec.submit_flag = FND_API.G_MISS_CHAR))
   THEN
     IF l_order_header_rec.order_category_code = 'RETURN' then
       SaveMDLRelatedOperations(p_context_type    => 'SAVE',
                              p_order_line_tbl  => l_order_line_tbl,
                              p_order_header_id => l_order_header_rec.header_id,
                              p_save_type       => p_save_type,
                              x_order_line_tbl  => lx_line_tbl
                             );

      for i in 1..lx_line_tbl.count
      loop
        l_order_line_tbl(i) := lx_line_tbl(i);
      end loop;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('LineTbl cnt returned from SAveMDL API:'||l_order_line_tbl.count);
      END IF;
     END IF;  -- order_category_code = 'RETURN' check
   END IF; -- main if for savemdlrel... call


/***************** Delete The Order When Last Item is Deleted bug#3272947 **************/

  IF (l_order_header_rec.order_category_code = 'RETURN'
      AND p_save_type = SAVE_REMOVEITEMS) THEN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('Inside Last Item Removal-Hard Delete If Loop');
   end if;

    for lineIdx in 1..l_order_line_tbl.count
    loop
       if(l_order_line_tbl(lineIdx).operation=OE_GLOBALS.G_OPR_DELETE) THEN
         p_dl_line_ids := p_dl_line_ids || ','||l_order_line_tbl(lineIdx).LINE_ID;
       end if;
    end loop;

   IBE_LEAD_IMPORT_PVT.parseInput (p_dl_line_ids, 'CHAR', l_parseKey, l_parseNum, l_dl_line_id_qry);

   l_dl_tmp_qry :=  'SELECT count(*) from oe_order_lines_all '||
                    'WHERE header_id= :dl_header_id '||
                    'AND line_id NOT IN('||l_dl_line_id_qry||')';

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('qry for finding if last item is removed: '|| l_dl_tmp_qry);
   end if;

   open l_dl_tmp for l_dl_tmp_qry using p_order_header_rec.header_id,l_parseKey;
   fetch l_dl_tmp into No_Of_ExistingLines;
   close l_dl_tmp;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.debug('No. Of lines Existing in the ReturnOrder: '|| l_dl_tmp_qry);
   end if;

   IF (No_Of_ExistingLines = 0) THEN -- No More Lines in The Return Order so can be hard deleted.
     CancelOrder(l_order_header_rec,lx_order_header_rec);
     l_order_header_rec := lx_order_header_rec;
     IF (IBE_UTIL.G_DEBUGON = l_true) then
       ibe_util.debug('after Remove-Cancelorder header_id:' ||l_order_header_rec.header_id);
       ibe_util.debug('after Remove-cancelorder operation:' ||l_order_header_rec.operation);
     end if;

     IF(l_order_header_rec.operation = OE_Globals.G_OPR_DELETE) THEN
       l_cancel_flow    := FND_API.G_TRUE;
       l_order_line_tbl := OE_ORDER_PUB.G_MISS_LINE_TBL;
     END IF;
   END IF; --No Of Existing Lines

 ENd If;  --Main If



 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_Util.Debug('Save:submit-control_rec.submit_flag ' || p_submit_control_rec.submit_flag);
 END IF;

 IF p_submit_control_rec.submit_flag = 'Y' THEN

    -- If it is 'post 11590' OE flow and if it is a Return:
    -- New, Submit_Order() API should be called for booking it.
    -- SO validate the qty, before calling submit_order().

    IF (IBE_UTIL.G_DEBUGON = l_true) then
     IBE_UTIL.DEBUG('order_category_code: ' ||l_order_header_rec.order_category_code );
     IBE_UTIL.DEBUG('OE-Get_Code_Release_Level ' || OE_CODE_CONTROL.Get_Code_Release_Level);
    end if;

    -- As per Bug# 3522453, a new profile is introduced to drive pre-booking approval
    -- flows. So check for flow_status_code if it is "WORKING", then go with
    -- validations flow; else if it is ENTERED, go with Process_Order() API call.
    -- So get the flow_status_code of the ReturnOrder to be submitted.


     Get_Order_Status(p_header_id        => l_order_header_rec.header_id
                     ,x_order_status     => l_flow_status_code
                     ,x_last_update_date => l_last_update_date);

     IF (IBE_UTIL.G_DEBUGON = l_true) then
       IBE_UTIL.DEBUG('SAVE - Pending Return flow_status_code: ' ||l_flow_status_code);
     end if;

     IF (l_order_header_rec.order_category_code = 'RETURN' AND
        l_flow_status_code = 'WORKING') THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Before Complete Validate API');
          END IF;

          Complete_RetOrder_Validate(
                  P_order_header_id   => l_order_header_rec.header_id
                 ,p_user_type         => l_user_type
                 ,X_failed_line_ids   => X_failed_line_ids
                 ,x_return_status     => x_return_status
                 ,x_msg_count         => x_msg_count
                 ,x_msg_data          => x_msg_data
                 );

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('After Complete Validate API: '|| x_return_status);
          END IF;

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            raise FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      -- For post 11590 flow, submit_order() flow would be called directly for booking.
      -- But for a b2c user, the header level values(invoice_to_org_id) would be
      -- populated for the return lines during submit flow.
      -- So Process_Order() should be called before submit_order().
      -- For B2B flow, submit_order() could be called directly.
      -- Checking whether it is a B2C flow.

          IF ((l_user_type = 'PERSON') AND
           (l_order_header_rec.operation = OE_Globals.G_OPR_UPDATE) AND
           (p_submit_control_rec.cancel_flag <> 'Y')) THEN

            l_ProcessOrder_Flow := FND_API.G_TRUE;
	  ELSIF ((l_user_type = 'PARTY_RELATIONSHIP') AND  -- b2b user
           (l_order_header_rec.operation = OE_Globals.G_OPR_UPDATE) AND
           (p_submit_control_rec.cancel_flag <> 'Y')) THEN

	   /* bug 8303137, scnagara, Added this condition  for a b2b user so that when quantity
	   is updated in Review and Submit return page, and Submit Return is clicked, quantity needs
	   to be saved to db */
	    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('B2b user - require update to be performed');
            END IF;
	    l_ProcessOrder_Flow := FND_API.G_TRUE;
          ELSE
            l_ProcessOrder_Flow := FND_API.G_FALSE;
          End If; --user_type ='Person'

    Else
      l_request_tbl(1).entity_code  := OE_GLOBALS.G_ENTITY_HEADER;
      l_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;
    End If;

 -- added the following for Bug 26561470
-- Testing the following flow

IF (l_order_header_rec.order_category_code = 'RETURN' AND
  l_flow_status_code = 'ENTERED') THEN


  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Bug 26561470 add check return qtybefore');
  end if;
  -- Now verify the Over Return Quantity
BEGIN


  CheckOverReturnQty(p_order_header_id => l_order_header_rec.header_id
                    ,x_qtyfail_LineIds => x_qtyfail_LineIds
                    ,x_return_status  => x_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
                     );

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('After Calling CheckOverRetQty');
      END IF;

--SETUP the test case
/*
x_return_status := FND_API.G_RET_STS_ERROR;
x_qtyfail_lineIds(1) := 'QTY:825712';
x_qtyfail_lineIds(2) := 'QTY:825713';
x_qtyfail_lineIds(3) := 'QTY:825714';
*/
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('No. of Lines failing after Qty validations:'|| x_qtyfail_LineIds.count);
         END IF;
         tCount := X_failed_Line_Ids.count;
         QtyFailLineCnt := x_qtyfail_LineIds.FIRST;

         while (QtyFailLineCnt IS NOT NULL)
         Loop
           X_failed_line_ids.extend(1);
           tCount := tCount+1;
           X_failed_line_ids(tCount) := x_qtyfail_LineIds(QtyFailLineCnt);
           QtyFailLineCnt := x_qtyfail_LineIds.NEXT(QtyFailLineCnt);
         end loop;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Total failLine Ids In final loop: '|| X_failed_line_ids.count);
           for k in 1..X_failed_line_ids.count
           loop
             IBE_Util.Debug('Total failLine Ids in final Loop: '|| X_failed_line_ids(k));
           end loop;
         END IF;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Bug26561470 Error 1');
         END IF;

         raise FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Total Failing LineCounts:'||tCount);
         END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug(' Total Failing LineCounts:'||tCount);
         END IF;

  -- If there are validation failing line IDs then set the status as ERROR.

      IF (X_failed_line_ids is not null AND X_failed_line_ids.count > 0) THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Bug26561470 Error 2');
         END IF;
         msgRewrite := true;
        raise FND_API.G_EXC_ERROR;

     ENd IF;


  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Bug 26561470 add check return qtyafter');
  end if;
/*
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:CheckOverReturn'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPError IBE_ORDER_SAVE_PVT:CheckOverREturn' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
       --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Other IBE_ORDER_SAVE_PVT:CheckOverREturn' || sqlerrm);
         END IF;
*/
END;
 END IF;
--TESTING THE FLOW END IF; --added the qty check for submitflag Y and Status Entered




  END IF;   -- booking submitflag='Y'

  -- bug# 3069333
  OE_STANDARD_WF.SAVE_MESSAGES_OFF;

  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('l_ProcessOrder_Flow: ' || l_ProcessOrder_Flow );
  end if;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Save  Before Process Order:order_hdr_rec.ship_to_org_id: ' || l_order_header_rec.SHIP_TO_ORG_ID);
       IBE_Util.Debug('Save  Bef Process Ord:order_hdr_rec.Invoice_to_org_id: ' || l_order_header_rec.INVOICE_TO_ORG_ID);
       IBE_Util.Debug('Save  Bef Process Ord:order_hdr_rec.header_id: ' || l_order_header_rec.HEADER_ID);
   END IF;

IF(FND_API.to_Boolean(l_ProcessOrder_Flow)) THEN

  /*************--call process order;--*****************/


  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Save - Before Calling Process_Order()');
  end if;

  OE_Order_GRP.Process_Order
  (   p_api_version_number        => 1.0
  ,   p_init_msg_list             => FND_API.G_TRUE
  ,   p_return_values             => l_return_values
  ,   p_commit                    => FND_API.G_FALSE
  ,   x_return_status             => x_return_status
  ,   x_msg_count                 => x_msg_count
  ,   x_msg_data                  => x_msg_data
--,   p_api_service_level         => p_api_service_level
  ,   p_header_rec                => l_order_header_rec
  ,   p_Header_Adj_tbl            => l_header_adj_tbl
  ,   p_Header_price_Att_tbl      => l_header_price_att_tbl
  ,   p_Header_Adj_Att_tbl        => l_header_adj_att_tbl
  ,   p_Header_Adj_Assoc_tbl      => l_header_adj_assoc_tbl
  ,   p_Header_Scredit_tbl        => l_header_scredit_tbl
  ,   p_line_tbl                  => l_order_line_tbl
  ,   p_Line_Adj_tbl              => l_line_adj_tbl
  ,   p_Line_price_Att_tbl        => l_line_price_att_tbl
  ,   p_Line_Adj_Att_tbl          => l_Line_Adj_Att_tbl
  ,   p_Line_Adj_Assoc_tbl        => l_line_adj_assoc_tbl
  ,   p_Line_Scredit_tbl          => l_line_scredit_tbl
  ,   p_Lot_Serial_tbl            => l_lot_serial_tbl
  ,   p_Action_Request_tbl        => l_request_tbl
  ,   x_header_rec                => lx_order_header_rec
  ,   x_header_val_rec            => l_header_val_rec
  ,   x_Header_Adj_tbl            => lx_header_adj_tbl
  ,   x_Header_Adj_val_tbl        => l_header_adj_val_tbl
  ,   x_Header_price_Att_tbl      => lx_header_price_att_tbl
  ,   x_Header_Adj_Att_tbl        => lx_header_adj_att_tbl
  ,   x_Header_Adj_Assoc_tbl      => lx_header_adj_assoc_tbl
  ,   x_Header_Scredit_tbl        => lx_header_scredit_tbl
  ,   x_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
  ,   x_line_tbl                  => lx_line_tbl
  ,   x_line_val_tbl              => l_line_val_tbl
  ,   x_Line_Adj_tbl              => lx_line_adj_tbl
  ,   x_Line_Adj_val_tbl          => l_line_adj_val_tbl
  ,   x_Line_price_Att_tbl        => lx_line_price_att_tbl
  ,   x_Line_Adj_Att_tbl          => lx_line_adj_att_tbl
  ,   x_Line_Adj_Assoc_tbl        => lx_line_adj_assoc_tbl
  ,   x_Line_Scredit_tbl          => lx_line_scredit_tbl
  ,   x_Line_Scredit_val_tbl      => l_line_scredit_val_tbl
  ,   x_Lot_Serial_tbl            => lx_lot_serial_tbl
  ,   x_Lot_Serial_val_tbl        => l_lot_serial_val_tbl
  ,   x_action_request_tbl        => l_action_request_tbl
 );

  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Save After Calling Process_Order() : ' || x_return_status);
    IBE_UTIL.DEBUG('header id from OE Save: ' || lx_order_header_rec.header_id);
  end if;

  for j in 1 .. x_msg_count
  loop
    x_msg_data:= OE_MSG_PUB.get(fnd_msg_pub.g_next,FND_API.G_FALSE);
    IF (IBE_UTIL.G_DEBUGON = l_true) then
     IBE_UTIL.DEBUG('Message from OE Save: ' || x_msg_data );
    end if;
  end loop;

  -- This check is for catching Booking Related Exceptions Only.
  -- In post 11590 flow, for B2c user, the process_order() would be called
  -- before submit_order(). So in the following if condition, the
  -- first 2 condns would be satisfied. But for the third condn.,
  -- l_action_request_tbl will be empty as we are not sending l_request_tbl()
  -- params above. So its safer to check for Exists and chk the return_status.


  IF ( (x_return_status = FND_API.G_RET_STS_SUCCESS
     AND p_submit_control_rec.submit_flag = 'Y'
        AND (l_action_request_tbl.EXISTS(1) AND
             l_action_request_tbl(1).return_status <> FND_API.G_RET_STS_SUCCESS)))
  THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) then
       IBE_UTIL.DEBUG('Error in ProcessOrder Booking Flow' );
IBE_UTIL.DEBUG('Bug 26561470 ' );

     end if;
IF (IBE_UTIL.G_DEBUGON = l_true) then

IBE_UTIL.DEBUG('Bug 26561470 before retrieve error' );

     end if;

IF (msgRewrite) THEN
  -- if qty error no retrieve OE message anymore
    IF (IBE_UTIL.G_DEBUGON = l_true) then

    IBE_UTIL.DEBUG('Bug 26561470 NONEED retrieve OE message' );
   end if;

    FND_MESSAGE.set_name('IBE', 'IBE_OM_ERROR');
    FND_MESSAGE.set_token('MSG_TXT', substr(x_msg_data,1, 240));
    FND_MSG_PUB.ADD;

else

    IF (IBE_UTIL.G_DEBUGON = l_true) then

    IBE_UTIL.DEBUG('Bug 26561470 NO QTYERROR retrieve OE message' );
   end if;

     retrieve_oe_messages;
END IF;
IF (IBE_UTIL.G_DEBUGON = l_true) then

IBE_UTIL.DEBUG('Bug 26561470 after retrieve error' );

     end if;

     x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE FND_API.G_EXC_ERROR;
  END IF;

 -- This check is for catching all generic Exceptions.
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
    IF (IBE_UTIL.G_DEBUGON = l_true) then
      IBE_UTIL.DEBUG('Error in Procees Order Flow: '||x_return_status );
    end if;
IF (IBE_UTIL.G_DEBUGON = l_true) then

IBE_UTIL.DEBUG('Bug 26561470 before retrieve error2' );

     end if;

    retrieve_oe_messages;
IF (IBE_UTIL.G_DEBUGON = l_true) then

IBE_UTIL.DEBUG('Bug 26561470 after retrieve error2' );

     end if;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

   x_order_header_id   := lx_order_header_rec.header_id;
   x_last_update_date  := lx_order_header_rec.last_update_date;
   x_order_number      := lx_order_header_rec.order_number;
   x_flow_status_code  := lx_order_header_rec.flow_status_code;

 END If;  --processOrderflow

  IF((p_submit_control_rec.submit_flag = 'Y')
      AND(l_order_header_rec.order_category_code = 'RETURN' AND
          l_flow_status_code = 'WORKING'))THEN

    IF (IBE_UTIL.G_DEBUGON = l_true) then
     IBE_UTIL.DEBUG('Before Calling OE_RMA_GRP.Submit_Order');
    end if;

    OE_RMA_GRP.Submit_Order( p_api_version   => 1.0
                          , p_header_id     => l_order_header_rec.header_id
                          , x_return_status => x_return_status
                          , x_msg_count     => x_msg_count
                          , x_msg_data      => x_msg_data);

    IF (IBE_UTIL.G_DEBUGON = l_true) then
     IBE_UTIL.DEBUG('After Calling Submit_Order - return_stats: '||x_return_status);
     IBE_UTIL.DEBUG('x_msg_count: '||x_msg_count);
    end if;

   --for logging appropriate error message
   if(x_msg_count is not null AND x_msg_count > 0) then
   for j in 1 .. x_msg_count
   loop
    x_msg_data:= OE_MSG_PUB.get(fnd_msg_pub.g_next,FND_API.G_FALSE);
    IF (IBE_UTIL.G_DEBUGON = l_true) then
     IBE_UTIL.DEBUG('Message from OE Save: ' || x_msg_data );
    end if;
   end loop;
   end if;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
      retrieve_oe_messages;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    x_order_header_id   := l_order_header_rec.header_id;

    -- We need to send back order_number and last_update_date back to UI.
    -- As OE is not sending these, we are populating.
    Declare
       cursor c_submit_hdrattr(sh_hdr_id number) is
         select order_number,last_update_date,flow_status_code
          from oe_order_headers_all where header_id=sh_hdr_id;
    Begin
       open c_submit_hdrattr(x_order_header_id);
       fetch c_submit_hdrattr into x_order_number,x_last_update_date,x_flow_status_code;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('order number after submit: ' || x_order_number );
       END IF;
       close c_submit_hdrattr;
    End;

 END If;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.DEBUG('header id returned from OE: ' || x_order_header_id );
   IBE_UTIL.DEBUG('x_flow_status_code: ' || x_flow_status_code );
   IBE_UTIL.DEBUG('calling ibe_active_quotes_all package handler: ' || l_cancel_flow);
 END IF;

  IF (FND_API.to_Boolean(l_cancel_flow)
  OR ((p_save_type = SAVE_NORMAL AND p_submit_control_rec.submit_flag = 'Y')
   --  AND (l_action_request_tbl(1).return_status = FND_API.G_RET_STS_SUCCESS)
  ))
  THEN
    DeactivateOrder(p_party_id,l_order_header_rec.sold_to_org_id,l_order_header_rec.transactional_curr_code);
  ELSE
    ActivateOrder(x_order_header_id,p_party_id,l_order_header_rec.sold_to_org_id,
                   l_order_header_rec.transactional_curr_code);
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('back from ibe_active_quotes_all package handler');
  END IF;

  -- Calling Notification to the user After successfully booking the order.
  -- This would send a notification to the user about the conformation of the Return.

  IF (p_save_type = SAVE_NORMAL AND p_submit_control_rec.submit_flag = 'Y') THEN

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('IBE_ORDER_SAVE_PVT: Before calling Notification API');
     END IF;

    IBE_WORKFLOW_PVT.NotifyReturnOrderStatus(
       p_api_version     => 1,
       p_party_id        => p_party_id,
       p_order_header_id => x_order_header_id,
       p_errmsg_count    => 0,
       p_errmsg_data     => NULL,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data
                     );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('IBE_ORDER_SAVE_PVT: Notification API is called');
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF; -- IF (p_save_type....)


   --
    -- End of API body
   --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End OE_ORDER_SAVE_PVT:Save)');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                             p_data  =>   x_msg_data);

 EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO SAVE_ORDER_SAVE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:Save()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVE_ORDER_SAVE_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDError IBE_ORDER_SAVE_PVT:Save()' || sqlerrm);
      END IF;
   WHEN OTHERS THEN
       ROLLBACK TO SAVE_ORDER_SAVE_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Other IBE_ORDER_SAVE_PVT:Save()' || sqlerrm);
         END IF;


END Save;

PROCEDURE CheckConstraint(
     p_api_version_number       IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,p_order_header_rec         IN  OE_Order_PUB.Header_Rec_Type
    ,p_order_line_tbl           IN  OE_Order_PUB.Line_Tbl_Type
    ,p_submit_control_rec       IN  IBE_Order_W1_PVT.Control_Rec_Type
    ,p_combine_same_lines       IN  VARCHAR2
    ,p_party_id                 IN  NUMBER
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,x_error_lineids            OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ,x_last_update_date         OUT NOCOPY DATE
    )
IS

 /***********  API Flow ***********/

 -- Refer Bug# 2988993 For Details
 -- Process_Order() would be called twice
 -- First Call, would create a Return Header without lines.
 -- Now the second call would use this SAme Header_id created in the first call.
 -- Next, set the Control Record and a new Header Record(l_retplcy_orderhdr_rec)
 -- with HEaderId created above and opcode 'UPDATE".
 -- Call Process_Order() API again, with l_retplcy_orderhdr_rec, ControlRec and
 -- Line_Table.
 -- This second call would set Api_Service_Level param as 'Check_Security_Only'.
 -- Second call check the Return Policy and send the failing LineIds back.
 -- Later when OM release bug# 2988993, then these 2 Porcess_Order() API call
 -- could be removed and HeaderRecord, LineTable and ControlRecord could be sent
 -- together in a Single Call.


l_order_header_rec            OE_Order_PUB.Header_Rec_Type  := OE_Order_PUB.G_MISS_HEADER_REC;
l_retplcy_orderhdr_rec        OE_Order_PUB.Header_Rec_Type  := OE_Order_PUB.G_MISS_HEADER_REC;
l_request_tbl                 OE_Order_PUB.Request_Tbl_Type := OE_Order_PUB.G_MISS_REQUEST_TBL;
l_order_line_tbl              OE_Order_PUB.Line_Tbl_Type    := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_header_val_rec              OE_Order_PUB.Header_Val_Rec_Type;
l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_line_val_tbl                OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_Action_Request_tbl          OE_Order_PUB.request_tbl_type :=OE_Order_PUB.g_miss_request_tbl;

lx_Header_Adj_tbl             OE_Order_PUB.Header_Adj_Tbl_Type;
lx_Header_price_Att_tbl       OE_Order_PUB.Header_Price_Att_Tbl_Type ;
lx_Header_Adj_Att_tbl         OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
lx_Header_Adj_Assoc_tbl       OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
lx_Header_Scredit_tbl         OE_Order_PUB.Header_Scredit_Tbl_Type;
lx_Line_Adj_tbl               OE_Order_PUB.Line_Adj_Tbl_Type;
lx_Line_price_Att_tbl         OE_Order_PUB.Line_Price_Att_Tbl_Type ;
lx_Line_Adj_Att_tbl           OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
lx_Line_Adj_Assoc_tbl         OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
lx_Line_Scredit_tbl           OE_Order_PUB.Line_Scredit_Tbl_Type;
lx_Lot_Serial_tbl             OE_Order_PUB.Lot_Serial_Tbl_Type;
lx_order_header_rec           OE_Order_PUB.Header_Rec_Type;
lx_line_tbl                   OE_Order_PUB.Line_Tbl_Type;

l_tmp_line_id                 varchar2(100) := '';
l_line_id                     number;
l_line_return_status          varchar2(10);
l_line_return_attr2           number;
l_return_values               varchar2(4000);
l_api_name                    VARCHAR2(100)     := 'Check Constraints';
l_api_version                 NUMBER := 1.0;

cursor c_get_lineInfo(l_lineId Number) is
    select * from oe_order_lines_all where line_id = l_lineId;

l_line_rec         OE_Order_PUB.Line_Rec_Type;
l_line_type_id     NUMBER;
l_siteuse_id       NUMBER;

TYPE Fail_TmpLineRec IS TABLE OF VARCHAR2(240)
  INDEX BY BINARY_INTEGER;

Fail_TmpLineRec_Tbl Fail_TmpLineRec;

l_count        NUMBER := 0;
l_salesrep_id  VARCHAR2(360);
l_order_type_id NUMBER;
l_commit VARCHAR2(10):=FND_API.G_FALSE;

l_salesrep_number  VARCHAR2(360); --MOAC Changes by ASO::Obsoletion of ASO_DEFAULT_PERSON_ID
l_user_orgid NUMBER;


BEGIN

 x_error_lineids := JTF_VARCHAR2_TABLE_300();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:CheckConstraints()');
  END IF;

  -- Standard Start of API savepoint
   SAVEPOINT    ORDER_CHKCONSTRAINT;

  -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        P_Api_Version_Number,
                                        l_api_name,
                                        G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean( p_init_msg_list ) THEN
     FND_Msg_Pub.initialize;
   END IF;

  --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Start OF API body --
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('In chkconstraint()');
   END IF;

 -- SET HEADER RECORD
  l_order_header_rec                 := p_order_header_rec;
  l_order_header_rec.operation       := OE_GLOBALS.G_OPR_CREATE;
--  l_order_header_rec.flow_status_code := 'ENTERED';
 --l_order_header_rec.ORDER_CATEGORY_CODE  := 'RETURN';
  l_order_type_id                    := FND_PROFILE.VALUE('IBE_RETURN_TRANSACTION_TYPE');

  IF (l_order_type_id is null) THEN
    FND_Message.Set_Name('IBE', 'IBE_ERR_OT_ORDER_TYPE_ID_MISS');
    FND_Msg_Pub.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    l_order_header_rec.order_type_id   := l_order_type_id;
  END IF;

  -- Get the User's Session ORG_ID
  l_user_orgid := mo_global.GET_CURRENT_ORG_ID();
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('Current Org id : ' ||l_user_orgid);
  END IF;

  -- Get the Sales Rep Number from the ASO Utility package
  l_salesrep_number := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(aso_utility_pvt.GET_DEFAULT_SALESREP,l_user_orgid);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('Sales Rep Number for Current Org : ' ||l_salesrep_number);
  END IF;

  -- Bug 5359687, Proper error message when default salesrep is not set
  IF (l_salesrep_number is null) THEN
      FND_Message.Set_Name('IBE', 'IBE_ERR_OT_SALESREPID_MISS');
      FND_Msg_Pub.Add;
      RAISE FND_API.G_EXC_ERROR;
  ELSE
      -- Get the sales rep id from the sales rep number using the JTF table
       select SALESREP_ID into l_salesrep_id from JTF_RS_SALESREPS where SALESREP_NUMBER = l_salesrep_number and ORG_ID = l_user_orgid;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.Debug('Sales Rep Id : ' ||l_salesrep_id);
  END IF;

  --l_salesrep_id := FND_PROFILE.VALUE('ASO_DEFAULT_PERSON_ID');

  IF (l_salesrep_id is null) THEN
    FND_Message.Set_Name('IBE', 'IBE_ERR_OT_SALESREPID_MISS');
    FND_Msg_Pub.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
  --Modified for bug 22542852
   -- l_order_header_rec.salesrep_id     := l_salesrep_id;
   l_order_header_rec.salesrep_id := FND_API.G_MISS_NUM;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.Debug('22542852--printing default salesrep-inside checkconstraint' || l_order_header_rec.salesrep_id);
     END IF;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('chkconstraint-l_order_header_rec.header_id:' || l_order_header_rec.header_id);
   IBE_Util.Debug('chkconstraint-l_order_header_rec.sold_to_org_id:' || l_order_header_rec.sold_to_org_id);
   IBE_Util.Debug('chkconstraint-l_order_header_rec.operation:' || l_order_header_rec.operation);
   IBE_Util.Debug('chkconstraint-l_order_header_rec.order_type_id:' || l_order_header_rec.order_type_id);
  END IF;


  -- SET LINE RECORD
  FOR i in 1..p_order_line_tbl.COUNT
  LOOP
   l_order_line_tbl(i) := p_order_line_tbl(i);

   DefaultLineTypes(l_order_header_rec.order_type_id,l_line_type_id);
   l_order_line_tbl(i).line_type_id     := l_line_type_id;

   if(l_order_header_rec.order_category_code = 'RETURN') then
     l_order_line_tbl(i).line_category_code := 'RETURN';
     l_order_line_tbl(i).return_context     := 'ORDER';
   end if;

   l_order_line_tbl(i).operation := OE_GLOBALS.G_OPR_CREATE;


   -- ShipTo / InvoiceTo OrgIds.
   -- line level will always be defaulted from original order lines.

   for l_line_rec in c_get_lineInfo(l_order_line_tbl(i).return_attribute2)
   loop
     l_order_line_tbl(i).ship_to_org_id    := l_line_rec.SHIP_TO_ORG_ID;
     l_order_line_tbl(i).invoice_to_org_id := l_line_rec.INVOICE_TO_ORG_ID;
   end loop;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('chkconstraint-l_order_line_tbl.lineId: ' || l_order_line_tbl(i).line_id);
    IBE_Util.Debug('chkconstraint-l_order_line_tbl.linetypeid: ' || l_order_line_tbl(i).line_type_id);
    IBE_Util.Debug('chkconstraint-l_order_line_tbl.shiptoOrgid: ' || l_order_line_tbl(i).ship_to_org_id);
    IBE_Util.Debug('chkconstraint-l_order_line_tbl.invoicetoOrgid: ' || l_order_line_tbl(i).invoice_to_org_id);
   END IF;

 END LOOP;

  -- Header Level shipTo /InvoiceTo org ids

  DefaultFromLineSiteId(l_order_line_tbl,p_party_id,'SHIP_TO',l_siteuse_id);
   l_order_header_rec.ship_to_org_id          := l_siteuse_id;
  DefaultFromLineSiteId(l_order_line_tbl,p_party_id,'INVOICE_TO',l_siteuse_id);
   l_order_header_rec.invoice_to_org_id       := l_siteuse_id;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('Chkconsrnt-l_order_header_rec.shiporgid: ' || l_order_header_rec.ship_to_org_id);
   IBE_Util.Debug('Chkconsrnt-l_order_header_rec.invoiceorgid: ' || l_order_header_rec.invoice_to_org_id);
  END IF;

 -- FIRST CALL To Process_Order to create only the Header Record. Bug#2988993
 -- This would avoid the NoDataFound thrown from OM as reported in the bug.

 OE_Order_GRP.Process_Order
 (   p_api_version_number        => 1.0
 ,   p_init_msg_list             => FND_API.G_TRUE
 ,   p_return_values             => l_return_values
 ,   p_commit                    => FND_API.G_FALSE
 ,   x_return_status             => x_return_status
 ,   x_msg_count                 => x_msg_count
 ,   x_msg_data                  => x_msg_data
 ,   p_control_rec               => l_control_rec
 ,   p_header_rec                => l_order_header_rec
 ,   p_Action_Request_tbl        => l_request_tbl
 ,   x_header_rec                => lx_order_header_rec
 ,   x_header_val_rec            => l_header_val_rec
 ,   x_Header_Adj_tbl            => lx_header_adj_tbl
 ,   x_Header_Adj_val_tbl        => l_header_adj_val_tbl
 ,   x_Header_price_Att_tbl      => lx_header_price_att_tbl
 ,   x_Header_Adj_Att_tbl        => lx_header_adj_att_tbl
 ,   x_Header_Adj_Assoc_tbl      => lx_header_adj_assoc_tbl
 ,   x_Header_Scredit_tbl        => lx_header_scredit_tbl
 ,   x_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
 ,   x_line_tbl                  => lx_line_tbl
 ,   x_line_val_tbl              => l_line_val_tbl
 ,   x_Line_Adj_tbl              => lx_line_adj_tbl
 ,   x_Line_Adj_val_tbl          => l_line_adj_val_tbl
 ,   x_Line_price_Att_tbl        => lx_line_price_att_tbl
 ,   x_Line_Adj_Att_tbl          => lx_line_adj_att_tbl
 ,   x_Line_Adj_Assoc_tbl        => lx_line_adj_assoc_tbl
 ,   x_Line_Scredit_tbl          => lx_line_scredit_tbl
 ,   x_Line_Scredit_val_tbl      => l_line_scredit_val_tbl
 ,   x_Lot_Serial_tbl            => lx_lot_serial_tbl
 ,   x_Lot_Serial_val_tbl        => l_lot_serial_val_tbl
 ,   x_action_request_tbl        => l_action_request_tbl
 );

IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_UTIL.DEBUG('Return Status of First-Call to Process_Order() : ' || x_return_status);
    IBE_UTIL.DEBUG('header id from OE: ' || lx_order_header_rec.header_id);
end if;

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
   retrieve_oe_messages;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    raise FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
END IF;

 --SET HEADER RECORD
  l_retplcy_orderhdr_rec.header_id := lx_order_header_rec.header_id;
  l_retplcy_orderhdr_rec.operation := OE_Globals.G_OPR_UPDATE;

 -- SET CONTROL RECORD
   l_control_rec.controlled_operation := TRUE;
   l_control_rec.process_partial      := TRUE;

   -- PLEASE NOTE:
   -- process_partial should be TRUE.
   -- If FALSE, when in case if first line fails for Return Policy then all the
   -- following lines are also sent back as failing Lines from OM

 FOR i in 1..l_order_line_tbl.COUNT
 LOOP
   l_order_line_tbl(i).header_id := lx_order_header_rec.header_id;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_order_line_tbl.lineId: ' || l_order_line_tbl(i).line_id);
      IBE_Util.Debug('l_order_line_tbl.HEaderId: ' || l_order_line_tbl(i).header_id);
      IBE_Util.Debug('l_order_line_tbl.retattr1: ' || l_order_line_tbl(i).return_attribute1);
      IBE_Util.Debug('l_order_line_tbl.retattr2: ' || l_order_line_tbl(i).return_attribute2);
      IBE_Util.Debug('l_order_line_tbl.retcontxt: ' || l_order_line_tbl(i).return_context);
      IBE_Util.Debug('l_order_line_tbl.linetypeid: ' || l_order_line_tbl(i).line_type_id);
      IBE_Util.Debug('l_order_line_tbl.operation: ' || l_order_line_tbl(i).operation);
      IBE_Util.Debug('l_order_line_tbl.shiptoOrgid: ' || l_order_line_tbl(i).ship_to_org_id);
      IBE_Util.Debug('l_order_line_tbl.invoicetoOrgid: ' || l_order_line_tbl(i).invoice_to_org_id);
    END IF;
 END LOOP;


 -- Now call Process_Order API for Policy check.

 OE_Order_GRP.Process_Order
 (   p_api_version_number        => 1.0
 ,   p_init_msg_list             => FND_API.G_TRUE
 ,   p_return_values             => l_return_values
 ,   p_commit                    => FND_API.G_FALSE
 ,   x_return_status             => x_return_status
 ,   x_msg_count                 => x_msg_count
 ,   x_msg_data                  => x_msg_data
 ,   p_api_service_level         => OE_GLOBALS.G_CHECK_SECURITY_ONLY
 ,   p_control_rec               => l_control_rec
 ,   p_header_rec                => l_retplcy_orderhdr_rec
 ,   p_line_tbl                  => l_order_line_tbl
 ,   p_Action_Request_tbl        => l_request_tbl
 ,   x_header_rec                => lx_order_header_rec
 ,   x_header_val_rec            => l_header_val_rec
 ,   x_Header_Adj_tbl            => lx_header_adj_tbl
 ,   x_Header_Adj_val_tbl        => l_header_adj_val_tbl
 ,   x_Header_price_Att_tbl      => lx_header_price_att_tbl
 ,   x_Header_Adj_Att_tbl        => lx_header_adj_att_tbl
 ,   x_Header_Adj_Assoc_tbl      => lx_header_adj_assoc_tbl
 ,   x_Header_Scredit_tbl        => lx_header_scredit_tbl
 ,   x_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
 ,   x_line_tbl                  => lx_line_tbl
 ,   x_line_val_tbl              => l_line_val_tbl
 ,   x_Line_Adj_tbl              => lx_line_adj_tbl
 ,   x_Line_Adj_val_tbl          => l_line_adj_val_tbl
 ,   x_Line_price_Att_tbl        => lx_line_price_att_tbl
 ,   x_Line_Adj_Att_tbl          => lx_line_adj_att_tbl
 ,   x_Line_Adj_Assoc_tbl        => lx_line_adj_assoc_tbl
 ,   x_Line_Scredit_tbl          => lx_line_scredit_tbl
 ,   x_Line_Scredit_val_tbl      => l_line_scredit_val_tbl
 ,   x_Lot_Serial_tbl            => lx_lot_serial_tbl
 ,   x_Lot_Serial_val_tbl        => l_lot_serial_val_tbl
 ,   x_action_request_tbl        => l_action_request_tbl
 );

 x_error_lineids := JTF_VARCHAR2_TABLE_300();

 for j in 1..lx_line_tbl.count
 loop
    l_line_id            := lx_line_tbl(j).line_id;
    l_line_return_status := lx_line_tbl(j).return_status;
    l_line_return_attr2  := lx_line_tbl(j).return_attribute2;

    If(l_line_return_status <> 'S')then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('line id returned from OE' || l_line_id );
         IBE_UTIL.DEBUG('return status returned from OE' || l_line_return_status);
         IBE_UTIL.DEBUG('return attribute2 returned from OE' || l_line_return_attr2);
       END IF;

       l_count := l_count + 1;
       Fail_TmpLineRec_Tbl(l_count) := lx_line_tbl(j).return_attribute2;
    end if;
 end loop;

 l_count := Fail_TmpLineRec_Tbl.count;
 if (l_count > 0) then
   x_error_lineids.extend(l_count);
   for k in 1..l_count
   loop
   null;
     x_error_lineids(k) := Fail_TmpLineRec_Tbl(k);
   end loop;
 end if;

 IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_Util.debug('ChkConstraint Error Messages count: ' || x_msg_count ||' : '||x_return_status);
  end if;

 for j in 1 .. x_msg_count
 loop
  x_msg_data:= OE_MSG_PUB.get(fnd_msg_pub.g_next,FND_API.G_FALSE);
  IF (IBE_UTIL.G_DEBUGON = l_true) then
    IBE_Util.debug('Chk Constraint Exception Message' || x_msg_data);
  end if;
 end loop;

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
    retrieve_oe_messages;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          raise FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
 END IF;

   --
   -- End of API body
   --
   -- Bug#2988993
   -- As the First Process_Order() API call would create an Order Header Record,
   -- This Rollback is a must.

   ROLLBACK TO ORDER_CHKCONSTRAINT;
   l_commit := p_commit;

   -- Standard check for p_commit
   IF FND_API.to_Boolean(l_commit)
   THEN
     COMMIT WORK;
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End OE_ORDER_SAVE_PVT:CHECKCONSTRAINT()');
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ORDER_CHKCONSTRAINT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:CHECKCONSTRAINT()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ORDER_CHKCONSTRAINT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDError IBE_ORDER_SAVE_PVT:CHECKCONSTRAINT()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO ORDER_CHKCONSTRAINT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Other IBE_ORDER_SAVE_PVT:CHECKCONSTRAINT()' || sqlerrm);
         END IF;

END CheckConstraint;


PROCEDURE UpdateLineShippingBilling(
     p_api_version_number       IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
    ,p_order_header_id          IN NUMBER
    ,p_order_line_id            IN NUMBER
    ,p_billto_party_id          IN NUMBER
    ,p_billto_cust_acct_id      IN NUMBER
    ,p_billto_party_site_id     IN NUMBER
    ,p_shipto_party_id          IN NUMBER
    ,p_shipto_cust_acct_id      IN NUMBER
    ,p_shipto_party_site_id     IN NUMBER
    ,p_last_update_date         IN DATE
    )
IS

--l_acct_siteuse_id  NUMBER := null;
l_billto_acct_siteuse_id  NUMBER := null;
l_shipto_acct_siteuse_id  NUMBER := null;
l_return_values    varchar2(2000);
l_api_version      NUMBER := 1.0;
l_api_name         VARCHAR2(30) := 'ORDER_UPDATELINEBILL';

l_order_header_rec            OE_Order_PUB.Header_Rec_Type  := OE_Order_PUB.G_MISS_HEADER_REC;
l_order_line_tbl              OE_Order_PUB.Line_Tbl_Type    := OE_ORDER_PUB.G_MISS_LINE_TBL;
l_request_tbl                 OE_Order_PUB.Request_Tbl_Type := OE_Order_PUB.G_MISS_REQUEST_TBL;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_header_val_rec              OE_Order_PUB.Header_Val_Rec_Type;
l_header_scredit_val_tbl      OE_Order_PUB.Header_Scredit_Val_Tbl_Type;
l_header_adj_val_tbl          OE_Order_PUB.Header_Adj_Val_Tbl_Type;
l_line_val_tbl                OE_Order_PUB.Line_Val_Tbl_Type;
l_line_adj_val_tbl            OE_Order_PUB.Line_Adj_Val_Tbl_Type;
l_line_scredit_val_tbl        OE_Order_PUB.Line_Scredit_Val_Tbl_Type;
l_lot_serial_val_tbl          OE_Order_PUB.Lot_Serial_Val_Tbl_Type;
l_Action_Request_tbl          OE_Order_PUB.request_tbl_type :=OE_Order_PUB.g_miss_request_tbl;

lx_Header_Adj_tbl             OE_Order_PUB.Header_Adj_Tbl_Type;
lx_Header_price_Att_tbl       OE_Order_PUB.Header_Price_Att_Tbl_Type ;
lx_Header_Adj_Att_tbl         OE_Order_PUB.Header_Adj_Att_Tbl_Type ;
lx_Header_Adj_Assoc_tbl       OE_Order_PUB.Header_Adj_Assoc_Tbl_Type ;
lx_Header_Scredit_tbl         OE_Order_PUB.Header_Scredit_Tbl_Type;
lx_Line_Adj_tbl               OE_Order_PUB.Line_Adj_Tbl_Type;
lx_Line_price_Att_tbl         OE_Order_PUB.Line_Price_Att_Tbl_Type ;
lx_Line_Adj_Att_tbl           OE_Order_PUB.Line_Adj_Att_Tbl_Type ;
lx_Line_Adj_Assoc_tbl         OE_Order_PUB.Line_Adj_Assoc_Tbl_Type ;
lx_Line_Scredit_tbl           OE_Order_PUB.Line_Scredit_Tbl_Type;
lx_Lot_Serial_tbl             OE_Order_PUB.Lot_Serial_Tbl_Type;
lx_order_header_rec           OE_Order_PUB.Header_Rec_Type;
lx_line_tbl                   OE_Order_PUB.Line_Tbl_Type;
--l_siteuse_type                VARCHAR2(20);
l_siteuse_billto			  VARCHAR2(20);
l_siteuse_shipto			  VARCHAR2(20);
l_cust_acct_role_id           NUMBER;
l_flow_status_code            VARCHAR2(30);
l_last_update_date            DATE;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_ORDER_SAVE_PVT:UpdateLinebilling()');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT    ORDER_UPDTLINEBILL;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean( p_init_msg_list ) THEN
      FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Start OF API body --

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Calling Validate Order Access');
  END IF;

 /********** User Authentication *************/

 IF (p_order_header_id is not null AND
     p_order_header_id <> FND_API.G_MISS_NUM)
 THEN
   ValidateOrderAccess(p_order_header_id        => p_order_header_id
                      ,x_return_status          => x_return_status
                      );
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         raise FND_API.G_EXC_ERROR;
   END IF;
 END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    Ibe_util.Debug('checking the Return status');
   END IF;


   Get_Order_Status(p_header_id        => p_order_header_id
                   ,x_order_status     => l_flow_status_code
                   ,x_last_update_date => l_last_update_date);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     Ibe_util.Debug('last_update_date sent from ui: '||p_last_update_date);
     Ibe_util.Debug('last_update_date from db: '||l_last_update_date);
     Ibe_util.Debug('l_flow_status_code: '||l_flow_status_code);
   END IF;

  IF ((l_flow_status_code = 'BOOKED' OR l_flow_status_code='CLOSED' OR
        l_flow_status_code = 'CANCELLED')
       OR l_last_update_date > p_last_update_date)
       THEN
          FND_Message.Set_Name('IBE', 'IBE_ERR_OT_REFRESH_RETURN');
          FND_Msg_Pub.Add;
          RAISE FND_API.G_EXC_ERROR;
  END IF;


   IF (p_billto_cust_acct_id is not null AND p_billto_cust_acct_id <> FND_API.G_MISS_NUM
   AND p_billto_party_site_id is not null AND p_billto_party_site_id <> FND_API.G_MISS_NUM)
   THEN
     --l_siteuse_type := 'BILL_TO';
	 l_siteuse_billto := 'BILL_TO';
   END IF;

   IF (p_shipto_cust_acct_id is not null AND p_shipto_cust_acct_id <> FND_API.G_MISS_NUM
   AND p_shipto_party_site_id is not null AND p_shipto_party_site_id <> FND_API.G_MISS_NUM)
   THEN
     --l_siteuse_type := 'SHIP_TO';
     l_siteuse_shipto := 'SHIP_TO';
   END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('UpdateLinebilling-l_siteuse_billto: '||l_siteuse_billto||' : l_siteuse_shipto: '||l_siteuse_shipto);
  END IF;

   -- Fetching Invoice To Org Id.

   if(l_siteuse_billto = 'BILL_TO') then

      IBE_CUSTOMER_ACCT_PVT.Get_Cust_Account_Site_Use(
                                p_cust_acct_id   => p_billto_cust_acct_id
                               ,p_party_id       => p_billto_party_id
                               ,p_siteuse_type   => l_siteuse_billto
                               ,p_partysite_id   => p_billto_party_site_id
                               ,x_siteuse_id     => l_billto_acct_siteuse_id
                               ,x_return_status  => x_return_status
                               ,x_msg_count      => x_msg_count
                               ,x_msg_data       => x_msg_data
                              );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('UpdateLinebilling- Get_Cust_Account_Site_Use() fails raise exception');
        END IF;

        FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_BILLTO_ADDR');
        FND_Msg_Pub.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UpdateLinebilling-l_acct_siteuse_id: ' || l_billto_acct_siteuse_id);
      END IF;
   end if;

   if(l_siteuse_shipto = 'SHIP_TO') then

      IBE_CUSTOMER_ACCT_PVT.Get_Cust_Account_Site_Use(
                                p_cust_acct_id   => p_shipto_cust_acct_id
                               ,p_party_id       => p_shipto_party_id
                               ,p_siteuse_type   => l_siteuse_shipto
                               ,p_partysite_id   => p_shipto_party_site_id
                               ,x_siteuse_id     => l_shipto_acct_siteuse_id
                               ,x_return_status  => x_return_status
                               ,x_msg_count      => x_msg_count
                               ,x_msg_data       => x_msg_data
                              );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('UpdateLinebilling- Get_Cust_Account_Site_Use() fails raise exception');
         END IF;

         FND_Message.Set_Name('IBE', 'IBE_ERR_OT_INVALID_SHIPTO_ADDR');
          FND_Msg_Pub.Add;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('UpdateLinebilling-l_acct_siteuse_id: ' || l_shipto_acct_siteuse_id);
       END IF;

   end if;

   l_order_header_rec.header_id := p_order_header_id;
   l_order_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
   l_order_line_tbl(1)           := OE_Order_PUB.G_MISS_LINE_REC;
   l_order_line_tbl(1).header_id := p_order_header_id;
   l_order_line_tbl(1).operation := OE_GLOBALS.G_OPR_UPDATE;
   l_order_line_tbl(1).line_id   := p_order_line_id;

   if(l_siteuse_billto = 'BILL_TO') then
     l_order_line_tbl(1).invoice_to_org_id := l_billto_acct_siteuse_id;
   end if;
   if(l_siteuse_shipto = 'SHIP_TO') then
     l_order_line_tbl(1).ship_to_org_id := l_shipto_acct_siteuse_id;
   end if;

   -- Fetching InvoiceToContactId
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('billto_ party_id :: billto_custacct_id: '||p_billto_party_id||' :: '||p_billto_cust_acct_id);
   END IF;

   If(p_billto_party_id is not null AND
      p_billto_party_id <> FND_API.G_MISS_NUM AND
      l_siteuse_billto = 'BILL_TO') then

      IBE_CUSTOMER_ACCT_PVT.Get_Cust_Acct_Role(
                           p_party_id            => p_billto_party_id
                          ,p_acctsite_type       => 'BILL_TO'
                          ,p_sold_to_orgid       => p_billto_cust_acct_id
                          ,p_custacct_siteuse_id => l_order_line_tbl(1).invoice_to_org_id
                          ,x_cust_acct_role_id   => l_cust_acct_role_id
                          ,x_return_status       => x_return_status
                          ,x_msg_count           => x_msg_count
                          ,x_msg_data            => x_msg_data
                        );

      l_order_line_tbl(1).invoice_to_contact_id := l_cust_acct_role_id;
   end if;

   if(p_shipto_party_id is not null AND
      p_shipto_party_id <> FND_API.G_MISS_NUM AND
      l_siteuse_shipto = 'SHIP_TO') then

      IBE_CUSTOMER_ACCT_PVT.Get_Cust_Acct_Role(
                           p_party_id            => p_shipto_party_id
                          ,p_acctsite_type       => 'SHIP_TO'
                          ,p_sold_to_orgid       => p_shipto_cust_acct_id
                          ,p_custacct_siteuse_id => l_order_line_tbl(1).ship_to_org_id
                          ,x_cust_acct_role_id   => l_cust_acct_role_id
                          ,x_return_status       => x_return_status
                          ,x_msg_count           => x_msg_count
                          ,x_msg_data            => x_msg_data
                         );
      l_order_line_tbl(1).ship_to_contact_id := l_cust_acct_role_id;
   end if;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Line Id: '||l_order_line_tbl(1).line_id);
     IBE_Util.Debug('Line operation: ' ||l_order_line_tbl(1).operation);
     IBE_Util.Debug('Line invoiceToOrgId: ' ||l_order_line_tbl(1).invoice_to_org_id);
     IBE_Util.Debug('Line InvoiceToContactId: '||l_order_line_tbl(1).invoice_to_contact_id);
   ENd If;

   SaveMDLRelatedOperations(p_context_type    => 'UPDATELINES',
                           p_order_line_tbl  => l_order_line_tbl,
                           p_order_header_id => p_order_header_id,
                           x_order_line_tbl  => lx_line_tbl
                           );

    for i in 1..lx_line_tbl.count
    loop
      l_order_line_tbl(i) := lx_line_tbl(i);
    end loop;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('UpdateLine Linetbl cnt b4 processOrder '||l_order_line_tbl.count);
       IBE_Util.Debug('check this: '||l_order_line_tbl(1).LINE_ID);
              IBE_Util.Debug('check this: '||l_order_line_tbl(1).INVOICE_TO_ORG_ID);
                    IBE_Util.Debug('check this: '||l_order_line_tbl(1).INVOICE_TO_CONTACT_ID);
                  IBE_Util.Debug('check this: '||l_order_line_tbl(1).SHIP_TO_ORG_ID);
                IBE_Util.Debug('check this: '||l_order_line_tbl(1).SHIP_TO_CONTACT_ID);
             IBE_Util.Debug('check this: '||l_order_line_tbl(1).OPERATION);
    END IF;

   -- Calling Process Order
    OE_Order_GRP.Process_Order
    (   p_api_version_number        => 1.0
    ,   p_init_msg_list             => FND_API.G_TRUE
    ,   p_return_values             => l_return_values
    ,   p_commit                    => FND_API.G_FALSE
    ,   x_return_status             => x_return_status
    ,   x_msg_count                 => x_msg_count
    ,   x_msg_data                  =>  x_msg_data
    ,   p_control_rec               => l_control_rec
    ,   p_header_rec                => l_order_header_rec
    ,   p_line_tbl                  => l_order_line_tbl
    ,   p_Action_Request_tbl        => l_request_tbl
    ,   x_header_rec                => lx_order_header_rec
    ,   x_header_val_rec            => l_header_val_rec
    ,   x_Header_Adj_tbl            => lx_header_adj_tbl
    ,   x_Header_Adj_val_tbl        => l_header_adj_val_tbl
    ,   x_Header_price_Att_tbl      => lx_header_price_att_tbl
    ,   x_Header_Adj_Att_tbl        => lx_header_adj_att_tbl
    ,   x_Header_Adj_Assoc_tbl      => lx_header_adj_assoc_tbl
    ,   x_Header_Scredit_tbl        => lx_header_scredit_tbl
    ,   x_Header_Scredit_val_tbl    => l_header_scredit_val_tbl
    ,   x_line_tbl                  => lx_line_tbl
    ,   x_line_val_tbl              => l_line_val_tbl
    ,   x_Line_Adj_tbl              => lx_line_adj_tbl
    ,   x_Line_Adj_val_tbl          => l_line_adj_val_tbl
    ,   x_Line_price_Att_tbl        => lx_line_price_att_tbl
    ,   x_Line_Adj_Att_tbl          => lx_line_adj_att_tbl
    ,   x_Line_Adj_Assoc_tbl        => lx_line_adj_assoc_tbl
    ,   x_Line_Scredit_tbl          => lx_line_scredit_tbl
    ,   x_Line_Scredit_val_tbl      => l_line_scredit_val_tbl
    ,   x_Lot_Serial_tbl            => lx_lot_serial_tbl
    ,   x_Lot_Serial_val_tbl        => l_lot_serial_val_tbl
    ,   x_action_request_tbl        => l_action_request_tbl
 );

 IF (IBE_UTIL.G_DEBUGON = l_true) then
   IBE_UTIL.DEBUG('Return status from OE updatelinebill: ' || x_return_status);
   IBE_UTIL.DEBUG('header id from OE updatelinebill: ' || lx_order_header_rec.header_id);
 end if;

 for j in 1 .. x_msg_count
 loop
   x_msg_data:= OE_MSG_PUB.get(fnd_msg_pub.g_next,FND_API.G_FALSE);
   IF (IBE_UTIL.G_DEBUGON = l_true) then
     IBE_UTIL.DEBUG('Message from OE update line bill: ' || x_msg_data );
   end if;
 end loop;

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
    retrieve_oe_messages;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        raise FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
 END IF;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
     COMMIT WORK;
   END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End IBE_ORDER_SAVE_PVT:UpdateLinebilling()');
  END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get ( p_count =>   x_msg_count,
                               p_data  =>   x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ORDER_UPDTLINEBILL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Error IBE_ORDER_SAVE_PVT:UpdateLineShippingBilling()'|| sqlerrm);
      END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ORDER_UPDTLINEBILL;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('UNEXPECTEDErr IBE_ORDER_SAVE_PVT:UpdateLineShippingBilling()' || sqlerrm);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO ORDER_UPDTLINEBILL;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
       END IF;

       FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('OtherExc IBE_ORDER_SAVE_PVT:UpdateLineShippingBilling()' || sqlerrm);
         END IF;

END UpdateLineShippingBilling;

END IBE_Order_Save_pvt;

/
