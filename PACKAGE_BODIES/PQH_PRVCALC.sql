--------------------------------------------------------
--  DDL for Package Body PQH_PRVCALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PRVCALC" as
/* $Header: pqprvcal.pkb 120.1 2005/07/05 17:13:19 hsajja noship $ */
-- global package variable for the purpose of hr_utility.

g_package varchar2(2000) := 'pqh_prvcalc.';


--
-- ----------------------------------------------------------------------------
-- |------------------------< list_attribute_privs >----------------------------|
-- ----------------------------------------------------------------------------
--
-- to be used for debugging results with trace on
--
procedure list_attribute_privs is
begin
for i in g_result.first .. g_result.last loop
   hr_utility.set_location('form_col :'||g_result(i).form_column_name||' Mod : '||g_result(i).mode_flag||' Req :'||g_result(i).reqd_flag,10);
end loop;
end;
--
-- ----------------------------------------------------------------------------
-- |------------------------< task_task_reqd_comp_flag >------------------------|
-- ----------------------------------------------------------------------------
--

procedure task_task_reqd_comp_flag (p_task1_reqd_flag in varchar2,
                                    p_task2_reqd_flag in varchar2,
                                    p_result_reqd_flag   out nocopy varchar )
as
l_proc varchar2(2000) := g_package||'task_task_reqd_comp_flag' ;
begin
    hr_utility.set_location('Entering'||l_proc,10);
    if p_task1_reqd_flag = 'Y' or p_task2_reqd_flag ='Y' then
       p_result_reqd_flag := 'Y' ;
    else
       p_result_reqd_flag := 'N' ;
    end if;
    hr_utility.set_location('Exiting'||l_proc,10000);
exception when others then
p_result_reqd_flag := null;
raise;
end task_task_reqd_comp_flag;

--
-- ----------------------------------------------------------------------------
-- |------------------------< attribute_flag_result >------------------------|
-- ----------------------------------------------------------------------------
--
procedure attribute_flag_result (p_edit_flag   in varchar2,
                                 p_view_flag   in varchar2,
                                 p_result_flag    out nocopy varchar2 )
as
  l_proc varchar2(2000) := g_package||'attribute_flag_result' ;
begin
--    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This procedure is used for calculating the result flag based on the
    values of the edit flag and the view flag which are taken as input.
     If edit flag is Yes then result is E irrespective of the value of the View flag.
     if edit flag is No then view flag determines the value of the result flag.
     if view flag is yes and edit flag is no then result flag is V else result flag is N.
    */
  if p_edit_flag = 'Y' then
     p_result_flag := 'E';
  elsif p_view_flag = 'Y' then
     p_result_flag := 'V' ;
  else
     p_result_flag := 'N' ;
  end if;
  hr_utility.set_location('edit'||p_edit_flag||' view '||p_view_flag||' result '||p_result_flag||l_proc,20);
--  hr_utility.set_location('Exiting'||l_proc,10000);
exception when others then
p_result_flag := null;
raise;
end attribute_flag_result;

--
-- ----------------------------------------------------------------------------
-- |------------------------< task_task_mode_comp_flag >------------------------|
-- ----------------------------------------------------------------------------
--
procedure task_task_mode_comp_flag(p_task1_flag in varchar2,
                                   p_task2_flag in varchar2,
                                   p_result_flag   out nocopy varchar2 )
as
  l_proc varchar2(2000) := g_package||'task_task_mode_comp_flag' ;
begin
--    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This procedure is used for calculating result of the comparison of the
    flags associated with an attribute of a task.
    Task1  task2 are the input parameters . Flags can have possible values
    (E,V,N ) listed in the order of heirarchy . In the task flag comparison ,
    higher flag is to be returned as result.  if any of the flag is E then
    result is E which is the highest value for the flag. which represents
    that the attribute is editable for the task.  if both the flags are N
    then result is N which means that attribute is not even viewable for
    the task.
    */
    if p_task1_flag ='E' or p_task2_flag = 'E' then
        p_result_flag := 'E' ;
    elsif p_task1_flag = 'V' or p_task2_flag = 'V' then
        p_result_flag := 'V' ;
    else
        p_result_flag := 'N' ;
    end if;
    hr_utility.set_location('task1'||p_task1_flag||' task2 '||p_task2_flag||' result '||p_result_flag||l_proc,20 );
