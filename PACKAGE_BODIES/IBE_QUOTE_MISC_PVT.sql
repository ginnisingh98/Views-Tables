--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_MISC_PVT" AS
/* $Header: IBEVQMIB.pls 120.15.12010000.6 2013/11/20 11:27:07 kdosapat ship $ */


l_true VARCHAR2(1) := FND_API.G_TRUE;

FUNCTION get_multi_svc_profile return varchar2 is
BEGIN
   IF(FND_PROFILE.Value('IBE_ENABLE_MULT_SVC') = 'Y') THEN
     return FND_API.G_TRUE;
   ELSE
     return FND_API.G_FALSE;
   END IF;
END;

FUNCTION is_quote_usable(
         p_quote_header_id  IN NUMBER,
         p_party_id         IN NUMBER,
         p_cust_account_id  IN NUMBER) return varchar2 is
CURSOR c_get_quote_details(c_quote_header_id NUMBER) is
  select quote_expiration_date
  from aso_quote_headers_all
  where quote_header_id = c_quote_header_id;

CURSOR c_find_active_cart(c_quote_header_id NUMBER,
                          c_party_id        NUMBER,
                          c_cust_account_id NUMBER) is
  select quote_header_id
  from ibe_active_quotes
  where quote_header_id = c_quote_header_id
  and party_id          = c_party_id
  and cust_account_id   = c_cust_account_id
  and record_type       = 'CART';


l_api_name CONSTANT VARCHAR2(30) := 'is_quote_usable';
l_expiration_date date;
l_active_cart     number;
l_return_status          VARCHAR2(1);
l_msg_count              NUMBER   ;
l_msg_data               VARCHAR2(2000);
rec_get_quote_details c_get_quote_details%rowtype;
rec_find_active_cart  c_find_active_cart%rowtype;
BEGIN
SAVEPOINT is_quote_usable;
for rec_get_quote_details in c_get_quote_details(p_quote_header_id) LOOP
  l_expiration_date := rec_get_quote_details.quote_expiration_date;
  exit when c_get_quote_details%notfound;
END LOOP;

IF (nvl(trunc(l_expiration_date), trunc(sysdate)+1) < trunc(sysdate)) THEN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN

    IBE_Util.Debug('is_quote_usable: Quote: '||p_quote_header_id||' has expired');
    IBE_Util.Debug('Expiration date for the quote is: '||to_char(l_expiration_date,'mm-dd-yyyy:hh24:mi:ss'));
  END IF;
  FOR rec_find_active_cart in c_find_active_cart(p_quote_header_id,
                                                 p_party_id,
                                                 p_cust_account_id) LOOP
    l_active_cart := rec_find_active_cart.quote_header_id;
    IF (l_active_cart is not null) THEN
      IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
                 P_Quote_header_id  => p_quote_header_id,
                 P_Party_id         => p_party_id        ,
                 P_Cust_account_id  => p_Cust_account_id ,
                 p_api_version      => 1                 ,
                 p_init_msg_list    => fnd_api.g_false   ,
                 p_commit           => fnd_api.g_false   ,
                 x_return_status    => l_return_status   ,
                 x_msg_count        => l_msg_count       ,
                 x_msg_data         => l_msg_data        );

               IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
    END IF;
    EXIT when c_find_active_cart%notfound;
  END LOOP;
  return FND_API.G_FALSE;
ELSE
  return FND_API.G_TRUE;
END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Expected exception in IBE_QUOTE_MISC_PVT.Is_quote_usable');
     END IF;

     ROLLBACK TO is_quote_usable;
      l_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unexpected exception in IBE_QUOTE_MISC_PVT.Is_quote_usable');
     END IF;
     ROLLBACK TO is_quote_usable;
	 l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);
   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_Util.Debug('Unknown exception in IBE_QUOTE_MISC_PVT.Is_quote_usable');
     END IF;
     ROLLBACK TO is_quote_usable;
     l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  	 IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                               l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => l_msg_count,
                                p_data    => l_msg_data);

END ;

-- Start of comments
--    API name   : Get_Active_Quote_ID
--    Type       : Private
--    Function   :
--    Parameters :
--    Version    : Current version	1.0
--    Notes      :
--
-- End of comments

FUNCTION Get_Active_Quote_ID
(
   p_party_id        IN NUMBER,
   p_cust_account_id IN NUMBER
  ) RETURN NUMBER
IS
   l_quote_header_id NUMBER := NULL;
   l_is_quote_usable VARCHAR2(1) ;
BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug(' Querying active quote id for partyid: ' || p_party_id || ' and acctid: ' || p_cust_account_id);
  END IF;

  --MANNAMRA:09/22/02: Changed this query to get the active quote id from
                        --active_quotes table(single source of truth for active quotes)

  SELECT aq.quote_header_id
  INTO l_quote_header_id
  FROM IBE_ACTIVE_QUOTES AQ
  where party_id = p_party_id
  and cust_account_id = p_cust_account_id
  and record_type       = 'CART';

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug(' Querying found: ' || l_quote_header_id);
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('get_active_qute_id: checking to see the usability of above quote');
  END IF;

  IF(l_quote_header_id is not null) THEN
    l_is_quote_usable := is_quote_usable(l_quote_header_id,
                                         p_party_id,
                                         p_cust_account_id);
    IF (l_is_quote_usable =FND_API.G_TRUE)  THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_Util.Debug('get_active_qute_id:l_quote_usable is true');
      END IF;
      RETURN l_quote_header_id;
    END IF;
  END IF;
  return 0;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
   WHEN TOO_MANY_ROWS THEN
      RETURN -1;
END Get_Active_Quote_ID;


-- Start of comments
--    API name   : Get_Number_Of_Lines
--    Type       : Private.
--    Function   :
--    Parameters :
--    Version    : Current version	1.0
--    Notes      :
--
-- End of comments
PROCEDURE Get_Number_Of_Lines
(
   p_party_id        IN  NUMBER,
   p_cust_account_id IN  NUMBER,
   x_number_of_lines OUT NOCOPY NUMBER
)
IS
   l_quote_header_id NUMBER := NULL;
BEGIN
   l_quote_header_id := Get_Active_Quote_ID(p_party_id, p_cust_account_id);

   IF l_quote_header_id = 0
   OR l_quote_header_id = -1 THEN
      x_number_of_lines := -1;
   ELSE
      SELECT COUNT(*)
      INTO x_number_of_lines
      FROM aso_quote_lines
      WHERE quote_header_id = l_quote_header_id;
   END IF;
END Get_Number_Of_Lines;

-- wli

FUNCTION get_Quote_Status(
  p_quote_header_id         IN  NUMBER
) RETURN VARCHAR2
IS
l_quote_header_id           NUMBER;
l_order_id                  NUMBER;
BEGIN

   SELECT quote_header_id, order_id INTO l_quote_header_id, l_order_id
   FROM aso_quote_headers
   WHERE quote_header_id = p_quote_header_id;

  IF (l_order_id IS NULL) THEN
    RETURN 'NOT_ORDERED';
  ELSE
    RETURN 'ORDERED';
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 'NOT_EXIST';
END get_quote_status;


FUNCTION getLineIndexFromLineId(
  p_quote_line_id           IN NUMBER
  ,p_qte_line_tbl           IN aso_quote_pub.qte_line_tbl_type
) RETURN NUMBER
IS
BEGIN

  FOR i IN 1..p_qte_line_tbl.count LOOP
     IF p_quote_line_id = p_qte_line_tbl(i).quote_line_id then
        RETURN i;
     END IF;


  END LOOP;

  RETURN FND_API.G_MISS_NUM;
END getLineIndexFromLineId;


FUNCTION getQuoteLastUpdateDate(
  p_quote_header_id         IN  NUMBER
) RETURN DATE
IS

  CURSOR c_getLastUpdateDate(c_qte_header_id NUMBER) IS
  SELECT last_update_date FROM ASO_QUOTE_HEADERS
  WHERE quote_header_id = c_qte_header_id;
  l_last_update_date  date := FND_API.G_MISS_DATE;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.Debug('getQuoteLastUpdateDate: starts');
  END IF;

  OPEN c_getLastUpdateDate(p_quote_header_id);
  FETCH c_getLastUpdateDate into l_last_update_date;
  CLOSE c_getLastUpdateDate;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.Debug('getQuoteLastUpdateDate: ends');
  END IF;

  RETURN l_last_update_date;
END getQuoteLastUpdateDate;


FUNCTION getLinePrcAttrTbl(
  p_quote_line_id             IN  NUMBER
) RETURN    ASO_QUOTE_PUB.PRICE_ATTRIBUTES_TBL_TYPE
IS
  l_ln_price_attributes_rec   ASO_QUOTE_PUB.PRICE_ATTRIBUTES_REC_Type;
  l_ln_price_attributes_tbl   ASO_QUOTE_PUB.PRICE_ATTRIBUTES_Tbl_Type
                              := ASO_QUOTE_PUB.g_miss_PRICE_ATTRIBUTES_Tbl;

  CURSOR c_getlnprcattrtbl(p_quote_line_id number) is
  SELECT APA.price_attribute_id
         ,APA.creation_date
         ,APA.created_by
         ,APA.last_update_date
         ,APA.last_updated_by
         ,APA.last_update_login
         ,APA.request_id
         ,APA.program_application_id
         ,APA.program_id
         ,APA.program_update_date
         ,APA.quote_header_id
         ,APA.quote_line_id
         ,APA.flex_title
         ,APA.pricing_context
         ,APA.pricing_attribute1
         ,APA.pricing_attribute2
         ,APA.pricing_attribute3
         ,APA.pricing_attribute4
         ,APA.pricing_attribute5
         ,APA.pricing_attribute6
         ,APA.pricing_attribute7
         ,APA.pricing_attribute8
         ,APA.pricing_attribute9
         ,APA.pricing_attribute10
         ,APA.pricing_attribute11
         ,APA.pricing_attribute12
         ,APA.pricing_attribute13
         ,APA.pricing_attribute14
         ,APA.pricing_attribute15
         ,APA.pricing_attribute16
         ,APA.pricing_attribute17
         ,APA.pricing_attribute18
         ,APA.pricing_attribute19
         ,APA.pricing_attribute20
         ,APA.pricing_attribute21
         ,APA.pricing_attribute22
         ,APA.pricing_attribute23
         ,APA.pricing_attribute24
         ,APA.pricing_attribute25
         ,APA.pricing_attribute26
         ,APA.pricing_attribute27
         ,APA.pricing_attribute28
         ,APA.pricing_attribute29
         ,APA.pricing_attribute30
         ,APA.pricing_attribute31
         ,APA.pricing_attribute32
         ,APA.pricing_attribute33
         ,APA.pricing_attribute34
         ,APA.pricing_attribute35
         ,APA.pricing_attribute36
         ,APA.pricing_attribute37
         ,APA.pricing_attribute38
         ,APA.pricing_attribute39
         ,APA.pricing_attribute40
         ,APA.pricing_attribute41
         ,APA.pricing_attribute42
         ,APA.pricing_attribute43
         ,APA.pricing_attribute44
         ,APA.pricing_attribute45
         ,APA.pricing_attribute46
         ,APA.pricing_attribute47
         ,APA.pricing_attribute48
         ,APA.pricing_attribute49
         ,APA.pricing_attribute50
         ,APA.pricing_attribute51
         ,APA.pricing_attribute52
         ,APA.pricing_attribute53
         ,APA.pricing_attribute54
         ,APA.pricing_attribute55
         ,APA.pricing_attribute56
         ,APA.pricing_attribute57
         ,APA.pricing_attribute58
         ,APA.pricing_attribute59
         ,APA.pricing_attribute50
         ,APA.pricing_attribute51
         ,APA.pricing_attribute52
         ,APA.pricing_attribute53
         ,APA.pricing_attribute54
         ,APA.pricing_attribute55
         ,APA.pricing_attribute56
         ,APA.pricing_attribute57
         ,APA.pricing_attribute58
         ,APA.pricing_attribute59
         ,APA.pricing_attribute60
         ,APA.pricing_attribute61
         ,APA.pricing_attribute62
         ,APA.pricing_attribute63
         ,APA.pricing_attribute64
         ,APA.pricing_attribute65
         ,APA.pricing_attribute66
         ,APA.pricing_attribute67
         ,APA.pricing_attribute68
         ,APA.pricing_attribute69
         ,APA.pricing_attribute70
         ,APA.pricing_attribute71
         ,APA.pricing_attribute72
         ,APA.pricing_attribute73
         ,APA.pricing_attribute74
         ,APA.pricing_attribute75
         ,APA.pricing_attribute76
         ,APA.pricing_attribute77
         ,APA.pricing_attribute78
         ,APA.pricing_attribute79
         ,APA.pricing_attribute80
         ,APA.pricing_attribute81
         ,APA.pricing_attribute82
         ,APA.pricing_attribute83
         ,APA.pricing_attribute84
         ,APA.pricing_attribute85
         ,APA.pricing_attribute86
         ,APA.pricing_attribute87
         ,APA.pricing_attribute88
         ,APA.pricing_attribute89
         ,APA.pricing_attribute90
         ,APA.pricing_attribute91
         ,APA.pricing_attribute92
         ,APA.pricing_attribute93
         ,APA.pricing_attribute94
         ,APA.pricing_attribute95
         ,APA.pricing_attribute96
         ,APA.pricing_attribute97
         ,APA.pricing_attribute98
         ,APA.pricing_attribute99
         ,APA.pricing_attribute100
         ,APA.context
         ,APA.attribute1
         ,APA.attribute2
         ,APA.attribute3
         ,APA.attribute4
         ,APA.attribute5
         ,APA.attribute6
         ,APA.attribute7
         ,APA.attribute8
         ,APA.attribute9
         ,APA.attribute10
         ,APA.attribute11
         ,APA.attribute12
         ,APA.attribute13
         ,APA.attribute14
         ,APA.attribute15
  FROM aso_price_attributes APA
  WHERE APA.quote_line_id = p_quote_line_id;

BEGIN
  OPEN c_getlnprcattrtbl(p_quote_line_id);
  LOOP
  FETCH c_getlnprcattrtbl
  INTO l_ln_price_attributes_rec.price_attribute_id
       ,l_ln_price_attributes_rec.creation_date
       ,l_ln_price_attributes_rec.created_by
       ,l_ln_price_attributes_rec.last_update_date
       ,l_ln_price_attributes_rec.last_updated_by
       ,l_ln_price_attributes_rec.last_update_login
       ,l_ln_price_attributes_rec.request_id
       ,l_ln_price_attributes_rec.program_application_id
       ,l_ln_price_attributes_rec.program_id
       ,l_ln_price_attributes_rec.program_update_date
       ,l_ln_price_attributes_rec.quote_header_id
       ,l_ln_price_attributes_rec.quote_line_id
       ,l_ln_price_attributes_rec.flex_title
       ,l_ln_price_attributes_rec.pricing_context
       ,l_ln_price_attributes_rec.pricing_attribute1
       ,l_ln_price_attributes_rec.pricing_attribute2
       ,l_ln_price_attributes_rec.pricing_attribute3
       ,l_ln_price_attributes_rec.pricing_attribute4
       ,l_ln_price_attributes_rec.pricing_attribute5
       ,l_ln_price_attributes_rec.pricing_attribute6
       ,l_ln_price_attributes_rec.pricing_attribute7
       ,l_ln_price_attributes_rec.pricing_attribute8
       ,l_ln_price_attributes_rec.pricing_attribute9
       ,l_ln_price_attributes_rec.pricing_attribute10
       ,l_ln_price_attributes_rec.pricing_attribute11
       ,l_ln_price_attributes_rec.pricing_attribute12
       ,l_ln_price_attributes_rec.pricing_attribute13
       ,l_ln_price_attributes_rec.pricing_attribute14
       ,l_ln_price_attributes_rec.pricing_attribute15
       ,l_ln_price_attributes_rec.pricing_attribute16
       ,l_ln_price_attributes_rec.pricing_attribute17
       ,l_ln_price_attributes_rec.pricing_attribute18
       ,l_ln_price_attributes_rec.pricing_attribute19
       ,l_ln_price_attributes_rec.pricing_attribute20
       ,l_ln_price_attributes_rec.pricing_attribute21
       ,l_ln_price_attributes_rec.pricing_attribute22
       ,l_ln_price_attributes_rec.pricing_attribute23
       ,l_ln_price_attributes_rec.pricing_attribute24
       ,l_ln_price_attributes_rec.pricing_attribute25
       ,l_ln_price_attributes_rec.pricing_attribute26
       ,l_ln_price_attributes_rec.pricing_attribute27
       ,l_ln_price_attributes_rec.pricing_attribute28
       ,l_ln_price_attributes_rec.pricing_attribute29
       ,l_ln_price_attributes_rec.pricing_attribute30
       ,l_ln_price_attributes_rec.pricing_attribute31
       ,l_ln_price_attributes_rec.pricing_attribute32
       ,l_ln_price_attributes_rec.pricing_attribute33
       ,l_ln_price_attributes_rec.pricing_attribute34
       ,l_ln_price_attributes_rec.pricing_attribute35
       ,l_ln_price_attributes_rec.pricing_attribute36
       ,l_ln_price_attributes_rec.pricing_attribute37
       ,l_ln_price_attributes_rec.pricing_attribute38
       ,l_ln_price_attributes_rec.pricing_attribute39
       ,l_ln_price_attributes_rec.pricing_attribute40
       ,l_ln_price_attributes_rec.pricing_attribute41
       ,l_ln_price_attributes_rec.pricing_attribute42
       ,l_ln_price_attributes_rec.pricing_attribute43
       ,l_ln_price_attributes_rec.pricing_attribute44
       ,l_ln_price_attributes_rec.pricing_attribute45
       ,l_ln_price_attributes_rec.pricing_attribute46
       ,l_ln_price_attributes_rec.pricing_attribute47
       ,l_ln_price_attributes_rec.pricing_attribute48
       ,l_ln_price_attributes_rec.pricing_attribute49
       ,l_ln_price_attributes_rec.pricing_attribute50
       ,l_ln_price_attributes_rec.pricing_attribute51
       ,l_ln_price_attributes_rec.pricing_attribute52
       ,l_ln_price_attributes_rec.pricing_attribute53
       ,l_ln_price_attributes_rec.pricing_attribute54
       ,l_ln_price_attributes_rec.pricing_attribute55
       ,l_ln_price_attributes_rec.pricing_attribute56
       ,l_ln_price_attributes_rec.pricing_attribute57
       ,l_ln_price_attributes_rec.pricing_attribute58
       ,l_ln_price_attributes_rec.pricing_attribute59
       ,l_ln_price_attributes_rec.pricing_attribute50
       ,l_ln_price_attributes_rec.pricing_attribute51
       ,l_ln_price_attributes_rec.pricing_attribute52
       ,l_ln_price_attributes_rec.pricing_attribute53
       ,l_ln_price_attributes_rec.pricing_attribute54
       ,l_ln_price_attributes_rec.pricing_attribute55
       ,l_ln_price_attributes_rec.pricing_attribute56
       ,l_ln_price_attributes_rec.pricing_attribute57
       ,l_ln_price_attributes_rec.pricing_attribute58
       ,l_ln_price_attributes_rec.pricing_attribute59
       ,l_ln_price_attributes_rec.pricing_attribute60
       ,l_ln_price_attributes_rec.pricing_attribute61
       ,l_ln_price_attributes_rec.pricing_attribute62
       ,l_ln_price_attributes_rec.pricing_attribute63
       ,l_ln_price_attributes_rec.pricing_attribute64
       ,l_ln_price_attributes_rec.pricing_attribute65
       ,l_ln_price_attributes_rec.pricing_attribute66
       ,l_ln_price_attributes_rec.pricing_attribute67
       ,l_ln_price_attributes_rec.pricing_attribute68
       ,l_ln_price_attributes_rec.pricing_attribute69
       ,l_ln_price_attributes_rec.pricing_attribute70
       ,l_ln_price_attributes_rec.pricing_attribute71
       ,l_ln_price_attributes_rec.pricing_attribute72
       ,l_ln_price_attributes_rec.pricing_attribute73
       ,l_ln_price_attributes_rec.pricing_attribute74
       ,l_ln_price_attributes_rec.pricing_attribute75
       ,l_ln_price_attributes_rec.pricing_attribute76
       ,l_ln_price_attributes_rec.pricing_attribute77
       ,l_ln_price_attributes_rec.pricing_attribute78
       ,l_ln_price_attributes_rec.pricing_attribute79
       ,l_ln_price_attributes_rec.pricing_attribute80
       ,l_ln_price_attributes_rec.pricing_attribute81
       ,l_ln_price_attributes_rec.pricing_attribute82
       ,l_ln_price_attributes_rec.pricing_attribute83
       ,l_ln_price_attributes_rec.pricing_attribute84
       ,l_ln_price_attributes_rec.pricing_attribute85
       ,l_ln_price_attributes_rec.pricing_attribute86
       ,l_ln_price_attributes_rec.pricing_attribute87
       ,l_ln_price_attributes_rec.pricing_attribute88
       ,l_ln_price_attributes_rec.pricing_attribute89
       ,l_ln_price_attributes_rec.pricing_attribute90
       ,l_ln_price_attributes_rec.pricing_attribute91
       ,l_ln_price_attributes_rec.pricing_attribute92
       ,l_ln_price_attributes_rec.pricing_attribute93
       ,l_ln_price_attributes_rec.pricing_attribute94
       ,l_ln_price_attributes_rec.pricing_attribute95
       ,l_ln_price_attributes_rec.pricing_attribute96
       ,l_ln_price_attributes_rec.pricing_attribute97
       ,l_ln_price_attributes_rec.pricing_attribute98
       ,l_ln_price_attributes_rec.pricing_attribute99
       ,l_ln_price_attributes_rec.pricing_attribute100
       ,l_ln_price_attributes_rec.context
       ,l_ln_price_attributes_rec.attribute1
       ,l_ln_price_attributes_rec.attribute2
       ,l_ln_price_attributes_rec.attribute3
       ,l_ln_price_attributes_rec.attribute4
       ,l_ln_price_attributes_rec.attribute5
       ,l_ln_price_attributes_rec.attribute6
       ,l_ln_price_attributes_rec.attribute7
       ,l_ln_price_attributes_rec.attribute8
       ,l_ln_price_attributes_rec.attribute9
       ,l_ln_price_attributes_rec.attribute10
       ,l_ln_price_attributes_rec.attribute11
       ,l_ln_price_attributes_rec.attribute12
       ,l_ln_price_attributes_rec.attribute13
       ,l_ln_price_attributes_rec.attribute14
       ,l_ln_price_attributes_rec.attribute15
       ;
  EXIT WHEN c_getlnprcattrtbl%NOTFOUND;
  l_ln_price_attributes_tbl(l_ln_price_attributes_tbl.count+1)
            :=l_ln_price_attributes_rec;
  END LOOP;
  CLOSE   c_getlnprcattrtbl;
  RETURN l_ln_price_attributes_tbl;
END GETLINEPRCATTRTBL;

FUNCTION getLineAttrExtTbl(
  p_quote_line_id             IN  NUMBER
) RETURN   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
IS

  l_line_attr_ext_tbl   ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type
                        := ASO_QUOTE_PUB.g_miss_Line_Attribs_Ext_Tbl;

  l_line_attr_ext_rec   ASO_QUOTE_PUB.Line_Attribs_Ext_rec_Type;

  CURSOR c_getLineAttrExtTbl(p_quote_line_id number) is
  SELECT lae.LINE_ATTRIBUTE_ID
         ,lae.CREATION_DATE
         ,lae.CREATED_BY
         ,lae.LAST_UPDATE_DATE
         ,lae.LAST_UPDATED_BY
         ,lae.LAST_UPDATE_LOGIN
         ,lae.REQUEST_ID
         ,lae.PROGRAM_APPLICATION_ID
         ,lae.PROGRAM_ID
         ,lae.PROGRAM_UPDATE_DATE
         ,lae.APPLICATION_ID
         ,lae.QUOTE_LINE_ID
         ,lae.ATTRIBUTE_TYPE_CODE
         ,lae.NAME
         ,lae.VALUE
         ,lae.VALUE_TYPE
         ,lae.STATUS
         ,lae.START_DATE_ACTIVE
         ,lae.END_DATE_ACTIVE
--         ,lae.QUOTE_HEADER_ID
--         ,lae.QUOTE_SHIPMENT_ID
--       ,lae.SECURITY_GROUP_ID
--       ,lae.OBJECT_VERSION_NUMBER
  From ASO_QUOTE_LINE_ATTRIBS_EXT lae
  Where lae.QUOTE_LINE_ID = p_quote_line_id;

BEGIN
  OPEN c_getLineAttrExtTbl(p_quote_line_id);
  LOOP
  FETCH c_getLineAttrExtTbl into
        l_line_attr_ext_rec.LINE_ATTRIBUTE_ID
        ,l_line_attr_ext_rec.CREATION_DATE
        ,l_line_attr_ext_rec.CREATED_BY
        ,l_line_attr_ext_rec.LAST_UPDATE_DATE
        ,l_line_attr_ext_rec.LAST_UPDATED_BY
        ,l_line_attr_ext_rec.LAST_UPDATE_LOGIN
        ,l_line_attr_ext_rec.REQUEST_ID
        ,l_line_attr_ext_rec.PROGRAM_APPLICATION_ID
        ,l_line_attr_ext_rec.PROGRAM_ID
        ,l_line_attr_ext_rec.PROGRAM_UPDATE_DATE
        ,l_line_attr_ext_rec.APPLICATION_ID
        ,l_line_attr_ext_rec.QUOTE_LINE_ID
        ,l_line_attr_ext_rec.ATTRIBUTE_TYPE_CODE
        ,l_line_attr_ext_rec.NAME
        ,l_line_attr_ext_rec.VALUE
        ,l_line_attr_ext_rec.VALUE_TYPE
        ,l_line_attr_ext_rec.STATUS
        ,l_line_attr_ext_rec.START_DATE_ACTIVE
        ,l_line_attr_ext_rec.END_DATE_ACTIVE
--      ,l_line_attr_ext_rec.QUOTE_HEADER_ID
--        ,l_line_attr_ext_rec.QUOTE_SHIPMENT_ID
--      ,l_line_attr_ext_rec.SECURITY_GROUP_ID
--      ,l_line_attr_ext_rec.OBJECT_VERSION_NUMBER
        ;
  EXIT WHEN c_getLineAttrExtTbl%NOTFOUND;
     l_line_attr_ext_tbl(l_line_attr_ext_tbl.count+1) := l_line_attr_ext_rec;
  END LOOP;
  CLOSE c_getLineAttrExtTbl;
  RETURN l_line_attr_ext_tbl;
END getLineAttrExtTbl;

