--------------------------------------------------------
--  DDL for Package CZ_BATCH_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_BATCH_VALIDATE" AUTHID CURRENT_USER AS
/*      $Header: czbvalds.pls 120.0.12010000.2 2009/07/16 00:53:59 vsingava ship $  */

type INPUT_SELECTION is record (
			component_code	varchar2(1200),
			quantity          number,
			input_seq         number,
			config_item_id    number default NULL);

type CFG_INPUT_LIST is table of INPUT_SELECTION index by binary_integer;
subtype CFG_OUTPUT_PIECES is UTL_HTTP.HTML_PIECES;

INIT_MESSAGE_LIMIT            constant NUMBER :=2*1024;

--------------------------Validation status return codes----------------------------------
CONFIG_PROCESSED              constant NUMBER :=0;
CONFIG_PROCESSED_NO_TERMINATE constant NUMBER :=1;
INIT_TOO_LONG                 constant NUMBER :=2;
INVALID_OPTION_REQUEST        constant NUMBER :=3;
CONFIG_EXCEPTION              constant NUMBER :=4;
DATABASE_ERROR                constant NUMBER :=5;
UTL_HTTP_INIT_FAILED          constant NUMBER :=6;
UTL_HTTP_REQUEST_FAILED       constant NUMBER :=7;
CONFIG_ITEM_UNSUPPORTED_PRE_H constant NUMBER :=8;
INVALID_ALTBATCHVALIDATE_URL  constant NUMBER :=9;
------------------------------------------------------------------------------------------
PROCEDURE VALIDATE (
-- single-call validation function uses tables to exchange multi-valued data
    config_input_list IN  CFG_INPUT_LIST,        -- input selections
    init_message      IN  VARCHAR2,              -- additional XML
    config_messages   IN  OUT NOCOPY CFG_OUTPUT_PIECES, -- table of output XML messages
    validation_status IN  OUT NOCOPY NUMBER,            -- status return
    URL               IN  VARCHAR2 DEFAULT FND_PROFILE.Value('CZ_UIMGR_URL'));
------------------------------------------------------------------------------------------
END CZ_BATCH_VALIDATE;

/
