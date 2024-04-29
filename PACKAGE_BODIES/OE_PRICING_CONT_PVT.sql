--------------------------------------------------------
--  DDL for Package Body OE_PRICING_CONT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICING_CONT_PVT" AS
/* $Header: OEXVPRCB.pls 120.3 2005/07/07 05:33:13 appldev ship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_Pricing_Cont_PVT';

FUNCTION Check_Delete_Agreement( p_Price_List_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION Check_Order_Agreement( p_Agreement_id IN NUMBER)
RETURN BOOLEAN;

FUNCTION Check_Order_Lines_Agreement( p_Agreement_id IN NUMBER)
RETURN BOOLEAN;
--  Contract
-- This procedure is no longer used
/*
PROCEDURE Contract
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Contract_rec                  OUT NOCOPY OE_Pricing_Cont_PUB.Contract_Rec_Type --file.sql.39 change
,   x_old_Contract_rec              OUT NOCOPY OE_Pricing_Cont_PUB.Contract_Rec_Type --file.sql.39 change
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type := p_Contract_rec;
l_old_Contract_rec            OE_Pricing_Cont_PUB.Contract_Rec_Type := p_old_Contract_rec;
l_p_Contract_rec	      OE_Pricing_Cont_PUB.Contract_Rec_Type; --[prarasto]
BEGIN

    oe_debug_pub.add('------------------------------------------------');
    oe_debug_pub.add('Entering Contract');

    --  Load API control record

    l_control_rec := OE_GLOBALS.Init_Control_Rec
    (   p_operation     => l_Contract_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_Contract_rec.return_status   := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_Contract_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        l_Contract_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_Contract_rec :=
        OE_Contract_Util.Convert_Miss_To_Null (l_old_Contract_rec);

    ELSIF (l_Contract_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR    l_Contract_rec.operation = OE_GLOBALS.G_OPR_DELETE )
    THEN

        l_Contract_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_Contract_rec.pricing_contract_id = FND_API.G_MISS_NUM
        THEN

            l_old_Contract_rec := OE_Contract_Util.Query_Row
            (   p_pricing_contract_id         => l_Contract_rec.pricing_contract_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_Contract_rec :=
            OE_Contract_Util.Convert_Miss_To_Null (l_old_Contract_rec);

        END IF;

        --  Complete new record from old

        l_Contract_rec := OE_Contract_Util.Complete_Record
        (   p_Contract_rec                => l_Contract_rec
        ,   p_old_Contract_rec            => l_old_Contract_rec
        );

    END IF;

IF ( l_contract_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR l_contract_rec.operation = OE_GLOBALS.G_OPR_CREATE
    OR l_contract_rec.operation = OE_GLOBALS.G_OPR_DELETE)  THEN

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            OE_Validate_Contract.Attributes
            (   x_return_status               => l_return_status
            ,   p_Contract_rec                => l_Contract_rec
            ,   p_old_Contract_rec            => l_old_Contract_rec
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN

        l_p_Contract_rec := l_Contract_rec; --[prarasto]

        OE_Contract_Util.Clear_Dependent_Attr
        (   p_Contract_rec                => l_p_Contract_rec
        ,   p_old_Contract_rec            => l_old_Contract_rec
        ,   x_Contract_rec                => l_Contract_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        l_p_Contract_rec := l_Contract_rec; --[prarasto]

        OE_Default_Contract.Attributes
        (   p_Contract_rec                => l_p_Contract_rec
        ,   x_Contract_rec                => l_Contract_rec
        );


    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN


        l_p_Contract_rec := l_Contract_rec; --[prarasto]

        OE_Contract_Util.Apply_Attribute_Changes
        (   p_Contract_rec                => l_p_Contract_rec
        ,   p_old_Contract_rec            => l_old_Contract_rec
        ,   x_Contract_rec                => l_Contract_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_Contract_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Validate_Contract.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_Contract_rec                => l_Contract_rec
            );

        ELSE

            OE_Validate_Contract.Entity
            (   x_return_status               => l_return_status
            ,   p_Contract_rec                => l_Contract_rec
            ,   p_old_Contract_rec            => l_old_Contract_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_Contract_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Contract_Util.Delete_Row
            (   p_pricing_contract_id         => l_Contract_rec.pricing_contract_id
            );

        ELSE

            --  Get Who Information

            l_Contract_rec.last_update_date := SYSDATE;
            l_Contract_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_Contract_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_Contract_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                OE_Contract_Util.Update_Row (l_Contract_rec);

            ELSIF l_Contract_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                l_Contract_rec.creation_date   := SYSDATE;
                l_Contract_rec.created_by      := FND_GLOBAL.USER_ID;

                OE_Contract_Util.Insert_Row (l_Contract_rec);

            END IF;

        END IF;

    END IF;
END IF;
    --  Load OUT parameters

    x_Contract_rec                 := l_Contract_rec;
    x_old_Contract_rec             := l_old_Contract_rec;

    oe_debug_pub.add('Exiting Contract');
    oe_debug_pub.add('------------------------------------------------');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_Contract_rec.return_status   := FND_API.G_RET_STS_ERROR;
        x_Contract_rec                 := l_Contract_rec;
        x_old_Contract_rec             := l_old_Contract_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_Contract_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Contract_rec                 := l_Contract_rec;
        x_old_Contract_rec             := l_old_Contract_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Contract'
            );
        END IF;

        l_Contract_rec.return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Contract_rec                 := l_Contract_rec;
        x_old_Contract_rec             := l_old_Contract_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Contract;
-- End Procedure not required
*/

/*commented this and exposed this procedure in the specification for agreements upgrade
PROCEDURE Create_Agreement_Qualifier
			(p_list_header_id IN NUMBER,
			 p_old_list_header_id IN NUMBER,
			 p_Agreement_id IN NUMBER,
			 p_operation IN VARCHAR2,
			 x_return_status OUT NOCOPY VARCHAR2); --file.sql.39 change
			 */

--  Agreement

PROCEDURE Agreement
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_old_Agreement_rec             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_Agreement_Delete_Flag  BOOLEAN;
l_Agreement_Lines_Delete_Flag  BOOLEAN;
l_Price_List_Exists_Flag  BOOLEAN;
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
--l_control_rec                 QP_GLOBALS.Control_Rec_Type;
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type := p_Agreement_rec;
l_old_Agreement_rec           OE_Pricing_Cont_PUB.Agreement_Rec_Type := p_old_Agreement_rec;
l_old_price_list_id			QP_LIST_HEADERS_B.LIST_HEADER_ID%TYPE;
l_count_agr_qual			NUMBER;

/* For creating qualifiers */
l_price_list_type_code     QP_LIST_HEADERS_B.LIST_TYPE_CODE%TYPE;
l_QUALIFIERS_tbl		  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_QUALIFIERS_val_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_QUALIFIERS_rec		  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;

l_x_QUALIFIERS_tbl		  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_x_QUALIFIERS_val_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_x_QUALIFIERS_rec		  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_x_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_x_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
l_return_values	VARCHAR2(1) := FND_API.G_FALSE;
l_commit  VARCHAR2(1) := FND_API.G_FALSE;
l_msg_count    NUMBER;
l_msg_data    VARCHAR2(250);

l_p_Agreement_rec	OE_Pricing_Cont_PUB.Agreement_Rec_Type; --[prarasto]
BEGIN

    oe_debug_pub.add('------------------------------------------------');
    oe_debug_pub.add('Entering Agreement');

    --  Load API control record

    l_control_rec := OE_GLOBALS.Init_Control_Rec
    (   p_operation     => l_Agreement_rec.operation
    ,   p_control_rec   => p_control_rec
    );

    --  Set record return status.

    l_Agreement_rec.return_status  := FND_API.G_RET_STS_SUCCESS;

    --  Prepare record.

    IF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        l_Agreement_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_Agreement_rec :=
        OE_Agreement_Util.Convert_Miss_To_Null (l_old_Agreement_rec);

    ELSIF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR    l_Agreement_rec.operation = OE_GLOBALS.G_OPR_DELETE
    THEN

        l_Agreement_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_Agreement_rec.agreement_id = FND_API.G_MISS_NUM
        THEN

            l_old_Agreement_rec := OE_Agreement_Util.Query_Row
            (   p_agreement_id                => l_Agreement_rec.agreement_id
            );

        ELSE

            --  Set missing old record elements to NULL.

            l_old_Agreement_rec :=
            OE_Agreement_Util.Convert_Miss_To_Null (l_old_Agreement_rec);

        END IF;

        --  Complete new record from old




        l_Agreement_rec := OE_Agreement_Util.Complete_Record
        (   p_Agreement_rec               => l_Agreement_rec
        ,   p_old_Agreement_rec           => l_old_Agreement_rec
        );

    END IF;

