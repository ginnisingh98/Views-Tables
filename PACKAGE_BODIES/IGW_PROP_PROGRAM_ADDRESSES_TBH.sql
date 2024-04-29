--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PROGRAM_ADDRESSES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PROGRAM_ADDRESSES_TBH" as
--$Header: igwtpadb.pls 115.4 2002/11/15 00:43:47 ashkumar ship $
procedure INSERT_ROW (
  X_ROWID out NOCOPY ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_ADDRESS_ID in NUMBER,
  X_NUMBER_OF_COPIES in NUMBER,
  X_MAIL_DESCRIPTION in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_RETURN_STATUS   out NOCOPY VARCHAR2
   ) is
    cursor C is select ROWID from IGW_PROP_PROGRAM_ADDRESSES
      where PROPOSAL_ID = X_PROPOSAL_ID
      and ADDRESS_ID = X_ADDRESS_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    app_exception.raise_exception;
  end if;
  insert into IGW_PROP_PROGRAM_ADDRESSES (
    PROPOSAL_ID,
    ADDRESS_ID,
    NUMBER_OF_COPIES,
    MAIL_DESCRIPTION,
    RECORD_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PROPOSAL_ID,
    X_ADDRESS_ID,
    decode(X_NUMBER_OF_COPIES, FND_API.G_MISS_CHAR, NULL, X_NUMBER_OF_COPIES),
    decode(X_MAIL_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, X_MAIL_DESCRIPTION),
    1,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_PROP_PROGRAM_ADDRESSES_TBH'
                              ,p_procedure_name => 'INSERT_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end INSERT_ROW;
---------------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_ROWID in ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_ADDRESS_ID in NUMBER,
  X_NUMBER_OF_COPIES in NUMBER,
  X_MAIL_DESCRIPTION in VARCHAR2,
  X_RECORD_VERSION_NUMBER   IN NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_RETURN_STATUS   out NOCOPY VARCHAR2
    ) is
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

  l_row_id  ROWID := x_rowid;

  CURSOR get_row_id IS
  SELECT rowid
  FROM   IGW_PROP_PROGRAM_ADDRESSES
  WHERE  proposal_id = x_proposal_id
  AND    address_id = x_address_id;

begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    app_exception.raise_exception;
  end if;
  update IGW_PROP_PROGRAM_ADDRESSES set
    ADDRESS_ID = X_ADDRESS_ID,
    NUMBER_OF_COPIES = decode(X_NUMBER_OF_COPIES, FND_API.G_MISS_CHAR, NULL, X_NUMBER_OF_COPIES),
    MAIL_DESCRIPTION = decode(X_MAIL_DESCRIPTION, FND_API.G_MISS_CHAR, NULL, X_MAIL_DESCRIPTION),
    RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER + 1,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    where ROWID = L_ROW_ID
    AND   RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER;

  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    X_RETURN_STATUS := 'E';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_MAILING_INFO_TBH'
                              ,p_procedure_name => 'UPDATE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end UPDATE_ROW;
-----------------------------------------------------------------------

procedure DELETE_ROW (
  X_ROWID in ROWID,
  X_PROPOSAL_ID in NUMBER,
  X_ADDRESS_ID in NUMBER,
  X_RECORD_VERSION_NUMBER   IN NUMBER,
  X_RETURN_STATUS   out NOCOPY VARCHAR2
) is

  l_row_id  ROWID := x_rowid;

  CURSOR get_row_id IS
  SELECT rowid
  FROM   IGW_PROP_PROGRAM_ADDRESSES
  WHERE  proposal_id = x_proposal_id
  AND    address_id = x_address_id;

begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF l_row_id IS NULL THEN
    OPEN get_row_id;
    FETCH get_row_id INTO l_row_id;
    CLOSE get_row_id;
  END IF;

  delete from IGW_PROP_PROGRAM_ADDRESSES
  where ROWID = L_ROW_ID
  AND   RECORD_VERSION_NUMBER = X_RECORD_VERSION_NUMBER;



  if (sql%notfound) then
    FND_MESSAGE.SET_NAME('IGW','IGW_SS_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    X_RETURN_STATUS := 'E';
  end if;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name    => 'IGW_PROP_PROGRAM_ADDRESSES_TBH'
                              ,p_procedure_name => 'DELETE_ROW' );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    RAISE;
end DELETE_ROW;

end IGW_PROP_PROGRAM_ADDRESSES_TBH;

/