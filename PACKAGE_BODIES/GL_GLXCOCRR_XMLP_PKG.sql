--------------------------------------------------------
--  DDL for Package Body GL_GLXCOCRR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXCOCRR_XMLP_PKG" AS
/* $Header: GLXCOCRRB.pls 120.0 2007/12/27 14:51:41 vijranga noship $ */

function from_flexfield_lowformula(FROM_FLEXFIELD_LOW in varchar2) return varchar2 is
begin

/*srw.reference(FROM_CHART_OF_ACCOUNTS_ID);*/null;

/*srw.reference(FROM_FLEXDATA_LOW);*/null;

/*srw.user_exit('FND FLEXRIDVAL CODE="GL#"
               NUM=":FROM_CHART_OF_ACCOUNTS_ID"
               APPL_SHORT_NAME="SQLGL"
               DATA=":FROM_FLEXDATA_LOW"
               VALUE=":FROM_FLEXFIELD_LOW"');*/null;

RETURN(FROM_FLEXFIELD_LOW);

end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function from_flexfield_highformula(FROM_FLEXFIELD_HIGH in varchar2) return varchar2 is
begin

/*srw.reference(FROM_CHART_OF_ACCOUNTS_ID);*/null;

/*srw.reference(FROM_FLEXDATA_HIGH);*/null;

/*srw.user_exit('FND FLEXRIDVAL CODE="GL#"
               NUM=":FROM_CHART_OF_ACCOUNTS_ID"
               APPL_SHORT_NAME="SQLGL"
               DATA=":FROM_FLEXDATA_HIGH"
               VALUE=":FROM_FLEXFIELD_HIGH"');*/null;

RETURN(FROM_FLEXFIELD_HIGH);

end;

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


declare
  to_coa_id       NUMBER;
  from_coa_id     NUMBER;
  coaid           NUMBER;
  start_date      DATE;
  end_date        DATE;
  tmpname        VARCHAR2(100);
  description    VARCHAR2(240);
  errbuf         VARCHAR2(132);
  errbuf2        VARCHAR2(132);
begin

    SELECT average_balances_flag
  INTO   ADB_USED
  FROM   GL_SYSTEM_USAGES;

    gl_get_mapping_info(P_COA_MAPPING_ID, tmpname,
                      from_coa_id,to_coa_id, description,start_date,end_date,
                      errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_coa_mapping_info'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;


  COA_MAP_NAME := tmpname;
  COA_MAP_DESCRIPTION := description;
  TO_CHART_OF_ACCOUNTS_ID := to_coa_id;
  FROM_CHART_OF_ACCOUNTS_ID := from_coa_id;
  FROM_COA_NAME :=B_COA_NAME(FROM_CHART_OF_ACCOUNTS_ID);
  TO_COA_NAME   :=B_COA_NAME(TO_CHART_OF_ACCOUNTS_ID);
  START_DATE    :=start_date;
  END_DATE      :=end_date;
end;
/*srw.reference(TO_CHART_OF_ACCOUNTS_ID);*/null;


 null;


 null;

/*srw.reference(FROM_CHART_OF_ACCOUNTS_ID);*/null;

/*srw.user_exit('FND FLEXRSQL CODE="GL#" NUM=":FROM_CHART_OF_ACCOUNTS_ID"
              APPL_SHORT_NAME="SQLGL"
              OUTPUT=":SELECT_FROM_FLEX" TABLEALIAS="CFM"');*/null;


/*srw.reference(FROM_CHART_OF_ACCOUNTS_ID);*/null;

/*srw.user_exit('FND FLEXRSQL CODE="GL#"
              NUM=":FROM_CHART_OF_ACCOUNTS_ID"
              APPL_SHORT_NAME="SQLGL"
              OUTPUT=":ORDERBY_FROM_FLEX" TABLEALIAS="CFM"');*/null;

  return (TRUE);
end;

procedure gl_get_mapping_info(
                           map_id number, map_name out NOCOPY varchar2,
                           from_coa_id out NOCOPY number, to_coa_id out NOCOPY number,
                           description out NOCOPY varchar2,start_date_active out NOCOPY date,
			   end_date_active out NOCOPY date,
			   errbuf out NOCOPY varchar2) is


CURSOR MAP is
    Select name,from_coa_id, to_coa_id,
           description,start_date_active,end_date_active
    from   gl_coa_mappings
    where  coa_mapping_id = map_id;

begin

OPEN MAP;
FETCH MAP into map_name,
	        from_coa_id,
		to_coa_id,
		description,
		start_date_active,
		end_date_active;

CLOSE MAP;

end;

--function b_coa_name(x_segment number)(x_segment  NUMBER) return varchar is
function b_coa_name(x_segment  NUMBER) return varchar is
CURSOR SEGMENT IS
  SELECT 	ID_FLEX_STRUCTURE_NAME
     FROM 	FND_ID_FLEX_STRUCTURES_V
     WHERE      APPLICATION_ID = 101
       AND      ID_FLEX_CODE = 'GL#'
       AND      ID_FLEX_NUM = x_segment;
recinfo VARCHAR2(30);
BEGIN

OPEN SEGMENT;
FETCH SEGMENT INTO recinfo;
CLOSE SEGMENT;
RETURN(recinfo);

END;

--Functions to refer Oracle report placeholders--

 Function TO_CHART_OF_ACCOUNTS_ID_p return varchar2 is
	Begin
	 return TO_CHART_OF_ACCOUNTS_ID;
	 END;
 Function SELECT_FROM_FLEX_LOW_p return varchar2 is
	Begin
	 return SELECT_FROM_FLEX_LOW;
	 END;
 Function ORDERBY_FROM_FLEX_LOW_p return varchar2 is
	Begin
	 return ORDERBY_FROM_FLEX_LOW;
	 END;
 Function SELECT_TO_FLEX_p return varchar2 is
	Begin
	 return SELECT_TO_FLEX;
	 END;
 Function ORDERBY_TO_FLEX_p return varchar2 is
	Begin
	 return ORDERBY_TO_FLEX;
	 END;
 Function FROM_CHART_OF_ACCOUNTS_ID_p return varchar2 is
	Begin
	 return FROM_CHART_OF_ACCOUNTS_ID;
	 END;
 Function COA_MAP_NAME_p return varchar2 is
	Begin
	 return COA_MAP_NAME;
	 END;
 Function COA_MAP_DESCRIPTION_p return varchar2 is
	Begin
	 return COA_MAP_DESCRIPTION;
	 END;
 Function START_DATE_p return date is
	Begin
	 return START_DATE;
	 END;
 Function END_DATE_p return date is
	Begin
	 return END_DATE;
	 END;
 Function SELECT_FROM_FLEX_HIGH_p return varchar2 is
	Begin
	 return SELECT_FROM_FLEX_HIGH;
	 END;
 Function ORDERBY_FROM_FLEX_HIGH_p return varchar2 is
	Begin
	 return ORDERBY_FROM_FLEX_HIGH;
	 END;
 Function ADB_USED_p return varchar2 is
	Begin
	 return ADB_USED;
	 END;
 Function TO_COA_NAME_p return varchar2 is
	Begin
	 return TO_COA_NAME;
	 END;
 Function FROM_COA_NAME_p return varchar2 is
	Begin
	 return FROM_COA_NAME;
	 END;
END GL_GLXCOCRR_XMLP_PKG ;



/
