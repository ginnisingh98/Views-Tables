--------------------------------------------------------
--  DDL for Package Body AR_ARXFXGL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXFXGL_XMLP_PKG" AS
/* $Header: ARXFXGLB.pls 120.0 2007/12/27 13:51:15 abraghun noship $ */

function BeforeReport return boolean is
begin

    /*SRW.USER_EXIT('FND SRWINIT');*/null;


    /*srw.message ('100', 'DEBUG:  BeforeReport +');*/null;




    /*srw.message ('100', 'DEBUG:  Call Build_Customer_Details');*/null;

    Build_Customer_Details;




    /*srw.message ('100', 'DEBUG:  Call Build_Location_Details');*/null;

    Build_Location_Details;




    /*srw.message ('100', 'DEBUG:  Call Build_Rate_Type_Details');*/null;

    Build_Rate_Type_Details;




    /*srw.message ('100', 'DEBUG:  Call Build_Receipt_Date_Details');*/null;


    Build_Receipt_Date_Details;




    /*srw.message ('100', 'DEBUG:  Call Build_Currency_Details');*/null;


    Build_Currency_Details;




    /*srw.message ('100', 'DEBUG:  Call Get_SOB_Details');*/null;


    Get_SOB_Details;




    /*srw.message ('100', 'DEBUG:  Call Get_Report_Name');*/null;


    Get_Report_Name;


    /*srw.message ('100', 'DEBUG:  BeforeReport -');*/null;


  return (TRUE);
end;

PROCEDURE Build_Customer_Details IS
     Customer_Id_Char       VARCHAR2(15);
BEGIN

     /*srw.message ('100', 'DEBUG:  Build_Customer_Details +');*/null;


     IF P_Customer_Id IS NOT NULL THEN

          Customer_Id_Char := P_Customer_Id;
          Where_Customer := 'AND cash.customer_id = ' || Customer_Id_Char;

          SELECT CUST.ACCOUNT_NUMBER,
                 SUBSTRB(PARTY.PARTY_NAME,1,50)
          INTO   P_Customer_Number,
                 P_Customer_Name
          FROM   HZ_CUST_ACCOUNTS CUST,
		 HZ_PARTIES PARTY
          WHERE  CUST.CUST_ACCOUNT_ID = P_Customer_Id
	  AND    CUST.PARTY_ID = PARTY.PARTY_ID;
     END IF;

     /*srw.message ('100', 'DEBUG:  Build_Customer_Details -');*/null;



EXCEPTION
     WHEN NO_DATA_FOUND THEN
          /*srw.message ('100', 'DEBUG:  Customer Number/Name not found');*/null;

          RAISE;

END;

PROCEDURE Build_Location_Details IS
     Site_Use_Id_Char     VARCHAR2(15);
BEGIN

     /*srw.message ('100', 'DEBUG:  Build_Location_Details +');*/null;


     IF P_Site_Use_Id IS NOT NULL THEN

          Site_Use_Id_Char := P_Site_Use_Id;
          Where_Location := 'AND cash.customer_site_use_id = ' || Site_Use_Id_Char;

          SELECT location
          INTO   P_Location
          FROM   HZ_CUST_site_uses_all
          WHERE  site_use_id = P_site_use_id;

     END IF;

     /*srw.message ('100', 'DEBUG:  Build_Location_Details -');*/null;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
          /*srw.message ('100', 'DEBUG:  Location not found');*/null;

          RAISE;

END;

PROCEDURE Build_Rate_Type_Details IS
BEGIN

     /*srw.message ('100', 'DEBUG:  Build_Rate_Type_Details +');*/null;


     IF P_Rate_Type IS NOT NULL THEN

          SELECT user_conversion_type
          INTO   P_Exchange_Rate_Type
          FROM   gl_daily_conversion_types
          WHERE  conversion_type = P_Rate_Type;

     END IF;

     /*srw.message ('100', 'DEBUG:  Build_Rate_Type_Details -');*/null;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
          /*srw.message ('100', 'DEBUG:  Exchange Rate Type Not Found');*/null;

          RAISE;

END;

PROCEDURE BUILD_RECEIPT_DATE_DETAILS IS
     From_Date_Char     VARCHAR2(11);
     To_Date_Char       VARCHAR2(11);
