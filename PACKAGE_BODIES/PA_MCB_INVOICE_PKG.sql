--------------------------------------------------------
--  DDL for Package Body PA_MCB_INVOICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MCB_INVOICE_PKG" AS
/* $Header: PAXMCIUB.pls 120.12.12010000.2 2009/07/23 10:04:52 dbudhwar ship $ */

-- Procedure to
-- Convert the Bill Transaction to Invoice Processing
--    Bill Transaction to Project Functional
--			    Bill Transaction to Project
--		Update   pa_events table

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Event_Convert_amount_bulk (
		p_agreement_id		       IN	NUMBER DEFAULT 0,
            	p_project_id                   IN 	 NUMBER,
            	p_request_id                   IN 	 NUMBER,
                p_task_id                      IN	 PA_PLSQL_DATATYPES.NumTabTyp ,
                p_event_num                    IN	 PA_PLSQL_DATATYPES.NumTabTyp,
                p_bill_trans_currency_code     IN	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_bill_trans_bill_amount       IN 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_invproc_currency_code        IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_invproc_rate_type            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_invproc_rate_date            IN OUT   NOCOPY   PA_PLSQL_DATATYPES.Char30TabTyp,
                p_invproc_exchange_rate        IN OUT 	 NOCOPY  PA_PLSQL_DATATYPES.Char30TabTyp,
                p_invproc_bill_amount          IN OUT  NOCOPY    PA_PLSQL_DATATYPES.Char30TabTyp,
                p_project_currency_code        IN        PA_PLSQL_DATATYPES.Char30TabTyp,
                p_project_rate_type            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_project_rate_date            IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_project_exchange_rate        IN OUT  NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_projfunc_currency_code       IN  	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_projfunc_rate_type           IN OUT NOCOPY  	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_projfunc_rate_date           IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_projfunc_exchange_rate       IN OUT NOCOPY  	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_funding_rate_type           IN OUT NOCOPY  	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_funding_rate_date           IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_funding_exchange_rate       IN OUT NOCOPY  	 PA_PLSQL_DATATYPES.Char30TabTyp,
                p_shared_funds_consumption    IN                    NUMBER,   /* Federal */
                p_completion_date              IN                    PA_PLSQL_DATATYPES.Char30TabTyp,  /* Federal */
		x_status_tab		      IN OUT NOCOPY 	 PA_PLSQL_DATATYPES.Char30TabTyp,
                x_return_status               IN OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

tmp_denominator_tab           PA_PLSQL_DATATYPES.NumTabTyp;
tmp_numerator_tab             PA_PLSQL_DATATYPES.NumTabTyp;
tmp_rate_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
tmp_user_validate_flag_tab    PA_PLSQL_DATATYPES.Char30TabTyp;

tmp_status_project_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_status_projfunc_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_status_funding_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_status_invproc_tab        PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_status_tab                PA_PLSQL_DATATYPES.Char30TabTyp;

tmp_project_bill_amount       PA_PLSQL_DATATYPES.NumTabTyp;
tmp_projfunc_bill_amount      PA_PLSQL_DATATYPES.NumTabTyp;
tmp_funding_bill_amount       PA_PLSQL_DATATYPES.NumTabTyp;
tmp_invproc_bill_amount       PA_PLSQL_DATATYPES.NumTabTyp;
tmp_bill_trans_bill_amount    PA_PLSQL_DATATYPES.NumTabTyp;

tmp_project_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;
tmp_projfunc_exchange_rate    PA_PLSQL_DATATYPES.NumTabTyp;
tmp_funding_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;
tmp_invproc_exchange_rate     PA_PLSQL_DATATYPES.NumTabTyp;

tmp_invproc_rate_type         PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_invproc_currency_code     PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_currency_code     PA_PLSQL_DATATYPES.Char30TabTyp;

tmp_project_rate_date         PA_PLSQL_DATATYPES.DateTabTyp;
tmp_projfunc_rate_date        PA_PLSQL_DATATYPES.DateTabTyp;
tmp_funding_rate_date         PA_PLSQL_DATATYPES.DateTabTyp;
tmp_invproc_rate_date         PA_PLSQL_DATATYPES.DateTabTyp;


tmp_invproc_currency_type     VARCHAR2(30);

 l_multi_currency_billing_flag VARCHAR2(1);
 l_baseline_funding_flag       VARCHAR2(1);
 l_revproc_currency_code       VARCHAR2(30);
 l_invproc_currency_code       VARCHAR2(30);
 l_project_currency_code       VARCHAR2(30);
 l_project_rate_date_code      VARCHAR2(30);
 l_project_rate_type           VARCHAR2(30);
 l_project_rate_date           DATE;
 l_project_exchange_rate       NUMBER;
 l_projfunc_currency_code      VARCHAR2(30);
 l_projfunc_rate_date_code     VARCHAR2(30);
 l_projfunc_rate_type          VARCHAR2(30);
 l_projfunc_rate_date          DATE;
 l_projfunc_exchange_rate      NUMBER;
 l_funding_rate_date_code      VARCHAR2(30);
 l_funding_rate_type           VARCHAR2(30);
 l_funding_rate_date           DATE;
 l_funding_exchange_rate       NUMBER;
 l_funding_currency_code       VARCHAR2(30);
 l_return_status               VARCHAR2(1);
 l_msg_count                   NUMBER;
 l_msg_data                    VARCHAR2(240);


 l_request_id                  NUMBER:= fnd_global.conc_request_id;
 l_program_id                  NUMBER:= fnd_global.conc_program_id;
 l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
 l_program_update_date         DATE  := sysdate;
 l_last_update_date            DATE  := sysdate;
 l_last_updated_by             NUMBER:= fnd_global.user_id;
 l_last_update_login           NUMBER:= fnd_global.login_id;

 /* Federal Changes */

 tmp_completion_date              PA_PLSQL_DATATYPES.DateTabTyp;
 l_agreement_start_date           DATE;
 l_agreement_exp_date             DATE;


BEGIN

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk');
        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Call PA_MULTI_CURRENCY_BILLING.get_project_defaults');
        END IF;


        IF g1_debug_mode  = 'Y' THEN
                PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: Agreement Id :' || p_agreement_id );
        END IF;




	-- Get the Agreement Currency Code
	-- For Write-on Events Agreement id will be there
	-- For Reg Events Agreement Id will not be there.

        /* Federal Changes : Adding agreement start and end date */

	IF ( NVL(p_agreement_id,0) <> 0 ) THEN

	  	SELECT agreement_currency_code,
                       nvl(start_date, to_date('01/01/1952','DD/MM/YYYY')),
                       nvl(expiration_date, sysdate)
	    	  INTO l_funding_currency_code,
                       l_agreement_start_date,
                       l_agreement_exp_date
	    	  FROM pa_agreements_all
	   	 WHERE agreement_id =p_agreement_id;


	END IF;


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Call PA_MULTI_CURRENCY_BILLING.get_project_defaults');
        END IF;

	-- Get the Project Level Defaults
      PA_MULTI_CURRENCY_BILLING.get_project_defaults (
            p_project_id                  => p_project_id,
            x_multi_currency_billing_flag => l_multi_currency_billing_flag,
            x_baseline_funding_flag       => l_baseline_funding_flag,
            x_revproc_currency_code       => l_revproc_currency_code,
            x_invproc_currency_type       => tmp_invproc_currency_type,
            x_invproc_currency_code       => l_invproc_currency_code,
            x_project_currency_code       => l_project_currency_code,
            x_project_bil_rate_date_code  => l_project_rate_date_code,
            x_project_bil_rate_type       => l_project_rate_type,
            x_project_bil_rate_date       => l_project_rate_date,
            x_project_bil_exchange_rate   => l_project_exchange_rate,
            x_projfunc_currency_code      => l_projfunc_currency_code,
            x_projfunc_bil_rate_date_code => l_projfunc_rate_date_code,
            x_projfunc_bil_rate_type      => l_projfunc_rate_type,
            x_projfunc_bil_rate_date      => l_projfunc_rate_date,
            x_projfunc_bil_exchange_rate  => l_projfunc_exchange_rate,
            x_funding_rate_date_code      => l_funding_rate_date_code,
            x_funding_rate_type           => l_funding_rate_type,
            x_funding_rate_date           => l_funding_rate_date,
            x_funding_exchange_rate       => l_funding_exchange_rate,
            x_return_status               => l_return_status,
            x_msg_count                   => l_msg_count,
            x_msg_data                    => l_msg_data);

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Events To Process :  ' || p_event_num.count);
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'IPC Type :  ' || tmp_invproc_currency_type);
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'IPC Code :  ' || l_invproc_currency_code);
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'PC Code :  ' || l_project_currency_code);
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'PFC Code :  ' || l_projfunc_currency_code);
           END IF;

	-- ARRAY is empty, no process required

	IF  (p_event_num.exists(p_event_num.first))  THEN

		-- Convert the data types

		  FOR i IN p_event_num.FIRST..p_event_num.LAST LOOP

                        IF g1_debug_mode  = 'Y' THEN
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Project Rate Date :  ' || p_project_rate_date(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Projfunc Rate Date:  ' || p_projfunc_rate_date(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Funding Rate Date :  ' || p_funding_rate_date(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Invproc Rate Date :  ' || p_invproc_rate_date(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Project Rate    :  ' || p_project_exchange_rate(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Projfunc Rate   :  ' || p_projfunc_exchange_rate(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Funding Rate    :  ' || p_funding_exchange_rate(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'IPC      Rate   :  ' || p_invproc_exchange_rate(i));
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'BTC      Amount :  ' || p_bill_trans_bill_amount(i));
                                  /* Federal Changes */
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Evt Cmplete Date:  ' || p_completion_date(i));
                        END IF;

			tmp_project_exchange_rate(i) := TO_NUMBER(p_project_exchange_rate(i));
			tmp_projfunc_exchange_rate(i):= TO_NUMBER(p_projfunc_exchange_rate(i));
			tmp_funding_exchange_rate(i) := TO_NUMBER(p_funding_exchange_rate(i));
			tmp_invproc_exchange_rate(i) := TO_NUMBER(p_invproc_exchange_rate(i));

                        /* R12 : ATG changes : added date format */
			tmp_project_rate_date(i)     := TO_DATE(p_project_rate_date(i), 'YYYY/MM/DD');
			tmp_projfunc_rate_date(i)    := TO_DATE(p_projfunc_rate_date(i), 'YYYY/MM/DD');
			tmp_funding_rate_date(i)     := TO_DATE(p_funding_rate_date(i),'YYYY/MM/DD');
                        IF g1_debug_mode  = 'Y' THEN
                        	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Before Assign IPC date to   ');
                        END IF;

			tmp_invproc_rate_date(i)     := TO_DATE(p_invproc_rate_date(i),'YYYY/MM/DD');

 PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'first .....');

			tmp_denominator_tab(i)       :=0;
			tmp_numerator_tab(i)	     :=0;
			tmp_rate_tab(i)                 :=0;
			tmp_user_validate_flag_tab(i):='N';
			tmp_status_project_tab(i)    :='N';
			tmp_status_projfunc_tab(i)   :='N';
			tmp_status_funding_tab(i)    := 'N';
			tmp_status_invproc_tab(i)    := 'N';
			tmp_status_tab(i)               := 'N';

			tmp_project_bill_amount(i)   :=0;
			tmp_projfunc_bill_amount(i)  :=0;
			tmp_invproc_bill_amount(i)   :=0;
			tmp_funding_bill_amount(i)   :=0;

PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'two .....');

			tmp_bill_trans_bill_amount(i):= TO_NUMBER(p_bill_trans_bill_amount(i));
			tmp_invproc_currency_code (i) := l_invproc_currency_code;
			tmp_funding_currency_code(i)  := l_funding_currency_code;

PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'three .....');

		 IF tmp_invproc_currency_type = 'FUNDING_CURRENCY' THEN

 PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'three one .....');
           		tmp_invproc_rate_type(i) := p_funding_rate_type(i);
           		tmp_invproc_rate_date(i) := tmp_funding_rate_date(i);
           		tmp_invproc_exchange_rate(i) := tmp_funding_exchange_rate(i);
           		tmp_invproc_currency_code(i) := l_invproc_currency_code;
        	ELSIF tmp_invproc_currency_type = 'PROJECT_CURRENCY' THEN
 PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'three two .....');

           		tmp_invproc_rate_type(i) := p_project_rate_type(i);
           		tmp_invproc_rate_date(i) := tmp_project_rate_date(i);
           		tmp_invproc_exchange_rate(i) := tmp_project_exchange_rate(i);
           		tmp_invproc_currency_code(i) := p_project_currency_code(i);
        	ELSIF tmp_invproc_currency_type = 'PROJFUNC_CURRENCY' THEN
 PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'three three .....');
           		tmp_invproc_rate_type(i) := p_projfunc_rate_type(i);
           		tmp_invproc_rate_date(i) := tmp_projfunc_rate_date(i);
           		tmp_invproc_exchange_rate(i) := tmp_projfunc_exchange_rate(i);
           		tmp_invproc_currency_code(i) := p_projfunc_currency_code(i);
        	END IF;

PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'four .....');
                      /* Federal Changes */

                    /*    tmp_completion_date(i) := TO_DATE(p_completion_date(i), 'YYYY/MM/DD') ;   */


PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'five .....');

	END LOOP;

	-- Convert the bill transaction to Project functional currency
           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Convert Bill Transaction To Project functional ' );
           END IF;

       PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
          		p_from_currency_tab 		=> p_bill_trans_currency_code,
          		p_to_currency_tab   		=> p_projfunc_currency_code,
          		p_conversion_date_tab		=> tmp_projfunc_rate_date,
          		p_conversion_type_tab 		=> p_projfunc_rate_type,
          		p_amount_tab         		=> tmp_bill_trans_bill_amount,
          		p_user_validate_flag_tab 	=> tmp_user_validate_flag_tab,
          		p_converted_amount_tab          => tmp_projfunc_bill_amount,
          		p_denominator_tab               => tmp_denominator_tab,
          		p_numerator_tab                 => tmp_numerator_tab,
          		p_rate_tab                      => tmp_projfunc_exchange_rate,
          		x_status_tab                    => tmp_status_projfunc_tab,
			p_conversion_between 		=> 'BTC_PF',
			p_cache_flag			=> 'N');

	tmp_denominator_tab.delete;
	tmp_numerator_tab.delete;

        if (l_project_currency_code = l_projfunc_currency_code ) then

            IF g1_debug_mode  = 'Y' THEN
            	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Proj curr = Proj func currency ..Copy ' );
            END IF;

	    FOR i IN tmp_status_projfunc_tab.FIRST..tmp_status_projfunc_tab.LAST LOOP

                tmp_project_rate_date(i) :=  tmp_projfunc_rate_date(i);
                p_project_rate_type(i) :=  p_projfunc_rate_type(i);
                tmp_project_bill_amount(i) := tmp_projfunc_bill_amount(i);
                tmp_project_exchange_rate(i) :=  tmp_projfunc_exchange_rate(i);
                tmp_status_project_tab(i) :=  tmp_status_projfunc_tab(i);

            END LOOP;

        else
	    -- Convert the bill transaction to Project currency

            IF g1_debug_mode  = 'Y' THEN
            	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Convert Bill Transaction To Project ' );
            END IF;

            PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
          				p_from_currency_tab 		=> p_bill_trans_currency_code,
          				p_to_currency_tab   		=> p_project_currency_code,
          				p_conversion_date_tab		=> tmp_project_rate_date,
          				p_conversion_type_tab 		=> p_project_rate_type,
          				p_amount_tab         		=> tmp_bill_trans_bill_amount,
          				p_user_validate_flag_tab 	=> tmp_user_validate_flag_tab,
          				p_converted_amount_tab          => tmp_project_bill_amount,
          				p_denominator_tab               => tmp_denominator_tab,
          				p_numerator_tab                 => tmp_numerator_tab,
          				p_rate_tab                      => tmp_project_exchange_rate,
          				x_status_tab                    => tmp_status_project_tab,
					p_conversion_between 		=> 'BTC_PC',
					p_cache_flag			=>'N');

	    tmp_denominator_tab.delete;
            tmp_numerator_tab.delete;
        end if;


		-- Convert the bill transaction to Funding currency

	IF NVL(p_agreement_id,0) <> 0 THEN

	-- This will be done only for WRITE ON events

           if l_funding_currency_code = l_projfunc_currency_code then

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Write on - funding curr = Proj func currency ..Copy ' );
              END IF;

	      FOR i IN tmp_status_projfunc_tab.FIRST..tmp_status_projfunc_tab.LAST LOOP

                  tmp_funding_rate_date(i) :=  tmp_projfunc_rate_date(i);
                  p_funding_rate_type(i) :=  p_projfunc_rate_type(i);
                  tmp_funding_bill_amount(i) := tmp_projfunc_bill_amount(i);
                  tmp_funding_exchange_rate(i) :=  tmp_projfunc_exchange_rate(i);
                  tmp_status_funding_tab(i) :=  tmp_status_projfunc_tab(i);

              END LOOP;

           elsif l_funding_currency_code = l_project_currency_code then

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Write on - funding curr = Proj currency ..Copy ' );
              END IF;

	      FOR i IN tmp_status_project_tab.FIRST..tmp_status_project_tab.LAST LOOP

                  tmp_funding_rate_date(i) :=  tmp_project_rate_date(i);
                  p_funding_rate_type(i) :=  p_project_rate_type(i);
                  tmp_funding_bill_amount(i) := tmp_project_bill_amount(i);
                  tmp_funding_exchange_rate(i) :=  tmp_project_exchange_rate(i);
                  tmp_status_funding_tab(i) :=  tmp_status_project_tab(i);

              END LOOP;

           else

              IF g1_debug_mode  = 'Y' THEN
              	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Convert Bill Transaction To Funding Write-ON ' );
              END IF;

       	      PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
          		p_from_currency_tab 		=> p_bill_trans_currency_code,
          		p_to_currency_tab   		=> tmp_funding_currency_code,
          		p_conversion_date_tab		=> tmp_funding_rate_date,
          		p_conversion_type_tab 		=> p_funding_rate_type,
          		p_amount_tab         		=> tmp_bill_trans_bill_amount,
          		p_user_validate_flag_tab 	=> tmp_user_validate_flag_tab,
          		p_converted_amount_tab          => tmp_funding_bill_amount,
          		p_denominator_tab               => tmp_denominator_tab,
          		p_numerator_tab                 => tmp_numerator_tab,
          		p_rate_tab                      => tmp_funding_exchange_rate,
          		x_status_tab                    => tmp_status_funding_tab,
			p_conversion_between 		=> 'BTC_FC',
			p_cache_flag			=> 'N');

			tmp_denominator_tab.delete;
			tmp_numerator_tab.delete;
           end if;

	END IF;


        IF l_invproc_currency_code = l_projfunc_currency_code THEN

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'invproc curr = Proj func currency ..Copy ' );
           END IF;

	   FOR i IN tmp_status_projfunc_tab.FIRST..tmp_status_projfunc_tab.LAST LOOP

	       tmp_invproc_bill_amount(i)   := tmp_projfunc_bill_amount(i);
	       tmp_invproc_exchange_rate(i) := tmp_projfunc_exchange_rate(i);
	       tmp_invproc_rate_date(i)     := tmp_projfunc_rate_date(i);
	       tmp_invproc_rate_type(i)     := p_projfunc_rate_type(i);

           END LOOP;

        ELSIF l_invproc_currency_code = l_project_currency_code THEN

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'invproc curr = Project  currency ..Copy ' );
           END IF;

	   FOR i IN tmp_status_project_tab.FIRST..tmp_status_project_tab.LAST LOOP

	       tmp_invproc_bill_amount(i)   := tmp_project_bill_amount(i);
	       tmp_invproc_exchange_rate(i) := tmp_project_exchange_rate(i);
	       tmp_invproc_rate_date(i)     := tmp_project_rate_date(i);
	       tmp_invproc_rate_type(i)     := p_project_rate_type(i);

	   END LOOP;

        ELSE

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Convert Bill Transaction To Funding -Invproc ' );
          END IF;

                        PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                        p_from_currency_tab             => p_bill_trans_currency_code,
                        p_to_currency_tab               => tmp_invproc_currency_code,
                        p_conversion_date_tab           => tmp_invproc_rate_date,
                        p_conversion_type_tab           => tmp_invproc_rate_type,
                        p_amount_tab                    => tmp_bill_trans_bill_amount,
                        p_user_validate_flag_tab        => tmp_user_validate_flag_tab,
                        p_converted_amount_tab          => tmp_invproc_bill_amount,
                        p_denominator_tab               => tmp_denominator_tab,
                        p_numerator_tab                 => tmp_numerator_tab,
                        p_rate_tab                      => tmp_funding_exchange_rate,
                        x_status_tab                    => tmp_status_invproc_tab,
                        p_conversion_between            => 'BTC_FC',
                        p_cache_flag                    =>'N');
                        tmp_denominator_tab.delete;
                        tmp_numerator_tab.delete;


	END IF;

/*

	IF tmp_invproc_currency_type = 'FUNDING_CURRENCY' THEN

		   -- Invoice Processing is Funding Currency
		   -- Convert the Bill Transaction  to Invoice Processing Currency

           IF g1_debug_mode  = 'Y' THEN
           	PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Convert Bill Transaction To Funding ' );
           END IF;

       			PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
          		p_from_currency_tab 		=> p_bill_trans_currency_code,
          		p_to_currency_tab   		=> tmp_invproc_currency_code,
          		p_conversion_date_tab		=> tmp_invproc_rate_date,
          		p_conversion_type_tab 		=> tmp_invproc_rate_type,
          		p_amount_tab         		=> tmp_bill_trans_bill_amount,
          		p_user_validate_flag_tab 	=> tmp_user_validate_flag_tab,
          		p_converted_amount_tab          => tmp_invproc_bill_amount,
          		p_denominator_tab               => tmp_denominator_tab,
          		p_numerator_tab                 => tmp_numerator_tab,
          		p_rate_tab                      => tmp_funding_exchange_rate,
          		x_status_tab                    => tmp_status_invproc_tab,
			p_conversion_between 		=> 'BTC_FC',
			p_cache_flag			=>'N');
			tmp_denominator_tab.delete;
			tmp_numerator_tab.delete;

		ELSIF tmp_invproc_currency_type = 'PROJECT_CURRENCY' THEN

		   -- Invoice Processing is PC
		   -- Move the Project Currency Amount and attributes to  Invoice Processing

			FOR i IN tmp_status_project_tab.FIRST..tmp_status_project_tab.LAST LOOP

				tmp_invproc_bill_amount(i)   := tmp_project_bill_amount(i);
				tmp_invproc_exchange_rate(i) := tmp_project_exchange_rate(i);
				tmp_invproc_rate_date(i)     := tmp_project_rate_date(i);
				tmp_invproc_rate_type(i)     := p_project_rate_type(i);

			END LOOP;
		ELSIF tmp_invproc_currency_type = 'PROJFUNC_CURRENCY' THEN

		   -- Invoice Processing is PFC
		   -- Move the Project Functional Currency Amount and attributes to Invoice Processing

			FOR i IN tmp_status_project_tab.FIRST..tmp_status_project_tab.LAST LOOP

				tmp_invproc_bill_amount(i)   := tmp_projfunc_bill_amount(i);
				tmp_invproc_exchange_rate(i) := tmp_projfunc_exchange_rate(i);
				tmp_invproc_rate_date(i)     := tmp_projfunc_rate_date(i);
				tmp_invproc_rate_type(i)     := p_projfunc_rate_type(i);

			END LOOP;
		END IF;
*/

		-- Set the Status code array

		FOR i IN tmp_status_project_tab.FIRST..tmp_status_project_tab.LAST LOOP

		     tmp_status_tab(i) := 'N';
/*
         The error string concatenation is already done. so commented
         and rewritten by srividya

			IF NVL(tmp_status_project_tab(i),'N') <> 'N' THEN
				tmp_status_tab(i):= 'BTC_PC'|| tmp_status_project_tab(i);
			ELSIF NVL(tmp_status_projfunc_tab(i),'N') <> 'N' THEN
					tmp_status_tab(i):= 'BTC_PF'|| tmp_status_projfunc_tab(i);
			ELSIF NVL(tmp_status_invproc_tab(i),'N') <> 'N' THEN
					tmp_status_tab(i):= 'BTC_FC'|| tmp_status_invproc_tab(i);
			ELSIF NVL(tmp_status_funding_tab(i),'N') <> 'N'
					 AND NVL(p_agreement_id,0) <>0   THEN
					tmp_status_tab(i):= 'BTC_FC'|| tmp_status_funding_tab(i);
			END IF;
*/
                        IF NVL(tmp_status_project_tab(i),'N') <> 'N' THEN
                                tmp_status_tab(i):= tmp_status_project_tab(i);
                        ELSIF NVL(tmp_status_projfunc_tab(i),'N') <> 'N' THEN
                                        tmp_status_tab(i):= tmp_status_projfunc_tab(i);
                        ELSIF NVL(tmp_status_invproc_tab(i),'N') <> 'N' THEN
                                        tmp_status_tab(i):= tmp_status_invproc_tab(i);
                        ELSIF NVL(tmp_status_funding_tab(i),'N') <> 'N'
                                         AND NVL(p_agreement_id,0) <>0   THEN
                                        tmp_status_tab(i):= tmp_status_funding_tab(i);
                        END IF;
                        x_status_tab(i) := tmp_status_tab(i);


                        /* Federal Changes : Reporting error if event completion date is not with in
                           agreement start and end date for funding consumption rule is enabled

                           IF ( p_shared_funds_consumption = 1 ) THEN

                              IF ((tmp_completion_date(i) < l_agreement_start_date)  OR
                                  (tmp_completion_date(i) > l_agreement_exp_date )) THEN

                                    tmp_status_tab(i) := 'PA_EVT_AGR_DATE_MISMATCH';

                              END IF;

                           END IF;
                        */




		END LOOP;

		-- Update the events table

	-- Log Messages for Converted Amounts

           	IF g1_debug_mode  = 'Y' THEN
           		PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Project Id ' || p_project_id);
           	END IF;

	FOR i IN p_event_num.FIRST..p_event_num.LAST LOOP
           	IF g1_debug_mode  = 'Y' THEN
           		PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Event Num ' || P_event_num(i));
           		PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Task Id ' || P_task_id(i));
           		PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Project Amount ' || tmp_project_bill_amount(i));
           		PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'Project Func Amount ' || tmp_projfunc_bill_amount(i));
           		PA_MCB_INVOICE_PKG.log_message('Event_Convert_amount_bulk: ' || 'InvProc Amount ' || tmp_invproc_bill_amount(i));
           	END IF;
	END LOOP;


	FORALL I IN p_event_num.FIRST..p_event_num.LAST
