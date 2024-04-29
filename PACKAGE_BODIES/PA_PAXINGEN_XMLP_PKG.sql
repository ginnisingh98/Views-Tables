--------------------------------------------------------
--  DDL for Package Body PA_PAXINGEN_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXINGEN_XMLP_PKG" AS
/* $Header: PAXINGENB.pls 120.0.12010000.3 2008/12/12 09:32:48 dbudhwar ship $ */

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

function BeforeReport return boolean is
begin

DECLARE
 init_failure exception;
 org_name hr_organization_units.name%TYPE;
 member_name VARCHAR2(40);
 role_type VARCHAR2(40);
 enter_param VARCHAR2(80);
 inv_status VARCHAR2(30);
 prj_status VARCHAR2(100);
 pca_date date;
 draft_inv VARCHAR2(30);
 disp_details VARCHAR2(30);
 disp_unbilled VARCHAR2(30);
 p_number VARCHAR2(30);
 p_name VARCHAR2(30);

BEGIN


/*srw.user_exit('FND SRWINIT');*/null;



/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;








/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;








/*srw.user_exit('FND GETPROFILE
NAME="CURRENCY:MIXED_PRECISION"
FIELD=":p_min_precision"
PRINT_ERROR="N"');*/null;




IF (p_start_organization_id is null and
   project_member is null and
   project_id is null) then
    BEGIN




      select start_organization_id into p_start_organization_id
      from  pa_implementations;

      exception
      when no_data_found then
               null;
      when others then
          /*srw.message(2,'select start_organization_id in before_report' || sqlerrm);*/null;


    END;
END IF;


 IF p_start_organization_id is not null then
   begin
    select substr(name, 1, 40) into org_name from
      hr_organization_units where
      organization_id = p_start_organization_id;
     exception
       when no_data_found then
          null;
       when others then
          /*srw.message(2,'Org ID ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;

     end;
 END IF;
 c_start_org := org_name;

 IF project_member is not null then
  begin

   select substr(full_name, 1, 40) into member_name from
   per_people_f where
   person_id = project_member
      and   sysdate between effective_start_date
      and     nvl(effective_end_date,sysdate + 1)
      and (Current_NPW_Flag='Y' OR Current_Employee_Flag='Y')
      and Decode(Current_NPW_Flag,'Y',NPW_Number,employee_number) IS NOT NULL ;
     exception
       when no_data_found then
          null;
       when others then
          /*srw.message(2,'Project Member ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
 END IF;
 c_project_member := member_name;

 IF project_role_type is not null then
   begin
   select substr(meaning,1,40) into role_type
   from pa_project_role_types where
   project_role_type = PA_PAXINGEN_XMLP_PKG.project_role_type;
     exception
       when no_data_found then
           /*srw.message(2,'Role Type ' || sqlerrm);*/null;

          null;
       when others then
          /*srw.message(2,'Role Type ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;
   end;
 END IF;
 c_role_type := role_type;

 IF invoice_status is not null then
  BEGIN
  select
    substr(meaning,1,30) into inv_status
  from
    pa_lookups
  where
    lookup_type = 'INVOICE STATUS'
    and lookup_code = invoice_status;
     exception
       when no_data_found then
          null;
       when others then
          /*srw.message(2,'Invoice Status ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
 END IF;
 c_invoice_status := inv_status;

 /* added for bug 7115649 */
  IF  project_closed_after is not null then
   BEGIN
   select
      TO_CHAR(project_closed_after, 'DD-Mon-RRRR') INTO pca_date
   from
      dual ;
  exception
      when no_data_found then
         null;
       when others then
          /*srw.message(2,'Project closed after ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
 END IF;
 c_pca_date  := pca_date ;

 IF  project_status is not null then
   BEGIN
   select
      project_status_name into prj_status
   from
      pa_proj_statuses_v
   where
      project_status_code = project_status;
  exception
      when no_data_found then
         null;
       when others then
          /*srw.message(2,'Project Status ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;
  end;
 END IF;
 c_project_status := prj_status;
 /* added for bug 7115649 */

 IF project_id is not null then
   begin
   select segment1,name
   into p_number,p_name
   from pa_projects
   where project_id = PA_PAXINGEN_XMLP_PKG.project_id;
     exception
       when no_data_found then
          null;
       when others then
          /*srw.message(2,'Project Number ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;
 END IF;
 c_project_num := p_number;
 c_project_name := p_name;
 IF display_details is not null then
   begin
   select substr(meaning,1,30) into disp_details
   from fnd_lookups
   where
   lookup_type = 'YES_NO'
   and lookup_code = display_details;
     exception
       when no_data_found then
          null;
       when others then
          /*srw.message(2,'Display Details ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;

  END;

 END IF;
 C_display_details := disp_details;
 IF display_unbilled_items is not null then
  begin
   select substr(meaning,1,30) into disp_unbilled
   from fnd_lookups
   where
    lookup_type = 'YES_NO'
   and lookup_code = display_unbilled_items;
     exception
       when no_data_found then
          null;
       when others then
          /*srw.message(2,'Display Unbilled Items ' || sqlerrm);*/null;

            raise_application_error(-20101,null);/*srw.program_abort;*/null;


   end;
 END IF;
 C_display_unbilled := disp_unbilled;
 IF draft_invoice is not null then
    C_draft_invoice := draft_invoice;
 END IF;

 /* Added for bug 7115649 */