FUNCTION getLineDetailTbl(
  p_quote_line_id              IN  NUMBER
) RETURN  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
IS
  l_qte_line_dtl_tbl  ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type
                      := ASO_QUOTE_PUB.g_miss_Qte_Line_Dtl_tbl;
  l_qte_line_dtl_rec  ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_Type;

  CURSOR c_getDetLinetbl(p_quote_line_id number) IS
  SELECT dl.quote_line_detail_id
         ,dl.creation_date
         ,dl.created_by
         ,dl.last_update_date
         ,dl.last_updated_by
         ,dl.last_update_login
         ,dl.request_id
         ,dl.program_application_id
         ,dl.program_id
         ,dl.program_update_date
         ,dl.quote_line_id
         ,dl.config_header_id
         ,dl.config_revision_num
         ,dl.config_item_id
         ,dl.complete_configuration_flag
         ,dl.valid_configuration_flag
         ,dl.component_code
         ,dl.service_coterminate_flag
         ,dl.service_duration
         ,dl.service_period
         ,dl.service_unit_selling_percent
         ,dl.service_unit_list_percent
         ,dl.service_number
         ,dl.unit_percent_base_price
         ,dl.attribute_category
         ,dl.attribute1
         ,dl.attribute2
         ,dl.attribute3
         ,dl.attribute4
         ,dl.attribute5
         ,dl.attribute6
         ,dl.attribute7
         ,dl.attribute8
         ,dl.attribute9
         ,dl.attribute10
         ,dl.attribute11
         ,dl.attribute12
         ,dl.attribute13
         ,dl.attribute14
         ,dl.attribute15
         ,dl.service_ref_type_code
         ,dl.service_ref_order_number
         ,dl.service_ref_line_number
         ,dl.service_ref_line_id
         ,dl.service_ref_system_id
         ,dl.service_ref_option_numb
         ,dl.service_ref_shipment_numb
         ,dl.return_ref_type
         ,dl.return_ref_header_id
         ,dl.return_ref_line_id
         ,dl.return_attribute1
         ,dl.return_attribute2
         ,dl.return_attribute3
         ,dl.return_attribute4
         ,dl.return_attribute5
         ,dl.return_attribute6
         ,dl.return_attribute7
         ,dl.return_attribute8
         ,dl.return_attribute9
         ,dl.return_attribute10
         ,dl.return_attribute11
         ,dl.return_attribute12
         ,dl.return_attribute13
         ,dl.return_attribute14
         ,dl.return_attribute15
  From ASO_quote_LINE_details dl
  Where QUOTE_LINE_ID  = p_quote_line_id;
BEGIN
  open c_getDetLinetbl(p_quote_line_id);
  loop
  fetch c_getDetLinetbl into
        l_qte_line_dtl_rec.quote_line_detail_id
        ,l_qte_line_dtl_rec.creation_date
        ,l_qte_line_dtl_rec.created_by
        ,l_qte_line_dtl_rec.last_update_date
        ,l_qte_line_dtl_rec.last_updated_by
        ,l_qte_line_dtl_rec.last_update_login
        ,l_qte_line_dtl_rec.request_id
        ,l_qte_line_dtl_rec.program_application_id
        ,l_qte_line_dtl_rec.program_id
        ,l_qte_line_dtl_rec.program_update_date
        ,l_qte_line_dtl_rec.quote_line_id
        ,l_qte_line_dtl_rec.config_header_id
        ,l_qte_line_dtl_rec.config_revision_num
        ,l_qte_line_dtl_rec.config_item_id
        ,l_qte_line_dtl_rec.complete_configuration_flag
        ,l_qte_line_dtl_rec.valid_configuration_flag
        ,l_qte_line_dtl_rec.component_code
        ,l_qte_line_dtl_rec.service_coterminate_flag
        ,l_qte_line_dtl_rec.service_duration
        ,l_qte_line_dtl_rec.service_period
        ,l_qte_line_dtl_rec.service_unit_selling_percent
        ,l_qte_line_dtl_rec.service_unit_list_percent
        ,l_qte_line_dtl_rec.service_number
        ,l_qte_line_dtl_rec.unit_percent_base_price
        ,l_qte_line_dtl_rec.attribute_category
        ,l_qte_line_dtl_rec.attribute1
        ,l_qte_line_dtl_rec.attribute2
        ,l_qte_line_dtl_rec.attribute3
        ,l_qte_line_dtl_rec.attribute4
        ,l_qte_line_dtl_rec.attribute5
        ,l_qte_line_dtl_rec.attribute6
        ,l_qte_line_dtl_rec.attribute7
        ,l_qte_line_dtl_rec.attribute8
        ,l_qte_line_dtl_rec.attribute9
        ,l_qte_line_dtl_rec.attribute10
        ,l_qte_line_dtl_rec.attribute11
        ,l_qte_line_dtl_rec.attribute12
        ,l_qte_line_dtl_rec.attribute13
        ,l_qte_line_dtl_rec.attribute14
        ,l_qte_line_dtl_rec.attribute15
        ,l_qte_line_dtl_rec.service_ref_type_code
        ,l_qte_line_dtl_rec.service_ref_order_number
        ,l_qte_line_dtl_rec.service_ref_line_number
        ,l_qte_line_dtl_rec.service_ref_line_id
        ,l_qte_line_dtl_rec.service_ref_system_id
        ,l_qte_line_dtl_rec.service_ref_option_numb
        ,l_qte_line_dtl_rec.service_ref_shipment_numb
        ,l_qte_line_dtl_rec.return_ref_type
        ,l_qte_line_dtl_rec.return_ref_header_id
        ,l_qte_line_dtl_rec.return_ref_line_id
        ,l_qte_line_dtl_rec.return_attribute1
        ,l_qte_line_dtl_rec.return_attribute2
        ,l_qte_line_dtl_rec.return_attribute3
        ,l_qte_line_dtl_rec.return_attribute4
        ,l_qte_line_dtl_rec.return_attribute5
        ,l_qte_line_dtl_rec.return_attribute6
        ,l_qte_line_dtl_rec.return_attribute7
        ,l_qte_line_dtl_rec.return_attribute8
        ,l_qte_line_dtl_rec.return_attribute9
        ,l_qte_line_dtl_rec.return_attribute10
        ,l_qte_line_dtl_rec.return_attribute11
        ,l_qte_line_dtl_rec.return_attribute12
        ,l_qte_line_dtl_rec.return_attribute13
        ,l_qte_line_dtl_rec.return_attribute14
        ,l_qte_line_dtl_rec.return_attribute15;
  EXIT WHEN c_getDetLinetbl%notfound;
    l_qte_line_dtl_tbl(l_qte_line_dtl_tbl.count+1) := l_qte_line_dtl_rec;
  END LOOP;
  CLOSE  c_getDetLinetbl;
  RETURN l_qte_line_dtl_tbl;
END getLineDetailTbl;


FUNCTION getLineRelationshipTbl(
  p_quote_line_id              IN  NUMBER
) RETURN  ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
IS
  l_line_rltship_rec     ASO_QUOTE_PUB.Line_Rltship_rec_Type;
  l_line_rltship_tbl     ASO_QUOTE_PUB.Line_Rltship_Tbl_Type
                         := ASO_QUOTE_PUB.g_miss_Line_Rltship_Tbl;
  CURSOR c_getRelLinetbl(l_quote_line_id number) IS
  SELECT LINE_RELATIONSHIP_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,QUOTE_LINE_ID
         ,RELATED_QUOTE_LINE_ID
         ,RELATIONSHIP_TYPE_CODE
         ,RECIPROCAL_FLAG
  From  ASO_LINE_RELATIONSHIPS
  Where QUOTE_LINE_ID = p_quote_line_id;


begin

  open c_getRelLinetbl(p_quote_line_id);

  loop
  fetch c_getRelLinetbl into
        l_line_rltship_rec.LINE_RELATIONSHIP_ID
        ,l_line_rltship_rec.CREATION_DATE
        ,l_line_rltship_rec.CREATED_BY
        ,l_line_rltship_rec.LAST_UPDATED_BY
        ,l_line_rltship_rec.LAST_UPDATE_DATE
        ,l_line_rltship_rec.LAST_UPDATE_LOGIN
        ,l_line_rltship_rec.REQUEST_ID
        ,l_line_rltship_rec.PROGRAM_APPLICATION_ID
        ,l_line_rltship_rec.PROGRAM_ID
        ,l_line_rltship_rec.PROGRAM_UPDATE_DATE
        ,l_line_rltship_rec.QUOTE_LINE_ID
        ,l_line_rltship_rec.RELATED_QUOTE_LINE_ID
        ,l_line_rltship_rec.RELATIONSHIP_TYPE_CODE
        ,l_line_rltship_rec.RECIPROCAL_FLAG;
	EXIT WHEN c_getRelLinetbl%NOTFOUND;
  l_line_rltship_tbl(l_line_rltship_tbl.count+1) := l_line_rltship_rec;
  END LOOP;
  CLOSE c_getRelLinetbl;
  RETURN l_line_rltship_tbl;
END getLineRelationshipTbl;

