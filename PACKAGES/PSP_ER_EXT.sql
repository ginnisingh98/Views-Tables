--------------------------------------------------------
--  DDL for Package PSP_ER_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ER_EXT" AUTHID CURRENT_USER AS
/* $Header: PSPEREXS.pls 115.4 2002/04/17 19:20:50 pkm ship     $ */
/***********************************************************************************
**     NAME: psp_er_ext
** CONTENTS: Package Spec And Body  for psp_er_ext
**  PURPOSE: This Package contains one procedure(s).
**
**           1. PROCEDURE upd_include_flag
**              This procedure is an user defined user hook, which will be called
**              while a Effort Report is created , i.e. immediately after SUBMIT
**              button is pressed, once the  template is generated, but before it
**              is submitted to Concurrent Manager.
**   AUTHOR: Abhijit Prasad
**
************************************************************************************
***********************************************************************************/
---
   PROCEDURE upd_include_flag(a_template_id IN NUMBER);
END;

 

/
