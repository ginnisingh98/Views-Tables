--------------------------------------------------------
--  DDL for Package Body PA_OBJECT_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OBJECT_REGIONS_PKG" AS
--$Header: PAAPORHB.pls 120.1 2005/07/01 16:58:37 appldev noship $

procedure INSERT_ROW (

  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PLACEHOLDER_REG_CODE in VARCHAR2,
  P_REPLACEMENT_REG_CODE in VARCHAR2,
  P_CREATION_DATE        in DATE,
  P_CREATED_BY           in NUMBER,
  P_LAST_UPDATE_DATE     in DATE,
  P_LAST_UPDATED_BY      in NUMBER,
  P_LAST_UPDATE_LOGIN    in NUMBER
)
is
l_rowid ROWID;

   cursor C is select ROWID from PA_OBJECT_REGIONS
     where object_ID = p_object_id
     AND object_type = p_object_type
     AND placeholder_reg_code = P_PLACEHOLDER_REG_CODE ;

BEGIN

  insert into PA_OBJECT_REGIONS (
    OBJECT_ID,
    OBJECT_TYPE,
    PLACEHOLDER_REG_CODE,
    REPLACEMENT_REG_CODE,
    RECORD_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN
  ) VALUES (
    P_OBJECT_ID,
    P_OBJECT_TYPE,
    P_PLACEHOLDER_REG_CODE,
    P_REPLACEMENT_REG_CODE,
    1,
    P_LAST_UPDATED_BY,
    P_CREATED_BY,
    P_CREATION_DATE,
    P_LAST_UPDATE_DATE,
    P_LAST_UPDATE_LOGIN) ;

  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptions here
      RAISE;
END INSERT_ROW;

procedure UPDATE_ROW (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PLACEHOLDER_REG_CODE in VARCHAR2,
  P_REPLACEMENT_REG_CODE in VARCHAR2,
  P_RECORD_VERSION_NUMBER IN NUMBER,
  P_LAST_UPDATE_DATE     in DATE,
  P_LAST_UPDATED_BY      in NUMBER,
  P_LAST_UPDATE_LOGIN    in NUMBER
)
is
begin

  update PA_OBJECT_REGIONS set
    OBJECT_ID = p_object_id,
    OBJECT_TYPE = p_object_type,
    PLACEHOLDER_REG_CODE = P_PLACEHOLDER_REG_CODE,
    REPLACEMENT_REG_CODE = P_REPLACEMENT_REG_CODE,
    RECORD_VERSION_NUMBER = record_version_number +1,
    LAST_UPDATED_BY =  P_LAST_UPDATED_BY,
    LAST_UPDATE_DATE = P_LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN = P_LAST_UPDATE_LOGIN
    where object_ID = p_object_id
    AND object_type = p_object_type
    AND PLACEHOLDER_REG_CODE = P_PLACEHOLDER_REG_CODE
    AND record_version_number = Nvl(p_record_version_number, record_version_number);

   if (sql%notfound) then
      raise no_data_found;
      --PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       --x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_ROW;


procedure DELETE_ROW (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PLACEHOLDER_REG_CODE in VARCHAR2
  --x_return_status               OUT    VARCHAR2,
  --x_msg_count                   OUT    NUMBER,
  --x_msg_data                    OUT    VARCHAR2
   )
is
Begin
  --x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM  PA_OBJECT_REGIONS
    where object_ID = p_object_id
    AND object_type = p_object_type
    AND PLACEHOLDER_REG_CODE = P_PLACEHOLDER_REG_CODE ;

EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the current program unit name in the error stack
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
End DELETE_ROW;

END  PA_OBJECT_REGIONS_PKG;

/
