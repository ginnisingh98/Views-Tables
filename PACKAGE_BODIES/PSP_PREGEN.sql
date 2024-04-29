--------------------------------------------------------
--  DDL for Package Body PSP_PREGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PREGEN" AS
/* $Header: PSPLDPGB.pls 120.8 2007/01/26 16:38:34 spchakra noship $  */
--

--	Introduced the following for bug fix 2916848
g_bg_currency_code		psp_payroll_controls.currency_code%TYPE;	-- Business Group Currency
g_sob_currency_code		gl_sets_of_books.currency_code%TYPE;	-- SOB Currency (Introduced for bug 3107800)
g_currency_code			psp_payroll_controls.currency_code%TYPE;	-- Batch Currency
g_precision			NUMBER;
g_ext_precision			NUMBER;
g_pop_exchange_rate_type	BOOLEAN DEFAULT TRUE;	-- Identifies if Exchange Rate Type has to be populated
--	End of bug fix 2916848

g_pregen_autopop   varchar2(1); --- 2 vars for 5080403
g_suspense_autopop   varchar2(1);

/* deleted code for get_clearing_ccid, bug 2007521 */
Procedure get_suspense_account(p_organization_id in number,
                               p_organization_name in varchar2,
                               p_effective_date   in date,
                               p_gms_pa_install   in varchar2,
                               p_person_id        in number,
                               p_business_group_id in number,
                               p_set_of_books_id in number,
                               p_distribution_interface_id in number,
                               x_suspense_account  out NOCOPY number,
                               x_return_status out NOCOPY varchar2,
                               x_suspense_auto_glccid out nocopy number,
                               x_suspense_auto_exp_type out nocopy varchar2);
Procedure stick_suspense_account( p_assignment_id in number,
	                          p_effective_date in date,
                                  p_gms_pa_install   in varchar2,
                                  p_person_id        in number,
	                          p_distribution_interface_id in number,
	                          p_suspense_reason_code in varchar2,
                                  p_business_group_id in number,
                                  p_set_of_books_id in number,
	                          p_return_status out NOCOPY varchar2);
Procedure Validate_Person_ID(X_Person_ID         IN Number,
                             X_Effective_Date    IN Date,
			     X_Business_group_id IN NUMBER,
                             X_Payroll_ID        IN Number,
                             X_set_of_books_id    IN  Number,
			     X_return_status     OUT NOCOPY varchar2,
                             X_return_code       OUT NOCOPY varchar2);
--
Procedure Validate_Assignment_ID(X_Assignment_ID     IN Number,
                                 X_Effective_Date    IN Date,
 			         X_return_status     OUT NOCOPY varchar2,
                                 X_return_code       OUT NOCOPY varchar2,
				 X_business_group_id IN Number,
				 X_set_of_books_id   IN Number);

--
Procedure Validate_Payroll_ID(X_Payroll_ID         IN Number,
                              X_Assignment_ID      IN Number,
                              X_Effective_Date     IN Date,
 			      X_return_status      OUT NOCOPY varchar2,
                              X_return_code        OUT NOCOPY varchar2,
			      X_business_group_id  IN  Number,
			      X_set_of_books_id    IN  Number);

--
Procedure Validate_Payroll_Period_ID(X_Payroll_ID        IN Number,
                                     X_Payroll_Period_ID IN Number,
                                     X_Effective_Date    IN Date,
 			             X_return_status     OUT NOCOPY varchar2,
                                     X_return_code       OUT NOCOPY varchar2);
--
Procedure Validate_Payroll_Source_Code(X_Payroll_Source_Code IN varchar2,
 			               X_return_status       OUT NOCOPY varchar2,
                                       X_return_code         OUT NOCOPY varchar2);
--
Procedure Validate_Element_Type_ID(X_Element_Type_ID   IN Number,
                                   X_Payroll_Period_ID IN Number,
--	Introduced BG/SOB parameters for bug fix 3098050
				X_business_group_id  IN  Number,
				X_set_of_books_id    IN  Number,
			           X_return_status     OUT NOCOPY varchar2,
                                   X_return_code       OUT NOCOPY varchar2);
--
Procedure Validate_Project_details(X_Project_ID		IN Number,
	               	           X_task_id		IN Number,
			           X_award_id		IN Number,
			           X_expenditure_type	IN Varchar2,
                                   X_exp_org_id		IN Number,
				   X_gms_pa_install     IN VARCHAR2,
	  			   X_Person_ID	        IN VARCHAR2,
                             	   X_Effective_date	IN DATE,
			           X_return_status	OUT NOCOPY Varchar2,
			           X_return_code	OUT NOCOPY Varchar2);
--
Procedure update_record_with_error(X_distribution_interface_id	IN Number,
				   X_error_code			IN Varchar2,
				   X_return_status	        OUT NOCOPY Varchar2);
--
Procedure update_record_with_valid(X_distribution_interface_id	IN Number,
				   X_return_status		OUT NOCOPY varchar2);

Procedure update_record_with_exp(X_distribution_interface_id  IN Number,
				 X_expenditure_type           IN Varchar2,
				 X_return_status              OUT NOCOPY Varchar2);

--
Procedure update_record_with_na(X_distribution_interface_id  IN Number,
				X_gl_code_combination_id     IN Number,
				X_return_status              OUT NOCOPY Varchar2);

 /* Bug fix 2985061: Created this procedure.*/
PROCEDURE VALIDATE_DR_CR_FLAG ( X_DR_CR_FLAG     IN VARCHAR2,
                                X_return_status  OUT NOCOPY varchar2,
                                X_return_code    OUT NOCOPY varchar2);

 /* Bug fix 2985061: Created this procedure.*/
PROCEDURE VALIDATE_GL_CC_ID(  X_CODE_COMBINATION_ID          IN NUMBER,
                                            X_return_status  OUT NOCOPY varchar2,
                                            X_return_code    OUT NOCOPY varchar2);
g_use_pre_gen_suspense varchar(1); /* Bug 2007521: Profile use suspense A/C */
--
--
-- This is the Main procedure which is being called by Concurrent process
-- Input parameter is Batch Name
-- fetches all records from psp_distribution_interface table belongs to given batch name and
-- validates each record whether it is valid or not.
-- If all records are valid then imports into psp_pre_gen_dist_lines table and marks as Transfered in
-- psp_distribution_interface table
--
PROCEDURE IMPORT_PREGEN_LINES (ERRBUF              OUT NOCOPY Varchar2,
			       RETCODE             OUT NOCOPY Number,
			       p_batch_name        IN  VARCHAR2,
		               p_business_group_id IN NUMBER,
			       p_set_of_books_id   IN NUMBER,
			       p_operating_unit    IN NUMBER,
		               p_gms_pa_install    IN VARCHAR2) IS
--		               p_gms_pa_install    IN VARCHAR2 default NULL) IS	Commented as part of bug fix 2447912

CURSOR 	get_all_from_interface_csr is
SELECT 	*
FROM   	psp_distribution_interface
WHERE  	batch_name = p_batch_name  and
        status_code <> 'V' FOR UPDATE;

-- Declared the following cursor and exception for bug fix 2094036
CURSOR	pregen_distribution_check_cur IS
SELECT	distribution_interface_id
FROM	psp_distribution_interface
WHERE	batch_name = p_batch_name
AND	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id
FOR UPDATE OF distribution_interface_id NOWAIT;
l_distribution_interface_id	NUMBER;

RECORD_ALREADY_LOCKED	EXCEPTION;
PRAGMA EXCEPTION_INIT	(RECORD_ALREADY_LOCKED, -54);

g_pregen_rec  get_all_from_interface_csr%ROWTYPE;

CURSOR 	get_for_total_csr is
SELECT 	*
FROM   	psp_distribution_interface
WHERE  	batch_name = p_batch_name
ORDER BY	source_code,time_period_id;

g_for_total_rec  get_for_total_csr%ROWTYPE;

/* deleted cursors get_count_for_gl_csr, get_count_for_project_csr Bug 2007521 */

CURSOR  get_batch_name_csr is
SELECT  count(*)
FROM    psp_payroll_controls
WHERE   source_type       = 'P' and
        batch_name        = p_batch_name and
	business_group_id = p_business_group_id and
	set_of_books_id   = p_set_of_books_id;

--	Introduced the following for bug fix 2916848
CURSOR	currency_count_cur IS
SELECT	COUNT(DISTINCT NVL(currency_code, 'bg_currency'))
FROM	psp_distribution_interface
WHERE	batch_name = p_batch_name
AND	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id;

CURSOR	currency_code_cur IS
SELECT	currency_code
FROM	psp_distribution_interface
WHERE	batch_name = p_batch_name
AND	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id
AND	currency_code IS NOT NULL
AND	ROWNUM = 1;

CURSOR	period_end_date_cur (p_time_period_id NUMBER) IS
SELECT	end_date
FROM	per_time_periods ptp
WHERE	ptp.time_period_id = p_time_period_id;

l_currency_count	NUMBER;
l_period_end_date	DATE;
l_exchange_rate_type	psp_payroll_controls.exchange_rate_type%TYPE;
--	End of bug fix 2916848

--	Introdced the following for bug fix 3107800
CURSOR	sob_currency_cur IS
SELECT	currency_code
FROM	gl_sets_of_books gsob
WHERE	set_of_books_id = p_set_of_books_id;
--	End of bug fix 3107800

l_batch_name_count  number;
---g_auto_population VARCHAR2(1);  5080403

-- Error Handling variables

l_error_api_name	varchar2(2000);
l_return_status		varchar2(1);
l_return_code		varchar2(30);
l_batch_status		number(1):= 0;
l_msg_count		number;
l_msg_data		varchar2(2000);
l_msg_index_out		number;
--
l_api_name		varchar2(30)	:= 'PSP_PREGEN';
l_subline_message	varchar2(200);
--
l_ft_source_code	varchar2(30);
l_ft_time_period_id     number(15);
l_ft_payroll_id		number(9);
l_ft_number_of_cr	number(9);
l_ft_number_of_dr	number(9);
l_ft_dr_amount		number(22,2);
l_ft_cr_amount		number(22,2);
l_ft_counter		number(9);
l_control_id		number(9);
--Gl_posting_date included to incorporate the date changes by vijay cirigiri
l_gl_posting_date       date:=NULL;
l_gms_posting_date      date:=NULL;
l_rowid		        varchar2(20);
l_set_of_books_id       number(15):= 0;
l_count_status_v        NUMBER(9);
l_gms_pa_install        Varchar2(10);
d_set_of_books_id       NUMBER;
d_business_group_id     NUMBER;
d_operating_unit        NUMBER;
---l_dff_grouping_option	VARCHAR2(1) DEFAULT psp_general.get_act_dff_grouping_option(p_business_group_id); -- Introduced for bug fix 2908859
  -- commented above line for 4992668

-- following cursor for 5080403
  cursor autopop_config_cur is
  select pcv_information7 suspense,
         pcv_information9 pregen
    from pqp_configuration_values
   where pcv_information_category = 'PSP_ENABLE_AUTOPOPULATION'
     and legislation_code is null
     and nvl(business_group_id, p_business_group_id) = p_business_group_id;


BEGIN
  ---hr_utility.trace_on('Y', 'PREGEN');
  g_use_pre_gen_suspense := FND_PROFILE.VALUE('PSP_USE_PREGEN_SUSPENSE'); -- Bug 2007521
  FND_MSG_PUB.Initialize;
  --dbms_output.PUT_LINE('................0');

 --  l_set_of_books_id	:= FND_PROFILE.VALUE('PSP_SET_OF_BOOKS');
     l_set_of_books_id := p_set_of_books_id;
  if NVL(l_set_of_books_id,0) = 0 then
     l_error_api_name := 'IMPORT_PREGEN_LINES';
     fnd_message.set_name('PSP','PSP_PI_NO_PROFILE_FOR_SOB');
     fnd_msg_pub.add;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  Begin
     FND_STATS.Gather_Table_Stats(ownname => 'PSP',
				  tabname => 'PSP_DISTRIBUTION_INTERFACE');

--				  percent => 10,
--				  tmode   => 'NORMAL');
--    Removed percent and tmode parameters for bug fix 2463762

  Exception
     When others then
	 null;
  End;

  if p_gms_pa_install IS NULL then
     PSP_GENERAL.MULTIORG_CLIENT_INFO(d_set_of_books_id,d_business_group_id,d_operating_unit,l_gms_pa_install);
  else
     l_gms_pa_install := p_gms_pa_install;
  end if;

-- Included the following for bug fix 2094036
	OPEN pregen_distribution_check_cur;
	FETCH pregen_distribution_check_cur INTO l_distribution_interface_id;
	IF (pregen_distribution_check_cur%NOTFOUND) THEN
		CLOSE pregen_distribution_check_cur;
		RAISE RECORD_ALREADY_LOCKED;
	END IF;

	CLOSE pregen_distribution_check_cur;
-- End of bug fix 2094036

--	Introduced the following for bug fix 2916848
	g_bg_currency_code := psp_general.get_currency_code(p_business_group_id);

--	Introduced the following for bug fix 3107800
	OPEN sob_currency_cur;
	FETCH sob_currency_cur INTO g_sob_currency_code;
	CLOSE sob_currency_cur;
--	End of bug fix 3107800

	OPEN currency_count_cur;
	FETCH currency_count_cur INTO l_currency_count;
	CLOSE currency_count_cur;

	IF (l_currency_count > 1) THEN
		fnd_message.set_name('PSP', 'PSP_PI_INVALID_CURRENCY');
		fnd_message.set_token('BATCH_NAME', p_batch_name);
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	OPEN currency_code_cur;
	FETCH currency_code_cur INTO g_currency_code;
	CLOSE currency_code_cur;

	g_currency_code := NVL(g_currency_code, g_bg_currency_code);

	IF ((g_bg_currency_code = g_currency_code) AND (g_sob_currency_code = g_bg_currency_code)) THEN
		g_pop_exchange_rate_type := FALSE;
	END IF;

	psp_general.get_currency_precision(g_currency_code, g_precision, g_ext_precision);
