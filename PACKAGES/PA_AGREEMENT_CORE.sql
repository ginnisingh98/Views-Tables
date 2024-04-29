--------------------------------------------------------
--  DDL for Package PA_AGREEMENT_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_AGREEMENT_CORE" AUTHID CURRENT_USER as
/*$Header: PAAFAGCS.pls 120.2 2007/02/07 10:43:03 rgandhi ship $*/

--  FUNCTION  check_multi_customer check weather project is Multi-Customer or
--  Single-Customer

        FUNCTION  check_multi_customers
        ( p_project_id                        	IN      NUMBER
        ) RETURN VARCHAR2 ;


--  FUNCTION  check_contribution will ensure that the Customer Contribution
--  is exactly 100 % provided agreement is a template agreement.


        FUNCTION  check_contribution
        ( p_agreement_id                        IN      NUMBER
        ) RETURN VARCHAR2 ;


--  FUNCTION  check_valid_customer check weather Customer is valid or not

        FUNCTION  check_valid_customer
        ( p_customer_id                        	IN      NUMBER
        ) RETURN VARCHAR2 ;

--  FUNCTION  check_valid_type check weather Agreement type is valid or not

	FUNCTION check_valid_type
	( p_agreement_type       		IN 	VARCHAR2
 	) RETURN VARCHAR2;

--  FUNCTION  check_invoice_exists check weather invoices exists for given Agreement.

	FUNCTION check_invoice_exists
	( p_agreement_id        		IN 	NUMBER
 	) RETURN VARCHAR2;

--  FUNCTION  check_valid_term_id check weather term_id is active And valid or not

	FUNCTION check_valid_term_id
	( p_term_id        			IN 	NUMBER
 	) RETURN VARCHAR2;

--  FUNCTION  check_valid_owned_by_person_id check weather check_valid_owned_by_person_id is valid or not

	FUNCTION check_valid_owned_by_person_id
	( p_owned_by_person_id        		IN 	NUMBER
 	) RETURN VARCHAR2;

--  FUNCTION  check_unique_agreement check weather agreement_num, agreement_type and customer
--	      are of unique combination

FUNCTION check_unique_agreement
	( p_agreement_num        		IN 	VARCHAR2
 	 ,p_agreement_type                      IN      VARCHAR2
 	 ,p_customer_id                         IN      NUMBER
 	)RETURN VARCHAR2;

FUNCTION validate_agreement_amount
	( p_agreement_id        		IN 	NUMBER
 	 ,p_amount                         	IN      NUMBER
 	) RETURN VARCHAR2;

FUNCTION check_revenue_limit
	( p_agreement_id        		IN 	NUMBER
 	) RETURN VARCHAR2;

FUNCTION check_budget_type
	( p_funding_id        		IN 	NUMBER
 	) RETURN VARCHAR2;

FUNCTION get_agreement_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	) RETURN NUMBER;

FUNCTION get_customer_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	) RETURN NUMBER;

FUNCTION get_project_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	) RETURN NUMBER;

FUNCTION get_task_id
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	) RETURN NUMBER;


FUNCTION check_add_update
	( 	p_funding_id       		IN 	NUMBER
		,p_funding_reference		IN 	VARCHAR2
 	) RETURN VARCHAR2;

FUNCTION check_valid_agreement_ref
	(p_agreement_reference           	IN	VARCHAR2
	)RETURN VARCHAR2 ;

FUNCTION check_valid_agreement_id
	(p_agreement_id           		IN	NUMBER
	)RETURN VARCHAR2 ;

FUNCTION check_valid_funding_ref
	(p_funding_reference           		IN	VARCHAR2
	,p_agreement_id				IN	NUMBER
	)RETURN VARCHAR2 ;

FUNCTION check_valid_funding_id
	(p_agreement_id           		IN	NUMBER
	,p_funding_id           		IN	NUMBER
	)RETURN VARCHAR2 ;


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
	  p_Template_Flag		   IN VARCHAR2,
	  p_pm_agreement_reference	   IN VARCHAR2,
	  p_pm_product_code		   IN VARCHAR2,
          p_agreement_currency_code        IN VARCHAR2 DEFAULT NULL,
          p_owning_organization_id         IN NUMBER   DEFAULT NULL,
          p_invoice_limit_flag             IN VARCHAR2 DEFAULT NULL,
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

                      );

  PROCEDURE Lock_agreement(p_Agreement_Id IN NUMBER );

  PROCEDURE Update_agreement(
 	p_Agreement_Id                   NUMBER,
	p_Customer_Id                    NUMBER,
	p_Agreement_Num                  VARCHAR2,
	p_Agreement_Type                 VARCHAR2,
	p_Last_Update_Date               DATE,
	p_Last_Updated_By                NUMBER,
	p_Last_Update_Login              NUMBER,
	p_Owned_By_Person_Id             NUMBER,
	p_Term_Id                        NUMBER,
	p_Revenue_Limit_Flag             VARCHAR2,
	p_Amount                         NUMBER,
	p_Description                    VARCHAR2,
	p_Expiration_Date                DATE,
	p_Attribute_Category             VARCHAR2,
	p_Attribute1                     VARCHAR2,
	p_Attribute2                     VARCHAR2,
	p_Attribute3                     VARCHAR2,
	p_Attribute4                     VARCHAR2,
	p_Attribute5                     VARCHAR2,
	p_Attribute6                     VARCHAR2,
	p_Attribute7                     VARCHAR2,
	p_Attribute8                     VARCHAR2,
	p_Attribute9                     VARCHAR2,
	p_Attribute10                    VARCHAR2,
	p_Template_Flag			 VARCHAR2,
	p_pm_agreement_reference	 VARCHAR2,
	p_pm_product_code		 VARCHAR2,
        p_agreement_currency_code        IN VARCHAR2 DEFAULT NULL,
        p_owning_organization_id         IN NUMBER   DEFAULT NULL,
        p_invoice_limit_flag             IN VARCHAR2 DEFAULT NULL,
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
				);

    PROCEDURE Delete_agreement(p_agreement_id IN NUMBER );

    FUNCTION get_agr_curr_code (
                 p_agreement_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION check_valid_owning_orgn_id (
                 p_owning_organization_id IN NUMBER) RETURN VARCHAR2;
    FUNCTION check_valid_agr_curr_code(
                 p_agreement_currency_code IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION check_invoice_limit (
                 p_agreement_id IN NUMBER) RETURN VARCHAR2;

end PA_AGREEMENT_CORE;

/
