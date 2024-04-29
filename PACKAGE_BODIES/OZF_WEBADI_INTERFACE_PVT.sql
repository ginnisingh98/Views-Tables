--------------------------------------------------------
--  DDL for Package Body OZF_WEBADI_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_WEBADI_INTERFACE_PVT" as
/* $Header: ozfadiwb.pls 120.8.12010000.2 2010/03/03 08:20:36 rsatyava ship $ */
-- Start of Comments
-- Package name     : ozf_webadi_interface_pvt
-- Purpose          :
-- History          : 09-OCT-2003  vansub   Created
-- NOTE             :
-- End of Comments

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'OZF_WEBADI_INTERFACE_PVT';
G_FILE_NAME  CONSTANT VARCHAR2(12) := 'ozfadiwb.pls';

-- All of the parameters must be capital letter, WebADI enforces it to be in caps

PROCEDURE CODE_CONVERSION_WEBADI
(
   P_PARTY_ID               IN NUMBER,
   P_CUST_ACCOUNT_ID        IN NUMBER,
   P_CODE_CONVERSION_TYPE   IN VARCHAR2,
   P_EXTERNAL_CODE          IN VARCHAR2,
   P_INTERNAL_CODE          IN VARCHAR2,
   P_DESCRIPTION            IN VARCHAR2,
   P_START_DATE_ACTIVE      IN DATE,
   P_END_DATE_ACTIVE        IN DATE,
   P_ORG_ID                 IN NUMBER
)
IS

   l_api_name                   CONSTANT VARCHAR2(30) := 'code_conversion_webadi';
   l_api_version_number         CONSTANT NUMBER   := 1.0;
   l_code_conversion_id_tbl     JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_code_conversion_rec        OZF_CODE_CONVERSION_PVT.CODE_CONVERSION_REC_TYPE := ozf_code_conversion_pvt.g_miss_code_conversion_rec;
   l_code_conversion_tbl        OZF_CODE_CONVERSION_PVT.CODE_CONVERSION_TBL_TYPE := ozf_code_conversion_pvt.g_miss_code_conversion_tbl;
   l_error                      VARCHAR2(30) := 'OZF_WEBADI_ERROR';
   l_object_version_no_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   x_msg_count                  NUMBER;
   x_msg_data                   VARCHAR2(2000);
   x_return_status              VARCHAR(3);
   l_message                    VARCHAR2(32000);

-- Exceptions
 ozf_webadi_error          EXCEPTION;

 CURSOR csr_code_conversion(cv_external_code VARCHAR2
                             ,cv_party_id      NUMBER
                             ,cv_account_id    NUMBER
   )
   IS
   SELECT code_conversion_id,
          object_version_number,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          org_id,
          party_id,
          cust_account_id,
          code_conversion_type,
          external_code,
          internal_code,
          description,
          start_date_active,
          end_date_active,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          security_group_id,
          org_id
   FROM   ozf_code_conversions_all
   WHERE  external_code = cv_external_code
   AND    cv_party_id IS NULL
   AND    cv_account_id IS NULL
   UNION ALL
   SELECT code_conversion_id,
          object_version_number,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          org_id,
          party_id,
          cust_account_id,
          code_conversion_type,
          external_code,
          internal_code,
          description,
          start_date_active,
          end_date_active,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          security_group_id,
          org_id
   FROM   ozf_code_conversions_all
   WHERE  external_code = cv_external_code
   AND    party_id = cv_party_id
   AND    cv_party_id IS NOT NULL
   AND    cv_account_id IS NULL
   UNION ALL
   SELECT code_conversion_id,
          object_version_number,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login,
          org_id,
          party_id,
          cust_account_id,
          code_conversion_type,
          external_code,
          internal_code,
          description,
          start_date_active,
          end_date_active,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          security_group_id,
          org_id
   FROM   ozf_code_conversions_all
   WHERE  external_code = cv_external_code
   AND    party_id = cv_party_id
   AND    cust_account_id = cv_account_id
   AND    cv_party_id IS NOT NULL
   AND    cv_account_id IS NOT NULL;


BEGIN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
        OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;

     OPEN  csr_code_conversion(p_external_code
                             , p_party_id
                             , p_cust_account_id);
     FETCH csr_code_conversion
     INTO  l_code_conversion_rec.code_conversion_id
           ,l_code_conversion_rec.object_version_number
           ,l_code_conversion_rec.last_update_date
           ,l_code_conversion_rec.last_updated_by
           ,l_code_conversion_rec.creation_date
           ,l_code_conversion_rec.created_by
           ,l_code_conversion_rec.last_update_login
           ,l_code_conversion_rec.org_id
           ,l_code_conversion_rec.party_id
           ,l_code_conversion_rec.cust_account_id
           ,l_code_conversion_rec.code_conversion_type
           ,l_code_conversion_rec.external_code
           ,l_code_conversion_rec.internal_code
           ,l_code_conversion_rec.description
           ,l_code_conversion_rec.start_date_active
           ,l_code_conversion_rec.end_date_active
           ,l_code_conversion_rec.attribute_category
           ,l_code_conversion_rec.attribute1
           ,l_code_conversion_rec.attribute2
           ,l_code_conversion_rec.attribute3
           ,l_code_conversion_rec.attribute4
           ,l_code_conversion_rec.attribute5
           ,l_code_conversion_rec.attribute6
           ,l_code_conversion_rec.attribute7
           ,l_code_conversion_rec.attribute8
           ,l_code_conversion_rec.attribute9
           ,l_code_conversion_rec.attribute10
           ,l_code_conversion_rec.attribute11
           ,l_code_conversion_rec.attribute12
           ,l_code_conversion_rec.attribute13
           ,l_code_conversion_rec.attribute14
           ,l_code_conversion_rec.attribute15
           ,l_code_conversion_rec.security_group_id
           ,l_code_conversion_rec.org_id;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
         OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'fetched db rec');
      END IF;

      l_code_conversion_tbl := ozf_code_conversion_pvt.code_conversion_tbl_type();

      l_code_conversion_tbl.extend(1);

      l_code_conversion_tbl(1) := l_code_conversion_rec;
        IF l_code_conversion_rec.internal_code IS NOT NULL  AND
           l_code_conversion_rec.internal_code <> P_internal_code
        THEN
            l_message := 'Cannot update internal code';
            raise_application_error( -20000, l_message);
        END IF;


     -- Update End date only when it is NUll or a future date
        IF  l_code_conversion_Rec.End_Date_Active IS NOT NULL
        AND Trunc(l_code_conversion_Rec.End_Date_Active) < Trunc(P_End_Date_Active)
        AND P_End_Date_Active < SYSDATE THEN
              l_message :=  'End date Active cannot be updated';
              raise_application_error( -20000, l_message);
        END IF;

     ---Update not allowed for  Start Date when start date is earlier than current date
        IF  trunc(l_code_conversion_Rec.Start_Date_Active) <> trunc(P_Start_Date_Active)
        THEN
            IF  l_code_conversion_Rec.end_date_active <  p_Start_Date_Active THEN
               l_message :=  'Cannot update an end dated code conversion map';
               raise_application_error( -20000, l_message);
            END IF;

       END IF;

       IF p_end_date_active IS NOT NULL AND p_end_date_active  <  p_Start_Date_Active THEN
          l_message :=  'End Date Active Cannot be less than start date active';
          raise_application_error( -20000, l_message);
       END IF;

     -- Update not allowed for External Code
        IF l_code_conversion_Rec.external_Code IS NOT NULL AND
           l_code_conversion_Rec.external_Code <> P_external_Code
        THEN
              l_message :=  'External Code Cannot be Updated';
              raise_application_error( -20000, l_message);
        END IF;

        IF  l_code_conversion_Rec.Start_Date_Active IS NULL THEN
            IF  p_Start_Date_Active < TRUNC(SYSDATE) THEN
             l_message :=  'Start date Active cannot be earlier than current date';
             raise_application_error( -20000, l_message);
            END IF;
        ELSE
            IF trunc(l_code_conversion_Rec.Start_Date_Active) <> trunc(P_Start_Date_Active) THEN
               l_message :=  'Start date Active cannot be earlier than current date';
               raise_application_error( -20000, l_message);
            END IF;
        END IF;


      l_code_conversion_tbl(1).code_conversion_type   := p_code_conversion_type;
      l_code_conversion_tbl(1).description            := p_description;
      l_code_conversion_tbl(1).start_date_active      := p_start_date_active;
      l_code_conversion_tbl(1).end_date_active        := p_end_date_active;
      l_code_conversion_tbl(1).party_id               := p_party_id;
      l_code_conversion_tbl(1).cust_account_id        := p_cust_account_id;
      l_code_conversion_tbl(1).org_id                 := p_org_id;

      --insert into test_rb values('Description: ' || p_description );


      IF ( csr_code_conversion%NOTFOUND) THEN

         IF  p_external_code IS NOT NULL
         THEN


             l_code_conversion_tbl(1).external_code      := p_external_code;
             l_code_conversion_tbl(1).internal_code      := p_internal_code;

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
                OZF_UTILITY_PVT.debug_message('external code '|| p_external_code);
                OZF_UTILITY_PVT.debug_message('start date active '|| p_start_date_active);
                OZF_UTILITY_PVT.debug_message('calling create code conversion ');
             END IF;

               OZF_CODE_CONVERSION_PVT.create_code_conversion
               (
                p_api_version_number         =>  1.0 ,
                p_init_msg_list              =>  FND_API.G_FALSE,
                p_commit                     =>  FND_API.G_FALSE,
                p_validation_level           =>  FND_API.G_VALID_LEVEL_FULL,
                x_return_status              =>  x_return_Status,
                x_msg_count                  =>  x_msg_Count,
                x_msg_data                   =>  x_msg_Data,
                p_code_conversion_tbl        =>  l_code_conversion_tbl,
                x_code_conversion_id_tbl     =>  l_code_conversion_id_tbl);

             IF x_return_Status = FND_API.G_RET_STS_ERROR THEN
                IF fnd_msg_pub.Check_Msg_Level(fnd_msg_pub.G_MSG_LVL_ERROR) THEN
                   l_message := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                   raise_application_error( -20000, l_message);
                END IF;
             ELSIF x_return_Status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   fnd_message.set_name ('OZF', 'OZF_WADI_CREATE_ERROR');
                   l_message :=  fnd_message.get();
                   raise_application_error( -20000, l_message);
             END IF;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
                FOR i IN 1 .. l_code_conversion_id_tbl.count
                LOOP
                   OZF_UTILITY_PVT.debug_message('Code Conversion ID ' || l_code_conversion_id_tbl(i) );
                END LOOP;
             END IF;
         ELSE
            fnd_message.set_name ('OZF', 'OZF_REQ_PARAM_MISSING');
            l_message :=  fnd_message.get();
            raise_application_error( -20000, l_message);
        END IF;

     ELSE
            OZF_CODE_CONVERSION_PVT.update_code_conversion
           (
              p_api_version_number         =>  1.0 ,
              p_init_msg_list              =>  FND_API.G_FALSE,
              p_commit                     =>  FND_API.G_FALSE,
              p_validation_level           =>  FND_API.G_VALID_LEVEL_FULL,
              x_return_status              =>  x_return_Status,
              x_msg_count                  =>  x_msg_Count,
              x_msg_data                   =>  x_msg_Data,
              p_code_conversion_tbl        =>  l_code_conversion_tbl,
              x_object_version_number      =>  l_object_version_no_tbl
            );

 --            OZF_UTILITY_PVT.debug_message('after  update code conversion'||x_msg_Count);

             IF x_return_Status = FND_API.G_RET_STS_ERROR THEN
                   l_message := fnd_msg_pub.get(p_encoded => fnd_api.g_true);
                   OZF_UTILITY_PVT.debug_message('Message '||l_message);

                   IF length( l_message) > 30 THEN
                      l_message := substr(l_message,1,30);
                   END IF;
                   raise_application_error( -20000, l_message);
             ELSIF x_return_Status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   fnd_message.set_name ('OZF', 'OZF_WADI_UPDATE_ERROR');
                   l_message :=  fnd_message.get();
                   raise_application_error( -20000, l_message);
             END IF;

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low) THEN
              FOR i IN 1 .. l_object_version_no_tbl.count
              LOOP
                 OZF_UTILITY_PVT.debug_message('Object Version Number ' || l_object_version_no_tbl(i) );
              END LOOP;
           END IF;
     END IF;

    CLOSE csr_code_conversion;

--commit;

EXCEPTION
   WHEN ozf_webadi_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
