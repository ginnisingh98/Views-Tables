--------------------------------------------------------
--  DDL for Package CSF_PLAN_TERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_PLAN_TERRS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSFVPLTS.pls 115.7 2003/10/16 06:35:29 srengana ship $ */

/*
+========================================================================+
|                 Copyright (c) 1999 Oracle Corporation                  |
|                    Redwood Shores, California, USA                     |
|                         All rights reserved.                           |
+========================================================================+
Name
----
CSF_PLAN_TERRS_PKG

Purpose
-------
Insert, lock and delete records in the CSF_PLAN_TERRS table.
Check uniqueness of columns PLAN_TERR_ID and TERR_ID/GROUP_ID combinations.
Check referential integrity of the TERR_ID and GROUP_ID columns.

History
-------
6-JAN-2000 ipels          - First creation
13-NOV-2002 jgrondel      Bug 2663989.
                          Added NOCOPY hint to procedure
                          out-parameters.
13-NOV-2002 jgrondel      Added dbdrv.
03-dec-2002 jgrondel      Bug 2692082.
                          Added NOCOPY hint to procedure
                          out-parameters.

+========================================================================+
*/


PROCEDURE Check_Unique
( p_rowid    IN VARCHAR2,
  p_terr_id  IN NUMBER,
  p_group_id IN NUMBER
);

PROCEDURE Check_References
( p_terr_id  IN NUMBER,
  p_group_id IN NUMBER
);

PROCEDURE Insert_Row
( x_rowid    IN OUT NOCOPY VARCHAR2,
  p_terr_id  IN     NUMBER,
  p_group_id IN     NUMBER
);

PROCEDURE Delete_Row
( p_rowid IN VARCHAR2
);

PROCEDURE Lock_Row
( p_rowid                 IN VARCHAR2,
  p_object_version_number IN NUMBER
);


END;



 

/
