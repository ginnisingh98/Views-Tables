--------------------------------------------------------
--  DDL for Package OKL_PERD_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_PERD_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRPSMS.pls 115.2 2002/07/03 22:53:46 kjinger noship $ */


TYPE period_rec_type IS RECORD (
APPLICATION_ID                NUMBER := OKL_API.G_MISS_NUM,
SET_OF_BOOKS_ID               NUMBER := OKL_API.G_MISS_NUM,
PERIOD_NAME                   GL_PERIOD_STATUSES.PERIOD_NAME%TYPE := OKL_API.G_MISS_CHAR,
LAST_UPDATE_DATE              GL_PERIOD_STATUSES.LAST_UPDATE_DATE%TYPE := OKL_API.G_MISS_DATE,
LAST_UPDATED_BY               NUMBER := OKL_API.G_MISS_NUM,
CLOSING_STATUS                GL_PERIOD_STATUSES.CLOSING_STATUS%TYPE := OKL_API.G_MISS_CHAR,
START_DATE                    GL_PERIOD_STATUSES.START_DATE%TYPE := OKL_API.G_MISS_DATE,
END_DATE                      GL_PERIOD_STATUSES.END_DATE%TYPE := OKL_API.G_MISS_DATE,
PERIOD_TYPE                   GL_PERIOD_STATUSES.PERIOD_TYPE%TYPE := OKL_API.G_MISS_CHAR,
PERIOD_YEAR                   NUMBER  := OKL_API.G_MISS_NUM,
PERIOD_NUM                    NUMBER  := OKL_API.G_MISS_NUM,
QUARTER_NUM                   NUMBER:= OKL_API.G_MISS_NUM,
ADJUSTMENT_PERIOD_FLAG        GL_PERIOD_STATUSES.ADJUSTMENT_PERIOD_FLAG%TYPE := OKL_API.G_MISS_CHAR,
CREATION_DATE                 GL_PERIOD_STATUSES.CREATION_DATE%TYPE := OKL_API.G_MISS_DATE,
CREATED_BY                    NUMBER:= OKL_API.G_MISS_NUM,
LAST_UPDATE_LOGIN             NUMBER:= OKL_API.G_MISS_NUM,
ATTRIBUTE1                    GL_PERIOD_STATUSES.ATTRIBUTE1%TYPE := OKL_API.G_MISS_CHAR,
ATTRIBUTE2                    GL_PERIOD_STATUSES.ATTRIBUTE2%TYPE := OKL_API.G_MISS_CHAR,
ATTRIBUTE3                    GL_PERIOD_STATUSES.ATTRIBUTE3%TYPE := OKL_API.G_MISS_CHAR,
ATTRIBUTE4                    GL_PERIOD_STATUSES.ATTRIBUTE4%TYPE := OKL_API.G_MISS_CHAR,
ATTRIBUTE5                    GL_PERIOD_STATUSES.ATTRIBUTE5%TYPE := OKL_API.G_MISS_CHAR,
CONTEXT                       GL_PERIOD_STATUSES.CONTEXT%TYPE := OKL_API.G_MISS_CHAR,
YEAR_START_DATE               GL_PERIOD_STATUSES.YEAR_START_DATE%TYPE := OKL_API.G_MISS_DATE,
QUARTER_START_DATE            GL_PERIOD_STATUSES.QUARTER_START_DATE%TYPE := OKL_API.G_MISS_DATE,
EFFECTIVE_PERIOD_NUM          NUMBER:= OKL_API.G_MISS_NUM,
ELIMINATION_CONFIRMED_FLAG    GL_PERIOD_STATUSES.ELIMINATION_CONFIRMED_FLAG%TYPE := OKL_API.G_MISS_CHAR);

TYPE period_tbl_type IS TABLE OF period_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE SEARCH_PERIOD_STATUS(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_period_rec         IN       PERIOD_REC_TYPE,
                               x_period_tbl         OUT      NOCOPY PERIOD_TBL_TYPE);


PROCEDURE UPDATE_PERIOD_STATUS   (p_api_version      IN       NUMBER,
                                  p_init_msg_list    IN       VARCHAR2,
                                  x_return_status    OUT      NOCOPY VARCHAR2,
                                  x_msg_count        OUT      NOCOPY NUMBER,
                                  x_msg_data         OUT      NOCOPY VARCHAR2,
                                  p_period_tbl       IN       PERIOD_TBL_TYPE);


PROCEDURE UPDATE_PERD_ROW (p_api_version        IN       NUMBER,
                           p_init_msg_list      IN       VARCHAR2,
                           x_return_status      OUT      NOCOPY VARCHAR2,
                           x_msg_count          OUT      NOCOPY NUMBER,
                           x_msg_data           OUT      NOCOPY VARCHAR2,
                           p_period_rec         IN       PERIOD_REC_TYPE);


G_PKG_NAME CONSTANT VARCHAR2(200)      := 'OKL_PERD_STATUS_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)        :=  OKL_API.G_APP_NAME;
G_REQUIRED_VALUE              CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                       CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_COL_NAME_TOKEN              CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;

END;

 

/
