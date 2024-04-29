--------------------------------------------------------
--  DDL for Package FPA_UTILITIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_UTILITIES_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVUTLS.pls 120.1 2005/08/18 11:04:39 appldev ship $ */

procedure attach_AW(
  p_api_version                 IN              number
 ,p_attach_mode             IN              varchar2
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
);

procedure detach_AW(
  p_api_version                 IN              number
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
);

function Duplicate_Name(
  p_table_name                  IN              varchar2
 ,p_column_name                 IN              varchar2
 ,p_name                    IN              varchar2
) return number;

-- The following function returns the AW space for PJP.
-- It is used in the DDL for PJPs views.
function aw_space_name return varchar2;

function Get_Net_Cash_Needed(
  p_budget                  IN              number
 ,p_cash_req                    IN              number
) return number;

function Get_Overtime_Resources(
  p_req_resources               IN              number
 ,p_curr_resources      IN              number
) return number;

function Get_Unused_Resources(
  p_req_resources               IN              number
 ,p_curr_resources              IN              number
) return number;


/******  Section for common API messages, exception handling and logging. *********
******** created: ashariff Dt: 10/29/2004 ****************************************/

  TYPE msg_rec_type IS RECORD (
    error_status        NUMBER,
    data            VARCHAR2(2000));
  TYPE msg_tbl_type IS TABLE OF msg_rec_type
    INDEX BY BINARY_INTEGER;

  TYPE error_rec_type IS RECORD (
          idx                     NUMBER,
          error_type              VARCHAR2(1),
          msg_count               INTEGER,
          msg_data                VARCHAR2(2000),
          sqlcode                 NUMBER,
          api_name                VARCHAR2(30),
          api_package             VARCHAR2(30));
  TYPE error_tbl_type IS TABLE OF error_rec_type
          INDEX BY BINARY_INTEGER;


-- GLOBAL CONSTANTS

G_FALSE     CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE      CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_MISS_NUM  CONSTANT NUMBER := FND_API.G_MISS_NUM;
G_MISS_CHAR CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
G_MISS_DATE CONSTANT DATE := FND_API.G_MISS_DATE;

-- GLOBAL MESSAGE CONSTANTS

G_FND_APP           CONSTANT VARCHAR2(200) := 'FND';
G_APP_NAME          CONSTANT VARCHAR2(200) := 'FPA';
G_COL_NAME_TOKEN    CONSTANT VARCHAR2(200) := 'COL_NAME';

-- ERRORS AND EXCEPTIONS

G_RET_STS_SUCCESS       CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_WARNING       CONSTANT VARCHAR2(1) := 'W';
G_RET_STS_ERROR         CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
G_EXCEPTION_ERROR       EXCEPTION;
G_EXCEPTION_UNEXPECTED_ERROR    EXCEPTION;
G_EXC_WARNING           EXCEPTION;

-- Functions and Procedures

PROCEDURE init_msg_list(
    p_init_msg_list         IN VARCHAR2);

FUNCTION start_activity(
    p_api_name          IN VARCHAR2,
    p_pkg_name          IN VARCHAR2,
    p_init_msg_list     IN VARCHAR2,
    l_api_version       IN NUMBER,
    p_api_version       IN NUMBER,
    p_api_type          IN VARCHAR2,
    p_msg_log           IN VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2
) RETURN VARCHAR2;

PROCEDURE start_activity(
    p_api_name          IN VARCHAR2,
    p_pkg_name          IN VARCHAR2,
    p_init_msg_list     IN VARCHAR2,
    p_msg_log           IN VARCHAR2
);


FUNCTION handle_exceptions (
    p_api_name      IN VARCHAR2,
    p_pkg_name      IN VARCHAR2,
    p_exc_name      IN VARCHAR2,
    p_msg_log       IN VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    p_api_type      IN VARCHAR2
) RETURN VARCHAR2;

PROCEDURE end_activity
(
    p_api_name     IN VARCHAR2,
    p_pkg_name     IN VARCHAR2,
    p_msg_log      IN VARCHAR2,
    x_msg_count    OUT NOCOPY NUMBER,
    x_msg_data     OUT NOCOPY VARCHAR2
);

PROCEDURE set_message (
    p_app_name      IN VARCHAR2 DEFAULT FPA_UTILITIES_PVT.G_APP_NAME,
    p_msg_name      IN VARCHAR2,
    p_token1        IN VARCHAR2 DEFAULT NULL,
    p_token1_value  IN VARCHAR2 DEFAULT NULL,
    p_token2        IN VARCHAR2 DEFAULT NULL,
    p_token2_value  IN VARCHAR2 DEFAULT NULL,
    p_token3        IN VARCHAR2 DEFAULT NULL,
    p_token3_value  IN VARCHAR2 DEFAULT NULL,
    p_token4        IN VARCHAR2 DEFAULT NULL,
    p_token4_value  IN VARCHAR2 DEFAULT NULL,
    p_token5        IN VARCHAR2 DEFAULT NULL,
    p_token5_value  IN VARCHAR2 DEFAULT NULL,
    p_token6        IN VARCHAR2 DEFAULT NULL,
    p_token6_value  IN VARCHAR2 DEFAULT NULL,
    p_token7        IN VARCHAR2 DEFAULT NULL,
    p_token7_value  IN VARCHAR2 DEFAULT NULL,
    p_token8        IN VARCHAR2 DEFAULT NULL,
    p_token8_value  IN VARCHAR2 DEFAULT NULL,
    p_token9        IN VARCHAR2 DEFAULT NULL,
    p_token9_value  IN VARCHAR2 DEFAULT NULL,
    p_token10       IN VARCHAR2 DEFAULT NULL,
    p_token10_value IN VARCHAR2 DEFAULT NULL
);

/****END: Section for common API messages, exception handling and logging.******
********************************************************************************/

end FPA_Utilities_PVT;

 

/
