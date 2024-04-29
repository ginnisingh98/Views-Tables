--------------------------------------------------------
--  DDL for Package Body QP_DENORMALIZED_PRICING_ATTRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DENORMALIZED_PRICING_ATTRS" AS
/* $Header: QPXDNPAB.pls 120.0.12010000.3 2009/01/12 06:52:04 smbalara ship $ */

--Procedure to update the distinct row-count of pricing attributes per
--list_header_id

PROCEDURE Update_Row_Count(p_list_header_id_low  IN NUMBER,
                           p_list_header_id_high IN NUMBER);
/* Added for bug 7309559 */
PROCEDURE PREPARE_INPUT_DATA(
  err_buff out nocopy varchar2,
  retcode out  nocopy number,
  p_list_header_id_low in out nocopy number,
  p_list_header_id_high in out nocopy number,
  p_list_header_id_tbl in out nocopy num_type,
  p_update_type in varchar2
) is
  l_list_header_id_tbl     num_type;
  l_list_header_id_low   NUMBER;
  l_list_header_id_high  NUMBER;
BEGIN
 OE_DEBUG_PUB.ADD('Inside QP_Denormalized_Pricing_Attrs :PREPARE_INPUT_DATA');
  --Order the parameters and get correct values if null
  IF p_list_header_id_low IS NULL AND p_list_header_id_high IS NULL THEN
    BEGIN
      SELECT min(list_header_id), max(list_header_id)
      INTO   l_list_header_id_low, l_list_header_id_high
      FROM   qp_list_headers_b
      WHERE  list_type_code = 'PML';

    EXCEPTION
      WHEN OTHERS THEN
        l_list_header_id_low := 0;
        l_list_header_id_high := 0;
    END;

  ELSIF p_list_header_id_low IS NOT NULL AND p_list_header_id_high IS NULL THEN
    l_list_header_id_low := p_list_header_id_low;
    l_list_header_id_high := p_list_header_id_low;

  ELSIF p_list_header_id_low IS NULL AND p_list_header_id_high IS NOT NULL THEN
    l_list_header_id_low := p_list_header_id_high;
    l_list_header_id_high := p_list_header_id_high;

  ELSE
    l_list_header_id_low := least(p_list_header_id_low,p_list_header_id_high);
    l_list_header_id_high := greatest(p_list_header_id_low,p_list_header_id_high);
  END IF; --If stmt to check values of parameters p_list_header_id_low and high

  --Bulk Collect the Factor List Header Ids into l_list_header_id_tbl
  SELECT list_header_id
  BULK COLLECT INTO l_list_header_id_tbl
  FROM   qp_list_headers_b
  WHERE  list_type_code = 'PML'
  AND    list_header_id BETWEEN l_list_header_id_low AND l_list_header_id_high;

  p_list_header_id_tbl := l_list_header_id_tbl;
  p_list_header_id_low := l_list_header_id_low;
  p_list_header_id_high := l_list_header_id_high;

EXCEPTION
  WHEN OTHERS THEN
    err_buff := sqlerrm;
    retcode := 2;
END PREPARE_INPUT_DATA;

PROCEDURE UPDATE_SEARCH_IND(
  err_buff out nocopy  varchar2,
  retcode out  nocopy number,
  p_list_header_id_low in number,
  p_list_header_id_high in number,
  p_list_header_id_tbl in num_type,
  p_update_type in varchar2 default 'BATCH'
) IS
  l_pricing_attr_id_tbl    num_type;
  l_list_line_id_tbl       num_type;
  l_list_header_id_tbl     num_type;
  l_list_header_id_low   NUMBER;
  l_list_header_id_high  NUMBER;
