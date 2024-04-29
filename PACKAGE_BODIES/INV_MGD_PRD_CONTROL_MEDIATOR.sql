--------------------------------------------------------
--  DDL for Package Body INV_MGD_PRD_CONTROL_MEDIATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MGD_PRD_CONTROL_MEDIATOR" AS
/*  $Header: INVMOCLB.pls 120.6.12010000.5 2010/02/25 20:01:15 fayang ship $ */
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVMOCLB.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|    Specification of    INV_MGD_PRD_CONTROL_MEDIATOR                   |
--|                                                                       |
--| HISTORY                                                               |
--|     25-Sep-2000  rajkrish            Created                          |
--|     24-Jan-2001  rajkrish            Updated      Request             |
--|     14-May-2001  vjavli              updated for performance tuning   |
--|     14-Jan-2002  vjavli              period final date for the origin |
--|     14-Jan-2002  vjavli              process the origin first         |
--|     09-May-2002  vjavli              leap frog from 115.24 115.27     |
--|     09-May-2002  vjavli              Bug#2230141 fix done for 115.26  |
--|                                      has to be coded again            |
--|     22-May-2002  vjavli              Bug#2386091 fix                  |
--|                                      get_pending_tcount added with    |
--|                                      parameter pending_ship           |
--|     27-May-2002  vjavli              Bug#2384953 fix to open the      |
--|                                      period for the hierarchy origin  |
--|     03-June-2002 vjavli              Bug#2395514 fix: removed         |
--|                                      pending_ship parameter           |
--|                                      this is to provide a customer fix|
--|                                      with leap frog version of core   |
--|                                      inv file: INVTTGPB.pls           |
--|     21-Nov-2002  vma                 Added back pending_ship parameter|
--|                                      for compactibility.              |
--|                                      Performance: modify code to print|
--|                                      to log only if debug profile     |
--|                                      option is enabled                |
--|     24-Nov-2002 tsimmond             UTF8: changed l_org_name  and org|
--|                                      VARCHAR2(240)                    |
--|     16-jan-2003 vjavli     Bug#2754073 fix: get_pending_tcount has    |
--|                            additional parameter x_released_work_orders|
--|                            introduced in invoked procedure INVTTGP4   |
--|     18-Jul-2003 vjavli     period close enhancement: INVTTGP4 is      |
--|                            replaced with CST_AccountingPeriod_PUB with|
--|                            all the procedure parameters               |
--|     18-Jul-2003 vjavli     p_api_version assigned l_api_version       |
--|     09-Sep-2003 vjavli     NOCOPY added according to pl/sql standard  |
--|     18-Sep-2003 vjavli     verify_periodclose: verifications added    |
--|                            as in the inventory accounting period form |
--|                            lrgos_report_rec:reason width to 255       |
--|                            p_closing_end_date assigned with schedule  |
--|                            close date                                 |
--|     28-Jan-2004 nkamaraj   Validation for the calendar and ChartOf    |
--|                            Accounts is added.fixed the incorrect      |
--|                            opening of no of periods.Please refer      |
--|                            3296392 and 3263991			  |
--|     08-APR-2004 nesoni      Bug 3555234. Error/Exceptions should be   |
--|                            logged irrespective of FND Debug Enabled.  |
--|     24-APR-2004 nesoni     Bug 3590042. Initialization of variable    |
--|                            l_verify_flag is done in Close Period      |
--|                            control block.                             |
--|     25-MAY-2004 nesoni     Bug 3638081.   org_organization_definitions|
--|                            view is replaced with its definition to    |
--|                            improve performance.                       |
--|     09-Nov-2004 nesoni     One validation is introduced during bug    |
--|                            #3904824. User should not be able to close |
--|                            a period if its scheduled close date is    |
--|                            after current date. Earlier this validation|
--|                            was applicable while submiting a request.  |
--|                            Close Period lov used to show only those   |
--|                            periods which were open and their scheduled|
--|                            close date was prior or equal to current   |
--|                            date. This validation was not allowing user|
--|                            to schedule a close period request for     |
--|                            future date. For this reason, this         |
--|                            validation is transferred at backend.      |
--|     24-Jan-2005 nesoni     Sleep time is introduced between execution |
--|                            of Close Accounting Period concurrent      |
--|                            program status checking query. Bug 3999140 |
--|     05-Jul-2005 nesoni     Code modified for bug 4457006 to remove    |
--|                            scheduling check and Period end date       |
--|                            validation.                                |
--|     09-Sep-2005 myerrams   Modified the call to close_period procedure|
--|                            as per procedure signature in              |
--|                            CST_AccountingPeriod_PUB. Bug: 4599201     |
--+=======================================================================+
G_PKG_NAME CONSTANT    VARCHAR2(30) := 'INV_MGD_PRD_CONTROL_MEDIATOR';
g_log_level            NUMBER       := NULL;

/* Variable g_log_mode is commented becasue it is no more in use.
It was done during bug:3638081 fix to resolve GSCC warning
g_log_mode             VARCHAR2(3)  := 'OFF'; -- possible values: OFF,SQL,SRS
*/
G_DEBUG                VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');

TYPE LRGOS_REPORT_REC IS RECORD
( org             VARCHAR2(240)
, period          VARCHAR2(30)
, status          VARCHAR2(30)
, reason          VARCHAR2(255)
, request_id      NUMBER
, closed          VARCHAR2(1)
, request_status  VARCHAR2(30)
, acct_period_id  NUMBER
);


TYPE LRGOS_REPORT_TABLE IS TABLE OF LRGOS_REPORT_REC
     INDEX BY BINARY_INTEGER;

G_LOG_REPORT_TABLE   LRGOS_REPORT_TABLE ;

--===================
-- PROCEDURES AND FUNCTIONS
--===================


--========================================================================
-- PROCEDURE : GET_CLOSED_STATUS


-- COMMENT   : Returns the status of the Concurrent program
--=======================================================================
FUNCTION GET_CLOSED_STATUS
( p_acct_period_id IN NUMBER
 ,p_org            IN VARCHAR2)
RETURN VARCHAR2

IS

l_open_flag   VARCHAR2(1);
l_return_flag VARCHAR2(1);

BEGIN

---  INV_ORGHIERARCHY_PVT.Log
---  (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
---   ,'> GET_CLOSED_STATUS for acct_period ' || p_acct_period_id
---   || ' Org Name:' || p_org
---  );

  BEGIN
   /* Bug: 3638081. Following query is modifed and view org_organization_definitions is replaced with view HR_ORGANIZATION_UNITS
   SELECT
      OPEN_FLAG
   INTO
      l_open_flag
   FROM
      org_acct_periods oop
     ,org_organization_definitions ood
   WHERE oop.acct_period_id  = p_acct_period_id
     AND oop.organization_id = ood.organization_id
     AND ood.organization_name = p_org;
   */

   SELECT
      OPEN_FLAG
   INTO
      l_open_flag
   FROM
      org_acct_periods oop
     ,HR_ORGANIZATION_UNITS HOU
   WHERE oop.acct_period_id  = p_acct_period_id
     AND oop.organization_id = HOU.organization_id
       AND HOU.name = p_org;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
     l_open_flag := 'Y' ;

   END ;

   IF NVL(l_open_flag,'Y') = 'N'
   THEN
     l_return_flag := 'Y' ;
   ELSE
     l_return_flag := 'N' ;
   END IF;


---  INV_ORGHIERARCHY_PVT.Log
---  (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
---   ,'< GET_CLOSED_STATUS with flag ' || l_return_flag
---  );

   RETURN l_return_flag;

EXCEPTION
 WHEN OTHERS THEN
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
                          , 'SQLERRM '|| SQLERRM);
    --END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_CLOSED_STATUS'
      );
    END IF;
    ROLLBACK;
    RAISE;
END   ;


--========================================================================
-- PROCEDURE : GET_OPEN_REQUESTS_COUNT


-- COMMENT   : Returns the number of Requests still running
--=======================================================================
FUNCTION GET_OPEN_REQUESTS_COUNT
 RETURN NUMBER
IS

l_count NUMBER := 0 ;
l_dev_phase     VARCHAR2(1);
l_request_status VARCHAR2(30);

-- Cursor to obtain the request status
CURSOR c_check_request_status(c_request_id NUMBER)
  IS
  SELECT phase_code
    FROM FND_CONCURRENT_REQUESTS
   WHERE request_id = c_request_id;

BEGIN
  -- Loop through the PL/SQL table and verify the
  --  status of the programs that are still not
  -- COMPLETE status

  ---INV_ORGHIERARCHY_PVT.Log
  ---(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  --- ,'> GET_OPEN_REQUESTS_COUNT '
  ---);

  FOR I IN 1 .. G_LOG_REPORT_TABLE.COUNT
  LOOP
    IF G_LOG_REPORT_TABLE(I).request_id is NOT NULL
    THEN
      IF NVL(G_LOG_REPORT_TABLE(I).request_status , 'X')
          <> 'COMPLETE'
      THEN
    ---    INV_ORGHIERARCHY_PVT.Log
      ---  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ---  ,' Checking request status: '||
      ---    G_LOG_REPORT_TABLE(I).request_id
      ---  );

        OPEN c_check_request_status(G_LOG_REPORT_TABLE(I).request_id);

        FETCH c_check_request_status
         INTO l_dev_phase;

        CLOSE c_check_request_status;

        -- assign request status with meaningful constants
        IF (l_dev_phase = 'R')    THEN
          l_request_status := 'RUNNING';
        ELSIF (l_dev_phase = 'P') THEN
          l_request_status := 'PENDING';
        ELSIF (l_dev_phase = 'I') THEN
          l_request_status := 'INACTIVE';
        ELSIF (l_dev_phase = 'C') THEN
          l_request_status := 'COMPLETE';
        END IF;


        -- INV_ORGHIERARCHY_PVT.Log
        --    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        --   ,' Out with status: '|| l_request_status
        --     );

        IF l_request_status = 'COMPLETE'
        THEN
           G_LOG_REPORT_TABLE(I).request_status := l_request_status;
           G_LOG_REPORT_TABLE(I).closed :=
                   GET_CLOSED_STATUS
                   ( p_acct_period_id =>
                        G_LOG_REPORT_TABLE(I).acct_period_id
                    ,p_org => G_LOG_REPORT_TABLE(I).org
                    );

        ELSE
          G_LOG_REPORT_TABLE(I).request_status := NULL;
          l_count := NVL(l_count,0) + 1;
        END IF;
      END IF;
    END IF;

    IF NVL(G_LOG_REPORT_TABLE(I).closed,'N') <> 'Y'
    THEN
      IF G_LOG_REPORT_TABLE(I).request_id IS NOT NULL
      THEN
        G_LOG_REPORT_TABLE(I).reason := 'Review Request :'||
        G_LOG_REPORT_TABLE(I).request_id ;
        G_LOG_REPORT_TABLE(I).status := 'Processing' ;
      END IF;
    ELSE
      G_LOG_REPORT_TABLE(I).reason := NULL ;
      G_LOG_REPORT_TABLE(I).status := 'Closed' ;
    END IF;
  END LOOP ;

  ---INV_ORGHIERARCHY_PVT.Log
  ---(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  ---,'< GET_OPEN_REQUESTS_COUNT with count '||  l_count
  ---);

   RETURN l_count ;