FUNCTION getLinePrcAdjTbl(
  p_quote_line_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Tbl_Type
IS
  l_line_PrcAdj_rec     ASO_QUOTE_PUB.Price_Adj_Rec_Type;
  l_line_PrcAdj_tbl     ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                         := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
  CURSOR c_getLinePrcAdjTbl(l_quote_line_id number) IS
  SELECT PRICE_ADJUSTMENT_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,REQUEST_ID
         ,QUOTE_HEADER_ID
         ,QUOTE_LINE_ID
         ,QUOTE_SHIPMENT_ID
         ,MODIFIER_HEADER_ID
         ,MODIFIER_LINE_ID
         ,MODIFIER_LINE_TYPE_CODE
         ,MODIFIER_MECHANISM_TYPE_CODE
         ,MODIFIED_FROM
         ,MODIFIED_TO
         ,OPERAND
         ,ARITHMETIC_OPERATOR
         ,AUTOMATIC_FLAG
         ,UPDATE_ALLOWABLE_FLAG
         ,UPDATED_FLAG
         ,APPLIED_FLAG
         ,ON_INVOICE_FLAG
         ,PRICING_PHASE_ID
         ,ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ORIG_SYS_DISCOUNT_REF
         ,CHANGE_SEQUENCE
         ,UPDATE_ALLOWED
         ,CHANGE_REASON_CODE
         ,CHANGE_REASON_TEXT
         ,COST_ID
         ,TAX_CODE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON_CODE
         ,PARENT_ADJUSTMENT_ID
         ,INVOICED_FLAG
         ,ESTIMATED_FLAG
         ,INC_IN_SALES_PERFORMANCE
         ,SPLIT_ACTION_CODE
         ,ADJUSTED_AMOUNT
         ,CHARGE_TYPE_CODE
         ,CHARGE_SUBTYPE_CODE
         ,RANGE_BREAK_QUANTITY
         ,ACCRUAL_CONVERSION_RATE
         ,PRICING_GROUP_SEQUENCE
         ,ACCRUAL_FLAG
         ,LIST_LINE_NO
         ,SOURCE_SYSTEM_CODE
         ,BENEFIT_QTY
         ,BENEFIT_UOM_CODE
         ,PRINT_ON_INVOICE_FLAG
         ,EXPIRATION_DATE
         ,REBATE_TRANSACTION_TYPE_CODE
         ,REBATE_TRANSACTION_REFERENCE
         ,REBATE_PAYMENT_SYSTEM_CODE
         ,REDEEMED_DATE
         ,REDEEMED_FLAG
         ,MODIFIER_LEVEL_CODE
         ,PRICE_BREAK_TYPE_CODE
         ,SUBSTITUTION_ATTRIBUTE
         ,PRORATION_TYPE_CODE
         ,INCLUDE_ON_RETURNS_FLAG
         ,CREDIT_OR_CHARGE_FLAG
  From  ASO_PRICE_ADJUSTMENTS
  Where QUOTE_LINE_ID = p_quote_line_id;

begin
  open c_getLinePrcAdjTbl(p_quote_line_id);
  loop
  fetch c_getLinePrcAdjTbl into
        l_line_PrcAdj_rec.PRICE_ADJUSTMENT_ID
        ,l_line_PrcAdj_rec.CREATION_DATE
        ,l_line_PrcAdj_rec.CREATED_BY
        ,l_line_PrcAdj_rec.LAST_UPDATE_DATE
        ,l_line_PrcAdj_rec.LAST_UPDATED_BY
        ,l_line_PrcAdj_rec.LAST_UPDATE_LOGIN
        ,l_line_PrcAdj_rec.PROGRAM_APPLICATION_ID
        ,l_line_PrcAdj_rec.PROGRAM_ID
        ,l_line_PrcAdj_rec.PROGRAM_UPDATE_DATE
        ,l_line_PrcAdj_rec.REQUEST_ID
        ,l_line_PrcAdj_rec.QUOTE_HEADER_ID
        ,l_line_PrcAdj_rec.QUOTE_LINE_ID
        ,l_line_PrcAdj_rec.QUOTE_SHIPMENT_ID
        ,l_line_PrcAdj_rec.MODIFIER_HEADER_ID
        ,l_line_PrcAdj_rec.MODIFIER_LINE_ID
        ,l_line_PrcAdj_rec.MODIFIER_LINE_TYPE_CODE
        ,l_line_PrcAdj_rec.MODIFIER_MECHANISM_TYPE_CODE
        ,l_line_PrcAdj_rec.MODIFIED_FROM
        ,l_line_PrcAdj_rec.MODIFIED_TO
        ,l_line_PrcAdj_rec.OPERAND
        ,l_line_PrcAdj_rec.ARITHMETIC_OPERATOR
        ,l_line_PrcAdj_rec.AUTOMATIC_FLAG
        ,l_line_PrcAdj_rec.UPDATE_ALLOWABLE_FLAG
        ,l_line_PrcAdj_rec.UPDATED_FLAG
        ,l_line_PrcAdj_rec.APPLIED_FLAG
        ,l_line_PrcAdj_rec.ON_INVOICE_FLAG
        ,l_line_PrcAdj_rec.PRICING_PHASE_ID
        ,l_line_PrcAdj_rec.ATTRIBUTE_CATEGORY
        ,l_line_PrcAdj_rec.ATTRIBUTE1
        ,l_line_PrcAdj_rec.ATTRIBUTE2
        ,l_line_PrcAdj_rec.ATTRIBUTE3
        ,l_line_PrcAdj_rec.ATTRIBUTE4
        ,l_line_PrcAdj_rec.ATTRIBUTE5
        ,l_line_PrcAdj_rec.ATTRIBUTE6
        ,l_line_PrcAdj_rec.ATTRIBUTE7
        ,l_line_PrcAdj_rec.ATTRIBUTE8
        ,l_line_PrcAdj_rec.ATTRIBUTE9
        ,l_line_PrcAdj_rec.ATTRIBUTE10
        ,l_line_PrcAdj_rec.ATTRIBUTE11
        ,l_line_PrcAdj_rec.ATTRIBUTE12
        ,l_line_PrcAdj_rec.ATTRIBUTE13
        ,l_line_PrcAdj_rec.ATTRIBUTE14
        ,l_line_PrcAdj_rec.ATTRIBUTE15
        ,l_line_PrcAdj_rec.ORIG_SYS_DISCOUNT_REF
        ,l_line_PrcAdj_rec.CHANGE_SEQUENCE
        ,l_line_PrcAdj_rec.UPDATE_ALLOWED
        ,l_line_PrcAdj_rec.CHANGE_REASON_CODE
        ,l_line_PrcAdj_rec.CHANGE_REASON_TEXT
        ,l_line_PrcAdj_rec.COST_ID
        ,l_line_PrcAdj_rec.TAX_CODE
        ,l_line_PrcAdj_rec.TAX_EXEMPT_FLAG
        ,l_line_PrcAdj_rec.TAX_EXEMPT_NUMBER
        ,l_line_PrcAdj_rec.TAX_EXEMPT_REASON_CODE
        ,l_line_PrcAdj_rec.PARENT_ADJUSTMENT_ID
        ,l_line_PrcAdj_rec.INVOICED_FLAG
        ,l_line_PrcAdj_rec.ESTIMATED_FLAG
        ,l_line_PrcAdj_rec.INC_IN_SALES_PERFORMANCE
        ,l_line_PrcAdj_rec.SPLIT_ACTION_CODE
        ,l_line_PrcAdj_rec.ADJUSTED_AMOUNT
        ,l_line_PrcAdj_rec.CHARGE_TYPE_CODE
        ,l_line_PrcAdj_rec.CHARGE_SUBTYPE_CODE
        ,l_line_PrcAdj_rec.RANGE_BREAK_QUANTITY
        ,l_line_PrcAdj_rec.ACCRUAL_CONVERSION_RATE
        ,l_line_PrcAdj_rec.PRICING_GROUP_SEQUENCE
        ,l_line_PrcAdj_rec.ACCRUAL_FLAG
        ,l_line_PrcAdj_rec.LIST_LINE_NO
        ,l_line_PrcAdj_rec.SOURCE_SYSTEM_CODE
        ,l_line_PrcAdj_rec.BENEFIT_QTY
        ,l_line_PrcAdj_rec.BENEFIT_UOM_CODE
        ,l_line_PrcAdj_rec.PRINT_ON_INVOICE_FLAG
        ,l_line_PrcAdj_rec.EXPIRATION_DATE
        ,l_line_PrcAdj_rec.REBATE_TRANSACTION_TYPE_CODE
        ,l_line_PrcAdj_rec.REBATE_TRANSACTION_REFERENCE
        ,l_line_PrcAdj_rec.REBATE_PAYMENT_SYSTEM_CODE
        ,l_line_PrcAdj_rec.REDEEMED_DATE
        ,l_line_PrcAdj_rec.REDEEMED_FLAG
        ,l_line_PrcAdj_rec.MODIFIER_LEVEL_CODE
        ,l_line_PrcAdj_rec.PRICE_BREAK_TYPE_CODE
        ,l_line_PrcAdj_rec.SUBSTITUTION_ATTRIBUTE
        ,l_line_PrcAdj_rec.PRORATION_TYPE_CODE
        ,l_line_PrcAdj_rec.INCLUDE_ON_RETURNS_FLAG
        ,l_line_PrcAdj_rec.CREDIT_OR_CHARGE_FLAG;
	EXIT WHEN c_getLinePrcAdjTbl%NOTFOUND;
  l_line_PrcAdj_tbl(l_line_PrcAdj_tbl.count+1) := l_line_PrcAdj_rec;
  END LOOP;
  CLOSE c_getLinePrcAdjTbl;
  RETURN l_line_PrcAdj_tbl;
END getLinePrcAdjTbl;

FUNCTION getHdrPrcAdjTbl(
  p_quote_hdr_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Tbl_Type
IS
  l_hdr_PrcAdj_rec     ASO_QUOTE_PUB.Price_Adj_Rec_Type;
  l_hdr_PrcAdj_tbl     ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                         := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
  CURSOR c_getHdrPrcAdjTbl(l_quote_hdr_id number) IS
  SELECT PRICE_ADJUSTMENT_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,REQUEST_ID
         ,QUOTE_HEADER_ID
         ,QUOTE_LINE_ID
         ,QUOTE_SHIPMENT_ID
         ,MODIFIER_HEADER_ID
         ,MODIFIER_LINE_ID
         ,MODIFIER_LINE_TYPE_CODE
         ,MODIFIER_MECHANISM_TYPE_CODE
         ,MODIFIED_FROM
         ,MODIFIED_TO
         ,OPERAND
         ,ARITHMETIC_OPERATOR
         ,AUTOMATIC_FLAG
         ,UPDATE_ALLOWABLE_FLAG
         ,UPDATED_FLAG
         ,APPLIED_FLAG
         ,ON_INVOICE_FLAG
         ,PRICING_PHASE_ID
         ,ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ORIG_SYS_DISCOUNT_REF
         ,CHANGE_SEQUENCE
         ,UPDATE_ALLOWED
         ,CHANGE_REASON_CODE
         ,CHANGE_REASON_TEXT
         ,COST_ID
         ,TAX_CODE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON_CODE
         ,PARENT_ADJUSTMENT_ID
         ,INVOICED_FLAG
         ,ESTIMATED_FLAG
         ,INC_IN_SALES_PERFORMANCE
         ,SPLIT_ACTION_CODE
         ,ADJUSTED_AMOUNT
         ,CHARGE_TYPE_CODE
         ,CHARGE_SUBTYPE_CODE
         ,RANGE_BREAK_QUANTITY
         ,ACCRUAL_CONVERSION_RATE
         ,PRICING_GROUP_SEQUENCE
         ,ACCRUAL_FLAG
         ,LIST_LINE_NO
         ,SOURCE_SYSTEM_CODE
         ,BENEFIT_QTY
         ,BENEFIT_UOM_CODE
         ,PRINT_ON_INVOICE_FLAG
         ,EXPIRATION_DATE
         ,REBATE_TRANSACTION_TYPE_CODE
         ,REBATE_TRANSACTION_REFERENCE
         ,REBATE_PAYMENT_SYSTEM_CODE
         ,REDEEMED_DATE
         ,REDEEMED_FLAG
         ,MODIFIER_LEVEL_CODE
         ,PRICE_BREAK_TYPE_CODE
         ,SUBSTITUTION_ATTRIBUTE
         ,PRORATION_TYPE_CODE
         ,INCLUDE_ON_RETURNS_FLAG
         ,CREDIT_OR_CHARGE_FLAG
  From  ASO_PRICE_ADJUSTMENTS
  Where QUOTE_HEADER_ID = p_quote_hdr_id;

begin
  open c_getHdrPrcAdjTbl(p_quote_hdr_id);
  loop
  fetch c_getHdrPrcAdjTbl into
        l_hdr_PrcAdj_rec.PRICE_ADJUSTMENT_ID
        ,l_hdr_PrcAdj_rec.CREATION_DATE
        ,l_hdr_PrcAdj_rec.CREATED_BY
        ,l_hdr_PrcAdj_rec.LAST_UPDATE_DATE
        ,l_hdr_PrcAdj_rec.LAST_UPDATED_BY
        ,l_hdr_PrcAdj_rec.LAST_UPDATE_LOGIN
        ,l_hdr_PrcAdj_rec.PROGRAM_APPLICATION_ID
        ,l_hdr_PrcAdj_rec.PROGRAM_ID
        ,l_hdr_PrcAdj_rec.PROGRAM_UPDATE_DATE
        ,l_hdr_PrcAdj_rec.REQUEST_ID
        ,l_hdr_PrcAdj_rec.QUOTE_HEADER_ID
        ,l_hdr_PrcAdj_rec.QUOTE_LINE_ID
        ,l_hdr_PrcAdj_rec.QUOTE_SHIPMENT_ID
        ,l_hdr_PrcAdj_rec.MODIFIER_HEADER_ID
        ,l_hdr_PrcAdj_rec.MODIFIER_LINE_ID
        ,l_hdr_PrcAdj_rec.MODIFIER_LINE_TYPE_CODE
        ,l_hdr_PrcAdj_rec.MODIFIER_MECHANISM_TYPE_CODE
        ,l_hdr_PrcAdj_rec.MODIFIED_FROM
        ,l_hdr_PrcAdj_rec.MODIFIED_TO
        ,l_hdr_PrcAdj_rec.OPERAND
        ,l_hdr_PrcAdj_rec.ARITHMETIC_OPERATOR
        ,l_hdr_PrcAdj_rec.AUTOMATIC_FLAG
        ,l_hdr_PrcAdj_rec.UPDATE_ALLOWABLE_FLAG
        ,l_hdr_PrcAdj_rec.UPDATED_FLAG
        ,l_hdr_PrcAdj_rec.APPLIED_FLAG
        ,l_hdr_PrcAdj_rec.ON_INVOICE_FLAG
        ,l_hdr_PrcAdj_rec.PRICING_PHASE_ID
        ,l_hdr_PrcAdj_rec.ATTRIBUTE_CATEGORY
        ,l_hdr_PrcAdj_rec.ATTRIBUTE1
        ,l_hdr_PrcAdj_rec.ATTRIBUTE2
        ,l_hdr_PrcAdj_rec.ATTRIBUTE3
        ,l_hdr_PrcAdj_rec.ATTRIBUTE4
        ,l_hdr_PrcAdj_rec.ATTRIBUTE5
        ,l_hdr_PrcAdj_rec.ATTRIBUTE6
        ,l_hdr_PrcAdj_rec.ATTRIBUTE7
        ,l_hdr_PrcAdj_rec.ATTRIBUTE8
        ,l_hdr_PrcAdj_rec.ATTRIBUTE9
        ,l_hdr_PrcAdj_rec.ATTRIBUTE10
        ,l_hdr_PrcAdj_rec.ATTRIBUTE11
        ,l_hdr_PrcAdj_rec.ATTRIBUTE12
        ,l_hdr_PrcAdj_rec.ATTRIBUTE13
        ,l_hdr_PrcAdj_rec.ATTRIBUTE14
        ,l_hdr_PrcAdj_rec.ATTRIBUTE15
        ,l_hdr_PrcAdj_rec.ORIG_SYS_DISCOUNT_REF
        ,l_hdr_PrcAdj_rec.CHANGE_SEQUENCE
        ,l_hdr_PrcAdj_rec.UPDATE_ALLOWED
        ,l_hdr_PrcAdj_rec.CHANGE_REASON_CODE
        ,l_hdr_PrcAdj_rec.CHANGE_REASON_TEXT
        ,l_hdr_PrcAdj_rec.COST_ID
        ,l_hdr_PrcAdj_rec.TAX_CODE
        ,l_hdr_PrcAdj_rec.TAX_EXEMPT_FLAG
        ,l_hdr_PrcAdj_rec.TAX_EXEMPT_NUMBER
        ,l_hdr_PrcAdj_rec.TAX_EXEMPT_REASON_CODE
        ,l_hdr_PrcAdj_rec.PARENT_ADJUSTMENT_ID
        ,l_hdr_PrcAdj_rec.INVOICED_FLAG
        ,l_hdr_PrcAdj_rec.ESTIMATED_FLAG
        ,l_hdr_PrcAdj_rec.INC_IN_SALES_PERFORMANCE
        ,l_hdr_PrcAdj_rec.SPLIT_ACTION_CODE
        ,l_hdr_PrcAdj_rec.ADJUSTED_AMOUNT
        ,l_hdr_PrcAdj_rec.CHARGE_TYPE_CODE
        ,l_hdr_PrcAdj_rec.CHARGE_SUBTYPE_CODE
        ,l_hdr_PrcAdj_rec.RANGE_BREAK_QUANTITY
        ,l_hdr_PrcAdj_rec.ACCRUAL_CONVERSION_RATE
        ,l_hdr_PrcAdj_rec.PRICING_GROUP_SEQUENCE
        ,l_hdr_PrcAdj_rec.ACCRUAL_FLAG
        ,l_hdr_PrcAdj_rec.LIST_LINE_NO
        ,l_hdr_PrcAdj_rec.SOURCE_SYSTEM_CODE
        ,l_hdr_PrcAdj_rec.BENEFIT_QTY
        ,l_hdr_PrcAdj_rec.BENEFIT_UOM_CODE
        ,l_hdr_PrcAdj_rec.PRINT_ON_INVOICE_FLAG
        ,l_hdr_PrcAdj_rec.EXPIRATION_DATE
        ,l_hdr_PrcAdj_rec.REBATE_TRANSACTION_TYPE_CODE
        ,l_hdr_PrcAdj_rec.REBATE_TRANSACTION_REFERENCE
        ,l_hdr_PrcAdj_rec.REBATE_PAYMENT_SYSTEM_CODE
        ,l_hdr_PrcAdj_rec.REDEEMED_DATE
        ,l_hdr_PrcAdj_rec.REDEEMED_FLAG
        ,l_hdr_PrcAdj_rec.MODIFIER_LEVEL_CODE
        ,l_hdr_PrcAdj_rec.PRICE_BREAK_TYPE_CODE
        ,l_hdr_PrcAdj_rec.SUBSTITUTION_ATTRIBUTE
        ,l_hdr_PrcAdj_rec.PRORATION_TYPE_CODE
        ,l_hdr_PrcAdj_rec.INCLUDE_ON_RETURNS_FLAG
        ,l_hdr_PrcAdj_rec.CREDIT_OR_CHARGE_FLAG;
	EXIT WHEN c_getHdrPrcAdjTbl%NOTFOUND;
  l_hdr_PrcAdj_tbl(l_hdr_PrcAdj_tbl.count+1) := l_hdr_PrcAdj_rec;
  END LOOP;
  CLOSE c_getHdrPrcAdjTbl;
  RETURN l_hdr_PrcAdj_tbl;
END getHdrPrcAdjTbl;

FUNCTION getAllLinesPrcAdjTbl(
  p_quote_hdr_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Tbl_Type
IS
  l_AllLines_PrcAdj_rec     ASO_QUOTE_PUB.Price_Adj_Rec_Type;
  l_AllLines_PrcAdj_tbl     ASO_QUOTE_PUB.Price_Adj_Tbl_Type
                         := ASO_QUOTE_PUB.G_Miss_Price_Adj_Tbl;
  CURSOR c_getAllLinesPrcAdjTbl(l_quote_hdr_id number) IS
  SELECT PRICE_ADJUSTMENT_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,REQUEST_ID
         ,QUOTE_HEADER_ID
         ,QUOTE_LINE_ID
         ,QUOTE_SHIPMENT_ID
         ,MODIFIER_HEADER_ID
         ,MODIFIER_LINE_ID
         ,MODIFIER_LINE_TYPE_CODE
         ,MODIFIER_MECHANISM_TYPE_CODE
         ,MODIFIED_FROM
         ,MODIFIED_TO
         ,OPERAND
         ,ARITHMETIC_OPERATOR
         ,AUTOMATIC_FLAG
         ,UPDATE_ALLOWABLE_FLAG
         ,UPDATED_FLAG
         ,APPLIED_FLAG
         ,ON_INVOICE_FLAG
         ,PRICING_PHASE_ID
         ,ATTRIBUTE_CATEGORY
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ORIG_SYS_DISCOUNT_REF
         ,CHANGE_SEQUENCE
         ,UPDATE_ALLOWED
         ,CHANGE_REASON_CODE
         ,CHANGE_REASON_TEXT
         ,COST_ID
         ,TAX_CODE
         ,TAX_EXEMPT_FLAG
         ,TAX_EXEMPT_NUMBER
         ,TAX_EXEMPT_REASON_CODE
         ,PARENT_ADJUSTMENT_ID
         ,INVOICED_FLAG
         ,ESTIMATED_FLAG
         ,INC_IN_SALES_PERFORMANCE
         ,SPLIT_ACTION_CODE
         ,ADJUSTED_AMOUNT
         ,CHARGE_TYPE_CODE
         ,CHARGE_SUBTYPE_CODE
         ,RANGE_BREAK_QUANTITY
         ,ACCRUAL_CONVERSION_RATE
         ,PRICING_GROUP_SEQUENCE
         ,ACCRUAL_FLAG
         ,LIST_LINE_NO
         ,SOURCE_SYSTEM_CODE
         ,BENEFIT_QTY
         ,BENEFIT_UOM_CODE
         ,PRINT_ON_INVOICE_FLAG
         ,EXPIRATION_DATE
         ,REBATE_TRANSACTION_TYPE_CODE
         ,REBATE_TRANSACTION_REFERENCE
         ,REBATE_PAYMENT_SYSTEM_CODE
         ,REDEEMED_DATE
         ,REDEEMED_FLAG
         ,MODIFIER_LEVEL_CODE
         ,PRICE_BREAK_TYPE_CODE
         ,SUBSTITUTION_ATTRIBUTE
         ,PRORATION_TYPE_CODE
         ,INCLUDE_ON_RETURNS_FLAG
         ,CREDIT_OR_CHARGE_FLAG
  From  ASO_PRICE_ADJUSTMENTS
  Where QUOTE_HEADER_ID = p_quote_hdr_id
  and QUOTE_LINE_ID is not null;

begin
  open c_getAllLinesPrcAdjTbl(p_quote_hdr_id);
  loop
  fetch c_getAllLinesPrcAdjTbl into
        l_AllLines_PrcAdj_rec.PRICE_ADJUSTMENT_ID
        ,l_AllLines_PrcAdj_rec.CREATION_DATE
        ,l_AllLines_PrcAdj_rec.CREATED_BY
        ,l_AllLines_PrcAdj_rec.LAST_UPDATE_DATE
        ,l_AllLines_PrcAdj_rec.LAST_UPDATED_BY
        ,l_AllLines_PrcAdj_rec.LAST_UPDATE_LOGIN
        ,l_AllLines_PrcAdj_rec.PROGRAM_APPLICATION_ID
        ,l_AllLines_PrcAdj_rec.PROGRAM_ID
        ,l_AllLines_PrcAdj_rec.PROGRAM_UPDATE_DATE
        ,l_AllLines_PrcAdj_rec.REQUEST_ID
        ,l_AllLines_PrcAdj_rec.QUOTE_HEADER_ID
        ,l_AllLines_PrcAdj_rec.QUOTE_LINE_ID
        ,l_AllLines_PrcAdj_rec.QUOTE_SHIPMENT_ID
        ,l_AllLines_PrcAdj_rec.MODIFIER_HEADER_ID
        ,l_AllLines_PrcAdj_rec.MODIFIER_LINE_ID
        ,l_AllLines_PrcAdj_rec.MODIFIER_LINE_TYPE_CODE
        ,l_AllLines_PrcAdj_rec.MODIFIER_MECHANISM_TYPE_CODE
        ,l_AllLines_PrcAdj_rec.MODIFIED_FROM
        ,l_AllLines_PrcAdj_rec.MODIFIED_TO
        ,l_AllLines_PrcAdj_rec.OPERAND
        ,l_AllLines_PrcAdj_rec.ARITHMETIC_OPERATOR
        ,l_AllLines_PrcAdj_rec.AUTOMATIC_FLAG
        ,l_AllLines_PrcAdj_rec.UPDATE_ALLOWABLE_FLAG
        ,l_AllLines_PrcAdj_rec.UPDATED_FLAG
        ,l_AllLines_PrcAdj_rec.APPLIED_FLAG
        ,l_AllLines_PrcAdj_rec.ON_INVOICE_FLAG
        ,l_AllLines_PrcAdj_rec.PRICING_PHASE_ID
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE_CATEGORY
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE1
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE2
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE3
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE4
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE5
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE6
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE7
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE8
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE9
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE10
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE11
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE12
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE13
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE14
        ,l_AllLines_PrcAdj_rec.ATTRIBUTE15
        ,l_AllLines_PrcAdj_rec.ORIG_SYS_DISCOUNT_REF
        ,l_AllLines_PrcAdj_rec.CHANGE_SEQUENCE
        ,l_AllLines_PrcAdj_rec.UPDATE_ALLOWED
        ,l_AllLines_PrcAdj_rec.CHANGE_REASON_CODE
        ,l_AllLines_PrcAdj_rec.CHANGE_REASON_TEXT
        ,l_AllLines_PrcAdj_rec.COST_ID
        ,l_AllLines_PrcAdj_rec.TAX_CODE
        ,l_AllLines_PrcAdj_rec.TAX_EXEMPT_FLAG
        ,l_AllLines_PrcAdj_rec.TAX_EXEMPT_NUMBER
        ,l_AllLines_PrcAdj_rec.TAX_EXEMPT_REASON_CODE
        ,l_AllLines_PrcAdj_rec.PARENT_ADJUSTMENT_ID
        ,l_AllLines_PrcAdj_rec.INVOICED_FLAG
        ,l_AllLines_PrcAdj_rec.ESTIMATED_FLAG
        ,l_AllLines_PrcAdj_rec.INC_IN_SALES_PERFORMANCE
        ,l_AllLines_PrcAdj_rec.SPLIT_ACTION_CODE
        ,l_AllLines_PrcAdj_rec.ADJUSTED_AMOUNT
        ,l_AllLines_PrcAdj_rec.CHARGE_TYPE_CODE
        ,l_AllLines_PrcAdj_rec.CHARGE_SUBTYPE_CODE
        ,l_AllLines_PrcAdj_rec.RANGE_BREAK_QUANTITY
        ,l_AllLines_PrcAdj_rec.ACCRUAL_CONVERSION_RATE
        ,l_AllLines_PrcAdj_rec.PRICING_GROUP_SEQUENCE
        ,l_AllLines_PrcAdj_rec.ACCRUAL_FLAG
        ,l_AllLines_PrcAdj_rec.LIST_LINE_NO
        ,l_AllLines_PrcAdj_rec.SOURCE_SYSTEM_CODE
        ,l_AllLines_PrcAdj_rec.BENEFIT_QTY
        ,l_AllLines_PrcAdj_rec.BENEFIT_UOM_CODE
        ,l_AllLines_PrcAdj_rec.PRINT_ON_INVOICE_FLAG
        ,l_AllLines_PrcAdj_rec.EXPIRATION_DATE
        ,l_AllLines_PrcAdj_rec.REBATE_TRANSACTION_TYPE_CODE
        ,l_AllLines_PrcAdj_rec.REBATE_TRANSACTION_REFERENCE
        ,l_AllLines_PrcAdj_rec.REBATE_PAYMENT_SYSTEM_CODE
        ,l_AllLines_PrcAdj_rec.REDEEMED_DATE
        ,l_AllLines_PrcAdj_rec.REDEEMED_FLAG
        ,l_AllLines_PrcAdj_rec.MODIFIER_LEVEL_CODE
        ,l_AllLines_PrcAdj_rec.PRICE_BREAK_TYPE_CODE
        ,l_AllLines_PrcAdj_rec.SUBSTITUTION_ATTRIBUTE
        ,l_AllLines_PrcAdj_rec.PRORATION_TYPE_CODE
        ,l_AllLines_PrcAdj_rec.INCLUDE_ON_RETURNS_FLAG
        ,l_AllLines_PrcAdj_rec.CREDIT_OR_CHARGE_FLAG;
	EXIT WHEN c_getAllLinesPrcAdjTbl%NOTFOUND;
  l_AllLines_PrcAdj_tbl(l_AllLines_PrcAdj_tbl.count+1) := l_AllLines_PrcAdj_rec;
  END LOOP;
  CLOSE c_getAllLinesPrcAdjTbl;
  RETURN l_AllLines_PrcAdj_tbl;
END getAllLinesPrcAdjTbl;

FUNCTION getPrcAdjIndexFromPrcAdjId(
  p_price_adjustment_id     IN NUMBER
  ,p_Price_Adjustment_tbl           IN aso_quote_pub.Price_Adj_Tbl_Type
) RETURN NUMBER
IS
BEGIN

  FOR i IN 1..p_Price_Adjustment_tbl.count LOOP
     IF p_price_adjustment_id = p_Price_Adjustment_tbl(i).price_adjustment_id then
        RETURN i;
     END IF;


  END LOOP;

  RETURN FND_API.G_MISS_NUM;
END getPrcAdjIndexFromPrcAdjId;


FUNCTION getLinePrcAdjRelTbl(
  p_price_adjustment_id              IN  NUMBER
) RETURN  ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
IS
  l_line_PrcAdjRel_rec     ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_Type;
  l_line_PrcAdjRel_tbl     ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type
                         := ASO_QUOTE_PUB.G_Miss_Price_Adj_Rltship_Tbl;
  CURSOR c_getLinePrcAdjRelTbl(l_price_adjustment_id number) IS
  SELECT ADJ_RELATIONSHIP_ID
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,REQUEST_ID
         ,PROGRAM_APPLICATION_ID
         ,PROGRAM_ID
         ,PROGRAM_UPDATE_DATE
         ,QUOTE_LINE_ID
         ,QUOTE_SHIPMENT_ID
         ,PRICE_ADJUSTMENT_ID
         ,RLTD_PRICE_ADJ_ID
  From  ASO_PRICE_ADJ_RELATIONSHIPS
  Where RLTD_PRICE_ADJ_ID = p_price_adjustment_id;

begin
  open c_getLinePrcAdjRelTbl(p_price_adjustment_id);
  loop
  fetch c_getLinePrcAdjRelTbl into
        l_line_PrcAdjRel_rec.ADJ_RELATIONSHIP_ID
        ,l_line_PrcAdjRel_rec.CREATION_DATE
        ,l_line_PrcAdjRel_rec.CREATED_BY
        ,l_line_PrcAdjRel_rec.LAST_UPDATE_DATE
        ,l_line_PrcAdjRel_rec.LAST_UPDATED_BY
        ,l_line_PrcAdjRel_rec.LAST_UPDATE_LOGIN
        ,l_line_PrcAdjRel_rec.REQUEST_ID
        ,l_line_PrcAdjRel_rec.PROGRAM_APPLICATION_ID
        ,l_line_PrcAdjRel_rec.PROGRAM_ID
        ,l_line_PrcAdjRel_rec.PROGRAM_UPDATE_DATE
        ,l_line_PrcAdjRel_rec.QUOTE_LINE_ID
        ,l_line_PrcAdjRel_rec.QUOTE_SHIPMENT_ID
        ,l_line_PrcAdjRel_rec.PRICE_ADJUSTMENT_ID
        ,l_line_PrcAdjRel_rec.RLTD_PRICE_ADJ_ID;
	EXIT WHEN c_getLinePrcAdjRelTbl%NOTFOUND;
  l_line_PrcAdjRel_tbl(l_line_PrcAdjRel_tbl.count+1) := l_line_PrcAdjRel_rec;
  END LOOP;
  CLOSE c_getLinePrcAdjRelTbl;
  RETURN l_line_PrcAdjRel_tbl;
END getLinePrcAdjRelTbl;


FUNCTION getLineTbl(
  p_quote_header_Id            IN  NUMBER
) RETURN  ASO_QUOTE_PUB.QTE_LINE_TBL_TYPE
IS

  l_qte_line_rec     ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
  l_qte_line_tbl     ASO_QUOTE_PUB.QTE_LINE_TBL_TYPE;
  CURSOR c_getlinetbl(l_quote_header_id number) IS
  SELECT l.QUOTE_LINE_ID
	 ,l.CREATION_DATE
         ,l.CREATED_BY
         ,l.LAST_UPDATE_DATE
         ,l.LAST_UPDATED_BY
         ,l.LAST_UPDATE_LOGIN
         ,l.REQUEST_ID
         ,l.PROGRAM_APPLICATION_ID
         ,l.PROGRAM_ID
         ,l.PROGRAM_UPDATE_DATE
         ,l.QUOTE_HEADER_ID
         ,l.ORG_ID
         ,l.LINE_CATEGORY_CODE
         ,l.ITEM_TYPE_CODE
         ,l.LINE_NUMBER
         ,l.START_DATE_ACTIVE
         ,l.END_DATE_ACTIVE
         ,l.ORDER_LINE_TYPE_ID
         ,l.INVOICE_TO_PARTY_SITE_ID
         ,l.INVOICE_TO_PARTY_ID
         ,l.ORGANIZATION_ID
         ,l.INVENTORY_ITEM_ID
         ,l.QUANTITY
         ,l.UOM_CODE
         ,l.MARKETING_SOURCE_CODE_ID
         ,l.PRICE_LIST_ID
         ,l.PRICE_LIST_LINE_ID
         ,l.CURRENCY_CODE
         ,l.LINE_LIST_PRICE
         ,l.LINE_ADJUSTED_AMOUNT
         ,l.LINE_ADJUSTED_PERCENT
         ,l.LINE_QUOTE_PRICE
         ,l.RELATED_ITEM_ID
         ,l.ITEM_RELATIONSHIP_TYPE
         ,l.ACCOUNTING_RULE_ID
         ,l.INVOICING_RULE_ID
         ,l.SPLIT_SHIPMENT_FLAG
         ,l.BACKORDER_FLAG
         ,l.ATTRIBUTE_CATEGORY   -- bug 6015035, scnagara, Uncommented the code from ATTRIBUTE_CATEGORY to ATTRIBUTE15
         ,l.ATTRIBUTE1
         ,l.ATTRIBUTE2
         ,l.ATTRIBUTE3
         ,l.ATTRIBUTE4
         ,l.ATTRIBUTE5
         ,l.ATTRIBUTE6
         ,l.ATTRIBUTE7
         ,l.ATTRIBUTE8
         ,l.ATTRIBUTE9
         ,l.ATTRIBUTE10
         ,l.ATTRIBUTE11
         ,l.ATTRIBUTE12
         ,l.ATTRIBUTE13
         ,l.ATTRIBUTE14
         ,l.ATTRIBUTE15    --bug# 3395318
         ,l.pricing_line_type_indicator
  From  aso_quote_lines l
  Where l.QUOTE_HEADER_ID = l_QUOTE_HEADER_ID
  Order by l.quote_line_id;
begin

  open c_getlinetbl(p_quote_header_id);
  loop
  fetch c_getlinetbl into
   	l_qte_line_rec.QUOTE_LINE_ID
        ,l_qte_line_rec.CREATION_DATE
        ,l_qte_line_rec.CREATED_BY
        ,l_qte_line_rec.LAST_UPDATE_DATE
        ,l_qte_line_rec.LAST_UPDATED_BY
        ,l_qte_line_rec.LAST_UPDATE_LOGIN
        ,l_qte_line_rec.REQUEST_ID
        ,l_qte_line_rec.PROGRAM_APPLICATION_ID
        ,l_qte_line_rec.PROGRAM_ID
        ,l_qte_line_rec.PROGRAM_UPDATE_DATE
        ,l_qte_line_rec.QUOTE_HEADER_ID
        ,l_qte_line_rec.ORG_ID
        ,l_qte_line_rec.LINE_CATEGORY_CODE
        ,l_qte_line_rec.ITEM_TYPE_CODE
        ,l_qte_line_rec.LINE_NUMBER
        ,l_qte_line_rec.START_DATE_ACTIVE
        ,l_qte_line_rec.END_DATE_ACTIVE
        ,l_qte_line_rec.ORDER_LINE_TYPE_ID
        ,l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID
        ,l_qte_line_rec.INVOICE_TO_PARTY_ID
        ,l_qte_line_rec.ORGANIZATION_ID
        ,l_qte_line_rec.INVENTORY_ITEM_ID
        ,l_qte_line_rec.QUANTITY
        ,l_qte_line_rec.UOM_CODE
        ,l_qte_line_rec.MARKETING_SOURCE_CODE_ID
        ,l_qte_line_rec.PRICE_LIST_ID
        ,l_qte_line_rec.PRICE_LIST_LINE_ID
        ,l_qte_line_rec.CURRENCY_CODE
        ,l_qte_line_rec.LINE_LIST_PRICE
        ,l_qte_line_rec.LINE_ADJUSTED_AMOUNT
        ,l_qte_line_rec.LINE_ADJUSTED_PERCENT
        ,l_qte_line_rec.LINE_QUOTE_PRICE
        ,l_qte_line_rec.RELATED_ITEM_ID
        ,l_qte_line_rec.ITEM_RELATIONSHIP_TYPE
        ,l_qte_line_rec.ACCOUNTING_RULE_ID
        ,l_qte_line_rec.INVOICING_RULE_ID
        ,l_qte_line_rec.SPLIT_SHIPMENT_FLAG
        ,l_qte_line_rec.BACKORDER_FLAG
        ,l_qte_line_rec.ATTRIBUTE_CATEGORY  -- bug 6015035, scnagara, Uncommented the code
        ,l_qte_line_rec.ATTRIBUTE1          -- from ATTRIBUTE_CATEGORY to ATTRIBUTE15
        ,l_qte_line_rec.ATTRIBUTE2
        ,l_qte_line_rec.ATTRIBUTE3
        ,l_qte_line_rec.ATTRIBUTE4
        ,l_qte_line_rec.ATTRIBUTE5
        ,l_qte_line_rec.ATTRIBUTE6
        ,l_qte_line_rec.ATTRIBUTE7
        ,l_qte_line_rec.ATTRIBUTE8
        ,l_qte_line_rec.ATTRIBUTE9
        ,l_qte_line_rec.ATTRIBUTE10
        ,l_qte_line_rec.ATTRIBUTE11
        ,l_qte_line_rec.ATTRIBUTE12
        ,l_qte_line_rec.ATTRIBUTE13
        ,l_qte_line_rec.ATTRIBUTE14
        ,l_qte_line_rec.ATTRIBUTE15     --bug# 3395318
        ,l_qte_line_rec.pricing_line_type_indicator;
	EXIT WHEN c_getlinetbl%NOTFOUND;
        l_qte_line_tbl(l_qte_line_tbl.count+1) := l_qte_line_rec;
   END LOOP;
   CLOSE  c_getlinetbl;
   RETURN l_qte_line_tbl;
END getLineTbl;


FUNCTION getLineRec(
  p_qte_line_id            IN  NUMBER
) RETURN  ASO_QUOTE_PUB.QTE_LINE_REC_TYPE
IS

  l_qte_line_rec     ASO_QUOTE_PUB.QTE_LINE_REC_TYPE;
  CURSOR c_getlineRec(l_qte_line_id number) IS
  SELECT l.QUOTE_LINE_ID
	 ,l.CREATION_DATE
         ,l.CREATED_BY
         ,l.LAST_UPDATE_DATE
         ,l.LAST_UPDATED_BY
         ,l.LAST_UPDATE_LOGIN
         ,l.REQUEST_ID
         ,l.PROGRAM_APPLICATION_ID
         ,l.PROGRAM_ID
         ,l.PROGRAM_UPDATE_DATE
         ,l.QUOTE_HEADER_ID
         ,l.ORG_ID
         ,l.LINE_CATEGORY_CODE
         ,l.ITEM_TYPE_CODE
         ,l.LINE_NUMBER
         ,l.START_DATE_ACTIVE
         ,l.END_DATE_ACTIVE
         ,l.ORDER_LINE_TYPE_ID
         ,l.INVOICE_TO_PARTY_SITE_ID
         ,l.INVOICE_TO_PARTY_ID
         ,l.ORGANIZATION_ID
         ,l.INVENTORY_ITEM_ID
         ,l.QUANTITY
         ,l.UOM_CODE
         ,l.MARKETING_SOURCE_CODE_ID
         ,l.PRICE_LIST_ID
         ,l.PRICE_LIST_LINE_ID
         ,l.CURRENCY_CODE
         ,l.LINE_LIST_PRICE
         ,l.LINE_ADJUSTED_AMOUNT
         ,l.LINE_ADJUSTED_PERCENT
         ,l.LINE_QUOTE_PRICE
         ,l.RELATED_ITEM_ID
         ,l.ITEM_RELATIONSHIP_TYPE
         ,l.ACCOUNTING_RULE_ID
         ,l.INVOICING_RULE_ID
         ,l.SPLIT_SHIPMENT_FLAG
         ,l.BACKORDER_FLAG
         ,l.ATTRIBUTE_CATEGORY
         ,l.ATTRIBUTE1
         ,l.ATTRIBUTE2
         ,l.ATTRIBUTE3
         ,l.ATTRIBUTE4
         ,l.ATTRIBUTE5
         ,l.ATTRIBUTE6
         ,l.ATTRIBUTE7
         ,l.ATTRIBUTE8
         ,l.ATTRIBUTE9
         ,l.ATTRIBUTE10
         ,l.ATTRIBUTE11
         ,l.ATTRIBUTE12
         ,l.ATTRIBUTE13
         ,l.ATTRIBUTE14
         ,l.ATTRIBUTE15
         ,l.MINISITE_ID
  From  aso_quote_lines l
  Where l.QUOTE_LINE_ID = l_QTE_LINE_ID;
begin

  open c_getlineRec(p_qte_line_id);
  fetch c_getlineRec into
   	l_qte_line_rec.QUOTE_LINE_ID
        ,l_qte_line_rec.CREATION_DATE
        ,l_qte_line_rec.CREATED_BY
        ,l_qte_line_rec.LAST_UPDATE_DATE
        ,l_qte_line_rec.LAST_UPDATED_BY
        ,l_qte_line_rec.LAST_UPDATE_LOGIN
        ,l_qte_line_rec.REQUEST_ID
        ,l_qte_line_rec.PROGRAM_APPLICATION_ID
        ,l_qte_line_rec.PROGRAM_ID
        ,l_qte_line_rec.PROGRAM_UPDATE_DATE
        ,l_qte_line_rec.QUOTE_HEADER_ID
        ,l_qte_line_rec.ORG_ID
        ,l_qte_line_rec.LINE_CATEGORY_CODE
        ,l_qte_line_rec.ITEM_TYPE_CODE
        ,l_qte_line_rec.LINE_NUMBER
        ,l_qte_line_rec.START_DATE_ACTIVE
        ,l_qte_line_rec.END_DATE_ACTIVE
        ,l_qte_line_rec.ORDER_LINE_TYPE_ID
        ,l_qte_line_rec.INVOICE_TO_PARTY_SITE_ID
        ,l_qte_line_rec.INVOICE_TO_PARTY_ID
        ,l_qte_line_rec.ORGANIZATION_ID
        ,l_qte_line_rec.INVENTORY_ITEM_ID
        ,l_qte_line_rec.QUANTITY
        ,l_qte_line_rec.UOM_CODE
        ,l_qte_line_rec.MARKETING_SOURCE_CODE_ID
        ,l_qte_line_rec.PRICE_LIST_ID
        ,l_qte_line_rec.PRICE_LIST_LINE_ID
        ,l_qte_line_rec.CURRENCY_CODE
        ,l_qte_line_rec.LINE_LIST_PRICE
        ,l_qte_line_rec.LINE_ADJUSTED_AMOUNT
        ,l_qte_line_rec.LINE_ADJUSTED_PERCENT
        ,l_qte_line_rec.LINE_QUOTE_PRICE
        ,l_qte_line_rec.RELATED_ITEM_ID
        ,l_qte_line_rec.ITEM_RELATIONSHIP_TYPE
        ,l_qte_line_rec.ACCOUNTING_RULE_ID
        ,l_qte_line_rec.INVOICING_RULE_ID
        ,l_qte_line_rec.SPLIT_SHIPMENT_FLAG
        ,l_qte_line_rec.BACKORDER_FLAG
        ,l_qte_line_rec.ATTRIBUTE_CATEGORY
        ,l_qte_line_rec.ATTRIBUTE1
        ,l_qte_line_rec.ATTRIBUTE2
        ,l_qte_line_rec.ATTRIBUTE3
        ,l_qte_line_rec.ATTRIBUTE4
        ,l_qte_line_rec.ATTRIBUTE5
        ,l_qte_line_rec.ATTRIBUTE6
        ,l_qte_line_rec.ATTRIBUTE7
        ,l_qte_line_rec.ATTRIBUTE8
        ,l_qte_line_rec.ATTRIBUTE9
        ,l_qte_line_rec.ATTRIBUTE10
        ,l_qte_line_rec.ATTRIBUTE11
        ,l_qte_line_rec.ATTRIBUTE12
        ,l_qte_line_rec.ATTRIBUTE13
        ,l_qte_line_rec.ATTRIBUTE14
        ,l_qte_line_rec.ATTRIBUTE15
        ,l_qte_line_rec.MINISITE_ID;
   CLOSE  c_getlineRec;
   RETURN l_qte_line_rec;
END getLineRec;

FUNCTION getHeaderRec(
  p_quote_header_Id            IN  NUMBER
) RETURN  ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE
IS
  CURSOR c_getHeaderRec(p_quote_header_id NUMBER) IS
  SELECT  last_update_date
	,ORG_ID
	,QUOTE_NAME
	,QUOTE_NUMBER
	,QUOTE_VERSION
	,QUOTE_STATUS_ID
	,QUOTE_SOURCE_CODE
	,QUOTE_EXPIRATION_DATE
	,PRICE_FROZEN_DATE
	,QUOTE_PASSWORD
	,ORIGINAL_SYSTEM_REFERENCE
	,PARTY_ID
	,CUST_ACCOUNT_ID
	,ORG_CONTACT_ID
	,PHONE_ID
	,INVOICE_TO_PARTY_SITE_ID
	,INVOICE_TO_PARTY_ID
	,ORIG_MKTG_SOURCE_CODE_ID
	,MARKETING_SOURCE_CODE_ID
	,ORDER_TYPE_ID
	,QUOTE_CATEGORY_CODE
	,ORDERED_DATE
	,ACCOUNTING_RULE_ID
	,INVOICING_RULE_ID
	,EMPLOYEE_PERSON_ID
	,PRICE_LIST_ID
	,CURRENCY_CODE
	,TOTAL_LIST_PRICE
	,TOTAL_ADJUSTED_AMOUNT
	,TOTAL_ADJUSTED_PERCENT
	,TOTAL_TAX
	,TOTAL_SHIPPING_CHARGE
	,SURCHARGE
	,TOTAL_QUOTE_PRICE
	,PAYMENT_AMOUNT
	,EXCHANGE_RATE
	,EXCHANGE_TYPE_CODE
	,EXCHANGE_RATE_DATE
	,CONTRACT_ID
	,SALES_CHANNEL_CODE
	,ORDER_ID
  FROM aso_quote_headers
  WHERE quote_header_id = p_quote_header_id;

  l_qte_header_rec     ASO_QUOTE_PUB.QTE_HEADER_REC_TYPE;


BEGIN
  l_qte_header_rec.quote_header_id := p_quote_header_id;

  open c_getHeaderRec(l_qte_header_rec.quote_header_id);
  fetch c_getHeaderRec into
	l_qte_header_rec.last_update_date
	,l_qte_header_rec.ORG_ID
	,l_qte_header_rec.QUOTE_NAME
	,l_qte_header_rec.QUOTE_NUMBER
	,l_qte_header_rec.QUOTE_VERSION
	,l_qte_header_rec.QUOTE_STATUS_ID
	,l_qte_header_rec.QUOTE_SOURCE_CODE
	,l_qte_header_rec.QUOTE_EXPIRATION_DATE
	,l_qte_header_rec.PRICE_FROZEN_DATE
	,l_qte_header_rec.QUOTE_PASSWORD
	,l_qte_header_rec.ORIGINAL_SYSTEM_REFERENCE
	,l_qte_header_rec.PARTY_ID
	,l_qte_header_rec.CUST_ACCOUNT_ID
	,l_qte_header_rec.ORG_CONTACT_ID
	,l_qte_header_rec.PHONE_ID
	,l_qte_header_rec.INVOICE_TO_PARTY_SITE_ID
	,l_qte_header_rec.INVOICE_TO_PARTY_ID
	,l_qte_header_rec.ORIG_MKTG_SOURCE_CODE_ID
	,l_qte_header_rec.MARKETING_SOURCE_CODE_ID
	,l_qte_header_rec.ORDER_TYPE_ID
	,l_qte_header_rec.QUOTE_CATEGORY_CODE
	,l_qte_header_rec.ORDERED_DATE
	,l_qte_header_rec.ACCOUNTING_RULE_ID
	,l_qte_header_rec.INVOICING_RULE_ID
	,l_qte_header_rec.EMPLOYEE_PERSON_ID
	,l_qte_header_rec.PRICE_LIST_ID
	,l_qte_header_rec.CURRENCY_CODE
	,l_qte_header_rec.TOTAL_LIST_PRICE
	,l_qte_header_rec.TOTAL_ADJUSTED_AMOUNT
	,l_qte_header_rec.TOTAL_ADJUSTED_PERCENT
	,l_qte_header_rec.TOTAL_TAX
	,l_qte_header_rec.TOTAL_SHIPPING_CHARGE
	,l_qte_header_rec.SURCHARGE
	,l_qte_header_rec.TOTAL_QUOTE_PRICE
	,l_qte_header_rec.PAYMENT_AMOUNT
	,l_qte_header_rec.EXCHANGE_RATE
	,l_qte_header_rec.EXCHANGE_TYPE_CODE
	,l_qte_header_rec.EXCHANGE_RATE_DATE
	,l_qte_header_rec.CONTRACT_ID
	,l_qte_header_rec.SALES_CHANNEL_CODE
	,l_qte_header_rec.ORDER_ID;
  CLOSE c_getHeaderRec;

  RETURN l_qte_header_rec;

END getHeaderRec;

FUNCTION getHeaderPaymentTbl(
  p_quote_header_Id            IN  NUMBER
) RETURN ASO_QUOTE_PUB.PAYMENT_TBL_TYPE
IS

  l_index                       number :=1;
  l_payment_tbl              aso_quote_pub.payment_tbl_type;
  l_payment_rec              aso_quote_pub.payment_rec_type;


  CURSOR c_getPaymentRec(p_quote_header_id number) is
  SELECT payment_id
         ,creation_date
         ,created_by
         ,last_update_date
         ,last_updated_by
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date
         ,quote_header_id
         ,quote_line_id
         ,payment_type_code
         ,payment_ref_number
         ,payment_option
         ,payment_term_id
         ,credit_card_code
         ,credit_card_holder_name
         ,credit_card_expiration_date
         ,credit_card_approval_code
         ,credit_card_approval_date
         ,payment_amount
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
	    ,trxn_extension_id
        FROM ASO_PAYMENTS
        WHERE quote_header_id = p_quote_header_id
        AND quote_line_id IS NULL;

  CURSOR c_getInstrumentId(p_trxn_extn_id number)  is
  SELECT instr_assignment_id
--bug 10016159   FROM IBY_TRXN_EXTENSIONS_V
         FROM IBY_EXTN_INSTR_DETAILS_V
	    WHERE trxn_extension_id = p_trxn_extn_id;

BEGIN

   OPEN c_getPaymentRec(p_quote_header_id);
   LOOP
      FETCH c_getPaymentRec INTO
         l_payment_rec.payment_id
         ,l_payment_rec.creation_date
         ,l_payment_rec.created_by
         ,l_payment_rec.last_update_date
         ,l_payment_rec.last_updated_by
         ,l_payment_rec.last_update_login
         ,l_payment_rec.request_id
         ,l_payment_rec.program_application_id
         ,l_payment_rec.program_id
         ,l_payment_rec.program_update_date
         ,l_payment_rec.quote_header_id
         ,l_payment_rec.quote_line_id
         ,l_payment_rec.payment_type_code
         ,l_payment_rec.payment_ref_number
         ,l_payment_rec.payment_option
         ,l_payment_rec.payment_term_id
         ,l_payment_rec.credit_card_code
         ,l_payment_rec.credit_card_holder_name
         ,l_payment_rec.credit_card_expiration_date
         ,l_payment_rec.credit_card_approval_code
         ,l_payment_rec.credit_card_approval_date
         ,l_payment_rec.payment_amount
         ,l_payment_rec.attribute_category
         ,l_payment_rec.attribute1
         ,l_payment_rec.attribute2
         ,l_payment_rec.attribute3
         ,l_payment_rec.attribute4
         ,l_payment_rec.attribute5
         ,l_payment_rec.attribute6
         ,l_payment_rec.attribute7
         ,l_payment_rec.attribute8
         ,l_payment_rec.attribute9
         ,l_payment_rec.attribute10
         ,l_payment_rec.attribute11
         ,l_payment_rec.attribute12
         ,l_payment_rec.attribute13
         ,l_payment_rec.attribute14
         ,l_payment_rec.attribute15
	    ,l_payment_rec.trxn_extension_id;
      IF l_payment_rec.trxn_extension_id IS NOT NULL THEN
        OPEN c_getInstrumentId(l_payment_rec.trxn_extension_id);
        LOOP
          FETCH c_getInstrumentId INTO l_payment_rec.instr_assignment_id;
          EXIT WHEN c_getInstrumentId%NOTFOUND;
        END LOOP;
	   CLOSE c_getInstrumentId;
      END IF;
      EXIT WHEN c_getPaymentRec%NOTFOUND;
      l_payment_tbl(l_index) := l_payment_rec;
      l_index := l_index +1;
   END LOOP;
   CLOSE c_getPaymentRec;

   RETURN l_payment_tbl;
END getHeaderPaymentTbl;

FUNCTION getShareePrivilege(
  p_quote_header_Id            IN  NUMBER
  ,p_sharee_number             IN  NUMBER
) RETURN VARCHAR2
IS
  l_privilege_type_code        VARCHAR2(100) := 'X';
BEGIN

  SELECT update_privilege_type_code
  INTO l_privilege_type_code
  FROM IBE_SH_QUOTE_ACCESS
  WHERE quote_header_id = p_quote_header_id
  AND quote_sharee_number = p_sharee_number;

  RETURN l_privilege_type_code;

EXCEPTION
   WHEN  TOO_MANY_ROWS  THEN
     RETURN  'XM';
   WHEN NO_DATA_FOUND  THEN
     RETURN  'XN';
END getShareePrivilege;

FUNCTION getUserType(
  p_partyId  IN Varchar2
) RETURN VARCHAR2
IS
  l_PartyType       Varchar2(30);

  Cursor  c_hz_parties(c_party_id NUMBER) IS
    SELECT    party_type
	  FROM	  hz_parties
	  WHERE	  party_id = c_party_id;
  c_hz_parties_rec  c_hz_parties%rowtype;

BEGIN
    FOR c_hz_parties_rec IN c_hz_parties(p_partyId)  LOOP
      l_PartyType  := rtrim(c_hz_parties_rec.party_type);
    END LOOP;

    If (l_PartyType = 'PERSON') Then
      return 'B2C';
    else
      return 'B2B';
    End If;

END getUserType;

PROCEDURE validateQuoteLastUpdateDate(
  p_api_version_number      IN  NUMBER
  ,p_quote_header_id        IN  NUMBER
  ,p_last_update_date       IN  DATE
  ,X_Return_Status          OUT NOCOPY VARCHAR2
  ,X_Msg_Count              OUT NOCOPY NUMBER
  ,X_Msg_Data               OUT NOCOPY VARCHAR2
)
IS
  l_api_name	            CONSTANT VARCHAR2(30) := 'validateQuoteLastUpdateDate';
  l_api_version             CONSTANT NUMBER 	:= 1.0;
  l_last_update_date    DATE;
BEGIN
  SAVEPOINT validateLastUpdate_pvt;
  IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
        	    	    	    	P_Api_Version_Number,
   	       	    	 		l_api_name,
		    	    	    	G_PKG_NAME )
  THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_last_update_date  :=IBE_Quote_Misc_pvt.getQuoteLastUpdatedate(p_quote_header_id);
  if (l_last_update_date <> p_last_update_date) then
           -- raise error
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_SC_QUOTE_NEED_REFRESH');
	 FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;   -- need error message
  end if;

     -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected exception in IBE_QUOTE_MISC_PVT.ValidateQuotelastUpdateDate');
    END IF;
    ROLLBACK TO validateLastUpdate_pvt;
	x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unexpected exception in IBE_QUOTE_MISC_PVT.ValidateQuotelastUpdateDate');
    END IF;
    ROLLBACK TO validateLastUpdate_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown exception in IBE_QUOTE_MISC_PVT.ValidateQuotelastUpdateDate');
    END IF;
    ROLLBACK TO validateLastUpdate_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
        	FND_MSG_PUB.Add_Exc_Msg
    	    	(	G_PKG_NAME,
    	    		l_api_name
	    	);
	END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END validateQuoteLastUpdateDate;


PROCEDURE getQuoteOwner(
  p_api_version_number      IN  NUMBER
  ,p_quote_header_Id	    IN 	NUMBER

  ,x_party_id		    OUT NOCOPY	NUMBER
  ,x_cust_account_id	    OUT NOCOPY NUMBER
  ,X_Return_Status          OUT NOCOPY VARCHAR2
  ,X_Msg_Count              OUT NOCOPY NUMBER
  ,X_Msg_Data               OUT NOCOPY VARCHAR2
)
is
  l_api_name                CONSTANT VARCHAR2(30) := 'getQuoteOwner';
  l_api_version             CONSTANT NUMBER 	  := 1.0;

  l_party_id               number := FND_API.G_MISS_NUM;
  l_cust_account_id        number := FND_API.G_MISS_NUM;

  CURSOR getuserinfo(p_quote_header_id NUMBER) IS
  SELECT party_id, cust_account_id
  FROM aso_quote_headers
  WHERE quote_header_id = p_quote_header_id;

BEGIN
   SAVEPOINT getQuoteOwner_pvt;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
        	    	    	    	 	P_Api_Version_Number,
   	       	    	 			l_api_name,
		    	    	    	    	G_PKG_NAME )
   THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body

   open getuserinfo(p_quote_header_id);
   fetch getuserinfo into l_party_id
                          ,l_cust_account_id;
   close getuserinfo;

   IF (l_party_id = FND_API.G_MISS_NUM OR l_party_id IS NULL
       OR l_cust_account_id = FND_API.G_MISS_NUM OR l_cust_account_id IS NULL) THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_SC_NO_QUOTE_OWNER');
	     FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- End of API body.
   x_party_id        := l_party_id;
   x_cust_account_id := l_cust_account_id;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (     p_encoded => FND_API.G_FALSE,
	 p_count   =>      x_msg_count,
         p_data    =>      x_msg_data
   );



EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected exception in IBE_QUOTE_MISC_PVT.getQuoteOwner');
    END IF;

      ROLLBACK to getQuoteOwner_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('uNExpected exception in IBE_QUOTE_MISC_PVT.getQuoteOwner');
    END IF;
    ROLLBACK to getQuoteOwner_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown exception in IBE_QUOTE_MISC_PVT.getQuoteOwner');
    END IF;
    ROLLBACK to getQuoteOwner_pvt;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  	IF 	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                               l_api_name);
	END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END getQuoteOwner;


