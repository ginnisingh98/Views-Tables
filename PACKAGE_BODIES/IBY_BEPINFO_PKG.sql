--------------------------------------------------------
--  DDL for Package Body IBY_BEPINFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_BEPINFO_PKG" as
/*$Header: ibybepib.pls 115.18 2002/11/16 00:40:23 jleybovi ship $*/


g_pkg_name  CONSTANT VARCHAR2(30) := 'IBY_BEPINFO_PKG';

/*
** Function:suffixExists.
** Purpose: Check if suffix already exists
**
*/
function suffixExists (i_bepsuffix in iby_bepinfo.suffix%type,
         i_bepid in iby_bepinfo.bepid%type )
         -- when bepid is -1, we are adding a new one
         -- otherwise it's update for an existing one
return boolean

is
l_flag boolean := false;
l_bepsuffix iby_bepinfo.suffix%type;

cursor c_bep(ci_bepsuffix in iby_bepinfo.suffix%type,
      ci_bepid in iby_bepinfo.bepid%type) is
SELECT suffix
FROM iby_bepinfo
WHERE suffix = ci_bepsuffix AND
   bepid <> ci_bepid;
begin
   if ( c_bep%isopen) then
        close c_bep;
    end if;
/*
** open the cursor, which retrieves all the rows
*/
    open c_bep(i_bepsuffix, i_bepid);
    fetch c_bep into l_bepsuffix;
/*
**  if bep suffix already exist then return true otherwise flase.
*/
    l_flag := c_bep%found;

    close c_bep;
    return l_flag;
end suffixExists;



/*
** Function: bepNameExists.
** Purpose: Check if any bep Name already exists in the system.
*/
function bepNameExists (i_bepname in iby_bepinfo.name%type,
         i_bepid in iby_bepinfo.bepid%type )
         -- when bepid is -1, we are adding a new one
         -- otherwise it's update for an existing one
return boolean
is
l_flag boolean := false;
l_bepname iby_bepinfo.name%type;
cursor c_bep(ci_bepname in iby_bepinfo.name%type,
      ci_bepid in iby_bepinfo.bepid%type) is
SELECT name
FROM  iby_bepinfo
WHERE name = ci_bepname AND
   bepid <> ci_bepid;

begin
    if ( c_bep%isopen) then
        close c_bep;
    end if;
/*
** open the cursor, which retrieves all the rows
*/
    open c_bep(i_bepname, i_bepid);
    fetch c_bep into l_bepname;
/*
**  if bep name already exist then return true otherwise flase.
*/
    l_flag := c_bep%found;

    close c_bep;
    return l_flag;
end bepNameExists;

/*
** Procedure: createBEPInfo
** Purpose:  Creates an entry in the iby_bepinfo table and assigns an id
**           to identify it.
** Parameters:  bepname, name of the bep, bepurl, url of the bep
**              bepusername, username to be used to logon to bep,
**              beppassword, password for bepusername,
**              psusername, username to be used by bep when it call ps
**              catridge, pspassword, psusernames password.
**              login and lout urls for BEP, if any.
**              beptype is type of the bep. It could be OFX, creditcard,etc.
**              modsupport, cancsupport, identifies whether bep supports them
**              or not. srvridimmed, whether a server id is returned
**              immediately for a payment or not.
**              leadtime is the time that a payment should be scheduled.
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
                      i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type,
                      i_holidayfile in iby_bepinfo.holidayfile%type,
                      i_fileSupport in iby_bepinfo.fileSupport%type,
                      i_activestatus in iby_bepinfo.activestatus%type,
            i_securityscheme in iby_bepinfo.securityscheme%type,
                      i_partyid in NUMBER,
                      i_preNLSLang in iby_beplangs.beplang%type,
                      i_opt1NLSLang in iby_beplangs.beplang%type,
                      i_opt2NLSLang in iby_beplangs.beplang%type,
                      io_bepid in out nocopy iby_bepinfo.bepid%type)
is
l_instrtype iby_bepinfo.instrtype%type;

cursor c_bepid is
SELECT to_char(iby_bep_s.nextval) FROM dual;

begin

/*
** error checking, make BEP doesn't already exist, both BEP NAME, and
** SUFFIX has to be unique, and paymentscheme name has to exist
*/

