--------------------------------------------------------
--  DDL for Package Body JA_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_AWT_PKG" as
/* $Header: jazzawtb.pls 115.6 2003/07/15 22:35:30 dbetanco ship $ */
--
--
function JA_AU_Check_Exception (
                          P_Tax_Name    	IN varchar2
                         ,P_Invoice_Id  	IN number
                         ,P_Payment_Num 	IN number
                         ,P_Awt_Date    	IN date
                         ,P_Amount      	IN number
			 ,P_Vendor_id		IN number
			 ,P_Vendor_Site_id	IN number
			 ,P_Minimum_rate_id	IN number
			)
			return number
is
BEGIN

    return(NULL);

END JA_AU_Check_Exception;


-- +=======================================================================+
-- |  Function
-- |    JA_AU_Get_Rate_Id
-- |
-- |  Description
-- |    Function JA_AU_Get_Rate_Id used to obtain tax rate as required by
-- |    Australian Tax laws.
-- |
-- |  Localization History
-- |    S Goggin       11-MAR-96  PPS rules Coded
-- |    S Goggin       18-MAR-96  Modified to check for exception
-- |                              Rate>variation rate.
-- |    S Goggin       29-MAR-96  Added Rounding Code...
-- |    J.Karouzakis   22-MAY-96  Modified to update proposed_payment_amount
-- |                              and amount_remaining in rounding routine.
-- |    S.Goggin       07-JAN-97  Modified code to pick up the correct rates
-- |                              when the start date is null.
-- |    S.Goggin       21-JAN-97  Fixed rounding problem with PPS invoices.
-- |    J.Karouzakis   19-MAY-97  Modified to update proposed_payment_amount
-- |
-- |  Globalization History
-- |    J Tsai         19-JUN-97  Incorporated into JA Globalization
-- |    J Liu          02-OCT-97  Added JA_AU_AP_AWT_FLAG for execution control
-- |    J Liu          14-OCT-97  Bug564271. Local var not define and no value
-- |                              returned from ap_special_rate funtion.
-- |    J Liu          22-DEC-97  Bug603639:nvl profile option comparison
-- |    J.Karouzakis   22-DEC-97  Bug 569888. Changed cursors C_R_Tax_rate and
-- |                              C_C_Tax_rate to recognise certificate_type as
-- |                              it is stored in table.
-- |    J.Karouzakis   02-SEP-99  Bug 825343. Fixed problems where incorrect
-- |                              rate may be used to calculate withholding tax
-- |                              when two or more vendor sites are associated
-- |                              with a vendor.
-- |                              Bug 970280. Modified to account for changes
-- |                              made by AP to rel 11 which resulted in
-- |                              invoice to Tax Authority being for unrounded
-- |                              amount.
-- |    J.Karouzakis   22-DEC-97  Bug 569888. Changed cursors C_R_Tax_rate and
-- |    J.Karouzakis   08-NOV-99  Fixed for Bug 1062505
-- |    Dario Betancourt Stub Procedure Bug# 2358962
-- |
-- +==========================================================================+

function JA_AU_Get_Rate_Id (
                            P_Tax_Name    IN varchar2
                           ,P_Invoice_Id  IN number
                           ,P_Payment_Num IN number
                           ,P_Awt_Date    IN date
                           ,P_Amount      IN number
                           )
                           return number
is

BEGIN

    return(NULL);

END JA_AU_Get_Rate_Id;


-- +=======================================================================+
-- |  Procedure
-- |    JA_AU_AWT_Rounding
-- |
-- |  Description
-- |    Procedure JA_AU_AWT_Rounding used for PPS payment invoice rounding.
-- |
-- |  History
-- |    S Goggin       26-MAR-96  Created
-- |    S Goggin       18-JAN-97  Modified code to cope with pay alone invoices
-- |    J Tsai         19-JUN-97  Incorporated into JA Globalization
-- |    J Karouzakis   23-AUG-99  Changed for Bug 970280.
-- |    J Karouzakis   07-OCT-99  Modified for altered implementation for 11i
-- |    Dario Betancourt Stub Procedure Bug# 2358962
-- |
-- +=======================================================================+

procedure JA_AU_AWT_Rounding (P_Checkrun_Name IN varchar2)
is
BEGIN

   NULL;

END JA_AU_AWT_Rounding;




-- MAIN function/procedure begins here.

-- +=======================================================================+
-- |    Copyright (c) 1999 Oracle Corporation Belmont, California, USA     |
-- |                         All rights reserved.                          |
-- +=======================================================================+
-- |  Procedure
-- |    Get_Rate_Id
-- |
-- |  Description
-- |    Procedure Get_Rate_Id used for rate implementations in AWT.
-- |
-- |  History
-- |    J Karouzakis  07-OCT-1999  Created
-- |    Dario Betancourt Stub Procedure Bug# 2358962
-- |
-- +=======================================================================+

function Get_Rate_Id (
                       P_Tax_Name    IN varchar2
                      ,P_Invoice_Id  IN number
                      ,P_Payment_Num IN number
                      ,P_Awt_Date    IN date
                      ,P_Amount      IN number
                      )
                      return number
is

BEGIN

   return(NULL);

END Get_Rate_Id;


-- +=======================================================================+
-- |    Copyright (c) 1999 Oracle Corporation Belmont, California, USA     |
-- |                         All rights reserved.                          |
-- +=======================================================================+
-- |  Procedure
-- |    AWT_Rounding
-- |
-- |  Description
-- |    Procedure AWT_Rounding used for rounding implementations in AWT.
-- |
-- |  History
-- |    J Karouzakis  07-OCT-1999  Created
-- |    Dario Betancourt Stub Procedure Bug# 2358962
-- +=======================================================================+

procedure AWT_Rounding (P_Checkrun_Name IN varchar2)
is
BEGIN

    NULL;

END AWT_Rounding;

end JA_AWT_PKG;

/
