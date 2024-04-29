--------------------------------------------------------
--  DDL for Package JE_ES_MODELO_190_ALL_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JE_ES_MODELO_190_ALL_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: jeesupgs.pls 120.0 2006/05/19 17:59:26 rjreddy noship $ */

PROCEDURE upgrade_main (errbuf OUT NOCOPY varchar2,
                        retcode OUT NOCOPY number);

END je_es_modelo_190_all_upgrade;


 

/
