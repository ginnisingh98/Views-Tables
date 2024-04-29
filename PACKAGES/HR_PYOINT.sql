--------------------------------------------------------
--  DDL for Package HR_PYOINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PYOINT" AUTHID CURRENT_USER as
/* $Header: pyasgint.pkh 120.0 2005/05/29 03:01:22 appldev noship $ */
--
/*
/*
   Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved

   Name        : hr_pyoint

   Description : Procedure definition for hr_pyoint.

   Test List
   ---------

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   24-SEP-2004  NBRISTOW    115.1           Fixed GSCC errors.
   30-OCT-1996  ARASHID     3.1    397298   Modified to return assignment_number
                                            to enable logging of assignments
                                            that fail interlock rules.
   29-JAN-1993  DSAXBY      3.0             First created.
*/
--
   ----------------------------- validate -------------------------------------
   /*
      NAME
         validate - validates assignment interlocks.
      DESCRIPTION
         This procedure validates assignment level interlock rules
         for the run on an individual assignment basis.
         It is called from the main run code when interlock flag
         is set to 'Y'.
      NOTES
         <none>
   */
   procedure validate
   (
      pactid   in out nocopy number,   -- payroll_action_id.
      assignid in out nocopy number,   -- assignment_action_id to check.
      itpflag  in out nocopy varchar2, -- independent time periods flag.
      assnum   in out nocopy varchar2, -- returned assignment_number.
      intstat  in out nocopy number    -- interlock status.
   );
end hr_pyoint;

 

/
