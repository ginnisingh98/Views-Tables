--------------------------------------------------------
--  DDL for Package IGS_EN_GEN_016
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GEN_016" AUTHID CURRENT_USER AS
/* $Header: IGSENA1S.pls 115.2 2002/12/27 14:00:31 savenkat noship $ */

PROCEDURE enrp_batch_reg_upd(
errbuf            OUT NOCOPY VARCHAR2,
retcode           OUT NOCOPY NUMBER,
p_batch_id        IN VARCHAR2,
p_enr_method_type IN VARCHAR2 DEFAULT NULL);

END igs_en_gen_016;

 

/
