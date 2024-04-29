--------------------------------------------------------
--  DDL for Package MSC_PROFILE_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_PROFILE_PRE_PROCESS" AUTHID CURRENT_USER AS
/* $Header: MSCPFPPS.pls 115.0 2004/07/30 09:00:06 rawasthi noship $ */


  ----- CONSTANTS --------------------------------------------------------
  G_ERROR  CONSTANT NUMBER := 2;

  SYS_YES                      CONSTANT NUMBER := 1;
  SYS_NO                       CONSTANT NUMBER := 2;

 --  ================= PROCEDURES ====================
  PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2);

  PROCEDURE setprofile(ERRBUF          OUT NOCOPY VARCHAR2,
                       RETCODE         OUT NOCOPY NUMBER,
                       p_preference_set_name IN VARCHAR2,
		       p_upload_profile IN NUMBER);

  PROCEDURE MSC_PROF_PRE_PROCESS (ERRBUF          OUT NOCOPY VARCHAR2,
                                  RETCODE         OUT NOCOPY NUMBER,
                                  p_preference_set_name   IN VARCHAR2,
				   p_upload_profile IN NUMBER);


  END MSC_PROFILE_PRE_PROCESS;

 

/