/*
** DB constraints are case sensitive, 'Cybercash' and 'cyBerCash' are
** considered DIFFERENT entries.
** All suffix will be 3-letter code in lower case, ensured in Java layer
*/


   if (bepNameExists(i_bepname, -1)) then
       --raise_application_error(-20524, 'BEP name already exists...',FALSE);
       raise_application_error(-20000, 'IBY_20524#', FALSE);
   end if;

   if (suffixExists(i_bepsuffix, -1)) then
       raise_application_error(-20000, 'IBY_20525#', FALSE);
       --raise_application_error(-20525, 'Suffix already exists...',FALSE);
   end if;

/*  obtain the new bep id
**  close the cursor if it is already open.
**  open the cursor and get the next sequence number.
*/
    if ( c_bepid%isopen ) then
        close c_bepid;
    end if;
    open c_bepid;
    fetch c_bepid into io_bepid;

/*
** It's a new BEP, insert information into iby_bepinfo.
*/
  INSERT INTO iby_bepinfo ( bepid, name, bepusername, beppassword, psusername,
                            pspassword, baseurl, suffix, bep_type,
                            supportedop, adminurl, loginurl, logouturl,
                            leadtime, srvrIdImmed, holidayfile,
                            filesupport, activestatus,
             instrtype, securityscheme, party_id,
             last_update_date, last_updated_by,
             creation_date, created_by,
             last_update_login, object_version_number)
   VALUES ( io_bepid, i_bepname, i_bepusername, i_beppassword, i_psusername,
             i_pspassword, i_bepurl, i_bepsuffix, i_bep_type, i_supportedop,
             i_adminurl,  i_login, i_logout,
             i_leadtime, i_srvrIdImmed, i_holidayfile,
        i_fileSupport, i_activeStatus,
        l_instrtype, i_securityscheme, i_partyid,
        sysdate, fnd_global.user_id,
        sysdate, fnd_global.user_id,
      fnd_global.login_id, 1);

    close c_bepid;

    -- create pmt scheme info
    -- Add check to create Payment Scheme only if input is not null
    -- FZ 5/20/02
    IF i_pmtschemename IS NOT NULL THEN
      iby_pmtschemes_pkg.createPmtScheme(io_bepid, i_pmtschemename);
    END IF;

    --create NLS Languages.
    iby_beplangs_pkg.createBEPLangs(io_bepid, i_preNLSLang,
                                   i_opt1NLSLang, i_opt2NLSLang);

    commit;

end createBEPInfo;




-- This wrapper version is to handle FND_API.G_MISS_XXX
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
  i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type,
  i_holidayfile in iby_bepinfo.holidayfile%type,
  i_fileSupport in iby_bepinfo.fileSupport%type,
  i_activestatus in iby_bepinfo.activestatus%type,
  i_securityscheme in iby_bepinfo.securityscheme%type,
  i_partyid in NUMBER,
  i_preNLSLang in iby_beplangs.beplang%type,
  i_opt1NLSLang in iby_beplangs.beplang%type,
  i_opt2NLSLang in iby_beplangs.beplang%type,
  io_bepid in out nocopy iby_bepinfo.bepid%type)

