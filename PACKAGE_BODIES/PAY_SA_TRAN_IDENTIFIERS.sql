--------------------------------------------------------
--  DDL for Package Body PAY_SA_TRAN_IDENTIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_TRAN_IDENTIFIERS" AS
/* $Header: pysatran.pkb 120.0.12010000.2 2009/07/27 06:09:51 bkeshary noship $ */



   --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EFT_RECON_DATA                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function to identify the batch transaction          --
  --                  identifiers for reconciliation                                        --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_effective_date              DATE                  --
  --                  p_identifier_name             VARCHAR2              --
  --                  p_payroll_action_id           NUMBER                --
  --                  p_payment_type_id             NUMBER                --
  --                  p_org_payment_method_id       NUMBER                --
  --                  p_personal_payment_method_id  NUMBER                --
  --                  p_assignment_action_id        NUMBER                --
  --                  p_pre_payment_id              NUMBER                --
  --                  p_delimiter_string            VARCHAR2              --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 12.0  17-Jul-2009    bkeshary  Initial Version                       --
  --------------------------------------------------------------------------
     FUNCTION get_eft_recon_data
	(
	  p_effective_date              DATE
	, p_identifier_name             VARCHAR2
	, p_payroll_action_id           NUMBER
	, p_payment_type_id             NUMBER
	, p_org_payment_method_id       NUMBER
	, p_personal_payment_method_id  NUMBER
	, p_assignment_action_id        NUMBER
	, p_pre_payment_id              NUMBER
	, p_delimiter_string            VARCHAR2
	)
	RETURN VARCHAR2
	IS

          CURSOR c_get_transaction_date
           IS
            select overriding_dd_date
            from pay_payroll_actions
            where payroll_action_id = p_payroll_action_id;

	 CURSOR c_get_func_name(p_org_payment_method_id NUMBER)
	  IS
           select PMETH_INFORMATION4
            from PAY_ORG_PAYMENT_METHODS_F
	    where ORG_PAYMENT_METHOD_ID = p_org_payment_method_id;


      l_return_value	 VARCHAR2(80) := NULL;
      l_trans_date            Date;
      l_func_name           VARCHAR2(80);
      user_excep            EXCEPTION;
      user_excep1           EXCEPTION;


   BEGIN

          OPEN c_get_func_name(p_org_payment_method_id);
          FETCH c_get_func_name INTO l_func_name;
	  CLOSE c_get_func_name;


     IF  l_func_name IS NOT NULL
     THEN
          EXECUTE IMMEDIATE 'select '||l_func_name||'(:1,:2,:3,:4,:5,:6,:7,:8,:9) from dual'
          INTO l_return_value
          USING p_effective_date ,
                p_identifier_name,
                p_payroll_action_id,
                p_payment_type_id,
                p_org_payment_method_id,
                p_personal_payment_method_id,
                p_assignment_action_id,
                p_pre_payment_id,
                p_delimiter_string ;

		IF UPPER(p_identifier_name) = 'TRANSACTION_DATE'  THEN

		 BEGIN
                 l_return_value := to_char(to_date(l_return_value, 'YYYY/MM/DD'), 'YYYY/MM/DD');
                 EXCEPTION
                   WHEN others THEN
                    raise_application_error(-20100,'Transition Date must be in YYYY/MM/DD format.');
                 END;

	       END IF;

     ELSE
           raise user_excep;

     END IF;


     IF UPPER(p_identifier_name) = 'TRANSACTION_DATE' AND  l_return_value IS NULL
      THEN
           OPEN c_get_transaction_date;
	   FETCH c_get_transaction_date INTO l_trans_date;
           CLOSE c_get_transaction_date;

	    l_return_value := to_char(l_trans_date, 'yyyy/mm/dd');

     ELSIF UPPER(p_identifier_name) = 'TRANSACTION_GROUP' AND l_return_value IS NULL
      THEN
            l_return_value := p_payroll_action_id;

     ELSIF UPPER(p_identifier_name) = 'CONCATENATED_IDENTIFIERS' AND l_return_value IS NULL
     THEN
             raise user_excep1;

     END IF;

   RETURN l_return_value;

   EXCEPTION

       WHEN user_excep THEN

	raise_application_error(-20101, 'Function Name must be entered in the Reconciliation Function segment of Further Payment Method Info DDF.');

       WHEN user_excep1 THEN

       raise_application_error(-20102, 'Ensure that the function returns a value for the identifier CONCATENATED_IDENTIFIERS.');

       WHEN others THEN

    raise;

   END get_eft_recon_data;

END pay_sa_tran_identifiers;

/
