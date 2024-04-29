--------------------------------------------------------
--  DDL for Package MSC_LAUNCH_LISTENER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_LAUNCH_LISTENER" AS-- specification
/* $Header: MSCLSTNS.pls 120.1 2005/06/21 02:01:13 appldev ship $ */

  ----- CONSTANTS --------------------------------------------------------

   G_CONC_ERROR                            CONSTANT NUMBER := 3;
   G_SUCCESS                               CONSTANT NUMBER := 0;
   G_WARNING                               CONSTANT NUMBER := 1;
   G_ERROR                                 CONSTANT NUMBER := 2;

  PROCEDURE LAUNCH_LISTENER( ERRBUF                OUT NOCOPY VARCHAR2,
                           RETCODE               OUT NOCOPY NUMBER,
                           p_agent_name          IN  VARCHAR2);

END MSC_LAUNCH_LISTENER;

 

/
