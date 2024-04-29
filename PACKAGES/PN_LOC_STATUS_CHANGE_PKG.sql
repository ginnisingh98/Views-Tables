--------------------------------------------------------
--  DDL for Package PN_LOC_STATUS_CHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_LOC_STATUS_CHANGE_PKG" AUTHID CURRENT_USER AS
  -- $Header: PNLOCSTS.pls 115.3 2002/11/12 23:02:22 stripath noship $


PROCEDURE activate_deact_location (
                             errbuf                         OUT NOCOPY VARCHAR2
                            ,retcode                        OUT NOCOPY VARCHAR2
                            ,p_action                           VARCHAR2
                            ,p_loc_type                         VARCHAR2
                            ,p_loc_code_low                     VARCHAR2
                            ,p_loc_code_high                    VARCHAR2
                            );


---------------------------------------------------------------------------------------
-- End of Pkg
---------------------------------------------------------------------------------------
END pn_loc_status_change_pkg;

 

/