--	End of bug fix 2916848

/*************************************************************************************************
  if g_auto_population ='Y' then
       Autopop(errbuf, retcode, p_batch_name);
       IF retcode != FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
  end if;

Modified Procedure Call
**************************************************************************************************/
 --- cursor for 5080403
  open autopop_config_cur;
  fetch autopop_config_cur into g_suspense_autopop, g_pregen_autopop;
  close autopop_config_cur;

  if g_pregen_autopop ='Y' then     --- changed to new option for 5080403
       hr_utility.trace('Calling Autopop');
        Autopop(
               X_Batch_name        => p_batch_name,
               X_Set_of_Books_Id   =>p_set_of_books_id,
               X_Business_Group_ID =>p_business_group_id,
               X_Operating_Unit    =>p_operating_unit,
               X_Gms_Pa_Install    => l_gms_pa_install,
               X_Return_Status     =>l_return_status);

       IF l_return_status  <>  FND_API.G_RET_STS_SUCCESS THEN
--	Included changes for bug fix 2094036, to commit autopop errors as part of inerface errors
	   l_batch_status := 1;
	   IF (l_return_status = fnd_api.g_ret_sts_unexp_error) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	   END IF;
       END IF;
 end if;

  open get_all_from_interface_csr;
  fetch get_all_from_interface_csr into g_pregen_rec;

  if get_all_from_interface_csr%NOTFOUND  then
     --RAISE NO_DATA_FOUND;
/* Code added by Subha on 7/23/1999 to allow processing to continue in the vent that all
    records in interface table have a status of 'VALID'  */

     select count(*) into l_count_status_v  from psp_distribution_interface
     where batch_name=p_batch_name and status_code='V';
      if l_count_status_v = 0 then
          raise NO_DATA_FOUND;
      end if;
  end if;
  close get_all_from_interface_csr;
--
  --dbms_output.PUT_LINE('................1');
  open get_batch_name_csr;
    fetch get_batch_name_csr into l_batch_name_count;
  close get_batch_name_csr;

  if NVL(l_batch_name_count,0) > 0 then
      fnd_message.set_name('PSP','PSP_PI_INVALID_BATCH_NAME');
      fnd_message.set_token('PSP_BATCH_NAME',p_batch_name);
      fnd_msg_pub.add;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

/* Bug 2007521: Optimization, Run this part only if autopop is OFF */
if nvl(g_pregen_autopop,'N') <> 'Y' then
  open get_all_from_interface_csr;
  LOOP
      --dbms_output.PUT_LINE('................2');
      fetch get_all_from_interface_csr into g_pregen_rec;
      EXIT WHEN get_all_from_interface_csr%NOTFOUND ; -- Exit when last record is reached

        --dbms_output.PUT_LINE('................3');
        --dbms_output.PUT_LINE('Interface ID....' || to_char(g_pregen_rec.distribution_interface_id));

	  Validate_Person_ID(X_Person_ID	 =>	g_pregen_rec.person_id,
                             X_Effective_date	 =>	g_pregen_rec.distribution_date,
			     X_Business_group_id =>     p_business_group_id,
                             X_Payroll_ID        =>     g_pregen_rec.payroll_id,
                             X_set_of_books_id   =>     p_set_of_books_id,
			     X_return_status	 =>	l_return_status,
			     X_return_code	 => 	l_return_code);
        --dbms_output.PUT_LINE('................4');
	  if l_return_status		<> FND_API.G_RET_STS_SUCCESS then
           l_batch_status		:= 1;
           if l_return_code = 'OTHER'	then
              l_error_api_name	:= 'VALIDATE_PERSON_ID';
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           else
             update_record_with_error(X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
				      X_error_code			=> l_return_code,
                                      X_return_status			=> l_return_status);
             if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
           end if;
        else
          Validate_Assignment_ID(X_Assignment_ID	=> g_pregen_rec.assignment_id,
				 X_Effective_Date	=> g_pregen_rec.distribution_date,
				 X_return_status	=> l_return_status,
				 X_return_code		=> l_return_code,
				 X_business_group_id    => p_business_group_id,
				 X_set_of_books_id      => p_set_of_books_id);

          --dbms_output.PUT_LINE('................5');
          if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
             l_batch_status		:= 1;
             if l_return_code = 'OTHER' then
                l_error_api_name	:= 'VALIDATE_ASSIGNMENT_ID';
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             else
               update_record_with_error(X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
					X_error_code			=> l_return_code,
                                        X_return_status			=> l_return_status);
               if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;
             end if;
          else
	      Validate_Payroll_ID(X_Payroll_ID		=> g_pregen_rec.payroll_id,
				  X_Assignment_ID	=> g_pregen_rec.assignment_id,
				  X_Effective_Date	=> g_pregen_rec.distribution_date,
				  X_return_status	=> l_return_status,
				  X_return_code		=> l_return_code,
				  X_business_group_id   => p_business_group_id,
				  X_set_of_books_id     => p_set_of_books_id);

            --dbms_output.PUT_LINE('................6');
            if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
               l_batch_status		:= 1;
               if l_return_code = 'OTHER' then
                  l_error_api_name	:= 'VALIDATE_PAYROLL_ID';
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               else
                 update_record_with_error(X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
					  X_error_code			=> l_return_code,
                                          X_return_status		=> l_return_status);
                 if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 end if;
               end if;
            else
		 Validate_Payroll_Period_ID(X_Payroll_ID	=>	g_pregen_rec.payroll_id,
					    X_Payroll_Period_ID	=>	g_pregen_rec.time_period_id,
					    X_Effective_Date	=>	g_pregen_rec.distribution_date,
				            X_return_status	=>	l_return_status,
				            X_return_code	=>	l_return_code);
              --dbms_output.PUT_LINE('................7');
              if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
                 l_batch_status		:= 1;
                 if l_return_code = 'OTHER' then
                    l_error_api_name	:= 'VALIDATE_PAYROLL_PERIOD_ID';
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 else
                   update_record_with_error(X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
					    X_error_code		=> l_return_code,
                                            X_return_status		=> l_return_status);
                   if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   end if;
                 end if;
              else
--For Bug fix 2985061 :  adding the  validation of DR_CR Flag
            VALIDATE_DR_CR_FLAG ( X_DR_CR_FLAG   => g_pregen_rec.dr_cr_flag,
                                X_return_status  => l_return_status,
                                X_return_code    => l_return_code);

                IF l_return_status      <> FND_API.G_RET_STS_SUCCESS  THEN
                   l_batch_status               := 1;
                   IF l_return_code = 'OTHER' THEN
                      l_error_api_name  := 'VALIDATE_DR_CR_FLAG';
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                     update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
                                              X_error_code                 => l_return_code,
                                              X_return_status              => l_return_status);
                     IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                   END IF;
            ELSE
--End of Changes for Bug 2985061
		   Validate_Payroll_Source_Code(X_Payroll_Source_Code	=> g_pregen_rec.source_code,
				                X_return_status		=> l_return_status,
				                X_return_code		=> l_return_code);
                --dbms_output.PUT_LINE('................8');
                if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
                   --dbms_output.PUT_LINE('Entered Failure................8');
                   l_batch_status		:= 1;
                   if l_return_code = 'OTHER' then
                      l_error_api_name	:= 'VALIDATE_PAYROLL_SOURCE_CODE';
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   else
                     update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
					      X_error_code		   => l_return_code,
                                              X_return_status		   => l_return_status);
                     if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     end if;
                   end if;
                else
		     Validate_Element_Type_ID(X_Element_Type_ID		=> g_pregen_rec.element_type_id,
					      X_Payroll_Period_ID	=> g_pregen_rec.time_period_id,
--	Introduced BG/SOB parameters for bug fix 3098050
						x_business_group_id	=>	p_business_group_id,
						x_set_of_books_id	=>	p_set_of_books_id,
				              X_return_status		=> l_return_status,
				              X_return_code		=> l_return_code);
                  --dbms_output.PUT_LINE('................9');
                  if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
                     l_batch_status		:= 1;
                     if l_return_code = 'OTHER' then
                        l_error_api_name	:= 'VALIDATE_ELEMENT_TYPE_ID';
                        raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     else
                       update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
					        X_error_code		     => l_return_code,
                                                X_return_status		     => l_return_status);
                       if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       end if;
                     end if;
                  elsif g_pregen_rec.gl_code_combination_id IS NULL and
                        g_pregen_rec.project_id IS NULL then
                        l_batch_status	:= 1;
                        l_return_code	:= 'NUL_GLP';
                       update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
					        X_error_code		     => l_return_code,
                                                X_return_status		     => l_return_status);
                       if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       end if;
                  elsif g_pregen_rec.gl_code_combination_id IS NOT NULL and
                        g_pregen_rec.project_id IS NOT NULL then
                        l_batch_status	:= 1;
                        l_return_code	:= 'NOT_GLP';
                       update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
					        X_error_code		     => l_return_code,
                                                X_return_status		     => l_return_status);
                       if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                          raise FND_API.G_EXC_UNEXPECTED_ERROR;
                       end if;
			/* Bug fix 2985061 */
				  elsif g_pregen_rec.gl_code_combination_id IS NOT NULL then
					validate_gl_cc_id(  x_code_combination_id       => g_pregen_rec.gl_code_combination_id,
								    x_return_status                 => l_return_status,
								    x_return_code                   => l_return_code);

					IF l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
					   l_batch_status := 1;
					   IF l_return_code = 'OTHER' THEN
					      l_error_api_name  := 'VALIDATE_GL_CC_ID';
					      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					   ELSE
					     update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
								      X_error_code                 => l_return_code,
								      X_return_status              => l_return_status);
					     IF l_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
						RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					     END IF;
					   END IF;
					END IF;

				  elsif g_pregen_rec.project_id is not null then     /* Bug fix 2985061 */
--                  elsif NVL(g_pregen_rec.project_id,0) <> 0 then
	/****** Check for projects is installed or not ***************/
                         if l_gms_pa_install ='NO_PA_GMS' then
                 		l_batch_status:=1;
                 		l_return_status:= FND_API.G_RET_STS_ERROR;
                 		l_return_code:='NO_PA';
                  		   update_record_with_error(
                    			X_distribution_interface_id	=>  g_pregen_rec.distribution_interface_id,
                    			X_error_code			=> l_return_code,
                    			X_return_status			=> l_return_status);
                  		if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    			raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  		end if;
                          else
 		           Validate_Project_details(X_Project_ID	=> g_pregen_rec.project_id,
					            X_task_id		=> g_pregen_rec.task_id,
					      	    X_award_id		=> g_pregen_rec.award_id,
					            X_expenditure_type	=> g_pregen_rec.expenditure_type,
                                                    X_exp_org_id	=> g_pregen_rec.expenditure_organization_id,
						    X_gms_pa_install    => l_gms_pa_install,
	  					    X_Person_ID	        => g_pregen_rec.person_id,
                             			    X_Effective_date	=> g_pregen_rec.distribution_date,
				                    X_return_status	=> l_return_status,
				                    X_return_code	=> l_return_code);
			   --dbms_output.PUT_LINE('................10');
			   --dbms_output.PUT_LINE('return status.....' || l_return_status);
			   --dbms_output.PUT_LINE('return code.....' || l_return_code);
                          end if;
                         if l_return_status	<> FND_API.G_RET_STS_SUCCESS then
                         -- l_batch_status		:= 1;
                          if l_return_code = 'OTHER' then
                             l_batch_status		:= 1; /* 2007521 */
                             l_error_api_name	:= 'VALIDATE_PROJECTS_DETAILS';
                             raise FND_API.G_EXC_UNEXPECTED_ERROR;
                          else
                            if g_use_pre_gen_suspense = 'Y' then
	                        stick_suspense_account( g_pregen_rec.assignment_id,
	                                              g_pregen_rec.distribution_date,
                                                      l_gms_pa_install,
                                                      g_pregen_rec.person_id,
	                                              g_pregen_rec.distribution_interface_id,
	                                              l_return_code,
                                                      p_business_group_id,
                                                      p_set_of_books_id,
	                                              l_return_status);
                               if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
	                       end if;
                               /* Bug 2007521: moved code into stick suspense a/c
                               update_record_with_valid(X_distribution_interface_id=>
                                                      g_pregen_rec.distribution_interface_id,
                                                   X_return_status	      => l_return_status);
                               if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
	                       end if; */
                            else
                                l_batch_status := 1;
                                    update_record_with_error(X_distribution_interface_id=>
                                                             g_pregen_rec.distribution_interface_id,
		   			             X_error_code		=> l_return_code,
                                                     X_return_status		=> l_return_status);
                               if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                               end if;
                            end if;
                        end if;
                       else
                          ----dbms_output.put_line ('Update record with valid');
                           l_return_code 	:= 0;
                          update_record_with_valid(X_distribution_interface_id=> g_pregen_rec.distribution_interface_id,
                                                   X_return_status	      => l_return_status);
                          if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                             raise FND_API.G_EXC_UNEXPECTED_ERROR;
                          end if;
                       end if;
                    else
                       ----dbms_output.put_line ('Update record with valid');
                       l_return_code 	:= 0;
                          update_record_with_valid(X_distribution_interface_id=> g_pregen_rec.distribution_interface_id,
                                                   X_return_status	      => l_return_status);
                          if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                             raise FND_API.G_EXC_UNEXPECTED_ERROR;
                          end if;
                    end if;
                  end if;
                end if;
            end if;
         end if;
       end if;
    end if; -- for bug fix 2985061
  END LOOP;
  close get_all_from_interface_csr;
  --dbms_output.PUT_LINE('...End Loop .....l_batch_status ' || to_char(l_batch_status));