PROCEDURE Get_Shared_Quote(
   p_api_version_number IN  NUMBER                         ,
   p_quote_password     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number       IN  NUMBER                         ,
   p_quote_version      IN  NUMBER   := FND_API.G_MISS_NUM ,
   x_quote_header_id    OUT NOCOPY NUMBER                         ,
   x_last_update_date   OUT NOCOPY DATE                           ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT VARCHAR2(30) := 'getshareeQuote';
  l_api_version CONSTANT NUMBER       := 1.0;

  l_quote_version    NUMBER;
  l_quote_header_id  NUMBER := FND_API.G_MISS_NUM;
  l_last_update_date DATE   := FND_API.G_MISS_DATE;

  l_sql1 VARCHAR2(200) :=
     'SELECT quote_header_id,
             last_update_date
      FROM aso_quote_headers
      WHERE quote_number  = :1
        AND quote_version = :2 ';

  l_sql2 VARCHAR2(100) := 'AND quote_password = :3';
BEGIN
   SAVEPOINT get_shared_quote;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version,
        	    	    	    	  p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   l_quote_version := p_quote_version;

   IF l_quote_version IS NULL
   OR l_quote_version = FND_API.G_MISS_NUM THEN
      SELECT MAX(quote_version)
      INTO l_quote_version
      FROM aso_quote_headers
      WHERE quote_number = p_quote_number;
   END IF;

   IF p_quote_password IS NULL
   OR p_quote_password = FND_API.G_MISS_CHAR THEN
      EXECUTE IMMEDIATE l_sql1
      INTO l_quote_header_id, l_last_update_date
      USING p_quote_number, l_quote_version;
   ELSE
      EXECUTE IMMEDIATE l_sql1 || l_sql2
      INTO l_quote_header_id, l_last_update_date
      USING p_quote_number, l_quote_version, p_quote_password;
   END IF;

   IF l_quote_header_id IS NULL
   OR l_quote_header_id = FND_API.G_MISS_NUM THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_SC_NO_SHARE_QUOTE');
         FND_MSG_PUB.ADD;
      END IF;

      RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_quote_header_id  := l_quote_header_id;
   x_last_update_date := l_last_update_date;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected exception in IBE_QUOTE_MISC_PVT.get_shared_quote');
    END IF;
    ROLLBACK to get_shared_quote;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unexpected exception in IBE_QUOTE_MISC_PVT.get_shared_quote');
    END IF;
    ROLLBACK to get_shared_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown exception in IBE_QUOTE_MISC_PVT.get_shared_quote');
    END IF;
    ROLLBACK to get_shared_quote;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Get_Shared_Quote;


-- direct entry
-- load inventory_item_ids based on customer number
PROCEDURE Load_Item_IDs(
   p_api_version           IN  NUMBER   := 1              ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_cust_id               IN  NUMBER                     ,
   p_cust_item_number_tbl  IN  jtf_varchar2_table_100     ,
   p_organization_id       IN  NUMBER                     ,
   p_minisite_id	   IN  NUMBER			  ,
   x_inventory_item_id_tbl OUT NOCOPY jtf_number_table           ,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(30) := 'Load_Item_IDs';
  l_api_version CONSTANT  NUMBER       := 1.0;

  l_error_code                  VARCHAR2(30);
  l_error_flag                  VARCHAR2(30);
  l_error_message               VARCHAR2(300);

  l_attribute_value             VARCHAR2(30);
  l_count                       NUMBER;
  l_item_exists			NUMBER;
  l_inventory_item_id		NUMBER;
BEGIN
   /*inv_debug.message('ssia', 'customer id is ' || p_cust_id);
   inv_debug.message('ssia', 'p_organization_id is ' || p_organization_id);
   inv_debug.message('ssia', 'p_minisite_id is ' || p_minisite_id);*/

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name   ,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt.Load_Item_IDs(+)...');
   END IF;

   l_count                   := p_cust_item_number_tbl.COUNT;

   x_inventory_item_id_Tbl   := JTF_NUMBER_TABLE();
   x_inventory_item_id_Tbl.extend(l_count);


   FOR i IN 1..l_count LOOP
      IF p_cust_item_number_tbl(i) IS NOT NULL THEN
         --inv_debug.message('ssia', 'p_cust_item_number is ' || p_cust_item_number_tbl(i));

         -- get inventory_item_id for each customer_item_number
         INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
            z_customer_id          => p_cust_id                ,
            z_customer_item_number => p_cust_item_number_tbl(i),
            z_organization_id      => p_organization_id            ,
            attribute_name         => 'INVENTORY_ITEM_ID'          ,
            error_code             => l_error_code                 ,
            error_flag             => l_error_flag                 ,
            error_message          => l_error_message              ,
            attribute_value        => l_attribute_value
         );

         IF l_error_flag = 'Y' THEN
            --inv_debug.message('ssia', 'got error from inv_customer_item_grp');
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_Message.Set_Name('IBE', 'IBE_SC_INV_CUSTOM_ITEM_ERROR');
               FND_Message.Set_Token('INVMSG', l_error_message);
               FND_MSG_PUB.Add;
            END IF;
         END IF;


         IF l_attribute_value IS NOT NULL THEN
            l_inventory_item_id := to_number(l_attribute_value);
            --inv_debug.message('ssia', 'l_inventory_item_id is ' || l_inventory_item_id);
            select count(s.inventory_item_id)
            into l_item_exists
	    from ibe_dsp_section_items s, ibe_dsp_msite_sct_items b
 	    where s.section_item_id = b.section_item_id
	    and   b.mini_site_id = p_minisite_id
	    and   s.inventory_item_id = l_inventory_item_id
	    and   (s.end_date_active > sysdate or s.end_date_active is null )
	    and   s.start_date_active < sysdate;

            if( l_item_exists > 0  ) then
		--inv_debug.message('ssia', 'item exists');
                x_inventory_item_id_tbl(i) := to_number(l_attribute_value);
	    else
		--inv_debug.message('ssia', 'item not exists');
		x_inventory_item_id_tbl(i) := 0;
	    end if;
         END IF;
      END IF;
   END LOOP;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   --inv_debug.message('ssia', 'x_msg_count is ' || x_msg_count);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Ibe_Shopcart_Pvt10.Load_Merchant_InvId(-)...');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END Load_Item_IDs;

PROCEDURE Load_Item_IDs_for_crossRef(
   p_api_version           IN  NUMBER   := 1              ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_crossRef_type_tbl  IN  jtf_varchar2_table_100     ,
   p_crossRef_number_tbl  IN  jtf_varchar2_table_100     ,
   p_organization_id       IN  NUMBER                     ,
   x_inventory_item_id_tbl OUT NOCOPY jtf_number_table           ,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
 /* commented by kdosapat - for bug 17184951
  Cursor c_crossRef_Num (c_crossRef_num VARCHAR2) is
      Select inventory_item_id
      From MTL_CROSS_REFERENCES_V
      where cross_reference =  c_crossRef_num;
*/
  Cursor c_crossRef_Num (c_crossRef_num VARCHAR2) is
   Select ref.inventory_item_id
      From MTL_CROSS_REFERENCES_V ref, MTL_SYSTEM_ITEMS_VL MSIV
      where ref.cross_reference =  c_crossRef_num
      and ref.inventory_item_id = MSIV.inventory_item_id
                 AND MSIV.WEB_STATUS = 'PUBLISHED'
                 AND MSIV.organization_id = p_organization_id;
/* commented by kdosapat - for bug 17184951
  Cursor c_crossRef_typeAndNum (c_crossRef_num VARCHAR2, c_crossRef_type VARCHAR2) is
    Select inventory_item_id
      From MTL_CROSS_REFERENCES_V
       where cross_reference_type = c_crossRef_type and
       cross_reference =  c_crossRef_num; */

    Cursor c_crossRef_typeAndNum (c_crossRef_num VARCHAR2, c_crossRef_type VARCHAR2) is
    Select ref.inventory_item_id
      From MTL_CROSS_REFERENCES_V ref, MTL_SYSTEM_ITEMS_VL MSIV
       where ref.cross_reference_type = c_crossRef_type and
       ref.cross_reference =  c_crossRef_num
       and ref.inventory_item_id = MSIV.inventory_item_id
       AND MSIV.WEB_STATUS = 'PUBLISHED'
       AND MSIV.organization_id = p_organization_id;

  /* commented - kdosapat - for bug 17184951
    Cursor c_crossRef_typeAndNum_count (c_crossRef_num VARCHAR2, c_crossRef_type VARCHAR2) is
    Select count(*)
      From MTL_CROSS_REFERENCES_V
       where cross_reference_type = c_crossRef_type and
       cross_reference =  c_crossRef_num; */

        Cursor c_crossRef_typeAndNum_count (c_crossRef_num VARCHAR2, c_crossRef_type VARCHAR2) is
        Select count(*)
          From MTL_CROSS_REFERENCES_V ref,  MTL_SYSTEM_ITEMS_VL MSIV
           where ref.cross_reference_type = c_crossRef_type and
                 ref.cross_reference =  c_crossRef_num
                 and ref.inventory_item_id = MSIV.inventory_item_id
                 AND MSIV.WEB_STATUS = 'PUBLISHED'
                 AND MSIV.organization_id = p_organization_id;


  l_api_name    CONSTANT  VARCHAR2(30) := 'Load_Item_IDs_for_crossRef';
  l_api_version CONSTANT  NUMBER       := 1.0;

  l_error_code                  VARCHAR2(30);
  l_error_flag                  VARCHAR2(30);
  l_error_message               VARCHAR2(300);

  l_attribute_value             VARCHAR2(30);
  l_count                       NUMBER;
  l_item_count			NUMBER;
  l_inventory_item_id		NUMBER;
  l_temp_count 			NUMBER;
BEGIN
   /*inv_debug.message('ssia', 'customer id is ' || p_cust_id);
   inv_debug.message('ssia', 'p_organization_id is ' || p_organization_id);
   inv_debug.message('ssia', 'p_minisite_id is ' || p_minisite_id);*/

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name   ,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt.Load_Item_IDs_for_crossRef...');
       IBE_Util.Debug('IBE_Quote_Misc_pvt.Load_Item_IDs_for_crossRef... p_crossRef_type_tbl length: ' || p_crossRef_type_tbl.count);
        IBE_Util.Debug('IBE_Quote_Misc_pvt.Load_Item_IDs_for_crossRef...p_crossRef_number_tbl length: ' || p_crossRef_number_tbl.count);
   END IF;

   l_count                   := p_crossRef_type_tbl.COUNT;

   x_inventory_item_id_Tbl   := JTF_NUMBER_TABLE();
   x_inventory_item_id_Tbl.extend(l_count);


   FOR i IN 1..l_count LOOP

   l_inventory_item_id := null;
      IF p_crossRef_number_tbl(i) IS NOT NULL THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('IBE_Quote_Misc_pvt:: p_crossRef_number_tbl(' || i || ') is not null: ' ||  p_crossRef_number_tbl(i));
         End IF;
        IF p_crossRef_type_tbl(i) IS NOT NULL THEN
         l_temp_count := 0;
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('IBE_Quote_Misc_pvt::p_crossRef_type_tbl(' || i || ') is not null: ' ||  p_crossRef_type_tbl(i));
         End IF;
         open c_crossRef_typeAndNum_count(p_crossRef_number_tbl(i),p_crossRef_type_tbl(i));
         fetch c_crossRef_typeAndNum_count into l_temp_count;
         close c_crossRef_typeAndNum_count;

         IBE_Util.Debug('17184951 : IBE_Quote_Misc_pvt::l_temp_count is: ' || l_temp_count );
         if (l_temp_count > 1) then
          l_inventory_item_id := -1;  -- Cross Ref Number was defined more than one time within same cross ref type
         else
          open c_crossRef_typeAndNum(p_crossRef_number_tbl(i),p_crossRef_type_tbl(i));
          fetch c_crossRef_typeAndNum into l_inventory_item_id;

          if c_crossRef_typeAndNum%notfound then
            l_inventory_item_id := null;
          end if;
          close c_crossRef_typeAndNum;
         end if;


         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_Misc_pvt::l_inventory_item_id:  ' ||  l_inventory_item_id);
         End IF;
        else
            /*  commented - kdosapat - for bug 17184951
           Select count(inventory_item_id) into l_item_count From MTL_CROSS_REFERENCES_V where cross_reference =  p_crossRef_number_tbl(i); */
           Select count(ref.inventory_item_id) into l_item_count From MTL_CROSS_REFERENCES_V ref, MTL_SYSTEM_ITEMS_VL MSIV  where ref.cross_reference =  p_crossRef_number_tbl(i)
                 and ref.inventory_item_id = MSIV.inventory_item_id
                 AND MSIV.WEB_STATUS = 'PUBLISHED'
                 AND MSIV.organization_id = p_organization_id ;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt::l_item_count::17184951  ' ||  l_item_count);
      End IF;
            if (l_item_count > 1) then
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt::setting  l_inventory_item_id 0');
      End IF;
              l_inventory_item_id := 0;  -- Cross Ref Number was defined more than once
            else

              open c_crossRef_Num(p_crossRef_number_tbl(i));
       fetch c_crossRef_Num into l_inventory_item_id;

       if c_crossRef_Num%notfound then
       l_inventory_item_id := null;
       end if;
       close c_crossRef_Num;

               IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt::inventory_item_id: '|| l_inventory_item_id);
      End IF;
            end if;
        END IF;

      end if;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   if l_inventory_item_id is not null then
      IBE_Util.Debug('Load_Item_IDs_for_crossRef. inventory_item_id' || l_inventory_item_id);
      else
      IBE_Util.Debug('Load_Item_IDs_for_crossRef. inventory_item_id is null');
      end if;
      end if;
        x_inventory_item_id_Tbl(i) := l_inventory_item_id;
   END LOOP;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   --inv_debug.message('ssia', 'x_msg_count is ' || x_msg_count);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Load_Item_IDs_for_crossRef(-)...');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END Load_Item_IDs_for_crossRef;


---converting ShoppingList, saved cart, Quote to Active shopping cart
PROCEDURE Check_Item_IDs(
   p_api_version           IN  NUMBER   := 1              ,
   p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
   p_cust_id               IN  NUMBER                     ,
   p_organization_id       IN  NUMBER                     ,
   p_minisite_id	   IN  NUMBER			  ,
   x_inventory_item_id_tbl IN OUT NOCOPY jtf_number_table           ,
   x_return_status         OUT NOCOPY VARCHAR2                   ,
   x_msg_count             OUT NOCOPY NUMBER                     ,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_api_name    CONSTANT  VARCHAR2(30) := 'Check_Item_IDs';
  l_api_version CONSTANT  NUMBER       := 1.0;

  l_error_code                  VARCHAR2(30);
  l_error_flag                  VARCHAR2(30);
  l_error_message               VARCHAR2(300);

  l_attribute_value             VARCHAR2(30);
  l_count                       NUMBER;
  l_item_exists			NUMBER;
  l_inventory_item_id		NUMBER;
BEGIN
   /*inv_debug.message('ssia', 'customer id is ' || p_cust_id);
   inv_debug.message('ssia', 'p_organization_id is ' || p_organization_id);
   inv_debug.message('ssia', 'p_minisite_id is ' || p_minisite_id);*/

   -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name   ,
                                      g_pkg_name)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt.Check_Item_IDs(+)...');
   END IF;

   l_count                   := x_inventory_item_id_tbl.COUNT;




   FOR i IN 1..l_count LOOP
      IF x_inventory_item_id_tbl(i) IS NOT NULL THEN
         --inv_debug.message('ssia', 'p_cust_item_number is ' || p_cust_item_number_tbl(i));

         -- get inventory_item_id for each customer_item_number



            l_inventory_item_id := x_inventory_item_id_tbl(i);
            --inv_debug.message('ssia', 'l_inventory_item_id is ' || l_inventory_item_id);
            select count(s.inventory_item_id)
            into l_item_exists
	    from ibe_dsp_section_items s, ibe_dsp_msite_sct_items b
 	    where s.section_item_id = b.section_item_id
	    and   b.mini_site_id = p_minisite_id
	    and   s.inventory_item_id = l_inventory_item_id
	    and   (s.end_date_active > sysdate or s.end_date_active is null )
	    and   s.start_date_active < sysdate;

            if( l_item_exists > 0  ) then
		--inv_debug.message('ssia', 'item exists');
                x_inventory_item_id_tbl(i) := l_inventory_item_id;
	    else
		--inv_debug.message('ssia', 'item not exists');
		x_inventory_item_id_tbl(i) := 0;
	    end if;
         END IF;

   END LOOP;


   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
   --inv_debug.message('ssia', 'x_msg_count is ' || x_msg_count);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Ibe_Shopcart_Pvt10.Load_Merchant_InvId(-)...');
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END Check_Item_IDs;



procedure get_load_errors(
   X_reason_code      OUT NOCOPY JTF_VARCHAR2_TABLE_100 ,
   p_api_version      IN  NUMBER   := 1.0               ,
   p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE    ,
   p_commit           IN  VARCHAR2 := FND_API.G_FALSE   ,
   x_return_status    OUT NOCOPY VARCHAR2               ,
   x_msg_count        OUT NOCOPY NUMBER                 ,
   x_msg_data         OUT NOCOPY VARCHAR2               ,
   P_quote_header_id  IN number    := FND_API.G_MISS_NUM,
   P_Load_type        IN number    := FND_API.G_MISS_NUM,
   P_quote_number     IN number    := FND_API.G_MISS_NUM,
   P_quote_version    IN number    := FND_API.G_MISS_NUM,
   P_party_id         IN number    := FND_API.G_MISS_NUM, -- only involved in sharee w/o retr num
   P_cust_account_id  IN number    := FND_API.G_MISS_NUM, -- only involved in sharee w/o retr num
   p_retrieval_number IN NUMBER    := FND_API.G_MISS_NUM,
   P_share_type       IN number    := -1,                 -- defaulted to no share type
   p_access_level     IN number    := 0) is

  Cursor c_cart_columns (quote_hdr_id number) is
    select resource_id, status_code, publish_flag, quote_expiration_date,
    max_version_flag , order_id, quote_name
    from aso_quote_headers_all a,   aso_quote_statuses_vl b
    where quote_header_id = quote_hdr_id
    and a.quote_status_id = b.quote_status_id;

  Cursor c_cart_from_number(quote_num number, quote_ver number) is
    select quote_header_id
    from aso_quote_headers_all a
    where quote_number = quote_num
    and quote_version = quote_ver;

  Cursor c_retrieval_number (c_retrieval_number NUMBER) is
    select quote_sharee_number, quote_sharee_id, end_date_active, update_privilege_type_code, quote_header_id
    from IBE_SH_QUOTE_ACCESS
    where quote_sharee_number = c_retrieval_number;

  Cursor c_recipient_no_retnum (c_quote_header_id NUMBER, c_party_id NUMBER, c_account_id NUMBER) is
    select quote_sharee_number, quote_sharee_id, end_date_active, update_privilege_type_code
    from IBE_SH_QUOTE_ACCESS
    where quote_header_id = c_quote_header_id
    and party_id = c_party_id
    and cust_account_id = c_account_id;



  G_PKG_NAME            CONSTANT VARCHAR2(30) := 'IBE_Quote_Misc_pvt';
  l_api_name            CONSTANT VARCHAR2(50) := 'Get_load_errors_pvt';
  l_api_version         NUMBER                := 1.0;
-- these constants need to be kept in sync w/ Quote.java's static defines
  L_CART_LOAD_TYPE      CONSTANT number       := 0;
  L_QUOTE_LOAD_TYPE     CONSTANT number       := 1;
  L_LOAD_FORUPDATE      CONSTANT number       := 2;
  L_LOAD_EXPRESSORDER   CONSTANT number       := 3;

  L_NO_SHARE_TYPE      CONSTANT number       := -1;
  L_UN_SHARED_TYPE     CONSTANT number       := 0;
  L_SHARED_BY_TYPE     CONSTANT number       := 1;
  L_SHARED_TO_TYPE     CONSTANT number       := 2;

  L_NO_ACCESS_LEVEL    CONSTANT number       := 0;
  L_READ_ONLY          CONSTANT number       := 1;
  L_UPDATE             CONSTANT number       := 2;
  L_FULL               CONSTANT number       := 3;

  l_quote_header_id     NUMBER;
  l_resource_id         number                :=fnd_api.g_miss_num;
  l_status_code         varchar2(100)         :=fnd_api.g_miss_char;
  l_publish_flag        varchar2(10)          :=fnd_api.g_miss_char;
  l_quote_type          varchar2(10)          :=fnd_api.g_miss_char;
  l_return_status       VARCHAR2(100);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_max_version_flag    varchar2(2);
  l_expiration_date     date;
  table_counter         number                := 1;
  l_end_date_active     DATE;
  l_order_id            NUMBER;
  l_recipient_id        NUMBER;
  l_access_code         VARCHAR2(10)          :=fnd_api.g_miss_char;
  l_quote_name          VARCHAR2(2000);
  l_exp_quote_header_id NUMBER;

  rec_cart_columns      c_cart_columns%rowtype;
  rec_cart_from_number  c_cart_from_number%rowtype;
  rec_retrieval_number  c_retrieval_number%rowtype;
  rec_recipient_no_retnum  c_recipient_no_retnum%rowtype;

Begin
  -- Standard Start of API savepoint
   SAVEPOINT Get_load_errors_pvt;

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
  --Start of API Body
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('incoming quote_header_id in get_load_errors is '||p_quote_header_id);
     IBE_UTIL.debug('incoming retrievalnumber in get_load_errors is '||p_retrieval_number);
     IBE_UTIL.debug('incoming partyid         in get_load_errors is '||p_party_id);
     IBE_UTIL.debug('incoming accountid       in get_load_errors is '||p_cust_account_id);
     IBE_UTIL.debug('incoming sharetype       in get_load_errors is '||p_share_type);
     IBE_UTIL.debug('incoming accesslevel     in get_load_errors is '||p_access_level);
  END IF;

  X_reason_code :=  JTF_VARCHAR2_TABLE_100();
  If (p_quote_header_id <> fnd_api.g_miss_num) then
    l_exp_quote_header_id := p_quote_header_id;
    For rec_cart_columns in c_cart_columns(p_quote_header_id) loop
	  L_resource_id       := rec_cart_columns.resource_id;
	  l_status_code       := rec_cart_columns.status_code;
	  l_publish_flag      := rec_cart_columns.publish_flag;
      l_expiration_date   := rec_cart_columns.quote_expiration_date;
      l_max_version_flag  := rec_cart_columns.max_version_flag;
      l_order_id          := rec_cart_columns.order_id;
      l_quote_name        := rec_cart_columns.quote_name;
      exit when c_cart_columns%notfound;
    end loop;
  Elsif ((p_quote_number <> fnd_api.g_miss_num) and (p_quote_version <> fnd_api.g_miss_num)) then
    For rec_cart_from_number in c_cart_from_number(p_quote_number, p_quote_version) loop
      l_quote_header_id := rec_cart_from_number.quote_header_id;
      For rec_cart_columns in c_cart_columns(l_quote_header_id) loop
        L_resource_id       := rec_cart_columns.resource_id;
        l_status_code       := rec_cart_columns.status_code;
        l_publish_flag      := rec_cart_columns.publish_flag;
        l_expiration_date   := rec_cart_columns.quote_expiration_date;
        l_max_version_flag  := rec_cart_columns.max_version_flag;
        exit when c_cart_columns%notfound;
      end loop;
      exit when c_cart_from_number%notfound;
    end loop;
  End if;

  -- 1st half of errors for share information
  -- only do these checks if given retrieval number or qtehdrid, ptyid, acctid, and sharetype
  If((p_retrieval_number <> FND_API.G_MISS_NUM) or
    ((p_retrieval_number = FND_API.G_MISS_NUM)
      and (p_share_type = L_SHARED_TO_TYPE)
      and (p_party_id <> FND_API.G_MISS_NUM)
      and (p_cust_account_id <> FND_API.G_MISS_NUM)
      and (p_quote_header_id <> FND_API.G_MISS_NUM))) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Checking for recipient info...');
    end if;
    If(p_retrieval_number <> FND_API.G_MISS_NUM) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('get recipient info based on retrieval number');
      end if;
      for rec_retrieval_number in c_retrieval_number(p_retrieval_number) loop
        l_end_date_active := rec_retrieval_number.end_date_active;
        l_recipient_id    := rec_retrieval_number.quote_sharee_id;
        l_access_code     := rec_retrieval_number.update_privilege_type_code;
        l_quote_header_id := rec_retrieval_number.quote_header_id;
        exit when c_retrieval_number%NOTFOUND;
      end loop;
      if((p_quote_header_id = fnd_api.g_miss_num) and (l_quote_header_id is not null)) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('tried to load with retreival number only (no cartid)');
          IBE_UTIL.debug('but the retrieval number was valid so get cart info... ');
        end if;
        l_exp_quote_header_id := l_quote_header_id;
        For rec_cart_columns in c_cart_columns(l_quote_header_id) loop
          L_resource_id       := rec_cart_columns.resource_id;
          l_status_code       := rec_cart_columns.status_code;
          l_publish_flag      := rec_cart_columns.publish_flag;
          l_expiration_date   := rec_cart_columns.quote_expiration_date;
          l_max_version_flag  := rec_cart_columns.max_version_flag;
          l_quote_name        := rec_cart_columns.quote_name;
        exit when c_cart_columns%notfound;
        end loop;
      end if;
    end if;

    If((p_retrieval_number = FND_API.G_MISS_NUM)
      and (p_share_type = L_SHARED_TO_TYPE)
      and (p_party_id <> FND_API.G_MISS_NUM)
      and (p_cust_account_id <> FND_API.G_MISS_NUM)
      and (p_quote_header_id <> FND_API.G_MISS_NUM)) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('get recipient info based on cartid, partyid, acctid');
      end if;
      for rec_recipient_no_retnum in c_recipient_no_retnum(p_quote_header_id, p_party_id, p_cust_account_id) loop
        l_end_date_active := rec_recipient_no_retnum.end_date_active;
        l_recipient_id    := rec_recipient_no_retnum.quote_sharee_id;
        l_access_code     := rec_recipient_no_retnum.update_privilege_type_code;
        exit when c_retrieval_number%NOTFOUND;
      end loop;
    end if;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('l_end_date_active: '||TO_CHAR(l_end_date_active, 'mm/dd/yyyy:hh24:MI:SS'));
      IBE_UTIL.debug('l_recipient_id: '||l_recipient_id);
      IBE_UTIL.debug('l_access_code:  '||l_access_code);
    end if;

    If ((p_retrieval_number <> FND_API.G_MISS_NUM) and (l_recipient_id is NULL)) then
      -- if we were given a retrieval number and it was not in the database
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_INVALID_RETRIEVAL_NUM');
      END IF;
      if(table_counter = 1)  then
          x_reason_code.extend();
          X_reason_code(table_counter) := 'IBE_SC_INVALID_RETRIEVAL_NUM';
          Table_counter := table_counter+1;
      end if;

    Elsif (l_recipient_id is NULL) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Including the Error code: IBE_SC_ERR_PRIVILEGE');
    END IF;
      if(table_counter = 1)  then
          x_reason_code.extend();
          X_reason_code(table_counter) := 'IBE_SC_ERR_PRIVILEGE';
          Table_counter := table_counter+1;
      end if;

    Elsif ((p_access_level = L_UPDATE) or (p_access_level = L_FULL))  then
      -- if a certain access level was passed in, then see if the db access level is sufficient
      if (p_access_level = L_UPDATE  and (l_access_code <> 'F' or l_access_code <> 'A')) or
         (p_access_level = L_FULL    and (l_access_code <> 'A')) then
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Including the Error code: IBE_SC_ERR_PRIVILEGE');
        END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(table_counter) := 'IBE_SC_ERR_PRIVILEGE';
            Table_counter := table_counter+1;
        end if;
      end if;

    Elsif (Upper(l_status_code)  = 'INACTIVE') then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Including the Error code: IBE_SC_CART_DELETED');
    END IF;
      if(table_counter = 1)  then
          x_reason_code.extend();
          X_reason_code(table_counter) := 'IBE_SC_CART_DELETED';
          Table_counter := table_counter+1;
      end if;

    Elsif (l_order_id is NOT NULL) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Including the Error code: IBE_SC_CART_ORDERED');
    END IF;
      if(table_counter = 1)  then
          x_reason_code.extend();
          X_reason_code(table_counter) := 'IBE_SC_CART_ORDERED';
          Table_counter := table_counter+1;
      end if;

    Elsif ((l_end_date_active is NOT NULL and l_end_date_active < sysdate) or
           (l_recipient_id is NULL)) then
      -- if the row has been end dated or we were unable to find a recip row by party, acct, and cart
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_ERR_USERACCESS');
      END IF;
      if(table_counter = 1)  then
          x_reason_code.extend();
          X_reason_code(table_counter) := 'IBE_SC_ERR_USERACCESS';
          Table_counter := table_counter+1;
      end if;

    End if;

  End If;
  -- 2nd half of errors for cart information
  -- only do these latter checks if we had a request for a cart - either by id or number and version
  if ((p_quote_header_id <> fnd_api.g_miss_num) or
      ((p_quote_number <> fnd_api.g_miss_num)
       and (p_quote_version <> fnd_api.g_miss_num))) then
    if(trunc(l_expiration_date) < trunc(sysdate)) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Including the Error code: IBE_SC_CART_EXPIRED');
    END IF;
      if(table_counter = 1)  then
          x_reason_code.extend();
          X_reason_code(table_counter) := 'IBE_SC_CART_EXPIRED';
          Table_counter := table_counter+1;
      end if;
    End if;
    If(l_max_version_flag = 'N') then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_QUOTE_MAX_VER_FLAG_N');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(table_counter) := 'IBE_SC_QUOTE_MAX_VER_FLAG_N';
            Table_counter := table_counter+1;
        end if;
    End If;
    If (p_load_type = L_CART_LOAD_TYPE) then
      If (l_resource_id is not null and (l_resource_id <> FND_API.G_MISS_NUM)) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_CART_HAS_RESOURCEID');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(Table_counter) := 'IBE_SC_CART_HAS_RESOURCEID';
            Table_counter := table_counter+1;
        end if;
      End If;
      --Status code 28 is for "store draft"
      If (upper(l_status_code) <> 'STORE DRAFT') then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Including the Error code: IBE_SC_INVALID_CART_STS');
        END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(Table_counter ) := 'IBE_SC_INVALID_CART_STS';
            Table_counter := table_counter+1;
        end if;
      End if;

      If(l_publish_flag <> 'F') then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_CART_NOT_PUBL');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(Table_counter) := 'IBE_SC_CART_NOT_PUBL';
            Table_counter := table_counter+1;
        end if;
      End if;
    Elsif(p_load_type = L_QUOTE_LOAD_TYPE) then
      If (l_resource_id is null) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_QUOTE_NEEDS_RESOURCEID');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(Table_counter):= 'IBE_SC_QUOTE_NEEDS_RESOURCEID';
            Table_counter := table_counter+1;
        end if;
      End If;
      If (l_status_code = 'INACTIVE') then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_QUOTE_INACTIVE');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(table_counter) := 'IBE_SC_QUOTE_INACTIVE';
            Table_counter := table_counter+1;
        end if;
      End If;
      If(l_publish_flag <> 'T') then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_QUOTE_NOT_PUBL');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(Table_counter):= 'IBE_SC_QUOTE_NOT_PUBL';
            Table_counter := table_counter+1;
        end if;
      End if;
    Elsif(p_load_type = L_LOAD_FORUPDATE) then
      If (l_resource_id is not null and (l_resource_id <> FND_API.G_MISS_NUM)) THEN
        If (FND_Profile.Value('IBE_UPDATE_DRAFT_QUOTES') = 'Y' and l_status_code <> 'DRAFT')  THEN
        -- Update on Draft profile enabled, only allow updates on DRAFT.
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Including the Error code: IBE_SC_INVALID_QUOTE_STS');
        END IF;
          if(table_counter = 1)  then
              x_reason_code.extend();
              X_reason_code(Table_counter):= 'IBE_SC_INVALID_QUOTE_STS';
              Table_counter := table_counter+1;
          end if;
        End if;
        If(l_publish_flag <> 'T') then
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Including the Error code: IBE_SC_QUOTE_NOT_PUBL');
        END IF;
          if(table_counter = 1)  then
              x_reason_code.extend();
              X_reason_code(Table_counter):= 'IBE_SC_QUOTE_NOT_PUBL';
              Table_counter := table_counter+1;
          end if;
        End if;
      Else -- for a cart, check for 'STORE DRAFT' (if the loadType is load_forupdate, status has to be 'STORE DRAFT')
       If (l_status_code <> 'STORE DRAFT') Then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Including the Error code: IBE_SC_INVALID_CART_STS');
       END IF;
          if(table_counter = 1)  then
              x_reason_code.extend();
              X_reason_code(Table_counter):= 'IBE_SC_INVALID_CART_STS';
              Table_counter := table_counter+1;
          end if;
       End if;
      End if;
    End if;
    --load error for one click orders.
    If(p_load_type = L_LOAD_EXPRESSORDER) Then
      If(l_quote_name  = l_exp_quote_header_id) Then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Including the Error code: IBE_SC_CART_DELETED');
      END IF;
        if(table_counter = 1)  then
            x_reason_code.extend();
            X_reason_code(table_counter) := 'IBE_SC_CART_DELETED';
            Table_counter := table_counter+1;
        end if;
      End If;
    End if;
  End if;-- end if we have an input cartid or cartnum and version
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
      IBE_UTIL.debug('Expected exception in IBE_QUOTE_MISC_PVT.get_load_errors');
    end if;
     ROLLBACK TO Get_load_errors_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Unexpected exception in IBE_QUOTE_MISC_PVT.get_load_errors');
    end if;
     ROLLBACK TO Get_load_errors_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN OTHERS THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Unknown exception in IBE_QUOTE_MISC_PVT.get_load_errors');
    end if;
    ROLLBACK TO Get_load_errors_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                              L_API_NAME);
    END IF;

    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);