is

  l_bepname              iby_bepinfo.name%type;
  l_bepurl               iby_bepinfo.baseurl%type;
  l_bepsuffix            iby_bepinfo.suffix%type;
  l_bep_type             iby_bepinfo.bep_type%type;
  l_bepusername          iby_bepinfo.bepusername%type;
  l_beppassword          iby_bepinfo.beppassword%type;
  l_psusername           iby_bepinfo.psusername%type;
  l_pspassword           iby_bepinfo.pspassword%type;
  l_adminurl             iby_bepinfo.adminurl%type;
  l_login                iby_bepinfo.loginurl%type;
  l_logout               iby_bepinfo.logouturl%type;
  l_supportedop          iby_bepinfo.supportedOp%type;
  l_leadtime             iby_bepinfo.leadtime%type;
  l_srvrIdImmed          iby_bepinfo.srvrIdImmed%type DEFAULT 'Y';
  l_holidayfile          iby_bepinfo.holidayfile%type DEFAULT 'N';
  l_fileSupport          iby_bepinfo.fileSupport%type DEFAULT 'N';
  l_activestatus         iby_bepinfo.activestatus%type DEFAULT 'Y';
  l_securityscheme       iby_bepinfo.securityscheme%type;
  l_partyid              NUMBER;
  l_preNLSLang           iby_beplangs.beplang%type;
  l_opt1NLSLang          iby_beplangs.beplang%type;
  l_opt2NLSLang          iby_beplangs.beplang%type;

begin

  l_bepname := i_bepname;
  IF l_bepname = FND_API.G_MISS_CHAR THEN
    l_bepname := NULL;
  END IF;

  l_bepurl := i_bepurl;
  IF l_bepurl = FND_API.G_MISS_CHAR THEN
    l_bepurl := NULL;
  END IF;

  l_bepsuffix := i_bepsuffix;
  IF l_bepsuffix = FND_API.G_MISS_CHAR THEN
    l_bepsuffix := NULL;
  END IF;

  l_bep_type := i_bep_type;
  IF l_bep_type = FND_API.G_MISS_CHAR THEN
    l_bep_type := NULL;
  END IF;

  l_bepusername := i_bepusername;
  IF l_bepusername = FND_API.G_MISS_CHAR THEN
    l_bepusername := NULL;
  END IF;

  l_beppassword := i_beppassword;
  IF l_beppassword = FND_API.G_MISS_CHAR THEN
    l_beppassword := NULL;
  END IF;

  l_psusername := i_psusername;
  IF l_psusername = FND_API.G_MISS_CHAR THEN
    l_psusername := NULL;
  END IF;

  l_pspassword := i_pspassword;
  IF l_pspassword = FND_API.G_MISS_CHAR THEN
    l_pspassword := NULL;
  END IF;

  l_adminurl := i_adminurl;
  IF l_adminurl = FND_API.G_MISS_CHAR THEN
    l_adminurl := NULL;
  END IF;

  l_login := i_login;
  IF l_login = FND_API.G_MISS_CHAR THEN
    l_login := NULL;
  END IF;

  l_logout := i_logout;
  IF l_logout = FND_API.G_MISS_CHAR THEN
    l_logout := NULL;
  END IF;

  l_supportedop := i_supportedop;
  IF l_supportedop = FND_API.G_MISS_NUM THEN
    l_supportedop := NULL;
  END IF;

  l_leadtime := i_leadtime;
  IF l_leadtime = FND_API.G_MISS_NUM THEN
    l_leadtime := NULL;
  END IF;

  l_srvrIdImmed := i_srvrIdImmed;
  IF l_srvrIdImmed = FND_API.G_MISS_CHAR THEN
    l_srvrIdImmed := NULL;
  END IF;

  l_holidayfile := i_holidayfile;
  IF l_holidayfile = FND_API.G_MISS_CHAR THEN
    l_holidayfile := NULL;
  END IF;

  l_fileSupport := i_fileSupport;
  IF l_fileSupport = FND_API.G_MISS_CHAR THEN
    l_fileSupport := NULL;
  END IF;

  l_activestatus := i_activestatus;
  IF l_activestatus = FND_API.G_MISS_CHAR THEN
    l_activestatus := NULL;
  END IF;

  l_securityscheme := i_securityscheme;
  IF l_securityscheme = FND_API.G_MISS_NUM THEN
    l_securityscheme := NULL;
  END IF;

  l_partyid := i_partyid;
  IF l_partyid = FND_API.G_MISS_NUM THEN
    l_partyid := NULL;
  END IF;

  l_preNLSLang := i_preNLSLang;
  IF l_preNLSLang = FND_API.G_MISS_CHAR THEN
    l_preNLSLang := NULL;
  END IF;

  l_opt1NLSLang := i_opt1NLSLang;
  IF l_opt1NLSLang = FND_API.G_MISS_CHAR THEN
    l_opt1NLSLang := NULL;
  END IF;

  l_opt2NLSLang := i_opt2NLSLang;
  IF l_opt2NLSLang = FND_API.G_MISS_CHAR THEN
    l_opt2NLSLang := NULL;
  END IF;

  IF io_bepid = FND_API.G_MISS_NUM THEN
    io_bepid := NULL;
  END IF;

  -- forward the call to the base API
  createBEPInfo(
    i_bepname             => l_bepname,
    i_bepurl              => l_bepurl,
    i_bepsuffix           => l_bepsuffix,
    i_bep_type            => l_bep_type,
    i_bepusername         => l_bepusername,
    i_beppassword         => l_beppassword,
    i_psusername          => l_psusername,
    i_pspassword          => l_pspassword,
    i_adminurl            => l_adminurl,
    i_login               => l_login,
    i_logout              => l_logout,
    i_supportedop         => l_supportedop,
    i_pmtschemeName       => i_pmtschemeName,
    i_leadtime            => l_leadtime,
    i_srvrIdImmed         => l_srvrIdImmed,
    i_holidayfile         => l_holidayfile,
    i_fileSupport         => l_fileSupport,
    i_activestatus        => l_activestatus,
    i_securityscheme      => l_securityscheme,
    i_partyid             => l_partyid,
    i_preNLSLang          => l_preNLSLang,
    i_opt1NLSLang         => l_opt1NLSLang,
    i_opt2NLSLang         => l_opt2NLSLang,
    io_bepid              => io_bepid
  );

