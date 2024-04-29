--------------------------------------------------------
--  DDL for Package FND_OID_DIAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OID_DIAG" AUTHID CURRENT_USER as
/* $Header: AFSCODIS.pls 120.1.12000000.1 2007/01/18 13:26:39 appldev ship $ */
--
/*****************************************************************************/

procedure init;
procedure getDefaultTestParams(defaultInputValues out nocopy jtf_diag_inputtbl);
procedure cleanup;
procedure runtest(inputs in jtf_diag_inputtbl,
		              report out nocopy jtf_diag_report,
		              reportClob out nocopy clob);
procedure getComponentName(compName out nocopy varchar2);
procedure getTestName(testName out nocopy varchar2);
procedure getTestDesc(descStr out nocopy varchar2);
function getTestMode return integer;
end fnd_oid_diag;

 

/
