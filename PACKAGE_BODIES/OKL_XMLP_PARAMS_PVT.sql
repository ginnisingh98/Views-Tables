--------------------------------------------------------
--  DDL for Package Body OKL_XMLP_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XMLP_PARAMS_PVT" AS
 /* $Header: OKLRXMPB.pls 120.0 2007/01/04 11:22:50 udhenuko noship $ */

 ----------------------------------------------------------------------------
 -- PROCEDURE create_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_xmlp_params_rec
  -- Description     : procedure for inserting the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure creates a record containing the parameter
  --                   name, value and type code.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec, x_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE create_xmlp_params_rec     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_rec         IN  xmp_rec_type
                                 ,x_xmp_rec         OUT NOCOPY xmp_rec_type
                                ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.create_xmlp_params_rec';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_xmp_rec                 xmp_rec_type ;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'create_xmlp_params_rec';

-------------------
-- DECLARE Cursors
-------------------

BEGIN
   L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
   IF(L_DEBUG_ENABLED='Y') THEN
     L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
     IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
   END IF;
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.insert_row ');
     END;
   END IF;

   l_xmp_rec := p_xmp_rec;
   l_api_version := 1.0;
   l_init_msg_list := OKL_API.g_false;
   l_msg_count := 0;

   SAVEPOINT create_xmlp_params_rec_PVT;
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- TAPI call to create a record for xmlp params in table OKL_XMLP_PARAMS.
   okl_xmp_pvt.insert_row( l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_xmp_rec,
                           x_xmp_rec);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.insert_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );


     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

END create_xmlp_params_rec;

----------------------------------------------------------------------------
 -- PROCEDURE create_xmlp_params_tbl
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_xmlp_params_tbl
  -- Description     : procedure for inserting the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure creates a record containing the parameter
  --                   name, value and type code.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_tbl, x_xmp_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE create_xmlp_params_tbl     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_tbl         IN  xmp_tbl_type
                                 ,x_xmp_tbl         OUT NOCOPY xmp_tbl_type
                                ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.create_xmlp_params_tbl';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_xmp_tbl                  xmp_tbl_type ;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'create_xmlp_params_tbl';

-------------------
-- DECLARE Cursors
-------------------

BEGIN
   L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
   IF(L_DEBUG_ENABLED='Y') THEN
     L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
     IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
   END IF;
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.insert_row ');
     END;
   END IF;

   l_xmp_tbl := p_xmp_tbl;
   l_api_version := 1.0;
   l_init_msg_list := OKL_API.g_false;
   l_msg_count := 0;

   SAVEPOINT create_xmlp_params_rec_PVT;
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- TAPI call to create a record for xmlp params in table OKL_XMLP_PARAMS.
   okl_xmp_pvt.insert_row( l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_xmp_tbl,
                           x_xmp_tbl);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.insert_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );


     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

END create_xmlp_params_tbl;

 -----------------------------------------------------------------------------
 -- PROCEDURE update_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_xmlp_params_rec
  -- Description     : procedure for updating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure updates a record based on the id provided.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec, x_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_xmlp_params_rec     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_rec         IN  xmp_rec_type
                                 ,x_xmp_rec         OUT NOCOPY xmp_rec_type
                                ) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.update_xmlp_params_rec';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_xmp_rec                 xmp_rec_type ;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'update_xmlp_params_rec';
-------------------
-- DECLARE Cursors
-------------------

BEGIN
   L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
   IF(L_DEBUG_ENABLED='Y') THEN
     L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
     IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
   END IF;
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.update_row ');
     END;
   END IF;
   l_xmp_rec := p_xmp_rec;
   l_api_version := 1.0;
   l_init_msg_list := OKL_API.g_false;
   l_msg_count := 0;

   SAVEPOINT update_xmlp_params_rec_PVT;
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- TAPI call to update xmlp params in table OKL_XMLP_PARAMS.
   okl_xmp_pvt.update_row(l_api_version,
                          l_init_msg_list,
                          l_return_status,
                          l_msg_count,
                          l_msg_data,
                          l_xmp_rec,
                          x_xmp_rec);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );


     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
END update_xmlp_params_rec;

-----------------------------------------------------------------------------
 -- PROCEDURE update_xmlp_params_tbl
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_xmlp_params_tbl
  -- Description     : procedure for updating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure updates a record based on the id provided.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_tbl, x_xmp_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE update_xmlp_params_tbl     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_xmp_tbl         IN  xmp_tbl_type
                                 ,x_xmp_tbl         OUT NOCOPY xmp_tbl_type
                                ) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.update_xmlp_params_tbl';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_xmp_tbl                  xmp_tbl_type ;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'update_xmlp_params_tbl';
-------------------
-- DECLARE Cursors
-------------------

