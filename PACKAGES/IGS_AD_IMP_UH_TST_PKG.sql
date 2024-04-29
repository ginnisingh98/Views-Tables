--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_UH_TST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_UH_TST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADA5S.pls 115.7 2002/11/28 21:47:56 nsidana ship $ */

PROCEDURE imp_convt_tst_scrs
(   errbuf		OUT NOCOPY VARCHAR2,
  retcode		OUT NOCOPY NUMBER,
  p_group_id		IN  NUMBER,
  p_org_id		IN  NUMBER
);

PROCEDURE transfer_int_oss
(
p_person_id	IN NUMBER,
p_session_id	IN NUMBER
);

END IGS_AD_IMP_UH_TST_PKG;

 

/
