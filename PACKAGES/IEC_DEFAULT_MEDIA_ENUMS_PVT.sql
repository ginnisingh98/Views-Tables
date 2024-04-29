--------------------------------------------------------
--  DDL for Package IEC_DEFAULT_MEDIA_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_DEFAULT_MEDIA_ENUMS_PVT" AUTHID CURRENT_USER AS
/* $Header: IECENMVS.pls 115.7 2003/08/22 20:41:26 hhuang ship $ */


PROCEDURE ENUMERATE_ADV_OUTB_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER );

END IEC_DEFAULT_MEDIA_ENUMS_PVT;

 

/
