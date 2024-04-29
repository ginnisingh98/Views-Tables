--------------------------------------------------------
--  DDL for Package Body QP_DELAYED_REQUESTS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_DELAYED_REQUESTS_UTIL" AS
/* $Header: QPXUREQB.pls 120.14.12010000.5 2009/12/18 05:09:49 jputta ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Delayed_Requests_UTIL';


Procedure Check_For_Duplicate_Qualifiers
  ( x_return_status OUT NOCOPY Varchar2
  , p_qualifier_rule_id     IN NUMBER
  ) IS
l_status  VARCHAR2(20);
DUPLICATE_DISCOUNT EXCEPTION;
Cursor C_Qualifiers(p_qualifier_rule_id number) IS
   Select 'DUPLICATE'
    from   qp_qualifiers a , qp_qualifiers b
    where a.qualifier_rule_id = b.qualifier_rule_id
    and a.qualifier_rule_id = p_qualifier_rule_id
    and a.qualifier_grouping_no = b.qualifier_grouping_no
    and a.qualifier_context = b.qualifier_context
    and a. qualifier_attribute = b.qualifier_attribute
    and a.qualifier_id <> b.qualifier_id;

BEGIN

   oe_debug_pub.add('Entering QP_DELAYED_REQUESTS_UTIL.check dup');
   oe_debug_pub.add('passed rule id is'||p_qualifier_rule_id);
   --dbms_output.put_line('Entering QP_DELAYED_REQUESTS_UTIL.check dup');
   --dbms_output.put_line('passed rule id is'||p_qualifier_rule_id);

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   open C_Qualifiers(p_qualifier_rule_id);
   fetch C_Qualifiers into l_status;
   close C_Qualifiers;

    --dbms_output.put_line('status is '||l_status);
       If l_status = 'DUPLICATE' Then

   oe_debug_pub.add('status is duplicate');
    --dbms_output.put_line('status is duplicate');
           x_return_status := FND_API.G_RET_STS_ERROR;

	      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	        THEN

	            fnd_message.set_name('ONT', 'OE_DIS_DUPLICATE_LIN_DISC');
	            OE_MSG_PUB.Add;
	      END IF;
	 RAISE DUPLICATE_DISCOUNT;
	 END IF;

   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.checkdup');
   --dbms_output.put_line('Exiting QP_DELAYED_REQUESTS_UTIL.checkdup');

EXCEPTION
   WHEN  DUPLICATE_DISCOUNT
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

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
            ,   'QP_Delayed_Requests_Util'
);
END IF;
END Check_For_Duplicate_Qualifiers;

Procedure Maintain_List_Header_Phases
( p_List_Header_ID IN NUMBER
, x_return_status OUT NOCOPY VARCHAR2
) IS

BEGIN

delete from qp_list_header_phases
where list_header_id = p_List_Header_ID;

/*
 Bug - 8224336
 Changes for Pattern Engine - added column PRIC_PROD_ATTR_ONLY_FLAG
 Column PRIC_PROD_ATTR_ONLY_FLAG in table qp_list_header_phases will be -
 'Y' - If all the lines in the header for that phase have only product or pricing or both attributes (but not qualifiers).
 'N' - If atleast one line within that header or header itself has qualifiers attached, for that phase
*/

insert into qp_list_header_phases
 (list_header_id, pricing_phase_id,PRIC_PROD_ATTR_ONLY_FLAG)
(
select distinct list_header_id , pricing_phase_id,'N'
from   qp_list_lines
where  pricing_phase_id > 1
and qualification_ind in (2,6,8,10,12,14,22,28,30)
and list_header_id = p_List_Header_ID);


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
            ,   'Maintain_List_Header_Phases');
        END IF;

END Maintain_List_Header_Phases;

Procedure Update_Qualifier_Status(p_list_header_id in NUMBER,
                                  p_active_flag in VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE qp_qualifiers
  SET active_flag = p_active_flag
  WHERE list_header_id = p_list_header_id;

  IF p_active_flag = 'Y'
  THEN
    update qp_pte_segments set used_in_setup='Y'
    where nvl(used_in_setup,'N')='N'
    and segment_id in
    (select a.segment_id
    from qp_segments_b a, qp_prc_contexts_b b, qp_qualifiers c
    where c.list_header_id         = p_list_header_id
    and   a.segment_mapping_column = c.qualifier_attribute
    and   a.prc_context_id         = b.prc_context_id
    and   b.prc_context_type       = 'QUALIFIER'
    and   b.prc_context_code       = c.qualifier_context);

    update qp_pte_segments set used_in_setup='Y'
    where nvl(used_in_setup,'N')='N'
    and segment_id in
    (select  a.segment_id
    from qp_segments_b a, qp_prc_contexts_b b, qp_pricing_attributes c
    where c.list_header_id         = p_list_header_id
    and   a.segment_mapping_column = c.pricing_attribute
    and   a.prc_context_id         = b.prc_context_id
    and   b.prc_context_type       = 'PRICING_ATTRIBUTE'
    and   b.prc_context_code       = c.pricing_attribute_context);

    update qp_pte_segments set used_in_setup='Y'
    where nvl(used_in_setup,'N')='N'
    and segment_id in
    (select  a.segment_id
    from qp_segments_b a, qp_prc_contexts_b b, qp_pricing_attributes c
    where c.list_header_id         = p_list_header_id
    and   a.segment_mapping_column = c.product_attribute
    and   a.prc_context_id         = b.prc_context_id
    and   b.prc_context_type       = 'PRODUCT'
    and   b.prc_context_code       = c.product_attribute_context);

  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME
                 ,   'QP_Delayed_Requests_Util');
    END IF;
END Update_Qualifier_Status;

Procedure Create_Security_Privilege(p_list_header_id in NUMBER,
                                    p_list_type_code in VARCHAR2,
                                    x_return_status OUT NOCOPY VARCHAR2)
IS
 x_result                   VARCHAR2(1);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_list_type_code = 'AGR' THEN
    QP_security.create_default_grants( p_instance_type => QP_security.G_AGREEMENT_OBJECT,
                                       p_instance_pk1  => p_list_header_id,
                                       x_return_status => x_result);
  ELSIF p_list_type_code = 'PRL' THEN
    QP_security.create_default_grants( p_instance_type => QP_security.G_PRICELIST_OBJECT,
                                       p_instance_pk1  => p_list_header_id,
                                       x_return_status => x_result);
  ELSE
    QP_security.create_default_grants( p_instance_type => QP_security.G_MODIFIER_OBJECT,
                                       p_instance_pk1  => p_list_header_id,
                                       x_return_status => x_result);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME
                 ,   'QP_Delayed_Requests_Util');
    END IF;
END Create_Security_Privilege;

Procedure Update_Attribute_Status(p_list_header_id in NUMBER,
                                  p_list_line_id in NUMBER,
                                  p_context_type in VARCHAR2,
                                  p_context_code in VARCHAR2,
                                  p_segment_mapping_column VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2)
IS
l_check_active_flag     VARCHAR2(1);
l_active_flag           VARCHAR2(1);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_list_header_id IS NOT NULL THEN
       SELECT ACTIVE_FLAG
       INTO   l_active_flag
       FROM   QP_LIST_HEADERS_B
       WHERE  list_header_id=p_list_header_id;
    END IF;
    IF p_list_line_id IS NOT NULL THEN
       SELECT ListHeaders.ACTIVE_FLAG
       INTO  l_active_flag
       FROM   QP_LIST_HEADERS_B ListHeaders, QP_LIST_LINES ListLines
       WHERE  ListHeaders.LIST_HEADER_ID = ListLines.LIST_HEADER_ID AND
              ListLines.LIST_LINE_ID = p_list_line_id AND
              rownum = 1;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  l_check_active_flag:=nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');
  IF (l_check_active_flag='N') OR (l_check_active_flag='Y' AND l_active_flag='Y') THEN
    IF(p_context_code IS NOT NULL) AND
      (p_segment_mapping_column IS NOT NULL) THEN
      UPDATE qp_pte_segments set used_in_setup='Y'
      WHERE  nvl(used_in_setup,'N')='N'
      AND    segment_id IN
      (SELECT a.segment_id FROM qp_segments_b a, qp_prc_contexts_b b
       WHERE  a.segment_mapping_column=p_segment_mapping_column
       AND    a.prc_context_id=b.prc_context_id
       AND b.prc_context_type = p_context_type
       AND    b.prc_context_code=p_context_code);
    END IF;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
                  (   G_PKG_NAME
                 ,   'QP_Delayed_Requests_Util');
    END IF;
END Update_Attribute_Status;


-- start bug2091362
Procedure Check_Duplicate_Modifier_Lines
  (  p_Start_Date_Active IN DATE
   , p_End_Date_Active IN DATE
   , p_List_Line_ID IN NUMBER
   , p_List_Header_ID IN NUMBER
   , p_pricing_attribute_context IN VARCHAR2
   , p_pricing_attribute IN VARCHAR2
   , p_Pricing_attr_value IN VARCHAR2
   , x_return_status OUT NOCOPY VARCHAR2
  ) IS
l_status BOOLEAN := TRUE;
l_rows number := 0;
l_effdates boolean := FALSE;
BEGIN

   oe_debug_pub.add('Entering QP_DELAYED_REQUESTS_UTIL.check_duplicate_modifier_lines');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_status := QP_VALIDATE_PRICING_ATTR.Mod_Dup(p_Start_Date_Active,
                                              p_End_Date_Active,
                                              p_List_Line_ID,
                                              p_List_Header_ID,
                                              p_pricing_attribute_context,
                                              p_pricing_attribute,
                                              p_pricing_attr_value,
                                              l_rows,
                                              l_effdates);

     IF l_status = FALSE then


	   oe_debug_pub.add('Ren: check_duplicate_modifiers status is false ');

            FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_MODIFIER_LINES');
            oe_msg_pub.Add;

          RAISE FND_API.G_EXC_ERROR;

       END IF;



   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.mod_dup');


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
            ,   'Check_duplicate_Modifier_lines');
        END IF;

END Check_Duplicate_Modifier_Lines;

-- end bug2091362


Procedure Check_Duplicate_List_Lines
  (  p_Start_Date_Active IN DATE
   , p_End_Date_Active IN DATE
   , p_Revision IN VARCHAR2
   , p_List_Line_ID IN NUMBER
   , p_List_Header_ID IN NUMBER
   , x_return_status OUT NOCOPY VARCHAR2
   , x_dup_sdate OUT NOCOPY DATE
   , x_dup_edate OUT NOCOPY DATE
  ) IS