End get_load_errors;

/*PROCEDURE Get_ActiveCart_Id (
   p_party_id            IN number
   ,p_cust_account_id    IN number
   ,p_api_version_number IN   NUMBER
   ,p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE
   ,p_commit             IN   VARCHAR2 := FND_API.G_FALSE
   ,X_Return_Status      OUT NOCOPY  VARCHAR2
   ,X_Msg_Count          OUT NOCOPY  NUMBER
   ,X_Msg_Data           OUT NOCOPY  VARCHAR2
   ,x_cartHeaderId       OUT NOCOPY number
   ,x_last_update_date   OUT NOCOPY  DATE
)
is

   CURSOR C_get_quote_id(p_partyid number,p_cust_accountid number ) is
     select quote_header_id, last_update_date
     from aso_quote_headers_all
     where quote_header_id = (select max(quote_header_id)
                            from aso_quote_headers_all
                            where upper(quote_source_code) = 'ISTORE ACCOUNT'
                            and party_id = p_partyid
                            and cust_account_id = p_cust_accountid
                            and quote_name = 'IBEACTIVECART'
                            and quote_expiration_date > sysdate
                            and resource_id IS NULL
                            and ORDER_ID IS NULL);



   l_CartHeaderId  number := null;
   Rec_get_quote_id C_get_quote_id%rowtype;
   l_dummy         number;
   l_api_name      CONSTANT VARCHAR2(30) := 'Get_ActiveCart_Id';
   l_api_version   CONSTANT NUMBER   := 1.0;
   l_count         number;

begin
  -- Standard Start of API savepoint
  SAVEPOINT GetActiveCartId_pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
                           l_api_version       ,
                           P_Api_Version_Number,
                           l_api_name          ,
                           G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- API body
  FOR Rec_get_quote_id in c_get_quote_id(p_party_id, p_cust_account_id) loop
    l_cartHeaderId := Rec_get_quote_id.quote_header_id;
    x_last_update_date := Rec_get_quote_id.last_update_date;
  exit when c_get_quote_id%notfound;
  end loop;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('ibeactivecart ='||l_cartHeaderId);
  END IF;

  IF (l_cartHeaderId = fnd_api.g_miss_num or l_cartHeaderid is null ) then
    x_cartHeaderId := null;
  else
    x_cartHeaderId := l_cartHeaderId;
  end if;

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get
                    (p_count => x_msg_count,
                     p_data  => x_msg_data
                    );


EXCEPTION
     WHEN  TOO_MANY_ROWS  then
    --ibe_util.debug('TOO_MANY_ROWS');
    ROLLBACK TO GETACTIVECARTID_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.set_name('IBE','IBE_SC_GETACTIVEC_MANY');
    FND_MSG_PUB.add;
    FND_MSG_PUB.Count_And_Get
        (   p_count         =>      x_msg_count,
            p_data          =>      x_msg_data
        );
    WHEN NO_DATA_FOUND  then
    --ibe_util.debug('NO_DATA_FOUND');
          null;

    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO GETACTIVECARTID_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
        (   p_count         =>      x_msg_count,
            p_data          =>      x_msg_data
        );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO GETACTIVECARTID_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
        (   p_count         =>      x_msg_count,
            p_data          =>      x_msg_data
        );
  WHEN OTHERS THEN
    ROLLBACK TO GETACTIVECARTID_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg
                    ( G_PKG_NAME,
                      l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
        (   p_count         =>      x_msg_count,
            p_data          =>      x_msg_data
        );

END GET_ACTIVECART_ID;*/

PROCEDURE Update_Config_Item_Lines(
   x_return_status        OUT NOCOPY VARCHAR2,
   x_msg_count            OUT NOCOPY NUMBER  ,
   x_msg_data             OUT NOCOPY VARCHAR2,
   px_qte_line_dtl_tbl IN OUT NOCOPY ASO_QUOTE_PUB.Qte_Line_Dtl_tbl_Type
)
IS
   L_API_NAME       CONSTANT VARCHAR2(30) := 'Update_Config_Item_Lines';
   l_old_config_header_id    NUMBER;
   l_new_config_header_id    NUMBER;
   l_old_config_revision_num NUMBER;
   l_new_config_revision_num NUMBER;

   -- ER#4025142
   --l_return_value            NUMBER;
   l_api_version    CONSTANT NUMBER         := 1.0;
   l_ret_status VARCHAR2(1);
   l_msg_count  INTEGER;
   l_orig_item_id_tbl  CZ_API_PUB.number_tbl_type;
   l_new_item_id_tbl   CZ_API_PUB.number_tbl_type;