/** Bug 2874486, added decode statement for ensuring all amt fields have same sign as bill_trans_bill_amount */
		UPDATE pa_events
		   SET 	bill_amount = decode(SIGN(bill_trans_bill_amount),SIGN(tmp_invproc_bill_amount(i)),
                                              tmp_invproc_bill_amount(i),(-1) * tmp_invproc_bill_amount(i)),
			invproc_currency_code =decode(invproc_currency_code,NULL,
							 tmp_invproc_currency_code(i),invproc_currency_code),
                                                                         /*bug-2483358*/
			project_bill_amount = decode(SIGN(bill_trans_bill_amount),SIGN(tmp_project_bill_amount(i)),
                                                       tmp_project_bill_amount(i),(-1) * tmp_project_bill_amount(i)),
			project_inv_exchange_rate =tmp_project_exchange_rate(i),
	--		project_inv_rate_date =tmp_project_rate_date(i), --Modified for Bug3087929
			project_inv_rate_date =decode(p_project_rate_type(i), 'User', null, tmp_project_rate_date(i)),
			projfunc_bill_amount = decode(SIGN(bill_trans_bill_amount),SIGN(tmp_projfunc_bill_amount(i)),
                                                        tmp_projfunc_bill_amount(i),(-1) * tmp_projfunc_bill_amount(i)),
			projfunc_inv_exchange_rate =tmp_projfunc_exchange_rate(i),
        --		projfunc_inv_rate_date =tmp_projfunc_rate_date(i), --Modified for Bug3087929
			projfunc_inv_rate_date =decode(p_projfunc_rate_type(i), 'User', null, tmp_projfunc_rate_date(i)),
			inv_gen_rejection_code = tmp_status_tab(i),
 			request_id                       = p_request_id,
            		program_id                       = l_program_id,
            		program_application_id           = l_program_application_id,
            		program_update_date              = l_program_update_date,
            		last_update_date                 = l_last_update_date,
            		last_updated_by                  = l_last_updated_by,
            		last_update_login                = l_last_update_login
		WHERE  project_id = p_project_id
		  AND  NVL(task_id,0) = NVL(p_task_id(i),0)
		  AND  event_num     = p_event_num(i);

  IF g1_debug_mode  = 'Y' THEN
        PA_MCB_INVOICE_PKG.log_message('No of Rows Updated ' || sql%rowcount);
  END IF;
	-- Convert the Data Type for BTC and IPC

		  FOR i IN p_event_num.FIRST..p_event_num.LAST LOOP

			p_invproc_bill_amount(i) := TO_CHAR(tmp_invproc_bill_amount(i));
			p_invproc_exchange_rate(i) := TO_CHAR(tmp_invproc_exchange_rate(i));
			p_invproc_rate_date(i) := TO_CHAR(tmp_invproc_rate_date(i),'YYYY/MM/DD');

			p_project_exchange_rate(i) := TO_CHAR(tmp_project_exchange_rate(i));
			p_project_rate_date(i) := TO_CHAR(tmp_project_rate_date(i),'YYYY/MM/DD');

			p_projfunc_exchange_rate(i) := TO_CHAR(tmp_projfunc_exchange_rate(i));
			p_projfunc_rate_date(i) := TO_CHAR(tmp_projfunc_rate_date(i),'YYYY/MM/DD');

			p_projfunc_exchange_rate(i) := TO_CHAR(tmp_funding_exchange_rate(i));
			p_projfunc_rate_date(i) := TO_CHAR(tmp_funding_rate_date(i),'YYYY/MM/DD');
			p_invproc_currency_code(i) := tmp_invproc_currency_code(i);

		 END LOOP;

	END IF;

EXCEPTION

  When Others Then

          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Event_Convert_amount_bulk ' || sqlerrm);
          END IF;
          x_return_status := sqlerrm( sqlcode );

END Event_Convert_amount_bulk;

-- Procedure to Convert the Invoice Line Bill Transaction Amount to PFC, PC, FC

PROCEDURE Convert_Line_Event_Amount (
                                p_agreement_id                IN  NUMBER ,
                                p_project_id                  IN  NUMBER ,
                                p_task_id                     IN  NUMBER ,
                                p_event_num                   IN  NUMBER ,
                                p_invproc_bill_amount         IN  VARCHAR2,
                                x_project_bill_amount         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_projfunc_bill_amount        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_currency_code       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_bill_amount         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 				x_funding_rate_date 	      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_exchange_rate       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_funding_rate_type           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_bill_trans_inv_amount       OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                                x_status_code                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status               IN OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

tmp_funding_currency_code VARCHAR2(30);

tmp_project_event_amount 	NUMBER:=0;
tmp_projfunc_event_amount	NUMBER:=0;
tmp_invproc_event_amount	NUMBER:=0;
tmp_funding_exchange_rate	NUMBER:=0;
tmp_invproc_bill_amount         NUMBER:=0;
tmp_bill_trans_inv_amount	NUMBER:=0;
tmp_bill_trans_event_amount	NUMBER :=0;
tmp_funding_rate_type		VARCHAR2(30);
tmp_bill_trans_currency_code	VARCHAR2(30);
tmp_funding_rate_date		DATE;

tmp_project_currency_code	VARCHAR2(30);
tmp_projfunc_currency_code	VARCHAR2(30);
tmp_invproc_currency_code	VARCHAR2(30);

tmp_project_inv_exch_rate       NUMBER;
tmp_project_inv_rate_date       DATE;
tmp_project_rate_type           VARCHAR2(30);


tmp_projfunc_inv_exch_rate       NUMBER;
tmp_projfunc_inv_rate_date       DATE;
tmp_projfunc_rate_type           VARCHAR2(30);

tmp_denominator_tab           PA_PLSQL_DATATYPES.NumTabTyp;
tmp_numerator_tab             PA_PLSQL_DATATYPES.NumTabTyp;
tmp_rate_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
tmp_user_validate_flag_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_bill_amount_tab       PA_PLSQL_DATATYPES.NumTabTyp;
tmp_funding_rate_type_tab         PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_rate_date_tab         PA_PLSQL_DATATYPES.DateTabTyp;
tmp_funding_exchange_rate_tab     PA_PLSQL_DATATYPES.NumTabTyp;
tmp_bill_trans_bill_amount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
tmp_bill_trans_currency_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_status_tab                	PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_currency_tab     PA_PLSQL_DATATYPES.Char30TabTyp;

tmp_invproc_currency_type	VARCHAR2(30);

BEGIN

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount');
        	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Project Id '||p_project_id);
        	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Agreement Id  '||p_agreement_id);
        	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Task Id  '||p_task_id);
        	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Event Num   '||p_event_num);
        	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Invproc_Bill_Amount '||p_invproc_bill_amount);
        END IF;

	tmp_invproc_bill_amount := TO_NUMBER(NVL(p_invproc_bill_amount,0));

        x_status_code := 'N';


	BEGIN
	-- Get the Funding Currency Code

                /* this pre-existing code was commented for bug 2916606*/
     	/*	SELECT  FUNDING_CURRENCY_CODE
	 	  INTO  tmp_funding_currency_code
		  FROM pa_summary_project_fundings
     		 WHERE agreement_id = p_agreement_id
       		   AND NVL(task_id,0) = NVL(p_task_id,0)
       	           AND project_id = p_project_id
		   AND rownum=1
                 GROUP BY funding_currency_code
		 HAVING sum(total_baselined_amount) <>0;*/

              /* begin code added for bug 2916606 */

                 select funding_currency_code
                 into tmp_funding_currency_code
                 from (
                        select funding_currency_code
                        from pa_summary_project_fundings
                        where project_id = p_project_id
                        and agreement_id = p_agreement_id
                        and nvl(task_id, 0) = nvl(p_task_id, 0)
                        group by funding_currency_code
                        having sum(total_baselined_amount) <> 0)
                 where rownum=1;

                 /* end of code added for bug 2916606 */


	EXCEPTION /** Added for bug 2263965 **/
	WHEN NO_DATA_FOUND THEN  /** Funding is at Project Level **/

                /* this pre-existing code was commented for bug 2916606*/
		/*SELECT  FUNDING_CURRENCY_CODE
                  INTO  tmp_funding_currency_code
                  FROM pa_summary_project_fundings
                 WHERE agreement_id = p_agreement_id
                   AND project_id = p_project_id
                   AND rownum=1
                 GROUP BY funding_currency_code
                 HAVING sum(total_baselined_amount) <>0;*/

                 /* begin code added for bug 2916606 */

                 select funding_currency_code
                 into tmp_funding_currency_code
                 from(
                        select funding_currency_code
                        from pa_summary_project_fundings
                        where project_id = p_project_id
                        and agreement_id = p_agreement_id
                        group by funding_currency_code
                        having sum(total_baselined_amount) <> 0
                 )
                 where rownum = 1;

                 /* end of code added for bug 2916606 */

	END;

	-- Event Amounts

	BEGIN

     		SELECT  evt.bill_trans_currency_code,
	             /*  decode(etyp.event_type_classification,
			 'INVOICE REDUCTION' ,-evt.bill_trans_bill_amount,
			evt.bill_trans_bill_amount),  Commented for bug 3108623 */
                        evt.bill_trans_bill_amount,  /*Added for 3108623 */
		 	evt.project_bill_amount,
	    		evt.projfunc_bill_amount,
	    		evt.bill_amount,
	    		evt.funding_rate_type,
	    		evt.funding_rate_date,
	    		evt.funding_exchange_rate ,
			evt.project_currency_code,
			evt.projfunc_currency_code,
                        evt.invproc_currency_code,
                        evt.project_inv_exchange_rate,
                        evt.project_inv_rate_date,
                        evt.project_rate_type,
                        evt.projfunc_inv_exchange_rate,
                        evt.projfunc_inv_rate_date,
                        evt.projfunc_rate_type,
			pr.invproc_currency_type
		  INTO tmp_bill_trans_currency_code,
		       tmp_bill_trans_event_amount,
		       tmp_project_event_amount,
		       tmp_projfunc_event_amount,
		       tmp_invproc_event_amount,
		       tmp_funding_rate_type,
		       tmp_funding_rate_date,
		       tmp_funding_exchange_rate,
		       tmp_project_currency_code,
		       tmp_projfunc_currency_code,
                       tmp_invproc_currency_code,
                       tmp_project_inv_exch_rate,
                       tmp_project_inv_rate_date,
                       tmp_project_rate_type,
                       tmp_projfunc_inv_exch_rate,
                       tmp_projfunc_inv_rate_date,
                       tmp_projfunc_rate_type,
                       tmp_invproc_currency_type
     	          FROM  pa_events evt, pa_projects_all pr,
			pa_event_types etyp
    		  WHERE evt.project_id = p_project_id
      		    AND NVL(evt.task_id,0) = NVL(p_task_id,0)
      		    AND evt.event_num = p_event_num
                    AND evt.project_id = pr.project_id
		    AND evt.event_type = etyp.event_type;

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Event IPC Amount    : ' || tmp_invproc_event_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Event PC Amount    : ' || tmp_project_event_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Event PFC Amount    : ' || tmp_projfunc_event_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Event Bill Trans Amount    : ' || tmp_bill_trans_event_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Event Inv Proc Amount    : ' || tmp_invproc_event_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Invoice Inv Proc Amount    : ' || tmp_invproc_bill_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Inv Proc Currency Type    : ' || tmp_invproc_currency_type);
                END IF;

	        -- Calculating Amounts

                IF nvl(tmp_invproc_currency_code,'0') = nvl(tmp_bill_trans_currency_code,'0') THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_invproc_currency_code = tmp_bill_trans_currency_code');
                    END IF;

                   tmp_bill_trans_inv_amount :=  nvl(p_invproc_bill_amount,0);

                elsif tmp_invproc_currency_type= 'PROJFUNC_CURRENCY' AND
			nvl(tmp_bill_trans_currency_code,'0') <> nvl(tmp_projfunc_currency_code,'0')   THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_invproc_currency_type = PROJFUNC_CURRENCY and tmp_bill_trans_currency_code <> tmp_projfunc_currency_code ');
                    END IF;

		  /* Bug 3548844:  If the event is fully billed, use the trans amount from event
                                   do not rederive the transaction amount */

                  /* Bug 3712615: Added abs to compare the absolute value of amounts.
                     Also added sign functions since invproc bill amt will be -ve in case inv redn event
                     and manual events can have -ve values */
		    IF NVL(abs(p_invproc_bill_amount),0) = NVL(abs(tmp_invproc_event_amount),0) THEN

			tmp_bill_trans_inv_amount := NVL(tmp_bill_trans_event_amount, 0) *
                                                      sign(nvl(p_invproc_bill_amount, 1)) * sign(nvl(tmp_bill_trans_event_amount,1));

		    ELSE
		  /* end of the bug fix 3548844 */
	            tmp_bill_trans_inv_amount := pa_multi_currency_billing.round_trans_currency_amt(
				        	 NVL(p_invproc_bill_amount,0) *
						(1/ NVL(tmp_projfunc_inv_exch_rate,0))
				                 , tmp_bill_trans_currency_code);

		    END IF;  --- Added for bug 3548844

                elsif tmp_invproc_currency_type= 'PROJECT_CURRENCY'  AND
				 nvl(tmp_bill_trans_currency_code,'0') <> nvl(tmp_project_currency_code,'0')   THEN

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_invproc_currency_type = PROJECT_CURRENCY and tmp_bill_trans_currency_code <> tmp_project_currency_code ');
                    END IF;
		  /* Bug 3548844:  If the event is fully billed, use the trans amount from event
                                   do not rederive the transaction amount */

                  /* Bug 3712615: Added abs to compare the absolute value of amounts.
                     Also added sign function since invproc bill amt will be -ve in case inv redn event */
		    IF NVL(abs(p_invproc_bill_amount),0) = NVL(abs(tmp_invproc_event_amount),0) THEN

			tmp_bill_trans_inv_amount := NVL(tmp_bill_trans_event_amount,0) *
                                                      sign(nvl(p_invproc_bill_amount,1)) * sign(nvl(tmp_bill_trans_event_amount,1));

		    ELSE
		  /* end of the bug fix 3548844 */
	            tmp_bill_trans_inv_amount := pa_multi_currency_billing.round_trans_currency_amt(
				        	 NVL(p_invproc_bill_amount,0) *
						(1/ NVL(tmp_project_inv_exch_rate,0))
				                 , tmp_bill_trans_currency_code);

		    END IF;  --- Added for bug 3548844
                else

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_invproc_currency_code <> tmp_bill_trans_currency_code');
                    END IF;

		  /* Bug 3548844:  If the event is fully billed, use the trans amount from event
                                   do not rederive the transaction amount */

                  /* Bug 3712615: Added abs to compare the absolute value of amounts.
                     Also added sign function since invproc bill amt will be -ve in case inv redn event */
		    IF NVL(abs(p_invproc_bill_amount),0) = NVL(abs(tmp_invproc_event_amount),0) THEN

			tmp_bill_trans_inv_amount := NVL(tmp_bill_trans_event_amount,0) *
                                                      sign(nvl(p_invproc_bill_amount,1)) * sign(nvl(tmp_bill_trans_event_amount,1));

		    ELSE
		  /* end of the bug fix 3548844 */
	            tmp_bill_trans_inv_amount := pa_multi_currency_billing.round_trans_currency_amt(
				        	 tmp_bill_trans_event_amount
				             * (NVL(p_invproc_bill_amount,0) /
				                NVL(tmp_invproc_event_amount,0) ) , tmp_bill_trans_currency_code);
		    END IF;  --- Added for bug 3548844

                end if;

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_bill_trans_inv_amount    : ' || tmp_bill_trans_inv_amount);
                END IF;

	        x_bill_trans_inv_amount := TO_CHAR(tmp_bill_trans_inv_amount);

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_bill_trans_inv_amount    : ' || tmp_bill_trans_inv_amount);
                END IF;

                if nvl(tmp_projfunc_currency_code,'0') = nvl(tmp_bill_trans_currency_code,'0') then

                   x_projfunc_bill_amount := x_bill_trans_inv_amount;

                else
		/* added for bug 2784321 */
                  if nvl(tmp_projfunc_currency_code,'0') = nvl(tmp_invproc_currency_code,'0') then
		   IF g1_debug_mode  = 'Y' THEN
		    PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'tmp_projfunc_currency_code <> tmp_bill_trans_currency_code AND tmp_projfunc_currency_code = tmp_invproc_currency_code');
		   END IF;

		       x_projfunc_bill_amount := p_invproc_bill_amount;
                  else
                	IF g1_debug_mode  = 'Y' THEN
                		PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'tmp_projfunc_currency_code <> tmp_bill_trans_currency_code');
                	END IF;

                   x_projfunc_bill_amount    := TO_CHAR ( pa_multi_currency_billing.round_trans_currency_amt(
					           NVL(tmp_projfunc_event_amount,0) *
				                   (NVL(tmp_bill_trans_inv_amount,0)/
					              NVL(tmp_bill_trans_event_amount,0)), tmp_projfunc_currency_code));
		  end if;/* Added for bug 2784321 */
                end if ;

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' x_projfunc_bill_amount    : ' || x_projfunc_bill_amount);
                END IF;


                if nvl(tmp_project_currency_code,'0') = nvl(tmp_bill_trans_currency_code,'0') then

                   x_project_bill_amount := x_bill_trans_inv_amount;

                elsif nvl(tmp_project_currency_code,'0') = nvl(tmp_projfunc_currency_code,'0') then

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' tmp_project_currency_code <> tmp_projfunc_currency_code');
                    END IF;

                   x_project_bill_amount := x_projfunc_bill_amount ;

                else

                   x_project_bill_amount     := TO_CHAR ( pa_multi_currency_billing.round_trans_currency_amt(
				                   NVL(tmp_project_event_amount,0) *
				                   (NVL(tmp_bill_trans_inv_amount,0)/
					              NVL(tmp_bill_trans_event_amount,0)), tmp_project_currency_code));

                end if;

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' x_project_bill_amount    : '|| x_project_bill_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Line Bill Trans Amount    : ' || tmp_bill_trans_inv_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_Project Amount : ' || x_project_bill_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_projfunc Amount:  ' || x_projfunc_bill_amount);
                END IF;

                if nvl(tmp_funding_currency_code,'0') = nvl(tmp_bill_trans_currency_code,'0') then

                   x_funding_currency_code := tmp_funding_currency_code;
                   x_funding_bill_amount := x_bill_trans_inv_amount;
                   x_funding_exchange_rate :=  NULL;
                   x_funding_rate_type :=  NULL;
                   x_funding_rate_date :=  NULL;

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'tmp_funding_currency_code = tmp_bill_trans_currency_code  ');
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'x_funding_bill_amount = ' || x_funding_bill_amount);
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'x_bill_trans_inv_amount = ' || x_bill_trans_inv_amount);
                   END IF;

                elsif nvl(tmp_funding_currency_code,'0') = nvl(tmp_projfunc_currency_code,'0') then

                   x_funding_currency_code := tmp_projfunc_currency_code;
                   x_funding_bill_amount := x_projfunc_bill_amount;
                   x_funding_exchange_rate :=  TO_CHAR(tmp_projfunc_inv_exch_rate);
                   x_funding_rate_type :=  tmp_projfunc_rate_type;
                   x_funding_rate_date :=  TO_CHAR(tmp_projfunc_inv_rate_date,'YYYY/MM/DD');

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'tmp_funding_currency_code = tmp_projfunc_currency_code  ');
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'x_funding_bill_amount = ' || x_funding_bill_amount);
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'x_projfunc_bill_amount = ' || x_projfunc_bill_amount);
                   END IF;

                elsif nvl(tmp_funding_currency_code,'0') = nvl(tmp_project_currency_code,'0') then

                   x_funding_currency_code := tmp_project_currency_code;
                   x_funding_bill_amount := x_project_bill_amount;
                   x_funding_exchange_rate :=  TO_CHAR(tmp_project_inv_exch_rate);
                   x_funding_rate_type :=  tmp_project_rate_type;
                   x_funding_rate_date :=  TO_CHAR(tmp_project_inv_rate_date,'YYYY/MM/DD');

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'tmp_funding_currency_code = tmp_project_currency_code  ');
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'x_funding_bill_amount = ' || x_funding_bill_amount);
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'x_project_bill_amount = ' || x_project_bill_amount);
                   END IF;

                else

	           x_funding_currency_code   := tmp_funding_currency_code;
	           tmp_bill_trans_currency_tab(1) := tmp_bill_trans_currency_code;
                   tmp_funding_currency_tab(1)    := tmp_funding_currency_code;
	           tmp_funding_rate_type_tab(1)      := tmp_funding_rate_type;
	           tmp_funding_rate_date_tab(1)      := nvl(tmp_funding_rate_date,TO_DATE(pa_billing.globvars.invoicedate,'YYYY/MM/DD'));
	           tmp_funding_exchange_rate_tab(1)  := tmp_funding_exchange_rate;
	           tmp_bill_trans_bill_amount_tab(1) := tmp_bill_trans_inv_amount;
	           tmp_funding_bill_amount_tab(1)    := 0;
                   tmp_status_tab(1)		  := 'N';
 	           tmp_denominator_tab(1)	          :=0;
                   tmp_numerator_tab(1)		  :=0;
                   tmp_user_validate_flag_tab(1)	  :='N';

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Call convert_amount_bulk Using :  ');
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'From Currency Code  :  ' || tmp_bill_trans_currency_code);
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || '  To Currency Code  :  ' || tmp_funding_currency_code);
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || '     Ex Rate Type   :  ' || tmp_funding_rate_type);
                        PA_MCB_INVOICE_PKG.log_message('     Ex Rate Date   :  ' ||
                           nvl(to_char(tmp_funding_rate_date, 'YYYY/MM/DD'), pa_billing.globvars.invoicedate));
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || '     Ex Rate        :  ' || tmp_funding_exchange_rate);
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || '     From Amount    :  ' || tmp_bill_trans_inv_amount);
                   END IF;

                   PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                     p_from_currency_tab 		=> tmp_bill_trans_currency_tab,
                     p_to_currency_tab   		=> tmp_funding_currency_tab,
                     p_conversion_date_tab		=> tmp_funding_rate_date_tab,
                     p_conversion_type_tab 	=> tmp_funding_rate_type_tab,
                     p_amount_tab         		=> tmp_bill_trans_bill_amount_tab,
                     p_user_validate_flag_tab 	=> tmp_user_validate_flag_tab,
                     p_converted_amount_tab        => tmp_funding_bill_amount_tab,
                     p_denominator_tab             => tmp_denominator_tab,
                     p_numerator_tab               => tmp_numerator_tab,
                     p_rate_tab                    => tmp_funding_exchange_rate_tab,
	             x_status_tab		        =>tmp_status_tab,
	             p_conversion_between		=> 'BTC_FC',
	             p_cache_flag			=> 'N');

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' After Convert_Bulk Call  ' );
                   END IF;

	           IF NVL(tmp_funding_bill_amount_tab(1),0) <> 0  THEN

                       IF g1_debug_mode  = 'Y' THEN
                       	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Assign Funding Amount ' );
                       END IF;
	               x_funding_bill_amount := TO_CHAR(tmp_funding_bill_amount_tab(1));

                       IF g1_debug_mode  = 'Y' THEN
                       	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Assign Funding Ex Date ' );
                       END IF;
	               --x_funding_rate_date := TO_CHAR(NVL(tmp_funding_rate_date_tab(1),SYSDATE));
	               x_funding_rate_date := TO_CHAR(tmp_funding_rate_date_tab(1),'YYYY/MM/DD');

                       IF g1_debug_mode  = 'Y' THEN
                       	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Assign Funding Ex Rate ' );
                       END IF;
	               -- x_funding_exchange_rate := TO_CHAR(round(tmp_funding_exchange_rate_tab(1),5));
	               x_funding_exchange_rate := TO_CHAR(tmp_funding_exchange_rate_tab(1));

                       IF g1_debug_mode  = 'Y' THEN
                       	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || ' Assign Funding Ex Rate type' );
                       END IF;
	               x_funding_rate_type := tmp_funding_rate_type_tab(1);
	               x_status_code  := 'N';
	           ELSE
	              x_funding_bill_amount :=0 ;
	              x_status_code  := 'Y';
	           END IF;

                END IF;

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_Funding Amount : ' || x_funding_bill_amount);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_Funding Rate   : ' || x_funding_exchange_rate);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_Funding Rate type  : ' || x_funding_rate_type);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_Funding Rate Date  : ' || x_funding_rate_date);
                	PA_MCB_INVOICE_PKG.log_message('Convert_Line_Event_Amount: ' || 'Convert_Line_Funding Status : ' || x_status_code);
                END IF;

	END;
