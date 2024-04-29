--------------------------------------------------------
--  DDL for Package Body OKL_FULFILLMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FULFILLMENT_PVT" AS
/* $Header: OKLRFULB.pls 115.9 2004/01/29 20:46:59 rvaduri noship $ */

------------------------------------------------------------------------------
-- Procedure create_fulfillment
------------------------------------------------------------------------------
PROCEDURE create_fulfillment (p_api_version   IN  NUMBER,
                              p_init_msg_list IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                              p_agent_id      IN  NUMBER,
                              p_server_id     IN  NUMBER,
                              p_content_id    IN  NUMBER,
                              p_from          IN  VARCHAR2,
                              p_subject       IN  VARCHAR2,
                              p_email         IN  VARCHAR2,
                              p_bind_var      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                              p_bind_val      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                              p_bind_var_type IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                              p_commit        IN  VARCHAR2,
                              x_request_id    OUT NOCOPY NUMBER,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count     OUT NOCOPY NUMBER,
                              x_msg_data      OUT NOCOPY VARCHAR2) IS

  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_request_id             NUMBER;
  l_content_xml            VARCHAR2(32767);
  l_extended_header        VARCHAR2(32767);
  l_commit                 VARCHAR2(1);

BEGIN

  IF (p_commit = FND_API.G_TRUE) OR (p_commit = FND_API.G_FALSE) THEN
    l_commit := p_commit;
  ELSE
    l_commit := G_COMMIT;
  END IF;

  jtf_fm_request_grp.start_request (p_api_version => G_API_VERSION,
                                    p_init_msg_list => P_INIT_MSG_LIST,
                                    p_commit => l_commit,
                                    p_validation_level => G_VALIDATION_LEVEL,
                                    x_return_status => x_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data => l_msg_data,
                                    x_request_id => l_request_id);

  IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (x_return_status =  OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;


  jtf_fm_request_grp.get_content_xml (p_api_version        => G_API_VERSION,
                                      p_init_msg_list      => P_INIT_MSG_LIST,
                                      p_commit             => l_commit,
                                      p_validation_level   => G_VALIDATION_LEVEL,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => l_msg_count,
                                      x_msg_data           => l_msg_data,
                                      p_content_id         => p_content_id,
                                      p_content_nm         => FND_API.G_MISS_CHAR,
                                      p_document_type      => FND_API.G_MISS_CHAR,
                                      p_quantity           => 1,
                                      p_media_type         => 'EMAIL',
                                      p_printer            => FND_API.G_MISS_CHAR,
                                      p_email              => p_email,
                                      p_fax                => FND_API.G_MISS_CHAR,
                                      p_file_path          => FND_API.G_MISS_CHAR,
                                      p_user_note          => FND_API.G_MISS_CHAR,
                                      p_content_type       => 'QUERY',
                                      p_bind_var           => p_bind_var,
                                      p_bind_val           => p_bind_val,
                                      p_bind_var_type      => p_bind_var_type,
                                      p_request_id         => l_request_id,
                                      x_content_xml        => l_content_xml);

  IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (x_return_status =  OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  l_extended_header :='<extended_header media_type="EMAIL">';
  -- "FROM" (default FROM is Recipient of the Email!)
  l_extended_header := l_extended_header||'<header_name>';
  l_extended_header := l_extended_header||'From';
  l_extended_header := l_extended_header||'</header_name>';
  l_extended_header := l_extended_header||'<header_value>';
  l_extended_header := l_extended_header||p_from;
  l_extended_header := l_extended_header||'</header_value>';
  l_extended_header := l_extended_header||'</extended_header>';


  jtf_fm_request_grp.submit_request (
                                     p_api_version => G_API_VERSION,
                                     p_init_msg_list => P_INIT_MSG_LIST,
                                     p_commit => l_commit,
                                     p_validation_level => G_VALIDATION_LEVEL,
                                     x_return_status => x_return_status,
                                     x_msg_count => l_msg_count,
                                     x_msg_data => l_msg_data,
                                     p_template_id => NULL,
                                     p_subject => p_subject,
                                     p_party_id => FND_API.G_MISS_NUM,
                                     p_party_name => FND_API.G_MISS_CHAR,
                                     p_user_id => p_agent_id,
                                     p_priority => jtf_fm_request_grp.G_PRIORITY_REGULAR,
                                     p_source_code_id => FND_API.G_MISS_NUM,
                                     p_source_code => FND_API.G_MISS_CHAR,
                                     p_object_type => FND_API.G_MISS_CHAR,
                                     p_object_id => FND_API.G_MISS_NUM,
                                     p_order_id => FND_API.G_MISS_NUM,
                                     p_doc_id => FND_API.G_MISS_NUM,
                                     p_doc_ref => FND_API.G_MISS_CHAR,
                                     p_server_id => p_server_id,
                                     p_queue_response => FND_API.G_FALSE,
                                     p_extended_header => l_extended_header,
                                     p_content_xml => l_content_xml,
                                     p_request_id => l_request_id);

  IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  ELSIF (x_return_status =  OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  x_request_id := l_request_id;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data   => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_FULFILLMENT_PVT','create_fulfillment');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_fulfillment;

END okl_fulfillment_pvt;

/
