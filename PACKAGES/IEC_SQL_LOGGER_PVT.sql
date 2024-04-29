--------------------------------------------------------
--  DDL for Package IEC_SQL_LOGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEC_SQL_LOGGER_PVT" AUTHID CURRENT_USER AS
/* $Header: IECVLGRS.pls 115.8 2003/08/22 20:42:40 hhuang ship $ */

-- IEO Logging Constants
   G_TL_NONE            CONSTANT NUMBER := 0;
   G_TL_FATAL           CONSTANT NUMBER := 1;
   G_TL_ERROR           CONSTANT NUMBER := 2;
   G_TL_WARNING         CONSTANT NUMBER := 3;
   G_TL_INFO            CONSTANT NUMBER := 4;
   G_TL_CALL_LEVEL      CONSTANT NUMBER := 50;
   G_TL_TXN             CONSTANT NUMBER := 51;
   G_TL_DEBUG           CONSTANT NUMBER := 52;
   G_TL_ALL             CONSTANT NUMBER := 99;

-- IEO Alert Constants
   G_ALERT_NONE         CONSTANT NUMBER := 1;
   G_ALERT_SET          CONSTANT NUMBER := 4;
   G_ALERT_CLEAR        CONSTANT NUMBER := 16;
   G_ALERT_CLEAR_ALL    CONSTANT NUMBER := 64;

-- Generic Exception
   G_SVR_EXCEPTION      EXCEPTION;
   G_SVR_WARNING        EXCEPTION;
   G_SVR_SUCCESS        EXCEPTION;

-- Return Codes
   G_RETURN_EXCEPTION   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;
   G_RETURN_ERROR       CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
   G_RETURN_SUCCESS     CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

-- Generic table defs used for logging.
   TYPE VARCHAR2_TABLE is TABLE of VARCHAR2(4000) index by BINARY_INTEGER;
   TYPE NUMBER_TABLE is TABLE of NUMBER(15) index by BINARY_INTEGER;
   TYPE DATE_TABLE is TABLE of DATE index by BINARY_INTEGER;

-- Used for insert into log, descriptions and params table.
   L_DESC_B_INS_STMT VARCHAR2(4000);
   L_REC_B_INS_STMT VARCHAR2(4000);
   L_PARMS_B_INS_STMT VARCHAR2(4000);

-- Cache seq numbers here.
   G_SEQ_NUM  NUMBER(10);
   G_FETCH_SEQ_NUM  NUMBER(10);

-- Get the next record id
FUNCTION GET_NEXT_RECORD_ID RETURN NUMBER;

-- Get the source id for this source.
PROCEDURE GET_SOURCE_ID
  ( P_FACILITY_GUID             IN              VARCHAR2
  , P_APP_ID                    IN              VARCHAR2
  , P_FACILITY_NAME_MSG_NAME    IN              VARCHAR2
  , P_FACILITY_INSTANCE         IN              VARCHAR2
  , P_FACILITY_INSTANCE_UID     IN              VARCHAR2
  , P_IP_ADDRESS                IN              VARCHAR2
  , P_HOSTNAME                  IN              VARCHAR2
  , P_OS_USER_NAME              IN              VARCHAR2
  , P_LOG_LEVEL                 IN              NUMBER
  , X_SOURCE_ID                 IN OUT NOCOPY   NUMBER
  );

-- Log a message
PROCEDURE LOG
  ( P_SOURCE_ID            IN                   NUMBER
  , P_LOG_LEVEL            IN                   NUMBER
  , P_TIMESTAMP            IN                   DATE
  , P_TIMESTAMP_MILLI      IN                   NUMBER
  , P_ACTION_ID            IN                   NUMBER
  , P_SEVERITY_ID          IN                   NUMBER
  , P_TITLE_MSG_NAME       IN                   VARCHAR2
  , P_TITLE_MSG_APP_NAME   IN                   VARCHAR2
  , P_MESSAGE              IN                   VARCHAR2
  , X_RECORD_ID            IN OUT NOCOPY        NUMBER
  );

-- This uses the format 'yyyy-MM-DD HH:MI:SS'
-- Log a message
PROCEDURE LOG
  ( P_SOURCE_ID            IN                   NUMBER
  , P_LOG_LEVEL            IN                   NUMBER
  , P_TIMESTAMP            IN                   VARCHAR2
  , P_TIMESTAMP_MILLI      IN                   NUMBER
  , P_ACTION_ID            IN                   NUMBER
  , P_SEVERITY_ID          IN                   NUMBER
  , P_TITLE_MSG_NAME       IN                   VARCHAR2
  , P_TITLE_MSG_APP_NAME   IN                   VARCHAR2
  , P_MESSAGE              IN                   VARCHAR2
  , X_RECORD_ID            IN OUT NOCOPY        NUMBER
  );

-- Log the corresponding description
PROCEDURE LOG_DESCRIPTION
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_POS             IN     NUMBER
  , P_DESC_MSG_NAME        IN     VARCHAR2
  , P_DESC_MSG_APP_NAME    IN     VARCHAR2
  );

-- Use this for multiple descriptions
PROCEDURE LOG_DESCRIPTION
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_MSG_NAME        IN     VARCHAR2_TABLE
  , P_DESC_MSG_APP_NAME    IN     VARCHAR2_TABLE
  );

-- Log the description params
PROCEDURE DESCRIPTION_PARAMS
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_POS             IN     NUMBER
  , P_PARAM_POS            IN     NUMBER
  , P_PARAM_MSG_NAME       IN     VARCHAR2
  , P_PARAM_MSG_APP_NAME   IN     VARCHAR2
  , P_VALUE                IN     VARCHAR2
  , P_VALUE_TYPE           IN     NUMBER
  );

-- Use this for multiple parameters
PROCEDURE DESCRIPTION_PARAMS
  ( P_RECORD_ID            IN     NUMBER
  , P_DESC_POS             IN     NUMBER_TABLE
  , P_PARAM_MSG_NAME       IN     VARCHAR2_TABLE
  , P_PARAM_MSG_APP_NAME   IN     VARCHAR2_TABLE
  , P_PARAM_VALUE          IN     VARCHAR2_TABLE
  , P_PARAM_VALUE_TYPE     IN     NUMBER_TABLE
  );

END IEC_SQL_LOGGER_PVT;

 

/
