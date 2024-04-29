--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_LIMITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_LIMITS" AS
/* $Header: QPXLLMTB.pls 120.1 2005/06/08 04:27:49 appldev  $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Limits';

PROCEDURE Validate_List_Header_Limits
(x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
)
IS
l_list_type_code         VARCHAR2(30) := null;
l_error_code             NUMBER := 0;
l_return_status          VARCHAR2(1);
BEGIN


   SELECT list_type_code into l_list_type_code from QP_LIST_HEADERS_B
   WHERE LIST_HEADER_ID = p_LIMITS_rec.list_header_id;

       IF (l_list_type_code IN ('DLT','SLT','DEL','PRO'))
       THEN
           IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE'))
           THEN
               IF p_LIMITS_rec.limit_level_code = 'TRANSACTION'
               THEN
                   IF  (p_LIMITS_rec.organization_flag = 'N')
                   THEN
                       IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER') AND
                          (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER'))
                          THEN
                              l_error_code := 0;
                              x_return_status := FND_API.G_RET_STS_SUCCESS;
                              return;
                          ELSE
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_NOT_ALLOWED');
                              OE_MSG_PUB.Add;
                              l_error_code := 1;
                              return;
                          END IF;
                   ELSE
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.SET_NAME('QP','QP_ORG_NOT_ALLOWED');
                       OE_MSG_PUB.Add;
                       l_error_code := 1;
                       return;
                   END IF;
               END IF;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
              OE_MSG_PUB.Add;
              l_error_code := 1;
              return;
           END IF;

          --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 1' || 'l_error_code = ' || l_error_code);

       END IF;

       IF (l_list_type_code = 'CHARGES')
       THEN
           IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','CHARGE','USAGE'))
           THEN
               IF p_LIMITS_rec.limit_level_code = 'TRANSACTION'
               THEN
                   IF  (p_LIMITS_rec.organization_flag = 'N')
                   THEN
                       IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER') AND
                          (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER'))
                          THEN
                              l_error_code := 0;
                              x_return_status := FND_API.G_RET_STS_SUCCESS;
                              return;
                          ELSE
                              x_return_status := FND_API.G_RET_STS_ERROR;
                              FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_NOT_ALLOWED');
                              OE_MSG_PUB.Add;
                              l_error_code := 1;
                              return;
                          END IF;
                   ELSE
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       FND_MESSAGE.SET_NAME('QP','QP_ORG_NOT_ALLOWED');
                       OE_MSG_PUB.Add;
                       l_error_code := 1;
                       return;
                   END IF;
               END IF;
           ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
              OE_MSG_PUB.Add;
              l_error_code := 1;
              return;
           END IF;

          --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 2' || 'l_error_code = ' || l_error_code);
       END IF;

   IF l_error_code = 0  --  Validation Passed
   THEN
       l_return_status := FND_API.G_RET_STS_SUCCESS;

   END IF;

   --Done validating List Header Limits

   x_return_status := l_return_status;

EXCEPTION

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_List_Header_Limits'
            );
        END IF;

END Validate_List_Header_Limits;

--  Procedure Entity

PROCEDURE Validate_List_Line_Limits
(x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
)
IS
l_list_line_type_code    VARCHAR2(30) := null;
l_application_method     VARCHAR2(30) := null;
l_modifier_level_code    VARCHAR2(30) := null;
l_accrual_flag           VARCHAR2(1) := null;
l_return_status          VARCHAR2(1);
l_benefit_qty            NUMBER := 0;
l_error_code             NUMBER := 0;
l_qualification_ind      NUMBER := 0;
l_monetary_accrual       BOOLEAN := false;
l_non_monetary_accrual   BOOLEAN := false;
l_accruals_also          BOOLEAN := false;
l_applies_to_entire_brk  BOOLEAN := false;
l_applies_to_entire_mod  BOOLEAN := false;
BEGIN


       --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY Before Select Statement' || 'l_error_code = ' || l_error_code);
   SELECT LIST_LINE_TYPE_CODE,
          BENEFIT_QTY,
          ACCRUAL_FLAG,
          ARITHMETIC_OPERATOR,
          MODIFIER_LEVEL_CODE,
          QUALIFICATION_IND
   INTO
          l_list_line_type_code,
          l_benefit_qty,
          l_accrual_flag,
          l_application_method,
          l_modifier_level_code,
          l_qualification_ind
   FROM   QP_LIST_LINES
   WHERE LIST_LINE_ID = p_LIMITS_rec.list_line_id;

   --DBMS_OUTPUT.PUT_LINE('LIST_LINE_TYPE_CODE ' || l_list_line_type_code || ' BENEFIT_QTY ' || l_benefit_qty || ' ACCRUAL_FLAG ' || l_accrual_flag || ' ARITHMETIC_OPERATOR ' || l_application_method || ' MODIFIER_LEVEL_CODE ' || l_modifier_level_code);

-- Check for Monetary/Non-Monetary Accrual

   IF (l_accrual_flag = 'Y') and (nvl(l_benefit_qty,0) <> 0)
   THEN
      l_non_monetary_accrual := true;
   ELSIF (l_accrual_flag = 'Y') and (nvl(l_benefit_qty,0) = 0)
   THEN
      l_monetary_accrual := true;
   END IF;

-- Check for Accruals Also

   IF (l_accrual_flag = 'Y')
   THEN
      l_accruals_also := true;
   ELSIF (l_accrual_flag = 'N')
   THEN
      l_accruals_also := false;
   END IF;

   IF mod(l_qualification_ind,2) = 1
   THEN
      l_applies_to_entire_brk := false;
      l_applies_to_entire_mod := false;
   ELSIF mod(l_qualification_ind,2) = 0
   THEN
      l_applies_to_entire_brk := true;
      l_applies_to_entire_mod := true;
   END IF;

       --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY After Select Statement' || 'l_error_code = ' || l_error_code);


--  Validating Line Level Limits for Header Level Modifiers

   IF (l_modifier_level_code = 'ORDER')
   THEN
    --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 5' || 'l_error_code = ' || l_error_code);

      IF (l_non_monetary_accrual = true) AND
         (l_application_method = '%')
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','ACCRUAL','USAGE'))
         THEN
            IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','ACCRUAL'))
            THEN
                IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                 AND
                   (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                  ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                   (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
                THEN
                   l_error_code := 0;
                   x_return_status := FND_API.G_RET_STS_SUCCESS;
                 --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 6' || 'l_error_code = ' || l_error_code);
                   return;
                ELSE
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                   OE_MSG_PUB.Add;
                   l_error_code := 1;
                   return;
                END IF;
            END IF;
            IF (p_LIMITS_rec.basis = 'USAGE')
            THEN
                IF (p_LIMITS_rec.limit_level_code = 'ACROSS_TRANSACTION')
                THEN
                    IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                AND
                       (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                       ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                       (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
                    THEN
                        l_error_code := 0;
                        x_return_status := FND_API.G_RET_STS_SUCCESS;
           --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 7' || 'l_error_code = ' || l_errorde);
                        return;
                    ELSE
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                        OE_MSG_PUB.Add;
                        l_error_code := 1;
                        return;
                    END IF;
                ELSE
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_LEVEL');
                    OE_MSG_PUB.Add;
                    l_error_code := 1;
                    return;
                END IF;
            END IF;
         ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
             OE_MSG_PUB.Add;
             l_error_code := 1;
             return;
         END IF;
      END IF;

      IF ((l_list_line_type_code IN ('DIS','SUR')) OR (l_monetary_accrual = true)) AND
         (l_application_method = '%')
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE'))
         THEN
            --DBMS_OUTPUT.PUT_LINE('VALIDATE ENTITY GR/COS/USA');
            IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST'))
            THEN
            --DBMS_OUTPUT.PUT_LINE('VALIDATE ENTITY GR/COS');
                IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                 AND
                   (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                  ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                   (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
                THEN
                   l_error_code := 0;
                   x_return_status := FND_API.G_RET_STS_SUCCESS;
                 --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 3' || 'l_error_code = ' || l_error_code);
                   return;
                ELSE
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                   OE_MSG_PUB.Add;
                   l_error_code := 1;
                   return;
                END IF;
            ELSIF (p_LIMITS_rec.basis = 'USAGE')
            THEN
                --DBMS_OUTPUT.PUT_LINE('VALIDATE ENTITY USA');
                IF (p_LIMITS_rec.limit_level_code = 'ACROSS_TRANSACTION')
                THEN
                    IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                AND
                       (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                       ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                       (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
                    THEN
                        l_error_code := 0;
                        x_return_status := FND_API.G_RET_STS_SUCCESS;
                        --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 4' || 'l_error_code = ' || l_error_code);
                        return;
                    ELSE
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                        OE_MSG_PUB.Add;
                        l_error_code := 1;
                        return;
                    END IF;
                ELSE
                    x_return_status := FND_API.G_RET_STS_ERROR;
                    FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_LEVEL');
                    OE_MSG_PUB.Add;
                    l_error_code := 1;
                    return;
                END IF;
            END IF;
         ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
             FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
             OE_MSG_PUB.Add;
             l_error_code := 1;
             return;
         END IF;
      END IF;

    --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 8' || 'l_error_code = ' || l_error_code);
      IF (l_list_line_type_code = 'FREIGHT_CHARGE') AND
         (l_application_method = 'LUMPSUM')
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','CHARGE','USAGE'))
         THEN
            IF (p_LIMITS_rec.limit_level_code = 'ACROSS_TRANSACTION')
            THEN
               IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                 ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
               THEN
                  l_error_code := 0;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
                  --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 9' || 'l_error_code = ' || l_error_code);
                  return;
               ELSE
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                  OE_MSG_PUB.Add;
                  l_error_code := 1;
                  return;
               END IF;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_LEVEL');
               OE_MSG_PUB.Add;
               l_error_code := 1;
               return;
            END IF;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

      IF (l_list_line_type_code = 'PRG')
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE'))
         THEN
            IF (p_LIMITS_rec.limit_level_code = 'ACROSS_TRANSACTION')
            THEN
               IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                 ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
               THEN
                  l_error_code := 0;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
        --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 10' || 'l_error_code = ' || l_error_code);
                  return;
               ELSE
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                  OE_MSG_PUB.Add;
                  l_error_code := 1;
                  return;
               END IF;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_LEVEL');
               OE_MSG_PUB.Add;
               l_error_code := 1;
               return;
            END IF;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

      IF (l_list_line_type_code = 'CIE')
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','USAGE'))
         THEN
            IF (p_LIMITS_rec.limit_level_code = 'ACROSS_TRANSACTION')
            THEN
               IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                 ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
               THEN
                  l_error_code := 0;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
           --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 11' || 'l_error_code = ' || l_error_code);
                  return;
               ELSE
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                  OE_MSG_PUB.Add;
                  l_error_code := 1;
                  return;
               END IF;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_LEVEL');
               OE_MSG_PUB.Add;
               l_error_code := 1;
               return;
            END IF;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

      IF (l_list_line_type_code = 'TSN')
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE'))
         THEN
            IF (p_LIMITS_rec.limit_level_code = 'ACROSS_TRANSACTION')
            THEN
               IF ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'CUSTOMER')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'CUSTOMER')) AND
                 ((nvl(p_LIMITS_rec.multival_attr1_context,'NA') <> 'ITEM')
                                 AND
                  (nvl(p_LIMITS_rec.multival_attr2_context,'NA') <> 'ITEM'))
               THEN
                  l_error_code := 0;
                  x_return_status := FND_API.G_RET_STS_SUCCESS;
       --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 12' || 'l_error_code = ' || l_error_code);
                  return;
               ELSE
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  FND_MESSAGE.SET_NAME('QP','QP_CONT_CUST_PROD_NOT_ALLOWED');
                  OE_MSG_PUB.Add;
                  l_error_code := 1;
                  return;
               END IF;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_LEVEL');
               OE_MSG_PUB.Add;
               l_error_code := 1;
               return;
            END IF;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;
   END IF;

--  Validating Line Level Limits for Line Level Modifiers

-- Non-Monetary Accruals

      IF (l_non_monetary_accrual = true) THEN
        IF (l_application_method IN ('AMT','LUMPSUM')) THEN
            IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','ACCRUAL','USAGE','QUANTITY')) THEN
               l_error_code := 0;
               x_return_status := FND_API.G_RET_STS_SUCCESS;
               --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 17' || 'l_error_code = ' || l_error_code);
               return;
            ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
               OE_MSG_PUB.Add;
               l_error_code := 1;
               return;
            END IF;
        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
        END IF;
      END IF;

-- Discount/Surcharge

   IF (l_modifier_level_code = 'LINE') OR (l_modifier_level_code = 'LINEGROUP')
   THEN
      IF (l_list_line_type_code IN ('DIS','SUR')) AND
         (l_application_method IN ('%','AMT','LUMPSUM')) AND
         (l_accruals_also = true)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE','QUANTITY'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 13' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

      IF (l_list_line_type_code IN ('DIS','SUR')) AND
         (l_application_method = 'NEWPRICE') AND
         (l_accruals_also = false)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE','QUANTITY'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
           --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 14' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;


-- Monetary Accruals

      IF (l_monetary_accrual = true) AND
         (l_application_method IN ('%','AMT','LUMPSUM')) AND
         (l_accruals_also = true)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE','QUANTITY'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 15' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

      IF (l_monetary_accrual = true) AND
         (l_application_method = 'NEWPRICE') AND
         (l_accruals_also = false)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE','QUANTITY'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 16' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;


-- Freight and Special Charges

      IF (l_list_line_type_code = 'FREIGHT_CHARGE') AND
         (l_application_method IN ('%','AMT','LUMPSUM'))
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','CHARGE','USAGE','QUANTITY'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 18' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

-- Other Item Discounts

      IF (l_list_line_type_code = 'OID') and (l_applies_to_entire_mod = true)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 19' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

-- Discount Breaks

      IF (l_list_line_type_code = 'PBH') and (l_applies_to_entire_brk = true)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE','ACCRUAL','QUANTITY'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 20' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

-- Promotional Goods

      IF (l_list_line_type_code = 'PRG') and (l_applies_to_entire_mod = true)
      THEN
         IF (p_LIMITS_rec.basis IN ('GROSS_REVENUE','COST','USAGE'))
         THEN
            l_error_code := 0;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY 21' || 'l_error_code = ' || l_error_code);
            return;
         ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIMIT_BASIS');
            OE_MSG_PUB.Add;
            l_error_code := 1;
            return;
         END IF;
      END IF;

   END IF;

   --DBMS_OUTPUT.PUT_LINE('INSIDE VALIDATE ENTITY ' || 'l_error_code = ' || l_error_code);

   IF (l_error_code = 0)  --  Validation Passed
   THEN
      l_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;

 --Done validating List Line Limits

   x_return_status := l_return_status;

EXCEPTION

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Validate_List_Line_Limits'
            );
        END IF;


END Validate_List_Line_Limits;


PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_LIMITS_rec                  QP_Limits_PUB.Limits_Rec_Type;
BEGIN
l_LIMITS_rec := p_LIMITS_rec;
    --  Check required attributes.

    IF  p_LIMITS_rec.limit_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','amount');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --


    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --
       --DBMS_OUTPUT.PUT_LINE('Here ');
    IF (l_LIMITS_rec.list_line_id = -1) or (l_LIMITS_rec.list_line_id is null)  THEN
       Validate_List_Header_Limits(x_return_status               => l_return_status
                                   ,p_LIMITS_rec                  => l_LIMITS_rec
                                   );
       --DBMS_OUTPUT.PUT_LINE('Here1 ');
    ELSE
       Validate_List_Line_Limits(x_return_status               => l_return_status
                                 ,p_LIMITS_rec                  => l_LIMITS_rec
                                );
       --DBMS_OUTPUT.PUT_LINE('Here2 ' || ' Return Status ' || l_return_status);
    END IF;

    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
,   p_old_LIMITS_rec                IN  QP_Limits_PUB.Limits_Rec_Type :=
                                        QP_Limits_PUB.G_MISS_LIMITS_REC
)
IS
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

            --dbms_output.put_line('Inside QP_Validate_Limits.Attributes ' || x_return_status);
    --  Validate LIMITS attributes
    IF  p_LIMITS_rec.amount IS NOT NULL AND
        (   p_LIMITS_rec.amount <>
            p_old_LIMITS_rec.amount OR
            p_old_LIMITS_rec.amount IS NULL )
    THEN
        IF NOT QP_Validate.Amount(p_LIMITS_rec.amount) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Amount ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.basis IS NOT NULL AND
        (   p_LIMITS_rec.basis <>
            p_old_LIMITS_rec.basis OR
            p_old_LIMITS_rec.basis IS NULL )
    THEN
        IF NOT QP_Validate.Basis(p_LIMITS_rec.basis) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Basis ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.created_by IS NOT NULL AND
        (   p_LIMITS_rec.created_by <>
            p_old_LIMITS_rec.created_by OR
            p_old_LIMITS_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_LIMITS_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.created_by ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.creation_date IS NOT NULL AND
        (   p_LIMITS_rec.creation_date <>
            p_old_LIMITS_rec.creation_date OR
            p_old_LIMITS_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_LIMITS_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Creation_Date ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.last_updated_by IS NOT NULL AND
        (   p_LIMITS_rec.last_updated_by <>
            p_old_LIMITS_rec.last_updated_by OR
            p_old_LIMITS_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_LIMITS_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Last_Updated_By ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.last_update_date IS NOT NULL AND
        (   p_LIMITS_rec.last_update_date <>
            p_old_LIMITS_rec.last_update_date OR
            p_old_LIMITS_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_LIMITS_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Last_Update_Date ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.last_update_login IS NOT NULL AND
        (   p_LIMITS_rec.last_update_login <>
            p_old_LIMITS_rec.last_update_login OR
            p_old_LIMITS_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_LIMITS_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.last_update_login ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.limit_exceed_action_code IS NOT NULL AND
        (   p_LIMITS_rec.limit_exceed_action_code <>
            p_old_LIMITS_rec.limit_exceed_action_code OR
            p_old_LIMITS_rec.limit_exceed_action_code IS NULL )
    THEN
        IF NOT QP_Validate.Limit_Exceed_Action(p_LIMITS_rec.limit_exceed_action_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Limit_Exceed_Action ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.limit_hold_flag IS NOT NULL AND
        (   p_LIMITS_rec.limit_hold_flag <>
            p_old_LIMITS_rec.limit_hold_flag OR
            p_old_LIMITS_rec.limit_hold_flag IS NULL )
    THEN
        IF NOT QP_Validate.LIMIT_HOLD(p_LIMITS_rec.limit_hold_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.LIMIT_HOLD ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.limit_id IS NOT NULL AND
        (   p_LIMITS_rec.limit_id <>
            p_old_LIMITS_rec.limit_id OR
            p_old_LIMITS_rec.limit_id IS NULL )
    THEN
        IF NOT QP_Validate.Limit(p_LIMITS_rec.limit_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.limit_id ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.limit_level_code IS NOT NULL AND
        (   p_LIMITS_rec.limit_level_code <>
            p_old_LIMITS_rec.limit_level_code OR
            p_old_LIMITS_rec.limit_level_code IS NULL )
    THEN
        IF NOT QP_Validate.Limit_Level(p_LIMITS_rec.limit_level_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Limit_Level ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.limit_number IS NOT NULL AND
        (   p_LIMITS_rec.limit_number <>
            p_old_LIMITS_rec.limit_number OR
            p_old_LIMITS_rec.limit_number IS NULL )
    THEN
        IF NOT QP_Validate.Limit_Number(p_LIMITS_rec.limit_number) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Limit_Number ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.list_header_id IS NOT NULL AND
        (   p_LIMITS_rec.list_header_id <>
            p_old_LIMITS_rec.list_header_id OR
            p_old_LIMITS_rec.list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Header(p_LIMITS_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.List_Header ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.list_line_id IS NOT NULL AND
        (   p_LIMITS_rec.list_line_id <>
            p_old_LIMITS_rec.list_line_id OR
            p_old_LIMITS_rec.list_line_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Line(p_LIMITS_rec.list_line_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.List_Line ' || x_return_status);
    END IF;

    IF  p_LIMITS_rec.multival_attr1_type IS NOT NULL AND
        (   p_LIMITS_rec.multival_attr1_type <>
            p_old_LIMITS_rec.multival_attr1_type OR
            p_old_LIMITS_rec.multival_attr1_type IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Type(p_LIMITS_rec.multival_attr1_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attr1_context IS NOT NULL AND
        (   p_LIMITS_rec.multival_attr1_context <>
            p_old_LIMITS_rec.multival_attr1_context OR
            p_old_LIMITS_rec.multival_attr1_context IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Context(p_LIMITS_rec.multival_attr1_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attribute2 IS NOT NULL AND
        (   p_LIMITS_rec.multival_attribute2 <>
            p_old_LIMITS_rec.multival_attribute2 OR
            p_old_LIMITS_rec.multival_attribute2 IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attribute2(p_LIMITS_rec.multival_attribute2) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attr1_datatype IS NOT NULL AND
        (   p_LIMITS_rec.multival_attr1_datatype <>
            p_old_LIMITS_rec.multival_attr1_datatype OR
            p_old_LIMITS_rec.multival_attr1_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr1_Datatype(p_LIMITS_rec.multival_attr1_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attr2_type IS NOT NULL AND
        (   p_LIMITS_rec.multival_attr2_type <>
            p_old_LIMITS_rec.multival_attr2_type OR
            p_old_LIMITS_rec.multival_attr2_type IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Type(p_LIMITS_rec.multival_attr2_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attr2_context IS NOT NULL AND
        (   p_LIMITS_rec.multival_attr2_context <>
            p_old_LIMITS_rec.multival_attr2_context OR
            p_old_LIMITS_rec.multival_attr2_context IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Context(p_LIMITS_rec.multival_attr2_context) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attribute2 IS NOT NULL AND
        (   p_LIMITS_rec.multival_attribute2 <>
            p_old_LIMITS_rec.multival_attribute2 OR
            p_old_LIMITS_rec.multival_attribute2 IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attribute2(p_LIMITS_rec.multival_attribute2) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.multival_attr2_datatype IS NOT NULL AND
        (   p_LIMITS_rec.multival_attr2_datatype <>
            p_old_LIMITS_rec.multival_attr2_datatype OR
            p_old_LIMITS_rec.multival_attr2_datatype IS NULL )
    THEN
        IF NOT QP_Validate.Multival_Attr2_Datatype(p_LIMITS_rec.multival_attr2_datatype) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.organization_flag IS NOT NULL AND
        (   p_LIMITS_rec.organization_flag <>
            p_old_LIMITS_rec.organization_flag OR
            p_old_LIMITS_rec.organization_flag IS NULL )
    THEN
        IF NOT QP_Validate.Organization(p_LIMITS_rec.organization_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
            --dbms_output.put_line('Inside QP_Validate.Organization ' || x_return_status);
    END IF;


    IF  p_LIMITS_rec.program_application_id IS NOT NULL AND
        (   p_LIMITS_rec.program_application_id <>
            p_old_LIMITS_rec.program_application_id OR
            p_old_LIMITS_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_LIMITS_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.program_id IS NOT NULL AND
        (   p_LIMITS_rec.program_id <>
            p_old_LIMITS_rec.program_id OR
            p_old_LIMITS_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_LIMITS_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.program_update_date IS NOT NULL AND
        (   p_LIMITS_rec.program_update_date <>
            p_old_LIMITS_rec.program_update_date OR
            p_old_LIMITS_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_LIMITS_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_LIMITS_rec.request_id IS NOT NULL AND
        (   p_LIMITS_rec.request_id <>
            p_old_LIMITS_rec.request_id OR
            p_old_LIMITS_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_LIMITS_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            --dbms_output.put_line('Inside QP_Validate.request_id ' || x_return_status);
        END IF;
    END IF;

    IF  (p_LIMITS_rec.attribute1 IS NOT NULL AND
        (   p_LIMITS_rec.attribute1 <>
            p_old_LIMITS_rec.attribute1 OR
            p_old_LIMITS_rec.attribute1 IS NULL ))
    OR  (p_LIMITS_rec.attribute10 IS NOT NULL AND
        (   p_LIMITS_rec.attribute10 <>
            p_old_LIMITS_rec.attribute10 OR
            p_old_LIMITS_rec.attribute10 IS NULL ))
    OR  (p_LIMITS_rec.attribute11 IS NOT NULL AND
        (   p_LIMITS_rec.attribute11 <>
            p_old_LIMITS_rec.attribute11 OR
            p_old_LIMITS_rec.attribute11 IS NULL ))
    OR  (p_LIMITS_rec.attribute12 IS NOT NULL AND
        (   p_LIMITS_rec.attribute12 <>
            p_old_LIMITS_rec.attribute12 OR
            p_old_LIMITS_rec.attribute12 IS NULL ))
    OR  (p_LIMITS_rec.attribute13 IS NOT NULL AND
        (   p_LIMITS_rec.attribute13 <>
            p_old_LIMITS_rec.attribute13 OR
            p_old_LIMITS_rec.attribute13 IS NULL ))
    OR  (p_LIMITS_rec.attribute14 IS NOT NULL AND
        (   p_LIMITS_rec.attribute14 <>
            p_old_LIMITS_rec.attribute14 OR
            p_old_LIMITS_rec.attribute14 IS NULL ))
    OR  (p_LIMITS_rec.attribute15 IS NOT NULL AND
        (   p_LIMITS_rec.attribute15 <>
            p_old_LIMITS_rec.attribute15 OR
            p_old_LIMITS_rec.attribute15 IS NULL ))
    OR  (p_LIMITS_rec.attribute2 IS NOT NULL AND
        (   p_LIMITS_rec.attribute2 <>
            p_old_LIMITS_rec.attribute2 OR
            p_old_LIMITS_rec.attribute2 IS NULL ))
    OR  (p_LIMITS_rec.attribute3 IS NOT NULL AND
        (   p_LIMITS_rec.attribute3 <>
            p_old_LIMITS_rec.attribute3 OR
            p_old_LIMITS_rec.attribute3 IS NULL ))
    OR  (p_LIMITS_rec.attribute4 IS NOT NULL AND
        (   p_LIMITS_rec.attribute4 <>
            p_old_LIMITS_rec.attribute4 OR
            p_old_LIMITS_rec.attribute4 IS NULL ))
    OR  (p_LIMITS_rec.attribute5 IS NOT NULL AND
        (   p_LIMITS_rec.attribute5 <>
            p_old_LIMITS_rec.attribute5 OR
            p_old_LIMITS_rec.attribute5 IS NULL ))
    OR  (p_LIMITS_rec.attribute6 IS NOT NULL AND
        (   p_LIMITS_rec.attribute6 <>
            p_old_LIMITS_rec.attribute6 OR
            p_old_LIMITS_rec.attribute6 IS NULL ))
    OR  (p_LIMITS_rec.attribute7 IS NOT NULL AND
        (   p_LIMITS_rec.attribute7 <>
            p_old_LIMITS_rec.attribute7 OR
            p_old_LIMITS_rec.attribute7 IS NULL ))
    OR  (p_LIMITS_rec.attribute8 IS NOT NULL AND
        (   p_LIMITS_rec.attribute8 <>
            p_old_LIMITS_rec.attribute8 OR
            p_old_LIMITS_rec.attribute8 IS NULL ))
    OR  (p_LIMITS_rec.attribute9 IS NOT NULL AND
        (   p_LIMITS_rec.attribute9 <>
            p_old_LIMITS_rec.attribute9 OR
            p_old_LIMITS_rec.attribute9 IS NULL ))
    OR  (p_LIMITS_rec.context IS NOT NULL AND
        (   p_LIMITS_rec.context <>
            p_old_LIMITS_rec.context OR
            p_old_LIMITS_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_LIMITS_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_LIMITS_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_LIMITS_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_LIMITS_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_LIMITS_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_LIMITS_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_LIMITS_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_LIMITS_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_LIMITS_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_LIMITS_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_LIMITS_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_LIMITS_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_LIMITS_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_LIMITS_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_LIMITS_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_LIMITS_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'LIMITS' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy                       NUMBER := 0;
BEGIN

    --  Validate entity delete.

    SELECT count(*) into l_dummy from QP_LIMIT_BALANCES
    WHERE limit_id = p_LIMITS_rec.limit_id
    AND nvl(consumed_amount,0) > 0;

    IF l_dummy = 0
    THEN
        l_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF l_dummy > 0
    THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_DEL_LIMIT_BAL_EXISTS');
        FND_MESSAGE.SET_TOKEN('ENTITY1','Limit');
        FND_MESSAGE.SET_TOKEN('ENTITY2','Limit');
        OE_MSG_PUB.Add;
    END IF;
    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;


PROCEDURE Entity_Update
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_LIMITS_rec                    IN  QP_Limits_PUB.Limits_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_limits_rec                  QP_Limits_PUB.Limits_Rec_Type;
l_error_code                  NUMBER := 0;
l_dummy                       NUMBER := 0;
l_consumed_amount             NUMBER := 0;
BEGIN

    --  Validate entity update.

    l_limits_rec :=  QP_Limits_Util.Query_Row(p_LIMITS_rec.limit_id);

    SELECT count(*) into l_dummy from QP_LIMIT_BALANCES
    WHERE limit_id = p_LIMITS_rec.limit_id
    AND nvl(consumed_amount,0) > 0;

    SELECT MAX(consumed_amount) INTO l_consumed_amount FROM QP_LIMIT_BALANCES
    WHERE limit_id = p_LIMITS_rec.limit_id;

    IF l_dummy = 0
    THEN
       l_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSIF l_dummy > 0
    THEN

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_header_id
                              ,l_limits_rec.list_header_id)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.list_line_id
                              ,l_limits_rec.list_line_id)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_number
                              ,l_limits_rec.limit_number)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.basis
                              ,l_limits_rec.basis)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.organization_flag
                              ,l_limits_rec.organization_flag)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_level_code
                              ,l_limits_rec.limit_level_code)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_exceed_action_code
                              ,l_limits_rec.limit_exceed_action_code)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.limit_hold_flag
                              ,l_limits_rec.limit_hold_flag)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_type
                              ,l_limits_rec.multival_attr1_type)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_context
                              ,l_limits_rec.multival_attr1_context)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute1
                              ,l_limits_rec.multival_attribute1)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr1_datatype
                              ,l_limits_rec.multival_attr1_datatype)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_type
                              ,l_limits_rec.multival_attr2_type)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_context
                              ,l_limits_rec.multival_attr2_context)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attribute2
                              ,l_limits_rec.multival_attribute2)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.multival_attr2_datatype
                              ,l_limits_rec.multival_attr2_datatype)
       THEN
          l_error_code := 1;
       END IF;

       IF NOT QP_GLOBALS.Equal(p_LIMITS_rec.amount
                              ,l_limits_rec.amount)
       THEN
          IF p_LIMITS_rec.amount < l_consumed_amount
          THEN
             l_error_code := 1;
          END IF;
       END IF;

       IF l_error_code = 1
       THEN
           l_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPD_LIMIT_BAL_EXISTS');
           FND_MESSAGE.SET_TOKEN('ENTITY1','Limit');
           FND_MESSAGE.SET_TOKEN('ENTITY2','Limit');
           OE_MSG_PUB.Add;
       ELSIF l_error_code = 0
       THEN
           l_return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;

    END IF;
    --  Done.

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Update;

END QP_Validate_Limits;

/