--    hr_utility.set_location('Exiting'||l_proc,10000);
exception when others then
p_result_flag := null;
raise;
end task_task_mode_comp_flag;

--
-- ----------------------------------------------------------------------------
-- |------------------------< domain_task_mode_comp_flag >------------------------|
-- ----------------------------------------------------------------------------
--
procedure domain_task_mode_comp_flag(p_domain_mode_flag in varchar2,
                                     p_task_mode_flag   in varchar2,
                                     p_result_flag         out nocopy varchar2 )
as
   l_proc varchar2(2000) := g_package||'domain_task_mode_comp_flag' ;
begin
--    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This procedure is used for calculating the result of comparison of
    domain flag and task flag associated with the attribute. Flag can have
    values (E,V,N) . Minimum of the two flags is to be calculated as result.
    */
    if p_domain_mode_flag = 'E' then
        if p_task_mode_flag = 'E' then
            p_result_flag := 'E' ;
        elsif p_task_mode_flag ='V' then
            p_result_flag := 'V' ;
        else
            p_result_flag := 'N' ;
        end if;
    elsif p_domain_mode_flag = 'V' then
        if p_task_mode_flag ='N' then
            p_result_flag := 'N' ;
        else
            p_result_flag := 'V' ;
        end if;
    else
        p_result_flag := 'N' ;
    end if;
    hr_utility.set_location('domain'||p_domain_mode_flag||' task '||p_task_mode_flag||' result '||p_result_flag||l_proc,20 );
--    hr_utility.set_location('Exiting'||l_proc,10000);
exception when others then
p_result_flag := null;
raise;
end domain_task_mode_comp_flag;

--
-- ----------------------------------------------------------------------------
-- |------------------------< domain_result_calc >------------------------|
-- ----------------------------------------------------------------------------
--
procedure domain_result_calc (p_domain in pqh_template_attributes.template_id%type,
                              p_result    out nocopy t_attid_priv)
as
  l_count number := 1;
  l_result_flag varchar2(1) ;
  l_result t_attid_priv;
  cursor c1(l_template_id number) is
      select edit_flag,view_flag,attribute_id
      from pqh_template_attributes
      where template_id = l_template_id;
  l_proc varchar2(2000) := g_package||'domain_result_calc' ;
begin
    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This procedure is used for calculating the attribute and result flag
    associated to a domain.  domain template id is taken as input parameter
    and result is stored in the pl/sql table of records. Call to attribute
    flag result is made to find out nocopy the result flag for each attribute.
    */
  l_count := 1 ;
  for l_domain_rec in c1(p_domain) loop
--    hr_utility.set_location('# '||to_char(l_count)||' attribute '||to_char(l_domain_rec.attribute_id)||l_proc,20 );
    attribute_flag_result(p_edit_flag   => l_domain_rec.edit_flag,
                          p_view_flag   => l_domain_rec.view_flag,
                          p_result_flag => l_result_flag);
    p_result(l_count).attribute_id := l_domain_rec.attribute_id;
    p_result(l_count).mode_flag := l_result_flag;
-- domain 's required flag is not considered for computing the required flag of attribute.
    p_result(l_count).reqd_flag := '';
-- domain's task type is also not considered
    p_result(l_count).task_type := '';
    l_count := l_count + 1 ;
  end loop;
  hr_utility.set_location('Exiting'||l_proc,10000);
  exception when others then
  p_result := l_result;
  raise;
end;

--
-- ----------------------------------------------------------------------------
-- |------------------------< task_result_update >------------------------|
-- ----------------------------------------------------------------------------
--
procedure task_result_update (p_task       in pqh_template_attributes.template_id%type,
			      p_task_type  in varchar2,
                              p_result_int in out nocopy t_attid_priv)
as
	l_result_int t_attid_priv := p_result_int;
  l_res_count number ;
  l_result_flag varchar2(1);
  l_reqd_flag varchar2(1);
  l_ins_result varchar2(1);
  l_task_last_count number ;
  cursor c1(l_task_template_id number) is
      select edit_flag,view_flag,attribute_id,required_flag
      from pqh_template_attributes
      where template_id = l_task_template_id;
  l_proc varchar2(2000) := g_package||'task_result_update' ;
