--------------------------------------------------------
--  DDL for Package GMD_QM_VALIDATE_FIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_QM_VALIDATE_FIX" AUTHID CURRENT_USER AS
/* $Header: GMDQVADS.pls 115.0 2004/05/10 21:06:23 magupta noship $ */


   PROCEDURE POPULATE_SPEC_HEADER;
   PROCEDURE Validation_Fix (p_migration_id in NUMBER DEFAULT NULL,
                             p_data_fix      IN BOOLEAN DEFAULT FALSE,
                             x_return_status OUT NOCOPY VARCHAR2);

END GMD_QM_VALIDATE_FIX;

 

/
