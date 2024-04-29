--------------------------------------------------------
--  DDL for Package Body QP_DEFAULT_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DEFAULT_PRICE_LIST" AS
/* $Header: QPXDPLHB.pls 120.7 2005/09/27 12:32:53 spgopal ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Default_Price_List';

--  Package global used within the package.

g_PRICE_LIST_rec              QP_Price_List_PUB.Price_List_Rec_Type;

--  Get functions.

FUNCTION Get_Automatic
RETURN VARCHAR2
IS
BEGIN

   oe_debug_pub.add('entering automatic');

  oe_debug_pub.add('exiting automatic');

    RETURN 'Y';

END Get_Automatic;

FUNCTION Get_Comments
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Comments;

FUNCTION Get_Name
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Name;

FUNCTION Get_Description
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Description;

FUNCTION Get_Currency
RETURN VARCHAR2
IS
l_set_of_books_id VARCHAR2(255) := '';
l_currency_code VARCHAR2(15) := '';
l_org_id NUMBER;
BEGIN

  oe_debug_Pub.add('entering currency');

     --added for moac to call Oe_sys_params only if org_id is not null
     l_org_id := QP_UTIL.get_org_id;
     IF l_org_id IS NOT NULL THEN
       l_set_of_books_id := oe_sys_parameters.value('SET_OF_BOOKS_ID', l_org_id);
     ELSE
       l_set_of_books_id := null;
     END IF;--if l_org_id

  IF l_set_of_books_id is not null THEN

   SELECT CURRENCY_CODE
   INTO l_currency_code
   FROM GL_SETS_OF_BOOKS
   WHERE SET_OF_BOOKS_ID = l_set_of_books_id;

  END IF;

  oe_debug_Pub.add('exiting currency');

  RETURN l_currency_code;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN RETURN NULL;

     WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Currency'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Get_Currency;

FUNCTION Get_Discount_Lines
RETURN VARCHAR2
IS
BEGIN

    RETURN 'N';

END Get_Discount_Lines;

FUNCTION Get_End_Date_Active
RETURN DATE
IS
BEGIN

    RETURN NULL;

END Get_End_Date_Active;

FUNCTION Get_Freight_Terms
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Freight_Terms;

FUNCTION Get_Gsa_Indicator
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Gsa_Indicator;

FUNCTION Get_Version
RETURN VARCHAR2
IS
BEGIN

    RETURN '1';

END Get_Version;

FUNCTION Get_List_Header
RETURN NUMBER
IS
   l_list_header_id	NUMBER := NULL;
BEGIN

    oe_debug_pub.add('Entering QP_Default_Price_List.Get_Price_List');

    select qp_list_headers_b_s.nextval into l_list_header_id
    from dual;

    oe_debug_pub.add('Exiting QP_Default_Price_List.Get_Price_List');
    RETURN l_list_header_id;

EXCEPTION

   WHEN OTHERS THEN

      IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Price_List'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;



END Get_List_Header;

FUNCTION Get_List_Type
RETURN VARCHAR2
IS
BEGIN

    RETURN 'PRL';

END Get_List_Type;

FUNCTION Get_Prorate
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Prorate;

FUNCTION Get_Active_Flag
RETURN VARCHAR2
IS
BEGIN
    RETURN 'Y';
END Get_Active_Flag;

-- mkarya for bug 1944882
FUNCTION Get_Mobile_Download
RETURN VARCHAR2
IS
BEGIN
    RETURN 'N';
END Get_Mobile_Download;

-- Pricing Security gtippire
FUNCTION Get_Global_Flag
RETURN VARCHAR2
IS
BEGIN
    RETURN 'Y';
END Get_Global_Flag;

-- Multi-Currency SunilPandey
FUNCTION Get_Currency_Header
RETURN VARCHAR2
IS
  l_currency_header_id  number;
BEGIN
  -- bug 2302661, if multi-currency is installed and public api do not pass the currency_header_id
  -- then find the currency header id for currency code and rounding factor. If currency_header_id
  -- is not found then create it.
  if nvl(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED'), 'N') = 'Y'
  --added for moac now defaulted currency_code can be null
  --when the default org_id is not set as the OM setofbooks will be null
  --and qp_currency_lists_b.base_currency_code is a notnull column
  --and the insert below will fail
  and g_PRICE_LIST_rec.currency_code IS NOT NULL then
     BEGIN
        select currency_header_id
          into l_currency_header_id
          from qp_currency_lists_vl
         where base_currency_code = g_PRICE_LIST_rec.currency_code
           and BASE_ROUNDING_FACTOR = g_PRICE_LIST_rec.rounding_factor
           and name like 'Generated Currency Conversion For%'
           and rownum < 2;

         return l_currency_header_id;
      EXCEPTION
        when no_data_found then
            declare
               ll_currency_header_id  number;
            begin
		 -- Get next currency_header_id
                 SELECT QP_CURRENCY_LISTS_B_S.NEXTVAL
                 INTO   ll_currency_header_id
                 FROM   dual;

                 -- Insert one record into qp_currency_lists
                 INSERT  INTO QP_CURRENCY_LISTS_B
                 (       ATTRIBUTE1
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
                 ,       BASE_CURRENCY_CODE
                 ,       CONTEXT
                 ,       CREATED_BY
                 ,       CREATION_DATE
                 ,       CURRENCY_HEADER_ID
                 ,       LAST_UPDATED_BY
                 ,       LAST_UPDATE_DATE
                 ,       LAST_UPDATE_LOGIN
                 ,       PROGRAM_APPLICATION_ID
                 ,       PROGRAM_ID
                 ,       PROGRAM_UPDATE_DATE
                 ,       REQUEST_ID
                 )
                 VALUES
                 (       null			-- attribute1
                 ,       null			-- attribute10
                 ,       null			-- attribute11
                 ,       null			-- attribute12
                 ,       null			-- attribute13
                 ,       null			-- attribute14
                 ,       null			-- attribute15
                 ,       null			-- attribute2
                 ,       null			-- attribute3
                 ,       null			-- attribute4
                 ,       null			-- attribute5
                 ,       null			-- attribute6
                 ,       null			-- attribute7
                 ,       null			-- attribute8
                 ,       null			-- attribute9
    	         ,       g_price_list_rec.CURRENCY_CODE 	-- base_currency_code
                 ,       null			-- context
                 ,       FND_GLOBAL.USER_ID	-- created_by
                 ,       SYSDATE		-- creation_date
                 ,       ll_CURRENCY_HEADER_ID  --currency_header_id
                 ,       FND_GLOBAL.USER_ID	-- last_updated_by
                 ,       SYSDATE		-- last_update_date
                 ,       FND_GLOBAL.LOGIN_ID	-- last_update_login
                 ,       FND_GLOBAL.PROG_APPL_ID -- program_application_id
                 ,       FND_GLOBAL.CONC_PROGRAM_ID -- program_id
                 ,       SYSDATE		    -- program_update_date
                 ,       FND_GLOBAL.CONC_REQUEST_ID -- request_id
                 );

                 -- Insert into qp_currency_details

                 INSERT  INTO QP_CURRENCY_DETAILS
     		 (       ATTRIBUTE1
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
                 ,       CONTEXT
                 ,       CONVERSION_DATE
                 ,       CONVERSION_DATE_TYPE
                 ,       CONVERSION_TYPE
                 ,       CREATED_BY
                 ,       CREATION_DATE
                 ,       CURRENCY_DETAIL_ID
                 ,       CURRENCY_HEADER_ID
                 ,       END_DATE_ACTIVE
                 ,       FIXED_VALUE
                 ,       LAST_UPDATED_BY
                 ,       LAST_UPDATE_DATE
                 ,       LAST_UPDATE_LOGIN
                 ,       MARKUP_FORMULA_ID
                 ,       MARKUP_OPERATOR
                 ,       MARKUP_VALUE
                 ,       PRICE_FORMULA_ID
                 ,       PROGRAM_APPLICATION_ID
                 ,       PROGRAM_ID
                 ,       PROGRAM_UPDATE_DATE
                 ,       REQUEST_ID
                 ,       SELLING_ROUNDING_FACTOR
                 ,       START_DATE_ACTIVE
                 ,       TO_CURRENCY_CODE
                 )
                 VALUES
                 (       null         		-- attribute1
                 ,       null         		-- attribute10
                 ,       null         		-- attribute11
                 ,       null         		-- attribute12
                 ,       null         		-- attribute13
                 ,       null         		-- attribute14
                 ,       null         		-- attribute15
                 ,       null         		-- attribute2
                 ,       null         		-- attribute3
                 ,       null         		-- attribute4
                 ,       null         		-- attribute5
                 ,       null         		-- attribute6
                 ,       null         		-- attribute7
                 ,       null        		-- attribute8
                 ,       null         		-- attribute9
                 ,       null         		-- context
                 ,       null         		-- conversion_date
                 ,       null         		-- conversion_date_type
                 ,       null         		-- conversion_type
                 ,       FND_GLOBAL.USER_ID	-- created_by
                 ,       SYSDATE      		-- creation_date
                 ,       QP_CURRENCY_DETAILS_S.nextval  -- currency_detail_id
                 ,       ll_CURRENCY_HEADER_ID	-- currency_header_id
                 ,       null         		-- end_date_active
                 ,       null         		-- fixed_value
                 ,       FND_GLOBAL.USER_ID	-- last_updated_by
                 ,       SYSDATE       		-- last_update_date
                 ,       FND_GLOBAL.LOGIN_ID    -- last_update_login
                 ,       null	      		-- base_markup_formula_id
                 ,       null         		-- base_markup_operator
                 ,       null         		-- base_markup_value
                 ,       null         		-- price_formula_id
                 ,       FND_GLOBAL.PROG_APPL_ID    -- program_application_id
                 ,       FND_GLOBAL.CONC_PROGRAM_ID -- program_id
                 ,       SYSDATE                    -- program_update_date
                 ,       FND_GLOBAL.CONC_REQUEST_ID -- request_id
                 ,       g_price_list_rec.ROUNDING_FACTOR 	-- base_rounding_factor
                 ,       null         		-- start_date_active
                 ,       g_price_list_rec.CURRENCY_CODE     -- base_currency_code
                 );


                 -- Insert into qp_currency_lists_tl
                 INSERT INTO QP_CURRENCY_LISTS_TL
                 (       CURRENCY_HEADER_ID
                 , 	 NAME
                 , 	 DESCRIPTION
                 , 	 CREATION_DATE
                 , 	 CREATED_BY
                 ,       LAST_UPDATE_DATE
                 ,       LAST_UPDATED_BY
                 ,       LAST_UPDATE_LOGIN
                 ,       LANGUAGE
                 ,       SOURCE_LANG
                 )
                 select
                         ll_currency_header_id	--CURRENCY_HEADER_ID
    	         ,      'Generated Currency Conversion For '|| g_price_list_rec.currency_code||' '||ll_currency_header_id -- NAME
                 ,      'Generated Currency Conversion For '|| g_price_list_rec.currency_code||' '||ll_currency_header_id -- DESCRIPTION
                 , 	 SYSDATE		-- CREATION_DATE
                 , 	 FND_GLOBAL.USER_ID	-- CREATED_BY
                 , 	 SYSDATE		-- LAST_UPDATE_DATE
                 , 	 FND_GLOBAL.USER_ID	-- LAST_UPDATED_BY
                 , 	 FND_GLOBAL.LOGIN_ID	-- LAST_UPDATE_LOGIN
                 , 	 L.LANGUAGE_CODE	-- LANGUAGE
                 ,       userenv('LANG')	-- SOURCE_LANG
                 from    fnd_languages l
                 where   l.installed_flag IN ('I','B');

                return ll_currency_header_id;
             end;

        when others then
            IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
             THEN
              OE_MSG_PUB.Add_Exc_Msg
                (    G_PKG_NAME          ,
                     'Get_Currency_Header'
                 );
           END IF;

           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END;
  else
    RETURN NULL;
  end if;
END Get_Currency_Header;

-- Attribute Manager Giri
FUNCTION Get_Pte
RETURN VARCHAR2
IS
l_pte_code            VARCHAR2(30);
BEGIN
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

    IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
    END IF;
    RETURN l_pte_code;
END Get_Pte;

FUNCTION Get_Rounding_Factor
RETURN NUMBER
IS
l_unit_precision_type varchar2(255) := '';
l_precision number := 0;
l_extended_precision number := 0;

BEGIN

   oe_debug_pub.add('entering get_rounding_factor');

  l_unit_precision_type :=
              FND_PROFILE.VALUE('QP_UNIT_PRICE_PRECISION_TYPE');

    SELECT -1*PRECISION,
           -1*EXTENDED_PRECISION
    INTO   l_precision,
           l_extended_precision
    FROM   FND_CURRENCIES
   WHERE   CURRENCY_CODE = G_PRICE_LIST_REC.CURRENCY_CODE;

  IF l_unit_precision_type = 'STANDARD' THEN
   oe_debug_pub.add('exiting get_rounding_factor');
   return l_precision;
  ELSE
	return l_extended_precision;
  END IF;

   EXCEPTION

     WHEN NO_DATA_FOUND THEN RETURN NULL;

     WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Rounding_Factor'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Rounding_Factor;

FUNCTION Get_Ship_Method
RETURN VARCHAR2
IS
BEGIN

    RETURN NULL;

END Get_Ship_Method;

FUNCTION Get_Start_Date_Active
RETURN DATE
IS
l_sysdate date;
BEGIN

   oe_debug_pub.add('entering start date active');
   SELECT TRUNC(SYSDATE)
   INTO l_sysdate
   FROM DUAL;

   oe_debug_pub.add('exiting start date active');

    RETURN l_sysdate;

  EXCEPTION

     WHEN NO_DATA_FOUND THEN RETURN NULL;

     WHEN OTHERS THEN

       IF OE_MSG_PUB.Check_Msg_Level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
         OE_MSG_PUB.Add_Exc_Msg
           (    G_PKG_NAME          ,
                'Get_Start_Date_Active'
            );
      END IF;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Start_Date_Active;

FUNCTION Get_Terms
RETURN NUMBER
IS
BEGIN

    RETURN NULL;

END Get_Terms;

--Blanket Sales Order
FUNCTION Get_List_Source_Code
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_List_Source_Code;

--Blanket Sales Order
FUNCTION Get_Orig_System_Header_Ref
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Orig_System_Header_Ref;

-- Blanket Pricing
FUNCTION Get_Source_System_Code
RETURN VARCHAR2
IS
l_source_system_code VARCHAR2(30);
BEGIN

    FND_PROFILE.GET('QP_SOURCE_SYSTEM_CODE',l_source_system_code);
    RETURN l_source_system_code;

END Get_Source_System_Code;

FUNCTION Get_Shareable_Flag
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Shareable_Flag;

FUNCTION Get_Sold_To_Org_Id
RETURN VARCHAR2
IS BEGIN

    RETURN NULL;

END Get_Sold_To_Org_Id;


FUNCTION Get_Locked_From_List_Header_Id
RETURN NUMBER
IS BEGIN

    RETURN NULL;

END Get_Locked_From_List_Header_Id;

--added for MOAC
FUNCTION Get_Org_Id
RETURN NUMBER
IS BEGIN

    RETURN QP_UTIL.Get_Org_Id;

END Get_Org_Id;

PROCEDURE Get_Flex_Price_List
IS
BEGIN

    --  In the future call Flex APIs for defaults

    IF g_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute1    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute10   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute11   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute12   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute13   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute14   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute15   := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute2    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute3    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute4    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute5    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute6    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute7    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute8    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.attribute9    := NULL;
    END IF;

    IF g_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR THEN
        g_PRICE_LIST_rec.context       := NULL;
    END IF;

END Get_Flex_Price_List;

--  Procedure Attributes

PROCEDURE Attributes
(   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
,   p_iteration                     IN  NUMBER := 1
,   x_PRICE_LIST_rec                OUT NOCOPY /* file.sql.39 change */ QP_Price_List_PUB.Price_List_Rec_Type
)
IS
g_p_PRICE_LIST_rec         QP_Price_List_PUB.Price_List_Rec_Type;
BEGIN

    oe_debug_pub.add('entering attributes');

    --  Check number of iterations.

    IF p_iteration > QP_GLOBALS.G_MAX_DEF_ITERATIONS THEN

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','OE_DEF_MAX_ITERATION');
            oe_msg_pub.Add;

        END IF;

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --  Initialize g_PRICE_LIST_rec

    g_PRICE_LIST_rec := p_PRICE_LIST_rec;

    --  Default missing attributes.

    IF g_PRICE_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.automatic_flag := Get_Automatic;

        IF g_PRICE_LIST_rec.automatic_flag IS NOT NULL THEN

            IF QP_Validate.Automatic(g_PRICE_LIST_rec.automatic_flag)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_AUTOMATIC
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.automatic_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.comments = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.comments := Get_Comments;

        IF g_PRICE_LIST_rec.comments IS NOT NULL THEN

            IF QP_Validate.Comments(g_PRICE_LIST_rec.comments)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_COMMENTS
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.comments := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.currency_code := Get_Currency;

        IF g_PRICE_LIST_rec.currency_code IS NOT NULL THEN

            IF QP_Validate.Currency(g_PRICE_LIST_rec.currency_code)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_CURRENCY
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.currency_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.discount_lines_flag := Get_Discount_Lines;

        IF g_PRICE_LIST_rec.discount_lines_flag IS NOT NULL THEN

            IF QP_Validate.Discount_Lines(g_PRICE_LIST_rec.discount_lines_flag)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_DISCOUNT_LINES
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.discount_lines_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.end_date_active := Get_End_Date_Active;

        IF g_PRICE_LIST_rec.end_date_active IS NOT NULL THEN

            IF QP_Validate.End_Date_Active(g_PRICE_LIST_rec.end_date_active)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_END_DATE_ACTIVE
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.end_date_active := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.freight_terms_code := Get_Freight_Terms;

        IF g_PRICE_LIST_rec.freight_terms_code IS NOT NULL THEN

            IF QP_Validate.Freight_Terms(g_PRICE_LIST_rec.freight_terms_code)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_FREIGHT_TERMS
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.freight_terms_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.gsa_indicator := Get_Gsa_Indicator;

        IF g_PRICE_LIST_rec.gsa_indicator IS NOT NULL THEN

            IF QP_Validate.Gsa_Indicator(g_PRICE_LIST_rec.gsa_indicator)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_GSA_INDICATOR
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.gsa_indicator := NULL;
            END IF;

        END IF;

    END IF;

