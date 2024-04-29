--------------------------------------------------------
--  DDL for Package QA_BIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_BIS" AUTHID CURRENT_USER AS
/* $Header: qltbisb.pls 115.4 2002/11/27 19:22:22 jezheng ship $ */


   --
   -- Concurrent program wrapper to rebuild BIS summary table.
   --
   PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                     RETCODE OUT NOCOPY NUMBER,
                     ARGUMENT1 IN VARCHAR2,     -- Rebuild strategy
		     ARGUMENT2 IN VARCHAR2      -- # of rows between commits
		     );

   --
   -- QA_RESULTS delete audit trail.
   --
   PROCEDURE delete_log(x_occurrence number);


   --
   -- The following are for internal testing purposes.
   --

   PROCEDURE rebuild;

   PROCEDURE refresh;

END QA_BIS;


 

/
