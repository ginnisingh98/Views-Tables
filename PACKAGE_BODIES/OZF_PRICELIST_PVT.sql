--------------------------------------------------------
--  DDL for Package Body OZF_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_PRICELIST_PVT" AS
/* $Header: ozfvpltb.pls 120.5 2006/01/18 20:12:42 julou ship $ */

-- start of comment
-- History
--    19-MAY-2001  julou  modified
--                 1. added primary_uom_flag
--                 2. allow change when price list is actived
--                 3. when price list goes active, no call to move_segments
--                 4. commented out reference to object_attributes
--    17-AUG-2001  julou  modified
--                 added approval for status change
--    21-AUG-2001  julou  modified
--                 added calls to ams_access_pvt.create_access and
--                 ams_access_pvt.update_object_owner.
--    01-Nov-2001  rssharma modified
--                 passing list_price , along with operand
--    22-Oct-2002  RSSHARMA Added Function to get Currency Header Name
--    Added Currency_header_id for multi currency support
--    20-JAN-2003  julou fixed approval redirect issue.
--                 the g_miss_num is parsed in as owner_id and access table are
--                 updated with g_miss_num. solution: populate orig owner_id as
--                 owner_id(if it is g_miss_num) before check owner change.
--    FEB-05-2003  julou  bug 2784394 - moved WF after update price list
--   Fri Jan 09 2004:2/41 PM RSSHARMA Fixed bug # 3358056. Changed WOrkflow approval process from OZFGAPP to AMSGAPP
--   Tue Apr 13 2004:5/39 PM RSSHARMA Fixed bug # 3384634. Added Product Pricing Validation to make List header Id(Price List)
--   mandatory
--   Tue Jun 08 2004:3/30 PM RSSHARMA Fixed Category LOV issue. in get_Product_name function, if category belongs to
-- inventory categories then get concat_segments as before for backword compatibility, else if category belongs to unified
-- product catelog get the category description as the parentage is not correct.
-- end of comment

FUNCTION get_currency_header_name
  (   p_currency_header_id IN     NUMBER
  ) RETURN VARCHAR2
  IS
l_currency_name VARCHAR2(250);

CURSOR l_curr_currency_name(l_currency_header_id NUMBER) IS
SELECT name FROM qp_currency_lists_tl
WHERE currency_header_id = l_currency_header_id AND language = userenv('lang') ;

BEGIN

OPEN l_curr_currency_name(p_currency_header_id) ;
FETCH l_curr_currency_name INTO l_currency_name ;
CLOSE l_curr_currency_name ;
RETURN l_currency_name ;

EXCEPTION
WHEN OTHERS THEN
  RETURN '';
END;

PROCEDURE process_price_list_attributes( p_price_list_attr_rec IN  OZF_PRICE_LIST_PVT.OZF_PRICE_LIST_Rec_Type,
                                                        p_operation           IN  VARCHAR2,
                                                     x_return_status       OUT NOCOPY VARCHAR2)
 IS
  l_msg_data varchar2(2000);
  l_msg_count number;
  l_return_status varchar2(1) := FND_API.g_ret_sts_success;
  l_price_list_attribute_id   NUMBER;
  l_object_version_number     NUMBER;

  l_custom_setup_id   NUMBER;

   CURSOR c_custom_setup IS
   SELECT custom_setup_id
     FROM ams_custom_setups_vl
    WHERE object_type = 'PRIC';

BEGIN
  IF p_operation = QP_GLOBALS.G_OPR_CREATE THEN
    OZF_PRICE_LIST_PVT.create_price_list(p_api_version_number      => 1
                                        ,p_init_msg_list           => FND_API.G_FALSE
                                        ,p_commit                  => FND_API.G_FALSE
                                        ,x_return_status           => l_return_status
                                        ,x_msg_count               => l_msg_count
                                        ,x_msg_data                => l_msg_data
                                        ,p_ozf_PRICE_LIST_rec      => p_price_list_attr_rec
                                        ,x_price_list_attribute_id => l_price_list_attribute_id);

   OPEN c_custom_setup;
   FETCH c_custom_setup INTO l_custom_setup_id;
   CLOSE c_custom_setup;
   -- following code is removed by julou  19-MAY-2001.
/*
   -- create attributes for this offer
   IF l_custom_setup_id IS NOT NULL THEN
      AMS_ObjectAttribute_PVT.create_object_attributes(
         p_api_version       => 1.0,
         p_init_msg_list     => FND_API.g_false,
         p_commit            => FND_API.g_false,
         p_validation_level  => FND_API.g_valid_level_full,
         x_return_status     => l_return_status,
         x_msg_count         => l_msg_count,
         x_msg_data          => l_msg_data,
         p_object_type       => 'PRIC',
         p_object_id         => p_price_list_attr_rec.qp_list_header_id,
         p_setup_id          => l_custom_setup_id
      );
   END IF;
 */
 -- end of comment

 ELSIF  p_operation = QP_GLOBALS.G_OPR_UPDATE THEN
    OZF_PRICE_LIST_PVT.update_price_list(p_api_version_number    => 1
                                        ,p_init_msg_list         => FND_API.G_FALSE
                                        ,p_commit                => FND_API.G_FALSE
                                        ,x_return_status         => l_return_status
                                        ,x_msg_count             => l_msg_count
                                        ,x_msg_data              => l_msg_data
                                        ,p_ozf_PRICE_LIST_rec    => p_price_list_attr_rec
                                        ,x_object_version_number => l_object_version_number);


  ELSIF  p_operation = QP_GLOBALS.G_OPR_DELETE THEN

   OZF_PRICE_LIST_PVT.delete_price_list(  p_api_version_number     => 1
                                        ,p_init_msg_list           => FND_API.G_FALSE
                                        ,p_commit                  => FND_API.G_FALSE
                                        ,x_return_status           => l_return_status
                                        ,x_msg_count               => l_msg_count
                                        ,x_msg_data                => l_msg_data
                                        ,p_price_list_attribute_id => p_price_list_attr_rec.price_list_attribute_id
                                        ,p_object_version_number   => p_price_list_attr_rec.object_version_number );

  END IF;

   x_return_status := l_return_status;

 END;

PROCEDURE validate_price_list(
p_price_list_line_rec IN Price_List_Line_rec_Type
)
IS
BEGIN
    IF p_price_list_line_rec.list_header_id IS NULL OR  p_price_list_line_rec.list_header_id = FND_API.G_MISS_NUM THEN
      FND_MESSAGE.set_name('OZF', 'OZF_NO_PRIC_LIST');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
END validate_price_list;

PROCEDURE process_price_list(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_price_list_rec    IN  ozf_price_list_rec_type,
   p_price_list_line_tbl    IN  price_list_line_tbl_type,
   p_pricing_attr_tbl  IN  pricing_attr_tbl_type,
   p_qualifiers_tbl    IN  QUALIFIERS_TBL_TYPE,
   x_list_header_id    OUT NOCOPY NUMBER,
   x_error_source      OUT NOCOPY VARCHAR2,
   x_error_location    OUT NOCOPY NUMBER
)
IS
l_msg_data varchar2(2000);
l_msg_count number;
l_return_status varchar2(1) := FND_API.g_ret_sts_success;
l_api_name constant varchar2(30) := 'process_price_list';
i number := 1;
j number := 1;
l_list_header_id number;
l_api_version       CONSTANT NUMBER := 1.0;

l_price_list_rec                     QP_PRICE_LIST_PUB.Price_List_Rec_Type;
temp_price_list_rec                  QP_PRICE_LIST_PUB.Price_List_Rec_Type;
l_price_list_val_rec            QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
l_price_list_line_tbl           QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
l_price_list_line_val_tbl       QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
l_qualifiers_tbl                     QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_qualifiers_val_tbl            QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
l_pricing_attr_tbl                   QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
l_pricing_attr_val_tbl          QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
v_price_list_rec                     QP_PRICE_LIST_PUB.Price_List_Rec_Type;
v_price_list_val_rec            QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
v_price_list_line_tbl           QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
v_price_list_line_val_tbl       QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
v_qualifiers_tbl                     QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
v_qualifiers_val_tbl            QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
v_pricing_attr_tbl                   QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
v_pricing_attr_val_tbl          QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
l_ozf_price_list_attr_rec     OZF_PRICE_LIST_PVT.OZF_PRICE_LIST_Rec_Type;
l_access_rec                  ams_access_PVT.access_rec_type;
l_jtf_note_id NUMBER;
l_lines_delete VARCHAR2(1) := 'N';
l_access_id  NUMBER;

CURSOR cur_get_status_code(p_list_header_id NUMBER) IS
SELECT status_code
FROM   OZF_price_lists_v
WHERE  list_header_id = p_list_header_id;

CURSOR cur_get_system_status_code(p_user_status_id NUMBER) IS
SELECT system_status_code
  FROM ams_user_statuses_vl
 WHERE user_status_id = p_user_status_id;

CURSOR cur_get_user_status_id(l_status_code VARCHAR2) IS
SELECT user_status_id
 FROM  ams_user_statuses_vl
 WHERE system_status_type = 'OZF_PRICELIST_STATUS'
   AND system_status_code = l_status_code
   AND TRUNC(sysdate) BETWEEN NVL(start_date_active, TRUNC(SYSDATE)) and NVL(end_date_active, TRUNC(sysdate))
   AND default_flag = 'Y'
   AND enabled_flag = 'Y';

CURSOR c_get_old_status_id(l_id VARCHAR2) IS
SELECT user_status_id,custom_setup_id,owner_id
  FROM OZF_price_list_attributes
 WHERE qp_list_header_id = l_id;

 l_resource_id NUMBER := OZF_UTILITY_PVT.get_resource_id(FND_GLOBAL.user_id);

 l_new_status_code VARCHAR2(30);
 l_existing_status_code VARCHAR2(30);
 l_old_status_id NUMBER;
 l_approval_type VARCHAR2(30) := NULL;
 l_user_status_id NUMBER;
 l_custom_setup_id NUMBER;
 l_old_owner_id    NUMBER;
 l_owner_id        NUMBER;
 l_is_owner        VARCHAR2(1);
 l_login_is_owner  VARCHAR2(1);
 l_is_admin      BOOLEAN;
