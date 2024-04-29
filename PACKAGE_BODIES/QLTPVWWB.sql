--------------------------------------------------------
--  DDL for Package Body QLTPVWWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTPVWWB" as
/* $Header: qltpvwwb.plb 120.0 2005/05/24 18:06:42 appldev noship $ */

-- 3/25/95 - CREATED
-- Kevin Wiggen
-- 8/20/97 - MODIFIED
-- Dave Stephens
--  consolidated all dynamic view creation wrappers
--  into this wrapper
--
--  This is a wrapper for dynamic view creation.
--  It is needed for the concurrent manager to run
--

   PROCEDURE WRAPPER(ERRBUF     OUT NOCOPY VARCHAR2,
                     RETCODE    OUT NOCOPY NUMBER,
                     ARGUMENT1  IN VARCHAR2,    -- plan view name
                     ARGUMENT2  IN VARCHAR2,    -- old plan view name
                     ARGUMENT3  IN NUMBER,      -- plan_id
                     ARGUMENT4  IN VARCHAR2,    -- import view name
                     ARGUMENT5  IN VARCHAR2,    -- import old view name
                     ARGUMENT6  IN VARCHAR2)    -- global view name
   IS
   BEGIN
      --only do the plan view and import plan view if we got args1,3,4 - this allows us to call this
      --procedure to just regen the global view name
      IF ARGUMENT3 IS NOT NULL THEN
         QLTVCREB.PLAN_VIEW(ARGUMENT1,ARGUMENT2,ARGUMENT3);
         QLTVCREB.IMPORT_PLAN_VIEW(ARGUMENT4,ARGUMENT5,ARGUMENT3);
      END IF;


      -- anagarwa Tue Nov 30 16:52:24 PST 2004
      -- Bug 3918659
      -- Commenting the following global view creation to resolve
      -- the performance issue.This is already done in mainline
      -- version 115.5.

      --only do the global view regen if ARGUMENT6 is not null
      -- IF ARGUMENT6 IS NOT NULL THEN
      --   QLTVCREB.GLOBAL_VIEW(ARGUMENT6);
      -- END IF;

      RETCODE := 0;
      ERRBUF := '';
   END WRAPPER;

   -- anagarwa Mon Nov 29 11:09:05 PST 2004
   -- bug 3918659 Global View creation during collection plan saving causes
   -- unacceptable performance issues.
   -- I am making global view an on demand feature by introducing a new
   -- concurrent program. . Following procedure will
   -- be used as the program for executable for this new concurrent program

   PROCEDURE GLOBAL_V_WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                              RETCODE OUT NOCOPY NUMBER)
   IS
   BEGIN
      QLTVCREB.GLOBAL_VIEW('QA_GLOBAL_RESULTS_V');
      RETCODE := 0;
      ERRBUF := '';
    END GLOBAL_V_WRAPPER;


END QLTPVWWB;

/
