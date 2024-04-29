--------------------------------------------------------
--  DDL for Package Body PA_BILLING_CYCLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_CYCLES_PKG" AS
-- $Header: PAXIBCLB.pls 120.1 2005/10/10 22:34:22 appldev ship $
/**------
function    Get_Billing_Date (
                        X_Project_ID            IN  Number,
                        X_Project_Start_Date    IN  Date,
                        X_Billing_Cycle_ID      IN  Number,
                        X_Bill_Thru_Date        IN  Date,
                        X_Last_Bill_Thru_Date   IN  Date
                                )   RETURN Date;
------**/


/*---------------------------------------------------------------
 Get_Next_Billing_Date ()

 The Function returns the Next Bill Date.
 If the Bill Date computed is less than the Last_Bill_Thru_Date
 then compute the Bill Date which is greater than the Last_Bill_Thru_Date.
-----------------------------------------------------------------*/

function    Get_Next_Billing_Date (
                X_Project_ID            IN  Number,
                X_Project_Start_Date    IN  Date    default NULL,
                X_Billing_Cycle_ID      IN  Number  default NULL,
                X_Billing_Offset_Days   IN  Number  default NULL,
                X_Bill_Thru_Date        IN  Date    default NULL,
                X_Last_Bill_Thru_Date   IN  Date    default NULL
                                )   RETURN Date
IS

Proj_start_date Date     := X_Project_Start_date;
Proj_id         Number   := X_Project_ID;
Bill_cycle_id   Number   := X_Billing_Cycle_ID;
Bill_offset     Number   := X_Billing_Offset_Days;
Last_Bill_thru_date Date := X_Last_Bill_thru_date;
Bill_thru_date	Date	 := X_Bill_Thru_Date;
Bill_date       Date;

BEGIN

/** If project start date, billing cycle id, billing offset IS NULL
    then get the proj info **/

IF (X_Project_Start_Date IS NULL) OR (X_Billing_Cycle_ID IS NULL)
    OR (X_Billing_offset_days IS NULL) then
    Begin
      Select NVL(Start_date, Creation_date), billing_cycle_id,
              NVL(billing_offset,0)
      INTO proj_start_date, bill_cycle_id, bill_offset
      FROM PA_Projects_All
      WHERE project_id = Proj_ID;
        Exception When NO_DATA_FOUND THEN
          NULL;
    End;
END IF;

/** If Last_Bill_thru_date IS NULL then determine the Last bill thru
    date **/

IF Last_Bill_thru_date IS NULL then
    Last_Bill_thru_date := Get_Last_Bill_Thru_Date( Proj_id);
END IF;

/** If Last Bill thru date NULL means No invs found.
    Determine the date using offset days **/
/* Condition modified for Bug#1347747 */

IF Last_Bill_thru_date IS NULL then
    IF NVL(Bill_offset,0) >= 0 then
        /** Add offset and return **/
        RETURN ( TRUNC(Proj_start_date + NVL(bill_offset,0)) );
    END IF;
END IF;

/** Get the Next billing date  using bill cycle **/

Bill_date := Get_Billing_Date(  Proj_id,
                                Proj_start_date,
                                Bill_cycle_id,
								Bill_thru_date,
                                Last_Bill_thru_date);

RETURN (Bill_date);

EXCEPTION
    When OTHERS then
    RAISE;
END Get_Next_Billing_Date;

/*------------------------------------------------------------------------
 Get_Billing_Date ()

 Function to compute the Billing Cycle Date based on the
 Last Bill thru Date.
 The Bill Date is computed based on the month of Last Bill Thru date.
 The Bill Date > Last Bill Thru date.
 Calls Billing Cycle extn for User Defined Billing Cycles Types.
 The Client Extension should ensure the Bill Date > Last Bill thru date.
---------------------------------------------------------------------------*/
function    Get_Billing_Date (
                X_Project_ID            IN  Number,
                X_Project_Start_Date    IN  Date,
                X_Billing_Cycle_ID      IN  Number,
                X_Bill_Thru_Date        IN  Date,
                X_Last_Bill_Thru_Date   IN  Date
                                )   RETURN Date
IS

