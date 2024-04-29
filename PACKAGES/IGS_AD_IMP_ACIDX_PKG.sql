--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_ACIDX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_ACIDX_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADA9S.pls 115.4 2002/11/28 21:48:25 nsidana ship $ */


PROCEDURE prgp_imp_acad_indx(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_acadindex_batch_id IN NUMBER,
  p_org_id IN NUMBER );

END igs_ad_imp_acidx_pkg;

 

/
