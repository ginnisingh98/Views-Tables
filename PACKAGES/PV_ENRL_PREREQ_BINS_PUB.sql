--------------------------------------------------------
--  DDL for Package PV_ENRL_PREREQ_BINS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENRL_PREREQ_BINS_PUB" AUTHID CURRENT_USER AS
/* $Header: pvxpebis.pls 120.1 2006/01/16 17:25:26 ktsao noship $*/

PROCEDURE Exec_Create_Elig_Prgm ( ERRBUF              OUT  NOCOPY VARCHAR2,
                                  RETCODE             OUT  NOCOPY VARCHAR2,
                                  p_log_to_file       IN VARCHAR2 := 'Y'
);

PROCEDURE get_matched_partners(
    x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_program_id                 IN   NUMBER
   ,x_matched_id_tbl             OUT  NOCOPY  JTF_NUMBER_TABLE
);

END PV_ENRL_PREREQ_BINS_PUB;

 

/
