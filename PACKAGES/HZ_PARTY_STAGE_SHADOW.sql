--------------------------------------------------------
--  DDL for Package HZ_PARTY_STAGE_SHADOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_STAGE_SHADOW" AUTHID CURRENT_USER AS
/*$Header: ARHDSHSS.pls 120.0 2005/08/18 00:08:06 nthaker noship $ */

TYPE StageCurTyp IS REF CURSOR;
PROCEDURE Stage (
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_num_workers           IN      VARCHAR2,
        p_continue              IN      VARCHAR2,
        p_tablespace            IN      VARCHAR2 DEFAULT NULL,
        p_index_creation        IN      VARCHAR2 DEFAULT NULL
);

PROCEDURE Stage_worker(
        errbuf                  OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_num_workers           IN      VARCHAR2,
        p_worker_number         IN      VARCHAR2,
        p_command               IN      VARCHAR2,
        p_continue              IN      VARCHAR2
);

PROCEDURE Stage_create_index (
        errbuf

       OUT NOCOPY    VARCHAR2,
        retcode                 OUT NOCOPY    VARCHAR2,
        p_command               IN      VARCHAR2,
        p_idx_mem               IN      VARCHAR2,
        p_num_prll              IN      VARCHAR2,
        p_index              	IN      VARCHAR2 DEFAULT 'ALL'
);

PROCEDURE generate_map_pkg_nolog;

END HZ_PARTY_STAGE_SHADOW;

 

/
