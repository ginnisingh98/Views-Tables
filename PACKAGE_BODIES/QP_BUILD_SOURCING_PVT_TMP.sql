--------------------------------------------------------
--  DDL for Package Body QP_BUILD_SOURCING_PVT_TMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_BUILD_SOURCING_PVT_TMP" AS
/* $Header: QPXVBSTB.pls 115.0 30-AUG-13 23:23:31 appldev ship $ */
 
--  
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--  
--  FILENAME
--  
--      QP_BUILD_SOURCING_PVT_TMP
--  
--  DESCRIPTION
--  
--      Body of package QP_BUILD_SOURCING_PVT_TMP
--  
--  NOTES
--  
--  HISTORY
--  
--  30-AUG-13 Created
--  
 
--  Global constant holding the package name
 
 
PROCEDURE Get_Attribute_Values
(    p_req_type_code                IN VARCHAR2
,    p_pricing_type_code            IN VARCHAR2
,    x_qual_ctxts_result_tbl        OUT NOCOPY QP_Attr_Mapping_PUB.CONTEXTS_RESULT_TBL_TYPE
,    x_price_ctxts_result_tbl       OUT NOCOPY QP_Attr_Mapping_PUB.CONTEXTS_RESULT_TBL_TYPE
)
IS
 
v_attr_value         VARCHAR2(240);
v_attr_mvalue        QP_Attr_Mapping_PUB.t_MultiRecord;
q_count              NUMBER := 1;
p_count              NUMBER := 1;
v_index              NUMBER := 1;
prev_header_id 	   NUMBER := FND_API.G_MISS_NUM;
 
l_debug              VARCHAR2(3);
BEGIN
qp_debug_util.tstart('FETCH_ATTRIBUTES','Fetching the Attribute Values');
 
  l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
if p_pricing_type_code = 'H' and qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_no then
  qp_preq_grp.g_new_pricing_call := qp_preq_grp.g_yes;
  IF l_debug = FND_API.G_TRUE THEN
    oe_debug_pub.add('hw/src/H: change to g_yes');
  END IF;
end if;
 
  If QP_Util_PUB.HVOP_Pricing_On= 'N' Then --Follow Non-HVOP Path
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'AHL' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'AHL' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'OKS' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
--  Src_Type: CONSTANT
      v_attr_value := 'ALL';
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_price_ctxts_result_tbl(p_count).context_name := 'ITEM';
      x_price_ctxts_result_tbl(p_count).attribute_name := 'PRICING_ATTRIBUTE3';
      x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;
        p_count := p_count + 1;
 
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Gathering product details');
        END IF;
        BEGIN
          QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := x_price_ctxts_result_tbl(p_count-1);
        Exception
        When Others Then
          IF l_debug = FND_API.G_TRUE THEN
            oe_debug_pub.add('No product sourced ');
          END IF;
        END;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'OKS' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'PO' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
--  Src_Type: CONSTANT
      v_attr_value := 'ALL';
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_price_ctxts_result_tbl(p_count).context_name := 'ITEM';
      x_price_ctxts_result_tbl(p_count).attribute_name := 'PRICING_ATTRIBUTE3';
      x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;
        p_count := p_count + 1;
 
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Gathering product details');
        END IF;
        BEGIN
          QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := x_price_ctxts_result_tbl(p_count-1);
        Exception
        When Others Then
          IF l_debug = FND_API.G_TRUE THEN
            oe_debug_pub.add('No product sourced ');
          END IF;
        END;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'PO' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'MSD' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'MSD' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'IC' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'IC' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'FTE' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'FTE' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'ASO' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