end if; /* Bug 2007521: Optimization */--Moved the End if  for Bug 2096440

  if l_batch_status = 1 then
     /* 2007521: Introduced update statement, to revert sticking suspense a/c if
        there are some other errors. Give chance to user to correct all errors */
     if nvl(g_use_pre_gen_suspense,'N')  = 'Y' then
       update psp_distribution_interface
       set suspense_org_account_id = null,
          status_code = 'E'
        where batch_name = p_batch_name and
            suspense_org_account_id is not null;
     end if;
      fnd_message.set_name('PSP','PSP_BATCH_HAS_ERRORS');
      fnd_msg_pub.add;
      -- This comment was added by Chandra to commit records
      -- in the PSP_DISTRIBUTION_INTERFACE table with the status
      commit; -- Added by Chandra
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;
--For Bug 2096440 : Moved the END IF above , the check for l_batch_status=1 has to be applicable for autopop 'Y' as well as 'N'
--  end if; /* Bug 2007521: Optimization */
--
  if l_batch_status = 0 then
     INSERT INTO PSP_PRE_GEN_DIST_LINES ( pre_gen_dist_line_id,
                                          distribution_interface_id,
                                          person_id,
					  assignment_id,
                                          element_type_id,
                                          distribution_date,
                                          effective_date,
                                          distribution_amount,
                                          dr_cr_flag,
                                          payroll_control_id,
                  			  source_type,
                                          source_code,
                                          time_period_id,
 					  batch_name,
                                          status_code,
                                          set_of_books_id,
                                          gl_code_combination_id,
                                          project_id,
                                          expenditure_organization_id,
                                          expenditure_type,
                                          task_id,
                                          award_id,
                                          suspense_org_account_id,
                                          suspense_reason_code,
                                          effort_report_id,
                                          version_num,
                                          summary_line_id,
					  reversal_entry_flag,
                                          user_defined_field,
				          business_group_id,
					  attribute_category,	--	Introduced DFF columns for bug fix 2908859
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
                                          suspense_auto_glccid,
                                          suspense_auto_exp_type)
                              SELECT      psp_distribution_lines_s.nextval,
                                          a.distribution_interface_id,
                                          a.person_id,
                                          a.assignment_id,
                                          a.element_type_id,
                                          a.distribution_date,
                                          --- Replaced dist date with period end date for GL -2876055
                                          decode(nvl(a.gl_code_combination_id, susp.gl_code_combination_id)
                                                          , null, a.distribution_date, t.end_date), -- added nvl for 5164744
                                          ---a.distribution_date,
                                          ROUND(a.distribution_amount, g_precision),	-- Introduced ROUND for bug fix 2651379; Corrected precision for bug fix 2916848
                                          UPPER(a.dr_cr_flag),
                                          0,
					  'P',
                                          a.source_code,
                                          a.time_period_id,
					  p_batch_name,
                                          'N',
                                          l_set_of_books_id,
                                          a.gl_code_combination_id,
                                          a.project_id,
                                          a.expenditure_organization_id,
                                          a.expenditure_type,
                                          a.task_id,
                                          a.award_id,
                                          a.suspense_org_account_id, /* 2007521 */
                                          a.error_code, --NULL, Bug 2007521: Susp changed to error code
                                          NULL, -- effort report id
                                          NULL, -- version num
                                          NULL, -- summary line id
                                          NULL, -- reversal_entry_flag
                                          NULL, -- user_defined_field
					            p_business_group_id,
					  a.attribute_category,	--	Introduced DFF columns for bug fix 2908859,
--- another fix for 4992668 DFF column always to gointo  lines
					  a.attribute1,
					  a.attribute2,
					  a.attribute3,
					  a.attribute4,
					  a.attribute5,
					  a.attribute6,
					  a.attribute7,
					  a.attribute8,
					  a.attribute9,
					  a.attribute10,
                                          a.suspense_auto_glccid,
                                          a.suspense_auto_exp_type
                              FROM        psp_distribution_interface a,
                                          per_time_periods T,
                                          psp_organization_accounts susp   --- introduced for 5164744
                              WHERE       batch_name = p_batch_name and
                                          T.time_period_id = a.time_period_id and
                                          susp.organization_account_id(+) = a.suspense_org_account_id;
    if sql%NOTFOUND then
       fnd_msg_pub.add_exc_msg('PSP_PREGEN','Error while inserting data');
       raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
    --dbms_output.PUT_LINE('...Crossed First Insert ' );
    --dbms_output.PUT_LINE('...L_gl_count ' || to_char(l_gl_count) );
    --dbms_output.PUT_LINE('...L_project_count ' || to_char(l_project_count) );

    /* 2007521: Deleted creation of balancing lines for Projects/GL, S and T does this */

       UPDATE psp_distribution_interface
       SET    status_code = 'T'
       WHERE  batch_name = p_batch_name;
       --dbms_output.PUT_LINE('...Crossed Update ' );
       if sql%NOTFOUND then
          fnd_msg_pub.add_exc_msg('PSP_PREGEN','Error while Updating Transfer status ');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

-- Total up all records by source_code, time_period_id to write into payroll_control table

    open get_for_total_csr;
    l_ft_payroll_id	:= 0;
    l_ft_number_of_cr	:= 0;
    l_ft_number_of_dr	:= 0;
    l_ft_dr_amount	:= 0;
    l_ft_cr_amount	:= 0;
    l_ft_counter	:= 0;
    LOOP
      fetch get_for_total_csr into g_for_total_rec;
      EXIT WHEN get_for_total_csr%NOTFOUND;
      --dbms_output.PUT_LINE('...Entered Payroll Controls LOOP.... ' );
      l_ft_counter := l_ft_counter + 1;
      if l_ft_counter   = 1 then
         l_ft_source_code	:= g_for_total_rec.source_code;
         l_ft_time_period_id	:= g_for_total_rec.time_period_id;
 	   l_ft_payroll_id	:= g_for_total_rec.payroll_id;
      end if;
	if ( nvl(l_ft_source_code,' ') <> nvl(g_for_total_rec.source_code,' ') or
      nvl(l_ft_time_period_id, 0) <> nvl(g_for_total_rec.time_period_id,0)) then
           -- Insert a record in psp_payroll_controls
          --dbms_output.PUT_LINE('...Before Insert into payroll controls  ' );
          select psp_payroll_controls_s.nextval into l_control_id from dual;

--	Introduced for bug fix 2916848
		OPEN period_end_date_cur(l_ft_time_period_id);
		FETCH period_end_date_cur INTO l_period_end_date;
		CLOSE period_end_date_cur;

		IF (g_pop_exchange_rate_type) THEN
			l_exchange_rate_type := hruserdt.get_table_value
					(p_bus_group_id		=>	p_business_group_id,
					p_table_name		=>	'EXCHANGE_RATE_TYPES',
					p_col_name		=>	'Conversion Rate Type',
					p_row_value		=>	'PAY',
					p_effective_date	=>	l_period_end_date);
		END IF;
--	End of bug fix 2916848

	    PSP_PAYROLL_CONTROLS_PKG.INSERT_ROW (
	    X_ROWID => l_rowid,
	    X_PAYROLL_CONTROL_ID => l_control_id,
	    X_PAYROLL_ACTION_ID => 0,
	    X_PAYROLL_SOURCE_CODE => l_ft_Source_Code,
	    X_SOURCE_TYPE => 'P',
	    X_PAYROLL_ID => l_ft_payroll_id,
	    X_TIME_PERIOD_ID => l_ft_time_period_id,
	    X_NUMBER_OF_CR => l_ft_number_of_cr,
	    X_NUMBER_OF_DR => l_ft_number_of_dr,
	    X_TOTAL_DR_AMOUNT => NULL,
	    X_TOTAL_CR_AMOUNT => NULL,
	    X_BATCH_NAME => p_batch_name,
	    X_SUBLINES_DR_AMOUNT => NULL,
	    X_SUBLINES_CR_AMOUNT => NULL,
	    X_DIST_CR_AMOUNT => l_ft_cr_amount,
	    X_DIST_DR_AMOUNT => l_ft_dr_amount,
	    X_OGM_DR_AMOUNT => NULL,
	    X_OGM_CR_AMOUNT => NULL,
	    X_GL_DR_AMOUNT => NULL,
	    X_GL_CR_AMOUNT => NULL,
	    X_STATUS_CODE => 'N',
	    X_MODE => 'R',
	    X_GL_POSTING_OVERRIDE_DATE =>g_for_total_rec.gl_posting_override_date ,
            X_GMS_POSTING_OVERRIDE_DATE =>g_for_total_rec.gms_posting_override_date,
            X_business_group_id    => p_business_group_id,
	    X_set_of_books_id      => l_set_of_books_id ,
            X_GL_PHASE             => NULL,
            X_GMS_PHASE            => NULL,
            X_ADJ_SUM_BATCH_NAME   => NULL,
--	Introduced the following for bug fix 2916848
	    x_currency_code		=>	g_currency_code,
	    x_exchange_rate_type	=>	l_exchange_rate_type);
       if sql%NOTFOUND then
          fnd_msg_pub.add_exc_msg('PSP_PREGEN','Error while inserting data in Payroll Controls');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
       --dbms_output.PUT_LINE('...Before Updating control_id in pre gen ' );
       UPDATE psp_pre_gen_dist_lines
          SET payroll_control_id = l_control_id
        WHERE time_period_id = l_ft_time_period_id and
              batch_name     = p_batch_name and
              source_type    = 'P' and
              source_code    = l_ft_source_code  and
	      set_of_books_id= l_set_of_books_id and
	   business_group_id = p_business_group_id;
       if sql%NOTFOUND then
          fnd_msg_pub.add_exc_msg('PSP_PREGEN','Error while updating control_id in pre-gen-dist-lines ');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;

         l_ft_source_code	:= g_for_total_rec.source_code;
         l_ft_time_period_id	:= g_for_total_rec.time_period_id;
 	   l_ft_payroll_id	:= g_for_total_rec.payroll_id;
	   l_ft_number_of_cr	:= 0;
	   l_ft_number_of_dr	:= 0;
	   l_ft_dr_amount	:= 0;
	   l_ft_cr_amount	:= 0;
      end if;

      if NVL(g_for_total_rec.dr_cr_flag,' ') = 'D' then
	      l_ft_number_of_dr	:= l_ft_number_of_dr + 1;
	      l_ft_dr_amount	:= l_ft_dr_amount + NVL(g_for_total_rec.distribution_amount,0);
      else
	      l_ft_number_of_cr		:= l_ft_number_of_cr + 1;
	      l_ft_cr_amount		:= l_ft_cr_amount + NVL(g_for_total_rec.distribution_amount,0);
      end if;
    END LOOP;
-- Insert the last record into payroll_controls
          --dbms_output.PUT_LINE('...Before Insert into payroll controls  ' );
          select psp_payroll_controls_s.nextval into l_control_id from dual;

--	Introduced for bug fix 2916848
		OPEN period_end_date_cur(l_ft_time_period_id);
		FETCH period_end_date_cur INTO l_period_end_date;
		CLOSE period_end_date_cur;

		IF (g_pop_exchange_rate_type) THEN
			l_exchange_rate_type := hruserdt.get_table_value
					(p_bus_group_id		=>	p_business_group_id,
					p_table_name		=>	'EXCHANGE_RATE_TYPES',
					p_col_name		=>	'Conversion Rate Type',
					p_row_value		=>	'PAY',
					p_effective_date	=>	l_period_end_date);
		END IF;
--	End of bug fix 2916848

	  PSP_PAYROLL_CONTROLS_PKG.INSERT_ROW (
	    X_ROWID => l_rowid,
	    X_PAYROLL_CONTROL_ID => l_control_id,
	    X_PAYROLL_ACTION_ID => 0,
	    X_PAYROLL_SOURCE_CODE => l_ft_Source_Code,
	    X_SOURCE_TYPE => 'P',
	    X_PAYROLL_ID => l_ft_payroll_id,
	    X_TIME_PERIOD_ID => l_ft_time_period_id,
	    X_NUMBER_OF_CR => l_ft_number_of_cr,
	    X_NUMBER_OF_DR => l_ft_number_of_dr,
	    X_TOTAL_DR_AMOUNT => NULL,
	    X_TOTAL_CR_AMOUNT => NULL,
	    X_BATCH_NAME => p_batch_name,
	    X_SUBLINES_DR_AMOUNT => NULL,
	    X_SUBLINES_CR_AMOUNT => NULL,
	    X_DIST_CR_AMOUNT => l_ft_cr_amount,
	    X_DIST_DR_AMOUNT => l_ft_dr_amount,
	    X_OGM_DR_AMOUNT => NULL,
	    X_OGM_CR_AMOUNT => NULL,
	    X_GL_DR_AMOUNT => NULL,
	    X_GL_CR_AMOUNT => NULL,
	    X_STATUS_CODE => 'N',
	    X_MODE => 'R',
            X_GL_POSTING_OVERRIDE_DATE => g_for_total_rec.gl_posting_override_date,
            X_GMS_POSTING_OVERRIDE_DATE =>g_for_total_rec.gms_posting_override_date ,
            X_business_group_id => p_business_group_id,
	    X_set_of_books_id   => l_set_of_books_id,
            X_GL_PHASE 		=> NULL,
            X_GMS_PHASE 	=> NULL,
            X_ADJ_SUM_BATCH_NAME=> NULL,
--	Introduced the following for bug fix 2916848
	    x_currency_code		=>	g_currency_code,
	    x_exchange_rate_type	=>	l_exchange_rate_type);

       if sql%NOTFOUND then
          fnd_msg_pub.add_exc_msg('PSP_PREGEN','Error while inserting data in Payroll Controls');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
       --dbms_output.PUT_LINE('...Before Updating control_id in pre gen ' );
       UPDATE psp_pre_gen_dist_lines
          SET payroll_control_id = l_control_id
        WHERE time_period_id = l_ft_time_period_id and
              batch_name     = p_batch_name and
              source_type    = 'P' and
              source_code    = l_ft_source_code and
	      set_of_books_id= l_set_of_books_id and
	   business_group_id = p_business_group_id;
       if sql%NOTFOUND then
          fnd_msg_pub.add_exc_msg('PSP_PREGEN','Error while updating control_id in pre-gen-dist-lines ');
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    close get_for_total_csr;
  end if;
  errbuf  :=  l_subline_message;
  retcode := 0;
  commit;
   PSP_MESSAGE_S.Print_Success;



  EXCEPTION
