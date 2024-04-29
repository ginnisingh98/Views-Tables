--------------------------------------------------------
--  DDL for Package Body FND_RANDOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RANDOM_PKG" as
/* $Header: AFCPRNDB.pls 120.2 2006/05/18 22:31:44 jnurthen ship $ */

-- This package is now deprecated. Please use the random number packages
-- IN FND_CRYPTO instead.
-- Init, Seed and init_arrays are now no-ops here ias fnd_crypto is self-seeding
-- and get_next simply covers fnd_crypto, returning a number in the same number
-- range as the old get_next from this package.

procedure init( p_length in number)
is
begin
  NULL;

end init;

-- Fnd_crypto takes care of seeding itself
procedure seed(	value	in      number,
		cycles  in      number,
		forced  in      boolean)
is
begin

	NULL;

end seed;

--Get the next pseudorandom number.

function get_next return number is
l_number    number;
XTONUM      CONSTANT VARCHAR2(32) := 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
begin
    LOOP
      l_number := TO_NUMBER(RAWTOHEX(Fnd_Crypto.RandomBytes(4)), XTONUM);
      EXIT WHEN l_number > 0 AND l_number < 4294967296;
    END LOOP;

    RETURN l_number;

end get_next;


procedure init_arrays is
begin
      NULL;

end init_arrays;

end;

/