TYPE BillValueTab IS TABLE OF Number
    INDEX BY BINARY_INTEGER;

BillValue       BillValueTab;
i               BINARY_INTEGER := 5;

j               Number := 0;
k               Number := 0;
tmp             Number := 0;
Bill_date       Date;
Bill_thru_Date  Date := X_Bill_Thru_Date;
Last_Bill_Thru_Date Date := X_Last_Bill_Thru_Date;
Last_Date 	Date := NVL(X_Last_Bill_thru_date, X_Project_Start_Date);
Temp_Date       Date;
Temp2_Date      Date;
Bill_Month      Varchar2(10);
Bill_Day        Varchar2(100); --Changed the length for bug 4630032
MaxVal          Number := 9999;
Bill_Date_15	DATE;
Bill_Date_Last_Day DATE;

Cursor Bill_Cur IS
    Select Billing_Cycle_Type, Billing_Value1,
            Billing_Value2, Billing_Value3,
            Billing_Value4, Billing_Value5
    From    PA_Billing_Cycles
    Where   Billing_Cycle_ID = X_Billing_Cycle_ID;

Bill_rec        Bill_Cur%RowType;

BEGIN

/**  Get the Billing Cycle Record **/

Open Bill_Cur;
Fetch Bill_Cur into Bill_rec;
If Bill_Cur%NOTFOUND then
    Close Bill_Cur;
    RAISE NO_DATA_FOUND;
    RETURN NULL ;
End if;

Close Bill_cur;


-- Added for Patchset L Enhancement Bug 1584948
IF Bill_Rec.Billing_Cycle_Type = '15TH AND MONTH END'
THEN
  Bill_Month := to_char( Last_Date, 'mm/yyyy' );
  Bill_Date_15 := to_date('15/'|| Bill_Month,'dd/mm/yyyy' );
  Bill_Date_Last_Day := last_day(to_date('01/'|| Bill_Month,'dd/mm/yyyy'));

  -- Following if clause is modified for bug fix 3011314
  -- If the last Bill thru date is before 15th of its month,
  -- then return its 15th date of the month
  IF Last_Date < Bill_Date_15 THEN
    RETURN Bill_Date_15;
  END IF;

  -- If the last Bill trhu date is on before last day of the month
  -- then return the last day of the month
  -- Else return 15th of the next month.
  IF Last_Date >= Bill_Date_15 AND Last_Date <> Bill_Date_Last_Day
  THEN
    RETURN Bill_Date_Last_Day ;
  ELSE
    Temp_Date := to_date( '15/'|| Bill_Month,'dd/mm/yyyy');
    Temp_Date := add_months( Temp_Date, 1 );
    Return Temp_Date;
  END IF;

END IF;
-- Added for Patchset L END


/** User defined code called **/

IF Bill_Rec.Billing_Cycle_Type = 'USER DEFINED' Then
   Return PA_Client_Extn_Bill_Cycle.Get_Next_Billing_Date(
							  X_Project_id,
                              X_Project_Start_Date,
                              X_Billing_Cycle_ID,
                              X_Bill_Thru_Date,
                              X_Last_Bill_Thru_Date);
End if;

/** Calculate the Bill Date for Billing Cycle Days  **/

If Bill_Rec.Billing_Cycle_Type = 'BILLING CYCLE DAYS' Then
   Bill_Date := Last_Date + (NVL(to_number(Bill_Rec.Billing_Value1),0));
   Return Bill_Date;
End if;

Bill_Month := to_char( Last_Date, 'mm/yyyy' );

/** Set the billValue table with not null values **/

FOR i in 1..5 LOOP
    BillValue(i) := NULL;
END LOOP;

BillValue(1) := nvl(to_number(Bill_Rec.Billing_Value1),MaxVal);
BillValue(2) := nvl(to_number(Bill_Rec.Billing_Value2),MaxVal);
BillValue(3) := nvl(to_number(Bill_Rec.Billing_Value3),MaxVal);
BillValue(4) := nvl(to_number(Bill_Rec.Billing_Value4),MaxVal);
BillValue(5) := nvl(to_number(Bill_Rec.Billing_Value5),MaxVal);

/** Sort the Values with null values to the end as 9999 **/