l_status BOOLEAN := TRUE;
l_rows number := 0;
l_revision boolean := FALSE;
l_effdates boolean := FALSE;
l_blank_text VARCHAR2(2000);
BEGIN

   oe_debug_pub.add('Entering QP_DELAYED_REQUESTS_UTIL.check_duplicate_list_lines');

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_status := QP_VALIDATE_PLL_PRICING_ATTR.Check_Dup_Pra(p_Start_Date_Active,
                                              p_End_Date_Active,
                                              p_Revision,
                                              p_List_Line_ID,
                                              p_List_Header_ID,
                                              l_rows,
                                              l_revision,
                                              l_effdates,
                                              x_dup_sdate,
                                              x_dup_edate);

     IF l_status = FALSE then

	IF l_revision = FALSE then


	   oe_debug_pub.add('Ren: check_duplicate_lines status is false ');

            FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_LIST_LINES');
            oe_msg_pub.Add;

           RAISE FND_API.G_EXC_ERROR;

       ELSIF l_effdates = FALSE then


	   oe_debug_pub.add('Ren: check_duplicate_lines status is false ');

            FND_MESSAGE.SET_NAME('QP', 'QP_BLANK');
            l_blank_text := FND_MESSAGE.get;

            FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_LIST_LINES_DATES');

            IF x_dup_sdate IS NULL THEN
              FND_MESSAGE.SET_TOKEN('STARTDATE', l_blank_text);
            ELSE
              FND_MESSAGE.SET_TOKEN('STARTDATE', x_dup_sdate);
            END IF;

            IF x_dup_edate IS NULL THEN
              FND_MESSAGE.SET_TOKEN('ENDDATE', l_blank_text);
            ELSE
              FND_MESSAGE.SET_TOKEN('ENDDATE', x_dup_edate);
            END IF;

            oe_msg_pub.Add;

          RAISE FND_API.G_EXC_ERROR;

       ELSE

	   oe_debug_pub.add('Ren: check_duplicate_lines status is false ');

            FND_MESSAGE.SET_NAME('QP','QP_DUPLICATE_LIST_LINES');
            oe_msg_pub.Add;

           RAISE FND_API.G_EXC_ERROR;

       END IF;

   END IF;

   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.checkdup');


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
            ,   'check_duplicate_list_lines');
        END IF;

END Check_Duplicate_List_Lines;



--Procedure checks whether a price break line has 1 child  break line.

Procedure Validate_Lines_For_Child
  (x_return_status OUT NOCOPY Varchar2
   ,p_list_line_type_code Varchar2
   ,p_list_line_id IN NUMBER
   )IS

l_status  NUMBER;
l_modifier_grp_type varchar2(30) := 'NOVAL';

NO_CHILD_FOR_PBH_EXCEPTION  EXCEPTION;
NO_CHILD_FOR_OID_EXCEPTION  EXCEPTION;
NO_CHILD_FOR_PRG_EXCEPTION  EXCEPTION;
NO_CHILD_EXCEPTION  EXCEPTION;




Cursor C_pbh_children(p_list_line_id  number
				  ,p_list_line_type_code varchar2
				  ,l_modifier_grp_type varchar2) IS
      SELECT count(1)
      FROM   QP_LIST_LINES qll,
	        QP_RLTD_MODIFIERS qrm
      WHERE  qll.list_line_id = p_list_line_id
	 AND    qll.list_line_id= qrm.from_rltd_modifier_id
      --AND   qrm.rltd_modifier_grp_type = 'PRICE BREAK'
      AND   qrm.rltd_modifier_grp_type = l_modifier_grp_type
      AND   qll.list_line_type_code = p_list_line_type_code;

CURSOR  C_CHECK_FOR_PARENT(p_list_line_id number) IS
	   select 'FOUND' from
	   QP_LIST_LINES
	   WHERE LIST_LINE_ID = P_LIST_LINE_ID;

l_parent varchar2(30);

BEGIN

   oe_debug_pub.add('Entering QP_DELAYED_REQUESTS_UTIL.validate_pbh_line');
   oe_debug_pub.add('passed rule id is'||p_list_line_id);

   --dbms_output.put_line('Entering QP_DELAYED_REQUESTS_UTIL.validate_pbh_line');
   --dbms_output.put_line('passed rule id is'||p_list_line_id);


   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open c_check_for_parent(p_list_line_id);
   fetch c_check_for_parent into l_parent;
   close c_check_for_parent;

   oe_debug_pub.add('check parent for ' ||p_list_line_id);
   oe_debug_pub.add('parent is ' ||l_parent);

  If l_parent = 'FOUND'  then

   IF p_list_line_type_code = 'PBH' THEN

	   l_modifier_grp_type := 'PRICE BREAK';

   ELSIF p_list_line_type_code  IN( 'OID','PRG') THEN

	   l_modifier_grp_type := 'BENEFIT';

   END IF;


   open C_pbh_children(p_list_line_id,
				   p_list_line_type_code,
				   l_modifier_grp_type);
   fetch C_pbh_children into l_status;
   close C_pbh_children;

  --dbms_output.put_line('status is '||l_status);

  IF  l_status <  1 then

	 --Raise MULTIPLE_BREAK_CHILD_EXCEPTION;

      oe_debug_pub.add('status is more than 1');
      --dbms_output.put_line('status is more than 1');
      x_return_status := FND_API.G_RET_STS_ERROR;

	      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	        THEN
	            IF p_list_line_type_code = 'PBH' THEN
	               fnd_message.set_name('QP', 'QP_NO_CHILD_FOR_PBH');
	               --OE_MSG_PUB.Add;
			  ELSIF p_list_line_type_code IN ('OID' ,'PRG') THEN
	               fnd_message.set_name('QP', 'QP_NO_CHILD_FOR_OID_PRG');
	               --OE_MSG_PUB.Add;
                 END IF;
	            OE_MSG_PUB.Add;
	      END IF;
	 RAISE NO_CHILD_EXCEPTION;
	 END IF;

   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.validate pbh');
   --dbms_output.put_line('Exiting QP_DELAYED_REQUESTS_UTIL.validate pbh');
  else

   null;
   oe_debug_pub.add('Exiting no parent found');

  END IF;

EXCEPTION
   WHEN  NO_CHILD_EXCEPTION
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN NO_DATA_FOUND THEN
    NULL;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_Delayed_Requests_Util'
            );
        END IF;

End Validate_Lines_For_Child;

-- This procedure checkes if there are overlapping breaks within
-- the child lines of PBH.

--Changed on APR 07 -svdeshmu



Procedure Check_For_Overlapping_breaks
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_line_id IN NUMBER
   ) IS

--Begin Bug No:	7321885
	l_to_number NUMBER;
	l_count NUMBER;
--End Bug No: 	7321885

OVERLAPPING_BREAKS_EXCEPTION EXCEPTION;
-- mkarya for performance bug 1840060
-- Changed the cursor definition from view qp_price_breaks_v to base tables

--[prarasto] changed the cursor to revert to the validations for
--Non-continuous price breaks
Cursor C_break_lines(p_list_line_id number) IS
      --Begin Bug No: 	7321885
	SELECT PRICING_ATTR_VALUE_FROM_NUMBER,
	       PRICING_ATTR_VALUE_TO_NUMBER
	     FROM QP_RLTD_MODIFIERS QRMA, QP_PRICING_ATTRIBUTES QPBVA
	     WHERE QRMA.FROM_RLTD_MODIFIER_ID = p_list_line_id AND
		   QRMA.TO_RLTD_MODIFIER_ID = QPBVA.LIST_LINE_ID
		   AND QRMA.RLTD_MODIFIER_GRP_TYPE = 'PRICE BREAK'
		   AND QPBVA.PRICING_ATTRIBUTE_DATATYPE = 'N'
		   ORDER BY QPBVA.PRICING_ATTR_VALUE_FROM_NUMBER;
	--End Bug No: 	7321885


BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
--Begin Bug No: 7321885
	l_count := 0;
	l_to_number := 0;
--End Bug No: 7321885


   oe_debug_pub.add('Before overlapping breaks select stmt');

--Begin Bug No: 7321885
	for l_break_lines_rec in C_break_lines(p_list_line_id)
	LOOP
		l_count := l_count + 1;
		if l_break_lines_rec.pricing_attr_value_to_number < l_break_lines_rec.pricing_attr_value_from_number  --changes for value from = value to bug#9210448
		then
			x_return_status := FND_API.G_RET_STS_ERROR;
		end if;
		if (l_count > 1) and ( l_break_lines_rec.pricing_attr_value_from_number <= l_to_number)
		then
			x_return_status := FND_API.G_RET_STS_ERROR;
		end if;
		l_to_number := l_break_lines_rec.pricing_attr_value_to_number;
	END LOOP;
--End Bug No: 	7321885

   oe_debug_pub.add('After overlapping breaks select stmt');
  --dbms_output.put_line('status is '||l_status);

--Begin Bug No: 7321885
  IF  x_return_status =  FND_API.G_RET_STS_ERROR then
--End Bug No: 7321885

	 --Raise OVERLAPPING_BREAKS_EXCEPTION;

     /*  x_return_status := FND_API.G_RET_STS_ERROR; */ --Bug No: 7321885

	      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	        THEN

	            fnd_message.set_name('QP', 'QP_OVERLAP_PRICE_BREAK_RANGE');
	            OE_MSG_PUB.Add;
	      END IF;
	 Raise OVERLAPPING_BREAKS_EXCEPTION;
	 END IF;

   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.overlapping breaks');
   --dbms_output.put_line('Exiting QP_DELAYED_REQUESTS_UTIL.overlapping breaks');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;

    WHEN  OVERLAPPING_BREAKS_EXCEPTION
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   oe_debug_pub.add('overlapping breaks error '||substr(sqlerrm,1,100));
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_Delayed_Requests_Util'
            );
        END IF;
End Check_For_Overlapping_breaks;


-- This procedure validates continuous price breaks.
Procedure Check_Continuous_Price_Breaks
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_line_id IN NUMBER
   ) IS
l_status                VARCHAR2(30) := NULL;
l_break_count           NUMBER       := 0;
l_old_value_from        NUMBER       := NULL;
l_old_value_to          NUMBER       := NULL;

CONTINUOUS_BREAKS_EXCEPTION  EXCEPTION;

Cursor c_break_lines_attr_values(p_list_line_id number) IS
            SELECT  qpa.PRICING_ATTR_VALUE_FROM,
		   qpa.PRICING_ATTR_VALUE_TO
            from qp_list_lines ql, qp_pricing_attributes qpa,qp_rltd_modifiers qrm
            WHERE ql.list_line_id = qpa.list_line_id
	    and ql.list_line_type_code IN ('SUR', 'DIS', 'PLL')
	    and qrm.to_rltd_modifier_id = ql.list_line_id
            and qrm.rltd_modifier_grp_type = 'PRICE BREAK'
            and qrm.from_rltd_modifier_id = p_list_line_id
            order by qp_number.canonical_to_number(qpa.PRICING_ATTR_VALUE_FROM);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   oe_debug_pub.add('Before continuous breaks loop');

   FOR c_break_lines_attr_val_rec in c_break_lines_attr_values(p_list_line_id)
   LOOP

       IF qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_FROM) >=
          qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_TO)
       THEN
          l_status := 'FROM_NOT_LESS_THAN_TO';
	  EXIT;
       END IF;

       IF l_break_count = 0 THEN
          IF qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_FROM) <> 0
	  THEN
	      l_status := 'NON_ZERO_FIRST_VALUE';
	      EXIT;
	  END IF;
       ELSE
          IF qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_FROM) > l_old_value_to
	  THEN
	      l_status := 'GAP';
	      EXIT;
          ELSIF qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_FROM) < l_old_value_to
	  THEN
	      l_status := 'OVERLAP';
	      EXIT;
	  END IF;
       END IF;

       l_old_value_from := qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_FROM);
       l_old_value_to   :=  qp_number.canonical_to_number(c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_TO);


       l_break_count := l_break_count+1;
   END LOOP;
   oe_debug_pub.add('After continuous breaks loop');

   IF l_status IS NOT NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN
          IF l_status = 'FROM_NOT_LESS_THAN_TO' THEN
             fnd_message.set_name('QP', 'QP_INCORRECT_BREAK_VALUES');
          ELSIF l_status = 'NON_ZERO_FIRST_VALUE' THEN
	     fnd_message.set_name('QP', 'QP_NON_ZERO_BREAK_VALUE');
          ELSIF l_status = 'GAP' THEN
             fnd_message.set_name('QP', 'QP_PRICE_BREAKS_GAP');
          ELSIF l_status = 'OVERLAP' THEN
             fnd_message.set_name('QP', 'QP_OVERLAP_PRICE_BREAK_RANGE');
	  END IF;

	  OE_MSG_PUB.Add;
	  Raise CONTINUOUS_BREAKS_EXCEPTION;
      END IF;
   END IF;

   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.Check_Continuous_Price_Breaks');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    NULL;

    WHEN  CONTINUOUS_BREAKS_EXCEPTION
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   oe_debug_pub.add('continuous breaks error '||substr(sqlerrm,1,100));
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_Delayed_Requests_Util'
            );
        END IF;