IF g_PRICE_LIST_rec.active_flag = FND_API.G_MISS_CHAR THEN
     g_PRICE_LIST_rec.active_flag := Get_Active_Flag;
	  IF g_PRICE_LIST_rec.active_flag IS NOT NULL THEN
		IF QP_Validate.active(g_PRICE_LIST_rec.active_flag)
		THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
		   QP_Price_List_Util.Clear_Dependent_Attr
			(p_attr_id              => QP_Price_list_Util.G_ACTIVE_FLAG,
			 p_PRICE_LIST_rec       => g_p_PRICE_LIST_rec,
			 x_PRICE_LIST_rec       => g_PRICE_LIST_rec);
          ELSE
		   g_PRICE_LIST_rec.active_flag := NULL;
          END IF;
        END IF;
END IF;

-- mkarya for bug 1944882
IF g_PRICE_LIST_rec.mobile_download = FND_API.G_MISS_CHAR THEN
     g_PRICE_LIST_rec.mobile_download := Get_Mobile_Download;
	  IF g_PRICE_LIST_rec.mobile_download IS NOT NULL THEN
		IF QP_Validate.mobile_download(g_PRICE_LIST_rec.mobile_download)
		THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
		   QP_Price_List_Util.Clear_Dependent_Attr
			(p_attr_id              => QP_Price_list_Util.G_MOBILE_DOWNLOAD,
			 p_PRICE_LIST_rec       => g_p_PRICE_LIST_rec,
			 x_PRICE_LIST_rec       => g_PRICE_LIST_rec);
          ELSE
		   g_PRICE_LIST_rec.mobile_download := NULL;
          END IF;
        END IF;
