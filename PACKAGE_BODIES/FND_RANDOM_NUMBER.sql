--------------------------------------------------------
--  DDL for Package Body FND_RANDOM_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_RANDOM_NUMBER" AS
/* $Header: AFSCRNGB.pls 120.2 2005/07/02 03:09:22 appldev noship $ */

--
-- Tuneable constants:
--
-- C_BLOCK_SIZE  The number of random values that can be generated off
--               of the cached value for the counter before we need to
--               go back to the table and sequence again.  This number
--               times the C_REKEY_SIZE must be less than 2^20.  This
--               must be greater than 2000/8 to satisfy the block get API.
-- C_REKEY_SIZE  The number of random blocks that can be generated off
--               of a key before a recomputation of the key is required.
--               When a process goes to the table/sequence and detects
--               that this number of blocks has been used, that process
--               is responsible for recomputing the key and updating the
--               the table with the new values.
-- C_FLUSH_SIZE  The number of random events that can be buffered in
--               the pools before the code must flush the entropy to
--               one-row table.  This must be a multiple of 32 so that
--               table updates don't favor earlier pools with more
--               of the available entropy.
-- C_EVENT_SIZE  The number of random events that must be collected in
--               the table before a reseeding operation can be performed.
--
  C_BLOCK_SIZE   constant number       := 4096;
  C_REKEY_SIZE   constant number       := 64;
  C_FLUSH_SIZE   constant number       := 1024;
  C_EVENT_SIZE   constant number       := 65536;
--
-- Static (class) variables, do not change
--
  S_HEX_FORMAT   constant varchar2(60) := 'FM0XXXXXXXXXXXXXXX';
  S_MAX_COUNTER  constant number       := power(2, 64);
--
-- Table of MD5 values (raws)
--
  type RAWTAB is table of raw(16) index by binary_integer;
--
-- Writable class member variables
--
  M_NUM_RANDOMS   number := 0;
  M_COUNTER       number := 0;
  M_KEY           raw(24);
  M_POOLS         RAWTAB;
  M_EVENTS        number := 0;

--
-- Internal function - generates an entropy raw based on the SYS_GUID,
-- SYSDATE, session ID, DBMS_RANDOM, and any other input entropy.
-- Concatenates this with an existing entropy value (if any).
--
  function GENERATE_ENTROPY(P_ENTROPY in raw default null,
                            P_OLDVALUE in raw default null)
  return raw
  is
    X_E1    raw(16);
    X_E2    raw(16);
    X_E3    raw(16);
    X_E4    raw(16);
  begin
    -- select SYS_GUID() into X_E1 from dual;
    -- replacing with the line below for bug 4082303
    X_E1 := SYS_GUID();
    X_E2 := DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
              UTL_RAW.CAST_TO_RAW(to_char(SYSDATE, 'YYYYMMDD HH24MISS')||' '||
                                  USERENV('SESSIONID')));
    X_E3 := hextoraw(to_char(DBMS_RANDOM.RANDOM+power(2,31),'FM0XXXXXXX')||
                     to_char(DBMS_RANDOM.RANDOM+power(2,31),'FM0XXXXXXX')||
                     to_char(DBMS_RANDOM.RANDOM+power(2,31),'FM0XXXXXXX')||
                     to_char(DBMS_RANDOM.RANDOM+power(2,31),'FM0XXXXXXX'));
    if (P_ENTROPY is not null) then
      X_E4 := DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT => P_ENTROPY);
    else
      X_E4 := hextoraw('0123456789ABCDEF0123456789ABCDEF');
    end if;
    return(UTL_RAW.CONCAT(X_E1, X_E2, X_E3, X_E4, P_OLDVALUE));
  end GENERATE_ENTROPY;

