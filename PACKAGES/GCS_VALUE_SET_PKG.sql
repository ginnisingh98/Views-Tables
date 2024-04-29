--------------------------------------------------------
--  DDL for Package GCS_VALUE_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_VALUE_SET_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsvsets.pls 120.0 2005/09/30 23:13:09 mikeward noship $ */

 PROCEDURE  create_entity_value_set(x_errbuf	OUT NOCOPY VARCHAR2,
                            				x_retcode	OUT NOCOPY VARCHAR2);

 PROCEDURE  create_entity_value_set_hier( x_errbuf	 OUT NOCOPY VARCHAR2,
                                          x_retcode	 OUT NOCOPY VARCHAR2,
                                          p_eff_date IN  VARCHAR2);

END GCS_VALUE_SET_PKG;

 

/
