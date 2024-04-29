--------------------------------------------------------
--  DDL for Package Body PA_PAXRWIMP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWIMP_XMLP_PKG" AS
/* $Header: PAXRWIMPB.pls 120.0 2008/01/02 11:58:07 krreddy noship $ */

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function BeforeReport return boolean is
begin


declare
init_error exception;
begin

 /*srw.user_exit('FND SRWINIT');*/null;


if ( get_company_name <> TRUE ) then
  raise init_error;
end if;
end;

/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;





/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;





return (TRUE);
end;

function get_meaning (type in VARCHAR2,code in VARCHAR2) return VARCHAR2 is
v_meaning     varchar2(80);
cursor c is
select meaning
from pa_lookups
where lookup_type = type
and   lookup_code = code;
begin
  open c;
  fetch c into v_meaning;
  close c;
  return v_meaning;

exception
  when others then
    return null;
end;

function c_descformula(glpa_type in varchar2) return varchar2 is
begin

return(get_meaning('ACCUMULATION PERIOD TYPE',glpa_type));
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_overtime_flagformula(overtime_flag in varchar2) return varchar2 is
tmp_over_flag VARCHAR2(80);
begin
IF overtime_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = overtime_flag ;
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_iflabortoglformula(Iflabortogl in varchar2) return varchar2 is
tmp_labortogl VARCHAR2(80);
begin
IF Iflabortogl IS NOT NULL THEN
	SELECT meaning INTO tmp_labortogl
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = Iflabortogl ;
	RETURN tmp_labortogl;
ELSE
 RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_ifrevtoglformula(Ifrevenuetogl in varchar2) return varchar2 is
tmp_ifrevtogl VARCHAR2(80);
begin
IF Ifrevenuetogl IS NOT NULL THEN
	SELECT meaning INTO tmp_ifrevtogl
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = ifrevenuetogl ;
	RETURN tmp_ifrevtogl;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_ifusgtoglformula(ifusagetogl in varchar2) return varchar2 is
tmp_ifusgtogl VARCHAR2(80);
begin
IF ifusagetogl IS NOT NULL THEN
	SELECT meaning INTO tmp_ifusgtogl
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = ifusagetogl ;
	RETURN tmp_ifusgtogl;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_cen_inv_collformula(centralized_invoicing_flag in varchar2) return varchar2 is
tmp_ceninvcoll VARCHAR2(80);
begin
IF centralized_invoicing_flag IS NOT NULL THEN
	SELECT meaning INTO tmp_ceninvcoll
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code =
	centralized_invoicing_flag ;
	RETURN tmp_ceninvcoll;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_ifretnaccformul(Ifretnacc in varchar2) return varchar2 is
tmp_ifretnacc VARCHAR2(80);
begin
IF Ifretnacc IS NOT NULL THEN
	SELECT meaning INTO tmp_ifretnacc
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = ifretnacc ;
	RETURN tmp_ifretnacc;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_mrc_for_fundformula(mrc_for_fund in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF mrc_for_fund IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO'
        AND    lookup_code = DECODE(mrc_for_fund,'U','Y', mrc_for_fund);
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_reval_mrc_fundformula(reval_mrc_fund in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF reval_mrc_fund IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO'
        AND    lookup_code = DECODE(reval_mrc_fund,'U','Y', reval_mrc_fund);
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_mrc_for_finplanformula(mrc_for_finplan in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF mrc_for_finplan IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO'
        AND    lookup_code = DECODE(mrc_for_finplan,'U','Y', mrc_for_finplan) ;
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_ingainlossformula(ingainloss in varchar2) return char is
tmp_over_flag VARCHAR2(80);
begin
IF ingainloss IS NOT NULL THEN
	SELECT meaning INTO tmp_over_flag
	FROM   fnd_lookups
	WHERE  lookup_type = 'YES_NO' AND lookup_code = ingainloss ;
	RETURN tmp_over_flag;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function cf_exch_rate_typeformula(exch_rate_type in varchar2) return char is
tmp_exchrate VARCHAR2(80);
begin
IF exch_rate_type IS NOT NULL THEN
        SELECT user_conversion_type INTO tmp_exchrate
        FROM   pa_conversion_types_v
        WHERE  conversion_type = exch_rate_type;
	RETURN tmp_exchrate;
ELSE
  RETURN NULL;
END IF;
EXCEPTION
  WHEN OTHERS THEN
     RAISE;
end;

function  cf_customer_relationformula(cust_acc_rel_code in varchar2) return char is
   tmp_over_flag VARCHAR2(80);

begin
   IF cust_acc_rel_code IS NOT NULL THEN
      SELECT meaning INTO tmp_over_flag
        FROM  pa_lookups
       WHERE  lookup_type = 'PA_CUST_ACC_REL_CODE'
         AND  lookup_code = cust_acc_rel_code;

    RETURN tmp_over_flag;

    ELSE
      RETURN NULL;
    END IF;
EXCEPTION
   WHEN OTHERS THEN
      RAISE;
end;



function cf_credit_memoformula(credit_memo_reason_flag in varchar2) return char is
   temp fnd_lookups.meaning%TYPE;
begin
   IF credit_memo_reason_flag IS NOT NULL THEN
      SELECT meaning
        INTO temp
        FROM fnd_lookups
       WHERE lookup_type = 'YES_NO'
         AND lookup_code = credit_memo_reason_flag;
   END IF;

   RETURN temp;

end;

function AfterReport return boolean is
begin

  /*srw.user_exit('FND SRWEXIT') ;*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_Company_Name_Header_p return varchar2 is
	Begin
	 return C_Company_Name_Header;
	 END;
END PA_PAXRWIMP_XMLP_PKG ;


/