--
-- Add some entropy to the in-memory pools.  Entropy is added in
-- round-robin fashion to 32 pools.  Each call to this routine is
-- considered one event.  Even if no entropy is passed in to this
-- routine, it will attempt to get some by using the GUID mechanism,
-- the SYSDATE and SESSIONID (together), and the current state of
-- DBMS_RANDOM.  The entropy is added to the next pool in sequence.
-- Only the resulting MD5 is stored - there is no buffering of
-- intermediate amounts of entropy (seems pointless because we're
-- not getting much entropy from the above sources anyway).
--
  procedure ADD_ENTROPY(P_ENTROPY in raw default null)
  is
    X_INDEX number;
  begin
    if (M_EVENTS = 0) then
      for M_EVENTS in 1..32 loop
        M_POOLS(M_EVENTS) := null;
      end loop;
      M_EVENTS := 0;
    end if;
    X_INDEX := mod(M_EVENTS, 32) + 1;
    M_EVENTS := M_EVENTS + 1;
    M_POOLS(X_INDEX) := DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
                          UTL_RAW.CONCAT(GENERATE_ENTROPY(P_ENTROPY,
                                                          M_POOLS(X_INDEX))));
    if (M_EVENTS >= C_FLUSH_SIZE) then
      FLUSH_ENTROPY;
    end if;
  end ADD_ENTROPY;
--
-- Write any accumulated entropy to the table in an autonomous transaction.
-- The entropy collected is assumed to be evenly distributed across the 32
-- pools.  If enough entropy has been accumulated in the table, a reseeding
-- of the generator is done.
--
  procedure FLUSH_ENTROPY
  is
  pragma AUTONOMOUS_TRANSACTION;
    X_COUNT   number;
    X_EVENTS  number;
    X_POOL    RAWTAB;
  begin
    if (M_EVENTS = 0) then
      return; -- No entropy available yet
    end if;
    -- Initialize the pool arrays
    for X_BIT in 1..32 loop
      X_POOL(X_BIT) := null;
    end loop;
    -- Get the current state of the entropy pools from disk
    select EVENT_COUNT,
           POOL0,  POOL1,  POOL2,  POOL3,  POOL4,  POOL5,  POOL6,  POOL7,
           POOL8,  POOL9,  POOL10, POOL11, POOL12, POOL13, POOL14, POOL15,
           POOL16, POOL17, POOL18, POOL19, POOL20, POOL21, POOL22, POOL23,
           POOL24, POOL25, POOL26, POOL27, POOL28, POOL29, POOL30, POOL31
      into X_EVENTS,
           X_POOL(1),  X_POOL(2),  X_POOL(3),  X_POOL(4),  X_POOL(5),
           X_POOL(6),  X_POOL(7),  X_POOL(8),  X_POOL(9),  X_POOL(10),
           X_POOL(11), X_POOL(12), X_POOL(13), X_POOL(14), X_POOL(15),
           X_POOL(16), X_POOL(17), X_POOL(18), X_POOL(19), X_POOL(20),
           X_POOL(21), X_POOL(22), X_POOL(23), X_POOL(24), X_POOL(25),
           X_POOL(26), X_POOL(27), X_POOL(28), X_POOL(29), X_POOL(30),
           X_POOL(31), X_POOL(32)
      from FND_RAND_STATES
     where LOCK_ID = 1
       for update;
    -- Merge as much entropy as available into the pools
    for X_COUNT in 1..32 loop
      if (M_POOLS(X_COUNT) is not null) then
        X_POOL(X_COUNT) := DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
                             UTL_RAW.CONCAT(X_POOL(X_COUNT),M_POOLS(X_COUNT)));
        M_POOLS(X_COUNT) := null;
      end if;
    end loop;
    -- Update the pools and event counter
    X_EVENTS := X_EVENTS + M_EVENTS;
    update FND_RAND_STATES
       set EVENT_COUNT = X_EVENTS,
           POOL0  = X_POOL(1),
           POOL1  = X_POOL(2),
           POOL2  = X_POOL(3),
           POOL3  = X_POOL(4),
           POOL4  = X_POOL(5),
           POOL5  = X_POOL(6),
           POOL6  = X_POOL(7),
           POOL7  = X_POOL(8),
           POOL8  = X_POOL(9),
           POOL9  = X_POOL(10),
           POOL10 = X_POOL(11),
           POOL11 = X_POOL(12),
           POOL12 = X_POOL(13),
           POOL13 = X_POOL(14),
           POOL14 = X_POOL(15),
           POOL15 = X_POOL(16),
           POOL16 = X_POOL(17),
           POOL17 = X_POOL(18),
           POOL18 = X_POOL(19),
           POOL19 = X_POOL(20),
           POOL20 = X_POOL(21),
           POOL21 = X_POOL(22),
           POOL22 = X_POOL(23),
           POOL23 = X_POOL(24),
           POOL24 = X_POOL(25),
           POOL25 = X_POOL(26),
           POOL26 = X_POOL(27),
           POOL27 = X_POOL(28),
           POOL28 = X_POOL(29),
           POOL29 = X_POOL(30),
           POOL30 = X_POOL(31),
           POOL31 = X_POOL(32)
      where LOCK_ID = 1;
    -- If enough events have been accumulated, reseed
    if (X_EVENTS >= C_EVENT_SIZE) then
      RESEED_GENERATOR;
    end if;
    commit;
    -- Mark the in-memory entropy pools as empty
    M_EVENTS := 0;
  exception when OTHERS then
    rollback;
  end FLUSH_ENTROPY;