end create_BEPInfo;




/*
** Function: modBEPInfo
** Purpose:  modifies the entry in the iby_bepinfo table that matches bepid
**           passed with the values specified.
** Parameters:  bepid, id of the bep, bepname, name of the bep,
**              bepurl, url of the bep
**              bepusername, username to be used to logon to bep,
**              beppassword, password for bepusername,
**              psusername, username to be used by bep when it call ps
**              catridge, pspassword, psusernames password.
**              beptype is type of the bep. It could be OFX, creditcard,etc.
**              modsupport, cancsupport, identifies whether bep supports them
**              or not. srvridimmed, whether a server id is returned
**              immediately for a payment or not.
**              leadtime is the time that a payment should be scheduled.
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
                      i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type,
                      i_holidayfile in iby_bepinfo.holidayfile%type,
                      i_fileSupport in iby_bepinfo.fileSupport%type,
                      i_activestatus in iby_bepinfo.activestatus%type,
            i_securityscheme in iby_bepinfo.securityscheme%type,
                      i_partyid in NUMBER,
                      i_preNLSLang in iby_beplangs.beplang%type,
                      i_opt1NLSLang in iby_beplangs.beplang%type,
                      i_opt2NLSLang in iby_beplangs.beplang%type,
      i_object_version in iby_bepinfo.object_version_number%type)
is

l_instrtype iby_bepinfo.instrtype%type;

begin

   -- check for the bep name/suffix uniqueness before update
   -- this check is not needed in terms of functionality since there are
   -- unique constraints in DB already, however, it will give better
   -- clear error messages

   if (bepNameExists(i_bepname, i_bepid)) then
       --raise_application_error(-20524, 'BEP name already exists...',FALSE);
       raise_application_error(-20000, 'IBY_20524#', FALSE);
   end if;

   if (suffixExists(i_bepsuffix, i_bepid)) then
       raise_application_error(-20000, 'IBY_20525#', FALSE);
       --raise_application_error(-20525, 'Suffix already exists...',FALSE);
   end if;


/*
** update the row that matches the bepid;
*/
    UPDATE iby_bepinfo
    SET name = i_bepname,
        bepusername = i_bepusername,
        beppassword = i_beppassword,
        psusername = i_psusername,
        pspassword = i_pspassword,
        baseurl = i_bepurl,
        suffix = i_bepsuffix,
        bep_type = i_bep_type,
        adminurl = i_adminurl,
        loginurl = i_login,
        logouturl = i_logout,
        supportedop = i_supportedop,
        leadtime = i_leadtime,
        srvrIdImmed = i_srvrIdImmed,
        holidayfile = i_holidayfile,
        filesupport = i_fileSupport,
        activeStatus = i_activeStatus,
   instrtype = l_instrtype,
   securityscheme = i_securityscheme,
        party_id = i_partyid,
      last_update_date = sysdate,
   last_updated_by = fnd_global.user_id,
   last_update_login = fnd_global.login_id,
   object_version_number = object_version_number + 1
    WHERE bepid = i_bepid
   AND  object_version_number = i_object_version;

    if ( sql%notfound ) then
   -- no row matches, invalid bepid or object version number
       raise_application_error(-20000, 'IBY_20521#', FALSE);
   -- no need to worry about mulitple matches since 'bepid' is unique
    end if;


    -- replace pmt scheme info
    iby_pmtschemes_pkg.createPmtScheme(i_bepid, i_pmtschemename);

    -- replace NLS Languages.
    iby_beplangs_pkg.createBEPLangs(i_bepid, i_preNLSLang,
                                   i_opt1NLSLang, i_opt2NLSLang);
    commit;
