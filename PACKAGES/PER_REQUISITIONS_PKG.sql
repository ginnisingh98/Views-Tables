--------------------------------------------------------
--  DDL for Package PER_REQUISITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_REQUISITIONS_PKG" AUTHID CURRENT_USER as
/* $Header: pereq01t.pkh 115.1 2003/01/27 18:51:52 irgonzal ship $ */
--
/*   +=======================================================================+
     |           Copyright (c) 1993 Oracle Corporation                       |
     |              Redwood Shores, California, USA                          |
     |                   All rights reserved.                                |
     +========================================================================
 Name
    per_requisitions_pkg
  Purpose
    Supports the REQUISITION block in the form PERWSVAC (Define REquistion
    and Vacancy).
  Notes

  History
    13-Apr-94  H.Minton   40.0         Date created.
    02-FEB-95  D.Kerr     70.4         Removed WHO columns

    27-JAN-03  irgonzal   115.1        Fixed gscc errors.

=============================================================================*/
--
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_Unique_Name                                                     --
-- Purpose                                                                 --
--   checks that the requisition name is unique. Called from the client    --
--   side package REQUISITION_ITEMS from the procedure 'name'. Called      --
--   on WHEN-VALIDATE-ITEM from Name.                                      --
--                                                                         --
-----------------------------------------------------------------------------
--
PROCEDURE Check_Unique_Name(P_Name                      VARCHAR2,
                            P_Business_group_id         NUMBER,
                            P_rowid                     VARCHAR2);
--
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Chk_date_from                                                         --
-- Purpose                                                                 --
--   checks that the requisition date_from is within the vacancy date_from --
--   for the same requisition_id.                                          --
-----------------------------------------------------------------------------
--
PROCEDURE Chk_date_from(P_Date_from                 DATE,
                        P_Business_Group_Id         NUMBER,
                        P_Requisition_Id            NUMBER);
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Date_from_raised_by                                                   --
-- Purpose                                                                 --
--   checks that the requisition date_from does not invalidate the person  --
--   who raised the requisition.                                           --
-----------------------------------------------------------------------------
--
PROCEDURE Date_from_raised_by(P_Person_id                 NUMBER,
                              P_Business_Group_Id         NUMBER,
                              P_Date_from                 DATE);
-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Date_to_in_vac_dates                                                  --
-- Purpose                                                                 --
--   checks that the requisition date_to does not invalidate the vacancy   --
--   child records.                                                        --
-----------------------------------------------------------------------------
--
PROCEDURE Date_to_in_vac_dates(P_Requisition_id            NUMBER,
                               P_Business_Group_Id         NUMBER,
                               P_Date_to                   DATE);
-----------------------------------------------------------------------------
-- Name                                                                    --
--   Check_References                                                      --
-- Purpose                                                                 --
--   checks that deletes cannot take place of a requisition if             --
--   there are any child vacancies.
-----------------------------------------------------------------------------
PROCEDURE Check_References(P_requisition_id             NUMBER,
                           P_Business_group_id          NUMBER);
--
------------------------------------------------------------------------------
PROCEDURE Insert_Row(X_Rowid                         IN OUT nocopy VARCHAR2,
                     X_Requisition_Id                IN OUT nocopy NUMBER,
                     X_Business_Group_Id                    NUMBER,
                     X_Person_Id                            NUMBER,
                     X_Date_From                            DATE,
                     X_Name                                 VARCHAR2,
                     X_Comments                             VARCHAR2,
                     X_Date_To                              DATE,
                     X_Description                          VARCHAR2,
                     X_Attribute_Category                   VARCHAR2,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Attribute11                          VARCHAR2,
                     X_Attribute12                          VARCHAR2,
                     X_Attribute13                          VARCHAR2,
                     X_Attribute14                          VARCHAR2,
                     X_Attribute15                          VARCHAR2,
                     X_Attribute16                          VARCHAR2,
                     X_Attribute17                          VARCHAR2,
                     X_Attribute18                          VARCHAR2,
                     X_Attribute19                          VARCHAR2,
                     X_Attribute20                          VARCHAR2
                     );
PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Requisition_Id                         NUMBER,
                   X_Business_Group_Id                      NUMBER,
                   X_Person_Id                              NUMBER,
                   X_Date_From                              DATE,
                   X_Name                                   VARCHAR2,
                   X_Comments                               VARCHAR2,
                   X_Date_To                                DATE,
                   X_Description                            VARCHAR2,
                   X_Attribute_Category                     VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Attribute11                            VARCHAR2,
                   X_Attribute12                            VARCHAR2,
                   X_Attribute13                            VARCHAR2,
                   X_Attribute14                            VARCHAR2,
                   X_Attribute15                            VARCHAR2,
                   X_Attribute16                            VARCHAR2,
                   X_Attribute17                            VARCHAR2,
                   X_Attribute18                            VARCHAR2,
                   X_Attribute19                            VARCHAR2,
                   X_Attribute20                            VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Requisition_Id                      NUMBER,
                     X_Business_Group_Id                   NUMBER,
                     X_Person_Id                           NUMBER,
                     X_Date_From                           DATE,
                     X_Name                                VARCHAR2,
                     X_Comments                            VARCHAR2,
                     X_Date_To                             DATE,
                     X_Description                         VARCHAR2,
                     X_Attribute_Category                  VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Attribute11                         VARCHAR2,
                     X_Attribute12                         VARCHAR2,
                     X_Attribute13                         VARCHAR2,
                     X_Attribute14                         VARCHAR2,
                     X_Attribute15                         VARCHAR2,
                     X_Attribute16                         VARCHAR2,
                     X_Attribute17                         VARCHAR2,
                     X_Attribute18                         VARCHAR2,
                     X_Attribute19                         VARCHAR2,
                     X_Attribute20                         VARCHAR2
                     );

PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END PER_REQUISITIONS_PKG;

 

/
