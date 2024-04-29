--------------------------------------------------------
--  DDL for Package QLTPVWWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTPVWWB" AUTHID CURRENT_USER as
/* $Header: qltpvwwb.pls 120.0 2005/05/25 06:31:48 appldev noship $ */

-- 3/25/95 - CREATED
-- Kevin Wiggen

--  This is a wrapper for the plan dynamic view.
--  It is needed for the concurrent manager to run
--

   PROCEDURE WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                     RETCODE OUT NOCOPY NUMBER,
                     ARGUMENT1 IN VARCHAR2,    -- plan view name
                     ARGUMENT2 IN VARCHAR2,    -- old plan view name
                     ARGUMENT3 IN NUMBER,      -- plan_id
                     ARGUMENT4 IN VARCHAR2,    -- import view name
                     ARGUMENT5 IN VARCHAR2,    -- old import view name
                     ARGUMENT6 IN VARCHAR2);   -- global view name


   -- anagarwa Mon Nov 29 11:09:05 PST 2004
   -- bug 3918659 Global View creation during collection plan saving causes
   -- unacceptable performance issues.
   -- I am making global view an on demand feature by introducing a new
   -- concurrent program. . Following procedure will
   -- be used as the program for executable for this new concurrent program
   PROCEDURE GLOBAL_V_WRAPPER(ERRBUF OUT NOCOPY VARCHAR2,
                              RETCODE OUT NOCOPY NUMBER);

END QLTPVWWB;

 

/
