--------------------------------------------------------
--  DDL for Package Body PO_POXVCVAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXVCVAR_XMLP_PKG" AS
/* $Header: POXVCVARB.pls 120.1 2007/12/25 12:38:02 krreddy noship $ */

function BeforeReport return boolean is
begin

DECLARE
      	x_assignment_set_id  VARCHAR2(240) := '';
	x_organization_code  VARCHAR2(240) := '';
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;


 null;


 null;





  fnd_profile.get('MRP_DEFAULT_ASSIGNMENT_SET',
	x_assignment_set_id);
  IF (x_assignment_set_id IS NULL) THEN
	begin
	P_ASSIGNMENT_SET_ID := -1;
	P_ASSIGNMENT_SET_ID_Qry:= -1;
	end;
  ELSE
  begin
	P_ASSIGNMENT_SET_ID :=
		to_number(x_assignment_set_id);
  P_ASSIGNMENT_SET_ID_Qry:=P_ASSIGNMENT_SET_ID;
	end;
  END IF;



    select organization_code
    into   x_organization_code
    from   mtl_parameters
    where  organization_id = P_ORGANIZATION_ID;

    CP_ORGANIZATION_CODE := x_organization_code;


  RETURN TRUE;
EXCEPTION
   when no_data_found then null;
   when others then
	/*srw.message('50', 'Exception from BEFOREREPORT: '||sqlerrm);*/null;

END;
  return (TRUE);
end;

function P_titleValidTrigger return boolean is
begin

		  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function get_actual(Expenditure_total in number, C_vendor_total in number) return number is
actual number;
begin
  if Expenditure_total <> 0          then
     actual := C_vendor_total/Expenditure_Total*100;
  else
     actual := 0;
  end if;
  return (actual);
RETURN NULL; exception
  when others then
    /*srw.message('010','Error error error');*/null;

    raise_application_error(-20101,null);/*srw.context_failure;*/null;

end;

function c_intendedformula(Split in number, Expenditure_Total in number) return number is
begin

 return ((Split/100)*Expenditure_Total);
end;

--Functions to refer Oracle report placeholders--

END PO_POXVCVAR_XMLP_PKG ;


/
