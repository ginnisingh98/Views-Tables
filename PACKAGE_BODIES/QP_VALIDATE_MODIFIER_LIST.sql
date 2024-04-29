--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_MODIFIER_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_MODIFIER_LIST" AS
/* $Header: QPXLMLHB.pls 120.8 2006/09/04 06:54:08 rbagri ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Modifier_List';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_currency_code               VARCHAR2(15);
l_qp_status                   VARCHAR2(1);
l_security_profile            VARCHAR2(1);
BEGIN


    oe_debug_pub.add('BEGIN entity in QPXLMLHB');

    -- Check whether Source System Code matches
    -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
    QP_UTIL.Check_Source_System_Code
                            (p_list_header_id => p_MODIFIER_LIST_rec.list_header_id,
                             p_list_line_id   => NULL,
                             x_return_status  => l_return_status
                            );

    --  Check required attributes.

    IF  p_MODIFIER_LIST_rec.list_header_id IS NULL
    THEN

    oe_debug_pub.add('list header id is mandatory');
        l_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Header Id');
            OE_MSG_PUB.Add;

        END IF;

    END IF;

    --
    --  Check rest of required attributes here.
    --

    IF p_MODIFIER_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    THEN

       IF  p_old_MODIFIER_LIST_rec.list_type_code IS NOT NULL
       AND p_old_MODIFIER_LIST_rec.list_type_code <> FND_API.G_MISS_CHAR
       AND p_old_MODIFIER_LIST_rec.list_type_code <> p_MODIFIER_LIST_rec.list_type_code
	  THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_LIST_TYPE');
        OE_MSG_PUB.Add;

       END IF;

       IF   nvl(p_old_MODIFIER_LIST_rec.list_source_code,'X') <>
nvl(p_MODIFIER_LIST_rec.list_source_code,'X')
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','List Source Code');
        OE_MSG_PUB.Add;

       END IF;


       IF  nvl(p_old_MODIFIER_LIST_rec.shareable_flag,'X') <>
nvl(p_MODIFIER_LIST_rec.shareable_flag,'X')
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Shareable Flag');
        OE_MSG_PUB.Add;

       END IF;

      IF  p_old_MODIFIER_LIST_rec.list_type_code NOT IN ('DEL')
       AND nvl(p_old_MODIFIER_LIST_rec.parent_list_header_id,0) <>
nvl(p_MODIFIER_LIST_rec.parent_list_header_id,0)
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Parent List Header Id');
        OE_MSG_PUB.Add;

       END IF;

	IF  nvl(p_old_MODIFIER_LIST_rec.source_system_code,'X') <>
nvl(p_MODIFIER_LIST_rec.source_system_code,'X')
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Source System Code');
        OE_MSG_PUB.Add;

       END IF;

	IF  nvl(p_old_MODIFIER_LIST_rec.pte_code,'X') <>
nvl(p_MODIFIER_LIST_rec.pte_code,'X')
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Pricing Transaction Entity Code');
        OE_MSG_PUB.Add;

       END IF;

/*	IF  nvl(p_old_MODIFIER_LIST_rec.ask_for_flag,'X') <>
nvl(p_MODIFIER_LIST_rec.ask_for_flag,'X')
          THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Ask For Flag');
        OE_MSG_PUB.Add;

       END IF; Bug 5503831 */