EXCEPTION
 WHEN OTHERS THEN
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
                          , 'SQLERRM '|| SQLERRM) ;
    --END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_OPEN_REQUESTS_COUNT'
      );
    END IF;
    ROLLBACK;
    RAISE;


END GET_OPEN_REQUESTS_COUNT;



--========================================================================
-- PROCEDURE : ADD_ITEM


-- COMMENT   : Includes a record into the PL/SQL report table
--=======================================================================
PROCEDURE ADD_ITEM
( p_org             IN   VARCHAR2
, p_period          IN   VARCHAR2
, p_status          IN   VARCHAR2
, p_reason          IN   VARCHAR2
, p_request_id      IN   NUMBER
, p_closed          IN   VARCHAR2
, p_acct_period_id  IN   NUMBER
)

IS

I NUMBER ;

BEGIN

  ---INV_ORGHIERARCHY_PVT.Log
  ---(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  --- ,'> ADD_ITEM for period ' || p_period
  ---);

  I := NVL(G_LOG_REPORT_TABLE.COUNT, 0 ) + 1 ;

  ---INV_ORGHIERARCHY_PVT.Log
  ---(INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  --- ,' No of records in the report table =  '|| i
  ---);


  G_LOG_REPORT_TABLE(I).org             := p_org ;
  G_LOG_REPORT_TABLE(I).period          := p_period ;
  G_LOG_REPORT_TABLE(I).status          := p_status ;
  G_LOG_REPORT_TABLE(I).reason          := p_reason ;
  G_LOG_REPORT_TABLE(I).request_id      := p_request_id ;
  G_LOG_REPORT_TABLE(I).closed          := p_closed ;
  G_LOG_REPORT_TABLE(I).acct_period_id  := p_acct_period_id ;

  I := NULL ;


  ---INV_ORGHIERARCHY_PVT.Log
  ---(INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
  --- ,'< ADD_ITEM '
  ---);

END ADD_ITEM ;


--========================================================================
-- PROCEDURE : PRINT_REPORT


-- COMMENT   : Prints the report from the PL/SQL report table
--=======================================================================
PROCEDURE PRINT_REPORT
IS

l_space VARCHAR2(10) ;

BEGIN
  /* Variable initialization is shifted from declaration section. It was done during bug:3638081 fix to resolve GSCC warning */
  l_space := '    ' ;
  IF G_DEBUG = 'Y' THEN

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'> PRINT_REPORT '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,'  '
    );
  END IF;

  /* Bug: 3555234
     Following code block is modified to change log level. Replaced
     G_LOG_STATEMENT wtih G_LOG_PRINT becasue basic report will be printed
     irrespective of FND Debug Enabled profile option.
  */
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
       ,'  '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
      ,'************** Begin Report **************************** '
    );

	/* Bug 9314796 added logic to check if G_LOG_REPORT_TABLE is empty */
	if( NVL(G_LOG_REPORT_TABLE.COUNT, 0 ) > 0 ) then

    FOR I IN G_LOG_REPORT_TABLE.FIRST .. G_LOG_REPORT_TABLE.LAST
    LOOP
      IF G_LOG_REPORT_TABLE(I).org IS NOT NULL
      THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
         ,' '
        );

        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
         ,'.................................................. '
        );

        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
         ,'ORGANIZATION :  ' ||  G_LOG_REPORT_TABLE(I).org
        );

        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
         ,'  '
        );

      ELSE
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
         , G_LOG_REPORT_TABLE(I).period || l_space ||
         G_LOG_REPORT_TABLE(I).status
         || l_space  || G_LOG_REPORT_TABLE(I).reason
        );

      END IF;
    END LOOP;

	end if;

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
        ,' '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PRINT
      ,'************** End Report **************************** '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'  '
    );

   IF G_DEBUG = 'Y' THEN

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'< PRINT_REPORT '
    );

   END IF;
END PRINT_REPORT ;


--========================================================================
-- PROCEDURE : GET_MAX_OPEN_PERIOD


-- COMMENT   : Returns the Max Open period for the Org

--=======================================================================
PROCEDURE GET_MAX_OPEN_PERIOD
( p_org_id            IN NUMBER
, p_period_set_name   IN VARCHAR2
, p_period_type       IN VARCHAR2
, x_period_start_date OUT NOCOPY DATE
, x_period_end_date   OUT NOCOPY DATE
, x_period_name       OUT NOCOPY VARCHAR2
)
IS

l_max_period_id       NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'> GET_MAX_OPEN_PERIOD '
    );
  END IF;

  -- The Maximum open period is validated and is used
  -- for calculating the starting period

  BEGIN
    SELECT
      MAX( acct_period_id )
    INTO
      l_max_period_id
    FROM
      org_acct_periods orgp
    WHERE orgp.organization_id     = p_org_id
      AND orgp.period_set_name     = p_period_set_name
      AND orgp.open_flag           = 'Y' ;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' Max Open period num ' ||  l_max_period_id
      );
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      l_max_period_id := NULL;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,' Open period not found '
        );
      END IF;
  END ;

  IF l_max_period_id IS NOT NULL
  THEN
    BEGIN
      SELECT
        glp.period_name
      , glp.start_date
      , glp.end_date
      INTO
        x_period_name
      , x_period_start_date
      , x_period_end_date
      FROM
        gl_periods glp
      , org_acct_periods orgp
      WHERE glp.period_name      = orgp.period_name
        AND glp.period_set_name  = p_period_set_name
        AND glp.period_type      = p_period_type
        AND orgp.acct_period_id  = l_max_period_id
        AND orgp.organization_id = p_org_id;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        ,' gl period  found '
        );
      END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' gl period not found '
          );
        END IF;

          x_period_name        := NULL;
          x_period_start_date  := NULL;
          x_period_end_date    := NULL;
    END ;

  ELSE

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' gl period not selcted '
      );
    END IF;
    x_period_name        := NULL;
    x_period_start_date  := NULL;
    x_period_end_date    := NULL;

  END IF;

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'< GET_MAX_OPEN_PERIOD  '
    );
  END IF;


EXCEPTION
 WHEN OTHERS THEN
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
                            , 'SQLERRM '|| SQLERRM) ;
    --END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' GET_MAX_OPEN_PERIOD'
      );
    END IF;
    ROLLBACK;
    RAISE;

END GET_MAX_OPEN_PERIOD;


--========================================================================
-- PROCEDURE : GET_MIN_OPEN_PERIOD


-- COMMENT   : Returns the Min Open period for the Org

--=======================================================================
PROCEDURE GET_MIN_OPEN_PERIOD
( p_org_id            IN NUMBER
, p_period_set_name   IN VARCHAR2
, p_period_type       IN VARCHAR2
, x_period_start_date OUT NOCOPY DATE
, x_period_end_date   OUT NOCOPY DATE
, x_period_name       OUT NOCOPY VARCHAR2
)
IS

l_min_period_id       NUMBER;

BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'> GET_MIN_OPEN_PERIOD'
    );
  END IF;

  BEGIN
    SELECT
      MIN( acct_period_id )
    INTO
      l_min_period_id
    FROM
      org_acct_periods orgp
    WHERE orgp.organization_id     = p_org_id
      AND orgp.period_set_name     = p_period_set_name ;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' Min Open period num ' ||  l_min_period_id
      );
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_min_period_id := NULL;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,' Open period not found '
        );
      END IF;
  END ;

  IF l_min_period_id IS NOT NULL
  THEN
    BEGIN
      SELECT
        glp.period_name
      , glp.start_date
      , glp.end_date
      INTO
        x_period_name
      , x_period_start_date
      , x_period_end_date
      FROM
        gl_periods glp
      , org_acct_periods orgp
      WHERE glp.period_name      = orgp.period_name
        AND glp.period_set_name  = p_period_set_name
        AND glp.period_type      = p_period_type
        AND orgp.acct_period_id  = l_min_period_id
        AND orgp.organization_id = p_org_id;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        ,' gl period  found '
        );
      END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' gl period not found '
          );
        END IF;
          x_period_name        := NULL;
          x_period_start_date  := NULL;
          x_period_end_date    := NULL;
    END ;

  ELSE
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' gl period not selcted '
      );
    END IF;
    x_period_name        := NULL;
    x_period_start_date  := NULL;
    x_period_end_date    := NULL;

  END IF;


  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'< GET_MIN_OPEN_PERIOD '
    );
  END IF;

EXCEPTION
 WHEN OTHERS THEN
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
                          , 'SQLERRM '|| SQLERRM) ;
    --END IF;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , 'GET_MIN_OPEN_PERIOD'
      );
    END IF;
    ROLLBACK;
    RAISE;

