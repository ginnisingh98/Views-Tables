--------------------------------------------------------
--  DDL for Package Body QP_LOCK_PRICELIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LOCK_PRICELIST_PVT" AS
/* $Header: QPXLKPLB.pls 120.8 2006/05/16 23:57:20 srashmi ship $ */

/***************************************************************************
* Utility Procedures and Functions for Price Locking
****************************************************************************/

--Function to query a Price List Line and if is a PBH also its child break lines
FUNCTION Query_Rows(p_list_header_id  IN  NUMBER,
                    p_list_line_id    IN  NUMBER)
RETURN QP_Price_List_PUB.Price_List_Line_Tbl_Type
IS
  l_PRICE_LIST_LINE_rec         QP_Price_List_PUB.Price_List_Line_Rec_Type;
  l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;

  CURSOR price_list_line_cur(a_list_header_id  NUMBER, a_list_line_id  NUMBER)
  IS
    SELECT  ACCRUAL_QTY
    ,       ACCRUAL_UOM_CODE
    ,       ARITHMETIC_OPERATOR
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTOMATIC_FLAG
    ,       BASE_QTY
    ,       BASE_UOM_CODE
    ,       COMMENTS
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       EFFECTIVE_PERIOD_UOM
    ,       END_DATE_ACTIVE
    ,       ESTIM_ACCRUAL_RATE
    ,       GENERATE_USING_FORMULA_ID
    ,       INVENTORY_ITEM_ID
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LIST_HEADER_ID
    ,       LIST_LINE_ID
    ,       LIST_LINE_NO
    ,       LIST_LINE_TYPE_CODE
    ,       LIST_PRICE
    ,       PRODUCT_PRECEDENCE
    ,       MODIFIER_LEVEL_CODE
    ,       NUMBER_EFFECTIVE_PERIODS
    ,       OPERAND
    ,       ORGANIZATION_ID
    ,       OVERRIDE_FLAG
    ,       PERCENT_PRICE
    ,       PRICE_BREAK_TYPE_CODE
    ,       PRICE_BY_FORMULA_ID
    ,       PRIMARY_UOM_FLAG
    ,       PRINT_ON_INVOICE_FLAG
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       REBATE_TRANSACTION_TYPE_CODE
    ,       RELATED_ITEM_ID
    ,       RELATIONSHIP_TYPE_ID
    ,       REPRICE_FLAG
    ,       REQUEST_ID
    ,       REVISION
    ,       REVISION_DATE
    ,       REVISION_REASON_CODE
    ,       START_DATE_ACTIVE
    ,       SUBSTITUTION_ATTRIBUTE
    ,       SUBSTITUTION_CONTEXT
    ,       SUBSTITUTION_VALUE
    ,       QUALIFICATION_IND
    ,       RECURRING_VALUE -- block pricing
    ,       CUSTOMER_ITEM_ID
    ,       BREAK_UOM_CODE
    ,       BREAK_UOM_CONTEXT
    ,       BREAK_UOM_ATTRIBUTE
    ,       CONTINUOUS_PRICE_BREAK_FLAG
    FROM    QP_LIST_LINES l
    WHERE   l.LIST_HEADER_ID = a_list_header_id
    AND    (l.LIST_LINE_ID = a_list_line_id OR
            EXISTS (SELECT 'x'
                    FROM   QP_RLTD_MODIFIERS
                    WHERE  TO_RLTD_MODIFIER_ID = l.LIST_LINE_ID
                    AND    FROM_RLTD_MODIFIER_ID = a_list_line_id)
           );

