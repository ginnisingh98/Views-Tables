--------------------------------------------------------
--  DDL for Package Body QP_VALIDATE_PRICE_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_VALIDATE_PRICE_LIST" AS
/* $Header: QPXLPLHB.pls 120.9 2006/08/03 05:27:03 rbagri ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'QP_Validate_Price_List';

--  Procedure Entity

PROCEDURE Entity
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_dummy_c                     VARCHAR2(1);
l_security_profile            VARCHAR2(1);
l_unit_precision_type         VARCHAR2(255):= '';
l_price_rounding              VARCHAR2(50):= '';

	cursor c_lines_dates_cur(p_list_header_id NUMBER)  is
	select end_date_active, start_date_active
	from qp_list_lines
	where list_header_id = p_list_header_id
	and NOT((end_date_active is null or end_date_active = FND_API.G_MISS_DATE)
		and (start_date_active is null or start_date_active = FND_API.G_MISS_DATE));

BEGIN

    --  Check required attributes. list_header_id, list_type_code
    --  and currency_code are required.

    IF  p_PRICE_LIST_rec.list_header_id IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_header_id');
            oe_msg_pub.Add;

        END IF;

    END IF;

--5286339
  IF p_PRICE_LIST_rec.operation = QP_GLOBALS.G_OPR_UPDATE
    THEN
      IF  nvl(p_old_PRICE_LIST_rec.shareable_flag,'X') <>
        nvl(p_PRICE_LIST_rec.shareable_flag,'X')
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','shareable_flag');
       OE_MSG_PUB.Add;

      END IF;

      IF  nvl(p_old_PRICE_LIST_rec.list_source_code,'X') <>
        nvl(p_PRICE_LIST_rec.list_source_code,'X')
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_source_code');
       OE_MSG_PUB.Add;

     END IF;

     IF  nvl(p_old_PRICE_LIST_rec.rounding_factor,9999999) <>
        nvl(p_PRICE_LIST_rec.rounding_factor,9999999)
         THEN

	 l_unit_precision_type :=  FND_PROFILE.VALUE('QP_UNIT_PRICE_PRECISION_TYPE');
         l_price_rounding := fnd_profile.value('QP_PRICE_ROUNDING');

	 IF l_unit_precision_type = 'STANDARD' THEN
           IF l_price_rounding = 'PRECISION' THEN
                      l_return_status := FND_API.G_RET_STS_ERROR;
                      FND_MESSAGE.SET_NAME('QP', 'QP_ROUNDING_FACTOR_NO_UPDATE');
                      OE_MSG_PUB.Add;
               END IF;
           END IF;
     END IF;

     IF  nvl(p_old_PRICE_LIST_rec.pte_code,'X') <>
       nvl(p_PRICE_LIST_rec.pte_code,'X')
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','pte_code');
       OE_MSG_PUB.Add;

     END IF;

     IF  nvl(p_old_PRICE_LIST_rec.source_system_code,'X') <>
       nvl(p_PRICE_LIST_rec.source_system_code,'X')
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','source_system_code');
       OE_MSG_PUB.Add;

    END IF;

    IF  nvl(p_old_PRICE_LIST_rec.sold_to_org_id,9999999) <>
      nvl(p_PRICE_LIST_rec.sold_to_org_id,9999999)
         THEN
       l_return_status := FND_API.G_RET_STS_ERROR;

       FND_MESSAGE.SET_NAME('QP','QP_CANNOT_UPDATE_ATTRIBUTE');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
       OE_MSG_PUB.Add;

    END IF;

  END IF;

--5286339

    IF  p_PRICE_LIST_rec.list_type_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('LIST_TYPE_CODE'));  -- Fix For Bug-1974413
            oe_msg_pub.Add;

        END IF;

    END IF;


    IF  p_PRICE_LIST_rec.currency_code IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('CURRENCY_CODE'));  -- Fix For Bug-1974413
            oe_msg_pub.Add;

        END IF;

    END IF;

          -- Bug 2347427 start

    IF  p_PRICE_LIST_rec.currency_code IS NOT NULL AND
        ( p_PRICE_LIST_rec.currency_code <>
            p_old_PRICE_LIST_rec.currency_code )
    THEN
        FND_MESSAGE.SET_NAME('QP','QP_CHANGE_SEC_PRL_CURR');
        OE_MSG_PUB.Add;
    END IF;

        -- Bug 2347427 end

    IF  p_PRICE_LIST_rec.name IS NULL
    THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE',QP_PRC_UTIL.Get_Attribute_Name('NAME'));  -- Fix For Bug-1974413
            oe_msg_pub.Add;

        END IF;

    END IF;

    --  Return Error if a required attribute is missing.

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

    END IF;

    --
    --  Check conditionally required attributes here.
    --

   IF NOT QP_Validate.Currency(p_PRICE_LIST_rec.currency_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


   IF NOT QP_Validate.Rounding_Factor(p_PRICE_LIST_rec.rounding_factor,p_PRICE_LIST_rec.currency_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF ( p_PRICE_LIST_rec.automatic_flag IS NOT NULL
      and p_PRICE_LIST_rec.automatic_flag <> FND_API.G_MISS_CHAR ) THEN

      IF p_PRICE_LIST_rec.automatic_flag not in ('Y', 'N', 'y', 'n') THEN

         l_return_status := FND_API.G_RET_STS_ERROR;

         IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
         THEN

            FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
            FND_MESSAGE.SET_TOKEN('ATTRIBUTE','automatic');
            oe_msg_pub.Add;

         END IF;

      END IF;

  END IF;
  --add validation for active_flag
  IF ( p_PRICE_LIST_rec.active_flag IS NOT NULL
	  and p_PRICE_LIST_rec.active_flag <> FND_API.G_MISS_CHAR ) THEN

		 IF p_PRICE_LIST_rec.active_flag not in ('Y', 'N', 'y', 'n') THEN

		 l_return_status := FND_API.G_RET_STS_ERROR;

		 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
		 THEN

			FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
			FND_MESSAGE.SET_TOKEN('ATTRIBUTE','active_flag');
			oe_msg_pub.add;
            END IF;
		  END IF;
		  END IF;

  -- mkarya for bug 1944882
  IF ( p_PRICE_LIST_rec.mobile_download IS NOT NULL
	  and p_PRICE_LIST_rec.mobile_download <> FND_API.G_MISS_CHAR ) THEN

     IF p_PRICE_LIST_rec.mobile_download not in ('Y', 'N', 'n') THEN

	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN

		FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','mobile_download');
		oe_msg_pub.add;
         END IF;
     END IF;
  END IF;

  -- Pricing Security gtippire
  IF ( p_PRICE_LIST_rec.global_flag IS NOT NULL
	  and p_PRICE_LIST_rec.global_flag <> FND_API.G_MISS_CHAR ) THEN

     IF p_PRICE_LIST_rec.global_flag not in ('Y', 'N', 'n') THEN

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

    IF ( p_PRICE_LIST_rec.global_flag IS NOT NULL)
    THEN

                --if security is OFF, global_flag cannot be 'N'
                IF (l_security_profile = 'N'
                and p_PRICE_LIST_rec.global_flag in ('N', 'n')) THEN
	          l_return_status := FND_API.G_RET_STS_ERROR;
	          IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
		    FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
		    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','global_flag');
		    oe_msg_pub.add;
                  END IF;
        	END IF;

                IF l_security_profile = 'Y' THEN
                  --if security is ON and global_flag is 'N', org_id cannot be null
                  IF (p_PRICE_LIST_rec.global_flag in ('N', 'n')
                  and p_PRICE_LIST_rec.org_id is null) THEN
	            l_return_status := FND_API.G_RET_STS_ERROR;
	            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
                      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORG_ID');
		      oe_msg_pub.add;
                    END IF;
                  END IF;

                  --if org_id is not null and it is not a valid org
                  IF (p_PRICE_LIST_rec.org_id is not null
                  and QP_UTIL.validate_org_id(p_PRICE_LIST_rec.org_id) = 'N') THEN
	            l_return_status := FND_API.G_RET_STS_ERROR;
	            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
		      FND_MESSAGE.SET_NAME('FND','FND_MO_ORG_INVALID');
--		      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ORG_ID');
		      oe_msg_pub.add;
                    END IF;
                  END IF;
                END IF;--IF l_security_profile = 'Y'

                -- global_flag 'Y', and org_id not null combination is invalid
                IF ((p_PRICE_LIST_rec.global_flag = 'Y'
                and p_PRICE_LIST_rec.org_id is not null) OR (p_PRICE_LIST_rec.global_flag ='N' and p_PRICE_LIST_rec.org_id is null)) THEN
--                and p_MODIFIER_LIST_rec.org_id <> FND_API.G_MISS_NUM THEN
	          l_return_status := FND_API.G_RET_STS_ERROR;
	          IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR) THEN
                    FND_MESSAGE.SET_NAME('QP', 'QP_GLOBAL_OR_ORG');
		    oe_msg_pub.add;
                  END IF;
                END IF;--p_header_rec.global_flag
    END IF;
    --end validations for moac


  -- Multi-Currency SunilPandey
  -- Check if the multi-currency profile option is set then multi-currency name must be
  -- present and rounding_factor should be null else other way round
  -- If NVL(UPPER(fnd_profile.value('QP_MULTI_CURRENCY_INSTALLED')), 'NO') = 'Y'
  If QP_UTIL.Get_QP_Status = 'I' AND  -- bug 4739577 (sfiresto)
     QP_LIST_HEADERS_PVT.G_MULTI_CURRENCY_INSTALLED = 'Y'
  then

     -- Multi-Currency is installed
     If (p_PRICE_LIST_rec.currency_header_id is NULL  or
	 p_PRICE_LIST_rec.currency_header_id = FND_API.G_MISS_NUM )
     then
	 l_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('QP','QP_MUL_CURR_REQD');
         oe_msg_pub.add;

     end if;

     /*
     If (p_PRICE_LIST_rec.rounding_factor is NOT NULL  and
	 p_PRICE_LIST_rec.rounding_factor <> FND_API.G_MISS_NUM )
     then
	 l_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');  -- CHANGE
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','rounding_factor');
         oe_msg_pub.add;

     end if;
     */
  else
     -- Multi-Currency not installed
     If (p_PRICE_LIST_rec.currency_header_id is NOT NULL  and
	 p_PRICE_LIST_rec.currency_header_id <> FND_API.G_MISS_NUM and
	 p_old_PRICE_LIST_rec.currency_header_id <> p_PRICE_LIST_rec.currency_header_id)
     then
	 l_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('QP','QP_MUL_CURR_NULL');
         oe_msg_pub.add;

     end if;

  end if;

   -- Bug 2293974 - rounding factor is mandatory irrespective of multi-currency is installed or not
     If (p_PRICE_LIST_rec.rounding_factor is NULL  or
	 p_PRICE_LIST_rec.rounding_factor = FND_API.G_MISS_NUM )
     then
	 l_return_status := FND_API.G_RET_STS_ERROR;

         FND_MESSAGE.SET_NAME('QP','QP_RNDG_FACTOR_REQD');
         oe_msg_pub.add;

     end if;

  IF ( p_PRICE_LIST_rec.currency_header_id IS NOT NULL and
       p_PRICE_LIST_rec.currency_header_id <> FND_API.G_MISS_NUM ) THEN
   BEGIN

     SELECT 'X'
     INTO l_dummy_c
     FROM QP_CURRENCY_LISTS_B
     WHERE currency_header_id = p_PRICE_LIST_rec.currency_header_id and
	   base_currency_code = p_PRICE_LIST_rec.currency_code;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
	 l_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('QP','QP_INVALID_ATTRIBUTE');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','currency_header_id');
         oe_msg_pub.add;
   END;
  END IF;

   IF NOT QP_Validate.List_Type(p_PRICE_LIST_rec.list_type_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   /*

   IF NOT QP_Validate.Source_System(p_PRICE_LIST_rec.source_system_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   */

   IF NOT QP_Validate.Ship_Method(p_PRICE_LIST_rec.ship_method_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF NOT QP_Validate.Freight_Terms(p_PRICE_LIST_rec.freight_terms_code) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF NOT QP_Validate.Terms(p_PRICE_LIST_rec.terms_id) THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

    --
    --  Validate attribute dependencies here.
    --

IF NOT QP_Validate.Start_Date_Active(p_PRICE_LIST_rec.start_date_active, p_PRICE_LIST_rec.end_date_active) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

           /*

            IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_ERROR)
            THEN

              FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
              FND_MESSAGE.SET_TOKEN('ATTRIBUTE','list_line_id');
              oe_msg_pub.Add;

            END IF;

           */

       END IF;

IF  NOT((p_PRICE_LIST_rec.end_date_active is null or p_PRICE_LIST_rec.end_date_active  = FND_API.G_MISS_DATE)
	and (p_PRICE_LIST_rec.start_date_active is null or p_PRICE_LIST_rec.start_date_active  = FND_API.G_MISS_DATE)) THEN
	FOR l_lines_dates_cur IN c_lines_dates_cur(p_PRICE_LIST_rec.list_header_id) LOOP
		IF (p_PRICE_LIST_rec.end_date_active < l_lines_dates_cur.end_date_active) THEN -- line date not within hdr date
			l_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('QP','QP_PLL_END_DATE_NOT_WITHIN');
         		oe_msg_pub.add;
			exit;
		END IF;

		IF (p_PRICE_LIST_rec.start_date_active > l_lines_dates_cur.start_date_active) THEN -- line date not within hdr date
			l_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('QP','QP_PLL_START_DATE_NOT_WITHIN');
         		oe_msg_pub.add;
			exit;
		END IF;
	END LOOP;
END IF;

       IF NOT QP_Validate.Price_List_Name(p_PRICE_LIST_rec.name,
                                p_PRICE_LIST_rec.list_header_id,
                                p_PRICE_LIST_rec.version_no) THEN

            l_return_status := FND_API.G_RET_STS_ERROR;

        END IF;


     IF l_return_status = FND_API.G_RET_STS_ERROR THEN

        RAISE FND_API.G_EXC_ERROR;

     END IF;

    --  Done validating entity

    x_return_status := l_return_status;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity'
            );
        END IF;

END Entity;

--  Procedure Attributes

PROCEDURE Attributes
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
,   p_old_PRICE_LIST_rec            IN  QP_Price_List_PUB.Price_List_Rec_Type :=
                                        QP_Price_List_PUB.G_MISS_PRICE_LIST_REC
)
IS

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate PRICE_LIST attributes

    IF  p_PRICE_LIST_rec.automatic_flag IS NOT NULL AND
        (   p_PRICE_LIST_rec.automatic_flag <>
            p_old_PRICE_LIST_rec.automatic_flag OR
            p_old_PRICE_LIST_rec.automatic_flag IS NULL )
    THEN
        IF NOT QP_Validate.Automatic(p_PRICE_LIST_rec.automatic_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF p_PRICE_LIST_rec.active_flag IS NOT NULL AND
	    (p_PRICE_LIST_rec.active_flag <>
		p_old_PRICE_LIST_rec.active_flag OR
		p_old_PRICE_LIST_rec.active_flag IS NULL)
    THEN
	   IF NOT QP_Validate.active(p_PRICE_LIST_rec.active_flag) THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --mkarya for bug 1944882
    IF p_PRICE_LIST_rec.mobile_download IS NOT NULL AND
	    (p_PRICE_LIST_rec.mobile_download <>
		p_old_PRICE_LIST_rec.mobile_download OR
		p_old_PRICE_LIST_rec.mobile_download IS NULL)
    THEN
	   IF NOT QP_Validate.mobile_download(p_PRICE_LIST_rec.mobile_download) THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --Pricing Security gtippire
    IF p_PRICE_LIST_rec.global_flag IS NOT NULL AND
	    (p_PRICE_LIST_rec.global_flag <>
		p_old_PRICE_LIST_rec.global_flag OR
		p_old_PRICE_LIST_rec.global_flag IS NULL)
    THEN
	   IF NOT QP_Validate.global_flag(p_PRICE_LIST_rec.global_flag) THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;


    IF  p_PRICE_LIST_rec.description IS NOT NULL AND
        (   p_PRICE_LIST_rec.description <>
            p_old_PRICE_LIST_rec.description OR
            p_old_PRICE_LIST_rec.description IS NULL )
    THEN
      IF NOT QP_Validate.Description(p_PRICE_LIST_rec.description) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.name IS NOT NULL AND
        (   p_PRICE_LIST_rec.name <>
            p_old_PRICE_LIST_rec.name OR
            p_old_PRICE_LIST_rec.name IS NULL )
    THEN
        IF NOT QP_Validate.Name(p_PRICE_LIST_rec.name) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.comments IS NOT NULL AND
        (   p_PRICE_LIST_rec.comments <>
            p_old_PRICE_LIST_rec.comments OR
            p_old_PRICE_LIST_rec.comments IS NULL )
    THEN
        IF NOT QP_Validate.Comments(p_PRICE_LIST_rec.comments) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.created_by IS NOT NULL AND
        (   p_PRICE_LIST_rec.created_by <>
            p_old_PRICE_LIST_rec.created_by OR
            p_old_PRICE_LIST_rec.created_by IS NULL )
    THEN
        IF NOT QP_Validate.Created_By(p_PRICE_LIST_rec.created_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.creation_date IS NOT NULL AND
        (   p_PRICE_LIST_rec.creation_date <>
            p_old_PRICE_LIST_rec.creation_date OR
            p_old_PRICE_LIST_rec.creation_date IS NULL )
    THEN
        IF NOT QP_Validate.Creation_Date(p_PRICE_LIST_rec.creation_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.currency_code IS NOT NULL AND
        (   p_PRICE_LIST_rec.currency_code <>
            p_old_PRICE_LIST_rec.currency_code OR
            p_old_PRICE_LIST_rec.currency_code IS NULL )
    THEN
        IF NOT QP_Validate.Currency(p_PRICE_LIST_rec.currency_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.discount_lines_flag IS NOT NULL AND
        (   p_PRICE_LIST_rec.discount_lines_flag <>
            p_old_PRICE_LIST_rec.discount_lines_flag OR
            p_old_PRICE_LIST_rec.discount_lines_flag IS NULL )
    THEN
        IF NOT QP_Validate.Discount_Lines(p_PRICE_LIST_rec.discount_lines_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.end_date_active IS NOT NULL AND
        (   p_PRICE_LIST_rec.end_date_active <>
            p_old_PRICE_LIST_rec.end_date_active OR
            p_old_PRICE_LIST_rec.end_date_active IS NULL )
    THEN
        IF NOT QP_Validate.End_Date_Active(p_PRICE_LIST_rec.end_date_active, p_PRICE_LIST_rec.start_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF  p_PRICE_LIST_rec.freight_terms_code IS NOT NULL AND
        (   p_PRICE_LIST_rec.freight_terms_code <>
            p_old_PRICE_LIST_rec.freight_terms_code OR
            p_old_PRICE_LIST_rec.freight_terms_code IS NULL )
    THEN
        IF NOT QP_Validate.Freight_Terms(p_PRICE_LIST_rec.freight_terms_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.gsa_indicator IS NOT NULL AND
        (   p_PRICE_LIST_rec.gsa_indicator <>
            p_old_PRICE_LIST_rec.gsa_indicator OR
            p_old_PRICE_LIST_rec.gsa_indicator IS NULL )
    THEN
        IF NOT QP_Validate.Gsa_Indicator(p_PRICE_LIST_rec.gsa_indicator) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.last_updated_by IS NOT NULL AND
        (   p_PRICE_LIST_rec.last_updated_by <>
            p_old_PRICE_LIST_rec.last_updated_by OR
            p_old_PRICE_LIST_rec.last_updated_by IS NULL )
    THEN
        IF NOT QP_Validate.Last_Updated_By(p_PRICE_LIST_rec.last_updated_by) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.last_update_date IS NOT NULL AND
        (   p_PRICE_LIST_rec.last_update_date <>
            p_old_PRICE_LIST_rec.last_update_date OR
            p_old_PRICE_LIST_rec.last_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Date(p_PRICE_LIST_rec.last_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.last_update_login IS NOT NULL AND
        (   p_PRICE_LIST_rec.last_update_login <>
            p_old_PRICE_LIST_rec.last_update_login OR
            p_old_PRICE_LIST_rec.last_update_login IS NULL )
    THEN
        IF NOT QP_Validate.Last_Update_Login(p_PRICE_LIST_rec.last_update_login) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.list_header_id IS NOT NULL AND
        (   p_PRICE_LIST_rec.list_header_id <>
            p_old_PRICE_LIST_rec.list_header_id OR
            p_old_PRICE_LIST_rec.list_header_id IS NULL )
    THEN
        IF NOT QP_Validate.List_Header(p_PRICE_LIST_rec.list_header_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.list_type_code IS NOT NULL AND
        (   p_PRICE_LIST_rec.list_type_code <>
            p_old_PRICE_LIST_rec.list_type_code OR
            p_old_PRICE_LIST_rec.list_type_code IS NULL )
    THEN
        IF NOT QP_Validate.List_Type(p_PRICE_LIST_rec.list_type_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.version_no IS NOT NULL AND
        (   p_PRICE_LIST_rec.version_no <>
            p_old_PRICE_LIST_rec.version_no OR
            p_old_PRICE_LIST_rec.version_no IS NULL )
    THEN
        IF NOT QP_Validate.Version(p_PRICE_LIST_rec.version_no) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.program_application_id IS NOT NULL AND
        (   p_PRICE_LIST_rec.program_application_id <>
            p_old_PRICE_LIST_rec.program_application_id OR
            p_old_PRICE_LIST_rec.program_application_id IS NULL )
    THEN
        IF NOT QP_Validate.Program_Application(p_PRICE_LIST_rec.program_application_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.program_id IS NOT NULL AND
        (   p_PRICE_LIST_rec.program_id <>
            p_old_PRICE_LIST_rec.program_id OR
            p_old_PRICE_LIST_rec.program_id IS NULL )
    THEN
        IF NOT QP_Validate.Program(p_PRICE_LIST_rec.program_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.program_update_date IS NOT NULL AND
        (   p_PRICE_LIST_rec.program_update_date <>
            p_old_PRICE_LIST_rec.program_update_date OR
            p_old_PRICE_LIST_rec.program_update_date IS NULL )
    THEN
        IF NOT QP_Validate.Program_Update_Date(p_PRICE_LIST_rec.program_update_date) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.prorate_flag IS NOT NULL AND
        (   p_PRICE_LIST_rec.prorate_flag <>
            p_old_PRICE_LIST_rec.prorate_flag OR
            p_old_PRICE_LIST_rec.prorate_flag IS NULL )
    THEN
        IF NOT QP_Validate.Prorate(p_PRICE_LIST_rec.prorate_flag) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.request_id IS NOT NULL AND
        (   p_PRICE_LIST_rec.request_id <>
            p_old_PRICE_LIST_rec.request_id OR
            p_old_PRICE_LIST_rec.request_id IS NULL )
    THEN
        IF NOT QP_Validate.Request(p_PRICE_LIST_rec.request_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.rounding_factor IS NOT NULL AND
        (   p_PRICE_LIST_rec.rounding_factor <>
            p_old_PRICE_LIST_rec.rounding_factor OR
            p_old_PRICE_LIST_rec.rounding_factor IS NULL )
    THEN
        IF NOT QP_Validate.Rounding_Factor(p_PRICE_LIST_rec.rounding_factor) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.ship_method_code IS NOT NULL AND
        (   p_PRICE_LIST_rec.ship_method_code <>
            p_old_PRICE_LIST_rec.ship_method_code OR
            p_old_PRICE_LIST_rec.ship_method_code IS NULL )
    THEN
        IF NOT QP_Validate.Ship_Method(p_PRICE_LIST_rec.ship_method_code) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    IF  p_PRICE_LIST_rec.start_date_active IS NOT NULL AND
        (   p_PRICE_LIST_rec.start_date_active <>
            p_old_PRICE_LIST_rec.start_date_active OR
            p_old_PRICE_LIST_rec.start_date_active IS NULL )
    THEN
        IF NOT QP_Validate.Start_Date_Active(p_PRICE_LIST_rec.start_date_active, p_PRICE_LIST_rec.end_date_active) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;


    END IF;

    IF  p_PRICE_LIST_rec.terms_id IS NOT NULL AND
        (   p_PRICE_LIST_rec.terms_id <>
            p_old_PRICE_LIST_rec.terms_id OR
            p_old_PRICE_LIST_rec.terms_id IS NULL )
    THEN
        IF NOT QP_Validate.Terms(p_PRICE_LIST_rec.terms_id) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --Multi-Currency SunilPandey
    IF p_PRICE_LIST_rec.currency_header_id IS NOT NULL AND
	    (p_PRICE_LIST_rec.currency_header_id <>
		p_old_PRICE_LIST_rec.currency_header_id OR
		p_old_PRICE_LIST_rec.currency_header_id IS NULL)
    THEN
	   IF NOT QP_Validate.currency_header(p_PRICE_LIST_rec.currency_header_id) THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --Attribute Manager Giri
    IF p_PRICE_LIST_rec.pte_code IS NOT NULL AND
	    (p_PRICE_LIST_rec.pte_code <>
		p_old_PRICE_LIST_rec.pte_code OR
		p_old_PRICE_LIST_rec.pte_code IS NULL)
    THEN
	   IF NOT QP_Validate.pte(p_PRICE_LIST_rec.pte_code) THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;

    --Blanket Sales Order
    IF p_PRICE_LIST_rec.LIST_SOURCE_CODE IS NOT NULL AND
            (p_PRICE_LIST_rec.LIST_SOURCE_CODE <>
                p_old_PRICE_LIST_rec.LIST_SOURCE_CODE OR
                p_old_PRICE_LIST_rec.LIST_SOURCE_CODE IS NULL)
    THEN
           IF NOT QP_Validate.list_source_code(p_PRICE_LIST_rec.LIST_SOURCE_CODE) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    -- Blanket Pricing
    IF p_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF IS NOT NULL AND
            (p_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF <>
                p_old_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF OR
                p_old_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF IS NULL)
    THEN
        IF NOT QP_Validate.orig_system_header_ref(p_PRICE_LIST_rec.ORIG_SYSTEM_HEADER_REF) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    IF p_PRICE_LIST_rec.SOURCE_SYSTEM_CODE IS NOT NULL AND
        (p_PRICE_LIST_rec.SOURCE_SYSTEM_CODE <>
            p_old_PRICE_LIST_rec.SOURCE_SYSTEM_CODE OR
            p_old_PRICE_LIST_rec.SOURCE_SYSTEM_CODE IS NULL)
    THEN
            IF NOT QP_Validate.Source_System(p_PRICE_LIST_rec.SOURCE_SYSTEM_CODE) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
    END IF;

    IF p_PRICE_LIST_rec.SHAREABLE_FLAG IS NOT NULL AND
        (p_PRICE_LIST_rec.SHAREABLE_FLAG <>
            p_old_PRICE_LIST_rec.SHAREABLE_FLAG OR
            p_old_PRICE_LIST_rec.SHAREABLE_FLAG IS NULL)
    THEN
            IF NOT QP_Validate.shareable_flag(p_PRICE_LIST_rec.SHAREABLE_FLAG) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
    END IF;

    IF p_PRICE_LIST_rec.SOLD_TO_ORG_ID IS NOT NULL AND
        (p_PRICE_LIST_rec.SOLD_TO_ORG_ID <>
            p_old_PRICE_LIST_rec.SOLD_TO_ORG_ID OR
            p_old_PRICE_LIST_rec.SOLD_TO_ORG_ID IS NULL)
    THEN
            IF NOT QP_Validate.sold_to_org_id(p_PRICE_LIST_rec.SOLD_TO_ORG_ID) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
    END IF;

    IF p_PRICE_LIST_rec.locked_from_list_header_id IS NOT NULL AND
        (p_PRICE_LIST_rec.locked_from_list_header_id <>
            p_old_PRICE_LIST_rec.locked_from_list_header_id OR
            p_old_PRICE_LIST_rec.locked_from_list_header_id IS NULL)
    THEN
            IF NOT QP_Validate.locked_from_list_header_id(p_PRICE_LIST_rec.locked_from_list_header_id) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
    END IF;

    --added for MOAC
    IF p_PRICE_LIST_rec.org_id IS NOT NULL AND
        (p_PRICE_LIST_rec.org_id <>
            p_old_PRICE_LIST_rec.org_id OR
            p_old_PRICE_LIST_rec.org_id IS NULL)
    THEN
            IF NOT QP_Validate.org_id(p_PRICE_LIST_rec.org_id) THEN
                   x_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
    END IF;

    IF  (p_PRICE_LIST_rec.attribute1 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute1 <>
            p_old_PRICE_LIST_rec.attribute1 OR
            p_old_PRICE_LIST_rec.attribute1 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute10 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute10 <>
            p_old_PRICE_LIST_rec.attribute10 OR
            p_old_PRICE_LIST_rec.attribute10 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute11 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute11 <>
            p_old_PRICE_LIST_rec.attribute11 OR
            p_old_PRICE_LIST_rec.attribute11 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute12 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute12 <>
            p_old_PRICE_LIST_rec.attribute12 OR
            p_old_PRICE_LIST_rec.attribute12 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute13 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute13 <>
            p_old_PRICE_LIST_rec.attribute13 OR
            p_old_PRICE_LIST_rec.attribute13 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute14 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute14 <>
            p_old_PRICE_LIST_rec.attribute14 OR
            p_old_PRICE_LIST_rec.attribute14 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute15 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute15 <>
            p_old_PRICE_LIST_rec.attribute15 OR
            p_old_PRICE_LIST_rec.attribute15 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute2 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute2 <>
            p_old_PRICE_LIST_rec.attribute2 OR
            p_old_PRICE_LIST_rec.attribute2 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute3 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute3 <>
            p_old_PRICE_LIST_rec.attribute3 OR
            p_old_PRICE_LIST_rec.attribute3 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute4 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute4 <>
            p_old_PRICE_LIST_rec.attribute4 OR
            p_old_PRICE_LIST_rec.attribute4 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute5 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute5 <>
            p_old_PRICE_LIST_rec.attribute5 OR
            p_old_PRICE_LIST_rec.attribute5 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute6 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute6 <>
            p_old_PRICE_LIST_rec.attribute6 OR
            p_old_PRICE_LIST_rec.attribute6 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute7 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute7 <>
            p_old_PRICE_LIST_rec.attribute7 OR
            p_old_PRICE_LIST_rec.attribute7 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute8 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute8 <>
            p_old_PRICE_LIST_rec.attribute8 OR
            p_old_PRICE_LIST_rec.attribute8 IS NULL ))
    OR  (p_PRICE_LIST_rec.attribute9 IS NOT NULL AND
        (   p_PRICE_LIST_rec.attribute9 <>
            p_old_PRICE_LIST_rec.attribute9 OR
            p_old_PRICE_LIST_rec.attribute9 IS NULL ))
    OR  (p_PRICE_LIST_rec.context IS NOT NULL AND
        (   p_PRICE_LIST_rec.context <>
            p_old_PRICE_LIST_rec.context OR
            p_old_PRICE_LIST_rec.context IS NULL ))
    THEN

    --  These calls are temporarily commented out

/*
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE1'
        ,   column_value                  => p_PRICE_LIST_rec.attribute1
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE10'
        ,   column_value                  => p_PRICE_LIST_rec.attribute10
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE11'
        ,   column_value                  => p_PRICE_LIST_rec.attribute11
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE12'
        ,   column_value                  => p_PRICE_LIST_rec.attribute12
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE13'
        ,   column_value                  => p_PRICE_LIST_rec.attribute13
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE14'
        ,   column_value                  => p_PRICE_LIST_rec.attribute14
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE15'
        ,   column_value                  => p_PRICE_LIST_rec.attribute15
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE2'
        ,   column_value                  => p_PRICE_LIST_rec.attribute2
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE3'
        ,   column_value                  => p_PRICE_LIST_rec.attribute3
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE4'
        ,   column_value                  => p_PRICE_LIST_rec.attribute4
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE5'
        ,   column_value                  => p_PRICE_LIST_rec.attribute5
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE6'
        ,   column_value                  => p_PRICE_LIST_rec.attribute6
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE7'
        ,   column_value                  => p_PRICE_LIST_rec.attribute7
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE8'
        ,   column_value                  => p_PRICE_LIST_rec.attribute8
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'ATTRIBUTE9'
        ,   column_value                  => p_PRICE_LIST_rec.attribute9
        );
        FND_FLEX_DESC_VAL.Set_Column_Value
        (   column_name                   => 'CONTEXT'
        ,   column_value                  => p_PRICE_LIST_rec.context
        );
*/

        --  Validate descriptive flexfield.

        IF NOT QP_Validate.Desc_Flex( 'PRICE_LIST' ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;

    --  Done validating attributes

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Attributes'
            );
        END IF;

END Attributes;

--  Procedure Entity_Delete

PROCEDURE Entity_Delete
(   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_PRICE_LIST_rec                IN  QP_Price_List_PUB.Price_List_Rec_Type
)
IS
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

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

        IF oe_msg_pub.Check_Msg_Level(oe_msg_pub.G_MSG_LVL_UNEXP_ERROR)
        THEN
            oe_msg_pub.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Entity_Delete'
            );
        END IF;

END Entity_Delete;

END QP_Validate_Price_List;

/
