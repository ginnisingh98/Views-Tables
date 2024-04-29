--------------------------------------------------------
--  DDL for Package IGS_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PARTY_MERGE" AUTHID CURRENT_USER AS
/* $Header: IGSPE06S.pls 115.6 2003/05/30 07:51:52 npalanis noship $ */

/* This package is to incorporate the Oracle Student System Requirement
   for the R11i.1+Party Merge DLD  TCA
   Change History
   Who              When                  What
   npalanis         16-may-2003           Bug : 2853529
                                          Merge party relations new procedure added*/


   PROCEDURE MERGE_PARTY  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );

   PROCEDURE MERGE_PERSON_PROFILE  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );


   PROCEDURE MERGE_EDUCATION  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );

   PROCEDURE MERGE_ACAD_HIST  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );

   PROCEDURE MERGE_PARTY_REL  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );

   PROCEDURE MERGE_EMP_DTL  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );

   PROCEDURE MERGE_EXTRACURR_ACT  (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2

                           );


END IGS_PARTY_MERGE;

 

/