/*      IF length( l_message) > 30 THEN
         l_message := substr(l_message,1,30);
      END IF;      */
      raise_application_error( -20000, l_message);
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF length( SQLERRM) > 30 THEN
         ozf_utility_pvt.debug_message(substr(SQLERRM,12,30));
         fnd_message.set_name ('OZF', substr(SQLERRM,12,30));
      ELSE
         fnd_message.set_name ('OZF', SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
      IF length( SQLERRM) > 30 THEN
         ozf_utility_pvt.debug_message(substr(SQLERRM,12,30));
         fnd_message.set_name ('OZF', substr(SQLERRM,12,30));
      ELSE
         fnd_message.set_name ('OZF', SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END CODE_CONVERSION_WEBADI;


PROCEDURE RESALE_WEBADI
(
  P_BATCH_TYPE                   IN VARCHAR2,
  P_BATCH_NUMBER                 IN VARCHAR2,
  P_BATCH_COUNT                  IN NUMBER,
  P_REPORT_DATE                  IN DATE,
  P_REPORT_START_DATE            IN DATE,
  P_REPORT_END_DATE              IN DATE,
  P_DATA_SOURCE_CODE             IN VARCHAR2,
  P_REFERENCE_TYPE               IN VARCHAR2,
  P_REFERENCE_NUMBER             IN VARCHAR2,
  P_YEAR                         IN NUMBER,
  P_MONTH                        IN NUMBER,
  P_COMMENTS                     IN VARCHAR2,
  P_PARTNER_CLAIM_NUMBER         IN VARCHAR2,
  P_TRANSACTION_PURPOSE          IN VARCHAR2,
  P_TRANSACTION_TYPE             IN VARCHAR2,
  P_PARTNER_TYPE                 IN VARCHAR2,
  P_PARTNER_PARTY_ID             IN NUMBER,
  P_PARTNER_CUST_ACCOUNT_ID      IN NUMBER,
  P_PARTNER_SITE_ID              IN NUMBER,
  P_PARTNER_CONTACT_NAME         IN VARCHAR2,
  P_PARTNER_EMAIL                IN VARCHAR2,
  P_PARTNER_PHONE                IN VARCHAR2,
  P_PARTNER_FAX                  IN VARCHAR2,
  P_CURRENCY                     IN VARCHAR2,
  P_CLAIMED_AMOUNT               IN NUMBER,
  P_CREDIT_CODE                  IN VARCHAR2,
  P_BATCH_CREDIT_ADVICE_DATE     IN DATE,
  P_RESALE_TRANSFER_TYPE         IN VARCHAR2,
  P_TRANSFER_MVMT_TYPE           IN VARCHAR2,
  P_TRANSFER_DATE                IN DATE,
  P_TRACING_FLAG                 IN VARCHAR2,
  P_SHIP_FROM_PARTY_NAME         IN VARCHAR2,
  P_SHIP_FROM_ADDRESS            IN VARCHAR2,
  P_SHIP_FROM_LOCATION           IN VARCHAR2,
  P_SHIP_FROM_CITY               IN VARCHAR2,
  P_SHIP_FROM_STATE              IN VARCHAR2,
  P_SHIP_FROM_POSTAL_CODE        IN VARCHAR2,
  P_SHIP_FROM_COUNTRY            IN VARCHAR2,
  P_SHIP_FROM_CONTACT_NAME       IN VARCHAR2,
  P_SHIP_FROM_PHONE              IN VARCHAR2,
  P_SHIP_FROM_FAX                IN VARCHAR2,
  P_SHIP_FROM_EMAIL              IN VARCHAR2,
  P_SOLD_FROM_PARTY_NAME         IN VARCHAR2,
  P_SOLD_FROM_ADDRESS            IN VARCHAR2,
  P_SOLD_FROM_LOCATION           IN VARCHAR2,
  P_SOLD_FROM_CITY               IN VARCHAR2,
  P_SOLD_FROM_STATE              IN VARCHAR2,
  P_SOLD_FROM_POSTAL_CODE        IN VARCHAR2,
  P_SOLD_FROM_COUNTRY            IN VARCHAR2,
  P_SOLD_FROM_CONTACT_NAME       IN VARCHAR2,
  P_SOLD_FROM_PHONE              IN VARCHAR2,
  P_SOLD_FROM_FAX                IN VARCHAR2,
  P_SOLD_FROM_EMAIL              IN VARCHAR2,
  P_BILL_TO_PARTY_NAME           IN VARCHAR2,
  P_BILL_TO_DUNS_NUMBER          IN VARCHAR2,
  P_BILL_TO_ADDRESS              IN VARCHAR2,
  P_BILL_TO_LOCATION             IN VARCHAR2,
  P_BILL_TO_CITY                 IN VARCHAR2,
  P_BILL_TO_STATE                IN VARCHAR2,
  P_BILL_TO_POSTAL_CODE          IN VARCHAR2,
  P_BILL_TO_COUNTRY              IN VARCHAR2,
  P_BILL_TO_CONTACT_NAME         IN VARCHAR2,
  P_BILL_TO_PHONE                IN VARCHAR2,
  P_BILL_TO_FAX                  IN VARCHAR2,
  P_BILL_TO_EMAIL                IN VARCHAR2,
  P_SHIP_TO_PARTY_NAME           IN VARCHAR2,
  P_SHIP_TO_DUNS_NUMBER          IN VARCHAR2,
  P_SHIP_TO_ADDRESS              IN VARCHAR2,
  P_SHIP_TO_LOCATION             IN VARCHAR2,
  P_SHIP_TO_CITY                 IN VARCHAR2,
  P_SHIP_TO_STATE                IN VARCHAR2,
  P_SHIP_TO_POSTAL_CODE          IN VARCHAR2,
  P_SHIP_TO_COUNTRY              IN VARCHAR2,
  P_SHIP_TO_CONTACT_NAME         IN VARCHAR2,
  P_SHIP_TO_PHONE                IN VARCHAR2,
  P_SHIP_TO_FAX                  IN VARCHAR2,
  P_SHIP_TO_EMAIL                IN VARCHAR2,
  P_END_CUST_PARTY_NAME          IN VARCHAR2,
  P_END_CUST_DUNS_NUMBER         IN VARCHAR2,
  P_END_CUST_ADDRESS             IN VARCHAR2,
  P_END_CUST_LOCATION            IN VARCHAR2,
  P_END_CUST_SITE_USE_CODE       IN VARCHAR2,
  P_END_CUST_CITY                IN VARCHAR2,
  P_END_CUST_STATE               IN VARCHAR2,
  P_END_CUST_POSTAL_CODE         IN VARCHAR2,
  P_END_CUST_COUNTRY             IN VARCHAR2,
  P_END_CUST_CONTACT_NAME        IN VARCHAR2,
  P_END_CUST_PHONE               IN VARCHAR2,
  P_END_CUST_FAX                 IN VARCHAR2,
  P_END_CUST_EMAIL               IN VARCHAR2,
  P_ORIG_SYSTEM_REFERENCE        IN VARCHAR2,
  P_ORIG_SYSTEM_LINE_REFERENCE   IN VARCHAR2,
  P_ORIG_SYSTEM_CURRENCY_CODE    IN VARCHAR2,
  P_ORIG_SYSTEM_SELLING_PRICE    IN NUMBER,
  P_ORIG_SYSTEM_QUANTITY         IN NUMBER,
  P_ORIG_SYSTEM_UOM              IN VARCHAR2,
  P_ORIG_SYSTEM_PURCHASE_UOM     IN VARCHAR2,
  P_ORIG_SYSTEM_PURCHASE_CURR    IN VARCHAR2,
  P_ORIG_SYSTEM_PURCHASE_PRICE   IN NUMBER,
  P_ORIG_SYSTEM_PURCHASE_QUANT   IN NUMBER,
  P_ORIG_SYSTEM_AGREEMENT_UOM    IN VARCHAR2,
  P_ORIG_SYSTEM_AGREEMENT_NAME   IN VARCHAR2,
  P_ORIG_SYSTEM_AGREEMENT_TYPE   IN VARCHAR2,
  P_ORIG_SYSTEM_AGREEMENT_STATUS IN VARCHAR2,
  P_ORIG_SYSTEM_AGREEMENT_CURR   IN VARCHAR2,
  P_ORIG_SYSTEM_AGREEMENT_PRICE  IN NUMBER,
  P_ORIG_SYSTEM_AGREEMENT_QUANT  IN NUMBER,
  P_ORIG_SYSTEM_ITEM_NUMBER      IN VARCHAR2,
  P_ORDER_TYPE                   IN VARCHAR2,
  P_ORDER_CATEGORY               IN VARCHAR2,
  P_AGREEMENT_TYPE               IN VARCHAR2,
  P_AGREEMENT_NAME               IN VARCHAR2,
  P_AGREEMENT_PRICE              IN NUMBER,
  P_AGREEMENT_UOM                IN VARCHAR2,
  P_LINE_CURRENCY                IN VARCHAR2,
  P_EXCHANGE_RATE                IN VARCHAR2,
  P_EXCHANGE_RATE_TYPE           IN VARCHAR2,
  P_EXCHANGE_RATE_DATE           IN DATE,
  P_PO_NUMBER                    IN VARCHAR2,
  P_PO_RELEASE_NUMBER            IN VARCHAR2,
  P_PO_TYPE                      IN VARCHAR2,
  P_INVOICE_NUMBER               IN VARCHAR2,
  P_DATE_INVOICED                IN DATE,
  P_ORDER_NUMBER                 IN VARCHAR2,
  P_DATE_ORDERED                 IN DATE,
  P_DATE_SHIPPED                 IN DATE,
  P_LINE_CLAIMED_AMOUNT          IN NUMBER,
  P_PURCHASE_PRICE               IN NUMBER,
  P_PURCHASE_UOM                 IN VARCHAR2,
  P_SELLING_PRICE                IN NUMBER,
  P_UOM                          IN VARCHAR2,
  P_QUANTITY                     IN NUMBER,
  P_LINE_CREDIT_CODE             IN VARCHAR2,
  P_UPC_CODE                     IN VARCHAR2,
  P_ITEM_DESCRIPTION             IN VARCHAR2,
  P_RESPONSE_TYPE                IN VARCHAR2,
  P_RESPONSE_CODE                IN VARCHAR2,
  P_FOLLOWUP_ACTION_CODE         IN VARCHAR2,
  P_REJECT_REASON_CODE           IN VARCHAR2,
  P_CREDIT_ADVICE_DATE           IN VARCHAR2,
  P_ATTRIBUTE_CATEGORY           IN VARCHAR2,
  P_ATTRIBUTE1                   IN VARCHAR2,
  P_ATTRIBUTE2                   IN VARCHAR2,
  P_ATTRIBUTE3                   IN VARCHAR2,
  P_ATTRIBUTE4                   IN VARCHAR2,
  P_ATTRIBUTE5                   IN VARCHAR2,
  P_ATTRIBUTE6                   IN VARCHAR2,
  P_ATTRIBUTE7                   IN VARCHAR2,
  P_ATTRIBUTE8                   IN VARCHAR2,
  P_ATTRIBUTE9                   IN VARCHAR2,
  P_ATTRIBUTE10                  IN VARCHAR2,
  P_ATTRIBUTE11                  IN VARCHAR2,
  P_ATTRIBUTE12                  IN VARCHAR2,
  P_ATTRIBUTE13                  IN VARCHAR2,
  P_ATTRIBUTE14                  IN VARCHAR2,
  P_ATTRIBUTE15                  IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT1      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT2      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT3      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT4      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT5      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT6      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT7      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT8      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT9      IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT10     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT11     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT12     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT13     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT14     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT15     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT16     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT17     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT18     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT19     IN VARCHAR2,
  P_INVENTORY_ITEM_SEGMENT20     IN VARCHAR2,
  P_HEADER_ATTRIBUTE_CATEGORY    IN VARCHAR2,
  P_HEADER_ATTRIBUTE1            IN VARCHAR2,
  P_HEADER_ATTRIBUTE2            IN VARCHAR2,
  P_HEADER_ATTRIBUTE3            IN VARCHAR2,
  P_HEADER_ATTRIBUTE4            IN VARCHAR2,
  P_HEADER_ATTRIBUTE5            IN VARCHAR2,
  P_HEADER_ATTRIBUTE6            IN VARCHAR2,
  P_HEADER_ATTRIBUTE7            IN VARCHAR2,
  P_HEADER_ATTRIBUTE8            IN VARCHAR2,
  P_HEADER_ATTRIBUTE9            IN VARCHAR2,
  P_HEADER_ATTRIBUTE10           IN VARCHAR2,
  P_HEADER_ATTRIBUTE11           IN VARCHAR2,
  P_HEADER_ATTRIBUTE12           IN VARCHAR2,
  P_HEADER_ATTRIBUTE13           IN VARCHAR2,
  P_HEADER_ATTRIBUTE14           IN VARCHAR2,
  P_HEADER_ATTRIBUTE15           IN VARCHAR2,
  P_LINE_ATTRIBUTE_CATEGORY      IN VARCHAR2,
  P_LINE_ATTRIBUTE1              IN VARCHAR2,
  P_LINE_ATTRIBUTE2              IN VARCHAR2,
  P_LINE_ATTRIBUTE3              IN VARCHAR2,
  P_LINE_ATTRIBUTE4              IN VARCHAR2,
  P_LINE_ATTRIBUTE5              IN VARCHAR2,
  P_LINE_ATTRIBUTE6              IN VARCHAR2,
  P_LINE_ATTRIBUTE7              IN VARCHAR2,
  P_LINE_ATTRIBUTE8              IN VARCHAR2,
  P_LINE_ATTRIBUTE9              IN VARCHAR2,
  P_LINE_ATTRIBUTE10             IN VARCHAR2,
  P_LINE_ATTRIBUTE11             IN VARCHAR2,
  P_LINE_ATTRIBUTE12             IN VARCHAR2,
  P_LINE_ATTRIBUTE13             IN VARCHAR2,
  P_LINE_ATTRIBUTE14             IN VARCHAR2,
  P_LINE_ATTRIBUTE15             IN VARCHAR2,
  P_RESALE_LINE_INT_ID           IN NUMBER,
  X_RETURN_STATUS                OUT NOCOPY VARCHAR2,
  P_BILL_TO_PARTY                IN VARCHAR2,
  P_BILL_TO_PARTY_SITE           IN VARCHAR2,
  P_SHIP_TO_PARTY                IN VARCHAR2,
  P_SHIP_TO_PARTY_SITE           IN VARCHAR2,
  P_ORIG_BILL_TO_PARTY           IN VARCHAR2,
  P_ORIG_BILL_TO_PARTY_SITE      IN VARCHAR2,
  P_ORIG_SHIP_TO_PARTY           IN VARCHAR2,
  P_ORIG_SHIP_TO_PARTY_SITE      IN VARCHAR2,
  P_ORIG_END_CUST_PARTY          IN VARCHAR2,
  P_ORIG_END_CUST_PARTY_SITE     IN VARCHAR2,
  P_ORG_ID                       IN VARCHAR2,
  P_LINE_STATUS                  IN VARCHAR2,
  P_DISPUTE_CODE                 IN VARCHAR2

)
 IS

 l_api_name                   CONSTANT VARCHAR2(30) := 'RESALE_WEBADI';
 l_api_version_number         CONSTANT NUMBER   := 1.0;


 CURSOR c_chk_record_exists(pc_batch_number VARCHAR2)
 IS
 SELECT COUNT(batch_number)
 FROM   ozf_resale_batches_all
 WHERE  batch_number    = pc_batch_number;


 CURSOR c_chk_line_exists(pc_batch_number VARCHAR2)
 IS
 SELECT COUNT(b.resale_batch_id),a.status_code
 FROM   ozf_resale_batches_all a, ozf_resale_lines_int_all b
 WHERE  a.resale_batch_id = b.resale_batch_id
 AND    a.batch_number    = pc_batch_number
 GROUP BY a.resale_batch_id, a.status_code;


 CURSOR c_get_update_record(pc_batch_number VARCHAR2, pc_resale_line_int_id NUMBER)
 IS
 SELECT a.resale_batch_id, a.object_version_number,
        b.object_version_number
 FROM   ozf_resale_batches_all a, ozf_resale_lines_int_all b
 WHERE  a.resale_batch_id = b.resale_batch_id
 AND    a.batch_number    = pc_batch_number
 AND    b.resale_line_int_id = pc_resale_line_int_id;

 CURSOR C
 IS
 SELECT value
 FROM   v$parameter
 WHERE  name = 'utl_file_dir';

 CURSOR csr_get_party_site_id(cv_site_number IN VARCHAR2) IS
    SELECT party_site_id
    FROM hz_party_sites
    WHERE party_site_number = cv_site_number;


 l_batch_count             NUMBER := 0;
 l_resale_batch_id         NUMBER;
 l_resale_line_int_id      NUMBER;
 l_resale_line_batch_id    NUMBER;
 l_batch_number            VARCHAR2(3200);
 l_batch_insert_flag       VARCHAR2(1);
 l_batch_update_flag       VARCHAR2(1);
 l_batch_obj               NUMBER := 1;
 l_line_obj                NUMBER := 1;
 l_line_count              NUMBER := 0;
 l_amount                  NUMBER := 0;
 l_prev_batch_number       VARCHAR2(3200);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(32000);
 l_credit_code             VARCHAR2(10);
 l_status_code             VARCHAR2(30);
 l_line_status             VARCHAR2(30);
 l_batch_status            VARCHAR2(30);

 l_resale_batch_rec        ozf_resale_batches_all%rowtype;
 l_int_line_tbl            ozf_pre_process_pvt.resale_line_int_tbl_type := ozf_pre_process_pvt.resale_line_int_tbl_type();
 l_resale_line_int_id_tbl  JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
 l_object_version_no_tbl   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
 l_total_claimed_amount    NUMBER := 0;
 j                         NUMBER;
 l_file                    utl_file.file_type;
 l_file_dir                VARCHAR2(500);
 l_file_name               VARCHAR2(3200);
 l_text                    VARCHAR2(32000);
 l_error_message           VARCHAR2(3200);
 l_batch_status_n          VARCHAR2(60);

-- Exceptions
 ozf_webadi_error          EXCEPTION;
 l_org_id                  NUMBER;

 CURSOR csr_get_org_id(cv_org_name IN VARCHAR2) IS
   SELECT organization_id
   FROM hr_operating_units
   WHERE name = cv_org_name;

BEGIN

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- R12 MOAC Enhancement (+)
   IF P_ORG_ID IS NULL THEN
      fnd_message.set_name ('OZF', 'OZF_ENTER_OPEARTING_UNIT');
      l_error_message :=  fnd_message.get();
      raise_application_error( -20000, l_error_message);
   END IF;

   OPEN csr_get_org_id(P_ORG_ID);
   FETCH csr_get_org_id INTO l_org_id;
   CLOSE csr_get_org_id;

   --l_org_id := MO_GLOBAL.get_valid_org(p_org_id);

   IF l_org_id IS NULL THEN
      fnd_message.set_name ('OZF', 'OZF_ENTER_OPERATING_UNIT');
      l_error_message :=  fnd_message.get();
      raise_application_error( -20000, l_error_message);
       --x_return_status := FND_API.G_RET_STS_ERROR;
      --RAISE FND_API.G_EXC_ERROR;
   END IF;

   MO_GLOBAL.set_policy_context('S', l_org_id);
   -- R12 MOAC Enhancement (-)
   OZF_UTILITY_PVT.debug_message('Private API: 1');

-- Batch Level Required Value Validation

  IF  p_report_start_date IS NULL THEN
       fnd_message.set_name ('OZF', 'OZF_ENTER_REPORT_START_DATE');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
   END IF;

   IF p_report_end_date  IS NULL THEN
       fnd_message.set_name ('OZF', 'OZF_ENTER_REPORT_END_DATE');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
   END IF;

   IF p_report_start_date > p_report_end_date THEN
       fnd_message.set_name ('OZF', 'OZF_END_DATE_LESS_START_DATE');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
   END IF;

   IF p_partner_party_id IS NULL THEN
       fnd_message.set_name ('OZF', 'OZF_ENTER_PARTNER_ID');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
   END IF;

   IF  p_batch_type IS NULL AND p_transaction_type IS NULL THEN
       fnd_message.set_name ('OZF', 'OZF_ENTER_BATCH_TYPE');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
   END IF;

-- Line Level Required Value Validation

   IF p_item_description IS NULL THEN
      IF p_orig_system_item_number IS NULL THEN
         fnd_message.set_name ('OZF', 'OZF_ENTER_ITEM_NUMBER');
         l_error_message :=  fnd_message.get();
         raise_application_error( -20000, l_error_message);
      END IF;
   END IF;

   IF  p_quantity IS NULL THEN
       IF  p_orig_system_quantity IS NULL THEN
           fnd_message.set_name ('OZF', 'OZF_ENTER_QUANTITY');
           l_error_message :=  fnd_message.get();
           raise_application_error( -20000, l_error_message);
       END IF;
   END IF;

  IF  p_order_number IS NULL THEN
       fnd_message.set_name ('OZF', 'OZF_ENTER_ORDER_NUMBER');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
  END IF;
  IF  p_date_ordered IS NULL THEN
       fnd_message.set_name ('OZF', 'OZF_ENTER_ORDER_DATE');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
  END IF;

  IF p_date_ordered < p_report_start_date THEN
       fnd_message.set_name ('OZF', 'OZF_ORDER_DATE_LESS_START_DATE');
       l_error_message :=  fnd_message.get();
     raise_application_error( -20000, l_error_message);
  END IF;

  IF p_date_ordered > p_report_end_date THEN
     fnd_message.set_name ('OZF', 'OZF_ORDER_DATE_GRT_END_DATE');
     l_error_message :=  fnd_message.get();
     raise_application_error( -20000, l_error_message);
  END IF;

  IF p_currency IS NULL THEN
     fnd_message.set_name ('OZF', 'OZF_ENTER_CURRENCY');
     l_error_message :=  fnd_message.get();
     raise_application_error( -20000, l_error_message);
  END IF;

-- Writing to a file to record the data and debug for any problems

   l_file_dir := FND_PROFILE.VALUE('BNE_SERVER_LOG_PATH');

   IF  l_file_dir IS NULL THEN

       OPEN C;
       FETCH C INTO l_file_dir;
       CLOSE C;

   END IF;

   IF l_file_dir IS NOT NULL THEN

      l_file_name := 'ozfrsladi-'||p_batch_number||'.log';
      BEGIN
          l_file := utl_file.fopen( l_file_dir, l_file_name, 'w' , 32000);
      EXCEPTION
          WHEN UTL_FILE.INVALID_PATH THEN
              SELECT decode(instr(value,',',1,1), 0, value, substr(value,1,instr(value,',',1,1)-1))
              INTO  l_file_dir
              FROM   v$parameter
              WHERE  name = 'utl_file_dir';
             l_file := utl_file.fopen( l_file_dir, l_file_name, 'w' , 32000);
      END;
   END IF;


    G_COUNT := G_COUNT + 1;

    -- Record all the values and store them in a file
    l_text := l_text ||'Batch Number '||p_batch_number||'  \n ';
    l_text := l_text ||'Batch Type '||p_batch_type||'  \n ';
    l_text := l_text ||'batch_count '||p_batch_count||'  \n ';
    l_text := l_text ||'report_date '||p_report_date||'  \n ';
    l_text := l_text ||'report_start_date'||p_report_start_date||'  \n ';
    l_text := l_text ||'report_end_date '||p_report_end_date||'  \n ';
    l_text := l_text ||'comments '||p_comments||'  \n ';
    l_text := l_text ||'partner_claim_number '||p_partner_claim_number||'  \n ';
    l_text := l_text ||'transaction_purpose_code '||p_transaction_purpose||'  \n ';
    l_text := l_text ||'transaction_type_code '||p_transaction_type||'  \n ';
    l_text := l_text ||'partner_type '||p_partner_type||'  \n ';
    l_text := l_text ||'partner_party_id '||p_partner_party_id||'  \n ';
    l_text := l_text ||'partner_cust_account_id '||p_partner_cust_account_id||'  \n ';
    l_text := l_text ||'partner_site_id '||p_partner_site_id||'  \n ';
    l_text := l_text ||'partner_contact_name '||p_partner_contact_name||'  \n ';
    l_text := l_text ||'partner_email '||p_partner_email||'  \n ';
    l_text := l_text ||'partner_phone '||p_partner_phone||'  \n ';
    l_text := l_text ||'partner_fax'||p_partner_fax||'  \n ';
    l_text := l_text ||'currency_code '||p_currency||'  \n ';
    l_text := l_text ||'claimed_amount '||p_claimed_amount||'  \n ';
    l_text := l_text ||'credit_code '||p_credit_code||'  \n ';
    l_text := l_text ||'Completed Batch Assignments' ||'  \n ';

    IF p_resale_line_int_id IS NOT NULL THEN
       l_text := l_text ||'Resale Line Int ID from webadi '|| p_resale_line_int_id||'  \n ';
    END IF;
    l_text := l_text ||'Response Type '||p_response_type||'  \n ';
    l_text := l_text ||'Response Code '||p_response_code||'  \n ';
    l_text := l_text ||'Reject Reason Code '||p_reject_reason_code||'  \n ';
    l_text := l_text ||'Followup Action Code '||p_followup_action_code||'  \n ';
    l_text := l_text ||'Resale Transfer Type '||p_resale_transfer_type||'  \n ';
    l_text := l_text ||'Transfer Movement Type '||p_transfer_mvmt_type||'  \n ';
    l_text := l_text ||'Transfer Date '||p_transfer_date||'  \n ';
    l_text := l_text ||'End Customer Site Use '||p_end_cust_site_use_code||'  \n ';
    l_text := l_text ||'End Customer Party ID '||p_end_cust_party_name||'  \n ';
    l_text := l_text ||'End Customer Location '||p_end_cust_location||'  \n ';
    l_text := l_text ||'End Customer Address '||p_end_cust_address||'  \n ';
    l_text := l_text ||'End Customer City '||p_end_cust_city||'  \n ';
    l_text := l_text ||'End Customer State '||p_end_cust_state||'  \n ';
    l_text := l_text ||'End Customer Zip '||p_end_cust_postal_code||'  \n ';
    l_text := l_text ||'End Customer Country '||p_end_cust_country||'  \n ';
    l_text := l_text ||'End Customer Contact '||p_end_cust_contact_name||'  \n ';
    l_text := l_text ||'End Customer Email '||p_end_cust_email||'  \n ';
    l_text := l_text ||'End Customer Phone '||p_end_cust_phone||'  \n ';
    l_text := l_text ||'End Customer Fax '||p_end_cust_fax||'  \n ';
    l_text := l_text ||'[BUG 4186465] Bill To Party '||to_number(p_bill_to_party)||'  \n ';
    l_text := l_text ||'[BUG 4186465] Bill To Party Site '||p_bill_to_party_site||'  \n ';
    l_text := l_text ||'Bill To Party ID '||to_number(p_bill_to_PARTY_NAME)||'  \n ';
    l_text := l_text ||'Bill To Location'||p_bill_to_location||'  \n ';
    l_text := l_text ||'Bill To DUNS'||p_bill_to_duns_number||'  \n ';
    l_text := l_text ||'Bill To Address '||p_bill_to_address||'  \n ';
    l_text := l_text ||'Bill To City '||p_bill_to_city||'  \n ';
    l_text := l_text ||'Bill To State '||p_bill_to_state||'  \n ';
    l_text := l_text ||'Bill To Zip '||p_bill_to_postal_code||'  \n ';
    l_text := l_text ||'Bill To Country '||p_bill_to_country||'  \n ';
    l_text := l_text ||'Bill To Contact '||p_bill_to_contact_name||'  \n ';
    l_text := l_text ||'Bill To Email '||p_bill_to_email||'  \n ';
    l_text := l_text ||'Bill To Phone '||p_bill_to_phone||'  \n ';
    l_text := l_text ||'Bill To Fax '||p_bill_to_fax||'  \n ';
    l_text := l_text ||'[BUG 4186465] Ship To Party '||to_number(p_ship_to_party)||'  \n ';
    l_text := l_text ||'[BUG 4186465] Ship To Party Site '||p_ship_to_party_site||'  \n ';
    l_text := l_text ||'Ship To Party ID '||to_number(p_ship_to_PARTY_NAME)||'  \n ';
    l_text := l_text ||'Ship To DUNS '||p_ship_to_duns_number||'  \n ';
    l_text := l_text ||'Ship To Location '||p_ship_to_location||'  \n ';
    l_text := l_text ||'Ship To Address '||p_ship_to_address||'  \n ';
    l_text := l_text ||'Ship To City '||p_ship_to_city||'  \n ';
    l_text := l_text ||'Ship To State '||p_ship_to_state||'  \n ';
    l_text := l_text ||'Ship To Zip '||p_ship_to_postal_code||'  \n ';
    l_text := l_text ||'Ship To Country '||p_ship_to_country||'  \n ';
    l_text := l_text ||'Ship To Contact '||p_ship_to_contact_name||'  \n ';
    l_text := l_text ||'Ship To Email '||p_ship_to_email||'  \n ';
    l_text := l_text ||'Ship To Phone '||p_ship_to_phone||'  \n ';
    l_text := l_text ||'Ship To Fax '||p_ship_to_fax||'  \n ';
    l_text := l_text ||'Ship From Party '||to_number(p_ship_from_PARTY_NAME)||'  \n ';
    l_text := l_text ||'Ship From Location '||p_ship_from_location||'  \n ';
    l_text := l_text ||'Ship From Address '||p_ship_from_address||'  \n ';
    l_text := l_text ||'Ship From City '||p_ship_from_city||'  \n ';
    l_text := l_text ||'Ship From State '||p_ship_from_state||'  \n ';
    l_text := l_text ||'Ship From Zip '||p_ship_from_postal_code||'  \n ';
    l_text := l_text ||'Ship From Country '||p_ship_from_country||'  \n ';
    l_text := l_text ||'Ship From Contact '||p_ship_from_contact_name||'  \n ';
    l_text := l_text ||'Ship From Email '||p_ship_from_email||'  \n ';
    l_text := l_text ||'Ship From Phone '||p_ship_from_phone||'  \n ';
    l_text := l_text ||'Ship From Fax '||p_ship_from_fax||'  \n ';
    l_text := l_text ||'Sold From Party '||to_number(p_sold_from_PARTY_NAME)||'  \n ';
    l_text := l_text ||'Sold From Location '||p_sold_from_location||'  \n ';
    l_text := l_text ||'Sold From Address '||p_sold_from_address||'  \n ';
    l_text := l_text ||'Sold From City '||p_sold_from_city||'  \n ';
    l_text := l_text ||'Sold From State '||p_sold_from_state||'  \n ';
    l_text := l_text ||'Sold From Zip '||p_sold_from_postal_code||'  \n ';
    l_text := l_text ||'Sold From Country '||p_sold_from_country||'  \n ';
    l_text := l_text ||'Sold From Contact '||p_sold_from_contact_name||'  \n ';
    l_text := l_text ||'Sold From Email '||p_sold_from_email||'  \n ';
    l_text := l_text ||'Sold From Phone '||p_sold_from_phone||'  \n ';
    l_text := l_text ||'Sold From Fax '||p_sold_from_fax||'  \n ';
    l_text := l_text ||'Quantity '||p_quantity||'  \n ';
    l_text := l_text ||'UOM '||p_uom||'  \n ';
    l_text := l_text ||'Currency '||p_line_currency||'  \n ';
    l_text := l_text ||'Exchange Rate '||p_exchange_rate||'  \n ';
    l_text := l_text ||'Exchange Rate Type '||p_exchange_rate_type||'  \n ';
    l_text := l_text ||'Exchange Rate  Date '||p_exchange_rate_date||'  \n ';
    l_text := l_text ||'Selling Price '||p_selling_price||'  \n ';
    l_text := l_text ||'Purchase UOM '||p_purchase_uom||'  \n ';
    l_text := l_text ||'Invoice Number '||p_invoice_number||'  \n ';
    l_text := l_text ||'Date Invoiced '||p_date_invoiced||'  \n ';
    l_text := l_text ||'Date Shipped '||p_date_shipped||'  \n ';
    l_text := l_text ||'Credit Advice Date '||p_credit_advice_date||'  \n ';
    l_text := l_text ||'Inventory Item ID '||to_number(p_item_description)||'  \n ';
    l_text := l_text ||'UPC '||p_upc_code||'  \n ';
    l_text := l_text ||'Purchase Price '||p_purchase_price||'  \n ';
    l_text := l_text ||'Unit Claimed Amount '||p_line_claimed_amount||'  \n ';
    l_text := l_text ||'Total Claimed Amount '||l_total_claimed_amount||'  \n ';
    l_text := l_text ||'Credit Code '||p_credit_code||'  \n ';
    l_text := l_text ||'Order Type '||p_order_type||'  \n ';
    l_text := l_text ||'Order Category '||p_order_category||'  \n ';
    l_text := l_text ||'Order Number '||p_order_number||'  \n ';
    l_text := l_text ||'Date Ordered '||p_date_ordered||'  \n ';
    l_text := l_text ||'PO Number '||p_po_number||'  \n ';
    l_text := l_text ||'PO Release Number '||p_po_release_number||'  \n ';
    l_text := l_text ||'PO Type '||p_po_type||'  \n ';
    l_text := l_text ||'Agreement Type '||p_agreement_type||'  \n ';
    l_text := l_text ||'Agreement Name '||p_agreement_name||'  \n ';
    l_text := l_text ||'Agreement Price '||p_agreement_price||'  \n ';
    l_text := l_text ||'Agreement UOM '||p_agreement_uom||'  \n ';
    l_text := l_text ||'Line Assignments Started'||'  \n ';
    l_text := l_text ||'Orig System Quantity '||p_orig_system_quantity||'  \n ';
    l_text := l_text ||'Orig System UOM '||p_orig_system_uom||'  \n ';
    l_text := l_text ||'Orig System Currency '||p_orig_system_currency_code||'  \n ';
    l_text := l_text ||'Orig System Selling Price '||p_orig_system_selling_price||'  \n ';
    l_text := l_text ||'Orig System Line Reference '||p_orig_system_line_reference||'  \n ';
    l_text := l_text ||'Orig System Purchase UOM '||p_orig_system_purchase_uom||'  \n ';
    l_text := l_text ||'Orig System Purchase Currency '||p_orig_system_purchase_curr||'  \n ';
    l_text := l_text ||'Orig System Purchase Price '||p_orig_system_purchase_price||'  \n ';
    l_text := l_text ||'Orig System Purchase Quantity '||p_orig_system_purchase_quant||'  \n ';
    l_text := l_text ||'Orig System Agreement UOM '||p_orig_system_agreement_uom||'  \n ';
    l_text := l_text ||'Orig System Agreement Name '||p_orig_system_agreement_name||'  \n ';
    l_text := l_text ||'Orig System Agreement Type '||p_orig_system_agreement_type||'  \n ';
    l_text := l_text ||'Orig System Agreement Status '||p_orig_system_agreement_status||'  \n ';
    l_text := l_text ||'Orig System Agreement Currency '||p_orig_system_agreement_curr||'  \n ';
    l_text := l_text ||'Orig System Agreement Price '||p_orig_system_agreement_price||'  \n ';
    l_text := l_text ||'Orig System Agreement Quantity '||p_orig_system_agreement_quant||'  \n ';
    l_text := l_text ||'Orig System Item Number '||p_orig_system_item_number||'  \n ';
    l_text := l_text ||'[BUG 4469837] Orig System Bill To Party '||p_orig_bill_to_party||'  \n ';
    l_text := l_text ||'[BUG 4469837] Orig System Bill To Party Site '||p_orig_bill_to_party_site||'  \n ';
    l_text := l_text ||'[BUG 4469837] Orig System Ship To Party '||p_orig_ship_to_party||'  \n ';
    l_text := l_text ||'[BUG 4469837] Orig System Ship To Party Site '||p_orig_ship_to_party_site||'  \n ';
    l_text := l_text ||'[BUG 4469837] Orig System End Customer '||p_orig_end_cust_party||'  \n ';
    l_text := l_text ||'[BUG 4469837] Orig System End Customer Location '||p_orig_end_cust_party_site||'  \n ';
    l_text := l_text ||'Line Status is '||p_line_status||'  \n ';
    l_text := l_text ||'Dispute code is '||p_dispute_code||'  \n ';





    -- Batch record level assignments

    l_resale_batch_rec.last_update_date               := SYSDATE;
    l_resale_batch_rec.last_updated_by                := FND_GLOBAL.User_Id;
    l_resale_batch_rec.last_update_login              := FND_GLOBAL.User_Id;
    l_resale_batch_rec.batch_type                     := p_batch_type;
    l_resale_batch_rec.batch_number                   := p_batch_number;
    l_resale_batch_rec.batch_count                    := p_batch_count;
    l_resale_batch_rec.year                           := p_year;
    l_resale_batch_rec.month                          := p_month;
    l_resale_batch_rec.report_date                    := NVL(p_report_date, TRUNC(SYSDATE));
    l_resale_batch_rec.report_start_date              := p_report_start_date;
    l_resale_batch_rec.report_end_date                := p_report_end_date;
    l_resale_batch_rec.data_source_code               := p_data_source_code;
    l_resale_batch_rec.reference_type                 := p_reference_type;
    l_resale_batch_rec.reference_number               := p_reference_number;
    l_resale_batch_rec.comments                       := p_comments;
    l_resale_batch_rec.partner_claim_number           := p_partner_claim_number;
    l_resale_batch_rec.transaction_purpose_code       := nvl(p_transaction_purpose,'00');
    l_resale_batch_rec.transaction_type_code          := p_transaction_type;
    l_resale_batch_rec.partner_type                   := p_partner_type;
    l_resale_batch_rec.partner_party_id               := p_partner_party_id;
    l_resale_batch_rec.partner_cust_account_id        := p_partner_cust_account_id;
    l_resale_batch_rec.partner_site_id                := p_partner_site_id;
    l_resale_batch_rec.partner_contact_name           := p_partner_contact_name;
    l_resale_batch_rec.partner_email                  := p_partner_email;
    l_resale_batch_rec.partner_phone                  := p_partner_phone;
    l_resale_batch_rec.partner_fax                    := p_partner_fax;
    l_resale_batch_rec.currency_code                  := p_currency;
    l_resale_batch_rec.claimed_amount                 := p_claimed_amount;
    l_resale_batch_rec.credit_code                    := p_credit_code;
    l_resale_batch_rec.attribute_category             := p_attribute_category;
    l_resale_batch_rec.attribute1                     := p_attribute1;
    l_resale_batch_rec.attribute2                     := p_attribute2;
    l_resale_batch_rec.attribute3                     := p_attribute3;
    l_resale_batch_rec.attribute4                     := p_attribute4;
    l_resale_batch_rec.attribute5                     := p_attribute5;
    l_resale_batch_rec.attribute6                     := p_attribute6;
    l_resale_batch_rec.attribute7                     := p_attribute7;
    l_resale_batch_rec.attribute8                     := p_attribute8;
    l_resale_batch_rec.attribute9                     := p_attribute9;
    l_resale_batch_rec.attribute10                    := p_attribute10;
    l_resale_batch_rec.attribute11                    := p_attribute11;
    l_resale_batch_rec.attribute12                    := p_attribute12;
    l_resale_batch_rec.attribute13                    := p_attribute13;
    l_resale_batch_rec.attribute14                    := p_attribute14;
    l_resale_batch_rec.attribute15                    := p_attribute15;
    l_resale_batch_rec.batch_set_id_code              := 'WEBADI';
    l_resale_batch_rec.credit_advice_date             := p_batch_credit_advice_date;

    -- Line level record assignments

    IF   p_line_claimed_amount IS NOT NULL  THEN
       IF   p_quantity IS NOT NULL THEN
          l_total_claimed_amount := p_line_claimed_amount*p_quantity;
       ELSIF p_orig_system_quantity IS NOT NULL THEN
          l_total_claimed_amount := p_line_claimed_amount*p_orig_system_quantity;
       END IF;
    END IF;
    l_int_line_tbl.extend(1);
    l_int_line_tbl(1).last_update_date                :=  SYSDATE;
    l_int_line_tbl(1).last_updated_by                 :=  FND_GLOBAL.User_Id;
    l_int_line_tbl(1).last_update_login               :=  FND_GLOBAL.User_Id;
    l_int_line_tbl(1).response_type                   :=  p_response_type;
    l_int_line_tbl(1).response_code                   :=  p_response_code;
    l_int_line_tbl(1).reject_reason_code              :=  p_reject_reason_code;
    l_int_line_tbl(1).followup_action_code            :=  p_followup_action_code;
    l_int_line_tbl(1).resale_transfer_type            :=  p_resale_transfer_type;
    l_int_line_tbl(1).product_transfer_movement_type  :=  p_transfer_mvmt_type;
    l_int_line_tbl(1).product_transfer_date           :=  p_transfer_date;
    l_int_line_tbl(1).end_cust_site_use_code          :=  p_end_cust_site_use_code;
    l_int_line_tbl(1).end_cust_party_id               :=  to_number(p_end_cust_party_name);
    l_int_line_tbl(1).end_cust_location               :=  p_end_cust_location;
    l_int_line_tbl(1).end_cust_address                :=  p_end_cust_address;
    l_int_line_tbl(1).end_cust_city                   :=  p_end_cust_city;
    l_int_line_tbl(1).end_cust_state                  :=  p_end_cust_state;
    l_int_line_tbl(1).end_cust_postal_code            :=  p_end_cust_postal_code;
    l_int_line_tbl(1).end_cust_country                :=  p_end_cust_country;
    l_int_line_tbl(1).end_cust_contact_name           :=  p_end_cust_contact_name;
    l_int_line_tbl(1).end_cust_email                  :=  p_end_cust_email;
    l_int_line_tbl(1).end_cust_phone                  :=  p_end_cust_phone;
    l_int_line_tbl(1).end_cust_fax                    :=  p_end_cust_fax;
    -- [BEGIN OF BUG 4198442 Fixing]
    l_int_line_tbl(1).bill_to_party_id                :=  to_number(p_bill_to_party);
    OPEN csr_get_party_site_id(p_bill_to_party_site);
    FETCH csr_get_party_site_id INTO l_int_line_tbl(1).bill_to_party_site_id;
    CLOSE csr_get_party_site_id;
    -- [END OF BUG 4198442 Fixing]
    l_int_line_tbl(1).bill_to_cust_account_id         :=  to_number(p_bill_to_PARTY_NAME);
    l_int_line_tbl(1).bill_to_location                :=  p_bill_to_location;
    l_int_line_tbl(1).bill_to_duns_number             :=  p_bill_to_duns_number;
    l_int_line_tbl(1).bill_to_address                 :=  p_bill_to_address;
    l_int_line_tbl(1).bill_to_city                    :=  p_bill_to_city;
    l_int_line_tbl(1).bill_to_state                   :=  p_bill_to_state;
    l_int_line_tbl(1).bill_to_postal_code             :=  p_bill_to_postal_code;
    l_int_line_tbl(1).bill_to_country                 :=  p_bill_to_country;
    l_int_line_tbl(1).bill_to_contact_name            :=  p_bill_to_contact_name;
    l_int_line_tbl(1).bill_to_email                   :=  p_bill_to_email;
    l_int_line_tbl(1).bill_to_phone                   :=  p_bill_to_phone;
    l_int_line_tbl(1).bill_to_fax                     :=  p_bill_to_fax;
    -- [BEGIN OF BUG 4198442 Fixing]
    l_int_line_tbl(1).ship_to_party_id                :=  to_number(p_ship_to_party);
    OPEN csr_get_party_site_id(p_ship_to_party_site);
    FETCH csr_get_party_site_id INTO l_int_line_tbl(1).ship_to_party_site_id;
    CLOSE csr_get_party_site_id;
    -- [END OF BUG 4198442 Fixing]
    l_int_line_tbl(1).ship_to_cust_account_id         :=  to_number(p_ship_to_PARTY_NAME);
    l_int_line_tbl(1).ship_to_duns_number             :=  p_ship_to_duns_number;
    l_int_line_tbl(1).ship_to_location                :=  p_ship_to_location;
    l_int_line_tbl(1).ship_to_address                 :=  p_ship_to_address;
    l_int_line_tbl(1).ship_to_city                    :=  p_ship_to_city;
    l_int_line_tbl(1).ship_to_state                   :=  p_ship_to_state;
    l_int_line_tbl(1).ship_to_postal_code             :=  p_ship_to_postal_code;
    l_int_line_tbl(1).ship_to_country                 :=  p_ship_to_country;
    l_int_line_tbl(1).ship_to_contact_name            :=  p_ship_to_contact_name;
    l_int_line_tbl(1).ship_to_email                   :=  p_ship_to_email;
    l_int_line_tbl(1).ship_to_phone                   :=  p_ship_to_phone;
    l_int_line_tbl(1).ship_to_fax                     :=  p_ship_to_fax;
    l_int_line_tbl(1).ship_from_cust_account_id       :=  to_number(p_ship_from_PARTY_NAME);
    l_int_line_tbl(1).ship_from_location              :=  p_ship_from_location;
    l_int_line_tbl(1).ship_from_address               :=  p_ship_from_address;
    l_int_line_tbl(1).ship_from_city                  :=  p_ship_from_city;
    l_int_line_tbl(1).ship_from_state                 :=  p_ship_from_state;
    l_int_line_tbl(1).ship_from_postal_code           :=  p_ship_from_postal_code;
    l_int_line_tbl(1).ship_from_country               :=  p_ship_from_country;
    l_int_line_tbl(1).ship_from_contact_name          :=  p_ship_from_contact_name;
    l_int_line_tbl(1).ship_from_email                 :=  p_ship_from_email;
    l_int_line_tbl(1).ship_from_phone                 :=  p_ship_from_phone;
    l_int_line_tbl(1).ship_from_fax                   :=  p_ship_from_fax;
    l_int_line_tbl(1).sold_from_cust_account_id       :=  to_number(p_sold_from_PARTY_NAME);
    l_int_line_tbl(1).sold_from_location              :=  p_sold_from_location;
    l_int_line_tbl(1).sold_from_address               :=  p_sold_from_address;
    l_int_line_tbl(1).sold_from_city                  :=  p_sold_from_city;
    l_int_line_tbl(1).sold_from_state                 :=  p_sold_from_state;
    l_int_line_tbl(1).sold_from_postal_code           :=  p_sold_from_postal_code;
    l_int_line_tbl(1).sold_from_country               :=  p_sold_from_country;
    l_int_line_tbl(1).sold_from_contact_name          :=  p_sold_from_contact_name;
    l_int_line_tbl(1).sold_from_email                 :=  p_sold_from_email;
    l_int_line_tbl(1).sold_from_phone                 :=  p_sold_from_phone;
    l_int_line_tbl(1).sold_from_fax                   :=  p_sold_from_fax;
    l_int_line_tbl(1).order_number                    :=  p_order_number;
    l_int_line_tbl(1).date_ordered                    :=  p_date_ordered;
    l_int_line_tbl(1).po_number                       :=  p_po_number;
    l_int_line_tbl(1).po_release_number               :=  p_po_release_number;
    l_int_line_tbl(1).po_type                         :=  p_po_type;
    l_int_line_tbl(1).agreement_type                  :=  p_agreement_type;
    l_int_line_tbl(1).agreement_name                  :=  p_agreement_name;
    l_int_line_tbl(1).agreement_price                 :=  p_agreement_price;
    l_int_line_tbl(1).agreement_uom_code              :=  p_agreement_uom;
    l_int_line_tbl(1).orig_system_quantity            :=  p_orig_system_quantity;
    l_int_line_tbl(1).orig_system_uom                 :=  p_orig_system_uom;
    l_int_line_tbl(1).orig_system_currency_code       :=  p_orig_system_currency_code;
    l_int_line_tbl(1).orig_system_selling_price       :=  p_orig_system_selling_price;
    l_int_line_tbl(1).orig_system_line_reference      :=  p_orig_system_line_reference;
    l_int_line_tbl(1).orig_system_purchase_uom        :=  p_orig_system_purchase_uom;
    l_int_line_tbl(1).orig_system_purchase_curr       :=  p_orig_system_purchase_curr;
    l_int_line_tbl(1).orig_system_purchase_price      :=  p_orig_system_purchase_price;
    l_int_line_tbl(1).orig_system_purchase_quantity   :=  p_orig_system_purchase_quant;
    l_int_line_tbl(1).orig_system_agreement_uom       :=  p_orig_system_agreement_uom;
    l_int_line_tbl(1).orig_system_agreement_name      :=  p_orig_system_agreement_name;
    l_int_line_tbl(1).orig_system_agreement_type      :=  p_orig_system_agreement_type;
    l_int_line_tbl(1).orig_system_agreement_status    :=  p_orig_system_agreement_status;
    l_int_line_tbl(1).orig_system_agreement_curr      :=  p_orig_system_agreement_curr;
    l_int_line_tbl(1).orig_system_agreement_price     :=  p_orig_system_agreement_price;
    l_int_line_tbl(1).orig_system_agreement_quantity  :=  p_orig_system_agreement_quant;
    l_int_line_tbl(1).orig_system_item_number         :=  p_orig_system_item_number;
    l_int_line_tbl(1).quantity                        :=  p_quantity;
    l_int_line_tbl(1).uom_code                        :=  p_uom;
    l_int_line_tbl(1).currency_code                   :=  p_line_currency;
    l_int_line_tbl(1).exchange_rate                   :=  p_exchange_rate;
    l_int_line_tbl(1).exchange_rate_type              :=  p_exchange_rate_type;
    l_int_line_tbl(1).exchange_rate_date              :=  p_exchange_rate_date;
    l_int_line_tbl(1).selling_price                   :=  p_selling_price;
    l_int_line_tbl(1).purchase_uom_code               :=  p_purchase_uom;
    l_int_line_tbl(1).invoice_number                  :=  p_invoice_number;
    l_int_line_tbl(1).date_invoiced                   :=  p_date_invoiced;
    l_int_line_tbl(1).date_shipped                    :=  p_date_shipped;
    l_int_line_tbl(1).credit_advice_date              :=  p_credit_advice_date;
    l_int_line_tbl(1).inventory_item_segment1         :=  p_inventory_item_segment1;
    l_int_line_tbl(1).inventory_item_segment2         :=  p_inventory_item_segment2;
    l_int_line_tbl(1).inventory_item_segment3         :=  p_inventory_item_segment3;
    l_int_line_tbl(1).inventory_item_segment4         :=  p_inventory_item_segment4;
    l_int_line_tbl(1).inventory_item_segment5         :=  p_inventory_item_segment5;
    l_int_line_tbl(1).inventory_item_segment6         :=  p_inventory_item_segment6;
    l_int_line_tbl(1).inventory_item_segment7         :=  p_inventory_item_segment7;
    l_int_line_tbl(1).inventory_item_segment8         :=  p_inventory_item_segment8;
    l_int_line_tbl(1).inventory_item_segment9         :=  p_inventory_item_segment9;
    l_int_line_tbl(1).inventory_item_segment10        :=  p_inventory_item_segment10;
    l_int_line_tbl(1).inventory_item_segment11        :=  p_inventory_item_segment11;
    l_int_line_tbl(1).inventory_item_segment12        :=  p_inventory_item_segment12;
    l_int_line_tbl(1).inventory_item_segment13        :=  p_inventory_item_segment13;
    l_int_line_tbl(1).inventory_item_segment14        :=  p_inventory_item_segment14;
    l_int_line_tbl(1).inventory_item_segment15        :=  p_inventory_item_segment15;
    l_int_line_tbl(1).inventory_item_segment16        :=  p_inventory_item_segment16;
    l_int_line_tbl(1).inventory_item_segment17        :=  p_inventory_item_segment17;
    l_int_line_tbl(1).inventory_item_segment18        :=  p_inventory_item_segment18;
    l_int_line_tbl(1).inventory_item_segment19        :=  p_inventory_item_segment19;
    l_int_line_tbl(1).inventory_item_segment20        :=  p_inventory_item_segment20;
    l_int_line_tbl(1).inventory_item_id               :=  to_number(p_item_description);
    l_int_line_tbl(1).upc_code                        :=  p_upc_code;
    l_int_line_tbl(1).purchase_price                  :=  p_purchase_price;
    l_int_line_tbl(1).claimed_amount                  :=  p_line_claimed_amount;
    l_int_line_tbl(1).total_claimed_amount            :=  l_total_claimed_amount;
    l_int_line_tbl(1).credit_code                     :=  p_credit_code;
    l_int_line_tbl(1).order_type                      :=  p_order_type;
    l_int_line_tbl(1).order_category                  :=  p_order_category;
    -- [BEGIN OF BUG 4332301 FIXING]
    --l_int_line_tbl(1).tracing_flag                    :=  p_tracing_flag;
    IF p_tracing_flag = 'YES' THEN
       l_int_line_tbl(1).tracing_flag := 'T';
    ELSIF p_tracing_flag = 'NO' THEN
       l_int_line_tbl(1).tracing_flag := 'F';
    ELSE
       l_int_line_tbl(1).tracing_flag := NULL;
    END IF;
    -- [END OF BUG 4332301 FIXING]
    l_int_line_tbl(1).header_attribute_category       :=  p_header_attribute_category;
    l_int_line_tbl(1).header_attribute1               :=  p_header_attribute1;
    l_int_line_tbl(1).header_attribute2               :=  p_header_attribute2;
    l_int_line_tbl(1).header_attribute3               :=  p_header_attribute3;
    l_int_line_tbl(1).header_attribute4               :=  p_header_attribute4;
    l_int_line_tbl(1).header_attribute5               :=  p_header_attribute5;
    l_int_line_tbl(1).header_attribute6               :=  p_header_attribute6;
    l_int_line_tbl(1).header_attribute7               :=  p_header_attribute7;
    l_int_line_tbl(1).header_attribute8               :=  p_header_attribute8;
    l_int_line_tbl(1).header_attribute9               :=  p_header_attribute9;
    l_int_line_tbl(1).header_attribute10              :=  p_header_attribute10;
    l_int_line_tbl(1).header_attribute11              :=  p_header_attribute11;
    l_int_line_tbl(1).header_attribute12              :=  p_header_attribute12;
    l_int_line_tbl(1).header_attribute13              :=  p_header_attribute13;
    l_int_line_tbl(1).header_attribute14              :=  p_header_attribute14;
    l_int_line_tbl(1).header_attribute15              :=  p_header_attribute15;
    l_int_line_tbl(1).line_attribute_category         :=  p_line_attribute_category;
    l_int_line_tbl(1).line_attribute1                 :=  p_line_attribute1;
    l_int_line_tbl(1).line_attribute2                 :=  p_line_attribute2;
    l_int_line_tbl(1).line_attribute3                 :=  p_line_attribute3;
    l_int_line_tbl(1).line_attribute4                 :=  p_line_attribute4;
    l_int_line_tbl(1).line_attribute5                 :=  p_line_attribute5;
    l_int_line_tbl(1).line_attribute6                 :=  p_line_attribute6;
    l_int_line_tbl(1).line_attribute7                 :=  p_line_attribute7;
    l_int_line_tbl(1).line_attribute8                 :=  p_line_attribute8;
    l_int_line_tbl(1).line_attribute9                 :=  p_line_attribute9;
    l_int_line_tbl(1).line_attribute10                :=  p_line_attribute10;
    l_int_line_tbl(1).line_attribute11                :=  p_line_attribute11;
    l_int_line_tbl(1).line_attribute12                :=  p_line_attribute12;
    l_int_line_tbl(1).line_attribute13                :=  p_line_attribute13;
    l_int_line_tbl(1).line_attribute14                :=  p_line_attribute14;
    l_int_line_tbl(1).line_attribute15                :=  p_line_attribute15;
    -- Bug 4469837 (+)
    IF p_orig_bill_to_party IS NOT NULL AND
       l_int_line_tbl(1).bill_to_party_id IS NULL AND
       l_int_line_tbl(1).bill_to_cust_account_id IS NULL THEN
       l_int_line_tbl(1).bill_to_party_name := p_orig_bill_to_party;
    END IF;
    IF p_orig_bill_to_party_site IS NOT NULL AND
       l_int_line_tbl(1).bill_to_party_site_id IS NULL AND
       l_int_line_tbl(1).bill_to_location IS NULL THEN
       l_int_line_tbl(1).bill_to_location := p_orig_bill_to_party_site;
    END IF;
    IF p_orig_ship_to_party IS NOT NULL AND
       l_int_line_tbl(1).ship_to_party_id IS NULL AND
       l_int_line_tbl(1).ship_to_cust_account_id IS NULL THEN
       l_int_line_tbl(1).ship_to_party_name := p_orig_ship_to_party;
    END IF;
    IF p_orig_ship_to_party_site IS NOT NULL AND
       l_int_line_tbl(1).ship_to_party_site_id IS NULL AND
       l_int_line_tbl(1).ship_to_location IS NULL THEN
       l_int_line_tbl(1).ship_to_location := p_orig_ship_to_party_site;
    END IF;
    IF p_orig_end_cust_party IS NOT NULL AND
       l_int_line_tbl(1).end_cust_party_id IS NULL THEN
       l_int_line_tbl(1).end_cust_party_name := p_orig_end_cust_party;
    END IF;
    IF p_orig_end_cust_party_site IS NOT NULL AND
       l_int_line_tbl(1).end_cust_party_site_id IS NULL THEN
       l_int_line_tbl(1).end_cust_location := p_orig_end_cust_party_site;
    END IF;
    -- Bug 4469837 (-)

    -- R12 MOAC Enhancement (+)
    l_int_line_tbl(1).org_id := l_org_id;
    -- R12 MOAC Enhancement (+)

    OPEN  c_chk_line_exists (P_BATCH_NUMBER);
    FETCH c_chk_line_exists INTO l_line_count, l_batch_status;
    CLOSE c_chk_line_exists;
    OZF_UTILITY_PVT.debug_message('batch status '||  l_batch_status);
--  Transaction Purpose Code Validations
    IF  l_batch_status IS NOT NULL  THEN
       IF  l_batch_status = 'CLOSED' THEN
          fnd_message.set_name ('OZF', 'OZF_WADI_CANNOT_UPDATE');
          l_error_message :=  fnd_message.get();
          RAISE_APPLICATION_ERROR( -20000, l_error_message);
       ELSIF l_batch_status IN ('NEW','OPEN','PROCESSED','DISPUTED') THEN
          l_status_code :=  l_batch_status;
       -- [BEGIN OF BUG 4212707 FIXING] by mchang
       ELSE
          /*
          FND_MESSAGE.set_name('OZF', 'OZF_WADI_BATCH_NO_UPLOAD');
          FND_MESSAGE.set_token( 'NUMBER', P_BATCH_NUMBER);
          FND_MESSAGE.set_token( 'STATUS'
                               , OZF_UTILITY_PVT.get_lookup_meaning('OZF_RESALE_BATCH_STATUS'
                                                                   ,l_batch_status
                                                                   )
                               );
          */
          --l_error_message :=  FND_MESSAGE.get();
          l_batch_status_n := OZF_UTILITY_PVT.get_lookup_meaning('OZF_RESALE_BATCH_STATUS'
                                                                ,l_batch_status
                                                                );
          l_error_message := 'Cannot update '||l_batch_status_n||' batch';
          RAISE_APPLICATION_ERROR( -20000, l_error_message);
       -- [END OF BUG 4212707 FIXING] by mchang
       END IF;
    ELSE
       IF p_transaction_purpose = '00' THEN
           l_status_code  := 'NEW';
           l_line_status  := 'NEW';
       ELSIF  p_transaction_purpose IS NULL THEN
           l_status_code  := 'NEW';
       END IF;
    END IF;

    l_text := l_text || 'Status '|| l_status_code||'  \n ';

--  ==============================================================================
--  When l_line_count = 0 then it is a new batch
--  When l_line_count > 0 but p_resale_line_int_id is NULL then new line is being inserted
--  to the batch
--  ==============================================================================


    IF  l_status_code IN ('OPEN','NEW','PROCESSED') AND
       (l_line_count = 0 OR  p_resale_line_int_id IS NULL) THEN

       OPEN  c_chk_record_exists (P_BATCH_NUMBER);
       FETCH c_chk_record_exists INTO l_batch_count;
       CLOSE c_chk_record_exists;

       --  ==============================================================================
       --  WebADI sends batch and line data together to this API and it is called
       --  as many times as the number of lines exists, but batch has to be created
       --  the first time this API call is made. Batch is created when batch count = 0
       --  ==============================================================================

       IF l_status_code = 'NEW' AND l_batch_count = 0  THEN
          SELECT ozf_resale_batches_all_s.nextval
          INTO   l_resale_batch_rec.resale_batch_id
          FROM   DUAL;

          --  ==============================================================================
          --  Resale Batch ID is stored as global variable for the subsequent line record creation
          --  ==============================================================================

          G_RESALE_BATCH_ID  := l_resale_batch_rec.resale_batch_id;

          ozf_utility_pvt.debug_message('Resale Batch ID '||G_RESALE_BATCH_ID);
          ozf_utility_pvt.debug_message('Resale Batch ID in create  '|| l_resale_batch_rec.resale_batch_id);

          l_text := l_text || 'Resale Batch ID in create  '|| l_resale_batch_rec.resale_batch_id||'  \n ';

          -- R12 MOAC Enhancement (+)
          /*
          SELECT TO_NUMBER(NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99))
          INTO   l_resale_batch_rec.org_id FROM DUAL;
          */
          -- R12 MOAC Enhancement (-)
          BEGIN

             OZF_RESALE_BATCHES_PKG.INSERT_ROW
             (
              px_resale_batch_id                  => l_resale_batch_rec.resale_batch_id
             ,px_object_version_number            => l_batch_obj
             ,p_last_update_date                  => SYSDATE
             ,p_last_updated_by                   => FND_GLOBAL.User_Id
             ,p_creation_date                     => SYSDATE
             ,p_request_id                        => NULL
             ,p_created_by                        => FND_GLOBAL.User_Id
             ,p_created_from                      => NULL
             ,p_last_update_login                 => FND_GLOBAL.User_Id
             ,p_program_application_id            => NULL
             ,p_program_update_date               => NULL
             ,p_program_id                        => NULL
             ,p_batch_number                      => l_resale_batch_rec.batch_number
             ,p_batch_type                        => l_resale_batch_rec.batch_type
             ,p_batch_count                       => l_resale_batch_rec.batch_count
             ,p_year                              => l_resale_batch_rec.year
             ,p_month                             => l_resale_batch_rec.month
             ,p_report_date                       => l_resale_batch_rec.report_date
             ,p_report_start_date                 => l_resale_batch_rec.report_start_date
             ,p_report_end_date                   => l_resale_batch_rec.report_end_date
             ,p_status_code                       => 'NEW'
             ,p_data_source_code                  => l_resale_batch_rec.data_source_code
             ,p_reference_type                    => l_resale_batch_rec.reference_type
             ,p_reference_number                  => l_resale_batch_rec.reference_number
             ,p_comments                          => l_resale_batch_rec.comments
             ,p_partner_claim_number              => l_resale_batch_rec.partner_claim_number
             ,p_transaction_purpose_code          => l_resale_batch_rec.transaction_purpose_code
             ,p_transaction_type_code             => l_resale_batch_rec.transaction_type_code
             ,p_partner_type                      => l_resale_batch_rec.partner_type
             ,p_partner_id                        => NULL
             ,p_partner_party_id                  => l_resale_batch_rec.partner_party_id
             ,p_partner_cust_account_id           => l_resale_batch_rec.partner_cust_account_id
             ,p_partner_site_id                   => l_resale_batch_rec.partner_site_id
             ,p_partner_contact_party_id          => NULL
             ,p_partner_contact_name              => l_resale_batch_rec.partner_contact_name
             ,p_partner_email                     => l_resale_batch_rec.partner_email
             ,p_partner_phone                     => l_resale_batch_rec.partner_phone
             ,p_partner_fax                       => l_resale_batch_rec.partner_fax
             ,p_header_tolerance_operand          => NULL
             ,p_header_tolerance_calc_code        => NULL
             ,p_line_tolerance_operand            => NULL
             ,p_line_tolerance_calc_code          => NULL
             ,p_currency_code                     => l_resale_batch_rec.currency_code
             ,p_claimed_amount                    => l_resale_batch_rec.claimed_amount
             ,p_allowed_amount                    => l_amount
             ,p_paid_amount                       => l_amount
             ,p_disputed_amount                   => l_amount
             ,p_accepted_amount                   => l_amount
             ,p_lines_invalid                     => l_amount
             ,p_lines_w_tolerance                 => l_amount
             ,p_lines_disputed                    => l_amount
             ,p_batch_set_id_code                 => 'WEBADI'
             ,p_credit_code                       => l_resale_batch_rec.credit_code
             ,p_credit_advice_date                => l_resale_batch_rec.credit_advice_date
             ,p_purge_flag                        => NULL
             ,p_attribute_category                => p_attribute_category
             ,p_attribute1                        => p_attribute1
             ,p_attribute2                        => p_attribute2
             ,p_attribute3                        => p_attribute3
             ,p_attribute4                        => p_attribute4
             ,p_attribute5                        => p_attribute5
             ,p_attribute6                        => p_attribute6
             ,p_attribute7                        => p_attribute7
             ,p_attribute8                        => p_attribute8
             ,p_attribute9                        => p_attribute9
             ,p_attribute10                       => p_attribute10
             ,p_attribute11                       => p_attribute11
             ,p_attribute12                       => p_attribute12
             ,p_attribute13                       => p_attribute13
             ,p_attribute14                       => p_attribute14
             ,p_attribute15                       => p_attribute15
             ,px_org_id                           => l_org_id -- R12 MOAC Enhancement --l_resale_batch_rec.org_id
             );

          EXCEPTION

             WHEN OTHERS THEN
              l_text := l_text||'Error in Create Batch '||SQLERRM||'  \n ';
              fnd_message.set_name ('OZF', 'OZF_WADI_CREATE_BATCH_ERROR');
              l_error_message :=  fnd_message.get();
              raise_application_error( -20000, l_error_message);
          END;

       END IF; -- l_batch_count = 0

       l_text := l_text||'Creating Line Record'||'  \n ';
       ozf_utility_pvt.debug_message('Creating Line Record');
       -- Bug 5417666 (+)
       --SELECT TO_NUMBER(NVL(SUBSTRB(USERENV('CLIENT_INFO'),1,10),-99))
       --INTO   l_int_line_tbl(1).org_id FROM DUAL;
       l_int_line_tbl(1).org_id := l_org_id;
       -- Bug 5417666 (-)

       SELECT ozf_resale_lines_int_all_s.nextval
       INTO   l_int_line_tbl(1).resale_line_int_id
       FROM   DUAL;
       ozf_utility_pvt.debug_message('resale_line_int_id '||l_int_line_tbl(1).resale_line_int_id);
       IF  G_RESALE_BATCH_ID = 0 OR l_resale_batch_rec.resale_batch_id IS NULL THEN
           SELECT resale_batch_id
             INTO l_int_line_tbl(1).resale_batch_id
            FROM  ozf_resale_batches
           WHERE  batch_number = p_batch_number;
       ELSE
                l_int_line_tbl(1).resale_batch_id := G_RESALE_BATCH_ID;

       END IF;
       ozf_utility_pvt.debug_message('resale_batch_id '||l_int_line_tbl(1).resale_batch_id );

       l_text := l_text||'Resale Batch ID '||l_int_line_tbl(1).resale_batch_id||'  \n ';

       insert_resale_int_line (
         p_api_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         p_Commit                => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_int_line_tbl          => l_int_line_tbl,
         x_return_status         => x_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data  );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           l_text := l_text||'Error in Create Line '||SQLERRM||'  \n ';
           fnd_message.set_name ('OZF', 'OZF_WADI_CREATE_LINE_ERROR');
           l_error_message :=  fnd_message.get();
           raise_application_error( -20000, l_error_message);
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

    ELSIF   l_status_code IN ('OPEN','NEW','PROCESSED','DISPUTED') AND p_resale_line_int_id IS NOT NULL THEN

       ozf_utility_pvt.debug_message('P_BATCH_NUMBER '||P_BATCH_NUMBER);
       ozf_utility_pvt.debug_message('P_RESALE_LINE_INT_ID '||P_RESALE_LINE_INT_ID);

      OPEN  c_get_update_record (P_BATCH_NUMBER, P_RESALE_LINE_INT_ID);
      LOOP

         l_resale_line_int_id_tbl.extend;
            l_object_version_no_tbl.extend;

         j := l_resale_line_int_id_tbl.count;

           FETCH c_get_update_record
            INTO  l_resale_batch_rec.resale_batch_id,
                  l_resale_batch_rec.object_version_number,
                  l_object_version_no_tbl(1);
        EXIT WHEN c_get_update_record%NOTFOUND;

      END LOOP;
      CLOSE c_get_update_record;



      l_int_line_tbl(1).resale_line_int_id := p_resale_line_int_id;
      l_int_line_tbl(1).resale_batch_id    := l_resale_batch_rec.resale_batch_id;
      l_int_line_tbl(1).object_version_number := l_object_version_no_tbl(1);
      ozf_utility_pvt.debug_message('resale_line_int_id '||l_int_line_tbl(1).resale_line_int_id);
      ozf_utility_pvt.debug_message('resale_batch_id '||l_int_line_tbl(1).resale_batch_id);

      l_text := l_text||'resale_line_int_id '||l_int_line_tbl(1).resale_line_int_id;

    --  l_int_line_tbl(1).status_code := l_line_status;
    --  l_resale_batch_rec.status_code := l_status_code;

--  ==============================================================================
--  WebADI sends batch and line data together to this API and it is called
--  as many times as the number of lines exists, but batch has to be updated
--  the first time this API call is made.
--  ==============================================================================
      l_text := l_text||'Updating batch record ';

     IF G_RESALE_BATCH_NUMBER = 0 OR l_status_code <> 'NEW' THEN

       Update_Resale_Batch
       (
         p_api_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         P_Commit                => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         p_int_batch_rec         => l_resale_batch_rec,
         x_return_status         => x_return_status,
         x_msg_count             => l_msg_count,
         x_msg_data              => l_msg_data
       );

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           l_text := l_text||'Error in Update Batch '||SQLERRM||'  \n ';
           fnd_message.set_name ('OZF', 'OZF_WADI_UPDATE_BATCH_ERROR');
           l_error_message :=  fnd_message.get();
           raise_application_error( -20000, l_error_message);
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       ozf_utility_pvt.debug_message('x_return_status '||x_return_status);
     END IF;

      l_text := l_text||'Updating line record ';
     Update_Resale_Int_Line
     (
       p_api_version_number    => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       P_Commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       p_int_line_tbl          => l_int_line_tbl,
       x_return_status         => x_return_status,
       x_msg_count             => l_msg_count,
       x_msg_data              => l_msg_data
     );

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        l_text := l_text||'Error in Update Line '||SQLERRM||'  \n ';
       fnd_message.set_name ('OZF', 'OZF_WADI_UPDATE_LINE_ERROR');
       l_error_message :=  fnd_message.get();
       raise_application_error( -20000, l_error_message);
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
       ozf_utility_pvt.debug_message('x_return_status '||x_return_status);
      l_text := l_text||'line record updated';

     OZF_UTILITY_PVT.debug_message('Interface Lines Table is updated successfully ' ||x_return_status);

     G_RESALE_BATCH_NUMBER :=  P_BATCH_NUMBER;

  END IF;

  OZF_UTILITY_PVT.debug_message('length of text '||length(l_text));
  OZF_UTILITY_PVT.debug_message('length of text '||length(substr(l_text,1001,1000)));
  UTL_FILE.PUTF(l_file,l_text);
  UTL_FILE.FCLOSE(l_file);

EXCEPTION
   WHEN ozf_webadi_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      raise_application_error( -20000, l_error_message);
   WHEN UTL_FILE.INVALID_PATH THEN
      RAISE_APPLICATION_ERROR(-20100,'Invalid Path');
   WHEN UTL_FILE.INVALID_MODE THEN
      RAISE_APPLICATION_ERROR(-20101,'Invalid Mode');
   WHEN UTL_FILE.INVALID_OPERATION then
      RAISE_APPLICATION_ERROR(-20102,'Invalid Operation');
   WHEN UTL_FILE.INVALID_FILEHANDLE then
      RAISE_APPLICATION_ERROR(-20103,'Invalid Filehandle');
   WHEN UTL_FILE.WRITE_ERROR then
      RAISE_APPLICATION_ERROR(-20104,'Write Error');
   WHEN UTL_FILE.READ_ERROR then
      RAISE_APPLICATION_ERROR(-20105,'Read Error');
   WHEN UTL_FILE.INTERNAL_ERROR then
      RAISE_APPLICATION_ERROR(-20106,'Internal Error');
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      UTL_FILE.FCLOSE(l_file);
      IF length( SQLERRM) > 30 THEN
         ozf_utility_pvt.debug_message(substr(SQLERRM,12,30));
         fnd_message.set_name ('OZF', substr(SQLERRM,12,30));
      ELSE
         fnd_message.set_name ('OZF', SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
      UTL_FILE.FCLOSE(l_file);
      IF length( SQLERRM) > 30 THEN
         ozf_utility_pvt.debug_message(substr(SQLERRM,12,30));
         fnd_message.set_name ('OZF', substr(SQLERRM,12,30));
      ELSE
         fnd_message.set_name ('OZF', SQLERRM);
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END RESALE_WEBADI;

PROCEDURE Update_Resale_Batch (
   p_api_version_number    IN       NUMBER,
   p_init_msg_list         IN       VARCHAR2     := FND_API.G_FALSE,
   p_Commit                IN       VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN       NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_int_batch_rec         IN       ozf_resale_batches_all%rowtype,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Resale_Batch';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_resale_batch_rec          ozf_resale_batches_all%rowtype;

   CURSOR get_resale_batch (pc_batch_number VARCHAR2)
   IS
   SELECT last_update_date,
          last_updated_by,
          last_update_login,
          object_version_number,
          NVL(p_int_batch_rec.batch_type,batch_type),
          NVL(p_int_batch_rec.batch_count,batch_count),
          NVL(p_int_batch_rec.year,year),
          NVL(p_int_batch_rec.month,month),
          NVL(p_int_batch_rec.report_date,report_date),
          NVL(p_int_batch_rec.report_start_date,report_start_date),
          NVL(p_int_batch_rec.report_end_date,report_end_date),
          NVL(p_int_batch_rec.data_source_code,data_source_code),
          NVL(p_int_batch_rec.reference_type,reference_type),
          NVL(p_int_batch_rec.reference_number,reference_number),
          NVL(p_int_batch_rec.comments,comments),
          NVL(p_int_batch_rec.partner_claim_number,partner_claim_number),
          NVL(p_int_batch_rec.transaction_purpose_code,transaction_purpose_code),
          NVL(p_int_batch_rec.transaction_type_code,transaction_type_code),
          NVL(p_int_batch_rec.partner_type,partner_type),
          NVL(p_int_batch_rec.partner_party_id,partner_party_id),
          DECODE(p_int_batch_rec.partner_cust_account_id,
                NULL,partner_cust_account_id,
                DECODE(p_int_batch_rec.partner_cust_account_id,partner_cust_account_id,partner_cust_account_id,p_int_batch_rec.partner_cust_account_id )),
          DECODE(p_int_batch_rec.partner_site_id,
                NULL,partner_site_id,
                DECODE(p_int_batch_rec.partner_site_id,partner_site_id,partner_site_id,p_int_batch_rec.partner_site_id )),
          DECODE(p_int_batch_rec.partner_contact_name,
                NULL,partner_contact_party_id,
                DECODE(p_int_batch_rec.partner_contact_name,partner_contact_name,partner_contact_party_id,NULL )),
          NVL(p_int_batch_rec.partner_contact_name,partner_contact_name),
          NVL(p_int_batch_rec.partner_email,partner_email   ),
          NVL(p_int_batch_rec.partner_phone,partner_phone),
          NVL(p_int_batch_rec.partner_fax,partner_fax),
          NVL(p_int_batch_rec.currency_code,currency_code),
          NVL(p_int_batch_rec.claimed_amount,claimed_amount),
          NVL(p_int_batch_rec.credit_code,credit_code),
          NVL(p_int_batch_rec.attribute_category,attribute_category),
          NVL(p_int_batch_rec.attribute1,attribute1),
          NVL(p_int_batch_rec.attribute2,attribute2),
          NVL(p_int_batch_rec.attribute3,attribute3),
          NVL(p_int_batch_rec.attribute4,attribute4),
          NVL(p_int_batch_rec.attribute5,attribute5),
          NVL(p_int_batch_rec.attribute6,attribute6),
          NVL(p_int_batch_rec.attribute7,attribute7),
          NVL(p_int_batch_rec.attribute8,attribute8),
          NVL(p_int_batch_rec.attribute9,attribute9),
          NVL(p_int_batch_rec.attribute10,attribute10),
          NVL(p_int_batch_rec.attribute11,attribute11),
          NVL(p_int_batch_rec.attribute12,attribute12),
          NVL(p_int_batch_rec.attribute13,attribute13),
          NVL(p_int_batch_rec.attribute14,attribute14),
          NVL(p_int_batch_rec.attribute15,attribute15),
          NVL(p_int_batch_rec.batch_set_id_code,batch_set_id_code ),
          NVL(p_int_batch_rec.credit_advice_date,credit_advice_date),
          NVL(p_int_batch_rec.org_id,org_id),
          NVL(p_int_batch_rec.header_tolerance_operand,header_tolerance_operand),
          NVL(p_int_batch_rec.header_tolerance_calc_code,header_tolerance_calc_code),
          NVL(p_int_batch_rec.line_tolerance_operand,line_tolerance_operand),
          NVL(p_int_batch_rec.line_tolerance_calc_code,line_tolerance_calc_code),
          NVL(p_int_batch_rec.allowed_amount,allowed_amount),
          NVL(p_int_batch_rec.accepted_amount,accepted_amount),
          NVL(p_int_batch_rec.paid_amount,paid_amount),
          NVL(p_int_batch_rec.disputed_amount,disputed_amount),
          NVL(p_int_batch_rec.lines_invalid,lines_invalid),
          NVL(p_int_batch_rec.lines_w_tolerance,lines_w_tolerance),
          NVL(p_int_batch_rec.lines_disputed,lines_disputed),
          NVL(p_int_batch_rec.purge_flag,purge_flag)
    FROM  ozf_resale_batches
   WHERE  batch_number = pc_batch_number;

BEGIN
   OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_resale_batch_rec.resale_batch_id :=  p_int_batch_rec.resale_batch_id;
   l_resale_batch_rec.batch_number    :=  p_int_batch_rec.batch_number;
   l_resale_batch_rec.status_code     :=  'OPEN';


   OPEN  get_resale_batch ( p_int_batch_rec.batch_number);
   FETCH get_resale_batch
   INTO  l_resale_batch_rec.last_update_date,
         l_resale_batch_rec.last_updated_by,
         l_resale_batch_rec.last_update_login,
         l_resale_batch_rec.object_version_number,
         l_resale_batch_rec.batch_type,
         l_resale_batch_rec.batch_count,
         l_resale_batch_rec.year,
         l_resale_batch_rec.month,
         l_resale_batch_rec.report_date,
         l_resale_batch_rec.report_start_date,
         l_resale_batch_rec.report_end_date,
         l_resale_batch_rec.data_source_code,
         l_resale_batch_rec.reference_type,
         l_resale_batch_rec.reference_number,
         l_resale_batch_rec.comments,
         l_resale_batch_rec.partner_claim_number,
         l_resale_batch_rec.transaction_purpose_code,
         l_resale_batch_rec.transaction_type_code,
         l_resale_batch_rec.partner_type,
         l_resale_batch_rec.partner_party_id,
         l_resale_batch_rec.partner_cust_account_id,
         l_resale_batch_rec.partner_site_id,
         l_resale_batch_rec.partner_contact_party_id,
         l_resale_batch_rec.partner_contact_name,
         l_resale_batch_rec.partner_email,
         l_resale_batch_rec.partner_phone,
         l_resale_batch_rec.partner_fax,
         l_resale_batch_rec.currency_code,
         l_resale_batch_rec.claimed_amount,
         l_resale_batch_rec.credit_code,
         l_resale_batch_rec.attribute_category,
         l_resale_batch_rec.attribute1,
         l_resale_batch_rec.attribute2,
         l_resale_batch_rec.attribute3,
         l_resale_batch_rec.attribute4,
         l_resale_batch_rec.attribute5,
         l_resale_batch_rec.attribute6,
         l_resale_batch_rec.attribute7,
         l_resale_batch_rec.attribute8,
         l_resale_batch_rec.attribute9,
         l_resale_batch_rec.attribute10,
         l_resale_batch_rec.attribute11,
         l_resale_batch_rec.attribute12,
         l_resale_batch_rec.attribute13,
         l_resale_batch_rec.attribute14,
         l_resale_batch_rec.attribute15,
         l_resale_batch_rec.batch_set_id_code,
         l_resale_batch_rec.credit_advice_date,
         l_resale_batch_rec.org_id,
         l_resale_batch_rec.header_tolerance_operand,
         l_resale_batch_rec.header_tolerance_calc_code,
         l_resale_batch_rec.line_tolerance_operand,
         l_resale_batch_rec.line_tolerance_calc_code,
         l_resale_batch_rec.allowed_amount,
         l_resale_batch_rec.accepted_amount,
         l_resale_batch_rec.paid_amount,
         l_resale_batch_rec.disputed_amount,
         l_resale_batch_rec.lines_invalid,
         l_resale_batch_rec.lines_w_tolerance,
         l_resale_batch_rec.lines_disputed,
         l_resale_batch_rec.purge_flag;
   CLOSE get_resale_batch;

   ozf_pre_process_pvt.update_interface_batch
   (
      p_api_version_number    => 1.0,
      p_init_msg_list         => FND_API.G_FALSE,
      P_Commit                => FND_API.G_FALSE,
      p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
      p_int_batch_rec         => l_resale_batch_rec,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data
   );



   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
     -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
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

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Update_Resale_Batch;




PROCEDURE Update_Resale_Int_Line (
   p_api_version_number    IN       NUMBER,
   p_init_msg_list         IN       VARCHAR2     := FND_API.G_FALSE,
   p_Commit                IN       VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN       NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_int_line_tbl          IN       ozf_pre_process_pvt.resale_line_int_tbl_type,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Resale_Int_Line';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_int_line_tbl            ozf_pre_process_pvt.resale_line_int_tbl_type := ozf_pre_process_pvt.resale_line_int_tbl_type();

   CURSOR get_int_line ( pc_line_id    NUMBER
                       , pc_batch_id   NUMBER)
   IS
   SELECT  resale_line_int_id,
           object_version_number,
           last_update_date,
           last_updated_by,
           request_id,
           created_from,
           last_update_login,
           nvl(p_int_line_tbl(1).program_application_id,program_application_id),
           nvl(p_int_line_tbl(1).program_update_date,program_update_date),
           nvl(p_int_line_tbl(1).program_id,program_id),
           'OPEN',
           nvl(p_int_line_tbl(1).resale_transfer_type,resale_transfer_type),
           nvl(p_int_line_tbl(1).product_transfer_movement_type,product_transfer_movement_type ),
           nvl(p_int_line_tbl(1).product_transfer_date,product_transfer_date),
           nvl(p_int_line_tbl(1).tracing_flag,tracing_flag),
           DECODE(p_int_line_tbl(1).ship_from_party_name
                 ,NULL,ship_from_cust_account_id
                 ,DECODE(p_int_line_tbl(1).ship_from_party_name,ship_from_party_name,ship_from_cust_account_id, NULL)),
          DECODE(p_int_line_tbl(1).ship_from_location
                  ,NULL,DECODE(p_int_line_tbl(1).ship_from_address
                             ,NULL,ship_from_site_id
                             ,DECODE(p_int_line_tbl(1).ship_from_address, ship_from_address,ship_from_site_id,NULL))
                  ,DECODE(p_int_line_tbl(1).ship_from_location,ship_from_location,ship_from_site_id,NULL )),
           DECODE(p_int_line_tbl(1).ship_from_party_name,
                 ship_from_party_name,ship_from_party_name,
                                      p_int_line_tbl(1).ship_from_party_name),
          nvl(p_int_line_tbl(1).ship_from_location,ship_from_location),
          nvl(p_int_line_tbl(1).ship_from_address,ship_from_address),
          nvl(p_int_line_tbl(1).ship_from_city,ship_from_city),
          nvl(p_int_line_tbl(1).ship_from_state,ship_from_state),
          nvl(p_int_line_tbl(1).ship_from_postal_code,ship_from_postal_code),
          nvl(p_int_line_tbl(1).ship_from_country,ship_from_country),
          DECODE(p_int_line_tbl(1).ship_from_contact_name
                ,NULL,ship_from_contact_party_id
                ,decode(p_int_line_tbl(1).ship_from_contact_name,ship_from_contact_name,ship_from_contact_party_id, NULL)),
          nvl(p_int_line_tbl(1).ship_from_contact_name,ship_from_contact_name),
          nvl(p_int_line_tbl(1).ship_from_email,ship_from_email),
          nvl(p_int_line_tbl(1).ship_from_phone,ship_from_phone),
          nvl(p_int_line_tbl(1).ship_from_fax,ship_from_fax),
          DECODE(p_int_line_tbl(1).sold_from_party_name
                ,NULL,DECODE(p_int_line_tbl(1).ship_from_location, ship_from_location,sold_from_cust_account_id,
                                          NULL)
                ,decode(p_int_line_tbl(1).sold_from_party_name,sold_from_party_name,sold_from_cust_account_id, NULL)),
          DECODE(p_int_line_tbl(1).sold_from_location
                ,NULL,DECODE(p_int_line_tbl(1).sold_from_address
                             ,NULL,DECODE(p_int_line_tbl(1).ship_from_location, ship_from_location,sold_from_site_id,
                                          NULL)
                             ,DECODE(p_int_line_tbl(1).sold_from_address, sold_from_address,sold_from_site_id,NULL))
                ,DECODE(p_int_line_tbl(1).sold_from_location,sold_from_location,sold_from_site_id,NULL )),
         DECODE(p_int_line_tbl(1).sold_from_party_name,
                sold_from_party_name,sold_from_party_name,
                                   p_int_line_tbl(1).sold_from_party_name),
         nvl(p_int_line_tbl(1).sold_from_location,sold_from_location),
         nvl(p_int_line_tbl(1).sold_from_address,sold_from_address),
         nvl(p_int_line_tbl(1).sold_from_city,sold_from_city),
         nvl(p_int_line_tbl(1).sold_from_state,sold_from_state),
         nvl(p_int_line_tbl(1).sold_from_postal_code,sold_from_postal_code),
         nvl(p_int_line_tbl(1).sold_from_country,sold_from_country),
         DECODE(p_int_line_tbl(1).sold_from_contact_name
               ,NULL,sold_from_contact_party_id
               ,decode(p_int_line_tbl(1).sold_from_contact_name,sold_from_contact_name,sold_from_contact_party_id, NULL)),
         nvl(p_int_line_tbl(1).sold_from_contact_name,sold_from_contact_name),
         nvl(p_int_line_tbl(1).sold_from_email,sold_from_email),
         nvl(p_int_line_tbl(1).sold_from_phone,sold_from_phone),
         nvl(p_int_line_tbl(1).sold_from_fax,sold_from_fax),
         DECODE(p_int_line_tbl(1).bill_to_party_name
               ,NULL,DECODE(p_int_line_tbl(1).ship_to_location, ship_to_location,bill_to_cust_account_id,
                                          NULL)
               ,decode(p_int_line_tbl(1).bill_to_party_name,bill_to_party_name,bill_to_cust_account_id, NULL)),
         DECODE(p_int_line_tbl(1).bill_to_location
               ,NULL,DECODE(p_int_line_tbl(1).bill_to_address
                         ,NULL,DECODE(p_int_line_tbl(1).ship_to_location, ship_to_location,bill_to_site_use_id,
                                          NULL)
                        ,DECODE(p_int_line_tbl(1).bill_to_address, bill_to_address,bill_to_site_use_id,NULL))
               ,DECODE(p_int_line_tbl(1).bill_to_location,bill_to_location,bill_to_site_use_id,NULL )),
         DECODE(p_int_line_tbl(1).bill_to_party_name
               ,NULL,DECODE(p_int_line_tbl(1).ship_to_location, ship_to_location,bill_to_party_id,
                                          NULL)
               ,decode(p_int_line_tbl(1).bill_to_party_name,bill_to_party_name,bill_to_party_id, NULL)),
         DECODE(p_int_line_tbl(1).bill_to_location
                ,NULL,DECODE(p_int_line_tbl(1).bill_to_address
                         ,NULL,DECODE(p_int_line_tbl(1).ship_to_location, ship_to_location,bill_to_party_site_id,
                                          NULL)
                         ,DECODE(p_int_line_tbl(1).bill_to_address, bill_to_address,bill_to_party_site_id,NULL))
                ,DECODE(p_int_line_tbl(1).bill_to_location,bill_to_location,bill_to_party_site_id,NULL )),
         DECODE(p_int_line_tbl(1).bill_to_party_name, NULL,
                bill_to_party_name,bill_to_party_name,
                               p_int_line_tbl(1).bill_to_party_name),
         nvl(p_int_line_tbl(1).bill_to_duns_number,bill_to_duns_number),
         nvl(p_int_line_tbl(1).bill_to_location,bill_to_location),
         nvl(p_int_line_tbl(1).bill_to_address,bill_to_address),
         nvl(p_int_line_tbl(1).bill_to_city,bill_to_city),
         nvl(p_int_line_tbl(1).bill_to_state,bill_to_state),
         nvl(p_int_line_tbl(1).bill_to_postal_code,bill_to_postal_code),
         nvl(p_int_line_tbl(1).bill_to_country,bill_to_country),
         DECODE(p_int_line_tbl(1).bill_to_contact_name
               ,NULL,bill_to_contact_party_id
               ,decode(p_int_line_tbl(1).bill_to_contact_name,bill_to_contact_name,bill_to_contact_party_id, NULL)),
         nvl(p_int_line_tbl(1).bill_to_contact_name,bill_to_contact_name),
         nvl(p_int_line_tbl(1).bill_to_email,bill_to_email),
         nvl(p_int_line_tbl(1).bill_to_phone,bill_to_phone),
         nvl(p_int_line_tbl(1).bill_to_fax,bill_to_fax),
         DECODE(p_int_line_tbl(1).ship_to_party_name
               ,NULL,DECODE(p_int_line_tbl(1).ship_to_location, ship_to_location ,ship_to_cust_account_id,NULL)
               ,decode(p_int_line_tbl(1).ship_to_party_name,ship_to_party_name,ship_to_cust_account_id, NULL)),
         DECODE(p_int_line_tbl(1).ship_to_location
               ,NULL,DECODE(p_int_line_tbl(1).ship_to_address
                         ,NULL,ship_to_site_use_id
                         ,DECODE(p_int_line_tbl(1).ship_to_address, ship_to_address,ship_to_site_use_id,NULL))
               ,DECODE(p_int_line_tbl(1).ship_to_location,ship_to_location,ship_to_site_use_id,NULL )),
         DECODE(p_int_line_tbl(1).ship_to_party_name
               ,NULL,DECODE(p_int_line_tbl(1).ship_to_location, ship_to_location ,ship_to_cust_account_id,NULL)
               ,decode(p_int_line_tbl(1).ship_to_party_name,ship_to_party_name,ship_to_party_id, NULL)),
         DECODE(p_int_line_tbl(1).ship_to_location
               ,NULL,DECODE(p_int_line_tbl(1).ship_to_address
                            ,NULL,ship_to_party_site_id
                            ,DECODE(p_int_line_tbl(1).ship_to_address, ship_to_address,ship_to_party_site_id,NULL))
               ,DECODE(p_int_line_tbl(1).ship_to_location,ship_to_location,ship_to_party_site_id,NULL )),
         DECODE(p_int_line_tbl(1).ship_to_party_name,
                ship_to_party_name,ship_to_party_name,
                               p_int_line_tbl(1).ship_to_party_name),
         nvl(p_int_line_tbl(1).ship_to_duns_number,ship_to_duns_number),
         nvl(p_int_line_tbl(1).ship_to_location,ship_to_location),
         nvl(p_int_line_tbl(1).ship_to_address,ship_to_address),
         nvl(p_int_line_tbl(1).ship_to_city,ship_to_city),
         nvl(p_int_line_tbl(1).ship_to_state,ship_to_state),
         nvl(p_int_line_tbl(1).ship_to_postal_code,ship_to_postal_code),
         nvl(p_int_line_tbl(1).ship_to_country,ship_to_country),
         DECODE(p_int_line_tbl(1).ship_to_contact_name
               ,NULL,ship_to_contact_party_id
               ,decode(p_int_line_tbl(1).ship_to_contact_name,ship_to_contact_name,ship_to_contact_party_id, NULL)),
         nvl(p_int_line_tbl(1).ship_to_contact_name,ship_to_contact_name),
         nvl(p_int_line_tbl(1).ship_to_email,ship_to_email),
         nvl(p_int_line_tbl(1).ship_to_phone,ship_to_phone),
         nvl(p_int_line_tbl(1).ship_to_fax,ship_to_fax),
         DECODE(p_int_line_tbl(1).end_cust_party_name
               ,NULL,end_cust_party_id
               ,decode(p_int_line_tbl(1).end_cust_party_name,end_cust_party_name,end_cust_party_id, NULL)),
         DECODE(p_int_line_tbl(1).end_cust_location
               ,NULL,DECODE(p_int_line_tbl(1).end_cust_address
                           ,NULL,end_cust_site_use_id
                           ,DECODE(p_int_line_tbl(1).end_cust_address, end_cust_address,end_cust_site_use_id,NULL))
                  ,DECODE(p_int_line_tbl(1).end_cust_location,end_cust_location,end_cust_site_use_id,NULL )),
         nvl(p_int_line_tbl(1).end_cust_site_use_code,end_cust_site_use_code),
         DECODE(p_int_line_tbl(1).end_cust_location
               ,NULL,DECODE(p_int_line_tbl(1).end_cust_address
                           ,NULL,end_cust_party_site_id
                           ,DECODE(p_int_line_tbl(1).end_cust_address, end_cust_address,end_cust_party_site_id,NULL))
               ,DECODE(p_int_line_tbl(1).end_cust_location,end_cust_location,end_cust_party_site_id,NULL )),
         nvl(p_int_line_tbl(1).end_cust_party_name,end_cust_party_name),
         nvl(p_int_line_tbl(1).end_cust_location,end_cust_location),
         nvl(p_int_line_tbl(1).end_cust_address,end_cust_address),
         nvl(p_int_line_tbl(1).end_cust_city,end_cust_city),
         nvl(p_int_line_tbl(1).end_cust_state,end_cust_state),
         nvl(p_int_line_tbl(1).end_cust_postal_code,end_cust_postal_code),
         nvl(p_int_line_tbl(1).end_cust_country,end_cust_country),
         DECODE(p_int_line_tbl(1).end_cust_contact_name
               ,NULL,end_cust_contact_party_id
               ,decode(p_int_line_tbl(1).end_cust_contact_name,end_cust_contact_name,end_cust_contact_party_id, NULL)),
         nvl(p_int_line_tbl(1).end_cust_contact_name,end_cust_contact_name),
         nvl(p_int_line_tbl(1).end_cust_email,end_cust_email),
         nvl(p_int_line_tbl(1).end_cust_phone,end_cust_phone),
         nvl(p_int_line_tbl(1).end_cust_fax,end_cust_fax),
         nvl(p_int_line_tbl(1).direct_customer_flag,direct_customer_flag ),
         DECODE(p_int_line_tbl(1).order_type,NULL,order_type_id,NULL),
         nvl(p_int_line_tbl(1).order_type,order_type),
         nvl(p_int_line_tbl(1).order_category,order_category),
         DECODE(p_int_line_tbl(1).orig_system_agreement_type,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_type,NULL,agreement_type, p_int_line_tbl(1).agreement_type)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_type,orig_system_agreement_type, agreement_type, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_agreement_name,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_name,NULL,agreement_id, NULL)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_name,orig_system_agreement_name, agreement_id, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_agreement_name,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_name,NULL,agreement_name, p_int_line_tbl(1).agreement_name)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_name,orig_system_agreement_name, agreement_name, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_agreement_price,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_price,NULL,agreement_price, p_int_line_tbl(1).agreement_price)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_price,orig_system_agreement_price, agreement_price, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_agreement_uom,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_uom_code,NULL,agreement_uom_code, p_int_line_tbl(1).agreement_uom_code)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_uom,orig_system_agreement_uom, agreement_uom_code, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_agreement_name,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_name,NULL,corrected_agreement_id, NULL)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_name,orig_system_agreement_name, corrected_agreement_id, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_agreement_name,NULL
                                                      ,decode(p_int_line_tbl(1).agreement_name,NULL,corrected_agreement_name, NULL)
                                                      ,decode(p_int_line_tbl(1).orig_system_agreement_name,orig_system_agreement_name, corrected_agreement_name, NULL)),
         DECODE(p_int_line_tbl(1).price_list_name,NULL,price_list_id,NULL),
         nvl(p_int_line_tbl(1).price_list_name,price_list_name),
         nvl(p_int_line_tbl(1).orig_system_reference,orig_system_reference),
         nvl(p_int_line_tbl(1).orig_system_line_reference,orig_system_line_reference),
         nvl(p_int_line_tbl(1).orig_system_currency_code,orig_system_currency_code),
         nvl(p_int_line_tbl(1).orig_system_selling_price,orig_system_selling_price),
         nvl(p_int_line_tbl(1).orig_system_quantity,orig_system_quantity),
         nvl(p_int_line_tbl(1).orig_system_uom,orig_system_uom),
         nvl(p_int_line_tbl(1).orig_system_purchase_uom,orig_system_purchase_uom),
         nvl(p_int_line_tbl(1).orig_system_purchase_curr,orig_system_purchase_curr),
         nvl(p_int_line_tbl(1).orig_system_purchase_price,orig_system_purchase_price),
         nvl(p_int_line_tbl(1).orig_system_purchase_quantity,orig_system_purchase_quantity),
         nvl(p_int_line_tbl(1).orig_system_agreement_uom,orig_system_agreement_uom),
         nvl(p_int_line_tbl(1).orig_system_agreement_name,orig_system_agreement_name),
         nvl(p_int_line_tbl(1).orig_system_agreement_type,orig_system_agreement_type),
         nvl(p_int_line_tbl(1).orig_system_agreement_status,orig_system_agreement_status),
         nvl(p_int_line_tbl(1).orig_system_agreement_curr,orig_system_agreement_curr),
         nvl(p_int_line_tbl(1).orig_system_agreement_price,orig_system_agreement_price),
         nvl(p_int_line_tbl(1).orig_system_agreement_quantity,orig_system_agreement_quantity),
         nvl(p_int_line_tbl(1).orig_system_item_number,orig_system_item_number),
         nvl(p_int_line_tbl(1).currency_code,currency_code),
         nvl(p_int_line_tbl(1).exchange_rate,exchange_rate),
         nvl(p_int_line_tbl(1).exchange_rate_type,exchange_rate_type),
         nvl(p_int_line_tbl(1).exchange_rate_date,exchange_rate_date),
         nvl(p_int_line_tbl(1).po_number,po_number),
         nvl(p_int_line_tbl(1).po_release_number,po_release_number),
         nvl(p_int_line_tbl(1).po_type,po_type),
         nvl(p_int_line_tbl(1).invoice_number,invoice_number),
         nvl(p_int_line_tbl(1).date_invoiced,date_invoiced),
         nvl(p_int_line_tbl(1).order_number,order_number),
         nvl(p_int_line_tbl(1).date_ordered,date_ordered),
         nvl(p_int_line_tbl(1).date_shipped,date_shipped),
         nvl(p_int_line_tbl(1).claimed_amount,claimed_amount),
         nvl(p_int_line_tbl(1).allowed_amount,allowed_amount),
         nvl(p_int_line_tbl(1).total_allowed_amount,total_allowed_amount),
         nvl(p_int_line_tbl(1).accepted_amount,accepted_amount),
         nvl(p_int_line_tbl(1).total_accepted_amount,total_accepted_amount),
         nvl(p_int_line_tbl(1).line_tolerance_amount,line_tolerance_amount),
         nvl(p_int_line_tbl(1).tolerance_flag,tolerance_flag),
         DECODE(p_int_line_tbl(1).quantity,
                NULL,DECODE(p_int_line_tbl(1).orig_system_quantity,
                                              orig_system_quantity, total_claimed_amount,
                            (p_int_line_tbl(1).orig_system_quantity*p_int_line_tbl(1).claimed_amount)),
                DECODE(p_int_line_tbl(1).quantity, quantity,
                                                   total_claimed_amount,
                       (p_int_line_tbl(1).quantity*p_int_line_tbl(1).claimed_amount))),
         DECODE(p_int_line_tbl(1).orig_system_purchase_price,NULL
                                                      ,decode(p_int_line_tbl(1).purchase_price,NULL,purchase_price, p_int_line_tbl(1).purchase_price)
                                                      ,decode(p_int_line_tbl(1).orig_system_purchase_price,orig_system_purchase_price, purchase_price, NULL)),
             DECODE(p_int_line_tbl(1).orig_system_purchase_uom,NULL
                                                      ,decode(p_int_line_tbl(1).purchase_uom_code,NULL,purchase_uom_code, p_int_line_tbl(1).purchase_uom_code)
                                                      ,decode(p_int_line_tbl(1).orig_system_purchase_uom,orig_system_purchase_uom, purchase_uom_code, NULL)),
         nvl(p_int_line_tbl(1).acctd_purchase_price,acctd_purchase_price),
         DECODE(p_int_line_tbl(1).orig_system_selling_price,NULL
                                                      ,decode(p_int_line_tbl(1).selling_price,NULL,selling_price, p_int_line_tbl(1).selling_price)
                                                      ,decode(p_int_line_tbl(1).orig_system_selling_price,orig_system_selling_price, selling_price, NULL)),
         nvl(p_int_line_tbl(1).acctd_selling_price,acctd_selling_price  ),
         DECODE(p_int_line_tbl(1).orig_system_uom,NULL
                                          ,decode(p_int_line_tbl(1).uom_code,NULL,uom_code, p_int_line_tbl(1).uom_code)
                                                      ,decode(p_int_line_tbl(1).orig_system_uom,orig_system_uom, uom_code, NULL)),
         DECODE(p_int_line_tbl(1).orig_system_quantity,NULL
                                          ,decode(p_int_line_tbl(1).quantity,NULL,quantity, p_int_line_tbl(1).quantity)
                                                   ,decode(p_int_line_tbl(1).orig_system_quantity,orig_system_quantity, quantity, NULL)),
        nvl(p_int_line_tbl(1).calculated_price,calculated_price),
         nvl(p_int_line_tbl(1).acctd_calculated_price,acctd_calculated_price),
         nvl(p_int_line_tbl(1).calculated_amount,calculated_amount),
         nvl(p_int_line_tbl(1).credit_code,credit_code),
         nvl(p_int_line_tbl(1).credit_advice_date,credit_advice_date),
         nvl(p_int_line_tbl(1).upc_code,upc_code),
         DECODE(p_int_line_tbl(1).orig_system_item_number,NULL
                                          ,decode(p_int_line_tbl(1).inventory_item_id,NULL,inventory_item_id, p_int_line_tbl(1).inventory_item_id)
                                                      ,decode(p_int_line_tbl(1).orig_system_item_number,orig_system_item_number, inventory_item_id, NULL)),
         nvl(p_int_line_tbl(1).item_number,item_number),
         nvl(p_int_line_tbl(1).item_description,item_description),
         nvl(p_int_line_tbl(1).inventory_item_segment1,inventory_item_segment1),
         nvl(p_int_line_tbl(1).inventory_item_segment2,inventory_item_segment2),
         nvl(p_int_line_tbl(1).inventory_item_segment3,inventory_item_segment3),
         nvl(p_int_line_tbl(1).inventory_item_segment4,inventory_item_segment4),
         nvl(p_int_line_tbl(1).inventory_item_segment5,inventory_item_segment5),
         nvl(p_int_line_tbl(1).inventory_item_segment6,inventory_item_segment6),
         nvl(p_int_line_tbl(1).inventory_item_segment7,inventory_item_segment7),
         nvl(p_int_line_tbl(1).inventory_item_segment8,inventory_item_segment8),
         nvl(p_int_line_tbl(1).inventory_item_segment9,inventory_item_segment9),
         nvl(p_int_line_tbl(1).inventory_item_segment10,inventory_item_segment10),
         nvl(p_int_line_tbl(1).inventory_item_segment11,inventory_item_segment11),
         nvl(p_int_line_tbl(1).inventory_item_segment12,inventory_item_segment12),
         nvl(p_int_line_tbl(1).inventory_item_segment13,inventory_item_segment13),
         nvl(p_int_line_tbl(1).inventory_item_segment14,inventory_item_segment14),
         nvl(p_int_line_tbl(1).inventory_item_segment15,inventory_item_segment15),
         nvl(p_int_line_tbl(1).inventory_item_segment16,inventory_item_segment16),
         nvl(p_int_line_tbl(1).inventory_item_segment17,inventory_item_segment17),
         nvl(p_int_line_tbl(1).inventory_item_segment18,inventory_item_segment18),
         nvl(p_int_line_tbl(1).inventory_item_segment19,inventory_item_segment19),
         nvl(p_int_line_tbl(1).inventory_item_segment20,inventory_item_segment20),
         nvl(p_int_line_tbl(1).product_category_id,product_category_id),
         nvl(p_int_line_tbl(1).category_name,category_name),
         nvl(p_int_line_tbl(1).duplicated_line_id,duplicated_line_id),
         nvl(p_int_line_tbl(1).duplicated_adjustment_id,duplicated_adjustment_id),
         nvl(p_int_line_tbl(1).response_type,response_type),
         nvl(p_int_line_tbl(1).response_code,response_code),
         nvl(p_int_line_tbl(1).reject_reason_code,reject_reason_code),
         nvl(p_int_line_tbl(1).followup_action_code,followup_action_code),
         nvl(p_int_line_tbl(1).net_adjusted_amount,net_adjusted_amount),
         NULL dispute_code,
         nvl(p_int_line_tbl(1).data_source_code,data_source_code),
         nvl(p_int_line_tbl(1).header_attribute_category,header_attribute_category),
         nvl(p_int_line_tbl(1).header_attribute1,header_attribute1),
         nvl(p_int_line_tbl(1).header_attribute2,header_attribute2),
         nvl(p_int_line_tbl(1).header_attribute3,header_attribute3),
         nvl(p_int_line_tbl(1).header_attribute4,header_attribute4),
         nvl(p_int_line_tbl(1).header_attribute5,header_attribute5),
         nvl(p_int_line_tbl(1).header_attribute6,header_attribute6),
         nvl(p_int_line_tbl(1).header_attribute7,header_attribute7),
         nvl(p_int_line_tbl(1).header_attribute8,header_attribute8),
         nvl(p_int_line_tbl(1).header_attribute9,header_attribute9),
         nvl(p_int_line_tbl(1).header_attribute10,header_attribute10),
         nvl(p_int_line_tbl(1).header_attribute11,header_attribute11),
         nvl(p_int_line_tbl(1).header_attribute12,header_attribute12),
         nvl(p_int_line_tbl(1).header_attribute13,header_attribute13),
         nvl(p_int_line_tbl(1).header_attribute14,header_attribute14),
         nvl(p_int_line_tbl(1).header_attribute15,header_attribute15),
         nvl(p_int_line_tbl(1).line_attribute_category,line_attribute_category),
         nvl(p_int_line_tbl(1).line_attribute1,line_attribute1),
         nvl(p_int_line_tbl(1).line_attribute2,line_attribute2),
         nvl(p_int_line_tbl(1).line_attribute3,line_attribute3),
         nvl(p_int_line_tbl(1).line_attribute4,line_attribute4),
         nvl(p_int_line_tbl(1).line_attribute5,line_attribute5),
         nvl(p_int_line_tbl(1).line_attribute6,line_attribute6),
         nvl(p_int_line_tbl(1).line_attribute7,line_attribute7),
         nvl(p_int_line_tbl(1).line_attribute8,line_attribute8),
         nvl(p_int_line_tbl(1).line_attribute9,line_attribute9),
         nvl(p_int_line_tbl(1).line_attribute10,line_attribute10),
         nvl(p_int_line_tbl(1).line_attribute11,line_attribute11),
         nvl(p_int_line_tbl(1).line_attribute12,line_attribute12),
         nvl(p_int_line_tbl(1).line_attribute13,line_attribute13),
         nvl(p_int_line_tbl(1).line_attribute14,line_attribute14),
         nvl(p_int_line_tbl(1).line_attribute15,line_attribute15),
         nvl(p_int_line_tbl(1).org_id,org_id)
  FROM  ozf_resale_lines_int
  WHERE  resale_line_int_id = pc_line_id
    AND  resale_batch_id    = pc_batch_id;


