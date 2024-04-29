--------------------------------------------------------
--  DDL for Package IGS_PS_LGCY_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_LGCY_CONC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS87S.pls 120.1 2005/10/04 00:30:22 appldev ship $ */

PROCEDURE legacy_batch_process(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_n_batch_id NUMBER,
  p_c_del_flag VARCHAR2
  );

END igs_ps_lgcy_conc_pkg;

 

/
