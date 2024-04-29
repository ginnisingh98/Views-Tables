--------------------------------------------------------
--  DDL for Package Body OKL_VP_K_ARTICLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VP_K_ARTICLE_PUB" AS
/* $Header: OKLPCARB.pls 120.1 2005/08/04 01:29:42 manumanu noship $ */
  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_VP_K_ARTICLE_PUB';
  G_API_VERSION               CONSTANT NUMBER := 1;
  G_SCOPE				CONSTANT varchar2(4) := '_PUB';

--
--	reset some columns procedures after "before user hooks"
--
procedure reset(p_catv_rec IN catv_rec_type) is
begin
    g_catv_rec.id                    := p_catv_rec.id;
    g_catv_rec.object_version_number := p_catv_rec.object_version_number;
    g_catv_rec.created_by            := p_catv_rec.created_by;
    g_catv_rec.creation_date         := p_catv_rec.creation_date;
    g_catv_rec.last_updated_by       := p_catv_rec.last_updated_by;
    g_catv_rec.last_update_date      := p_catv_rec.last_update_date;
    g_catv_rec.last_update_login     := p_catv_rec.last_update_login;
end reset;


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
  OKL_VP_K_ARTICLE_PVT.add_language_k_article;
end add_language;
-- Start of comments
--
-- Procedure Name  : create_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_K_ARTICLE';
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_clob 			clob;
begin
/*  l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;*/
  g_catv_rec := p_catv_rec;
  --
  -- code for temporary clob ... start
  --
/*  if (dbms_lob.istemporary(p_catv_rec.TEXT) = 1) then
    DBMS_LOB.CREATETEMPORARY(g_catv_rec.TEXT,FALSE,DBMS_LOB.CALL);
    l_clob := p_catv_rec.TEXT;
    DBMS_LOB.OPEN(l_clob, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.OPEN(g_catv_rec.TEXT, DBMS_LOB.LOB_READWRITE);
    DBMS_LOB.COPY(dest_lob => g_catv_rec.TEXT,src_lob => l_clob,
  			amount => dbms_lob.getlength(l_clob));
    DBMS_LOB.CLOSE(g_catv_rec.TEXT);
    DBMS_LOB.CLOSE(l_clob);
    DBMS_LOB.freetemporary(l_clob);
  end if;
*/
  --
  -- code for temporary clob ... end
  --
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_catv_rec);
  OKL_VP_K_ARTICLE_PVT.create_k_article
  (
                              p_api_version 	=> p_api_version,
                              p_init_msg_list 	=> OKC_API.G_FALSE,
                              x_return_status 	=> x_return_status,
                              x_msg_count		=> x_msg_count,
                              x_msg_data		=> x_msg_data,
                              p_catv_rec		=> g_catv_rec,
                              x_catv_rec		=> x_catv_rec
  );
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_catv_rec := x_catv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'A');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
/*  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);*/
   EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end create_k_article;
-- Start of comments
--
-- Procedure Name  : create_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure create_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type,
                              x_catv_tbl	OUT NOCOPY	catv_tbl_type) is
  c 	NUMBER;
  i 	NUMBER;
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    x_return_status:= OKC_API.G_RET_STS_SUCCESS;
    c:=p_catv_tbl.COUNT;
    if (c>0) then
      i := p_catv_tbl.FIRST;
      LOOP
	  create_k_article
       (
                  p_api_version	=> p_api_version,
                  p_init_msg_list	=> OKC_API.G_FALSE,
                  x_return_status	=> x_return_status,
                  x_msg_count		=> x_msg_count,
                  x_msg_data		=> x_msg_data,
                  p_catv_rec		=> p_catv_tbl(i),
                  x_catv_rec		=> x_catv_tbl(i)
        );
        if (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          null;
        end if;
        c:=c-1;
        EXIT WHEN (c=0);
        i := p_catv_tbl.NEXT(i);
      END LOOP;
    end if;
exception
when others then NULL;
end create_k_article;

-- Start of comments
--
-- Procedure Name  : update_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type,
                              x_catv_rec	OUT NOCOPY	catv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'UPDATE_K_ARTICLE';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_clob 			clob;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  g_catv_rec := p_catv_rec;
  --
  -- code for temporary clob ... start
  --
/*  if (dbms_lob.istemporary(p_catv_rec.TEXT) = 1) then
    DBMS_LOB.CREATETEMPORARY(g_catv_rec.TEXT,FALSE,DBMS_LOB.CALL);
    l_clob := p_catv_rec.TEXT;
    DBMS_LOB.OPEN(l_clob, DBMS_LOB.LOB_READONLY);
    DBMS_LOB.OPEN(g_catv_rec.TEXT, DBMS_LOB.LOB_READWRITE);
    DBMS_LOB.COPY(dest_lob => g_catv_rec.TEXT,src_lob => l_clob,
  			amount => dbms_lob.getlength(l_clob));
    DBMS_LOB.CLOSE(g_catv_rec.TEXT);
    DBMS_LOB.CLOSE(l_clob);
    DBMS_LOB.freetemporary(l_clob);
  end if;
*/
  --
  -- code for temporary clob ... end
  --
--
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_catv_rec);
  OKL_VP_K_ARTICLE_PVT.update_k_article ( p_api_version 	=> p_api_version,
                              p_init_msg_list 	=> OKC_API.G_FALSE,
                              x_return_status 	=> x_return_status,
                              x_msg_count		=> x_msg_count,
                              x_msg_data		=> x_msg_data,
                              p_catv_rec		=> g_catv_rec,
                              x_catv_rec		=> x_catv_rec
                              );
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_catv_rec := x_catv_rec;
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
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end update_k_article;
-- Start of comments
--
-- Procedure Name  : update_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure update_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type,
                              x_catv_tbl	OUT NOCOPY	catv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_catv_tbl.COUNT>0) then
        i := p_catv_tbl.FIRST;
        LOOP
	    update_k_article(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_catv_rec=>p_catv_tbl(i),
                              x_catv_rec=>x_catv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_catv_tbl.LAST);
          i := p_catv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end update_k_article;