BEGIN
   SAVEPOINT Update_Config_Item_Lines;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt.Update_Config_Item_Lines(+)');
   END IF;

   -- API body
  FOR i IN 1..px_qte_line_dtl_tbl.COUNT LOOP
      IF  px_qte_line_dtl_tbl(i).config_header_id IS NOT NULL
      AND px_qte_line_dtl_tbl(i).config_header_id <> FND_API.G_MISS_NUM THEN
         l_old_config_header_id    := px_qte_line_dtl_tbl(i).config_header_id;
         l_old_config_revision_num := px_qte_line_dtl_tbl(i).config_revision_num;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('old config header id = '|| l_old_config_header_id);
            IBE_Util.Debug('old config revision number = '|| l_old_config_revision_num);
            IBE_Util.Debug('Call CZ_CONFIG_API_PUB.copy_configuration at'
                 || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         --ER#4025142
         CZ_CONFIG_API_PUB.copy_configuration(p_api_version => l_api_version
                            ,p_config_hdr_id        => l_old_config_header_id
                            ,p_config_rev_nbr       => l_old_config_revision_num
                            ,p_copy_mode            => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                            ,x_config_hdr_id        => l_new_config_header_id
                            ,x_config_rev_nbr       => l_new_config_revision_num
                            ,x_orig_item_id_tbl     => l_orig_item_id_tbl
                            ,x_new_item_id_tbl      => l_new_item_id_tbl
                            ,x_return_status        => l_ret_status
                            ,x_msg_count            => l_msg_count
                            ,x_msg_data             => x_msg_data);
		 IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
            	RAISE FND_API.G_EXC_ERROR;
  		 END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('Done CZ_CONFIG_API_PUB.Copy_Configuration at'
                 || TO_CHAR(SYSDATE, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_Util.Debug('new config header id = '|| l_new_config_header_id);
            IBE_Util.Debug('new config revision number = '|| l_new_config_revision_num);
         END IF;

         -- update all other dtl table
         FOR j in 1..px_qte_line_dtl_tbl.COUNT LOOP
            IF  px_qte_line_dtl_tbl(j).config_header_id    = l_old_config_header_id
            AND px_qte_line_dtl_tbl(j).config_revision_num = l_old_config_revision_num THEN
               px_qte_line_dtl_tbl(j).config_header_id    := l_new_config_header_id;
               px_qte_line_dtl_tbl(j).config_revision_num := l_new_config_revision_num;
            END IF;
         END LOOP;
      END IF;
   END LOOP;
   -- End of API body.

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('IBE_Quote_Misc_pvt.Update_Config_Item_Lines(-)');
   END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data     );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected error IBE_Quote_Misc_pvt.Update_Config_Item_Lines');
   END IF;
   ROLLBACK to Update_config_item_lines;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('Unexpected error IBE_Quote_Misc_pvt.Update_Config_Item_Lines');
   END IF;
   ROLLBACK to Update_config_item_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown error IBE_Quote_Misc_pvt.Update_Config_Item_Lines');
   END IF;
   ROLLBACK to Update_config_item_lines;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Update_Config_Item_Lines;

procedure Validate_Items(
   x_item_exists        OUT NOCOPY     jtf_number_Table,
   p_cust_account_id    IN      NUMBER,
   p_minisite_id        IN      NUMBER,
   p_merchant_item_ids  IN      JTF_NUMBER_TABLE,
   p_org_id             IN      NUMBER
) IS
   l_item_exists	NUMBER;
   l_count		NUMBER;
BEGIN
   l_count                   := p_merchant_item_ids.COUNT;
   x_item_exists   := JTF_NUMBER_TABLE();
   x_item_exists.extend(l_count);


   FOR i IN 1..l_count LOOP
      IF p_merchant_item_ids(i) IS NOT NULL THEN
         --inv_debug.message('ssia', 'p_cust_item_number is ' || p_cust_item_number_tbl(i));
         select count(s.inventory_item_id)
         into l_item_exists
	 from ibe_dsp_section_items s, ibe_dsp_msite_sct_items b
 	 where s.section_item_id = b.section_item_id
	 and   b.mini_site_id = p_minisite_id
	 and   s.inventory_item_id = p_merchant_item_ids(i)
	 and   (s.end_date_active > sysdate or s.end_date_active is null )
	 and   s.start_date_active < sysdate;

         x_item_exists(i) := l_item_exists;
      else
	 x_item_exists(i) := 0;
      end if;
   END LOOP;
END Validate_Items;

PROCEDURE Get_Included_Warranties(
  p_api_version_number              IN  NUMBER := 1,
  p_init_msg_list                   IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                          IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2,
  p_organization_id                 IN  NUMBER := NULL,
  p_product_item_id                 IN  NUMBER,
  x_service_item_ids                OUT NOCOPY JTF_NUMBER_TABLE
) IS
  l_warranty_tbl ASO_SERVICE_CONTRACTS_INT.War_tbl_type;
  l_count        NUMBER;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('Start IBE_Quote_Misc_pvt.Get_Available_Services');
     IBE_UTIL.Debug('     Parms: [' || p_organization_id || ', ' ||
			  p_product_item_id || ']');
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('   ASO_SERVICE_CONTRACTS_INT.Get_Warranty Starts');
  END IF;
  ASO_SERVICE_CONTRACTS_INT.Get_Warranty(
	  p_api_version_number     => p_api_version_number,
	  p_init_msg_list          => p_init_msg_list,
	  x_msg_count              => x_msg_count,
	  x_msg_data               => x_msg_data,
	  p_org_id                 => FND_PROFILE.Value('ORG_ID'),
	  p_organization_id        => p_organization_id,
	  p_product_item_id        => p_product_item_id,
	  x_return_status          => x_return_status,
	  x_warranty_tbl           => l_warranty_tbl
  );
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    l_count := l_warranty_tbl.COUNT;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('   ASO_SERVICE_CONTRACTS_INT.Get_Warranty Finishes ' || x_return_status ||
  			    ' x_warranty_tbl.COUNT=' || l_count);
    END IF;

    x_service_item_ids   := JTF_NUMBER_TABLE();

    IF l_count > 0 THEN
      x_service_item_ids.extend(l_count);
      FOR i in 1..l_count LOOP
        x_service_item_ids(i) := l_warranty_tbl(i).service_item_id;
      END LOOP;
    END IF;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('End IBE_Quote_Misc_pvt.Get_Available_Services');
  END IF;

END Get_Included_Warranties;

PROCEDURE Get_Available_Services(
  p_api_version_number              IN  NUMBER := 1,
  p_init_msg_list                   IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                          IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2,
  p_product_item_id                 IN  NUMBER,
  p_customer_id                     IN  NUMBER,
  p_product_revision                IN  VARCHAR2,
  p_request_date                    IN  DATE,
  x_service_item_ids                OUT NOCOPY JTF_NUMBER_TABLE
) IS
  l_avail_service_rec     ASO_SERVICE_CONTRACTS_INT.Avail_Service_Rec_Type;
  l_orderable_Service_tbl ASO_SERVICE_CONTRACTS_INT.order_service_tbl_type;
  l_count                 NUMBER;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('Start IBE_Quote_Misc_pvt.Get_Available_Services');
     IBE_UTIL.Debug('     Parms: [p_product_item_id=' || p_product_item_id || ', ' ||
			  p_customer_id || ', ' || p_product_revision || ', ' ||
			  p_request_date || ']');
  END IF;

  -- Setting Rec values to be passed to ASO_SERVICE_CONTRACTS_INT
  l_avail_service_rec.product_item_id  := p_product_item_id;
  l_avail_service_rec.customer_id      := p_customer_id;
  l_avail_service_rec.product_revision := p_product_revision;
  l_avail_service_rec.request_date     := p_request_date;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('   ASO_SERVICE_CONTRACTS_INT.Available_Services Starts');
  END IF;
  ASO_SERVICE_CONTRACTS_INT.Available_Services(
	  p_api_version_number     => p_api_version_number,
	  p_init_msg_list          => p_init_msg_list,
	  x_msg_count              => x_msg_count,
	  x_msg_data               => x_msg_data,
	  x_return_status          => x_return_status,
	  p_avail_service_rec      => l_avail_service_rec,
	  x_orderable_service_tbl  => l_orderable_service_tbl
  );

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_count := l_orderable_service_tbl.COUNT;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('   ASO_SERVICE_CONTRACTS_INT.Available_Services Finishes ' || x_return_status || '  ' ||
			  'x_orderable_service_tbl.COUNT=' || l_count);
  END IF;

  x_service_item_ids   := JTF_NUMBER_TABLE();

  IF l_count > 0 THEN
    x_service_item_ids.extend(l_count);
    FOR i IN 1..l_count LOOP
      x_service_item_ids(i) := l_orderable_service_tbl(i).service_item_id;
    END LOOP;
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.Debug('End IBE_Quote_Misc_pvt.Get_Available_Services');
  END IF;

END Get_Available_Services;

Procedure Duplicate_Line(
  p_api_version_number        IN  NUMBER
  ,p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                   IN  VARCHAR2 := FND_API.G_FALSE
  ,X_Return_Status            OUT NOCOPY VARCHAR2
  ,X_Msg_Count                OUT NOCOPY NUMBER
  ,X_Msg_Data                 OUT NOCOPY VARCHAR2
  ,p_quote_header_id          IN  NUMBER
  ,p_qte_line_id              IN  NUMBER
  ,x_qte_line_tbl             IN OUT NOCOPY ASO_Quote_Pub.qte_line_tbl_type
  ,x_qte_line_dtl_tbl         IN OUT NOCOPY ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type
  ,x_line_attr_ext_tbl        IN OUT NOCOPY ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type
  ,x_line_rltship_tbl         IN OUT NOCOPY ASO_Quote_Pub.Line_Rltship_tbl_Type
  ,x_ln_price_attributes_tbl  IN OUT NOCOPY ASO_Quote_Pub.Price_Attributes_Tbl_Type
  ,x_ln_price_adj_tbl         IN OUT NOCOPY ASO_Quote_Pub.Price_Adj_Tbl_Type
)
IS

  l_api_name                    CONSTANT VARCHAR2(30)   := 'Duplicate_Line';
  l_api_version                 CONSTANT NUMBER         := 1.0;

  l_qte_line_dtl_tbl            ASO_Quote_Pub.Qte_Line_Dtl_tbl_Type;
  l_line_rltship_tbl            ASO_Quote_Pub.Line_Rltship_tbl_Type;
  l_line_attr_ext_tbl           ASO_Quote_Pub.Line_Attribs_Ext_tbl_Type;
  l_ln_price_attributes_tbl     ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  l_ln_price_adj_tbl            ASO_Quote_Pub.Price_Adj_Tbl_Type;

  l_initial_count               NUMBER;
  l_initial_dtl_count           NUMBER;

  l_old_config_hdr_id           NUMBER;
  l_old_config_rev_nbr          NUMBER;

  l_new_config_hdr_id           NUMBER;
  l_new_config_rev_nbr          NUMBER;

  -- ER#4025142
  --l_return_value                NUMBER;
  l_ret_status VARCHAR2(1);
  l_msg_count  INTEGER;
  l_orig_item_id_tbl  CZ_API_PUB.number_tbl_type;
  l_new_item_id_tbl   CZ_API_PUB.number_tbl_type;

  CURSOR c_related_lines (p_qte_line_id NUMBER) IS
    SELECT related_quote_line_id
      FROM aso_line_relationships
     START WITH quote_line_id = p_qte_line_id
    CONNECT BY quote_line_id = PRIOR related_quote_line_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    DUPLICATE_LINE_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_initial_dtl_count := x_qte_line_dtl_tbl.COUNT + 1;

   l_initial_count := x_qte_line_tbl.COUNT + 1;
   x_qte_line_tbl(l_initial_count) := IBE_Quote_Misc_pvt.getLineRec(p_qte_line_id);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.Debug('  Adding Lines From c_related_lines');
   END IF;
   FOR l_related_lines_rec IN c_related_lines(p_qte_line_id) LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.Debug('    Adding related_quote_line_id=' || l_related_lines_rec.related_quote_line_id);
      END IF;
      x_qte_line_tbl(x_qte_line_tbl.COUNT + 1) := IBE_Quote_Misc_pvt.getLineRec(l_related_lines_rec.related_quote_line_id);
   END LOOP;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('line number is='|| x_qte_line_tbl.count);
   END IF;
   FOR i IN l_initial_count..x_qte_line_tbl.COUNT LOOP

       l_qte_line_dtl_tbl := IBE_Quote_Misc_pvt.getlineDetailTbl
                             (x_qte_line_tbl(i).quote_line_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.Debug(' Processing LineDetailTbl  Count=' || l_qte_line_dtl_tbl.COUNT);
       END IF;
       FOR j IN 1..l_qte_line_dtl_tbl.COUNT LOOP
         IF l_qte_line_dtl_tbl(j).service_ref_line_id <> fnd_api.g_miss_num THEN
	   -- All service_ref_line_id's should point to first entry in x_qte_line_tbl
           l_qte_line_dtl_tbl(j).service_ref_qte_line_index := l_initial_count;
           l_qte_line_dtl_tbl(j).service_ref_line_id := fnd_api.g_miss_num;
         END IF;
         l_qte_line_dtl_tbl(j).quote_line_detail_id := fnd_api.g_miss_num;
         l_qte_line_dtl_tbl(j).operation_code := 'CREATE';
         l_qte_line_dtl_tbl(j).qte_line_index := i;
         l_qte_line_dtl_tbl(j).quote_line_id := fnd_api.g_miss_num;
         x_qte_line_dtl_tbl(x_qte_line_dtl_tbl.count+1)
               := l_qte_line_dtl_tbl(j);
       END LOOP;


       l_line_rltship_tbl := IBE_Quote_Misc_pvt.getlineRelationshipTbl(x_qte_line_tbl(i).quote_line_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.Debug(' Processing LineRelationshipTbl  Count=' || l_line_rltship_tbl.COUNT);
       END IF;

       FOR j IN 1..l_line_rltship_tbl.COUNT LOOP
          IF NVL(l_line_rltship_tbl(j).relationship_type_code, '*') <> 'SERVICE' THEN
            l_line_rltship_tbl(j).line_relationship_id := fnd_api.g_miss_num;
            l_line_rltship_tbl(j).operation_code := 'CREATE';

            l_line_rltship_tbl(j).qte_line_index := i;
            l_line_rltship_tbl(j).related_qte_line_index
                            := IBE_Quote_Misc_pvt.getLineIndexFromLineId
                               (  l_line_rltship_tbl(j).related_quote_line_id
                                  ,x_qte_line_tbl
                                );
	    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	    IBE_UTIL.Debug('   related_quote_line_id=' || l_line_rltship_tbl(j).related_quote_line_id ||
	                   '   related_quote_line_index=' || l_line_rltship_tbl(j).related_qte_line_index);
	    END IF;
            l_line_rltship_tbl(j).quote_line_id := fnd_api.g_miss_num;
            l_line_rltship_tbl(j).related_quote_line_id := fnd_api.g_miss_num;
            x_line_rltship_tbl(x_line_rltship_tbl.count+1)
                 := l_line_rltship_tbl(j);
          END IF;

       END LOOP;


       l_line_attr_ext_tbl := IBE_Quote_Misc_pvt.getLineAttrExtTbl
                              (x_qte_line_tbl(i).quote_line_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.Debug(' Processing LineAttrExtTbl  Count=' || l_line_attr_ext_tbl.COUNT);
       END IF;

       FOR j IN 1..l_line_attr_ext_tbl.COUNT LOOP
           l_line_attr_ext_tbl(j).line_attribute_id := fnd_api.g_miss_num;
           l_line_attr_ext_tbl(j).operation_code := 'CREATE';
           l_line_attr_ext_tbl(j).qte_line_index := i;
           l_line_attr_ext_tbl(j).quote_line_id := fnd_api.g_miss_num;

           x_line_attr_ext_tbl(x_line_attr_ext_tbl.count+1)
               := l_line_attr_ext_tbl(j);
       END LOOP;

       l_ln_price_attributes_tbl := IBE_Quote_Misc_pvt.getlinePrcAttrTbl
                                    (x_qte_line_tbl(i).quote_line_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.Debug(' Processing linePrcAttrTbl  Count=' || l_ln_price_attributes_tbl.COUNT);
       END IF;

       FOR j IN 1..l_ln_price_attributes_tbl.COUNT LOOP
         l_ln_price_attributes_tbl(j).price_attribute_id := fnd_api.g_miss_num;
         l_ln_price_attributes_tbl(j).operation_code := 'CREATE';
         l_ln_price_attributes_tbl(j).qte_line_index := i;
         l_ln_price_attributes_tbl(j).quote_line_id := fnd_api.g_miss_num;
         l_ln_price_attributes_tbl(j).quote_header_id := p_quote_header_id;
         x_ln_price_attributes_tbl(x_ln_price_attributes_tbl.count+1)
                      := l_ln_price_attributes_tbl(j);
       END LOOP;

       l_ln_price_adj_tbl := getHdrPrcAdjNonPRGTbl
                               (p_qte_header_id      => p_quote_header_id,
						  p_qte_line_id        => x_qte_line_tbl(i).quote_line_id);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.Debug(' Processing LinePriceAdjTbl  Count=' || l_ln_price_adj_tbl.COUNT);
       END IF;

       FOR j IN 1..l_ln_price_adj_tbl.COUNT LOOP
         l_ln_price_adj_tbl(j).price_adjustment_id := fnd_api.g_miss_num;
         l_ln_price_adj_tbl(j).operation_code := 'CREATE';
         l_ln_price_adj_tbl(j).qte_line_index := i;
         l_ln_price_adj_tbl(j).quote_line_id := fnd_api.g_miss_num;
         l_ln_price_adj_tbl(j).quote_header_id := p_quote_header_id;
         x_ln_price_adj_tbl(x_ln_price_adj_tbl.count+1)
                      := l_ln_price_adj_tbl(j);
       END LOOP;

  END LOOP; -- end of get line information

  FOR I IN l_initial_count..x_qte_line_tbl.COUNT LOOP
    x_qte_line_tbl(I).operation_code := 'CREATE';
    x_qte_line_tbl(I).quote_line_id := fnd_api.g_miss_num;
    x_qte_line_tbl(I).quote_header_id := p_quote_header_id;
  END LOOP;

  -- takes care of configuraton item
  FOR i IN l_initial_dtl_count..x_qte_line_dtl_tbl.COUNT LOOP
      IF x_qte_line_tbl(x_qte_line_dtl_tbl(i).qte_line_index).item_type_code
          = 'MDL' THEN
         l_old_config_hdr_id  := x_qte_line_dtl_tbl(i).config_header_id;
         l_old_config_rev_nbr := x_qte_line_dtl_tbl(i).config_revision_num;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('old config id = '|| l_old_config_hdr_id);
            IBE_UTIL.debug('old config rev number = '|| l_old_config_rev_nbr);
         END IF;


         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('call CZ_CONFIG_API_PUB.copy_configuration at'
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         --ER#4025142
         CZ_CONFIG_API_PUB.copy_configuration(p_api_version => l_api_version
                            ,p_config_hdr_id        => l_old_config_hdr_id
                            ,p_config_rev_nbr       => l_old_config_rev_nbr
                            ,p_copy_mode            => CZ_API_PUB.G_NEW_HEADER_COPY_MODE
                            ,x_config_hdr_id        => l_new_config_hdr_id
                            ,x_config_rev_nbr       => l_new_config_rev_nbr
                            ,x_orig_item_id_tbl     => l_orig_item_id_tbl
                            ,x_new_item_id_tbl      => l_new_item_id_tbl
                            ,x_return_status        => l_ret_status
                            ,x_msg_count            => l_msg_count
                            ,x_msg_data             => x_msg_data);
   		 IF (l_ret_status <> FND_API.G_RET_STS_SUCCESS) THEN
             RAISE FND_API.G_EXC_ERROR;
         END IF;


         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('done CZ_CONFIG_API_PUB.Copy_Configuration at'
                 || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('new config id = '|| l_new_config_hdr_id);
            IBE_UTIL.debug('new config rev number = '|| l_new_config_rev_nbr);
         END IF;

         -- update all other dtl table
         FOR j in l_initial_dtl_count..x_qte_line_dtl_tbl.COUNT LOOP
            IF ( x_qte_line_dtl_tbl(j).config_header_id = l_old_config_hdr_id
               and x_qte_line_dtl_tbl(j).config_revision_num = l_old_config_rev_nbr )
            THEN
               x_qte_line_dtl_tbl(j).config_header_id    := l_new_config_hdr_id;
               x_qte_line_dtl_tbl(j).config_revision_num := l_new_config_rev_nbr;
            END IF;
         END LOOP;
      END IF;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('before out line number is='|| x_qte_line_tbl.count);
  END IF;
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count,
                             p_data    => x_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected error IBE_Quote_Misc_pvt.Duplicate_line');
   END IF;

      ROLLBACK TO DUPLICATE_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected error IBE_Quote_Misc_pvt.Duplicate_line');
   END IF;

      ROLLBACK TO DUPLICATE_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
   WHEN OTHERS THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('unknown error IBE_Quote_Misc_pvt.Duplicate_line');
   END IF;

      ROLLBACK TO DUPLICATE_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
END Duplicate_Line;

FUNCTION getHdrPrcAdjNonPRGTbl (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id        IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type
IS
    CURSOR c_price_adj IS
     SELECT
        PRICE_ADJUSTMENT_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     REQUEST_ID,
     QUOTE_HEADER_ID,
     QUOTE_LINE_ID,
     MODIFIER_HEADER_ID,
     MODIFIER_LINE_ID,
     MODIFIER_LINE_TYPE_CODE,
     MODIFIER_MECHANISM_TYPE_CODE,
     MODIFIED_FROM,
        MODIFIED_TO,
     OPERAND,
     ARITHMETIC_OPERATOR,
     AUTOMATIC_FLAG,
     UPDATE_ALLOWABLE_FLAG,
        UPDATED_FLAG,
     APPLIED_FLAG,
     ON_INVOICE_FLAG,
     PRICING_PHASE_ID,
     ATTRIBUTE_CATEGORY,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     TAX_CODE,
     TAX_EXEMPT_FLAG,
     TAX_EXEMPT_NUMBER,
     TAX_EXEMPT_REASON_CODE,
     PARENT_ADJUSTMENT_ID,
     INVOICED_FLAG,
     ESTIMATED_FLAG,
     INC_IN_SALES_PERFORMANCE,
     SPLIT_ACTION_CODE,
     ADJUSTED_AMOUNT,
     CHARGE_TYPE_CODE,
     CHARGE_SUBTYPE_CODE,
     RANGE_BREAK_QUANTITY,
     ACCRUAL_CONVERSION_RATE,
     PRICING_GROUP_SEQUENCE,
     ACCRUAL_FLAG,
     LIST_LINE_NO,
     SOURCE_SYSTEM_CODE,
     BENEFIT_QTY,
     BENEFIT_UOM_CODE,
     PRINT_ON_INVOICE_FLAG,
     EXPIRATION_DATE,
     REBATE_TRANSACTION_TYPE_CODE,
     REBATE_TRANSACTION_REFERENCE,
     REBATE_PAYMENT_SYSTEM_CODE,
     REDEEMED_DATE,
     REDEEMED_FLAG,
     MODIFIER_LEVEL_CODE,
     PRICE_BREAK_TYPE_CODE,
     SUBSTITUTION_ATTRIBUTE,
     PRORATION_TYPE_CODE,
     INCLUDE_ON_RETURNS_FLAG,
     CREDIT_OR_CHARGE_FLAG,
     ORIG_SYS_DISCOUNT_REF,
     CHANGE_REASON_CODE,
     CHANGE_REASON_TEXT,
     COST_ID,
     LIST_LINE_TYPE_CODE,
     UPDATE_ALLOWED,
     CHANGE_SEQUENCE,
     LIST_HEADER_ID,
     LIST_LINE_ID,
     QUOTE_SHIPMENT_ID
        FROM ASO_PRICE_ADJUSTMENTS
     WHERE quote_header_id = p_qte_header_id AND
         (quote_line_id = p_qte_line_id OR
          (quote_line_id IS NULL AND p_qte_line_id IS NULL))
         AND modifier_line_type_code <> 'PRG';

    l_price_adj_rec             ASO_QUOTE_PUB.Price_Adj_Rec_Type;
    l_price_adj_tbl             ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

BEGIN
      FOR price_adj_rec IN c_price_adj LOOP
       l_price_adj_rec.PRICE_ADJUSTMENT_ID := price_adj_rec.PRICE_ADJUSTMENT_ID;
        l_price_adj_rec.CREATION_DATE := price_adj_rec.CREATION_DATE;
        l_price_adj_rec.CREATED_BY := price_adj_rec.CREATED_BY;
        l_price_adj_rec.LAST_UPDATE_DATE := price_adj_rec.LAST_UPDATE_DATE;
        l_price_adj_rec.LAST_UPDATED_BY := price_adj_rec.LAST_UPDATED_BY;
        l_price_adj_rec.LAST_UPDATE_LOGIN := price_adj_rec.LAST_UPDATE_LOGIN;
        l_price_adj_rec.REQUEST_ID := price_adj_rec.REQUEST_ID;
        l_price_adj_rec.PROGRAM_APPLICATION_ID := price_adj_rec.PROGRAM_APPLICATION_ID;
        l_price_adj_rec.PROGRAM_ID := price_adj_rec.PROGRAM_ID;
        l_price_adj_rec.PROGRAM_UPDATE_DATE := price_adj_rec.PROGRAM_UPDATE_DATE;
       l_price_adj_rec.QUOTE_HEADER_ID := price_adj_rec.QUOTE_HEADER_ID;
       l_price_adj_rec.QUOTE_LINE_ID := price_adj_rec.QUOTE_LINE_ID;
       l_price_adj_rec.MODIFIER_HEADER_ID := price_adj_rec.MODIFIER_HEADER_ID;
       l_price_adj_rec.MODIFIER_LINE_ID := price_adj_rec.MODIFIER_LINE_ID;
       l_price_adj_rec.MODIFIER_LINE_TYPE_CODE := price_adj_rec.MODIFIER_LINE_TYPE_CODE;
       l_price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE
                         := price_adj_rec.MODIFIER_MECHANISM_TYPE_CODE;
       l_price_adj_rec.MODIFIED_FROM := price_adj_rec.MODIFIED_FROM;
       l_price_adj_rec.MODIFIED_TO := price_adj_rec.MODIFIED_TO;
       l_price_adj_rec.OPERAND := price_adj_rec.OPERAND;
       l_price_adj_rec.ARITHMETIC_OPERATOR := price_adj_rec.ARITHMETIC_OPERATOR;
       l_price_adj_rec.AUTOMATIC_FLAG := price_adj_rec.AUTOMATIC_FLAG;
       l_price_adj_rec.UPDATE_ALLOWABLE_FLAG := price_adj_rec.UPDATE_ALLOWABLE_FLAG;
       l_price_adj_rec.UPDATED_FLAG := price_adj_rec.UPDATED_FLAG;
       l_price_adj_rec.APPLIED_FLAG := price_adj_rec.APPLIED_FLAG;
       l_price_adj_rec.ON_INVOICE_FLAG := price_adj_rec.ON_INVOICE_FLAG;
       l_price_adj_rec.PRICING_PHASE_ID := price_adj_rec.PRICING_PHASE_ID;
       l_price_adj_rec.QUOTE_SHIPMENT_ID := price_adj_rec.QUOTE_SHIPMENT_ID;
       l_price_adj_rec.ATTRIBUTE_CATEGORY := price_adj_rec.ATTRIBUTE_CATEGORY;
       l_price_adj_rec.ATTRIBUTE1 := price_adj_rec.ATTRIBUTE1;
       l_price_adj_rec.ATTRIBUTE2 := price_adj_rec.ATTRIBUTE2;
       l_price_adj_rec.ATTRIBUTE3 := price_adj_rec.ATTRIBUTE3;
       l_price_adj_rec.ATTRIBUTE4 := price_adj_rec.ATTRIBUTE4;
       l_price_adj_rec.ATTRIBUTE5 := price_adj_rec.ATTRIBUTE5;
       l_price_adj_rec.ATTRIBUTE6 := price_adj_rec.ATTRIBUTE6;
       l_price_adj_rec.ATTRIBUTE7 := price_adj_rec.ATTRIBUTE7;
       l_price_adj_rec.ATTRIBUTE8 := price_adj_rec.ATTRIBUTE8;
       l_price_adj_rec.ATTRIBUTE9 := price_adj_rec.ATTRIBUTE9;
       l_price_adj_rec.ATTRIBUTE10 := price_adj_rec.ATTRIBUTE10;
       l_price_adj_rec.ATTRIBUTE11 := price_adj_rec.ATTRIBUTE11;
       l_price_adj_rec.ATTRIBUTE12 := price_adj_rec.ATTRIBUTE12;
       l_price_adj_rec.ATTRIBUTE13 := price_adj_rec.ATTRIBUTE13;
       l_price_adj_rec.ATTRIBUTE14 := price_adj_rec.ATTRIBUTE14;
       l_price_adj_rec.ATTRIBUTE15 := price_adj_rec.ATTRIBUTE15;
          l_price_adj_rec.TAX_CODE   := price_adj_rec.TAX_CODE;
     l_price_adj_rec.TAX_EXEMPT_FLAG := price_adj_rec.TAX_EXEMPT_FLAG;
     l_price_adj_rec.TAX_EXEMPT_NUMBER := price_adj_rec.TAX_EXEMPT_NUMBER;
     l_price_adj_rec.TAX_EXEMPT_REASON_CODE := price_adj_rec.TAX_EXEMPT_REASON_CODE;
     l_price_adj_rec.PARENT_ADJUSTMENT_ID := price_adj_rec.PARENT_ADJUSTMENT_ID;
     l_price_adj_rec.INVOICED_FLAG := price_adj_rec.INVOICED_FLAG;
     l_price_adj_rec.ESTIMATED_FLAG := price_adj_rec.ESTIMATED_FLAG;
     l_price_adj_rec.INC_IN_SALES_PERFORMANCE := price_adj_rec.INC_IN_SALES_PERFORMANCE;
     l_price_adj_rec.SPLIT_ACTION_CODE := price_adj_rec.SPLIT_ACTION_CODE;
     l_price_adj_rec.ADJUSTED_AMOUNT := price_adj_rec.ADJUSTED_AMOUNT;
     l_price_adj_rec.CHARGE_TYPE_CODE := price_adj_rec.CHARGE_TYPE_CODE;
     l_price_adj_rec.CHARGE_SUBTYPE_CODE := price_adj_rec.CHARGE_SUBTYPE_CODE;
     l_price_adj_rec.RANGE_BREAK_QUANTITY := price_adj_rec.RANGE_BREAK_QUANTITY;
     l_price_adj_rec.ACCRUAL_CONVERSION_RATE := price_adj_rec.ACCRUAL_CONVERSION_RATE;
     l_price_adj_rec.PRICING_GROUP_SEQUENCE := price_adj_rec.PRICING_GROUP_SEQUENCE;
     l_price_adj_rec.ACCRUAL_FLAG := price_adj_rec.ACCRUAL_FLAG;
     l_price_adj_rec.LIST_LINE_NO := price_adj_rec.LIST_LINE_NO;
     l_price_adj_rec.SOURCE_SYSTEM_CODE := price_adj_rec.SOURCE_SYSTEM_CODE;
     l_price_adj_rec.BENEFIT_QTY := price_adj_rec.BENEFIT_QTY;
     l_price_adj_rec.BENEFIT_UOM_CODE := price_adj_rec.BENEFIT_UOM_CODE;
     l_price_adj_rec.PRINT_ON_INVOICE_FLAG := price_adj_rec.PRINT_ON_INVOICE_FLAG;
     l_price_adj_rec.EXPIRATION_DATE := price_adj_rec.EXPIRATION_DATE;
     l_price_adj_rec.REBATE_TRANSACTION_TYPE_CODE := price_adj_rec.REBATE_TRANSACTION_TYPE_CODE;
     l_price_adj_rec.REBATE_TRANSACTION_REFERENCE := price_adj_rec.REBATE_TRANSACTION_REFERENCE;
     l_price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE := price_adj_rec.REBATE_PAYMENT_SYSTEM_CODE;
     l_price_adj_rec.REDEEMED_DATE := price_adj_rec.REDEEMED_DATE;
     l_price_adj_rec.REDEEMED_FLAG := price_adj_rec.REDEEMED_FLAG;
     l_price_adj_rec.MODIFIER_LEVEL_CODE := price_adj_rec.MODIFIER_LEVEL_CODE;
     l_price_adj_rec.PRICE_BREAK_TYPE_CODE := price_adj_rec.PRICE_BREAK_TYPE_CODE;
     l_price_adj_rec.SUBSTITUTION_ATTRIBUTE := price_adj_rec.SUBSTITUTION_ATTRIBUTE;
     l_price_adj_rec.PRORATION_TYPE_CODE := price_adj_rec.PRORATION_TYPE_CODE;
     l_price_adj_rec.INCLUDE_ON_RETURNS_FLAG := price_adj_rec.INCLUDE_ON_RETURNS_FLAG;
     l_price_adj_rec.CREDIT_OR_CHARGE_FLAG := price_adj_rec.CREDIT_OR_CHARGE_FLAG;
     l_price_adj_rec.ORIG_SYS_DISCOUNT_REF := price_adj_rec.ORIG_SYS_DISCOUNT_REF;
     l_price_adj_rec.CHANGE_REASON_CODE := price_adj_rec.CHANGE_REASON_CODE;
     l_price_adj_rec.CHANGE_REASON_TEXT := price_adj_rec.CHANGE_REASON_TEXT;
     l_price_adj_rec.COST_ID := price_adj_rec.COST_ID;
     --l_price_adj_rec.LIST_LINE_TYPE_CODE := price_adj_rec.LIST_LINE_TYPE_CODE;
     l_price_adj_rec.UPDATE_ALLOWED := price_adj_rec.UPDATE_ALLOWED;
     l_price_adj_rec.CHANGE_SEQUENCE := price_adj_rec.CHANGE_SEQUENCE;
     --l_price_adj_rec.LIST_HEADER_ID := price_adj_rec.LIST_HEADER_ID;
     --l_price_adj_rec.LIST_LINE_ID := price_adj_rec.LIST_LINE_ID;
       l_price_adj_tbl(l_price_adj_tbl.COUNT+1) := l_price_adj_rec;
      END LOOP;
      RETURN l_price_adj_tbl;
END getHdrPrcAdjNonPRGTbl;

Procedure Split_Line(
   p_api_version_number     IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,X_Return_Status          OUT NOCOPY VARCHAR2
  ,X_Msg_Count              OUT NOCOPY NUMBER
  ,X_Msg_Data               OUT NOCOPY VARCHAR2
  ,p_quote_header_id        IN  NUMBER
  ,p_qte_line_id            IN  NUMBER
  ,p_quantities             IN  jtf_number_table
  ,p_last_update_date       IN OUT NOCOPY DATE
  ,p_party_id               IN NUMBER := FND_API.G_MISS_NUM
  ,p_cust_account_id        IN NUMBER := FND_API.G_MISS_NUM
  ,p_quote_retrieval_number IN NUMBER := FND_API.G_MISS_NUM
  ,p_minisite_id            IN NUMBER := FND_API.G_MISS_NUM
  ,p_validate_user          IN VARCHAR2 := FND_API.G_FALSE
)
IS
  l_api_name                    CONSTANT VARCHAR2(30)   := 'Split_Line';
  l_api_version                 CONSTANT NUMBER         := 1.0;
  l_qte_header_rec             ASO_QUOTE_PUB.Qte_Header_Rec_Type;
  l_control_rec                ASO_QUOTE_PUB.Control_Rec_Type := ASO_QUOTE_PUB.G_Miss_Control_Rec;
  l_count                      NUMBER;
  l_last_update_date           DATE;
  l_qte_line_count             NUMBER;
  lx_quote_header_id           NUMBER;
  lx_last_update_date          DATE;
  -- Duplicate line Records (Temporary).
  l_qte_line_rec               ASO_QUOTE_PUB.Qte_Line_Rec_Type;
  l_tmp_qte_line_rec           ASO_QUOTE_PUB.Qte_Line_Rec_Type;
  l_qte_line_tbl               ASO_QUOTE_PUB.qte_line_tbl_type;
  lx_qte_line_tbl              ASO_QUOTE_PUB.qte_line_tbl_type;
  l_qte_line_dtl_tbl           ASO_QUOTE_PUB.qte_line_dtl_tbl_type;
  l_line_attr_ext_tbl          ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
  l_line_rltship_tbl           ASO_QUOTE_PUB.line_rltship_tbl_type;
  l_ln_price_attributes_tbl    ASO_QUOTE_PUB.price_attributes_tbl_type;
  l_ln_price_adj_tbl           ASO_QUOTE_PUB.price_adj_tbl_type;
  -- Duplicate line Records (Used for actually calling Save.)
  l_sv_qte_line_tbl            ASO_QUOTE_PUB.qte_line_tbl_type;
  l_sv_qte_line_dtl_tbl        ASO_QUOTE_PUB.qte_line_dtl_tbl_type;
  l_sv_line_attr_ext_tbl       ASO_QUOTE_PUB.line_attribs_ext_tbl_type;
  l_sv_line_rltship_tbl        ASO_QUOTE_PUB.line_rltship_tbl_type;
  l_sv_ln_price_attributes_tbl ASO_QUOTE_PUB.price_attributes_tbl_type;
  l_sv_ln_price_adj_tbl        ASO_QUOTE_PUB.price_adj_tbl_type;
  lx_return_status             VARCHAR2(1);
  lx_msg_count                 NUMBER;
  lx_msg_data                  VARCHAR2(2000);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT    SPLIT_LINE_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      P_Api_Version_Number,
                                      l_api_name,
                                      G_PKG_NAME )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list IF p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   IF p_quantities IS NOT NULL THEN

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.Debug('Validating User Starts: Also Pquantities is not null');
     END IF;

     /* -- 4587019
     l_last_update_date  := IBE_Quote_Misc_pvt.getQuoteLastUpdatedate(p_quote_header_id);

     IF (l_last_update_date <> p_last_update_date) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.Debug('comparing dates');
       END IF;
	   p_last_update_date := l_last_update_date;
       -- raise error

       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name('IBE', 'IBE_SC_QUOTE_NEED_REFRESH');
	     FND_MSG_PUB.ADD;
       END IF;
       RAISE FND_API.G_EXC_ERROR;   -- need error message
     END IF;
     -- 4587019
     */

     -- User Authentication
     IBE_Quote_Misc_pvt.Validate_User_Update
      (	 p_init_msg_list            => p_init_msg_list
   	 ,p_quote_header_id	    => p_quote_header_id
   	 ,p_party_id		    => p_party_id
   	 ,p_cust_account_id	    => p_cust_account_id
   	 ,p_quote_retrieval_number  => p_quote_retrieval_number
   	 ,p_validate_user	    => p_validate_user
   	 ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
       );


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('Validating User Finishes');
      END IF;

     l_qte_header_rec.quote_header_id  := p_quote_header_id;
     l_qte_header_rec.last_update_date := IBE_Quote_Misc_pvt.getQuoteLastUpdatedate(p_quote_header_id);
     l_qte_line_rec.quote_line_id      := p_qte_line_id;
     l_qte_line_count := l_qte_line_tbl.COUNT;

     For counter in 1.. p_quantities.count loop
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('p_quantities(counter) '||p_quantities(counter));
     END IF;
     End loop;

     For counter in 1.. p_quantities.count loop
	   l_qte_line_tbl(counter).quantity:= p_quantities(counter);
     End loop;
     l_control_rec.calculate_tax_flag            := 'Y';
     l_control_rec.calculate_freight_charge_flag := 'Y';
     --mannamra:Removing references to obsoleted profile IBE_PRICE_REQUEST_TYPE see bug 2594529 for details
     l_control_rec.pricing_request_type          := 'ASO';--FND_PROFILE.Value('IBE_PRICE_REQUEST_TYPE');
     l_control_rec.header_pricing_event          := FND_PROFILE.Value('IBE_INCART_PRICING_EVENT');
     l_control_rec.line_pricing_event            := FND_API.G_MISS_CHAR;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('Split_quote_line: aso_split_line_int.split_quote_line:start');
     END IF;
     aso_split_line_int.Split_Quote_line (
       P_Api_Version_Number     => 1.0,
       P_Init_Msg_List          => FND_API.G_TRUE,
       P_Commit                 => FND_API.G_TRUE,
       p_qte_header_rec         => l_qte_header_rec,
       p_original_qte_line_rec  => l_qte_line_rec,
       p_control_rec            => l_control_rec,
       P_Qte_Line_Tbl	        => l_qte_line_tbl,
       X_Qte_Line_Tbl           => lx_qte_line_tbl,
       X_Return_Status          => lx_return_status,
       X_Msg_Count              => lx_msg_count,
       X_Msg_Data               => lx_msg_data    );
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;
     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('Split_quote_line: aso_split_line_int.split_quote_line:end');
     END IF;
   END IF;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.Debug('IBE_Quote_Misc_pvt.Split_Line Ends');
   END IF;
  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
   -- Standard call to get message count and IF count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => lx_msg_count,
                             p_data    => lx_msg_data);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unexpected error IBE_Quote_Misc_pvt.Split_line');
   END IF;
      ROLLBACK TO SPLIT_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => lx_msg_count,
                                p_data    => lx_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Expected error IBE_Quote_Misc_pvt.Split_line');
   END IF;
      ROLLBACK TO SPLIT_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => lx_msg_count,
                                p_data    => lx_msg_data);
   WHEN OTHERS THEN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Unknown error IBE_Quote_Misc_pvt.Split_line');
   END IF;
      ROLLBACK TO SPLIT_LINE_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => lx_msg_count,
                                p_data    => lx_msg_data);
END Split_Line;


Procedure validate_quote(
  p_quote_header_id               IN  NUMBER
 ,p_save_type                     IN  NUMBER
 ,x_return_status              OUT NOCOPY VARCHAR2
 ,x_msg_count                  OUT NOCOPY NUMBER
 ,x_msg_data                   OUT NOCOPY VARCHAR2)
IS
-- Get resource_id, publish_flag and quote_status of a quote.
	cursor c_get_quote_details is
        select a.resource_id,
               a.publish_flag,
               b.status_code,
               a.party_id,
               a.cust_account_id,
               a.quote_source_code
        from aso_quote_headers a ,
             aso_quote_statuses_b b
        where a.quote_status_id = b.quote_status_id
        and a.quote_header_id = p_quote_header_id;

    l_api_name    CONSTANT VARCHAR2(30) := 'Validate_quote';
    l_resource_id         NUMBER;
    l_publish_flag        VARCHAR2(1);
    l_status_code         VARCHAR2(30);
    l_source_code         VARCHAR2(100);
    l_party_id            NUMBER;
    l_cust_account_id     NUMBER;
    l_validate_quote_sts  VARCHAR2(2) := FND_API.G_TRUE;
    l_error               VARCHAR2(1) := FND_API.G_FALSE;

    CURSOR c_get_active_cart(c_quote_header_id NUMBER,
                          c_party_id        NUMBER,
                          c_cust_account_id NUMBER) is
    select quote_header_id
    from ibe_active_quotes
    where quote_header_id = c_quote_header_id
    and party_id          = c_party_id
    and cust_account_id   = c_cust_account_id
    and record_type       = 'CART';


    l_active_cart            NUMBER;
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER   ;
    l_msg_data               VARCHAR2(2000);
    rec_get_active_cart  c_get_active_cart%rowtype;

BEGIN
    SAVEPOINT validate_quote;
    -- Get resource_id, publish_flag and quote_status of a quote.
      --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Begin Validate_quote' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
    END IF;
    open c_get_quote_details;
    fetch c_get_quote_details into l_resource_id,
                                   l_publish_flag,
                                   l_status_code,
                                   l_party_id,
                                   l_cust_account_id,
                                   l_source_code;
    close c_get_quote_details;

    IF l_resource_id is not null and nvl(l_publish_flag,'N')='N' THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Validate_quote, quote is unpublished' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
      END IF;

	  IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
            FND_Message.Set_Name('IBE', 'IBE_SC_QUOTE_NOT_PUBL');
            FND_Msg_Pub.Add;
      END IF;
      l_error := FND_API.G_TRUE;
    END IF;

    IF (p_save_type is not null and
       (p_save_type = END_WORKING OR p_save_type = SAVE_PAYMENT_ONLY
        OR p_save_type = SALES_ASSISTANCE OR p_save_type = PLACE_ORDER OR p_save_type = OP_DUPLICATE_CART)) THEN
      l_validate_quote_sts := FND_API.G_FALSE;
    END IF;

    IF (l_validate_quote_sts = FND_API.G_TRUE) THEN
      IF (l_resource_id is not null) THEN
        IF (FND_Profile.Value('IBE_UPDATE_DRAFT_QUOTES') = 'Y' ) THEN -- Update on Draft profile enabled, only allow updates on DRAFT.
          IF (l_status_code <> 'DRAFT') THEN
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_INVALID_QUOTE_STS');
              FND_Msg_Pub.Add;
            END IF;
            l_error := FND_API.G_TRUE;
          END IF;
        ELSE --  update profile is not enabled, but update call for quote is coming down.
          IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
            FND_Message.Set_Name('IBE', 'IBE_SC_INVALID_OPERATION'); -- Invalid Operation
            FND_Msg_Pub.Add;
          END IF;
          l_error := FND_API.G_TRUE;
        END IF;
     ELSE -- for a cart, check for 'STORE DRAFT'
       IF (l_status_code <> 'STORE DRAFT') THEN
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_INVALID_CART_STS');
              FND_Msg_Pub.Add;
            END IF;
            l_error := FND_API.G_TRUE;
       END IF;
     END IF;
   END IF;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Validate_quote: Validation for one-click start');
   END IF;
   IF (p_save_type <> END_WORKING AND p_save_type <> OP_DELETE_CART) THEN
     IF ((p_save_type = UPDATE_EXPRESSORDER OR p_save_type = SAVE_EXPRESSORDER)
          AND (l_source_code <> 'IStore Oneclick')) THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Validate_quote: Oneclick operation on a non-oneclick cart');
       END IF;
       IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
         FND_Message.Set_Name('IBE', 'IBE_SC_INVALID_OPERATION'); -- Invalid Operation
         FND_Msg_Pub.Add;
       END IF;
       l_error := FND_API.G_TRUE;
     ELSE
       IF ((p_save_type <> UPDATE_EXPRESSORDER AND p_save_type <> SAVE_EXPRESSORDER)
          AND (l_source_code = 'IStore Oneclick')) THEN

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Validate_quote: Non-Oneclick operation on a oneclick cart');
         END IF;

         IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
           FND_Message.Set_Name('IBE', 'IBE_SC_CART_ORDERED');
           FND_Msg_Pub.Add;
         END IF;
         l_error := FND_API.G_TRUE;
       END IF;
     END IF;

   END IF;

   IF (l_error = FND_API.G_TRUE) THEN
     FOR rec_get_active_cart in c_get_active_cart(p_quote_header_id,
                                                 l_party_id,
                                                 l_cust_account_id) LOOP
      l_active_cart := rec_get_active_cart.quote_header_id;
      IF (l_active_cart is not null) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('Validate_quote, active cart found, deactivate it' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
        END IF;

        IBE_QUOTE_SAVESHARE_V2_PVT.DEACTIVATE_QUOTE  (
                 P_Quote_header_id  => p_quote_header_id,
                 P_Party_id         => l_party_id        ,
                 P_Cust_account_id  => l_Cust_account_id ,
                 p_api_version      => 1                 ,
                 p_init_msg_list    => fnd_api.g_false   ,
                 p_commit           => fnd_api.g_true   ,
                 x_return_status    => l_return_status   ,
                 x_msg_count        => l_msg_count       ,
                 x_msg_data         => l_msg_data        );

               IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;
       EXIT when c_get_active_cart%notfound;
      END LOOP;
      RAISE FND_API.G_EXC_ERROR;
   END IF;


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('End validate_quote' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO validate_quote;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
		          p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End With Exp Exception IBE_Quote_Misc_pvt.validate_quote');
  END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO validate_quote;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
			  p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End with UnExp Exception IBE_Quote_Misc_pvt.validate_quote');
   END IF;
  WHEN OTHERS THEN
  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
			   l_api_name);
  END IF;
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
			  p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End with Others Exception IBE_Quote_Misc_pvt.validate_quote');
  END IF;
END validate_quote;

PROCEDURE Validate_User_Update(
 p_api_version_number         IN NUMBER   := 1.0
,p_init_msg_list              IN VARCHAR2 := FND_API.G_FALSE
,p_quote_header_id            IN NUMBER
,p_party_id                   IN NUMBER   := FND_API.G_MISS_NUM
,p_cust_account_id            IN NUMBER   := FND_API.G_MISS_NUM
,p_quote_retrieval_number     IN NUMBER   := FND_API.G_MISS_NUM
,p_validate_user              IN VARCHAR2 := FND_API.G_FALSE
,p_privilege_type_code        IN VARCHAR2 := 'F'
,p_save_type                  IN NUMBER := FND_API.G_MISS_NUM
,p_last_update_date           IN DATE     := FND_API.G_MISS_DATE
,x_return_status              OUT NOCOPY VARCHAR2
,x_msg_count                  OUT NOCOPY NUMBER
,x_msg_data                   OUT NOCOPY VARCHAR2)

IS

l_api_name    CONSTANT VARCHAR2(30) := 'Validate_User_Update';
l_api_version CONSTANT NUMBER       := 1.0;
l_db_quote_header_id NUMBER;
l_party_id NUMBER;
l_user_id NUMBER :=FND_GLOBAL.USER_ID;
l_db_user_id NUMBER;
l_privilege_type_code VARCHAR2(10);
l_end_date_active     DATE;
l_upgrade_flag varchar2(1) := FND_API.G_TRUE;

l_last_update_date DATE;
l_quote_status     VARCHAR2(100);
l_last_updated_by    NUMBER;
l_owner_party_id   NUMBER;
l_resource_id      NUMBER;
l_last_upd_party_id  NUMBER;
l_is_member NUMBER := null;
l_err_code VARCHAR2(50) := null;
l_person_party_id NUMBER;

CURSOR c_getPartyInfo(c_user_id NUMBER) IS
	SELECT customer_id
	from fnd_user
	WHERE user_id = c_user_id;

CURSOR c_getShareeInfo IS
	SELECT quote_header_id,update_privilege_type_code,end_date_active, party_id, cust_account_id
	from ibe_sh_quote_access
	where quote_sharee_number = p_quote_retrieval_number
	and quote_header_id       = p_quote_header_id;

CURSOR c_isSharee(c_party_id NUMBER) IS
	SELECT count(*)
	from ibe_sh_quote_access
	where party_id = c_party_id
	and quote_header_id = p_quote_header_id;

CURSOR c_getQuoteInfo IS
	SELECT quote_header_id
	from aso_quote_headers_all
	where quote_header_id = p_quote_header_id
	AND (party_id = l_party_id OR (party_id = p_party_id AND cust_account_id = p_cust_account_id));

CURSOR c_getQuoteInfo2 IS   -- bug 13517114, scnagara
	SELECT quote_header_id
	from aso_quote_headers_all
	where quote_header_id = p_quote_header_id
	AND party_id in (select relationship_party_id
			FROM IBE_CUSTOMERS_ASSIGNED_V
			where person_party_id = l_person_party_id);

CURSOR c_getPersonPartyInfo(c_user_id NUMBER) IS
	SELECT person_party_id
	from fnd_user
	WHERE user_id = c_user_id;

-- 9/23/02: we're using the next cursor
CURSOR c_getResourceInfo_orig IS
	select resource_id
	from jtf_rs_resource_extns
	where user_id = l_user_id;

-- 9/23/02: new cursor to check for salesrep
Cursor c_getResourceInfo IS
    SELECT j.resource_id
    FROM jtf_rs_srp_vl srp, jtf_rs_resource_extns j
    WHERE j.user_id = l_user_id
      AND j.resource_id = srp.resource_id
      AND srp.status = 'A'
      AND nvl(trunc(srp.start_date_active), trunc(sysdate)) <= trunc(sysdate)
      AND nvl(trunc(srp.end_date_active), trunc(sysdate)) >= trunc(sysdate)
      AND NVL(srp.org_id,MO_GLOBAL.get_current_org_id()) = MO_GLOBAL.get_current_org_id();

--For the last update validation --08/06/2003

Cursor c_last_update_date(c_quote_hdr_id number) is
    SELECT status_code,
           a.last_update_date,
           a.last_updated_by,
           a.party_id,
           a.resource_id
    FROM aso_quote_headers a,
         aso_quote_statuses_vl b
    WHERE quote_header_id = c_quote_hdr_id
    and a.quote_status_id = b.quote_status_id;

rec_last_update_date c_last_update_date%rowtype;

rec_sharee_info      c_getShareeInfo%rowtype;

-- 9/11/02: we want to check if this cart is a guest cart
CURSOR c_getActiveCartTypeInfo IS
  select quote_source_code from aso_quote_headers_all where quote_header_id = p_quote_header_id;
rec_ActiveCartType_info c_getActiveCartTypeInfo%rowtype;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Begin validate_user_update' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version,
			       p_api_version_number,
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
     IBE_UTIL.DEBUG('Incoming party_id is '||p_party_id);
     IBE_UTIL.DEBUG('Incoming cust_account_id is '||p_cust_account_id);
     IBE_UTIL.DEBUG('Incoming quote_header_id is '||p_quote_header_id);
     IBE_UTIL.DEBUG('User id obtained from environment is: '||l_user_id);
     IBE_UTIL.DEBUG('p_save_type is :'||p_save_type);
  END IF;
  IF (FND_API.to_Boolean(p_validate_user) AND p_quote_header_id is not null AND p_quote_header_id <> FND_API.G_MISS_NUM) Then

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Entered Validation...'|| p_validate_user);
    END IF;

    IF (p_quote_retrieval_number is not null AND p_quote_retrieval_number <> FND_API.G_MISS_NUM) then

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('In validating Recipient flow '||p_quote_retrieval_number||' '||to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
      END IF;

      OPEN c_getShareeInfo;
      FETCH c_getShareeInfo INTO rec_sharee_info;
      CLOSE c_getShareeInfo;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('rec_sharee_info.quote_header_id :  '||rec_sharee_info.quote_header_id);
      END IF;

      IF ((rec_sharee_info.quote_header_id is null) OR
	      (nvl(rec_sharee_info.end_date_active,sysdate+1) <= sysdate)) then
        IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
          FND_Msg_Pub.Add;
        END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('quote_retrieval_number::quotehdrId'||'('||p_quote_retrieval_number||','||p_quote_header_id||')');
  	    END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('rec_sharee_info.party_id        :  '||rec_sharee_info.party_id);
        IBE_UTIL.DEBUG('rec_sharee_info.cust_account_id :  '||rec_sharee_info.cust_account_id);
      END IF;


      -- if we have party and acct passed in AND in the table then
      -- check that the passed-in user matches the recipient identity we have in the table
      if ((rec_sharee_info.party_id is not null) and
          (rec_sharee_info.cust_account_id is not null) and
          (p_party_id <> FND_API.G_MISS_NUM) and
          (p_cust_account_id <> FND_API.G_MISS_NUM)) then
        if ((rec_sharee_info.party_id <> p_party_id) or (rec_sharee_info.cust_account_id <> p_cust_account_id)) then
          IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
            FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
            FND_Msg_Pub.Add;
          END IF;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('passed in partyid and account id does not match those of the retrieval number');
            IBE_UTIL.DEBUG('passed in partyid: ' || p_party_id || ' and account id : ' || p_cust_account_id);
            IBE_UTIL.DEBUG('retrieval partyid: ' || rec_sharee_info.party_id || ' and account id : ' || rec_sharee_info.cust_account_id);
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        end if;
      -- otherwise, we may have a case where we can validate and then upgrade a partyless row to have a partyid and acctid
      elsif ((rec_sharee_info.party_id is null) and
          (rec_sharee_info.cust_account_id is null) and
          (p_party_id <> FND_API.G_MISS_NUM) and
          (p_cust_account_id <> FND_API.G_MISS_NUM)) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('we have blank partyid and acctid in the share table, see if we can upgrade this row...');
          IBE_UTIL.DEBUG('passed in partyid: ' || p_party_id || ' and account id : ' || p_cust_account_id);
        END IF;
        upgrade_recipient_row(
          p_party_id         => p_party_id,
          p_cust_account_id  => p_cust_account_id,
          p_retrieval_number => p_quote_retrieval_number,
          p_quote_header_id  => p_quote_header_id,
          x_valid_flag => l_upgrade_flag);
        if (l_upgrade_flag <> FND_API.G_TRUE) then
          IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
            FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
            FND_Msg_Pub.Add;
          END IF;
        end if;
      end if;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('rec_sharee_info.update_privilege_type_code        :  '||rec_sharee_info.update_privilege_type_code);
      END IF;

    --Skip this validation for Duplicate Action
    IF p_save_type <> OP_DUPLICATE_CART THEN
      l_privilege_type_code := rec_sharee_info.update_privilege_type_code;
      IF l_privilege_type_code <> 'A' THEN
        IF l_privilege_type_code = 'F' THEN
          IF p_privilege_type_code <> 'F' AND p_privilege_type_code <> 'R' THEN
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
              FND_Msg_Pub.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          IF p_privilege_type_code <> 'R' THEN
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_ERR_PRIVILEGE');
              FND_Msg_Pub.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;   -- need error message
          END IF;
        END IF;
      end if;
      -- else, the access level is Admin and we are okay to do other validations
      END IF; --Duplicate action
    ELSE
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('no sharee number');
      END IF;

      -- 9/11/02: if the cartId passed in is a Guest Cart, we should not go forth w/ the validation
      OPEN  c_getActiveCartTypeInfo;
      FETCH c_getActiveCartTypeInfo INTO rec_ActiveCartType_info;
      CLOSE c_getActiveCartTypeInfo;
 	  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('quote_source_code of cart passed in='||rec_ActiveCartType_info.quote_source_code);
	  END IF;
      if (rec_ActiveCartType_info.quote_source_code = 'IStore Walkin') then
        return;
      end if;

      IF ((p_party_id is not null AND p_party_id <> FND_API.G_MISS_NUM) AND (p_cust_account_id is not null AND p_cust_account_id <> FND_API.G_MISS_NUM)) THEN

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	      IBE_UTIL.DEBUG('In validating Owner flow: '||p_party_id||','||p_cust_account_id||' '||to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
        END IF;
        OPEN c_getQuoteInfo;
        FETCH c_getQuoteInfo INTO l_db_quote_header_id;
        CLOSE c_getQuoteInfo;
        IF l_db_quote_header_id is null then
          IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
            FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
            FND_Msg_Pub.Add;
          END IF;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('partyId::custAcctId::quotehdrId'||'('||p_party_id||','||p_cust_account_id||','||p_quote_header_id||')');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      ELSE
        -- retrieving user info from environment
        OPEN c_getResourceInfo;
        FETCH c_getResourceInfo INTO l_db_user_id;
        CLOSE c_getResourceInfo;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('Owner flow with env. userid: '||l_db_user_id||' '||to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
        END IF;

        IF l_db_user_id is null then
          OPEN c_getPartyInfo(l_user_id);
          FETCH c_getPartyInfo INTO l_party_id;
          CLOSE c_getPartyInfo;

          OPEN c_getQuoteInfo;
          FETCH c_getQuoteInfo INTO l_db_quote_header_id;
          CLOSE c_getQuoteInfo;

	  IF l_db_quote_header_id is null then
		OPEN c_getPersonPartyInfo(l_user_id);
		FETCH c_getPersonPartyInfo INTO l_person_party_id;
		CLOSE c_getPersonPartyInfo;

		OPEN c_getQuoteInfo2;
		FETCH c_getQuoteInfo2 INTO l_db_quote_header_id;
		CLOSE c_getQuoteInfo2;
	   END IF;

          IF l_db_quote_header_id is null then
            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', 'IBE_SC_USERACCESS_ERR');
              FND_Msg_Pub.Add;
            END IF;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('partyId::quotehdrId'||'('||p_party_id||','||p_quote_header_id||')');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF; -- end if l_db_quote_header_id is null
        END IF; -- end if l_db_user_id is null
      END IF; -- end section of user info from env
    END IF; -- end if no sharee number

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Validate_user_update: Before Last update date validation,p_last_update_date= '||p_last_update_date);
    END IF;

    IF (p_last_update_date <> FND_API.G_MISS_DATE) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Validate_user_update: Last update date validation START');
      END IF;
      FOR rec_last_update_date in c_last_update_date(p_quote_header_id) LOOP
        l_last_update_date  := rec_last_update_date.last_update_date;
        l_quote_status      := rec_last_update_date.status_code;
        l_last_updated_by   := rec_last_update_date.last_updated_by;
        l_owner_party_id    := rec_last_update_date.party_id;
        l_resource_id       := rec_last_update_date.resource_id;
        EXIT when c_last_update_date%NOTFOUND;
      END LOOP;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Validate_user_update: l_last_update_date='||to_char(l_last_update_date,'mm/dd/yyyy:hh24:MI:SS'));
        IBE_UTIL.DEBUG('Validate_user_update: p_last_update_date='||to_char(p_last_update_date,'mm/dd/yyyy:hh24:MI:SS'));
      END IF;
      IF(l_last_update_date <> p_last_update_date) THEN
        IF (l_quote_status = 'ORDER SUBMITTED') THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('Validate_user_update: raising Quote_already_ordered error');
          END IF;

          IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
            FND_Message.Set_Name('IBE', 'IBE_SC_CART_ORDERED');
            FND_Msg_Pub.Add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          IF ((l_last_updated_by <> l_user_id) OR (p_save_type = PLACE_ORDER))  THEN
            -- determine which error message we need to show
            OPEN c_getPartyInfo(l_last_updated_by);
            FETCH c_getPartyInfo INTO l_last_upd_party_id;
            CLOSE c_getPartyInfo;
            -- have to use party id to determine owner since createdby may be the sales rep
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Validate_user_update: l_last_upd_party_id : ' || l_last_upd_party_id);
              IBE_UTIL.DEBUG('Validate_user_update: l_owner_party_id    : ' || l_owner_party_id);
              IBE_UTIL.DEBUG('Validate_user_update: l_resource_id       : ' || l_resource_id);
            END IF;

            -- user is not last updated, and last update is the owner (another member)
            if (l_last_upd_party_id = l_owner_party_id) then
              if (l_resource_id is not null) then
                l_err_code := 'IBE_SC_ERR_RELOAD_Q_MEMBER_UPD';
              else
                l_err_code := 'IBE_SC_ERR_RELOAD_C_MEMBER_UPD';
              end if;
            else
              -- use is not last updated, and last updated is a member
              OPEN c_isSharee(l_last_upd_party_id);
              FETCH c_isSharee INTO l_is_member;
              CLOSE c_isSharee;
              if ((l_is_member is not null) and (l_is_member > 0)) then
                if (l_resource_id is not null) then
                  l_err_code := 'IBE_SC_ERR_RELOAD_Q_MEMBER_UPD';
                else
                  l_err_code := 'IBE_SC_ERR_RELOAD_C_MEMBER_UPD';
                end if;
              end if;
            end if;
            if (l_err_code is null) then
            -- otherwise, the last person to have updated the cart was a sales rep
              l_err_code := 'IBE_SC_ERR_RELOAD_SALESREP_UPD';
            end if;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Validate_user_update: raising Quote_needs_refresh error : ' || l_err_code);
            END IF;

            IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
              FND_Message.Set_Name('IBE', l_err_code);
              FND_Msg_Pub.Add;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Validate_user_update: Last update date validation END');
      END IF;

    END IF; -- last_update_date validation end.

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Before calling validate_quote' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
    END IF;
    -- call an internal api, for quote or cart validation.
    validate_quote(p_quote_header_id,
                   p_save_type,
                   x_return_status,
                   x_msg_count,
                   x_msg_data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('End validate_user_update' || to_char(sysdate, 'mm/dd/yyyy:hh24:MI:SS'));
    END IF;
  END IF; -- end if quote header id is not null
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
		          p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End:Expected exception:IBE_Quote_Misc_pvt.validate_user_update');
  END IF;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
			  p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End:Unexpected exception:IBE_Quote_Misc_pvt.validate_user_update');
   END IF;
  WHEN OTHERS THEN
  IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
			   l_api_name);
  END IF;
  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
			  p_count   => x_msg_count    ,
			  p_data    => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_Util.Debug('End:Others exception:IBE_Quote_Misc_pvt.validate_user_update');
  END IF;
END validate_user_update;

/*This procedure is used to save the missing party_id and cust_account_id
of the recipient before cart activation*/
-- assumes that the retrieval number given has no party id and accountid
PROCEDURE upgrade_recipient_row(
          p_party_id         in NUMBER,
          p_cust_account_id  in NUMBER,
          p_retrieval_number in NUMBER,
          p_quote_header_id  in NUMBER,
          x_valid_flag out NOCOPY VARCHAR2) is

  cursor c_sharee_id(c_retrieval_num NUMBER) is
  select quote_sharee_id
  from   ibe_sh_quote_access
  where  quote_sharee_number = c_retrieval_num ;

  cursor c_get_sold_to(c_quote_header_id NUMBER) is
  select cust_account_id, party_type
  from aso_quote_headers_all a, hz_parties p
  where a.party_id = p.party_id
  and quote_header_id = c_quote_header_id;

  cursor c_get_party_type(c_party_id NUMBER) is
  select party_type
  from hz_parties
  where party_id = c_party_id;

  rec_get_sold_to c_get_sold_to%rowtype;

  l_recip_id        NUMBER := NULL;
  l_sold_to_cust    NUMBER := NULL;
  l_party_type_cart_owner  VARCHAR2(30);
  l_party_type_recipient   VARCHAR2(30);

  BEGIN
    x_valid_flag := FND_API.G_TRUE;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('upgrade_recipient_row: BEGIN ');
      IBE_UTIL.DEBUG('  p_party_id        : ' || p_party_id);
      IBE_UTIL.DEBUG('  p_cust_account_id : ' || p_cust_account_id);
      IBE_UTIL.DEBUG('  p_retrieval_number: ' || p_retrieval_number);
      IBE_UTIL.DEBUG('  p_quote_header_id : ' || p_quote_header_id);
    END IF;

    FOR rec_get_sold_to in c_get_sold_to(p_quote_header_id) LOOP
	  l_sold_to_cust := rec_get_sold_to.cust_account_id;
      l_party_type_cart_owner   := rec_get_sold_to.party_type;
      exit when c_get_sold_to%NOTFOUND;
    END LOOP;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('  cart owner pty type: ' || l_party_type_cart_owner);
    end if;
    IF(l_party_type_cart_owner = 'PARTY_RELATIONSHIP') then
      if (p_cust_account_id <> l_sold_to_cust) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Not upgrading as the b2b cart account id does not match the account id passed in');
        END IF;
        IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
          FND_Msg_Pub.Add;
        END IF;
        x_valid_flag := FND_API.G_FALSE;
  	    RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif (l_party_type_cart_owner = 'PERSON') then
      OPEN c_get_party_type(p_party_id);
      FETCH c_get_party_type into l_party_type_recipient;
      CLOSE c_get_party_type;

      if (l_party_type_cart_owner <> l_party_type_recipient) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('Not saving party and cust_account_id because the recipient is not a b2c user');
           IBE_UTIL.DEBUG('Recipient user type: ' || l_party_type_recipient);
        END IF;
        IF FND_Msg_Pub.Check_Msg_Level (FND_Msg_Pub.G_MSG_LVL_ERROR) THEN
          FND_Message.Set_Name('IBE', 'IBE_SC_ERR_USERACCESS');
          FND_Msg_Pub.Add;
        END IF;
        x_valid_flag := FND_API.G_FALSE;
  	    RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF; -- end person check

    if (x_valid_flag = FND_API.G_TRUE) then
    -- if we passed validations then upgrade the share row with the partyid and accountid
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Upgrading the share row with input partyid and accountid.');
      END IF;

      OPEN c_sharee_id(p_retrieval_number);
      FETCH c_sharee_id into l_recip_id;
      CLOSE c_sharee_id;
      IBE_SH_QUOTE_ACCESS_PKG.update_Row(
        p_QUOTE_SHAREE_ID => l_recip_id
        ,p_party_id        => p_party_id
        ,p_cust_account_id => p_cust_account_id);
    end if;

END upgrade_recipient_row; -- upgrade_recipient_row

PROCEDURE Log_Environment_Info (
   p_quote_header_id      in number := null
) IS

  cursor c_getAppId
    is
    select fnd_global.resp_appl_id appId from dual;
  rec_AppId                       c_getAppId%rowtype;

  cursor c_getRespId
    is
    select fnd_global.resp_id respId from dual;
  rec_RespId                       c_getRespId%rowtype;

  cursor c_getUserId
    is
    select fnd_global.user_id userId from dual;
  rec_UserId                       c_getUserId%rowtype;

  cursor c_getOrgId
    is
    SELECT  (MO_GLOBAL.get_current_org_id()) orgId from dual;
  rec_OrgId                       c_getOrgId%rowtype;

  cursor c_getEnvInfo
    is
    SELECT FND_GLOBAL.SESSION_ID session_id
          ,FND_GLOBAL.USER_NAME user_name
		,FND_GLOBAL.LOGIN_ID login_id
		,userenv('CLIENT_INFO') client_info
		,userenv('LANG') lang
    FROM dual;
  rec_EnvInfo                     c_getEnvInfo%rowtype;

  cursor c_getICXSessionDetails(p_session_id VARCHAR2)
    is
    SELECT SESSION_ID
          ,USER_ID
		,RESPONSIBILITY_ID
		,ORG_ID
		,NLS_LANGUAGE
		,CREATED_BY
		,CREATION_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATE_LOGIN
		,RESPONSIBILITY_APPLICATION_ID
		,SECURITY_GROUP_ID
		,PAGE_ID,LOGIN_ID
		,TIME_OUT
    FROM  icx_sessions
    WHERE session_id = p_session_id;
  rec_ICXSessionDetails           c_getICXSessionDetails%rowtype;

  cursor c_getMOTempTableInfo
    is
    SELECT * from  MO_GLOB_ORG_ACCESS_TMP;
  rec_MOTempTableInfo             c_getMOTempTableInfo%rowtype;

  cursor c_getSysContext
    is
    SELECT sys_context('multi_org2','current_org_id') sys_context from dual;
  rec_SysContext                  c_getSysContext%rowtype;

Begin
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: Begin');
  END IF;

  -- 1. AppId
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: AppId:  Begin');
  END IF;
  open c_getAppId;
  fetch c_getAppId into rec_AppId;
  close c_getAppId;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: AppId:  End='||rec_AppId.appId);
  END IF;

  -- 2. RespId
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: RespId: Begin');
  END IF;
  open c_getRespId;
  fetch c_getRespId into rec_RespId;
  close c_getRespId;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: RespId:  End='||rec_RespId.respId);
  END IF;

  -- 3. UserId
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: UserId: Begin');
  END IF;
  open c_getUserId;
  fetch c_getUserId into rec_UserId;
  close c_getUserId;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: UserId:  End='||rec_UserId.userId);
  END IF;

  -- 4. OrgId
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: OrgId:  Begin');
  END IF;
  open c_getOrgId;
  fetch c_getOrgId into rec_OrgId;
  close c_getOrgId;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: OrgId:  End='||rec_OrgId.orgId);
  END IF;

  -- 5. EnvInfo
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: EnvInfo:  Begin');
  END IF;
  open c_getEnvInfo;
  fetch c_getEnvInfo into rec_EnvInfo;
  close c_getEnvInfo;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Session_id='||rec_EnvInfo.session_id);
     IBE_UTIL.DEBUG('UserName='||rec_EnvInfo.user_name);
     IBE_UTIL.DEBUG('login_id='||rec_EnvInfo.login_id);
     IBE_UTIL.DEBUG('Client_info='||rec_EnvInfo.client_info);
     IBE_UTIL.DEBUG('Language='||rec_EnvInfo.lang);
     IBE_UTIL.DEBUG('Log_Environment_Info: EnvInfo:  End');
  END IF;

  -- 6. ICXSession Details
  /*  COMMENTED OUT..NEED TO GET THE ICX SESSION ID AND RUN THE CURSOR.
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: ICXSessionDetails:  Begin');
  END IF;
  open c_getICXSessionDetails(rec_EnvInfo.session_id);
  fetch c_getICXSessionDetails into rec_ICXSessionDetails;
  close c_getICXSessionDetails;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('session_id='||rec_ICXSessionDetails.session_id);
     IBE_UTIL.DEBUG('user_id='||rec_ICXSessionDetails.user_id);
     IBE_UTIL.DEBUG('responsibility_id='||rec_ICXSessionDetails.responsibility_id);
     IBE_UTIL.DEBUG('org_id='||rec_ICXSessionDetails.org_id);
     IBE_UTIL.DEBUG('nls_language='||rec_ICXSessionDetails.nls_language);
     IBE_UTIL.DEBUG('created_by='||rec_ICXSessionDetails.created_by);
     IBE_UTIL.DEBUG('creation_date='||rec_ICXSessionDetails.creation_date);
     IBE_UTIL.DEBUG('last_updated_by='||rec_ICXSessionDetails.last_updated_by);
     IBE_UTIL.DEBUG('last_update_date='||rec_ICXSessionDetails.last_update_date);
     IBE_UTIL.DEBUG('last_update_login='||rec_ICXSessionDetails.last_update_login);
     IBE_UTIL.DEBUG('responsibility_application_id='||rec_ICXSessionDetails.responsibility_application_id);
     IBE_UTIL.DEBUG('security_group_id='||rec_ICXSessionDetails.security_group_id);
     IBE_UTIL.DEBUG('page_id='||rec_ICXSessionDetails.page_id);
     IBE_UTIL.DEBUG('login_id='||rec_ICXSessionDetails.login_id);
     IBE_UTIL.DEBUG('time_out='||rec_ICXSessionDetails.time_out);
     IBE_UTIL.DEBUG('Log_Environment_Info: ICXSessionDetails:  End');
  END IF; */

  -- 7.MO Temp Table details
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: MOTempTableDetails:  Begin');
  END IF;
  open c_getMOTempTableInfo;
  fetch c_getMOTempTableInfo into rec_MOTempTableInfo;
  close c_getMOTempTableInfo;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('organization_id='||rec_MOTempTableInfo.organization_id);
     IBE_UTIL.DEBUG('organization_name='||rec_MOTempTableInfo.organization_name);
     IBE_UTIL.DEBUG('legal_entity_id='||rec_MOTempTableInfo.legal_entity_id);
     IBE_UTIL.DEBUG('legal_entity_name='||rec_MOTempTableInfo.legal_entity_name);
     IBE_UTIL.DEBUG('Log_Environment_Info: MOTempTableDetails:  End');
  END IF;

  -- 8. SysContext
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: SysContext:  Begin');
  END IF;
  open c_getSysContext;
  fetch c_getSysContext into rec_SysContext;
  close c_getSysContext;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Sys_Context='||rec_SysContext.sys_context);
     IBE_UTIL.DEBUG('Log_Environment_Info: SysContext:  End');
  END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Log_Environment_Info: End');
  END IF;

END Log_Environment_Info;

FUNCTION Get_party_name (
		p_party_id		NUMBER,
		p_party_type    VARCHAR2
		)
RETURN VARCHAR2
 IS
 CURSOR C1 IS
 select HP.party_id,HP.party_name
  from hz_relationships HPR,hz_parties HP where hpr.party_id = p_party_id
  and HPR.subject_type = 'PERSON'
  and HPR.object_type = 'ORGANIZATION'
  and hp.party_id=HPR.subject_id;
  CURSOR C2 IS
   select party_id,party_name
  from hz_parties HP where  party_id = p_party_id;
  l_party_name VARCHAR2(360);
  l_party_id NUMBER;
  BEGIN
   IF p_party_type = 'PARTY_RELATIONSHIP' THEN
     OPEN C1;
     FETCH C1 INTO l_party_id,l_party_name;
        IF C1%NOTFOUND OR l_party_name IS NULL THEN
            CLOSE C1;
            l_party_name := NULL;
            RETURN  l_party_name;
        END IF;
     CLOSE C1;
     RETURN  l_party_name;
   ELSE
         OPEN C2;
         FETCH C2 INTO l_party_id,l_party_name;
        IF C2%NOTFOUND OR l_party_name IS NULL THEN
            CLOSE C2;
            l_party_name := NULL;
            RETURN  l_party_name;
        END IF;
     CLOSE C2;
     RETURN  l_party_name;
   END IF;
END Get_party_name;

PROCEDURE Add_Attachment(
  p_api_version_number    IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit               IN  VARCHAR2 := FND_API.G_FALSE
  ,p_category_id          IN  VARCHAR2
  ,p_document_description IN  VARCHAR2
  ,p_datatype_id          IN  VARCHAR2
  ,p_text                 IN  LONG
  ,p_file_name            IN  VARCHAR2
  ,p_url                  IN  VARCHAR2
  ,p_function_name        IN  VARCHAR2 := null
  ,p_quote_header_id      IN  NUMBER
  ,p_media_id             IN  NUMBER
  ,p_party_id             IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_cust_account_id      IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_retrieval_number     IN  NUMBER   := FND_API.G_MISS_NUM
  ,p_validate_user        IN  VARCHAR2 := FND_API.G_FALSE
  ,p_last_update_date     IN  DATE     :=FND_API.G_MISS_DATE
  ,p_save_type            IN  NUMBER   := FND_API.G_MISS_NUM
  ,x_last_update_date     OUT NOCOPY  DATE
  ,x_return_status        OUT NOCOPY  VARCHAR2
  ,x_msg_count            OUT NOCOPY  NUMBER
  ,x_msg_data             OUT NOCOPY  VARCHAR2
)
IS
  l_api_name         CONSTANT VARCHAR2(30)    := 'Add_Attachment';
  l_api_version      CONSTANT NUMBER          := 1.0;
  l_seq_num          VARCHAR2(30)			  := NULL;

BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin IBE_Quote_Misc_pvt.Add_Attachment()');
   END IF;

   -- Standard Start of API savepoint
   SAVEPOINT    Add_Attachment;

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

  -- User Authentication
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Call to Validate_User_Update');
  END IF;

  IBE_Quote_Misc_pvt.Validate_User_Update
   (  p_init_msg_list   => p_Init_Msg_List
     ,p_quote_header_id => p_quote_header_id
     ,p_party_id        => p_party_id
     ,p_cust_account_id => p_cust_account_id
     ,p_validate_user   => p_validate_user
     ,p_quote_retrieval_number => p_retrieval_number
     ,p_save_type        => p_save_type
     ,p_last_update_date => p_last_update_date
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
    );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Call to ASO_ATTACHMENT_INT.Add_Attachment');
   END IF;

   l_seq_num := to_char(FND_CRYPTO.SmallRandomNumber);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('l_seq_num = '||l_seq_num);
   END IF;

  -- ASO Attachment Procedure Call
  ASO_ATTACHMENT_INT.Add_Attachment
  (
      p_api_version_number  => p_api_version_number
     ,p_init_msg_list       => p_init_msg_list
     ,p_commit              => p_commit
     ,p_seq_num             => l_seq_num
     ,p_category_id         => p_category_id
     ,p_document_description=> p_document_description
     ,p_datatype_id         => p_datatype_id
     ,p_text                => p_text
     ,p_file_name            => p_file_name
     ,p_url                    => p_url
     ,p_function_name       => p_function_name
     ,p_quote_header_id     => p_quote_header_id
     ,p_media_id            => p_media_id
     ,x_return_status       => x_return_status
     ,x_msg_count           => x_msg_count
     ,x_msg_data            => x_msg_data
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End ASO_ATTACHMENT_INT.Add_Attachment');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Add_Attachment;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_last_update_date := getQuoteLastUpdateDate(p_quote_header_id);
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Misc_pvt.Add_Attachment()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Add_Attachment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_last_update_date := getQuoteLastUpdateDate(p_quote_header_id);
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Misc_pvt.Add_Attachment()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO  Add_Attachment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Misc_pvt.Add_Attachment()');
      END IF;

END Add_Attachment;


PROCEDURE Delete_Attachment(
   p_api_version_number   IN  NUMBER
  ,p_init_msg_list        IN  VARCHAR2
  ,p_commit               IN  VARCHAR2
  ,p_quote_header_id      IN  NUMBER
  ,p_quote_attachment_ids IN  JTF_VARCHAR2_TABLE_100
  ,p_last_update_date     IN  DATE
  ,p_party_id             IN  NUMBER
  ,p_cust_account_id      IN  NUMBER
  ,p_retrieval_number     IN  NUMBER
  ,x_last_update_date     OUT NOCOPY   DATE
  ,x_return_status        OUT NOCOPY   VARCHAR2
  ,x_msg_count            OUT NOCOPY   NUMBER
  ,x_msg_data             OUT NOCOPY   VARCHAR2
)
IS
  l_api_name         CONSTANT VARCHAR2(30)    := 'Delete_Attachment';
  l_api_version      CONSTANT NUMBER          := 1.0;

BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Begin IBE_Quote_Misc_pvt.Delete_Attachment()');
   END IF;

   -- Standard Start of API savepoint
   SAVEPOINT    Add_Attachment;

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

  -- User Authentication
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_Util.Debug('Call to Validate_User_Update');
  END IF;

  IBE_Quote_Misc_pvt.Validate_User_Update(
      p_quote_header_id => p_quote_header_id
     ,p_party_id        => p_party_id
     ,p_cust_account_id => p_cust_account_id
     ,p_validate_user   => FND_API.G_TRUE
     ,p_quote_retrieval_number => p_retrieval_number
     ,p_last_update_date => p_last_update_date
     ,x_return_status    => x_return_status
     ,x_msg_count        => x_msg_count
     ,x_msg_data         => x_msg_data
    );

   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('Call to ASO_ATTACHMENT_INT.Delete_Attachment');
   END IF;

  -- ASO Attachment Procedure Call
  ASO_ATTACHMENT_INT.Delete_Attachments
  (
      p_api_version_number   => p_api_version_number
     ,p_init_msg_list        => p_init_msg_list
     ,p_commit               => p_commit
     ,p_quote_header_id      => p_quote_header_id
     ,p_quote_attachment_ids => p_quote_attachment_ids
     ,x_return_status        => x_return_status
     ,x_msg_count            => x_msg_count
     ,x_msg_data             => x_msg_data
   );

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_Util.Debug('End ASO_ATTACHMENT_INT.Delete_Attachment');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO  Add_Attachment;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_last_update_date := getQuoteLastUpdateDate(p_quote_header_id);
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Misc_pvt.Delete_Attachment()');
      END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO  Add_Attachment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_last_update_date := getQuoteLastUpdateDate(p_quote_header_id);
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Misc_pvt.Delete_Attachment()');
      END IF;

   WHEN OTHERS THEN
      ROLLBACK TO  Add_Attachment;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_Msg_Pub.Check_Msg_Level(FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                                 l_api_name);
      END IF;

      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count    ,
                                p_data    => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_Util.Debug('End   IBE_Quote_Misc_pvt.Delete_Attachment()');
      END IF;

END Delete_Attachment;

FUNCTION get_aso_quote_status (p_quote_header_id NUMBER) RETURN VARCHAR2 is

CURSOR c_quote_status_code (quote_hdr_id number) is
    select status_code
    from aso_quote_headers_all a,   aso_quote_statuses_vl b
    where quote_header_id = quote_hdr_id
    and a.quote_status_id = b.quote_status_id;

 rec_quote_status_code   c_quote_status_code%rowtype;
 l_quote_status_code     aso_quote_statuses_vl.status_code%type;


BEGIN

for rec_quote_status_code in c_quote_status_code(p_quote_header_id) loop
  l_quote_status_code := rec_quote_status_code.status_code;
  exit when c_quote_status_code%notfound;
end loop;

RETURN l_quote_status_code;

END get_aso_quote_status;

PROCEDURE get_primary_file_id(p_quote_id IN NUMBER,
                              x_file_id OUT NOCOPY NUMBER) is

file_id  NUMBER;
BEGIN

IF (OKC_TERMS_UTIL_GRP.has_terms (p_document_type => 'QUOTE', p_document_id => p_quote_id) = 'Y') THEN

  x_file_id := OKC_TERMS_UTIL_GRP.get_primary_terms_doc_file_id(p_document_type => 'QUOTE',
                                                              p_document_id => p_quote_id);
ELSE
  x_file_id := 0;
END IF;

END get_primary_file_id;

END IBE_Quote_Misc_pvt;

/
