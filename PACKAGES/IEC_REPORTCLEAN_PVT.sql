--------------------------------------------------------
--  DDL for Package IEC_REPORTCLEAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_REPORTCLEAN_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVRPCS.pls 120.1 2006/01/16 09:06:14 minwang noship $ */

PROCEDURE CLEAN_DATA
   (P_SCHEDULE_ID            NUMBER
   ,P_RESET_TIME		    DATE
   );

PROCEDURE CLEANUP;

END IEC_REPORTCLEAN_PVT;


 

/