END GET_MIN_OPEN_PERIOD ;



--========================================================================
-- PROCEDURE : Period_Control


-- COMMENT   : This is the Wrapper program mediator that invokes the
--             Inventory API for Open and Close periods

--=======================================================================
PROCEDURE Period_Control
        (        x_retcode               OUT  NOCOPY VARCHAR2
        ,        x_errbuff               OUT  NOCOPY VARCHAR2
        ,        p_org_hierarchy_origin	 IN    NUMBER
   	,        p_org_hierarchy_id	 IN    NUMBER
        ,        p_close_period_name     IN    VARCHAR2
	,	 p_close_if_res_recmd    IN    VARCHAR2
        ,        p_open_period_count     IN    NUMBER
        ,        p_open_or_close_flag    IN    VARCHAR2
        ,        p_requests_count        IN    NUMBER
        )
IS

l_org_code_list INV_ORGHIERARCHY_PVT.OrgID_tbl_type;

l_orgid		          hr_organization_units.organization_id%TYPE;
l_org_name                  VARCHAR2(240) := NULL;


l_index                 BINARY_INTEGER;

l_login_id                  NUMBER;
l_user_id                   NUMBER;

l_requests_count            NUMBER;

l_period_set_name           VARCHAR2(30);
l_sob_period_type           VARCHAR2(30);

l_final_period_name         VARCHAR2(30);
l_period_final_start_date   DATE;
l_period_final_end_date     DATE;
l_cursor_final_end_date     DATE;

l_wip_failed                BOOLEAN;
l_close_failed              BOOLEAN;
l_download_failed           BOOLEAN;
l_unprocessed_txns	    BOOLEAN; --myerrams, Bug:4599201
l_rec_rpt_launch_failed	    BOOLEAN; --myerrams, Bug:4599201
l_req_id                    NUMBER;
l_list_count                NUMBER:= 0;
l_last_scheduled_close_date DATE;
l_org_from_date             DATE;

l_prior_period_open         BOOLEAN;
l_new_acct_period_id        NUMBER;
l_duplicate_open_period	    BOOLEAN;
l_commit_complete           BOOLEAN;
l_return_status             VARCHAR2(1);
l_api_version               NUMBER := 1.0;

l_open_period_exists        BOOLEAN;
l_proper_order              BOOLEAN;
l_end_date_is_past          BOOLEAN;
l_download_in_process       BOOLEAN;
l_prompt_to_reclose         BOOLEAN;

l_date_from                 DATE;
l_count                     NUMBER:= 0 ;

l_min_start_date            DATE;
l_min_end_date              DATE;
l_min_period                VARCHAR2(30);

l_pend_receiving            INTEGER;
l_unproc_matl               INTEGER;
l_pend_matl                 INTEGER;
l_uncost_matl               INTEGER;
l_pend_move                 INTEGER;
l_pend_WIP_cost             INTEGER;
l_uncost_wsm                INTEGER;
l_pending_wsm               INTEGER;
l_pending_ship              INTEGER;
l_pending_lcm               INTEGER;

-- Bug#2754073 fix to include variable for the parameter
-- x_released_work_orders
l_released_work_orders      INTEGER;

-- Following code line which was introduced during bug 3904824
-- has been commented during fix 4457006 because 11.5.10 CU2 onwards, scheduling can be
-- done for any date and user can close Period on any date they wish.So no new
-- exception is needed.
-- A new varaible l_legal_entity is defined to collect legal entity id.
-- New variable l_le_sysdate represents sysdate in legal entity timezone.
-- New variable l_period_end_date represents period end date in server timezone.
-- New variable l_reamining_hours represents remaining hours for period close date.


--Bug #3904824
--l_close_period_before_sch_dt  EXCEPTION;

l_legal_entity               NUMBER;
l_period_end_date            DATE;
l_le_sysdate                 DATE;
l_hours_remaining            NUMBER;

/* A new variable to define sleep time is introduced. Bug: 3999140 */
l_sleep_time          NUMBER       := 15;

-- Bug #3263991 and 3296392
l_hierarchy_validation      EXCEPTION;
l_property_flag             VARCHAR2(1);
l_hierarchy_name     VARCHAR2(30);
l_property           VARCHAR2(100);

-- Bug # 5078841 to generate warning if periods of closed when pending transactions' resolution is recommended
l_closed_if_res_recmd       NUMBER  := 0;

l_allow_close         varchar2(240);

l_max_open_period_name		ORG_ACCT_PERIODS.PERIOD_NAME%TYPE;
l_max_open_period_start_date    DATE;
l_max_open_period_end_date	DATE;
l_max_period_start_date		DATE;


CURSOR c_org_name(c_org_id NUMBER) IS
  SELECT
    name
  , date_from
  FROM
    HR_organization_units
  WHERE ORGANIZATION_ID = c_org_id;

-- Select the periods from GL_PERIODS
-- that are eligible to be
-- opened for a given Org

CURSOR c_gl_period_future(c_org_id NUMBER) IS
      SELECT
         glp.PERIOD_SET_NAME open_period_set_name
      ,  glp.PERIOD_NAME     open_period_name
      ,  glp.START_DATE      period_start_date
      ,  glp.END_DATE        period_end_date
      ,  glp.PERIOD_TYPE     acct_period_type
      ,  glp.PERIOD_YEAR     open_period_year
      ,  glp.PERIOD_NUM      open_period_num
      FROM
        GL_PERIODS glp
      WHERE glp.ADJUSTMENT_PERIOD_FLAG        = 'N'
        AND glp.period_type                   = l_sob_period_type
        AND glp.PERIOD_SET_NAME               = l_period_set_name
        AND glp.PERIOD_NAME NOT IN
              (  SELECT OAP.PERIOD_NAME
                  FROM  ORG_ACCT_PERIODS OAP
                  WHERE OAP.PERIOD_SET_NAME   = glp.PERIOD_SET_NAME
                  AND   OAP.PERIOD_NAME       = glp.PERIOD_NAME
                  AND   OAP.organization_id   = c_org_id
              )
        AND glp.end_date <= NVL( l_cursor_final_end_date + 1, glp.end_date )
        AND glp.end_date >= l_org_from_date
        ORDER BY glp.start_date ;

       l_gl_period_future   c_gl_period_future%ROWTYPE ;


   -- Select the periods from GL_PERIODS
   -- that are eligible to be
   -- Closed for a given Org

   CURSOR c_org_acct_periods_open IS
        SELECT
          orgp.rowid                  closing_rowid
        , orgp.ACCT_PERIOD_ID         closing_acct_period_id
        , orgp.ORGANIZATION_ID        organization_id
        , orgp.period_start_date      period_start_date
        , orgp.PERIOD_CLOSE_DATE      period_close_date
        , orgp.SCHEDULE_CLOSE_DATE    schedule_close_date
        , orgp.PERIOD_YEAR            open_period_year
        , orgp.PERIOD_NUM             open_period_num
        , orgp.PERIOD_NAME            open_period_name
        , orgp.open_flag              open_flag
        FROM
          org_acct_periods orgp
        WHERE orgp.period_name         = p_close_period_name
          AND orgp.organization_id     = l_orgid
          AND orgp.period_set_name     = l_period_set_name ;


 l_org_acct_periods_val_open     c_org_acct_periods_open%ROWTYPE ;

-- log error message
l_error_msg   VARCHAR2(255);
--Initialization of variable l_verify_flag is removed. Bug: 3590042
-- Verify flag for verify_periodclose
l_verify_flag VARCHAR2(1);

l_start_time  date;
l_end_time    date;
l_wip_installation VARCHAR2(10);
l_wip_indust       VARCHAR2(10);
BEGIN

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
     ,'> INV_MGD_PRD_CONTROL_MEDIATOR.Period_Control '
    );
  END IF;
-- Following validation block which was introduced during bug 3904824
-- has been commented during fix 4457006 because 11.5.10 CU2 onwards, scheduling can be
-- done for any date and user can close Period on any date they wish.

-- Following validation block is introduced during bug 3904824.
--  User should not be able to close a period if its scheduled close date is after current date.
-- Earlier this validation was applicable while submiting a request. Close Period lov used to
-- show only those period which are open and their scheduled close date is prior or equal to
-- current date. This validation was not allowing user to schedule a close period request for future date.
-- For this reason, this validation is transferred at backend.
-- IF p_open_or_close_flag = 'C' THEN
-- SELECT count(*)
-- INTO l_count
-- FROM ORG_ACCT_PERIODS
-- WHERE SCHEDULE_CLOSE_DATE > SYSDATE
-- AND PERIOD_NAME = p_close_period_name
-- AND ORGANIZATION_ID = p_org_hierarchy_origin;

-- IF l_count > 0 THEN
--  FND_MESSAGE.SET_NAME('INV', 'INV_SCHE_CLOSE_DATE_NOT_PASSED');
--  x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1,255);

