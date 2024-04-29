--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_PLL_PRICING_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_PLL_PRICING_ATTR" AS
/* $Header: QPXDPLAB.pls 120.2 2005/07/07 04:03:57 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'Qp_Default_pll_pricing_attr';

--  Package global used within the package.

g_PRICING_ATTR_rec            QP_Price_List_PUB.Pricing_Attr_Rec_Type;

--  Get functions.

FUNCTION Get_Accumulate
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Accumulate;

FUNCTION Get_Attribute_Grouping_No
RETURN NUMBER
IS
l_attribute_grouping_no number;
BEGIN

   select attribute_grouping_no
   into l_attribute_grouping_no
   from qp_pricing_attributes
   where list_line_id = g_Pricing_Attr_rec.list_line_id
   and rownum < 2;

   return l_attribute_grouping_no;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

     select qp_pricing_attr_group_no_s.nextval
     into l_attribute_grouping_no
     from dual;

     return l_attribute_grouping_no;

  WHEN OTHERS THEN RETURN NULL;


END Get_Attribute_Grouping_No;

FUNCTION Get_Excluder
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Excluder;

FUNCTION Get_List_Line
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Line;

FUNCTION Get_Qualification_Ind
RETURN NUMBER
IS
BEGIN
    RETURN NULL;
END Get_Qualification_Ind;

FUNCTION Get_List_Header(a_list_line_id   IN   NUMBER)
RETURN NUMBER
IS
l_list_header_id  NUMBER;

BEGIN

    SELECT list_header_id
    INTO   l_list_header_id
    FROM   qp_list_lines
    WHERE  list_line_id = a_list_line_id;

    RETURN l_list_header_id;

EXCEPTION
    WHEN OTHERS THEN
         RETURN NULL;
END Get_List_Header;

FUNCTION Get_Pricing_Phase
RETURN NUMBER
IS
BEGIN

    RETURN 1;

END Get_Pricing_Phase;

FUNCTION Get_Pricing_Attribute_Id
RETURN VARCHAR2
IS
l_pricing_attribute_id number;
BEGIN

   select qp_pricing_attributes_s.nextval
   into l_pricing_attribute_id
   from dual;

   RETURN l_pricing_attribute_id;

EXCEPTION

  WHEN OTHERS THEN RETURN NULL;

END Get_Pricing_Attribute_Id;

FUNCTION Get_Pricing_Attribute_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute_Context;

FUNCTION Get_Pricing_Attribute
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attribute;

FUNCTION Get_Pricing_Attribute_Datatype( pric_attribute_context  IN VARCHAR2,
                                         pric_attribute  IN VARCHAR2,
                                         pric_attr_value   IN VARCHAR2)
RETURN VARCHAR2
IS

l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_error_code                  NUMBER := 0;

BEGIN

    QP_UTIL.validate_qp_flexfield(flexfield_name         =>'QP_ATTR_DEFNS_PRICING'
			 ,context                        =>pric_attribute_context
			 ,attribute                      =>pric_attribute
			 ,value                          =>pric_attr_value
                ,application_short_name         => 'QP'
			 ,context_flag                   =>l_context_flag
			 ,attribute_flag                 =>l_attribute_flag
			 ,value_flag                     =>l_value_flag
			 ,datatype                       =>l_datatype
			 ,precedence                      =>l_precedence
			 ,error_code                     =>l_error_code
			 );

oe_debug_pub.add('error code = '|| to_char(l_error_code));
       IF l_error_code = 0
	  THEN

         RETURN l_datatype;

       ELSE

         RETURN NULL;

      END IF;

END Get_Pricing_Attribute_Datatype;

FUNCTION Get_Product_Attribute_Datatype( prod_attribute_context  IN VARCHAR2,
                                         prod_attribute  IN VARCHAR2,
                                         prod_attr_value   IN VARCHAR2)
RETURN VARCHAR2
IS

l_context_flag                VARCHAR2(1);
l_attribute_flag              VARCHAR2(1);
l_value_flag                  VARCHAR2(1);
l_datatype                    VARCHAR2(1);
l_precedence                  NUMBER;
l_error_code                  NUMBER := 0;

BEGIN

    QP_UTIL.validate_qp_flexfield(flexfield_name         =>'QP_ATTR_DEFNS_PRICING'
			 ,context                        =>prod_attribute_context
			 ,attribute                      =>prod_attribute
			 ,value                          =>prod_attr_value
                ,application_short_name         => 'QP'
			 ,context_flag                   =>l_context_flag
			 ,attribute_flag                 =>l_attribute_flag
			 ,value_flag                     =>l_value_flag
			 ,datatype                       =>l_datatype
			 ,precedence                      =>l_precedence
			 ,error_code                     =>l_error_code
			 );

oe_debug_pub.add('error code = '|| to_char(l_error_code));

       IF l_error_code = 0
	  THEN

         RETURN l_datatype;

       ELSE

         RETURN NULL;

      END IF;

END Get_Product_Attribute_Datatype;

FUNCTION Get_Pricing_Attr_Value_From
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attr_Value_From;

FUNCTION Get_Pricing_Attr_Value_To
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Pricing_Attr_Value_To;

FUNCTION Get_Comparison_Operator_Code
RETURN VARCHAR2
IS
BEGIN

  RETURN 'BETWEEN';

END Get_Comparison_Operator_Code;

FUNCTION Get_From_Rltd_Modifier_Id
RETURN NUMBER
IS
BEGIN

   RETURN NULL;

END;

FUNCTION Get_Product_Attribute
RETURN VARCHAR2
IS
l_prod_attr VARCHAR2(30) := NULL;
BEGIN

   IF ( g_Pricing_Attr_rec.from_rltd_modifier_id is not null
	  and g_Pricing_Attr_rec.from_rltd_modifier_id <> FND_API.G_MISS_NUM) THEN

    select product_attribute
    into l_prod_attr
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.from_rltd_modifier_id
    and excluder_flag = 'N'
    and rownum < 2;

    oe_debug_pub.add('prod attr  3 : ' || l_prod_attr );

   ELSIF ( g_Pricing_Attr_rec.list_line_id is not null
	  and g_Pricing_Attr_rec.list_line_id <> FND_API.G_MISS_NUM) THEN

    select product_attribute
    into l_prod_attr
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.list_line_id
    and excluder_flag = 'N'
    and rownum < 2;

   END IF;

    return l_prod_attr;

EXCEPTION

    WHEN OTHERS THEN RETURN NULL;

END Get_Product_Attribute;

FUNCTION Get_Product_Attribute_Context
RETURN VARCHAR2
IS
l_prod_attr_cont VARCHAR2(30) := NULL;
BEGIN

   oe_debug_pub.add('parent line id 1 :' || g_PRICING_ATTR_REC.FROM_RLTD_MODIFIER_ID );

   IF ( g_Pricing_Attr_rec.from_rltd_modifier_id is not null
	  and g_Pricing_Attr_rec.from_rltd_modifier_id <> FND_API.G_MISS_NUM) THEN

    select product_attribute_context
    into l_prod_attr_cont
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.from_rltd_modifier_id
    and excluder_flag = 'N'
    and rownum < 2;

    oe_debug_pub.add('prod attr cont 1 : ' || l_prod_attr_cont );

   ELSIF ( g_Pricing_Attr_rec.list_line_id is not null
	  and g_Pricing_Attr_rec.list_line_id <> FND_API.G_MISS_NUM) THEN

    select product_attribute_context
    into l_prod_attr_cont
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.list_line_id
    and excluder_flag = 'N'
    and rownum < 2;

   END IF;

    return l_prod_attr_cont;

EXCEPTION

    WHEN OTHERS THEN RETURN NULL;

END Get_Product_Attribute_Context;

FUNCTION Get_Product_Attr_Value
RETURN VARCHAR2
IS
l_prod_attr_value VARCHAR2(240) := NULL;
BEGIN

   IF ( g_Pricing_Attr_rec.from_rltd_modifier_id is not null
	  and g_Pricing_Attr_rec.from_rltd_modifier_id <> FND_API.G_MISS_NUM) THEN

    select product_attr_value
    into l_prod_attr_value
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.from_rltd_modifier_id
    and excluder_flag = 'N'
    and rownum < 2;

    oe_debug_pub.add('prod attr value 2 : ' || l_prod_attr_value );

   ELSIF ( g_Pricing_Attr_rec.list_line_id is not null
	  and g_Pricing_Attr_rec.list_line_id <> FND_API.G_MISS_NUM) THEN

    select product_attr_value
    into l_prod_attr_value
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.list_line_id
    and excluder_flag = 'N'
    and rownum < 2;

   END IF;

   return l_prod_attr_value;

EXCEPTION

    WHEN OTHERS THEN RETURN NULL;

END Get_Product_Attr_Value;

FUNCTION Get_Product_Uom
RETURN VARCHAR2
IS
l_prod_uom VARCHAR2(3) := NULL;
BEGIN

   IF ( g_Pricing_Attr_rec.from_rltd_modifier_id is not null
	  and g_Pricing_Attr_rec.from_rltd_modifier_id <> FND_API.G_MISS_NUM) THEN

    select product_uom_code
    into l_prod_uom
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.from_rltd_modifier_id
    and excluder_flag = 'N'
    and rownum < 2;

    oe_debug_pub.add('uom 4: ' || l_prod_uom );

   ELSIF ( g_Pricing_Attr_rec.list_line_id is not null
	  and g_Pricing_Attr_rec.list_line_id <> FND_API.G_MISS_NUM) THEN

    select product_uom_code
    into l_prod_uom
    from qp_pricing_attributes
    where list_line_id = g_Pricing_Attr_rec.list_line_id
    and excluder_flag = 'N'
    and rownum < 2;

   END IF;

   return l_prod_uom;

EXCEPTION

    WHEN OTHERS THEN RETURN NULL;

END Get_Product_Uom;

PROCEDURE Get_Flex_Pricing_Attr
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PRICING_ATTR_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute1  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute10 := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute11 := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute12 := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute13 := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute14 := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute15 := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute2  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute3  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute4  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute5  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute6  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute7  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute8  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.attribute9  := NULL;
    END IF;

    IF g_PRICING_ATTR_rec.context = FND_API.G_MISS_CHAR THEN
        g_PRICING_ATTR_rec.context     := NULL;
    END IF;

END Get_Flex_Pricing_Attr;

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICING_ATTR_rec              IN  QP_Price_List_PUB.Pricing_Attr_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICING_ATTR_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICING_ATTR_rec              OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Pricing_Attr_Rec_Type
)
IS
 g_p_PRICING_ATTR_rec         QP_Price_List_PUB.Pricing_Attr_Rec_Type;
BEGIN

    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            oe_msg_pub.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_PRICING_ATTR_rec

    g_PRICING_ATTR_rec := p_PRICING_ATTR_rec;

    --  Default missing attributes.

    IF g_PRICING_ATTR_rec.accumulate_flag = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.accumulate_flag := Get_Accumulate;

        IF g_PRICING_ATTR_rec.accumulate_flag IS NOT NULL THEN

            IF QP_Validate.Accumulate(g_PRICING_ATTR_rec.accumulate_flag)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_ACCUMULATE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.accumulate_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.attribute_grouping_no = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.attribute_grouping_no := Get_Attribute_Grouping_No;

        IF g_PRICING_ATTR_rec.attribute_grouping_no IS NOT NULL THEN

            IF QP_Validate.Attribute_Grouping_No(g_PRICING_ATTR_rec.attribute_grouping_no)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_ATTRIBUTE_GROUPING_NO
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.attribute_grouping_no := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.excluder_flag = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.excluder_flag := Get_Excluder;

        IF g_PRICING_ATTR_rec.excluder_flag IS NOT NULL THEN

            IF QP_Validate.Excluder(g_PRICING_ATTR_rec.excluder_flag)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_EXCLUDER
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.excluder_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.list_line_id := Get_List_Line;

        IF g_PRICING_ATTR_rec.list_line_id IS NOT NULL THEN

            IF QP_Validate.List_Line(g_PRICING_ATTR_rec.list_line_id)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_LIST_LINE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.qualification_ind = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.qualification_ind := Get_Qualification_Ind;

    END IF;

    IF g_PRICING_ATTR_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.list_header_id :=
				Get_List_Header(p_PRICING_ATTR_rec.list_line_id);

        IF g_PRICING_ATTR_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_PRICING_ATTR_rec.list_header_id)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_LIST_HEADER
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_phase_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.pricing_phase_id := Get_Pricing_Phase;

        IF g_PRICING_ATTR_rec.pricing_phase_id IS NOT NULL THEN

            IF QP_Validate.Pricing_Phase(g_PRICING_ATTR_rec.pricing_phase_id)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_LIST_HEADER
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_phase_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_attribute_context = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.pricing_attribute_context := Get_Pricing_Attribute_Context;

        IF g_PRICING_ATTR_rec.pricing_attribute_context IS NOT NULL THEN

            IF QP_Validate.Pricing_Attribute_Context(g_PRICING_ATTR_rec.pricing_attribute_context)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE_CONTEXT
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_attribute_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_attribute = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.pricing_attribute := Get_Pricing_Attribute;

        IF g_PRICING_ATTR_rec.pricing_attribute IS NOT NULL THEN

            IF QP_Validate.Pricing_Attribute(g_PRICING_ATTR_rec.pricing_attribute)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_attr_value_from = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.pricing_attr_value_from := Get_Pricing_Attr_Value_From;

        IF g_PRICING_ATTR_rec.pricing_attr_value_from IS NOT NULL THEN

            IF QP_Validate.Pricing_Attr_Value_From(g_PRICING_ATTR_rec.pricing_attr_value_from)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRICING_ATTR_VALUE_FROM
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_attr_value_from := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_attr_value_to = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.pricing_attr_value_to := Get_Pricing_Attr_Value_To;

        IF g_PRICING_ATTR_rec.pricing_attr_value_to IS NOT NULL THEN

            IF QP_Validate.Pricing_Attr_Value_To(g_PRICING_ATTR_rec.pricing_attr_value_to)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRICING_ATTR_VALUE_TO
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_attr_value_to := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_attribute_datatype = FND_API.G_MISS_CHAR THEN

      g_PRICING_ATTR_rec.pricing_attribute_datatype :=
 Get_Pricing_Attribute_Datatype(p_PRICING_ATTR_rec.pricing_attribute_context,
	                                  p_PRICING_ATTR_rec.pricing_attribute,
	                                  p_PRICING_ATTR_rec.pricing_attr_value_from);


        IF g_PRICING_ATTR_rec.pricing_attribute_datatype IS NOT NULL THEN

            IF QP_Validate.Pricing_Attribute_Datatype(g_PRICING_ATTR_rec.pricing_attribute_datatype)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE_DATATYPE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_attribute_datatype := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.pricing_attribute_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.pricing_attribute_id := Get_Pricing_Attribute_Id;

        IF g_PRICING_ATTR_rec.pricing_attribute_id IS NOT NULL THEN

            IF QP_Validate.Pricing_Attribute(g_PRICING_ATTR_rec.pricing_attribute_id)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRICING_ATTRIBUTE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.pricing_attribute_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN

	 g_PRICING_ATTR_rec.comparison_operator_code := Get_Comparison_Operator_Code;

        IF g_PRICING_ATTR_rec.comparison_operator_code IS NOT NULL THEN

            IF QP_Validate.comparison_operator(g_PRICING_ATTR_rec.comparison_operator_code)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_COMPARISON_OPERATOR_CODE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.comparison_operator_code := NULL;
            END IF;

        END IF;

    END IF;


    IF g_PRICING_ATTR_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.from_rltd_modifier_id := Get_From_Rltd_Modifier_Id;

	   oe_debug_pub.add('get rltd modifier');

       /*

        IF g_PRICING_ATTR_rec.from_rltd_modifier_id IS NOT NULL THEN

            IF QP_Validate.From_Rltd_Modifier_Id(g_PRICING_ATTR_rec.from_rltd_modifier_id)
            THEN
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_FROM_RLTD_MODIFIER
                ,   p_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.from_rltd_modifier_id := NULL;
            END IF;

        END IF;

         */

    END IF;

    IF g_PRICING_ATTR_rec.product_attribute_context = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.product_attribute_context := Get_Product_Attribute_Context;

        IF g_PRICING_ATTR_rec.product_attribute_context IS NOT NULL THEN

            IF QP_Validate.Product_Attribute_Context(g_PRICING_ATTR_rec.product_attribute_context)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRODUCT_ATTRIBUTE_CONTEXT
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.product_attribute_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.product_attribute = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.product_attribute := Get_Product_Attribute;

        IF g_PRICING_ATTR_rec.product_attribute IS NOT NULL THEN

            IF QP_Validate.Product_Attribute(g_PRICING_ATTR_rec.product_attribute)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRODUCT_ATTRIBUTE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.product_attribute := NULL;
            END IF;

        END IF;

    END IF;


    IF g_PRICING_ATTR_rec.product_attr_value = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.product_attr_value := Get_Product_Attr_Value;

        IF g_PRICING_ATTR_rec.product_attr_value IS NOT NULL THEN

            IF QP_Validate.Product_Attr_Value(g_PRICING_ATTR_rec.product_attr_value)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRODUCT_ATTR_VALUE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.product_attr_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.product_attribute_datatype = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.product_attribute_datatype :=
	   Get_Product_Attribute_Datatype(g_PRICING_ATTR_rec.product_attribute_context,
	                                  g_PRICING_ATTR_rec.product_attribute,
	                                  g_PRICING_ATTR_rec.product_attr_value);


        IF g_PRICING_ATTR_rec.product_attribute_datatype IS NOT NULL THEN

            IF QP_Validate.Product_Attribute_Datatype(g_PRICING_ATTR_rec.product_attribute_datatype)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRODUCT_ATTRIBUTE_DATATYPE
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.product_attribute_datatype := NULL;
            END IF;

        END IF;

    END IF;

    oe_debug_pub.add('product attr datatype is : ' || g_PRICING_ATTR_rec.product_attribute_datatype);

    IF g_PRICING_ATTR_rec.product_uom_code = FND_API.G_MISS_CHAR THEN

        g_PRICING_ATTR_rec.product_uom_code := Get_Product_Uom;

        IF g_PRICING_ATTR_rec.product_uom_code IS NOT NULL THEN

            IF QP_Validate.Product_Uom(g_PRICING_ATTR_rec.product_uom_code)
            THEN
                g_p_PRICING_ATTR_rec := g_PRICING_ATTR_rec;
                Qp_pll_pricing_attr_Util.Clear_Dependent_Attr
                (   p_attr_id                     => Qp_pll_pricing_attr_Util.G_PRODUCT_UOM
                ,   p_PRICING_ATTR_rec            => g_p_PRICING_ATTR_rec
                ,   x_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
                );
            ELSE
                g_PRICING_ATTR_rec.product_uom_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICING_ATTR_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Pricing_Attr;

    END IF;

    IF g_PRICING_ATTR_rec.created_by = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.created_by := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_PRICING_ATTR_rec.creation_date := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.last_updated_by := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_PRICING_ATTR_rec.last_update_date := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.last_update_login := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.program_application_id := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.program_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.program_id := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_PRICING_ATTR_rec.program_update_date := NULL;

    END IF;

    IF g_PRICING_ATTR_rec.request_id = FND_API.G_MISS_NUM THEN

        g_PRICING_ATTR_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PRICING_ATTR_rec.accumulate_flag = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.attribute_grouping_no = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.context = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.created_by = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_PRICING_ATTR_rec.excluder_flag = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_PRICING_ATTR_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.list_line_id = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.pricing_attribute = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.pricing_attribute_context = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.pricing_attribute_id = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.pricing_attr_value_from = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.pricing_attr_value_to = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.from_rltd_modifier_id = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.product_attribute = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.product_attribute_context = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.product_attr_value = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.product_uom_code = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.program_id = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_PRICING_ATTR_rec.request_id = FND_API.G_MISS_NUM
    OR  g_PRICING_ATTR_rec.comparison_operator_code = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.pricing_attribute_datatype = FND_API.G_MISS_CHAR
    OR  g_PRICING_ATTR_rec.product_attribute_datatype = FND_API.G_MISS_CHAR
    THEN

        Qp_Default_pll_pricing_attr.Attributes
        (   p_PRICING_ATTR_rec            => g_PRICING_ATTR_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PRICING_ATTR_rec            => x_PRICING_ATTR_rec
        );

    ELSE

        --  Done defaulting attributes

        x_PRICING_ATTR_rec := g_PRICING_ATTR_rec;

    END IF;

END Attributes;

END QP_Default_pll_pricing_attr;

/
