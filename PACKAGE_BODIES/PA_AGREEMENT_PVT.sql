--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENT_PVT" as
/*$Header: PAAFAPVB.pls 120.9.12010000.4 2009/11/21 00:45:24 rmandali ship $*/

--Global constants to be used in error messages
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_AGREEMENT_PVT';
G_AGREEMENT_CODE        CONSTANT VARCHAR2(9)  := 'AGREEMENT';

--PACKAGE GLOBAL to be used during updates ---------------------------
G_USER_ID               CONSTANT NUMBER := FND_GLOBAL.user_id;
G_LOGIN_ID              CONSTANT NUMBER := FND_GLOBAL.login_id;



-- ============================================================================
--
--Name:               convert_ag_ref_to_id
--Type:               Procedure
--Description:  This procedure can be used to convert the agreement reference to
--		to an agreement id.
--
--Called subprograms:
--			pa_agreement_pvt.fetch_agreement_id
--			pa_interface_utils_pub.map_new_amg_msg
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------

PROCEDURE convert_ag_ref_to_id
(p_pm_agreement_reference  IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_af_agreement_id  IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_out_agreement_id OUT NOCOPY NUMBER  /*file.sql.39*/
,p_RETURN_status    OUT NOCOPY VARCHAR2  /*file.sql.39*/)
IS
CURSOR 	l_agreement_id_csr
IS
SELECT 	'X'
FROM	pa_agreements_all
where   agreement_id = p_af_agreement_id;

l_api_name	CONSTANT 	VARCHAR2(30) := 'Convert_ag_ref_to_id';
l_agreement_id    		NUMBER ;
l_dummy				VARCHAR2(1);

BEGIN
	--dbms_output.put_line(' Inside the pvt ag_ref_to_id');
    p_return_status :=  FND_API.G_RET_STS_SUCCESS;


    IF p_af_agreement_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    AND p_af_agreement_id IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_agreement_id_csr;
      	FETCH l_agreement_id_csr INTO l_dummy;

      	IF l_agreement_id_csr%NOTFOUND
      	THEN
      		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             		pa_interface_utils_pub.map_new_amg_msg
              			( p_old_message_code => 'PA_INVALID_AGMT_ID'
              			,p_msg_attribute    => 'CHANGE'
               			,p_resize_flag      => 'N'
               			,p_msg_context      => 'GENERAL'
               			,p_attribute1       => ''
               			,p_attribute2       => ''
               			,p_attribute3       => ''
               			,p_attribute4       => ''
               			,p_attribute5       => '');
		END IF;
		CLOSE l_agreement_id_csr;
		RAISE FND_API.G_EXC_ERROR;
      	END IF;
      	CLOSE l_agreement_id_csr;
      	p_out_agreement_id := p_af_agreement_id;
        ELSIF  p_pm_agreement_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
              AND p_pm_agreement_reference IS NOT NULL
        THEN
        	--dbms_output.put_line('Calling fetch agreement id');
        	l_agreement_id  :=  pa_agreement_pvt.fetch_agreement_id(p_pm_agreement_reference => p_pm_agreement_reference);
        	--dbms_output.put_line('Agreement id:'||nvl(to_char(l_agreement_id),'NULL'));
         	IF  l_agreement_id IS NULL
         	THEN
             		IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             		THEN
                		FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                		FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Agreement Reference');
                		FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_agreement_reference);
                		FND_MSG_PUB.add;
              		END IF;
              	RAISE FND_API.G_EXC_ERROR;
         	ELSE
                	p_out_agreement_id := l_agreement_id;
         	END IF;
     	ELSE
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_AGMT_REF_AND_ID_MISS'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
     	END IF;
     	RAISE FND_API.G_EXC_ERROR;
     END IF; -- If p_af_agreement_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
EXCEPTION
	WHEN FND_API.G_EXC_ERROR
	THEN
	----dbms_output.put_line('handling an G_EXC_ERROR exception');
	p_RETURN_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	----dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception');
	p_RETURN_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS
	THEN
	----dbms_output.put_line('handling an OTHERS exception');
	p_RETURN_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	END IF;
END convert_ag_ref_to_id;

-- ============================================================================
--
--Name:               convert_fu_ref_to_id
--Type:               Procedure
--Description:  This procedure can be used to convert the funding reference to
--		to a funding id.
--
--Called subprograms:
--			pa_agreement_pvt.fetch_funding_id
--			pa_interface_utils_pub.map_new_amg_msg
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------
PROCEDURE convert_fu_ref_to_id
(p_pm_funding_reference  IN VARCHAR2  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
,p_af_funding_id  IN NUMBER    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
,p_out_funding_id OUT NOCOPY NUMBER  /*file.sql.39*/
,p_RETURN_status    OUT NOCOPY VARCHAR2  /*file.sql.39*/)
IS
CURSOR 	l_funding_id_csr
IS
SELECT 	'X'
FROM	pa_project_fundings
where   project_funding_id = p_af_funding_id;

l_api_name	CONSTANT 	VARCHAR2(30) := 'Convert_fu_ref_to_id';
l_agreement_id    		NUMBER ;
l_dummy				VARCHAR2(1);
l_funding_id   		NUMBER ;
BEGIN
	--dbms_output.put_line('Inside fetch agreement id');
    p_RETURN_status :=  FND_API.G_RET_STS_SUCCESS;

    IF p_af_funding_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    AND p_af_funding_id IS NOT NULL
    THEN

      	--check validity of this ID
      	OPEN l_funding_id_csr;
      	FETCH l_funding_id_csr INTO l_dummy;

      	IF l_funding_id_csr%NOTFOUND
      	THEN
      		IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
		THEN
             		pa_interface_utils_pub.map_new_amg_msg
              			( p_old_message_code => 'PA_INVALID_FUNDING_ID'
              			,p_msg_attribute    => 'CHANGE'
               			,p_resize_flag      => 'N'
               			,p_msg_context      => 'GENERAL'
               			,p_attribute1       => ''
               			,p_attribute2       => ''
               			,p_attribute3       => ''
               			,p_attribute4       => ''
               			,p_attribute5       => '');
		END IF;
		CLOSE l_funding_id_csr;
		RAISE FND_API.G_EXC_ERROR;
      	END IF;
      	CLOSE l_funding_id_csr;
      	p_out_funding_id := p_af_funding_id;
        ELSIF  p_pm_funding_reference <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
              AND p_pm_funding_reference IS NOT NULL
        THEN
        	l_funding_id  :=  fetch_funding_id(p_pm_funding_reference => p_pm_funding_reference);
         	IF  l_funding_id IS NULL
         	THEN
             		IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR)
             		THEN
                		FND_MESSAGE.SET_NAME('PA','PA_API_CONV_ERROR_AMG'); -- Bug 2257612
                		FND_MESSAGE.SET_TOKEN('ATTR_NAME','Pm Funding Reference');
                		FND_MESSAGE.SET_TOKEN('ATTR_VALUE',p_pm_funding_reference);
                		FND_MSG_PUB.add;
              		END IF;
              	RAISE FND_API.G_EXC_ERROR;
         	ELSE
                	p_out_funding_id := l_funding_id;
         	END IF;
     	ELSE
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_FUND_REF_AND_ID_MISS'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'Y'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
     	END IF;
     	RAISE FND_API.G_EXC_ERROR;
     END IF; -- If p_af_agreement_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     --dbms_output.put_line('Returning fetched funding id ='||nvl(to_char(p_out_funding_id),'NULL'));
EXCEPTION
	WHEN FND_API.G_EXC_ERROR
	THEN
	----dbms_output.put_line('handling an G_EXC_ERROR exception');
	p_RETURN_status := FND_API.G_RET_STS_ERROR;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	----dbms_output.put_line('handling an G_EXC_UNEXPECTED_ERROR exception');
	p_RETURN_status := FND_API.G_RET_STS_UNEXP_ERROR;

	WHEN OTHERS
	THEN
	----dbms_output.put_line('handling an OTHERS exception');
	p_RETURN_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
		FND_MSG_PUB.add_exc_msg
				( p_pkg_name		=> G_PKG_NAME
				, p_procedure_name	=> l_api_name	);
	END IF;

END convert_fu_ref_to_id;

-- ============================================================================
--
--Name:               fetch_agreement_id
--Type:               Function
--Description:  This function can be used to fetch an agreement id when
--		provided with the agreement reference.
--
--Called subprograms:
--			None
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------

FUNCTION fetch_agreement_id
(p_pm_agreement_reference IN VARCHAR2)
RETURN NUMBER
IS
CURSOR c_agreements_csr IS
SELECT	p.agreement_id
FROM 	pa_agreements_all p
WHERE	p.pm_agreement_reference = p_pm_agreement_reference;

l_agreement_rec      c_agreements_csr%ROWTYPE;

