--------------------------------------------------------
--  DDL for Package Body PA_ROLE_JOB_BG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ROLE_JOB_BG_PKG" AS
 /* $Header: PAXRJBTB.pls 120.0.12010000.2 2009/07/06 07:09:03 paljain ship $ */
-- INSERT ROW -----------------------------------------

PROCEDURE INSERT_ROW (
 P_ROLE_JOB_BG_ID               OUT NOCOPY NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN         NUMBER,
 P_JOB_ID                       IN         NUMBER,
 P_MIN_JOB_LEVEL                IN         NUMBER,
 P_MAX_JOB_LEVEL                IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        OUT NOCOPY NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
) IS

BEGIN

  -- Initialize object version number.
  p_object_version_number := 1;

  -- Get the next sequence number for the primary key.
  select PA_ROLE_JOB_BGS_S.nextval
    into P_ROLE_JOB_BG_ID
    from sys.dual;

    -- hr_utility.trace('before insert');
    -- hr_utility.trace('P_ROLE_JOB_BG_ID IS : ' || P_ROLE_JOB_BG_ID);
    -- hr_utility.trace('P_PROJECT_ROLE_ID IS : ' || P_PROJECT_ROLE_ID);
    -- hr_utility.trace('P_BUSINESS_GROUP_ID IS : ' || P_BUSINESS_GROUP_ID);
    -- hr_utility.trace('P_JOB_ID IS : ' || P_JOB_ID);
    -- hr_utility.trace('P_MIN_JOB_LEVEL IS : ' || P_MIN_JOB_LEVEL);
    -- hr_utility.trace('P_MAX_JOB_LEVEL IS : ' || P_MAX_JOB_LEVEL);
    -- hr_utility.trace('P_OBJECT_VERSION_NUMBER IS : ' || P_OBJECT_VERSION_NUMBER);

    -- hr_utility.trace('P_CREATION_DATE IS : ' || P_CREATION_DATE);
    -- hr_utility.trace('P_CREATED_BY IS : ' || P_CREATED_BY);
    -- hr_utility.trace('P_LAST_UPDATE_DATE IS : ' || P_LAST_UPDATE_DATE);
    -- hr_utility.trace('P_LAST_UPDATED_BY IS : ' || P_LAST_UPDATED_BY);
    -- hr_utility.trace('P_LAST_UPDATE_LOGIN IS : ' || P_LAST_UPDATE_LOGIN);

 if P_JOB_ID is not null
 then
  insert into PA_ROLE_JOB_BGS (
    ROLE_JOB_BG_ID,
    PROJECT_ROLE_ID,
    BUSINESS_GROUP_ID,
    JOB_ID,
    MIN_JOB_LEVEL,
    MAX_JOB_LEVEL,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    P_ROLE_JOB_BG_ID,
    P_PROJECT_ROLE_ID,
    P_BUSINESS_GROUP_ID,
    P_JOB_ID,
    P_MIN_JOB_LEVEL,
    P_MAX_JOB_LEVEL,
    P_OBJECT_VERSION_NUMBER,
    P_CREATION_DATE,
    P_CREATED_BY,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATED_BY,
    P_LAST_UPDATE_LOGIN
	    );
else
   FND_MESSAGE.SET_NAME('PA','PA_DFLT_JB_GRP');
   FND_MSG_PUB.ADD;
   RAISE  FND_API.G_EXC_ERROR;
 end if;

-- hr_utility.trace('after insert');
END INSERT_ROW;


-- LOCK ROW ------------------------------------------
PROCEDURE LOCK_ROW (
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER
) IS

	CURSOR c
	IS
        SELECT *
        FROM   PA_ROLE_JOB_BGS
        WHERE  ROLE_JOB_BG_ID = P_ROLE_JOB_BG_ID
        FOR UPDATE NOWAIT;

        Recinfo c%ROWTYPE;

BEGIN

        OPEN c;
        FETCH c INTO Recinfo;
        IF (c%NOTFOUND)
        THEN
            CLOSE c;
            FND_MESSAGE.Set_Name('FND','FORM_RECORD_DELETED');
            APP_EXCEPTION.Raise_Exception;
        END IF;
        CLOSE c;


        IF ( ( (Recinfo.OBJECT_VERSION_NUMBER  = P_OBJECT_VERSION_NUMBER)
            OR ( (Recinfo.OBJECT_VERSION_NUMBER IS NULL)
             AND (P_OBJECT_VERSION_NUMBER IS NULL)))
           )
        THEN
              RETURN;
        ELSE
              FND_MESSAGE.Set_Name('FND','FORM_RECORD_CHANGED');
              APP_EXCEPTION.Raise_Exception;
        END IF;

END LOCK_ROW;

-- UPDATE ROW -----------------------------------------
PROCEDURE UPDATE_ROW (
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_PROJECT_ROLE_ID              IN         NUMBER,
 P_BUSINESS_GROUP_ID            IN         NUMBER,
 P_JOB_ID                       IN         NUMBER,
 P_MIN_JOB_LEVEL                IN         NUMBER,
 P_MAX_JOB_LEVEL                IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN OUT NOCOPY    NUMBER,
 P_LAST_UPDATE_DATE             IN         DATE,
 P_LAST_UPDATED_BY              IN         NUMBER,
 P_CREATION_DATE                IN         DATE,
 P_CREATED_BY                   IN         NUMBER,
 P_LAST_UPDATE_LOGIN            IN         NUMBER
) IS


BEGIN
   -- Lock the row for update.
   LOCK_ROW (
        P_ROLE_JOB_BG_ID,
        P_OBJECT_VERSION_NUMBER
        );

    -- Increment the object version number.
    p_object_version_number := p_object_version_number + 1;

 if P_JOB_ID is not null
 then
    update PA_ROLE_JOB_BGS
    set
    BUSINESS_GROUP_ID = P_BUSINESS_GROUP_ID,
    JOB_ID = P_JOB_ID,
    MIN_JOB_LEVEL = P_MIN_JOB_LEVEL,
    MAX_JOB_LEVEL = P_MAX_JOB_LEVEL,
    OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = P_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
    WHERE role_job_bg_id = p_role_job_bg_id;
 else
   FND_MESSAGE.SET_NAME('PA','PA_DFLT_JB_GRP');
   FND_MSG_PUB.ADD;
   RAISE  FND_API.G_EXC_ERROR;
 end if;

    IF (SQL%NOTFOUND)
      THEN
       RAISE NO_DATA_FOUND;
    END IF;
  if (sql%notfound) then
    raise no_data_found;
  end if;

END UPDATE_ROW;


-- DELETE ROW -----------------------------------------
PROCEDURE DELETE_ROW (
 P_ROLE_JOB_BG_ID               IN         NUMBER,
 P_OBJECT_VERSION_NUMBER        IN         NUMBER) IS

BEGIN

LOCK_ROW (
        P_ROLE_JOB_BG_ID,
        P_OBJECT_VERSION_NUMBER
        );

  delete from PA_ROLE_JOB_BGS
  where ROLE_JOB_BG_ID = P_ROLE_JOB_BG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

END Delete_Row;

END pa_role_job_bg_pkg;

/
