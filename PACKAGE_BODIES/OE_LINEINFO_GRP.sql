--------------------------------------------------------
--  DDL for Package Body OE_LINEINFO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINEINFO_GRP" AS
/* $Header: OEXLIFOB.pls 120.0 2005/06/01 00:37:00 appldev noship $ */

/*
 column unit_discount_amount will have positive sign if list line type code is a DIS (discount)
and negative sign if list line type code is a SUR (Surcharge).
*/
Procedure Get_Adjustments(p_header_id     IN  NUMBER
			  ,p_line_id      IN  NUMBER
			  ,x_adj_detail    OUT nocopy OE_Header_Adj_Util.line_adjustments_tab_type
			  ,x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

l_line_adj_tbl OE_Header_Adj_Util.line_adjustments_tab_type;

Begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OE_Header_Adj_Util.Get_Line_Adjustments(p_header_id => p_header_id
		                         ,p_line_id   => p_line_id
					 ,x_line_adjustments => x_adj_detail
					 );

  Exception
     When Others Then
       x_return_status := FND_API.G_RET_STS_ERROR;
End;

Procedure Get_Total_Tax(p_header_id IN NUMBER
			 ,x_order_tax_total OUT nocopy NUMBER
			 ,x_return_status OUT nocopy VARCHAR2) IS
   l_order_tax_total  Number;
   l_return_tax_total Number;
Begin
  x_return_status:=FND_API.G_RET_STS_SUCCESS;
  SELECT SUM(tax_value)
  INTO  l_order_tax_total
  FROM oe_order_lines_all
  WHERE header_id=p_header_id
  AND charge_periodicity_code is NULL
  AND NVL(cancelled_flag,'N') ='N'
  AND line_category_code<>'RETURN';


  SELECT SUM(tax_value)
  INTO  l_return_tax_total
  FROM oe_order_lines_all
  WHERE header_id=p_header_id
  AND charge_periodicity_code is NULL
  AND NVL(cancelled_flag,'N') ='N'
  AND line_category_code='RETURN';

  x_order_tax_total:= l_order_tax_total - l_return_tax_total;

Exception When others THEN
  x_order_tax_total:=NULL;
  x_return_status:= FND_API.G_RET_STS_ERROR;

  oe_debug_pub.add(SQLERRM);
  oe_debug_pub.add('header id passed in:'||p_header_id);
End;

Procedure Get_Tax(p_header_id IN NUMBER
		  ,p_line_id  IN NUMBER
		  ,x_tax_rec OUT nocopy oe_lineinfo_grp.tax_rec_type
		  ,x_return_status OUT NOCOPY VARCHAR2) IS

Begin
   x_return_status:=FND_API.G_RET_STS_SUCCESS;

   SELECT tax_code,tax_rate,tax_value,tax_date,tax_exempt_flag,tax_exempt_number,tax_exempt_reason_code
   into    x_tax_rec.tax_code,
           x_tax_rec.tax_rate,
           x_tax_rec.tax_amount,
           x_tax_rec.tax_date,
           x_tax_rec.tax_exempt_flag,
           x_tax_rec.tax_exempt_number,
           x_tax_rec.tax_exempt_reason_code
   FROM oe_order_lines_all
   Where header_id = p_header_id
   and   line_id   = p_line_id;

Exception When others THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR;
   oe_debug_pub.add(SQLERRM);
   oe_debug_pub.add('header id passed in:'||p_header_id||' line id:'||p_line_id);
End;

End  OE_LINEINFO_GRP;

/