--	Included the following exception handling as part of bug fix 2094036
     WHEN RECORD_ALREADY_LOCKED THEN
	fnd_message.set_name('PSP', 'PSP_PI_BATCH_IN_PROGRESS');
	fnd_message.set_token('BATCH_NAME', p_batch_name);
	l_subline_message := fnd_message.get;
	errbuf := l_error_api_name ||fnd_global.local_chr(10)||l_subline_message;
	retcode:= 2;
     WHEN NO_DATA_FOUND then
       close get_all_from_interface_csr;
       FND_MESSAGE.SET_NAME('PSP','PSP_LD_NO_TRANS');
       l_subline_message := fnd_message.get;
       errbuf	 := l_error_api_name || fnd_global.local_chr(10) || l_subline_message;
       retcode := 0;
           fnd_message.set_name('PSP','PSP_PROGRAM_SUCCESS') ;
           fnd_msg_pub.add;

           psp_message_s.print_error(p_mode=>FND_FILE.log,
                                      p_print_header=>FND_API.G_FALSE);
       PSP_MESSAGE_S.Print_Success;
       return;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then
       ----dbms_output.put_line('Unexpected Error...........');
/*
       fnd_msg_pub.get(p_msg_index	=> FND_MSG_PUB.G_FIRST,
		       p_encoded	=> FND_API.G_FALSE,
		       p_data	        => l_msg_data,
		       p_msg_index_out	=> l_msg_count);

*/
         errbuf	 :=  l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10);
	 retcode := 2;
       rollback;
       psp_message_s.print_error(p_mode => FND_FILE.LOG,
    			  p_print_header => FND_API.G_TRUE);
       return;
     WHEN OTHERS then
       ----dbms_output.put_line('When others  Error...........');
/*
       fnd_msg_pub.get(p_msg_index	=> FND_MSG_PUB.G_FIRST,
		       p_encoded	=> FND_API.G_FALSE,
		       p_data		=> l_msg_data,
		       p_msg_index_out	=> l_msg_count);

*/
       errbuf	 :=  l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10);
       rollback;
	 retcode := 2;
         psp_message_s.print_error(p_mode => FND_FILE.LOG,
					  p_print_header => FND_API.G_TRUE);
       return;
   END;
--




-------------------------------------VALIDATE_PERSON_ID------------------------------------------
-- This procedure is to validate the person id with Oracle HR
--
Procedure Validate_Person_ID(X_Person_ID         IN Number,
                             X_Effective_Date    IN Date,
			     X_Business_group_id IN NUMBER,
                             X_Payroll_ID        IN Number,
                             X_set_of_books_id    IN  Number,
			     X_return_status     OUT NOCOPY Varchar2,
			     X_return_code       OUT NOCOPY Varchar2)  IS

/* Modified the cursor below for "Processing of employee assignments with zero work days"
   enhancement  : Bug 1994421 */

/*****	Modified the following cursor for R12 performance fixes (bug 4507892)
CURSOR   check_person_csr IS
SELECT   a.person_id
FROM     Per_People_F a
WHERE 	 a.Person_ID = x_person_id
-- AND  	 a.current_employee_flag ='Y'  --Added for bug 2624259. Commented for Bug 3424494
AND      (x_effective_date BETWEEN a.EFFECTIVE_START_DATE and a.EFFECTIVE_END_DATE)
AND       x_effective_date <= ( SELECT 	max(b.effective_end_date)
                                FROM    per_assignments_f  b,
                                        pay_payrolls_f c
                        	WHERE 	a.person_id = b.person_id
                                AND     b.business_group_id = x_business_group_id
                                AND     c.payroll_id = b.payroll_id
                                AND     b.assignment_type ='E'   --Added for bug 2624259.
                                AND     c.gl_set_of_books_id  = X_set_of_books_id);
	End of comment for R12 performance fixes (bug 4507892)	*****/
--	New cursor defn. for R12 performance fixes (bug 4507892)
CURSOR	check_person_csr IS
SELECT	ppf.person_id
FROM	per_people_f ppf
WHERE	ppf.person_id = x_person_id
AND	(x_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date)
AND	x_effective_date <=	(SELECT	MAX(paf.effective_end_date)
		 FROM	 per_assignments_f  paf,
			 pay_payrolls_f ppf2
		 WHERE	paf.person_id = x_person_id
		 AND	paf.business_group_id = x_business_group_id
		 AND	ppf2.payroll_id = paf.payroll_id
		 AND	paf.assignment_type ='E'
		 AND	ppf2.gl_set_of_books_id  = x_set_of_books_id);

l_person_id   number(9);

Begin
  open check_person_csr;
  fetch check_person_csr into l_person_id;
  if check_person_csr%NOTFOUND then
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code	:= 'INV_PER';
     close check_person_csr;
     return;
  else
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code	:= '  ';
  end If;
  close check_person_csr;
  Exception
	when no_data_found or too_many_rows then
          x_return_status	:= FND_API.G_RET_STS_ERROR;
          x_return_code	        := 'INV_PER';
          close check_person_csr;
          return;
	when OTHERS then
	   fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Person_id : Unexpected Error');
           x_return_status	:= FND_API.G_RET_STS_ERROR;
           x_return_code	:= 'OTHER';
           close check_person_csr;
End  Validate_Person_ID;

-----------------------------VALIDATE_ASSIGNMENT_ID-------------------------------------------
--This procedure is to validate Assignment ID with Oracle HR
--
Procedure Validate_Assignment_ID(X_Assignment_ID     IN Number,
                                 X_Effective_Date    IN Date,
			         X_return_status     OUT NOCOPY varchar2,
			         X_return_code       OUT NOCOPY varchar2,
				 X_business_group_id IN NUMBER,
				 X_set_of_books_id   IN NUMBER)  IS
CURSOR check_assg_csr IS
SELECT   assignment_id
FROM     per_assignments_f a, pay_payrolls_f b
WHERE    assignment_id = x_assignment_id
AND      a.assignment_type ='E'  --Added for bug 2624259.
and      a.payroll_id=b.payroll_id
AND      x_effective_date between a.effective_start_date and a.effective_end_date
AND      x_effective_date between b.effective_start_date and b.effective_end_date
AND      a.business_group_id    = X_business_group_id
AND      b.gl_set_of_books_id   = X_set_of_books_id;

l_assignment_id   number(9);

Begin
  open check_assg_csr;
  fetch check_assg_csr into l_assignment_id;
  if check_assg_csr%NOTFOUND then
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code	:= 'INV_ASG';
     close check_assg_csr;
     return;
  else
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code	:= '  ';
  end If;
  close check_assg_csr;

  Exception
	when no_data_found or too_many_rows then
          x_return_status   := FND_API.G_RET_STS_ERROR;
          x_return_code	    := 'INV_ASG';
          close check_assg_csr;
          return;
	when OTHERS then
	  fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Assignment_id : Unexpected Error');
          x_return_status	:= FND_API.G_RET_STS_ERROR;
          x_return_code	:= 'OTHER';
          close check_assg_csr;
End Validate_Assignment_ID;

------------------------VALIDATE_PAYROLL_ID---------------------------------------------------
-- This procedure is to validate payroll ID with Oracle Payroll
--
Procedure Validate_Payroll_ID(X_Payroll_ID         IN Number,
                              X_Assignment_ID      IN Number,
                              X_Effective_Date     IN Date,
		              X_return_status      OUT NOCOPY varchar2,
			      X_return_code        OUT NOCOPY varchar2,
			      X_business_group_id  IN  Number,
			      X_set_of_books_id    IN  Number)  IS
CURSOR check_payroll_csr IS
SELECT a.payroll_id
FROM   pay_payrolls_f a, per_assignments_f b
WHERE  a.payroll_id = x_payroll_id
AND    x_effective_date between a.effective_start_date and a.effective_end_date
AND    a.payroll_id = b.payroll_id
AND    b.assignment_id = X_assignment_id
AND    (X_effective_date between b.effective_start_date and b.effective_end_date)
AND    a.business_group_id    = X_business_group_id
AND    a.gl_set_of_books_id   = X_set_of_books_id;

l_payroll_id  number(9);

Begin
  ----dbms_output.put_line('payroll id     ' || to_char(x_payroll_id));
  ----dbms_output.put_line('Assignment ID  ' || to_char(x_assignment_id));
  ----dbms_output.put_line('Effective Date ' || to_char(x_effective_date));

      begin
        open check_payroll_csr;
        fetch check_payroll_csr into l_payroll_id;
        if check_payroll_csr%NOTFOUND then
           ----dbms_output.put_line('%NOTFOUND');
           x_return_status	:= FND_API.G_RET_STS_ERROR;
           x_return_code	:= 'INV_PID';
          close check_payroll_csr;
          return;
        else
          ----dbms_output.put_line('%SUCCESS');
          x_return_status	:= FND_API.G_RET_STS_SUCCESS;
          x_return_code		:= '  ';
        end If;
        close check_payroll_csr;
        Exception
	     when no_data_found or too_many_rows then
               ----dbms_output.put_line('NO DATA FOUND');
               x_return_status	:= FND_API.G_RET_STS_ERROR;
               x_return_code	:= 'INV_PID';
               close check_payroll_csr;
               return;
           when OTHERS then
               ----dbms_output.put_line('OTHERS ');
	         fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Payroll_id : Unexpected Error');
               x_return_status	:= FND_API.G_RET_STS_ERROR;
               x_return_code	:= 'OTHER';
               close check_payroll_csr;
           return;
       end;
End Validate_Payroll_ID;


----------------------------------VALIDATE_PAYROLL_PERIOD_ID-----------------------------------
-- This procedure is to validate Time Period id with Oracle HR
--
Procedure Validate_Payroll_Period_ID(X_Payroll_ID IN number,
                                     X_Payroll_Period_ID IN number,
                                     X_Effective_Date IN Date,
		                     X_return_status  OUT NOCOPY varchar2,
			             X_return_code    OUT NOCOPY varchar2)  IS
CURSOR check_period_csr IS
SELECT Time_Period_id
FROM   Per_Time_Periods
WHERE  Payroll_id = x_Payroll_ID
	and Time_Period_ID = x_Payroll_Period_ID
	and (x_Effective_Date between start_date and end_date);

l_period_id 	number(9);

Begin
  open check_period_csr;
  fetch check_period_csr into l_period_id;
  if check_period_csr%NOTFOUND then
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code		:= 'INV_TPI';
     close check_period_csr;
     return;
  else
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code		:= '  ';
  end If;
  close check_period_csr;
  Exception
	when no_data_found or too_many_rows then
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code	:= 'INV_TPI';
        close check_period_csr;
        return;
	when OTHERS then
	   fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Period_id : Unexpected Error');
         x_return_status	:= FND_API.G_RET_STS_ERROR;
         x_return_code	:= 'OTHER';
        close check_period_csr;
        return;
End Validate_Payroll_Period_ID;
----------------------------------VALIDATE_PAYROLL_SOURCE_ID-----------------------------------
-- This procedure is to validate Source code with Psp_payroll_sources
--
Procedure Validate_Payroll_Source_Code(x_Payroll_Source_Code IN varchar2,
		                        X_return_status  OUT NOCOPY varchar2,
			                 X_return_code    OUT NOCOPY varchar2)  IS
CURSOR check_source_csr IS
SELECT source_code
FROM   PSP_PAYROLL_SOURCES
WHERE  source_code = x_Payroll_Source_Code and
	 source_type = 'P';
l_lookup_code	varchar2(30);
Begin
  open check_source_csr;
  fetch check_source_csr into l_lookup_code;
  if check_source_csr%NOTFOUND then
     --dbms_output.PUT_LINE('Enter NOTFOUND......8');
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code		:= 'INV_SRC';
     close check_source_csr;
     return;
  else
     --dbms_output.PUT_LINE('Enter Success.....8');
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code		:= '  ';
  end If;
  close check_source_csr;
  Exception
	when no_data_found or too_many_rows then
        --dbms_output.PUT_LINE('Enter Too_many_rows....8');
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code	:= 'INV_SRC';
        close check_source_csr;
        return;
	when OTHERS then
        --dbms_output.PUT_LINE('Enter Too_many_rows....8');
	   fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Payroll_Source_Code : Unexpected Error');
         x_return_status	:= FND_API.G_RET_STS_ERROR;
         x_return_code	:= 'OTHER';
        close check_source_csr;
        return;
End Validate_Payroll_Source_Code;
----------------------------------VALIDATE_ELEMENT_TYPE_ID-----------------------------------
--This procedure is to validate Element types with psp element types
--
Procedure Validate_Element_Type_ID(X_Element_Type_ID IN Number,
                                   X_Payroll_Period_ID IN Number,
--	Introduced BG/SOB parameters for bug fix 3098050
                                   x_business_group_id	IN NUMBER,
                                   x_set_of_books_id	IN NUMBER,
		                      X_return_status  OUT NOCOPY varchar2,
			               X_return_code    OUT NOCOPY varchar2)  IS
CURSOR check_element_csr IS
SELECT a.element_type_id
FROM   psp_element_types a,
	per_time_periods c
WHERE a.element_type_id = x_Element_Type_ID and
	c.time_period_id = x_payroll_period_id
--	and ((c.start_date between a.start_date_active and a.end_date_active)
--		or (c.end_date between a.start_date_active and a.end_date_active)
--		or ((a.start_date_active < c.start_date) and (a.end_date_active > c.end_date)))
--	Introduced this for bug fix 2916848
AND	c.start_date <= a.end_date_active
AND	c.end_date >= a.start_date_active
AND	EXISTS (SELECT	1
		FROM	pay_element_types_f pef
		WHERE	pef.element_type_id = a.element_type_id
		AND	(	pef.output_currency_code = g_currency_code
			OR	g_currency_code = 'STAT')
		AND	pef.effective_end_date >= a.start_date_active
		AND	pef.effective_start_date <= a.end_date_active)
