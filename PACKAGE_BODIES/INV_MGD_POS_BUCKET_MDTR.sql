--------------------------------------------------------
--  DDL for Package Body INV_MGD_POS_BUCKET_MDTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_POS_BUCKET_MDTR" AS
/* $Header: INVMPBKB.pls 115.4 2003/04/10 12:31:50 ghurli ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMPBKB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Inventory Position View and Export: Time Bucket Mediator          |
--| HISTORY                                                               |
--|     09/07/2000 Paolo Juvara      Created                              |
--+======================================================================*/

--===================
-- CONSTANTS
--===================
G_PKG_NAME           CONSTANT VARCHAR2(30):= 'INV_MGD_POS_BUCKET_MDTR';


--===================
-- TYPES
--===================

TYPE g_context_rec_type IS RECORD
( period_set_name VARCHAR2(15)
, period_type     VARCHAR2(15)
, organization_id NUMBER
, bucket_size     VARCHAR2(30)
);

TYPE g_period_rec_type  IS RECORD
( name            VARCHAR2(15)
, start_date      DATE
, end_date        DATE
);


--===================
-- CURSOR
--===================

CURSOR g_period_crsr
( p_period_set_name IN VARCHAR2
, p_period_type     IN VARCHAR2
, p_date_from       IN DATE
)
IS
SELECT
  period_name
, start_date
, end_date
, start_date
FROM gl_periods
WHERE period_set_name        = p_period_set_name
  AND period_type            = p_period_type
  AND adjustment_period_flag = 'N'
  AND end_date >= p_date_from
ORDER BY end_date;


--===================
-- PROCEDURES AND FUNCTIONS
--===================


