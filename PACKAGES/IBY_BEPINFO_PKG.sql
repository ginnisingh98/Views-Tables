--------------------------------------------------------
--  DDL for Package IBY_BEPINFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BEPINFO_PKG" AUTHID CURRENT_USER as
/*$Header: ibybepis.pls 115.17 2003/12/19 20:32:33 jleybovi ship $*/

  -- constants for IBY_BEPINFO.BEP_TYPE
  --
  C_BEPTYPE_GATEWAY CONSTANT VARCHAR2(20) := 'GATEWAY';
  C_BEPTYPE_PROCESSOR CONSTANT VARCHAR2(20) := 'PROCESSOR';


/*
** Name : iby_bepinfo_pkg.
** Purpose : This package creates or deletes Back end processor entry in
**           BEP Table.
*/

/*
** Function: SuffixExists.
** Purpose: Check if suffix with the same name already exists in the system.
*/
function suffixExists (i_bepsuffix in iby_bepinfo.suffix%type,
         i_bepid in iby_bepinfo.bepid%type)
return boolean;

/*
** Function: bepNameExists.
** Purpose: Check if any bep Name already exists in the system.
*/
function bepNameExists (i_bepname in iby_bepinfo.name%type,
         i_bepid in iby_bepinfo.bepid%type)
return boolean;

/*
** Procedure Name : createBEPInfo
** Purpose : creates an entry in Back end processor information table.
**           Returns the id created for the entry.
**
** Parameters:
**
**    In  : i_bepname, i_bepurl, i_beptype, i_srvrimm, i_modsupport,
**          i_bepusername, i_beppassword, i_psusername, i_pspassword,
**          i_login, i_logout.
**          i_cancsupport, io_depid
**    Out : io_bepid.
**
*/
procedure createBEPInfo(i_bepname in iby_bepinfo.name%type,
                      i_bepurl in iby_bepinfo.baseurl%type,
                      i_bepsuffix in iby_bepinfo.suffix%type,
                      i_bep_type in iby_bepinfo.bep_type%type,
                      i_bepusername in iby_bepinfo.bepusername%type,
                      i_beppassword in iby_bepinfo.beppassword%type,
                      i_psusername in iby_bepinfo.psusername%type,
                      i_pspassword in iby_bepinfo.pspassword%type,
                      i_adminurl in iby_bepinfo.adminurl%type,
                      i_login in iby_bepinfo.loginurl%type,
                      i_logout in iby_bepinfo.logouturl%type,
                      i_supportedop in iby_bepinfo.supportedOp%type,
                 i_pmtschemeName in JTF_VARCHAR2_TABLE_100,
                      i_leadtime in iby_bepinfo.leadtime%type,
                      i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type DEFAULT 'Y',
                      i_holidayfile in iby_bepinfo.holidayfile%type DEFAULT 'N',
                      i_fileSupport in iby_bepinfo.fileSupport%type DEFAULT 'N',
                      i_activestatus in iby_bepinfo.activestatus%type DEFAULT 'Y',
            i_securityscheme in iby_bepinfo.securityscheme%type,
                      i_partyid in NUMBER,
                      i_preNLSLang in iby_beplangs.beplang%type,
                      i_opt1NLSLang in iby_beplangs.beplang%type,
                      i_opt2NLSLang in iby_beplangs.beplang%type,
                      io_bepid in out nocopy iby_bepinfo.bepid%type);