i := 1;
LOOP
  i := i+1;
  tmp := BillValue(i);
  FOR j in 1..(i-1) LOOP
    IF tmp < BillValue(j) then
        k := i;
        LOOP
            BillValue(k) := BillValue(k-1);
            k := k-1;
            IF k = j then
                BillValue(j) := tmp;
                EXIT;    -- exit to outer loop
            END IF;
        END LOOP;
        EXIT;       -- exit to main loop
    END IF;
  END LOOP;
  IF i = 5 then
    EXIT;       -- exit out
  END IF;
END LOOP;

/** Derive the date **/

LOOP

IF Bill_Rec.Billing_Cycle_Type = 'DATE OF MONTH' Then
    /** Date of Month may have ore than one values **/
    i := 0;
    LOOP
        i := i+1;
        IF BillValue(i) = MaxVal then
            EXIT;       -- out of this loop
        END IF;
        BEGIN
        Bill_Date := to_date( lpad(to_char(BillValue(i)),2,'0')
                            || '/' || Bill_Month,'dd/mm/yyyy' );
        EXCEPTION
        When OTHERS then
            Bill_Date := last_day( to_date('01/'|| Bill_Month,'dd/mm/yyyy' ));
        END;
        IF Bill_Date > Last_date then
            EXIT;       -- out of this loop
        END IF;
        IF i = 5 then
            EXIT;       -- out of this loop
        END IF;
    END LOOP;

ELSIF Bill_Rec.Billing_Cycle_Type = 'LAST DAY OF MONTH' Then
    Bill_Date := last_day( to_date('01/'|| Bill_Month,'dd/mm/yyyy' ));

ELSIF Bill_Rec.Billing_Cycle_Type = 'FIRST DAY OF MONTH' Then
    Bill_Date := to_date( '01/'|| Bill_Month,'dd/mm/yyyy' );

ELSIF Bill_Rec.Billing_Cycle_Type = 'FIRST WEEKDAY OF MONTH' Then
    Temp_Date := to_date( '01/'|| Bill_Month,'dd/mm/yyyy' ); -- First of curr mth
    Temp2_Date := last_day( Temp_Date );      -- Last of curr mth
    Temp_Date := add_months( Temp2_date, -1 );  -- Last of prev mth

    -- decode number 1-7 into weekdays

   if BillValue(1)=1 then
       BillValue(1):=8;
    end if;
    select to_char(to_date('01-01-1950','DD-MM-YYYY') + BillValue(1)-1,'Day')
           Into  Bill_Day
           From Dual;

  --  Select meaning
  --     Into  Bill_Day
  --    From  PA_Lookups
  --   Where Lookup_Type = 'EXPENDITURE CYCLE START DAY'
  --  AND   Lookup_Code = to_char(BillValue(1));

    Bill_Date := next_day( Temp_Date, Bill_Day ); -- date for first wkday

ELSIF Bill_Rec.Billing_Cycle_Type = 'LAST WEEKDAY OF MONTH' Then
    Temp_Date := to_date( '01/'|| Bill_Month,'dd/mm/yyyy' ); -- First of curr mth
    Temp2_Date := last_day( Temp_Date );      -- Last of curr mth

    -- decode number 1-7 into weekdays

    if BillValue(1)=1 then
       BillValue(1):=8;
    end if;

    select to_char(to_date('01-01-1950','DD-MM-YYYY') +BillValue(1)-1,'Day')
           Into  Bill_Day
           From Dual;

   -- Select meaning
   --     Into  Bill_Day
   --    From  PA_Lookups
   -- Where Lookup_Type = 'EXPENDITURE CYCLE START DAY'
   -- AND   Lookup_Code = to_char(BillValue(1));

    Temp_Date := next_day( Temp2_Date, Bill_Day ); -- date for first wkday
                                          -- of next mth
    Bill_Date := Temp_Date - 7;             -- Last wkday of curr mth

