--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_SAVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_SAVE_PVT" AS
/* $Header: IBEVQCUB.pls 120.46.12010000.26 2018/04/11 09:47:21 amaheshw ship $ */
-- Start of Comments
-- Package name     : IBE_Quote_Save_pvt
-- Purpose          :--DBMS_PUT.PUT_line(' ');
-- NOTE             :
-- End of Comments

l_true VARCHAR2(1)                := FND_API.G_TRUE;
G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_Quote_Save_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVQCUB.pls';

FUNCTION Compare(
  p_qte_line_tbl_service          IN  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,p_qte_line_dtl_tbl_service     IN  ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type
  ,p_qte_line_tbl_service_db      IN  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,p_qte_line_dtl_tbl_service_db  IN  ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type
) RETURN varchar2
IS
  l_qte_line_rec      ASO_Quote_Pub.Qte_Line_Rec_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_rec;

  l_same             varchar2(1) := 'N';
  l_found            varchar2(1) := 'N';
  l_index            number      := 1;
BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('compare: p_qte_line_tbl_service.count'
                  || p_qte_line_tbl_service.count);
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('compare: p_qte_line_tbl_service_db.count'
                 || p_qte_line_tbl_service_db.count);
  END IF;
  IF p_qte_line_tbl_service.count = p_qte_line_tbl_service_db.count THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug(' start compare: ');
    END IF;
    FOR i in 1..p_qte_line_tbl_service.count LOOP
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('compare: line i='||i);
        END IF;
        l_found := 'N';
        l_index :=1;
        WHILE l_found= 'N' and l_index <= p_qte_line_tbl_service_db.count
        LOOP

         IF p_qte_line_tbl_service(i).inventory_item_id
                    = p_qte_line_tbl_service_db(l_index).inventory_item_id
             and p_qte_line_tbl_service(i).organization_id
                    = p_qte_line_tbl_service_db(l_index).organization_id
          THEN
             l_found := 'Y';

          END IF;
          l_index := l_index+1;
        END LOOP;
        IF l_found = 'N' THEN
          l_same := 'N';
          return l_same;
        END IF;
        l_same := 'Y';
    END LOOP;

   FOR i IN 1..p_qte_line_dtl_tbl_service.count
   LOOP
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('compare: detail line i='||i);
        END IF;
        l_found := 'N';
        l_index :=1;
        WHILE l_found= 'N' and l_index <= p_qte_line_dtl_tbl_service_db.count
        LOOP
          IF p_qte_line_dtl_tbl_service(i).SERVICE_DURATION
                     = p_qte_line_dtl_tbl_service_db(l_index).service_duration
             and p_qte_line_dtl_tbl_service(i).service_period
                    = p_qte_line_dtl_tbl_service_db(l_index).service_period
          THEN
             l_found := 'Y';

          END IF;
          l_index := l_index +1;
        END LOOP;
        IF l_found = 'N' THEN
          l_same := 'N';
          return l_same;
        END IF;
        l_same := 'Y';
    END LOOP;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('compare: before return l_same = '||l_same);
  END IF;

  RETURN l_same;
END compare;


FUNCTION getLinetblfromdb(
  p_quote_header_id     IN NUMBER
  ,p_qte_line_rec       ASO_Quote_Pub.Qte_Line_Rec_Type
) RETURN  ASO_Quote_Pub.Qte_Line_tbl_Type
IS

  l_qte_line_rec      ASO_Quote_Pub.Qte_Line_Rec_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_rec;

  l_qte_line_tbl      ASO_Quote_Pub.Qte_Line_tbl_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_tbl;

  cursor c_getlineinfo(p_quote_header_id number, l_inventory_item_id number)
  is
  select quote_line_id, item_type_code ,quantity, inventory_item_id
  from aso_quote_lines
  where quote_header_id = p_quote_header_id
  and inventory_item_id = l_inventory_item_id;

BEGIN

    OPEN c_getlineinfo(p_quote_header_id
                       ,p_qte_line_rec.inventory_item_id);
    LOOP
    FETCH c_getlineinfo into l_qte_line_rec.quote_line_id,
                             l_qte_line_rec.item_type_code,
                 l_qte_line_rec.quantity,
                             l_qte_line_rec.inventory_item_id;
    EXIT WHEN c_getLineinfo%notfound;
    l_qte_line_tbl(l_qte_line_tbl.count+1) := l_qte_line_rec;
    END LOOP;
    CLOSE c_getlineinfo;

    return l_qte_line_tbl;

END getlinetblfromdb;

PROCEDURE log_Control_Rec_Values(
   p_control_rec               IN ASO_Quote_Pub.Control_Rec_Type
)
IS
BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	IBE_Util.Debug('log_Control_Rec_Values BEGIN');
        IBE_Util.Debug('change line logic pricing Test BEGIN');
	IBE_Util.Debug('p_control_rec.last_update_date = ' || p_control_rec.last_update_date);
	IBE_Util.Debug('p_control_rec.auto_version_flag = '||  p_control_rec.auto_version_flag);
	IBE_Util.Debug('p_control_rec.pricing_request_type = '|| p_control_rec.pricing_request_type);
	IBE_Util.Debug('p_control_rec.header_pricing_event = '|| p_control_rec.header_pricing_event );
	IBE_Util.Debug('p_control_rec.line_pricing_event = ' || p_control_rec.line_pricing_event);
	IBE_Util.Debug('p_control_rec.calculate_tax_flag = '|| p_control_rec.calculate_tax_flag);
	IBE_Util.Debug('p_control_rec.calculate_freight_charge_flag = '|| p_control_rec.calculate_freight_charge_flag);
	IBE_Util.Debug('p_control_rec.price_mode = ' || p_control_rec.price_mode);
	IBE_Util.Debug('change line logic pricing Test END');
     END IF;
END log_Control_Rec_Values;

Procedure Load_Service(
  p_quote_header_id               IN  NUMBER
  ,p_service_ref_line_id          IN  NUMBER
  ,x_qte_line_tbl_service_db      out nocopy ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_qte_line_dtl_tbl_service_db  out nocopy ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type
)
IS
  l_qte_line_rec      ASO_Quote_Pub.Qte_Line_Rec_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_rec;

  l_qte_line_tbl      ASO_Quote_Pub.Qte_Line_Tbl_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_tbl;

  l_qte_line_dtl_rec  ASO_Quote_Pub.Qte_Line_dtl_Rec_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_dtl_rec;

  l_qte_line_dtl_tbl  ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_dtl_tbl;

  CURSOR c_getlineinfo(p_quote_header_id NUMBER, p_service_ref_line_id NUMBER)
  IS
  select l.quote_line_id
         ,l.item_type_code
         ,l.quantity
         ,l.inventory_item_id
         ,l.organization_id
         ,l.uom_code
         ,dl.quote_line_detail_id
         ,dl.service_duration
         ,dl.service_period
  from aso_quote_lines l, aso_quote_line_details dl
  where l.quote_header_id = p_quote_header_id
  and  l.item_type_code = 'SRV'
  and  dl.service_ref_line_id = p_service_ref_line_id
  and  dl.quote_line_id  = l.quote_line_id;
BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('at load_service p_service_ref_line_id ='
                    || p_service_ref_line_id);
    END IF;

    OPEN c_getlineinfo(p_quote_header_id
                       ,p_service_ref_line_id);
    LOOP
    FETCH c_getlineinfo into l_qte_line_rec.quote_line_id,
                             l_qte_line_rec.item_type_code,
                 l_qte_line_rec.quantity,
                             l_qte_line_rec.inventory_item_id,
                             l_qte_line_rec.organization_id,
                             l_qte_line_rec.uom_code,
                             l_qte_line_dtl_rec.quote_line_detail_id,
                             l_qte_line_dtl_rec.service_duration,
                             l_qte_line_dtl_rec.service_period;
    EXIT WHEN c_getLineinfo%notfound;

        l_qte_line_tbl(l_qte_line_tbl.count+1)
                                           := l_qte_line_rec;

        l_qte_line_dtl_tbl(l_qte_line_dtl_tbl.count+1)
                                           := l_qte_line_dtl_rec;
    END LOOP;
    CLOSE c_getlineinfo;

    x_qte_line_tbl_service_db := l_qte_line_tbl;
    x_qte_line_dtl_tbl_service_db := l_qte_line_dtl_tbl;
END Load_service;

PROCEDURE find_service(
  p_qte_line_index              IN NUMBER
  ,p_qte_line_tbl               IN  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,p_qte_line_dtl_tbl           IN  ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
  ,x_qte_line_tbl_service       OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_qte_line_dtl_tbl_service   OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
)
IS
  l_qte_line_index    NUMBER;
  l_qte_line_dtl_rec  ASO_Quote_Pub.Qte_Line_Dtl_rec_Type;

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('at find_service p_qte_line_tbl.count= '
                 ||p_qte_line_tbl.count);
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('at find_service p_qte_line_dtl_tbl.count= '
                 ||p_qte_line_dtl_tbl.count);
  END IF;
  FOR i in 1..p_qte_line_dtl_tbl.count Loop
      IF p_qte_line_dtl_tbl(i).service_ref_qte_line_index = p_qte_line_index THEN
         l_qte_line_dtl_rec := p_qte_line_dtl_tbl(i);

         l_qte_line_dtl_rec.SERVICE_REF_QTE_LINE_INDEX := i;
         --this to avoide search again

         x_qte_line_dtl_tbl_service(x_qte_line_dtl_tbl_service.count+1)
                          := l_qte_line_dtl_rec;

         l_qte_line_index := p_qte_line_dtl_tbl(i).qte_line_index;

         x_qte_line_tbl_service(x_qte_line_tbl_service.count+1)
                          := p_qte_line_tbl(l_qte_line_index);
      END IF;

  END  LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('at find_service x_qte_line_dtl_tbl.count= '
                 ||x_qte_line_dtl_tbl_service.count);
  END IF;
END Find_Service;


PROCEDURE load_serviceable_service(
  p_quote_header_id              IN NUMBER
  ,p_qte_line_rec                IN  ASO_Quote_Pub.Qte_Line_Rec_Type
  ,p_qte_line_tbl_service        IN  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,p_qte_line_dtl_tbl_service    IN  ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
  ,x_qte_line_rec_db             OUT NOCOPY ASO_Quote_Pub.Qte_Line_Rec_Type
  ,x_qte_line_tbl_service_db     OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_qte_line_dtl_tbl_service_db OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
)
IS
  l_qte_line_tbl                ASO_Quote_Pub.Qte_Line_Tbl_Type;
  l_qte_line_tbl_service_db     ASO_Quote_Pub.Qte_Line_Tbl_Type;
  l_qte_line_dtl_tbl_service_db ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;

  l_index                     number :=1;
  l_same                      varchar2(1) := 'N';
BEGIN
   -- find all the serviceable items  from database
   l_qte_line_tbl := getLineTblfromdb(
                        p_quote_header_id => p_quote_header_id,
                        p_qte_line_rec    => p_qte_line_rec);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('load_serviceable_service l_qte_line_tbl.count'||l_qte_line_tbl.count);
   END IF;

   WHILE l_same = 'N' and l_index  <= l_qte_line_tbl.count LOOP
     -- find all the service item from database for this serviceable item
      Load_service(
         p_quote_header_id             => p_quote_header_id                    ,
         p_service_ref_line_id         => l_qte_line_tbl(l_index).quote_line_id,
         x_qte_line_tbl_service_db     => l_qte_line_tbl_service_db            ,
         x_qte_line_dtl_tbl_service_db => l_qte_line_dtl_tbl_service_db);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('load_serviceable_service l_qte_line_tbl_service_db.count '
                   ||l_qte_line_tbl_service_db.count);
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('load_serviceable_service l_qte_line_dtl_tbl_service_db.count '
                   ||l_qte_line_dtl_tbl_service_db.count);
      END IF;
      IF p_qte_line_tbl_service.count = l_qte_line_tbl_service_db.count THEN
         IF p_qte_line_tbl_service.count  > 0 THEN
          l_same := compare
               ( p_qte_line_tbl_service         => p_qte_line_tbl_service
                 ,p_qte_line_dtl_tbl_service    => p_qte_line_dtl_tbl_service
                 ,p_qte_line_tbl_service_db     => l_qte_line_tbl_service_db
                 ,p_qte_line_dtl_tbl_service_db => l_qte_line_dtl_tbl_service_db);
         ELSE
            l_same := 'Y';
         END IF;
      END IF;

      IF l_same = 'Y' THEN
         x_qte_line_rec_db := l_qte_line_tbl(l_index);
         x_qte_line_tbl_service_db :=  l_qte_line_tbl_service_db;
         x_qte_line_dtl_tbl_service_db :=  l_qte_line_dtl_tbl_service_db;
      END IF;
      l_index := l_index + 1;
   END LOOP;
END load_serviceable_service;


procedure updateserviceLine(
  p_qte_line_rec          IN  ASO_Quote_Pub.Qte_Line_Rec_Type
  ,p_qte_line_dtl_rec     IN  ASO_Quote_Pub.Qte_Line_dtl_Rec_Type
  ,p_qte_line_tbl_db      IN  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,p_qte_line_dtl_tbl_db  IN  ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type
  ,x_qte_line_rec         OUT NOCOPY ASO_Quote_Pub.Qte_Line_Rec_Type
  ,x_qte_line_dtl_rec     OUT NOCOPY ASO_Quote_Pub.Qte_Line_dtl_Rec_Type
)
IS
  l_qte_line_rec      ASO_Quote_Pub.Qte_Line_Rec_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_rec;

  l_qte_line_dtl_rec  ASO_Quote_Pub.Qte_Line_dtl_Rec_Type
                      := ASO_Quote_Pub.g_miss_Qte_Line_dtl_rec;

  l_found             varchar2(1) := 'N';
  l_index             NUMBER      := 1;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('updateserviceline p_qte_line_tbl_db.count='
               ||p_qte_line_tbl_db.count);
  END IF;


  while l_found = 'N' and l_index <= p_qte_line_tbl_db.count Loop

      IF p_qte_line_tbl_db(l_index).inventory_item_id = p_qte_line_rec.inventory_item_id
         and p_qte_line_tbl_db(l_index).organization_id = p_qte_line_rec.organization_id
         and p_qte_line_tbl_db(l_index).uom_code = p_qte_line_rec.uom_code then
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('updateserviceline start update');
         END IF;
         l_qte_line_rec     := p_qte_line_rec;
         l_qte_line_dtl_rec := p_qte_line_dtl_rec;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('update service inventory_item_id'||l_qte_line_rec.inventory_item_id);
  END IF;
         l_qte_line_rec.quote_line_id  := p_qte_line_tbl_db(l_index).quote_line_id;
         l_qte_line_rec.quantity       := p_qte_line_tbl_db(l_index).quantity
                                       + l_qte_line_rec.quantity;
         l_qte_line_rec.operation_code := 'UPDATE';

         l_qte_line_dtl_rec.service_ref_qte_line_index
                                := FND_API.G_MISS_NUM;
         l_qte_line_dtl_rec.qte_line_index
                                := FND_API.G_MISS_NUM;
         l_qte_line_dtl_rec.operation_code
                                := 'UPDATE';
         l_qte_line_dtl_rec.quote_line_id
                                := l_qte_line_rec.quote_line_id;
         l_qte_line_dtl_rec.quote_line_detail_id
                                := p_qte_line_dtl_tbl_db(l_index).quote_line_detail_id;
         l_found := 'Y';
      END IF;
         l_index := l_index +1;
  END LOOP;

  x_qte_line_rec     := l_qte_line_rec;
  x_qte_line_dtl_rec := l_qte_line_dtl_rec;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('update service inventory_item_id'||x_qte_line_rec.inventory_item_id);
     IBE_Util.Debug('update service quote_line_id'||x_qte_line_rec.quote_line_id);
     IBE_Util.Debug('update service quote_line_id'||x_qte_line_dtl_rec.quote_line_detail_id);
  END IF;
END updateserviceline;

PROCEDURE header_agreements(
                p_api_version      IN  NUMBER   := 1                  ,
                p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE     ,
                p_commit           IN  VARCHAR2 := FND_API.G_FALSE    ,
                x_return_status    OUT NOCOPY VARCHAR2                       ,
                x_msg_count        OUT NOCOPY NUMBER                         ,
                x_msg_data         OUT NOCOPY VARCHAR2                       ,
                p_qte_header_rec   IN  aso_quote_pub.Qte_Header_Rec_Type ,
                p_hdr_payment_tbl  IN  aso_quote_pub.Payment_Tbl_Type,
                x_hdr_payment_tbl  OUT NOCOPY aso_quote_pub.Payment_Tbl_Type ) is

  cursor c_term_id(p_contract_id number) is
    select term_id
    from oe_agreements
    where agreement_id = p_contract_id;

  cursor c_payment_id(p_quote_hdr_id number) is
    select payment_id
    from aso_payments
    where quote_header_id = p_quote_hdr_id
    and quote_line_id is null;

  L_API_NAME    CONSTANT VARCHAR2(30) := 'handle_header_agreements';
  L_API_VERSION CONSTANT NUMBER       := 1.0;
  l_payment_id       number := null;
  l_payment_term_id  number := fnd_api.g_miss_num;
  l_hdr_payment_tbl  aso_quote_pub.Payment_Tbl_Type;
  counter            number;
  rec_term_id        c_term_id%rowtype;
  rec_payment_id     c_payment_id%rowtype;

  begin
     -- Standard Start of API savepoint
    SAVEPOINT handle_header_agreements_pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- API body

  l_hdr_payment_tbl := p_hdr_payment_tbl;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('Incoming header payment rec has '||p_hdr_payment_tbl.count||' records');
     ibe_util.debug('Incoming agreementId is        '||p_qte_header_rec.contract_id );
  END IF;

  if(p_qte_header_rec.contract_id is null or p_qte_header_rec.contract_id <> fnd_api.g_miss_num) then
    if(p_qte_header_rec.contract_id is not null
      and p_qte_header_rec.contract_id <> fnd_api.g_miss_num) then
      for rec_term_id in c_term_id(p_qte_header_rec.contract_id) loop
        l_payment_term_id := rec_term_id.term_id;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('payment term id when contract id is not null and not g_miss '||l_payment_term_id);
        END IF;
        exit when c_term_id%notfound;
      end loop;
    elsif (p_qte_header_rec.contract_id is null ) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('p_qte_header_rec.contract_id is null hence l_payment_term_id is null');
      END IF;
      -- changed 4/5/04 for bug 3551866
       --l_payment_term_id := null;
      l_payment_term_id := fnd_profile.value('IBE_DEFAULT_PAYMENT_TERM_ID');
    end if;

    if(p_hdr_payment_tbl.count>0) then
      for counter in 1..p_hdr_payment_tbl.count loop
        if (p_hdr_payment_tbl(counter).quote_header_id = p_qte_header_rec.quote_header_id
            and (p_hdr_payment_tbl(counter).quote_line_id is null or
                 p_hdr_payment_tbl(counter).quote_line_id = fnd_api.g_miss_num) ) then
          if(p_hdr_payment_tbl(counter).operation_code <> 'DELETE') then
            l_hdr_payment_tbl(counter).payment_term_id := l_payment_term_id;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               ibe_util.debug('header_payment_tbl.payment_term_id '||l_payment_term_id);
            END IF;
          end if;
        end if;
      end loop;
    else
      counter := 1;
      for rec_payment_id in c_payment_id(p_qte_header_rec.quote_header_id) loop
        l_payment_id      := rec_payment_id.payment_id;
        exit when c_payment_id%notfound;
      end loop;
      l_hdr_payment_tbl(counter).quote_header_id := p_qte_header_rec.quote_header_id;
      l_hdr_payment_tbl(counter).quote_line_id   := null;
      if(l_payment_id is not null ) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Input payment table is empty but record in database');
        END IF;
        l_hdr_payment_tbl(counter).payment_id := l_payment_id;
        l_hdr_payment_tbl(counter).payment_term_id := l_payment_term_id;
        l_hdr_payment_tbl(counter).operation_code  := 'UPDATE';
      else
        if (l_payment_term_id is not null) then
          l_hdr_payment_tbl(counter).payment_term_id := l_payment_term_id;
          l_hdr_payment_tbl(counter).operation_code  := 'CREATE';
        end if;
      end if;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('outgoing payment table quote_header_id '||l_hdr_payment_tbl(1).quote_header_id);
          ibe_util.debug('outgoing payment table quote_line_id   '||l_hdr_payment_tbl(1).quote_line_id);
          ibe_util.debug('outgoing payment table payment_id      '||l_hdr_payment_tbl(1).payment_id);
          ibe_util.debug('outgoing payment table payment_term_id '||l_hdr_payment_tbl(1).payment_term_id);
          ibe_util.debug('outgoing payment table operation_code  '||l_hdr_payment_tbl(1).operation_code);
        END IF;

    end if;
  else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Incoming agreement id is g_miss');
    END IF;
  end if;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('outgoing payment table from header_agreements API');
  END IF;
  x_hdr_payment_tbl := l_hdr_payment_tbl;

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count    ,
                            p_data    => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Expected error in IBE_QUOTE_SAVE_PVT.header_agreements');
     END IF;
      ROLLBACK TO handle_header_agreements_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Unexpected error in IBE_QUOTE_SAVE_PVT.header_agreements');
     END IF;
      ROLLBACK TO handle_header_agreements_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO handle_header_agreements_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Unknown error in IBE_QUOTE_SAVE_PVT.header_agreements');
     END IF;
      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 L_API_NAME);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

end header_agreements;

PROCEDURE Default_Header_Record(
   p_qte_header_rec           IN  ASO_Quote_Pub.Qte_Header_Rec_Type       ,
   p_auto_update_active_quote IN  VARCHAR2  := FND_API.G_TRUE             ,
   p_hdr_payment_tbl          IN  aso_quote_pub.Payment_Tbl_Type          ,
   x_hdr_payment_tbl          OUT NOCOPY aso_quote_pub.Payment_Tbl_Type   ,
   x_qte_header_rec           OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type,
   x_return_status            OUT NOCOPY VARCHAR2                         ,
   x_msg_count                OUT NOCOPY NUMBER                           ,
   x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
   l_duration          NUMBER := NULL;
   l_last_update_date  DATE;
   l_party_id          NUMBER;
   l_cust_account_id   NUMBER;
   l_contract_id       NUMBER;
   l_quote_source_code VARCHAR2(240);
   l_resource_id       NUMBER := NULL;
   l_publish_flag      VARCHAR2(1);
   l_price_list_id     NUMBER;
   l_agmt_associated   VARCHAR2(1):= FND_API.G_FALSE;
   l_org_payment_id	   NUMBER	:= NULL;
   l_installment_options VARCHAR2(30)	:= NULL;


BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('start Default_Header_Record');
   END IF;
   --DBMS_OUTPUT.PUT_line('p_qte_header_rec.quote_header_id '||p_qte_header_rec.quote_header_id);
   x_qte_header_rec := p_qte_header_rec;
   x_hdr_payment_tbl := p_hdr_payment_tbl;
   -- need get active cart for account user (ignore passed in value)
   IF  p_qte_header_rec.quote_header_id   = FND_API.G_MISS_NUM

   AND p_qte_header_rec.quote_source_code = 'IStore Account'
   AND (p_qte_header_rec.quote_name = 'IBE_PRMT_SC_UNNAMED' --MANNAMRA: Changed default quote name value from IBEACTIVECART to IBE_PRMT_SC_UNNAMED
                                                   --09/16/02
     OR p_qte_header_rec.quote_name = FND_API.G_MISS_CHAR) THEN
      --DBMS_OUTPUT.PUT_line('passed in qte_header_id is g_miss ');
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug(' need to get active cart');
      END IF;
      x_qte_header_rec.quote_header_id :=
         IBE_Quote_Misc_pvt.Get_Active_Quote_ID(
            p_party_id        => p_qte_header_rec.party_id,
            p_cust_account_id => p_qte_header_rec.cust_account_id);
      -- create quote
      IF x_qte_header_rec.quote_header_id = 0 THEN
         x_qte_header_rec.quote_header_id := FND_API.G_MISS_NUM;
         -- if create quote and contract_id(agreement_id) is not set
         -- then check if there is user default agreement
         IF x_qte_header_rec.contract_id = FND_API.G_MISS_NUM THEN
            x_qte_header_rec.contract_id := NVL(FND_Profile.Value('IBE_USER_DEFAULT_AGREEMENT'),
                                                FND_API.G_MISS_NUM);
         END IF;
      -- update quote
      /*A quote header_id is passed in during every update quote operation*/
      ELSE
         IF NOT FND_API.To_Boolean(p_auto_update_active_quote) THEN
            IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
               FND_Message.Set_Name('IBE', 'IBE_SC_QUOTE_NEED_REFRESH');
               FND_Msg_Pub.Add;
            END IF;

            RAISE FND_API.G_EXC_ERROR;   -- need error message
         END IF;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('after  get active cart id = '|| x_qte_header_rec.quote_header_id);
      END IF;
   END IF;

   -- if contract_id is set, then overwrite price_list_id field
   IF x_qte_header_rec.contract_id <> FND_API.G_MISS_NUM THEN
      -- if contract_id is null it is because the user wants to set to null.
      -- just use price_list_id that is set.
      IF x_qte_header_rec.contract_id IS NULL THEN
         NULL;
      -- if contract_id is not null, get its associated price list id from DB
      ELSE
         SELECT price_list_id
         INTO x_qte_header_rec.price_list_id
         FROM OE_Agreements_B
         WHERE agreement_id = x_qte_header_rec.contract_id;

         l_agmt_associated := FND_API.G_TRUE;
      END IF;
   END IF;

   -- only set expiration date, default order_type_id, quote_category_code and quote_name
   --  when quote_header_id is null

   IF (x_qte_header_rec.quote_header_id = FND_API.G_MISS_NUM or x_qte_header_rec.quote_header_id is null) THEN

      IF  x_qte_header_rec.quote_name = FND_API.G_MISS_CHAR
      AND (x_qte_header_rec.quote_source_code = 'IStore Walkin'
        OR x_qte_header_rec.quote_source_code = 'IStore Account'
	OR x_qte_header_rec.quote_source_code = 'IStore InstallBase'
	OR x_qte_header_rec.quote_source_code = 'IStore ProcPunchout') THEN
        x_qte_header_rec.quote_name := 'IBE_PRMT_SC_UNNAMED';--MANNAMRA: Changed default quote name value from IBEACTIVECART to IBE_PRMT_SC_UNNAMED
                                                    --09/16/02
      END IF;

   ELSE -- header_id is there
      --DBMS_OUTPUT.PUT_line('before the select stmt ');
      --DBMS_OUTPUT.PUT_line('x_qte_header_rec.quote_header_id '||x_qte_header_rec.quote_header_id);
      SELECT party_id        ,
             cust_account_id ,
             last_update_date,
             contract_id     ,
             quote_source_code,
             resource_id,
             publish_flag,
             price_list_id
      INTO l_party_id        ,
           l_cust_account_id ,
           l_last_update_date,
           l_contract_id     ,
           l_quote_source_code,
           l_resource_id,
           l_publish_flag,
           l_price_list_id
      FROM aso_quote_headers_all
      WHERE quote_header_id = x_qte_header_rec.quote_header_id;
      --DBMS_OUTPUT.PUT_line('after select statement ');
      -- set last_update_date
      --Removing this check because this is already being done in validate_user_update
      --IF x_qte_header_rec.last_update_date = FND_API.G_MISS_DATE THEN
         x_qte_header_rec.last_update_date := l_last_update_date;
      --END IF;

      IF x_qte_header_rec.party_id = FND_API.G_MISS_NUM THEN
         x_qte_header_rec.party_id := l_party_id;
      END IF;

      IF x_qte_header_rec.cust_account_id = FND_API.G_MISS_NUM THEN
         x_qte_header_rec.cust_account_id := l_cust_account_id;
      END IF;

      /* Check if the quote_header_id is for a published quote then keep the price_list_id as whatever in the DB.
      Ideally we do not want to change the price list id put in by the Sales Rep for Update of published Quotes.
      This is true only when the agreement is not associated to the quote.*/
      IF (l_resource_id is not null AND nvl(l_publish_flag,'N')='Y'
       AND l_agmt_associated = FND_API.G_FALSE AND l_price_list_id is not null) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Please revert back the price list id as in the DB,as this is a Published quote, price_list_id='||l_price_list_id);
        END IF;
        x_qte_header_rec.price_list_id := l_price_list_id;
      END IF;

      /* if agreement_id in DB is not null and the current record
         does not have it set, use the value from DB.*/
      IF  x_qte_header_rec.contract_id = FND_API.G_MISS_NUM
      AND l_contract_id IS NOT NULL THEN
         x_qte_header_rec.contract_id := l_contract_id;

         SELECT price_list_id
         INTO x_qte_header_rec.price_list_id
         FROM OE_Agreements_B
         WHERE agreement_id = l_contract_id;
      END IF;
     --DBMS_OUTPUT.PUT_line('BEFORE header agreements ');
     header_agreements(
              p_api_version      => 1.0              ,
              p_init_msg_list    => FND_API.G_TRUE   ,
              p_commit           => FND_API.G_FALSE  ,
              x_return_status    => x_return_status  ,
              x_msg_count        => x_msg_count      ,
              x_msg_data         => x_msg_data       ,
              p_qte_header_rec   => x_qte_header_rec ,
              p_hdr_payment_tbl  => p_hdr_payment_tbl,
              x_hdr_payment_tbl  => x_hdr_payment_tbl);
      --DBMS_OUTPUT.PUT_line('AFTER header agreements ');

      IF x_qte_header_rec.quote_source_code = FND_API.G_MISS_CHAR THEN
         x_qte_header_rec.quote_source_code := l_quote_source_code;
      END IF;

      -- expiration date doesn't change from 1st one set for sales rep
      -- for self service, we want to avoid expiring the quote
      /*
      IF (x_qte_header_rec.resource_id = FND_API.G_MISS_NUM) AND
         (l_resource_id is null) THEN
         -- temporary way to have non-expiring self service quotes
         x_qte_header_rec.quote_expiration_date := SYSDATE + 10000;
      END IF;
      */

   END IF;

   -- set price frozen date
   -- Removed the code for setting the price frozen date for the bug# 2917587

   -- default payment term id if pay now is enabled
   IF x_hdr_payment_tbl.count=0 THEN
     IBE_Util.Debug('no header payment record passed down so far.');
     IBE_Util.Debug('checking if PAY NOW is turned on...');
   	 IF x_qte_header_rec.org_id is NULL OR x_qte_header_rec.org_id=FND_API.G_MISS_NUM THEN
	    IBE_Util.Debug('x_qte_header_rec.org_id is null or GMISS');
     	l_installment_options := oe_sys_parameters.value(
            param_name  => 'INSTALLMENT_OPTIONS');
   	 ELSE
	    IBE_Util.Debug('x_qte_header_rec.org_id='||x_qte_header_rec.org_id);
     	l_installment_options := oe_sys_parameters.value(
            param_name  => 'INSTALLMENT_OPTIONS',
            p_org_id    => x_qte_header_rec.org_id);
     END IF;
     IBE_Util.Debug('OM parameter INSTALLMENT_OPTIONS='||l_installment_options);

     IF NVL(l_installment_options,'NONE')='ENABLE_PAY_NOW' THEN
         IBE_Util.Debug('Pay Now is enabled.');
         IF x_qte_header_rec.quote_header_id is null OR	x_qte_header_rec.quote_header_id=FND_API.G_MISS_NUM THEN
    	    IBE_Util.Debug('it is a new cart.');
         ELSE
		    IBE_Util.Debug('existing cart,x_qte_header_rec.quote_header_id='|| x_qte_header_rec.quote_header_id);
    	    IBE_Util.Debug('checking if a header payment record is already present...');
    	    BEGIN
    	      SELECT payment_id into l_org_payment_id	FROM ASO_payments
			  WHERE QUOTE_HEADER_ID = x_qte_header_rec.quote_header_id AND quote_line_id is null;
         	  IBE_Util.Debug('header payment record found,l_org_payment_id='||l_org_payment_id);
  	        EXCEPTION
  	          WHEN NO_DATA_FOUND THEN
  	           l_org_payment_id := NULL;
  	           IBE_Util.Debug('no header payment record found');
  	          WHEN TOO_MANY_ROWS  THEN
  	           l_org_payment_id := FND_API.G_MISS_NUM;
  	           IBE_Util.Debug('too many header payment records found');
  	        END;
         END IF;

         IF x_qte_header_rec.quote_header_id is null OR l_org_payment_id is null THEN
         	IBE_Util.Debug('initializing header payment record...');
         	x_hdr_payment_tbl(1).PAYMENT_TERM_ID := FND_PROFILE.VALUE('IBE_DEFAULT_PAYMENT_TERM_ID');
         	IBE_Util.Debug('profile option IBE_DEFAULT_PAYMENT_TERM_ID='||x_hdr_payment_tbl(1).PAYMENT_TERM_ID);
         	IF x_qte_header_rec.quote_header_id is not null THEN
			 x_hdr_payment_tbl(1).QUOTE_HEADER_ID := x_qte_header_rec.quote_header_id;
			END IF;
         	--x_hdr_payment_tbl(1).PAYMENT_TYPE_CODE := NULL;
         	x_hdr_payment_tbl(1).OPERATION_CODE := 'CREATE';
         	IBE_Util.Debug('header payment record is defaulted for Pay Now');
         END IF;
     ELSE
         IBE_Util.Debug('Pay Now is turned off');
         IBE_Util.Debug('no header payment record was populated');
     END IF;
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('done Default_Header_Record');
   END IF;

END Default_Header_Record;

procedure setLineDefaultVal(
  p_quote_header_id        in  number
  ,p_qte_line_tbl           in  ASO_Quote_Pub.QTE_LINE_TBL_TYPE
  ,p_qte_line_dtl_tbl       IN  ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
  ,p_combinesameitem        in  VARCHAR2    := FND_API.G_MISS_CHAR
  ,x_qte_line_tbl           out nocopy ASO_Quote_Pub.QTE_LINE_TBL_TYPE
  ,x_qte_line_dtl_tbl       OUT NOCOPY ASO_Quote_Pub.QTE_LINE_DTL_TBL_TYPE
)
is
  l_length            NUMBER :=0;

  l_combinesameitem   VARCHAR2(2) := FND_API.G_MISS_CHAR;
  l_quantity          NUMBER;
  l_marketing_source_code_id  NUMBER;
  l_quote_line_id     NUMBER;
  l_item_type_code    VARCHAR2(30);

  l_pricing_line_type_indicator  VARCHAR2(3);
  l_found_PRG         varchar2(1) := 'N';

  l_qte_line_rec_db             ASO_Quote_Pub.QTE_LINE_REC_TYPE;
  l_qte_line_tbl_service        ASO_Quote_Pub.QTE_LINE_TBL_TYPE;
  l_qte_line_dtl_tbl_service    ASO_Quote_Pub.QTE_LINE_DTL_TBL_TYPE;

  l_qte_line_tbl_service_db     ASO_Quote_Pub.QTE_LINE_TBL_TYPE;
  l_qte_line_dtl_tbl_service_db ASO_Quote_Pub.QTE_LINE_DTL_TBL_TYPE;

  l_line_tbl_index              NUMBER :=1;
  l_line_dtl_tbl_index          NUMBER :=1;

  l_found                      varchar2(1);
  l_qte_line_index             NUMBER;
  l_line_level_services        VARCHAR2(1)  := 'N';

  --temp vars for OUT NOCOPY params
  l_qte_line_tbl_tmp           ASO_Quote_Pub.QTE_LINE_TBL_TYPE;
  l_qte_line_dtl_tbl_tmp       ASO_Quote_Pub.QTE_LINE_DTL_TBL_TYPE;


  cursor c_getlineinfo(p_quote_header_id number, l_inventory_item_id number,l_uom_code varchar2)
  is
  select quote_line_id, item_type_code ,quantity,marketing_source_code_id
  from aso_quote_lines
  where quote_header_id = p_quote_header_id
  and inventory_item_id = l_inventory_item_id and uom_code = l_uom_code;

  cursor c_checkForPRG (p_quote_header_id number)
  is
  select pricing_line_type_indicator
  from aso_quote_lines
  where quote_header_id = p_quote_header_id;

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('start setLineDefaultval');
  END IF;


  FOR i IN 1..p_qte_line_dtl_tbl.count LOOP
      x_qte_line_dtl_tbl(i) := p_qte_line_dtl_tbl(i);
  END LOOP;


  FOR i IN 1..p_qte_line_tbl.count LOOP
      x_qte_line_tbl(i) := p_qte_line_tbl(i);
      if (x_qte_line_tbl(i).pricing_line_type_indicator = 'F') then
        l_found_PRG := 'Y';
      end if;
  END LOOP;

  -- added 1/26/04: Bug #3399026 -- need to check if target cart has PRG lines as well
  open c_checkForPRG(p_quote_header_id);
  loop
  fetch c_checkForPRG into l_pricing_line_type_indicator;
     exit when c_checkForPRG%notfound;
     if (l_pricing_line_type_indicator = 'F') then
       l_found_PRG := 'Y';
       exit;
     end if;
  end loop;
  close c_checkForPRG;

  IF (p_combinesameitem = FND_API.G_MISS_CHAR) THEN
    l_combinesameitem := FND_Profile.Value('IBE_SC_MERGE_SHOPCART_LINES');
  Else
    l_combinesameitem := p_combinesameitem;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Checking line level services profile');
     IBE_Util.Debug('IBE_USE_SUPPORT: '||FND_Profile.Value('IBE_USE_SUPPORT'));
     IBE_Util.Debug('IBE_USE_SUPPORT_CART_LEVEL '||FND_Profile.Value('IBE_USE_SUPPORT_CART_LEVEL'));
  END IF;

  IF (FND_Profile.Value('IBE_USE_SUPPORT') = 'Y' ) THEN

    l_line_level_services := 'Y';
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('line level services turned on');
    END IF;

  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('looping around input quote line table');
  END IF;
  FOR i in 1..p_qte_line_tbl.count LOOP

    -- set quote_header_id
    if ((x_qte_line_tbl(i).quote_header_id is null
         or x_qte_line_tbl(i).quote_header_id = FND_API.G_MISS_NUM)
       and (p_quote_header_id is not null
            and p_quote_header_id <> FND_API.G_MISS_NUM)) then
       x_qte_line_tbl(i).quote_header_id := p_quote_header_id;

      if ((x_qte_line_tbl(i).quote_line_id is null
         or x_qte_line_tbl(i).quote_line_id = FND_API.G_MISS_NUM)
         and (x_qte_line_tbl(i).operation_code is  null
         or x_qte_line_tbl(i).operation_code = FND_API.G_MISS_CHAR)) then

        x_qte_line_tbl(i).operation_code := 'CREATE';
      END IF;
    END IF;

    -- treat quantity 0 as delete
    IF (p_qte_line_tbl(i).quantity = 0) THEN
      x_qte_line_tbl(i).operation_code := 'DELETE';
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug(' l_combinesameitem='||l_combinesameitem);
       IBE_Util.Debug('before combine item_type_code='||x_qte_line_tbl(i).item_type_code);
       IBE_Util.Debug('inventory_item_id='||x_qte_line_tbl(i).inventory_item_id);
       IBE_Util.Debug('quantity='||x_qte_line_tbl(i).quantity);
       IBE_Util.Debug('operation_code='||x_qte_line_tbl(i).operation_code);
    END IF;

    -- combine same item
    IF l_combinesameitem = 'Y'
       and p_quote_header_id is not null
       and p_quote_header_id  <> FND_API.G_MISS_NUM
       and x_qte_line_tbl(i).operation_code = 'CREATE'
       and l_found_PRG = 'N' THEN

      /*
      -- 9/2/03: For Merging, SVA Case, don't compare SRV's
      --           so, handle SVA case just like STD case
      IF x_qte_line_tbl(i).item_type_code = 'SVA' THEN

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Current item type code in input quote line tbl is SVA');
        END IF;

        IF (l_line_level_services <> 'Y') THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Entering combine same item logic: Line level services turned off');
          END IF;

          l_qte_line_tbl_service     := ASO_Quote_Pub.g_miss_Qte_Line_tbl;
          l_qte_line_dtl_tbl_service := ASO_Quote_Pub.g_miss_Qte_Line_dtl_tbl;
          -- find service line and detail line based on servicable item
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('call fnd_service with i='||i);
          END IF;

          find_service
          ( p_qte_line_index            => i    -- serviceable index
            ,p_qte_line_tbl             => p_qte_line_tbl
            ,p_qte_line_dtl_tbl         => x_qte_line_dtl_tbl
            ,x_qte_line_tbl_service     => l_qte_line_tbl_service
            ,x_qte_line_dtl_tbl_service => l_qte_line_dtl_tbl_service);

           -- find a same servicable and service item from db
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('call load_serviceable_service ');
          END IF;
          load_serviceable_service
          ( p_quote_header_id              => p_quote_header_id
            ,p_qte_line_rec                => x_qte_line_tbl(i)
            ,p_qte_line_tbl_service        => l_qte_line_tbl_service
            ,p_qte_line_dtl_tbl_service    => l_qte_line_dtl_tbl_service
            ,x_qte_line_rec_db             => l_qte_line_rec_db
            ,x_qte_line_tbl_service_db     => l_qte_line_tbl_service_db
            ,x_qte_line_dtl_tbl_service_db => l_qte_line_dtl_tbl_service_db);

          --- doing merge
          IF l_qte_line_rec_db.quote_line_id is not null
            and l_qte_line_rec_db.quote_line_id <> FND_API.G_MISS_NUM THEN
           --- setup servicable item
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('merge serviceable line_id'
                               || l_qte_line_rec_db.quote_line_id);
            END IF;

            x_qte_line_tbl(i).operation_code := 'UPDATE';
            x_qte_line_tbl(i).quantity       := x_qte_line_tbl(i).quantity
                                          + nvl(l_qte_line_rec_db.quantity,0);
            x_qte_line_tbl(i).quote_line_id  := l_qte_line_rec_db.quote_line_id;
            l_line_tbl_index     :=1;
            l_line_dtl_tbl_index :=1;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('merge service line count='
                             || l_qte_line_dtl_tbl_service.count);
            END IF;

            FOR i in 1..l_qte_line_dtl_tbl_service.count LOOP

              l_line_tbl_index   := l_qte_line_dtl_tbl_service(i).qte_line_index;
              -- this line is hack
              l_line_dtl_tbl_index := l_qte_line_dtl_tbl_service(i).service_ref_qte_line_index;

              updateserviceLine
                ( p_qte_line_rec         => x_qte_line_tbl(l_line_tbl_index)
                  ,p_qte_line_dtl_rec    => x_qte_line_dtl_tbl(l_line_dtl_tbl_index)
                  ,p_qte_line_tbl_db     => l_qte_line_tbl_service_db
                  ,p_qte_line_dtl_tbl_db => l_qte_line_dtl_tbl_service_db
                  ,x_qte_line_rec        => l_qte_line_tbl_tmp(l_line_tbl_index)
                  ,x_qte_line_dtl_rec    => l_qte_line_dtl_tbl_tmp(l_line_dtl_tbl_index));

              x_qte_line_tbl(l_line_tbl_index) := l_qte_line_tbl_tmp(l_line_tbl_index);
              x_qte_line_dtl_tbl(l_line_dtl_tbl_index) := l_qte_line_dtl_tbl_tmp(l_line_dtl_tbl_index);

              x_qte_line_dtl_tbl(l_line_dtl_tbl_index).service_ref_line_id
                                      := l_qte_line_rec_db.quote_line_id ;

              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('quote line id='
                             ||x_qte_line_dtl_tbl(i).quote_line_id);
              END IF;
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('quote line detail id='
                                       ||x_qte_line_dtl_tbl(i).quote_line_detail_id);
              END IF;
            END LOOP;

          END IF;  -- end merge service item
        END IF; --line level services check
      -- 9/2/03: For Merging, SVA Case, don't compare SRV's
      --           so, handle SVA case just like STD case
      ELSE
      */
        l_quote_line_id   := FND_API.G_MISS_NUM;
        l_item_type_code  := FND_API.G_MISS_CHAR;
        l_quantity        := FND_API.G_MISS_NUM;
        l_marketing_source_code_id := FND_API.G_MISS_NUM;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Calling the item cursor in MergeLines with uom_code'||x_qte_line_tbl(i).uom_code);
        END IF;
        open c_getlineinfo(p_quote_header_id
                          ,x_qte_line_tbl(i).inventory_item_id,x_qte_line_tbl(i).uom_code);
        fetch c_getlineinfo into l_quote_line_id,
                                 l_item_type_code,
                                 l_quantity,
                                 l_marketing_source_code_id;
        close c_getlineinfo;


        IF (l_item_type_code is not null
            and ((l_item_type_code = 'STD') or ((l_item_type_code = 'SVA') and (l_line_level_services <> 'Y')) )
            and (l_quote_line_id is not null) ) THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Dealing with a standard item');
          END IF;
          x_qte_line_tbl(i).operation_code := 'UPDATE';
          x_qte_line_tbl(i).quantity := x_qte_line_tbl(i).quantity
                                           + nvl(l_quantity,0);
          x_qte_line_tbl(i).quote_line_id := l_quote_line_id;

	  -- Fix for Bug#6015035, scnagara
 	  -- Added setting of dff attributes to G_MISS_CHAR when merge profile is on
 	  x_qte_line_tbl(i).ATTRIBUTE_CATEGORY := FND_API.G_MISS_CHAR;
 	  x_qte_line_tbl(i).ATTRIBUTE1 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE2 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE3 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE4 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE5 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE6 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE7 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE8 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE9 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE10 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE11 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE12 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE13 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE14 := FND_API.G_MISS_CHAR;
	  x_qte_line_tbl(i).ATTRIBUTE15 := FND_API.G_MISS_CHAR;
    --modified for bug 18525045 - start
    x_qte_line_tbl(i).ATTRIBUTE16 := FND_API.G_MISS_CHAR;
    x_qte_line_tbl(i).ATTRIBUTE17 := FND_API.G_MISS_CHAR;
    x_qte_line_tbl(i).ATTRIBUTE18 := FND_API.G_MISS_CHAR;
    x_qte_line_tbl(i).ATTRIBUTE19 := FND_API.G_MISS_CHAR;
    x_qte_line_tbl(i).ATTRIBUTE20 := FND_API.G_MISS_CHAR;
    --modified for bug 18525045 - end
	  -- End Fix for Bug#6015035, scnagara

          --Fix for bug 2727665
          x_qte_line_tbl(i).item_type_code := l_item_type_code;
          --End fix for 2727665
          x_qte_line_tbl(i).marketing_source_code_id := l_marketing_source_code_id;
    END IF;
    END IF;  -- end of combine item

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('item_type_code='||x_qte_line_tbl(i).item_type_code);
      IBE_Util.Debug('inventory_item_id='||x_qte_line_tbl(i).inventory_item_id);
      IBE_Util.Debug('quantity='||x_qte_line_tbl(i).quantity);
      IBE_Util.Debug('operation_code='||x_qte_line_tbl(i).operation_code);
      IBE_Util.Debug('quote_line_id='||x_qte_line_tbl(i).quote_line_id);
      IBE_Util.Debug('quote_header_id='||x_qte_line_tbl(i).quote_header_id);
    END IF;


  -- set line_category_code

    IF ( (x_qte_line_tbl(i).operation_code = 'CREATE')
        or (x_qte_line_tbl(i).operation_code is null)
        or (x_qte_line_tbl(i).operation_code = FND_API.G_MISS_CHAR))
      and ((x_qte_line_tbl(i).line_category_code is null )
        or (x_qte_line_tbl(i).line_category_code = FND_API.G_MISS_CHAR)) then
      x_qte_line_tbl(i).line_category_code := 'ORDER';
    END IF;

    IF (((x_qte_line_tbl(i).operation_code = 'CREATE')
        or (x_qte_line_tbl(i).operation_code is null)
        or (x_qte_line_tbl(i).operation_code = FND_API.G_MISS_CHAR))
      and  (x_qte_line_tbl(i).item_type_code = 'SRV' )
      and  ((x_qte_line_tbl(i).start_date_active is null )
        or (x_qte_line_tbl(i).start_date_active = FND_API.G_MISS_DATE))) THEN
      x_qte_line_tbl(i).start_date_active := sysdate;
    END IF;

  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('done setLinedefaultval');
  END IF;
END setLineDefaultVal;

PROCEDURE DeleteSharees(
  p_api_version_number   IN  NUMBER
  ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
  ,p_Quote_HEADER_ID     IN  NUMBER
  ,p_minisite_id         IN  NUMBER   := FND_API.G_MISS_NUM
  ,X_Return_Status       OUT NOCOPY VARCHAR2
  ,X_Msg_Count           OUT NOCOPY NUMBER
  ,X_Msg_Data            OUT NOCOPY VARCHAR2
)
IS
  l_api_name             CONSTANT VARCHAR2(30)    := 'DeleteSharees';
  l_api_version          CONSTANT NUMBER     := 1.0;

  CURSOR c_get_recipients(c_quote_header_id number) is
    SELECT quote_sharee_id,
           party_id,
           cust_account_id,
           quote_sharee_number,
           contact_point_id,
           fnd.customer_id shared_by_party_id
    FROM IBE_SH_QUOTE_ACCESS, fnd_user fnd
    where quote_header_id = c_quote_header_id
    and ibe_sh_quote_access.created_by = fnd.user_id;
  rec_get_recipients c_get_recipients%rowtype;
  l_qte_access_rec   IBE_QUOTE_SAVESHARE_pvt.quote_access_rec_type
                     := IBE_QUOTE_SAVESHARE_pvt.G_MISS_QUOTE_ACCESS_REC;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    DELETESHAREES_pvt;
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

   IF FND_API.To_Boolean(p_init_msg_list) THEN
                FND_Msg_Pub.initialize;
   END IF;

   -- API body

   -- need to delete contact point
   -- delete all shares need table handle and generate table handle

   /*DELETE
   FROM ibe_sh_quote_access
   WHERE quote_header_id = p_quote_header_id;*/

   FOR rec_get_recipients in c_get_recipients(p_Quote_HEADER_ID) LOOP
     l_qte_access_rec.quote_sharee_id     := rec_get_recipients.quote_sharee_id;
     l_qte_access_rec.quote_sharee_number := rec_get_recipients.quote_sharee_number;
     l_qte_access_rec.party_id            := rec_get_recipients.party_id;
     l_qte_access_rec.cust_account_id     := rec_get_recipients.cust_account_id;
     l_qte_access_rec.contact_point_id    := rec_get_recipients.contact_point_id;
     l_qte_access_rec.shared_by_party_id  := rec_get_recipients.shared_by_party_id;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('DeleteSharees:Calling delete_recipient');
     END IF;

     IBE_QUOTE_SAVESHARE_V2_PVT.DELETE_RECIPIENT(
       P_Quote_access_rec  => l_qte_access_rec ,
       p_minisite_id       => p_minisite_id    ,
       --p_notes             => p_notes          ,
       x_return_status     => x_return_status  ,
       x_msg_count         => x_msg_count      ,
       x_msg_data          => x_msg_data       );

       IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
       IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('DeleteSharees:Done calling delete_recipient');
     END IF;
     EXIT when c_get_recipients%notfound;
   END LOOP;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETESHAREES_pvt;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Expected error in IBE_QUOTE_SAVE_PVT.DeleteSharees');
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unexpected error in IBE_QUOTE_SAVE_PVT.DeleteSharees');
      END IF;
      ROLLBACK TO DELETESHAREES_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unknown error in IBE_QUOTE_SAVE_PVT.DeleteSharees');
      END IF;
      ROLLBACK TO DELETESHAREES_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END DeleteSharees;


PROCEDURE Delete(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                ,
   x_msg_count          OUT NOCOPY NUMBER                  ,
   x_msg_data           OUT NOCOPY VARCHAR2                ,
   p_quote_header_id    IN  NUMBER                         ,
   p_expunge_flag       IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_minisite_id        IN  NUMBER   :=FND_API.G_MISS_NUM  ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_Quote_access_tbl   IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE
                            := IBE_QUOTE_SAVESHARE_pvt.G_miss_quote_access_Tbl ,
   p_notes              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   -- in even that we are deleting a shared cart
   -- could be owner or admin recipient
   p_initiator_party_id IN  NUMBER  :=FND_API.G_MISS_NUM  ,
   p_initiator_account_id IN NUMBER  :=FND_API.G_MISS_NUM
)
IS
  l_api_name           CONSTANT VARCHAR2(30) := 'DELETE';
  l_api_version        CONSTANT NUMBER       := 1.0;
  l_quote_status       VARCHAR2(15);
  l_quote_status_id    NUMBER;
  l_quote_header_rec   aso_quote_pub.Qte_Header_Rec_Type
                       := aso_quote_pub.g_miss_qte_header_rec;
  l_quote_header_id   NUMBER;
  l_last_update_date  DATE;
  l_quote_recip_id    NUMBER;
  l_party_id          NUMBER;
  l_cust_account_id   NUMBER;
  l_retrieval_number  NUMBER := FND_API.G_MISS_NUM;

cursor c_get_quote_status is
  select quote_status_id
  from aso_quote_statuses_vl
  where status_code = 'INACTIVE';

cursor c_get_recip_id(c_qte_header_id number) is
  select quote_sharee_id
  from ibe_sh_quote_access
  where quote_header_id = c_qte_header_id;

cursor c_get_party_id is
  select party_id, cust_account_id
  from aso_quote_headers_all
  where quote_header_id = p_quote_header_id;


rec_get_quote_status c_get_quote_status%rowtype;
rec_get_recip_id     c_get_recip_id%rowtype;
rec_get_party_id     c_get_party_id%rowtype;

BEGIN
--   IBE_Util.Enable_Debug;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('START IBE_Quote_Save_pvt.Delete()');
   END IF;
   --DBMS_OUTPUT.PUT_line('Begin IBE_Quote_Save_pvt.Delete()');
   -- Standard Start of API savepoint
   SAVEPOINT    DELETE_pvt;
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

   -- API body

   -- get quote owner partyid
   for rec_get_party_id in c_get_party_id loop
       l_party_id        := rec_get_party_id.party_id;
       l_cust_account_id := rec_get_party_id.cust_account_id;
       exit when c_get_party_id%notfound;
   end loop;
   -- if initiator is specified, and owner is not initiator,
   -- send a retieval number here and to the save call (if expunge=F)
   if ((p_initiator_party_id <> FND_API.G_MISS_NUM) and l_party_id <> p_initiator_party_id) then
     select quote_sharee_number into l_retrieval_number
     from ibe_sh_quote_access
     where party_id = p_initiator_party_id
     and quote_header_id = p_quote_header_id
     and cust_account_id = p_initiator_account_id;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Recipient is deleting the cart.  Partyid: ' || p_initiator_party_id || ' RetrievalNumber: ' || l_retrieval_number);
     END IF;
   end if;
   -- User Authentication
   --DBMS_OUTPUT.PUT_line('validate_user_update start ');
   -- if there is no qte access tbl, then we're in the owner only flow
   IF (nvl(p_Quote_access_tbl.count,0) = 0) THEN
     IBE_Quote_Misc_pvt.Validate_User_Update
     (
      p_init_msg_list          => FND_API.G_TRUE
     ,p_quote_header_id        => p_quote_header_id
     ,p_validate_user          => FND_API.G_TRUE
     ,p_quote_retrieval_number => l_retrieval_number
     ,p_privilege_type_code    => 'A'
     ,p_save_type              => OP_DELETE_CART
     ,p_last_update_date       => p_last_update_date
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data

    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --DBMS_OUTPUT.PUT_line('validate_user_update start end ');
  END IF;

   -- get quote stutus
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('get quote stutus');
   END IF;
   l_quote_status := IBE_Quote_Misc_pvt.get_Quote_status(p_quote_header_id);

   IF (l_quote_status = 'NOT_EXIST') THEN
      --DBMS_OUTPUT.PUT_line('Quote not exists ');
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Quote not exists ');
      END IF;
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
         FND_Message.Set_Name('IBE', 'IBE_SC_NO_QUOTE_EXIST');
         FND_Msg_Pub.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF (l_quote_status = 'ORDERED')  THEN
      --DBMS_OUTPUT.PUT_line('Quote ordered ');
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Quote ordered ');
      END IF;
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
         FND_Message.Set_Name('IBE', 'IBE_SC_QUOTE_IS_ORDERED');
         FND_Msg_Pub.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --Removing this validation because this is aleady being done in validate_user_update
/*   -- validate last_update_date
   IF (p_last_update_date is not null
       and p_last_update_date <> FND_API.G_MISS_DATE) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('validate last_update_date ');
      END IF;
      IBE_Quote_Misc_pvt.validateQuoteLastUpdateDate
      (   p_api_version_number   => p_api_version_number
           ,p_quote_header_id     => p_quote_header_id
           ,p_last_update_date    => p_last_update_date
           ,X_Return_Status       => x_return_status
           ,X_Msg_Count           => x_msg_count
           ,X_Msg_Data            => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;*/

  -- makulkar: Moving the deactivate quote code before expunge flag check. Bug 3715127.

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Quote_save_pvt.Delete: Ready to call deactivate_quote');
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Ready to call IBE_QUOTE_SAVESHARE_V2_PVT.Stop_sharing');
  END IF;
  --DBMS_OUTPUT.PUT_line('Ready to call IBE_QUOTE_SAVESHARE_V2_PVT.Stop_sharing');
    -- Stop sharing this quote if this is a shared quote.
  IBE_QUOTE_SAVESHARE_V2_PVT.stop_sharing (
      p_quote_header_id  => p_quote_header_id      ,
      p_delete_context   => 'IBE_SC_CART_DELETED',
      P_minisite_id      => p_minisite_id          ,
      p_notes            => p_notes                ,
      p_quote_access_tbl => p_quote_access_tbl     ,
      p_api_version      => p_api_version_number   ,
      p_init_msg_list    => fnd_api.g_false        ,
      p_commit           => fnd_api.g_false        ,
      x_return_status    => x_return_status        ,
      x_msg_count        => x_msg_count            ,
      x_msg_data         => x_msg_data             );


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    --DBMS_OUTPUT.PUT_line('Done calling IBE_QUOTE_SAVESHARE_V2_PVT.Stop_sharing ');
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Done calling IBE_QUOTE_SAVESHARE_V2_PVT.Stop_sharing');
    END IF;


   --MANNAMRA:Changes for save/share project(09/12/02)
   /*If p_expunge_flag is true then call aso_quote_pub.delete, else
     invalidate the quote setting the quote status to 'INVALID' status
     and expiring the quote*/

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('expunge flag is: '||p_expunge_flag);
  END IF;
  --dbms_output.put_line('expunge flag is: '||p_expunge_flag);
  IF(p_expunge_flag = FND_API.G_TRUE ) THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expunge flag is true') ;
    END IF;
    --DBMS_OUTPUT.PUT_line('Expunge flag is true');
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('ASO_Quote_Pub.Delete_Quote() starts');
    END IF;
    --DBMS_OUTPUT.PUT_line('ASO_Quote_Pub.Delete_Quote() starts');


    ASO_Quote_Pub.Delete_quote(
         P_Api_Version_Number => P_Api_Version_Number
        ,P_Init_Msg_List     => FND_API.G_FALSE
        ,P_Commit            => FND_API.G_FALSE
        ,P_qte_header_id     => P_Quote_Header_Id
        ,x_Return_Status     => x_return_status
        ,x_Msg_Count         => x_msg_count
        ,x_Msg_Data          => x_msg_data );



    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('ASO_Quote_Pub.Delete_Quote() finishes');
    END IF;
    --DBMS_OUTPUT.PUT_line('ASO_Quote_Pub.Delete_Quote() finishes');
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  ELSE
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expunge flag is false');
    END IF;
    --DBMS_OUTPUT.PUT_line(' Expunge flag is false');
    FOR rec_get_quote_status in c_get_quote_status LOOP
      l_quote_Status_id := rec_get_quote_status.quote_status_id;
      exit when c_get_quote_status%notfound;
    END LOOP;
    l_quote_header_rec.quote_header_id       := p_quote_header_id;
    l_quote_header_rec.last_update_date      := p_last_update_date;
    --Forcing the quote to inactivate
    l_quote_header_rec.quote_status_id       := l_quote_Status_id;
    --Forcing the quote to expire
    l_quote_header_rec.quote_expiration_date := trunc(sysdate);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Values of quote header rec before calling Save API');
    END IF;

    --DBMS_OUTPUT.PUT_line('l_quote_header_rec.quote_header_id :'||l_quote_header_rec.quote_header_id);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('l_quote_header_rec.quote_header_id :'||l_quote_header_rec.quote_header_id);
       IBE_UTIL.DEBUG('l_quote_header_rec.quote_status_id :'||l_quote_header_rec.quote_status_id);
       IBE_UTIL.DEBUG('l_quote_header_rec.last_update_date :'||l_quote_header_rec.last_update_date);
    END IF;
    --DBMS_OUTPUT.PUT_line('calling save ');
    ibe_quote_save_pvt.save(
        p_api_version_number => p_api_version_number               ,
        p_init_msg_list      => fnd_api.g_false                    ,
        p_commit             => fnd_api.g_false                    ,
        p_sharee_Number      => l_retrieval_number                 ,
        p_save_type          => OP_DELETE_CART                     ,
        p_qte_header_rec     => l_Quote_header_rec                 ,
        x_quote_header_id    => l_quote_header_id                  ,
        x_last_update_date   => l_last_update_date                 ,

        x_return_status      => x_return_status                    ,
        x_msg_count          => x_msg_count                        ,
        x_msg_data           => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  --DBMS_OUTPUT.PUT_line('Done calling save ');
  END IF; --expunge_flag check

  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count    ,
                            p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End   IBE_Quote_Save_pvt.Delete()');
  END IF;
  -- IBE_Util.Disable_Debug;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Expected error: End   IBE_Quote_Save_pvt.Delete()');
      END IF;

      ROLLBACK TO DELETE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
            --IBE_Util.Disable_Debug;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error: End   IBE_Quote_Save_pvt.Delete()');
      END IF;
      ROLLBACK TO DELETE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      -- IBE_Util.Disable_Debug;
   WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown error: End   IBE_Quote_Save_pvt.Delete()');
      END IF;
      ROLLBACK TO DELETE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      --IBE_Util.Disable_Debug;
END DELETE;


PROCEDURE DeleteAllLines(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2                       ,
   p_quote_header_id    IN  NUMBER                         ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_sharee_number      IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE
)
is
  l_api_name         CONSTANT VARCHAR2(30)   := 'DELETEALLLINES';
  l_api_version      CONSTANT NUMBER         := 1.0;

  l_quote_line_id    number;
  l_control_rec      ASO_Quote_Pub.Control_Rec_Type;
  l_qte_header_rec   ASO_Quote_Pub.QTE_HEADER_REC_TYPE
                                    := ASO_Quote_Pub.g_miss_qte_header_rec;
  l_qte_line_rec     ASO_Quote_Pub.QTE_LINE_REC_TYPE
                                    := ASO_Quote_Pub.g_miss_qte_line_rec;
  l_qte_line_tbl     ASO_Quote_Pub.QTE_LINE_TBL_TYPE
                                     := ASO_Quote_Pub.g_miss_qte_line_tbl;


  cursor c_getlineids(p_quote_header_id number) is
  select quote_line_id
  from aso_quote_lines
  where quote_header_id = p_quote_header_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    DELETEALLLINES_pvt;
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

   -- API body

    -- User Authentication
   IBE_Quote_Misc_pvt.Validate_User_Update
   ( p_init_msg_list               => p_init_msg_list
    ,p_quote_header_id          => p_quote_header_id
    ,p_quote_retrieval_number     => p_sharee_number
    ,p_validate_user          => FND_API.G_TRUE
    ,x_return_status              => x_return_status
    ,x_msg_count              => x_msg_count
    ,x_msg_data                   => x_msg_data
    );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  -- 8/24/2002

   l_qte_header_rec.quote_header_id := p_quote_header_id;

   open c_getlineids(p_quote_header_id);
   loop
   fetch c_getlineids into l_quote_line_id;
      exit when c_getlineids%notfound;
      l_qte_line_rec.quote_header_id := l_qte_header_rec.quote_header_id;
      l_qte_line_rec.quote_line_id   := l_quote_line_id;
      l_qte_line_rec.operation_code  := 'DELETE';
      l_qte_line_tbl(l_qte_line_tbl.count+1) := l_qte_line_rec;
   end loop;
   close c_getlineids;

   l_control_rec.pricing_request_type          := 'ASO';
   l_control_rec.header_pricing_event          := FND_Profile.Value('IBE_INCART_PRICING_EVENT');
   l_control_rec.line_pricing_event            :=  FND_API.G_MISS_CHAR;
   l_control_rec.calculate_freight_charge_flag := 'Y';
   l_control_rec.calculate_tax_flag            := 'Y';

   ibe_quote_save_pvt.SAVE
   (   p_api_version_number     => p_api_version_number
       ,p_init_msg_list         => FND_API.G_FALSE
       ,p_commit                => FND_API.G_FALSE
       ,p_sharee_Number         => p_sharee_Number
       ,p_qte_header_rec        => l_qte_header_rec
       ,p_qte_line_tbl          => l_qte_line_tbl
       ,p_control_rec           => l_control_rec
       ,x_quote_header_id       => x_quote_header_id
       ,x_last_update_date      => x_last_update_date
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- End of API body.
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.

    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Expected error: IBE_Quote_Save_pvt.DeleteAllLines()');
      END IF;
    ROLLBACK TO DELETEALLLINES_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Unexpected error:IBE_Quote_Save_pvt.DeleteAllLines()');
      END IF;

    ROLLBACK TO DELETEALLLINES_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count,
                              p_data    => x_msg_data);
    WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Unknown error: IBE_Quote_Save_pvt.DeleteAllLines()');
      END IF;

      ROLLBACK TO DELETEALLLINES_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END DeleteAllLines;


PROCEDURE Set_Last_Update_Date(p_qte_header_id IN NUMBER,
                       px_last_update_date OUT NOCOPY DATE)
IS
BEGIN
  IF p_qte_header_id <> FND_API.G_MISS_NUM THEN
    px_last_update_date := IBE_Quote_Misc_pvt.getQuoteLastUpdateDate(p_qte_header_id);
  END IF;
END Set_Last_Update_Date;

-- formerly AddItemsToCart; the original addItemsToCart
-- this is the one that handles adding of std, services, cartlevel services
PROCEDURE AddItemsToCart_orig(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_ql_line_codes            IN   jtf_number_table       := NULL
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec

  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,P_save_flag                IN   NUMBER := SAVE_ADDTOCART

  ,x_quote_header_id          OUT NOCOPY  varchar2
  ,x_Qte_Line_Tbl             OUT NOCOPY  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
)
is

  l_api_name                        CONSTANT VARCHAR2(30)   := 'AddItemsToCart';
  l_api_version                     CONSTANT NUMBER         := 1.0;

  lx_Qte_Header_Rec            ASO_Quote_Pub.Qte_Header_Rec_Type       := p_Qte_Header_Rec;
  lx_Hd_Price_Attributes_Tbl   ASO_Quote_Pub.Price_Attributes_Tbl_Type := p_Hd_Price_Attributes_Tbl;
  lx_Hd_Payment_Tbl            ASO_Quote_Pub.Payment_Tbl_Type          := p_Hd_Payment_Tbl;

  lx_Hd_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type         := p_Hd_Shipment_Tbl;
  lx_Hd_Shipment_Rec            ASO_Quote_Pub.Shipment_Rec_Type;
  lx_Hd_Freight_Charge_Tbl      ASO_Quote_Pub.Freight_Charge_Tbl_Type   := p_Hd_Freight_Charge_Tbl;
  lx_Hd_Tax_Detail_Tbl          ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE       := p_Hd_Tax_Detail_Tbl;

  l_Qte_Line_Tbl                ASO_Quote_Pub.Qte_Line_Tbl_Type;
  l_Qte_Line_Dtl_Tbl            ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
  lx_Qte_Line_Dtl_Tbl           ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
  lx_Line_Attr_Ext_Tbl          ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type;
  lx_Line_rltship_tbl           ASO_Quote_Pub.Line_Rltship_Tbl_Type;

  lx_Ln_Price_Attributes_Tbl    ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Ln_Payment_Tbl             ASO_Quote_Pub.Payment_Tbl_Type;
  lx_Ln_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Ln_Freight_Charge_Tbl      ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Ln_Tax_Detail_Tbl          ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Price_Adjustment_Tbl       ASO_Quote_Pub.Price_Adj_Tbl_Type        := p_Price_Adjustment_Tbl;
  lx_Price_Adj_Attr_Tbl         ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type   := p_Price_Adj_Attr_Tbl;
  lx_Price_Adj_Rltship_Tbl      ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type:= p_Price_Adj_Rltship_Tbl;

  l_ibeItemTypeSize             number;
  l_itemIdListSRVSize           number;
  l_quoteLineSize               number;
  l_quoteLineDetSize            number;

  l_svcIndex                    number;
  l_chkPrevRefLine              number                 := NULL;
  l_itemIdListSRV               jtf_number_table       := NULL;
  l_uomCodeListSRV              JTF_VARCHAR2_TABLE_100 := NULL;
  l_periodListSRV               JTF_VARCHAR2_TABLE_100 := NULL;
  l_durationListSRV             JTF_VARCHAR2_TABLE_100 := NULL;

  l_isCartEmpty                 varchar2(1)      := 'N';
  l_isCartSupp                  varchar2(1)      := 'N';
  l_line_level_services         varchar2(1)      := 'N';
  l_numLines                    number           := 0;
  l_hasSVA                      varchar2(1)      := 'N';
  l_hasQueriedItems             varchar2(1)      := 'N';

  l_suppLevelProfileValue       varchar2(30);
  l_profValueSize               number;
  l_commIndex                   number;
  l_startIndex                  number;
  l_quote_line_id               number;
  l_checkActiveCartId           number;
  l_attach_contract             VARCHAR2(1);
  l_contract_template_id        NUMBER;
  l_trans_Contract_templ_id     NUMBER;

  --temp vars for NOCOPY OUT params.
  lx_Qte_Header_Rec_tmp            ASO_Quote_Pub.Qte_Header_Rec_Type       := p_Qte_Header_Rec;
  lx_Hd_Price_Attributes_Tbl_tmp   ASO_Quote_Pub.Price_Attributes_Tbl_Type := p_Hd_Price_Attributes_Tbl;
  lx_Hd_Payment_Tbl_tmp            ASO_Quote_Pub.Payment_Tbl_Type          := p_Hd_Payment_Tbl;
  lx_Hd_Shipment_Tbl_tmp           ASO_Quote_Pub.Shipment_Tbl_Type         := p_Hd_Shipment_Tbl;
  lx_Hd_Freight_Charge_Tbl_tmp     ASO_Quote_Pub.Freight_Charge_Tbl_Type   := p_Hd_Freight_Charge_Tbl;
  lx_Hd_Tax_Detail_Tbl_tmp         ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE       := p_Hd_Tax_Detail_Tbl;
  lx_Price_Adjustment_Tbl_tmp      ASO_Quote_Pub.Price_Adj_Tbl_Type        := p_Price_Adjustment_Tbl;
  lx_Price_Adj_Attr_Tbl_tmp        ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type   := p_Price_Adj_Attr_Tbl;
  lx_Price_Adj_Rltship_Tbl_tmp     ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type:= p_Price_Adj_Rltship_Tbl;

  l_suppLevelLookupName VARCHAR2(30);

  cursor c_getServiceInvId (l_quote_header_id number)
    is
    select  aqld.service_ref_line_id refLine, aql2.inventory_item_id invId
      from  ASO_QUOTE_LINES          aql,
            ASO_QUOTE_LINES          aql2,
            ASO_QUOTE_LINE_DETAILS   aqld
      where aql.item_type_code  = 'SVA'                    and
            aql.quote_line_id   = aqld.service_ref_line_id and
            aql.quote_header_id = l_quote_header_id        and
            aqld.quote_line_id  = aql2.quote_line_id
      order by  aql2.QUOTE_LINE_ID;

  cursor c_getItemInfo (l_inventory_item_id number, l_organization_id number)
    is
    select  PRIMARY_UOM_CODE uomCode, SERVICE_DURATION_PERIOD_CODE period, SERVICE_DURATION duration
    from  MTL_SYSTEM_ITEMS_VL
    where inventory_item_id = l_inventory_item_id      and
          organization_id   = l_organization_id;

  Cursor c_find_service(c_service_ref_line_id number) is
  Select ql.quote_line_id
  From aso_quote_lines ql, aso_quote_line_details qld
  where ql.quote_line_id   = qld.quote_line_id
  And qld.service_ref_line_id = c_service_ref_line_id;

  rec_service      c_getServiceInvId%rowtype;
  rec_itemInfo     c_getItemInfo%rowtype;
  rec_find_service c_find_service%rowtype;

  l_combinesameitem   VARCHAR2(2) := FND_API.G_MISS_CHAR;

  --maithili added for R12
  Cursor c_get_Marketing_source(p_quote_header_id NUMBER) is
    select marketing_source_code_id
    from aso_quote_headers_all
    where quote_header_id = p_quote_header_id;

  l_marketing_source_code_id  NUMBER;

  l_Hd_Price_Attributes_Tbl_temp   ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  l_Hd_Price_Attributes_Tbl_DB   ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  l_pricingIndex NUMBER := 1;

  Cursor c_get_hdr_pricing_attributes(p_quote_header_id NUMBER) is
    select pricing_attribute1
    from aso_price_attributes
    where quote_header_id = p_quote_header_id
    and quote_line_id is null;

    rec_pricing_attr_info c_get_hdr_pricing_attributes%rowtype;

  Cursor c_get_support_level(p_support_lookup_type VARCHAR2, p_support_lookup_code VARCHAR2) is
    select 1 from fnd_lookups
    where lookup_type = p_support_lookup_type
    and   lookup_code = p_support_lookup_code;

    support_level_check    number;


BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT AddItemsToCartorig_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                     P_Api_Version_Number,
                                     L_API_NAME   ,
                                     G_PKG_NAME )
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_Msg_Pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_Quote_Save_pvt.AddItemsToCart_orig()');
  END IF;

  lx_Hd_Payment_Tbl    := p_Hd_Payment_Tbl;
  lx_Hd_Shipment_Tbl   := p_Hd_Shipment_Tbl;
  lx_Hd_Tax_Detail_Tbl := p_Hd_Tax_Detail_Tbl;
  lx_Qte_Header_Rec    := p_Qte_Header_Rec;

    -- IBE_Util.Enable_Debug;

    l_Qte_Line_Tbl     := p_Qte_Line_Tbl;
    l_Qte_Line_Dtl_Tbl := p_Qte_Line_Dtl_Tbl;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Save_flag in AddItemsToCart_orig is: '||p_save_flag);
    END IF;

    -- Check for cart level support
    if (( FND_Profile.Value('IBE_USE_SUPPORT_CART_LEVEL') <> 'N') AND
       ((FND_Profile.Value('IBE_USE_SUPPORT') = 'N') OR (FND_Profile.Value('IBE_USE_SUPPORT') is null ))) then
      l_isCartSupp := 'Y';
    else
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Cart level support turned off ');
      END IF;
    end if;
    -- Check for line level support
    IF ((FND_Profile.Value('IBE_USE_SUPPORT') <> 'N') and
      (FND_Profile.Value('IBE_USE_SUPPORT') is not null)) THEN

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Line level support profile turned on');
      END IF;
      l_line_level_services := 'Y';
    ELSE
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Line level support profile turned off');
      END IF;
    END IF;

    --DBMS_OUTPUT.PUT_line('l_isCartSupp='||l_isCartSupp);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_isCartSupp='||l_isCartSupp);
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_line_level_services = '||l_line_level_services);
    END IF;

    IF (p_Qte_Header_Rec.quote_header_id is null) THEN
      l_isCartEmpty := 'Y';
    END IF;
    --DBMS_OUTPUT.PUT_line('l_isCartEmpty='||l_isCartEmpty);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_isCartEmpty='||l_isCartEmpty);
    END IF;

    --Cart level support logic
    IF (l_isCartSupp = 'Y') THEN

      IF ((p_Qte_Header_Rec.quote_header_id is not null)
         and (p_Qte_Header_Rec.quote_header_id <> FND_API.G_MISS_NUM) ) THEN
        --Check the number of quote lines in the quote
        SELECT COUNT(*) INTO l_numLines
        FROM aso_quote_lines
        WHERE quote_header_id = p_Qte_Header_Rec.quote_header_id;
      END IF;

      --DBMS_OUTPUT.PUT_line('l_numLines='||l_numLines);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_numLines='||l_numLines);
      END IF;

      IF ((l_isCartEmpty = 'Y') or (l_numLines = 0)) THEN
        l_isCartEmpty := 'Y';
      END IF;

      --DBMS_OUTPUT.PUT_line('l_isCartEmpty='||l_isCartEmpty);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_isCartEmpty='||l_isCartEmpty);
      END IF;

      IF ((p_Qte_Header_Rec.quote_header_id is not null)
         and (p_Qte_Header_Rec.quote_header_id <> FND_API.G_MISS_NUM) ) THEN
        --Get the number of serviceable items in the quote
        SELECT COUNT(*) INTO l_numLines
        FROM aso_quote_lines
        WHERE quote_header_id = p_Qte_Header_Rec.quote_header_id and
            item_type_code  = 'SVA';
      END IF;

      IF (l_numLines > 0) THEN
        --Quote has serviceable items
        l_hasSVA := 'Y';
      END IF;
      --DBMS_OUTPUT.PUT_line('l_hasSVA='||l_hasSVA);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_hasSVA='||l_hasSVA);
      END IF;

      -- added 8/4/03: if merge case, we might not want to pass SRV info down
      IF (p_combinesameitem = FND_API.G_MISS_CHAR) THEN
        l_combinesameitem := FND_Profile.Value('IBE_SC_MERGE_SHOPCART_LINES');
      Else
        l_combinesameitem := p_combinesameitem;
      END IF;

      IF  ((p_ql_line_codes is not null) and (l_isCartSupp = 'Y') ) THEN   -- for backward compatibility w/ addModelToCart

        l_ibeItemTypeSize  := p_ql_line_codes.count;
        l_quoteLineSize    := l_Qte_Line_Tbl.count;
        l_quoteLineDetSize := p_Qte_Line_Dtl_Tbl.count;

        FOR i in 1..l_ibeItemTypeSize LOOP

          -- added 8/4/03: if merge case, we might not want to pass SRV info down
          l_numLines := 0;
          IF ((p_Qte_Header_Rec.quote_header_id is not null)
             and (p_Qte_Header_Rec.quote_header_id <> FND_API.G_MISS_NUM) ) THEN
             SELECT COUNT(inventory_item_id) INTO l_numLines
             FROM aso_quote_lines
             WHERE quote_header_id = p_Qte_Header_Rec.quote_header_id and
                   inventory_item_id = l_Qte_Line_Tbl(i).inventory_item_id;
          END IF;

          IF ((p_ql_line_codes(i)  = SERVICEABLE_LINE_CODE) and
             ((l_combinesameitem is null) or (l_combinesameitem = 'N') or (l_numLines = 0)) ) THEN      -- SVA

          --DBMS_OUTPUT.PUT_line('Service! p_ql_line_codes(i)='||SERVICEABLE_LINE_CODE);
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('Service! p_ql_line_codes(i)='||SERVICEABLE_LINE_CODE);
            END IF;

            -- if we have not gotten a list of the support services and cart is not empty
            IF ((l_itemIdListSRV is null)
              and (l_isCartEmpty = 'N') ) THEN
               --DBMS_OUTPUT.PUT_line('l_itemIdListSRV is null');
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug('l_itemIdListSRV is null');
              END IF;

              l_svcIndex := 1;

              FOR rec_service in c_getServiceInvId( p_Qte_Header_Rec.quote_header_id)  LOOP

                IF(l_itemIdListSRV is NULL ) THEN
                  l_itemIdListSRV := JTF_NUMBER_TABLE();
                END IF;
                IF (l_chkPrevRefLine is null) THEN                          -- if we're just starting
                   --DBMS_OUTPUT.PUT_line('just starting: l_svcIndex ='||l_svcIndex);
                  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_Util.Debug('just starting: l_svcIndex ='||l_svcIndex);
                  END IF;

                  l_chkPrevRefLine := rec_service.refLine;
                  l_itemIdListSRV.extend();
                  l_itemIdListSRV(l_svcIndex) := rec_service.invId;
                  l_svcIndex := l_svcIndex + 1;
                ELSE                                                        -- else we're not
                  IF (l_chkPrevRefLine = rec_service.refLine) then          -- if we have the same ref line as the previous
                    --DBMS_OUTPUT.PUT_line('same ref line: l_svcIndex ='||l_svcIndex);
                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_Util.Debug('same ref line: l_svcIndex ='||l_svcIndex);
                    END IF;
                    l_itemIdListSRV.extend();
                    l_itemIdListSRV(l_svcIndex) := rec_service.invId;
                    l_svcIndex := l_svcIndex + 1;
                  ELSE                                                      -- else we're done
                     --DBMS_OUTPUT.PUT_line(' done: l_svcIndex ='||l_svcIndex);
                    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                      IBE_Util.Debug(' done: l_svcIndex ='||l_svcIndex);
                    END IF;
                    EXIT;
                  END IF; --If we have the same service ref line as the previous one
                END IF; --If (l_chkPrevRefLine is null)
                EXIT WHEN c_getServiceInvId%notfound;
              END LOOP;
            END IF;     --if l_itemIdListSRV is null and cart is not empty

            -- if add 1st item to cart
            l_suppLevelLookupName := rtrim(ltrim(FND_Profile.Value('IBE_CART_LEVEL_SUPPORT_LOOKUP')));
            l_suppLevelProfileValue := rtrim(ltrim(FND_Profile.Value('IBE_PREFERED_SUPPORT_LEVEL')));


            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_Util.Debug('Support Level Lookup Name: ' || l_suppLevelLookupName);
               IBE_Util.Debug('Prefered Support Level : ' || l_suppLevelProfileValue);
            END IF;

            OPEN c_get_support_level(l_suppLevelLookupName,l_suppLevelProfileValue);
            fetch c_get_support_level into support_level_check;

            IF c_get_support_level%NOTFOUND THEN
               l_suppLevelProfileValue := null;
            END IF;
            CLOSE c_get_support_level;

            --l_suppLevelProfileValue := '478,478';
            IF ((l_itemIdListSRV is null)
               and (l_suppLevelProfileValue is not null)
               and (l_suppLevelProfileValue <> 'NONE') and (l_hasSVA = 'N') ) THEN
              -- parse suppLevelProfileValue -- delimiter = ',' -> put in l_itemIdListSRV
              l_itemIdListSRV  := JTF_NUMBER_TABLE();
              l_profValueSize  := length(l_suppLevelProfileValue);
              l_startIndex     := 1;
              --DBMS_OUTPUT.PUT_line(' start: l_profValueSize ='||l_profValueSize);
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug(' start: l_profValueSize ='||l_profValueSize);
              END IF;

              FOR firstItmIndx in 1..l_profValueSize LOOP
                l_commIndex := instr(l_suppLevelProfileValue, ',', 1, firstItmIndx);
                IF (l_commIndex = 0) THEN
                  l_commIndex := l_profValueSize - l_startIndex + 1;
                ELSE
                  l_commIndex := l_commIndex - l_startIndex;
                END IF;
                --DBMS_OUTPUT.PUT_line(' l_startIndex ='||l_startIndex);
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug(' l_startIndex ='||l_startIndex);
                END IF;
                --DBMS_OUTPUT.PUT_line(' l_commIndex ='||l_commIndex);
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug(' l_commIndex ='||l_commIndex);
                END IF;

                l_itemIdListSRV.extend();
                  --DBMS_OUTPUT.PUT_line(' substr(l_suppLevelProfileValue, l_startIndex, l_commIndex)='||substr(l_suppLevelProfileValue, l_startIndex, l_commIndex));
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug(' substr(l_suppLevelProfileValue, l_startIndex, l_commIndex)='||substr(l_suppLevelProfileValue, l_startIndex, l_commIndex));
                END IF;
                l_itemIdListSRV(firstItmIndx) := to_number(substr(l_suppLevelProfileValue, l_startIndex, l_commIndex));
                l_startIndex                  := l_startIndex + l_commIndex + 1;
                --DBMS_OUTPUT.PUT_line(' l_itemIdListSRV(firstItmIndx)='||l_itemIdListSRV(firstItmIndx));
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug(' l_itemIdListSRV(firstItmIndx)='||l_itemIdListSRV(firstItmIndx));
                END IF;

                IF (l_startIndex > l_profValueSize) THEN
                  EXIT;
                END IF;

              END LOOP; --firstItmIndx in 1..l_profValueSize
            END IF; --If (IteIdListSRV is null)

            IF (l_itemIdListSRV is null) THEN
             -- there are no SRV items found -- should exit
              exit;
            ELSE
              /*
              Once we have valid values for l_itemIdListSRV, build structures for services:
              ** continue from regular lines
              quote_line_tbl
              quote_line_details_tbl - pass in the correct line_index corresponding to the lines in quote_line_tbl
              */

              -- for performance reasons we can keep track of values that have already been queried from mtl_system_items_vl table
              IF (l_uomCodeListSRV is null) THEN
                l_uomCodeListSRV    := JTF_VARCHAR2_TABLE_100();
                l_periodListSRV     := JTF_VARCHAR2_TABLE_100();
                l_durationListSRV   := JTF_VARCHAR2_TABLE_100();
              ELSE
                l_hasQueriedItems   := 'Y';
              END IF;

              l_itemIdListSRVSize := l_itemIdListSRV.count;
              FOR j in 1..l_itemIdListSRVSize LOOP

              -- for performance reasons we can keep track of values that have already been queried from mtl_system_items_vl table
                IF (l_hasQueriedItems   = 'N') THEN
                  OPEN c_getItemInfo (l_itemIdListSRV(j), l_Qte_Line_Tbl(i).organization_id);
                    fetch c_getItemInfo into rec_itemInfo;
                  close c_getItemInfo;

                  l_uomCodeListSRV.extend();
                  l_uomCodeListSRV(j) := rec_itemInfo.uomCode;
                  l_periodListSRV.extend();
                  l_periodListSRV(j)  := rec_itemInfo.period;
                  l_durationListSRV.extend();
                  l_durationListSRV(j):= rec_itemInfo.duration;
                  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_Util.Debug('Quertying mtl_sytem_items_vl the first time');
                  END IF;
                END IF;           -- if we haven't queried mtl_system_items_vl table

                l_Qte_Line_Tbl(l_quoteLineSize+j).quote_header_id   := p_Qte_Header_Rec.quote_header_id;
                l_Qte_Line_Tbl(l_quoteLineSize+j).inventory_item_id := l_itemIdListSRV(j);
                l_Qte_Line_Tbl(l_quoteLineSize+j).organization_id   := l_Qte_Line_Tbl(i).organization_id;
                l_Qte_Line_Tbl(l_quoteLineSize+j).quantity          := l_Qte_Line_Tbl(i).quantity;
                l_Qte_Line_Tbl(l_quoteLineSize+j).uom_code          := l_uomCodeListSRV(j);     -- 'YR'
                l_Qte_Line_Tbl(l_quoteLineSize+j).operation_code    := 'CREATE';
                l_Qte_Line_Tbl(l_quoteLineSize+j).start_date_active := sysdate;
                l_Qte_Line_Tbl(l_quoteLineSize+j).item_type_code    := 'SRV';

                l_Qte_Line_Dtl_Tbl(l_quoteLineDetSize+j).qte_line_index             := l_quoteLineSize+j;
                l_Qte_Line_Dtl_Tbl(l_quoteLineDetSize+j).service_ref_type_code      := 'QUOTE';
                l_Qte_Line_Dtl_Tbl(l_quoteLineDetSize+j).service_ref_qte_line_index := i;
                l_Qte_Line_Dtl_Tbl(l_quoteLineDetSize+j).operation_code             := 'CREATE';
                l_Qte_Line_Dtl_Tbl(l_quoteLineDetSize+j).service_period             := l_periodListSRV(j);   -- 'YR'
                l_Qte_Line_Dtl_Tbl(l_quoteLineDetSize+j).service_duration           := l_durationListSRV(j); -- 3
              END LOOP;
            END IF;                                                          -- if there are service items
          END IF;                                                             -- SVA

          l_quoteLineSize    := l_Qte_Line_Tbl.count;
          l_quoteLineDetSize := l_Qte_Line_Dtl_Tbl.count;
            --DBMS_OUTPUT.PUT_line('i:'||i||' *inventory_item_id = '||l_Qte_Line_Tbl(i).inventory_item_id);
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('i:'||i||' *inventory_item_id = '||l_Qte_Line_Tbl(i).inventory_item_id);
          END IF;
        END LOOP;                                                              -- loop through p_ql_line_codes
      END IF;                                                                  -- if p_ql_line_codes is not null
    ELSIF(l_line_level_services = 'Y') THEN

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Entering the logic for line level support');
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('IBE_QUOTE_MISC_PVT.get_multi_svc_profile: '||IBE_QUOTE_MISC_PVT.get_multi_svc_profile);
      END IF;

      --CHANGES FOR LINE LEVEL SERVICES
      IF(IBE_QUOTE_MISC_PVT.get_multi_svc_profile <> 'T')  THEN

        FOR i in 1..p_Qte_Line_Dtl_Tbl.count LOOP
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('p_Qte_Line_Dtl_Tbl(i).service_ref_type_code: '||p_Qte_Line_Dtl_Tbl(i).service_ref_type_code);
            IBE_Util.Debug('p_Qte_Line_Dtl_Tbl(i).operation_code: '||p_Qte_Line_Dtl_Tbl(i).operation_code);
            IBE_Util.Debug('p_Qte_Line_Dtl_Tbl(i).service_ref_line_id: '||p_Qte_Line_Dtl_Tbl(i).service_ref_line_id);
          END IF;

          IF(p_Qte_Line_Dtl_Tbl(i).service_ref_type_code <> 'CUSTOMER_PRODUCT')
            and (p_Qte_Line_Dtl_Tbl(i).operation_code = 'CREATE') THEN


            IF(p_Qte_Line_Dtl_Tbl(i).service_ref_line_id is not null and
              p_Qte_Line_Dtl_Tbl(i).service_ref_line_id <> FND_API.g_miss_num) THEN

              FOR rec_find_service in c_find_service(p_Qte_Line_Dtl_Tbl(i).service_ref_line_id) LOOP
                l_quote_line_id := rec_find_service.quote_line_id;
                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug('service aleady exists,l_quote_line_id: '||l_quote_line_id);
                END IF;

                EXIT WHEN c_find_service%NOTFOUND;
              END LOOP;

              IF(l_quote_line_id is not null) THEN

                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug('Service item existing for the service item, deleting the existing one');
                END IF;
                l_Qte_Line_Tbl(l_Qte_Line_Tbl.count+1).quote_line_id  := l_quote_line_id;
                l_Qte_Line_Tbl(l_Qte_Line_Tbl.count).operation_code :=  'DELETE';
              END IF; --(if l_quote_line_id is not null)

            END IF; --If(p_quote_line_detail_tbl.service_ref_line_id)
          END IF;   --If (ref_type_code is 'customer_product')
        END LOOP;
      END IF; -- (Multiple services profile check)
      --END: CHANGES FOR LINE LEVEL SERVICES
    END IF; --line level services or cart level services

  l_ibeItemTypeSize  := l_Qte_Line_Tbl.count;
  for i in 1..l_ibeItemTypeSize loop
    --DBMS_OUTPUT.PUT_line('i:'||i||' *invId = '||l_Qte_Line_Tbl(i).inventory_item_id||' *type = '||l_Qte_Line_Tbl(i).item_type_code);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('i: '||i||' *invId = '||l_Qte_Line_Tbl(i).inventory_item_id);
      IBE_Util.Debug(' *type = '||l_Qte_Line_Tbl(i).item_type_code);
      IBE_Util.Debug('l_Qte_Line_Tbl(i).operation_code: '||l_Qte_Line_Tbl(i).operation_code);
    END IF;
  end loop;
  l_ibeItemTypeSize  := l_Qte_Line_Dtl_Tbl.count;
  FOR i in 1..l_ibeItemTypeSize LOOP
    --DBMS_OUTPUT.PUT_line('i:'||i||' *service_ref_qte_line_index = '||l_Qte_Line_Dtl_Tbl(i).service_ref_qte_line_index||' *qte_line_index = '||l_Qte_Line_Dtl_Tbl(i).qte_line_index);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('i:'||i||' *service_ref_qte_line_index = '||l_Qte_Line_Dtl_Tbl(i).service_ref_qte_line_index||' *qte_line_index = '||l_Qte_Line_Dtl_Tbl(i).qte_line_index);
      IBE_Util.Debug('l_Qte_Line_Dtl_Tbl(i).service_period:   '||l_Qte_Line_Dtl_Tbl(i).service_period);
      IBE_Util.Debug('l_Qte_Line_Dtl_Tbl(i).service_duration: '||l_Qte_Line_Dtl_Tbl(i).service_duration);
      IBE_Util.Debug('l_Qte_Line_Dtl_Tbl(i).service_ref_type_code: '||l_Qte_Line_Dtl_Tbl(i).service_ref_type_code);
    END IF;
  END LOOP;

  --Added during line level services.
  --1. if doing express checkout of items then the api below will retrieve exp settings

  IF(p_save_flag = SAVE_EXPRESSORDER) THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug(' Save_flag is: '||p_save_flag||' Calling IBE_ORD_ONECLICK_PVT.Get_Express_items_settings' );
    END IF;

    IBE_ORD_ONECLICK_PVT.Get_Express_items_settings(
           x_qte_header_rec   => lx_Qte_Header_Rec
          ,p_flag             => 'ITEMS'
          ,x_payment_tbl      => lx_Hd_Payment_Tbl
          ,x_hd_shipment_tbl  => lx_Hd_Shipment_Tbl
          ,x_hd_tax_dtl_tbl   => lx_Hd_Tax_Detail_Tbl);
    lx_qte_header_rec.quote_source_code := 'IStore Oneclick';
    l_attach_contract := FND_API.G_TRUE;

  END IF; --(p_save_type = 'SAVE_EXPRESSORDER')

  -- added 8/11/02: for Default Feature: we have to detect the case where we're defaulting:
  --   1) We're creating an Account Active Cart
  --   2) There's no other Account Active Cart for this particular user
  -- *Note that these conditions are copied from default_header_rec procedure
  IF  p_qte_header_rec.quote_header_id   = FND_API.G_MISS_NUM
    AND p_qte_header_rec.quote_source_code = 'IStore Account'
    AND (p_qte_header_rec.quote_name = 'IBE_PRMT_SC_UNNAMED' --MANNAMRA: 16/09/02:Changed IBEACTIVECART to IBEUNNAMED
    OR p_qte_header_rec.quote_name = FND_API.G_MISS_CHAR)
    AND (p_save_flag <> SAVE_EXPRESSORDER) THEN --Defaulting not required for express check out carts

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug(' need to get active cart');
    END IF;
    l_checkActiveCartId :=
      IBE_Quote_Misc_pvt.Get_Active_Quote_ID(
            p_party_id        => p_qte_header_rec.party_id,
            p_cust_account_id => p_qte_header_rec.cust_account_id);
      -- create quote
    IF (l_checkActiveCartId = 0) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('About to call getHdrDefaultValues');
      END IF;
      getHdrDefaultValues(
            P_Api_Version_Number          => p_api_version_number
           ,p_Init_Msg_List               => p_init_msg_list
           ,p_Commit                      => p_commit
           ,p_minisite_id                 => l_Qte_Line_Tbl(1).minisite_id
           ,p_Qte_Header_Rec              => p_Qte_Header_Rec
           ,p_hd_price_attributes_tbl     => p_hd_price_attributes_tbl
           ,p_hd_payment_tbl              => p_hd_payment_tbl
           ,p_hd_shipment_tbl             => p_hd_shipment_tbl
           ,p_hd_freight_charge_tbl       => p_hd_freight_charge_tbl
           ,p_hd_tax_detail_tbl           => p_hd_tax_detail_tbl
           ,p_price_adjustment_tbl        => p_price_adjustment_tbl
           ,p_price_adj_attr_tbl          => p_price_adj_attr_tbl
           ,p_price_adj_rltship_tbl       => p_price_adj_rltship_tbl
           ,x_Qte_Header_Rec              => lx_Qte_Header_Rec
           ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl
           ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl
           ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl
           ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl
           ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl
           ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl
           ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl
           ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl
           ,x_last_update_date            => x_last_update_date
           ,X_Return_Status               => x_Return_Status
           ,X_Msg_Count                   => x_Msg_Count
           ,X_Msg_Data                    => x_Msg_Data
           );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Back from calling getHdrDefaultValues');
      END IF;
    END IF;
  END IF;

  --maithili added for R12
  /*Check for marketing source code id in the DB, ignore passed in value if DB value already exists */
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Mkt Source code check, lx_Qte_Header_Rec.marketing_source_code_id'||lx_Qte_Header_Rec.marketing_source_code_id);
    IBE_Util.Debug('Mkt Source code check, lx_Qte_Header_Rec.quote_header_id'||lx_Qte_Header_Rec.quote_header_id);
  END IF;
  IF lx_Qte_Header_Rec.marketing_source_code_id is not null and
     lx_Qte_Header_Rec.marketing_source_code_id <> fnd_api.g_miss_num and
     lx_Qte_Header_Rec.quote_header_id is not null and
     lx_Qte_Header_Rec.quote_header_id <> fnd_api.g_miss_num THEN

     OPEN c_get_marketing_source(lx_Qte_Header_Rec.quote_header_id);
     FETCH c_get_marketing_source into l_marketing_source_code_id;
     CLOSE c_get_marketing_source;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('l_marketing_source_code_id'||l_marketing_source_code_id);
       END IF;

     IF (l_marketing_source_code_id is not null) THEN
       lx_Qte_Header_Rec.marketing_source_code_id := FND_API.G_MISS_NUM;
     END IF;
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('After Mkt Source code check, lx_Qte_Header_Rec.marketing_source_code_id'||lx_Qte_Header_Rec.marketing_source_code_id);
  END IF;

  /* Check Duplicate Header Promo Codes, If the passed in promo code value already exists in DB, then do not pass that */
  IF lx_Hd_Price_Attributes_Tbl.count > 0 THEN -- check Duplicate Promo code stuff only if the pricing attr tbl is not null

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Checking for duplicate promo codes'||lx_Hd_Price_Attributes_Tbl.count);
    END IF;

    l_Hd_Price_Attributes_Tbl_temp := lx_Hd_Price_Attributes_Tbl;

    -- Query existing promo codes and populate them in DB array.
    FOR rec_pricing_attr_info in c_get_hdr_pricing_attributes(lx_Qte_Header_Rec.quote_header_id) LOOP
      l_Hd_Price_Attributes_Tbl_DB(l_pricingIndex).pricing_attribute1 := rec_pricing_attr_info.pricing_attribute1;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	    IBE_UTIL.debug('Existing Promo code in DB = '|| l_Hd_Price_Attributes_Tbl_DB(l_pricingIndex).pricing_attribute1 );
        IBE_UTIL.debug('pricing index = '|| l_pricingIndex );
	  END IF;
      l_pricingIndex := l_pricingIndex + 1;

      EXIT WHEN c_get_hdr_pricing_attributes%NOTFOUND;
    END LOOP;

    FOR i IN 1..l_Hd_Price_Attributes_Tbl_temp.count LOOP
      If l_Hd_Price_Attributes_Tbl_temp(i).pricing_attribute1 IS NOT NULL
	  AND l_Hd_Price_Attributes_Tbl_temp(i).pricing_attribute1 <> FND_API.G_MISS_CHAR THEN
        For j IN 1..l_Hd_Price_Attributes_Tbl_DB.count LOOP
		      If l_Hd_Price_Attributes_Tbl_DB(j).pricing_attribute1 IS NOT NULL AND
                 l_Hd_Price_Attributes_Tbl_temp(i).pricing_attribute1 = l_Hd_Price_Attributes_Tbl_DB(j).pricing_attribute1 THEN
				   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
				     IBE_UTIL.debug('Duplicate Promo code = '|| l_Hd_Price_Attributes_Tbl_temp(i).pricing_attribute1||' found, setting pricing attribute rec to G_MISS_CHAR' );
				   END IF;
				   lx_Hd_Price_Attributes_Tbl(i).pricing_attribute1 := FND_API.G_MISS_CHAR;
                   lx_Hd_Price_Attributes_Tbl(i).flex_title         := FND_API.G_MISS_CHAR;
                   lx_Hd_Price_Attributes_Tbl(i).pricing_context    := FND_API.G_MISS_CHAR ;
                   lx_Hd_Price_Attributes_Tbl(i).quote_header_id    := FND_API.G_MISS_NUM;
                   lx_Hd_Price_Attributes_Tbl(i).operation_code     := FND_API.G_MISS_CHAR;
		      END If;
        END LOOP; -- for j loop
      END IF; -- for checking not null check for temp array
    END LOOP;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Before Save, lx_Hd_Price_Attributes_Tbl.count'||lx_Hd_Price_Attributes_Tbl.count);
    END IF;
  END IF;

  Save(
     P_Api_Version_Number          => p_api_version_number
    ,p_Init_Msg_List               => p_init_msg_list
    ,p_Commit                      => p_commit
    ,p_combineSameItem             => p_combineSameItem
    ,p_sharee_Number               => p_sharee_Number
    ,p_sharee_party_id             => p_sharee_party_id
    ,p_sharee_cust_account_id      => p_sharee_cust_account_id
    ,p_minisite_id                 => p_minisite_id
    ,p_changeowner                 => p_changeowner
    ,p_save_type                   => p_save_flag
    ,p_Control_Rec                 => p_Control_Rec
    ,p_Qte_Header_Rec              => lx_Qte_Header_Rec
    ,p_Qte_Line_Tbl                => l_Qte_Line_Tbl
    ,p_Qte_Line_Dtl_Tbl            => l_Qte_Line_Dtl_Tbl

    ,p_hd_price_attributes_tbl  => lx_Hd_Price_Attributes_Tbl
    ,p_hd_payment_tbl           => lx_Hd_Payment_Tbl
    ,p_hd_shipment_tbl          => lx_Hd_Shipment_Tbl
    ,p_hd_freight_charge_tbl    => lx_Hd_Freight_Charge_Tbl
    ,p_hd_tax_detail_tbl        => lx_Hd_Tax_Detail_Tbl
    ,p_line_attr_ext_tbl        => p_line_attr_ext_tbl
    ,p_line_rltship_tbl         => p_line_rltship_tbl
    ,p_price_adjustment_tbl     => lx_Price_Adjustment_Tbl
    ,p_price_adj_attr_tbl       => lx_Price_Adj_Attr_Tbl
    ,p_price_adj_rltship_tbl    => lx_Price_Adj_Rltship_Tbl
    ,p_ln_price_attributes_tbl  => p_ln_price_attributes_tbl
    ,p_ln_payment_tbl           => p_ln_payment_tbl
    ,p_ln_shipment_tbl          => p_ln_shipment_tbl
    ,p_ln_freight_charge_tbl    => p_ln_freight_charge_tbl
    ,p_ln_tax_detail_tbl        => p_ln_tax_detail_tbl

    ,x_quote_header_id             => x_quote_header_id
    ,x_last_update_date            => x_last_update_date
    ,x_Qte_Header_Rec              => lx_Qte_Header_Rec_tmp
    ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl_tmp
    ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl_tmp
    ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl_tmp
    ,x_Hd_Shipment_Rec             => lx_Hd_Shipment_Rec
    ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl_tmp
    ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl_tmp
    ,x_Qte_Line_Tbl                => x_Qte_Line_Tbl
    ,x_Qte_Line_Dtl_Tbl            => lx_Qte_Line_Dtl_Tbl
    ,x_Line_Attr_Ext_Tbl           => lx_Line_Attr_Ext_Tbl
    ,x_Line_rltship_tbl            => lx_Line_rltship_tbl
    ,x_Ln_Price_Attributes_Tbl     => lx_Ln_Price_Attributes_Tbl
    ,x_Ln_Payment_Tbl              => lx_Ln_Payment_Tbl
    ,x_Ln_Shipment_Tbl             => lx_Ln_Shipment_Tbl
    ,x_Ln_Freight_Charge_Tbl       => lx_Ln_Freight_Charge_Tbl
    ,x_Ln_Tax_Detail_Tbl           => lx_Ln_Tax_Detail_Tbl
    ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl_tmp
    ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl_tmp
    ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl_tmp
    ,X_Return_Status               => x_Return_Status
    ,X_Msg_Count                   => x_Msg_Count
    ,X_Msg_Data                    => x_Msg_Data
  );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  lx_Qte_Header_Rec          := lx_Qte_Header_Rec_tmp;
  lx_Hd_Price_Attributes_Tbl := lx_Hd_Price_Attributes_Tbl_tmp;
  lx_Hd_Payment_Tbl          := lx_Hd_Payment_Tbl_tmp;
  lx_Hd_Shipment_Tbl         := lx_Hd_Shipment_Tbl_tmp;
  lx_Hd_Freight_Charge_Tbl   := lx_Hd_Freight_Charge_Tbl_tmp;
  lx_Hd_Tax_Detail_Tbl       := lx_Hd_Tax_Detail_Tbl;
  lx_Price_Adjustment_Tbl    := lx_Price_Adjustment_Tbl;
  lx_Price_Adj_Attr_Tbl      := lx_Price_Adj_Attr_Tbl_tmp;
  lx_Price_Adj_Rltship_Tbl   := lx_Price_Adj_Rltship_Tbl_tmp;

  IF(l_attach_contract = FND_API.G_TRUE) THEN
    IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS') = 'Y' ) THEN --Only if contracts is enabled

      --instantiate a contract and associate to the quote
      /*mannamra: Chnages for MOAC : Bug 4682364*/
      --l_contract_template_id := FND_Profile.Value('ASO_DEFAULT_CONTRACT_TEMPLATE'); --Old style
      l_contract_template_id := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_CONTRACT_TEMPLATE)); --New style
      --
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('l_contract_template_id = '||l_contract_template_id);
      end if;
      IF (l_contract_template_id is not null) THEN

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('l_contract_template_id = '||l_contract_template_id);
          IBE_UTIL.debug('Before calling OKC_TERMS_COPY_GRP.copy_terms_api, quoteheaderId = '||x_quote_header_id);
        END IF;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('l_contract_template_id = '||l_contract_template_id);
            END IF;

            OKC_TERMS_UTIL_GRP.get_translated_template(
                  p_api_version    => 1.0,
                  p_init_msg_list  => FND_API.g_false,
                  p_template_id    => l_contract_template_id, --this variable will have the translated template ID
                  p_language       => userenv('LANG'),
                  p_document_type  => 'QUOTE',
                  x_template_id    => l_trans_Contract_templ_id,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data )  ;

            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
              RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('l_trans_Contract_templ_id = '||l_trans_Contract_templ_id);
              IBE_UTIL.debug('After calling OKC_TERMS_UTIL_GRP. get_translated_template(), quoteheaderId = '||lx_Qte_Header_Rec.quote_header_id);
            END IF;

        OKC_TERMS_COPY_GRP.copy_terms(
                    p_api_version             =>1.0
                   ,p_template_id             => l_trans_Contract_templ_id
                   ,p_target_doc_type         => 'QUOTE'
                   ,p_target_doc_id           => lx_Qte_Header_Rec.quote_header_id
                   ,p_article_effective_date  => null
                   ,p_validation_string       => null
                   ,x_return_status           => x_return_status
                   ,x_msg_count               => x_msg_count
                   ,x_msg_data                => x_msg_data);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('After copy_terms api, return status = '||x_return_status);
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF; --IF (l_contract_template_id is not null
      END IF;   --IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS') = 'Y'
    END IF;
  END IF; --if l_attach_contract is true;

   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_Quote_Save_pvt.AddItemsToCart_orig()');
   END IF;
   -- IBE_Util.Disable_Debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expected error: IBE_Quote_Save_pvt.AddItemsToCart_orig()');
     END IF;

      ROLLBACK TO AddItemsToCartorig_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unexpected error: IBE_Quote_Save_pvt.AddItemsToCart_orig()');
     END IF;

      ROLLBACK TO AddItemsToCartorig_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unknown error: IBE_Quote_Save_pvt.AddItemsToCart_orig()');
     END IF;

      ROLLBACK TO AddItemsToCartorig_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

END AddItemsToCart_orig;

/*This function creates the XML message required by the CZ_CF_API.Validate API*/
function get_xml_for_validate(p_model_item_id   IN number,
                              p_model_quantity  IN number,
                              p_quote_header_id IN number,
                              p_inv_org_id      IN number,
                              p_quote_line_id   IN number) return varchar2 is
l_user_id                   varchar2(10);
l_database_id               varchar2(30);
l_session_ticket            varchar2(50);
l_context_org_id            varchar2(50);
l_calling_application_id    varchar2(10);
l_responsibility_id         varchar2(10);
l_servlet_url               varchar2(100);
Str_database_id             varchar2(1000);
str_session_ticket          varchar2(100);
str_context_org_id          varchar2(100);
str_model_id                varchar2(100);
str_model_quantity          varchar2(100);
str_config_creation_date    varchar2(100);
str_calling_appl_id         varchar2(100);
str_responsibility_id       varchar2(100);
str_save_config_behaviour   varchar2(100);
str_teminate_msg_behavior   varchar2(100);
str_sbm_sbm_flag            varchar2(100);
str_sbm_client_header       varchar2(100);
str_sbm_client_line         varchar2(100);
str_xml_string              varchar2(2000);
begin

     l_database_id            := fnd_web_config.database_id;
     l_session_ticket         :=cz_cf_api.icx_session_ticket;
     --l_context_org_id       :=fnd_profile.value('ORG_ID');
     l_responsibility_id      := fnd_profile.value('RESP_ID') ;
     l_calling_application_id := fnd_profile.value('RESP_APPL_ID');
     l_servlet_url            := fnd_profile.value('CZ_UIMGR_URL') ;
     /*construct the XML string here*/

    str_database_id     := '<param+name="database_id">'||l_database_id||'</param>';
    str_session_ticket  :='<param+name="icx_session_ticket">'||l_session_ticket||'</param>';
    str_context_org_id  :='<param+name="context_org_id">'||p_inv_org_id||'</param>';
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('The Model item id passed to batch validate is '||to_char(p_model_item_id));
    END IF;
    str_model_id        := '<param+name="model_id">'||to_char(p_model_item_id)||'</param>';

    str_model_quantity       :='<param+name="model_quantity">'||p_model_quantity||'</param>';
    str_config_creation_date :='<param+name="config_creation_date">'||to_char(sysdate,'mm-dd-yyyy-hh24-mi-ss')||'</param>';
    str_calling_appl_id      := '<param+name="calling_application_id">'||l_calling_application_id||'</param>';
    str_responsibility_id    := '<param+name="responsibility_id">'||l_responsibility_id||'</param>';
    str_save_config_behaviour:='<param+name="save_config_behavior">'||'new_revision'||'</param>';
    str_teminate_msg_behavior:='<param+name="terminate_msg_behavior">'||'full'||'</param>';
    -- added 12/13/02: for potential SBM bundles
    str_sbm_sbm_flag         :='<param+name="sbm_flag">'||'true'||'</param>';
    str_sbm_client_header    :='<param+name="client_header">'||to_char(p_quote_header_id)||'</param>';
    str_sbm_client_line      :='<param+name="client_line">'||to_char(p_quote_line_id)||'</param>';

    str_xml_string           :='<initialize>'||str_database_id||str_session_ticket||str_context_org_id||str_model_id||str_model_quantity||str_config_creation_date;
    str_xml_string           := str_xml_string || str_calling_appl_id||str_responsibility_id;
    str_xml_string           := str_xml_string||str_save_config_behaviour||str_teminate_msg_behavior;
    str_xml_string           := str_xml_string||str_sbm_sbm_flag||str_sbm_client_header||str_sbm_client_line||'</initialize>';

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('The init msg string from get_xml_for_validate:'||str_xml_string);
    END IF;
    return str_xml_string;
end get_xml_for_validate;

-- formerly AddModelsToCart
-- same signature, but expanded to match the original addItemsToCart
-- this should be the main entry point for all item types as it internally calls addItemsToCart_orig
PROCEDURE AddItemsToCart(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  -- this flag is no longer used or supported; rather items will come in with a line code indicating it is a bundle
  ,p_Bundle_Flag              IN   VARCHAR2   := FND_API.G_FALSE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR
  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_ql_line_codes            IN   jtf_number_table       := NULL
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,P_save_flag                IN   NUMBER := SAVE_ADDTOCART
  ,x_quote_header_id          OUT NOCOPY  varchar2
  ,x_Qte_Line_Tbl             OUT NOCOPY  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
)
is

  l_api_name                    CONSTANT VARCHAR2(30)   := 'ADDMODELSTOCART';
  l_api_version                 CONSTANT NUMBER         := 1.0;
  lx_Qte_Header_Rec                ASO_Quote_Pub.Qte_Header_Rec_Type;
  lx_Hd_Price_Attributes_Tbl    ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Hd_Payment_Tbl                ASO_Quote_Pub.Payment_Tbl_Type;

  lx_Hd_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Hd_Shipment_Rec            ASO_Quote_Pub.Shipment_Rec_Type;
  lx_Hd_Freight_Charge_Tbl        ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Hd_Tax_Detail_Tbl            ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Qte_Line_Dtl_Tbl            ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
  lx_Line_Attr_Ext_Tbl            ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type;
  lx_Line_rltship_tbl            ASO_Quote_Pub.Line_Rltship_Tbl_Type;

  lx_Ln_Price_Attributes_Tbl    ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Ln_Payment_Tbl                ASO_Quote_Pub.Payment_Tbl_Type;
  lx_Ln_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Ln_Freight_Charge_Tbl        ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Ln_Tax_Detail_Tbl            ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Price_Adjustment_Tbl        ASO_Quote_Pub.Price_Adj_Tbl_Type;
  lx_Price_Adj_Attr_Tbl            ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
  lx_Price_Adj_Rltship_Tbl        ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;
  /*Following parameters added for Education project*/
  loop_counter                  Number;
  l_xml_string_for_validate     varchar2(2000); /*This holds the XML string to be passed to validate API*/
  lx_xml_from_validate           varchar2(2000); /*This holds the XML string returned by validate API*/
  l_input_selection             cz_cf_api.input_selection;
  l_cfg_input_list                 cz_cf_api.cfg_input_list;
  lx_cfg_output_pieces            cz_cf_api.cfg_output_pieces;
  l_validation_status            number;
  l_config_header_id            number := fnd_api.g_miss_num;
  l_config_rev_num                number;
  l_complete_config_flag        varchar2(5);
  l_valid_config_flag            varchar2(5);
  l_servlet_url                 varchar2(2000);
  l_qte_line_rec                ASO_Quote_Pub.Qte_Line_rec_Type;
  l_qte_line_dtl_rec            ASO_Quote_Pub.Qte_Line_Dtl_rec_Type;
  lx_msg_count                    number;
  lx_msg_data                    varchar2(2000);
  lx_quote_header_id            number;
  l_control_rec                    ASO_Quote_Pub.control_rec_type;
  l_number_of_bundles               number := 0;
  l_bundle_counter                  number := 0;


BEGIN
--  IBE_Util.Enable_Debug;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Begin IBE_Quote_Save_pvt.AddItemsToCart() (new one)');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT    ADDITEMSTOCART_pvt;
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
  -- API body

 -- User Authentication
   IBE_Quote_Misc_pvt.Validate_User_Update
   (  p_init_msg_list           => p_init_msg_list
     ,p_quote_header_id            => p_Qte_Header_Rec.quote_header_id
     ,p_party_id                => p_Qte_Header_Rec.party_id
     ,p_cust_account_id            => p_Qte_Header_Rec.cust_account_id
     ,p_quote_retrieval_number    => p_sharee_Number
     ,p_validate_user            => FND_API.G_TRUE
     ,P_save_type               => P_save_flag
     ,p_last_update_date        => p_Qte_Header_Rec.last_update_date
     ,x_return_status           => x_return_status
     ,x_msg_count               => lx_msg_count
     ,x_msg_data                => lx_msg_data
    );

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

  /*Check whether we have any model bundles or not*/
  if (p_ql_line_codes is not null) then
    for i in 1..p_Qte_Line_Tbl.count loop
      if (p_ql_line_codes(i) = MODEL_BUNDLE_LINE_CODE) then
      -- skip non bundles, this loop is only to handle bundles
        l_number_of_bundles := l_number_of_bundles +1;
      end if;
    end loop;
  else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('no line codes');
    END IF;
  end if;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('l_number_of_bundles : '||l_number_of_bundles);
  END IF;

  if (l_number_of_bundles = 0) then
    -- if no bundles, set to price in the first additemstocart_orig call
    -- as we will have no subsequent call to aso to price
    l_control_rec := p_control_rec;
  else
    /*Turn off the control record values here to avoid pricing until the last bundle loop*/
    l_control_rec.pricing_request_type := fnd_api.g_miss_char;
    l_control_rec.header_pricing_event := fnd_api.g_miss_char;
    l_control_rec.line_pricing_event   := fnd_api.g_miss_char;
    l_control_rec.Calculate_tax_flag   := 'N';
    l_control_rec.Calculate_freight_charge_flag := 'N';
  end if;
  -- Compulsory call to AddItemsToCart_orig - this call will take care of all
  -- standard, service, ui model, and model of the bundle items
  /*wrt to model bundles: Pass model_item_ids(p_Qte_line_Tbl) to AddItemsToCart and receive the table of model quote_line_ids returned by AddModelsToCart*/
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Begin IBE_Quote_Save_pvt.AddItemsToCart_orig()');
  END IF;
  AddItemsToCart_orig (
     P_Api_Version_Number        => P_Api_version_number
     ,p_Init_Msg_List            => p_init_msg_list
     ,p_Commit                   => p_Commit
     ,p_combineSameItem          => p_combineSameItem
     ,p_sharee_Number            => p_sharee_Number
     ,p_sharee_party_id          => p_sharee_party_id
     ,p_sharee_cust_account_id   => p_sharee_cust_account_id
     ,p_minisite_id              => p_minisite_id
     ,p_changeowner              => p_changeowner
     ,p_Control_Rec              => l_Control_Rec
     ,p_ql_line_codes            => p_ql_line_codes
     ,p_Qte_Header_Rec           => p_Qte_Header_Rec
     ,p_hd_Price_Attributes_Tbl  => p_hd_Price_Attributes_Tbl
     ,p_hd_Payment_Tbl           => p_hd_Payment_Tbl
     ,p_hd_Shipment_TBL          => p_hd_Shipment_TBL
     ,p_hd_Freight_Charge_Tbl    => p_hd_Freight_Charge_Tbl
     ,p_hd_Tax_Detail_Tbl        => p_hd_Tax_Detail_Tbl
     ,p_Qte_Line_Tbl             => p_Qte_Line_Tbl
     ,p_Qte_Line_Dtl_Tbl         => p_Qte_Line_Dtl_Tbl
     ,p_Line_Attr_Ext_Tbl        => p_Line_Attr_Ext_Tbl
     ,p_line_rltship_tbl         => p_line_rltship_tbl
     ,p_Price_Adjustment_Tbl     => p_Price_Adjustment_Tbl
     ,p_Price_Adj_Attr_Tbl       => p_Price_Adj_Attr_Tbl
     ,p_Price_Adj_Rltship_Tbl    => p_Price_Adj_Rltship_Tbl
     ,p_Ln_Price_Attributes_Tbl  => p_Ln_Price_Attributes_Tbl
     ,p_Ln_Payment_Tbl           => p_Ln_Payment_Tbl
     ,p_Ln_Shipment_Tbl          => p_Ln_Shipment_Tbl
     ,p_Ln_Freight_Charge_Tbl    => p_Ln_Freight_Charge_Tbl
     ,p_Ln_Tax_Detail_Tbl        => p_Ln_Tax_Detail_Tbl
     ,P_save_flag                => P_save_flag
     ,x_quote_header_id          => x_quote_header_id
     ,x_Qte_Line_Tbl             => x_Qte_Line_Tbl
     ,x_last_update_date         => x_last_update_date
     ,X_Return_Status            => x_return_status
     ,X_Msg_Count                => lx_msg_count
     ,X_Msg_Data                 => lx_msg_data
  );
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('End IBE_Quote_Save_pvt.AddItemsToCart_orig() : ' || x_return_status);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  if (l_number_of_bundles > 0) then
    l_bundle_counter := 0;
    l_servlet_url := fnd_profile.value('CZ_UIMGR_URL');
    -- by now the control record has already been set not to price
    -- we will restore the input pricing parameters on the last loop

    /*Loop through the model quote line ids obtained from the previous call to AddItemsToCart*/
    for loop_count in 1..x_qte_line_tbl.count loop
    if (p_ql_line_codes(loop_count) = MODEL_BUNDLE_LINE_CODE) then
      -- skip non bundles, this loop is only to handle bundles
      l_bundle_counter := l_bundle_counter +1;

      /*reset the state of control record for the last bundle*/
      if(l_bundle_counter = l_number_of_bundles) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('restoring control record for pricing');
        END IF;
        l_control_rec := p_control_rec;
      end if;

      /*Call Batch validation program here*/
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Begin cz_cf_api.validate');
      END IF;
      cz_cf_api.validate(config_input_list =>l_cfg_input_list,
                        init_message       =>get_xml_for_validate(x_qte_line_tbl(loop_count).inventory_item_id,
                                                                  x_qte_line_tbl(loop_count).quantity,
                                                                  x_quote_header_id,
                                                                  x_qte_line_tbl(loop_count).organization_id,
                                                                  x_qte_line_tbl(loop_count).quote_line_id),
                        config_messages    =>lx_cfg_output_pieces,
                        validation_status  =>l_validation_status,
                        url                =>l_servlet_url);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End cz_cf_api.validate');
      END IF;
      /*Parse the XML message for config_header_id, config_rev_num returned by the Batch validate program*/
      lx_xml_from_validate     := lx_cfg_output_pieces(1);
      l_config_header_id       := to_number(substr(lx_xml_from_validate,(instr(lx_xml_from_validate, '<config_header_id>',1,1)+18),(instr(lx_xml_from_validate,'</config_header_id>',1,1)-(instr(lx_xml_from_validate, '<config_header_id>',1,1)+18))));
      l_config_rev_num         := to_number(substr(lx_xml_from_validate,(instr(lx_xml_from_validate,'<config_rev_nbr>',1,1)+16),(instr(lx_xml_from_validate,'</config_rev_nbr>',1,1)-(instr(lx_xml_from_validate,'<config_rev_nbr>',1,1)+16))));
      l_valid_config_flag      := substr(lx_xml_from_validate,(instr(lx_xml_from_validate,'<valid_configuration>',1,1)+21),(instr(lx_xml_from_validate,'</valid_configuration>',1,1)-(instr(lx_xml_from_validate,'<valid_configuration>',1,1)+21)));
      l_complete_config_flag   :=
   substr(lx_xml_from_validate,(instr(lx_xml_from_validate,'<complete_configuration>',1,1)+24),(instr(lx_xml_from_validate,'</complete_configuration>',1,1)-(instr(lx_xml_from_validate,'<complete_configuration>',1,1)+24)));
      l_qte_line_rec           := x_qte_line_tbl(loop_count);

      /*Error handling if cz_cf_api.validate failed*/
      IF (l_config_header_id is NULL) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Error in CZ_CF_API.Validate:Printing the terminate string: '||lx_xml_from_validate);
        END IF;
        IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE','IBE_DSP_GENERIC_ERROR_TXT');
          FND_Message.Set_Token('IBE_DSP_GENERIC_ERROR_TXT',lx_xml_from_validate);
          FND_Msg_Pub.Add;
        END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Printing values obtained from batch validation');
        IBE_Util.Debug('Config header id: '||l_config_header_id);
        IBE_Util.Debug('Config rev num: '||l_config_rev_num);
        IBE_Util.Debug('Valid config flag: '||l_valid_config_flag);
        IBE_Util.Debug('Complete config flag: '||l_complete_config_flag);
      END IF;

      l_Qte_Line_Dtl_rec.quote_line_id := x_qte_line_tbl(loop_count).quote_line_id;
      if l_complete_config_flag = 'true' then
        l_Qte_Line_Dtl_rec.complete_configuration_flag := 'Y';
      else
        l_Qte_Line_Dtl_rec.complete_configuration_flag := 'N';
      end if;
      if l_valid_config_flag = 'true' then
        l_Qte_Line_Dtl_rec.valid_configuration_flag := 'Y';
      else
        l_Qte_Line_Dtl_rec.Valid_configuration_flag := 'N';
      end if;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Begin ASO_CFG_PUB.get_config_details');
      END IF;
      /*Call GET_CONFIG_DETAILS here*/
      aso_cfg_pub.get_config_details(P_Api_Version_Number => P_Api_Version_Number,
                                     P_Init_Msg_List      => P_Init_Msg_List,
                                     p_commit             => p_commit ,
                                     p_config_rec         => l_Qte_Line_Dtl_rec,
                                     p_model_line_rec     => l_qte_line_rec,
                                     p_config_hdr_id      => l_config_header_id ,
                                     p_config_rev_nbr     => l_config_rev_num,
                                     p_quote_header_id    => x_quote_header_id ,
                                     p_Control_Rec        => l_Control_Rec,
                                     x_return_status      => x_return_status,
                                     x_msg_count          => x_msg_count,
                                     x_msg_data           => x_msg_data
                                       );
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End ASO_CFG_PUB.get_config_details : ' || x_return_status);
      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    end if; -- end if bundle
    end loop; -- end bundle loop over line records from the 1st call to add models
  end if; -- end if l_have_bundle_Flag = true
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('End   IBE_Quote_Save_pvt.AddItemsToCart() (new one)');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expected error: IBE_Quote_Save_pvt.AddItemsToCart() (new one)');
     END IF;

      ROLLBACK TO ADDITEMSTOCART_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unexpected error: IBE_Quote_Save_pvt.AddItemsToCart() (new one)');
     END IF;
      ROLLBACK TO ADDITEMSTOCART_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unknown error: IBE_Quote_Save_pvt.AddItemsToCart) (new one)');
     END IF;
      ROLLBACK TO ADDITEMSTOCART_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END AddItemsToCart;

procedure get_termid_pricelistid( p_qte_line_tbl    in OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type
                                                     ,
                                  p_ln_Payment_Tbl  IN OUT NOCOPY  ASO_Quote_Pub.Payment_Tbl_Type

                                                     ) is
  /*This cursor selects price_list_id and term_id(payment_term_id as in aso_payments) */
  cursor c_term_pricelist(p_agreement_id number) is
        select price_list_id, term_id
        from oe_agreements_b
        where agreement_id = p_agreement_id;
  /*This cursor selects payment_id from aso_payments based on the qte_header_id and quote_line_id*/
  cursor c_payment_id(p_quote_header_id number, p_quote_line_id number) is
        select payment_id
        from aso_payments
        where quote_header_id = p_quote_header_id
        and quote_line_id = p_quote_line_id;

  rec_term_pricelist      c_term_pricelist%rowtype;
  rec_payment_id          c_payment_id%rowtype;
  l_price_list_id         number := fnd_api.g_miss_num;
  l_term_id               number := fnd_api.g_miss_num;
  l_payment_id            number := fnd_api.g_miss_num;

  l_ql_loop_counter       number := 1; /* Loop counter for Quote line table*/
  l_pmt_loop_counter      number := 1; /* Loop counter for input payment table*/
  l_pmt_rec_counter          number := 1; /* Loop counter for new payment table*/
  l_ln_payment_tbl        ASO_Quote_Pub.Payment_Tbl_Type;
  l_qte_line_tbl          ASO_Quote_Pub.Qte_Line_Tbl_Type;
  l_found_input_rec       varchar2(5) := FND_API.G_FALSE;

begin

  l_Qte_Line_Tbl           := p_qte_line_tbl;
  l_pmt_rec_counter     := 1;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('Entered get_termid_pricelistid');
  END IF;
  if (l_qte_line_tbl.count = 0) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Quote_line_table is empty');
    END IF;
  end if;

  for l_ql_loop_counter in 1..l_qte_line_tbl.count loop

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Quote header id is : '||l_qte_line_tbl(l_ql_loop_counter).quote_header_id);
       ibe_util.debug('Quote line id is: '||l_qte_line_tbl(l_ql_loop_counter).quote_line_id);
       ibe_util.debug('Quote line loop counter: '||l_ql_loop_counter);
       ibe_util.debug('Agreement Id detected is : '||l_qte_line_tbl(l_ql_loop_counter).agreement_id);
    END IF;

    if ((l_qte_line_tbl(l_ql_loop_counter).agreement_id is not null)
    and (l_qte_line_tbl(l_ql_loop_counter).agreement_id <> fnd_api.g_miss_num)) then
    --if the agreement id has a value in the quote_line_tbl
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Non Empty agreement value');
      END IF;
      for rec_term_pricelist in c_term_pricelist(l_qte_line_tbl(l_ql_loop_counter).agreement_id) loop
        --retrieve price_list_id from oe_agreements
        l_price_list_id := rec_term_pricelist.price_list_id;
        l_term_id := rec_term_pricelist.term_id;
      end loop;
    elsif (l_qte_line_tbl(l_ql_loop_counter).agreement_id is null) then
    -- If agreement_id is null in the quote_line_tbl then anull price_list_id and payment_term_id
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('NULL Agreement value');
      END IF;
      l_price_list_id := null;
      l_term_id := null;
    end if;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('l_price_list_id : '||l_price_list_id);
       ibe_util.debug('l_term_id       : '||l_term_id );
    END IF;

    -- this if goes to the end of the loop since we have no continue operator
    if ((l_qte_line_tbl(l_ql_loop_counter).agreement_id is null) or
        (l_qte_line_tbl(l_ql_loop_counter).agreement_id <> fnd_api.g_miss_num)) then

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Processing agreement id info - either null or number');
      END IF;
      -- take care of price list id
      l_qte_line_tbl(l_ql_loop_counter).price_list_id := l_price_list_id;

      -- now deal with payment term id -
      /*Check for the presence of the payment record in the database(aso_payments),
      if the record is present then operation code in the l_ln_payment_tbl= 'UPDATE'
      else it is 'CREATE'*/
      l_payment_id  := fnd_api.g_miss_num;
      for rec_payment_id in c_payment_id( l_qte_line_tbl(l_ql_loop_counter).quote_header_id,
                                          l_qte_line_tbl(l_ql_loop_counter).quote_line_id)  loop
        l_payment_id := rec_payment_id.payment_id;
        exit when c_payment_id%notfound;
      end loop;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('l_payment_id       : '||l_payment_id );
      END IF;
      -- prep the current payment record
      l_found_input_rec := FND_API.G_FALSE;
      if (p_ln_payment_tbl.count > 0 ) then
        --loop through the payment table to identify the right qte_header_id and qte_line_id as in the line_record
        for l_pmt_loop_counter in 1..p_ln_payment_tbl.count loop
          if((p_ln_payment_tbl(l_pmt_loop_counter).quote_header_id = l_qte_line_tbl(l_ql_loop_counter).quote_header_id)
          and (p_ln_payment_tbl(l_pmt_loop_counter).quote_line_id = l_qte_line_tbl(l_ql_loop_counter).quote_line_id)) then
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               ibe_util.debug('Found a passed in payment record.');
            END IF;
            l_found_input_rec := FND_API.G_TRUE;
            l_ln_payment_tbl(l_pmt_rec_counter) := p_ln_payment_tbl(l_pmt_loop_counter);
            l_ln_payment_tbl(l_pmt_rec_counter).payment_term_id := l_term_id;
            l_pmt_rec_counter := l_pmt_rec_counter + 1; --increment the payment table record counter
          end if;
        end loop;
      end if;

      if ((l_found_input_rec = FND_API.G_FALSE) or
          (l_ln_payment_tbl(l_pmt_rec_counter).operation_code <> 'DELETE')) then
        if (l_payment_id <> fnd_api.g_miss_num ) then
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('Operation code is UPDATE');
          END IF;
          l_ln_payment_tbl(l_pmt_rec_counter).operation_code := 'UPDATE';
          l_ln_payment_tbl(l_pmt_rec_counter).payment_id := l_payment_id;
          l_ln_payment_tbl(l_pmt_rec_counter).quote_header_id := l_qte_line_tbl(l_ql_loop_counter).quote_header_id;
          l_ln_payment_tbl(l_pmt_rec_counter).quote_line_id := l_qte_line_tbl(l_ql_loop_counter).quote_line_id;
          l_ln_payment_tbl(l_pmt_rec_counter).payment_term_id := l_term_id;
          l_pmt_rec_counter := l_pmt_rec_counter + 1; --increment the payment table record counter
        else
          if ((l_term_id is not null) and (l_term_id <> fnd_api.g_miss_num)) then
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               ibe_util.debug('Operation code is CREATE');
            END IF;
            l_ln_payment_tbl(l_pmt_rec_counter).operation_code := 'CREATE';
            l_ln_payment_tbl(l_pmt_rec_counter).quote_header_id := l_qte_line_tbl(l_ql_loop_counter).quote_header_id;
            l_ln_payment_tbl(l_pmt_rec_counter).quote_line_id := l_qte_line_tbl(l_ql_loop_counter).quote_line_id;
            l_ln_payment_tbl(l_pmt_rec_counter).payment_term_id := l_term_id;
            l_pmt_rec_counter := l_pmt_rec_counter + 1; --increment the payment table record counter
          end if;
        end if;
      end if;


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('OUT: l_pmt_rec_counter  : '||l_pmt_rec_counter);
      END IF;
      if (l_ln_payment_tbl.count >= l_pmt_rec_counter) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('OUT: operation_code     : '||l_ln_payment_tbl(l_pmt_rec_counter).operation_code);
           ibe_util.debug('OUT: quote_header_id    : '||l_ln_payment_tbl(l_pmt_rec_counter).quote_header_id);
           ibe_util.debug('OUT: quote_line_id      : '||l_ln_payment_tbl(l_pmt_rec_counter).quote_line_id);
           ibe_util.debug('OUT: payment_id         : '||l_ln_payment_tbl(l_pmt_rec_counter).payment_id);
           ibe_util.debug('OUT: payment_term_id    : '||l_ln_payment_tbl(l_pmt_rec_counter).payment_term_id);
           ibe_util.debug('OUT: price_list_id      : '||l_qte_line_tbl(l_ql_loop_counter).price_list_id );
        END IF;
      end if;

      --l_pmt_rec_counter := l_pmt_rec_counter + 1; --increment the payment table record counter



    end if; -- end if agreement id not g_miss

  end loop; --end loop for the loop around quote_line_table

  p_ln_payment_tbl := l_ln_payment_tbl;
  p_Qte_Line_Tbl   := l_qte_line_tbl;

end get_termid_pricelistid;
/*Get_quote_expiration_date is used to determine the expiration date for a shopping cart.
The number of days of expiration is different for saved carts and active carts and this
number is determined from profile values 'IBE_EXP_ACTIVE_CART' and 'IBE_EXP_SAVE_CART' for
active carts and saved carts respectively.*/

procedure GET_QUOTE_EXPIRATION_DATE(
          p_api_version      IN  NUMBER   := 1.0                       ,
          p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE            ,
          p_commit           IN  VARCHAR2 := FND_API.G_FALSE           ,
          x_return_status    OUT NOCOPY VARCHAR2                              ,
          x_msg_count        OUT NOCOPY NUMBER                                ,
          x_msg_data         OUT NOCOPY VARCHAR2                              ,
          p_quote_header_rec IN aso_quote_pub.qte_header_rec_type      ,
          X_expiration_date  OUT NOCOPY DATE) is

Cursor c_check_resource_name(quote_hdr_id number) is
    Select resource_id,quote_name
    from aso_quote_headers_all
    Where quote_header_id = quote_hdr_id;

  G_PKG_NAME               CONSTANT VARCHAR2(30) := 'IBE_Quote_Save_pvt';
  l_api_name               CONSTANT VARCHAR2(50) := 'Get_quote_expiration_date_pvt';
  l_api_version            NUMBER   := 1.0;
  Rec_check_resource_name  c_check_resource_name%rowtype;
  L_db_resource_id         number:= null;
  L_cart_name              varchar2(2000);
  L_profile_value          number:= fnd_api.g_miss_num;
  L_expiration_date        date:= fnd_api.g_miss_date;

Begin

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('Begin IEB_QUOTE_SAVE_pvt.GET_QUOTE_EXPIRATION_DATE()');
  END IF;

  -- Standard Start of API savepoint
   SAVEPOINT Get_quote_exp_date_pvt;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

  --API Body
  x_expiration_date := fnd_api.g_miss_date;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('Incoming quote name into get_quote_exp_date is '||p_quote_header_rec.quote_name);
  END IF;
  --If no resource id in the quote header rec then check for one in the database
  If p_quote_header_rec.resource_id = fnd_api.g_miss_num then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('No resource id in the incoming quote_header_rec');
    END IF;

    For rec_check_resource_name in c_check_resource_name(p_quote_header_rec.quote_header_id) loop
      L_db_resource_id := rec_check_resource_name.resource_id;
      L_cart_name := rec_check_resource_name.quote_name;
    Exit when c_check_resource_name%notfound;
    End loop;
    If (l_db_resource_id is null) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('No resource id in the database for the given qte_hdr_id');
      END IF;
      If (((p_quote_header_rec.quote_name <> fnd_api.g_miss_char)
          and(p_quote_header_rec.quote_name is not null)
          and (p_quote_header_rec.quote_name<>'IBE_PRMT_SC_UNNAMED') --MANNAMRA: 16/09/02:Changed IBEACTIVECART to IBE_PRMT_SC_UNNAMED
          /* and(l_cart_name<> 'IBEACTIVECART') */
          )
          or((p_quote_header_rec.quote_name = fnd_api.g_miss_char)
              and (l_cart_name is not null)
              and (l_cart_name <>'IBE_PRMT_SC_UNNAMED'))) then --MANNAMRA: 16/09/02:Changed IBEACTIVECART to IBE_PRMT_SC_UNNAMED
        L_profile_value := FND_Profile.Value('IBE_EXP_SAVE_CART');
      Else
        L_profile_value := FND_Profile.Value('IBE_EXP_ACTIVE_CART');
      End If;

      /*If((p_quote_header_rec.quote_name <> fnd_api.g_miss_char
          and p_quote_header_rec.quote_name <> 'IBEACTIVECART' )) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Using the IBE_EXP_SAVE_CART profile value');
        END IF;
        L_profile_value := FND_Profile.Value('IBE_EXP_SAVE_CART');

      Elsif((l_cart_name =  'IBEACTIVECART')
        or(p_quote_header_rec.quote_name = 'IBEACTIVECART')) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Using the IBE_EXP_ACTIVE_CART profile value');
        END IF;
        L_profile_value := FND_Profile.Value('IBE_EXP_ACTIVE_CART');
      End if;*/
      x_expiration_date := trunc(sysdate)+nvl(l_profile_value,0);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Expiration date returned by get_quote_exp_date is suppressed');
      END IF;
    End if;
  End if;

   -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and if count is 1, get message info.
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count    ,
                            p_data    => x_msg_data);

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   ibe_util.debug('End IBE_Quote_Save_pvt.GET_QUOTE_EXPIRATION_DATE()');
END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expected error: IBE_Quote_Save_pvt.Get_quote_expiration_date');
     END IF;

    ROLLBACK TO Get_quote_exp_date_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unexpected error: IBE_Quote_Save_pvt.Get_quote_expiration_date');
    END IF;

    ROLLBACK TO Get_quote_exp_date_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);
  WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown error: IBE_Quote_Save_pvt.Get_quote_expiration_date');
    END IF;

    ROLLBACK TO Get_quote_exp_date_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                              L_API_NAME);
    END IF;

    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);
End Get_Quote_expiration_date;

procedure request_for_sales_assistance (
          P_Api_Version           IN  NUMBER                     ,
          p_Init_Msg_List      IN  VARCHAR2:= FND_API.G_FALSE ,
          p_Commit             IN  VARCHAR2:= FND_API.G_FALSE ,
          x_return_status      OUT NOCOPY VARCHAR2            ,
          x_msg_count          OUT NOCOPY NUMBER              ,
          x_msg_data           OUT NOCOPY VARCHAR2            ,
          x_last_update_date   OUT NOCOPY Date                ,
          p_minisite_id        IN  NUMBER                     ,
          p_last_update_date   IN  Date                       ,
          p_quote_header_id    IN  NUMBER:= FND_API.G_MISS_NUM,
          p_party_id           IN  NUMBER:= FND_API.G_MISS_NUM,
          p_cust_account_id    IN  NUMBER:= FND_API.G_MISS_NUM,
          p_validate_user      IN  VARCHAR2:= FND_API.G_FALSE ,
          P_quote_name         IN  VARCHAR2                   ,
          P_Reason_code        IN  VARCHAR2                   ,
          P_url                IN  VARCHAR2:= FND_API.G_MISS_CHAR,
          P_COMMENTS           IN  VARCHAR2,
          p_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM,
          p_contract_context   IN  VARCHAR2 :='N',
          p_notes              IN  VARCHAR2 := NULL) is

  Cursor c_find_resourceid(qte_hdr_id number) is
            select resource_id,ASSISTANCE_REASON_CODE
            from aso_quote_headers_all
            where quote_header_id = qte_hdr_id;
  /*Cursor c_get_jtf_resource(salesrep number) is
            select resource_id
            from jtf_rs_salesreps_mo_v
            where salesrep_id = salesrep;*/
  /*10/17/2005:Mannamra: Bug ref #4682364. Modified cursor for getting the resource.
                         This query will get us the primary resource id */
  CURSOR c_get_jtf_resource (l_Srep VARCHAR2) IS
            SELECT Resource_Id
            /* FROM JTF_RS_SRP_VL */
            FROM JTF_RS_SALESREPS_MO_V
            WHERE Salesrep_number = l_Srep
            AND NVL(status,'A') = 'A'
            AND nvl(trunc(start_date_active), trunc(sysdate)) <= trunc(sysdate)
            AND nvl(trunc(end_date_active), trunc(sysdate)) >= trunc(sysdate) ;


  Cursor c_get_sr_user_id(resourceid number) is
            select user_id
            from jtf_rs_resource_extns
            where resource_id = resourceid;
  Cursor c_get_status_id(p_status_code varchar2) is
            select quote_status_id
            from aso_quote_statuses_b
            where status_code = p_status_code;

  Cursor c_get_lkp_meaning(lkp_code varchar2) is
           select lookup_code, meaning
           from fnd_lookup_values_vl
           where lookup_code = lkp_code
           and   lookup_type = 'IBE_SALES_ASSIST_REASONS_LK';


  G_PKG_NAME           CONSTANT VARCHAR2(30) := 'IBE_Quote_Save_pvt';
  l_api_name           CONSTANT VARCHAR2(200) := 'Req_for_sales_asst_pvt';
  l_api_version        NUMBER   := 1.0;


  l_salesrep_id         VARCHAR2(50);
  L_resource_id         Number := fnd_api.g_miss_num;
  l_salesrep_user_id    Number := fnd_api.g_miss_num;
  l_salesrep_user_name  Varchar2(100) :=fnd_api.g_miss_char;
  L_qte_hdr_rec         ASO_Quote_Pub.Qte_Header_Rec_Type
                        := ASO_Quote_Pub.G_MISS_Qte_Header_Rec;
  l_status_id           number;
  lx_quote_header_id    number;
  lX_return_status      VARCHAR2(1);
  lx_msg_count          NUMBER;
  lx_msg_data           VARCHAR2(2000);
  lx_last_update_date   DATE;
  l_check_resource_id   NUMBER;
  l_reason_code_meaning fnd_lookup_values_vl.meaning%type;
  lx_jtf_note_id        NUMBER;
  l_quote_status        aso_quote_statuses_vl.status_code%type;

  rec_get_SR_user_id           c_get_SR_user_id%rowtype;
  rec_get_jtf_resource         c_get_jtf_resource%rowtype;
  rec_find_resourceid          c_find_resourceid%rowtype;
  rec_get_status_id            c_get_status_id%rowtype;
--  rec_get_lkp_meaning  c_get_lkp_meaning%rowtype;

  l_contract_template_id       NUMBER;
  l_trans_Contract_template_id NUMBER;
  l_save_changes VARCHAR2(1);
  l_db_reason_code VARCHAR2(30);

Begin
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('Start IBE_Quote_Save_pvt.REQUEST_FOR_SALES_ASSISTANCE()');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Req_for_sales_asst_pvt;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                     p_api_version,
                                     L_API_NAME   ,
                                     G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_Msg_Pub.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --API Body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('REQUEST_FOR_SALES_ASSISTANCE: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('REQUEST_FOR_SALES_ASSISTANCE: After Calling log_environment_info');
      IBE_UTIL.DEBUG('REQUEST_FOR_SALES_ASSISTANCE: p_retrieval_number = '||p_retrieval_number);
   END IF;
  -- User Authentication
  IBE_Quote_Misc_pvt.Validate_User_Update
   (  p_init_msg_list   => p_Init_Msg_List
     ,p_quote_header_id => p_quote_header_id
     ,p_party_id        => p_party_id
     ,p_cust_account_id => p_cust_account_id
     ,p_validate_user   => p_validate_user
     ,p_quote_retrieval_number => p_retrieval_number
     ,p_save_type       => SALES_ASSISTANCE
     ,p_last_update_date => p_last_update_date
     ,x_return_status   => lx_return_status
     ,x_msg_count       => lx_msg_count
     ,x_msg_data        => lx_msg_data
    );
   IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --obtaining the resource id from the database
  For rec_find_resourceid in c_find_resourceid(p_quote_header_id) loop
    l_resource_id := rec_find_resourceid.resource_id ;
    l_db_reason_code := rec_find_resourceid.ASSISTANCE_REASON_CODE;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('REQUEST_FOR_SALES_ASSISTANCE: db_resource_id is'||l_resource_id);
      IBE_UTIL.DEBUG('REQUEST_FOR_SALES_ASSISTANCE: l_db_reason_code = '||l_db_reason_code);
   END IF;
  Exit when c_find_resourceid%notfound;
  End loop;

  If l_resource_id is null then
    l_save_changes := 'Y';
    --Making the value_specific call to obtain the profile value at application level
    -- ASO_DEFAULT_PERSON_ID may be defined at resp and appl levels , so using VALUE call

    /*--10/17/2005: Mannamra: In light of MOAC chages, default salesrep setting is no
                  longer a profile value but is instead stored
                  as Quoting parameter. Bug ref: 4682364*/

    --l_salesrep_id := FND_Profile.Value('ASO_DEFAULT_PERSON_ID');  --Old code
    l_salesrep_id := ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_SALESREP); --new way of getting the salesrep id

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('IBE_QUOTE_SAVE_PVT.Request_for_sales_assistance: salesrep id from quote_attrib: '||l_salesrep_id);
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Salesrep id from ASO profile is '||l_salesrep_id);
    END IF;
    --Profile value(ASO_DEFAULT_PERSON_ID) has salesrep_id, obtain resource_id from the
    --table jtf_rs_salesreps_mo_v. --Old comment
    /*--10/17/2005: Mannamra: In light of MOAC chages, default salesrep setting is no
                    longer a profile value but is instead stored
                    as Quoting parameter.However we will still obtainb the resource id
                    for the corresponding salesrep id from jtf_rs_salesreps_mo_v. Bug ref: 4682364*/

    for rec_get_jtf_resource in c_get_jtf_resource(l_salesrep_id) loop
      L_resource_id := rec_get_jtf_resource.resource_id;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('IBE_QUOTE_SAVE_PVT.Request_for_sales_assistance: L_resource_id: '||L_resource_id);
      END IF;

      exit when c_get_jtf_resource%notfound;
    end loop;

    --obtain the status_id for 'DRAFT' from aso_quote_statuses_vl
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('obtain the status_id for DRAFT from aso_quote_statuses_vl ');
    END IF;

    for rec_get_status_id in c_get_status_id('DRAFT') loop
      l_status_id := rec_get_status_id.quote_status_id;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('IBE_QUOTE_SAVE_PVT.Request_for_sales_assistance: l_status_id: '||l_status_id);
      END IF;

--      --DBMS_OUTPUT.PUT_line('Quote Status id: '||l_status_id);
    exit when c_get_status_id%notfound;
    end loop;
    --prepare the quote_hdr_rec for SAVE API
    L_qte_hdr_rec.resource_id      := l_resource_id;
    L_qte_hdr_rec.quote_name       := p_quote_name;
    L_qte_hdr_rec.quote_status_id  := l_status_id;   -- change the quote_status from "SAVE DRAFT"(CART) to "DRAFT".
    L_qte_hdr_rec.publish_flag     := 'Y';
 end if;

 if(l_save_changes = 'Y' OR l_db_reason_code is null OR l_db_reason_code <> p_reason_code)then
    l_qte_hdr_rec.quote_header_id :=  p_quote_header_id;
    l_qte_hdr_rec.last_update_date := p_last_update_date;
    --IBE.Q RSA changes
    l_qte_hdr_rec.Assistance_Requested := 'Y';
    l_qte_hdr_rec.Assistance_Reason_Code := p_reason_code;


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Values assigned to quote_header_rec going into "Save" API');
       IBE_UTIL.debug('Quote_header_id '||p_quote_header_id);
       IBE_UTIL.debug('Quote_name      '||p_quote_name);
       IBE_UTIL.debug('Resource_id     '||l_resource_id);
       IBE_UTIL.debug('Quote_status_id '||l_status_id);
       IBE_UTIL.debug('p_reason_code '||p_reason_code);
       IBE_UTIL.debug('Calling Save in request_for_sales_assist()');
    END IF;
    ibe_quote_save_pvt.save(
         p_api_version_number       => 1.0                 ,
         p_init_msg_list            => FND_API.G_FALSE     ,
         p_commit                   => FND_API.G_FALSE     ,
         p_qte_header_rec           => L_qte_hdr_rec       ,
         p_save_type                => SALES_ASSISTANCE    ,
         p_sharee_Number            => p_retrieval_number  ,
         x_quote_header_id          => lx_quote_header_id  ,
         x_last_update_date         => lx_last_update_date ,
         x_return_status            => lx_return_status    ,
         x_msg_count                => lx_msg_count        ,
         x_msg_data                 => lx_msg_data);
    IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  -- For the bug, 3014723, retrieve the resource_id from aso_quote_headers, instead of using the cached profile value.
    For rec_find_resourceid in c_find_resourceid(p_quote_header_id) loop
      l_resource_id := rec_find_resourceid.resource_id ;
      Exit when c_find_resourceid%notfound;
    End loop;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('IBE_QUOTE_SAVE_PVT.Request_for_sales_assistance: L_resource_id in quote: '||L_resource_id);
  END IF;


  --Obtain the salesrep user_id here
  for rec_get_SR_user_id in c_get_SR_user_id(l_resource_id) loop
    l_salesrep_user_id := rec_get_SR_user_id.user_id;
  exit when c_get_SR_user_id%notfound;
  end loop;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('IBE_QUOTE_SAVE_PVT.Request_for_sales_assistance: l_salesrep_user_id who will get the notif: '||l_salesrep_user_id);
  END IF;


  /* IBE.Q changes, this code commented out. Contracts needs to be
     instantiated in all cases
  -- Create the contract if the contract_context is set to 'Y'.
  IF (p_contract_context   = 'Y') THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('contract context is Yes, before calling get_terms_template');
    END IF;
  */

  IF (FND_Profile.Value('OKC_ENABLE_SALES_CONTRACTS') = 'Y' ) THEN --Only if contracts is enabled
    --check whether ther is already a contract associated with the quote
    IF (OKC_TERMS_UTIL_GRP.Get_Terms_Template('QUOTE', p_quote_header_id) IS NULL) THEN
    --no contract associated with the quote yet, hence get the contract template id.
    --instantiate a contract and associate to the quote
    /*Mannamra: Changes for MOAC: Bug 4682364**/
      --l_contract_template_id := FND_Profile.Value('ASO_DEFAULT_CONTRACT_TEMPLATE'); --Old style
      l_contract_template_id := to_number(ASO_UTILITY_PVT.GET_OU_ATTRIBUTE_VALUE(ASO_UTILITY_PVT.G_DEFAULT_CONTRACT_TEMPLATE)); --New style
    /*Mannamra: End of changes for MOAC**/
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('l_contract_template_id = '||l_contract_template_id);
        IBE_UTIL.debug('p_quote_header_id = '||p_quote_header_id);
      END IF;
      IF (l_contract_template_id is not null) THEN

        OKC_TERMS_UTIL_GRP.get_Translated_template(
                p_api_version    => 1.0,
                p_init_msg_list  => FND_API.g_false,
                p_template_id    => l_contract_template_id,
                p_language       => userenv('LANG'),
                p_document_type  => 'QUOTE',
                --this variable will have the translated template ID
                x_template_id    => l_trans_Contract_template_id,
                x_return_status  => x_return_status,
                x_msg_count      => x_msg_count,
                x_msg_data       => x_msg_data )  ;
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('l_trans_Contract_templ_id = '||l_trans_Contract_template_id);
        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('calling IBE_QUOTE_MISC_PVT.get_aso_quote_status');
        END IF;
        l_quote_status := IBE_QUOTE_MISC_PVT.get_aso_quote_status(p_quote_header_id);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('returned from IBE_QUOTE_MISC_PVT.get_aso_quote_status, l_quote_status = '||l_quote_status);
        END IF;
        IF(upper(l_quote_status) <> 'APPROVED') THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('calling OKC_XPRT_INT_GRP.get_contract_terms...');
          END IF;
          OKC_XPRT_INT_GRP.get_contract_terms(
             p_api_version    => 1.0
            ,p_init_msg_list  => FND_API.g_false
            ,P_document_type  => 'QUOTE'
            ,P_document_id    => p_quote_header_id
            ,P_template_id    => l_trans_Contract_template_id
            ,P_called_from_UI => 'N'
            ,P_run_xprt_flag  => 'Y'
            ,x_return_status  => lx_return_status
            ,x_msg_count      => lx_msg_count
            ,x_msg_data       => lx_msg_data           )  ;


          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After OKC_XPRT_INT_GRP.get_contract_terms, return status = '||lx_return_status);
          END IF;
          IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

        END IF; -- IF(upper(l_quote_status) <> 'APPROVED')
      END IF; --IF (l_contract_template_id is not null) THEN
    END IF;
  END IF; --Only if contracts is enabled

  /*Calling share_readonly to downgrade the access levels of  all recipients to 'R' status,
  this is done because recipients cannot update a cart after it becomes a quote*/

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Calling share_readonly to downgrade the access levels of  all recipients to R status');
  END IF;
  IBE_QUOTE_SAVESHARE_V2_PVT.share_readonly(
    p_quote_header_id  => p_quote_header_id,
    P_minisite_id      => p_minisite_id    ,
    p_url              => p_url            ,
    p_api_version      => 1.0              ,
    p_init_msg_list    => FND_API.G_FALSE  ,
    p_commit           => FND_API.G_FALSE  ,
    x_return_status    => lx_return_status ,
    x_msg_count        => lx_msg_count     ,
    x_msg_data         => lx_msg_data      );

    IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Done calling share_readonly');
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('RSA:Calling deactivate API');
  END IF;
  IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
          P_Quote_header_id  => p_quote_header_id,
          P_Party_id         => p_party_id        ,
          P_Cust_account_id  => p_cust_account_id ,
          p_api_version      => p_api_version     ,
          p_init_msg_list    => fnd_api.g_false   ,
          p_commit           => fnd_api.g_false   ,
          x_return_status    => lx_return_status   ,
          x_msg_count        => lx_msg_count       ,
          x_msg_data         => lx_msg_data        );
      IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('RSA:Deactivate owner cart after sharing:Done');
  END IF;

  /* Commenting the code (4 Dec, 03) as we are passing the meaning from the UI itself.
  -- For Contract Context get the reason_code_meaning from FND Message Code. Otherwise get the lookup meaning.
  IF (p_contract_context = 'Y') THEN
    fnd_message.set_name('IBE','IBE_CHKOUT_LIC_TERMS_CONDN');
	l_reason_code_meaning := fnd_message.get;
  ELSE
    --obtain the lookup_value of the reason_code lookup_code
    for rec_get_lkp_meaning in c_get_lkp_meaning(p_reason_code) loop
      l_reason_code_meaning := rec_get_lkp_meaning.meaning;
      l_reason_code_meaning := ':'||rec_get_lkp_meaning.meaning;
      exit when c_get_lkp_meaning%notfound;
    end loop;
  END IF;
  */


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('Calling the workflow notification API');
  END IF;
  --Calling the workflow notification API. This API sends out an e-maiol each to the salesrep and the customer.
  IBE_WORKFLOW_pvt.NotifyForSalesAssistance(
                   p_api_version       =>  1.0                   ,
                   p_init_msg_list     =>  FND_API.G_FALSE       ,
                   p_quote_id          =>  P_QUOTE_HEADER_ID     ,
                   p_customer_comments =>  P_COMMENTS            ,
                   p_salesrep_email_id =>  FND_API.G_MISS_CHAR   ,
                   p_salesrep_user_id  =>  l_salesrep_user_id    ,
                   p_reason_code       =>  P_Reason_code ,
                   p_msite_id          =>  p_minisite_id         ,
                   x_return_status     =>  lx_return_status      ,
                   x_msg_count         =>  lx_msg_count          ,
                   x_msg_data          =>  lx_msg_data    );

  IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --Bug 3204942 Start
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('Calling the create_note API');
  END IF;
  IF (p_notes IS NOT NULL) THEN
    JTF_NOTES_PUB.create_note(
               p_api_version        =>1.0,
			   x_return_status      => lx_return_status,
			   x_msg_count          => lx_msg_count,
			   x_msg_data           => lx_msg_data,
			   p_source_object_id   => p_quote_header_id,
			   p_source_object_code => 'ASO_QUOTE',
			   p_notes              => p_notes,
			   p_notes_detail       => p_comments,
			   p_note_status        => 'I', --this is for note_status of Public
			   x_jtf_note_id        => lx_jtf_note_id,
			   p_note_type          => 'QOT_SALES_ASSIST' );

    IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF (lx_return_status =  FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('After Calling the create_note API, note_id ='||lx_jtf_note_id);
    END IF;
  END IF;
  --Bug 3204942 End

 -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => lx_msg_count    ,
                            p_data    => lx_msg_data);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected error: IBE_Quote_Save_pvt.Request_for_sales_assistance');
    END IF;

    ROLLBACK TO Req_for_sales_asst_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    Set_Last_Update_Date(p_quote_header_id, x_last_update_date);
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => lx_msg_count    ,
                              p_data    => lx_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unexpected error: IBE_Quote_Save_pvt.Request_for_sales_assistance');
    END IF;

    ROLLBACK TO Req_for_sales_asst_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => lx_msg_count    ,
                              p_data    => lx_msg_data);
  WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown error: IBE_Quote_Save_pvt.Request_for_sales_assistance');
    END IF;

    ROLLBACK TO Req_for_sales_asst_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Set_Last_Update_Date(p_quote_header_id, x_last_update_date);
      IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
        FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                L_API_NAME);
      END IF;

    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => lx_msg_count    ,
                              p_data    => lx_msg_data);

End request_for_sales_assistance;

-- Overloaded SAVE to not handle any output record from OC.
PROCEDURE Save(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_auto_update_active_quote IN   VARCHAR2   := FND_API.G_TRUE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR

  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE

  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_save_type                IN   NUMBER := FND_API.G_MISS_NUM
  ,x_quote_header_id          OUT NOCOPY  varchar2
  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
)
is
  lx_Qte_Header_Rec                    ASO_Quote_Pub.Qte_Header_Rec_Type;
  lx_Hd_Price_Attributes_Tbl     ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Hd_Payment_Tbl                 ASO_Quote_Pub.Payment_Tbl_Type;

  lx_Hd_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Hd_Shipment_Rec            ASO_Quote_Pub.Shipment_Rec_Type;
  lx_Hd_Freight_Charge_Tbl        ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Hd_Tax_Detail_Tbl            ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Qte_Line_Tbl                   ASO_Quote_Pub.Qte_Line_Tbl_Type;
  lx_Qte_Line_Dtl_Tbl            ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
  lx_Line_Attr_Ext_Tbl            ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type;
  lx_Line_rltship_tbl            ASO_Quote_Pub.Line_Rltship_Tbl_Type;

  lx_Ln_Price_Attributes_Tbl    ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Ln_Payment_Tbl                ASO_Quote_Pub.Payment_Tbl_Type;
  lx_Ln_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Ln_Freight_Charge_Tbl        ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Ln_Tax_Detail_Tbl            ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Price_Adjustment_Tbl        ASO_Quote_Pub.Price_Adj_Tbl_Type;
  lx_Price_Adj_Attr_Tbl            ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
  lx_Price_Adj_Rltship_Tbl        ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Begin IBE_Quote_Save_pvt.Save(Overloaded SAVE)');
  END IF;
-- Commented mo_global.init(IBE) call as it was causing access mode error reported in 11810302, 8852116
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Before calling mo_global.init, input param=S');
  END IF;
  --mo_global.init('IBE');  -- bug 10113717
  mo_global.init('S'); -- bug 12775927
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('After calling mo_global.init)');
  END IF;
  Save(
     P_Api_Version_Number          => p_api_version_number
    ,p_Init_Msg_List               => p_init_msg_list
    ,p_Commit                      => p_commit
    ,p_auto_update_active_quote    => p_auto_update_active_quote
    ,p_combineSameItem             => p_combineSameItem
    ,p_sharee_Number               => p_sharee_Number
    ,p_sharee_party_id             => p_sharee_party_id
    ,p_sharee_cust_account_id      => p_sharee_cust_account_id
    ,p_minisite_id                 => p_minisite_id
    ,p_changeowner                 => p_changeowner
    ,p_Control_Rec                 => p_Control_Rec
    ,p_Qte_Header_Rec              => p_Qte_Header_Rec
    ,p_hd_Price_Attributes_Tbl     => p_hd_Price_Attributes_Tbl
    ,p_hd_Payment_Tbl              => p_hd_Payment_Tbl
    ,p_hd_Shipment_Tbl             => p_hd_Shipment_Tbl
    ,p_hd_Freight_Charge_Tbl       => p_hd_Freight_Charge_Tbl
    ,p_hd_Tax_Detail_Tbl           => p_hd_Tax_Detail_tbl
    ,p_Qte_Line_Tbl                => p_Qte_Line_Tbl
    ,p_Qte_Line_Dtl_Tbl            => p_Qte_Line_Dtl_Tbl
    ,p_Line_Attr_Ext_Tbl           => p_Line_Attr_Ext_Tbl
    ,p_line_rltship_tbl            => p_line_rltship_tbl
    ,p_Price_Adjustment_Tbl        => p_Price_Adjustment_Tbl
    ,p_Price_Adj_Attr_Tbl          => p_Price_Adj_Attr_Tbl
    ,p_Price_Adj_Rltship_Tbl       => p_Price_Adj_Rltship_Tbl
    ,p_Ln_Price_Attributes_Tbl     => p_Ln_Price_Attributes_Tbl
    ,p_Ln_Payment_Tbl              => p_Ln_Payment_Tbl
    ,p_Ln_Shipment_Tbl             => p_Ln_Shipment_Tbl
    ,p_Ln_Freight_Charge_Tbl       => p_Ln_Freight_Charge_Tbl
    ,p_Ln_Tax_Detail_Tbl           => p_Ln_Tax_Detail_Tbl
    ,p_save_type                   => p_save_type
    ,x_quote_header_id             => x_quote_header_id
    ,x_last_update_date            => x_last_update_date
    ,x_Qte_Header_Rec              => lx_Qte_Header_Rec
    ,x_Hd_Price_Attributes_Tbl     => lx_Hd_Price_Attributes_Tbl
    ,x_Hd_Payment_Tbl              => lx_Hd_Payment_Tbl
    ,x_Hd_Shipment_Tbl             => lx_Hd_Shipment_Tbl
    ,x_Hd_Shipment_Rec             => lx_Hd_Shipment_Rec
    ,x_Hd_Freight_Charge_Tbl       => lx_Hd_Freight_Charge_Tbl
    ,x_Hd_Tax_Detail_Tbl           => lx_Hd_Tax_Detail_Tbl
    ,x_Qte_Line_Tbl                => lx_Qte_Line_Tbl
    ,x_Qte_Line_Dtl_Tbl            => lx_Qte_Line_Dtl_Tbl
    ,x_Line_Attr_Ext_Tbl           => lx_Line_Attr_Ext_Tbl
    ,x_Line_rltship_tbl            => lx_Line_rltship_tbl
    ,x_Ln_Price_Attributes_Tbl     => lx_Ln_Price_Attributes_Tbl
    ,x_Ln_Payment_Tbl              => lx_Ln_Payment_Tbl
    ,x_Ln_Shipment_Tbl             => lx_Ln_Shipment_Tbl
    ,x_Ln_Freight_Charge_Tbl       => lx_Ln_Freight_Charge_Tbl
    ,x_Ln_Tax_Detail_Tbl           => lx_Ln_Tax_Detail_Tbl
    ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl
    ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl
    ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl
    ,X_Return_Status               => x_Return_Status
    ,X_Msg_Count                   => x_Msg_Count
    ,X_Msg_Data                    => x_Msg_Data
  );
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('End IBE_Quote_Save_pvt.Save(Overloaded SAVE)');
  END IF;
END Save;



PROCEDURE Save(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE
  ,p_auto_update_active_quote IN   VARCHAR2   := FND_API.G_TRUE
  ,p_combineSameItem          IN   VARCHAR2   := FND_API.G_MISS_CHAR

  ,p_sharee_Number            IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_party_id          IN   Number     := FND_API.G_MISS_NUM
  ,p_sharee_cust_account_id   IN   Number     := FND_API.G_MISS_NUM
  ,p_minisite_id              IN   NUMBER     := FND_API.G_MISS_NUM
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE

  ,p_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
                                     := ASO_Quote_Pub.G_Miss_Control_Rec
  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Qte_Line_Tbl             IN   ASO_Quote_Pub.Qte_Line_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl         IN   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_Attr_Ext_Tbl        IN   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL
  ,p_line_rltship_tbl         IN   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl
  ,p_Ln_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl          IN   ASO_Quote_Pub.Shipment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_Ln_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_save_type                IN   NUMBER := FND_API.G_MISS_NUM
  ,x_quote_header_id          OUT NOCOPY  varchar2
  ,x_last_update_date         OUT NOCOPY  DATE

  ,x_Qte_Header_Rec           IN OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type
  ,x_Hd_Price_Attributes_Tbl  IN OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_Hd_Payment_Tbl          IN OUT NOCOPY ASO_Quote_Pub.Payment_Tbl_Type
  ,x_Hd_Shipment_Tbl          IN OUT NOCOPY ASO_Quote_Pub.Shipment_Tbl_Type
  ,x_Hd_Shipment_Rec          IN OUT NOCOPY ASO_Quote_Pub.Shipment_Rec_Type
  ,x_Hd_Freight_Charge_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Freight_Charge_Tbl_Type
  ,x_Hd_Tax_Detail_Tbl        IN OUT NOCOPY ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE
  ,x_Qte_Line_Tbl             IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,x_Qte_Line_Dtl_Tbl         IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
  ,x_Line_Attr_Ext_Tbl        IN OUT NOCOPY ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
  ,x_Line_rltship_tbl         IN OUT NOCOPY ASO_Quote_Pub.Line_Rltship_Tbl_Type
  ,x_Ln_Price_Attributes_Tbl  IN OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_Ln_Payment_Tbl           IN OUT NOCOPY ASO_Quote_Pub.Payment_Tbl_Type
  ,x_Ln_Shipment_Tbl          IN OUT NOCOPY ASO_Quote_Pub.Shipment_Tbl_Type
  ,x_Ln_Freight_Charge_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Freight_Charge_Tbl_Type
  ,x_Ln_Tax_Detail_Tbl        IN OUT NOCOPY ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE
  ,x_Price_Adjustment_Tbl     IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Tbl_Type
  ,x_Price_Adj_Attr_Tbl       IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
  ,x_Price_Adj_Rltship_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type

  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
)
is
  l_api_name             CONSTANT VARCHAR2(30)   := 'SAVE';
  l_api_version          CONSTANT NUMBER         := 1.0;
  l_pricebasedonowner    varchar2(100);
  l_count                NUMBER;
  l_qte_header_rec       ASO_Quote_Pub.Qte_Header_Rec_Type
                         := ASO_Quote_Pub.g_miss_qte_header_rec;
  l_qte_line_tbl         ASO_Quote_Pub.Qte_Line_Tbl_Type
                         := ASO_Quote_Pub.g_miss_qte_line_tbl;
  l_Hd_Shipment_Rec         ASO_Quote_Pub.Shipment_Rec_Type
                          := ASO_Quote_Pub.g_miss_shipment_rec;
  l_qte_line_dtl_tbl     ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type
                         := ASO_Quote_Pub.g_miss_qte_line_dtl_tbl;
  l_hd_Payment_Tbl       ASO_Quote_Pub.Payment_Tbl_Type
                         := ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
  l_tmp_hd_Payment_Tbl   ASO_Quote_Pub.Payment_Tbl_Type
                         := ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
  l_Hd_Shipment_Tbl      ASO_Quote_Pub.Shipment_Tbl_Type
                         := ASO_Quote_Pub.g_miss_shipment_TBL;
  l_tmp_Hd_Shipment_Tbl  ASO_Quote_Pub.Shipment_Tbl_Type
                         := ASO_Quote_Pub.g_miss_shipment_TBL;
  l_Ln_Payment_Tbl       ASO_Quote_Pub.Payment_Tbl_Type;
  l_privilege_type_code  varchar2(30);
  ld_last_update_date    date;
  l_is_quote_usable      VARCHAR2(1);
--  l_control_rec      ASO_Quote_Pub.Control_Rec_Type;

  l_upd_stmnt             VARCHAR2(200);

  l_temp_qte_line_tbl         ASO_Quote_Pub.Qte_Line_Tbl_Type
                         := ASO_Quote_Pub.g_miss_qte_line_tbl;

  l_match_found         VARCHAR2(6) := FND_API.G_FALSE;

  l_combinesameitem   VARCHAR2(2) := FND_API.G_MISS_CHAR;

  qte_id NUMBER;		-- change line logic pricing Test
  prc_sts_ind VARCHAR2(1);
  tax_sts_ind VARCHAR2(1);

 /*This cursor retrieves payment_term_id and price_list_id for a given agreement id
   this modification added to support bundles in iStore */
  cursor c_term_pricelist(p_agreement_id number) is
        select term_id, price_list_id
        from oe_agreements_b
        where agreement_id = p_agreement_id;

  Cursor c_quote_sts_id(p_status_code varchar2) is
    select quote_status_id
    from aso_quote_statuses_vl
    where status_code = p_status_code;

  cursor c_pricing_indicators(qte_header_id number) is		-- change line logic pricing Test
        select quote_header_id, pricing_status_indicator, tax_status_indicator from
	aso_quote_headers_all where quote_header_id = qte_header_id;

  rec_term_pricelist       c_term_pricelist%rowtype;
  rec_quote_sts_id         c_quote_sts_id%rowtype;
  loop_count               number;
  lx_quote_expiration_date date;
  profileOrderTypeVal varchar2(1000);

    --09-MAY-2017  amaheshw Bug 25970063
  local_x_msg_data varchar2(2000);

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Begin IBE_Quote_Save_pvt.Save()');
  END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Before calling mo_global.init, input param=S');
   END IF;
   --mo_global.init('IBE');  -- bug 10113717
   mo_global.init('S'); -- bug 12775927
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('After calling mo_global.init)');
   END IF;

  -- Standard Start of API savepoint
  SAVEPOINT    SAVE_pvt;
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

  -- API body

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('SAVE: Before Calling log_environment_info');
  END IF;
  IBE_Quote_Misc_pvt.log_environment_info();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('SAVE: After Calling log_environment_info');
  END IF;

  --DBMS_OUTPUT.PUT_line('IBE_Quote_Save_pvt.SAVE into api ');
  --DBMS_OUTPUT.PUT_line('In save qte_hdr_id is '||p_Qte_Header_Rec.quote_header_id);
  -- USer Authentication
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('SAVE: Before Calling Validate User');
  END IF;

  IF(p_save_type <> OP_DELETE_CART) THEN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('SAVE: Calling Validate User');
  END IF;
  IBE_Quote_Misc_pvt.Validate_User_Update
   (  p_init_msg_list          => p_Init_Msg_List
     ,p_quote_header_id        => p_Qte_Header_Rec.quote_header_id
     ,p_party_id               => p_Qte_Header_Rec.party_id
     ,p_cust_account_id        => p_Qte_Header_Rec.cust_account_id
     ,p_quote_retrieval_number => p_sharee_Number
     ,p_validate_user          => FND_API.G_TRUE
     ,p_save_type              => p_save_type
     ,p_last_update_date       => p_Qte_Header_Rec.last_update_date
     ,x_return_status          => x_return_status
     ,x_msg_count              => x_msg_count
     ,x_msg_data               => x_msg_data    );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    -- so that we can get the quote last update date in the exception block
    l_qte_header_rec.quote_header_id := p_Qte_Header_Rec.quote_header_id;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    -- so that we can get the quote last update date in the exception block
    l_qte_header_rec.quote_header_id := p_Qte_Header_Rec.quote_header_id;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('SAVE: Validate User End');
  END IF;
END IF;
  -- set default value for header
  --DBMS_OUTPUT.PUT_line('befoe default_hdr_rec ');
  --DBMS_OUTPUT.PUT_line('p_qte_header_rec.quote_header_id '||p_qte_header_rec.quote_header_id);
  --Verify if the incoming quote is usable or not
  /*In this case we perticularly ensure that quote identified by p_qte_header_rec.quote_header_id
  has not expired because we do not want to allow updates on expired carts*/
  l_is_quote_usable := IBE_QUOTE_MISC_PVT.is_quote_usable(p_qte_header_rec.quote_header_id,
                                                           p_Qte_Header_Rec.party_id,
                                                           p_Qte_Header_Rec.cust_account_id);
   --Raise an error f the above validation failed
   IF(l_is_quote_usable = FND_API.G_FALSE) THEN
     IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
       FND_Message.Set_Name('IBE', 'IBE_SC_CART_EXPIRED');
       FND_Msg_Pub.Add;
     END IF;
     RAISE FND_API.G_EXC_ERROR;
   END IF;
   Default_Header_Record( p_qte_header_rec         => p_qte_header_rec
                       ,p_auto_update_active_quote => p_auto_update_active_quote
                       ,x_qte_header_rec           => l_qte_header_rec
                       ,p_hdr_Payment_Tbl          => p_hd_payment_tbl
                       ,x_hdr_payment_tbl          => l_hd_Payment_Tbl
                       ,x_return_status            => x_return_status
                       ,x_msg_count                => x_msg_count
                       ,x_msg_data                 => x_msg_data );
  --DBMS_OUTPUT.PUT_line('after default_hdr_rec ');
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

  -- set default value for line
  --DBMS_OUTPUT.PUT_line('before setlinedefaultval ');

  IF (p_combinesameitem = FND_API.G_MISS_CHAR) THEN
      l_combinesameitem := FND_Profile.Value('IBE_SC_MERGE_SHOPCART_LINES');
    Else
      l_combinesameitem := p_combinesameitem;
  END IF;
-- bug 6146600, scnagara
/* Commented the below merge logic, because when multiple support items were added,
and merge profile was on, the support lines were combined into one line, and hence
corresponding records of support items in quote line detail table p_qte_line_dtl_tbl
will have QTE_LINE_INDEX containing invalid index. And data would be corrupted.
Merge logic is incorporated in setLineDefaultVal api.
*/
 /*
  IF( l_combinesameitem = 'Y') THEN
      FOR i in 1..p_qte_line_tbl.count LOOP
          l_match_found := FND_API.G_FALSE;
          FOR j in 1..l_temp_qte_line_tbl.count LOOP
              IF((p_qte_line_tbl(i).inventory_item_id = l_temp_qte_line_tbl(j).inventory_item_id)
		              and (p_qte_line_tbl(i).quantity <> FND_API.G_MISS_NUM)) THEN
                  l_temp_qte_line_tbl(j).quantity := l_temp_qte_line_tbl(j).quantity + p_qte_line_tbl(i).quantity;
                  l_match_found := FND_API.G_TRUE;
                  EXIT;
              END IF;
          END LOOP;
          IF( NOT FND_API.To_Boolean(l_match_found) ) THEN
              l_temp_qte_line_tbl(l_temp_qte_line_tbl.count + 1) := p_qte_line_tbl(i);
          END IF;
      END LOOP;
  ELSE
      FOR i in 1..p_qte_line_tbl.count LOOP
          l_temp_qte_line_tbl(i) := p_qte_line_tbl(i);
      END LOOP;
  END IF;
  */
  setLineDefaultVal(l_qte_header_rec.quote_header_id
              --    ,l_temp_qte_line_tbl	-- bug 6146600, scnagara
	            ,p_qte_line_tbl		-- bug 6146600, scnagara
                    ,p_qte_line_dtl_tbl
                    ,p_combinesameitem
                    ,l_qte_line_tbl
                    ,l_qte_line_dtl_tbl);
  --DBMS_OUTPUT.PUT_line('afetr setlinedefaultval ');
  -- get access privilege only when sharee number is there.
  /*This code validates the recipient's access level against the minimum required access level for a create/update
  operation which is "F"*/

  IF ( ( p_sharee_Number is not null)
       and ( p_sharee_Number <>  FND_API.G_MISS_NUM)) THEN

    l_privilege_type_code := IBE_Quote_Misc_pvt.GetShareeprivilege(l_qte_header_rec.quote_header_id
                                                                   ,p_sharee_Number);
    IF ((l_privilege_type_code <> 'A')
        and (l_privilege_type_code <> 'F' )) THEN
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
        FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
        FND_Msg_Pub.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;   -- need error message
    END IF;

    IF ( l_privilege_type_code <> 'A'
        and FND_API.To_Boolean(p_changeowner) )THEN
      IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
        FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
        FND_Msg_Pub.Add;
      END IF;
      RAISE FND_API.G_EXC_ERROR;   -- need error message
    END IF;
  END IF; -- p_sharee_number is not null

  IF(l_qte_header_rec.quote_expiration_date = fnd_api.g_miss_date) then
    get_quote_expiration_date(
      p_api_version      => 1.0                     ,
      p_init_msg_list    => FND_API.G_TRUE          ,
      p_commit           => FND_API.G_FALSE         ,
      x_return_status    => x_return_status         ,
      x_msg_count        => x_msg_count             ,
      x_msg_data         => x_msg_data              ,
      p_quote_header_rec => l_qte_header_rec        ,
      x_expiration_date  => lx_quote_expiration_date);
	 l_qte_header_rec.quote_expiration_date := lx_quote_expiration_date;

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

  --DBMS_OUTPUT.PUT_line('after get_quote_exp_date ');
  --DBMS_OUTPUT.PUT_line('checking for p_hd_shipment_tbl ');
  IF (p_hd_shipment_tbl.count >0) then
    l_hd_shipment_rec := p_hd_shipment_tbl(1);
  END IF;
  --DBMS_OUTPUT.PUT_line('done checking for p_hd_shipment_tbl ');
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('Quote expiration date from get_quote_exp_date() is suppressed');
  END IF;

 log_Control_Rec_Values(p_control_rec);  -- change line logic pricing Test

  IF l_qte_header_rec.quote_header_id IS NOT NULL
    OR l_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM THEN
	  OPEN c_pricing_indicators(l_qte_header_rec.quote_header_id);  -- change line logic pricing Test
	  FETCH c_pricing_indicators INTO qte_id, prc_sts_ind, tax_sts_ind;
	  CLOSE c_pricing_indicators;

	  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		IBE_Util.Debug('change line logic pricing Test BEGIN');
		IBE_Util.Debug('qte_id = ' || qte_id);
		IBE_Util.Debug('prc_sts_ind = ' || prc_sts_ind);
		IBE_Util.Debug('tax_sts_ind = ' || tax_sts_ind);
		IBE_Util.Debug('change line logic pricing Test END');
	  END IF;
  END IF;

  /* Start of CREATE QUOTE or UPDATE QUOTE conditions*/
  /* "Create quote" is invoked if there is no incoming quote_header_id and no quote header id found
     in the database for the operating user, otherwise "Update quote" is invoked*/

  IF l_qte_header_rec.quote_header_id IS NULL
    OR l_qte_header_rec.quote_header_id = FND_API.G_MISS_NUM THEN

    --Fix for bug 2512597
    -- Force the quote_status_id to be 'STORE DRAFT' if there is no input value
    IF l_qte_header_rec.quote_status_id is null OR
      l_qte_header_rec.quote_status_id = fnd_api.g_miss_num then
       for rec_quote_sts_id in c_quote_sts_id('STORE DRAFT') loop
        l_qte_header_rec.quote_status_id := rec_quote_sts_id.quote_status_id;
        exit when c_quote_sts_id%notfound;
      end loop;
    END IF;

    --End of fix for bug 2512597

    -- create quote

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('ASO_Quote_Pub.Create_Quote() starts');
    END IF;

    /*Mannamra: Fix for Bug 4661967: This fix is required to save the payment type during
      "AddToCart" defaulting work*/

    FOR loop_count in 1..l_Hd_Payment_Tbl.count LOOP
      IF (l_Hd_Payment_Tbl(loop_count).payment_type_code = 'CREDIT_CARD' and
          l_Hd_Payment_Tbl(loop_count).instr_assignment_id is not null) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Save: Input payment table Payment type is cc and assignment id is not null');
        END IF;
        l_Hd_Payment_Tbl(loop_count).payment_ref_number := '';
      END IF;
    END LOOP;

       -- clear ASO global structures Bug 8327573/8360172
     ASO_PRICING_INT.G_LINE_REC := NULL;
     ASO_PRICING_INT.G_HEADER_REC := NULL;
      l_Qte_Header_Rec.MINISITE_ID := p_minisite_id ;

    -- change line logic pricing
     IF (p_control_rec.header_pricing_event = FND_Profile.Value('IBE_INCART_PRICING_EVENT') and p_control_rec.price_mode = 'CHANGE_LINE' ) THEN
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Its a create quote, pricing is turned on, change line pricing  is on ');
          IBE_UTIL.debug('Setting pricing indicators to C');
	END IF;
	l_Qte_Header_Rec.pricing_status_indicator := 'C';
	l_Qte_Header_Rec.tax_status_indicator := 'C';
     END IF;

	-- Passing order_type_id for bug 7042892 - start
      profileOrderTypeVal :=
      FND_Profile.Value('IBE_DEFAULT_ORDER_TYPE');

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Before:the current order type value'||
            l_Qte_Header_Rec.order_type_id);

      IBE_UTIL.debug('profile order type value'||
            profileOrderTypeVal);
    END IF;



    --check the value here before reset with the Profile value
   if ( l_Qte_Header_Rec.order_type_id is NULL or l_Qte_Header_Rec.order_type_id = FND_API.G_MISS_NUM ) then
    l_Qte_Header_Rec.order_type_id :=
      NVL(profileOrderTypeVal,FND_API.G_MISS_NUM);
   else
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('not reset with the profile value');
    END IF;
   END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('After:the current order type value=== '||l_Qte_Header_Rec.order_type_id);
  END IF;
	-- Passing order_type_id for bug 7042892 - end

    ASO_Quote_Pub.Create_Quote(
      P_Api_Version_Number      => P_Api_Version_Number      ,
      P_Init_Msg_List           => FND_API.G_FALSE           ,
      P_Commit                  => FND_API.G_FALSE           ,
      P_Control_Rec             => p_control_rec             ,
      P_qte_header_rec          => l_Qte_Header_Rec          ,
      P_Qte_Line_Tbl            => l_Qte_Line_Tbl            ,
      p_Line_rltship_tbl        => p_Line_rltship_tbl        ,
      p_Qte_Line_Dtl_Tbl        => l_Qte_Line_Dtl_Tbl        ,
      p_Hd_Price_Attributes_Tbl => p_Hd_Price_Attributes_Tbl ,
      p_Hd_Payment_Tbl          => l_Hd_Payment_Tbl          ,
      p_Hd_Shipment_rec         => l_Hd_Shipment_Rec         ,
      p_Hd_Tax_Detail_Tbl       => p_Hd_Tax_Detail_Tbl       ,
      p_Ln_Price_Attributes_Tbl => p_Ln_Price_Attributes_Tbl ,
      p_Ln_Payment_Tbl          => p_Ln_Payment_Tbl          ,
      p_Ln_Tax_Detail_Tbl       => p_Ln_Tax_Detail_Tbl       ,
      p_Price_Adj_Attr_Tbl      => p_Price_Adj_Attr_Tbl      ,
      p_Price_Adjustment_Tbl    => p_Price_Adjustment_Tbl    ,
      p_Price_Adj_Rltship_Tbl   => p_Price_Adj_Rltship_Tbl   ,
      p_Line_Attr_Ext_Tbl       => p_Line_Attr_Ext_Tbl       ,
      p_Hd_Freight_Charge_Tbl   => p_Hd_Freight_Charge_Tbl   ,
      p_Ln_Freight_Charge_Tbl   => p_Ln_Freight_Charge_Tbl   ,
      x_qte_header_rec          => x_Qte_Header_Rec          ,
      X_Qte_Line_Tbl            => x_Qte_Line_Tbl            ,
      X_Qte_Line_Dtl_Tbl        => x_Qte_Line_Dtl_Tbl        ,
      X_Hd_Price_Attributes_Tbl => X_Hd_Price_Attributes_Tbl ,
      X_Hd_Payment_Tbl          => x_Hd_Payment_Tbl          ,
      X_Hd_Shipment_Rec         => x_Hd_Shipment_Rec         ,
      X_Hd_Freight_Charge_Tbl   => x_Hd_Freight_Charge_Tbl  ,
      X_Hd_Tax_Detail_Tbl       => x_Hd_Tax_Detail_Tbl      ,
      X_Line_Attr_Ext_Tbl       => x_Line_Attr_Ext_Tbl      ,
      X_Line_rltship_tbl        => x_Line_Rltship_Tbl       ,
      X_Price_Adjustment_Tbl    => x_Price_Adjustment_Tbl   ,
      X_Price_Adj_Attr_Tbl        => X_Price_Adj_Attr_Tbl     ,
      X_Price_Adj_Rltship_Tbl   => x_Price_Adj_Rltship_Tbl  ,
      X_Ln_Price_Attributes_Tbl => X_Ln_Price_Attributes_Tbl,
      X_Ln_Payment_Tbl          => x_Ln_Payment_Tbl         ,
      X_Ln_Shipment_Tbl         => x_Ln_Shipment_Tbl        ,
      X_Ln_Freight_Charge_Tbl   => x_Ln_Freight_Charge_Tbl  ,
      X_Ln_Tax_Detail_Tbl       => x_Ln_Tax_Detail_Tbl      ,
      X_Return_Status           => x_return_status          ,
      X_Msg_Count               => x_msg_count              ,
      X_Msg_Data                => x_msg_data                );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('ASO_Quote_Pub.Create_Quote() finishes');
      END IF;

      OPEN c_pricing_indicators(x_Qte_header_rec.quote_header_id);  -- change line logic pricing Test
      FETCH c_pricing_indicators INTO qte_id, prc_sts_ind, tax_sts_ind;
      CLOSE c_pricing_indicators;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('change line logic pricing Test BEGIN');
	 IBE_Util.Debug('qte_id = ' || qte_id);
	 IBE_Util.Debug('prc_sts_ind = ' || prc_sts_ind);
	 IBE_Util.Debug('tax_sts_ind = ' || tax_sts_ind);
	 IBE_Util.Debug('change line logic pricing Test END');
      END IF;

-- Dynamic SQL for updating the MinisiteId in ASO_QUOTE_HEADER
    BEGIN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('In Update Header MinisiteId Dynamic SQL');
      END IF;
      IF (p_minisite_id <> FND_API.G_MISS_NUM) THEN
          l_upd_stmnt := 'Update ASO_QUOTE_HEADERS_ALL set minisite_id = :1
                    where quote_header_id = :2';
          EXECUTE IMMEDIATE  l_upd_stmnt using p_minisite_id,x_Qte_header_rec.quote_header_id;
          IF SQL%ROWCOUNT <> 1 THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      EXCEPTION
        When OTHERS THEN
    IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.set_name('IBE', 'IBE_UPDATE_MSITE_HDR_ERR');
              FND_MSG_PUB.add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
      END;

      --- make sure there is not multiple active cart exist before commit
      /*IF ((p_qte_header_rec.quote_source_code = 'IStore Account')
        AND  ( p_qte_header_rec.quote_name = 'IBEACTIVECART'
             OR p_qte_header_rec.quote_name = FND_API.G_MISS_CHAR )) then
          IF x_qte_header_rec.quote_header_id <>
            IBE_Quote_Misc_pvt.Get_Active_Quote_ID
                     (p_party_id         => x_qte_header_rec.party_id
                      ,p_cust_account_id => x_qte_header_rec.cust_account_id
                      ,p_only_max        =>  FALSE) then
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_QUOTE_NEED_REFRESH');
              FND_Msg_Pub.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;   -- need error message
          END IF;
       END IF;*/

       --MANNAMRA:Changes for save/share project(09/16/02)
       /* Callng activate quote here to track the above created cart in IBE_ACTIVE_CARTS_ALL table*/
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('DO not call activate_quote if p_save_type is DUPLCIATE_CART,p_save_type='||p_save_type);
    END IF;

    IF (p_save_type <> OP_DUPLICATE_CART) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Calling IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE');
      IBE_UTIL.DEBUG('x_Qte_header_rec.quote_header_id: '||x_Qte_header_rec.quote_header_id);
     END IF;
     IBE_QUOTE_SAVESHARE_V2_PVT.ACTIVATE_QUOTE  (
                   P_Quote_header_rec  => x_Qte_header_rec,
                   P_Party_id         => l_Qte_header_rec.party_id ,
                   P_Cust_account_id  => l_Qte_header_rec.cust_account_id,
                   p_api_version      => 1,
                   p_init_msg_list    => FND_API.G_TRUE,
                   p_commit           => FND_API.G_FALSE,
                   x_return_status    => x_return_status,
                   x_msg_count        => x_msg_count,
                   x_msg_data         => x_msg_data);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Finished calling ACTIVATE_QUOTE ');
      END IF;
     END IF;--Checking of p_save_type
      --MANNAMRA:End of changes for save/share project(09/16/02)
  else
    -- update cart
    --Convert Quote Status code to Status id
    IF (l_qte_header_rec.quote_status_id is null OR
       l_qte_header_rec.quote_status_id = fnd_api.g_miss_num) and
       (l_qte_header_rec.quote_status_code is not null OR
       l_qte_header_rec.quote_status_id <> fnd_api.g_miss_num) then
         for rec_quote_sts_id in c_quote_sts_id(l_qte_header_rec.quote_status_code) loop
          l_qte_header_rec.quote_status_id := rec_quote_sts_id.quote_status_id;
         exit when c_quote_sts_id%notfound;
         end loop;
    END IF;
      l_count := 0;
      l_tmp_hd_payment_tbl := IBE_Quote_Misc_pvt.getHeaderPaymentTbl(l_qte_header_rec.quote_header_id);
      IF l_tmp_hd_payment_tbl.COUNT > 0 THEN
      FOR I IN 1..p_hd_payment_tbl.COUNT LOOP
        IF l_hd_payment_tbl(I).operation_code = 'CREATE' THEN
          l_count := l_count + 1;
          IF l_tmp_hd_payment_tbl.COUNT > 0 THEN
            l_hd_payment_tbl(I).operation_code := 'UPDATE'; -- Bug# 1955991
            l_hd_payment_tbl(I).payment_id  := l_tmp_hd_payment_tbl(I).payment_id;
/*
          l_hd_payment_tbl(I).last_update_date :=
             IBE_Quote_Misc_pvt.getQuoteLastUpdateDate(l_qte_header_rec.quote_header_id); -- Bug# 1955991
*/
          /* Bug#1955991
              IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
                 FND_Message.Set_Name('IBE', 'IBE_QUOTE_HDR_PMT_RCRD_EXISTS');
                 FND_Msg_Pub.Add;
              END IF;
          RAISE FND_API.G_EXC_ERROR;
          */
          END IF;
        END IF;
      END LOOP;
      /* Bug#1955991
      IF l_count > 1 THEN -- Trying to create more than one header payment
        IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE', 'IBE_QUOTE_HDR_PMT_RCRD_EXISTS');
          FND_Msg_Pub.Add;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      */
      /* Added by Sri 09/06 since the header last update date should be the value in the db */
      l_qte_header_rec.last_update_date :=
      IBE_Quote_Misc_pvt.getQuoteLastUpdateDate(l_qte_header_rec.quote_header_id); -- Bug# 1955991
      END IF;
    l_hd_shipment_tbl := p_hd_shipment_tbl;
    -- More Bug# 1955991
    l_tmp_hd_shipment_tbl := ASO_UTILITY_PVT.Query_Shipment_Rows(
                                  p_qte_header_id  => l_qte_header_rec.quote_header_id,
                                  p_qte_line_id    => null);

    IF l_tmp_hd_shipment_tbl.COUNT > 0 THEN
      FOR I IN 1..l_hd_shipment_tbl.COUNT LOOP
        IF l_hd_shipment_tbl(I).operation_code = 'CREATE' THEN
          l_hd_shipment_tbl(I).operation_code := 'UPDATE';
          l_hd_shipment_tbl(I).shipment_id    := l_tmp_hd_shipment_tbl(I).shipment_id;
/*
        l_hd_shipment_tbl(I).last_update_date :=
             IBE_Quote_Misc_pvt.getQuoteLastUpdateDate(l_qte_header_rec.quote_header_id); -- Bug# 1955991
*/
        END IF;
      END LOOP;
/* Added by Sri 09/06 since the header last update date should be the value in the db */
      l_qte_header_rec.last_update_date :=
      IBE_Quote_Misc_pvt.getQuoteLastUpdateDate(l_qte_header_rec.quote_header_id); -- Bug# 1955991

    END IF;
    -- End Bug# 1955991

    --l_pricebasedonowner :=   FND_Profile.Value('IBE_SC_PRICE_BASED_ON_OWNER');
    l_ln_payment_tbl := p_Ln_Payment_Tbl;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.debug('Printing quote_line_tbl passedd to get_termid_pricelistid');
    END IF;
    for counter in 1..l_qte_line_tbl.count loop
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('Input commitment id to get_termid_pracelistid is: '||l_qte_line_tbl(counter).commitment_id);
        Ibe_util.debug('Input agreement id to get_termid_pricelistid is: '||l_qte_line_tbl(counter).agreement_id);
        Ibe_util.debug('Pricelist id before calling get_termid_pricelistid is: '||l_qte_line_tbl(counter).price_list_id);
      END IF;
    end loop;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.debug('values of payment table passed to get_termid_pricelisted');
    END IF;
    For counter in 1..l_ln_payment_tbl.count loop
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('Payment_term_id is: '||l_ln_payment_tbl(counter).payment_term_id);
      END IF;
    end loop;

    get_termid_pricelistid( p_qte_line_tbl      => l_qte_line_tbl,
                            p_ln_payment_tbl => l_ln_payment_tbl);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         Ibe_util.debug('Printing commitment_id obtained from get_termid_pricelistid');
      END IF;
    For counter in 1..l_qte_line_tbl.count loop
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('commitment id obtained from get_termid_pracelistid is: '||l_qte_line_tbl(counter).commitment_id);
        Ibe_util.debug('commitment id obtained from get_termid_pracelistid is: '||l_qte_line_tbl(counter).agreement_id);
        Ibe_util.debug('Pricelist id obtained from get_termid_pricelistid is: '||l_qte_line_tbl(counter).price_list_id);
      END IF;
    END LOOP;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      Ibe_util.debug('values of payment table obtained from get_termid_pricelisted');
    END IF;
    FOR counter in 1..l_ln_payment_tbl.count LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('l_ln_payment_tbl.Quote_header_id: '||l_ln_payment_tbl(counter).quote_header_id);
        Ibe_util.debug('l_ln_payment_tbl.Quote_line_id: '||l_ln_payment_tbl(counter).quote_line_id);
        Ibe_util.debug('l_ln_payment_tbl.payment_term_id: '||l_ln_payment_tbl(counter).payment_term_id);
        Ibe_util.debug('l_ln_payment_tbl.operation_code: '||l_ln_payment_tbl(counter).operation_code);
      END IF;
    END LOOP;
    /*if (p_sharee_Number is not null
       and p_sharee_Number <> FND_API.G_MISS_NUM
       and (l_pricebasedonowner = 'N')) then
        -- get price based on owner profile
       UpdateQuoteForSharee(
              p_api_version_number         => p_api_version_number
              ,p_init_msg_list             => FND_API.G_FALSE
                ,p_commit                    => FND_API.G_FALSE
              ,p_sharee_party_id           => p_sharee_party_id
              ,p_sharee_cust_account_id    => p_sharee_cust_account_id
              ,p_control_rec               => p_control_rec
              ,p_qte_header_rec            => l_qte_header_rec
              ,p_Hd_Price_Attributes_Tbl   => p_Hd_Price_Attributes_Tbl
              ,p_Hd_Payment_Tbl            => l_Hd_Payment_Tbl
              ,p_Hd_Shipment_Tbl           => l_Hd_Shipment_Tbl
              ,p_Hd_Tax_Detail_Tbl         => p_Hd_Tax_Detail_Tbl
              ,p_Hd_Freight_Charge_Tbl     => p_Hd_Freight_Charge_Tbl
              ,p_qte_line_tbl              => l_qte_line_tbl
              ,p_Qte_Line_Dtl_Tbl          => l_Qte_Line_Dtl_Tbl
              ,p_Line_rltship_tbl          => p_Line_rltship_tbl
              ,p_Line_Attr_Ext_Tbl         => p_Line_Attr_Ext_Tbl
              ,p_Ln_Price_Attributes_Tbl   => p_Ln_Price_Attributes_Tbl
              ,p_Ln_Payment_Tbl            => l_Ln_Payment_Tbl
              ,p_Ln_Shipment_Tbl           => p_Ln_Shipment_Tbl
              ,p_Ln_Tax_Detail_Tbl         => p_Ln_Tax_Detail_Tbl
              ,p_Ln_Freight_Charge_Tbl     => p_Ln_Freight_Charge_Tbl
              ,p_Price_Adj_Attr_Tbl        => p_Price_Adj_Attr_Tbl
              ,p_Price_Adjustment_Tbl      => p_Price_Adjustment_Tbl
              ,p_Price_Adj_Rltship_Tbl     => p_Price_Adj_Rltship_Tbl
              ,x_qte_header_rec            => x_qte_header_rec
              ,x_qte_line_tbl              => x_qte_line_tbl
              ,X_Return_Status             => X_Return_Status
              ,X_Msg_Count                 => X_Msg_Count
              ,X_Msg_Data                  => X_Msg_Data);

             IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
             END IF;

             IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
           else -- no sharee*/

    FOR counter in 1..p_Price_Adjustment_Tbl.count LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('p_Price_Adjustment_Tbl.operation_code: '||p_Price_Adjustment_Tbl(counter).operation_code);
        Ibe_util.debug('p_Price_Adjustment_Tbl.PRICE_ADJUSTMENT_ID: '||p_Price_Adjustment_Tbl(counter).PRICE_ADJUSTMENT_ID);
        Ibe_util.debug('p_Price_Adjustment_Tbl.qte_line_index: '||p_Price_Adjustment_Tbl(counter).qte_line_index);
        Ibe_util.debug('p_Price_Adjustment_Tbl.quote_line_id: '||p_Price_Adjustment_Tbl(counter).quote_line_id);
        Ibe_util.debug('p_Price_Adjustment_Tbl.Quote_header_id: '||p_Price_Adjustment_Tbl(counter).quote_header_id);
      END IF;
    END LOOP;
    FOR counter in 1..p_Price_Adj_Rltship_Tbl.count LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.operation_code: '||p_Price_Adj_Rltship_Tbl(counter).operation_code);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.ADJ_RELATIONSHIP_ID: '||p_Price_Adj_Rltship_Tbl(counter).ADJ_RELATIONSHIP_ID);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.RLTD_PRICE_ADJ_INDEX: '||p_Price_Adj_Rltship_Tbl(counter).RLTD_PRICE_ADJ_INDEX);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.PRICE_ADJ_INDEX: '||p_Price_Adj_Rltship_Tbl(counter).PRICE_ADJ_INDEX);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.QTE_LINE_INDEX: '||p_Price_Adj_Rltship_Tbl(counter).QTE_LINE_INDEX);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.RLTD_PRICE_ADJ_Id: '||p_Price_Adj_Rltship_Tbl(counter).RLTD_PRICE_ADJ_Id);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.PRICE_ADJUSTMENT_ID: '||p_Price_Adj_Rltship_Tbl(counter).PRICE_ADJUSTMENT_ID);
        Ibe_util.debug('p_Price_Adj_Rltship_Tbl.QUOTE_LINE_ID: '||p_Price_Adj_Rltship_Tbl(counter).QUOTE_LINE_ID);
      END IF;
    END LOOP;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('ASO_Quote_Pub.Update_Quote() starts');
      IBE_Util.Debug('Save : COUNT: just before aso update' || p_Ln_Price_Attributes_Tbl.count);
    END IF;
    --DBMS_OUTPUT.PUT_line('calling IBE_Quote_Save_pvt.SAVE.UPDATE_QUOTE ');
    --DBMS_OUTPUT.PUT_line('before update_quote: '||l_qte_header_rec.quote_name);
    --DBMS_OUTPUT.PUT_line('before update_quote: '||l_qte_header_rec.quote_header_id);
    --DBMS_OUTPUT.PUT_line('before update_quote: '||l_qte_header_rec.quote_status_id);
    --DBMS_OUTPUT.PUT_line('before update_quote: '||l_qte_header_rec.quote_expiration_date);
    --DBMS_OUTPUT.PUT_line('before update_quote: '||l_qte_header_rec.quote_source_code);

  -- clear ASO global structures,bug 8327573/8360172

     ASO_PRICING_INT.G_LINE_REC := NULL;
     ASO_PRICING_INT.G_HEADER_REC := NULL;

    ASO_Quote_Pub.Update_quote(
            P_Api_Version_Number       => P_Api_Version_Number
           ,P_Init_Msg_List            => FND_API.G_FALSE
           ,P_Commit                   => FND_API.G_FALSE
           ,P_Control_Rec              => p_control_rec
           ,P_qte_header_rec           => l_Qte_Header_Rec
           ,P_Qte_Line_Tbl             => l_Qte_Line_Tbl
            ,p_Line_rltship_tbl        => p_Line_rltship_tbl
            ,p_Qte_Line_Dtl_Tbl        => l_Qte_Line_Dtl_Tbl
            ,p_Hd_Price_Attributes_Tbl => p_Hd_Price_Attributes_Tbl
            ,p_Hd_Payment_Tbl          => l_Hd_Payment_Tbl
            ,p_Hd_Shipment_Tbl         => l_Hd_Shipment_Tbl
            ,p_Hd_Tax_Detail_Tbl       => p_Hd_Tax_Detail_Tbl
            ,p_Ln_Price_Attributes_Tbl => p_Ln_Price_Attributes_Tbl
            ,p_Ln_Payment_Tbl          => l_Ln_Payment_Tbl
            ,p_Ln_Shipment_Tbl         => p_Ln_Shipment_Tbl
            ,p_Ln_Tax_Detail_Tbl       => p_Ln_Tax_Detail_Tbl
            ,p_Price_Adj_Attr_Tbl      => p_Price_Adj_Attr_Tbl
            ,p_Price_Adjustment_Tbl    => p_Price_Adjustment_Tbl
            ,p_Price_Adj_Rltship_Tbl   => p_Price_Adj_Rltship_Tbl
            ,p_Line_Attr_Ext_Tbl       => p_Line_Attr_Ext_Tbl
            ,p_Hd_Freight_Charge_Tbl   => p_Hd_Freight_Charge_Tbl
            ,p_Ln_Freight_Charge_Tbl   => p_Ln_Freight_Charge_Tbl
            ,x_qte_header_rec          => x_Qte_Header_Rec
            ,X_Qte_Line_Tbl            => x_Qte_Line_Tbl
            ,X_Qte_Line_Dtl_Tbl        => x_Qte_Line_Dtl_Tbl
            ,x_Hd_Price_Attributes_Tbl => X_Hd_Price_Attributes_Tbl
            ,X_Hd_Payment_Tbl          => x_Hd_Payment_Tbl
            ,X_Hd_Shipment_Tbl         => x_Hd_Shipment_Tbl
            ,X_Hd_Freight_Charge_Tbl   => x_Hd_Freight_Charge_Tbl
            ,X_Hd_Tax_Detail_Tbl       => x_Hd_Tax_Detail_Tbl
            ,x_Line_Attr_Ext_Tbl       => x_Line_Attr_Ext_Tbl
            ,X_Line_rltship_tbl        => x_Line_Rltship_Tbl
            ,X_Price_Adjustment_Tbl    => x_Price_Adjustment_Tbl
            ,X_Price_Adj_Attr_Tbl      => X_Price_Adj_Attr_Tbl
            ,X_Price_Adj_Rltship_Tbl   => x_Price_Adj_Rltship_Tbl
            ,X_Ln_Price_Attributes_Tbl => X_Ln_Price_Attributes_Tbl
            ,X_Ln_Payment_Tbl          => x_Ln_Payment_Tbl
            ,X_Ln_Shipment_Tbl         => x_Ln_Shipment_Tbl
            ,X_Ln_Freight_Charge_Tbl   => x_Ln_Freight_Charge_Tbl
            ,X_Ln_Tax_Detail_Tbl       => x_Ln_Tax_Detail_Tbl
              ,X_Return_Status           => x_return_status
            ,X_Msg_Count               => x_msg_count
            ,X_Msg_Data                => x_msg_data);

        --DBMS_OUTPUT.PUT_line('FINISH IBE_Quote_Save_pvt.SAVE.UPDATE_QUOTE ');
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

         IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('ASO_Quote_Pub.Update_Quote() finishes : '|| x_return_status);
    END IF;

   OPEN c_pricing_indicators(x_Qte_header_rec.quote_header_id);  -- change line logic pricing Test
    FETCH c_pricing_indicators INTO qte_id, prc_sts_ind, tax_sts_ind;
    CLOSE c_pricing_indicators;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('change line logic pricing Test BEGIN');
	 IBE_Util.Debug('qte_id = ' || qte_id);
	 IBE_Util.Debug('prc_sts_ind = ' || prc_sts_ind);
	 IBE_Util.Debug('tax_sts_ind = ' || tax_sts_ind);
	 IBE_Util.Debug('change line logic pricing Test END');
      END IF;

    --DBMS_OUTPUT.PUT_line('after update_quote: '||x_qte_header_rec.quote_name);
    --DBMS_OUTPUT.PUT_line('after update_quote: '||x_qte_header_rec.quote_header_id);
    --DBMS_OUTPUT.PUT_line('after update_quote: '||x_qte_header_rec.quote_status_id);
    --DBMS_OUTPUT.PUT_line('after update_quote: '||x_qte_header_rec.quote_expiration_date);
    --DBMS_OUTPUT.PUT_line('after update_quote: '||x_qte_header_rec.quote_source_code);
  END IF;  -- end of create/update

  x_quote_header_id  := x_qte_header_rec.quote_header_id;
  x_last_update_date := x_qte_header_rec.last_update_date;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);

-- 09-MAY-2017  amaheshw Bug 25970063

   IF (fnd_msg_pub.count_msg > 1)THEN
    FOR i IN 1..fnd_msg_pub.count_msg
    LOOP

     fnd_msg_pub.get
     ( p_msg_index => i,
       p_encoded => 'F',
       p_data => local_x_msg_data,
       p_msg_index_out => X_msg_count
     );

    if (i>1) then
      x_msg_data :=  x_msg_data || '<br/>' || i || '. ' ||  local_x_msg_data ;
    else
      x_msg_data := i || '. ' || local_x_msg_data ;
    End if;
	 IBE_Util.Debug('bug 25970063 local_x_msg_data=' || local_x_msg_data);
   END LOOP;
	 IBE_Util.Debug('bug 25970063 final x_msg_data=' || x_msg_data);

  End if;
--end 09-MAY-2017  amaheshw Bug 25970063

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Normal End   IBE_Quote_Save_pvt.Save()');
   END IF;
   -- IBE_Util.Disable_Debug;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expected error IBE_Quote_Save_pvt.Save()');
     END IF;
      ROLLBACK TO SAVE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
     Set_Last_Update_Date(l_qte_header_rec.quote_header_id, x_last_update_date);
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unexpected error  IBE_Quote_Save_pvt.Save()');
      END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SAVE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Set_Last_Update_Date(l_qte_header_rec.quote_header_id, x_last_update_date);
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('Unknown exception End   IBE_Quote_Save_pvt.Save()');
      END IF;
   WHEN OTHERS THEN
      ROLLBACK TO SAVE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     Set_Last_Update_Date(l_qte_header_rec.quote_header_id, x_last_update_date);
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Save_pvt.Save()');
      END IF;

END Save;


PROCEDURE UpdateQuoteForSharee(
  p_api_version_number        IN   NUMBER
  ,p_init_msg_list            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_commit                   IN   VARCHAR2    := FND_API.G_FALSE

  ,p_sharee_Party_Id          IN NUMBER
  ,p_sharee_Cust_account_Id   IN NUMBER
  ,p_changeowner              IN   VARCHAR2   := FND_API.G_FALSE

  ,P_Control_Rec              IN   ASO_Quote_Pub.Control_Rec_Type
  ,P_Qte_Header_Rec              IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                 := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_Hd_Price_Attributes_Tbl  in   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                 := ASO_Quote_Pub.G_MISS_Price_Attributes_Tbl
  ,p_Hd_Payment_Tbl                 in   ASO_Quote_Pub.Payment_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Hd_Shipment_Tbl                in   ASO_Quote_Pub.Shipment_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_SHIPMENT_Tbl
  ,p_Hd_Tax_Detail_Tbl              in   ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE
                                    := ASO_Quote_Pub.G_MISS_Tax_Detail_Tbl
  ,p_Hd_Freight_Charge_Tbl          in   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Freight_Charge_Tbl

  ,p_qte_line_tbl                   in  ASO_Quote_Pub.Qte_Line_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL
  ,p_Qte_Line_Dtl_Tbl               in   ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL
  ,p_Line_rltship_tbl               in   ASO_Quote_Pub.Line_Rltship_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl
  ,p_Line_Attr_Ext_Tbl              in   ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_Tbl
  ,p_Ln_Price_Attributes_Tbl        in   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Price_Attributes_Tbl
  ,p_Ln_Payment_Tbl                 in   ASO_Quote_Pub.Payment_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_Ln_Shipment_Tbl                in   ASO_Quote_Pub.Shipment_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_Ln_Tax_Detail_Tbl              in   ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE
                                    := ASO_Quote_Pub.G_MISS_Tax_Detail_Tbl
  ,p_Ln_Freight_Charge_Tbl          in   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Freight_Charge_Tbl
  ,p_Price_Adj_Attr_Tbl             in   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adjustment_Tbl           in   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Price_Adj_Tbl
  ,p_Price_Adj_Rltship_Tbl          in   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                    := ASO_Quote_Pub.G_MISS_Price_Adj_Rltship_Tbl

  ,x_qte_header_rec                 OUT NOCOPY  ASO_Quote_Pub.Qte_Header_Rec_Type
  ,x_qte_line_tbl                   OUT NOCOPY  ASO_Quote_Pub.Qte_Line_Tbl_Type
  ,X_Return_Status                  OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                      OUT NOCOPY  NUMBER
  ,X_Msg_Data                       OUT NOCOPY  VARCHAR2
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)    := 'UpdateQuoteForSharee';
  l_api_version               CONSTANT NUMBER     := 1.0;

  l_quote_party_id        number;
  l_quote_Cust_account_id   number;

  l_qte_header_rec      ASO_Quote_Pub.QTE_HEADER_REC_TYPE;
  l_control_Rec           ASO_Quote_Pub.Control_Rec_Type;



  lx_Hd_Price_Attributes_Tbl        ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Hd_Payment_Tbl            ASO_Quote_Pub.Payment_Tbl_Type;
  lx_Hd_Shipment_Rec            ASO_Quote_Pub.Shipment_Rec_Type;
  lx_Hd_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Hd_Freight_Charge_Tbl        ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Hd_Tax_Detail_Tbl                ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;


  lx_Qte_Line_Dtl_Tbl            ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
  lx_Line_Attr_Ext_Tbl                ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type;
  lx_Line_rltship_tbl            ASO_Quote_Pub.Line_Rltship_Tbl_Type;

  lx_Ln_Price_Attributes_Tbl        ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Ln_Payment_Tbl            ASO_Quote_Pub.Payment_Tbl_Type;
  lx_Ln_Shipment_Tbl            ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Ln_Freight_Charge_Tbl        ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Ln_Tax_Detail_Tbl            ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Price_Adjustment_Tbl        ASO_Quote_Pub.Price_Adj_Tbl_Type;
  lx_Price_Adj_Attr_Tbl                ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
  lx_Price_Adj_Rltship_Tbl        ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;
BEGIN
--   IBE_Util.Enable_Debug;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin IBE_Quote_Save_pvt.UpdateQuoteForSharee()');
   END IF;

   -- Standard Start of API savepoint
   SAVEPOINT    UpdateQuoteForSharee_pvt;
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

  -- API body

   IBE_Quote_Misc_pvt.getQuoteOwner(
      p_api_version_number  => p_api_version_number
     ,p_quote_header_id    => p_qte_header_rec.quote_header_id
     ,x_party_id           => l_quote_Party_id
     ,x_cust_account_id    => l_quote_Cust_account_id
     ,X_Return_Status      => x_return_status
     ,X_Msg_Count          => x_msg_count
         ,X_Msg_Data           => x_msg_data);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_qte_header_rec                 := p_qte_header_rec;
  l_qte_header_rec.party_id        := p_sharee_Party_id;
  l_qte_header_rec.cust_account_id := p_sharee_Cust_account_id;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('ASO_Quote_Pub.Update_Quote() starts');
  END IF;

  ASO_Quote_Pub.Update_Quote(
     P_Api_Version_Number        => P_Api_Version_Number
          ,P_Init_Msg_List            => FND_API.G_FALSE
          ,P_Commit                => FND_API.G_FALSE
          ,P_Control_Rec            => p_control_rec
          ,P_qte_header_rec            => l_Qte_Header_Rec
          ,P_Qte_Line_Tbl            => p_Qte_Line_Tbl
            ,p_Line_rltship_tbl             => p_Line_rltship_tbl
            ,p_Qte_Line_Dtl_Tbl             => p_Qte_Line_Dtl_Tbl
            ,p_Hd_Price_Attributes_Tbl      => p_Hd_Price_Attributes_Tbl
            ,p_Hd_Payment_Tbl               => p_Hd_Payment_Tbl
            ,p_Hd_Shipment_Tbl              => p_Hd_Shipment_Tbl
            ,p_Hd_Tax_Detail_Tbl            => p_Hd_Tax_Detail_Tbl
            ,p_Ln_Price_Attributes_Tbl      => p_Ln_Price_Attributes_Tbl
            ,p_Ln_Payment_Tbl               => p_Ln_Payment_Tbl
            ,p_Ln_Shipment_Tbl              => p_Ln_Shipment_Tbl
            ,p_Ln_Tax_Detail_Tbl            => p_Ln_Tax_Detail_Tbl
            ,p_Price_Adj_Attr_Tbl           => p_Price_Adj_Attr_Tbl
            ,p_Price_Adjustment_Tbl         => p_Price_Adjustment_Tbl
            ,p_Price_Adj_Rltship_Tbl        => p_Price_Adj_Rltship_Tbl
            ,p_Line_Attr_Ext_Tbl            => p_Line_Attr_Ext_Tbl
            ,p_Hd_Freight_Charge_Tbl        => p_Hd_Freight_Charge_Tbl
            ,p_Ln_Freight_Charge_Tbl        => p_Ln_Freight_Charge_Tbl

          ,x_qte_header_rec            => x_Qte_Header_Rec
          ,X_Qte_Line_Tbl            => x_Qte_Line_Tbl
          ,X_Qte_Line_Dtl_Tbl            => lx_Qte_Line_Dtl_Tbl
            ,x_Hd_Price_Attributes_Tbl        => lX_Hd_Price_Attributes_Tbl
            ,X_Hd_Payment_Tbl            => lx_Hd_Payment_Tbl
            ,X_Hd_Shipment_Tbl            => lx_Hd_Shipment_Tbl
            ,X_Hd_Freight_Charge_Tbl        => lx_Hd_Freight_Charge_Tbl
            ,X_Hd_Tax_Detail_Tbl        => lx_Hd_Tax_Detail_Tbl
          ,x_Line_Attr_Ext_Tbl            => lx_Line_Attr_Ext_Tbl
          ,X_Line_rltship_tbl            => lx_Line_Rltship_Tbl
          ,X_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl
            ,X_Price_Adj_Attr_Tbl        => lX_Price_Adj_Attr_Tbl
          ,X_Price_Adj_Rltship_Tbl        => lx_Price_Adj_Rltship_Tbl
            ,X_Ln_Price_Attributes_Tbl        => lX_Ln_Price_Attributes_Tbl
            ,X_Ln_Payment_Tbl            => lx_Ln_Payment_Tbl
            ,X_Ln_Shipment_Tbl            => lx_Ln_Shipment_Tbl
            ,X_Ln_Freight_Charge_Tbl        => lx_Ln_Freight_Charge_Tbl
            ,X_Ln_Tax_Detail_Tbl            => lx_Ln_Tax_Detail_Tbl
          ,X_Return_Status                => x_return_status
          ,X_Msg_Count                    => x_msg_count
          ,X_Msg_Data                     => x_msg_data);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('ASO_Quote_Pub.Update_Quote() finishes');
  END IF;

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- #2: set control_rec to NOT recalculate the price
  --     and set the owner back

  if ( not fnd_api.To_Boolean(p_changeowner)) then
        l_qte_header_rec := p_qte_header_rec;
    l_qte_header_rec.last_update_date :=x_qte_header_rec.last_update_date;

    l_qte_header_rec.party_id        := l_Quote_Party_id;
    l_qte_header_rec.cust_account_id := l_Quote_Cust_account_id;

        l_control_rec := ASO_Quote_Pub.G_MISS_Control_Rec;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('ASO_Quote_Pub.Update_Quote() starts');
       END IF;

       ASO_Quote_Pub.Update_quote(
          P_Api_Version_Number        => P_Api_Version_Number
          ,P_Init_Msg_List            => FND_API.G_FALSE
          ,P_Commit                => FND_API.G_FALSE
         ,P_qte_header_rec            => l_Qte_Header_Rec
          ,x_qte_header_rec            => x_Qte_Header_Rec
          ,X_Qte_Line_Tbl            => x_Qte_Line_Tbl
          ,X_Qte_Line_Dtl_Tbl            => lx_Qte_Line_Dtl_Tbl
            ,x_Hd_Price_Attributes_Tbl        => lX_Hd_Price_Attributes_Tbl
            ,X_Hd_Payment_Tbl            => lx_Hd_Payment_Tbl
            ,X_Hd_Shipment_Tbl            => lx_Hd_Shipment_Tbl
            ,X_Hd_Freight_Charge_Tbl        => lx_Hd_Freight_Charge_Tbl
            ,X_Hd_Tax_Detail_Tbl        => lx_Hd_Tax_Detail_Tbl
          ,x_Line_Attr_Ext_Tbl            => lx_Line_Attr_Ext_Tbl
          ,X_Line_rltship_tbl            => lx_Line_Rltship_Tbl
          ,X_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl
            ,X_Price_Adj_Attr_Tbl        => lX_Price_Adj_Attr_Tbl
          ,X_Price_Adj_Rltship_Tbl        => lx_Price_Adj_Rltship_Tbl
            ,X_Ln_Price_Attributes_Tbl        => lX_Ln_Price_Attributes_Tbl
            ,X_Ln_Payment_Tbl            => lx_Ln_Payment_Tbl
            ,X_Ln_Shipment_Tbl            => lx_Ln_Shipment_Tbl
            ,X_Ln_Freight_Charge_Tbl        => lx_Ln_Freight_Charge_Tbl
            ,X_Ln_Tax_Detail_Tbl            => lx_Ln_Tax_Detail_Tbl
          ,X_Return_Status                => x_return_status
          ,X_Msg_Count                    => x_msg_count
          ,X_Msg_Data                     => x_msg_data);

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('ASO_Quote_Pub.Update_Quote() finishes');
       END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  END IF;

  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
     COMMIT WORK;
  END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_Quote_Save_pvt.UpdateQuoteForSharee()');
   END IF;
   -- IBE_Util.Disable_Debug;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UpdateQuoteForSharee_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Save_pvt.UpdateQuoteForSharee()');
      END IF;
      -- IBE_Util.Disable_Debug;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UpdateQuoteForSharee_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Save_pvt.UpdateQuoteForSharee()');
      END IF;
      -- IBE_Util.Disable_Debug;
   WHEN OTHERS THEN
      ROLLBACK TO UpdateQuoteForSharee_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Save_pvt.UpdateQuoteForSharee()');
      END IF;
      -- IBE_Util.Disable_Debug;
END UpdateQuoteForSharee;


/* ------------------------------ Default API's: Start -----------------*/

PROCEDURE getHdrDefaultValues(
  P_Api_Version_Number        IN   NUMBER
  ,p_Init_Msg_List            IN   VARCHAR2   := FND_API.G_FALSE
  ,p_Commit                   IN   VARCHAR2   := FND_API.G_FALSE

  ,p_minisite_id              IN   NUMBER

  ,p_Qte_Header_Rec           IN   ASO_Quote_Pub.Qte_Header_Rec_Type
                                     := ASO_Quote_Pub.G_MISS_Qte_Header_Rec
  ,p_hd_Price_Attributes_Tbl  IN   ASO_Quote_Pub.Price_Attributes_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl
  ,p_hd_Payment_Tbl           IN   ASO_Quote_Pub.Payment_Tbl_Type
                                     := ASO_Quote_Pub.G_MISS_PAYMENT_TBL
  ,p_hd_Shipment_TBL          IN   ASO_Quote_Pub.Shipment_tbl_Type
                                     := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL
  ,p_hd_Freight_Charge_Tbl    IN   ASO_Quote_Pub.Freight_Charge_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl
  ,p_hd_Tax_Detail_Tbl        IN   ASO_Quote_Pub.Tax_Detail_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl
  ,p_Price_Adjustment_Tbl     IN   ASO_Quote_Pub.Price_Adj_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl
  ,p_Price_Adj_Attr_Tbl       IN   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl
  ,p_Price_Adj_Rltship_Tbl    IN   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
                                     := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl

  ,x_Qte_Header_Rec           OUT NOCOPY   ASO_Quote_Pub.Qte_Header_Rec_Type
  ,x_hd_Price_Attributes_Tbl  OUT NOCOPY   ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_hd_Payment_Tbl           OUT NOCOPY   ASO_Quote_Pub.Payment_Tbl_Type
  ,x_hd_Shipment_TBL          OUT NOCOPY   ASO_Quote_Pub.Shipment_tbl_Type
  ,x_hd_Freight_Charge_Tbl    OUT NOCOPY   ASO_Quote_Pub.Freight_Charge_Tbl_Type
  ,x_hd_Tax_Detail_Tbl        OUT NOCOPY   ASO_Quote_Pub.Tax_Detail_Tbl_Type
  ,x_Price_Adjustment_Tbl     OUT NOCOPY   ASO_Quote_Pub.Price_Adj_Tbl_Type
  ,x_Price_Adj_Attr_Tbl       OUT NOCOPY   ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
  ,x_Price_Adj_Rltship_Tbl    OUT NOCOPY   ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type

  ,x_last_update_date         OUT NOCOPY  DATE
  ,X_Return_Status            OUT NOCOPY  VARCHAR2
  ,X_Msg_Count                OUT NOCOPY  NUMBER
  ,X_Msg_Data                 OUT NOCOPY  VARCHAR2
)

IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'getHdrDefaultValues';
  l_api_version               CONSTANT NUMBER         := 1.0;

  lx_Qte_Header_Rec           ASO_Quote_Pub.Qte_Header_Rec_Type;
  lx_Hd_Price_Attributes_Tbl  ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_Hd_Payment_Tbl           ASO_Quote_Pub.Payment_Tbl_Type;

  lx_Hd_Shipment_Tbl          ASO_Quote_Pub.Shipment_Tbl_Type;
  lx_Hd_Shipment_Rec          ASO_Quote_Pub.Shipment_Rec_Type;
  lx_Hd_Freight_Charge_Tbl    ASO_Quote_Pub.Freight_Charge_Tbl_Type ;
  lx_Hd_Tax_Detail_Tbl        ASO_Quote_Pub.TAX_DETAIL_TBL_TYPE;

  lx_Price_Adjustment_Tbl     ASO_Quote_Pub.Price_Adj_Tbl_Type;
  lx_Price_Adj_Attr_Tbl       ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
  lx_Price_Adj_Rltship_Tbl    ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

  l_userType                  VARCHAR2(10);
  l_cvv2_setup                VARCHAR2(1);
  l_statement_address_setup   VARCHAR2(1);
BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT getHdrDefaultValues_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      P_Api_Version_Number,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Start   IBE_Quote_Save_pvt.getHdrDefaultValues()');
      IBE_Util.Debug('APPLE1:'||p_Qte_Header_Rec.party_id);
--       IBE_Util.Debug('APPLE1:'||p_Qte_Header_Rec.cust_acct_id);
      IBE_Util.Debug('APPLE1:'||p_Qte_Header_Rec.quote_header_id);
   END IF;

   -- We will call the various helper api's to get default values
   -- #* First we have to make sure we pass and get the right parameters
   lx_hd_Shipment_TBL   := p_hd_Shipment_TBL;
   lx_qte_header_rec    := p_qte_header_rec;
   lx_hd_Payment_Tbl    := p_hd_Payment_Tbl;
   lx_hd_Tax_Detail_Tbl := p_hd_Tax_Detail_Tbl;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('APPLE2:'||lx_qte_header_rec.party_id);
--       IBE_Util.Debug('APPLE2:'||lx_qte_header_rec.cust_acct_id);
      IBE_Util.Debug('APPLE2:'||lx_qte_header_rec.quote_header_id);
   END IF;

   -- #1 Shipping Info
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('getHdrDefaultAddress() -- SHIPTO starts');
   END IF;
   getHdrDefaultAddress       (
                               P_Api_Version_Number   => P_Api_Version_Number
                              ,p_Init_Msg_List        => p_Init_Msg_List
                              ,p_Commit               => p_Commit
                              ,px_hd_Shipment_TBL     => lx_hd_Shipment_TBL
                              ,px_qte_header_rec      => lx_qte_header_rec
                              ,p_party_site_use       => 'S'
                              ,X_Return_Status        => X_Return_Status
                              ,X_Msg_Count            => X_Msg_Count
                              ,X_Msg_Data             => X_Msg_Data
                              );
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('getHdrDefaultAddress() -- SHIPTO finishes');
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   if (lx_hd_shipment_tbl.count <> 0) then
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('lx_hd_shipment_tbl.ship_to_party_site_id: '||lx_hd_shipment_tbl(1).ship_to_party_site_id);
     END IF;
     --dbms_output.put_line('lx_hd_shipment_tbl.ship_to_party_site_id: '||lx_hd_shipment_tbl(1).ship_to_party_site_id);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('lx_hd_shipment_tbl.shipment_id:           '||lx_hd_shipment_tbl(1).shipment_id);
     END IF;
     --dbms_output.put_line('lx_hd_shipment_tbl.shipment_id:           '||lx_hd_shipment_tbl(1).shipment_id);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('lx_hd_shipment_tbl.quote_header_id:       '||lx_hd_shipment_tbl(1).quote_header_id);
     END IF;
     --dbms_output.put_line('lx_hd_shipment_tbl.quote_header_id:       '||lx_hd_shipment_tbl(1).quote_header_id);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('lx_hd_shipment_tbl.operation_code:        '||lx_hd_shipment_tbl(1).operation_code);
     END IF;
     --dbms_output.put_line('lx_hd_shipment_tbl.operation_code:        '||lx_hd_shipment_tbl(1).operation_code);

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('*******************************');
     END IF;
     --dbms_output.put_line('*******************************');

     -- 9/11/02: we only call this api if we were able to find the shipTo address because if we can't find
     --    this info, we can't default the contact
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultShipMethod() starts');
     END IF;
     getHdrDefaultShipMethod    (
                                 P_Api_Version_Number   => P_Api_Version_Number
                                ,p_Init_Msg_List        => p_Init_Msg_List
                                ,p_Commit               => p_Commit
                                ,px_hd_Shipment_TBL     => lx_hd_Shipment_TBL
                                ,p_qte_header_rec       => lx_qte_header_rec
                                ,p_minisite_id          => p_minisite_id
                                ,X_Return_Status        => X_Return_Status
                                ,X_Msg_Count            => X_Msg_Count
                                ,X_Msg_Data             => X_Msg_Data
                                );
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultShipMethod() finishes');
     END IF;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     if (lx_hd_Shipment_Tbl.count <> 0) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Shipment_Tbl.shipment_id:           '||lx_hd_Shipment_Tbl(1).shipment_id);
       END IF;
       --dbms_output.put_line('lx_hd_Shipment_Tbl.shipment_id:           '||lx_hd_Shipment_Tbl(1).shipment_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Shipment_Tbl.quote_header_id:       '||lx_hd_Shipment_Tbl(1).quote_header_id);
       END IF;
       --dbms_output.put_line('lx_hd_Shipment_Tbl.quote_header_id:       '||lx_hd_Shipment_Tbl(1).quote_header_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Shipment_Tbl.operation_code:        '||lx_hd_Shipment_Tbl(1).operation_code);
       END IF;
       --dbms_output.put_line('lx_hd_Shipment_Tbl.operation_code:        '||lx_hd_Shipment_Tbl(1).operation_code);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Shipment_Tbl.SHIP_METHOD_CODE:      '||lx_hd_Shipment_Tbl(1).SHIP_METHOD_CODE);
       END IF;
       --dbms_output.put_line('lx_hd_Shipment_Tbl.SHIP_METHOD_CODE:      '||lx_hd_Shipment_Tbl(1).SHIP_METHOD_CODE);

     end if;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('*******************************');
     END IF;
     --dbms_output.put_line('*******************************');
   end if; -- if there is shipTo address

   -- #2 Billing Info
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('getHdrDefaultAddress() -- BILLTO starts');
      IBE_Util.Debug('STAR 123 getHdrDefaultAddress()' || lx_qte_header_rec.party_id);
   END IF;
   getHdrDefaultAddress       (
                               P_Api_Version_Number   => P_Api_Version_Number
                              ,p_Init_Msg_List        => p_Init_Msg_List
                              ,p_Commit               => p_Commit
                              ,px_hd_Shipment_TBL     => lx_hd_Shipment_TBL
                              ,px_qte_header_rec      => lx_qte_header_rec
                              ,p_party_site_use       => 'B'
                              ,X_Return_Status        => X_Return_Status
                              ,X_Msg_Count            => X_Msg_Count
                              ,X_Msg_Data             => X_Msg_Data
                              );
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('getHdrDefaultAddress() -- BILLTO finishes');
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('lx_qte_header_rec.INVOICE_TO_PARTY_SITE_ID: '||to_char(lx_qte_header_rec.INVOICE_TO_PARTY_SITE_ID));
   END IF;
   --dbms_output.put_line('lx_qte_header_rec.INVOICE_TO_PARTY_SITE_ID: '||to_char(lx_qte_header_rec.INVOICE_TO_PARTY_SITE_ID));
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('*******************************');
   END IF;
   --dbms_output.put_line('*******************************');

   IBE_PAYMENT_INT_PVT.check_Payment_channel_setups
            (p_api_version             => 1.0
            ,p_init_msg_list           => FND_API.G_FALSE
            ,p_commit                  => FND_API.G_FALSE
            ,x_cvv2_setup              => l_cvv2_setup
            ,x_statement_address_setup => l_statement_address_setup
            ,x_return_status           => X_Return_Status
            ,x_msg_count               => x_msg_count
            ,x_msg_data                => x_msg_data );
   /*mannamra: Credit card consolidation: payment type defaulting should not kick in only when CVV2
                                          is mandatory so that user will be able to visit the
                                          billing page to provide the credit card cvv2 number*/
   IF(l_cvv2_setup <> FND_API.G_TRUE) THEN


     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('getHdrDefaultPaymentMethod() starts');
     END IF;
     getHdrDefaultPaymentMethod (
                               P_Api_Version_Number   => P_Api_Version_Number
                              ,p_Init_Msg_List        => p_Init_Msg_List
                              ,p_Commit               => p_Commit
                              ,px_hd_Payment_Tbl      => lx_hd_Payment_Tbl
                              ,p_qte_header_rec       => lx_qte_header_rec
                              ,p_minisite_id          => p_minisite_id
                              ,X_Return_Status        => X_Return_Status
                              ,X_Msg_Count            => X_Msg_Count
                              ,X_Msg_Data             => X_Msg_Data
                              );
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('getHdrDefaultPaymentMethod() finishes');
     END IF;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     if (lx_hd_Payment_Tbl.count <> 0) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.payment_id:            '||lx_hd_Payment_Tbl(1).payment_id);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.payment_id:            '||lx_hd_Payment_Tbl(1).payment_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.quote_header_id:       '||lx_hd_Payment_Tbl(1).quote_header_id);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.quote_header_id:       '||lx_hd_Payment_Tbl(1).quote_header_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.operation_code:        '||lx_hd_Payment_Tbl(1).operation_code);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.operation_code:        '||lx_hd_Payment_Tbl(1).operation_code);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.PAYMENT_TYPE_CODE:     '||lx_hd_Payment_Tbl(1).PAYMENT_TYPE_CODE);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.PAYMENT_TYPE_CODE:     '||lx_hd_Payment_Tbl(1).PAYMENT_TYPE_CODE);

       --IBE_Util.Debug('lx_hd_Payment_Tbl.PAYMENT_REF_NUMBER:    '||lx_hd_Payment_Tbl(1).PAYMENT_REF_NUMBER);
       --dbms_output.put_line('lx_hd_Payment_Tbl.PAYMENT_REF_NUMBER:    '||lx_hd_Payment_Tbl(1).PAYMENT_REF_NUMBER);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.PAYMENT_TERM_ID:       '||lx_hd_Payment_Tbl(1).PAYMENT_TERM_ID);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.PAYMENT_TERM_ID:       '||lx_hd_Payment_Tbl(1).PAYMENT_TERM_ID);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.CREDIT_CARD_CODE:      '||lx_hd_Payment_Tbl(1).CREDIT_CARD_CODE);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.CREDIT_CARD_CODE:      '||lx_hd_Payment_Tbl(1).CREDIT_CARD_CODE);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.CREDIT_CARD_HOLDER_NAME:     '||lx_hd_Payment_Tbl(1).CREDIT_CARD_HOLDER_NAME);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.CREDIT_CARD_HOLDER_NAME:     '||lx_hd_Payment_Tbl(1).CREDIT_CARD_HOLDER_NAME);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('lx_hd_Payment_Tbl.CREDIT_CARD_EXPIRATION_DATE: '||lx_hd_Payment_Tbl(1).CREDIT_CARD_EXPIRATION_DATE);
       END IF;
       --dbms_output.put_line('lx_hd_Payment_Tbl.CREDIT_CARD_EXPIRATION_DATE: '||lx_hd_Payment_Tbl(1).CREDIT_CARD_EXPIRATION_DATE);
     end if;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('*******************************');
     END IF;
   END IF;  --l_cvv2_setup <> FND_API.G_TRUE
   --dbms_output.put_line('*******************************');

   if ((lx_qte_header_rec.invoice_to_party_site_id <> fnd_api.g_miss_num) and (lx_qte_header_rec.invoice_to_party_site_id is not null) ) then
     -- 9/11/02: we only call this api if we were able to find the billTo address because if we can't find
     --    this info, we can't default the contact
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultTaxExemption() starts');
     END IF;
     getHdrDefaultTaxExemption  (
                                 P_Api_Version_Number   => P_Api_Version_Number
                                ,p_Init_Msg_List        => p_Init_Msg_List
                                ,p_Commit               => p_Commit
                                ,px_hd_Tax_Detail_Tbl   => lx_hd_Tax_Detail_Tbl
                                ,p_qte_header_rec       => lx_qte_header_rec
                                ,X_Return_Status        => X_Return_Status
                                ,X_Msg_Count            => X_Msg_Count
                                ,X_Msg_Data             => X_Msg_Data
                                );
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultTaxExemption() finishes');
     END IF;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     if (lx_hd_Tax_Detail_Tbl.count <> 0) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Tax_Detail_Tbl.tax_detail_id:         '||lx_hd_Tax_Detail_Tbl(1).tax_detail_id);
       END IF;
       --dbms_output.put_line('lx_hd_Tax_Detail_Tbl.tax_detail_id:         '||lx_hd_Tax_Detail_Tbl(1).tax_detail_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Tax_Detail_Tbl.quote_header_id:       '||lx_hd_Tax_Detail_Tbl(1).quote_header_id);
       END IF;
       --dbms_output.put_line('lx_hd_Tax_Detail_Tbl.quote_header_id:       '||lx_hd_Tax_Detail_Tbl(1).quote_header_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Tax_Detail_Tbl.operation_code:        '||lx_hd_Tax_Detail_Tbl(1).operation_code);
       END IF;
       --dbms_output.put_line('lx_hd_Tax_Detail_Tbl.operation_code:        '||lx_hd_Tax_Detail_Tbl(1).operation_code);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('lx_hd_Tax_Detail_Tbl.tax_exempt_flag:       '||lx_hd_Tax_Detail_Tbl(1).tax_exempt_flag);
       END IF;
       --dbms_output.put_line('lx_hd_Tax_Detail_Tbl.tax_exempt_flag:       '||lx_hd_Tax_Detail_Tbl(1).tax_exempt_flag);

     end if;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('*******************************');
     END IF;
     --dbms_output.put_line('*******************************');
   end if; -- if there is billTo address

   -- #3 End Customer Info (added 1/24/05>
   l_userType := IBE_Quote_Misc_pvt.getUserType(lx_qte_header_rec.party_id);

  -- bug 25993613 if (l_userType = 'B2B') then
   if (l_userType = 'B2B' AND nvl(FND_PROFILE.VALUE('IBE_DISPLAY_END_CUSTOMER_INFO'),'N') = 'Y') then
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultEndCustomer() bug 25993613 starts');
     END IF;
     getHdrDefaultEndCustomer   (
                                 P_Api_Version_Number   => P_Api_Version_Number
                                ,p_Init_Msg_List        => p_Init_Msg_List
                                ,p_Commit               => p_Commit
                                ,px_Qte_Header_Rec      => lx_Qte_Header_Rec
                                ,p_hd_Shipment_TBL      => lx_hd_Shipment_TBL
                                ,X_Return_Status        => X_Return_Status
                                ,X_Msg_Count            => X_Msg_Count
                                ,X_Msg_Data             => X_Msg_Data
                                );
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultEndCustomer() finishes');
     END IF;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   end if;


   -- #* Finally we have to make sure we pass and get the right parameters
   x_hd_Shipment_TBL   := lx_hd_Shipment_TBL;
   x_qte_header_rec    := lx_qte_header_rec;
   x_hd_Payment_Tbl    := lx_hd_Payment_Tbl;
   x_hd_Tax_Detail_Tbl := lx_hd_Tax_Detail_Tbl;
   --maithili added for R12, for creating header level offer codes
   x_hd_Price_Attributes_Tbl := p_hd_Price_Attributes_Tbl;
   -- End of API body.
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultValues()');
   END IF;
   --IBE_Util.Disable_Debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getHdrDefaultValues_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getHdrDefaultValues_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO getHdrDefaultValues_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
END getHdrDefaultValues;


PROCEDURE getHdrDefaultAddress(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Shipment_TBL   IN OUT NOCOPY ASO_Quote_Pub.Shipment_tbl_Type
                              ,px_qte_header_rec    IN OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,p_party_site_use     IN varchar2
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              )
is

     l_api_name                        CONSTANT VARCHAR2(30)   := 'getHdrDefaultAddress';
     l_api_version                     CONSTANT NUMBER         := 1.0;

     l_opCode                          varchar2(10)            := 'CREATE';
     l_party_id                        number                  := px_qte_header_rec.party_id;
     lx_party_site_id                  number;
     l_shipment_id                     number                  := FND_API.G_MISS_NUM;

     l_isDone                          varchar2(1)             := 'N';

     l_userType                        varchar2(30);

     --shipTo
     cursor c_check_shipTo_rec_exist(l_quote_header_id number)
     is
       select shipment_id, SHIP_TO_PARTY_SITE_ID
         from ASO_shipments
         where QUOTE_HEADER_ID = l_quote_header_id                 and
               quote_line_id is null;
     rec_shipTo_rec_exist              c_check_shipTo_rec_exist%rowtype;

     cursor c_check_shipTo_partyId(l_quote_header_id number)
     is
       select ship_to_party_id
         from ASO_shipments
         where QUOTE_HEADER_ID = l_quote_header_id                 and
               quote_line_id is null                               and
               SHIP_TO_CUST_ACCOUNT_ID is null                     and
               SHIP_TO_PARTY_SITE_ID is null;
     rec_shipTo_partyId                c_check_shipTo_partyId%rowtype;

     -- billTo
     cursor c_check_billTo_rec_exist(l_quote_header_id number)
     is
       select quote_header_id, INVOICE_TO_PARTY_SITE_ID
         from ASO_quote_headers
         where QUOTE_HEADER_ID = l_quote_header_id;
     rec_billTo_rec_exist              c_check_billTo_rec_exist%rowtype;

     cursor c_check_billTo_partyId(l_quote_header_id number)
     is
       select invoice_to_party_id
         from ASO_quote_headers
         where QUOTE_HEADER_ID = l_quote_header_id                 and
               INVOICE_TO_CUST_ACCOUNT_ID is null                  and
               INVOICE_TO_PARTY_SITE_ID is null;

     rec_billTo_partyId                c_check_billTo_partyId%rowtype;

begin

     -- Standard Start of API savepoint
     SAVEPOINT getHdrDefaultAddress_pvt;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                        P_Api_Version_Number,
                                        L_API_NAME   ,
                                        G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Begin   IBE_Quote_Save_pvt.getHdrDefaultAddress()');
     END IF;
     -- 1. for the merge cart cases, we have to check if there is shipment/billing address in the shipment/quote header record associated w/ the cart:
     /*
     *Here is the general algorithm:
      if there is already shipTo partySiteId               -> we're done
      else if there is no shipmentId                       -> partyId = cookie's
                                                              opCode  = Create
      else
                                                              opCode  = Update
         if shipTo_partyId is not null                     -> partyId = shipTo_partyId
         else
           there is shipment record but no shipTo_partyId  -> partyId = cookie's
     */

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getDefaultAddress: l_party_id                       ='||l_party_id);
     END IF;
     --DBMS_OUTPUT.PUT_line('getDefaultAddress: l_party_id                       ='||l_party_id);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getDefaultAddress: px_qte_header_rec.quote_header_id='||px_qte_header_rec.quote_header_id);
     END IF;
     --DBMS_OUTPUT.PUT_line('getDefaultAddress: px_qte_header_rec.quote_header_id='||px_qte_header_rec.quote_header_id);
     if ((px_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM) and (px_qte_header_rec.quote_header_id is not null)) then
        if (p_party_site_use = 'S') then

           -- check to see if there is already a shipTo partySiteId
           open c_check_shipTo_rec_exist (px_qte_header_rec.quote_header_id);
           fetch c_check_shipTo_rec_exist into rec_shipTo_rec_exist;
           close c_check_shipTo_rec_exist;

           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('getDefaultAddress: px_qte_header_rec.quote_header_id         ='||px_qte_header_rec.quote_header_id);
           END IF;
           --DBMS_OUTPUT.PUT_line('getDefaultAddress: px_qte_header_rec.quote_header_id         ='||px_qte_header_rec.quote_header_id);
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('getDefaultAddress: rec_shipTo_rec_exist.SHIP_TO_PARTY_SITE_ID='||rec_shipTo_rec_exist.SHIP_TO_PARTY_SITE_ID);
           END IF;
           --DBMS_OUTPUT.PUT_line('getDefaultAddress: rec_shipTo_rec_exist.SHIP_TO_PARTY_SITE_ID='||rec_shipTo_rec_exist.SHIP_TO_PARTY_SITE_ID);
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_Util.Debug('getDefaultAddress: rec_shipTo_rec_exist.shipment_id          ='||rec_shipTo_rec_exist.shipment_id);
           END IF;
           --DBMS_OUTPUT.PUT_line('getDefaultAddress: rec_shipTo_rec_exist.shipment_id          ='||rec_shipTo_rec_exist.shipment_id);

           -- if there is already a shipTo partySiteId, we are done
           if ((rec_shipTo_rec_exist.SHIP_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM) and (rec_shipTo_rec_exist.SHIP_TO_PARTY_SITE_ID is not null)) then
             l_isDone := 'Y';

           -- if there is no shipmentId
           elsif ((rec_shipTo_rec_exist.shipment_id = FND_API.G_MISS_NUM) or (rec_shipTo_rec_exist.shipment_id is null)) then
             l_party_id := px_qte_header_rec.party_id;
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('getDefaultAddress: l_party_id-no shipId-='||l_party_id);
             END IF;
             --DBMS_OUTPUT.PUT_line('getDefaultAddress: l_party_id-no shipId-='||l_party_id);

           else
             l_opCode      := 'UPDATE';
             l_shipment_id := rec_shipTo_rec_exist.shipment_id;
             -- if not, check if there is a shipTo partyId
             open c_check_shipTo_partyId (px_qte_header_rec.quote_header_id);
             fetch c_check_shipTo_partyId into rec_shipTo_partyId;
             close c_check_shipTo_partyId;

             -- if there is shipTo contact
             if ((rec_shipTo_partyId.ship_to_party_id <> FND_API.G_MISS_NUM) and (rec_shipTo_partyId.ship_to_party_id is not null)) then
               l_party_id := rec_shipTo_partyId.ship_to_party_id;
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug('getDefaultAddress: l_party_id-contact-='||l_party_id);
               END IF;
               --DBMS_OUTPUT.PUT_line('getDefaultAddress: l_party_id-contact-='||l_party_id);
             else
               l_party_id := px_qte_header_rec.party_id;
               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_Util.Debug('getDefaultAddress: l_party_id-soldTo-='||l_party_id);
               END IF;
               --DBMS_OUTPUT.PUT_line('getDefaultAddress: l_party_id-soldTo-='||l_party_id);
             end if;

           end if;

        elsif (p_party_site_use = 'B') then

           -- check to see if there is already a billTo partySiteId
           open c_check_billTo_rec_exist (px_qte_header_rec.quote_header_id);
           fetch c_check_billTo_rec_exist into rec_billTo_rec_exist;
           close c_check_billTo_rec_exist;

           -- if there is already a billTo partySiteId, we are done
           if ((rec_billTo_rec_exist.INVOICE_TO_PARTY_SITE_ID <> FND_API.G_MISS_NUM) and (rec_billTo_rec_exist.INVOICE_TO_PARTY_SITE_ID is not null)) then
             l_isDone := 'Y';

           -- if there is no quote record (shouldn't happen; should also raise an error)
           elsif ((rec_billTo_rec_exist.quote_header_id = FND_API.G_MISS_NUM) or (rec_billTo_rec_exist.quote_header_id is null)) then
             l_party_id := px_qte_header_rec.party_id;

           else
             l_opCode := 'UPDATE';

             -- if not, check if there is a billTo partyId
             open c_check_billTo_partyId (px_qte_header_rec.quote_header_id);
             fetch c_check_billTo_partyId into rec_billTo_partyId;
             close c_check_billTo_partyId;

             -- if there is billTo contact
             if ((rec_billTo_partyId.invoice_to_party_id <> FND_API.G_MISS_NUM) and (rec_billTo_partyId.invoice_to_party_id is not null)) then
               l_party_id := rec_billTo_partyId.invoice_to_party_id;
             else
               l_party_id := px_qte_header_rec.party_id;
             end if;

           end if;

        end if; -- check p_party_site_use
     end if;    -- for merge cart cases

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_party_id      ='||l_party_id);
     END IF;
     --DBMS_OUTPUT.PUT_line('l_party_id      ='||l_party_id);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('p_party_site_use='||p_party_site_use);
     END IF;
     --DBMS_OUTPUT.PUT_line('p_party_site_use='||p_party_site_use);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_orgId         ='||MO_GLOBAL.get_current_org_id());
     END IF;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_isDone        ='||l_isDone);
     END IF;
     --DBMS_OUTPUT.PUT_line('l_isDone        ='||l_isDone);

     -- 2. if there isn't a record, continue
     if (l_isDone <> 'Y') then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Before calling IBE_ADDRESS_V2PVT.get_primary_address_id');
        END IF;
        --DBMS_OUTPUT.PUT_line('Before calling IBE_ADDRESS_V2PVT.get_primary_address_id');
        IBE_ADDRESS_V2PVT.get_primary_addr_id
                                                   (
                                                    p_api_version     => p_Api_Version_Number
                                                   ,p_init_msg_list   => p_Init_Msg_List
                                                   ,p_commit          => p_Commit
                                                   ,p_party_id        => l_party_id
                                                   ,p_site_use_type   => p_party_site_use
                                                   ,p_org_id          => MO_Global.get_current_org_id()
										 ,p_get_org_prim_addr => FND_API.G_TRUE
                                                   ,x_return_status   => x_return_status
                                                   ,x_msg_count       => x_msg_count
                                                   ,x_msg_data        => x_msg_data
                                                   ,x_party_site_id   => lx_party_site_id
                                                   );
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('After calling IBE_ADDRESS_V2PVT.get_primary_address_id');
        END IF;
        --DBMS_OUTPUT.PUT_line('After calling IBE_ADDRESS_V2PVT.get_primary_address_id');
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('lx_party_site_id      ='||lx_party_site_id);
        END IF;
        --DBMS_OUTPUT.PUT_line('lx_party_site_id      ='||lx_party_site_id);

        -- 2.1 populate the shipment/quote hdr record:
       -- 27-Mar-2018  Bug 27535105 - amaheshw Commented below line
        -- if ((lx_party_site_id <> -1) and (lx_party_site_id <> fnd_api.g_miss_num) and (lx_party_site_id is not null) ) then
        l_userType                                  := IBE_Quote_Misc_pvt.getUserType(px_qte_header_rec.party_id);
        if (p_party_site_use = 'S') then
          px_hd_Shipment_TBL(1).shipment_id          := l_shipment_id;
          px_hd_Shipment_TBL(1).quote_header_id      := px_qte_header_rec.quote_header_id;
          px_hd_Shipment_TBL(1).operation_code       := l_opCode;
          px_hd_Shipment_TBL(1).SHIP_TO_PARTY_site_ID := lx_party_site_id;
          if ( ((rec_shipTo_partyId.ship_to_party_id    = FND_API.G_MISS_NUM) or (rec_shipTo_partyId.ship_to_party_id    is null)) and (l_userType = 'B2B') ) then
            px_hd_Shipment_TBL(1).SHIP_TO_PARTY_ID   := px_qte_header_rec.party_id;
          end if;
        elsif (p_party_site_use = 'B') then
          px_qte_header_rec.INVOICE_TO_PARTY_SITE_ID := lx_party_site_id;
          if ( ((rec_billTo_partyId.invoice_to_party_id = FND_API.G_MISS_NUM) or (rec_billTo_partyId.invoice_to_party_id is null)) and (l_userType = 'B2B') ) then
            px_qte_header_rec.INVOICE_TO_PARTY_ID    := px_qte_header_rec.party_id;
        end if;
        end if;
     --27-Mar-2018  commented for Bug 27535105 - amaheshw   end if;

     end if; -- if (l_isDone <> 'Y')

     -- End of API body.
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultAddress()');
     END IF;
     --IBE_Util.Disable_Debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getHdrDefaultAddress_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getHdrDefaultAddress_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO getHdrDefaultAddress_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

end getHdrDefaultAddress;

PROCEDURE getHdrDefaultShipMethod(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Shipment_TBL   IN OUT NOCOPY ASO_Quote_Pub.Shipment_tbl_Type
                              ,p_qte_header_rec     IN     ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,p_minisite_id        IN     Number
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              )

is

     l_api_name                   CONSTANT VARCHAR2(30)   := 'getHdrDefaultShipMethod';
     l_api_version                CONSTANT NUMBER         := 1.0;
     l_opCode                     varchar2(10)            := 'CREATE';

     l_shipment_id                number                  := FND_API.G_MISS_NUM;
     l_isDone                     varchar2(1)             := 'N';

     l_ship_method_code           varchar2(30)            := null;
     l_ship_method_code_first     varchar2(30)            := null;
     l_org_id                     number                  := MO_GLOBAL.get_current_org_id();
     l_prefSMValid                varchar2(1)             := 'N';
     l_index                      number                  := 1;

     cursor c_check_shipTo_rec_exist(l_quote_header_id number)
     is
       select shipment_id, SHIP_METHOD_CODE
         from ASO_shipments
         where QUOTE_HEADER_ID = l_quote_header_id                 and
               quote_line_id is null;
     rec_shipTo_rec_exist              c_check_shipTo_rec_exist%rowtype;

     cursor c_get_MiniSiteOrg_ShipMethod(l_msite_id number, l_org_id number,l_ship_mthd varchar2, l_web_enabled varchar2, l_enabled_flag varchar2)
     is
       SELECT msite_information1
         FROM ibe_msite_information m, wsh_carrier_ship_methods o, oe_system_parameters_all oesp
         WHERE m.msite_id                    = l_msite_id
           AND m.msite_information_context   = l_ship_mthd
           AND m.msite_information1          = o.ship_method_code
           AND oesp.org_id                   = l_org_id
           AND o.organization_id             = oesp.master_organization_id
           AND o.web_enabled                 = l_web_enabled
           AND o.enabled_flag                = l_enabled_flag
         Order by msite_information1;

     rec_MiniSiteOrg_ShipMethod        c_get_MiniSiteOrg_ShipMethod%rowtype;

begin

     -- Standard Start of API savepoint
     SAVEPOINT getHdrDefaultShipMethod_pvt;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                        P_Api_Version_Number,
                                        L_API_NAME   ,
                                        G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Start   IBE_Quote_Save_pvt.getHdrDefaultShipMethod()');
     END IF;

     -- 1. for the merge cart cases, we have to check if there is shipment method in the shipment record associated w/ the cart:
     if ((p_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM) and (p_qte_header_rec.quote_header_id is not null)) then

        -- check to see if there is already a ship method
        open c_check_shipTo_rec_exist (p_qte_header_rec.quote_header_id);
        fetch c_check_shipTo_rec_exist into rec_shipTo_rec_exist;
        close c_check_shipTo_rec_exist;

        -- if there is already a ship method, we are done
        if ((rec_shipTo_rec_exist.SHIP_METHOD_CODE <> FND_API.G_MISS_char) and (rec_shipTo_rec_exist.SHIP_METHOD_CODE is not null)) then
          l_isDone      := 'Y';

        -- if there is shipmentId
        elsif ((rec_shipTo_rec_exist.shipment_id <> FND_API.G_MISS_NUM) and (rec_shipTo_rec_exist.shipment_id is not null)) then
          l_opCode      := 'UPDATE';
          l_shipment_id := rec_shipTo_rec_exist.shipment_id;
        end if;
     end if;    -- for merge cart cases

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_opCode      :'||l_opCode);
     END IF;
     --DBMS_OUTPUT.PUT_line('l_opCode      :'||l_opCode);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_shipment_id :'||l_shipment_id);
     END IF;
     --DBMS_OUTPUT.PUT_line('l_shipment_id :'||l_shipment_id);

     -- 2. if there isn't a record, continue
     if (l_isDone <> 'Y') then
        -- 2.1 First, look at the prefered Shipment Method profile:
        --      if there is a value then we have to validate this value with the list of shipment methods
        --      created from an intersection of shipment methods in the minisite and those in the operation unit
        l_ship_method_code := FND_PROFILE.VALUE('IBE_PREFERED_SHIP_METHOD');

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('l_ship_method_code      :'||l_ship_method_code||'*');
        END IF;
        --DBMS_OUTPUT.PUT_line('l_ship_method_code      :'||l_ship_method_code||'*');
        if (l_ship_method_code = '') then
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('l_ship_method_code is blank');
          END IF;
          --DBMS_OUTPUT.PUT_line('l_ship_method_code is blank');
        end if;

        -- 2.2 the drop down value: intersection of the minisite ones and the org ones
        --      if there is not preferred ship method, we just take the the first row in the result set
        --      else we have to validate this value w/ this result set

        for rec_MiniSiteOrg_ShipMethod in c_get_MiniSiteOrg_ShipMethod(p_minisite_id, l_org_id,'SHPMT_MTHD','Y','Y')  loop

          -- case 2.2: no preferred ship method -> so, take the first row of the result set
          if ((l_ship_method_code = FND_API.G_MISS_char) or (l_ship_method_code is null)) then

            -- 11/14/02: we're changing the logic: if no preferred ship method, then don't default
	    -- Now, as per ER#4663790, we need to default, so uncommenting the following line.

            l_ship_method_code := rec_MiniSiteOrg_ShipMethod.msite_information1;
            -- l_ship_method_code := null; -- commenting for ER# 4663790

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_Util.Debug('case 2.2: l_ship_method_code      :'||l_ship_method_code);
            END IF;

            l_prefSMValid := 'Y';
            exit;
          else
            -- case 2.1: validate preferred ship method w/ the result set
            if (l_ship_method_code = rec_MiniSiteOrg_ShipMethod.msite_information1) then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_Util.Debug('case 2.1: l_ship_method_code      :'||l_ship_method_code);
              END IF;
              l_prefSMValid := 'Y';
              exit;
            end if;

            -- case 2.2 #2: if preferred ship method is not in result set, then take the first row of the result set
            --               Hence, we have to keep track of the first row
            if (l_index = 1) then
              l_ship_method_code_first := rec_MiniSiteOrg_ShipMethod.msite_information1;
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_Util.Debug('l_ship_method_code_first      :'||l_ship_method_code_first);
              END IF;
              l_index := 2;
            end if;
          end if;

          exit when c_get_MiniSiteOrg_ShipMethod%notfound;
        end loop;
        --close c_get_MiniSiteOrg_ShipMethod;

        -- case 2.2 #2:
        if (l_prefSMValid = 'N') then

          -- 11/14/02: we're changing the logic: if no preferred ship method, then don't default
          -- Now, as per ER#4663790, we need to default, so uncommenting the following line.
             l_ship_method_code := l_ship_method_code_first;

          -- 11/14/02: added this

          -- l_ship_method_code := null; -- commenting for ER# 4663790

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('case 2.2#2: l_ship_method_code      :'||l_ship_method_code);
          END IF;
          --DBMS_OUTPUT.PUT_line('case 2.2#2: l_ship_method_code      :'||l_ship_method_code);
        end if;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('Finally: l_ship_method_code      :'||l_ship_method_code);
        END IF;
        --DBMS_OUTPUT.PUT_line('Finally: l_ship_method_code      :'||l_ship_method_code);
        -- 2.3 populate the shipment record:
        if ((l_ship_method_code <> FND_API.G_MISS_char) and (l_ship_method_code is not null)) then
          px_hd_Shipment_TBL(1).shipment_id          := l_shipment_id;
          px_hd_Shipment_TBL(1).quote_header_id      := p_qte_header_rec.quote_header_id;
          px_hd_Shipment_TBL(1).operation_code       := l_opCode;
          px_hd_Shipment_TBL(1).SHIP_METHOD_CODE     := l_ship_method_code;
        end if;

     end if; -- if (l_isDone <> 'Y')

     -- End of API body.
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultShipMethod()');
     END IF;
     --IBE_Util.Disable_Debug;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getHdrDefaultShipMethod_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getHdrDefaultShipMethod_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO getHdrDefaultShipMethod_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
end getHdrDefaultShipMethod;

PROCEDURE getHdrDefaultPaymentMethod(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Payment_Tbl    IN OUT NOCOPY ASO_Quote_Pub.Payment_Tbl_Type
                              ,p_qte_header_rec     IN     ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,p_minisite_id        IN     Number
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              )

is

     l_api_name                  CONSTANT VARCHAR2(30)   := 'getHdrDefaultPaymentMethod';
     l_api_version               CONSTANT NUMBER         := 1.0;
     l_opCode                    varchar2(10)            := 'CREATE';

     l_isDone                    varchar2(1)             := 'N';

     l_payment_id                number                  := FND_API.G_MISS_NUM;
     l_payment_type_code         varchar2(30)            := null;
     lx_cc_assignment_id         NUMBER;

     l_isInvoice                 varchar2(1)             := 'N';
     l_isCash                    varchar2(1)             := 'N';
     l_isCheck                   varchar2(1)             := 'N';
     G_PERM_VIEW_PAY_BOOK       BOOLEAN;
     l_ret_credit_pref varchar2(5) :='Y';
     l_retain_cc varchar2(1) := 'Y';

     cursor c_check_payment_rec_exist(l_quote_header_id number)
     is
       select payment_id, PAYMENT_TYPE_CODE
         from ASO_payments
         where QUOTE_HEADER_ID = l_quote_header_id                 and
               quote_line_id is null;
     rec_payment_rec_exist              c_check_payment_rec_exist%rowtype;

     cursor c_check_CC_enabled(l_msite_id number)
     is
       SELECT msite_information1
         FROM ibe_msite_information a, fnd_lookup_values b
         WHERE a.msite_id                    = l_msite_id
           AND a.msite_information1          = b.lookup_code
           AND a.msite_information1          = 'CREDIT_CARD'
           AND b.LOOKUP_TYPE                 = 'IBE_PAYMENT_TYPE'
           AND b.ENABLED_FLAG                ='Y' AND (b.TAG='Y' or b.TAG is null)
           AND b.language                    = userenv('lang');
     rec_CC_enabled                     c_check_CC_enabled%rowtype;

     cursor c_get_next_payment_type(l_msite_id number)
     is
       SELECT msite_information1
         FROM ibe_msite_information a, fnd_lookup_values b
         WHERE a.msite_id                    = l_msite_id
           AND a.msite_information1          = b.lookup_code
           AND a.msite_information1          <> 'CREDIT_CARD'
           AND b.LOOKUP_TYPE                 = 'IBE_PAYMENT_TYPE'
           AND b.ENABLED_FLAG                ='Y' AND (b.TAG='Y' or b.TAG is null)
           AND b.language                    = userenv('lang');
     rec_next_payment_type              c_get_next_payment_type%rowtype;

begin

     -- Standard Start of API savepoint
     SAVEPOINT getHdrDefPmtMethod_pvt;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                        P_Api_Version_Number,
                                        L_API_NAME   ,
                                        G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Start   IBE_Quote_Save_pvt.getHdrDefaultPaymentMethod()');
     END IF;
     -- 1. for the merge cart cases, we have to check if there is a payment record associated w/ the cart:
     if ((p_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM) and (p_qte_header_rec.quote_header_id is not null)) then

        -- check to see if there is already a payment method
        open c_check_payment_rec_exist (p_qte_header_rec.quote_header_id);
        fetch c_check_payment_rec_exist into rec_payment_rec_exist;
        close c_check_payment_rec_exist;

        -- if there is already a payment method, we are done
        -- 2/6/03: per Bug 2780574, we will not update the payment record, we will only create
        /*
        if ((rec_payment_rec_exist.PAYMENT_TYPE_CODE <> FND_API.G_MISS_char) and (rec_payment_rec_exist.PAYMENT_TYPE_CODE is not null)) then
          l_isDone      := 'Y';

        -- if there is paymentId
        elsif ((rec_payment_rec_exist.payment_id <> FND_API.G_MISS_NUM) and (rec_payment_rec_exist.payment_id is not null)) then
          l_opCode      := 'UPDATE';
          l_payment_id := rec_payment_rec_exist.payment_id;
        end if;
        */

        if ((rec_payment_rec_exist.payment_id <> FND_API.G_MISS_NUM) and (rec_payment_rec_exist.payment_id is not null)) then
          l_isDone      := 'Y';
        end if;
     end if;    -- for merge cart cases

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_opCode     :'||l_opCode);
     END IF;
     --DBMS_OUTPUT.PUT_line('l_opCode     :'||l_opCode);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_payment_id :'||l_payment_id);
     END IF;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_isDone :'||l_isDone);
     END IF;
     --DBMS_OUTPUT.PUT_line('l_payment_id :'||l_payment_id);

     -- 2. if there isn't a record, continue
     if (l_isDone <> 'Y') then

        -- 2.1 Check to see if CC is enabled:
        open c_check_CC_enabled (p_minisite_id);
        fetch c_check_CC_enabled into rec_CC_enabled;
        close c_check_CC_enabled;

        -- 2.2 if CC is enabled then we call IBE_CUSTOMER_ACCOUNTS.get_default_credit_card_info to see if there is a default credit card
        if ((rec_CC_enabled.msite_information1 <> FND_API.G_MISS_char) and (rec_CC_enabled.msite_information1 is not null)) then

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('Before calling IBE_CUSTOMER_pvt.get_default_credit_card_info');
          END IF;
          --DBMS_OUTPUT.PUT_line('Before calling IBE_CUSTOMER_pvt.get_default_credit_card_info');
          /* CC consolidation    */

          l_ret_credit_pref  := NVL(FND_PROFILE.VALUE('IBE_RETAIN_CC_PREFS'),'Y');
          G_PERM_VIEW_PAY_BOOK      := IBE_UTIL.check_user_permission('IBE_USE_PAYMENT_BOOK');

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('l_ret_credit_pref:'||l_ret_credit_pref);

              IF(G_PERM_VIEW_PAY_BOOK) THEN
                Ibe_Util.debug(rpad('G_PERM_VIEW_PAY_BOOK',30)||':'||'TRUE');
              ELSE
                Ibe_Util.debug(rpad('G_PERM_VIEW_PAY_BOOK',30)||':'||'FALSE');
              END IF;
          END IF;

          if ( not G_PERM_VIEW_PAY_BOOK or (l_ret_credit_pref = 'N')) then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('padss is set: not querying cc pref : '||l_retain_cc);
              end if;
              l_retain_cc := 'N';
          end if;

          if (l_retain_cc = 'Y') then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_Util.Debug('padss is not set: querying cc pref');
              end if;

          	  IBE_CUSTOMER_pvt.get_default_credit_card_info(
                                                        p_api_version             => P_Api_Version_Number
                                                       ,p_init_msg_list           => p_Init_Msg_List
                                                       ,p_commit                  => p_Commit
                                                       ,p_cust_account_id         => p_qte_header_rec.cust_account_id
                                                       ,p_party_id                => p_qte_header_rec.party_id
                                                       ,p_mini_site_id            => p_minisite_id
                                                       ,x_return_status           => x_return_status
                                                       ,x_msg_count               => x_msg_count
                                                       ,x_msg_data                => x_msg_data
                                                       ,x_cc_assignment_id        => lx_cc_assignment_id
                                                       );
		 end if;

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('After calling IBE_CUSTOMER_pvt.get_default_credit_card_info');
          END IF;
          --DBMS_OUTPUT.PUT_line('After calling IBE_CUSTOMER_pvt.get_default_credit_card_info');
        end if;

        -- 2.3 if CC is not enabled or the call from 2.2 doesn't return a valid value,
        --      then we try to find the next enabled payment option in this order: invoice, cash, check
        --if ((lx_credit_card_num = FND_API.G_MISS_char) or (lx_credit_card_num is null)) then
        if ((lx_cc_assignment_id = FND_API.G_MISS_NUM) or (lx_cc_assignment_id is null)) then
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('lx_credit_card_num is null');
          END IF;
          --DBMS_OUTPUT.PUT_line('lx_credit_card_num is null');

          /* 10/8/02: for bug 2608853: we're not going to default non-CC payment methods
          for rec_next_payment_type in c_get_next_payment_type(p_minisite_id)  loop
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_Util.Debug('rec_next_payment_type.msite_information1='||rec_next_payment_type.msite_information1||'*');
            END IF;
            --DBMS_OUTPUT.PUT_line('rec_next_payment_type.msite_information1='||rec_next_payment_type.msite_information1||'*');
            if (rec_next_payment_type.msite_information1 = 'INVOICE') then
              l_isInvoice := 'Y';
              exit;
            elsif (rec_next_payment_type.msite_information1 = 'CASH') then
              l_isCash    := 'Y';
            elsif (rec_next_payment_type.msite_information1 = 'CHECK') then
              l_isCheck   := 'Y';
            end if;
            exit when c_get_next_payment_type%notfound;
          end loop;
          --close c_get_next_payment_type;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('l_isInvoice ='||l_isInvoice);
          END IF;
          --DBMS_OUTPUT.PUT_line('l_isInvoice ='||l_isInvoice);
          if (l_isInvoice  = 'Y') then
            l_payment_type_code := 'INVOICE';
          elsif (l_isCash  = 'Y') then
            l_payment_type_code := 'CASH';
          elsif (l_isCheck = 'Y') then
            -- 8/29/02: we can't default check because check # is required
            --l_payment_type_code := 'CHECK';
            l_payment_type_code := null;
          end if;
          */

        else
          l_payment_type_code   := 'CREDIT_CARD';
        end if;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_Util.Debug('l_payment_type_code ='||l_payment_type_code);
        END IF;
        --DBMS_OUTPUT.PUT_line('l_payment_type_code ='||l_payment_type_code);

        -- 2.4 populate the payment record:
	-- Bug 	11810302, scnagara, included check on p_qte_header_rec.invoice_to_party_site_id in the below if condition
        if ((l_payment_type_code <> FND_API.G_MISS_char) and (l_payment_type_code is not null) and (p_qte_header_rec.invoice_to_party_site_id  <> fnd_api.g_miss_num) and (p_qte_header_rec.invoice_to_party_site_id is not null)) then
          px_hd_Payment_Tbl(1).payment_id                   := l_payment_id;
          px_hd_Payment_Tbl(1).quote_header_id              := p_qte_header_rec.quote_header_id;
          px_hd_Payment_Tbl(1).operation_code               := l_opCode;
          -- px_hd_Payment_Tbl(1).quote_shipment_index      := 1;                    // not needed

          if (l_payment_type_code = 'INVOICE') then
            l_payment_type_code := null;
          end if;
          px_hd_Payment_Tbl(1).PAYMENT_TYPE_CODE            := l_payment_type_code;
          px_hd_Payment_Tbl(1).PAYMENT_TERM_ID              := fnd_profile.value('IBE_DEFAULT_PAYMENT_TERM_ID');

          /*CC consolidation*/
          if ((lx_cc_assignment_id <> FND_API.G_MISS_NUM) and (lx_cc_assignment_id is not null)) then
                      px_hd_Payment_Tbl(1).INSTR_ASSIGNMENT_ID           := lx_cc_assignment_id;
            px_hd_Payment_Tbl(1).PAYMENT_REF_NUMBER           := null;
            px_hd_Payment_Tbl(1).CREDIT_CARD_CODE             := null;
            px_hd_Payment_Tbl(1).CREDIT_CARD_HOLDER_NAME      := null;
            px_hd_Payment_Tbl(1).CREDIT_CARD_EXPIRATION_DATE  := null;
          else
            px_hd_Payment_Tbl(1).INSTR_ASSIGNMENT_ID          := null;
            px_hd_Payment_Tbl(1).PAYMENT_REF_NUMBER           := null;
            px_hd_Payment_Tbl(1).CREDIT_CARD_CODE             := null;
            px_hd_Payment_Tbl(1).CREDIT_CARD_HOLDER_NAME      := null;
            px_hd_Payment_Tbl(1).CREDIT_CARD_EXPIRATION_DATE  := null;
          end if;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_Util.Debug('done: populate the payment record');
          END IF;
          --DBMS_OUTPUT.PUT_line('done: populate the payment record');
        end if;

     end if; -- if (l_isDone <> 'Y')

     -- End of API body.
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultPaymentMethod()');
     END IF;
     --IBE_Util.Disable_Debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getHdrDefPmtMethod_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getHdrDefPmtMethod_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO getHdrDefPmtMethod_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
end getHdrDefaultPaymentMethod;

PROCEDURE getHdrDefaultTaxExemption(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,px_hd_Tax_Detail_Tbl IN OUT NOCOPY ASO_Quote_Pub.Tax_Detail_Tbl_Type
                              ,p_qte_header_rec     IN     ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              )

is

     l_api_name                  CONSTANT VARCHAR2(30)   := 'getHdrDefaultTaxExemption';
     l_api_version               CONSTANT NUMBER         := 1.0;
     l_opCode                    varchar2(10)            := 'CREATE';

     l_isDone                    varchar2(1)             := 'N';

     l_tax_detail_id             number                  := FND_API.G_MISS_NUM;
     l_payment_type_code         varchar2(30)            := null;

     cursor c_check_tax_rec_exist(l_quote_header_id number)
     is
       select tax_detail_id, tax_exempt_flag
         from ASO_TAX_DETAILS
         where QUOTE_HEADER_ID = l_quote_header_id                 and
               quote_line_id is null;
     rec_tax_rec_exist              c_check_tax_rec_exist%rowtype;

begin

     -- Standard Start of API savepoint
     SAVEPOINT getHdrDefTaxExmpt_pvt;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                        P_Api_Version_Number,
                                        L_API_NAME   ,
                                        G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Start   IBE_Quote_Save_pvt.getHdrDefaultTaxExemption()');
     END IF;

     -- 1. for the merge cart cases, we have to check if there is tax exemption flag in the tax record associated w/ the cart:
     if ((p_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM) and (p_qte_header_rec.quote_header_id is not null)) then

        -- check to see if there is already a tax exemption flag
        open c_check_tax_rec_exist (p_qte_header_rec.quote_header_id);
        fetch c_check_tax_rec_exist into rec_tax_rec_exist;
        close c_check_tax_rec_exist;

        -- if there is already a shipTo partySiteId, we are done
        if ((rec_tax_rec_exist.tax_exempt_flag <> FND_API.G_MISS_char) and (rec_tax_rec_exist.tax_exempt_flag is not null)) then
          l_isDone      := 'Y';

        -- if there is tax_detail_id
        elsif ((rec_tax_rec_exist.tax_detail_id <> FND_API.G_MISS_NUM) and (rec_tax_rec_exist.tax_detail_id is not null)) then
          l_opCode        := 'UPDATE';
          l_tax_detail_id := rec_tax_rec_exist.tax_detail_id;
        end if;
     end if;    -- for merge cart cases

     -- 2. if there isn't a record, continue
     if (l_isDone <> 'Y') then
        -- 2.1 populate the following fields:
        px_hd_Tax_Detail_Tbl(1).tax_detail_id            := l_tax_detail_id;
        px_hd_Tax_Detail_Tbl(1).quote_header_id          := p_qte_header_rec.quote_header_id;
        px_hd_Tax_Detail_Tbl(1).operation_code           := l_opCode;
        -- px_hd_Tax_Detail_Tbl(1).quote_shipment_index     := 1;       // no need
        px_hd_Tax_Detail_Tbl(1).tax_exempt_flag          := 'S';
     end if;

     -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultTaxExemption()');
     END IF;
     --IBE_Util.Disable_Debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getHdrDefTaxExmpt_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getHdrDefTaxExmpt_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO getHdrDefTaxExmpt_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

end getHdrDefaultTaxExemption;

PROCEDURE getHdrDefaultEndCustomer(
                               P_Api_Version_Number IN     NUMBER
                              ,p_Init_Msg_List      IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_Commit             IN     VARCHAR2   := FND_API.G_FALSE
                              ,p_hd_Shipment_TBL    IN     ASO_Quote_Pub.Shipment_tbl_Type
                              ,px_qte_header_rec    IN OUT NOCOPY ASO_Quote_Pub.Qte_Header_Rec_Type
                              ,X_Return_Status      OUT NOCOPY  VARCHAR2
                              ,X_Msg_Count          OUT NOCOPY  NUMBER
                              ,X_Msg_Data           OUT NOCOPY  VARCHAR2
                              )
is

     l_api_name                        CONSTANT VARCHAR2(30)   := 'getHdrDefaultEndCustomer';
     l_api_version                     CONSTANT NUMBER         := 1.0;
     l_isDone                          varchar2(1)             := 'N';

     cursor c_check_endTo_rec_exist(l_quote_header_id number)
     is
       select quote_header_id, end_customer_party_id, end_customer_cust_party_id, end_customer_party_site_id, end_customer_cust_account_id
         from ASO_quote_headers
         where QUOTE_HEADER_ID = l_quote_header_id;
     rec_endTo_rec_exist              c_check_endTo_rec_exist%rowtype;

     cursor c_get_shipTo_info(l_quote_header_id number)
     is
       select SHIP_TO_CUST_ACCOUNT_ID, ship_to_party_id, ship_to_party_site_id
         from aso_shipments
         where QUOTE_HEADER_ID = l_quote_header_id and
               quote_line_id is null;
     rec_shipTo_info                  c_get_shipTo_info%rowtype;

begin

     -- Standard Start of API savepoint
     SAVEPOINT getHdrDefaultEndCustomer_pvt;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                        P_Api_Version_Number,
                                        L_API_NAME   ,
                                        G_PKG_NAME )
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_Msg_Pub.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- API body
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('Begin   IBE_Quote_Save_pvt.getHdrDefaultEndCustomer()');
     END IF;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultEndCustomer: px_qte_header_rec.quote_header_id='||px_qte_header_rec.quote_header_id);
     END IF;

     if ((px_qte_header_rec.quote_header_id <> FND_API.G_MISS_NUM) and (px_qte_header_rec.quote_header_id is not null)) then

        -- check to see if there is already an endTo info
        open c_check_endTo_rec_exist (px_qte_header_rec.quote_header_id);
        fetch c_check_endTo_rec_exist into rec_endTo_rec_exist;
        close c_check_endTo_rec_exist;

        -- if there is no endTo info, then we shld try to default
        if ( ((rec_endTo_rec_exist.end_customer_PARTY_SITE_ID <> FND_API.G_MISS_NUM) and (rec_endTo_rec_exist.end_customer_PARTY_SITE_ID is not null)) or
             ((rec_endTo_rec_exist.end_customer_PARTY_SITE_ID <> FND_API.G_MISS_NUM) and (rec_endTo_rec_exist.end_customer_PARTY_SITE_ID is not null)) or
             ((rec_endTo_rec_exist.end_customer_cust_account_id  <> FND_API.G_MISS_NUM) and (rec_endTo_rec_exist.end_customer_PARTY_SITE_ID is not null)) ) then
           l_isDone := 'Y';
        end if; -- check to see if we shld try to default

     end if;    -- for merge cart cases

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('l_isDone        ='||l_isDone);
     END IF;


     if (l_isDone <> 'Y') then
        if (p_hd_Shipment_TBL.count <> 0) then
          px_qte_header_rec.end_customer_cust_account_id := p_hd_Shipment_TBL(1).SHIP_TO_CUST_ACCOUNT_ID;
          px_qte_header_rec.end_customer_party_id        := p_hd_Shipment_TBL(1).ship_to_party_id;
          px_qte_header_rec.end_customer_party_site_id   := p_hd_Shipment_TBL(1).ship_to_party_site_id;
        else
          -- get shipto info directly from db
          open c_get_shipTo_info (px_qte_header_rec.quote_header_id);
          fetch c_get_shipTo_info into rec_shipTo_info;
          close c_get_shipTo_info;

          px_qte_header_rec.end_customer_cust_account_id := rec_shipTo_info.SHIP_TO_CUST_ACCOUNT_ID;
          px_qte_header_rec.end_customer_party_id        := rec_shipTo_info.ship_to_party_id;
          px_qte_header_rec.end_customer_party_site_id   := rec_shipTo_info.ship_to_party_site_id;
        end if;
     end if; -- if (l_isDone <> 'Y')

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('getHdrDefaultEndCustomer: px_qte_header_rec.end_customer_cust_account_id ='||px_qte_header_rec.end_customer_cust_account_id);
        IBE_Util.Debug('getHdrDefaultEndCustomer: px_qte_header_rec.end_customer_party_id        ='||px_qte_header_rec.end_customer_party_id);
        IBE_Util.Debug('getHdrDefaultEndCustomer: px_qte_header_rec.end_customer_party_site_id   ='||px_qte_header_rec.end_customer_party_site_id);
     END IF;

     -- End of API body.
     -- Standard check of p_commit.
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultEndCustomer()');
     END IF;
     --IBE_Util.Disable_Debug;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO getHdrDefaultEndCustomer_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO getHdrDefaultEndCustomer_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      ROLLBACK TO getHdrDefaultEndCustomer_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);

end getHdrDefaultEndCustomer;
/* ------------------------------ Default API's: End -----------------*/

PROCEDURE Create_Contract_For_Quote(
              P_Api_Version_Number     IN  NUMBER   := OKC_API.G_MISS_NUM
             ,p_Init_Msg_List          IN  VARCHAR2 := OKC_API.G_FALSE
             ,p_quote_id               IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
             ,p_rel_type               IN  OKC_K_REL_OBJS.RTY_CODE%TYPE := OKC_API.G_MISS_CHAR
             ,p_terms_agreed_flag      IN  VARCHAR2 := OKC_API.G_FALSE
             ,p_trace_mode             IN  VARCHAR2 := OKC_API.G_FALSE
             ,p_party_id               IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_cust_account_id        IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_quote_retrieval_number IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_minisite_id            IN  NUMBER   := FND_API.G_MISS_NUM
             ,p_validate_user          IN  VARCHAR2 := FND_API.G_FALSE
             ,p_url                    IN  VARCHAR2 := FND_API.G_MISS_CHAR
             ,x_contract_id           OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
             ,x_contract_number       OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
             ,x_return_status          OUT NOCOPY VARCHAR2
             ,x_msg_count              OUT NOCOPY NUMBER
             ,x_msg_data               OUT NOCOPY VARCHAR2
             )
IS

   l_api_name                  CONSTANT VARCHAR2(30)   := 'Create_Contract_For_Quote';
   l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN

 -- Standard Start of API savepoint
SAVEPOINT    CREATECONTRACTFORQUOTE_pvt;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.DEBUG('REACHED CREATE_CONTRACT_FOR_QUOTE' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
END IF;


  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version,
                                        P_Api_Version_Number,
                                        l_api_name   ,
                                        G_PKG_NAME )
  THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_Init_Msg_List) THEN
        FND_Msg_Pub.initialize;
  END IF;
  --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body

  -- User Authentication
  IBE_Quote_Misc_pvt.validate_user_update(
              p_init_msg_list            => p_Init_Msg_List
             ,p_quote_header_id         => p_quote_id
             ,p_party_id                 => p_party_id
             ,p_cust_account_id          => p_cust_account_id
             ,p_quote_retrieval_number   => p_quote_retrieval_number
             ,p_validate_user            => p_validate_user
             ,x_return_status         => x_return_status
             ,x_msg_count         => x_msg_count
             ,x_msg_data         => x_msg_data
             );
 IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 --commented by makulkar for the bug 2572588.
/*
 OKC_OC_INT_PUB.create_k_from_quote(
        p_api_version        => P_Api_Version_Number
        ,p_init_msg_list      => p_Init_Msg_List
        ,p_quote_id           => p_quote_id
        ,p_rel_type           => p_rel_type
        ,p_terms_agreed_flag  => p_terms_agreed_flag
        ,p_trace_mode         => p_trace_mode
        ,x_return_status      => x_return_status
        ,x_msg_count          => x_msg_count
        ,x_msg_data           => x_msg_data
        ,x_contract_id        => x_contract_id
        ,x_contract_number    => x_contract_number
        );
*/
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('create contract, quote_id ='||p_quote_id);
        IBE_Util.Debug('create contract, rel_type ='||p_rel_type);
        IBE_Util.Debug('create contract, p_terms_agreed_flag ='||p_terms_agreed_flag);
     END IF;

     aso_core_contracts_pub.create_contract(
                          x_return_status    => x_return_status
                         ,x_msg_count        => x_msg_count
                         ,x_msg_data         => x_msg_data
                         ,x_contract_id      => x_contract_id
                         ,x_contract_number  => x_contract_number
                         ,p_api_version      => P_Api_Version_Number
                         ,p_init_msg_list    => p_Init_Msg_List
                         ,p_quote_id         => p_quote_id
                         ,p_rel_type         => p_rel_type
                         ,p_terms_agreed_flag  => p_terms_agreed_flag
                         );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('create contract, output contract_id ='||x_contract_id);
         IBE_Util.Debug('create contract, output contract_num ='||x_contract_number);
      END IF;
      /*Calling share_readonly to downgrade the access levels of  all recipients to 'R' status,
      this is done because recipients cannot update a cart after it becomes a quote*/
      IF(IBE_UTIL.G_DEBUGON = 'Y') THEN
        IBE_UTIL.DEBUG('Calling share_readonly to downgrade the access levels of  all recipients to R status');
      END IF;
      ibe_quote_saveshare_v2_pvt.share_readonly(
         p_quote_header_id  => p_quote_id          ,
         P_minisite_id      => p_minisite_id       ,
         p_api_version      => P_Api_Version_Number,
         p_url              => p_url               ,
         p_init_msg_list    => FND_API.G_FALSE     ,
         p_commit           => FND_API.G_FALSE     ,
         x_return_status    => x_return_status     ,
         x_msg_count        => x_msg_count         ,
         x_msg_data         => x_msg_data          );

        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      IF(IBE_UTIL.G_DEBUGON = 'Y') THEN
        IBE_UTIL.DEBUG('Done calling share_readonly');
        IBE_UTIL.DEBUG('Create_contract:Calling deactivate API');
      END IF;

      IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
          P_Quote_header_id  => p_quote_id          ,
          P_Party_id         => p_party_id          ,
          P_Cust_account_id  => p_cust_account_id   ,
          p_api_version      => P_Api_Version_Number,
          p_init_msg_list    => fnd_api.g_false     ,
          p_commit           => fnd_api.g_false     ,
          x_return_status    => x_return_status     ,
          x_msg_count        => x_msg_count         ,
          x_msg_data         => x_msg_data          );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
       IF(IBE_UTIL.G_DEBUGON = 'Y') THEN
          IBE_UTIL.DEBUG('Create_Contract:Deactivate owner cart after creating the contract:Done');
        END IF;



  -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.getHdrDefaultTaxExemption()');
     END IF;
     --IBE_Util.Disable_Debug;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATECONTRACTFORQUOTE_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATECONTRACTFORQUOTE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO CREATECONTRACTFORQUOTE_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END CREATE_CONTRACT_FOR_QUOTE;

-- Duplicate Cart feature for 11.5.11 MaithiliK

PROCEDURE DUPLICATE_CART (
          P_Api_Version           IN  NUMBER                     ,
          p_Init_Msg_List      IN  VARCHAR2:= FND_API.G_FALSE ,
          p_Commit             IN  VARCHAR2:= FND_API.G_FALSE ,
          x_return_status      OUT NOCOPY VARCHAR2            ,
          x_msg_count          OUT NOCOPY NUMBER              ,
          x_msg_data           OUT NOCOPY VARCHAR2            ,
          x_last_update_date   OUT NOCOPY Date                ,
          x_quote_header_id    OUT NOCOPY NUMBER              ,
          p_last_update_date   IN  Date                       ,
          p_quote_header_id    IN  NUMBER:= FND_API.G_MISS_NUM,
          p_party_id           IN  NUMBER:= FND_API.G_MISS_NUM,
          p_cust_account_id    IN  NUMBER:= FND_API.G_MISS_NUM,
          p_validate_user      IN  VARCHAR2:= FND_API.G_FALSE ,
          P_new_quote_name     IN  VARCHAR2                   ,
          p_retrieval_number   IN  NUMBER   := FND_API.G_MISS_NUM,
          p_minisite_id        IN  NUMBER ) is

  CURSOR  c_check_for_quote(c_quote_header_id NUMBER) IS
     SELECT count(*) is_published_quote
     FROM ASO_QUOTE_HEADERS_ALL
     WHERE quote_header_id = c_quote_header_id
       AND resource_id is not null
       AND publish_flag = 'Y';

  CURSOR c_is_shared_cart(c_quote_header_id NUMBER) IS
     select count(*) is_shared_cart
     from ibe_sh_quote_access
     where quote_header_id = c_quote_header_id;

  rec_is_shared_cart   c_is_shared_cart%rowtype;
  rec_check_for_quote  c_check_for_quote%rowtype;


  G_PKG_NAME           CONSTANT VARCHAR2(30) := 'IBE_Quote_Save_pvt';
  l_api_name           CONSTANT VARCHAR2(200) := 'Duplicate_cart';
  l_api_version        NUMBER   := 1.0;

  l_to_qte_header_rec         ASO_Quote_Pub.Qte_Header_Rec_Type
                        := ASO_Quote_Pub.G_MISS_Qte_Header_Rec;

  l_to_hd_shipment_tbl         ASO_Quote_Pub.shipment_tbl_type;

  l_to_qte_line_tbl            ASO_Quote_Pub.qte_line_tbl_type;
  l_to_line_rltship_tbl        ASO_Quote_Pub.Line_Rltship_tbl_Type;
  l_to_qte_line_dtl_tbl        ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type;
  l_to_line_attr_ext_tbl       ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type;
  l_to_ln_price_attributes_tbl ASO_Quote_Pub.Price_Attributes_Tbl_Type;

  -- added 12/22/03: PRG, no line merge
  l_Price_Adjustment_Tbl       ASO_Quote_Pub.Price_Adj_Tbl_Type;
  l_Price_Adj_Rltship_Tbl      ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

  CURSOR c_get_orig_quote_details(p_quote_header_id NUMBER) IS
    SELECT order_type_id,currency_code, price_list_id		-- bug 11805700,scnagara
	 FROM aso_quote_headers
	WHERE quote_header_id = p_quote_header_id;
  l_order_type_id              NUMBER;
  l_currency_code              VARCHAR2(10);
  l_price_list_id	       NUMBER;  -- bug 11805700,scnagara


  lx_quote_header_id    NUMBER;
  lx_quote_number       NUMBER;
  lx_return_status      VARCHAR2(1);
  lx_msg_count          NUMBER;
  lx_msg_data           VARCHAR2(2000);
  lx_last_update_date   DATE;

  l_exp_date_profile_value NUMBER := FND_API.G_MISS_NUM;
  l_controlled_copy     VARCHAR2(2) := FND_API.G_FALSE;
  l_copy_quote_header_rec       ASO_Copy_Quote_Pub.Copy_Quote_Header_Rec_Type
                       := ASO_Copy_Quote_Pub.G_MISS_Copy_Quote_Header_Rec;
  l_copy_quote_control_rec    ASO_Copy_Quote_Pub.Copy_Quote_Control_Rec_Type
                       := ASO_Copy_Quote_Pub.G_MISS_Copy_Quote_Control_Rec;
  l_quote_expiration_date DATE;

  l_control_rec      ASO_Quote_Pub.Control_Rec_Type;
  l_header_pricing_event VARCHAR2(30);
Begin

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('22829370 Start IBE_Quote_Save_pvt.DUPLICATE_CART()');
     IBE_UTIL.DEBUG('DUPLICATE_CART: Input values');
     IBE_UTIL.DEBUG('DUPLICATE_CART: p_last_update_date = '||p_last_update_date);
     IBE_UTIL.DEBUG('DUPLICATE_CART: p_party_id = '||p_party_id);
     IBE_UTIL.DEBUG('DUPLICATE_CART: p_cust_account_id = '||p_cust_account_id);
     IBE_UTIL.DEBUG('DUPLICATE_CART: p_validate_user = '||p_validate_user);
     IBE_UTIL.DEBUG('DUPLICATE_CART: P_new_quote_name = '||P_new_quote_name);
     IBE_UTIL.DEBUG('DUPLICATE_CART: p_retrieval_number = '||p_retrieval_number);
     IBE_UTIL.DEBUG('22829370 DUPLICATE_CART: p_minisite_id = '||p_minisite_id);
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT Duplicate_Cart;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                     p_api_version,
                                     L_API_NAME   ,
                                     G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_Msg_Pub.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --API Body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('DUPLICATE_CART: Before Calling log_environment_info');
   END IF;
   IBE_Quote_Misc_pvt.log_environment_info();
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('DUPLICATE_CART: After Calling log_environment_info');
      IBE_UTIL.DEBUG('DUPLICATE_CART: p_retrieval_number = '||p_retrieval_number);
      IBE_UTIL.DEBUG('DUPLICATE_CART: p_new_quote_name = '||p_new_quote_name);
   END IF;

  -- User Authentication
  IBE_Quote_Misc_pvt.Validate_User_Update
   (  p_init_msg_list   => p_Init_Msg_List
     ,p_quote_header_id => p_quote_header_id
     ,p_party_id        => p_party_id
     ,p_cust_account_id => p_cust_account_id
     ,p_validate_user   => p_validate_user
     ,p_quote_retrieval_number => p_retrieval_number
     ,p_save_type       => OP_DUPLICATE_CART
     ,p_last_update_date => p_last_update_date
     ,x_return_status   => lx_return_status
     ,x_msg_count       => lx_msg_count
     ,x_msg_data        => lx_msg_data
    );
   IF (lx_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --Check for Shared Cart and Published Quote separately. If the cart is a Shared Cart (Even if end dated record)
   --OR published quote then set the l_controlled_copy flag to TRUE.

   FOR rec_is_shared_cart in c_is_shared_cart(p_quote_header_id) LOOP
     IF (nvl(rec_is_shared_cart.is_shared_cart,0) > 0) THEN
       l_controlled_copy := FND_API.G_TRUE;
     END IF;
   END LOOP;

   FOR rec_check_for_quote in c_check_for_quote(p_quote_header_id) LOOP
     IF (nvl(rec_check_for_quote.is_published_quote,0) > 0) THEN
       l_controlled_copy := FND_API.G_TRUE;
     END IF;
   END LOOP;

   -- Get the expiration date from the Saved Cart expiration profile.
   l_exp_date_profile_value := FND_Profile.Value('IBE_EXP_SAVE_CART');
   l_quote_expiration_date := trunc(sysdate)+nvl(l_exp_date_profile_value,0);

   -- Get Header Pricing event from IBE profile as it is needed for both calls (iStore duplicate cart logic and ASO copy quote)
   l_header_pricing_event := FND_Profile.Value('IBE_INCART_PRICING_EVENT');

   -- If the cart is a shared cart or published quote, then copy only items and agreements and commitments if applicable
   -- Else call ASO copy_quote api to copy the entire cart.

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('DUPLICATE_CART: l_controlled_copy='||l_controlled_copy);
   END IF;

   IF (l_controlled_copy = FND_API.G_TRUE) THEN
     IBE_UTIL.DEBUG('l controlled copy is true, so calling istore apis for DUPLICATE');
       -- get order_type_id from the original quote header
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Getting order_type_id,currency code from original quote header ' || p_quote_header_id);
     END IF;

     OPEN c_get_orig_quote_details(p_quote_header_id);
     FETCH c_get_orig_quote_details INTO l_order_type_id,l_currency_code,l_price_list_id;  -- bug 11805700, scnagara
     IF l_order_type_id IS NOT NULL THEN
      l_to_qte_header_rec.order_type_id := l_order_type_id;
     END IF;
     IF l_currency_code IS NOT NULL THEN
       l_to_qte_header_rec.currency_code := l_currency_code;
     END IF;
     IF l_price_list_id IS NOT NULL THEN
       l_to_qte_header_rec.price_list_id := l_price_list_id;  -- bug 11805700, scnagara
     END IF;
     CLOSE c_get_orig_quote_details;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('order_type_id=' || l_order_type_id);
	IBE_Util.Debug('l_currency_code=' || l_currency_code);
	IBE_Util.Debug('l_price_list_id=' || l_price_list_id);
     END IF;

     --construct header rec with other information
     l_to_qte_header_rec.quote_name := p_new_quote_name;
     l_to_qte_header_rec.party_id := p_party_id;
     l_to_qte_header_rec.cust_account_id := p_cust_account_id;
     l_to_qte_header_rec.quote_source_code := 'IStore Account';
     l_to_qte_header_rec.quote_expiration_date := l_quote_expiration_date;

    -- get all line related information from original quote header id with p_mode = 'CONTROLLED_COPY'
     ibe_quote_saveshare_pvt.Copy_Lines
      (  p_api_version_number       => 1.0
        ,p_init_msg_list           => FND_API.G_FALSE
        ,p_commit                  => FND_API.G_FALSE
        ,x_Return_Status           => x_Return_Status
        ,x_Msg_Count               => x_Msg_Count
        ,x_Msg_Data                => x_Msg_Data
        ,p_from_quote_header_id    => p_quote_header_id
        ,p_to_quote_header_id      => l_to_qte_header_rec.quote_header_id
        ,p_mode                    => 'CONTROLLED_COPY'
        ,x_qte_line_tbl            => l_to_qte_line_tbl
        ,x_qte_line_dtl_tbl        => l_to_qte_line_dtl_tbl
        ,x_line_attr_ext_tbl       => l_to_line_attr_ext_tbl
        ,x_line_rltship_tbl        => l_to_line_rltship_tbl
        ,x_ln_price_attributes_tbl => l_to_ln_price_attributes_tbl
        ,x_Price_Adjustment_tbl    => l_Price_Adjustment_tbl
        ,x_Price_Adj_Rltship_tbl   => l_Price_Adj_Rltship_tbl
      );

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      l_to_hd_shipment_tbl(1).quote_header_id 	:= l_to_qte_header_rec.quote_header_id;

      -- Setup control record for pricing
      l_control_rec.pricing_request_type          := 'ASO';
      l_control_rec.header_pricing_event          := l_header_pricing_event;
      l_control_rec.line_pricing_event            :=  FND_API.G_MISS_CHAR;
      l_control_rec.calculate_freight_charge_flag := 'Y';
      l_control_rec.calculate_tax_flag            := 'Y';

      -- Call save api to create a quote.
      --Added p_minisite_id parameter - for bug 22829370
      IBE_Quote_Save_pvt.save(
       p_api_version_number        => 1.0
      ,p_init_msg_list            => FND_API.G_FALSE
      ,p_commit                   => FND_API.G_FALSE
      ,p_minisite_id              => p_minisite_id
      ,p_qte_header_rec           => l_to_qte_header_rec
      ,p_Qte_Line_Tbl             => l_to_qte_line_tbl
      ,p_Qte_Line_Dtl_Tbl         => l_to_Qte_Line_Dtl_Tbl
      ,p_Line_rltship_tbl         => l_to_Line_rltship_tbl
      ,p_save_type                => OP_DUPLICATE_CART
      ,p_control_rec              => l_control_rec
      ,p_hd_shipment_tbl          => l_to_hd_shipment_tbl
      ,x_quote_header_id          => lx_quote_header_id
      ,x_last_update_date         => lx_last_update_date
      ,x_return_status            => x_return_status
      ,x_msg_count                => x_msg_count
      ,x_msg_data                 => x_msg_data
      );
      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;




   ELSE
      -- Regular cart, call ASO Copy Quote api for Duplicating an entire quote.
      l_copy_quote_header_rec.quote_header_id := p_quote_header_id;
      l_copy_quote_header_rec.quote_name := p_new_quote_name;
      l_copy_quote_header_rec.quote_expiration_date := l_quote_expiration_date;
--      l_copy_quote_header_rec.pricing_status_indicator := 'I';
      l_copy_quote_control_rec.Pricing_Request_Type	         := 'ASO';
      l_copy_quote_control_rec.Header_Pricing_Event	         := l_header_pricing_event;
	  l_copy_quote_control_rec.Calculate_Freight_Charge_Flag := 'Y';
      l_copy_quote_control_rec.Calculate_Tax_Flag            := 'Y';
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('DUPLICATE_CART: Copy Quote Header Rec Values');
        IBE_UTIL.DEBUG('DUPLICATE_CART: quote_header_id = '||l_copy_quote_header_rec.quote_header_id);
        IBE_UTIL.DEBUG('DUPLICATE_CART: quote_name = '||l_copy_quote_header_rec.quote_name);
        IBE_UTIL.DEBUG('DUPLICATE_CART: quote_expiration_date = '||l_copy_quote_header_rec.quote_expiration_date);
        IBE_UTIL.DEBUG('DUPLICATE_CART: pricing_status_indicator = '||l_copy_quote_header_rec.pricing_status_indicator);
        IBE_UTIL.DEBUG('DUPLICATE_CART: Before calling ASO Copy Quote');
      END IF;

      ASO_Copy_Quote_Pub.Copy_Quote(
        p_api_Version_Number      => 1.0,
        p_init_msg_list           => FND_API.G_FALSE,
        p_commit                  => FND_API.G_FALSE,
        p_copy_quote_header_rec   => l_copy_quote_header_rec,
        p_copy_quote_control_rec  => l_copy_quote_control_rec,
        x_qte_header_id           => lx_quote_header_id,
        x_qte_number              => lx_quote_number,
        x_return_status           => lx_return_status,
        x_msg_count               => lx_msg_count,
        x_msg_data                => lx_msg_data);

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('DUPLICATE_CART: After ASO Copy Quote call, return status='||lx_return_status);
       IBE_UTIL.DEBUG('DUPLICATE_CART: After ASO Copy Quote call, new quote header id='||lx_quote_header_id);
     END IF;

     IF lx_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF lx_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;





   END IF;
   x_quote_header_id  := lx_quote_header_id;

  -- Standard call to get message count and if count is 1, get message info.
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('End   IBE_Quote_Save_pvt.Duplicate_cart');
     END IF;
     --IBE_Util.Disable_Debug;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Duplicate_Cart;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Duplicate_Cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Duplicate_Cart;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);


END DUPLICATE_CART;

-- API NAME:  RECONFIGURE_FROM_IB
PROCEDURE RECONFIGURE_FROM_IB(
   p_api_version_number      IN  NUMBER   := 1
   ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE
  ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
  ,p_Control_Rec              IN   ASO_QUOTE_PUB.Control_Rec_Type
                                     := ASO_QUOTE_PUB.G_Miss_Control_Rec
  ,p_Qte_Header_Rec           IN   ASO_QUOTE_PUB.Qte_Header_Rec_Type
                                     := ASO_QUOTE_PUB.G_MISS_Qte_Header_Rec
  ,p_instance_ids             IN   jtf_number_table       := NULL
  ,x_config_line              OUT NOCOPY ConfigCurTyp
  ,x_last_update_date         OUT NOCOPY DATE
  ,x_return_status            OUT NOCOPY VARCHAR2
  ,x_msg_count                OUT NOCOPY NUMBER
  ,x_msg_data                 OUT NOCOPY VARCHAR2
) IS
  L_API_VERSION CONSTANT NUMBER       := 1.0;
  l_api_name            CONSTANT VARCHAR2(200) := 'Reconfigure_From_Ib';
  lx_last_update_date   DATE;
  lx_quote_header_id    NUMBER;
  l_inst_table_size     NUMBER;
  l_Qte_Header_Rec    ASO_Quote_Pub.Qte_Header_Rec_Type;
  x_Qte_Header_Rec    ASO_Quote_Pub.Qte_Header_Rec_Type;
  l_control_rec ASO_Quote_Pub.Control_Rec_Type :=
                ASO_Quote_Pub.G_Miss_Control_Rec;
  l_instance_tbl ASO_QUOTE_HEADERS_PVT. Instance_Tbl_Type ;
  l_instance_rec  ASO_QUOTE_HEADERS_PVT.Instance_rec_Type ;

  l_refcursor_query VARCHAR2(1000) :=   'select aql.quote_header_id,
                                               aql.quote_line_id,
                                               aql.inventory_item_id,
                                               aql.organization_id,
	                                       aql.uom_code,
                                               aql.quantity,
	                                       aqld.config_header_id,
	                                       aqld.config_revision_num
                                        from aso_quote_lines_all aql,
                                             aso_quote_line_details AQLD
                                        where aqld.quote_line_id = aql.quote_line_id and
					      aqld.ref_line_id is null and
					      aql.quote_header_id = :1';

      l_table_size   PLS_INTEGER := 0;
	 l_csi_config_rec   CSI_CZ_INT.config_rec;
	 l_instance_locked boolean  := FALSE;

  lx_Qte_Header_Rec             ASO_Quote_Pub.Qte_Header_Rec_Type:=p_Qte_Header_Rec;
  lx_hd_Price_Attributes_Tbl    ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  lx_hd_Payment_Tbl             ASO_Quote_Pub.Payment_Tbl_Type;
  lx_hd_Shipment_TBL            ASO_Quote_Pub.Shipment_tbl_Type;
  lx_hd_Freight_Charge_Tbl      ASO_Quote_Pub.Freight_Charge_Tbl_Type;
  lx_hd_Tax_Detail_Tbl          ASO_Quote_Pub.Tax_Detail_Tbl_Type;
  lx_Price_Adjustment_Tbl       ASO_Quote_Pub.Price_Adj_Tbl_Type;
  lx_Price_Adj_Attr_Tbl         ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
  lx_Price_Adj_Rltship_Tbl      ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Reconfigure_From_Ib;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Begin Reconfigure_Form_IB');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                     P_Api_Version_Number,
                                     L_API_NAME   ,
                                     G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.To_Boolean(p_init_msg_list) THEN
    FND_Msg_Pub.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Call Check Instance Lock API
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('API CSI_CZ_INT.Check_Item_Instance_Lock() Starts');
   END IF;

   l_table_size                 := p_instance_ids.COUNT;
   FOR i IN 1..l_table_size LOOP
   l_csi_config_rec.instance_id := p_instance_ids(i);
   l_instance_locked := CSI_CZ_INT.Check_Item_Instance_Lock(
    p_init_msg_list           => p_init_msg_list
   ,p_config_rec              => l_csi_config_rec
   ,x_return_status           => x_return_status
   ,X_Msg_Count               => x_Msg_Count
   ,X_Msg_Data                => x_Msg_Data
   );
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	 IF(l_instance_locked = TRUE) THEN
       IBE_UTIL.debug('Instance Id '||p_instance_ids(i)||' islocked');
	 ELSE
       IBE_UTIL.debug('Instance Id '||p_instance_ids(i)||' isNotlocked');
	 END IF;
   END IF;
   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   IF (l_instance_locked = TRUE) THEN
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_UTIL.debug('Instance Id '||p_instance_ids(i)||' is locked');
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
    FND_MESSAGE.Set_Token('ERRNO', 'IB_INSTANCE_LOCKED');
    FND_MESSAGE.Set_Token('REASON','This instance is locked cannot reconfigure');
    FND_MSG_PUB.Add;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
   END IF;
   END LOOP;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('API CSI_CZ_INT.Check_Item_Instance_Lock() Ends::x_return_status'||x_return_status);
   END IF;
  --API Body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Call IBE_QUOTE_SAVE_PVT.Save()');
   END IF;

   IBE_UTIL.DEBUG('Before call to getHdrDefaultValues()');
   getHdrDefaultValues(
            P_Api_Version_Number          => p_api_version_number
           ,p_minisite_id                 => p_Qte_Header_Rec.minisite_id
           ,p_Qte_Header_Rec              => p_Qte_Header_Rec
           ,x_Qte_Header_Rec              => lx_Qte_Header_Rec
           ,x_hd_Price_Attributes_Tbl     => lx_hd_Price_Attributes_Tbl
           ,x_hd_Payment_Tbl              => lx_hd_Payment_Tbl
           ,x_hd_Shipment_TBL             => lx_hd_Shipment_TBL
           ,x_hd_Freight_Charge_Tbl       => lx_hd_Freight_Charge_Tbl
           ,x_hd_Tax_Detail_Tbl           => lx_hd_Tax_Detail_Tbl
           ,x_Price_Adjustment_Tbl        => lx_Price_Adjustment_Tbl
           ,x_Price_Adj_Attr_Tbl          => lx_Price_Adj_Attr_Tbl
           ,x_Price_Adj_Rltship_Tbl       => lx_Price_Adj_Rltship_Tbl
           ,x_last_update_date            => x_last_update_date
           ,X_Return_Status               => x_return_status
           ,X_Msg_Count                   => x_msg_count
           ,X_Msg_Data                    => x_msg_data
           );
   IBE_UTIL.DEBUG('After call to getHdrDefaultValues()');

   Save(
     P_Api_Version_Number      => p_api_version_number
    ,p_Init_Msg_List           => p_init_msg_list
    ,p_Commit                  => p_commit
    ,p_Control_Rec             => p_Control_Rec
    ,p_Qte_Header_Rec          => lx_Qte_Header_Rec
    ,p_hd_Price_Attributes_Tbl => lx_hd_Price_Attributes_Tbl
    ,p_hd_Payment_Tbl          => lx_hd_Payment_Tbl
    ,p_hd_Shipment_Tbl         => lx_hd_Shipment_TBL
    ,p_hd_Freight_Charge_Tbl   => lx_hd_Freight_Charge_Tbl
    ,p_hd_Tax_Detail_Tbl       => lx_hd_Tax_Detail_Tbl
    ,p_Price_Adjustment_Tbl    => lx_Price_Adjustment_Tbl
    ,p_Price_Adj_Attr_Tbl      => lx_Price_Adj_Attr_Tbl
    ,p_Price_Adj_Rltship_Tbl   => lx_Price_Adj_Rltship_Tbl
    ,x_quote_header_id         => lx_quote_header_id
    ,x_last_update_date        => lx_last_update_date
    ,X_Return_Status           => x_Return_Status
    ,X_Msg_Count               => x_Msg_Count
    ,X_Msg_Data                => x_Msg_Data
  );
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
 --Instantiate Quote_Header_Rec and InstanceTable
 l_Qte_Header_Rec.quote_header_id := lx_quote_header_id;
 l_Qte_Header_Rec.last_update_date := lx_last_update_date;


 l_inst_table_size := p_instance_ids.COUNT;
 FOR i IN 1..l_inst_table_size LOOP
  l_instance_rec.instance_id := p_instance_ids(i);
  l_instance_tbl(i)          := l_instance_rec;
 END LOOP;
 l_control_rec := p_control_rec;
 -- Call Config_Operations to copy the Config Details from CZ to ASO
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('API ASO_Config_Operations_Int.Config_Operations() Begin');
 END IF;
 ASO_CONFIG_OPERATIONS_INT.Config_Operations
 (
     P_Api_Version_Number     => p_api_version_number
     ,p_Init_Msg_List         => p_init_msg_list
     ,p_Commit                => p_commit
     ,P_Control_Rec  	     => l_control_rec
     ,P_Qte_Header_Rec        => l_Qte_Header_Rec
     ,P_instance_tbl          => l_instance_tbl
     ,p_operation_code        => ASO_QUOTE_PUB.G_RECONFIGURE
     ,X_Return_Status         => x_Return_Status
     ,X_Msg_Count             => x_Msg_Count
     ,X_Msg_Data              => x_Msg_Data
     ,x_Qte_Header_Rec        => x_Qte_Header_Rec
 );
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('API CSI_CZ_INT.Check_Item_Instance_Lock() Ends::x_return_status'||x_return_status);
 END IF;
 IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
 END IF;
 IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 END IF;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Ref cursor x_config_line begin');
 END IF;
 open x_config_line for l_refcursor_query using l_Qte_Header_Rec.quote_header_id;
  -- End of API body.
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

  -- Standard call to get message count and if count is 1, get message info.
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count    ,
                            p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End   IBE_Quote_Save_pvt.Reconfigure_from_ib() end');
  END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Reconfigure_From_Ib;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Reconfigure_From_Ib;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Reconfigure_From_Ib;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END RECONFIGURE_FROM_IB;

PROCEDURE ADD_CART_LEVEL_SERVICES(
    p_quote_header_id		IN	NUMBER,
   	p_organization_id       IN  NUMBER,
   	-- p_minisite_id           IN  NUMBER   := FND_API.G_MISS_NUM,
   	p_sva_line_id           IN  NUMBER,
   	p_sva_line_qty          IN  NUMBER,
    p_svc_item_id_tbl       IN 	JTF_NUMBER_TABLE,
    px_svc_period_tbl	    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_100,
    px_svc_duration_tbl	    IN OUT NOCOPY  JTF_NUMBER_TABLE,
    px_svc_uom_tbl  	    IN OUT NOCOPY  JTF_VARCHAR2_TABLE_100,

    px_quote_line_tbl       IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Tbl_Type,
    px_line_rec_index       IN OUT NOCOPY PLS_INTEGER,
    px_quote_line_dtl_tbl	IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type,
    px_dtl_rec_index        IN OUT NOCOPY PLS_INTEGER)
IS

  i						PLS_INTEGER := 1;
  l_idx     			PLS_INTEGER := 1;
  l_load_svc_detail		BOOLEAN := FALSE;


  CURSOR c_get_svc_detail(p_svc_item_id NUMBER, p_org_id NUMBER) IS
  	SELECT primary_uom_code, service_duration_period_code, service_duration
	FROM mtl_system_items
	WHERE inventory_item_id = p_svc_item_id and organization_id = p_org_id;

BEGIN

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('enter ADD_CART_LEVEL_SERVICES');
	END IF;

	IF px_svc_period_tbl IS NULL THEN
		px_svc_period_tbl := JTF_VARCHAR2_TABLE_100();
	   	px_svc_duration_tbl := JTF_NUMBER_TABLE();
	   	px_svc_uom_tbl := JTF_VARCHAR2_TABLE_100();
	   	l_load_svc_detail := TRUE;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('l_load_svc_detail is true');
		END IF;
	ELSE
	   	l_load_svc_detail := FALSE;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('l_load_svc_detail is false');
		END IF;
	END IF;

    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('loop through new svc items...');
	END IF;
	FOR i IN p_svc_item_id_tbl.FIRST..p_svc_item_id_tbl.LAST LOOP
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('i='||i||', l_idx='||l_idx);
		END IF;
		IF l_load_svc_detail THEN
			px_svc_period_tbl.EXTEND;
			px_svc_duration_tbl.EXTEND;
			px_svc_uom_tbl.EXTEND;
    		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	   		  IBE_UTIL.debug('fetch service duration, period, and  uom...');
	   		  IBE_UTIL.debug('p_svc_item_id_tbl('||i||')='||p_svc_item_id_tbl(i));
	   		  IBE_UTIL.debug('p_organization_id='||p_organization_id);
            END IF;
    	    OPEN c_get_svc_detail(p_svc_item_id_tbl(i),p_organization_id);
	    	FETCH c_get_svc_detail into px_svc_uom_tbl(l_idx),
                px_svc_period_tbl(l_idx),px_svc_duration_tbl(l_idx);
        	CLOSE c_get_svc_detail;
    		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	   		  IBE_UTIL.debug('fetch is completed:');
	   		  IBE_UTIL.debug('px_svc_uom_tbl('||l_idx||')='||px_svc_uom_tbl(l_idx));
	   		  IBE_UTIL.debug('px_svc_period_tbl('||l_idx||')='||px_svc_period_tbl(l_idx));
	   		  IBE_UTIL.debug('px_svc_duration_tbl('||l_idx||')='||px_svc_duration_tbl(l_idx));
            END IF;
		END IF;

        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	       	IBE_UTIL.debug('populate line rec, px_line_rec_index='||px_line_rec_index);
    	END IF;
		px_quote_line_tbl(px_line_rec_index).item_type_code := 'SRV';
		px_quote_line_tbl(px_line_rec_index).operation_code := 'CREATE';
		px_quote_line_tbl(px_line_rec_index).quote_header_id := p_quote_header_id;
		px_quote_line_tbl(px_line_rec_index).inventory_item_id := p_svc_item_id_tbl(i);
		px_quote_line_tbl(px_line_rec_index).organization_id := p_organization_id;
		px_quote_line_tbl(px_line_rec_index).start_date_active := sysdate;
		px_quote_line_tbl(px_line_rec_index).uom_code := px_svc_uom_tbl(l_idx);
		-- always a dummy quantity to avoid vilation failure.
		-- ASO will derive the correct service quantities from SVA line
		px_quote_line_tbl(px_line_rec_index).quantity := p_sva_line_qty;
		--px_quote_line_tbl(px_line_rec_index).minisite_id := p_minisite_id;

        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	       	IBE_UTIL.debug('populate line detail rec, px_dtl_rec_index='||px_dtl_rec_index);
    	END IF;
		px_quote_line_dtl_tbl(px_dtl_rec_index).operation_code := 'CREATE';
		px_quote_line_dtl_tbl(px_dtl_rec_index).service_ref_line_id := p_sva_line_id;
		px_quote_line_dtl_tbl(px_dtl_rec_index).qte_line_index := px_line_rec_index;
		px_quote_line_dtl_tbl(px_dtl_rec_index).service_ref_type_code := 'QUOTE';
		px_quote_line_dtl_tbl(px_dtl_rec_index).service_period := px_svc_period_tbl(l_idx);
		IF px_svc_duration_tbl(l_idx) IS NOT NULL THEN
			px_quote_line_dtl_tbl(px_dtl_rec_index).service_duration := px_svc_duration_tbl(l_idx);
		END IF;

        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	       	IBE_UTIL.debug('moving to next svc item ...');
    	END IF;
		px_line_rec_index := px_line_rec_index + 1;
		px_dtl_rec_index := px_dtl_rec_index + 1;
		l_idx := l_idx + 1;
	END LOOP;
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('exit ADD_CART_LEVEL_SERVICES with success');
	END IF;
END ADD_CART_LEVEL_SERVICES;

PROCEDURE UPDATE_SUPPORT_AND_QUANTITY(
	p_api_version        		IN  NUMBER,
    p_init_msg_list      		IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status      		OUT NOCOPY VARCHAR2,
    x_msg_count          		OUT NOCOPY NUMBER,
    x_msg_data           		OUT NOCOPY VARCHAR2,

    p_quote_header_id			IN	NUMBER,
    p_quote_line_id_tbl			IN	JTF_NUMBER_TABLE := NULL,
    p_line_quantity_tbl			IN 	JTF_NUMBER_TABLE := NULL,
    p_new_service_id_tbl		IN 	JTF_NUMBER_TABLE := NULL,
   	p_organization_id           IN  NUMBER   := FND_API.G_MISS_NUM,

    p_party_id                  IN  NUMBER   := FND_API.G_MISS_NUM,
    p_cust_account_id           IN  NUMBER   := FND_API.G_MISS_NUM,
    p_sharee_number             IN  NUMBER   := FND_API.G_MISS_NUM,

   	p_minisite_id               IN  NUMBER   := FND_API.G_MISS_NUM,
   	p_price_list_id             IN  NUMBER   := FND_API.G_MISS_NUM,
   	p_currency_code             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
	p_header_pricing_event      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   	p_save_type                 IN  NUMBER   := FND_API.G_MISS_NUM,
    p_last_update_date			IN 	DATE	:= FND_API.G_MISS_DATE,
    x_last_update_date			IN OUT	NOCOPY DATE
)
IS
  l_api_name	      	CONSTANT VARCHAR2(30) := 'UPDATE_SUPPORT_AND_QUANTITY';
  l_api_version	      	CONSTANT NUMBER		:= 1.0;

  l_sharee_party_id           	NUMBER   := FND_API.G_MISS_NUM;
  l_sharee_cust_account_id    	NUMBER   := FND_API.G_MISS_NUM;

  l_quote_line_id_tbl			JTF_NUMBER_TABLE := p_quote_line_id_tbl;
  l_line_quantity_tbl			JTF_NUMBER_TABLE := p_line_quantity_tbl;
  l_new_service_id_tbl			JTF_NUMBER_TABLE := p_new_service_id_tbl;
  l_new_service_period_tbl		JTF_VARCHAR2_TABLE_100 := NULL;
  l_new_service_duration_tbl	JTF_NUMBER_TABLE := NULL;
  l_new_service_uom_tbl			JTF_VARCHAR2_TABLE_100 := NULL;

  l_sva_line_size			PLS_INTEGER := 0;
  l_curr_sva_line_id		NUMBER := NULL;
  l_curr_line_qty			NUMBER := NULL;

  l_quote_header_id			NUMBER := NULL;
  l_line_rec_size		PLS_INTEGER := 0;
  l_line_qty_size		PLS_INTEGER := 0;
  l_new_service_size	PLS_INTEGER := 0;
  l_line_rec_index      PLS_INTEGER	:= 1;
  l_dtl_rec_index       PLS_INTEGER	:= 1;
  i						PLS_INTEGER := 1;

  l_map_index 			PLS_INTEGER := 1;
  l_deleted_svc_map_tbl	JTF_VARCHAR2_TABLE_100 := NULL;

  l_control_rec         ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_Miss_Control_Rec;
  l_quote_header_rec    ASO_Quote_Pub.Qte_Header_Rec_Type := ASO_Quote_Pub.G_MISS_Qte_Header_Rec;
  l_quote_Line_Tbl		ASO_Quote_Pub.Qte_Line_Tbl_Type := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL;
  l_quote_Line_Dtl_Tbl	ASO_Quote_Pub.Qte_Line_dtl_Tbl_Type := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL;

  CURSOR c_get_svc_lines(p_quote_header_id NUMBER) IS
	SELECT AQL.quote_line_id,ALD.service_ref_line_id,AQL.inventory_item_id
	FROM aso_quote_lines_all AQL, aso_quote_line_details ALD
	WHERE AQL.quote_header_id = p_quote_header_id and AQL.quote_line_id=ALD.quote_line_id
		and AQL.item_type_code='SRV'
	ORDER BY ALD.service_ref_line_id,AQL.inventory_item_id;

  CURSOR c_get_sva_lines(p_quote_header_id NUMBER) IS
  	SELECT quote_line_id, quantity FROM aso_quote_lines_all
  	WHERE quote_header_id = p_quote_header_id and ITEM_TYPE_CODE='SVA'
  	ORDER BY quote_line_id;

  CURSOR c_get_line_qty(p_quote_line_id NUMBER) IS
  	SELECT quantity FROM aso_quote_lines_all
  	WHERE quote_line_id = p_quote_line_id;
BEGIN
  	-- Standard Start of API savepoint
  	SAVEPOINT UPDATE_SUPPORT_LEVEL_AND_QTY;

	-- Standard initialization tasks
	-- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean(p_init_msg_list) THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to success.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Print debugging info.
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||' Begin');
		IBE_UTIL.debug('p_quote_header_id = ' || p_quote_header_id);
	END IF;

	IF p_quote_line_id_tbl IS NOT NULL THEN
		l_line_rec_size := p_quote_line_id_tbl.count;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('p_quote_line_id_tbl.count= ' ||l_line_rec_size);
		END IF;
	END IF;

	IF p_line_quantity_tbl IS NOT NULL THEN
		l_line_qty_size := p_line_quantity_tbl.count;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('p_line_quantity_tbl.count= ' || l_line_qty_size);
		END IF;
	END IF;

	IF p_new_service_id_tbl IS NOT NULL THEN
		l_new_service_size := p_new_service_id_tbl.count;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('p_new_service_id_tbl.count= ' || l_new_service_size);
		END IF;
	END IF;

	-- validating input parameters
	IF p_quote_header_id IS NULL THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Invalid input parameters, quote header id is null');
		END IF;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
	     	FND_MESSAGE.Set_Token('ERRNO', 'IBE_ST_INVALID_OPERATION');
     	    FND_MESSAGE.Set_Token('REASON', 'quote header id is null');
     	    FND_MSG_PUB.Add;
	    IF	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	    END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	IF l_line_qty_size>0 AND l_line_qty_size = l_line_rec_size THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Need to update quantity');
		END IF;
	ELSIF l_line_qty_size=0 THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('No need to update quantity');
		END IF;
	ELSE
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Invalid input parameters, size of line records does not match size of line quantities');
		END IF;
	    x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     	    FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
	     	FND_MESSAGE.Set_Token('ERRNO', 'IBE_ST_INVALID_OPERATION');
     	    FND_MESSAGE.Set_Token('REASON', 'size of line records does not match size of line quantities');
     	    FND_MSG_PUB.Add;
	    IF	FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
	    END IF;
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	-- update quantities
	IF l_line_qty_size>0 THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('updating quantities, l_line_rec_index='||l_line_rec_index);
		END IF;
		FOR l_line_rec_index IN 1..l_line_qty_size LOOP
			l_quote_line_tbl(l_line_rec_index).quote_header_id := p_quote_header_id;
			l_quote_line_tbl(l_line_rec_index).quote_line_id := p_quote_line_id_tbl(l_line_rec_index);
			l_quote_line_tbl(l_line_rec_index).quantity := p_line_quantity_tbl(l_line_rec_index);
			l_quote_line_tbl(l_line_rec_index).operation_code := 'UPDATE';
    		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    			IBE_UTIL.debug('l_line_rec_index='||l_line_rec_index);
	   	       	IBE_UTIL.debug('quote_line_id='||l_quote_line_tbl(l_line_rec_index).quote_line_id);
	   	       	IBE_UTIL.debug('quantity='||l_quote_line_tbl(l_line_rec_index).quantity);
	       	END IF;
		END LOOP;
		l_line_rec_index := l_line_rec_index + 1;
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('quantities updated, l_line_rec_index='||l_line_rec_index);
		END IF;
	ELSIF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('no quantity updated, l_line_rec_index='||l_line_rec_index);
	END IF;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('updating cart level support...');
		IBE_UTIL.debug('checking existing cart level services...');
	END IF;

	FOR rec_svc_line IN c_get_svc_lines(p_quote_header_id) LOOP
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('found service line:');
			IBE_UTIL.debug('service_ref_line_id='||rec_svc_line.service_ref_line_id);
			IBE_UTIL.debug('quote_line_id='||rec_svc_line.quote_line_id);
			IBE_UTIL.debug('l_curr_sva_line_id='||l_curr_sva_line_id);
		END IF;
		IF l_curr_sva_line_id IS NULL OR l_curr_sva_line_id <> rec_svc_line.service_ref_line_id THEN
			-- start a new sva line
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('starts a new SVA line, l_curr_sva_line_id='||l_curr_sva_line_id);
			END IF;

			IF l_curr_sva_line_id IS NOT NULL AND l_new_service_id_tbl IS NOT NULL THEN
				-- not the first sva line, add new services to previous SVA line first
				IF l_new_service_id_tbl.COUNT >0 THEN
					IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
						IBE_UTIL.debug('not the first sva line');
							IBE_UTIL.debug('adding new services to previous SVA line...:');
							IBE_UTIL.debug('l_line_rec_index='||l_line_rec_index);
							IBE_UTIL.debug('l_dtl_rec_index='||l_dtl_rec_index);
					END IF;
					ADD_CART_LEVEL_SERVICES(
						p_quote_header_id		=>p_quote_header_id,
						p_organization_id		=>p_organization_id,
						-- p_minisite_id		=>p_minisite_id,
						p_sva_line_id			=>l_curr_sva_line_id,
						p_sva_line_qty			=>l_curr_line_qty,
						p_svc_item_id_tbl		=>l_new_service_id_tbl,
						px_svc_period_tbl		=>l_new_service_period_tbl,
						px_svc_duration_tbl		=>l_new_service_duration_tbl,
						px_svc_uom_tbl			=>l_new_service_uom_tbl,
						px_quote_line_tbl		=>l_quote_line_tbl,
						px_line_rec_index		=>l_line_rec_index,
						px_quote_line_dtl_tbl	=>l_quote_line_dtl_tbl,
						px_dtl_rec_index		=>l_dtl_rec_index);
						IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
							IBE_UTIL.debug('new services added:');
							IBE_UTIL.debug('l_line_rec_index='||l_line_rec_index);
							IBE_UTIL.debug('l_dtl_rec_index='||l_dtl_rec_index);
						END IF;
				ELSIF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
					IBE_UTIL.debug('no new service need to be added.');
				END IF;
			END IF;

			-- move to the new line
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('initializing the new SVA line...');
			END IF;
			l_curr_sva_line_id := rec_svc_line.service_ref_line_id;
			l_sva_line_size := l_sva_line_size + 1;
			l_map_index := 1;

			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('l_sva_line_size='||l_sva_line_size);
				IBE_UTIL.debug('checking if need to update quantity...');
			END IF;
			l_curr_line_qty := NULL;
			IF l_quote_line_id_tbl IS NOT NULL AND l_line_quantity_tbl IS NOT NULL THEN
				i := l_quote_line_id_tbl.FIRST;
				WHILE i <= l_quote_line_id_tbl.LAST LOOP
					IF l_quote_line_id_tbl(i) = l_curr_sva_line_id THEN
						l_curr_line_qty := p_line_quantity_tbl(i);
						l_quote_line_id_tbl.DELETE(i);
						l_line_quantity_tbl.DELETE(i);
						IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
							IBE_UTIL.debug('a new quantity is entered, l_curr_line_qty='||l_curr_line_qty);
						END IF;
						EXIT;
					ELSE
						i := l_quote_line_id_tbl.NEXT(i);
					END IF;
				END LOOP;
			END IF;
			IF l_curr_line_qty IS NULL THEN
				IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
					IBE_UTIL.debug('no quantity entered, loading from db...');
				END IF;
        		OPEN c_get_line_qty(l_curr_sva_line_id);
        		FETCH c_get_line_qty into l_curr_line_qty;
        		CLOSE c_get_line_qty;
				IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
					IBE_UTIL.debug('quantity loaded, l_curr_line_qty='||l_curr_line_qty);
				END IF;
			END IF;
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('new SVA line initialized, l_sva_line_size='||l_sva_line_size);
			END IF;
		ELSE
			l_map_index := l_map_index + 1;
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('remains in the same SVA line');
			END IF;
		END IF;

		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('ready to processe current svc line, l_line_rec_index='||l_line_rec_index);
			IBE_UTIL.debug('l_line_rec_index='||l_line_rec_index ||', l_dtl_rec_index='||l_dtl_rec_index);
			IBE_UTIL.debug('l_map_index='||l_map_index);
		END IF;

		IF l_sva_line_size = 1 THEN
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('The first SVA line detected');
			END IF;
			IF l_deleted_svc_map_tbl IS NULL THEN
			l_deleted_svc_map_tbl := JTF_VARCHAR2_TABLE_100();
			END IF;
			l_deleted_svc_map_tbl.EXTEND;
			l_deleted_svc_map_tbl(l_map_index) := 'DELETE';
			IF l_new_service_id_tbl IS NOT NULL AND l_new_service_id_tbl.count >0 THEN
				IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
					IBE_UTIL.debug('populating l_deleted_svc_map_tbl table,l_map_index='||l_map_index);
				END IF;
				i := l_new_service_id_tbl.FIRST;
				WHILE i <= l_new_service_id_tbl.LAST LOOP
					IF rec_svc_line.inventory_item_id = l_new_service_id_tbl(i) THEN
						l_deleted_svc_map_tbl(l_map_index) := 'KEEP'; -- keep the svc item
						IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
							IBE_UTIL.debug('skipping svc line, inventory_item_id='||rec_svc_line.inventory_item_id);
						END IF;
						l_new_service_id_tbl.DELETE(i);
						EXIT;
					ELSE
						i := l_new_service_id_tbl.NEXT(i);
					END IF;
				END LOOP;
				IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
					IBE_UTIL.debug('l_deleted_svc_map_tbl('||l_map_index||')='||l_deleted_svc_map_tbl(l_map_index));
				END IF;
			END IF;
		END IF;

		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('applying l_deleted_svc_map_tbl table, service item='||rec_svc_line.inventory_item_id);
			IBE_UTIL.debug('l_map_index='||l_map_index||', opcode='||l_deleted_svc_map_tbl(l_map_index));
		END IF;
		IF l_deleted_svc_map_tbl(l_map_index) = 'DELETE' THEN
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('deleting svc line, inventory_item_id='||rec_svc_line.inventory_item_id);
			END IF;
			l_quote_line_tbl(l_line_rec_index).operation_code := 'DELETE';
			l_quote_line_tbl(l_line_rec_index).quote_line_id := rec_svc_line.quote_line_id;
			l_quote_line_tbl(l_line_rec_index).quote_header_id := p_quote_header_id;
			l_line_rec_index := l_line_rec_index + 1;
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('svc line deleted, l_line_rec_index='||l_line_rec_index);
			END IF;
		ELSIF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('svc line skipped (no change)');
		END IF;
	EXIT WHEN c_get_svc_lines%NOTFOUND;
	END LOOP;

	IF l_sva_line_size > 0 AND l_new_service_id_tbl IS NOT NULL THEN
		-- add new services the last line if exist
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('the last SVA line detected,l_sva_line_size='||l_sva_line_size);
		END IF;
		IF l_new_service_id_tbl.COUNT >0 THEN
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('adding new services the last SVA line,l_new_service_id_tbl.COUNT='||l_new_service_id_tbl.COUNT);
			END IF;
			ADD_CART_LEVEL_SERVICES(
						p_quote_header_id		=>p_quote_header_id,
						p_organization_id		=>p_organization_id,
						-- p_minisite_id		=>p_minisite_id,
						p_sva_line_id			=>l_curr_sva_line_id,
						p_sva_line_qty			=>l_curr_line_qty,
						p_svc_item_id_tbl		=>l_new_service_id_tbl,
						px_svc_period_tbl		=>l_new_service_period_tbl,
						px_svc_duration_tbl		=>l_new_service_duration_tbl,
						px_svc_uom_tbl			=>l_new_service_uom_tbl,
						px_quote_line_tbl		=>l_quote_line_tbl,
						px_line_rec_index		=>l_line_rec_index,
						px_quote_line_dtl_tbl	=>l_quote_line_dtl_tbl,
						px_dtl_rec_index		=>l_dtl_rec_index);
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('new services added to the last SVA line,l_line_rec_index='||l_line_rec_index);
				IBE_UTIL.debug('l_dtl_rec_index='||l_dtl_rec_index);
			END IF;
		ELSIF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('no new service need to be added to the last SVA line.');
		END IF;
	ELSIF l_new_service_id_tbl IS NOT NULL AND l_new_service_id_tbl.COUNT >0 THEN
		-- no previous cart level services found,retrieve sva lines
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('Current support level is NONE, directly adding new services...');
			IBE_UTIL.debug('Retrieving SVA lines, l_new_service_id_tbl.COUNT'||l_new_service_id_tbl.COUNT);
		END IF;
		FOR rec_sva_line IN c_get_sva_lines(p_quote_header_id) LOOP
			l_curr_sva_line_id := rec_sva_line.quote_line_id;
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('found SVA line, l_curr_sva_line_id='||l_curr_sva_line_id);
				IBE_UTIL.debug('checking quantity...');
			END IF;
			l_curr_line_qty := NULL;
			IF l_quote_line_id_tbl IS NOT NULL AND p_line_quantity_tbl IS NOT NULL THEN
				i := l_quote_line_id_tbl.FIRST;
				WHILE i <= l_quote_line_id_tbl.LAST LOOP
					IF l_quote_line_id_tbl(i) = l_curr_sva_line_id THEN
						l_curr_line_qty := p_line_quantity_tbl(i);
						l_quote_line_id_tbl.DELETE(i);
						l_line_quantity_tbl.DELETE(i);
						IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
							IBE_UTIL.debug('a new quantity is entered, l_curr_line_qty='||l_curr_line_qty);
						END IF;
						EXIT;
					ELSE
						i := l_quote_line_id_tbl.NEXT(i);
					END IF;
				END LOOP;
			END IF;
			IF l_curr_line_qty IS NULL THEN
				l_curr_line_qty := rec_sva_line.quantity;
				IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
					IBE_UTIL.debug('no quantity entered, default from db: '||l_curr_line_qty);
				END IF;
			END IF;

			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('before adding new services, l_curr_sva_line_id='||l_curr_sva_line_id);
				IBE_UTIL.debug('l_line_rec_index='||l_line_rec_index);
				IBE_UTIL.debug('l_dtl_rec_index='||l_dtl_rec_index);
			END IF;
			ADD_CART_LEVEL_SERVICES(
						p_quote_header_id		=>p_quote_header_id,
						p_organization_id		=>p_organization_id,
						-- p_minisite_id		=>p_minisite_id,
						p_sva_line_id			=>l_curr_sva_line_id,
						p_sva_line_qty			=>l_curr_line_qty,
						p_svc_item_id_tbl		=>l_new_service_id_tbl,
						px_svc_period_tbl		=>l_new_service_period_tbl,
						px_svc_duration_tbl		=>l_new_service_duration_tbl,
						px_svc_uom_tbl			=>l_new_service_uom_tbl,
						px_quote_line_tbl		=>l_quote_line_tbl,
						px_line_rec_index		=>l_line_rec_index,
						px_quote_line_dtl_tbl	=>l_quote_line_dtl_tbl,
						px_dtl_rec_index		=>l_dtl_rec_index);
			IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
				IBE_UTIL.debug('new services added:');
				IBE_UTIL.debug('l_line_rec_index='||l_line_rec_index);
				IBE_UTIL.debug('l_dtl_rec_index='||l_dtl_rec_index);
			END IF;
		EXIT WHEN c_get_sva_lines%NOTFOUND;
		END LOOP;
	END IF;

	IF l_quote_line_tbl IS NULL OR l_quote_line_tbl.count=0 THEN
		IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
			IBE_UTIL.debug('nothing to update, returning...');
		END IF;
		RETURN;
	END IF;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('setup control record...');
	END IF;
	l_control_rec.pricing_request_type := 'ASO';
	l_control_rec.header_pricing_event := p_header_pricing_event;
	l_control_rec.calculate_tax_flag := 'Y';
	l_control_rec.calculate_freight_charge_flag := 'Y';

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('header_pricing_event='||p_header_pricing_event);
		IBE_UTIL.debug('setup header record...');
	END IF;
	l_quote_header_rec.pricing_status_indicator := 'C';
	l_quote_header_rec.tax_status_indicator := 'C';
	l_quote_header_rec.quote_header_id := p_quote_header_id;
	l_quote_header_rec.currency_code := p_currency_code;
	l_quote_header_rec.price_list_id := p_price_list_id;

	IF (FND_Profile.Value('IBE_PRICE_CHANGED_LINES') = 'Y') THEN  -- bug 10638145, scnagara
		l_control_rec.price_mode := 'CHANGE_LINE';
		l_quote_header_rec.PRICING_STATUS_INDICATOR := 'I';
		l_quote_header_rec.TAX_STATUS_INDICATOR := 'I';
	ELSE
		l_control_rec.price_mode := 'ENTIRE_QUOTE';
		l_quote_header_rec.PRICING_STATUS_INDICATOR := 'C';
		l_quote_header_rec.TAX_STATUS_INDICATOR := 'C';
	END IF;

	IF p_sharee_number IS NULL THEN
		l_quote_header_rec.cust_account_id := p_cust_account_id;
		l_quote_header_rec.party_id := p_party_id;
	ELSE
		l_sharee_party_id := p_party_id;
		l_sharee_cust_account_id := p_cust_account_id;
	END IF;
	l_quote_header_rec.last_update_date := p_last_update_date;

	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('quote_header_id='||p_quote_header_id);
		IBE_UTIL.debug('currency_code='||p_currency_code);
		IBE_UTIL.debug('price_list_id='||p_price_list_id);
		IBE_UTIL.debug('p_sharee_number='||p_sharee_number);
		IBE_UTIL.debug('cust_account_id='||p_cust_account_id);
		IBE_UTIL.debug('party_id='||p_party_id);
		IBE_UTIL.debug('l_sharee_party_id='||l_sharee_party_id);
		IBE_UTIL.debug('l_sharee_cust_account_id='||l_sharee_cust_account_id);

		IBE_UTIL.debug('call IBE_QUOTE_SAVE_PVT.SAVE...');
		IBE_UTIL.debug('p_minisite_id='||p_minisite_id);
		IBE_UTIL.debug('p_save_type='||p_save_type);
	END IF;
	SAVE(p_api_version_number       => p_api_version
    	,p_init_msg_list            => FND_API.G_FALSE
    	,p_commit                   => FND_API.G_FALSE
    	,p_auto_update_active_quote => FND_API.G_FALSE
    	,p_combinesameitem          => 1

    	,p_sharee_number            => p_sharee_number
    	,p_sharee_party_id          => l_sharee_party_id
    	,p_sharee_cust_account_id   => l_sharee_cust_account_id

    	,p_minisite_id              => p_minisite_id
    	,p_control_rec              => l_control_rec
    	,p_qte_header_rec           => l_quote_header_rec
    	,p_qte_line_tbl             => l_quote_line_tbl
    	,p_qte_line_dtl_tbl         => l_quote_line_dtl_tbl
	    ,p_save_type                => p_save_type
	    ,x_quote_header_id          => l_quote_header_id
	    ,x_last_update_date         => x_last_update_date
	    ,x_return_status            => x_return_status
    	,x_msg_count                => x_msg_count
	    ,x_msg_data                 => x_msg_data);
	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
		IBE_UTIL.debug('returned from IBE_QUOTE_SAVE_PVT.SAVE');
		IBE_UTIL.debug('l_quote_header_id='||l_quote_header_id);
		IBE_UTIL.debug('x_last_update_date='||x_last_update_date);
		IBE_UTIL.debug('x_return_status='||x_return_status);
		IBE_UTIL.debug('x_msg_count='||x_msg_count);
		IBE_UTIL.debug('x_msg_data='||x_msg_data);
		IBE_UTIL.debug(G_PKG_NAME||'.'||l_api_name||' End');
	END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_SUPPORT_LEVEL_AND_QTY;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_SUPPORT_LEVEL_AND_QTY;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_SUPPORT_LEVEL_AND_QTY;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END UPDATE_SUPPORT_AND_QUANTITY;

END ibe_quote_save_pvt;

/
