--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_QUALIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_QUALIFIERS" AS
/* $Header: QPXDQPQB.pls 120.3 2005/08/31 17:51:43 srashmi ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Qualifiers';

--  Package global used within the package.

g_QUALIFIERS_rec              QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;
g_p_QUALIFIERS_rec            QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type;

--  Get functions.

FUNCTION Get_Comparison_Operator
RETURN VARCHAR2
IS
BEGIN

    RETURN '=';

END Get_Comparison_Operator;

FUNCTION Get_Created_From_Rule
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Created_From_Rule;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Excluder
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Excluder;

FUNCTION Get_List_Header
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_List_Header;

FUNCTION Get_List_Line
RETURN NUMBER
IS
BEGIN

    RETURN -1;

END Get_List_Line;

FUNCTION Get_Qualifier_Attribute
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Attribute;

FUNCTION Get_Qualifier_Attr_Value
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Attr_Value;

FUNCTION Get_Qualifier_Attr_Value_To
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Attr_Value_To;


FUNCTION Get_Qualifier_Context
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Context;

FUNCTION Get_Qualifier_Datatype(p_qualifier_context IN VARCHAR2,
						    p_qualifier_attribute IN VARCHAR2,
                                  p_qualifier_attribute_value IN VARCHAR2
						    )
RETURN VARCHAR2
IS
l_context_error VARCHAR2(1);
l_attribute_error VARCHAR2(1);
l_value_error VARCHAR2(1);
l_datatype VARCHAR2(1);
l_precedence NUMBER;
l_error_code NUMBER;

BEGIN


    QP_UTIL.validate_qp_flexfield(flexfield_name         =>'QP_ATTR_DEFNS_QUALIFIER'
			 ,context                        =>p_qualifier_context
			 ,attribute                      =>p_qualifier_attribute
			 ,value                          =>p_qualifier_attribute_value
                ,application_short_name         => 'QP'
			 ,context_flag                   =>l_context_error
			 ,attribute_flag                 =>l_attribute_error
			 ,value_flag                     =>l_value_error
			 ,datatype                       =>l_datatype
			 ,precedence                      =>l_precedence
			 ,error_code                     =>l_error_code
			 );

    If l_error_code = 0 Then

	  RETURN  l_datatype;
    Else
	  RETURN  NULL;
    End If;

END Get_Qualifier_Datatype;

/*FUNCTION Get_Qualifier_Date_Format
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Date_Format;*/

FUNCTION Get_Qualifier_Grouping_No
RETURN NUMBER
IS
BEGIN

    RETURN -1;

END Get_Qualifier_Grouping_No;

FUNCTION Get_Qualifier
RETURN NUMBER
IS
l_qualifier_id  NUMBER;
BEGIN

   SELECT QP_QUALIFIERS_S.NEXTVAL
   INTO   l_qualifier_id
   FROM  DUAL;
   RETURN l_qualifier_id;

END Get_Qualifier;

/*FUNCTION Get_Qualifier_Number_Format
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Number_Format;*/

FUNCTION Get_Qualifier_Precedence(p_qualifier_context IN VARCHAR2,
						    p_qualifier_attribute IN VARCHAR2,
                                  p_qualifier_attribute_value IN VARCHAR2
                                 )
RETURN NUMBER
IS

l_context_error VARCHAR2(1);
l_attribute_error VARCHAR2(1);
l_value_error VARCHAR2(1);
l_datatype VARCHAR2(1);
l_precedence NUMBER;
l_error_code NUMBER;

BEGIN


    QP_UTIL.validate_qp_flexfield(flexfield_name         =>'QP_ATTR_DEFNS_QUALIFIER'
			 ,context                        =>p_qualifier_context
			 ,attribute                      =>p_qualifier_attribute
			 ,value                          =>p_qualifier_attribute_value
                ,application_short_name         => 'QP'
			 ,context_flag                   =>l_context_error
			 ,attribute_flag                 =>l_attribute_error
			 ,value_flag                     =>l_value_error
			 ,datatype                       =>l_datatype
			 ,precedence                      =>l_precedence
			 ,error_code                     =>l_error_code
			 );

    If l_error_code = 0 Then

	  RETURN  l_precedence;

    Else
       RETURN NULL;

    End If;