--  RAISE l_close_period_before_sch_dt;
-- END IF;
-- END IF;


  -- The Open and Close poeriod solution is acheived by using
  -- the underlying Inventory API's.

  -- A report PL/SQL table is maintained for the sttaus to be
  -- printed for each period for each Org.
  -- The same table is also used to manipulate the
  -- number of requests running during the Close period program

  -- The API's return status details the process outcome , which is
  -- inserted into the PL/SQL table and later printed as Log report

  -- The periods for Closing are selected from the ORG_ACCT_PERIODS
  -- and the periods to Open are retreived from GL_PERIODS

  G_LOG_REPORT_TABLE.DELETE ;

  l_requests_count := p_requests_count ;

  x_retcode :=  RETCODE_SUCCESS;

  INV_ORGHIERARCHY_PVT.get_organization_List (
       p_hierarchy_id    => p_org_hierarchy_id
  ,    p_origin_org_id   => p_org_hierarchy_origin
  ,    x_org_id_tbl      => l_org_code_list
  ,    p_include_origin  => 'Y'
  );

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' Out of Org List capture with count '|| l_org_code_list.COUNT
    );
  END IF;

   -- Bug : 3296392 - Validate for the same Calendar of all orgs in hierarchy

    l_property_flag := INV_ORGHIERARCHY_PVT.
                         validate_property(l_org_code_list, 'CALENDAR');

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_EVENT
      ,'Property Flag:' || l_property_flag );
    END IF;

    IF l_property_flag = 'N' THEN
      -- get hierarchy name
      SELECT name
        INTO l_hierarchy_name
        FROM per_organization_structures
          WHERE organization_structure_id = p_org_hierarchy_id;

      -- get the hierarchy property text
      SELECT meaning
        INTO l_property
        FROM mfg_lookups
          WHERE lookup_type = 'INV_MGD_HIER_PROPERTY_TYPE'
            AND lookup_code = 2;

      -- raise hiearchy validation failure
      -- Set the message, tokens
      FND_MESSAGE.set_name('INV', 'INV_MGD_HIER_INVALID_PROPERTY');
      FND_MESSAGE.set_token('HIERARCHY', l_hierarchy_name);
      FND_MESSAGE.set_token('PROPERTY', l_property);
      x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1, 255);

      RAISE l_hierarchy_validation;

    END IF;
   -- Bug : 3296392 - Validate for the same ChartOfAccounts of all orgs in hierarchy

    l_property_flag := INV_ORGHIERARCHY_PVT.
                        validate_property(l_org_code_list, 'CHART_OF_ACCOUNTS');

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      ( INV_ORGHIERARCHY_PVT.G_LOG_EVENT
      ,'Property Flag:' || l_property_flag );
    END IF;

    IF l_property_flag = 'N' THEN
      -- get hierarchy name
      SELECT name
        INTO l_hierarchy_name
        FROM per_organization_structures
          WHERE organization_structure_id = p_org_hierarchy_id;

      -- get the hierarchy property text
      SELECT meaning
        INTO l_property
        FROM mfg_lookups
          WHERE lookup_type = 'INV_MGD_HIER_PROPERTY_TYPE'
            AND lookup_code = 3;

      -- raise hiearchy validation failure
      -- Set the message, tokens
      FND_MESSAGE.set_name('INV', 'INV_MGD_HIER_INVALID_PROPERTY');
      FND_MESSAGE.set_token('HIERARCHY', l_hierarchy_name);
      FND_MESSAGE.set_token('PROPERTY', l_property);
      x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1, 255);

      RAISE l_hierarchy_validation;

  END IF;




  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'  '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'*********************** Start of Report ***********************  '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'  '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' ------------------- Running for Parameters ---------------  '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' p_org_hierarchy_origin	 '
     || p_org_hierarchy_origin
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' p_org_hierarchy_id	 '
     || p_org_hierarchy_id
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' p_close_period_name     '
     || p_close_period_name
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' p_open_period_count     '
     || p_open_period_count
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' p_open_or_close_flag    '
     || p_open_or_close_flag
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' p_requests_count '
     || p_requests_count
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'         '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' --------------- End Parameters ----------------------------------------- '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,'         '
    );

    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
     ,' ............................................................  '
    );
  END IF;

  l_count    := 1 ;
  l_login_id := NVL(TO_NUMBER(FND_PROFILE.Value('LOGIN_ID')),1) ;
  l_user_id  := NVL(TO_NUMBER(FND_PROFILE.Value('USER_ID')),1) ;

  BEGIN
   /* Bug: 3638081. Following query is modifed and view org_organization_definitions is replaced with its definition.
    SELECT
      glstb.period_set_name
    , glstb.ACCOUNTED_PERIOD_TYPE
    , orgu.date_from
    INTO
      l_period_set_name
    , l_sob_period_type
    , l_org_from_date
    FROM
      gl_sets_of_books             glstb
    , org_organization_definitions orgdef
    , hr_organization_units orgu
    WHERE orgdef.organization_id   = p_org_hierarchy_origin
      AND glstb.set_of_books_id    = orgdef.set_of_books_id
      AND orgu.organization_id     = orgdef.organization_id
      AND orgu.business_group_id   = orgdef.business_group_id ;
    */
    SELECT
      glstb.period_set_name
      , glstb.ACCOUNTED_PERIOD_TYPE
      , HOU.date_from from_date
    INTO
      l_period_set_name
    , l_sob_period_type
    , l_org_from_date
    FROM
      MTL_PARAMETERS MP
    , hr_organization_units HOU
    , HR_ORGANIZATION_INFORMATION HOI
    , gl_sets_of_books glstb
    WHERE  HOU.ORGANIZATION_ID = p_org_hierarchy_origin
      AND HOU.ORGANIZATION_ID = MP.ORGANIZATION_ID
      AND HOU.ORGANIZATION_ID = HOI.ORGANIZATION_ID
      AND UPPER( HOI.ORG_INFORMATION_CONTEXT || '') = 'ACCOUNTING INFORMATION'
      AND TO_NUMBER(HOI.ORG_INFORMATION1) = glstb.SET_OF_BOOKS_ID ;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' FOUND: Period Set name  '
       || l_period_set_name );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' FOUND: Period Type '
       || l_sob_period_type );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' Calling GET_MAX_OPEN_PERIOD ' );
    END IF;

    GET_MAX_OPEN_PERIOD
    ( p_org_id            => p_org_hierarchy_origin
    , p_period_set_name   => l_period_set_name
    , p_period_type       => l_sob_period_type
    , x_period_start_date => l_period_final_start_date
    , x_period_end_date   => l_period_final_end_date
    , x_period_name       => l_final_period_name
    );

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' Out of GET_MAX_OPEN_PERIOD with period name '|| l_final_period_name );
    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,' NO_DATA_FOUND: Period Set name not found for Hierarchy Origin '
         ||  p_org_hierarchy_origin
         );
      END IF;
      RAISE ;

  END ;

  -- for the open flag process the hierarchy origin first
  IF p_open_or_close_flag = 'O' THEN

      OPEN c_org_name(p_org_hierarchy_origin);
      FETCH c_org_name
      INTO
        l_org_name
      , l_date_from ;

      CLOSE c_org_name;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
           ,' Hierarchy Origin name = '||
            l_org_name
          );

        INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' Calling GET_MIN_OPEN_PERIOD ' );
      END IF;

      GET_MIN_OPEN_PERIOD
          ( p_org_id            => p_org_hierarchy_origin
          , p_period_set_name   => l_period_set_name
          , p_period_type       => l_sob_period_type
          , x_period_start_date => l_min_start_date
          , x_period_end_date   => l_min_end_date
          , x_period_name       => l_min_period
          );

      IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' Out of GET_MIN_OPEN_PERIOD with period name '|| l_min_period );
      END IF;

      -- If there are no minimum periods opened for this Org
      -- the starting period will be determined by the
      -- Org from date. If not , the next period of the
      -- Minimum opened period is the starting point.

      IF l_min_end_date IS NOT NULL
      THEN
        l_org_from_date := l_min_end_date + 1 ;
      ELSE
        -- Bug :3263991 for fixing the incorrect periods opening.
        -- l_org_from_date := l_date_from - 1 ;
        l_org_from_date := l_date_from  ;
      END IF;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        ,'  l_org_from_date '|| l_org_from_date
        );
      END IF;

      IF l_count > NVL(p_open_period_count,0) THEN

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' No Processing for Hierarchy Origin  as Input count 0 '
          );
        END IF;
      ELSE
        -- open the periods for the hierarchy origin
        FOR l_gl_period_future IN c_gl_period_future(p_org_hierarchy_origin)
        LOOP
          -- The Inventory Open period Api is called
          --  for each of the period

          l_final_period_name       := l_gl_period_future.open_period_name ;
          l_period_final_start_date := l_gl_period_future.period_start_date ;
          l_period_final_end_date   := l_gl_period_future.period_end_date ;

          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
             ,'Period Final End Date: ' || to_char(l_period_final_end_date)
            );

            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
            ,'********* Start Processing for Hierarchy Origin ********* '
            );

            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
            ,'Period Count: ' || l_count
            );
           /* Following code line has been commented. It is shifted
           out of debug condition block.Bug 3555234.
           ADD_ITEM
           ( p_org             => l_org_name
           , p_period          => NULL
           , p_status          => NULL
           , p_reason          => NULL
           , p_request_id      => NULL
           , p_closed          => NULL
           , p_acct_period_id  => NULL
           );
           */

            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
            ,' ======== Attempt to Open Period : ' || l_gl_period_future.open_period_name
            || ' ============================ ' );
          END IF;

          /* Bug 3555234. Following code line shifted out of above block.*/
          ADD_ITEM
          ( p_org             => l_org_name
           , p_period          => NULL
           , p_status          => NULL
           , p_reason          => NULL
           , p_request_id      => NULL
           , p_closed          => NULL
           , p_acct_period_id  => NULL
          );

          l_start_time := sysdate;
          CST_AccountingPeriod_PUB.open_period
            (  p_api_version                => l_api_version
            ,  p_org_id                     => p_org_hierarchy_origin
            ,  p_user_id                    => l_user_id
            ,  p_login_id                   => l_login_id
            ,  p_acct_period_type           => l_gl_period_future.acct_period_type
            ,  p_org_period_set_name        => l_period_set_name
            ,  p_open_period_name	    => l_gl_period_future.open_period_name
            ,  p_open_period_year	    => l_gl_period_future.open_period_year
            ,  p_open_period_num            => l_gl_period_future.open_period_num
            ,  x_last_scheduled_close_date  => l_last_scheduled_close_date
            ,  p_period_end_date           => l_gl_period_future.period_end_date
            ,  x_prior_period_open          => l_prior_period_open
            ,  x_new_acct_period_id         => l_new_acct_period_id
            ,  x_duplicate_open_period	    => l_duplicate_open_period
            ,  x_commit_complete            => l_commit_complete
            ,  x_return_status              => l_return_status
            ) ;

          l_end_time := sysdate;

          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
             ,' l_last_scheduled_close_date ' || l_last_scheduled_close_date
            );

            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
             ,' l_new_acct_period_id ' || l_new_acct_period_id
            );
          END IF;

          IF (l_duplicate_open_period) = true
          THEN
            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        	      ,  ' duplicate_open_period Error for '
                || l_orgid
              );
            END IF;

            ADD_ITEM
             ( p_org        => NULL
             , p_period     => l_gl_period_future.open_period_name
             , p_status     => 'IGNORE'
             , p_reason     => 'Duplicate Open Periods'
             , p_request_id => NULL
             , p_closed     => NULL
             , p_acct_period_id  => NULL
             );

          END IF;

            IF l_prior_period_open = true
            THEN
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	            ,  '  '
                );
              END IF;
            ELSE
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	            ,  ' EXCEPTION: l_prior_period_open  FALSE '
                );
              END IF;
              ADD_ITEM
                ( p_org        => NULL
                , p_period     => l_gl_period_future.open_period_name
                , p_status     => 'IGNORE'
                , p_reason     => 'Prior period not Open'
                , p_request_id => NULL
                , p_closed     => NULL
                , p_acct_period_id  => NULL
                );
            END IF;

            IF (l_commit_complete) = true
            THEN
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                 ,' Open SUCCESS for '
                 || l_orgid || ' - '|| l_org_name
                );
              END IF;
              ADD_ITEM
                ( p_org        => NULL
                , p_period     => l_gl_period_future.open_period_name
                , p_status     => 'OPEN'
                , p_reason     => NULL
                , p_request_id => NULL
                , p_acct_period_id  => NULL
                , p_closed     => NULL
                );

              COMMIT;

	      IF (fnd_installation.get(appl_id => 706, dep_appl_id => 706,
				      status => l_wip_installation,
				      industry => l_wip_indust)) THEN

	      /* make insert into wpb using starting time and end time */
	      /* for discrete */
 	      INSERT INTO WIP_PERIOD_BALANCES
                (ACCT_PERIOD_ID, WIP_ENTITY_ID,
		 REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
		 LAST_UPDATED_BY, CREATION_DATE,
		 CREATED_BY, LAST_UPDATE_LOGIN,
		 ORGANIZATION_ID, CLASS_TYPE,
		 TL_RESOURCE_IN, TL_OVERHEAD_IN,
		 TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
		 PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
		 PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
		 TL_MATERIAL_OUT, TL_MATERIAL_OVERHEAD_OUT, TL_RESOURCE_OUT,
		 TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
		 PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
		 PL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_VAR, PL_MATERIAL_OVERHEAD_VAR,
		 PL_RESOURCE_VAR, PL_OUTSIDE_PROCESSING_VAR,
		 PL_OVERHEAD_VAR, TL_MATERIAL_VAR, TL_MATERIAL_OVERHEAD_VAR,
		 TL_RESOURCE_VAR, TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR)
		SELECT
		l_new_acct_period_id,
		WDJ.WIP_ENTITY_ID,
		NULL, SYSDATE,
		l_user_id, SYSDATE,
		l_user_id, l_login_id,
		p_org_hierarchy_origin, WAC.CLASS_TYPE,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM WIP_DISCRETE_JOBS WDJ,
	        WIP_ACCOUNTING_CLASSES WAC
                WHERE WDJ.STATUS_TYPE IN (3, 4, 5, 6, 7, 14, 15)
	        AND WDJ.DATE_RELEASED is not NULL
		AND WDJ.ORGANIZATION_ID = p_org_hierarchy_origin
		AND WAC.CLASS_CODE = WDJ.CLASS_CODE
	        AND WAC.ORGANIZATION_ID = p_org_hierarchy_origin
	        AND ((WDJ.CREATION_DATE between l_start_time and l_end_time)
		  or (WDJ.DATE_RELEASED between l_start_time and l_end_time))
	        AND   not exists
		(select 'X' from wip_period_balances wpb
		 where l_new_acct_period_id = wpb.acct_period_id
		 and   wpb.organization_id = p_org_hierarchy_origin
		 and   wdj.wip_entity_id = wpb.wip_entity_id);

	      /* for repetitive schedules */
	      INSERT INTO WIP_PERIOD_BALANCES
                (ACCT_PERIOD_ID, WIP_ENTITY_ID,
		 REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
		 LAST_UPDATED_BY, CREATION_DATE,
		 CREATED_BY, LAST_UPDATE_LOGIN,
		 ORGANIZATION_ID, CLASS_TYPE,
		 TL_RESOURCE_IN, TL_OVERHEAD_IN,
		 TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
		 PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
		 PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
		 TL_MATERIAL_OUT, TL_MATERIAL_OVERHEAD_OUT, TL_RESOURCE_OUT,
		 TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
		 PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
		 PL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_VAR, PL_MATERIAL_OVERHEAD_VAR,
		 PL_RESOURCE_VAR, PL_OUTSIDE_PROCESSING_VAR,
		 PL_OVERHEAD_VAR, TL_MATERIAL_VAR, TL_MATERIAL_OVERHEAD_VAR,
		 TL_RESOURCE_VAR, TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR)
		SELECT
		l_new_acct_period_id,
		WRS.WIP_ENTITY_ID,
		WRS.REPETITIVE_SCHEDULE_ID, SYSDATE,
		l_user_id, SYSDATE,
		l_user_id, l_login_id,
		p_org_hierarchy_origin, 2,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	        FROM WIP_REPETITIVE_SCHEDULES WRS
                WHERE WRS.STATUS_TYPE IN (3, 4, 6)
	        AND WRS.ORGANIZATION_ID = p_org_hierarchy_origin
	        AND ((WRS.CREATION_DATE between l_start_time and l_end_time)
		  or (WRS.DATE_RELEASED between l_start_time and l_end_time))
	        AND   not exists
		(select 'X' from wip_period_balances wpb
		 where l_new_acct_period_id = wpb.acct_period_id
		 and   wpb.organization_id = p_org_hierarchy_origin
		 and   wrs.wip_entity_id = wpb.wip_entity_id
		 and   wrs.repetitive_schedule_id = wpb.repetitive_schedule_id);

	      COMMIT;
 	      END IF; --wip installed
            ELSE
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                ,' Open FAILED for '
                || l_orgid || ' - '|| l_org_name
                );
              END IF;

              ADD_ITEM
                ( p_org        => NULL
                , p_period     => l_gl_period_future.open_period_name
                , p_status     => 'FAILED'
                , p_reason     => 'Open process Failed'
                , p_request_id => NULL
                , p_closed     => NULL
                , p_acct_period_id  => NULL
                );
              ROLLBACK ;
            END IF;

            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
              ,' Hierarchy Origin End of Period Name ' || l_gl_period_future.open_period_name
              || ' ============================ ' );
            END IF;

            IF l_count >= p_open_period_count
            THEN
               EXIT ;
            ELSE
              l_count := l_count + 1 ;
            END IF;


        END LOOP;
        -- end loop for hierarchy origin
     END IF; -- input count 0 check

      SELECT max(start_date)
   INTO l_max_period_start_date
    FROM GL_PERIODS
    WHERE ADJUSTMENT_PERIOD_FLAG   = 'N'
    AND period_type   = l_sob_period_type
    AND PERIOD_SET_NAME   = l_period_set_name;

    GET_MAX_OPEN_PERIOD
    ( p_org_id            => p_org_hierarchy_origin
    , p_period_set_name   => l_period_set_name
    , p_period_type       => l_sob_period_type
    , x_period_start_date => l_max_open_period_start_date
    , x_period_end_date   => l_max_open_period_end_date
    , x_period_name       => l_max_open_period_name
    );

    IF l_max_period_start_date = l_max_open_period_start_date THEN
     FND_MESSAGE.set_name('INV', 'INV_MGD_DEFINE_PERIODS');
     FND_MESSAGE.set_token('PERIOD_NAME', l_max_open_period_name);
     FND_MESSAGE.set_token('CALENDAR', l_period_set_name);
     ADD_ITEM ( p_org        =>  NULL
                , p_period     => l_period_set_name
                , p_status     => NULL
                , p_reason     => FND_MESSAGE.GET
                , p_request_id => NULL
                , p_closed     => NULL
                , p_acct_period_id  => NULL
              );
    END IF;

  END IF; -- open period flag

  -- re-initialize l_count
  l_count := 1;

  -- The Organization list belonging to this Hierarchy Origin
  -- is retreived. organization list includes the hierarchy origin

  IF G_DEBUG = 'Y' THEN
    INV_ORGHIERARCHY_PVT.Log
    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' Calling INV_ORGHIERARCHY_PVT.get_organization_List '
    );
  END IF;


  IF NVL(l_org_code_list.COUNT,0) > 0
  THEN
    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' count > 0 '
      );
    END IF;

    l_list_count := l_org_code_list.COUNT ;

    l_index := l_org_code_list.FIRST;
    l_orgid := l_org_code_list(l_index);

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' Initial l_index ' || l_index
      );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' Initial l_orgid ' || l_orgid
      );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' About to Enter WHILE Loop for the Org List '
      );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,'         '
      );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' ............................................................  '
      );
    END IF;

    WHILE ( l_list_count > 0 )
    LOOP
      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,' Into while loop with l_index ' || l_index
        );
      END IF;

      l_orgid := l_org_code_list(l_index);

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
         ,' Organization Id:  ' || l_orgid
        );
      END IF;

        -- Get Organization Name and Date from
        OPEN c_org_name(l_orgid);
        FETCH c_org_name
        INTO
         l_org_name
       , l_date_from ;

        CLOSE c_org_name;

      -- process only for the child organizations
      -- exclude hierarchy origin for the open flag
      IF p_open_or_close_flag = 'O' AND l_orgid <> p_org_hierarchy_origin
         THEN

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
           ,' while loop l_orgid ' || l_orgid
          );
        END IF;


        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
           ,' ************** START Processing Organization = '||
          l_org_name || ' ************************** '
          );
        END IF;

       ADD_ITEM
       ( p_org             => l_org_name
       , p_period          => NULL
       , p_status          => NULL
       , p_reason          => NULL
       , p_request_id      => NULL
       , p_closed          => NULL
       , p_acct_period_id  => NULL
       );


        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
           ,'## Organization Date From '|| l_date_from
          );
        END IF;

        -- Final period end date is the final period
        -- of the Hierarchy Origin being opened

        l_cursor_final_end_date := l_period_final_end_date ;

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,'  l_cursor_final_end_date '|| l_cursor_final_end_date
          );

          -- The Minimum and Maximum periods for this Org
          --  is selected. This required to determine the
          -- range of periods that are eligible to be Opened

          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' Calling GET_MIN_OPEN_PERIOD ' );
        END IF;

          GET_MIN_OPEN_PERIOD
          ( p_org_id            => l_orgid
          , p_period_set_name   => l_period_set_name
          , p_period_type       => l_sob_period_type
          , x_period_start_date => l_min_start_date
          , x_period_end_date   => l_min_end_date
          , x_period_name       => l_min_period
          );

        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' Out of GET_MIN_OPEN_PERIOD with period name '|| l_min_period );
        END IF;

          -- If there are no minimum periods opened for this Org
          -- the starting period will be determined by the
          -- Org from date. If not , the next period of the
          -- Minimum opened period is the starting point.

          IF l_min_end_date IS NOT NULL
          THEN
            l_org_from_date := l_min_end_date + 1 ;
          ELSE
          --NKILLEDA : Modified for Bug 3263991 for fixing the
          --           incorrect periods opening.
          --l_org_from_date := l_date_from - 1 ;
            l_org_from_date := l_date_from;
          END IF;

          IF G_DEBUG = 'Y' THEN
            INV_ORGHIERARCHY_PVT.Log
            (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
            ,'  l_org_from_date '|| l_org_from_date
            );
          END IF;

          FOR l_gl_period_future IN c_gl_period_future(l_orgid)
          LOOP
            -- The Inventory Open period Api is called
            --  for each of the period


            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,' ======== Attempt to Open Period : ' || l_gl_period_future.open_period_name
              || ' ============================ ' );
            END IF;

            l_start_time := sysdate;
            CST_AccountingPeriod_PUB.open_period
            (  p_api_version                => l_api_version
            ,  p_org_id                     => l_orgid
            ,  p_user_id                    => l_user_id
            ,  p_login_id                   => l_login_id
            ,  p_acct_period_type           => l_gl_period_future.acct_period_type
            ,  p_org_period_set_name        => l_period_set_name
            ,  p_open_period_name	    => l_gl_period_future.open_period_name
            ,  p_open_period_year	    => l_gl_period_future.open_period_year
            ,  p_open_period_num            => l_gl_period_future.open_period_num
            ,  x_last_scheduled_close_date  => l_last_scheduled_close_date
            ,  p_period_end_date           => l_gl_period_future.period_end_date
            ,  x_prior_period_open          => l_prior_period_open
            ,  x_new_acct_period_id         => l_new_acct_period_id
            ,  x_duplicate_open_period	    => l_duplicate_open_period
            ,  x_commit_complete            => l_commit_complete
            ,  x_return_status              => l_return_status
            ) ;
            l_end_time := sysdate;

            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
               ,' l_last_scheduled_close_date ' || l_last_scheduled_close_date
              );

              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
	           ,' l_new_acct_period_id ' || l_new_acct_period_id
              );
            END IF;

            IF (l_duplicate_open_period) = true
            THEN
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	            ,  ' duplicate_open_period Error for '
                || l_orgid
                );
              END IF;

              ADD_ITEM
             ( p_org        => NULL
             , p_period     => l_gl_period_future.open_period_name
             , p_status     => 'IGNORE'
             , p_reason     => 'Duplicate Open Periods'
             , p_request_id => NULL
             , p_closed     => NULL
             , p_acct_period_id  => NULL
             );

            END IF;

            IF (l_prior_period_open) = true
            THEN
              IF G_DEBUG = 'Y' THEN
               INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
    	          ,  '  '
                );
              END IF;
            ELSE
              IF G_DEBUG = 'Y' THEN
               INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	            ,  ' EXCEPTION: l_prior_period_open  FALSE '
                );
              END IF;

              ADD_ITEM
             ( p_org        => NULL
             , p_period     => l_gl_period_future.open_period_name
             , p_status     => 'IGNORE'
             , p_reason     => 'Prior period not Open'
             , p_request_id => NULL
             , p_closed     => NULL
             , p_acct_period_id  => NULL
             );

            END IF;

            IF (l_commit_complete) = true
            THEN
              IF G_DEBUG = 'Y' THEN
               INV_ORGHIERARCHY_PVT.Log
	              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
  	            ,' Open SUCCESS for '
                || l_orgid || ' - '|| l_org_name
                );
              END IF;

              ADD_ITEM
             ( p_org        => NULL
             , p_period     => l_gl_period_future.open_period_name
             , p_status     => 'OPEN'
             , p_reason     => NULL
             , p_request_id => NULL
             , p_acct_period_id  => NULL
             , p_closed     => NULL
             );

              COMMIT;

	      IF (fnd_installation.get(appl_id => 706, dep_appl_id => 706,
				      status => l_wip_installation,
				      industry => l_wip_indust)) THEN

	      /* make insert into wpb using starting time and end time */
	      /* for discrete */
	      INSERT INTO WIP_PERIOD_BALANCES
                (ACCT_PERIOD_ID, WIP_ENTITY_ID,
		 REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
		 LAST_UPDATED_BY, CREATION_DATE,
		 CREATED_BY, LAST_UPDATE_LOGIN,
		 ORGANIZATION_ID, CLASS_TYPE,
		 TL_RESOURCE_IN, TL_OVERHEAD_IN,
		 TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
		 PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
		 PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
		 TL_MATERIAL_OUT, TL_MATERIAL_OVERHEAD_OUT, TL_RESOURCE_OUT,
		 TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
		 PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
		 PL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_VAR, PL_MATERIAL_OVERHEAD_VAR,
		 PL_RESOURCE_VAR, PL_OUTSIDE_PROCESSING_VAR,
		 PL_OVERHEAD_VAR, TL_MATERIAL_VAR, TL_MATERIAL_OVERHEAD_VAR,
		 TL_RESOURCE_VAR, TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR)
		SELECT
		l_new_acct_period_id,
		WDJ.WIP_ENTITY_ID,
		NULL, SYSDATE,
		l_user_id, SYSDATE,
		l_user_id, l_login_id,
		l_orgid, WAC.CLASS_TYPE,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		FROM WIP_DISCRETE_JOBS WDJ,
	        WIP_ACCOUNTING_CLASSES WAC
                WHERE WDJ.STATUS_TYPE IN (3, 4, 5, 6, 7, 14, 15)
	        AND WDJ.DATE_RELEASED is not NULL
		AND WDJ.ORGANIZATION_ID = l_orgid
		AND WAC.CLASS_CODE = WDJ.CLASS_CODE
	        AND WAC.ORGANIZATION_ID = l_orgid
	        AND ((WDJ.CREATION_DATE between l_start_time and l_end_time)
		  or (WDJ.DATE_RELEASED between l_start_time and l_end_time))
	        AND   not exists
		(select 'X' from wip_period_balances wpb
		 where l_new_acct_period_id = wpb.acct_period_id
		 and   wpb.organization_id = l_orgid
		 and   wdj.wip_entity_id = wpb.wip_entity_id);

	      /* for repetitive schedules */
	      INSERT INTO WIP_PERIOD_BALANCES
                (ACCT_PERIOD_ID, WIP_ENTITY_ID,
		 REPETITIVE_SCHEDULE_ID, LAST_UPDATE_DATE,
		 LAST_UPDATED_BY, CREATION_DATE,
		 CREATED_BY, LAST_UPDATE_LOGIN,
		 ORGANIZATION_ID, CLASS_TYPE,
		 TL_RESOURCE_IN, TL_OVERHEAD_IN,
		 TL_OUTSIDE_PROCESSING_IN, PL_MATERIAL_IN,
		 PL_MATERIAL_OVERHEAD_IN, PL_RESOURCE_IN,
		 PL_OVERHEAD_IN, PL_OUTSIDE_PROCESSING_IN,
		 TL_MATERIAL_OUT, TL_MATERIAL_OVERHEAD_OUT, TL_RESOURCE_OUT,
		 TL_OVERHEAD_OUT, TL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_OUT, PL_MATERIAL_OVERHEAD_OUT,
		 PL_RESOURCE_OUT, PL_OVERHEAD_OUT,
		 PL_OUTSIDE_PROCESSING_OUT,
		 PL_MATERIAL_VAR, PL_MATERIAL_OVERHEAD_VAR,
		 PL_RESOURCE_VAR, PL_OUTSIDE_PROCESSING_VAR,
		 PL_OVERHEAD_VAR, TL_MATERIAL_VAR, TL_MATERIAL_OVERHEAD_VAR,
		 TL_RESOURCE_VAR, TL_OUTSIDE_PROCESSING_VAR, TL_OVERHEAD_VAR)
		SELECT
		l_new_acct_period_id,
		WRS.WIP_ENTITY_ID,
		WRS.REPETITIVE_SCHEDULE_ID, SYSDATE,
		l_user_id, SYSDATE,
		l_user_id, l_login_id,
		l_orgid, 2,
		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	        FROM WIP_REPETITIVE_SCHEDULES WRS
                WHERE WRS.STATUS_TYPE IN (3, 4, 6)
	        AND WRS.ORGANIZATION_ID = l_orgid
	        AND ((WRS.CREATION_DATE between l_start_time and l_end_time)
		  or (WRS.DATE_RELEASED between l_start_time and l_end_time))
	        AND   not exists
		(select 'X' from wip_period_balances wpb
		 where l_new_acct_period_id = wpb.acct_period_id
		 and   wpb.organization_id = l_orgid
		 and   wrs.wip_entity_id = wpb.wip_entity_id
		 and   wrs.repetitive_schedule_id = wpb.repetitive_schedule_id);

	      COMMIT;
	      END IF; --wip installed

            ELSE
              IF G_DEBUG = 'Y' THEN
               INV_ORGHIERARCHY_PVT.Log
	              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        	       ,' Open FAILED for '
                 || l_orgid || ' - '|| l_org_name
                );
              END IF;

              ADD_ITEM
             ( p_org        => NULL
             , p_period     => l_gl_period_future.open_period_name
             , p_status     => 'FAILED'
             , p_reason     => 'Open process Failed'
             , p_request_id => NULL
             , p_closed     => NULL
             , p_acct_period_id  => NULL
             );
               ROLLBACK ;
            END IF;

            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
	    ,' ======== End of Period Name ' || l_gl_period_future.open_period_name
               || ' ============================ ' );
            END IF;

         END LOOP; -- end gl fututre cursor loop

      END IF; -- process only for child organizations


       IF p_open_or_close_flag = 'C' THEN
        FOR l_org_acct_periods_val_open IN c_org_acct_periods_open
        LOOP
          IF l_org_acct_periods_val_open.open_flag = 'Y'
          THEN
            -- The period close is first verified if it can be Opened
            -- If YES, the Close period Inventory API is called

            ADD_ITEM
            ( p_org             => l_org_name
            , p_period          => NULL
            , p_status          => NULL
            , p_reason          => NULL
            , p_request_id      => NULL
            , p_closed          => NULL
            , p_acct_period_id  => NULL
            );



            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
	            ,' Calling CST_AccountingPeriod_PUB.verify_periodclose  for Org ID '
              || l_orgid
              );

              INV_ORGHIERARCHY_PVT.Log
              (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
              ,' Org ID ' || l_orgid || ' for period ' ||
              l_org_acct_periods_val_open.open_period_name ||
              ' Schedule Close Date:' || l_org_acct_periods_val_open.schedule_close_date
              );
            END IF;

            -- Bug: 3590042. Initialization of variable l_verify_flag is added.
            -- Verify flag for verify_periodclose
            l_verify_flag := 'Y';

            CST_AccountingPeriod_PUB.VERIFY_PERIODCLOSE
            ( p_api_version             => l_api_version
            , p_org_id                  => l_orgid
            , p_closing_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
            , p_closing_end_date        => l_org_acct_periods_val_open.schedule_close_date
            , x_open_period_exists      => l_open_period_exists
            , x_proper_order            => l_proper_order
            , x_end_date_is_past        => l_end_date_is_past
            , x_download_in_process     => l_download_in_process
            , x_prompt_to_reclose       => l_prompt_to_reclose
            , x_return_status           => l_return_status
            ) ;

            -- ==================================================
            -- Display log error messages
            -- check for all the verifications success
            -- ==================================================
              -- check whether period is openend
              IF NOT l_open_period_exists THEN
                /*Message name in following method is modified from
                'INV_NON_NEXT_PERIOD' to 'INV_NO_NEXT_PERIOD'.
                Bug: 3555234
                */
                FND_MESSAGE.SET_NAME('INV', 'INV_NO_NEXT_PERIOD');
                  l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);

                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,l_error_msg
                  );
                END IF;

                l_verify_flag := 'N';

              -- check whether this period is the next period to close
              ELSIF NOT l_proper_order THEN
                FND_MESSAGE.SET_NAME('INV', 'INV_CLOSE_IN_ORDER');
                l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);

                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,l_error_msg
                  );
                END IF;

                l_verify_flag := 'N';

              -- Following ELSEIF block has been modified during fix #4457006.
              -- Now it doesn't compare end date with today becasue period
              -- can be closed on any date if it has started.
              -- So if EndDate is not past then it should check whether
              -- open date is past otherwise period can not be closed.

              ELSIF NOT l_end_date_is_past THEN

	      FND_PROFILE.GET('CST_ALLOW_EARLY_PERIOD_CLOSE',l_allow_close);

	       IF l_allow_close = '1' THEN
                 SELECT TO_NUMBER(HOI.org_information2)
		 INTO   l_legal_entity
		 FROM   hr_organization_information HOI
		 WHERE  HOI.org_information_context = 'Accounting Information'
                 AND    HOI.organization_id = l_orgid;

                 l_le_sysdate := INV_LE_TIMEZONE_PUB.GET_LE_SYSDATE_FOR_OU(
		                      l_legal_entity);
                 IF (l_org_acct_periods_val_open.period_start_date > l_le_sysdate) THEN
                  FND_MESSAGE.SET_NAME('BOM','CST_CLOSE_FUTURE_PERIOD');
                  l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);
                  IF G_DEBUG = 'Y' THEN
		    INV_ORGHIERARCHY_PVT.Log
		     (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
		     ,l_error_msg
		     );
		  END IF;
		  l_verify_flag := 'N';
		 ELSE
		  -- Convert Period end date into server time zone. Adding .99999 becasue
		  -- Period end date does not store time factor.
		  l_period_end_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                             l_org_acct_periods_val_open.schedule_close_date + .99999,
                             l_legal_entity);
                  -- Get remaining hours from sysdate
		  l_hours_remaining := round((l_period_end_date - sysdate) * 24);

                  IF G_DEBUG = 'Y' THEN
		    INV_ORGHIERARCHY_PVT.Log
		     (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
		     ,'Remaining hours to close period : ' || l_hours_remaining
		     );
		  END IF;
                  ADD_ITEM
                  ( p_org             => NULL
                  , p_period          => l_org_acct_periods_val_open.open_period_name
                  , p_status          => 'Warning'
                  , p_reason          => 'Remaining hours to close period : ' || l_hours_remaining
                  , p_request_id      => NULL
                  , p_closed          => NULL
                  , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
                  );
		 END IF; --IF (l_period_open_date > l_le_sysdate)


              ELSE
	      FND_MESSAGE.SET_NAME('BOM','CST_EARLY_CLOSE_NOT_ALLOWED');
	      l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);
	      IF G_DEBUG = 'Y' THEN
		    INV_ORGHIERARCHY_PVT.Log
		     (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
		     ,l_error_msg
		     );
		  END IF;
	      l_verify_flag := 'N';
	     END IF;

              -- period close already in process for org
              ELSIF l_download_in_process THEN
                FND_MESSAGE.SET_NAME('INV', 'INV_GL_DOWNLOAD_IN_PROGRESS');
                l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);

                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,l_error_msg
                  );
                END IF;

                l_verify_flag := 'N';

              -- popup modal window asking to reclose period
              ELSIF l_prompt_to_reclose THEN
                FND_MESSAGE.SET_NAME('INV', 'INV_RECLOSE_PERIOD');
                l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);

                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,l_error_msg
                  );
                END IF;

                l_verify_flag := 'N';

              END IF; -- verify conditions

           -- insert error log on the report
           IF l_verify_flag = 'N' THEN
             ADD_ITEM
             ( p_org        => NULL
             , p_period     => l_org_acct_periods_val_open.open_period_name
             , p_status     => 'Ignore'
             , p_reason     => l_error_msg
             , p_request_id => NULL
             , p_closed     => 'N'
             , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
             );
          END IF;

            -- Proceed further to close the period only if the
            -- verify flag is 'Y'
            IF l_verify_flag = 'Y' THEN
              -- Bug#2230141 fix - check for all the pending transactions
              -- Bug#2386091 fix - added parameter pending_ship
              CST_AccountingPeriod_PUB.get_pendingtcount
              ( p_api_version            => l_api_version
              , p_org_id                 => l_orgid
              , p_closing_period         => l_org_acct_periods_val_open.closing_acct_period_id
              , p_sched_close_date       => l_org_acct_periods_val_open.schedule_close_date
              , x_pend_receiving         => l_pend_receiving
              , x_unproc_matl            => l_unproc_matl
              , x_pend_matl              => l_pend_matl
              , x_uncost_matl            => l_uncost_matl
              , x_pend_move              => l_pend_move
              , x_pend_WIP_cost          => l_pend_WIP_cost
              , x_uncost_wsm             => l_uncost_wsm
              , x_pending_wsm            => l_pending_wsm
              , x_pending_ship           => l_pending_ship
              /* Support for LCM */
              , x_pending_lcm            => l_pending_lcm
              , x_released_work_orders   => l_released_work_orders
              , x_return_status          => l_return_status
              );
              -- check for pending transactions
	         IF l_unproc_matl = 0  AND l_uncost_matl = 0  AND l_pend_WIP_cost = 0 AND
                 l_uncost_wsm = 0 AND l_pending_wsm = 0  AND l_pending_lcm = 0 AND
		 ( (  p_close_if_res_recmd = 'N' AND l_pend_receiving = 0 AND l_pend_matl = 0
		      AND l_pend_move = 0 AND l_released_work_orders = 0 AND l_pending_ship = 0)
		   OR
		    ( p_close_if_res_recmd = 'Y' AND l_pend_receiving >= 0 AND l_pend_matl >= 0
		      AND l_pend_move >= 0 AND l_released_work_orders >= 0 AND
		      (l_pending_ship = 0 OR
		       (cst_periodcloseoption_pub.get_shippingtxnhook_value(p_org_id  => l_orgid, p_acct_period_id => l_org_acct_periods_val_open.closing_acct_period_id) = 1
		        AND  l_pending_ship >= 0)
		      )
		    )
		  )
		 THEN

              -- Request Loop
              -- The Close period is called only if the
              -- number of currently running Concurrent programs are
              -- lesser than the Input parameter for Request count

              LOOP
                IF GET_OPEN_REQUESTS_COUNT < l_requests_count
                THEN
                  IF G_DEBUG = 'Y' THEN
                    INV_ORGHIERARCHY_PVT.Log
                    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                    ,' Exiting Request Loop '
                    );
                  END IF;
                  EXIT;
                END IF;

                /* Bug 3999140. Sleep time is introdued between execution of
                 * Close Accounting Period concurrent program status checking query.
                 */
                DBMS_LOCK.sleep(l_sleep_time);

              END LOOP;

              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                 ,' Calling CLOSE_PERIOD for Org ID '
                || l_orgid || ' for period ' ||
                l_org_acct_periods_val_open.open_period_name
                );
              END IF;

              /* myerrams, Bug:4599201. Modified the call to
               * CST_AccountingPeriod_PUB.close_period because of a
               * change of the signature.
               * The following parameters are removed:
               *   p_period_close_date
               *   p_schedule_close_date
               *   p_closing_rowid
               *   x_download_failed
               * And the following parameters are newly added:
               *   x_unprocessed_txns
               *   x_rec_rpt_launch_failed
               */
              CST_AccountingPeriod_PUB.close_period
              ( p_api_version             => l_api_version
              , p_org_id                  => l_orgid
              , p_user_id                 => l_user_id
              , p_login_id                => l_login_id
              , p_closing_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
              , x_wip_failed              => l_wip_failed
              , x_close_failed            => l_close_failed
              , x_req_id                  => l_req_id
  	      , x_unprocessed_txns        => l_unprocessed_txns
   	      , x_rec_rpt_launch_failed   => l_rec_rpt_launch_failed
              , x_return_status           => l_return_status
              );

              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                    ,' Out of CST_AccountingPeriod_PUB.close_period for Org ID ' || l_orgid
                );
              END IF;

              IF (l_wip_failed) = true
              THEN
                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,' WIP Failed for '
                  || l_orgid || ' Request ID ' || l_req_id
                  )  ;
                END IF;
                ADD_ITEM
                ( p_org             => NULL
                 , p_period          => l_org_acct_periods_val_open.open_period_name
                , p_status          => 'Failed'
                , p_reason          => 'WIP Failed'
                , p_request_id      => l_req_id
                , p_closed          => 'N'
                , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
                );

              END IF;

	      IF (l_download_failed) = true
              THEN
                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,'  download_failed for '
                   || l_orgid || ' Request ID ' || l_req_id
                  );
                END IF;
                ADD_ITEM
                ( p_org        => NULL
                , p_period     => l_org_acct_periods_val_open.open_period_name
                , p_status     => 'Failed'
                , p_reason     => 'Download Failed'
                , p_request_id => l_req_id
                , p_closed     => 'N'
                , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
                );

              END IF;

              --myerrams, Bug:4599201
	      IF (l_unprocessed_txns) = true
	      THEN

		FND_MESSAGE.SET_NAME('BOM','CST_UNPROCESSED_TXNS');
                l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);
                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,l_error_msg
                  );
                END IF;

		FND_MESSAGE.SET_NAME('INV','INV_PERIOD_CLOSE_ABORTED');
                l_error_msg := SUBSTR(FND_MESSAGE.Get, 1,255);
                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                  ,l_error_msg
                  );
                END IF;

	      END IF;
              --myerrams end, Bug:4599201

              IF      ( l_close_failed )    = true
              THEN
                IF G_DEBUG = 'Y' THEN
                   INV_ORGHIERARCHY_PVT.Log
                    (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
	                   ,'  close Falied - for Org ID '
                     || l_orgid || ' Request ID ' || l_req_id
                    );
                END IF;

                ADD_ITEM
                 ( p_org        => NULL
                 , p_period     => l_org_acct_periods_val_open.open_period_name
                 , p_status     => 'Failed'
                 , p_reason     => 'Close Failed'
                 , p_request_id => l_req_id
                 , p_closed     => 'N'
                 , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
                 );

                ROLLBACK ;
              ELSE --IF      ( l_close_failed )    = true
                IF G_DEBUG = 'Y' THEN
                  INV_ORGHIERARCHY_PVT.Log
                  ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                    , ' Close in process REquest  '|| l_req_id
                  );
                END IF;
                IF p_close_if_res_recmd = 'Y' AND
		    (l_pend_receiving > 0 OR l_pend_matl > 0 OR l_pend_move > 0
		     OR l_released_work_orders > 0 OR l_pending_ship > 0) THEN
		  l_closed_if_res_recmd := 1;
		 IF G_DEBUG = 'Y' THEN
		  INV_ORGHIERARCHY_PVT.Log
                  ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                    , ' WARNING : There are pending transactions with resolutions recommended for '||l_org_acct_periods_val_open.open_period_name||
		       ' in '||l_orgid
                  );
		 END IF;
                 ADD_ITEM
                 ( p_org        => NULL
                 , p_period     => l_org_acct_periods_val_open.open_period_name
                 , p_status     => 'Warning'
                 , p_reason     => 'There are pending transactions with resolutions recommended'
                 , p_request_id => NULL
                 , p_closed     => 'N'
                 , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
                 );
		 END IF;
		 ADD_ITEM
                 ( p_org        => NULL
                 , p_period     => l_org_acct_periods_val_open.open_period_name
                 , p_status     => 'Processing'
                 , p_reason     => NULL
                 , p_request_id => l_req_id
                 , p_closed     => 'N'
                 , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
                 );
                COMMIT ;
              END IF; --IF      ( l_close_failed )    = true

            ELSE  --IF l_unproc_matl = 0
              IF G_DEBUG = 'Y' THEN
                INV_ORGHIERARCHY_PVT.Log
                ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
                 , 'Pending Transactions exists'
                );
              END IF;
              ADD_ITEM
              ( p_org        => NULL
              , p_period     => l_org_acct_periods_val_open.open_period_name
              , p_status     => 'Ignore'
              , p_reason     => 'Pending transactions exists'
              , p_request_id => NULL
              , p_closed     => 'N'
              , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
              );
            END IF ; -- check for pending transaction

          -- verify_periodclose failed
          ELSE
            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
               , ' Period not eligible to be closed '
              );
            END IF;

          END IF; -- verify_periodclose

          ELSE
            IF G_DEBUG = 'Y' THEN
              INV_ORGHIERARCHY_PVT.Log
              ( INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
               , ' Period not Open '
              );
            END IF;
           /* Commented following code for showing details of only eligible
           periods in Summary report. Bug: 3555234
            ADD_ITEM
           ( p_org        => NULL
           , p_period     => l_org_acct_periods_val_open.open_period_name
           , p_status     => 'Ignore'
           , p_reason     => 'Not Open'
           , p_request_id => NULL
           , p_closed     => 'N'
           , p_acct_period_id  => l_org_acct_periods_val_open.closing_acct_period_id
           );*/

          END IF; -- open flag check
        END LOOP;
        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
          ,' Out of Close FOR loop ' );
        END IF;
      END IF; -- Open or close flag check

      l_list_count := l_list_count - 1;
      l_index      := l_index + 1;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        ,'  '
        );

        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        ,' ************** END Processing Organization = '||
         l_org_name || ' ************************** '
        );
      END IF;

      l_date_from     := NULL;
      l_org_from_date := NULL;

      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        ,' Out of Close FOR loop ' );
      END IF;

    END LOOP;  -- organization list loop

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,' Out of Org List WHILE Loop, start final request check '
      );
    END IF;

    -- Final loop to check the status of the remaining
    -- concurrent close programs that could be running

    LOOP
      IF GET_OPEN_REQUESTS_COUNT <= 0
      THEN
        IF G_DEBUG = 'Y' THEN
          INV_ORGHIERARCHY_PVT.Log
          (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        	,' Exiting Request Loop '
          );
        END IF;
        EXIT;
      END IF;

      /* Bug 3999140. Sleep time is introdued between execution of
      * Close Accounting Period concurrent program status checking query.
      */
      DBMS_LOCK.sleep(l_sleep_time);

    END LOOP;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      , ' Out of final Request Loop  ' );
    END IF;
    ELSE
      IF G_DEBUG = 'Y' THEN
        INV_ORGHIERARCHY_PVT.Log
        (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
        , ' Org List Empty ' );
      END IF;
    END IF;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
       ,'  '
      );

      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_STATEMENT
      ,'*********************** End of Report ***********************  '
      );
    END IF;

    PRINT_REPORT ;

    IF G_DEBUG = 'Y' THEN
      INV_ORGHIERARCHY_PVT.Log
      (INV_ORGHIERARCHY_PVT.G_LOG_PROCEDURE
       ,'< INV_MGD_PRD_CONTROL_MEDIATOR.Period_Control '
      );
    END IF;

    IF l_closed_if_res_recmd = 1 THEN
         FND_MESSAGE.set_name('INV', 'INV_MGD_RES_RECMD_WARNING');
         x_errbuff  := SUBSTR(FND_MESSAGE.Get, 1, 255);
    END IF;