EXCEPTION

     WHEN OTHERS THEN
        x_project_bill_amount   := NULL; --NOCOPY
        x_projfunc_bill_amount  := NULL; --NOCOPY
        x_funding_currency_code := NULL; --NOCOPY
        x_funding_bill_amount  := NULL; --NOCOPY
 	x_funding_rate_date  := NULL; --NOCOPY
        x_funding_exchange_rate := NULL; --NOCOPY
        x_funding_rate_type   := NULL; --NOCOPY
        x_bill_trans_inv_amount := NULL; --NOCOPY
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Convert_line_event_amount' || sqlerrm);
          END IF;
          x_return_status := sqlerrm( sqlcode );

          -- RAISE;
END Convert_Line_Event_Amount;
-- Check whether the btc can be converted to FC

PROCEDURE Check_Funding_Conv_Attributes (
                                p_funding_currency_code  IN VARCHAR2 ,
                                p_bill_trans_currency_code IN VARCHAR2 ,
                                p_bill_trans_bill_amount   IN VARCHAR2 ,
                                p_funding_rate_type        IN VARCHAR2 ,
                                p_funding_rate_date        IN VARCHAR2,
                                p_funding_exchange_rate    IN VARCHAR2,
                                x_funding_bill_amount      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_status_code              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status            IN OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

tmp_denominator_tab             PA_PLSQL_DATATYPES.NumTabTyp;
tmp_numerator_tab               PA_PLSQL_DATATYPES.NumTabTyp;
tmp_rate_tab                    PA_PLSQL_DATATYPES.NumTabTyp;
tmp_user_validate_flag_tab      PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_bill_amount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
tmp_funding_rate_type_tab       PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_rate_date_tab       PA_PLSQL_DATATYPES.DateTabTyp;
tmp_funding_exchange_rate_tab   PA_PLSQL_DATATYPES.NumTabTyp;
tmp_bill_trans_bill_amount_tab  PA_PLSQL_DATATYPES.NumTabTyp;
tmp_bill_trans_currency_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_status_tab                	PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_funding_currency_tab        PA_PLSQL_DATATYPES.Char30TabTyp;

BEGIN

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes');
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || 'Bill Trans Currency :  ' || p_bill_trans_currency_code);
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || 'Bill Trans Amount   :  ' || p_bill_trans_bill_amount);
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || 'Funding Currency    :  ' || p_funding_currency_code);
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || '       Rate Type    :  ' || p_funding_rate_type);
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || '      Rate Date     :  ' || p_funding_rate_date);
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || '           Rate     :  ' || p_funding_exchange_rate);
        END IF;

	tmp_bill_trans_currency_tab(1)    := p_bill_trans_currency_code;
	tmp_bill_trans_bill_amount_tab(1) := p_bill_trans_bill_amount;
        tmp_funding_currency_tab(1)       := p_funding_currency_code;
	tmp_funding_rate_type_tab(1)      := p_funding_rate_type;
	tmp_funding_rate_date_tab(1)      := TO_DATE(p_funding_rate_date,'YYYY/MM/DD');
	tmp_funding_exchange_rate_tab(1)  := TO_NUMBER(p_funding_exchange_rate);
	tmp_funding_bill_amount_tab(1)    := 0;
        tmp_status_tab(1)		  := 'N';
 	tmp_denominator_tab(1)	          :=0;
        tmp_numerator_tab(1)		  :=0;
        tmp_user_validate_flag_tab(1)	  :='N';

        PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
          p_from_currency_tab 		=> tmp_bill_trans_currency_tab,
          p_to_currency_tab   		=> tmp_funding_currency_tab,
          p_conversion_date_tab		=> tmp_funding_rate_date_tab,
          p_conversion_type_tab 	=> tmp_funding_rate_type_tab,
          p_amount_tab         		=> tmp_bill_trans_bill_amount_tab,
          p_user_validate_flag_tab 	=> tmp_user_validate_flag_tab,
          p_converted_amount_tab        => tmp_funding_bill_amount_tab,
          p_denominator_tab             => tmp_denominator_tab,
          p_numerator_tab               => tmp_numerator_tab,
          p_rate_tab                    => tmp_funding_exchange_rate_tab,
	  x_status_tab		        => tmp_status_tab,
	  p_conversion_between		=> 'BTC_FC',
	  p_cache_flag			=> 'N');

--	  IF   tmp_funding_bill_amount_tab(1) <> 0 THEN /*Commented for bug 6161196 */
	  IF   tmp_status_tab(1) = 'N' THEN /*Added for bug 6161196 */
	    x_funding_bill_amount := TO_CHAR(tmp_funding_bill_amount_tab(1));
	    x_status_code    :='N';
	  ELSE
	    x_funding_bill_amount :=0 ;
	    x_status_code    :='Y';
	  END IF;
        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || 'Funding Tab Amount   :     ' || tmp_funding_bill_amount_tab(1));
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || 'Funding Amount   :     ' || x_funding_bill_amount);
        	PA_MCB_INVOICE_PKG.log_message('Check_Funding_Conv_Attributes: ' || '      Status     :     ' || x_status_code);
        END IF;

EXCEPTION

  When Others Then
          x_funding_bill_amount := NULL; --NOCOPY
          IF g1_debug_mode  = 'Y' THEN
          	PA_MCB_INVOICE_PKG.log_message('Error in Check_funding_conv_attributes ' || sqlerrm);
          END IF;
          x_return_status := sqlerrm( sqlcode );

