--------------------------------------------------------
--  DDL for Package MTH_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTH_COMMON_PKG" AUTHID CURRENT_USER AS
/*$Header: mthcmtbs.pls 120.0.12010000.1 2010/03/15 21:47:42 lvenkatr noship $*/

--Added for Composite Primary key

PROCEDURE CALL_NTB_UPLOAD_COMPOSITE_PK(P_TARGET IN VARCHAR2);

END MTH_COMMON_PKG;


/