--
-- Reseed the random number generator using entropy from the table
-- If insufficient entropy is available, aborts the operation and
-- returns.  This code runs in the same transaction as the caller;
-- the caller is responsible for committing or rolling back the
-- changes.  Note that on returning, this code always leaves the
-- one-row table in a locked state (even if it aborts), so the caller
-- should always commit or rollback, preferably soon after the call.
--
  procedure RESEED_GENERATOR
  is
    X_BIT       number;
    X_POOL      RAWTAB;
    X_COUNTER   number;
    X_EVENTS    number;
    X_SEQUENCE  number;
    X_KEY       raw(24);
    X_ENTROPY   raw(512);
  begin
    -- Initialize the pool arrays
    for X_BIT in 1..32 loop
      X_POOL(X_BIT) := null;
    end loop;
    -- Get the current state of the key, seed counter, and entropy
    select LAST_SEQUENCE, RANDOM_KEY, RESEED_COUNTER, EVENT_COUNT,
           POOL0,  POOL1,  POOL2,  POOL3,  POOL4,  POOL5,  POOL6,  POOL7,
           POOL8,  POOL9,  POOL10, POOL11, POOL12, POOL13, POOL14, POOL15,
           POOL16, POOL17, POOL18, POOL19, POOL20, POOL21, POOL22, POOL23,
           POOL24, POOL25, POOL26, POOL27, POOL28, POOL29, POOL30, POOL31
      into X_SEQUENCE, X_KEY, X_COUNTER, X_EVENTS,
           X_POOL(1),  X_POOL(2),  X_POOL(3),  X_POOL(4),  X_POOL(5),
           X_POOL(6),  X_POOL(7),  X_POOL(8),  X_POOL(9),  X_POOL(10),
           X_POOL(11), X_POOL(12), X_POOL(13), X_POOL(14), X_POOL(15),
           X_POOL(16), X_POOL(17), X_POOL(18), X_POOL(19), X_POOL(20),
           X_POOL(21), X_POOL(22), X_POOL(23), X_POOL(24), X_POOL(25),
           X_POOL(26), X_POOL(27), X_POOL(28), X_POOL(29), X_POOL(30),
           X_POOL(31), X_POOL(32)
      from FND_RAND_STATES
     where LOCK_ID = 1
       for update;
    -- Draw entropy from the pools
    X_ENTROPY := null;
    for X_BIT in 0..31 loop
      if (mod(X_COUNTER, power(2, X_BIT)) = 0) then
        -- Use this pool for the reseed operation
        if (X_POOL(X_BIT + 1) is not null) then
          X_ENTROPY := UTL_RAW.CONCAT(X_ENTROPY, X_POOL(X_BIT + 1));
          X_POOL(X_BIT + 1) := null;
        end if;
      end if;
    end loop;
    if (X_ENTROPY is null) then
      -- Insufficient entropy available, abort the reseeding
      return;
    end if;
    -- Recompute the key by taking the MD5 of the old key plus the entropy.
    X_KEY := UTL_RAW.CONCAT(
               UTL_RAW.SUBSTR(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
                 UTL_RAW.CONCAT(hextoraw('1'), X_KEY, X_ENTROPY)), 1, 12),
               UTL_RAW.SUBSTR(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
                 UTL_RAW.CONCAT(hextoraw('2'), X_KEY, X_ENTROPY)), 1, 12));
    -- Increment the seed counter
    if (X_COUNTER = power(2,31)) then
      X_COUNTER := 1;
    else
      X_COUNTER := X_COUNTER + 1;
    end if;
    -- Update the reseed counter, key, and entropy;
    -- set the last sequence to 0 to force a re-initialization to occur
    update FND_RAND_STATES
       set LAST_SEQUENCE = 0,
           EVENT_COUNT = 0,
           RESEED_COUNTER = X_COUNTER,
           RANDOM_KEY = X_KEY,
           POOL0  = X_POOL(1),
           POOL1  = X_POOL(2),
           POOL2  = X_POOL(3),
           POOL3  = X_POOL(4),
           POOL4  = X_POOL(5),
           POOL5  = X_POOL(6),
           POOL6  = X_POOL(7),
           POOL7  = X_POOL(8),
           POOL8  = X_POOL(9),
           POOL9  = X_POOL(10),
           POOL10 = X_POOL(11),
           POOL11 = X_POOL(12),
           POOL12 = X_POOL(13),
           POOL13 = X_POOL(14),
           POOL14 = X_POOL(15),
           POOL15 = X_POOL(16),
           POOL16 = X_POOL(17),
           POOL17 = X_POOL(18),
           POOL18 = X_POOL(19),
           POOL19 = X_POOL(20),
           POOL20 = X_POOL(21),
           POOL21 = X_POOL(22),
           POOL22 = X_POOL(23),
           POOL23 = X_POOL(24),
           POOL24 = X_POOL(25),
           POOL25 = X_POOL(26),
           POOL26 = X_POOL(27),
           POOL27 = X_POOL(28),
           POOL28 = X_POOL(29),
           POOL29 = X_POOL(30),
           POOL30 = X_POOL(31),
           POOL31 = X_POOL(32)
      where LOCK_ID = 1;
  exception when OTHERS then
    rollback;
  end RESEED_GENERATOR;