--	Introduced for bug fix 3098050
AND	a.business_group_id = x_business_group_id
AND	a.set_of_books_id = x_set_of_books_id;

l_element_id	number(9);

Begin
  open check_element_csr;
  fetch check_element_csr into l_element_id;
  if check_element_csr%NOTFOUND then
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code		:= 'INV_ELE';
     close check_element_csr;
     return;
  else
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code		:= '  ';
  end If;
  close check_element_csr;
  Exception
	when no_data_found or too_many_rows then
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code	:= 'INV_ELE';
        close check_element_csr;
        return;
	when OTHERS then
	   fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Element_Type_Id : Unexpected Error');
         x_return_status	:= FND_API.G_RET_STS_ERROR;
         x_return_code	:= 'OTHER';
        close check_element_csr;
        return;
End Validate_Element_Type_ID;
--
----------------------------------VALIDATE_PROJECT_DETAILS-----------------------------------
-- This procedure is to validate POETA
Procedure  Validate_Project_details(X_Project_ID	IN NUMBER,
				    X_task_id		IN NUMBER,
				    X_award_id		IN NUMBER,
				    X_expenditure_type	IN VARCHAR2,
                                    X_exp_org_id	IN NUMBER,
				    X_gms_pa_install    IN VARCHAR2,
	  			    X_Person_ID	        IN VARCHAR2,
                             	    X_Effective_date	IN DATE,
				    X_return_status	OUT NOCOPY VARCHAR2,
				    X_return_code	OUT NOCOPY VARCHAR2) IS
/*************************************************************************************
Commented for Bug 2096440 - Suspense Reason Code  to display the error code returned by PA instead of using  custom
code. -lveerubh

CURSOR check_project_csr IS
SELECT project_id
FROM   gms_projects_expend_v
where  project_id = x_project_id;

CURSOR check_exp_org_csr IS
SELECT organization_id
FROM   pa_organizations_expend_v
WHERE  organization_id = x_exp_org_id
AND    active_flag = 'Y';

CURSOR check_task_csr IS
SELECT task_id
FROM   pa_tasks_expend_v
WHERE  project_id = x_project_id and
       task_id    = x_task_id;
--End of Commenting for Bug 2096440
****************************************************************************************/

/* Commented for bug 2054610
CURSOR check_award_csr IS
SELECT award_id
FROM   gms_awards_basic_v
WHERE  award_id   = x_award_id
and    project_id = x_project_id
and    ROWNUM = 1; */
/************************************************************************************
Commented for Bug 2096440 - Suspense Reason Code  to display the error code returned by PA instead of using custom
code. -lveerubh
l_project_id		number(15);

CURSOR check_exp_type_csr IS
SELECT et.expenditure_type
FROM   pa_expenditure_types_expend_v et
WHERE	et.system_linkage_function IN ('STRAIGHT_TIME', 'ST') and
	exists(select a.expenditure_type
			from gms_allowable_expenditures a
			where a.expenditure_type = et.expenditure_type
			and a.allowability_schedule_id = (select allowable_schedule_id
								from gms_awards
								where award_id = x_award_id))
	and	et.expenditure_type = x_Expenditure_Type;


CURSOR check_exp_type_csr1 IS
SELECT et.expenditure_type
FROM   pa_expenditure_types_expend_v et
WHERE	et.system_linkage_function IN ('STRAIGHT_TIME', 'ST')
and	et.expenditure_type = x_Expenditure_Type;


l_exp_type  varchar2(80);
l_control_num	number(1)  := 0;
--End of Commenting for Bug 2096440
*****************************************************************************/
l_msg_app  VARCHAR2(80);
l_msg_type VARCHAR2(80);
l_msg_token1 VARCHAR2(80);
l_msg_token2 VARCHAR2(80);
l_msg_token3 VARCHAR2(80);
l_msg_count NUMBER;
l_patc_status 	VARCHAR2(2000);		-- Increased the width from 80 to 2000 for bug fix 2636830
l_award_status 	VARCHAR2(2000);		-- Increased the width from 80 to 2000 for bug fix 2636830
l_billable_flag VARCHAR2(80);

begin

IF X_GMS_PA_INSTALL IN ('PA_ONLY','PA_GMS') THEN
 --- added if condition for 2985061
 if x_exp_org_id is null then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_return_code   := 'NULL_EXP_ORG';
    return;
 else
  pa_transactions_pub.validate_transaction(
		x_project_id		=> x_project_id,
		x_task_id		=> x_task_id,
		x_ei_date		=> x_effective_date,
		x_expenditure_type	=> x_expenditure_type,
		x_non_labor_resource	=> null,
		x_person_id		=> x_person_id,
		x_incurred_by_org_id	=> x_exp_org_id,
		x_calling_module	=> 'PSPLDPGB',
		x_msg_application	=> l_msg_app,
		x_msg_type		=> l_msg_type,
		x_msg_token1		=> l_msg_token1,
		x_msg_token2		=> l_msg_token2,
		x_msg_token3		=> l_msg_token3,
		x_msg_count		=> l_msg_count,
		x_msg_data		=> l_patc_status,
		x_billable_flag		=> l_billable_flag,
                p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter

	     ----dbms_output.put_line('patc stat 1 '|| l_patc_status);
	     ----dbms_output.put_line('x_project_id'|| x_project_id);


		 if l_patc_status is not null then
                    x_return_status	:= FND_API.G_RET_STS_ERROR;
----Commented for Bug 2096440 : Added the following line-
----Passing l_patc_status as the return code ,which will be passed to stick_suspense_account procedure
----as suspense_reason_code
                   -- x_return_code	:= 'INV_PATC';
		      x_return_code	:= substr(l_patc_status,1,50); --Added the line
                    return;
	         end if;
-----------
--IF X_GMS_PA_INSTALL = 'PA_GMS' THEN			Commented for bug fix 2908859
IF (psp_general.get_sponsored_flag(x_project_id) = 'Y') THEN		-- Introduced for bug fix 2908859
  --l_control_num	:= 4; Bug 2096440
/* Commented for bug 2054610
  open check_award_csr;
  fetch check_award_csr into l_project_id;
  if check_award_csr%NOTFOUND then
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code	:= 'INV_AI';
     close check_award_csr;
     return;
  else
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code	:= '  ';
  end If;
  close check_award_csr; */

  if l_patc_status is null then
     gms_transactions_pub.validate_transaction
			(x_project_id,
		   	x_task_id,
			x_award_id,
		   	x_expenditure_type,
			x_effective_date,
			'PSPLDPGB',
			l_award_status);

      IF l_award_status IS NOT NULL THEN
                    x_return_status	:= FND_API.G_RET_STS_ERROR;
----Commented for Bug 2096440 : Added the following line-
----Passing l_award_status as the return code ,which will be passed to stick_suspense_account procedure
----as suspense_reason_code
                    --x_return_code	:= 'INV_PATCAW';
		      x_return_code 	:= substr(l_award_status,1,50);
		    return;
      END IF;
   END IF;
  END IF;  --End if of PA_GMS  , for Bug 2096440
 end if; ---2985061
 END IF;   --For Bug 2096440

           x_return_status	:= FND_API.G_RET_STS_SUCCESS;
           x_return_code	:= '  ';
/*******************************************************************************
Commented  For Bug 2096440

 l_control_num := 5;
  open check_exp_type_csr;
  fetch check_exp_type_csr into l_exp_type;
  if check_exp_type_csr%NOTFOUND then
     x_return_status	:= FND_API.G_RET_STS_ERROR;
     x_return_code	:= 'INV_ET';
     close check_exp_type_csr;
     return;
  else
     x_return_status	:= FND_API.G_RET_STS_SUCCESS;
     x_return_code	:= '  ';
  end If;
END IF;
  IF X_GMS_PA_INSTALL = 'PA_ONLY' THEN
     l_control_num	:= 5;
     open check_exp_type_csr1;
     fetch check_exp_type_csr1 into l_exp_type;
        if check_exp_type_csr1%NOTFOUND then
           x_return_status	:= FND_API.G_RET_STS_ERROR;
           x_return_code	:= 'INV_ET';
           close check_exp_type_csr1;
           return;
        else
           x_return_status	:= FND_API.G_RET_STS_SUCCESS;
           x_return_code	:= '  ';
        end If;
  EN IF;
 END IF;
--End of Commenting for Byug 2096440
************************************************************************************/

  EXCEPTION
	when OTHERS then
	   fnd_msg_pub.add_exc_msg('PSP_PREGEN','Validate_Project_Details : Unexpected Error');
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_return_code	 := 'OTHER';
/*************************************************************************************
Commenting for bug 2096440
         if l_control_num = 1 then
            close check_project_csr;
         elsif l_control_num = 2 then
            close check_exp_org_csr;
         elsif l_control_num = 3 then
            close check_task_csr;
         elsif l_control_num = 4 then
           -- close check_award_csr; --Commented for bug 2054610;
            null; --Added for bug 2054610.
         elsif l_control_num = 5 then
            close check_exp_type_csr;
         end if;
************************************************************************************/
        return;
END;
--
----------------------------------UPDATE_RECORD_WITH_ERROR-----------------------------------
-- This procedure is to update the psp_distribution_interface table
-- with given error code
--
Procedure update_record_with_error(X_distribution_interface_id	IN Number,
					 X_error_code				IN Varchar2,
                                  X_return_status			OUT NOCOPY varchar2) IS
begin
  UPDATE psp_distribution_interface
  SET    status_code = 'E',
         error_code  = x_error_code
  WHERE  distribution_interface_id = x_distribution_interface_id;

  if SQL%NOTFOUND then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;
  --dbms_output.PUT_LINE('.....Update Record With Error ');
  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then
       fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_error :  Error while updating');
       x_return_status	:= FND_API.G_RET_STS_ERROR;
     WHEN OTHERS   then
      fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_error :  Unexpected error');
      x_return_status	:= FND_API.G_RET_STS_ERROR;

end;
--
----------------------------------UPDATE_RECORD_WITH_VALID-----------------------------------
-- This procedure is to update psp_distribution_interface table with Valid status
--
Procedure update_record_with_valid(X_distribution_interface_id	IN Number,
					 X_return_status			OUT NOCOPY varchar2) IS
begin
  UPDATE psp_distribution_interface
  SET    status_code = 'V',
         error_code  = NULL
  WHERE  distribution_interface_id = x_distribution_interface_id;

  if SQL%NOTFOUND then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then
       fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_valid :  Error while updating');
       x_return_status	:= FND_API.G_RET_STS_ERROR;
     WHEN OTHERS   then
      fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_valid :  Unexpected error');
      x_return_status	:= FND_API.G_RET_STS_ERROR;

end;
--
Function get_least_date(x_time_period_id IN Number,x_person_id IN Number, x_gl_ccid IN Number,
			    x_project_id IN Number, x_award_id IN Number,
                         x_task_id IN Number,x_distribution_date IN Date)  Return Date IS
l_project_end_date	DATE;
l_award_end_date	DATE;
l_payroll_end_date  DATE;
l_task_end_date     DATE;
l_effective_date    DATE;
l_payroll_begin_date        DATE;  -- Added by Pvelamur as a fix for 900768
l_termination_date   DATE;

begin
  SELECT start_date,end_date
   into l_payroll_begin_date,l_payroll_end_date
    FROM per_time_periods
   WHERE time_period_id = x_time_period_id;

 if NVL(x_gl_ccid,0) = 0 and NVL(x_project_id,0)  = 0 then
    return x_distribution_date;
 end if;
  If NVL(x_gl_ccid,0) = 0 then
     SELECT  nvl(completion_date,l_payroll_end_date)
       INTO    l_project_end_date
       FROM    pa_projects_all
      WHERE   project_id = x_project_id;
--
      SELECT  nvl(end_date_active,l_payroll_end_date)
        INTO  l_award_end_date
        FROM  gms_awards
       WHERE  award_id = x_award_id;
--
-- The following code added by PVELAMUR to fix bug 888089
  SELECT  nvl(completion_date,l_payroll_end_date)
   INTO   l_task_end_date
   FROM   pa_tasks
  WHERE   task_id = x_task_id;
-- The above code added by PVELAMUR tp fix the bug 888089
-- The following code added by PVELAMUR to fix bug 900768
  SELECT  nvl(actual_termination_date,l_payroll_end_date)
    into l_termination_date
   FROM    per_periods_of_service
   WHERE   person_id = x_person_id and
        (date_start between l_payroll_begin_date and l_payroll_end_date) ;
-- The above code added by PVELAMUR tp fix the bug 900768

      SELECT least(l_payroll_end_date,l_project_end_date,l_award_end_date,l_task_end_date,l_termination_date)
        INTO l_effective_date
        FROM dual;
       return l_effective_date;
   else
       return l_payroll_end_date;
   end if;
--
EXCEPTION
  WHEN OTHERS THEN
--     fnd_msg_pub.add_exc_msg('PSP_PREGEN','GET_LEAST_DATE');
     return x_distribution_date;
END get_least_date;
--

/* autopop stuff      */

--   Called from Import_Pregen when autopop profile option is set to 'Y'
-- fetches all records from psp_distribution_interface table belongs to given batch name and
-- validates each record whether it is valid or not for purposes of running auto-population.
-- If a record is valid then auto-population will replace the expenditure type for
-- project lines or the GL code combination ID for Gl lines.  The regular import Pregen process is
-- called separately and will re-do valoidations to insure the new expenditure type and other info
-- is valid before it imports the lines into LDM.
--  Subha 10/mar/2000  Multi-org and validation changes

Procedure Autopop( X_Batch_name         IN VARCHAR2,
                 X_Set_of_Books_Id    IN NUMBER,
                 X_Business_Group_Id  IN NUMBER,
                 X_Operating_Unit     IN NUMBER,
                 X_Gms_Pa_Install     IN  VARCHAR2,
                 X_Return_Status     OUT NOCOPY VARCHAR2
)IS

--For Bug 2651339 : Introduced the status code check
--to avoid revalidation of valid records
CURSOR 	get_all_from_interface_csr is
SELECT 	*
FROM   	psp_distribution_interface
WHERE  	batch_name = x_batch_name
AND 	status_code <> 'V'; --Introduced for bug 2651339
-- FOR UPDATE; Commented FOR UPDATE for bug fix 2094036

g_pregen_rec  get_all_from_interface_csr%ROWTYPE;

--For Bug 2616807 : Modifying the Select to check for correct source type 'P' instead of 'N'
CURSOR       get_batch_name_csr is
SELECT       count(*)
FROM         psp_payroll_controls
WHERE        source_type = 'P' and
             batch_name = x_batch_name;

l_batch_name_count  number;

-- Error Handling variables
l_error_api_name		varchar2(2000);
l_return_status		varchar2(1);
l_return_code		varchar2(30);
l_batch_status		number(1) 	:= 0;
l_msg_count			number;
l_msg_data			varchar2(2000);
l_msg_index_out			number;
--
l_api_name			varchar2(30)	:= 'PSP_PREGEN';
l_subline_message		varchar2(200);
--

-- Auto-Population Variables
l_new_expenditure_type        varchar2(30);
l_new_gl_code_combination_id  number(15);
l_autopop_status              varchar2(1);

BEGIN
  --dbms_output.PUT_LINE('................0');
/* Commented the following as the locking is taken care in the main procedure
  open get_all_from_interface_csr;
  fetch get_all_from_interface_csr into g_pregen_rec;

  if get_all_from_interface_csr%NOTFOUND  then
     RAISE NO_DATA_FOUND;
  end if;
  close get_all_from_interface_csr;
End of bug fix 2094036	*/

  --dbms_output.PUT_LINE('................1');
  open get_batch_name_csr;
    fetch get_batch_name_csr into l_batch_name_count;
  close get_batch_name_csr;

  if NVL(l_batch_name_count,0) > 0 then
      fnd_message.set_name('PSP','PSP_PI_INVALID_BATCH_NAME');
      fnd_message.set_token('PSP_BATCH_NAME',x_batch_name);
      fnd_msg_pub.add;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  open get_all_from_interface_csr;
  LOOP
      --dbms_output.PUT_LINE('................2');
      fetch get_all_from_interface_csr into g_pregen_rec;
      EXIT WHEN get_all_from_interface_csr%NOTFOUND ; -- Exit when last record is reached

        --dbms_output.PUT_LINE('................3');
        --dbms_output.PUT_LINE('Interface ID....' || to_char(g_pregen_rec.distribution_interface_id));

	  Validate_Person_ID(      X_Person_ID		=>	g_pregen_rec.person_id,
                                   X_Effective_date	=>	g_pregen_rec.distribution_date,
                                   X_Payroll_ID        =>     g_pregen_rec.payroll_id,
                                   X_set_of_books_id   =>     x_set_of_books_id,
				   X_return_status	=>	x_return_status,
				   X_return_code	=> 	l_return_code,
                                   X_Business_group_Id  => x_business_group_id
                                  );
        --dbms_output.PUT_LINE('................4');
        if x_return_status		<> FND_API.G_RET_STS_SUCCESS then
           l_batch_status		:= 1;
           if l_return_code = 'OTHER'	then
              l_error_api_name := 'VALIDATE_PERSON_ID';
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           else
             update_record_with_error(
                 X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
                 X_error_code			=> l_return_code,
                 X_return_status		=> x_return_status);
             if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             end if;
           end if;
        else

          Validate_Assignment_ID(X_Assignment_ID	=>	g_pregen_rec.assignment_id,
				         X_Effective_Date	=>	g_pregen_rec.distribution_date,
				         X_Return_Status	=>	x_return_status,
				         X_Return_Code		=>	l_return_code,
                                         X_Business_Group_Id    =>x_business_group_id,
                                         X_Set_of_Books_Id      => x_set_of_books_id);
          --dbms_output.PUT_LINE('................5');
          if x_return_status	<> FND_API.G_RET_STS_SUCCESS then
             l_batch_status		:= 1;
             if l_return_code = 'OTHER' then
                l_error_api_name	:= 'VALIDATE_ASSIGNMENT_ID';
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
             else
               update_record_with_error(X_distribution_interface_id => g_pregen_rec.distribution_interface_id,
		  	                X_error_code		    => l_return_code,
                                        X_return_status		    => x_return_status);
               if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
               end if;
             end if;

          else
---For Bug 2616807 : Validate Payroll Id and Validate Payroll source Code missing from AUTOPOP
--Adding the following code
			Validate_Payroll_ID(X_Payroll_ID          => g_pregen_rec.payroll_id,
                                  X_Assignment_ID       => g_pregen_rec.assignment_id,
                                  X_Effective_Date      => g_pregen_rec.distribution_date,
                                  X_return_status       => x_return_status,
                                  X_return_code         => l_return_code,
                                  X_business_group_id   => x_business_group_id,
                                  X_set_of_books_id     => x_set_of_books_id);

           IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
               l_batch_status           := 1;
               IF l_return_code = 'OTHER' THEN
                  l_error_api_name      := 'VALIDATE_PAYROLL_ID';
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSE
                  update_record_with_error(X_distribution_interface_id   => g_pregen_rec.distribution_interface_id,
                                          X_error_code                  => l_return_code,
                                          X_return_status               => x_return_status);
                 IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
               END IF;
           ELSE
            --End of Changes for Bug 2616807
             Validate_Payroll_Period_ID(X_Payroll_ID            =>      g_pregen_rec.payroll_id,
                                        X_Payroll_Period_ID     =>      g_pregen_rec.time_period_id,
                                        X_Effective_Date        =>      g_pregen_rec.distribution_date,
                                        X_return_status         =>      x_return_status,
                                        X_return_code           =>      l_return_code);
              --dbms_output.PUT_LINE('................7');
              if x_return_status        <> FND_API.G_RET_STS_SUCCESS then
                 l_batch_status         := 1;
                 if l_return_code = 'OTHER' then
                    l_error_api_name    := 'VALIDATE_PAYROLL_PERIOD_ID';
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                 else
                   update_record_with_error(X_distribution_interface_id => g_pregen_rec.distribution_interface_id,
                                            X_error_code                        => l_return_code,
                                     X_return_status                    => x_return_status);
                   if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   end if;
                 end if;
          else
--For Bug fix 2985061 :  adding the  validation of DR_CR Flag

            VALIDATE_DR_CR_FLAG ( X_DR_CR_FLAG   => g_pregen_rec.dr_cr_flag,
                                X_return_status  => x_return_status,
                                X_return_code    => l_return_code);

                IF x_return_status      <> FND_API.G_RET_STS_SUCCESS  THEN
                   l_batch_status               := 1;
                   IF l_return_code = 'OTHER' THEN
                      l_error_api_name  := 'VALIDATE_DR_CR_FLAG';
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                     update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
                                              X_error_code                 => l_return_code,
                                              X_return_status              => x_return_status);
                     IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                   END IF;
            ELSE
