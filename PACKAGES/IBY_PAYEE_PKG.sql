--------------------------------------------------------
--  DDL for Package IBY_PAYEE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PAYEE_PKG" AUTHID CURRENT_USER as
/*$Header: ibypyees.pls 120.1 2005/07/26 17:26:52 rameshsh ship $*/

/*
** Procedure: createPayee.
** Purpose: creates a payee object in iby_payee.
** parameters: i_payeeid, id of the payee that is passed by ec application.
**             ecappid, id of the ecapplication.
*/
procedure createPayee(i_ecappid in iby_ecapp.ecappid%type,
                      i_payeeid in iby_payee.payeeid%type,
                      i_payeename in iby_payee.name%type,
                      i_supportedOp in iby_payee.supportedOp%type,
                      i_username in iby_payee.username%type,
                      i_password in iby_payee.password%type,
                      i_activestatus in iby_payee.activeStatus%type,
		      i_threshold in iby_payee.threshold%type,
		      i_risk_enabled in iby_payee.risk_enabled%type,
                      i_bepids in JTF_NUMBER_TABLE,
                      i_bepkeys in varchar2,
                      i_bepdefaults in varchar2,
                      i_mcc in number,
		      i_secenable IN iby_payee.security_enabled%TYPE
		      );


/*
** Procedure activatePayee
** Set the active status of the payee
*/
procedure setPayeeStatus(i_ecappid in iby_payee.ecappid%type,
			i_payeeid in iby_payee.payeeid%type,
			i_activestatus in iby_payee.activeStatus%type);


/*
** Procedure: modifyPayee.
** Purpose: creates a payee object in iby_payee.
** parameters: i_payeeid, id of the payee that is passed by ec application.
**             ecappid, id of the ecapplication.
*/
procedure modifyPayee(i_ecappid in iby_ecapp.ecappid%type,
                      i_payeeid in iby_payee.payeeid%type,
                      i_payeename in iby_payee.name%type,
                      i_supportedOp in iby_payee.supportedOp%type,
                      i_username in iby_payee.username%type,
                      i_password in iby_payee.password%type,
                      i_activestatus in iby_payee.activeStatus%type,
		      i_threshold in iby_payee.threshold%type,
		      i_risk_enabled in iby_payee.risk_enabled%type,
                      i_bepids in JTF_NUMBER_TABLE,
                      i_bepkeys in varchar2,
                      i_bepdefaults in varchar2,
                      i_mcc in number,
		      i_secenable IN iby_payee.security_enabled%TYPE,
		      i_object_version in iby_payee.object_version_number%type);


/*
** Function: payeeExists.
** Purpose: Check if the specified payeeid and ecappid  exists or not.
*/
function payeeExists(i_ecappid in iby_payee.ecappid%type,
                     i_payeeid in iby_payee.payeeid%type)
return boolean;

/*
** Following procedures are used for BEP keys parsing.
*/
Type varchar_tab is table of varchar2(100) index by BINARY_INTEGER;
Type number_tab is table of number index by BINARY_INTEGER;

procedure getTables(tableString varchar2, pltable out NOCOPY varchar_tab, counter out NOCOPY integer);
procedure getNumberTables(tableNumber JTF_NUMBER_TABLE, pltable out NOCOPY number_tab, counter out NOCOPY integer);

end iby_payee_pkg;

 

/
