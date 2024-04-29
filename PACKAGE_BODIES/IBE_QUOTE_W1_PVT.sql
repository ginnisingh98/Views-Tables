--------------------------------------------------------
--  DDL for Package Body IBE_QUOTE_W1_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_QUOTE_W1_PVT" as
/* $Header: IBEVQW1B.pls 120.8.12010000.8 2014/04/28 12:23:01 kdosapat ship $ */
-- Start of Comments
-- Package name     : IBE_Quote_W1_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- END of Comments
ROSETTA_G_MISTAKE_DATE DATE   := TO_DATE('01/01/+4713', 'MM/DD/SYYYY');
ROSETTA_G_MISS_NUM     NUMBER := 0-1962.0724;

G_PKG_NAME CONSTANT VARCHAR2(30)  := 'IBE_Quote_W1_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'IBEVQW1B.PLS';
l_true VARCHAR2(1) := FND_API.G_TRUE;

FUNCTION Construct_Payment_Tbl(
   p_operation_code            IN  jtf_varchar2_table_100  ,
   p_qte_line_index            IN  jtf_number_table  ,
   p_payment_id                IN  jtf_number_table  ,
   p_creation_date             IN  jtf_date_table    ,
   p_created_by                IN  jtf_number_table  ,
   p_last_update_date          IN  jtf_date_table    ,
   p_last_updated_by           IN  jtf_number_table  ,
   p_last_update_login         IN  jtf_number_table  ,
   p_request_id                IN  jtf_number_table  ,
   p_program_application_id    IN  jtf_number_table  ,
   p_program_id                IN  jtf_number_table  ,
   p_program_update_date       IN  jtf_date_table    ,
   p_quote_header_id           IN  jtf_number_table  ,
   p_quote_line_id             IN  jtf_number_table  ,
   p_payment_type_code         IN  jtf_varchar2_table_100  ,
   p_payment_ref_number        IN  jtf_varchar2_table_300  ,
   p_payment_option            IN  jtf_varchar2_table_300  ,
   p_payment_term_id           IN  jtf_number_table  ,
   p_credit_card_code          IN  jtf_varchar2_table_100  ,
   p_credit_card_holder_name   IN  jtf_varchar2_table_100  ,
   p_credit_card_exp_date      IN  jtf_date_table    ,
   p_credit_card_approval_code IN  jtf_varchar2_table_100  ,
   p_credit_card_approval_date IN  jtf_date_table    ,
   p_payment_amount            IN  jtf_number_table  ,
   p_cust_po_number            IN  jtf_varchar2_table_100  ,
   p_attribute_category        IN  jtf_varchar2_table_100  ,
   p_attribute1                IN  jtf_varchar2_table_200  ,
   p_attribute2                IN  jtf_varchar2_table_200  ,
   p_attribute3                IN  jtf_varchar2_table_200  ,
   p_attribute4                IN  jtf_varchar2_table_200  ,
   p_attribute5                IN  jtf_varchar2_table_200  ,
   p_attribute6                IN  jtf_varchar2_table_200  ,
   p_attribute7                IN  jtf_varchar2_table_200  ,
   p_attribute8                IN  jtf_varchar2_table_200  ,
   p_attribute9                IN  jtf_varchar2_table_200  ,
   p_attribute10               IN  jtf_varchar2_table_200  ,
   p_attribute11               IN  jtf_varchar2_table_200  ,
   p_attribute12               IN  jtf_varchar2_table_200  ,
   p_attribute13               IN  jtf_varchar2_table_200  ,
   p_attribute14               IN  jtf_varchar2_table_200  ,
   p_attribute15               IN  jtf_varchar2_table_200  ,
   p_assignment_id             IN  jtf_number_table  ,
   p_cvv2                      IN  jtf_varchar2_table_200
)
RETURN ASO_Quote_Pub.Payment_Tbl_Type
IS
   l_payment_tbl ASO_Quote_Pub.Payment_Tbl_Type;
   l_table_size  PLS_INTEGER := 0;
   i             PLS_INTEGER;
