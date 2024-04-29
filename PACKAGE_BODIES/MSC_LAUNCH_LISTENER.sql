--------------------------------------------------------
--  DDL for Package Body MSC_LAUNCH_LISTENER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_LAUNCH_LISTENER" AS -- body
/* $Header: MSCLSTNB.pls 120.1 2005/06/21 01:59:29 appldev ship $ */

  PROCEDURE LAUNCH_LISTENER( ERRBUF                OUT NOCOPY VARCHAR2,
                           RETCODE               OUT NOCOPY NUMBER,
                           p_agent_name          IN  VARCHAR2)
  IS

  BEGIN

    wf_log_pkg.wf_debug_flag := TRUE;

    wf_event.listen(p_agent_name);

   RETCODE := G_SUCCESS;

  EXCEPTION
    when others then
        ERRBUF  := SQLERRM;
        RETCODE := G_ERROR;
  END LAUNCH_LISTENER;

END MSC_LAUNCH_LISTENER;


/
