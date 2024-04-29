--------------------------------------------------------
--  DDL for Package Body PQH_SIT_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_SIT_ENGINE" as
/* $Header: pqsiteng.pkb 120.0 2005/05/29 02:41 appldev noship $ */

procedure get_attribute(p_txn_catg_attr_id in number, p_attribute_id out NOCOPY number,
                        p_value_style_cd OUT NOCOPY varchar2)  is
l_attribute_id number;
l_value_style_cd Varchar2(30);
begin
   select attribute_id, value_style_cd
   into l_attribute_id, l_value_style_cd
   from pqh_txn_category_attributes
   where txn_category_attribute_id = p_txn_catg_attr_id;
   hr_utility.set_location('attr : '||l_attribute_id, 5);
   hr_utility.set_location('l_value_style_cd : '||l_value_style_cd, 5);
   p_attribute_id := l_attribute_id;
   p_value_style_cd := l_value_style_cd;
exception
   when no_data_found then
      hr_utility.set_location('ndf txn_cat_attr : '||p_txn_catg_attr_id, 10);
      raise;
   when others then
      hr_utility.set_location('other error, txn_cat_attr : '||p_txn_catg_attr_id, 10);
      raise;
end get_attribute;

Function GET_TRANSACTION_VALUE (p_person_id      IN  number,
                                p_effective_date in date,
                                p_attribute_id   IN  number) RETURN  varchar2 IS
   l_sel_stmt               varchar2(4000);
   l_from_clause            PQH_TABLE_ROUTE.FROM_CLAUSE%TYPE;
   l_where_clause_in        PQH_TABLE_ROUTE.WHERE_CLAUSE%TYPE;
   l_where_clause_out       PQH_TABLE_ROUTE.WHERE_CLAUSE%TYPE;
   l_column_name            PQH_ATTRIBUTES.COLUMN_NAME%TYPE;
   l_column_type            PQH_ATTRIBUTES.COLUMN_TYPE%TYPE;
   l_selected_value_v       varchar2(2000);
   l_selected_value_n       number;
   l_selected_value_d       date;
   l_proc                   varchar2(100) := 'get_transaction_value';
   l_table_route_id         PQH_TABLE_ROUTE.TABLE_ROUTE_ID%TYPE;
BEGIN
hr_utility.set_location('Entering : '||l_proc, 5);
if (p_person_id is not null and p_attribute_id is not null) then

-- get the attribute details
   select column_name, master_table_route_id,column_type
   into   l_column_name, l_table_route_id,l_column_type
   from   pqh_attributes
   where  attribute_id = p_attribute_id;
   hr_utility.set_location('column_name1 is : '||substr(l_column_name,1,50),10);
   hr_utility.set_location('column_name2 is : '||substr(l_column_name,51,50),11);
   hr_utility.set_location('column_name3 is : '||substr(l_column_name,101,50),12);
   hr_utility.set_location('column_name4 is : '||substr(l_column_name,151,50),13);
   hr_utility.set_location('column_type is : '||l_column_type,15);
   hr_utility.set_location('table_route is : '||l_table_route_id,20);

-- table route is selected, get the details

   select from_clause, where_clause
   into   l_from_clause, l_where_clause_in
   from   pqh_table_route where table_route_id = l_table_route_id;

   hr_utility.set_location('from_clause1 is : '||substr(l_from_clause,1,30),30);
   hr_utility.set_location('from_clause2 is : '||substr(l_from_clause,31,30),31);
   hr_utility.set_location('where_clause 1is : '||substr(l_where_clause_in,1,40),40);
   hr_utility.set_location('where_clause 2is : '||substr(l_where_clause_in,41,40),40);

