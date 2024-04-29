--------------------------------------------------------
--  DDL for Package GMD_SS_ERES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SS_ERES_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDQSERS.pls 115.0 2003/04/17 22:08:36 hsaleeb noship $ */

/* ######################################################################## */

   PROCEDURE GET_TO_STATUS(
   /* procedure to get Target status description */
      p_instatus      IN NUMBER,
      p_outstatus_desc     OUT NOCOPY VARCHAR2
   );

   PROCEDURE GET_RESOURCE_DESC(
   /* procedure to get Resource Description */
      p_se_id      IN NUMBER,
      p_resource_desc     OUT NOCOPY VARCHAR2
   );

END GMD_SS_ERES_PKG ;

 

/
