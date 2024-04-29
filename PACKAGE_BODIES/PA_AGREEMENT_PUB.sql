--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENT_PUB" as
/*$Header: PAAFAPBB.pls 120.11.12010000.2 2008/12/14 12:18:32 arbandyo ship $*/

--Global constants to be used in error messages
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_AGREEMENT_PUB';
G_AGREEMENT_CODE        CONSTANT VARCHAR2(9)  := 'AGREEMENT';

--PACKAGE GLOBAL to be used during updates ---------------------------
G_USER_ID               CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID              CONSTANT NUMBER := FND_GLOBAL.login_id;

-- ============================================================================
--
--Name:               create_agreement
--Type:               Procedure
--Description:  This procedure can be used to create an agreement for an
--              existing project or template.
--
--Called subprograms:
--			pa_interface_utils_pub.map_new_amg_msg
--			pa_agreement_pub.check_create_agreement_ok
--			pa_agreement_utils.validate_flex_fields
--			pa_agreement_pvt.convert_ag_ref_to_id
--			pa_agreement_utils.create_agreement
--			pa_agreement_pub.add_funding
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      10-SEP-2001      Srividya                MCB2 code changes
--      17-JAN-2002      Amit           Bug 2180350. Changed from OR
--                                      to AND in the if condition of
--                                      update_agreement procedure.
-- ---------------------------------------------------------------------------

PROCEDURE create_agreement
(p_api_version_number	IN	NUMBER   --:=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit	        IN	VARCHAR2 --:= FND_API.G_FALSE
 ,p_init_msg_list	IN	VARCHAR2 --:= FND_API.G_FALSE
 ,p_msg_count	        OUT	NOCOPY NUMBER /*file.sql.39*/
 ,p_msg_data	        OUT	NOCOPY VARCHAR2 /*file.sql.39*/
 ,p_return_status	OUT	NOCOPY VARCHAR2
 ,p_pm_product_code	IN	VARCHAR2 --:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_agreement_in_rec	IN	Agreement_Rec_In_Type
 ,p_agreement_out_rec	OUT	NOCOPY Agreement_Rec_Out_Type /*file.sql.39*/
 ,p_funding_in_tbl	IN	funding_in_tbl_type
 ,p_funding_out_tbl	OUT	NOCOPY funding_out_tbl_type /*File.sql.39*/
 )
IS
-- Local variables
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_row_id					VARCHAR2(2000);
l_return_msg					VARCHAR2(2000);
l_validate_status				VARCHAR2(1);
i 						NUMBER;
l_funding_in_rec				funding_rec_in_type;
l_funding_id					NUMBER;
l_out_agreement_id				NUMBER ;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'create_agreement';
l_agreement_in_rec				Agreement_Rec_In_Type;
l_valid_currency                                VARCHAR2(1);  /* Bug 2437469 */
l_old_fund_curr_code                            VARCHAR2(15); /* Bug 2437469 */
l_invproc_currency_type                         VARCHAR2(30); /* Bug 2437469 */
x_advance_flag  boolean; /*Added for bug 5743599*/
x_status        Number;  /*Added for bug 5743599*/
x_error_message varchar2(240); /*Added for bug 5743599*/
l_advance_flag varchar2(2); /*Added for bug 5743599*/

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT create_agreement_pub;

