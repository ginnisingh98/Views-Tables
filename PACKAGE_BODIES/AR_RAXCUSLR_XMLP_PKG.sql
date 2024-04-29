--------------------------------------------------------
--  DDL for Package Body AR_RAXCUSLR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_RAXCUSLR_XMLP_PKG" AS
/* $Header: RAXCUSLRB.pls 120.0 2007/12/27 14:17:44 abraghun noship $ */

function AfterPForm return boolean is
begin

begin

if lcn is not null then
	lp_lcn := ' AND RACU.ACCOUNT_NUMBER >= :lcn ';
else
        LP_LCN := ' ';
end if;

if hcn is not null then
	lp_hcn := ' AND RACU.ACCOUNT_NUMBER <= :hcn ';
else
        LP_HCN := ' ';
end if;

if p_customer_name_low is not null then
	lp_customer_low  := ' AND PARTY.PARTY_NAME >= :p_customer_name_low ';
 else
        LP_CUSTOMER_LOW := ' ';
end if;

if p_customer_name_high is not null then
	lp_customer_high  := ' AND PARTY.PARTY_NAME <= :p_customer_name_high ';
else
        LP_CUSTOMER_HIGH := ' ';
end if;


end;  return (TRUE);
end;

function BeforeReport return boolean is
begin

     /*srw.message ('100', 'BeforeReport Trigger +');*/null;


     /*SRW.USER_EXIT('FND SRWINIT');*/null;


     Get_Customer_Segment;
     Setup_Automotive_Requirements;
     Get_Company_Name;
     Get_Report_Name;

     get_boiler_plates;

     /*srw.message ('100', 'BeforeReport Trigger -');*/null;


     return (TRUE);

end;

PROCEDURE Get_Customer_Segment IS
     BEGIN

        /*  srw.message ('100', 'BeforeReport_Procs.Get_Customer_Segment');*/

         /* srw.user_exit('FND FLEXSQL
                         CODE="CT#"
                         APPL_SHORT_NAME="AR"
                         TABLEALIAS="RATT"
                         OUTPUT=":TERR_FLEX_ALL_SEG"
                         MODE="SELECT"
                         DISPLAY="ALL"');*/

          null;
     EXCEPTION
          WHEN NO_DATA_FOUND THEN
              /* srw.message ('101', 'BeforeReport_Procs.Get_Customer_Segment:  Segment Not Found');*/
               /*RAISE;*/
	       null;
          WHEN OTHERS THEN
              /* srw.message ('101', 'BeforeReport_Procs.Get_Customer_Segment:  Segment Failed.');*/
              /* RAISE; */
	      null;

     END;


     /*
      --------------------------------------------------------------------------
     |  Procedure:      Setup_Automotive_Requirements                           |
     |                                                                          |
     |  Functionality:  Setup various report parameters if the Automotive       |
     |                  product has been installed on the customer's site.      |
      --------------------------------------------------------------------------
     */

     PROCEDURE Setup_Automotive_Requirements IS
     BEGIN

         /* srw.message ('100', 'BeforeReport_Procs.Setup_Automotive_Requirements');*/

         /* srw.user_exit('FND INSTALLATION OUTPUT_TYPE="STATUS"
                         OUTPUT_FIELD=":P_veh_install_status"
                         APPS="VEH"') ;*/

          IF P_veh_install_status = 'I' THEN

               /* Automotive Specific solution */

              /* srw.message ('100', 'BeforeReport_Procs.Setup_Automotive_Requirements:  Automotive Installed');*/

               P_veh_install_status := 'Y';
               P_veh_select_column1 := 'TPD.TRANSLATOR_CODE';
               P_veh_select_column2 := 'RAAD.ECE_TP_LOCATION_CODE';
               P_veh_from_table     := 'ECE_TP_DETAILS TPD, ECE_TP_HEADERS TPH, ';
               P_veh_where_clause1  := 'TPD.TP_HEADER_ID(+)';
               P_veh_where_clause2  := 'TPH.TP_HEADER_ID(+)';
          END IF;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
               /*srw.message ('101', 'BeforeReport_Procs.Setup_Automotive_Requirements:  Automotive Not Found');*/
              /* RAISE; */
	      null;
          WHEN OTHERS THEN
              /* srw.message ('101', 'BeforeReport_Procs.Setup_Automotive_Requirements:  Automotive Failed.'); */
              /* RAISE; */
	      null;
     END;


     /*
      --------------------------------------------------------------------------
     |  Procedure:      Get_Company_Name                                        |
     |                                                                          |
     |  Functionality:  The Company Name is displayed within the header of each |
     |                  page within the report.                                 |
      --------------------------------------------------------------------------
     */

     PROCEDURE Get_Company_Name IS
     l_sob_id          NUMBER(15);
     l_company_name    VARCHAR2(30);
     BEGIN

          /*srw.message ('100', 'BeforeReport_Procs.Get_Company_Name');*/

          SELECT sob.name
          INTO   L_Company_Name
          FROM   gl_sets_of_books sob,
                 ar_system_parameters ar
          WHERE  sob.set_of_books_id  = ar.set_of_books_id;

	  /*srw.message ('100', 'L_Company_Name = ' || L_Company_Name); */

         RP_Company_Name := L_Company_Name;


         SELECT set_of_books_id
         INTO   l_sob_id
         FROM   ar_system_parameters;

	/* srw.message ('100', 'l_sob_id = ' || l_sob_id);*/