End Check_Continuous_Price_Breaks;


-- Upgrades non-continuous Price Breaks to continuous Price Breaks
Procedure Upgrade_Price_Breaks
  (  x_return_status OUT NOCOPY Varchar2
   , p_pbh_id IN NUMBER
   , p_list_line_no IN VARCHAR2
   , p_product_attribute IN VARCHAR2
   , p_product_attr_value IN VARCHAR2
   , p_list_type IN VARCHAR2
   , p_start_date_active IN VARCHAR2
   , p_end_date_active IN VARCHAR2)
IS
Cursor c_break_lines_attr_values(p_list_line_id number) IS
            SELECT qpa.PRICING_ATTR_VALUE_FROM_NUMBER,
                   qpa.PRICING_ATTR_VALUE_FROM,
                   qpa.PRICING_ATTR_VALUE_TO_NUMBER,
                   qpa.PRICING_ATTR_VALUE_TO
            from qp_list_lines ql,qp_pricing_attributes qpa,qp_rltd_modifiers qrm
            WHERE ql.list_line_id = qpa.list_line_id
	    and ql.list_line_type_code IN ('SUR', 'DIS', 'PLL')
	    and qrm.to_rltd_modifier_id = ql.list_line_id
            and qrm.rltd_modifier_grp_type = 'PRICE BREAK'
            and qrm.from_rltd_modifier_id = p_list_line_id
            order by 1
        FOR UPDATE OF PRICING_ATTR_VALUE_FROM,PRICING_ATTR_VALUE_FROM_NUMBER;

l_old_value_to             VARCHAR2(240);
l_old_value_to_number      NUMBER;
l_prc_attr_val_from        VARCHAR2(240);
l_prc_attr_val_from_number NUMBER;
l_first_break              BOOLEAN := true;
l_prod_attr_val_disp       VARCHAR2(4000);
UPGRADE_PRICE_BREAKS_EXCEPTION EXCEPTION;

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_prod_attr_val_disp := QP_PRICE_LIST_LINE_UTIL.Get_Product_Value('QP_ATTR_DEFNS_PRICING',
                                                                     'ITEM',
								     p_product_attribute,
								     p_product_attr_value);

   fnd_file.put_line(FND_FILE.LOG,'>>>Upgrading breaks for: ');

   IF p_list_type = 'MODIFIER' THEN
      fnd_file.put_line(FND_FILE.LOG,'Modifier Line No        : '||p_list_line_no);
   END IF;

   fnd_file.put_line(FND_FILE.LOG,'Product Attribute Value : '||l_prod_attr_val_disp);
   fnd_file.put_line(FND_FILE.LOG,'Start Date Active       : '||p_start_date_active);
   fnd_file.put_line(FND_FILE.LOG,'End Date Active         : '||p_end_date_active);
   fnd_file.put_line(FND_FILE.LOG,'                     Old Breaks                    |                     New Breaks');
   fnd_file.put_line(FND_FILE.LOG,rpad(lpad('Value From',20,' '),25,' ')
                           ||'|'||rpad(lpad('Value To',20,' '),25,' ')
			   ||'|'||rpad(lpad('Value From',20,' '),25,' ')
			   ||'|'||rpad(lpad('Value To',20,' '),25,' ')
			   );

   FOR c_break_lines_attr_val_rec in c_break_lines_attr_values(p_pbh_id)
   LOOP
       IF l_first_break THEN
          l_prc_attr_val_from := '0';
          l_prc_attr_val_from_number := 0;
      l_first_break := false;
       ELSE
          l_prc_attr_val_from := l_old_value_to;
          l_prc_attr_val_from_number := l_old_value_to_number;
       END IF;
       l_old_value_to   := c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_TO;
       l_old_value_to_number   := c_break_lines_attr_val_rec.PRICING_ATTR_VALUE_TO_NUMBER;

       fnd_file.put_line(FND_FILE.LOG,rpad(lpad(c_break_lines_attr_val_rec.pricing_attr_value_from,20,' '),25,' ')
                      ||'|'||rpad(lpad(c_break_lines_attr_val_rec.pricing_attr_value_to,20,' '),25,' ')
                      ||'|'||rpad(lpad(l_prc_attr_val_from,20,' '),25,' ')
                      ||'|'||rpad(lpad(c_break_lines_attr_val_rec.pricing_attr_value_to,20,' '),25,' ')
		      );

       BEGIN
          UPDATE qp_pricing_attributes SET
          PRICING_ATTR_VALUE_FROM = l_prc_attr_val_from,
          PRICING_ATTR_VALUE_FROM_NUMBER = l_prc_attr_val_from_number
          WHERE CURRENT OF c_break_lines_attr_values;
       EXCEPTION
          WHEN OTHERS THEN
	     raise UPGRADE_PRICE_BREAKS_EXCEPTION;
       END;
   END LOOP;

   --oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.Upgrade_Price_Breaks');

EXCEPTION

    WHEN UPGRADE_PRICE_BREAKS_EXCEPTION
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   oe_debug_pub.add('upgrade breaks error '||substr(sqlerrm,1,100));
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'QP_Delayed_Requests_Util'
            );
        END IF;

END Upgrade_Price_Breaks;



Procedure Check_Mult_Price_Break_Attrs
  (x_return_status       OUT  NOCOPY VARCHAR2,
   p_parent_list_line_id  IN  NUMBER)
IS

e_mult_price_break_attrs   EXCEPTION;
l_count                        NUMBER := 0;

BEGIN

  select count(DISTINCT pricing_attribute)
  into   l_count
  from   qp_price_breaks_v
  where  parent_list_line_id = p_parent_list_line_id;

oe_debug_pub.add('price break groups '|| to_char(l_count) );
  IF l_count > 1 THEN
    RAISE e_mult_price_break_attrs;
  END IF;

EXCEPTION
    WHEN  e_mult_price_break_attrs THEN

oe_debug_pub.add('In relevant exception ');
      FND_MESSAGE.SET_NAME('QP','QP_MULT_PRICE_BREAK_ATTRS');
      oe_msg_pub.Add;

      x_return_status := FND_API.G_RET_STS_ERROR;

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
            ,   'Check_Mult_Price_Break_Attrs'
            );
        END IF;


END Check_Mult_Price_Break_Attrs;


Procedure Check_Mixed_Qual_Seg_Levels
  (x_return_status       OUT  NOCOPY VARCHAR2,
   p_qualifier_rule_id   IN   NUMBER)
IS

e_mixed_qual_seg_levels  EXCEPTION;
l_qualifier_grouping_no  NUMBER;
l_pte_code               VARCHAR2(30);

CURSOR count_cur(a_qualifier_rule_id NUMBER, a_pte_code VARCHAR2)
IS
  SELECT a.qualifier_grouping_no
  FROM   qp_qualifiers a
  WHERE  a.qualifier_rule_id = a_qualifier_rule_id
  AND    EXISTS (SELECT 'x'
                 FROM   qp_qualifiers b, qp_prc_contexts_b d,
                        qp_segments_b e,  qp_pte_segments f
                 WHERE  b.qualifier_context = d.prc_context_code
                 AND    b.qualifier_attribute = e.segment_mapping_column
                 AND    d.prc_context_id = e.prc_context_id
                 AND    e.segment_id = f.segment_id
                 AND    f.pte_code = a_pte_code
                 AND    f.segment_level = 'LINE'
                 AND    b.qualifier_rule_id = a_qualifier_rule_id
                 AND    (b.qualifier_grouping_no = a.qualifier_grouping_no or
                         b.qualifier_grouping_no = -1))

  AND    EXISTS (SELECT 'x'
                 FROM   qp_qualifiers c, qp_prc_contexts_b d1,
                        qp_segments_b e1,  qp_pte_segments f1
                 WHERE  c.qualifier_context = d1.prc_context_code
                 AND    c.qualifier_attribute = e1.segment_mapping_column
                 AND    d1.prc_context_id = e1.prc_context_id
                 AND    e1.segment_id = f1.segment_id
                 AND    f1.pte_code = a_pte_code
                 AND    f1.segment_level = 'ORDER'
                 AND    c.qualifier_rule_id = a_qualifier_rule_id
                 AND    (c.qualifier_grouping_no = a.qualifier_grouping_no or
                        c.qualifier_grouping_no = -1))

  GROUP BY a.qualifier_grouping_no;

BEGIN
  oe_debug_pub.add('Check_Mixed_Qual_Seg_Levels');
  FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

  if l_pte_code is null then
     l_pte_code := 'ORDFUL';
  end if;

  OPEN  count_cur(p_qualifier_rule_id, l_pte_code);
  FETCH count_cur INTO l_qualifier_grouping_no;

  IF count_cur%FOUND THEN
    CLOSE count_cur;
    RAISE e_mixed_qual_seg_levels;
  END IF;

  CLOSE count_cur;

EXCEPTION
  WHEN  e_mixed_qual_seg_levels THEN

  oe_debug_pub.add('Mixed Segment Levels for Qualifiers Attributes with ' ||
                   'qualifier_rule_id = ' || p_qualifier_rule_id ||
                   'and qualifier_grouping_no = ' || l_qualifier_grouping_no);

    FND_MESSAGE.SET_NAME('QP','QP_MIXED_QUAL_SEG_LEVELS');
    oe_msg_pub.Add;

    x_return_status := FND_API.G_RET_STS_ERROR;

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
        ,   'Check_Mixed_Qual_Seg_Levels'
        );
    END IF;

END Check_Mixed_Qual_Seg_Levels;


Procedure Check_multiple_prl
  (  x_return_status OUT NOCOPY Varchar2
   , p_list_header_id IN NUMBER
   )IS

l_status NUMBER ;

MULTIPLE_PRICE_LIST_EXCEPTION EXCEPTION;

Cursor C_modifier(p_list_header_id number) IS
       SELECT  count(1)
	  FROM    QP_LIST_HEADERS qplh ,
               QP_QUALIFIERS  qpq
       WHERE  qplh.list_header_id = p_list_header_id
       AND    qplh.list_header_id = qpq.list_header_id
       AND    qpq.qualifier_context = 'MODLIST'
       AND    qpq.qualifier_attribute = 'QUALIFIER_ATTRIBUTE4';
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   open C_modifier(p_list_header_id);
   fetch C_modifier into l_status;
   close C_modifier;

       If l_status > 1 Then

    --oe_debug_pub.add('status is duplicate');
    --dbms_output.put_line('status is duplicate');

           x_return_status := FND_API.G_RET_STS_ERROR;

	      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
	        THEN

	            fnd_message.set_name('ONT', 'OE_DIS_DUPLICATE_LIN_DISC');
	            OE_MSG_PUB.Add;
	      END IF;
	 RAISE MULTIPLE_PRICE_LIST_EXCEPTION;
	 END IF;

   oe_debug_pub.add('Exiting QP_DELAYED_REQUESTS_UTIL.checkdup');
   --dbms_output.put_line('Exiting QP_DELAYED_REQUESTS_UTIL.checkdup');