--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions



    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_CREATE_AGREEMENT',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;


        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;
    p_agreement_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Product Code
    IF (p_pm_product_code IS NULL)
       OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Agreement Reference
    IF (p_agreement_in_rec.pm_agreement_reference IS NULL)
       OR (p_agreement_in_rec.pm_agreement_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Agreement Number
    IF (p_agreement_in_rec.agreement_num IS NULL)
       OR (p_agreement_in_rec.agreement_num = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_NUM_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Customer Id

    IF (p_agreement_in_rec.customer_id IS NULL)
       OR (p_agreement_in_rec.customer_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_CUST_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Customer Number
    IF (p_agreement_in_rec.customer_num IS NULL)
       OR (p_agreement_in_rec.customer_num = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_CUST_NUM_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Agreement Type
    IF (p_agreement_in_rec.agreement_type IS NULL)
       OR (p_agreement_in_rec.agreement_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_TYPE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
		        ,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- Term Id
     IF (p_agreement_in_rec.term_id IS NULL)
       OR (p_agreement_in_rec.term_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
     THEN
      	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
            	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_TERM_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
/*
   -- Template Flag
   IF (p_agreement_in_rec.template_flag IS NULL)
       OR (p_agreement_in_rec.template_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_TEMP_FLG_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
*/
   -- Revenue Limit Flag
   IF (p_agreement_in_rec.revenue_limit_flag IS NULL)
       OR (p_agreement_in_rec.revenue_limit_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
   		pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_REV_LT_FLG_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Owned By Person Id
   IF (p_agreement_in_rec.owned_by_person_id IS NULL)
       OR (p_agreement_in_rec.owned_by_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_OWND_BY_PRSN_ID_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
   END IF;

 -- Amount
   IF (p_agreement_in_rec.amount IS NULL)
       OR (p_agreement_in_rec.amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_ALLOC_AMT_IS_MISS_AMG'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- VALIDATE THE INCOMING PARAMETERS
   IF pa_agreement_pvt.check_create_agreement_ok
   			(p_pm_agreement_reference	=> p_agreement_in_rec.pm_agreement_reference
 			,p_customer_id			=> p_agreement_in_rec.customer_id
 			,p_agreement_type 		=> p_agreement_in_rec.agreement_type
 			,p_agreement_num 		=> p_agreement_in_rec.agreement_num
 			,p_term_id 			=> p_agreement_in_rec.term_id
 			,p_template_flag 		=> p_agreement_in_rec.template_flag
 			,p_revenue_limit_flag 		=> p_agreement_in_rec.revenue_limit_flag
 			,p_owned_by_person_id 		=> p_agreement_in_rec.owned_by_person_id
/* MCB2 params begin */
 			,p_owning_organization_id 	=> p_agreement_in_rec.owning_organization_id
 			,p_agreement_currency_code 	=> p_agreement_in_rec.agreement_currency_code
 			,p_invoice_limit_flag 	        => p_agreement_in_rec.invoice_limit_flag
/* MCB2 params end */ /*federal*/
			,p_start_date                   => p_agreement_in_rec.start_date
			,p_end_date                     => p_agreement_in_rec.expiration_date
			,p_advance_required             => p_agreement_in_rec.advance_required
			,p_billing_sequence             => p_agreement_in_rec.billing_sequence
 			) = 'N'
   THEN
   	p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Flex Field Validations

   IF (p_agreement_in_rec.desc_flex_name IS NOT NULL)

       AND (p_agreement_in_rec.desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
   THEN
   /*Changed for federal*/
   pa_agreement_pvt.validate_flex_fields
   	(p_desc_flex_name         => p_agreement_in_rec.desc_flex_name
         ,p_attribute_category    => p_agreement_in_rec.attribute_category
         ,p_attribute1            => p_agreement_in_rec.attribute1
         ,p_attribute2            => p_agreement_in_rec.attribute2
         ,p_attribute3            => p_agreement_in_rec.attribute3
         ,p_attribute4            => p_agreement_in_rec.attribute4
         ,p_attribute5            => p_agreement_in_rec.attribute5
         ,p_attribute6            => p_agreement_in_rec.attribute6
         ,p_attribute7            => p_agreement_in_rec.attribute7
         ,p_attribute8            => p_agreement_in_rec.attribute8
         ,p_attribute9            => p_agreement_in_rec.attribute9
         ,p_attribute10           => p_agreement_in_rec.attribute10
         ,p_attribute11           => p_agreement_in_rec.attribute11
         ,p_attribute12           => p_agreement_in_rec.attribute12
         ,p_attribute13           => p_agreement_in_rec.attribute13
         ,p_attribute14           => p_agreement_in_rec.attribute14
         ,p_attribute15           => p_agreement_in_rec.attribute15
         ,p_attribute16           => p_agreement_in_rec.attribute16
         ,p_attribute17           => p_agreement_in_rec.attribute17
         ,p_attribute18           => p_agreement_in_rec.attribute18
         ,p_attribute19           => p_agreement_in_rec.attribute19
         ,p_attribute20           => p_agreement_in_rec.attribute20
         ,p_attribute21           => p_agreement_in_rec.attribute21
         ,p_attribute22           => p_agreement_in_rec.attribute22
         ,p_attribute23           => p_agreement_in_rec.attribute23
         ,p_attribute24           => p_agreement_in_rec.attribute24
         ,p_attribute25           => p_agreement_in_rec.attribute25
         ,p_return_msg            => l_return_msg
         ,p_validate_status       => l_validate_status);

     IF l_validate_status = 'N'
     THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FF_VALUES'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;

/* NOT REQUIRED
   -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
   pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_agreement_reference => p_agreement_in_rec.pm_agreement_reference
		,p_af_agreement_id => p_agreement_in_rec.agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
   p_agreement_out_rec.return_status := l_return_status;
   p_return_status             := l_return_status;

   IF l_return_status = FND_API.G_RET_STS_ERROR
   THEN
   	RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   THEN
   	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSE
   	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   */

l_agreement_in_rec := p_agreement_in_rec;

IF l_agreement_in_rec.expiration_date =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
	l_agreement_in_rec.expiration_date := NULL;
END IF;

IF l_agreement_in_rec.description  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.description := NULL;
END IF;

IF l_agreement_in_rec.desc_flex_name  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.desc_flex_name := NULL;
END IF;

IF l_agreement_in_rec.attribute_category  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute_category := NULL;
END IF;
IF l_agreement_in_rec.attribute1  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute1 := NULL;
END IF;

IF l_agreement_in_rec.attribute2  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute2 := NULL;
END IF;
IF l_agreement_in_rec.template_flag  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.template_flag := NULL;
END IF;

IF l_agreement_in_rec.attribute3  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute3 := NULL;
END IF;
IF l_agreement_in_rec.attribute4  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute4 := NULL;
END IF;
IF l_agreement_in_rec.attribute5  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute5 := NULL;
END IF;
IF l_agreement_in_rec.attribute6  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute6 := NULL;
END IF;
IF l_agreement_in_rec.attribute7  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute7 := NULL;
END IF;
IF l_agreement_in_rec.attribute8  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute8 := NULL;
END IF;
IF l_agreement_in_rec.attribute9  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute9 := NULL;
END IF;
IF l_agreement_in_rec.attribute10  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.attribute10 := NULL;
END IF;

IF l_agreement_in_rec.template_flag  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
	l_agreement_in_rec.template_flag := NULL;
END IF;

/* Start Bug 2701579  Initialized owning_organization_id,invoice_limit_flag
                           and agreement_currency_code */
IF l_agreement_in_rec.owning_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
        l_agreement_in_rec.owning_organization_id := NULL;
END IF;

IF l_agreement_in_rec.invoice_limit_flag  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.invoice_limit_flag := 'N';
END IF;

IF l_agreement_in_rec.agreement_currency_code  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
      SELECT pa_currency.get_currency_code
        INTO l_agreement_in_rec.agreement_currency_code from dual;
END IF;
/* End- Bug 2701579 */

/*Federal*/

IF l_agreement_in_rec.customer_order_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.customer_order_number := NULL;
END IF;

 /* Code commented for bug 5743599  syarts
IF l_agreement_in_rec.Advance_required  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.Advance_required := 'N';
END IF;
Code commented for bug 5743599 ends */

/* Code Added for bug 5743599 starts */

   PA_ADVANCE_CLIENT_EXT.advance_required(p_agreement_in_rec.customer_id,
	                                        x_advance_flag,
	    			                              x_error_message,
					                                x_status);

	 IF (x_status = 0 ) THEN
	    IF (x_advance_flag = TRUE) then
	       l_advance_flag := 'Y';
	    ELSE
	       l_advance_flag := 'N';
	    END IF;
   ELSE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CLNT_ADV_CHECK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_agreement_in_rec.pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
        END IF;
            p_return_status             := FND_API.G_RET_STS_ERROR;
	          RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_agreement_in_rec.Advance_required IS NOT NULL and
       l_agreement_in_rec.Advance_required <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then

       IF (FND_FUNCTION.TEST('PA_PAXINEAG_ADVREQ')) THEN
           null;
       ELSE
          l_agreement_in_rec.Advance_required := l_advance_flag;
       END IF;
   ELSE
          l_agreement_in_rec.Advance_required := l_advance_flag;
   END IF;

 /* Code Added for bug 5743599 ends */

IF l_agreement_in_rec.start_date  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
        l_agreement_in_rec.start_date := NULL;
END IF;

IF l_agreement_in_rec.Billing_sequence  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  Then
        l_agreement_in_rec.Billing_sequence := NUll;
END IF;

IF l_agreement_in_rec.line_of_account  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.line_of_account := NULL;
END IF;

IF l_agreement_in_rec.attribute11  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute11 := NULL;
END IF;

IF l_agreement_in_rec.attribute12  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute12 := NULL;
END IF;

IF l_agreement_in_rec.attribute13  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute13 := NULL;
END IF;

IF l_agreement_in_rec.attribute14  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute14 := NULL;
END IF;

IF l_agreement_in_rec.attribute15  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute15 := NULL;
END IF;

IF l_agreement_in_rec.attribute16  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute16 := NULL;
END IF;

IF l_agreement_in_rec.attribute17  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute17 := NULL;
END IF;

IF l_agreement_in_rec.attribute18  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute18 := NULL;
END IF;

IF l_agreement_in_rec.attribute19  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute19 := NULL;
END IF;

IF l_agreement_in_rec.attribute20  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute20 := NULL;
END IF;

IF l_agreement_in_rec.attribute21  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute21 := NULL;
END IF;

IF l_agreement_in_rec.attribute22  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute22 := NULL;
END IF;

IF l_agreement_in_rec.attribute23  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute23 := NULL;
END IF;

IF l_agreement_in_rec.attribute24  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute24 := NULL;
END IF;

IF l_agreement_in_rec.attribute25  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.attribute25 := NULL;
END IF;

   -- CREATE AGREEMENT
   pa_agreement_utils.create_agreement
   		(p_rowid         	=> l_row_id
                ,p_agreement_id	 	=> l_out_agreement_id
                ,p_customer_id      	=> l_agreement_in_rec.customer_id
                ,p_agreement_num    	=> l_agreement_in_rec.agreement_num
                ,p_agreement_type   	=> l_agreement_in_rec.agreement_type
                ,p_last_update_date 	=> SYSDATE
                ,p_last_updated_by  	=> G_USER_ID
                ,p_creation_date    	=> SYSDATE
                ,p_created_by           => G_USER_ID
                ,p_last_update_login    => G_LOGIN_ID
                ,p_owned_by_person_id   => l_agreement_in_rec.owned_by_person_id
                ,p_term_id 		=> l_agreement_in_rec.term_id
                ,p_revenue_limit_flag   => l_agreement_in_rec.revenue_limit_flag
                ,p_amount  		=> l_agreement_in_rec.amount
                ,p_description          => l_agreement_in_rec.description
                ,p_expiration_date      => l_agreement_in_rec.expiration_date
                ,p_attribute_category   => l_agreement_in_rec.attribute_category
                ,p_attribute1           => l_agreement_in_rec.attribute1
                ,p_attribute2           => l_agreement_in_rec.attribute2
                ,p_attribute3           => l_agreement_in_rec.attribute3
                ,p_attribute4           => l_agreement_in_rec.attribute4
                ,p_attribute5           => l_agreement_in_rec.attribute5
                ,p_attribute6           => l_agreement_in_rec.attribute6
                ,p_attribute7           => l_agreement_in_rec.attribute7
                ,p_attribute8           => l_agreement_in_rec.attribute8
                ,p_attribute9           => l_agreement_in_rec.attribute9
                ,p_attribute10          => l_agreement_in_rec.attribute10
		,p_template_flag	=> l_agreement_in_rec.template_flag
		,p_pm_agreement_reference => l_agreement_in_rec.pm_agreement_reference
		,p_pm_product_code	=> p_pm_product_code
/* MCB2 params begin */
                ,p_owning_organization_id => l_agreement_in_rec.owning_organization_id
                ,p_agreement_currency_code => l_agreement_in_rec.agreement_currency_code
                ,p_invoice_limit_flag   => l_agreement_in_rec.invoice_limit_flag
/*Federal*/
		,p_customer_order_number=> l_agreement_in_rec.customer_order_number
		,p_advance_required     => l_agreement_in_rec.advance_required
		,p_start_date           => l_agreement_in_rec.start_date
		,p_billing_sequence     => l_agreement_in_rec.billing_sequence
		,p_line_of_account      => l_agreement_in_rec.line_of_account
		,p_attribute11          => l_agreement_in_rec.attribute11
		,p_attribute12          => l_agreement_in_rec.attribute12
		,p_attribute13          => l_agreement_in_rec.attribute13
		,p_attribute14          => l_agreement_in_rec.attribute14
		,p_attribute15          => l_agreement_in_rec.attribute15
		,p_attribute16          => l_agreement_in_rec.attribute16
		,p_attribute17          => l_agreement_in_rec.attribute17
		,p_attribute18          => l_agreement_in_rec.attribute18
		,p_attribute19          => l_agreement_in_rec.attribute19
		,p_attribute20          => l_agreement_in_rec.attribute20
		,p_attribute21          => l_agreement_in_rec.attribute21
		,p_attribute22          => l_agreement_in_rec.attribute22
		,p_attribute23          => l_agreement_in_rec.attribute23
		,p_attribute24          => l_agreement_in_rec.attribute24
		,p_attribute25          => l_agreement_in_rec.attribute25);
/* MCB2 params end */

 p_agreement_out_rec.agreement_id:=l_out_agreement_id; /* Bug 2440551 */

   -- ADD FUNDING
     i := p_funding_in_tbl.first;

   WHILE i IS NOT NULL LOOP
	--Move the incoming record to a local record
	l_funding_in_rec 	:= p_funding_in_tbl(i);
	/* NOT REQUIRED
	--Get the unique Funding ID for this funding
	l_funding_id	:= p_funding_out_tbl(i).project_funding_id;
	*/
/* Added the below check to create an agreement even when no funding is there. Bug 5734567*/
if (l_funding_in_rec.project_id is NULL
or l_funding_in_rec.date_allocated is NULL
or l_funding_in_rec.allocated_amount is NULL
--or l_funding_in_rec.funding_category is NULL  /* Commented for the bug 6780803  */
or l_funding_in_rec.project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
or l_funding_in_rec.date_allocated = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
or l_funding_in_rec.allocated_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
--or l_funding_in_rec.funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) /* Commented for the bug 6780803  */
then
--dbms_output.put_line('Funding not entered. ');
exit;
end if;
/* End of Changes for Bug 5734567 */


/* Bug 2437469- BEGIN */

   SELECT invproc_currency_type INTO l_invproc_currency_type
   FROM pa_projects_all
   WHERE project_id=l_funding_in_rec.project_id;

   IF l_invproc_currency_type='FUNDING_CURRENCY'
     THEN
      BEGIN
        l_valid_currency:='Y';
        SELECT distinct funding_currency_code INTO l_old_fund_curr_code
        FROM pa_summary_project_fundings
        WHERE project_id=l_funding_in_rec.project_id
	and  not (total_baselined_amount = 0
	          and total_unbaselined_amount = 0); /* Added for bug 6510026 */

        IF (l_old_fund_curr_code<>l_agreement_in_rec.agreement_currency_code)
          THEN
              l_valid_currency:='N';
        END IF;

      EXCEPTION
        WHEN TOO_MANY_ROWS THEN
          l_valid_currency:='N';
        WHEN NO_DATA_FOUND THEN
          Null;
        WHEN OTHERS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END;

      IF l_valid_currency='N' THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CURR_NOT_VALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => l_agreement_in_rec.pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
     END IF;

/* Bug 2437469- END */


	pa_agreement_pub.add_funding
   		(p_api_version_number 	=> p_api_version_number
 		,p_commit		=> p_commit
 		,p_init_msg_list	=> p_init_msg_list
 		,p_msg_count	        => p_msg_count
 		,p_msg_data	        => p_msg_data
 		,p_return_status	=> l_return_status
 		,p_pm_product_code	=> p_pm_product_code
 		,p_pm_funding_reference	=> l_funding_in_rec.pm_funding_reference
 		,p_funding_id		=> l_funding_in_rec.project_funding_id
 		,p_pa_project_id	=> l_funding_in_rec.project_id
 		,p_pa_task_id	        => l_funding_in_rec.task_id
 		,p_agreement_id	        => l_out_agreement_id
 		,p_allocated_amount	=> l_funding_in_rec.allocated_amount
 		,p_date_allocated	=> l_funding_in_rec.date_allocated
 		,p_desc_flex_name	=> l_funding_in_rec.desc_flex_name
 		,p_attribute_category	=> l_funding_in_rec.attribute_category
 		,p_attribute1	        => l_funding_in_rec.attribute1
 		,p_attribute2	        => l_funding_in_rec.attribute2
 		,p_attribute3	        => l_funding_in_rec.attribute3
 		,p_attribute4	        => l_funding_in_rec.attribute4
 		,p_attribute5	        => l_funding_in_rec.attribute5
 		,p_attribute6	        => l_funding_in_rec.attribute6
 		,p_attribute7	        => l_funding_in_rec.attribute7
 		,p_attribute8	        => l_funding_in_rec.attribute8
 		,p_attribute9	        => l_funding_in_rec.attribute9
 		,p_attribute10	        => l_funding_in_rec.attribute10
 		,p_funding_id_out       => p_funding_out_tbl(i).project_funding_id
/* MCB2 params begin */
                ,p_project_rate_type    => l_funding_in_rec.project_rate_type
                ,p_project_rate_date    => l_funding_in_rec.project_rate_date
                ,p_project_exchange_rate => l_funding_in_rec.project_exchange_rate
                ,p_projfunc_rate_type    => l_funding_in_rec.projfunc_rate_type
                ,p_projfunc_rate_date    => l_funding_in_rec.projfunc_rate_date
                ,p_projfunc_exchange_rate => l_funding_in_rec.projfunc_exchange_rate
/* MCB2 params end */
                ,p_funding_category     => l_funding_in_rec.funding_category  /* For Bug2244796 */
             );


	-- Assign the return_status to the fudning out record
	p_funding_out_tbl(i).return_status := l_return_status;

   	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	THEN
--            	p_multiple_funding_msg := 'F';
          	RAISE FND_API.G_EXC_ERROR;
    	END IF;

	--Move to next funding in funding pl/sql table
	i := p_funding_in_tbl.next(i);

   END LOOP;

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

--END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR
		THEN
		ROLLBACK TO create_agreement_pub;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
		ROLLBACK TO create_agreement_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
		THEN
		ROLLBACK TO create_agreement_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END create_agreement;


-- =============================================================================
--
--Name:               delete_agreement
--Type:               Procedure
--Description:  This procedure can be used to delete an agreement for an
--              existing project or template.
--
--Called subprograms:
--			pa_interface_utils_pub.map_new_amg_msg
--			pa_agreement_pub.check_delete_agreement_ok
--			pa_agreement_pvt.convert_ag_ref_to_id
--			pa_agreement_utils.delete_agreement

--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE delete_agreement
(p_api_version_number	      IN	NUMBER
 ,p_commit	              IN	VARCHAR2
 ,p_init_msg_list	      IN	VARCHAR2
 ,p_msg_count	              OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data	              OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status	      OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_product_code	      IN	VARCHAR2
 ,p_pm_agreement_reference    IN	VARCHAR2
 ,p_agreement_id	      IN	NUMBER
 )
IS
-- Local Cursors
CURSOR l_funding_id_csr(p_agreement_id NUMBER)
IS
SELECT       project_funding_id,pm_funding_reference,agreement_id
FROM         pa_project_fundings f
WHERE        f.agreement_id = p_agreement_id;
-- Local variables
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_api_name					CONSTANT VARCHAR2(30):= 'delete_agreement';
l_return_status					VARCHAR2(1);
l_funding_id					NUMBER;
l_out_agreement_id				NUMBER ;
l_funding_id_rec 				l_funding_id_csr%ROWTYPE;
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT delete_agreement_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_DELETE_AGREEMENT',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;


    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Product Code
    IF (p_pm_product_code IS NULL)
       OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Agreement Reference
    IF (p_pm_agreement_reference IS NULL)
       OR (p_pm_agreement_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;
 /* NOT REQUIRED
    -- Agreement Id
    IF (p_agreement_id IS NULL)
       OR (p_agreement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	 pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
*/
     -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
     pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_agreement_reference => p_pm_agreement_reference
		,p_af_agreement_id => p_agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
     p_return_status             := l_return_status;
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS
     THEN
   	IF l_return_status = FND_API.G_RET_STS_ERROR
   	THEN
   		RAISE FND_API.G_EXC_ERROR;
   	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   	THEN
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	ELSE
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;
     END IF;

     -- VALIDATE THE INCOMING PARAMETERS
     IF pa_agreement_pvt.check_delete_agreement_ok
     		(p_agreement_id	=> p_agreement_id
		,p_pm_agreement_reference => p_pm_agreement_reference) = 'N'
     THEN
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- DELETE CORRESPONDING FUNDINGS FOR THE AGREEMENT
     OPEN l_funding_id_csr( l_out_agreement_id);
	LOOP
        FETCH l_funding_id_csr INTO l_funding_id_rec;
           IF l_funding_id_csr%NOTFOUND
           THEN
           	EXIT;
           ELSE
     		pa_agreement_pub.delete_funding
			( p_api_version_number 		=> p_api_version_number
          		,p_commit 			=> p_commit
          		,p_init_msg_list 		=> p_init_msg_list
          		,p_msg_count 			=> p_msg_count
          		,p_msg_data 			=> p_msg_data
          		,p_return_status 		=> p_return_status
          		,p_pm_product_code 		=> p_pm_product_code
          		,p_pm_funding_reference   	=> l_funding_id_rec.pm_funding_reference
 			,p_funding_id	      		=> l_funding_id
 			,p_check_y_n			=> 'N'	);
     		IF p_return_status <> FND_API.G_RET_STS_SUCCESS
     		THEN
   			IF p_return_status = FND_API.G_RET_STS_ERROR
   			THEN
   				RAISE FND_API.G_EXC_ERROR;
   			ELSIF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   			THEN
   				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   			ELSE
   				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   			END IF;
     		END IF;
            END IF;
 	END LOOP;
        CLOSE l_funding_id_csr;

         -- DELETE AGREEMENT

     	pa_agreement_utils.delete_agreement
     		(p_agreement_id => l_out_agreement_id);

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR
		THEN
		ROLLBACK TO delete_agreement_pub;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
		ROLLBACK TO delete_agreement_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN ROW_ALREADY_LOCKED
    		THEN
		ROLLBACK TO delete_agreement_pub;
		p_return_status := FND_API.G_RET_STS_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
      			FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_P_AMG');
      			FND_MESSAGE.SET_TOKEN('AGREEMENT',p_pm_agreement_reference);
      			FND_MSG_PUB.ADD;
		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
		THEN
		ROLLBACK TO delete_agreement_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END delete_agreement;

-- ============================================================================
--
--Name:               update_agreement
--Type:               Procedure
--Description:  This procedure can be used to update an agreement for an
--              existing project or template.
--
--Called subprograms:
--			pa_interface_utils_pub.map_new_amg_msg
--			pa_agreement_pub.check_update_agreement_ok
--			pa_agreement_utils.validate_flex_fields
--			pa_agreement_pvt.convert_ag_ref_to_id
--			pa_agreement_utils.update_agreement
--			pa_agreement_pub.add_funding
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      10-SEP-2001      Srividya                MCB2 code changes
-- ---------------------------------------------------------------------------

PROCEDURE update_agreement
(p_api_version_number	IN	NUMBER
 ,p_commit	        IN	VARCHAR2
 ,p_init_msg_list	IN	VARCHAR2
 ,p_msg_count	        OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data	        OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status	OUT	NOCOPY VARCHAR2
 ,p_pm_product_code	IN	VARCHAR2
 ,p_agreement_in_rec	IN	Agreement_Rec_In_Type
 ,p_agreement_out_rec	OUT	NOCOPY Agreement_Rec_Out_Type /*File.sql.39*/
 ,p_funding_in_tbl	IN	funding_in_tbl_type
 ,p_funding_out_tbl	OUT	NOCOPY funding_out_tbl_type /*File.sql.39*/
 )
IS
-- Local variables
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_out_agreement_id				NUMBER ;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'update_agreement';
i 						NUMBER;
l_funding_in_rec				funding_rec_in_type;
l_return_msg					VARCHAR2(2000);
l_row_id					VARCHAR2(2000);
l_validate_status				VARCHAR2(1);
l_funding_id					NUMBER;
l_agreement_in_rec                              Agreement_Rec_In_Type;  /* Added for Bug 3511175 */
                                                                  /* This l_agreement_in_rec will be used throughout this function
                                                                     in place of p_agreement_in_rec */

BEGIN
--  Standard begin of API savepoint

    SAVEPOINT update_agreement_pub;

l_agreement_in_rec:=p_agreement_in_rec;
--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_UPDATE_AGREEMENT',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;
    p_agreement_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;


    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Product Code
    IF (p_pm_product_code IS NULL)
       OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

/*Commented the validation for non mandatory parameter 'pm_agreement_reference' for bug 6601566
    -- Agreement Reference
    IF (l_agreement_in_rec.pm_agreement_reference IS NULL)
       OR (l_agreement_in_rec.pm_agreement_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
Commenting ends here */

/* Commented the validations for non mandatory parameters for bug 6602451
   -- Customer Id
    IF (l_agreement_in_rec.customer_ID IS NULL)
       OR (l_agreement_in_rec.customer_ID = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_CUST_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  l_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- Customer Number
    IF (l_agreement_in_rec.customer_num IS NULL)
       OR (l_agreement_in_rec.customer_num = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_CUST_NUM_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  l_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Agreement Type
    IF (l_agreement_in_rec.agreement_type IS NULL)
       OR (l_agreement_in_rec.agreement_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_TYPE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  l_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Agreement Number
    IF (l_agreement_in_rec.agreement_num IS NULL)
       OR (l_agreement_in_rec.agreement_num = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_NUM_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  l_agreement_in_rec.pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
Code commented ends here */

     -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
     pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_agreement_reference => l_agreement_in_rec.pm_agreement_reference
		,p_af_agreement_id => l_agreement_in_rec.agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
     p_agreement_out_rec.return_status := l_return_status;
     p_return_status             := l_return_status;


/*Commented code for bug 7110396
/* Start Bug 3511175  Initialized owning_organization_id,invoice_limit_flag
                           and agreement_currency_code
IF l_agreement_in_rec.owning_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
        l_agreement_in_rec.owning_organization_id := NULL;
END IF;

IF l_agreement_in_rec.invoice_limit_flag  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
        l_agreement_in_rec.invoice_limit_flag := 'N';
END IF;

IF l_agreement_in_rec.agreement_currency_code  =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
      SELECT pa_currency.get_currency_code
        INTO l_agreement_in_rec.agreement_currency_code from dual;
END IF;

 End- Bug 3511175 */




     -- VALIDATE THE INCOMING PARAMETERS
/* This part of code moved from while loop to here as check for project funding id is commented
    out in check_update_agreement_ok */
     IF pa_agreement_pvt.check_update_agreement_ok
     		(p_pm_agreement_reference  => l_agreement_in_rec.pm_agreement_reference
		,p_agreement_id 	   => l_out_agreement_id
		,p_funding_id 		   => NULL
		,p_customer_id		   => l_agreement_in_rec.customer_id
		,p_agreement_type	   => l_agreement_in_rec.agreement_type
		,p_term_id		   => l_agreement_in_rec.term_id
		,p_template_flag	   => l_agreement_in_rec.template_flag
		,p_revenue_limit_flag	   => l_agreement_in_rec.revenue_limit_flag
		,p_owned_by_person_id	   => l_agreement_in_rec.owned_by_person_id
/* MCB2 params begin */
                ,p_owning_organization_id  => l_agreement_in_rec.owning_organization_id
                ,p_agreement_currency_code => l_agreement_in_rec.agreement_currency_code
                ,p_invoice_limit_flag      => l_agreement_in_rec.invoice_limit_flag
/* MCB2 params end */
/*Federal*/
		,p_start_date                   => p_agreement_in_rec.start_date
		,p_end_date                     => p_agreement_in_rec.expiration_date
		,p_advance_required             => p_agreement_in_rec.advance_required
		,p_billing_sequence             => p_agreement_in_rec.billing_sequence
		,p_amount                       => p_agreement_in_rec.amount
               ) = 'N'
     THEN
   	p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
     i := p_funding_in_tbl.first;
     WHILE i IS NOT NULL LOOP
     --Move the incoming record to a local record
     l_funding_in_rec 	:= p_funding_in_tbl(i);

     --Move to next funding in funding pl/sql table
	i := p_funding_in_tbl.next(i);

/* Added the below check to update an agreement even when no funding is there. Bug 5734567 */
if (l_funding_in_rec.project_id is NULL
or l_funding_in_rec.date_allocated is NULL
or l_funding_in_rec.allocated_amount is NULL
--or l_funding_in_rec.funding_category is NULL  /* Commented for the bug 6780803  */
or l_funding_in_rec.project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
or l_funding_in_rec.date_allocated = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
or l_funding_in_rec.allocated_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
--or l_funding_in_rec.funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)  /* Commented for the bug 6780803  */
then
--dbms_output.put_line('Funding not entered. ');
exit;
end if;
/* End of Changes for Bug 5734567 */

   END LOOP;


     -- Flex Field Validations

/** Bug 2180350 - Replaced OR with AND in the following IF conmdition **/

     IF (l_agreement_in_rec.desc_flex_name IS NOT NULL)
       AND (l_agreement_in_rec.desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
     THEN
     pa_agreement_pvt.validate_flex_fields
   	(p_desc_flex_name         => l_agreement_in_rec.desc_flex_name
         ,p_attribute_category    => l_agreement_in_rec.attribute_category
         ,p_attribute1            => l_agreement_in_rec.attribute1
         ,p_attribute2            => l_agreement_in_rec.attribute2
         ,p_attribute3            => l_agreement_in_rec.attribute3
         ,p_attribute4            => l_agreement_in_rec.attribute4
         ,p_attribute5            => l_agreement_in_rec.attribute5
         ,p_attribute6            => l_agreement_in_rec.attribute6
         ,p_attribute7            => l_agreement_in_rec.attribute7
         ,p_attribute8            => l_agreement_in_rec.attribute8
         ,p_attribute9            => l_agreement_in_rec.attribute9
         ,p_attribute10           => l_agreement_in_rec.attribute10
         ,p_attribute11           => p_agreement_in_rec.attribute11
         ,p_attribute12           => p_agreement_in_rec.attribute12
         ,p_attribute13           => p_agreement_in_rec.attribute13
         ,p_attribute14           => p_agreement_in_rec.attribute14
         ,p_attribute15           => p_agreement_in_rec.attribute15
         ,p_attribute16           => p_agreement_in_rec.attribute16
         ,p_attribute17           => p_agreement_in_rec.attribute17
         ,p_attribute18           => p_agreement_in_rec.attribute18
         ,p_attribute19           => p_agreement_in_rec.attribute19
         ,p_attribute20           => p_agreement_in_rec.attribute20
         ,p_attribute21           => p_agreement_in_rec.attribute21
         ,p_attribute22           => p_agreement_in_rec.attribute22
         ,p_attribute23           => p_agreement_in_rec.attribute23
         ,p_attribute24           => p_agreement_in_rec.attribute24
         ,p_attribute25           => p_agreement_in_rec.attribute25
         ,p_return_msg            => l_return_msg
         ,p_validate_status       => l_validate_status
          );
     IF l_validate_status = 'N'
     THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FF_VALUES'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_agreement_out_rec.return_status := FND_API.G_RET_STS_ERROR;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;


     -- UPDATE AGREEMENT
     pa_agreement_utils.update_agreement
     		(p_agreement_id	 	 => l_out_agreement_id
                 ,p_customer_id          => l_agreement_in_rec.customer_id
                 ,p_agreement_num        => l_agreement_in_rec.agreement_num
                 ,p_agreement_type       => l_agreement_in_rec.agreement_type
                 ,p_last_update_date 	 => SYSDATE
                 ,p_last_updated_by  	 => G_USER_ID
                 ,p_last_update_login    => G_LOGIN_ID
                 ,p_owned_by_person_id   => l_agreement_in_rec.owned_by_person_id
                 ,p_term_id              => l_agreement_in_rec.term_id
                 ,p_revenue_limit_flag   => l_agreement_in_rec.revenue_limit_flag
                 ,p_amount               => l_agreement_in_rec.amount
                 ,p_description          => l_agreement_in_rec.description
                 ,p_expiration_date      => l_agreement_in_rec.expiration_date
                 ,p_attribute_category   => l_agreement_in_rec.attribute_category
                 ,p_attribute1           => l_agreement_in_rec.attribute1
                 ,p_attribute2           => l_agreement_in_rec.attribute2
                 ,p_attribute3           => l_agreement_in_rec.attribute3
                 ,p_attribute4           => l_agreement_in_rec.attribute4
                 ,p_attribute5           => l_agreement_in_rec.attribute5
                 ,p_attribute6           => l_agreement_in_rec.attribute6
                 ,p_attribute7           => l_agreement_in_rec.attribute7
                 ,p_attribute8           => l_agreement_in_rec.attribute8
                 ,p_attribute9           => l_agreement_in_rec.attribute9
                 ,p_attribute10          => l_agreement_in_rec.attribute10
		 ,p_template_flag	 => l_agreement_in_rec.template_flag
		 ,p_pm_agreement_reference => l_agreement_in_rec.pm_agreement_reference
		 ,p_pm_product_code	=> p_pm_product_code
/* MCB2 params begin */
                 ,p_owning_organization_id => l_agreement_in_rec.owning_organization_id
                 ,p_agreement_currency_code => l_agreement_in_rec.agreement_currency_code
                 ,p_invoice_limit_flag   => l_agreement_in_rec.invoice_limit_flag
/* MCB2 params end */
/*Federal*/
		,p_customer_order_number=> l_agreement_in_rec.customer_order_number
		,p_advance_required     => l_agreement_in_rec.advance_required
		,p_start_date           => l_agreement_in_rec.start_date
		,p_billing_sequence     => l_agreement_in_rec.billing_sequence
		,p_line_of_account      => l_agreement_in_rec.line_of_account
		,p_attribute11          => l_agreement_in_rec.attribute11
		,p_attribute12          => l_agreement_in_rec.attribute12
		,p_attribute13          => l_agreement_in_rec.attribute13
		,p_attribute14          => l_agreement_in_rec.attribute14
		,p_attribute15          => l_agreement_in_rec.attribute15
		,p_attribute16          => l_agreement_in_rec.attribute16
		,p_attribute17          => l_agreement_in_rec.attribute17
		,p_attribute18          => l_agreement_in_rec.attribute18
		,p_attribute19          => l_agreement_in_rec.attribute19
		,p_attribute20          => l_agreement_in_rec.attribute20
		,p_attribute21          => l_agreement_in_rec.attribute21
		,p_attribute22          => l_agreement_in_rec.attribute22
		,p_attribute23          => l_agreement_in_rec.attribute23
		,p_attribute24          => l_agreement_in_rec.attribute24
		,p_attribute25          => l_agreement_in_rec.attribute25
                );

        i := p_funding_in_tbl.first;
   	WHILE i IS NOT NULL LOOP
	--Move the incoming record to a local record
	l_funding_in_rec := p_funding_in_tbl(i);
	--Get the unique Funding ID for this funding
	/* NOT REQUIRED
	l_funding_id	:= p_funding_out_tbl(i).project_funding_id;
	*/

/* Added the below check to update an agreement even when no funding is there. Bug 5734567  */
if (l_funding_in_rec.project_id is NULL
or l_funding_in_rec.date_allocated is NULL
or l_funding_in_rec.allocated_amount is NULL
--or l_funding_in_rec.funding_category is NULL /* Commented for the bug 6780803  */
or l_funding_in_rec.project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
or l_funding_in_rec.date_allocated = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
or l_funding_in_rec.allocated_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
--or l_funding_in_rec.funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) /* Commented for the bug 6780803  */
then
--dbms_output.put_line('Funding not entered. ');
exit;
end if;
/* End of Changes for Bug 5734567 */

     IF pa_agreement_pvt.check_add_update(p_funding_reference => l_funding_in_rec.pm_funding_reference)='U'
     THEN
     	-- UPDATE FUNDING
    	 pa_agreement_pub.update_funding
   		(p_api_version_number 	=> p_api_version_number
 		,p_commit		=> p_commit
 		,p_init_msg_list	=> p_init_msg_list
 		,p_msg_count	        => p_msg_count
 		,p_msg_data	        => p_msg_data
 		,p_return_status	=> l_return_status
 		,p_pm_product_code	=> p_pm_product_code
 		,p_pm_funding_reference	=> l_funding_in_rec.pm_funding_reference
 		,p_funding_id		=> l_funding_in_rec.project_funding_id
 		,p_project_id		=> l_funding_in_rec.project_id
 		,p_task_id	        => l_funding_in_rec.task_id
 		,p_agreement_id	        => l_out_agreement_id
 		,p_allocated_amount	=> l_funding_in_rec.allocated_amount
 		,p_date_allocated	=> l_funding_in_rec.date_allocated
 		,p_desc_flex_name	=> l_funding_in_rec.desc_flex_name
 		,p_attribute_category	=> l_funding_in_rec.attribute_category
 		,p_attribute1	        => l_funding_in_rec.attribute1
 		,p_attribute2	        => l_funding_in_rec.attribute2
 		,p_attribute3	        => l_funding_in_rec.attribute3
 		,p_attribute4	        => l_funding_in_rec.attribute4
 		,p_attribute5	        => l_funding_in_rec.attribute5
 		,p_attribute6	        => l_funding_in_rec.attribute6
 		,p_attribute7	        => l_funding_in_rec.attribute7
 		,p_attribute8	        => l_funding_in_rec.attribute8
 		,p_attribute9	        => l_funding_in_rec.attribute9
 		,p_attribute10	        => l_funding_in_rec.attribute10
 		,p_funding_id_out       => p_funding_out_tbl(i).project_funding_id
/* MCB2 params begin */
                ,p_project_rate_type    => l_funding_in_rec.project_rate_type
                ,p_project_rate_date    => l_funding_in_rec.project_rate_date
                ,p_project_exchange_rate => l_funding_in_rec.project_exchange_rate
                ,p_projfunc_rate_type    => l_funding_in_rec.projfunc_rate_type
                ,p_projfunc_rate_date    => l_funding_in_rec.projfunc_rate_date
                ,p_projfunc_exchange_rate => l_funding_in_rec.projfunc_exchange_rate
/* MCB2 params end */
                ,p_funding_category      => l_funding_in_rec.funding_category  /* For Bug2244796 */
                );

	-- Assign the return_status to the task out record
	p_funding_out_tbl(i).return_status := l_return_status;

   	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	THEN
--            	p_multiple_funding_msg := 'F';
          	RAISE FND_API.G_EXC_ERROR;
    	END IF;

     ELSIF  pa_agreement_pvt.check_add_update(p_funding_reference => l_funding_in_rec.pm_funding_reference)='A'
     THEN
    	 -- ADD FUNDING
	 pa_agreement_pub.add_funding
   		(p_api_version_number 	=> p_api_version_number
 		,p_commit		=> p_commit
 		,p_init_msg_list	=> p_init_msg_list
 		,p_msg_count	        => p_msg_count
 		,p_msg_data	        => p_msg_data
 		,p_return_status	=> l_return_status
 		,p_pm_product_code	=> p_pm_product_code
 		,p_pm_funding_reference	=> l_funding_in_rec.pm_funding_reference
 		,p_funding_id		=> l_funding_in_rec.project_funding_id
 		,p_pa_project_id	=> l_funding_in_rec.project_id
 		,p_pa_task_id	        => l_funding_in_rec.task_id
 		,p_agreement_id	        => l_out_agreement_id
 		,p_allocated_amount	=> l_funding_in_rec.allocated_amount
 		,p_date_allocated	=> l_funding_in_rec.date_allocated
 		,p_desc_flex_name	=> l_funding_in_rec.desc_flex_name
 		,p_attribute_category	=> l_funding_in_rec.attribute_category
 		,p_attribute1	        => l_funding_in_rec.attribute1
 		,p_attribute2	        => l_funding_in_rec.attribute2
 		,p_attribute3	        => l_funding_in_rec.attribute3
 		,p_attribute4	        => l_funding_in_rec.attribute4
 		,p_attribute5	        => l_funding_in_rec.attribute5
 		,p_attribute6	        => l_funding_in_rec.attribute6
 		,p_attribute7	        => l_funding_in_rec.attribute7
 		,p_attribute8	        => l_funding_in_rec.attribute8
 		,p_attribute9	        => l_funding_in_rec.attribute9
 		,p_attribute10	        => l_funding_in_rec.attribute10
 		,p_funding_id_out       => p_funding_out_tbl(i).project_funding_id
/* MCB2 params begin */
                ,p_project_rate_type    => l_funding_in_rec.project_rate_type
                ,p_project_rate_date    => l_funding_in_rec.project_rate_date
                ,p_project_exchange_rate => l_funding_in_rec.project_exchange_rate
                ,p_projfunc_rate_type    => l_funding_in_rec.projfunc_rate_type
                ,p_projfunc_rate_date    => l_funding_in_rec.projfunc_rate_date
                ,p_projfunc_exchange_rate => l_funding_in_rec.projfunc_exchange_rate
/* MCB2 params end */
                ,p_funding_category      => l_funding_in_rec.funding_category  /* For Bug2244796 */
                );
	-- Assign the return_status to the task out record
	p_funding_out_tbl(i).return_status := l_return_status;

   	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    	ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    	THEN
--            	p_multiple_funding_msg := 'F';
          	RAISE FND_API.G_EXC_ERROR;
    	END IF;

    	END IF;

	--Move to next funding in funding pl/sql table
	i := p_funding_in_tbl.next(i);

   END LOOP;

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR
     	THEN
        p_return_status := FND_API.G_RET_STS_ERROR ;
        ROLLBACK TO update_agreement_pub;
        FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


      WHEN FND_API.G_EXC_UNEXPECTED_ERROR
      	THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         ROLLBACK TO update_agreement_pub;
         FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

      WHEN NO_DATA_FOUND
      	THEN
        pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_NO_DATA_FOUND'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');

    WHEN ROW_ALREADY_LOCKED THEN
	ROLLBACK TO update_project_pub;
	p_return_status := FND_API.G_RET_STS_ERROR;
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	    THEN
      		FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_P_AMG');
      		FND_MESSAGE.SET_TOKEN('AGREEMENT',l_agreement_in_rec.pm_agreement_reference);
      		FND_MESSAGE.SET_TOKEN('FUNDING',l_funding_in_rec.pm_funding_reference);
      		FND_MSG_PUB.ADD;
	    END IF;

	FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

    WHEN OTHERS
    	THEN
        ROLLBACK TO update_agreement_pub;
        p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
        END IF;
        FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END update_agreement;


-- ============================================================================
--
--Name:               add_funding
--Type:               Procedure
--Description:  This procedure can be used to create funding for an existing  for an
--              agreement.
--
--Called subprograms:
--			pa_interface_utils_pub.map_new_amg_msg
--			pa_agreement_pub.check_add_funding_ok
--			pa_agreement_utils.validate_flex_fields
--			pa_agreement_pvt.convert_fu_ref_to_id
--			pa_agreement_utils.add_funding
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      11-JUN-2002      Raji  - Modified for Bug 2403652
-- ---------------------------------------------------------------------------

PROCEDURE add_funding
(p_api_version_number	        IN	NUMBER
 ,p_commit	                IN	VARCHAR2
 ,p_init_msg_list	        IN	VARCHAR2
 ,p_msg_count	                OUT NOCOPY	NUMBER /*File.sql.39*/
 ,p_msg_data	                OUT NOCOPY 	VARCHAR2 /*File.sql.39*/
 ,p_return_status	        OUT	NOCOPY VARCHAR2/*File.sql.39*/
 ,p_pm_product_code	        IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN OUT NOCOPY	NUMBER  /*File.sql.39*/
 ,p_pa_project_id	        IN	NUMBER
 ,p_pa_task_id	                IN	NUMBER
 ,p_agreement_id	        IN	NUMBER
 ,p_allocated_amount	        IN	NUMBER
 ,p_date_allocated	        IN	DATE
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_attribute_category	        IN	VARCHAR2
 ,p_attribute1	                IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10	                IN	VARCHAR2
 ,p_funding_id_out	        OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'
 /* Added for Bug 2483081 to include Default Value- For Bug 2244796 */
)
IS
-- Local variables
l_msg_count					NUMBER ;
l_validate_status				VARCHAR2(1);
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_out_agreement_id				NUMBER ;
l_out_funding_id				NUMBER;
l_customer_id					NUMBER;
l_return_msg					VARCHAR2(2000);
l_row_id					VARCHAR2(2000);
l_api_name					CONSTANT VARCHAR2(30):= 'add_funding';
l_pa_task_id	                		NUMBER;
l_desc_flex_name				VARCHAR2(240);
l_attribute_category				VARCHAR2(30);
l_attribute1	                		VARCHAR2(150);
l_attribute2	                		VARCHAR2(150);
l_attribute3	                		VARCHAR2(150);
l_attribute4	                		VARCHAR2(150);
l_attribute5	                		VARCHAR2(150);
l_attribute6	                		VARCHAR2(150);
l_attribute7	                		VARCHAR2(150);
l_attribute8	                		VARCHAR2(150);
l_attribute9	                		VARCHAR2(150);
l_attribute10	                		VARCHAR2(150);
l_resize_flag                                   VARCHAR2(1);     /* Added for bug 2902096 */
l_funding_category                              VARCHAR2(30);    /* Added for bug 2838872 */

/*Start of bug 5554070*/
l_project_rate_type      PA_PROJECT_FUNDINGS.PROJECT_RATE_TYPE%type;
l_projfunc_rate_type     PA_PROJECT_FUNDINGS.PROJFUNC_RATE_TYPE%type;
l_projfunc_rate_date     PA_PROJECT_FUNDINGS.PROJFUNC_RATE_DATE%type;
l_project_rate_date      PA_PROJECT_FUNDINGS.PROJECT_RATE_DATE%type;
/*End of bug 5554070*/

l_err_code         number;
l_err_msg          VARCHAR2(50);

BEGIN
--  Standard begin of API savepoint

    SAVEPOINT add_funding_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

  -- This call is added for patchset K project role based security check

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_pa_project_id;


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_ADD_FUNDING',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST


    -- Product Code
    IF (p_pm_product_code IS NULL)
       OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

   /* NOT REQUIRED
   -- Agreement Reference
    IF (p_pm_agreement_reference IS NULL)
       OR (p_pm_agreement_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;


    --  Project Reference
    IF (p_pm_project_reference IS NULL)
       OR (p_pm_project_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_PROJ_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
      */

  --  Code added for Bug 2403652 starts here

  --  Funding category
/*  Commented for 2483081 */
/*    IF (p_funding_category IS NULL)
       OR (p_funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUND_CAT_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'GENERAL'
                        ,p_attribute1       => ''
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status             := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
*/

  --  Validate funding category
      /* Added IF condition for bug 2838872 */
       IF (p_funding_category IS NULL)
           OR (p_funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
       THEN
           l_funding_category := 'ADDITIONAL';
       ELSE
           l_funding_category := p_funding_category;
       END IF;

       IF pa_agreement_pvt.check_funding_category
               (p_pa_project_id
               ,p_pa_task_id
               ,p_agreement_id
               ,p_pm_funding_reference
               ,l_funding_category        ) = 'N'
       THEN
                p_return_status             := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
       END IF;

--  Code added for Bug 2403652 ends here


    --  Funding Reference
    IF (p_pm_funding_reference IS NULL)
       OR (p_pm_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Project Id
    IF (p_pa_project_id IS NULL)
       OR (p_pa_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_PROJ_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Task Id
/*
    IF (p_pa_task_id IS NULL)
       OR (p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_TASK_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
  */
    -- Date Allocated
    IF (p_date_allocated IS NULL)
       OR (p_date_allocated = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_DATE_ALLOC_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    --  Allocated Amount
    IF (p_allocated_amount IS NULL)
       OR (p_allocated_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_ALLOC_AMT_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
--	ELSE
--         select amount into l_nik from pa_agreements_all where agreement_id = p_agreement_id;
     END IF;

    -- Agreement Id
    IF (p_agreement_id IS NULL)
       OR (p_agreement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- VALIDATE THE INCOMING PARAMETERS
	SELECT a. customer_id
	INTO l_customer_id
	FROM pa_agreements_all a
	WHERE a.agreement_id = p_agreement_id;
     IF pa_agreement_pvt.check_add_funding_ok
     	(p_project_id		         => p_pa_project_id
 	 ,p_task_id			 => p_pa_task_id
 	 ,p_agreement_id		 => p_agreement_id
 	 ,p_pm_funding_reference	 => p_pm_funding_reference
 	 ,p_funding_amt			 => p_allocated_amount
 	 ,p_customer_id			 => l_customer_id
/* MCB2 PARAMETERS BEGIN */
         ,p_project_rate_type		 => p_project_rate_type
	 ,p_project_rate_date		 => p_project_rate_date
	 ,p_project_exchange_rate	 => p_project_exchange_rate
         ,p_projfunc_rate_type		 => p_projfunc_rate_type
	 ,p_projfunc_rate_date		 => p_projfunc_rate_date
	 ,p_projfunc_exchange_rate	 => p_projfunc_exchange_rate ) = 'N'
/* MCB2 PARAMETERS END */

     THEN
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- Flex Field Validations
     IF (p_desc_flex_name IS NOT NULL)
       AND (p_desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
--       OR (p_desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
     THEN
     pa_agreement_pvt.validate_flex_fields
   	(p_desc_flex_name         => p_desc_flex_name
         ,p_attribute_category    => p_attribute_category
         ,p_attribute1            => p_attribute1
         ,p_attribute2            => p_attribute2
         ,p_attribute3            => p_attribute3
         ,p_attribute4            => p_attribute4
         ,p_attribute5            => p_attribute5
/**      ,p_attribute6            => p_attribute7 ** commented bug 2862922 **/
         ,p_attribute6            => p_attribute6 /** added bug 2862922 **/
         ,p_attribute7            => p_attribute7 /** added bug 2862922 **/
         ,p_attribute8            => p_attribute8
         ,p_attribute9            => p_attribute9
         ,p_attribute10           => p_attribute10
         ,p_return_msg            => l_return_msg
         ,p_validate_status       => l_validate_status
          );
     IF l_validate_status = 'N'
     THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FF_VALUES'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;

/*   NOT REQUIRED
     -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
     pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_agreement_reference => p_pm_agreement_reference
		,p_af_agreement_id => p_agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
     p_return_status 		 := l_return_status;


     -- CONVERT PROJECT REFERENCE TO PROJECT ID
     pa_project_pvt.convert_pm_projref_to_id
     		(p_pm_project_reference => p_pm_project_reference
     		,p_pa_project_id        => p_project_id
     		,p_out_project_id       => l_out_project_id
     		,p_return_status        => l_return_status);
     p_return_status             := l_return_status;

 */
     /* NOT REQUIRED
     -- CONVERT FUNDING REFERENCE TO FUNDING ID
     pa_agreement_pvt.convert_fu_ref_to_id
     		(p_pm_funding_reference  => p_pm_funding_reference
		,p_af_funding_id    => p_funding_id
		,p_out_funding_id   => l_out_funding_id
		,p_return_status    => l_return_status);
     p_return_status             := l_return_status;
*/
--HERE
--TO BE CORRECTED - BUDGET_TYPE_CODE - NIKHIL
IF p_pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_pa_task_id IS NOT NULL THEN
	l_pa_task_id	:= p_pa_task_id;
ELSIF 	p_pa_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM then
l_pa_task_id := NULL;
END IF;


/* 2315767 Added Else condition for all the Flex Field Attributes
so that proper value is passed if corresponding p_attribute's are not NULL
or not the default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR */
IF p_desc_flex_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_desc_flex_name:= NULL;
ELSE
   l_desc_flex_name := p_desc_flex_name;
END IF;
IF p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute_category := NULL;
ELSE
   l_attribute_category := p_attribute_category;
END IF;
IF p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute1 := NULL;
ELSE
   l_attribute1 := p_attribute1;
END IF;
IF p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute2 := NULL;
ELSE
   l_attribute2 := p_attribute2;
END IF;
IF p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute3 := NULL;
ELSE
   l_attribute3 := p_attribute3;/* 2315767 Modified l_attribute4 to l_attribute3 */
END IF;
/* 2315767 Added code for attribute4 of flexfield */
IF p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute4 := NULL;
ELSE
   l_attribute4 := p_attribute4;
END IF;
IF p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute5 := NULL;
ELSE
   l_attribute5 := p_attribute5;
END IF;
IF p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute6 := NULL;
ELSE
   l_attribute6 := p_attribute6;
END IF;
IF p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute7 := NULL;
ELSE
   l_attribute7 := p_attribute7;
END IF;
IF p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute8 := NULL;
ELSE
   l_attribute8 := p_attribute8;
END IF;
IF p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute9 := NULL;
ELSE
   l_attribute9 := p_attribute9;
END IF;
IF p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
        l_attribute10 := NULL;
ELSE
   l_attribute10 := p_attribute10;
END IF;

/* Changes for bug 5554070-Start */

IF p_project_rate_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
   l_project_rate_type := null;
else
   l_project_rate_type :=p_project_rate_type;
end if;

If p_projfunc_rate_type  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
   l_projfunc_rate_type :=null;
else
    l_projfunc_rate_type := p_projfunc_rate_type;
end if;

If p_projfunc_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
   l_projfunc_rate_date :=null;
else
    l_projfunc_rate_date := p_projfunc_rate_date;
end if;

If p_project_rate_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN
   l_project_rate_date :=null;
else
    l_project_rate_date := p_project_rate_date;
end if;

/* Changes for bug 5554070-End */



     -- ADD FUNDING
     pa_agreement_utils.create_funding(
     			p_Rowid			=> l_row_id,
     			p_Project_Funding_Id	=> p_funding_id,
                        p_Last_Update_Date	=> SYSDATE,
                        p_Last_Updated_By	=> G_USER_ID,
                        p_Creation_Date		=> SYSDATE,
                        p_Created_By		=> G_USER_ID,
                        p_Last_Update_Login	=> G_LOGIN_ID,
                        p_Agreement_Id		=> p_agreement_id,
                        p_Project_Id		=> p_pa_project_id,
                        p_Task_Id		=> l_pa_task_id,
                        p_Allocated_Amount	=> p_allocated_amount,
                        p_Date_Allocated	=> p_date_allocated,
                        p_Attribute_Category	=> l_attribute_category,
                        p_Attribute1		=> l_attribute1,
                        p_Attribute2		=> l_attribute2,
                        p_Attribute3		=> l_attribute3,
                        p_Attribute4		=> l_attribute4,
                        p_Attribute5		=> l_attribute5,
                        p_Attribute6		=> l_attribute6,
                        p_Attribute7		=> l_attribute7,
                        p_Attribute8		=> l_attribute8,
                        p_Attribute9		=> l_attribute9,
                        p_Attribute10		=> l_attribute10,
                        p_pm_funding_reference  => p_pm_funding_reference,
		        p_pm_product_code	=> p_pm_product_code,
/* MCB2 PARAMETERS BEGIN 5554070 Chaged to new introduced variable */
			p_project_rate_type	 => l_project_rate_type,
			p_project_rate_date	 => l_project_rate_date,
			p_project_exchange_rate	 => p_project_exchange_rate,
			p_projfunc_rate_type	 => l_projfunc_rate_type,
			p_projfunc_rate_date	 => l_projfunc_rate_date,
			p_projfunc_exchange_rate => p_projfunc_exchange_rate,
                        x_err_code               => l_err_code,
                        x_err_msg                => l_err_msg,
                        p_funding_category       => l_funding_category   /* For Bug 2244796 */
 );

/* MCB2 PARAMETERS END */


     IF l_err_code <> 0 THEN

/* Following code added for bug 2902096 .The l_resize_flag is set to 'Y' only for some
   error messages whose length of message_name will go above 30 if '_AMG' is added to it.
   These messages can be used straightaway without using the '_AMG' as the message text is same .*/
/* Added some more error messages in the IF condition for bug 2967759 */
     l_resize_flag:='N';
     IF (l_err_msg in ('PA_USR_RATE_NOT_ALLOWED_FC_PC','PA_USR_RATE_NOT_ALLOWED_FC_PF',
                       'PA_USR_RATE_NOT_ALLOWED_BC_PF','PA_NO_EXCH_RATE_EXISTS_BC_PF',
                       'PA_NO_EXCH_RATE_EXISTS_FC_PC','PA_NO_EXCH_RATE_EXISTS_FC_PF')) THEN
         l_resize_flag:='Y';
     END IF;

/* End - Bug 2902096 */

   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => l_err_msg
            		,p_msg_attribute    => 'CHANGE'
                /*      ,p_resize_flag      => 'N' changed for bug 2902096 */
            		,p_resize_flag      => l_resize_flag
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;

     ELSE

       -- UPDATE SUMMARY PROJECT FUNDINGS
          pa_agreement_utils.summary_funding_insert_row
     		(p_agreement_id => p_agreement_id
 		,p_project_id   => p_pa_project_id
 		,p_task_id      => p_pa_task_id
 		,p_login_id     => G_LOGIN_ID
 		,p_user_id      => G_USER_ID);

          IF FND_API.to_boolean( p_commit ) THEN
	     COMMIT;
          END IF;

     END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR
		THEN
		ROLLBACK TO add_funding_pub;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
		ROLLBACK TO add_funding_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
		THEN
		ROLLBACK TO add_funding_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END add_funding;

-- ============================================================================
--
--Name:               delete_funding
--Type:               Procedure
--Description:  This procedure can be used to delete funding for an existing for an
--              agreement.
--
--Called subprograms:
--			pa_interface_utils_pub.map_new_amg_msg
--			pa_agreement_pub.check_delete_funding_ok
--			pa_agreement_pvt.convert_fu_ref_to_id
--			pa_agreement_utils.delete_agreement
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------
PROCEDURE delete_funding
(p_api_version_number	        IN	NUMBER
 ,p_commit	                IN	VARCHAR2
 ,p_init_msg_list	        IN	VARCHAR2
 ,p_msg_count	                OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data	                OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status	        OUT	NOCOPY VARCHAR2/*File.sql.39*/
 ,p_pm_product_code	        IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id	                IN	NUMBER
 ,p_check_y_n			IN	VARCHAR2
 )
IS
-- Local variables
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_funding_id					NUMBER;
l_out_funding_id				NUMBER;
l_agreement_id					NUMBER;
l_project_id 					NUMBER;
l_task_id 					NUMBER;
l_out_agreement_id				NUMBER ;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'delete_funding';

/* adding variables for bug 2868818*/

CURSOR c1
IS
SELECT f.funding_category
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_pm_funding_reference;

l_fund_rec1 c1%ROWTYPE;
l_funding_category      VARCHAR2(30);

/* end adding variables for bug 2868818*/

BEGIN
--  Standard begin of API savepoint

    SAVEPOINT delete_funding_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;


-- This call is added for patchset K project role based security check

        -- Get the project id from this project funding line
         l_project_id := pa_agreement_utils.get_project_id(p_funding_id => p_funding_id,
                                                   p_funding_reference => p_pm_funding_reference);

        PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

-- End of the security changes


    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_DELETE_FUNDING',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Product Code
    IF (p_pm_product_code IS NULL)
       OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_CUST_NUM_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Funding Reference
    IF (p_pm_funding_reference IS NULL)
       OR (p_pm_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

/* NOT REQUIRED
    -- Funding Id
    IF (p_funding_id IS NULL)
       OR (p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
  */
    /* code change for bug 2868818*/

    open c1;
    fetch c1 into l_fund_rec1;
    if c1%found then
        l_funding_category := l_fund_rec1.funding_category;
    end if;
    close c1;

    IF l_funding_category = 'REVALUATION'
    THEN
    pa_interface_utils_pub.map_new_amg_msg
        ( p_old_message_code => 'PA_UPDATE_DELETE_REVAL'
        ,p_msg_attribute    => 'CHANGE'
        ,p_resize_flag      => 'N'
        ,p_msg_context      => 'GENERAL'
        ,p_attribute1       => ''
        ,p_attribute2       => ''
        ,p_attribute3       => ''
        ,p_attribute4       => ''
        ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* end code change for bug 2868818*/

   -- - NIKHIL
     -- VALIDATE THE INCOMING PARAMETERS
-- NIKHIL added if statement to make it a point while deleting funding for
-- with an agreement it should not check for validity
-- start

  IF p_check_y_n = 'Y' THEN
     IF pa_agreement_pvt.check_delete_funding_ok
     		(p_agreement_id	=> pa_agreement_utils.get_agreement_id(	p_funding_id => p_funding_id
									,p_funding_reference => p_pm_funding_reference)
     		,p_funding_id	=> pa_agreement_utils.get_funding_id(p_funding_reference => p_pm_funding_reference)
		,p_pm_funding_reference => p_pm_funding_reference) = 'N'
     THEN
     	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF;
-- End
     -- CONVERT FUNDING REFERENCE TO FUNDING ID

     pa_agreement_pvt.convert_fu_ref_to_id
     		(p_pm_funding_reference  => p_pm_funding_reference
		,p_af_funding_id    => p_funding_id
		,p_out_funding_id   => l_out_funding_id
		,p_return_status    => l_return_status);
     p_return_status             := l_return_status;


     -- GET THE VALUES OF AGREEMENT ID, FUNDING ID AND PROJECT ID BEFORE DELETING THE FUNDING
     l_agreement_id :=  pa_agreement_utils.get_agreement_id (p_funding_id => p_funding_id
							    ,p_funding_reference => p_pm_funding_reference);
     l_project_id := pa_agreement_utils.get_project_id(p_funding_id => p_funding_id
					              ,p_funding_reference => p_pm_funding_reference);
     l_task_id := pa_agreement_utils.get_task_id(p_funding_id => p_funding_id
					        ,p_funding_reference => p_pm_funding_reference);



     -- DELETE FUNDING
     pa_agreement_utils.delete_funding
     		(p_project_funding_id =>l_out_funding_id);

   -- TO BE CORRECTED - NIKHIL
     -- UPDATE SUMMARY PROJECT FUNDINGS
     pa_agreement_utils.summary_funding_delete_row
     		(p_agreement_id => l_agreement_id
     		,p_project_id   => l_project_id
 		,p_task_id      => l_task_id
 		,p_login_id     => G_LOGIN_ID
 		,p_user_id      => G_USER_ID );
    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR
		THEN
	 	ROLLBACK TO delete_funding_pub;
	 	p_return_status := FND_API.G_RET_STS_ERROR;
	 	FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
	   	ROLLBACK TO delete_funding_pub;
	   	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   	FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN ROW_ALREADY_LOCKED
		THEN
	   	ROLLBACK TO delete_funding_pub;
	   	p_return_status := FND_API.G_RET_STS_ERROR;
	   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
      			FND_MESSAGE.SET_NAME('PA','PA_ROW_ALREADY_LOCKED_T_AMG');
      			FND_MESSAGE.SET_TOKEN('FUNDING',p_pm_funding_reference);
      			FND_MSG_PUB.ADD;
		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
		THEN
	   	ROLLBACK TO delete_funding_pub;
       	   	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    	THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	   	END IF;
	   	FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END delete_funding;


-- ============================================================================
--
--Name:               update_funding
--Type:               Procedure
--Description:  This procedure can be used to update funding for an agreement.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      11-JUN-2002      Raji - code added for bug 2403652
-- ---------------------------------------------------------------------------

PROCEDURE update_funding
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_product_code		IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_agreement_id		IN	NUMBER
 ,p_allocated_amount		IN	NUMBER
 ,p_date_allocated		IN	DATE
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1	                IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_funding_id_out		OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'
 /* Added for Bug 2512483 Default Value- For Bug 2244796 */
)
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_msg			VARCHAR2(2000);
l_validate_status		VARCHAR2(1);
l_row_id			VARCHAR2(2000);
i 				NUMBER;
l_funding_id			NUMBER;
l_out_funding_id		NUMBER;
l_out_agreement_id		NUMBER ;
l_return_status			VARCHAR2(1);
l_api_name			CONSTANT VARCHAR2(30):= 'update_funding';
l_resize_flag                                   VARCHAR2(1);     /* Added for bug 2902096 */

l_err_code         number;
l_err_msg          VARCHAR2(50);

/* adding variables for bug 2868818*/

CURSOR c1
IS
SELECT f.funding_category
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_pm_funding_reference
AND f.funding_category = 'REVALUATION';/* Added this condition for 3360593*/

l_fund_rec1 c1%ROWTYPE;
l_funding_category      VARCHAR2(30);

/* end adding variables for bug 2868818*/
BEGIN
--  Standard begin of API savepoint
    SAVEPOINT update_funding_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- This call is added for patchset K project role based security check

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_project_id;


    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_UPDATE_FUNDING',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Product Code
    IF (p_pm_product_code IS NULL)
       OR (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
         		  ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
	 END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* Bug 5686790. If Miss char is passed then this check is not required, as
    customer doesn't want to change the funding category*/

 IF (p_funding_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
--  Code added for Bug 2403652 starts here

  --  Funding category is NULL
      /* Added IF condition for bug 2838872 */
    IF (p_funding_category IS NULL)
       /*OR (p_funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
         Bug 5686790 */
    THEN
        l_funding_category := 'ADDITIONAL';
    ELSE
        l_funding_category := p_funding_category;
/*****    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUND_CAT_IS_MISS'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'GENERAL'
                        ,p_attribute1       => ''
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         p_return_status             := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
*** Commented for bug 2838872 ***/
     END IF;

  --  Validate funding category

    IF pa_agreement_pvt.check_funding_category
       (p_project_id
       ,p_task_id
       ,p_agreement_id
       ,p_pm_funding_reference
       ,upper(l_funding_category)) = 'N'--Added upper for 3360593
     THEN
         p_return_status             := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
  END IF; /* l_funding_category is mischar*/

 --  Code added for Bug 2403652 ends here


    -- Funding Reference
    IF (p_pm_funding_reference IS NULL)
       OR (p_pm_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
  /* NOT REQUIED
     -- Funding Id
     IF (p_funding_id IS NULL)
       OR (p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
     THEN
     	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
  */

    /* code change for bug 2868818*/

    open c1;
    fetch c1 into l_fund_rec1;
    if c1%found then
        l_funding_category := l_fund_rec1.funding_category;
    end if;
    close c1;


    IF l_funding_category = 'REVALUATION'
    THEN
    pa_interface_utils_pub.map_new_amg_msg
        ( p_old_message_code => 'PA_UPDATE_DELETE_REVAL'
        ,p_msg_attribute    => 'CHANGE'
        ,p_resize_flag      => 'N'
        ,p_msg_context      => 'GENERAL'
        ,p_attribute1       => ''
        ,p_attribute2       => ''
        ,p_attribute3       => ''
        ,p_attribute4       => ''
        ,p_attribute5       => '');

        p_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


/* Moved the following function call from below to this place bug 2434153 **/
        -- CONVERT FUNDING REFERENCE TO FUNDING ID
        pa_agreement_pvt.convert_fu_ref_to_id
                (p_pm_funding_reference  => p_pm_funding_reference
                ,p_af_funding_id    => p_funding_id
                ,p_out_funding_id   => l_out_funding_id
                ,p_return_status    => l_return_status);
        p_return_status             := l_return_status;

    /* end code change for bug 2868818*/
/** changed p_funding_id to l_out_funding_id in call to check_update_funding_ok  bug 2434153 **/
     -- TO BE CORRECTED - NIKHIL
      	-- VALIDATE THE INCOMING PARAMETERS
      	IF pa_agreement_pvt.check_update_funding_ok
      	  (p_project_id			 => p_project_id
 	   ,p_task_id			 => p_task_id
 	   ,p_agreement_id		 => p_agreement_id
 	   ,p_customer_id		 => pa_agreement_utils.get_customer_id
 					(p_funding_id => l_out_funding_id
 					,p_funding_reference => p_pm_funding_reference)
 	   ,p_pm_funding_reference       => p_pm_funding_reference
 	   ,p_funding_id		 => l_out_funding_id
 	   ,p_funding_amt                => p_allocated_amount
/* MCB2 PARAMETERS BEGIN */
           ,p_project_rate_type		 => p_project_rate_type
	   ,p_project_rate_date		 => p_project_rate_date
	   ,p_project_exchange_rate	 => p_project_exchange_rate
           ,p_projfunc_rate_type	 => p_projfunc_rate_type
	   ,p_projfunc_rate_date	 => p_projfunc_rate_date
	   ,p_projfunc_exchange_rate	 => p_projfunc_exchange_rate ) = 'N'
/* MCB2 PARAMETERS END */

 	THEN
		p_return_status             := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
        END IF;


      -- Flex Field Validations
     IF (p_desc_flex_name IS NOT NULL)
       AND (p_desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
-- Nikhil        OR (p_desc_flex_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
     THEN
     pa_agreement_pvt.validate_flex_fields
   	(p_desc_flex_name         => p_desc_flex_name
         ,p_attribute_category    => p_attribute_category
         ,p_attribute1            => p_attribute1
         ,p_attribute2            => p_attribute2
         ,p_attribute3            => p_attribute3
         ,p_attribute4            => p_attribute4
         ,p_attribute5            => p_attribute5
/**      ,p_attribute6            => p_attribute7 ** commented bug 2862922 **/
         ,p_attribute6            => p_attribute6 /** added bug 2862922 **/
         ,p_attribute7            => p_attribute7 /** added bug 2862922 **/
         ,p_attribute8            => p_attribute8
         ,p_attribute9            => p_attribute9
         ,p_attribute10           => p_attribute10
         ,p_return_msg            => l_return_msg
         ,p_validate_status       => l_validate_status
          );
     IF l_validate_status = 'N'
     THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FF_VALUES'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;

       /* NOT REQUIRED
        -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
        pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_ag_reference => p_agreement_in_rec.pm_agreement_reference
		,p_af_agreement_id => pa_agreement_in_rec.agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
        p_return_status             := l_return_status;

        */

        -- CONVERT FUNDING REFERENCE TO FUNDING ID
/****        pa_agreement_pvt.convert_fu_ref_to_id
     		(p_pm_funding_reference  => p_pm_funding_reference
		,p_af_funding_id    => p_funding_id
		,p_out_funding_id   => l_out_funding_id
		,p_return_status    => l_return_status);
        p_return_status             := l_return_status;
***** Commented bug 2434153 **/

     /* Added for bug 5686790*/

      IF (p_funding_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
          SELECT funding_category
            INTO l_funding_category
           FROM pa_project_fundings
           WHERE PROJECT_FUNDING_ID = l_out_funding_id;
      END IF;


      -- TO BE CORRECTED - NIKHIL
        -- UPDATE FUNDING
        pa_agreement_utils.update_funding
     		(p_project_funding_id   => l_out_funding_id
                ,p_last_update_date 	=> SYSDATE
                ,p_last_updated_by  	=> G_USER_ID
                ,p_last_update_login    => G_LOGIN_ID
                ,p_agreement_id         => p_agreement_id
                ,p_project_id           => p_project_id
                ,p_task_id              => p_task_id
                ,p_allocated_amount     => p_allocated_amount
                ,p_date_allocated       => p_date_allocated
                ,p_attribute_category   => p_attribute_category
                ,p_attribute1           => p_attribute1
                ,p_attribute2           => p_attribute2
                ,p_attribute3           => p_attribute3
                ,p_attribute4           => p_attribute4
                ,p_attribute5           => p_attribute5
                ,p_attribute6           => p_attribute6
                ,p_attribute7           => p_attribute7
                ,p_attribute8           => p_attribute8
                ,p_attribute9           => p_attribute9
                ,p_attribute10          => p_attribute10
                ,p_pm_funding_reference => p_pm_funding_reference
		,p_pm_product_code	=> p_pm_product_code
/* MCB2 PARAMETERS BEGIN */
		,p_project_rate_type	 => p_project_rate_type
		,p_project_rate_date	 => p_project_rate_date
		,p_project_exchange_rate => p_project_exchange_rate
		,p_projfunc_rate_type	 => p_projfunc_rate_type
		,p_projfunc_rate_date	 => p_projfunc_rate_date
		,p_projfunc_exchange_rate => p_projfunc_exchange_rate
                ,x_err_code               => l_err_code
                ,x_err_msg                => l_err_msg
                ,p_funding_category       => l_funding_category   /* For Bug 2244796 */
 );
/* MCB2 PARAMETERS END */

     IF l_err_code <> 0 THEN

/* Following code added for bug 2902096 .The l_resize_flag is set to 'Y' only for some
   error messages whose length of message_name will go above 30 if '_AMG' is added to it.
   These messages can be used straightaway without using the '_AMG' as the message text is same .*/
/* Added some more error messages in the IF condition for bug 2967759 */
     l_resize_flag:='N';

      IF (l_err_msg in ('PA_USR_RATE_NOT_ALLOWED_FC_PC','PA_USR_RATE_NOT_ALLOWED_FC_PF',
                       'PA_USR_RATE_NOT_ALLOWED_BC_PF','PA_NO_EXCH_RATE_EXISTS_BC_PF',
                       'PA_NO_EXCH_RATE_EXISTS_FC_PC','PA_NO_EXCH_RATE_EXISTS_FC_PF')) THEN
         l_resize_flag:='Y';
     END IF;


/* End - Bug 2902096 */

   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => l_err_msg
            		,p_msg_attribute    => 'CHANGE'
            	/*	,p_resize_flag      => 'N' changed for bug 2902096 */
            		,p_resize_flag      => l_resize_flag
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;

     ELSE


        -- UPDATE SUMMARY PROJECT FUNDINGS
        pa_agreement_utils.summary_funding_update_row
     		(p_agreement_id => p_agreement_id
 		,p_project_id   => p_project_id
 		,p_task_id      => p_task_id
 		,p_login_id     => G_LOGIN_ID
 		,p_user_id      => G_USER_ID
 		);


        IF FND_API.to_boolean( p_commit ) THEN
	   COMMIT;
        END IF;

     END IF;

EXCEPTION

       WHEN FND_API.G_EXC_ERROR
          THEN
          p_return_status := FND_API.G_RET_STS_ERROR ;
          ROLLBACK TO update_funding_pub;
          FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          ROLLBACK TO update_funding_pub;
          FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

       WHEN OTHERS
          THEN
          ROLLBACK TO update_funding_pub;
          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
          	FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
          END IF;
          FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END update_funding;

-- ============================================================================
--
--Name:               init_agreement
--Type:               Procedure
--Description:        This procedure can be used to initialize the global PL/SQL
--		      tables that are used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE init_agreement
IS
BEGIN

--  Standard begin of API savepoint

    SAVEPOINT init_agreement_pub;

--  Initialize global table and record types

    G_agreement_in_rec 			:= G_agreement_in_null_rec;
    G_funding_in_tbl.delete;
    G_funding_tbl_count 		:= 0;
    G_agreement_out_rec       		:= G_agreement_out_null_rec;
    G_funding_out_tbl.delete;

END init_agreement;

-- ============================================================================
--
--Name:               load_agreement
--Type:               Procedure
--Description:        This procedure can be used to move the agreement related
--		      parameters from the client side to a record on the server side
--                    , where it will be used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------


PROCEDURE load_agreement
(p_api_version_number		IN	NUMBER
 ,p_init_msg_list		IN	VARCHAR2
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_customer_id			IN	NUMBER
 ,p_customer_name		IN     	VARCHAR2
 ,p_customer_num		IN	VARCHAR2
 ,p_agreement_num		IN	VARCHAR2
 ,p_agreement_type		IN	VARCHAR2
 ,p_amount			IN	NUMBER
 ,p_term_id			IN	NUMBER
 ,p_term_name			IN	VARCHAR2
 ,p_revenue_limit_flag		IN	VARCHAR2
 ,p_expiration_date		IN	DATE
 ,p_description			IN	VARCHAR2
 ,p_owned_by_person_id		IN	NUMBER
 ,p_owned_by_person_name	IN	VARCHAR2
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1			IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_template_flag		IN	VARCHAR2
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_owning_organization_id	IN	NUMBER
 ,p_agreement_currency_code	IN	VARCHAR2
 ,p_invoice_limit_flag		IN	VARCHAR2
 /*Federal*/
 ,p_customer_order_number       IN      VARCHAR2
 ,p_advance_required            IN      VARCHAR2
 ,p_start_date                  IN      DATE
 ,p_billing_sequence            IN      NUMBER
 ,p_line_of_account             IN      VARCHAR2
 ,p_attribute11			IN	VARCHAR2
 ,p_attribute12	                IN	VARCHAR2
 ,p_attribute13	                IN	VARCHAR2
 ,p_attribute14	                IN	VARCHAR2
 ,p_attribute15	                IN	VARCHAR2
 ,p_attribute16	                IN	VARCHAR2
 ,p_attribute17	                IN	VARCHAR2
 ,p_attribute18	                IN	VARCHAR2
 ,p_attribute19	                IN	VARCHAR2
 ,p_attribute20			IN	VARCHAR2
 ,p_attribute21			IN	VARCHAR2
 ,p_attribute22			IN	VARCHAR2
 ,p_attribute23			IN	VARCHAR2
 ,p_attribute24			IN	VARCHAR2
 ,p_attribute25			IN	VARCHAR2
 )
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'load_agreement';

BEGIN
--  Standard begin of API savepoint

    SAVEPOINT load_agreement_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

/* NOT REQUIRED

    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_LOAD_AGREEMENT',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;


    -- ASSIGN INCOMING PARAMETERS TO THE FIELDS OF THE GLOBAL AGREEMENT RECORD

    G_agreement_in_rec.agreement_id			:= p_agreement_id;
    G_agreement_in_rec.agreement_num		        := p_agreement_num;
    G_agreement_in_rec.pm_agreement_reference 		:= p_pm_agreement_reference;
    G_agreement_in_rec.customer_id			:= p_customer_id;
    G_agreement_in_rec.customer_num			:= p_customer_num;
    G_agreement_in_rec.agreement_type 			:= p_agreement_type;
    G_agreement_in_rec.amount				:= p_amount;
    G_agreement_in_rec.term_id				:= p_term_id;
    G_agreement_in_rec.revenue_limit_flag		:= p_revenue_limit_flag;
    G_agreement_in_rec.expiration_date			:= p_expiration_date;
    G_agreement_in_rec.description			:= p_description;
    G_agreement_in_rec.owned_by_person_id		:= p_owned_by_person_id;
    G_agreement_in_rec.template_flag                    := p_template_flag;
    G_agreement_in_rec.desc_flex_name			:= p_desc_flex_name;
    G_agreement_in_rec.attribute_category		:= p_attribute_category;
    G_agreement_in_rec.attribute1			:= p_attribute1;
    G_agreement_in_rec.attribute2			:= p_attribute2;
    G_agreement_in_rec.attribute3			:= p_attribute3;
    G_agreement_in_rec.attribute4			:= p_attribute4;
    G_agreement_in_rec.attribute5			:= p_attribute5;
    G_agreement_in_rec.attribute6        		:= p_attribute6;
    G_agreement_in_rec.attribute7			:= p_attribute7;
    G_agreement_in_rec.attribute8			:= p_attribute8;
    G_agreement_in_rec.attribute9			:= p_attribute9;
    G_agreement_in_rec.attribute10			:= p_attribute10;
    G_agreement_in_rec.owning_organization_id		:= p_owning_organization_id;
    G_agreement_in_rec.agreement_currency_code		:= p_agreement_currency_code;
    G_agreement_in_rec.invoice_limit_flag		:= p_invoice_limit_flag;
/*Federal*/
    G_agreement_in_rec.customer_order_number            := p_customer_order_number;
    G_agreement_in_rec.advance_required                 := p_advance_required;
    G_agreement_in_rec.start_date                       := p_start_date;
    G_agreement_in_rec.billing_sequence                 := p_billing_sequence;
    G_agreement_in_rec.line_of_account                  := p_line_of_account;
    G_agreement_in_rec.attribute11                      := p_attribute11;
    G_agreement_in_rec.attribute12                      := p_attribute12;
    G_agreement_in_rec.attribute13                      := p_attribute13;
    G_agreement_in_rec.attribute14                      := p_attribute14;
    G_agreement_in_rec.attribute15                      := p_attribute15;
    G_agreement_in_rec.attribute16                      := p_attribute16;
    G_agreement_in_rec.attribute17                      := p_attribute17;
    G_agreement_in_rec.attribute18                      := p_attribute18;
    G_agreement_in_rec.attribute19                      := p_attribute19;
    G_agreement_in_rec.attribute20                      := p_attribute20;
    G_agreement_in_rec.attribute21                      := p_attribute21;
    G_agreement_in_rec.attribute22                      := p_attribute22;
    G_agreement_in_rec.attribute23                      := p_attribute23;
    G_agreement_in_rec.attribute24                      := p_attribute24;
    G_agreement_in_rec.attribute25                      := p_attribute25;


 EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	   THEN
	   ROLLBACK TO load_agreement_pub;
	   p_return_status := FND_API.G_RET_STS_ERROR;


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	 THEN
	 ROLLBACK TO load_agreement_pub;
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


	WHEN OTHERS
	 THEN
	 ROLLBACK TO load_agreement_pub;
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	END IF;

END load_agreement;

-- ============================================================================
--
--Name:               load_funding
--Type:               Procedure
--Description:        This procedure can be used to move the funding related
--		      parameters from the client side to a record on the server side
--                    , where it will be used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE load_funding
(p_api_version_number		IN	NUMBER
 ,p_init_msg_list		IN	VARCHAR2
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_agreement_id		IN	NUMBER
 ,p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_allocated_amount		IN	NUMBER
 ,p_date_allocated		IN	DATE
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1			IN	VARCHAR2
 ,p_attribute2	                IN	VARCHAR2
 ,p_attribute3	                IN	VARCHAR2
 ,p_attribute4	                IN	VARCHAR2
 ,p_attribute5	                IN	VARCHAR2
 ,p_attribute6	                IN	VARCHAR2
 ,p_attribute7	                IN	VARCHAR2
 ,p_attribute8	                IN	VARCHAR2
 ,p_attribute9	                IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'
/* Added for Bug 2483081 to include Default value - For Bug 2244796 */
)
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'load_funding';
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT load_funding_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

/* NOT REQUIRED
    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_LOAD_FUNDING',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    --  ASSIGN A VALUE TO THE GLOBAL COUNTER FOR THIS TABLE
    G_funding_tbl_count	:= G_funding_tbl_count + 1;

    -- ASSIGN INCOMING PARAMETERS TO THE GLOBAL TABLE FIELDS
    G_funding_in_tbl(G_funding_tbl_count).pm_funding_reference	:= p_pm_funding_reference;
    G_funding_in_tbl(G_funding_tbl_count).project_funding_id	:= p_funding_id;
    G_funding_in_tbl(G_funding_tbl_count).project_id		:= p_project_id;
    G_funding_in_tbl(G_funding_tbl_count).task_id		:= p_task_id;
    G_funding_in_tbl(G_funding_tbl_count).allocated_amount	:= p_allocated_amount;
    G_funding_in_tbl(G_funding_tbl_count).date_allocated	:= p_date_allocated;
    G_funding_in_tbl(G_funding_tbl_count).attribute_category	:= p_attribute_category;
    G_funding_in_tbl(G_funding_tbl_count).attribute1		:= p_attribute1;
    G_funding_in_tbl(G_funding_tbl_count).attribute2		:= p_attribute2;
    G_funding_in_tbl(G_funding_tbl_count).attribute3		:= p_attribute3;
    G_funding_in_tbl(G_funding_tbl_count).attribute4		:= p_attribute4;
    G_funding_in_tbl(G_funding_tbl_count).attribute5		:= p_attribute5;
    G_funding_in_tbl(G_funding_tbl_count).attribute6		:= p_attribute6;
    G_funding_in_tbl(G_funding_tbl_count).attribute7		:= p_attribute7;
    G_funding_in_tbl(G_funding_tbl_count).attribute8		:= p_attribute8;
    G_funding_in_tbl(G_funding_tbl_count).attribute9		:= p_attribute9;
    G_funding_in_tbl(G_funding_tbl_count).attribute10		:= p_attribute10;
    G_funding_in_tbl(G_funding_tbl_count).project_rate_type     := p_project_rate_type;
    G_funding_in_tbl(G_funding_tbl_count).project_rate_date     := p_project_rate_date;
    G_funding_in_tbl(G_funding_tbl_count).project_exchange_rate := p_project_exchange_rate;
    G_funding_in_tbl(G_funding_tbl_count).projfunc_rate_type    := p_projfunc_rate_type;
    G_funding_in_tbl(G_funding_tbl_count).projfunc_rate_date	:= p_projfunc_rate_date;
    G_funding_in_tbl(G_funding_tbl_count).projfunc_exchange_rate := p_projfunc_exchange_rate;
    G_funding_in_tbl(G_funding_tbl_count).funding_category := p_funding_category; /* Added for Bug 2403652 */


EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	 THEN
	 ROLLBACK TO load_funding_pub;
	 p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	 THEN
	 ROLLBACK TO load_funding_pub;
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS
	 THEN
	 ROLLBACK TO load_funding_pub;
         p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	 END IF;

END load_funding;


-- ============================================================================
--
--Name:               execute_create_agreement
--Type:               Procedure
--Description:        This procedure can be used to create an agreement
--                    using global PL/SQL tables.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE execute_create_agreement
(p_api_version_number	IN	NUMBER
 ,p_commit		IN	VARCHAR2
 ,p_init_msg_list	IN	VARCHAR2
 ,p_msg_count		OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status	OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_product_code	IN	VARCHAR2
 ,p_agreement_id_out	OUT	NOCOPY NUMBER
 ,p_customer_id_out	OUT	NOCOPY NUMBER
 )
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'execute_create_agreement';
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT execute_create_agreement_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

/* NOT REQUIRED
    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_EXECUTE_CREATE_AGREEMENT',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;


    -- CALL CREATE AGREEMENT
    pa_agreement_pub.create_agreement
    		(p_api_version_number	=> p_api_version_number
 		,p_commit	        => p_commit
 		,p_init_msg_list	=> p_init_msg_list
 		,p_msg_count	        => p_msg_count
 		,p_msg_data	        => p_msg_data
 		,p_return_status	=> l_return_status
 		,p_pm_product_code	=> p_pm_product_code
 		,p_agreement_in_rec	=> G_agreement_in_rec
 		,p_agreement_out_rec	=> G_agreement_out_rec
 		,p_funding_in_tbl	=> G_funding_in_tbl
 		,p_funding_out_tbl	=> G_funding_out_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- ASSIGN OUTGOING VALUES TO OUTGOING PARAMETERS
    IF G_agreement_out_rec.agreement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
	   p_agreement_id_out	:= NULL;
    ELSE
	   p_agreement_id_out 	:= G_agreement_out_rec.agreement_id;
    END IF;

    IF G_agreement_out_rec.customer_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    THEN
	   p_customer_id_out	:= NULL;
    ELSE
	   p_customer_id_out 	:= G_agreement_out_rec.customer_id;
    END IF;

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	   THEN
	   ROLLBACK TO execute_create_agreement_pub;
	   p_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	   THEN
	   ROLLBACK TO execute_create_agreement_pub;
	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
	   THEN
	   ROLLBACK TO execute_create_agreement_pub;
	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	  END IF;
	  FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END execute_create_agreement;


-- ============================================================================
--
--Name:               execute_update_agreement
--Type:               Procedure
--Description:        This procedure can be used to update an agreement
--                    using global PL/SQL tables.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE execute_update_agreement
(p_api_version_number	IN	NUMBER
 ,p_commit		IN	VARCHAR2
 ,p_init_msg_list	IN	VARCHAR2
 ,p_msg_count		OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status	OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_product_code	IN	VARCHAR2
 )
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'execute_update_agreement';
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT execute_update_agreement_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

/* NOT REQUIRED
    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_EXECUTE_UPDATE_AGREEMENT',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CALL UPDATE AGREEMENT
    pa_agreement_pub.update_agreement
    		(p_api_version_number	=> p_api_version_number
 		,p_commit	        => p_commit
 		,p_init_msg_list	=> p_init_msg_list
 		,p_msg_count	        => p_msg_count
 		,p_msg_data	        => p_msg_data
 		,p_return_status	=> p_return_status
 		,p_pm_product_code	=> p_pm_product_code
 		,p_agreement_in_rec	=> G_agreement_in_rec
 		,p_agreement_out_rec	=> G_agreement_out_rec
 		,p_funding_in_tbl	=> G_funding_in_tbl
 		,p_funding_out_tbl	=> G_funding_out_tbl);

    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;


EXCEPTION

        WHEN FND_API.G_EXC_ERROR
          THEN
          ROLLBACK TO execute_update_agreement_pub;
          p_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
          THEN
          ROLLBACK TO execute_update_agreement_pub;
          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

        WHEN OTHERS
          THEN
          ROLLBACK TO execute_update_agreement_pub;
          p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
        	FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name
				, p_error_text		=> SUBSTR(SQLERRM, 1, 240) );
                FND_MSG_PUB.add;
          END IF;
          FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

END execute_update_agreement;

-- ============================================================================
--
--Name:               fetch_funding
--Type:               Procedure
--Description:        This procedure can be used to update an agreement
--                    using global PL/SQL tables.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE fetch_funding
(p_api_version_number		IN	NUMBER
 ,p_init_msg_list		IN	VARCHAR2
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_funding_index		IN	NUMBER
 ,p_funding_id			OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_pm_funding_reference	OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 )
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_index						NUMBER;
l_api_name					CONSTANT VARCHAR2(30):= 'fetch_funding';
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT fetch_funding_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

/* NOT REQUIRED
    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_FETCH_FUNDING',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
        	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
        	RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
*/
    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    --  Check Funding index value, when they don't provide an index we will error out
    IF p_funding_index = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    OR p_funding_index IS NULL
    THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_INDEX_NOT_PROV'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
	END IF;
	p_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
    ELSE
	l_index := p_funding_index;
    END IF;
    IF G_funding_out_tbl.exists(l_index)
    THEN
    --  assign global table fields to the outgoing parameter
    --  we don't want to return the big number G_PA_MISS_NUM
    	IF G_funding_out_tbl(l_index).project_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    	THEN
		p_funding_id 	:= NULL;
	ELSE
   		p_funding_id 	:= G_funding_out_tbl(l_index).project_funding_id;
	END IF;
   	p_return_status		:= G_funding_out_tbl(l_index).return_status;
    END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	  THEN
	  ROLLBACK TO fetch_funding_pub;
	  p_return_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	  THEN
	  ROLLBACK TO fetch_funding_pub;
	  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS
	  THEN
	  ROLLBACK TO fetch_funding_pub;
	  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	END IF;

END fetch_funding;

-- ============================================================================
--
--Name:               clear_agreement
--Type:               Procedure
--Description:        This procedure can be used to clear the global PL/SQL
--		      tables that are used by a LOAD/EXECUTE/FETCH cycle.
--
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE clear_agreement
IS
-- LOCAL VARIABLES
l_resp_id					NUMBER := 0;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'clear_agreement';

BEGIN

    --  Standard begin of API savepoint

    SAVEPOINT clear_agreement_pub;


    -- CALL THE INIT AGREEMENT PROCEDURE
    pa_agreement_pub.init_agreement;

END clear_agreement;

-- ============================================================================
--
--Name:               check_delete_agreement_ok
--Type:               Procedure
--Description:        This procedure can be used to check whether it is OK
--                    to delete an agreement.
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE check_delete_agreement_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_del_agree_ok_flag		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 )
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_out_agreement_id				NUMBER ;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'check_delete_agreement_ok';

BEGIN

--  Standard begin of API savepoint

    SAVEPOINT check_delete_agreement_ok_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_DEL_AGMT_OK',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;


    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Agreement Reference
    IF (p_pm_agreement_reference IS NULL)
       OR (p_pm_agreement_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
  /* NOT REQUIRED
    -- Agreement Id
    IF (p_agreement_id IS NULL)
       OR (p_agreement_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
           		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
     */
     -- VALIDATE THE INCOMING PARAMETERS

 -- TO BE CORRECTED - NIKHIL
     -- Agreement Reference
     IF pa_agreement_utils.check_valid_agreement_ref(p_agreement_reference => p_pm_agreement_reference) = 'N'
     THEN
     	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_AGMT_REF'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
          END IF;
          p_return_status := FND_API.G_RET_STS_ERROR;
          RAISE FND_API.G_EXC_ERROR;
    END IF;

   /* NOT REQUIRED
   -- Agreement Id
   IF pa_agreement_utils.check_valid_agreement_id(p_agreement_id => p_agreement_id) =  'N'
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
            pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_AGMT_ID'
           		 ,p_msg_attribute    => 'CHANGE'
            		 ,p_resize_flag      => 'N'
           		 ,p_msg_context      => 'AGREEMENT'
           		 ,p_attribute1       => p_pm_agreement_reference
            		 ,p_attribute2       => ''
            		 ,p_attribute3       => ''
            		 ,p_attribute4       => ''
            		 ,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
   */

    -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
    pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_agreement_reference => p_pm_agreement_reference
		,p_af_agreement_id => p_agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
    p_return_status             := l_return_status;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
   THEN
   	IF l_return_status = FND_API.G_RET_STS_ERROR
   	THEN
   		RAISE FND_API.G_EXC_ERROR;
   	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   	THEN
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	ELSE
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;
   END IF;

    -- CHECK IF IT IS OK TO DELETE THE AGREEMENT
    p_del_agree_ok_flag := pa_agreement_pvt.check_delete_agreement_ok
    				(p_agreement_id => l_out_agreement_id
				,p_pm_agreement_reference => p_pm_agreement_reference);

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR
		THEN
		ROLLBACK TO check_delete_agreement_ok_pub;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
		ROLLBACK TO check_delete_agreement_ok_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
		THEN
		ROLLBACK TO check_delete_agreement_ok_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END check_delete_agreement_ok;

-- ============================================================================
--
--Name:               check_add_funding_ok
--Type:               Procedure
--Description:        This procedure can be used to check whether it is OK
--                    to add a funding.
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE check_add_funding_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_task_id			IN	NUMBER
 ,p_project_id			IN 	NUMBER
 ,p_add_funding_ok_flag		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_funding_amt			IN	NUMBER
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
  )
IS
-- added for validating the funding amount
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_out_agreement_id				NUMBER ;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'check_add_funding_ok';
l_customer_id					NUMBER ;
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT check_add_funding_ok_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

    -- This call is added for patchset K project role based security check

    PA_INTERFACE_UTILS_PUB.G_PROJECt_ID := p_project_id;



    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_ADD_FUND_OK',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Agreement Reference
    IF (p_pm_agreement_reference IS NULL)
       OR (p_pm_agreement_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Project Id
    IF (p_project_id IS NULL)
       OR (p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_PROJ_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
/*
    -- Task Id
    IF (p_task_id IS NULL)
       OR (p_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_TASK_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
  */
     --  Funding Reference
    IF (p_pm_funding_reference IS NULL)
       OR (p_pm_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

   /* NOT REQUIRED
    -- Funding Id
    IF (p_funding_id IS NULL)
       OR (p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_ID_IS_MISS'
           		 ,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
     */

     -- VALIDATE THE INCOMING PARAMETERS

--TO BE CORRECTED - NIKHIL
     -- Agreement Reference
     IF pa_agreement_utils.check_valid_agreement_ref(p_agreement_reference => p_pm_agreement_reference) = 'N'
     THEN
     	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_AGMT_REF'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'Y'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
/* NOT REQUIRED
    -- Funding Reference
   IF pa_agreement_utils.check_valid_funding_ref(p_funding_reference => p_pm_funding_reference
						,p_agreement_id => p_agreement_id) = 'N'
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_REF'
           		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
           		,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
*/
    -- CONVERT AGREEMENT REFERENCE TO AGREEMENT ID
    pa_agreement_pvt.convert_ag_ref_to_id
   		(p_pm_agreement_reference => p_pm_agreement_reference
		,p_af_agreement_id => p_agreement_id
		,p_out_agreement_id => l_out_agreement_id
		,p_return_status   => l_return_status);
    p_return_status             := l_return_status;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
   	IF l_return_status = FND_API.G_RET_STS_ERROR
   	THEN
   		RAISE FND_API.G_EXC_ERROR;
   	ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
   	THEN
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	ELSE
   		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   	END IF;
    END IF;

  -- TO BE CORRECTED - NIKHIL
    -- CHECK IF IT IS OK TO  ADD FUNDING

	SELECT a. customer_id
	INTO l_customer_id
	FROM pa_agreements_all a
	WHERE a.agreement_id = p_agreement_id;

    p_add_funding_ok_flag := pa_agreement_pvt.check_add_funding_ok
    	(p_project_id	                 => p_project_id
 	 ,p_task_id			 => p_task_id
 	 ,p_agreement_id		 => l_out_agreement_id
 	 ,p_pm_funding_reference	 => p_pm_funding_reference
 	 ,p_funding_amt			 => p_funding_amt
 	 ,p_customer_id			 => l_customer_id
/* MCB2 PARAMETERS BEGIN */
         ,p_project_rate_type		 => p_project_rate_type
	 ,p_project_rate_date		 => p_project_rate_date
	 ,p_project_exchange_rate	 => p_project_exchange_rate
         ,p_projfunc_rate_type		 => p_projfunc_rate_type
	 ,p_projfunc_rate_date		 => p_projfunc_rate_date
	 ,p_projfunc_exchange_rate	 => p_projfunc_exchange_rate );
/* MCB2 PARAMETERS END */

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR
		THEN
		ROLLBACK TO check_add_funding_ok_pub;
		p_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
		THEN
		ROLLBACK TO check_add_funding_ok_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);

	WHEN OTHERS
		THEN
		ROLLBACK TO check_add_funding_ok_pub;
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
			FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

		END IF;
		FND_MSG_PUB.Count_And_Get
			(   p_count		=>	p_msg_count	,
			    p_data		=>	p_msg_data	);


END check_add_funding_ok;

-- ============================================================================
--
--Name:               check_delete_funding_ok
--Type:               Procedure
--Description:        This procedure can be used to check whether it is OK
--                    to delete a funding.
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE check_delete_funding_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_del_funding_ok_flag		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 )
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_out_agreement_id				NUMBER ;
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'check_delete_funding_ok';
l_project_id					NUMBER;

BEGIN
--  Standard begin of API savepoint

    SAVEPOINT check_delete_funding_ok_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

	-- Get the project id from this project funding line

     l_project_id := pa_agreement_utils.get_project_id(p_funding_id => p_funding_id,
                                                   p_funding_reference => p_pm_funding_reference);

	 -- This call is added for patchset K project role based security check

	    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_DEL_FUND_OK',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Funding Reference
    IF (p_pm_funding_reference IS NULL)
       OR (p_pm_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_REF_IS_MISS'
           		 ,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
           		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;
   /* NOT REQUIRED
    -- Funding Id
    IF (p_funding_id IS NULL)
       OR (p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
 */

    -- VALIDATE THE INCOMING PARAMETERS
    --TO BE CORRECTED - NIKHIL
     -- Funding Reference
     IF pa_agreement_utils.check_valid_funding_ref
     		(p_funding_reference => p_pm_funding_reference
     		 ,p_agreement_id => pa_agreement_utils.get_agreement_id(p_funding_id => p_funding_id
									,p_funding_reference => p_pm_funding_reference)) = 'N'
     THEN
     	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_REF'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        p_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     -- Funding Id
   IF pa_agreement_utils.check_valid_funding_id(p_agreement_id => pa_agreement_utils.get_agreement_id(p_funding_id => p_funding_id
												   ,p_funding_reference => p_pm_funding_reference)
   						,p_funding_id => pa_agreement_utils.get_funding_id(p_funding_reference => p_pm_funding_reference)) = 'N'
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ID'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => 'p_pm_funding_reference'
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- CALL THE CHECK DELETE FUNDING OK PRIVATE PROCEDURE

    p_del_funding_ok_flag :=  pa_agreement_pvt.check_delete_funding_ok
    				(p_agreement_id		=>	pa_agreement_utils.get_agreement_id(p_funding_id => p_funding_id
												   ,p_funding_reference => p_pm_funding_reference)
				,p_funding_id		=>	pa_agreement_utils.get_funding_id(p_funding_reference => p_pm_funding_reference)
				,p_pm_funding_reference	=>	p_pm_funding_reference);



     IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	 THEN
	   ROLLBACK TO check_delete_funding_ok_pub;

	   p_return_status := FND_API.G_RET_STS_ERROR;


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	 THEN
	   ROLLBACK TO check_delete_funding_ok_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


	WHEN OTHERS
	 THEN
	  ROLLBACK TO check_delete_funding_ok_pub;

	  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	   FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	END IF;


END check_delete_funding_ok;

-- ============================================================================
--
--Name:               check_update_funding_ok
--Type:               Procedure
--Description:        This procedure can be used to check whether it is OK
--                    to update a funding.
--Called subprograms: XXX
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- ---------------------------------------------------------------------------

PROCEDURE check_update_funding_ok
(p_api_version_number		IN	NUMBER
 ,p_commit			IN	VARCHAR2
 ,p_init_msg_list		IN	VARCHAR2
 ,p_msg_count			OUT	NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data			OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status		OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_product_code		IN	VARCHAR2
 ,p_pm_funding_reference	IN	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_pm_project_reference	IN	VARCHAR2
 ,p_project_id			IN	NUMBER
 ,p_pm_task_reference		IN	VARCHAR2
 ,p_task_id			IN	NUMBER
 ,p_pm_agreement_reference	IN	VARCHAR2
 ,p_agreement_id		IN	NUMBER
 ,p_allocated_amount		IN	NUMBER
 ,p_date_allocated		IN	DATE
 ,p_desc_flex_name		IN	VARCHAR2
 ,p_attribute_category		IN	VARCHAR2
 ,p_attribute1			IN	VARCHAR2
 ,p_attribute2			IN	VARCHAR2
 ,p_attribute3			IN	VARCHAR2
 ,p_attribute4			IN	VARCHAR2
 ,p_attribute5			IN 	VARCHAR2
 ,p_attribute6			IN	VARCHAR2
 ,p_attribute7			IN	VARCHAR2
 ,p_attribute8			IN	VARCHAR2
 ,p_attribute9			IN	VARCHAR2
 ,p_attribute10			IN	VARCHAR2
 ,p_update_funding_ok_flag	OUT	NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_project_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_project_rate_date		IN	DATE		DEFAULT NULL
 ,p_project_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_projfunc_rate_type		IN	VARCHAR2	DEFAULT NULL
 ,p_projfunc_rate_date		IN	DATE		DEFAULT NULL
 ,p_projfunc_exchange_rate	IN	NUMBER		DEFAULT NULL
 ,p_funding_category            IN      VARCHAR2        DEFAULT 'ADDITIONAL'
/* Added for Bug 2483081 to include Default value - For Bug 2244796 */
)
IS
-- LOCAL VARIABLES
l_msg_count					NUMBER ;
l_msg_data					VARCHAR2(2000);
l_function_allowed				VARCHAR2(1);
l_resp_id					NUMBER := 0;
l_out_agreement_id				NUMBER ;
l_return_msg					VARCHAR2(2000);
l_validate_status				VARCHAR2(1);
l_return_status					VARCHAR2(1);
l_api_name					CONSTANT VARCHAR2(30):= 'check_update_funding_ok';
BEGIN
--  Standard begin of API savepoint

    SAVEPOINT check_update_funding_ok_pub;


--  Standard call to check for call compatibility.


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

 -- This call is added for patchset K project role based security check

    PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_project_id;


    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions


    PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_AF_UPD_FUND_OK',
       p_msg_count          => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed
       );

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNC_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
           p_return_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;

    --  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;

    --  Set API return status to success

    p_return_status             := FND_API.G_RET_STS_SUCCESS;

    -- CHECK WHETHER MANDATORY INCOMING PARAMETERS EXIST

    -- Funding Reference
    IF (p_pm_funding_reference IS NULL)
       OR (p_pm_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
       		pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_REF_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
           		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Funding Id
    IF (p_funding_id IS NULL)
       OR (p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
    THEN
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_FUND_ID_IS_MISS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'GENERAL'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
	 p_return_status             := FND_API.G_RET_STS_ERROR;
	 RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- VALIDATE THE INCOMING PARAMETERS

     -- Funding Reference
     IF pa_agreement_utils.check_valid_funding_ref(p_funding_reference => p_pm_funding_reference
						,p_agreement_id => p_agreement_id) = 'N'
     THEN
     	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
          		 ( p_old_message_code => 'PA_INVD_FUND_REF'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'Y'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Agreement Id
   IF pa_agreement_utils.check_valid_agreement_id
   		(p_agreement_id => p_agreement_id) = 'N'
   THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FUNDING_ID'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'Y'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => ''
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         p_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
    END IF;

       -- Flex Field Validations
     pa_agreement_pvt.validate_flex_fields
   	(p_desc_flex_name         => p_desc_flex_name
         ,p_attribute_category    => p_attribute_category
         ,p_attribute1            => p_attribute1
         ,p_attribute2            => p_attribute2
         ,p_attribute3            => p_attribute3
         ,p_attribute4            => p_attribute4
         ,p_attribute5            => p_attribute5
/**      ,p_attribute6            => p_attribute7 ** commented bug 2862922 **/
         ,p_attribute6            => p_attribute6 /** added bug 2862922 **/
         ,p_attribute7            => p_attribute7 /** added bug 2862922 **/
         ,p_attribute8            => p_attribute8
         ,p_attribute9            => p_attribute9
         ,p_attribute10           => p_attribute10
         ,p_return_msg            => l_return_msg
         ,p_validate_status       => l_validate_status
          );
     IF l_validate_status = 'N'
     THEN
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FF_VALUES'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FLEX'
            		,p_attribute1       => l_return_msg
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
	p_return_status             := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
      END IF;


    -- CALL THE CHECK UPDATE FUNDING OK PRIVATE PROCEDURE
    p_update_funding_ok_flag := pa_agreement_pvt.check_update_funding_ok
    	(p_project_id 	           => p_project_id
 	 ,p_task_id		   => p_task_id
 	 ,p_agreement_id	   => p_agreement_id
 	 ,p_customer_id		   => pa_agreement_utils.get_customer_id
 				        (p_funding_id => p_funding_id
	                                ,p_funding_reference => p_pm_funding_reference)
 	 ,p_pm_funding_reference   => p_pm_funding_reference
 	 ,p_funding_id		   => p_funding_id
	 ,p_funding_amt            => p_allocated_amount
/* MCB2 PARAMETERS BEGIN */
         ,p_project_rate_type	   => p_project_rate_type
	 ,p_project_rate_date	   => p_project_rate_date
	 ,p_project_exchange_rate  => p_project_exchange_rate
         ,p_projfunc_rate_type	   => p_projfunc_rate_type
	 ,p_projfunc_rate_date	   => p_projfunc_rate_date
	 ,p_projfunc_exchange_rate => p_projfunc_exchange_rate );
/* MCB2 PARAMETERS END */

    IF FND_API.to_boolean( p_commit )
    THEN
	COMMIT;
    END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR
	 THEN
	   ROLLBACK TO check_update_funding_ok_pub;

	   p_return_status := FND_API.G_RET_STS_ERROR;


	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	 THEN
	   ROLLBACK TO check_update_funding_ok_pub;

	   p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


	WHEN OTHERS
	 THEN
	  ROLLBACK TO check_update_funding_ok_pub;

	  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	 THEN
	   FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);

	END IF;


END check_update_funding_ok;


PROCEDURE create_baseline_budget
( p_api_version_number                  IN      NUMBER
 ,p_commit                              IN      VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list                       IN      VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count                           OUT     NOCOPY NUMBER /*File.sql.39*/
 ,p_msg_data                            OUT     NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_return_status                       OUT     NOCOPY VARCHAR2 /*File.sql.39*/
 ,p_pm_product_code                     IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_budget_version_name                 IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                       IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference                IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_budget_type_code                    IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Always "AR"
 ,p_change_reason_code                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_description                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_entry_method_code                   IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_resource_list_name                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- ,p_resource_list_id                    IN      NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category                  IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                          IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                         IN      VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    )
IS
         CURSOR res_info IS
                SELECT R1.resource_list_id resource_list_id,
                       R1.name resource_list_name,
                       M.resource_list_member_id resource_list_member_id
                FROM   pa_resource_lists R1, pa_implementations I,
                       pa_resource_list_members M
                WHERE  R1.uncategorized_flag = 'Y'
                AND    R1.business_group_id = I.business_group_id
                AND    R1.resource_list_id = M.resource_list_id;


         CURSOR proj_dates IS
                SELECT start_date, completion_date,nvl(baseline_funding_flag,'N') baseline_funding_flag
                FROM pa_projects_all
                WHERE project_id = p_pa_project_id;

         res_info_rec     res_info%ROWTYPE;
         proj_dates_rec   proj_dates%ROWTYPE;

         l_project_id           pa_projects_all.project_id%type;
         l_budget_version_id    NUMBER;
         l_funding_level        VARCHAR2(1);
         l_budget_entry_method_code   VARCHAR2(30);

         l_err_code             NUMBER;
         l_resp_id              NUMBER;
         l_err_stage            VARCHAR2(120);
         l_status               VARCHAR2(120);
         l_msg_count            NUMBER;
         l_api_name             VARCHAR2(50) := 'CREATE_BASELINE_BUDGET';
         l_err_stack            VARCHAR2(250);

        l_return_status		VARCHAR2(1);
        l_workflow_started	VARCHAR2(1);

-- CREATE DRAFT

         CURSOR budget_version IS
                SELECT max(budget_version_id)
                FROM   pa_budget_versions
                WHERE project_id = p_pa_project_id
                AND   budget_type_code = 'AR'
                AND   budget_status_code = 'W'
                AND   version_number = 1;

-- CREATE FUNDING
       CURSOR funding_amount (p_resource_list_member_id number, p_start_date date, p_end_date date)
              is
              SELECT nvl(pf.task_id,0) pa_task_id,
                     to_char(Null) pm_task_reference,
                     to_char(Null) resource_alias,
                     p_resource_list_member_id,
                     DECODE(nvl(pf.task_id,0),0,p_start_date,t.start_date) budget_start_date,
                     DECODE(nvl(pf.task_id,0),0,p_end_date,t.completion_date) budget_end_date,
                     to_char(null) period_name,
                     'Default Created by Projects AMG Agreement Funding' description,
                     to_number(null) raw_cost,
                     to_number(null) burdened_cost,
                     sum(nvl(pf.projfunc_allocated_amount,0)) revenue,
                     to_number(null) quantity,
                     p_pm_product_code,
                     p_pm_budget_reference,
                     p_Attribute_Category,
                     p_Attribute1,
                     p_Attribute2,
                     p_Attribute3,
                     p_Attribute4,
                     p_Attribute5,
                     p_Attribute6,
                     p_Attribute7,
                     p_Attribute8,
                     p_Attribute9,
                     p_Attribute10,
                     p_Attribute11,
                     p_Attribute12,
                     p_Attribute13,
                     p_Attribute14,
                     p_Attribute15,
/* Bug 2866699 Added due to Fin plan impact */
                     pf.PROJFUNC_CURRENCY_CODE,
                     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL),
		     to_char(NULL)
/* Bug 2866699 Added due to Fin plan impact ends here */
              FROM  pa_project_fundings pf, pa_tasks t
              WHERE pf.project_id = p_pa_project_id
	      AND   pf.task_id = t.task_id(+)
              AND   pf.budget_type_code in ('BASELINE', 'DRAFT')
              group by nvl(pf.task_id,0),
                       pf.projfunc_currency_code, /*projfunc_currency_code added for bug 3078560 */
                     DECODE(nvl(pf.task_id,0),0,p_start_date,t.start_date),
                     DECODE(nvl(pf.task_id,0),0,p_end_date,t.completion_date);
		       /* Modified the cursor for bug 3488706*/

l_budget_lines_in_tbl           pa_budget_pub.budget_line_in_tbl_type;

l_budget_lines_out_tbl          pa_budget_pub.budget_line_out_tbl_type;

l_budget_lines_in_rec           pa_budget_pub.budget_line_in_rec_type;

i number := 1;

P_BUDGET_VERSION_NAME varchar2(10);
BEGIN

    SAVEPOINT Create_Budget_From_funding;
    -- Initializing the return status to success ! -- bug 3099706
      --  Set API return status to success
      p_return_status         := FND_API.G_RET_STS_SUCCESS;

--  Standard call to check for call compatibility.
    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

        FND_MSG_PUB.initialize;

    END IF;


    IF NOT FND_API.Compatible_API_Call ( g_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;
    l_resp_id := FND_GLOBAL.Resp_id;

     Pa_project_pvt.Convert_pm_projref_to_id (
         p_pm_project_reference  => p_pm_project_reference,
         p_pa_project_id         => p_pa_project_id,
         p_out_project_id        => l_project_id,
         p_return_status         => l_return_status );

     IF l_return_status =  FND_API.G_RET_STS_UNEXP_ERROR
     THEN
         p_return_status             := l_return_status;
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

     ELSIF l_return_status = FND_API.G_RET_STS_ERROR
     THEN
         p_return_status             := l_return_status;
         RAISE  FND_API.G_EXC_ERROR;

     END IF;

	IF (PA_FUNDING_CORE.CHECK_PROJECT_TYPE(l_project_id)) = 'N' THEN
    	p_return_status             := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_PROJECT'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'CONTRACT'
                        ,p_attribute1       => l_project_id
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
	END IF;


         OPEN res_info;
         FETCH res_info INTO res_info_rec;
         CLOSE res_info;


         OPEN proj_dates;
         FETCH proj_dates INTO proj_dates_rec;
         CLOSE proj_dates;

        IF (proj_dates_rec.completion_date is null  or proj_dates_rec.start_date is null) then
    --  Set API return status to success
          P_RETURN_STATUS             := FND_API.G_RET_STS_ERROR;

          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_BU_NO_PROJ_END_DATE'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'N'
           ,p_msg_context      => 'BUDG'
           ,p_attribute1       => l_project_id
           ,p_attribute2       => ''
           ,p_attribute3       => null
           ,p_attribute4       => ''
           ,p_attribute5       => '');

                RAISE FND_API.G_EXC_ERROR;
        END IF;

        IF proj_dates_rec.baseline_funding_flag = 'N' then


          P_RETURN_STATUS             := FND_API.G_RET_STS_ERROR;

          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => 'PA_NO_BASELINE_FUNDING'
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'N'
           ,p_msg_context      => 'BUDG'
           ,p_attribute1       => l_project_id
           ,p_attribute2       => ''
           ,p_attribute3       => null
           ,p_attribute4       => ''
           ,p_attribute5       => '');

                RAISE FND_API.G_EXC_ERROR;

         END IF;



         pa_billing_core.check_funding_level (
                x_project_id  => l_project_id,
                x_funding_level => l_funding_level,
                x_err_code      => l_err_code,
                x_err_stage     => l_err_stage,
                x_err_stack     => l_err_stack);

         IF l_err_code <> 0 then
          pa_interface_utils_pub.map_new_amg_msg
          ( p_old_message_code => l_err_code
           ,p_msg_attribute    => 'CHANGE'
           ,p_resize_flag      => 'N'
           ,p_msg_context      => 'BUDG'
           ,p_attribute1       => l_project_id
           ,p_attribute2       => ''
           ,p_attribute3       => l_funding_level
           ,p_attribute4       => ''
           ,p_attribute5       => '');

                RAISE FND_API.G_EXC_ERROR;

         END IF;



            IF l_funding_level = 'P' then
               l_budget_entry_method_code := 'PA_PROJLVL_BASELINE';
            ELSIF l_funding_level = 'T' then
               l_budget_entry_method_code := 'PA_TASKLVL_BASELINE';
            END IF;


	OPen Funding_amount  ( res_info_rec.resource_list_member_id,
       		                proj_dates_rec.start_date,
       		               	proj_dates_rec.completion_date);
	loop
	fetch funding_amount into l_budget_lines_in_rec;
		if funding_amount%notfound then
			exit;
		end if;
	l_budget_lines_in_tbl(i) := l_budget_lines_in_rec;
	i := i + 1;
	end loop;
	close funding_amount;

   -- Bug 3099706 : Set a variable to Y to indicate to pa_budget_pvt.validate_header_info
   -- API that the API is called from Agreement Pub during baselining of budget for an
   -- Autobaselined project. In this case, the called API needs to skip validations
   -- related to Autobaseline checking while creating a Draft Budget.

   -- dbms_output.put_line('Before setting the value of PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB = '|| PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB);
   PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'Y';

   -- dbms_output.put_line('AFTER setting the value of PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB = '|| PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB);
   -- dbms_output.put_line('about to call create_draft_budget ... '||l_budget_entry_method_code||' '||l_project_id||' '||p_budget_version_name);

/* Commented for bug 4941046
   pa_budget_pub.create_draft_budget( p_api_version_number   => p_api_version_number
                        ,p_commit               => FND_API.G_FALSE
                        ,p_init_msg_list        => FND_API.G_FALSE
                        ,p_msg_count            => p_msg_count
                        ,p_msg_data             => p_msg_data
                        ,p_return_status        => l_return_status
                        ,p_pm_product_code      => p_pm_product_code
                        ,p_budget_version_name  => p_budget_version_name
                        ,p_pa_project_id        => l_project_id
                        ,p_pm_project_reference => p_pm_project_reference
                        ,p_budget_type_code     => 'AR'
                        ,p_change_reason_code   => Null
                        ,p_description          => 'Default Created by Projects AMG Agreement Funding'
                        ,p_entry_method_code    => l_budget_entry_method_code
                        ,p_resource_list_name   => res_info_rec.resource_list_name
                        ,p_resource_list_id     => res_info_rec.resource_list_id
                        ,p_attribute_category   => p_attribute_category
                        ,p_attribute1           => p_attribute1
                        ,p_attribute2           => p_attribute2
                        ,p_attribute3           => p_attribute3
                        ,p_attribute4           => p_attribute4
                        ,p_attribute5           => p_attribute5
                        ,p_attribute6           => p_attribute6
                        ,p_attribute7           => p_attribute7
                        ,p_attribute8           => p_attribute8
                        ,p_attribute9           => p_attribute9
                        ,p_attribute10          => p_attribute10
                        ,p_attribute11          => p_attribute11
                        ,p_attribute12          => p_attribute12
                        ,p_attribute13          => p_attribute13
                        ,p_attribute14          => p_attribute14
                        ,p_attribute15          => p_attribute15
                        ,p_budget_lines_in      => l_budget_lines_in_tbl
                        ,p_budget_lines_out     => l_budget_lines_out_tbl);*/

   --WRAPPER API CALL ADDED FOR BUG 4941046
        pa_fin_plan_utils.create_draft_budget_wrp( p_api_version_number   => p_api_version_number
                        ,p_commit               => FND_API.G_FALSE
                        ,p_init_msg_list        => FND_API.G_FALSE
                        ,p_msg_count            => p_msg_count
                        ,p_msg_data             => p_msg_data
                        ,p_return_status        => l_return_status
                        ,p_pm_product_code      => p_pm_product_code
                        ,p_budget_version_name  => p_pm_budget_reference --Added for bug 4941046
                        ,p_pa_project_id        => l_project_id
                        ,p_pm_project_reference => p_pm_project_reference
                        ,p_budget_type_code     => 'AR'
                        ,p_change_reason_code   => Null
                        ,p_description          => 'Default Created by Projects AMG Agreement Funding'
                        ,p_entry_method_code    => l_budget_entry_method_code
                        ,p_resource_list_name   => res_info_rec.resource_list_name
                        ,p_resource_list_id     => res_info_rec.resource_list_id
                        ,p_attribute_category   => p_attribute_category
                        ,p_attribute1           => p_attribute1
                        ,p_attribute2           => p_attribute2
                        ,p_attribute3           => p_attribute3
                        ,p_attribute4           => p_attribute4
                        ,p_attribute5           => p_attribute5
                        ,p_attribute6           => p_attribute6
                        ,p_attribute7           => p_attribute7
                        ,p_attribute8           => p_attribute8
                        ,p_attribute9           => p_attribute9
                        ,p_attribute10          => p_attribute10
                        ,p_attribute11          => p_attribute11
                        ,p_attribute12          => p_attribute12
                        ,p_attribute13          => p_attribute13
                        ,p_attribute14          => p_attribute14
                        ,p_attribute15          => p_attribute15
                        ,p_budget_lines_in      => l_budget_lines_in_tbl
                        ,p_budget_lines_out     => l_budget_lines_out_tbl);

        -- dbms_output.put_line('returned from create_draft ... status = '||l_return_status);
        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- dbms_output.put_line('about to call baseline_budget ... ');
        -- dbms_output.put_line('Before setting the value of PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB = '|| PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB);

/* Commented for bug 4941046
        PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'Y';

	PA_BUDGET_PUB.BASELINE_BUDGET
	( p_api_version_number                  => p_api_version_number
 	 ,p_commit                              => FND_API.G_FALSE
 	 ,p_init_msg_list                       => FND_API.G_FALSE
 	 ,p_msg_count                           => p_msg_count
 	 ,p_msg_data                            => p_msg_data
 	 ,p_return_status                       => l_return_status
 	 ,p_workflow_started                    => l_workflow_started
 	 ,p_pm_product_code                     => p_pm_product_code
 	 ,p_pa_project_id                       => l_project_id
 	 ,p_pm_project_reference                => p_pm_project_reference
 	 ,p_budget_type_code                    => 'AR'
 	 ,p_mark_as_original                    => 'Y'
	 );
        -- dbms_output.put_line('returned from BASELINE_BUDGET ... status = '||l_return_status);

	IF (nvl(PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB,'N') = 'Y') THEN
		PA_FP_CONSTANTS_PKG.G_CALLED_FROM_AGREEMENT_PUB := 'N'; -- reset the value bug 3099706
	END IF;

        IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
        THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF l_return_status = FND_API.G_RET_STS_ERROR
        THEN
                        RAISE FND_API.G_EXC_ERROR;
        END IF; End of comment for bug 4941046 */


    IF FND_API.to_boolean( p_commit )
    THEN
        COMMIT;
    END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR
                THEN
                ROLLBACK TO Create_Budget_From_funding;
                p_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      p_msg_data      );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
                THEN
                ROLLBACK TO Create_Budget_From_funding;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      p_msg_data      );

        WHEN OTHERS
                THEN
                ROLLBACK TO Create_Budget_From_funding;
                p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
                THEN
                        FND_MSG_PUB.add_exc_msg
                                ( p_pkg_name            => G_PKG_NAME
                                , p_procedure_name      => l_api_name   );

                END IF;
                FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      p_msg_data      );


END create_baseline_budget;


end PA_AGREEMENT_PUB;

/
