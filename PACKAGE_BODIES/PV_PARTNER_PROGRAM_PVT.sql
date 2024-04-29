--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_PROGRAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_PROGRAM_PVT" as
/* $Header: pvxvprgb.pls 120.12 2006/07/25 17:30:57 dgottlie ship $ */
-- Start of Comments
-- Package name: PV_PARTNER_PROGRAM_PVT
-- Purpose     :
-- History     : 28-FEB-2002    Ravi.Mikkilineni     Created
--                1-APR-2002    Peter.Nixon          Modified
--                         -    MEMBERSHIP columns (4) made nullable
--                         -    removed SOURCE_LANG column
--               22-APR-2002    Peter.Nixon          Modified
--                         -    restored SOURCE_LANG column
--                         -    removed PROGRAM_SHORT_NAME column
--                         -    changed PROGRAM_SETUP_TYPE column to PROGRAM_TYPE_ID
--                         -    added CUSTOM_SETUP_ID column
--                         -    added ENABLED_FLAG column
--                         -    added ATTRIBUTE_CATEGORY column
--                         -    added ATTRIBUTE1 thru ATTRIBUTE15 columns
--               20-MAY-2002    Peter.Nixon          Modified
--                         -    added call to PV_PROCESS_RULES_PUB api in Create_Partner_Program
--              28-May-2002-    pukken               Modified
--                              Added the call to ams_gen_approval_pvt.StartProcess and added function isApproverExists
--              04-Jun-2002     Added validation for delete and start and end dates of child program
--                              by adding 2 functions isProgramDeletable and isStartEndDateInRange
--              06-Jun-2002     pukken: Added function isEnrollApproverValid
--              14-Jun-2002     pukken: Added function isChildActivatable
--              09-Sep-2002 -   pukken: added columns  inventory_item_id ,inventory_item_org_id,
--                              bus_user_resp_id ,admin_resp_id,no_fee_flag,qsnr_ttl_all_page_dsp_flag ,
--                              qsnr_hdr_all_page_dsp_flag ,qsnr_ftr_all_page_dsp_flag ,allow_enrl_wout_chklst_flag,
--                              qsnr_title ,qsnr_header,qsnr_footer
--             10-Sep-2002 -    pukken: removed columns membership_fees and membership_currency_names
--             15-NOV-2002 -    sranka: Made FInal changes for the Pricing-Inventory creation
--   12/04/2002  SVEERAVE  added Close_Ended_programs that will close the ended programs.
--   12/04/2002  SVEERAVE  added check_price_exists function.
--   01/21/2003  SVEERAVE  added Get_Object_Name procedure for integration with OCM
--   01/22/2003  PUKKEN    changed validation for membership duration when its Activated or pending_approval only
--   02/03/03    PUKKEN    adding validation for system profile value for PV_PROGRAM_INV_FLEX_SEGMENTS
--   03/31/2003  sveerave  Close_ended_programs: Now, if any error happens, conc prog will completely
--                         error out. Changed in such a way that if error happens
--                         for a particular program, it will process all other non-errored
--                         records, but will complete with a waring for bug#2878969
--   06/27/2003  sveerave  Invoice Enabled Flag is set to 'Y' for bug# 3027596
--   06/27/2003  pukken    Code changes for 3 new columns for 11.5.10 enhancements
--   07/24/2003  ktsao     Code changes for program copy functionality
--   08/84/2003  ktsao     Change membership_type to member_type_code.
--   10/14/2003  ktsao     Took out the call to PV_PRGM_PMT_MODE_PVT.Copy_Prgm_Pmt_Mode.
--   11/11/2003  ktsao     Took out the responsibility_id in Copy_Benefits.
--   12/02/2003  ktsao     Made a call to AMS_PRICELIST_PVT.add_inventory_item in Copy_Payments().
--   12/08/2003  ktsao     Made a call to copy the program prerequisites in Copy_Qualifications().
--   12/08/2003  ktsao     Changed package name from AMS_PRICELIST_PVT to OZF_PRICELIST_PVT.
--   12/09/2003  ktsao     Modified Copy_Qualifications to copy the prereq process rules as well.
--   12/11/2003  ktsao     Switch the order of
--                            PVX_UTILITY_PVT.debug_message('l_new_inv_item_id(.....
--                         and
--                            l_index := l_index + 1;
--                         in Copy_Payments().
--   04/11/2005  ktsao     Code changes for create_inv_item_if_not_exists
--   04/27/2005  ktsao     Modified one of PV_PRGM_PRICE_UNDEFINED_SUBMIT to PV_PRGM_PRICE_UNDEFINED_ACTIVE
--   07/15/2005  dgottlie  Removed hard-coding of 'Ea' to be replaced with the value from PV_DEFAULT_UOM_CODE profile option
--   08/31/2005  ktsao     Modified one IF condition before calling create_inventory_item()
--   10/11/2005  amaram    Replaced the reference to JTF_PROFILE_DEFAULT_CURRENCY with ICX_PREFERRED_CURRENCY for R12
--
-- NOTE        :
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_PARTNER_PROGRAM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvprgb.pls';
l_msg_count              NUMBER;
l_msg   VARCHAR2(2000);
l_msg_data               VARCHAR2(2000);
l_ptr_prgm_update_rec       ptr_prgm_rec_type;
l_org_Id             NUMBER       := FND_PROFILE.Value('AMS_ITEM_ORGANIZATION_ID');
l_uom_code           VARCHAR2(10) := fnd_profile.value('PV_DEFAULT_UOM_CODE');
l_flx_fld            VARCHAR2(244);
l_temp_flx_fld       VARCHAR2(244);
l_rplc_str           VARCHAR2(40);


-- added for Creation of Inventory Item sranka
l_count NUMBER;
l_error_tbl          INV_Item_GRP.Error_tbl_type;
l_item_rec_out       INV_Item_GRP.Item_rec_type;
l_Item_rec INV_Item_GRP.Item_rec_type;
l_pricelist_line_id NUMBER;
l_inventory_item_id NUMBER ;
l_return_status          VARCHAR2(1);
l_operation  VARCHAR2(30);
l_isavailable boolean;
l_list_header_id NUMBER;
l_list_line_id NUMBER;
l_pricing_attribute_id NUMBER;

TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--to check whether there is a price list line or not
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   check_price_exists
   --
   -- PURPOSE
   --   Checks whether any price exists for a given program.
   -- IN
   --   program_id NUMBER
   -- OUT
   --   'Y' if exists
   --   'N' if not exists
   -- USED BY
   --   Program Approval API, and Activate API.
   -- HISTORY
   --   12/04/2002        sveerave        CREATION
   --------------------------------------------------------------------------

FUNCTION check_price_exists(p_program_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR get_price_line_details(p_program_id number) is
    SELECT 'Y'
    FROM dual
    WHERE
      EXISTS
      (SELECT 1
        FROM qp_list_attributes_v attr,pv_partner_program_b prg
        WHERE prg.program_id = p_program_id
          AND attr.PRODUCT_ATTR_VALUE = to_char(prg.inventory_item_id)
          AND attr.PRODUCT_ATTRIBUTE_CONTEXT = 'ITEM'
          AND attr.PRODUCT_ATTRIBUTE ='PRICING_ATTRIBUTE1'
          AND  NVL(attr.qpl_start_date_active,sysdate) <= sysdate
          AND  NVL(attr.qpl_END_DATE_ACTIVE,sysdate) >= sysdate
       );
    l_exists_flag VARCHAR2(1) := 'N';

BEGIN
  OPEN get_price_line_details(p_program_id);
  FETCH get_price_line_details INTO l_exists_flag;
  CLOSE get_price_line_details;
  RETURN l_exists_flag;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(l_exists_flag);
  WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END check_price_exists;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   check_inventory_item_exists
   --
   -- PURPOSE
   --   Checks whether any inventory item exists for a given program.
   -- IN
   --   program_id NUMBER
   -- OUT
   --   'Y' if exists
   --   'N' if not exists
   -- USED BY
   --   Program Approval API, and Activate API.
   -- HISTORY
   --   16/03/2005        ktsao        CREATION
   --------------------------------------------------------------------------

FUNCTION check_inventory_item_exists(p_program_id IN NUMBER)
RETURN VARCHAR2 IS
  CURSOR is_inventory_item_exists(p_program_id number) is
    SELECT 'Y'
    FROM dual
    WHERE
      EXISTS
      (SELECT 1
        FROM pv_partner_program_b
        WHERE program_id = p_program_id
        AND INVENTORY_ITEM_ID is not null
        AND INVENTORY_ITEM_ORG_ID is not null
      );
    l_exists_flag VARCHAR2(1) := 'N';

BEGIN
  OPEN is_inventory_item_exists(p_program_id);
  FETCH is_inventory_item_exists INTO l_exists_flag;
  CLOSE is_inventory_item_exists;
  RETURN l_exists_flag;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN(l_exists_flag);
  WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END check_inventory_item_exists;


FUNCTION check_membership_duration(p_program_id IN NUMBER)
RETURN VARCHAR2 IS
    CURSOR get_memb_dur( p_program_id number ) IS
            select  membership_period_unit,membership_valid_period
            FROM    pv_partner_program_b
            WHERE   program_id=p_program_id;
    l_exists_flag VARCHAR2(1) := 'Y';
    l_membership_period_unit VARCHAR2(15);
    l_membership_valid_period   NUMBER;

BEGIN
  OPEN get_memb_dur(p_program_id);
     FETCH get_memb_dur INTO l_membership_period_unit,l_membership_valid_period;
  CLOSE get_memb_dur;
  IF ( l_membership_period_unit is null OR l_membership_valid_period is null ) THEN
     l_exists_flag:='N';
  END IF;
  RETURN l_exists_flag;
EXCEPTION

  WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END check_membership_duration;


PROCEDURE create_inventory_item(
   p_ptr_prgm_rec    IN  ptr_prgm_rec_type,
   x_Item_rec        OUT NOCOPY INV_Item_GRP.Item_rec_type,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_Error_tbl       OUT NOCOPY INV_Item_GRP.Error_tbl_type
)
IS

   l_item_rec           INV_Item_GRP.Item_rec_type;
   l_ptr_prgm_rec       ptr_prgm_rec_type := p_ptr_prgm_rec;
   l_no NUMBER;
   l_flag VARCHAR2(1);

   CURSOR uom_csr IS
   select 'X'
   from mtl_uom_conversions conv, mtl_units_of_measure uom
   where nvl(conv.disable_date,sysdate+1) > sysdate
   and conv.inventory_item_id = 0
   and conv.unit_of_measure = uom.unit_of_measure
   and nvl(uom.disable_date, sysdate+1) > sysdate
   and conv.uom_code = l_uom_code;

BEGIN


-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Initialize inventory API return status to SUCCESS
--   x_item_return_status := FND_API.G_RET_STS_SUCCESS;

-- org id is Hard coded but need to find from the profile values


--   IF (p_program_rec.item_number IS NULL
--   OR p_program_rec.item_number = FND_API.g_miss_char)
--   THEN
--      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
--      THEN
--         FND_MESSAGE.set_name('PV', 'PV_PROGRAM_ENTER_PROPER_PARTNO');
--         FND_MSG_PUB.add;
--      END IF;
--      x_return_status := FND_API.g_ret_sts_error;
--      RETURN;
--   END IF;


   IF (l_org_Id IS NULL)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_SET_MASTER_INV_ORG_ID');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   IF (l_uom_code IS NULL)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_SET_DEFAULT_UOM_CODE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

-- /*** need to find the Item Number from profile value and than replce the val ***/

   l_flx_fld   := FND_PROFILE.Value_Specific('PV_PROGRAM_INV_FLEX_SEGMENTS',null,null,691);
   IF (l_flx_fld IS NULL)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_PROGRAM_INVENTORY_NOT_SET');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

   --check whether the profile value for PV_PROGRAM_INV_FLEX_SEGMENTS contains PV_PRGM_FLEX_CODE
   l_no:=INSTR(l_flx_fld,'PV_PRGM_FLEX_CODE');
   IF l_no=0 THEN
   	FND_MESSAGE.set_name('PV', 'PV_PRGM_PROF_VAL_INCORRECT');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
   END IF;
-- /*** here pre concatenating the val with 1st Five characters of the program Name so it is the unique ***/
-- Anothor reason for adding the program Name is bcos in the Order Mngmt screen the search is based on the
-- Item Number

  IF (length(l_ptr_prgm_rec.program_name) > 5) THEN
      l_rplc_str := SUBSTR(l_ptr_prgm_rec.program_name,1,5) || 'PV' || l_ptr_prgm_rec.program_id ;
   ELSE
      l_rplc_str := l_ptr_prgm_rec.program_name  || 'PV' ||  l_ptr_prgm_rec.program_id ;
   END IF;

   l_temp_flx_fld := REPLACE(l_flx_fld,'PV_PRGM_FLEX_CODE',l_rplc_str);

   l_item_rec.item_number := l_temp_flx_fld ; --REPLACE(l_flx_fld,'PV_PRGM_FLEX_CODE',l_rplc_str);
--   l_item_rec.item_number := 'PV_'|| l_ptr_prgm_rec.program_id ;

   l_item_rec.organization_id := l_org_Id;
   l_item_rec.description := l_ptr_prgm_rec.program_name;
   l_item_rec.long_description := l_ptr_prgm_rec.program_name;
   l_item_rec.customer_order_flag := 'Y';
   l_item_rec.customer_order_enabled_flag := 'Y';
   l_item_rec.shippable_item_flag := 'N';
   l_item_rec.INVOICEABLE_ITEM_FLAG := 'Y';
   -- fix for bug#3027596
   l_item_rec.invoice_enabled_flag := 'Y';
   l_item_rec.RETURNABLE_FLAG := 'N';
   l_item_rec.ORDERABLE_ON_WEB_FLAG := 'N';

   l_item_rec.PRIMARY_UOM_CODE := l_uom_code;
   -- befor creating inv item verify that the UOM code exists in inventory
   OPEN uom_csr;
      FETCH uom_csr INTO l_flag;
   CLOSE uom_csr;

   IF l_flag is NULL THEN
        Fnd_Message.SET_NAME('PV','PV_UOM_CODE_NOT_DEFINED');
        Fnd_Msg_Pub.ADD;
        RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- calling the inventory creation API

   INV_Item_GRP.Create_Item
       ( p_commit           =>  FND_API.G_FALSE
       , p_validation_level =>  fnd_api.g_VALID_LEVEL_FULL
       , p_Item_rec         =>  l_item_rec        /*P_ITEM_REC_In*/
       , x_Item_rec         =>  l_item_rec_out       /*P_ITEM_REC_Out*/
       , x_return_status    =>  x_return_status
       , x_Error_tbl        =>  l_error_tbl              /*x_Error_tbl*/
       );

    x_Item_rec := l_item_rec_out;

    -- dbms_output.put_line('The return status after Inventory creation is '||x_return_status);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF l_error_tbl.count >0 THEN
         FOR l_cnt IN 1..l_error_tbl.count LOOP
            x_error_tbl(l_cnt).transaction_id := l_error_tbl(l_cnt).transaction_id;
            x_error_tbl(l_cnt).unique_id       := l_error_tbl(l_cnt).unique_id;
            x_error_tbl(l_cnt).message_name    := l_error_tbl(l_cnt).message_name;
            -- dbms_output.put_line('The message name is '||x_error_tbl(l_cnt).message_name);
            x_error_tbl(l_cnt).message_text    := l_error_tbl(l_cnt).message_text;
            -- dbms_output.put_line('The message text is '||x_error_tbl(l_cnt).message_text);
            x_error_tbl(l_cnt).table_name      := l_error_tbl(l_cnt).table_name;
            x_error_tbl(l_cnt).column_name     := l_error_tbl(l_cnt).column_name;
            -- dbms_output.put_line('The coulmn name is '||x_error_tbl(l_cnt).column_name);
            x_error_tbl(l_cnt).organization_id := l_error_tbl(l_cnt).organization_id;
         END LOOP;
      END IF;
      FOR i IN 1 .. x_error_tbl.count LOOP
         Fnd_Message.SET_NAME('PV','PV_PRGM_CREAT_INVENTORY');
         Fnd_Message.SET_TOKEN('ERROR_MSG','Transaction_id is '|| x_error_tbl(i).transaction_id
                                         ||', message_name is '||x_error_tbl(i).message_name
                                         || ', mesage_text  is '||x_error_tbl(i).message_text
                                         ||  ', table name is '||x_error_tbl(i).table_name
                                         ||  ', column name is '||x_error_tbl(i).column_name
                                         ||  ', unique_id is ' ||x_error_tbl(i).unique_id
                                         ||   ', organisation id is ' || x_error_tbl(i).organization_id);
         Fnd_Msg_Pub.ADD;
      END LOOP;

      RAISE FND_API.G_EXC_ERROR;
   END IF;
END create_inventory_item;

-- This is no longer used as we are directly calling the AMS pricing fragment for the same.

PROCEDURE create_pricelist_line(
   p_ptr_prgm_rec      IN  ptr_prgm_rec_type,
   p_inventory_item_id IN  NUMBER,
   p_operation IN VARCHAR2,
-- The following two variables will be used in case of Update only
   p_list_header_id        IN NUMBER,
   p_pricing_attribute_id  IN NUMBER,
   x_return_status   OUT NOCOPY VARCHAR2,
   x_pricelist_line_id OUT NOCOPY NUMBER,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data  OUT NOCOPY VARCHAR2

)
IS

    l_price_list_rec         qp_price_list_pub.price_list_rec_type;
    l_price_list_val_rec     qp_price_list_pub.price_list_val_rec_type;

    l_price_list_line_tbl    qp_price_list_pub.price_list_line_tbl_type;
    l_price_list_line_val_tbl      qp_price_list_pub.price_list_line_val_tbl_type;

    l_qualifiers_tbl         qp_qualifier_rules_pub.qualifiers_tbl_type;
    l_qualifiers_val_tbl     qp_qualifier_rules_pub.qualifiers_val_tbl_type;

    l_pricing_attr_tbl       qp_price_list_pub.pricing_attr_tbl_type;
    l_pricing_attr_val_tbl   qp_price_list_pub.pricing_attr_val_tbl_type;


    v_price_list_rec          QP_PRICE_LIST_PUB.Price_List_Rec_Type;
    v_price_list_val_rec      QP_PRICE_LIST_PUB.Price_List_Val_Rec_Type;

    v_price_list_line_tbl     QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
    v_price_list_line_val_tbl QP_PRICE_LIST_PUB.Price_List_Line_Val_Tbl_Type;

    v_qualifiers_tbl          QP_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
    v_qualifiers_val_tbl      QP_Qualifier_Rules_Pub.Qualifiers_Val_Tbl_Type;

    v_pricing_attr_tbl        QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
    v_pricing_attr_val_tbl    QP_PRICE_LIST_PUB.Pricing_Attr_Val_Tbl_Type;

--    l_operation               CONSTANT VARCHAR2(30) := QP_GLOBALS.G_OPR_UPDATE; -- create or update


-- harding the value of the l_price_list_hdr_id but need to get from profile
    l_price_list_hdr_id CONSTANT NUMBER := 1000;
    l_ptr_prgm_rec       ptr_prgm_rec_type := p_ptr_prgm_rec;



    l_return_status VARCHAR2(1);
    l_msg_data  VARCHAR2(2000);
    l_msg_count NUMBER;

    l_isAvailable  BOOLEAN := false;
    l_list_header_id NUMBER;



BEGIN

   IF (l_uom_code IS NULL)
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_SET_DEFAULT_UOM_CODE');
         FND_MSG_PUB.add;
      END IF;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;

--dbms_output.put_line('passed p_operation in create_pricelist_line is ' || p_operation);
--dbms_output.put_line('passed no_fee_flag in create_pricelist_line is ' || l_ptr_prgm_rec.no_fee_flag);

-- Begin Price list line creation
--      IF l_operation = QP_GLOBALS.G_OPR_UPDATE THEN
        l_price_list_line_tbl(1).list_line_type_code := 'PLL';
        l_price_list_line_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;--l_operation ;
        l_price_list_line_tbl(1).base_uom_code := l_uom_code;
        l_price_list_line_tbl(1).arithmetic_operator := 'UNIT_PRICE';
        l_price_list_line_tbl(1).list_header_id := 1000; --l_price_list_hdr_id;
        l_price_list_line_tbl(1).list_line_id := FND_API.G_MISS_NUM;
        l_price_list_line_tbl(1).list_price := l_ptr_prgm_rec.membership_fees; -- may need currency conversion
        l_price_list_line_tbl(1).operand := l_ptr_prgm_rec.membership_fees; --l_ptr_prgm_rec.membership_fees;
        l_price_list_line_tbl(1).created_by := l_ptr_prgm_rec.created_by;--l_ptr_prgm_rec.created_by ; --l_ptr_prgm_rec.created_by;
        l_price_list_line_tbl(1).last_updated_by := l_ptr_prgm_rec.last_updated_by; --l_ptr_prgm_rec.created_by;
        l_price_list_line_tbl(1).inventory_item_id := p_inventory_item_id; --p_inventory_item_id; -- output of the Item Creation API
--        l_price_list_line_tbl(1).start_date_active := sysdate;
-- get fro the profile val
        l_price_list_line_tbl(1).organization_id := l_org_Id;
--        l_price_list_line_tbl(1).revision := 1;


    -- populate pricing attributes table.
        l_pricing_attr_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;--QP_GLOBALS.G_OPR_UPDATE;
        l_pricing_attr_tbl(1).PRODUCT_ATTRIBUTE_CONTEXT := 'ITEM';
        l_pricing_attr_tbl(1).PRODUCT_ATTRIBUTE := 'PRICING_ATTRIBUTE1';
        l_pricing_attr_tbl(1).PRODUCT_ATTR_VALUE := p_inventory_item_id; --p_inventory_item_id; -- output of the Item Creation API
        l_pricing_attr_tbl(1).PRICE_LIST_LINE_index :=1;
        l_pricing_attr_tbl(1).product_uom_code := l_uom_code;

--        -- dbms_output.put_line('l_ptr_prgm_rec.no_fee_flag ' || l_ptr_prgm_rec.no_fee_flag);
--        IF (PV_DEBUG_HIGH_ON) THEN                PVX_UTILITY_PVT.debug_message('l_ptr_prgm_rec.no_fee_flag ' || l_ptr_prgm_rec.no_fee_flag);        END IF;



if  (p_operation =  QP_GLOBALS.G_OPR_UPDATE)  THEN

      l_price_list_line_tbl(1).list_line_id := p_list_header_id; --p_list_header_id; -- need to change the var name
      l_price_list_line_tbl(1).list_header_id := 1000; -- p_list_header_id;
      l_price_list_line_tbl(1).operation :=  QP_GLOBALS.G_OPR_UPDATE;
      l_pricing_attr_tbl(1).operation := QP_GLOBALS.G_OPR_UPDATE;
      l_pricing_attr_tbl(1).pricing_attribute_id := p_pricing_attribute_id;

--    IF (l_ptr_prgm_rec.no_fee_flag = 'N') THEN
--      dbms_output.put_line('HERE UPDATING THE PRICE RECORD WITH NEW PRICE VALUES ');
--      l_price_list_line_tbl(1).list_price := 00; -- may need currency covnersion
--      l_price_list_line_tbl(1).operand := 00;
--    ELSIF (l_ptr_prgm_rec.no_fee_flag = 'Y') THEN
--      dbms_output.put_line('HERE UPDATING THE PRICE RECORD WITH END DATE ACTIVE ');
--      l_price_list_line_tbl(1).end_date_active := sysdate;
--    END IF;

      QP_PRICE_LIST_PUB.Process_Price_List
        (   p_api_version_number            => 1.0
        ,   p_init_msg_list                 => FND_API.G_TRUE
        ,   p_return_values                 => FND_API.G_TRUE
        ,   p_commit                        => FND_API.G_FALSE

        ,   x_return_status                 => l_return_status
        ,   x_msg_count                     => l_msg_count
        ,   x_msg_data                      => l_msg_data
        ,   p_price_list_rec                => l_price_list_rec

        ,   p_price_list_val_rec            => l_price_list_val_rec
        ,   p_price_list_line_tbl           => l_price_list_line_tbl
        ,   p_price_list_line_val_tbl       => l_price_list_line_val_tbl
        ,   p_pricing_attr_tbl              => l_pricing_attr_tbl

        ,   p_pricing_attr_val_tbl          => l_pricing_attr_val_tbl
        ,   p_qualifiers_tbl                => l_qualifiers_tbl
        ,   p_qualifiers_val_tbl            => l_qualifiers_val_tbl
        ,   x_price_list_rec                => v_price_list_rec

        ,   x_price_list_val_rec            => v_price_list_val_rec
        ,   x_price_list_line_tbl           => v_price_list_line_tbl
        ,   x_price_list_line_val_tbl       => v_price_list_line_val_tbl
        ,   x_qualifiers_tbl                => v_qualifiers_tbl

        ,   x_qualifiers_val_tbl            => v_qualifiers_val_tbl
        ,   x_pricing_attr_tbl              => v_pricing_attr_tbl
        ,   x_pricing_attr_val_tbl          => v_pricing_attr_val_tbl
       );

      -- dbms_output.put_line('IN UPDATE BLOCK : l_return_status  : ' || l_return_status);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN UPDATE BLOCK : l_return_status  : ' || l_return_status);
      END IF;

      -- dbms_output.put_line('IN UPDATE BLOCK :  l_msg_count  : ' || l_msg_count);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN UPDATE BLOCK :  l_msg_count  : ' || l_msg_count);
      END IF;

      -- dbms_output.put_line('IN UPDATE BLOCK :  l_msg_data  : ' || l_msg_data);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN UPDATE BLOCK : l_msg_data  : ' || l_msg_data);
      END IF;


ELSE

--      l_price_list_line_tbl(1).revision := 3;
        l_price_list_line_tbl(1).start_date_active := sysdate;

      QP_PRICE_LIST_PUB.Process_Price_List
        (   p_api_version_number            => 1.0
        ,   p_init_msg_list                 => FND_API.G_TRUE
        ,   p_return_values                 => FND_API.G_TRUE
        ,   p_commit                        => FND_API.G_FALSE

        ,   x_return_status                 => l_return_status
        ,   x_msg_count                     => l_msg_count
        ,   x_msg_data                      => l_msg_data
        ,   p_price_list_rec                => l_price_list_rec

        ,   p_price_list_val_rec            => l_price_list_val_rec
        ,   p_price_list_line_tbl           => l_price_list_line_tbl
        ,   p_price_list_line_val_tbl       => l_price_list_line_val_tbl
        ,   p_pricing_attr_tbl              => l_pricing_attr_tbl

        ,   p_pricing_attr_val_tbl          => l_pricing_attr_val_tbl
        ,   p_qualifiers_tbl                => l_qualifiers_tbl
        ,   p_qualifiers_val_tbl            => l_qualifiers_val_tbl
        ,   x_price_list_rec                => v_price_list_rec

        ,   x_price_list_val_rec            => v_price_list_val_rec
        ,   x_price_list_line_tbl           => v_price_list_line_tbl
        ,   x_price_list_line_val_tbl       => v_price_list_line_val_tbl
        ,   x_qualifiers_tbl                => v_qualifiers_tbl

        ,   x_qualifiers_val_tbl            => v_qualifiers_val_tbl
        ,   x_pricing_attr_tbl              => v_pricing_attr_tbl
        ,   x_pricing_attr_val_tbl          => v_pricing_attr_val_tbl
       );


      -- dbms_output.put_line('IN CREATE BLOCK : l_return_status  : ' || l_return_status);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN CREATE BLOCK : l_return_status  : ' || l_return_status);
      END IF;

      -- dbms_output.put_line('IN CREATE BLOCK :  l_msg_count  : ' || l_msg_count);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN CREATE BLOCK :  l_msg_count  : ' || l_msg_count);
      END IF;

      -- dbms_output.put_line('IN CREATE BLOCK :  l_msg_data  : ' || l_msg_data);
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN CREATE BLOCK : l_msg_data  : ' || l_msg_data);
      END IF;

     -- Standard call to get message count and if count=1, get the message
--     OE_MSG_PUB.Count_And_Get (
--             p_encoded => FND_API.G_FALSE
--            ,p_count   => x_msg_count
--            ,p_data    => x_msg_data
--            );
--       l_count := OE_MSG_PUB.count_msg;
--       FOR i IN 1 .. l_count LOOP
--          l_msg := OE_MSG_PUB.get(i, FND_API.g_false);
--          -- holiu: remove since adchkdrv does not like it
--          -- dbms_OUTPUT.put_line('( IN CREATE BLOCK :' || i || ') ' || l_msg);
--          IF (PV_DEBUG_HIGH_ON) THEN                    PVX_UTILITY_PVT.debug_message('(' || i || ') ' || l_msg);          END IF;
--       END LOOP;
END IF;




 x_pricelist_line_id := v_PRICE_LIST_LINE_tbl(1).list_line_id;
-- x_pricelist_line_id := 1000;
--
-- dbms_output.put_line('111 The x_pricelist_line_id is  : '||v_PRICE_LIST_LINE_tbl(1).list_line_id);
IF (PV_DEBUG_HIGH_ON) THEN

PVX_UTILITY_PVT.debug_message('111 The x_pricelist_line_id is  : '||v_PRICE_LIST_LINE_tbl(1).list_line_id);
END IF;

 -- dbms_output.put_line('l_msg_count '|| l_msg_count);
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('l_msg_count '|| l_msg_count);
 END IF;

 -- dbms_output.put_line('l_msg_data '|| l_msg_data);
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('l_msg_data '|| l_msg_data);
 END IF;


--   l_count := OE_MSG_PUB.count_msg;
--   FOR i IN 1 .. l_count LOOP
--      l_msg := OE_MSG_PUB.get(i, FND_API.g_false);
--      -- holiu: remove since adchkdrv does not like it
--      DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
--      IF (PV_DEBUG_HIGH_ON) THEN            PVX_UTILITY_PVT.debug_message('(' || i || ') ' || l_msg);      END IF;
--   END LOOP;

-- dbms_output.put_line('Printing Error Messages from FND');
--
--   l_count := FND_MSG_PUB.count_msg;
--   FOR i IN 1 .. l_count LOOP
--      l_msg := FND_MSG_PUB.get(i, FND_API.g_false);
--      -- holiu: remove since adchkdrv does not like it
--      DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
--   END LOOP;

 x_return_status     := l_return_status;
 x_msg_count         := l_msg_count;
 x_msg_data          := l_msg_data;



    IF x_return_status = FND_API.g_ret_sts_error THEN
     RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
     RAISE FND_API.g_exc_unexpected_error;
    END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_UTILITY_PVT.debug_message('In CREATE_PRICE_LINE API ERROR BLOCK');

     END IF;

     -- Standard call to get message count and if count=1, get the message
--     OE_MSG_PUB.Count_And_Get (
--             p_encoded => FND_API.G_FALSE
--            ,p_count   => x_msg_count
--            ,p_data    => x_msg_data
--            );
--       l_count := OE_MSG_PUB.count_msg;
--       FOR i IN 1 .. l_count LOOP
--          l_msg := OE_MSG_PUB.get(i, FND_API.g_false);
--          -- holiu: remove since adchkdrv does not like it
--          DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
--          IF (PV_DEBUG_HIGH_ON) THEN                    PVX_UTILITY_PVT.debug_message('(' || i || ') ' || l_msg);          END IF;
--       END LOOP;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     OE_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,'CREATE_PAROGRAM');
     END IF;

   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
END create_pricelist_line;

--to check whether there is a valid approver for the program type
FUNCTION isApproverExists (p_program_type_id in number) return boolean is
    l_temp varchar2(1);
    isavailable boolean:=false ;
    cursor app_cur(p_prgm_type_id varchar) is
          select 'X' from dual where exists
           (select approver_id from ams_approvers appr,ams_approval_details apdt
                where  nvl(appr.start_date_active,sysdate)<=sysdate
                and nvl(appr.end_date_active,sysdate)>=sysdate
                and appr.ams_approval_detail_id =apdt.approval_detail_id
                and apdt.approval_object_type=p_prgm_type_id
                and apdt.approval_object='PRGT'
		and apdt.approval_type='CONCEPT'
            and nvl(apdt.active_flag,'Y') = 'Y'
        and nvl(appr.active_flag,'Y')='Y'
           );
 BEGIN
     OPEN app_cur(to_char(p_program_type_id));
        FETCH app_cur into l_temp;
        if app_cur%found THEN
           isavailable:=true;
        end if;
      CLOSE app_cur;
      return isavailable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isApproverExists;

-- this function is to check whether there is atleast one enrollment approver for the
-- program whose(APPROVER's end date) end date is greater than program's end date.
/*FUNCTION isEnrollApproverValid (p_program_id in number,p_end_date Date) return boolean is
    l_temp varchar2(1);
    isavailable boolean:=false ;
    cursor enr_cur(p_prgm_id varchar,edate Date) is
         select 'X' from dual where exists
           (select approver_id from ams_approvers appr,ams_approval_details apdt
                where  nvl(appr.end_date_active,sysdate)>=edate
                and appr.ams_approval_detail_id =apdt.approval_detail_id
                and apdt.approval_object_type=p_prgm_id
                and apdt.approval_object='PRGM'
            and nvl(apdt.active_flag,'Y') = 'Y'
        and nvl(appr.active_flag,'Y')='Y'
           );
 BEGIN
     OPEN enr_cur(to_char(p_program_id),p_end_date);
        FETCH enr_cur into l_temp;
        if enr_cur%found THEN
           isavailable:=true;
        end if;
      CLOSE enr_cur;
      return isavailable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isEnrollApproverValid;
*/

FUNCTION isProgramDeletable (p_program_id in number) return boolean is
    l_temp varchar2(1);
    isDeletable boolean:=true ;
    cursor rec_cur(p_prgm_id number) is
          select 'X' from dual where exists (
               select program_id from pv_partner_program_b
               where program_parent_id=p_prgm_id
               and enabled_flag='Y');
 BEGIN
     OPEN rec_cur(p_program_id);
        FETCH rec_cur into  l_temp;
        if rec_cur%found THEN
           isDeletable:=false;
        end if;
      CLOSE rec_cur;
      return isDeletable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isProgramDeletable;

--to check whether the start and end date of the program within the range of parent's start and end date
FUNCTION isStartEndDateInRange (p_parent_program_id in number,start_date in Date,end_date in Date) return boolean is
    l_parent_program_start_date Date;
    l_parent_program_end_date Date;
    isDatesInRange boolean:=false ;
    cursor startend_cur(p_parent_prgm_id number) is
          select program_start_date,program_end_date from pv_partner_program_b where program_id=p_parent_prgm_id;
 BEGIN
     OPEN startend_cur(p_parent_program_id);
        FETCH startend_cur into l_parent_program_start_date,l_parent_program_end_date;
        if startend_cur%found THEN
           if (start_date>=l_parent_program_start_date) and (end_date<=l_parent_program_end_date) THEN
              isDatesInRange:=true;
           end if;
        end if;
     CLOSE startend_cur;
     return isDatesInRange;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isStartEndDateInRange;

--to check whether No Enrollments After Date is in between start and end date
FUNCTION isNoEnrlDateInRange (p_enrl_date in Date,p_start_date in Date,p_end_date in Date) return boolean is

    isDatesInRange boolean:=true ;

 BEGIN

           if ( p_enrl_date<p_start_date OR p_enrl_date>p_end_date ) THEN
              isDatesInRange:=false;
           end if;

     return isDatesInRange;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isNoEnrlDateInRange;

FUNCTION isChildActivatable (p_parent_program_id in number) return boolean is

    l_parent_program_status varchar2(30);
    isActivatable boolean:=false ;
    cursor parentprogramstatus_cur(p_parent_prgm_id number) is
          select  PROGRAM_STATUS_CODE from pv_partner_program_b where program_id=p_parent_prgm_id;
 BEGIN
     OPEN parentprogramstatus_cur(p_parent_program_id);
        FETCH parentprogramstatus_cur into l_parent_program_status;
        if parentprogramstatus_cur%found THEN
           if  l_parent_program_status='ACTIVE' THEN
               isActivatable:=true;
           end if;
        end if;
     CLOSE parentprogramstatus_cur;
     return isActivatable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isChildActivatable;


FUNCTION isParentApproved (p_parent_program_id in number) return boolean is

    l_parent_program_status varchar2(30);
    isApproved boolean:=false ;
    cursor parentprogramstatus_cur(p_parent_prgm_id number) is
          select  PROGRAM_STATUS_CODE from pv_partner_program_b where program_id=p_parent_prgm_id;
 BEGIN
     OPEN parentprogramstatus_cur(p_parent_program_id);
        FETCH parentprogramstatus_cur into l_parent_program_status;
        if parentprogramstatus_cur%found THEN
           if  l_parent_program_status in ('APPROVED','ACTIVE')  THEN
               isApproved:=true;
           end if;
        end if;
     CLOSE parentprogramstatus_cur;
     return isApproved;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isParentApproved;

FUNCTION isProgramCancellable (p_program_id in number) return boolean is

-- A program cannot be cancelled untill the child programs are cancelled or archived or closed
--returns false if there is any active child program which has a status of new,pending_approval,approved,rejected,active.

    l_status varchar2(1);
    isCancellable boolean:=true;
    cursor childprogramstatus_cur(p_prgm_id number) is
               select 'X' from dual where exists(
               select  PROGRAM_STATUS_CODE from pv_partner_program_b where program_parent_id=p_prgm_id
                       and  PROGRAM_STATUS_CODE not in('CANCEL','CLOSED','ARCHIVE') and enabled_flag='Y' );

 BEGIN

     OPEN childprogramstatus_cur(p_program_id);
        FETCH childprogramstatus_cur into l_status;
        IF childprogramstatus_cur%found THEN
                   isCancellable:=false;
        END IF;
     CLOSE childprogramstatus_cur;
     return isCancellable;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END isProgramCancellable;

PROCEDURE get_program_status_code(
   p_user_status_id  IN  NUMBER,
   x_status_code     OUT NOCOPY VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS

   l_status_code     VARCHAR2(30);

   cursor c_status_code(p_prgm_user_status_id number) is

   SELECT system_status_code
     FROM ams_user_statuses_b
    WHERE user_status_id = p_prgm_user_status_id
       AND system_status_type = 'PV_PROGRAM_STATUS'
      AND enabled_flag = 'Y';

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   OPEN c_status_code(p_user_status_id);
   FETCH c_status_code INTO l_status_code ;
   CLOSE c_status_code;

   IF l_status_code IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.set_name('PV', 'PV_PROGRAM_BAD_USER_STATUS');
      FND_MESSAGE.set_token('ID',to_char( p_user_status_id) );
      FND_MSG_PUB.add;
   END IF;

   x_status_code := l_status_code;

END get_program_status_code;

PROCEDURE Create_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type  := g_miss_ptr_prgm_rec
    ,p_identity_resource_id       IN   NUMBER
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,x_program_id                 OUT NOCOPY  NUMBER
    )

 IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Create_Partner_Program';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status                       VARCHAR2(1);
   l_ptr_prgm_rec                        ptr_prgm_rec_type                   := p_ptr_prgm_rec;
   l_rules_rec                           PV_RULE_RECTYPE_PUB.rules_rec_type  := PV_RULE_RECTYPE_PUB.g_miss_rules_rec;
   l_process_rule_id                     NUMBER;
   l_prereq_process_rule_Id              NUMBER;
   l_object_version_number               NUMBER                          := 1;
   l_uniqueness_check                    VARCHAR2(1);
   l_access_rec   AMS_Access_Pvt.access_rec_type ;
   l_dummy_id     NUMBER ;
   l_start_end_date_within_range         boolean :=false;
   l_isNoEnrlDateInRange boolean:=true;
   l_currency              VARCHAR2(60);
   -- Cursor to get the sequence for pv_partner_program_b
   CURSOR c_partner_program_id_seq IS
      SELECT PV_PARTNER_PROGRAM_B_S.NEXTVAL
      FROM dual;

   -- Cursor to validate the uniqueness
   CURSOR c_partner_program_id_exists(l_id IN NUMBER) IS
      SELECT 'X'
      FROM PV_PARTNER_PROGRAM_B
      WHERE PROGRAM_ID = l_id;

   CURSOR c_resource_id(p_user_id IN NUMBER) IS
      SELECT RESOURCE_ID
      FROM   jtf_rs_resource_extns
      WHERE  USER_ID=p_user_id;

BEGIN
      ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Partner_Program_PVT;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       --------------- validate -------------------------

      IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      get_program_status_code(l_ptr_prgm_rec.user_status_id,l_ptr_prgm_rec.program_status_code,x_return_status);

      IF l_ptr_prgm_rec.PROGRAM_ID IS NULL OR
        l_ptr_prgm_rec.program_ID = FND_API.g_miss_NUM THEN
        LOOP
           -- Get the identifier
           OPEN c_partner_program_id_seq;
           FETCH c_partner_program_id_seq INTO l_ptr_prgm_rec.program_id;
           CLOSE c_partner_program_id_seq;

           -- Check the uniqueness of the identifier
           OPEN c_partner_program_id_exists(l_ptr_prgm_rec.program_id);
           FETCH c_partner_program_id_exists INTO l_uniqueness_check;
           -- Exit when the identifier uniqueness is established
             EXIT WHEN c_partner_program_id_exists%ROWCOUNT = 0;
           CLOSE c_partner_program_id_exists;
        END LOOP;
      END IF;


     OPEN c_resource_id(FND_GLOBAL.USER_ID);
        FETCH c_resource_id into l_rules_rec.owner_resource_id;
     CLOSE c_resource_id;

     --get the currency of the logged in user
      l_currency:=FND_PROFILE.Value('ICX_PREFERRED_CURRENCY');
      IF l_currency IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_PRGM_CURRENCY_UNDEFINED');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      --program name is a required filed for process rule api and so doing the validation here.
      IF l_ptr_prgm_rec.program_name = FND_API.g_miss_char
       OR l_ptr_prgm_rec.program_name IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_NAME');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;

      END IF;
      -- Create and get process_rule_id
      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - get process_rule_id');
      END IF;

          -- Populate the default required items for process_rule_id
           l_rules_rec.process_type          := 'PARTNER_PROGRAM';
           l_rules_rec.rank                  := 0;
           l_rules_rec.object_version_number := l_object_version_number;
           l_rules_rec.last_update_date      := SYSDATE;
           l_rules_rec.last_updated_by       := FND_GLOBAL.USER_ID;
           l_rules_rec.creation_date         := SYSDATE;
           l_rules_rec.created_by            := FND_GLOBAL.USER_ID;
           l_rules_rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;
           l_rules_rec.start_date            := sysdate;
           l_rules_rec.status_code           := 'ACTIVE';
           l_rules_rec.end_date              :=  null;
           l_rules_rec.currency_code         :=  l_currency;
           l_rules_rec.process_rule_name     := l_ptr_prgm_rec.program_name;
           l_rules_rec.description           := l_ptr_prgm_rec.program_description;


         -- Invoke process_rule_id api
         PV_PROCESS_RULES_PUB.Create_Process_Rules(
            p_api_version_number        => 2.0
           ,p_init_msg_list             => FND_API.g_false
           ,p_commit                    => FND_API.g_false
           ,p_validation_level          => p_validation_level
           ,p_rules_rec                 => l_rules_rec
           ,p_identity_resource_id      => p_identity_resource_id
           ,x_process_rule_id           => l_process_rule_id
           ,x_return_status             => x_return_status
           ,x_msg_count                 => x_msg_count
           ,x_msg_data                  => x_msg_data
           );

         l_ptr_prgm_rec.process_rule_id := l_process_rule_id;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;





          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  PV_PROCESS_RULES_PUB.Create_Process_Rules return_status = ' || x_return_status );
          END IF;
          -- End of call to PV_PROCESS_RULES_PUB.Create_Process_Rules

         -- Invoke prereq_process_rule_Id api
         PV_PROCESS_RULES_PUB.Create_Process_Rules(
            p_api_version_number        => 2.0
           ,p_init_msg_list             => FND_API.g_false
           ,p_commit                    => FND_API.g_false
           ,p_validation_level          => p_validation_level
           ,p_rules_rec                 => l_rules_rec
           ,p_identity_resource_id      => p_identity_resource_id
           ,x_process_rule_id           => l_prereq_process_rule_Id
           ,x_return_status             => x_return_status
           ,x_msg_count                 => x_msg_count
           ,x_msg_data                  => x_msg_data
           );

         l_ptr_prgm_rec.prereq_process_rule_Id := l_prereq_process_rule_Id;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  PV_PROCESS_RULES_PUB.Create_Process_Rules return_status = ' || x_return_status );
      END IF;


      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - program_id = '|| l_ptr_prgm_rec.program_id);
      END IF;

      -- Populate the default required items
      l_ptr_prgm_rec.last_update_date      := SYSDATE;
      l_ptr_prgm_rec.last_updated_by       := FND_GLOBAL.USER_ID;
      l_ptr_prgm_rec.creation_date         := SYSDATE;
      l_ptr_prgm_rec.created_by            := FND_GLOBAL.USER_ID;
      l_ptr_prgm_rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;
      l_ptr_prgm_rec.object_version_number := l_object_version_number;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - Validate_Partner_Program');
          END IF;

          -- populate enabled flag only if value not passed from application
           IF l_ptr_prgm_rec.enabled_flag = FND_API.g_miss_char THEN
             l_ptr_prgm_rec.enabled_flag        := 'Y';
           END IF;


         -- Invoke validation procedures
          Validate_partner_program(
             p_api_version_number        => 1.0
            ,p_init_msg_list             => FND_API.G_FALSE
            ,p_validation_level          => p_validation_level
            ,p_validation_mode           => JTF_PLSQL_API.g_create
            ,p_ptr_prgm_rec              => l_ptr_prgm_rec
            ,x_return_status             => x_return_status
            ,x_msg_count                 => x_msg_count
            ,x_msg_data                  => x_msg_data
            );
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  Validate_Partner_Program return_status = ' || x_return_status );
          END IF;

      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;




   l_access_rec.act_access_to_object_id := l_ptr_prgm_rec.program_id;
   l_access_rec.arc_act_access_to_object := 'PRGM' ;
   l_access_rec.arc_user_or_role_type := 'USER' ;
   l_access_rec.delete_flag := 'N' ;
   l_access_rec.admin_flag  := 'N' ;


   IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message('Owner Resource Id : ' || l_ptr_prgm_rec.program_owner_resource_id);
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('p_identity_resource_id : ' || p_identity_resource_id);
   END IF;

  IF ( l_ptr_prgm_rec.program_owner_resource_id <>  p_identity_resource_id ) then


      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Adding Owner To the Team');
      END IF;
      l_access_rec.user_or_role_id := l_ptr_prgm_rec.program_owner_resource_id;
      l_access_rec.owner_flag := 'Y' ;

     AMS_Access_Pvt.Create_Access(
       p_api_version       => l_api_version_number,
       p_init_msg_list     => p_init_msg_list,
       p_commit            => p_commit,
       p_validation_level  => p_validation_level,

       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,

       p_access_rec        => l_access_rec,
       x_access_id         => l_dummy_id
     );

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Return Status From Access API after adding owner ' || x_return_status);
  END IF;
        IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message('Access ID From Access API after adding owner' || l_dummy_id);
  END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
     END IF;

       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Adding Creator To the Team');
       END IF;
      /*** Adding Creator to the Team ***/
      l_access_rec.user_or_role_id := p_identity_resource_id;
      l_access_rec.owner_flag := 'N' ;

      AMS_Access_Pvt.Create_Access(
       p_api_version       => l_api_version_number,
       p_init_msg_list     => p_init_msg_list,
       p_commit            => p_commit,
       p_validation_level  => p_validation_level,

       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,

       p_access_rec        => l_access_rec,
       x_access_id         => l_dummy_id
  );

     IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Return Status From Access API after adding creator ' || x_return_status);
  END IF;
        IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message('Access ID From Access API after adding creator ' || l_dummy_id);
  END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
     END IF;



  ELSE
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Adding Owner To the Team');
      END IF;
      l_access_rec.user_or_role_id := l_ptr_prgm_rec.program_owner_resource_id;
      l_access_rec.owner_flag := 'Y' ;

      AMS_Access_Pvt.Create_Access(
       p_api_version       => l_api_version_number,
       p_init_msg_list     => p_init_msg_list,
       p_commit            => p_commit,
       p_validation_level  => p_validation_level,

       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,

       p_access_rec        => l_access_rec,
       x_access_id         => l_dummy_id
      );


        IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Return Status From Access API after adding owner ' || x_return_status);
  END IF;
        IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message('Access ID From Access API after adding owner' || l_dummy_id);
  END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
     END IF;



  END IF;



     IF l_ptr_prgm_rec.program_start_date>=l_ptr_prgm_rec.program_end_date THEN
         FND_MESSAGE.set_name('PV', 'PV_END_DATE_SMALL_START_DATE');
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;


     IF l_ptr_prgm_rec.program_parent_id is not null THEN
        l_start_end_date_within_range:=isStartEndDateInRange(l_ptr_prgm_rec.program_parent_id,l_ptr_prgm_rec.program_start_date,l_ptr_prgm_rec.program_end_date);
        IF l_start_end_date_within_range=false THEN
            FND_MESSAGE.set_name('PV', 'PV_START_END_DATE_NOT_IN_RANGE');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF ;


     --check whether allow_enroll_untill_date is in between start and end dates
     IF l_ptr_prgm_rec.program_level_code='MEMBERSHIP'
        AND l_ptr_prgm_rec.allow_enrl_until_date is not null
        AND l_ptr_prgm_rec.allow_enrl_until_date<>FND_API.g_miss_date
        THEN
     	l_isNoEnrlDateInRange:=isNoEnrlDateInRange(  l_ptr_prgm_rec.allow_enrl_until_date
     	                                           ,l_ptr_prgm_rec.program_start_date
     	                                           ,l_ptr_prgm_rec.program_end_date
     	                                          );
     	IF l_isNoEnrlDateInRange=false THEN
           FND_MESSAGE.set_name('PV', 'PV_ENRL_DATE_NOT_INRANGE');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
     	END IF;

     END IF;
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: ' || l_full_name || ' -  Calling create table handler');
      END IF;

      -- Invoke table handler(PV_PARTNER_PROGRAM_PKG.Insert_Row)
      PV_PARTNER_PROGRAM_PKG.Insert_Row(
           px_program_id                => l_ptr_prgm_rec.program_id
          ,p_PROGRAM_TYPE_ID            => l_ptr_prgm_rec.PROGRAM_TYPE_ID
          ,p_custom_setup_id            => l_ptr_prgm_rec.custom_setup_id
          ,p_program_level_code         => l_ptr_prgm_rec.program_level_code
          ,p_program_parent_id          => l_ptr_prgm_rec.program_parent_id
          ,p_program_owner_resource_id  => l_ptr_prgm_rec.program_owner_resource_id
          ,p_program_start_date         => l_ptr_prgm_rec.program_start_date
          ,p_program_end_date           => l_ptr_prgm_rec.program_end_date
          ,p_allow_enrl_until_date      => l_ptr_prgm_rec.allow_enrl_until_date
          ,p_citem_version_id           => l_ptr_prgm_rec.citem_version_id
          ,p_membership_valid_period    => l_ptr_prgm_rec.membership_valid_period
          ,p_membership_period_unit     => l_ptr_prgm_rec.membership_period_unit
          ,p_process_rule_id            => l_ptr_prgm_rec.process_rule_id
          ,p_prereq_process_rule_Id     => l_ptr_prgm_rec.prereq_process_rule_Id
          ,p_program_status_code        => l_ptr_prgm_rec.program_status_code
          ,p_submit_child_nodes         => l_ptr_prgm_rec.submit_child_nodes
          ,p_inventory_item_id          => l_ptr_prgm_rec.inventory_item_id
          ,p_inventory_item_org_id      => l_ptr_prgm_rec.inventory_item_org_id
          ,p_bus_user_resp_id           => l_ptr_prgm_rec.bus_user_resp_id
          ,p_admin_resp_id              => l_ptr_prgm_rec.admin_resp_id
          ,p_no_fee_flag                => l_ptr_prgm_rec.no_fee_flag
          ,p_vad_invite_allow_flag      => l_ptr_prgm_rec.vad_invite_allow_flag
          ,p_global_mmbr_reqd_flag      => l_ptr_prgm_rec.global_mmbr_reqd_flag
          ,p_waive_subsidiary_fee_flag  => l_ptr_prgm_rec.waive_subsidiary_fee_flag
          ,p_qsnr_ttl_all_page_dsp_flag         => l_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag
          ,p_qsnr_hdr_all_page_dsp_flag         => l_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag
          ,p_qsnr_ftr_all_page_dsp_flag        => l_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag
          ,p_allow_enrl_wout_chklst_flag         => l_ptr_prgm_rec.allow_enrl_wout_chklst_flag
          ,p_user_status_id             => l_ptr_prgm_rec.user_status_id
          ,p_enabled_flag               => l_ptr_prgm_rec.enabled_flag
          ,p_attribute_category         => l_ptr_prgm_rec.attribute_category
          ,p_attribute1                 => l_ptr_prgm_rec.attribute1
          ,p_attribute2                 => l_ptr_prgm_rec.attribute2
          ,p_attribute3                 => l_ptr_prgm_rec.attribute3
          ,p_attribute4                 => l_ptr_prgm_rec.attribute4
          ,p_attribute5                 => l_ptr_prgm_rec.attribute5
          ,p_attribute6                 => l_ptr_prgm_rec.attribute6
          ,p_attribute7                 => l_ptr_prgm_rec.attribute7
          ,p_attribute8                 => l_ptr_prgm_rec.attribute8
          ,p_attribute9                 => l_ptr_prgm_rec.attribute9
          ,p_attribute10                => l_ptr_prgm_rec.attribute10
          ,p_attribute11                => l_ptr_prgm_rec.attribute11
          ,p_attribute12                => l_ptr_prgm_rec.attribute12
          ,p_attribute13                => l_ptr_prgm_rec.attribute13
          ,p_attribute14                => l_ptr_prgm_rec.attribute14
          ,p_attribute15                => l_ptr_prgm_rec.attribute15
          ,p_last_update_date           => l_ptr_prgm_rec.last_update_date
          ,p_last_updated_by            => l_ptr_prgm_rec.last_updated_by
          ,p_creation_date              => l_ptr_prgm_rec.creation_date
          ,p_created_by                 => l_ptr_prgm_rec.created_by
          ,p_last_update_login          => l_ptr_prgm_rec.last_update_login
          ,p_object_version_number      => l_object_version_number
          ,p_program_name               => l_ptr_prgm_rec.program_name
          ,p_program_description        => l_ptr_prgm_rec.program_description
          ,p_source_lang                => l_ptr_prgm_rec.source_lang
          ,p_qsnr_title                 => l_ptr_prgm_rec.qsnr_title
          ,p_qsnr_header                => l_ptr_prgm_rec.qsnr_header
          ,p_qsnr_footer                => l_ptr_prgm_rec.qsnr_footer
          );

          x_program_id := l_ptr_prgm_rec.program_id;

--         dbms_output.put_line('The program id created ' || x_program_id);
              -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('The program id created ' || x_program_id);
         END IF;


         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         --call notications rules api for member level programs

  IF l_ptr_prgm_rec.program_level_code='MEMBERSHIP' THEN
     PV_Ge_Notif_Rules_PVT.Create_Ge_Notif_Rules_Rec
    (
       p_api_version_number      => l_api_version_number
      ,p_init_msg_list     => p_init_msg_list
      ,p_commit            => p_commit
      ,p_validation_level  => p_validation_level
      ,x_return_status     => x_return_status
      ,x_msg_count         => x_msg_count
            ,x_msg_data          => x_msg_data
      ,p_programId         => x_program_id
          );
    IF x_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
          ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;

     END IF;


         -- added by sranka for Inventory Generation
         l_return_status := FND_API.G_RET_STS_SUCCESS;

     /* Modified for R12 */
     -- If the profile is not set or set to 'Y'
     IF (((FND_PROFILE.VALUE('PV_ENABLE_AUTO_CREATION_OF_INVENTORY_ITEM') is null) or (FND_PROFILE.VALUE('PV_ENABLE_AUTO_CREATION_OF_INVENTORY_ITEM') = 'Y')) and
         l_ptr_prgm_rec.no_fee_flag = 'N') THEN
        IF (PV_DEBUG_HIGH_ON) THEN
           PVX_UTILITY_PVT.debug_message('PV_AUTO_CREATION_OF_INVENTORY is not N');
        END IF;

        IF l_ptr_prgm_rec.program_level_code = 'MEMBERSHIP' THEN
            create_inventory_item(
                   p_ptr_prgm_rec       => l_ptr_prgm_rec,
                   x_Item_rec           => l_Item_rec,
                   x_return_status      => l_return_status,
                   x_Error_tbl          => l_error_tbl
             );
            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
           l_inventory_item_id := l_Item_rec.inventory_item_id;

           -- This is a local record of type, ptr_prgm_rec_type, define for the update of the inventory id for the newly created program
           l_ptr_prgm_rec.inventory_item_id := l_inventory_item_id;
           l_ptr_prgm_rec.inventory_item_org_id := l_Item_rec.organization_id;
         END IF;

      END IF;

        l_ptr_prgm_rec.object_version_number := l_object_version_number;


        IF (PV_DEBUG_HIGH_ON) THEN





        PVX_UTILITY_PVT.debug_message(' Calling Update_Partner_Program');


        END IF;

-- changes done by sranka 10/16/2002
-- Here making the membership_fees to 0, is the bussiness logic. We are creting the price line for every invetory item, but at the
--FIRST time we are harcoding the val TO the 0, but FROM the UI, using the Pricing fragemnt we can modify it.
        l_ptr_prgm_rec.membership_fees := 0;

--        create_pricelist_line(
--           p_ptr_prgm_rec           => l_ptr_prgm_rec,
--           p_inventory_item_id      => l_Item_rec.inventory_item_id,
--           p_operation              => QP_GLOBALS.G_OPR_CREATE,
--
--           -- The following two variables will be used in case of Update only
--           p_list_header_id         => l_list_line_id, -- l_list_header_id,
--           p_pricing_attribute_id   => l_pricing_attribute_id,
--
--
--           x_return_status          => l_return_status,
--           x_pricelist_line_id      => l_pricelist_line_id,
--
--           x_msg_count              => l_msg_count,
--           x_msg_data               => l_msg_data
--        );





--        IF l_return_status = FND_API.g_ret_sts_error THEN
--            OE_MSG_PUB.Count_And_Get (
--             p_encoded => FND_API.G_FALSE
--            ,p_count   => x_msg_count
--            ,p_data    => x_msg_data
--            );
--
--           RAISE FND_API.g_exc_error;
--        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
--           RAISE FND_API.g_exc_unexpected_error;
--        END IF;




        Update_Partner_Program(
         p_api_version_number         => 1.0
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
-- since we are updating the just created record, so we need not to validate it, so we are doing the validation level as NULL
        ,p_validation_level           => FND_API.G_VALID_LEVEL_NONE

        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_ptr_prgm_rec               => l_ptr_prgm_rec
        );

       -- dbms_output.put_line(' aftr Calling Update_Partner_Program');

        IF l_return_status = FND_API.g_ret_sts_error THEN
           RAISE FND_API.g_exc_error;
        ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
           RAISE FND_API.g_exc_unexpected_error;
        END IF;




          -- Debug Message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
        END IF;

          -- Standard check for p_commit
        IF FND_API.to_Boolean( p_commit ) THEN
            COMMIT WORK;
        END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_UTILITY_PVT.debug_message('In CREATE_PARTNER_PROGRAM API ERROR BLOCK');

     END IF;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

--       l_count := OE_MSG_PUB.count_msg;
--       FOR i IN 1 .. l_count LOOP
--          l_msg := OE_MSG_PUB.get(i, FND_API.g_false);
--          -- holiu: remove since adchkdrv does not like it
--          DBMS_OUTPUT.put_line('(' || i || ') ' || l_msg);
--          IF (PV_DEBUG_HIGH_ON) THEN                    PVX_UTILITY_PVT.debug_message('(' || i || ') ' || l_msg);          END IF;
--       END LOOP;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;

   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

End Create_Partner_Program;


PROCEDURE Update_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    )

 IS


CURSOR c_get_partner_program(cv_program_id NUMBER) IS
     SELECT *
     FROM  PV_PARTNER_PROGRAM_B
     WHERE PROGRAM_ID = cv_program_ID;

CURSOR c_get_child_programs(cv_program_id NUMBER) IS
SELECT program_id,object_version_number
     FROM pv_partner_program_b
     where program_id  not in ( cv_program_id)
     and enabled_flag='Y'
     start with program_id = cv_program_id
     CONNECT BY PRIOR program_id = program_parent_id;

CURSOR c_get_status_code(cv_status_code VARCHAR2) IS
SELECT user_status_id
     FROM AMS_USER_STATUSES_B
     where SYSTEM_STATUS_TYPE='PV_PROGRAM_STATUS'
     and SYSTEM_STATUS_CODE=cv_status_code;

l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Partner_Program';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;

-- Local Variables
l_ref_ptr_prgm_rec                   c_get_Partner_Program%ROWTYPE ;
l_tar_ptr_prgm_rec                   PV_PARTNER_PROGRAM_PVT.ptr_prgm_rec_type := p_ptr_prgm_rec;
l_tar_ptr_prgm_update_rec                   PV_PARTNER_PROGRAM_PVT.ptr_prgm_rec_type := p_ptr_prgm_rec;
l_enrollment_valid                   boolean :=false;
l_valid_approvers                    boolean :=false;
l_start_end_date_within_range        boolean :=false;
l_activatable                        boolean :=false;
l_is_parent_approved                 boolean:=false;
l_is_ProgramCancellable              boolean:=true;
l_isNoEnrlDateInRange                boolean:=true;
l_user_status_for_new                NUMBER;
l_user_status_for_approved           NUMBER;
l_user_status_for_rejected           NUMBER;
l_check_price_exists                 VARCHAR2(1);
l_check_inventory_item_exists        VARCHAR2(1);
l_check_membership_duration          VARCHAR2(1);
l_default_appr                       VARCHAR2(60);

BEGIN

      --  dbms_output.put_line(' in Update_Partner_Program');
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message(' in Update_Partner_Program');
        END IF;

     ---------Initialize ------------------
      get_program_status_code(l_tar_ptr_prgm_rec.user_status_id,l_tar_ptr_prgm_rec.program_status_code,x_return_status);

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Partner_Program_PVT;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Open Cursor to Select');
      END IF;

      OPEN c_get_Partner_Program( l_tar_ptr_prgm_rec.program_id);
      FETCH c_get_Partner_Program INTO l_ref_ptr_prgm_rec  ;

      IF ( c_get_Partner_Program%NOTFOUND) THEN
       FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
       FND_MESSAGE.set_token('MODE','Update');
       FND_MESSAGE.set_token('ENTITY','Partner_Program');
       FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_ptr_prgm_rec.program_id));
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('Private API: '|| l_full_name || ' - Close Cursor');
     END IF;
     CLOSE     c_get_Partner_Program;

     IF (l_tar_ptr_prgm_rec.object_version_number IS NULL OR
          l_tar_ptr_prgm_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_ptr_prgm_rec.object_version_number <> l_ref_ptr_prgm_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','Partner_Program');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: '||l_full_name||' - Validate_Partner_Program');
          END IF;


          -- Invoke validation procedures
          Validate_partner_program(
             p_api_version_number       => 1.0
            ,p_init_msg_list        => FND_API.G_FALSE
            ,p_validation_level     => p_validation_level
            ,p_validation_mode      => JTF_PLSQL_API.g_update
            ,p_ptr_prgm_rec             => p_ptr_prgm_rec
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            );
      END IF;

     IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
     ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;


    IF (l_tar_ptr_prgm_rec.program_owner_resource_id  <> FND_API.g_miss_NUM
       AND l_ref_ptr_prgm_rec.program_owner_resource_id <> l_tar_ptr_prgm_rec.program_owner_resource_id  ) THEN
       AMS_Access_PVT.update_object_owner
       (   p_api_version        => 1.0
          ,p_init_msg_list      => FND_API.G_FALSE
          ,p_commit             => FND_API.G_FALSE
          ,p_validation_level   => p_validation_level
          ,x_return_status      => x_return_status
          ,x_msg_count          => x_msg_count
          ,x_msg_data           => x_msg_data
          ,p_object_type        => 'PRGM'
          ,p_object_id          => l_tar_ptr_prgm_rec.program_id
          ,p_resource_id        => l_tar_ptr_prgm_rec.program_owner_resource_id
          ,p_old_resource_id    => l_ref_ptr_prgm_rec.program_owner_resource_id
      );
        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


     -- replace g_miss_char/num/date with current column values
     Complete_Rec(
              p_ptr_prgm_rec => p_ptr_prgm_rec
             ,x_complete_rec =>l_tar_ptr_prgm_rec
             );
   get_program_status_code(l_tar_ptr_prgm_rec.user_status_id,l_tar_ptr_prgm_rec.program_status_code,x_return_status);

    IF l_tar_ptr_prgm_rec.program_start_date>=l_tar_ptr_prgm_rec.program_end_date THEN
      FND_MESSAGE.set_name('PV', 'PV_END_DATE_SMALL_START_DATE');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (l_tar_ptr_prgm_rec.program_parent_id is not null) and (l_tar_ptr_prgm_rec.program_parent_id <> FND_API.g_miss_num) THEN
        l_start_end_date_within_range:=isStartEndDateInRange(l_tar_ptr_prgm_rec.program_parent_id,l_tar_ptr_prgm_rec.program_start_date,l_tar_ptr_prgm_rec.program_end_date);
        IF l_start_end_date_within_range=false THEN
            FND_MESSAGE.set_name('PV', 'PV_START_END_DATE_NOT_IN_RANGE');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF ;

     IF (l_tar_ptr_prgm_rec.program_parent_id is not null) and (l_tar_ptr_prgm_rec.program_parent_id <> FND_API.g_miss_num) and (l_tar_ptr_prgm_rec.program_status_code='ACTIVE') THEN
        l_activatable:=isChildActivatable(l_tar_ptr_prgm_rec.program_parent_id);
        IF l_activatable=false THEN
           FND_MESSAGE.set_name('PV', 'PV_PARENT_NOT_ACTIVATED');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;


     -- check whether inventory item and price are defined for this membership upon activation
     IF ( l_tar_ptr_prgm_rec.program_status_code='PENDING_APPROVAL' and
          l_tar_ptr_prgm_rec.program_level_code='MEMBERSHIP' and
          l_tar_ptr_prgm_rec.no_fee_flag='N'
        ) THEN

        l_check_inventory_item_exists:=check_inventory_item_exists(l_tar_ptr_prgm_rec.program_id);
        IF ( l_check_inventory_item_exists='N' ) THEN
            FND_MESSAGE.set_name('PV', 'PV_PRGM_INV_ITEM_UNDEFIND');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- check whether price is defined for this membership
        l_check_price_exists:=check_price_exists(l_tar_ptr_prgm_rec.program_id);

        IF ( l_check_price_exists='N' ) THEN
            FND_MESSAGE.set_name('PV', 'PV_PRGM_PRICE_UNDEFINED_SUBMIT');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     -- check whether inventory item and price are defined for this membership upon activation
     IF ( l_tar_ptr_prgm_rec.program_status_code='ACTIVE' and
          l_tar_ptr_prgm_rec.program_level_code='MEMBERSHIP' and
          l_tar_ptr_prgm_rec.no_fee_flag='N'
        ) THEN

        l_check_inventory_item_exists:=check_inventory_item_exists(l_tar_ptr_prgm_rec.program_id);
        IF ( l_check_inventory_item_exists='N' ) THEN
            FND_MESSAGE.set_name('PV', 'PV_PRGM_INV_ITEM_UNDEFIND');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        l_check_price_exists:=check_price_exists(l_tar_ptr_prgm_rec.program_id);

        IF ( l_check_price_exists='N' ) THEN
            FND_MESSAGE.set_name('PV', 'PV_PRGM_PRICE_UNDEFINED_ACTIVE');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
     END IF;

     --check whether durataon is defined. this should be checke When program status is change to Active or pending approval only
     --its becuase a child program can be submitted for approval when parent submits.
     IF ( (l_tar_ptr_prgm_rec.program_status_code='ACTIVE'
           OR  l_tar_ptr_prgm_rec.program_status_code='PENDING_APPROVAL') and
          l_tar_ptr_prgm_rec.program_level_code='MEMBERSHIP' and
          (l_tar_ptr_prgm_rec.membership_period_unit is  null or l_tar_ptr_prgm_rec.membership_period_unit =FND_API.g_miss_char or
          l_tar_ptr_prgm_rec.membership_valid_period is null or l_tar_ptr_prgm_rec.membership_valid_period =FND_API.g_miss_num
          )

        ) THEN

        --l_check_membership_duration:=check_membership_duration(l_tar_ptr_prgm_rec.program_id);
  --IF ( l_check_membership_duration='N' ) THEN
            FND_MESSAGE.set_name('PV', 'PV_PRGM_NO_DURATION');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
       -- END IF;

     END IF;


     l_default_appr:=FND_PROFILE.VALUE('PV_ENRQ_DEFAULT_APPR');
     IF (  l_tar_ptr_prgm_rec.program_status_code='ACTIVE' and
           l_tar_ptr_prgm_rec.program_level_code='MEMBERSHIP' and
           l_default_appr is NULL ) THEN

            FND_MESSAGE.set_name('PV', 'PV_ENRQ_DEFAULT_APPR_NOT_SET');
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;

     END IF;

     --check whether allow_enroll_untill_date is in between start and end dates
     IF l_tar_ptr_prgm_rec.program_level_code='MEMBERSHIP'
        AND l_tar_ptr_prgm_rec.allow_enrl_until_date is not null
        AND l_tar_ptr_prgm_rec.allow_enrl_until_date<>FND_API.g_miss_date
        THEN
     	l_isNoEnrlDateInRange:=isNoEnrlDateInRange(  l_tar_ptr_prgm_rec.allow_enrl_until_date
     	                                           ,l_tar_ptr_prgm_rec.program_start_date
     	                                           ,l_tar_ptr_prgm_rec.program_end_date
     	                                          );
     	IF l_isNoEnrlDateInRange=false THEN
           FND_MESSAGE.set_name('PV', 'PV_ENRL_DATE_NOT_INRANGE');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
     	END IF;

     END IF;

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update table handler');
     END IF;

     -- Invoke table handler(PV_PARTNER_PROGRAM_PKG.Update_Row)
     PV_PARTNER_PROGRAM_PKG.Update_Row(
           p_program_id                 => l_tar_ptr_prgm_rec.program_id
          ,p_PROGRAM_TYPE_ID            => l_tar_ptr_prgm_rec.PROGRAM_TYPE_ID
          ,p_custom_setup_id            => l_tar_ptr_prgm_rec.custom_setup_id
          ,p_program_level_code         => l_tar_ptr_prgm_rec.program_level_code
          ,p_program_parent_id          => l_tar_ptr_prgm_rec.program_parent_id
          ,p_program_owner_resource_id  => l_tar_ptr_prgm_rec.program_owner_resource_id
          ,p_program_start_date         => l_tar_ptr_prgm_rec.program_start_date
          ,p_program_end_date           => l_tar_ptr_prgm_rec.program_end_date
           ,p_allow_enrl_until_date      => l_tar_ptr_prgm_rec.allow_enrl_until_date
           ,p_citem_version_id           => l_tar_ptr_prgm_rec.citem_version_id
          ,p_membership_valid_period    => l_tar_ptr_prgm_rec.membership_valid_period
          ,p_membership_period_unit     => l_tar_ptr_prgm_rec.membership_period_unit
          ,p_process_rule_id            => l_tar_ptr_prgm_rec.process_rule_id
          ,p_prereq_process_rule_Id     => l_tar_ptr_prgm_rec.prereq_process_rule_Id
          ,p_program_status_code        => l_tar_ptr_prgm_rec.program_status_code
          ,p_submit_child_nodes         => l_tar_ptr_prgm_rec.submit_child_nodes
          ,p_inventory_item_id          => l_tar_ptr_prgm_rec.inventory_item_id
          ,p_inventory_item_org_id      => l_tar_ptr_prgm_rec.inventory_item_org_id
          ,p_bus_user_resp_id           => l_tar_ptr_prgm_rec.bus_user_resp_id
          ,p_admin_resp_id              => l_tar_ptr_prgm_rec.admin_resp_id
          ,p_no_fee_flag                => l_tar_ptr_prgm_rec.no_fee_flag
          ,p_vad_invite_allow_flag      => l_tar_ptr_prgm_rec.vad_invite_allow_flag
          ,p_global_mmbr_reqd_flag      => l_tar_ptr_prgm_rec.global_mmbr_reqd_flag
          ,p_waive_subsidiary_fee_flag  => l_tar_ptr_prgm_rec.waive_subsidiary_fee_flag
          ,p_qsnr_ttl_all_page_dsp_flag         => l_tar_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag
          ,p_qsnr_hdr_all_page_dsp_flag        => l_tar_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag
          ,p_qsnr_ftr_all_page_dsp_flag        => l_tar_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag
          ,p_allow_enrl_wout_chklst_flag       => l_tar_ptr_prgm_rec.allow_enrl_wout_chklst_flag
          ,p_user_status_id             => l_tar_ptr_prgm_rec.user_status_id
          ,p_enabled_flag               => l_tar_ptr_prgm_rec.enabled_flag
          ,p_attribute_category         => l_tar_ptr_prgm_rec.attribute_category
          ,p_attribute1                 => l_tar_ptr_prgm_rec.attribute1
          ,p_attribute2                 => l_tar_ptr_prgm_rec.attribute2
          ,p_attribute3                 => l_tar_ptr_prgm_rec.attribute3
          ,p_attribute4                 => l_tar_ptr_prgm_rec.attribute4
          ,p_attribute5                 => l_tar_ptr_prgm_rec.attribute5
          ,p_attribute6                 => l_tar_ptr_prgm_rec.attribute6
          ,p_attribute7                 => l_tar_ptr_prgm_rec.attribute7
          ,p_attribute8                 => l_tar_ptr_prgm_rec.attribute8
          ,p_attribute9                 => l_tar_ptr_prgm_rec.attribute9
          ,p_attribute10                => l_tar_ptr_prgm_rec.attribute10
          ,p_attribute11                => l_tar_ptr_prgm_rec.attribute11
          ,p_attribute12                => l_tar_ptr_prgm_rec.attribute12
          ,p_attribute13                => l_tar_ptr_prgm_rec.attribute13
          ,p_attribute14                => l_tar_ptr_prgm_rec.attribute14
          ,p_attribute15                => l_tar_ptr_prgm_rec.attribute15
          ,p_last_update_date           => SYSDATE
          ,p_last_updated_by            => FND_GLOBAL.USER_ID
          ,p_last_update_login          => FND_GLOBAL.CONC_LOGIN_ID
          ,p_object_version_number      => l_tar_ptr_prgm_rec.object_version_number
          ,p_program_name               => l_tar_ptr_prgm_rec.program_name
          ,p_program_description        => l_tar_ptr_prgm_rec.program_description
          ,p_qsnr_title                 => l_tar_ptr_prgm_rec.qsnr_title
          ,p_qsnr_header                => l_tar_ptr_prgm_rec.qsnr_header
          ,p_qsnr_footer                => l_tar_ptr_prgm_rec.qsnr_footer
          );
         l_inventory_item_id := l_tar_ptr_prgm_rec.inventory_item_id;