BEGIN

      OPEN c_agreements_csr;
      FETCH  c_agreements_csr INTO l_agreement_rec;
      IF c_agreements_csr%NOTFOUND THEN
         CLOSE c_agreements_csr;
         RETURN NULL;
      ELSE
         CLOSE c_agreements_csr;
         RETURN(l_agreement_rec.agreement_id);
      END IF;

END fetch_agreement_id;

-- ============================================================================
--
--Name:               fetch_funding_id
--Type:               Function
--Description:  This function can be used to fetch an funding id when
--		provided with the funding reference.
--
--Called subprograms:
--			None
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------

FUNCTION fetch_funding_id
(p_pm_funding_reference IN VARCHAR2 )
RETURN NUMBER
IS
CURSOR c_fundings_csr IS
SELECT project_funding_id
FROM
	pa_project_fundings
WHERE
	pm_funding_reference = p_pm_funding_reference;

l_funding_rec      c_fundings_csr%ROWTYPE;

BEGIN

      OPEN c_fundings_csr;
      FETCH  c_fundings_csr INTO l_funding_rec;
      IF c_fundings_csr%NOTFOUND THEN
         CLOSE c_fundings_csr;
         RETURN NULL;
      ELSE
         CLOSE c_fundings_csr;
         RETURN(l_funding_rec.project_funding_id);
      END IF;

END fetch_funding_id;


-- ============================================================================
--
--Name:               check_create_agreement_ok
--Type:               Function
--Description:  This function can be used to check IF it is OK to create the
--		agreement.
--
--Called subprograms:
--		pa_agreement_utils.check_valid_customer
--		pa_agreement_utils.check_valid_type
--		pa_agreement_utils.check_valid_agreement_num
--		pa_agreement_utils.check_valid_term_id
--		pa_agreement_pvt.check_valid_template_flag
--		pa_agreement_pvt.check_valid_revenue_limit_flag
--		pa_agreement_utils.check_valid_owned_by_person_id
--		pa_agreement_utils.check_unique_agreement
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      10-SEP-2001      Srividya Modified for MCB2.
-- -----------------------------------------------------------------------------

FUNCTION check_create_agreement_ok
(p_pm_agreement_reference	IN 	VARCHAR2
 ,p_customer_id			IN	NUMBER
 ,p_agreement_type		IN 	VARCHAR2
 ,p_agreement_num		IN 	VARCHAR2
 ,p_term_id			IN	NUMBER
 ,p_template_flag		IN	VARCHAR2
 ,p_revenue_limit_flag		IN	VARCHAR2
 ,p_owned_by_person_id		IN	NUMBER
 ,p_owning_organization_id      IN      NUMBER default null
 ,p_agreement_currency_code     IN      VARCHAR2 default null
 ,p_invoice_limit_flag          IN      VARCHAR2 default null
 /* Federal*/
 ,p_start_date                  IN      DATE  DEFAULT NULL
 ,p_end_date                    IN      DATE  DEFAULT NULL
 ,p_advance_required            IN      VARCHAR2 DEFAULT NULL
 ,p_billing_sequence            IN      Number   DEFAULT NULL)
RETURN VARCHAR2
IS
-- LOCAL VARIABLES
l_RETURN 	VARCHAR2(1):='Y';

/* x_advance_flag  boolean; Commented for bug 5743599*/
x_error_message varchar2(240);
x_status        Number;

BEGIN
 --dbms_output.put_line('Inside the private package');

 -- VALIDATE THE PARAMETERS

 -- Customer Number
 --dbms_output.put_line('Check for Valid Customer Id');
 IF pa_agreement_utils.check_valid_customer
  	(p_customer_id => p_customer_id) = 'N'
 THEN
	--dbms_output.put_line('Invalid Customer Id');
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
   	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_CUST'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
    END IF;

    -- Agreement Type
    --dbms_output.put_line('Check for valid Agreement Type');
    IF pa_agreement_utils.check_valid_type
    	(p_agreement_type => p_agreement_type) = 'N'
    THEN
    	--dbms_output.put_line('Invalid Agreement Type');
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TYPE'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
     END IF;

/* NOT REQUIRED - TEST
     -- Agreement Number
     --dbms_output.put_line('Check for Agreement Number');
     IF pa_agreement_utils.check_valid_agreement_num
     		(p_agreement_num => p_agreement_num) = 'N'
     THEN
     	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	 THEN
     	 	--dbms_output.put_line('Invalid Agreement Number');
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_AGMT_NUM'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
     END IF;
*/

     -- Term Name
     --dbms_output.put_line('Check for valid Term Name');
     IF pa_agreement_utils.check_valid_term_id
     		(p_term_id => p_term_id) = 'N'
     THEN
     	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	 THEN
     	 	--dbms_output.put_line('Invalid Term Name');
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TERM_NAME'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
      END IF;


      -- Template Flag
IF p_template_flag is not null THEN
      --dbms_output.put_line('Check for valid Template Flag');
      IF pa_agreement_pvt.check_yes_no
      		( p_val => p_template_flag) = 'N'
      THEN
      	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	  THEN
     	  	--dbms_output.put_line('Invalid Template Flag');
          	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TEMP_FLG'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
           END IF;
           l_RETURN:='N';
       END IF;

END IF;
       -- Revenue Limit Flag
       --dbms_output.put_line('Check for valid Revenue Limit Flag');
       IF pa_agreement_pvt.check_yes_no
       		(p_val => p_revenue_limit_flag) = 'N'
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	   THEN
     	   	--dbms_output.put_line('Invalid Revenue Limit Flag');
           	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_REV_LT_FLG'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
           END IF;
           l_RETURN:='N';
        END IF;


        -- Owned By Person Id
        --dbms_output.put_line('Check for valid owned by person id');
        IF pa_agreement_utils.check_valid_owned_by_person_id
        	(p_owned_by_person_id => p_owned_by_person_id) = 'N'
        THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	     THEN
     	     	--dbms_output.put_line('Invalid Owned By Person id');
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_OWND_BY_PRSN_ID'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
             END IF;
             l_RETURN:='N';
       END IF;

       -- Unique Agreement
       --dbms_output.put_line('Check for Unique agreement');
       IF pa_agreement_utils.check_unique_agreement
       		(p_agreement_num => p_agreement_num
       		 ,p_agreement_type => p_agreement_type
       		 ,p_customer_id => p_customer_id) = 'N'
       THEN
       		--dbms_output.put_line('Agreement Not Unique');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	    THEN
            	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_AGMT_NOT_UNIQUE'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
           END IF;
           l_RETURN:='N';
       END IF;

