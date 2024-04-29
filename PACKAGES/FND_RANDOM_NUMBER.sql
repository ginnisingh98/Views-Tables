--------------------------------------------------------
--  DDL for Package FND_RANDOM_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RANDOM_NUMBER" AUTHID CURRENT_USER AS
/* $Header: AFSCRNGS.pls 115.3 2004/04/20 21:06:23 dehu noship $ */
  --
  -- Note to developers:
  -- Please do not directly use the APIs in this package.  Use the
  -- APIs in FND_CRYPTO.  These APIs are internal to AOL.
  --
  --
  -- Reseed the random generator from stored entropy
  -- Note: in-transaction, caller must commit or rollback
  --
  procedure RESEED_GENERATOR;

  --
  -- Initialize the generator by getting the key and counter
  -- Note: performs autonomous transaction if table update is needed
  --
  procedure INITIALIZE_GENERATOR;

  --
  -- Get a random value as a 16-byte raw value (by calling GET_RANDOM_BYTES).
  --
  function GET_RANDOM return raw;

  --
  -- Get a random set of bytes (from 1-2000 as specified).
  -- Returns null if an invalid byte count is specified.
  -- If necessary, (re)initializes the generator.
  -- Throws some entropy into the in-memory pools
  --
  function GET_RANDOM_BYTES(P_NBYTES in number default null) return raw;

  --
  -- Add some entropy to the in-memory pools
  -- Automatically flushes the entropy to the table after a certain amount
  -- is collected.
  --
  procedure ADD_ENTROPY(P_ENTROPY in raw default null);

  --
  -- Flush any accumulated entropy to the table
  -- Automatically reseeds the generator if enough entropy is available
  -- Note: commits as an autonomous transaction
  --
  procedure FLUSH_ENTROPY;


  --
  -- Can be invoked to bootstrap the generator with external entropy
  -- DO NOT INVOKE THIS WITHOUT CONSULTING ATG SECURITY
  --
  procedure ADD_EXTERNAL_ENTROPY(P_E in raw default null);

end FND_RANDOM_NUMBER;

 

/