BEGIN
   L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
   IF(L_DEBUG_ENABLED='Y') THEN
     L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
     IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
   END IF;
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.update_row ');
     END;
   END IF;
   l_xmp_tbl := p_xmp_tbl;
   l_api_version := 1.0;
   l_init_msg_list := OKL_API.g_false;
   l_msg_count := 0;

   SAVEPOINT update_xmlp_params_rec_PVT;
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- TAPI call to update xmlp params in table OKL_XMLP_PARAMS.
   okl_xmp_pvt.update_row(l_api_version,
                          l_init_msg_list,
                          l_return_status,
                          l_msg_count,
                          l_msg_data,
                          l_xmp_tbl,
                          x_xmp_tbl);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );


     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
END update_xmlp_params_tbl;

 ----------------------------------------------------------------------------
 -- PROCEDURE delete_xmlp_params
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_xmlp_params
  -- Description     : procedure for deleting the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : This procedure deletes a record based on the id provided.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec, x_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE delete_xmlp_params     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_batch_id         IN  OKL_XMLP_PARAMS.Batch_Id%TYPE
                                ) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.delete_xmlp_params';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_batch_id                 OKL_XMLP_PARAMS.Batch_Id%TYPE ;
  l_id                       OKL_XMLP_PARAMS.Id%TYPE ;
  l_xmp_rec                  xmp_rec_type ;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'delete_xmlp_params';

-------------------
-- DECLARE Cursors
-------------------

  CURSOR c_get_param_ids(p_batch_id IN OKL_XMLP_PARAMS.Batch_Id%TYPE) IS
  SELECT ID,
         BATCH_ID
  FROM OKL_XMLP_PARAMS
  WHERE BATCH_ID = p_batch_id;

  BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.delete_row ');
    END;
  END IF;
  l_batch_id :=  p_batch_id;
  l_api_version := 1.0;
  l_init_msg_list := OKL_API.g_false;
  l_msg_count := 0;

  SAVEPOINT delete_xmlp_params_PVT;
  l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- Call TAPI to delete the xmlp params in table OKL_XMLP_PARAMS based on the batch id.
  FOR each_row IN c_get_param_ids(l_batch_id) LOOP
    l_xmp_rec.id := each_row.id;
    l_xmp_rec.batch_id := each_row.batch_id;
    okl_xmp_pvt.delete_row(l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_xmp_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END LOOP;


   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.delete_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
 END delete_xmlp_params;

 ---------------------------------------------------------------------------
 -- PROCEDURE validate_xmlp_params_rec
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_xmlp_params_rec
  -- Description     : procedure for validating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : Validates the record passed to it. x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_xmlp_params_rec( p_api_version     IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_xmp_rec            IN  xmp_rec_type) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.validate_xmlp_params_rec';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_xmp_rec                  xmp_rec_type := p_xmp_rec;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'validate_xmlp_params_rec';

-------------------
-- DECLARE Cursors
-------------------

  BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.validate_row ');
    END;
  END IF;
  l_api_version := 1.0;
  l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    -- TAPI call to validate the records.
    okl_xmp_pvt.validate_row(
	 p_api_version	        => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_xmp_rec	        => l_xmp_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.validate_row ');
    END;
  END IF;

  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_xmlp_params_rec;

---------------------------------------------------------------------------
 -- PROCEDURE validate_xmlp_params_tbl
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_xmlp_params_tbl
  -- Description     : procedure for validating the records in
  --                   table OKL_XMLP_PARAMS
  -- Business Rules  : Validates the records passed to it. x_return_status is 'S' on success.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_xmp_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_xmlp_params_tbl( p_api_version     IN  NUMBER,
                            p_init_msg_list       IN  VARCHAR2,
                            x_return_status       OUT NOCOPY VARCHAR2,
                            x_msg_count           OUT NOCOPY NUMBER,
                            x_msg_data            OUT NOCOPY VARCHAR2,
                            p_xmp_tbl            IN  xmp_tbl_type) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_XMLP_PARAMS_PVT.validate_xmlp_params_tbl';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_xmp_tbl                  xmp_tbl_type := p_xmp_tbl;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'validate_xmlp_params_tbl';


  BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRXMPB.pls call okl_xmp_pvt.validate_row ');
    END;
  END IF;
  l_api_version := 1.0;
  l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;


    -- TAPI call to validate the records.
    okl_xmp_pvt.validate_row(
	 p_api_version	        => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_xmp_tbl	        => l_xmp_tbl);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data	=> x_msg_data);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRXMPB.pls call okl_xmp_pvt.validate_row ');
    END;
  END IF;

  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_xmlp_params_tbl;

END OKL_XMLP_PARAMS_PVT;

/
