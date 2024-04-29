--------------------------------------------------------
--  DDL for Package Body GL_GLXRLCOA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLCOA_XMLP_PKG" AS
/* $Header: GLXRLCOAB.pls 120.0 2007/12/27 15:12:25 vijranga noship $ */

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


/*srw.reference( P_STRUCT_NUM );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;

/*srw.reference( P_ORDERBY_SEG );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;

/*srw.reference( P_FLEX_HIGH );*/null;

/*srw.reference( P_FLEX_LOW );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;


 null;

/*srw.reference( P_STRUCT_NUM );*/null;

/*srw.reference( P_ORDERBY_SEG );*/null;


 null;

return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function FLEX_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_SELECT_ALL;
	 END;
 Function FLEX_SELECT_BAL_p return varchar2 is
	Begin
	 return FLEX_SELECT_BAL;
	 END;
 Function FLEX_SELECT_SEG_p return varchar2 is
	Begin
	 return FLEX_SELECT_SEG;
	 END;
 Function FLEX_ORDERBY_ALL_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_ALL;
	 END;
 Function FLEX_ORDERBY_BAL_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_BAL;
	 END;
 Function FLEX_ORDERBY_SEG_p return varchar2 is
	Begin
	 return FLEX_ORDERBY_SEG;
	 END;
 Function FLEX_WHERE_ALL_p return varchar2 is
	Begin
	 return FLEX_WHERE_ALL;
	 END;
 Function FLEX_NODATA_SELECT_ALL_p return varchar2 is
	Begin
	 return FLEX_NODATA_SELECT_ALL;
	 END;
END GL_GLXRLCOA_XMLP_PKG ;


/