END Check_Funding_Conv_Attributes;

PROCEDURE log_message (p_log_msg IN VARCHAR2) IS
BEGIN
pa_debug.write_file ('LOG',to_char(sysdate, 'YYYY/MM/DD HH:MI:SS ')||p_log_msg);
NULL;
END log_message;
PROCEDURE Init (P_DEBUG_MODE VARCHAR2) IS
BEGIN
G_LAST_UPDATE_LOGIN := fnd_global.login_id;
G_REQUEST_ID := fnd_global.conc_request_id;
G_PROGRAM_APPLICATION_ID := fnd_global.prog_appl_id;
G_PROGRAM_ID := fnd_global.conc_program_id;
G_LAST_UPDATED_BY := fnd_global.user_id;
G_CREATED_BY :=  fnd_global.user_id;
G_DEBUG_MODE := 'Y';
pa_debug.init_err_stack ('Invoice Generation');
pa_debug.set_process(
            x_process => 'PLSQL',
            x_debug_mode => G_DEBUG_MODE);

pa_debug.G_Err_Stage :=' Start PLSQL Error ';
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Init: ' || pa_debug.G_Err_Stage);
END IF;


END Init;
--==================================================================================
--Introduced for the Bug 4146846
---Procedure cal_conversion_attr
--Assigns the AR Conversion Attributes depending on IPC,PFC and USe PFC flag
--Behaves similar to the case when BTC is not checked
--==================================================================================
Procedure Cal_Conversion_Attr (p_project_id 			IN NUMBER,
			       p_draft_invoice_num 		IN NUMBER,
			       p_use_pfc_flag                   IN VARCHAR2,
			       p_pfc_currency_code              IN VARCHAR2,
			       p_pfc_ex_rate                    IN NUMBER,
			       p_pfc_ex_rate_date_code          IN VARCHAR2,
			       p_pfc_rate_type                  IN VARCHAR2,
			       p_pfc_rate_date                  IN DATE,
			       p_invproc_currency_code          IN VARCHAR2,
			       p_inv_ex_rate 			IN NUMBER,
			       p_inv_rate_type			IN VARCHAR2,
			       p_inv_rate_date			IN DATE,
			       p_btc_currency_code 		IN VARCHAR2,
			       p_bill_thru_date			IN DATE,
			       x_status				OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
-- Declared the cursor for the Bug 4298230 to fetch the lookup meaning
CURSOR reject_reason (reject_code VARCHAR2) IS
      SELECT lu.meaning
        FROM pa_lookups lu
       WHERE lu.lookup_type = 'INVOICE DISTRIBUTION WARNING'
         AND lu.lookup_code = reject_code;

-- Bug : 4298230  Added the following parameters for the call to PA_MULTI_CURRENCY_BILLING.convert_amount_bulk
l_reject_reason_meaning       VARCHAR2(500);
l_invoice_date                DATE := pa_billing.GetInvoiceDate;
tmp_pfc_currency_code_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_btc_currency_code_tab     PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_bill_trans_amount_tab     PA_PLSQL_DATATYPES.NumTabTyp;
tmp_denominator_tab           PA_PLSQL_DATATYPES.NumTabTyp;
tmp_numerator_tab             PA_PLSQL_DATATYPES.NumTabTyp;
tmp_rate_tab                  PA_PLSQL_DATATYPES.NumTabTyp;
tmp_status_tab                PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_bill_trans_rate_type_tab  PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_bill_trans_rate_date_tab  PA_PLSQL_DATATYPES.DateTabTyp;
tmp_projfunc_rate_type_tab    PA_PLSQL_DATATYPES.Char30TabTyp;
tmp_projfunc_rate_date_tab    PA_PLSQL_DATATYPES.DateTabTyp;
tmp_user_validate_flag_tab    PA_PLSQL_DATATYPES.Char30TabTyp;

l_sum_projfunc_bill_amount    NUMBER;			--Added For Bug 6084445
l_sum_inv_amount              NUMBER;			--Added For Bug 6084445

l_rate                        NUMBER; -- Bug#5762081


BEGIN

-- Bug 4298230 Initilaized the variables

tmp_btc_currency_code_tab(1) := p_btc_currency_code;
tmp_pfc_currency_code_tab(1) := p_pfc_currency_code;
tmp_bill_trans_amount_tab(1) := null;
tmp_denominator_tab(1)       := null;
tmp_numerator_tab(1)         := null;
tmp_rate_tab(1) 	     := null;
tmp_status_tab(1)	     := null;
tmp_bill_trans_rate_type_tab(1) := null;
tmp_bill_trans_rate_date_tab(1) := null;
tmp_projfunc_rate_type_tab(1)   := null;
tmp_projfunc_rate_date_tab(1)   := null;
tmp_user_validate_flag_tab(1)   := 'N';



   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: add for bug 5762081 ');
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_project_id '|| to_char(p_project_id) );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_draft_invoice_num '|| to_char(p_draft_invoice_num) );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_use_pfc_flag '|| p_use_pfc_flag );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_pfc_currency_code '|| p_pfc_currency_code);
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_pfc_ex_rate '|| to_char(p_pfc_ex_rate) );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_pfc_ex_rate_date_code '|| p_pfc_ex_rate_date_code);
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_pfc_rate_type '|| p_pfc_rate_type);
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_pfc_rate_date  '|| to_char(p_pfc_rate_date,'DD-MON-YYYY' ) );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_invproc_currency_code  '|| p_invproc_currency_code );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_inv_ex_rate '|| to_char(p_inv_ex_rate) );

   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_inv_rate_type  '|| p_inv_rate_type );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_inv_rate_date  '|| to_char(p_inv_rate_date,'DD-MON-YYYY' ));
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_btc_currency_code  '|| p_btc_currency_code );
   PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' p_bill_thru_date  '|| to_char(p_bill_thru_date,'DD-MON-YYYY' ));



IF  (p_btc_currency_code = p_pfc_currency_code)
   THEN
--CASE : BTC=PFC:e.g IPC=GBP, PFC=BTC=USD or IPC=PFC=BTC=USD  : Here we donot need AR attributes as the Inv currency is in terms of PFC

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' if  (p_invproc_currency_code = p_btc_currency_code) AND (p_btc_currency_code = p_pfc_currency_code)');
	END IF;
        X_Status  := NULL;

        UPDATE pa_draft_invoices_all
        SET    projfunc_invtrans_rate_type      = NULL
              ,projfunc_invtrans_rate_date      = NULL
              ,projfunc_invtrans_ex_rate     	= NULL
        WHERE project_id             		= p_project_id
        AND   draft_invoice_num      		= p_draft_invoice_num;

ELSIF (p_invproc_currency_code <> p_pfc_currency_code)  THEN

--CASE : BTC<>IPC<>PFC or BTC=IPC<>PFC :Check for Use PFC for Receviabled Flag  :e.g::e.g IPC=GBP, PFC=USD BTC=DKK
--e.g : IPC=GBP,BTC=GBP,PFC=USD

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: ' || ' iF  (p_invproc_currency_code <>  p_pfc_currency_code) THEN ');
	END IF;

	IF p_use_pfc_flag <> 'Y' then   --USE PFC FLAG CHECK

 	--The projfunc_inv_trans_rate derived in the procedure Inv_by_Bill_trans_Currency remains as it is
	-- We are going to use the same as derived rate with Rate Type ='User and Date= InvoiceDate

    	  UPDATE pa_draft_invoices_all
          SET    projfunc_invtrans_rate_type      = 'User'
                ,projfunc_invtrans_rate_date      = l_invoice_date
          WHERE project_id                        = p_project_id
          AND   draft_invoice_num                 = p_draft_invoice_num;

        ELSE -- If p_use_pfc_flag  ='Y' Then use PFC attributes

	       tmp_rate_tab(1)  := p_inv_ex_rate; -- Bug 4298230

	     	SELECT   NVL(sum(dii.bill_trans_bill_amount),0)
	         INTO 	  tmp_bill_trans_amount_tab(1)
	         FROM    pa_draft_invoice_items dii
	         WHERE    dii.project_id = p_project_id
	           AND    dii.draft_invoice_num = p_draft_invoice_num
	           AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
	     	   AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
	     	   AND    dii.invoice_line_type <> 'RETENTION';

	          tmp_projfunc_rate_type_tab(1) := p_pfc_rate_type; -- bug 4298230
                  tmp_projfunc_rate_date_tab(1) := l_invoice_date; --Bug 4298230


PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
 		p_from_currency_tab           => tmp_pfc_currency_code_tab  ,
		p_to_currency_tab             =>  tmp_btc_currency_code_tab,
                p_conversion_date_tab         =>  tmp_projfunc_rate_date_tab,
		p_conversion_type_tab         =>  tmp_projfunc_rate_type_tab,
                p_amount_tab                  =>  tmp_bill_trans_amount_tab,
                p_user_validate_flag_tab      =>  tmp_user_validate_flag_tab,
		p_converted_amount_tab        =>   tmp_bill_trans_amount_tab,
                p_denominator_tab             =>   tmp_denominator_tab,
                p_numerator_tab               =>  tmp_numerator_tab,
		p_rate_tab                    =>  tmp_rate_tab,
		x_status_tab                  =>  tmp_status_tab,
		p_conversion_between          =>  'PFC_BT',
          	p_cache_flag                  =>  'N');

-- Added the below code for Bug 4298230

    IF tmp_status_tab(1) = 'PA_NO_EXCH_RATE_EXISTS_PFC_BT' THEN

	OPEN reject_reason (tmp_status_tab(1));
        FETCH reject_reason INTO l_reject_reason_meaning;
        CLOSE reject_reason;

         UPDATE pa_draft_invoices_all
 	     SET generation_error_flag = 'Y',
                 TRANSFER_REJECTION_REASON = l_reject_reason_meaning
           WHERE project_id             = p_project_id
             AND draft_invoice_num      = p_draft_invoice_num;

     ELSE

	  UPDATE pa_draft_invoices_all
	     SET  projfunc_invtrans_rate_type =   p_pfc_rate_type
	         ,projfunc_invtrans_rate_date = DECODE(p_pfc_ex_rate_date_code,'PA_INVOICE_DATE',
	            				tmp_projfunc_rate_date_tab(1),p_pfc_rate_date)
	              ,projfunc_invtrans_ex_rate   = DECODE(p_pfc_ex_rate_date_code,'PA_INVOICE_DATE',
	              					tmp_rate_tab(1), p_pfc_ex_rate )
	    WHERE project_id             = p_project_id
	      AND draft_invoice_num      = p_draft_invoice_num;

      END IF; -- End of IF for Bug 4298230

	   END IF; -- of p_use_pfc_flag case
 ELSE --IPC=PFC
  IF  (p_invproc_currency_code <> p_btc_currency_code) AND (p_invproc_currency_code = p_pfc_currency_code) THEN

  --CASE: PFC=IPC<>BTC   e.g :IPC=PFC=USD , BTC=GBP

	IF g1_debug_mode  = 'Y' THEN
		PA_MCB_INVOICE_PKG.log_message('cal_conversion_Attr ' || ' (p_invproc_currency_code <> p_btc_currency_code) AND (p_invproc_currency_code = p_pfc_currency_code) ');

          PA_MCB_INVOICE_PKG.log_message('cal_conversion_Attr: ' || 'Invoice Transaction Rate is based on p_use_pfc_flag  '); -- 5762081
	END IF;


   /* Begin Bug#5762081 */

    IF p_use_pfc_flag <> 'Y' then


          PA_MCB_INVOICE_PKG.log_message('cal_conversion_Attr: ' || ' p_use_pfg_flag is not equal to Y ');
          PA_MCB_INVOICE_PKG.log_message('cal_conversion_Attr: ' || ' update invtrans_rate details as User ');

        --The projfunc_inv_trans_rate derived in the procedure Inv_by_Bill_trans_Currency remains as it is
        -- We are going to use the same as derived rate with Rate Type ='User and Date= InvoiceDate

	/*Start of code change for Bug 6084445*/

	SELECT sum(NVL(dii.projfunc_bill_amount,0))
	INTO l_sum_projfunc_bill_amount
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
	 AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
         AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
         AND    dii.invoice_line_type <> 'RETENTION'
	 AND  dii.draft_invoice_num = p_draft_invoice_num;

	SELECT sum(NVL(dii.bill_trans_bill_amount,0))
	INTO l_sum_inv_amount
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
	 AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
         AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
         AND    dii.invoice_line_type <> 'RETENTION'
	AND  dii.draft_invoice_num = p_draft_invoice_num;


	IF l_sum_projfunc_bill_amount <> 0 AND l_sum_inv_amount <> 0
	THEN
		SELECT sum(NVL(dii.bill_trans_bill_amount,0))/sum(NVL(dii.projfunc_bill_amount,0))
		INTO l_rate
		FROM pa_draft_invoice_items dii
		WHERE dii.project_id = P_Project_Id
		 AND  dii.draft_invoice_num = p_draft_invoice_num
		 AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
                 AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
                 AND    dii.invoice_line_type <> 'RETENTION'
		 having  sum(nvl(dii.projfunc_bill_amount,0)) <> 0;
         ELSE
	 /* Added begin and end to handle the exception for bug 8666892  */
  	    BEGIN

		SELECT NVL(dii.bill_trans_bill_amount,0)/NVL(dii.projfunc_bill_amount,0)
		INTO l_rate
		FROM pa_draft_invoice_items dii
		WHERE dii.project_id = P_Project_Id
		 AND  dii.draft_invoice_num = p_draft_invoice_num
		 AND  nvl(dii.projfunc_bill_amount,0) <> 0
		 AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
                 AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
                 AND    dii.invoice_line_type <> 'RETENTION'
		 AND  rownum=1;
		 	    EXCEPTION
		WHEN OTHERS THEN
			l_rate := 0;
	    END;

	 END IF;
	/* End of code change for Bug 6084445 */

