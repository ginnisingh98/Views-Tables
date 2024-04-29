--------------------------------------------------------
--  DDL for Package Body IBY_INSTRHOLDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_INSTRHOLDER_PKG" as
/*$Header: ibyhdisb.pls 115.11 2003/05/30 10:59:43 nmukerje ship $*/

/*
** Function: holderInstrExists
** Purpose: checks whether the corresponding id of the holder holds the
**          instrument or not.
*/
function instrholderExists(i_ecappid in iby_ecapp.ecappid%type,
                           i_hld_type in iby_instrholder.ownerType%type,
                           i_hld_id in iby_instrholder.ownerId%type,
                           i_instr_type in iby_instrholder.instrtype%type,
                           i_instr_id in iby_instrholder.instrid%type)
return boolean
is
l_flag boolean := false;
l_junk integer;
cursor c_holderinstr(
                    ci_hld_type in iby_instrholder.ownertype%type,
                    ci_hld_id in iby_instrholder.ownerid%type,
                    ci_instr_type in iby_instrholder.instrtype%type,
                    ci_instr_id in iby_instrholder.instrid%type) is
select 1
from iby_instrholder
where ci_hld_type = ownertype
and   ci_hld_id = ownerid
and   ci_instr_type = instrtype
and   ci_instr_id = instrid
and activestatus = 1;
begin
/*
** if cursor is already open close it.
*/
    if ( c_holderinstr%isopen ) then
        close c_holderinstr;
    end if;
/*
** open the cursor with proper input parameters.
*/
    open c_holderinstr(i_hld_type, i_hld_id,
                               i_instr_type, i_instr_id);
    fetch c_holderinstr into l_junk;
/*
**  if any rows exist that are active then return true,
**  otherwise holder_id does not hole the
**  the instrument.
*/
    if ( c_holderinstr%found ) then
        l_flag := true;
    else
        l_flag := false;
    end if;
    close c_holderinstr;
    return l_flag;
end instrholderExists;
/*
** Function: payeeAcctExists
** Purpose: checks whether the corresponding id of the holder holds the
**          isntrument or not.
*/
function payeeAcctExists(i_ecappid in iby_ecapp.ecappid%type,
                         i_hld_id in iby_instrholder.ownerId%type)
return boolean
is
l_flag boolean := false;
l_junk integer;
cursor c_holderinstr(
                    ci_hld_id in iby_instrholder.ownerid%type) is
select 1
from iby_instrholder
where 'PAYEE' = ownertype
and   ci_hld_id = ownerid
and   instrtype = 'BANKACCOUNT'
and activestatus = 1;
begin
/*
** if cursor is already open close it.
*/
    if ( c_holderinstr%isopen ) then
        close c_holderinstr;
    end if;
/*
** open the cursor with proper input parameters.
*/
    open c_holderinstr(i_hld_id);
    fetch c_holderinstr into l_junk;
/*
**  if any rows exist that are active then return true,
**  otherwise holder_id does not hole the
**  the instrument.
*/
    if ( c_holderinstr%found ) then
        l_flag := true;
    else
        l_flag := false;
    end if;
    close c_holderinstr;
    return l_flag;
end payeeAcctExists;
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
procedure createHolderInstr(i_ecappid in iby_ecapp.ecappid%type,
                         i_hld_type in iby_instrholder.ownertype%type,
                         i_hld_id in iby_instrholder.ownerid%type,
			 i_hld_address_id in iby_instrholder.owneraddressid%type,
                         i_instr_type in iby_instrholder.instrtype%type,
                         i_instr_id in iby_instrholder.instrid%type)
is
begin
/*
** insert the holder and instrument information and mark the status as
** active.
*/
    insert into iby_instrholder ( ownertype, ownerid, owneraddressid,instrtype, instrid, activestatus,
                                  last_update_date, last_updated_by, creation_date,
                                  created_by,object_version_number)
                         values ( i_hld_type, i_hld_id,i_hld_address_id,i_instr_type, i_instr_id, 1,
                                  sysdate, fnd_global.user_id, sysdate,
                                  fnd_global.user_id, 1);
    --commit;
end createHolderinstr;


/*
** Procedure: deleteHolderInstr.
** Purpose: marks the record identified by the ownerid, ownertype and
**          instrid and instrtype as in inactivated.
*/
procedure deleteHolderInstr(i_ecappid in iby_ecapp.ecappid%type,
                       i_ownertype in iby_instrholder.ownertype%type,
                       i_ownerid in iby_instrholder.ownerid%type,
                       i_instrtype in iby_instrholder.instrtype%type,
                       i_instrid in iby_instrholder.instrid%type)
is
l_cnt integer;

