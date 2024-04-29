--------------------------------------------------------
--  DDL for Package IGS_OR_PRC_CWLK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_PRC_CWLK" AUTHID CURRENT_USER AS
/* $Header: IGSOR13S.pls 115.4 2002/11/29 01:48:54 nsidana ship $ */

  PROCEDURE transfer_data(errbuf  IN OUT NOCOPY VARCHAR2,
                          retcode IN OUT NOCOPY NUMBER,
                          p_org_id       NUMBER);
END igs_or_prc_cwlk;

 

/