/* Commented for Bug 6084445 Start
        SELECT   NVL(sum(dii.bill_trans_bill_amount),0) / nvl(sum(dii.projfunc_bill_amount),0)
          INTO    l_rate
          FROM    pa_draft_invoice_items dii
         WHERE    dii.project_id = p_project_id
           AND    dii.draft_invoice_num = p_draft_invoice_num
           AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
           AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
           AND    dii.invoice_line_type <> 'RETENTION';
Commented for Bug 6084445 End */

         UPDATE  pa_draft_invoices_all
            SET  projfunc_invtrans_rate_type      = 'User'
                ,projfunc_invtrans_rate_date      = NVL(l_invoice_date,p_bill_thru_date)
                ,projfunc_invtrans_ex_rate        = l_rate
          WHERE project_id                        = p_project_id
          AND   draft_invoice_num                 = p_draft_invoice_num;


   ELSE    /* End Bug#5762081 */


      PA_MCB_INVOICE_PKG.log_message('cal_conversion_Attr: ' || 'Before the Select statement  ');

     	SELECT   NVL(sum(dii.bill_trans_bill_amount),0)
          INTO 	  tmp_bill_trans_amount_tab(1)
          FROM    pa_draft_invoice_items dii
         WHERE    dii.project_id = p_project_id
           AND    dii.draft_invoice_num = p_draft_invoice_num
           AND    dii.invoice_line_type  in ('STANDARD','INVOICE REDUCTION')
     	   AND    dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
     	   AND    dii.invoice_line_type <> 'RETENTION';

	tmp_bill_trans_rate_date_tab(1) :=NVL(p_inv_rate_date,NVL(l_invoice_date,p_bill_thru_date)); -- Bug 4298230

	--Converting the PFC to BTC as per Rate Types and DAtes defined in Ct. Screen
	tmp_rate_tab(1) := p_inv_ex_rate; --Bug 4298230
	tmp_bill_trans_rate_type_tab(1) := p_inv_rate_type; --Bug 4298230

PA_MULTI_CURRENCY_BILLING.convert_amount_bulk (
                p_from_currency_tab           =>  tmp_pfc_currency_code_tab  ,
                p_to_currency_tab             =>  tmp_btc_currency_code_tab,
                p_conversion_date_tab         =>  tmp_bill_trans_rate_date_tab,
                p_conversion_type_tab         =>  tmp_bill_trans_rate_type_tab,
                p_amount_tab                  =>  tmp_bill_trans_amount_tab,
                p_user_validate_flag_tab      =>  tmp_user_validate_flag_tab,
                p_converted_amount_tab        =>   tmp_bill_trans_amount_tab,
                p_denominator_tab             =>   tmp_denominator_tab,
                p_numerator_tab               =>  tmp_numerator_tab,
                p_rate_tab                    =>  tmp_rate_tab,
                x_status_tab                  =>  tmp_status_tab,
                p_conversion_between          =>  'PFC_BT',
                p_cache_flag                  =>  'N');

-- Added the below code for Bug 4298230

	IF g1_debug_mode  = 'Y' THEN
          PA_MCB_INVOICE_PKG.log_message('cal_conversion_attr: status :: '||tmp_status_tab(1));
        END IF;

       IF tmp_status_tab(1) = 'PA_NO_EXCH_RATE_EXISTS_PFC_BT' THEN

	    OPEN reject_reason (tmp_status_tab(1));
           FETCH reject_reason INTO l_reject_reason_meaning;
	   CLOSE reject_reason;

          UPDATE pa_draft_invoices_all
             SET generation_error_flag = 'Y',
                 TRANSFER_REJECTION_REASON = l_reject_reason_meaning
           WHERE project_id             = p_project_id
             AND draft_invoice_num      = p_draft_invoice_num;

      ELSE

	  UPDATE pa_draft_invoices_all
             SET projfunc_invtrans_rate_type  = p_inv_rate_type
              	  ,projfunc_invtrans_rate_date = NVL(p_inv_rate_date,NVL(l_invoice_date,p_bill_thru_date))
              	  ,projfunc_invtrans_ex_rate   = NVL(p_inv_ex_rate,tmp_rate_tab(1))
           WHERE project_id         = p_project_id
             AND draft_invoice_num  = p_draft_invoice_num;

     END IF; -- End of IF added for the Bug 4298230

   END IF;  --  Bug#5762081

   END IF;
END IF;
x_status := 'Y';

EXCEPTION
    WHEN OTHERS
    THEN
   IF g1_debug_mode  = 'Y' THEN
   	PA_MCB_INVOICE_PKG.log_message('cal_Conversion_Attr: ' || ' Sql Error : ' || sqlerrm);
   END IF;
         RAISE;
END Cal_Conversion_Attr;

--====================================================
-- Procedure Invoice_by_Bill_Trans_Currency
-- This procedure will be called only if the project is invoice by
-- bill transaction currency setup.
-- Procedure will split the invoice by grouping BTC and
-- renumber the draft invoice num, line num
-- and also update the RDLs, ERDLs

PROCEDURE Inv_by_Bill_Trans_Currency(
				p_project_id	IN	NUMBER,
				p_request_id	IN	NUMBER,
                                x_return_status  IN OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

-- This structure is used to track the header information

TYPE inv_header IS RECORD
			(current_draft_invoice_num 	NUMBER,
			 inv_currency_code 		VARCHAR2(15),
			 new_draft_invoice_num		NUMBER,
			 action_flag	 		VARCHAR2(1),
			 retention_percentage		NUMBER
			);


-- This structure is used to track the invoice line information

TYPE inv_line IS RECORD
			(current_draft_invoice_num NUMBER,
			 current_line_Num	   NUMBER,
			 bill_trans_currency_code VARCHAR2(15),
			 event_num 		  NUMBER,
			 revenue_amount 	 NUMBER,
			 new_draft_invoice_num	   NUMBER,
			 new_line_num	   		NUMBER
			);

TYPE InvLinesTab IS TABLE OF inv_line
  INDEX BY BINARY_INTEGER;

TYPE InvHeadersTab IS TABLE OF inv_header
  INDEX BY BINARY_INTEGER;

-- Cursor to select the invoice which is created by current request id
-- and should not be the Cancel invoice, not be the credit memo

CURSOR cur_inv IS
	SELECT 	di.agreement_id,
		di.draft_invoice_num,
		di.retention_percentage,
		dii.line_num,
		dii.bill_trans_currency_code,
		dii.invoice_line_type,
		NVL(dii.event_num,0) event_num,
		NVL(evt.revenue_amount,0) revenue_amount
       	FROM pa_draft_invoices_all di,
	     pa_draft_invoice_items dii,
	     pa_events evt
      WHERE di.project_id = p_project_id
         AND di.project_id = dii.project_id
         AND dii.request_id = p_request_id
	 AND di.request_id = p_request_id
	 AND di.draft_invoice_num = dii.draft_invoice_num
	 AND NVL(di.canceled_flag,'N') <> 'Y'
	 AND NVL(di.cancel_credit_memo_flag,'N') <>'Y'
	 AND dii.draft_inv_line_num_credited IS NULL
	 AND dii.event_num = evt.event_num(+)
	 AND dii.project_id = evt.project_id(+)
	 AND NVL(dii.event_task_id,-99) = NVL(evt.task_id(+),-99)
	 AND dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
	 AND dii.invoice_line_type <> 'RETENTION'
	ORDER BY di.draft_invoice_num,dii.bill_trans_currency_code,dii.line_num;

/* Cursor added for Bug 3062595 */
CURSOR cur_cm IS
        SELECT   di.draft_invoice_num,
                 di.draft_invoice_num_credited,
                 dii.line_num
        FROM     pa_draft_invoices_all di, pa_draft_invoice_items dii
        WHERE    di.project_id = p_project_id
        AND      di.request_id = p_request_id
        AND      dii.project_id= di.project_id
        AND      dii.draft_invoice_num = di.draft_invoice_num
        AND      di.draft_invoice_num_credited IS NOT NULL
        AND      nvl(di.write_off_flag,'N') <> 'Y'
        AND      nvl(di.cancel_credit_memo_flag,'N') <> 'Y'
        ORDER BY di.drafT_invoice_num;

--For Bug 4146846
CURSOR c_project_details IS
	  SELECT projfunc_attr_for_ar_flag,
	  	 projfunc_currency_code,
		 projfunc_bil_exchange_rate,
	         projfunc_bil_rate_date_code,
	         projfunc_bil_rate_type,
	         projfunc_bil_rate_date,
	         project_currency_code,
	         invproc_currency_type
	  FROM   pa_projects_all
  WHERE  project_id = P_Project_Id;

--End of Bug fix 4146846

TmpInvLines    InvLinesTab;
TmpInvHeaders  InvHeadersTab;

previous_btc      	VARCHAR2(15);
previous_invoice_num 	NUMBER:=0;
split_invoice      	BOOLEAN:=TRUE;
i		  	BINARY_INTEGER:=0;
J		  	BINARY_INTEGER:=1;

last_invoice_num	NUMBER:=10;
last_line_num	  	NUMBER:=0;
current_invoice_num 	NUMBER:=0;
current_line_num	NUMBER:=0;
new_invoice_num 	NUMBER:=0;
new_line_num	  	NUMBER:=0;
l_projfunc_invtrans_rate NUMBER:=0;
l_inv_amount 		NUMBER:=0;
l_pfc_amount 		NUMBER:=0;
l_ret_line_num		NUMBER:=0;
l_fc_amount 		NUMBER:=0;
l_pc_amount 		NUMBER:=0;
l_btc_amount 		NUMBER:=0;

l_sum_projfunc_bill_amount NUMBER:=0;

--For Bug 4146846 :Added following variables
  l_invoice_date DATE := pa_billing.GetInvoiceDate;
  l_use_pfc_flag  VARCHAR2(1);
  l_projfunc_exchange_rate          NUMBER;
  l_projfunc_exchg_rate_type	    VARCHAR2(30);
  l_projfunc_exchg_rate_date	    Date;
  l_pfc_exchg_rate_date_code        VARCHAR2(50);
  l_bill_trans_currency_code        VARCHAR2(50);
  l_pfc_currency_code               VARCHAR2(50);
  l_project_currency_code	    VARCHAr2(50);
  l_invproc_currency_type           VARCHAR2(50);
  l_funding_currency_code	    VARCHAR2(30);
  l_invproc_currency_code	    VARCHAR2(30);
  l_inv_rate_date  		    DATE;
  l_inv_rate_type  		    VARCHAR2(30);
  l_inv_rate        		    NUMBER;
  l_ret_status 			    VARCHAR2(30);
  l_bill_thru_date		    DATE;
  l_customer_id			    NUMBER;
--End of bug fix

  l_head_inv_exch_rate              NUMBER := 1;  /* Added for bug 4735682 */
  l_head_inv_curr_code              VARCHAR2(50); /* Added for bug 4735682 */
  inv_num_cached                    NUMBER := -1; /* Added for bug 4735682 */
  l_calc_inv_amount                 NUMBER := 0;  /* Added for bug 4995695 */
  l_sum_inv_amount                  NUMBER; /*Added For Bug 5346566*/


BEGIN
        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Entering Invoice By Bill Transaction Currency API Type ');
        END IF;
	TmpInvLines.delete;
	TmpInvHeaders.delete;


        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Request Id : ' || p_request_id);
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Project id : ' || p_project_id);
        END IF;
/*For bug 4146846 -a) Obtaining the PFC attributes for the project one time
                   b) Determing the IPC currency code */

OPEN c_project_details;
FETCH c_project_details INTO l_use_pfc_flag,
			     l_pfc_currency_code,
			     l_projfunc_exchange_rate,
			     l_pfc_exchg_rate_date_code,
			     l_projfunc_exchg_rate_type,
			     l_projfunc_exchg_rate_date,
			     l_project_currency_code,
			     l_invproc_currency_type;

CLOSE c_project_details;


  IF l_invproc_currency_type ='PROJECT_CURRENCY' THEN

	l_invproc_currency_code := l_project_currency_code;

  ELSIF l_invproc_currency_type ='PROJFUNC_CURRENCY' THEN

	l_invproc_currency_code := l_pfc_currency_code;

  ELSIF l_invproc_currency_type ='FUNDING_CURRENCY' THEN

	SELECT	funding_currency_code
        INTO	l_funding_currency_code
	FROM	pa_summary_project_fundings
	WHERE	project_id  = p_project_id
        AND	rownum=1
	AND	NVL(total_baselined_amount,0) > 0;

	l_invproc_currency_code := l_funding_currency_code;

  END IF;

/*End of bug fix*/
/* Bug 3062595 - Fix Starts here */
        -- Credit memo processing is done here
        FOR cm_rec IN cur_cm LOOP

               IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: Credit memo processing ');
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: Invoice number : ' || cm_rec.draft_invoice_num);
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: Line number : ' || cm_rec.line_num);
               END IF;

/* Start of bug 4735682 */
               IF cm_rec.draft_invoice_num <> inv_num_cached THEN
                 inv_num_cached := cm_rec.draft_invoice_num;

                 select nvl(da.INV_EXCHANGE_RATE, 1), da.INV_CURRENCY_CODE
                   into l_head_inv_exch_rate, l_head_inv_curr_code
                   from pa_draft_invoices_all da
                  where project_id = p_project_id
                    and draft_invoice_num = inv_num_cached;

                 IF g1_debug_mode  = 'Y' THEN
                  PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: Exchange rate retrival');
                  PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: Using currency code: ' || l_head_inv_curr_code);
                  PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: Using exchange rate: ' || l_head_inv_exch_rate);
                 END IF;
               END IF;
/* Bug 4735682 ends */

/* Bug 4735682: Following update clause altered to include the exchange rate *

/* Commented and rewritten for bug 4735682
               UPDATE pa_draft_invoice_items dii
               SET    dii.inv_amount =
                        (SELECT sum(nvl(rdl.bill_trans_bill_amount, 0)) FROM pa_cust_rev_dist_lines_all rdl
                         WHERE rdl.project_id                  = dii.project_id
                         AND   rdl.draft_invoice_num           = dii.draft_invoice_num
                         AND   rdl.draft_invoice_item_line_num = dii.line_num)
               WHERE dii.project_id        = p_project_id
               AND   dii.draft_invoice_num = cm_rec.draft_invoice_num
               AND   dii.line_num          = cm_rec.line_num
               AND   dii.invoice_line_type = 'STANDARD';
 */
 /* Select query for bug 4735682 brought out to comply with 8i.. bug 4995695 */

                SELECT sum(nvl(rdl.bill_trans_bill_amount, 0)) * l_head_inv_exch_rate
                 INTO l_calc_inv_amount
                 FROM pa_cust_rev_dist_lines_all rdl
                WHERE rdl.project_id                  = p_project_id
                  AND rdl.draft_invoice_num           = inv_num_cached
                  AND rdl.draft_invoice_item_line_num = cm_rec.line_num;

 /* End of bug 4735682 .. bug 4995695 */

/* Bug 4995695.. modified the query for compatibility with 8i */

               UPDATE pa_draft_invoice_items dii
               SET    dii.inv_amount =
                        PA_MULTI_CURRENCY_BILLING.ROUND_TRANS_CURRENCY_AMT(l_calc_inv_amount, l_head_inv_curr_code)
               WHERE dii.project_id        = p_project_id
               AND   dii.draft_invoice_num = cm_rec.draft_invoice_num
               AND   dii.line_num          = cm_rec.line_num
               AND   dii.invoice_line_type = 'STANDARD';

               UPDATE pa_draft_invoice_items dii
               SET    inv_amount = bill_trans_bill_amount
               WHERE dii.project_id        = p_project_id
               AND   dii.draft_invoice_num = cm_rec.draft_invoice_num
               AND   dii.line_num          = cm_rec.line_num
               AND   dii.invoice_line_type = 'RETENTION';

        END LOOP;
/* Bug 3062595 - Fix Ends here */

	-- Get the last invoice number
	BEGIN
		SELECT NVL(MAX(draft_invoice_num),0) INTO Last_invoice_num
	  	FROM pa_draft_invoices_all
	 	WHERE project_id = p_project_id;
	END;
        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Max Invoice Number:  ' || Last_invoice_num);
         	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Befor the cur_inv Loop .....');
         END IF;


	FOR inv_rec IN cur_inv LOOP

                    IF g1_debug_mode  = 'Y' THEN
                    	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Inside the cursor cur_inv Loop .....');
                    END IF;

		IF inv_rec.draft_invoice_num <> NVL(previous_invoice_num,0) THEN
		   		-- Reset the previous values

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Inside the din <> Prvs_din If ....');
                   END IF;

		    		previous_btc :=inv_rec.bill_trans_currency_code;
		    		previous_invoice_num :=inv_rec.draft_invoice_num;
				split_invoice :=FALSE;
				last_line_num := 0 ;
				i := i+1;
				TmpInvHeaders(i).new_draft_invoice_num :=inv_rec.draft_invoice_num;
				TmpInvHeaders(i).current_draft_invoice_num :=inv_rec.draft_invoice_num;
				TmpInvHeaders(i).inv_currency_code:=inv_rec.bill_trans_currency_code;
				TmpInvHeaders(i).action_flag:='U';
				TmpInvHeaders(i).retention_percentage:= inv_rec.retention_percentage;
		END IF;

		current_invoice_num := inv_rec.draft_invoice_num;
		new_invoice_num := inv_rec.draft_invoice_num;

		current_line_num := inv_rec.line_num;
		new_line_num := inv_rec.line_num;


		IF inv_rec.bill_trans_currency_code <> previous_btc THEN

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Inside the BTC <> Prvs_btc If .....');
                   END IF;

			-- If the bill transaction changes
			-- Create new invoice
			-- Reset the invoice line num
			i := i+1;
			last_line_num  	:= 0;
		    	previous_btc :=inv_rec.bill_trans_currency_code;
			split_invoice :=TRUE;
			last_invoice_num := last_invoice_num +1;
			TmpInvHeaders(i).new_draft_invoice_num :=last_invoice_num;
			TmpInvHeaders(i).current_draft_invoice_num :=inv_rec.draft_invoice_num;
			TmpInvHeaders(i).inv_currency_code:=inv_rec.bill_trans_currency_code;
			TmpInvHeaders(i).action_flag:='I';
			TmpInvHeaders(i).retention_percentage:= inv_rec.retention_percentage;

			new_invoice_num :=TmpInvHeaders(i).new_draft_invoice_num;
			new_line_num  	:= 0;
			new_invoice_num := last_invoice_num;

		END IF;

		IF previous_btc = inv_rec.bill_trans_currency_code AND
			(split_invoice)  THEN

                   IF g1_debug_mode  = 'Y' THEN
                   	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Inside the Prvs_btc = btc If .....');
                   END IF;

			-- Add the invoice lines into new invoice lines array
			last_line_num := last_line_num +1;
			new_line_num  	:= last_line_num;
			new_invoice_num := last_invoice_num;
		ELSE

                  IF g1_debug_mode  = 'Y' THEN
                  	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Inside the Prvs_btc = btc Else .....');
                  END IF;

			last_line_num := last_line_num +1;
			new_line_num  	:= last_line_num;
		END IF;

                IF g1_debug_mode  = 'Y' THEN
                	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Before assigning to TmpInvlines .....');
                END IF;

		TmpInvLines(j).current_draft_invoice_num := current_invoice_num;
		TmpInvLines(j).new_draft_invoice_num := new_invoice_num;
		TmpInvLines(j).current_line_num := current_line_num;
		TmpInvLines(j).new_line_num :=new_line_num;
		TmpInvLines(j).event_num :=inv_rec.event_num;
		TmpInvLines(j).revenue_amount :=inv_rec.revenue_amount;

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' j  =  ' || j);
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' Old Inv      :  ' || TmpInvLines(j).current_draft_invoice_num);
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' Old Line Num :  ' || TmpInvLines(j).current_line_num);
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || '     New  Inv :  ' || TmpInvLines(j).new_draft_invoice_num);
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' New Line Num :  ' || TmpInvLines(j).new_line_num);
        END IF;

		j:= j+1;

	END LOOP;


         IF g1_debug_mode  = 'Y' THEN
         	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Out side the cur_inv Loop .....');
         END IF;

