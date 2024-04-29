--------------------------------------------------------
--  DDL for Package Body PV_K_REL_OBJS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_K_REL_OBJS_PVT" AS
/* $Header: pvxvkrob.pls 115.2 2003/10/24 01:17:36 ktsao ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_K_REL_OBJS_PVT';

  PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE create_k_rel_obj(
    p_api_version_number         IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status              OUT   NOCOPY VARCHAR2,
    x_msg_count                  OUT   NOCOPY NUMBER,
    x_msg_data                   OUT   NOCOPY VARCHAR2,
    p_crj_rel_hdr_full_rec	      IN		crj_rel_hdr_full_rec_type,
    x_crj_rel_hdr_full_rec	      OUT NOCOPY   crj_rel_hdr_full_rec_type)

  IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'create_k_rel_obj';
    l_api_version_number           CONSTANT NUMBER   := 1.0;
    l_crj_rel_hdr_full_rec         OKC_K_REL_OBJS_PUB.crj_rel_hdr_full_rec_type;
    l_crj_rel_line_tbl             OKC_K_REL_OBJS_PUB.crj_rel_line_tbl_type;
    l_x_crj_rel_hdr_full_rec         OKC_K_REL_OBJS_PUB.crj_rel_hdr_full_rec_type;
    x_crj_rel_line_tbl             OKC_K_REL_OBJS_PUB.crj_rel_line_tbl_type;

  BEGIN

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_crj_rel_hdr_full_rec.chr_id := p_crj_rel_hdr_full_rec.chr_id;
    l_crj_rel_hdr_full_rec.object1_id1 := p_crj_rel_hdr_full_rec.object1_id1;
    l_crj_rel_hdr_full_rec.object1_id2 := p_crj_rel_hdr_full_rec.object1_id2;
    l_crj_rel_hdr_full_rec.jtot_object1_code := p_crj_rel_hdr_full_rec.jtot_object1_code;
    l_crj_rel_hdr_full_rec.line_jtot_object1_code := p_crj_rel_hdr_full_rec.line_jtot_object1_code;
    l_crj_rel_hdr_full_rec.rty_code := p_crj_rel_hdr_full_rec.rty_code;


    OKC_K_REL_OBJS_PUB.create_k_rel_obj(
      p_api_version              => p_api_version_number,
      p_init_msg_list            => FND_API.G_FALSE,
      x_return_status            => x_return_status,
      x_msg_count                => x_msg_count,
      x_msg_data                 => x_msg_data,
      p_crj_rel_hdr_full_rec     => l_crj_rel_hdr_full_rec,
      p_crj_rel_line_tbl         => l_crj_rel_line_tbl,
      x_crj_rel_hdr_full_rec     => l_x_crj_rel_hdr_full_rec,
      x_crj_rel_line_tbl         => x_crj_rel_line_tbl);


     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       raise OKC_API.G_EXCEPTION_ERROR;
     END IF;

    x_crj_rel_hdr_full_rec.chr_id := l_x_crj_rel_hdr_full_rec.chr_id;
    x_crj_rel_hdr_full_rec.object1_id1 := l_x_crj_rel_hdr_full_rec.object1_id1;
    x_crj_rel_hdr_full_rec.object1_id2 := l_x_crj_rel_hdr_full_rec.object1_id2;
    x_crj_rel_hdr_full_rec.jtot_object1_code := l_x_crj_rel_hdr_full_rec.jtot_object1_code;
    x_crj_rel_hdr_full_rec.line_jtot_object1_code := l_x_crj_rel_hdr_full_rec.line_jtot_object1_code;
    x_crj_rel_hdr_full_rec.rty_code := l_x_crj_rel_hdr_full_rec.rty_code;


  EXCEPTION

  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS( l_api_name
                                                 ,G_PKG_NAME
                                                 ,'OKC_API.G_RET_STS_ERROR'
                                                 ,x_msg_count
                                                 ,x_msg_data
                                                 ,'_PUB');
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS( l_api_name
                                                ,G_PKG_NAME
                                                ,'OKC_API.G_RET_STS_UNEXP_ERROR'
                                                ,x_msg_count
                                                ,x_msg_data
                                                ,'_PUB');
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS( l_api_name
                                                ,G_PKG_NAME
                                                ,'OTHERS'
                                                ,x_msg_count
                                                ,x_msg_data
                                                ,'_PUB');
  END create_k_rel_obj;
END PV_K_REL_OBJS_PVT;


/