--End of Changes for Bug 2985061

--For Bug fix 2616807 :  adding the  validation of Source code
           Validate_Payroll_Source_Code(X_Payroll_Source_Code   => g_pregen_rec.source_code,
                                                X_return_status         => x_return_status,
                                                X_return_code           => l_return_code);

                IF x_return_status      <> FND_API.G_RET_STS_SUCCESS  THEN
                   l_batch_status               := 1;
                   IF l_return_code = 'OTHER' THEN
                      l_error_api_name  := 'VALIDATE_PAYROLL_SOURCE_CODE';
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                     update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
                                              X_error_code                 => l_return_code,
                                              X_return_status              => x_return_status);
                     IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                   END IF;
	         ELSE
--End of Changes for Bug 2616807
		Validate_Element_Type_ID(X_Element_Type_ID	=> g_pregen_rec.element_type_id,
					 X_Payroll_Period_ID	=> g_pregen_rec.time_period_id,
--	Introduced BG/SOB parameters for bug fix 3098050
					x_business_group_id	=>	x_business_group_id,
					x_set_of_books_id	=>	x_set_of_books_id,
	  		                 X_return_status	=> x_return_status,
				         X_return_code		=> l_return_code);
            --dbms_output.PUT_LINE('................9');
            if x_return_status	<> FND_API.G_RET_STS_SUCCESS then
              l_batch_status		:= 1;
              if l_return_code = 'OTHER' then
                l_error_api_name	:= 'VALIDATE_ELEMENT_TYPE_ID';
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              else
                update_record_with_error(X_distribution_interface_id => g_pregen_rec.distribution_interface_id,
					           X_error_code			   => l_return_code,
                                         X_return_status		   => x_return_status);
                if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
              end if;

            elsif g_pregen_rec.gl_code_combination_id IS NULL and
                      g_pregen_rec.project_id IS NULL then
              l_batch_status	:= 1;
              l_return_code	:= 'NUL_GLP';
              update_record_with_error(
                         X_distribution_interface_id	=>   g_pregen_rec.distribution_interface_id,
  		         X_error_code			=> l_return_code,
                         X_return_status		=> x_return_status);
              if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;
            elsif g_pregen_rec.gl_code_combination_id IS NOT NULL and
                        g_pregen_rec.project_id IS NOT NULL then
              l_batch_status		:= 1;
              l_return_code	:= 'NOT_GLP';
              update_record_with_error(
                               X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
                               X_error_code			=> l_return_code,
                               X_return_status	                => x_return_status);

              if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_UNEXPECTED_ERROR;
              end if;

            elsif g_pregen_rec.project_id is not null then     /* Bug fix 2985061 */
                     hr_utility.trace('project_id is not null');
--            elsif (NVL(g_pregen_rec.project_id,0) <> 0)   then

