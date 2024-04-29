--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCFG_PROCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCFG_PROCS_PKG" as
/* $Header: AFOAMDSCPROCB.pls 120.1 2005/11/23 17:03 yawu noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCFG_PROCS_PKG.';

   -- cursor for selecting procedures for a given stage, getting procedures for two stages concurrently will
   -- cause both to fail iteration.
   CURSOR B_PROCS(p_stage       VARCHAR2)
   IS
      SELECT /*+ FIRST_ROWS(1) */ P.proc_id, P.proc_type, P.error_is_fatal_flag, P.location, P.executable
      FROM fnd_oam_dscfg_procs P
      WHERE P.STAGE = p_stage
      AND SYSDATE BETWEEN NVL(P.START_DATE, SYSDATE) and NVL(P.END_DATE, SYSDATE)
      ORDER BY P.priority ASC, P.proc_id ASC;

   -- local state for the last fetched proc
   TYPE b_proc_state_type IS RECORD
      (
       initialized              BOOLEAN         := FALSE,
       proc_id                  NUMBER          := NULL,
       proc_type                VARCHAR2(30)    := NULL,
       error_is_fatal_flag      VARCHAR2(3)     := NULL,
       location                 VARCHAR2(2000)  := NULL,
       executable               VARCHAR2(2000)  := NULL
       );
   b_proc_state b_proc_state_type;

   -- variable indicating stage of the last GET call
   b_last_fetched_stage                 VARCHAR2(30) := NULL;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION IS_INITIALIZED
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN b_proc_state.initialized;
   END;

   -- Public
   FUNCTION GET_CURRENT_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_proc_state.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_proc_state.proc_id;
   END;

   -- Public
   FUNCTION GET_CURRENT_TYPE
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_proc_state.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_proc_state.proc_type;
   END;

   -- Public
   FUNCTION GET_CURRENT_ERROR_IS_FATAL
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_proc_state.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_proc_state.error_is_fatal_flag;
   END;

   -- Public
   FUNCTION GET_CURRENT_LOCATION
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_proc_state.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_proc_state.location;
   END;

   -- Public
   FUNCTION GET_CURRENT_EXECUTABLE
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_proc_state.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_proc_state.executable;
   END;

   -- Private
   -- Helper to GET_NEXT_PROC/SET_CURRENT_PROC to initialize the package state
   PROCEDURE INIT_STATE(p_proc_id               IN NUMBER,
                        p_proc_type             IN VARCHAR2,
                        p_error_is_fatal_flag   IN VARCHAR2,
                        p_location              IN VARCHAR2,
                        p_executable            IN VARCHAR2)
   IS
   BEGIN
      b_proc_state.proc_id              := p_proc_id;
      b_proc_state.proc_type            := p_proc_type;
      b_proc_state.error_is_fatal_flag  := p_error_is_fatal_flag;
      b_proc_state.location             := p_location;
      b_proc_state.executable           := p_executable;
      b_proc_state.initialized          := TRUE;
   END;

   -- Public
   PROCEDURE GET_NEXT_PROC(p_stage              IN VARCHAR2,
                           x_proc_id            OUT NOCOPY NUMBER,
                           x_proc_type          OUT NOCOPY VARCHAR2,
                           x_error_is_fatal     OUT NOCOPY VARCHAR2,
                           x_location           OUT NOCOPY VARCHAR2,
                           x_executable         OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'GET_NEXT_PROC';

      l_proc_id                 NUMBER;
      l_proc_type               VARCHAR2(30);
      l_error_is_fatal_flag     VARCHAR2(3);
      l_location                VARCHAR2(2000);
      l_executable              VARCHAR2(2000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --make sure the cursor's prep'd
      IF NOT B_PROCS%ISOPEN THEN
         OPEN B_PROCS(p_stage);
      -- and in the right stage
      ELSIF p_stage IS NULL OR p_stage <> b_last_fetched_stage THEN
         IF B_PROCS%ISOPEN THEN
            CLOSE B_PROCS;
         END IF;
         OPEN B_PROCS(p_stage);
         b_last_fetched_stage := p_stage;
      END IF;

      --get the next row
      FETCH B_PROCS INTO l_proc_id, l_proc_type, l_error_is_fatal_flag, l_location, l_executable;

      --no more rows left, invalidate the state and return nulls
      IF B_PROCS%NOTFOUND THEN
         b_proc_state.initialized := FALSE;
         RAISE NO_DATA_FOUND;
      END IF;

      --got a row, set the state and return it
      INIT_STATE(l_proc_id,
                 l_proc_type,
                 l_error_is_fatal_flag,
                 l_location,
                 l_executable);
      x_proc_id         := l_proc_id;
      x_proc_type       := l_proc_type;
      x_error_is_fatal  := l_error_is_fatal_flag;
      x_location        := l_location;
      x_executable      := l_executable;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_proc_id              := NULL;
         x_proc_type            := NULL;
         x_error_is_fatal       := NULL;
         x_location             := NULL;
         x_executable           := NULL;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      WHEN OTHERS THEN
         x_proc_id              := NULL;
         x_proc_type            := NULL;
         x_error_is_fatal       := NULL;
         x_location             := NULL;
         x_executable           := NULL;
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;

   -- Public
   PROCEDURE SET_CURRENT_PROC(p_proc_id IN NUMBER)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'SET_CURRENT_PROC';

      l_proc_id                 NUMBER;
      l_proc_type               VARCHAR2(30);
      l_error_is_fatal_flag     VARCHAR2(3);
      l_location                VARCHAR2(2000);
      l_executable              VARCHAR2(2000);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');

      --query out the import proc attributes
      SELECT proc_id, proc_type, error_is_fatal_flag, location, executable
         INTO l_proc_id, l_proc_type, l_error_is_fatal_flag, l_location, l_executable
         FROM fnd_oam_dscfg_procs
         WHERE proc_id = p_proc_id
         AND SYSDATE BETWEEN NVL(START_DATE, SYSDATE) and NVL(END_DATE, SYSDATE);

      --set the state
      INIT_STATE(l_proc_id,
                 l_proc_type,
                 l_error_is_fatal_flag,
                 l_location,
                 l_executable);

      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
      WHEN OTHERS THEN
         fnd_oam_debug.log(6, l_ctxt, 'Unexpected Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))');
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RAISE;
   END;


 --PROCEDURES REQUIRED BY FNDLOADER

  procedure LOAD_ROW (
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_OWNER               in VARCHAR2,
      x_custom_mode         in varchar2,
      X_LAST_UPDATE_DATE    in varchar2)
    is
      mproc_id number;
      row_id varchar2(64);
      f_luby    number;  -- entity owner in file
      f_ludate  date;    -- entity update date in file
      db_luby   number;  -- entity owner in db
      db_ludate date;    -- entity update date in db
    begin

      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(x_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

      begin
	-- check if this PROCS id already exists.
	select proc_id, LAST_UPDATED_BY, LAST_UPDATE_DATE
	into mproc_id, db_luby, db_ludate
	from   fnd_oam_dscfg_procs
    where  proc_id = to_number(X_PROC_ID);

      if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then
        FND_OAM_DSCFG_PROCS_PKG.UPDATE_ROW (
          X_PROC_ID => mproc_id,
          X_PROC_TYPE => X_PROC_TYPE,
          X_STAGE => X_STAGE,
          X_START_DATE => X_START_DATE,
          X_END_DATE => X_END_DATE,
          X_PRIORITY => X_PRIORITY,
          X_ERROR_IS_FATAL_FLAG => X_ERROR_IS_FATAL_FLAG,
          X_LOCATION => X_LOCATION,
          X_EXECUTABLE => X_EXECUTABLE,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATE_LOGIN => 0 );

        end if;
      exception
        when NO_DATA_FOUND then

        FND_OAM_DSCFG_PROCS_PKG.INSERT_ROW (
          X_ROWID => row_id,
          X_PROC_ID => X_PROC_ID,
          X_PROC_TYPE => X_PROC_TYPE,
          X_STAGE => X_STAGE,
          X_START_DATE => X_START_DATE,
          X_END_DATE => X_END_DATE,
          X_PRIORITY => X_PRIORITY,
          X_ERROR_IS_FATAL_FLAG => X_ERROR_IS_FATAL_FLAG,
          X_LOCATION => X_LOCATION,
          X_EXECUTABLE => X_EXECUTABLE,
          X_CREATION_DATE => f_ludate,
          X_CREATED_BY => f_luby,
          X_LAST_UPDATE_DATE => f_ludate,
          X_LAST_UPDATED_BY => f_luby,
          X_LAST_UPDATE_LOGIN => 0 );
    end;

  end LOAD_ROW;

  --INSERT ROW
  procedure INSERT_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER)
 is
  cursor C is select ROWID from FND_OAM_DSCFG_PROCS
    where PROC_ID = X_PROC_ID;
begin
  insert into FND_OAM_DSCFG_PROCS (
	PROC_ID,
  PROC_TYPE,
  STAGE,
	START_DATE,
	END_DATE,
  PRIORITY,
  ERROR_IS_FATAL_FLAG,
  LOCATION,
  EXECUTABLE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
  ) values (
	X_PROC_ID,
  X_PROC_TYPE,
  X_STAGE,
	X_START_DATE,
	X_END_DATE,
  X_PRIORITY,
  X_ERROR_IS_FATAL_FLAG,
  X_LOCATION,
  X_EXECUTABLE,
	X_CREATED_BY,
	X_CREATION_DATE,
	X_LAST_UPDATED_BY,
	X_LAST_UPDATE_DATE,
	X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

   --LOCK ROW

  procedure LOCK_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER
) is
  cursor c is select
	PROC_ID,
  PROC_TYPE,
  STAGE,
	START_DATE,
	END_DATE,
  PRIORITY,
  ERROR_IS_FATAL_FLAG,
  LOCATION,
  EXECUTABLE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
    from FND_OAM_DSCFG_PROCS
    where PROC_ID = X_PROC_ID
    for update of PROC_ID nowait;
  recinfo c%rowtype;

begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.END_DATE = X_END_DATE)
           OR ((recinfo.END_DATE is null) AND (X_END_DATE is null)))
      AND ((recinfo.PROC_TYPE = X_PROC_TYPE)
           OR ((recinfo.PROC_TYPE is null) AND (X_PROC_TYPE is null)))
      AND ((recinfo.STAGE = X_STAGE)
           OR ((recinfo.STAGE is null) AND (X_STAGE is null)))
      AND ((recinfo.PRIORITY = X_PRIORITY)
           OR ((recinfo.PRIORITY is null) AND (X_PRIORITY is null)))
      AND ((recinfo.ERROR_IS_FATAL_FLAG = X_ERROR_IS_FATAL_FLAG)
           OR ((recinfo.ERROR_IS_FATAL_FLAG is null) AND (X_ERROR_IS_FATAL_FLAG is null)))
      AND ((recinfo.LOCATION = X_LOCATION)
           OR ((recinfo.LOCATION is null) AND (X_LOCATION is null)))
      AND ((recinfo.EXECUTABLE = X_EXECUTABLE)
           OR ((recinfo.EXECUTABLE is null) AND (X_EXECUTABLE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  return;
end LOCK_ROW;

--UPDATE ROW

  procedure UPDATE_ROW (
      X_PROC_ID             in NUMBER,
      X_PROC_TYPE           IN VARCHAR2,
      X_STAGE               IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_PRIORITY            IN NUMBER,
      X_ERROR_IS_FATAL_FLAG IN VARCHAR2,
      X_LOCATION            IN VARCHAR2,
      X_EXECUTABLE          IN VARCHAR2,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER
) is
begin
  update FND_OAM_DSCFG_PROCS set
          PROC_TYPE = X_PROC_TYPE,
          STAGE = X_STAGE,
          START_DATE = X_START_DATE,
          END_DATE = X_END_DATE,
          PRIORITY = X_PRIORITY,
          ERROR_IS_FATAL_FLAG = X_ERROR_IS_FATAL_FLAG,
          LOCATION = X_LOCATION,
          EXECUTABLE = X_EXECUTABLE,
          LAST_UPDATED_BY = X_LAST_UPDATED_BY,
          LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PROC_ID = X_PROC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
      X_PROC_ID           in NUMBER
) is
begin
  delete from FND_OAM_DSCFG_PROCS
  where PROC_ID = X_PROC_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;



END FND_OAM_DSCFG_PROCS_PKG;

/
