--------------------------------------------------------
--  DDL for Package Body AR_RAXNCAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXNCAR_XMLP_PKG" AS
/* $Header: RAXNCARB.pls 120.0 2007/12/27 14:31:08 abraghun noship $ */

function report_nameformula(Company_Name in varchar2) return varchar2 is
begin

DECLARE
    l_report_name  VARCHAR2(80);
BEGIN
    RP_Company_Name := Company_Name;

    SELECT cp.user_concurrent_program_name
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE  cr.request_id = P_CONC_REQUEST_ID
    AND    cp.application_id = cr.program_application_id
    AND    cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_Name := l_report_name;
    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := NULL;
         RETURN(NULL);
END;
RETURN NULL; end;

function BeforeReport return boolean is
begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*SRW.USER_EXIT('FND SRWINIT');*/null;


declare

	yes		VARCHAR2(80);
	no		VARCHAR2(80);
	cm_foot		VARCHAR2(80);
	dep_foot	VARCHAR2(80);
	inv_foot	VARCHAR2(80);
	guar_foot	VARCHAR2(80);
	arra_min	VARCHAR2(11);
	arra_max	VARCHAR2(11);
	adjs_min	VARCHAR2(11);
	adjs_max	VARCHAR2(11);
	min_date	VARCHAR2(11);
	max_date	VARCHAR2(11);
	sql_start_date	VARCHAR2(11);
	sql_end_date	VARCHAR2(11);
begin

SELECT
        INITCAP(YES.MEANING)                            yes,
        INITCAP(NO.MEANING)                             no,
        CM.MEANING                                      cm_foot,
        DEP.MEANING                                     dep_foot,
        GUAR.MEANING                                    guar_foot,
        INV.MEANING                                     inv_foot
INTO
 	yes,
        no,
        cm_foot,
        dep_foot,
        guar_foot,
        inv_foot
FROM
        AR_LOOKUPS                      YES,
        AR_LOOKUPS                      NO,
        AR_LOOKUPS                      CM,
        AR_LOOKUPS                      DEP,
        AR_LOOKUPS                      GUAR,
        AR_LOOKUPS                      INV
WHERE
        YES.LOOKUP_TYPE = 'YES/NO'                              AND
        YES.LOOKUP_CODE = 'Y'
AND
        NO.LOOKUP_TYPE = 'YES/NO'                               AND
        NO.LOOKUP_CODE = 'N'
AND
        CM.LOOKUP_TYPE = 'INV/CM'                               AND
        CM.LOOKUP_CODE = 'CM'
AND
        DEP.LOOKUP_TYPE = 'INV/CM'                              AND
        DEP.LOOKUP_CODE = 'DEP'
AND
        GUAR.LOOKUP_TYPE = 'INV/CM'                             AND
        GUAR.LOOKUP_CODE = 'GUAR'
AND
        INV.LOOKUP_TYPE = 'INV/CM'                              AND
        INV.LOOKUP_CODE = 'INV';

 	    AR_RAXNCAR_XMLP_PKG.yes := yes;
        AR_RAXNCAR_XMLP_PKG.no   := no;
        AR_RAXNCAR_XMLP_PKG.cm_foot := cm_foot;
        AR_RAXNCAR_XMLP_PKG.dep_foot := dep_foot;
        AR_RAXNCAR_XMLP_PKG.guar_foot := guar_foot;
        AR_RAXNCAR_XMLP_PKG.inv_foot := inv_foot;



SELECT TO_CHAR(MIN(GL_DATE), 'DD-MON-YYYY')             arra_min,
       TO_CHAR(MAX(GL_DATE), 'DD-MON-YYYY')             arra_max
INTO	arra_min,
	arra_max
FROM   AR_RECEIVABLE_APPLICATIONS;

	AR_RAXNCAR_XMLP_PKG.arra_min := arra_min;
	AR_RAXNCAR_XMLP_PKG.arra_max := arra_max;

SELECT TO_CHAR(MIN(GL_DATE), 'DD-MON-YYYY')             adjs_min,
       TO_CHAR(MAX(GL_DATE), 'DD-MON-YYYY')             adjs_max
INTO	adjs_min,
	adjs_max