EXCEPTION
-- Following exception handling block which was introduced during bug 3904824
-- has been commented during fix 4457006 because 11.5.10 CU2 onwards, scheduling can be
-- done for any date and user can close Period on any date they wish. So no need
-- to handle scheduling related exception.

-- Bug #3904824.New exception introduced.
-- WHEN l_close_period_before_sch_dt THEN
--       INV_ORGHIERARCHY_PVT.Log
--         (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,x_errbuff);
--              x_retcode := RETCODE_ERROR;


 -- Bug:3296392 - Addeed the exception hanlding for the validaiton
 --               failure.
 WHEN l_hierarchy_validation THEN
       INV_ORGHIERARCHY_PVT.Log
         (INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION,x_errbuff);
    x_retcode := RETCODE_ERROR;

 WHEN OTHERS THEN
    /* This executable is used by concurrent program so
       Error/Exception logging should not depend on
       FND Debug Enabled profile otpion. Bug: 3555234
      IF G_DEBUG = 'Y' THEN
      */
      INV_ORGHIERARCHY_PVT.Log( INV_ORGHIERARCHY_PVT.G_LOG_EXCEPTION
                            , 'SQLERRM '|| SQLERRM) ;
    --END IF;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg
      ( G_PKG_NAME
      , ' Period_Control '
      );
    END IF;
    ROLLBACK;
    RAISE;

END Period_Control ;

END INV_MGD_PRD_CONTROL_MEDIATOR ;


/
