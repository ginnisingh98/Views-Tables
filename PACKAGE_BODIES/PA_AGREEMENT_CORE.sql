--------------------------------------------------------
--  DDL for Package Body PA_AGREEMENT_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_AGREEMENT_CORE" as
/*$Header: PAAFAGCB.pls 120.4 2007/02/07 10:45:25 rgandhi ship $*/

/*============================================================================+
| Name              : check_multi_customers
| Type              : FUNCTION
| Description       : This function will return 'Y' IF the Project has
|                     Multiple-Customers
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

FUNCTION check_multi_customers
( p_project_id		                IN	NUMBER
 ) RETURN VARCHAR2
IS
     multi_flag varchar2(1);
  BEGIN
     SELECT 'Y' into multi_flag
     FROM  PA_PROJECT_CUSTOMERS
     WHERE PROJECT_ID = p_project_id
     AND   CUSTOMER_BILL_SPLIT NOT IN (100, 0)
     HAVING COUNT(CUSTOMER_ID) > 1;

     IF (multi_flag = 'Y') THEN
        return 'Y';
     ELSE
        return 'N';
     END  IF;

  exception
     when NO_DATA_FOUND THEN return 'N';
     when OTHERS THEN        return 'N';
END  check_multi_customers;


/*============================================================================+
| Name              : check_contribution
| Type              : FUNCTION
| Description       : This function will return null
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

FUNCTION check_contribution
( p_agreement_id			IN	NUMBER
 ) return varchar2
IS
BEGIN
return null;
END  check_contribution;


/*============================================================================+
| Name              : check_valid_customer
| Type              : FUNCTION
| Description       : This function will return various  values.
|                     "N" -  user is not a registered employee and he is not
|                     allowed to create agreement.
|                     Message is PA_ALL_WARN_NO_EMPL_REC
|                     "Y" - Valid
| Called subprograms: PA_UTILS.GetEmpIdFromUser
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

	FUNCTION check_valid_customer
	(  p_customer_id 		IN 	NUMBER
 	)  RETURN VARCHAR2
is
cust_exists number;
  BEGIN
  	-- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.CHECK_VALID_CUSTOMER');
	-- dbms_output.put_line('Customer_id: '||nvl(to_char(p_customer_id),'NULL'));
	-- Ensure that user is a registered EMPLOYEE.
       IF PA_UTILS.GetEmpIdFromUser(to_number(fnd_profile.value('USER_ID')))
                IS NULL THEN
	RETURN 'N';
       --  fnd_message.set_name ('PA', 'PA_ALL_WARN_NO_EMPL_REC');
       ELSE
        select 1 into cust_exists from dual where exists (
                Select customer_name, customer_id, customer_number
                from pa_customers_v where status = 'A' and
                customer_id = p_customer_id);
	  IF cust_exists = 1
	  THEN RETURN 'Y';
	  END  IF;
       END  IF;
  EXCEPTION
        when Others THEN return 'N';
  END  Check_valid_customer;


/*============================================================================+
| Name              : check_valid_type
| Type              : FUNCTION
| Description       : This function will return 'Y' IF the agreement type is
|                     valid else N
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

	FUNCTION check_valid_type
	(  p_agreement_type       IN 	VARCHAR2
 	) RETURN VARCHAR2 is
  type_exists number;
  BEGIN
        Select 1 into type_exists
        From Dual
        Where Exists (
                select  0
                from    pa_agreement_types atp, ra_terms rt
                where   atp.term_id = rt.term_id(+)
                and     trunc(sysdate) between trunc(atp.start_date_active)
                and     trunc(nvl(atp.end_date_active,sysdate))
    		and     atp.agreement_type = p_agreement_type);
	IF type_exists = 1
	THEN RETURN 'Y';
	END  IF;

  EXCEPTION
        When Others THEN RETURN 'N';
  END  Check_valid_type;

--
--Name:                 check_invoice_exists
--Type:                 Function
--Description:          Will return Y IF invoices exists for given agreement ELSE return N
--Called subprograms:None
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--

/*============================================================================+
| Name              : check_invoice_exists
| Type              : FUNCTION
| Description       : This function will return 'Y' IF invoices exists ELSE N
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

	FUNCTION check_invoice_exists
	( p_agreement_id        		IN 	NUMBER
 	) RETURN VARCHAR2
	IS
          invoice_exists number;
        BEGIN
          select 1 into invoice_exists
          from pa_draft_invoices_all
          where agreement_id = p_agreement_id
          and rownum=1;

          IF invoice_exists = 1 THEN
          RETURN 'Y';
          END  IF;

        exception
          when OTHERS THEN RETURN 'N';
        END  Check_invoice_exists;

/*============================================================================+
| Name              : check_valid_term_id
| Type              : FUNCTION
| Description       : This function will return 'Y' IF term id is valid ELSE N
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

FUNCTION check_valid_term_id
(p_term_id        		IN 	NUMBER
 ) RETURN VARCHAR2
IS
term_exists number;
  BEGIN
        Select 1
	into Term_exists
	From Dual
	Where Exists (
                select 0
                from ra_terms
                where trunc(sysdate) between start_date_active
                and nvl(end_date_active, trunc(sysdate))
    		and term_id = p_term_id);

	IF Term_Exists = 1
	THEN RETURN 'Y';
	END  IF;
  EXCEPTION
        When Others THEN RETURN 'N';
  END  Check_valid_term_id;

/*============================================================================+
| Name              : check_valid_owned_by_person_id
| Type              : FUNCTION
| Description       : This function will return 'Y' IF person_id is valid ELSE N
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

	FUNCTION check_valid_owned_by_person_id
	( p_owned_by_person_id        		IN 	NUMBER
 	) RETURN VARCHAR2
IS
  person_id_exists number;
  BEGIN
        select 1 into Person_Id_Exists
	from Dual Where Exists (
        select 0 from pa_employees
	where  person_id = p_owned_by_person_id);
	IF Person_Id_Exists = 1
	THEN RETURN 'Y';
	END  IF;

  EXCEPTION
        When Others THEN RETURN 'N';
  END  Check_valid_owned_by_person_id;


/*============================================================================+
| Name              : check_unique_agreement
| Type              : FUNCTION
| Description       : This function will return 'Y' IF the combination of
|                     Agreement_Number, Agreement_type, Customer is unique
|                     ELSE will return 'N' Message is PA_BU_AGRMNT_NOT_UNIQUE
| Called subprograms: none
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/

	FUNCTION check_unique_agreement
	( p_agreement_num        		IN 	VARCHAR2
 	 ,p_agreement_type                      IN      VARCHAR2
 	 ,p_customer_id                         IN      NUMBER
 	) RETURN VARCHAR2
IS
     not_unique number;

  BEGIN
        select 1 into not_unique
        from pa_agreements p
        where p.customer_id = p_customer_id
        and p.agreement_num = p_agreement_num
        and p.agreement_type = p_agreement_type;

     IF (not_unique = 1) THEN
     RETURN 'N';
     END  IF;

  exception
     when NO_DATA_FOUND THEN RETURN 'Y';
     when OTHERS THEN RETURN 'N';

  END  Check_unique_agreement;

--
--Name:                 check_valid_agreement_ref
--Type:                 Function
--Description:          This function will return 'Y' IF the Agreement_reference
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_agreement_ref
	(p_agreement_reference           	IN	VARCHAR2
	)
RETURN VARCHAR2
IS
CURSOR c IS
SELECT 1
FROM PA_AGREEMENTS_ALL A
WHERE A.pm_agreement_reference = p_agreement_reference;
l_row c%ROWTYPE;
BEGIN
	-- dbms_output.put_line('PA_AGREEMENT_CORE.CHECK_VALID_AGREEMENT_REF');
	OPEN C;
	FETCH C INTO l_row;
	IF C%FOUND THEN
	RETURN 'Y';
	ELSE
	RETURN 'N';
	END IF;
	CLOSE C;
END check_valid_agreement_ref;

--
--Name:                 check_valid_agreement_id
--Type:                 Function
--Description:          This function will return 'Y' IF the Agreement_Id
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_agreement_id
	(p_agreement_id           	IN	NUMBER
	)
RETURN VARCHAR2
IS
CURSOR c IS
SELECT 1
FROM PA_AGREEMENTS_ALL A
WHERE A.agreement_id = p_agreement_id;
l_row c%ROWTYPE;
BEGIN
	OPEN C;
	FETCH C INTO l_row;
	IF C%FOUND THEN
	RETURN 'Y';
	ELSE
	RETURN 'N';
	END IF;
	CLOSE C;
END check_valid_agreement_id;


--
--Name:                 check_valid_funding_ref
--Type:                 Function
--Description:          This function will return 'Y' IF the funding_reference
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_funding_ref
	(p_funding_reference           		IN	VARCHAR2
	,p_agreement_id				IN	NUMBER
	)
RETURN VARCHAR2
IS
CURSOR c IS
SELECT 1
FROM PA_PROJECT_FUNDINGS F
WHERE	F.pm_funding_reference = p_funding_reference
AND	F.agreement_id = p_agreement_id ;
l_row c%ROWTYPE;
BEGIN
	-- dbms_output.put_line(' Inside: PA_AGREEMENT_CORE.CHECK_VALID_FUNDING_REF');
	OPEN C;
	FETCH C INTO l_row;
	IF C%FOUND THEN
	RETURN 'Y';
	ELSE
	RETURN 'N';
	END IF;
	CLOSE C;
END check_valid_funding_ref;

--
--Name:                 check_valid_funding_id
--Type:                 Function
--Description:          This function will return 'Y' IF the funding_Id
--			is valid
--                      ELSE will return 'N'
--
--Called subprograms: none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra
--

FUNCTION check_valid_funding_id
	(p_agreement_id           		IN	NUMBER
	,p_funding_id           		IN	NUMBER
	)
RETURN VARCHAR2
IS
CURSOR c IS
SELECT 1
FROM PA_PROJECT_FUNDINGS F
WHERE	F.project_funding_id = p_funding_id
AND	F.agreement_id = p_agreement_id ;
l_row c%ROWTYPE;
BEGIN
	OPEN C;
	FETCH C INTO l_row;
	IF C%FOUND THEN
	RETURN 'Y';
	ELSE
	RETURN 'N';
	END IF;
	CLOSE C;
END check_valid_funding_id;

--
--Name:                 validate_agreement_amount
--Type:                 Function
--Description:          This function will return 'Y' IF the Agreement amount enetered
--			is valid i.e. the amount entered should always be greater than
--			total baselined and unbaselined amount for that agreement_id;
--			IF returning 'N' indicating invalid amount THEN message is
--			PA_BU_AMOUNT_NOT_UPDATEABLE
--
--Called subprograms: none
--
--
--History:
--                      05-MAY-2000     Created         Adwait Marathe.
--


	FUNCTION validate_agreement_amount
	( p_agreement_id       		        IN 	NUMBER
	 ,p_amount				IN	NUMBER
 	) RETURN VARCHAR2
IS
        l_tot_baselined_amt     number;
        l_tot_unbaselined_amt   number;
  BEGIN
                Select  nvl(sum(total_baselined_amount),0),
                        nvl(sum(total_unbaselined_amount),0)
                into    l_tot_baselined_amt,
                        l_tot_unbaselined_amt
                From    Pa_Summary_Project_Fundings
                where   Agreement_id = p_Agreement_id;
        IF (nvl(p_amount, 0) <
            nvl(l_tot_unbaselined_amt, 0) +
            nvl(l_tot_baselined_amt, 0)) THEN
	RETURN 'N';
        END  IF;
        Exception When  No_Data_Found THEN RETURN 'Y';
                        When Others THEN RETURN 'Y';
  END  Validate_agreement_amount;

--
--Name:                 check_add_update
--Type:                 FUNCTION
--Description:          This function will return 'U' if update is required or 'A' if insert is required .
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_add_update
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN VARCHAR2
IS

CURSOR c1
IS
SELECT f.project_funding_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.project_funding_id = p_funding_id;

CURSOR c2
IS
SELECT f.project_funding_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_funding_reference;

l_fund_rec1 c1%ROWTYPE;
l_fund_rec2 c2%ROWTYPE;

BEGIN
	IF p_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN
		OPEN c1;
		FETCH c1 INTO l_fund_rec1;
		IF c1%FOUND THEN
			RETURN 'U';
		ELSE
			RETURN 'A';
		END IF;
		CLOSE c1;
	ELSIF p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
		OPEN c2;
		FETCH c2 INTO l_fund_rec2;
		IF c2%FOUND THEN
			RETURN 'U';
		ELSE
			RETURN 'A';
		END IF;
		CLOSE c2;
	END IF;

END check_add_update;

--
--Name:                 get_agreement_id
--Type:                 FUNCTION
--Description:          This procedure will get the corresponding agreement_id for the funding_id or funding _reference given
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_agreement_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

CURSOR c1
IS
SELECT f.agreement_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.project_funding_id = p_funding_id;

CURSOR c2
IS
SELECT f.agreement_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_funding_reference;

l_fund_rec1 c1%ROWTYPE;
l_fund_rec2 c2%ROWTYPE;
--Nikhil changed c1 to c2 and c2 to c1
BEGIN
	-- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.GET_AGREEMENT_ID');
	 -- dbms_output.put_line('p_funding_id = '||nvl(to_char(p_funding_id),'NULL'));
	 -- dbms_output.put_line('p_funding_reference ='||nvl(p_funding_reference,'NULL'));
	IF p_funding_reference is NOT NULL
--	   OR (p_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
	THEN
		 -- dbms_output.put_line('Funding Id is available: '||nvl(to_char(p_funding_id),'NULL'));
		OPEN c2;
		FETCH c2 INTO l_fund_rec2;
		IF c2%FOUND THEN
		-- dbms_output.put_line('Returning'||nvl(to_char(l_fund_rec2.agreement_id),'NULL'));
		RETURN  l_fund_rec2.agreement_id;
		ELSE
		-- dbms_output.put_line('NO VALUES WHY???');
                NULL;               -- Fix bug#1581381
		END IF;
		CLOSE c2;
	ELSIF p_funding_id is NOT NULL
--	      OR (p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
	THEN
	-- dbms_output.put_line('Funding ref is available: '||nvl(p_funding_reference,'NULL'));
		OPEN c1;
		FETCH c1 INTO l_fund_rec1;
		IF c1%FOUND THEN
		-- dbms_output.put_line('Returning'||nvl(to_char(l_fund_rec1.agreement_id),'NULL'));
		RETURN  l_fund_rec1.agreement_id;
		END IF;
		CLOSE c2;
	END IF;
/*		-- dbms_output.put_line('Returning'||'RAJ');
exception
when others then
 -- dbms_output.put_line(SQLERRM);
 */
