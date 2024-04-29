--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_TRX_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_TRX_TYPES_PVT" AS
/* $Header: OKLRTXTB.pls 115.3 2002/11/01 23:16:01 santonyr noship $ */

-- Added by Santonyr 09-19-2002

G_RET_STS_SUCCESS		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_SUCCESS;
G_RET_STS_UNEXP_ERROR		CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_UNEXP_ERROR;
G_RET_STS_ERROR			CONSTANT VARCHAR2(1) 	:= OKL_API.G_RET_STS_ERROR;
G_EXCEPTION_UNEXPECTED_ERROR	EXCEPTION;
G_EXCEPTION_ERROR		EXCEPTION;


PROCEDURE insert_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type)

IS

l_api_version   NUMBER := 1.0;
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_name      VARCHAR2(30) := 'INSERT_TRX_TYPES';

BEGIN

  x_return_status    := OKL_API.G_RET_STS_SUCCESS;

  -- Set save point

  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;


  -- 08/30/2002 Added by Santonyr if check to see if the name is not null

    IF (p_tryv_rec.name IS NULL) OR
         (p_tryv_rec.name = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => 'OKL',
                             p_msg_name => 'OKL_NAME_REQUIRED' );

          RAISE G_EXCEPTION_ERROR;
    END IF;

    OKL_TRX_TYPES_PUB.insert_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_rec                     => p_tryv_rec,
                                        x_tryv_rec                     => x_tryv_rec);

    IF  (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    Okl_Api.end_activity(x_msg_count, x_msg_data);


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');

END insert_trx_types;


PROCEDURE insert_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type)

IS

l_api_version  	NUMBER := 1.0;
l_api_name      VARCHAR2(30) := 'INSERT_TRX_TYPES';
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
i 		NUMBER;

BEGIN

  x_return_status    := OKL_API.G_RET_STS_SUCCESS;

  -- Set save point
  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

-- 08/30/2002 Added by Santonyr. Check to see if the name is not null

 IF (p_tryv_tbl.COUNT > 0) THEN
      i := p_tryv_tbl.FIRST;
      LOOP
	    IF (p_tryv_tbl(i).name IS NULL) OR
	         (p_tryv_tbl(i).name = OKC_API.G_MISS_CHAR) THEN
	         OKC_API.SET_MESSAGE(p_app_name => 'OKL',
                             p_msg_name => 'OKL_NAME_REQUIRED' );

	          RAISE G_EXCEPTION_ERROR;
	    END IF;

            EXIT WHEN (i = p_tryv_tbl.LAST);
            i := p_tryv_tbl.NEXT(i);
      END LOOP;
  END IF;


 OKL_TRX_TYPES_PUB.insert_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_tbl                     => p_tryv_tbl,
                                        x_tryv_tbl                     => x_tryv_tbl);


  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');


END insert_trx_types;


-- 09/19/2002 Added by Santonyr
-- To Check if the update is allowed for this record. If the record is seeded,
-- do not allow updation.


FUNCTION Check_Update_Allowed (p_tryv_rec  IN  tryv_rec_type )
RETURN VARCHAR2
IS

    CURSOR try_lub_cur (l_id NUMBER) IS
    SELECT last_updated_by
    FROM   okl_trx_types_v
    WHERE id =  l_id;


    l_last_updated_by	okl_trx_types_v.last_updated_by%TYPE;
	l_update_allowed VARCHAR2(1) := 'Y';

  BEGIN

    FOR try_lub_rec IN try_lub_cur (p_tryv_rec.id) LOOP
      l_last_updated_by := try_lub_rec.last_updated_by;
    END LOOP;

    IF l_last_updated_by = 1 THEN
	l_update_allowed := 'N';
    END IF;

    RETURN l_update_allowed;

END Check_Update_Allowed;


PROCEDURE update_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type,
    x_tryv_rec                     OUT NOCOPY tryv_rec_type)

IS

l_api_version  	 NUMBER := 1.0;
l_return_status	 VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_update_allowed VARCHAR2(1) := 'Y';
l_api_name       VARCHAR2(30) := 'UPDATE_TRX_TYPES';


BEGIN

  x_return_status    := OKL_API.G_RET_STS_SUCCESS;

  -- Set save point
  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;


  -- 08/30/2002 Added by Santonyr Mandatory Check for Name

    IF (p_tryv_rec.name IS NULL) OR
         (p_tryv_rec.name = OKC_API.G_MISS_CHAR) THEN
         OKC_API.SET_MESSAGE(p_app_name => 'OKL',
                             p_msg_name => 'OKL_NAME_REQUIRED' );

          RAISE G_EXCEPTION_ERROR;
    END IF;


