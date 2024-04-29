--------------------------------------------------------
--  DDL for Package Body OE_INVOICE_EXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INVOICE_EXT_PVT" AS
/*  $Header: OEXVINVB.pls 115.1 2003/10/20 07:24:27 appldev ship $ */

Procedure Insert_Salescredit(p_salescredit_rec  IN Oe_Invoice_Pub.Ra_Interface_Scredits_Rec_Type) IS
Begin
  INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
                 (CREATED_BY
                  ,CREATION_DATE
                  ,LAST_UPDATED_BY
                  ,LAST_UPDATE_DATE
                  ,INTERFACE_SALESCREDIT_ID
                  ,INTERFACE_LINE_ID
                  ,INTERFACE_LINE_CONTEXT
                  ,INTERFACE_LINE_ATTRIBUTE1
                  ,INTERFACE_LINE_ATTRIBUTE2
                  ,INTERFACE_LINE_ATTRIBUTE3
                  ,INTERFACE_LINE_ATTRIBUTE4
                  ,INTERFACE_LINE_ATTRIBUTE5
                  ,INTERFACE_LINE_ATTRIBUTE6
                  ,INTERFACE_LINE_ATTRIBUTE7
                  ,INTERFACE_LINE_ATTRIBUTE8
                  ,INTERFACE_LINE_ATTRIBUTE9
                  ,INTERFACE_LINE_ATTRIBUTE10
                  ,INTERFACE_LINE_ATTRIBUTE11
                  ,INTERFACE_LINE_ATTRIBUTE12
                  ,INTERFACE_LINE_ATTRIBUTE13
                  ,INTERFACE_LINE_ATTRIBUTE14
                  ,INTERFACE_LINE_ATTRIBUTE15
                  ,SALESREP_NUMBER
                  ,SALESREP_ID
                  ,SALES_CREDIT_TYPE_NAME
                  ,SALES_CREDIT_TYPE_ID
                  ,SALES_CREDIT_AMOUNT_SPLIT
                  ,SALES_CREDIT_PERCENT_SPLIT
           --SG
           --       ,SALES_GROUP_ID
           --SG
                  ,INTERFACE_STATUS
                  ,REQUEST_ID
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
                  ,ORG_ID)
            VALUES
                  (p_salescredit_rec.CREATED_BY
                  ,p_salescredit_rec.CREATION_DATE
                  ,p_salescredit_rec.LAST_UPDATED_BY
                  ,p_salescredit_rec.LAST_UPDATE_DATE
                  ,p_salescredit_rec.INTERFACE_SALESCREDIT_ID
                  ,p_salescredit_rec.INTERFACE_LINE_ID
                  ,p_salescredit_rec.INTERFACE_LINE_CONTEXT
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE1
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE2
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE3
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE4
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE5
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE6
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE7
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE8
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE9
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE10
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE11
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE12
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE13
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE14
                  ,p_salescredit_rec.INTERFACE_LINE_ATTRIBUTE15
                  ,p_salescredit_rec.SALESREP_NUMBER
                  ,p_salescredit_rec.SALESREP_ID
                  ,p_salescredit_rec.SALES_CREDIT_TYPE_NAME
                  ,p_salescredit_rec.SALES_CREDIT_TYPE_ID
                  ,p_salescredit_rec.SALES_CREDIT_AMOUNT_SPLIT
                  ,p_salescredit_rec.SALES_CREDIT_PERCENT_SPLIT
           --SG
           --       ,p_salescredit_rec.SALES_GROUP_ID
           --SG
                  ,p_salescredit_rec.INTERFACE_STATUS
                  ,p_salescredit_rec.REQUEST_ID
                  ,p_salescredit_rec.ATTRIBUTE_CATEGORY
                  ,p_salescredit_rec.ATTRIBUTE1
                  ,p_salescredit_rec.ATTRIBUTE2
                  ,p_salescredit_rec.ATTRIBUTE3
                  ,p_salescredit_rec.ATTRIBUTE4
                  ,p_salescredit_rec.ATTRIBUTE5
                  ,p_salescredit_rec.ATTRIBUTE6
                  ,p_salescredit_rec.ATTRIBUTE7
                  ,p_salescredit_rec.ATTRIBUTE8
                  ,p_salescredit_rec.ATTRIBUTE9
                  ,p_salescredit_rec.ATTRIBUTE10
                  ,p_salescredit_rec.ATTRIBUTE11
                  ,p_salescredit_rec.ATTRIBUTE12
                  ,p_salescredit_rec.ATTRIBUTE13
                  ,p_salescredit_rec.ATTRIBUTE14
                  ,p_salescredit_rec.ATTRIBUTE15
                  ,p_salescredit_rec.ORG_ID);
          OE_DEBUG_PUB.ADD('Successfully inserted Sales Credit Records',5);
EXCEPTION WHEN OTHERS THEN
          OE_DEBUG_PUB.add('Unable to insert Sales Credit records -> '||sqlerrm,1);
          NULL;
END Insert_Salescredit;

END OE_Invoice_Ext_Pvt;

/