END get_agreement_id;


--
--Name:                 get_project_id
--Type:                 FUNCTION
--Description:          This procedure will get the corresponding project_id for the funding_id or funding _reference given
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_project_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

CURSOR c1
IS
SELECT f.project_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.project_funding_id = p_funding_id;

CURSOR c2
IS
SELECT f.project_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_funding_reference;

l_fund_rec1 c1%ROWTYPE;
l_fund_rec2 c2%ROWTYPE;

-- Nikhil changed c1 to c2

BEGIN
-- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.GET_PROJECT_ID');
	IF p_funding_reference IS NOT NULL
--	   OR p_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
	THEN
		OPEN c2;
		FETCH c2 INTO l_fund_rec2;
		IF c2%FOUND THEN
		RETURN  l_fund_rec2.project_id;
		END IF;
		CLOSE c2;
	 ELSIF p_funding_id is NOT NULL
--	       OR p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	 THEN
		OPEN c1;
		FETCH c1 INTO l_fund_rec1;
		IF c1%FOUND THEN
		RETURN  l_fund_rec1.project_id;
		END IF;
		CLOSE c1;
	END IF;

END get_project_id;


--
--Name:                 get_task_id
--Type:                 FUNCTION
--Description:          This function will get the corresponding task_id for the funding_id or funding _reference given
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION get_task_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

