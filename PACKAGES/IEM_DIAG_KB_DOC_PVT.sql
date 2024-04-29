--------------------------------------------------------
--  DDL for Package IEM_DIAG_KB_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DIAG_KB_DOC_PVT" AUTHID CURRENT_USER AS
/* $Header: iemddocs.pls 115.0 2003/07/23 22:32:51 chtang noship $ */

TYPE document_type IS RECORD (
          item_id    jtf_amv_items_vl.item_id%type,
          file_name  fnd_lobs.file_name%type,
          channel_category_id 	amv_c_chl_item_match.channel_category_id%type,
          score number);

TYPE document_tbl IS TABLE OF document_type
           INDEX BY BINARY_INTEGER;

PROCEDURE init;
PROCEDURE getDefaultTestParams(defaultInputValues OUT NOCOPY JTF_DIAG_INPUTTBL);
PROCEDURE cleanup;
PROCEDURE runTest(inputs IN JTF_DIAG_INPUTTBL,
                  reports OUT NOCOPY JTF_DIAG_REPORT,
                  reportClob OUT NOCOPY CLOB);
PROCEDURE getComponentName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestName(name OUT NOCOPY VARCHAR2);
PROCEDURE getTestDesc(descStr OUT NOCOPY VARCHAR2);
FUNCTION getTestMode RETURN INTEGER;
END;

 

/