BEGIN

   SAVEPOINT process_price_list;

   IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
        RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status  := FND_API.G_RET_STS_SUCCESS;


-- Commented to allow product association to Price Lists Created in QP
/* IF p_price_list_rec.operation <> QP_GLOBALS.G_OPR_CREATE THEN
   IF AMS_ACCESS_PVT.check_update_access(p_price_list_rec.list_header_id, 'PRIC',l_resource_id,'USER') NOT IN ('F','R') THEN
      FND_MESSAGE.SET_NAME('OZF','OZF_EVO_NO_UPDATE_ACCESS');
      FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
      FND_MSG_PUB.ADD;
      x_error_source := 'H';
      RAISE FND_API.g_exc_error;
    END IF;
  END IF; */

   OPEN cur_get_status_code(p_price_list_rec.list_header_id);
   FETCH cur_get_status_code INTO  l_existing_status_code;
   CLOSE cur_get_status_code;

   IF l_existing_status_code IN ('CANCELLED') THEN
     FND_MESSAGE.SET_NAME('OZF','OZF_PRIC_NO_CHANGES_ALLOWED');
     FND_MSG_PUB.ADD;
     x_error_source := 'H';
     RAISE FND_API.g_exc_error;
   END IF;



IF p_price_list_rec.operation  <> FND_API.G_MISS_CHAR THEN

   l_price_list_rec.name                     := p_price_list_rec.name;
   l_price_list_rec.description       := p_price_list_rec.description;
   l_price_list_rec.currency_code     := p_price_list_rec.currency_code;
   l_price_list_rec.operation         := p_price_list_rec.operation;
   l_price_list_rec.start_date_active := p_price_list_rec.start_date_active;
   l_price_list_rec.end_date_active   := p_price_list_rec.end_date_active;
   l_price_list_rec.currency_header_id := p_price_list_rec.currency_header_id;

   IF NVL(fnd_profile.value('QP_SECURITY_CONTROL'), 'OFF') = 'ON' THEN
     l_price_list_rec.global_flag := p_price_list_rec.global_flag;
   ELSE
     l_price_list_rec.global_flag := 'Y';
   END IF;

   IF l_price_list_rec.global_flag = 'Y' THEN
     IF p_price_list_rec.org_id IS NOT NULL AND p_price_list_rec.org_id <> fnd_api.g_miss_num THEN
       FND_MESSAGE.set_name('OZF', 'OZF_CLEAR_OU');
       FND_MSG_PUB.add;
       RAISE FND_API.g_exc_error;
     ELSE
       l_price_list_rec.org_id := NULL; -- global offer does need org id
     END IF;
   ELSE -- local offer
     l_price_list_rec.org_id := p_price_list_rec.org_id;
   END IF;

   -- julou bug 3863693: expose flex field
   l_price_list_rec.context     := p_price_list_rec.context;
   l_price_list_rec.attribute1  := p_price_list_rec.attribute1;
   l_price_list_rec.attribute2  := p_price_list_rec.attribute2;
   l_price_list_rec.attribute3  := p_price_list_rec.attribute3;
   l_price_list_rec.attribute4  := p_price_list_rec.attribute4;
   l_price_list_rec.attribute5  := p_price_list_rec.attribute5;
   l_price_list_rec.attribute6  := p_price_list_rec.attribute6;
   l_price_list_rec.attribute7  := p_price_list_rec.attribute7;
   l_price_list_rec.attribute8  := p_price_list_rec.attribute8;
   l_price_list_rec.attribute9  := p_price_list_rec.attribute9;
   l_price_list_rec.attribute10 := p_price_list_rec.attribute10;
   l_price_list_rec.attribute11 := p_price_list_rec.attribute11;
   l_price_list_rec.attribute12 := p_price_list_rec.attribute12;
   l_price_list_rec.attribute13 := p_price_list_rec.attribute13;
   l_price_list_rec.attribute14 := p_price_list_rec.attribute14;
   l_price_list_rec.attribute15 := p_price_list_rec.attribute15;
   -- julou end

  -- added by julou 07-16-2002 bug 2452540
  -- validate dates here instead of validating in QP.
  -- QP checks twice and hence returns 2 error messages
  IF l_price_list_rec.start_date_active IS NOT NULL
  AND l_price_list_rec.start_date_active <> FND_API.G_MISS_DATE
  AND l_price_list_rec.end_date_active IS NOT NULL
  AND l_price_list_rec.end_date_active <> FND_API.G_MISS_DATE
  THEN
    IF l_price_list_rec.start_date_active > l_price_list_rec.end_date_active THEN
      FND_MESSAGE.set_name('OZF', 'OZF_PRIC_START_AFTER_END');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
  END IF;
  -- ended 2452540

  IF p_price_list_rec.list_header_id IS NOT NULL AND p_price_list_rec.list_header_id <> fnd_api.g_miss_num THEN
   OPEN c_get_old_status_id(p_price_list_rec.list_header_id);
   FETCH c_get_old_status_id INTO l_old_status_id,l_custom_setup_id,l_old_owner_id;
   CLOSE c_get_old_status_id;

   -- check if approval is required
    IF p_price_list_rec.user_status_id IS NOT NULL AND p_price_list_rec.user_status_id <> FND_API.G_MISS_NUM THEN
   -- bug 3780070 exception when updating price list created from QP (QP price lists have no status code in OZF)
      OZF_Utility_PVT.check_new_status_change(p_object_type     => 'PRIC'
                                             ,p_object_id       => p_price_list_rec.list_header_id
                                             ,p_old_status_id   => l_old_status_id
                                             ,p_new_status_id   => p_price_list_rec.user_status_id
                                             ,p_custom_setup_id => l_custom_setup_id
                                             ,x_approval_type   => l_approval_type
                                             ,x_return_status   => l_return_status);

      OPEN cur_get_system_status_code(p_price_list_rec.user_status_id);
      FETCH cur_get_system_status_code INTO l_new_status_code;
      CLOSE cur_get_system_status_code;

      IF l_new_status_code = 'ACTIVE' THEN
        IF l_approval_type IS NULL THEN -- no approval needed
          l_price_list_rec.active_flag := 'Y';
        END IF;
      END IF;
    END IF; -- end bug 3780070 exception when updating price list created from QP
  END IF;

   /****************Uncomment once upgraded to R3 LEVEL **********************/

 IF p_price_list_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN
      l_price_list_rec.list_type_code  := 'PRL';
      l_price_list_rec.active_flag     := 'N';
      l_price_list_rec.list_header_id  := FND_API.G_MISS_NUM;
   ELSE
      l_price_list_rec.list_header_id  := p_price_list_rec.list_header_id;
   END IF;
 END IF;