--
-- This routine updates the generator state stored in the one-row table
-- using an autonomous transaction.  Since the counter is coming from a
-- sequence, that means that this routine really just updates the key
-- stored in the table.  The update also stores the value of the sequence,
-- so that later readers of the table can determine how many blocks of
-- random values have been generated using the stored key.
--
  procedure UPDATE_KEY(P_LASTCOUNT in number)
  is
  pragma AUTONOMOUS_TRANSACTION;
    X_NEWKEY    raw(24);
    X_R1        raw(8);
    X_R2        raw(8);
    X_R3        raw(8);
    X_LASTCOUNT number;
    X_ENTROPY   raw(512);
  begin
    -- Re-fetch the row to lock it for update
    select LAST_SEQUENCE, RANDOM_KEY
      into X_LASTCOUNT, M_KEY
      from FND_RAND_STATES
     where LOCK_ID = 1
       for update;
    -- Recheck it to make sure we need to update it; it's possible
    -- that another process beat us to it.
    if (X_LASTCOUNT = P_LASTCOUNT) then
      if (P_LASTCOUNT = 0) then
        -- This is the first process to touch the row, force a key change
        X_ENTROPY := GENERATE_ENTROPY;
        M_KEY := UTL_RAW.CONCAT(
                   UTL_RAW.SUBSTR(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
                     UTL_RAW.CONCAT(hextoraw('1'), M_KEY, X_ENTROPY)), 1, 12),
                   UTL_RAW.SUBSTR(DBMS_OBFUSCATION_TOOLKIT.MD5(INPUT =>
                     UTL_RAW.CONCAT(hextoraw('2'), M_KEY, X_ENTROPY)), 1, 12));
      end if;
      -- Update is required
      X_LASTCOUNT := M_COUNTER;
      M_COUNTER := mod(M_COUNTER * C_BLOCK_SIZE, S_MAX_COUNTER);
      -- Now regenerate the key
      X_R1 := hextoraw(to_char(M_COUNTER, S_HEX_FORMAT));
      M_COUNTER := mod(M_COUNTER + 1, S_MAX_COUNTER);
      X_R2 := hextoraw(to_char(M_COUNTER, S_HEX_FORMAT));
      M_COUNTER := mod(M_COUNTER + 1, S_MAX_COUNTER);
      X_R3 := hextoraw(to_char(M_COUNTER, S_HEX_FORMAT));
      M_COUNTER := mod(M_COUNTER + 2, S_MAX_COUNTER);
      X_NEWKEY := DBMS_OBFUSCATION_TOOLKIT.DES3ENCRYPT(
                    INPUT => UTL_RAW.CONCAT(X_R1, X_R2, X_R3), KEY => M_KEY);
      -- Used the first 4 randoms from this block to regenerate the key
      -- (one value was discarded to stay on an even count)
      M_NUM_RANDOMS := C_BLOCK_SIZE - 4;
      -- Update the counter and key
      update FND_RAND_STATES
         set LAST_SEQUENCE = X_LASTCOUNT,
             RANDOM_KEY = X_NEWKEY
      where LOCK_ID = 1;
      commit;
    else
      -- Update was done by another process; unlock the one-row table
      rollback;
      M_COUNTER := mod(M_COUNTER * C_BLOCK_SIZE, S_MAX_COUNTER);
      M_NUM_RANDOMS := C_BLOCK_SIZE;
    end if;
  exception when OTHERS then
    rollback;
  end UPDATE_KEY;
