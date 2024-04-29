--------------------------------------------------------
--  DDL for Package BIL_OBI_GROUPS_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIL_OBI_GROUPS_DENORM_PKG" AUTHID CURRENT_USER AS
/*$Header: bilobieesgs.pls 120.0.12000000.1 2007/04/12 06:04:04 kreardon noship $*/

 PROCEDURE load(errbuf              IN OUT NOCOPY VARCHAR2,
                retcode             IN OUT NOCOPY  VARCHAR2);

END BIL_OBI_GROUPS_DENORM_PKG;

 

/