BEGIN

  --Loop over fetched records
  IF (p_list_header_id IS NOT NULL) AND (p_list_line_id IS NOT NULL)
  THEN

    FOR l_rec IN price_list_line_cur (p_list_header_id, p_list_line_id)
    LOOP
      l_PRICE_LIST_LINE_rec.accrual_qty := l_rec.ACCRUAL_QTY;
      l_PRICE_LIST_LINE_rec.accrual_uom_code := l_rec.ACCRUAL_UOM_CODE;
      l_PRICE_LIST_LINE_rec.arithmetic_operator := l_rec.ARITHMETIC_OPERATOR;
      l_PRICE_LIST_LINE_rec.attribute1 := l_rec.ATTRIBUTE1;
      l_PRICE_LIST_LINE_rec.attribute10 := l_rec.ATTRIBUTE10;
      l_PRICE_LIST_LINE_rec.attribute11 := l_rec.ATTRIBUTE11;
      l_PRICE_LIST_LINE_rec.attribute12 := l_rec.ATTRIBUTE12;
      l_PRICE_LIST_LINE_rec.attribute13 := l_rec.ATTRIBUTE13;
      l_PRICE_LIST_LINE_rec.attribute14 := l_rec.ATTRIBUTE14;
      l_PRICE_LIST_LINE_rec.attribute15 := l_rec.ATTRIBUTE15;
      l_PRICE_LIST_LINE_rec.attribute2 := l_rec.ATTRIBUTE2;
      l_PRICE_LIST_LINE_rec.attribute3 := l_rec.ATTRIBUTE3;
      l_PRICE_LIST_LINE_rec.attribute4 := l_rec.ATTRIBUTE4;
      l_PRICE_LIST_LINE_rec.attribute5 := l_rec.ATTRIBUTE5;
      l_PRICE_LIST_LINE_rec.attribute6 := l_rec.ATTRIBUTE6;
      l_PRICE_LIST_LINE_rec.attribute7 := l_rec.ATTRIBUTE7;
      l_PRICE_LIST_LINE_rec.attribute8 := l_rec.ATTRIBUTE8;
      l_PRICE_LIST_LINE_rec.attribute9 := l_rec.ATTRIBUTE9;
      l_PRICE_LIST_LINE_rec.automatic_flag := l_rec.AUTOMATIC_FLAG;
      l_PRICE_LIST_LINE_rec.base_qty := l_rec.BASE_QTY;
      l_PRICE_LIST_LINE_rec.base_uom_code := l_rec.BASE_UOM_CODE;
      l_PRICE_LIST_LINE_rec.comments := l_rec.COMMENTS;
      l_PRICE_LIST_LINE_rec.context  := l_rec.CONTEXT;
      l_PRICE_LIST_LINE_rec.created_by := l_rec.CREATED_BY;
      l_PRICE_LIST_LINE_rec.creation_date := l_rec.CREATION_DATE;
      l_PRICE_LIST_LINE_rec.effective_period_uom := l_rec.EFFECTIVE_PERIOD_UOM;
      l_PRICE_LIST_LINE_rec.end_date_active := l_rec.END_DATE_ACTIVE;
      l_PRICE_LIST_LINE_rec.estim_accrual_rate := l_rec.ESTIM_ACCRUAL_RATE;
      l_PRICE_LIST_LINE_rec.generate_using_formula_id :=
                                 l_rec.GENERATE_USING_FORMULA_ID;
      l_PRICE_LIST_LINE_rec.inventory_item_id := l_rec.INVENTORY_ITEM_ID;
      l_PRICE_LIST_LINE_rec.last_updated_by := l_rec.LAST_UPDATED_BY;
      l_PRICE_LIST_LINE_rec.last_update_date := l_rec.LAST_UPDATE_DATE;
      l_PRICE_LIST_LINE_rec.last_update_login := l_rec.LAST_UPDATE_LOGIN;
      l_PRICE_LIST_LINE_rec.list_header_id := l_rec.LIST_HEADER_ID;
      l_PRICE_LIST_LINE_rec.list_line_id := l_rec.LIST_LINE_ID;
      l_PRICE_LIST_LINE_rec.list_line_no := l_rec.LIST_LINE_NO;
      l_PRICE_LIST_LINE_rec.list_line_type_code := l_rec.LIST_LINE_TYPE_CODE;
      l_PRICE_LIST_LINE_rec.list_price := l_rec.LIST_PRICE;
      l_PRICE_LIST_LINE_rec.product_precedence := l_rec.PRODUCT_PRECEDENCE;
      l_PRICE_LIST_LINE_rec.modifier_level_code := l_rec.MODIFIER_LEVEL_CODE;
      l_PRICE_LIST_LINE_rec.number_effective_periods :=
                               l_rec.NUMBER_EFFECTIVE_PERIODS;
      l_PRICE_LIST_LINE_rec.operand  := l_rec.OPERAND;
      l_PRICE_LIST_LINE_rec.organization_id := l_rec.ORGANIZATION_ID;
      l_PRICE_LIST_LINE_rec.override_flag := l_rec.OVERRIDE_FLAG;
      l_PRICE_LIST_LINE_rec.percent_price := l_rec.PERCENT_PRICE;
      l_PRICE_LIST_LINE_rec.price_break_type_code :=
                               l_rec.PRICE_BREAK_TYPE_CODE;
      l_PRICE_LIST_LINE_rec.price_by_formula_id := l_rec.PRICE_BY_FORMULA_ID;
      l_PRICE_LIST_LINE_rec.primary_uom_flag := l_rec.PRIMARY_UOM_FLAG;
      l_PRICE_LIST_LINE_rec.print_on_invoice_flag :=
                               l_rec.PRINT_ON_INVOICE_FLAG;
      l_PRICE_LIST_LINE_rec.program_application_id :=
                               l_rec.PROGRAM_APPLICATION_ID;
      l_PRICE_LIST_LINE_rec.program_id := l_rec.PROGRAM_ID;
      l_PRICE_LIST_LINE_rec.program_update_date := l_rec.PROGRAM_UPDATE_DATE;
      l_PRICE_LIST_LINE_rec.rebate_trxn_type_code :=
                               l_rec.REBATE_TRANSACTION_TYPE_CODE;
      l_PRICE_LIST_LINE_rec.related_item_id := l_rec.RELATED_ITEM_ID;
      l_PRICE_LIST_LINE_rec.relationship_type_id := l_rec.RELATIONSHIP_TYPE_ID;
      l_PRICE_LIST_LINE_rec.reprice_flag := l_rec.REPRICE_FLAG;
      l_PRICE_LIST_LINE_rec.request_id := l_rec.REQUEST_ID;
      l_PRICE_LIST_LINE_rec.revision := l_rec.REVISION;
      l_PRICE_LIST_LINE_rec.revision_date := l_rec.REVISION_DATE;
      l_PRICE_LIST_LINE_rec.revision_reason_code := l_rec.REVISION_REASON_CODE;
      l_PRICE_LIST_LINE_rec.start_date_active := l_rec.START_DATE_ACTIVE;
      l_PRICE_LIST_LINE_rec.substitution_attribute :=
                               l_rec.SUBSTITUTION_ATTRIBUTE;
      l_PRICE_LIST_LINE_rec.substitution_context := l_rec.SUBSTITUTION_CONTEXT;
      l_PRICE_LIST_LINE_rec.substitution_value := l_rec.SUBSTITUTION_VALUE;
      l_PRICE_LIST_LINE_rec.qualification_ind := l_rec.QUALIFICATION_IND;
      l_PRICE_LIST_LINE_rec.recurring_value := l_rec.RECURRING_VALUE;
      l_PRICE_LIST_LINE_rec.customer_item_id := l_rec.CUSTOMER_ITEM_ID;
      l_PRICE_LIST_LINE_rec.break_uom_code := l_rec.BREAK_UOM_CODE;
      l_PRICE_LIST_LINE_rec.break_uom_context := l_rec.BREAK_UOM_CONTEXT;
      l_PRICE_LIST_LINE_rec.break_uom_attribute := l_rec.BREAK_UOM_ATTRIBUTE;
      l_PRICE_LIST_LINE_rec.continuous_price_break_flag := l_rec.CONTINUOUS_PRICE_BREAK_FLAG;

      BEGIN
        SELECT  RLTD_MODIFIER_GRP_NO,
                RLTD_MODIFIER_GRP_TYPE,
                FROM_RLTD_MODIFIER_ID,
                TO_RLTD_MODIFIER_ID,
                RLTD_MODIFIER_ID
        INTO    l_PRICE_LIST_LINE_rec.rltd_modifier_group_no,
                l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type,
                l_PRICE_LIST_LINE_rec.from_rltd_modifier_id,
                l_PRICE_LIST_LINE_rec.to_rltd_modifier_id,
                l_PRICE_LIST_LINE_rec.rltd_modifier_id
        FROM    QP_RLTD_MODIFIERS
        WHERE   TO_RLTD_MODIFIER_ID = l_rec.LIST_LINE_ID;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_PRICE_LIST_LINE_rec.rltd_modifier_group_no := null;
          l_PRICE_LIST_LINE_rec.rltd_modifier_grp_type := null;
          l_PRICE_LIST_LINE_rec.from_rltd_modifier_id := null;
          l_PRICE_LIST_LINE_rec.to_rltd_modifier_id := null;
          l_PRICE_LIST_LINE_rec.rltd_modifier_id := null;
      END;

      l_PRICE_LIST_LINE_tbl(l_PRICE_LIST_LINE_tbl.COUNT+1) :=
                                             l_PRICE_LIST_LINE_rec;

    END LOOP;

  END IF;

  RETURN l_PRICE_LIST_LINE_tbl;