/*   Commented for bug2516658

       IF  p_old_MODIFIER_LIST_rec.name IS NOT NULL
       AND p_old_MODIFIER_LIST_rec.name <> FND_API.G_MISS_CHAR
       AND p_old_MODIFIER_LIST_rec.name <> p_MODIFIER_LIST_rec.name
	  THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_NUMBER');
        OE_MSG_PUB.Add;

       END IF;

       IF  p_old_MODIFIER_LIST_rec.description IS NOT NULL
       AND p_old_MODIFIER_LIST_rec.description <> FND_API.G_MISS_CHAR
       AND p_old_MODIFIER_LIST_rec.description <> p_MODIFIER_LIST_rec.description
	  THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_NAME');
        OE_MSG_PUB.Add;

       END IF;
*/
   END IF;


  IF  p_MODIFIER_LIST_rec.gsa_indicator IS NULL
  THEN

    l_qp_status := QP_UTIL.GET_QP_STATUS;

     IF  p_MODIFIER_LIST_rec.list_type_code IS NULL
     THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        oe_debug_pub.add('list type code is mandatory');
        FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('LIST_TYPE_CODE'));  -- Fix For Bug-1974413
        OE_MSG_PUB.Add;

     END IF;

	IF     ( l_qp_status = 'I' AND
	         p_MODIFIER_LIST_rec.list_type_code <> 'PRO' AND
              p_MODIFIER_LIST_rec.list_type_code <> 'DEL' AND
              p_MODIFIER_LIST_rec.list_type_code <> 'DLT' AND
              p_MODIFIER_LIST_rec.list_type_code <> 'PML' AND
              p_MODIFIER_LIST_rec.list_type_code <> 'CHARGES' AND
              p_MODIFIER_LIST_rec.list_type_code <> 'SLT' )
     THEN

        oe_debug_pub.add('invalid list type code ');
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_TYPE');
        OE_MSG_PUB.Add;

     END IF;
-- For bug 2363065, raise the error in basic pricing if not called from FTE
	IF  p_MODIFIER_LIST_rec.list_type_code <> 'PML' THEN
	  IF     ( l_qp_status = 'S' AND
                QP_MOD_LOADER_PUB.G_PROCESS_LST_REQ_TYPE <> 'FTE' AND
                p_MODIFIER_LIST_rec.list_type_code <> 'DLT' AND
                p_MODIFIER_LIST_rec.list_type_code <> 'CHARGES' AND
                p_MODIFIER_LIST_rec.list_type_code <> 'SLT' )
       THEN

          oe_debug_pub.add('invalid list type code ');
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_TYPE');
          OE_MSG_PUB.Add;

       END IF;
     END IF;

  END IF;

  IF  p_MODIFIER_LIST_rec.list_type_code <> 'PML' THEN

    IF  p_MODIFIER_LIST_rec.gsa_indicator = 'Y'
    AND p_MODIFIER_LIST_rec.list_type_code <> 'DLT'
    THEN
          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_TYPE');
          OE_MSG_PUB.Add;


    END IF;

    IF  p_MODIFIER_LIST_rec.source_system_code IS NULL
    THEN

          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('SOURCE_SYSTEM_CODE'));  -- Fix For Bug-1974413
          OE_MSG_PUB.Add;

    END IF;

   -- Bug 2351145 - pte_code is mandatory only when attribute manager is installed
   IF qp_util.attrmgr_installed = 'Y' then
    IF  p_MODIFIER_LIST_rec.pte_code IS NULL
    THEN

          l_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          FND_MESSAGE.SET_TOKEN('ATTRIBUTE', 'PTE_CODE');
          OE_MSG_PUB.Add;

    END IF;
   END IF;

  END IF;

  IF  p_MODIFIER_LIST_rec.list_type_code <> 'PML' THEN

       IF  p_MODIFIER_LIST_rec.currency_code IS NULL
       THEN
         If QP_Code_Control.Get_Code_Release_Level >  '110509'
	 Then
	 	l_currency_code := NULL;
	 Else
          	oe_debug_pub.add('currency code is null ');
	        l_return_status := FND_API.G_RET_STS_ERROR;
          	FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
          	FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('CURRENCY_CODE'));   -- Fix For Bug-1974413
          	OE_MSG_PUB.Add;
	End If;
       ELSE

     	BEGIN

	     select currency_code
		into   l_currency_code
		from   fnd_currencies_vl
		where  enabled_flag = 'Y'
		and    currency_flag = 'Y'
		and    currency_code = p_MODIFIER_LIST_rec.currency_code;