--========================================================================
-- PROCEDURE : Get_Context             PRIVATE
-- PARAMETERS: p_organization_id       organization holding the calendar
--             p_bucket_size           bucket size
--             x_context_rec           context
-- COMMENT   : retrieves context information
--========================================================================
PROCEDURE Get_Context
( p_organization_id    IN            NUMBER
, p_bucket_size        IN            VARCHAR2
, x_context_rec        OUT NOCOPY    g_context_rec_type
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Get_Context';

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  x_context_rec.organization_id := p_organization_id;
  x_context_rec.bucket_size     := p_bucket_size;
  SELECT
    gsob.period_set_name
  , gsob.accounted_period_type
  INTO
    x_context_rec.period_set_name
  , x_context_rec.period_type
  FROM gl_sets_of_books gsob
     , org_organization_definitions ood
  WHERE gsob.set_of_books_id = ood.set_of_books_id
    AND organization_id      = p_organization_id;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Get_Context;

--========================================================================
-- PROCEDURE : Open_Cursor             PRIVATE
-- PARAMETERS: p_context_rec           context
--             p_date_from             date from
-- COMMENT   : open cursors
--========================================================================
PROCEDURE Open_Cursor
( p_context_rec IN g_context_rec_type
, p_date_from   IN DATE
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Open_Cursor';

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  IF p_context_rec.bucket_size = 'PERIOD' THEN
    OPEN g_period_crsr
    ( p_period_set_name => p_context_rec.period_set_name
    , p_period_type     => p_context_rec.period_type
    , p_date_from       => p_date_from
    );
  END IF;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Open_Cursor;

--========================================================================
-- PROCEDURE : Close_Cursor            PRIVATE
-- COMMENT   : close cursors
--========================================================================
PROCEDURE Close_Cursor
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Close_Cursor';

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  IF g_period_crsr%ISOPEN THEN
    CLOSE g_period_crsr;
  END IF;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Close_Cursor;


--========================================================================
-- FUNCTION  : Get_Increment           PRIVATE
-- PARAMETERS: p_bucket_size           PERIOD, WEEK, DAY or HOUR
-- COMMENT   : returns increment value in days (null if bucket is PERIOD
--========================================================================
FUNCTION Get_Increment
( p_bucket_size        IN            VARCHAR2
) RETURN NUMBER
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Get_Increment';
l_increment                NUMBER;

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  IF p_bucket_size = 'HOUR' THEN
    l_increment  := TO_NUMBER
                    ( TO_DATE('20000101 01:00:00', 'YYYYMMDD HH24:MI:SS') -
                      TO_DATE('20000101 00:00:00', 'YYYYMMDD HH24:MI:SS')
                    );
  ELSIF p_bucket_size = 'DAY' THEN
    l_increment  := 1;
  ELSIF p_bucket_size = 'WEEK' THEN
    l_increment  := 7;
  ELSIF p_bucket_size = 'PERIOD' THEN
    l_increment  := NULL;
  END IF;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

  RETURN l_Increment;

END Get_Increment;

--========================================================================
-- PROCEDURE : Get_Start_Info          PRIVATE
-- PARAMETERS: p_context_rec           context
--             p_date_from             date range from
--             x_start_date            start date
--             x_period_rec            period info
-- COMMENT   : determines the start bucket information
--========================================================================
PROCEDURE Get_Start_Info
( p_context_rec        IN            g_context_rec_type
, p_date_from          IN            DATE
, x_start_date         OUT NOCOPY    DATE
, x_period_rec         OUT NOCOPY    g_period_rec_type
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Get_Start_Info';

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  IF p_context_rec.bucket_size = 'HOUR' THEN
    x_start_date := TRUNC(p_date_from, 'HH');
  ELSIF p_context_rec.bucket_size = 'DAY' THEN
    x_start_date := TRUNC(p_date_from, 'DD');
  ELSIF p_context_rec.bucket_size = 'WEEK' THEN
    x_start_date := TRUNC(p_date_from, 'IW');
  ELSIF p_context_rec.bucket_size = 'PERIOD' THEN
    FETCH g_period_crsr
    INTO
      x_period_rec.name
    , x_period_rec.start_date
    , x_period_rec.end_date
    , x_start_date;
  END IF;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Get_Start_Info;

--========================================================================
-- PROCEDURE : Get_Bucket              PRIVATE
-- PARAMETERS: p_context               context
--             p_start_date            bucket begin
--             p_period_rec            period info (only for PERIOD)
--             x_bucket_rec            bucket
-- COMMENT   : build a bucket
--========================================================================
PROCEDURE Get_Bucket
( p_context_rec        IN            g_context_rec_type
, p_start_date         IN            DATE
, p_period_rec         IN            g_period_rec_type
, x_bucket_rec         OUT NOCOPY    INV_MGD_POS_UTIL.bucket_rec_type
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Get_Bucket';

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  IF p_context_rec.bucket_size = 'HOUR' THEN
    x_bucket_rec.name := FND_DATE.date_to_chardate(p_start_date) ||
                         ' - '                                   ||
                         TO_CHAR(p_start_date, 'HH24');
    x_bucket_rec.start_date := p_start_date;
    x_bucket_rec.end_date   := p_start_date +
                               Get_Increment(p_context_rec.bucket_size);
  ELSIF p_context_rec.bucket_size = 'DAY' THEN
    x_bucket_rec.name := FND_DATE.date_to_chardate(p_start_date);
    x_bucket_rec.start_date := p_start_date;
    x_bucket_rec.end_date   := p_start_date +
                               Get_Increment(p_context_rec.bucket_size);
  ELSIF p_context_rec.bucket_size = 'WEEK' THEN
    x_bucket_rec.name := TO_CHAR(p_start_date, 'IW');
    x_bucket_rec.start_date := p_start_date;
    x_bucket_rec.end_date   := p_start_date +
                               Get_Increment(p_context_rec.bucket_size);
  ELSIF p_context_rec.bucket_size = 'PERIOD' THEN
    x_bucket_rec.name := p_period_rec.name;
    x_bucket_rec.start_date := p_period_rec.start_date;
    x_bucket_rec.end_date   := p_period_rec.end_date + 1;  /*2872802*/
  END IF;
  x_bucket_rec.bucket_size := p_context_rec.bucket_size;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Get_Bucket;

--========================================================================
-- PROCEDURE : Increment_Start_Info    PRIVATE
-- PARAMETERS: p_context_rec           PERIOD, WEEK, DAY or HOUR
--             x_start_date            new bucket begin
--             x_period_rec            period info (only for PERIOD)
-- COMMENT   : increment the start information for the next bucket
--========================================================================
PROCEDURE Increment_Start_Info
( p_context_rec        IN            g_context_rec_type
, x_start_date         IN OUT NOCOPY DATE
, x_period_rec         IN OUT NOCOPY g_period_rec_type
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Increment_Start_Info';

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  IF p_context_rec.bucket_size = 'PERIOD' THEN
    FETCH g_period_crsr
    INTO
      x_period_rec.name
    , x_period_rec.start_date
    , x_period_rec.end_date
    , x_start_date;
    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'start date:'||TO_CHAR(x_period_rec.start_date, 'YYYY/MM/DD HH24:MI:SS')
    );
  ELSE
    x_start_date := x_start_date + Get_Increment(p_context_rec.bucket_size);
  END IF;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Increment_Start_Info;


--========================================================================
-- PROCEDURE : Build_Bucket_List       PUBLIC
-- PARAMETERS: p_init_msg_list         FND_API.G_TRUE to reset list
--             x_return_status         return status
--             x_msg_count             number of messages in the list
--             x_msg_data              text of messages
--             p_organization_id       organization holding the calendar
--             p_date_from             date range from
--             p_date_to               date range to
--             p_bucket_size           PERIOD, WEEK, DAY or HOUR
--             x_bucket_tbl            list of buckets
-- COMMENT   : Builds the list of buckets in the given date range
-- PRE-COND  : p_date_to > p_date_from
-- POST-COND : x_bucket_tbl is not empty
--========================================================================
PROCEDURE Build_Bucket_List
( p_organization_id    IN            NUMBER
, p_date_from          IN            DATE
, p_date_to            IN            DATE
, p_bucket_size        IN            VARCHAR2
, x_bucket_tbl         IN OUT NOCOPY INV_MGD_POS_UTIL.bucket_tbl_type
)
IS

l_api_name                 CONSTANT VARCHAR2(30):= 'Build_Bucket_List';
l_context_rec              g_context_rec_type;
l_start_date               DATE;
l_period_rec               g_period_rec_type;
l_bucket_rec               INV_MGD_POS_UTIL.bucket_rec_type;

BEGIN

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '> '||G_PKG_NAME||'.'||l_api_name
  );

  -- Initialize organization list
  x_bucket_tbl.DELETE;

  -- retrieve context info
  Get_Context
  ( p_organization_id => p_organization_id
  , p_bucket_size     => p_bucket_size
  , x_context_rec     => l_context_rec
  );

  -- open period cursor
  Open_Cursor
  ( p_context_rec     => l_context_rec
  , p_date_from       => p_date_from
  );

  -- determine begin first bucket
  Get_Start_Info
  ( p_context_rec     => l_context_rec
  , p_date_from       => p_date_from
  , x_start_date      => l_start_date
  , x_period_rec      => l_period_rec
  );

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
  , p_msg => 'initial start date:'||TO_CHAR(l_start_date, 'YYYY/MM/DD HH24:MI:SS')
  );

  LOOP

    Get_Bucket
    ( p_context_rec     => l_context_rec
    , p_start_date      => l_start_date
    , p_period_rec      => l_period_rec
    , x_bucket_rec      => l_bucket_rec
    );

    x_bucket_tbl(x_bucket_tbl.COUNT + 1) := l_bucket_rec;

    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'bucket_rec.name:'||l_bucket_rec.name
    );

    Increment_Start_Info
    ( p_context_rec     => l_context_rec
    , x_start_date      => l_start_date
    , x_period_rec      => l_period_rec
    );

    INV_MGD_POS_UTIL.Log
    ( p_priority => INV_MGD_POS_UTIL.G_LOG_STATEMENT
    , p_msg => 'new start date:'||TO_CHAR(l_start_date, 'YYYY/MM/DD HH24:MI:SS')
    );

    EXIT WHEN l_start_date > p_date_to;

  END LOOP;

  -- close period cursor
  Close_Cursor;

  INV_MGD_POS_UTIL.Log
  ( p_priority => INV_MGD_POS_UTIL.G_LOG_PROCEDURE
  , p_msg => '< '||G_PKG_NAME||'.'||l_api_name
  );

END Build_Bucket_List;


END INV_MGD_POS_BUCKET_MDTR;

/
