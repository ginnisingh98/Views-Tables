--------------------------------------------------------
--  DDL for Package Body GMS_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_COMMON_PKG" as
/* $Header: gmscomnb.pls 115.5 2002/08/01 09:43:36 gnema ship $ */

  -- ====================================================================
  -- BUG: 1906458 - Project number/name LOV was fixed to make it runnable
  --		    on 11i.PA.E.
  -- ====================================================================
  p_project_template	varchar2(1) := 'A' ;

  PROCEDURE set_project_option( x_template	varchar2) is
  begin
	IF x_template = 'TEMPLATE' THEN
		p_project_template := 'T' ;
	elsif  x_template = 'PROJECT' then
		p_project_template := 'P' ;
	else
		p_project_template := 'A' ;
	end if ;
  END set_project_option ;

  FUNCTION Is_project_template(x_string varchar2)
  return NUMBER IS
  BEGIN
	IF x_string = 'Y' and p_project_template = 'T' THEN
		return 1;
	ELSIF x_string = 'N' and p_project_template = 'P' THEN
		return 1;
	ELSIF p_project_template = 'A' THEN
		return 1;
	END IF ;

	return 0 ;

  END Is_project_template ;

  -- ====================================================================
  -- BUG: 1906458 -  End of fixes.
  -- ====================================================================

  FUNCTION isnumber(X_string varchar2) return char
  is
    lx_num  NUMBER ;
  begin
    lx_num := to_number(X_string) ;
    return 'Y' ;
  exception
    when value_error THEN
        return 'N'  ;
    when others THEN
       RAISE ;
  end isnumber ;

function getmax_award_number return number
is
 l_max_awnum NUMBER ;
BEGIN
 Select max(to_number(award_number))
  into l_max_awnum
  from gms_awards
 where gms_common_pkg.isnumber(award_number) = 'Y' ;

 return ( l_max_awnum) ;
EXCEPTION
 when others then
   RAISE ;
END getmax_award_number ;


end GMS_COMMON_PKG;

/
