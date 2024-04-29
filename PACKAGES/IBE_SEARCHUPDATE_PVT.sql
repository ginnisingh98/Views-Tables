--------------------------------------------------------
--  DDL for Package IBE_SEARCHUPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_SEARCHUPDATE_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVCSUS.pls 120.0.12010000.2 2015/05/08 12:20:12 amaheshw ship $ */

TYPE MSITE_ID_REC_TYPE Is RECORD
  (
		msite_id	Number,
        msite_root_section_id Number
  );

TYPE msite_id_tbl_type Is TABLE OF MSITE_ID_REC_TYPE Index by BINARY_INTEGER;

procedure loadMsitesSectionItemsTable(
	errbuf	OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY NUMBER);

end;

/