END Query_Rows;


PROCEDURE Get_Price_List
(p_list_header_id                IN  NUMBER,
 p_list_line_id                  IN  NUMBER,
 x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type,
 x_PRICE_LIST_LINE_tbl           OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Line_Tbl_Type,
 x_QUALIFIERS_tbl                OUT NOCOPY /* file.sql.39 change */ Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type,
 x_PRICING_ATTR_tbl              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Tbl_Type,
 x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
 x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER,
 x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;
l_PRICE_LIST_LINE_tbl         QP_Price_List_PUB.Price_List_Line_Tbl_Type;
l_QUALIFIERS_tbl              Qp_Qualifier_Rules_Pub.Qualifiers_Tbl_Type;
l_PRICING_ATTR_tbl            QP_Price_List_PUB.Pricing_Attr_Tbl_Type;
l_x_PRICING_ATTR_tbl          QP_Price_List_PUB.Pricing_Attr_Tbl_Type;

BEGIN
  --Get Price List Header
  l_PRICE_LIST_rec :=  QP_Price_List_Util.Query_Row
    (p_list_header_id => p_list_header_id);

  --Get Price List Lines
  l_PRICE_LIST_LINE_tbl :=  Query_Rows
        (p_list_header_id => l_PRICE_LIST_rec.list_header_id,
         p_list_line_id => p_list_line_id);

  --Loop over Price List Line's children
  FOR i2 IN 1..l_PRICE_LIST_LINE_tbl.COUNT
  LOOP
    --Get Pricing Attributes
    l_PRICING_ATTR_tbl :=  Qp_pll_pricing_attr_Util.Query_Rows
            (p_list_line_id  => l_PRICE_LIST_LINE_tbl(i2).list_line_id);

    FOR i3 IN 1..l_PRICING_ATTR_tbl.COUNT
    LOOP
      l_PRICING_ATTR_tbl(i3).PRICE_LIST_LINE_Index := i2;
      l_x_PRICING_ATTR_tbl
                (l_x_PRICING_ATTR_tbl.COUNT + 1) := l_PRICING_ATTR_tbl(i3);
    END LOOP;
  END LOOP; --Loop over Price List Lines

  --Get Qualifiers
  l_QUALIFIERS_tbl :=  QP_Qualifiers_Util_Mod.Query_Rows
        (p_list_header_id => l_PRICE_LIST_rec.list_header_id);

  --Load out parameters
  x_PRICE_LIST_rec               := l_PRICE_LIST_rec;
  x_PRICE_LIST_LINE_tbl          := l_PRICE_LIST_LINE_tbl;
  x_QUALIFIERS_tbl               := l_QUALIFIERS_tbl;
  x_PRICING_ATTR_tbl             := l_x_PRICING_ATTR_tbl;

  --  Set return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Get message count and data
  fnd_msg_pub.Count_And_Get (p_count => x_msg_count,
                             p_data  => x_msg_data);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || 'Get_Price_List',
                      'Others Exception: '||substr(sqlerrm, 1, 240));
    END IF;

    fnd_msg_pub.Add_Exc_Msg
    (   G_PKG_NAME
    ,   'Get_Price_List'
    ,   substr(sqlerrm, 1, 240)
    );

    --Get message count and data
    fnd_msg_pub.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