IF p_price_list_line_tbl.count > 0 THEN
   FOR i in p_price_list_line_tbl.first..p_price_list_line_tbl.last LOOP

    IF p_price_list_line_tbl.exists(i) AND p_price_list_line_tbl(i).operation <> FND_API.G_MISS_CHAR THEN
      -- bug 2452540
      IF p_price_list_line_tbl(i).start_date_active IS NOT NULL
      AND p_price_list_line_tbl(i).start_date_active <> FND_API.G_MISS_DATE
      AND p_price_list_line_tbl(i).end_date_active IS NOT NULL
      AND p_price_list_line_tbl(i).end_date_active <> FND_API.G_MISS_DATE
      THEN
        IF p_price_list_line_tbl(i).start_date_active > p_price_list_line_tbl(i).end_date_active THEN
          FND_MESSAGE.set_name('OZF', 'OZF_PRIC_START_AFTER_END');
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
        END IF;
      END IF;
      -- end bug 2452540
      validate_price_list(p_price_list_line_rec =>p_price_list_line_tbl(i));

       l_price_list_line_tbl(i).list_line_id :=  p_price_list_line_tbl(i).list_line_id;
       l_price_list_line_tbl(i).list_header_id :=  p_price_list_line_tbl(i).list_header_id;

       -- julou bug 3863693 expose flex field
       l_price_list_line_tbl(i).context     := p_price_list_line_tbl(i).context;
       l_price_list_line_tbl(i).attribute1  := p_price_list_line_tbl(i).attribute1;
       l_price_list_line_tbl(i).attribute2  := p_price_list_line_tbl(i).attribute2;
       l_price_list_line_tbl(i).attribute3  := p_price_list_line_tbl(i).attribute3;
       l_price_list_line_tbl(i).attribute4  := p_price_list_line_tbl(i).attribute4;
       l_price_list_line_tbl(i).attribute5  := p_price_list_line_tbl(i).attribute5;
       l_price_list_line_tbl(i).attribute6  := p_price_list_line_tbl(i).attribute6;
       l_price_list_line_tbl(i).attribute7  := p_price_list_line_tbl(i).attribute7;
       l_price_list_line_tbl(i).attribute8  := p_price_list_line_tbl(i).attribute8;
       l_price_list_line_tbl(i).attribute9  := p_price_list_line_tbl(i).attribute9;
       l_price_list_line_tbl(i).attribute10 := p_price_list_line_tbl(i).attribute10;
       l_price_list_line_tbl(i).attribute11 := p_price_list_line_tbl(i).attribute11;
       l_price_list_line_tbl(i).attribute12 := p_price_list_line_tbl(i).attribute12;
       l_price_list_line_tbl(i).attribute13 := p_price_list_line_tbl(i).attribute13;
       l_price_list_line_tbl(i).attribute14 := p_price_list_line_tbl(i).attribute14;
       l_price_list_line_tbl(i).attribute15 := p_price_list_line_tbl(i).attribute15;
       -- julou end

      IF p_price_list_line_tbl(i).operation = QP_GLOBALS.G_OPR_CREATE THEN
        l_price_list_line_tbl(i).list_line_type_code := 'PLL';
        l_price_list_line_tbl(i).operation := p_price_list_line_tbl(i).operation ;
        l_price_list_line_tbl(i).arithmetic_operator := 'UNIT_PRICE';
        l_price_list_line_tbl(i).print_on_invoice_flag := 'N';
        l_price_list_line_tbl(i).override_flag := 'N';
        l_price_list_line_tbl(i).automatic_flag := 'Y';
        l_price_list_line_tbl(i).modifier_level_code := 'LINE';


        l_price_list_line_tbl(i).start_date_active  := p_price_list_line_tbl(i).start_date_active;
        l_price_list_line_tbl(i).end_date_active    := p_price_list_line_tbl(i).end_date_active;
        l_price_list_line_tbl(i).operand := p_price_list_line_tbl(i).operand;
        l_price_list_line_tbl(i).list_price := p_price_list_line_tbl(i).list_price;
        l_price_list_line_tbl(i).product_precedence := p_price_list_line_tbl(i).product_precedence;
        l_price_list_line_tbl(i).primary_uom_flag := p_price_list_line_tbl(i).primary_uom_flag;
        l_price_list_line_tbl(i).generate_using_formula_id := p_price_list_line_tbl(i).static_formula_id;
        l_price_list_line_tbl(i).price_by_formula_id := p_price_list_line_tbl(i).dynamic_formula_id;
      ELSIF  p_price_list_line_tbl(i).operation = QP_GLOBALS.G_OPR_UPDATE THEN
        l_price_list_line_tbl(i).operation := p_price_list_line_tbl(i).operation ;
        l_price_list_line_tbl(i).start_date_active  := p_price_list_line_tbl(i).start_date_active;
        l_price_list_line_tbl(i).end_date_active    := p_price_list_line_tbl(i).end_date_active;
        l_price_list_line_tbl(i).operand := p_price_list_line_tbl(i).operand;
        l_price_list_line_tbl(i).list_price := p_price_list_line_tbl(i).list_price;
        l_price_list_line_tbl(i).product_precedence := p_price_list_line_tbl(i).product_precedence;
        l_price_list_line_tbl(i).primary_uom_flag := p_price_list_line_tbl(i).primary_uom_flag;
        l_price_list_line_tbl(i).generate_using_formula_id := p_price_list_line_tbl(i).static_formula_id;
        l_price_list_line_tbl(i).price_by_formula_id := p_price_list_line_tbl(i).dynamic_formula_id;
        l_price_list_line_tbl(i).comments := p_price_list_line_tbl(i).comments;
      ELSE
       l_lines_delete := 'Y';
     END IF;
    END IF;

   END LOOP;
 END IF;

  IF p_pricing_attr_tbl.count > 0 THEN
   FOR i in p_pricing_attr_tbl.first..p_pricing_attr_tbl.last LOOP

    IF p_pricing_attr_tbl.exists(i) AND p_pricing_attr_tbl(i).operation <> FND_API.G_MISS_CHAR THEN

          l_pricing_attr_tbl(i).pricing_attribute_id := p_pricing_attr_tbl(i).pricing_attribute_id;
       l_pricing_attr_tbl(i).list_line_id := p_pricing_attr_tbl(i).list_line_id;
       l_pricing_attr_tbl(i).operation       := p_pricing_attr_tbl(i).operation ;
       l_pricing_attr_tbl(i).PRODUCT_ATTR_VALUE := p_pricing_attr_tbl(i).PRODUCT_ATTR_VALUE;
       l_pricing_attr_tbl(i).PRODUCT_UOM_CODE   := p_pricing_attr_tbl(i).PRODUCT_UOM_CODE;

         IF p_pricing_attr_tbl(i).operation = QP_GLOBALS.G_OPR_CREATE THEN

           l_pricing_attr_tbl(i).PRODUCT_ATTRIBUTE_CONTEXT := 'ITEM';
        l_pricing_attr_tbl(i).PRODUCT_ATTRIBUTE := p_pricing_attr_tbl(i).PRODUCT_ATTRIBUTE;
        l_pricing_attr_tbl(i).EXCLUDER_FLAG := 'N';
        l_pricing_attr_tbl(i).ATTRIBUTE_GROUPING_NO := 1;
        l_pricing_attr_tbl(i).PRICE_LIST_LINE_INDEX := i;