begin
--    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This procedure is used to update internal result table which stores result
    flags for the attributes associated with the list of tasks. Internal result
    table and task template id are the input parameters and internal result
    table after updation is passed back as result.
    for the task, attributes  their flags are fetched from the database. Result
    flag is calculated using attribute flag result procedure.
    Presence of the attribute is checked in the internal result table. if the
    attribute is available in the internal result table then flag comparison
    is made and result is stored back in internal result table. if no match is
    made for the attribute then attribute is added in the internal result
    table with the result flag.
    */
    hr_utility.set_location('task is'||p_task||l_proc,15 );
    for i in c1(p_task) loop
--        hr_utility.set_location('Values task, attribute '||to_char(i.attribute_id)||'edit '||i.edit_flag||' view '||i.view_flag||l_proc,20 );
        attribute_flag_result(p_edit_flag   => i.edit_flag,
                              p_view_flag   => i.view_flag,
                              p_result_flag => l_result_flag);
        l_reqd_flag := substr(nvl(i.required_flag,'N'),1,1) ;
        l_res_count := 1;
        l_ins_result := 'Y';
        l_task_last_count := p_result_int.count;
        for l_res_count in 1..l_task_last_count loop
            if p_result_int(l_res_count).attribute_id = i.attribute_id then
               l_ins_result := 'N' ;
--	       hr_utility.set_location('Table has'||p_result_int(l_res_count).task_type||' adding '||p_task_type||l_proc,30);
	       if p_result_int(l_res_count).task_type = 'T' then
		  if p_task_type ='T' then
-- max of the attribute flags is stored in the table
 --                    hr_utility.set_location('Attribute flags updated '||l_proc,40);
                     task_task_mode_comp_flag(p_task1_flag  => p_result_int(l_res_count).mode_flag,
                                              p_task2_flag  => l_result_flag,
                                              p_result_flag => p_result_int(l_res_count).mode_flag);
                     task_task_reqd_comp_flag(p_task1_reqd_flag  => p_result_int(l_res_count).reqd_flag,
                                              p_task2_reqd_flag  => l_reqd_flag,
                                              p_result_reqd_flag => p_result_int(l_res_count).reqd_flag);
-- else attribute flags of the reference template are not considered in comparison to task attribute flags
		  end if;
	       else
		  if p_task_type ='T' then
-- table stores Reference and compared with task , task attribute flags replae reference template attribute flags
		     p_result_int(l_res_count).mode_flag := l_result_flag;
		     p_result_int(l_res_count).reqd_flag := l_reqd_flag;
		     p_result_int(l_res_count).task_type := 'T';
		  else
-- max of the attribute flags is stored in the table
                     task_task_mode_comp_flag(p_task1_flag  => p_result_int(l_res_count).mode_flag,
                                              p_task2_flag  => l_result_flag,
                                              p_result_flag => p_result_int(l_res_count).mode_flag);
                     task_task_reqd_comp_flag(p_task1_reqd_flag  => p_result_int(l_res_count).reqd_flag,
                                              p_task2_reqd_flag  => l_reqd_flag,
                                              p_result_reqd_flag => p_result_int(l_res_count).reqd_flag);
		  end if;
	       end if;
            end if;
        end loop;
        if l_ins_result ='Y' then
--           hr_utility.set_location('New attribute added '||l_proc,50);
           l_res_count := l_task_last_count + 1;
           p_result_int(l_res_count).attribute_id := i.attribute_id;
           p_result_int(l_res_count).mode_flag := l_result_flag ;
           p_result_int(l_res_count).reqd_flag := l_reqd_flag;
           p_result_int(l_res_count).task_type := p_task_type;
        end if;
    end loop;
--  hr_utility.set_location('Exiting'||l_proc,10000);
exception when others then
p_result_int := l_result_int;
raise;
end task_result_update;

--
-- ----------------------------------------------------------------------------
-- |------------------------< task_references >------------------------|
-- ----------------------------------------------------------------------------
--

