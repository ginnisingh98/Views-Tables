--------------------------------------------------------
--  DDL for Package FTP_BR_IRCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_BR_IRCS_PVT" AUTHID CURRENT_USER AS
/* $Header: ftpircss.pls 120.1 2006/01/26 08:37:52 appldev noship $ */
---------------------------------------------------------------------
-- Translate Row for FTP_IRCS_TL
---------------------------------------------------------------------

PROCEDURE TranslateRow(
  x_INTEREST_RATE_CODE IN NUMBER,
  x_DESCRIPTION IN VARCHAR2,
  x_last_update_date IN VARCHAR2,
  x_owner IN VARCHAR2,
  x_custom_mode IN VARCHAR2);

-- bomathew 20060126 - Bug 4902755
procedure ADD_LANGUAGE;

END FTP_BR_IRCS_PVT;


 

/