END IF;

-- Pricing Security gtippire
IF g_PRICE_LIST_rec.global_flag = FND_API.G_MISS_CHAR THEN
     g_PRICE_LIST_rec.global_flag := Get_Global_Flag;
	  IF g_PRICE_LIST_rec.global_flag IS NOT NULL THEN
		IF QP_Validate.global_flag(g_PRICE_LIST_rec.global_flag)
		THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
		   QP_Price_List_Util.Clear_Dependent_Attr
			(p_attr_id              => QP_Price_list_Util.G_GLOBAL_FLAG,
			 p_PRICE_LIST_rec       => g_p_PRICE_LIST_rec,
			 x_PRICE_LIST_rec       => g_PRICE_LIST_rec);
          ELSE
		   g_PRICE_LIST_rec.global_flag := NULL;
          END IF;
        END IF;
END IF;


-- Attributes Manager Giri
IF g_PRICE_LIST_rec.pte_code = FND_API.G_MISS_CHAR THEN
     g_PRICE_LIST_rec.pte_code := Get_Pte;
	  IF g_PRICE_LIST_rec.pte_code IS NOT NULL THEN
		IF QP_Validate.pte(g_PRICE_LIST_rec.pte_code)
		THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
		   QP_Price_List_Util.Clear_Dependent_Attr
			(p_attr_id              => QP_Price_list_Util.G_PTE,
			 p_PRICE_LIST_rec       => g_p_PRICE_LIST_rec,
			 x_PRICE_LIST_rec       => g_PRICE_LIST_rec);
          ELSE
		   g_PRICE_LIST_rec.pte_code := NULL;
          END IF;
        END IF;
