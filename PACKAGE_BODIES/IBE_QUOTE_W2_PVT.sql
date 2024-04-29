--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_W2_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_W2_PVT" as
/* $Header: IBEVQW2B.pls 120.3.12010000.2 2010/12/13 06:10:31 scnagara ship $ */
-- Start of Comments
-- Package name     : IBE_QUOTE_W2_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments
ROSETTA_G_MISTAKE_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM     NUMBER := 0-1962.0724;

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_QUOTE_W2_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVQW2B.PLS';
l_true VARCHAR2(1) := FND_API.G_TRUE;

PROCEDURE set_control_rec_w(
   p_c_last_update_date        DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag VARCHAR2 := FND_API.G_MISS_CHAR,
   x_control_rec               OUT NOCOPY ASO_Quote_Pub.Control_Rec_Type
)
IS
BEGIN
   IF p_c_last_update_date <> ROSETTA_G_MISTAKE_DATE
   AND p_c_last_update_date <> FND_API.G_MISS_DATE
   AND p_c_last_update_date <> null THEN
      x_control_rec.last_update_date := p_c_last_update_date;
   END IF;

   IF p_c_auto_version_flag <> FND_API.G_MISS_CHAR THEN
      x_control_rec.auto_version_flag := p_c_auto_version_flag;
   END IF;

   IF p_c_pricing_request_type <> FND_API.G_MISS_CHAR THEN
      x_control_rec.pricing_request_type := p_c_pricing_request_type;
   END IF;

   IF p_c_header_pricing_event <> FND_API.G_MISS_CHAR THEN
      x_control_rec.header_pricing_event := p_c_header_pricing_event;
   END IF;

   IF p_c_line_pricing_event <> FND_API.G_MISS_CHAR THEN
      x_control_rec.line_pricing_event := p_c_line_pricing_event;
   END IF;

   IF p_c_cal_tax_flag <> FND_API.G_MISS_CHAR THEN
      x_control_rec.calculate_tax_flag := p_c_cal_tax_flag;
   END IF;

   IF p_c_cal_freight_charge_flag <> FND_API.G_MISS_CHAR THEN
      x_control_rec.calculate_freight_charge_flag := p_c_cal_freight_charge_flag;
   END IF;
END Set_Control_Rec_W;

PROCEDURE set_saveshare2_control_rec_w(
   p_c_last_update_date        DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ssc_delete_source_cart    VARCHAR2 := FND_API.G_TRUE     ,
   p_ssc_combinesameitem       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ssc_operation_code        VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ssc_deactivate_cart       VARCHAR2 := FND_API.G_MISS_CHAR,
   x_saveshare_control_rec     OUT NOCOPY IBE_QUOTE_SAVESHARE_V2_PVT.saveshare_control_rec_type
) is

l_control_rec            ASO_QUOTE_PUB.control_rec_type;
l_saveshare_control_rec  IBE_QUOTE_SAVESHARE_V2_PVT.saveshare_control_rec_type;

BEGIN
  Set_Control_rec_w(
      p_c_LAST_UPDATE_DATE                   =>  p_c_LAST_UPDATE_DATE
     ,p_c_auto_version_flag                  =>  p_c_auto_version_flag
     ,p_c_pricing_request_type               =>  p_c_pricing_request_type
     ,p_c_header_pricing_event               =>  p_c_header_pricing_event
     ,p_c_line_pricing_event                 =>  p_c_line_pricing_event
     ,p_c_CAL_TAX_FLAG                       =>  p_c_CAL_TAX_FLAG
     ,p_c_CAL_FREIGHT_CHARGE_FLAG            =>  p_c_CAL_FREIGHT_CHARGE_FLAG
     ,x_control_rec                          =>  l_control_rec );

  x_saveshare_control_rec.control_rec := l_control_rec;

  x_saveshare_control_rec.delete_source_cart := p_ssc_delete_source_cart;

  IF p_ssc_combinesameitem is not NULL THEN
    x_saveshare_control_rec.combinesameitem := p_ssc_combinesameitem;
  END IF;

  IF p_ssc_operation_code is not NULL THEN
    x_saveshare_control_rec.operation_code := p_ssc_operation_code;
  END IF;

  IF p_ssc_deactivate_cart is not NULL THEN
    x_saveshare_control_rec.deactivate_cart := p_ssc_deactivate_cart;
  END IF;
END;