/********************************************************************************************************

Batch contains  a  project record , yet projects is not installed. cannot proceed

*********************************************************************************************************/


                 if x_gms_pa_install ='NO_PA_GMS' then
                 l_batch_status:=1;
                 x_return_status:= FND_API.G_RET_STS_ERROR;
                 l_return_code:='NO_PA';
                  update_record_with_error(
                    X_distribution_interface_id	=>  g_pregen_rec.distribution_interface_id,
                    X_error_code		=> l_return_code,
                    X_return_status		=> x_return_status);
                  if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  end if;



           else  /* projects is installed . Can proceed with the validations */

 		  Validate_Project_details(X_Project_ID         => g_pregen_rec.project_id,
					   X_task_id		=> g_pregen_rec.task_id,
					   X_award_id		=> g_pregen_rec.award_id,
					   X_expenditure_type	=> g_pregen_rec.expenditure_type,
                                           X_exp_org_id		=> g_pregen_rec.expenditure_organization_id,
         			           X_gms_pa_install     => x_gms_pa_install,
	  				   X_Person_ID	        => g_pregen_rec.person_id,
                             		   X_Effective_date	=> g_pregen_rec.distribution_date,
				           X_return_status	=> x_return_status,
				           X_return_code	=> l_return_code);
     	        --dbms_output.PUT_LINE('................10');
		  --dbms_output.PUT_LINE('return status.....' || l_return_status);
		  --dbms_output.PUT_LINE('return code.....' || l_return_code);

           end if;
              if x_return_status	<> FND_API.G_RET_STS_SUCCESS then
               --- l_batch_status := 1; /* Bug 2007521 */
                if l_return_code = 'OTHER' then
                  l_error_api_name	:= 'VALIDATE_PROJECTS_DETAILS';
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                else
                  if g_use_pre_gen_suspense = 'Y' then
	                  stick_suspense_account( g_pregen_rec.assignment_id,
	                                             g_pregen_rec.distribution_date,
                                                     x_gms_pa_install,
                                                     g_pregen_rec.person_id,
	                                             g_pregen_rec.distribution_interface_id,
	                                             l_return_code,
                                                     x_business_group_id,
                                                     x_set_of_books_id,
	                                             x_return_status);
                          if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                             raise FND_API.G_EXC_UNEXPECTED_ERROR;
	                  end if;
                           /* Bug 2007521: moved code into stick suspense a/c
                           update_record_with_valid(X_distribution_interface_id=>
                                                    g_pregen_rec.distribution_interface_id,
                                                   X_return_status	      => l_return_status);
                          if l_return_status  <> FND_API.G_RET_STS_SUCCESS then
                             raise FND_API.G_EXC_UNEXPECTED_ERROR;
	                  end if; */
                    else
                        l_batch_status := 1;
                        update_record_with_error(
                        X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
                        X_error_code	        	=> l_return_code,
                        X_return_status	        	=> x_return_status);

                        if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;
                        end if;
                   end if;
                end if;
              else
                -- Call Auto-Population for a new expenditure type.
                hr_utility.trace('Calling Autopop for Exp type');
                psp_autopop.main(p_acct_type                   => 'E',
				         p_person_id                   => g_pregen_rec.person_id,
					   p_assignment_id               => g_pregen_rec.assignment_id,
				         p_element_type_id             => g_pregen_rec.element_type_id,
					   p_project_id                  => g_pregen_rec.project_id,
					   p_expenditure_organization_id => g_pregen_rec.expenditure_organization_id,
					   p_task_id                     => g_pregen_rec.task_id,
					   p_award_id                    => g_pregen_rec.award_id,
					   p_expenditure_type            => g_pregen_rec.expenditure_type,
                                           p_gl_code_combination_id      => null,
					   p_payroll_date                => g_pregen_rec.distribution_date,
                                           p_set_of_books_id             => x_set_of_books_id,
                                           p_business_group_id           => x_business_group_id,
					   ret_expenditure_type          => l_new_expenditure_type,
					   ret_gl_code_combination_id    => l_new_gl_code_combination_id,
					   retcode                       => l_autopop_status);

                IF l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  l_batch_status := 1;
                  l_return_code := 'AUTOPOP_EXP_ERR';
                  update_record_with_error(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
		   			             X_error_code	   => l_return_code,
                                           X_return_status     => x_return_status);
                  if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  end if;
                ELSIF l_autopop_status = FND_API.G_RET_STS_ERROR THEN
          /********Will not populate distribution interface table if autopop returns no value
           ******** as it is not considered an error condition.
                  l_return_code := 'AUTOPOP_NO_VAL';
                  update_record_with_error(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
		   			             X_error_code	   => l_return_code,
                                           X_return_status     => x_return_status);
                  if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  end if;
            *********************************************************/

                  l_return_code 	:= 0;
                  update_record_with_valid(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
                                           X_return_status => x_return_status);
                  if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  end if;
                ELSIF l_autopop_status = FND_API.G_RET_STS_SUCCESS THEN
                     update_record_with_exp(X_distribution_interface_id  =>
								     g_pregen_rec.distribution_interface_id,
						     X_expenditure_type => l_new_expenditure_type,
						     X_return_status => x_return_status);
                     if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     end if;
                  /* Introduced validation for Bug 2007521 */
 		  Validate_Project_details(X_Project_ID         => g_pregen_rec.project_id,
					   X_task_id		=> g_pregen_rec.task_id,
					   X_award_id		=> g_pregen_rec.award_id,
					   X_expenditure_type	=> l_new_expenditure_type,
                                           X_exp_org_id		=> g_pregen_rec.expenditure_organization_id,
         			           X_gms_pa_install     => x_gms_pa_install,
	  				   X_Person_ID	        => g_pregen_rec.person_id,
                             		   X_Effective_date	=> g_pregen_rec.distribution_date,
				           X_return_status	=> x_return_status,
				           X_return_code	=> l_return_code);

                  if x_return_status	<> FND_API.G_RET_STS_SUCCESS then
                    if l_return_code = 'OTHER' then
                      l_error_api_name	:= 'VALIDATE_PROJECTS_DETAILS';
                      raise FND_API.G_EXC_UNEXPECTED_ERROR;
                    else
                      if g_use_pre_gen_suspense = 'Y' then
                             /* stick suspense, also makes Valid and puts in error code Bug 2007521 */
	                      stick_suspense_account( g_pregen_rec.assignment_id,
	                                                 g_pregen_rec.distribution_date,
                                                         x_gms_pa_install,
                                                         g_pregen_rec.person_id,
	                                                 g_pregen_rec.distribution_interface_id,
	                                                 l_return_code,
                                                         x_business_group_id,
                                                         x_set_of_books_id,
	                                                 x_return_status);
                              if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                                 raise FND_API.G_EXC_UNEXPECTED_ERROR;
	                      end if;
                        else
                            l_batch_status := 1;
                            update_record_with_error(
                            X_distribution_interface_id	=> g_pregen_rec.distribution_interface_id,
                            X_error_code	        	=> l_return_code,
                            X_return_status	        	=> x_return_status);
                            if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                               raise FND_API.G_EXC_UNEXPECTED_ERROR;
                            end if;
                       end if;
                    end if;
                  else
                    ----dbms_output.put_line ('Update record with valid');
                     l_return_code 	:= 0;
                     update_record_with_valid(X_distribution_interface_id	=>
                                           g_pregen_rec.distribution_interface_id,
                                           X_return_status => x_return_status);
                     if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                       raise FND_API.G_EXC_UNEXPECTED_ERROR;
                     end if;
                 end if;
                END IF;
              END IF;
            else
              /* Bug fix 2985061,  moved this code here from separate elseif for 4717564 */
                validate_gl_cc_id(  x_code_combination_id       => g_pregen_rec.gl_code_combination_id,
                                            x_return_status     => x_return_status,
                                            x_return_code       => l_return_code);

                IF x_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
                   l_batch_status := 1;
                   IF l_return_code = 'OTHER' THEN
                      l_error_api_name  := 'VALIDATE_GL_CC_ID';
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   ELSE
                     update_record_with_error(X_distribution_interface_id  => g_pregen_rec.distribution_interface_id,
                                              X_error_code                 => l_return_code,
                                              X_return_status              => x_return_status);
                     IF x_return_status  <> FND_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                     END IF;
                   END IF;
                END IF;
		  -- Call Auto-Population for a new GL Code Combination Id that has a new Natural Account.
              psp_autopop.main(p_acct_type                   => 'N',
				       p_person_id                   => g_pregen_rec.person_id,
			             p_assignment_id               => g_pregen_rec.assignment_id,
				       p_element_type_id             => g_pregen_rec.element_type_id,
			             p_project_id                  => null,
				       p_expenditure_organization_id => null,
				       p_task_id                     => null,
				       p_award_id                    => null,
                                       p_expenditure_type            => null,
				       p_gl_code_combination_id      => g_pregen_rec.gl_code_combination_id,
				       p_payroll_date                =>  g_pregen_rec.distribution_date,
                                       p_set_of_books_id             => x_set_of_books_id,
                                       p_business_group_id           => x_business_group_id,
				       ret_expenditure_type          => l_new_expenditure_type,
				       ret_gl_code_combination_id    => l_new_gl_code_combination_id,
				       retcode                       => l_autopop_status);

              IF l_autopop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                l_batch_status := 1;
                l_return_code := 'AUTOPOP_NA_ERR';
                update_record_with_error(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
		   			           X_error_code	   => l_return_code,
                                         X_return_status => x_return_status);
                if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
              ELSIF l_autopop_status = FND_API.G_RET_STS_ERROR THEN

          /********Will not populate distribution interface table if autopop returns no value
           ******** as it is not considered an error condition.
                l_return_code := 'AUTOPOP_NO_VAL';
                update_record_with_error(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
		   			           X_error_code	   => l_return_code,
                                         X_return_status => x_return_status);
                if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
           ******************************************************/
                  l_return_code 	:= 0;
                  update_record_with_valid(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
                                           X_return_status => x_return_status);
                  if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
                  end if;
              ELSIF l_autopop_status = FND_API.G_RET_STS_SUCCESS THEN
                ----dbms_output.put_line ('Update record with valid');
                l_return_code 	:= 0;
                update_record_with_valid(X_distribution_interface_id	=>
                                                       g_pregen_rec.distribution_interface_id,
                                         X_return_status => x_return_status);
                if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;

                update_record_with_na(X_distribution_interface_id  =>
								     g_pregen_rec.distribution_interface_id,
					        X_gl_code_combination_id => l_new_gl_code_combination_id,
				              X_return_status => x_return_status);
                if x_return_status  <> FND_API.G_RET_STS_SUCCESS then
                  raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;
              END IF;
            END IF;
          end if;
        end if;
      END IF;
    end if; -- Added for bug 2985061
END IF; --Added for Bug2616807
END IF; --Added for Bug 2616807

  END LOOP;
  close get_all_from_interface_csr;
  --dbms_output.PUT_LINE('...End Loop .....l_batch_status ' || to_char(l_batch_status));


--  errbuf	:=  l_subline_message;

/* Changed the return code for errors , so that regular pre-gen does not repeat the validations
 again in case of errors either during the first phase of validations or
'AUTOPOP_NA_ERR, or AUTOPOP_EXP_ERR
:- Subha, Jly 17, 2000
*/


if l_batch_status =1 then
     /* 2007521: Introduced update statement, to revert sticking suspense a/c if
        there are some other errors. Give chance to user to correct all errors */
   if g_use_pre_gen_suspense  = 'Y' then
     update psp_distribution_interface
      set suspense_org_account_id = null,
          status_code = 'E'
      where batch_name = x_batch_name and
            suspense_org_account_id is not null;
   end if;

    fnd_message.set_name('PSP','PSP_BATCH_HAS_ERRORS');
    fnd_msg_pub.add;
    x_return_status:=FND_API.G_RET_STS_ERROR;
else
  x_return_status:= FND_API.G_RET_STS_SUCCESS;
end if;
--  commit; Commented COMMIT for bug fix 2094036, error reason codes get commited in main procedure.
return;
  EXCEPTION
     WHEN NO_DATA_FOUND then
       close get_all_from_interface_csr;
       FND_MESSAGE.SET_NAME('PSP','PSP_LD_NO_TRANS');
       l_subline_message := fnd_message.get;
 --      errbuf	 := SUBSTR(l_error_api_name ||fnd_global.local_chr(10) || l_subline_message,1,230);
       x_return_status:= FND_API.G_RET_STS_SUCCESS;
       return;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then
       ----dbms_output.put_line('Unexpected Error...........');
/*******************************************************************************************************
       fnd_msg_pub.get(p_msg_index		=> FND_MSG_PUB.G_FIRST,
		           p_encoded		=> FND_API.G_FALSE,
			     p_data			=> l_msg_data,
			     p_msg_index_out	=> l_msg_count);

Printed from Message  Stack
**********************************************************************************************************/
  --     errbuf	 :=  SUBSTR(l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10),1,230);
	fnd_msg_pub.add_exc_msg('PSP_PREGEN','Autopop-Unexpected Error');
       x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;

       rollback;
       return;
     WHEN OTHERS then
       ----dbms_output.put_line('When others  Error...........');

/*********************************************************************************************************
       fnd_msg_pub.get(p_msg_index		=> FND_MSG_PUB.G_FIRST,
		           p_encoded		=> FND_API.G_FALSE,
			     p_data			=> l_msg_data,
		           p_msg_index_out	=> l_msg_count);
   --    errbuf	 :=  SUBSTR(l_error_api_name || fnd_global.local_chr(10) || l_msg_data || fnd_global.local_chr(10),1,230);

 printed from mesasge stack
**********************************************************************************************************/
       rollback;
	fnd_msg_pub.add_exc_msg('PSP_PREGEN','Autopop-Error');
       x_return_status := FND_API.G_RET_STS_ERROR;
---	 x_retcode := 2;
       return;
   END Autopop;

--

----------------------------------UPDATE_RECORD_WITH_EXP-----------------------------------
-- This procedure is to update psp_distribution_interface table with Auto-Populated expenditure type
--

Procedure update_record_with_exp(X_distribution_interface_id  IN Number,
				         X_expenditure_type           IN Varchar2,
				         X_return_status              OUT NOCOPY Varchar2) IS
begin
  UPDATE psp_distribution_interface
  SET    expenditure_type = X_expenditure_type
  WHERE  distribution_interface_id = X_distribution_interface_id;

  if SQL%NOTFOUND then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then
       fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_exp :  Error while updating');
       x_return_status	:= FND_API.G_RET_STS_ERROR;
     WHEN OTHERS   then
      fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_exp :  Unexpected error');
      x_return_status	:= FND_API.G_RET_STS_ERROR;

end;

--
----------------------------------UPDATE_RECORD_WITH_NA-----------------------------------
-- This procedure is to update psp_distribution_interface table with Auto-Populated expenditure type
--

Procedure update_record_with_na(X_distribution_interface_id  IN Number,
				        X_gl_code_combination_id     IN Number,
				        X_return_status              OUT NOCOPY Varchar2) IS
begin
  UPDATE psp_distribution_interface
  SET    gl_code_combination_id = X_gl_code_combination_id
  WHERE  distribution_interface_id = X_distribution_interface_id;

  if SQL%NOTFOUND then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  x_return_status	:= FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR  then
       fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_na :  Error while updating');
       x_return_status	:= FND_API.G_RET_STS_ERROR;
     WHEN OTHERS   then
      fnd_msg_pub.add_exc_msg('PSP_PREGEN','update_record_with_na :  Unexpected error');
      x_return_status	:= FND_API.G_RET_STS_ERROR;

end;

---================================= GET_SUSPENSE_ACCOUNT ===================
/* Introduced this function for bug 2007521.
   Gets suspense account for person/assignment org. */
Procedure get_suspense_account(p_organization_id in number,
                               p_organization_name varchar2,
                               p_effective_date   in date,
                               p_gms_pa_install   in varchar2,
                               p_person_id        in number,
                               p_business_group_id in number,
                               p_set_of_books_id in number,
                               p_distribution_interface_id in number,
                               x_suspense_account  out NOCOPY number,
                               x_return_status out NOCOPY varchar2,
                               x_suspense_auto_glccid  out NOCOPY number,
                               x_suspense_auto_exp_type  out NOCOPY varchar2) Is
 cursor org_suspense_cur(P_effective_date  in date,
                        p_account_type_code in varchar2) is
           SELECT organization_account_id,
                  gl_code_combination_id,
                  project_id,
                  task_id,
                  award_id,
                  expenditure_type,
                  expenditure_organization_id
             FROM   psp_organization_accounts
             WHERE  business_group_id = p_business_group_id
               AND    set_of_books_id = p_set_of_books_id
               AND    organization_id = p_organization_id
               AND    account_type_code = p_account_type_code
               AND    p_effective_date  BETWEEN start_date_active AND
                                       nvl(end_date_active, p_effective_date);
 cursor org_suspense_cur2(p_suspense_account_id in number) is
           SELECT organization_account_id,
                  gl_code_combination_id,
                  project_id,
                  task_id,
                  award_id,
                  expenditure_type,
                  expenditure_organization_id
             FROM   psp_organization_accounts
             WHERE   organization_account_id = p_suspense_account_id;

/* Following cursor is added for bug 2514611 */
   CURSOR employee_name_cur IS
   SELECT full_name
   FROM   per_people_f
   WHERE  person_id =p_person_id;

v_return_value varchar2(30);
v_return_Status varchar2(1);
v_return_code varchar2(100);
v_suspense_account_id number := NULL;
l_employee_name  VARCHAR2(240); --Added for bug 2514611
suspense_rec  org_suspense_cur%ROWTYPE;

  profile_val_date_matches         EXCEPTION;
  no_profile_exists                EXCEPTION;
  no_val_date_matches              EXCEPTION;
  no_global_acct_exists            EXCEPTION;
  suspense_ac_invalid              EXCEPTION;
  l_auto_status                   varchar2(100);
  l_auto_pop_status                varchar2(100);
  l_acct_type                     varchar2(1);
  l_element_type_id               number;
  l_assignment_id                 number;
  l_assignment_number          varchar2(100);
  l_element_type               varchar2(200);
  l_account                    varchar2(1000);
  l_auto_org_name              hr_all_organization_units_tl.name%TYPE;
  l_new_exp_type          varchar2(30);
  l_new_glccid                 number;

  cursor get_element_type is
   select element_type_id,
          assignment_id
     from psp_distribution_interface
    where distribution_interface_id = p_distribution_interface_id;

 cursor get_asg_details is
   select ppf.full_name,
          paf.assignment_number,
          pet.element_name,
          hou.name
     from per_all_people_f ppf,
          per_all_assignments_f paf,
          pay_element_types_f pet,
          hr_all_organization_units hou
    where ppf.person_id = p_person_id
      and p_effective_date between paf.effective_start_date and paf.effective_end_date
      and paf.assignment_id = l_assignment_id
      and p_effective_date between ppf.effective_start_date and ppf.effective_end_date
      and pet.element_type_id = l_element_type_id
      and p_effective_date between pet.effective_start_date and pet.effective_end_date
      and hou.organization_id = paf.organization_id;