-- Process only  if the project multi bill transaction currencies

IF  (TmpInvHeaders.EXISTS(TmpInvHeaders.first))  THEN
		-- Reset the line number for newly created invoices
/* Bug 2870248 fix starts*/
        FOR k IN TmpInvLines.FIRST.. TmpInvLines.LAST LOOP
            UPDATE pa_draft_invoice_items
                   SET line_num  = TmpInvLines(k).current_line_num+1000000
                 WHERE project_id = p_project_id
                 AND   request_id = p_request_id
                 AND  draft_invoice_num = TmpInvLines(k).current_draft_invoice_num
                 AND line_num         = TmpInvLines(k).current_line_num;

/* Added for bug 3144517.Fix is similar to that in 2870248 */

	 IF TmpInvLines(k).event_num =0 THEN
	       --Update the RDLS
			UPDATE pa_cust_rev_dist_lines
			   SET draft_invoice_item_line_num = TmpInvLines(k).current_line_num+1000000
			 WHERE project_id = p_project_id
			   AND request_id = p_request_id
			   AND draft_invoice_num = TmpInvLines(k).current_draft_invoice_num
			   AND draft_invoice_item_line_num = TmpInvLines(k).current_line_num;

		ELSIF TmpInvLines(k).revenue_amount <> 0 THEN
		-- Update only if the event is revenue event

			UPDATE pa_cust_event_rdl_all
			   SET draft_invoice_item_line_num = TmpInvLines(k).current_line_num+1000000
			 WHERE project_id = p_project_id
			   AND request_id = p_request_id
			   AND draft_invoice_num = TmpInvLines(k).current_draft_invoice_num
			   AND draft_invoice_item_line_num = TmpInvLines(k).current_line_num;

        END IF;

/*End of fix for bug 3144517 */

        END LOOP;
/* Bug 2870248 Ends */

   FOR k IN REVERSE TmpInvLines.FIRST..TmpInvLines.LAST LOOP

		-- Update the draft invoice items
	-- IF (TmpInvLines(k).current_draft_invoice_num <>
	--    TmpInvLInes(k).new_draft_invoice_num ) OR
	--    ( TmpInvLines(k).current_line_num <>
	--    TmpInvLines(k).new_line_num) THEN
        --PA_MCB_INVOICE_PKG.log_message('Update Invoice Lines ');

       -- PA_MCB_INVOICE_PKG.log_message('O Inv Num :  ' || TmpInvLines(k).current_draft_invoice_num ||
      --  '     N Inv Num :  ' || TmpInvLInes(k).new_draft_invoice_num ||
      --  '     O LineNum :  ' || TmpInvLInes(k).current_line_num ||
      --  '     N Inv Num :  ' || TmpInvLInes(k).new_line_num);

		UPDATE pa_draft_invoice_items
		   SET draft_invoice_num = TmpInvLines(k).new_draft_invoice_num,
			line_num  = TmpInvLines(k).new_line_num,
			inv_amount= bill_trans_bill_amount
		 WHERE project_id = p_project_id
	         AND   request_id = p_request_id
		 AND  draft_invoice_num = TmpInvLines(k).current_draft_invoice_num
		 AND line_num         = TmpInvLines(k).current_line_num+1000000;
						       /* Adding with Huge number for bug2870248 */

/*fix for bug 3144517 */
	IF TmpInvLines(k).event_num =0 THEN
       --Update the RDLS
		UPDATE pa_cust_rev_dist_lines
		   SET draft_invoice_num =  TmpInvLines(k).new_draft_invoice_num,
		       draft_invoice_item_line_num = TmpInvLines(k).new_line_num
		 WHERE project_id = p_project_id
		   AND request_id = p_request_id
		   AND draft_invoice_num = TmpInvLines(k).current_draft_invoice_num
		   AND draft_invoice_item_line_num = TmpInvLines(k).current_line_num+1000000;
                                                                   /*For bug 3144517*/
	ELSIF TmpInvLines(k).revenue_amount <> 0 THEN
	-- Update only if the event is revenue event

		UPDATE pa_cust_event_rdl_all
		   SET draft_invoice_num =  TmpInvLines(k).new_draft_invoice_num,
		       draft_invoice_item_line_num = TmpInvLines(k).new_line_num
		 WHERE project_id = p_project_id
		   AND request_id = p_request_id
		   AND draft_invoice_num = TmpInvLines(k).current_draft_invoice_num
		   AND draft_invoice_item_line_num = TmpInvLines(k).current_line_num+1000000;
                                                                   /*For bug 3144517*/
	END IF;
-- 	END IF;

 END LOOP;

 -- Final Update to calculate the rate between invoice currency and project functional currency

	 update  pa_draft_invoice_items
         set     inv_amount        = 0
         where   project_id        = P_Project_Id
           and   invoice_line_type = 'NET ZERO ADJUSTMENT'
	   and   request_id        = p_request_id;

     -- Update the conversion rate for ITC to PFC

 FOR k IN TmpInvHeaders.FIRST..TmpInvHeaders.LAST LOOP
	-- Insert the New Invoice Headers
	-- All the values will be the same exception draft_invoice_num
	-- , inv_currency_code


	l_projfunc_invtrans_rate :=0;
	l_inv_amount :=0;
	l_pfc_amount :=0;
	l_fc_amount :=0;
	l_pc_amount :=0;
	l_btc_amount :=0;
	l_ret_line_num :=0;

	SELECT NVL(sum(dii.inv_amount),0),
	      NVL(sum(dii.projfunc_bill_amount),0),
	      NVL(sum(dii.project_bill_amount),0),
	      NVL(sum(dii.bill_trans_bill_amount),0),
	      NVL(sum(dii.funding_bill_amount),0),
	      NVL(MAX(dii.line_num),0) +1
          INTO 	l_inv_amount,
		l_pfc_amount,
		l_pc_amount,
		l_btc_amount,
		l_fc_amount,
		l_ret_line_num
          FROM pa_draft_invoice_items dii
         WHERE dii.project_id = P_Project_Id
           AND  dii.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num
	   AND dii.invoice_line_type <> 'NET ZERO ADJUSTMENT'
	   AND dii.invoice_line_type <> 'RETENTION';

        IF g1_debug_mode  = 'Y' THEN
        	PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || 'Old Inv Num :  ' || TmpInvHeaders(k).current_draft_invoice_num ||
        '     New Inv Num :  ' || TmpInvHeaders(k).new_draft_invoice_num ||
        '     New Inv Curr :  ' || TmpInvHeaders(k).inv_currency_code ||
        '     Action Flag  :  ' || TmpInvHeaders(k).action_flag ||
        '     INV AMOUNT   :  ' || l_inv_amount ||
       '     PFC AMOUNT   :  ' || l_pfc_amount );
        END IF;

 /*   To avoid division by zero error , changing the logic to calculate l_projfunc_invtrans_rate - For bug 2961983
          commenting the following code to calculate l_projfunc_invtrans_rate and added the new logic following the same */

  /*	IF NVL(l_inv_amount,0) <> 0 AND NVL(l_pfc_amount,0) <> 0 THEN
	   l_projfunc_invtrans_rate := NVL(l_inv_amount,0)/NVL(l_pfc_amount,0);
	END IF;  Commented for bug 2961983 */

 /* Added the following for bug 2961983 */

