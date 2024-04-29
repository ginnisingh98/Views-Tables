--------------------------------------------------------
--  DDL for Package Body OKC_ROLE_SOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ROLE_SOURCE_PUB" AS
/* $Header: OKCPRSCB.pls 120.0 2005/05/26 09:51:09 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_ROLE_SOURCES_PUB';
  G_TOO_MANY_SOURCES		CONSTANT VARCHAR2(20) := 'OKC_TOO_MANY_SOURCES';

procedure reset(p_rscv_rec IN rscv_rec_type) is
begin
    g_rscv_rec.RLE_CODE       	 := p_rscv_rec.RLE_CODE;
    g_rscv_rec.BUY_OR_SELL    	 := p_rscv_rec.BUY_OR_SELL;
    g_rscv_rec.START_DATE     	 := p_rscv_rec.START_DATE;
    g_rscv_rec.object_version_number := p_rscv_rec.object_version_number;
    g_rscv_rec.created_by            := p_rscv_rec.created_by;
    g_rscv_rec.creation_date         := p_rscv_rec.creation_date;
    g_rscv_rec.last_updated_by       := p_rscv_rec.last_updated_by;
    g_rscv_rec.last_update_date      := p_rscv_rec.last_update_date;
    g_rscv_rec.last_update_login     := p_rscv_rec.last_update_login;
    g_rscv_rec.access_level          := p_rscv_rec.access_level;
end reset;

procedure reset(p_csov_rec IN csov_rec_type) is
begin
    g_csov_rec.RLE_CODE       	 := p_csov_rec.RLE_CODE;
    g_csov_rec.CRO_CODE       	 := p_csov_rec.CRO_CODE;
    g_csov_rec.BUY_OR_SELL    	 := p_csov_rec.BUY_OR_SELL;
    g_csov_rec.START_DATE     	 := p_csov_rec.START_DATE;
    g_csov_rec.object_version_number := p_csov_rec.object_version_number;
    g_csov_rec.created_by            := p_csov_rec.created_by;
    g_csov_rec.creation_date         := p_csov_rec.creation_date;
    g_csov_rec.last_updated_by       := p_csov_rec.last_updated_by;
    g_csov_rec.last_update_date      := p_csov_rec.last_update_date;
    g_csov_rec.last_update_login     := p_csov_rec.last_update_login;
    g_csov_rec.access_level          := p_csov_rec.access_level;
end reset;

-- Start of comments
--
-- Procedure Name  : contact_role_meaning
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function contact_role_meaning(p_cro_code in varchar2) return varchar2 is
cursor c1 is
  select meaning
  from fnd_lookups
  where lookup_type = 'OKC_CONTACT_ROLE'
    and lookup_code = p_cro_code;
v1 varchar2(300);
begin
  open c1;
  fetch c1 into v1;
  close c1;
  return v1;
end contact_role_meaning;

-- Start of comments
--
-- Procedure Name  : source_name
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

function source_name(p_jtot_object_code in varchar2) return varchar2 is
cursor c1 is
  select name
  from jtf_objects_vl
  where object_code = p_jtot_object_code;
v1 varchar2(300);
begin
  open c1;
  fetch c1 into v1;
  close c1;
  return v1;
end source_name;

-- Start of comments
--
-- Procedure Name  : one_role_source_atime
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure one_role_source_atime(x_return_status	OUT NOCOPY	VARCHAR2,
					p_rle_code in varchar2) is

-- Changed the select statement with a UNION ALL for performance reasons 08/14/2000
cursor c1 is
  select START_DATE+0.5
  from okc_role_sources
  where RLE_CODE = p_rle_code AND p_rle_code is not null
  and nvl(end_date,sysdate)>=sysdate
  UNION ALL
  select START_DATE+0.5
  from okc_role_sources
  where p_rle_code is null
  and nvl(end_date,sysdate)>=sysdate;
d1 date;
cursor c2 is
--  select max(count(start_date))
--  from okc_role_sources
--  where RLE_CODE = NVL(p_rle_code,RLE_CODE)
--    and d1 between start_date and NVL(end_date,d1)
--  group by RLE_CODE, buy_or_sell;
  select count(start_date)
    from okc_role_sources
   where RLE_CODE = p_rle_code AND p_rle_code is not null
     and d1 between start_date and NVL(end_date,d1)
  group by RLE_CODE, buy_or_sell
  having count(start_date) > 1
  UNION ALL
  select count(start_date)
    from okc_role_sources
   where p_rle_code is null
     and d1 between start_date and NVL(end_date,d1)
  group by RLE_CODE, buy_or_sell
  having count(start_date) > 1;
n1 number;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  open c1;
  loop
    fetch c1 into d1;
    exit when c1%NOTFOUND;
    open c2;
    fetch c2 into n1;
    close c2;
    if (n1>1) then
      FND_MESSAGE.SET_NAME(application => G_APP_NAME,
                      	name     => G_TOO_MANY_SOURCES);
      FND_MESSAGE.SET_TOKEN(token => 'DATE',
                      	value     => fnd_date.date_to_chardate(d1));
      FND_MESSAGE.SET_TOKEN(token => 'SOURCE',
                      	value     => 'OKC_ROLE_SOURCES',
				translate => TRUE);
      FND_MSG_PUB.add;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      exit;
    end if;
  end loop;
  close c1;
end one_role_source_atime;

-- Start of comments
--
-- Procedure Name  : one_contact_source_atime
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure one_contact_source_atime(x_return_status	OUT NOCOPY	VARCHAR2,
					p_rle_code in varchar2) is

-- Changed the select statement to UNION ALL for performance reasons 08/14/2000

cursor c1 is
  select START_DATE+0.5
    from okc_contact_sources
   where RLE_CODE = p_rle_code AND p_rle_code is not null
     and nvl(end_date,sysdate)>=sysdate
  UNION ALL
  select START_DATE+0.5
    from okc_contact_sources
   where p_rle_code is null
     and nvl(end_date,sysdate)>=sysdate;
d1 date;
cursor c2 is
--  select max(count(start_date))
--  from okc_contact_sources
--  where RLE_CODE = NVL(p_rle_code,RLE_CODE)
--    and d1 between start_date and NVL(end_date,d1)
--  group by RLE_CODE, CRO_CODE, buy_or_sell;
select count(start_date)
    from okc_contact_sources
   where RLE_CODE = p_rle_code and p_rle_code is not null
     and d1 between start_date and NVL(end_date,d1)
   group by RLE_CODE, CRO_CODE, buy_or_sell
   having count(start_date) > 1
  UNION ALL
  select count(start_date)
    from okc_contact_sources
   where p_rle_code is null
     and d1 between start_date and NVL(end_date,d1)
   group by RLE_CODE, CRO_CODE, buy_or_sell
   having count(start_date) > 1;
n1 number;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  open c1;
  loop
    fetch c1 into d1;
    exit when c1%NOTFOUND;
    open c2;
    fetch c2 into n1;
    close c2;
    if (n1>1) then
      FND_MESSAGE.SET_NAME(application => G_APP_NAME,
                      	name     => G_TOO_MANY_SOURCES);
      FND_MESSAGE.SET_TOKEN(token => 'DATE',
                      	value     => fnd_date.date_to_chardate(d1));
      FND_MESSAGE.SET_TOKEN(token => 'SOURCE',
                      	value     => 'OKC_CONTACT_SOURCES',
				translate => TRUE);
      FND_MSG_PUB.add;
      x_return_status := OKC_API.G_RET_STS_ERROR;
      exit;
    end if;
  end loop;
  close c1;
end one_contact_source_atime;

-- Start of comments
--
-- Procedure Name  : create_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure create_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type,
                              x_rscv_rec	OUT NOCOPY	rscv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'create_role_source';
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
  --
  -- Call Before Logic Hook
  --
  g_rscv_rec := p_rscv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_rscv_rec);
  OKC_ROLE_SOURCE_PVT.create_role_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_rscv_rec,
                              x_rscv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_rscv_rec := x_rscv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end create_role_source;

-- Start of comments
--
-- Procedure Name  : create_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure create_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type,
                              x_rscv_tbl	OUT NOCOPY	rscv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_rscv_tbl.COUNT>0) then
        i := p_rscv_tbl.FIRST;
        LOOP
	    create_role_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_rscv_rec=>p_rscv_tbl(i),
                              x_rscv_rec=>x_rscv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_rscv_tbl.LAST);
          i := p_rscv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end create_role_source;

procedure update_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type,
                              x_rscv_rec	OUT NOCOPY	rscv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'update_role_source';
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
  --
  -- Call Before Logic Hook
  --
  g_rscv_rec := p_rscv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_rscv_rec);
  OKC_ROLE_SOURCE_PVT.update_role_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_rscv_rec,
                              x_rscv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_rscv_rec := x_rscv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end update_role_source;

-- Start of comments
--
-- Procedure Name  : update_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure update_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type,
                              x_rscv_tbl	OUT NOCOPY	rscv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_rscv_tbl.COUNT>0) then
        i := p_rscv_tbl.FIRST;
        LOOP
	    update_role_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_rscv_rec=>p_rscv_tbl(i),
                              x_rscv_rec=>x_rscv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_rscv_tbl.LAST);
          i := p_rscv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end update_role_source;

-- Start of comments
--
-- Procedure Name  : lock_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'lock_role_source';
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
  --
  -- Call Before Logic Hook
  --
  g_rscv_rec := p_rscv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_rscv_rec);
  OKC_ROLE_SOURCE_PVT.lock_role_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_rscv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end lock_role_source;

-- Start of comments
--
-- Procedure Name  : lock_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_rscv_tbl.COUNT>0) then
        i := p_rscv_tbl.FIRST;
        LOOP
	    lock_role_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_rscv_rec=>p_rscv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_rscv_tbl.LAST);
          i := p_rscv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end lock_role_source;

-- Start of comments
--
-- Procedure Name  : validate_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_rec	IN	rscv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'validate_role_source';
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
  --
  -- Call Before Logic Hook
  --
  g_rscv_rec := p_rscv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_rscv_rec);
  OKC_ROLE_SOURCE_PVT.validate_role_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_rscv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end validate_role_source;

-- Start of comments
--
-- Procedure Name  : validate_role_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_role_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_rscv_tbl	IN	rscv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_rscv_tbl.COUNT>0) then
        i := p_rscv_tbl.FIRST;
        LOOP
	    validate_role_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_rscv_rec=>p_rscv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_rscv_tbl.LAST);
          i := p_rscv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end validate_role_source;

-- Start of comments
--
-- Procedure Name  : create_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure create_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type,
                              x_csov_rec	OUT NOCOPY	csov_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'create_contact_source';
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
  --
  -- Call Before Logic Hook
  --
  g_csov_rec := p_csov_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_csov_rec);
  OKC_ROLE_SOURCE_PVT.create_contact_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_csov_rec,
                              x_csov_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_csov_rec := x_csov_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end create_contact_source;

-- Start of comments
--
-- Procedure Name  : create_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure create_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type,
                              x_csov_tbl	OUT NOCOPY	csov_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_csov_tbl.COUNT>0) then
        i := p_csov_tbl.FIRST;
        LOOP
	    create_contact_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_csov_rec=>p_csov_tbl(i),
                              x_csov_rec=>x_csov_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_csov_tbl.LAST);
          i := p_csov_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end create_contact_source;

-- Start of comments
--
-- Procedure Name  : update_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure update_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type,
                              x_csov_rec	OUT NOCOPY	csov_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'update_contact_source';
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
  --
  -- Call Before Logic Hook
  --
  g_csov_rec := p_csov_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_csov_rec);
  OKC_ROLE_SOURCE_PVT.update_contact_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_csov_rec,
                              x_csov_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_csov_rec := x_csov_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end update_contact_source;

-- Start of comments
--
-- Procedure Name  : update_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure update_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type,
                              x_csov_tbl	OUT NOCOPY	csov_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_csov_tbl.COUNT>0) then
        i := p_csov_tbl.FIRST;
        LOOP
	    update_contact_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_csov_rec=>p_csov_tbl(i),
                              x_csov_rec=>x_csov_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_csov_tbl.LAST);
          i := p_csov_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end update_contact_source;

-- Start of comments
--
-- Procedure Name  : lock_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'lock_contact_source';
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
  --
  -- Call Before Logic Hook
  --
  g_csov_rec := p_csov_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_csov_rec);
  OKC_ROLE_SOURCE_PVT.lock_contact_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_csov_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end lock_contact_source;

-- Start of comments
--
-- Procedure Name  : lock_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_csov_tbl.COUNT>0) then
        i := p_csov_tbl.FIRST;
        LOOP
	    lock_contact_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_csov_rec=>p_csov_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_csov_tbl.LAST);
          i := p_csov_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end lock_contact_source;

-- Start of comments
--
-- Procedure Name  : validate_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_rec	IN	csov_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'validate_contact_source';
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
  --
  -- Call Before Logic Hook
  --
  g_csov_rec := p_csov_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_csov_rec);
  OKC_ROLE_SOURCE_PVT.validate_contact_source(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_csov_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
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
end validate_contact_source;

-- Start of comments
--
-- Procedure Name  : validate_contact_source
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_contact_source(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 ,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_csov_tbl	IN	csov_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_csov_tbl.COUNT>0) then
        i := p_csov_tbl.FIRST;
        LOOP
	    validate_contact_source(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_csov_rec=>p_csov_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_csov_tbl.LAST);
          i := p_csov_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end validate_contact_source;

END OKC_ROLE_SOURCE_PUB;

/
