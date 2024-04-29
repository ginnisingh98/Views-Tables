--------------------------------------------------------
--  DDL for Package Body OKS_ORDER_CONTACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ORDER_CONTACTS_PUB" AS
/* $Header: OKSPCOCB.pls 120.0 2005/05/25 18:17:48 appldev noship $ */

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_ORDER_CONTACTS_PUB';
  G_COCV_REC         COCV_REC_TYPE;
procedure reset(p_cocv_rec IN cocv_rec_type) is
begin
    g_cocv_rec.object_version_number := p_cocv_rec.object_version_number;
    g_cocv_rec.created_by            := p_cocv_rec.created_by;
    g_cocv_rec.creation_date         := p_cocv_rec.creation_date;
    g_cocv_rec.last_updated_by       := p_cocv_rec.last_updated_by;
    g_cocv_rec.last_update_date      := p_cocv_rec.last_update_date;
end reset;

-- Start of comments
--
-- Procedure Name  : create_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Insert_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type,
                              x_cocv_rec	OUT NOCOPY	cocv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'Insert_Order_Contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
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
  g_cocv_rec := p_cocv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cocv_rec);
  OKS_ORDER_CONTACTs_PVT.create_Order_Contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cocv_rec,
                              x_cocv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_cocv_rec := x_cocv_rec;
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
end Insert_Order_Contact;

-- Start of comments
--
-- Procedure Name  : create_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Insert_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_tbl	IN	cocv_tbl_type,
                              x_cocv_tbl	OUT NOCOPY	cocv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cocv_tbl.COUNT>0) then
        i := p_cocv_tbl.FIRST;
        LOOP
	    Insert_Order_Contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cocv_rec=>p_cocv_tbl(i),
                              x_cocv_rec=>x_cocv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cocv_tbl.LAST);
          i := p_cocv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end Insert_Order_Contact;

procedure update_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type,
                              x_cocv_rec	OUT NOCOPY	cocv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'update_Order_Contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
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
  g_cocv_rec := p_cocv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cocv_rec);
  OKS_ORDER_CONTACTs_PVT.update_Order_Contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cocv_rec,
                              x_cocv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_cocv_rec := x_cocv_rec;
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
end update_Order_Contact;

-- Start of comments
--
-- Procedure Name  : update_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure update_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_tbl	IN	cocv_tbl_type,
                              x_cocv_tbl	OUT NOCOPY	cocv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cocv_tbl.COUNT>0) then
        i := p_cocv_tbl.FIRST;
        LOOP
	    update_Order_Contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cocv_rec=>p_cocv_tbl(i),
                              x_cocv_rec=>x_cocv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cocv_tbl.LAST);
          i := p_cocv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end update_Order_Contact;

-- Start of comments
--
-- Procedure Name  : delete_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure delete_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'delete_Order_Contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
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
  g_cocv_rec := p_cocv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cocv_rec);
  OKS_ORDER_CONTACTs_PVT.delete_Order_Contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cocv_rec);
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
end delete_Order_Contact;

-- Start of comments
--
-- Procedure Name  : delete_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure delete_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_tbl	IN	cocv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cocv_tbl.COUNT>0) then
        i := p_cocv_tbl.FIRST;
        LOOP
	    delete_Order_Contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cocv_rec=>p_cocv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cocv_tbl.LAST);
          i := p_cocv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end delete_Order_Contact;

-- Start of comments
--
-- Procedure Name  : lock_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'lock_Order_Contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
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
  g_cocv_rec := p_cocv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cocv_rec);
  OKS_ORDER_CONTACTs_PVT.lock_Order_Contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cocv_rec);
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
end lock_Order_Contact;

-- Start of comments
--
-- Procedure Name  : lock_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_tbl	IN	cocv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cocv_tbl.COUNT>0) then
        i := p_cocv_tbl.FIRST;
        LOOP
	    lock_Order_Contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cocv_rec=>p_cocv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cocv_tbl.LAST);
          i := p_cocv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end lock_Order_Contact;

-- Start of comments
--
-- Procedure Name  : validate_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_rec	IN	cocv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'validate_Order_Contact';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
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
  g_cocv_rec := p_cocv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cocv_rec);
  OKS_ORDER_CONTACTs_PVT.validate_Order_Contact(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cocv_rec);
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
end validate_Order_Contact;

-- Start of comments
--
-- Procedure Name  : validate_Order_Contact
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_Order_Contact(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cocv_tbl	IN	cocv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cocv_tbl.COUNT>0) then
        i := p_cocv_tbl.FIRST;
        LOOP
	    validate_Order_Contact(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cocv_rec=>p_cocv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cocv_tbl.LAST);
          i := p_cocv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end validate_Order_Contact;
end OKS_ORDER_CONTACTS_PUB;

/