-- update the where clause with the context values

    pqh_refresh_data.replace_where_params(
      p_where_clause_in  => l_where_clause_in,
      p_txn_tab_flag     => 'N',
      p_txn_id           => p_person_id,
      p_where_clause_out => l_where_clause_out);
   hr_utility.set_location('where_clause 1is : '||substr(l_where_clause_out,1,40),50);
   hr_utility.set_location('where_clause 2is : '||substr(l_where_clause_out,41,40),50);

   hr_utility.set_location('select clause 1is : '||substr(l_column_name,1,40),50);
   l_column_name := replace(l_column_name,'p_person_id',p_person_id);
   hr_utility.set_location('select clause 2is : '||substr(l_column_name,1,40),50);
   l_column_name := replace(l_column_name,'p_effective_date',''''||to_char(p_effective_date,'dd/mm/yyyy')||'''');
   hr_utility.set_location('select clause 3is : '||substr(l_column_name,1,40),50);
-- build up the statement to be used for getting the value
    l_sel_stmt := 'select '||l_column_name||' from '||l_from_clause||' where '||l_where_clause_out ;
   hr_utility.set_location('stmt1 '||substr(l_sel_stmt,1,60),55);
   hr_utility.set_location('stmt2 '||substr(l_sel_stmt,61,60),55);
   hr_utility.set_location('stmt3 '||substr(l_sel_stmt,121,60),55);
   hr_utility.set_location('stmt4 '||substr(l_sel_stmt,181,60),55);
   hr_utility.set_location('stmt5 '||substr(l_sel_stmt,241,60),55);
   hr_utility.set_location('stmt6 '||substr(l_sel_stmt,361,60),55);

-- execute the dynamic sql
   if l_column_type ='D' then
      hr_utility.set_location('date being fetched ',60);
      execute immediate l_sel_stmt into l_selected_value_d;
      -- converting the date to character format
      l_selected_value_v := fnd_date.date_to_canonical(l_selected_value_d);
   elsif l_column_type ='N' then
      hr_utility.set_location('number being fetched ',60);
      execute immediate l_sel_stmt into l_selected_value_n;
      l_selected_value_v := to_char(l_selected_value_n);
   else
      hr_utility.set_location('varchar being fetched ',60);
      execute immediate l_sel_stmt into l_selected_value_v;
   end if;
   hr_utility.set_location('leaving with value: '||l_selected_value_v, 90);
   return l_selected_value_v;
else
   hr_utility.set_location('values passed was null. '||l_proc, 420);
   return null;
end if;
EXCEPTION
   when no_data_found then
      hr_utility.set_location('no data exists '||l_proc, 100);
      return null;
   WHEN others THEN
      hr_utility.set_location('Failure in program unit: '||l_proc, 420);
      return null;
END GET_TRANSACTION_VALUE;

function check_attribute_result(p_rule_from in varchar2,
                                p_txn_value in varchar2,
                                p_rule_to   in varchar2,
                                p_value_style_cd in varchar2,
                                p_exclude_flag in varchar2) return BOOLEAN is
   l_proc varchar2(30) := g_package||'check_attr';
BEGIN
   hr_utility.set_location('entering '||l_proc, 5);
   hr_utility.set_location('p_rule_from is '||p_rule_from, 5);
   hr_utility.set_location('p_rule_to is '||p_rule_to, 10);
   hr_utility.set_location('p_txn_value is '||p_txn_value, 15);
   hr_utility.set_location('p_value_style_cd is '||p_value_style_cd, 15);
   hr_utility.set_location('p_exclude_flag is '||p_exclude_flag, 15);

   if p_txn_value is null then
      hr_utility.set_location('txn_value_null'||l_proc, 420);
      return false;
   else
     IF  p_value_style_cd = 'EXACT' THEN
         hr_utility.set_location('Value Cd is Exact '||l_proc, 420);
	      IF p_txn_value = p_rule_from THEN
            hr_utility.set_location('txn value is equal to rule_from ', 420);
	        IF p_exclude_flag = 'Y' THEN
	           hr_utility.set_location('exclude flag Y ', 420);
	           RETURN FALSE;
	        ELSE
	          hr_utility.set_location('exclude flag N ', 420);
	          RETURN TRUE;
	        END IF;
          ELSE
	          hr_utility.set_location('txn value is not equal to rule_from ', 420);
	        IF p_exclude_flag = 'Y' THEN
	           hr_utility.set_location('exclude flag Y ', 420);
	           RETURN TRUE;
	        ELSE
	          hr_utility.set_location('exclude flag N ', 420);
	          RETURN FALSE;
	        END IF;
          END IF;
     ELSIF p_value_style_cd  = 'RANGE' THEN
	   if p_rule_from is null then
         hr_utility.set_location('rule_from null'||l_proc, 420);
         if p_txn_value <= p_rule_to then
            hr_utility.set_location('txn_value less than to '||l_proc, 420);
           IF p_exclude_flag = 'Y' THEN
	          RETURN FALSE;
	       ELSE
	         RETURN TRUE;
	       END IF;
         else
            hr_utility.set_location('txn_value more than to '||l_proc, 420);
            IF p_exclude_flag = 'Y' THEN
	              RETURN TRUE;
            ELSE
	              RETURN FALSE;
	        END IF;
         end if;
      else
         if p_rule_to is null then
            hr_utility.set_location('rule_to is null '||l_proc, 420);
            if p_txn_value >= p_rule_from then
               hr_utility.set_location('txn_value more than rule_from '||l_proc, 420);
              IF p_exclude_flag = 'Y' THEN
	            RETURN FALSE;
	          ELSE
	            RETURN TRUE;
	          END IF;
            else
               hr_utility.set_location('txn_value less than rule_from '||l_proc, 420);
               IF p_exclude_flag = 'Y' THEN
	              RETURN TRUE;
	           ELSE
	              RETURN FALSE;
	           END IF;
            end if;
         else
            if p_txn_value between p_rule_from and p_rule_to then
               hr_utility.set_location('txn_value between rule values '||l_proc, 420);
              IF p_exclude_flag = 'Y' THEN
	             RETURN FALSE;
	          ELSE
	            RETURN TRUE;
	          END IF;
            else
               hr_utility.set_location('txn_value not between rule values '||l_proc, 420);
               IF p_exclude_flag = 'Y' THEN
	              RETURN TRUE;
	           ELSE
	              RETURN FALSE;
	           END IF;
            end if;
         end if;
      end if;
	 END IF;
   end if;
EXCEPTION
   WHEN others THEN
      return false;
END CHECK_ATTRIBUTE_RESULT;

PROCEDURE apply_defined_rules(p_stat_sit_id    IN number,
                              p_person_id      IN number,
                              p_effective_date IN DATE,
                              p_rule_type      IN VARCHAR2 DEFAULT 'REQUIRED',
                              p_status_flag    OUT NOCOPY varchar2) is
   l_proc varchar2(71) := g_package||'  apply_defined_rules';
   l_cond_result boolean;
   l_transaction_value varchar2(2000);
   l_rule_from varchar2(2000);
   l_rule_to varchar2(2000);
   l_txn_type varchar2(30);
   l_final_stat varchar2(30);
   l_rule_message fnd_new_messages.message_text%type;
   l_attribute_id number;
   l_required_flag varchar2(2);
   l_exclude_flag varchar2(2);
   l_value_style_cd pqh_txn_category_attributes.value_style_cd%type;

   cursor csr_sit_rules (p_required_flag VARCHAR2) is
        select * from pqh_fr_stat_situation_rules
        where statutory_situation_id = p_stat_sit_id
        and nvl(enabled_flag,'N') ='Y'
        and required_flag = p_required_flag
        order by processing_sequence;
begin
     hr_utility.set_location('inside'||l_proc,10);

     p_status_flag := 'NO_RULES_DEFINED';

     hr_utility.set_location('p_rule_type '||p_rule_type,10);

     IF p_rule_type = 'REQUIRED' THEN
        l_required_flag := 'Y';
     ELSE
        l_required_flag := 'N';
     END IF;

        hr_utility.set_location('l_required_flag  '||l_required_flag,10);

   for i in csr_sit_rules(l_required_flag) loop
       hr_utility.set_location('Checking rule conditions '||l_proc,70);
       l_rule_from := i.from_value;
       l_rule_to := i.to_value;
       l_exclude_flag := i.exclude_flag;

       hr_utility.set_location('rule_from is '||l_rule_from,70);
       hr_utility.set_location('rule_to is '||l_rule_to,70);
       hr_utility.set_location('Exclude_flag is '||l_exclude_flag,70);

       hr_utility.set_location('Getting Attribute values ',70);
       get_attribute(i.txn_category_attribute_id, l_attribute_id, l_value_style_cd);
       hr_utility.set_location('attribute is '||l_attribute_id,70);
       hr_utility.set_location('l_value_style_cd is '||l_value_style_cd,70);

       if l_attribute_id is not null then
          l_transaction_value :=  get_transaction_value(p_person_id      => p_person_id,
                                                        p_effective_date => p_effective_date,
                                                        p_attribute_id   => l_attribute_id
                                                        );
          hr_utility.set_location('txn_value '||l_transaction_value,75);
       end if;

       if l_transaction_value is not null and l_rule_from is not null then
          hr_utility.set_location('checking result '||l_proc,75);
          l_cond_result := check_attribute_result(p_rule_from => l_rule_from,
                                                  p_txn_value => l_transaction_value,
                                                  p_rule_to   => l_rule_to,
                                                  p_value_style_cd => l_value_style_cd,
                                                  p_exclude_flag => l_exclude_flag);

            -- hr_utility.set_location('l_cond_result '||to_char(l_cond_result),70);

             IF l_cond_result THEN
	            p_status_flag := 'YES';
	            IF p_rule_type = 'OPTIONAL' THEN
	              EXIT;
	           END IF;
	         ELSE
	            p_status_flag := 'NO';
	            IF p_rule_type = 'REQUIRED' THEN
	              fnd_message.set_name('PQH','PQH_FR_REQD_SIT_RULE_FAIL');
                  HR_MULTI_MESSAGE.ADD;
                  RAISE HR_MULTI_MESSAGE.error_message_exist;
	              EXIT;
	            END IF;
	         END IF;
       end if;
       hr_utility.set_location('going for next rule',140);
   end loop; -- rules for all entities of a folder
  -- hr_utility.set_location('all rule applied '||l_final_stat,145);
   hr_utility.set_location('leaving '||l_proc,200);
exception
   when others then
      hr_utility.set_location('some error '||l_proc,420);
      raise;
end apply_defined_rules;

Function is_situation_valid (p_person_id in number,
                               p_effective_date IN DATE,
                               p_statutory_situation_id in NUMBER)
RETURN VARCHAR2
IS
   l_passed_all_reqd VARCHAR2(30);
   l_passed VARCHAR2(30);
   l_return_status VARCHAR2(10) := 'N';
   l_rule_valid  BOOLEAN := FALSE;
   BEGIN
--Validate the Mandatory Conditions first. If it meets all the conditions, then situation is valid.
     apply_defined_rules(p_statutory_situation_id ,p_person_id,p_effective_date,
                          'REQUIRED',l_passed_all_reqd);

      IF l_passed_all_reqd = 'YES' THEN
         hr_utility.set_location('l_passed_all_reqd  '||l_passed_all_reqd,10);
         l_return_status := 'Y';
      ELSIF l_passed_all_reqd = 'NO' THEN
         hr_utility.set_location('l_passed_all_reqd  '||l_passed_all_reqd,10);
         l_return_status := 'N';
      ELSIF l_passed_all_reqd = 'NO_RULES_DEFINED' THEN
         hr_utility.set_location('l_passed_all_reqd  '||l_passed_all_reqd,10);
--No Required rules defined. See if meets atleast one optional rule.
         apply_defined_rules(p_statutory_situation_id ,p_person_id,p_effective_date,
                          'OPTIONAL',l_passed);
          hr_utility.set_location('l_passed  '||l_passed,10);
         IF l_passed = 'YES' OR l_passed = 'NO_RULES_DEFINED' THEN
	       l_return_status := 'Y';
	     ELSE
	       l_return_status := 'N';
           fnd_message.set_name('PQH','PQH_FR_OPT_SIT_RULE_FAIL');
           HR_MULTI_MESSAGE.ADD;
           RAISE HR_MULTI_MESSAGE.error_message_exist;
	     END IF;
      END IF;
      RETURN l_return_status;
      hr_utility.set_location('leaving is_situation_valid ',10);
   END is_situation_valid;

end pqh_sit_engine;

/
