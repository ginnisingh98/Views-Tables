--------------------------------------------------------
--  DDL for Package QP_CALCULATE_PRICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_CALCULATE_PRICE_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXPCLPS.pls 120.3.12010000.1 2008/07/28 11:54:55 appldev ship $ */

-- begin shu, new rounding
G_CHAR_Q                      		CONSTANT VARCHAR2(30):='Q'; -- look at QP_SELLING_PRICE_ROUNDING_OPTIONS
G_CHAR_U                      		CONSTANT VARCHAR2(30):='U'; -- not round list_price, not round adjs, round selling price

G_NO_ROUND		                CONSTANT VARCHAR2(30):='NO_ROUND'; -- selling_price = un_round list_price + un_round adjs
G_NO_ROUND_ADJ		                CONSTANT VARCHAR2(30):='NO_ROUND_ADJ'; -- selling_price = round(list_price)+ round (adjs calculated by rounded list_price)
G_ROUND_ADJ		                CONSTANT VARCHAR2(30):='ROUND_ADJ'; -- selling price = round(unrounded list_price + adjs calculated by unrounded list_price)
-- end shu, new rounding

 TYPE l_request_line_rec IS RECORD (
  LINE_INDEX                 NUMBER,
  PRICING_EFFECTIVE_DATE     DATE,
  SOURCE_SYSTEM_CODE         VARCHAR2(30),
  LINE_QUANTITY              NUMBER,
  QUALIFIER_VALUE            NUMBER,
  UNIT_PRICE                 NUMBER,
  PARENT_PRICE               NUMBER, -- Applicable for service items
  PERCENT_PRICE              NUMBER,
  SERVICE_DURATION           NUMBER,
  RELATED_ITEM_PRICE         NUMBER,
  ADJUSTED_UNIT_PRICE        NUMBER,
  GSA_QUALIFIER_FLAG         VARCHAR2(1),
  GSA_ENABLED_FLAG           VARCHAR2(1),
  ROUNDING_FACTOR            NUMBER,
  ROUNDING_FLAG              VARCHAR2(1),
  EXTENDED_PRICE             NUMBER); -- block pricing

 TYPE l_request_line_detail_rec IS RECORD (
  LINE_DETAIL_INDEX           NUMBER,
  CREATED_FROM_LIST_LINE_ID   NUMBER,
  CREATED_FROM_LIST_HEADER_ID NUMBER,
  CREATED_FROM_LIST_LINE_TYPE VARCHAR2(30),
  CREATED_FROM_LIST_TYPE      VARCHAR2(30), -- PriceList Break/Discount Break
  PRICING_GROUP_SEQUENCE      NUMBER,
  OPERAND_CALCULATION_CODE    VARCHAR2(30),
  OPERAND_VALUE               NUMBER,
  ACCRUAL_FLAG                VARCHAR2(1),
  AUTOMATIC_FLAG              VARCHAR2(1),
  ACCRUAL_CONVERSION_RATE     NUMBER,
  ESTIM_ACCRUAL_RATE          NUMBER,
  BENEFIT_QTY                 NUMBER,
  QUALIFIER_VALUE			NUMBER,
  PRICE_BREAK_TYPE_CODE       VARCHAR2(30), -- Recurring
  LINE_QUANTITY			NUMBER,
  MODIFIER_LEVEL_CODE         VARCHAR2(30),-- 2388011, grp_pbh_amt
  BUCKETED_FLAG               VARCHAR2(1), -- IT, bucket, 2388011
  ADJUSTMENT_AMOUNT           NUMBER);

 TYPE l_related_request_line_rec IS RECORD (
  LINE_DETAIL_INDEX           NUMBER, -- Parent Line Index
  CHILD_LINE_DETAIL_INDEX           NUMBER, -- Child Line Detail Index
  RELATED_LIST_LINE_TYPE      VARCHAR2(30),
  VALUE_FROM                  NUMBER,
  VALUE_TO                    NUMBER,
  PRICING_GROUP_SEQUENCE      NUMBER,
  OPERAND_CALCULATION_CODE    VARCHAR2(30),
  OPERAND_VALUE               NUMBER,
  ACCRUAL_FLAG                VARCHAR2(1),
  RECURRING_VALUE             NUMBER, -- block pricing
  LINE_QTY                    NUMBER,
  ADJUSTMENT_AMOUNT           NUMBER,  --adjustment amount
  PRICE_BREAK_TYPE_CODE       VARCHAR2(30)); -- Point or Range

 TYPE l_request_line_details_tbl IS TABLE OF l_request_line_detail_rec
  INDEX BY BINARY_INTEGER;

 TYPE l_related_request_lines_tbl IS TABLE OF l_related_request_line_rec
  INDEX BY BINARY_INTEGER;

  /*  PROCEDURE Calculate_Price
   (p_request_line                  l_request_line_rec,
    p_request_line_details          l_request_line_details_tbl,
    p_related_request_lines         l_related_request_lines_tbl,
    x_request_line            OUT NOCOPY   l_request_line_rec,
    x_request_line_details    OUT NOCOPY   l_request_line_details_tbl,
    x_related_request_lines   OUT NOCOPY   l_related_request_lines_tbl,
    x_return_status		     OUT NOCOPY	VARCHAR2,
    x_return_status_txt		OUT NOCOPY	VARCHAR2);  */

   PROCEDURE Calculate_Price
   (p_request_line            IN OUT NOCOPY      l_request_line_rec,
    p_request_line_details    IN OUT NOCOPY      l_request_line_details_tbl,
    p_related_request_lines   IN OUT NOCOPY      l_related_request_lines_tbl,
    x_return_status		 OUT NOCOPY	         VARCHAR2,
    x_return_status_txt		 OUT NOCOPY	         VARCHAR2);

    -- overloaded 2388011_latest
    PROCEDURE Price_Break_Calculation(p_list_line_id NUMBER,
                                  p_break_type   VARCHAR2,
                                  p_line_index   NUMBER,
                                  p_req_value_per_unit  NUMBER, -- Item qty,group qty,group value
                                  p_applied_req_value_per_unit  NUMBER, -- [julin/4112395]
                                  p_total_value  NUMBER, -- Total value (Group amount or item amount)
                                  p_list_price   NUMBER,
                                  p_line_quantity NUMBER, -- Acutal quantity on order line
                                  p_bucketed_adjustment  NUMBER,
                                  p_bucketed_flag     VARCHAR2,
                                  p_automatic_flag VARCHAR2, -- 5328123
                                  x_adjustment_amount OUT NOCOPY NUMBER,
                                  x_return_status OUT NOCOPY VARCHAR2,
                                  x_return_status_text OUT NOCOPY VARCHAR2);


   PROCEDURE Price_Break_Calculation(p_list_line_id NUMBER,
                                     p_break_type   VARCHAR2,
                                     p_line_index   NUMBER,
                                     p_request_qty  NUMBER,
                                     p_list_price   NUMBER,
                                     x_adjustment_amount OUT NOCOPY NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_return_status_text OUT NOCOPY VARCHAR2);

  PROCEDURE Calculate_Adjustment(p_price                  NUMBER
                              ,p_operand_calculation_code VARCHAR2
                              ,p_operand_value            NUMBER
                              ,p_priced_quantity          NUMBER
                              ,x_calc_adjustment    OUT NOCOPY   NUMBER
                              ,x_return_status      OUT NOCOPY   VARCHAR2
                              ,x_return_status_text OUT NOCOPY   VARCHAR2);

PROCEDURE Get_Satisfied_Range(p_value_from  NUMBER,
                              p_value_to    NUMBER,
                              p_qualifier_value NUMBER,
                              p_list_line_id NUMBER := null, -- for accum range break
                              p_continuous_flag VARCHAR := 'N', -- 4061138, continuous price break
                              p_prorated_flag   VARCHAR := 'N', -- 4061138
                              x_satisfied_value OUT NOCOPY NUMBER);

PROCEDURE Calculate_List_Price (p_operand_calc_code        VARCHAR2,
                                p_operand_value            NUMBER,
                                p_request_qty              NUMBER,
                                p_rltd_item_price          NUMBER,
                                p_service_duration         NUMBER,
                                p_rounding_flag            VARCHAR2,
                                p_rounding_factor          NUMBER,
                                x_list_price         OUT NOCOPY   NUMBER,
                                x_percent_price      OUT NOCOPY   NUMBER,
                                x_return_status      OUT NOCOPY   VARCHAR2,
                                x_return_status_txt  OUT NOCOPY   VARCHAR2);


END QP_Calculate_Price_PUB;

/
