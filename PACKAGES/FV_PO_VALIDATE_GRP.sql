--------------------------------------------------------
--  DDL for Package FV_PO_VALIDATE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_PO_VALIDATE_GRP" AUTHID CURRENT_USER as
-- $Header: FVPOVALS.pls 120.1 2005/08/16 16:29:52 ksriniva noship $
PROCEDURE   CHECK_AGREEMENT_DATES(x_code_combination_id in number,
				      x_org_id  in number,
                                      x_ledger_id  in number,
                                      x_called_from in varchar2,
                                       x_ATTRIBUTE1  IN VARCHAR2,
                                       x_ATTRIBUTE2  IN VARCHAR2,
                                       x_ATTRIBUTE3  IN VARCHAR2,
                                       x_ATTRIBUTE4  IN VARCHAR2,
                                       x_ATTRIBUTE5  IN VARCHAR2,
                                       x_ATTRIBUTE6  IN VARCHAR2,
                                       x_ATTRIBUTE7  IN VARCHAR2,
                                       x_ATTRIBUTE8  IN VARCHAR2,
                                       x_ATTRIBUTE9  IN VARCHAR2,
                                       x_ATTRIBUTE10 IN VARCHAR2,
                                       x_ATTRIBUTE11 IN VARCHAR2,
                                       x_ATTRIBUTE12 IN VARCHAR2,
                                       x_ATTRIBUTE13 IN VARCHAR2,
                                       x_ATTRIBUTE14 IN VARCHAR2,
                                       x_ATTRIBUTE15 IN VARCHAR2,
                                       x_status out nocopy varchar2,
                                       x_message out nocopy varchar2);

End FV_PO_VALIDATE_GRP;

 

/