FUNCTION construct_quote_access_tbl(
  p_qsh_OPERATION_CODE              JTF_VARCHAR2_TABLE_100  :=NULL,
  p_qsh_QUOTE_SHAREE_ID             JTF_NUMBER_TABLE        :=NULL,
  p_qsh_REQUEST_ID                  JTF_NUMBER_TABLE        :=NULL,
  p_qsh_PROGRAM_APPLICATION_ID      JTF_NUMBER_TABLE        :=NULL,
  p_qsh_PROGRAM_ID                  JTF_NUMBER_TABLE        :=NULL,
  p_qsh_PROGRAM_UPDATE_DATE         JTF_DATE_TABLE          :=NULL,
  p_qsh_OBJECT_VERSION_NUMBER       JTF_NUMBER_TABLE        :=NULL,
  p_qsh_CREATED_BY                  JTF_NUMBER_TABLE        :=NULL,
  p_qsh_CREATION_DATE               JTF_DATE_TABLE          :=NULL,
  p_qsh_LAST_UPDATED_BY             JTF_NUMBER_TABLE        :=NULL,
  p_qsh_LAST_UPDATE_DATE            JTF_DATE_TABLE          :=NULL,
  p_qsh_LAST_UPDATE_LOGIN           JTF_NUMBER_TABLE        :=NULL,
  p_qsh_QUOTE_HEADER_ID             JTF_NUMBER_TABLE        :=NULL,
  p_qsh_QUOTE_SHAREE_NUMBER         JTF_NUMBER_TABLE        :=NULL,
  p_qsh_UPDATE_PRIV_TYPE_CODE       JTF_VARCHAR2_TABLE_2000 :=NULL,
  p_qsh_SECURITY_GROUP_ID           JTF_NUMBER_TABLE        :=NULL,
  p_qsh_PARTY_ID                    JTF_NUMBER_TABLE        :=NULL,
  p_qsh_CUST_ACCOUNT_ID             JTF_NUMBER_TABLE        :=NULL,
  p_qsh_START_DATE_ACTIVE           JTF_DATE_TABLE          :=NULL,
  p_qsh_END_DATE_ACTIVE             JTF_DATE_TABLE          :=NULL,
  p_qsh_RECIPIENT_NAME              JTF_VARCHAR2_TABLE_300  :=NULL,
  p_qsh_CONTACT_POINT_ID            JTF_NUMBER_TABLE        :=NULL,
  p_qsh_EMAIL_ADDRESS               JTF_VARCHAR2_TABLE_2000 :=NULL,
  p_qsh_NOTIFY_FLAG                 JTF_VARCHAR2_TABLE_100  :=NULL)
  RETURN IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE IS

  l_quote_access_tbl   IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE;
  l_table_size         NUMBER;

  BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('CONSTRUCT_QUOTE_ACCESS_TABLE:START');
  END IF;
    IF p_qsh_NOTIFY_FLAG IS NOT NULL THEN
      l_table_size := p_qsh_NOTIFY_FLAG.COUNT;
    END IF;

    IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
        IF ((p_qsh_operation_code is not null ) and (p_qsh_operation_code(i) is not null)) THEN
        l_quote_access_tbl(i).operation_code := p_qsh_operation_code(i);
        END IF;

        IF((p_qsh_QUOTE_SHAREE_ID is not null ) and ((p_qsh_QUOTE_SHAREE_ID(i) is not null)
          or (p_qsh_QUOTE_SHAREE_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).QUOTE_SHAREE_ID := p_qsh_QUOTE_SHAREE_ID(i);
        END IF;

        IF	((p_qsh_REQUEST_ID is not null ) and ((p_qsh_REQUEST_ID(i) is not null)
          or (p_qsh_REQUEST_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).REQUEST_ID := p_qsh_REQUEST_ID(i);
        END IF;

        IF	((p_qsh_PROGRAM_APPLICATION_ID is not null ) and ((p_qsh_PROGRAM_APPLICATION_ID(i) is not null)
            or (p_qsh_PROGRAM_APPLICATION_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).PROGRAM_APPLICATION_ID := p_qsh_PROGRAM_APPLICATION_ID(i)	;
        END IF;

        IF	((p_qsh_PROGRAM_ID is not null ) and ((p_qsh_PROGRAM_ID(i) is not null)
            or (p_qsh_PROGRAM_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).PROGRAM_ID := p_qsh_PROGRAM_ID(i);
        END IF;

        IF	((p_qsh_PROGRAM_UPDATE_DATE is not null ) and ((p_qsh_PROGRAM_UPDATE_DATE(i) is not null)
            or (p_qsh_PROGRAM_UPDATE_DATE(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
          l_quote_access_tbl(i).PROGRAM_UPDATE_DATE := p_qsh_PROGRAM_UPDATE_DATE(i);
        END IF;

        IF	((p_qsh_OBJECT_VERSION_NUMBER is not null ) and ((p_qsh_OBJECT_VERSION_NUMBER(i) is not null)
            or (p_qsh_OBJECT_VERSION_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).OBJECT_VERSION_NUMBER := p_qsh_OBJECT_VERSION_NUMBER(i);
        END	IF;

        IF	((p_qsh_CREATED_BY is not null ) and ((p_qsh_CREATED_BY(i) is not null)
          or (p_qsh_CREATED_BY(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).CREATED_BY := p_qsh_CREATED_BY(i);
        END IF;

        IF	((p_qsh_CREATION_DATE is not null ) and ((p_qsh_CREATION_DATE(i) is not null)
          or (p_qsh_CREATION_DATE(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
          l_quote_access_tbl(i).CREATION_DATE := p_qsh_CREATION_DATE(i);
        END IF;

        IF	((p_qsh_LAST_UPDATED_BY is not null ) and ((p_qsh_LAST_UPDATED_BY(i) is not null)
          or (p_qsh_LAST_UPDATED_BY(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).LAST_UPDATED_BY := p_qsh_LAST_UPDATED_BY(i);
        END IF;

        IF	((p_qsh_LAST_UPDATE_DATE is not null ) and ((p_qsh_LAST_UPDATE_DATE(i) is not null)
          or (p_qsh_LAST_UPDATE_DATE(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
          l_quote_access_tbl(i).LAST_UPDATE_DATE := p_qsh_LAST_UPDATE_DATE(i);
        END IF;

        IF	((p_qsh_LAST_UPDATE_LOGIN is not null ) and ((p_qsh_LAST_UPDATE_LOGIN(i) is not null)
          or (p_qsh_LAST_UPDATE_LOGIN(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).LAST_UPDATE_LOGIN := p_qsh_LAST_UPDATE_LOGIN(i);
        END IF;
        IF ((p_qsh_QUOTE_HEADER_ID is not null ) and ((p_qsh_QUOTE_HEADER_ID(i) is not null)
          or (p_qsh_QUOTE_HEADER_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).QUOTE_HEADER_ID := p_qsh_QUOTE_HEADER_ID(i);
        END IF;

        IF ((p_qsh_QUOTE_SHAREE_NUMBER is not null ) and ((p_qsh_QUOTE_SHAREE_NUMBER(i) is not null)
          or (p_qsh_QUOTE_SHAREE_NUMBER(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).QUOTE_SHAREE_NUMBER := p_qsh_QUOTE_SHAREE_NUMBER(i);
        END IF;

        IF	(p_qsh_UPDATE_PRIV_TYPE_CODE is not null )  THEN
          l_quote_access_tbl(i).UPDATE_PRIVILEGE_TYPE_CODE := p_qsh_UPDATE_PRIV_TYPE_CODE(i);
        END IF;

        IF ((p_qsh_SECURITY_GROUP_ID is not null ) and ((p_qsh_SECURITY_GROUP_ID(i) is not null)
          or (p_qsh_SECURITY_GROUP_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).SECURITY_GROUP_ID := p_qsh_SECURITY_GROUP_ID(i);
        END IF;

        IF ((p_qsh_PARTY_ID is not null ) and ((p_qsh_PARTY_ID(i) is not null)
          or (p_qsh_PARTY_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).PARTY_ID := p_qsh_PARTY_ID(i);
        END IF;

        IF ((p_qsh_CUST_ACCOUNT_ID is not null ) and ((p_qsh_CUST_ACCOUNT_ID(i) is not null)
          or (p_qsh_CUST_ACCOUNT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).CUST_ACCOUNT_ID := p_qsh_CUST_ACCOUNT_ID(i);
        END IF;

        IF ((p_qsh_START_DATE_ACTIVE is not null ) and ((p_qsh_START_DATE_ACTIVE(i) is not null)
          or (p_qsh_START_DATE_ACTIVE(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
          l_quote_access_tbl(i).START_DATE_ACTIVE := p_qsh_START_DATE_ACTIVE(i);
        END IF;

        IF ((p_qsh_END_DATE_ACTIVE is not null ) and ((p_qsh_END_DATE_ACTIVE(i) is not null)
          or (p_qsh_END_DATE_ACTIVE(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
          l_quote_access_tbl(i).END_DATE_ACTIVE := p_qsh_END_DATE_ACTIVE(i);
        END IF;

        IF ((p_qsh_RECIPIENT_NAME is not null ) and (p_qsh_RECIPIENT_NAME(i) is not null)) THEN
          l_quote_access_tbl(i).RECIPIENT_NAME := p_qsh_RECIPIENT_NAME(i);
        END IF;

        IF ((p_qsh_EMAIL_ADDRESS is not null ) and (p_qsh_EMAIL_ADDRESS(i) is not null)) THEN
          l_quote_access_tbl(i).EMAIL_CONTACT_ADDRESS := p_qsh_EMAIL_ADDRESS(i);
        END IF;

        IF ((p_qsh_CONTACT_POINT_ID is not null ) and ((p_qsh_CONTACT_POINT_ID(i) is not null)
          or (p_qsh_CONTACT_POINT_ID(i) <> ROSETTA_G_MISS_NUM))) THEN
          l_quote_access_tbl(i).CONTACT_POINT_ID := p_qsh_CONTACT_POINT_ID(i);
        END IF;

--        IF ((p_qsh_NOTIFY_FLAG is not null ) and (p_qsh_NOTIFY_FLAG(i) is not null)) THEN
          l_quote_access_tbl(i).NOTIFY_FLAG := p_qsh_NOTIFY_FLAG(i);
--        END IF;

      END LOOP;
    END IF;
  RETURN L_QUOTE_ACCESS_TBL;
END;



FUNCTION construct_sales_credit_tbl(
   p_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qte_line_index         IN jtf_number_table       := NULL,
   p_sales_credit_id        IN jtf_number_table       := NULL,
   p_creation_date          IN jtf_date_table         := NULL,
   p_created_by             IN jtf_number_table       := NULL,
   p_last_updated_by        IN jtf_number_table       := NULL,
   p_last_update_date       IN jtf_date_table         := NULL,
   p_last_update_login      IN jtf_number_table       := NULL,
   p_request_id             IN jtf_number_table       := NULL,
   p_program_application_id IN jtf_number_table       := NULL,
   p_program_id             IN jtf_number_table       := NULL,
   p_program_update_date    IN jtf_date_table         := NULL,
   p_quote_header_id        IN jtf_number_table       := NULL,
   p_quote_line_id          IN jtf_number_table       := NULL,
   p_percent                IN jtf_number_table       := NULL,
   p_resource_id            IN jtf_number_table       := NULL,
   p_sales_credit_type      IN jtf_varchar2_table_300 := NULL,
   p_resource_group_id      IN jtf_number_table       := NULL,
   p_employee_person_id     IN jtf_number_table       := NULL,
   p_sales_credit_type_id   IN jtf_number_table       := NULL,
   p_attribute_category     IN jtf_varchar2_table_100 := NULL,
   p_attribute1             IN jtf_varchar2_table_300 := NULL,
   p_attribute2             IN jtf_varchar2_table_300 := NULL,
   p_attribute3             IN jtf_varchar2_table_300 := NULL,
   p_attribute4             IN jtf_varchar2_table_300 := NULL,
   p_attribute5             IN jtf_varchar2_table_300 := NULL,
   p_attribute6             IN jtf_varchar2_table_300 := NULL,
   p_attribute7             IN jtf_varchar2_table_300 := NULL,
   p_attribute8             IN jtf_varchar2_table_300 := NULL,
   p_attribute9             IN jtf_varchar2_table_300 := NULL,
   p_attribute10            IN jtf_varchar2_table_300 := NULL,
   p_attribute11            IN jtf_varchar2_table_300 := NULL,
   p_attribute12            IN jtf_varchar2_table_300 := NULL,
   p_attribute13            IN jtf_varchar2_table_300 := NULL,
   p_attribute14            IN jtf_varchar2_table_300 := NULL,
   p_attribute15            IN jtf_varchar2_table_300 := NULL
)
RETURN ASO_Quote_Pub.Sales_Credit_Tbl_Type
IS
   l_sales_credit_tbl ASO_Quote_Pub.Sales_Credit_Tbl_Type;
   l_table_size     PLS_INTEGER := 0;
   i                PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         l_sales_credit_tbl(i).operation_code := p_operation_code(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_sales_credit_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).sales_credit_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).sales_credit_id := p_sales_credit_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_sales_credit_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_sales_credit_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_sales_credit_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_sales_credit_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_sales_credit_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_sales_credit_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_percent(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).percent := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).percent := p_percent(i);
         END IF;
         IF p_resource_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).resource_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).resource_id := p_resource_id(i);
         END IF;

         l_sales_credit_tbl(i).sales_credit_type := p_sales_credit_type(i);

         IF p_resource_group_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).resource_group_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).resource_group_id := p_resource_group_id(i);
         END IF;
         IF p_employee_person_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).employee_person_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).employee_person_id := p_employee_person_id(i);
         END IF;
         IF p_sales_credit_type_id(i)= ROSETTA_G_MISS_NUM THEN
            l_sales_credit_tbl(i).sales_credit_type_id := FND_API.G_MISS_NUM;
         ELSE
            l_sales_credit_tbl(i).sales_credit_type_id := p_sales_credit_type_id(i);
         END IF;

         l_sales_credit_tbl(i).attribute_category_code := p_attribute_category(i);
         l_sales_credit_tbl(i).attribute1 := p_attribute1(i);
         l_sales_credit_tbl(i).attribute2 := p_attribute2(i);
         l_sales_credit_tbl(i).attribute3 := p_attribute3(i);
         l_sales_credit_tbl(i).attribute4 := p_attribute4(i);
         l_sales_credit_tbl(i).attribute5 := p_attribute5(i);
         l_sales_credit_tbl(i).attribute6 := p_attribute6(i);
         l_sales_credit_tbl(i).attribute7 := p_attribute7(i);
         l_sales_credit_tbl(i).attribute8 := p_attribute8(i);
         l_sales_credit_tbl(i).attribute9 := p_attribute9(i);
         l_sales_credit_tbl(i).attribute10 := p_attribute10(i);
         l_sales_credit_tbl(i).attribute11 := p_attribute11(i);
         l_sales_credit_tbl(i).attribute12 := p_attribute12(i);
         l_sales_credit_tbl(i).attribute13 := p_attribute13(i);
         l_sales_credit_tbl(i).attribute14 := p_attribute14(i);
         l_sales_credit_tbl(i).attribute15 := p_attribute15(i);
      END LOOP;

      RETURN l_sales_credit_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_SALES_CREDIT_TBL;
   END IF;
END Construct_Sales_Credit_Tbl;

FUNCTION construct_qte_header_rec(
   p_quote_header_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_creation_date              IN DATE     := FND_API.G_MISS_DATE,
   p_created_by                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_updated_by            IN NUMBER   := FND_API.G_MISS_NUM,
   p_last_update_date           IN DATE     := FND_API.G_MISS_DATE,
   p_last_update_login          IN NUMBER   := FND_API.G_MISS_NUM,
   p_request_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_application_id     IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_id                 IN NUMBER   := FND_API.G_MISS_NUM,
   p_program_update_date        IN DATE     := FND_API.G_MISS_DATE,
   p_org_id                     IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_number               IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_version              IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_status_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_quote_source_code          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_expiration_date      IN DATE     := FND_API.G_MISS_DATE,
   p_price_frozen_date          IN DATE     := FND_API.G_MISS_DATE,
   p_quote_password             IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_original_system_reference  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_cust_account_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_cust_account_id IN NUMBER   := FND_API.G_MISS_NUM,
   p_org_contact_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_party_name                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_party_type                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_person_first_name          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_person_last_name           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_person_middle_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_phone_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_price_list_name            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_currency_code              IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_total_list_price           IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_adjusted_amount      IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_adjusted_percent     IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_tax                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_shipping_charge      IN NUMBER   := FND_API.G_MISS_NUM,
   p_surcharge                  IN NUMBER   := FND_API.G_MISS_NUM,
   p_total_quote_price          IN NUMBER   := FND_API.G_MISS_NUM,
   p_payment_amount             IN NUMBER   := FND_API.G_MISS_NUM,
   p_accounting_rule_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_exchange_rate              IN NUMBER   := FND_API.G_MISS_NUM,
   p_exchange_type_code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_exchange_rate_date         IN DATE     := FND_API.G_MISS_DATE,
   p_quote_category_code        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_status_code          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_status               IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_employee_person_id         IN NUMBER   := FND_API.G_MISS_NUM,
   p_sales_channel_code         IN VARCHAR2 := FND_API.G_MISS_CHAR,
--   p_salesrep_full_name         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute_category         IN VARCHAR2 := FND_API.G_MISS_CHAR,
-- bug 6873117 mgiridha added attribute 16-20
   p_attribute1                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute10                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute11                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute12                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute13                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute14                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute15                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute16                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute17                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute18                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute19                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute2                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute20                IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute3                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute4                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute5                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute6                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute7                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute8                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_attribute9                 IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_contract_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_qte_contract_id            IN NUMBER   := FND_API.G_MISS_NUM,
   p_ffm_request_id             IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_address1        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_address2        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_address3        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_address4        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_city            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cont_first_name IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cont_last_name  IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_cont_mid_name   IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_country_code    IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_country         IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_county          IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_party_id        IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_party_name      IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_party_site_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_invoice_to_postal_code     IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_province        IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoice_to_state           IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_invoicing_rule_id          IN NUMBER   := FND_API.G_MISS_NUM,
   p_marketing_source_code_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_marketing_source_code      IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_marketing_source_name      IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_orig_mktg_source_code_id   IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_type_id              IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_id                   IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_number               IN NUMBER   := FND_API.G_MISS_NUM,
   p_order_type_name            IN VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ordered_date               IN DATE     := FND_API.G_MISS_DATE,
   p_resource_id                IN NUMBER   := FND_API.G_MISS_NUM,
   p_pricing_status_indicator	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
   p_tax_status_indicator		IN	VARCHAR2 := FND_API.G_MISS_CHAR
)
RETURN ASO_Quote_Pub.Qte_Header_Rec_Type
IS
   l_qte_header ASO_Quote_Pub.Qte_Header_Rec_Type;
BEGIN
   IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_header_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_header_id := p_quote_header_id;
   END IF;
   IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.creation_date := FND_API.G_MISS_DATE;
   ELSE
     l_qte_header.creation_date := p_creation_date;
   END IF;
   IF p_created_by= ROSETTA_G_MISS_NUM THEN
      l_qte_header.created_by := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.created_by := p_created_by;
   END IF;
   IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
      l_qte_header.last_updated_by := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.last_updated_by := p_last_updated_by;
   END IF;
   IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.last_update_date := p_last_update_date;
   END IF;
   IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
      l_qte_header.last_update_login := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.last_update_login := p_last_update_login;
   END IF;
   IF p_request_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.request_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.request_id := p_request_id;
   END IF;
   IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.program_application_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.program_application_id := p_program_application_id;
   END IF;
   IF p_program_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.program_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.program_id := p_program_id;
   END IF;
   IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.program_update_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.program_update_date := p_program_update_date;
   END IF;
   IF p_org_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.org_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.org_id := p_org_id;
   END IF;
   l_qte_header.quote_name := p_quote_name;
   IF p_quote_number= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_number := p_quote_number;
   END IF;
   IF p_quote_version= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_version := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_version := p_quote_version;
   END IF;
   IF p_quote_status_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.quote_status_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.quote_status_id := p_quote_status_id;
   END IF;
   l_qte_header.quote_source_code := p_quote_source_code;
   IF p_quote_expiration_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.quote_expiration_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.quote_expiration_date := p_quote_expiration_date;
   END IF;
   IF p_price_frozen_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.price_frozen_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.price_frozen_date := p_price_frozen_date;
   END IF;
   l_qte_header.quote_password := p_quote_password;
   l_qte_header.original_system_reference := p_original_system_reference;
   IF p_party_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.party_id := p_party_id;
   END IF;
   IF p_cust_account_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.cust_account_id := p_cust_account_id;
   END IF;
   IF p_invoice_to_cust_account_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoice_to_cust_account_id := p_invoice_to_cust_account_id;
   END IF;
   IF p_org_contact_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.org_contact_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.org_contact_id := p_org_contact_id;
   END IF;
   l_qte_header.party_name := p_party_name;
   l_qte_header.party_type := p_party_type;
   l_qte_header.person_first_name := p_person_first_name;
   l_qte_header.person_last_name := p_person_last_name;
   l_qte_header.person_middle_name := p_person_middle_name;
   IF p_phone_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.phone_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.phone_id := p_phone_id;
   END IF;
   IF p_price_list_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.price_list_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.price_list_id := p_price_list_id;
   END IF;
   l_qte_header.price_list_name := p_price_list_name;
   l_qte_header.currency_code := p_currency_code;
   IF p_total_list_price= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_list_price := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_list_price := p_total_list_price;
   END IF;
   IF p_total_adjusted_amount= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_adjusted_amount := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_adjusted_amount := p_total_adjusted_amount;
   END IF;
   IF p_total_adjusted_percent= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_adjusted_percent := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_adjusted_percent := p_total_adjusted_percent;
   END IF;
   IF p_total_tax= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_tax := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_tax := p_total_tax;
   END IF;
   IF p_total_shipping_charge= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_shipping_charge := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_shipping_charge := p_total_shipping_charge;
   END IF;
   IF p_surcharge= ROSETTA_G_MISS_NUM THEN
      l_qte_header.surcharge := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.surcharge := p_surcharge;
   END IF;
   IF p_total_quote_price= ROSETTA_G_MISS_NUM THEN
      l_qte_header.total_quote_price := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.total_quote_price := p_total_quote_price;
   END IF;
   IF p_payment_amount= ROSETTA_G_MISS_NUM THEN
      l_qte_header.payment_amount := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.payment_amount := p_payment_amount;
   END IF;
   IF p_accounting_rule_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.accounting_rule_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.accounting_rule_id := p_accounting_rule_id;
   END IF;
   IF p_exchange_rate= ROSETTA_G_MISS_NUM THEN
      l_qte_header.exchange_rate := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.exchange_rate := p_exchange_rate;
   END IF;
   l_qte_header.exchange_type_code := p_exchange_type_code;
   IF p_exchange_rate_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.exchange_rate_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.exchange_rate_date := p_exchange_rate_date;
   END IF;
   l_qte_header.quote_category_code := p_quote_category_code;
   l_qte_header.quote_status_code := p_quote_status_code;
   l_qte_header.quote_status := p_quote_status;
   IF p_employee_person_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.employee_person_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.employee_person_id := p_employee_person_id;
   END IF;
   l_qte_header.sales_channel_code := p_sales_channel_code;
--   l_qte_header.salesrep_full_name := p_salesrep_full_name;
   l_qte_header.attribute_category := p_attribute_category;
-- bug 6873117 mgiridha added attribute 16-20
   l_qte_header.attribute1 := p_attribute1;
   l_qte_header.attribute10 := p_attribute10;
   l_qte_header.attribute11 := p_attribute11;
   l_qte_header.attribute12 := p_attribute12;
   l_qte_header.attribute13 := p_attribute13;
   l_qte_header.attribute14 := p_attribute14;
   l_qte_header.attribute15 := p_attribute15;
   l_qte_header.attribute16 := p_attribute16;
   l_qte_header.attribute17 := p_attribute17;
   l_qte_header.attribute18 := p_attribute18;
   l_qte_header.attribute19 := p_attribute19;
   l_qte_header.attribute2 := p_attribute2;
   l_qte_header.attribute20 := p_attribute20;
   l_qte_header.attribute3 := p_attribute3;
   l_qte_header.attribute4 := p_attribute4;
   l_qte_header.attribute5 := p_attribute5;
   l_qte_header.attribute6 := p_attribute6;
   l_qte_header.attribute7 := p_attribute7;
   l_qte_header.attribute8 := p_attribute8;
   l_qte_header.attribute9 := p_attribute9;
   IF p_contract_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.contract_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.contract_id := p_contract_id;
   END IF;
   IF p_qte_contract_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.qte_contract_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.qte_contract_id := p_qte_contract_id;
   END IF;
   IF p_ffm_request_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.ffm_request_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.ffm_request_id := p_ffm_request_id;
   END IF;
   l_qte_header.invoice_to_address1 := p_invoice_to_address1;
   l_qte_header.invoice_to_address2 := p_invoice_to_address2;
   l_qte_header.invoice_to_address3 := p_invoice_to_address3;
   l_qte_header.invoice_to_address4 := p_invoice_to_address4;
   l_qte_header.invoice_to_city := p_invoice_to_city;
   l_qte_header.invoice_to_contact_first_name := p_invoice_to_cont_first_name;
   l_qte_header.invoice_to_contact_last_name := p_invoice_to_cont_last_name;
   l_qte_header.invoice_to_contact_middle_name := p_invoice_to_cont_mid_name;
   l_qte_header.invoice_to_country_code := p_invoice_to_country_code;
   l_qte_header.invoice_to_country := p_invoice_to_country;
   l_qte_header.invoice_to_county := p_invoice_to_county;
   IF p_invoice_to_party_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoice_to_party_id := p_invoice_to_party_id;
   END IF;
   l_qte_header.invoice_to_party_name := p_invoice_to_party_name;
   IF p_invoice_to_party_site_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoice_to_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoice_to_party_site_id := p_invoice_to_party_site_id;
   END IF;
   l_qte_header.invoice_to_postal_code := p_invoice_to_postal_code;
   l_qte_header.invoice_to_province := p_invoice_to_province;
   l_qte_header.invoice_to_state := p_invoice_to_state;
   IF p_invoicing_rule_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.invoicing_rule_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.invoicing_rule_id := p_invoicing_rule_id;
   END IF;
   IF p_marketing_source_code_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.marketing_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.marketing_source_code_id := p_marketing_source_code_id;
   END IF;
   l_qte_header.marketing_source_code := p_marketing_source_code;
   l_qte_header.marketing_source_name := p_marketing_source_name;
   IF p_orig_mktg_source_code_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.orig_mktg_source_code_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.orig_mktg_source_code_id := p_orig_mktg_source_code_id;
   END IF;
   IF p_order_type_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.order_type_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.order_type_id := p_order_type_id;
   END IF;
   IF p_order_id= ROSETTA_G_MISS_NUM THEN
      l_qte_header.order_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.order_id := p_order_id;
   END IF;
   IF p_order_number= ROSETTA_G_MISS_NUM THEN
      l_qte_header.order_number := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.order_number := p_order_number;
   END IF;
   l_qte_header.order_type_name := p_order_type_name;
   IF p_ordered_date= ROSETTA_G_MISTAKE_DATE THEN
      l_qte_header.ordered_date := FND_API.G_MISS_DATE;
   ELSE
      l_qte_header.ordered_date := p_ordered_date;
   END IF;
   IF p_resource_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.resource_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.resource_id := p_resource_id;
   END IF;
   RETURN l_qte_header;
END Construct_Qte_Header_Rec;


FUNCTION construct_qte_line_tbl(
   p_quote_header_id          IN jtf_number_table       := NULL,
   p_quote_line_id            IN jtf_number_table       := NULL
)
RETURN ASO_Quote_Pub.Qte_Line_Tbl_Type
IS
   l_qte_line_tbl ASO_Quote_Pub.Qte_Line_Tbl_Type;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN
   IF p_quote_header_id IS NOT NULL THEN
      l_table_size := p_quote_header_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         l_qte_line_tbl(i).operation_code := 'UPDATE';
      END LOOP;

      RETURN l_qte_line_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_QTE_LINE_TBL;
   END IF;
END Construct_Qte_Line_Tbl;

PROCEDURE save_share_v2_wrapper
(
   p_api_version_number           IN  NUMBER   := 1                 ,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE    ,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE   ,

   p_c_last_update_date        DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event    VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event      VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode		  IN  VARCHAR2 := 'ENTIRE_QUOTE',	-- change line logic pricing
   p_ssc_delete_source_cart    VARCHAR2 := FND_API.G_TRUE     ,
   p_ssc_combinesameitem       VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ssc_operation_code        VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ssc_deactivate_cart       IN VARCHAR2 := FND_API.G_MISS_CHAR,

   p_q_quote_header_id            IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_creation_date              IN  DATE     := FND_API.G_MISS_DATE,
   p_q_created_by                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_last_updated_by            IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_q_last_update_login          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_request_id                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_program_application_id     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_program_id                 IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_program_update_date        IN  DATE     := FND_API.G_MISS_DATE,
   p_q_org_id                     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_name                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_number               IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_version              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_status_id            IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_quote_source_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_expiration_date      IN  DATE     := FND_API.G_MISS_DATE,
   p_q_price_frozen_date          IN  DATE     := FND_API.G_MISS_DATE,
   p_q_quote_password             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_original_system_reference  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_party_id                   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_cust_account_id            IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_cust_account_id IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_org_contact_id             IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_party_name                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_party_type                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_person_first_name          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_person_last_name           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_person_middle_name         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_phone_id                   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_price_list_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_price_list_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_currency_code              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_total_list_price           IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_adjusted_amount      IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_adjusted_percent     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_tax                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_shipping_charge      IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_surcharge                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_total_quote_price          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_payment_amount             IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_accounting_rule_id         IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_exchange_rate              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_exchange_type_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_exchange_rate_date         IN  DATE     := FND_API.G_MISS_DATE,
   p_q_quote_category_code        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_status_code          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_quote_status               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_employee_person_id         IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_sales_channel_code         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
--   p_q_salesrep_full_name         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute_category         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
-- bug 6873117 added attribute 16-20
   p_q_attribute1                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute10                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute11                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute12                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute13                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute14                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute15                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute16                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute17                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute18                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute19                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute2                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute20                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute3                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute4                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute5                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute6                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute7                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute8                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_attribute9                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_contract_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_qte_contract_id            IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_ffm_request_id             IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_address1        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_address2        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_address3        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_address4        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_city            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_cont_first_name IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_cont_last_name  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_cont_mid_name   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_country_code    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_country         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_county          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_party_id        IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_party_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_party_site_id   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_invoice_to_postal_code     IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_province        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoice_to_state           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_invoicing_rule_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_marketing_source_code_id   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_marketing_source_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_marketing_source_name      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_orig_mktg_source_code_id   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_type_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_id                   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_number               IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_order_type_name            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_ordered_date               IN  DATE     := FND_API.G_MISS_DATE,
   p_q_resource_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   --p_q_save_type                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_pricing_status_indicator   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_tax_status_indicator   	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,

   p_qsh_OPERATION_CODE              JTF_VARCHAR2_TABLE_100  :=NULL,
   p_qsh_QUOTE_SHAREE_ID             JTF_NUMBER_TABLE        :=NULL,
   p_qsh_REQUEST_ID                  JTF_NUMBER_TABLE        :=NULL,
   p_qsh_PROGRAM_APPLICATION_ID      JTF_NUMBER_TABLE        :=NULL,
   p_qsh_PROGRAM_ID                  JTF_NUMBER_TABLE        :=NULL,
   p_qsh_PROGRAM_UPDATE_DATE         JTF_DATE_TABLE          :=NULL,
   p_qsh_OBJECT_VERSION_NUMBER       JTF_NUMBER_TABLE        :=NULL,
   p_qsh_CREATED_BY                  JTF_NUMBER_TABLE        :=NULL,
   p_qsh_CREATION_DATE               JTF_DATE_TABLE          :=NULL,
   p_qsh_LAST_UPDATED_BY             JTF_NUMBER_TABLE        :=NULL,
   p_qsh_LAST_UPDATE_DATE            JTF_DATE_TABLE          :=NULL,
   p_qsh_LAST_UPDATE_LOGIN           JTF_NUMBER_TABLE        :=NULL,
   p_qsh_QUOTE_HEADER_ID             JTF_NUMBER_TABLE        :=NULL,
   p_qsh_QUOTE_SHAREE_NUMBER         JTF_NUMBER_TABLE        :=NULL,
   p_qsh_UPDATE_PRIV_TYPE_CODE       JTF_VARCHAR2_TABLE_2000 :=NULL,
   p_qsh_SECURITY_GROUP_ID           JTF_NUMBER_TABLE        :=NULL,
   p_qsh_PARTY_ID                    JTF_NUMBER_TABLE        :=NULL,
   p_qsh_CUST_ACCOUNT_ID             JTF_NUMBER_TABLE        :=NULL,
   p_qsh_START_DATE_ACTIVE           JTF_DATE_TABLE          :=NULL,
   p_qsh_END_DATE_ACTIVE             JTF_DATE_TABLE          :=NULL,
   p_qsh_RECIPIENT_NAME              JTF_VARCHAR2_TABLE_300  :=NULL,
   p_qsh_CONTACT_POINT_ID            JTF_NUMBER_TABLE        :=NULL,
   p_qsh_EMAIL_ADDRESS               JTF_VARCHAR2_TABLE_2000 :=NULL,
   p_qsh_NOTIFY_FLAG                 JTF_VARCHAR2_TABLE_100  :=NULL,
   p_NOTES                           VARCHAR2                := FND_API.G_MISS_CHAR,
   p_party_id                        NUMBER                  := FND_API.G_MISS_NUM,
   P_CUST_ACCOUNT_ID                 NUMBER                  := FND_API.G_MISS_NUM,
   P_RETRIEVAL_NUMBER                NUMBER                  := FND_API.G_MISS_NUM,
   p_minisite_id                     NUMBER                  := FND_API.G_MISS_NUM,
   P_source_quote_header_id          NUMBER                  := FND_API.G_MISS_NUM,
   P_source_last_update_date        DATE                     := FND_API.G_MISS_DATE,
   p_URL                             VARCHAR2                := FND_API.G_MISS_CHAR,
   x_return_status                OUT NOCOPY VARCHAR2                      ,
   x_msg_count                    OUT NOCOPY NUMBER                        ,
   x_msg_data                     OUT NOCOPY VARCHAR2                     ) is

l_saveshare_control_rec   IBE_QUOTE_SAVESHARE_V2_PVT.SAVESHARE_CONTROL_REC_TYPE;
l_quote_access_tbl        IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_TBL_TYPE
                          := IBE_QUOTE_SAVESHARE_pvt.g_miss_QUOTE_ACCESS_TBL;
l_qte_header_rec          ASO_QUOTE_PUB.qte_header_rec_type;
BEGIN
  Set_Saveshare2_Control_Rec_W(
     p_c_last_update_date        => p_c_last_update_date ,
     p_c_auto_version_flag       => p_c_auto_version_flag,
     p_c_pricing_request_type    => p_c_pricing_request_type,
     p_c_header_pricing_event    => p_c_header_pricing_event,
     p_c_line_pricing_event      => p_c_line_pricing_event,
     p_c_cal_tax_flag            => p_c_cal_tax_flag,
     p_c_cal_freight_charge_flag => p_c_cal_freight_charge_flag ,
     p_ssc_delete_source_cart    => p_ssc_delete_source_cart,
     p_ssc_combinesameitem       => p_ssc_combinesameitem,
     p_ssc_operation_code        => p_ssc_operation_code,
     p_ssc_deactivate_cart       => p_ssc_deactivate_cart,
     x_saveshare_control_rec     => l_saveshare_control_rec) ;

    /*l_qte_header_rec := Construct_Qte_Header_Rec(
      p_quote_header_id            => p_q_quote_header_id,
	  p_last_update_date           => p_q_last_update_date);*/

l_qte_header_rec := Construct_Qte_Header_Rec(
      p_quote_header_id            => p_q_quote_header_id           ,
      p_creation_date              => p_q_creation_date             ,
      p_created_by                 => p_q_created_by                ,
      p_last_updated_by            => p_q_last_updated_by           ,
      p_last_update_date           => p_q_last_update_date          ,
      p_last_update_login          => p_q_last_update_login         ,
      p_request_id                 => p_q_request_id                ,
      p_program_application_id     => p_q_program_application_id    ,
      p_program_id                 => p_q_program_id                ,
      p_program_update_date        => p_q_program_update_date       ,
      p_org_id                     => p_q_org_id                    ,
      p_quote_name                 => p_q_quote_name                ,
      p_quote_number               => p_q_quote_number              ,
      p_quote_version              => p_q_quote_version             ,
      p_quote_status_id            => p_q_quote_status_id           ,
      p_quote_source_code          => p_q_quote_source_code         ,
      p_quote_expiration_date      => p_q_quote_expiration_date     ,
      p_price_frozen_date          => p_q_price_frozen_date         ,
      p_quote_password             => p_q_quote_password            ,
      p_original_system_reference  => p_q_original_system_reference ,
      p_party_id                   => p_q_party_id                  ,
      p_cust_account_id            => p_q_cust_account_id           ,
      p_invoice_to_cust_account_id => p_q_invoice_to_cust_account_id,
      p_org_contact_id             => p_q_org_contact_id            ,
      p_party_name                 => p_q_party_name                ,
      p_party_type                 => p_q_party_type                ,
      p_person_first_name          => p_q_person_first_name         ,
      p_person_last_name           => p_q_person_last_name          ,
      p_person_middle_name         => p_q_person_middle_name        ,
      p_phone_id                   => p_q_phone_id                  ,
      p_price_list_id              => p_q_price_list_id             ,
      p_price_list_name            => p_q_price_list_name           ,
      p_currency_code              => p_q_currency_code             ,
      p_total_list_price           => p_q_total_list_price          ,
      p_total_adjusted_amount      => p_q_total_adjusted_amount     ,
      p_total_adjusted_percent     => p_q_total_adjusted_percent    ,
      p_total_tax                  => p_q_total_tax                 ,
      p_total_shipping_charge      => p_q_total_shipping_charge     ,
      p_surcharge                  => p_q_surcharge                 ,
      p_total_quote_price          => p_q_total_quote_price         ,
      p_payment_amount             => p_q_payment_amount            ,
      p_accounting_rule_id         => p_q_accounting_rule_id        ,
      p_exchange_rate              => p_q_exchange_rate             ,
      p_exchange_type_code         => p_q_exchange_type_code        ,
      p_exchange_rate_date         => p_q_exchange_rate_date        ,
      p_quote_category_code        => p_q_quote_category_code       ,
      p_quote_status_code          => p_q_quote_status_code         ,
      p_quote_status               => p_q_quote_status              ,
      p_employee_person_id         => p_q_employee_person_id        ,
      p_sales_channel_code         => p_q_sales_channel_code        ,
--      p_salesrep_full_name         => p_q_salesrep_full_name        ,
      p_attribute_category         => p_q_attribute_category        ,
-- bug 6873117 mgiridha added attribute 16-20
      p_attribute1                 => p_q_attribute1                ,
      p_attribute10                => p_q_attribute10               ,
      p_attribute11                => p_q_attribute11               ,
      p_attribute12                => p_q_attribute12               ,
      p_attribute13                => p_q_attribute13               ,
      p_attribute14                => p_q_attribute14               ,
      p_attribute15                => p_q_attribute15               ,
      p_attribute16                => p_q_attribute16               ,
      p_attribute17                => p_q_attribute17               ,
      p_attribute18                => p_q_attribute18               ,
      p_attribute19                => p_q_attribute19               ,
      p_attribute2                 => p_q_attribute2                ,
      p_attribute20                => p_q_attribute20               ,
      p_attribute3                 => p_q_attribute3                ,
      p_attribute4                 => p_q_attribute4                ,
      p_attribute5                 => p_q_attribute5                ,
      p_attribute6                 => p_q_attribute6                ,
      p_attribute7                 => p_q_attribute7                ,
      p_attribute8                 => p_q_attribute8                ,
      p_attribute9                 => p_q_attribute9                ,
      p_contract_id                => p_q_contract_id               ,
      p_qte_contract_id            => p_q_qte_contract_id           ,
      p_ffm_request_id             => p_q_ffm_request_id            ,
      p_invoice_to_address1        => p_q_invoice_to_address1       ,
      p_invoice_to_address2        => p_q_invoice_to_address2       ,
      p_invoice_to_address3        => p_q_invoice_to_address3       ,
      p_invoice_to_address4        => p_q_invoice_to_address4       ,
      p_invoice_to_city            => p_q_invoice_to_city           ,
      p_invoice_to_cont_first_name => p_q_invoice_to_cont_first_name,
      p_invoice_to_cont_last_name  => p_q_invoice_to_cont_last_name ,
      p_invoice_to_cont_mid_name   => p_q_invoice_to_cont_mid_name  ,
      p_invoice_to_country_code    => p_q_invoice_to_country_code   ,
      p_invoice_to_country         => p_q_invoice_to_country        ,
      p_invoice_to_county          => p_q_invoice_to_county         ,
      p_invoice_to_party_id        => p_q_invoice_to_party_id       ,
      p_invoice_to_party_name      => p_q_invoice_to_party_name     ,
      p_invoice_to_party_site_id   => p_q_invoice_to_party_site_id  ,
      p_invoice_to_postal_code     => p_q_invoice_to_postal_code    ,
      p_invoice_to_province        => p_q_invoice_to_province       ,
      p_invoice_to_state           => p_q_invoice_to_state          ,
      p_invoicing_rule_id          => p_q_invoicing_rule_id         ,
      p_marketing_source_code_id   => p_q_marketing_source_code_id  ,
      p_marketing_source_code      => p_q_marketing_source_code     ,
      p_marketing_source_name      => p_q_marketing_source_name     ,
      p_orig_mktg_source_code_id   => p_q_orig_mktg_source_code_id  ,
      p_order_type_id              => p_q_order_type_id             ,
      p_order_id                   => p_q_order_id                  ,
      p_order_number               => p_q_order_number              ,
      p_order_type_name            => p_q_order_type_name           ,
      p_ordered_date               => p_q_ordered_date              ,
      p_resource_id                => p_q_resource_id				,
	  p_pricing_status_indicator   =>p_q_pricing_status_indicator	,
	  p_tax_status_indicator	   =>p_q_tax_status_indicator);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('  IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2:START');
  END IF;

  l_quote_access_tbl :=  construct_quote_access_tbl(
   p_qsh_OPERATION_CODE             =>  p_qsh_OPERATION_CODE          ,
   p_qsh_QUOTE_SHAREE_ID            =>  p_qsh_QUOTE_SHAREE_ID         ,
   p_qsh_REQUEST_ID                 =>  p_qsh_REQUEST_ID              ,
   p_qsh_PROGRAM_APPLICATION_ID     =>  p_qsh_PROGRAM_APPLICATION_ID  ,
   p_qsh_PROGRAM_ID                 =>  p_qsh_PROGRAM_ID              ,
   p_qsh_PROGRAM_UPDATE_DATE        =>  p_qsh_PROGRAM_UPDATE_DATE     ,
   p_qsh_OBJECT_VERSION_NUMBER      =>  p_qsh_OBJECT_VERSION_NUMBER   ,
   p_qsh_CREATED_BY                 =>  p_qsh_CREATED_BY              ,
   p_qsh_CREATION_DATE              =>  p_qsh_CREATION_DATE           ,
   p_qsh_LAST_UPDATED_BY            =>  p_qsh_LAST_UPDATED_BY         ,
   p_qsh_LAST_UPDATE_DATE           =>  p_qsh_LAST_UPDATE_DATE        ,
   p_qsh_LAST_UPDATE_LOGIN          =>  p_qsh_LAST_UPDATE_LOGIN       ,
   p_qsh_QUOTE_HEADER_ID            =>  p_qsh_QUOTE_HEADER_ID         ,
   p_qsh_QUOTE_SHAREE_NUMBER        =>  p_qsh_QUOTE_SHAREE_NUMBER     ,
   p_qsh_UPDATE_PRIV_TYPE_CODE      =>  p_qsh_UPDATE_PRIV_TYPE_CODE   ,
   p_qsh_SECURITY_GROUP_ID          =>  p_qsh_SECURITY_GROUP_ID       ,
   p_qsh_PARTY_ID                   =>  p_qsh_PARTY_ID                ,
   p_qsh_CUST_ACCOUNT_ID            =>  p_qsh_CUST_ACCOUNT_ID         ,
   p_qsh_START_DATE_ACTIVE          =>  p_qsh_START_DATE_ACTIVE       ,
   p_qsh_END_DATE_ACTIVE            =>  p_qsh_END_DATE_ACTIVE         ,
   p_qsh_RECIPIENT_NAME             =>  p_qsh_RECIPIENT_NAME          ,
   p_qsh_CONTACT_POINT_ID           =>  p_qsh_CONTACT_POINT_ID        ,
   p_qsh_EMAIL_ADDRESS              =>  p_qsh_EMAIL_ADDRESS           ,
   p_qsh_NOTIFY_FLAG                =>  p_qsh_NOTIFY_FLAG             );

  IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2
        (P_saveshare_control_rec   => l_saveshare_control_rec,
         P_party_id                => P_PARTY_ID,
         P_cust_account_id         => P_CUST_ACCOUNT_ID,
         P_retrieval_number        => P_retrieval_number,
         P_Quote_header_rec        => L_QTE_HEADER_REC,
         P_quote_access_tbl        => L_quote_access_tbl,
         P_source_quote_header_id  => P_source_quote_header_id,
         P_source_last_update_date => P_source_last_update_date ,
         p_minisite_id             => p_minisite_id,
         p_URL                     => p_URL,
         p_notes                   => p_notes,
         p_api_version             => p_api_version_number,
         p_init_msg_list           => p_init_msg_list,
         p_commit                  => p_commit,
         x_return_status           => x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data) ;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('  IBE_QUOTE_SAVESHARE_V2_PVT.save_share_v2:END');
  END IF;
END;

END IBE_Quote_W2_PVT;

/
