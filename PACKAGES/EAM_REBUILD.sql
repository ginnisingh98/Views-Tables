--------------------------------------------------------
--  DDL for Package EAM_REBUILD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_REBUILD" AUTHID CURRENT_USER as
/* $Header: EAMRBLDS.pls 115.0 2004/04/29 04:06:36 cboppana noship $ */

--creates a rebuild workorder and updates the genealogy
  procedure create_rebuild_job(p_tempId IN NUMBER,
                              x_retVal OUT NOCOPY VARCHAR2,
                              x_errMsg OUT NOCOPY VARCHAR2);

end eam_rebuild;

 

/