--         checkPriceLineExits(p_inventory_item_id => l_inventory_item_id ,
--                          isAvailable => l_isAvailable,
--                          x_list_header_id => l_list_header_id,
--                          x_list_line_id => l_list_line_id,
--                          x_pricing_attribute_id => l_pricing_attribute_id);







     IF l_tar_ptr_prgm_rec.program_status_code in ('CANCEL' ,'CLOSED') THEN
          l_is_ProgramCancellable:=isProgramCancellable(l_tar_ptr_prgm_rec.program_id);
          IF l_is_ProgramCancellable=false THEN
                FND_MESSAGE.set_name('PV', 'PV_CHILD_NOT_CANCLD_OR_CLSED');
                FND_MSG_PUB.add;
                RAISE FND_API.G_EXC_ERROR;
          END IF;

     END IF;
     IF l_tar_ptr_prgm_rec.program_status_code='PENDING_APPROVAL' THEN

       IF l_tar_ptr_prgm_rec.submit_child_nodes='Y' THEN
                   for c_rec in c_get_child_programs(l_tar_ptr_prgm_rec.program_id) loop
                        update pv_partner_program_b set submit_child_nodes='Y',object_version_number=c_rec.object_version_number+1 where program_id=c_rec.program_id;
                   end loop;
         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN

         PVX_UTILITY_PVT.debug_message('Private: ' || l_api_name || 'Inside if when status is moved to planned');
         END IF;
         IF (l_tar_ptr_prgm_rec.program_parent_id is not null) and (l_tar_ptr_prgm_rec.program_parent_id <> FND_API.g_miss_num) THEN
              l_is_parent_approved:=isParentApproved(l_tar_ptr_prgm_rec.program_parent_id);
              IF  l_is_parent_approved=false THEN
                   FND_MESSAGE.set_name('PV', 'PV_PARENT_NOT_APPROVED');
                   FND_MSG_PUB.add;
                   RAISE FND_API.G_EXC_ERROR;
              END IF;
              -- to flag that the child programs need to be submitted for approval


         END IF;
         l_valid_approvers:=isApproverExists(l_tar_ptr_prgm_rec.PROGRAM_TYPE_ID);
         IF l_valid_approvers=true THEN
              IF (PV_DEBUG_HIGH_ON) THEN

              PVX_UTILITY_PVT.debug_message('Private: ' || l_api_name || 'Just before calling start process');
              END IF;
              open c_get_status_code('NEW');
              fetch c_get_status_code into l_user_status_for_new;
              IF ( c_get_status_code%NOTFOUND) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              close c_get_status_code;
              open c_get_status_code('APPROVED');
              fetch c_get_status_code into l_user_status_for_approved;
              IF ( c_get_status_code%NOTFOUND) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              close c_get_status_code;
              open c_get_status_code('REJECTED');
              fetch c_get_status_code into l_user_status_for_rejected;
              IF ( c_get_status_code%NOTFOUND) THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
              close c_get_status_code;
              ams_gen_approval_pvt.StartProcess(   p_activity_type =>'PRGT'
                                             ,p_activity_id=>l_tar_ptr_prgm_rec.program_id
                                             ,p_approval_type=>'CONCEPT'
                                             ,p_object_version_number=>l_tar_ptr_prgm_rec.object_version_number
                                             ,p_orig_stat_id=>l_user_status_for_new
                                             ,p_new_stat_id=>l_user_status_for_approved
                                             ,p_reject_stat_id=>l_user_status_for_rejected
                                             ,p_requester_userid=>l_tar_ptr_prgm_rec.program_owner_resource_id
                                             ,p_notes_from_requester=>null
                                             ,p_workflowprocess=>'AMSGAPP'
                                             ,p_item_type=>'AMSGAPP'
                                           );

         ELSE
              FND_MESSAGE.set_name('PV', 'PV_APPROVER_NOT_AVAILABLE');
              FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
         END IF;
     END IF;
     /**IF l_tar_ptr_prgm_rec.program_status_code not in('CANCEL','CLOSED','ARCHIVE') THEN
          l_enrollment_valid :=isEnrollApproverValid(l_tar_ptr_prgm_rec.program_id,l_tar_ptr_prgm_rec.program_end_date);
          IF l_enrollment_valid=false THEN
                 FND_MESSAGE.set_name('PV', 'PV_ENROLLER_NOT_VALID');
                 FND_MSG_PUB.add;

          END IF;
    END IF;
    */
     -- Check for commit
     IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
     END IF;


    FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