EXCEPTION
   WHEN  MULTIPLE_PRICE_LIST_EXCEPTION
     THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

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
            ,   'QP_Delayed_Requests_Util'
            );
        END IF;

END Check_multiple_prl;

Procedure Maintain_Qualifier_Den_Cols
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_header_id IN NUMBER
  ) IS

l_err_buf         varchar2(30);
l_ret_code        number;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     QP_Maintain_Denormalized_Data.Update_Qualifiers(err_buff => l_err_buf,
										   retcode => l_ret_code,
                                                     p_list_header_id => p_list_header_id,
										   p_update_type => 'DELAYED_REQ');

    IF l_ret_code <> 0 THEN

	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,  'Unexpected error occured in the procedure : QP_Maintain_Denormalized_Data.Update_Qualifiers');
        END IF;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Qualification_Ind');
        END IF;

END Maintain_Qualifier_Den_Cols;


Procedure Maintain_Factor_List_Attrs
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  )
IS
l_list_header_id  NUMBER;

BEGIN

  BEGIN
    SELECT list_header_id
    INTO   l_list_header_id
    FROM   qp_list_lines
    WHERE  list_line_id = p_list_line_id;
  EXCEPTION
    WHEN OTHERS THEN
      l_list_header_id := 0;
  END;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  QP_Denormalized_Pricing_Attrs.Update_Pricing_Attributes(
                                     p_list_header_id_low => l_list_header_id,
                                     p_list_header_id_high => l_list_header_id,
                                     p_update_type => 'FACTOR_DELAYED_REQ');

  QP_Denormalized_Pricing_Attrs.Populate_Factor_List_Attrs(
                                     p_list_header_id_low => l_list_header_id,
                                     p_list_header_id_high => l_list_header_id);

EXCEPTION
   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
       OE_MSG_PUB.Add_Exc_Msg
       (   G_PKG_NAME
       ,   'Maintain_Factor_List_Attrs');
     END IF;

END Maintain_Factor_List_Attrs;


Procedure Update_List_Qualification_Ind
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_header_id IN NUMBER
  ) IS

CURSOR list_lines_cur (a_list_header_id  NUMBER)
IS
  SELECT list_line_id, qualification_ind
  FROM   qp_list_lines
  WHERE  list_header_id = a_list_header_id;

l_dummy           number;
l_list_type_code  varchar2(30);

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     oe_debug_pub.add('list_line_id is NULL');

	BEGIN
       select list_type_code
	  into   l_list_type_code
	  from   qp_list_headers_vl
	  where  list_header_id = p_list_header_id;
	EXCEPTION
       WHEN OTHERS THEN
	    NULL;
	END;

     update qp_list_lines qpl
     set qpl.qualification_ind = 0
     where qpl.list_header_id=p_list_header_id;

     update qp_list_lines qpl
     set qpl.qualification_ind=nvl(qualification_ind,0) + 1
     where qpl.list_header_id=p_list_header_id
     and exists (
        select 'X'
        from qp_rltd_modifiers qprltd
        where qprltd.to_rltd_modifier_id=qpl.list_line_id
        and rltd_modifier_grp_type<>'COUPON');


     IF l_list_type_code IN ('PRL', 'AGR') THEN

        --Check if there exist qualifiers, not including qualifiers
	   --corresponding to primary price list as qualifier for a secondary PL
       -- Replaced the count(*) with exists clause for performance fix of bug 2337578

          Begin
           select 1 into l_dummy from dual where
           exists ( Select 'Y'
           from   qp_qualifiers
           where  list_header_id = p_list_header_id
           and    NOT (qualifier_context = 'MODLIST' AND
                                qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'));
           Exception
           when no_data_found then
           l_dummy :=0;
          End;   --End of bug 2337578


	   IF l_dummy > 0 THEN --Qualifiers exist
           update qp_list_lines qpl
           set qpl.qualification_ind=nvl(qpl.qualification_ind,0) + 2
           where qpl.list_header_id=p_list_header_id;
	   END IF;

     ELSE -- for other list_type_codes

        -- Header level qualifiers
        update qp_list_lines qpl
        set qpl.qualification_ind=nvl(qpl.qualification_ind,0) + 2
        where qpl.list_header_id=p_list_header_id
        and exists (
           select 'X'
           from qp_qualifiers q
           where q.list_header_id=qpl.list_header_id
           and  q.list_line_id = -1);

        -- Line level qualifiers
        update qp_list_lines qpl
        set qpl.qualification_ind=nvl(qpl.qualification_ind,0) + 8
        where qpl.list_header_id=p_list_header_id
        and exists (
           select 'X'
           from qp_qualifiers q
           where q.list_header_id=qpl.list_header_id
           and q.list_line_id=qpl.list_line_id);

     END IF; --If list_type_code is 'PRL or 'AGR'

     -- If Product Attributes exist
     update qp_list_lines qpl
     set qpl.qualification_ind= nvl(qpl.qualification_ind, 0) + 4
     where qpl.list_header_id=p_list_header_id
     and exists (
       select /*+ no_unnest */ 'X'  --5612361
       from qp_pricing_attributes qpprod
       where qpprod.list_line_id = qpl.list_line_id
	  and   qpprod.excluder_flag = 'N');

     -- If Pricing Attributes exist
     update qp_list_lines qpl
     set qpl.qualification_ind= nvl(qpl.qualification_ind, 0) + 16
     where qpl.list_header_id=p_list_header_id
     and exists (
       select 'X'
       from qp_pricing_attributes qpprod
       where qpprod.list_line_id = qpl.list_line_id
          and  qpprod.list_header_id = p_list_header_id --bug#4261111
	  and  qpprod.pricing_attribute_context is not null
	  and  qpprod.pricing_attribute is not null
       -- changes made per rchellam's request --spgopal
	  and  qpprod.pricing_attr_value_from is not null);
/*5612361
	for list_lines_rec IN list_lines_cur(p_list_header_id)
	loop

         update qp_pricing_attributes
	    set    qualification_ind = list_lines_rec.qualification_ind
	    where  list_line_id = list_lines_rec.list_line_id;

	end loop;
*/

--5612361

UPDATE QP_PRICING_ATTRIBUTES A
SET QUALIFICATION_IND = (SELECT  QUALIFICATION_IND
                          FROM  QP_LIST_LINES
                         where A.LIST_LINE_ID = LIST_LINE_ID
                           and LIST_HEADER_ID = p_list_header_id)
WHERE LIST_LINE_ID in
(SELECT /*+ cardinality(QP_LIST_LINES 1) */ LIST_LINE_ID
  FROM QP_LIST_LINES WHERE LIST_HEADER_ID = p_list_header_id);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Qualification_Ind');
        END IF;

END Update_List_Qualification_Ind;

Procedure Update_Limits_Columns
          ( p_Limit_Id                    IN  NUMBER
           ,x_return_status               OUT NOCOPY Varchar2
          )
IS

l_Organization_Count NUMBER := 0;
l_Customer_Attr_Count NUMBER := 0;
l_Product_Attr_Count NUMBER := 0;
l_Limit_Attrs_Count NUMBER := 0;
l_Total_Attr_Count NUMBER := 0;
l_dummy NUMBER := 0;

Phase_Exception Exception;
l_return_status_text VARCHAR2(300);

BEGIN

    SELECT COUNT(*)
    INTO l_Organization_Count
    FROM QP_LIMITS
    WHERE (limit_id = p_Limit_Id) AND
          (UPPER(ORGANIZATION_FLAG) = 'Y');

    SELECT COUNT(*)
    INTO l_Customer_Attr_Count
    FROM QP_LIMITS
    WHERE ((limit_id = p_Limit_Id) AND
          ((MULTIVAL_ATTR1_TYPE IS NOT NULL) OR
          (MULTIVAL_ATTR1_CONTEXT IS NOT NULL) OR
          (MULTIVAL_ATTRIBUTE1 IS NOT NULL) OR
          (MULTIVAL_ATTR1_DATATYPE IS NOT NULL)));

    SELECT COUNT(*)
    INTO l_Product_Attr_Count
    FROM QP_LIMITS
    WHERE ((limit_id = p_Limit_Id) AND
          ((MULTIVAL_ATTR2_TYPE IS NOT NULL) OR
          (MULTIVAL_ATTR2_CONTEXT IS NOT NULL) OR
          (MULTIVAL_ATTRIBUTE2 IS NOT NULL) OR
          (MULTIVAL_ATTR2_DATATYPE IS NOT NULL)));

    SELECT COUNT(*)
    INTO l_Limit_Attrs_Count
    FROM QP_LIMIT_ATTRIBUTES
    WHERE limit_id = p_Limit_Id;

    l_Total_Attr_Count := l_Organization_Count + l_Customer_Attr_Count +
                          l_Product_Attr_Count + l_Limit_Attrs_Count;

     SELECT COUNT(*)
     INTO   l_dummy
     FROM QP_LIMITS
     WHERE limit_id = p_Limit_Id;

     IF l_dummy > 0 -- LIMIT EXISTS
     THEN
         IF (l_Organization_Count > 0) OR (l_Customer_Attr_Count > 0)
             OR (l_Product_Attr_Count > 0)
         THEN
             UPDATE QP_LIMITS
             SET EACH_ATTR_EXISTS = 'Y'
             WHERE limit_id = p_Limit_Id;
         ELSE
             UPDATE QP_LIMITS
             SET EACH_ATTR_EXISTS = 'N'
             WHERE limit_id = p_Limit_Id;
         END IF;

         UPDATE QP_LIMITS
         SET NON_EACH_ATTR_COUNT = l_Limit_Attrs_Count
         WHERE limit_id = p_Limit_Id;

         UPDATE QP_LIMITS
         SET TOTAL_ATTR_COUNT = l_Total_Attr_Count
         WHERE limit_id = p_Limit_Id;
     END IF;

--made the change to call this API to update the basic_modifiers_setup profile
--when a limit gets created so the OM calls old code path
IF QP_CODE_CONTROL.GET_CODE_RELEASE_LEVEL < '110509' THEN
        QP_Maintain_Denormalized_Data.Update_Pricing_Phases
        (p_update_type => 'DELAYED_REQ'
        --,p_pricing_phase_id => p_pricing_phase_id
        -- commenting out as suggested by SPGOPAL
        ,x_return_status => x_return_status
        ,x_return_status_text => l_return_status_text);

        IF x_return_status = FND_API.G_RET_STS_ERROR
        THEN
        oe_debug_pub.add('error update_pricing_phase begin'||l_return_status_text);
                raise Phase_exception;
        END IF;
END IF;

oe_debug_pub.add('end update_pricing_phase begin');

EXCEPTION
WHEN Phase_Exception THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Pricing_Phase');
        END IF;
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Pricing_Phase');
        END IF;
END Update_Limits_Columns;

Procedure Update_Line_Qualification_Ind
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  ) IS

l_qualification_ind  NUMBER;
l_dummy              number;
l_list_type_code     varchar2(30);
l_list_header_id     number;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     oe_debug_pub.add('list_line_id is '||p_list_line_id);

     BEGIN
       select list_type_code, list_header_id
	  into   l_list_type_code, l_list_header_id
	  from   qp_list_headers_vl
	  where  list_header_id = (select list_header_id
						  from   qp_list_lines
						  where  list_line_id = p_list_line_id);
     EXCEPTION
       WHEN OTHERS THEN
	    NULL;
	END;

     update qp_list_lines qpl
     set qpl.qualification_ind = 0
     where qpl.list_line_id=p_list_line_id;

     update qp_list_lines qpl
     set qpl.qualification_ind=nvl(qualification_ind,0) + 1
     where qpl.list_line_id=p_list_line_id
     and exists (
        select 'X'
        from qp_rltd_modifiers qprltd
        where qprltd.to_rltd_modifier_id=p_list_line_id
        and rltd_modifier_grp_type<>'COUPON')
     returning qpl.qualification_ind into l_qualification_ind;

     IF l_list_type_code IN ('PRL', 'AGR') THEN

        --Check if there exist qualifiers, not including qualifiers
	   --corresponding to primary price list as qualifier for a secondary PL

          -- Replaced the count(*) with exists clause for performance fix of bug 2337578

          Begin
           select 1 into l_dummy from dual where
           exists ( Select 'Y'
           from   qp_qualifiers
           where  list_header_id = l_list_header_id
           and    NOT (qualifier_context = 'MODLIST' AND
                                qualifier_attribute = 'QUALIFIER_ATTRIBUTE4'));
           Exception
           when no_data_found then
           l_dummy :=0;
          End;   --End of bug 2337578


	   IF l_dummy > 0 THEN --Qualifiers exist
           update qp_list_lines qpl
           set qpl.qualification_ind=nvl(qpl.qualification_ind,0) + 2
           where qpl.list_line_id=p_list_line_id
		 returning qpl.qualification_ind into l_qualification_ind;
	   END IF;

     ELSE -- for other list_type_codes

        -- Header level qualifiers
        update qp_list_lines qpl
        set qpl.qualification_ind=nvl(qpl.qualification_ind,0) + 2
        where qpl.list_line_id=p_list_line_id
        and exists (
           select 'X'
           from qp_qualifiers q
           where q.list_header_id=qpl.list_header_id
           and q.list_line_id = -1)
        returning qpl.qualification_ind into l_qualification_ind;

        -- Line level qualifiers
        update qp_list_lines qpl
        set qpl.qualification_ind=nvl(qpl.qualification_ind,0) + 8
        where qpl.list_line_id=p_list_line_id
        and exists (
           select 'X'
           from qp_qualifiers q
           where q.list_header_id=qpl.list_header_id
           and q.list_line_id=p_list_line_id)
        returning qpl.qualification_ind into l_qualification_ind;

     END IF; --If list_type_code is 'PRL or 'AGR'

     -- If Product Attributes exist
     update qp_list_lines qpl
     set qpl.qualification_ind= nvl(qpl.qualification_ind, 0) + 4
     where qpl.list_line_id=p_list_line_id
     and exists (
       select 'X'
       from qp_pricing_attributes qpprod
       where qpprod.list_line_id = p_list_line_id
	  and   qpprod.excluder_flag = 'N')
     returning qpl.qualification_ind into l_qualification_ind;

     -- If Pricing Attributes exist
     update qp_list_lines qpl
     set qpl.qualification_ind= nvl(qpl.qualification_ind, 0) + 16
     where qpl.list_line_id=p_list_line_id
     and exists (
       select 'X'
       from qp_pricing_attributes qpprod
       where qpprod.list_line_id = p_list_line_id
	  and   qpprod.pricing_attribute_context is not null
	  and   qpprod.pricing_attribute is not null
       -- changes made per rchellam's request --spgopal
	  and   qpprod.pricing_attr_value_from is not null)
     returning qpl.qualification_ind into l_qualification_ind;

     update qp_pricing_attributes pra
	set    pra.qualification_ind = l_qualification_ind
	where  pra.list_line_id = p_list_line_id;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Qualification_Ind');
        END IF;


END Update_Line_Qualification_Ind;


Procedure Update_Child_Break_Lines
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  ) IS
   l_price_break_type varchar2(30);
   l_pricing_phase_id number;
   l_arithmetic_operator varchar2(30); -- 4936019

