--------------------------------------------------------
--  DDL for Package Body CZ_BATCH_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_BATCH_VALIDATE" AS
/*  $Header: czbvaldb.pls 120.0.12010000.2 2009/07/16 00:55:27 vsingava ship $        */
------------------------------------------------------------------------------------------
PROCEDURE VALIDATE (
-- single-call validation function uses tables to exchange multi-valued data
                    config_input_list IN  CFG_INPUT_LIST,        -- input selections
                    init_message      IN  VARCHAR2,              -- additional XML
                    config_messages   IN  OUT NOCOPY CFG_OUTPUT_PIECES, -- table of output XML messages
                    validation_status IN  OUT NOCOPY NUMBER,            -- status return
                    URL               IN  VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'))

IS
  cfapi_input_list  cz_cf_api.CFG_INPUT_LIST;
  i                 PLS_INTEGER;
BEGIN

  i := config_input_list.FIRST;

  WHILE(i IS NOT NULL)LOOP

    cfapi_input_list(i).component_code := config_input_list(i).component_code;
    cfapi_input_list(i).quantity := config_input_list(i).quantity;
    cfapi_input_list(i).input_seq := config_input_list(i).input_seq;
    cfapi_input_list(i).config_item_id := config_input_list(i).config_item_id;

    i := config_input_list.NEXT(i);
  END LOOP;

  cz_cf_api.validate(cfapi_input_list, init_message, config_messages, validation_status, URL);
END validate;
------------------------------------------------------------------------------------------
END CZ_BATCH_VALIDATE;

/
