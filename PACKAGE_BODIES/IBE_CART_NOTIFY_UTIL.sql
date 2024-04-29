--------------------------------------------------------
--  DDL for Package Body IBE_CART_NOTIFY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CART_NOTIFY_UTIL" AS
/* $Header: IBEVCNUB.pls 120.3 2005/12/15 00:55:31 banatara ship $ */
-- Start of Comments
-- Package name     : IBE_Cart_Notify_Util
-- Purpose          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_CART_NOTIFY_UTIL';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVCNUB.pls';

PROCEDURE Get_sales_assist_hdr_tokens(
                 p_api_version      IN  NUMBER   := 1.0            ,
                 p_init_msg_list    IN  VARCHAR2 := FND_API.G_TRUE ,
                 p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                 x_return_status    OUT NOCOPY VARCHAR2            ,
                 x_msg_count        OUT NOCOPY NUMBER              ,
                 x_msg_data         OUT NOCOPY VARCHAR2            ,
                 p_quote_header_id  IN  NUMBER                     ,
                 p_minisite_id      IN  NUMBER                     ,
                 x_Contact_Name     OUT NOCOPY VARCHAR2            ,
                 x_Contact_phone    OUT NOCOPY VARCHAR2            ,
                 x_email            OUT NOCOPY VARCHAR2            ,
                 x_first_name       OUT NOCOPY VARCHAR2            ,
                 X_last_name        OUT NOCOPY VARCHAR2            ,
                 x_Cart_name        OUT NOCOPY VARCHAR2            ,
                 X_cart_date        OUT NOCOPY VARCHAR2            ,
                 x_Ship_to_name     OUT NOCOPY VARCHAR2            ,
                 x_ship_to_address1 OUT NOCOPY VARCHAR2            ,
                 x_ship_to_address2 OUT NOCOPY VARCHAR2            ,
                 x_ship_to_address3 OUT NOCOPY VARCHAR2            ,
                 x_ship_to_address4 OUT NOCOPY VARCHAR2            ,
                 x_country          OUT NOCOPY VARCHAR2            ,
                 X_CITY             OUT NOCOPY VARCHAR2            ,
                 X_POSTAL_CODE      OUT NOCOPY VARCHAR2            ,
                 X_SHIP_TO_STATE    OUT NOCOPY VARCHAR2            ,
                 X_SHIP_TO_PROVINCE OUT NOCOPY VARCHAR2            ,
                 X_SHIP_TO_COUNTY   OUT NOCOPY VARCHAR2            ,
                 x_shipping_method  OUT NOCOPY VARCHAR2            ,
                 x_minisite_name    OUT NOCOPY VARCHAR2            ,
                 x_ship_and_hand    OUT NOCOPY NUMBER              ,
                 x_tax              OUT NOCOPY NUMBER              ,
                 x_total            OUT NOCOPY NUMBER              ) IS


  CURSOR c_get_minisite_token(p_minisite_id number) is
         SELECT msite_name
         FROM ibe_msites_vl
         where msite_id = p_minisite_id;

  CURSOR c_get_notify_hdr_tokens(p_quote_header_id number, inv_org_id number) is
         SELECT qh.quote_name,
                qh.last_update_date,
                s.ship_to_cust_account_id,
                ip.party_name SHIP_TO_CUST_NAME,
                nvl(loc.ADDRESS1,'') add1,
                nvl(loc.ADDRESS2,'') add2,
                nvl(loc.ADDRESS3,'') add3,
                nvl(loc.ADDRESS4,'') add4,
                nvl(loc.COUNTRY,'') country,
                nvl(loc.CITY,'') city,
                nvl(loc.POSTAL_CODE,'') zip,
                nvl(loc.STATE,'') state,
                nvl(loc.PROVINCE,'') province,
                nvl(loc.COUNTY,'') county,
                fl.MEANING SHIP_METHOD_CODE_MEANING,
                qh.TOTAL_SHIPPING_CHARGE,
                qh.TOTAL_TAX,
                qh.TOTAL_QUOTE_PRICE
         FROM aso_quote_headers_all    qh,
                aso_shipments s,
                hz_party_sites ps,
                hz_locations loc,
                aso_i_parties_v ip,
                wsh_carrier_ship_methods csm,
                fnd_lookup_values_vl fl
         WHERE qh.quote_header_id = s.quote_header_id
           and s.ship_to_party_site_id = ps.party_site_id(+)
           and s.ship_to_cust_party_id = ip.party_id(+)
           and ps.location_id = loc.location_id(+)
           and s.ship_method_code = csm.ship_method_code
           and fl.lookup_type = 'SHIP_METHOD'
           and fl.lookup_code = csm.ship_method_code
           and fl.view_application_id = 3
           and qh.quote_header_id = p_quote_header_id
           and organization_id    = inv_org_id;


  CURSOR c_get_contact_tokens(p_quote_header_id number) is
         SELECT ap.party_name,
                ap.person_first_name,
                ap.person_last_name,
                ap.party_type,
                DECODE(ap.party_type, 'PERSON', NULL, ap.party_name) organization_name,
                nvl(h.email_address,'') email,
                nvl(h.phone_area_code,'') ph_area_code,
                nvl(h.phone_number,'') ph_number,
                nvl(h.phone_extension,'') ph_extension,
                h.phone_line_type ,
                h.contact_point_purpose,
                h.contact_point_type

         FROM hz_contact_points h,
              aso_i_parties_v  ap,
              fnd_user         fnd
         where fnd.user_id       = FND_GLOBAL.USER_ID
           and owner_table_name  = 'HZ_PARTIES'
           and owner_table_id    = fnd.customer_id
           and fnd.customer_id   = ap.party_id
           and h.status            = 'A';


  G_PKG_NAME            CONSTANT VARCHAR2(30) := 'IBE_CART_NOTIFY_UTIL';
  l_api_name            CONSTANT VARCHAR2(50) := 'Get_sales_assist_tokens_pvt';
  l_api_version         number := 1.0;

  l_ship_to_cust_name         varchar2(360);
  l_ship_to_address           varchar2(2000);
  l_contact_phone             varchar2(100);
  l_inv_org_id                number;
  l_ship_to_cust_id           NUMBER;
  rec_get_minisite_token      c_get_minisite_token%rowtype;
  rec_get_notify_hdr_tokens   c_get_notify_hdr_tokens%rowtype;
  rec_get_contact_tokens      c_get_contact_tokens%rowtype;


 BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Get_sales_assist_tokens_pvt;

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
  l_inv_org_id := fnd_profile.value_specific('IBE_ITEM_VALIDATION_ORGANIZATION',null,null,671);
  --671 is the application_id for iStore
  for rec_get_minisite_token in c_get_minisite_token(p_minisite_id) loop
    x_minisite_name := rec_get_minisite_token.msite_name;
    exit when c_get_minisite_token%notfound;
  end loop;

  for rec_get_notify_hdr_tokens in c_get_notify_hdr_tokens(p_quote_header_id,l_inv_org_id) loop

    l_ship_to_cust_id   := rec_get_notify_hdr_tokens.ship_to_cust_account_id;
    l_ship_to_cust_name := rec_get_notify_hdr_tokens.ship_to_cust_name;
    /*if rec_get_notify_hdr_tokens.ship_to_cust_account_id is not null then
      x_Ship_to_name := rec_get_notify_hdr_tokens.ship_to_cust_name;
    else
      x_Ship_to_name := rec_get_notify_hdr_tokens.organization_name;
    end if;*/
    x_cart_name        := rec_get_notify_hdr_tokens.quote_name;
    x_cart_date        := rec_get_notify_hdr_tokens.last_update_date;
    x_shipping_method  := rec_get_notify_hdr_tokens.ship_method_code_meaning;
    x_ship_and_hand    := rec_get_notify_hdr_tokens.TOTAL_SHIPPING_CHARGE;
    x_tax              := rec_get_notify_hdr_tokens.TOTAL_TAX;
    x_total            := rec_get_notify_hdr_tokens.TOTAL_QUOTE_PRICE;
    X_ship_to_address1 := rec_get_notify_hdr_tokens.add1;
    X_ship_to_address2 := rec_get_notify_hdr_tokens.add2;
    X_ship_to_address3 := rec_get_notify_hdr_tokens.add3;
    X_ship_to_address4 := rec_get_notify_hdr_tokens.add4;
    X_country          := rec_get_notify_hdr_tokens.country;
    x_city             := rec_get_notify_hdr_tokens.city;
    x_postal_code      := rec_get_notify_hdr_tokens.zip;
    x_ship_to_state    := rec_get_notify_hdr_tokens.state;
    x_ship_to_province := rec_get_notify_hdr_tokens.province;
    x_ship_to_county   := rec_get_notify_hdr_tokens.county;
  exit when c_get_notify_hdr_tokens%notfound;
  end loop;

  for rec_get_contact_tokens in c_get_contact_tokens(p_quote_header_id) loop

    IF l_ship_to_cust_id is not null THEN
      x_Ship_to_name := l_ship_to_cust_name;
    ELSE
      x_Ship_to_name := rec_get_contact_tokens.organization_name;
    END IF;

    IF (rec_get_contact_tokens.contact_point_type = 'EMAIL') THEN
      x_email := rec_get_contact_tokens.email;
    END IF;

    IF(rec_get_contact_tokens.party_type = 'PARTY_RELATIONSHIP' ) THEN
      x_contact_name   := rec_get_contact_tokens.person_first_name;
      x_contact_name   := x_contact_name||' '||rec_get_contact_tokens.person_last_name;
    ELSE
      x_contact_name     := rec_get_contact_tokens.party_name;
    END IF;
    x_first_name       := rec_get_contact_tokens.person_first_name;
    x_last_name        := rec_get_contact_tokens.person_last_name;

    IF ((rec_get_contact_tokens.contact_point_type = 'PHONE')
        and (rec_get_contact_tokens.phone_line_type  = 'GEN' )
        and (rec_get_contact_tokens.contact_point_purpose = 'BUSINESS')) THEN
          l_contact_phone := rec_get_contact_tokens.ph_area_code||'-';
          l_contact_phone := l_contact_phone||rec_get_contact_tokens.ph_number;
          l_contact_phone := l_contact_phone||rec_get_contact_tokens.ph_extension;
    END IF;
  exit when c_get_contact_tokens%notfound;
  end loop;

  x_contact_phone := l_contact_phone;

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
     ROLLBACK TO Get_sales_assist_tokens_pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Get_sales_assist_tokens_pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Get_sales_assist_tokens_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                              L_API_NAME);
    END IF;

    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                              p_count   => x_msg_count    ,
                              p_data    => x_msg_data);