IF project_id is null Then
IF from_project_number is null then
  begin
	select min(p.segment1) into from_project_number
	from pa_projects_all p, pa_project_types_all pt
	where p.project_type = pt.project_type
	and pt.project_type_class_code = 'CONTRACT';
  exception
	when no_data_found then
		null;
	when others then
		raise_application_error(-20101,null);
  end;
END IF;


IF to_project_number is null then
  begin
	select max(p.segment1) into to_project_number
	from pa_projects_all p, pa_project_types_all pt
	where p.project_type = pt.project_type
	and pt.project_type_class_code = 'CONTRACT';
  exception
	when no_data_found then
		null;
	when others then
		raise_application_error(-20101,null);
  end;
END IF;
END IF;
/* End of code for bug 7115649 */

IF (get_company_name <> TRUE) THEN        /*srw.message(2,'Company Name   ' || sqlerrm);*/null;

     RAISE init_failure;
  END IF;
IF (project_id is null and
     project_member is null and
      p_start_organization_id is null) THEN
  C_enter := enter_param;
ELSE
  IF  (get_start_org <> TRUE) THEN
      /*srw.message(2,'call org  ' || sqlerrm);*/null;

     RAISE init_failure;
  END IF;
END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    null;
  WHEN   OTHERS  THEN
        /*srw.message(2,' Global  ' || sqlerrm);*/null;
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
  b_res                    boolean:=false;
BEGIN
  begin
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;

  b_res :=true;


 EXCEPTION
   WHEN NO_DATA_FOUND THEN
       /*srw.message(2,'Company Name missing');*/null;

       b_res := false;

  WHEN   OTHERS  THEN
        /*srw.message(2,'Company Name Function ' || sqlerrm);*/null;

        b_res := false;
  end;

    RETURN (b_res);

END;

FUNCTION get_start_org RETURN BOOLEAN IS
  c_start_organization_id number;
  c_project_organization_id number;
  b_res   boolean :=true;
BEGIN

   BEGIN
      select
          decode(p_start_organization_id,null,
          start_organization_id,p_start_organization_id)
          into  C_start_organization_id
      from  pa_implementations;
     exception
      when no_data_found then
               null;
      when others then
          /*srw.message(2,'Fn Get Start Org ID   ' || sqlerrm);*/null;

     b_res := false;
   END;

 IF  project_id is null then

    begin

  insert into
  pa_org_reporting_sessions
  (start_organization_id,session_id)
  values
  (c_start_organization_id,userenv('SESSIONID'));
    exception
    when no_data_found then
           null;
    when others then
     /*srw.message(2,'Fn Get Start Org Id    ' || sqlerrm);*/null;

       b_res := false;
   end;

ELSIF
 project_id is not null then

   begin
      insert into
      pa_org_reporting_sessions
     (start_organization_id,session_id)
      values
      (null,userenv('SESSIONID'));
    exception
     when no_data_found then
           null;
     when others then
           /*srw.message(2,'Get Start Org ID  ' || sqlerrm);*/null;

        b_res := false;
  end;
END IF;
return(b_res);
END;

function G_project_hdrGroupFilter return boolean is
begin

IF (p_start_organization_id is null and
    project_member is null and
    project_id is null) then
       RETURN(FALSE);
ELSE
    return(TRUE);
end if;  return (TRUE);
end;

function g_item_infogroupfilter(invoice_amount in number) return boolean is
begin

If invoice_amount <> 0 then
   return(TRUE);
else
   return(FALSE);
end if;  return (TRUE);
end;

