--------------------------------------------------------
--  DDL for Package GL_AUTO_ALLOC_VW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTO_ALLOC_VW_PKG" AUTHID CURRENT_USER AS
/* $Header: glalvwfs.pls 120.2 2005/05/05 02:01:34 kvora ship $ */

 FUNCTION Get_Batch_Name(BATCH_TYPE_CODE IN VARCHAR2
                         , BATCH_ID IN NUMBER)
                        RETURN VARCHAR2;
           pragma restrict_references( Get_Batch_Name, WNDS,WNPS);

 FUNCTION Get_Owner_Dsp (OWNER IN VARCHAR2)
                         RETURN VARCHAR2;
           pragma restrict_references( Get_Owner_Dsp, WNDS,WNPS);

END gl_auto_alloc_vw_pkg;

 

/