/*		and    trunc(sysdate) between nvl(start_date_active,trunc(sysdate))
		and    nvl(end_date_active,trunc(sysdate));
		*/

    	  EXCEPTION

	   WHEN NO_DATA_FOUND THEN
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_INVALID_CURRENCY');
        OE_MSG_PUB.Add;

       END;

     END IF;
   END IF;

      IF  nvl( p_MODIFIER_LIST_rec.start_date_active,to_date('01/01/1951','mm/dd/yyyy')) >
          nvl( p_MODIFIER_LIST_rec.end_date_active,to_date('12/31/9999','mm/dd/yyyy'))
      THEN

        oe_debug_pub.add('start date after end date');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
        OE_MSG_PUB.Add;

      END IF;

      IF  nvl( p_MODIFIER_LIST_rec.start_date_active_first,to_date('01/01/1951','mm/dd/yyyy')) >
          nvl( p_MODIFIER_LIST_rec.end_date_active_first,to_date('12/31/9999','mm/dd/yyyy'))
      THEN

        oe_debug_pub.add('start date after end date');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
        OE_MSG_PUB.Add;

      END IF;

      IF  nvl( p_MODIFIER_LIST_rec.start_date_active_second,to_date('01/01/1951','mm/dd/yyyy')) >
          nvl( p_MODIFIER_LIST_rec.end_date_active_second,to_date('12/31/9999','mm/dd/yyyy'))
      THEN

        oe_debug_pub.add('start date after end date');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_STRT_DATE_BFR_END_DATE');
        OE_MSG_PUB.Add;

      END IF;

     oe_debug_pub.add('list type code = '||p_MODIFIER_LIST_rec.list_type_code);
     oe_debug_pub.add('parent list header id = '||
	to_char(p_MODIFIER_LIST_rec.parent_list_header_id));

	IF  p_MODIFIER_LIST_rec.list_type_code = 'DEL'
     AND  p_MODIFIER_LIST_rec.parent_list_header_id IS NULL
	THEN

        oe_debug_pub.add('id deal, list header id is null');
        l_return_status := FND_API.G_RET_STS_ERROR;

        FND_MESSAGE.SET_NAME('QP','QP_PARENT_REQUIRED');
        OE_MSG_PUB.Add;

     END IF;

     IF  p_MODIFIER_LIST_rec.list_type_code <> 'PML' THEN
       IF  p_MODIFIER_LIST_rec.list_type_code <> 'CHARGES'
	  THEN
         IF  p_MODIFIER_LIST_rec.description IS NULL
	    THEN

           oe_debug_pub.add('name is null');
           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
           FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('NAME'));   -- Fix For Bug-1974413
           OE_MSG_PUB.Add;

         END IF;
       END IF;

       IF  p_MODIFIER_LIST_rec.active_date_first_type IS NOT NULL
	  AND p_MODIFIER_LIST_rec.active_date_second_type IS NOT NULL
	  THEN
         IF  p_MODIFIER_LIST_rec.active_date_first_type =
	        p_MODIFIER_LIST_rec.active_date_second_type
	    THEN

           oe_debug_pub.add('name is null');
           l_return_status := FND_API.G_RET_STS_ERROR;

           FND_MESSAGE.SET_NAME('QP','QP_DATE_TYPES_MUST_DIFFER');
           OE_MSG_PUB.Add;

         END IF;
       END IF;
     END IF;  --list_type_code is not 'PML'

  -- added for MOAC
  IF ( p_MODIFIER_LIST_rec.global_flag IS NOT NULL
	  and p_MODIFIER_LIST_rec.global_flag <> FND_API.G_MISS_CHAR ) THEN

     IF p_MODIFIER_LIST_rec.global_flag not in ('Y', 'N', 'n') THEN

	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN

		FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','Global_flag');
		oe_msg_pub.add;
         END IF;
     END IF;
  END IF;

    --added for MOAC
    l_security_profile := QP_SECURITY.security_on;

    IF ( p_MODIFIER_LIST_rec.global_flag IS NOT NULL)
    THEN

                --if security is OFF, global_flag cannot be 'N'
                IF (l_security_profile = 'N'
                and p_MODIFIER_LIST_rec.global_flag in ('N', 'n')) THEN
	          l_return_status := FND_API.G_RET_STS_ERROR;
	          IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
		    FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','global_flag');
		    oe_msg_pub.add;
                  END IF;
        	END IF;

                IF l_security_profile = 'Y' THEN
                  --if security is ON and global_flag is 'N', org_id cannot be null
                  IF  (p_MODIFIER_LIST_rec.global_flag in ('N', 'n')
                  and p_MODIFIER_LIST_rec.org_id is null) THEN
	            l_return_status := FND_API.G_RET_STS_ERROR;
	            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
                      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORG_ID');
		      oe_msg_pub.add;
                    END IF;
                  END IF;

                  --if org_id is not null and it is not a valid org
                  IF (p_MODIFIER_LIST_rec.org_id is not null
                  and QP_UTIL.validate_org_id(p_MODIFIER_LIST_rec.org_id) = 'N') THEN
	            l_return_status := FND_API.G_RET_STS_ERROR;
	            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
                      FND_MESSAGE.SET_NAME('FND','FND_MO_ORG_INVALID');
