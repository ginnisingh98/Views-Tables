--------------------------------------------------------
--  DDL for Package IBY_EC_OP_FILE_NAME_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_EC_OP_FILE_NAME_EXT_PUB" AUTHID CURRENT_USER AS
/* $Header: ibyecfnes.pls 120.0.12010000.1 2010/02/22 14:51:21 appldev noship $ */


  --
  -- This API is called processing payments through ECE gateway for
  -- generating fileID.
  -- Note: File name would be calculated by concatenating 'PYO' to
  -- the file ID
  -- If this function returns null, then fileId would be generated
  -- with sequence ece_output_runs_s
  --
  Function get_File_Id(p_payment_instruction_id IN number) return PLS_INTEGER;


END IBY_EC_OP_FILE_NAME_EXT_PUB;



/