CURSOR pbh_details_csr is
SELECT
     a.modifier_level_code
     ,a.automatic_flag
     ,a.override_flag
     ,a.Print_on_invoice_flag
     ,a.price_break_type_code
,a.arithmetic_operator -- 4936019
     ,a.Proration_type_code
     ,a.Incompatibility_Grp_code
     ,a.Pricing_phase_id
     ,a.Pricing_group_sequence
     ,a.accrual_flag
     ,a.estim_accrual_rate
     ,a.expiration_date
     ,a.expiration_period_start_date
     ,a.expiration_period_uom
     ,a.number_expiration_periods
     ,a.rebate_transaction_type_code
FROM qp_list_lines a
WHERE a.list_line_id = p_list_line_id;

BEGIN

  --   l_price_break_type := p_price_break_type;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     oe_debug_pub.add('list_line_id is '||p_list_line_id);

     select price_break_type_code,pricing_phase_id, arithmetic_operator -- 4936019
     into l_price_break_type,l_pricing_phase_id, l_arithmetic_operator -- 4936019
     from qp_list_lines
     where list_line_id = p_list_line_id;

   IF (l_pricing_phase_id = 1) THEN
     update qp_list_lines qpl
     set qpl.price_break_type_code = l_price_break_type
     where qpl.list_line_id in ( select to_rltd_modifier_id
                                 from qp_rltd_modifiers
                               where from_rltd_modifier_id = p_list_line_id );
		 IF (l_arithmetic_operator = 'UNIT_PRICE') THEN
	 	update qp_list_lines qpl
     		set qpl.arithmetic_operator = 'UNIT_PRICE'
     		where qpl.list_line_id in ( select to_rltd_modifier_id
                                 from qp_rltd_modifiers
                               where from_rltd_modifier_id = p_list_line_id )
		and qpl.arithmetic_operator <> 'UNIT_PRICE';
	 END IF;

	 IF (l_arithmetic_operator = 'BLOCK_PRICE' and l_price_break_type = 'POINT') THEN
	 	update qp_list_lines qpl
     		set qpl.arithmetic_operator = 'BLOCK_PRICE'
     		where qpl.list_line_id in ( select to_rltd_modifier_id
                                 from qp_rltd_modifiers
                               where from_rltd_modifier_id = p_list_line_id )
		and qpl.arithmetic_operator <> 'BLOCK_PRICE';
	 END IF;

	 IF (l_arithmetic_operator = 'BLOCK_PRICE' and l_price_break_type = 'RANGE') THEN
	 	update qp_list_lines qpl
     		set qpl.arithmetic_operator = 'BLOCK_PRICE'
     		where qpl.list_line_id in ( select to_rltd_modifier_id
                                 from qp_rltd_modifiers
                               where from_rltd_modifier_id = p_list_line_id )
		and qpl.arithmetic_operator not in ('BLOCK_PRICE', 'BREAKUNIT_PRICE');
	 END IF;

  ELSE
   FOR i in pbh_details_csr
   LOOP
    UPDATE qp_list_lines
    SET  modifier_level_code     = i.modifier_level_code
         ,automatic_flag         = i.automatic_flag
         ,override_flag          = i.override_flag
         ,Print_on_invoice_flag  = i.Print_on_invoice_flag
         ,price_break_type_code  = i.price_break_type_code
         ,Proration_type_code    = i.Proration_type_code
         ,Incompatibility_Grp_code= i.Incompatibility_Grp_code
         ,Pricing_phase_id       = i.Pricing_phase_id
         ,Pricing_group_sequence = i.Pricing_group_sequence
         ,accrual_flag           = i.accrual_flag
         ,rebate_transaction_type_code = i.rebate_transaction_type_code
         ,estim_accrual_rate     = i.estim_accrual_rate
         ,expiration_date        = i.expiration_date
         ,expiration_period_start_date   = i.expiration_period_start_date
         ,expiration_period_uom  = i.expiration_period_uom
         ,number_expiration_periods      = i.number_expiration_periods
    WHERE list_line_id in (select to_rltd_modifier_id
                           from   qp_rltd_modifiers
                           where  from_rltd_modifier_id = p_list_line_id);

   END LOOP;
  END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Child_Break_Lines');
        END IF;


END Update_Child_Break_Lines;


PROCEDURE UPDATE_CHILD_PRICING_ATTR
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER) IS

l_status  NUMBER;
l_list_line_id NUMBER;
l_list_line_type_code VARCHAR2(30);
l_Pricing_Attr_rec QP_PRICING_ATTRIBUTES%rowtype;

Cursor C_pbh_product_details IS
SELECT product_attribute_context,
       product_attribute,
       product_attr_value,
       product_uom_code
FROM   QP_PRICING_ATTRIBUTES
WHERE  list_line_id  = p_list_line_id;



BEGIN

/*	select list_line_type_code
        into l_list_line_type_code
	from qp_list_lines where
	list_line_id = p_list_line_id; */

	--IF l_list_line_type_code = 'PBH' THEN

	--l_modifier_grp_type := 'PRICE BREAK';

	--updating all child break pricing_attributes

   	       FOR i in  C_pbh_product_details
               LOOP

	  	UPDATE qp_Pricing_Attributes SET
		 Product_attribute_context = i.Product_attribute_context
    		,Product_attribute 	   = i.Product_attribute
    		,Product_attr_value 	   = i.Product_attr_value
                ,Product_uom_code          = i.Product_Uom_Code
		WHERE list_line_id IN (select to_rltd_modifier_id
                                       from qp_rltd_modifiers qrm
                                       where from_rltd_modifier_id = p_list_line_id);

               END LOOP;

	--END IF;

EXCEPTION

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Child_Pricing_Attr'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END UPDATE_CHILD_PRICING_ATTR;

/*added by spgopal for including list_header_id and pricing_phase_id in pricing_attributes table for modifiers*/

Procedure Update_Pricing_Attr_Phase
  (     x_return_status OUT NOCOPY Varchar2
	,  p_List_Line_ID IN NUMBER
	   ) IS

l_Pricing_Phase_id	QP_PRICING_PHASES.PRICING_PHASE_ID%TYPE
						:= FND_API.G_MISS_NUM;
l_List_Header_ID	QP_LIST_HEADERS_B.LIST_HEADER_ID%TYPE
						:= FND_API.G_MISS_NUM;

/*
Cursor C_pricing_attr(p_list_line_id number) IS
       SELECT  *
	  FROM    QP_LIST_LINES WHERE  list_line_id = p_list_line_id;
	  */

BEGIN


	IF (p_List_Line_ID IS NOT NULL OR
	    p_List_Line_ID <> FND_API.G_MISS_NUM) THEN

		SELECT LIST_HEADER_ID, PRICING_PHASE_ID INTO
			l_List_Header_ID, l_Pricing_Phase_ID FROM QP_LIST_LINES
			WHERE LIST_LINE_ID = p_List_Line_ID;