procedure task_references(p_task       in pqh_template_attributes.template_id%type,
                          p_result_int in out nocopy t_attid_priv)
as

l_result_int t_attid_priv := p_result_int;
  cursor c2(p_template_id number) is
  select base_template_id
  from pqh_ref_templates
  where parent_template_id = p_template_id
  and reference_type_cd = 'REFERENCE';

  l_proc varchar2(2000) := g_package||'task_references' ;
begin
    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This procedure is used for finding out nocopy reference tasks associated with
    each task and also taking into account their flag values and updating
    those into the internal result table.  for each reference task associated
    with a task, call to task_result update is made.
    */
    for i in c2(p_task) loop
       hr_utility.set_location('values fetched are attribute '||to_char(i.base_template_id)||l_proc,20 );
       task_result_update(p_task       => i.base_template_id,
			  p_task_type  => 'R',
                          p_result_int => p_result_int);
    end loop;
    hr_utility.set_location('Exiting'||l_proc,10000);

exception when others then
p_result_int := l_result_int;
raise;
end task_references;

procedure check_priv_calc is
  p_domain pqh_template_attributes.template_id%type;
  p_tasks  t_task_templ;
  p_result t_attname_priv;
  p_transaction_category_id number;
  l_proc varchar2(256) := g_package||'check_priv_calc';
begin
  p_domain := 1;
  p_tasks(1) := 2;
  priviledge_calc(p_domain => p_domain,
                  p_tasks  => p_tasks,
		  p_transaction_category_id => p_transaction_category_id,
                  p_result => p_result);
  for i in 1..p_result.last loop
      hr_utility.set_location('att'||p_result(i).form_column_name||'mode'||p_result(i).mode_flag||'reqd'||p_result(i).reqd_flag||l_proc,200);
  end loop;
end check_priv_calc;

procedure get_row_prv( p_row in number,
                       p_form_column_name out nocopy pqh_txn_category_attributes.form_column_name%type,
                       p_mode_flag out nocopy varchar2,
                       p_reqd_flag out nocopy varchar2)
is
 l_proc varchar2(256) := g_package||'get_row_prv';
begin
  p_form_column_name := g_result(p_row).form_column_name;
  p_mode_flag      := g_result(p_row).mode_flag;
  p_reqd_flag      := g_result(p_row).reqd_flag;
  hr_utility.set_location('exiting'||l_proc,10000);
end get_row_prv;

procedure priviledge_calc_count (p_domain       in pqh_template_attributes.template_id%type,
                                 p_tasks        in t_task_templ,
				 p_transaction_category_id in number,
			         p_result_count    out nocopy number )
is
  l_temp_flag         varchar2(1);
  l_task_count        number  := 1;
  l_error_flag        boolean := FALSE;
  l_task_last_count   number  := 1;
  l_domain_last_count number  := 1;
  l_att_count         number  := 1;
  l_res_count         number  := 1;
  l_int_res_count     number  := 1;
  l_count             number  := 1;
  l_task_att_count    number ;
  l_chg_result        varchar2(1) := 'Y' ;
  l_task_template_id  pqh_template_attributes.template_id%type;
  l_form_column_name  pqh_txn_category_attributes.form_column_name%type;
  l_result_flag       varchar2(1) ;
  l_result_task_int   t_attid_priv;
  l_result_domain_int t_attid_priv;
  cursor c1(p_attribute_id number) is
          select form_column_name
      from pqh_txn_category_attributes
      where attribute_id = p_attribute_id
      and transaction_category_id = p_transaction_category_id;
  l_proc varchar2(2000) := g_package||'priviledge_calc_count' ;
begin
    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This is the main procedure . It takes domain template id and an table of tasks as input
    and passes the attributes and their flag values as result .
    This procedure has three parts.
    1) Internal result table is computed according to the tasks and their references attributes and flags.
    2) Result table is computed according to the domain attributes and their flags.
    3) Internal result table is applied on result table to take the minimum of the attribute flag
       value and result is stored in the result table .
    4) form_column name is fetched corresponding to the attribute_id from the database and flag values are
       stored in the table and this table of records is passed as out nocopy parameter
    */