END IF;


    IF g_PRICE_LIST_rec.name = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.name := Get_Name;

        IF g_PRICE_LIST_rec.name IS NOT NULL THEN

            IF QP_Validate.Name(g_PRICE_LIST_rec.name)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_NAME
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.name := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.description = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.description := Get_Description;

        IF g_PRICE_LIST_rec.description IS NOT NULL THEN

            IF QP_Validate.Description(g_PRICE_LIST_rec.description)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_DESCRIPTION
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.description := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.list_header_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.list_header_id := Get_List_Header;

        IF g_PRICE_LIST_rec.list_header_id IS NOT NULL THEN

            IF QP_Validate.List_Header(g_PRICE_LIST_rec.list_header_id)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_LIST_HEADER
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.list_header_id := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.list_type_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.list_type_code := Get_List_Type;

        IF g_PRICE_LIST_rec.list_type_code IS NOT NULL THEN

            IF QP_Validate.List_Type(g_PRICE_LIST_rec.list_type_code)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_LIST_TYPE
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.list_type_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.version_no = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.version_no := Get_Version;

        IF g_PRICE_LIST_rec.version_no IS NOT NULL THEN

            IF QP_Validate.Version(g_PRICE_LIST_rec.version_no)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_VERSION_NO
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.version_no := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.prorate_flag := Get_Prorate;

        IF g_PRICE_LIST_rec.prorate_flag IS NOT NULL THEN

            IF QP_Validate.Prorate(g_PRICE_LIST_rec.prorate_flag)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_PRORATE
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.prorate_flag := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.rounding_factor := Get_Rounding_Factor;

        IF g_PRICE_LIST_rec.rounding_factor IS NOT NULL THEN

            IF QP_Validate.Rounding_Factor(g_PRICE_LIST_rec.rounding_factor)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_ROUNDING_FACTOR
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.rounding_factor := NULL;
            END IF;

        END IF;

    END IF;