BEGIN

  l_list_header_id_tbl := p_list_header_id_tbl;
  l_list_header_id_low := p_list_header_id_low;
  l_list_header_id_high := p_list_header_id_high;

  OE_DEBUG_PUB.ADD('Inside QP_Denormalized_Pricing_Attrs :UPDATE_SEARCH_IND');
  --Update Distinct_Row_Count for factor pricing attributes
  QP_Denormalized_Pricing_Attrs.Update_Row_Count(l_list_header_id_low, l_list_header_id_high);

  --Set the format mask for the canonical form of numbers
  --fnd_number.canonical_mask := '00999999999999999999999.99999999999999999999999999999999999999';

  IF l_list_header_id_tbl.COUNT > 0 THEN
    --Reset the search_ind value for the factor qp_pricing_attributes initially.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    search_ind = null
      WHERE  list_header_id = l_list_header_id_tbl(k);
  END IF; --If l_list_header_id_tbl.COUNT > 0

  --Select those rows from qp_pricing_attributes where the distinct_row_count
  --is the lowest value among the pricing attributes for a given list_line_id.
  --If multiple such pricing_attributes exist, pick any one.
SELECT min(a.pricing_attribute_id), a.list_line_id
  BULK COLLECT INTO l_pricing_attr_id_tbl, l_list_line_id_tbl
  FROM   qp_pricing_attributes a
  WHERE  a.distinct_row_count = (SELECT min(b.distinct_row_count)
                                 FROM   qp_pricing_attributes b
                                 WHERE  b.list_line_id = a.list_line_id)
  AND    a.list_header_id IN (SELECT list_header_id
                              FROM   qp_list_headers_b
                              WHERE  list_type_code = 'PML'
                              AND    list_header_id BETWEEN l_list_header_id_low
                                     AND l_list_header_id_high)
  GROUP BY a.list_line_id;

  IF l_pricing_attr_id_tbl.COUNT > 0 THEN
    --For rows selected above update the search_ind to 1.
    FORALL i IN l_pricing_attr_id_tbl.FIRST..l_pricing_attr_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    search_ind = 1
      WHERE  pricing_attribute_id = l_pricing_attr_id_tbl(i);
  END IF; --If l_pricing_attr_id_tbl.COUNT > 0

  l_pricing_attr_id_tbl.DELETE; --Clear the plsql table.


  IF l_list_line_id_tbl.COUNT > 0 THEN
    --Update the search_ind to 2 for the remaining rows with 'BETWEEN' operator
    FORALL j IN l_list_line_id_tbl.FIRST..l_list_line_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    search_ind = 2
      WHERE  (search_ind <> 1 or search_ind IS NULL)
      AND    list_line_id = l_list_line_id_tbl(j);
  END IF; --If l_list_line_id_tbl.COUNT > 0

  l_list_line_id_tbl.DELETE; --Clear the plsql table.


  IF l_list_header_id_tbl.COUNT > 0 THEN
    --Update the group_count column of qp_list_lines with the count of
    --pricing attributes which have search_ind = 2 for each list_line_id
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_list_lines l
      SET    l.group_count = (select count(*)
                              from   qp_pricing_attributes a
                              where  a.list_line_id = l.list_line_id
                              and    a.search_ind = 2)
      WHERE  l.list_header_id = l_list_header_id_tbl(k);
  END IF; --If l_list_header_id_tbl.COUNT > 0

  IF p_update_type IN ('ALL','FACTOR','BATCH') THEN
    commit;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    err_buff := sqlerrm;
    retcode := 2;

END UPDATE_SEARCH_IND;

PROCEDURE UPDATE_SEARCH_IND(
  err_buff out nocopy  varchar2,
  retcode out  nocopy number,
  p_list_header_id_low in number,
  p_list_header_id_high in number,
  p_update_type in varchar2
) IS
  l_list_header_id_tbl    num_type;
  l_list_header_id_low   NUMBER;
  l_list_header_id_high  NUMBER;
BEGIN
  l_list_header_id_low := p_list_header_id_low;
  l_list_header_id_high := p_list_header_id_high;
OE_DEBUG_PUB.ADD('Inside QP_Denormalized_Pricing_Attrs :UPDATE_SEARCH_IND -called from Concurrent Program');
QP_Denormalized_Pricing_Attrs.PREPARE_INPUT_DATA(err_buff,retcode,l_list_header_id_low,l_list_header_id_high,l_list_header_id_tbl,p_update_type);

QP_Denormalized_Pricing_Attrs.UPDATE_SEARCH_IND(err_buff,retcode,l_list_header_id_low,l_list_header_id_high,l_list_header_id_tbl,p_update_type);

