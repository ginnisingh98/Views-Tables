--------------------------------------------------------
--  DDL for Package Body PAY_ORG_PAY_METH_USAGES_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ORG_PAY_METH_USAGES_F_PKG" as
/* $Header: pyopu01t.pkb 120.0.12010000.2 2009/04/14 06:45:54 parusia ship $ */
--
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   opmu_end_date                                                         --
 -- Purpose                                                                 --
 --   Returns the date effective end date of an OPMU that is about to be    --
 --   created. This takes into account future opmu's and also the end date  --
 --   of the opm.                                                           --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 function opmu_end_date
 (
  p_org_pay_method_usage_id number,
  p_payroll_id              number,
  p_org_payment_method_id   number,
  p_session_date            date,
  p_validation_start_date   date
 ) return date is
--
   v_next_opmu_start_date date;
   v_max_payroll_end_date date;
   v_max_opm_end_date     date;
   v_opmu_end_date        date;
--
 begin
--
   -- Get the start date of the earliest future opmu if it exists.
   begin
     select min(opmu.effective_start_date)
     into   v_next_opmu_start_date
     from   pay_org_pay_method_usages_f opmu
     where  opmu.payroll_id = p_payroll_id
       and  opmu.org_payment_method_id = p_org_payment_method_id
       and  opmu.effective_end_date >= p_session_date
       and  opmu.org_pay_method_usage_id <> nvl(p_org_pay_method_usage_id,0);
   exception
     when no_data_found then null;
   end;
--
   -- If there are no future opmus , get the least of hte max end date of the
   -- payroll and opm..
   if v_next_opmu_start_date is null then
--
     -- Get payroll end date
     begin
       select max(prl.effective_end_date)
       into   v_max_payroll_end_date
       from   pay_all_payrolls_f prl
       where  prl.payroll_id = p_payroll_id;
     exception
       when no_data_found then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
				      'pay_payrolls_f_pkg.opmu_end_date');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
     end;
--
     -- Get opm end date
     begin
       select max(opm.effective_end_date)
       into   v_max_opm_end_date
       from   pay_org_payment_methods_f opm
       where  opm.org_payment_method_id = p_org_payment_method_id;
     exception
       when no_data_found then
         hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE',
				      'pay_payrolls_f_pkg.opmu_end_date');
         hr_utility.set_message_token('STEP','2');
         hr_utility.raise_error;
     end;
--
     -- Use the most restrictive date.
     v_opmu_end_date := least(v_max_payroll_end_date,v_max_opm_end_date);
--
   else
--
     -- Set the date to the day before the next opmu.
     v_opmu_end_date := v_next_opmu_start_date - 1;
--
   end if;
--
   -- Trying to open up an opmu that would either overlap with an
   -- existing opmu or extend beyond the lifetime of the opm or payroll
   -- on which it is based.
   if v_opmu_end_date < p_validation_start_date then
--
     -- No future opmu was found.
     if v_next_opmu_start_date is null then
--
       -- Trying to extend the end date of the opmu past the end date
       -- of the payroll.
       if v_opmu_end_date = v_max_payroll_end_date then
--
         hr_utility.set_message(801, 'HR_6868_PAY_NO_DNC_PAY');
--
       -- Trying to extend the end date of the opmu past the end date
       -- of the opm.
       else
--
	 hr_utility.set_message(801, 'HR_6870_PAY_NO_DNC_PAYM');
--
       end if;
--
     -- Trying to extend the end date of the opmu such that it will
     -- overlap with an existing opmu.
     else
--
       hr_utility.set_message(801, 'HR_6869_PAY_NO_DNC_OPMU');
--
     end if;
--
     hr_utility.raise_error;
--
   end if;
--
   return v_opmu_end_date;
--
 end opmu_end_date;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   validate_delete_opmu                                                  --
 -- Purpose                                                                 --
 --   Checks to see if it is valid to delete the opmu.                      --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 procedure validate_delete_opmu
 (
  p_payroll_id              number,
  p_org_payment_method_id   number,
  p_effective_start_date    date,
  p_effective_end_date      date,
  p_dt_delete_mode          varchar2,
  p_validation_start_date   date,
  p_validation_end_date     date
 ) is
--
   cursor csr_dflt_pay_meth
	  (
	   p_payroll_id            number,
	   p_org_payment_method_id number,
	   p_validation_start_date date,
	   p_validation_end_date   date
	  ) is
     select prl.payroll_id
     from   pay_all_payrolls_f prl
     where  prl.payroll_id = p_payroll_id
       and  prl.default_payment_method_id = p_org_payment_method_id
       and  prl.effective_start_date <= p_validation_end_date
       and  prl.effective_end_date   >= p_validation_start_date;
