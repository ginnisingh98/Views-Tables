--------------------------------------------------------
--  DDL for Package Body EDR_POLICY_FUNCTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_POLICY_FUNCTION_PKG" AS
/*  $Header: EDRSECVB.pls 120.0.12000000.1 2007/01/18 05:55:19 appldev ship $ */

/* this function is used to control the update of the eRecords.
   the security rule says that no update is allowed from any
   interface other than Oracle applications.
*/
FUNCTION psig_modify (owner VARCHAR2, objname VARCHAR2)
RETURN VARCHAR2 AS
  l_predicate VARCHAR2(2000);
BEGIN
  if (sys_context('userenv','client_info') is null) then
   l_predicate := '1=2';
  end if;
 -- Bug 3411859 : Start
 -- Verfication for the secure context is also required for the Update.
  if (sys_context('edr_secure_ctx','secure') = 'Y') then
   l_predicate := '1=1';
  end if;
 -- Bug 3411859 : End
  return l_predicate;
END psig_modify;

/* this function is used to control the deletion of the eRecords.
   the security rule says that no deletion is allowed from any
   interface other than Oracle applications.
*/

FUNCTION psig_delete (owner VARCHAR2, objname VARCHAR2)
RETURN VARCHAR2 AS
BEGIN
   return '1=2';
END psig_delete;

/* this function is used to control the viewing of the eRecords.
   the view access is controlled by the security rules in the
   edr_psig_security table
*/
FUNCTION psig_view (owner VARCHAR2, objname VARCHAR2)
RETURN VARCHAR2 AS
  l_user varchar2(15);
  l_resp varchar2(15);
  l_high_security varchar2(1);

  l_old_section varchar2(30);
  l_old_event varchar2(240);

  l_current_event varchar2(240);
  l_current_section varchar2(30);
  l_value varchar2(500);
  l_rule_found boolean :=false;

  l_temp_predicate varchar2(600);
  l_wild_predicate varchar2(600);
  l_predicate varchar2(3000);

--for low (default) security level- everyone is granted access by default
  cursor c1 is
  select a.event_name, b.index_section_name, upper(a.secure_value) secure_value
  from edr_security_rules a, edr_secure_elements_v b
  where ((a.user_id = l_user or a.responsibility_id = l_resp) and a.access_code = 'R')
  and (a.start_date <= sysdate and (a.end_date >= sysdate or a.end_date is null))
  and a.ELEMENT_ID = b.ELEMENT_ID
  minus
  select a.event_name, b.index_section_name, upper(a.secure_value) secure_value
  from edr_security_rules a, edr_secure_elements_v b
  where (a.user_id = l_user and a.access_code = 'G')
  and (a.start_date <= sysdate and (a.end_date >= sysdate or a.end_date is null))
  and a.ELEMENT_ID = b.ELEMENT_ID
  order by event_name desc, index_section_name;

--for high securiy level- everyone has to be granted access
  cursor c2 is
  select a.event_name, b.index_section_name, upper(a.secure_value) secure_value
  from edr_security_rules a, edr_secure_elements_v b
  where ((a.user_id = l_user or a.responsibility_id = l_resp) and a.access_code = 'G')
  and (a.start_date <= sysdate and (a.end_date >= sysdate or a.end_date is null))
  and a.ELEMENT_ID = b.ELEMENT_ID
  minus
  select a.event_name, b.index_section_name, upper(a.secure_value) secure_value
  from edr_security_rules a, edr_secure_elements_v b
  where (a.user_id = l_user and a.access_code = 'R')
  and (a.start_date <= sysdate and (a.end_date >= sysdate or a.end_date is null))
  and a.ELEMENT_ID = b.ELEMENT_ID
  order by event_name desc, index_section_name;

BEGIN
/* if the select is coming from a secure context in oracle apps, don't
   get into rule deciphering at all.
*/
if (sys_context('edr_secure_ctx','secure') = 'Y') then
  l_predicate := '1=1';

/* if the select is coming from a direct source like SQL plus, simply
   abort the attempt.
*/
else