CURSOR c1
IS
SELECT f.task_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.project_funding_id = p_funding_id;

CURSOR c2
IS
SELECT f.task_id
FROM PA_PROJECT_FUNDINGS f
WHERE f.pm_funding_reference = p_funding_reference;

l_fund_rec1 c1%ROWTYPE;
l_fund_rec2 c2%ROWTYPE;

BEGIN
	-- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.GET_TASK_ID');
	IF p_funding_reference IS NOT NULL
--	   OR p_funding_reference = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
	THEN
		OPEN c2;
		FETCH c2 INTO l_fund_rec2;
		IF c2%FOUND THEN
		RETURN  l_fund_rec2.task_id;
		END IF;
		CLOSE c2;
	ELSIF p_funding_id IS NOT NULL
--	      OR p_funding_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
	THEN
		OPEN c1;
		FETCH c1 INTO l_fund_rec1;
		IF c1%FOUND THEN
		RETURN  l_fund_rec1.task_id;
		END IF;
		CLOSE c1;
	END IF;

END get_task_id;

--
--Name:                 get_customer_id
--Type:                 FUNCTION
--Description:          This procedure will get the corresponding customer_id for the funding_id or funding_reference given
--
--Called subprograms:   none
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--


FUNCTION get_customer_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	)
RETURN NUMBER
IS

