--------------------------------------------------------
--  DDL for Package Body IGS_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PARTY_MERGE" AS
/* $Header: IGSPE06B.pls 115.6 2003/05/30 07:52:22 npalanis noship $ */

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
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
     BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
              END IF;
    END  merge_party;

   PROCEDURE MERGE_PERSON_PROFILE (
                             P_Entity_Name        IN      VARCHAR2,
                             P_From_Id            IN      NUMBER,
                             P_To_Id              IN OUT NOCOPY  NUMBER,
                             P_From_FK_Id         IN      NUMBER,
                             P_To_FK_Id           IN      NUMBER,
                             P_Parent_Entity_Name IN      VARCHAR2,
                             P_Batch_Id           IN      NUMBER,
                             P_Batch_Party_Id     IN      NUMBER,
                             X_Return_Status      IN OUT NOCOPY  VARCHAR2
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
              END IF;
    END  merge_person_profile;

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
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
             END IF;
    END  merge_education;

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
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
             END IF;
    END  merge_acad_hist;

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
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
             END IF;
    END  merge_party_rel;

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
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
             END IF;
    END  merge_emp_dtl;

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
                           ) AS
  /**********************************************************
  Created By : kpadiyar

  Date Created By : 10-AUG-2001

  Purpose : For Merge

  Know limitations, enhancements or remarks :

  Change History

   Who           When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    BEGIN
              IF p_from_FK_id = p_to_FK_id THEN
                 p_to_id := p_from_id;
                 return;
              ELSE
                 HZ_PARTY_MERGE.veto_delete;
                 FND_MESSAGE.SET_NAME('IGS','IGS_GE_PARTY_MERGE_CANT_DELETE');
                 FND_MESSAGE.SET_TOKEN('P_FROM_ID',P_From_ID);
                 fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
                 X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;
             END IF;
    END  merge_extracurr_act;
END igs_party_merge;

/
