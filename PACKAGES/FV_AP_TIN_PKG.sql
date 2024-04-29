--------------------------------------------------------
--  DDL for Package FV_AP_TIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_TIN_PKG" AUTHID CURRENT_USER AS
-- $Header: FVAPTNCS.pls 120.2 2002/11/11 19:56:26 ksriniva noship $

PROCEDURE TIN_VALIDATE(FIELD_NAME     IN  varchar2,
                       PROC_RESULT    OUT NOCOPY varchar2,
                       RESULT_MESSAGE OUT NOCOPY varchar2);

END FV_AP_TIN_PKG;

 

/
