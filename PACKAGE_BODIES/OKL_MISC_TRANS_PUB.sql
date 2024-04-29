--------------------------------------------------------
--  DDL for Package Body OKL_MISC_TRANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_MISC_TRANS_PUB" AS
/* $Header: OKLPMSCB.pls 120.3 2005/10/30 04:26:07 appldev noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.TRANSACTIONS';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator



PROCEDURE CREATE_MISC_DSTR_LINE(p_api_version        IN     NUMBER,
                                p_init_msg_list      IN     VARCHAR2,
                                x_return_status      OUT    NOCOPY VARCHAR2,
                                x_msg_count          OUT    NOCOPY NUMBER,
                                x_msg_data           OUT    NOCOPY VARCHAR2,
                                p_tclv_rec           IN     tclv_rec_type,
                                x_tclv_rec           OUT    NOCOPY tclv_rec_type)
IS

l_api_version     NUMBER := 1.0;
l_api_name        VARCHAR2(30) := 'CREATE_MISC_DSTR_LINE';

l_tclv_rec        tclv_rec_type := p_tclv_rec;
l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN

  SAVEPOINT CREATE_MISC_DSTR_LINE;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


-- Start of wraper code generated automatically by Debug code generator for OKL_MISC_TRANS_PVT.CREATE_MISC_DSTR_LINE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPMSCB.pls call OKL_MISC_TRANS_PVT.CREATE_MISC_DSTR_LINE ');
    END;
  END IF;
  OKL_MISC_TRANS_PVT.CREATE_MISC_DSTR_LINE(p_api_version        => l_api_version,
                                           p_init_msg_list      => p_init_msg_list,
                                           x_return_status      => x_return_status,
                                           x_msg_count          => x_msg_count,
                                           x_msg_data           => x_msg_data,
                                           p_tclv_rec           => l_tclv_rec,
                                           x_tclv_rec           => x_tclv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPMSCB.pls call OKL_MISC_TRANS_PVT.CREATE_MISC_DSTR_LINE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_MISC_TRANS_PVT.CREATE_MISC_DSTR_LINE


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_tclv_rec := x_tclv_rec;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_MISC_DSTR_LINE;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_MISC_DSTR_LINE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      FND_MSG_PUB.ADD_EXC_MSG('OKL_MISC_TRANS_PUB','CREATE_MISC_DSTR_LINE');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END CREATE_MISC_DSTR_LINE;


  -----------------------------------------------------------------------------
  -- PROCEDURE create_misc_transaction
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_misc_transaction
  -- Description     : This procedure creates the manual journal header, lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 10-JUN-2004 RABHUPAT Created
  -- End of comments

  PROCEDURE create_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     OKL_MISC_TRANS_PVT.jrnl_line_tbl_type,
                                    x_jrnl_hdr_rec       OUT    NOCOPY OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type) IS

    l_prog_name      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'create_misc_transaction';

    l_jrnl_hdr_rec   OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type;
    l_jrnl_line_tbl  OKL_MISC_TRANS_PVT.jrnl_line_tbl_type;
    lx_jrnl_hdr_rec  OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type;

    lx_return_status VARCHAR2(1);

  BEGIN

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;
    -- initialize the local variables with the in records
    l_jrnl_hdr_rec  := p_jrnl_hdr_rec;
    l_jrnl_line_tbl := p_jrnl_line_tbl;

    -- call the private wrapper to create manual journal
    OKL_MISC_TRANS_PVT.create_misc_transaction(p_api_version       =>   p_api_version,
                                                   p_init_msg_list     =>   p_init_msg_list,
                                                   x_return_status     =>   lx_return_status,
                                                   x_msg_count         =>   x_msg_count,
                                                   x_msg_data          =>   x_msg_data,
                                                   p_jrnl_hdr_rec      =>   l_jrnl_hdr_rec,
                                                   p_jrnl_line_tbl     =>   l_jrnl_line_tbl,
                                                   x_jrnl_hdr_rec      =>   lx_jrnl_hdr_rec);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- return record
    x_jrnl_hdr_rec := lx_jrnl_hdr_rec;
    -- return the status
    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END create_misc_transaction;

  -----------------------------------------------------------------------------
  -- PROCEDURE update_misc_transaction
  -----------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_misc_transaction
  -- Description     : This procedure updates the manual journal header, creates/updates lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 10-JUN-2004 RABHUPAT Created
  -- End of comments

  PROCEDURE update_misc_transaction(p_api_version        IN     NUMBER,
                                    p_init_msg_list      IN     VARCHAR2,
                                    x_return_status      OUT    NOCOPY VARCHAR2,
                                    x_msg_count          OUT    NOCOPY NUMBER,
                                    x_msg_data           OUT    NOCOPY VARCHAR2,
                                    p_jrnl_hdr_rec       IN     OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type,
                                    p_jrnl_line_tbl      IN     OKL_MISC_TRANS_PVT.jrnl_line_tbl_type) IS

    l_prog_name      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'update_misc_transaction';

    l_jrnl_hdr_rec   OKL_MISC_TRANS_PVT.jrnl_hdr_rec_type;
    l_jrnl_line_tbl  OKL_MISC_TRANS_PVT.jrnl_line_tbl_type;

    lx_return_status VARCHAR2(1);

  BEGIN

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;
    -- initialize the local variables with the in records
    l_jrnl_hdr_rec  := p_jrnl_hdr_rec;
    l_jrnl_line_tbl := p_jrnl_line_tbl;

    -- call the private wrapper to create manual journal
    OKL_MISC_TRANS_PVT.update_misc_transaction(p_api_version       =>   p_api_version,
                                                   p_init_msg_list     =>   p_init_msg_list,
                                                   x_return_status     =>   lx_return_status,
                                                   x_msg_count         =>   x_msg_count,
                                                   x_msg_data          =>   x_msg_data,
                                                   p_jrnl_hdr_rec      =>   l_jrnl_hdr_rec,
                                                   p_jrnl_line_tbl     =>   l_jrnl_line_tbl);

    IF lx_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF lx_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- return the status
    x_return_status := lx_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_misc_transaction;



END OKL_MISC_TRANS_PUB;

/