BEGIN
   OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   OZF_UTILITY_PVT.debug_message('x_return_status ' || x_return_status);

   l_int_line_tbl.extend;
   l_int_line_tbl(1).resale_batch_id := p_int_line_tbl(1).resale_batch_id;

   OPEN get_int_line(p_int_line_tbl(1).resale_line_int_id, p_int_line_tbl(1).resale_batch_id);
   FETCH get_int_line INTO
          l_int_line_tbl(1).resale_line_int_id
         ,l_int_line_tbl(1).object_version_number
         ,l_int_line_tbl(1).last_update_date
         ,l_int_line_tbl(1).last_updated_by
         ,l_int_line_tbl(1).request_id
         ,l_int_line_tbl(1).created_from
         ,l_int_line_tbl(1).last_update_login
         ,l_int_line_tbl(1).program_application_id
         ,l_int_line_tbl(1).program_update_date
         ,l_int_line_tbl(1).program_id
         ,l_int_line_tbl(1).status_code
         ,l_int_line_tbl(1).resale_transfer_type
         ,l_int_line_tbl(1).product_transfer_movement_type
         ,l_int_line_tbl(1).product_transfer_date
         ,l_int_line_tbl(1).tracing_flag
         ,l_int_line_tbl(1).ship_from_cust_account_id
         ,l_int_line_tbl(1).ship_from_site_id
         ,l_int_line_tbl(1).ship_from_party_name
         ,l_int_line_tbl(1).ship_from_location
         ,l_int_line_tbl(1).ship_from_address
         ,l_int_line_tbl(1).ship_from_city
         ,l_int_line_tbl(1).ship_from_state
         ,l_int_line_tbl(1).ship_from_postal_code
         ,l_int_line_tbl(1).ship_from_country
         ,l_int_line_tbl(1).ship_from_contact_party_id
         ,l_int_line_tbl(1).ship_from_contact_name
         ,l_int_line_tbl(1).ship_from_email
         ,l_int_line_tbl(1).ship_from_phone
         ,l_int_line_tbl(1).ship_from_fax
         ,l_int_line_tbl(1).sold_from_cust_account_id
         ,l_int_line_tbl(1).sold_from_site_id
         ,l_int_line_tbl(1).sold_from_party_name
         ,l_int_line_tbl(1).sold_from_location
         ,l_int_line_tbl(1).sold_from_address
         ,l_int_line_tbl(1).sold_from_city
         ,l_int_line_tbl(1).sold_from_state
         ,l_int_line_tbl(1).sold_from_postal_code
         ,l_int_line_tbl(1).sold_from_country
         ,l_int_line_tbl(1).sold_from_contact_party_id
         ,l_int_line_tbl(1).sold_from_contact_name
         ,l_int_line_tbl(1).sold_from_email
         ,l_int_line_tbl(1).sold_from_phone
         ,l_int_line_tbl(1).sold_from_fax
         ,l_int_line_tbl(1).bill_to_cust_account_id
         ,l_int_line_tbl(1).bill_to_site_use_id
         ,l_int_line_tbl(1).bill_to_party_id
         ,l_int_line_tbl(1).bill_to_party_site_id
         ,l_int_line_tbl(1).bill_to_party_name
         ,l_int_line_tbl(1).bill_to_duns_number
         ,l_int_line_tbl(1).bill_to_location
         ,l_int_line_tbl(1).bill_to_address
         ,l_int_line_tbl(1).bill_to_city
         ,l_int_line_tbl(1).bill_to_state
         ,l_int_line_tbl(1).bill_to_postal_code
         ,l_int_line_tbl(1).bill_to_country
         ,l_int_line_tbl(1).bill_to_contact_party_id
         ,l_int_line_tbl(1).bill_to_contact_name
         ,l_int_line_tbl(1).bill_to_email
         ,l_int_line_tbl(1).bill_to_phone
         ,l_int_line_tbl(1).bill_to_fax
         ,l_int_line_tbl(1).ship_to_cust_account_id
         ,l_int_line_tbl(1).ship_to_site_use_id
         ,l_int_line_tbl(1).ship_to_party_id
         ,l_int_line_tbl(1).ship_to_party_site_id
         ,l_int_line_tbl(1).ship_to_party_name
         ,l_int_line_tbl(1).ship_to_duns_number
         ,l_int_line_tbl(1).ship_to_location
         ,l_int_line_tbl(1).ship_to_address
         ,l_int_line_tbl(1).ship_to_city
         ,l_int_line_tbl(1).ship_to_state
         ,l_int_line_tbl(1).ship_to_postal_code
         ,l_int_line_tbl(1).ship_to_country
         ,l_int_line_tbl(1).ship_to_contact_party_id
         ,l_int_line_tbl(1).ship_to_contact_name
         ,l_int_line_tbl(1).ship_to_email
         ,l_int_line_tbl(1).ship_to_phone
         ,l_int_line_tbl(1).ship_to_fax
         ,l_int_line_tbl(1).end_cust_party_id
         ,l_int_line_tbl(1).end_cust_site_use_id
         ,l_int_line_tbl(1).end_cust_site_use_code
         ,l_int_line_tbl(1).end_cust_party_site_id
         ,l_int_line_tbl(1).end_cust_party_name
         ,l_int_line_tbl(1).end_cust_location
         ,l_int_line_tbl(1).end_cust_address
         ,l_int_line_tbl(1).end_cust_city
         ,l_int_line_tbl(1).end_cust_state
         ,l_int_line_tbl(1).end_cust_postal_code
         ,l_int_line_tbl(1).end_cust_country
         ,l_int_line_tbl(1).end_cust_contact_party_id
         ,l_int_line_tbl(1).end_cust_contact_name
         ,l_int_line_tbl(1).end_cust_email
         ,l_int_line_tbl(1).end_cust_phone
         ,l_int_line_tbl(1).end_cust_fax
         ,l_int_line_tbl(1).direct_customer_flag
         ,l_int_line_tbl(1).order_type_id
         ,l_int_line_tbl(1).order_type
         ,l_int_line_tbl(1).order_category
         ,l_int_line_tbl(1).agreement_type
         ,l_int_line_tbl(1).agreement_id
         ,l_int_line_tbl(1).agreement_name
         ,l_int_line_tbl(1).agreement_price
         ,l_int_line_tbl(1).agreement_uom_code
         ,l_int_line_tbl(1).corrected_agreement_id
         ,l_int_line_tbl(1).corrected_agreement_name
         ,l_int_line_tbl(1).price_list_id
         ,l_int_line_tbl(1).price_list_name
         ,l_int_line_tbl(1).orig_system_reference
         ,l_int_line_tbl(1).orig_system_line_reference
         ,l_int_line_tbl(1).orig_system_currency_code
         ,l_int_line_tbl(1).orig_system_selling_price
         ,l_int_line_tbl(1).orig_system_quantity
         ,l_int_line_tbl(1).orig_system_uom
         ,l_int_line_tbl(1).orig_system_purchase_uom
         ,l_int_line_tbl(1).orig_system_purchase_curr
         ,l_int_line_tbl(1).orig_system_purchase_price
         ,l_int_line_tbl(1).orig_system_purchase_quantity
         ,l_int_line_tbl(1).orig_system_agreement_uom
         ,l_int_line_tbl(1).orig_system_agreement_name
         ,l_int_line_tbl(1).orig_system_agreement_type
         ,l_int_line_tbl(1).orig_system_agreement_status
         ,l_int_line_tbl(1).orig_system_agreement_curr
         ,l_int_line_tbl(1).orig_system_agreement_price
         ,l_int_line_tbl(1).orig_system_agreement_quantity
         ,l_int_line_tbl(1).orig_system_item_number
         ,l_int_line_tbl(1).currency_code
         ,l_int_line_tbl(1).exchange_rate
         ,l_int_line_tbl(1).exchange_rate_type
         ,l_int_line_tbl(1).exchange_rate_date
         ,l_int_line_tbl(1).po_number
         ,l_int_line_tbl(1).po_release_number
         ,l_int_line_tbl(1).po_type
         ,l_int_line_tbl(1).invoice_number
         ,l_int_line_tbl(1).date_invoiced
         ,l_int_line_tbl(1).order_number
         ,l_int_line_tbl(1).date_ordered
         ,l_int_line_tbl(1).date_shipped
         ,l_int_line_tbl(1).claimed_amount
         ,l_int_line_tbl(1).allowed_amount
         ,l_int_line_tbl(1).total_allowed_amount
         ,l_int_line_tbl(1).accepted_amount
         ,l_int_line_tbl(1).total_accepted_amount
         ,l_int_line_tbl(1).line_tolerance_amount
         ,l_int_line_tbl(1).tolerance_flag
         ,l_int_line_tbl(1).total_claimed_amount
         ,l_int_line_tbl(1).purchase_price
         ,l_int_line_tbl(1).purchase_uom_code
         ,l_int_line_tbl(1).acctd_purchase_price
         ,l_int_line_tbl(1).selling_price
         ,l_int_line_tbl(1).acctd_selling_price
         ,l_int_line_tbl(1).uom_code
         ,l_int_line_tbl(1).quantity
         ,l_int_line_tbl(1).calculated_price
         ,l_int_line_tbl(1).acctd_calculated_price
         ,l_int_line_tbl(1).calculated_amount
         ,l_int_line_tbl(1).credit_code
         ,l_int_line_tbl(1).credit_advice_date
         ,l_int_line_tbl(1).upc_code
         ,l_int_line_tbl(1).inventory_item_id
         ,l_int_line_tbl(1).item_number
         ,l_int_line_tbl(1).item_description
         ,l_int_line_tbl(1).inventory_item_segment1
         ,l_int_line_tbl(1).inventory_item_segment2
         ,l_int_line_tbl(1).inventory_item_segment3
         ,l_int_line_tbl(1).inventory_item_segment4
         ,l_int_line_tbl(1).inventory_item_segment5
         ,l_int_line_tbl(1).inventory_item_segment6
         ,l_int_line_tbl(1).inventory_item_segment7
         ,l_int_line_tbl(1).inventory_item_segment8
         ,l_int_line_tbl(1).inventory_item_segment9
         ,l_int_line_tbl(1).inventory_item_segment10
         ,l_int_line_tbl(1).inventory_item_segment11
         ,l_int_line_tbl(1).inventory_item_segment12
         ,l_int_line_tbl(1).inventory_item_segment13
         ,l_int_line_tbl(1).inventory_item_segment14
         ,l_int_line_tbl(1).inventory_item_segment15
         ,l_int_line_tbl(1).inventory_item_segment16
         ,l_int_line_tbl(1).inventory_item_segment17
         ,l_int_line_tbl(1).inventory_item_segment18
         ,l_int_line_tbl(1).inventory_item_segment19
         ,l_int_line_tbl(1).inventory_item_segment20
         ,l_int_line_tbl(1).product_category_id
         ,l_int_line_tbl(1).category_name
         ,l_int_line_tbl(1).duplicated_line_id
         ,l_int_line_tbl(1).duplicated_adjustment_id
         ,l_int_line_tbl(1).response_type
         ,l_int_line_tbl(1).response_code
         ,l_int_line_tbl(1).reject_reason_code
         ,l_int_line_tbl(1).followup_action_code
         ,l_int_line_tbl(1).net_adjusted_amount
         ,l_int_line_tbl(1).dispute_code
         ,l_int_line_tbl(1).data_source_code
         ,l_int_line_tbl(1).header_attribute_category
         ,l_int_line_tbl(1).header_attribute1
         ,l_int_line_tbl(1).header_attribute2
         ,l_int_line_tbl(1).header_attribute3
         ,l_int_line_tbl(1).header_attribute4
         ,l_int_line_tbl(1).header_attribute5
         ,l_int_line_tbl(1).header_attribute6
         ,l_int_line_tbl(1).header_attribute7
         ,l_int_line_tbl(1).header_attribute8
         ,l_int_line_tbl(1).header_attribute9
         ,l_int_line_tbl(1).header_attribute10
         ,l_int_line_tbl(1).header_attribute11
         ,l_int_line_tbl(1).header_attribute12
         ,l_int_line_tbl(1).header_attribute13
         ,l_int_line_tbl(1).header_attribute14
         ,l_int_line_tbl(1).header_attribute15
         ,l_int_line_tbl(1).line_attribute_category
         ,l_int_line_tbl(1).line_attribute1
         ,l_int_line_tbl(1).line_attribute2
         ,l_int_line_tbl(1).line_attribute3
         ,l_int_line_tbl(1).line_attribute4
         ,l_int_line_tbl(1).line_attribute5
         ,l_int_line_tbl(1).line_attribute6
         ,l_int_line_tbl(1).line_attribute7
         ,l_int_line_tbl(1).line_attribute8
         ,l_int_line_tbl(1).line_attribute9
         ,l_int_line_tbl(1).line_attribute10
         ,l_int_line_tbl(1).line_attribute11
         ,l_int_line_tbl(1).line_attribute12
         ,l_int_line_tbl(1).line_attribute13
         ,l_int_line_tbl(1).line_attribute14
         ,l_int_line_tbl(1).line_attribute15
         ,l_int_line_tbl(1).org_id ;
   CLOSE get_int_line;
   OZF_UTILITY_PVT.debug_message('x_return_status ' || x_return_status);

   Ozf_pre_process_pvt.Update_interface_line
   (
       p_api_version_number    => 1.0,
       p_init_msg_list         => FND_API.G_FALSE,
       P_Commit                => FND_API.G_FALSE,
       p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
       p_int_line_tbl          => l_int_line_tbl,
       x_return_status         => x_return_status,
       x_msg_count             => x_msg_count,
       x_msg_data              => x_msg_data
   );
   OZF_UTILITY_PVT.debug_message('x_return_status ' || x_return_status);

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

     -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );

   OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
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

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Update_Resale_Int_Line;

