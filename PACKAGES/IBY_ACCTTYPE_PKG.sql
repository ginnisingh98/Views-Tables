--------------------------------------------------------
--  DDL for Package IBY_ACCTTYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_ACCTTYPE_PKG" AUTHID CURRENT_USER as
/*$Header: ibyactps.pls 115.5 2002/11/15 23:49:49 jleybovi ship $*/
/*
** Function: createPmtSchemes.
** Purpose:  creates the pmt scheme information, if it is not already
**           there in the database.
**           and passes back the corresponding pmtschemeid id.
*/
procedure createAcctType( i_accttype in iby_accttype.accttype%type,
                        i_instrtype in iby_accttype.instrtype%type,
                        io_accttypeid  in out nocopy iby_accttype.accttypeid%type);
end iby_accttype_pkg;

 

/
