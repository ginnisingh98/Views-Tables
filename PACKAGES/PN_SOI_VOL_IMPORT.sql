--------------------------------------------------------
--  DDL for Package PN_SOI_VOL_IMPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_SOI_VOL_IMPORT" AUTHID CURRENT_USER AS
  -- $Header: PNSOIMPS.pls 120.1 2007/01/23 12:42:36 pseeram ship $

  PROCEDURE import_vol_hist (
            errbuf    OUT  NOCOPY       varchar2,
            retcode   OUT  NOCOPY        varchar2,
           p_batch_id  IN            NUMBER
  );

PROCEDURE delete_vol_hist(
                        errbuf         OUT NOCOPY       varchar2,
                        retcode        OUT NOCOPY       varchar2,
                        p_batch_id     IN         NUMBER,
                        p_start_date   IN         varchar2,
                        p_end_date     IN         varchar2
				  );

g_org_id  NUMBER;
-------------------
-- End of Pkg
-------------------
END PN_SOI_VOL_IMPORT;

/