END Get_Price_List;



/***************************************************************************
* Lock_Price API
***************************************************************************/
PROCEDURE Lock_Price (p_source_price_list_id	   IN	NUMBER,
		      p_source_list_line_id	   IN	NUMBER,
                      p_startup_mode               IN   VARCHAR2,
                      p_orig_system_header_ref     IN   VARCHAR2,
                      p_org_id                     IN   NUMBER DEFAULT NULL,
                      p_commit                     IN   VARCHAR2 DEFAULT 'F',
                      --added for OKS bug 4504825
                      x_locked_price_list_id       OUT  NOCOPY 	NUMBER,
                      x_locked_list_line_id        OUT 	NOCOPY 	NUMBER,
                      x_return_status              OUT 	NOCOPY 	VARCHAR2,
 		      x_msg_count                  OUT 	NOCOPY 	NUMBER,
		      x_msg_data                   OUT 	NOCOPY 	VARCHAR2)
IS

l_source_system_code	VARCHAR2(30);
l_locked_price_list_id	NUMBER;
l_pte_code		VARCHAR2(30);

p_control_rec  			QP_GLOBALS.Control_Rec_Type;

p_price_list_rec 		QP_PRICE_LIST_PUB.Price_List_Rec_Type;
p_price_list_line_tbl 		QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
p_pricing_attr_tbl 		QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;

x_price_list_rec 		QP_PRICE_LIST_PUB.Price_List_Rec_Type;
x_price_list_line_tbl 		QP_PRICE_LIST_PUB.Price_List_Line_Tbl_Type;
x_pricing_attr_tbl 		QP_PRICE_LIST_PUB.Pricing_Attr_Tbl_Type;
x_qualifiers_tbl  		QP_QUALIFIER_RULES_PUB.Qualifiers_Tbl_Type;

i number := 1;
ii number := 1;
j number := 1;
jj number := 1;
k number := 1;

l_name    VARCHAR2(240);
l_blank   NUMBER;
l_number_String  VARCHAR2(240);

