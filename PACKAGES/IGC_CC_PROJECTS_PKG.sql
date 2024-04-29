--------------------------------------------------------
--  DDL for Package IGC_CC_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_PROJECTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCCPAS.pls 120.5 2006/01/20 06:28:59 vkilambi noship $ */

PROCEDURE Delete_Project (p_project_id           IN       NUMBER,
                          p_delete_allowed       OUT NOCOPY      VARCHAR2);

END IGC_CC_PROJECTS_PKG;

 

/
