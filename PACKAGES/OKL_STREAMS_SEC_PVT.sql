--------------------------------------------------------
--  DDL for Package OKL_STREAMS_SEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_STREAMS_SEC_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLSSECS.pls 120.0.12010000.1 2008/08/06 05:08:05 sshinde noship $ */
  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_APP_NAME             CONSTANT VARCHAR2(3)   := OKL_API.G_APP_NAME;
  G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_STREAMS_SEC_PVT';
  G_API_NAME             CONSTANT VARCHAR2(30)  := 'OKL_STREAMS_SEC_PVT';
  G_DB_ERROR             CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  G_PROG_NAME_TOKEN      CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  G_SQLCODE_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLCODE';
  G_SQLERRM_TOKEN        CONSTANT VARCHAR2(7)   := 'SQLERRM';
  G_RET_STS_SUCCESS      CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_SUCCESS;
  G_RET_STS_UNEXP_ERROR  CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_UNEXP_ERROR;
  G_RET_STS_ERROR        CONSTANT VARCHAR2(1)   := FND_API.G_RET_STS_ERROR;
  G_FALSE                CONSTANT VARCHAR2(1)   := FND_API.G_FALSE;
  G_TRUE                 CONSTANT VARCHAR2(1)   := FND_API.G_TRUE;
  G_INVALID_VALUE        CONSTANT VARCHAR2(200) :=  OKC_API.G_INVALID_VALUE;

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  FUNCTION STREAMS_REPO_POLICY
                       (
                          --p_api_version   IN          NUMBER,
                          --p_init_msg_list IN          VARCHAR2 DEFAULT G_FALSE,
                          p_owner         IN          VARCHAR2,
                          p_obj_name      IN          VARCHAR2
                          --x_return_status OUT NOCOPY  VARCHAR2,
                          --x_msg_count     OUT NOCOPY  NUMBER,
                          --x_msg_data      OUT NOCOPY  VARCHAR2
                       )  RETURN VARCHAR2;

  PROCEDURE SET_REPO_STREAMS;

  PROCEDURE RESET_REPO_STREAMS;

  FUNCTION GET_STREAMS_POLICY RETURN VARCHAR2;

END  OKL_STREAMS_SEC_PVT;

/