procedure insert_resale_int_line (
   p_api_version_number    IN       NUMBER,
   p_init_msg_list         IN       VARCHAR2     := FND_API.G_FALSE,
   p_Commit                IN       VARCHAR2     := FND_API.G_FALSE,
   p_validation_level      IN       NUMBER       := FND_API.G_VALID_LEVEL_FULL,
   p_int_line_tbl          IN       ozf_pre_process_pvt.resale_line_int_tbl_type,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2
)
IS

   l_api_name                  CONSTANT VARCHAR2(30) := 'insert_resale_int_line';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

   l_resale_line_int_id        NUMBER;
   l_object_version_number     NUMBER;
   l_org_id                    NUMBER;
   l_amount                    NUMBER := 0;
  BEGIN

   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

      -- Debug Message

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN


      IF p_int_line_tbl.count > 0 THEN

         FOR i in p_int_line_tbl.FIRST .. p_int_line_tbl.LAST
         LOOP

       l_resale_line_int_id := p_int_line_tbl(i).resale_line_int_id;
       l_object_version_number := 1;
       l_org_id       := p_int_line_tbl(i).org_id;

        OZF_RESALE_LINES_INT_PKG.INSERT_ROW
        (
        px_resale_line_int_id                =>  l_resale_line_int_id,
        px_object_version_number             =>  l_object_version_number,
        p_last_update_date                   =>  sysdate,
        p_last_updated_by                    =>  FND_GLOBAL.user_id,
        p_creation_date                      =>  sysdate,
        p_request_id                         =>  NULL,
        p_created_by                         =>  FND_GLOBAL.user_id,
        p_created_from                       =>  NULL,
        p_last_update_login                  =>  FND_GLOBAL.user_id,
        p_program_application_id             =>  NULL,
        p_program_update_date                =>  NULL,
        p_program_id                         =>  NULL,
        p_response_type                      =>  p_int_line_tbl(i).response_type,
        p_response_code                      =>  p_int_line_tbl(i).response_code,
        p_reject_reason_code                 =>  p_int_line_tbl(i).reject_reason_code,
        p_followup_action_code               =>  p_int_line_tbl(i).followup_action_code,
        p_resale_transfer_type               =>  p_int_line_tbl(i).resale_transfer_type,
        p_product_trans_movement_type        =>  p_int_line_tbl(i).product_transfer_movement_type,
        p_product_transfer_date              =>  p_int_line_tbl(i).product_transfer_date,
        p_resale_batch_id                    =>  p_int_line_tbl(i).resale_batch_id,
        p_status_code                        =>  'NEW',
        p_end_cust_party_id                  =>  p_int_line_tbl(i).end_cust_party_id,
        p_end_cust_site_use_id               =>  NULL,
        p_end_cust_site_use_code             =>  p_int_line_tbl(i).end_cust_site_use_code,
        p_end_cust_party_site_id             =>  NULL,
        -- Bug 4469837 (+)
        --p_end_cust_party_name                =>  NULL,
        p_end_cust_party_name                =>  p_int_line_tbl(i).end_cust_party_name,
        -- Bug 4469837 (-)
        p_end_cust_location                  =>  p_int_line_tbl(i).end_cust_location,
        p_end_cust_address                   =>  p_int_line_tbl(i).end_cust_address,
        p_end_cust_city                      =>  p_int_line_tbl(i).end_cust_city,
        p_end_cust_state                     =>  p_int_line_tbl(i).end_cust_state,
        p_end_cust_postal_code               =>  p_int_line_tbl(i).end_cust_postal_code,
        p_end_cust_country                   =>  p_int_line_tbl(i).end_cust_country,
        p_end_cust_contact_party_id          =>  NULL,
        p_end_cust_contact_name              =>  p_int_line_tbl(i).end_cust_contact_name,
        p_end_cust_email                     =>  p_int_line_tbl(i).end_cust_email,
        p_end_cust_phone                     =>  p_int_line_tbl(i).end_cust_phone,
        p_end_cust_fax                       =>  p_int_line_tbl(i).end_cust_fax,
        p_bill_to_cust_account_id            =>  p_int_line_tbl(i).bill_to_cust_account_id,
        p_bill_to_site_use_id                =>  NULL,
        -- Bug 4469837 (+)
        --p_bill_to_PARTY_NAME                 =>  NULL,
        p_bill_to_party_name                 =>  p_int_line_tbl(i).bill_to_party_name,
        -- Bug 4469837 (-)
        -- [BEGIN OF BUG 4186465 FIXING]
        p_bill_to_party_id                   =>  p_int_line_tbl(i).bill_to_party_id,
        p_bill_to_party_site_id              =>  p_int_line_tbl(i).bill_to_party_site_id,
        -- [END OF BUG 4186465 FIXING]
        p_bill_to_location                   =>  p_int_line_tbl(i).bill_to_location,
        p_bill_to_duns_number                =>  p_int_line_tbl(i).bill_to_duns_number,
        p_bill_to_address                    =>  p_int_line_tbl(i).bill_to_address,
        p_bill_to_city                       =>  p_int_line_tbl(i).bill_to_city,
        p_bill_to_state                      =>  p_int_line_tbl(i).bill_to_state,
        p_bill_to_postal_code                =>  p_int_line_tbl(i).bill_to_postal_code,
        p_bill_to_country                    =>  p_int_line_tbl(i).bill_to_country,
        p_bill_to_contact_party_id           =>  NULL,
        p_bill_to_contact_name               =>  p_int_line_tbl(i).bill_to_contact_name,
        p_bill_to_email                      =>  p_int_line_tbl(i).bill_to_email,
        p_bill_to_phone                      =>  p_int_line_tbl(i).bill_to_phone,
        p_bill_to_fax                        =>  p_int_line_tbl(i).bill_to_fax,
        p_ship_to_cust_account_id            =>  p_int_line_tbl(i).ship_to_cust_account_id,
        p_ship_to_site_use_id                =>  NULL,
        -- Bug 4469837 (+)
        --p_ship_to_PARTY_NAME                 =>  NULL,
        p_ship_to_party_name                 =>  p_int_line_tbl(i).ship_to_party_name,
        -- Bug 4469837 (-)
        -- [BEGIN OF BUG 4186465 FIXING]
        p_ship_to_party_id                   =>  p_int_line_tbl(i).ship_to_party_id,
        p_ship_to_party_site_id              =>  p_int_line_tbl(i).ship_to_party_site_id,
        -- [END OF BUG 4186465 FIXING]
        p_ship_to_duns_number                =>  p_int_line_tbl(i).ship_to_duns_number,
        p_ship_to_location                   =>  p_int_line_tbl(i).ship_to_location,
        p_ship_to_address                    =>  p_int_line_tbl(i).ship_to_address,
        p_ship_to_city                       =>  p_int_line_tbl(i).ship_to_city,
        p_ship_to_state                      =>  p_int_line_tbl(i).ship_to_state,
        p_ship_to_postal_code                =>  p_int_line_tbl(i).ship_to_postal_code,
        p_ship_to_country                    =>  p_int_line_tbl(i).ship_to_country,
        p_ship_to_contact_party_id           =>  NULL,
        p_ship_to_contact_name               =>  p_int_line_tbl(i).ship_to_contact_name,
        p_ship_to_email                      =>  p_int_line_tbl(i).ship_to_email,
        p_ship_to_phone                      =>  p_int_line_tbl(i).ship_to_phone,
        p_ship_to_fax                        =>  p_int_line_tbl(i).ship_to_fax,
        p_ship_from_cust_account_id          =>  p_int_line_tbl(i).ship_from_cust_account_id,
        p_ship_from_site_id                  =>  NULL,
        p_ship_from_PARTY_NAME               =>  NULL,
        p_ship_from_location                 =>  p_int_line_tbl(i).ship_from_location,
        p_ship_from_address                  =>  p_int_line_tbl(i).ship_from_address,
        p_ship_from_city                     =>  p_int_line_tbl(i).ship_from_city,
        p_ship_from_state                    =>  p_int_line_tbl(i).ship_from_state,
        p_ship_from_postal_code              =>  p_int_line_tbl(i).ship_from_postal_code,
        p_ship_from_country                  =>  p_int_line_tbl(i).ship_from_country,
        p_ship_from_contact_party_id         =>  NULL,
        p_ship_from_contact_name             =>  p_int_line_tbl(i).ship_from_contact_name,
        p_ship_from_email                    =>  p_int_line_tbl(i).ship_from_email,
        p_ship_from_phone                    =>  p_int_line_tbl(i).ship_from_phone,
        p_ship_from_fax                      =>  p_int_line_tbl(i).ship_from_fax,
        p_sold_from_cust_account_id          =>  p_int_line_tbl(i).sold_from_cust_account_id,
        p_sold_from_site_id                  =>  NULL,
        p_sold_from_PARTY_NAME               =>  NULL,
        p_sold_from_location                 =>  p_int_line_tbl(i).sold_from_location,
        p_sold_from_address                  =>  p_int_line_tbl(i).sold_from_address,
        p_sold_from_city                     =>  p_int_line_tbl(i).sold_from_city,
        p_sold_from_state                    =>  p_int_line_tbl(i).sold_from_state,
        p_sold_from_postal_code              =>  p_int_line_tbl(i).sold_from_postal_code,
        p_sold_from_country                  =>  p_int_line_tbl(i).sold_from_country,
        p_sold_from_contact_party_id         =>  NULL,
        p_sold_from_contact_name             =>  p_int_line_tbl(i).sold_from_contact_name,
        p_sold_from_email                    =>  p_int_line_tbl(i).sold_from_email,
        p_sold_from_phone                    =>  p_int_line_tbl(i).sold_from_phone,
        p_sold_from_fax                      =>  p_int_line_tbl(i).sold_from_fax,
        p_order_number                       =>  p_int_line_tbl(i).order_number,
        p_date_ordered                       =>  p_int_line_tbl(i).date_ordered,
        p_po_number                          =>  p_int_line_tbl(i).po_number,
        p_po_release_number                  =>  p_int_line_tbl(i).po_release_number,
        p_po_type                            =>  p_int_line_tbl(i).po_type,
        p_agreement_id                       =>  NULL,
        p_agreement_name                     =>  p_int_line_tbl(i).agreement_name,
        p_agreement_type                     =>  p_int_line_tbl(i).agreement_type,
        p_agreement_price                    =>  p_int_line_tbl(i).agreement_price,
        p_agreement_uom_code                 =>  p_int_line_tbl(i).agreement_uom_code,
        p_corrected_agreement_id             =>  NULL,
        p_corrected_agreement_name           =>  NULL,
        p_price_list_id                      =>  NULL,
        p_price_list_name                    =>  NULL,
        p_orig_system_quantity               =>  p_int_line_tbl(i).orig_system_quantity,
        p_orig_system_uom                    =>  p_int_line_tbl(i).orig_system_uom,
        p_orig_system_currency_code          =>  p_int_line_tbl(i).orig_system_currency_code,
        p_orig_system_selling_price          =>  p_int_line_tbl(i).orig_system_selling_price,
        p_orig_system_reference              =>  p_int_line_tbl(i).orig_system_reference,
        p_orig_system_line_reference         =>  p_int_line_tbl(i).orig_system_line_reference,
        p_orig_system_purchase_uom           =>  p_int_line_tbl(i).orig_system_purchase_uom,
        p_orig_system_purchase_curr          =>  p_int_line_tbl(i).orig_system_purchase_curr,
        p_orig_system_purchase_price         =>  p_int_line_tbl(i).orig_system_purchase_price,
        p_orig_system_purchase_quant         =>  p_int_line_tbl(i).orig_system_purchase_quantity,
        p_orig_system_agreement_uom          =>  p_int_line_tbl(i).orig_system_agreement_uom,
        p_ORIG_SYSTEM_AGREEMENT_name         =>  p_int_line_tbl(i).orig_system_agreement_name,
        p_orig_system_agreement_type         =>  p_int_line_tbl(i).orig_system_agreement_type,
        p_orig_system_agreement_status       =>  p_int_line_tbl(i).orig_system_agreement_status,
        p_orig_system_agreement_curr         =>  p_int_line_tbl(i).orig_system_agreement_curr,
        p_orig_system_agreement_price        =>  p_int_line_tbl(i).orig_system_agreement_price,
        p_orig_system_agreement_quant        =>  p_int_line_tbl(i).orig_system_agreement_quantity,
        p_orig_system_item_number            =>  p_int_line_tbl(i).orig_system_item_number,
        p_quantity                           =>  p_int_line_tbl(i).quantity,
        p_uom_code                           =>  p_int_line_tbl(i).uom_code,
        p_currency_code                      =>  p_int_line_tbl(i).currency_code,
        p_exchange_rate                      =>  p_int_line_tbl(i).exchange_rate,
        p_exchange_rate_type                 =>  p_int_line_tbl(i).exchange_rate_type,
        p_exchange_rate_date                 =>  p_int_line_tbl(i).exchange_rate_date,
        p_selling_price                      =>  p_int_line_tbl(i).selling_price,
        p_purchase_uom_code                  =>  p_int_line_tbl(i).purchase_uom_code,
        p_invoice_number                     =>  p_int_line_tbl(i).invoice_number,
        p_date_invoiced                      =>  p_int_line_tbl(i).date_invoiced,
        p_date_shipped                       =>  p_int_line_tbl(i).date_shipped,
        p_credit_advice_date                 =>  p_int_line_tbl(i).credit_advice_date,
        p_product_category_id                =>  NULL,
        p_category_name                      =>  NULL,
        p_inventory_item_segment1            =>  p_int_line_tbl(i).inventory_item_segment1,
        p_inventory_item_segment2            =>  p_int_line_tbl(i).inventory_item_segment2,
        p_inventory_item_segment3            =>  p_int_line_tbl(i).inventory_item_segment3,
        p_inventory_item_segment4            =>  p_int_line_tbl(i).inventory_item_segment4,
        p_inventory_item_segment5            =>  p_int_line_tbl(i).inventory_item_segment5,
        p_inventory_item_segment6            =>  p_int_line_tbl(i).inventory_item_segment6,
        p_inventory_item_segment7            =>  p_int_line_tbl(i).inventory_item_segment7,
        p_inventory_item_segment8            =>  p_int_line_tbl(i).inventory_item_segment8,
        p_inventory_item_segment9            =>  p_int_line_tbl(i).inventory_item_segment9,
        p_inventory_item_segment10           =>  p_int_line_tbl(i).inventory_item_segment10,
        p_inventory_item_segment11           =>  p_int_line_tbl(i).inventory_item_segment11,
        p_inventory_item_segment12           =>  p_int_line_tbl(i).inventory_item_segment12,
        p_inventory_item_segment13           =>  p_int_line_tbl(i).inventory_item_segment13,
        p_inventory_item_segment14           =>  p_int_line_tbl(i).inventory_item_segment14,
        p_inventory_item_segment15           =>  p_int_line_tbl(i).inventory_item_segment15,
        p_inventory_item_segment16           =>  p_int_line_tbl(i).inventory_item_segment16,
        p_inventory_item_segment17           =>  p_int_line_tbl(i).inventory_item_segment17,
        p_inventory_item_segment18           =>  p_int_line_tbl(i).inventory_item_segment18,
        p_inventory_item_segment19           =>  p_int_line_tbl(i).inventory_item_segment19,
        p_inventory_item_segment20           =>  p_int_line_tbl(i).inventory_item_segment20,
        p_inventory_item_id                  =>  p_int_line_tbl(i).inventory_item_id,
        p_item_description                   =>  NULL,
        p_upc_code                           =>  p_int_line_tbl(i).upc_code,
        p_item_number                        =>  NULL,
        p_claimed_amount                     =>  p_int_line_tbl(i).claimed_amount,
        p_purchase_price                     =>  p_int_line_tbl(i).purchase_price,
        p_acctd_purchase_price               =>  NULL,
        p_net_adjusted_amount                =>  NULL,
        p_accepted_amount                    =>  l_amount,
        p_total_accepted_amount              =>  l_amount,
        p_allowed_amount                     =>  l_amount,
        p_total_allowed_amount               =>  l_amount,
        p_calculated_price                   =>  l_amount,
        p_acctd_calculated_price             =>  l_amount,
        p_calculated_amount                  =>  l_amount,
        p_line_tolerance_amount              =>  NULL,
        p_total_claimed_amount               =>  p_int_line_tbl(i).total_claimed_amount,
        p_credit_code                        =>  p_int_line_tbl(i).credit_code,
        p_direct_customer_flag               =>  NULL,
        p_duplicated_line_id                 =>  NULL,
        p_duplicated_adjustment_id           =>  NULL,
        p_order_type_id                      =>  NULL,
        p_order_type                         =>  p_int_line_tbl(i).order_type,
        p_order_category                     =>  p_int_line_tbl(i).order_category,
        p_dispute_code                       =>  NULL,
        p_data_source_code                         =>  p_int_line_tbl(i).data_source_code,
        p_tracing_flag                       =>  p_int_line_tbl(i).tracing_flag,
        p_header_attribute_category          =>  p_int_line_tbl(i).header_attribute_category,
        p_header_attribute1                  =>  p_int_line_tbl(i).header_attribute1,
        p_header_attribute2                  =>  p_int_line_tbl(i).header_attribute2,
        p_header_attribute3                  =>  p_int_line_tbl(i).header_attribute3,
        p_header_attribute4                  =>  p_int_line_tbl(i).header_attribute4,
        p_header_attribute5                  =>  p_int_line_tbl(i).header_attribute5,
        p_header_attribute6                  =>  p_int_line_tbl(i).header_attribute6,
        p_header_attribute7                  =>  p_int_line_tbl(i).header_attribute7,
        p_header_attribute8                  =>  p_int_line_tbl(i).header_attribute8,
        p_header_attribute9                  =>  p_int_line_tbl(i).header_attribute9,
        p_header_attribute10                 =>  p_int_line_tbl(i).header_attribute10,
        p_header_attribute11                 =>  p_int_line_tbl(i).header_attribute11,
        p_header_attribute12                 =>  p_int_line_tbl(i).header_attribute12,
        p_header_attribute13                 =>  p_int_line_tbl(i).header_attribute13,
        p_header_attribute14                 =>  p_int_line_tbl(i).header_attribute14,
        p_header_attribute15                 =>  p_int_line_tbl(i).header_attribute15,
        p_line_attribute_category            =>  p_int_line_tbl(i).line_attribute_category,
        p_line_attribute1                    =>  p_int_line_tbl(i).line_attribute1,
        p_line_attribute2                    =>  p_int_line_tbl(i).line_attribute2,
        p_line_attribute3                    =>  p_int_line_tbl(i).line_attribute3,
        p_line_attribute4                    =>  p_int_line_tbl(i).line_attribute4,
        p_line_attribute5                    =>  p_int_line_tbl(i).line_attribute5,
        p_line_attribute6                    =>  p_int_line_tbl(i).line_attribute6,
        p_line_attribute7                    =>  p_int_line_tbl(i).line_attribute7,
        p_line_attribute8                    =>  p_int_line_tbl(i).line_attribute8,
        p_line_attribute9                    =>  p_int_line_tbl(i).line_attribute9,
        p_line_attribute10                   =>  p_int_line_tbl(i).line_attribute10,
        p_line_attribute11                   =>  p_int_line_tbl(i).line_attribute11,
        p_line_attribute12                   =>  p_int_line_tbl(i).line_attribute12,
        p_line_attribute13                   =>  p_int_line_tbl(i).line_attribute13,
        p_line_attribute14                   =>  p_int_line_tbl(i).line_attribute14,
        p_line_attribute15                   =>  p_int_line_tbl(i).line_attribute15,
        px_org_id                            =>  l_org_id );

      END LOOP;
    END IF;
       EXCEPTION

          WHEN OTHERS THEN

             ozf_utility_pvt.debug_message('Problem with updating line record   '||SQLERRM);
             RAISE FND_API.G_EXC_ERROR;

       END;


     -- Standard call to get message count and if count is 1, get message info.
     FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

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
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );


END insert_resale_int_line;

END OZF_WEBADI_INTERFACE_PVT;

/