END UPDATE_SEARCH_IND;
/* End Bug  -7309559  */

PROCEDURE Update_Row_Count(p_list_header_id_low  IN NUMBER,
                           p_list_header_id_high IN NUMBER)
IS
BEGIN
  OE_DEBUG_PUB.ADD('Inside QP_Denormalized_Pricing_Attrs :Update_Row_Count');
  --Do this only for factor list attributes
  -- Added the hint inside the subquery for bug#3993301
  UPDATE qp_pricing_attributes a
  SET    a.distinct_row_count =
	   (SELECT /*+  INDEX(aa QP_PRICING_ATTRIBUTES_N6) */ count(*)
            FROM   qp_pricing_attributes aa
            WHERE  aa.pricing_attribute_context = a.pricing_attribute_context
            AND    aa.pricing_attribute = a.pricing_attribute
            AND    aa.pricing_attr_value_from = a.pricing_attr_value_from
            AND    nvl(aa.pricing_attr_value_to,'-x') =
                   nvl(a.pricing_attr_value_to,'-x')
            AND    aa.comparison_operator_code = a.comparison_operator_code
            AND    aa.list_header_id  = a.list_header_id
            AND    aa.pricing_attribute_context IS NOT NULL)
  WHERE a.list_header_id IN (SELECT list_header_id
                             FROM   qp_list_headers_b
                             WHERE  list_type_code = 'PML'
                             AND    list_header_id BETWEEN p_list_header_id_low
                                    AND p_list_header_id_high);

END Update_Row_Count;


PROCEDURE Populate_Factor_List_Attrs(
                      p_list_header_id_low  IN NUMBER default null,
                      p_list_header_id_high IN NUMBER default null)
IS
l_list_header_id_low   NUMBER;
l_list_header_id_high  NUMBER;

BEGIN
  OE_DEBUG_PUB.ADD('Inside QP_Denormalized_Pricing_Attrs :Populate_Factor_List_Attrs');
  --Order the parameters and get correct values if null
  IF p_list_header_id_low IS NULL AND p_list_header_id_high IS NULL THEN
    BEGIN
      SELECT min(list_header_id), max(list_header_id)
      INTO   l_list_header_id_low, l_list_header_id_high
      FROM   qp_list_headers_b
      WHERE  list_type_code = 'PML';
    EXCEPTION
      WHEN OTHERS THEN
        l_list_header_id_low := 0;
        l_list_header_id_high := 0;
    END;

  ELSIF p_list_header_id_low IS NOT NULL AND p_list_header_id_high IS NULL THEN
    l_list_header_id_low := p_list_header_id_low;
    l_list_header_id_high := p_list_header_id_low;

  ELSIF p_list_header_id_low IS NULL AND p_list_header_id_high IS NOT NULL THEN
    l_list_header_id_low := p_list_header_id_high;
    l_list_header_id_high := p_list_header_id_high;

  ELSE
    l_list_header_id_low := least(p_list_header_id_low,p_list_header_id_high);
    l_list_header_id_high := greatest(p_list_header_id_low,p_list_header_id_high
);
  END IF; --If stmt to check values of parameters p_list_header_id_low and high


  DELETE FROM qp_factor_list_attrs
  WHERE  list_header_id BETWEEN l_list_header_id_low AND l_list_header_id_high;


  INSERT INTO qp_factor_list_attrs
   (SELECT DISTINCT a.list_header_id,
           a.pricing_attribute_context, a.pricing_attribute
    FROM   qp_pricing_attributes a, qp_list_headers_b b
    WHERE  a.list_header_id = b.list_header_id
    AND    b.list_type_code = 'PML'
    AND    b.list_header_id BETWEEN
           l_list_header_id_low AND l_list_header_id_high);
  EXCEPTION
 	WHEN OTHERS THEN
	RAISE;
END Populate_Factor_List_Attrs;


PROCEDURE Update_Pricing_Attributes(
                     p_list_header_id_low  IN NUMBER default null,
                     p_list_header_id_high IN NUMBER default null,
                     p_update_type         IN VARCHAR2 default 'BATCH')