FROM   AR_ADJUSTMENTS;

	AR_RAXNCAR_XMLP_PKG.adjs_min := adjs_min;
	AR_RAXNCAR_XMLP_PKG.adjs_max := adjs_max;

SELECT TO_CHAR(LEAST(TO_DATE(arra_min, 'DD-MM-YYYY'), TO_DATE(adjs_min, 'DD-MM-YYYY')),'DD-MM-YYYY')                                   min_date,
       TO_CHAR(GREATEST(TO_DATE(arra_max, 'DD-MM-YYYY'),TO_DATE(adjs_max, 'DD-MM-YYYY')),'DD-MM-YYYY')                          max_date
INTO
	min_date,
	max_date
FROM   DUAL;

	AR_RAXNCAR_XMLP_PKG.min_date := min_date;
	AR_RAXNCAR_XMLP_PKG.max_date := max_date;

SELECT DECODE(TO_CHAR(p_start_gl_date, 'DD-MON-YYYY'),
              NULL, min_date,
              TO_CHAR(p_start_gl_date, 'DD-MON-YYYY'))                 sql_start_date,
       DECODE(TO_CHAR(p_end_gl_date, 'DD-MON-YYYY'),
              NULL, max_date,
              TO_CHAR(p_end_gl_date, 'DD-MON-YYYY'))                   sql_end_date
INTO
	sql_start_date,
	sql_end_date
FROM   DUAL;

	AR_RAXNCAR_XMLP_PKG.sql_start_date := sql_start_date;
	AR_RAXNCAR_XMLP_PKG.sql_end_date 	:= sql_end_date;

end;


  return (TRUE);
end;

function Sub_TitleFormula return VARCHAR2 is
begin

begin
rp_sub_title := ARP_STANDARD.FND_MESSAGE
                 ('AR_REPORTS_GL_DATE_FROM_TO',
                  'FROM_DATE',nvl(TO_CHAR(p_start_gl_date, 'DD-MON-YYYY'),'     '),
                  'TO_DATE',nvl(TO_CHAR(p_end_gl_date, 'DD-MON-YYYY'),'     '));
return(RP_SUB_TITLE);
end;

RETURN NULL; end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return substr(RP_REPORT_NAME,1,instr(RP_REPORT_NAME,' (XML)'));
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function RP_SUB_TITLE_p return varchar2 is
	Begin
	 return RP_SUB_TITLE;
	 END;
 Function Cm_foot_p return varchar2 is
	Begin
	 return Cm_foot;
	 END;
 Function Dep_Foot_p return varchar2 is
	Begin
	 return Dep_Foot;
	 END;
 Function Guar_foot_p return varchar2 is
	Begin
	 return Guar_foot;
	 END;
 Function Inv_foot_p return varchar2 is
	Begin
	 return Inv_foot;
	 END;
 Function Yes_p return varchar2 is
	Begin
	 return Yes;
	 END;
 Function No_p return varchar2 is
	Begin
	 return No;
	 END;
 Function Arra_Min_p return varchar2 is
	Begin
	 return Arra_Min;
	 END;
 Function Arra_Max_p return varchar2 is
	Begin
	 return Arra_Max;
	 END;
 Function Adjs_Min_p return varchar2 is
	Begin
	 return Adjs_Min;
	 END;
 Function Adjs_Max_p return varchar2 is
	Begin
	 return Adjs_Max;
	 END;
 Function Min_Date_p return varchar2 is
	Begin
	 return Min_Date;
	 END;
 Function Max_Date_p return varchar2 is
	Begin
	 return Max_Date;
	 END;
 Function Sql_Start_Date_p return varchar2 is
	Begin
	 return Sql_Start_Date;
	 END;
 Function Sql_End_Date_p return varchar2 is
	Begin
	 return Sql_End_Date;
	 END;
 Function GSum_Tran_Foreign_Dsp_p return varchar2 is
	Begin
	 return GSum_Tran_Foreign_Dsp;
	 END;
 Function GSum_Tran_Funct_Dsp_p return varchar2 is
	Begin
	 return GSum_Tran_Funct_Dsp;
	 END;
 function D_Tran_ForeignFormula return VARCHAR2 is
	begin
	RP_DATA_FOUND:='X';
	return null;
	end;
END AR_RAXNCAR_XMLP_PKG ;



/
