--------------------------------------------------------
--  DDL for Package Body PV_QA_CHECK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_QA_CHECK_PVT" AS
/* $Header: pvxvqacb.pls 120.2 2006/03/31 15:30:29 ktsao noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_QA_CHECK_PVT';

  PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE execute_qa_check_list(
    p_api_version                  IN  NUMBER,
    p_init_msg_list                IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_doc_type                     IN  VARCHAR2,
    p_doc_id                       IN  NUMBER,
    x_qa_return_status             OUT NOCOPY VARCHAR2,
    x_msg_tbl                      OUT NOCOPY JTF_VARCHAR2_TABLE_2000)
    --x_err_tbl                      OUT NOCOPY JTF_VARCHAR2_TABLE_100)
  IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name                     CONSTANT VARCHAR2(30) := 'execute_qa_check_list';
    l_api_type                     CONSTANT VARCHAR2(5) := '_PVT';
    l_api_version                  CONSTANT NUMBER   := 1.0;
    l_qa_result_tbl                OKC_TERMS_QA_GRP.qa_result_tbl_type;

  BEGIN

 	   DBMS_TRANSACTION.SAVEPOINT(l_api_name || l_api_type);
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version,
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

      PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OKC_TERMS_QA_GRP.QA_Doc(
           p_api_version       => p_api_version,
           p_init_msg_list     => p_init_msg_list,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           --p_qa_mode         => null,
           p_doc_type          => p_doc_type,
           p_doc_id            => p_doc_id,
           x_qa_result_tbl     => l_qa_result_tbl,
           x_qa_return_status  => x_qa_return_status
           --p_qa_terms_only   => null
           );


      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
         raise OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF (x_qa_return_status = OKC_TERMS_QA_GRP.G_QA_STS_ERROR or x_qa_return_status = OKC_TERMS_QA_GRP.G_QA_STS_WARNING) THEN

         --x_err_tbl := JTF_VARCHAR2_TABLE_100();
         x_msg_tbl := JTF_VARCHAR2_TABLE_2000();

         FOR l_curr_row IN l_qa_result_tbl.first..l_qa_result_tbl.last LOOP
            x_msg_tbl.extend;
            x_msg_tbl(l_curr_row) := l_qa_result_tbl(l_curr_row).Problem_details;
            --x_err_tbl.extend;
            --x_err_tbl(l_curr_row) := l_qa_result_tbl(l_curr_row).error_status;
         END LOOP; --FOR l_curr_row IN 1..l_qa_result_tbl.count LOOP
      END IF;

  EXCEPTION

  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS( l_api_name
                                                 ,G_PKG_NAME
                                                 ,'OKC_API.G_RET_STS_ERROR'
                                                 ,x_msg_count
                                                 ,x_msg_data
                                                 ,l_api_type);
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS( l_api_name
                                                ,G_PKG_NAME
                                                ,'OKC_API.G_RET_STS_UNEXP_ERROR'
                                                ,x_msg_count
                                                ,x_msg_data
                                                ,l_api_type);
  WHEN OTHERS THEN
    x_return_status :=OKC_API.HANDLE_EXCEPTIONS( l_api_name
                                                ,G_PKG_NAME
                                                ,'OTHERS'
                                                ,x_msg_count
                                                ,x_msg_data
                                                ,l_api_type);
  END execute_qa_check_list;
END PV_QA_CHECK_PVT;


/
