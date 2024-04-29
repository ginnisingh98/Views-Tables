--------------------------------------------------------
--  DDL for Package ENI_UPGRADE_VSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_UPGRADE_VSET" AUTHID CURRENT_USER AS
/* $Header: ENIVSTUS.pls 115.0 2003/08/21 13:32:47 dsakalle noship $  */

PROCEDURE UPDATE_CATSET_FROM_VSET (
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_top_node        IN VARCHAR2,
    p_validation_mode IN VARCHAR2);

FUNCTION eni_validate_setup RETURN NUMBER;

END ENI_UPGRADE_VSET;

 

/