/* MCB2 code begins */
       -- valid owning organization id
       --dbms_output.put_line('Check for valid owning orgn id ');

       IF (p_owning_organization_id is not null )and
           (p_owning_organization_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )then /* Bug 2701579 */

          IF pa_agreement_utils.check_valid_owning_orgn_id
                (p_owning_organization_id => p_owning_organization_id
                 ) = 'N'
          THEN
                --dbms_output.put_line('Invalid owning organization_id ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_OWNING_ORGN_ID_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
          END IF;
       END IF;

      IF (p_agreement_currency_code is not null ) AND
            (p_agreement_currency_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then /* Bug 2701579 */

          IF pa_agreement_utils.check_valid_agr_curr_code
                (p_agreement_currency_code => p_agreement_currency_code
                 ) = 'N'
          THEN
                --dbms_output.put_line('Invalid agreement_currency_code ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CURR_NOT_VALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
          END IF;
       END IF;

/*Federal*/

      IF (p_start_date is not null ) AND
            (p_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) AND
	 (p_end_date is not null) AND
	 (p_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) then

          IF (p_start_date >= p_end_date)

          THEN
                --dbms_output.put_line('Invalid agreement_currency_code ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_START_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
          END IF;
       END IF;

/*      IF (p_advance_required = 'Y') then

       IF (FND_FUNCTION.TEST('PA_PAXINEAG_ADVREQ')) THEN

          PA_ADVANCE_CLIENT_EXT.advance_required(p_customer_id,
	                                         x_advance_flag,
	    			                 x_error_message,
					         x_status);

          IF (x_status = 0 and x_advance_flag = TRUE) THEN
	    null;
          ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CLNT_ADV_CHECK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
          END IF;   /* client advance flag value
        ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CLNT_ADV_CHECK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
        END IF; /* Function security
      END IF; /*Advance required  Commented for bug 5743599*/


      IF ((p_billing_sequence <=0 or p_billing_sequence > 99) and
           p_billing_sequence <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
           then

            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_BILL_SEQ'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';

       END IF;

       -- invoice Limit Flag
       --dbms_output.put_line('Check for valid invoice Limit Flag');

        IF (p_invoice_limit_flag is not null)
              AND (p_invoice_limit_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then  /* Bug 2701579 */

          IF pa_agreement_pvt.check_yes_no
                (p_val => p_invoice_limit_flag) = 'N'
          THEN

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
             THEN
                --dbms_output.put_line('Invalid invoice Limit Flag');
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_INV_LT_FLG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
             END IF;
             l_RETURN:='N';
          END IF;
       END IF;

/* MCB2 code ends */
       RETURN(l_RETURN);

END check_create_agreement_ok;

-- ============================================================================
--
--Name:               check_update_agreement_ok
--Type:               Function
--Description:  This function can be used to check IF it is OK to update the
--		agreement.
--
--Called subprograms:
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      10-SEP-2001      Srividya Modified for MCB2.
--      25-JUL-2002      prajaram      		 Bug 2442176: A new check is added
--						 to see if the Agreement has funding
--						 allocated and if so the currency is
--						 not allowed to be changed.
-- -----------------------------------------------------------------------------
FUNCTION check_update_agreement_ok
(p_pm_agreement_reference       IN       VARCHAR2
,p_agreement_id                 IN       NUMBER
,p_funding_id		        IN       NUMBER
,p_customer_id			IN OUT NOCOPY	NUMBER  /*Bug 6602451*/
,p_agreement_type		IN OUT NOCOPY 	VARCHAR2  /*Bug 6602451*/
,p_term_id			IN OUT NOCOPY	NUMBER  /*Bug 6602451*/
,p_template_flag		IN	VARCHAR2
,p_revenue_limit_flag		IN OUT NOCOPY	VARCHAR2  /*Bug 6602451*/
,p_owned_by_person_id		IN OUT NOCOPY	NUMBER  /*Bug 6602451*/
,p_owning_organization_id      IN OUT NOCOPY    NUMBER  /*Bug 6602451*/
,p_agreement_currency_code     IN OUT NOCOPY    VARCHAR2  /*Bug 6602451*/
,p_invoice_limit_flag          IN OUT NOCOPY    VARCHAR2  /*Bug 6602451*/
/*Federal*/
,p_start_date                   IN      DATE  DEFAULT NULL
,p_end_date                     IN      DATE  DEFAULT NULL
,p_advance_required             IN      VARCHAR2 DEFAULT NULL
,p_billing_sequence             IN      Number   DEFAULT NULL
,p_amount                       IN      NUMBER   DEFAULT NULL)

RETURN VARCHAR2
IS
-- LOCAL VARIABLES
l_start_date    DATE;
l_end_date      DATE;
l_adv_req       VARCHAR2(1);

cur_start_date    DATE;
cur_end_date      DATE;
cur_adv_req       VARCHAR2(1);
cur_adv_amt      NUMBER;
cur_agmt_amt      NUMBER;
l_fund_count      NUMBER;
--l_tot_fund        NUMBER;  Commented for bug 6853994
l_agm_amt         NUMBER;
l_count           NUMBER;

x_advance_flag  boolean;
x_error_message varchar2(240);
x_status        Number;

l_RETURN 	VARCHAR2(1) :='Y';

/* Cursor added for bug 6602451 */
CURSOR agrcur IS SELECT * FROM PA_AGREEMENTS_ALL WHERE AGREEMENT_ID = p_agreement_id;

BEGIN
	--dbms_output.put_line('Inside: PA_AGREEMENT_PVT.CHECK_UPDATE_AGREEMENT_OK');
FOR l_agrcur IN agrcur LOOP  /*Bug 6602451 */
 -- VALIDATE THE INCOMING PARAMETERS
 -- Customer Number
 --dbms_output.put_line('Check for Valid Customer Id');
IF (p_customer_id IS NOT NULL AND p_customer_id <>
PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    AND p_customer_id <> l_agrcur.customer_id) THEN  /* Bug 6602451 */
 IF pa_agreement_utils.check_valid_customer
  	(p_customer_id => p_customer_id) = 'N'
 THEN
	--dbms_output.put_line('Invalid Customer Id');
   	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
   	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_CUST'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
    END IF;
/* Added for bug 6602451 */
ELSE
   p_customer_id := l_agrcur.customer_id;
END IF;

    -- Agreement Type
    --dbms_output.put_line('Check for valid Agreement Type');
IF (p_agreement_type IS NOT NULL AND p_agreement_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND p_agreement_type <> l_agrcur.agreement_type) THEN  /* Bug 6602451 */
    IF pa_agreement_utils.check_valid_type
    	(p_agreement_type => p_agreement_type) = 'N'
    THEN
    	--dbms_output.put_line('Invalid Agreement Type');
    	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
    	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TYPE'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
     END IF;
/* Added for bug 6602451 */
ELSE
   p_agreement_type := l_agrcur.agreement_type;
END IF;

/* NOT REQUIRED
     -- Agreement Number
     --dbms_output.put_line('Check for Agreement Number');
     IF pa_agreement_utils.check_valid_agreement_num
     		(p_agreement_num => p_agreement_num) = 'N'
     THEN
     	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	 THEN
     	 	--dbms_output.put_line('Invalid Agreement Number');
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_AGMT_NUM'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
     END IF;
*/

     -- Term Name
     --dbms_output.put_line('Check for valid Term Name');
IF (p_term_id IS NOT NULL AND p_term_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    AND p_term_id <> l_agrcur.term_id) THEN  /* Bug 6602451 */
     IF pa_agreement_utils.check_valid_term_id
     		(p_term_id => p_term_id) = 'N'
     THEN
     	 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	 THEN
     	 	--dbms_output.put_line('Invalid Term Name');
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TERM_NAME'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
      END IF;
/* Added for bug 6602451 */
ELSE
   p_term_id := l_agrcur.term_id;
END IF;

/*
      -- Template Flag
      --dbms_output.put_line('Check for valid Template Flag');
      IF pa_agreement_pvt.check_yes_no
      		( p_val => p_template_flag) = 'N'
      THEN
      	  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	  THEN
     	  	--dbms_output.put_line('Invalid Template Flag');
          	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TEMP_FLG'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
           END IF;
           l_RETURN:='N';
       END IF;

*/
       -- Revenue Limit Flag
       --dbms_output.put_line('Check for valid Revenue Limit Flag');
IF (p_revenue_limit_flag IS NOT NULL AND p_revenue_limit_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    AND p_revenue_limit_flag <> l_agrcur.revenue_limit_flag) THEN  /* Bug 6602451 */
   IF pa_agreement_pvt.check_yes_no
       		(p_val => p_revenue_limit_flag) = 'N'
       THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	   THEN
     	   	--dbms_output.put_line('Invalid Revenue Limit Flag');
           	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_REV_LT_FLG'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
           END IF;
           l_RETURN:='N';
        END IF;
/* Added for bug 6602451 */
ELSE
   p_revenue_limit_flag := l_agrcur.revenue_limit_flag;
END IF;

        -- Owned By Person Id
        --dbms_output.put_line('Check for valid owned by person id');
IF (p_owned_by_person_id IS NOT NULL AND p_owned_by_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   AND p_owned_by_person_id <> l_agrcur.owned_by_person_id) THEN  /* Bug 6602451 */
        IF pa_agreement_utils.check_valid_owned_by_person_id
        	(p_owned_by_person_id => p_owned_by_person_id) = 'N'
        THEN
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	     THEN
     	     	--dbms_output.put_line('Invalid Owned By Person id');
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_OWND_BY_PRSN_ID'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
             END IF;
             l_RETURN:='N';
       END IF;
/* Added for bug 6602451 */
ELSE
   p_owned_by_person_id := l_agrcur.owned_by_person_id;
END IF;

/*  NOT REQUIRED
 -- Check Funding Revenue Amount
 IF pa_agreement_utils.check_fund_rev_amt
     		( p_funding_id => p_funding_id) = 'N'
 THEN
 	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_FUND_REV_AMT'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
 END IF;
*/

/*Federal*/

      SELECT start_date,
             expiration_date,
	     nvl(advance_Required,'N'),
	     advance_amount,
	     amount
	INTO cur_start_date,
	     cur_end_date,
	     cur_adv_req,
	     cur_adv_amt,
	     cur_agmt_amt
        FROM pa_agreements_all
       WHERE agreement_id = p_agreement_id;
/*  Commented for bug 6853994
      SELECT sum(allocated_amount)
        INTO l_tot_fund
        FROM pa_project_fundings
       WHERE agreement_id = p_agreement_id;
*/
      IF (p_start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
        l_start_date := cur_start_date;
      ELSE
        l_start_date := p_start_date;
      END IF;

      IF (p_end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
        l_end_date := cur_end_date;
      ELSE
        l_end_date := p_end_date;
      END IF;

      IF (p_advance_required = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

       l_adv_req := cur_adv_req;
      ELSE
      l_adv_req  := nvl(p_advance_required,'N');/*Bug 5747269 */

      END IF;

      IF (l_adv_req = 'Y') then
        l_agm_amt := cur_adv_amt;
      ELSE
        IF (p_amount = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
         l_agm_amt := cur_agmt_amt;
        ELSE
	 l_agm_amt := p_amount;
        END IF;
      END IF;

      IF (l_start_date >= l_end_date)
       THEN
                --dbms_output.put_line('Invalid agreement_currency_code ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_START_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
       l_RETURN:='N';
      END IF;

 /* Federal
         SELECT count(*)
	   INTO l_count
	  FROM  pa_project_fundings fun,
	        pa_events ev
          WHERE fun.agreement_id = p_agreement_id
	    AND fun.agreement_id = ev.agreement_id
	    AND fun.project_id   = ev.project_id
	    AND ev.completion_date not between l_start_date and l_end_date;


      IF (l_count >0)
       THEN
                --dbms_output.put_line('Invalid agreement_currency_code ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_EVENT_DATE'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
       l_RETURN:='N';
      END IF; */

     IF (cur_adv_req <> l_adv_req) then

         SELECT COUNT(*)
	   INTO l_fund_count
	   FROM pa_project_fundings
	  WHERE agreement_id = p_agreement_id;

        IF l_fund_count >0 THEN
           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CLNT_ADV_CHECK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
        ELSE
	    IF FND_FUNCTION.TEST('PA_PAXINEAG_ADVREQ') THEN

              PA_ADVANCE_CLIENT_EXT.advance_required(p_customer_id,
                                                 x_advance_flag,
                                                 x_error_message,
                                                 x_status);

              IF (x_status = 0 and x_advance_flag = TRUE) THEN
                null;
              ELSE
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                  pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CLNT_ADV_CHECK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
                l_RETURN:='N';
              END IF; /* value from client ext*/
           ELSE
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
                  pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CLNT_ADV_CHECK'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                END IF;
                l_RETURN:='N'; /*Bug 5747269*/
           END IF; /* Function security */
         END IF; /* count >0 */
      END IF; /* curr and incoming value check*/

    /* 5684469 changed and to OR in the p_billing_sequence */

     IF ((p_billing_sequence <=0 or  p_billing_sequence > 99)and
                p_billing_sequence <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)then

           IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_BILL_SEQ'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
          l_RETURN:='N';

      END IF;

 -- Check Revenue Limit
IF (UPPER(p_revenue_limit_flag)='Y') THEN     /* IF condition added for bug 2862024 */

 IF pa_agreement_utils.check_revenue_limit
      		(p_agreement_id => p_agreement_id)= 'N'
 THEN
 	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
         	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_REVENUE_LIMIT'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
 END IF;

END IF;/* 2862024 */
 -- Check Fund Allocated
 /*IF pa_agreement_utils.check_fund_allocated
      		(p_agreement_id => p_agreement_id)= 'N' Federal */
/* Commeted for bug 6853994
 IF (l_agm_amt < l_tot_fund)-- bug 5685032 changed to < from <=
 THEN
 	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ALLOC'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       => p_pm_agreement_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
  END IF; */

/* MCB2 code begins */
       -- valid owning organization id
       --dbms_output.put_line('Check for valid owning orgn id ');
/*       IF p_owning_organization_id is not null then         Commenetd for Bug 6602451 and added the below IF condition*/

      IF (p_owning_organization_id IS NOT NULL AND p_owning_organization_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
         AND p_owning_organization_id <> l_agrcur.owning_organization_id) THEN /* Bug 6602451 */
          IF pa_agreement_utils.check_valid_owning_orgn_id
                (p_owning_organization_id => p_owning_organization_id
                 ) = 'N'
          THEN
                --dbms_output.put_line('Invalid owning organization_id ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_OWNING_ORGN_ID_INVALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
          END IF;
/* Added for bug 6602451 */
       ELSE
	      p_owning_organization_id := l_agrcur.owning_organization_id;
       END IF;

/*       IF p_agreement_currency_code is not null then         Commenetd for Bug 6602451 and added the below IF condition*/

	   IF (p_agreement_currency_code IS NOT NULL AND p_agreement_currency_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
	      AND p_agreement_currency_code <> l_agrcur.agreement_currency_code) THEN  /* Bug 6602451 */
       -- Start of Bugfix  2442176
          IF pa_agreement_utils.check_valid_agr_curr_code
                (p_agreement_currency_code => p_agreement_currency_code
                 ) ='Y' THEN
                IF l_return = 'Y' THEN
                BEGIN
                   SELECT 'N' INTO l_return
                   FROM PA_AGREEMENTS_ALL
                   WHERE AGREEMENT_ID = p_agreement_id
                   AND (AGREEMENT_CURRENCY_CODE <> p_agreement_currency_code
                   AND EXISTS ( SELECT *
                             FROM PA_PROJECT_FUNDINGS
                             WHERE AGREEMENT_ID= p_agreement_id
                             AND   nvl(ALLOCATED_AMOUNT,0) <> 0));
                    --dbms_output.put_line('Invalid agreement_currency_code ');
                   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                   THEN
                        pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CURR_NOT_VALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
                   END IF;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_return :='Y';
                END;
                end if;
          ELSE
          /* Comment for bug 2442176 : IF pa_agreement_utils.check_valid_agr_curr_code
                (p_agreement_currency_code => p_agreement_currency_code
                 ) = 'N'
          THEN */
          -- End of Changes for Bug 2442176

                --dbms_output.put_line('Invalid agreement_currency_code ');
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_CURR_NOT_VALID'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
            END IF;
            l_RETURN:='N';
          END IF;
/* Added for bug 6602451 */
       ELSE
	      p_agreement_currency_code := l_agrcur.agreement_currency_code;
       END IF;

       -- invoice Limit Flag
       --dbms_output.put_line('Check for valid invoice Limit Flag');
/*       IF p_invoice_limit_flag is not null THEN         Commenetd for Bug 6602451 and added the below IF condition*/

       IF (p_invoice_limit_flag IS NOT NULL AND p_invoice_limit_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
	       AND  p_invoice_limit_flag <> l_agrcur.invoice_limit_flag) THEN /* Bug 6602451 */
          IF pa_agreement_pvt.check_yes_no
                (p_val => p_invoice_limit_flag) = 'N' THEN

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                --dbms_output.put_line('Invalid invoice Limit Flag');
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_INV_LT_FLG'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
             END IF;
             l_RETURN:='N';

          ELSIF UPPER(p_invoice_limit_flag)='Y' THEN /* Added for bug 2862024 */
           IF pa_agreement_utils.check_invoice_limit
                (p_agreement_id => p_agreement_id)= 'N' THEN

             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                   pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INVALID_INVOICE_LIMIT'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'AGREEMENT'
                        ,p_attribute1       => p_pm_agreement_reference
                        ,p_attribute2       => ''
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
             END IF;
             l_RETURN:='N';
          END IF;
        END IF; /* 2862024 */
/* Added for bug 6602451 */
	   ELSE
	      p_invoice_limit_flag := l_agrcur.invoice_limit_flag;
       END IF;
END LOOP;
/* MCB2 code ends */

  --dbms_output.put_line('Check Update Agreement OK retuning :' ||l_return);
  RETURN(l_RETURN);

END check_update_agreement_ok;

-- ============================================================================
--
--Name:               check_delete_agreement_ok
--Type:               Function
--Description:  This function can be used to check IF it is OK to delete the
--		agreement.
--
--Called subprograms:
--			pa_project_utils.check_delete_agreement_ok
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------

FUNCTION check_delete_agreement_ok
(p_agreement_id 		IN 	NUMBER
,p_pm_agreement_reference	IN	VARCHAR2)
RETURN VARCHAR2
IS

-- LOCAL CURSORS

CURSOR l_funding_id_csr(p_agreement_id NUMBER)
IS
SELECT       project_funding_id,pm_funding_reference,agreement_id, allocated_amount
FROM         pa_project_fundings f
WHERE        f.agreement_id = p_agreement_id;

-- LOCAL VARIABLES
l_RETURN 		VARCHAR2(1) :='Y';
l_funding_id_rec 	l_funding_id_csr%ROWTYPE;
l_count                 NUMBER; /*Federal*/
BEGIN
/*if(check_delete_agreement_ok_fp(p_agreement_id)='N')then
return ('N');
else*/

	OPEN l_funding_id_csr( p_agreement_id);
	LOOP
        FETCH l_funding_id_csr INTO l_funding_id_rec;
           IF l_funding_id_csr%NOTFOUND
           THEN
           	EXIT;
           ELSE
           	l_RETURN:= pa_agreement_pvt.check_delete_funding_ok
           			(p_agreement_id => l_funding_id_rec.agreement_id
           			,p_funding_id => l_funding_id_rec.project_funding_id
           			,p_pm_funding_reference => l_funding_id_rec.pm_funding_reference);
                IF l_RETURN = 'N'
                THEN
                	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	  		THEN
          			pa_interface_utils_pub.map_new_amg_msg
           				( p_old_message_code => 'PA_CANT_DELETE_AGMT'
            				,p_msg_attribute    => 'CHANGE'
            				,p_resize_flag      => 'Y'
            				,p_msg_context      => 'AGREEMENT'
            				,p_attribute1       => p_pm_agreement_reference
            				,p_attribute2       => ''
            				,p_attribute3       => ''
            				,p_attribute4       => ''
            				,p_attribute5       => '');
           		END IF;
 			EXIT;
                END IF;
            END IF;
          END LOOP;
          CLOSE l_funding_id_csr;


/*Federal */
      SELECT  count(*)
        INTO  l_count
        FROM  pa_agreements_all
       WHERE  agreement_id = p_agreement_id
	 and  advance_amount >0;


      IF (l_count>0) THEN
        l_RETURN:='N';
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                 pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_RECP_DELETE_AGMT'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N' /*Bug 5909864 */
                  ,p_msg_context      => 'AGREEMENT'
                  ,p_attribute1       => p_pm_agreement_reference
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
        END IF;
     END IF;
/*
       select count(*)
         into l_count
         from pa_events e,
	      pa_project_fundings f
	where e.project_id   = f.project_id
	  and e.agreement_id = f.agreement_id
	  and f.agreement_id = p_agreement_id;

     IF (l_count>0) THEN
        l_RETURN:='N';
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
                 pa_interface_utils_pub.map_new_amg_msg
                  ( p_old_message_code => 'PA_EVENT_AGMT_DELETE'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'Y'
                  ,p_msg_context      => 'AGREEMENT'
                  ,p_attribute1       => p_pm_agreement_reference
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
        END IF;
     END IF;*/

 RETURN(l_RETURN);
--end if;
END check_delete_agreement_ok;

-- ===========================================================================
--
--Name:               check_funding_category
--Type:               Function
--Description:        This function can be used to check if the
--                    funding category is valid.
--
--Called subprograms:
--
--
--
--History:
--      11-JUN-2002     Raji         Created - Bug 2403652.
--      26-JUL-02        Raji         Modified for Bug 2483081
-- ---------------------------------------------------------------------------

FUNCTION check_funding_category
( p_project_id                  IN      NUMBER
 ,p_task_id                     IN      NUMBER
 ,p_agreement_id                IN      NUMBER
 ,p_pm_funding_reference        IN      VARCHAR2
 ,p_funding_category            IN      VARCHAR2)

RETURN VARCHAR2
IS

-- Local Variables
l_funding_category        VARCHAR2(30);
l_return                  VARCHAR2(1) := 'Y';

BEGIN
    /* code change for bug 2868818*/

    IF upper(p_funding_category) = 'REVALUATION'
    THEN
    pa_interface_utils_pub.map_new_amg_msg
        ( p_old_message_code => 'PA_INV_FUND_CAT'
        ,p_msg_attribute    => 'CHANGE'
        ,p_resize_flag      => 'N'
        ,p_msg_context      => 'FUNDING'
        ,p_attribute1       => ''
        ,p_attribute2       => 'p_pm_funding_reference'
        ,p_attribute3       => ''
        ,p_attribute4       => ''
        ,p_attribute5       => '');

        l_RETURN := 'N';
        RETURN(l_RETURN);

    END IF;

    /* end code change for bug 2868818*/

   select meaning /* 2483081 */
   into l_funding_category
   from pa_lookups
   where lookup_code= p_funding_category
     and lookup_type= 'FUNDING CATEGORY TYPE';

--  Check if valid funding category

  RETURN(l_RETURN);
EXCEPTION
WHEN NO_DATA_FOUND THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_INV_FUND_CAT'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'FUNDING'
                        ,p_attribute1       => ''
                        ,p_attribute2       => p_pm_funding_reference
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_RETURN := 'N';
         RETURN(l_RETURN);
WHEN OTHERS THEN
 l_RETURN := 'N';
 RETURN(l_RETURN);
END check_funding_category;


-- ============================================================================
--
--Name:               check_add_funding_ok
--Type:               Function
--Description:  This function can be used to check IF it is OK to add funding.
--
--Called subprograms:
--
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      10-SEP-2001      Srividya                Modified.
--           Call to check valid project includes project_id also
--           ADded mcb2 code
--   03-SEP-2008  jngeorge  Bug 6600563: Added parameter p_calling_context
-- -----------------------------------------------------------------------------

FUNCTION check_add_funding_ok
(p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_agreement_id                IN	NUMBER
 ,p_pm_funding_reference   	IN 	VARCHAR2
 ,p_funding_amt			IN	NUMBER
 ,p_customer_id			IN	NUMBER
 ,p_project_rate_type           IN      VARCHAR2 default null
 ,p_project_rate_date           IN      DATE     default null
 ,p_project_exchange_rate       IN      NUMBER   default null
 ,p_projfunc_rate_type          IN      VARCHAR2 default null
 ,p_projfunc_rate_date          IN      DATE     default null
 ,p_projfunc_exchange_rate      IN      NUMBER   default null -- Bug 6600563
 ,p_calling_context             IN      VARCHAR2 default null)
RETURN VARCHAR2
IS
-- added to validate the funding amount
-- LOCAL VARIABLES

l_RETURN 	VARCHAR2(1):='Y';
l_funding_lvl   VARCHAR2(1);
l_valid_fund_amt VARCHAR2(1);
l_rate_type      VARCHAR2(1) := 'Y';
l_old_message_code VARCHAR2(35);
l_plan_type_id number;
l_msg_count number;
l_msg_data varchar2(2000);
l_return_status varchar2(2000);

l_Enable_Top_Task_Cust_Flag VARCHAR2(1);
l_Exist_Flag VARCHAR2(1);

l_Allowable_Funding_Level_Code pa_project_types_all.ALLOWABLE_FUNDING_LEVEL_CODE%type;	/*Added for bug 3614374*/

l_Inv_Method_Override_Flag VARCHAR2(1);  /*Added for Bug 5550709*/

BEGIN
	--dbms_output.put_line('Inside: PA_AGREEMENT_PVT.CHECK_ADD_FUNDING_OK');

-- VALIDATE THE INCOMING PARAMETERS

--  Check Valid Project

-- NOT REQUIRED
--dbms_output.put_line('Check valid project');
IF (   ( pa_agreement_utils.check_valid_project
		(p_customer_id => p_customer_id,
                 p_project_id  => p_project_id,
		 p_agreement_id => p_agreement_id) = 'N' )/*Federal*/
  OR
       ( pa_agreement_utils.check_proj_agr_fund_ok
                (p_agreement_id => p_agreement_id,
                 p_project_id  => p_project_id) = 'N' )   /* added OR condition Bug2756047 */
   )
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_PROJECT'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
END IF;
--dbms_output.put_line('Check valid customer');
IF pa_agreement_utils.check_valid_customer
		(p_customer_id => p_customer_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_CUSTOMER'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
END IF;


--  Check Valid Task
IF p_task_id IS NOT NULL and p_task_id <> FND_API.G_MISS_NUM THEN
--dbms_output.put_line('Check valid task');
IF pa_agreement_utils.check_valid_task
	(p_project_id => p_project_id
	,p_task_id => p_task_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
     		--dbms_output.put_line('Invalid Task');
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_TASK'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
END IF;
END IF;

-- Following changes are made for FP_M : Top Task customer changes
l_Enable_Top_Task_Cust_Flag := PA_Billing_Pub.Get_Top_Task_Customer_Flag (
					P_Project_ID => P_Project_ID );

/* Added the code for bug 5550709. Task level funding is required if customer at
   top task or invoice method by top task is enabled. */
l_Inv_Method_Override_Flag := PA_Billing_Pub.Get_Inv_Method_Override_Flag (
                                        P_Project_ID => P_Project_ID );

IF p_task_id IS NULL and (l_Enable_Top_Task_Cust_Flag = 'Y' or
l_Inv_Method_Override_Flag = 'Y') THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                --dbms_output.put_line('Invalid Funding level');
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_TASK_LEVEL_FUND_REQD'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'FUNDING'
                        ,p_attribute1       => ''
                        ,p_attribute2       => p_pm_funding_reference
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
        END IF;
        RETURN 'N';
END IF;

-- Check for Top Task Customer existence if l_Enable_Top_Task_Cust_Flag = 'Y'
--
-- If Project is implemented with Top Task Customer enabled then make sure
-- that the funding line's top task is associated to the customer which is same
-- as that of agreement's customer.
-- If not, then raise the error.
IF l_Enable_Top_Task_Cust_Flag = 'Y'
THEN
  begin
    Select 1 into l_Exist_Flag
    From   PA_Tasks
    Where  Project_ID  = P_Project_ID
    AND    Task_ID     = P_Task_ID
    AND    Customer_ID = P_Customer_ID
    AND    Rownum      < 2;
    Exception when no_data_found then
      PA_Interface_Utils_Pub.Map_New_AMG_Msg (
        P_Old_Message_Code => 'PA_INVALID_TASK_CUSTOMER',
	P_Msg_Attribute    => 'CHANGE',
	P_Msg_Context      => 'FUNDING',
        p_resize_flag      => 'N',	-- Fix for bug 3523077
	P_Attribute1       => '',
	P_Attribute2       => p_pm_funding_reference,
	P_Attribute3       => '',
	P_Attribute4       => '',
	P_Attribute5       => ''
      );
      Return 'N';
  end;
END IF;
-- End of changes made for FP_M : Top Task customer changes

-- Check Funding Level
--dbms_output.put_line('Check Funding Level');

/* Added for bug 3614374*/
/* The code validates the funding level when user tries to create an agreement
 * 		  and add funding to the project.*/

	Select 	ALLOWABLE_FUNDING_LEVEL_CODE
	Into 	l_Allowable_Funding_Level_Code
	From 	pa_project_types_all pt, pa_projects_all p
	Where 	p.project_id=p_project_id
	And 	p.project_type=pt.project_type
	AND	nvl(p.org_id,-99) = nvl(pt.org_id,-99);

	IF (p_task_id IS NULL and l_Allowable_Funding_Level_Code='T')
	   OR (p_task_id IS NOT NULL and l_Allowable_Funding_Level_Code = 'P' and l_Inv_Method_Override_Flag = 'N')    /* Modified for Bug 9087135 */
THEN
		   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
THEN
			pa_interface_utils_pub.map_new_amg_msg
         			( p_old_message_code => 'PA_INVD_FUNDING_LVL'
            			,p_msg_attribute    => 'CHANGE'
            			,p_resize_flag      => 'N'
            			,p_msg_context      => 'FUNDING'
            			,p_attribute1       => ''
            			,p_attribute2       => p_pm_funding_reference
            			,p_attribute3       => ''
            			,p_attribute4       => ''
            			,p_attribute5       => '');
		   END IF;
		   l_RETURN:='N';
	END IF;

/* End of changes for bug 3614374*/


/*added for finplan impact on billing*/
/*pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info (
                                           p_project_id    =>p_project_id,
                                           x_plan_type_id  => l_plan_type_id,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data
                                         );
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
              THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     ELSIF l_return_status = FND_API.G_RET_STS_ERROR
             THEN
                        RAISE FND_API.G_EXC_ERROR;
     END IF;

If l_plan_type_id is not null then
  l_funding_lvl := pa_agreement_utils.check_proj_task_lvl_funding_fp
			(p_project_id => p_project_id
			,p_task_id => p_task_id
			,p_agreement_id => p_agreement_id);
else   commented for bug 2729975*/
  l_funding_lvl := pa_agreement_utils.check_proj_task_lvl_funding
			(p_project_id => p_project_id
			,p_task_id => p_task_id
			,p_agreement_id => p_agreement_id);
/*end if;    commented for bug 2729975*/

IF l_funding_lvl = 'A'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
     		--dbms_output.put_line('1.Invalid Funding level');
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_PROJ_FUND_NO_TASK_TRANS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';

ELSIF l_funding_lvl = 'P'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
     		--dbms_output.put_line('Invalid Funding level PA_BU_PROJECT_ALLOC_ONLY');
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_BU_PROJECT_ALLOC_ONLY'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';

ELSIF l_funding_lvl = 'T'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
     		--dbms_output.put_line('3. Invalid Funding level');
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_BU_TASK_ALLOC_ONLY'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';

ELSIF l_funding_lvl = 'B'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
     		--dbms_output.put_line('4. Invalid Funding level');
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_TASK_FUND_NO_PROJ_TRANS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
END IF;
/*added for finplan impact on billing bug 2729975*/
pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info (
                                           p_project_id    =>p_project_id,
                                           x_plan_type_id  => l_plan_type_id,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data
                                         );
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
              THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     ELSIF l_return_status = FND_API.G_RET_STS_ERROR
             THEN
                        RAISE FND_API.G_EXC_ERROR;
     END IF;

If l_plan_type_id is not null then
  l_funding_lvl := pa_agreement_utils.check_proj_task_lvl_funding_fp
                        (p_project_id => p_project_id
                        ,p_task_id => p_task_id
                        ,p_agreement_id => p_agreement_id);

  IF l_funding_lvl='A' then

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                --dbms_output.put_line('4. Invalid Funding level');
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FP_CHK_FUNDING_LVL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'FUNDING'
                        ,p_attribute1       => ''
                        ,p_attribute2       => p_pm_funding_reference
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
  END IF;
END IF;
/*End of change for fin plan impact on billing*/
 -- Bug 6600563. Call to this API will be made only when
 -- p_calling_context is NULL. please refer to bug for details
IF  p_calling_context IS NULL THEN
-- added to validate the funding amount
  l_valid_fund_amt := pa_agreement_pvt.validate_funding_amt(p_funding_amt	  => p_funding_amt
					,p_agreement_id	  => p_agreement_id
					,p_operation_flag => 'A'
					,p_pm_funding_reference	  => p_pm_funding_reference
					,p_funding_id	  => NULL ) ;
--dbms_output.put_line('INSIDE PVT value of l_valid_funding_amt : =>'|| l_valid_fund_amt);

  IF l_valid_fund_amt in ('Z','M') THEN
	--dbms_output.put_line('INSIDE PVTmessage should popup');
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ALLOC'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       =>  p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN := 'N';
  END IF;
END IF; -- Bug 6600563.

--dbms_output.put_line('Return:'||l_return);

RETURN(l_RETURN);
END check_add_funding_ok;

-- ============================================================================
--
--Name:               check_update_funding_ok
--Type:               Function
--Description:  This function can be used to check IF it is OK to update funding.
--
--Called subprograms:
--			pa_project_utils.update_funding
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
--      10-SEP-2001      Srividya                Modified.
--           Call to check valid project includes project_id also
--           ADded mcb2 code
-- -----------------------------------------------------------------------------

FUNCTION check_update_funding_ok
(p_project_id			IN	NUMBER
 ,p_task_id			IN	NUMBER
 ,p_agreement_id                IN	NUMBER
 ,p_customer_id			IN 	NUMBER
 ,p_pm_funding_reference   	IN 	VARCHAR2
 ,p_funding_id			IN	NUMBER
 ,p_funding_amt			IN	NUMBER
 ,p_project_rate_type           IN      VARCHAR2 default null
 ,p_project_rate_date           IN      DATE     default null
 ,p_project_exchange_rate       IN      NUMBER   default null
 ,p_projfunc_rate_type          IN      VARCHAR2 default null
 ,p_projfunc_rate_date          IN      DATE     default null
 ,p_projfunc_exchange_rate      IN      NUMBER   default null)

RETURN VARCHAR2
IS
-- LOCAL VARIABLES
l_RETURN 	VARCHAR2(1):='Y';
l_check_proj_task_lvl_funding VARCHAR2(1) := Null;
l_valid_fund_amt	VARCHAR2(1):= 'Y';
l_rate_type      VARCHAR2(1) := 'Y';
l_old_message_code VARCHAR2(35);
l_plan_type_id number;
l_return_status varchar2(2000);
l_msg_count number;
l_msg_data varchar2(2000);

l_Enable_Top_Task_Cust_Flag VARCHAR2(1);
l_Exist_Flag VARCHAR2(1);

l_Inv_Method_Override_Flag VARCHAR2(1);  /*Added for Bug 5550709 */

BEGIN
	--dbms_output.put_line('Inside: PA_AGREEMENT_PVT.CHECK_UPDATE_FUNDING_OK');
	--dbms_output.put_line('p_pm_funding_reference: '||nvl(p_pm_funding_reference,'NULL'));
-- VALIDATE THE INCOMING PARAMETERS

--  Check Valid Project

IF pa_agreement_utils.check_budget_type (
               p_funding_id => p_funding_id) = 'N' THEN

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FUNDING_BASELINED'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'FUNDING'
                        ,p_attribute1       => ''
                        ,p_attribute2       => p_pm_funding_reference
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
	 RETURN(l_RETURN);
END IF;

/*For bug 3066711 Changed the message code */

/*Federal*/
IF pa_agreement_utils.check_valid_project
                (p_customer_id => p_customer_id,
                 p_project_id  => p_project_id,
		 p_agreement_id => p_agreement_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_PROJECT_ID'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
	 RETURN(l_RETURN);
END IF;

IF pa_agreement_utils.check_valid_customer
		(p_customer_id => p_customer_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_CUST'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
	 RETURN(l_RETURN);
END IF;

--  Check Valid Task
IF p_task_id IS NOT NULL and p_task_id <> FND_API.G_MISS_NUM THEN
IF pa_agreement_utils.check_valid_task
	(p_project_id => p_project_id
	,p_task_id => p_task_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVALID_TASK'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
        RETURN(l_RETURN);
END IF;
END IF;

-- Following changes are made for FP_M : Top Task customer changes
l_Enable_Top_Task_Cust_Flag := PA_Billing_Pub.Get_Top_Task_Customer_Flag (
					P_Project_ID => P_Project_ID );


/* Added the code for bug 5550709. Task level funding is required if customer at
   top task or invoice method by top task is enabled. */
l_Inv_Method_Override_Flag := PA_Billing_Pub.Get_Inv_Method_Override_Flag (
                                        P_Project_ID => P_Project_ID );

IF p_task_id IS NULL and (l_Enable_Top_Task_Cust_Flag = 'Y' or
l_Inv_Method_Override_Flag = 'Y') THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                --dbms_output.put_line('Invalid Funding level');
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_TASK_LEVEL_FUND_REQD'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'FUNDING'
                        ,p_attribute1       => ''
                        ,p_attribute2       => p_pm_funding_reference
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
        END IF;
        RETURN 'N';
END IF;

-- Check for Top Task Customer existence if l_Enable_Top_Task_Cust_Flag = 'Y'
--
-- If Project is implemented with Top Task Customer enabled then make sure
-- that the funding line's top task is associated to the customer which is same
-- as that of agreement's customer.
-- If not, then raise the error.

IF l_Enable_Top_Task_Cust_Flag = 'Y'
THEN
  begin
    Select 1 into l_Exist_Flag
    From   PA_Tasks
    Where  Project_ID  = P_Project_ID
    AND    Task_ID     = P_Task_ID
    AND    Customer_ID = P_Customer_ID
    AND    Rownum      < 2;
    Exception when no_data_found then
      PA_Interface_Utils_Pub.Map_New_AMG_Msg (
        P_Old_Message_Code => 'PA_INVALID_TASK_CUSTOMER',
	P_Msg_Attribute    => 'CHANGE',
	p_Resize_Flag      => 'N',
	P_Msg_Context      => 'FUNDING',
	P_Attribute1       => '',
	P_Attribute2       => p_pm_funding_reference,
	P_Attribute3       => '',
	P_Attribute4       => '',
	P_Attribute5       => ''
      );
      Return 'N';
  end;
END IF;
-- End of changes made for FP_M : Top Task customer changes

--  Check Funding Level
/*added for finplan impact on billing*/
/*pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info (
                                           p_project_id    =>p_project_id,
                                           x_plan_type_id  => l_plan_type_id,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data
                                         );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
              THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   ELSIF l_return_status = FND_API.G_RET_STS_ERROR
              THEN
                        RAISE FND_API.G_EXC_ERROR;
   END IF;

If l_plan_type_id is not null then
l_check_proj_task_lvl_funding := pa_agreement_utils.check_proj_task_lvl_funding_fp
                        (p_project_id => p_project_id
                        ,p_task_id => p_task_id
                        ,p_agreement_id => p_agreement_id); commented for bug 2729975*/
/*end of change for finplan impact on billing*/
--else
l_check_proj_task_lvl_funding := pa_agreement_utils.check_proj_task_lvl_funding
					(p_project_id => p_project_id
					,p_task_id => p_task_id
					,p_agreement_id => p_agreement_id);
--end if;
IF l_check_proj_task_lvl_funding = 'A'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_PROJ_FUND_NO_TASK_TRANS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
        RETURN(l_RETURN);
ELSIF l_check_proj_task_lvl_funding = 'P'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_BU_PROJECT_ALLOC_ONLY'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
        RETURN(l_RETURN);
ELSIF l_check_proj_task_lvl_funding = 'T'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_BU_TASK_ALLOC_ONLY'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
        RETURN(l_RETURN);
ELSIF l_check_proj_task_lvl_funding = 'B'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_TASK_FUND_NO_PROJ_TRANS'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
        RETURN(l_RETURN);
END IF;

/*Added for bug 2729975*/
pa_fin_plan_utils.Get_Appr_Rev_Plan_Type_Info (
                                           p_project_id    =>p_project_id,
                                           x_plan_type_id  => l_plan_type_id,
                                           x_return_status => l_return_status,
                                           x_msg_count     => l_msg_count,
                                           x_msg_data      => l_msg_data
                                         );
    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
              THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   ELSIF l_return_status = FND_API.G_RET_STS_ERROR
              THEN
                        RAISE FND_API.G_EXC_ERROR;
   END IF;

If l_plan_type_id is not null then
l_check_proj_task_lvl_funding := pa_agreement_utils.check_proj_task_lvl_funding_fp
                        (p_project_id => p_project_id
                        ,p_task_id => p_task_id
                        ,p_agreement_id => p_agreement_id);
  IF l_check_proj_task_lvl_funding='A' THEN

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                pa_interface_utils_pub.map_new_amg_msg
                        ( p_old_message_code => 'PA_FP_CHK_FUNDING_LVL'
                        ,p_msg_attribute    => 'CHANGE'
                        ,p_resize_flag      => 'N'
                        ,p_msg_context      => 'FUNDING'
                        ,p_attribute1       => ''
                        ,p_attribute2       => p_pm_funding_reference
                        ,p_attribute3       => ''
                        ,p_attribute4       => ''
                        ,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
        RETURN(l_RETURN);
  END IF;

END IF;

-- added to validate the funding amount
l_valid_fund_amt := pa_agreement_pvt.validate_funding_amt(p_funding_amt	  => p_funding_amt
					,p_agreement_id	  => p_agreement_id
					,p_operation_flag => 'U'
					,p_pm_funding_reference	  => p_pm_funding_reference
					,p_funding_id	  => p_funding_id) ;
IF l_valid_fund_amt in ('Z','M') THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ALLOC'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       =>  p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN := 'N';
         RETURN(l_RETURN);
END IF;
/* commented as check is covered in the previous loop
ELSIF l_valid_fund_amt = 'M' THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ALLOC'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
         RETURN(l_RETURN);
END IF;
-- commented as check is covered in the previous loop
*/
-- END IF;

--added to validate the funding amount
--dbms_output.put_line('Check_update_funding_ok returning:'||l_return);
RETURN(l_RETURN);

END check_update_funding_ok;


-- ============================================================================
--
--Name:               check_delete_funding_ok
--Type:               Function
--Description:  This function can be used to delete funding.
--
--Called subprograms:
--			pa_project_utils.delete_funding
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------

FUNCTION check_delete_funding_ok
(p_agreement_id			IN	NUMBER
,p_funding_id			IN	NUMBER
,p_pm_funding_reference		IN 	VARCHAR2)
RETURN VARCHAR2
IS
-- LOCAL VARIABLES
l_RETURN 		VARCHAR2(1):='Y';
l_valid_fund_amt 	VARCHAR2(1):='Y';
l_funding_amt		NUMBER := 0;
BEGIN
	--dbms_output.put_line('Inside" PA_AGREEMENT_PVT.CHECK_DELETE_FUNDING_OK');

--  Check Budget Type
	--dbms_output.put_line('Calling: pa_agreement_utils.check_budget_type');
IF pa_agreement_utils.check_budget_type
	(p_funding_id => p_funding_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_INVD_BDGT_TYP_CODE'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'Y'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
END IF;

	--dbms_output.put_line('Calling: pa_agreement_utils.check_revenue_limit');
IF pa_agreement_utils.check_revenue_limit
	(p_agreement_id => p_agreement_id) = 'N'
THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
         		( p_old_message_code => 'PA_INVALID_REVENUE_LIMIT'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'Y'
            		,p_msg_context      => 'FUNDING'
            		,p_attribute1       => ''
            		,p_attribute2       => p_pm_funding_reference
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
        END IF;
        l_RETURN:='N';
END IF;
-- added to validate the funding amount
IF p_funding_id IS NOT NULL THEN
 SELECT f.allocated_amount
 INTO l_funding_amt
 FROM pa_project_fundings f
 WHERE f.project_funding_id = p_funding_id;
ELSIF p_pm_funding_reference IS NULL THEN
 SELECT f.allocated_amount
 INTO l_funding_amt
 FROM pa_project_fundings f
 WHERE f.pm_funding_reference = p_pm_funding_reference
 AND f.agreement_id = p_agreement_id;
END IF;
l_valid_fund_amt := pa_agreement_pvt.validate_funding_amt(p_funding_amt	  => l_funding_amt
					,p_agreement_id	  => p_agreement_id
					,p_operation_flag => 'D'
					,p_pm_funding_reference	  => p_pm_funding_reference
					,p_funding_id	  => p_funding_id ) ;
IF l_valid_fund_amt = 'Z' THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ALLOC'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN := 'N';
ELSIF l_valid_fund_amt = 'M' THEN
	IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
     	THEN
        	pa_interface_utils_pub.map_new_amg_msg
           		( p_old_message_code => 'PA_INVD_FUND_ALLOC'
            		,p_msg_attribute    => 'CHANGE'
            		,p_resize_flag      => 'N'
            		,p_msg_context      => 'AGREEMENT'
            		,p_attribute1       =>  p_pm_funding_reference
            		,p_attribute2       => ''
            		,p_attribute3       => ''
            		,p_attribute4       => ''
            		,p_attribute5       => '');
         END IF;
         l_RETURN:='N';
END IF;

-- END IF;

--added to validate the funding amount

RETURN(l_RETURN);

END check_delete_funding_ok;


-- ============================================================================
--
--Name:               validate_flex_fields
--Type:               Procedure
--Description:  This procedure can be used to validate flexfields.
--
--Called subprograms:
--			None
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------
PROCEDURE validate_flex_fields(
                  p_desc_flex_name        IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute_category    IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute1            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute2            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute3            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute4            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute5            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute6            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute7            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute8            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute9            IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute10           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute11           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute12           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute13           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute14           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute15           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute16           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute17           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute18           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute19           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute20           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute21           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute22           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute23           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute24           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_attribute25           IN     VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
                 ,p_RETURN_msg            OUT NOCOPY VARCHAR2  /*file.sql.39*/
                 ,p_validate_status       OUT NOCOPY VARCHAR2  /*file.sql.39*/)
IS
        l_dummy VARCHAR2(1);
        l_r VARCHAR2(2000);
BEGIN

        -- DEFINE ID COLUMNS
        fnd_flex_descval.set_context_value(p_attribute_category);
        fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1);
        fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2);
        fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3);
        fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4);
        fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5);
        fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6);
        fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7);
        fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8);
        fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9);
        fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10);
        fnd_flex_descval.set_column_value('ATTRIBUTE11', p_attribute11);
        fnd_flex_descval.set_column_value('ATTRIBUTE12', p_attribute12);
        fnd_flex_descval.set_column_value('ATTRIBUTE13', p_attribute13);
        fnd_flex_descval.set_column_value('ATTRIBUTE14', p_attribute14);
        fnd_flex_descval.set_column_value('ATTRIBUTE15', p_attribute15);
        fnd_flex_descval.set_column_value('ATTRIBUTE16', p_attribute16);
        fnd_flex_descval.set_column_value('ATTRIBUTE17', p_attribute17);
        fnd_flex_descval.set_column_value('ATTRIBUTE18', p_attribute18);
        fnd_flex_descval.set_column_value('ATTRIBUTE19', p_attribute19);
        fnd_flex_descval.set_column_value('ATTRIBUTE20', p_attribute20);
        fnd_flex_descval.set_column_value('ATTRIBUTE21', p_attribute21);
        fnd_flex_descval.set_column_value('ATTRIBUTE22', p_attribute22);
        fnd_flex_descval.set_column_value('ATTRIBUTE23', p_attribute23);
        fnd_flex_descval.set_column_value('ATTRIBUTE24', p_attribute24);
        fnd_flex_descval.set_column_value('ATTRIBUTE25', p_attribute25);

        -- VALIDATE
        IF (fnd_flex_descval.validate_desccols( 'PA',p_desc_flex_name)) then
              p_RETURN_msg := 'VALID: ' || fnd_flex_descval.concatenated_ids;
              p_validate_status := 'Y';
        ELSE
              p_RETURN_msg := 'INVALID: ' || fnd_flex_descval.error_message;
              p_validate_status := 'N';
        END IF;
END validate_flex_fields;


-- ============================================================================
--
--Name:               	check_yes_no
--Type:              	function
--Description:  	This function will return 'Y' if the value passed is 'Y' or 'N' else return 'N'.
--
--Called subprograms:
--			None
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------
FUNCTION check_yes_no
(p_val VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
	IF p_val in ('Y','N','y','n')
	THEN
	RETURN 'Y';
	ELSE
	RETURN 'N';
	END IF;
END check_yes_no;

-- ============================================================================
--
--Name:               	check_add_update
--Type:              	function
--Description:  	This function will return 'U' if the funding reference
--			passed into it already exists else returns 'A' if the
--			funding reference does not exist.
--
--Called subprograms:
--			None
--
--
--History:
--      25-MAR-2000      Rakesh Raghavan         Created.
-- -----------------------------------------------------------------------------
FUNCTION check_add_update
(p_funding_reference VARCHAR2)
RETURN VARCHAR2
IS
CURSOR C1 is
Select 1 from pa_project_fundings
where pm_funding_reference = p_funding_reference;

l_temp NUMBER;

BEGIN
        --dbms_output.put_line('Inside: PA_AGREEMENT_PVT.CHECK_ADD_UPDATE');
        --dbms_output.put_line('p_funding_reference: '||nvl(p_funding_reference,'NULL'));
	OPEN C1;
	FETCH C1 into l_temp;
	IF C1%FOUND
	THEN
	--dbms_output.put_line('Returning: U');
	RETURN 'U';
	ELSE
	--dbms_output.put_line('Returning: A');
	RETURN 'A';
	END IF;
	CLOSE C1;
END check_add_update;


-- ============================================================================
--
--Name:               	Validate_funding_amt
--Type:              	function
--Description:  	This function will return 'Y' if the funding amonut is
--			valid otherwise it will return 'Z' or 'M' or 'N'.
--			'Y'=> Valid Value for the allocated amount
--			'Z'=> Invalid Value (Total Allocated Amount is less than zero)
--			'M'=> Invalid Value (Total Allocated Amount is more that agreement amount)
--			Funding amount will be considered valid If the sum of all the fundings are not
--			negative and it is less that the agreenment amount
--
--Called subprograms:
--			None
--
--
--History:
--      30-Sep-2000      Nikhil Mishra         Created.
-- -----------------------------------------------------------------------------
FUNCTION validate_funding_amt
(p_funding_amt	NUMBER
,p_agreement_id	NUMBER
,p_operation_flag VARCHAR2
,p_funding_id NUMBER
,p_pm_funding_reference	 VARCHAR2)
RETURN VARCHAR2
IS
-- LOCAL VARIABLES
l_RETURN 	VARCHAR2(1):='Y';
l_fun_sum	NUMBER := 0;
l_fun_amt	NUMBER := 0;
l_agr_amt	NUMBER := 0;

BEGIN
--dbms_output.put_line('INSIDE: => validate_funding_amt');
IF p_funding_id IS NOT NULL THEN
--dbms_output.put_line('INSIDE: => validate_funding_amt => Funding id is '|| to_char(p_funding_id));
	SELECT nvl(f.allocated_amount,0)
	INTO l_fun_amt
	FROM pa_project_fundings f
	WHERE f.project_funding_id = p_funding_id;
END IF;

/*Federal*/
SELECT decode(a.advance_required,'Y',nvl(a.advance_amount,0),nvl(a.amount,0))
INTO l_agr_amt
FROM pa_agreements_all a
WHERE a.agreement_id = p_agreement_id;
--dbms_output.put_line('INSIDE: => validate_funding_amt => Total Agreement Amt is '|| to_char(l_agr_amt));

SELECT nvl(SUM(f.allocated_amount),0)
INTO l_fun_sum
FROM pa_project_fundings f
WHERE f.agreement_id = p_agreement_id;

--dbms_output.put_line('INSIDE: => validate_funding_amt => Total Funding Amt is '|| to_char(l_fun_sum));

IF p_operation_flag = 'A' THEN
	l_fun_sum := l_fun_sum + p_funding_amt;
--dbms_output.put_line('INSIDE: => this is an add operation amount is '|| to_char(l_fun_sum));
ELSIF p_operation_flag = 'U' THEN
	l_fun_sum := l_fun_sum + p_funding_amt - l_fun_amt ;
ELSIF p_operation_flag = 'D' THEN
	l_fun_sum := l_fun_sum - l_fun_amt;
END IF;

IF l_fun_sum < 0
THEN
--dbms_output.put_line('INSIDE: => less than zero');
l_RETURN := 'Z';
ELSIF l_fun_sum  > l_agr_amt
THEN 	l_RETURN :=  'M';
ELSIF l_fun_sum  < l_agr_amt
AND l_fun_sum >= 0
THEN 	l_RETURN := 'Y';
END IF;
--dbms_output.put_line('INSIDE: => returning ' || l_RETURN);
RETURN (l_RETURN);

--dbms_output.put_line('INSIDE: => Thats all');

EXCEPTION
WHEN OTHERS THEN
--dbms_output.put_line('INSIDE: => WHEN OTHERS');
RETURN 'N';

END validate_funding_amt;

END PA_AGREEMENT_PVT;

/