Begin
         open org_suspense_cur(p_effective_date,'S');
         fetch org_suspense_cur into suspense_rec;
         if org_suspense_cur%NOTFOUND then
            close org_suspense_cur;
            v_return_value:= psp_general.find_global_suspense(p_effective_date,
	     				              p_business_group_id,
                                                        p_set_of_books_id,
                                                        v_suspense_account_id );

           IF v_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
               open org_suspense_cur2(v_suspense_account_id);
               fetch org_suspense_cur2 into suspense_rec;
               close org_suspense_cur2;
           ELSIF v_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
              RAISE no_global_acct_exists;
           ELSIF v_return_value = 'NO_VAL_DATE_MATCHES' THEN
              RAISE no_val_date_matches;
           ELSIF v_return_value = 'NO_PROFILE_EXISTS' THEN
              RAISE no_profile_exists;
           END IF;
         else
           close org_suspense_cur;
         end if;
          --- autopop for suspense account 5080403
           if g_suspense_autopop = 'Y' then
               if suspense_rec.gl_code_combination_id is null then
                    l_acct_type:='E';
                else
                     l_acct_type:='N';
               end if;
              open get_element_type;
              fetch get_element_type into l_element_type_id, l_assignment_id;
              close get_element_type;
              psp_autopop.main(
                           p_acct_type                   => l_acct_type,
                           p_person_id                   => p_person_id,
                           p_assignment_id               => l_assignment_id,
                           p_element_type_id             => l_element_type_id,
                           p_project_id                  => suspense_rec.project_id,
                           p_expenditure_organization_id => suspense_rec.expenditure_organization_id,
                           p_task_id                     => suspense_rec.task_id,
                           p_award_id                    => suspense_rec.award_id,
                           p_expenditure_type            => suspense_rec.expenditure_type,
                           p_gl_code_combination_id      => suspense_rec.gl_code_combination_id,
                           p_payroll_date                => p_effective_date,
                           p_set_of_books_id             => p_set_of_books_id,
                           p_business_group_id           => p_business_group_id,
                           ret_expenditure_type          => l_new_exp_type,
                           ret_gl_code_combination_id    => l_new_glccid,
                           retcode                       => l_auto_pop_status);
                /* fnd_file.put_line(fnd_file.log, 'Suspense.. After autopop call'|| 'p_acct_type                   =>'|| l_acct_type
                            || 'p_person_id                   => '||p_person_id
                            || ' p_assignment_id               => '||l_assignment_id
                            ||' p_element_type_id             => '||l_element_type_id
                            ||' p_project_id                  =>'|| suspense_rec.project_id
                            ||' p_expenditure_organization_id =>'|| suspense_rec.expenditure_organization_id
                            ||' p_task_id                     =>'|| suspense_rec.task_id
                            ||' p_award_id                    =>'|| suspense_rec.award_id
                            ||' p_expenditure_type            =>'|| suspense_rec.expenditure_type
                            ||' p_gl_code_combination_id      =>'|| suspense_rec.gl_code_combination_id
                            ||' p_payroll_date                => '||p_effective_date
                            ||' p_set_of_books_id             => '||p_set_of_books_id
                            ||' p_business_group_id           => '||p_business_group_id);*/

               if (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) or
                   (l_auto_pop_status = FND_API.G_RET_STS_ERROR) then
                  if l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR then
                    if l_acct_type ='N'  then
                         l_auto_status := 'AUTO_POP_NA_ERROR';
                    else
                         l_auto_status :='AUTO_POP_EXP_ERROR';
                    end if;
                  elsif l_auto_pop_status = FND_API.G_RET_STS_ERROR then
                    l_auto_status := 'AUTO_POP_NO_VALUE';
                 end if;
                open get_asg_details;
                fetch get_asg_details into l_employee_name, l_assignment_number, l_element_type, l_auto_org_name;
                close get_asg_details;
                  psp_enc_crt_xml.p_set_of_books_id := p_set_of_books_id;
                  psp_enc_crt_xml.p_business_group_id := p_business_group_id;
                  if l_acct_type = 'N' then
                      l_account :=
                          psp_enc_crt_xml.cf_charging_instformula(suspense_rec.gl_code_combination_id,
                                                                  null,
                                                                  null,
                                                                  null,
                                                                  null,
                                                                  null);
                   else
                      l_account :=
                          psp_enc_crt_xml.cf_charging_instformula(null,
                                                                  suspense_rec.project_id,
                                                                  suspense_rec.task_id,
                                                                  suspense_rec.award_id,
                                                                  l_new_exp_type,
                                                                  suspense_rec.expenditure_organization_id);
                   end if;
                   fnd_message.set_name('PSP','PSP_SUSPENSE_AUTOPOP_FAIL');
                   fnd_message.set_token('ORG_NAME',l_auto_org_name);
                   fnd_message.set_token('EMPLOYEE_NAME',l_employee_name);
                   fnd_message.set_token('ASG_NUM',l_assignment_number);
                   fnd_message.set_token('CHARGING_ACCOUNT',l_account);
                   fnd_message.set_token('AUTOPOP_ERROR',l_auto_status);
                   fnd_message.set_token('EFF_DATE',p_effective_date);
                   fnd_msg_pub.add;
                   x_return_status := fnd_api.g_ret_sts_unexp_error;
         else
            x_suspense_auto_glccid := l_new_glccid;
            x_suspense_auto_exp_type := l_new_exp_type;
            suspense_rec.gl_code_combination_id := x_suspense_auto_glccid;
            suspense_rec.expenditure_type      := x_suspense_auto_exp_type;
         end if;
         end if;
         if x_return_status is null then
         if suspense_rec.project_id is not null then
           Validate_Project_details(X_Project_ID    	=> suspense_rec.project_id,
	         		      X_task_id		=> suspense_rec.task_id,
				      X_award_id		=> suspense_rec.award_id,
				      X_expenditure_type => suspense_rec.expenditure_type,
                                      X_exp_org_id	=> suspense_rec.expenditure_organization_id,
			        	X_gms_pa_install   => p_gms_pa_install,
	  				X_Person_ID	       => p_person_id,
                             		X_Effective_date	=> p_effective_date,
				            X_return_status	=> v_return_status,
				            X_return_code	=> v_return_code);

             if v_return_status <> FND_API.G_RET_STS_SUCCESS then
                   if v_return_code = 'OTHER' then
                         raise FND_API.G_EXC_UNEXPECTED_ERROR;
                   else
                         raise SUSPENSE_AC_INVALID;   /* should raise functional fatal error 2007521 */
                   end if;
             end if;
         end if;

         x_return_status := FND_API.G_RET_STS_SUCCESS;
         end if;
         x_suspense_account := suspense_rec.organization_account_id;
EXCEPTION
   WHEN NO_PROFILE_EXISTS THEN
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_VAL_DATE_MATCHES THEN
       fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',p_organization_name);
      fnd_message.set_token('PAYROLL_DATE',p_effective_date);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',p_organization_name);
      fnd_message.set_token('PAYROLL_DATE',p_effective_date);
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN SUSPENSE_AC_INVALID THEN
       /* Following added for bug 2514611 */
      OPEN   employee_name_cur;
      FETCH  employee_name_cur INTO l_employee_name;
      CLOSE  employee_name_cur;
      fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_INVALID');
      fnd_message.set_token('ORG_NAME',p_organization_name);
      fnd_message.set_token('PATC_STATUS',v_return_code);
      fnd_message.set_token('EMPLOYEE_NAME',l_employee_name); --Bug 2514611
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      if org_suspense_cur%isopen then
         close org_suspense_cur;
      end if;
      if org_suspense_cur2%isopen then
         close org_suspense_cur2;
      end if;
      fnd_msg_pub.add_exc_msg('PSP_PREGEN','GET_SUSPENSE_ACCOUNT');
      x_return_status := fnd_api.g_ret_sts_unexp_error;
END;
---================================= STICK_SUSPENSE_ACCOUNT ===================
 /* Bug fix 2007521: Created this procedure.
    Sticks suspense account for Pre-Gen line with invalid POETA account. */
Procedure stick_suspense_account( p_assignment_id in number,
	                          p_effective_date in date,
                                  p_gms_pa_install   in varchar2,
                                  p_person_id        in number,
	                          p_distribution_interface_id in number,
	                          p_suspense_reason_code in varchar2,
                                  p_business_group_id in number,
                                  p_set_of_books_id in number,
	                          p_return_status out NOCOPY varchar2) Is
   CURSOR org_name_cur IS
   SELECT hou.organization_id,
          hou.name
   FROM   per_assignments_f paf,
          hr_organization_units hou
   WHERE  paf.business_group_id = p_business_group_id
   AND    paf.assignment_id = p_assignment_id
   AND    p_effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    p_effective_date between hou.date_from and nvl(hou.date_to,p_effective_date)
   AND    p_business_group_id = hou.business_group_id
   AND    paf.organization_id = hou.organization_id;

   v_organization_id number;
   v_org_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   v_suspense_account number;
   v_return_status varchar2(1);
   assign_org_not_found exception;
   l_suspense_auto_glccid number;
   l_suspense_auto_exp_type varchar2(30);
   l_pre_gen_line_id      number;

   BEGIN
        open org_name_cur;
        fetch org_name_cur into v_organization_id, v_org_name;
        if org_name_cur%NOTFOUND then
          close org_name_cur;
          raise ASSIGN_ORG_NOT_FOUND;
        else
          l_pre_gen_line_id := p_distribution_interface_id;
          get_suspense_account(v_organization_id,
                               v_org_name,
                               p_effective_date,
                               p_gms_pa_install,
                               p_person_id,
                               p_business_group_id,
                               p_set_of_books_id,
                               l_pre_gen_line_id,
                               v_suspense_account,
                               v_return_status,
                               l_suspense_auto_glccid,
                               l_suspense_auto_exp_type);
           if v_return_status <> FND_API.G_RET_STS_SUCCESS then
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

           update psp_distribution_interface
           set suspense_org_account_id = v_suspense_account,
               error_code = p_suspense_reason_code,
               status_code = 'V',
               suspense_auto_glccid = l_suspense_auto_glccid, --- added for 5080403
               suspense_auto_exp_type = l_suspense_auto_exp_type
           where distribution_interface_id =   p_distribution_interface_id;
          close org_name_cur;
       end if;
       p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
     When ASSIGN_ORG_NOT_FOUND then
        fnd_msg_pub.add_exc_msg('PSP_PREGEN','STICK_SUSPENSE_ACCOUNT-(Assign ORG)');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
     When others then
        if org_name_cur%isopen then
         close org_name_cur;
        end if;
        fnd_msg_pub.add_exc_msg('PSP_PREGEN','STICK_SUSPENSE_ACCOUNT');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

 /* Bug fix 2985061: Created this procedure.
    If Cr_Dr_Flag in the psp_distribution_interface table is not in ('C','D') then throw Exception */

PROCEDURE VALIDATE_DR_CR_FLAG ( X_DR_CR_FLAG     IN VARCHAR2,
                                X_return_status  OUT NOCOPY varchar2,
                                X_return_code    OUT NOCOPY varchar2)  IS
BEGIN
    if (X_DR_CR_FLAG = 'D') or (X_DR_CR_FLAG = 'C') then
        x_return_status	:= FND_API.G_RET_STS_SUCCESS;
        x_return_code		:= '  ';
    else
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code	:= 'INV_D_C';
    end if;
    EXCEPTION
	when OTHERS then
        fnd_msg_pub.add_exc_msg('PSP_PREGEN','VALIDATE_DR_CR_FLAG : Unexpected Error');
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code	:= 'OTHER';
        return;
END VALIDATE_DR_CR_FLAG;

 /* Bug fix 2985061: Created this procedure.
    If CODE_COMBINATION_ID is not in table gl_code_combinations then throw Exception */
PROCEDURE VALIDATE_GL_CC_ID(  X_CODE_COMBINATION_ID          IN NUMBER,
                                            X_return_status  OUT NOCOPY varchar2,
                                            X_return_code    OUT NOCOPY varchar2)  IS
    CURSOR check_code_combination_csr is
    select 1
    from gl_code_combinations
    where CODE_COMBINATION_ID = X_CODE_COMBINATION_ID;

    l_code_combination_id	number(15);
BEGIN
    open check_code_combination_csr;
    fetch check_code_combination_csr into l_code_combination_id;
    if check_code_combination_csr%NOTFOUND then
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code		:= 'INV_GLC';
        close check_code_combination_csr;
        return;
    else
        x_return_status	:= FND_API.G_RET_STS_SUCCESS;
        x_return_code		:= '  ';
    end If;
    close check_code_combination_csr;
    Exception
	when no_data_found or too_many_rows then
        x_return_status	:= FND_API.G_RET_STS_ERROR;
        x_return_code	:= 'INV_GLC';
        close check_code_combination_csr;
        return;
	when OTHERS then
	   fnd_msg_pub.add_exc_msg('PSP_PREGEN','VALIDATE_GL_CODE_COMBINATION_ID : Unexpected Error');
         x_return_status	:= FND_API.G_RET_STS_ERROR;
         x_return_code	:= 'OTHER';
        close check_code_combination_csr;
        return;
End VALIDATE_GL_CC_ID;

END PSP_PREGEN;  -- End of Package Body

/