--		open c_Pricing_Attr(p_list_line_id); LOOP

		for C_Pricing_Attr in (select pricing_attribute_id
							from qp_pricing_attributes
							where list_line_id = p_list_line_id) LOOP


		Update QP_PRICING_ATTRIBUTES Set
			LIST_HEADER_ID = l_List_Header_ID,
			PRICING_PHASE_ID = l_Pricing_Phase_ID
			where PRICING_ATTRIBUTE_ID = C_Pricing_Attr.Pricing_Attribute_ID;

		END LOOP;

	END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Pricing_Attr_Phase');
        END IF;


END Update_Pricing_Attr_Phase;



/*added by spgopal for updating denormalised info on pricing_phases about line_g
roup, oid and rltd lines for modifiers in that phase*/

Procedure Update_Pricing_Phase
  			(  x_return_status OUT NOCOPY Varchar2
    			,  p_pricing_phase_id IN NUMBER
                        ,  p_automatic_flag  IN Varchar2 --fix for bug 3756625
                        ,  p_count IN NUMBER
		        , p_call_from IN NUMBER
	 			) IS
l_line_type VARCHAR2(30) := 'NONE';
l_level_type VARCHAR2(30) := 'NONE';

l_line VARCHAR2(1) := 'N';
l_rltd VARCHAR2(1) := 'N';
l_level VARCHAR2(1) := 'N';
Phase_Exception Exception;
l_return_status_text VARCHAR2(300);

BEGIN
oe_debug_pub.add('update_pricing_phase begin'||p_pricing_phase_id);--||' '||p_parent_line_id||' '||p_modifier_level_code);

/*
	IF p_list_line_type = 'OID' THEN
		l_line := 'Y';
	ELSIF p_list_line_type = 'RLTD' THEN
		IF p_parent_line_id IS NOT NULL OR
			p_parent_line_id <> FND_API.G_MISS_NUM THEN

			select decode(LL.list_line_type_code, 'PRG','Y','N')
				into l_rltd from qp_list_lines LL
				where LL.list_line_id = p_parent_line_id;

		END IF;
	ELSE NULL;
	END IF;

	IF p_modifier_level_code = 'LINEGROUP' THEN
		l_level := 'Y';
	END IF;

--  oe_debug_pub.add('update_pricing_phase l_line '||l_line||' l_rltd '||l_rltd||' l_level '||l_level);

		update qp_pricing_phases PH set
			PH.oid_exists = decode(l_line,'N',PH.oid_exists,'Y',l_line)
		   , PH.rltd_exists = decode(l_rltd,'N',PH.rltd_exists,'Y',l_rltd)
	    	   , PH.line_group_exists =
			decode(l_level,'N',PH.line_group_exists,'Y',l_level)
			where pricing_phase_id = p_pricing_phase_id;
*/
	QP_Maintain_Denormalized_Data.Update_Pricing_Phases
	(p_update_type => 'DELAYED_REQ'
	,p_pricing_phase_id => p_pricing_phase_id
        ,p_automatic_flag  => p_automatic_flag --fix for bug 3756625
        ,p_count    => p_count
        ,p_call_from => p_call_from
	,x_return_status => x_return_status
	,x_return_status_text => l_return_status_text);

	IF x_return_status = FND_API.G_RET_STS_ERROR
	THEN
	oe_debug_pub.add('error update_pricing_phase begin'||l_return_status_text);
		raise Phase_exception;
	END IF;

oe_debug_pub.add('end update_pricing_phase begin');
EXCEPTION
WHEN Phase_Exception THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Update_Pricing_Phase');
	END IF;

WHEN FND_API.G_EXC_ERROR THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN OTHERS THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Update_Pricing_Phase');
	END IF;
END Update_Pricing_Phase;


--Essilor Fix bug 2789138
Procedure Update_manual_modifier_flag
                        (  x_return_status OUT NOCOPY Varchar2
                        ,  p_automatic_flag IN Varchar2
                        ,  p_pricing_phase_id IN NUMBER
                                ) IS
l_manual_modifier_flag  VARCHAR2(1);
l_set_manual_flag       VARCHAR2(1);
BEGIN

 oe_debug_pub.add('Update manual modifier flag Begin ');
 oe_debug_pub.add('Pricing Phase Id : '||p_pricing_phase_id);
 oe_debug_pub.add('Automatic Flag : '||p_automatic_flag);

 l_set_manual_flag := NULL;
 select manual_modifier_flag into l_manual_modifier_flag
 from qp_pricing_phases
 where pricing_phase_id = p_pricing_phase_id;

 IF nvl(l_manual_modifier_flag, '*') = 'A' then
    IF p_automatic_flag = 'N' then
       l_set_manual_flag := 'B';
    else
       l_set_manual_flag := 'A';
    END IF;
 ELSIF nvl(l_manual_modifier_flag, '*') = 'M' then
    IF p_automatic_flag = 'Y' then
       l_set_manual_flag := 'B';
    else
       l_set_manual_flag := 'M';
    END IF;
 ELSIF l_manual_modifier_flag is NULL then
    IF p_automatic_flag = 'Y' then
       l_set_manual_flag := 'A';
    ELSIF p_automatic_flag = 'N' then
       l_set_manual_flag := 'M';
    END IF;
 END IF;
 if l_set_manual_flag is not NULL then
     update qp_pricing_phases
     set manual_modifier_flag = l_set_manual_flag
     where pricing_phase_id = p_pricing_phase_id;
 end if;

oe_debug_pub.add('Update manual modifier flag End');
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   'Update_Pricing_Phase');
        END IF;
END Update_manual_modifier_flag;


Procedure Validate_Selling_Rounding
  			(  x_return_status OUT NOCOPY Varchar2
    			,  p_currency_header_id IN NUMBER
			,  p_to_currency_code IN VARCHAR2
	 		) IS
-- If the selling_rounding_factor is NULL, then assuming a very high value 9999999 to compare
-- with the not null selling_rounding_factor
 cursor c_selling_rounding is
   select distinct nvl(selling_rounding_factor, 9999999) selling_rounding_factor
     from qp_currency_details
    where currency_header_id = p_currency_header_id
      and to_currency_code = p_to_currency_code;

 l_first_record   varchar2(10);
 l_first_selling_rounding   number;
BEGIN
  oe_debug_pub.add('validate_selling_price begin '||p_currency_header_id||' '||p_to_currency_code);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_first_record := 'TRUE';

  for selling_rounding_rec in c_selling_rounding
  LOOP
  oe_debug_pub.add('IN LOOP selling_rounding_factor = '||selling_rounding_rec.selling_rounding_factor);
     if l_first_record = 'TRUE' then
        l_first_selling_rounding  := selling_rounding_rec.selling_rounding_factor;
        l_first_record := 'FALSE';
     end if;

          oe_debug_pub.add('l_first_selling_rounding = '||l_first_selling_rounding);
     if selling_rounding_rec.selling_rounding_factor <> l_first_selling_rounding then
          oe_debug_pub.add('selling_rounding_factor NOT EQUAL ');

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   fnd_message.set_name('QP', 'QP_SELLING_ROUNDING_NOT_SAME');
	   fnd_message.set_token('CURRENCY_CODE', p_to_currency_code);
	   OE_MSG_PUB.Add;
	END IF;

        raise FND_API.G_EXC_ERROR;
     end if;

  END LOOP;

  oe_debug_pub.add('end validate_selling_rounding ');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Validate_Selling_Rounding');
	END IF;
END Validate_Selling_Rounding;

Procedure Check_Segment_Level_in_Group
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  ,  p_list_header_id IN NUMBER
  ,  p_qualifier_grouping_no IN NUMBER
  )
is
 cursor c_qualifiers is
   select qualifier_context, qualifier_attribute
     from qp_qualifiers
    where list_header_id = p_list_header_id
      and ((qualifier_grouping_no = p_qualifier_grouping_no) OR (qualifier_grouping_no = -1))
      and list_line_id = p_list_line_id;

 l_current_segment_level   VARCHAR2(30) := NULL;

 l_final_segment_level     VARCHAR2(30) := NULL;


BEGIN
  oe_debug_pub.add('Begin Check_Segment_Level_in_Group');
  oe_debug_pub.add('p_list_line_id = ' || p_list_line_id);
  oe_debug_pub.add('p_list_header_id = ' || p_list_header_id);
  oe_debug_pub.add('p_qualifier_grouping_no = ' || p_qualifier_grouping_no);
     FOR l_rec in c_qualifiers
     LOOP
        l_current_segment_level := qp_util.get_segment_level(p_list_header_id
                                                            ,l_rec.qualifier_context
                                                            ,l_rec.qualifier_attribute
                                                            );
        if l_final_segment_level is NULL then
           l_final_segment_level := l_current_segment_level;
        else
           if l_final_segment_level = 'LINE' then
              if l_current_segment_level = 'LINE' then
                 l_final_segment_level := 'LINE';
              elsif l_current_segment_level = 'BOTH' then
                 l_final_segment_level := 'LINE_BOTH';
              elsif l_current_segment_level = 'ORDER' then
	        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   -- There is a mix of 'LINE' and 'ORDER' segment level for list line id ? and
                   -- qualifier grouping no ?. Please make sure that all the segments should be either
                   -- of level LINE/BOTH or ORDER/BOTH for a given list line id and qualifier grouping no
	           fnd_message.set_name('QP', 'QP_MIXED_SEGMENT_LEVELS');
	           fnd_message.set_token('LIST_LINE_ID', p_list_line_id);
	           fnd_message.set_token('QUALIFIER_GRP_NO', p_qualifier_grouping_no);
	           OE_MSG_PUB.Add;
	        END IF;
                raise FND_API.G_EXC_ERROR;
              end if;

           elsif l_final_segment_level = 'ORDER' then
              if l_current_segment_level = 'ORDER' then
                 l_final_segment_level := 'ORDER';
              elsif l_current_segment_level = 'BOTH' then
                 l_final_segment_level := 'ORDER_BOTH';
              elsif l_current_segment_level = 'LINE' then
	        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   -- There is a mix of 'LINE' and 'ORDER' segment level for list line id ? and
                   -- qualifier grouping no ?. Please make sure that all the segments should be either
                   -- of level LINE/BOTH or ORDER/BOTH for a given list line id and qualifier grouping no
	           fnd_message.set_name('QP', 'QP_MIXED_SEGMENT_LEVELS');
	           fnd_message.set_token('LIST_LINE_ID', p_list_line_id);
	           fnd_message.set_token('QUALIFIER_GRP_NO', p_qualifier_grouping_no);
	           OE_MSG_PUB.Add;
	        END IF;
                raise FND_API.G_EXC_ERROR;
              end if;

           elsif l_final_segment_level = 'BOTH' then
              if l_current_segment_level = 'LINE' then
                 l_final_segment_level := 'LINE_BOTH';
              elsif l_current_segment_level = 'ORDER' then
                 l_final_segment_level := 'ORDER_BOTH';
              elsif l_current_segment_level = 'BOTH' then
                 l_final_segment_level := 'BOTH';
              end if;

           elsif l_final_segment_level = 'LINE_BOTH' then
              if l_current_segment_level in ('LINE', 'BOTH') then
                 l_final_segment_level := 'LINE_BOTH';
              elsif l_current_segment_level = 'ORDER' then
	        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   -- There is a mix of 'LINE' and 'ORDER' segment level for list line id ? and
                   -- qualifier grouping no ?. Please make sure that all the segments should be either
                   -- of level LINE/BOTH or ORDER/BOTH for a given list line id and qualifier grouping no
	           fnd_message.set_name('QP', 'QP_MIXED_SEGMENT_LEVELS');
	           fnd_message.set_token('LIST_LINE_ID', p_list_line_id);
	           fnd_message.set_token('QUALIFIER_GRP_NO', p_qualifier_grouping_no);
	           OE_MSG_PUB.Add;
	        END IF;
                raise FND_API.G_EXC_ERROR;
              end if;

           elsif l_final_segment_level = 'ORDER_BOTH' then
              if l_current_segment_level in ('ORDER', 'BOTH') then
                 l_final_segment_level := 'ORDER_BOTH';
              elsif l_current_segment_level = 'LINE' then
	        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   -- There is a mix of 'LINE' and 'ORDER' segment level for list line id ? and
                   -- qualifier grouping no ?. Please make sure that all the segments should be either
                   -- of level LINE/BOTH or ORDER/BOTH for a given list line id and qualifier grouping no
	           fnd_message.set_name('QP', 'QP_MIXED_SEGMENT_LEVELS');
	           fnd_message.set_token('LIST_LINE_ID', p_list_line_id);
	           fnd_message.set_token('QUALIFIER_GRP_NO', p_qualifier_grouping_no);
	           OE_MSG_PUB.Add;
	        END IF;
                raise FND_API.G_EXC_ERROR;
              end if;

           end if; -- l_final_segment_level = 'LINE'
        end if; -- l_final_segment_level is NULL

     END LOOP;

  oe_debug_pub.add('End Check_Segment_Level_in_Group');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Check_Segment_Level_in_Group');
	END IF;
