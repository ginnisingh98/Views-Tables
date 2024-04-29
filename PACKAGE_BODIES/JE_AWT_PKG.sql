--------------------------------------------------------
--  DDL for Package Body JE_AWT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_AWT_PKG" as
/* $Header: jezzawtb.pls 115.0 99/10/14 13:52:34 porting ship $ */


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
   return(null);

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
-- |
-- +=======================================================================+

procedure AWT_Rounding (P_Checkrun_Name IN varchar2)
is
BEGIN
   null;

END AWT_Rounding;

end JE_AWT_PKG;

/