--if the query is coming in from direct source like sql plus abort
if (sys_context('userenv','client_info') is null) then
  l_predicate := '1=2';

/* if the select is from generic query decipher the security rules */
else
 l_user := fnd_global.user_id();

 l_resp:=fnd_global.resp_id();

/* determine site's security level */
 fnd_profile.get('EDR_SECURITY_HIGH',l_high_security);
 l_old_section := 'x';
 l_old_event:='x';

if (l_high_security <> 'Y') then
--this is the heart of the code for returning a predicate if the security
--level of the organization is low

  --This loop would read each security rule for the user and create a predicate based
  --on the security rules

  for rule_rec in c1 loop

    --set the boolean variable to indicate that at least one security rule found
    l_rule_found :=true;

    --obtain the value of event name and section name from cursor

    l_current_event := rule_rec.event_name ;
    l_current_event := nvl(l_current_event,'x');
    l_current_section := rule_rec.index_section_name;

    --if there are more than one security rules the control would enter this construct
    --in that case creating the predicate is more complex

    if (l_old_section <> 'x') then

	--if the currently read section name is not the same as last read (section break)
	--or the current event name is not same as last read (event break) then we have
	--to add conditions to the predicate
	--please note that the cursor is sorted on event name desc and section name

      if (l_current_section <> l_old_section or l_current_event <> l_old_event) then

	  --this temp predicate is used to store the predicate created when breaks on section
	  --name occur in the cursor

	  l_temp_predicate := 'CONTAINS(PSIG_XML, '''||l_value ||' WITHIN '||l_old_section||''')+0=0 ';

	  --the value read for all the section names = the last section name is flushed
	  l_value := null;

	  --if a section break occurs but the event is null then add the temp predicate to the
	  --final predicate

	  if(l_old_event ='x') then

	    --if the final predicate is already populated then use AND

	    if (l_predicate is not null) then
	      l_predicate := l_predicate || 'AND ';
          end if;
  	  l_predicate := l_predicate || '(' || l_temp_predicate  || ') ';

	  --flush out the temp predicate so that it can be used again
	  --this is doen whenever the temp predicate is used up to create the
	  --final predicate

        l_temp_predicate :=null;

	  end if;

	  --if an event break has also occured then add the conditions using event name
	  --to the predicate

	  if(l_current_event <> 'x' AND l_old_event <> 'x' and l_current_event <> l_old_event) then

	    if (l_predicate is not null) then
  	      l_predicate := l_predicate || 'AND ';
 	    end if;
	    l_predicate := l_predicate || '((' || l_temp_predicate || 'AND event_name = ''' ||
                         l_old_event|| ''') OR event_name <> ''' || l_old_event||''')';

   	    --flush out the temp predicate so that it can be used again
          l_temp_predicate :=null;

	  end if;
	  end if;
    end if;

    --the secure value is OR'd till we get a section break or an event break

    if (l_value is not null) then
	l_value := l_value|| '|';
    end if;
    l_value := l_value || rule_rec.secure_value;

    --the current section name and the event name are saved as old values before
    --new ones are fetched from the cursor

    l_old_event := l_current_event;
    l_old_section := l_current_section;

  end loop;

  --this construction of the predicate outside the for loop is used to take into
  --account the last read security rule and also if there is only security rule
  --it essentially does the same processing as above

  if(l_rule_found = true) then

  if(l_old_event <> 'x') then

    if (l_temp_predicate is not null) then
      l_temp_predicate := l_temp_predicate || 'AND ';
    end if;

    l_temp_predicate := l_temp_predicate ||'CONTAINS(PSIG_XML, '''||l_value ||
                        ' WITHIN  '||l_old_section||''')+0=0 ';
  else
    l_temp_predicate := 'CONTAINS(PSIG_XML, '''||l_value ||' WITHIN '||l_old_section||''')+0=0 ';
  end if;

  if (l_predicate is not null) then
    l_predicate := l_predicate || 'AND ';
  end if;

  if(l_old_event <> 'x') then

    l_predicate := l_predicate ||'((' || l_temp_predicate || 'AND event_name = '''||  l_old_event ||
                   ''') OR event_name <> ''' || l_old_event||''')';
  else
    l_predicate := l_predicate || '(' || l_temp_predicate  || ')';
  end if;
  end if;

else
--this is the heart of the code for returning a predicate if the security
--level of the organization is high

  --This loop would read each security rule for the user and create a predicate based
  --on the security rules

  for rule_rec in c2 loop

    --set the boolean variable to indicate that at least one security rule found
    l_rule_found :=true;

    --obtain the value of event name and section name from cursor

    l_current_event := rule_rec.event_name ;
    l_current_event := nvl(l_current_event,'x');
    l_current_section := rule_rec.index_section_name;

    --if there are more than one security rules the control would enter this construct
    --in that case creating the predicate is more complex

    if (l_old_section <> 'x') then

	--if the currently read section name is not the same as last read (section break)
	--or the current event name is not same as last read (event break) then we have
	--to add conditions to the predicate
	--please note that the cursor is sorted on event name desc and section name

      if (l_current_section <> l_old_section or l_current_event <> l_old_event) then

	  --this temp predicate is used to store the predicate created when breaks on section
	  --name occur in the cursor

	  l_temp_predicate := 'CONTAINS(PSIG_XML, '''||l_value ||' WITHIN  '||l_old_section||''')>0 ';

	  --the value read for all the section names till the section break is flushed
	  l_value := null;

	  --if a section break occurs but the event is null then add the temp predicate to the
	  --final predicate

	  if(l_old_event ='x') then

	    --if the final predicate is already populated then use AND
	    if (l_predicate is not null) then
	      l_predicate := l_predicate || 'OR ';
          end if;
  	    l_predicate := l_predicate || '(' || l_temp_predicate  || ') ';

          --flush out the temp predicate so that it can be used again
  	    --this is done whenever the temp predicate is used up to create the
	    --final predicate

          l_temp_predicate :=null;

	  end if;

	  --if an event break has also occured then add the conditions using event name
	  --to the predicate

	  if(l_current_event <> 'x' AND l_old_event <> 'x' and l_current_event <> l_old_event) then

	    if (l_predicate is not null) then
  	      l_predicate := l_predicate || 'OR ';
 	    end if;

	    l_predicate := l_predicate ||'((' || l_temp_predicate || ') AND event_name = '''||  l_old_event||''') ';

          --flush out the temp predicate so that it can be used again

          l_temp_predicate :=null;

	  end if;
	end if;
    end if;

    --the secure value is OR'd till we get a section break or an event break

    if (l_value is not null) then
	l_value := l_value|| '|';
    end if;
    l_value := l_value || rule_rec.secure_value;

    --the current section name and the event name are saved as old values before
    --new ones are fetched from the cursor

    l_old_event := l_current_event;
    l_old_section := l_current_section;
  end loop;

  --this construction of the predicate outside the for loop is used to take into
  --account the last read security rule and also if there is only security rule
  --it essentially does the same processing as above

  if(l_rule_found = true) then
  if(l_old_event <> 'x') then

    if (l_temp_predicate is not null) then
      l_temp_predicate := l_temp_predicate || 'OR ';
    end if;

    l_temp_predicate := l_temp_predicate || 'CONTAINS(PSIG_XML, '''||l_value ||
                        ' WITHIN  ' || l_old_section || ''')>0 ';
  else
    l_temp_predicate := 'CONTAINS(PSIG_XML, '''||l_value ||' WITHIN  '||l_old_section||''')>0 ';
  end if;

  if (l_predicate is not null) then
    l_predicate := l_predicate || 'OR ';
  end if;

  if(l_old_event <> 'x') then

    l_predicate := l_predicate || '((' || l_temp_predicate || ') AND event_name = '''||  l_old_event||''') ';
  else
    l_predicate := l_predicate || '(' || l_temp_predicate  || ')';
  end if;

  end if;

end if;

if (l_high_security = 'Y' and l_rule_found = false) then
	l_predicate := '1=2';
end if;

end if;
end if;

return l_predicate;
END psig_view;
end edr_policy_function_pkg;

/
