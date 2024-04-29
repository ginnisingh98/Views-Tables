--------------------------------------------------------
--  DDL for Package ICX_POR_EXTRACTOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_EXTRACTOR" AUTHID CURRENT_USER AS
/* $Header: ICXEXTMS.pls 120.1 2006/01/10 11:59:42 sbgeorge noship $*/

--------------------------------------------------------------
--                   Global Variables                       --
--------------------------------------------------------------

-- Extractor loader value
TYPE tLoaderValueRecord IS Record (
  load_catalog_groups			VARCHAR2(1),
  load_categories			VARCHAR2(1),
  load_template_headers			VARCHAR2(1),
  load_template_lines			VARCHAR2(1),
  load_item_master			VARCHAR2(1),
  load_contracts			VARCHAR2(1),
  catalog_groups_last_run_date		DATE,
  categories_last_run_date		DATE,
  template_headers_last_run_date	DATE,
  template_lines_last_run_date		DATE,
  item_master_last_run_date		DATE,
  contracts_last_run_date		DATE,
  vendor_last_run_date			DATE,
  load_internal_item			VARCHAR2(1),
  internal_item_last_run_date		DATE,
  cleanup_flag				VARCHAR2(1),
  load_onetimeitems_all_langs           VARCHAR2(1)  -- Bug # 3991430
);
gLoaderValue		tLoaderValueRecord;

gBaseLang		VARCHAR2(4);
gNLSLanguage		VARCHAR2(30);
gInstalledLanguageCount	PLS_INTEGER := 1;

gJobNum			PLS_INTEGER := 1;
gSpid			VARCHAR2(20);

gUserId			PLS_INTEGER := fnd_global.user_id;
gLoginId		PLS_INTEGER := fnd_global.login_id;
gRequestId		PLS_INTEGER := fnd_global.conc_request_id;
gProgramApplicationId	PLS_INTEGER := fnd_global.prog_appl_id;
gProgramId		PLS_INTEGER := fnd_global.conc_program_id;

PROCEDURE setLastRunDates(pType	IN VARCHAR2);
PROCEDURE extract(pType 	IN VARCHAR2,
                  pFileName 	IN VARCHAR2,
                  pDebugLevel 	IN PLS_INTEGER,
                  pCommitSize	IN PLS_INTEGER);

PROCEDURE purge(pFileName 	IN VARCHAR2,
                pDebugLevel 	IN PLS_INTEGER,
                pCommitSize	IN PLS_INTEGER);

END ICX_POR_EXTRACTOR;

 

/