--		      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORG_ID');
		      oe_msg_pub.add;
                    END IF;
                  END IF;
                END IF; --IF l_security_profile = 'Y'

                --global_flag 'Y', and org_id not null combination is invalid
                IF ((p_MODIFIER_LIST_rec.global_flag = 'Y'
                and p_MODIFIER_LIST_rec.org_id is not null) OR (p_MODIFIER_LIST_rec.global_flag = 'N' and p_MODIFIER_LIST_rec.org_id is null)) THEN
--                and p_MODIFIER_LIST_rec.org_id <> FND_API.G_MISS_NUM THEN
	          l_return_status := FND_API.G_RET_STS_ERROR;
	          IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.SET_NAME('QP', 'QP_GLOBAL_OR_ORG');
		    oe_msg_pub.add;
                  END IF;
                END IF;--p_header_rec.global_flag
    END IF;
    --end validations for moac

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --


    --
    --  Validate attribute dependencies here.
    --


    --  Done validating entity

    x_return_status := l_return_status;

    oe_debug_pub.add('END entity in QPXLMLHB');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

oe_debug_pub.add('here in G_EXC');
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

oe_debug_pub.add('others EXP');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
,   p_old_MODIFIER_LIST_rec         IN  QP_Modifiers_PUB.Modifier_List_Rec_Type :=
                                        QP_Modifiers_PUB.G_MISS_MODIFIER_LIST_REC
)
IS
BEGIN

    oe_debug_pub.add('BEGIN attributes in QPXLMLHB');

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate MODIFIER_LIST attributes

    IF  p_MODIFIER_LIST_rec.automatic_flag IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.automatic_flag <>
            p_old_MODIFIER_LIST_rec.automatic_flag OR
            p_old_MODIFIER_LIST_rec.automatic_flag IS NULL )
    THEN
        IF NOT QP_Validate.Automatic(p_MODIFIER_LIST_rec.automatic_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here1');
    IF  p_MODIFIER_LIST_rec.comments IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.comments <>
            p_old_MODIFIER_LIST_rec.comments OR
            p_old_MODIFIER_LIST_rec.comments IS NULL )
    THEN
        IF NOT QP_Validate.Comments(p_MODIFIER_LIST_rec.comments) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.created_by IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.created_by <>
            p_old_MODIFIER_LIST_rec.created_by OR
            p_old_MODIFIER_LIST_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_MODIFIER_LIST_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.creation_date IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.creation_date <>
            p_old_MODIFIER_LIST_rec.creation_date OR
            p_old_MODIFIER_LIST_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_MODIFIER_LIST_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.currency_code IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.currency_code <>
            p_old_MODIFIER_LIST_rec.currency_code OR
            p_old_MODIFIER_LIST_rec.currency_code IS NULL )
    THEN
        IF NOT QP_Validate.Currency(p_MODIFIER_LIST_rec.currency_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.discount_lines_flag IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.discount_lines_flag <>
            p_old_MODIFIER_LIST_rec.discount_lines_flag OR
            p_old_MODIFIER_LIST_rec.discount_lines_flag IS NULL )
    THEN
        IF NOT QP_Validate.Discount_Lines(p_MODIFIER_LIST_rec.discount_lines_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here6');
    IF  p_MODIFIER_LIST_rec.end_date_active IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.end_date_active <>
            p_old_MODIFIER_LIST_rec.end_date_active OR
            p_old_MODIFIER_LIST_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_MODIFIER_LIST_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here7');
    IF  p_MODIFIER_LIST_rec.freight_terms_code IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.freight_terms_code <>
            p_old_MODIFIER_LIST_rec.freight_terms_code OR
            p_old_MODIFIER_LIST_rec.freight_terms_code IS NULL )
    THEN
        IF NOT QP_Validate.Freight_Terms(p_MODIFIER_LIST_rec.freight_terms_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here8');
    IF  p_MODIFIER_LIST_rec.gsa_indicator IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.gsa_indicator <>
            p_old_MODIFIER_LIST_rec.gsa_indicator OR
            p_old_MODIFIER_LIST_rec.gsa_indicator IS NULL )
    THEN
        IF NOT QP_Validate.Gsa_Indicator(p_MODIFIER_LIST_rec.gsa_indicator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here9');
    IF  p_MODIFIER_LIST_rec.last_updated_by IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.last_updated_by <>
            p_old_MODIFIER_LIST_rec.last_updated_by OR
            p_old_MODIFIER_LIST_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_MODIFIER_LIST_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here10');
    IF  p_MODIFIER_LIST_rec.last_update_date IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.last_update_date <>
            p_old_MODIFIER_LIST_rec.last_update_date OR
            p_old_MODIFIER_LIST_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_MODIFIER_LIST_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here11');
    IF  p_MODIFIER_LIST_rec.last_update_login IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.last_update_login <>
            p_old_MODIFIER_LIST_rec.last_update_login OR
            p_old_MODIFIER_LIST_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_MODIFIER_LIST_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here12');
    IF  p_MODIFIER_LIST_rec.list_header_id IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.list_header_id <>
            p_old_MODIFIER_LIST_rec.list_header_id OR
            p_old_MODIFIER_LIST_rec.list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Header(p_MODIFIER_LIST_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here13');
    IF  p_MODIFIER_LIST_rec.list_type_code IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.list_type_code <>
            p_old_MODIFIER_LIST_rec.list_type_code OR
            p_old_MODIFIER_LIST_rec.list_type_code IS NULL )
    THEN
        IF NOT QP_Validate.List_Type(p_MODIFIER_LIST_rec.list_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here14');
    IF  p_MODIFIER_LIST_rec.program_application_id IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.program_application_id <>
            p_old_MODIFIER_LIST_rec.program_application_id OR
            p_old_MODIFIER_LIST_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_MODIFIER_LIST_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here15');
    IF  p_MODIFIER_LIST_rec.program_id IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.program_id <>
            p_old_MODIFIER_LIST_rec.program_id OR
            p_old_MODIFIER_LIST_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_MODIFIER_LIST_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here16');
    IF  p_MODIFIER_LIST_rec.program_update_date IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.program_update_date <>
            p_old_MODIFIER_LIST_rec.program_update_date OR
            p_old_MODIFIER_LIST_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_MODIFIER_LIST_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here17');
    IF  p_MODIFIER_LIST_rec.prorate_flag IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.prorate_flag <>
            p_old_MODIFIER_LIST_rec.prorate_flag OR
            p_old_MODIFIER_LIST_rec.prorate_flag IS NULL )
    THEN
        IF NOT QP_Validate.Prorate(p_MODIFIER_LIST_rec.prorate_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here18');
    IF  p_MODIFIER_LIST_rec.request_id IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.request_id <>
            p_old_MODIFIER_LIST_rec.request_id OR
            p_old_MODIFIER_LIST_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_MODIFIER_LIST_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here19');
    IF  p_MODIFIER_LIST_rec.rounding_factor IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.rounding_factor <>
            p_old_MODIFIER_LIST_rec.rounding_factor OR
            p_old_MODIFIER_LIST_rec.rounding_factor IS NULL )
    THEN
        IF NOT QP_Validate.Rounding_Factor(p_MODIFIER_LIST_rec.rounding_factor) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here20');
    IF  p_MODIFIER_LIST_rec.ship_method_code IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.ship_method_code <>
            p_old_MODIFIER_LIST_rec.ship_method_code OR
            p_old_MODIFIER_LIST_rec.ship_method_code IS NULL )
    THEN
        IF NOT QP_Validate.Ship_Method(p_MODIFIER_LIST_rec.ship_method_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here21');
oe_debug_pub.add(to_char(p_MODIFIER_LIST_rec.start_date_active)||'start_date');
    IF  p_MODIFIER_LIST_rec.start_date_active IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.start_date_active <>
            p_old_MODIFIER_LIST_rec.start_date_active OR
            p_old_MODIFIER_LIST_rec.start_date_active IS NULL )
    THEN
    oe_debug_pub.add('here');
        IF NOT QP_Validate.Start_Date_Active(p_MODIFIER_LIST_rec.start_date_active) THEN
    oe_debug_pub.add('here');
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here22');
    IF  p_MODIFIER_LIST_rec.terms_id IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.terms_id <>
            p_old_MODIFIER_LIST_rec.terms_id OR
            p_old_MODIFIER_LIST_rec.terms_id IS NULL )
    THEN
        IF NOT QP_Validate.Terms(p_MODIFIER_LIST_rec.terms_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here23');
    IF  p_MODIFIER_LIST_rec.source_system_code IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.source_system_code <>
            p_old_MODIFIER_LIST_rec.source_system_code OR
            p_old_MODIFIER_LIST_rec.source_system_code IS NULL )
    THEN
        IF NOT QP_Validate.Source_System(p_MODIFIER_LIST_rec.source_system_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.pte_code IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.pte_code <>
            p_old_MODIFIER_LIST_rec.pte_code OR
            p_old_MODIFIER_LIST_rec.pte_code IS NULL )
    THEN
        IF NOT QP_Validate.Pte_Code(p_MODIFIER_LIST_rec.pte_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here24');
    IF  p_MODIFIER_LIST_rec.active_flag IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.active_flag <>
            p_old_MODIFIER_LIST_rec.active_flag OR
            p_old_MODIFIER_LIST_rec.active_flag IS NULL )
    THEN
        IF NOT QP_Validate.Active(p_MODIFIER_LIST_rec.active_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here25');
    IF  p_MODIFIER_LIST_rec.parent_list_header_id IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.parent_list_header_id <>
            p_old_MODIFIER_LIST_rec.parent_list_header_id OR
            p_old_MODIFIER_LIST_rec.parent_list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.Parent_List_Header(p_MODIFIER_LIST_rec.parent_list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here26');
    IF  p_MODIFIER_LIST_rec.start_date_active_first IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.start_date_active_first <>
            p_old_MODIFIER_LIST_rec.start_date_active_first OR
            p_old_MODIFIER_LIST_rec.start_date_active_first IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active_First(p_MODIFIER_LIST_rec.start_date_active_first) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here27');
    IF  p_MODIFIER_LIST_rec.end_date_active_first IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.end_date_active_first <>
            p_old_MODIFIER_LIST_rec.end_date_active_first OR
            p_old_MODIFIER_LIST_rec.end_date_active_first IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active_First(p_MODIFIER_LIST_rec.end_date_active_first) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here28');
    IF  p_MODIFIER_LIST_rec.active_date_first_type IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.active_date_first_type <>
            p_old_MODIFIER_LIST_rec.active_date_first_type OR
            p_old_MODIFIER_LIST_rec.active_date_first_type IS NULL )
    THEN
        IF NOT QP_Validate.Active_Date_First_Type(p_MODIFIER_LIST_rec.active_date_first_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here29');
    IF  p_MODIFIER_LIST_rec.start_date_active_second IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.start_date_active_second <>
            p_old_MODIFIER_LIST_rec.start_date_active_second OR
            p_old_MODIFIER_LIST_rec.start_date_active_second IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active_Second(p_MODIFIER_LIST_rec.start_date_active_second) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.global_flag IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.global_flag <>
            p_old_MODIFIER_LIST_rec.global_flag OR
            p_old_MODIFIER_LIST_rec.global_flag IS NULL )
    THEN
        IF NOT QP_Validate.Global_Flag(p_MODIFIER_LIST_rec.global_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


oe_debug_pub.add('here30');
    IF  p_MODIFIER_LIST_rec.end_date_active_second IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.end_date_active_second <>
            p_old_MODIFIER_LIST_rec.end_date_active_second OR
            p_old_MODIFIER_LIST_rec.end_date_active_second IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active_Second(p_MODIFIER_LIST_rec.end_date_active_second) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here31');
    IF  p_MODIFIER_LIST_rec.active_date_second_type IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.active_date_second_type <>
            p_old_MODIFIER_LIST_rec.active_date_second_type OR
            p_old_MODIFIER_LIST_rec.active_date_second_type IS NULL )
    THEN
        IF NOT QP_Validate.Active_Date_Second_Type(p_MODIFIER_LIST_rec.active_date_second_type) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.ask_for_flag IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.ask_for_flag <>
            p_old_MODIFIER_LIST_rec.ask_for_flag OR
            p_old_MODIFIER_LIST_rec.ask_for_flag IS NULL )
    THEN
        IF NOT QP_Validate.Ask_For(p_MODIFIER_LIST_rec.ask_for_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.name IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.name <>
            p_old_MODIFIER_LIST_rec.name OR
            p_old_MODIFIER_LIST_rec.name IS NULL )
    THEN
        IF NOT QP_Validate.Name(p_MODIFIER_LIST_rec.name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_MODIFIER_LIST_rec.description IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.description <>
            p_old_MODIFIER_LIST_rec.description OR
            p_old_MODIFIER_LIST_rec.description IS NULL )
    THEN
        IF NOT QP_Validate.Description(p_MODIFIER_LIST_rec.description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

oe_debug_pub.add('here31 - blanket pricing');
    IF p_MODIFIER_LIST_rec.LIST_SOURCE_CODE IS NOT NULL AND
       (    p_MODIFIER_LIST_rec.LIST_SOURCE_CODE <>
            p_old_MODIFIER_LIST_rec.LIST_SOURCE_CODE OR
            p_old_MODIFIER_LIST_rec.LIST_SOURCE_CODE IS NULL)
    THEN
       IF NOT QP_Validate.list_source_code(p_MODIFIER_LIST_rec.LIST_SOURCE_CODE) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    IF p_MODIFIER_LIST_rec.ORIG_SYSTEM_HEADER_REF IS NOT NULL AND
       (    p_MODIFIER_LIST_rec.ORIG_SYSTEM_HEADER_REF <>
            p_old_MODIFIER_LIST_rec.ORIG_SYSTEM_HEADER_REF OR
            p_old_MODIFIER_LIST_rec.ORIG_SYSTEM_HEADER_REF IS NULL)
    THEN
       IF NOT QP_Validate.orig_system_header_ref(p_MODIFIER_LIST_rec.ORIG_SYSTEM_HEADER_REF)
       THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    IF p_MODIFIER_LIST_rec.SHAREABLE_FLAG IS NOT NULL AND
       (    p_MODIFIER_LIST_rec.SHAREABLE_FLAG <>
            p_old_MODIFIER_LIST_rec.SHAREABLE_FLAG OR
            p_old_MODIFIER_LIST_rec.SHAREABLE_FLAG IS NULL)
    THEN
       IF NOT QP_Validate.shareable_flag(p_MODIFIER_LIST_rec.SHAREABLE_FLAG) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

    --added for MOAC
    IF p_MODIFIER_LIST_rec.ORG_ID IS NOT NULL AND
       (    p_MODIFIER_LIST_rec.ORG_ID <>
            p_old_MODIFIER_LIST_rec.ORG_ID OR
            p_old_MODIFIER_LIST_rec.ORG_ID IS NULL)
    THEN
       IF NOT QP_Validate.ORG_ID(p_MODIFIER_LIST_rec.ORG_ID) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
    END IF;

oe_debug_pub.add('here32');
    IF  (p_MODIFIER_LIST_rec.attribute1 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute1 <>
            p_old_MODIFIER_LIST_rec.attribute1 OR
            p_old_MODIFIER_LIST_rec.attribute1 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute10 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute10 <>
            p_old_MODIFIER_LIST_rec.attribute10 OR
            p_old_MODIFIER_LIST_rec.attribute10 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute11 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute11 <>
            p_old_MODIFIER_LIST_rec.attribute11 OR
            p_old_MODIFIER_LIST_rec.attribute11 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute12 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute12 <>
            p_old_MODIFIER_LIST_rec.attribute12 OR
            p_old_MODIFIER_LIST_rec.attribute12 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute13 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute13 <>
            p_old_MODIFIER_LIST_rec.attribute13 OR
            p_old_MODIFIER_LIST_rec.attribute13 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute14 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute14 <>
            p_old_MODIFIER_LIST_rec.attribute14 OR
            p_old_MODIFIER_LIST_rec.attribute14 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute15 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute15 <>
            p_old_MODIFIER_LIST_rec.attribute15 OR
            p_old_MODIFIER_LIST_rec.attribute15 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute2 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute2 <>
            p_old_MODIFIER_LIST_rec.attribute2 OR
            p_old_MODIFIER_LIST_rec.attribute2 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute3 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute3 <>
            p_old_MODIFIER_LIST_rec.attribute3 OR
            p_old_MODIFIER_LIST_rec.attribute3 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute4 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute4 <>
            p_old_MODIFIER_LIST_rec.attribute4 OR
            p_old_MODIFIER_LIST_rec.attribute4 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute5 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute5 <>
            p_old_MODIFIER_LIST_rec.attribute5 OR
            p_old_MODIFIER_LIST_rec.attribute5 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute6 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute6 <>
            p_old_MODIFIER_LIST_rec.attribute6 OR
            p_old_MODIFIER_LIST_rec.attribute6 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute7 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute7 <>
            p_old_MODIFIER_LIST_rec.attribute7 OR
            p_old_MODIFIER_LIST_rec.attribute7 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute8 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute8 <>
            p_old_MODIFIER_LIST_rec.attribute8 OR
            p_old_MODIFIER_LIST_rec.attribute8 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.attribute9 IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.attribute9 <>
            p_old_MODIFIER_LIST_rec.attribute9 OR
            p_old_MODIFIER_LIST_rec.attribute9 IS NULL ))
    OR  (p_MODIFIER_LIST_rec.context IS NOT NULL AND
        (   p_MODIFIER_LIST_rec.context <>
            p_old_MODIFIER_LIST_rec.context OR
            p_old_MODIFIER_LIST_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_MODIFIER_LIST_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_MODIFIER_LIST_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'MODIFIER_LIST' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

    oe_debug_pub.add('END attributes in QPXLMLHB');
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
            ,   'Attributes'
            );
        END IF;


END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_MODIFIER_LIST_rec             IN  QP_Modifiers_PUB.Modifier_List_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

    oe_debug_pub.add('BEGIN entity_delete in QPXLMLHB');
    --  Validate entity delete.

    NULL;

    --  Done.

    x_return_status := l_return_status;

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
            ,   'Entity_Delete'
            );
        END IF;

    oe_debug_pub.add('END entity_delete in QPXLMLHB');
END Entity_Delete;

END QP_Validate_Modifier_List;

/