function g_item_detailsgroupfilter(bill_amount in number) return boolean is
begin

If (bill_amount <> 0) then
   return(TRUE);
else
   return(FALSE);
end if;  return (TRUE);
end;

function g_unbilled_detailsgroupfilter(items_unbilled in number) return boolean is
begin

IF (items_unbilled >= 1) then
RETURN(TRUE);
else
return(FALSE);
end if;  return (TRUE);
end;

function g_unbilled_eventsgroupfilter(event_amount_unbilled in number) return boolean is
begin

IF event_amount_unbilled <> 0 then
   RETURN(TRUE);
else
   RETURN(FALSE);
end if;  return (TRUE);
end;

function g_invoicegroupfilter(invoice_amount in number) return boolean is
begin

If invoice_amount <> 0 then
   return(TRUE);
else
   return(FALSE);
end if;  return (TRUE);
end;

function g_unbilled_infogroupfilter(items_unbilled in number, event_amount_unbilled in number) return boolean is
begin

IF (items_unbilled > 0 OR event_amount_unbilled > 0) then
   return(TRUE);
ELSE
   return(FALSE);
END IF;  return (TRUE);
end;

function AfterReport return boolean is
begin

   Begin
    Rollback;
   END;

/*srw.user_exit('FND SRWEXIT') ;*/null;

return (TRUE);
end;

function CF_CURENCY_CODEFormula return VARCHAR2 is
begin
  return pa_multi_currency.get_acct_currency_code;
end;

function cf_cc_proj_labelformula(cc_project_number in varchar2) return char is
begin
  IF cc_project_number IS NOT NULL THEN
            return('Cross Charged Project Number: ');
   ELSE
        return('  ');
  END IF;
end;

function g_retn_invoicegroupfilter(retention_invoice in varchar2) return boolean is
begin
  if ( retention_invoice = 'Yes' ) then
    return (TRUE);
  else
    return (FALSE);
  end if ;
end;

function c_invproc_curr_typeformula(invproc_currency_type in varchar2) return char is
begin
  /*SRW.REFERENCE(invproc_currency_type);*/null;

  return(rtrim(invproc_currency_type));
end;

function c_credit_memo_reasonformula(credit_memo_reason_code in varchar2, invoice_date in date) return char is
l_reason varchar2(80);
begin
  select meaning
  into   l_reason
  from   fnd_lookup_values_vl
  where  lookup_type='CREDIT_MEMO_REASON'
  and    enabled_flag='Y'
  and    lookup_code=credit_memo_reason_code
  and    invoice_date between start_date_active and nvl(end_date_active,invoice_date);
return(l_reason);
exception
when others then
return(null);

end;

function c_ubr_uerformula(unbilled_receivable in number) return number is
begin
  RETURN(ABS(unbilled_receivable));
end;

function CF_PROJECT_CURRENCYFormula(project_id2 number) return VARCHAR2 is
begin
  return pa_multi_currency_txn.get_proj_curr_code_sql(project_id2);
end;

--Functions to refer Oracle report placeholders--

 Function C_ubr_uer_label_p return varchar2 is
	Begin
	 return C_ubr_uer_label;
	 END;
 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_start_org_p return varchar2 is
	Begin
	 return C_start_org;
	 END;
 Function C_project_member_p return varchar2 is
	Begin
	 return C_project_member;
	 END;
 Function C_role_type_p return varchar2 is
	Begin
	 return C_role_type;
	 END;
 Function C_enter_p return varchar2 is
	Begin
	 return C_enter;
	 END;
 Function C_invoice_status_p return varchar2 is
	Begin
	 return C_invoice_status;
	 END;
	 /* added for bug 7115649 */
 Function C_project_status_p return varchar2 is
	Begin
	 return C_project_status;
	 END;
 Function C_pca_date_p return date is
	Begin
	 return C_pca_date;
	 END;
	 /* added for bug 7115649 */
 Function C_project_num_p return varchar2 is
	Begin
	 return C_project_num;
	 END;
 Function C_project_name_p return varchar2 is
	Begin
	 return C_project_name;
	 END;
 Function C_display_details_p return varchar2 is
	Begin
	 return C_display_details;
	 END;
 Function C_display_unbilled_p return varchar2 is
	Begin
	 return C_display_unbilled;
	 END;
 Function C_draft_invoice_p return varchar2 is
	Begin
	 return C_draft_invoice;
	 END;
END PA_PAXINGEN_XMLP_PKG ;



/
