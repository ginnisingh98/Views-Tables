--------------------------------------------------------
--  DDL for Package Body OKL_PROCESS_TMPT_SET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PROCESS_TMPT_SET_PUB" AS
/* $Header: OKLPTMSB.pls 120.1.12010000.2 2010/03/13 00:38:06 gkadarka ship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.ACCOUNTING.TEMPLATE';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator
  PROCEDURE create_tmpt_set(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                     OUT NOCOPY VARCHAR2
    ,p_aesv_rec                     IN  aesv_rec_type
    ,p_avlv_tbl                     IN  avlv_tbl_type
    ,p_atlv_tbl                     IN  atlv_tbl_type
    ,x_aesv_rec                     OUT NOCOPY aesv_rec_type
    ,x_avlv_tbl                     OUT NOCOPY avlv_tbl_type
    ,x_atlv_tbl                     OUT NOCOPY atlv_tbl_type
    ) IS
    i                               NUMBER;
    l_api_name                      CONSTANT VARCHAR2(30)  := 'create_tmpt_set';
    l_aesv_rec                      aesv_rec_type := p_aesv_rec;
    l_return_status                 VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;
    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;
  BEGIN
    SAVEPOINT create_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => l_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_aesv_rec      => l_aesv_rec
                        ,p_avlv_tbl      => l_avlv_tbl
                        ,p_atlv_tbl      => l_atlv_tbl
                        ,x_aesv_rec      => x_aesv_rec
                        ,x_avlv_tbl      => x_avlv_tbl
						,x_atlv_tbl => x_atlv_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_aesv_rec := x_aesv_rec;
	   l_avlv_tbl := x_avlv_tbl;
	   l_atlv_tbl := x_atlv_tbl;
    -- vertical industry-post-processing
     -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_tmpt_set;

  PROCEDURE create_tmpt_set(
     p_api_version             IN  NUMBER
    ,p_init_msg_list           IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status           OUT NOCOPY VARCHAR2
    ,x_msg_count               OUT NOCOPY NUMBER
    ,x_msg_data                OUT NOCOPY VARCHAR2
    ,p_aesv_rec                IN  aesv_rec_type
    ,x_aesv_rec                OUT NOCOPY aesv_rec_type
    ,p_aes_source_id           IN OKL_AE_TMPT_SETS.id%TYPE DEFAULT NULL)
IS
    l_return_status            VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                 CONSTANT VARCHAR2(30)  := 'create_tmpt_set';
    l_aesv_rec                      aesv_rec_type := p_aesv_rec;
  BEGIN
    SAVEPOINT create_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_aesv_rec      => l_aesv_rec
                          ,x_aesv_rec      => x_aesv_rec
			  ,p_aes_source_id => p_aes_source_id
                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_tmpt_set
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_aesv_rec := x_aesv_rec;
    -- vertical industry-post-processing
     -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_tmpt_set;

  PROCEDURE create_tmpt_set(
     p_api_version               IN  NUMBER
    ,p_init_msg_list             IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status             OUT NOCOPY VARCHAR2
    ,x_msg_count                 OUT NOCOPY NUMBER
    ,x_msg_data                  OUT NOCOPY VARCHAR2
    ,p_aesv_tbl                  IN  aesv_tbl_type
    ,x_aesv_tbl                  OUT NOCOPY aesv_tbl_type) IS
    l_return_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                   CONSTANT VARCHAR2(30)  := 'create_tmpt_set';
    i                            NUMBER;
    l_aesv_tbl                      aesv_tbl_type := p_aesv_tbl;
    l_overall_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  --Initialize the return status
     SAVEPOINT create_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_aesv_tbl.COUNT > 0) THEN
      i := l_aesv_tbl.FIRST;
      LOOP
        create_tmpt_set(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_aesv_rec      => l_aesv_tbl(i)
                          ,x_aesv_rec      => x_aesv_tbl(i)
			  ,p_aes_source_id => NULL
                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_aesv_tbl.LAST);
          i := l_aesv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_status;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_aesv_tbl := x_aesv_tbl;
    -- vertical industry-post-processing
     -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_tmpt_set;

  -- Object type procedure for update
  PROCEDURE update_tmpt_set(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_aesv_rec              IN  aesv_rec_type,
    p_avlv_tbl              IN  avlv_tbl_type,
	p_atlv_tbl				IN	atlv_tbl_type,
    x_aesv_rec              OUT NOCOPY aesv_rec_type,
    x_avlv_tbl              OUT NOCOPY avlv_tbl_type,
	x_atlv_tbl				OUT NOCOPY atlv_tbl_type) IS
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name              CONSTANT VARCHAR2(30)  := 'update_tmpt_set';
    l_aesv_rec                      aesv_rec_type := p_aesv_rec;
    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;
    l_atlv_tbl                      atlv_tbl_type := p_atlv_tbl;
  BEGIN
    SAVEPOINT update_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set(
                         p_api_version   => p_api_version
                        ,p_init_msg_list => p_init_msg_list
                        ,x_return_status => l_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_aesv_rec      => l_aesv_rec
                        ,p_avlv_tbl      => l_avlv_tbl
                        ,p_atlv_tbl => l_atlv_tbl
                        ,x_aesv_rec      => x_aesv_rec
                        ,x_avlv_tbl      => x_avlv_tbl
						,x_atlv_tbl       => x_atlv_tbl
                        );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_aesv_rec := x_aesv_rec;
	   l_avlv_tbl := x_avlv_tbl;
	   l_atlv_tbl := x_atlv_tbl;
   -- vertical industry-post processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_tmpt_set;

  PROCEDURE update_tmpt_set(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_aesv_rec                   IN  aesv_rec_type
    ,x_aesv_rec                   OUT NOCOPY aesv_rec_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_tmpt_set';
    l_aesv_rec                      aesv_rec_type := p_aesv_rec;
  BEGIN
    SAVEPOINT update_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_aesv_rec      => l_aesv_rec
                          ,x_aesv_rec      => x_aesv_rec
                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_tmpt_set
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_aesv_rec := x_aesv_rec;
    -- vertical industry-post-processing
    -- customer post-processing
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_tmpt_set;


  PROCEDURE update_tmpt_set(
     p_api_version                IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status              OUT NOCOPY VARCHAR2
    ,x_msg_count                  OUT NOCOPY NUMBER
    ,x_msg_data                   OUT NOCOPY VARCHAR2
    ,p_aesv_tbl                   IN  aesv_tbl_type
    ,x_aesv_tbl                   OUT NOCOPY aesv_tbl_type) IS
    l_return_status               VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status              VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                    CONSTANT VARCHAR2(30)  := 'update_tmpt_set';
    i                             NUMBER;
    l_aesv_tbl                    aesv_tbl_type := p_aesv_tbl;
  BEGIN
  --Initialize the return status
    SAVEPOINT update_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_aesv_tbl.COUNT > 0) THEN
      i := l_aesv_tbl.FIRST;
      LOOP
        update_tmpt_set(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_aesv_rec      => l_aesv_tbl(i)
                          ,x_aesv_rec      => x_aesv_tbl(i)
                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_aesv_tbl.LAST);
          i := l_aesv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_Status;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_aesv_tbl := x_aesv_tbl;
    -- vertical industry-post-processing
    -- customer post-processing
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_tmpt_set;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_tmpt_set(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_aesv_rec              IN  aesv_rec_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_tmpt_set';
    l_aesv_rec                      aesv_rec_type := p_aesv_rec;
  BEGIN
    SAVEPOINT delete_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_set
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_set ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_set(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_aesv_rec      => l_aesv_rec
                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_set ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_set
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    -- vertical industry-post-processing
    -- customer post-processing
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','delete_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_tmpt_set;

  PROCEDURE delete_tmpt_set(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_aesv_tbl              IN  aesv_tbl_type) IS
    i                        NUMBER :=0;
    l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name               CONSTANT VARCHAR2(30)  := 'delete_tmpt_set';
    l_aesv_tbl                      aesv_tbl_type := p_aesv_tbl;
  BEGIN
    --Initialize the return status
     SAVEPOINT delete_tmpt_set2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_aesv_tbl.COUNT > 0) THEN
      i := l_aesv_tbl.FIRST;
      LOOP
        delete_tmpt_set(
                             p_api_version   => p_api_version
                            ,p_init_msg_list => p_init_msg_list
                            ,x_return_status => x_return_status
                            ,x_msg_count     => x_msg_count
                            ,x_msg_data      => x_msg_data
                            ,p_aesv_rec      => l_aesv_tbl(i)
                            );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
         EXIT WHEN (i = l_aesv_tbl.LAST);
         i := l_aesv_tbl.NEXT(i);
       END LOOP;
      END IF;
      x_return_status := l_overall_status;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    -- vertical industry-post-processing
    -- customer post-processing
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_set2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_tmpt_set2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','delete_tmpt_set');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_tmpt_set;

PROCEDURE create_template(p_api_version                  IN  NUMBER,
                          p_init_msg_list                IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                          x_return_status                OUT NOCOPY VARCHAR2,
                          x_msg_count                    OUT NOCOPY NUMBER,
                          x_msg_data                     OUT NOCOPY VARCHAR2,
                          p_avlv_rec                     IN  avlv_rec_type,
                          x_avlv_rec                     OUT NOCOPY avlv_rec_type)  IS
 l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
 l_api_name                        CONSTANT VARCHAR2(30)  := 'create_template';
 l_avlv_rec                      avlv_rec_type := p_avlv_rec;
  BEGIN
    SAVEPOINT create_template2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_template ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.create_template(p_api_version   => p_api_version
                                            ,p_init_msg_list => p_init_msg_list
                                            ,x_return_status => l_return_status
                                            ,x_msg_count     => x_msg_count
                                            ,x_msg_data      => x_msg_data
                                            ,p_avlv_rec      => l_avlv_rec
                                            ,x_avlv_rec      => x_avlv_rec );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_template
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_avlv_rec := x_avlv_rec;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_template2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_template2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_template2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_template;

  PROCEDURE create_template(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_avlv_tbl                       IN  avlv_tbl_type
    ,x_avlv_tbl                       OUT NOCOPY avlv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_template';
    i                                 NUMBER;
	l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;
  BEGIN
  --Initialize the return status
    SAVEPOINT create_template2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_avlv_tbl.COUNT > 0) THEN
      i := l_avlv_tbl.FIRST;
      LOOP
        create_template(p_api_version   => p_api_version
                       ,p_init_msg_list => p_init_msg_list
                       ,x_return_status => x_return_status
                       ,x_msg_count     => x_msg_count
                       ,x_msg_data      => x_msg_data
                       ,p_avlv_rec      => l_avlv_tbl(i)
                       ,x_avlv_rec      => x_avlv_tbl(i));        -- not possible thru this API
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_avlv_tbl.LAST);
          i := l_avlv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_status ;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
	   l_avlv_tbl := x_avlv_tbl;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_template2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_template2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_template2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_template;

  PROCEDURE update_template(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_avlv_rec                       IN  avlv_rec_type
    ,x_avlv_rec                       OUT NOCOPY avlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_template';
    l_avlv_rec                      avlv_rec_type := p_avlv_rec;
  BEGIN
    SAVEPOINT update_template2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_template ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.update_template(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_avlv_rec      => l_avlv_rec
                          ,x_avlv_rec      => x_avlv_rec
                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_template
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_avlv_rec := x_avlv_rec;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_template2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_template2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_template2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_template;

  PROCEDURE update_template(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_avlv_tbl                       IN  avlv_tbl_type
    ,x_avlv_tbl                       OUT NOCOPY avlv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_template';
    i                                 NUMBER;
    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;
   BEGIN
  --Initialize the return status
     SAVEPOINT update_template2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_avlv_tbl.COUNT > 0) THEN
      i := l_avlv_tbl.FIRST;
      LOOP
        update_template(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_avlv_rec      => l_avlv_tbl(i)
                          ,x_avlv_rec      => x_avlv_tbl(i)
                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_avlv_tbl.LAST);
          i := l_avlv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_status;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_avlv_tbl := x_avlv_tbl;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_template2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_template2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_template2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_template;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_template(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_avlv_rec                       IN  avlv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_template';
    l_avlv_rec                      avlv_rec_type := p_avlv_rec;
  BEGIN
    SAVEPOINT delete_template2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.delete_template
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.delete_template ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.delete_template(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_avlv_rec      => l_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.delete_template ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.delete_template
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_template2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_template2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_template2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','delete_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_template;

  PROCEDURE delete_template(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_avlv_tbl                       IN  avlv_tbl_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_template';
    l_avlv_tbl                      avlv_tbl_type := p_avlv_tbl;
  BEGIN
  --Initialize the return status
   SAVEPOINT delete_template2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_avlv_tbl.COUNT > 0) THEN
      i := l_avlv_tbl.FIRST;
      LOOP
        delete_template(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_avlv_rec      => l_avlv_tbl(i));
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_avlv_tbl.LAST);
          i := l_avlv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_status;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_template2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_template2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_template2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','delete_template');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_template;

  PROCEDURE create_tmpt_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_atlv_rec                       IN  atlv_rec_type
    ,x_atlv_rec                       OUT NOCOPY atlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_tmpt_lines';
    l_atlv_rec                      atlv_rec_type := p_atlv_rec;
  BEGIN
    SAVEPOINT create_tmpt_lines2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_tmpt_lines ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.create_tmpt_lines(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_atlv_rec      => l_atlv_rec
                          ,x_atlv_rec      => x_atlv_rec
                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.create_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.create_tmpt_lines
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_atlv_rec := x_atlv_rec;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_tmpt_lines2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_tmpt_lines;

  PROCEDURE create_tmpt_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_atlv_tbl                       IN  atlv_tbl_type
    ,x_atlv_tbl                       OUT NOCOPY atlv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'create_tmpt_lines';
    i                                 NUMBER;
    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;
  BEGIN
  --Initialize the return status
   SAVEPOINT create_tmpt_lines2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_atlv_tbl.COUNT > 0) THEN
      i := l_atlv_tbl.FIRST;
      LOOP
        create_tmpt_lines(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_atlv_rec      => l_atlv_tbl(i)
                          ,x_atlv_rec      => x_atlv_tbl(i)
                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
              l_overall_status := x_return_status;
              EXIT;
          END IF;
          EXIT WHEN (i = l_atlv_tbl.LAST);
          i := l_atlv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_Status;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
	   l_atlv_tbl := x_atlv_tbl;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_tmpt_lines2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','create_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END create_tmpt_lines;

  PROCEDURE update_tmpt_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_atlv_rec                       IN  atlv_rec_type
    ,x_atlv_rec                       OUT NOCOPY atlv_rec_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_tmpt_lines';
    l_atlv_rec                      atlv_rec_type := p_atlv_rec;
  BEGIN
    SAVEPOINT update_tmpt_lines2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_tmpt_lines ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.update_tmpt_lines(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_atlv_rec      => l_atlv_rec
                          ,x_atlv_rec      => x_atlv_rec
                          );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.update_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.update_tmpt_lines
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
	   l_atlv_rec := x_atlv_rec;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_tmpt_lines2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_tmpt_lines;

  PROCEDURE update_tmpt_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_atlv_tbl                       IN  atlv_tbl_type
    ,x_atlv_tbl                       OUT NOCOPY atlv_tbl_type) IS
    l_return_status                   VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1)   := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'update_tmpt_lines';
    i                                 NUMBER;
    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;
  BEGIN
  --Initialize the return status
    SAVEPOINT update_tmpt_lines2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_atlv_tbl.COUNT > 0) THEN
      i := l_atlv_tbl.FIRST;
      LOOP
        update_tmpt_lines(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => x_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_atlv_rec      => l_atlv_tbl(i)
                          ,x_atlv_rec      => x_atlv_tbl(i)
                          );
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_atlv_tbl.LAST OR x_return_status <> OKC_API.G_RET_STS_SUCCESS); -- Added OR condition for bug 9278844
          i := l_atlv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_status;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
	   l_atlv_tbl := x_atlv_tbl;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_tmpt_lines2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','update_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END update_tmpt_lines;

       --Put custom code for cascade delete by developer
  PROCEDURE delete_tmpt_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_atlv_rec                       IN  atlv_rec_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_tmpt_lines';
    l_atlv_rec                      atlv_rec_type := p_atlv_rec;
  BEGIN
    SAVEPOINT delete_tmpt_lines2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
   -- call complex entity API
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_lines
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_lines ');
    END;
  END IF;
    OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_lines(
                           p_api_version   => p_api_version
                          ,p_init_msg_list => p_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count     => x_msg_count
                          ,x_msg_data      => x_msg_data
                          ,p_atlv_rec      => l_atlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_lines ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.delete_tmpt_lines
       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_tmpt_lines2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','delete_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_tmpt_lines;

  PROCEDURE delete_tmpt_lines(
     p_api_version                    IN  NUMBER
    ,p_init_msg_list                  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
    ,x_return_status                  OUT NOCOPY VARCHAR2
    ,x_msg_count                      OUT NOCOPY NUMBER
    ,x_msg_data                       OUT NOCOPY VARCHAR2
    ,p_atlv_tbl                       IN  atlv_tbl_type) IS
    i                                 NUMBER :=0;
    l_return_status                   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                        CONSTANT VARCHAR2(30)  := 'delete_tmpt_lines';
    l_atlv_tbl						atlv_tbl_type := p_atlv_tbl;
  BEGIN
  --Initialize the return status
    SAVEPOINT delete_tmpt_lines2;
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
   -- customer pre-processing
   -- vertical industry-preprocessing
    IF (l_atlv_tbl.COUNT > 0) THEN
      i := l_atlv_tbl.FIRST;
      LOOP
        delete_tmpt_lines(
                                  p_api_version   => p_api_version
                                 ,p_init_msg_list => p_init_msg_list
                                 ,x_return_status => x_return_status
                                 ,x_msg_count     => x_msg_count
                                 ,x_msg_data      => x_msg_data
                                 ,p_atlv_rec      => l_atlv_tbl(i));
          IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
             IF (l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                 l_overall_status := x_return_status;
             END IF;
          END IF;
          EXIT WHEN (i = l_atlv_tbl.LAST);
          i := l_atlv_tbl.NEXT(i);
       END LOOP;
     END IF;
     x_return_status := l_overall_status;
     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   -- vertical industry-post-processing
   -- customer post-processing
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_tmpt_lines2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_tmpt_lines2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_PROCESS_TMPT_SET_PUB','delete_tmpt_lines');
      -- store SQL error message on message stack for caller
      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      -- notify caller of an UNEXPECTED error
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END delete_tmpt_lines;

/* This API Takes 'From Template Set ID'  and 'To Template Set ID'
   as parameters and copies all the templates and Template Line
   from 'From Template Set ID' to 'To Template Set ID'. The Template
   names in the copied templates is suffixed with '-COPY' so as not
   to violate the unique constraint.                                 */
