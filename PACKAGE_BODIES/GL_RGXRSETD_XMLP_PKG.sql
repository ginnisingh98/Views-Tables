--------------------------------------------------------
--  DDL for Package Body GL_RGXRSETD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RGXRSETD_XMLP_PKG" AS
/* $Header: RGXRSETDB.pls 120.0 2007/12/27 15:42:07 vijranga noship $ */

function BeforeReport return boolean is
begin

  DECLARE
   COA_ID    NUMBER;
   FUNC_CURR VARCHAR2(15);
  BEGIN
    /*SRW.USER_EXIT('FND SRWINIT');*/null;


    IF P_ACCESS_SET_ID IS NULL THEN
       NULL;
    ELSE

      SELECT chart_of_accounts_id INTO COA_ID
      FROM gl_access_sets WHERE access_set_id = P_ACCESS_SET_ID;

      C_STRUCTURE_ID := COA_ID;
    END IF;

    C_ID_FLEX_CODE := 'GLLE';



    /*SRW.USER_EXIT('FND GETPROFILE
                    INDUSTRY :C_INDUSTRY_TYPE');*/null;


    IF C_INDUSTRY_TYPE = 'G' THEN


       /*SRW.USER_EXIT('FND GETPROFILE
                    ATTRIBUTE_REPORTING :C_ATTRIBUTE_FLAG');*/null;


       IF ( C_ATTRIBUTE_FLAG = 'Y' ) THEN
         C_ID_FLEX_CODE := 'GLAT' ;
       END IF;

     END IF;

  END;
  P_DELIMITER := fnd_flex_ext.get_delimiter('SQLGL','GLLE',C_STRUCTURE_ID);
  return (TRUE);
end;

function AfterReport return boolean is
begin

BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

--function f_override_segment(segment varchar)(segment  varchar) return varchar is
function f_override_segment(segment varchar) return varchar is
CURSOR C is
select short_name
		 from 	gl_ledgers
		where 	gl_ledgers.ledger_id (+) = to_number(substr(segment,0, instr(segment,P_DELIMITER,1,1) -1) );

recinfo varchar2(240);
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
     CLOSE C;
return( Recinfo||substr (segment, instr(segment,P_DELIMITER,1,1), length(segment) ));
END;

function c_segment_overrideformula(segment_override1 in varchar2) return char is
begin
    return(F_OVERRIDE_SEGMENT(segment_override1));
end;

--Functions to refer Oracle report placeholders--

 Function C_ID_FLEX_CODE_p return varchar2 is
	Begin
	 return C_ID_FLEX_CODE;
	 END;
 Function C_STRUCTURE_ID_p return number is
	Begin
	 return C_STRUCTURE_ID;
	 END;
 Function C_INDUSTRY_TYPE_p return varchar2 is
	Begin
	 return C_INDUSTRY_TYPE;
	 END;
 Function C_ATTRIBUTE_FLAG_p return varchar2 is
	Begin
	 return C_ATTRIBUTE_FLAG;
	 END;
END GL_RGXRSETD_XMLP_PKG ;


/
