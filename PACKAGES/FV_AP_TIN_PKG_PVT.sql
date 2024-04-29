--------------------------------------------------------
--  DDL for Package FV_AP_TIN_PKG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_TIN_PKG_PVT" AUTHID CURRENT_USER AS
-- $Header: FVXAPTNS.pls 120.2 2002/11/11 20:07:42 ksriniva noship $

PROCEDURE TIN_VALIDATE(FIELD_NAME     IN  varchar2,
                       PROC_RESULT    OUT NOCOPY varchar2,
                       RESULT_MESSAGE OUT NOCOPY varchar2);

END FV_AP_TIN_PKG_PVT;

 

/