IF ( l_agreement_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR l_agreement_rec.operation = OE_GLOBALS.G_OPR_CREATE
    OR l_agreement_rec.operation = OE_GLOBALS.G_OPR_DELETE)  THEN

    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            OE_Validate_Agreement.Attributes
            (   x_return_status               => l_return_status
            ,   p_Agreement_rec               => l_Agreement_rec
            ,   p_old_Agreement_rec           => l_old_Agreement_rec
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.

    IF  l_control_rec.change_attributes THEN

        l_p_Agreement_rec := l_Agreement_rec; --[prarasto]

        OE_Agreement_Util.Clear_Dependent_Attr
        (   p_Agreement_rec               => l_p_Agreement_rec
        ,   p_old_Agreement_rec           => l_old_Agreement_rec
        ,   x_Agreement_rec               => l_Agreement_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        l_p_Agreement_rec := l_Agreement_rec; --[prarasto]

        OE_Default_Agreement.Attributes
        (   p_Agreement_rec               => l_p_Agreement_rec
        ,   x_Agreement_rec               => l_Agreement_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

/*change made by spgopal 08/14/00 for duplicate qualifiers when updating
	price list info on agreement*/

		oe_debug_pub.add('old_list_id'||to_char(l_old_agreement_rec.price_list_id)||'new_list_id'||to_char(l_agreement_rec.price_list_id));

	l_old_price_list_id := l_old_Agreement_rec.price_list_id;

        l_p_Agreement_rec := l_Agreement_rec; --[prarasto]

        OE_Agreement_Util.Apply_Attribute_Changes
        (   p_Agreement_rec               => l_p_Agreement_rec
        ,   p_old_Agreement_rec           => l_old_Agreement_rec
        ,   x_Agreement_rec               => l_Agreement_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Validate_Agreement.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_Agreement_rec               => l_Agreement_rec
            );

        ELSE

	    IF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_CREATE then

            OE_Validate_Agreement.Entity
            (   x_return_status               => l_return_status
            ,   p_Agreement_rec               => l_Agreement_rec
            ,   p_old_Agreement_rec           => l_old_Agreement_rec
            );
	    END if;

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN


        /* Check the price List associated with an agreement */
      /* Bug 2321498 Commented following code as price List should not be deleted */
   /*
    oe_debug_pub.add('Geresh Before Check Delete Agreement');
		  if NOT ( Check_Delete_Agreement( p_Price_List_id => l_Agreement_rec.price_list_id )) THEN
				l_Price_List_Exists_Flag := FALSE;
		  else
				l_Price_List_Exists_Flag := TRUE;

		  end if;

     oe_debug_pub.add('Geresh After Check Delete Agreement'); */
    /* Bug 2321498 : Added following line to always set the flag to false */
                 l_Price_List_Exists_Flag := TRUE;


		  /* Check to see if an agreement used an in an Order */

       	if NOT ( Check_Order_Agreement(p_Agreement_id => l_Agreement_rec.agreement_id)) THEN
			l_Agreement_Delete_Flag := FALSE;
	  	else
			l_Agreement_Delete_Flag := TRUE;
	  	end if;

/* Check to see Agreement Used in Order Lines */
       	if NOT ( Check_Order_Lines_Agreement(p_Agreement_id => l_Agreement_rec.agreement_id)) THEN
			l_Agreement_Lines_Delete_Flag := FALSE;
	  	else
			l_Agreement_Lines_Delete_Flag := TRUE;
	  	end if;

            OE_Agreement_Util.Delete_Row
            (         x_return_status              => l_return_status
                  ,   p_agreement_id                => l_Agreement_rec.agreement_id
		  ,   p_Price_List_Exists_Flag     => l_Price_list_Exists_Flag
		  ,   p_Agreement_Delete_Flag      => l_Agreement_Delete_Flag
		  ,   p_Agreement_Lines_Delete_Flag      => l_Agreement_Lines_Delete_Flag
            );
            /* Added following code for bug 2321498 */

              IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              END IF;

        ELSE

            --  Get Who Information

            l_Agreement_rec.last_update_date := SYSDATE;
            l_Agreement_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_Agreement_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                OE_Agreement_Util.Update_Row (l_Agreement_rec);
-- update agreement qualifier

/*Changes made by spgopal for AGR fix conditionally create qualifiers 08/14/00*/

                begin --Begin, Exception and End stmts added for OKC
		select list_type_code into l_price_list_type_code from
				qp_list_headers_vl where
				list_header_id = l_Agreement_rec.price_list_id;
                exception
                  when others then
                    l_price_list_type_code := NULL;
                end;


				IF l_price_list_type_code = 'AGR' THEN

				--Create agreement qualifier for AGR type price lists only

				oe_debug_pub.add('before update create_agr_qual');


				Create_Agreement_Qualifier(l_Agreement_rec.price_list_id
								 ,l_old_price_list_id
								 ,l_Agreement_rec.Agreement_id
								 ,l_Agreement_rec.Operation
								 ,l_return_status);

				oe_debug_pub.add('after update create_agr_qual');

        				IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        				ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            				RAISE FND_API.G_EXC_ERROR;
        				END IF;

				END IF;

            --END IF;

            ELSIF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                l_Agreement_rec.creation_date  := SYSDATE;
                l_Agreement_rec.created_by     := FND_GLOBAL.USER_ID;

                OE_Agreement_Util.Insert_Row (l_Agreement_rec);


/*Changes made by spgopal for AGR fix conditionally create qualifiers 08/14/00*/

                              begin --Begin, Exception and End added for OKC
				select list_type_code into l_price_list_type_code from
				qp_list_headers_vl where
				list_header_id = l_Agreement_rec.price_list_id;
                              exception
                                when others then
                                  l_price_list_type_code := NULL;
                              end;



				IF l_price_list_type_code = 'AGR' THEN

					--Create agreement qualifier for AGR type price lists only

					oe_debug_pub.add('before insert create_agr_qual');

					Create_Agreement_Qualifier(l_Agreement_rec.price_list_id
								 ,l_old_price_list_id
								 ,l_Agreement_rec.Agreement_id
								 ,l_Agreement_rec.Operation
								 ,l_return_status);

					oe_debug_pub.add('after insert create_agr_qual');
				END IF;

            END IF;

	    	  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    		        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    		  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    		        RAISE FND_API.G_EXC_ERROR;
    		  END IF;


		/* Creating a quaklifier for a price list */

/*Changes made by spgopal for AGR fix conditionally create qualifiers 08/10/00*/

/*
		select list_type_code into l_price_list_type_code from
				qp_list_headers_vl where
				list_header_id = l_Agreement_rec.price_list_id;


			IF l_price_list_type_code = 'AGR' THEN

			--Create agreement qualifier for AGR type price lists only

			null;

*/

/*changes made by spgopal 08/14/00 included the foll in procedure create_agreement_qualifier below*/
/*
		   l_qualifiers_rec.list_header_id := l_Agreement_rec.price_list_id ;
		   l_qualifiers_rec.qualifier_attr_value := l_Agreement_rec.agreement_id;
		   l_qualifiers_rec.qualifier_context := 'CUSTOMER';
		   l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE7';
		   l_qualifiers_rec.operation := OE_GLOBALS.G_OPR_CREATE;

	   l_qualifiers_rec.qualifier_grouping_no := l_Agreement_rec.agreement_id;


		   l_qualifiers_rec.operation := OE_GLOBALS.G_OPR_CREATE;
		   l_qualifiers_tbl(1) := l_qualifiers_rec;

		 QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
		   (     p_api_version_number =>	1.0
		   	,   p_init_msg_list		=> FND_API.G_TRUE
			,   p_validation_level          => FND_API.G_VALID_LEVEL_FULL
			,   p_commit			=> FND_API.G_FALSE
			,   x_return_status		=> l_return_status
			,   x_msg_count 		=> l_msg_count
			,   x_msg_data			=> l_msg_data
			,   p_control_rec               => l_control_rec
			,   p_QUALIFIER_RULES_rec	=> l_QUALIFIER_RULES_rec
--			,   p_QUALIFIER_RULES_val_rec	=> l_QUALIFIER_RULES_val_rec
			,   p_QUALIFIERS_tbl  		=> l_QUALIFIERS_tbl
--			,   p_QUALIFIERS_val_tbl	=> l_QUALIFIERS_val_tbl
			,   x_QUALIFIER_RULES_rec	=> l_x_QUALIFIER_RULES_rec
--			,   x_QUALIFIER_RULES_val_rec	=> l_x_QUALIFIER_RULES_val_rec
			,   x_QUALIFIERS_tbl		=>  l_x_QUALIFIERS_tbl
--			,   x_QUALIFIERS_val_tbl	=>  l_x_QUALIFIERS_val_tbl
   		);
*/

		null;

		END IF;

	     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    		        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    		ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
    		        RAISE FND_API.G_EXC_ERROR;
    		END IF;


        END IF;

 --   END IF;
END IF;
    --  Load OUT parameters

    x_Agreement_rec                := l_Agreement_rec;
    x_old_Agreement_rec            := l_old_Agreement_rec;

    oe_debug_pub.add('Exiting Agreement');
    oe_debug_pub.add('------------------------------------------------');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_Agreement_rec.return_status  := FND_API.G_RET_STS_ERROR;
        x_Agreement_rec                := l_Agreement_rec;
        x_old_Agreement_rec            := l_old_Agreement_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_Agreement_rec.return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Agreement_rec                := l_Agreement_rec;
        x_old_Agreement_rec            := l_old_Agreement_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Agreement'
            );
        END IF;

        l_Agreement_rec.return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Agreement_rec                := l_Agreement_rec;
        x_old_Agreement_rec            := l_old_Agreement_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Agreement;

--  Price_Lheader

PROCEDURE Price_Lheader
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type
,   p_old_Price_LHeader_rec         IN  OE_Price_List_PUB.Price_List_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_old_Price_LHeader_rec         OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type := p_Price_LHeader_rec;
l_old_Price_LHeader_rec       OE_Price_List_PUB.Price_List_Rec_Type := p_old_Price_LHeader_rec;

l_p_Price_LHeader_rec	      OE_Price_List_PUB.Price_List_Rec_Type; --[prarasto]
BEGIN


    oe_debug_pub.add('------------------------------------------------');
    oe_debug_pub.add('Entering Price_LHeader');
    --  Load API control record

    l_control_rec := OE_GLOBALS.Init_Control_Rec
    (   p_operation     => l_Price_LHeader_rec.operation
    ,   p_control_rec   => p_control_rec
    );
    l_Price_LHeader_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    --  Set record return status.


    --  Prepare record.

    IF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

        l_Price_LHeader_rec.db_flag := FND_API.G_FALSE;

        --  Set missing old record elements to NULL.

        l_old_Price_LHeader_rec :=
        OE_Price_List_Util.Convert_Miss_To_Null (l_old_Price_LHeader_rec);

    ELSIF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR    l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_DELETE
    THEN

        l_Price_LHeader_rec.db_flag := FND_API.G_TRUE;

        --  Query Old if missing

        IF  l_old_Price_LHeader_rec.name = FND_API.G_MISS_CHAR
        OR  l_old_Price_LHeader_rec.price_list_id = FND_API.G_MISS_NUM
        THEN

           l_old_Price_LHeader_rec := OE_Price_List_Util.Query_Row
            (  p_name	                      => l_Price_LHeader_rec.name ,
               p_price_list_id               => l_Price_LHeader_rec.price_list_id
            );

         ELSE

            --  Set missing old record elements to NULL.

            l_old_Price_LHeader_rec :=
            OE_Price_List_Util.Convert_Miss_To_Null (l_old_Price_LHeader_rec);

        END IF;

        --  Complete new record from old

        l_Price_LHeader_rec := OE_Price_List_Util.Complete_Record
        (   p_PRICE_LIST_rec           => l_Price_LHeader_rec
        ,   p_old_PRICE_LIST_rec       => l_old_Price_LHeader_rec
        );

    END IF;


IF ( l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_CREATE
    OR l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_DELETE)  THEN
    --  Attribute level validation.

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

            OE_Validate_Price_List.Attributes
            (   x_return_status               => l_return_status
            ,   p_Price_LIST_rec           => l_Price_LHeader_rec
            ,   p_old_Price_LIST_rec       => l_old_Price_LHeader_rec
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

    END IF;

        --  Clear dependent attributes.
    IF  l_control_rec.change_attributes THEN

        l_p_Price_LHeader_rec := l_Price_LHeader_rec; --[prarasto]

        OE_Price_List_Util.Clear_Dependent_Attr
        (   p_Price_list_rec           => l_p_Price_LHeader_rec
        ,   p_old_Price_list_rec       => l_old_Price_LHeader_rec
        ,   x_Price_list_rec           => l_Price_LHeader_rec
        );

    END IF;

    --  Default missing attributes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        l_p_Price_LHeader_rec := l_Price_LHeader_rec; --[prarasto]

        OE_Default_Price_List.Attributes
        (   p_Price_list_rec           => l_p_Price_LHeader_rec
        ,   x_Price_list_rec           => l_Price_LHeader_rec
        );

    END IF;

    --  Apply attribute changes

    IF  l_control_rec.default_attributes
    OR  l_control_rec.change_attributes
    THEN

        l_p_Price_LHeader_rec := l_Price_LHeader_rec; --[prarasto]

        OE_Price_List_Util.Apply_Attribute_Changes
        (   p_Price_LIST_rec           => l_p_Price_LHeader_rec
        ,   p_old_Price_list_rec       => l_old_Price_LHeader_rec
        ,   x_Price_list_rec           => l_Price_LHeader_rec
        );

    END IF;

    --  Entity level validation.

    IF l_control_rec.validate_entity THEN

        IF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Validate_Price_List.Entity_Delete
            (   x_return_status               => l_return_status
            ,   p_Price_list_rec           => l_Price_LHeader_rec
            );

        ELSE

            OE_Validate_Price_List.Entity
            (   x_return_status               => l_return_status
            ,   p_Price_list_rec           => l_Price_LHeader_rec
            ,   p_old_Price_list_rec       => l_old_Price_LHeader_rec
            );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF;

    --  Step 4. Write to DB

    IF l_control_rec.write_to_db THEN

        IF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

            OE_Price_List_Util.Delete_Row
           ( p_name			    => l_Price_LHeader_rec.name,
             p_price_list_id               => l_Price_LHeader_rec.price_list_id
            );

        ELSE

            --  Get Who Information

            l_Price_LHeader_rec.last_update_date := SYSDATE;
            l_Price_LHeader_rec.last_updated_by := FND_GLOBAL.USER_ID;
            l_Price_LHeader_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

            IF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                OE_Price_List_Util.Update_Row (l_Price_LHeader_rec);

            ELSIF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                l_Price_LHeader_rec.creation_date := SYSDATE;
                l_Price_LHeader_rec.created_by := FND_GLOBAL.USER_ID;

                OE_Price_List_Util.Insert_Row (l_Price_LHeader_rec);

            END IF;

        END IF;

    END IF;

END IF;
    --  Load OUT parameters

    x_Price_LHeader_rec            := l_Price_LHeader_rec;
    x_old_Price_LHeader_rec        := l_old_Price_LHeader_rec;

    oe_debug_pub.add('Exiting Price_LHeader');
    oe_debug_pub.add('------------------------------------------------');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        l_Price_LHeader_rec.return_status := FND_API.G_RET_STS_ERROR;
        x_Price_LHeader_rec            := l_Price_LHeader_rec;
        x_old_Price_LHeader_rec        := l_old_Price_LHeader_rec;
        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        l_Price_LHeader_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Price_LHeader_rec            := l_Price_LHeader_rec;
        x_old_Price_LHeader_rec        := l_old_Price_LHeader_rec;

        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Lheader'
            );
        END IF;

        l_Price_LHeader_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Price_LHeader_rec            := l_Price_LHeader_rec;
        x_old_Price_LHeader_rec        := l_old_Price_LHeader_rec;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Lheader;


--  Price_Llines

PROCEDURE Price_Llines
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_Price_LLine_tbl               IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   p_old_Price_LLine_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_old_Price_LLine_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_Price_LLine_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_Price_LLine_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;

l_p_Price_LLine_rec	      OE_Price_List_PUB.Price_List_Line_Rec_Type; --[prarasto]

BEGIN

    oe_debug_pub.add('------------------------------------------------');
    oe_debug_pub.add('Entering Price_LLines');

    --  Init local table variables.

    l_Price_LLine_tbl              := p_Price_LLine_tbl;
    l_old_Price_LLine_tbl          := p_old_Price_LLine_tbl;

    oe_debug_pub.add('No of Records in Price_List_Lines table : ' || to_char(l_Price_LLine_tbl.COUNT));

    FOR I IN 1..l_Price_LLine_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_Price_LLine_rec := l_Price_LLine_tbl(I);

        IF l_old_Price_LLine_tbl.EXISTS(I) THEN
            l_old_Price_LLine_rec := l_old_Price_LLine_tbl(I);
        ELSE
            l_old_Price_LLine_rec := OE_Price_List_PUB.G_MISS_PRICE_List_Line_REC;
        END IF;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Price_LLine_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Price_LLine_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Price_LLine_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_Price_LLine_rec :=
            OE_Price_List_Line_Util.Convert_Miss_To_Null (l_old_Price_LLine_rec);

        ELSIF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Price_LLine_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Price_LLine_rec.price_list_line_id = FND_API.G_MISS_NUM
            THEN

                l_old_Price_LLine_rec := OE_Price_List_Line_Util.Query_Row
                (   p_price_list_line_id          => l_Price_LLine_rec.price_list_line_id
                ,   p_price_list_id          => l_Price_LLine_rec.price_list_id
                );

            ELSE

                --  Set missing old record elements to NULL.

                l_old_Price_LLine_rec :=
                OE_Price_List_Line_Util.Convert_Miss_To_Null (l_old_Price_LLine_rec);

            END IF;

            --  Complete new record from old

            l_Price_LLine_rec := OE_Price_List_Line_Util.Complete_Record
            (   p_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
            ,   p_old_PRICE_LIST_LINE_rec         => l_old_Price_LLine_rec
            );

        END IF;

IF ( l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_UPDATE
    OR l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_CREATE
    OR l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_DELETE)  THEN
        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Price_List_Line.Attributes
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
                ,   p_old_PRICE_LIST_LINE_rec         => l_old_Price_LLine_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN

	    l_p_Price_LLine_rec := l_Price_LLine_rec; --[prarasto]

            OE_Price_List_Line_Util.Clear_Dependent_Attr
            (   p_PRICE_LIST_LINE_rec             => l_p_Price_LLine_rec
            ,   p_old_PRICE_LIST_LINE_rec         => l_old_Price_LLine_rec
            ,   x_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
            );

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

	    l_p_Price_LLine_rec := l_Price_LLine_rec; --[prarasto]

            OE_Default_Price_List_Line.Attributes
            (   p_PRICE_LIST_LINE_rec             => l_p_Price_LLine_rec
            ,   x_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

	    l_p_Price_LLine_rec := l_Price_LLine_rec; --[prarasto]

            OE_Price_List_Line_Util.Apply_Attribute_Changes
            (   p_PRICE_LIST_LINE_rec             => l_p_Price_LLine_rec
            ,   p_old_PRICE_LIST_LINE_rec         => l_old_Price_LLine_rec
            ,   x_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Validate_Price_List_Line.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
                );

            ELSE

                OE_Validate_Price_List_Line.Entity
                (   x_return_status               => l_return_status
                ,   p_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
                ,   p_old_PRICE_LIST_LINE_rec         => l_old_Price_LLine_rec
                );

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

                OE_Price_List_Line_Util.Delete_Row
                (   p_price_list_line_id          => l_Price_LLine_rec.price_list_line_id
                );

            ELSE

                --  Get Who Information

                l_Price_LLine_rec.last_update_date := SYSDATE;
                l_Price_LLine_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Price_LLine_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

                    OE_Price_List_Line_Util.Update_Row (l_Price_LLine_rec);

                ELSIF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Price_LLine_rec.creation_date := SYSDATE;
                    l_Price_LLine_rec.created_by   := FND_GLOBAL.USER_ID;


                    OE_Price_List_Line_Util.Insert_Row (l_Price_LLine_rec );


                END IF;

            END IF;

        END IF;

END IF;
        --  Load tables.

        l_Price_LLine_tbl(I)           := l_Price_LLine_rec;
        l_old_Price_LLine_tbl(I)       := l_old_Price_LLine_rec;

    --  For loop exception handler.

    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Price_LLine_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_Price_LLine_tbl(I)           := l_Price_LLine_rec;
            l_old_Price_LLine_tbl(I)       := l_old_Price_LLine_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Price_LLine_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Price_LLine_tbl(I)           := l_Price_LLine_rec;
            l_old_Price_LLine_tbl(I)       := l_old_Price_LLine_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Price_LLine_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Price_LLine_tbl(I)           := l_Price_LLine_rec;
            l_old_Price_LLine_tbl(I)       := l_old_Price_LLine_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Price_Llines'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_Price_LLine_tbl              := l_Price_LLine_tbl;
    x_old_Price_LLine_tbl          := l_old_Price_LLine_tbl;

    oe_debug_pub.add('Exiting Price_LLines');
    oe_debug_pub.add('------------------------------------------------');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Llines'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Llines;

--  Price_Breaks

PROCEDURE Price_Breaks
(   p_validation_level              IN  NUMBER
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type
,   p_Price_Break_tbl               IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
,   p_old_Price_Break_tbl           IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
,   x_old_Price_Break_tbl           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
)
IS
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_old_Price_Break_rec         OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_old_Price_Break_tbl         OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;

l_p_Price_Break_rec	      OE_Pricing_Cont_PUB.Price_Break_Rec_Type; --[prarasto]

BEGIN

    oe_debug_pub.add('------------------------------------------------');
    oe_debug_pub.add('Entering Price_Breaks');

    --  Init local table variables.

    l_Price_Break_tbl              := p_Price_Break_tbl;
    l_old_Price_Break_tbl          := p_old_Price_Break_tbl;

    FOR I IN 1..l_Price_Break_tbl.COUNT LOOP
    BEGIN

        --  Load local records.

        l_Price_Break_rec := l_Price_Break_tbl(I);

        IF l_old_Price_Break_tbl.EXISTS(I) THEN
            l_old_Price_Break_rec := l_old_Price_Break_tbl(I);
        ELSE
            l_old_Price_Break_rec := OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_REC;
        END IF;

        --  Load API control record

        l_control_rec := OE_GLOBALS.Init_Control_Rec
        (   p_operation     => l_Price_Break_rec.operation
        ,   p_control_rec   => p_control_rec
        );

        --  Set record return status.

        l_Price_Break_rec.return_status := FND_API.G_RET_STS_SUCCESS;

        --  Prepare record.

        IF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

            l_Price_Break_rec.db_flag := FND_API.G_FALSE;

            --  Set missing old record elements to NULL.

            l_old_Price_Break_rec :=
            OE_Price_Break_Util.Convert_Miss_To_Null (l_old_Price_Break_rec);

        ELSIF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_UPDATE
        OR    l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_DELETE
        THEN

            l_Price_Break_rec.db_flag := FND_API.G_TRUE;

            --  Query Old if missing

            IF  l_old_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM
            OR  l_old_Price_Break_rec.method_type_code = FND_API.G_MISS_CHAR
            OR  l_old_Price_Break_rec.price_break_high = FND_API.G_MISS_NUM
            OR  l_old_Price_Break_rec.price_break_low = FND_API.G_MISS_NUM
            THEN
NULL;
/*
                l_old_Price_Break_rec := OE_Price_Break_Util.Query_Row
                (   p_discount_line_id  => l_Price_Break_rec.discount_line_id
			 ,   p_method_type_code  => l_Price_Break_rec.method_type_code
			 ,   p_price_break_high  => l_Price_Break_rec.price_break_high
			 ,   p_price_break_low   => l_Price_Break_rec.price_break_low
                );
*/

            ELSE

                --  Set missing old record elements to NULL.
				null;
/*
                l_old_Price_Break_rec :=
                OE_Price_Break_Util.Convert_Miss_To_Null (l_old_Price_Break_rec);
*/

            END IF;

            --  Complete new record from old
/*
            l_Price_Break_rec := OE_Price_Break_Util.Complete_Record
            (   p_Price_Break_rec             => l_Price_Break_rec
            ,   p_old_Price_Break_rec         => l_old_Price_Break_rec
            );
*/

        END IF;

        --  Attribute level validation.

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            IF p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

                OE_Validate_Price_Break.Attributes
                (   x_return_status               => l_return_status
                ,   p_Price_Break_rec             => l_Price_Break_rec
                ,   p_old_Price_Break_rec         => l_old_Price_Break_rec
                );

                IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            END IF;

        END IF;

            --  Clear dependent attributes.

        IF  l_control_rec.change_attributes THEN
			NULL;

/*
	    l_p_Price_Break_rec := l_Price_Break_rec; --[prarasto]

            OE_Price_Break_Util.Clear_Dependent_Attr
            (   p_Price_Break_rec             => l_p_Price_Break_rec
            ,   p_old_Price_Break_rec         => l_old_Price_Break_rec
            ,   x_Price_Break_rec             => l_Price_Break_rec
            );
*/

        END IF;

        --  Default missing attributes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

	    l_p_Price_Break_rec := l_Price_Break_rec; --[prarasto]

            OE_Default_Price_Break.Attributes
            (   p_Price_Break_rec             => l_p_Price_Break_rec
            ,   x_Price_Break_rec             => l_Price_Break_rec
            );

        END IF;

        --  Apply attribute changes

        IF  l_control_rec.default_attributes
        OR  l_control_rec.change_attributes
        THEN

            OE_Price_Break_Util.Apply_Attribute_Changes
            (   p_Price_Break_rec             => l_Price_Break_rec
            ,   p_old_Price_Break_rec         => l_old_Price_Break_rec
            ,   x_Price_Break_rec             => l_Price_Break_rec
            );

        END IF;

        --  Entity level validation.

        IF l_control_rec.validate_entity THEN

            IF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN
/*
                OE_Validate_Price_Break.Entity_Delete
                (   x_return_status               => l_return_status
                ,   p_Price_Break_rec             => l_Price_Break_rec
                );
*/
		NULL;

            ELSE
			NULL;
/*
                OE_Validate_Price_Break.Entity
                (   x_return_status               => l_return_status
                ,   p_Price_Break_rec             => l_Price_Break_rec
                ,   p_old_Price_Break_rec         => l_old_Price_Break_rec
                );
*/

            END IF;

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        END IF;

        --  Step 4. Write to DB

        IF l_control_rec.write_to_db THEN

            IF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_DELETE THEN

			NULL;
/*		OE_Price_Break_Util.Delete_Row
	   (   p_discount_line_id     => l_Price_Break_rec.discount_line_id
	      , p_method_type_code     => l_Price_Break_rec.method_type_code
	      ,   p_price_break_high     => l_Price_Break_rec.price_break_high
	      ,   p_price_break_low      => l_Price_Break_rec.price_break_low
	   ) ;
*/
			NULL;


            ELSE

                --  Get Who Information

                l_Price_Break_rec.last_update_date := SYSDATE;
                l_Price_Break_rec.last_updated_by := FND_GLOBAL.USER_ID;
                l_Price_Break_rec.last_update_login := FND_GLOBAL.LOGIN_ID;

                IF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_UPDATE THEN

			NULL;
/*
                  OE_Price_Break_Util.Update_Row (l_Price_Break_rec);
*/
                ELSIF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_CREATE THEN

                    l_Price_Break_rec.creation_date := SYSDATE;
                    l_Price_Break_rec.created_by   := FND_GLOBAL.USER_ID;
/*
                    OE_Price_Break_Util.Insert_Row (l_Price_Break_rec);
*/

                END IF;

            END IF;

        END IF;

        --  Load tables.

        l_Price_Break_tbl(I)           := l_Price_Break_rec;
        l_old_Price_Break_tbl(I)       := l_old_Price_Break_rec;

    --  For loop exception handler.


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN

            l_Price_Break_rec.return_status := FND_API.G_RET_STS_ERROR;
            l_Price_Break_tbl(I)           := l_Price_Break_rec;
            l_old_Price_Break_tbl(I)       := l_old_Price_Break_rec;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            l_Price_Break_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Price_Break_tbl(I)           := l_Price_Break_rec;
            l_old_Price_Break_tbl(I)       := l_old_Price_Break_rec;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        WHEN OTHERS THEN

            l_Price_Break_rec.return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            l_Price_Break_tbl(I)           := l_Price_Break_rec;
            l_old_Price_Break_tbl(I)       := l_old_Price_Break_rec;

            IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                OE_MSG_PUB.Add_Exc_Msg
                (   G_PKG_NAME
                ,   'Price_Breaks'
                );
            END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END;
    END LOOP;

    --  Load OUT parameters

    x_Price_Break_tbl              := l_Price_Break_tbl;
    x_old_Price_Break_tbl          := l_old_Price_Break_tbl;

    oe_debug_pub.add('Exiting Price_Breaks');
    oe_debug_pub.add('------------------------------------------------');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        RAISE;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        RAISE;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Price_Breaks'
            );
        END IF;


        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Price_Breaks;

--  Start of Comments
--  API name    Process_Pricing_Cont
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Process_Pricing_Cont
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_commit                        IN  VARCHAR2 := FND_API.G_FALSE
,   p_validation_level              IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_control_rec                   IN  OE_GLOBALS.Control_Rec_Type :=
                                        OE_GLOBALS.G_MISS_CONTROL_REC
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_old_Contract_rec              IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_old_Agreement_rec             IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_REC
,   p_old_Price_LHeader_rec         IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_REC
,   p_Discount_Header_rec           IN  OE_Pricing_Cont_PUB.Discount_Header_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_HEADER_REC
,   p_old_Discount_Header_rec       IN  OE_Pricing_Cont_PUB.Discount_Header_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_HEADER_REC
,   p_Price_LLine_tbl               IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_Line_TBL
,   p_old_Price_LLine_tbl           IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_Line_TBL
,   p_Discount_Cust_tbl             IN  OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_CUST_TBL
,   p_old_Discount_Cust_tbl         IN  OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_CUST_TBL
,   p_Discount_Line_tbl             IN  OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_LINE_TBL
,   p_old_Discount_Line_tbl         IN  OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_LINE_TBL
,   p_Price_Break_tbl               IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_TBL
,   p_old_Price_Break_tbl           IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_TBL
,   x_Contract_rec                  OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_Discount_Header_rec           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Header_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Discount_Cust_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type
,   x_Discount_Line_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Process_Pricing_Cont';
l_return_status               VARCHAR2(1);
l_control_rec                 OE_GLOBALS.Control_Rec_Type;
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type := p_Contract_rec;
l_old_Contract_rec            OE_Pricing_Cont_PUB.Contract_Rec_Type := p_old_Contract_rec;
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type := p_Agreement_rec;
l_old_Agreement_rec           OE_Pricing_Cont_PUB.Agreement_Rec_Type := p_old_Agreement_rec;
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type := p_Price_LHeader_rec;
l_old_Price_LHeader_rec       OE_Price_List_PUB.Price_List_Rec_Type := p_old_Price_LHeader_rec;
l_Discount_Header_rec         OE_Pricing_Cont_PUB.Discount_Header_Rec_Type := p_Discount_Header_rec;
l_old_Discount_Header_rec     OE_Pricing_Cont_PUB.Discount_Header_Rec_Type := p_old_Discount_Header_rec;
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_old_Price_LLine_rec         OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_old_Price_LLine_tbl         OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_Discount_Cust_rec           OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_Discount_Cust_tbl           OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_old_Discount_Cust_rec       OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_old_Discount_Cust_tbl       OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_Discount_Line_rec           OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_Discount_Line_tbl           OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_old_Discount_Line_rec       OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_old_Discount_Line_tbl       OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_old_Price_Break_rec         OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
l_old_Price_Break_tbl         OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_msg_data 	VARCHAR2(250);

l_msg_count    NUMBER;

/*
l_QUALIFIERS_tbl		  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_QUALIFIERS_val_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_QUALIFIERS_rec		  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;

l_x_QUALIFIERS_tbl		  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_x_QUALIFIERS_val_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_x_QUALIFIERS_rec		  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_x_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_x_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
*/
l_return_values	VARCHAR2(1) := FND_API.G_FALSE;
l_commit  VARCHAR2(1) := FND_API.G_FALSE;
NO_UPDATE_PRIVILEGE           EXCEPTION;

l_p_Agreement_rec	OE_Pricing_Cont_PUB.Agreement_Rec_Type; --[prarasto]
l_p_old_Agreement_rec	OE_Pricing_Cont_PUB.Agreement_Rec_Type; --[prarasto]
l_p_Price_LHeader_rec	OE_Price_List_PUB.Price_List_Rec_Type;  --[prarasto]
l_p_old_Price_LHeader_rec OE_Price_List_PUB.Price_List_Rec_Type;  --[prarasto]
l_p_Price_LLine_tbl	OE_Price_List_PUB.Price_List_Line_Tbl_Type; --[prarasto]
l_p_old_Price_LLine_tbl OE_Price_List_PUB.Price_List_Line_Tbl_Type; --[prarasto]
l_p_Price_Break_tbl	OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;   --[prarasto]
l_p_old_Price_Break_tbl OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;   --[prarasto]

BEGIN


    oe_debug_pub.add('Entring Process_Pricing_Cont');

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    IF p_Agreement_rec.operation = QP_GLOBALS.G_OPR_UPDATE THEN
       -- Check the security privilege
       IF p_Agreement_rec.price_list_id IS NOT NULL
       THEN
          IF QP_security.check_function( p_function_name => QP_Security.G_FUNCTION_UPDATE,
                                       p_instance_type => QP_Security.G_PRICELIST_OBJECT,
                                       p_instance_pk1  => p_Agreement_rec.price_list_id) = 'F'
          THEN
            fnd_message.set_name('QP', 'QP_NO_PRIVILEGE');
            fnd_message.set_token('PRICING_OBJECT', 'Agreement');
            oe_msg_pub.Add;

            RAISE NO_UPDATE_PRIVILEGE;

          END IF;  -- end of check security privilege
       END IF;
    END IF;
    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Init local table variables.

    l_Price_LLine_tbl              := p_Price_LLine_tbl;
    l_old_Price_LLine_tbl          := p_old_Price_LLine_tbl;

    --  Init local table variables.

    l_Discount_Cust_tbl            := p_Discount_Cust_tbl;
    l_old_Discount_Cust_tbl        := p_old_Discount_Cust_tbl;

    --  Init local table variables.

    l_Discount_Line_tbl            := p_Discount_Line_tbl;
    l_old_Discount_Line_tbl        := p_old_Discount_Line_tbl;

    --  Init local table variables.

    l_Price_Break_tbl              := p_Price_Break_tbl;
    l_old_Price_Break_tbl          := p_old_Price_Break_tbl;

-- This procedure not required , oe_pricing_contracts table
-- made obselete

    --  Contract
/*
    Contract
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Contract_rec                => l_Contract_rec
    ,   p_old_Contract_rec            => l_old_Contract_rec
    ,   x_Contract_rec                => l_Contract_rec
    ,   x_old_Contract_rec            => l_old_Contract_rec
    );

    --  Perform Contract group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_CONTRACT)
    THEN

        NULL;

    END IF;

-- end comments :: procedure call made obselete
*/

    --  Load parent key if missing and operation is create.

    IF l_Agreement_rec.operation = OE_GLOBALS.G_OPR_CREATE
    AND (l_Agreement_rec.pricing_contract_id IS NULL OR
        l_Agreement_rec.pricing_contract_id = FND_API.G_MISS_NUM)
    THEN

        --  Copy parent_id.

        l_Agreement_rec.pricing_contract_id := l_Contract_rec.pricing_contract_id;
    END IF;

    if (l_Contract_rec.agreement_Id IS NOT NULL AND l_Contract_rec.agreement_Id <> FND_API.G_MISS_NUM)
    THEN
        l_Agreement_rec.agreement_id := l_Contract_rec.agreement_id;
    END IF;

    --  Agreement

    l_p_Agreement_rec		:= l_Agreement_rec;	--[prarasto]
    l_p_old_Agreement_rec	:= l_old_Agreement_rec; --[prarasto]

    Agreement
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Agreement_rec               => l_p_Agreement_rec
    ,   p_old_Agreement_rec           => l_p_old_Agreement_rec
    ,   x_Agreement_rec               => l_Agreement_rec
    ,   x_old_Agreement_rec           => l_old_Agreement_rec
    );


    --  Perform Agreement group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_AGREEMENT)
    THEN

        NULL;

    END IF;


    oe_debug_pub.add('attribute1 ='||l_Discount_Header_rec.attribute1);

	-- The old logic exists when called from Agreement Form (Screen).

	if   l_Discount_Header_rec.attribute1 <> 'Calling from PUBLIC API' then


    --  Load parent key if missing and operation is create.

   IF l_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_CREATE
       AND (l_Price_LHeader_rec.pricing_contract_id IS NULL OR
           l_Price_LHeader_rec.pricing_contract_id = FND_API.G_MISS_NUM)
    THEN

        --  Copy parent_id.

        l_Price_LHeader_rec.pricing_contract_id := l_Contract_rec.pricing_contract_id;

    END IF;

    --  Price_Lheader

    l_p_Price_LHeader_rec	:= l_Price_LHeader_rec;     --[prarasto]
    l_p_old_Price_LHeader_rec	:= l_old_Price_LHeader_rec; --[prarasto]

    Price_Lheader
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Price_LHeader_rec           => l_p_Price_LHeader_rec
    ,   p_old_Price_LHeader_rec       => l_p_old_Price_LHeader_rec
    ,   x_Price_LHeader_rec           => l_Price_LHeader_rec
    ,   x_old_Price_LHeader_rec       => l_old_Price_LHeader_rec
    );

    --  Perform Price_LHeader group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_PRICE_LHEADER)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    IF l_Discount_Header_rec.operation = OE_GLOBALS.G_OPR_CREATE
    AND (l_Discount_Header_rec.pricing_contract_id IS NULL OR
        l_Discount_Header_rec.pricing_contract_id = FND_API.G_MISS_NUM)
    THEN

        --  Copy parent_id.

        l_Discount_Header_rec.pricing_contract_id := l_Contract_rec.pricing_contract_id;
    END IF;

    if (l_Contract_rec.discount_Id IS NOT NULL AND l_Contract_rec.discount_Id <> FND_API.G_MISS_NUM)
    THEN
        l_Discount_Header_rec.discount_id := l_Contract_rec.discount_id;
    END IF;

    --  Discount_Header