BEGIN
   --To determine the table size
   --quote_header_id array is choosen because it will definitely be passed by the mid tier
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Ready to call CONSTRUCT_PAYMENT_TBL in IBE_Quote_W1_PVT');
   END IF;
   IF p_quote_header_id IS NOT NULL THEN
      l_table_size := p_quote_header_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
                  IF (p_operation_code is not null) THEN
            l_payment_tbl(i).operation_code := p_operation_code(i);
         END IF;
         IF ((p_qte_line_index is not null ) and ((p_qte_line_index(i) is null) or (p_qte_line_index(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;

         IF ((p_payment_id is not null ) and ((p_payment_id(i) is null) or (p_payment_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).payment_id := p_payment_id(i);
         END IF;

         IF ((p_creation_date is not null ) and ((p_creation_date(i) is null) or (p_creation_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_payment_tbl(i).creation_date := p_creation_date(i);
         END IF;

         IF ((p_created_by is not null ) and ((p_created_by(i) is null) or (p_created_by(i) <> FND_API.G_MISS_NUM))) THEN
            l_payment_tbl(i).created_by := p_created_by(i);
         END IF;

         IF ((p_last_update_date is not null ) and ((p_last_update_date(i) is null) or (p_last_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_payment_tbl(i).last_update_date := p_last_update_date(i);
         END IF;

         IF ((p_last_updated_by is not null ) and ((p_last_updated_by(i) is null) or (p_last_updated_by(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;

         IF ((p_last_update_login is not null ) and ((p_last_update_login(i) is null) or (p_last_update_login(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).last_update_login := p_last_update_login(i);
         END IF;

         IF ((p_request_id is not null ) and ((p_request_id(i) is null) or (p_request_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).request_id := p_request_id(i);
         END IF;

         IF ((p_program_application_id is not null ) and ((p_program_application_id(i) is null) or (p_program_application_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).program_application_id := p_program_application_id(i);
         END IF;

         IF ((p_program_id is not null ) and ((p_program_id(i) is null) or (p_program_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).program_id := p_program_id(i);
         END IF;

         IF ((p_program_update_date is not null ) and ((p_program_update_date(i) is null) or (p_program_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_payment_tbl(i).program_update_date := p_program_update_date(i);
         END IF;

         IF ((p_quote_header_id is not null ) and ((p_quote_header_id(i) is null) or (p_quote_header_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;

         IF ((p_quote_line_id is not null ) and ((p_quote_line_id(i) is null) or (p_quote_line_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;

         IF (p_payment_type_code is not null) THEN
            l_payment_tbl(i).payment_type_code := p_payment_type_code(i);
         END IF;

         IF (p_payment_ref_number is not null) THEN
            l_payment_tbl(i).payment_ref_number := p_payment_ref_number(i);
         END IF;

         IF (p_payment_option is not null) THEN
            l_payment_tbl(i).payment_option := p_payment_option(i);
         END IF;

         IF ((p_payment_term_id is not null ) and ((p_payment_term_id(i) is null) or (p_payment_term_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).payment_term_id := p_payment_term_id(i);
         END IF;

         IF (p_credit_card_code is not null) THEN
            l_payment_tbl(i).credit_card_code := p_credit_card_code(i);
         END IF;

         IF (p_credit_card_holder_name is not null) THEN
            l_payment_tbl(i).credit_card_holder_name := p_credit_card_holder_name(i);
         END IF;

         IF ((p_credit_card_exp_date is not null ) and ((p_credit_card_exp_date(i) is null) or (p_credit_card_exp_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_payment_tbl(i).credit_card_expiration_date := p_credit_card_exp_date(i);
         END IF;

         IF (p_credit_card_approval_code is not null) THEN
            l_payment_tbl(i).credit_card_approval_code := p_credit_card_approval_code(i);
         END IF;

         IF ((p_credit_card_approval_date is not null ) and ((p_credit_card_approval_date(i) is null) or (p_credit_card_approval_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_payment_tbl(i).credit_card_approval_date := p_credit_card_approval_date(i);
         END IF;

         IF ((p_payment_amount is not null ) and ((p_payment_amount(i) is null) or (p_payment_amount(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_payment_tbl(i).payment_amount := p_payment_amount(i);
         END IF;

         IF (p_cust_po_number is not null ) THEN
            l_payment_tbl(i).cust_po_number := p_cust_po_number(i);
         END IF;

         IF (p_attribute_category is not null) THEN
            l_payment_tbl(i).attribute_category := p_attribute_category(i);
         END IF;

         IF (p_attribute1 is not null) THEN
            l_payment_tbl(i).attribute1 := p_attribute1(i);
         END IF;


         IF (p_attribute2 is not null) THEN
            l_payment_tbl(i).attribute2 := p_attribute2(i);
         END IF;

         IF (p_attribute3 is not null) THEN
            l_payment_tbl(i).attribute3 := p_attribute3(i);
         END IF;

         IF (p_attribute4 is not null) THEN
            l_payment_tbl(i).attribute4 := p_attribute4(i);
         END IF;

         IF (p_attribute5 is not null) THEN
            l_payment_tbl(i).attribute5 := p_attribute5(i);
         END IF;

         IF (p_attribute6 is not null) THEN
            l_payment_tbl(i).attribute6 := p_attribute6(i);
         END IF;

         IF (p_attribute7 is not null) THEN
            l_payment_tbl(i).attribute7 := p_attribute7(i);
         END IF;

         IF (p_attribute8 is not null) THEN
            l_payment_tbl(i).attribute8 := p_attribute8(i);
         END IF;

         IF (p_attribute9 is not null) THEN
            l_payment_tbl(i).attribute9 := p_attribute9(i);
         END IF;

         IF (p_attribute10 is not null) THEN
            l_payment_tbl(i).attribute10 := p_attribute10(i);
         END IF;

         IF (p_attribute11 is not null) THEN
            l_payment_tbl(i).attribute11 := p_attribute11(i);
         END IF;

         IF (p_attribute12 is not null) THEN
            l_payment_tbl(i).attribute12 := p_attribute12(i);
         END IF;

         IF (p_attribute13 is not null) THEN
            l_payment_tbl(i).attribute13 := p_attribute13(i);
         END IF;

         IF (p_attribute14 is not null) THEN
            l_payment_tbl(i).attribute14 := p_attribute14(i);
         END IF;

         IF (p_attribute15 is not null) THEN
            l_payment_tbl(i).attribute15 := p_attribute15(i);
         END IF;

         IF (p_assignment_id is not null) THEN
            l_payment_tbl(i).INSTR_ASSIGNMENT_ID := p_assignment_id(i);
         END IF;

         IF (p_cvv2 is not null) THEN
            l_payment_tbl(i).cvv2 := p_cvv2(i);
         END IF;

       END LOOP;


      RETURN l_payment_tbl;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('returning payment table from CONSTRUCT_PAYMENT_TBL');
     END IF;
   END IF;
END Construct_Payment_Tbl;

PROCEDURE Set_Order_Header_Out_W(
   p_order_header_rec IN  ASO_Quote_Pub.Order_Header_Rec_Type,
   x_order_number     OUT NOCOPY NUMBER                             ,
   x_order_header_id  OUT NOCOPY NUMBER                             ,
   x_order_request_id OUT NOCOPY NUMBER                             ,
   x_contract_id      OUT NOCOPY NUMBER                             ,
   x_status           OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_order_number     := p_order_header_rec.order_number;
   x_order_header_id  := p_order_header_rec.order_header_id;
   x_order_request_id := p_order_header_rec.order_request_id;
   x_contract_id      := p_order_header_rec.contract_id;
   x_status           := p_order_header_rec.status;
END Set_Order_Header_Out_W;


PROCEDURE Set_CC_Trxn_Out_W(
   p_cc_Trxn_Out_Rec    IN  ASO_PAYMENT_INT.CC_Trxn_Out_Rec_Type,
   x_au_status          OUT NOCOPY NUMBER                              ,
   x_au_err_code        OUT NOCOPY VARCHAR2                            ,
   x_au_err_message     OUT NOCOPY VARCHAR2                            ,
   x_au_nls_lang        OUT NOCOPY VARCHAR2                            ,
   x_au_trxn_id         OUT NOCOPY NUMBER                              ,
   x_au_trxn_date       OUT NOCOPY DATE                                ,
   x_au_auth_code       OUT NOCOPY VARCHAR2                            ,
   x_au_err_location    OUT NOCOPY NUMBER                              ,
   x_au_bep_err_code    OUT NOCOPY VARCHAR2                            ,
   x_au_bep_err_message OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_au_status          := p_cc_trxn_out_rec.status;
   x_au_err_code        := p_cc_trxn_out_rec.err_code;
   x_au_err_message     := p_cc_trxn_out_rec.err_message;
   x_au_nls_lang        := p_cc_trxn_out_rec.NLS_LANG;
   x_au_trxn_id         := p_cc_trxn_out_rec.trxn_id;
   x_au_trxn_date       := p_cc_trxn_out_rec.trxn_date;
   x_au_auth_code       := p_cc_trxn_out_rec.auth_code ;
   x_au_err_location    := p_cc_trxn_out_rec.err_location;
   x_au_bep_err_code    := p_cc_trxn_out_rec.bep_err_code;
   x_au_bep_err_message := p_cc_trxn_out_rec.bep_err_message;
END Set_CC_Trxn_Out_W;


PROCEDURE Set_Submit_Control_Rec_W(
   p_sc_book_flag       IN  VARCHAR2 := FND_API.G_FALSE,
   p_sc_reserve_flag    IN  VARCHAR2 := FND_API.G_FALSE,
   p_sc_calculate_price IN  VARCHAR2 := FND_API.G_FALSE,
   p_sc_server_id       IN  NUMBER   := -1             ,
   p_sc_cc_by_fax       IN  VARCHAR2 := FND_API.G_FALSE,
   x_Submit_control_rec OUT NOCOPY ASO_Quote_Pub.Submit_Control_Rec_Type
)
IS
BEGIN
   x_submit_control_rec.book_flag := p_sc_book_flag;
   x_submit_control_rec.reserve_flag := p_sc_reserve_flag;
   x_submit_control_rec.calculate_price := p_sc_calculate_price;
   IF p_sc_server_id = ROSETTA_G_MISS_NUM THEN
      x_submit_control_rec.server_id := -1;
   ELSE
      x_submit_control_rec.server_id := p_sc_server_id;
   END IF;
   x_submit_control_rec.cc_by_fax := p_sc_cc_by_fax;

END Set_Submit_Control_Rec_W;


PROCEDURE Set_Control_Rec_W(
   p_c_last_update_date        DATE ,
   p_c_auto_version_flag       VARCHAR2,
   p_c_pricing_request_type    VARCHAR2,
   p_c_header_pricing_event    VARCHAR2,
   p_c_line_pricing_event      VARCHAR2,
   p_c_cal_tax_flag            VARCHAR2,
   p_c_cal_freight_charge_flag VARCHAR2,
   p_c_price_mode  	       VARCHAR2 := 'ENTIRE_QUOTE',	-- change line logic pricing
   x_control_rec               OUT NOCOPY ASO_Quote_Pub.Control_Rec_Type
)
IS
BEGIN
   IF p_c_last_update_date = ROSETTA_G_MISTAKE_DATE THEN
      x_control_rec.last_update_date := FND_API.G_MISS_DATE;
   ELSE
      x_control_rec.last_update_date := p_c_last_update_date;
   END IF;
   x_control_rec.auto_version_flag := p_c_auto_version_flag;
   x_control_rec.pricing_request_type := p_c_pricing_request_type;
   x_control_rec.header_pricing_event := p_c_header_pricing_event;
   x_control_rec.line_pricing_event := p_c_line_pricing_event;
   x_control_rec.calculate_tax_flag := p_c_cal_tax_flag;
   x_control_rec.calculate_freight_charge_flag := p_c_cal_freight_charge_flag;
   x_control_rec.price_mode	    := p_c_price_mode;		-- change line logic pricing
END Set_Control_Rec_W;


FUNCTION Construct_Price_Adj_Rel_Tbl(
   p_operation_code         IN jtf_varchar2_table_100  ,
   p_adj_relationship_id    IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_updated_by        IN jtf_number_table        ,
   p_last_update_login      IN jtf_number_table        ,
   p_request_id             IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_quote_line_id          IN jtf_number_table        ,
   p_qte_line_index         IN jtf_number_table        ,
   p_price_adjustment_id    IN jtf_number_table        ,
   p_price_adj_index        IN jtf_number_table        ,
   p_rltd_price_adj_id      IN jtf_number_table        ,
   p_rltd_price_adj_index   IN jtf_number_table
)
RETURN ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type
IS
   l_price_adj_rltship_tbl ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;
   l_table_size            PLS_INTEGER := 0;
   i                       PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         l_price_adj_rltship_tbl(i).operation_code := p_operation_code(i);
         IF p_adj_relationship_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).adj_relationship_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).adj_relationship_id := p_adj_relationship_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_rltship_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_rltship_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_rltship_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_rltship_tbl(i).last_update_date := p_last_update_date(i);
         END IF;

         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_rltship_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_rltship_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_price_adjustment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).price_adjustment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).price_adjustment_id := p_price_adjustment_id(i);
         END IF;
         IF p_price_adj_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).price_adj_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).price_adj_index := p_price_adj_index(i);
         END IF;
         IF p_rltd_price_adj_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).rltd_price_adj_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).rltd_price_adj_id := p_rltd_price_adj_id(i);
         END IF;
         IF p_rltd_price_adj_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_rltship_tbl(i).rltd_price_adj_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_rltship_tbl(i).rltd_price_adj_index := p_rltd_price_adj_index(i);
         END IF;
      END LOOP;

      RETURN l_price_adj_rltship_tbl;
   END IF;
END Construct_Price_Adj_Rel_Tbl;


FUNCTION Construct_Price_Adj_Tbl(
   p_operation_code         IN jtf_varchar2_table_100  ,
   p_qte_line_index         IN jtf_number_table        ,
   p_price_adjustment_id    IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_updated_by        IN jtf_number_table        ,
   p_last_update_login      IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_request_id             IN jtf_number_table        ,
   p_quote_header_id        IN jtf_number_table        ,
   p_quote_line_id          IN jtf_number_table        ,
   p_modifier_header_id     IN jtf_number_table        ,
   p_modifier_line_id       IN jtf_number_table        ,
   p_mod_line_type_code     IN jtf_varchar2_table_100  ,
   p_mod_mech_type_code     IN jtf_varchar2_table_100  ,
   p_modified_from          IN jtf_number_table        ,
   p_modified_to            IN jtf_number_table        ,
   p_operand                IN jtf_number_table        ,
   p_arithmetic_operator    IN jtf_varchar2_table_100  ,
   p_automatic_flag         IN jtf_varchar2_table_100  ,
   p_update_allowable_flag  IN jtf_varchar2_table_100  ,
   p_updated_flag           IN jtf_varchar2_table_100  ,
   p_applied_flag           IN jtf_varchar2_table_100  ,
   p_on_invoice_flag        IN jtf_varchar2_table_100  ,
   p_pricing_phase_id       IN jtf_number_table        ,
   p_attribute_category     IN jtf_varchar2_table_100  ,
   p_attribute1             IN jtf_varchar2_table_200  ,
   p_attribute2             IN jtf_varchar2_table_200  ,
   p_attribute3             IN jtf_varchar2_table_200  ,
   p_attribute4             IN jtf_varchar2_table_200  ,
   p_attribute5             IN jtf_varchar2_table_200  ,
   p_attribute6             IN jtf_varchar2_table_200  ,
   p_attribute7             IN jtf_varchar2_table_200  ,
   p_attribute8             IN jtf_varchar2_table_200  ,
   p_attribute9             IN jtf_varchar2_table_200  ,
   p_attribute10            IN jtf_varchar2_table_200  ,
   p_attribute11            IN jtf_varchar2_table_200  ,
   p_attribute12            IN jtf_varchar2_table_200  ,
   p_attribute13            IN jtf_varchar2_table_200  ,
   p_attribute14            IN jtf_varchar2_table_200  ,
   p_attribute15            IN jtf_varchar2_table_200  ,
   p_orig_sys_discount_ref  IN jtf_varchar2_table_100  ,
   p_change_sequence        IN jtf_varchar2_table_100  ,
   p_update_allowed         IN jtf_varchar2_table_100  ,
   p_change_reason_code     IN jtf_varchar2_table_100  ,
   p_change_reason_text     IN jtf_varchar2_table_2000  ,
   p_cost_id                IN jtf_number_table        ,
   p_tax_code               IN jtf_varchar2_table_100  ,
   p_tax_exempt_flag        IN jtf_varchar2_table_100  ,
   p_tax_exempt_number      IN jtf_varchar2_table_100  ,
   p_tax_exempt_reason_code IN jtf_varchar2_table_100  ,
   p_parent_adjustment_id   IN jtf_number_table        ,
   p_invoiced_flag          IN jtf_varchar2_table_100  ,
   p_estimated_flag         IN jtf_varchar2_table_100  ,
   p_inc_in_sales_perfce    IN jtf_varchar2_table_100  ,
   p_split_action_code      IN jtf_varchar2_table_100  ,
   p_adjusted_amount        IN jtf_number_table        ,
   p_charge_type_code       IN jtf_varchar2_table_100  ,
   p_charge_subtype_code    IN jtf_varchar2_table_100  ,
   p_range_break_quantity   IN jtf_number_table        ,
   p_accrual_conv_rate      IN jtf_number_table        ,
   p_pricing_group_sequence IN jtf_number_table        ,
   p_accrual_flag           IN jtf_varchar2_table_100  ,
   p_list_line_no           IN jtf_varchar2_table_300  ,
   p_source_system_code     IN jtf_varchar2_table_100  ,
   p_benefit_qty            IN jtf_number_table        ,
   p_benefit_uom_code       IN jtf_varchar2_table_100  ,
   p_print_on_invoice_flag  IN jtf_varchar2_table_100  ,
   p_expiration_date        IN jtf_date_table          ,
   p_rebate_trans_type_code IN jtf_varchar2_table_100  ,
   p_rebate_trans_reference IN jtf_varchar2_table_100  ,
   p_rebate_pay_system_code IN jtf_varchar2_table_100  ,
   p_redeemed_date          IN jtf_date_table          ,
   p_redeemed_flag          IN jtf_varchar2_table_100  ,
   p_modifier_level_code    IN jtf_varchar2_table_100  ,
   p_price_break_type_code  IN jtf_varchar2_table_100  ,
   p_substitution_attribute IN jtf_varchar2_table_100  ,
   p_proration_type_code    IN jtf_varchar2_table_100  ,
   p_include_on_ret_flag    IN jtf_varchar2_table_100  ,
   p_credit_or_charge_flag  IN jtf_varchar2_table_100
)
RETURN ASO_Quote_Pub.Price_Adj_Tbl_Type
IS
   l_price_adj_tbl ASO_Quote_Pub.Price_Adj_Tbl_Type;
   l_table_size  PLS_INTEGER := 0;
   i             PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         l_price_adj_tbl(i).operation_code := p_operation_code(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_price_adjustment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).price_adjustment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).price_adjustment_id := p_price_adjustment_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_modifier_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modifier_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modifier_header_id := p_modifier_header_id(i);
         END IF;
         IF p_modifier_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modifier_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modifier_line_id := p_modifier_line_id(i);
         END IF;
         l_price_adj_tbl(i).modifier_line_type_code := p_mod_line_type_code(i);
         l_price_adj_tbl(i).modifier_mechanism_type_code := p_mod_mech_type_code(i);
         IF p_modified_from(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modified_from := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modified_from := p_modified_from(i);
         END IF;
         IF p_modified_to(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).modified_to := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).modified_to := p_modified_to(i);
         END IF;
         IF p_operand(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).operand := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).operand := p_operand(i);
         END IF;
         l_price_adj_tbl(i).arithmetic_operator := p_arithmetic_operator(i);
         l_price_adj_tbl(i).automatic_flag := p_automatic_flag(i);
         l_price_adj_tbl(i).update_allowable_flag := p_update_allowable_flag(i);
         l_price_adj_tbl(i).updated_flag := p_updated_flag(i);
         l_price_adj_tbl(i).applied_flag := p_applied_flag(i);
         l_price_adj_tbl(i).on_invoice_flag := p_on_invoice_flag(i);
         IF p_pricing_phase_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).pricing_phase_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).pricing_phase_id := p_pricing_phase_id(i);
         END IF;
         l_price_adj_tbl(i).attribute_category := p_attribute_category(i);
         l_price_adj_tbl(i).attribute1 := p_attribute1(i);
         l_price_adj_tbl(i).attribute2 := p_attribute2(i);
         l_price_adj_tbl(i).attribute3 := p_attribute3(i);
         l_price_adj_tbl(i).attribute4 := p_attribute4(i);
         l_price_adj_tbl(i).attribute5 := p_attribute5(i);
         l_price_adj_tbl(i).attribute6 := p_attribute6(i);
         l_price_adj_tbl(i).attribute7 := p_attribute7(i);
         l_price_adj_tbl(i).attribute8 := p_attribute8(i);
         l_price_adj_tbl(i).attribute9 := p_attribute9(i);
         l_price_adj_tbl(i).attribute10 := p_attribute10(i);
         l_price_adj_tbl(i).attribute11 := p_attribute11(i);
         l_price_adj_tbl(i).attribute12 := p_attribute12(i);
         l_price_adj_tbl(i).attribute13 := p_attribute13(i);
         l_price_adj_tbl(i).attribute14 := p_attribute14(i);
         l_price_adj_tbl(i).attribute15 := p_attribute15(i);
         l_price_adj_tbl(i).orig_sys_discount_ref := p_orig_sys_discount_ref(i);
         l_price_adj_tbl(i).change_sequence := p_change_sequence(i);
         l_price_adj_tbl(i).update_allowed := p_update_allowed(i);
         l_price_adj_tbl(i).change_reason_code := p_change_reason_code(i);
         l_price_adj_tbl(i).change_reason_text := p_change_reason_text(i);
         IF p_cost_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).cost_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).cost_id := p_cost_id(i);
         END IF;
         l_price_adj_tbl(i).tax_code := p_tax_code(i);
         l_price_adj_tbl(i).tax_exempt_flag := p_tax_exempt_flag(i);
         l_price_adj_tbl(i).tax_exempt_number := p_tax_exempt_number(i);
         l_price_adj_tbl(i).tax_exempt_reason_code := p_tax_exempt_reason_code(i);
         IF p_parent_adjustment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).parent_adjustment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).parent_adjustment_id := p_parent_adjustment_id(i);
         END IF;
         l_price_adj_tbl(i).invoiced_flag := p_invoiced_flag(i);
         l_price_adj_tbl(i).estimated_flag := p_estimated_flag(i);
         l_price_adj_tbl(i).inc_in_sales_performance := p_inc_in_sales_perfce(i);
         l_price_adj_tbl(i).split_action_code := p_split_action_code(i);
         IF p_adjusted_amount(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).adjusted_amount := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).adjusted_amount := p_adjusted_amount(i);
         END IF;
         l_price_adj_tbl(i).charge_type_code := p_charge_type_code(i);
         l_price_adj_tbl(i).charge_subtype_code := p_charge_subtype_code(i);
         IF p_range_break_quantity(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).range_break_quantity := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).range_break_quantity := p_range_break_quantity(i);
         END IF;
         IF p_accrual_conv_rate(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).accrual_conversion_rate := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).accrual_conversion_rate := p_accrual_conv_rate(i);
         END IF;
         IF p_pricing_group_sequence(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).pricing_group_sequence := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).pricing_group_sequence := p_pricing_group_sequence(i);
         END IF;
         l_price_adj_tbl(i).accrual_flag := p_accrual_flag(i);
         l_price_adj_tbl(i).list_line_no := p_list_line_no(i);
         l_price_adj_tbl(i).source_system_code := p_source_system_code(i);
         IF p_benefit_qty(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_tbl(i).benefit_qty := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_tbl(i).benefit_qty := p_benefit_qty(i);
         END IF;
         l_price_adj_tbl(i).benefit_uom_code := p_benefit_uom_code(i);
         l_price_adj_tbl(i).print_on_invoice_flag := p_print_on_invoice_flag(i);
         IF p_expiration_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).expiration_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).expiration_date := p_expiration_date(i);
         END IF;
         l_price_adj_tbl(i).rebate_transaction_type_code := p_rebate_trans_type_code(i);
         l_price_adj_tbl(i).rebate_transaction_reference := p_rebate_trans_reference(i);
         l_price_adj_tbl(i).rebate_payment_system_code := p_rebate_pay_system_code(i);
         IF p_redeemed_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_tbl(i).redeemed_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_tbl(i).redeemed_date := p_redeemed_date(i);
         END IF;
         l_price_adj_tbl(i).redeemed_flag := p_redeemed_flag(i);
         l_price_adj_tbl(i).modifier_level_code := p_modifier_level_code(i);
         l_price_adj_tbl(i).price_break_type_code := p_price_break_type_code(i);
         l_price_adj_tbl(i).substitution_attribute := p_substitution_attribute(i);
         l_price_adj_tbl(i).proration_type_code := p_proration_type_code(i);
         l_price_adj_tbl(i).include_on_returns_flag := p_include_on_ret_flag(i);
         l_price_adj_tbl(i).credit_or_charge_flag := p_credit_or_charge_flag(i);
      END LOOP;

      RETURN l_price_adj_tbl;
   END IF;
END Construct_Price_Adj_Tbl;


FUNCTION Construct_Price_Adj_Attr_Tbl(
  p_operation_code         IN jtf_varchar2_table_100  ,
   p_qte_line_index         IN jtf_number_table        ,
   p_price_adj_index        IN jtf_number_table        ,
   p_price_adj_attrib_id    IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_updated_by        IN jtf_number_table        ,
   p_last_update_login      IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_request_id             IN jtf_number_table        ,
   p_price_adjustment_id    IN jtf_number_table        ,
   p_pricing_context        IN jtf_varchar2_table_100  ,
   p_pricing_attribute      IN jtf_varchar2_table_100  ,
   p_prc_attr_value_from    IN jtf_varchar2_table_300  ,
   p_pricing_attr_value_to  IN jtf_varchar2_table_300  ,
   p_comparison_operator    IN jtf_varchar2_table_100  ,
   p_flex_title             IN jtf_varchar2_table_100
)
RETURN ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type
IS
   l_price_adj_attr_tbl ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
   l_table_size         PLS_INTEGER := 0;
   i                    PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         l_price_adj_attr_tbl(i).operation_code := p_operation_code(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_price_adj_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).price_adj_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).price_adj_index := p_price_adj_index(i);
         END IF;
         IF p_price_adj_attrib_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).price_adj_attrib_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).price_adj_attrib_id := p_price_adj_attrib_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_attr_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_attr_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_attr_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_attr_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_adj_attr_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_adj_attr_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_price_adjustment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_adj_attr_tbl(i).price_adjustment_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_adj_attr_tbl(i).price_adjustment_id := p_price_adjustment_id(i);
         END IF;
         l_price_adj_attr_tbl(i).pricing_context := p_pricing_context(i);
         l_price_adj_attr_tbl(i).pricing_attribute := p_pricing_attribute(i);
         l_price_adj_attr_tbl(i).pricing_attr_value_from := p_prc_attr_value_from(i);
         l_price_adj_attr_tbl(i).pricing_attr_value_to := p_pricing_attr_value_to(i);
         l_price_adj_attr_tbl(i).comparison_operator := p_comparison_operator(i);
         l_price_adj_attr_tbl(i).flex_title := p_flex_title(i);
      END LOOP;

      RETURN l_price_adj_attr_tbl;
   END IF;
END Construct_Price_Adj_Attr_Tbl;


FUNCTION Construct_Line_Attribs_Ext_Tbl(
    p_qte_line_index         IN jtf_number_table         ,
   p_shipment_index         IN jtf_number_table         ,
   p_line_attribute_id      IN jtf_number_table         ,
   p_creation_date          IN jtf_date_table           ,
   p_created_by             IN jtf_number_table         ,
   p_last_update_date       IN jtf_date_table           ,
   p_last_updated_by        IN jtf_number_table         ,
   p_last_update_login      IN jtf_number_table         ,
   p_request_id             IN jtf_number_table         ,
   p_program_application_id IN jtf_number_table         ,
   p_program_id             IN jtf_number_table         ,
   p_program_update_date    IN jtf_date_table           ,
   p_quote_header_id        IN jtf_number_table         ,
   p_quote_line_id          IN jtf_number_table         ,
   p_quote_shipment_id      IN jtf_number_table         ,
   p_attribute_type_code    IN jtf_varchar2_table_100   ,
   p_name                   IN jtf_varchar2_table_100   ,
   p_value                  IN jtf_varchar2_table_2000  ,
   p_value_type             IN jtf_varchar2_table_300   ,
   p_status                 IN jtf_varchar2_table_100   ,
   p_application_id         IN jtf_number_table         ,
   p_start_date_active      IN jtf_date_table           ,
   p_end_date_active        IN jtf_date_table           ,
   p_operation_code         IN jtf_varchar2_table_100
)
RETURN ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type
IS
   l_line_attribs_ext_tbl ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type;
   l_table_size           PLS_INTEGER := 0;
   i                      PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_shipment_index(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).shipment_index := p_shipment_index(i);
         END IF;
         IF p_line_attribute_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).line_attribute_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).line_attribute_id := p_line_attribute_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_attribs_ext_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_attribs_ext_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_attribs_ext_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_attribs_ext_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_attribs_ext_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_attribs_ext_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_quote_shipment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).quote_shipment_id := p_quote_shipment_id(i);
         END IF;
         l_line_attribs_ext_tbl(i).attribute_type_code := p_attribute_type_code(i);
         l_line_attribs_ext_tbl(i).name := p_name(i);
         l_line_attribs_ext_tbl(i).value := p_value(i);
         l_line_attribs_ext_tbl(i).value_type := p_value_type(i);
         l_line_attribs_ext_tbl(i).status := p_status(i);
         IF p_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_attribs_ext_tbl(i).application_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_attribs_ext_tbl(i).application_id := p_application_id(i);
         END IF;
         IF p_start_date_active(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_attribs_ext_tbl(i).start_date_active := FND_API.G_MISS_DATE;
         ELSE
            l_line_attribs_ext_tbl(i).start_date_active := p_start_date_active(i);
         END IF;
         IF p_end_date_active(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_attribs_ext_tbl(i).end_date_active := FND_API.G_MISS_DATE;
         ELSE
            l_line_attribs_ext_tbl(i).end_date_active := p_end_date_active(i);
         END IF;
         l_line_attribs_ext_tbl(i).operation_code := p_operation_code(i);
      END LOOP;

      RETURN l_line_attribs_ext_tbl;
   END IF;
END Construct_Line_Attribs_Ext_Tbl;


FUNCTION Construct_Freight_Charge_Tbl(
   p_operation_code         IN jtf_varchar2_table_100  ,
   p_qte_line_index         IN jtf_number_table        ,
   p_shipment_index         IN jtf_number_table        ,
   p_freight_charge_id      IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_updated_by        IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_update_login      IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_request_id             IN jtf_number_table        ,
   p_quote_shipment_id      IN jtf_number_table        ,
   p_quote_line_id          IN jtf_number_table        ,
   p_freight_charge_type_id IN jtf_number_table        ,
   p_charge_amount          IN jtf_number_table        ,
   p_attribute_category     IN jtf_varchar2_table_200  ,
   p_attribute1             IN jtf_varchar2_table_200  ,
   p_attribute2             IN jtf_varchar2_table_200  ,
   p_attribute3             IN jtf_varchar2_table_200  ,
   p_attribute4             IN jtf_varchar2_table_200  ,
   p_attribute5             IN jtf_varchar2_table_200  ,
   p_attribute6             IN jtf_varchar2_table_200  ,
   p_attribute7             IN jtf_varchar2_table_200  ,
   p_attribute8             IN jtf_varchar2_table_200  ,
   p_attribute9             IN jtf_varchar2_table_200  ,
   p_attribute10            IN jtf_varchar2_table_200  ,
   p_attribute11            IN jtf_varchar2_table_200  ,
   p_attribute12            IN jtf_varchar2_table_200  ,
   p_attribute13            IN jtf_varchar2_table_200  ,
   p_attribute14            IN jtf_varchar2_table_200  ,
   p_attribute15            IN jtf_varchar2_table_200
)
RETURN ASO_Quote_Pub.Freight_Charge_Tbl_Type
IS
   l_freight_charge_tbl ASO_Quote_Pub.Freight_Charge_Tbl_Type;
   l_table_size         PLS_INTEGER := 0;
   i                    PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         l_freight_charge_tbl(i).operation_code := p_operation_code(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_shipment_index(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).shipment_index := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).shipment_index := p_shipment_index(i);
         END IF;
         IF p_freight_charge_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).freight_charge_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).freight_charge_id := p_freight_charge_id(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_freight_charge_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_freight_charge_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_freight_charge_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_freight_charge_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_freight_charge_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_freight_charge_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_quote_shipment_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).quote_shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).quote_shipment_id := p_quote_shipment_id(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_freight_charge_type_id(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).freight_charge_type_id := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).freight_charge_type_id := p_freight_charge_type_id(i);
         END IF;
         IF p_charge_amount(i)= ROSETTA_G_MISS_NUM THEN
            l_freight_charge_tbl(i).charge_amount := FND_API.G_MISS_NUM;
         ELSE
            l_freight_charge_tbl(i).charge_amount := p_charge_amount(i);
         END IF;
         l_freight_charge_tbl(i).attribute_category := p_attribute_category(i);
         l_freight_charge_tbl(i).attribute1 := p_attribute1(i);
         l_freight_charge_tbl(i).attribute2 := p_attribute2(i);
         l_freight_charge_tbl(i).attribute3 := p_attribute3(i);
         l_freight_charge_tbl(i).attribute4 := p_attribute4(i);
         l_freight_charge_tbl(i).attribute5 := p_attribute5(i);
         l_freight_charge_tbl(i).attribute6 := p_attribute6(i);
         l_freight_charge_tbl(i).attribute7 := p_attribute7(i);
         l_freight_charge_tbl(i).attribute8 := p_attribute8(i);
         l_freight_charge_tbl(i).attribute9 := p_attribute9(i);
         l_freight_charge_tbl(i).attribute10 := p_attribute10(i);
         l_freight_charge_tbl(i).attribute11 := p_attribute11(i);
         l_freight_charge_tbl(i).attribute12 := p_attribute12(i);
         l_freight_charge_tbl(i).attribute13 := p_attribute13(i);
         l_freight_charge_tbl(i).attribute14 := p_attribute14(i);
         l_freight_charge_tbl(i).attribute15 := p_attribute15(i);
      END LOOP;

      RETURN l_freight_charge_tbl;
   END IF;
END Construct_Freight_Charge_Tbl;


FUNCTION Construct_Price_Attributes_Tbl(
   p_operation_code         IN jtf_varchar2_table_100  ,
   p_qte_line_index         IN jtf_number_table        ,
   p_price_attribute_id     IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_updated_by        IN jtf_number_table        ,
   p_last_update_login      IN jtf_number_table        ,
   p_request_id             IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_quote_header_id        IN jtf_number_table        ,
   p_quote_line_id          IN jtf_number_table        ,
   p_flex_title             IN jtf_varchar2_table_100  ,
   p_pricing_context        IN jtf_varchar2_table_100  ,
   p_pricing_attribute1     IN jtf_varchar2_table_300  ,
   p_pricing_attribute2     IN jtf_varchar2_table_300  ,
   p_pricing_attribute3     IN jtf_varchar2_table_300  ,
   p_pricing_attribute4     IN jtf_varchar2_table_300  ,
   p_pricing_attribute5     IN jtf_varchar2_table_300  ,
   p_pricing_attribute6     IN jtf_varchar2_table_300  ,
   p_pricing_attribute7     IN jtf_varchar2_table_300  ,
   p_pricing_attribute8     IN jtf_varchar2_table_300  ,
   p_pricing_attribute9     IN jtf_varchar2_table_300  ,
   p_pricing_attribute10    IN jtf_varchar2_table_300  ,
   p_pricing_attribute11    IN jtf_varchar2_table_300  ,
   p_pricing_attribute12    IN jtf_varchar2_table_300  ,
   p_pricing_attribute13    IN jtf_varchar2_table_300  ,
   p_pricing_attribute14    IN jtf_varchar2_table_300  ,
   p_pricing_attribute15    IN jtf_varchar2_table_300  ,
   p_pricing_attribute16    IN jtf_varchar2_table_300  ,
   p_pricing_attribute17    IN jtf_varchar2_table_300  ,
   p_pricing_attribute18    IN jtf_varchar2_table_300  ,
   p_pricing_attribute19    IN jtf_varchar2_table_300  ,
   p_pricing_attribute20    IN jtf_varchar2_table_300  ,
   p_pricing_attribute21    IN jtf_varchar2_table_300  ,
   p_pricing_attribute22    IN jtf_varchar2_table_300  ,
   p_pricing_attribute23    IN jtf_varchar2_table_300  ,
   p_pricing_attribute24    IN jtf_varchar2_table_300  ,
   p_pricing_attribute25    IN jtf_varchar2_table_300  ,
   p_pricing_attribute26    IN jtf_varchar2_table_300  ,
   p_pricing_attribute27    IN jtf_varchar2_table_300  ,
   p_pricing_attribute28    IN jtf_varchar2_table_300  ,
   p_pricing_attribute29    IN jtf_varchar2_table_300  ,
   p_pricing_attribute30    IN jtf_varchar2_table_300  ,
   p_pricing_attribute31    IN jtf_varchar2_table_300  ,
   p_pricing_attribute32    IN jtf_varchar2_table_300  ,
   p_pricing_attribute33    IN jtf_varchar2_table_300  ,
   p_pricing_attribute34    IN jtf_varchar2_table_300  ,
   p_pricing_attribute35    IN jtf_varchar2_table_300  ,
   p_pricing_attribute36    IN jtf_varchar2_table_300  ,
   p_pricing_attribute37    IN jtf_varchar2_table_300  ,
   p_pricing_attribute38    IN jtf_varchar2_table_300  ,
   p_pricing_attribute39    IN jtf_varchar2_table_300  ,
   p_pricing_attribute40    IN jtf_varchar2_table_300  ,
   p_pricing_attribute41    IN jtf_varchar2_table_300  ,
   p_pricing_attribute42    IN jtf_varchar2_table_300  ,
   p_pricing_attribute43    IN jtf_varchar2_table_300  ,
   p_pricing_attribute44    IN jtf_varchar2_table_300  ,
   p_pricing_attribute45    IN jtf_varchar2_table_300  ,
   p_pricing_attribute46    IN jtf_varchar2_table_300  ,
   p_pricing_attribute47    IN jtf_varchar2_table_300  ,
   p_pricing_attribute48    IN jtf_varchar2_table_300  ,
   p_pricing_attribute49    IN jtf_varchar2_table_300  ,
   p_pricing_attribute50    IN jtf_varchar2_table_300  ,
   p_pricing_attribute51    IN jtf_varchar2_table_300  ,
   p_pricing_attribute52    IN jtf_varchar2_table_300  ,
   p_pricing_attribute53    IN jtf_varchar2_table_300  ,
   p_pricing_attribute54    IN jtf_varchar2_table_300  ,
   p_pricing_attribute55    IN jtf_varchar2_table_300  ,
   p_pricing_attribute56    IN jtf_varchar2_table_300  ,
   p_pricing_attribute57    IN jtf_varchar2_table_300  ,
   p_pricing_attribute58    IN jtf_varchar2_table_300  ,
   p_pricing_attribute59    IN jtf_varchar2_table_300  ,
   p_pricing_attribute60    IN jtf_varchar2_table_300  ,
   p_pricing_attribute61    IN jtf_varchar2_table_300  ,
   p_pricing_attribute62    IN jtf_varchar2_table_300  ,
   p_pricing_attribute63    IN jtf_varchar2_table_300  ,
   p_pricing_attribute64    IN jtf_varchar2_table_300  ,
   p_pricing_attribute65    IN jtf_varchar2_table_300  ,
   p_pricing_attribute66    IN jtf_varchar2_table_300  ,
   p_pricing_attribute67    IN jtf_varchar2_table_300  ,
   p_pricing_attribute68    IN jtf_varchar2_table_300  ,
   p_pricing_attribute69    IN jtf_varchar2_table_300  ,
   p_pricing_attribute70    IN jtf_varchar2_table_300  ,
   p_pricing_attribute71    IN jtf_varchar2_table_300  ,
   p_pricing_attribute72    IN jtf_varchar2_table_300  ,
   p_pricing_attribute73    IN jtf_varchar2_table_300  ,
   p_pricing_attribute74    IN jtf_varchar2_table_300  ,
   p_pricing_attribute75    IN jtf_varchar2_table_300  ,
   p_pricing_attribute76    IN jtf_varchar2_table_300  ,
   p_pricing_attribute77    IN jtf_varchar2_table_300  ,
   p_pricing_attribute78    IN jtf_varchar2_table_300  ,
   p_pricing_attribute79    IN jtf_varchar2_table_300  ,
   p_pricing_attribute80    IN jtf_varchar2_table_300  ,
   p_pricing_attribute81    IN jtf_varchar2_table_300  ,
   p_pricing_attribute82    IN jtf_varchar2_table_300  ,
   p_pricing_attribute83    IN jtf_varchar2_table_300  ,
   p_pricing_attribute84    IN jtf_varchar2_table_300  ,
   p_pricing_attribute85    IN jtf_varchar2_table_300  ,
   p_pricing_attribute86    IN jtf_varchar2_table_300  ,
   p_pricing_attribute87    IN jtf_varchar2_table_300  ,
   p_pricing_attribute88    IN jtf_varchar2_table_300  ,
   p_pricing_attribute89    IN jtf_varchar2_table_300  ,
   p_pricing_attribute90    IN jtf_varchar2_table_300  ,
   p_pricing_attribute91    IN jtf_varchar2_table_300  ,
   p_pricing_attribute92    IN jtf_varchar2_table_300  ,
   p_pricing_attribute93    IN jtf_varchar2_table_300  ,
   p_pricing_attribute94    IN jtf_varchar2_table_300  ,
   p_pricing_attribute95    IN jtf_varchar2_table_300  ,
   p_pricing_attribute96    IN jtf_varchar2_table_300  ,
   p_pricing_attribute97    IN jtf_varchar2_table_300  ,
   p_pricing_attribute98    IN jtf_varchar2_table_300  ,
   p_pricing_attribute99    IN jtf_varchar2_table_300  ,
   p_pricing_attribute100   IN jtf_varchar2_table_300  ,
   p_context                IN jtf_varchar2_table_100  ,
   p_attribute1             IN jtf_varchar2_table_300  ,
   p_attribute2             IN jtf_varchar2_table_300  ,
   p_attribute3             IN jtf_varchar2_table_300  ,
   p_attribute4             IN jtf_varchar2_table_300  ,
   p_attribute5             IN jtf_varchar2_table_300  ,
   p_attribute6             IN jtf_varchar2_table_300  ,
   p_attribute7             IN jtf_varchar2_table_300  ,
   p_attribute8             IN jtf_varchar2_table_300  ,
   p_attribute9             IN jtf_varchar2_table_300  ,
   p_attribute10            IN jtf_varchar2_table_300  ,
   p_attribute11            IN jtf_varchar2_table_300  ,
   p_attribute12            IN jtf_varchar2_table_300  ,
   p_attribute13            IN jtf_varchar2_table_300  ,
   p_attribute14            IN jtf_varchar2_table_300  ,
   p_attribute15            IN jtf_varchar2_table_300
)
RETURN ASO_Quote_Pub.Price_Attributes_Tbl_Type
IS
   l_price_attributes_tbl ASO_Quote_Pub.Price_Attributes_Tbl_Type;
   l_table_size           PLS_INTEGER := 0;
   i                      PLS_INTEGER;
BEGIN
   IF p_operation_code IS NOT NULL THEN
      l_table_size := p_operation_code.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         l_price_attributes_tbl(i).operation_code := p_operation_code(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_price_attribute_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).price_attribute_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).price_attribute_id := p_price_attribute_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_attributes_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_attributes_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_attributes_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_attributes_tbl(i).last_update_date := p_last_update_date(i);
         END IF;

         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_price_attributes_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_price_attributes_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_quote_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_price_attributes_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_price_attributes_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         l_price_attributes_tbl(i).flex_title := p_flex_title(i);
         l_price_attributes_tbl(i).pricing_context := p_pricing_context(i);
         l_price_attributes_tbl(i).pricing_attribute1 := p_pricing_attribute1(i);
         l_price_attributes_tbl(i).pricing_attribute2 := p_pricing_attribute2(i);
         l_price_attributes_tbl(i).pricing_attribute3 := p_pricing_attribute3(i);
         l_price_attributes_tbl(i).pricing_attribute4 := p_pricing_attribute4(i);
         l_price_attributes_tbl(i).pricing_attribute5 := p_pricing_attribute5(i);
         l_price_attributes_tbl(i).pricing_attribute6 := p_pricing_attribute6(i);
         l_price_attributes_tbl(i).pricing_attribute7 := p_pricing_attribute7(i);
         l_price_attributes_tbl(i).pricing_attribute8 := p_pricing_attribute8(i);
         l_price_attributes_tbl(i).pricing_attribute9 := p_pricing_attribute9(i);
         l_price_attributes_tbl(i).pricing_attribute10 := p_pricing_attribute10(i);
         l_price_attributes_tbl(i).pricing_attribute11 := p_pricing_attribute11(i);
         l_price_attributes_tbl(i).pricing_attribute12 := p_pricing_attribute12(i);
         l_price_attributes_tbl(i).pricing_attribute13 := p_pricing_attribute13(i);
         l_price_attributes_tbl(i).pricing_attribute14 := p_pricing_attribute14(i);
         l_price_attributes_tbl(i).pricing_attribute15 := p_pricing_attribute15(i);
         l_price_attributes_tbl(i).pricing_attribute16 := p_pricing_attribute16(i);
         l_price_attributes_tbl(i).pricing_attribute17 := p_pricing_attribute17(i);
         l_price_attributes_tbl(i).pricing_attribute18 := p_pricing_attribute18(i);
         l_price_attributes_tbl(i).pricing_attribute19 := p_pricing_attribute19(i);
         l_price_attributes_tbl(i).pricing_attribute20 := p_pricing_attribute20(i);
         l_price_attributes_tbl(i).pricing_attribute21 := p_pricing_attribute21(i);
         l_price_attributes_tbl(i).pricing_attribute22 := p_pricing_attribute22(i);
         l_price_attributes_tbl(i).pricing_attribute23 := p_pricing_attribute23(i);
         l_price_attributes_tbl(i).pricing_attribute24 := p_pricing_attribute24(i);
         l_price_attributes_tbl(i).pricing_attribute25 := p_pricing_attribute25(i);
         l_price_attributes_tbl(i).pricing_attribute26 := p_pricing_attribute26(i);
         l_price_attributes_tbl(i).pricing_attribute27 := p_pricing_attribute27(i);
         l_price_attributes_tbl(i).pricing_attribute28 := p_pricing_attribute28(i);
         l_price_attributes_tbl(i).pricing_attribute29 := p_pricing_attribute29(i);
         l_price_attributes_tbl(i).pricing_attribute30 := p_pricing_attribute30(i);
         l_price_attributes_tbl(i).pricing_attribute31 := p_pricing_attribute31(i);
         l_price_attributes_tbl(i).pricing_attribute32 := p_pricing_attribute32(i);
         l_price_attributes_tbl(i).pricing_attribute33 := p_pricing_attribute33(i);
         l_price_attributes_tbl(i).pricing_attribute34 := p_pricing_attribute34(i);
         l_price_attributes_tbl(i).pricing_attribute35 := p_pricing_attribute35(i);
         l_price_attributes_tbl(i).pricing_attribute36 := p_pricing_attribute36(i);
         l_price_attributes_tbl(i).pricing_attribute37 := p_pricing_attribute37(i);
         l_price_attributes_tbl(i).pricing_attribute38 := p_pricing_attribute38(i);
         l_price_attributes_tbl(i).pricing_attribute39 := p_pricing_attribute39(i);
         l_price_attributes_tbl(i).pricing_attribute40 := p_pricing_attribute40(i);
         l_price_attributes_tbl(i).pricing_attribute41 := p_pricing_attribute41(i);
         l_price_attributes_tbl(i).pricing_attribute42 := p_pricing_attribute42(i);
         l_price_attributes_tbl(i).pricing_attribute43 := p_pricing_attribute43(i);
         l_price_attributes_tbl(i).pricing_attribute44 := p_pricing_attribute44(i);
         l_price_attributes_tbl(i).pricing_attribute45 := p_pricing_attribute45(i);
         l_price_attributes_tbl(i).pricing_attribute46 := p_pricing_attribute46(i);
         l_price_attributes_tbl(i).pricing_attribute47 := p_pricing_attribute47(i);
         l_price_attributes_tbl(i).pricing_attribute48 := p_pricing_attribute48(i);
         l_price_attributes_tbl(i).pricing_attribute49 := p_pricing_attribute49(i);
         l_price_attributes_tbl(i).pricing_attribute50 := p_pricing_attribute50(i);
         l_price_attributes_tbl(i).pricing_attribute51 := p_pricing_attribute51(i);
         l_price_attributes_tbl(i).pricing_attribute52 := p_pricing_attribute52(i);
         l_price_attributes_tbl(i).pricing_attribute53 := p_pricing_attribute53(i);
         l_price_attributes_tbl(i).pricing_attribute54 := p_pricing_attribute54(i);
         l_price_attributes_tbl(i).pricing_attribute55 := p_pricing_attribute55(i);
         l_price_attributes_tbl(i).pricing_attribute56 := p_pricing_attribute56(i);
         l_price_attributes_tbl(i).pricing_attribute57 := p_pricing_attribute57(i);
         l_price_attributes_tbl(i).pricing_attribute58 := p_pricing_attribute58(i);
         l_price_attributes_tbl(i).pricing_attribute59 := p_pricing_attribute59(i);
         l_price_attributes_tbl(i).pricing_attribute60 := p_pricing_attribute60(i);
         l_price_attributes_tbl(i).pricing_attribute61 := p_pricing_attribute61(i);
         l_price_attributes_tbl(i).pricing_attribute62 := p_pricing_attribute62(i);
         l_price_attributes_tbl(i).pricing_attribute63 := p_pricing_attribute63(i);
         l_price_attributes_tbl(i).pricing_attribute64 := p_pricing_attribute64(i);
         l_price_attributes_tbl(i).pricing_attribute65 := p_pricing_attribute65(i);
         l_price_attributes_tbl(i).pricing_attribute66 := p_pricing_attribute66(i);
         l_price_attributes_tbl(i).pricing_attribute67 := p_pricing_attribute67(i);
         l_price_attributes_tbl(i).pricing_attribute68 := p_pricing_attribute68(i);
         l_price_attributes_tbl(i).pricing_attribute69 := p_pricing_attribute69(i);
         l_price_attributes_tbl(i).pricing_attribute70 := p_pricing_attribute70(i);
         l_price_attributes_tbl(i).pricing_attribute71 := p_pricing_attribute71(i);
         l_price_attributes_tbl(i).pricing_attribute72 := p_pricing_attribute72(i);
         l_price_attributes_tbl(i).pricing_attribute73 := p_pricing_attribute73(i);
         l_price_attributes_tbl(i).pricing_attribute74 := p_pricing_attribute74(i);
         l_price_attributes_tbl(i).pricing_attribute75 := p_pricing_attribute75(i);
         l_price_attributes_tbl(i).pricing_attribute76 := p_pricing_attribute76(i);
         l_price_attributes_tbl(i).pricing_attribute77 := p_pricing_attribute77(i);
         l_price_attributes_tbl(i).pricing_attribute78 := p_pricing_attribute78(i);
         l_price_attributes_tbl(i).pricing_attribute79 := p_pricing_attribute79(i);
         l_price_attributes_tbl(i).pricing_attribute80 := p_pricing_attribute80(i);
         l_price_attributes_tbl(i).pricing_attribute81 := p_pricing_attribute81(i);
         l_price_attributes_tbl(i).pricing_attribute82 := p_pricing_attribute82(i);
         l_price_attributes_tbl(i).pricing_attribute83 := p_pricing_attribute83(i);
         l_price_attributes_tbl(i).pricing_attribute84 := p_pricing_attribute84(i);
         l_price_attributes_tbl(i).pricing_attribute85 := p_pricing_attribute85(i);
         l_price_attributes_tbl(i).pricing_attribute86 := p_pricing_attribute86(i);
         l_price_attributes_tbl(i).pricing_attribute87 := p_pricing_attribute87(i);
         l_price_attributes_tbl(i).pricing_attribute88 := p_pricing_attribute88(i);
         l_price_attributes_tbl(i).pricing_attribute89 := p_pricing_attribute89(i);
         l_price_attributes_tbl(i).pricing_attribute90 := p_pricing_attribute90(i);
         l_price_attributes_tbl(i).pricing_attribute91 := p_pricing_attribute91(i);
         l_price_attributes_tbl(i).pricing_attribute92 := p_pricing_attribute92(i);
         l_price_attributes_tbl(i).pricing_attribute93 := p_pricing_attribute93(i);
         l_price_attributes_tbl(i).pricing_attribute94 := p_pricing_attribute94(i);
         l_price_attributes_tbl(i).pricing_attribute95 := p_pricing_attribute95(i);
         l_price_attributes_tbl(i).pricing_attribute96 := p_pricing_attribute96(i);
         l_price_attributes_tbl(i).pricing_attribute97 := p_pricing_attribute97(i);
         l_price_attributes_tbl(i).pricing_attribute98 := p_pricing_attribute98(i);
         l_price_attributes_tbl(i).pricing_attribute99 := p_pricing_attribute99(i);
         l_price_attributes_tbl(i).pricing_attribute100 := p_pricing_attribute100(i);
         l_price_attributes_tbl(i).context := p_context(i);
         l_price_attributes_tbl(i).attribute1 := p_attribute1(i);
         l_price_attributes_tbl(i).attribute2 := p_attribute2(i);
         l_price_attributes_tbl(i).attribute3 := p_attribute3(i);
         l_price_attributes_tbl(i).attribute4 := p_attribute4(i);
         l_price_attributes_tbl(i).attribute5 := p_attribute5(i);
         l_price_attributes_tbl(i).attribute6 := p_attribute6(i);
         l_price_attributes_tbl(i).attribute7 := p_attribute7(i);
         l_price_attributes_tbl(i).attribute8 := p_attribute8(i);
         l_price_attributes_tbl(i).attribute9 := p_attribute9(i);
         l_price_attributes_tbl(i).attribute10 := p_attribute10(i);
         l_price_attributes_tbl(i).attribute11 := p_attribute11(i);
         l_price_attributes_tbl(i).attribute12 := p_attribute12(i);
         l_price_attributes_tbl(i).attribute13 := p_attribute13(i);
         l_price_attributes_tbl(i).attribute14 := p_attribute14(i);
         l_price_attributes_tbl(i).attribute15 := p_attribute15(i);
      END LOOP;

      RETURN l_price_attributes_tbl;
   END IF;
END Construct_Price_Attributes_Tbl;

--
FUNCTION Construct_Shipment_Rec(
  p_operation_code         IN VARCHAR2       ,
   p_qte_line_index         IN NUMBER         ,
   p_shipment_id            IN NUMBER         ,
   p_creation_date          IN DATE           ,
   p_created_by             IN NUMBER         ,
   p_last_update_date       IN DATE           ,
   p_last_updated_by        IN NUMBER         ,
   p_last_update_login      IN NUMBER         ,
   p_request_id             IN NUMBER         ,
   p_program_application_id IN NUMBER         ,
   p_program_id             IN NUMBER         ,
   p_program_update_date    IN DATE           ,
   p_quote_header_id        IN NUMBER         ,
   p_quote_line_id          IN NUMBER         ,
   p_promise_date           IN DATE           ,
   p_request_date           IN DATE           ,
   p_schedule_ship_date     IN DATE           ,
   p_ship_to_party_site_id  IN NUMBER         ,
   p_ship_to_party_id       IN NUMBER         ,
   p_ship_to_cust_acct_id   IN NUMBER         ,
   p_ship_partial_flag      IN VARCHAR2       ,
   p_ship_set_id            IN NUMBER         ,
   p_ship_method_code       IN VARCHAR2       ,
   p_freight_terms_code     IN VARCHAR2       ,
   p_freight_carrier_code   IN VARCHAR2       ,
   p_fob_code               IN VARCHAR2       ,
   p_shipment_priority_code IN VARCHAR2       ,
   p_shipping_instructions  IN VARCHAR2       ,
   p_packing_instructions   IN VARCHAR2       ,
   p_quantity               IN NUMBER         ,
   p_reserved_quantity      IN NUMBER         ,
   p_reservation_id         IN NUMBER         ,
   p_order_line_id          IN NUMBER         ,
   p_ship_to_party_name     IN VARCHAR2       ,
   p_ship_to_cont_fst_name  IN VARCHAR2       ,
   p_ship_to_cont_mid_name  IN VARCHAR2       ,
   p_ship_to_cont_lst_name  IN VARCHAR2       ,
   p_ship_to_address1       IN VARCHAR2       ,
   p_ship_to_address2       IN VARCHAR2       ,
   p_ship_to_address3       IN VARCHAR2       ,
   p_ship_to_address4       IN VARCHAR2       ,
   p_ship_to_country_code   IN VARCHAR2       ,
   p_ship_to_country        IN VARCHAR2       ,
   p_ship_to_city           IN VARCHAR2       ,
   p_ship_to_postal_code    IN VARCHAR2       ,
   p_ship_to_state          IN VARCHAR2       ,
   p_ship_to_province       IN VARCHAR2       ,
   p_ship_to_county         IN VARCHAR2       ,
   p_attribute_category     IN VARCHAR2       ,
   p_attribute1             IN VARCHAR2       ,
   p_attribute2             IN VARCHAR2       ,
   p_attribute3             IN VARCHAR2       ,
   p_attribute4             IN VARCHAR2       ,
   p_attribute5             IN VARCHAR2       ,
   p_attribute6             IN VARCHAR2       ,
   p_attribute7             IN VARCHAR2       ,
   p_attribute8             IN VARCHAR2       ,
   p_attribute9             IN VARCHAR2       ,
   p_attribute10            IN VARCHAR2       ,
   p_attribute11            IN VARCHAR2       ,
   p_attribute12            IN VARCHAR2       ,
   p_attribute13            IN VARCHAR2       ,
   p_attribute14            IN VARCHAR2       ,
   p_attribute15            IN VARCHAR2
)
RETURN ASO_Quote_Pub.Shipment_Rec_Type
IS
   l_shipment_Rec ASO_Quote_Pub.Shipment_Rec_Type;
BEGIN

         l_shipment_rec.operation_code := p_operation_code;
         IF p_qte_line_index = ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.qte_line_index := p_qte_line_index;
         END IF;
         IF p_shipment_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.shipment_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.shipment_id := p_shipment_id;
         END IF;
         IF p_creation_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.creation_date := p_creation_date;
         END IF;
         IF p_created_by= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.created_by := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.created_by := p_created_by;
         END IF;
         IF p_last_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.last_update_date := p_last_update_date;
         END IF;
         IF p_last_updated_by= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.last_updated_by := p_last_updated_by;
         END IF;
         IF p_last_update_login= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.last_update_login := p_last_update_login;
         END IF;
         IF p_request_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.request_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.request_id := p_request_id;
         END IF;
         IF p_program_application_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.program_application_id := p_program_application_id;
         END IF;
         IF p_program_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.program_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.program_id := p_program_id;
         END IF;
         IF p_program_update_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.program_update_date := p_program_update_date;
         END IF;
         IF p_quote_header_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.quote_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.quote_header_id := p_quote_header_id;
         END IF;
         IF p_quote_line_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.quote_line_id := p_quote_line_id;
         END IF;
         IF p_promise_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.promise_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.promise_date := p_promise_date;
         END IF;
         IF p_request_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.request_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.request_date := p_request_date;
         END IF;
         IF p_schedule_ship_date= ROSETTA_G_MISTAKE_DATE THEN
            l_shipment_rec.schedule_ship_date := FND_API.G_MISS_DATE;
         ELSE
            l_shipment_rec.schedule_ship_date := p_schedule_ship_date;
         END IF;
         IF p_ship_to_party_site_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_party_site_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_party_site_id := p_ship_to_party_site_id;
         END IF;
         IF p_ship_to_party_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_party_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_party_id := p_ship_to_party_id;
         END IF;
         IF p_ship_to_cust_acct_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_to_cust_account_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_to_cust_account_id := p_ship_to_cust_acct_id;
         END IF;
         l_shipment_rec.ship_partial_flag := p_ship_partial_flag;
         IF p_ship_set_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.ship_set_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.ship_set_id := p_ship_set_id;
         END IF;
         l_shipment_rec.ship_method_code := p_ship_method_code;
         l_shipment_rec.freight_terms_code := p_freight_terms_code;
         l_shipment_rec.freight_carrier_code := p_freight_carrier_code;
         l_shipment_rec.fob_code := p_fob_code;
         l_shipment_rec.shipment_priority_code := p_shipment_priority_code;
         l_shipment_rec.shipping_instructions := p_shipping_instructions;
         l_shipment_rec.packing_instructions := p_packing_instructions;
         IF p_quantity= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.quantity := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.quantity := p_quantity;
         END IF;
         IF p_reserved_quantity= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.reserved_quantity := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.reserved_quantity := p_reserved_quantity;
         END IF;
         IF p_reservation_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.reservation_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.reservation_id := p_reservation_id;
         END IF;
         IF p_order_line_id= ROSETTA_G_MISS_NUM THEN
            l_shipment_rec.order_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_shipment_rec.order_line_id := p_order_line_id;
         END IF;
         l_shipment_rec.ship_to_party_name := p_ship_to_party_name;
         l_shipment_rec.ship_to_contact_first_name := p_ship_to_cont_fst_name;
         l_shipment_rec.ship_to_contact_middle_name := p_ship_to_cont_mid_name;
         l_shipment_rec.ship_to_contact_last_name := p_ship_to_cont_lst_name;
         l_shipment_rec.ship_to_address1 := p_ship_to_address1;
         l_shipment_rec.ship_to_address2 := p_ship_to_address2;
         l_shipment_rec.ship_to_address3 := p_ship_to_address3;
         l_shipment_rec.ship_to_address4 := p_ship_to_address4;
         l_shipment_rec.ship_to_country_code := p_ship_to_country_code;
         l_shipment_rec.ship_to_country := p_ship_to_country;
         l_shipment_rec.ship_to_city := p_ship_to_city;
         l_shipment_rec.ship_to_postal_code := p_ship_to_postal_code;
         l_shipment_rec.ship_to_state := p_ship_to_state;
         l_shipment_rec.ship_to_province := p_ship_to_province;
         l_shipment_rec.ship_to_county := p_ship_to_county;
         l_shipment_rec.attribute_category := p_attribute_category;
         l_shipment_rec.attribute1 := p_attribute1;
         l_shipment_rec.attribute2 := p_attribute2;
         l_shipment_rec.attribute3 := p_attribute3;
         l_shipment_rec.attribute4 := p_attribute4;
         l_shipment_rec.attribute5 := p_attribute5;
         l_shipment_rec.attribute6 := p_attribute6;
         l_shipment_rec.attribute7 := p_attribute7;
         l_shipment_rec.attribute8 := p_attribute8;
         l_shipment_rec.attribute9 := p_attribute9;
         l_shipment_rec.attribute10 := p_attribute10;
         l_shipment_rec.attribute11 := p_attribute11;
         l_shipment_rec.attribute12 := p_attribute12;
         l_shipment_rec.attribute13 := p_attribute13;
         l_shipment_rec.attribute14 := p_attribute14;
         l_shipment_rec.attribute15 := p_attribute15;
      RETURN l_shipment_rec;
END Construct_Shipment_Rec;


--

FUNCTION Construct_Shipment_Tbl(
   p_operation_code         IN jtf_varchar2_table_100   ,
   p_qte_line_index         IN jtf_number_table         ,
   p_shipment_id            IN jtf_number_table         ,
   p_creation_date          IN jtf_date_table           ,
   p_created_by             IN jtf_number_table         ,
   p_last_update_date       IN jtf_date_table           ,
   p_last_updated_by        IN jtf_number_table         ,
   p_last_update_login      IN jtf_number_table         ,
   p_request_id             IN jtf_number_table         ,
   p_program_application_id IN jtf_number_table         ,
   p_program_id             IN jtf_number_table         ,
   p_program_update_date    IN jtf_date_table           ,
   p_quote_header_id        IN jtf_number_table         ,
   p_quote_line_id          IN jtf_number_table         ,
   p_promise_date           IN jtf_date_table           ,
   p_request_date           IN jtf_date_table           ,
   p_schedule_ship_date     IN jtf_date_table           ,
   p_ship_to_party_site_id  IN jtf_number_table         ,
   p_ship_to_party_id       IN jtf_number_table         ,
   p_ship_to_cust_acct_id   IN jtf_number_table         ,
   p_ship_partial_flag      IN jtf_varchar2_table_300   ,
   p_ship_set_id            IN jtf_number_table         ,
   p_ship_method_code       IN jtf_varchar2_table_100   ,
   p_freight_terms_code     IN jtf_varchar2_table_100   ,
   p_freight_carrier_code   IN jtf_varchar2_table_100   ,
   p_fob_code               IN jtf_varchar2_table_100   ,
   p_shipment_priority_code IN jtf_varchar2_table_100   ,
   p_shipping_instructions  IN jtf_varchar2_table_2000  ,
   p_packing_instructions   IN jtf_varchar2_table_2000  ,
   p_quantity               IN jtf_number_table         ,
   p_reserved_quantity      IN jtf_number_table         ,
   p_reservation_id         IN jtf_number_table         ,
   p_order_line_id          IN jtf_number_table         ,
   p_ship_to_party_name     IN jtf_varchar2_table_300   ,
   p_ship_to_cont_fst_name  IN jtf_varchar2_table_100   ,
   p_ship_to_cont_mid_name  IN jtf_varchar2_table_100   ,
   p_ship_to_cont_lst_name  IN jtf_varchar2_table_100   ,
   p_ship_to_address1       IN jtf_varchar2_table_300   ,
   p_ship_to_address2       IN jtf_varchar2_table_300   ,
   p_ship_to_address3       IN jtf_varchar2_table_300   ,
   p_ship_to_address4       IN jtf_varchar2_table_300   ,
   p_ship_to_country_code   IN jtf_varchar2_table_100   ,
   p_ship_to_country        IN jtf_varchar2_table_100   ,
   p_ship_to_city           IN jtf_varchar2_table_100   ,
   p_ship_to_postal_code    IN jtf_varchar2_table_100   ,
   p_ship_to_state          IN jtf_varchar2_table_100   ,
   p_ship_to_province       IN jtf_varchar2_table_100   ,
   p_ship_to_county         IN jtf_varchar2_table_100   ,
   p_attribute_category     IN jtf_varchar2_table_100   ,
   p_attribute1             IN jtf_varchar2_table_200   ,
   p_attribute2             IN jtf_varchar2_table_200   ,
   p_attribute3             IN jtf_varchar2_table_200   ,
   p_attribute4             IN jtf_varchar2_table_200   ,
   p_attribute5             IN jtf_varchar2_table_200   ,
   p_attribute6             IN jtf_varchar2_table_200   ,
   p_attribute7             IN jtf_varchar2_table_200   ,
   p_attribute8             IN jtf_varchar2_table_200   ,
   p_attribute9             IN jtf_varchar2_table_200   ,
   p_attribute10            IN jtf_varchar2_table_200   ,
   p_attribute11            IN jtf_varchar2_table_200   ,
   p_attribute12            IN jtf_varchar2_table_200   ,
   p_attribute13            IN jtf_varchar2_table_200   ,
   p_attribute14            IN jtf_varchar2_table_200   ,
   p_attribute15            IN jtf_varchar2_table_200
)
RETURN ASO_Quote_Pub.Shipment_Tbl_Type
IS
   l_shipment_tbl ASO_Quote_Pub.Shipment_Tbl_Type;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN
   IF p_quote_header_id IS NOT NULL THEN
      l_table_size := p_quote_header_id.COUNT;
   END IF;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Rday to call CONSTRUCT_SHIPMENT_TBL ');
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP

         IF(p_operation_code is not null) THEN
            l_shipment_tbl(i).operation_code := p_operation_code(i);
         END IF;

         IF ((p_qte_line_index is not null ) and ((p_qte_line_index(i) is null) or (p_qte_line_index(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;

         IF ((p_shipment_id is not null ) and ((p_shipment_id(i) is null) or (p_shipment_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).shipment_id := p_shipment_id(i);
         END IF;

         IF ((p_creation_date is not null ) and ((p_creation_date(i) is null) or (p_creation_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_shipment_tbl(i).creation_date := p_creation_date(i);
         END IF;

         IF ((p_created_by is not null ) and ((p_created_by(i) is null) or (p_created_by(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).created_by := p_created_by(i);
         END IF;

         IF ((p_last_update_date is not null ) and ((p_last_update_date(i) is null) or (p_last_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_shipment_tbl(i).last_update_date := p_last_update_date(i);
         END IF;

         IF ((p_last_updated_by is not null ) and ((p_last_updated_by(i) is null) or (p_last_updated_by(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;

         IF ((p_last_update_login is not null ) and ((p_last_update_login(i) is null) or (p_last_update_login(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).last_update_login := p_last_update_login(i);
         END IF;

         IF ((p_request_id is not null ) and ((p_request_id(i) is null) or (p_request_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).request_id := p_request_id(i);
         END IF;

         IF ((p_program_application_id is not null ) and ((p_program_application_id(i) is null) or (p_program_application_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).program_application_id := p_program_application_id(i);
         END IF;

         IF ((p_program_id is not null ) and ((p_program_id(i) is null) or (p_program_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).program_id := p_program_id(i);
         END IF;

         IF ((p_program_update_date is not null ) and ((p_program_update_date(i) is null) or (p_program_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_shipment_tbl(i).program_update_date := p_program_update_date(i);
         END IF;

         IF ((p_quote_header_id is not null ) and ((p_quote_header_id(i) is null) or (p_quote_header_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;

         IF ((p_quote_line_id is not null ) and ((p_quote_line_id(i) is null) or (p_quote_line_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;

         IF ((p_promise_date is not null ) and ((p_promise_date(i) is null) or (p_promise_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_shipment_tbl(i).promise_date := p_promise_date(i);
         END IF;

         IF ((p_request_date is not null ) and ((p_request_date(i) is null) or (p_request_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_shipment_tbl(i).request_date := p_request_date(i);
         END IF;

         IF ((p_schedule_ship_date is not null ) and ((p_schedule_ship_date(i) is null) or (p_schedule_ship_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_shipment_tbl(i).schedule_ship_date := p_schedule_ship_date(i);
         END IF;

         IF ((p_ship_to_party_site_id is not null ) and ((p_ship_to_party_site_id(i) is null) or (p_ship_to_party_site_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).ship_to_party_site_id := p_ship_to_party_site_id(i);
         END IF;

         IF ((p_ship_to_party_id is not null ) and ((p_ship_to_party_id(i) is null) or (p_ship_to_party_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).ship_to_party_id := p_ship_to_party_id(i);
         END IF;

         IF ((p_ship_to_cust_acct_id is not null ) and ((p_ship_to_cust_acct_id(i) is null) or (p_ship_to_cust_acct_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).ship_to_cust_account_id := p_ship_to_cust_acct_id(i);
         END IF;

         IF(p_ship_partial_flag is not null) THEN
            l_shipment_tbl(i).ship_partial_flag := p_ship_partial_flag(i);
         END IF;

         IF ((p_ship_set_id is not null ) and ((p_ship_set_id(i) is null) or (p_ship_set_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).ship_set_id := p_ship_set_id(i);
         END IF;

         IF(p_ship_method_code is not null) THEN
            l_shipment_tbl(i).ship_method_code := p_ship_method_code(i);
         END IF;

         IF(p_freight_terms_code is not null) THEN
            l_shipment_tbl(i).freight_terms_code := p_freight_terms_code(i);
         END IF;

         IF(p_freight_carrier_code is not null) THEN    --p_freight_carrier_code
            l_shipment_tbl(i).freight_carrier_code := p_freight_carrier_code(i);
         END IF;

         IF(p_fob_code is not null) THEN
            l_shipment_tbl(i).fob_code := p_fob_code(i);
         END IF;

         IF(p_shipment_priority_code is not null) THEN
            l_shipment_tbl(i).shipment_priority_code := p_shipment_priority_code(i);
         END IF;

         IF(p_shipping_instructions is not null) THEN
            l_shipment_tbl(i).shipping_instructions := p_shipping_instructions(i);
         END IF;

         IF(p_packing_instructions is not null) THEN
            l_shipment_tbl(i).packing_instructions := p_packing_instructions(i);
         END IF;

         IF ((p_quantity is not null ) and ((p_quantity(i) is null) or (p_quantity(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).quantity := p_quantity(i);
         END IF;

         IF ((p_reserved_quantity is not null ) and ((p_reserved_quantity(i) is null) or (p_reserved_quantity(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).reserved_quantity := p_reserved_quantity(i);
         END IF;

         IF ((p_reservation_id is not null ) and ((p_reservation_id(i) is null) or (p_reservation_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).reservation_id := p_reservation_id(i);
         END IF;

         IF ((p_order_line_id is not null ) and ((p_order_line_id(i) is null) or (p_order_line_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_shipment_tbl(i).order_line_id := p_order_line_id(i);
         END IF;

         IF(p_ship_to_party_name is not null) THEN
            l_shipment_tbl(i).ship_to_party_name := p_ship_to_party_name(i);
         END IF;

         IF(p_ship_to_cont_fst_name is not null) THEN
            l_shipment_tbl(i).ship_to_contact_first_name := p_ship_to_cont_fst_name(i);
         END IF;

         IF(p_ship_to_cont_mid_name is not null) THEN
            l_shipment_tbl(i).ship_to_contact_middle_name := p_ship_to_cont_mid_name(i);
         END IF;

         IF(p_ship_to_cont_lst_name is not null) THEN
            l_shipment_tbl(i).ship_to_contact_last_name := p_ship_to_cont_lst_name(i);
         END IF;

         IF(p_ship_to_address1 is not null) THEN
            l_shipment_tbl(i).ship_to_address1 := p_ship_to_address1(i);
         END IF;

         IF(p_ship_to_address2 is not null) THEN
            l_shipment_tbl(i).ship_to_address2 := p_ship_to_address2(i);
         END IF;

         IF(p_ship_to_address3 is not null) THEN
            l_shipment_tbl(i).ship_to_address3 := p_ship_to_address3(i);
         END IF;

         IF(p_ship_to_address4 is not null) THEN
            l_shipment_tbl(i).ship_to_address4 := p_ship_to_address4(i);
         END IF;

         IF(p_ship_to_country_code is not null) THEN
            l_shipment_tbl(i).ship_to_country_code := p_ship_to_country_code(i);
         END IF;

         IF(p_ship_to_country is not null) THEN
            l_shipment_tbl(i).ship_to_country := p_ship_to_country(i);
         END IF;

         IF(p_ship_to_city is not null) THEN
            l_shipment_tbl(i).ship_to_city := p_ship_to_city(i);
         END IF;

         IF(p_ship_to_postal_code is not null) THEN
            l_shipment_tbl(i).ship_to_postal_code := p_ship_to_postal_code(i);
         END IF;

         IF(p_ship_to_state is not null) THEN
            l_shipment_tbl(i).ship_to_state := p_ship_to_state(i);
         END IF;

         IF(p_ship_to_province is not null) THEN
            l_shipment_tbl(i).ship_to_province := p_ship_to_province(i);
         END IF;

         IF(p_ship_to_county is not null) THEN
            l_shipment_tbl(i).ship_to_county := p_ship_to_county(i);
         END IF;

         IF(p_attribute_category is not null) THEN
            l_shipment_tbl(i).attribute_category := p_attribute_category(i);
         END IF;

         IF(p_attribute1 is not null) THEN
            l_shipment_tbl(i).attribute1 := p_attribute1(i);
         END IF;

         IF(p_attribute2 is not null) THEN
            l_shipment_tbl(i).attribute2 := p_attribute2(i);
         END IF;

         IF(p_attribute3 is not null) THEN
            l_shipment_tbl(i).attribute3 := p_attribute3(i);
         END IF;

         IF(p_attribute4 is not null) THEN
            l_shipment_tbl(i).attribute4 := p_attribute4(i);
         END IF;

         IF(p_attribute5 is not null) THEN
            l_shipment_tbl(i).attribute5 := p_attribute5(i);
         END IF;

         IF(p_attribute6 is not null) THEN
            l_shipment_tbl(i).attribute6 := p_attribute6(i);
         END IF;

         IF(p_attribute7 is not null) THEN
            l_shipment_tbl(i).attribute7 := p_attribute7(i);
         END IF;

         IF(p_attribute8 is not null) THEN
            l_shipment_tbl(i).attribute8 := p_attribute8(i);
         END IF;

         IF(p_attribute9 is not null) THEN
            l_shipment_tbl(i).attribute9 := p_attribute9(i);
         END IF;

         IF(p_attribute10 is not null) THEN
            l_shipment_tbl(i).attribute10 := p_attribute10(i);
         END IF;

         IF(p_attribute11 is not null) THEN
            l_shipment_tbl(i).attribute11 := p_attribute11(i);
         END IF;

         IF(p_attribute12 is not null) THEN
            l_shipment_tbl(i).attribute12 := p_attribute12(i);
         END IF;

         IF(p_attribute13 is not null) THEN
            l_shipment_tbl(i).attribute13 := p_attribute13(i);
         END IF;

         IF(p_attribute14 is not null) THEN
            l_shipment_tbl(i).attribute14 := p_attribute14(i);
         END IF;

         IF(p_attribute15 is not null) THEN
            l_shipment_tbl(i).attribute15 := p_attribute15(i);
         END IF;

      END LOOP;

      RETURN l_shipment_tbl;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Returning shipment table from CONSTRUCT_SHIPMENT_TBL');
     END IF;
   END IF;
END Construct_Shipment_Tbl;



FUNCTION Construct_Tax_Detail_Tbl(
   p_operation_code         IN jtf_varchar2_table_100  ,
   p_qte_line_index         IN jtf_number_table        ,
   p_shipment_index         IN jtf_number_table        ,
   p_tax_detail_id          IN jtf_number_table        ,
   p_quote_header_id        IN jtf_number_table        ,
   p_quote_line_id          IN jtf_number_table        ,
   p_quote_shipment_id      IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_updated_by        IN jtf_number_table        ,
   p_last_update_login      IN jtf_number_table        ,
   p_request_id             IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_orig_tax_code          IN jtf_varchar2_table_300  ,
   p_tax_code               IN jtf_varchar2_table_100  ,
   p_tax_rate               IN jtf_number_table        ,
   p_tax_date               IN jtf_date_table          ,
   p_tax_amount             IN jtf_number_table        ,
   p_tax_exempt_flag        IN jtf_varchar2_table_100  ,
   p_tax_exempt_number      IN jtf_varchar2_table_100  ,
   p_tax_exempt_reason_code IN jtf_varchar2_table_100  ,
   p_attribute_category     IN jtf_varchar2_table_100  ,
   p_attribute1             IN jtf_varchar2_table_200  ,
   p_attribute2             IN jtf_varchar2_table_200  ,
   p_attribute3             IN jtf_varchar2_table_200  ,
   p_attribute4             IN jtf_varchar2_table_200  ,
   p_attribute5             IN jtf_varchar2_table_200  ,
   p_attribute6             IN jtf_varchar2_table_200  ,
   p_attribute7             IN jtf_varchar2_table_200  ,
   p_attribute8             IN jtf_varchar2_table_200  ,
   p_attribute9             IN jtf_varchar2_table_200  ,
   p_attribute10            IN jtf_varchar2_table_200  ,
   p_attribute11            IN jtf_varchar2_table_200  ,
   p_attribute12            IN jtf_varchar2_table_200  ,
   p_attribute13            IN jtf_varchar2_table_200  ,
   p_attribute14            IN jtf_varchar2_table_200  ,
   p_attribute15            IN jtf_varchar2_table_200
)
RETURN ASO_Quote_Pub.Tax_Detail_Tbl_Type
IS
   l_tax_detail_tbl ASO_Quote_Pub.Tax_Detail_Tbl_Type;
   l_table_size     PLS_INTEGER := 0;
   i                PLS_INTEGER;
BEGIN
   IF p_quote_header_id IS NOT NULL THEN
      l_table_size := p_quote_header_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         IF(p_operation_code is not null) THEN
            l_tax_detail_tbl(i).operation_code := p_operation_code(i);
         END IF;

         IF ((p_qte_line_index is not null) and ((p_qte_line_index(i) is null) or (p_qte_line_index(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;

         IF ((p_shipment_index is not null) and ((p_shipment_index(i) is null) or (p_shipment_index(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).shipment_index := p_shipment_index(i);
         END IF;

         IF ((p_tax_detail_id is not null) and ((p_tax_detail_id(i) is null) or (p_tax_detail_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).tax_detail_id := p_tax_detail_id(i);
         END IF;

         IF ((p_quote_header_id is not null) and ((p_quote_header_id(i) is null) or (p_quote_header_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).quote_header_id := p_quote_header_id(i);
         END IF;

         IF ((p_quote_line_id is not null) and ((p_quote_line_id(i) is null) or (p_quote_line_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;

         IF ((p_quote_shipment_id is not null) and ((p_quote_shipment_id(i) is null) or (p_quote_shipment_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).quote_shipment_id := p_quote_shipment_id(i);
         END IF;

         IF ((p_creation_date is not null) and ((p_creation_date(i) is null) or (p_creation_date(i)  <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_tax_detail_tbl(i).creation_date := p_creation_date(i);
         END IF;

         IF ((p_created_by is not null) and ((p_created_by(i) is null) or (p_created_by(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).created_by := p_created_by(i);
         END IF;

         IF ((p_last_update_date is not null) and ((p_last_update_date(i) is null) or (p_last_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_tax_detail_tbl(i).last_update_date := p_last_update_date(i);
         END IF;

         IF ((p_last_updated_by is not null) and ((p_last_updated_by(i) is null) or (p_last_updated_by(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;

         IF ((p_last_update_login is not null) and ((p_last_update_login(i) is null) or (p_last_update_login(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).last_update_login := p_last_update_login(i);
         END IF;

         IF ((p_request_id is not null) and ((p_request_id(i) is null) or (p_request_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).request_id := p_request_id(i);
         END IF;

         IF ((p_program_application_id is not null) and ((p_program_application_id(i) is null) or (p_program_application_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).program_application_id := p_program_application_id(i);
         END IF;

         IF ((p_program_id is not null) and ((p_program_id(i) is null) or (p_program_id(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).program_id := p_program_id(i);
         END IF;

         IF ((p_program_update_date is not null) and ((p_program_update_date(i) is null) or (p_program_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_tax_detail_tbl(i).program_update_date := p_program_update_date(i);
         END IF;

         IF(p_orig_tax_code is not null) THEN
            l_tax_detail_tbl(i).orig_tax_code := p_orig_tax_code(i);
         END IF;

         IF(p_tax_code is not null) THEN
            l_tax_detail_tbl(i).tax_code := p_tax_code(i);
         END IF;

         IF ((p_tax_rate is not null) and ((p_tax_rate(i) is null) or (p_tax_rate(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).tax_rate := p_tax_rate(i);
         END IF;

         IF ((p_tax_date is not null) and ((p_tax_date(i) is null) or (p_tax_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_tax_detail_tbl(i).tax_date := p_tax_date(i);
         END IF;

         IF ((p_tax_amount is not null) and ((p_tax_amount(i) is null) or (p_tax_amount(i)  <> ROSETTA_G_MISS_NUM))) THEN
            l_tax_detail_tbl(i).tax_amount := p_tax_amount(i);
         END IF;

         IF(p_tax_exempt_flag is not null) THEN
            l_tax_detail_tbl(i).tax_exempt_flag := p_tax_exempt_flag(i);
         END IF;

         IF(p_tax_exempt_number is not null) THEN
            l_tax_detail_tbl(i).tax_exempt_number := p_tax_exempt_number(i);
         END IF;

         IF(p_tax_exempt_reason_code is not null) THEN
            l_tax_detail_tbl(i).tax_exempt_reason_code := p_tax_exempt_reason_code(i);
         END IF;

         IF(p_attribute_category is not null) THEN
            l_tax_detail_tbl(i).attribute_category := p_attribute_category(i);
         END IF;

         IF(p_attribute1 is not null) THEN
            l_tax_detail_tbl(i).attribute1 := p_attribute1(i);
         END IF;

         IF(p_attribute2 is not null) THEN
            l_tax_detail_tbl(i).attribute2 := p_attribute2(i);
         END IF;

         IF(p_attribute3 is not null) THEN
            l_tax_detail_tbl(i).attribute3 := p_attribute3(i);
         END IF;

         IF(p_attribute4 is not null) THEN
            l_tax_detail_tbl(i).attribute4 := p_attribute4(i);
         END IF;

         IF(p_attribute5 is not null) THEN
            l_tax_detail_tbl(i).attribute5 := p_attribute5(i);
         END IF;

         IF(p_attribute6 is not null) THEN
            l_tax_detail_tbl(i).attribute6 := p_attribute6(i);
         END IF;

         IF(p_attribute7 is not null) THEN
            l_tax_detail_tbl(i).attribute7 := p_attribute7(i);
         END IF;

         IF(p_attribute8 is not null) THEN
            l_tax_detail_tbl(i).attribute8 := p_attribute8(i);
         END IF;

         IF(p_attribute9 is not null) THEN
            l_tax_detail_tbl(i).attribute9 := p_attribute9(i);
         END IF;

         IF(p_attribute10 is not null) THEN
            l_tax_detail_tbl(i).attribute10 := p_attribute10(i);
         END IF;

         IF(p_attribute11 is not null) THEN
            l_tax_detail_tbl(i).attribute11 := p_attribute11(i);
         END IF;

         IF(p_attribute12 is not null) THEN
            l_tax_detail_tbl(i).attribute12 := p_attribute12(i);
         END IF;

         IF(p_attribute13 is not null) THEN
            l_tax_detail_tbl(i).attribute13 := p_attribute13(i);
         END IF;

         IF(p_attribute14 is not null) THEN
            l_tax_detail_tbl(i).attribute14 := p_attribute14(i);
         END IF;

         IF(p_attribute15 is not null) THEN
            l_tax_detail_tbl(i).attribute15 := p_attribute15(i);
         END IF;

        END LOOP;

      RETURN l_tax_detail_tbl;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.Debug('Returning tax details table from CONSTRUCT_TAX_DETAIL_TBL');
      END IF;
   END IF;
END Construct_Tax_Detail_Tbl;


-- there IS total 99 fields here IN header
FUNCTION Construct_Qte_Header_Rec(
   p_quote_header_id            IN NUMBER    ,
   p_creation_date              IN DATE      ,
   p_created_by                 IN NUMBER    ,
   p_last_updated_by            IN NUMBER    ,
   p_last_update_date           IN DATE      ,
   p_last_update_login          IN NUMBER    ,
   p_request_id                 IN NUMBER    ,
   p_program_application_id     IN NUMBER    ,
   p_program_id                 IN NUMBER    ,
   p_program_update_date        IN DATE      ,
   p_org_id                     IN NUMBER    ,
   p_quote_name                 IN VARCHAR2  ,
   p_quote_number               IN NUMBER    ,
   p_quote_version              IN NUMBER    ,
   p_quote_status_id            IN NUMBER    ,
   p_quote_source_code          IN VARCHAR2  ,
   p_quote_expiration_date      IN DATE      ,
   p_price_frozen_date          IN DATE      ,
   p_quote_password             IN VARCHAR2  ,
   p_original_system_reference  IN VARCHAR2  ,
   p_party_id                   IN NUMBER    ,
   p_cust_account_id            IN NUMBER    ,
   p_invoice_to_cust_account_id IN NUMBER    ,
   p_org_contact_id             IN NUMBER    ,
   p_party_name                 IN VARCHAR2  ,
   p_party_type                 IN VARCHAR2  ,
   p_person_first_name          IN VARCHAR2  ,
   p_person_last_name           IN VARCHAR2  ,
   p_person_middle_name         IN VARCHAR2  ,
   p_phone_id                   IN NUMBER    ,
   p_price_list_id              IN NUMBER    ,
   p_price_list_name            IN VARCHAR2  ,
   p_currency_code              IN VARCHAR2  ,
   p_total_list_price           IN NUMBER    ,
   p_total_adjusted_amount      IN NUMBER    ,
   p_total_adjusted_percent     IN NUMBER    ,
   p_total_tax                  IN NUMBER    ,
   p_total_shipping_charge      IN NUMBER    ,
   p_surcharge                  IN NUMBER    ,
   p_total_quote_price          IN NUMBER    ,
   p_payment_amount             IN NUMBER    ,
   p_accounting_rule_id         IN NUMBER    ,
   p_exchange_rate              IN NUMBER    ,
   p_exchange_type_code         IN VARCHAR2  ,
   p_exchange_rate_date         IN DATE      ,
   p_quote_category_code        IN VARCHAR2  ,
   p_quote_status_code          IN VARCHAR2  ,
   p_quote_status               IN VARCHAR2  ,
   p_employee_person_id         IN NUMBER    ,
   p_sales_channel_code         IN VARCHAR2  ,
--   p_salesrep_full_name         IN VARCHAR2  ,
   p_attribute_category         IN VARCHAR2  ,
-- added attribute 16-20 for bug 6873117 mgiridha
   p_attribute1                 IN VARCHAR2  ,
   p_attribute10                IN VARCHAR2  ,
   p_attribute11                IN VARCHAR2  ,
   p_attribute12                IN VARCHAR2  ,
   p_attribute13                IN VARCHAR2  ,
   p_attribute14                IN VARCHAR2  ,
   p_attribute15                IN VARCHAR2  ,
   p_attribute16                IN VARCHAR2  ,
   p_attribute17                IN VARCHAR2  ,
   p_attribute18                IN VARCHAR2  ,
   p_attribute19                IN VARCHAR2  ,
   p_attribute2                 IN VARCHAR2  ,
   p_attribute20                IN VARCHAR2  ,
   p_attribute3                 IN VARCHAR2  ,
   p_attribute4                 IN VARCHAR2  ,
   p_attribute5                 IN VARCHAR2  ,
   p_attribute6                 IN VARCHAR2  ,
   p_attribute7                 IN VARCHAR2  ,
   p_attribute8                 IN VARCHAR2  ,
   p_attribute9                 IN VARCHAR2  ,
   p_contract_id                IN NUMBER    ,
   p_qte_contract_id            IN NUMBER    ,
   p_ffm_request_id             IN NUMBER    ,
   p_invoice_to_address1        IN VARCHAR2  ,
   p_invoice_to_address2        IN VARCHAR2  ,
   p_invoice_to_address3        IN VARCHAR2  ,
   p_invoice_to_address4        IN VARCHAR2  ,
   p_invoice_to_city            IN VARCHAR2  ,
   p_invoice_to_cont_first_name IN VARCHAR2  ,
   p_invoice_to_cont_last_name  IN VARCHAR2  ,
   p_invoice_to_cont_mid_name   IN VARCHAR2  ,
   p_invoice_to_country_code    IN VARCHAR2  ,
   p_invoice_to_country         IN VARCHAR2  ,
   p_invoice_to_county          IN VARCHAR2  ,
   p_invoice_to_party_id        IN NUMBER    ,
   p_invoice_to_party_name      IN VARCHAR2  ,
   p_invoice_to_party_site_id   IN NUMBER    ,
   p_invoice_to_postal_code     IN VARCHAR2  ,
   p_invoice_to_province        IN VARCHAR2  ,
   p_invoice_to_state           IN VARCHAR2  ,
   p_invoicing_rule_id          IN NUMBER    ,
   p_marketing_source_code_id   IN NUMBER    ,
   p_marketing_source_code      IN VARCHAR2  ,
   p_marketing_source_name      IN VARCHAR2  ,
   p_orig_mktg_source_code_id   IN NUMBER    ,
   p_order_type_id              IN NUMBER    ,
   p_order_id                   IN NUMBER    ,
   p_order_number               IN NUMBER    ,
   p_order_type_name            IN VARCHAR2  ,
   p_ordered_date               IN DATE      ,
   p_resource_id                IN NUMBER    ,
   p_end_customer_party_id      IN NUMBER    ,
   p_end_customer_cust_party_id IN NUMBER    ,
   p_end_customer_party_site_id IN NUMBER    ,
   p_end_customer_cust_account_id IN NUMBER	 ,
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
-- added attribute 16-20 for bug 6873117 mgiridha
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
   IF p_end_customer_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_party_id := p_end_customer_party_id;
   END IF;
   IF p_end_customer_cust_party_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_cust_party_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_cust_party_id := p_end_customer_cust_party_id;
   END IF;
   IF p_end_customer_party_site_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_party_site_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_party_site_id := p_end_customer_party_site_id;
   END IF;
   IF p_end_customer_cust_account_id = ROSETTA_G_MISS_NUM THEN
      l_qte_header.end_customer_cust_account_id := FND_API.G_MISS_NUM;
   ELSE
      l_qte_header.end_customer_cust_account_id := p_end_customer_cust_account_id;
   END IF;
   l_qte_header.pricing_status_indicator := p_pricing_status_indicator;
   l_qte_header.tax_status_indicator := p_tax_status_indicator;
   RETURN l_qte_header;
END Construct_Qte_Header_Rec;


FUNCTION Construct_Qte_Line_Tbl(
   p_creation_date            IN jtf_date_table          ,
   p_created_by               IN jtf_number_table        ,
   p_last_updated_by          IN jtf_number_table        ,
   p_last_update_date         IN jtf_date_table          ,
   p_last_update_login        IN jtf_number_table        ,
   p_request_id               IN jtf_number_table        ,
   p_program_application_id   IN jtf_number_table        ,
   p_program_id               IN jtf_number_table        ,
   p_program_update_date      IN jtf_date_table          ,
   p_quote_line_id            IN jtf_number_table        ,
   p_quote_header_id          IN jtf_number_table        ,
   p_org_id                   IN jtf_number_table        ,
   p_line_number              IN jtf_number_table        ,
   p_line_category_code       IN jtf_varchar2_table_100  ,
   p_item_type_code           IN jtf_varchar2_table_100  ,
   p_inventory_item_id        IN jtf_number_table        ,
   p_organization_id          IN jtf_number_table        ,
   p_quantity                 IN jtf_number_table        ,
   p_uom_code                 IN jtf_varchar2_table_100  ,

   p_ordered_item_id_tbl 		  IN jtf_number_table        ,
   p_ordered_item_tbl        IN jtf_varchar2_table_100  ,
	 p_item_ident_type_tbl      IN jtf_varchar2_table_100  ,

   p_start_date_active        IN jtf_date_table          ,
   p_end_date_active          IN jtf_date_table          ,
   p_order_line_type_id       IN jtf_number_table        ,
   p_price_list_id            IN jtf_number_table        ,
   p_price_list_line_id       IN jtf_number_table        ,
   p_currency_code            IN jtf_varchar2_table_100  ,
   p_line_list_price          IN jtf_number_table        ,
   p_line_adjusted_amount     IN jtf_number_table        ,
   p_line_adjusted_percent    IN jtf_number_table        ,
   p_line_quote_price         IN jtf_number_table        ,
   p_related_item_id          IN jtf_number_table        ,
   p_item_relationship_type   IN jtf_varchar2_table_100  ,
   p_split_shipment_flag      IN jtf_varchar2_table_100  ,
   p_backorder_flag           IN jtf_varchar2_table_100  ,
   p_selling_price_change     IN jtf_varchar2_table_100  ,
   p_recalculate_flag         IN jtf_varchar2_table_100  ,
   p_attribute_category       IN jtf_varchar2_table_100  ,
   p_attribute1               IN jtf_varchar2_table_300  ,
   p_attribute2               IN jtf_varchar2_table_300  ,
   p_attribute3               IN jtf_varchar2_table_300  ,
   p_attribute4               IN jtf_varchar2_table_300  ,
   p_attribute5               IN jtf_varchar2_table_300  ,
   p_attribute6               IN jtf_varchar2_table_300  ,
   p_attribute7               IN jtf_varchar2_table_300  ,
   p_attribute8               IN jtf_varchar2_table_300  ,
   p_attribute9               IN jtf_varchar2_table_300  ,
   p_attribute10              IN jtf_varchar2_table_300  ,
   p_attribute11              IN jtf_varchar2_table_300  ,
   p_attribute12              IN jtf_varchar2_table_300  ,
   p_attribute13              IN jtf_varchar2_table_300  ,
   p_attribute14              IN jtf_varchar2_table_300  ,
   p_attribute15              IN jtf_varchar2_table_300  ,
   --modified for bug 18525045 - start
   p_attribute16              IN jtf_varchar2_table_300  ,
   p_attribute17              IN jtf_varchar2_table_300  ,
   p_attribute18              IN jtf_varchar2_table_300  ,
   p_attribute19              IN jtf_varchar2_table_300  ,
   p_attribute20              IN jtf_varchar2_table_300  ,
   --modified for bug 18525045 - end
   p_accounting_rule_id       IN jtf_number_table        ,
   p_ffm_content_name         IN jtf_varchar2_table_300  ,
   p_ffm_content_type         IN jtf_varchar2_table_300  ,
   p_ffm_document_type        IN jtf_varchar2_table_300  ,
   p_ffm_media_id             IN jtf_varchar2_table_300  ,
   p_ffm_media_type           IN jtf_varchar2_table_300  ,
   p_ffm_user_note            IN jtf_varchar2_table_300  ,
   p_invoice_to_party_id      IN jtf_number_table        ,
   p_invoice_to_party_site_id IN jtf_number_table        ,
   p_invoice_to_cust_acct_id  IN jtf_number_table        ,
   p_invoicing_rule_id        IN jtf_number_table        ,
   p_marketing_source_code_id IN jtf_number_table        ,
   p_commitment_id            IN jtf_number_table        ,
   p_agreement_id             IN jtf_number_table        ,
   p_minisite_id              IN jtf_number_table        ,
   p_section_id               IN jtf_number_table        ,
   p_operation_code           IN jtf_varchar2_table_100  ,
   p_end_customer_party_id        IN jtf_number_table    ,
   p_end_customer_cust_party_id   IN jtf_number_table    ,
   p_end_customer_party_site_id   IN jtf_number_table    ,
   p_end_customer_cust_account_id IN jtf_number_table
)
RETURN ASO_Quote_Pub.Qte_Line_Tbl_Type
IS
   l_qte_line_tbl ASO_Quote_Pub.Qte_Line_Tbl_Type;
   l_table_size   PLS_INTEGER := 0;
   i              PLS_INTEGER;
BEGIN
--To determine the table size
--quote_header_id array is choosen because it will definitely be passed by the mid tier
IF p_quote_header_id IS NOT NULL THEN
  l_table_size := p_quote_header_id.COUNT;
END IF;
   --All incoming arrays have the same table size, so use the same length for all of them
   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         --if the incoming column array(p_incoming_date) is not empty and if the data is not g_miss type then
         --assign the value to a local table_type variable.
         --Same strategy to be followed for all incoming column arrays
        IF ((p_creation_date is not null ) and ((p_creation_date(i) is null) or (p_creation_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
           l_qte_line_tbl(i).creation_date := p_creation_date(i);
        END IF;

        IF ((p_created_by is not null) and ((p_created_by(i) is null) or (p_created_by(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).created_by := p_created_by(i);
        END IF;

        IF ((p_last_updated_by is not null) and ((p_last_updated_by(i) is null) or  (p_last_updated_by(i)<> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).last_updated_by := p_last_updated_by(i);
        END IF;

        IF ((p_last_update_date is not null) and ((p_last_update_date(i) is null) or  (p_last_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
           l_qte_line_tbl(i).last_update_date := p_last_update_date(i);
        END IF;

        IF ((p_last_update_login is not null) and ((p_last_update_login(i) is null) or (p_last_update_login(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).last_update_login := p_last_update_login(i);
        END IF;

        IF ((p_request_id is not null) and ((p_request_id(i) is null) or (p_request_id(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).request_id := p_request_id(i);
        END IF;

        IF ((p_program_application_id is not null) and ((p_program_application_id(i) is null) or (p_program_application_id(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).program_application_id := p_program_application_id(i);
        END IF;

        IF ((p_program_id is not null) and ((p_program_id(i) is null) or (p_program_id(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).program_id := p_program_id(i);
        END IF;

        IF ((p_program_update_date is not null) and ((p_program_update_date(i) is null) or  (p_program_update_date(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
           l_qte_line_tbl(i).program_update_date := p_program_update_date(i);
        END IF;

        IF ((p_quote_line_id is not null) and ((p_quote_line_id(i) is null) or (p_quote_line_id(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).quote_line_id := p_quote_line_id(i);
        END IF;

        IF ((p_quote_header_id is not null) and ((p_quote_header_id(i) is null) or (p_quote_header_id(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).quote_header_id := p_quote_header_id(i);
        END IF;

        IF ((p_org_id is not null) and ((p_org_id(i) is null) or (p_org_id(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).org_id := p_org_id(i);
        END IF;

        IF ((p_line_number is not null) and ((p_line_number(i) is null) or (p_line_number(i) <> ROSETTA_G_MISS_NUM))) THEN
           l_qte_line_tbl(i).line_number := p_line_number(i);
        END IF;

        IF (p_line_category_code is not null) THEN
            l_qte_line_tbl(i).line_category_code := p_line_category_code(i);
        END IF;

        IF (p_item_type_code is not null) THEN
            l_qte_line_tbl(i).item_type_code := p_item_type_code(i);
        END IF;

        IF ((p_inventory_item_id is not null) and ((p_inventory_item_id(i) is null) or (p_inventory_item_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).inventory_item_id := p_inventory_item_id(i);
        END IF;

        IF ((p_organization_id is not null) and ((p_organization_id(i) is null) or (p_organization_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).organization_id := p_organization_id(i);
        END IF;

        IF ((p_quantity is not null) and ((p_quantity(i) is null) or (p_quantity(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).quantity := p_quantity(i);
        END IF;

        IF(p_uom_code is not null) THEN
            l_qte_line_tbl(i).uom_code := p_uom_code(i);
        END IF;

        --Bug 2641510  & 25-Jun-2013  amaheshw bug# 16993086
         IF ((p_ordered_item_id_tbl is not null) and ((p_ordered_item_id_tbl(i) is null) or (p_ordered_item_id_tbl(i) <> FND_API.G_MISS_NUM))) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Construct_Qte_Line_Tbl::: p_ordered_item_id_tbl(' || i || '):  ' ||  p_ordered_item_id_tbl(i));
        End IF;
            l_qte_line_tbl(i).ORDERED_ITEM_ID := p_ordered_item_id_tbl(i);
        END IF;

        IF ((p_ordered_item_tbl is not null) and ((p_ordered_item_tbl(i) is null) or (p_ordered_item_tbl(i) <> FND_API.G_MISS_CHAR))) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Construct_Qte_Line_Tbl::: p_ordered_item_tbl(' || i || '):  ' ||  p_ordered_item_tbl(i));
        End IF;
            l_qte_line_tbl(i).ORDERED_ITEM := p_ordered_item_tbl(i);
        END IF;

       IF ((p_item_ident_type_tbl is not null) and ((p_item_ident_type_tbl(i) is null) or (p_item_ident_type_tbl(i) <> FND_API.G_MISS_CHAR))) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('Construct_Qte_Line_Tbl::: p_item_ident_type_tbl(' || i || ') : ' ||  p_item_ident_type_tbl(i));
        End IF;
            l_qte_line_tbl(i).ITEM_IDENTIFIER_TYPE := p_item_ident_type_tbl(i);
        END IF;

        IF ((p_start_date_active is not null) and ((p_start_date_active(i) is null) or (p_start_date_active(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_qte_line_tbl(i).start_date_active := p_start_date_active(i);
        END IF;

        IF ((p_end_date_active is not null) and ((p_end_date_active(i) is null) or (p_end_date_active(i) <> ROSETTA_G_MISTAKE_DATE))) THEN
            l_qte_line_tbl(i).end_date_active := p_end_date_active(i);
        END IF;

        IF ((p_order_line_type_id is not null) and ((p_order_line_type_id(i) is null) or (p_order_line_type_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).order_line_type_id := p_order_line_type_id(i);
        END IF;

        IF ((p_price_list_id is not null) and ((p_price_list_id(i) is null) or  (p_price_list_id(i)<> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).price_list_id := p_price_list_id(i);
        END IF;

        IF ((p_price_list_line_id is not null) and ((p_price_list_line_id(i) is null) or (p_price_list_line_id(i) <> ROSETTA_G_MISS_NUM ))) THEN
            l_qte_line_tbl(i).price_list_line_id := p_price_list_line_id(i);
        END IF;

        --No g_miss check necessary for arrays of char datatype
        IF (p_currency_code is not null) THEN
            l_qte_line_tbl(i).currency_code := p_currency_code(i);
        END IF;

        IF ((p_line_list_price is not null) and ((p_line_list_price(i) is null) or (p_line_list_price(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).line_list_price := p_line_list_price(i);
        END IF;

        IF ((p_line_adjusted_amount is not null) and ((p_line_adjusted_amount(i) is null) or (p_line_adjusted_amount(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).line_adjusted_amount := p_line_adjusted_amount(i);
        END IF;

        IF ((p_line_adjusted_percent is not null) and ((p_line_adjusted_percent(i) is null) or (p_line_adjusted_percent(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).line_adjusted_percent := p_line_adjusted_percent(i);
        END IF;

        IF ((p_line_quote_price is not null) and ((p_line_quote_price(i) is null) or (p_line_quote_price(i) <> ROSETTA_G_MISS_NUM ))) THEN
            l_qte_line_tbl(i).line_quote_price := p_line_quote_price(i);
        END IF;

        IF ((p_related_item_id is not null) and ((p_related_item_id(i) is null) or (p_related_item_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).related_item_id := p_related_item_id(i);
        END IF;

        IF (p_item_relationship_type is not null) THEN
            l_qte_line_tbl(i).item_relationship_type := p_item_relationship_type(i);
        END IF;

        IF(p_split_shipment_flag is not null) THEN
            l_qte_line_tbl(i).split_shipment_flag := p_split_shipment_flag(i);
        END IF;

        IF(p_backorder_flag is not null) THEN
            l_qte_line_tbl(i).backorder_flag := p_backorder_flag(i);
        END IF;

        IF(p_selling_price_change is not null) THEN
            l_qte_line_tbl(i).selling_price_change := p_selling_price_change(i);
        END IF;

        IF(p_recalculate_flag is not null) THEN
            l_qte_line_tbl(i).recalculate_flag := p_recalculate_flag(i);
        END IF;

        IF(p_attribute_category is not null) THEN
            l_qte_line_tbl(i).attribute_category := p_attribute_category(i);
        END IF;


        IF(p_attribute1 is not null) THEN
            l_qte_line_tbl(i).attribute1 := p_attribute1(i);
        END IF;

        IF(p_attribute2 is not null) THEN
            l_qte_line_tbl(i).attribute2 := p_attribute2(i);
        END IF;

        IF(p_attribute3 is not null) THEN
            l_qte_line_tbl(i).attribute3 := p_attribute3(i);
        END IF;

        IF(p_attribute4 is not null) THEN
            l_qte_line_tbl(i).attribute4 := p_attribute4(i);
        END IF;

        IF(p_attribute5 is not null) THEN
            l_qte_line_tbl(i).attribute5 := p_attribute5(i);
        END IF;

        IF(p_attribute6 is not null) THEN
            l_qte_line_tbl(i).attribute6 := p_attribute6(i);
        END IF;

        IF(p_attribute7 is not null) THEN
            l_qte_line_tbl(i).attribute7 := p_attribute7(i);
        END IF;

        IF(p_attribute8 is not null) THEN
            l_qte_line_tbl(i).attribute8 := p_attribute8(i);
        END IF;

        IF(p_attribute9 is not null) THEN
            l_qte_line_tbl(i).attribute9 := p_attribute9(i);
        END IF;

        IF(p_attribute10 is not null) THEN
            l_qte_line_tbl(i).attribute10 := p_attribute10(i);
        END IF;

        IF(p_attribute11 is not null) THEN
            l_qte_line_tbl(i).attribute11 := p_attribute11(i);
        END IF;

        IF(p_attribute12 is not null) THEN
            l_qte_line_tbl(i).attribute12 := p_attribute12(i);
        END IF;

        IF(p_attribute13 is not null) THEN
            l_qte_line_tbl(i).attribute13 := p_attribute13(i);
        END IF;

        IF(p_attribute14 is not null) THEN
            l_qte_line_tbl(i).attribute14 := p_attribute14(i);
        END IF;

        IF(p_attribute15 is not null) THEN
            l_qte_line_tbl(i).attribute15 := p_attribute15(i);
        END IF;
        --modified for bug 18525045 - start
          IF(p_attribute16 is not null) THEN
            l_qte_line_tbl(i).attribute16 := p_attribute16(i);
          END IF;
          IF(p_attribute17 is not null) THEN
           l_qte_line_tbl(i).attribute17 := p_attribute17(i);
          END IF;
          IF(p_attribute18 is not null) THEN
            l_qte_line_tbl(i).attribute18 := p_attribute18(i);
          END IF;
          IF(p_attribute19 is not null) THEN
            l_qte_line_tbl(i).attribute19 := p_attribute19(i);
         END IF;
         IF(p_attribute20 is not null) THEN
            l_qte_line_tbl(i).attribute20 := p_attribute20(i);
          END IF;
        --modified for bug 18525045 - end

        IF ((p_accounting_rule_id is not null) and ((p_accounting_rule_id(i) is null) or (p_accounting_rule_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).accounting_rule_id := p_accounting_rule_id(i);
        END IF;

        IF(p_ffm_content_name is not null) THEN
            l_qte_line_tbl(i).ffm_content_name := p_ffm_content_name(i);
        END IF;

        IF(p_ffm_content_type is not null) THEN
            l_qte_line_tbl(i).ffm_content_type := p_ffm_content_type(i);
        END IF;

        IF(p_ffm_document_type is not null) THEN
            l_qte_line_tbl(i).ffm_document_type := p_ffm_document_type(i);
        END IF;

        IF(p_ffm_media_id is not null) THEN
            l_qte_line_tbl(i).ffm_media_id := p_ffm_media_id(i);
        END IF;

        IF(p_ffm_media_type is not null) THEN
            l_qte_line_tbl(i).ffm_media_type := p_ffm_media_type(i);
        END IF;

        IF(p_ffm_user_note is not null) THEN
            l_qte_line_tbl(i).ffm_user_note := p_ffm_user_note(i);
        END IF;

        IF((p_invoice_to_party_id is not null) and ((p_invoice_to_party_id(i) is null) or (p_invoice_to_party_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).invoice_to_party_id := p_invoice_to_party_id(i);
        END IF;

        IF ((p_invoice_to_party_site_id is not null) and ((p_invoice_to_party_site_id(i) is null) or (p_invoice_to_party_site_id(i) <> ROSETTA_G_MISS_NUM ))) THEN
            l_qte_line_tbl(i).invoice_to_party_site_id := p_invoice_to_party_site_id(i);
        END IF;

        IF ((p_invoice_to_cust_acct_id is not null) and ((p_invoice_to_cust_acct_id(i) is null) or (p_invoice_to_cust_acct_id(i) <> ROSETTA_G_MISS_NUM ))) THEN
            l_qte_line_tbl(i).invoice_to_cust_account_id := p_invoice_to_cust_acct_id(i);
        END IF;

        IF ((p_invoicing_rule_id is not null) and ((p_invoicing_rule_id(i) is null) or (p_invoicing_rule_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).invoicing_rule_id := p_invoicing_rule_id(i);
        END IF;

        IF ((p_marketing_source_code_id is not null) and ((p_marketing_source_code_id(i) is null) or (p_marketing_source_code_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).marketing_source_code_id := p_marketing_source_code_id(i);
        END IF;

        IF ((p_commitment_id is not null) and ((p_commitment_id(i) is null) or (p_commitment_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).commitment_id := p_commitment_id(i);
        END IF;

        IF ((p_agreement_id is not null) and ((p_agreement_id(i) is null) or (p_agreement_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).agreement_id := p_agreement_id(i);
        END IF;

        IF ((p_minisite_id is not null) and ((p_minisite_id(i) is null) or (p_minisite_id(i)<> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).minisite_id := p_minisite_id(i);
        END IF;

        IF ((p_section_id is not null) and ((p_section_id(i) is null) or (p_section_id(i)<> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).section_id := p_section_id(i);
        END IF;

        IF (p_operation_code is not null) THEN
           l_qte_line_tbl(i).operation_code := p_operation_code(i);
         END IF;

        IF ((p_end_customer_party_id is not null) and ((p_end_customer_party_id(i) is null) or (p_end_customer_party_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).end_customer_party_id:= p_end_customer_party_id (i);
        END IF;
        IF ((p_end_customer_cust_party_id is not null) and ((p_end_customer_cust_party_id(i) is null) or (p_end_customer_cust_party_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).end_customer_cust_party_id := p_end_customer_cust_party_id(i);
        END IF;
        IF ((p_end_customer_party_site_id is not null) and ((p_end_customer_party_site_id(i) is null) or (p_end_customer_party_site_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).end_customer_party_site_id := p_end_customer_party_site_id(i);
        END IF;
        IF ((p_end_customer_cust_account_id is not null) and ((p_end_customer_cust_account_id(i) is null) or (p_end_customer_cust_account_id(i) <> ROSETTA_G_MISS_NUM))) THEN
            l_qte_line_tbl(i).end_customer_cust_account_id := p_end_customer_cust_account_id(i);
        END IF;

      END LOOP; --end of loop around the column arrays

      RETURN l_qte_line_tbl;
   ELSE
      RETURN ASO_Quote_Pub.G_MISS_QTE_LINE_TBL; --empty qte_line arrays passed in
   END IF; --end if for l_table_size>0
END Construct_Qte_Line_Tbl;


FUNCTION Construct_Qte_Line_Dtl_Tbl(
   p_quote_line_detail_id     IN jtf_number_table         ,
   p_creation_date            IN jtf_date_table           ,
   p_created_by               IN jtf_number_table         ,
   p_last_update_date         IN jtf_date_table           ,
   p_last_updated_by          IN jtf_number_table         ,
   p_last_update_login        IN jtf_number_table         ,
   p_request_id               IN jtf_number_table         ,
   p_program_application_id   IN jtf_number_table         ,
   p_program_id               IN jtf_number_table         ,
   p_program_update_date      IN jtf_date_table           ,
   p_quote_line_id            IN jtf_number_table         ,
   p_config_header_id         IN jtf_number_table         ,
   p_config_revision_num      IN jtf_number_table         ,
   p_config_item_id           IN jtf_number_table         ,
   p_complete_configuration   IN jtf_varchar2_table_100   ,
   p_valid_configuration_flag IN jtf_varchar2_table_100   ,
   p_component_code           IN jtf_varchar2_table_1000  ,
   p_service_coterminate_flag IN jtf_varchar2_table_100   ,
   p_service_duration         IN jtf_number_table         ,
   p_service_period           IN jtf_varchar2_table_100   ,
   p_service_unit_selling     IN jtf_number_table         ,
   p_service_unit_list        IN jtf_number_table         ,
   p_service_number           IN jtf_number_table         ,
   p_unit_percent_base_price  IN jtf_number_table         ,
   p_attribute_category       IN jtf_varchar2_table_100   ,
   p_attribute1               IN jtf_varchar2_table_200   ,
   p_attribute2               IN jtf_varchar2_table_200   ,
   p_attribute3               IN jtf_varchar2_table_200   ,
   p_attribute4               IN jtf_varchar2_table_200   ,
   p_attribute5               IN jtf_varchar2_table_200   ,
   p_attribute6               IN jtf_varchar2_table_200   ,
   p_attribute7               IN jtf_varchar2_table_200   ,
   p_attribute8               IN jtf_varchar2_table_200   ,
   p_attribute9               IN jtf_varchar2_table_200   ,
   p_attribute10              IN jtf_varchar2_table_200   ,
   p_attribute11              IN jtf_varchar2_table_200   ,
   p_attribute12              IN jtf_varchar2_table_200   ,
   p_attribute13              IN jtf_varchar2_table_200   ,
   p_attribute14              IN jtf_varchar2_table_200   ,
   p_attribute15              IN jtf_varchar2_table_200   ,
   p_service_ref_type_code    IN jtf_varchar2_table_100   ,
   p_service_ref_order_number IN jtf_number_table         ,
   p_service_ref_line_number  IN jtf_number_table         ,
   p_service_ref_qte_line_ind IN jtf_number_table         ,
   p_service_ref_line_id      IN jtf_number_table         ,
   p_service_ref_system_id    IN jtf_number_table         ,
   p_service_ref_option_numb  IN jtf_number_table         ,
   p_service_ref_shipment     IN jtf_number_table         ,
   p_return_ref_type          IN jtf_varchar2_table_100   ,
   p_return_ref_header_id     IN jtf_number_table         ,
   p_return_ref_line_id       IN jtf_number_table         ,
   p_return_attribute1        IN jtf_varchar2_table_300   ,
   p_return_attribute2        IN jtf_varchar2_table_300   ,
   p_return_attribute3        IN jtf_varchar2_table_300   ,
   p_return_attribute4        IN jtf_varchar2_table_300   ,
   p_return_attribute5        IN jtf_varchar2_table_300   ,
   p_return_attribute6        IN jtf_varchar2_table_300   ,
   p_return_attribute7        IN jtf_varchar2_table_300   ,
   p_return_attribute8        IN jtf_varchar2_table_300   ,
   p_return_attribute9        IN jtf_varchar2_table_300   ,
   p_return_attribute10       IN jtf_varchar2_table_300   ,
   p_return_attribute11       IN jtf_varchar2_table_300   ,
   p_return_attribute12       IN jtf_varchar2_table_300   ,
   p_return_attribute13       IN jtf_varchar2_table_300   ,
   p_return_attribute14       IN jtf_varchar2_table_300   ,
   p_return_attribute15       IN jtf_varchar2_table_300   ,
   p_operation_code           IN jtf_varchar2_table_100   ,
   p_qte_line_index           IN jtf_number_table         ,
   p_return_attr_category     IN jtf_varchar2_table_100   ,
   p_return_reason_code       IN jtf_varchar2_table_100
)
RETURN ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type
IS
   l_qte_line_dtl_tbl ASO_Quote_Pub.Qte_Line_Dtl_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;
BEGIN
   IF p_quote_line_detail_id IS NOT NULL THEN
      l_table_size := p_quote_line_detail_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         IF p_quote_line_detail_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).quote_line_detail_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).quote_line_detail_id := p_quote_line_detail_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_qte_line_dtl_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_qte_line_dtl_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_config_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).config_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).config_header_id := p_config_header_id(i);
         END IF;
         IF p_config_revision_num(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).config_revision_num := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).config_revision_num := p_config_revision_num(i);
         END IF;
         IF p_config_item_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).config_item_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).config_item_id := p_config_item_id(i);
         END IF;
         l_qte_line_dtl_tbl(i).complete_configuration_flag := p_complete_configuration(i);
         l_qte_line_dtl_tbl(i).valid_configuration_flag := p_valid_configuration_flag(i);
         l_qte_line_dtl_tbl(i).component_code := p_component_code(i);
         l_qte_line_dtl_tbl(i).service_coterminate_flag := p_service_coterminate_flag(i);
         IF p_service_duration(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_duration := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_duration := p_service_duration(i);
         END IF;
         l_qte_line_dtl_tbl(i).service_period := p_service_period(i);
         IF p_service_unit_selling(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_unit_selling_percent := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_unit_selling_percent := p_service_unit_selling(i);
         END IF;
         IF p_service_unit_list(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_unit_list_percent := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_unit_list_percent := p_service_unit_list(i);
         END IF;
         IF p_service_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_number := p_service_number(i);
         END IF;
         IF p_unit_percent_base_price(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).unit_percent_base_price := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).unit_percent_base_price := p_unit_percent_base_price(i);
         END IF;
         l_qte_line_dtl_tbl(i).attribute_category := p_attribute_category(i);
         l_qte_line_dtl_tbl(i).attribute1 := p_attribute1(i);
         l_qte_line_dtl_tbl(i).attribute2 := p_attribute2(i);
         l_qte_line_dtl_tbl(i).attribute3 := p_attribute3(i);
         l_qte_line_dtl_tbl(i).attribute4 := p_attribute4(i);
         l_qte_line_dtl_tbl(i).attribute5 := p_attribute5(i);
         l_qte_line_dtl_tbl(i).attribute6 := p_attribute6(i);
         l_qte_line_dtl_tbl(i).attribute7 := p_attribute7(i);
         l_qte_line_dtl_tbl(i).attribute8 := p_attribute8(i);
         l_qte_line_dtl_tbl(i).attribute9 := p_attribute9(i);
         l_qte_line_dtl_tbl(i).attribute10 := p_attribute10(i);
         l_qte_line_dtl_tbl(i).attribute11 := p_attribute11(i);
         l_qte_line_dtl_tbl(i).attribute12 := p_attribute12(i);
         l_qte_line_dtl_tbl(i).attribute13 := p_attribute13(i);
         l_qte_line_dtl_tbl(i).attribute14 := p_attribute14(i);
         l_qte_line_dtl_tbl(i).attribute15 := p_attribute15(i);
         l_qte_line_dtl_tbl(i).service_ref_type_code := p_service_ref_type_code(i);
         IF p_service_ref_order_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_order_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_order_number := p_service_ref_order_number(i);
         END IF;
         IF p_service_ref_line_number(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_line_number := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_line_number := p_service_ref_line_number(i);
         END IF;
         IF p_service_ref_qte_line_ind(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_qte_line_index := p_service_ref_qte_line_ind(i);
         END IF;
         IF p_service_ref_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_line_id := p_service_ref_line_id(i);
         END IF;
         IF p_service_ref_system_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_system_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_system_id := p_service_ref_system_id(i);
         END IF;
         IF p_service_ref_option_numb(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_option_numb := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_option_numb := p_service_ref_option_numb(i);
         END IF;
         IF p_service_ref_shipment(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).service_ref_shipment_numb := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).service_ref_shipment_numb := p_service_ref_shipment(i);
         END IF;
         l_qte_line_dtl_tbl(i).return_ref_type := p_return_ref_type(i);
         IF p_return_ref_header_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).return_ref_header_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).return_ref_header_id := p_return_ref_header_id(i);
         END IF;
         IF p_return_ref_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).return_ref_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).return_ref_line_id := p_return_ref_line_id(i);
         END IF;
         l_qte_line_dtl_tbl(i).return_attribute1 := p_return_attribute1(i);
         l_qte_line_dtl_tbl(i).return_attribute2 := p_return_attribute2(i);
         l_qte_line_dtl_tbl(i).return_attribute3 := p_return_attribute3(i);
         l_qte_line_dtl_tbl(i).return_attribute4 := p_return_attribute4(i);
         l_qte_line_dtl_tbl(i).return_attribute5 := p_return_attribute5(i);
         l_qte_line_dtl_tbl(i).return_attribute6 := p_return_attribute6(i);
         l_qte_line_dtl_tbl(i).return_attribute7 := p_return_attribute7(i);
         l_qte_line_dtl_tbl(i).return_attribute8 := p_return_attribute8(i);
         l_qte_line_dtl_tbl(i).return_attribute9 := p_return_attribute9(i);
         l_qte_line_dtl_tbl(i).return_attribute10 := p_return_attribute10(i);
         l_qte_line_dtl_tbl(i).return_attribute11 := p_return_attribute11(i);
         l_qte_line_dtl_tbl(i).return_attribute12 := p_return_attribute12(i);
         l_qte_line_dtl_tbl(i).return_attribute13 := p_return_attribute13(i);
         l_qte_line_dtl_tbl(i).return_attribute14 := p_return_attribute14(i);
         l_qte_line_dtl_tbl(i).return_attribute15 := p_return_attribute15(i);
         l_qte_line_dtl_tbl(i).operation_code := p_operation_code(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_qte_line_dtl_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_qte_line_dtl_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         l_qte_line_dtl_tbl(i).return_attribute_category := p_return_attr_category(i);
         l_qte_line_dtl_tbl(i).return_reason_code := p_return_reason_code(i);
      END LOOP;

      RETURN l_qte_line_dtl_tbl;
   END IF;
END Construct_Qte_Line_Dtl_Tbl;


FUNCTION Construct_Line_Rltship_Tbl(
   p_line_relationship_id   IN jtf_number_table        ,
   p_creation_date          IN jtf_date_table          ,
   p_created_by             IN jtf_number_table        ,
   p_last_updated_by        IN jtf_number_table        ,
   p_last_update_date       IN jtf_date_table          ,
   p_last_update_login      IN jtf_number_table        ,
   p_request_id             IN jtf_number_table        ,
   p_program_application_id IN jtf_number_table        ,
   p_program_id             IN jtf_number_table        ,
   p_program_update_date    IN jtf_date_table          ,
   p_quote_line_id          IN jtf_number_table        ,
   p_related_quote_line_id  IN jtf_number_table        ,
   p_relationship_type_code IN jtf_varchar2_table_100  ,
   p_reciprocal_flag        IN jtf_varchar2_table_100  ,
   p_qte_line_index         IN jtf_number_table        ,
   p_related_qte_line_index IN jtf_number_table        ,
   p_operation_code         IN jtf_varchar2_table_100
)
RETURN ASO_Quote_Pub.Line_Rltship_Tbl_Type
IS
   l_line_rltship_tbl ASO_Quote_Pub.Line_Rltship_Tbl_Type;
   l_table_size       PLS_INTEGER := 0;
   i                  PLS_INTEGER;

BEGIN
   IF p_line_relationship_id IS NOT NULL THEN
      l_table_size := p_line_relationship_id.COUNT;
   END IF;

   IF l_table_size > 0 THEN
      FOR i IN 1..l_table_size LOOP
         IF p_line_relationship_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).line_relationship_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).line_relationship_id := p_line_relationship_id(i);
         END IF;
         IF p_creation_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_rltship_tbl(i).creation_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_rltship_tbl(i).creation_date := p_creation_date(i);
         END IF;
         IF p_created_by(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).created_by := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).created_by := p_created_by(i);
         END IF;
         IF p_last_updated_by(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).last_updated_by := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).last_updated_by := p_last_updated_by(i);
         END IF;
         IF p_last_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_rltship_tbl(i).last_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_rltship_tbl(i).last_update_date := p_last_update_date(i);
         END IF;
         IF p_last_update_login(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).last_update_login := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).last_update_login := p_last_update_login(i);
         END IF;
         IF p_request_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).request_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).request_id := p_request_id(i);
         END IF;
         IF p_program_application_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).program_application_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).program_application_id := p_program_application_id(i);
         END IF;
         IF p_program_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).program_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).program_id := p_program_id(i);
         END IF;
         IF p_program_update_date(i)= ROSETTA_G_MISTAKE_DATE THEN
            l_line_rltship_tbl(i).program_update_date := FND_API.G_MISS_DATE;
         ELSE
            l_line_rltship_tbl(i).program_update_date := p_program_update_date(i);
         END IF;
         IF p_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).quote_line_id := p_quote_line_id(i);
         END IF;
         IF p_related_quote_line_id(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).related_quote_line_id := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).related_quote_line_id := p_related_quote_line_id(i);
         END IF;
         l_line_rltship_tbl(i).relationship_type_code := p_relationship_type_code(i);
         l_line_rltship_tbl(i).reciprocal_flag := p_reciprocal_flag(i);
         IF p_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).qte_line_index := p_qte_line_index(i);
         END IF;
         IF p_related_qte_line_index(i)= ROSETTA_G_MISS_NUM THEN
            l_line_rltship_tbl(i).related_qte_line_index := FND_API.G_MISS_NUM;
         ELSE
            l_line_rltship_tbl(i).related_qte_line_index := p_related_qte_line_index(i);
         END IF;
         l_line_rltship_tbl(i).operation_code := p_operation_code(i);
      END LOOP;

      RETURN l_line_rltship_tbl;
   END IF;
END Construct_Line_Rltship_Tbl;


PROCEDURE SaveWrapper(
   p_api_version_number           IN  NUMBER   := 1                 ,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE    ,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE   ,
   x_return_status                OUT NOCOPY VARCHAR2                      ,
   x_msg_count                    OUT NOCOPY NUMBER                        ,
   x_msg_data                     OUT NOCOPY VARCHAR2                      ,
   x_quote_header_id              OUT NOCOPY NUMBER                        ,
   x_last_update_date             OUT NOCOPY DATE                          ,
   p_auto_update_active_quote     IN  VARCHAR2 := FND_API.G_TRUE    ,
   p_combinesameitem              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sharee_number                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_sharee_party_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_sharee_cust_account_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_c_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode		  IN  VARCHAR2 := 'ENTIRE_QUOTE'     ,  -- change line logic pricing
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
   p_q_save_type                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_minisite_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_party_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_cust_party_id     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_party_site_id     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_cust_account_id   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_pricing_status_indicator   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_tax_status_indicator   	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ql_creation_date            IN jtf_date_table         := NULL,
   p_ql_created_by               IN jtf_number_table       := NULL,
   p_ql_last_updated_by          IN jtf_number_table       := NULL,
   p_ql_last_update_date         IN jtf_date_table         := NULL,
   p_ql_last_update_login        IN jtf_number_table       := NULL,
   p_ql_request_id               IN jtf_number_table       := NULL,
   p_ql_program_application_id   IN jtf_number_table       := NULL,
   p_ql_program_id               IN jtf_number_table       := NULL,
   p_ql_program_update_date      IN jtf_date_table         := NULL,
   p_ql_quote_line_id            IN jtf_number_table       := NULL,
   p_ql_quote_header_id          IN jtf_number_table       := NULL,
   p_ql_org_id                   IN jtf_number_table       := NULL,
   p_ql_line_number              IN jtf_number_table       := NULL,
   p_ql_line_category_code       IN jtf_varchar2_table_100 := NULL,
   p_ql_item_type_code           IN jtf_varchar2_table_100 := NULL,
   p_ql_inventory_item_id        IN jtf_number_table       := NULL,
   p_ql_organization_id          IN jtf_number_table       := NULL,
   p_ql_quantity                 IN jtf_number_table       := NULL,
   p_ql_uom_code                 IN jtf_varchar2_table_100 := NULL,

   p_ql_cust_part_number                 IN jtf_varchar2_table_100 := NULL,
   p_ql_cross_ref_type                 IN jtf_varchar2_table_100 := NULL,
   p_ql_cross_ref_number                 IN jtf_varchar2_table_100 := NULL,

   p_ql_start_date_active        IN jtf_date_table         := NULL,
   p_ql_end_date_active          IN jtf_date_table         := NULL,
   p_ql_order_line_type_id       IN jtf_number_table       := NULL,
   p_ql_price_list_id            IN jtf_number_table       := NULL,
   p_ql_price_list_line_id       IN jtf_number_table       := NULL,
   p_ql_currency_code            IN jtf_varchar2_table_100 := NULL,
   p_ql_line_list_price          IN jtf_number_table       := NULL,
   p_ql_line_adjusted_amount     IN jtf_number_table       := NULL,
   p_ql_line_adjusted_percent    IN jtf_number_table       := NULL,
   p_ql_line_quote_price         IN jtf_number_table       := NULL,
   p_ql_related_item_id          IN jtf_number_table       := NULL,
   p_ql_item_relationship_type   IN jtf_varchar2_table_100 := NULL,
   p_ql_split_shipment_flag      IN jtf_varchar2_table_100 := NULL,
   p_ql_backorder_flag           IN jtf_varchar2_table_100 := NULL,
   p_ql_selling_price_change     IN jtf_varchar2_table_100 := NULL,
   p_ql_recalculate_flag         IN jtf_varchar2_table_100 := NULL,
   p_ql_attribute_category       IN jtf_varchar2_table_100 := NULL,
   p_ql_attribute1               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute2               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute3               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute4               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute5               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute6               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute7               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute8               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute9               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute10              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute11              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute12              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute13              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute14              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute15              IN jtf_varchar2_table_300 := NULL,
   --modified for bug 18525045 - start
  p_ql_attribute16              IN jtf_varchar2_table_300 := NULL,
  p_ql_attribute17              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute18              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute19              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute20              IN jtf_varchar2_table_300 := NULL,
   --modified for bug 18525045 - end
   p_ql_accounting_rule_id       IN jtf_number_table       := NULL,
   p_ql_ffm_content_name         IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_content_type         IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_document_type        IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_media_id             IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_media_type           IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_user_note            IN jtf_varchar2_table_300 := NULL,
   p_ql_invoice_to_party_id      IN jtf_number_table       := NULL,
   p_ql_invoice_to_party_site_id IN jtf_number_table       := NULL,
   p_ql_invoice_to_cust_acct_id  IN jtf_number_table       := NULL,
   p_ql_invoicing_rule_id        IN jtf_number_table       := NULL,
   p_ql_marketing_source_code_id IN jtf_number_table       := NULL,
   p_ql_operation_code           IN jtf_varchar2_table_100 := NULL,
   p_ql_commitment_id            IN jtf_number_table       := NULL,
   p_ql_agreement_id             IN jtf_number_table       := NULL,
   p_ql_minisite_id              IN jtf_number_table       := NULL,
   p_ql_section_id               IN jtf_number_table       := NULL,
   p_ql_line_codes               IN jtf_number_table       := NULL,
   p_ql_end_cust_party_id        IN jtf_number_table       := NULL,
   p_ql_end_cust_cust_party_id   IN jtf_number_table       := NULL,
   p_ql_end_cust_party_site_id   IN jtf_number_table       := NULL,
   p_ql_end_cust_cust_account_id IN jtf_number_table       := NULL,
   p_qrl_line_relationship_id     IN  jtf_number_table := NULL,
   p_qrl_creation_date            IN  jtf_date_table   := NULL,
   p_qrl_created_by               IN  jtf_number_table := NULL,
   p_qrl_last_updated_by          IN  jtf_number_table := NULL,
   p_qrl_last_update_date         IN  jtf_date_table   := NULL,
   p_qrl_last_update_login        IN  jtf_number_table := NULL,
   p_qrl_request_id               IN  jtf_number_table := NULL,
   p_qrl_program_application_id   IN  jtf_number_table := NULL,
   p_qrl_program_id               IN  jtf_number_table := NULL,
   p_qrl_program_update_date      IN  jtf_date_table   := NULL,
   p_qrl_quote_line_id            IN  jtf_number_table := NULL,
   p_qrl_related_quote_line_id    IN  jtf_number_table := NULL,
   p_qrl_relationship_type_code   IN  jtf_varchar2_table_100 := NULL,
   p_qrl_reciprocal_flag          IN  jtf_varchar2_table_100 := NULL,
   p_qrl_qte_line_index           IN  jtf_number_table := NULL,
   p_qrl_related_qte_line_index   IN  jtf_number_table := NULL,
   p_qrl_operation_code           IN  JTF_VARCHAR2_TABLE_100 := null,
   p_qdl_quote_line_detail_id     IN jtf_number_table        := NULL,
   p_qdl_creation_date            IN jtf_date_table          := NULL,
   p_qdl_created_by               IN jtf_number_table        := NULL,
   p_qdl_last_update_date         IN jtf_date_table          := NULL,
   p_qdl_last_updated_by          IN jtf_number_table        := NULL,
   p_qdl_last_update_login        IN jtf_number_table        := NULL,
   p_qdl_request_id               IN jtf_number_table        := NULL,
   p_qdl_program_application_id   IN jtf_number_table        := NULL,
   p_qdl_program_id               IN jtf_number_table        := NULL,
   p_qdl_program_update_date      IN jtf_date_table          := NULL,
   p_qdl_quote_line_id            IN jtf_number_table        := NULL,
   p_qdl_config_header_id         IN jtf_number_table        := NULL,
   p_qdl_config_revision_num      IN jtf_number_table        := NULL,
   p_qdl_config_item_id           IN jtf_number_table        := NULL,
   p_qdl_complete_configuration   IN jtf_varchar2_table_100  := NULL,
   p_qdl_valid_configuration_flag IN jtf_varchar2_table_100  := NULL,
   p_qdl_component_code           IN jtf_varchar2_table_1000 := NULL,
   p_qdl_service_coterminate_flag IN jtf_varchar2_table_100  := NULL,
   p_qdl_service_duration         IN jtf_number_table        := NULL,
   p_qdl_service_period           IN jtf_varchar2_table_100  := NULL,
   p_qdl_service_unit_selling     IN jtf_number_table        := NULL,
   p_qdl_service_unit_list        IN jtf_number_table        := NULL,
   p_qdl_service_number           IN jtf_number_table        := NULL,
   p_qdl_unit_percent_base_price  IN jtf_number_table        := NULL,
   p_qdl_attribute_category       IN jtf_varchar2_table_100  := NULL,
   p_qdl_attribute1               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute2               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute3               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute4               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute5               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute6               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute7               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute8               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute9               IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute10              IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute11              IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute12              IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute13              IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute14              IN jtf_varchar2_table_200  := NULL,
   p_qdl_attribute15              IN jtf_varchar2_table_200  := NULL,
   p_qdl_service_ref_type_code    IN jtf_varchar2_table_100  := NULL,
   p_qdl_service_ref_order_number IN jtf_number_table        := NULL,
   p_qdl_service_ref_line_number  IN jtf_number_table        := NULL,
   p_qdl_service_ref_qte_line_ind IN jtf_number_table        := NULL,
   p_qdl_service_ref_line_id      IN jtf_number_table        := NULL,
   p_qdl_service_ref_system_id    IN jtf_number_table        := NULL,
   p_qdl_service_ref_option_numb  IN jtf_number_table        := NULL,
   p_qdl_service_ref_shipment     IN jtf_number_table        := NULL,
   p_qdl_return_ref_type          IN jtf_varchar2_table_100  := NULL,
   p_qdl_return_ref_header_id     IN jtf_number_table        := NULL,
   p_qdl_return_ref_line_id       IN jtf_number_table        := NULL,
   p_qdl_return_attribute1        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute2        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute3        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute4        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute5        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute6        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute7        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute8        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute9        IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute10       IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute11       IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute12       IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute13       IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute14       IN jtf_varchar2_table_300  := NULL,
   p_qdl_return_attribute15       IN jtf_varchar2_table_300  := NULL,
   p_qdl_operation_code           IN jtf_varchar2_table_100  := NULL,
   p_qdl_qte_line_index           IN jtf_number_table        := NULL,
   p_qdl_return_attr_category     IN jtf_varchar2_table_100  := NULL,
   p_qdl_return_reason_code       IN jtf_varchar2_table_100  := NULL,
   p_qpa_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qpa_qte_line_index         IN jtf_number_table       := NULL,
   p_qpa_price_attribute_id     IN jtf_number_table       := NULL,
   p_qpa_creation_date          IN jtf_date_table         := NULL,
   p_qpa_created_by             IN jtf_number_table       := NULL,
   p_qpa_last_update_date       IN jtf_date_table         := NULL,
   p_qpa_last_updated_by        IN jtf_number_table       := NULL,
   p_qpa_last_update_login      IN jtf_number_table       := NULL,
   p_qpa_request_id             IN jtf_number_table       := NULL,
   p_qpa_program_application_id IN jtf_number_table       := NULL,
   p_qpa_program_id             IN jtf_number_table       := NULL,
   p_qpa_program_update_date    IN jtf_date_table         := NULL,
   p_qpa_quote_header_id        IN jtf_number_table       := NULL,
   p_qpa_quote_line_id          IN jtf_number_table       := NULL,
   p_qpa_flex_title             IN jtf_varchar2_table_100 := NULL,
   p_qpa_pricing_context        IN jtf_varchar2_table_100 := NULL,
   p_qpa_pricing_attribute1     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute2     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute3     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute4     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute5     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute6     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute7     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute8     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute9     IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute10    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute11    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute12    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute13    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute14    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute15    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute16    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute17    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute18    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute19    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute20    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute21    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute22    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute23    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute24    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute25    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute26    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute27    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute28    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute29    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute30    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute31    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute32    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute33    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute34    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute35    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute36    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute37    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute38    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute39    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute40    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute41    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute42    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute43    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute44    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute45    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute46    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute47    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute48    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute49    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute50    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute51    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute52    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute53    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute54    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute55    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute56    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute57    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute58    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute59    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute60    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute61    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute62    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute63    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute64    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute65    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute66    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute67    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute68    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute69    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute70    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute71    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute72    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute73    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute74    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute75    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute76    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute77    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute78    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute79    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute80    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute81    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute82    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute83    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute84    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute85    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute86    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute87    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute88    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute89    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute90    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute91    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute92    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute93    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute94    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute95    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute96    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute97    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute98    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute99    IN jtf_varchar2_table_300 := NULL,
   p_qpa_pricing_attribute100   IN jtf_varchar2_table_300 := NULL,
   p_qpa_context                IN jtf_varchar2_table_100 := NULL,
   p_qpa_attribute1             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute2             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute3             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute4             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute5             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute6             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute7             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute8             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute9             IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute10            IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute11            IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute12            IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute13            IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute14            IN jtf_varchar2_table_300 := NULL,
   p_qpa_attribute15            IN jtf_varchar2_table_300 := NULL,
   p_qp_operation_code            IN  jtf_varchar2_table_100 := NULL,
   p_qp_qte_line_index            IN  jtf_number_table := NULL,
   p_qp_payment_id                IN  jtf_number_table := NULL,
   p_qp_creation_date             IN  jtf_date_table   := NULL,
   p_qp_created_by                IN  jtf_number_table := NULL,
   p_qp_last_update_date          IN  jtf_date_table   := NULL,
   p_qp_last_updated_by           IN  jtf_number_table := NULL,
   p_qp_last_update_login         IN  jtf_number_table := NULL,
   p_qp_request_id                IN  jtf_number_table := NULL,
   p_qp_program_application_id    IN  jtf_number_table := NULL,
   p_qp_program_id                IN  jtf_number_table := NULL,
   p_qp_program_update_date       IN  jtf_date_table   := NULL,
   p_qp_quote_header_id           IN  jtf_number_table := NULL,
   p_qp_quote_line_id             IN  jtf_number_table := NULL,
   p_qp_payment_type_code         IN  jtf_varchar2_table_100 := NULL,
   p_qp_payment_ref_number        IN  jtf_varchar2_table_300 := NULL,
   p_qp_payment_option            IN  jtf_varchar2_table_300 := NULL,
   p_qp_payment_term_id           IN  jtf_number_table := NULL,
   p_qp_credit_card_code          IN  jtf_varchar2_table_100 := NULL,
   p_qp_credit_card_holder_name   IN  jtf_varchar2_table_100 := NULL,
   p_qp_credit_card_exp_date      IN  jtf_date_table   := NULL,
   p_qp_credit_card_approval_code IN  jtf_varchar2_table_100 := NULL,
   p_qp_credit_card_approval_date IN  jtf_date_table   := NULL,
   p_qp_payment_amount            IN  jtf_number_table := NULL,
   p_qp_cust_po_number            IN  jtf_varchar2_table_100 := NULL,
   p_qp_attribute_category        IN  jtf_varchar2_table_100 := NULL,
   p_qp_attribute1                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute2                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute3                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute4                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute5                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute6                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute7                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute8                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute9                IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute10               IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute11               IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute12               IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute13               IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute14               IN  jtf_varchar2_table_200 := NULL,
   p_qp_attribute15               IN  jtf_varchar2_table_200 := NULL,
   p_qp_assignment_id             IN  jtf_number_table := NULL,
   p_qp_cvv2                      IN  jtf_varchar2_table_200 := NULL,
   p_qs_operation_code         IN jtf_varchar2_table_100  := NULL,
   p_qs_qte_line_index         IN jtf_number_table        := NULL,
   p_qs_shipment_id            IN jtf_number_table        := NULL,
   p_qs_creation_date          IN jtf_date_table          := NULL,
   p_qs_created_by             IN jtf_number_table        := NULL,
   p_qs_last_update_date       IN jtf_date_table          := NULL,
   p_qs_last_updated_by        IN jtf_number_table        := NULL,
   p_qs_last_update_login      IN jtf_number_table        := NULL,
   p_qs_request_id             IN jtf_number_table        := NULL,
   p_qs_program_application_id IN jtf_number_table        := NULL,
   p_qs_program_id             IN jtf_number_table        := NULL,
   p_qs_program_update_date    IN jtf_date_table          := NULL,
   p_qs_quote_header_id        IN jtf_number_table        := NULL,
   p_qs_quote_line_id          IN jtf_number_table        := NULL,
   p_qs_promise_date           IN jtf_date_table          := NULL,
   p_qs_request_date           IN jtf_date_table          := NULL,
   p_qs_schedule_ship_date     IN jtf_date_table          := NULL,
   p_qs_ship_to_party_site_id  IN jtf_number_table        := NULL,
   p_qs_ship_to_party_id       IN jtf_number_table        := NULL,
   p_qs_ship_to_cust_acct_id   IN jtf_number_table        := NULL,
   p_qs_ship_partial_flag      IN jtf_varchar2_table_300  := NULL,
   p_qs_ship_set_id            IN jtf_number_table        := NULL,
   p_qs_ship_method_code       IN jtf_varchar2_table_100  := NULL,
   p_qs_freight_terms_code     IN jtf_varchar2_table_100  := NULL,
   p_qs_freight_carrier_code   IN jtf_varchar2_table_100  := NULL,
   p_qs_fob_code               IN jtf_varchar2_table_100  := NULL,
   p_qs_shipment_priority_code IN jtf_varchar2_table_100  := NULL,
   p_qs_shipping_instructions  IN jtf_varchar2_table_2000 := NULL,
   p_qs_packing_instructions   IN jtf_varchar2_table_2000 := NULL,
   p_qs_quantity               IN jtf_number_table        := NULL,
   p_qs_reserved_quantity      IN jtf_number_table        := NULL,
   p_qs_reservation_id         IN jtf_number_table        := NULL,
   p_qs_order_line_id          IN jtf_number_table        := NULL,
   p_qs_ship_to_party_name     IN jtf_varchar2_table_300  := NULL,
   p_qs_ship_to_cont_fst_name  IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_cont_mid_name  IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_cont_lst_name  IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_address1       IN jtf_varchar2_table_300  := NULL,
   p_qs_ship_to_address2       IN jtf_varchar2_table_300  := NULL,
   p_qs_ship_to_address3       IN jtf_varchar2_table_300  := NULL,
   p_qs_ship_to_address4       IN jtf_varchar2_table_300  := NULL,
   p_qs_ship_to_country_code   IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_country        IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_city           IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_postal_code    IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_state          IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_province       IN jtf_varchar2_table_100  := NULL,
   p_qs_ship_to_county         IN jtf_varchar2_table_100  := NULL,
   p_qs_attribute_category     IN jtf_varchar2_table_100  := NULL,
   p_qs_attribute1             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute2             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute3             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute4             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute5             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute6             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute7             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute8             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute9             IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute10            IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute11            IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute12            IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute13            IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute14            IN jtf_varchar2_table_200  := NULL,
   p_qs_attribute15            IN jtf_varchar2_table_200  := NULL,
   p_qt_operation_code            IN  jtf_varchar2_table_100 := NULL,
   p_qt_qte_line_index            IN  jtf_number_table := NULL,
   p_qt_shipment_index            IN  jtf_number_table := NULL,
   p_qt_tax_detail_id             IN  jtf_number_table := NULL,
   p_qt_quote_header_id           IN  jtf_number_table := NULL,
   p_qt_quote_line_id             IN  jtf_number_table := NULL,
   p_qt_quote_shipment_id         IN  jtf_number_table := NULL,
   p_qt_creation_date             IN  jtf_date_table   := NULL,
   p_qt_created_by                IN  jtf_number_table := NULL,
   p_qt_last_update_date          IN  jtf_date_table   := NULL,
   p_qt_last_updated_by           IN  jtf_number_table := NULL,
   p_qt_last_update_login         IN  jtf_number_table := NULL,
   p_qt_request_id                IN  jtf_number_table := NULL,
   p_qt_program_application_id    IN  jtf_number_table := NULL,
   p_qt_program_id                IN  jtf_number_table := NULL,
   p_qt_program_update_date       IN  jtf_date_table   := NULL,
   p_qt_orig_tax_code             IN  jtf_varchar2_table_300 := NULL,
   p_qt_tax_code                  IN  jtf_varchar2_table_100 := NULL,
   p_qt_tax_rate                  IN  jtf_number_table := NULL,
   p_qt_tax_date                  IN  jtf_date_table   := NULL,
   p_qt_tax_amount                IN  jtf_number_table := NULL,
   p_qt_tax_exempt_flag           IN  jtf_varchar2_table_100 := NULL,
   p_qt_tax_exempt_number         IN  jtf_varchar2_table_100 := NULL,
   p_qt_tax_exempt_reason_code    IN  jtf_varchar2_table_100 := NULL,
   p_qt_attribute_category        IN  jtf_varchar2_table_100 := NULL,
   p_qt_attribute1                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute2                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute3                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute4                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute5                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute6                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute7                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute8                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute9                IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute10               IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute11               IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute12               IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute13               IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute14               IN  jtf_varchar2_table_200 := NULL,
   p_qt_attribute15               IN  jtf_varchar2_table_200 := NULL,
   p_qlpa_operation_code          IN  jtf_varchar2_table_100 := NULL,
   p_qlpa_qte_line_index          IN  jtf_number_table := NULL,
   p_qlpa_price_attribute_id      IN  jtf_number_table := NULL,
   p_qlpa_creation_date           IN  jtf_date_table   := NULL,
   p_qlpa_created_by              IN  jtf_number_table := NULL,
   p_qlpa_last_update_date        IN  jtf_date_table   := NULL,
   p_qlpa_last_updated_by         IN  jtf_number_table := NULL,
   p_qlpa_last_update_login       IN  jtf_number_table := NULL,
   p_qlpa_request_id              IN  jtf_number_table := NULL,
   p_qlpa_program_application_id  IN  jtf_number_table := NULL,
   p_qlpa_program_id              IN  jtf_number_table := NULL,
   p_qlpa_program_update_date     IN  jtf_date_table   := NULL,
   p_qlpa_quote_header_id         IN  jtf_number_table := NULL,
   p_qlpa_quote_line_id           IN  jtf_number_table := NULL,
   p_qlpa_flex_title              IN  jtf_varchar2_table_100 := NULL,
   p_qlpa_pricing_context         IN  jtf_varchar2_table_100 := NULL,
   p_qlpa_pricing_attribute1      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute2      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute3      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute4      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute5      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute6      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute7      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute8      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute9      IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute10     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute11     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute12     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute13     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute14     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute15     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute16     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute17     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute18     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute19     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute20     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute21     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute22     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute23     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute24     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute25     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute26     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute27     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute28     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute29     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute30     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute31     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute32     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute33     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute34     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute35     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute36     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute37     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute38     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute39     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute40     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute41     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute42     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute43     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute44     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute45     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute46     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute47     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute48     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute49     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute50     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute51     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute52     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute53     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute54     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute55     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute56     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute57     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute58     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute59     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute60     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute61     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute62     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute63     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute64     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute65     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute66     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute67     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute68     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute69     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute70     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute71     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute72     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute73     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute74     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute75     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute76     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute77     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute78     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute79     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute80     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute81     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute82     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute83     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute84     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute85     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute86     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute87     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute88     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute89     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute90     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute91     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute92     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute93     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute94     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute95     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute96     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute97     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute98     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute99     IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_pricing_attribute100    IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_context                 IN  jtf_varchar2_table_100 := NULL,
   p_qlpa_attribute1              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute2              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute3              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute4              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute5              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute6              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute7              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute8              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute9              IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute10             IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute11             IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute12             IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute13             IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute14             IN  jtf_varchar2_table_300 := NULL,
   p_qlpa_attribute15             IN  jtf_varchar2_table_300 := NULL,
   p_qlp_operation_code           IN  jtf_varchar2_table_100 := NULL,
   p_qlp_qte_line_index           IN  jtf_number_table := NULL,
   p_qlp_payment_id               IN  jtf_number_table := NULL,
   p_qlp_creation_date            IN  jtf_date_table   := NULL,
   p_qlp_created_by               IN  jtf_number_table := NULL,
   p_qlp_last_update_date         IN  jtf_date_table   := NULL,
   p_qlp_last_updated_by          IN  jtf_number_table := NULL,
   p_qlp_last_update_login        IN  jtf_number_table := NULL,
   p_qlp_request_id               IN  jtf_number_table := NULL,
   p_qlp_program_application_id   IN  jtf_number_table := NULL,
   p_qlp_program_id               IN  jtf_number_table := NULL,
   p_qlp_program_update_date      IN  jtf_date_table   := NULL,
   p_qlp_quote_header_id          IN  jtf_number_table := NULL,
   p_qlp_quote_line_id            IN  jtf_number_table := NULL,
   p_qlp_payment_type_code        IN  jtf_varchar2_table_100 := NULL,
   p_qlp_payment_ref_number       IN  jtf_varchar2_table_300 := NULL,
   p_qlp_payment_option           IN  jtf_varchar2_table_300 := NULL,
   p_qlp_payment_term_id          IN  jtf_number_table := NULL,
   p_qlp_credit_card_code         IN  jtf_varchar2_table_100 := NULL,
   p_qlp_credit_card_holder_name  IN  jtf_varchar2_table_100 := NULL,
   p_qlp_credit_card_exp_date     IN  jtf_date_table   := NULL,
   p_qlp_credit_card_aprv_code    IN  jtf_varchar2_table_100 := NULL,
   p_qlp_credit_card_aprv_date    IN  jtf_date_table   := NULL,
   p_qlp_payment_amount           IN  jtf_number_table := NULL,
   p_qlp_cust_po_number           IN  jtf_varchar2_table_100 := NULL,
   p_qlp_attribute_category       IN  jtf_varchar2_table_100 := NULL,
   p_qlp_attribute1               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute2               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute3               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute4               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute5               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute6               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute7               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute8               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute9               IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute10              IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute11              IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute12              IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute13              IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute14              IN  jtf_varchar2_table_200 := NULL,
   p_qlp_attribute15              IN  jtf_varchar2_table_200 := NULL,
   p_qls_operation_code           IN  jtf_varchar2_table_100 := NULL,
   p_qls_qte_line_index           IN  jtf_number_table := NULL,
   p_qls_shipment_id              IN  jtf_number_table := NULL,
   p_qls_creation_date            IN  jtf_date_table   := NULL,
   p_qls_created_by               IN  jtf_number_table := NULL,
   p_qls_last_update_date         IN  jtf_date_table   := NULL,
   p_qls_last_updated_by          IN  jtf_number_table := NULL,
   p_qls_last_update_login        IN  jtf_number_table := NULL,
   p_qls_request_id               IN  jtf_number_table := NULL,
   p_qls_program_application_id   IN  jtf_number_table := NULL,
   p_qls_program_id               IN  jtf_number_table := NULL,
   p_qls_program_update_date      IN  jtf_date_table   := NULL,
   p_qls_quote_header_id          IN  jtf_number_table := NULL,
   p_qls_quote_line_id            IN  jtf_number_table := NULL,
   p_qls_promise_date             IN  jtf_date_table   := NULL,
   p_qls_request_date             IN  jtf_date_table   := NULL,
   p_qls_schedule_ship_date       IN  jtf_date_table   := NULL,
   p_qls_ship_to_party_site_id    IN  jtf_number_table := NULL,
   p_qls_ship_to_party_id         IN  jtf_number_table := NULL,
   p_qls_ship_to_cust_acct_id     IN  jtf_number_table := NULL,
   p_qls_ship_partial_flag        IN  jtf_varchar2_table_300 := NULL,
   p_qls_ship_set_id              IN  jtf_number_table := NULL,
   p_qls_ship_method_code         IN  jtf_varchar2_table_100 := NULL,
   p_qls_freight_terms_code       IN  jtf_varchar2_table_100 := NULL,
   p_qls_freight_carrier_code     IN  jtf_varchar2_table_100 := NULL,
   p_qls_fob_code                 IN  jtf_varchar2_table_100 := NULL,
   p_qls_shipment_priority_code   IN jtf_varchar2_table_100  := NULL,
   p_qls_shipping_instructions    IN  jtf_varchar2_table_2000 := NULL,
   p_qls_packing_instructions     IN  jtf_varchar2_table_2000 := NULL,
   p_qls_quantity                 IN  jtf_number_table := NULL,
   p_qls_reserved_quantity        IN  jtf_number_table := NULL,
   p_qls_reservation_id           IN  jtf_number_table := NULL,
   p_qls_order_line_id            IN  jtf_number_table := NULL,
   p_qls_ship_to_party_name       IN  jtf_varchar2_table_300 := NULL,
   p_qls_ship_to_cont_fst_name    IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_cont_mid_name    IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_cont_lst_name    IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_address1         IN  jtf_varchar2_table_300 := NULL,
   p_qls_ship_to_address2         IN  jtf_varchar2_table_300 := NULL,
   p_qls_ship_to_address3         IN  jtf_varchar2_table_300 := NULL,
   p_qls_ship_to_address4         IN  jtf_varchar2_table_300 := NULL,
   p_qls_ship_to_country_code     IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_country          IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_city             IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_postal_code      IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_state            IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_province         IN  jtf_varchar2_table_100 := NULL,
   p_qls_ship_to_county           IN  jtf_varchar2_table_100 := NULL,
   p_qls_attribute_category       IN  jtf_varchar2_table_100 := NULL,
   p_qls_attribute1               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute2               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute3               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute4               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute5               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute6               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute7               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute8               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute9               IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute10              IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute11              IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute12              IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute13              IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute14              IN  jtf_varchar2_table_200 := NULL,
   p_qls_attribute15              IN  jtf_varchar2_table_200 := NULL,
   p_qlt_operation_code           IN  jtf_varchar2_table_100 := NULL,
   p_qlt_qte_line_index           IN  jtf_number_table := NULL,
   p_qlt_shipment_index           IN  jtf_number_table := NULL,
   p_qlt_tax_detail_id            IN  jtf_number_table := NULL,
   p_qlt_quote_header_id          IN  jtf_number_table := NULL,
   p_qlt_quote_line_id            IN  jtf_number_table := NULL,
   p_qlt_quote_shipment_id        IN  jtf_number_table := NULL,
   p_qlt_creation_date            IN  jtf_date_table   := NULL,
   p_qlt_created_by               IN  jtf_number_table := NULL,
   p_qlt_last_update_date         IN  jtf_date_table   := NULL,
   p_qlt_last_updated_by          IN  jtf_number_table := NULL,
   p_qlt_last_update_login        IN  jtf_number_table := NULL,
   p_qlt_request_id               IN  jtf_number_table := NULL,
   p_qlt_program_application_id   IN  jtf_number_table := NULL,
   p_qlt_program_id               IN  jtf_number_table := NULL,
   p_qlt_program_update_date      IN  jtf_date_table   := NULL,
   p_qlt_orig_tax_code            IN  jtf_varchar2_table_300 := NULL,
   p_qlt_tax_code                 IN  jtf_varchar2_table_100 := NULL,
   p_qlt_tax_rate                 IN  jtf_number_table := NULL,
   p_qlt_tax_date                 IN  jtf_date_table   := NULL,
   p_qlt_tax_amount               IN  jtf_number_table := NULL,
   p_qlt_tax_exempt_flag          IN  jtf_varchar2_table_100 := NULL,
   p_qlt_tax_exempt_number        IN  jtf_varchar2_table_100 := NULL,
   p_qlt_tax_exempt_reason_code   IN  jtf_varchar2_table_100 := NULL,
   p_qlt_attribute_category       IN  jtf_varchar2_table_100 := NULL,
   p_qlt_attribute1               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute2               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute3               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute4               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute5               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute6               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute7               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute8               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute9               IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute10              IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute11              IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute12              IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute13              IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute14              IN  jtf_varchar2_table_200 := NULL,
   p_qlt_attribute15              IN  jtf_varchar2_table_200 := NULL,
   p_qlpaa_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qlpaa_qte_line_index         IN jtf_number_table       := NULL,
   p_qlpaa_price_adj_index        IN jtf_number_table       := NULL,
   p_qlpaa_price_adj_attrib_id    IN jtf_number_table       := NULL,
   p_qlpaa_creation_date          IN jtf_date_table         := NULL,
   p_qlpaa_created_by             IN jtf_number_table       := NULL,
   p_qlpaa_last_update_date       IN jtf_date_table         := NULL,
   p_qlpaa_last_updated_by        IN jtf_number_table       := NULL,
   p_qlpaa_last_update_login      IN jtf_number_table       := NULL,
   p_qlpaa_program_application_id IN jtf_number_table       := NULL,
   p_qlpaa_program_id             IN jtf_number_table       := NULL,
   p_qlpaa_program_update_date    IN jtf_date_table         := NULL,
   p_qlpaa_request_id             IN jtf_number_table       := NULL,
   p_qlpaa_price_adjustment_id    IN jtf_number_table       := NULL,
   p_qlpaa_pricing_context        IN jtf_varchar2_table_100 := NULL,
   p_qlpaa_pricing_attribute      IN jtf_varchar2_table_100 := NULL,
   p_qlpaa_prc_attr_value_from    IN jtf_varchar2_table_300 := NULL,
   p_qlpaa_pricing_attr_value_to  IN jtf_varchar2_table_300 := NULL,
   p_qlpaa_comparison_operator    IN jtf_varchar2_table_100 := NULL,
   p_qlpaa_flex_title             IN jtf_varchar2_table_100 := NULL,
   p_qlpaj_operation_code         IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_qte_line_index         IN  jtf_number_table := NULL,
   p_qlpaj_price_adjustment_id    IN  jtf_number_table := NULL,
   p_qlpaj_creation_date          IN  jtf_date_table   := NULL,
   p_qlpaj_created_by             IN  jtf_number_table := NULL,
   p_qlpaj_last_update_date       IN  jtf_date_table   := NULL,
   p_qlpaj_last_updated_by        IN  jtf_number_table := NULL,
   p_qlpaj_last_update_login      IN  jtf_number_table := NULL,
   p_qlpaj_program_application_id IN  jtf_number_table := NULL,
   p_qlpaj_program_id             IN  jtf_number_table := NULL,
   p_qlpaj_program_update_date    IN  jtf_date_table   := NULL,
   p_qlpaj_request_id             IN  jtf_number_table := NULL,
   p_qlpaj_quote_header_id        IN  jtf_number_table := NULL,
   p_qlpaj_quote_line_id          IN  jtf_number_table := NULL,
   p_qlpaj_modifier_header_id     IN  jtf_number_table := NULL,
   p_qlpaj_modifier_line_id       IN  jtf_number_table := NULL,
   p_qlpaj_mod_line_type_code     IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_mod_mech_type_code     IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_modified_from          IN  jtf_number_table := NULL,
   p_qlpaj_modified_to            IN  jtf_number_table := NULL,
   p_qlpaj_operand                IN  jtf_number_table := NULL,
   p_qlpaj_arithmetic_operator    IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_automatic_flag         IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_update_allowable_flag  IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_updated_flag           IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_applied_flag           IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_on_invoice_flag        IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_pricing_phase_id       IN  jtf_number_table := NULL,
   p_qlpaj_attribute_category     IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_attribute1             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute2             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute3             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute4             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute5             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute6             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute7             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute8             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute9             IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute10            IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute11            IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute12            IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute13            IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute14            IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_attribute15            IN  jtf_varchar2_table_200 := NULL,
   p_qlpaj_orig_sys_discount_ref  IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_change_sequence        IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_update_allowed         IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_change_reason_code     IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_change_reason_text     IN  jtf_varchar2_table_2000 := NULL,
   p_qlpaj_cost_id                IN  jtf_number_table := NULL,
   p_qlpaj_tax_code               IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_tax_exempt_flag        IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_tax_exempt_number      IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_tax_exempt_reason_code IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_parent_adjustment_id   IN  jtf_number_table := NULL,
   p_qlpaj_invoiced_flag          IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_estimated_flag         IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_inc_in_sales_perfce    IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_split_action_code      IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_adjusted_amount        IN  jtf_number_table := NULL,
   p_qlpaj_charge_type_code       IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_charge_subtype_code    IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_range_break_quantity   IN  jtf_number_table := NULL,
   p_qlpaj_accrual_conv_rate      IN  jtf_number_table := NULL,
   p_qlpaj_pricing_group_sequence IN  jtf_number_table := NULL,
   p_qlpaj_accrual_flag           IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_list_line_no           IN  jtf_varchar2_table_300 := NULL,
   p_qlpaj_source_system_code     IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_benefit_qty            IN  jtf_number_table := NULL,
   p_qlpaj_benefit_uom_code       IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_print_on_invoice_flag  IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_expiration_date        IN  jtf_date_table   := NULL,
   p_qlpaj_rebate_trans_type_code IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_rebate_trans_reference IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_rebate_pay_system_code IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_redeemed_date          IN  jtf_date_table   := NULL,
   p_qlpaj_redeemed_flag          IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_modifier_level_code    IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_price_break_type_code  IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_substitution_attribute IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_proration_type_code    IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_include_on_ret_flag    IN  jtf_varchar2_table_100 := NULL,
   p_qlpaj_credit_or_charge_flag  IN  jtf_varchar2_table_100 := NULL,
   p_qlpar_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qlpar_adj_relationship_id    IN jtf_number_table       := NULL,
   p_qlpar_creation_date          IN jtf_date_table         := NULL,
   p_qlpar_created_by             IN jtf_number_table       := NULL,
   p_qlpar_last_update_date       IN jtf_date_table         := NULL,
   p_qlpar_last_updated_by        IN jtf_number_table       := NULL,
   p_qlpar_last_update_login      IN jtf_number_table       := NULL,
   p_qlpar_request_id             IN jtf_number_table       := NULL,
   p_qlpar_program_application_id IN jtf_number_table       := NULL,
   p_qlpar_program_id             IN jtf_number_table       := NULL,
   p_qlpar_program_update_date    IN jtf_date_table         := NULL,
   p_qlpar_quote_line_id          IN jtf_number_table       := NULL,
   p_qlpar_qte_line_index         IN jtf_number_table       := NULL,
   p_qlpar_price_adjustment_id    IN jtf_number_table       := NULL,
   p_qlpar_price_adj_index        IN jtf_number_table       := NULL,
   p_qlpar_rltd_price_adj_id      IN jtf_number_table       := NULL,
   p_qlpar_rltd_price_adj_index   IN jtf_number_table       := NULL,
   p_qlae_qte_line_index         IN jtf_number_table        := NULL,
   p_qlae_shipment_index         IN jtf_number_table        := NULL,
   p_qlae_line_attribute_id      IN jtf_number_table        := NULL,
   p_qlae_creation_date          IN jtf_date_table          := NULL,
   p_qlae_created_by             IN jtf_number_table        := NULL,
   p_qlae_last_update_date       IN jtf_date_table          := NULL,
   p_qlae_last_updated_by        IN jtf_number_table        := NULL,
   p_qlae_last_update_login      IN jtf_number_table        := NULL,
   p_qlae_request_id             IN jtf_number_table        := NULL,
   p_qlae_program_application_id IN jtf_number_table        := NULL,
   p_qlae_program_id             IN jtf_number_table        := NULL,
   p_qlae_program_update_date    IN jtf_date_table          := NULL,
   p_qlae_quote_header_id        IN jtf_number_table        := NULL,
   p_qlae_quote_line_id          IN jtf_number_table        := NULL,
   p_qlae_quote_shipment_id      IN jtf_number_table        := NULL,
   p_qlae_attribute_type_code    IN jtf_varchar2_table_100  := NULL,
   p_qlae_name                   IN jtf_varchar2_table_100  := NULL,
   p_qlae_value                  IN jtf_varchar2_table_2000 := NULL,
   p_qlae_value_type             IN jtf_varchar2_table_300  := NULL,
   p_qlae_status                 IN jtf_varchar2_table_100  := NULL,
   p_qlae_application_id         IN jtf_number_table        := NULL,
   p_qlae_start_date_active      IN jtf_date_table          := NULL,
   p_qlae_end_date_active        IN jtf_date_table          := NULL,
   p_qlae_operation_code         IN jtf_varchar2_table_100  := NULL,
   p_qfc_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qfc_qte_line_index         IN jtf_number_table       := NULL,
   p_qfc_shipment_index         IN jtf_number_table       := NULL,
   p_qfc_freight_charge_id      IN jtf_number_table       := NULL,
   p_qfc_last_update_date       IN jtf_date_table         := NULL,
   p_qfc_last_updated_by        IN jtf_number_table       := NULL,
   p_qfc_creation_date          IN jtf_date_table         := NULL,
   p_qfc_created_by             IN jtf_number_table       := NULL,
   p_qfc_last_update_login      IN jtf_number_table       := NULL,
   p_qfc_program_application_id IN jtf_number_table       := NULL,
   p_qfc_program_id             IN jtf_number_table       := NULL,
   p_qfc_program_update_date    IN jtf_date_table         := NULL,
   p_qfc_request_id             IN jtf_number_table       := NULL,
   p_qfc_quote_shipment_id      IN jtf_number_table       := NULL,
   p_qfc_quote_line_id          IN jtf_number_table       := NULL,
   p_qfc_freight_charge_type_id IN jtf_number_table       := NULL,
   p_qfc_charge_amount          IN jtf_number_table       := NULL,
   p_qfc_attribute_category     IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute1             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute2             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute3             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute4             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute5             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute6             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute7             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute8             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute9             IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute10            IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute11            IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute12            IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute13            IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute14            IN jtf_varchar2_table_200 := NULL,
   p_qfc_attribute15            IN jtf_varchar2_table_200 := NULL,
   p_qlfc_operation_code         IN jtf_varchar2_table_100 := NULL,
   p_qlfc_qte_line_index         IN jtf_number_table       := NULL,
   p_qlfc_shipment_index         IN jtf_number_table       := NULL,
   p_qlfc_freight_charge_id      IN jtf_number_table       := NULL,
   p_qlfc_last_update_date       IN jtf_date_table         := NULL,
   p_qlfc_last_updated_by        IN jtf_number_table       := NULL,
   p_qlfc_creation_date          IN jtf_date_table         := NULL,
   p_qlfc_created_by             IN jtf_number_table       := NULL,
   p_qlfc_last_update_login      IN jtf_number_table       := NULL,
   p_qlfc_program_application_id IN jtf_number_table       := NULL,
   p_qlfc_program_id             IN jtf_number_table       := NULL,
   p_qlfc_program_update_date    IN jtf_date_table         := NULL,
   p_qlfc_request_id             IN jtf_number_table       := NULL,
   p_qlfc_quote_shipment_id      IN jtf_number_table       := NULL,
   p_qlfc_quote_line_id          IN jtf_number_table       := NULL,
   p_qlfc_freight_charge_type_id IN jtf_number_table       := NULL,
   p_qlfc_charge_amount          IN jtf_number_table       := NULL,
   p_qlfc_attribute_category     IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute1             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute2             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute3             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute4             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute5             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute6             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute7             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute8             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute9             IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute10            IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute11            IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute12            IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute13            IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute14            IN jtf_varchar2_table_200 := NULL,
   p_qlfc_attribute15            IN jtf_varchar2_table_200 := NULL
)
IS
  l_qte_header_rec ASO_Quote_Pub.qte_header_rec_type;
  l_qte_line_tbl              ASO_Quote_Pub.qte_line_tbl_type;
  l_qte_line_dtl_tbl          ASO_Quote_Pub.qte_line_Dtl_tbl_type;
  l_line_rltship_tbl          ASO_Quote_Pub.line_rltship_tbl_type;
  l_control_rec               ASO_Quote_Pub.Control_Rec_Type;
  l_Hd_Payment_Tbl            ASO_Quote_Pub.Payment_tbl_Type;
  l_ln_Payment_Tbl            ASO_Quote_Pub.Payment_tbl_Type;
  l_Hd_Tax_Detail_Tbl         ASO_Quote_Pub.Tax_Detail_TBL_Type;
  l_ln_Tax_Detail_Tbl         ASO_Quote_Pub.Tax_Detail_TBL_Type;
  l_Hd_Shipment_Tbl           ASO_Quote_Pub.Shipment_TBL_Type;
  l_ln_Shipment_Tbl           ASO_Quote_Pub.Shipment_TBL_Type;
  l_hd_Price_Attributes_Tbl   ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  l_ln_Price_Attributes_Tbl   ASO_Quote_Pub.Price_Attributes_Tbl_Type;
  l_hd_Freight_Charge_Tbl     ASO_Quote_Pub.Freight_Charge_Tbl_Type;
  l_ln_Freight_Charge_Tbl     ASO_Quote_Pub.Freight_Charge_Tbl_Type;
  l_Line_Attr_Ext_Tbl         ASO_Quote_Pub.Line_Attribs_Ext_Tbl_Type;
  l_Price_Adj_Attr_Tbl        ASO_Quote_Pub.Price_Adj_Attr_Tbl_Type;
  l_Price_Adjustment_Tbl      ASO_Quote_Pub.Price_Adj_Tbl_Type;
  l_Price_Adj_Rltship_Tbl     ASO_Quote_Pub.Price_Adj_Rltship_Tbl_Type;

  -- 4/23/02: changed
  lx_qte_line_tbl              ASO_Quote_Pub.qte_line_tbl_type;
  l_save_type                 VARCHAR2(100) := 'SAVE_ADDTOCART';

  --Bug 2641510
  l_error_code                  VARCHAR2(30);
  l_error_flag                  VARCHAR2(30);
  l_error_message               VARCHAR2(300);

  l_attribute_value             VARCHAR2(30);
  l_count Number := 0;
  l_cross_ref_type varchar2(100) := FND_API.G_MISS_CHAR;
  l_temp_id  Number := NULL;
  l_ordered_item_id_tbl   jtf_number_table ;
  l_ordered_item_tbl   jtf_varchar2_table_100 ;
  l_item_ident_type_tbl   jtf_varchar2_table_100 ;

  --bug 17376303
    l_org_id Number := null;

  Cursor c_get_custItemId (c_custPart_num VARCHAR2) is
    Select distinct customer_item_id
      From  MTL_CUSTOMER_ITEM_XREFS_V
       where CUSTOMER_ITEM_NUMBER = c_custPart_num;

       Cursor c_get_crossRefId (c_crossRef_num VARCHAR2, c_crossRef_type VARCHAR2) is
    Select CROSS_REFERENCE_ID
      From MTL_CROSS_REFERENCES_V
       where cross_reference_type = c_crossRef_type and
       cross_reference =  c_crossRef_num;

BEGIN

  Set_Control_rec_w(
    p_c_LAST_UPDATE_DATE                   =>  p_c_LAST_UPDATE_DATE
   ,p_c_auto_version_flag                  =>  p_c_auto_version_flag
   ,p_c_pricing_request_type               =>  p_c_pricing_request_type
   ,p_c_header_pricing_event               =>  p_c_header_pricing_event
   ,p_c_line_pricing_event                 =>  p_c_line_pricing_event
   ,p_c_CAL_TAX_FLAG                       =>  p_c_CAL_TAX_FLAG
   ,p_c_CAL_FREIGHT_CHARGE_FLAG            =>  p_c_CAL_FREIGHT_CHARGE_FLAG
   ,p_c_price_mode 			   =>  p_c_price_mode		-- change line logic pricing
   ,x_control_rec                          =>  l_control_rec
  );



    if p_ql_inventory_item_id  is not null  then
    l_count := p_ql_inventory_item_id.count;
    end if;

   l_ordered_item_id_tbl := JTF_NUMBER_TABLE();
   l_ordered_item_tbl := JTF_VARCHAR2_TABLE_100();
   l_item_ident_type_tbl := JTF_VARCHAR2_TABLE_100();

/* 16-July-2013  amaheshw bug# 17160660	   Commented & added

    l_ordered_item_id_tbl.extend(l_count);
    l_ordered_item_tbl.extend(l_count);
    l_item_ident_type_tbl.extend(l_count);
*/

  if l_count  >0   then
    l_ordered_item_id_tbl.extend(l_count);
    l_ordered_item_tbl.extend(l_count);
    l_item_ident_type_tbl.extend(l_count);
 else
   l_ordered_item_id_tbl := NULL;
   l_ordered_item_tbl := NULL;
   l_item_ident_type_tbl := NULL;
 end if;


--bug 17376303
    select distinct master_organization_id into l_org_id from oe_system_parameters_all
      where org_id = mo_global.GET_CURRENT_ORG_ID() ;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_Util.Debug('IBE_Quote_W1_pvt:: p_ql_inventory_item_id.count = l_count =' || l_count);
   IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: printing mo_global.GET_CURRENT_ORG_ID() value: ' ||  mo_global.GET_CURRENT_ORG_ID());
   IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: orgid value: ' || l_org_id);
  End IF;

--16-July-2013  amaheshw bug# 17160660 end of addition

    FOR i IN 1..l_count LOOP
   l_temp_id := null;

  if( (p_ql_cust_part_number is not null) and (p_ql_cust_part_number(i) IS NOT NULL) and (p_ql_cust_part_number(i) <> FND_API.G_MISS_CHAR) ) THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_W1_pvt:: p_ql_cust_part_number(' || i || ') is not null: ' ||  p_ql_cust_part_number(i));
           IBE_Util.Debug('IBE_Quote_W1_pvt::  p_q_cust_account_id: ' ||   p_q_cust_account_id);
            IBE_Util.Debug('IBE_Quote_W1_pvt:: p_q_org_id ' ||  l_org_id);
          End IF;

         INV_CUSTOMER_ITEM_GRP.CI_Attribute_Value(
            z_customer_id          => p_q_cust_account_id                ,
            z_customer_item_number => p_ql_cust_part_number(i),
         --bug 17376303    z_organization_id      => mo_global.GET_CURRENT_ORG_ID()           ,
            z_organization_id      => l_org_id           ,
            attribute_name         => 'CUSTOMER_ITEM_ID'          ,
            error_code             => l_error_code                 ,
            error_flag             => l_error_flag                 ,
            error_message          => l_error_message              ,
            attribute_value        => l_attribute_value
         );


          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_W1_pvt::l_error_flag 3 ' ||  l_error_flag);
           IBE_Util.Debug('IBE_Quote_W1_pvt::  l_error_message3: ' ||   l_error_message);
           IBE_Util.Debug('IBE_Quote_W1_pvt::  l_attribute_value3: ' ||   l_attribute_value);
          End IF;

         IF l_error_flag = 'Y' THEN
            --inv_debug.message('ssia', 'got error from inv_customer_item_grp');
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_Message.Set_Name('IBE', 'IBE_SC_INV_CUSTOM_ITEM_ERROR');
               FND_Message.Set_Token('INVMSG', l_error_message);
               FND_MSG_PUB.Add;
            END IF;
         END IF;


         IF l_attribute_value IS NOT NULL THEN
            l_temp_id := to_number(l_attribute_value);
       end if;

       l_ordered_item_id_tbl(i) := l_temp_id;
       l_item_ident_type_tbl(i) := 'CUST';
       l_ordered_item_tbl(i)  := null;

  elsif( (p_ql_cross_ref_number is not null) and (p_ql_cross_ref_number(i) IS NOT NULL) and (p_ql_cross_ref_number(i) <> FND_API.G_MISS_CHAR) ) THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_W1_pvt:: p_ql_cross_ref_number(' || i || ') is not null: ' ||  p_ql_cross_ref_number(i));
         End IF;
         -- Code when croess_reference_id is required to send to ASO: Start
       /* if( (p_ql_cross_ref_type is not null) and (p_ql_cross_ref_type(i) IS NOT NULL) and (p_ql_cross_ref_type(i) <> FND_API.G_MISS_CHAR) ) THEN
           open c_get_crossRefId(p_ql_cross_ref_number(i), p_ql_cross_ref_type(i));
           fetch c_get_crossRefId into l_temp_id;

           if c_get_crossRefId%notfound then
            l_temp_id := null;
           end if;
           close c_get_crossRefId;
            l_item_ident_type_tbl(i) := p_ql_cross_ref_type(i);
        else
        l_cross_ref_type := null;
        Select CROSS_REFERENCE_ID, cross_reference_type  into l_temp_id,l_cross_ref_type From MTL_CROSS_REFERENCES_V  where cross_reference =  p_ql_cross_ref_number(i);
        l_item_ident_type_tbl(i) := l_cross_ref_type;
       end if;
         l_ordered_item_id_tbl(i) := l_temp_id;*/
         -- Code when croess_reference_id is required to send to ASO:  End
         l_ordered_item_tbl(i) := p_ql_cross_ref_number(i);
         l_ordered_item_id_tbl(i) := null;

         if( (p_ql_cross_ref_type is not null) and (p_ql_cross_ref_type(i) IS NOT NULL) and (p_ql_cross_ref_type(i) <> FND_API.G_MISS_CHAR) ) THEN
		 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_W1_pvt::BUG:17184951: p_ql_cross_ref_type(' || i || ') is not null: ' ||  p_ql_cross_ref_type(i));
         End IF;
         l_item_ident_type_tbl(i) := p_ql_cross_ref_type(i);
         else
		 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_W1_pvt::BUG:17184951: p_ql_cross_ref_type is null: ');
         End IF;
          l_cross_ref_type := null;
          -- modified by kdosapat for bug 17184951 --
         /* Select cross_reference_type  into l_cross_ref_type From MTL_CROSS_REFERENCES_V  where cross_reference =  p_ql_cross_ref_number(i); */

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		 IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: printing mo_global.GET_CURRENT_ORG_ID() value: ' ||  mo_global.GET_CURRENT_ORG_ID());
     		 IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: printing org id value: ' ||  l_org_id);
		 IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: printing p_ql_cross_ref_number(i) value: ' ||  p_ql_cross_ref_number(i));
		 IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: changing the query to get correct org id:::::: ');
		 End IF;


          Select  ref.cross_reference_type into l_cross_ref_type From MTL_CROSS_REFERENCES_V ref,  MTL_SYSTEM_ITEMS_VL MSIV
		         where ref.cross_reference  = p_ql_cross_ref_number(i)
                and ref.inventory_item_id = MSIV.inventory_item_id
                 AND MSIV.WEB_STATUS = 'PUBLISHED'
             --    AND MSIV.organization_id = mo_global.GET_CURRENT_ORG_ID();
                 AND MSIV.organization_id = l_org_id;

	/* bug 17376303
				 Select  ref.cross_reference_type into l_cross_ref_type From MTL_CROSS_REFERENCES_V ref,  MTL_SYSTEM_ITEMS_VL MSIV
		         where ref.cross_reference  = p_ql_cross_ref_number(i)
                 and ref.inventory_item_id = MSIV.inventory_item_id
                 AND MSIV.WEB_STATUS = 'PUBLISHED'
                 AND MSIV.organization_id = (select distinct master_organization_id from oe_system_parameters_all
 where org_id = mo_global.GET_CURRENT_ORG_ID()) ;
*/
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	      IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: printing mo_global.GET_CURRENT_ORG_ID() value: ' ||  mo_global.GET_CURRENT_ORG_ID());
		  IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: printing p_ql_cross_ref_number(i) value: ' ||  p_ql_cross_ref_number(i));
          IBE_Util.Debug('IBE_Quote_W1_pvt:: BUG:17184951 :: l_cross_ref_type is: ' ||  l_cross_ref_type);
         End IF;


        l_item_ident_type_tbl(i) := l_cross_ref_type;
         end if;

  else

/* 25-Jun-2013  amaheshw bug# 16993086
      l_ordered_item_id_tbl(i) := null;
      l_item_ident_type_tbl(i) := null;
      l_ordered_item_tbl(i)  := null;
*/
      l_ordered_item_id_tbl(i) := FND_API.G_MISS_NUM;
      l_item_ident_type_tbl(i) := FND_API.G_MISS_CHAR;
      l_ordered_item_tbl(i)  := FND_API.G_MISS_CHAR;



  end if;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_Util.Debug('IBE_Quote_W1_pvt:: l_ordered_item_id_tbl(i): ' ||  l_ordered_item_id_tbl(i) || 'l_ordered_item_tbl(i): ' ||  l_ordered_item_tbl(i) || 'l_item_ident_type_tbl(i): ' || l_item_ident_type_tbl(i) || 'i: '||i);
         End IF;

      end loop;

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
-- added attribute 16-20 for bug 6873117 mgiridha
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
      p_resource_id                => p_q_resource_id               ,
      p_end_customer_party_id        => p_q_end_cust_party_id         ,
      p_end_customer_cust_party_id   => p_q_end_cust_cust_party_id    ,
      p_end_customer_party_site_id   => p_q_end_cust_party_site_id    ,
      p_end_customer_cust_account_id => p_q_end_cust_cust_account_id,
      p_pricing_status_indicator 	 => p_q_pricing_status_indicator,
      p_tax_status_indicator 		 => p_q_tax_status_indicator);


      --PerfCode Added
    IF p_ql_quote_header_id IS NOT NULL AND p_ql_quote_header_id.COUNT > 0 THEN
     l_qte_line_tbl := Construct_Qte_Line_Tbl(
      p_creation_date            => p_ql_creation_date           ,
      p_created_by               => p_ql_created_by              ,
      p_last_updated_by          => p_ql_last_updated_by         ,
      p_last_update_date         => p_ql_last_update_date        ,
      p_last_update_login        => p_ql_last_update_login       ,
      p_request_id               => p_ql_request_id              ,
      p_program_application_id   => p_ql_program_application_id  ,
      p_program_id               => p_ql_program_id              ,
      p_program_update_date      => p_ql_program_update_date     ,
      p_quote_line_id            => p_ql_quote_line_id           ,
      p_quote_header_id          => p_ql_quote_header_id         ,
      p_org_id                   => p_ql_org_id                  ,
      p_line_number              => p_ql_line_number             ,
      p_line_category_code       => p_ql_line_category_code      ,
      p_item_type_code           => p_ql_item_type_code          ,
      p_inventory_item_id        => p_ql_inventory_item_id       ,
      p_organization_id          => p_ql_organization_id         ,
      p_quantity                 => p_ql_quantity                ,
      p_uom_code                 => p_ql_uom_code                ,

      p_ordered_item_id_tbl      => l_ordered_item_id_tbl        ,
      p_ordered_item_tbl         => l_ordered_item_tbl        ,
      p_item_ident_type_tbl      => l_item_ident_type_tbl        ,

      p_start_date_active        => p_ql_start_date_active       ,
      p_end_date_active          => p_ql_end_date_active         ,
      p_order_line_type_id       => p_ql_order_line_type_id      ,
      p_price_list_id            => p_ql_price_list_id           ,
      p_price_list_line_id       => p_ql_price_list_line_id      ,
      p_currency_code            => p_ql_currency_code           ,
      p_line_list_price          => p_ql_line_list_price         ,
      p_line_adjusted_amount     => p_ql_line_adjusted_amount    ,
      p_line_adjusted_percent    => p_ql_line_adjusted_percent   ,
      p_line_quote_price         => p_ql_line_quote_price        ,
      p_related_item_id          => p_ql_related_item_id         ,
      p_item_relationship_type   => p_ql_item_relationship_type  ,
      p_split_shipment_flag      => p_ql_split_shipment_flag     ,
      p_backorder_flag           => p_ql_backorder_flag          ,
      p_selling_price_change     => p_ql_selling_price_change    ,
      p_recalculate_flag         => p_ql_recalculate_flag        ,
      p_attribute_category       => p_ql_attribute_category      ,
      p_attribute1               => p_ql_attribute1              ,
      p_attribute2               => p_ql_attribute2              ,
      p_attribute3               => p_ql_attribute3              ,
      p_attribute4               => p_ql_attribute4              ,
      p_attribute5               => p_ql_attribute5              ,
      p_attribute6               => p_ql_attribute6              ,
      p_attribute7               => p_ql_attribute7              ,
      p_attribute8               => p_ql_attribute8              ,
      p_attribute9               => p_ql_attribute9              ,
      p_attribute10              => p_ql_attribute10             ,
      p_attribute11              => p_ql_attribute11             ,
      p_attribute12              => p_ql_attribute12             ,
      p_attribute13              => p_ql_attribute13             ,
      p_attribute14              => p_ql_attribute14             ,
      p_attribute15              => p_ql_attribute15             ,
      --modified for bug 18525045 - start
     p_attribute16              => p_ql_attribute16             ,
     p_attribute17              => p_ql_attribute17             ,
      p_attribute18              => p_ql_attribute18             ,
     p_attribute19              => p_ql_attribute19             ,
     p_attribute20              => p_ql_attribute20             ,
      --modified for bug 18525045 - end
      p_accounting_rule_id       => p_ql_accounting_rule_id      ,
      p_ffm_content_name         => p_ql_ffm_content_name        ,
      p_ffm_content_type         => p_ql_ffm_content_type        ,
      p_ffm_document_type        => p_ql_ffm_document_type       ,
      p_ffm_media_id             => p_ql_ffm_media_id            ,
      p_ffm_media_type           => p_ql_ffm_media_type          ,
      p_ffm_user_note            => p_ql_ffm_user_note           ,
      p_invoice_to_party_id      => p_ql_invoice_to_party_id     ,
      p_invoice_to_party_site_id => p_ql_invoice_to_party_site_id,
      p_invoice_to_cust_acct_id  => p_ql_invoice_to_cust_acct_id ,
      p_invoicing_rule_id        => p_ql_invoicing_rule_id       ,
      p_marketing_source_code_id => p_ql_marketing_source_code_id,
      p_operation_code           => p_ql_operation_code          ,
      p_commitment_id            => p_ql_commitment_id           ,
      p_agreement_id             => p_ql_agreement_id            ,
      p_minisite_id              => p_ql_minisite_id             ,
      p_section_id               => p_ql_section_id              ,
      p_end_customer_party_id        => p_ql_end_cust_party_id       ,
      p_end_customer_cust_party_id   => p_ql_end_cust_cust_party_id  ,
      p_end_customer_party_site_id   => p_ql_end_cust_party_site_id  ,
      p_end_customer_cust_account_id => p_ql_end_cust_cust_account_id);
    ELSE
        l_qte_line_tbl  := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL;
    END IF;

  IF p_qdl_quote_line_detail_id IS NOT NULL  AND p_qdl_quote_line_detail_id.COUNT > 0 THEN
   l_qte_line_dtl_tbl := Construct_Qte_Line_Dtl_Tbl(
      p_quote_line_detail_id     => p_qdl_quote_line_detail_id    ,
      p_creation_date            => p_qdl_creation_date           ,
      p_created_by               => p_qdl_created_by              ,
      p_last_update_date         => p_qdl_last_update_date        ,
      p_last_updated_by          => p_qdl_last_updated_by         ,
      p_last_update_login        => p_qdl_last_update_login       ,
      p_request_id               => p_qdl_request_id              ,
      p_program_application_id   => p_qdl_program_application_id  ,
      p_program_id               => p_qdl_program_id              ,
      p_program_update_date      => p_qdl_program_update_date     ,
      p_quote_line_id            => p_qdl_quote_line_id           ,
      p_config_header_id         => p_qdl_config_header_id        ,
      p_config_revision_num      => p_qdl_config_revision_num     ,
      p_config_item_id           => p_qdl_config_item_id          ,
      p_complete_configuration   => p_qdl_complete_configuration  ,
      p_valid_configuration_flag => p_qdl_valid_configuration_flag,
      p_component_code           => p_qdl_component_code          ,
      p_service_coterminate_flag => p_qdl_service_coterminate_flag,
      p_service_duration         => p_qdl_service_duration        ,
      p_service_period           => p_qdl_service_period          ,
      p_service_unit_selling     => p_qdl_service_unit_selling    ,
      p_service_unit_list        => p_qdl_service_unit_list       ,
      p_service_number           => p_qdl_service_number          ,
      p_unit_percent_base_price  => p_qdl_unit_percent_base_price ,
      p_attribute_category       => p_qdl_attribute_category      ,
      p_attribute1               => p_qdl_attribute1              ,
      p_attribute2               => p_qdl_attribute2              ,
      p_attribute3               => p_qdl_attribute3              ,
      p_attribute4               => p_qdl_attribute4              ,
      p_attribute5               => p_qdl_attribute5              ,
      p_attribute6               => p_qdl_attribute6              ,
      p_attribute7               => p_qdl_attribute7              ,
      p_attribute8               => p_qdl_attribute8              ,
      p_attribute9               => p_qdl_attribute9              ,
      p_attribute10              => p_qdl_attribute10             ,
      p_attribute11              => p_qdl_attribute11             ,
      p_attribute12              => p_qdl_attribute12             ,
      p_attribute13              => p_qdl_attribute13             ,
      p_attribute14              => p_qdl_attribute14             ,
      p_attribute15              => p_qdl_attribute15             ,
      p_service_ref_type_code    => p_qdl_service_ref_type_code   ,
      p_service_ref_order_number => p_qdl_service_ref_order_number,
      p_service_ref_line_number  => p_qdl_service_ref_line_number ,
      p_service_ref_qte_line_ind => p_qdl_service_ref_qte_line_ind,
      p_service_ref_line_id      => p_qdl_service_ref_line_id     ,
      p_service_ref_system_id    => p_qdl_service_ref_system_id   ,
      p_service_ref_option_numb  => p_qdl_service_ref_option_numb ,
      p_service_ref_shipment     => p_qdl_service_ref_shipment    ,
      p_return_ref_type          => p_qdl_return_ref_type         ,
      p_return_ref_header_id     => p_qdl_return_ref_header_id    ,
      p_return_ref_line_id       => p_qdl_return_ref_line_id      ,
      p_return_attribute1        => p_qdl_return_attribute1       ,
      p_return_attribute2        => p_qdl_return_attribute2       ,
      p_return_attribute3        => p_qdl_return_attribute3       ,
      p_return_attribute4        => p_qdl_return_attribute4       ,
      p_return_attribute5        => p_qdl_return_attribute5       ,
      p_return_attribute6        => p_qdl_return_attribute6       ,
      p_return_attribute7        => p_qdl_return_attribute7       ,
      p_return_attribute8        => p_qdl_return_attribute8       ,
      p_return_attribute9        => p_qdl_return_attribute9       ,
      p_return_attribute10       => p_qdl_return_attribute10      ,
      p_return_attribute11       => p_qdl_return_attribute11      ,
      p_return_attribute12       => p_qdl_return_attribute12      ,
      p_return_attribute13       => p_qdl_return_attribute13      ,
      p_return_attribute14       => p_qdl_return_attribute14      ,
      p_return_attribute15       => p_qdl_return_attribute15      ,
      p_operation_code           => p_qdl_operation_code          ,
      p_qte_line_index           => p_qdl_qte_line_index          ,
      p_return_attr_category     => p_qdl_return_attr_category    ,
      p_return_reason_code       => p_qdl_return_reason_code);
   ELSE
     l_qte_line_dtl_tbl   := ASO_Quote_Pub.G_MISS_QTE_LINE_DTL_TBL;
   END IF;


   IF p_qrl_line_relationship_id IS NOT NULL AND p_qrl_line_relationship_id.COUNT > 0 THEN
   l_line_rltship_tbl := Construct_Line_Rltship_Tbl(
      p_line_relationship_id   => p_qrl_line_relationship_id  ,
      p_creation_date          => p_qrl_creation_date         ,
      p_created_by             => p_qrl_created_by            ,
      p_last_updated_by        => p_qrl_last_updated_by       ,
      p_last_update_date       => p_qrl_last_update_date      ,
      p_last_update_login      => p_qrl_last_update_login     ,
      p_request_id             => p_qrl_request_id            ,
      p_program_application_id => p_qrl_program_application_id,
      p_program_id             => p_qrl_program_id            ,
      p_program_update_date    => p_qrl_program_update_date   ,
      p_quote_line_id          => p_qrl_quote_line_id         ,
      p_related_quote_line_id  => p_qrl_related_quote_line_id ,
      p_relationship_type_code => p_qrl_relationship_type_code,
      p_reciprocal_flag        => p_qrl_reciprocal_flag       ,
      p_qte_line_index         => p_qrl_qte_line_index        ,
      p_related_qte_line_index => p_qrl_related_qte_line_index,
      p_operation_code         => p_qrl_operation_code);
    ELSE
      l_line_rltship_tbl  := ASO_Quote_Pub.G_MISS_Line_Rltship_Tbl;
    END IF;

   IF p_qp_quote_header_id IS NOT NULL AND p_qp_quote_header_id.COUNT > 0 THEN
   -- set header payment tbl
   l_hd_payment_tbl := Construct_Payment_Tbl(
      p_operation_code            => p_qp_operation_code           ,
      p_qte_line_index            => p_qp_qte_line_index           ,
      p_payment_id                => p_qp_payment_id               ,
      p_creation_date             => p_qp_creation_date            ,
      p_created_by                => p_qp_created_by               ,
      p_last_update_date          => p_qp_last_update_date         ,
      p_last_updated_by           => p_qp_last_updated_by          ,
      p_last_update_login         => p_qp_last_update_login        ,
      p_request_id                => p_qp_request_id               ,
      p_program_application_id    => p_qp_program_application_id   ,
      p_program_id                => p_qp_program_id               ,
      p_program_update_date       => p_qp_program_update_date      ,
      p_quote_header_id           => p_qp_quote_header_id          ,
      p_quote_line_id             => p_qp_quote_line_id            ,
      p_payment_type_code         => p_qp_payment_type_code        ,
      p_payment_ref_number        => p_qp_payment_ref_number       ,
      p_payment_option            => p_qp_payment_option           ,
      p_payment_term_id           => p_qp_payment_term_id          ,
      p_credit_card_code          => p_qp_credit_card_code         ,
      p_credit_card_holder_name   => p_qp_credit_card_holder_name  ,
      p_credit_card_exp_date      => p_qp_credit_card_exp_date     ,
      p_credit_card_approval_code => p_qp_credit_card_approval_code,
      p_credit_card_approval_date => p_qp_credit_card_approval_date,
      p_payment_amount            => p_qp_payment_amount           ,
      p_cust_po_number            => p_qp_cust_po_number           ,
      p_attribute_category        => p_qp_attribute_category       ,
      p_attribute1                => p_qp_attribute1               ,
      p_attribute2                => p_qp_attribute2               ,
      p_attribute3                => p_qp_attribute3               ,
      p_attribute4                => p_qp_attribute4               ,
      p_attribute5                => p_qp_attribute5               ,
      p_attribute6                => p_qp_attribute6               ,
      p_attribute7                => p_qp_attribute7               ,
      p_attribute8                => p_qp_attribute8               ,
      p_attribute9                => p_qp_attribute9               ,
      p_attribute10               => p_qp_attribute10              ,
      p_attribute11               => p_qp_attribute11              ,
      p_attribute12               => p_qp_attribute12              ,
      p_attribute13               => p_qp_attribute13              ,
      p_attribute14               => p_qp_attribute14              ,
      p_attribute15               => p_qp_attribute15              ,
      p_assignment_id             => p_qp_assignment_id            ,
      p_cvv2                      => p_qp_cvv2                     );
     ELSE
       l_Hd_Payment_Tbl := ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
     END IF;

   IF p_qlp_quote_header_id IS NOT NULL AND p_qlp_quote_header_id.COUNT > 0 THEN
     -- set line payment tbl
   l_ln_payment_tbl := Construct_Payment_Tbl(
      p_operation_code            => p_qlp_operation_code         ,
      p_qte_line_index            => p_qlp_qte_line_index         ,
      p_payment_id                => p_qlp_payment_id             ,
      p_creation_date             => p_qlp_creation_date          ,
      p_created_by                => p_qlp_created_by             ,
      p_last_update_date          => p_qlp_last_update_date       ,
      p_last_updated_by           => p_qlp_last_updated_by        ,
      p_last_update_login         => p_qlp_last_update_login      ,
      p_request_id                => p_qlp_request_id             ,
      p_program_application_id    => p_qlp_program_application_id ,
      p_program_id                => p_qlp_program_id             ,
      p_program_update_date       => p_qlp_program_update_date    ,
      p_quote_header_id           => p_qlp_quote_header_id        ,
      p_quote_line_id             => p_qlp_quote_line_id          ,
      p_payment_type_code         => p_qlp_payment_type_code      ,
      p_payment_ref_number        => p_qlp_payment_ref_number     ,
      p_payment_option            => p_qlp_payment_option         ,
      p_payment_term_id           => p_qlp_payment_term_id        ,
      p_credit_card_code          => p_qlp_credit_card_code       ,
      p_credit_card_holder_name   => p_qlp_credit_card_holder_name,
      p_credit_card_exp_date      => p_qlp_credit_card_exp_date   ,
      p_credit_card_approval_code => p_qlp_credit_card_aprv_code  ,
      p_credit_card_approval_date => p_qlp_credit_card_aprv_date  ,
      p_payment_amount            => p_qlp_payment_amount         ,
      p_cust_po_number            => p_qlp_cust_po_number          ,
      p_attribute_category        => p_qlp_attribute_category     ,
      p_attribute1                => p_qlp_attribute1             ,
      p_attribute2                => p_qlp_attribute2             ,
      p_attribute3                => p_qlp_attribute3             ,
      p_attribute4                => p_qlp_attribute4             ,
      p_attribute5                => p_qlp_attribute5             ,
      p_attribute6                => p_qlp_attribute6             ,
      p_attribute7                => p_qlp_attribute7             ,
      p_attribute8                => p_qlp_attribute8             ,
      p_attribute9                => p_qlp_attribute9             ,
      p_attribute10               => p_qlp_attribute10            ,
      p_attribute11               => p_qlp_attribute11            ,
      p_attribute12               => p_qlp_attribute12            ,
      p_attribute13               => p_qlp_attribute13            ,
      p_attribute14               => p_qlp_attribute14            ,
      p_attribute15               => p_qlp_attribute15            ,
      p_assignment_id             => null                         ,
      p_cvv2                      => null);
    ELSE
        l_ln_Payment_Tbl := ASO_Quote_Pub.G_MISS_PAYMENT_TBL;
    END IF;

     IF p_qt_quote_header_id IS NOT NULL AND p_qt_quote_header_id.COUNT > 0 THEN
   -- set header tax detail
   l_hd_tax_detail_tbl := Construct_Tax_Detail_Tbl(
      p_operation_code         => p_qt_operation_code        ,
      p_qte_line_index         => p_qt_qte_line_index        ,
      p_shipment_index         => p_qt_shipment_index        ,
      p_tax_detail_id          => p_qt_tax_detail_id         ,
      p_quote_header_id        => p_qt_quote_header_id       ,
      p_quote_line_id          => p_qt_quote_line_id         ,
      p_quote_shipment_id      => p_qt_quote_shipment_id     ,
      p_creation_date          => p_qt_creation_date         ,
      p_created_by             => p_qt_created_by            ,
      p_last_update_date       => p_qt_last_update_date      ,
      p_last_updated_by        => p_qt_last_updated_by       ,
      p_last_update_login      => p_qt_last_update_login     ,
      p_request_id             => p_qt_request_id            ,
      p_program_application_id => p_qt_program_application_id,
      p_program_id             => p_qt_program_id            ,
      p_program_update_date    => p_qt_program_update_date   ,
      p_orig_tax_code          => p_qt_orig_tax_code         ,
      p_tax_code               => p_qt_tax_code              ,
      p_tax_rate               => p_qt_tax_rate              ,
      p_tax_date               => p_qt_tax_date              ,
      p_tax_amount             => p_qt_tax_amount            ,
      p_tax_exempt_flag        => p_qt_tax_exempt_flag       ,
      p_tax_exempt_number      => p_qt_tax_exempt_number     ,
      p_tax_exempt_reason_code => p_qt_tax_exempt_reason_code,
      p_attribute_category     => p_qt_attribute_category    ,
      p_attribute1             => p_qt_attribute1            ,
      p_attribute2             => p_qt_attribute2            ,
      p_attribute3             => p_qt_attribute3            ,
      p_attribute4             => p_qt_attribute4            ,
      p_attribute5             => p_qt_attribute5            ,
      p_attribute6             => p_qt_attribute6            ,
      p_attribute7             => p_qt_attribute7            ,
      p_attribute8             => p_qt_attribute8            ,
      p_attribute9             => p_qt_attribute9            ,
      p_attribute10            => p_qt_attribute10           ,
      p_attribute11            => p_qt_attribute11           ,
      p_attribute12            => p_qt_attribute12           ,
      p_attribute13            => p_qt_attribute13           ,
      p_attribute14            => p_qt_attribute14           ,
      p_attribute15            => p_qt_attribute15);
   ELSE
       l_Hd_Tax_Detail_Tbl := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl;
   END IF;

     IF p_qlt_quote_header_id IS NOT NULL AND p_qlt_quote_header_id.COUNT > 0 THEN
   -- set line tax detail
   l_ln_tax_detail_tbl := Construct_Tax_Detail_Tbl(
      p_operation_code         => p_qlt_operation_code        ,
      p_qte_line_index         => p_qlt_qte_line_index        ,
      p_shipment_index         => p_qlt_shipment_index        ,
      p_tax_detail_id          => p_qlt_tax_detail_id         ,
      p_quote_header_id        => p_qlt_quote_header_id       ,
      p_quote_line_id          => p_qlt_quote_line_id         ,
      p_quote_shipment_id      => p_qlt_quote_shipment_id     ,
      p_creation_date          => p_qlt_creation_date         ,
      p_created_by             => p_qlt_created_by            ,
      p_last_update_date       => p_qlt_last_update_date      ,
      p_last_updated_by        => p_qlt_last_updated_by       ,
      p_last_update_login      => p_qlt_last_update_login     ,
      p_request_id             => p_qlt_request_id            ,
      p_program_application_id => p_qlt_program_application_id,
      p_program_id             => p_qlt_program_id            ,
      p_program_update_date    => p_qlt_program_update_date   ,
      p_orig_tax_code          => p_qlt_orig_tax_code         ,
      p_tax_code               => p_qlt_tax_code              ,
      p_tax_rate               => p_qlt_tax_rate              ,
      p_tax_date               => p_qlt_tax_date              ,
      p_tax_amount             => p_qlt_tax_amount            ,
      p_tax_exempt_flag        => p_qlt_tax_exempt_flag       ,
      p_tax_exempt_number      => p_qlt_tax_exempt_number     ,
      p_tax_exempt_reason_code => p_qlt_tax_exempt_reason_code,
      p_attribute_category     => p_qlt_attribute_category    ,
      p_attribute1             => p_qlt_attribute1            ,
      p_attribute2             => p_qlt_attribute2            ,
      p_attribute3             => p_qlt_attribute3            ,
      p_attribute4             => p_qlt_attribute4            ,
      p_attribute5             => p_qlt_attribute5            ,
      p_attribute6             => p_qlt_attribute6            ,
      p_attribute7             => p_qlt_attribute7            ,
      p_attribute8             => p_qlt_attribute8            ,
      p_attribute9             => p_qlt_attribute9            ,
      p_attribute10            => p_qlt_attribute10           ,
      p_attribute11            => p_qlt_attribute11           ,
      p_attribute12            => p_qlt_attribute12           ,
      p_attribute13            => p_qlt_attribute13           ,
      p_attribute14            => p_qlt_attribute14           ,
      p_attribute15            => p_qlt_attribute15);
   ELSE
       l_ln_tax_detail_tbl := ASO_Quote_Pub.G_Miss_Tax_Detail_Tbl;
   END IF;

   IF p_qs_quote_header_id IS NOT NULL AND p_qs_quote_header_id.COUNT > 0 THEN
   -- set header shipment
   l_hd_shipment_tbl := Construct_Shipment_Tbl(
      p_operation_code         => p_qs_operation_code        ,
      p_qte_line_index         => p_qs_qte_line_index        ,
      p_shipment_id            => p_qs_shipment_id           ,
      p_creation_date          => p_qs_creation_date         ,
      p_created_by             => p_qs_created_by            ,
      p_last_update_date       => p_qs_last_update_date      ,
      p_last_updated_by        => p_qs_last_updated_by       ,
      p_last_update_login      => p_qs_last_update_login     ,
      p_request_id             => p_qs_request_id            ,
      p_program_application_id => p_qs_program_application_id,
      p_program_id             => p_qs_program_id            ,
      p_program_update_date    => p_qs_program_update_date   ,
      p_quote_header_id        => p_qs_quote_header_id       ,
      p_quote_line_id          => p_qs_quote_line_id         ,
      p_promise_date           => p_qs_promise_date          ,
      p_request_date           => p_qs_request_date          ,
      p_schedule_ship_date     => p_qs_schedule_ship_date    ,
      p_ship_to_party_site_id  => p_qs_ship_to_party_site_id ,
      p_ship_to_party_id       => p_qs_ship_to_party_id      ,
      p_ship_to_cust_acct_id   => p_qs_ship_to_cust_acct_id  ,
      p_ship_partial_flag      => p_qs_ship_partial_flag     ,
      p_ship_set_id            => p_qs_ship_set_id           ,
      p_ship_method_code       => p_qs_ship_method_code      ,
      p_freight_terms_code     => p_qs_freight_terms_code    ,
      p_freight_carrier_code   => p_qs_freight_carrier_code  ,
      p_fob_code               => p_qs_fob_code              ,
      p_shipment_priority_code => p_qs_shipment_priority_code,
      p_shipping_instructions  => p_qs_shipping_instructions ,
      p_packing_instructions   => p_qs_packing_instructions  ,
      p_quantity               => p_qs_quantity              ,
      p_reserved_quantity      => p_qs_reserved_quantity     ,
      p_reservation_id         => p_qs_reservation_id        ,
      p_order_line_id          => p_qs_order_line_id         ,
      p_ship_to_party_name     => p_qs_ship_to_party_name    ,
      p_ship_to_cont_fst_name  => p_qs_ship_to_cont_fst_name ,
      p_ship_to_cont_mid_name  => p_qs_ship_to_cont_mid_name ,
      p_ship_to_cont_lst_name  => p_qs_ship_to_cont_lst_name ,
      p_ship_to_address1       => p_qs_ship_to_address1      ,
      p_ship_to_address2       => p_qs_ship_to_address2      ,
      p_ship_to_address3       => p_qs_ship_to_address3      ,
      p_ship_to_address4       => p_qs_ship_to_address4      ,
      p_ship_to_country_code   => p_qs_ship_to_country_code  ,
      p_ship_to_country        => p_qs_ship_to_country       ,
      p_ship_to_city           => p_qs_ship_to_city          ,
      p_ship_to_postal_code    => p_qs_ship_to_postal_code   ,
      p_ship_to_state          => p_qs_ship_to_state         ,
      p_ship_to_province       => p_qs_ship_to_province      ,
      p_ship_to_county         => p_qs_ship_to_county        ,
      p_attribute_category     => p_qs_attribute_category    ,
      p_attribute1             => p_qs_attribute1            ,
      p_attribute2             => p_qs_attribute2            ,
      p_attribute3             => p_qs_attribute3            ,
      p_attribute4             => p_qs_attribute4            ,
      p_attribute5             => p_qs_attribute5            ,
      p_attribute6             => p_qs_attribute6            ,
      p_attribute7             => p_qs_attribute7            ,
      p_attribute8             => p_qs_attribute8            ,
      p_attribute9             => p_qs_attribute9            ,
      p_attribute10            => p_qs_attribute10           ,
      p_attribute11            => p_qs_attribute11           ,
      p_attribute12            => p_qs_attribute12           ,
      p_attribute13            => p_qs_attribute13           ,
      p_attribute14            => p_qs_attribute14           ,
      p_attribute15            => p_qs_attribute15);
    ELSE
      l_hd_shipment_tbl  := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL;
    END IF;

   IF p_qls_quote_header_id IS NOT NULL AND p_qls_quote_header_id.COUNT > 0 THEN
   -- set line shipment
   l_ln_shipment_tbl := Construct_Shipment_Tbl(
      p_operation_code         => p_qls_operation_code        ,
      p_qte_line_index         => p_qls_qte_line_index        ,
      p_shipment_id            => p_qls_shipment_id           ,
      p_creation_date          => p_qls_creation_date         ,
      p_created_by             => p_qls_created_by            ,
      p_last_update_date       => p_qls_last_update_date      ,
      p_last_updated_by        => p_qls_last_updated_by       ,
      p_last_update_login      => p_qls_last_update_login     ,
      p_request_id             => p_qls_request_id            ,
      p_program_application_id => p_qls_program_application_id,
      p_program_id             => p_qls_program_id            ,
      p_program_update_date    => p_qls_program_update_date   ,
      p_quote_header_id        => p_qls_quote_header_id       ,
      p_quote_line_id          => p_qls_quote_line_id         ,
      p_promise_date           => p_qls_promise_date          ,
      p_request_date           => p_qls_request_date          ,
      p_schedule_ship_date     => p_qls_schedule_ship_date    ,
      p_ship_to_party_site_id  => p_qls_ship_to_party_site_id ,
      p_ship_to_party_id       => p_qls_ship_to_party_id      ,
      p_ship_to_cust_acct_id   => p_qls_ship_to_cust_acct_id  ,
      p_ship_partial_flag      => p_qls_ship_partial_flag     ,
      p_ship_set_id            => p_qls_ship_set_id           ,
      p_ship_method_code       => p_qls_ship_method_code      ,
      p_freight_terms_code     => p_qls_freight_terms_code    ,
      p_freight_carrier_code   => p_qls_freight_carrier_code  ,
      p_fob_code               => p_qls_fob_code              ,
      p_shipment_priority_code => p_qls_shipment_priority_code,
      p_shipping_instructions  => p_qls_shipping_instructions ,
      p_packing_instructions   => p_qls_packing_instructions  ,
      p_quantity               => p_qls_quantity              ,
      p_reserved_quantity      => p_qls_reserved_quantity     ,
      p_reservation_id         => p_qls_reservation_id        ,
      p_order_line_id          => p_qls_order_line_id         ,
      p_ship_to_party_name     => p_qls_ship_to_party_name    ,
      p_ship_to_cont_fst_name  => p_qls_ship_to_cont_fst_name ,
      p_ship_to_cont_mid_name  => p_qls_ship_to_cont_mid_name ,
      p_ship_to_cont_lst_name  => p_qls_ship_to_cont_lst_name ,
      p_ship_to_address1       => p_qls_ship_to_address1      ,
      p_ship_to_address2       => p_qls_ship_to_address2      ,
      p_ship_to_address3       => p_qls_ship_to_address3      ,
      p_ship_to_address4       => p_qls_ship_to_address4      ,
      p_ship_to_country_code   => p_qls_ship_to_country_code  ,
      p_ship_to_country        => p_qls_ship_to_country       ,
      p_ship_to_city           => p_qls_ship_to_city          ,
      p_ship_to_postal_code    => p_qls_ship_to_postal_code   ,
      p_ship_to_state          => p_qls_ship_to_state         ,
      p_ship_to_province       => p_qls_ship_to_province      ,
      p_ship_to_county         => p_qls_ship_to_county        ,
      p_attribute_category     => p_qls_attribute_category    ,
      p_attribute1             => p_qls_attribute1            ,
      p_attribute2             => p_qls_attribute2            ,
      p_attribute3             => p_qls_attribute3            ,
      p_attribute4             => p_qls_attribute4            ,
      p_attribute5             => p_qls_attribute5            ,
      p_attribute6             => p_qls_attribute6            ,
      p_attribute7             => p_qls_attribute7            ,
      p_attribute8             => p_qls_attribute8            ,
      p_attribute9             => p_qls_attribute9            ,
      p_attribute10            => p_qls_attribute10           ,
      p_attribute11            => p_qls_attribute11           ,
      p_attribute12            => p_qls_attribute12           ,
      p_attribute13            => p_qls_attribute13           ,
      p_attribute14            => p_qls_attribute14           ,
      p_attribute15            => p_qls_attribute15);
    ELSE
      l_ln_shipment_tbl  := ASO_Quote_Pub.G_MISS_SHIPMENT_TBL;
    END IF;

   IF p_qpa_operation_code IS NOT NULL AND p_qpa_operation_code.COUNT >0 THEN
   -- set header price attribute
   l_hd_price_attributes_tbl := Construct_Price_Attributes_Tbl(
      p_operation_code         => p_qpa_operation_code        ,
      p_qte_line_index         => p_qpa_qte_line_index        ,
      p_price_attribute_id     => p_qpa_price_attribute_id    ,
      p_creation_date          => p_qpa_creation_date         ,
      p_created_by             => p_qpa_created_by            ,
      p_last_update_date       => p_qpa_last_update_date      ,
      p_last_updated_by        => p_qpa_last_updated_by       ,
      p_last_update_login      => p_qpa_last_update_login     ,
      p_request_id             => p_qpa_request_id            ,
      p_program_application_id => p_qpa_program_application_id,
      p_program_id             => p_qpa_program_id            ,
      p_program_update_date    => p_qpa_program_update_date   ,
      p_quote_header_id        => p_qpa_quote_header_id       ,
      p_quote_line_id          => p_qpa_quote_line_id         ,
      p_flex_title             => p_qpa_flex_title            ,
      p_pricing_context        => p_qpa_pricing_context       ,
      p_pricing_attribute1     => p_qpa_pricing_attribute1    ,
      p_pricing_attribute2     => p_qpa_pricing_attribute2    ,
      p_pricing_attribute3     => p_qpa_pricing_attribute3    ,
      p_pricing_attribute4     => p_qpa_pricing_attribute4    ,
      p_pricing_attribute5     => p_qpa_pricing_attribute5    ,
      p_pricing_attribute6     => p_qpa_pricing_attribute6    ,
      p_pricing_attribute7     => p_qpa_pricing_attribute7    ,
      p_pricing_attribute8     => p_qpa_pricing_attribute8    ,
      p_pricing_attribute9     => p_qpa_pricing_attribute9    ,
      p_pricing_attribute10    => p_qpa_pricing_attribute10   ,
      p_pricing_attribute11    => p_qpa_pricing_attribute11   ,
      p_pricing_attribute12    => p_qpa_pricing_attribute12   ,
      p_pricing_attribute13    => p_qpa_pricing_attribute13   ,
      p_pricing_attribute14    => p_qpa_pricing_attribute14   ,
      p_pricing_attribute15    => p_qpa_pricing_attribute15   ,
      p_pricing_attribute16    => p_qpa_pricing_attribute16   ,
      p_pricing_attribute17    => p_qpa_pricing_attribute17   ,
      p_pricing_attribute18    => p_qpa_pricing_attribute18   ,
      p_pricing_attribute19    => p_qpa_pricing_attribute19   ,
      p_pricing_attribute20    => p_qpa_pricing_attribute20   ,
      p_pricing_attribute21    => p_qpa_pricing_attribute21   ,
      p_pricing_attribute22    => p_qpa_pricing_attribute22   ,
      p_pricing_attribute23    => p_qpa_pricing_attribute23   ,
      p_pricing_attribute24    => p_qpa_pricing_attribute24   ,
      p_pricing_attribute25    => p_qpa_pricing_attribute25   ,
      p_pricing_attribute26    => p_qpa_pricing_attribute26   ,
      p_pricing_attribute27    => p_qpa_pricing_attribute27   ,
      p_pricing_attribute28    => p_qpa_pricing_attribute28   ,
      p_pricing_attribute29    => p_qpa_pricing_attribute29   ,
      p_pricing_attribute30    => p_qpa_pricing_attribute30   ,
      p_pricing_attribute31    => p_qpa_pricing_attribute31   ,
      p_pricing_attribute32    => p_qpa_pricing_attribute32   ,
      p_pricing_attribute33    => p_qpa_pricing_attribute33   ,
      p_pricing_attribute34    => p_qpa_pricing_attribute34   ,
      p_pricing_attribute35    => p_qpa_pricing_attribute35   ,
      p_pricing_attribute36    => p_qpa_pricing_attribute36   ,
      p_pricing_attribute37    => p_qpa_pricing_attribute37   ,
      p_pricing_attribute38    => p_qpa_pricing_attribute38   ,
      p_pricing_attribute39    => p_qpa_pricing_attribute39   ,
      p_pricing_attribute40    => p_qpa_pricing_attribute40   ,
      p_pricing_attribute41    => p_qpa_pricing_attribute41   ,
      p_pricing_attribute42    => p_qpa_pricing_attribute42   ,
      p_pricing_attribute43    => p_qpa_pricing_attribute43   ,
      p_pricing_attribute44    => p_qpa_pricing_attribute44   ,
      p_pricing_attribute45    => p_qpa_pricing_attribute45   ,
      p_pricing_attribute46    => p_qpa_pricing_attribute46   ,
      p_pricing_attribute47    => p_qpa_pricing_attribute47   ,
      p_pricing_attribute48    => p_qpa_pricing_attribute48   ,
      p_pricing_attribute49    => p_qpa_pricing_attribute49   ,
      p_pricing_attribute50    => p_qpa_pricing_attribute50   ,
      p_pricing_attribute51    => p_qpa_pricing_attribute51   ,
      p_pricing_attribute52    => p_qpa_pricing_attribute52   ,
      p_pricing_attribute53    => p_qpa_pricing_attribute53   ,
      p_pricing_attribute54    => p_qpa_pricing_attribute54   ,
      p_pricing_attribute55    => p_qpa_pricing_attribute55   ,
      p_pricing_attribute56    => p_qpa_pricing_attribute56   ,
      p_pricing_attribute57    => p_qpa_pricing_attribute57   ,
      p_pricing_attribute58    => p_qpa_pricing_attribute58   ,
      p_pricing_attribute59    => p_qpa_pricing_attribute59   ,
      p_pricing_attribute60    => p_qpa_pricing_attribute60   ,
      p_pricing_attribute61    => p_qpa_pricing_attribute61   ,
      p_pricing_attribute62    => p_qpa_pricing_attribute62   ,
      p_pricing_attribute63    => p_qpa_pricing_attribute63   ,
      p_pricing_attribute64    => p_qpa_pricing_attribute64   ,
      p_pricing_attribute65    => p_qpa_pricing_attribute65   ,
      p_pricing_attribute66    => p_qpa_pricing_attribute66   ,
      p_pricing_attribute67    => p_qpa_pricing_attribute67   ,
      p_pricing_attribute68    => p_qpa_pricing_attribute68   ,
      p_pricing_attribute69    => p_qpa_pricing_attribute69   ,
      p_pricing_attribute70    => p_qpa_pricing_attribute70   ,
      p_pricing_attribute71    => p_qpa_pricing_attribute71   ,
      p_pricing_attribute72    => p_qpa_pricing_attribute72   ,
      p_pricing_attribute73    => p_qpa_pricing_attribute73   ,
      p_pricing_attribute74    => p_qpa_pricing_attribute74   ,
      p_pricing_attribute75    => p_qpa_pricing_attribute75   ,
      p_pricing_attribute76    => p_qpa_pricing_attribute76   ,
      p_pricing_attribute77    => p_qpa_pricing_attribute77   ,
      p_pricing_attribute78    => p_qpa_pricing_attribute78   ,
      p_pricing_attribute79    => p_qpa_pricing_attribute79   ,
      p_pricing_attribute80    => p_qpa_pricing_attribute80   ,
      p_pricing_attribute81    => p_qpa_pricing_attribute81   ,
      p_pricing_attribute82    => p_qpa_pricing_attribute82   ,
      p_pricing_attribute83    => p_qpa_pricing_attribute83   ,
      p_pricing_attribute84    => p_qpa_pricing_attribute84   ,
      p_pricing_attribute85    => p_qpa_pricing_attribute85   ,
      p_pricing_attribute86    => p_qpa_pricing_attribute86   ,
      p_pricing_attribute87    => p_qpa_pricing_attribute87   ,
      p_pricing_attribute88    => p_qpa_pricing_attribute88   ,
      p_pricing_attribute89    => p_qpa_pricing_attribute89   ,
      p_pricing_attribute90    => p_qpa_pricing_attribute90   ,
      p_pricing_attribute91    => p_qpa_pricing_attribute91   ,
      p_pricing_attribute92    => p_qpa_pricing_attribute92   ,
      p_pricing_attribute93    => p_qpa_pricing_attribute93   ,
      p_pricing_attribute94    => p_qpa_pricing_attribute94   ,
      p_pricing_attribute95    => p_qpa_pricing_attribute95   ,
      p_pricing_attribute96    => p_qpa_pricing_attribute96   ,
      p_pricing_attribute97    => p_qpa_pricing_attribute97   ,
      p_pricing_attribute98    => p_qpa_pricing_attribute98   ,
      p_pricing_attribute99    => p_qpa_pricing_attribute99   ,
      p_pricing_attribute100   => p_qpa_pricing_attribute100  ,
      p_context                => p_qpa_context               ,
      p_attribute1             => p_qpa_attribute1            ,
      p_attribute2             => p_qpa_attribute2            ,
      p_attribute3             => p_qpa_attribute3            ,
      p_attribute4             => p_qpa_attribute4            ,
      p_attribute5             => p_qpa_attribute5            ,
      p_attribute6             => p_qpa_attribute6            ,
      p_attribute7             => p_qpa_attribute7            ,
      p_attribute8             => p_qpa_attribute8            ,
      p_attribute9             => p_qpa_attribute9            ,
      p_attribute10            => p_qpa_attribute10           ,
      p_attribute11            => p_qpa_attribute11           ,
      p_attribute12            => p_qpa_attribute12           ,
      p_attribute13            => p_qpa_attribute13           ,
      p_attribute14            => p_qpa_attribute14           ,
      p_attribute15            => p_qpa_attribute15);
   ELSE
     l_hd_price_attributes_tbl  := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl;
   END IF;

   IF p_qlpa_operation_code IS NOT NULL AND p_qlpa_operation_code.COUNT > 0 THEN
   -- set line price attribute
   l_ln_price_attributes_tbl := Construct_Price_Attributes_Tbl(
      p_operation_code         => p_qlpa_operation_code        ,
      p_qte_line_index         => p_qlpa_qte_line_index        ,
      p_price_attribute_id     => p_qlpa_price_attribute_id    ,
      p_creation_date          => p_qlpa_creation_date         ,
      p_created_by             => p_qlpa_created_by            ,
      p_last_update_date       => p_qlpa_last_update_date      ,
      p_last_updated_by        => p_qlpa_last_updated_by       ,
      p_last_update_login      => p_qlpa_last_update_login     ,
      p_request_id             => p_qlpa_request_id            ,
      p_program_application_id => p_qlpa_program_application_id,
      p_program_id             => p_qlpa_program_id            ,
      p_program_update_date    => p_qlpa_program_update_date   ,
      p_quote_header_id        => p_qlpa_quote_header_id       ,
      p_quote_line_id          => p_qlpa_quote_line_id         ,
      p_flex_title             => p_qlpa_flex_title            ,
      p_pricing_context        => p_qlpa_pricing_context       ,
      p_pricing_attribute1     => p_qlpa_pricing_attribute1    ,
      p_pricing_attribute2     => p_qlpa_pricing_attribute2    ,
      p_pricing_attribute3     => p_qlpa_pricing_attribute3    ,
      p_pricing_attribute4     => p_qlpa_pricing_attribute4    ,
      p_pricing_attribute5     => p_qlpa_pricing_attribute5    ,
      p_pricing_attribute6     => p_qlpa_pricing_attribute6    ,
      p_pricing_attribute7     => p_qlpa_pricing_attribute7    ,
      p_pricing_attribute8     => p_qlpa_pricing_attribute8    ,
      p_pricing_attribute9     => p_qlpa_pricing_attribute9    ,
      p_pricing_attribute10    => p_qlpa_pricing_attribute10   ,
      p_pricing_attribute11    => p_qlpa_pricing_attribute11   ,
      p_pricing_attribute12    => p_qlpa_pricing_attribute12   ,
      p_pricing_attribute13    => p_qlpa_pricing_attribute13   ,
      p_pricing_attribute14    => p_qlpa_pricing_attribute14   ,
      p_pricing_attribute15    => p_qlpa_pricing_attribute15   ,
      p_pricing_attribute16    => p_qlpa_pricing_attribute16   ,
      p_pricing_attribute17    => p_qlpa_pricing_attribute17   ,
      p_pricing_attribute18    => p_qlpa_pricing_attribute18   ,
      p_pricing_attribute19    => p_qlpa_pricing_attribute19   ,
      p_pricing_attribute20    => p_qlpa_pricing_attribute20   ,
      p_pricing_attribute21    => p_qlpa_pricing_attribute21   ,
      p_pricing_attribute22    => p_qlpa_pricing_attribute22   ,
      p_pricing_attribute23    => p_qlpa_pricing_attribute23   ,
      p_pricing_attribute24    => p_qlpa_pricing_attribute24   ,
      p_pricing_attribute25    => p_qlpa_pricing_attribute25   ,
      p_pricing_attribute26    => p_qlpa_pricing_attribute26   ,
      p_pricing_attribute27    => p_qlpa_pricing_attribute27   ,
      p_pricing_attribute28    => p_qlpa_pricing_attribute28   ,
      p_pricing_attribute29    => p_qlpa_pricing_attribute29   ,
      p_pricing_attribute30    => p_qlpa_pricing_attribute30   ,
      p_pricing_attribute31    => p_qlpa_pricing_attribute31   ,
      p_pricing_attribute32    => p_qlpa_pricing_attribute32   ,
      p_pricing_attribute33    => p_qlpa_pricing_attribute33   ,
      p_pricing_attribute34    => p_qlpa_pricing_attribute34   ,
      p_pricing_attribute35    => p_qlpa_pricing_attribute35   ,
      p_pricing_attribute36    => p_qlpa_pricing_attribute36   ,
      p_pricing_attribute37    => p_qlpa_pricing_attribute37   ,
      p_pricing_attribute38    => p_qlpa_pricing_attribute38   ,
      p_pricing_attribute39    => p_qlpa_pricing_attribute39   ,
      p_pricing_attribute40    => p_qlpa_pricing_attribute40   ,
      p_pricing_attribute41    => p_qlpa_pricing_attribute41   ,
      p_pricing_attribute42    => p_qlpa_pricing_attribute42   ,
      p_pricing_attribute43    => p_qlpa_pricing_attribute43   ,
      p_pricing_attribute44    => p_qlpa_pricing_attribute44   ,
      p_pricing_attribute45    => p_qlpa_pricing_attribute45   ,
      p_pricing_attribute46    => p_qlpa_pricing_attribute46   ,
      p_pricing_attribute47    => p_qlpa_pricing_attribute47   ,
      p_pricing_attribute48    => p_qlpa_pricing_attribute48   ,
      p_pricing_attribute49    => p_qlpa_pricing_attribute49   ,
      p_pricing_attribute50    => p_qlpa_pricing_attribute50   ,
      p_pricing_attribute51    => p_qlpa_pricing_attribute51   ,
      p_pricing_attribute52    => p_qlpa_pricing_attribute52   ,
      p_pricing_attribute53    => p_qlpa_pricing_attribute53   ,
      p_pricing_attribute54    => p_qlpa_pricing_attribute54   ,
      p_pricing_attribute55    => p_qlpa_pricing_attribute55   ,
      p_pricing_attribute56    => p_qlpa_pricing_attribute56   ,
      p_pricing_attribute57    => p_qlpa_pricing_attribute57   ,
      p_pricing_attribute58    => p_qlpa_pricing_attribute58   ,
      p_pricing_attribute59    => p_qlpa_pricing_attribute59   ,
      p_pricing_attribute60    => p_qlpa_pricing_attribute60   ,
      p_pricing_attribute61    => p_qlpa_pricing_attribute61   ,
      p_pricing_attribute62    => p_qlpa_pricing_attribute62   ,
      p_pricing_attribute63    => p_qlpa_pricing_attribute63   ,
      p_pricing_attribute64    => p_qlpa_pricing_attribute64   ,
      p_pricing_attribute65    => p_qlpa_pricing_attribute65   ,
      p_pricing_attribute66    => p_qlpa_pricing_attribute66   ,
      p_pricing_attribute67    => p_qlpa_pricing_attribute67   ,
      p_pricing_attribute68    => p_qlpa_pricing_attribute68   ,
      p_pricing_attribute69    => p_qlpa_pricing_attribute69   ,
      p_pricing_attribute70    => p_qlpa_pricing_attribute70   ,
      p_pricing_attribute71    => p_qlpa_pricing_attribute71   ,
      p_pricing_attribute72    => p_qlpa_pricing_attribute72   ,
      p_pricing_attribute73    => p_qlpa_pricing_attribute73   ,
      p_pricing_attribute74    => p_qlpa_pricing_attribute74   ,
      p_pricing_attribute75    => p_qlpa_pricing_attribute75   ,
      p_pricing_attribute76    => p_qlpa_pricing_attribute76   ,
      p_pricing_attribute77    => p_qlpa_pricing_attribute77   ,
      p_pricing_attribute78    => p_qlpa_pricing_attribute78   ,
      p_pricing_attribute79    => p_qlpa_pricing_attribute79   ,
      p_pricing_attribute80    => p_qlpa_pricing_attribute80   ,
      p_pricing_attribute81    => p_qlpa_pricing_attribute81   ,
      p_pricing_attribute82    => p_qlpa_pricing_attribute82   ,
      p_pricing_attribute83    => p_qlpa_pricing_attribute83   ,
      p_pricing_attribute84    => p_qlpa_pricing_attribute84   ,
      p_pricing_attribute85    => p_qlpa_pricing_attribute85   ,
      p_pricing_attribute86    => p_qlpa_pricing_attribute86   ,
      p_pricing_attribute87    => p_qlpa_pricing_attribute87   ,
      p_pricing_attribute88    => p_qlpa_pricing_attribute88   ,
      p_pricing_attribute89    => p_qlpa_pricing_attribute89   ,
      p_pricing_attribute90    => p_qlpa_pricing_attribute90   ,
      p_pricing_attribute91    => p_qlpa_pricing_attribute91   ,
      p_pricing_attribute92    => p_qlpa_pricing_attribute92   ,
      p_pricing_attribute93    => p_qlpa_pricing_attribute93   ,
      p_pricing_attribute94    => p_qlpa_pricing_attribute94   ,
      p_pricing_attribute95    => p_qlpa_pricing_attribute95   ,
      p_pricing_attribute96    => p_qlpa_pricing_attribute96   ,
      p_pricing_attribute97    => p_qlpa_pricing_attribute97   ,
      p_pricing_attribute98    => p_qlpa_pricing_attribute98   ,
      p_pricing_attribute99    => p_qlpa_pricing_attribute99   ,
      p_pricing_attribute100   => p_qlpa_pricing_attribute100  ,
      p_context                => p_qlpa_context               ,
      p_attribute1             => p_qlpa_attribute1            ,
      p_attribute2             => p_qlpa_attribute2            ,
      p_attribute3             => p_qlpa_attribute3            ,
      p_attribute4             => p_qlpa_attribute4            ,
      p_attribute5             => p_qlpa_attribute5            ,
      p_attribute6             => p_qlpa_attribute6            ,
      p_attribute7             => p_qlpa_attribute7            ,
      p_attribute8             => p_qlpa_attribute8            ,
      p_attribute9             => p_qlpa_attribute9            ,
      p_attribute10            => p_qlpa_attribute10           ,
      p_attribute11            => p_qlpa_attribute11           ,
      p_attribute12            => p_qlpa_attribute12           ,
      p_attribute13            => p_qlpa_attribute13           ,
      p_attribute14            => p_qlpa_attribute14           ,
      p_attribute15            => p_qlpa_attribute15);
   ELSE
     l_ln_price_attributes_tbl  := ASO_Quote_Pub.G_Miss_Price_Attributes_Tbl;
   END IF;

   IF p_qfc_operation_code IS NOT NULL AND p_qfc_operation_code.COUNT > 0 THEN
   -- set header freight charge
   l_hd_freight_charge_tbl := Construct_Freight_Charge_Tbl(
      p_operation_code         => p_qfc_operation_code        ,
      p_qte_line_index         => p_qfc_qte_line_index        ,
      p_shipment_index         => p_qfc_shipment_index        ,
      p_freight_charge_id      => p_qfc_freight_charge_id     ,
      p_last_update_date       => p_qfc_last_update_date      ,
      p_last_updated_by        => p_qfc_last_updated_by       ,
      p_creation_date          => p_qfc_creation_date         ,
      p_created_by             => p_qfc_created_by            ,
      p_last_update_login      => p_qfc_last_update_login     ,
      p_program_application_id => p_qfc_program_application_id,
      p_program_id             => p_qfc_program_id            ,
      p_program_update_date    => p_qfc_program_update_date   ,
      p_request_id             => p_qfc_request_id            ,
      p_quote_shipment_id      => p_qfc_quote_shipment_id     ,
      p_quote_line_id          => p_qfc_quote_line_id         ,
      p_freight_charge_type_id => p_qfc_freight_charge_type_id,
      p_charge_amount          => p_qfc_charge_amount         ,
      p_attribute_category     => p_qfc_attribute_category    ,
      p_attribute1             => p_qfc_attribute1            ,
      p_attribute2             => p_qfc_attribute2            ,
      p_attribute3             => p_qfc_attribute3            ,
      p_attribute4             => p_qfc_attribute4            ,
      p_attribute5             => p_qfc_attribute5            ,
      p_attribute6             => p_qfc_attribute6            ,
      p_attribute7             => p_qfc_attribute7            ,
      p_attribute8             => p_qfc_attribute8            ,
      p_attribute9             => p_qfc_attribute9            ,
      p_attribute10            => p_qfc_attribute10           ,
      p_attribute11            => p_qfc_attribute11           ,
      p_attribute12            => p_qfc_attribute12           ,
      p_attribute13            => p_qfc_attribute13           ,
      p_attribute14            => p_qfc_attribute14           ,
      p_attribute15            => p_qfc_attribute15);
   ELSE
     l_hd_freight_charge_tbl  := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl;
   END IF;

    IF p_qlfc_operation_code IS NOT NULL AND p_qlfc_operation_code.COUNT > 0 THEN
   -- set line freight charge
   l_ln_freight_charge_tbl := Construct_Freight_Charge_Tbl(
      p_operation_code         => p_qlfc_operation_code        ,
      p_qte_line_index         => p_qlfc_qte_line_index        ,
      p_shipment_index         => p_qlfc_shipment_index        ,
      p_freight_charge_id      => p_qlfc_freight_charge_id     ,
      p_last_update_date       => p_qlfc_last_update_date      ,
      p_last_updated_by        => p_qlfc_last_updated_by       ,
      p_creation_date          => p_qlfc_creation_date         ,
      p_created_by             => p_qlfc_created_by            ,
      p_last_update_login      => p_qlfc_last_update_login     ,
      p_program_application_id => p_qlfc_program_application_id,
      p_program_id             => p_qlfc_program_id            ,
      p_program_update_date    => p_qlfc_program_update_date   ,
      p_request_id             => p_qlfc_request_id            ,
      p_quote_shipment_id      => p_qlfc_quote_shipment_id     ,
      p_quote_line_id          => p_qlfc_quote_line_id         ,
      p_freight_charge_type_id => p_qlfc_freight_charge_type_id,
      p_charge_amount          => p_qlfc_charge_amount         ,
      p_attribute_category     => p_qlfc_attribute_category    ,
      p_attribute1             => p_qlfc_attribute1            ,
      p_attribute2             => p_qlfc_attribute2            ,
      p_attribute3             => p_qlfc_attribute3            ,
      p_attribute4             => p_qlfc_attribute4            ,
      p_attribute5             => p_qlfc_attribute5            ,
      p_attribute6             => p_qlfc_attribute6            ,
      p_attribute7             => p_qlfc_attribute7            ,
      p_attribute8             => p_qlfc_attribute8            ,
      p_attribute9             => p_qlfc_attribute9            ,
      p_attribute10            => p_qlfc_attribute10           ,
      p_attribute11            => p_qlfc_attribute11           ,
      p_attribute12            => p_qlfc_attribute12           ,
      p_attribute13            => p_qlfc_attribute13           ,
      p_attribute14            => p_qlfc_attribute14           ,
      p_attribute15            => p_qlfc_attribute15);
   ELSE
     l_ln_freight_charge_tbl  := ASO_Quote_Pub.G_Miss_Freight_Charge_Tbl;
   END IF;


   IF p_qlae_operation_code IS NOT NULL AND p_qlae_operation_code.COUNT>0 THEN
     -- set line attribute exts
   l_line_attr_ext_tbl := Construct_Line_Attribs_Ext_Tbl(
      p_qte_line_index         => p_qlae_qte_line_index        ,
      p_shipment_index         => p_qlae_shipment_index        ,
      p_line_attribute_id      => p_qlae_line_attribute_id     ,
      p_creation_date          => p_qlae_creation_date         ,
      p_created_by             => p_qlae_created_by            ,
      p_last_update_date       => p_qlae_last_update_date      ,
      p_last_updated_by        => p_qlae_last_updated_by       ,
      p_last_update_login      => p_qlae_last_update_login     ,
      p_request_id             => p_qlae_request_id            ,
      p_program_application_id => p_qlae_program_application_id,
      p_program_id             => p_qlae_program_id            ,
      p_program_update_date    => p_qlae_program_update_date   ,
      p_quote_header_id        => p_qlae_quote_header_id       ,
      p_quote_line_id          => p_qlae_quote_line_id         ,
      p_quote_shipment_id      => p_qlae_quote_shipment_id     ,
      p_attribute_type_code    => p_qlae_attribute_type_code   ,
      p_name                   => p_qlae_name                  ,
      p_value                  => p_qlae_value                 ,
      p_value_type             => p_qlae_value_type            ,
      p_status                 => p_qlae_status                ,
      p_application_id         => p_qlae_application_id        ,
      p_start_date_active      => p_qlae_start_date_active     ,
      p_end_date_active        => p_qlae_end_date_active       ,
      p_operation_code         => p_qlae_operation_code);
    ELSE
      l_line_attr_ext_tbl := ASO_Quote_Pub.G_MISS_Line_Attribs_Ext_TBL;
    END IF;

   IF p_qlpaa_operation_code IS NOT NULL AND p_qlpaa_operation_code.COUNT > 0 THEN
   -- set price adjustment attribute
   l_price_adj_attr_tbl := Construct_Price_Adj_Attr_Tbl(
      p_operation_code         => p_qlpaa_operation_code        ,
      p_qte_line_index         => p_qlpaa_qte_line_index        ,
      p_price_adj_index        => p_qlpaa_price_adj_index       ,
      p_price_adj_attrib_id    => p_qlpaa_price_adj_attrib_id   ,
      p_creation_date          => p_qlpaa_creation_date         ,
      p_created_by             => p_qlpaa_created_by            ,
      p_last_update_date       => p_qlpaa_last_update_date      ,
      p_last_updated_by        => p_qlpaa_last_updated_by       ,
      p_last_update_login      => p_qlpaa_last_update_login     ,
      p_program_application_id => p_qlpaa_program_application_id,
      p_program_id             => p_qlpaa_program_id            ,
      p_program_update_date    => p_qlpaa_program_update_date   ,
      p_request_id             => p_qlpaa_request_id            ,
      p_price_adjustment_id    => p_qlpaa_price_adjustment_id   ,
      p_pricing_context        => p_qlpaa_pricing_context       ,
      p_pricing_attribute      => p_qlpaa_pricing_attribute     ,
      p_prc_attr_value_from    => p_qlpaa_prc_attr_value_from   ,
      p_pricing_attr_value_to  => p_qlpaa_pricing_attr_value_to ,
      p_comparison_operator    => p_qlpaa_comparison_operator   ,
      p_flex_title             => p_qlpaa_flex_title);
   ELSE
      l_price_adj_attr_tbl   := ASO_Quote_Pub.G_Miss_PRICE_ADJ_ATTR_Tbl;
   END IF;

   IF p_qlpaj_operation_code IS NOT NULL AND p_qlpaj_operation_code.COUNT > 0 THEN
   -- set price adjustment tbl
   l_price_adjustment_tbl := Construct_Price_Adj_Tbl(
      p_operation_code         => p_qlpaj_operation_code        ,
      p_qte_line_index         => p_qlpaj_qte_line_index        ,
      p_price_adjustment_id    => p_qlpaj_price_adjustment_id   ,
      p_creation_date          => p_qlpaj_creation_date         ,
      p_created_by             => p_qlpaj_created_by            ,
      p_last_update_date       => p_qlpaj_last_update_date      ,
      p_last_updated_by        => p_qlpaj_last_updated_by       ,
      p_last_update_login      => p_qlpaj_last_update_login     ,
      p_program_application_id => p_qlpaj_program_application_id,
      p_program_id             => p_qlpaj_program_id            ,
      p_program_update_date    => p_qlpaj_program_update_date   ,
      p_request_id             => p_qlpaj_request_id            ,
      p_quote_header_id        => p_qlpaj_quote_header_id       ,
      p_quote_line_id          => p_qlpaj_quote_line_id         ,
      p_modifier_header_id     => p_qlpaj_modifier_header_id    ,
      p_modifier_line_id       => p_qlpaj_modifier_line_id      ,
      p_mod_line_type_code     => p_qlpaj_mod_line_type_code    ,
      p_mod_mech_type_code     => p_qlpaj_mod_mech_type_code    ,
      p_modified_from          => p_qlpaj_modified_from         ,
      p_modified_to            => p_qlpaj_modified_to           ,
      p_operand                => p_qlpaj_operand               ,
      p_arithmetic_operator    => p_qlpaj_arithmetic_operator   ,
      p_automatic_flag         => p_qlpaj_automatic_flag        ,
      p_update_allowable_flag  => p_qlpaj_update_allowable_flag ,
      p_updated_flag           => p_qlpaj_updated_flag          ,
      p_applied_flag           => p_qlpaj_applied_flag          ,
      p_on_invoice_flag        => p_qlpaj_on_invoice_flag       ,
      p_pricing_phase_id       => p_qlpaj_pricing_phase_id      ,
      p_attribute_category     => p_qlpaj_attribute_category    ,
      p_attribute1             => p_qlpaj_attribute1            ,
      p_attribute2             => p_qlpaj_attribute2            ,
      p_attribute3             => p_qlpaj_attribute3            ,
      p_attribute4             => p_qlpaj_attribute4            ,
      p_attribute5             => p_qlpaj_attribute5            ,
      p_attribute6             => p_qlpaj_attribute6            ,
      p_attribute7             => p_qlpaj_attribute7            ,
      p_attribute8             => p_qlpaj_attribute8            ,
      p_attribute9             => p_qlpaj_attribute9            ,
      p_attribute10            => p_qlpaj_attribute10           ,
      p_attribute11            => p_qlpaj_attribute11           ,
      p_attribute12            => p_qlpaj_attribute12           ,
      p_attribute13            => p_qlpaj_attribute13           ,
      p_attribute14            => p_qlpaj_attribute14           ,
      p_attribute15            => p_qlpaj_attribute15           ,
      p_orig_sys_discount_ref  => p_qlpaj_orig_sys_discount_ref ,
      p_change_sequence        => p_qlpaj_change_sequence       ,
      p_update_allowed         => p_qlpaj_update_allowed        ,
      p_change_reason_code     => p_qlpaj_change_reason_code    ,
      p_change_reason_text     => p_qlpaj_change_reason_text    ,
      p_cost_id                => p_qlpaj_cost_id               ,
      p_tax_code               => p_qlpaj_tax_code              ,
      p_tax_exempt_flag        => p_qlpaj_tax_exempt_flag       ,
      p_tax_exempt_number      => p_qlpaj_tax_exempt_number     ,
      p_tax_exempt_reason_code => p_qlpaj_tax_exempt_reason_code,
      p_parent_adjustment_id   => p_qlpaj_parent_adjustment_id  ,
      p_invoiced_flag          => p_qlpaj_invoiced_flag         ,
      p_estimated_flag         => p_qlpaj_estimated_flag        ,
      p_inc_in_sales_perfce    => p_qlpaj_inc_in_sales_perfce   ,
      p_split_action_code      => p_qlpaj_split_action_code     ,
      p_adjusted_amount        => p_qlpaj_adjusted_amount       ,
      p_charge_type_code       => p_qlpaj_charge_type_code      ,
      p_charge_subtype_code    => p_qlpaj_charge_subtype_code   ,
      p_range_break_quantity   => p_qlpaj_range_break_quantity  ,
      p_accrual_conv_rate      => p_qlpaj_accrual_conv_rate     ,
      p_pricing_group_sequence => p_qlpaj_pricing_group_sequence,
      p_accrual_flag           => p_qlpaj_accrual_flag          ,
      p_list_line_no           => p_qlpaj_list_line_no          ,
      p_source_system_code     => p_qlpaj_source_system_code    ,
      p_benefit_qty            => p_qlpaj_benefit_qty           ,
      p_benefit_uom_code       => p_qlpaj_benefit_uom_code      ,
      p_print_on_invoice_flag  => p_qlpaj_print_on_invoice_flag ,
      p_expiration_date        => p_qlpaj_expiration_date       ,
      p_rebate_trans_type_code => p_qlpaj_rebate_trans_type_code,
      p_rebate_trans_reference => p_qlpaj_rebate_trans_reference,
      p_rebate_pay_system_code => p_qlpaj_rebate_pay_system_code,
      p_redeemed_date          => p_qlpaj_redeemed_date         ,
      p_redeemed_flag          => p_qlpaj_redeemed_flag         ,
      p_modifier_level_code    => p_qlpaj_modifier_level_code   ,
      p_price_break_type_code  => p_qlpaj_price_break_type_code ,
      p_substitution_attribute => p_qlpaj_substitution_attribute,
      p_proration_type_code    => p_qlpaj_proration_type_code   ,
      p_include_on_ret_flag    => p_qlpaj_include_on_ret_flag   ,
      p_credit_or_charge_flag  => p_qlpaj_credit_or_charge_flag);
   ELSE
      l_price_adjustment_tbl := ASO_Quote_Pub.G_Miss_Price_Adj_Tbl;
   END IF;

   IF p_qlpar_operation_code IS NOT NULL AND p_qlpar_operation_code.COUNT > 0 THEN
   -- set price adjustment relationship tbl
   l_price_adj_rltship_tbl := Construct_Price_Adj_Rel_Tbl(
      p_operation_code         => p_qlpar_operation_code        ,
      p_adj_relationship_id    => p_qlpar_adj_relationship_id   ,
      p_creation_date          => p_qlpar_creation_date         ,
      p_created_by             => p_qlpar_created_by            ,
      p_last_update_date       => p_qlpar_last_update_date      ,
      p_last_updated_by        => p_qlpar_last_updated_by       ,
      p_last_update_login      => p_qlpar_last_update_login     ,
      p_request_id             => p_qlpar_request_id            ,
      p_program_application_id => p_qlpar_program_application_id,
      p_program_id             => p_qlpar_program_id            ,
      p_program_update_date    => p_qlpar_program_update_date   ,
      p_quote_line_id          => p_qlpar_quote_line_id         ,
      p_qte_line_index         => p_qlpar_qte_line_index        ,
      p_price_adjustment_id    => p_qlpar_price_adjustment_id   ,
      p_price_adj_index        => p_qlpar_price_adj_index       ,
      p_rltd_price_adj_id      => p_qlpar_rltd_price_adj_id     ,
      p_rltd_price_adj_index   => p_qlpar_rltd_price_adj_index);
   ELSE
     l_price_adj_rltship_tbl := ASO_Quote_Pub.G_Miss_Price_Adj_Rltship_Tbl;
   END IF;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('p_q_save_type in Save_wrapper: '||p_q_save_type);
     END IF;

   if ((p_q_save_type = SAVE_ADDTOCART)
	 OR(p_q_save_type = SAVE_EXPRESSORDER)) then

     /*IF(p_q_save_type = SAVE_EXPRESSORDER) THEN
       l_save_type := 'SAVE_EXPRESSORDER';
     END IF;*/

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('L_save_type in Save_wrapper: '||l_save_type);
     END IF;
   IBE_Quote_Save_pvt.AddItemsToCart(
    p_api_version_number        => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,p_commit                   => p_commit
    ,p_combinesameitem          => p_combinesameitem
    ,p_sharee_number            => p_sharee_number
    ,p_sharee_party_id          => p_sharee_party_id
    ,p_sharee_cust_account_id   => p_sharee_cust_account_id
    ,p_minisite_id              => p_q_minisite_id
    ,p_save_flag                => p_q_save_type
    ,p_control_rec              => l_control_rec

    ,p_ql_line_codes            => p_ql_line_codes
    ,p_qte_header_rec           => l_qte_header_rec
    ,p_hd_price_attributes_tbl  => l_hd_price_attributes_tbl
    ,p_hd_payment_tbl           => l_hd_payment_tbl
    ,p_hd_shipment_tbl          => l_hd_shipment_tbl
    ,p_hd_freight_charge_tbl    => l_hd_freight_charge_tbl
    ,p_hd_tax_detail_tbl        => l_hd_tax_detail_tbl
    ,p_qte_line_tbl             => l_qte_line_tbl
    ,p_qte_line_dtl_tbl         => l_qte_line_dtl_tbl
    ,p_line_attr_ext_tbl        => l_line_attr_ext_tbl
    ,p_line_rltship_tbl         => l_line_rltship_tbl
    ,p_price_adjustment_tbl     => l_price_adjustment_tbl
    ,p_price_adj_attr_tbl       => l_price_adj_attr_tbl
    ,p_price_adj_rltship_tbl    => l_price_adj_rltship_tbl
    ,p_ln_price_attributes_tbl  => l_ln_price_attributes_tbl
    ,p_ln_payment_tbl           => l_ln_payment_tbl
    ,p_ln_shipment_tbl          => l_ln_shipment_tbl
    ,p_ln_freight_charge_tbl    => l_ln_freight_charge_tbl
    ,p_ln_tax_detail_tbl        => l_ln_tax_detail_tbl

    ,x_quote_header_id          => x_quote_header_id
    ,x_qte_line_tbl             => lx_Qte_Line_Tbl
    ,x_last_update_date         => x_last_update_date
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
   );

 else

    IBE_Quote_Save_pvt.Save(
    p_api_version_number        => p_api_version_number
    ,p_init_msg_list            => p_init_msg_list
    ,p_commit                   => p_commit
    ,p_auto_update_active_quote => p_auto_update_active_quote
    ,p_combinesameitem          => p_combinesameitem
    ,p_sharee_number            => p_sharee_number
    ,p_sharee_party_id          => p_sharee_party_id
    ,p_sharee_cust_account_id   => p_sharee_cust_account_id
    ,p_minisite_id              => p_q_minisite_id
    ,p_control_rec              => l_control_rec
    ,p_qte_header_rec           => l_qte_header_rec
    ,p_hd_price_attributes_tbl  => l_hd_price_attributes_tbl
    ,p_hd_payment_tbl           => l_hd_payment_tbl
    ,p_hd_shipment_tbl          => l_hd_shipment_tbl
    ,p_hd_freight_charge_tbl    => l_hd_freight_charge_tbl
    ,p_hd_tax_detail_tbl        => l_hd_tax_detail_tbl
    ,p_qte_line_tbl             => l_qte_line_tbl
    ,p_qte_line_dtl_tbl         => l_qte_line_dtl_tbl
    ,p_line_attr_ext_tbl        => l_line_attr_ext_tbl
    ,p_line_rltship_tbl         => l_line_rltship_tbl
    ,p_price_adjustment_tbl     => l_price_adjustment_tbl
    ,p_price_adj_attr_tbl       => l_price_adj_attr_tbl
    ,p_price_adj_rltship_tbl    => l_price_adj_rltship_tbl
    ,p_ln_price_attributes_tbl  => l_ln_price_attributes_tbl
    ,p_ln_payment_tbl           => l_ln_payment_tbl
    ,p_ln_shipment_tbl          => l_ln_shipment_tbl
    ,p_ln_freight_charge_tbl    => l_ln_freight_charge_tbl
    ,p_ln_tax_detail_tbl        => l_ln_tax_detail_tbl
    ,p_save_type                => p_q_save_type
    ,x_quote_header_id          => x_quote_header_id
    ,x_last_update_date         => x_last_update_date
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
   );
  end if;
END SaveWrapper;

PROCEDURE MergeActiveQuoteWrapper(
   p_api_version_number        IN  NUMBER   := 1                  ,
   p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit                    IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status             OUT NOCOPY VARCHAR2                       ,
   x_msg_count                 OUT NOCOPY NUMBER                         ,
   x_msg_data                  OUT NOCOPY VARCHAR2                       ,
   p_party_id                  IN  NUMBER                         ,
   p_cust_account_id           IN  NUMBER                         ,
   p_quote_header_id           IN  NUMBER                         ,
   p_last_update_date          IN  VARCHAR2 := FND_API.G_MISS_DATE,
   p_mode                      IN  VARCHAR2 := 'MERGE'            ,
   p_combinesameitem           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_quote_source_code         IN  VARCHAR2 := 'IStore Account'   ,
   p_currency_code             IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_price_list_id             IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_c_last_update_date        IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   x_quote_header_id           OUT NOCOPY NUMBER                  ,
   x_last_update_date          OUT NOCOPY DATE                    ,
   x_retrieval_number          OUT NOCOPY NUMBER
   )

IS
   l_control_rec ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_Miss_Control_Rec;
BEGIN
   Set_Control_Rec_W(
      p_c_last_update_date        => p_c_last_update_date       ,
      p_c_auto_version_flag       => p_c_auto_version_flag      ,
      p_c_pricing_request_type    => p_c_pricing_request_type   ,
      p_c_header_pricing_event    => p_c_header_pricing_event   ,
      p_c_line_pricing_event      => p_c_line_pricing_event     ,
      p_c_cal_tax_flag            => p_c_cal_tax_flag           ,
      p_c_cal_freight_charge_flag => p_c_cal_freight_charge_flag,
      x_control_rec               => l_control_rec);

   IBE_QUOTE_SAVESHARE_pvt.mergeActiveQuote(
      p_api_version_number => p_api_version_number,
      p_init_msg_list      => p_init_msg_list     ,
      p_commit             => p_commit            ,
      p_quote_header_id    => p_quote_header_id   ,
      p_last_update_date   => p_last_update_date  ,
      p_mode               => p_mode              ,
      p_combinesameitem    => p_combinesameitem   ,
      p_party_id           => p_party_id          ,
      p_cust_account_id    => p_cust_account_id   ,
      p_quote_source_code  => p_quote_source_code ,
      p_currency_code      => p_currency_code     ,
      p_price_list_id      => p_price_list_id     ,
      p_control_rec        => l_control_rec       ,
      x_quote_header_id    => x_quote_header_id   ,
      x_last_update_date   => x_last_update_date  ,
      x_return_status      => x_return_status     ,
      x_msg_count          => x_msg_count         ,
      x_msg_data           => x_msg_data          ,
      x_retrieval_number   => x_retrieval_number  );
END MergeActiveQuoteWrapper;

PROCEDURE SubmitQuoteWrapper(
   p_api_version_number IN  NUMBER   := 1                  ,
   p_init_msg_list      IN  VARCHAR2 := FND_API.G_TRUE     ,
   p_commit             IN  VARCHAR2 := FND_API.G_FALSE    ,
   x_return_status      OUT NOCOPY VARCHAR2                       ,
   x_msg_count          OUT NOCOPY NUMBER                         ,
   x_msg_data           OUT NOCOPY VARCHAR2                       ,
   p_quote_headerid     IN  NUMBER                         ,
   p_last_update_date   IN  DATE     := FND_API.G_MISS_DATE,
   p_sharee_number      IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sharee_party_id    IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sharee_account_id  IN  NUMBER   := FND_API.G_MISS_NUM ,
   p_sc_book_flag       IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_sc_reserve_flag    IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_sc_calculate_price IN  VARCHAR2 := FND_API.G_FALSE    ,
   p_sc_server_id       IN  NUMBER   := -1                 ,
   p_sc_cc_by_fax       IN  VARCHAR2 := FND_API.G_FALSE    ,

   p_customer_comments  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_reason_code        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_salesrep_email_id  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_minisite_id        IN  NUMBER   := FND_API.G_MISS_NUM ,

   x_last_update_date   OUT NOCOPY DATE                    ,
   x_order_number       OUT NOCOPY NUMBER                  ,
   x_order_header_id    OUT NOCOPY NUMBER                  ,
   x_order_request_id   OUT NOCOPY NUMBER                  ,
   x_contract_id        OUT NOCOPY NUMBER                  ,
   x_status             OUT NOCOPY VARCHAR2                ,
   --Mannamra: Added for bug 4716044
   x_hold_flag          OUT NOCOPY VARCHAR2
)
IS
   lp_Submit_control_rec ASO_Quote_Pub.Submit_Control_Rec_Type := ASO_Quote_Pub.G_MISS_Submit_Control_Rec;
   lx_order_header_rec   ASO_Quote_Pub.Order_Header_Rec_Type;
BEGIN
   Set_Submit_Control_Rec_w(
      p_sc_book_flag       => p_sc_book_flag      ,
      p_sc_reserve_flag    => p_sc_reserve_flag   ,
      p_sc_calculate_price => p_sc_calculate_price,
      p_sc_server_id       => p_sc_server_id      ,
      p_sc_cc_by_fax       => p_sc_cc_by_fax      ,
      x_Submit_control_rec => lp_Submit_control_rec);

   IBE_Quote_Checkout_Pvt.submitQuote(
      p_api_version_number     => p_api_version_number ,
      p_commit                 => p_commit             ,
      p_init_msg_list          => p_init_msg_list      ,
      p_quote_header_id        => p_quote_headerid     ,
      p_last_update_date       => p_last_update_date   ,
      p_sharee_party_id        => p_sharee_party_id    ,
      p_sharee_cust_account_id => p_sharee_account_id  ,
      p_sharee_number          => p_sharee_number      ,
      p_submit_control_rec     => lp_submit_control_rec,

      p_customer_comments      => p_customer_comments  ,
      p_reason_code            => p_reason_code        ,
      p_salesrep_email_id      => p_salesrep_email_id  ,
      p_minisite_id            => p_minisite_id        ,

      x_order_header_rec       => lx_order_header_rec  ,
      x_return_status          => x_return_status      ,
      x_msg_count              => x_msg_count          ,
      x_msg_data               => x_msg_data           ,
      x_hold_flag              => x_hold_flag          );

   Set_Order_Header_Out_W(
      p_order_header_rec => lx_order_header_rec,
      x_order_number     => x_order_number     ,
      x_order_header_id  => x_order_header_id  ,
      x_order_request_id => x_order_request_id ,
      x_contract_id      => x_contract_id      ,
      x_status           => x_status);
END SubmitQuoteWrapper;


PROCEDURE AddModelsToCartWrapper(
   x_ql_quote_line_id             OUT NOCOPY jtf_number_table              ,
   p_api_version_number           IN  NUMBER   := 1                 ,
   p_init_msg_list                IN  VARCHAR2 := FND_API.G_TRUE    ,
   p_commit                       IN  VARCHAR2 := FND_API.G_FALSE   ,
   p_Bundle_Flag                  IN  VARCHAR2 := FND_API.G_FALSE   ,
   x_return_status                OUT NOCOPY VARCHAR2                      ,
   x_msg_count                    OUT NOCOPY NUMBER                        ,
   x_msg_data                     OUT NOCOPY VARCHAR2                      ,
   x_quote_header_id              OUT NOCOPY NUMBER                        ,
   x_last_update_date             OUT NOCOPY DATE                          ,
   p_combinesameitem              IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_sharee_number                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_sharee_party_id              IN  NUMBER   := FND_API.G_MISS_NUM,
   p_sharee_cust_account_id       IN  NUMBER   := FND_API.G_MISS_NUM,
   p_c_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode		  IN  VARCHAR2 := 'ENTIRE_QUOTE'     ,  -- change line logic pricing
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
   p_q_save_type                  IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_minisite_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_pricing_status_indicator   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_tax_status_indicator   	  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_ql_creation_date            IN jtf_date_table         := NULL,
   p_ql_created_by               IN jtf_number_table       := NULL,
   p_ql_last_updated_by          IN jtf_number_table       := NULL,
   p_ql_last_update_date         IN jtf_date_table         := NULL,
   p_ql_last_update_login        IN jtf_number_table       := NULL,
   p_ql_request_id               IN jtf_number_table       := NULL,
   p_ql_program_application_id   IN jtf_number_table       := NULL,
   p_ql_program_id               IN jtf_number_table       := NULL,
   p_ql_program_update_date      IN jtf_date_table         := NULL,
   p_ql_quote_line_id            IN jtf_number_table       := NULL,
   p_ql_quote_header_id          IN jtf_number_table       := NULL,
   p_ql_org_id                   IN jtf_number_table       := NULL,
   p_ql_line_number              IN jtf_number_table       := NULL,
   p_ql_line_category_code       IN jtf_varchar2_table_100 := NULL,
   p_ql_item_type_code           IN jtf_varchar2_table_100 := NULL,
   p_ql_inventory_item_id        IN jtf_number_table       := NULL,
   p_ql_organization_id          IN jtf_number_table       := NULL,
   p_ql_quantity                 IN jtf_number_table       := NULL,
   p_ql_uom_code                 IN jtf_varchar2_table_100 := NULL,
   p_ql_start_date_active        IN jtf_date_table         := NULL,
   p_ql_end_date_active          IN jtf_date_table         := NULL,
   p_ql_order_line_type_id       IN jtf_number_table       := NULL,
   p_ql_price_list_id            IN jtf_number_table       := NULL,
   p_ql_price_list_line_id       IN jtf_number_table       := NULL,
   p_ql_currency_code            IN jtf_varchar2_table_100 := NULL,
   p_ql_line_list_price          IN jtf_number_table       := NULL,
   p_ql_line_adjusted_amount     IN jtf_number_table       := NULL,
   p_ql_line_adjusted_percent    IN jtf_number_table       := NULL,
   p_ql_line_quote_price         IN jtf_number_table       := NULL,
   p_ql_related_item_id          IN jtf_number_table       := NULL,
   p_ql_item_relationship_type   IN jtf_varchar2_table_100 := NULL,
   p_ql_split_shipment_flag      IN jtf_varchar2_table_100 := NULL,
   p_ql_backorder_flag           IN jtf_varchar2_table_100 := NULL,
   p_ql_selling_price_change     IN jtf_varchar2_table_100 := NULL,
   p_ql_recalculate_flag         IN jtf_varchar2_table_100 := NULL,
   p_ql_attribute_category       IN jtf_varchar2_table_100 := NULL,
   p_ql_attribute1               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute2               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute3               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute4               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute5               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute6               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute7               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute8               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute9               IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute10              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute11              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute12              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute13              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute14              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute15              IN jtf_varchar2_table_300 := NULL,
   --modified for bug 18525045 - start
   p_ql_attribute16              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute17              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute18              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute19              IN jtf_varchar2_table_300 := NULL,
   p_ql_attribute20              IN jtf_varchar2_table_300 := NULL,
   --modified for bug 18525045 - end
   p_ql_accounting_rule_id       IN jtf_number_table       := NULL,
   p_ql_ffm_content_name         IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_content_type         IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_document_type        IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_media_id             IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_media_type           IN jtf_varchar2_table_300 := NULL,
   p_ql_ffm_user_note            IN jtf_varchar2_table_300 := NULL,
   p_ql_invoice_to_party_id      IN jtf_number_table       := NULL,
   p_ql_invoice_to_party_site_id IN jtf_number_table       := NULL,
   p_ql_invoice_to_cust_acct_id  IN jtf_number_table       := NULL,
   p_ql_invoicing_rule_id        IN jtf_number_table       := NULL,
   p_ql_marketing_source_code_id IN jtf_number_table       := NULL,
   p_ql_operation_code           IN jtf_varchar2_table_100 := NULL,
   p_ql_commitment_id            IN jtf_number_table       := NULL,
   p_ql_agreement_id             IN jtf_number_table       := NULL,
   p_ql_minisite_id              IN jtf_number_table       := NULL,
   p_ql_section_id               IN jtf_number_table       := NULL,
   p_ql_line_codes               IN jtf_number_table       := NULL
)
IS
  l_qte_header_rec ASO_Quote_Pub.qte_header_rec_type := ASO_Quote_Pub.G_MISS_Qte_Header_Rec;
  l_qte_line_tbl   ASO_Quote_Pub.qte_line_tbl_type := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL;
  x_qte_line_tbl   ASO_Quote_Pub.qte_line_tbl_type := ASO_Quote_Pub.G_MISS_QTE_LINE_TBL;
  l_control_rec    ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_Miss_Control_Rec;
  l_count          NUMBER;
BEGIN

  Set_Control_rec_w(
    p_c_LAST_UPDATE_DATE                   =>  p_c_LAST_UPDATE_DATE
   ,p_c_auto_version_flag                  =>  p_c_auto_version_flag
   ,p_c_pricing_request_type               =>  p_c_pricing_request_type
   ,p_c_header_pricing_event               =>  p_c_header_pricing_event
   ,p_c_line_pricing_event                 =>  p_c_line_pricing_event
   ,p_c_CAL_TAX_FLAG                       =>  p_c_CAL_TAX_FLAG
   ,p_c_CAL_FREIGHT_CHARGE_FLAG            =>  p_c_CAL_FREIGHT_CHARGE_FLAG
   ,x_control_rec                          =>  l_control_rec
  );

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
-- added attribute 16-20 for bug 6873117 mgiridha
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
      p_resource_id                => p_q_resource_id,
      p_end_customer_party_id        => FND_API.G_MISS_NUM,
      p_end_customer_cust_party_id   => FND_API.G_MISS_NUM,
      p_end_customer_party_site_id   => FND_API.G_MISS_NUM,
      p_end_customer_cust_account_id => FND_API.G_MISS_NUM,
      p_pricing_status_indicator 	 => p_q_pricing_status_indicator,
      p_tax_status_indicator		 => p_q_tax_status_indicator
      );

   l_qte_line_tbl := Construct_Qte_Line_Tbl(
      p_creation_date              => p_ql_creation_date           ,
      p_created_by                 => p_ql_created_by              ,
      p_last_updated_by            => p_ql_last_updated_by         ,
      p_last_update_date           => p_ql_last_update_date        ,
      p_last_update_login          => p_ql_last_update_login       ,
      p_request_id                 => p_ql_request_id              ,
      p_program_application_id     => p_ql_program_application_id  ,
      p_program_id                 => p_ql_program_id              ,
      p_program_update_date        => p_ql_program_update_date     ,
      p_quote_line_id              => p_ql_quote_line_id           ,
      p_quote_header_id            => p_ql_quote_header_id         ,
      p_org_id                     => p_ql_org_id                  ,
      p_line_number                => p_ql_line_number             ,
      p_line_category_code         => p_ql_line_category_code      ,
      p_item_type_code             => p_ql_item_type_code          ,
      p_inventory_item_id          => p_ql_inventory_item_id       ,
      p_organization_id            => p_ql_organization_id         ,
      p_quantity                   => p_ql_quantity                ,
      p_uom_code                   => p_ql_uom_code                ,
      p_ordered_item_id_tbl        => null                         ,
      p_ordered_item_tbl        => null                         ,
      p_item_ident_type_tbl        => null                         ,
      p_start_date_active          => p_ql_start_date_active       ,
      p_end_date_active            => p_ql_end_date_active         ,
      p_order_line_type_id         => p_ql_order_line_type_id      ,
      p_price_list_id              => p_ql_price_list_id           ,
      p_price_list_line_id         => p_ql_price_list_line_id      ,
      p_currency_code              => p_ql_currency_code           ,
      p_line_list_price            => p_ql_line_list_price         ,
      p_line_adjusted_amount       => p_ql_line_adjusted_amount    ,
      p_line_adjusted_percent      => p_ql_line_adjusted_percent   ,
      p_line_quote_price           => p_ql_line_quote_price        ,
      p_related_item_id            => p_ql_related_item_id         ,
      p_item_relationship_type     => p_ql_item_relationship_type  ,
      p_split_shipment_flag        => p_ql_split_shipment_flag     ,
      p_backorder_flag             => p_ql_backorder_flag          ,
      p_selling_price_change       => p_ql_selling_price_change    ,
      p_recalculate_flag           => p_ql_recalculate_flag        ,
      p_attribute_category         => p_ql_attribute_category      ,
      p_attribute1                 => p_ql_attribute1              ,
      p_attribute2                 => p_ql_attribute2              ,
      p_attribute3                 => p_ql_attribute3              ,
      p_attribute4                 => p_ql_attribute4              ,
      p_attribute5                 => p_ql_attribute5              ,
      p_attribute6                 => p_ql_attribute6              ,
      p_attribute7                 => p_ql_attribute7              ,
      p_attribute8                 => p_ql_attribute8              ,
      p_attribute9                 => p_ql_attribute9              ,
      p_attribute10                => p_ql_attribute10             ,
      p_attribute11                => p_ql_attribute11             ,
      p_attribute12                => p_ql_attribute12             ,
      p_attribute13                => p_ql_attribute13             ,
      p_attribute14                => p_ql_attribute14             ,
      p_attribute15                => p_ql_attribute15             ,
      --modified for bug 18525045 - start
      p_attribute16                => p_ql_attribute16             ,
      p_attribute17                => p_ql_attribute17             ,
      p_attribute18                => p_ql_attribute18             ,
      p_attribute19                => p_ql_attribute19             ,
      p_attribute20                => p_ql_attribute20             ,
      --modified for bug 18525045 - end
      p_accounting_rule_id         => p_ql_accounting_rule_id      ,
      p_ffm_content_name           => p_ql_ffm_content_name        ,
      p_ffm_content_type           => p_ql_ffm_content_type        ,
      p_ffm_document_type          => p_ql_ffm_document_type       ,
      p_ffm_media_id               => p_ql_ffm_media_id            ,
      p_ffm_media_type             => p_ql_ffm_media_type          ,
      p_ffm_user_note              => p_ql_ffm_user_note           ,
      p_invoice_to_party_id        => p_ql_invoice_to_party_id     ,
      p_invoice_to_party_site_id   => p_ql_invoice_to_party_site_id,
      p_invoice_to_cust_acct_id    => p_ql_invoice_to_cust_acct_id ,
      p_invoicing_rule_id          => p_ql_invoicing_rule_id       ,
      p_marketing_source_code_id   => p_ql_marketing_source_code_id,
      p_operation_code             => p_ql_operation_code          ,
      p_commitment_id              => p_ql_commitment_id           ,
      p_agreement_id               => p_ql_agreement_id            ,
      p_minisite_id                => p_ql_minisite_id             ,
      p_section_id                 => p_ql_section_id,
      p_end_customer_party_id      => null,
      p_end_customer_cust_party_id => null,
      p_end_customer_party_site_id => null,
      p_end_customer_cust_account_id => null
      );

   -- originally we called addModelsToCart here
   -- but that api has become the new addItemsToCart
   IBE_Quote_Save_pvt.AddItemsToCart(
    p_api_version_number => p_api_version_number
    ,p_init_msg_list     => p_init_msg_list
    ,p_commit            => p_commit
    ,p_Bundle_Flag            => p_Bundle_Flag
    ,p_combinesameitem   => p_combinesameitem
    ,p_sharee_number     => p_sharee_number
    ,p_sharee_party_id   => p_sharee_party_id
    ,p_sharee_cust_account_id => p_sharee_cust_account_id
    ,p_minisite_id              => p_q_minisite_id
    ,p_control_rec => l_control_rec
    ,p_qte_header_rec        => l_qte_header_rec
    ,p_qte_line_tbl    => l_qte_line_tbl
    ,p_ql_line_codes   => p_ql_line_codes
    ,x_quote_header_id          => x_quote_header_id
    ,x_qte_line_tbl             => x_qte_line_tbl
    ,x_last_update_date        => x_last_update_date
    ,x_return_status            => x_return_status
    ,x_msg_count                => x_msg_count
    ,x_msg_data                 => x_msg_data
   );

   l_count := x_qte_line_tbl.COUNT;
   x_ql_quote_line_id := JTF_NUMBER_TABLE();

   IF l_count > 0 THEN
    x_ql_quote_line_id.extend(l_count);
     -- Set Output for Quote_Line_ids
     FOR i IN 1..l_count LOOP
       x_ql_quote_line_id(i) := x_qte_line_tbl(i).quote_line_id;
     END LOOP;
   END IF;

END AddModelsToCartWrapper;
-- API NAME:  RECONFIGURE_FROM_IB


PROCEDURE RECONFIGURE_FROM_IB_WRAPPER(
   p_api_version_number        IN  NUMBER      := 1,
   p_Init_Msg_List            IN   VARCHAR2    := FND_API.G_FALSE,
   p_Commit                   IN   VARCHAR2    := FND_API.G_FALSE,
   p_c_last_update_date           IN  DATE     := FND_API.G_MISS_DATE,
   p_c_auto_version_flag          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_pricing_request_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_header_pricing_event       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_line_pricing_event         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_tax_flag               IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_cal_freight_charge_flag    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_c_price_mode		  IN  VARCHAR2 := 'ENTIRE_QUOTE'     , -- change line logic pricing
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
   p_q_attribute_category         IN  VARCHAR2 := FND_API.G_MISS_CHAR,
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
   p_q_attribute20                 IN  VARCHAR2 := FND_API.G_MISS_CHAR,
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
   p_q_minisite_id                IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_party_id          IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_cust_party_id     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_party_site_id     IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_end_cust_cust_account_id   IN  NUMBER   := FND_API.G_MISS_NUM,
   p_q_pricing_status_indicator   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_q_tax_status_indicator          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_instance_ids                 IN  jtf_number_table       := NULL,
   x_config_line                  OUT NOCOPY ConfigCurTyp,
   x_last_update_date             OUT NOCOPY DATE,
   x_return_status                OUT NOCOPY VARCHAR2,
   x_msg_count                    OUT NOCOPY NUMBER,
   x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
  l_qte_header_rec ASO_Quote_Pub.qte_header_rec_type := ASO_Quote_Pub.G_MISS_Qte_Header_Rec;
  l_control_rec    ASO_Quote_Pub.Control_Rec_Type := ASO_Quote_Pub.G_Miss_Control_Rec;

BEGIN

  Set_Control_rec_w(
    p_c_LAST_UPDATE_DATE                   =>  p_c_LAST_UPDATE_DATE
   ,p_c_auto_version_flag                  =>  p_c_auto_version_flag
   ,p_c_pricing_request_type               =>  p_c_pricing_request_type
   ,p_c_header_pricing_event               =>  p_c_header_pricing_event
   ,p_c_line_pricing_event                 =>  p_c_line_pricing_event
   ,p_c_CAL_TAX_FLAG                       =>  p_c_CAL_TAX_FLAG
   ,p_c_CAL_FREIGHT_CHARGE_FLAG            =>  p_c_CAL_FREIGHT_CHARGE_FLAG
   ,x_control_rec                          =>  l_control_rec
  );

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
      p_attribute_category         => p_q_attribute_category        ,
-- added attribute 16-20 for bug 6873117 mgiridha
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
      p_attribute20                 => p_q_attribute20              ,
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
      p_resource_id                => p_q_resource_id,
      p_end_customer_party_id        => FND_API.G_MISS_NUM,
      p_end_customer_cust_party_id   => FND_API.G_MISS_NUM,
      p_end_customer_party_site_id   => FND_API.G_MISS_NUM,
      p_end_customer_cust_account_id => FND_API.G_MISS_NUM
      );
	 l_qte_header_rec.minisite_id := p_q_minisite_id;
      IBE_Quote_Save_pvt.RECONFIGURE_FROM_IB
      (
        p_api_version_number => p_api_version_number
        ,p_init_msg_list     => p_init_msg_list
        ,p_commit            => p_commit
        ,p_control_rec       => l_control_rec
        ,p_qte_header_rec    => l_qte_header_rec
	,p_instance_ids      => p_instance_ids
        ,x_config_line       => x_config_line
	,x_last_update_date  => x_last_update_date
        ,x_return_status     => x_return_status
        ,x_msg_count         => x_msg_count
        ,x_msg_data          => x_msg_data
      );
END RECONFIGURE_FROM_IB_WRAPPER;

END IBE_Quote_W1_PVT;

/