PROCEDURE COPY_TMPL_SET(p_api_version                IN         NUMBER,
                        p_init_msg_list              IN         VARCHAR2,
                        x_return_status              OUT        NOCOPY VARCHAR2,
                        x_msg_count                  OUT        NOCOPY NUMBER,
                        x_msg_data                   OUT        NOCOPY VARCHAR2,
		        p_aes_id_from                IN         NUMBER,
		        p_aes_id_to                  IN         NUMBER)
IS
  l_api_version NUMBER := 1.0;
  l_api_name    VARCHAR2(30) := 'COPY_TMPL_SET';
  l_aes_id_from        NUMBER := p_aes_id_from;
  l_aes_id_to          NUMBER := p_aes_id_to;
  l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
  SAVEPOINT COPY_TMPL_SET2;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  -- customer pre-processing
-- Run the MAIN Procedure
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.COPY_TMPL_SET
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.COPY_TMPL_SET ');
    END;
  END IF;
   OKL_PROCESS_TMPT_SET_PVT.COPY_TMPL_SET(p_api_version      => l_api_version,
                                       p_init_msg_list    => p_init_msg_list,
                                       x_return_status    => x_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data,
                                       p_aes_id_from      => l_aes_id_from,
                                       p_aes_id_to        => l_aes_id_to);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.COPY_TMPL_SET ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.COPY_TMPL_SET
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO COPY_TMPL_SET2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO COPY_TMPL_SET2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN OTHERS THEN
      ROLLBACK TO COPY_TMPL_SET2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_COPY_TEMPLATE_PUB','COPY_TMPL_SET');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END COPY_TMPL_SET;