end modbepinfo;





-- This is similar to modBEPInfo(), however we add code to
-- to handle FND_API.G_MISS_XXX
-- As we add this as a new independent API, we also add the
-- missing param for IBY_BEPINFO.INSTRTYPE
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
  i_srvrIdImmed in iby_bepinfo.srvrIdImmed%type,
  i_holidayfile in iby_bepinfo.holidayfile%type,
  i_fileSupport in iby_bepinfo.fileSupport%type,
  i_activestatus in iby_bepinfo.activestatus%type,
  i_securityscheme in iby_bepinfo.securityscheme%type,
  i_partyid in NUMBER,
  i_preNLSLang in iby_beplangs.beplang%type,
  i_opt1NLSLang in iby_beplangs.beplang%type,
  i_opt2NLSLang in iby_beplangs.beplang%type,
  i_object_version in iby_bepinfo.object_version_number%type)

is
  l_api_name                CONSTANT  VARCHAR2(30) := 'update_BEPInfo';

begin

  -- bepid must not be null or FND_API.G_MISS_NUM
  IF (i_bepid IS NULL) OR (i_bepid = FND_API.G_MISS_NUM) THEN
    fnd_message.set_name('IBY', 'IBY_G_INVALID_PARAM_ERR');
    fnd_message.set_token('API', g_pkg_name || '.' || l_api_name);
    fnd_message.set_token('PARAM', 'i_bepid: ' || i_bepid);
    fnd_message.set_token('REASON', 'Incorrect param value');
    fnd_msg_pub.add;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- object_version_number must not be null or FND_API.G_MISS_NUM
  -- for update API
  IF (i_object_version IS NULL) OR (i_object_version = FND_API.G_MISS_NUM) THEN
    fnd_message.set_name('IBY', 'IBY_G_INVALID_PARAM_ERR');
    fnd_message.set_token('API', g_pkg_name || '.' || l_api_name);
    fnd_message.set_token('PARAM', 'i_object_version: ' || i_object_version);
    fnd_message.set_token('REASON', 'Incorrect param value');
    fnd_msg_pub.add;

    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- check for the bep name/suffix uniqueness before update
  -- this check is not needed in terms of functionality since there are
  -- unique constraints in DB already, however, it will give better
  -- clear error messages

  -- these validation are still valid, keep them
  -- however they are incomplete - they do not check against
  -- FND_API.G_MISS_CHAR for these mandatory columns
  -- we will add additional checks below
  -- FZ 5/20/02
  if (bepNameExists(i_bepname, i_bepid)) then
    --raise_application_error(-20524, 'BEP name already exists...',FALSE);
    raise_application_error(-20000, 'IBY_20524#', FALSE);
  end if;

  if (suffixExists(i_bepsuffix, i_bepid)) then
    raise_application_error(-20000, 'IBY_20525#', FALSE);
    --raise_application_error(-20525, 'Suffix already exists...',FALSE);
  end if;


  -- by the new App standard, if input is FND_API.G_MISS_CHAR
  -- in update API, it means the caller wants to set the field
  -- to null. However IBY_BEPINFO.NAME is a not null column
  -- note it's ok for the input param to be null. In that case
  -- the existing value in db is retained
  IF i_bepname = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name('IBY', 'IBY_G_INVALID_PARAM_ERR');
    fnd_message.set_token('API', g_pkg_name || '.' || l_api_name);
    fnd_message.set_token('PARAM', 'i_bepname: FND_API.G_MISS_CHAR');
    fnd_message.set_token('REASON', 'Incorrect param value');
    fnd_msg_pub.add;

    RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- by the new App standard, if input is FND_API.G_MISS_CHAR
  -- in update API, it means the caller wants to set the field
  -- to null. However IBY_BEPINFO.SUFFIX is a not null column
  -- note it's ok for the input param to be null. In that case
  -- the existing value in db is retained
  IF i_bepsuffix = FND_API.G_MISS_CHAR THEN
    fnd_message.set_name('IBY', 'IBY_G_INVALID_PARAM_ERR');
    fnd_message.set_token('API', g_pkg_name || '.' || l_api_name);
    fnd_message.set_token('PARAM', 'i_bepsuffix: FND_API.G_MISS_CHAR');
    fnd_message.set_token('REASON', 'Incorrect param value');
    fnd_msg_pub.add;

    RAISE FND_API.G_EXC_ERROR;
  END IF;


  -- update the row that matches the bepid;
  -- should use OVN based locking
  UPDATE IBY_BEPINFO  SET
    name              = DECODE(i_bepname, NULL, name, i_bepname),
    suffix            = DECODE(i_bepsuffix, NULL, suffix, i_bepsuffix),
    bepusername       = DECODE(i_bepusername, NULL, bepusername, FND_API.G_MISS_CHAR, NULL, i_bepusername),
    beppassword       = DECODE(i_beppassword, NULL, beppassword, FND_API.G_MISS_CHAR, NULL, i_beppassword),
    psusername        = DECODE(i_psusername, NULL, psusername, FND_API.G_MISS_CHAR, NULL, i_psusername),
    pspassword        = DECODE(i_pspassword, NULL, pspassword, FND_API.G_MISS_CHAR, NULL, i_pspassword),
    baseurl           = DECODE(i_bepurl, NULL, baseurl, FND_API.G_MISS_CHAR, NULL, i_bepurl),
    bep_type          = DECODE(i_bep_type, NULL, bep_type, FND_API.G_MISS_CHAR, NULL, i_bep_type),
    adminurl          = DECODE(i_adminurl, NULL, adminurl, FND_API.G_MISS_CHAR, NULL, i_adminurl),
    loginurl          = DECODE(i_login, NULL, loginurl, FND_API.G_MISS_CHAR, NULL, i_login),
    logouturl         = DECODE(i_logout, NULL, logouturl, FND_API.G_MISS_CHAR, NULL, i_logout),
    supportedop       = DECODE(i_supportedop, NULL, supportedop, FND_API.G_MISS_NUM, NULL, i_supportedop),
    leadtime          = DECODE(i_leadtime, NULL, leadtime, FND_API.G_MISS_NUM, NULL, i_leadtime),
    srvrIdImmed       = DECODE(i_srvrIdImmed, NULL, srvrIdImmed, FND_API.G_MISS_CHAR, NULL, i_srvrIdImmed),
    holidayfile       = DECODE(i_holidayfile, NULL, holidayfile, FND_API.G_MISS_CHAR, NULL, i_holidayfile),
    filesupport       = DECODE(i_fileSupport, NULL, filesupport, FND_API.G_MISS_CHAR, NULL, i_fileSupport),
    activeStatus      = DECODE(i_activeStatus, NULL, activeStatus, FND_API.G_MISS_CHAR, NULL, i_activeStatus),
    -- instrtype         = DECODE(p_instr_type, NULL, instrtype, FND_API.G_MISS_CHAR, NULL, p_instr_type),
    securityscheme    = DECODE(i_securityscheme, NULL, securityscheme, FND_API.G_MISS_NUM, NULL, i_securityscheme),
    party_id          = DECODE(i_partyid, NULL, party_id, FND_API.G_MISS_CHAR, NULL, i_partyid),
    last_update_date  = SYSDATE,
    last_updated_by   = fnd_global.user_id,
    last_update_login = fnd_global.login_id,
    object_version_number = object_version_number + 1
  WHERE bepid = i_bepid
   AND object_version_number = i_object_version;

  if ( sql%notfound ) then
   -- no row matches, invalid bepid or object version number
    raise_application_error(-20000, 'IBY_20521#', FALSE);
   -- no need to worry about mulitple matches since 'bepid' is unique
  end if;

  -- right now we don't have an update API for the iby_pmtschemes_pkg
  -- the logic in modbepinfo() is to simply overwrite the existing
  -- payment scheme definition. This is too simplistic. We need to
  -- have a better solution. For now we skip the payment schemes
  -- and BEP langs update, as there are no business requirement
  -- at this point.

    -- replace NLS Languages.
    iby_beplangs_pkg.createBEPLangs(i_bepid, i_preNLSLang,
                                   i_opt1NLSLang, i_opt2NLSLang);
  commit;

