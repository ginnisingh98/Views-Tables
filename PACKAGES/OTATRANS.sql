--------------------------------------------------------
--  DDL for Package OTATRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTATRANS" AUTHID CURRENT_USER as
/* $Header: otatrans.pkh 115.2 2002/11/26 12:24:39 dbatra ship $ */
--
Procedure gl_transfer (ERRBUF  OUT nocopy VARCHAR2,
                       RETCODE OUT nocopy VARCHAR2);
--
end OTATRANS;

 

/
