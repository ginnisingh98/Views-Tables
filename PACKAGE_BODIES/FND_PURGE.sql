--------------------------------------------------------
--  DDL for Package Body FND_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PURGE" as
/* $Header: AFCPPURB.pls 115.0 99/09/29 17:52:14 porting ship  $ */

  --
  -- Name
  --   requests
  --
  -- Purpose
  --   It will purge the records that are belongs to a concurrent request.
  -- Arguments
  --   rec_table   : pl/sql table with request_id a one field.
  --   start_range : starting number of the record in the rec_table for which
  --                 purge is required.
  --   end_range   : ending number of the record in the rec_table for which
  --                 purge is recuired.
  --

  PROCEDURE requests( rec_table    IN requests_tab_type,
                    start_range  IN NUMBER,
                    end_range    IN NUMBER) is
  BEGIN
      NULL;
  END requests;


  --
  -- Name
  --   managers
  --
  -- Purpose
  --   It will purge the records that are belongs to a concurrent managers.
  -- Arguments
  --   rec_table   : pl/sql table with process_id as one field.
  --   start_range : starting number of the record in the rec_table for which
  --                 purge is required.
  --   end_range   : ending number of the record in the rec_table for which
  --                 purge is recuired.
  --

  PROCEDURE managers( rec_table  IN managers_tab_type,
                    start_range  IN NUMBER,
                    end_range    IN NUMBER) is
  BEGIN
      NULL;
  END managers;


end FND_PURGE;

/