end update_BEPInfo;




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
      o_object_version out nocopy iby_bepinfo.object_version_number%type)
is

cursor c_bepinfo(ci_bepid in iby_bepinfo.bepid%type) is
SELECT name, baseurl, suffix, bep_type, bepusername, beppassword,
   supportedop, psusername, pspassword,
       adminurl, loginurl, logouturl, leadtime, holidayfile,
       srvridimmed, filesupport, activestatus,
   securityscheme, party_id, object_version_number
FROM iby_bepinfo
WHERE bepid = ci_bepid;

cursor c_preNLSLang(ci_bepid in iby_bepinfo.bepid%type) is
SELECT beplang
FROM iby_beplangs
WHERE bepid = ci_bepid
AND preferred = 0;

cursor c_opt1NLSLang(ci_bepid in iby_bepinfo.bepid%type) is
SELECT beplang
FROM iby_beplangs
WHERE bepid = ci_bepid
AND preferred = 1;

cursor c_opt2NLSLang(ci_bepid in iby_bepinfo.bepid%type) is
SELECT beplang
FROM iby_beplangs
WHERE bepid = ci_bepid
AND preferred = 2;

begin
    if ( c_bepinfo%isopen ) then
         close c_bepinfo;
    end if;
    open c_bepinfo(i_Bepid);
    fetch c_bepinfo into o_bepname, o_bepurl, o_bepsuffix, o_bep_type,
                         o_bepusername,
                         o_beppassword,
         o_supportedop,
                         o_psusername, o_pspassword, o_adminurl,
                         o_login, o_logout, o_leadtime,
                         o_holidayfile, o_srvrIdImmed, o_filesupport,
                         o_activestatus,
         o_securityscheme, o_partyid,
         o_object_version;

    if ( c_bepinfo%notfound ) then
   -- no row matched, invalid bepid or object version number
       raise_application_error(-20000, 'IBY_20521#', FALSE);
    end if;

    close c_bepinfo;

    -- get pmtscheme name based on bepid
    iby_pmtschemes_pkg.getPmtSchemeName(i_bepid, o_pmtschemeName);

    if ( c_preNLSLang%isopen ) then
         close c_preNLSLang;
    end if;
    open c_preNLSLang(i_bepid);
    fetch c_preNLSLang into o_preNLSLang;
    close c_preNLSLang;

    if ( c_opt1NLSLang%isopen ) then
         close c_opt1NLSLang;
    end if;
    open c_opt1NLSLang(i_bepid);
    fetch c_opt1NLSLang into o_opt1NLSLang;
    close c_opt1NLSLang;

    if ( c_opt2NLSLang%isopen ) then
         close c_opt2NLSLang;
    end if;
    open c_opt2NLSLang(i_bepid);
    fetch c_opt2NLSLang into o_opt2NLSLang;
    close c_opt2NLSLang;
