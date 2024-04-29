--------------------------------------------------------
--  DDL for Package XLA_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_PURGE_PKG" AUTHID CURRENT_USER AS
/* $Header: xlapurge.pkh 120.0.12010000.3 2009/10/20 06:39:51 rajose noship $ */


FUNCTION GetGroupID(p_gltname IN VARCHAR2)
RETURN NUMBER;

PROCEDURE drop_glt
   (  p_errbuf          OUT NOCOPY VARCHAR2
     ,p_retcode         OUT NOCOPY NUMBER
     ,p_application_id  IN NUMBER
     ,p_dummy_parameter IN VARCHAR2
     ,p_ledger_id       IN NUMBER
     ,p_end_date        IN VARCHAR2 );


END XLA_PURGE_PKG;

/