-- Multi-Currency SunilPandey
IF g_PRICE_LIST_rec.currency_header_id = FND_API.G_MISS_NUM THEN
     g_PRICE_LIST_rec.currency_header_id := Get_Currency_Header;
	  IF g_PRICE_LIST_rec.currency_header_id IS NOT NULL THEN
		IF QP_Validate.currency_header(g_PRICE_LIST_rec.currency_header_id)
		THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
		   QP_Price_List_Util.Clear_Dependent_Attr
			(p_attr_id              => QP_Price_list_Util.G_CURRENCY_HEADER,
			 p_PRICE_LIST_rec       => g_p_PRICE_LIST_rec,
			 x_PRICE_LIST_rec       => g_PRICE_LIST_rec);
          ELSE
		   g_PRICE_LIST_rec.currency_header_id := NULL;
          END IF;
        END IF;
END IF;

    IF g_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR THEN

        g_PRICE_LIST_rec.ship_method_code := Get_Ship_Method;

        IF g_PRICE_LIST_rec.ship_method_code IS NOT NULL THEN

            IF QP_Validate.Ship_Method(g_PRICE_LIST_rec.ship_method_code)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_SHIP_METHOD
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.ship_method_code := NULL;
            END IF;

        END IF;

    END IF;

    IF g_PRICE_LIST_rec.start_date_active = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.start_date_active := Get_Start_Date_Active;

	  /*
        IF g_PRICE_LIST_rec.start_date_active IS NOT NULL THEN

		oe_debug_pub.add('start date active is not null');

            IF QP_Validate.Start_Date_Active(g_PRICE_LIST_rec.start_date_active)
            THEN
              oe_debug_pub.add('valid start date');
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_START_DATE_ACTIVE
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
			oe_debug_pub.add('setting start date to be null');
                g_PRICE_LIST_rec.start_date_active := NULL;
            END IF;

        END IF;
	    */

    END IF;

    IF g_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM THEN

	oe_debug_pub.add('defaulting terms id');
        g_PRICE_LIST_rec.terms_id := Get_Terms;

        IF g_PRICE_LIST_rec.terms_id IS NOT NULL THEN

            IF QP_Validate.Terms(g_PRICE_LIST_rec.terms_id)
            THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_TERMS
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                g_PRICE_LIST_rec.terms_id := NULL;
            END IF;

        END IF;
	   oe_debug_pub.add('defaulted terms id');

    END IF;