end;


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
procedure  setBEPStatus(i_bepid in iby_bepinfo.bepid%type,
                   i_status in iby_bepinfo.activestatus%type,
                     o_flag out nocopy int)
is

begin

    o_flag := 0;

    UPDATE iby_bepinfo
    SET activestatus = i_status,
    last_update_date = sysdate,
    last_updated_by = fnd_global.user_id,
    last_update_login = fnd_global.login_id,
    object_version_number = object_version_number + 1
    WHERE bepid = i_bepid;
   -- can't check object version here, as old API didn't ask for
   -- object_version, simply increment it
   ---AND  object_version_number = i_object_version;

    if ( sql%notfound ) then
   -- no row matches, invalid bepid or object version number
       raise_application_error(-20000, 'IBY_20521#', FALSE);
   -- no need to worry about mulitple matches since 'bepid' is unique
    end if;

    o_flag := 1;
    commit;
end setBEPStatus;

/*
** Function: getBepName
** Purpose: return the bep name that matches the id passed
*/

function getBEPName(i_id iby_bepinfo.bepid%type)
return varchar
is

l_bepname iby_bepinfo.name%type;

cursor c_bep(ci_id iby_bepinfo.bepid%type)
is
SELECT name
FROM iby_bepinfo
WHERE bepid = ci_id;

BEGIN
   IF (c_bep%isopen) THEN
      close c_bep;
   END IF;

   open c_bep(i_id);
      fetch c_bep into l_bepname;

      if ( c_bep%notfound ) then
         l_bepname := null;
   end if;
      close c_bep;
      return l_bepname;
end getBEPName;


/*
** Function: getBEPId.
** Purpose: returnt the bep id that matches the name passed.
*/
function getBEPId(i_name iby_bepinfo.name%type)
return int
is

l_flag boolean := false;
l_bepid iby_bepinfo.bepid%type;

cursor c_bep(ci_name iby_bepinfo.name%type)
is
select bepid
from iby_bepinfo
where name = ci_name;

begin

    if ( c_bep%isopen) then
        close c_bep;
    end if;
/*
** open the cursor, which retrieves all the rows
*/
    open c_bep(i_name);
    fetch c_bep into l_bepid;
/*
**  if bep does not exist then return error value.
*/
    if ( c_bep%notfound ) then
         l_bepid := -99;
    end if;
    close c_bep;
    return l_bepid;
end getBEPId;



end iby_bepinfo_pkg;

/