-- 09/19/2002 Added by Santonyr To Check if the updation is allowed.

    l_update_allowed :=  Check_Update_Allowed(p_tryv_rec);

    IF l_update_allowed = 'N' THEN
         OKC_API.SET_MESSAGE(p_app_name => 'OKL',
                             p_msg_name => 'OKL_NO_UPD_TRX_TYPE' );
          RAISE G_EXCEPTION_ERROR;
    END IF;


     OKL_TRX_TYPES_PUB.update_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_rec                     => p_tryv_rec,
                                        x_tryv_rec                     => x_tryv_rec);

  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;


  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');

END update_trx_types;



PROCEDURE update_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type,
    x_tryv_tbl                     OUT NOCOPY tryv_tbl_type)

IS

l_api_version  		NUMBER := 1.0;
l_update_allowed	VARCHAR2(1) := 'Y';
l_return_status		VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_name      	VARCHAR2(30) := 'UPDATE_TRX_TYPES';
i 			NUMBER;

BEGIN
  x_return_status    := OKL_API.G_RET_STS_SUCCESS;

  -- Set save point
  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);

  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

-- 08/30/2002 Added by Santonyr Check to see if the name is not null

 IF (p_tryv_tbl.COUNT > 0) THEN
      i := p_tryv_tbl.FIRST;

      LOOP
	    IF (p_tryv_tbl(i).name IS NULL) OR
	         (p_tryv_tbl(i).name = OKC_API.G_MISS_CHAR) THEN
	         OKC_API.SET_MESSAGE(p_app_name => 'OKL',
                             p_msg_name => 'OKL_NAME_REQUIRED' );

	          RAISE G_EXCEPTION_ERROR;
	    END IF;

-- 09/19/2002 Added by Santonyr To Check if the updation is allowed.

	    l_update_allowed :=  Check_Update_Allowed(p_tryv_tbl(i));

	    IF l_update_allowed = 'N' THEN
	         OKC_API.SET_MESSAGE(p_app_name => 'OKL',
	                             p_msg_name => 'OKL_NO_UPD_TRX_TYPE' );
	          RAISE G_EXCEPTION_ERROR;
	    END IF;

            EXIT WHEN (i = p_tryv_tbl.LAST);
            i := p_tryv_tbl.NEXT(i);
      END LOOP;
  END IF;


     OKL_TRX_TYPES_PUB.update_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_tbl                     => p_tryv_tbl,
                                        x_tryv_tbl                     => x_tryv_tbl);

  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;


  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');

END update_trx_types;


PROCEDURE delete_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_rec                     IN  tryv_rec_type)

IS

l_api_version  	NUMBER := 1.0;
l_api_name      VARCHAR2(30) := 'DELETE_TRX_TYPES';
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

  x_return_status    := OKL_API.G_RET_STS_SUCCESS;

  -- Set save point
  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;


  OKL_TRX_TYPES_PUB.delete_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_rec                     => p_tryv_rec);


  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');


END delete_trx_types;



PROCEDURE delete_trx_types(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tryv_tbl                     IN  tryv_tbl_type)

IS

l_api_version  NUMBER := 1.0;
l_api_name            VARCHAR2(30) := 'DELETE_TRX_TYPES';
l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

BEGIN

  x_return_status    := OKL_API.G_RET_STS_SUCCESS;

  -- Set save point
  l_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                               ,G_PKG_NAME
                                               ,p_init_msg_list
                                               ,l_api_version
                                               ,p_api_version
                                               ,'_PVT'
                                               ,l_return_status);
  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;


  OKL_TRX_TYPES_PUB.delete_trx_types(p_api_version                  => l_api_version,
                                        p_init_msg_list                => p_init_msg_list,
                                        x_return_status                => l_return_status,
                                        x_msg_count                    => x_msg_count,
                                        x_msg_data                     => x_msg_data,
                                        p_tryv_tbl                     => p_tryv_tbl);


  IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
    RAISE G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_Status = G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_ERROR;
  END IF;

  x_return_status := l_return_status;
  Okl_Api.end_activity(x_msg_count, x_msg_data);


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                     ,g_pkg_name
                                                     ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                     ,x_msg_count
                                                     ,x_msg_data
                                                     ,'_PVT');
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(l_api_name
                                                      ,g_pkg_name
                                                      ,'OTHERS'
                                                      ,x_msg_count
                                                      ,x_msg_data
                                                      ,'_PVT');


END delete_trx_types;


END OKL_PROCESS_TRX_TYPES_PVT;

/
