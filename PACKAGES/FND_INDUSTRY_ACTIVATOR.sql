--------------------------------------------------------
--  DDL for Package FND_INDUSTRY_ACTIVATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_INDUSTRY_ACTIVATOR" AUTHID CURRENT_USER as
/* $Header: afindacts.pls 120.1 2005/08/15 16:45:13 dbowles noship $ */

procedure activate_industry(errbuf         OUT NOCOPY VARCHAR2,
                            retcode        OUT NOCOPY VARCHAR2,
                            p_industry_id  IN VARCHAR2);

procedure deactivate_industries(errbuf         OUT NOCOPY VARCHAR2,
                                retcode        OUT NOCOPY VARCHAR2);


end fnd_industry_activator;


 

/