END Check_Segment_Level_in_Group;

Procedure Check_Line_for_Header_Qual
  (  x_return_status OUT NOCOPY Varchar2
  ,  p_list_line_id IN NUMBER
  ,  p_list_header_id IN NUMBER
  )
is
  cursor c_mod_level is
     select distinct modifier_level_code modifier_level
       from qp_list_lines
      where list_header_id = p_list_header_id;

  cursor c_qual_grp_no is
    select distinct qualifier_grouping_no qualifier_grouping_no
      from qp_qualifiers
     where list_header_id = p_list_header_id
       and list_line_id = p_list_line_id
       and qualifier_grouping_no <> -1;

  l_order_modifier_exists VARCHAR2(1) := 'N';
  l_line_modifier_exists VARCHAR2(1) := 'N';

  l_qual_exist_for_line_modifier VARCHAR2(1) := 'N';
  l_qual_exist_for_ord_modifier  VARCHAR2(1) := 'N';

   -- to check whether header qualifier exists with qualifier_grouping_no <> -1
  l_header_qual_exists VARCHAR2(1) := 'N';

  l_segment_level VARCHAR2(30) := NULL;

BEGIN
  oe_debug_pub.add('Begin Check_Line_for_Header_Qual');
  oe_debug_pub.add('p_list_line_id = ' || p_list_line_id);
  oe_debug_pub.add('p_list_header_id = ' || p_list_header_id);
   for l_mod_rec in c_mod_level
   LOOP
      if l_mod_rec.modifier_level = 'ORDER' then
         l_order_modifier_exists := 'Y';
      elsif l_mod_rec.modifier_level in ('LINE', 'LINEGROUP') then
         l_line_modifier_exists := 'Y';
      end if;
   END LOOP;

   if l_line_modifier_exists = 'Y' or l_order_modifier_exists = 'Y' then
     for l_rec in c_qual_grp_no
     LOOP
       l_header_qual_exists := 'Y';
       l_segment_level := QP_Modifier_List_Util.Get_Segment_Level_for_Group(p_list_header_id,
                                                                            p_list_line_id ,
                                                                l_rec.qualifier_grouping_no);
       if ((l_segment_level in ('LINE', 'LINE_BOTH', 'BOTH')) AND l_line_modifier_exists = 'Y') then
          l_qual_exist_for_line_modifier := 'Y';
       end if;

       if ((l_segment_level in ('ORDER', 'ORDER_BOTH', 'BOTH')) AND l_order_modifier_exists = 'Y') then
          l_qual_exist_for_ord_modifier := 'Y';
       end if;
     END LOOP;

     -- if no header qualifiers exist with qualifier_grouping_no <> -1, then check for -1
     if l_header_qual_exists = 'N' then
       l_segment_level := NULL;
       l_segment_level := QP_Modifier_List_Util.Get_Segment_Level_for_Group(p_list_header_id,
                                                                            p_list_line_id ,
                                                                            -1);
       -- if l_segment_level is not null then it means header qualifiers with grouping no -1 exist
       if l_segment_level is not null then
          l_header_qual_exists := 'Y';
          if ((l_segment_level in ('LINE', 'LINE_BOTH', 'BOTH')) AND l_line_modifier_exists = 'Y') then
             l_qual_exist_for_line_modifier := 'Y';
          end if;

          if ((l_segment_level in ('ORDER', 'ORDER_BOTH', 'BOTH')) AND l_order_modifier_exists = 'Y') then
             l_qual_exist_for_ord_modifier := 'Y';
          end if;
       end if; -- l_segment_level is not null
     end if; -- l_header_qual_exists = 'N'

     if l_header_qual_exists = 'Y' then
        if l_line_modifier_exists = 'Y' and l_qual_exist_for_line_modifier = 'N' then
           oe_debug_pub.add('mkarya - Modifier Lines of level ''LINE'' or ''LINEGROUP''
                             will not be applied to an order as no header qualifier exist');
	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      fnd_message.set_name('QP', 'QP_NO_HEADER_QUAL_FOR_LINE');
	      OE_MSG_PUB.Add;
	   END IF;
           --raise FND_API.G_EXC_ERROR;
        end if;

        if l_order_modifier_exists = 'Y' and l_qual_exist_for_ord_modifier = 'N' then
           oe_debug_pub.add('mkarya - Modifier Lines of level ''ORDER'' will not be applied
                             to an order as no header qualifier exist');
	   IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      fnd_message.set_name('QP', 'QP_NO_HEADER_QUAL_FOR_ORD');
	      OE_MSG_PUB.Add;
	   END IF;
           --raise FND_API.G_EXC_ERROR;
        end if;

     end if; -- l_header_qual_exists = 'Y'
   end if; -- l_line_modifier_exists = 'Y' or l_order_modifier_exists = 'Y'

  oe_debug_pub.add('End Check_Line_for_Header_Qual');
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN

	x_return_status := FND_API.G_RET_STS_ERROR;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		OE_MSG_PUB.Add_Exc_Msg
			(   G_PKG_NAME
			,   'Check_Line_for_Header_Qual');
	END IF;
END Check_Line_for_Header_Qual;


--hw
-- update QP_ADV_MOD_PRODUCTS for changed lines

procedure update_changed_lines_add (
    p_list_line_id in number,
	p_list_header_id in number,
	p_pricing_phase_id in number,
	x_return_status out NOCOPY varchar2
) is
begin

oe_debug_pub.add('process update_changed_lines_add');

--please note that this is being done from concurrent program
--QP: Maintain denormalised data in qp_qualifiers also in which
--case the procedure update_changed_lines_product in QPXDENOB.pls
--is called. Any changes made to this routine needs to be
--communicated to DENOB as well.
--also this same operation is done in 3 other procedures in this
--same API so the fixes need to be done there as well. They are:
--update_changed_lines_act,update_changed_lines_del/_add/_ph

	begin

	insert into qp_adv_mod_products (
		product_attribute,
		product_attr_value,
		pricing_phase_id) (
		select distinct qpa.product_attribute,
         			qpa.product_attr_value,
			p_pricing_phase_id
          		from qp_pricing_attributes qpa
			where qpa.list_line_id = p_list_line_id
			and not exists (
					select 'Y' from qp_adv_mod_products
						where pricing_phase_id = p_pricing_phase_id
							and product_attribute = qpa.product_attribute
							and product_attr_value = qpa.product_attr_value));

	exception
		when others then
			x_return_status := FND_API.G_RET_STS_ERROR;
	end;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

end update_changed_lines_add;


procedure update_changed_lines_del (
    p_list_line_id in number,
	p_list_header_id in number,
	p_pricing_phase_id in number,
	p_product_attribute in varchar2,
	p_product_attr_value in varchar2,
	x_return_status out NOCOPY varchar2
) is
begin

oe_debug_pub.add('process update_changed_lines_del');

--please note that this is being done from concurrent program
--QP: Maintain denormalised data in qp_qualifiers also in which
--case the procedure update_changed_lines_product in QPXDENOB.pls
--is called. Any changes made to this routine needs to be
--communicated to DENOB as well.
--also this same operation is done in 3 other procedures in this
--same API so the fixes need to be done there as well. They are:
--update_changed_lines_act,update_changed_lines_del/_add/_ph

	begin

	delete from qp_adv_mod_products
		where pricing_phase_id = p_pricing_phase_id
			and product_attribute = p_product_attribute
			and product_attr_value = p_product_attr_value
			and not exists (
				select 'Y'
					from qp_list_lines qpl,
						qp_list_headers_b qph
					where qpl.list_line_id = p_list_line_id
						and qpl.modifier_level_code = 'LINEGROUP'
						and qph.list_header_id = p_list_header_id
						and qph.active_flag = 'Y'
						and rownum = 1
				union
				select 'Y'
					from qp_rltd_modifiers qpr,
						qp_list_lines qpl,
						qp_list_headers_b qph
					where qpl.list_line_id = p_list_line_id
						and qpr.to_rltd_modifier_id = p_list_line_id
						and qpr.rltd_modifier_grp_type = 'BENEFIT'
						and qpl.list_line_type_code = 'DIS'
						and qph.list_header_id = p_list_header_id
						and qph.active_flag = 'Y'
						and qpr.to_rltd_modifier_id = qpl.list_line_id
						and qph.list_header_id = qpl.list_header_id
						and rownum = 1
				union
				select 'Y'
					from qp_list_lines qpl,
						qp_list_headers_b qph
					where qpl.list_line_id = p_list_line_id
						and qpl.list_line_type_code in ('OID', 'PRG', 'RLTD')
						and qph.list_header_id = p_list_header_id
						and qph.active_flag = 'Y'
						and rownum = 1);

	exception
		when others then
			x_return_status := FND_API.G_RET_STS_ERROR;
	end;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

end update_changed_lines_del;

procedure update_changed_lines_ph (
    p_list_line_id in number,
	p_list_header_id in number,
	p_pricing_phase_id in number,
	p_old_pricing_phase_id in number,
	x_return_status out NOCOPY varchar2
) is
	l_product_attribute			varchar2(30);
	l_product_attr_value		varchar2(240);
	l_pricing_phase_id			number;
begin

	oe_debug_pub.add('process update_changed_lines_ph');

--please note that this is being done from concurrent program
--QP: Maintain denormalised data in qp_qualifiers also in which
--case the procedure update_changed_lines_product in QPXDENOB.pls
--is called. Any changes made to this routine needs to be
--communicated to DENOB as well.
--also this same operation is done in 3 other procedures in this
--same API so the fixes need to be done there as well. They are:
--update_changed_lines_act,update_changed_lines_del/_add/_ph
	begin

		-- process new phase id
		insert into qp_adv_mod_products (
			product_attribute,
			product_attr_value,
			pricing_phase_id) (
			select distinct qpa.product_attribute,
          		qpa.product_attr_value,
				p_pricing_phase_id
           		from qp_pricing_attributes qpa
				where qpa.list_line_id = p_list_line_id
					and not exists (
						select 'Y' from qp_adv_mod_products
							where pricing_phase_id = p_pricing_phase_id
								and product_attribute = qpa.product_attribute
								and product_attr_value = qpa.product_attr_value));

		-- process old phase id
		select distinct product_attribute,
         	product_attr_value,
			p_pricing_phase_id
			into l_product_attribute,
				l_product_attr_value,
				l_pricing_phase_id
          	from qp_pricing_attributes
			where list_line_id = p_list_line_id;

		--tuned SQl to avoid cartesian join
		delete from qp_adv_mod_products
			where pricing_phase_id = p_old_pricing_phase_id
				and product_attribute = l_product_attribute
				and product_attr_value = l_product_attr_value
				and not exists (
                    select 'Y'
                    from qp_pricing_attributes qpa,
                        qp_list_lines qpl,
                        qp_list_headers_b qph
                    where qpa.pricing_phase_id = p_old_pricing_phase_id
                    and qpa.product_attribute = l_product_attribute
                    and qpa.product_attr_value = l_product_attr_value
                    and qpl.list_line_id = qpa.list_line_id
                    and qpl.modifier_level_code = 'LINEGROUP'
                    and qph.list_header_id = qpa.list_header_id
                    and qph.active_flag = 'Y'
                    and rownum = 1
            		union
                    select 'Y'
                    from qp_rltd_modifiers qpr,
                        qp_list_lines qpl,
                        qp_pricing_attributes qpa,
                        qp_list_headers_b qph
                    where qpa.pricing_phase_id = p_old_pricing_phase_id
                    and qpa.product_attribute = l_product_attribute
                    and qpa.product_attr_value = l_product_attr_value
                    and qpl.list_line_id = qpa.list_line_id
                    and qpr.rltd_modifier_grp_type = 'BENEFIT'
                    and qpr.to_rltd_modifier_id = qpl.list_line_id
                    and qpl.list_line_type_code = 'DIS'
                    and qph.list_header_id = qpa.list_header_id
                    and qph.active_flag = 'Y'
                    and rownum = 1
            		union
                    select 'Y'
                    from qp_list_lines qpl,
                        qp_pricing_attributes qpa,
                        qp_list_headers_b qph
                    where qpa.pricing_phase_id = p_old_pricing_phase_id
                    and qpa.product_attribute = l_product_attribute
                    and qpa.product_attr_value = l_product_attr_value
                    and qpl.list_line_type_code in ('OID', 'PRG', 'RLTD')
                    and qpl.list_line_id = qpa.list_line_id
                    and qph.list_header_id = qpl.list_header_id--p_list_header_id
                    and qph.active_flag = 'Y'
                    and rownum = 1);

	exception
		when others then
			x_return_status := FND_API.G_RET_STS_ERROR;
	end;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

end update_changed_lines_ph;

procedure update_changed_lines_act (
	p_list_header_id in number,
	p_active_flag varchar2,
	x_return_status out NOCOPY varchar2
) is
	l_product_attribute			varchar2(30);
	l_product_attr_value		varchar2(240);

	cursor l_get_line_csr is
		select distinct qpl.list_line_id,
			qpl.pricing_phase_id,
			qpa.product_attribute,
			qpa.product_attr_value
			from qp_list_lines qpl,
				qp_pricing_attributes qpa
			where qpl.list_header_id = p_list_header_id
				and qpa.list_line_id = qpl.list_line_id;

begin

	oe_debug_pub.add('process update_changed_lines_act');
--please note that this is being done from concurrent program
--QP: Maintain denormalised data in qp_qualifiers also in which
--case the procedure update_changed_lines_product in QPXDENOB.pls
--is called. Any changes made to this routine needs to be
--communicated to DENOB as well.
--also this same operation is done in 3 other procedures in this
--same API so the fixes need to be done there as well. They are:
--update_changed_lines_act,update_changed_lines_del/_add/_ph

	begin

		if p_active_flag = 'Y' then

		for line_cursor in l_get_line_csr loop

			insert into qp_adv_mod_products (
				pricing_phase_id,
				product_attribute,
				product_attr_value
				) (
				select line_cursor.pricing_phase_id,
					line_cursor.product_attribute,
					line_cursor.product_attr_value
					from dual
					where not exists (
						select 'Y' from qp_adv_mod_products
							where pricing_phase_id = line_cursor.pricing_phase_id
								and	product_attribute = line_cursor.product_attribute
								and	product_attr_value = line_cursor.product_attr_value));

		end loop;

		else

		for line_cursor in l_get_line_csr loop

		--tuned SQl to avoid cartesian join
		delete from qp_adv_mod_products
			where pricing_phase_id = line_cursor.pricing_phase_id
				and product_attribute = line_cursor.product_attribute
				and product_attr_value = line_cursor.product_attr_value
				and not exists (
                    select 'Y'
                    from qp_pricing_attributes qpa,
                        qp_list_lines qpl,
                        qp_list_headers_b qph
                    where qpa.pricing_phase_id = line_cursor.pricing_phase_id
                    and qpa.product_attribute = line_cursor.product_attribute
                    and qpa.product_attr_value = line_cursor.product_attr_value
                    and qpl.list_line_id = qpa.list_line_id
                    and qpl.modifier_level_code = 'LINEGROUP'
                    and qph.list_header_id = qpa.list_header_id
                    and qph.active_flag = 'Y'
                    and rownum = 1
            		union
                    select 'Y'
                    from qp_rltd_modifiers qpr,
                        qp_list_lines qpl,
                        qp_pricing_attributes qpa,
                        qp_list_headers_b qph
                    where qpa.pricing_phase_id = line_cursor.pricing_phase_id
                    and qpa.product_attribute = line_cursor.product_attribute
                    and qpa.product_attr_value = line_cursor.product_attr_value
                    and qpl.list_line_id = qpa.list_line_id
                    and qpr.rltd_modifier_grp_type = 'BENEFIT'
                    and qpr.to_rltd_modifier_id = qpl.list_line_id
                    and qpl.list_line_type_code = 'DIS'
                    and qph.list_header_id = qpa.list_header_id
                    and qph.active_flag = 'Y'
                    and rownum = 1
            		union
                    select 'Y'
                    from qp_list_lines qpl,
                        qp_pricing_attributes qpa,
                        qp_list_headers_b qph
                    where qpa.pricing_phase_id = line_cursor.pricing_phase_id
                    and qpa.product_attribute = line_cursor.product_attribute
                    and qpa.product_attr_value = line_cursor.product_attr_value
                    and qpl.list_line_type_code in ('OID', 'PRG', 'RLTD')
                    and qpl.list_line_id = qpa.list_line_id
                    and qph.list_header_id = qpl.list_header_id
                    and qph.active_flag = 'Y'
                    and rownum = 1);
			end loop;

		end if;

	exception
		when others then
			x_return_status := FND_API.G_RET_STS_ERROR;
	end;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

end update_changed_lines_act;

Procedure HVOP_Pricing_Setup (x_return_status OUT NOCOPY VARCHAR2) IS

l_return_status_text VARCHAR2(200);
procedure_error Exception;
BEGIN

QP_Maintain_Denormalized_Data.Set_HVOP_Pricing (x_return_status, l_return_status_text);
IF(x_return_status=FND_API.G_RET_STS_ERROR) THEN
raise procedure_error;
END IF;

EXCEPTION
	WHEN procedure_error THEN
	OE_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME
	,   'Error while executing the process QP_Maintain_Denormalized_Data.Set_HVOP_Pricing : '|| l_return_status_text);

	WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	OE_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME
		,   l_return_status_text);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	OE_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME
		,   l_return_status_text);

	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	OE_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME
		,   l_return_status_text);