--
   cursor csr_ppm
	  (
	   p_payroll_id            number,
	   p_org_payment_method_id number,
	   p_validation_start_date date,
	   p_validation_end_date   date
	  ) is
     select ppm.personal_payment_method_id
     from   per_all_assignments_f asg,
	    pay_personal_payment_methods_f ppm
     where  asg.payroll_id = p_payroll_id
       and  ppm.assignment_id = asg.assignment_id
       and  ppm.org_payment_method_id = p_org_payment_method_id
       and  ppm.effective_start_date <= asg.effective_end_date
       and  ppm.effective_end_date   >= asg.effective_start_date
       and  ppm.effective_start_date <= p_validation_end_date
       and  ppm.effective_end_date   >= p_validation_start_date
       /* Checks added for bug 8419878 */
       and  asg.effective_start_date <= p_validation_end_date
       and  asg.effective_end_date   >= p_validation_start_date;
--
   cursor csr_pre_pay
	  (
	   p_payroll_id            number,
	   p_org_payment_method_id number,
	   p_validation_start_date date,
	   p_validation_end_date   date
	  ) is
     select pp.pre_payment_id
     from   pay_payroll_actions pa,
	    pay_assignment_actions aa,
	    pay_pre_payments pp
     where  pa.payroll_id = p_payroll_id
       and  aa.payroll_action_id = pa.payroll_action_id
       and  pp.assignment_action_id = aa.assignment_action_id
       and  pp.org_payment_method_id = p_org_payment_method_id
       and  pa.action_type in ('P', 'U')
       and  pa.effective_date between p_validation_start_date
				  and p_validation_end_date;
--
   v_dummy_id              number;
   v_validation_start_date date;
   v_validation_end_date   date;
--
 begin
--
   -- NB. the validation for 'DELETE_NEXT_CHANGE' and 'FUTURE_CHANGE is done
   -- by opmu_end_date ie. it checks for future opmus etc ...
   if p_dt_delete_mode in ('ZAP','DELETE') then
--
     -- DT code sets the validation dates to the start and end of time when
     -- doing a ZAP. This would result in a check over a too wide range of
     -- dates so the actual start and end dates of the record being removed are
     -- used NB. as the opmu cannot be updated there will only be one record.
     if p_dt_delete_mode = 'ZAP' then
       v_validation_start_date := p_effective_start_date;
       v_validation_end_date   := p_effective_end_date;
     else
       v_validation_start_date := p_validation_start_date;
       v_validation_end_date   := p_validation_end_date;
     end if;
--
     -- Check to see if the opmu is being removed during a time when it is
     -- the default for the payroll.
     open csr_dflt_pay_meth(p_payroll_id,
                            p_org_payment_method_id,
                            v_validation_start_date,
                            v_validation_end_date);
     fetch csr_dflt_pay_meth into v_dummy_id;
     if csr_dflt_pay_meth%found then
       close csr_dflt_pay_meth;
       hr_utility.set_message(801, 'HR_6932_PAY_PAST_DPM');
       hr_utility.raise_error;
     else
       close csr_dflt_pay_meth;
     end if;
--
     -- Check to see if the opmu is being removed during a time when it is
     -- has been used to allow the creation of a personal payment method.
     open csr_ppm(p_payroll_id,
	          p_org_payment_method_id,
	          v_validation_start_date,
	          v_validation_end_date);
     fetch csr_ppm into v_dummy_id;
     if csr_ppm%found then
       close csr_ppm;
       hr_utility.set_message(801, 'HR_6497_PAY_DEL_PPM');
       hr_utility.raise_error;
     else
       close csr_ppm;
     end if;
--
     -- Check to see if the opmu is being removed during a time when it is
     -- has been used in a pre payment.
     open csr_pre_pay(p_payroll_id,
	              p_org_payment_method_id,
	              v_validation_start_date,
	              v_validation_end_date);
     fetch csr_pre_pay into v_dummy_id;
     if csr_pre_pay%found then
       close csr_pre_pay;
       hr_utility.set_message(801, 'HR_6498_PAY_DEL_PREPAY');
       hr_utility.raise_error;
     else
       close csr_pre_pay;
     end if;
--
   end if;
--
 end validate_delete_opmu;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Insert_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert of an OPMU via the   --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Insert_Row(X_Rowid                        IN OUT nocopy VARCHAR2,
                      X_Org_Pay_Method_Usage_Id      IN OUT nocopy NUMBER,
                      X_Effective_Start_Date                       DATE,
                      X_Effective_End_Date           IN OUT nocopy DATE,
                      X_Payroll_Id                                 NUMBER,
                      X_Org_Payment_Method_Id                      NUMBER) IS
--
   CURSOR C IS SELECT rowid FROM pay_org_pay_method_usages_f
               WHERE  org_pay_method_usage_id = X_Org_Pay_Method_Usage_Id;
--
   CURSOR C2 IS SELECT pay_org_pay_method_usages_s.nextval
   FROM dual;
--
 BEGIN
