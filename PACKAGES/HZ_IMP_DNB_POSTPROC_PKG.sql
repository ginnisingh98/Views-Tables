--------------------------------------------------------
--  DDL for Package HZ_IMP_DNB_POSTPROC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_DNB_POSTPROC_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLDBPS.pls 120.3 2005/10/30 03:52:48 appldev noship $*/


 PROCEDURE POST_PROCESSING (
  errbuf      OUT NOCOPY     VARCHAR2,
  retcode     OUT NOCOPY     VARCHAR2,
  p_batchid  IN             VARCHAR2);

END HZ_IMP_DNB_POSTPROC_PKG; -- Package spec
 

/
