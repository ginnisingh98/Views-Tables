--------------------------------------------------------
--  DDL for Package CSF_SPATIAL_DATALOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_SPATIAL_DATALOAD_PUB" AUTHID CURRENT_USER AS
/* $Header: CSFPSDLS.pls 120.0.12010000.2 2009/05/14 05:45:21 vpalle noship $ */

 g_debug_p             CONSTANT VARCHAR2 (100)
                          := 'begin dbms_' || 'output' || '.put_line(:1); end;';
 g_log                 CONSTANT NUMBER         := fnd_file.LOG;
 g_output              CONSTANT NUMBER         := fnd_file.output;
 g_debug                        BOOLEAN;

PROCEDURE POST_INSTALLATION_STEPS (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_dataset_name IN              VARCHAR2,
      p_table_space  IN              VARCHAR2,
      p_WOM_flag     IN              VARCHAR2);

PROCEDURE PRE_INSTALLATION_STEPS (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_dataset_name IN              VARCHAR2,
      p_WOM_flag     IN              VARCHAR2 );

PROCEDURE POST_INST_REFRESH_MVS (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_dataset_name IN              VARCHAR2,
      p_table_space  IN              VARCHAR2,
      p_referesh_mvs_flag IN         VARCHAR2,
      p_compute_statistics_flag IN   VARCHAR2);

End CSF_SPATIAL_DATALOAD_PUB;

/