CURSOR c1
IS
SELECT A.customer_id
FROM PA_AGREEMENTS_ALL A
WHERE A.agreement_id  = (SELECT f.agreement_id
			FROM PA_PROJECT_FUNDINGS f
			WHERE f.project_funding_id = p_funding_id);

CURSOR c2
IS
SELECT A.customer_id
FROM PA_AGREEMENTS_ALL A
WHERE A.agreement_id  = (SELECT f.agreement_id
			FROM PA_PROJECT_FUNDINGS f
			WHERE f.pm_funding_reference = p_funding_reference);

l_fund_rec1 c1%ROWTYPE;
l_fund_rec2 c2%ROWTYPE;

BEGIN
/** Giving higher precedence to funding_id over funding_reference to determine customer_id bug 2434153 **/
	-- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.GET_CUSTOMER_ID');
	IF p_funding_id IS NOT NULL
	      AND (p_funding_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
	THEN
		OPEN c1;
		FETCH c1 INTO l_fund_rec1;
		IF c1%FOUND THEN
		-- dbms_output.put_line('Returning Customer Id: '||nvl(to_char(l_fund_rec1.customer_id),'NULL'));
		RETURN  l_fund_rec1.customer_id;
		END IF;
		CLOSE c1;
	ELSIF p_funding_reference IS NOT NULL
	   AND (p_funding_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)
        THEN
		OPEN c2;
		FETCH c2 INTO l_fund_rec2;
		IF c2%FOUND THEN
		-- dbms_output.put_line('Returning Customer Id: '||nvl(to_char(l_fund_rec2.customer_id),'NULL'));
		RETURN  l_fund_rec2.customer_id;
		END IF;
		CLOSE c2;
	END IF;

END get_customer_id;


/*============================================================================+
| Name              : create_agreement
| Type              : PROCEDURE
| Description       : This procedure will insert one row in to PA_AGREEMENTS_ALL
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
|    07-SEP-2001     Modified        Srividya
|      Added all new columns used in MCB2
+============================================================================*/
 PROCEDURE create_agreement(
	   p_Rowid                   IN OUT NOCOPY VARCHAR2,/*File.sql.39*/
           p_Agreement_Id                   IN OUT NOCOPY NUMBER,/*File.sql.39*/
           p_Customer_Id                    IN NUMBER,
           p_Agreement_Num                  IN VARCHAR2,
           p_Agreement_Type                 IN VARCHAR2,
           p_Last_Update_Date               IN DATE,
           p_Last_Updated_By                IN NUMBER,
           p_Creation_Date                  IN DATE,
           p_Created_By                     IN NUMBER,
           p_Last_Update_Login              IN NUMBER,
           p_Owned_By_Person_Id             IN NUMBER,
           p_Term_Id                        IN NUMBER,
           p_Revenue_Limit_Flag             IN VARCHAR2,
           p_Amount                         IN NUMBER,
           p_Description                    IN VARCHAR2,
           p_Expiration_Date                IN DATE,
           p_Attribute_Category             IN VARCHAR2,
           p_Attribute1                     IN VARCHAR2,
           p_Attribute2                     IN VARCHAR2,
           p_Attribute3                     IN VARCHAR2,
           p_Attribute4                     IN VARCHAR2,
           p_Attribute5                     IN VARCHAR2,
           p_Attribute6                     IN VARCHAR2,
           p_Attribute7                     IN VARCHAR2,
           p_Attribute8                     IN VARCHAR2,
           p_Attribute9                     IN VARCHAR2,
           p_Attribute10                    IN VARCHAR2,
           p_Template_Flag                  IN VARCHAR2,
           p_pm_agreement_reference         IN VARCHAR2,
           p_pm_product_code         	    IN VARCHAR2,
	   p_agreement_currency_code	    IN VARCHAR2 DEFAULT NULL,
	   p_owning_organization_id	    IN NUMBER	DEFAULT NULL,
	   p_invoice_limit_flag		    IN VARCHAR2 DEFAULT NULL,
/*Federal*/
           p_customer_order_number          IN VARCHAR2 DEFAULT NULL,
           p_advance_required               IN VARCHAR2 DEFAULT NULL,
           p_start_date                     IN DATE     DEFAULT NULL,
           p_billing_sequence               IN NUMBER   DEFAULT NULL,
           p_line_of_account                IN VARCHAR2 DEFAULT NULL,
           p_Attribute11                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute12                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute13                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute14                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute15                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute16                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute17                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute18                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute19                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute20                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute21                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute22                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute23                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute24                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute25                    IN VARCHAR2 DEFAULT NULL
                      )
  is

	l_agreement_currency_code	VARCHAR2(30);
	l_invoice_limit_flag		VARCHAR2(1);
	l_org_id                        Number; /* Shared Services*/
  BEGIN
   -- dbms_output.put_line('In CORE - create_agreement');
      if p_agreement_currency_code is null then
	 l_agreement_currency_code := pa_currency.get_currency_code;
      else
	 l_agreement_currency_code := p_agreement_currency_code;
      end if;
      if p_invoice_limit_flag is null then
	 l_invoice_limit_flag := p_revenue_limit_flag;
      else
	 l_invoice_limit_flag := p_invoice_limit_flag;
      end if;

     /* Shared Services. Checking get_current_org_id has value*/
      l_org_id := mo_global.get_current_org_id;

      if l_org_id is null then
       raise no_data_found;
      end if;
     /* End of change for Shared Services*/

    pa_agreements_pkg.insert_row(
	x_rowid				=>	 p_rowid,
	x_agreement_id			=>	 p_agreement_id,
	x_customer_id			=>	 p_customer_id,
	x_agreement_num			=>	 p_agreement_num,
	x_agreement_type		=>	 p_agreement_type,
	x_last_update_date		=>	 p_last_update_date,
	x_last_updated_by		=>	 p_last_updated_by,
	x_creation_date			=>	 p_creation_date,
	x_created_by			=>	 p_created_by,
	x_last_update_login		=>	 p_last_update_login,
	x_owned_by_person_id		=>	 p_owned_by_person_id,
	x_term_id			=>	 p_term_id,
	x_revenue_limit_flag		=>	 p_revenue_limit_flag,
	x_amount			=>	 p_amount,
	x_description			=>	 p_description,
	x_expiration_date		=>	 p_expiration_date,
	x_attribute_category		=>	 p_attribute_category,
	x_attribute1			=>	 p_attribute1,
	x_attribute2			=>	 p_attribute2,
	x_attribute3			=>	 p_attribute3,
	x_attribute4			=>	 p_attribute4,
	x_attribute5			=>	 p_attribute5,
	x_attribute6			=>	 p_attribute6,
	x_attribute7			=>	 p_attribute7,
	x_attribute8			=>	 p_attribute8,
	x_attribute9			=>	 p_attribute9,
	x_attribute10			=>	 p_attribute10,
	x_template_flag			=>	 p_template_flag,
	x_pm_agreement_reference	=>	 p_pm_agreement_reference,
	x_pm_product_code		=>	 p_pm_product_code,
	x_owning_organization_id	=>	 p_owning_organization_id,
	x_agreement_currency_code	=>	 l_agreement_currency_code,
	x_invoice_limit_flag		=>	 l_invoice_limit_flag,
	x_org_id                        =>       l_org_id,
/*Federal*/
        x_customer_order_number         =>       p_customer_order_number,
        x_advance_required              =>       p_advance_required,
        x_start_date                    =>       p_start_date,
        x_billing_sequence              =>       p_billing_sequence,
        x_line_of_account               =>       p_line_of_account,
        x_attribute11                   =>       p_attribute11,
        x_attribute12                   =>       p_attribute12,
        x_attribute13                   =>       p_attribute13,
        x_attribute14                   =>       p_attribute14,
        x_attribute15                   =>       p_attribute15,
        x_attribute16                   =>       p_attribute16,
        x_attribute17                   =>       p_attribute17,
        x_attribute18                   =>       p_attribute18,
        x_attribute19                   =>       p_attribute19,
        x_attribute20                   =>       p_attribute20,
        x_attribute21                   =>       p_attribute21,
        x_attribute22                   =>       p_attribute22,
        x_attribute23                   =>       p_attribute23,
        x_attribute24                   =>       p_attribute24,
        x_attribute25                   =>       p_attribute25);/* Shared Services*/

  /* Added Below for File.sql.39*/
  EXCEPTION
    WHEN OTHERS THEN
       p_rowid := NULL;
       raise;
  END  Create_agreement;

/*============================================================================+
| Name              : update_agreement
| Type              : PROCEDURE
| Description       : This procedure will update one row in to PA_AGREEMENTS_ALL
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
|    07-SEP-2001     Modified        Srividya
|      Added all new columns used in MCB2
+============================================================================*/
  PROCEDURE update_agreement(
           p_Agreement_Id		IN 	NUMBER,
           p_Customer_Id		IN	NUMBER,
           p_Agreement_Num		IN	VARCHAR2,
           p_Agreement_Type		IN	VARCHAR2,
           p_Last_Update_Date		IN	DATE,
           p_Last_Updated_By		IN	NUMBER,
           p_Last_Update_Login		IN	NUMBER,
           p_Owned_By_Person_Id		IN	NUMBER,
           p_Term_Id			IN	NUMBER,
           p_Revenue_Limit_Flag		IN	VARCHAR2,
           p_Amount			IN	NUMBER,
           p_Description		IN	VARCHAR2,
           p_Expiration_Date		IN	DATE,
           p_Attribute_Category		IN	VARCHAR2,
           p_Attribute1			IN	VARCHAR2,
           p_Attribute2			IN	VARCHAR2,
           p_Attribute3			IN	VARCHAR2,
           p_Attribute4			IN	VARCHAR2,
           p_Attribute5			IN	VARCHAR2,
           p_Attribute6			IN	VARCHAR2,
           p_Attribute7			IN	VARCHAR2,
           p_Attribute8			IN	VARCHAR2,
           p_Attribute9			IN	VARCHAR2,
           p_Attribute10		IN	VARCHAR2,
           p_Template_Flag		IN	VARCHAR2,
           p_pm_agreement_reference	IN	VARCHAR2,
           p_pm_product_code		IN	VARCHAR2,
	   p_agreement_currency_code	IN	VARCHAR2 DEFAULT NULL,
	   p_owning_organization_id	IN	NUMBER	DEFAULT NULL,
	   p_invoice_limit_flag		IN	VARCHAR2 DEFAULT NULL,
/*Federal*/
           p_customer_order_number          IN VARCHAR2 DEFAULT NULL,
           p_advance_required               IN VARCHAR2 DEFAULT NULL,
           p_start_date                     IN DATE     DEFAULT NULL,
           p_billing_sequence               IN NUMBER   DEFAULT NULL,
           p_line_of_account                IN VARCHAR2 DEFAULT NULL,
           p_Attribute11                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute12                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute13                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute14                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute15                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute16                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute17                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute18                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute19                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute20                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute21                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute22                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute23                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute24                    IN VARCHAR2 DEFAULT NULL,
           p_Attribute25                    IN VARCHAR2 DEFAULT NULL)
  is
     CURSOR C IS
      SELECT rowid,agreement_currency_code,
	     owning_organization_id, invoice_limit_flag
      FROM PA_AGREEMENTS_ALL
      WHERE agreement_id = p_agreement_id;
      agr_rec C%ROWTYPE;

      l_agreement_currency_code	VARCHAR2(30);
      l_invoice_limit_flag	VARCHAR2(1);
      l_owning_organization_id	NUMBER;

 BEGIN
 	-- dbms_output.put_line('Calling: pa_agreement_core.update_agreement');
      OPEN C;
      FETCH C INTO agr_rec;
      IF C%FOUND THEN
	 IF p_agreement_currency_code is null then
	    l_agreement_currency_code := agr_rec.agreement_currency_code;
	 else
	    l_agreement_currency_code := p_agreement_currency_code;
	 end if;
	 if p_invoice_limit_flag is null then
	    l_invoice_limit_flag := agr_rec.invoice_limit_flag;
	 else
	    l_invoice_limit_flag := p_invoice_limit_flag;
	 end if;

        pa_agreements_pkg.update_row(
	x_rowid				=>	 agr_rec.rowid,
	x_agreement_id			=>	 p_agreement_id,
	x_customer_id			=>	 p_customer_id,
	x_agreement_num			=>	 p_agreement_num,
	x_agreement_type		=>	 p_agreement_type,
	x_last_update_date		=>	 p_last_update_date,
	x_last_updated_by		=>	 p_last_updated_by,
	x_last_update_login		=>	 p_last_update_login,
	x_owned_by_person_id		=>	 p_owned_by_person_id,
	x_term_id			=>	 p_term_id,
	x_revenue_limit_flag		=>	 p_revenue_limit_flag,
	x_amount			=>	 p_amount,
	x_description			=>	 p_description,
	x_expiration_date		=>	 p_expiration_date,
	x_attribute_category		=>	 p_attribute_category,
	x_attribute1			=>	 p_attribute1,
	x_attribute2			=>	 p_attribute2,
	x_attribute3			=>	 p_attribute3,
	x_attribute4			=>	 p_attribute4,
	x_attribute5			=>	 p_attribute5,
	x_attribute6			=>	 p_attribute6,
	x_attribute7			=>	 p_attribute7,
	x_attribute8			=>	 p_attribute8,
	x_attribute9			=>	 p_attribute9,
	x_attribute10			=>	 p_attribute10,
	x_template_flag			=>	 p_template_flag,
	x_pm_agreement_reference	=>	 p_pm_agreement_reference,
	x_pm_product_code		=>	 p_pm_product_code,
	x_owning_organization_id	=>	 p_owning_organization_id,
	x_agreement_currency_code	=>	 l_agreement_currency_code,
	x_invoice_limit_flag		=>	 l_invoice_limit_flag,
/*Federal*/
        x_customer_order_number         =>       p_customer_order_number,
        x_advance_required              =>       p_advance_required,
        x_start_date                    =>       p_start_date,
        x_billing_sequence              =>       p_billing_sequence,
        x_line_of_account               =>       p_line_of_account,
        x_attribute11                   =>       p_attribute11,
        x_attribute12                   =>       p_attribute12,
        x_attribute13                   =>       p_attribute13,
        x_attribute14                   =>       p_attribute14,
        x_attribute15                   =>       p_attribute15,
        x_attribute16                   =>       p_attribute16,
        x_attribute17                   =>       p_attribute17,
        x_attribute18                   =>       p_attribute18,
        x_attribute19                   =>       p_attribute19,
        x_attribute20                   =>       p_attribute20,
        x_attribute21                   =>       p_attribute21,
        x_attribute22                   =>       p_attribute22,
        x_attribute23                   =>       p_attribute23,
        x_attribute24                   =>       p_attribute24,
        x_attribute25                   =>       p_attribute25);
   END  IF;
   CLOSE C;
  END  update_agreement;

/*============================================================================+
| Name              : delete_agreement
| Type              : PROCEDURE
| Description       : This procedure will delete one row from PA_AGREEMENTS_ALL
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
+============================================================================*/
  procedure delete_agreement(p_agreement_id	IN NUMBER)
  is
      CURSOR C IS
      SELECT rowid
      FROM PA_AGREEMENTS
      WHERE agreement_id = p_agreement_id;
      agr_row_id  VARCHAR2(2000);
  BEGIN
    OPEN C;
      FETCH C INTO agr_row_id;
       IF C%FOUND THEN
          pa_agreements_pkg.delete_row(agr_row_id);
       END  IF;
    CLOSE C;
  END  delete_agreement;


/*============================================================================+
| Name              : lock
| Type              : PROCEDURE
| Description       : This procedure will lock one row in to PA_AGREEMENTS_ALL
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
|    07-SEP-2001     Modified        Srividya
|      Added all new columns used in MCB2
+============================================================================*/

PROCEDURE Lock_agreement(p_Agreement_Id IN NUMBER)
  is
  CURSOR C IS
      SELECT  rowid,
	agreement_id,
	customer_id,
	agreement_num,
	agreement_type,
	owned_by_person_id,
	term_id,
	revenue_limit_flag ,
	amount,
	description,
	expiration_date,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8 ,
	attribute9,
	attribute10,
	template_flag,
	pm_agreement_reference,
	pm_product_code,
	owning_organization_id,
	agreement_currency_code,
	invoice_limit_flag,
/*Federal*/
        customer_order_number,
        advance_required,
        start_date,
        billing_sequence,
        line_of_account,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18 ,
	attribute19,
	attribute20,
	attribute21,
	attribute22,
	attribute23,
	attribute24,
	attribute25
      FROM PA_AGREEMENTS
      WHERE agreement_id = p_agreement_id;
      agr_rec C%ROWTYPE;
 BEGIN
      OPEN C;
      FETCH C INTO agr_rec;
      IF C%FOUND THEN
      pa_agreements_pkg.lock_row (
	x_rowid				=> agr_rec.rowid,
	x_agreement_id			=> agr_rec.agreement_id,
	x_customer_id			=> agr_rec.customer_id,
	x_agreement_num			=> agr_rec.agreement_num,
	x_agreement_type		=> agr_rec.agreement_type,
	x_owned_by_person_id		=> agr_rec.owned_by_person_id,
	x_term_id			=> agr_rec.term_id,
	x_revenue_limit_flag		=> agr_rec.revenue_limit_flag,
	x_amount			=> agr_rec.amount,
	x_description			=> agr_rec.description,
	x_expiration_date		=> agr_rec.expiration_date,
	x_attribute_category		=> agr_rec.attribute_category,
	x_attribute1			=> agr_rec.attribute1,
	x_attribute2			=> agr_rec.attribute2,
	x_attribute3			=> agr_rec.attribute3,
	x_attribute4			=> agr_rec.attribute4,
	x_attribute5			=> agr_rec.attribute5,
	x_attribute6			=> agr_rec.attribute6,
	x_attribute7			=> agr_rec.attribute7,
	x_attribute8			=> agr_rec.attribute8,
	x_attribute9			=> agr_rec.attribute9,
	x_attribute10			=> agr_rec.attribute10,
	x_template_flag			=> agr_rec.template_flag,
	x_pm_agreement_reference	=> agr_rec.pm_agreement_reference,
	x_pm_product_code		=> agr_rec.pm_product_code,
	x_owning_organization_id	=> agr_rec.owning_organization_id,
	x_agreement_currency_code	=> agr_rec.agreement_currency_code,
	x_invoice_limit_flag		=> agr_rec.invoice_limit_flag,
/*Federal*/
        x_customer_order_number         => agr_rec.customer_order_number,
        x_advance_required              => agr_rec.advance_required,
        x_start_date                    => agr_rec.start_date,
        x_billing_sequence              => agr_rec.billing_sequence,
        x_line_of_account               => agr_rec.line_of_account,
        x_attribute11                   => agr_rec.attribute11,
        x_attribute12                   => agr_rec.attribute12,
        x_attribute13                   => agr_rec.attribute13,
        x_attribute14                   => agr_rec.attribute14,
        x_attribute15                   => agr_rec.attribute15,
        x_attribute16                   => agr_rec.attribute16,
        x_attribute17                   => agr_rec.attribute17,
        x_attribute18                   => agr_rec.attribute18,
        x_attribute19                   => agr_rec.attribute19,
        x_attribute20                   => agr_rec.attribute20,
        x_attribute21                   => agr_rec.attribute21,
        x_attribute22                   => agr_rec.attribute22,
        x_attribute23                   => agr_rec.attribute23,
        x_attribute24                   => agr_rec.attribute24,
        x_attribute25                   => agr_rec.attribute25);
    END IF;
  END  lock_agreement;

/*============================================================================+
| Name              : check_revenue_limit
| Type              : FUNCTION
| Description       : This function
| History           :
|    15-MAY-2000     Created         Nikhil Mishra.
|    07-SEP-2001     Modified        Srividya
|      changed the select to check only for accrued amount
+============================================================================*/

FUNCTION check_revenue_limit
	( p_agreement_id        		IN 	NUMBER
 	)
RETURN VARCHAR2
IS
	l_check_limit NUMBER;
BEGIN
      -- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.CHECK_REVENUE_LIMIT');
/*
	SELECT MIN(SIGN((f1.total_baselined_amount+f1.total_unbaselined_amount)
               -GREATEST(NVL(f1.total_accrued_amount,0), NVL(f1.total_billed_amount, 0))))
	INTO	check_limit
	FROM	pa_summary_project_fundings f1
	WHERE	f1.agreement_id = p_agreement_id;
*/
        /* commented and rewritten for bug 2744993
	SELECT MIN(SIGN((f1.total_baselined_amount+f1.total_unbaselined_amount)
               - NVL(f1.total_accrued_amount, 0)))
        */
	SELECT MIN(SIGN((f1.projfunc_baselined_amount+f1.projfunc_unbaselined_amount)
               - NVL(f1.projfunc_accrued_amount, 0)))
	INTO	l_check_limit
	FROM	pa_summary_project_fundings f1
	WHERE	f1.agreement_id = p_agreement_id;

	IF l_check_limit < 0 then
		-- dbms_output.put_line('Returning N');
		RETURN 'N';
	ELSE
		-- dbms_output.put_line('Returning Y');
		RETURN 'Y';
	END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line('Returning N');
			RETURN 'N';
  END  check_revenue_limit;


--Name:                 check_budget_type
--Type:                 FUNCTION
--Description:          This function will return 'Y' IF the Project has budget_type_code as 'DRAFT'
--                      ELSE will return 'N'
--
--Called subprograms:   None
--
--
--History:
--                      15-MAY-2000     Created         Nikhil Mishra.
--

FUNCTION check_budget_type
	( p_funding_id        		IN 	NUMBER
 	)
RETURN VARCHAR2
IS
	budget_type_code VARCHAR2(20);
BEGIN
	-- dbms_output.put_line('Inside" PA_AGREEMENT_CORE.CHECK_BUDGET_TYPE');
	SELECT  budget_type_code
	INTO	budget_type_code
	FROM	pa_project_fundings f1
	WHERE	f1.project_funding_id = p_funding_id;

	IF budget_type_code = 'DRAFT' then
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RETURN 'N';
END  check_budget_type;

/*============================================================================+
| Name:                 get_agr_curr_code
| Type:                 FUNCTION
| Description:          This function will return agreement_currency_code for
|                       the agreement_id
|                       Created for MCB2
+============================================================================*/
FUNCTION get_agr_curr_code (p_agreement_id IN NUMBER)
RETURN VARCHAR2 IS
       l_currency_code VARCHAR2(30);
BEGIN
	SELECT agreement_currency_code INTO l_currency_code
	FROM pa_agreements_all
	WHERE agreement_id = p_agreement_id;
        RETURN (l_currency_code);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
             RETURN 'ERROR';
END get_agr_curr_code;

/*============================================================================+
| Name:                 check_valid_owning_orgn_id
| Type:                 FUNCTION
| Description:          This function will return "Y" if owning organization id
|                       is valid else N
|                       Created for MCB2
+============================================================================*/
FUNCTION check_valid_owning_orgn_id (
	 p_owning_organization_id IN NUMBER)
RETURN VARCHAR2 IS

       l_valid_flag VARCHAR2(1);
BEGIN
	SELECT 'Y' INTO l_valid_flag
	FROM pa_organizations_project_v
	WHERE organization_id = p_owning_organization_id
	AND SYSDATE BETWEEN DECODE (date_from, NULL, SYSDATE, date_from)
		    AND DECODE(date_to, NULL, SYSDATE,date_to);
        RETURN 'Y';
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	     RETURN 'N';
END check_valid_owning_orgn_id;

/*============================================================================+
| Name:                 check_valid_agr_curr_code
| Type:                 FUNCTION
| Description:          This function will return "Y" if agreement currency
|                       code is valid
|                       Created for MCB2
+============================================================================*/
FUNCTION check_valid_agr_curr_code (
	 p_agreement_currency_code IN VARCHAR2)
RETURN VARCHAR2 IS

       l_valid_flag VARCHAR2(1);
       l_multi_currency_billing_flag VARCHAR2(1);
       l_share_bill_rates_across_ou  VARCHAR2(1);
       l_allow_funding_across_ou     VARCHAR2(1);
       l_default_exchange_rate_type  VARCHAR2(30);
       l_functional_currency	     VARCHAR2(30);
       l_return_status		     VARCHAR2(30);
       l_msg_count		     NUMBER;
       l_msg_data		     VARCHAR2(100);
       l_competence_match_wt         NUMBER;
       l_availability_match_wt       NUMBER;
        l_job_level_match_wt         NUMBER;

BEGIN

  /* Bug#4403200 - Replace the View fnd_currencies_vl with table fnd_currencies
     for performance issue */

	SELECT 'Y' INTO l_valid_flag
	FROM fnd_currencies
	WHERE currency_code = p_agreement_currency_code
	AND SYSDATE BETWEEN DECODE (start_date_active, NULL, SYSDATE,
                                    start_date_active)
		    AND DECODE(end_date_active, NULL, SYSDATE,end_date_active);

	if l_valid_flag = 'Y' then

	   pa_multi_currency_billing.get_imp_defaults(
              x_multi_currency_billing_flag => l_multi_currency_billing_flag,
              x_share_bill_rates_across_ou  => l_share_bill_rates_across_ou,
	      x_allow_funding_across_ou     => l_allow_funding_across_ou,
	      x_default_exchange_rate_type  => l_default_exchange_rate_type,
	      x_functional_currency	    => l_functional_currency,
              x_competence_match_wt         => l_competence_match_wt,
              x_availability_match_wt       => l_availability_match_wt,
              x_job_level_match_wt          => l_job_level_match_wt,
	      x_return_status		    => l_return_status,
	      x_msg_count		    => l_msg_count,
	      x_msg_data		    => l_msg_data);

	   if (l_multi_currency_billing_flag = 'N' AND
	        p_agreement_currency_code <> l_functional_currency) THEN
		RETURN 'N';
	   ELSE
		RETURN 'Y';
	   END IF;
	ELSE
	   RETURN 'N';
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	     RETURN 'N';
END check_valid_agr_curr_code;

/*============================================================================+
| Name:                 check_invoice_limit
| Type:                 FUNCTION
| Description:          This function will return "Y"
|                       else N
+============================================================================*/
FUNCTION check_invoice_limit
	( p_agreement_id        		IN 	NUMBER
 	)
RETURN VARCHAR2
IS
	l_check_limit NUMBER;
BEGIN
	-- dbms_output.put_line('Inside: PA_AGREEMENT_CORE.CHECK_INVOICE_LIMIT');
        /* commented and rewritten for bug 2744993
	SELECT MIN(SIGN((f1.total_baselined_amount+f1.total_unbaselined_amount)
               - NVL(f1.total_billed_amount, 0)))
        */
	SELECT MIN(SIGN((f1.invproc_baselined_amount+f1.invproc_unbaselined_amount)
               - NVL(f1.invproc_billed_amount, 0)))
	INTO	l_check_limit
	FROM	pa_summary_project_fundings f1
	WHERE	f1.agreement_id = p_agreement_id;

	IF l_check_limit < 0 then
		-- dbms_output.put_line('Returning N');
		RETURN 'N';
	ELSE
		-- dbms_output.put_line('Returning Y');
		RETURN 'Y';
	END IF;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			-- dbms_output.put_line('Returning N');
			RETURN 'N';
  END  check_invoice_limit;

END  PA_AGREEMENT_CORE;


/
