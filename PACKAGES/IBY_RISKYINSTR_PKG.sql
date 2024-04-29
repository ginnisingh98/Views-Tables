--------------------------------------------------------
--  DDL for Package IBY_RISKYINSTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_RISKYINSTR_PKG" AUTHID CURRENT_USER as
/*$Header: ibyrkins.pls 115.3 2002/11/19 23:54:07 jleybovi ship $*/

/* Risky Instr used to update */
TYPE Risky_Instr is RECORD(PayeeID VARCHAR2(80), InstrType VARCHAR2(80),
		Routing_Num VARCHAR2(80), Account_Num VARCHAR2(80),
		CreditCard_Num VARCHAR2(80));

/* Result of each record's update */
TYPE Result is RECORD(success NUMBER, errmsg VARCHAR2(100));

TYPE RiskyInstr_Table IS TABLE OF Risky_Instr INDEX BY BINARY_INTEGER;

TYPE Result_Table IS TABLE OF Result INDEX BY BINARY_INTEGER;


 /*
  ** Procedure: add_RiskyInstr
  ** Purpose: Appends/Adds the vector of RiskyInstr into the table. For
  ** each risky instrument, if it matches (payeeid,instrtype,and numbers)
  ** then does nothing, else adds it to table
  */
procedure add_RiskyInstr (i_count in integer,
			  i_riskyinstr in RiskyInstr_Table,
			  o_results out nocopy Result_Table);


 /*
  ** Procedure: delete_RiskyInstr
  ** Purpose: Delete the vector of RiskyInstr into the table. For
  ** each risky instrument, if it matches (payeeid,instrtype,and numbers)
  ** then delete the entry from table, else does nothing
  */
procedure delete_RiskyInstr (i_count in integer,
			     i_riskyinstr in RiskyInstr_Table,
			     o_results out nocopy Result_Table);

procedure delete_allRiskyInstr;
end iby_riskyinstr_pkg;


 

/