--Blanket Sales Order
    IF g_PRICE_LIST_rec.list_source_code = FND_API.G_MISS_CHAR THEN

       g_PRICE_LIST_REC.list_source_code := Get_List_Source_Code;

       IF g_PRICE_LIST_REC.list_source_code IS NOT NULL THEN

           IF QP_Validate.List_Source_Code(g_PRICE_LIST_rec.list_source_code) THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
	        QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_LIST_SOURCE
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                        oe_debug_pub.add('setting list_source_code and orig_system_header_ref to be null');
                g_PRICE_LIST_rec.list_source_code := NULL;
            END IF;

        END IF;
    END IF;


--Blanket Sales Order
    IF g_PRICE_LIST_rec.orig_system_header_ref = FND_API.G_MISS_CHAR THEN

       g_PRICE_LIST_REC.orig_system_header_ref := Get_Orig_System_Header_ref;

      /* IF g_PRICE_LIST_REC.orig_system_header_ref IS NOT NULL THEN

           IF QP_Validate.List_Source_Code(g_PRICE_LIST_rec.list_source_code) THEN
	        QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_LIST_SOURCE
                ,   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                        oe_debug_pub.add('setting list_source_code and orig_system_header_ref to be null');
                g_PRICE_LIST_rec.list_source_code := NULL;
            END IF;

        END IF;
     */
   END IF;

