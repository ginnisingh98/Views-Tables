--------------------------------------------------------
--  DDL for Package HRI_OPL_BEN_DIM_REFRESH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_BEN_DIM_REFRESH" AUTHID CURRENT_USER AS
/* $Header: hripbdrf.pkh 120.0 2005/09/21 01:27:54 anmajumd noship $ */
  --
   PROCEDURE LOAD (
      p_full_refresh        IN              VARCHAR2
   );

   --
   PROCEDURE LOAD (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      p_full_refresh        IN              VARCHAR2
   );
--
END HRI_OPL_BEN_DIM_REFRESH;

 

/
