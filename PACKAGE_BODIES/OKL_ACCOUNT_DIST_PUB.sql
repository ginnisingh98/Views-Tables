--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_DIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_DIST_PUB" AS
/* $Header: OKLPTDTB.pls 120.2 2006/07/11 09:39:01 dkagrawa noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.ENGINE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator



PROCEDURE  CREATE_ACCOUNTING_DIST(p_api_version          IN       NUMBER,
                                  p_init_msg_list        IN       VARCHAR2,
                                  x_return_status        OUT      NOCOPY VARCHAR2,
                                  x_msg_count            OUT      NOCOPY NUMBER,
                                  x_msg_data             OUT      NOCOPY VARCHAR2,
                                  p_tmpl_identify_rec    IN       TMPL_IDENTIFY_REC_TYPE,
                                  p_dist_info_rec       IN       dist_info_REC_TYPE,
                                  p_ctxt_val_tbl         IN       CTXT_VAL_TBL_TYPE,
                                  p_acc_gen_primary_key_tbl  IN   acc_gen_primary_key,
                                  x_template_tbl         OUT      NOCOPY AVLV_TBL_TYPE,
                                  x_amount_tbl           OUT      NOCOPY AMOUNT_TBL_TYPE)

IS


  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'CREATE_ACCOUNTING_DIST';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_tmpl_identify_rec TMPL_IDENTIFY_REC_TYPE := p_tmpl_identify_rec;
  l_dist_info_rec    dist_info_REC_TYPE    := p_dist_info_rec;
  l_ctxt_val_tbl      CTXT_VAL_TBL_TYPE      := p_ctxt_val_tbl;
  l_acc_gen_primary_key_tbl acc_gen_primary_key := p_acc_gen_primary_key_tbl;
  l_template_tbl      AVLV_TBL_TYPE;
  l_amount_tbl        AMOUNT_TBL_TYPE;




BEGIN


  SAVEPOINT CREATE_ACCOUNTING_DIST1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure



-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
    OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST(p_api_version       => l_api_version,
                                                p_init_msg_list     => OKL_API.G_FALSE,
                                                x_return_status     => x_return_status,
                                                x_msg_count         => x_msg_count,
                                                x_msg_data          => x_msg_data,
                                                p_tmpl_identify_rec => l_tmpl_identify_rec,
                                                p_dist_info_rec    => l_dist_info_rec,
                                                p_ctxt_val_tbl      => l_ctxt_val_tbl,
                                                p_acc_gen_primary_key_tbl  =>
                                                                 l_acc_gen_primary_key_tbl,
                                                x_template_tbl      => x_template_tbl,
                                                x_amount_tbl        => x_amount_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST


  IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  l_template_tbl := x_template_tbl;
  l_amount_tbl   := x_amount_tbl;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_ACCOUNTING_DIST1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_ACCOUNTING_DIST1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO CREATE_ACCOUNTING_DIST1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNT_DIST_PUB','CREATE_ACCOUNTING_DIST');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END CREATE_ACCOUNTING_DIST;



PROCEDURE   CREATE_ACCOUNTING_DIST(p_api_version              IN       NUMBER,
                                   p_init_msg_list            IN       VARCHAR2,
                                   x_return_status            OUT      NOCOPY VARCHAR2,
                                   x_msg_count                OUT      NOCOPY NUMBER,
                                   x_msg_data                 OUT      NOCOPY VARCHAR2,
                                   p_tmpl_identify_rec        IN       TMPL_IDENTIFY_REC_TYPE,
                                   p_dist_info_rec            IN       DIST_INFO_REC_TYPE,
                                   p_ctxt_val_tbl             IN       CTXT_VAL_TBL_TYPE,
                                   p_acc_gen_primary_key_tbl  IN       acc_gen_primary_key,
                                   x_template_tbl             OUT      NOCOPY AVLV_TBL_TYPE,
                                   x_amount_tbl               OUT      NOCOPY AMOUNT_TBL_TYPE,
                                   x_gl_date                  OUT      NOCOPY DATE)
IS
BEGIN


     SAVEPOINT CREATE_ACCOUNTING_DIST1;

     x_return_status    := FND_API.G_RET_STS_SUCCESS;


-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
    OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST(p_api_version               => p_api_version,
                                                p_init_msg_list             => p_init_msg_list,
                                                x_return_status             => x_return_status,
                                                x_msg_count                 => x_msg_count,
                                                x_msg_data                  => x_msg_data,
                                                p_tmpl_identify_rec         => p_tmpl_identify_rec,
                                                p_dist_info_rec             => p_dist_info_rec,
                                                p_ctxt_val_tbl              => p_ctxt_val_tbl,
                                                p_acc_gen_primary_key_tbl   => p_acc_gen_primary_key_tbl,
                                                x_template_tbl              => x_template_tbl,
                                                x_amount_tbl                => x_amount_tbl,
                                                x_gl_date                   => x_gl_date );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.CREATE_ACCOUNTING_DIST


    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;





EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_ACCOUNTING_DIST1;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_ACCOUNTING_DIST1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO CREATE_ACCOUNTING_DIST1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNT_DIST_PUB','CREATE_ACCOUNTING_DIST');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;




END CREATE_ACCOUNTING_DIST;




PROCEDURE   GET_TEMPLATE_INFO(p_api_version        IN      NUMBER,
                              p_init_msg_list      IN      VARCHAR2,
                              x_return_status      OUT     NOCOPY VARCHAR2,
                              x_msg_count          OUT     NOCOPY NUMBER,
                              x_msg_data           OUT     NOCOPY VARCHAR2,
                              p_tmpl_identify_rec  IN      TMPL_IDENTIFY_REC_TYPE,
                              x_template_tbl       OUT NOCOPY     AVLV_TBL_TYPE,
                              p_validity_date            IN      DATE DEFAULT SYSDATE)

IS

  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'GET_TEMPLATE_INFO';
  l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  l_tmpl_identify_rec TMPL_IDENTIFY_REC_TYPE := p_tmpl_identify_rec;

  l_template_tbl      AVLV_TBL_TYPE     ;



BEGIN


  SAVEPOINT GET_TEMPLATE_INFO1;

  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the Main Procedure

-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO ');
    END;
  END IF;

  OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO(p_api_version       => l_api_version,
                                         p_init_msg_list     => p_init_msg_list,
                                         x_return_status     => x_return_status,
                                         x_msg_count         => x_msg_count,
                                         x_msg_data          => x_msg_data,
                                         p_tmpl_identify_rec => l_tmpl_identify_rec,
                                         x_template_tbl      => x_template_tbl,
                                         p_validity_date           => p_validity_date);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.GET_TEMPLATE_INFO

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


  l_template_tbl  := x_template_tbl;




EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO GET_TEMPLATE_INFO1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO GET_TEMPLATE_INFO1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO GET_TEMPLATE_INFO1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNT_DIST_PUB','GET_TEMPLATE_INFO');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END GET_TEMPLATE_INFO;




PROCEDURE UPDATE_POST_TO_GL(p_api_version          IN               NUMBER,
                            p_init_msg_list        IN               VARCHAR2,
                            x_return_status        OUT              NOCOPY VARCHAR2,
                            x_msg_count            OUT              NOCOPY NUMBER,
                            x_msg_data             OUT              NOCOPY VARCHAR2,
                            p_source_id            IN               NUMBER,
			    p_source_table         IN               VARCHAR2)
IS

  l_api_version          NUMBER := 1.0;
  l_api_name             CONSTANT VARCHAR2(30)  := 'UPDATE_POST_TO_GL';
  l_source_id            NUMBER := p_source_id;
  l_source_table         OKL_TRNS_ACC_DSTRS.source_table%TYPE := p_source_table;
  l_return_status        VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

BEGIN

  SAVEPOINT UPDATE_POST_TO_GL1;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.UPDATE_POST_TO_GL
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.UPDATE_POST_TO_GL ');
    END;
  END IF;
   OKL_ACCOUNT_DIST_PVT.UPDATE_POST_TO_GL(p_api_version       => l_api_version,
                                          p_init_msg_list     => OKL_API.G_FALSE,
                                          x_return_status     => x_return_status,
                                          x_msg_count         => x_msg_count,
                                          x_msg_data          => x_msg_data,
                                          p_source_id         => l_source_id,
				          p_source_table      => l_source_table);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.UPDATE_POST_TO_GL ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.UPDATE_POST_TO_GL

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;




EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_POST_TO_GL1;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_POST_TO_GL1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN

      ROLLBACK TO UPDATE_POST_TO_GL1;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNT_DIST_PUB','UPDATE_POST_TO_GL');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;



END UPDATE_POST_TO_GL;



PROCEDURE  REVERSE_ENTRIES(p_api_version                IN         NUMBER,
                           p_init_msg_list              IN         VARCHAR2,
                           x_return_status              OUT        NOCOPY VARCHAR2,
                           x_msg_count                  OUT        NOCOPY NUMBER,
                           x_msg_data                   OUT        NOCOPY VARCHAR2,
                           p_source_id                  IN         NUMBER,
                           p_source_table               IN         VARCHAR2,
                           p_acct_date                  IN         DATE)
IS

BEGIN

-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.REVERSE_ENTRIES
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.REVERSE_ENTRIES ');
    END;
  END IF;
    OKL_ACCOUNT_DIST_PVT.REVERSE_ENTRIES(p_api_version       => p_api_version,
                                         p_init_msg_list     => p_init_msg_list,
                                         x_return_status     => x_return_status,
                                         x_msg_count         => x_msg_count,
                                         x_msg_data          => x_msg_data,
                                         p_source_id         => p_source_id,
                                         p_source_table      => p_source_table,
                                         p_acct_date         => p_acct_date);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.REVERSE_ENTRIES ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.REVERSE_ENTRIES


END REVERSE_ENTRIES;



PROCEDURE  DELETE_ACCT_ENTRIES(p_api_version                IN         NUMBER,
                               p_init_msg_list              IN         VARCHAR2,
                               x_return_status              OUT        NOCOPY VARCHAR2,
                               x_msg_count                  OUT        NOCOPY NUMBER,
                               x_msg_data                   OUT        NOCOPY VARCHAR2,
                               p_source_id                  IN         NUMBER,
                               p_source_table               IN         VARCHAR2)

IS

BEGIN


-- Start of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.DELETE_ACCT_ENTRIES
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.DELETE_ACCT_ENTRIES ');
    END;
  END IF;
    OKL_ACCOUNT_DIST_PVT.DELETE_ACCT_ENTRIES(p_api_version       => p_api_version,
                                             p_init_msg_list     => p_init_msg_list,
                                             x_return_status     => x_return_status,
                                             x_msg_count         => x_msg_count,
                                             x_msg_data          => x_msg_data,
                                             p_source_id         => p_source_id,
                                             p_source_table      => p_source_table);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTDTB.pls call OKL_ACCOUNT_DIST_PVT.DELETE_ACCT_ENTRIES ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_ACCOUNT_DIST_PVT.DELETE_ACCT_ENTRIES

END DELETE_ACCT_ENTRIES;




END OKL_ACCOUNT_DIST_PUB;

/
