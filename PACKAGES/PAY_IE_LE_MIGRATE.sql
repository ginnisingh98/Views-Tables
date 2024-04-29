--------------------------------------------------------
--  DDL for Package PAY_IE_LE_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_LE_MIGRATE" AUTHID CURRENT_USER AS
/* $Header: pyiemigr.pkh 120.1 2005/11/30 05:34:36 sgajula noship $ */
PROCEDURE migrate_data(errbuf OUT NOCOPY VARCHAR2,
                       retcode OUT NOCOPY VARCHAR2,
                       p_bg_id IN NUMBER);

PROCEDURE revert_migration(p_bg_id IN NUMBER);
END pay_ie_le_migrate;

 

/