END Get_Qualifier_Precedence;

FUNCTION Get_Qualifier_Rule
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Qualifier_Rule;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_Start_Date_Active;

--Added for TCA
FUNCTION Get_Qualify_Hier_Descendents
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Qualify_Hier_Descendents;

PROCEDURE Get_Flex_Qualifiers
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute1    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute10   := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute11   := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute12   := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute13   := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute14   := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute15   := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute2    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute3    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute4    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute5    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute6    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute7    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute8    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.attribute9    := NULL;
    END IF;

    IF g_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR THEN
        g_QUALIFIERS_rec.context       := NULL;
    END IF;

END Get_Flex_Qualifiers;

--  Procedure Attributes

PROCEDURE Attributes
(   p_QUALIFIERS_rec                IN  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type :=
                                        QP_Qualifier_Rules_PUB.G_MISS_QUALIFIERS_REC
,   p_iteration                     IN  NUMBER := 1
,   x_QUALIFIERS_rec                OUT NOCOPY /* file.sql.39 change */ QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type
)
IS
BEGIN


      --dbms_output.put_line('entering default attributes');


    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            OE_MSG_PUB.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_QUALIFIERS_rec

    g_QUALIFIERS_rec := p_QUALIFIERS_rec;

    --  Default missing attributes.

    IF g_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.comparison_operator_code := Get_Comparison_Operator;

        IF g_QUALIFIERS_rec.comparison_operator_code IS NOT NULL THEN

            IF QP_Validate.Comparison_Operator(g_QUALIFIERS_rec.comparison_operator_code)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_COMPARISON_OPERATOR
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.comparison_operator_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.created_from_rule_id := Get_Created_From_Rule;

        IF g_QUALIFIERS_rec.created_from_rule_id IS NOT NULL THEN

            IF QP_Validate.Created_From_Rule(g_QUALIFIERS_rec.created_from_rule_id)
            THEN
                 g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_CREATED_FROM_RULE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.created_from_rule_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_QUALIFIERS_rec.end_date_active := Get_End_Date_Active;

        IF g_QUALIFIERS_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_QUALIFIERS_rec.end_date_active)
            THEN
                 g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_END_DATE_ACTIVE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.excluder_flag := Get_Excluder;

        IF g_QUALIFIERS_rec.excluder_flag IS NOT NULL THEN

            IF QP_Validate.Excluder(g_QUALIFIERS_rec.excluder_flag)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_EXCLUDER
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.excluder_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.list_header_id := Get_List_Header;

        IF g_QUALIFIERS_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_QUALIFIERS_rec.list_header_id)
            THEN
                 g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_LIST_HEADER
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.list_line_id := Get_List_Line;

        IF g_QUALIFIERS_rec.list_line_id IS NOT NULL THEN

            IF QP_Validate.List_Line(g_QUALIFIERS_rec.list_line_id)
            THEN
                 g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_LIST_LINE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.list_line_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualifier_attribute := Get_Qualifier_Attribute;

        IF g_QUALIFIERS_rec.qualifier_attribute IS NOT NULL THEN

            IF QP_Validate.Qualifier_Attribute(g_QUALIFIERS_rec.qualifier_attribute)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_ATTRIBUTE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_attribute := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualifier_attr_value := Get_Qualifier_Attr_Value;

        IF g_QUALIFIERS_rec.qualifier_attr_value IS NOT NULL THEN

            IF QP_Validate.Qualifier_Attr_Value(g_QUALIFIERS_rec.qualifier_attr_value)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_ATTR_VALUE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_attr_value := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.qualifier_attr_value_to = FND_API.G_MISS_CHAR THEN

       g_QUALIFIERS_rec.qualifier_attr_value_to := Get_Qualifier_Attr_Value_to;

        IF g_QUALIFIERS_rec.qualifier_attr_value_to IS NOT NULL THEN

            IF QP_Validate.Qualifier_Attr_Value_to(g_QUALIFIERS_rec.qualifier_attr_value_to)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_ATTR_VALUE_TO
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_attr_value_to := NULL;
            END IF;
		  --null;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.qualifier_context = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualifier_context := Get_Qualifier_Context;

        IF g_QUALIFIERS_rec.qualifier_context IS NOT NULL THEN

            IF QP_Validate.Qualifier_Context(g_QUALIFIERS_rec.qualifier_context)
            THEN
                  g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_CONTEXT
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_context := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.qualifier_datatype = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualifier_datatype := Get_Qualifier_Datatype(
											p_QUALIFIERS_rec.qualifier_context
                                                     , p_QUALIFIERS_rec.qualifier_attribute
										   ,p_QUALIFIERS_rec.qualifier_attr_value
										   );

        IF g_QUALIFIERS_rec.qualifier_datatype IS NOT NULL THEN

            IF QP_Validate.Qualifier_Datatype(g_QUALIFIERS_rec.qualifier_datatype)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_DATATYPE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_datatype := NULL;
            END IF;

        END IF;

    END IF;

    /*IF g_QUALIFIERS_rec.qualifier_date_format = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualifier_date_format := Get_Qualifier_Date_Format;

        IF g_QUALIFIERS_rec.qualifier_date_format IS NOT NULL THEN

            IF QP_Validate.Qualifier_Date_Format(g_QUALIFIERS_rec.qualifier_date_format)
            THEN
                   g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_DATE_FORMAT
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_date_format := NULL;
            END IF;

        END IF;

    END IF;*/

    IF g_QUALIFIERS_rec.qualifier_grouping_no = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.qualifier_grouping_no := Get_Qualifier_Grouping_No;

        IF g_QUALIFIERS_rec.qualifier_grouping_no IS NOT NULL THEN

            IF QP_Validate.Qualifier_Grouping_No(g_QUALIFIERS_rec.qualifier_grouping_no)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_GROUPING_NO
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_grouping_no := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.qualifier_id := Get_Qualifier;

        IF g_QUALIFIERS_rec.qualifier_id IS NOT NULL THEN

            IF QP_Validate.Qualifier(g_QUALIFIERS_rec.qualifier_id)
            THEN
                   g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_id := NULL;
            END IF;

        END IF;

    END IF;

    /*IF g_QUALIFIERS_rec.qualifier_number_format = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualifier_number_format := Get_Qualifier_Number_Format;

        IF g_QUALIFIERS_rec.qualifier_number_format IS NOT NULL THEN

            IF QP_Validate.Qualifier_Number_Format(g_QUALIFIERS_rec.qualifier_number_format)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_NUMBER_FORMAT
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_number_format := NULL;
            END IF;

        END IF;

    END IF;*/

    --dbms_output.put_line('chekcing for precedence');

    IF g_QUALIFIERS_rec.qualifier_precedence = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.qualifier_precedence := Get_Qualifier_Precedence(
											p_QUALIFIERS_rec.qualifier_context
                                                     , p_QUALIFIERS_rec.qualifier_attribute
										   ,p_QUALIFIERS_rec.qualifier_attr_value
										   );

        IF g_QUALIFIERS_rec.qualifier_precedence IS NOT NULL THEN

            IF QP_Validate.Qualifier_Precedence(g_QUALIFIERS_rec.qualifier_precedence)
            THEN
                  g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_PRECEDENCE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_precedence := NULL;
            END IF;

        END IF;

    END IF;


 oe_debug_pub.add('checking qualifier rule id in QPXDQPQB '|| g_QUALIFIERS_rec.qualifier_rule_id);


    IF g_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM THEN

        oe_debug_pub.add('atteching qualifier rule id by calling get_qualifier_rule');

        g_QUALIFIERS_rec.qualifier_rule_id := Get_Qualifier_Rule;

        IF g_QUALIFIERS_rec.qualifier_rule_id IS NOT NULL THEN

            IF QP_Validate.Qualifier_Rule(g_QUALIFIERS_rec.qualifier_rule_id)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFIER_RULE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualifier_rule_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_QUALIFIERS_rec.start_date_active := Get_Start_Date_Active;

        IF g_QUALIFIERS_rec.start_date_active IS NOT NULL THEN

            IF QP_Validate.Start_Date_Active(g_QUALIFIERS_rec.start_date_active)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec; -- added for nocopy hint
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_START_DATE_ACTIVE
                ,   p_QUALIFIERS_rec              => g_p_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.start_date_active := NULL;
            END IF;

        END IF;

    END IF;