END HVOP_Pricing_Setup;

-- pattern
Procedure Maintain_header_pattern(p_list_header_id in number,
				p_qualifier_group in number,
				p_setup_action in varchar2,
				x_return_status out NOCOPY varchar2)
IS
BEGIN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
	QP_PS_ATTR_GRP_PVT.Header_Pattern_Main(
			p_list_header_id => p_list_header_id,
			p_qualifier_group => p_qualifier_group,
			p_setup_action => p_setup_action);
			oe_debug_pub.add('calling new jagan ' || p_list_header_id);
	ELSE
	QP_ATTR_GRP_PVT.Header_Pattern_Main(
			p_list_header_id => p_list_header_id,
			p_qualifier_group => p_qualifier_group,
			p_setup_action => p_setup_action);
			oe_debug_pub.add('calling old jagan ' || p_list_header_id);
	END IF;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Maintain_header_pattern;

Procedure Maintain_line_pattern(p_list_header_id in number,
				p_list_line_id in number,
				p_qualifier_group in number,
				p_setup_action in varchar2,
				x_return_status out NOCOPY varchar2)
IS
BEGIN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
	QP_PS_ATTR_GRP_PVT.Line_Pattern_Main(
			p_list_header_id => p_list_header_id,
			p_list_line_id => p_list_line_id,
			p_qualifier_group => p_qualifier_group,
			p_setup_action => p_setup_action);
	ELSE
	QP_ATTR_GRP_PVT.Line_Pattern_Main(
			p_list_header_id => p_list_header_id,
			p_list_line_id => p_list_line_id,
			p_qualifier_group => p_qualifier_group,
			p_setup_action => p_setup_action);
	END IF;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Maintain_line_pattern;

Procedure Maintain_product_pattern(p_list_header_id in number,
				p_list_line_id in number,
				p_setup_action in varchar2,
				x_return_status out NOCOPY varchar2)
IS
BEGIN
        IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'M' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'P' OR FND_PROFILE.VALUE('QP_PATTERN_SEARCH') = 'B' THEN
	QP_PS_ATTR_GRP_PVT.Product_Pattern_Main(
			p_list_header_id => p_list_header_id,
			p_list_line_id => p_list_line_id,
			p_setup_action => p_setup_action);
	ELSE
	QP_ATTR_GRP_PVT.Product_Pattern_Main(
			p_list_header_id => p_list_header_id,
			p_list_line_id => p_list_line_id,
			p_setup_action => p_setup_action);
	END IF;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Maintain_product_pattern;

-- pattern

-- Hierarchical Categories (sfiresto)
PROCEDURE Check_Enabled_Func_Areas(p_pte_source_system_id IN NUMBER,
                                   x_return_status OUT NOCOPY VARCHAR2)
IS
l_exists   VARCHAR2(1);
l_pte_code VARCHAR2(30);
l_ss_code  VARCHAR2(30);
BEGIN

  -- Check to see if any enabled functional area mappings exist for
  -- the given PTE/SS combination

  SELECT 'x'
  INTO l_exists
  FROM qp_sourcesystem_fnarea_map
  WHERE pte_source_system_id = p_pte_source_system_id
    AND enabled_flag = 'Y'
    AND rownum = 1;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

    -- If no data was found, we add a warning message to the stack.
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN

      select pte_code, application_short_name
      into l_pte_code, l_ss_code
      from qp_pte_source_systems
      where pte_source_system_id = p_pte_source_system_id;

      FND_MESSAGE.set_name('QP', 'QP_NO_FUNC_AREA_WITHIN_PTE');
      FND_MESSAGE.set_token('PTE', l_pte_code);
      FND_MESSAGE.set_token('SS', l_ss_code);
      OE_MSG_PUB.Add;
    END IF;


    -- As this is a WARNING message, we still return success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Check_Enabled_Func_Areas;

END QP_Delayed_Requests_UTIL;

/
