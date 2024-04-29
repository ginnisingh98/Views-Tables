--------------------------------------------------------
--  DDL for Package Body PAY_ROLL_ACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ROLL_ACTS_PKG" as
/* $Header: pypra01t.pkb 115.2 2002/12/11 11:14:33 ssivasu2 ship $ */
  procedure delete_row ( p_rowid varchar2) is
  begin
    delete from pay_payroll_actions
    where  rowid = p_rowid;
  end delete_row;

  procedure insert_row ( p_rowid		IN out nocopy	varchar2,
                         p_payroll_action_id	IN out nocopy	number,
                         p_action_type			varchar2,
                         p_business_group_id		number,
                         p_consolidation_set_id		number,
                         p_payroll_id			number,
                         p_action_population_status	varchar2,
                         p_action_status		varchar2,
                         p_effective_date		date,
                         p_comments			varchar2,
                         p_legislative_parameters	varchar2,
                         p_run_type_id                  number,
                         p_element_set_id		number,
                         p_assignment_set_id		number,
                         p_date_earned			date,
                         p_display_run_number		number,
                         p_pay_advice_date		date,
                         p_pay_advice_message		varchar2,
                         p_attribute_category		varchar2,
                         p_attribute1 varchar2, p_attribute2 varchar2,
                         p_attribute3 varchar2, p_attribute4 varchar2,
                         p_attribute5 varchar2, p_attribute6 varchar2,
                         p_attribute7 varchar2, p_attribute8 varchar2,
                         p_attribute9 varchar2, p_attribute10 varchar2,
                         p_attribute11 varchar2, p_attribute12 varchar2,
                         p_attribute13 varchar2, p_attribute14 varchar2,
                         p_attribute15 varchar2, p_attribute16 varchar2,
                         p_attribute17 varchar2, p_attribute18 varchar2,
                         p_attribute19 varchar2, p_attribute20 varchar2 ) is

  cursor c1 is
    select pay_payroll_actions_s.nextval
    from   sys.dual;

  cursor c2 is
    select rowid
    from   pay_payroll_actions
    where  payroll_action_id = p_payroll_action_id;

  begin

    open  c1;
    fetch c1 into p_payroll_action_id;
    close c1;

    insert into pay_payroll_actions ( payroll_action_id,
                                      action_type,
                                      business_group_id,
                                      consolidation_set_id,
                                      payroll_id,
                                      action_population_status,
                                      action_status,
                                      effective_date,
                                      comments,
                                      legislative_parameters,
                                      run_type_id,
                                      element_set_id,
                                      assignment_set_id,
                                      date_earned,
                                      display_run_number,
                                      pay_advice_date,
                                      pay_advice_message,
                                      attribute_category,
                                      attribute1, attribute2,
                                      attribute3, attribute4,
                                      attribute5, attribute6,
                                      attribute7, attribute8,
                                      attribute9, attribute10,
                                      attribute11, attribute12,
                                      attribute13, attribute14,
                                      attribute15, attribute16,
                                      attribute17, attribute18,
                                      attribute19, attribute20  )
    values ( p_payroll_action_id,
             p_action_type,
             p_business_group_id,
             p_consolidation_set_id,
             p_payroll_id,
             p_action_population_status,
             p_action_status,
             p_effective_date,
             p_comments,
             p_legislative_parameters,
             p_run_type_id,
             p_element_set_id,
             p_assignment_set_id,
             p_date_earned,
             p_display_run_number,
             p_pay_advice_date,
             p_pay_advice_message,
             p_attribute_category,
             p_attribute1, p_attribute2,
             p_attribute3, p_attribute4,
             p_attribute5, p_attribute6,
             p_attribute7, p_attribute8,
             p_attribute9, p_attribute10,
             p_attribute11, p_attribute12,
             p_attribute13, p_attribute14,
             p_attribute15, p_attribute16,
             p_attribute17, p_attribute18,
             p_attribute19, p_attribute20  );

    open  c2;
    fetch c2 into p_rowid;
    close c2;

  end insert_row;

  procedure lock_row ( p_rowid IN varchar2,
                       p_payroll_action_id number,
                       p_action_type varchar2,
                       p_business_group_id number,
                       p_consolidation_set_id number,
                       p_payroll_id number,
                       p_action_population_status varchar2,
                       p_action_status varchar2,
                       p_effective_date date,
                       p_comments varchar2,
                       p_legislative_parameters varchar2,
                       p_run_type_id number,
                       p_element_set_id number,
                       p_assignment_set_id number,
                       p_date_earned date,
                       p_display_run_number number,
                       p_pay_advice_date date,
                       p_pay_advice_message varchar2,
                       p_attribute_category varchar2,
                       p_attribute1 varchar2, p_attribute2 varchar2,
                       p_attribute3 varchar2, p_attribute4 varchar2,
                       p_attribute5 varchar2, p_attribute6 varchar2,
                       p_attribute7 varchar2, p_attribute8 varchar2,
                       p_attribute9 varchar2, p_attribute10 varchar2,
                       p_attribute11 varchar2, p_attribute12 varchar2,
                       p_attribute13 varchar2, p_attribute14 varchar2,
                       p_attribute15 varchar2, p_attribute16 varchar2,
                       p_attribute17 varchar2, p_attribute18 varchar2,
                       p_attribute19 varchar2, p_attribute20 varchar2 ) is

    cursor c is
  	select *
  	from   pay_payroll_actions
  	where  rowid = p_rowid for update of payroll_action_id nowait;
    c_rec c%rowtype;

  begin
    open  c;
    fetch c into c_rec;
    close c;
   /*
    * strip any trailing spaces off the VARCHAR2 columns retrieved.
    */
    c_rec.comments := rtrim(c_rec.comments);
    c_rec.legislative_parameters := rtrim(c_rec.legislative_parameters);
    c_rec.pay_advice_message := rtrim(c_rec.pay_advice_message);
    c_rec.attribute_category := rtrim(c_rec.attribute_category);
    c_rec.attribute1 := rtrim(c_rec.attribute1);
    c_rec.attribute2 := rtrim(c_rec.attribute2);
    c_rec.attribute3 := rtrim(c_rec.attribute3);
    c_rec.attribute4 := rtrim(c_rec.attribute4);
    c_rec.attribute5 := rtrim(c_rec.attribute5);
    c_rec.attribute6 := rtrim(c_rec.attribute6);
    c_rec.attribute7 := rtrim(c_rec.attribute7);
    c_rec.attribute8 := rtrim(c_rec.attribute8);
    c_rec.attribute9 := rtrim(c_rec.attribute9);
    c_rec.attribute10 := rtrim(c_rec.attribute10);
    c_rec.attribute11 := rtrim(c_rec.attribute11);
    c_rec.attribute12 := rtrim(c_rec.attribute12);
    c_rec.attribute13 := rtrim(c_rec.attribute13);
    c_rec.attribute14 := rtrim(c_rec.attribute14);
    c_rec.attribute15 := rtrim(c_rec.attribute15);
    c_rec.attribute16 := rtrim(c_rec.attribute16);
    c_rec.attribute17 := rtrim(c_rec.attribute17);
    c_rec.attribute18 := rtrim(c_rec.attribute18);
    c_rec.attribute19 := rtrim(c_rec.attribute19);
    c_rec.attribute20 := rtrim(c_rec.attribute20);
    c_rec.action_type := rtrim(c_rec.action_type);
    c_rec.action_population_status := rtrim(c_rec.action_population_status);
    c_rec.action_status := rtrim(c_rec.action_status);
    if ( ( (c_rec.payroll_action_id = p_payroll_action_id) or
           (c_rec.payroll_action_id is null and p_payroll_action_id is null) )
    and  ( (c_rec.action_type = p_action_type) or
  	 (c_rec.action_type is null and p_action_type is null) )
/******************************************
 *                                        *
 * omit check for business group change - *
 * it gives an unexplained value error,   *
 * and can never change anyway.           *
 *                                        *
 *   and  ( (c_rec.business_group_id = p_business_group_id) or
 * 	 (c_rec.business_group_id is null and p_business_group_id is null) )
 *                                        *
 ******************************************
 */
    and  ( (c_rec.consolidation_set_id = p_consolidation_set_id) or
  	 (c_rec.consolidation_set_id is null and
                                             p_consolidation_set_id is null) )
    and  ( (c_rec.payroll_id = p_payroll_id) or
  	 (c_rec.payroll_id is null and p_payroll_id is null) )
    and  ( (c_rec.action_population_status = p_action_population_status) or
  	 (c_rec.action_population_status is null and
                                         p_action_population_status is null) )
    and  ( (c_rec.action_status = p_action_status) or
  	 (c_rec.action_status is null and p_action_status is null) )
    and  ( (c_rec.effective_date = p_effective_date) or
  	 (c_rec.effective_date is null and p_effective_date is null) )
    and  ( (c_rec.comments = p_comments) or
  	 (c_rec.comments is null and p_comments is null) )
    and  ( (c_rec.legislative_parameters = p_legislative_parameters) or
  	 (c_rec.legislative_parameters is null and
                                           p_legislative_parameters is null) )
    and  ( (c_rec.run_type_id = p_run_type_id) or
         (c_rec.run_type_id is null and p_run_type_id is null) )
    and  ( (c_rec.element_set_id = p_element_set_id) or
  	 (c_rec.element_set_id is null and p_element_set_id is null) )
    and  ( (c_rec.assignment_set_id = p_assignment_set_id) or
  	 (c_rec.assignment_set_id is null and p_assignment_set_id is null) )
    and  ( (c_rec.date_earned = p_date_earned) or
  	 (c_rec.date_earned is null and p_date_earned is null) )
    and  ( (c_rec.display_run_number = p_display_run_number) or
  	 (c_rec.display_run_number is null and p_display_run_number is null) )
    and  ( (c_rec.pay_advice_date = p_pay_advice_date) or
  	 (c_rec.pay_advice_date is null and p_pay_advice_date is null) )
    and  ( (c_rec.pay_advice_message = p_pay_advice_message) or
  	 (c_rec.pay_advice_message is null and p_pay_advice_message is null) )
    and  ( (c_rec.attribute_category = p_attribute_category) or
  	 (c_rec.attribute_category is null and p_attribute_category is null) )
    and  ( (c_rec.attribute1 = p_attribute1) or
  	 (c_rec.attribute1 is null and p_attribute1 is null) )
    and  ( (c_rec.attribute2 = p_attribute2) or
  	 (c_rec.attribute2 is null and p_attribute2 is null) )
    and  ( (c_rec.attribute3 = p_attribute3) or
  	 (c_rec.attribute3 is null and p_attribute3 is null) )
    and  ( (c_rec.attribute4 = p_attribute4) or
  	 (c_rec.attribute4 is null and p_attribute4 is null) )
    and  ( (c_rec.attribute5 = p_attribute5) or
  	 (c_rec.attribute5 is null and p_attribute5 is null) )
    and  ( (c_rec.attribute6 = p_attribute6) or
  	 (c_rec.attribute6 is null and p_attribute6 is null) )
    and  ( (c_rec.attribute7 = p_attribute7) or
  	 (c_rec.attribute7 is null and p_attribute7 is null) )
    and  ( (c_rec.attribute8 = p_attribute8) or
  	 (c_rec.attribute8 is null and p_attribute8 is null) )
    and  ( (c_rec.attribute9 = p_attribute9) or
  	 (c_rec.attribute9 is null and p_attribute9 is null) )
    and  ( (c_rec.attribute10 = p_attribute10) or
  	 (c_rec.attribute10 is null and p_attribute10 is null) )
    and  ( (c_rec.attribute11 = p_attribute11) or
  	 (c_rec.attribute11 is null and p_attribute11 is null) )
    and  ( (c_rec.attribute12 = p_attribute12) or
  	 (c_rec.attribute12 is null and p_attribute12 is null) )
    and  ( (c_rec.attribute13 = p_attribute13) or
  	 (c_rec.attribute13 is null and p_attribute13 is null) )
    and  ( (c_rec.attribute14 = p_attribute14) or
  	 (c_rec.attribute14 is null and p_attribute14 is null) )
    and  ( (c_rec.attribute15 = p_attribute15) or
  	 (c_rec.attribute15 is null and p_attribute15 is null) )
    and  ( (c_rec.attribute16 = p_attribute16) or
  	 (c_rec.attribute16 is null and p_attribute16 is null) )
    and  ( (c_rec.attribute17 = p_attribute17) or
  	 (c_rec.attribute17 is null and p_attribute17 is null) )
    and  ( (c_rec.attribute18 = p_attribute18) or
  	 (c_rec.attribute18 is null and p_attribute18 is null) )
    and  ( (c_rec.attribute19 = p_attribute19) or
  	 (c_rec.attribute19 is null and p_attribute19 is null) )
    and  ( (c_rec.attribute20 = p_attribute20) or
  	 (c_rec.attribute20 is null and p_attribute20 is null) )
     ) then
        return;
     else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
     end if;
  end lock_row;

  procedure update_row ( p_rowid IN varchar2,
                         p_payroll_action_id number,
                         p_action_type varchar2,
                         p_business_group_id number,
                         p_consolidation_set_id number,
                         p_payroll_id number,
                         p_action_population_status varchar2,
                         p_action_status varchar2,
                         p_effective_date date,
                         p_comments varchar2,
                         p_legislative_parameters varchar2,
                         p_run_type_id number,
                         p_element_set_id number,
                         p_assignment_set_id number,
                         p_date_earned date,
                         p_display_run_number number,
                         p_pay_advice_date date,
                         p_pay_advice_message varchar2,
                         p_attribute_category varchar2,
                         p_attribute1 varchar2, p_attribute2 varchar2,
                         p_attribute3 varchar2, p_attribute4 varchar2,
                         p_attribute5 varchar2, p_attribute6 varchar2,
                         p_attribute7 varchar2, p_attribute8 varchar2,
                         p_attribute9 varchar2, p_attribute10 varchar2,
                         p_attribute11 varchar2, p_attribute12 varchar2,
                         p_attribute13 varchar2, p_attribute14 varchar2,
                         p_attribute15 varchar2, p_attribute16 varchar2,
                         p_attribute17 varchar2, p_attribute18 varchar2,
                         p_attribute19 varchar2, p_attribute20 varchar2 ) is
  begin
    update pay_payroll_actions
    set payroll_action_id        = p_payroll_action_id,
        action_type              = p_action_type,
        business_group_id        = p_business_group_id,
        consolidation_set_id     = p_consolidation_set_id,
        payroll_id               = p_payroll_id,
        action_population_status = action_population_status,
        action_status            = p_action_status,
        effective_date           = p_effective_date,
        comments                 = p_comments,
        legislative_parameters   = p_legislative_parameters,
        run_type_id              = p_run_type_id,
        element_set_id           = p_element_set_id,
        assignment_set_id        = p_assignment_set_id,
        date_earned              = p_date_earned,
        display_run_number       = p_display_run_number,
        pay_advice_date          = p_pay_advice_date,
        pay_advice_message       = p_pay_advice_message,
        attribute_category       = p_attribute_category,
        attribute1               = p_attribute1,
        attribute2               = p_attribute2,
        attribute3               = p_attribute3,
        attribute4               = p_attribute4,
        attribute5               = p_attribute5,
        attribute6               = p_attribute6,
        attribute7               = p_attribute7,
        attribute8               = p_attribute8,
        attribute9               = p_attribute9,
        attribute10              = p_attribute10,
        attribute11              = p_attribute11,
        attribute12              = p_attribute12,
        attribute13              = p_attribute13,
        attribute14              = p_attribute14,
        attribute15              = p_attribute15,
        attribute16              = p_attribute16,
        attribute17              = p_attribute17,
        attribute18              = p_attribute18,
        attribute19              = p_attribute19,
        attribute20              = p_attribute20
    where  rowid = p_rowid;
  end update_row;

end pay_roll_acts_pkg;

/
