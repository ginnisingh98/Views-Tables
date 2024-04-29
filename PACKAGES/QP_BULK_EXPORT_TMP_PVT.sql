--------------------------------------------------------
--  DDL for Package QP_BULK_EXPORT_TMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_BULK_EXPORT_TMP_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXBTEXS.pls 120.0 2005/06/02 01:06:44 appldev noship $ */

g_interface_action	varchar2(30);

PROCEDURE EXPORT_TMP_PRICING_DATA
(
  err_buff     OUT NOCOPY  VARCHAR2
 ,retcode      OUT NOCOPY  NUMBER
 ,list_from                NUMBER
 ,list_to                  NUMBER
 ,p_entity_name		   VARCHAR2
 ,interface_action	   VARCHAR2
);

PROCEDURE EXPORT_TMP_LISTS
(
 	list_from                      NUMBER
	,p_entity_name                  VARCHAR2
);

PROCEDURE EXPORT_TMP_QUALIFIERS
(
 	list_from                      NUMBER
	,p_entity_name                  VARCHAR2
);
PROCEDURE EXPORT_TMP_LINES
(
 	list_from                      NUMBER
	,p_entity_name                  VARCHAR2
);
PROCEDURE EXPORT_TMP_ATTRIBS
(
 	list_from                      NUMBER
	,p_entity_name                  VARCHAR2
);

END QP_BULK_EXPORT_TMP_PVT;


 

/
