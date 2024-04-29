--------------------------------------------------------
--  DDL for Package Body IGW_SUBJECT_INFORMATION_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_SUBJECT_INFORMATION_TBH" as
 /* $Header: igwtsuib.pls 115.5 2002/11/15 00:50:58 ashkumar ship $ */
procedure INSERT_ROW (
  X_ROWID                           out NOCOPY rowid,
  X_STUDY_TITLE_ID                  IN  NUMBER,
  X_SUBJECT_TYPE_CODE               IN  VARCHAR2,
  X_SUBJECT_RACE_CODE               IN  VARCHAR2,
  X_SUBJECT_ETHNICITY_CODE	    IN  VARCHAR2,
  X_NO_OF_SUBJECTS                  IN  NUMBER,
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  ) is
    cursor C is select ROWID from IGW_SUBJECT_INFORMATION
    where STUDY_TITLE_ID = X_STUDY_TITLE_ID and SUBJECT_TYPE_CODE = X_SUBJECT_TYPE_CODE;
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  insert into IGW_SUBJECT_INFORMATION (
   STUDY_TITLE_ID,
   SUBJECT_TYPE_CODE,
   SUBJECT_RACE_CODE,
   SUBJECT_ETHNICITY_CODE,
   NO_OF_SUBJECTS,
   RECORD_VERSION_NUMBER)
   values (
   X_STUDY_TITLE_ID,
   X_SUBJECT_TYPE_CODE,
   X_SUBJECT_RACE_CODE,
   X_SUBJECT_ETHNICITY_CODE,
   X_NO_OF_SUBJECTS,
   1);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_SUBJECT_INFORMATION_TBH'
                              ,p_procedure_name => 'INSERT_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE Fnd_Api.G_Exc_Unexpected_Error;

end INSERT_ROW;

-----------------------------------------------------------------------

procedure UPDATE_ROW (
  X_ROWID                           IN ROWID,
  X_STUDY_TITLE_ID                  IN  NUMBER,
  X_SUBJECT_TYPE_CODE               IN  VARCHAR2,
  X_SUBJECT_RACE_CODE               IN  VARCHAR2,
  X_SUBJECT_ETHNICITY_CODE	    IN  VARCHAR2,
  X_NO_OF_SUBJECTS                  IN  NUMBER,
  X_RECORD_VERSION_NUMBER           IN NUMBER,
  X_RETURN_STATUS                   OUT NOCOPY VARCHAR2
  ) is

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_rowid IS NULL THEN
    RAISE NO_DATA_FOUND;
  END IF;

  update igw_subject_information set
    study_title_id = x_study_title_id,
    subject_type_code = x_subject_type_code,
    subject_race_code = x_subject_race_code,
    subject_ethnicity_code = x_subject_ethnicity_code,
    no_of_subjects = x_no_of_subjects,
    record_version_number = x_record_version_number +1
  where rowid = x_rowid
    and   record_version_number = x_record_version_number;

  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_SUBJECT_INFORMATION_TBH'
                              ,p_procedure_name => 'UPDATE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE Fnd_Api.G_Exc_Unexpected_Error;

end UPDATE_ROW;

---------------------------------------------------------------------------------

procedure DELETE_ROW (
  x_rowid in rowid
  ,x_record_version_number in number
  ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
) is

  l_record_version_number  NUMBER;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  delete from igw_subject_information
  where rowid = x_rowid
  and   record_version_number = x_record_version_number;

  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_SUBJECT_INFORMATION_TBH'
                              ,p_procedure_name => 'DELETE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE Fnd_Api.G_Exc_Unexpected_Error;
end DELETE_ROW;

end IGW_SUBJECT_INFORMATION_TBH;

/