--
   if (X_Org_Pay_Method_Usage_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Org_Pay_Method_Usage_Id;
     CLOSE C2;
   end if;
--
   -- Sets the correct ned date for the opmu taking into account the payroll,
   -- opm and future opmus.
   X_Effective_End_Date := pay_org_pay_meth_usages_f_pkg.opmu_end_date
                             (null,                    -- opmu id
                              X_Payroll_Id,
                              X_Org_Payment_Method_Id,
                              X_Effective_Start_Date,  -- session date
                              X_Effective_Start_Date); -- validation start date
--
   INSERT INTO pay_org_pay_method_usages_f
   (org_pay_method_usage_id,
    effective_start_date,
    effective_end_date,
    payroll_id,
    org_payment_method_id)
   VALUES
   (X_Org_Pay_Method_Usage_Id,
    X_Effective_Start_Date,
    X_Effective_End_Date,
    X_Payroll_Id,
    X_Org_Payment_Method_Id);
--
   OPEN C;
   FETCH C INTO X_Rowid;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_org_pay_meth_usages_f_pkg.insert_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
 END Insert_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Lock_Row                                                              --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the insert , update and delete  --
 --   of a formula by applying a lock on a formula in the Define Payroll    --
 --   form.                                                                 --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                    X_Org_Pay_Method_Usage_Id               NUMBER,
                    X_Effective_Start_Date                  DATE,
                    X_Effective_End_Date                    DATE,
                    X_Payroll_Id                            NUMBER,
                    X_Org_Payment_Method_Id                 NUMBER) IS
--
   CURSOR C IS SELECT * FROM pay_org_pay_method_usages_f
               WHERE  rowid = X_Rowid FOR UPDATE of Org_Pay_Method_Usage_Id
	       NOWAIT;
--
   Recinfo C%ROWTYPE;
--
 BEGIN
--
   OPEN C;
   FETCH C INTO Recinfo;
   if (C%NOTFOUND) then
     CLOSE C;
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_org_pay_meth_usages_f_pkg.lock_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
   CLOSE C;
--
   if (    (   (Recinfo.org_pay_method_usage_id = X_Org_Pay_Method_Usage_Id)
            OR (    (Recinfo.org_pay_method_usage_id IS NULL)
                AND (X_Org_Pay_Method_Usage_Id IS NULL)))
       AND (   (Recinfo.effective_start_date = X_Effective_Start_Date)
            OR (    (Recinfo.effective_start_date IS NULL)
                AND (X_Effective_Start_Date IS NULL)))
       AND (   (Recinfo.effective_end_date = X_Effective_End_Date)
            OR (    (Recinfo.effective_end_date IS NULL)
                AND (X_Effective_End_Date IS NULL)))
       AND (   (Recinfo.payroll_id = X_Payroll_Id)
            OR (    (Recinfo.payroll_id IS NULL)
                AND (X_Payroll_Id IS NULL)))
       AND (   (Recinfo.org_payment_method_id = X_Org_Payment_Method_Id)
            OR (    (Recinfo.org_payment_method_id IS NULL)
                AND (X_Org_Payment_Method_Id IS NULL)))
           ) then
     return;
   else
     FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
     APP_EXCEPTION.RAISE_EXCEPTION;
   end if;
--
 END Lock_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Update_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the update of an OPMU   via the --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --   None.                                                                 --
 -----------------------------------------------------------------------------
--
 PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                      X_Org_Pay_Method_Usage_Id             NUMBER,
                      X_Effective_Start_Date                DATE,
                      X_Effective_End_Date                  DATE,
                      X_Payroll_Id                          NUMBER,
                      X_Org_Payment_Method_Id               NUMBER) IS
--
 BEGIN
--
   UPDATE pay_org_pay_method_usages_f
   SET org_pay_method_usage_id   =    X_Org_Pay_Method_Usage_Id,
       effective_start_date      =    X_Effective_Start_Date,
       effective_end_date        =    X_Effective_End_Date,
       payroll_id                =    X_Payroll_Id,
       org_payment_method_id     =    X_Org_Payment_Method_Id
   WHERE rowid = X_rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_org_pay_meth_usages_f_pkg.update_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Update_Row;
--
 -----------------------------------------------------------------------------
 -- Name                                                                    --
 --   Delete_Row                                                            --
 -- Purpose                                                                 --
 --   Table handler procedure that supports the delete of a OPMU via the    --
 --   Define Payroll form.                                                  --
 -- Arguments                                                               --
 --   See below.                                                            --
 -- Notes                                                                   --
 --                                                                         --
 -----------------------------------------------------------------------------
--
 PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
--
 BEGIN
--
   DELETE FROM pay_org_pay_method_usages_f
   WHERE  rowid = X_Rowid;
--
   if (SQL%NOTFOUND) then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE',
                                  'pay_org_pay_meth_usages_f_pkg.delete_row');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
   end if;
--
 END Delete_Row;
--
END PAY_ORG_PAY_METH_USAGES_F_PKG;

/
