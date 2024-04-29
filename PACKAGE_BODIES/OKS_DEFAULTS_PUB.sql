--------------------------------------------------------
--  DDL for Package Body OKS_DEFAULTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_DEFAULTS_PUB" AS
/* $Header: OKSPCDTB.pls 120.2 2006/03/20 17:53:45 skkoppul noship $ */

  G_APP_NAME			CONSTANT VARCHAR2(3)   :=  OKC_API.G_APP_NAME;
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKS_DEFAULTS_PUB';
  G_CDTV_REC             cdtv_Rec_Type;

  G_MODULE              CONSTANT VARCHAR2(250) := 'oks.plsql.'||g_pkg_name||'.';

FUNCTION do_Dates_Overlap (p_id               NUMBER,
                           p_jtot_object_code VARCHAR2,
                           p_org_or_party_id  VARCHAR2,
                           p_start_date       DATE,
                           p_end_date         DATE)
 RETURN VARCHAR2 IS

  CURSOR csr_duplicate_check IS
   SELECT id, start_date, end_date
   FROM oks_k_defaults
   WHERE jtot_object_code = p_jtot_object_code
   AND segment_id1 = p_org_or_party_id;

  l_api_name   CONSTANT VARCHAR2(30) := 'do_Dates_Overlap';

  l_id            NUMBER;
  l_start_date    DATE;
  l_end_date      DATE;
  x_overlap_yn    VARCHAR2(1) := 'N';
  l_infinite_date DATE := TO_DATE(5373484,'j');

BEGIN

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
                    'Entered '||G_PKG_NAME ||'.'||l_api_name );
  END IF;

  IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'ID '||p_id ||' JTOT Obj Code '||p_jtot_object_code);
    FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'Party/Org id ' || p_org_or_party_id ||
                    ' Start Date ' || to_char(p_start_date,'DD-MON-RRRR') ||
                    ' End Date ' || to_char(p_end_date,'DD-MON-RRRR'));
  END IF;

  FOR dup_check_rec IN csr_duplicate_check
  LOOP
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'ID '||dup_check_rec.id  || ' Start Date ' || to_char(dup_check_rec.start_date,'DD-MON-RRRR') ||
                    ' End Date ' || to_char(dup_check_rec.end_date,'DD-MON-RRRR'));
    END IF;
    IF p_id IS NULL OR p_id <> dup_check_rec.id THEN

      -- check if the dates overlap
      IF ((dup_check_rec.start_date IS NULL AND dup_check_rec.end_date IS NULL) OR
          (p_start_date IS NULL AND p_end_date IS NULL) OR
          (dup_check_rec.end_date   IS NULL AND p_end_date IS NULL) OR
          (dup_check_rec.start_date IS NULL AND p_start_date IS NULL) OR
          (dup_check_rec.start_date BETWEEN p_start_date AND NVL(p_end_date,l_infinite_date)) OR
          (dup_check_rec.end_date   BETWEEN p_start_date AND NVL(p_end_date,l_infinite_date)) OR
          (p_start_date BETWEEN dup_check_rec.start_date AND NVL(dup_check_rec.end_date,l_infinite_date)) OR
          (p_end_date   BETWEEN dup_check_rec.start_date AND NVL(dup_check_rec.end_date,l_infinite_date)))
      THEN
        fnd_message.set_name('OKS','OKS_DATE_OVERLAP');
        fnd_message.set_token('DATE','OKS_DATE_OVERLAP_GBSET',TRUE);
        fnd_msg_pub.add;
        x_overlap_yn := 'Y';
        EXIT;
      END IF; -- duplicate record found with dates overlap
    END IF;
  END LOOP;
  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,G_MODULE||l_api_name,
       'Leaving '||G_PKG_NAME ||'.'||l_api_name||' x_overlap_yn='||x_overlap_yn);
  END IF;
  RETURN x_overlap_yn;
EXCEPTION
  WHEN OTHERS THEN
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       fnd_log.string(FND_LOG.LEVEL_EXCEPTION,G_MODULE||l_api_name,
          'Leaving '||G_PKG_NAME ||'.'||l_api_name||'.Others sqlcode = '
          ||SQLCODE||', sqlerrm = '||SQLERRM);
    END IF;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    RETURN NULL;
END;

procedure reset(p_cdtv_rec IN cdtv_rec_type) is
begin
    g_cdtv_rec.id                    := p_cdtv_rec.id;
    g_cdtv_rec.object_version_number := p_cdtv_rec.object_version_number;
    g_cdtv_rec.created_by            := p_cdtv_rec.created_by;
    g_cdtv_rec.creation_date         := p_cdtv_rec.creation_date;
    g_cdtv_rec.last_updated_by       := p_cdtv_rec.last_updated_by;
    g_cdtv_rec.last_update_date      := p_cdtv_rec.last_update_date;
end reset;

-- Start of comments
--
-- Procedure Name  : create_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Insert_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type,
                              x_cdtv_rec	OUT NOCOPY	cdtv_rec_type) is

l_api_name                     CONSTANT VARCHAR2(30) := 'Insert_defaults';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_overlap_yn                   VARCHAR2(1);

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
  g_cdtv_rec := p_cdtv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cdtv_rec);

  -- Check for operlapping dates
  l_overlap_yn := do_Dates_Overlap (
                        p_id               => NULL,
                        p_jtot_object_code => g_cdtv_rec.jtot_object_code,
                        p_org_or_party_id  => g_cdtv_rec.segment_id1,
                        p_start_date       => g_cdtv_rec.start_date,
                        p_end_date         => g_cdtv_rec.end_date
                       );
  IF l_overlap_yn IS NULL THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_overlap_yn = 'Y' THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  OKS_defaults_PVT.Insert_defaults(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cdtv_rec,
                              x_cdtv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_cdtv_rec := x_cdtv_rec;
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
end Insert_defaults;

-- Start of comments
--
-- Procedure Name  : create_default
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure Insert_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_tbl	IN	cdtv_tbl_type,
                              x_cdtv_tbl	OUT NOCOPY	cdtv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cdtv_tbl.COUNT>0) then
        i := p_cdtv_tbl.FIRST;
        LOOP
	    Insert_defaults(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cdtv_rec=>p_cdtv_tbl(i),
                              x_cdtv_rec=>x_cdtv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cdtv_tbl.LAST);
          i := p_cdtv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end Insert_defaults;