ELSIF Bill_Rec.Billing_Cycle_Type = 'PROJECT COMPLETION' then
    /** Get the completion date for the project **/
	Select Completion_date
	Into Bill_Date
	From PA_Projects_All
	Where Project_ID = X_Project_ID;

	IF (Bill_date IS NULL) AND (X_Bill_Thru_Date IS NOT NULL) then
	/** Project not yet complete.
		If inv gen process ( Bill thru date not null)
		then return bill thru date+1, so as not to consider the project.
		else, return NULL **/
		Bill_date := X_Bill_Thru_Date+1;
	END IF;

    RETURN Bill_Date;

ELSIF Bill_Rec.Billing_Cycle_Type = 'WEEKDAY EACH WEEK' then
    -- decode number 1-7 into weekdays

    if BillValue(1)=1 then
       BillValue(1):=8;
    end if;

    select to_char(to_date('01-01-1950','DD-MM-YYYY') +BillValue(1)-1,'Day')
           Into  Bill_Day
           From Dual;

   -- Select meaning
   --    Into  Bill_Day
   --   From  PA_Lookups
   --  Where Lookup_Type = 'EXPENDITURE CYCLE START DAY'
   -- AND   Lookup_Code = to_char(BillValue(1));

    Bill_Date := next_day( Last_Date, Bill_Day ); -- date for next wkday

    RETURN Bill_Date;

END IF;

If Bill_Date <= Last_Date then
    Temp_Date := to_date( '01/'|| Bill_Month,'dd/mm/yyyy');
    Temp_Date := add_months( Temp_Date, 1 );
    Bill_Month := to_char( Temp_Date, 'mm/yyyy');
Else
    Return Bill_Date;
End if;

END LOOP;

EXCEPTION
   WHEN OTHERS then
   RAISE;

END Get_Billing_Date;

/*-------------------------------------------------------------------
 Get_Last_Bill_Thru_Date ()
 Function to get the last bill thru date for a project.
 If no invoices found, then null returned.
---------------------------------------------------------------------*/

function    Get_Last_Bill_Thru_Date (
                X_Project_ID            IN  Number
                                )   RETURN Date
IS

Last_Bill_Thru_Date Date;

BEGIN

/** get the last bill thru date **/
/* Added retention_invoice_flag condition for Bug2385594 */

SELECT  MAX(NVL(Bill_through_date, Creation_date))
INTO    Last_Bill_thru_date
FROM    PA_Draft_Invoices_All
WHERE   Project_id = X_project_id
AND     nvl(retention_invoice_flag, 'N') = 'N'
AND     Draft_Invoice_Num_Credited IS NULL
AND     Released_By_Person_ID IS NOT NULL
AND     NVL(Canceled_Flag,'N') = 'N';

RETURN Last_Bill_Thru_Date;

EXCEPTION

WHEN OTHERS then
    Raise;

END Get_Last_Bill_Thru_Date;


/*--------------------------------------------------------------------
 Get_Last_Released_Invoice_Num ()

 Function to determine the last invoice number for a project.
 Returns the uncrediting, released draft invoice, if found,
 else NULL.
----------------------------------------------------------------------*/

function    Get_Last_Released_Invoice_Num (
                X_Project_ID            IN  Number
                                )   RETURN Number
IS

Invoice_Num Number;

BEGIN

/** Get invoice num **/

SELECT  MAX(DI.Draft_Invoice_Num)
INTO    Invoice_Num
FROM    PA_Draft_Invoices DI
WHERE   DI.Project_ID = X_Project_id
AND     DI.Draft_Invoice_Num_Credited IS NULL
AND     DI.Released_By_Person_ID IS NOT NULL
AND     NVL(DI.Canceled_Flag,'N') = 'N'
AND     NVL(DI.Bill_through_date, DI.Creation_date) = (
                SELECT  MAX(NVL(PDI.Bill_through_date, PDI.Creation_date))
                FROM    PA_Draft_Invoices PDI
                WHERE   PDI.Project_ID = DI.Project_ID
                AND     PDI.Draft_Invoice_Num_Credited IS NULL
                AND     PDI.Released_By_Person_ID IS NOT NULL
		AND     NVL(PDI.Canceled_Flag,'N') = 'N'
                        );

RETURN Invoice_Num;

EXCEPTION
WHEN OTHERS then
    RAISE;

END Get_Last_Released_Invoice_Num;

------------------------------------------------------------------------
END PA_Billing_Cycles_Pkg;


/
