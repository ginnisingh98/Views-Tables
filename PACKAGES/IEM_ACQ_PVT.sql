--------------------------------------------------------
--  DDL for Package IEM_ACQ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_ACQ_PVT" AUTHID CURRENT_USER AS
/* $Header: iemacqvs.pls 120.0 2005/06/02 13:59:48 appldev noship $ */

PROCEDURE ENUMERATE_ACQUIRED_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  );

END IEM_ACQ_PVT;

 

/