--  Src_Type: CONSTANT
      v_attr_value := 'ALL';
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_price_ctxts_result_tbl(p_count).context_name := 'ITEM';
      x_price_ctxts_result_tbl(p_count).attribute_name := 'PRICING_ATTRIBUTE3';
      x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;
        p_count := p_count + 1;
 
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Gathering product details');
        END IF;
        BEGIN
          QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := x_price_ctxts_result_tbl(p_count-1);
        Exception
        When Others Then
          IF l_debug = FND_API.G_TRUE THEN
            oe_debug_pub.add('No product sourced ');
          END IF;
        END;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
    IF l_debug = FND_API.G_TRUE THEN
      oe_debug_pub.add('In check to call line_group');
    END IF;
    IF QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG = 'Y' THEN
      BEGIN
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('Before call line_group');
      END IF;
      QP_ATTR_MAPPING_PUB.Check_line_group_items(p_pricing_type_code);
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('After call line_group');
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Error in Check_line_group_items');
        END IF;
      END;
    ELSE--QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG
      QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE := 'Y';
    END IF;--QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG
    IF QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE = 'N' THEN
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('Deleting sourced prod attr');
      END IF;
      x_price_ctxts_result_tbl.delete;
      RETURN;
    END IF;--QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE
--  Src_Type: API
    BEGIN
      v_attr_value := 
                      ASO_PRICING_INT.G_LINE_REC.price_list_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    BEGIN
    IF v_attr_value = FND_API.G_MISS_NUM THEN
      v_attr_value := NULL;
    END IF;
    EXCEPTION
      WHEN VALUE_ERROR THEN
        IF v_attr_value = FND_API.G_MISS_CHAR THEN
          v_attr_value := NULL;
        END IF;
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_qual_ctxts_result_tbl(q_count).context_name := 'MODLIST';
      x_qual_ctxts_result_tbl(q_count).attribute_name := 'QUALIFIER_ATTRIBUTE4';
      x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_value;
      q_count := q_count + 1;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'ASO' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
--  Src_Type: API
    BEGIN
      v_attr_value := 
                      ASO_PRICING_INT.G_HEADER_REC.price_list_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    BEGIN
    IF v_attr_value = FND_API.G_MISS_NUM THEN
      v_attr_value := NULL;
    END IF;
    EXCEPTION
      WHEN VALUE_ERROR THEN
        IF v_attr_value = FND_API.G_MISS_CHAR THEN
          v_attr_value := NULL;
        END IF;
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_qual_ctxts_result_tbl(q_count).context_name := 'MODLIST';
      x_qual_ctxts_result_tbl(q_count).attribute_name := 'QUALIFIER_ATTRIBUTE4';
      x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_value;
      q_count := q_count + 1;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'OKC' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
--  Src_Type: CONSTANT
      v_attr_value := 'ALL';
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_price_ctxts_result_tbl(p_count).context_name := 'ITEM';
      x_price_ctxts_result_tbl(p_count).attribute_name := 'PRICING_ATTRIBUTE3';
      x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;
        p_count := p_count + 1;
 
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Gathering product details');
        END IF;
        BEGIN
          QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := x_price_ctxts_result_tbl(p_count-1);
        Exception
        When Others Then
          IF l_debug = FND_API.G_TRUE THEN
            oe_debug_pub.add('No product sourced ');
          END IF;
        END;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'OKC' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'ONT' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
--  Src_Type: CONSTANT
      v_attr_value := 'ALL';
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_price_ctxts_result_tbl(p_count).context_name := 'ITEM';
      x_price_ctxts_result_tbl(p_count).attribute_name := 'PRICING_ATTRIBUTE3';
      x_price_ctxts_result_tbl(p_count).attribute_value := v_attr_value;
        p_count := p_count + 1;
 
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Gathering product details');
        END IF;
        BEGIN
          QP_ATTR_MAPPING_PUB.G_Product_attr_tbl(QP_ATTR_MAPPING_PUB.G_Product_attr_tbl.COUNT+1) := x_price_ctxts_result_tbl(p_count-1);
        Exception
        When Others Then
          IF l_debug = FND_API.G_TRUE THEN
            oe_debug_pub.add('No product sourced ');
          END IF;
        END;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
    IF l_debug = FND_API.G_TRUE THEN
      oe_debug_pub.add('In check to call line_group');
    END IF;
    IF QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG = 'Y' THEN
      BEGIN
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('Before call line_group');
      END IF;
      QP_ATTR_MAPPING_PUB.Check_line_group_items(p_pricing_type_code);
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('After call line_group');
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('Error in Check_line_group_items');
        END IF;
      END;
    ELSE--QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG
      QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE := 'Y';
    END IF;--QP_ATTR_MAPPING_PUB.G_CHECK_LINE_FLAG
    IF QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE = 'N' THEN
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('Deleting sourced prod attr');
      END IF;
      x_price_ctxts_result_tbl.delete;
      RETURN;
    END IF;--QP_ATTR_MAPPING_PUB.G_PASS_THIS_LINE
