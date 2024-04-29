--------------------------------------------------------
--  DDL for Package IBE_BI_STR_MIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_BI_STR_MIG_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEBISTRMIGS.pls 115.3 2003/05/15 10:03:37 suchandr noship $ */



PROCEDURE run_migration(errbuf                   OUT NOCOPY VARCHAR2,
                        retcode                  OUT NOCOPY VARCHAR2,
                        p_auto_defaulting_flag   IN         VARCHAR2 ,
                        p_override_minisite_flag IN         VARCHAR2,
                        p_running_mode           IN         VARCHAR2,
                        p_string_in              IN         VARCHAR2,
				    p_batch_size             IN         NUMBER);


END ibe_bi_str_mig_pvt;

 

/
