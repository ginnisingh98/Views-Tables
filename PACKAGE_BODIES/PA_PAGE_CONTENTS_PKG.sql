--------------------------------------------------------
--  DDL for Package Body PA_PAGE_CONTENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAGE_CONTENTS_PKG" AS
--$Header: PAPGCTTB.pls 115.1 2002/12/03 18:20:01 mwasowic noship $


procedure INSERT_PAGE_CONTENTS_ROW (

  P_PAGE_CONTENT_ID  	IN NUMBER,
  P_OBJECT_TYPE    	IN VARCHAR2,
  P_PK1_VALUE      	IN VARCHAR2,
  P_PK2_VALUE      	IN VARCHAR2,
  P_PK3_VALUE      	IN VARCHAR2,
  P_PK4_VALUE      	IN VARCHAR2,
  P_PK5_VALUE      	IN VARCHAR2,

  x_return_status       OUT    NOCOPY VARCHAR2,
  x_msg_count           OUT    NOCOPY NUMBER,
  x_msg_data            OUT    NOCOPY VARCHAR2
) is

  l_ROWID ROWID;

   cursor C is select ROWID from PA_PAGE_CONTENTS
     where Page_content_id = P_PAGE_CONTENT_ID;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --get the unique page content id from the Oracle Sequence
  --SELECT pa.pa_page_contents_s.nextval
  --INTO l_content_id
  --FROM DUAL;


  insert into PA_PAGE_CONTENTS (
    PAGE_CONTENT_ID,
    OBJECT_TYPE,
    PK1_VALUE,
    PK2_VALUE,
    PK3_VALUE,
    PK4_VALUE,
    PK5_VALUE,
    PAGE_CONTENT,
    RECORD_VERSION_NUMBER,
    LAST_UPDATED_BY,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN

  ) VALUES (
    P_PAGE_CONTENT_ID,
    P_OBJECT_TYPE,
    P_PK1_VALUE,
    P_PK2_VALUE,
    P_PK3_VALUE,
    P_PK4_VALUE,
    P_PK5_VALUE,
    empty_clob(),
    1,
    fnd_global.user_id,
    fnd_global.user_id,
    sysdate,
    sysdate,
    fnd_global.user_id
    );


  open c;
  fetch c into l_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  --x_page_content_id := l_content_id;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

end INSERT_PAGE_CONTENTS_ROW;

-- Clear existing CLOB before writing new contents
-- in case new contents length is < old length

procedure CLEAR_CLOB (
  P_PAGE_CONTENT_ID       IN NUMBER,
  --P_RECORD_VERSION_NUMBER IN NUMBER := NULL,

  x_return_status         OUT    NOCOPY VARCHAR2,
  x_msg_count             OUT    NOCOPY NUMBER,
  x_msg_data              OUT    NOCOPY VARCHAR2
) is
begin

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  update PA_PAGE_CONTENTS set
    PAGE_CONTENT              = empty_clob(),
    RECORD_VERSION_NUMBER     = record_version_number +1,
    LAST_UPDATED_BY           = fnd_global.user_id,
    LAST_UPDATE_DATE          = sysdate,
    LAST_UPDATE_LOGIN         = fnd_global.login_id
    where page_content_id     = p_page_content_id;
    --AND record_version_number = Nvl(p_record_version_number, record_version_number);

   if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end CLEAR_CLOB;


procedure UPDATE_PAGE_CONTENTS_ROW (
  P_PAGE_CONTENT_ID       in NUMBER,
  P_OBJECT_TYPE           in VARCHAR2,
  P_PK1_VALUE             in VARCHAR2,
  P_PK2_VALUE             in VARCHAR2,
  P_PK3_VALUE             in VARCHAR2,
  P_PK4_VALUE             in VARCHAR2,
  P_PK5_VALUE             in VARCHAR2,
  p_record_version_number IN NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2,
  x_msg_count                   OUT    NOCOPY NUMBER,
  x_msg_data                    OUT    NOCOPY VARCHAR2
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  update PA_PAGE_CONTENTS set
    OBJECT_TYPE               = Nvl(p_object_type, object_type),
    PK1_VALUE                 = Nvl(P_PK1_VALUE, PK1_VALUE),
    PK2_VALUE                 = Nvl(P_PK2_VALUE, PK2_VALUE),
    PK3_VALUE                 = Nvl(P_PK3_VALUE, PK3_VALUE),
    PK4_VALUE                 = Nvl(P_PK4_VALUE, PK4_VALUE),
    PK5_VALUE                 = Nvl(P_PK5_VALUE, PK5_VALUE),

    RECORD_VERSION_NUMBER     = record_version_number +1,
    LAST_UPDATED_BY           = fnd_global.user_id,
    LAST_UPDATE_DATE          = sysdate,
    LAST_UPDATE_LOGIN         = fnd_global.login_id
    where page_content_id     = p_page_content_id
    AND record_version_number = Nvl(p_record_version_number, record_version_number);

   if (sql%notfound) then
       PA_UTILS.Add_Message ( p_app_short_name => 'PA',p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
  end if;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end UPDATE_PAGE_CONTENTS_ROW;



procedure DELETE_PAGE_CONTENTS_ROW (
  P_PAGE_CONTENT_ID       in NUMBER,
  x_return_status               OUT    NOCOPY VARCHAR2,
  x_msg_count                   OUT    NOCOPY NUMBER,
  x_msg_data                    OUT    NOCOPY VARCHAR2
) is
begin
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM  PA_PAGE_CONTENTS
    where page_content_id = P_PAGE_CONTENT_ID;


EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
end DELETE_PAGE_CONTENTS_ROW;

END  PA_PAGE_CONTENTS_PKG;

/
