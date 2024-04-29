--------------------------------------------------------
--  DDL for Package Body IBY_EC_OP_FILE_NAME_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EC_OP_FILE_NAME_EXT_PUB" AS
/* $Header: ibyecfneb.pls 120.0.12010000.1 2010/02/22 14:51:10 appldev noship $ */


  --
  -- This API is called processing payments through ECE gateway for
  -- generating fileID.
  -- Note: File name would be calculated by concatenating 'PYO' to
  -- the file ID
  -- If this function returns null, then fileId would be generated
  -- with sequence ece_output_runs_s
  --
  Function get_File_Id(p_payment_instruction_id IN number) return PLS_INTEGER
  IS
  l_file_id PLS_INTEGER :=null;
  BEGIN
   return l_file_id;
  END  get_File_Id;


END IBY_EC_OP_FILE_NAME_EXT_PUB;



/