IS

l_pricing_attr_id_tbl    num_type;
l_list_line_id_tbl       num_type;
l_list_header_id_tbl     num_type;

l_list_header_id_low   NUMBER:=0;
l_list_header_id_high  NUMBER:=0;
err_buff varchar2(2000):=' ';
retcode number:=0;
l_perf varchar2(30);
BEGIN

l_list_header_id_low := p_list_header_id_low;
l_list_header_id_high := p_list_header_id_high;

OE_DEBUG_PUB.ADD('Inside QP_Denormalized_Pricing_Attrs :Update_Pricing_Attributes');

/*Added for bug# 7143714 for performance contrrol*/
QP_Denormalized_Pricing_Attrs.PREPARE_INPUT_DATA(err_buff,retcode,l_list_header_id_low,l_list_header_id_high,l_list_header_id_tbl,p_update_type);

l_perf := nvl(FND_PROFILE.VALUE(g_perf), g_off);

OE_DEBUG_PUB.ADD('PErformance Control Profile is '||l_perf);

if (l_perf = g_off) then
QP_Denormalized_Pricing_Attrs.UPDATE_SEARCH_IND(err_buff,retcode,l_list_header_id_low,l_list_header_id_high,l_list_header_id_tbl,p_update_type);
end if;
/*End Bug 7309559*/

  --Update the pattern_value_from and pattern_value_to columns with canonical
  --form of the pricing_attr_value_from_number and to_number columns if
  --datatype = 'N'and for other datatypes, populate the pricing_attr_value_from
  --and to in the pattern_value_from and pattern_value_to columns

   --Set the format mask for the canonical form of numbers --bug 7696883
  qp_number.canonical_mask := '00999999999999999999999.99999999999999999999999999999999999999';

  IF l_list_header_id_tbl.COUNT > 0 THEN
    --When pricing attribute datatype is 'N', operator is between and both
    --pricing_attr_value_from and pricing_attr_value_to are negative.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_negative =
           LEAST(qp_number.number_to_canonical(pricing_attr_value_from_number),
                 qp_number.number_to_canonical(pricing_attr_value_to_number)),
           pattern_value_to_negative =
           GREATEST(
                 qp_number.number_to_canonical(pricing_attr_value_from_number),
                 qp_number.number_to_canonical(pricing_attr_value_to_number)),
           pattern_value_from_positive = null,
           pattern_value_to_positive = null
      WHERE  comparison_operator_code = 'BETWEEN'
      AND    pricing_attribute_datatype = 'N'
      AND    list_header_id = l_list_header_id_tbl(k)
      AND    pricing_attr_value_from_number < 0
      AND    pricing_attr_value_to_number < 0;

    --When pricing attribute datatype is 'N', operator is between and both
    --pricing_attr_value_from and pricing_attr_value_to are positive.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_positive =
           LEAST(qp_number.number_to_canonical(pricing_attr_value_from_number),
                 qp_number.number_to_canonical(pricing_attr_value_to_number)),
           pattern_value_to_positive =
           GREATEST(
                 qp_number.number_to_canonical(pricing_attr_value_from_number),
                 qp_number.number_to_canonical(pricing_attr_value_to_number)),
           pattern_value_from_negative = null,
           pattern_value_to_negative = null
      WHERE  comparison_operator_code = 'BETWEEN'
      AND    pricing_attribute_datatype = 'N'
      AND    list_header_id = l_list_header_id_tbl(k)
      AND    pricing_attr_value_from_number >= 0
      AND    pricing_attr_value_to_number >= 0;

    --When pricing_attr_value_from is negative,pricing_attr_value_to is 0,
    --operator is between and pricing attribute datatype is 'N'.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_negative =
                 '-' || LTRIM(qp_number.number_to_canonical(0)),
             pattern_value_to_negative =
                 qp_number.number_to_canonical(pricing_attr_value_from_number),
             pattern_value_from_positive = null,
             pattern_value_to_positive = null
      WHERE  comparison_operator_code = 'BETWEEN'
      AND    pricing_attribute_datatype = 'N'
      AND    list_header_id = l_list_header_id_tbl(k)
      AND    pricing_attr_value_from_number < 0
      AND    pricing_attr_value_to_number = 0;

    --When pricing_attr_value_from is negative,pricing_attr_value_to is
    --positive, operator is between and pricing attribute datatype is 'N'.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_negative =
                 '-' || LTRIM(qp_number.number_to_canonical(0)),
             pattern_value_to_negative =
                 qp_number.number_to_canonical(pricing_attr_value_from_number),
             pattern_value_from_positive = qp_number.number_to_canonical(0),
             pattern_value_to_positive =
                 qp_number.number_to_canonical(pricing_attr_value_to_number)
      WHERE  comparison_operator_code = 'BETWEEN'
      AND    pricing_attribute_datatype = 'N'
      AND    list_header_id = l_list_header_id_tbl(k)
      AND    pricing_attr_value_from_number < 0
      AND    pricing_attr_value_to_number > 0;

    --When operator is '=' and pricing attribute datatype is 'N' and
    --pricing_attr_value_from is positive.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_positive =
               qp_number.number_to_canonical(pricing_attr_value_from_number),
             pattern_value_to_positive =
               qp_number.number_to_canonical(pricing_attr_value_from_number),
             pattern_value_from_negative = null,
             pattern_value_to_negative = null
      WHERE  comparison_operator_code = '='
      AND    pricing_attribute_datatype = 'N'
      AND    list_header_id = l_list_header_id_tbl(k)
      AND    pricing_attr_value_from_number >= 0;

    --When operator is '=' and pricing attribute datatype is 'N' and
    --pricing_attr_value_from is negative.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_negative =
               qp_number.number_to_canonical(pricing_attr_value_from_number),
             pattern_value_to_negative =
               qp_number.number_to_canonical(pricing_attr_value_from_number),
             pattern_value_from_positive = null,
             pattern_value_to_positive = null
      WHERE  comparison_operator_code = '='
      AND    pricing_attribute_datatype = 'N'
      AND    list_header_id = l_list_header_id_tbl(k)
      AND    pricing_attr_value_from_number < 0;

    --When pricing attribute datatype is 'X', 'Y' or 'C' and operator is between
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_positive =
                      LEAST(pricing_attr_value_from, pricing_attr_value_to),
             pattern_value_to_positive =
                      GREATEST(pricing_attr_value_from, pricing_attr_value_to),
             pattern_value_from_negative = null,
             pattern_value_to_negative = null
      WHERE  comparison_operator_code = 'BETWEEN'
      AND    pricing_attribute_datatype IN ('X','Y','C')
      AND    list_header_id = l_list_header_id_tbl(k);

    --When pricing attribute datatype is 'X', 'Y' or 'C' and operator is '='.
    FORALL k IN l_list_header_id_tbl.FIRST..l_list_header_id_tbl.LAST
      UPDATE qp_pricing_attributes
      SET    pattern_value_from_positive = pricing_attr_value_from,
             pattern_value_to_positive = pricing_attr_value_from,
             pattern_value_from_negative = null,
             pattern_value_to_negative = null
      WHERE  comparison_operator_code = '='
      AND    pricing_attribute_datatype IN ('X','Y','C')
      AND    list_header_id = l_list_header_id_tbl(k);

  END IF; --If l_list_header_id_tbl.COUNT > 0

  IF p_update_type IN ('ALL','FACTOR','BATCH') THEN
    commit;
  END IF;

  l_list_header_id_tbl.DELETE; --Clear the plsql table.

  --Set the format mask for the canonical form of numbers
  qp_number.canonical_mask := 'FM999999999999999999999.9999999999999999999999999999999999999999';

  --dbms_output.put_line('Updated Search_Ind columns');
  --dbms_output.put_line('Updated Pattern_value_from/Pattern_value_to columns');

EXCEPTION
  WHEN OTHERS THEN
    --dbms_output.put_line('ERR:'||substr(sqlerrm, 1, 240));
    RAISE;

END Update_Pricing_Attributes;

END QP_Denormalized_Pricing_Attrs;

/
