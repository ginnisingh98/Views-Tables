--------------------------------------------------------
--  DDL for Package FND_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PURGE" AUTHID CURRENT_USER as
/* $Header: AFCPPURS.pls 115.0 99/09/29 17:52:24 porting ship  $ */

     TYPE requests_record_type is record
             (request_id   number);

     TYPE requests_tab_type is table of requests_record_type
              index by binary_integer;

     TYPE managers_record_type is record
             (process_id   number);

     TYPE managers_tab_type is table of managers_record_type
              index by binary_integer;

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

  PROCEDURE requests( rec_table  IN requests_tab_type,
                    start_range  IN NUMBER,
                    end_range    IN NUMBER);
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
                    end_range    IN NUMBER);

end FND_PURGE;

 

/
