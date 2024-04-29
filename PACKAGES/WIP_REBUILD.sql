--------------------------------------------------------
--  DDL for Package WIP_REBUILD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_REBUILD" AUTHID CURRENT_USER as
/* $Header: wiprblds.pls 115.6.1159.1 2003/05/09 01:22:34 appldev ship $ */

--inserts record into wjsi
--spawns process
--updates genealogy if spawn was successful
  procedure create_rebuild_job(p_tempId IN NUMBER,
                              x_retVal OUT NOCOPY VARCHAR2,
                              x_errMsg OUT NOCOPY VARCHAR2);

end wip_rebuild;

 

/