/*
** Procedure Name : modBEPInfo
** Purpose : modifies an entry in Back end processor information table.
**
** Parameters:
**
**    In  : i_bepid, i_bepname, i_bepurl, i_beptype, i_srvrimm, i_modsupport,
**          i_bepusername, i_beppassword, i_psusername, i_pspassword,
**          i_login, i_logout.
**          i_cancsupport, io_depid
**    Out : io_bepid.
**
*/
procedure    modBEPInfo(i_bepid in iby_bepinfo.bepid%type,
                      i_bepname in iby_bepinfo.name%type,
                      i_bepurl in iby_bepinfo.baseurl%type,
                      i_bepsuffix in iby_bepinfo.suffix%type,
                      i_bep_type in iby_bepinfo.bep_type%type,
                      i_bepusername in iby_bepinfo.bepusername%type,
                      i_beppassword in iby_bepinfo.beppassword%type,
                      i_psusername in iby_bepinfo.psusername%type,
                      i_pspassword in iby_bepinfo.pspassword%type,
                      i_adminurl in iby_bepinfo.adminurl%type,
                      i_login in iby_bepinfo.loginurl%type,
                      i_logout in iby_bepinfo.logouturl%type,
                      i_supportedop in iby_bepinfo.supportedOp%type,
                 i_pmtschemeName in JTF_VARCHAR2_TABLE_100,
                      i_leadtime in iby_bepinfo.leadtime%type,
                      i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type DEFAULT 'Y',
                      i_holidayfile in iby_bepinfo.holidayfile%type DEFAULT 'N',
                      i_fileSupport in iby_bepinfo.fileSupport%type DEFAULT 'N',
                      i_activestatus in iby_bepinfo.activestatus%type DEFAULT 'Y',
            i_securityscheme in iby_bepinfo.securityscheme%type,
                      i_partyid in NUMBER,
                      i_preNLSLang in iby_beplangs.beplang%type,
                      i_opt1NLSLang in iby_beplangs.beplang%type,
                      i_opt2NLSLang in iby_beplangs.beplang%type,
      i_object_version in iby_bepinfo.object_version_number%type);

/*
** Procedure Name : getBEPInfo
** Purpose : retrieves Back end processor information table.
**
** Parameters:
**
**    In  : i_bepid.
**    Out : o_bepname, o_bepurl, o_beptype, o_srvrimm, o_modsupport,
**          o_bepusername, o_beppassword, o_psusername, o_pspassword,
**          o_login, o_logout.
**          o_cancsupport, io_depid
**
*/
procedure    getBEPInfo(i_bepid in iby_bepinfo.bepid%type,
                      o_bepname out nocopy iby_bepinfo.name%type,
                      o_bepurl out nocopy iby_bepinfo.baseurl%type,
                      o_bepsuffix out nocopy iby_bepinfo.suffix%type,
                      o_bep_type out nocopy iby_bepinfo.bep_type%type,
                      o_bepusername out nocopy iby_bepinfo.bepusername%type,
                      o_beppassword out nocopy iby_bepinfo.beppassword%type,
                      o_psusername out nocopy iby_bepinfo.psusername%type,
                      o_pspassword out nocopy iby_bepinfo.pspassword%type,
                      o_adminurl out nocopy iby_bepinfo.adminurl%type,
                      o_login out nocopy iby_bepinfo.loginurl%type,
                      o_logout out nocopy iby_bepinfo.logouturl%type,
                      o_supportedop out nocopy iby_bepinfo.supportedOp%type,
                 o_pmtschemeName out nocopy JTF_VARCHAR2_TABLE_100,
                      o_leadtime out nocopy iby_bepinfo.leadtime%type,
                      o_srvrIdImmed out nocopy iby_bepinfo.srvrIdImmed%type,
                      o_holidayfile out nocopy iby_bepinfo.holidayfile%type,
                      o_fileSupport out nocopy iby_bepinfo.fileSupport%type,
                      o_activestatus out nocopy iby_bepinfo.activestatus%type,
            o_securityscheme out nocopy iby_bepinfo.securityscheme%type,
                      o_partyid out nocopy NUMBER,
                      o_preNLSLang out nocopy iby_beplangs.beplang%type,
                      o_opt1NLSLang out nocopy iby_beplangs.beplang%type,
                      o_opt2NLSLang out nocopy iby_beplangs.beplang%type,
      o_object_version out nocopy iby_bepinfo.object_version_number%type);


/*
** Procedure Name : setBEPStatus
** Purpose : Sets BEP status to the given value.
**
** Parameters:
**
**    In  : i_bepid, i_status.
**    Out : o_flag
**
*/
procedure    setBEPStatus(i_bepid in iby_bepinfo.bepid%type,
                      i_status in iby_bepinfo.activestatus%type,
                      o_flag out nocopy int);