END IF;

     END IF;

   END LOOP;
  END IF;

      QP_PRICE_LIST_PUB.Process_Price_List
        (   p_api_version_number            => 1
        ,   p_init_msg_list                 => FND_API.G_TRUE
        ,   p_return_values                 => FND_API.G_FALSE
        ,   p_commit                        => FND_API.G_FALSE
        ,   x_return_status                 => l_return_status
        ,   x_msg_count                     => l_msg_count
        ,   x_msg_data                      => l_msg_data
        ,   p_PRICE_LIST_rec                => l_price_list_rec
        ,   p_PRICE_LIST_LINE_tbl           => l_price_list_line_tbl
        ,   p_PRICING_ATTR_tbl              => l_pricing_attr_tbl
        ,   x_PRICE_LIST_rec                => v_price_list_rec
        ,   x_PRICE_LIST_val_rec            => v_price_list_val_rec
        ,   x_PRICE_LIST_LINE_TBL           => v_price_list_line_tbl
        ,   x_PRICE_LIST_LINE_val_tbl       => v_price_list_line_val_tbl
        ,   x_QUALIFIERS_tbl                => v_qualifiers_tbl
        ,   x_QUALIFIERS_val_tbl            => v_qualifiers_val_tbl
        ,   x_PRICING_ATTR_tbl              => v_pricing_attr_tbl
        ,   x_PRICING_ATTR_val_tbl          => v_pricing_attr_val_tbl
       );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        IF v_price_list_rec.return_status <> fnd_api.g_ret_sts_success THEN
          x_error_source := 'H';
        ELSE
          IF v_price_list_line_tbl.count > 0 THEN
            FOR i in v_price_list_line_tbl.first..v_price_list_line_tbl.last LOOP
              IF v_price_list_line_tbl.exists(i) THEN
                IF v_price_list_line_tbl(i).return_status <> fnd_api.g_ret_sts_success THEN
                  x_error_source := 'L';
                  x_error_location := i;
                  exit;
                END IF;
              END IF;
            END LOOP;
          END IF;
        END IF;

        IF x_error_source not in ('H','L') THEN

          IF v_pricing_attr_tbl.count > 0 THEN
            FOR i in v_pricing_attr_tbl.first..v_pricing_attr_tbl.last LOOP
              IF v_pricing_attr_tbl.exists(i) THEN
                IF v_pricing_attr_tbl(i).return_status <> fnd_api.g_ret_sts_success THEN
                  x_error_source := 'L';
                  x_error_location := i;
                  exit;
                END IF;
              END IF;
            END LOOP;
          END IF;
        END IF;

      ELSE

        IF l_lines_delete = 'Y' THEN
          l_price_list_rec := temp_price_list_rec;
          l_price_list_line_tbl.delete;
          l_pricing_attr_tbl.delete;
          j := 1;
          FOR i in p_price_list_line_tbl.first..p_price_list_line_tbl.last LOOP

            IF p_price_list_line_tbl.exists(i) AND p_price_list_line_tbl(i).operation = QP_GLOBALS.G_OPR_DELETE THEN

              l_price_list_line_tbl(j).list_line_id :=  p_price_list_line_tbl(i).list_line_id;
              l_price_list_line_tbl(j).list_header_id :=  p_price_list_line_tbl(i).list_header_id;
              l_price_list_line_tbl(j).operation := p_price_list_line_tbl(i).operation ;
              j := j+1;
            END IF;

          END LOOP;

          QP_PRICE_LIST_PUB.Process_Price_List
            (   p_api_version_number            => 1
            ,   p_init_msg_list                 => FND_API.G_TRUE
            ,   p_return_values                 => FND_API.G_FALSE
            ,   p_commit                        => FND_API.G_FALSE
            ,   x_return_status                 => l_return_status
            ,   x_msg_count                     => l_msg_count
            ,   x_msg_data                      => l_msg_data
            ,   p_PRICE_LIST_rec                => l_price_list_rec
            ,   p_PRICE_LIST_LINE_tbl           => l_price_list_line_tbl
            ,   p_PRICING_ATTR_tbl              => l_pricing_attr_tbl
            ,   x_PRICE_LIST_rec                => v_price_list_rec
            ,   x_PRICE_LIST_val_rec            => v_price_list_val_rec
            ,   x_PRICE_LIST_LINE_TBL           => v_price_list_line_tbl
            ,   x_PRICE_LIST_LINE_val_tbl       => v_price_list_line_val_tbl
            ,   x_QUALIFIERS_tbl                => v_qualifiers_tbl
            ,   x_QUALIFIERS_val_tbl            => v_qualifiers_val_tbl
            ,   x_PRICING_ATTR_tbl              => v_pricing_attr_tbl
            ,   x_PRICING_ATTR_val_tbl          => v_pricing_attr_val_tbl
            );

          IF l_return_status <> fnd_api.g_ret_sts_success THEN

            IF v_price_list_line_tbl.count > 0 THEN
              FOR i in v_price_list_line_tbl.first..v_price_list_line_tbl.last LOOP
                IF v_price_list_line_tbl.exists(i) THEN
                  IF v_price_list_line_tbl(i).return_status <> fnd_api.g_ret_sts_success THEN
                    x_error_source := 'L';
                    x_error_location := i;
                    exit;
                  END IF;
                END IF;
              END LOOP;
            END IF;
          END IF;

        END IF;

      END IF;

      IF l_return_status =  fnd_api.g_ret_sts_error THEN
        FOR i in 1 .. l_msg_count LOOP
          l_msg_data :=  oe_msg_pub.get( p_msg_index => i,
                                       p_encoded => 'F' );
          FND_MESSAGE.SET_NAME('OZF','OZF_QP_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
          FND_MSG_PUB.ADD;
        END LOOP;
        RAISE FND_API.g_exc_error;

      ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        FOR i in 1 .. l_msg_count LOOP
          l_msg_data :=  oe_msg_pub.get( p_msg_index => i,
                                       p_encoded => 'F' );

          FND_MESSAGE.SET_NAME('OZF','OZF_QP_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
          FND_MSG_PUB.ADD;
        END LOOP;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

     IF  p_price_list_rec.operation <>  FND_API.G_MISS_CHAR THEN
          x_list_header_id  := v_price_list_rec.list_header_id;
       l_ozf_price_list_attr_rec.status_code :=   l_new_status_code;
       l_ozf_price_list_attr_rec.user_status_id :=   p_price_list_rec.user_status_id;
       l_ozf_price_list_attr_rec.owner_id :=   p_price_list_rec.owner_id;
       l_ozf_price_list_attr_rec.custom_setup_id := p_price_list_rec.custom_setup_id  ;

    IF  p_price_list_rec.operation = QP_GLOBALS.G_OPR_CREATE THEN
            FND_MESSAGE.SET_NAME('OZF','CREATE');
       l_ozf_price_list_attr_rec.object_version_number := 1;
       l_ozf_price_list_attr_rec.qp_list_header_id := v_price_list_rec.list_header_id  ;
       l_ozf_price_list_attr_rec.custom_setup_id := p_price_list_rec.custom_setup_id  ;
          l_ozf_price_list_attr_rec.status_code := 'DRAFT';
          OPEN cur_get_user_status_id('DRAFT');
          FETCH cur_get_user_status_id into l_ozf_price_list_attr_rec.user_status_id;
       CLOSE cur_get_user_status_id;
       l_ozf_price_list_attr_rec.status_date :=   sysdate;

-- added by julou 08/21/2001  calling create_access to create an entry in ams_act_access
       l_access_rec.ACT_ACCESS_TO_OBJECT_ID := x_list_header_id;
       l_access_rec.ARC_ACT_ACCESS_TO_OBJECT := 'PRIC';
       l_access_rec.USER_OR_ROLE_ID := p_price_list_rec.owner_id;
       l_access_rec.ARC_USER_OR_ROLE_TYPE := 'USER';
       l_access_rec.ACTIVE_FROM_DATE := p_price_list_rec.start_date_active;
       l_access_rec.ADMIN_FLAG := 'Y';
       l_access_rec.ACTIVE_TO_DATE := p_price_list_rec.end_date_active;
       l_access_rec.OWNER_FLAG := 'Y';

       ams_access_PVT.create_access(
   p_api_version       => l_api_version,
   p_init_msg_list     => FND_API.g_false,
   p_commit            => FND_API.g_false,
   p_validation_level  => FND_API.g_valid_level_full,

   x_return_status     => l_return_status,
   x_msg_count         => l_msg_count,
   x_msg_data          => l_msg_data,

   p_access_rec        => l_access_rec,
   x_access_id         => l_access_id
);
     IF l_return_status =  fnd_api.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;

          process_price_list_attributes(p_price_list_attr_rec => l_ozf_price_list_attr_rec
                                                    ,p_operation           => p_price_list_rec.operation
                                       ,x_return_status       => l_return_status
                                    );

     IF l_return_status =  fnd_api.g_ret_sts_error THEN
          x_error_source := 'H';
       RAISE FND_API.g_exc_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
          x_error_source := 'H';
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
-- end of comments

     ELSE -- operation = 'update'
      -- get old user_status id
       IF p_price_list_rec.operation = 'UPDATE'
       AND ( p_price_list_rec.list_header_id IS NULL
       or p_price_list_rec.list_header_id = FND_API.g_miss_num) THEN
         NULL;
       ELSE
         IF p_price_list_rec.owner_id = fnd_api.g_miss_num THEN
           l_owner_id := l_old_owner_id;
         ELSE
           l_owner_id := p_price_list_rec.owner_id;
         END IF;
         -- check if approval is required
         IF p_price_list_rec.user_status_id IS NOT NULL AND p_price_list_rec.user_status_id <> FND_API.G_MISS_NUM THEN
         -- bug 3780070 exception when updating price list created from QP i.e. no status for QP price lists
           IF l_approval_type IS NOT NULL THEN -- approval is required
             l_ozf_price_list_attr_rec.user_status_id := ozf_utility_pvt.get_default_user_status('OZF_PRICELIST_STATUS','PENDING');
             l_ozf_price_list_attr_rec.status_code := 'PENDING';
           END IF;
         END IF; -- end bug 3780070 exception when updating price list created from QP


         l_ozf_price_list_attr_rec.price_list_attribute_id :=   p_price_list_rec.price_list_attribute_id;
         l_ozf_price_list_attr_rec.object_version_number :=   p_price_list_rec.object_version_number;
         l_ozf_price_list_attr_rec.qp_list_header_id := p_price_list_rec.list_header_id;
         -- added by julou 08/21/2001  check if the owner is changed. if so, update the owner inof in ams_act_access
         l_is_owner := ams_access_PVT.check_owner(p_object_id => p_price_list_rec.list_header_id
                                              ,p_object_type       => 'PRIC'
                                              ,p_user_or_role_id   => l_owner_id
                                              ,p_user_or_role_type => 'USER');
         IF l_owner_id IS NOT NULL AND l_owner_id <> FND_API.G_MISS_NUM AND l_is_owner = 'N' THEN -- owner is changed
         -- bug 3780070 exception when updating price list created from QP i.e. no owner id for QP price lists
           l_is_admin := ams_Access_PVT.Check_Admin_Access(l_resource_id); -- check if login user is super user
           l_login_is_owner := ams_access_PVT.check_owner(p_object_id => p_price_list_rec.list_header_id
                                              ,p_object_type        => 'PRIC'
                                              ,p_user_or_role_id    => l_resource_id
                                              ,p_user_or_role_type  => 'USER');
           IF l_is_admin OR l_login_is_owner = 'Y' THEN -- only super user/owner of price list can change the owner
             ams_access_PVT.update_object_owner(
             p_api_version       => l_api_version,
             p_init_msg_list     => FND_API.g_false,
             p_commit            => FND_API.g_false,
             p_validation_level  => FND_API.g_valid_level_full,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data,
             p_object_type       => 'PRIC',
             p_object_id         => p_price_list_rec.list_header_id,
             p_resource_id       => p_price_list_rec.owner_id,
             p_old_resource_id   => l_old_owner_id);

             IF l_return_status =  fnd_api.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
             ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
             END IF;
           ELSE
             OZF_Utility_PVT.error_message('OZF_PRIC_UPDT_OWNER_PERM');
             x_return_status := FND_API.g_ret_sts_error;
           END IF;



         END IF;
         -- end of comments
         process_price_list_attributes(p_price_list_attr_rec => l_ozf_price_list_attr_rec
                                       ,p_operation           => p_price_list_rec.operation
                                       ,x_return_status       => l_return_status
                                    );
         IF l_return_status =  fnd_api.g_ret_sts_error THEN
           x_error_source := 'H';
           RAISE FND_API.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
           x_error_source := 'H';
           RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF l_approval_type IS NOT NULL THEN -- approval is required
           ams_gen_approval_pvt.StartProcess(p_activity_type     => 'PRIC'
                                     ,p_activity_id           => p_price_list_rec.list_header_id
                                     ,p_approval_type         => 'PRICELIST'
                                     ,p_object_version_number => p_price_list_rec.object_version_number
                                     ,p_orig_stat_id          => l_old_status_id
                                     ,p_new_stat_id           => p_price_list_rec.user_status_id
                                     ,p_reject_stat_id        => ozf_utility_pvt.get_default_user_status('OZF_PRICELIST_STATUS','REJECTED')
                                     ,p_requester_userid      => OZF_Utility_PVT.get_resource_id(FND_GLOBAL.user_id)
                                     ,p_workflowprocess       => 'AMSGAPP'
                                     ,p_item_type             => 'AMSGAPP');
         END IF;

       END IF;
     END IF; -- end operation
   END IF;
/*-- added by julou  08/16/2001 create or update note info in jtf notes tables.
IF p_price_list_line_tbl.count > 0 THEN
  FOR i in p_price_list_line_tbl.first .. p_price_list_line_tbl.last LOOP
    IF p_price_list_line_tbl(i).operation = QP_GLOBALS.G_OPR_UPDATE
    OR p_price_list_line_tbl(i).operation = QP_GLOBALS.G_OPR_CREATE THEN
     IF p_price_list_line_tbl(i).jtf_note_id IS NULL THEN
      IF p_price_list_line_tbl(i).note IS NOT NULL THEN
        JTF_NOTES_PUB.Create_note(
        p_parent_note_id     => FND_API.g_miss_num,
        p_jtf_note_id        => NULL,
        p_api_version        => l_api_version,
        p_init_msg_list      => FND_API.g_false,
        p_commit             => FND_API.g_false,
        p_validation_level   => FND_API.g_valid_level_full,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data,
        p_org_id             => NULL,
        p_source_object_id   => v_price_list_line_tbl(i).list_line_id,
        p_source_object_code => 'OZF_PRIC_LINE',
        p_notes              => p_price_list_line_tbl(i).note,
        p_notes_detail       => NULL,
        p_note_status        => 'I',
        p_entered_by         => FND_GLOBAL.user_id,
        p_entered_date       => SYSDATE,
        x_jtf_note_id        => l_jtf_note_id,
        p_last_update_date   => SYSDATE,
        p_last_updated_by    => FND_GLOBAL.user_id,
        p_creation_date      => SYSDATE,
        p_created_by         => FND_GLOBAL.user_id,
        p_last_update_login  => FND_GLOBAL.login_id,
        p_attribute1         => NULL,
        p_attribute2         => NULL,
        p_attribute3         => NULL,
        p_attribute4         => NULL,
        p_attribute5         => NULL,
        p_attribute6         => NULL,
        p_attribute7         => NULL,
        p_attribute8         => NULL,
        p_attribute9         => NULL,
        p_attribute10        => NULL,
        p_attribute11        => NULL,
        p_attribute12        => NULL,
        p_attribute13        => NULL,
        p_attribute14        => NULL,
        p_attribute15        => NULL,
        p_context            => NULL,
        p_note_type          => 'OZF_PRICELISTREPORT',
        p_jtf_note_contexts_tab => JTF_NOTES_PUB.jtf_note_contexts_tab_dflt);
      END IF;

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          FND_MESSAGE.SET_NAME('OZF', 'OZF_NOTE_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.g_exc_unexpected_error;
        ELSE
          FND_MESSAGE.Set_Name('OZF', 'OZF_NOTE_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.g_exc_error;
        END IF;
      END IF;
     ELSE
      JTF_NOTES_PUB.Update_note(
        p_api_version       => l_api_version,
        p_init_msg_list     => FND_API.g_false,
        p_commit            => FND_API.g_false,
        p_validation_level  => FND_API.g_valid_level_full,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
        p_jtf_note_id       => p_price_list_line_tbl(i).jtf_note_id,
        p_entered_by        => FND_GLOBAL.user_id,
        p_last_updated_by   => FND_GLOBAL.user_id,
        p_last_update_date  => SYSDATE,
        p_last_update_login => FND_GLOBAL.login_id,
        p_notes             => p_price_list_line_tbl(i).note,
        p_notes_detail      => NULL,
        p_append_flag       => FND_API.g_miss_char,
        p_note_status       => 'I',
        p_note_type         => 'OZF_PRICELISTREPORT',
        p_jtf_note_contexts_tab => JTF_NOTES_PUB.jtf_note_contexts_tab_dflt);

      IF l_return_status <> FND_API.g_ret_sts_success THEN
        IF l_return_status = FND_API.g_ret_sts_unexp_error THEN
          FND_MESSAGE.SET_NAME('OZF', 'OZF_NOTE_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.g_exc_unexpected_error;
        ELSE
          FND_MESSAGE.Set_Name('OZF', 'OZF_NOTE_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
          FND_MSG_PUB.Add;
          RAISE FND_API.g_exc_error;
        END IF;
      END IF;
     END IF;
    END IF;
  END LOOP;
END IF;
*/
-- end of code added by julou

    IF p_commit = FND_API.g_true then
      COMMIT WORK;
    END IF;

       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
    ROLLBACK TO process_price_list;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        ROLLBACK TO process_price_list;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_erroR ;
        x_error_source := 'H';
        ROLLBACK TO process_price_list;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;

PROCEDURE move_segments (
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_price_list_id     IN  NUMBER
  )IS
l_msg_data varchar2(2000);
l_msg_count number;
l_return_status varchar2(1) := FND_API.g_ret_sts_success;
l_api_name constant varchar2(30) := 'move_segments';
i number := 1;
l_list_header_id number;
l_api_version       CONSTANT NUMBER := 1.0;

CURSOR cur_get_market_segments  IS
SELECT aam.market_segment_name
FROM   ams_act_mkt_segments_vl aam
WHERE  aam.act_market_segment_used_by_id = p_price_list_id
AND    aam.arc_act_market_segment_used_by ='PRIC'
AND    aam.segment_type  = 'MARKET_SEGMENT';

CURSOR cur_get_target_segments  IS
SELECT aam.market_segment_name
FROM   ams_act_mkt_segments_vl aam
WHERE  aam.act_market_segment_used_by_id = p_price_list_id
AND    aam.arc_act_market_segment_used_by = 'PRIC'
AND    aam.segment_type  = 'CELL';


l_price_list_rec                     QP_PRICE_LIST_PUB.Price_List_Rec_Type;
l_price_list_val_rec            QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
l_price_list_line_tbl           QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
l_price_list_line_val_tbl       QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
l_qualifiers_tbl                     QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_qualifiers_val_tbl            QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
l_pricing_attr_tbl                   QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
l_pricing_attr_val_tbl          QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;
v_price_list_rec                     QP_PRICE_LIST_PUB.Price_List_Rec_Type;
v_price_list_val_rec            QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
v_price_list_line_tbl           QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
v_price_list_line_val_tbl       QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
v_qualifiers_tbl                     QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
v_qualifiers_val_tbl            QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
v_pricing_attr_tbl                   QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
v_pricing_attr_val_tbl          QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

BEGIN
  SAVEPOINT move_segments;

  IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call
   (
      l_api_version,
      p_api_version,
      l_api_name,
      g_pkg_name
   )
   THEN
        RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status  := FND_API.G_RET_STS_SUCCESS;

--Create market segments
FOR market_segment_rec in cur_get_market_segments
LOOP
 l_qualifiers_tbl(i).qualifier_attr_value      := market_segment_rec.market_segment_name;
 l_qualifiers_tbl(i).list_header_id            := p_price_list_id;
 l_qualifiers_tbl(i).qualifier_context         :=  'SEGMENT';
 l_qualifiers_tbl(i).qualifier_attribute       :=  'QUALIFIER_ATTRIBUTE1';
 l_qualifiers_tbl(i).comparison_operator_code  :=  '=';
 l_qualifiers_tbl(i).operation                  := QP_GLOBALS.G_OPR_CREATE;
 i := i+1;
END LOOP;

--Create Target segments
FOR target_segment_rec in cur_get_target_segments
LOOP
 l_qualifiers_tbl(i).qualifier_attr_value      := target_segment_rec.market_segment_name;
 l_qualifiers_tbl(i).list_header_id            := p_price_list_id;
 l_qualifiers_tbl(i).qualifier_context         :=  'SEGMENT';
 l_qualifiers_tbl(i).qualifier_attribute       :=  'QUALIFER_ATTRIBUTE2';
 l_qualifiers_tbl(i).comparison_operator_code  :=  '=';
 l_qualifiers_tbl(i).operation                  := QP_GLOBALS.G_OPR_CREATE;
 i := i+1;
END LOOP;

IF l_qualifiers_tbl.count > 0 THEN

    QP_PRICE_LIST_PUB.Process_Price_List
        (   p_api_version_number            => 1
        ,   p_init_msg_list                 => FND_API.G_TRUE
        ,   p_return_values                 => FND_API.G_FALSE
        ,   p_commit                        => FND_API.G_FALSE
        ,   x_return_status                 => l_return_status
        ,   x_msg_count                     => l_msg_count
        ,   x_msg_data                      => l_msg_data
        ,   p_PRICE_LIST_rec                => l_price_list_rec
        ,   p_PRICE_LIST_LINE_tbl           => l_price_list_line_tbl
        ,   p_PRICING_ATTR_tbl              => l_pricing_attr_tbl
        ,   p_QUALIFIERS_tbl                => l_qualifiers_tbl
        ,   x_PRICE_LIST_rec                => v_price_list_rec
        ,   x_PRICE_LIST_val_rec            => v_price_list_val_rec
        ,   x_PRICE_LIST_LINE_TBL          => v_price_list_line_tbl
        ,   x_PRICE_LIST_LINE_val_tbl       => v_price_list_line_val_tbl
        ,   x_QUALIFIERS_tbl                => v_qualifiers_tbl
        ,   x_QUALIFIERS_val_tbl            => v_qualifiers_val_tbl
        ,   x_PRICING_ATTR_tbl              => v_pricing_attr_tbl
        ,   x_PRICING_ATTR_val_tbl          => v_pricing_attr_val_tbl
    );


   IF l_return_status =  fnd_api.g_ret_sts_error THEN
      FOR i in 1 .. l_msg_count LOOP
        l_msg_data :=  oe_msg_pub.get( p_msg_index => i,
                                       p_encoded => 'F' );

        FND_MESSAGE.SET_NAME('OZF','OZF_QP_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
        FND_MSG_PUB.ADD;
      END LOOP;
       RAISE FND_API.g_exc_error;

   ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
      FOR i in 1 .. l_msg_count LOOP
        l_msg_data :=  oe_msg_pub.get( p_msg_index => i,
                                       p_encoded => 'F' );

        FND_MESSAGE.SET_NAME('OZF','OZF_QP_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_MSG',l_msg_data);
        FND_MSG_PUB.ADD;
      END LOOP;
       RAISE FND_API.g_exc_unexpected_error;
   END IF;

END IF;

       FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded             =>      FND_API.G_FALSE );

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.g_ret_sts_error ;
    ROLLBACK TO move_segments;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        ROLLBACK TO move_segments;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_erroR ;
        ROLLBACK TO move_segments;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END;
/**
    Helper method to get product or category name.
    Logic for getting category_name is as:
    if category belongs to inventory categories then get concat_segments as before
    for backword compatibility, else if category belongs to unified product catelog
    get the category description as the parentage is not correct.
    */
FUNCTION get_product_name
  (   p_type        IN     VARCHAR2,
      p_prod_value  IN     NUMBER
  ) RETURN VARCHAR2  IS

CURSOR get_prod_name IS
SELECT description
  FROM mtl_system_items_kfv
 WHERE inventory_item_id = p_prod_value;

CURSOR get_eni_cat_name (p_catg_id NUMBER) IS
 SELECT eni.category_desc Category_Name
         FROM eni_prod_den_hrchy_parents_v eni
 WHERE eni.category_id = p_catg_id;

CURSOR get_mtl_cat_name (p_catg_id NUMBER) IS
 SELECT mtl.concatenated_segments Category_Name
         FROM mtl_categories_kfv mtl
 WHERE mtl.category_id = p_catg_id;

l_name VARCHAR2(4000);

BEGIN

  IF p_type = 'INV' THEN
   OPEN get_prod_name;
   FETCH get_prod_name INTO l_name;
   CLOSE get_prod_name;
  END IF;

  IF p_type = 'CAT' THEN
   OPEN get_eni_cat_name(p_prod_value);
   FETCH get_eni_cat_name INTO l_name;
   CLOSE get_eni_cat_name;
   IF l_name is NULL THEN
      OPEN get_mtl_cat_name(p_prod_value);
      FETCH get_mtl_cat_name INTO l_name;
      CLOSE get_mtl_cat_name;
   END IF;
  END IF;

  return (l_name);

END;

FUNCTION check_dup_product(p_list_header_id IN NUMBER, p_inv_item_id IN NUMBER)
RETURN VARCHAR2
IS

  l_item_in_prl  VARCHAR2(1) := 'N';

  CURSOR c_item_in_prl IS
  SELECT 'Y'
  FROM   DUAL
  WHERE  EXISTS(SELECT 1
                FROM   qp_pricing_attributes
                WHERE  product_attribute = 'PRICING_ATTRIBUTE1'
                AND    product_attr_value = p_inv_item_id
                AND    list_header_id = p_list_header_id);

BEGIN

  OPEN c_item_in_prl;
  FETCH c_item_in_prl INTO l_item_in_prl;
  CLOSE c_item_in_prl;

  RETURN l_item_in_prl;

END;


PROCEDURE add_inventory_item(
   p_api_version       IN  NUMBER,
   p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
   p_commit            IN  VARCHAR2  := FND_API.g_false,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_org_inv_item_id   IN  NUMBER,
   p_new_inv_item_id   IN num_tbl_type
)
IS
  l_api_name          CONSTANT VARCHAR2(30) := 'add_inventory_item';
  l_api_version       CONSTANT NUMBER := 1.0;
  l_index                      NUMBER := 1;
  l_item_in_prl                VARCHAR2(1);
  l_source_system_code         VARCHAR2(30);

  l_price_list_rec        QP_PRICE_LIST_PUB.Price_List_Rec_Type := QP_PRICE_LIST_PUB.G_MISS_PRICE_LIST_REC;
  l_price_list_line_tbl   QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type := QP_PRICE_LIST_PUB.G_MISS_PRICE_LIST_LINE_TBL;
  l_pricing_attr_tbl      QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type := QP_PRICE_LIST_PUB.G_MISS_PRICING_ATTR_TBL;

v_price_list_rec                     QP_PRICE_LIST_PUB.Price_List_Rec_Type;
v_price_list_val_rec            QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;
v_price_list_line_tbl           QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
v_price_list_line_val_tbl       QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;
v_qualifiers_tbl                     QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
v_qualifiers_val_tbl            QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;
v_pricing_attr_tbl                   QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
v_pricing_attr_val_tbl          QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

  CURSOR c_list_header_line_id (l_source_system_code VARCHAR2) IS
  SELECT DISTINCT qpa.list_header_id, qpa.list_line_id
  FROM   qp_pricing_attributes qpa, qp_list_lines qll, qp_list_headers_b qlh
  WHERE  qll.list_line_id = qpa.list_line_id
  AND    qpa.product_attribute = 'PRICING_ATTRIBUTE1'
  AND    qpa.product_attr_value = TO_CHAR(p_org_inv_item_id)
  AND    qlh.list_header_id = qpa.list_header_id
  AND    qlh.list_type_code = 'PRL'
  AND    qlh.source_system_code = l_source_system_code;

  CURSOR c_list_header_detail (l_list_header_id NUMBER) IS
  SELECT *
  FROM   qp_list_headers_vl
  WHERE  list_header_id = l_list_header_id;
  l_list_header_detail c_list_header_detail%ROWTYPE;

  CURSOR c_list_line_detail (l_list_line_id NUMBER) IS
  SELECT *
  FROM   qp_list_lines
  WHERE  list_line_id = l_list_line_id;
  l_list_line_detail c_list_line_detail%ROWTYPE;

  CURSOR c_pricing_detail (l_list_line_id NUMBER) IS
  SELECT *
  FROM   qp_pricing_attributes
  WHERE  list_line_id = l_list_line_id;
  l_pricing_detail c_pricing_detail%ROWTYPE;


  CURSOR c_list_line_id IS
  SELECT qp_list_lines_s.NEXTVAL
  FROM   DUAL;

  CURSOR c_pricing_attr_id IS
  SELECT qp_pricing_attributes_s.NEXTVAL
  FROM   DUAL;

  l_list_line_id     NUMBER;
  l_pricing_attr_id  NUMBER;

BEGIN

  SAVEPOINT add_inventory_item;

  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     g_pkg_name)
  THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  x_return_status  := FND_API.G_RET_STS_SUCCESS;

  l_source_system_code := FND_PROFILE.VALUE('QP_SOURCE_SYSTEM_CODE');

  FOR l_list_header_line_id IN c_list_header_line_id(l_source_system_code) LOOP
    OPEN c_list_line_detail(l_list_header_line_id.list_line_id);
    FETCH c_list_line_detail INTO l_list_line_detail;
    CLOSE c_list_line_detail;

    OPEN c_pricing_detail(l_list_header_line_id.list_line_id);
    FETCH c_pricing_detail INTO l_pricing_detail;
    CLOSE c_pricing_detail;

   FOR i IN 1..p_new_inv_item_id.COUNT LOOP
    l_item_in_prl := check_dup_product(l_list_header_line_id.list_header_id, p_new_inv_item_id(i));
    IF l_item_in_prl <> 'Y' THEN
      OPEN c_list_line_id;
      FETCH c_list_line_id INTO l_list_line_id;
      CLOSE c_list_line_id;

      OPEN c_pricing_attr_id;
      FETCH c_pricing_attr_id INTO l_pricing_attr_id;
      CLOSE c_pricing_attr_id;

    INSERT INTO qp_list_lines(list_line_id
                             ,accrual_qty
                             ,accrual_uom_code
                             ,arithmetic_operator
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
                             ,automatic_flag
                             ,base_qty
                             ,base_uom_code
                             ,comments
                             ,context
                             ,created_by
                             ,creation_date
                             ,last_updated_by
                             ,last_update_date
                             ,last_update_login
                             ,effective_period_uom
                             ,end_date_active
                             ,estim_accrual_rate
                             ,inventory_item_id
                             ,list_header_id
                             ,list_line_no
                             ,list_line_type_code
                             ,list_price
                             ,modifier_level_code
                             ,number_effective_periods
                             ,operand
                             ,organization_id
                             ,override_flag
                             ,percent_price
                             ,price_break_type_code
                             ,price_by_formula_id
                             ,primary_uom_flag
                             ,print_on_invoice_flag
                             ,program_application_id
                             ,program_id
                             ,program_update_date
                             ,rebate_transaction_type_code
                             ,related_item_id
                             ,relationship_type_id
                             ,reprice_flag
                             ,request_id
                             ,revision
                             ,revision_date
                             ,revision_reason_code
                             ,start_date_active
                             ,substitution_attribute
                             ,substitution_context
                             ,substitution_value
                             ,qualification_ind
                             ,pricing_phase_id
                             ,pricing_group_sequence
                             ,incompatibility_grp_code
                             ,product_precedence)
                       VALUES(l_list_line_id
                             ,l_list_line_detail.accrual_qty
                             ,l_list_line_detail.accrual_uom_code
                             ,l_list_line_detail.arithmetic_operator
                             ,l_list_line_detail.attribute1
                             ,l_list_line_detail.attribute2
                             ,l_list_line_detail.attribute3
                             ,l_list_line_detail.attribute4
                             ,l_list_line_detail.attribute5
                             ,l_list_line_detail.attribute6
                             ,l_list_line_detail.attribute7
                             ,l_list_line_detail.attribute8
                             ,l_list_line_detail.attribute9
                             ,l_list_line_detail.attribute10
                             ,l_list_line_detail.attribute11
                             ,l_list_line_detail.attribute12
                             ,l_list_line_detail.attribute13
                             ,l_list_line_detail.attribute14
                             ,l_list_line_detail.attribute15
                             ,l_list_line_detail.automatic_flag
                             ,l_list_line_detail.base_qty
                             ,l_list_line_detail.base_uom_code
                             ,l_list_line_detail.comments
                             ,l_list_line_detail.context
                             ,FND_GLOBAL.user_id
                             ,SYSDATE
                             ,FND_GLOBAL.user_id
                             ,SYSDATE
                             ,FND_GLOBAL.conc_login_id
                             ,l_list_line_detail.effective_period_uom
                             ,l_list_line_detail.end_date_active
                             ,l_list_line_detail.estim_accrual_rate
                             ,l_list_line_detail.inventory_item_id
                             ,l_list_header_line_id.list_header_id
                             ,l_list_line_id
                             ,l_list_line_detail.list_line_type_code
                             ,l_list_line_detail.list_price
                             ,l_list_line_detail.modifier_level_code
                             ,l_list_line_detail.number_effective_periods
                             ,l_list_line_detail.operand
                             ,l_list_line_detail.organization_id
                             ,l_list_line_detail.override_flag
                             ,l_list_line_detail.percent_price
                             ,l_list_line_detail.price_break_type_code
                             ,l_list_line_detail.price_by_formula_id
                             ,l_list_line_detail.primary_uom_flag
                             ,l_list_line_detail.print_on_invoice_flag
                             ,l_list_line_detail.program_application_id
                             ,l_list_line_detail.program_id
                             ,l_list_line_detail.program_update_date
                             ,l_list_line_detail.rebate_transaction_type_code
                             ,l_list_line_detail.related_item_id
                             ,l_list_line_detail.relationship_type_id
                             ,l_list_line_detail.reprice_flag
                             ,l_list_line_detail.request_id
                             ,l_list_line_detail.revision
                             ,l_list_line_detail.revision_date
                             ,l_list_line_detail.revision_reason_code
                             ,l_list_line_detail.start_date_active
                             ,l_list_line_detail.substitution_attribute
                             ,l_list_line_detail.substitution_context
                             ,l_list_line_detail.substitution_value
                             ,l_list_line_detail.qualification_ind
                             ,l_list_line_detail.pricing_phase_id
                             ,l_list_line_detail.pricing_group_sequence
                             ,l_list_line_detail.incompatibility_grp_code
                             ,l_list_line_detail.product_precedence);

    INSERT INTO qp_pricing_attributes(pricing_attribute_id
                                     ,accumulate_flag
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
                                     ,attribute_grouping_no
                                     ,context
                                     ,excluder_flag
                                     ,pricing_attribute
                                     ,pricing_attribute_context
                                     ,pricing_attr_value_from
                                     ,pricing_attr_value_to
                                     ,product_attribute
                                     ,product_attribute_context
                                     ,product_attr_value
                                     ,product_uom_code
                                     ,program_application_id
                                     ,program_id
                                     ,program_update_date
                                     ,request_id
                                     ,pricing_attr_value_from_number
                                     ,pricing_attr_value_to_number
                                     ,qualification_ind
                                     ,comparison_operator_code
                                     ,product_attribute_datatype
                                     ,pricing_attribute_datatype
                                     ,pricing_phase_id
                                     ,list_header_id
                                     ,list_line_id
--                                     ,list_line_no
                                     ,created_by
                                     ,creation_date
                                     ,last_updated_by
                                     ,last_update_date
                                     ,last_update_login)
                               VALUES(l_pricing_attr_id
                                     ,l_pricing_detail.accumulate_flag
                                     ,l_pricing_detail.attribute1
                                     ,l_pricing_detail.attribute2
                                     ,l_pricing_detail.attribute3
                                     ,l_pricing_detail.attribute4
                                     ,l_pricing_detail.attribute5
                                     ,l_pricing_detail.attribute6
                                     ,l_pricing_detail.attribute7
                                     ,l_pricing_detail.attribute8
                                     ,l_pricing_detail.attribute9
                                     ,l_pricing_detail.attribute10
                                     ,l_pricing_detail.attribute11
                                     ,l_pricing_detail.attribute12
                                     ,l_pricing_detail.attribute13
                                     ,l_pricing_detail.attribute14
                                     ,l_pricing_detail.attribute15
                                     ,l_pricing_detail.attribute_grouping_no
                                     ,l_pricing_detail.context
                                     ,l_pricing_detail.excluder_flag
                                     ,l_pricing_detail.pricing_attribute
                                     ,l_pricing_detail.pricing_attribute_context
                                     ,l_pricing_detail.pricing_attr_value_from
                                     ,l_pricing_detail.pricing_attr_value_to
                                     ,l_pricing_detail.product_attribute
                                     ,l_pricing_detail.product_attribute_context
                                     ,p_new_inv_item_id(i)
                                     ,l_pricing_detail.product_uom_code
                                     ,l_pricing_detail.program_application_id
                                     ,l_pricing_detail.program_id
                                     ,l_pricing_detail.program_update_date
                                     ,l_pricing_detail.request_id
                                     ,l_pricing_detail.pricing_attr_value_from_number
                                     ,l_pricing_detail.pricing_attr_value_to_number
                                     ,l_pricing_detail.qualification_ind
                                     ,l_pricing_detail.comparison_operator_code
                                     ,l_pricing_detail.product_attribute_datatype
                                     ,l_pricing_detail.pricing_attribute_datatype
                                     ,l_pricing_detail.pricing_phase_id
                                     ,l_list_header_line_id.list_header_id
                                     ,l_list_line_id
--                                     ,l_list_line_id
                                     ,FND_GLOBAL.user_id
                                     ,SYSDATE
                                     ,FND_GLOBAL.user_id
                                     ,SYSDATE
                                     ,FND_GLOBAL.conc_login_id);
    END IF;
   END LOOP;
  END LOOP;
/*
  FOR l_list_header_line_id IN c_list_header_line_id(l_source_system_code) LOOP
    l_price_list_line_tbl := QP_PRICE_LIST_PUB.G_MISS_PRICE_LIST_LINE_TBL;
    l_pricing_attr_tbl    := QP_PRICE_LIST_PUB.G_MISS_PRICING_ATTR_TBL;
    l_price_list_rec      := NULL;
    l_index               := 1;

    OPEN c_list_header_detail(l_list_header_line_id.list_header_id);
    FETCH c_list_header_detail INTO l_list_header_detail;
    CLOSE c_list_header_detail;

    l_price_list_rec.attribute1                 := l_list_header_detail.attribute1;
    l_price_list_rec.attribute2                 := l_list_header_detail.attribute2;
    l_price_list_rec.attribute3                 := l_list_header_detail.attribute3;
    l_price_list_rec.attribute4                 := l_list_header_detail.attribute4;
    l_price_list_rec.attribute5                 := l_list_header_detail.attribute5;
    l_price_list_rec.attribute6                 := l_list_header_detail.attribute6;
    l_price_list_rec.attribute7                 := l_list_header_detail.attribute7;
    l_price_list_rec.attribute8                 := l_list_header_detail.attribute8;
    l_price_list_rec.attribute9                 := l_list_header_detail.attribute9;
    l_price_list_rec.attribute10                := l_list_header_detail.attribute10;
    l_price_list_rec.attribute11                := l_list_header_detail.attribute11;
    l_price_list_rec.attribute12                := l_list_header_detail.attribute12;
    l_price_list_rec.attribute13                := l_list_header_detail.attribute13;
    l_price_list_rec.attribute14                := l_list_header_detail.attribute14;
    l_price_list_rec.attribute15                := l_list_header_detail.attribute15;
    l_price_list_rec.automatic_flag             := l_list_header_detail.automatic_flag;
    l_price_list_rec.comments                   := l_list_header_detail.comments;
    l_price_list_rec.context                    := l_list_header_detail.context;
    l_price_list_rec.discount_lines_flag        := l_list_header_detail.discount_lines_flag;
    l_price_list_rec.freight_terms_code         := l_list_header_detail.freight_terms_code;
    l_price_list_rec.gsa_indicator              := l_list_header_detail.gsa_indicator;
    l_price_list_rec.program_application_id     := l_list_header_detail.program_application_id;
    l_price_list_rec.program_id                 := l_list_header_detail.program_id;
    l_price_list_rec.program_update_date        := l_list_header_detail.program_update_date;
    l_price_list_rec.prorate_flag               := l_list_header_detail.prorate_flag;
    l_price_list_rec.request_id                 := l_list_header_detail.request_id;
    l_price_list_rec.ship_method_code           := l_list_header_detail.ship_method_code;
    l_price_list_rec.terms_id                   := l_list_header_detail.terms_id;
    l_price_list_rec.version_no                 := l_list_header_detail.version_no;
    l_price_list_rec.pte_code                   := l_list_header_detail.pte_code;
    l_price_list_rec.list_source_code           := l_list_header_detail.list_source_code;
    l_price_list_rec.orig_system_header_ref     := l_list_header_detail.orig_system_header_ref;
    l_price_list_rec.global_flag                := l_list_header_detail.global_flag;

    l_price_list_rec.name                       := l_list_header_detail.name;
    l_price_list_rec.description                := l_list_header_detail.description;
    l_price_list_rec.currency_code              := l_list_header_detail.currency_code;
    l_price_list_rec.start_date_active          := l_list_header_detail.start_date_active;
    l_price_list_rec.end_date_active            := l_list_header_detail.end_date_active;
    l_price_list_rec.currency_header_id         := l_list_header_detail.currency_header_id;
    l_price_list_rec.active_flag                := l_list_header_detail.active_flag;
    l_price_list_rec.list_type_code             := l_list_header_detail.list_type_code;
    l_price_list_rec.list_header_id             := l_list_header_line_id.list_header_id;
    l_price_list_rec.operation                  := QP_GLOBALS.G_OPR_UPDATE;
    l_price_list_rec.rounding_factor            := l_list_header_detail.rounding_factor;
    l_price_list_rec.created_by                 := l_list_header_detail.created_by;
    l_price_list_rec.creation_date              := l_list_header_detail.creation_date;

    OPEN c_list_line_detail(l_list_header_line_id.list_line_id);
    FETCH c_list_line_detail INTO l_list_line_detail;
    CLOSE c_list_line_detail;

    OPEN c_pricing_detail(l_list_header_line_id.list_line_id);
    FETCH c_pricing_detail INTO l_pricing_detail;
    CLOSE c_pricing_detail;

    FOR i IN 1..p_new_inv_item_id.COUNT LOOP
      -- check if the new item is already already in the price list
--      l_item_in_prl := check_duplicate_item(l_list_header_line_id.list_header_id, p_new_inv_item_id(i));
      IF l_item_in_prl = 'N' THEN
        l_price_list_line_tbl(l_index).accrual_qty               := l_list_line_detail.accrual_qty;
        l_price_list_line_tbl(l_index).accrual_uom_code          := l_list_line_detail.accrual_uom_code;
        l_price_list_line_tbl(l_index).arithmetic_operator       := l_list_line_detail.arithmetic_operator;
        l_price_list_line_tbl(l_index).attribute1                := l_list_line_detail.attribute1;
        l_price_list_line_tbl(l_index).attribute2                := l_list_line_detail.attribute2;
        l_price_list_line_tbl(l_index).attribute3                := l_list_line_detail.attribute3;
        l_price_list_line_tbl(l_index).attribute4                := l_list_line_detail.attribute4;
        l_price_list_line_tbl(l_index).attribute5                := l_list_line_detail.attribute5;
        l_price_list_line_tbl(l_index).attribute6                := l_list_line_detail.attribute6;
        l_price_list_line_tbl(l_index).attribute7                := l_list_line_detail.attribute7;
        l_price_list_line_tbl(l_index).attribute8                := l_list_line_detail.attribute8;
        l_price_list_line_tbl(l_index).attribute9                := l_list_line_detail.attribute9;
        l_price_list_line_tbl(l_index).attribute10               := l_list_line_detail.attribute10;
        l_price_list_line_tbl(l_index).attribute11               := l_list_line_detail.attribute11;
        l_price_list_line_tbl(l_index).attribute12               := l_list_line_detail.attribute12;
        l_price_list_line_tbl(l_index).attribute13               := l_list_line_detail.attribute13;
        l_price_list_line_tbl(l_index).attribute14               := l_list_line_detail.attribute14;
        l_price_list_line_tbl(l_index).attribute15               := l_list_line_detail.attribute15;
        l_price_list_line_tbl(l_index).automatic_flag            := l_list_line_detail.automatic_flag;
        l_price_list_line_tbl(l_index).base_qty                  := l_list_line_detail.base_qty;
        l_price_list_line_tbl(l_index).base_uom_code             := l_list_line_detail.base_uom_code;
        l_price_list_line_tbl(l_index).comments                  := l_list_line_detail.comments;
        l_price_list_line_tbl(l_index).context                   := l_list_line_detail.context;
        l_price_list_line_tbl(l_index).created_by                := l_list_line_detail.created_by;
        l_price_list_line_tbl(l_index).creation_date             := l_list_line_detail.creation_date;
        l_price_list_line_tbl(l_index).effective_period_uom      := l_list_line_detail.effective_period_uom;
        l_price_list_line_tbl(l_index).end_date_active           := l_list_line_detail.end_date_active;
        l_price_list_line_tbl(l_index).estim_accrual_rate        := l_list_line_detail.estim_accrual_rate;
        l_price_list_line_tbl(l_index).generate_using_formula_id := l_list_line_detail.generate_using_formula_id;
        l_price_list_line_tbl(l_index).inventory_item_id         := l_list_line_detail.inventory_item_id;
        l_price_list_line_tbl(l_index).list_header_id            := l_list_line_detail.list_header_id;
        l_price_list_line_tbl(l_index).list_line_type_code       := l_list_line_detail.list_line_type_code;
        l_price_list_line_tbl(l_index).list_price                := l_list_line_detail.list_price;
        l_price_list_line_tbl(l_index).modifier_level_code       := l_list_line_detail.modifier_level_code;
        l_price_list_line_tbl(l_index).number_effective_periods  := l_list_line_detail.number_effective_periods;
        l_price_list_line_tbl(l_index).operand                   := l_list_line_detail.operand;
        l_price_list_line_tbl(l_index).organization_id           := l_list_line_detail.organization_id;
        l_price_list_line_tbl(l_index).override_flag             := l_list_line_detail.override_flag;
        l_price_list_line_tbl(l_index).percent_price             := l_list_line_detail.percent_price;
        l_price_list_line_tbl(l_index).price_break_type_code     := l_list_line_detail.price_break_type_code;
        l_price_list_line_tbl(l_index).price_by_formula_id       := l_list_line_detail.price_by_formula_id;
        l_price_list_line_tbl(l_index).primary_uom_flag          := l_list_line_detail.primary_uom_flag;
        l_price_list_line_tbl(l_index).print_on_invoice_flag     := l_list_line_detail.print_on_invoice_flag;
        l_price_list_line_tbl(l_index).program_application_id    := l_list_line_detail.program_application_id;
        l_price_list_line_tbl(l_index).program_id                := l_list_line_detail.program_id;
        l_price_list_line_tbl(l_index).program_update_date       := l_list_line_detail.program_update_date;
        l_price_list_line_tbl(l_index).rebate_trxn_type_code     := l_list_line_detail.rebate_transaction_type_code;
        l_price_list_line_tbl(l_index).related_item_id           := l_list_line_detail.related_item_id;
        l_price_list_line_tbl(l_index).relationship_type_id      := l_list_line_detail.relationship_type_id;
        l_price_list_line_tbl(l_index).reprice_flag              := l_list_line_detail.reprice_flag;
        l_price_list_line_tbl(l_index).request_id                := l_list_line_detail.request_id;
        l_price_list_line_tbl(l_index).revision                  := l_list_line_detail.revision;
        l_price_list_line_tbl(l_index).revision_date             := l_list_line_detail.revision_date;
        l_price_list_line_tbl(l_index).revision_reason_code      := l_list_line_detail.revision_reason_code;
        l_price_list_line_tbl(l_index).start_date_active         := l_list_line_detail.start_date_active;
        l_price_list_line_tbl(l_index).substitution_attribute    := l_list_line_detail.substitution_attribute;
        l_price_list_line_tbl(l_index).substitution_context      := l_list_line_detail.substitution_context;
        l_price_list_line_tbl(l_index).substitution_value        := l_list_line_detail.substitution_value;
        l_price_list_line_tbl(l_index).product_precedence        := l_list_line_detail.product_precedence;
        l_price_list_line_tbl(l_index).qualification_ind         := l_list_line_detail.qualification_ind;
        l_price_list_line_tbl(l_index).operation                 := QP_GLOBALS.G_OPR_CREATE;

        l_pricing_attr_tbl(l_index).accumulate_flag                := l_pricing_detail.accumulate_flag ;
        l_pricing_attr_tbl(l_index).attribute1                     := l_pricing_detail.attribute1;
        l_pricing_attr_tbl(l_index).attribute2                     := l_pricing_detail.attribute2;
        l_pricing_attr_tbl(l_index).attribute3                     := l_pricing_detail.attribute3;
        l_pricing_attr_tbl(l_index).attribute4                     := l_pricing_detail.attribute4;
        l_pricing_attr_tbl(l_index).attribute5                     := l_pricing_detail.attribute5;
        l_pricing_attr_tbl(l_index).attribute6                     := l_pricing_detail.attribute6;
        l_pricing_attr_tbl(l_index).attribute7                     := l_pricing_detail.attribute7;
        l_pricing_attr_tbl(l_index).attribute8                     := l_pricing_detail.attribute8;
        l_pricing_attr_tbl(l_index).attribute9                     := l_pricing_detail.attribute9;
        l_pricing_attr_tbl(l_index).attribute10                    := l_pricing_detail.attribute10;
        l_pricing_attr_tbl(l_index).attribute11                    := l_pricing_detail.attribute11;
        l_pricing_attr_tbl(l_index).attribute12                    := l_pricing_detail.attribute12;
        l_pricing_attr_tbl(l_index).attribute13                    := l_pricing_detail.attribute13;
        l_pricing_attr_tbl(l_index).attribute14                    := l_pricing_detail.attribute14;
        l_pricing_attr_tbl(l_index).attribute15                    := l_pricing_detail.attribute15;
        l_pricing_attr_tbl(l_index).attribute_grouping_no          := l_pricing_detail.attribute_grouping_no;
        l_pricing_attr_tbl(l_index).context                        := l_pricing_detail.context;
        l_pricing_attr_tbl(l_index).excluder_flag                  := l_pricing_detail.excluder_flag;
        l_pricing_attr_tbl(l_index).pricing_attribute              := l_pricing_detail.pricing_attribute;
        l_pricing_attr_tbl(l_index).pricing_attribute_context      := l_pricing_detail.pricing_attribute_context;
        l_pricing_attr_tbl(l_index).pricing_attr_value_from        := l_pricing_detail.pricing_attr_value_from;
        l_pricing_attr_tbl(l_index).pricing_attr_value_to          := l_pricing_detail.pricing_attr_value_to;
        l_pricing_attr_tbl(l_index).product_attribute              := l_pricing_detail.product_attribute;
        l_pricing_attr_tbl(l_index).product_attribute_context      := l_pricing_detail.product_attribute_context;
        l_pricing_attr_tbl(l_index).product_attr_value             := p_new_inv_item_id(i);
        l_pricing_attr_tbl(l_index).product_uom_code               := l_pricing_detail.product_uom_code;
        l_pricing_attr_tbl(l_index).program_application_id         := l_pricing_detail.program_application_id;
        l_pricing_attr_tbl(l_index).program_id                     := l_pricing_detail.program_id;
        l_pricing_attr_tbl(l_index).program_update_date            := l_pricing_detail.program_update_date;
        l_pricing_attr_tbl(l_index).request_id                     := l_pricing_detail.request_id;
        l_pricing_attr_tbl(l_index).pricing_attr_value_from_number := l_pricing_detail.pricing_attr_value_from_number;
        l_pricing_attr_tbl(l_index).pricing_attr_value_to_number   := l_pricing_detail.pricing_attr_value_to_number;
        l_pricing_attr_tbl(l_index).qualification_ind              := l_pricing_detail.qualification_ind;
        l_pricing_attr_tbl(l_index).comparison_operator_code       := l_pricing_detail.comparison_operator_code;
        l_pricing_attr_tbl(l_index).product_attribute_datatype     := l_pricing_detail.product_attribute_datatype;
        l_pricing_attr_tbl(l_index).pricing_attribute_datatype     := l_pricing_detail.pricing_attribute_datatype;
        l_pricing_attr_tbl(l_index).list_header_id                 := l_pricing_detail.list_header_id;
        l_pricing_attr_tbl(l_index).pricing_phase_id               := l_pricing_detail.pricing_phase_id;
        l_pricing_attr_tbl(l_index).operation                      := QP_GLOBALS.G_OPR_CREATE;

        l_index := l_index + 1;
      END IF;
    END LOOP;

    QP_PRICE_LIST_PUB.Process_Price_List
            (   p_api_version_number            => p_api_version
            ,   p_init_msg_list                 => p_init_msg_list
            ,   p_return_values                 => FND_API.G_FALSE
            ,   p_commit                        => p_commit
            ,   x_return_status                 => x_return_status
            ,   x_msg_count                     => x_msg_count
            ,   x_msg_data                      => x_msg_data
            ,   p_price_list_rec                => l_price_list_rec
            ,   p_price_list_line_tbl           => l_price_list_line_tbl
            ,   p_pricing_attr_tbl              => l_pricing_attr_tbl
            ,   x_price_list_rec                => v_price_list_rec
            ,   x_price_list_val_rec            => v_price_list_val_rec
            ,   x_price_list_line_tbl           => v_price_list_line_tbl
            ,   x_price_list_line_val_tbl       => v_price_list_line_val_tbl
            ,   x_qualifiers_tbl                => v_qualifiers_tbl
            ,   x_qualifiers_val_tbl            => v_qualifiers_val_tbl
            ,   x_pricing_attr_tbl              => v_pricing_attr_tbl
            ,   x_pricing_attr_val_tbl          => v_pricing_attr_val_tbl
            );

    IF x_return_status =  fnd_api.g_ret_sts_error THEN
      FOR i in 1 .. x_msg_count LOOP
        x_msg_data :=  oe_msg_pub.get( p_msg_index => i,
                                       p_encoded => 'F' );
          FND_MESSAGE.SET_NAME('OZF','OZF_QP_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',x_msg_data);
          FND_MSG_PUB.ADD;
        END LOOP;
        RAISE FND_API.g_exc_error;

      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
        FOR i in 1 .. x_msg_count LOOP
          x_msg_data :=  oe_msg_pub.get( p_msg_index => i,
                                       p_encoded => 'F' );

          FND_MESSAGE.SET_NAME('OZF','OZF_QP_ERROR');
          FND_MESSAGE.SET_TOKEN('ERROR_MSG',x_msg_data);
          FND_MSG_PUB.ADD;
        END LOOP;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
  END LOOP;
*/
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.g_ret_sts_error ;
--    ROLLBACK TO add_inventory_item;
      FND_MSG_PUB.Count_AND_Get
         ( p_count       =>      x_msg_count,
           p_data        =>      x_msg_data,
           p_encoded    =>      FND_API.G_FALSE
          );
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.g_ret_sts_unexp_error ;
--        ROLLBACK TO add_inventory_item;
     FND_MSG_PUB.Count_AND_Get
         ( p_count           =>      x_msg_count,
           p_data            =>      x_msg_data,
           p_encoded        =>      FND_API.G_FALSE
          );
 WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_erroR ;
--        ROLLBACK TO add_inventory_item;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     FND_MSG_PUB.Count_AND_Get
       ( p_count           =>      x_msg_count,
         p_data            =>      x_msg_data,
         p_encoded         =>      FND_API.G_FALSE
        );

END add_inventory_item;

END OZF_PRICELIST_PVT;

/