-- Code Commented
-- No need to create discounts now
/*
    l_p_Discount_Header_rec	:= l_Discount_Header_rec;     --[prarasto]
    l_p_old_Discount_Header_rec	:= l_old_Discount_Header_rec; --[prarasto]

    Discount_Header
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Discount_Header_rec         => l_p_Discount_Header_rec
    ,   p_old_Discount_Header_rec     => l_p_old_Discount_Header_rec
    ,   x_Discount_Header_rec         => l_Discount_Header_rec
    ,   x_old_Discount_Header_rec     => l_old_Discount_Header_rec
    );
*/

    --  Perform Discount_Header group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_DISCOUNT_HEADER)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Price_LLine_tbl.COUNT LOOP

        l_Price_LLine_rec := l_Price_LLine_tbl(I);

        IF l_Price_LLine_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Price_LLine_rec.price_list_id IS NULL OR
            l_Price_LLine_rec.price_list_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_Price_LLine_tbl(I).price_list_id := l_Price_LHeader_rec.price_list_id;
        END IF;
    END LOOP;

    --  Price_Llines

    l_p_Price_LLine_tbl 	:= l_Price_LLine_tbl;     --[prarasto]
    l_p_old_Price_LLine_tbl	:= l_old_Price_LLine_tbl; --[prarasto]

    Price_Llines
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Price_LLine_tbl             => l_p_Price_LLine_tbl
    ,   p_old_Price_LLine_tbl         => l_p_old_Price_LLine_tbl
    ,   x_Price_LLine_tbl             => l_Price_LLine_tbl
    ,   x_old_Price_LLine_tbl         => l_old_Price_LLine_tbl
    );

    --  Perform Price_LLine group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_PRICE_LLINE)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Discount_Cust_tbl.COUNT LOOP

        l_Discount_Cust_rec := l_Discount_Cust_tbl(I);

        IF l_Discount_Cust_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Discount_Cust_rec.discount_id IS NULL OR
            l_Discount_Cust_rec.discount_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_Discount_Cust_tbl(I).discount_id := l_Discount_Header_rec.discount_id;
        END IF;
    END LOOP;

    --  Discount_Custs
