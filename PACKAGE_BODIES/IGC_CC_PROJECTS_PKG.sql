--------------------------------------------------------
--  DDL for Package Body IGC_CC_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_PROJECTS_PKG" AS
/*$Header: IGCCCPAB.pls 120.5 2006/01/20 06:29:27 vkilambi noship $*/

   /*----------------------------------------------------------------------
   Procedure   : Delete_Project
   Purpose     : This function is used by the Projects Accounting Team
                 to determine if a project can be purged or not.
                 if a project is associated with a contract commitment
                 then it cannot be purged.
   Parameters  : P_Project_Id  IN , The Project Id
   Returns     : Varchar2 ,Y  = project can be deleted
                           N  = project cannot be deleted
   ----------------------------------------------------------------------*/
   PROCEDURE Delete_Project (P_project_id     IN NUMBER,
                             P_delete_allowed OUT NOCOPY VARCHAR2)
   IS

   BEGIN

NULL;

   END Delete_Project;

END IGC_CC_PROJECTS_PKG;

/