--  Src_Type: API
    BEGIN
      v_attr_value := 
                      OE_ORDER_PUB.G_LINE.price_list_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    BEGIN
    IF v_attr_value = FND_API.G_MISS_NUM THEN
      v_attr_value := NULL;
    END IF;
    EXCEPTION
      WHEN VALUE_ERROR THEN
        IF v_attr_value = FND_API.G_MISS_CHAR THEN
          v_attr_value := NULL;
        END IF;
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_qual_ctxts_result_tbl(q_count).context_name := 'MODLIST';
      x_qual_ctxts_result_tbl(q_count).attribute_name := 'QUALIFIER_ATTRIBUTE4';
      x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_value;
      q_count := q_count + 1;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'ONT' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
--  Src_Type: API
    BEGIN
      v_attr_value := 
                      OE_ORDER_PUB.G_HDR.price_list_id;
    EXCEPTION
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    BEGIN
    IF v_attr_value = FND_API.G_MISS_NUM THEN
      v_attr_value := NULL;
    END IF;
    EXCEPTION
      WHEN VALUE_ERROR THEN
        IF v_attr_value = FND_API.G_MISS_CHAR THEN
          v_attr_value := NULL;
        END IF;
      WHEN OTHERS THEN
        v_attr_value := NULL;
    END;
 
    IF (v_attr_value IS NOT NULL) THEN
 
      x_qual_ctxts_result_tbl(q_count).context_name := 'MODLIST';
      x_qual_ctxts_result_tbl(q_count).attribute_name := 'QUALIFIER_ATTRIBUTE4';
      x_qual_ctxts_result_tbl(q_count).attribute_value := v_attr_value;
      q_count := q_count + 1;
        IF l_debug = FND_API.G_TRUE THEN
          oe_debug_pub.add('After product assigned');
        END IF;
    END IF;--v_attr_(m)value
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
--  Attribute not used
--  Attribute not used
--  Attribute not used
IF p_req_type_code = 'INTORG' THEN
 
  IF p_pricing_type_code = 'L' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
  QP_ATTR_MAPPING_PUB.G_Product_Attr_Tbl.delete;
IF p_req_type_code = 'INTORG' THEN
 
  IF p_pricing_type_code = 'H' THEN
 
    NULL;
 
  END IF;
 
END IF;
 
 
  Else --Follow HVOP Path
  NULL;
 
  End If; --HVOP Path
 
  If QP_Util_PUB.HVOP_Pricing_On = 'N' Then
    if p_pricing_type_code = 'L' and qp_preq_grp.g_new_pricing_call = qp_preq_grp.g_yes then
      qp_preq_grp.g_new_pricing_call := qp_preq_grp.g_no;
      IF l_debug = FND_API.G_TRUE THEN
        oe_debug_pub.add('hw/src/L: change to g_no');
      END IF;
    end if;
  End If;
 
qp_debug_util.tstop('FETCH_ATTRIBUTES');
END Get_Attribute_Values;
 
FUNCTION Is_Attribute_Used (p_attribute_context IN VARCHAR2, p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
 
IS
 
x_out	VARCHAR2(1) := 'N';
BEGIN
 
IF (p_attribute_context = 'VOLUME') and (p_attribute_code = 'PRICING_ATTRIBUTE10')
THEN
x_out := 'N';
END IF;
IF (p_attribute_context = 'VOLUME') and (p_attribute_code = 'PRICING_ATTRIBUTE12')
THEN
x_out := 'N';
END IF;
 
RETURN x_out;
 
END Is_Attribute_Used;
 
END QP_BUILD_SOURCING_PVT_TMP;

/