/*
    l_p_Discount_Cust_tbl	:= l_Discount_Cust_tbl;     --[prarasto]
    l_p_old_Discount_Cust_tbl	:= l_old_Discount_Cust_tbl; --[prarasto]

    Discount_Custs
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Discount_Cust_tbl           => l_p_Discount_Cust_tbl
    ,   p_old_Discount_Cust_tbl       => l_p_old_Discount_Cust_tbl
    ,   x_Discount_Cust_tbl           => l_Discount_Cust_tbl
    ,   x_old_Discount_Cust_tbl       => l_old_Discount_Cust_tbl
    );
*/

    --  Perform Discount_Cust group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_DISCOUNT_CUST)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Discount_Line_tbl.COUNT LOOP

        l_Discount_Line_rec := l_Discount_Line_tbl(I);

        IF l_Discount_Line_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Discount_Line_rec.discount_id IS NULL OR
            l_Discount_Line_rec.discount_id = FND_API.G_MISS_NUM)
        THEN

            --  Copy parent_id.

            l_Discount_Line_tbl(I).discount_id := l_Discount_Header_rec.discount_id;
        END IF;
    END LOOP;
/*
    --  Discount_Lines

    l_p_Discount_Line_tbl	:= l_Discount_Line_tbl;     --[prarasto]
    l_p_old_Discount_Line_tbl	:= l_old_Discount_Line_tbl; --[prarasto]

    Discount_Lines
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Discount_Line_tbl           => l_p_Discount_Line_tbl
    ,   p_old_Discount_Line_tbl       => l_p_old_Discount_Line_tbl
    ,   x_Discount_Line_tbl           => l_Discount_Line_tbl
    ,   x_old_Discount_Line_tbl       => l_old_Discount_Line_tbl
    );
*/

    --  Perform Discount_Line group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_DISCOUNT_LINE)
    THEN

        NULL;

    END IF;

    --  Load parent key if missing and operation is create.

    FOR I IN 1..l_Price_Break_tbl.COUNT LOOP

        l_Price_Break_rec := l_Price_Break_tbl(I);

        IF l_Price_Break_rec.operation = OE_GLOBALS.G_OPR_CREATE
        AND (l_Price_Break_rec.discount_line_id IS NULL OR
            l_Price_Break_rec.discount_line_id = FND_API.G_MISS_NUM)
        THEN

            --  Check If parent exists.

            IF l_Discount_Line_tbl.EXISTS(l_Price_Break_rec.Discount_Line_index) THEN

                --  Copy parent_id.

                l_Price_Break_tbl(I).discount_line_id := l_Discount_Line_tbl(l_Price_Break_rec.Discount_Line_index).discount_line_id;

            ELSE

                IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
                THEN

                    FND_MESSAGE.SET_NAME('OE','OE_API_INV_PARENT_INDEX');
                    FND_MESSAGE.SET_TOKEN('ENTITY_NAME','Price_Break');
                    FND_MESSAGE.SET_TOKEN('ENTITY_INDEX',I);
                    FND_MESSAGE.SET_TOKEN('PARENT_INDEX',l_Price_Break_rec.Discount_Line_index);
                    OE_MSG_PUB.Add;

                END IF;
            END IF;
            END IF;
    END LOOP;

    --  Price_Breaks

    l_p_Price_Break_tbl		:= l_Price_Break_tbl;     --[prarasto]
    l_p_old_Price_Break_tbl	:= l_old_Price_Break_tbl; --[prarasto]

    Price_Breaks
    (   p_validation_level            => p_validation_level
    ,   p_control_rec                 => p_control_rec
    ,   p_Price_Break_tbl             => l_p_Price_Break_tbl
    ,   p_old_Price_Break_tbl         => l_p_old_Price_Break_tbl
    ,   x_Price_Break_tbl             => l_Price_Break_tbl
    ,   x_old_Price_Break_tbl         => l_old_Price_Break_tbl
    );

    --  Perform Price_Break group requests.

    IF p_control_rec.process AND
        (p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL OR
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_PRICE_BREAK)
    THEN

        NULL;

    END IF;

    --  Step 6. Perform Object group logic

    IF p_control_rec.process AND
        p_control_rec.process_entity = OE_GLOBALS.G_ENTITY_ALL
    THEN

        NULL;

    END IF;

   end if;
   --end processing from screen

    --  Done processing, load OUT parameters.

    x_Contract_rec                 := l_Contract_rec;
    x_Agreement_rec                := l_Agreement_rec;
    x_Price_LHeader_rec            := l_Price_LHeader_rec;
    x_Discount_Header_rec          := l_Discount_Header_rec;
    x_Price_LLine_tbl              := l_Price_LLine_tbl;
    x_Discount_Cust_tbl            := l_Discount_Cust_tbl;
    x_Discount_Line_tbl            := l_Discount_Line_tbl;
    x_Price_Break_tbl              := l_Price_Break_tbl;

    --  Clear API cache.

    IF p_control_rec.clear_api_cache THEN

        NULL;

    END IF;

    --  Clear API request tbl.

    IF p_control_rec.clear_api_requests THEN

        NULL;

    END IF;

    --  Derive return status.



    IF l_Contract_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF l_Agreement_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF l_Price_LHeader_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF l_Discount_Header_rec.return_status = FND_API.G_RET_STS_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    FOR I IN 1..l_Price_LLine_tbl.COUNT LOOP

        IF l_Price_LLine_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_Discount_Cust_tbl.COUNT LOOP

        IF l_Discount_Cust_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_Discount_Line_tbl.COUNT LOOP

        IF l_Discount_Line_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR I IN 1..l_Price_Break_tbl.COUNT LOOP

        IF l_Price_Break_tbl(I).return_status = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

    oe_debug_pub.add('Exiting Process_Pricing_Cont');

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN NO_UPDATE_PRIVILEGE THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        --  Get message count and data

        oe_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Process_Pricing_Cont'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Process_Pricing_Cont;

