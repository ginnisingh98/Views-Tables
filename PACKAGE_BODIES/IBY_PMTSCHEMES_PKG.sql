--------------------------------------------------------
--  DDL for Package Body IBY_PMTSCHEMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PMTSCHEMES_PKG" as
/*$Header: ibypmscb.pls 120.2 2005/10/30 05:48:54 appldev ship $*/

/*
** Procedure: checkPmtSchemes.
** Purpose:  get payment scheme id based on scheme name,
**		from fnd_lookup table, raise exception
**		if scheme doesn't exist
*/
procedure checkPmtScheme( i_pmtschemename in
			iby_pmtschemes.pmtschemename%type,
                        io_pmtschemeid  in out nocopy
			iby_pmtschemes.pmtschemeid%type)
is

/*
l_pmtschemeid iby_pmtschemes.pmtschemeid%type;
cursor c_get_pmtschemeid(ci_pmtschemename
			iby_pmtschemes.pmtschemename%type)
is
SELECT lookup_code
FROM fnd_lookups
WHERE lookup_type = 'IBY_PMTSCHEMES'
AND meaning = ci_pmtschemename;
*/

begin
-- new code, hardcoded version

IF (i_pmtschemename = 'SSL') THEN
    io_pmtschemeid := 2;
ELSIF (i_pmtschemename = 'BANKACCOUNT') THEN
    io_pmtschemeid := 4;
ELSIF (i_pmtschemename = 'PURCHASECARD') THEN
    io_pmtschemeid := 5;
ELSIF (i_pmtschemename = 'FINANCING') THEN
    io_pmtschemeid := 6;
ELSIF (i_pmtschemename = 'BANKPAYMENT') THEN
    io_pmtschemeid := 7;
ELSIF (i_pmtschemename = 'PINLESSDEBITCARD') THEN
    io_pmtschemeid := 8;
ELSIF (i_pmtschemename = 'SET') THEN	-- keep SET here for now
    io_pmtschemeid := 1;
ELSE
	-- FI no longer supported
     raise_application_error(-20000, 'IBY_20570#', FALSE);
END IF;

/*
** close the cursor if it is already open.
*/
/*
    if ( c_get_pmtschemeid%isopen ) then
        close c_get_pmtschemeid;
    end if;
*/
/*
** open the cursor and check if the corresponding name exists in the
** database.
*/
/*
    open c_get_pmtschemeid(i_pmtschemename);
    fetch c_get_pmtschemeid into l_pmtschemeid;
    if ( c_get_pmtschemeid%notfound ) then
        raise_application_error(-20000, 'IBY_20570#', FALSE);
        --raise_application_error(-20570, 'Payment Scheme is not
	--Defined',FALSE);
    end if;
    io_pmtschemeid := l_pmtschemeid;
    close c_get_pmtschemeid;
*/
    --commit;
end checkPmtScheme;

/* Procedure: getPmtSchemeName
** Purpose: return pmt scheme name based on bepid
**	for single entry, whatever in the table
**	for double entry, return 'BOTH' ('SSL' and 'BANKACCOUNT')
*/
procedure getPmtSchemeName(i_bepid in iby_pmtschemes.bepid%type,
	              o_pmtschemeName out nocopy JTF_VARCHAR2_TABLE_100)
		--o_pmtschemename out nocopy iby_pmtschemes.pmtschemename%type)
IS

CURSOR c_get_pmtschemeName(ci_bepid in iby_pmtschemes.bepid%type)
IS
SELECT pmtschemename
FROM iby_pmtschemes
WHERE bepid = i_bepid;

l_index number;
l_pmtschemename varchar(30);

BEGIN
	if (c_get_pmtschemeName%isopen) then
	   close c_get_pmtschemeName;
	end if;

	open c_get_pmtschemeName(i_bepid);

	if (c_get_pmtschemeName%notfound) then
	   -- should never happen, if called from iby_bepinfo_pkg
	   -- no row matches, invalid bepid or object version number
	       close c_get_pmtschemeName;
	       raise_application_error(-20000, 'IBY_20521#', FALSE);
	end if;

	o_pmtschemeName := JTF_VARCHAR2_TABLE_100();
	--o_pmtschemeName.extend(c_get_pmtschemeName%count);

	--dbms_output.put_line('rowcount is ' || c_get_pmtschemeName%rowcount);

	l_index := 1;

	Loop
	   o_pmtschemeName.extend(1);
	   --dbms_output.put_line('l_index is ' || l_index);
	   fetch c_get_pmtschemename into l_pmtschemename;
	   --dbms_output.put_line('l_pmtschemename is ' || l_pmtschemename);
	   o_pmtschemename(l_index) := l_pmtschemename;
	   l_index := l_index + 1;
	   exit when c_get_pmtschemename%notfound;
	END LOOP;
	close c_get_pmtschemeName;

end getPmtSchemeName;



/* Procedure: createPmtScheme
** Purpose: replace whatever previous existing pmtscheme with new ones
**	for a given bepid
*/
procedure createPmtScheme(i_bepid in iby_pmtschemes.bepid%type,
	              i_pmtschemeName in JTF_VARCHAR2_TABLE_100)
IS

l_count number;
l_pmtschemeid number;

BEGIN
	DELETE FROM iby_pmtschemes
	WHERE bepid = i_bepid;

	for l_count in 1..i_pmtschemeName.count LOOP
		-- get pmtschemeid
		 checkPmtScheme( i_pmtschemename(l_count), l_pmtschemeid);

		-- insertion
		INSERT INTO iby_pmtschemes
			(bepid, pmtschemeid, pmtschemename,
			last_update_date, last_updated_by, creation_date,
			created_by, last_update_login, object_version_number)
		VALUES (i_bepid, l_pmtschemeid, i_pmtschemename(l_count),
			 sysdate, fnd_global.user_id,  sysdate,
			fnd_global.user_id, fnd_global.login_id, 1);
	END LOOP;

end createPmtScheme;

end iby_pmtschemes_pkg;

/