/* Commented for 3436063
    SELECT NVL(dii.inv_amount,0)/NVL(dii.projfunc_bill_amount,0)
        INTO l_projfunc_invtrans_rate
        FROM pa_draft_invoice_items dii
        WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num
         AND  nvl(dii.projfunc_bill_amount,0) <> 0
         AND  rownum=1;
*/
/* End of Changes for bug 2961983 */

 /****Code added for 3436063****/
	SELECT sum(NVL(dii.projfunc_bill_amount,0))
	INTO l_sum_projfunc_bill_amount
	FROM pa_draft_invoice_items dii
	WHERE dii.project_id = P_Project_Id
         AND  dii.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num;

   /*** For Bug 5346566 ***/
    SELECT sum(NVL(dii.inv_amount,0))
    INTO l_sum_inv_amount
    FROM pa_draft_invoice_items dii
    WHERE dii.project_id = P_Project_Id
    AND  dii.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num;
   /*** End of code change for Bug 5346566 ***/

	IF l_sum_projfunc_bill_amount <> 0 AND l_sum_inv_amount <> 0 /*** Condition added for bug 5346566 ***/
	THEN
		SELECT sum(NVL(dii.inv_amount,0))/sum(NVL(dii.projfunc_bill_amount,0))
		INTO l_projfunc_invtrans_rate
		FROM pa_draft_invoice_items dii
		WHERE dii.project_id = P_Project_Id
		 AND  dii.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num
		 having  sum(nvl(dii.projfunc_bill_amount,0)) <> 0;
         ELSE
	 /* Added begin and end to handle the exception for bug 8666892 */
  	    BEGIN
		SELECT NVL(dii.inv_amount,0)/NVL(dii.projfunc_bill_amount,0)
		INTO l_projfunc_invtrans_rate
		FROM pa_draft_invoice_items dii
		WHERE dii.project_id = P_Project_Id
		 AND  dii.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num
		 AND  nvl(dii.projfunc_bill_amount,0) <> 0
		 AND  rownum=1;

	    EXCEPTION
		WHEN OTHERS THEN
			l_projfunc_invtrans_rate := 0;
	    END;
	 END IF;
 /****End of code added for 3436063****/

	-- Insert if the action flag is I

	IF TmpInvHeaders(k).action_flag ='I' THEN

        	IF g1_debug_mode  = 'Y' THEN
        		PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' Insert New Invoices ');
        	END IF;

   		INSERT INTO pa_draft_invoices_all
              (project_id,
        	draft_invoice_num,
        	last_update_date,
        	last_updated_by,
		creation_date,
       		created_by,
       		transfer_status_code,
       		generation_error_flag,
      		agreement_id,
      		pa_date,
      		request_id,
       		program_application_id,
 		program_id,
 		program_update_date,
 		customer_bill_split,
 		bill_through_date,
 		invoice_comment,
 		approved_date,
 		approved_by_person_id,
 		released_date,
		released_by_person_id,
 		invoice_date,
 		ra_invoice_number,
 		transferred_date,
 		transfer_rejection_reason,
 		unearned_revenue_cr,
 		unbilled_receivable_dr,
 		gl_date,
 		system_reference,
 		draft_invoice_num_credited ,
 		canceled_flag,
 		cancel_credit_memo_flag ,
 		write_off_flag,
 		converted_flag,
 		extracted_date,
 		last_update_login,
 		attribute_category,
 		attribute1,
 		attribute2,
 		attribute3,
 		attribute4,
 		attribute5,
		attribute6,
		attribute7,
 		attribute8,
 		attribute9,
 		attribute10,
 		retention_percentage,
 		invoice_set_id,
 		org_id,
 		inv_currency_code,
 		inv_rate_type,
 		inv_rate_date,
 		inv_exchange_rate,
 		bill_to_address_id,
 		ship_to_address_id ,
 		prc_generated_flag,
 		receivable_code_combination_id,
 		rounding_code_combination_id,
 		unbilled_code_combination_id,
 		unearned_code_combination_id,
 		woff_code_combination_id,
 		acctd_curr_code,
 		acctd_rate_type,
 		acctd_rate_date,
 		acctd_exchg_rate,
		language,
 		cc_invoice_group_code ,
 		cc_project_id,
 		ib_ap_transfer_status_code,
 		ib_ap_transfer_error_code ,
 		invproc_currency_code,
 		projfunc_invtrans_rate_type,
 		projfunc_invtrans_rate_date ,
 		projfunc_invtrans_ex_rate,
                customer_id,
                bill_to_customer_id,
                ship_to_customer_id,
                bill_to_contact_id,
                ship_to_contact_id)
	SELECT 	project_id,
        	TmpInvHeaders(k).new_draft_invoice_num,
        	last_update_date,
        	last_updated_by,
		creation_date,
       		created_by,
       		transfer_status_code,
       		generation_error_flag,
      		agreement_id,
      		pa_date,
      		request_id,
       		program_application_id,
 		program_id,
 		program_update_date,
 		customer_bill_split,
 		bill_through_date,
 		invoice_comment,
 		approved_date,
 		approved_by_person_id,
 		released_date,
		released_by_person_id,
 		invoice_date,
 		ra_invoice_number,
 		transferred_date,
 		transfer_rejection_reason,
 		unearned_revenue_cr,
 		unbilled_receivable_dr,
 		gl_date,
 		system_reference,
 		draft_invoice_num_credited ,
 		canceled_flag,
 		cancel_credit_memo_flag ,
 		write_off_flag,
 		converted_flag,
 		extracted_date,
 		last_update_login,
 		attribute_category,
 		attribute1,
 		attribute2,
 		attribute3,
 		attribute4,
 		attribute5,
		attribute6,
		attribute7,
 		attribute8,
 		attribute9,
 		attribute10,
 		retention_percentage,
 		invoice_set_id,
 		org_id,
 		TmpInvHeaders(k).inv_currency_code,
 		NULL, --'User'
 		NULL, --sysdate
 		NULL, --1
 		bill_to_address_id,
 		ship_to_address_id ,
 		prc_generated_flag,
 		receivable_code_combination_id,
 		rounding_code_combination_id,
 		unbilled_code_combination_id,
 		unearned_code_combination_id,
 		woff_code_combination_id,
 		acctd_curr_code,
 		acctd_rate_type,
 		acctd_rate_date,
 		acctd_exchg_rate,
		language,
 		cc_invoice_group_code ,
 		cc_project_id,
 		ib_ap_transfer_status_code,
 		ib_ap_transfer_error_code ,
 		invproc_currency_code,
 		'User',
 		Sysdate ,
 		l_projfunc_invtrans_rate,
                customer_id,
                bill_to_customer_id,
                ship_to_customer_id,
                bill_to_contact_id,
                ship_to_contact_id
	FROM pa_draft_invoices_all
	WHERE project_id = p_project_id
          AND draft_invoice_num = TmpInvHeaders(k).current_draft_invoice_num;

	-- Handling Retention lines

	 /* Commented out for Retention enhancements
		IF NVL(TmpInvHeaders(k).retention_percentage,0) <> 0 THEN

        		IF g1_debug_mode  = 'Y' THEN
        			PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' Insert Ret Line for New Invoice ');
        		END IF;

			-- Insert new retention line

			INSERT INTO pa_draft_invoice_items(
						project_id,
						draft_invoice_num,
						line_num,
						last_update_date,
						last_updated_by,
						creation_date,
						created_by,
						amount,
						text,
						invoice_line_type,
						request_id,
						program_application_id,
						program_id,
						program_update_date,
						unearned_revenue_cr,
						unbilled_receivable_dr,
						task_id,
						event_task_id,
						event_num,
						ship_to_address_id,
						taxable_flag,
						draft_inv_line_num_credited,
						last_update_login,
						inv_amount,
                                                output_tax_classification_code,
						output_tax_exempt_flag,
						output_tax_exempt_reason_code,
						output_tax_exempt_number,
						acct_amount,
						rounding_amount,
						unbilled_rounding_amount_dr,
						unearned_rounding_amount_cr,
						translated_text,
						cc_rev_code_combination_id,
						cc_project_id,
						cc_tax_task_id,
						project_currency_code,
						project_bill_amount,
						projfunc_currency_code,
						projfunc_bill_amount,
						funding_currency_code,
						funding_bill_amount,
						invproc_currency_code,
						bill_trans_currency_code,
						bill_trans_bill_amount)
				SELECT
						project_id,
						TmpInvHeaders(k).new_draft_invoice_num,
						l_ret_line_num,
						last_update_date,
						last_updated_by,
						creation_date,
						created_by,
						NVL(l_btc_amount,0) *
						 ( NVL(TmpInvHeaders(k).retention_percentage,0)/100),
						text,
						invoice_line_type,
						request_id,
						program_application_id,
						program_id,
						program_update_date,
						unearned_revenue_cr,
						unbilled_receivable_dr,
						task_id,
						event_task_id,
						event_num,
						ship_to_address_id,
						taxable_flag,
						draft_inv_line_num_credited,
						last_update_login,
						NVL(l_btc_amount,0) *
						 ( NVL(TmpInvHeaders(k).retention_percentage,0)/100),
                                                output_tax_classification_code,
						output_tax_exempt_flag,
						output_tax_exempt_reason_code,
						output_tax_exempt_number,
						acct_amount,
						rounding_amount,
						unbilled_rounding_amount_dr,
						unearned_rounding_amount_cr,
						translated_text,
						cc_rev_code_combination_id,
						cc_project_id,
						cc_tax_task_id,
						project_currency_code,
						NVL(l_pc_amount,0) *
						(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
						projfunc_currency_code,
						NVL(l_pfc_amount,0) *
						(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
						funding_currency_code,
						NVL(l_fc_amount,0) *
						(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
						invproc_currency_code,
						TmpInvHeaders(k).inv_currency_code,
						NVL(l_btc_amount,0) *
						(NVL(TmpInvHeaders(k).retention_percentage,0)/100)
				FROM 	pa_draft_invoice_items
				WHERE 	project_id = p_project_id
  				  AND draft_invoice_num = TmpInvHeaders(k).current_draft_invoice_num
  				  AND invoice_Line_type ='RETENTION';



		END IF;  */

	ELSIF TmpInvHeaders(k).action_flag ='U' THEN

		---- Existing Invoice, update BTC currency code and rates
        	IF g1_debug_mode  = 'Y' THEN
        		PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' Update Existing Invoice ');
        	END IF;

		 UPDATE pa_draft_invoices_all
        		set  	inv_currency_code   = TmpInvHeaders(k).inv_currency_code,
			 	inv_rate_type      = NULL, --'User',
              			inv_rate_date      = NULL, --sysdate,
				inv_exchange_rate  = NULL, --1,
        	     projfunc_invtrans_rate_type      = 'User',
                     /* projfunc_invtrans_rate_date      = sysdate, commented for bug 5141073 */
                     projfunc_invtrans_rate_date      = invoice_date, /* Added for bug 5141073 */
                     projfunc_invtrans_ex_rate        = NVL(l_projfunc_invtrans_rate,0)
        	  WHERE project_id                        = P_Project_Id
        	  AND   draft_invoice_num                 = TmpInvHeaders(k).current_draft_invoice_num;

	        -- Reset the retention line

		/* Commented out for Retention Enhancements

		IF NVL(TmpInvHeaders(k).retention_percentage,0) <> 0 THEN

        	IF g1_debug_mode  = 'Y' THEN
        		PA_MCB_INVOICE_PKG.log_message('Inv_by_Bill_Trans_Currency: ' || ' Update Existing Invoice Retention Line ');
        	END IF;

				UPDATE pa_draft_invoice_items
				  SET  bill_trans_currency_code = TmpInvHeaders(k).inv_currency_code,
				       projfunc_bill_amount     =
						NVL(l_pfc_amount,0) *
						(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
				       project_bill_amount      =
						NVL(l_pc_amount,0) *
						(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
				       funding_bill_amount      =
						NVL(l_fc_amount,0) *
					(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
				       bill_trans_bill_amount      =
						NVL(l_btc_amount,0) *
					(NVL(TmpInvHeaders(k).retention_percentage,0)/100),
				       amount      =
						NVL(l_btc_amount,0) *
							NVL(TmpInvHeaders(k).retention_percentage,0),
				       inv_amount      =
						NVL(l_btc_amount,0) *
					  (NVL(TmpInvHeaders(k).retention_percentage,0)/100)
				WHERE draft_invoice_num = TmpInvHeaders(k).current_draft_invoice_num
				  AND project_id 	= p_project_id
				  AND invoice_line_type = 'RETENTION';
		  END IF;   */

	END IF;

 END LOOP;

END IF;
--For bug 4146846 : Call CAl_Conversion_Attr procedure which computes the Conversion Attributes
-- As per USE PFC flag  and BTC,PFC and IPC
FOR k IN TmpInvLines.FIRST.. TmpInvLines.LAST LOOP
	SELECT   agr.customer_id,
            	 i.bill_through_date
        INTO     l_customer_id,
        	 l_bill_thru_date
        FROM pa_draft_invoices_all i,
             pa_agreements_all agr
        WHERE i.project_id = p_project_id
        AND   i.request_id = p_request_id
        AND   i.draft_invoice_num = TmpInvHeaders(k).new_draft_invoice_num
        AND   NVL(i.generation_error_flag,'N')= 'N'
        AND   i.agreement_id = agr.agreement_id;

      SELECT   NVL(ppc.inv_rate_date,NVL(l_invoice_date,l_bill_thru_date)),
               ppc.inv_rate_type,
               ppc.inv_exchange_rate
       INTO    l_inv_rate_date,
               l_inv_rate_type,
               l_inv_rate
       FROM    pa_project_customers ppc
       WHERE   ppc.project_id          = P_Project_Id
       AND     ppc.customer_id         = l_customer_id;
	Cal_Conversion_Attr (  p_project_id 			=> p_project_id,
			       p_draft_invoice_num 		=> TmpInvHeaders(k).new_draft_invoice_num,
			       p_use_pfc_flag                   => l_use_pfc_flag,
			       p_pfc_currency_code              => l_pfc_currency_code,
			       p_pfc_ex_rate                    => l_projfunc_exchange_rate,
			       p_pfc_ex_rate_date_code          => l_pfc_exchg_rate_date_code,
			       p_pfc_rate_type                  => l_projfunc_exchg_rate_type,
			       p_pfc_rate_date                  => l_projfunc_exchg_rate_date,
			       p_invproc_currency_code          => l_invproc_currency_code,
			       p_inv_ex_rate 			=> l_inv_rate,
			       p_inv_rate_type			=> l_inv_rate_type,
			       p_inv_rate_date			=> l_inv_rate_date,
			       p_btc_currency_code 		=> TmpInvHeaders(k).inv_currency_code,
			       p_bill_thru_date			=> l_bill_thru_date,
			       x_status				=> l_ret_status);
IF l_ret_status <> 'Y' THEN
      	IF g1_debug_mode  = 'Y' THEN
       		PA_MCB_INVOICE_PKG.log_message(' Error in Inv_by_Bill_Trans_Currency '||sqlerrm(sqlcode));
      	END IF;
END IF;

END LOOP;

/*End of bug 4146846*/

EXCEPTION
   WHEN others THEN
       	IF g1_debug_mode  = 'Y' THEN
       		PA_MCB_INVOICE_PKG.log_message(' Error in Inv_by_Bill_Trans_Currency '||sqlerrm(sqlcode));
       	END IF;
          x_return_status := sqlerrm( sqlcode );

	-- RAISE;
END Inv_by_Bill_Trans_Currency;
END PA_MCB_INVOICE_PKG;

/