BEGIN



     /*srw.message ('100', 'DEBUG:  Build_Receipt_Dates +');*/null;


     From_Date_Char := P_From_Receipt_Date;
     To_Date_Char := P_To_Receipt_Date;


     IF P_From_Receipt_Date IS NOT NULL THEN
          IF P_To_Receipt_Date IS NOT NULL THEN
               Where_Date := 'AND cash.receipt_date BETWEEN ''' || From_Date_Char || '''' ||
                                                       ' AND ''' || To_Date_Char || '''';
          ELSE
               Where_Date := 'AND cash.receipt_date >= ''' || From_Date_Char || '''';
          END IF;
     ELSE
          IF P_To_Receipt_Date IS NOT NULL THEN
               Where_Date := 'AND cash.receipt_date <= ''' || To_Date_Char || '''';
          END IF;
     END IF;

     /*srw.message ('100', 'DEBUG:  Build_Receipt_Dates -');*/null;


END;

PROCEDURE BUILD_CURRENCY_DETAILS IS
BEGIN

     /*srw.message ('100', 'DEBUG:  Build_Currency_Details +');*/null;


     IF P_Receipt_Currency IS NOT NULL THEN
          Where_Currency := 'AND cash.currency_code = ''' || P_Receipt_Currency || '''';
     END IF;

     /*srw.message ('100', 'DEBUG:  Build_Currency_Details -');*/null;


END;

function cf_gain_loss_actualfo(Actual_Alloc_Receipt_Amt_Base in number, Trx_Amt_Applied_Base in number) return number is
   Exchange_Gain_Loss     NUMBER;
begin

     Exchange_Gain_Loss := ROUND(Actual_Alloc_Receipt_Amt_Base - Trx_Amt_Applied_Base, 6);

     RETURN (Exchange_Gain_Loss);

end;

function allocated_amount_rateformula(Trx_Amt_Applied IN NUMBER,Receipt_Precision IN NUMBER,Rate_Sys_Curr_Rate in number) return number is
     Allocated_Amount_Rate      NUMBER;
begin

     IF Rate_Sys_Curr_Rate IS NULL THEN
          Allocated_Amount_Rate := '';
     ELSE
          Allocated_Amount_Rate := ROUND (Trx_Amt_Applied * Rate_Sys_Curr_Rate, Receipt_Precision);
     END IF;

     RETURN (Allocated_Amount_Rate);

end;

function Sys_Cross_CurrencyFormula(Trx_Currency IN VARCHAR2,Receipt_Currency IN VARCHAR2,Receipt_Date IN DATE) return Number is
     Sys_Cross_Currency     NUMBER;
     Tmp_Sys_Cross_Currency NUMBER;
begin

     IF P_Rate_Type IS NULL THEN
          Sys_Cross_Currency := '';
     ELSE
          BEGIN



               Sys_Cross_Currency := GL_CURRENCY_API.get_rate (Trx_Currency,
						  	       Receipt_Currency,
							       Receipt_Date,
							       P_Rate_Type);




          EXCEPTION
               WHEN OTHERS THEN
                                        Sys_Cross_Currency := '';
          END;

     END IF;

     RETURN (Sys_Cross_Currency);

end;

function rate_alloc_receipt_amt_basefor(Rate_Sys_Curr_Rate in number,Rate_Alloc_Receipt_Amt IN NUMBER,Receipt_Exchange_Rate IN NUMBER) return number is
     Alloc_Receipt_Amt_Base     NUMBER;
begin

     IF Rate_Sys_Curr_Rate IS NULL THEN
         Alloc_Receipt_Amt_Base  := '';
     ELSE
          Alloc_Receipt_Amt_Base := ROUND ((Rate_Alloc_Receipt_Amt * Receipt_Exchange_Rate), Functional_Precision);
     END IF;

     RETURN (Alloc_Receipt_Amt_Base);

end;

function rate_gain_lossformula(Rate_Alloc_Receipt_Amt_Base in number, Trx_Amt_Applied_Base in number) return number is
     Gain_Loss     NUMBER;
begin

     Gain_Loss := ROUND (Rate_Alloc_Receipt_Amt_Base - Trx_Amt_Applied_Base, Functional_Precision);

     RETURN (Gain_Loss);

end;

function absolute_differenceformula(Actual_Gain_Loss in number, Rate_Gain_Loss in number) return number is
     L_Absolute_Difference     NUMBER;
begin

     L_Absolute_Difference := ABS( ROUND ((Actual_Gain_Loss - Rate_Gain_Loss), Functional_Precision));

     RETURN (L_Absolute_Difference);

end;

function actual_gainformula(Actual_Gain_Loss in number) return number is
     Actual_Gain    NUMBER;
begin

     IF Actual_Gain_Loss > 0 THEN
          Actual_Gain := Actual_Gain_Loss;
     END IF;

     RETURN (Actual_Gain);
end;

function actual_rate_lossformula(Actual_Gain_Loss in number) return number is
     Actual_Loss    NUMBER;
begin

     IF Actual_Gain_Loss < 0 THEN
          Actual_Loss := Actual_Gain_Loss;
     END IF;

     RETURN (Actual_Loss);

end;

function rate_gainformula(Rate_Gain_Loss in number) return number is
     Rate_Gain    NUMBER;
begin

     IF Rate_Gain_Loss > 0 THEN
          Rate_Gain := Rate_Gain_Loss;
     END IF;

     RETURN (Rate_Gain);

end;

function rate_lossformula(Rate_Gain_Loss in number) return number is
     Rate_Loss    NUMBER;
begin

     IF Rate_Gain_Loss < 0 THEN
          Rate_Loss := Rate_Gain_Loss;
     END IF;

     RETURN (Rate_Loss);

end;

PROCEDURE Get_Report_Name IS
BEGIN

     /*srw.message ('100', 'DEBUG:  Get_Report_Name +');*/null;


     SELECT cp.user_concurrent_program_name
     INTO   Report_Name
     FROM   FND_CONCURRENT_PROGRAMS_VL cp,
            FND_CONCURRENT_REQUESTS cr
     WHERE  cr.request_id = P_CONC_REQUEST_ID
     AND    cp.application_id = cr.program_application_id
     AND    cp.concurrent_program_id = cr.concurrent_program_id;

     /*srw.message ('100', 'DEBUG:  Get_Report_Name -');*/null;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
          /*srw.message ('100', 'DEBUG:  Concurrent Program Title not found');*/null;

	  Report_Name := '';

END;

PROCEDURE Get_SOB_Details IS
BEGIN

     /*srw.message ('100', 'DEBUG:  Get_SOB_Details +');*/null;


     SELECT cur.currency_code,
            cur.precision,
            sob.name
     INTO   Functional_Currency,
            Functional_Precision,
            Set_Of_Books_Name
     FROM   fnd_currencies cur,
            gl_sets_of_books sob
     WHERE  cur.currency_code = sob.currency_code
     AND    sob.set_of_books_id = P_Set_Of_Books_Id;

     /*srw.message ('100', 'DEBUG:  Get_SOB_Details -');*/null;


EXCEPTION
     WHEN NO_DATA_FOUND THEN
          /*srw.message ('100', 'DEBUG:  Set of Books Details not found');*/null;

          RAISE;

END;

function rate_sys_curr_rate_dformula(Rate_Sys_Curr_Rate in number) return number is
     Exchange_Rate    NUMBER;
begin

     Exchange_Rate := ROUND (Rate_Sys_Curr_Rate, 3);

     RETURN(Exchange_Rate);

end;

function actual_cross_curr_rate_dformul(Actual_Cross_Curr_Rate in number) return number is
     Exchange_Rate    NUMBER;
begin

     Exchange_Rate := ROUND (Actual_Cross_Curr_Rate, 3);

     RETURN(Exchange_Rate);

end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;


  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function P_Customer_Number_p return varchar2 is
	Begin
	 return P_Customer_Number;
	 END;
 Function P_Customer_Name_p return varchar2 is
	Begin
	 return P_Customer_Name;
	 END;
 Function Where_Customer_p return varchar2 is
	Begin
	 return Where_Customer;
	 END;
 Function P_Location_p return varchar2 is
	Begin
	 return P_Location;
	 END;
 Function Where_Location_p return varchar2 is
	Begin
	 return Where_Location;
	 END;
 Function Where_Date_p return varchar2 is
	Begin
	 return Where_Date;
	 END;
 Function Where_Currency_p return varchar2 is
	Begin
	 return Where_Currency;
	 END;
 Function P_Exchange_Rate_Type_p return varchar2 is
	Begin
	 return P_Exchange_Rate_Type;
	 END;
 Function Report_Name_p return varchar2 is
	Begin
	 return Report_Name;
	 END;
 Function Functional_Currency_p return varchar2 is
	Begin
	 return Functional_Currency;
	 END;
 Function Set_Of_Books_Name_p return varchar2 is
	Begin
	 return Set_Of_Books_Name;
	 END;
 Function Functional_Precision_p return number is
	Begin
	 return Functional_Precision;
	 END;
END AR_ARXFXGL_XMLP_PKG ;


/
