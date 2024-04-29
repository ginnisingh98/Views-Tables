--------------------------------------------------------
--  DDL for Package IGC_CBC_GL_FC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CBC_GL_FC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCBGFCS.pls 120.3.12000000.7 2007/11/05 12:15:02 dvjoshi ship $ */

FUNCTION GLZCBC
(
   p_mode              IN  VARCHAR2,
   p_conc_proc         IN  VARCHAR2 :=FND_API.G_FALSE
) RETURN NUMBER ;


FUNCTION  RECONCILE_GLZCBC
(
   p_mode               IN   VARCHAR2
) RETURN NUMBER;


END IGC_CBC_GL_FC_PKG;

 

/
