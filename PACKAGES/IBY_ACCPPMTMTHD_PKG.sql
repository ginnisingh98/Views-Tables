--------------------------------------------------------
--  DDL for Package IBY_ACCPPMTMTHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ACCPPMTMTHD_PKG" AUTHID CURRENT_USER as
/*$Header: ibyacpms.pls 120.2 2005/10/30 05:49:28 appldev ship $*/

/*
** Name : iby_accppmtmthd_pkg
**
** Purpose:
**
** This package creates accepted payment methods for a payee and
** deletes accepted payment methods.
**
*/


/*
** Procedure: getMPayeeId
** Purpose: retrieve mpayeeid from iby_payee table based on payeeid
*/
Procedure getMPayeeId(i_payeeid in iby_payee.payeeid%type,
			o_mpayeeid out NOCOPY iby_payee.mpayeeid%type);


/*
** Function: pmtMthdExists.
** Purpose: Check if the specified payeeid and pmtmethod  exists or not.
*/

function pmtMthdExists(i_ecappid in iby_accppmtmthd.ecappid%type,
		     i_payeeid in iby_accppmtmthd.payeeid%type,
		     i_instrtype in iby_accttype.instrtype%type,
                     i_accttype  in iby_accttype.accttype%type,
		     o_status out nocopy iby_accppmtmthd.status%type)

return boolean;

/*
** Procedure Name: createAccpPmtMthd
** Purpose : To create an accepted payment method for a payee.
** Parameters:
**     In : i_ecappid, i_payeetype, i_payeeid, i_instrtype, and i_accttype.
**     Out: None.
**
*/
procedure createAccpPmtMthd(i_ecappid   in iby_accppmtmthd.ecappid%type,
                            i_payeeid   in iby_accppmtmthd.payeeid%type,
                            i_instrtype in iby_accttype.instrtype%type,
                            i_accttype  in iby_accttype.accttype%type
					DEFAULT 'ALL');

/*
** Procedure Name: deleteAccpPmtMthd
** Purpose : To delete an accepted payment method for a payee.
** Parameters:
**     In : i_ecappid, i_payeetype, i_payeeid, i_intrtype, and i_accttype.
**     Out: None.
**
*/
procedure deleteAccpPmtMthd(i_ecappid   in iby_accppmtmthd.ecappid%type,
                            i_payeeid   in iby_accppmtmthd.payeeid%type,
                            i_instrtype in iby_accttype.instrtype%type,
                            i_accttype  in iby_accttype.accttype%type);

end iby_accppmtmthd_pkg;

/
