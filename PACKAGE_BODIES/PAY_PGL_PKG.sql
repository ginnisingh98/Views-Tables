--------------------------------------------------------
--  DDL for Package Body PAY_PGL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PGL_PKG" as
/* $Header: pypgl01t.pkb 115.4 2003/09/01 00:13:22 tvankayl ship $ */
--
procedure get_cost_allocation(p_business_group_id NUMBER
                             ,p_cost_allocation_id_flex_num IN OUT NOCOPY NUMBER
                             ) is
cursor c is
   select cost_allocation_structure
   from    per_business_groups
   where   business_group_id + 0  = p_business_group_id;
begin
   hr_utility.set_location('pay_pgl_pkg.get_cost_allocation',1);
   open c;
   fetch c into p_cost_allocation_id_flex_num;
   close c;
end get_cost_allocation;
--
--
procedure get_pay_post_query(p_gl_set_of_books_id NUMBER
                            ,p_effective_end_date DATE
                            ,p_end_of_time DATE
                            ,p_period_type VARCHAR2
                            ,p_displayed_set_of_books IN OUT NOCOPY VARCHAR2
                            ,p_displayed_eff_end_date IN OUT NOCOPY DATE
                            ,p_chart_of_accounts_id IN OUT NOCOPY NUMBER
                            ,p_display_period_type IN OUT NOCOPY VARCHAR2) is
cursor c is
  select name
  ,      chart_of_accounts_id
  from   gl_sets_of_books
  where  set_of_books_id = p_gl_set_of_books_id;
cursor c_period_type is
  select display_period_type
  from   per_time_period_types_vl
  where  period_type = p_period_type;
sob_rec c%rowtype;
--
begin
   /* Get the Set of Books Name  and Chart of Accounts ID*/
   hr_utility.set_location('pay_pgl_pkg.get_pay_post_query',1);
   open c;
   fetch c into sob_rec;
   close c;
   p_displayed_set_of_books := sob_rec.name;
   p_chart_of_accounts_id := sob_rec.chart_of_accounts_id;
   --
   /* Set the Effective End Date */
   if p_effective_end_date = p_end_of_time then
      p_displayed_eff_end_date := '';
   else p_displayed_eff_end_date := p_effective_end_date;
   end if;
   --
   open  c_period_type;
   fetch c_period_type into p_display_period_type;
   close c_period_type;
   --
end get_pay_post_query;
--
--
procedure get_prf_post_query(p_gl_account_segment VARCHAR2
                            ,p_displayed_gl_segment IN OUT NOCOPY VARCHAR2
                            ,p_gl_flex_num NUMBER
                            ,p_payroll_cost_segment VARCHAR2
                            ,p_displayed_cost_segment IN OUT NOCOPY VARCHAR2
                            ,p_cost_flex_num NUMBER) is
--
cursor c(l_flex_code VARCHAR2
        ,l_flex_num NUMBER
        ,l_column_name VARCHAR2) is
   select segment_name
   from fnd_id_flex_segments
   where id_flex_code = l_flex_code
   and    id_flex_num  = l_flex_num
   and    enabled_flag = 'Y'
   and    application_column_name = l_column_name;
begin
   hr_utility.set_location('pay_pgl_pkg.get_prf_post_query',1);
   open c('GL#',p_gl_flex_num,p_gl_account_segment);
   fetch c into p_displayed_gl_segment;
   close c;
   --
   hr_utility.set_location('pay_pgl_pkg.get_prf_post_query',2);
   open c('COST',p_cost_flex_num,p_payroll_cost_segment);
   fetch c into p_displayed_cost_segment;
   close c;
end;
--
--
procedure prf_checks(p_rowid VARCHAR2
                    ,p_payroll_id NUMBER
                    ,p_gl_set_of_books_id NUMBER
                    ,p_gl_account_segment VARCHAR2 ) is
l_exists VARCHAR2(1);
--
cursor c1 is
select ''
from   pay_payroll_gl_flex_maps
where  payroll_id = p_payroll_id
and    gl_set_of_books_id = p_gl_set_of_books_id
and    gl_account_segment = p_gl_account_segment
and   ( p_rowid is null or
      (p_rowid is not null
   and chartorowid(p_rowid) <> rowid));
--
begin
   hr_utility.set_location('pay_pgl_pkg.prf_checks',1);
   open c1;
   fetch c1 into l_exists;
   if c1%found then
      close c1;
          hr_utility.set_message(801,'PAY_6962_DEF_GLMAP_DUP_GLSEG');
          hr_utility.raise_error;
   end if;
   close c1;
end prf_checks;
--
function future_payroll_rows(p_payroll_id NUMBER
                            ,p_session_date DATE) return BOOLEAN is
cursor c is
  select ''
  from   pay_payrolls_f
  where  payroll_id = p_payroll_id
  and    effective_start_date > p_session_date;
pay_rec c%rowtype;
--
begin
   hr_utility.set_location('pay_pgl_pkg.future_payroll_rows',1);
   open c;
   fetch c into pay_rec;
   if c%found then
      close c;
      return(TRUE);
   end if;
   close c;
   return(FALSE);
end future_payroll_rows;
--
END PAY_PGL_PKG;

/