END Update_Partner_Program;



PROCEDURE Delete_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_program_id                 IN   NUMBER
    ,p_object_version_number      IN   NUMBER
    )

 IS

 CURSOR c_get_partner_program_rec(cv_program_id NUMBER) IS
    SELECT *
    FROM  PV_PARTNER_PROGRAM_B
    WHERE PROGRAM_ID = cv_program_id;

l_api_name                  CONSTANT VARCHAR2(30) := 'Delete_Partner_Program';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;

l_tar_ptr_prgm_rec                   PV_Partner_Program_PVT.ptr_prgm_rec_type;
l_ref_ptr_prgm_rec                   c_get_partner_program_rec%ROWTYPE;
l_program_id                         NUMBER;
l_return_status                      VARCHAR2(1);
l_msg_count                          NUMBER;
l_msg_data                           VARCHAR2(2000);
l_object_version_number              NUMBER;
l_index                              NUMBER;
l_is_deletable                       boolean:=true;
BEGIN
     ---------Initialize ------------------

      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Partner_Program_PVT;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - checking for object_version_number = ' || p_object_version_number);
     END IF;
     IF (p_object_version_number is NULL or
          p_object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- set values in record
      l_tar_ptr_prgm_rec.program_id             := p_program_id;
      l_tar_ptr_prgm_rec.enabled_flag           := 'N';
      l_tar_ptr_prgm_rec.object_version_number  := p_object_version_number;

      -- get record to be soft-deleted
      OPEN c_get_partner_program_rec(p_program_id);
      FETCH c_get_partner_program_rec INTO l_ref_ptr_prgm_rec  ;

      IF ( c_get_partner_program_rec%NOTFOUND) THEN
       FND_MESSAGE.set_name('PV', 'PV_API_MISSING_ENTITY');
       FND_MESSAGE.set_token('MODE','Update');
       FND_MESSAGE.set_token('ENTITY','Partner_Program');
       FND_MESSAGE.set_token('ID',TO_CHAR(l_tar_ptr_prgm_rec.program_id));
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('Private API: '|| l_full_name || ' - Close Cursor');
     END IF;
     CLOSE     c_get_partner_program_rec;

     IF (l_tar_ptr_prgm_rec.object_version_number is NULL or
          l_tar_ptr_prgm_rec.object_version_number = FND_API.G_MISS_NUM ) THEN

           FND_MESSAGE.set_name('PV', 'PV_API_VERSION_MISSING');
           FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
           FND_MSG_PUB.add;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_ptr_prgm_rec.object_version_number <> l_ref_ptr_prgm_rec.object_version_number) THEN
           FND_MESSAGE.set_name('PV', 'PV_API_RECORD_CHANGED');
           FND_MESSAGE.set_token('VALUE','Partner_Program');
           FND_MSG_PUB.add;
          raise FND_API.G_EXC_ERROR;
      End if;
     --Check whether the status is PENDING_APPROVAL. if so delete should not be allowed by raising exception
      If (l_ref_ptr_prgm_rec.program_status_code='PENDING_APPROVAL') THEN
           FND_MESSAGE.set_name('PV', 'PV_PENDING_APPROVAL');
           FND_MSG_PUB.add;
           raise FND_API.G_EXC_ERROR;
      End if;
      l_is_deletable :=isProgramDeletable(l_tar_ptr_prgm_rec.program_id);
      if ( l_is_deletable  =false) THEN
           FND_MESSAGE.set_name('PV', 'PV_CHILD_PROGRAM');
           FND_MSG_PUB.add;
           raise FND_API.G_EXC_ERROR;
      End if;

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - Calling update for soft delete');
     END IF;

     -- Invoke table handler(PV_PARTNER_PROGRAM_PKG.Delete_Row)
       PV_PARTNER_PROGRAM_PKG.Delete_Row(
           p_program_id              => l_tar_ptr_prgm_rec.program_id
          ,p_object_version_number   => l_tar_ptr_prgm_rec.object_version_number
          );

     -- Check for commit
     IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
     END IF;

    FND_MSG_PUB.count_and_get(
       p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );
End Delete_Partner_Program;




PROCEDURE Lock_Partner_Program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE

    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2

    ,px_program_id                IN  NUMBER
    ,p_object_version             IN  NUMBER
    )

 IS
l_api_name                  CONSTANT VARCHAR2(30) := 'Lock_Partner_Program';
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_program_id                         NUMBER;

CURSOR c_Partner_Program IS
   SELECT PROGRAM_ID
   FROM PV_PARTNER_PROGRAM_B
   WHERE PROGRAM_ID = px_program_id
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
               l_api_version_number
              ,p_api_version_number
              ,l_api_name
              ,G_PKG_NAME
              )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
  OPEN c_Partner_Program;

  FETCH c_Partner_Program INTO l_PROGRAM_ID;

  IF (c_Partner_Program%NOTFOUND) THEN
    CLOSE c_Partner_Program;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('PV', 'PV_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Partner_Program;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data
    );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;

EXCEPTION
/*
   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 PVX_UTILITY_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Partner_Program_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );
End Lock_Partner_Program;



PROCEDURE Check_UK_Items(
     p_ptr_prgm_rec        IN  ptr_prgm_rec_type
    ,p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status       OUT NOCOPY VARCHAR2
    )

IS

l_valid_flag  VARCHAR2(1);

BEGIN

      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN

         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PARTNER_PROGRAM_B',
         'PROGRAM_ID = ''' || p_ptr_prgm_rec.PROGRAM_ID ||''''
         );

        IF l_valid_flag = FND_API.g_false THEN
          FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
          FND_MESSAGE.set_token('ID',to_char(p_ptr_prgm_rec.PROGRAM_ID) );
          FND_MESSAGE.set_token('ENTITY','Partner_Program');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;
      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API Before Process_Rule_ID check' );
      END IF;


         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PARTNER_PROGRAM_B',
         'PROCESS_RULE_ID = ''' || p_ptr_prgm_rec.PROCESS_RULE_ID ||''''
         );

        IF l_valid_flag = FND_API.g_false THEN
          FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
          FND_MESSAGE.set_token('ID',to_char(p_ptr_prgm_rec.PROCESS_RULE_ID) );
          FND_MESSAGE.set_token('ENTITY','Partner_Program');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;

        -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_UK_Items API Before prereq_process_rule_Id check' );
      END IF;

      l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'PV_PARTNER_PROGRAM_B',
         'PREREQ_PROCESS_RULE_ID = ''' || p_ptr_prgm_rec.PREREQ_PROCESS_RULE_ID ||''''
         );

        IF l_valid_flag = FND_API.g_false THEN
          FND_MESSAGE.set_name('PV', 'PV_API_DUPLICATE_ENTITY');
          FND_MESSAGE.set_token('ID',to_char(p_ptr_prgm_rec.PREREQ_PROCESS_RULE_ID) );
          FND_MESSAGE.set_token('ENTITY','Partner_Program');
          FND_MSG_PUB.add;
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
        END IF;



      END IF;

END Check_UK_Items;



PROCEDURE Check_Req_Items(
     p_ptr_prgm_rec       IN  ptr_prgm_rec_type
    ,p_validation_mode    IN  VARCHAR2 := JTF_PLSQL_API.g_create
    ,x_return_status      OUT NOCOPY VARCHAR2
    )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_ptr_prgm_rec.program_id = FND_API.g_miss_num
        OR p_ptr_prgm_rec.program_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.PROGRAM_TYPE_ID = FND_API.g_miss_num
       OR p_ptr_prgm_rec.PROGRAM_TYPE_ID IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_TYPE_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.custom_setup_id = FND_API.g_miss_num
       OR p_ptr_prgm_rec.custom_setup_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CUSTOM_SETUP_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.program_level_code = FND_API.g_miss_char
       OR p_ptr_prgm_rec.program_level_code IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_LEVEL_CODE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.program_owner_resource_id = FND_API.g_miss_num
       OR p_ptr_prgm_rec.program_owner_resource_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_OWNER_RESOURCE_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.program_start_date = FND_API.g_miss_date
       OR p_ptr_prgm_rec.program_start_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_START_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_Req_Items API Before End Date Check' );
      END IF;


      IF p_ptr_prgm_rec.program_end_date = FND_API.g_miss_date
       OR p_ptr_prgm_rec.program_end_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_END_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.process_rule_id = FND_API.g_miss_num
       OR p_ptr_prgm_rec.process_rule_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROCESS_RULE_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.program_status_code = FND_API.g_miss_char
       OR p_ptr_prgm_rec.program_status_code IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_STATUS_CODE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ptr_prgm_rec.submit_child_nodes = FND_API.g_miss_char
       OR p_ptr_prgm_rec.submit_child_nodes IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','SUBMIT_CHILD_NODES');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

/*
      IF p_ptr_prgm_rec.bus_user_resp_id = FND_API.g_miss_num
       OR p_ptr_prgm_rec.bus_user_resp_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','BUS_USER_RESP_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ptr_prgm_rec.admin_resp_id = FND_API.g_miss_num
       OR p_ptr_prgm_rec.admin_resp_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','ADMIN_RESP_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
*/
      IF p_ptr_prgm_rec.no_fee_flag = FND_API.g_miss_char
       OR p_ptr_prgm_rec.no_fee_flag IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','NO_FEE_FLAG');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ptr_prgm_rec.user_status_id = FND_API.g_miss_num
       OR p_ptr_prgm_rec.user_status_id IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','USER_STATUS_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      IF p_ptr_prgm_rec.enabled_flag = FND_API.g_miss_char
       OR p_ptr_prgm_rec.enabled_flag IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','ENABLED_FLAG');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.object_version_number = FND_API.g_miss_num
       OR p_ptr_prgm_rec.object_version_number IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.creation_date = FND_API.g_miss_date
       OR p_ptr_prgm_rec.creation_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATION_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

      -- Debug message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('- In Check_Req_Items API Before Created_by Check' );
      END IF;


      IF p_ptr_prgm_rec.created_by = FND_API.g_miss_num
       OR p_ptr_prgm_rec.created_by IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','CREATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.last_update_login = FND_API.g_miss_num
       OR p_ptr_prgm_rec.last_update_login IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_LOGIN');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.last_update_date = FND_API.g_miss_date
       OR p_ptr_prgm_rec.last_update_date IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATE_DATE');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.last_updated_by = FND_API.g_miss_num
       OR p_ptr_prgm_rec.last_updated_by IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','LAST_UPDATED_BY');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


       IF p_ptr_prgm_rec.program_name = FND_API.g_miss_char
       OR p_ptr_prgm_rec.program_name IS NULL THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN','PROGRAM_NAME');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE

      IF p_ptr_prgm_rec.program_id IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','PROGRAM_ID');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_ptr_prgm_rec.object_version_number IS NULL THEN
         Fnd_Message.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         Fnd_Message.set_token('COLUMN','OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.add;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END Check_Req_Items;



PROCEDURE Check_FK_Items(
     p_ptr_prgm_rec     IN  ptr_prgm_rec_type
    ,x_return_status    OUT NOCOPY VARCHAR2
    )

IS

   CURSOR c_resource_exists IS
      SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1
      FROM JTF_RS_RESOURCE_EXTNS
      WHERE RESOURCE_ID = p_ptr_prgm_rec.program_owner_resource_id
      AND NVL(end_date_active,SYSDATE) >= SYSDATE AND NVL(start_date_active, SYSDATE) <= SYSDATE);

   l_process_type VARCHAR2(4000) := 'PARTNER_PROGRAM';
   CURSOR c_pr_exists IS
      SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1
      FROM pv_process_rules_vl pvprv
      WHERE PROCESS_RULE_ID =  p_ptr_prgm_rec.process_rule_id
      AND  NVL(start_date,SYSDATE) <= SYSDATE and  NVL(end_date,SYSDATE) >= SYSDATE AND PROCESS_TYPE = l_process_type);

   CURSOR c_pr_exists_1 IS
      SELECT 1 FROM DUAL WHERE EXISTS (SELECT 1
      FROM pv_process_rules_vl pvprv
      WHERE PROCESS_RULE_ID =  p_ptr_prgm_rec.prereq_process_rule_id
      AND  NVL(start_date,SYSDATE) <= SYSDATE and  NVL(end_date,SYSDATE) >= SYSDATE AND PROCESS_TYPE = l_process_type);

   l_resource_exists NUMBER := NULL;
   l_resource_exists_flag VARCHAR2(4000);
   l_pr_exists NUMBER := NULL;
   l_pr_exists_flag VARCHAR2(4000);
   l_pr_exists_1 NUMBER := NULL;
   l_pr_exists_flag_1 VARCHAR2(4000);

