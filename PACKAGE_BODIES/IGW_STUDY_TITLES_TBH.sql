--------------------------------------------------------
--  DDL for Package Body IGW_STUDY_TITLES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_STUDY_TITLES_TBH" as
 /* $Header: igwtsttb.pls 115.5 2002/11/15 00:50:01 ashkumar ship $ */
procedure INSERT_ROW (
  X_ROWID  out NOCOPY rowid,
  X_STUDY_TITLE_ID in NUMBER,
  X_STUDY_TITLE in VARCHAR2,
  X_ENROLLMENT_STATUS in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  ) is
    cursor C is select ROWID from IGW_STUDY_TITLES
    where STUDY_TITLE_ID = X_STUDY_TITLE_ID;
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  insert into IGW_STUDY_TITLES (
   STUDY_TITLE_ID,
   STUDY_TITLE,
   ENROLLMENT_STATUS,
   PROTOCOL_NUMBER,
   PROPOSAL_ID,
   RECORD_VERSION_NUMBER)
   values (
   X_STUDY_TITLE_ID,
   X_STUDY_TITLE,
   X_ENROLLMENT_STATUS,
   X_PROTOCOL_NUMBER,
   X_PROPOSAL_ID,
   1
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_STUDY_TITLES_TBH'
                              ,p_procedure_name => 'INSERT_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

end INSERT_ROW;

-----------------------------------------------------------------------

procedure UPDATE_ROW (
  X_ROWID IN ROWID,
  X_STUDY_TITLE_ID in NUMBER,
  X_STUDY_TITLE in VARCHAR2,
  X_ENROLLMENT_STATUS in VARCHAR2,
  X_PROTOCOL_NUMBER in VARCHAR2,
  X_PROPOSAL_ID in NUMBER,
  X_RECORD_VERSION_NUMBER IN NUMBER,
  X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  ) is

  l_row_id  ROWID := x_rowid;
  l_record_version_number  NUMBER;

  CURSOR get_row_id IS
  SELECT rowid
  FROM   igw_study_titles
  WHERE  study_title_id = x_study_title_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  update igw_study_titles set
    study_title_id = x_study_title_id,
    study_title = x_study_title,
    enrollment_status = x_enrollment_status,
    protocol_number = x_protocol_number,
    proposal_id = x_proposal_id,
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
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_STUDY_TITLES_TBH'
                              ,p_procedure_name => 'UPDATE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;

end UPDATE_ROW;

---------------------------------------------------------------------------------

procedure DELETE_ROW (
  x_rowid in rowid
  ,x_study_title_id in number
  ,x_record_version_number in number
  ,X_RETURN_STATUS   OUT NOCOPY VARCHAR2
) is

  l_row_id  ROWID := x_rowid;
  l_record_version_number  NUMBER;

  CURSOR get_row_id IS
  SELECT rowid
  FROM   igw_study_titles
  WHERE  study_title_id = x_study_title_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from igw_study_titles
  where rowid = l_row_id
  and   record_version_number = x_record_version_number;

  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_STUDY_TITLES_TBH'
                              ,p_procedure_name => 'DELETE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end DELETE_ROW;

end IGW_STUDY_TITLES_TBH;

/