--Blanket pricing
    IF g_PRICE_LIST_rec.source_system_code = FND_API.G_MISS_CHAR THEN

       g_PRICE_LIST_REC.source_system_code := Get_Source_System_Code;

       IF g_PRICE_LIST_REC.source_system_code IS NOT NULL THEN

           IF QP_Validate.Source_System(g_PRICE_LIST_rec.source_system_code) THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
	        QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_SOURCE_SYSTEM_CODE
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                oe_debug_pub.add('setting source_system_code to be null');
                g_PRICE_LIST_rec.source_system_code := NULL;
            END IF;

        END IF;
    END IF;

    IF g_PRICE_LIST_rec.shareable_flag = FND_API.G_MISS_CHAR THEN

       g_PRICE_LIST_REC.shareable_flag := Get_Shareable_Flag;

       IF g_PRICE_LIST_REC.shareable_flag IS NOT NULL THEN

           IF QP_Validate.Shareable_Flag(g_PRICE_LIST_rec.shareable_flag) THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
	        QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_SHAREABLE_FLAG
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                oe_debug_pub.add('setting shareable_flag to be null');
                g_PRICE_LIST_rec.shareable_flag := NULL;
            END IF;

        END IF;
    END IF;


    IF g_PRICE_LIST_rec.sold_to_org_id = FND_API.G_MISS_NUM THEN

       g_PRICE_LIST_REC.sold_to_org_id := Get_Sold_To_Org_Id;

       IF g_PRICE_LIST_REC.sold_to_org_id IS NOT NULL THEN

           IF QP_Validate.Sold_To_Org_Id(g_PRICE_LIST_rec.sold_to_org_id) THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
	        QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id                     => QP_Price_List_Util.G_SOLD_TO_ORG_ID
                ,   p_PRICE_LIST_rec              => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
                oe_debug_pub.add('setting sold_to_org_id to be null');
                g_PRICE_LIST_rec.sold_to_org_id := NULL;
            END IF;

        END IF;
    END IF;

    IF g_PRICE_LIST_rec.locked_from_list_header_id = FND_API.G_MISS_NUM THEN

       g_PRICE_LIST_REC.locked_from_list_header_id := Get_Locked_From_List_Header_Id;

       IF g_PRICE_LIST_REC.locked_from_list_header_id IS NOT NULL THEN

           IF QP_Validate.Locked_From_list_Header_Id(g_PRICE_LIST_rec.locked_from_list_header_id) THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id    => QP_Price_List_Util.G_LOCKED_FROM_LIST_HEADER
                ,   p_PRICE_LIST_rec   => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
              oe_debug_pub.add('setting locked_from_list_header_id to be null');
              g_PRICE_LIST_rec.locked_from_list_header_id := NULL;
            END IF;

        END IF;
    END IF;

    --added for MOAC
    IF g_PRICE_LIST_rec.org_id = FND_API.G_MISS_NUM THEN

      IF g_PRICE_LIST_rec.global_flag = 'N' THEN
       --global_flag defaulting happens before org_id defaulting
       g_PRICE_LIST_REC.org_id := Get_Org_Id;
      ELSE
       g_PRICE_LIST_REC.org_id := null;
      END IF;


       IF g_PRICE_LIST_REC.org_id IS NOT NULL THEN

           IF QP_Validate.Org_id(g_PRICE_LIST_rec.org_id) THEN
                g_p_PRICE_LIST_rec := g_PRICE_LIST_rec;
                QP_Price_List_Util.Clear_Dependent_Attr
                (   p_attr_id    => QP_Price_List_Util.G_ORG_ID
                ,   p_PRICE_LIST_rec   => g_p_PRICE_LIST_rec
                ,   x_PRICE_LIST_rec              => g_PRICE_LIST_rec
                );
            ELSE
              oe_debug_pub.add('setting ORG_ID to be null');
              g_PRICE_LIST_rec.org_id := NULL;
            END IF;

        END IF;
    END IF;

    IF g_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR
    THEN

	  oe_debug_Pub.add('getting flex field info');

        Get_Flex_Price_List;
	   oe_debug_Pub.add('after getting flex field');

    END IF;

    IF g_PRICE_LIST_rec.created_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.created_by := NULL;

    END IF;

    IF g_PRICE_LIST_rec.creation_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.creation_date := NULL;

    END IF;

    IF g_PRICE_LIST_rec.last_updated_by = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.last_updated_by := NULL;

    END IF;

    IF g_PRICE_LIST_rec.last_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.last_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_rec.last_update_login = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.last_update_login := NULL;

    END IF;

    IF g_PRICE_LIST_rec.program_application_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.program_application_id := NULL;

    END IF;

    IF g_PRICE_LIST_rec.program_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.program_id := NULL;

    END IF;

    IF g_PRICE_LIST_rec.program_update_date = FND_API.G_MISS_DATE THEN

        g_PRICE_LIST_rec.program_update_date := NULL;

    END IF;

    IF g_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM THEN

        g_PRICE_LIST_rec.request_id := NULL;

    END IF;

    --  Redefault if there are any missing attributes.

    IF  g_PRICE_LIST_rec.attribute1 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute10 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute11 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute12 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute13 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute14 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute15 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute2 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute3 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute4 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute5 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute6 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute7 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute8 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.attribute9 = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.automatic_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.comments = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.context = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.created_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.creation_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.currency_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.discount_lines_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.end_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.freight_terms_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.gsa_indicator = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.last_updated_by = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.last_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.last_update_login = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.list_header_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.list_type_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.version_no = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.program_application_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.program_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.program_update_date = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.prorate_flag = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.request_id = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM
    OR  g_PRICE_LIST_rec.ship_method_code = FND_API.G_MISS_CHAR
    OR  g_PRICE_LIST_rec.start_date_active = FND_API.G_MISS_DATE
    OR  g_PRICE_LIST_rec.terms_id = FND_API.G_MISS_NUM
    THEN

	  oe_debug_pub.add('redefault attributes 1');

        QP_Default_Price_List.Attributes
        (   p_PRICE_LIST_rec              => g_PRICE_LIST_rec
        ,   p_iteration                   => p_iteration + 1
        ,   x_PRICE_LIST_rec              => x_PRICE_LIST_rec
        );

	   oe_debug_pub.add('redefault attributes 2');

    ELSE

        --  Done defaulting attributes

        x_PRICE_LIST_rec := g_PRICE_LIST_rec;

    END IF;

    oe_debug_pub.add('exiting attributes');

END Attributes;

END QP_Default_Price_List;

/