END Get_sales_assist_hdr_tokens;

  PROCEDURE Get_sales_assist_line_tokens(
                 p_api_version        IN  NUMBER   := 1.0                  ,
                 p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE       ,
                 p_commit             IN  VARCHAR2 := FND_API.G_FALSE      ,
                 x_return_status      OUT NOCOPY VARCHAR2                         ,
                 x_msg_count          OUT NOCOPY NUMBER                           ,
                 x_msg_data           OUT NOCOPY VARCHAR2                         ,
                 P_quote_header_id    IN  NUMBER                           ,
                 x_notify_line_tokens OUT NOCOPY IBE_CART_NOTIFY_UTIL.notify_line_tokens_tab_type) is

  CURSOR c_get_notify_line_tokens(p_quote_header_id number) is
         SELECT qh.quote_header_id,
                ql.quote_line_id,
                ql.quantity,
                ql.line_quote_price,
                m.shippable_item_flag,
                m.inventory_item_id,
                m.description

         FROM  aso_quote_headers_all qh,
               aso_quote_lines_all   ql,
               mtl_system_items_vl   m
         where qh.quote_header_id = ql.quote_header_id
           and ql.inventory_item_id = m.inventory_item_id
           and ql.organization_id = m.organization_id
           and qh.quote_header_id = p_quote_header_id;

  G_PKG_NAME            CONSTANT VARCHAR2(30) := 'IBE_CART_NOTIFY_UTIL';
  l_api_name            CONSTANT VARCHAR2(100) := 'Get_sales_assist_line_tokens';
  l_api_version         number := 1.0;
  loop_counter          number := 1;
  l_notify_line_tokens  IBE_CART_NOTIFY_UTIL.notify_line_tokens_tab_type;

  BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT Create_New_Version_Pvt;

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
  for rec_get_notify_line_tokens in c_get_notify_line_tokens(p_quote_header_id) loop
     l_notify_line_tokens(loop_counter).Quote_line_id    := rec_get_notify_line_tokens.quote_line_id;
     l_notify_line_tokens(loop_counter).item_name        := rec_get_notify_line_tokens.description;
     l_notify_line_tokens(loop_counter).Item_Quantity    := rec_get_notify_line_tokens.Quantity;
     l_notify_line_tokens(loop_counter).Shippable_flag   := rec_get_notify_line_tokens.shippable_item_flag;
     l_notify_line_tokens(loop_counter).line_quote_price := rec_get_notify_line_tokens.line_quote_price;

     loop_counter := loop_counter+1;
  EXIT when c_get_notify_line_tokens%NOTFOUND;
  END LOOP;
  x_notify_line_tokens := l_notify_line_tokens;
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
     ROLLBACK TO Create_New_Version_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_New_Version_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_New_Version_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                              L_API_NAME);
    END IF;

  FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                            p_count   => x_msg_count    ,
                            p_data    => x_msg_data);

END Get_sales_assist_line_tokens;
END IBE_CART_NOTIFY_UTIL;


/