/* Check the input data validity, if domain is null then raise error and don't process the whole procedure */

    l_task_last_count := p_tasks.count;
    if p_domain is null then
       l_error_flag := TRUE;
       hr_utility.set_location('domain reqd'||l_proc,20);
    elsif l_task_last_count = 0  then
       l_error_flag := TRUE;
       hr_utility.set_location('tasks reqd'||l_proc,30);
    end if;

    -- Part1 starts here
    /*
    for each task in the task table internal result table is updated call to Task
    references is made
    */
    if l_error_flag = FALSE then
       for l_task_count in 1..l_task_last_count loop
         l_task_template_id := p_tasks(l_task_count) ;
         task_result_update(p_task       => p_tasks(l_task_count),
                            p_task_type  => 'T',
                            p_result_int => l_result_task_int) ;
         task_references(p_task       => p_tasks(l_task_count),
                         p_result_int => l_result_task_int) ;
       end loop;
       l_task_att_count := l_result_task_int.count;
       for i in 1..l_task_att_count loop
	   hr_utility.set_location('att '||l_result_task_int(i).attribute_id||'mode '||l_result_task_int(i).mode_flag||'reqd '||l_result_task_int(i).reqd_flag||l_proc,35);
       end loop;

-- Part2 : Computation of result table , corresponding to domain template
       domain_result_calc(p_domain => p_domain,
                          p_result => l_result_domain_int);

-- Part3 starts here
  /*
  Applying internal result table on the result table to find out nocopy the minimum of the
  flag value applicable to the attribute
  Call to domain_task_comp flag is made for each comparison.
  if an attribute is not there in the internal result table then result table is updated
  for that attribute and flag is made N.
  */
       l_domain_last_count := l_result_domain_int.count;
       l_res_count := 1;
       for l_res_count in 1..l_domain_last_count loop
         l_int_res_count := 1;
         l_chg_result := 'Y' ;
         l_task_last_count := l_result_task_int.count;
         for l_int_res_count in 1..l_task_last_count loop
           if l_result_domain_int(l_res_count).attribute_id = l_result_task_int(l_int_res_count).attribute_id then
               l_chg_result := 'N' ;
	       hr_utility.set_location('attribute in task'||to_char(l_result_task_int(l_int_res_count).attribute_id)||l_proc,95);
-- mode flag is taken as minimum of domain and task privledges
               domain_task_mode_comp_flag(p_domain_mode_flag => l_result_domain_int(l_res_count).mode_flag,
                                          p_task_mode_flag   => l_result_task_int(l_int_res_count).mode_flag,
                                          p_result_flag      => l_temp_flag);
               l_result_domain_int(l_res_count).mode_flag := l_temp_flag;
-- while required flag is solely task priviledge
               l_result_domain_int(l_res_count).reqd_flag := l_result_task_int(l_int_res_count).reqd_flag ;
           end if;
         end loop;
         if l_chg_result = 'Y' then
-- selected tasks don't have priviledge on this attribute
           l_result_domain_int(l_res_count).mode_flag := 'N' ;
           l_result_domain_int(l_res_count).reqd_flag := 'N' ;
         end if;
       end loop;

-- Part 4 start
-- The results stored in l_result_domain_int table are to be transfered to result table which will have attribute name
       p_result_count := l_result_domain_int.count;
       for i in 1..p_result_count loop
           open c1(l_result_domain_int(i).attribute_id) ;
           fetch c1 into l_form_column_name;
           close c1;
           g_result(i).form_column_name := l_form_column_name;
           g_result(i).mode_flag := l_result_domain_int(i).mode_flag;
           g_result(i).reqd_flag := l_result_domain_int(i).reqd_flag;
	   hr_utility.set_location('att'||g_result(i).form_column_name||'mode'||g_result(i).mode_flag||'reqd'||g_result(i).reqd_flag||l_proc,200);
       end loop;
   else
       hr_utility.set_location('errors , cannot execute'||l_proc,100);
   end if;
  hr_utility.set_location('Exiting'||l_proc,10000);
  exception when others then
  p_result_count := null;
  raise;
end priviledge_calc_count;

--
-- ----------------------------------------------------------------------------
-- |------------------------< priviledge_calc >------------------------|
-- ----------------------------------------------------------------------------
--