/*
** Function: getBepName
** Purpose: return the bep name that matches the id passed
*/

function getBEPName(i_id iby_bepinfo.bepid%type)
return varchar;

/*
** Function: getBEPId.
** Purpose: returnt he bep id that matches the name passed.
*/
function getBEPId(i_name iby_bepinfo.name%type)
return int;



-- This is a wrapper of createBEPInfo(). It is to handle
-- FND_API.G_MISS_XXX.
-- Note the validation in createBEPInfo() is not enough
-- We should add more to it later. No validation is done
-- in this wrapper.
-- FZ 5/20/02
procedure create_BEPInfo(
  i_bepname in iby_bepinfo.name%type,
  i_bepurl in iby_bepinfo.baseurl%type,
  i_bepsuffix in iby_bepinfo.suffix%type,
  i_bep_type in iby_bepinfo.bep_type%type,
  i_bepusername in iby_bepinfo.bepusername%type,
  i_beppassword in iby_bepinfo.beppassword%type,
  i_psusername in iby_bepinfo.psusername%type,
  i_pspassword in iby_bepinfo.pspassword%type,
  i_adminurl in iby_bepinfo.adminurl%type,
  i_login in iby_bepinfo.loginurl%type,
  i_logout in iby_bepinfo.logouturl%type,
  i_supportedop in iby_bepinfo.supportedOp%type,
  i_pmtschemeName in JTF_VARCHAR2_TABLE_100,
  i_leadtime in iby_bepinfo.leadtime%type,
  i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type DEFAULT 'Y',
  i_holidayfile in iby_bepinfo.holidayfile%type DEFAULT 'N',
  i_fileSupport in iby_bepinfo.fileSupport%type DEFAULT 'N',
  i_activestatus in iby_bepinfo.activestatus%type DEFAULT 'Y',
  i_securityscheme in iby_bepinfo.securityscheme%type,
  i_partyid in NUMBER,
  i_preNLSLang in iby_beplangs.beplang%type,
  i_opt1NLSLang in iby_beplangs.beplang%type,
  i_opt2NLSLang in iby_beplangs.beplang%type,
  io_bepid in out nocopy iby_bepinfo.bepid%type
);



-- This is similar to modBEPInfo(), however we add code to
-- to handle FND_API.G_MISS_XXX
-- FZ 5/20/02
procedure update_BEPInfo(
  i_bepid in iby_bepinfo.bepid%type,
  i_bepname in iby_bepinfo.name%type,
  i_bepurl in iby_bepinfo.baseurl%type,
  i_bepsuffix in iby_bepinfo.suffix%type,
  i_bep_type in iby_bepinfo.bep_type%type,
  i_bepusername in iby_bepinfo.bepusername%type,
  i_beppassword in iby_bepinfo.beppassword%type,
  i_psusername in iby_bepinfo.psusername%type,
  i_pspassword in iby_bepinfo.pspassword%type,
  i_adminurl in iby_bepinfo.adminurl%type,
  i_login in iby_bepinfo.loginurl%type,
  i_logout in iby_bepinfo.logouturl%type,
  i_supportedop in iby_bepinfo.supportedOp%type,
  i_pmtschemeName in JTF_VARCHAR2_TABLE_100,
  i_leadtime in iby_bepinfo.leadtime%type,
  i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type DEFAULT 'Y',
  i_holidayfile in iby_bepinfo.holidayfile%type DEFAULT 'N',
  i_fileSupport in iby_bepinfo.fileSupport%type DEFAULT 'N',
  i_activestatus in iby_bepinfo.activestatus%type DEFAULT 'Y',
  i_securityscheme in iby_bepinfo.securityscheme%type,
  i_partyid in NUMBER,
  i_preNLSLang in iby_beplangs.beplang%type,
  i_opt1NLSLang in iby_beplangs.beplang%type,
  i_opt2NLSLang in iby_beplangs.beplang%type,
  i_object_version in iby_bepinfo.object_version_number%type
);


end iby_bepinfo_pkg;

 

/