--
-- Initialize the in-memory generator by fetching the counter value from
-- the sequence and the key from the one-row table.  This in-memory state
-- is then used as needed to generate random numbers (up to a pre-defined
-- block size).  The fetch doesn't normally require that the one-row table
-- be locked (because the counter comes from a sequence).  Howver, if this
-- code detects that enough blocks have been generated from the current key,
-- it forces a recomputation of the key using UPDATE_KEY; we don't want
-- that to happen too often because it requires locking the table.
--
  procedure INITIALIZE_GENERATOR
  is
    X_NEWKEY    raw(24);
    X_LASTCOUNT number;
  begin
    -- Get the current state of the random counter and key
    select LAST_SEQUENCE, RANDOM_KEY, FND_RAND_S.NEXTVAL
      into X_LASTCOUNT, M_KEY, M_COUNTER
      from FND_RAND_STATES
     where LOCK_ID = 1;
    if ((X_LASTCOUNT = 0) or (M_COUNTER < X_LASTCOUNT) or
        ((M_COUNTER - X_LASTCOUNT) >= C_REKEY_SIZE)) then
      -- If the sequence has advanced enough, recompute the key
      UPDATE_KEY(X_LASTCOUNT);
    else
      -- Otherwise just consume the next block
      M_COUNTER := mod(M_COUNTER * C_BLOCK_SIZE, S_MAX_COUNTER);
      M_NUM_RANDOMS := C_BLOCK_SIZE;
    end if;
  end INITIALIZE_GENERATOR;
--
-- Get a random value as a 16-byte (128-bit) raw.  Values normally come
-- by generating them off of an in-memory cache containing the counter
-- and key.  This cache is used up to a pre-defined block size, after
-- which the cache is re-synced by calling INITIALIZE_GENERATOR.  The
-- first call is forced to do this, which means it's forced to read
-- the one-row table (but hopefully not to lock/update it).  Note that
-- this code runs the ADD_ENTROPY routine on every call in a pathetic
-- attempt to collect whatever entropy we can; this adds some cost to
-- the routine, and every so often will incur the additional cost of
-- updating the entropy in the table, or, worse, reseeding the key.
--
  function GET_RANDOM return raw
  is
  begin
    return(GET_RANDOM_BYTES(16));
  end GET_RANDOM;
