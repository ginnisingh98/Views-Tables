--------------------------------------------------------
--  DDL for Package Body FND_CONCURRENT_FILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONCURRENT_FILE" as
/* $Header: AFCPFIDB.pls 115.2 99/08/08 20:19:53 porting ship $ */
function get_file_id return varchar2
is
fuid	number;
fcrc	number;
frand	number;
fid	number;
rval	varchar2(32);
rtemp 	varchar2(32);
begin

	select fnd_s_file_temp_id.nextval
		into fuid
		from dual;

	-- Get a random number
	fnd_random_pkg.init(7);
	fnd_random_pkg.seed(to_number(to_char(sysdate, 'JSSSSS')), 10, false);
	frand := fnd_random_pkg.get_next;

	-- Compute CRC32 of the random number and the sequence number,
	-- this creates a self-checking value.
	rval := lpad(to_char(frand),10,'0')||lpad(to_char(fuid),10,'0');
	fcrc := fnd_hash_pkg.crc32(rval);

	-- XOR the sequence and random values with whatever we have
	-- lying around.  This make our algorithm more obscure,
	-- since sequence values and pseudorandom numbers are no longer
	-- obvious to an observer.
	fuid := fnd_hash_pkg.xor32(fuid, frand);
	frand := fnd_hash_pkg.xor32(fcrc, frand);

	-- this value will be unique
	fid := fcrc * power(2,64) + frand * power(2,32) + fuid;

	-- base 64
	rval := fnd_code_pkg.base64(fid, 16);
	rtemp := rval;

	-- and finally encrypt it all with RC4...actually we now use CRC Hash
-- rval := fnd_crypt_pkg.encrypt('4237533241', rval, 16);
        rval := to_char(icx_call.CRCHASH('4237533241',rval));
	return rval;

end get_file_id;

end;

/