/*
         :RP_Company_Name := 'US Operations';
*/

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
              /* srw.message ('101', 'BeforeReport_Procs.Get_Company_Name:  SOB Not Found.');
               srw.message ('101', 'BeforeReport_Procs.Get_Company_Name:  Company Name Not Found.');

               RAISE;*/
	       null;

          WHEN OTHERS THEN
              /* srw.message ('101', 'BeforeReport_Procs.Get_Company_Name:  Company Name Failed.');
               RAISE;*/
	       null;
     END;


     /*
      --------------------------------------------------------------------------
     |  Procedure:      Get_Report_Name                                         |
     |                                                                          |
     |  Functionality:  The report name is displayed within the header of each  |
     |                  page within the report.                                 |
      --------------------------------------------------------------------------
     */

     PROCEDURE Get_Report_Name IS
     l_report_name     VARCHAR2(240);
     BEGIN

         /* srw.message ('100', 'BeforeReport_Procs.Get_Report_Name'); */

          SELECT cp.user_concurrent_program_name
          INTO   l_report_name
          FROM   FND_CONCURRENT_PROGRAMS_VL cp,
                 FND_CONCURRENT_REQUESTS cr
          WHERE  cr.request_id = P_CONC_REQUEST_ID
          AND    cp.application_id = cr.program_application_id
          AND    cp.concurrent_program_id = cr.concurrent_program_id;

          RP_Report_Name := l_report_name;

     EXCEPTION
          WHEN NO_DATA_FOUND THEN
             /*  srw.message ('101', 'BeforeReport_Procs.Get_Report_Name:  Name not found');*/
               RP_REPORT_NAME := '';
          WHEN OTHERS THEN
              /* srw.message ('101', 'BeforeReport_Procs.Get_Report_Name:  Company Name Failed.');
               RAISE;*/
	       null;
     END;



function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function ITEM_FLEX_STRUCTUREFormula return VARCHAR2 is
  l_item_flex VARCHAR2(50);
begin



  oe_profile.get('SO_ORGANIZATION_ID', l_item_flex );

  RETURN(l_item_flex) ;
end;

function Set_DataFormula return VARCHAR2 is
begin

begin
RP_DATA_FOUND := 'X';
return('X');
end;

RETURN NULL; end;

procedure get_lookup_meaning(p_lookup_type	in varchar2,
			     p_lookup_code	in varchar2,
			     p_lookup_meaning  	in out nocopy varchar2) is
w_meaning varchar2(80);

begin

select meaning
  into w_meaning
  from fnd_lookups
 where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code ;

p_lookup_meaning := w_meaning ;

exception
   when no_data_found then
        		p_lookup_meaning := null ;

end ;

procedure get_boiler_plates is

w_industry_code varchar2(20);
w_industry_stat varchar2(20);

begin

/*srw.message ('100', 'Get_Boiler_Plates');*/null;


if fnd_installation.get(0, 0,
                        w_industry_stat,
	    	        w_industry_code) then
   if w_industry_code = 'C' then
      c_sales_title := null ;
   else
      get_lookup_meaning('IND_SALES',
                       	 w_industry_code,
			 c_sales_title);
      get_lookup_meaning('IND_SALES_TERRITORY',
                       	 w_industry_code,
			 c_salester_title);
      get_lookup_meaning('IND_SALES_REP',
                       	 w_industry_code,
			 c_salesrep_title);

   end if;
end if;

c_industry_code :=   w_Industry_code ;

end ;

function set_display_for_core(p_field_name in varchar2) return boolean is

begin

if c_industry_code = 'C' then
   return(TRUE);
elsif p_field_name = 'SALES' then
   if c_sales_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
elsif p_field_name = 'SALESREP' then
   if c_salesrep_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
elsif p_field_name = 'SALESTER' then
   if c_salester_title is not null then
      return(FALSE);
   else
      return(TRUE);
   end if;
end if;

RETURN NULL; end;

function set_display_for_gov(p_field_name in varchar2) return boolean is

begin


if c_industry_code = 'C' then
   return(FALSE);
elsif p_field_name = 'SALES' then
   if c_sales_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
elsif p_field_name = 'SALESREP' then
   if c_salesrep_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
elsif p_field_name = 'SALESTER' then
   if c_salester_title is not null then
      return(TRUE);
   else
      return(FALSE);
   end if;
end if;

RETURN NULL; end ;

function c_veh_tp_designatorformula(TRANSLATOR_CODE in varchar2) return varchar2 is
begin

/*SRW.REFERENCE(TRANSLATOR_CODE);*/null;

RETURN(TRANSLATOR_CODE);
end;

function G_CU_ADDRESSGroupFilter return boolean is
begin


  return (TRUE);
end;

function CF_ORDER_BYFormula return Char is
begin

return(ARPT_SQL_FUNC_UTIL.get_lookup_meaning('SORT_BY_RAXCUSLR',p_order_by));


end;

--Functions to refer Oracle report placeholders--

 Function RP_COMPANY_NAME_p return varchar2 is
	Begin
	 return RP_COMPANY_NAME;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
 Function RP_DATA_FOUND_p return varchar2 is
	Begin
	 return RP_DATA_FOUND;
	 END;
 Function TERR_FLEX_ALL_SEG_p return varchar2 is
	Begin
	 return TERR_FLEX_ALL_SEG;
	 END;
 Function c_industry_code_p return varchar2 is
	Begin
	 return c_industry_code;
	 END;
 Function c_salesrep_title_p return varchar2 is
	Begin
	 return c_salesrep_title;
	 END;
 Function c_sales_title_p return varchar2 is
	Begin
	 return c_sales_title;
	 END;
 Function c_salester_title_p return varchar2 is
	Begin
	 return c_salester_title;
	 END;
END AR_RAXCUSLR_XMLP_PKG ;



/