--
  function GET_RANDOM_BYTES(P_NBYTES in number default null) return raw
  is
    X_NRAND number;
    X_EXTRA number;
    X_BYTES raw(2000);
  begin
    -- Reject invalid requests
    if ((P_NBYTES is null) or (P_NBYTES < 1) or (P_NBYTES > 2000)) then
      return(null);
    end if;
    -- Collect whatever entropy we can from GUID, SYSDATE, DBMS_RANDOM
    ADD_ENTROPY;
    -- Compute number of bytes to round up the request to 64-bit boundary
    X_EXTRA := mod(P_NBYTES, 8);
    if (X_EXTRA > 0) then
      X_EXTRA := 8 - X_EXTRA;
    end if;
    X_NRAND := (P_NBYTES + X_EXTRA) / 8;
    if (M_NUM_RANDOMS < X_NRAND) then
      -- If the current block of randoms is too small, re-initialize
      INITIALIZE_GENERATOR;
    end if;
    -- Set the buffer to the first counter value
    M_NUM_RANDOMS := M_NUM_RANDOMS - X_NRAND;
    X_BYTES := hextoraw(to_char(M_COUNTER, S_HEX_FORMAT));
    X_NRAND := X_NRAND - 1;
    M_COUNTER := mod(M_COUNTER + 1, S_MAX_COUNTER);
    -- Concatenate additional counter values to fill the request
    while (X_NRAND > 0) loop
      X_BYTES := UTL_RAW.CONCAT(X_BYTES,
                                hextoraw(to_char(M_COUNTER, S_HEX_FORMAT)));
      M_COUNTER := mod(M_COUNTER + 1, S_MAX_COUNTER);
      X_NRAND := X_NRAND - 1;
    end loop;
    -- Return the encryption of the counter sequence
    if (X_EXTRA > 0) then
      -- If rounding was done, truncate unwanted bytes
      return(UTL_RAW.SUBSTR(DBMS_OBFUSCATION_TOOLKIT.DES3ENCRYPT(
                              INPUT => X_BYTES, KEY => M_KEY),
                            1, P_NBYTES));
    end if;
    return(DBMS_OBFUSCATION_TOOLKIT.DES3ENCRYPT(INPUT => X_BYTES,
                                                KEY => M_KEY));
  end GET_RANDOM_BYTES;

  procedure ADD_EXTERNAL_ENTROPY(P_E in raw default null)
  is
  pragma AUTONOMOUS_TRANSACTION;
     X_ENTROPY   raw(512);
     X_NEWKEY    raw(24);
  begin
     X_ENTROPY := GENERATE_ENTROPY(P_ENTROPY=>P_E);
     select RANDOM_KEY
       into X_NEWKEY
       from FND_RAND_STATES
     where LOCK_ID = 1
       for update;
     X_NEWKEY := DBMS_OBFUSCATION_TOOLKIT.MD5(
                     INPUT => UTL_RAW.CONCAT(X_NEWKEY,X_ENTROPY));
     X_NEWKEY := UTL_RAW.SUBSTR(
                     UTL_RAW.CONCAT(X_NEWKEY,
                       DBMS_OBFUSCATION_TOOLKIT.MD5(
                         INPUT => UTL_RAW.CONCAT(X_NEWKEY, X_NEWKEY))),
                     1, 24);
     update FND_RAND_STATES
       set RANDOM_KEY = X_NEWKEY,
           LAST_SEQUENCE = 0
     where LOCK_ID = 1;
     commit;
  exception when OTHERS then
     rollback;
  end ADD_EXTERNAL_ENTROPY;

END FND_RANDOM_NUMBER;

/