PROCEDURE COPY_TEMPLATE(p_api_version           IN         NUMBER,
                        p_init_msg_list         IN         VARCHAR2,
                        x_return_status         OUT        NOCOPY VARCHAR2,
                        x_msg_count             OUT        NOCOPY NUMBER,
                        x_msg_data              OUT        NOCOPY VARCHAR2,
                        p_avlv_rec              IN         avlv_rec_type,
                        p_source_tmpl_id        IN         NUMBER,
                        x_avlv_rec              OUT        NOCOPY avlv_rec_type)
IS
  l_api_version       NUMBER := 1.0;
  l_api_name          VARCHAR2(30) := 'COPY_TEMPLATES';
  l_avlv_rec          avlv_rec_type := p_avlv_rec;
  l_source_tmpl_id    NUMBER := p_source_tmpl_id;
  l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
  SAVEPOINT COPY_TEMPLATE2;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  -- customer pre-processing
-- Run the MAIN Procedure
-- Start of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.COPY_TEMPLATE
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.COPY_TEMPLATE ');
    END;
  END IF;
  OKL_PROCESS_TMPT_SET_PVT.COPY_TEMPLATE(p_api_version       => p_api_version,
                                      p_init_msg_list     => p_init_msg_list,
                                      x_return_status     => x_return_status,
                                      x_msg_count         => x_msg_count,
                                      x_msg_data          => x_msg_data,
                                      p_avlv_rec          => l_avlv_rec,
                                      p_source_tmpl_id    => l_source_tmpl_id,
                                      x_avlv_rec          => x_avlv_rec);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPTMSB.pls call OKL_PROCESS_TMPT_SET_PVT.COPY_TEMPLATE ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_PROCESS_TMPT_SET_PVT.COPY_TEMPLATE
  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO COPY_TEMPLATE2;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO COPY_TEMPLATE2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN OTHERS THEN
      ROLLBACK TO COPY_TEMPLATE2;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_COPY_TEMPLATE_PUB','COPY_TEMPLATE');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END COPY_TEMPLATE;

END OKL_PROCESS_TMPT_SET_PUB;



/
