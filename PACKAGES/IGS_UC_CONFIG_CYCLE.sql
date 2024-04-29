--------------------------------------------------------
--  DDL for Package IGS_UC_CONFIG_CYCLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_CONFIG_CYCLE" AUTHID CURRENT_USER AS
/* $Header: IGSUC41S.pls 120.0 2005/06/01 16:48:10 appldev noship $ */

PROCEDURE conf_system_for_ucas_cycle( errbuf  OUT NOCOPY VARCHAR2,
				      retcode OUT NOCOPY NUMBER,
                                      p_target_cycle IN NUMBER,
		                      p_dblink_name IN VARCHAR2
                                    );

END igs_uc_config_cycle;

 

/