procedure priviledge_calc (p_domain in pqh_template_attributes.template_id%type,
                           p_tasks  in t_task_templ,
			   p_transaction_category_id in number,
			   p_result    out nocopy t_attname_priv )
is
  l_temp_flag         varchar2(1);
  l_result	t_attname_priv;
  l_task_count        number  := 1;
  l_error_flag        boolean := FALSE;
  l_task_last_count   number  := 1;
  l_domain_last_count number  := 1;
  l_att_count         number  := 1;
  l_res_count         number  := 1;
  l_int_res_count     number  := 1;
  l_count             number  := 1;
  l_task_att_count    number ;
  l_chg_result        varchar2(1) := 'Y' ;
  l_task_template_id  pqh_template_attributes.template_id%type;
  l_form_column_name  pqh_txn_category_attributes.form_column_name%type;
  l_result_flag       varchar2(1) ;
  l_result_task_int   t_attid_priv;
  l_result_domain_int t_attid_priv;
  cursor c1(p_attribute_id number) is
          select form_column_name
      from pqh_txn_category_attributes
      where attribute_id = p_attribute_id
      and transaction_category_id = p_transaction_category_id;
  l_proc varchar2(2000) := g_package||'priviledge_calc' ;
begin
    hr_utility.set_location('Entering'||l_proc,10);
    /*
    This is the main procedure . It takes domain template id and an table of tasks as input
    and passes the attributes and their flag values as result .
    This procedure has three parts.
    1) Internal result table is computed according to the tasks and their references attributes and flags.
    2) Result table is computed according to the domain attributes and their flags.
    3) Internal result table is applied on result table to take the minimum of the attribute flag
       value and result is stored in the result table .
    4) form_column_name is fetched corresponding to the attribute_id from the database and flag values are
       stored in the table and this table of records is passed as out nocopy parameter
    */
/* Check the input data validity, if domain is null then raise error and don't process the whole procedure */

    l_task_last_count := p_tasks.count;
    if p_domain is null then
       l_error_flag := TRUE;
       hr_utility.set_location('domain reqd'||l_proc,20);
    elsif l_task_last_count = 0  then
       l_error_flag := TRUE;
       hr_utility.set_location('tasks reqd'||l_proc,30);
    end if;

    -- Part1 starts here
    /*
    for each task in the task table internal result table is updated call to Task
    references is made
    */
    if l_error_flag = FALSE then
       for l_task_count in 1..l_task_last_count loop
         l_task_template_id := p_tasks(l_task_count) ;
         task_result_update(p_task       => p_tasks(l_task_count),
                            p_task_type  => 'T',
                            p_result_int => l_result_task_int) ;
         task_references(p_task       => p_tasks(l_task_count),
                         p_result_int => l_result_task_int) ;
       end loop;
       l_task_att_count := l_result_task_int.count;
       for i in 1..l_task_att_count loop
	   hr_utility.set_location('att '||l_result_task_int(i).attribute_id||'mode '||l_result_task_int(i).mode_flag||'reqd '||l_result_task_int(i).reqd_flag||l_proc,35);
       end loop;

-- Part2 : Computation of result table , corresponding to domain template
       domain_result_calc(p_domain => p_domain,
                          p_result => l_result_domain_int);

-- Part3 starts here
  /*
  Applying internal result table on the result table to find out nocopy the minimum of the
  flag value applicable to the attribute
  Call to domain_task_comp flag is made for each comparison.
  if an attribute is not there in the internal result table then result table is updated
  for that attribute and flag is made N.
  */
       l_domain_last_count := l_result_domain_int.count;
       l_res_count := 1;
       for l_res_count in 1..l_domain_last_count loop
         l_int_res_count := 1;
         l_chg_result := 'Y' ;
         l_task_last_count := l_result_task_int.count;
         for l_int_res_count in 1..l_task_last_count loop
           if l_result_domain_int(l_res_count).attribute_id = l_result_task_int(l_int_res_count).attribute_id then
               l_chg_result := 'N' ;
	       hr_utility.set_location('attribute in task'||to_char(l_result_task_int(l_int_res_count).attribute_id)||l_proc,95);