BEGIN


      ----------------------- PROGRAM_OWNER_RESOURCE_ID ------------------------
 IF (p_ptr_prgm_rec.program_owner_resource_id <> FND_API.g_miss_num and
     p_ptr_prgm_rec.program_owner_resource_id IS NOT NULL )
   THEN
   OPEN c_resource_exists;
   FETCH c_resource_exists INTO l_resource_exists;
   IF c_resource_exists%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_OWNER');
         FND_MSG_PUB.add;
      END IF;
      CLOSE c_resource_exists;
      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
   CLOSE c_resource_exists;

 END IF;


        ----------------------- PROCESS_RULE_ID ------------------------
 IF (p_ptr_prgm_rec.process_rule_id <> FND_API.g_miss_num and
     p_ptr_prgm_rec.process_rule_id IS NOT NULL ) THEN

   OPEN c_pr_exists;
   FETCH c_pr_exists INTO l_pr_exists;
   IF c_pr_exists%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PROCESS_RULE');
         FND_MSG_PUB.add;
      END IF;
    CLOSE c_pr_exists;
    RETURN;
   END IF;
   CLOSE c_pr_exists;
 END IF;





    ----------------------- PREREQ_PROCESS_RULE_ID ------------------------
 IF (p_ptr_prgm_rec.prereq_process_rule_id <> FND_API.g_miss_num and
     p_ptr_prgm_rec.prereq_process_rule_id IS NOT NULL ) THEN

   OPEN c_pr_exists_1;
   FETCH c_pr_exists_1 INTO l_pr_exists_1;
   IF c_pr_exists_1%NOTFOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PROCESS_RULE');
         FND_MSG_PUB.add;
      END IF;
    CLOSE c_pr_exists_1;
    RETURN;
   END IF;
   CLOSE c_pr_exists_1;
 END IF;



   x_return_status := FND_API.g_ret_sts_success;

 ----------------------- PROGRAM_TYPE_ID ------------------------
 IF (p_ptr_prgm_rec.PROGRAM_TYPE_ID <> FND_API.g_miss_num and
     p_ptr_prgm_rec.PROGRAM_TYPE_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items before PROGRAM_TYPE_ID check : PROGRAM_TYPE_ID = ' || p_ptr_prgm_rec.PROGRAM_TYPE_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'PV_PARTNER_PROGRAM_TYPE_B',                           -- Parent schema object having the primary key
         'PROGRAM_TYPE_ID',                               -- Column name in the parent object that maps to the fk value
         p_ptr_prgm_rec.PROGRAM_TYPE_ID,                  -- Value of fk to be validated against the parent object's pk column
         PVX_utility_PVT.g_number,                              -- datatype of fk
         ' ENABLED_FLAG = ''Y''' || ' AND ACTIVE_FLAG = ''Y'''
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PTR_PRGM_TYPE');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

  -- Debug message
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message('- In Check_FK_Items after PROGRAM_TYPE_ID FK check ');
  END IF;


   ----------------------- CUSTOM_SETUP_ID ------------------------
 IF (p_ptr_prgm_rec.CUSTOM_SETUP_ID <> FND_API.g_miss_num and
     p_ptr_prgm_rec.CUSTOM_SETUP_ID IS NOT NULL ) THEN

 -- Debug message
 IF (PV_DEBUG_HIGH_ON) THEN

 PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : Before CUSTOM_SETUP_ID fk check : CUSTOM_SETUP_ID = ' || p_ptr_prgm_rec.CUSTOM_SETUP_ID);
 END IF;

   IF PVX_Utility_PVT.check_fk_exists(
         'AMS_CUSTOM_SETUPS_VL',               -- Parent schema object having the primary key
         'CUSTOM_SETUP_ID',                    -- Column name in the parent object that maps to the fk value
         p_ptr_prgm_rec.custom_setup_id,       -- Value of fk to be validated against the parent object's pk column
         PVX_utility_PVT.g_number,             -- datatype of fk
         ' ENABLED_FLAG = ''Y''' || ' AND OBJECT_TYPE = ''PRGM'''
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_CUSTOM_SETUP_ID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;

  -- Debug message
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message('- In Check_FK_Items : After CUSTOM_SETUP_ID fk check ');
  END IF;


    ----------------------- PROGRAM_PARENT_ID ------------------------
 IF (p_ptr_prgm_rec.PROGRAM_PARENT_ID <> FND_API.g_miss_num and
     p_ptr_prgm_rec.PROGRAM_PARENT_ID IS NOT NULL ) THEN


   IF PVX_Utility_PVT.check_fk_exists(
         'PV_PARTNER_PROGRAM_VL',                   -- Parent schema object having the primary key
         'PROGRAM_ID',                              -- Column name in the parent object that maps to the fk value
         p_ptr_prgm_rec.PROGRAM_PARENT_ID,       -- Value of fk to be validated against the parent object's pk column
         PVX_utility_PVT.g_number,                  -- datatype of fk
         ' ENABLED_FLAG = ''Y'''
   ) = FND_API.g_false
   THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
      THEN
         FND_MESSAGE.set_name('PV', 'PV_PARENT_PROGRAM_NOT_VALID');
         FND_MSG_PUB.add;
      END IF;

      x_return_status := FND_API.g_ret_sts_error;
      RETURN;
   END IF;
 END IF;



END Check_FK_Items;



PROCEDURE Check_Lookup_Items(
    p_ptr_prgm_rec   IN  ptr_prgm_rec_type
   ,x_return_status  OUT NOCOPY VARCHAR2
   )

IS

BEGIN

   x_return_status := FND_API.g_ret_sts_success;

     ----------------------- PROGRAM_LEVEL_CODE LOOKUP  ------------------------
   IF p_ptr_prgm_rec.program_level_code <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'PV_LOOKUPS',      -- Look up Table Name
            'PV_PROGRAM_LEVEL',    -- Lookup Type
            p_ptr_prgm_rec.program_level_code       -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PROGRAM_LEVEL');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

      END IF;
   END IF;
   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Check_Lookup_Items : After program_level_code lookup check. x_return_status = '||x_return_status);
   END IF;

      ----------------------- MEMBERSHIP_PERIOD_UNIT ------------------------
   IF p_ptr_prgm_rec.membership_period_unit <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'PV_LOOKUPS',      -- Look up Table Name
            'PV_PRGM_PMNT_UNIT',    -- Lookup Type
            p_ptr_prgm_rec.membership_period_unit       -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_INVALID_PROGRAM_MEMB_UNIT');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

   END IF;
END IF;

      ----------------------- program_status_code ------------------------
   IF p_ptr_prgm_rec.program_status_code <> FND_API.g_miss_char  THEN

      IF PVX_Utility_PVT.check_lookup_exists(
            'PV_LOOKUPS',      -- Look up Table Name
            'PV_PROGRAM_STATUS',    -- Lookup Type
            p_ptr_prgm_rec.program_status_code       -- Lookup Code
         ) = FND_API.g_false
      THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_A_VALID_PROGRAM_STATUS');
            FND_MSG_PUB.add;
         END IF;
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;

   END IF;
END IF;

END Check_Lookup_Items;



PROCEDURE Check_Items (
     p_ptr_prgm_rec         IN    ptr_prgm_rec_type
    ,p_validation_mode      IN    VARCHAR2
    ,x_return_status        OUT NOCOPY   VARCHAR2
    )

IS

 l_api_name    CONSTANT VARCHAR2(30) := 'Check_Items';
 l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Req_Items call');
   END IF;

   -- Check Items Required/NOT NULL API calls
   Check_Req_Items(
       p_ptr_prgm_rec           => p_ptr_prgm_rec
      ,p_validation_mode    => p_validation_mode
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_Req_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_UK_Items call');
   END IF;

    -- Check Items Uniqueness API calls
   Check_UK_Items(
       p_ptr_prgm_rec           => p_ptr_prgm_rec
      ,p_validation_mode    => p_validation_mode
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_UK_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_FK_Items call');
   END IF;

   -- Check Items Foreign Keys API calls
   Check_FK_Items(
       p_ptr_prgm_rec     => p_ptr_prgm_rec
      ,x_return_status    => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_FK_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- Check_Items API prior to Check_Lookup_Items call');
   END IF;

   -- Check Items Lookups
   Check_Lookup_Items(
       p_ptr_prgm_rec       => p_ptr_prgm_rec
      ,x_return_status      => x_return_status
      );

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- After Check_Lookup_Items. return status = ' || x_return_status);
   END IF;

   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_Items;



PROCEDURE Complete_Rec (
    p_ptr_prgm_rec   IN   ptr_prgm_rec_type
   ,x_complete_rec   OUT NOCOPY  ptr_prgm_rec_type
   )

IS

   CURSOR c_complete IS
      SELECT *
      FROM PV_PARTNER_PROGRAM_VL
      WHERE PROGRAM_ID = p_ptr_prgm_rec.program_id;

   l_ptr_prgm_rec c_complete%ROWTYPE;

BEGIN

   x_complete_rec := p_ptr_prgm_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_ptr_prgm_rec;
   CLOSE c_complete;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning program_id');
   END IF;

  -- program_id
  -- IF p_ptr_prgm_rec.program_id = FND_API.g_miss_num THEN
   IF p_ptr_prgm_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_ptr_prgm_rec.program_id;
   END IF;

   -- PROGRAM_TYPE_ID
   IF p_ptr_prgm_rec.PROGRAM_TYPE_ID IS NULL THEN
      x_complete_rec.PROGRAM_TYPE_ID := l_ptr_prgm_rec.PROGRAM_TYPE_ID;
   END IF;

   -- custom_setup_id
   IF p_ptr_prgm_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_ptr_prgm_rec.custom_setup_id;
   END IF;

   -- program_level_code
   IF p_ptr_prgm_rec.program_level_code IS NULL THEN
      x_complete_rec.program_level_code := l_ptr_prgm_rec.program_level_code;
   END IF;

      -- program_name
   IF p_ptr_prgm_rec.program_name IS NULL THEN
       x_complete_rec.program_name := l_ptr_prgm_rec.program_name;
   END IF;

   -- program_description
   IF p_ptr_prgm_rec.program_description IS NULL THEN
      x_complete_rec.program_description := l_ptr_prgm_rec.program_description;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('- In Complete_Rec API prior to assigning program_parent_id');
   END IF;

   -- program_parent_id
   IF p_ptr_prgm_rec.program_parent_id IS NULL THEN
   --IF p_ptr_prgm_rec.program_id = FND_API.g_miss_num THEN
      x_complete_rec.program_parent_id := l_ptr_prgm_rec.program_parent_id;
   END IF;

   -- program_owner_resource_id
   IF p_ptr_prgm_rec.program_owner_resource_id IS NULL THEN
      x_complete_rec.program_owner_resource_id := l_ptr_prgm_rec.program_owner_resource_id;
   END IF;


   -- program_start_date
   IF p_ptr_prgm_rec.program_start_date IS NULL THEN
      x_complete_rec.program_start_date := l_ptr_prgm_rec.program_start_date;
   END IF;

   -- program_end_date
   IF p_ptr_prgm_rec.program_end_date IS NULL THEN
      x_complete_rec.program_end_date := l_ptr_prgm_rec.program_end_date;
   END IF;

   -- allow_enrl_until_date
   IF p_ptr_prgm_rec.allow_enrl_until_date IS NULL THEN
      x_complete_rec.allow_enrl_until_date := l_ptr_prgm_rec.allow_enrl_until_date;
   END IF;

  --citem_version_id

  IF p_ptr_prgm_rec.citem_version_id  IS NULL THEN
      x_complete_rec.citem_version_id  := l_ptr_prgm_rec.citem_version_id;
   END IF;

   -- membership_valid_period
   IF p_ptr_prgm_rec.membership_valid_period IS NULL THEN
      x_complete_rec.membership_valid_period := l_ptr_prgm_rec.membership_valid_period;
   END IF;


   -- membership_period_unit
   IF p_ptr_prgm_rec.membership_period_unit IS NULL THEN
      x_complete_rec.membership_period_unit := l_ptr_prgm_rec.membership_period_unit;
   END IF;

   -- process_rule_id
   IF p_ptr_prgm_rec.process_rule_id IS NULL THEN
      x_complete_rec.process_rule_id := l_ptr_prgm_rec.process_rule_id;
   END IF;

    -- prereq process_rule_id
   IF p_ptr_prgm_rec.prereq_process_rule_Id IS NULL THEN
      x_complete_rec.prereq_process_rule_Id := l_ptr_prgm_rec.prereq_process_rule_Id;
   END IF;

   -- program_status_code
   IF p_ptr_prgm_rec.program_status_code IS NULL THEN
      x_complete_rec.program_status_code := l_ptr_prgm_rec.program_status_code;
   END IF;

   IF p_ptr_prgm_rec.submit_child_nodes IS NULL THEN
      x_complete_rec.submit_child_nodes := l_ptr_prgm_rec.submit_child_nodes;
   END IF;

   IF p_ptr_prgm_rec.inventory_item_id IS NULL THEN
      x_complete_rec.inventory_item_id := l_ptr_prgm_rec.inventory_item_id;
   END IF;

   IF p_ptr_prgm_rec.inventory_item_org_id IS NULL THEN
      x_complete_rec.inventory_item_org_id := l_ptr_prgm_rec.inventory_item_org_id;
   END IF;

   IF p_ptr_prgm_rec.bus_user_resp_id IS NULL THEN
      x_complete_rec.bus_user_resp_id := l_ptr_prgm_rec.bus_user_resp_id;
   END IF;

  IF p_ptr_prgm_rec.admin_resp_id IS NULL THEN
      x_complete_rec.admin_resp_id := l_ptr_prgm_rec.admin_resp_id;
   END IF;

   IF p_ptr_prgm_rec.no_fee_flag IS NULL THEN
      x_complete_rec.no_fee_flag := l_ptr_prgm_rec.no_fee_flag;
   END IF;


   IF p_ptr_prgm_rec.vad_invite_allow_flag IS NULL THEN
      x_complete_rec.vad_invite_allow_flag := l_ptr_prgm_rec.vad_invite_allow_flag;
   END IF;

   IF p_ptr_prgm_rec.global_mmbr_reqd_flag IS NULL THEN
      x_complete_rec.global_mmbr_reqd_flag := l_ptr_prgm_rec.global_mmbr_reqd_flag;
   END IF;

   IF p_ptr_prgm_rec.waive_subsidiary_fee_flag IS NULL THEN
      x_complete_rec.waive_subsidiary_fee_flag := l_ptr_prgm_rec.waive_subsidiary_fee_flag;
   END IF;

   IF p_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag IS NULL THEN
      x_complete_rec.qsnr_ttl_all_page_dsp_flag := l_ptr_prgm_rec.qsnr_ttl_all_page_dsp_flag;
   END IF;

   IF p_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag IS NULL THEN
      x_complete_rec.qsnr_hdr_all_page_dsp_flag := l_ptr_prgm_rec.qsnr_hdr_all_page_dsp_flag;
   END IF;

   IF p_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag IS NULL THEN
      x_complete_rec.qsnr_ftr_all_page_dsp_flag := l_ptr_prgm_rec.qsnr_ftr_all_page_dsp_flag;
   END IF;

   IF p_ptr_prgm_rec.allow_enrl_wout_chklst_flag IS NULL THEN
      x_complete_rec.allow_enrl_wout_chklst_flag := l_ptr_prgm_rec.allow_enrl_wout_chklst_flag;
   END IF;

   IF p_ptr_prgm_rec.user_status_id IS NULL THEN
      x_complete_rec.user_status_id := l_ptr_prgm_rec.user_status_id;
   END IF;

   -- enabled_flag
   IF p_ptr_prgm_rec.enabled_flag IS NULL THEN
      x_complete_rec.enabled_flag := l_ptr_prgm_rec.enabled_flag;
   END IF;

   -- attribute_category
   IF p_ptr_prgm_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_ptr_prgm_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_ptr_prgm_rec.attribute1;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_ptr_prgm_rec.attribute2;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_ptr_prgm_rec.attribute3;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_ptr_prgm_rec.attribute4;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_ptr_prgm_rec.attribute5;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_ptr_prgm_rec.attribute6;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_ptr_prgm_rec.attribute7;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_ptr_prgm_rec.attribute8;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_ptr_prgm_rec.attribute9;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10:= l_ptr_prgm_rec.attribute10;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_ptr_prgm_rec.attribute11;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_ptr_prgm_rec.attribute12;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_ptr_prgm_rec.attribute13;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_ptr_prgm_rec.attribute14;
   END IF;

   -- attribute1
   IF p_ptr_prgm_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_ptr_prgm_rec.attribute15;
   END IF;

   -- last_update_date
   IF p_ptr_prgm_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_ptr_prgm_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_ptr_prgm_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_ptr_prgm_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_ptr_prgm_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_ptr_prgm_rec.creation_date;
   END IF;

   -- created_by
   IF p_ptr_prgm_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_ptr_prgm_rec.created_by;
   END IF;

   -- last_update_login
   IF p_ptr_prgm_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_ptr_prgm_rec.last_update_login;
   END IF;

END Complete_Rec;



PROCEDURE Validate_partner_program(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2       := FND_API.G_FALSE
    ,p_validation_level           IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL
    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    ,p_validation_mode            IN   VARCHAR2       := Jtf_Plsql_Api.G_UPDATE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    )

IS

l_api_name                  CONSTANT VARCHAR2(30) := 'Validate_Partner_Program';
l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_api_version_number        CONSTANT NUMBER       := 1.0;
l_object_version_number              NUMBER;
l_ptr_prgm_rec                       PV_Partner_Program_PVT.ptr_prgm_rec_type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Partner_Program_;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

       -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - start');
      END IF;

     IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
     -- Debug message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - prior to Check_Items call');
     END IF;

              Check_Items(
                  p_ptr_prgm_rec          => p_ptr_prgm_rec
                 ,p_validation_mode       => p_validation_mode
                 ,x_return_status         => x_return_status
                 );

              -- Debug message
              IF (PV_DEBUG_HIGH_ON) THEN

              PVX_UTILITY_PVT.debug_message('  Private API: ' || l_full_name || ' - return status after Check_Items call ' || x_return_status);
              END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Rec(
            p_api_version_number     => 1.0
           ,p_init_msg_list          => FND_API.G_FALSE
           ,x_return_status          => x_return_status
           ,x_msg_count              => x_msg_count
           ,x_msg_data               => x_msg_data
           ,p_ptr_prgm_rec           => l_ptr_prgm_rec
           );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_full_name || ' - end');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Partner_Program_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('IN VALIDATE PROGRAM ERROR BLOCK');
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Partner_Program_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN VALIDATE PROGRAM UNEXPECTED ERROR BLOCK');
      END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Partner_Program_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('IN VALIDATE PROGRAM WHEN OTHERS BLOCK');
      END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

END Validate_Partner_Program;

PROCEDURE Validate_Rec(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,p_ptr_prgm_rec               IN   ptr_prgm_rec_type
    ,p_validation_mode            IN   VARCHAR2     := Jtf_Plsql_Api.G_UPDATE
    )

IS

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Rec;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Write_Log
   --
   -- PURPOSE
   --   Helper method for conc. program .
   -- USED BY
   --   Internally close_ended_programs
   -- HISTORY
   --   12/04/2002        sveerave        CREATION
   --------------------------------------------------------------------------

PROCEDURE Write_Log(p_which number, p_mssg  varchar2) IS
BEGIN
    FND_FILE.put(p_which, p_mssg);
    FND_FILE.NEW_LINE(p_which, 1);
END Write_Log;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Close_Ended_programs
   --
   -- PURPOSE
   --   close all the partner programs which are end dated.
   -- IN
   --   std. conc. request parameters.
   --   ERRBUF
   --   RETCODE
   -- OUT
   -- USED BY
   --   Concurrent program
   -- HISTORY
   --   12/04/2002  sveerave        CREATION
   --   03/31/2003  sveerave  Now, if any error happens, conc prog will completely
   --                         error out. Changed in such a way that if error happens
   --                         for a particular program, it will process all other non-errored
   --                         records, but will complete with a waring for bug#2878969
   --------------------------------------------------------------------------
PROCEDURE Close_Ended_programs(
  ERRBUF                OUT NOCOPY VARCHAR2,
  RETCODE               OUT NOCOPY VARCHAR2 )
IS
  CURSOR c_get_closable_memb IS
    SELECT program_id, object_version_number
    FROM pv_partner_program_b
    WHERE program_level_code = 'MEMBERSHIP'
      AND NVL(program_end_date,sysdate+1) <= sysdate
      AND program_status_code NOT IN ('CLOSED', 'ARCHIVE');

  CURSOR c_get_closable_prgm IS
    SELECT program_id, object_version_number
    FROM pv_partner_program_b
    WHERE program_level_code = 'PROGRAM'
      AND NVL(program_end_date,sysdate+1) <= sysdate
      AND program_status_code NOT IN ('CLOSED', 'ARCHIVE');

  CURSOR c_get_user_status IS
    SELECT user_status_id
    FROM ams_user_statuses_b
    WHERE system_status_type like 'PV_PROGRAM_STATUS'
      AND system_status_code = 'CLOSED'
      AND enabled_flag = 'Y';

  l_ptr_prgm_rec  PV_PARTNER_PROGRAM_PVT.ptr_prgm_rec_type ;
  l_return_status VARCHAR2(1);
  l_msg_count   NUMBER;
  l_msg_data      VARCHAR2(240);
  l_user_status_id NUMBER := NULL;
  l_msg varchar2(4000);

BEGIN
  Write_log (1, 'Start of Processing:');
  -- default with success return code
  retcode := 0;

  OPEN c_get_user_status;
  FETCH c_get_user_status INTO l_user_status_id;
  IF c_get_user_status%NOTFOUND THEN
    CLOSE c_get_user_status;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE c_get_user_status;

  Write_log (1, 'Start of Processing for closing endable memberships: ');

  FOR c_get_closable_memb_rec IN c_get_closable_memb LOOP
    Write_log (1, 'Processing membership id: '|| c_get_closable_memb_rec.program_id);
    BEGIN
      l_ptr_prgm_rec.program_id := c_get_closable_memb_rec.program_id;
      l_ptr_prgm_rec.object_version_number := c_get_closable_memb_rec.object_version_number;
      l_ptr_prgm_rec.user_status_id  := l_user_status_id;
      l_ptr_prgm_rec.program_status_code := 'CLOSED';
      Update_Partner_Program(
         p_api_version_number         => 1.0
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_ptr_prgm_rec               => l_ptr_prgm_rec
        );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RETCODE := '1'; -- warning
        FND_MSG_PUB.reset;
        LOOP
          l_msg := fnd_msg_pub.get(p_encoded => FND_API.G_FALSE);
          EXIT WHEN l_msg IS NULL;
          Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': '||l_msg);
        END LOOP;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RETCODE := '1'; -- warning
        Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM);
      END IF;
    END;
  END LOOP;

  Write_log (1, 'Start of Processing for closing endable programs: ');
  FOR c_get_closable_prgm_rec IN c_get_closable_prgm LOOP
    Write_log (1, 'Processing program id: '|| c_get_closable_prgm_rec.program_id);
    BEGIN
      l_ptr_prgm_rec.program_id := c_get_closable_prgm_rec.program_id;
      l_ptr_prgm_rec.object_version_number := c_get_closable_prgm_rec.object_version_number;
      l_ptr_prgm_rec.user_status_id  := l_user_status_id;
      l_ptr_prgm_rec.program_status_code := 'CLOSED';
      Update_Partner_Program(
         p_api_version_number         => 1.0
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_ptr_prgm_rec               => l_ptr_prgm_rec
        );
      IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RETCODE := '1'; -- warning
        FND_MSG_PUB.reset;
        LOOP
          l_msg := fnd_msg_pub.get(p_encoded => FND_API.G_FALSE);
          EXIT WHEN l_msg IS NULL;
          Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': '||l_msg);
        END LOOP;
      ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
        RETCODE := '1'; -- warning
        Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM);
      END IF;
    END;
  END LOOP;
  IF retcode IN (0,1) THEN
    COMMIT;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ERRBUF := ERRBUF || sqlerrm;
    RETCODE := '2';
    IF l_user_status_id IS NULL THEN
      Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': User Status for CLOSED program status is not setup. Pls. setup, and retry');
    END IF;

  WHEN OTHERS THEN
    ERRBUF := ERRBUF||sqlerrm;
    RETCODE := '2';
    --l_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR', SQLERRM);
    Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': Other Exception in running the conc. program for closing the endable programs');
    Write_log (1, TO_CHAR(DBMS_UTILITY.get_time)||': SQLCODE: ' || to_char(SQLCODE) || ' SQLERRM: ' || SQLERRM);

