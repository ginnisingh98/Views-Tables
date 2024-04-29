--------------------------------------------------------
--  DDL for Package Body PA_PARLBLDG_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PARLBLDG_XMLP_PKG" AS
/* $Header: PARLBLDGB.pls 120.0 2008/01/02 11:03:48 krreddy noship $ */

function AfterReport return boolean is
begin
  /*SRW.USER_EXIT('FND SRWEXIT');*/null;

  return (TRUE);

end;

function BeforeReport return boolean is
 x_status       VARCHAR2(1);
 x_count        NUMBER;
 x_data         VARCHAR2(2000);
 l_name         VARCHAR2(100);
 l_date          DATE;
begin

/*srw.user_exit('FND SRWINIT');*/null;


/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;








/*srw.user_exit('FND GETPROFILE
NAME="CURRENCY:MIXED_PRECISION"
FIELD=":p_min_precision"
PRINT_ERROR="N"');*/null;



IF (p_start_resource_name IS NULL ) THEN
   SELECT MIN(name)
   INTO p_start_resource_name
   FROM pa_resources;
END IF;

IF (p_end_resource_name IS NULL ) THEN
   SELECT MAX(name)
   INTO p_end_resource_name
   FROM pa_resources;
END IF;
BEGIN
    SELECT SYSDATE
    INTO l_date
    FROM dual;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
       /*SRW.MESSAGE(100,' OTHER PROBLEM IN SELECTING THE SYSDATE '||SQLERRM);*/null;

       NULL;
END;
/*srw.message(100,'res_nam1 '||p_start_resource_name);*/null;

/*srw.message(100,'res_nam2 '||p_end_resource_name);*/null;

/*srw.message(100,'res_id '||to_number(p_resource_id));*/null;


 IF (UPPER(p_run_mode) = 'R') THEN
    PA_TIMELINE_PVT.create_timeline(
                          p_start_resource_name => p_start_resource_name,
                          p_end_resource_name   => p_end_resource_name,
                          p_resource_id         => NULL,
                          p_start_date          => l_date,
                          p_end_date            => NULL,
                          x_return_status       => x_status,
                          x_msg_count           => x_count,
                          x_msg_data            => x_data);


 ELSIF (UPPER(p_run_mode) = 'S' ) THEN
   SELECT name
   INTO l_name
   FROM pa_resources
   WHERE resource_id = p_resource_id;
   p_start_resource_name := l_name;
   p_end_resource_name   := l_name;

    PA_TIMELINE_PVT.create_timeline(
                          p_start_resource_name => NULL,
                          p_end_resource_name   => NULL,
                          p_resource_id         => p_resource_id,
                          p_start_date          => l_date,
                          p_end_date            => NULL,
                          x_return_status       => x_status,
                          x_msg_count           => x_count,
                          x_msg_data            => x_data);
 END IF;
p_start_resource_name_dummy:=p_start_resource_name;
p_end_resource_name_dummy:=p_end_resource_name;
   return(TRUE);
EXCEPTION
  WHEN OTHERS THEN
   /*SRW.MESSAGE(1111,' DATA IS NOT IN THE TABLE'||sqlerrm);*/null;

    Raise;
return (TRUE);
end;

function CP_company_nameFormula return Char is
   v_company_name  gl_sets_of_books.name%type;

begin

  select glb.name into v_company_name
  from gl_sets_of_books glb, pa_implementations pi
  where glb.set_of_books_id=pi.set_of_books_id;

  cp_company_name:=v_company_name;
   return  cp_company_name;
end;

--Functions to refer Oracle report placeholders--

 Function CP_company_name_p return varchar2 is
	Begin
	 return CP_company_name;
	 END;
 Function CP_NODATAFOUND_p return varchar2 is
	Begin
	 return CP_NODATAFOUND;
	 END;
END PA_PARLBLDG_XMLP_PKG ;


/
