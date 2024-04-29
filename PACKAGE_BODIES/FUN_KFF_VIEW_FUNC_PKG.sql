--------------------------------------------------------
--  DDL for Package Body FUN_KFF_VIEW_FUNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_KFF_VIEW_FUNC_PKG" AS
/* $Header: funxtmkffvfcb.pls 120.0.12010000.2 2008/08/06 07:50:19 makansal ship $ */

function derive_format_attributes(p_value_set_id in number,
                                  p_qualifiers in varchar2) return varchar2 as
  cursor qual_csr is
    select segment_attribute_type||'.'||value_attribute_type qual
    from fnd_flex_validation_qualifiers
    where flex_value_set_id = p_value_set_id order by assignment_date;

  l_qualifiers varchar2(1000);
  l_n number;
  l_begin number;
  l_end number;
  l_v varchar2(100);


--GL_GLOBAL.DETAIL_POSTING_ALLOWED=Y|GL_GLOBAL.DETAIL_BUDGETING_ALLOWED=N
--GL_GLOBAL.DETAIL_BUDGETING_ALLOWED=N|GL_GLOBAL.DETAIL_POSTING_ALLOWED=Y'


begin
  for qual_rec in qual_csr loop

    l_n := instr(p_qualifiers, qual_rec.qual, 1, 1);

    if l_n <> 0 then
      l_n := instr(p_qualifiers, '=', l_n, 1);
      l_begin := l_n + 1;
      l_end := instr(p_qualifiers, '|' , l_n + 1, 1);
      if l_end <> 0 then
        l_v := substr(p_qualifiers, l_begin, l_end-l_begin);
      else
        l_v := substr(p_qualifiers, l_begin);
      end if;
      l_v := ''''||l_v||'''';
    else
      l_v := '''%''';
    end if;

    if l_qualifiers is null then
      l_qualifiers := l_v;
    else
      l_qualifiers := l_qualifiers||'||'||'fnd_global.newline||'||l_v;
    end if;

  end loop;
  return l_qualifiers;
exception when others then
  return null;
end;

function format_attributes(p_value_set_id in number,
                           p_compiled_value_attributes in varchar2) return varchar2 as
  cursor c is
    select count(*) from fnd_flex_validation_qualifiers where flex_value_set_id = p_value_set_id;

  num number;
  l_compiled_value_attributes varchar2(200);
  l_t number;

begin
  open c;
  fetch c into num;
  close c;

  l_compiled_value_attributes := p_compiled_value_attributes;

  for i in 1..num-1 loop
    l_t := instr(p_compiled_value_attributes, fnd_global.newline, 1, i);
    if l_t = 0 then
      l_compiled_value_attributes := l_compiled_value_attributes || fnd_global.newline;
    end if;
  end loop;

  return l_compiled_value_attributes;
exception when others then
  return null;
end;


/*
 * Bug: 6900726 FP for 4455493
 * Checks to see if the flex value is secured through security rules for the current
 * responsibility.
 *
 * TODO: This function currently does not support dependent value sets.
 *       Security rules for dependent value sets require the parent value.
 *       Bug 4481634 loggged to track this issue.
 *
 * @param p_value_set_id Value set identifier
 * @param p_flex_value   Segment value
 * @return 'T' if the value is not secured by the current responsibility. 'F' otherwise.
 */
function is_valid_on_security_rules(p_value_set_id in number,
                                    p_flex_value in varchar2) return varchar2 as

  l_security_status varchar2(2048);
  l_error_message varchar2(2048);
begin
  fnd_flex_server.check_value_security(
                p_security_check_mode => 'Y',
                p_flex_value_set_id => p_value_set_id,
                p_parent_flex_value => null,
                p_flex_value => p_flex_value,
                p_resp_application_id => fnd_global.resp_appl_id,
                p_responsibility_id => fnd_global.resp_id,
                x_security_status => l_security_status,
                x_error_message => l_error_message
                                );


  if l_security_status = 'NOT-SECURED' then
    return 'T';
  else
    return 'F';
  end if;
exception when others then
  return 'F';
end;

END;

/
