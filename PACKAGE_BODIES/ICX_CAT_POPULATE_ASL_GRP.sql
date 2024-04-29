--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_ASL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_ASL_GRP" AS
/* $Header: ICXGPPAB.pls 120.3 2006/01/31 17:03:30 sbgeorge noship $*/

-- Constants
G_PKG_NAME      CONSTANT VARCHAR2(30):='ICX_CAT_POPULATE_ASL_GRP';

PROCEDURE populateOnlineASLs
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateOnlineASLs';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc			PLS_INTEGER;
l_start_date			DATE;
l_end_date			DATE;
l_log_string			VARCHAR2(2000);

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Stubbed out as per ECO 4911859 in R12

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END populateOnlineASLs;

PROCEDURE populateOnlineASLStatusRule
(       p_api_version           IN              NUMBER                                  ,
        p_commit                IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_init_msg_list         IN              VARCHAR2 := FND_API.G_FALSE             ,
        p_validation_level      IN              VARCHAR2 := FND_API.G_VALID_LEVEL_FULL  ,
        x_return_status         OUT NOCOPY      VARCHAR2                                ,
        p_key                   IN              NUMBER
)
IS
l_api_name                      CONSTANT VARCHAR2(30)   := 'populateOnlineASLStatusRule';
l_api_version                   CONSTANT NUMBER         := 1.0;
l_err_loc			PLS_INTEGER;
l_start_date			DATE;
l_end_date			DATE;
l_log_string			VARCHAR2(2000);

BEGIN
  l_err_loc := 100;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Stubbed out as per ECO 4911859 in R12

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END populateOnlineASLStatusRule;

END ICX_CAT_POPULATE_ASL_GRP;

/