-- Constant declaration for the various transaction status
-- when the instrument should not be modified or deleted.

   C_COMMUNICATION_ERROR  CONSTANT  NUMBER(3) := 1;
   C_REQUEST_PENDING  CONSTANT  NUMBER(3) := 11;
   C_SCHED_IN_PROGRESS  CONSTANT  NUMBER(3) := 12;
   C_REQUEST_SCHEDULED  CONSTANT  NUMBER(3) := 13;
   C_VOICE_AUTH_REQD  CONSTANT  NUMBER(3) := 21;

begin
/*
** check if there are any pewnding requests for this holderid;
** if so, raise an exception.
*/
    if ( i_ownertype = 'USER' ) then
        select count(*) into l_cnt
        from iby_trxn_summaries_all ps,
             iby_instrholder pih
        where ps.payerinstrid = pih.instrid
        and pih.ownertype = i_ownertype
        and pih.ownerid = i_ownerid
        and pih.instrid = i_instrid
        and ps.status IN ( C_COMMUNICATION_ERROR,C_REQUEST_PENDING,C_SCHED_IN_PROGRESS,
                           C_REQUEST_SCHEDULED,C_VOICE_AUTH_REQD );

    -- Commented,as payee never registers/modifies an instrument.
    --else
        --select count(*) into l_cnt
        --from iby_trxn_summaries_all ps,
             --iby_instrholder pih
        --where ps.payeeinstrid = pih.instrid
        --and pih.ownertype = i_ownertype
        --and pih.ownerid = i_ownerid
        --and pih.instrid = i_instrid
        --and ps.status IN ( 1, 11, 12, 13, 21);
    end if;
    if ( l_cnt <> 0 ) then
        raise_application_error(-20000, 'IBY_20516#', FALSE);
        --raise_application_error(-20516, 'Some Payments are Still pending', FALSE);
    end if;
/*
** mark the status of the matched record as '0'(inactive).
*/

	if (i_instrtype is null) then
	    update iby_instrholder
	    set activestatus = 0,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		last_update_login = fnd_global.login_id
	    where ownertype = i_ownertype
	    and ownerid = i_ownerid
	    and activestatus = 1
	    and instrid = i_instrid;
	else
	    update iby_instrholder
	    set activestatus = 0,
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		last_update_login = fnd_global.login_id
	    where ownertype = i_ownertype
	    and ownerid = i_ownerid
	    and instrtype = i_instrtype
	    and activestatus = 1
	    and instrid = i_instrid;

	end if;

    if ( sql%notfound ) then
        raise_application_error(-20000, 'IBY_20511#', FALSE);
        --raise_application_error(-20511, 'User does not hold instr', FALSE);
    elsif ( sql%rowcount <> 1 ) then
        raise_application_error(-20000, 'IBY_20000#', FALSE);
        --raise_application_error(-20000, ' Rows ' || sql%rowcount || ' matched, so not deleting ', FALSE);
    end if;
    commit;
end deleteHolderInstr;

procedure getHolderinstr( i_ecappid in iby_ecapp.ecappid%type,
                          i_hld_type in iby_instrholder.ownertype%type,
                          i_hld_id in iby_instrholder.ownerid%type,
                          o_instr_type out nocopy iby_instrholder.instrtype%type,
                          o_instr_id out nocopy iby_instrholder.instrid%type)
is
cursor c_holderinstr(ci_hld_type in iby_instrholder.ownertype%type,
                    ci_hld_id in iby_instrholder.ownerid%type) is
select instrtype, instrid
from iby_instrholder
where ci_hld_type = ownertype
and   activestatus = 1
and   ci_hld_id = ownerid;
begin
/*
** close the cursor, if it is open.
*/
    if ( c_holderinstr%isopen ) then
        close c_holderinstr;
    end if;
/*
** open the cursor to extract all the activer records.
*/
    open c_holderinstr(i_hld_type, i_hld_id);

    fetch c_holderinstr into o_instr_type, o_instr_id;
    if ( c_holderinstr%notfound ) then
/*
**   if not instrument matched then raise an error.
*/
        close c_holderinstr;
        raise_application_error(-20000, 'IBY_20512#', FALSE);
        --raise_application_error(-20512, 'No instrument Matched ', FALSE);
    end if;
    close c_holderinstr;
end getHolderInstr;
/*
** Procedure: deleteInstr.
** Purpose: marks the record identified by the ownerid, ownertype and
**          instrid as inactivated.
*/
procedure deleteInstr( i_ecappid in iby_ecapp.ecappid%type,
                       i_ownertype in iby_instrholder.ownertype%type,
                       i_ownerid in iby_instrholder.ownerid%type,
                       i_instrid in iby_instrholder.instrid%type)
is
begin

	-- we don't care what type of instrment it is, just delete it
         deleteHolderInstr(i_ecappid, i_ownertype, i_ownerid, null,
                           i_instrid);

end deleteInstr;
end iby_instrholder_pkg;

/
