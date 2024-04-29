--------------------------------------------------------
--  DDL for Package IEC_LISTVALID_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_LISTVALID_PVT" AUTHID CURRENT_USER AS
/* $Header: IECLSTVS.pls 115.4 2003/08/22 20:41:54 hhuang noship $ */

PROCEDURE LAUNCHVALIDATION
(listheaderid IN NUMBER);

PROCEDURE INITRECORD
(
  listheaderid IN NUMBER,
  userid IN NUMBER

);


END IEC_LISTVALID_PVT;

 

/
