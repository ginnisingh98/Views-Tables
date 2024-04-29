--------------------------------------------------------
--  DDL for Package HR_GL_COST_CENTERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GL_COST_CENTERS" AUTHID CURRENT_USER AS
/* $Header: hrglcsyn.pkh 115.5 2003/04/03 12:00:31 fsheikh noship $ */

Procedure synch_orgs(errbuf               in out nocopy VARCHAR2
                    , retcode             in out nocopy NUMBER
                    , p_mode              IN            VARCHAR2
                    , p_business_group_id IN            NUMBER default null
                    , P_CCID              in            number default null
                    , p_coa               in            NUMBER default null);

Procedure create_org(p_ccid IN NUMBER);

END hr_gl_cost_centers;


 

/