--  Start of Comments
--  API name    Lock_Pricing_Cont
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Lock_Pricing_Cont
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_Contract_rec                  IN  OE_Pricing_Cont_PUB.Contract_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_CONTRACT_REC
,   p_Agreement_rec                 IN  OE_Pricing_Cont_PUB.Agreement_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_AGREEMENT_REC
,   p_Price_LHeader_rec             IN  OE_Price_List_PUB.Price_List_Rec_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_REC
,   p_Discount_Header_rec           IN  OE_Pricing_Cont_PUB.Discount_Header_Rec_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_HEADER_REC
,   p_Price_LLine_tbl               IN  OE_Price_List_PUB.Price_List_Line_Tbl_Type :=
                                        OE_Price_List_PUB.G_MISS_PRICE_List_Line_TBL
,   p_Discount_Cust_tbl             IN  OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_CUST_TBL
,   p_Discount_Line_tbl             IN  OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_DISCOUNT_LINE_TBL
,   p_Price_Break_tbl               IN  OE_Pricing_Cont_PUB.Price_Break_Tbl_Type :=
                                        OE_Pricing_Cont_PUB.G_MISS_PRICE_BREAK_TBL
,   x_Contract_rec                  OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_Discount_Header_rec           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Header_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Discount_Cust_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type
,   x_Discount_Line_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Lock_Pricing_Cont';
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Discount_Cust_rec           OE_Pricing_Cont_PUB.Discount_Cust_Rec_Type;
l_Discount_Line_rec           OE_Pricing_Cont_PUB.Discount_Line_Rec_Type;
l_Price_Break_rec             OE_Pricing_Cont_PUB.Price_Break_Rec_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Set Savepoint

    SAVEPOINT Lock_Pricing_Cont_PVT;

    --  Lock Contract

    IF p_Contract_rec.operation = OE_GLOBALS.G_OPR_LOCK THEN

        OE_Contract_Util.Lock_Row
        (   p_Contract_rec                => p_Contract_rec
        ,   x_Contract_rec                => x_Contract_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock Agreement

    IF p_Agreement_rec.operation = OE_GLOBALS.G_OPR_LOCK THEN

        OE_Agreement_Util.Lock_Row
        (   p_Agreement_rec               => p_Agreement_rec
        ,   x_Agreement_rec               => x_Agreement_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;

    --  Lock Price_LHeader

    IF p_Price_LHeader_rec.operation = OE_GLOBALS.G_OPR_LOCK THEN

        OE_Price_List_Util.Lock_Row
        (   p_Price_LIST_rec           => p_Price_LHeader_rec
        ,   x_Price_LIST_rec           => x_Price_LHeader_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;
/*
    --  Lock Discount_Header

    IF p_Discount_Header_rec.operation = OE_GLOBALS.G_OPR_LOCK THEN

        OE_Discount_Header_Util.Lock_Row
        (   p_Discount_Header_rec         => p_Discount_Header_rec
        ,   x_Discount_Header_rec         => x_Discount_Header_rec
        ,   x_return_status               => l_return_status
        );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;


    END IF;
*/
    --  Lock Price_LLine

    FOR I IN 1..p_Price_LLine_tbl.COUNT LOOP

        IF p_Price_LLine_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Price_List_Line_Util.Lock_Row
            (   p_PRICE_LIST_LINE_rec             => p_Price_LLine_tbl(I)
            ,   x_PRICE_LIST_LINE_rec             => l_Price_LLine_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Price_LLine_tbl(I)           := l_Price_LLine_rec;

        END IF;

    END LOOP;
/*
    --  Lock Discount_Cust

    FOR I IN 1..p_Discount_Cust_tbl.COUNT LOOP

        IF p_Discount_Cust_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Discount_Cust_Util.Lock_Row
            (   p_Discount_Cust_rec           => p_Discount_Cust_tbl(I)
            ,   x_Discount_Cust_rec           => l_Discount_Cust_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Discount_Cust_tbl(I)         := l_Discount_Cust_rec;

        END IF;

    END LOOP;

    --  Lock Discount_Line

    FOR I IN 1..p_Discount_Line_tbl.COUNT LOOP

        IF p_Discount_Line_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Discount_Line_Util.Lock_Row
            (   p_Discount_Line_rec           => p_Discount_Line_tbl(I)
            ,   x_Discount_Line_rec           => l_Discount_Line_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Discount_Line_tbl(I)         := l_Discount_Line_rec;

        END IF;

    END LOOP;
*/


    --  Lock Price_Break

    FOR I IN 1..p_Price_Break_tbl.COUNT LOOP

        IF p_Price_Break_tbl(I).operation = OE_GLOBALS.G_OPR_LOCK THEN

            OE_Price_Break_Util.Lock_Row
            (   p_Price_Break_rec             => p_Price_Break_tbl(I)
            ,   x_Price_Break_rec             => l_Price_Break_rec
            ,   x_return_status               => l_return_status
            );

            IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            x_Price_Break_tbl(I)           := l_Price_Break_rec;

        END IF;

    END LOOP;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Pricing_Cont_PVT;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Pricing_Cont_PVT;

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Lock_Pricing_Cont'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

        --  Rollback

        ROLLBACK TO Lock_Pricing_Cont_PVT;

END Lock_Pricing_Cont;

--  Start of Comments
--  API name    Get_Pricing_Cont
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Pricing_Cont
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   x_msg_count                     OUT NOCOPY /* file.sql.39 change */ NUMBER
,   x_msg_data                      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_pricing_contract_id           IN  NUMBER
,   p_name		            IN  VARCHAR2
,   x_Contract_rec                  OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Contract_Rec_Type
,   x_Agreement_rec                 OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Agreement_Rec_Type
,   x_Price_LHeader_rec             OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Rec_Type
,   x_Discount_Header_rec           OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Header_Rec_Type
,   x_Price_LLine_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Price_List_PUB.Price_List_Line_Tbl_Type
,   x_Discount_Cust_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type
,   x_Discount_Line_tbl             OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type
,   x_Price_Break_tbl               OUT NOCOPY /* file.sql.39 change */ OE_Pricing_Cont_PUB.Price_Break_Tbl_Type
)
IS
l_api_version_number          CONSTANT NUMBER := 1.0;
l_api_name                    CONSTANT VARCHAR2(30):= 'Get_Pricing_Cont';
l_Contract_rec                OE_Pricing_Cont_PUB.Contract_Rec_Type;
l_Agreement_tbl               OE_Pricing_Cont_PUB.Agreement_Tbl_Type;
l_Agreement_rec               OE_Pricing_Cont_PUB.Agreement_Rec_Type;
l_Price_LHeader_tbl           OE_Price_List_PUB.Price_List_Tbl_Type;
l_Price_LHeader_rec           OE_Price_List_PUB.Price_List_Rec_Type;
l_Discount_Header_tbl         OE_Pricing_Cont_PUB.Discount_Header_Tbl_Type;
l_Discount_Header_rec         OE_Pricing_Cont_PUB.Discount_Header_Rec_Type;
l_Price_LLine_tbl             OE_Price_List_PUB.Price_List_Line_Tbl_Type;
l_Price_LLine_rec             OE_Price_List_PUB.Price_List_Line_Rec_Type;
l_Discount_Cust_tbl           OE_Pricing_Cont_PUB.Discount_Cust_Tbl_Type;
l_Discount_Line_tbl           OE_Pricing_Cont_PUB.Discount_Line_Tbl_Type;
l_Price_Break_tbl             OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
l_x_Price_Break_tbl           OE_Pricing_Cont_PUB.Price_Break_Tbl_Type;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
           (   l_api_version_number
           ,   p_api_version_number
           ,   l_api_name
           ,   G_PKG_NAME
           )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list.

    IF FND_API.to_Boolean(p_init_msg_list) THEN
        OE_MSG_PUB.initialize;
    END IF;

    --  Get Contract ( parent = Contract )

    l_Contract_rec :=  OE_Contract_Util.Query_Row
    (   p_pricing_contract_id => p_pricing_contract_id
    );

        --  Get Agreement ( parent = Contract )

        l_Agreement_tbl :=  OE_Agreement_Util.Query_Rows
        (   p_pricing_contract_id   => l_Contract_rec.pricing_contract_id
        );

        IF l_Agreement_tbl.COUNT > 0 THEN
            l_Agreement_rec                := l_Agreement_tbl(1);
        END IF;


        --  Get Price_LHeader ( parent = Contract )

        l_Price_LHeader_tbl(1) :=  OE_Price_List_Util.Query_Row
        ( p_name			    => l_Price_LHeader_rec.name
         ,p_price_list_id               => l_contract_rec.pricing_contract_id
        );

        IF l_Price_LHeader_tbl.COUNT > 0 THEN
            l_Price_LHeader_rec            := l_Price_LHeader_tbl(1);
        END IF;


            --  Get Price_LLine ( parent = Price_LHeader )

            l_Price_LLine_tbl(1) :=  OE_Price_List_Line_Util.Query_Row
            (   p_price_list_line_id          => l_Price_LLine_rec.price_list_line_id
            ,   p_price_list_id          => l_Price_LLine_rec.price_list_id
            );

        IF l_Price_LLine_tbl.COUNT > 0 THEN
            l_Price_LLine_rec            := l_Price_LLine_tbl(1);
        END IF;

/*
        --  Get Discount_Header ( parent = Contract )
        l_Discount_Header_tbl :=  OE_Discount_Header_Util.Query_Rows
        (   p_pricing_contract_id   => l_Contract_rec.pricing_contract_id
        );

        IF l_Discount_Header_tbl.COUNT > 0 THEN
            l_Discount_Header_rec          := l_Discount_Header_tbl(1);
        END IF;


            --  Get Discount_Cust ( parent = Discount_Header )

            l_Discount_Cust_tbl :=  OE_Discount_Cust_Util.Query_Rows
            (   p_discount_id             => l_Discount_Header_rec.discount_id
            );


            --  Get Discount_Line ( parent = Discount_Header )

            l_Discount_Line_tbl :=  OE_Discount_Line_Util.Query_Rows
            (   p_discount_id             => l_Discount_Header_rec.discount_id
            );


            --  Loop over Discount_Line's children

            FOR I3 IN 1..l_Discount_Line_tbl.COUNT LOOP

                --  Get Price_Break ( parent = Discount_Line )

                l_Price_Break_tbl :=  OE_Price_Break_Util.Query_Rows
                (   p_discount_line_id          => l_Discount_Line_tbl(I3).discount_line_id
                );

                FOR I4 IN 1..l_Price_Break_tbl.COUNT LOOP
                    l_Price_Break_tbl(I4).Discount_Line_Index := I3;
                    l_x_Price_Break_tbl
                    (l_x_Price_Break_tbl.COUNT + 1) := l_Price_Break_tbl(I4);
                END LOOP;


            END LOOP;
*/

    --  Load out parameters

    x_Contract_rec                 := l_Contract_rec;
    x_Agreement_rec                := l_Agreement_rec;
    x_Price_LHeader_rec            := l_Price_LHeader_rec;
    x_Discount_Header_rec          := l_Discount_Header_rec;
    x_Price_LLine_tbl              := l_Price_LLine_tbl;
    x_Discount_Cust_tbl            := l_Discount_Cust_tbl;
    x_Discount_Line_tbl            := l_Discount_Line_tbl;
    x_Price_Break_tbl              := l_x_Price_Break_tbl;

    --  Set return status

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Get message count and data

    OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Get_Pricing_Cont'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Get_Pricing_Cont;



FUNCTION Check_Delete_Agreement( p_Price_List_id IN NUMBER)
RETURN BOOLEAN

IS
 l_price_list_id NUMBER;
 l_count NUMBER;
BEGIN

		SELECT count(*)
		into l_count
		from oe_agreements_b
		where price_list_id = p_Price_List_id;

    oe_debug_pub.add('Geresh In Check Delete Agreement' || p_Price_List_Id);

		if ( l_count = 1) then
		     RETURN TRUE;
		else
		   if l_count > 1 THEN
			RETURN FALSE;
		   else
			RETURN TRUE;
		   end if;
		end if;




		EXCEPTION
		WHEN NO_DATA_FOUND THEN
    oe_debug_pub.add('Geresh In No Data Found Check Delete Agreement' || p_Price_List_Id);
		   RETURN TRUE;

		WHEN TOO_MANY_ROWS THEN
    oe_debug_pub.add('Geresh In No Data Found Check Delete Agreement' || p_Price_List_Id);
		   RETURN FALSE;


END Check_Delete_Agreement;

-------------
FUNCTION Check_Order_Lines_Agreement( p_Agreement_id IN NUMBER)
RETURN BOOLEAN
IS
  l_agreement_id NUMBER;
  l_exist varchar2(1) := 'Y';
BEGIN

/* Commented following code for Bug 2321498 */

/*
    oe_debug_pub.add('Geresh In Check Order Header' || p_Agreement_id);
   SELECT agreement_id into
   l_agreement_id
   from oe_order_lines
   where agreement_id = p_Agreement_id;


    oe_debug_pub.add('Geresh In Check Order Header After sql' || sql%rowcount);
  if SQL%ROWCOUNT > 0 then
	RETURN FALSE;
  else
     RETURN TRUE;
  end if; */

           Select 'N' into l_exist from dual where
           not exists (select 1 from oe_order_lines
           where agreement_id = p_Agreement_id);
            oe_debug_pub.add('Geresh In Check Order Line After sql');
           oe_debug_pub.add('l_exist :'||l_exist);

           If l_exist = 'N' Then
           RETURN TRUE;
           Else
               RETURN FALSE;
           End If;
          --oe_debug_pub.add('Geresh In Check Order Line After sql');
           --oe_debug_pub.add('l_exist :'||l_exist);
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	RETURN FALSE;

   WHEN TOO_MANY_ROWS THEN
     RETURN TRUE;



END Check_Order_Lines_Agreement;
--------

FUNCTION Check_Order_Agreement( p_Agreement_id IN NUMBER)
RETURN BOOLEAN
IS
  l_agreement_id NUMBER;
  l_exist VARCHAR2(1) := 'Y';
BEGIN
--Commented following code for bug 2321498

  /*
    oe_debug_pub.add('Geresh In Check Order Header' || p_Agreement_id);
   SELECT agreement_id into
   l_agreement_id
   from oe_order_headers
   where agreement_id = p_Agreement_id;


    oe_debug_pub.add('Geresh In Check Order Header After sql' || sql%rowcount);
  if SQL%ROWCOUNT > 0 then
	RETURN FALSE;
  else
     RETURN TRUE;
  end if;
*/
--Added following code for Bug 2321498
  Select 'N' into l_exist from dual where
           not exists (select 1 from oe_order_headers
           where agreement_id = p_Agreement_id);
   oe_debug_pub.add('Geresh In Check Order Header After sql');
  oe_debug_pub.add('l_exist :'||l_exist);

           If l_exist = 'N' Then
           RETURN TRUE;
           Else
               RETURN FALSE;
           End If;


   EXCEPTION
   WHEN NO_DATA_FOUND THEN
	RETURN FALSE;

   WHEN TOO_MANY_ROWS THEN
     RETURN TRUE;



END Check_Order_Agreement;

/*procedure added by spgopal 08/14/00 for duplication of qualifier on price list updates*/

/*
PROCEDURE Create_Agreement_Qualifier
			(p_list_header_id IN NUMBER,
			 p_old_list_header_id IN NUMBER,
			 p_Agreement_id IN NUMBER,
			 x_return_status OUT NOCOPY VARCHAR2); -- file.sql.39 change
*/


PROCEDURE Create_Agreement_Qualifier
			(p_list_header_id IN NUMBER,
			 p_old_list_header_id IN NUMBER,
			 p_Agreement_id IN NUMBER,
			 p_operation IN VARCHAR2,
			 x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2) IS

/* For creating qualifiers */
l_price_list_type_code     QP_LIST_HEADERS_B.LIST_TYPE_CODE%TYPE;
l_QUALIFIERS_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_QUALIFIERS_val_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_QUALIFIERS_rec	  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
--nguha 2041504
l_control_rec                 QP_GLOBALS.Control_Rec_Type;

l_x_QUALIFIERS_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Tbl_Type ;
l_x_QUALIFIERS_val_tbl	  QP_Qualifier_Rules_PUB.Qualifiers_Val_Tbl_Type;
l_x_QUALIFIERS_rec	  QP_Qualifier_Rules_PUB.Qualifiers_Rec_Type ;
l_x_QUALIFIER_RULES_rec	  QP_Qualifier_Rules_PUB.Qualifier_Rules_Rec_Type ;
l_x_QUALIFIER_RULES_val_rec  QP_Qualifier_Rules_PUB.Qualifier_Rules_Val_Rec_Type;
l_return_status	VARCHAR2(1);
l_return_values	VARCHAR2(1) := FND_API.G_FALSE;
l_commit  VARCHAR2(1) := FND_API.G_FALSE;
l_msg_count    NUMBER;
l_msg_data    VARCHAR2(250);
l_qual_count	NUMBER;
l_old_qual_count	NUMBER;

BEGIN

oe_debug_pub.add('begin create_agr_qual'||to_char(p_old_list_header_id)||'old'||to_char(p_list_header_id)||'new');

		IF p_list_header_id IS NOT NULL OR
			p_list_header_id <> FND_API.G_MISS_NUM THEN


		if p_operation = OE_GLOBALS.G_OPR_CREATE then

			oe_debug_pub.add('in if create'||p_operation);

		   	l_qualifiers_rec.list_header_id := p_list_header_id;
		   	l_qualifiers_rec.qualifier_attr_value := p_agreement_id;
		   	l_qualifiers_rec.qualifier_context := 'CUSTOMER';
		   	l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE7';
	   	   	l_qualifiers_rec.qualifier_grouping_no := p_agreement_id;


		   	l_qualifiers_rec.operation := OE_GLOBALS.G_OPR_CREATE;
		   	l_qualifiers_tbl(1) := l_qualifiers_rec;
--nguha 2041504
    -- set the called_from_ui indicator to 'Y', as
    -- QP_Qualifier_Rules_PVT.Process_Qualifier_Rules is being called from UI

			l_control_rec.called_from_ui := 'Y';

-- We should call the private package and not the public

		 	QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
		   	(     p_api_version_number =>	1.0
		   		,   p_init_msg_list		=> FND_API.G_TRUE
				,   p_validation_level          => FND_API.G_VALID_LEVEL_FULL
				,   p_commit			=> FND_API.G_FALSE
				,   x_return_status		=> x_return_status
				,   x_msg_count 		=> l_msg_count
				,   x_msg_data			=> l_msg_data
				,   p_control_rec               => l_control_rec
				,   p_QUALIFIER_RULES_rec	=> l_QUALIFIER_RULES_rec
				,   p_QUALIFIERS_tbl  		=> l_QUALIFIERS_tbl
				,   x_QUALIFIER_RULES_rec	=> l_x_QUALIFIER_RULES_rec
				,   x_QUALIFIERS_tbl		=>  l_x_QUALIFIERS_tbl
   			);


	elsif p_operation = OE_GLOBALS.G_OPR_UPDATE then
			oe_debug_pub.add('in if update'||p_operation);


		if p_old_list_header_id <> p_list_header_id then
			oe_debug_pub.add('in else id!=id'||p_operation);
				delete from qp_qualifiers where
				list_header_id = p_old_list_header_id
				and qualifier_context = 'CUSTOMER'
				and qualifier_attribute = 'QUALIFIER_ATTRIBUTE7'
				and qualifier_attr_value = p_agreement_id;

		else
			null;
		end if;      --p_old_list_header_id = p_list_header_id

		oe_debug_pub.add('in if id=id'||p_operation);
		BEGIN

			select count(list_header_id) into l_qual_count
			from qp_qualifiers where
			list_header_id = p_list_header_id
			and qualifier_context = 'CUSTOMER'
			and qualifier_attribute = 'QUALIFIER_ATTRIBUTE7'
			and qualifier_attr_value = p_agreement_id;

		EXCEPTION
		When NO_DATA_FOUND Then
		l_qual_count := 0;

		END;

		if l_qual_count < 1 then
			oe_debug_pub.add('in if count'||to_char(l_qual_count));
			l_qualifiers_rec.list_header_id := p_list_header_id;
		   	l_qualifiers_rec.qualifier_attr_value := p_agreement_id;
		   	l_qualifiers_rec.qualifier_context := 'CUSTOMER';
		   	l_qualifiers_rec.qualifier_attribute := 'QUALIFIER_ATTRIBUTE7';
	   	   	l_qualifiers_rec.qualifier_grouping_no := p_agreement_id;


		   	l_qualifiers_rec.operation := OE_GLOBALS.G_OPR_CREATE;
		   	l_qualifiers_tbl(1) := l_qualifiers_rec;

		else

			oe_debug_pub.add('in else count'||to_char(l_qual_count));
			null;

		end if; --l_qual_count<1


--nguha 2041504
    -- set the called_from_ui indicator to 'Y', as
    -- QP_Qualifier_Rules_PVT.Process_Qualifier_Rules is being called from UI

                        l_control_rec.called_from_ui := 'Y';

-- We should call the private package and not the public

                        QP_Qualifier_Rules_PVT.Process_Qualifier_Rules
                        (     p_api_version_number =>   1.0
                                ,   p_init_msg_list             => FND_API.G_TRUE
                                ,   p_validation_level          => FND_API.G_VALID_LEVEL_FULL
                                ,   p_commit                    => FND_API.G_FALSE
                                ,   x_return_status             => x_return_status
                                ,   x_msg_count                 => l_msg_count
                                ,   x_msg_data                  => l_msg_data
                                ,   p_control_rec               => l_control_rec
                                ,   p_QUALIFIER_RULES_rec       => l_QUALIFIER_RULES_rec
                                ,   p_QUALIFIERS_tbl            => l_QUALIFIERS_tbl
                                ,   x_QUALIFIER_RULES_rec       => l_x_QUALIFIER_RULES_rec
                                ,   x_QUALIFIERS_tbl            =>  l_x_QUALIFIERS_tbl
                        );


			end if; --operation
		END IF;



oe_debug_pub.add('end create_agr_qual'||to_char(p_old_list_header_id)||'old'||to_char(p_list_header_id)||'new');

EXCEPTION

    WHEN OTHERS THEN

		  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
				THEN
				OE_MSG_PUB.Add_Exc_Msg
				(   G_PKG_NAME
				,   'Process_Modifiers'
				);
		  END IF;

																    			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

																		  --  Get message count and data

																				OE_MSG_PUB.Count_And_Get
				(   p_count                       => l_msg_count
				,   p_data                        => l_msg_data
				);

oe_debug_pub.add('exp create_agr_qual'||to_char(p_old_list_header_id)||'old'||to_char(p_list_header_id)||'new');

END Create_Agreement_Qualifier;

END OE_Pricing_Cont_PVT;

/