-- Added for TCA

     IF g_QUALIFIERS_rec.qualify_hier_descendent_flag = FND_API.G_MISS_CHAR THEN

        g_QUALIFIERS_rec.qualify_hier_descendent_flag := Get_Qualify_Hier_Descendents;

        IF g_QUALIFIERS_rec.qualify_hier_descendent_flag IS NOT NULL THEN

            IF QP_Validate.Qualify_Hier_Descendent_Flag(g_QUALIFIERS_rec.qualify_hier_descendent_flag)
            THEN
                g_p_QUALIFIERS_rec := g_QUALIFIERS_rec;
                QP_Qualifiers_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Qualifiers_Util.G_QUALIFY_HIER_DESCENDENT_FLAG
                ,   p_QUALIFIERS_rec              => g_QUALIFIERS_rec
                ,   x_QUALIFIERS_rec              => g_QUALIFIERS_rec
                );
            ELSE
                g_QUALIFIERS_rec.qualify_hier_descendent_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR
    THEN

        Get_Flex_Qualifiers;

    END IF;

    IF g_QUALIFIERS_rec.created_by = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.created_by := NULL;

    END IF;

    IF g_QUALIFIERS_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_QUALIFIERS_rec.creation_date := NULL;

    END IF;

    IF g_QUALIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.last_updated_by := NULL;

    END IF;

    IF g_QUALIFIERS_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_QUALIFIERS_rec.last_update_date := NULL;

    END IF;

    IF g_QUALIFIERS_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.last_update_login := NULL;

    END IF;

    IF g_QUALIFIERS_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.program_application_id := NULL;

    END IF;

    IF g_QUALIFIERS_rec.program_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.program_id := NULL;

    END IF;

    IF g_QUALIFIERS_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_QUALIFIERS_rec.program_update_date := NULL;

    END IF;

    IF g_QUALIFIERS_rec.request_id = FND_API.G_MISS_NUM THEN

        g_QUALIFIERS_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_QUALIFIERS_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.comparison_operator_code = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.context = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.created_by = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.created_from_rule_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_QUALIFIERS_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_QUALIFIERS_rec.excluder_flag = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_QUALIFIERS_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.list_header_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.list_line_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.program_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_QUALIFIERS_rec.qualifier_attribute = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.qualifier_attr_value = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.qualifier_attr_value_to = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.qualifier_context = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.qualifier_datatype = FND_API.G_MISS_CHAR
    --OR  g_QUALIFIERS_rec.qualifier_date_format = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.qualifier_grouping_no = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.qualifier_id = FND_API.G_MISS_NUM
    --OR  g_QUALIFIERS_rec.qualifier_number_format = FND_API.G_MISS_CHAR
    OR  g_QUALIFIERS_rec.qualifier_precedence = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.qualifier_rule_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.request_id = FND_API.G_MISS_NUM
    OR  g_QUALIFIERS_rec.start_date_active = FND_API.G_MISS_DATE
    -- Added for TCA
    OR  g_QUALIFIERS_rec.qualify_hier_descendent_flag = FND_API.G_MISS_CHAR
    THEN

        QP_Default_Qualifiers.Attributes
        (   p_QUALIFIERS_rec              => g_QUALIFIERS_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_QUALIFIERS_rec              => x_QUALIFIERS_rec
        );

    ELSE

        --  Done defaulting attributes

        x_QUALIFIERS_rec := g_QUALIFIERS_rec;

    END IF;

END Attributes;

END QP_Default_Qualifiers;

/
