--------------------------------------------------------
--  DDL for Package Body OKC_PRICE_ADJUSTMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PRICE_ADJUSTMENT_PUB" AS
 /* $Header: OKCPPATB.pls 120.0 2005/05/25 22:50:02 appldev noship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Start of comments
--
-- Procedure Name  : create_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

PROCEDURE create_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_adjustment(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_patv_rec                     ,
    x_patv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : create_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE create_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type) is
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF p_patv_tbl.COUNT > 0 THEN
     i := p_patv_tbl.FIRST;
     LOOP
       create_price_adjustment(
           p_api_version,
           p_init_msg_list,
           l_return_status,
           x_msg_count,
           x_msg_data,
           p_patv_tbl(i),
           x_patv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
     END LOOP;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END create_price_adjustment;

-- Start of comments
--
-- Procedure Name  : update_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type,
    x_patv_rec                     OUT NOCOPY patv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_adjustment(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_patv_rec                     ,
    x_patv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : update_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type,
    x_patv_tbl                     OUT NOCOPY patv_tbl_type) is
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF p_patv_tbl.COUNT > 0 THEN
     i := p_patv_tbl.FIRST;
     LOOP
       update_price_adjustment(
           p_api_version,
           p_init_msg_list,
           l_return_status,
           x_msg_count,
           x_msg_data,
           p_patv_tbl(i),
           x_patv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
       END IF;
       EXIT WHEN (i = p_patv_tbl.LAST);
       i := p_patv_tbl.NEXT(i);
     END LOOP;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END update_price_adjustment;


-- Start of comments
--
-- Procedure Name  : delete_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_adjustment(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_patv_rec                     );
end;


-- Start of comments
--
-- Procedure Name  : delete_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type) is
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF p_patv_tbl.COUNT > 0 THEN
     i := p_patv_tbl.FIRST;
     LOOP
       delete_price_adjustment(
           p_api_version,
           p_init_msg_list,
           l_return_status,
           x_msg_count,
           x_msg_data,
           p_patv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
     END LOOP;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END delete_price_adjustment;


-- Start of comments
--
-- Procedure Name  : validate_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_adjustment(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_patv_rec                     );
end;


-- Start of comments
--
-- Procedure Name  : validate_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type) is
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF p_patv_tbl.COUNT > 0 THEN
     i := p_patv_tbl.FIRST;
     LOOP
       validate_price_adjustment(
           p_api_version,
           p_init_msg_list,
           l_return_status,
           x_msg_count,
           x_msg_data,
           p_patv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
     END LOOP;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_price_adjustment;


-- Start of comments
--
-- Procedure Name  : lock_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_rec                     IN patv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_adjustment(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_patv_rec                     );
end;


-- Start of comments
--
-- Procedure Name  : lock_price_adjustment
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_adjustment(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_patv_tbl                     IN patv_tbl_type) is
    i                              NUMBER := 0;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  IF p_patv_tbl.COUNT > 0 THEN
     i := p_patv_tbl.FIRST;
     LOOP
       lock_price_adjustment(
           p_api_version,
           p_init_msg_list,
           l_return_status,
           x_msg_count,
           x_msg_data,
           p_patv_tbl(i));
       IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
            raise G_EXCEPTION_HALT_VALIDATION;
          ELSE
            x_return_status := l_return_status;
          END IF;
        END IF;
        EXIT WHEN (i = p_patv_tbl.LAST);
        i := p_patv_tbl.NEXT(i);
     END LOOP;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END lock_price_adjustment;


-- Start of comments
--
-- Procedure Name  : create_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE create_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_rec                     ,
    x_pacv_rec                     );
end;


-- Start of comments
--
-- Procedure Name  : create_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE create_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_tbl                     ,
    x_pacv_tbl                     );

end;


-- Start of comments
--
-- Procedure Name  : update_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_rec                     ,
    x_pacv_rec                     );
end;


-- Start of comments
--
-- Procedure Name  : update_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_tbl                     ,
    x_pacv_tbl                     );
end;


-- Start of comments
--
-- Procedure Name  : delete_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : delete_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : validate_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : validate_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_tbl                     );

end;

-- Start of comments
--
-- Procedure Name  : lock_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_rec                     );

end;

-- Start of comments
--
-- Procedure Name  : lock_price_adj_assoc
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_adj_assoc(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_adj_assoc(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pacv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : create_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

  PROCEDURE create_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_rec                     ,
    x_pavv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : create_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE create_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_tbl                     ,
    x_pavv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : update_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type,
    x_pavv_rec                     OUT NOCOPY pavv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_rec                     ,
    x_pavv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : update_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type,
    x_pavv_tbl                     OUT NOCOPY pavv_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_tbl                     ,
    x_pavv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : delete_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : delete_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : validate_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : validate_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : lock_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_rec                     IN pavv_rec_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : lock_price_att_value
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_att_value(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pavv_tbl                     IN pavv_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_att_value(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_pavv_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : create_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE create_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_rec                     ,
    x_paav_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : create_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE create_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.create_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_tbl                     ,
    x_paav_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : update_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_rec                     ,
    x_paav_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : update_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE update_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.update_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_tbl                     ,
    x_paav_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : delete_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : delete_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE delete_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.delete_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : validate_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : validate_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE validate_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type ) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.validate_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_tbl                     );
end;

-- Start of comments
--
-- Procedure Name  : lock_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_rec                     );
end;

-- Start of comments
--
-- Procedure Name  : lock_price_adj_attrib
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

 PROCEDURE lock_price_adj_attrib(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type) is
begin
  OKC_PRICE_ADJUSTMENT_PVT.lock_price_adj_attrib(
    p_api_version                  ,
    p_init_msg_list                ,
    x_return_status                ,
    x_msg_count                    ,
    x_msg_data                     ,
    p_paav_tbl                     );
end;


END okc_price_adjustment_pub;

/
