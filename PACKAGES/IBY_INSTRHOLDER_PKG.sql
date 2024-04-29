--------------------------------------------------------
--  DDL for Package IBY_INSTRHOLDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_INSTRHOLDER_PKG" AUTHID CURRENT_USER as
/*$Header: ibyhdiss.pls 115.6 2003/05/30 10:59:09 nmukerje ship $*/
/*
** Procedure: createHolderInstr.
** Purpose:   create a row in holder instrument table. This table keeps
**            track of the instrument and its holder information.
** In Parameters: i_hld_type, type of the holder. (payee, user, etc..
**            i_hld_id, id of the holder.
**            i_ecappid, ec application id through which the holder is
**            created. instr_type and instr_id are type of instrument
**            BANKACCT or CREDITCARD, and it's id respectively.
*/
procedure createHolderInstr( i_ecappid in iby_ecapp.ecappid%type,
                         i_hld_type in iby_instrholder.ownertype%type,
                         i_hld_id in iby_instrholder.ownerid%type,
                         i_hld_address_id in iby_instrholder.owneraddressid%type,
                         i_instr_type in iby_instrholder.instrtype%type,
                         i_instr_id in iby_instrholder.instrid%type);
/*
** Procedure: deleteHolderInstr.
** Purpose: marks the record identified by the ownerid, ownertype and
**          instrid and instrtype as in inactivated.
*/
procedure deleteHolderInstr( i_ecappid in iby_ecapp.ecappid%type,
                       i_ownertype in iby_instrholder.ownertype%type,
                       i_ownerid in iby_instrholder.ownerid%type,
                       i_instrtype in iby_instrholder.instrtype%type,
                       i_instrid in iby_instrholder.instrid%type);
/*
** Procedure: holderInstrExists
** Purpose: checks whether the corresponding id of the holder holds the
**          isntrument or not.
*/
function instrholderExists(i_ecappid in iby_ecapp.ecappid%type,
                           i_hld_type in iby_instrholder.ownertype%type,
                           i_hld_id in iby_instrholder.ownerid%type,
                           i_instr_type in iby_instrholder.instrtype%type,
                           i_instr_id in iby_instrholder.instrid%type)
return boolean;
procedure getHolderinstr( i_ecappid in iby_ecapp.ecappid%type,
                          i_hld_type in iby_instrholder.ownertype%type,
                          i_hld_id in iby_instrholder.ownerid%type,
                          o_instr_type out nocopy iby_instrholder.instrtype%type,
                          o_instr_id out nocopy iby_instrholder.instrid%type);
/*
** Function: payeeAcctExists
** Purpose: checks whether the corresponding id of the holder holds the
**          isntrument or not.
*/
function payeeAcctExists(i_ecappid in iby_ecapp.ecappid%type,
                         i_hld_id in iby_instrholder.ownerId%type)
return boolean;
/*
** Procedure: deleteInstr.
** Purpose: marks the record identified by the ownerid, ownertype and
**          instrid as inactivated.
*/
procedure deleteInstr( i_ecappid in iby_ecapp.ecappid%type,
                       i_ownertype in iby_instrholder.ownertype%type,
                       i_ownerid in iby_instrholder.ownerid%type,
                       i_instrid in iby_instrholder.instrid%type);
end iby_instrholder_pkg;

 

/