-- mode flag is taken as minimum of domain and task privledges
               domain_task_mode_comp_flag(p_domain_mode_flag => l_result_domain_int(l_res_count).mode_flag,
                                          p_task_mode_flag   => l_result_task_int(l_int_res_count).mode_flag,
                                          p_result_flag      => l_temp_flag);
               l_result_domain_int(l_res_count).mode_flag := l_temp_flag;
-- while required flag is solely task priviledge
               l_result_domain_int(l_res_count).reqd_flag := l_result_task_int(l_int_res_count).reqd_flag ;
           end if;
         end loop;
         if l_chg_result = 'Y' then
-- selected tasks don't have priviledge on this attribute
           l_result_domain_int(l_res_count).mode_flag := 'N' ;
           l_result_domain_int(l_res_count).reqd_flag := 'N' ;
         end if;
       end loop;

-- Part 4 start
-- The results stored in l_result_domain_int table are to be transfered to result table which will have attribute name
       l_count := l_result_domain_int.count;
       for i in 1..l_count loop
           open c1(l_result_domain_int(i).attribute_id) ;
           fetch c1 into l_form_column_name;
           close c1;
           p_result(i).form_column_name := l_form_column_name;
           p_result(i).mode_flag := l_result_domain_int(i).mode_flag;
           p_result(i).reqd_flag := l_result_domain_int(i).reqd_flag;
	   hr_utility.set_location('att'||p_result(i).form_column_name||'mode'||p_result(i).mode_flag||'reqd'||p_result(i).reqd_flag||l_proc,200);
       end loop;
   else
       hr_utility.set_location('errors , cannot execute'||l_proc,100);
   end if;
  hr_utility.set_location('Exiting'||l_proc,10000);
  exception when others then
  p_result := l_result;
  raise;
end priviledge_calc;

--
-- ----------------------------------------------------------------------------
-- |------------------------< template_attrib_reqd_calc >------------------------|
-- ----------------------------------------------------------------------------
--

procedure template_attrib_reqd_calc (p_tasks in t_task_templ,
				     p_transaction_category_id in number,
                                     p_result   out nocopy t_attname_priv)
as
  l_task_count                number := 1;
  i                           binary_integer := 1;
  l_task_template_id          pqh_template_attributes.template_id%type;
  l_form_column_name          pqh_txn_category_attributes.form_column_name%type;
  l_result_task_int           t_attid_priv;
  l_result		      t_attname_priv;

  cursor c1(p_attribute_id number) is
        select form_column_name
        from   pqh_txn_category_attributes
        where  attribute_id = p_attribute_id
	and transaction_category_id = p_transaction_category_id;

  l_proc varchar2(2000) := g_package||'template_attrib_reqd_calc' ;
begin
  hr_utility.set_location('Entering'||l_proc,10);
  for l_task_count in 1..p_tasks.count loop
    l_task_template_id := p_tasks(l_task_count) ;
    task_result_update(p_task       => p_tasks(l_task_count),
		       p_task_type  => 'T',
                       p_result_int => l_result_task_int) ;
    task_references(p_task       => p_tasks(l_task_count),
                    p_result_int => l_result_task_int) ;
  end loop;
  for i in 1..l_result_task_int.count loop
      open c1(l_result_task_int(i).attribute_id) ;
      fetch c1 into l_form_column_name;
      close c1;
      p_result(i).form_column_name := l_form_column_name;
      p_result(i).mode_flag := l_result_task_int(i).mode_flag;
      p_result(i).reqd_flag := l_result_task_int(i).reqd_flag;
  end loop;
  hr_utility.set_location('Exiting'||l_proc,10000);
  exception when others then
  p_result := l_result;
  raise;
end template_attrib_reqd_calc;
--
-- ----------------------------------------------------------------------------
-- |------------------------< get_attribute_mode >----------------------------|
-- ----------------------------------------------------------------------------
--

function get_attribute_mode(
    p_form_column_name       in varchar2)
return varchar2 is
begin
for i in g_result.first .. g_result.last loop
  if g_result(i).form_column_name = p_form_column_name then
    return g_result(i).mode_flag;
  end if;
end loop;
return 'N';
exception
when others then
return 'N';
end;
--
end;

/
