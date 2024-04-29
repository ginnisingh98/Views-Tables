--------------------------------------------------------
--  DDL for Package ADI_SECURED_VALUES_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADI_SECURED_VALUES_ACCESS" AUTHID CURRENT_USER AS
/* $Header: frmsevas.pls 120.0 2006/12/14 02:07:47 dvayro noship $ */
----------------------------------------------------------------------------------------
--  PROCEDURE:    ADI_Secured_Values_Access                                           --
--                                                                                    --
--  Description:  Content security needs to be accessed in one of two ways:           --
--                  1.  Which expansions values does this user have access to?        --
--                  2.  Does this user have access to this expansion value?           --
--                                                                                    --
--                This package allows a call to be made to either of the procs        --
--                and returns either a list of accessible expansion values, or        --
--                a TRUE or FALSE flag, indicating access.                            --
--                                                                                    --
--  Modifications                                                                     --
--  Date       Username   Description                                                 --
--  16-FEB-00  cclyde     Added Package_Revision procedure to see if we can capture   --
--                        the revision number of the package during runtime.          --
--                              (Task:  3858)                                         --
--  16-MAY-00  GSANAP     Moved the $Header comment from the top to under             --
--                        the CREATE OR REPLACE PACKAGE stmt.                         --
--   15-NOV-02  GHOOKER    Stub out procedures not used by RM8                        --
----------------------------------------------------------------------------------------
END ADI_Secured_Values_Access;

 

/