END Close_Ended_programs;

   --------------------------------------------------------------------------
   -- PROCEDURE
   --   Get_Object_Name
   --
   -- PURPOSE
   --   Provides the program name to Oracle Content Manager given program_id.
   --   This is needed so that IBC can display correct program name in their UI.
   -- IN
   --   p_association_type_code -- should be the association type code for Program in IBC, 'PV_PRGM'
   --   p_associated_object_val_1  -- object_id, i.e. program_id
   --   p_associated_object_val_2 -- optional
   --   p_associated_object_val_3 -- optional
   --   p_associated_object_val_4 -- optional
   --   p_associated_object_val_5 -- optional

   -- OUT
   --   x_object_name   program_name
   --   x_object_code   None
   --   x_return_status   return status
   --   x_msg_count   std. out params
   --   x_msg_data   std. out params

   -- USED BY
   --   IBC User Interfaces
   -- HISTORY
   --   01/21/2003        sveerave        CREATION
   --------------------------------------------------------------------------
PROCEDURE Get_Object_Name
(
    p_association_type_code       IN    VARCHAR2
   ,p_associated_object_val_1     IN    VARCHAR2
   ,p_associated_object_val_2     IN    VARCHAR2 DEFAULT NULL
   ,p_associated_object_val_3     IN    VARCHAR2 DEFAULT NULL
   ,p_associated_object_val_4     IN    VARCHAR2 DEFAULT NULL
   ,p_associated_object_val_5     IN    VARCHAR2 DEFAULT NULL
   ,x_object_name                 OUT NOCOPY  VARCHAR2
   ,x_object_code                 OUT NOCOPY  VARCHAR2
   ,x_return_status               OUT NOCOPY  VARCHAR2
   ,x_msg_count                   OUT NOCOPY  NUMBER
   ,x_msg_data                    OUT NOCOPY  VARCHAR2
) AS

  CURSOR cur_get_prog_name(p_program_id IN NUMBER)  IS
    SELECT  program_name
    FROM    pv_partner_program_vl
    WHERE   program_id = p_program_id;

  l_api_name  CONSTANT VARCHAR2(30)   := 'GET_OBJECT_NAME';