BEGIN

  FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE',l_source_system_code);

  FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);

  BEGIN
    SELECT list_header_id
    INTO   l_locked_price_list_id
    FROM   qp_list_headers_b
    WHERE  locked_from_list_header_id = p_source_price_list_id
    AND    source_system_code = l_source_system_code
    AND    rownum = 1; --only one row is expected anyway.

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_locked_price_list_id := null;

  END;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'Entered procedure');
  END IF;

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'p_source_price_list_id = '||p_source_price_list_id ||
                      ' and ' ||
                      'p_source_list_line_id = ' || p_source_list_line_id);
  END IF;

  --Get source price list and its child (all levels) records.
  Get_Price_List(
	p_list_header_id	=> p_source_price_list_id,
	p_list_line_id          => p_source_list_line_id,
	x_PRICE_LIST_rec        => x_price_list_rec,
	x_PRICE_LIST_LINE_tbl   => x_price_list_line_tbl,
	x_QUALIFIERS_tbl        => x_qualifiers_tbl,
	x_PRICING_ATTR_tbl      => x_pricing_attr_tbl,
	x_return_status         => x_return_status,
	x_msg_count             => x_msg_count,
	x_msg_data              => x_msg_data);

  IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'l_locked_price_list_id = '|| l_locked_price_list_id);
  END IF;

  IF l_locked_price_list_id IS NULL THEN
    --Create new locked_price_list, line, etc.

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'l_locked_price_list_id is null ');
    END IF;

    --While copying the output records of the Get_Price_List call (which
    --correspond to the source price list) to the input records for the
    --Process_Price_List procedure call, retain only the source price list
    --line and its children. Also, the source pricelist's qualifiers should
    --not be copied since the the qualifiers won't be relevant to the locked
    --price list and line.


    --Copy the pricelist header record to the input record structure and set
    --the appropriate column values.
    p_price_list_rec := x_price_list_rec;
    p_price_list_rec.list_header_id := FND_API.G_MISS_NUM;


    IF (instr (p_price_list_rec.name, l_source_system_code || ' LOCKED') <> 0)
         --The source price list itself is a locked price list
    THEN
        l_name := replace(p_price_list_rec.name, l_source_system_code ||
                         ' LOCKED');
		--Strip the prefix upto LOCKED, not including the number
                --component, if any, or blank separator.

        l_blank := instr(l_name, ' '); --Get position of blank separator
                        --expected after the number component of LOCKED keyword.

        IF l_blank = 1 THEN --blank occurs in first position of remaining
                            --string, so no number associated with 'LOCKED'
           p_price_list_rec.name := l_source_system_code || ' LOCKED2 ' ||
                     substr(l_name, 2); --Start the numbering from 2

        ELSIF l_blank > 1 THEN --A number component exists in prefix of a
                               --previously locked price list.
           l_number_string  := Substr(l_name, 1, l_blank - 1);
           BEGIN
             p_price_list_rec.name := l_source_system_code || ' LOCKED' ||
 			to_char(to_number(l_number_string) + 1) ||
                        ' ' || substr(l_name, l_blank + 1);
                  --Increase the number component in the prefix of
                  --locked price list by 1
           EXCEPTION
             WHEN OTHERS THEN -- Such as invalid number error due to
                              -- non-numeric chars present instead of the
                              -- expected number in a previously locked PL
               p_price_list_rec.name := l_source_system_code || ' LOCKED ' ||
                               p_price_list_rec.name;
           END;

        ELSIF l_blank = 0 THEN --Blank separator not found, name does not follow
                               --naming convention of a previously locked price
                               --list.
           p_price_list_rec.name := l_source_system_code || ' LOCKED ' ||
                               p_price_list_rec.name;
        END IF;

    ELSE   -- Source price list is not a locked pricelist
        p_price_list_rec.name := l_source_system_code || ' LOCKED ' ||
                           p_price_list_rec.name;
    END IF;

    p_price_list_rec.source_system_code := l_source_system_code;
    p_price_list_rec.locked_from_list_header_id := p_source_price_list_id;
    p_price_list_rec.pte_code := l_pte_code;
    p_price_list_rec.list_source_code := p_startup_mode;
    p_price_list_rec.orig_system_header_ref := p_orig_system_header_ref;
    p_price_list_rec.start_date_active := null; --OKS requirement
    p_price_list_rec.end_date_active := null; --OKS requirement
    --added for MOAC
    p_price_list_rec.org_id := nvl(p_org_id, QP_UTIL.get_org_id);
    p_price_list_rec.global_flag := 'N'; --per OKS comments on bug 4725283,
                                         --global_flag should be 'N'
    p_price_list_rec.operation := QP_GLOBALS.G_OPR_CREATE;


    --Copy the source list_line and its attributes to input record structures
    --and set the appropriate column values.
    FOR i IN x_price_list_line_tbl.FIRST..x_price_list_line_tbl.LAST
    LOOP

      IF x_price_list_line_tbl(i).list_line_id = p_source_list_line_id THEN

        --We use index=1 (ii=1 at this point) to store the list line and
        --then exit since there can only be one line with list_line_id =
        --p_source_list_line_id.
        p_price_list_line_tbl(ii) := x_price_list_line_tbl(i);
        p_price_list_line_tbl(ii).operation := QP_GLOBALS.G_OPR_CREATE;
        p_price_list_line_tbl(ii).list_line_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).list_line_no := FND_API.G_MISS_CHAR;
        p_price_list_line_tbl(ii).list_header_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).start_date_active := null; --OKS requirement
        p_price_list_line_tbl(ii).end_date_active := null; --OKS requirement


        --For the list line whose id matches p_source_list_line_id, copy the
        --pricing attributes.
        FOR j IN x_pricing_attr_tbl.FIRST..x_pricing_attr_tbl.LAST
        LOOP
          IF x_pricing_attr_tbl(j).price_list_line_index = i  AND
          ((x_pricing_attr_tbl(j).pricing_attribute_context IS NULL) OR
          NOT (x_pricing_attr_tbl(j).pricing_attribute_context = 'QP_INTERNAL'
               AND
               x_pricing_attr_tbl(j).pricing_attribute = 'PRICING_ATTRIBUTE1'))
          --Only copy pricing attributes other than the 'List Line Id' attribute
          THEN
            --We store the pricing attributes for the source list line
            --in a sequential manner, set the price_list_line_index to 1 since
            --there will only be one locked list line id and increment jj.
            p_pricing_attr_tbl(jj) := x_pricing_attr_tbl(j);
            p_pricing_attr_tbl(jj).price_list_line_index := ii; -- ii = 1 now
            p_pricing_attr_tbl(jj).operation := QP_GLOBALS.G_OPR_CREATE;
            p_pricing_attr_tbl(jj).pricing_attribute_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_line_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_header_id := FND_API.G_MISS_NUM;
            jj := jj + 1;
          END IF;
        END LOOP;--Loop to copy attributes of p_source_list_line_id

        ii := ii + 1;
        exit; --Exit loop after processing the list line and pricing attributes
              --corresponding to the p_source_list_line_id

      END IF; --If x_price_list_line_tbl(i).list_line_id=p_source_list_line_id

    END LOOP; --Loop to copy p_source_list_line_id and its attributes


    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'After loop to copy p_source_list_line_id and attrs');
    END IF;


    --If the p_source_list_line_id happens to be a PBH(price break header) type
    --of list line, then copy the price break child lines and their attributes.
    FOR i IN x_price_list_line_tbl.FIRST..x_price_list_line_tbl.LAST
    LOOP

      IF x_price_list_line_tbl(i).from_rltd_modifier_id = p_source_list_line_id
      THEN
        p_price_list_line_tbl(ii) := x_price_list_line_tbl(i);
        p_price_list_line_tbl(ii).operation := QP_GLOBALS.G_OPR_CREATE;
        p_price_list_line_tbl(ii).price_break_header_index := 1;
                          --since if p_source_list_line_id was a PBH then it
                          --would have an index of 1 in the input plsql table.
        p_price_list_line_tbl(ii).list_line_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).list_line_no := FND_API.G_MISS_CHAR;
        p_price_list_line_tbl(ii).list_header_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).from_rltd_modifier_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).start_date_active := null; --OKS requirement
        p_price_list_line_tbl(ii).end_date_active := null; --OKS requirement

        --For the price break child lines of p_source_list_line_id, copy the
        --pricing attributes.
        FOR j IN x_pricing_attr_tbl.FIRST..x_pricing_attr_tbl.LAST
        LOOP
          IF x_pricing_attr_tbl(j).price_list_line_index = i THEN
            --We store the pricing attributes for the child break lines of
            --source list line in a sequential manner, set the
            --price_list_line_index appropriately and increment jj.
            p_pricing_attr_tbl(jj) := x_pricing_attr_tbl(j);
            p_pricing_attr_tbl(jj).price_list_line_index := ii;
            p_pricing_attr_tbl(jj).operation := QP_GLOBALS.G_OPR_CREATE;
            p_pricing_attr_tbl(jj).pricing_attribute_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_line_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_header_id := FND_API.G_MISS_NUM;
            jj := jj + 1;
          END IF;
        END LOOP; --loop to copy pricing attributes of child break line

        ii := ii + 1;

      END IF; --If list_line is a child of the source list line id

    END LOOP; --Loop to copy any price break child lines and its attributes

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'After loop to copy price break child lines and attrs');
    END IF;

    --Set control flags
    p_control_rec.controlled_operation := TRUE;

    --  Instruct API to retain its caches
    p_control_rec.clear_api_cache      := FALSE;
    p_control_rec.clear_api_requests   := FALSE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'Before Process_Price_List 1');
    END IF;

    --Create locked price list
    QP_LIST_HEADERS_PVT.Process_Price_List
	(   p_api_version_number            => 1
	,   p_init_msg_list                 => FND_API.G_FALSE
	,   p_commit                        => FND_API.G_FALSE
        ,   p_control_rec		    => p_control_rec
	,   x_return_status                 => x_return_status
	,   x_msg_count                     => x_msg_count
	,   x_msg_data                      => x_msg_data
	,   p_PRICE_LIST_rec                => p_price_list_rec
	,   p_PRICE_LIST_LINE_tbl           => p_price_list_line_tbl
	,   p_PRICING_ATTR_tbl              => p_pricing_attr_tbl
	,   x_PRICE_LIST_rec                => x_price_list_rec
	,   x_PRICE_LIST_LINE_tbl           => x_price_list_line_tbl
	,   x_QUALIFIERS_tbl                => x_qualifiers_tbl
	,   x_PRICING_ATTR_tbl              => x_pricing_attr_tbl
	);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'After Process_Price_List 1');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_return_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_msg_data);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Set output variables.
    x_locked_price_list_id := x_price_list_rec.list_header_id;
    x_locked_list_line_id := x_price_list_line_tbl(1).list_line_id;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_locked_price_list_id = ' || x_locked_price_list_id ||
                      'and ' ||
                      'x_locked_list_line_id = ' || x_locked_list_line_id);
    END IF;

    --Call Process_Price_List API again to add list_line_id as a
    --pricing attribute to the list_line_id locked from p_source_list_line_id

    --Clear the price list line and pricing attributes plsql tables.
    p_pricing_attr_tbl.delete;

    --Populate one pricing attribute record for the LIST_LINE_ID attribute with
    --appropriate values.
    p_pricing_attr_tbl(1).pricing_attribute_id := FND_API.G_MISS_NUM;
    p_pricing_attr_tbl(1).list_line_id := x_price_list_line_tbl(1).list_line_id;
    p_pricing_attr_tbl(1).list_header_id :=
                                 x_price_list_line_tbl(1).list_header_id;
    p_pricing_attr_tbl(1).product_attribute :=
                                 x_pricing_attr_tbl(1).product_attribute;
    p_pricing_attr_tbl(1).product_attr_value :=
                                 x_pricing_attr_tbl(1).product_attr_value;
    p_pricing_attr_tbl(1).product_uom_code :=
                                 x_pricing_attr_tbl(1).product_uom_code;
    p_pricing_attr_tbl(1).pricing_attribute_context := 'QP_INTERNAL';
    p_pricing_attr_tbl(1).pricing_attribute := 'PRICING_ATTRIBUTE1';
     --Above context and attribute combination is for pricing attr LIST_LINE_ID.
    p_pricing_attr_tbl(1).pricing_attr_value_from :=
                             to_char(x_price_list_line_tbl(1).list_line_id);
    p_pricing_attr_tbl(1).comparison_operator_code := '=';
    p_pricing_attr_tbl(1).excluder_flag := 'N';
    p_pricing_attr_tbl(1).price_list_line_index := 1;
    p_pricing_attr_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'Before Process_Price_List 2');
    END IF;

    --Add List Line Id as a pricing attribute to locked price list line.
    QP_LIST_HEADERS_PVT.Process_Price_List
        (   p_api_version_number            => 1
        ,   p_init_msg_list                 => FND_API.G_FALSE
        ,   p_commit                        => FND_API.G_FALSE
        ,   p_control_rec                   => p_control_rec
        ,   x_return_status                 => x_return_status
        ,   x_msg_count                     => x_msg_count
        ,   x_msg_data                      => x_msg_data
        ,   p_PRICING_ATTR_tbl              => p_pricing_attr_tbl
        ,   x_PRICE_LIST_rec                => x_price_list_rec
        ,   x_PRICE_LIST_LINE_tbl           => x_price_list_line_tbl
        ,   x_QUALIFIERS_tbl                => x_qualifiers_tbl
        ,   x_PRICING_ATTR_tbl              => x_pricing_attr_tbl
        );

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'After Process_Price_List 2');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_return_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_msg_data);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE --l_locked_price_list_id is not null

    --Use existing locked_price_list to create locked line, etc.

    --While copying the output records of the Get_Price_List call (which
    --correspond to the source price list) to the input records for the
    --Process_Price_List procedure call, retain only the source price list
    --line and its children.


    --Copy the source list_line and its attributes to input record structures
    --and set the appropriate column values.
    FOR i IN x_price_list_line_tbl.FIRST..x_price_list_line_tbl.LAST
    LOOP

      IF x_price_list_line_tbl(i).list_line_id = p_source_list_line_id THEN

        --We use index=1 (ii=1 at this point) to store the list line and
        --then exit since there can only be one line with list_line_id =
        --p_source_list_line_id.
        p_price_list_line_tbl(ii) := x_price_list_line_tbl(i);
        p_price_list_line_tbl(ii).operation := QP_GLOBALS.G_OPR_CREATE;
        p_price_list_line_tbl(ii).list_line_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).list_line_no := FND_API.G_MISS_CHAR;
        p_price_list_line_tbl(ii).list_header_id := l_locked_price_list_id;
        p_price_list_line_tbl(ii).start_date_active := null; --OKS requirement
        p_price_list_line_tbl(ii).end_date_active := null; --OKS requirement

        --For the list line whose id matches p_source_list_line_id, copy the
        --pricing attributes.
        FOR j IN x_pricing_attr_tbl.FIRST..x_pricing_attr_tbl.LAST
        LOOP
          IF x_pricing_attr_tbl(j).price_list_line_index = i AND
          ((x_pricing_attr_tbl(j).pricing_attribute_context IS NULL) OR
           NOT (x_pricing_attr_tbl(j).pricing_attribute_context = 'QP_INTERNAL'
           AND
           x_pricing_attr_tbl(j).pricing_attribute = 'PRICING_ATTRIBUTE1'))
          --Only copy pricing attributes other than the 'List Line Id' attribute
          THEN
            --We store the pricing attributes for the source list line
            --in a sequential manner, set the price_list_line_index to 1 since
            --there will only be one locked list line id and increment jj.
            p_pricing_attr_tbl(jj) := x_pricing_attr_tbl(j);
            p_pricing_attr_tbl(jj).price_list_line_index := ii; -- ii = 1 now
            p_pricing_attr_tbl(jj).operation := QP_GLOBALS.G_OPR_CREATE;
            p_pricing_attr_tbl(jj).pricing_attribute_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_line_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_header_id := l_locked_price_list_id;
            jj := jj + 1;
          END IF;
        END LOOP;--Loop to copy attributes of p_source_list_line_id

        ii := ii + 1;
        exit; --Exit loop after processing the list line and pricing attributes
              --corresponding to the p_source_list_line_id

      END IF; --If x_price_list_line_tbl(i).list_line_id=p_source_list_line_id

    END LOOP; --Loop to copy p_source_list_line_id and its attributes



    --If the p_source_list_line_id happens to be a PBH(price break header) type
    --of list line, then copy the price break child lines and their attributes.
    FOR i IN x_price_list_line_tbl.FIRST..x_price_list_line_tbl.LAST
    LOOP

      IF x_price_list_line_tbl(i).from_rltd_modifier_id = p_source_list_line_id
      THEN
        p_price_list_line_tbl(ii) := x_price_list_line_tbl(i);
        p_price_list_line_tbl(ii).operation := QP_GLOBALS.G_OPR_CREATE;
        p_price_list_line_tbl(ii).price_break_header_index := 1;
                          --since if p_source_list_line_id was a PBH then it
                          --would have an index of 1 in the input plsql table.
        p_price_list_line_tbl(ii).list_line_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).list_line_no := FND_API.G_MISS_CHAR;
        p_price_list_line_tbl(ii).from_rltd_modifier_id := FND_API.G_MISS_NUM;
        p_price_list_line_tbl(ii).list_header_id := l_locked_price_list_id;
        p_price_list_line_tbl(ii).start_date_active := null; --OKS requirement
        p_price_list_line_tbl(ii).end_date_active := null; --OKS requirement

        --For the price break child lines of p_source_list_line_id, copy the
        --pricing attributes.
        FOR j IN x_pricing_attr_tbl.FIRST..x_pricing_attr_tbl.LAST
        LOOP
          IF x_pricing_attr_tbl(j).price_list_line_index = i THEN
            --We store the pricing attributes for the child break lines of
            --source list line in a sequential manner, set the
            --price_list_line_index appropriately and increment jj.
            p_pricing_attr_tbl(jj) := x_pricing_attr_tbl(j);
            p_pricing_attr_tbl(jj).price_list_line_index := ii;
            p_pricing_attr_tbl(jj).operation := QP_GLOBALS.G_OPR_CREATE;
            p_pricing_attr_tbl(jj).pricing_attribute_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_line_id := FND_API.G_MISS_NUM;
            p_pricing_attr_tbl(jj).list_header_id := l_locked_price_list_id;
            jj := jj + 1;
          END IF;
        END LOOP; --loop to copy pricing attributes of child break line

        ii := ii + 1;

      END IF; --If list_line is a child of the source list line id

    END LOOP; --Loop to copy any price break child lines and its attributes

    --Set control flags
    p_control_rec.controlled_operation := TRUE;

    --  Instruct API to retain its caches
    p_control_rec.clear_api_cache      := FALSE;
    p_control_rec.clear_api_requests   := FALSE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'Before Process_Price_List 3');
    END IF;

    --Create locked price list
    QP_LIST_HEADERS_PVT.Process_Price_List
	(   p_api_version_number            => 1
	,   p_init_msg_list                 => FND_API.G_FALSE
	,   p_commit                        => FND_API.G_FALSE
        ,   p_control_rec		    => p_control_rec
	,   x_return_status                 => x_return_status
	,   x_msg_count                     => x_msg_count
	,   x_msg_data                      => x_msg_data
	,   p_PRICE_LIST_rec                => p_price_list_rec
	,   p_PRICE_LIST_LINE_tbl           => p_price_list_line_tbl
	,   p_PRICING_ATTR_tbl              => p_pricing_attr_tbl
	,   x_PRICE_LIST_rec                => x_price_list_rec
	,   x_PRICE_LIST_LINE_tbl           => x_price_list_line_tbl
	,   x_QUALIFIERS_tbl                => x_qualifiers_tbl
	,   x_PRICING_ATTR_tbl              => x_pricing_attr_tbl
	);

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'After Process_Price_List 3');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_return_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_msg_data);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Set output variables.
    x_locked_price_list_id := l_locked_price_list_id;
    x_locked_list_line_id := x_price_list_line_tbl(1).list_line_id;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_locked_price_list_id = ' || x_locked_price_list_id ||
                      'and ' ||
                      'x_locked_list_line_id = ' || x_locked_list_line_id);
    END IF;


    --Call Process_Price_List API again to add list_line_id as a
    --pricing attribute to the list_line_id locked from p_source_list_line_id

    --Clear the price list line and pricing attributes plsql tables.
    p_pricing_attr_tbl.delete;

    --Populate one pricing attribute record for the LIST_LINE_ID attribute with
    --appropriate values.
    p_pricing_attr_tbl(1).pricing_attribute_id := FND_API.G_MISS_NUM;
    p_pricing_attr_tbl(1).list_line_id := x_price_list_line_tbl(1).list_line_id;
    p_pricing_attr_tbl(1).list_header_id :=
                                 x_price_list_line_tbl(1).list_header_id;
    p_pricing_attr_tbl(1).product_attribute :=
                                 x_pricing_attr_tbl(1).product_attribute;
    p_pricing_attr_tbl(1).product_attr_value :=
                                 x_pricing_attr_tbl(1).product_attr_value;
    p_pricing_attr_tbl(1).product_uom_code :=
                                 x_pricing_attr_tbl(1).product_uom_code;
    p_pricing_attr_tbl(1).pricing_attribute_context := 'QP_INTERNAL';
    p_pricing_attr_tbl(1).pricing_attribute := 'PRICING_ATTRIBUTE1';
     --Above context and attribute combination is for pricing attr LIST_LINE_ID.
    p_pricing_attr_tbl(1).pricing_attr_value_from :=
                             to_char(x_price_list_line_tbl(1).list_line_id);
    p_pricing_attr_tbl(1).comparison_operator_code := '=';
    p_pricing_attr_tbl(1).excluder_flag := 'N';
    p_pricing_attr_tbl(1).price_list_line_index := 1;
    p_pricing_attr_tbl(1).operation := QP_GLOBALS.G_OPR_CREATE;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'Before Process_Price_List 4');
    END IF;

    --Add List Line Id as a pricing attribute to locked price list line.
    QP_LIST_HEADERS_PVT.Process_Price_List
        (   p_api_version_number            => 1
        ,   p_init_msg_list                 => FND_API.G_FALSE
        ,   p_commit                        => FND_API.G_FALSE
        ,   p_control_rec                   => p_control_rec
        ,   x_return_status                 => x_return_status
        ,   x_msg_count                     => x_msg_count
        ,   x_msg_data                      => x_msg_data
        ,   p_PRICING_ATTR_tbl              => p_pricing_attr_tbl
        ,   x_PRICE_LIST_rec                => x_price_list_rec
        ,   x_PRICE_LIST_LINE_tbl           => x_price_list_line_tbl
        ,   x_QUALIFIERS_tbl                => x_qualifiers_tbl
        ,   x_PRICING_ATTR_tbl              => x_pricing_attr_tbl
        );

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'After Process_Price_List 4');
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_return_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
        fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'x_return_status = ' || x_msg_data);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF; --l_locked_price_list_id is null

  IF p_commit = 'T' THEN  --for true (OKS Bug 4504825)
    commit; -- OKS requires newly created locked PL Line (and PL if applicable)
            -- to be committed conditionally. When called from Group API, OKS
            -- may pass 'T' or 'F', but when called from Price List Form which
            -- is integrated with the OKS Contract Authoring form, p_commit='T'.
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure,
                      g_pkg_name || '.Lock_Price',
                      'Others Exception : ' || substr(sqlerrm, 1, 240));
        END IF;

        FND_MSG_PUB.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Lock_Price'
        ,   substr(sqlerrm, 1, 240)
        );

        --  Get message count and data

        FND_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Price;


END QP_LOCK_PRICELIST_PVT;

/