procedure update_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type,
                              x_cdtv_rec	OUT NOCOPY	cdtv_rec_type) is

l_api_name                     CONSTANT VARCHAR2(30) := 'update_defaults';
l_api_version                  CONSTANT NUMBER := 1;
l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_overlap_yn                   VARCHAR2(1);

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
  g_cdtv_rec := p_cdtv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cdtv_rec);

  -- Check for overlapping dates
  l_overlap_yn := do_Dates_Overlap (
                        p_id               => g_cdtv_rec.id,
                        p_jtot_object_code => g_cdtv_rec.jtot_object_code,
                        p_org_or_party_id  => g_cdtv_rec.segment_id1,
                        p_start_date       => g_cdtv_rec.start_date,
                        p_end_date         => g_cdtv_rec.end_date
                       );
  IF l_overlap_yn IS NULL THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF l_overlap_yn = 'Y' THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  OKS_defaults_PVT.update_defaults(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cdtv_rec,
                              x_cdtv_rec);
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --
  -- Call After Logic Hook
  --
  g_cdtv_rec := x_cdtv_rec;
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
end update_defaults;

-- Start of comments
--
-- Procedure Name  : update_default
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure update_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_tbl	IN	cdtv_tbl_type,
                              x_cdtv_tbl	OUT NOCOPY	cdtv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cdtv_tbl.COUNT>0) then
        i := p_cdtv_tbl.FIRST;
        LOOP
	    update_defaults(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cdtv_rec=>p_cdtv_tbl(i),
                              x_cdtv_rec=>x_cdtv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cdtv_tbl.LAST);
          i := p_cdtv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end update_defaults;

-- Start of comments
--
-- Procedure Name  : delete_default
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure delete_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'delete_defaults';
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
  g_cdtv_rec := p_cdtv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cdtv_rec);
  OKS_defaults_PVT.delete_defaults(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cdtv_rec);
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
end delete_defaults;

-- Start of comments
--
-- Procedure Name  : delete_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure delete_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_tbl	IN	cdtv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cdtv_tbl.COUNT>0) then
        i := p_cdtv_tbl.FIRST;
        LOOP
	    delete_defaults(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cdtv_rec=>p_cdtv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cdtv_tbl.LAST);
          i := p_cdtv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end delete_defaults;

-- Start of comments
--
-- Procedure Name  : lock_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'lock_defaults';
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
  g_cdtv_rec := p_cdtv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cdtv_rec);
  OKS_defaults_PVT.lock_defaults(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cdtv_rec);
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
end lock_defaults;

-- Start of comments
--
-- Procedure Name  : lock_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure lock_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_tbl	IN	cdtv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cdtv_tbl.COUNT>0) then
        i := p_cdtv_tbl.FIRST;
        LOOP
	    lock_defaults(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cdtv_rec=>p_cdtv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cdtv_tbl.LAST);
          i := p_cdtv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end lock_defaults;

-- Start of comments
--
-- Procedure Name  : validate_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_rec	IN	cdtv_rec_type) is
l_api_name                     CONSTANT VARCHAR2(30) := 'validate_defaults';
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
  g_cdtv_rec := p_cdtv_rec;
  okc_util.call_user_hook(x_return_status, g_pkg_name, l_api_name, 'B');
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    raise OKC_API.G_EXCEPTION_ERROR;
  END IF;
  reset(p_cdtv_rec);
  OKS_defaults_PVT.validate_defaults(p_api_version,
                              p_init_msg_list,
                              x_return_status,
                              x_msg_count,
                              x_msg_data,
                              g_cdtv_rec);
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
end validate_defaults;

-- Start of comments
--
-- Procedure Name  : validate_defaults
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_defaults(p_api_version	IN	NUMBER,
                              p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
                              x_return_status	OUT NOCOPY	VARCHAR2,
                              x_msg_count	OUT NOCOPY	NUMBER,
                              x_msg_data	OUT NOCOPY	VARCHAR2,
                              p_cdtv_tbl	IN	cdtv_tbl_type) is
i NUMBER;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
begin
     OKC_API.init_msg_list(p_init_msg_list);
      x_return_status:= OKC_API.G_RET_STS_SUCCESS;
      if (p_cdtv_tbl.COUNT>0) then
        i := p_cdtv_tbl.FIRST;
        LOOP
	    validate_defaults(p_api_version=>p_api_version,
                              p_init_msg_list=>OKC_API.G_FALSE,
                              x_return_status=>l_return_status,
                              x_msg_count=>x_msg_count,
                              x_msg_data=>x_msg_data,
                              p_cdtv_rec=>p_cdtv_tbl(i));
          if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
            x_return_status := l_return_status;
            raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          elsif (l_return_status = OKC_API.G_RET_STS_ERROR) then
            x_return_status := l_return_status;
          end if;
          EXIT WHEN (i=p_cdtv_tbl.LAST);
          i := p_cdtv_tbl.NEXT(i);
        END LOOP;
      end if;
exception
when others then NULL;
end validate_defaults;
end OKS_defaults_PUB;

/