-- Start of comments
--
-- Procedure Name  : delete_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_rec	IN	catv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'DELETE_K_ARTICLE';
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  g_catv_rec := p_catv_rec;
  --
  -- Call Before Logic Hook
  --
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_catv_rec);
  OKL_VP_K_ARTICLE_PVT.delete_k_article
  	(
					p_api_version 	=> p_api_version,
                              p_init_msg_list 	=> OKC_API.G_FALSE,
                              x_return_status 	=> x_return_status,
                              x_msg_count		=> x_msg_count,
                              x_msg_data		=> x_msg_data,
                              p_catv_rec		=> g_catv_rec
  	);
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
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
end delete_k_article;
-- Start of comments
--
-- Procedure Name  : delete_k_article
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure delete_k_article(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_catv_tbl	IN	catv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
  OKC_API.init_msg_list(p_init_msg_list);
  x_return_status:= OKC_API.G_RET_STS_SUCCESS;
  if (p_catv_tbl.COUNT>0) then
    i := p_catv_tbl.FIRST;
    LOOP
      delete_k_article(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_catv_rec=>p_catv_tbl(i));
      if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          x_return_status := l_return_status;
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
          x_return_status := l_return_status;
      end if;
      EXIT WHEN (i=p_catv_tbl.LAST);
      i := p_catv_tbl.NEXT(i);
    END LOOP;
  end if;
exception
when others then NULL;
end delete_k_article;


-- Start of comments
--
-- Procedure Name  : std_art_name
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
function std_art_name(p_sav_sae_id IN NUMBER) return varchar2 is
l_name varchar2(150);
cursor c1 is
  select name
  from OKC_STD_ARTICLES_V
  where ID = p_sav_sae_id;
begin
  open c1;
  fetch c1 into l_name;
  close c1;
  return l_name;
end std_art_name;

-----------------------------------------------------------------------------
-- If p_text passed, updates the text with p_text.
-- Otherwise copies clob text to other recs with same source_lang as lang
-- in OKC_K_ARTICLES_TL table
------------------------------------------------------------------------------
-- new 11510 version of FUNCTION Copy_Articles_Text
  FUNCTION Copy_Articles_Text(p_id NUMBER,lang VARCHAR2,p_text VARCHAR2 ) RETURN VARCHAR2
   IS
    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(4000);
    p_api_version NUMBER := 1.0;
    p_init_msg_list VARCHAR2(1) := OKC_API.G_FALSE;

    length            NUMBER;
    l_chr_id            OKL_VP_ASSOCIATIONS.CHR_ID%TYPE;


    CURSOR cur_get_chr_id IS
    SELECT dnz_chr_id
    FROM   okc_k_articles_v
    WHERE  id = p_id;

   BEGIN

    /* Manu 22-Jul-2005 Begin */
    OPEN  cur_get_chr_id;
    FETCH cur_get_chr_id INTO l_chr_id;
    CLOSE cur_get_chr_id;
    /* Manu 22-Jul-2005 END */

    IF (p_text IS NOT NULL) THEN
      l_return_status := OKC_UTIL.Copy_Articles_Text(p_id   => p_id,
                                  lang   => lang,
                                  p_text => p_text);

      /* Manu 22-Jul-2005 Begin */
      IF (l_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        OKL_VENDOR_PROGRAM_PVT.passed_to_incomplete(p_api_version    => p_api_version
                               ,p_init_msg_list => p_init_msg_list
                               ,x_return_status => x_return_status
                               ,x_msg_count     => x_msg_count
                               ,x_msg_data      => x_msg_data
                               ,p_program_id    => l_chr_id
                              );
      END IF;
      /* Manu 22-Jul-2005 END */

    END IF;
    RETURN l_return_status;
   EXCEPTION
    WHEN OTHERS THEN
	  l_return_status := OKL_API.G_RET_STS_ERROR;
	  RETURN l_return_status;
  END Copy_Articles_Text;


END; -- Package Body OKL_VP_K_ARTICLE_PUB

/