BEGIN

  IF p_association_type_code = 'PV_PRGM' THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN cur_get_prog_name(p_associated_object_val_1);
    FETCH cur_get_prog_name INTO x_object_name;
    CLOSE cur_get_prog_name;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
       , p_data  => x_msg_data
       );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
       , p_data  => x_msg_data
       );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      (  p_count => x_msg_count
       , p_data  => x_msg_data
       );
END Get_Object_Name;

PROCEDURE Copy_Program
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_source_object_id     IN    NUMBER
   --,p_identity_resource_id IN    NUMBER
   ,p_attributes_table     IN    AMS_CpyUtility_PVT.copy_attributes_table_type
   ,p_copy_columns_table   IN    AMS_CpyUtility_PVT.copy_columns_table_type
   ,x_new_object_id        OUT   NOCOPY   NUMBER
   ,x_custom_setup_id      OUT   NOCOPY   NUMBER
)
IS
   CURSOR c_get_ptr_prgm_rec (cv_program_id IN NUMBER)  IS
      SELECT  *
      FROM    pv_partner_program_vl
      WHERE   program_id = cv_program_id;

   CURSOR c_get_user_status_id  IS
      SELECT user_status_id
      FROM ams_user_statuses_vl
      WHERE system_status_type = 'PV_PROGRAM_STATUS'
      AND system_status_code = 'NEW'
      AND enabled_flag = 'Y';

   CURSOR C_get_current_resource IS
      SELECT res.resource_id resource_id
      FROM jtf_rs_resource_extns res
      WHERE res.category IN ('EMPLOYEE', 'PARTY')
      AND res.user_id = fnd_global.user_id;

   l_src_ptr_pgrm_rec          c_get_ptr_prgm_rec%ROWTYPE;
   l_new_ptr_pgrm_rec          ptr_prgm_rec_type;
   l_new_program_id            NUMBER;
   l_identity_resource_id      NUMBER;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Copy_Program';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Program;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get the source object_id
   OPEN c_get_ptr_prgm_rec (p_source_object_id);
   FETCH c_get_ptr_prgm_rec INTO l_src_ptr_pgrm_rec;

   If (c_get_ptr_prgm_rec%NOTFOUND) THEN
      PVX_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_COPY_SOURCE',
                                    p_token_name   => 'SOURCE',
                                    p_token_value  => 'Program');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   CLOSE c_get_ptr_prgm_rec;

   -- Get the identity_resource_id
   FOR x in c_get_current_resource
   LOOP
      l_identity_resource_id := x.resource_id;
   END LOOP;

   -- Mandatory columns. From source program.
   l_new_ptr_pgrm_rec.program_level_code := l_src_ptr_pgrm_rec.program_level_code;
   l_new_ptr_pgrm_rec.program_type_id := l_src_ptr_pgrm_rec.program_type_id;
   l_new_ptr_pgrm_rec.custom_setup_id := l_src_ptr_pgrm_rec.custom_setup_id;
   l_new_ptr_pgrm_rec.vad_invite_allow_flag := l_src_ptr_pgrm_rec.vad_invite_allow_flag;
   l_new_ptr_pgrm_rec.global_mmbr_reqd_flag := l_src_ptr_pgrm_rec.global_mmbr_reqd_flag;
   l_new_ptr_pgrm_rec.waive_subsidiary_fee_flag := l_src_ptr_pgrm_rec.waive_subsidiary_fee_flag;
   l_new_ptr_pgrm_rec.program_status_code := 'NEW';
   l_new_ptr_pgrm_rec.inventory_item_id := l_src_ptr_pgrm_rec.inventory_item_id;
   l_new_ptr_pgrm_rec.inventory_item_org_id := l_src_ptr_pgrm_rec.inventory_item_org_id;


   FOR x in c_get_user_status_id
   LOOP
      l_new_ptr_pgrm_rec.user_status_id := x.user_status_id;
   END LOOP;
   l_new_ptr_pgrm_rec.submit_child_nodes := 'N';
   l_new_ptr_pgrm_rec.enabled_flag := 'Y';

   -- Mandatory columns. From user input.
   AMS_CpyUtility_PVT.get_column_value('newObjName', p_copy_columns_table, l_new_ptr_pgrm_rec.program_name);
   AMS_CpyUtility_PVT.get_column_value('prmOwnerResID', p_copy_columns_table, l_new_ptr_pgrm_rec.program_owner_resource_id);
   AMS_CpyUtility_PVT.get_column_value('programStartDate', p_copy_columns_table, l_new_ptr_pgrm_rec.program_start_date);
   AMS_CpyUtility_PVT.get_column_value('programEndDate', p_copy_columns_table, l_new_ptr_pgrm_rec.program_end_date);

   -- Mandatory columns. If not shown on the copy screen, get from the source object.
   AMS_CpyUtility_PVT.get_column_value ('noFeesFlag', p_copy_columns_table, l_new_ptr_pgrm_rec.no_fee_flag);
   l_new_ptr_pgrm_rec.no_fee_flag := NVL (l_new_ptr_pgrm_rec.no_fee_flag, l_src_ptr_pgrm_rec.no_fee_flag);

   AMS_CpyUtility_PVT.get_column_value ('membPeriodUnit', p_copy_columns_table, l_new_ptr_pgrm_rec.membership_period_unit);
   l_new_ptr_pgrm_rec.membership_period_unit := NVL (l_new_ptr_pgrm_rec.membership_period_unit, l_src_ptr_pgrm_rec.membership_period_unit);

   AMS_CpyUtility_PVT.get_column_value ('membValidPeriod', p_copy_columns_table, l_new_ptr_pgrm_rec.membership_valid_period);
   l_new_ptr_pgrm_rec.membership_valid_period := NVL (l_new_ptr_pgrm_rec.membership_valid_period, l_src_ptr_pgrm_rec.membership_valid_period);

   AMS_CpyUtility_PVT.get_column_value ('allowEnrlUntillDate', p_copy_columns_table, l_new_ptr_pgrm_rec.allow_enrl_until_date);
   l_new_ptr_pgrm_rec.allow_enrl_until_date := NVL (l_new_ptr_pgrm_rec.allow_enrl_until_date, l_src_ptr_pgrm_rec.allow_enrl_until_date);

   AMS_CpyUtility_PVT.get_column_value ('parentProgramId', p_copy_columns_table, l_new_ptr_pgrm_rec.program_parent_id);
   l_new_ptr_pgrm_rec.program_parent_id := NVL (l_new_ptr_pgrm_rec.program_parent_id, l_src_ptr_pgrm_rec.program_parent_id);

   -- Optional columns. From user input.
   AMS_CpyUtility_PVT.get_column_value ('description', p_copy_columns_table, l_new_ptr_pgrm_rec.program_description);


   -- add this for the questionnaire flag
   IF AMS_CpyUtility_PVT.is_copy_attribute ('QSNR', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'QSNR');
      END IF;
	l_new_ptr_pgrm_rec.QSNR_TTL_ALL_PAGE_DSP_FLAG := l_src_ptr_pgrm_rec.QSNR_TTL_ALL_PAGE_DSP_FLAG;
	l_new_ptr_pgrm_rec.QSNR_HDR_ALL_PAGE_DSP_FLAG := l_src_ptr_pgrm_rec.QSNR_HDR_ALL_PAGE_DSP_FLAG;
	l_new_ptr_pgrm_rec.QSNR_FTR_ALL_PAGE_DSP_FLAG := l_src_ptr_pgrm_rec.QSNR_FTR_ALL_PAGE_DSP_FLAG;
   END IF;

   -- add this for the allow_enrl_wo_cl_flag flag
   IF AMS_CpyUtility_PVT.is_copy_attribute ('CHKLST', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'CHKLST');
      END IF;
	l_new_ptr_pgrm_rec.allow_enrl_wout_chklst_flag := l_src_ptr_pgrm_rec.allow_enrl_wout_chklst_flag;
   END IF;

   PV_Partner_Program_PVT.Create_Partner_Program(
       p_api_version_number    => 1.0
      ,p_init_msg_list         => FND_API.G_FALSE
      ,p_commit                => FND_API.G_FALSE
      ,p_validation_level      => p_validation_level
      ,p_ptr_prgm_rec          => l_new_ptr_pgrm_rec
      ,p_identity_resource_id  => l_identity_resource_id
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      ,x_program_id            => l_new_program_id
    );

   x_new_object_id := l_new_program_id;
   x_custom_setup_id := l_new_ptr_pgrm_rec.custom_setup_id;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- For requirements
   IF AMS_CpyUtility_PVT.is_copy_attribute ('QUAL', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'QUAL');
      END IF;

      PV_Partner_Program_PVT.Copy_Qualifications (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id,
         p_identity_resource_id     => l_identity_resource_id
      );

   END IF;

   -- For benefits
   IF AMS_CpyUtility_PVT.is_copy_attribute ('BNFT', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'BNFT');
      END IF;

      PV_Partner_Program_PVT.Copy_Benefits (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- For pricing
   IF AMS_CpyUtility_PVT.is_copy_attribute ('PMNT', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'PMNT');
      END IF;
      PV_Partner_Program_PVT.Copy_payments (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id
      );
   END IF;

   -- For geography
   IF AMS_CpyUtility_PVT.is_copy_attribute ('GEOG', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'GEOG');
      END IF;
      AMS_COPYELEMENTS_PVT.copy_act_geo_areas (
         p_src_act_type   => 'PRGM',
         p_new_act_type   => 'PRGM',
         p_src_act_id     => p_source_object_id,
         p_new_act_id     => l_new_program_id,
         p_errnum         => x_msg_count,
         p_errcode        => x_return_status,
         p_errmsg         => x_msg_data
      );
      IF x_msg_data is not null THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;

   END IF;

   -- For legal terms
   IF AMS_CpyUtility_PVT.is_copy_attribute ('LGLT', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'LGLT');
      END IF;
      PV_Partner_Program_PVT.Copy_Legal_Terms (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- For enrollment questionnaire
   IF AMS_CpyUtility_PVT.is_copy_attribute ('QSNR', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'QUAL');
      END IF;
      PV_Partner_Program_PVT.Copy_Questionnaire (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- For approval checklist
   IF AMS_CpyUtility_PVT.is_copy_attribute ('CHKLST', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'CHKLST');
      END IF;
      PV_Partner_Program_PVT.Copy_Checklist (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- For notification rules
   IF AMS_CpyUtility_PVT.is_copy_attribute ('NOTIF', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'QUAL');
      END IF;

      PV_Partner_Program_PVT.Copy_Notif_Rules (
         p_api_version_number       => 1.0,
         p_init_msg_list            => FND_API.G_FALSE,
         p_commit                   => FND_API.G_FALSE,
         p_validation_level         => p_validation_level,
         x_return_status            => x_return_status,
         x_msg_count                => x_msg_count,
         x_msg_data                 => x_msg_data,
         p_object_type              => 'PRGM',
         p_src_object_id            => p_source_object_id,
         p_tar_object_id            => l_new_program_id
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   -- For team
   IF AMS_CpyUtility_PVT.is_copy_attribute ('TEAM', p_attributes_table) = FND_API.G_TRUE THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'TEAM');
      END IF;
      AMS_COPYELEMENTS_PVT.copy_act_access (
         p_src_act_type   => 'PRGM',
         p_new_act_type   => 'PRGM',
         p_src_act_id     => p_source_object_id,
         p_new_act_id     => l_new_program_id,
         p_errnum         => x_msg_count,
         p_errcode        => x_return_status,
         p_errmsg         => x_msg_data
      );
      IF x_msg_data is not null THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      x_return_status := fnd_api.g_ret_sts_success;
   END IF;

   x_new_object_id := l_new_program_id;
   x_custom_setup_id := l_new_ptr_pgrm_rec.custom_setup_id;


EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Program;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Program;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Program;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Program;

/*********************
 *
 *
 * Copy_Qualifications
 *
 *
 *********************/
PROCEDURE Copy_Qualifications
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
   ,p_identity_resource_id IN    NUMBER
)
IS
   CURSOR c_get_process_rule_id (cv_program_id IN NUMBER)  IS
      SELECT   process_rule_id id, 'ProcessRule' rule, object_version_number
      FROM     pv_partner_program_b
      WHERE    program_id = cv_program_id
      UNION
      SELECT   prereq_process_rule_id id, 'PrereqProcessRule' rule, object_version_number
      FROM     pv_partner_program_b
      WHERE    program_id = cv_program_id;

   CURSOR c_get_process_rule_rec (cv_process_rule_id IN NUMBER)  IS
      SELECT   *
      FROM     PV_PROCESS_RULES_VL
      WHERE    PROCESS_RULE_ID = cv_process_rule_id;

   CURSOR c_get_program_name_rec (cv_program_id IN NUMBER)  IS
      SELECT   program_name
      FROM     PV_PARTNER_PROGRAM_VL
      WHERE    PROGRAM_ID = cv_program_id;

   /*
   CURSOR c_get_object_version_number (cv_program_id IN NUMBER)  IS
      SELECT   object_version_number
      FROM     pv_partner_program_b
      WHERE    program_id = cv_program_id;
   */
   CURSOR c_get_pec_rules_rec (cv_program_id IN NUMBER)  IS
      SELECT   *
      FROM     PV_PG_ENRL_CHANGE_RULES
      WHERE    change_to_program_id = cv_program_id
      and      CHANGE_DIRECTION_CODE = 'PREREQUISITE';

   l_process_rule_name           VARCHAR2(100);
   l_src_process_rule_id         NUMBER;
   l_fake_process_rule_id        NUMBER;
   l_return_rule_id              NUMBER;
   l_enrl_change_rule_id         NUMBER;
   l_src_process_rule_rec        c_get_process_rule_rec%ROWTYPE;
   l_tar_process_rule_rec        PV_RULE_RECTYPE_PUB.RULES_REC_TYPE;
   l_fake_process_rule_rec       PV_RULE_RECTYPE_PUB.RULES_REC_TYPE;
   l_tar_ptr_prgm_rec            PV_Partner_Program_PVT.ptr_prgm_rec_type;
   l_src_pec_rules_rec           c_get_pec_rules_rec%ROWTYPE;
   l_tar_pec_rules_rec           PV_Pec_Rules_PVT.pec_rules_rec_type;
   L_API_NAME                    CONSTANT VARCHAR2(30) := 'Copy_Qualifications';
   L_API_VERSION_NUMBER          CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Qualifications;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get the target program name
   FOR y IN c_get_program_name_rec (p_tar_object_id)
   LOOP
	l_process_rule_name := y.program_name;
   END LOOP;

   -- Get the source process_rule_id and make a copy
   FOR x IN c_get_process_rule_id (p_src_object_id)
   LOOP
      l_src_process_rule_id := x.id;
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_src_process_rule_id = ' || l_src_process_rule_id);
          PVX_UTILITY_PVT.debug_message('x.rule = ' || x.rule);
      END IF;

      FOR l_src_process_rule_rec IN c_get_process_rule_rec (l_src_process_rule_id)
      LOOP
         l_tar_process_rule_rec.process_rule_id := l_src_process_rule_id;
         l_tar_process_rule_rec.process_rule_name := l_process_rule_name;
         l_tar_process_rule_rec.description := l_src_process_rule_rec.description;
         l_tar_process_rule_rec.process_type := l_src_process_rule_rec.process_type;
         l_tar_process_rule_rec.status_code := l_src_process_rule_rec.status_code;
         l_tar_process_rule_rec.currency_code := l_src_process_rule_rec.currency_code;
         l_tar_process_rule_rec.start_date := l_src_process_rule_rec.start_date;
         l_tar_process_rule_rec.end_date := l_src_process_rule_rec.end_date;
         l_tar_process_rule_rec.rank := l_src_process_rule_rec.rank;
         l_tar_process_rule_rec.owner_resource_id := l_src_process_rule_rec.owner_resource_id;

         PV_PROCESS_RULE_PVT.Copy_process_rule (
            p_api_version_number         => 2.0
           ,p_init_msg_list              => FND_API.G_FALSE
           ,p_commit                     => FND_API.G_FALSE
           ,p_validation_level           => p_validation_level
           ,p_identity_resource_id       => p_identity_resource_id
           ,p_process_rule_rec           => l_tar_process_rule_rec
           ,x_process_rule_id            => l_return_rule_id
           ,x_return_status              => x_return_status
           ,x_msg_count                  => x_msg_count
           ,x_msg_data                   => x_msg_data
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      IF (x.rule = 'ProcessRule') THEN
         l_tar_ptr_prgm_rec.process_rule_id := l_return_rule_id;
      ELSIF (x.rule = 'PrereqProcessRule') THEN
         l_tar_ptr_prgm_rec.prereq_process_rule_id := l_return_rule_id;
      END IF;
   END LOOP;

   -- Get the "fake" (created in create_partner_program) process_rule_id in
   -- pv_partner_program_b table and delete it.
   -- Also get the object_version_number of that program record for update
   -- later. (Update the process_rule_id with the l_return_rule_id)
   FOR x IN c_get_process_rule_id (p_tar_object_id)
   LOOP
      l_fake_process_rule_rec.process_rule_id := x.id;
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_fake_process_rule_rec.process_rule_id = ' || l_fake_process_rule_rec.process_rule_id);
      END IF;
      --l_fake_process_rule_rec.object_version_number := 1;
      PV_PROCESS_RULE_PVT.Delete_process_rule(
         p_api_version_number         => 2.0
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_validation_level           => p_validation_level
        ,p_identity_resource_id       => p_identity_resource_id
        ,p_process_rule_rec           => l_fake_process_rule_rec
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Get the object_version_number for later Update_Partner_Program
      l_tar_ptr_prgm_rec.object_version_number := x.object_version_number;
   END LOOP;

   l_tar_ptr_prgm_rec.program_id := p_tar_object_id;
   --l_tar_ptr_prgm_rec.process_rule_id := l_return_rule_id;
   /*
   FOR x IN c_get_object_version_number (p_tar_object_id) LOOP
      l_tar_ptr_prgm_rec.object_version_number := x.object_version_number;
   END LOOP;
   */
   PV_Partner_Program_PVT.Update_Partner_Program(
       p_api_version_number    => 1.0
      ,p_init_msg_list         => FND_API.G_FALSE
      ,p_commit                => FND_API.G_FALSE
      ,p_validation_level      => p_validation_level
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      ,p_ptr_prgm_rec          => l_tar_ptr_prgm_rec
    );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR l_src_pec_rules_rec IN c_get_pec_rules_rec (p_src_object_id)
   LOOP
      l_tar_pec_rules_rec.change_to_program_id := p_tar_object_id;
      l_tar_pec_rules_rec.change_from_program_id := l_src_pec_rules_rec.change_from_program_id;
      l_tar_pec_rules_rec.change_direction_code := l_src_pec_rules_rec.change_direction_code;
      l_tar_pec_rules_rec.effective_from_date := l_src_pec_rules_rec.effective_from_date;
      l_tar_pec_rules_rec.effective_to_date := l_src_pec_rules_rec.effective_to_date;
      l_tar_pec_rules_rec.active_flag := l_src_pec_rules_rec.active_flag;

      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_tar_pec_rules_rec.change_to_program_id = ' || l_tar_pec_rules_rec.change_to_program_id);
          PVX_UTILITY_PVT.debug_message('l_tar_pec_rules_rec.change_from_program_id = ' || l_tar_pec_rules_rec.change_from_program_id);
          PVX_UTILITY_PVT.debug_message('l_tar_pec_rules_rec.change_direction_code = ' || l_tar_pec_rules_rec.change_direction_code);
          PVX_UTILITY_PVT.debug_message('l_tar_pec_rules_rec.effective_from_date = ' || l_tar_pec_rules_rec.effective_from_date);
          PVX_UTILITY_PVT.debug_message('l_tar_pec_rules_rec.effective_to_date = ' || l_tar_pec_rules_rec.effective_to_date);
          PVX_UTILITY_PVT.debug_message('l_tar_pec_rules_rec.effective_to_date = ' || l_tar_pec_rules_rec.effective_to_date);
      END IF;

      PV_Pec_Rules_PVT.Create_Pec_Rules (
         p_api_version_number         => p_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_validation_level           => p_validation_level
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data
        ,p_pec_rules_rec              => l_tar_pec_rules_rec
        ,x_enrl_change_rule_id        => l_enrl_change_rule_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Qualifications;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Qualifications;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Qualifications;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Qualifications;


/*********************
 *
 *
 * Copy_Benefits
 *
 *
 *********************/
PROCEDURE Copy_Benefits
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS
   CURSOR c_get_prgm_benefit_rec (cv_program_id IN NUMBER)  IS
      SELECT  *
      FROM    pv_program_benefits
      WHERE   program_id = cv_program_id;

   l_program_benefits_id      NUMBER;
   l_src_prgm_benefits_rec    c_get_prgm_benefit_rec%ROWTYPE;
   l_tar_prgm_benefits_rec    PV_PRGM_BENEFITS_PVT.prgm_benefits_rec_type;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Copy_Benefits';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Benefits;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR l_src_prgm_benefits_rec IN c_get_prgm_benefit_rec (p_src_object_id)
   LOOP
      l_tar_prgm_benefits_rec.program_id := p_tar_object_id;
      l_tar_prgm_benefits_rec.benefit_code := l_src_prgm_benefits_rec.benefit_code;
      l_tar_prgm_benefits_rec.benefit_id := l_src_prgm_benefits_rec.benefit_id;
      l_tar_prgm_benefits_rec.benefit_type_code := l_src_prgm_benefits_rec.benefit_type_code;
      l_tar_prgm_benefits_rec.delete_flag := l_src_prgm_benefits_rec.delete_flag;
      --l_tar_prgm_benefits_rec.last_update_login := l_src_prgm_benefits_rec.last_update_login;
      --l_tar_prgm_benefits_rec.object_version_number := l_src_prgm_benefits_rec.object_version_number;
      --l_tar_prgm_benefits_rec.last_update_date := l_src_prgm_benefits_rec.last_update_date;
      --l_tar_prgm_benefits_rec.last_updated_by := l_src_prgm_benefits_rec.last_updated_by;
      --l_tar_prgm_benefits_rec.created_by := l_src_prgm_benefits_rec.created_by;
      --l_tar_prgm_benefits_rec.creation_date := l_src_prgm_benefits_rec.creation_date;

      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_benefits_rec.program_id = ' || l_tar_prgm_benefits_rec.program_id);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_benefits_rec.benefit_code = ' || l_tar_prgm_benefits_rec.benefit_code);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_benefits_rec.benefit_id = ' || l_tar_prgm_benefits_rec.benefit_id);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_benefits_rec.benefit_type_code = ' || l_tar_prgm_benefits_rec.benefit_type_code);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_benefits_rec.delete_flag = ' || l_tar_prgm_benefits_rec.delete_flag);
      END IF;

      PV_PRGM_BENEFITS_PVT.Create_Prgm_Benefits (
         p_api_version_number         => p_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_validation_level           => p_validation_level
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data
        ,p_prgm_benefits_rec          => l_tar_prgm_benefits_rec
        ,x_program_benefits_id        => l_program_benefits_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Benefits;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Benefits;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Benefits;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Benefits;

/*********************
 *
 *
 * Copy_Payments
 *
 *
 *********************/
PROCEDURE Copy_Payments
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS
   CURSOR c_get_inventory_item_id (cv_program_id IN NUMBER)  IS
      SELECT  inventory_item_id
      FROM    pv_partner_program_vl
      WHERE   program_id = cv_program_id;

   l_org_inv_item_id          NUMBER;
   l_new_inv_item_id          OZF_PRICELIST_PVT.num_tbl_type;
   l_index                    NUMBER;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Copy_Payments';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Payments;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR x IN c_get_inventory_item_id (p_src_object_id)
   LOOP
      l_org_inv_item_id := x.inventory_item_id;
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_org_inv_item_id = ' || l_org_inv_item_id);
      END IF;
   END LOOP;

   l_index := 1;
   FOR x IN c_get_inventory_item_id (p_tar_object_id)
   LOOP
      l_new_inv_item_id(l_index) := x.inventory_item_id;
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_new_inv_item_id(' || l_index || ') = ' || l_new_inv_item_id(l_index));
      END IF;
      l_index := l_index + 1;
   END LOOP;

   -- Copy Inventory Item
   OZF_PRICELIST_PVT.add_inventory_item(
      p_api_version                => p_api_version_number
     ,p_init_msg_list              => FND_API.G_FALSE
     ,p_commit                     => FND_API.G_FALSE
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     ,p_org_inv_item_id            => l_org_inv_item_id
     ,p_new_inv_item_id            => l_new_inv_item_id
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
    );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Payments;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Payments;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Payments;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Payments;

/*********************
 *
 *
 * Copy_Legal_Terms
 *
 *
 *********************/
PROCEDURE Copy_Legal_Terms
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS
   CURSOR c_get_prgm_contract_rec (cv_program_id IN NUMBER)  IS
      SELECT  *
      FROM    pv_program_contracts
      WHERE   program_id = cv_program_id;

   l_program_contracts_id      NUMBER;
   l_src_prgm_contracts_rec    c_get_prgm_contract_rec%ROWTYPE;
   l_tar_prgm_contracts_rec    PV_PRGM_CONTRACTS_PVT.prgm_contracts_rec_type;
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Copy_Legal_Terms';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Legal_Terms;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR l_src_prgm_contracts_rec IN c_get_prgm_contract_rec (p_src_object_id)
   LOOP
      l_tar_prgm_contracts_rec.program_id := p_tar_object_id;
      l_tar_prgm_contracts_rec.geo_hierarchy_id := l_src_prgm_contracts_rec.geo_hierarchy_id;
      l_tar_prgm_contracts_rec.contract_id := l_src_prgm_contracts_rec.contract_id;
      l_tar_prgm_contracts_rec.member_type_code := l_src_prgm_contracts_rec.member_type_code;

      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_contracts_rec.program_id = ' || l_tar_prgm_contracts_rec.program_id);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_contracts_rec.geo_hierarchy_id = ' || l_tar_prgm_contracts_rec.geo_hierarchy_id);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_contracts_rec.contract_id = ' || l_tar_prgm_contracts_rec.contract_id);
          PVX_UTILITY_PVT.debug_message('l_tar_prgm_contracts_rec.member_type_code = ' || l_tar_prgm_contracts_rec.member_type_code);
      END IF;

      PV_PRGM_CONTRACTS_PVT.Create_Prgm_Contracts (
         p_api_version_number         => p_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_validation_level           => p_validation_level
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data
        ,p_prgm_contracts_rec         => l_tar_prgm_contracts_rec
        ,x_program_contracts_id       => l_program_contracts_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Legal_Terms;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Legal_Terms;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Legal_Terms;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Legal_Terms;

/*********************
 *
 *
 * Copy_Questionnaire
 *
 *
 *********************/
PROCEDURE Copy_Questionnaire
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS

   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Copy_Questionnaire';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Questionnaire;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   PV_Gq_Elements_PVT.Copy_Row
   (
         p_api_version_number		=> p_api_version_number
        ,p_init_msg_list		=> FND_API.G_FALSE
        ,p_commit			=> FND_API.G_FALSE
        ,p_validation_level		=> p_validation_level
        ,x_return_status		=> x_return_status
        ,x_msg_count			=> x_msg_count
        ,x_msg_data			=> x_msg_data
        ,p_src_object_id		=> p_src_object_id
        ,p_tar_object_id		=> p_tar_object_id
   );

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Questionnaire;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Questionnaire;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Questionnaire;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Questionnaire;


/*********************
 *
 *
 * Copy_Checklist
 *
 *
 *********************/
PROCEDURE Copy_Checklist
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS

   l_object_version_number          NUMBER;
   L_API_NAME                       CONSTANT VARCHAR2(30) := 'Copy_Checklist';
   L_API_VERSION_NUMBER             CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Checklist;
        --dbms_output.put_line('Copy_Checklist');

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;
        --dbms_output.put_line('Copy_Checklist');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   PV_Ge_Chklst_PVT.Copy_Row
   (
         p_api_version_number		=> p_api_version_number
        ,p_init_msg_list		=> FND_API.G_FALSE
        ,p_commit			=> FND_API.G_FALSE
        ,p_validation_level		=> p_validation_level
        ,x_return_status		=> x_return_status
        ,x_msg_count			=> x_msg_count
        ,x_msg_data			=> x_msg_data
        ,p_src_object_id		=> p_src_object_id
        ,p_tar_object_id		=> p_tar_object_id
   );

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Checklist;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Checklist;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Checklist;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Checklist;


/*********************
 *
 *
 * Copy_Notif_Rules
 *
 *
 *********************/
PROCEDURE Copy_Notif_Rules
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_object_type          IN    VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)
IS

   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Copy_Notif_Rules';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Notif_Rules;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   PV_Ge_Notif_Rules_PVT.Copy_Row
   (
         p_api_version_number		=> p_api_version_number
        ,p_init_msg_list		=> FND_API.G_FALSE
        ,p_commit			=> FND_API.G_FALSE
        ,p_validation_level		=> p_validation_level
        ,x_return_status		=> x_return_status
        ,x_msg_count			=> x_msg_count
        ,x_msg_data			=> x_msg_data
        ,p_src_object_id		=> p_src_object_id
        ,p_tar_object_id		=> p_tar_object_id
   );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;


   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Copy_Notif_Rules;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Notif_Rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Notif_Rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

END Copy_Notif_Rules;


/** this api create_prereqprocessruleid is called from program requirements UI when the user checks the
    pre-req checkbox and if the prereqprocessruleid is not created in programs table.
    this is provided in 11.5.10  to give backward compatibility.
*/
PROCEDURE  create_prereqruleid(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_program_id                 IN   NUMBER
   ,p_identity_resource_id       IN   NUMBER
   ,l_prereq_rule_id             OUT NOCOPY  NUMBER
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'create_prereqruleid';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status                       VARCHAR2(1);
   l_ptr_prgm_rec                        ptr_prgm_rec_type;
   l_rules_rec                           PV_RULE_RECTYPE_PUB.rules_rec_type  := PV_RULE_RECTYPE_PUB.g_miss_rules_rec;
   l_prereq_process_rule_Id              NUMBER;
   l_object_version_number               NUMBER:= 1;
   l_currency              VARCHAR2(60);

   -- Cursor to validate the uniqueness
   CURSOR get_program_details(p_id IN NUMBER) IS
      SELECT program_name,program_description,object_version_number
      FROM PV_PARTNER_PROGRAM_vl
      WHERE PROGRAM_ID = p_id;

   CURSOR c_resource_id(p_user_id IN NUMBER) IS
      SELECT RESOURCE_ID
      FROM   jtf_rs_resource_extns
      WHERE  USER_ID=p_user_id;


BEGIN

   IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message(' in Update_Partner_Program');
   END IF;



   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_Partner_Program_PVT;
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number
                                       ,p_api_version_number
                                       ,l_api_name
                                       ,G_PKG_NAME
                                      )
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   OPEN c_resource_id(FND_GLOBAL.USER_ID);
      FETCH c_resource_id into l_rules_rec.owner_resource_id;
   CLOSE c_resource_id;

   --get the currency of the logged in user
   l_currency:=FND_PROFILE.Value('ICX_PREFERRED_CURRENCY');

   IF l_currency IS NULL THEN
      FND_MESSAGE.set_name('PV', 'PV_PRGM_CURRENCY_UNDEFINED');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;



   OPEN get_program_details(p_program_id);
      FETCH get_program_details into l_rules_rec.process_rule_name,l_rules_rec.description, l_ptr_prgm_rec.object_version_number ;
   CLOSE get_program_details;


   -- Populate the default required items for process_rule_id
   l_rules_rec.process_type          := 'PARTNER_PROGRAM';
   l_rules_rec.rank                  := 0;
   l_rules_rec.object_version_number := l_object_version_number;
   l_rules_rec.last_update_date      := SYSDATE;
   l_rules_rec.last_updated_by       := FND_GLOBAL.USER_ID;
   l_rules_rec.creation_date         := SYSDATE;
   l_rules_rec.created_by            := FND_GLOBAL.USER_ID;
   l_rules_rec.last_update_login     := FND_GLOBAL.CONC_LOGIN_ID;
   l_rules_rec.start_date            := sysdate;
   l_rules_rec.status_code           := 'ACTIVE';
   l_rules_rec.end_date              :=  null;
   l_rules_rec.currency_code         :=  l_currency;


   -- Invoke process_rule_id api
   PV_PROCESS_RULES_PUB.Create_Process_Rules(
            p_api_version_number        => 2.0
           ,p_init_msg_list             => FND_API.g_false
           ,p_commit                    => FND_API.g_false
           ,p_validation_level          => p_validation_level
           ,p_rules_rec                 => l_rules_rec
           ,p_identity_resource_id      => p_identity_resource_id
           ,x_process_rule_id           => l_prereq_rule_id
           ,x_return_status             => x_return_status
           ,x_msg_count                 => x_msg_count
           ,x_msg_data                  => x_msg_data
        );


   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   -- Debug message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' -  PV_PROCESS_RULES_PUB.Create_Process_Rules return_status = ' || x_return_status );
   END IF;
   -- End of call to PV_PROCESS_RULES_PUB.Create_Process_Rules

   l_ptr_prgm_rec.program_id:=p_program_id;
   l_ptr_prgm_rec.prereq_process_rule_id:=l_prereq_rule_id;


   Update_Partner_Program(
      p_api_version_number         => 1.0
     ,p_init_msg_list              => FND_API.G_FALSE
     ,p_commit                     => FND_API.G_FALSE
     ,p_validation_level           => FND_API.G_VALID_LEVEL_NONE
     ,x_return_status              => l_return_status
     ,x_msg_count                  => l_msg_count
     ,x_msg_data                   => l_msg_data
     ,p_ptr_prgm_rec               => l_ptr_prgm_rec
     );

    -- dbms_output.put_line(' aftr Calling Update_Partner_Program');
    IF l_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
    ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
    END IF;

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
     END IF;

       -- Standard check for p_commit
     IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

END create_prereqruleid;

-- Param p_update_program_table is to indicate whether to update PV_PARTNER_PROGRAM_B
-- If p_update_program_table is 'Y' update the invtory item id
-- and orgnization id with the newly created inventory item info
PROCEDURE  create_inv_item_if_not_exists(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_program_id                 IN   NUMBER
   ,p_update_program_table       IN   VARCHAR2
   ,x_return_status              OUT NOCOPY  VARCHAR2
   ,x_msg_count                  OUT NOCOPY  NUMBER
   ,x_msg_data                   OUT NOCOPY  VARCHAR2
   ,x_inventory_item_id          OUT NOCOPY  NUMBER
   ,x_inventory_item_org_id      OUT NOCOPY  NUMBER
)
IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'create_inv_item_if_not_exists';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_item_rec                  INV_Item_GRP.Item_rec_type;
   l_ptr_prgm_rec              ptr_prgm_rec_type;

   CURSOR c_get_program_info IS
      SELECT *
      FROM   pv_partner_program_vl
      WHERE  program_id = p_program_id;

BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
   END IF;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number
                                       ,p_api_version_number
                                       ,l_api_name
                                       ,G_PKG_NAME
                                      )
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR x IN c_get_program_info LOOP
      l_ptr_prgm_rec.program_id := p_program_id;
      l_ptr_prgm_rec.program_name := x.program_name;
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('l_ptr_prgm_rec.program_name: ' || l_ptr_prgm_rec.program_name);
      END IF;

      IF (x.inventory_item_id is null AND x.inventory_item_org_id is null) THEN
         create_inventory_item(
             p_ptr_prgm_rec       => l_ptr_prgm_rec,
             x_Item_rec           => l_Item_rec,
             x_return_status      => l_return_status,
             x_Error_tbl          => l_error_tbl
          );
         IF l_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('l_Item_rec.inventory_item_id: ' || l_Item_rec.inventory_item_id);
            PVX_UTILITY_PVT.debug_message('l_Item_rec.inventory_item_org_id: ' || l_Item_rec.organization_id);
         END IF;

         x_inventory_item_id := l_Item_rec.inventory_item_id;
         x_inventory_item_org_id := l_Item_rec.organization_id;

         IF p_update_program_table = 'Y' THEN
            l_ptr_prgm_rec.inventory_item_id := l_Item_rec.inventory_item_id;
            l_ptr_prgm_rec.inventory_item_org_id := l_Item_rec.organization_id;
            l_ptr_prgm_rec.object_version_number := x.object_version_number;

            Update_Partner_Program(
                  p_api_version_number         => 1.0
                 ,p_init_msg_list              => FND_API.G_FALSE
                 ,p_commit                     => FND_API.G_FALSE
                 ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
                 ,x_return_status              => l_return_status
                 ,x_msg_count                  => l_msg_count
                 ,x_msg_data                   => l_msg_data
                 ,p_ptr_prgm_rec               => l_ptr_prgm_rec
                 );

            IF l_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF l_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF; -- End of IF p_update_program_table = 'Y'
      END IF; -- End of IF (x.inventory_item_id is null AND x.inventory_item_org_id is null)
   END LOOP;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
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
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END create_inv_item_if_not_exists;

END PV_Partner_Program_PVT;

/
