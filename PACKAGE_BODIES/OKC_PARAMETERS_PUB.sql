--------------------------------------------------------
--  DDL for Package Body OKC_PARAMETERS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PARAMETERS_PUB" AS
/* $Header: OKCPPRMB.pls 120.2 2006/02/28 14:43:00 smallya noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  TYPE Params_Tbl_Type IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

  G_Params_tbl Params_Tbl_Type;
  G_Params_count number := 0;

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_PARAMETERS_PUB';
  G_SQL_ID number;

-- Start of comments
--
-- Procedure Name  : add_language
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure add_language is
begin
  OKC_PRM_PVT.add_language;
end add_language;

-- Start of comments
--
-- Procedure Name  : create_parameter
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
  procedure create_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type,
                              x_prmv_rec	OUT NOCOPY	prmv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'create_parameter';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_PRM_PVT.insert_row(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_prmv_rec,
                              x_prmv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
end create_parameter;

  procedure create_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type,
                              x_prmv_tbl	OUT NOCOPY	prmv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_prmv_tbl.COUNT>0) then
        i := p_prmv_tbl.FIRST;
        LOOP
	    create_parameter(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_prmv_rec=>p_prmv_tbl(i),
                              x_prmv_rec=>x_prmv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_prmv_tbl.LAST);
          i := p_prmv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
  when others then NULL;
end create_parameter;

  procedure update_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type,
                              x_prmv_rec	OUT NOCOPY	prmv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'update_parameter';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_PRM_PVT.update_row(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_prmv_rec,
                              x_prmv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
end update_parameter;

  procedure update_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type,
                              x_prmv_tbl	OUT NOCOPY	prmv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_prmv_tbl.COUNT>0) then
        i := p_prmv_tbl.FIRST;
        LOOP
	    update_parameter(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_prmv_rec=>p_prmv_tbl(i),
                              x_prmv_rec=>x_prmv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_prmv_tbl.LAST);
          i := p_prmv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
  when others then NULL;
end update_parameter;

  procedure delete_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'delete_parameter';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_PRM_PVT.delete_row(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_prmv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
end delete_parameter;

  procedure delete_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_prmv_tbl.COUNT>0) then
        i := p_prmv_tbl.FIRST;
        LOOP
	    delete_parameter(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_prmv_rec=>p_prmv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_prmv_tbl.LAST);
          i := p_prmv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
  when others then NULL;
end delete_parameter;

  procedure lock_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_rec	IN	prmv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'lock_parameter';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PUB',
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_PRM_PVT.lock_row(
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              p_prmv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
end lock_parameter;

  procedure lock_parameter(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_prmv_tbl	IN	prmv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_prmv_tbl.COUNT>0) then
        i := p_prmv_tbl.FIRST;
        LOOP
	    lock_parameter(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_prmv_rec=>p_prmv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_prmv_tbl.LAST);
          i := p_prmv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
  when others then NULL;
end lock_parameter;

-- for lct only
  procedure set_sql_id (p_sql_id number) is
  begin
    g_sql_id := p_sql_id;
  end;

  function get_sql_id return number is
  begin
    return g_sql_id;
  end;

-- for process only

  FUNCTION Count_Params RETURN NUMBER IS
  BEGIN
    RETURN G_Params_count;
  END;

  procedure Set_Params(p_array in JTF_VARCHAR2_TABLE_2000) is
    i number;
    c number;
  begin
    G_Params_tbl.DELETE;
    G_Params_count := 0;
    if ((p_array is not null) and (p_array.count > 0)) then
      c := p_array.count/2;
      i := p_array.first;
      while (G_Params_count < c) loop
        G_Params_tbl(2*G_Params_count+1) := p_array(i);
        G_Params_tbl(2*G_Params_count+2) := p_array(i+1);
        G_Params_count := G_Params_count+1;
        i := i+2;
      end loop;
    end if;
  end;

  procedure Set_Params2(p_array in name_value_tbl_type,
			p_xid varchar2 ,
			p_kid varchar2 ) is
    i number;
    c number := p_array.COUNT;
    l_xid varchar2(1) := '?';
    l_kid varchar2(1) := '?';
  begin
    G_Params_tbl.DELETE;
    G_Params_count := 0;
  if (c>0) then
    i := p_array.FIRST;
    while (G_Params_count < c) loop
      G_Params_tbl(2*G_Params_count+1) := p_array(i).NAME;
      G_Params_tbl(2*G_Params_count+2) := p_array(i).VALUE;
      G_Params_count                   := G_Params_count+1;
      if (p_array(i).NAME = 'xid') then
        l_xid := '!';
      end if;
      if (p_array(i).NAME = 'kid') then
        l_kid := '!';
      end if;
      i := i+1;
    end loop;
  end if;
    if ( (l_xid = '?') and (p_xid is not NULL)) then
      G_Params_tbl(2*G_Params_count+1) := 'xid';
      G_Params_tbl(2*G_Params_count+2) := p_xid;
      G_Params_count                   := G_Params_count+1;
    end if;
    if ( (l_kid = '?') and (p_kid is not NULL)) then
      G_Params_tbl(2*G_Params_count+1) := 'kid';
      G_Params_tbl(2*G_Params_count+2) := p_kid;
      G_Params_count                   := G_Params_count+1;
    end if;

  end;

  function Get_Name(p_index in number) return varchar2 is
  begin
    if (p_index between 1 and G_Params_count) then
      return G_Params_tbl(2*p_index-1);
    else
      return NULL;
    end if;
  end;

  function Get_Value(p_index in number) return varchar2 is
  begin
    if (p_index between 1 and G_Params_count) then
      return G_Params_tbl(2*p_index);
    else
      return NULL;
    end if;
  end;

  function Get(p_name in varchar2) return varchar2 is
    i number := 0;
    c2 number := 2*G_Params_count;
  begin
    while (i < c2) loop
      if (G_Params_tbl(i+1) = p_name) then
        return G_Params_tbl(i+2);
      else
        i := i+2;
      end if;
    end loop;
    return NULL;
  end;

  function Get_Index(p_name in varchar2) return number is
    i number := 0;
    c2 number := 2*G_Params_count;
  begin
    while (i < c2) loop
      if (G_Params_tbl(i+1) = p_name) then
        return (i+2)/2;
      else
        i := i+2;
      end if;
    end loop;
    return NULL;
  end;

  procedure Reset_Param(p_index in number, p_value in varchar2) is
  begin
    if (p_index between 1 and G_Params_count) then
      G_Params_tbl(2*p_index) := p_value;
    end if;
  end;

END OKC_PARAMETERS_PUB;

/
