--------------------------------------------------------
--  DDL for Package Body CST_ACCRUAL_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_ACCRUAL_LOAD" as
/* $Header: CSTACCLB.pls 120.27.12010000.18 2010/03/19 10:56:01 smsasidh ship $ */

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'CST_ACCRUAL_LOAD';
G_LOG_HEADER CONSTANT VARCHAR2(40) := 'cst.plsql.CST_ACCRUAL_LOAD';
G_LOG_LEVEL  CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_DEBUG      CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--Local procedure and function
g_dummy_date      CONSTANT DATE := TO_DATE('3000/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS');
g_def_start_date  CONSTANT DATE := TO_DATE('1900/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS');

/*===========================================================================+
|                                                                            |
| Procedure Name : debug                                                     |
|                                                                            |
| Purpose        : This Procedure logs the message in fnd_log_messages       |
|                                                                            |
| Called from    :                                                           |
|                                                                            |
| Parameters     :                                                           |
| IN             :  line       IN VARCHAR2                                   |
|                   msg_prefix IN VARCHAR2                                   |
|                   msg_module IN VARCHAR2                                   |
|                   msg_level  IN NUMBER                                     |
| OUT            :                                                           |
|                                                                            |
| Created   Aug-08     Herve Yu                                   |
|                                                                            |
+===========================================================================*/
PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT G_PKG_NAME,
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
  l_msg_prefix     VARCHAR2(64);
  l_msg_level      NUMBER;
  l_msg_module     VARCHAR2(256);
  l_beg_end_suffix VARCHAR2(15);
  l_org_cnt        NUMBER;
  l_line           VARCHAR2(32767);
BEGIN
  l_line       := line;
  l_msg_prefix := msg_prefix;
  l_msg_level  := msg_level;
  l_msg_module := msg_module;

  fnd_file.put_line(fnd_file.LOG, line);

  IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0) THEN
    l_msg_level  := FND_LOG.LEVEL_EXCEPTION;
  END IF;
  IF l_msg_level <> FND_LOG.LEVEL_EXCEPTION AND G_DEBUG = 'N' THEN
    RETURN;
  END IF;
  IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
    FND_LOG.STRING(l_msg_level,l_msg_module,SUBSTRB(l_line,1,1000));
    FND_FILE.put_line(fnd_file.log, SUBSTRB(l_line,1,1000) );
  END IF;
EXCEPTION
  WHEN OTHERS THEN RAISE;
END debug;

/*===========================================================================+
|                                                                            |
| Procedure Name : xla_min_upg_date                                          |
|                                                                            |
| Purpose        : This Procedure gets information whether XLA is upgraded   |
|                  or not for that Operating Unit.                           |
|                   x_xla_upg =  Y If XLA upgraded                           |
|                             =  N If xla NOT upgraded                       |
|                   x_min_upg_date = g_dummy_date, If XLA NOT upgraded       |
|                                  = Min xla Upgrade Date, If XLA upgraded   |
|                                                                            |
| Called from    : DetUpgDatesFromDate                                       |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  x_xla_upg        OUT  VARCHAR2                           |
|                   x_min_upg_date   OUT  DATE                               |
|                                                                            |
| Created   Aug-08     Herve Yu                                   |
|                                                                            |
+===========================================================================*/
PROCEDURE xla_min_upg_date
(p_operating_unit_id IN NUMBER,
 x_xla_upg           OUT NOCOPY VARCHAR2,
 x_min_upg_date      OUT NOCOPY DATE)
IS
  CURSOR sob_upg_date(p_operating_unit_id IN NUMBER) IS
  SELECT MIN(b.start_date)
    FROM cst_acct_info_v     a,
         gl_period_statuses  b
   WHERE a.ledger_id             = b.set_of_books_id
     AND b.migration_status_code = 'U'
     AND a.operating_unit        = to_char(p_operating_unit_id);

  l_min_date    DATE;
BEGIN
  debug('ou_min_upg_date +');
  debug('  p_operating_unit_id:'||p_operating_unit_id);
  OPEN sob_upg_date(p_operating_unit_id);
  FETCH sob_upg_date INTO x_min_upg_date ;
  IF sob_upg_date%NOTFOUND THEN
    x_xla_upg := 'N';
    x_min_upg_date  := g_dummy_date;
  ELSE
    IF x_min_upg_date IS NULL THEN
      x_xla_upg := 'N';
      x_min_upg_date  := g_dummy_date;
    ELSE
      x_xla_upg := 'Y';
    END IF;
  END IF;
  CLOSE sob_upg_date;
  debug('  x_min_upg_date  :'||x_min_upg_date );
  debug('  x_xla_upg       :'||x_xla_upg );
  debug('ou_min_upg_date -');
EXCEPTION
  WHEN OTHERS THEN
   debug('EXCEPTION in sob_upg_date:'||SQLERRM);
   RAISE;
END xla_min_upg_date;

/*===========================================================================+
|                                                                            |
| Procedure Name : build_run                                                 |
|                                                                            |
| Purpose        : This Procedure gets information whether the Accrual Load  |
|                  Build is first run or not for that Operating Unit         |
|                   x_first_build =  Y <=> 1st build                         |
|                                 =  N <=> NOT 1st build                     |
|                   x_min_build_date = g_dummy_date, IF first_build          |
|                                    = Min Build Date, If Second upgraded    |
|                                                                            |
| Called from    : DetUpgDatesFromDate                                       |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  x_first_build    OUT  VARCHAR2                           |
|                   x_min_build_date OUT  DATE                               |
|                                                                            |
| Created   Aug-08     Herve Yu                                   |
|                                                                            |
+===========================================================================*/
PROCEDURE build_run
(p_operating_unit    IN NUMBER,
 x_first_build       OUT NOCOPY  VARCHAR2,
 x_min_build_date    OUT NOCOPY  DATE)
IS
  CURSOR min_build_date(p_operating_unit IN NUMBER) IS
  SELECT MIN(DECODE(from_date,g_def_start_date, g_dummy_date,from_date))
    FROM CST_RECONCILIATION_BUILD
   WHERE operating_unit_id = p_operating_unit;
BEGIN
  debug('build_run +');
  debug('    p_operating_unit :'||p_operating_unit);

  OPEN min_build_date(p_operating_unit=>p_operating_unit);
  FETCH min_build_date INTO x_min_build_date;
  IF min_build_date%NOTFOUND THEN
     x_first_build    := 'Y';
     x_min_build_date := g_dummy_date;
  ELSE
     IF x_min_build_date IS NULL THEN
        x_first_build    := 'Y';
        x_min_build_date := g_dummy_date;
     ELSE
        x_first_build := 'N';
      END IF;
  END IF;
  CLOSE min_build_date;

  debug('    x_first_build    :'||x_first_build);
  debug('    x_min_build_date :'||x_min_build_date);
  debug('build_run -');
EXCEPTION
  WHEN OTHERS THEN
    debug('EXCEPTION build_run :'||SQLERRM);
END build_run;

/*===========================================================================+
|                                                                            |
| Procedure Name : min_mre_date                                              |
|                                                                            |
| Purpose        : This Procedure gets the minimum receipt date from         |
|                  xla_events table.                                         |
|                                                                            |
| Called from    : DetUpgDatesFromDate                                       |
|                                                                            |
| Parameters     :                                                           |
| IN             :  NONE                                                     |
|                                                                            |
| OUT            :  x_mre_date OUT DATE                                      |
|                                                                            |
| Created   Aug-08     Herve Yu                                   |
|                                                                            |
+===========================================================================*/
PROCEDURE min_mre_date
(x_mre_date   OUT NOCOPY DATE)
IS
  CURSOR c_min_recp IS
  SELECT min(ev.event_date)
    FROM xla_events ev
   WHERE ev.application_id      IN (707,555) /*Bug 8426283 - included application id 555 also*/
     AND ev.event_type_code     = 'RECEIVE'
     AND ev.process_status_code = 'P'
     AND ev.event_status_code   = 'P';
BEGIN
  debug('min_mre_date +');
  OPEN c_min_recp;
  FETCH c_min_recp INTO x_mre_date;
  IF c_min_recp%NOTFOUND THEN
     x_mre_date := SYSDATE;
  ELSE
     IF x_mre_date IS NULL THEN
       x_mre_date := SYSDATE;
     END IF;
  END IF;
  CLOSE c_min_recp;
  debug('  x_mre_date:'||x_mre_date);
  debug('min_mre_date -');
END min_mre_date;

/*===========================================================================+
|                                                                            |
| Procedure Name : DetUpgDatesFromDate                                       |
|                                                                            |
| Purpose        : This Procedure determines the From Date of Load Build     |
|                  program, and whether to upgrade old data or not.          |
|                                                                            |
|                                                                            |
| Called from    : Start_accrual_load                                        |
|                                                                            |
| Parameters     :                                                           |
| IN             : p_operating_unit     IN NUMBER                            |
|                  p_from_date          IN DATE                              |
|                                                                            |
| OUT            :  x_from_date          OUT NOCOPY DATE,                    |
|                   x_upg_old_data       OUT NOCOPY VARCHAR2                 |
|                   x_old_from_date      OUT NOCOPY DATE                     |
|                   x_old_to_date        OUT NOCOPY DATE                     |
|                                                                            |
| Created   Aug-08     Herve Yu                                   |
|                                                                            |
+===========================================================================*/
PROCEDURE DetUpgDatesFromDate
(p_operating_unit     IN NUMBER,
 p_from_date          IN DATE,
 x_from_date          OUT NOCOPY DATE,
 x_upg_old_data       OUT NOCOPY VARCHAR2,
 x_old_from_date      OUT NOCOPY DATE,
 x_old_to_date        OUT NOCOPY DATE)
IS
  l_xla_upg            VARCHAR2(1);
  l_min_upg_date       DATE;
  l_first_build        VARCHAR2(1);
  l_min_build_date     DATE;
  l_mre_date           DATE;
BEGIN
  debug('DetUpgDatesFromDate+');
  debug('   p_operating_unit :' || p_operating_unit);

  xla_min_upg_date(p_operating_unit_id => p_operating_unit,
                   x_xla_upg           => l_xla_upg,
                   x_min_upg_date      => l_min_upg_date);

  build_run(p_operating_unit    => p_operating_unit,
            x_first_build       => l_first_build,
            x_min_build_date    => l_min_build_date);

----------------------------------------------------------------------------------------------------------------------
-- FirstBuild XlaUpg BldDate XlaUpgDate PFromDate  Condition        xFromDate OldUpg OFromDate OToDate  Comment
----------------------------------------------------------------------------------------------------------------------
-- Y          Y      NA      XD         PD         NA               XD        Y       XD       SYSDATE  1
-- Y          Y      NA      XD         NULL       NA               XD        Y       XD       SYSDATE  2
-- Y          N      NA      NA         PD         PD>=MRE          PD        N       NA       NA       3 New Customer
--                                                 PD<MRE           MRE       N       NA       NA       4 New Customer
-- Y          N      NA      NA         NULL       NA               MRE       N       NA       NA       5 New Customer
-----------------------------------------------------------------------------------------------------------------------
-- N          Y      BD      XD         NULL       BD=XD            XD        N       NA       NA       6
-- N          Y      BD      XD         NULL       BD>XD            XD        Y       XD       BD-1     7 IncBuild
-- N          Y      BD      XD         PD         BD>XD AND PD>=BD PD        N       NA       NA       8 User needs to activate Incbuild
-- N          Y      BD      XD         PD         BD>XD AND PD<BD  XD        Y       XD       BD-1     9 IncBuild
-- N          Y      BD      XD         PD         BD=XD AND PD<BD  XD        N       NA       NA      10
-- N          Y      BD      XD         PD         BD=XD AND PD>=BD PD        N       NA       NA      11
-- N          N      BD      NA         NULL       NA               BD        N       NA       NA      12 New Customer
-- N          N      BD      NA         PD         PD>=BD           PD        N       NA       NA      13 New Customer
-- N          N      BD      NA         PD         PD<BD AND PD>MRE PD        N       NA       NA      14 New Customer
-- N          N      BD      NA         PD         PD<BD AND PD<MRE MRE       N       NA       NA      15 New Customer
-----------------------------------------------------------------------------------------------------------------------
-- Concurrent program Accrual build should default the MAX BD to the end user always except first build
-----------------------------------------------------------------------------------------------------------------------

  debug('----------------------');
  debug('l_first_build        :'||l_first_build);
  debug('  l_xla_upg            :'||l_xla_upg);
  debug('  BD l_min_build_date  :'||l_min_build_date);
  debug('  XD l_min_upg_date    :'||l_min_upg_date);
  debug('  PD p_from_date       :'||p_from_date);
  debug('----------------------');

  IF    l_first_build = 'Y' AND l_xla_upg = 'Y' THEN
     debug('  Case 1 or 2');
     x_from_date     := l_min_upg_date;
     x_upg_old_data  := 'Y';
     x_old_from_date := l_min_upg_date;
     x_old_to_date   := SYSDATE;
  ELSIF l_first_build = 'Y' AND l_xla_upg = 'N' THEN
    min_mre_date(x_mre_date  => l_mre_date);
    IF p_from_date IS NULL THEN
      debug('  Case 5');
      x_from_date     := l_mre_date;
      x_upg_old_data  := 'N';
    ELSE
      IF p_from_date >= l_mre_date THEN
        debug('  Case 3');
        x_from_date     := p_from_date;
        x_upg_old_data  := 'N';
      ELSE
        debug('  Case 4');
        x_from_date     := l_mre_date;
        x_upg_old_data  := 'N';
      END IF;
    END IF;
  ELSIF  l_first_build = 'N' AND l_xla_upg = 'Y' THEN
    IF p_from_date IS NULL THEN
       IF l_min_build_date <= l_min_upg_date THEN
         debug('  Case 6');
         x_from_date     := l_min_upg_date;
         x_upg_old_data  := 'N';
       ELSE
         debug('  Case 7');
         x_from_date     := l_min_upg_date;
         x_upg_old_data  := 'Y';
         x_old_from_date := l_min_upg_date;
         x_old_to_date   := l_min_build_date-1;
       END IF;
    ELSE
       IF  l_min_build_date > l_min_upg_date  THEN
          IF p_from_date >= l_min_build_date THEN
              debug('  Case 8');
              x_from_date     := p_from_date;
              x_upg_old_data  := 'N';
          ELSE
              debug('  Case 9');
              x_from_date     := l_min_upg_date;
              x_upg_old_data  := 'Y';
              x_old_from_date := l_min_upg_date;
              x_old_to_date   := l_min_build_date-1;
          END IF;
       ELSE
          IF p_from_date >= l_min_build_date THEN
              debug('  Case 11');
              x_from_date     := p_from_date;
              x_upg_old_data  := 'N';
          ELSE
              debug('  Case 10');
              x_from_date     := l_min_upg_date;
              x_upg_old_data  := 'N';
          END IF;
       END IF;
    END IF;
  ELSIF l_first_build = 'N' AND l_xla_upg = 'N' THEN
    IF p_from_date IS NULL THEN
       debug('  Case 12');
       x_from_date     := l_min_build_date;
       x_upg_old_data  := 'N';
    ELSE
      IF p_from_date >= l_min_build_date THEN
         debug('  Case 13');
         x_from_date     := p_from_date;
         x_upg_old_data  := 'N';
      ELSE
         min_mre_date(x_mre_date  => l_mre_date);
         IF p_from_date < l_min_build_date THEN
            IF p_from_date >= l_mre_date THEN
               debug('  Case 14');
               x_from_date     := p_from_date;
               x_upg_old_data  := 'N';
            ELSE
               debug('  Case 15');
               x_from_date     := l_mre_date;
               x_upg_old_data  := 'N';
            END IF;
         END IF;
      END IF;
    END IF;
  END IF;
  IF x_upg_old_data = 'N' THEN
    x_old_from_date := NULL;
    x_old_to_date   := NULL;
  END IF;
  debug('  x_from_date    :'||x_from_date);
  debug('  x_upg_old_data :'||x_upg_old_data);
  debug('  x_old_from_date:'||x_old_from_date);
  debug('  x_old_to_date  :'||x_old_to_date);
  debug('DetUpgDatesFromDate-');
EXCEPTION
  WHEN OTHERS THEN
    debug('OTHERS EXCEPTION IN DetUpgDatesFromDate'||SQLERRM);
    RAISE;
END DetUpgDatesFromDate;

/*===========================================================================+
|                                                                            |
| Procedure Name : Start_accrual_load                                        |
|                                                                            |
| Purpose        : This Procedure kicks off the Accrual load process         |
|                  and passes control to the accrual load procedure          |
|                                                                            |
| Called from    : The Accrual Concurrent Load program                       |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_from_date      IN   VARCHAR2  can be NULL              |
|                   p_to_date        IN   VARCHAR2  can be NULL              |
|                                                                            |
| OUT            :  errbuf      OUT  NOCOPY VARCHAR2                         |
|                   retcode     OUT  NOCOPY NUMBER                           |
|                   These 2 OUT variables are the standard OUT variables     |
|                   that the conc program definition expects.                |
|                                                                            |
| NOTES          :  None                                                     |
+===========================================================================*/

PROCEDURE start_accrual_load(errbuf           OUT  NOCOPY VARCHAR2,
                             retcode          OUT  NOCOPY NUMBER,
                             p_from_date      IN   VARCHAR2,
                             p_to_date        IN   VARCHAR2
                            )
IS
  l_stmt_num                     NUMBER;
  l_operating_unit               NUMBER;
  l_conc_request                 BOOLEAN;

  l_api_version        CONSTANT  NUMBER  := 1.0;
  l_init_message_list  CONSTANT  VARCHAR2(10) := 'FALSE';
  l_commit             CONSTANT  VARCHAR2(1) := FND_API.G_FALSE;

  l_call_error         VARCHAR2(400);

  l_err_data           VARCHAR2(2400);
  l_err_status         VARCHAR2(10);
  l_err_ret_status     VARCHAR2(10);
  l_err_count          NUMBER;

  l_api_name           CONSTANT  VARCHAR2(30)  := 'Start_accrual_load';
  l_full_name          CONSTANT  VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
  l_module             CONSTANT  VARCHAR2(60)  := 'cst.plsql.'||l_full_name;

  l_uLog               CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog           CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog       CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog               CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog               CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN

    debug('start_accrual_load +');

    l_stmt_num := 5;

    l_err_status    := fnd_api.g_ret_sts_success;
    l_err_ret_status := fnd_api.g_ret_sts_success;

    debug('   l_stmt_num  :' || l_stmt_num);
    debug('   p_from_date :' || p_from_date);
    debug('   p_to_date   :' || p_to_date);


    /* Get the current ORG_ID by calling the MOAC package */

    l_operating_unit := mo_global.get_current_org_id;

    debug('    l_operating_unit:'||l_operating_unit);

    /* Call the Accrual Load API and pass it all the parameters */

    accrual_load(p_api_version     => l_api_version,
                 p_init_msg_list   => l_init_message_list,
                 p_commit          => l_commit,
                 p_operating_unit  => l_operating_unit,
                 p_from_date       => p_from_date,
                 p_to_date         => p_to_date,
                 x_return_status   => l_err_status,
                 x_msg_count       => l_err_count,
                 x_msg_data        => l_err_data
                );

    debug(' accrual_load - l_err_status:'||l_err_status);
    debug(' accrual_load - l_err_count :'||l_err_count);
    debug(' accrual_load - l_err_data  :'||l_err_data);


     IF l_err_count IS NOT NULL AND l_err_count > 0 THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;

    l_stmt_num := 10;

    debug('start_accrual_load-');

EXCEPTION

 WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK;
    debug('EXCEPTION FND_API.g_exc_unexpected_error IN Start_accrual_load');
    debug(' l_stmt_num  :'||l_stmt_num);
    debug(' l_err_status:'||l_err_status);
    debug(' l_err_count :'||l_err_count);
    debug(' l_err_data  :'||l_err_data);

   l_conc_request := fnd_concurrent.set_completion_status('ERROR',substrb(l_err_data,1,240));

   RETURN;

 WHEN OTHERS THEN
   rollback;
   debug('EXCEPTION OTHERS IN Start_accrual_load: '||substr(SQLERRM,1,180));

   l_conc_request := fnd_concurrent.set_completion_status('ERROR',substrb(SQLERRM,1,240));

   RETURN;

END Start_accrual_load;

/*===========================================================================+
|                                                                            |
| Procedure Name : accrual_load                                              |
|                                                                            |
| Purpose        : This Procedure transfers control to the procedures        |
|                  that upgrade and load data from the transaction tables.   |
|                                                                            |
| Called from    : Start_accrual_load Procedure                              |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_api_version    IN   NUMBER    REQUIRED                 |
|                   p_init_msg_list  IN   VARCHAR2  REQUIRED                 |
|                   p_commit         IN   VARCHAR2  REQUIRED                 |
|                   p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_from_date      IN   VARCHAR2  can be NULL              |
|                   p_to_date        IN   VARCHAR2  can be NULL              |
|                                                                            |
| OUT            :  x_return_status  OUT  NOCOPY VARCHAR2                    |
|                   x_msg_count      OUT  NOCOPY NUMBER                      |
|                   x_msg_data       OUT  NOCOPY VARCHAR2                    |
|                                                                            |
| NOTES          :  None                                                     |
+===========================================================================*/


PROCEDURE accrual_load(p_api_version    IN  NUMBER,
                       p_init_msg_list  IN  VARCHAR2,
                       p_commit         IN  VARCHAR2,
                       p_operating_unit IN  NUMBER,
                       p_from_date      IN  VARCHAR2,
                       p_to_date        IN  VARCHAR2,
                       x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count      OUT NOCOPY NUMBER,
                       x_msg_data       OUT NOCOPY VARCHAR2
                       )
IS

  l_from_date            DATE;
  l_to_date              DATE;
  l_build_count          NUMBER;
  l_debug                VARCHAR2(80);
  l_round_unit           NUMBER;
  l_stmt_num             NUMBER;
  l_err_data             VARCHAR2(2400);
  l_err_status           VARCHAR2(10);
  l_err_count            NUMBER;
  l_conc_request         BOOLEAN;
  l_req_arg              VARCHAR2(20);
  l_req_running          NUMBER;
  l_acc_accounts         NUMBER;

  l_api_version CONSTANT  NUMBER        := 1.0;
  l_api_message           VARCHAR2(1000);
  l_error_message         VARCHAR2(300);
  l_call_error            VARCHAR2(400);

  l_api_name    CONSTANT  VARCHAR2(30)  := 'accrual_load';
  l_full_name   CONSTANT  VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
  l_module      CONSTANT  VARCHAR2(60)  := 'cst.plsql.'||l_full_name;

  l_uLog         CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog         CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  --BUG#7384429
  CURSOR c_chk_misc_inv(p_ou_id     IN NUMBER,
                        p_from_date IN DATE,
                        p_to_date   IN DATE)
  IS
  SELECT 'Y'
  FROM xla_ae_lines                    l
      ,xla_ae_headers                  h
      ,xla_event_types_b               xet
      ,financials_system_params_all    fsp
      ,cst_accrual_accounts            caa
  WHERE caa.operating_unit_id          = p_ou_id
  AND   fsp.org_id                     = p_ou_id
  AND   xet.application_id             = 707
  AND   xet.entity_code                = 'MTL_ACCOUNTING_EVENTS'
  AND   h.application_id               = 707
  AND   xet.event_type_code            = h.event_type_code
  AND   h.ledger_id                    = fsp.set_of_books_id
  AND   h.accounting_date  BETWEEN p_from_date AND p_to_date
  AND   h.ACCOUNTING_ENTRY_STATUS_CODE = 'F'
  AND   h.gl_transfer_status_code      = 'Y'
  AND   l.application_id               = 707
  AND   h.ae_header_id                 = l.ae_header_id
  AND   l.code_combination_id          = caa.accrual_account_id
  AND   rownum                         = 1;

  l_misc_inv            VARCHAR2(1);
  l_old_from_date       DATE;
  l_old_to_date         DATE;
  l_upg_old_data        VARCHAR2(1);
  l_p_from_date         DATE;
  stop_here      EXCEPTION;
  --}

BEGIN
    debug('accrual_load+');
    debug('   p_operating_unit:'||p_operating_unit);
    debug('   p_from_date := ' || p_from_date);
    debug('   p_to_date   := ' || p_to_date);

    l_stmt_num := 5;

    debug('  l_stmt_num:'||l_stmt_num);
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call (
                                           l_api_version,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME
                                           ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_return_status := fnd_api.g_ret_sts_success;

    /* check for incompatibility. If there is another load running for the same OU,error out this one */

    SELECT FCR.argument1 into l_req_arg
      FROM FND_CONCURRENT_REQUESTS FCR
     WHERE FCR.concurrent_program_id  = FND_GLOBAL.CONC_PROGRAM_ID
       AND FCR.program_application_id = FND_GLOBAL.PROG_APPL_ID
       AND FCR.request_id             = FND_GLOBAL.CONC_REQUEST_ID;

   debug('  l_req_arg:'||l_req_arg);

    SELECT count(*) into l_req_running
    FROM FND_CONCURRENT_REQUESTS FCR
    WHERE FCR.concurrent_program_id  = FND_GLOBAL.CONC_PROGRAM_ID
      AND FCR.program_application_id = FND_GLOBAL.PROG_APPL_ID
      AND FCR.phase_code             = 'R'
      AND FCR.argument1              = l_req_arg;

   debug('  l_req_running:'||l_req_running);


    IF (l_req_running > 1) THEN /* More than one running, so error this one out*/
      l_error_message := 'CST_ACC_ERROR';
      fnd_message.set_name('BOM','CST_ACC_ERROR');
      RAISE fnd_api.g_exc_error;
    END IF;


    l_stmt_num := 10;
    debug('  l_stmt_num:'||l_stmt_num);

    /* check if there are accounts selected in CST_ACCRUAL_ACCOUNTS table. If not then error out */

    SELECT count(*)
      INTO l_acc_accounts
      FROM cst_accrual_accounts
     WHERE operating_unit_id = p_operating_unit
       AND ROWNUM            = 1;

   debug('  l_acc_accounts:'||l_acc_accounts);


    IF l_acc_accounts = 0 THEN
      l_error_message := 'CST_ACC_ACCOUNTS_ERR';
      fnd_message.set_name('BOM','CST_ACC_ACCOUNTS_ERR');
      RAISE fnd_api.g_exc_error;
    END IF;

    l_stmt_num := 20;
    debug('  l_stmt_num:'||l_stmt_num);

    /* Check if this is the first build.If it is,then,make a call to the upgrade
       function.Also ignore the from and to dates provided by the user and run the
       load for the complete time range */


 --BUG#7275286


/*
    Select count(*)
    INTO l_build_count
    FROM  CST_RECONCILIATION_BUILD
    WHERE operating_unit_id = p_operating_unit
    AND   rownum            = 1;


    If (l_build_count = 0 OR p_from_date is NULL)then
      l_from_date := to_date('1900/01/01 00:00:00','YYYY/MM/DD HH24:MI:SS');
    elsif (p_from_date is NOT NULL) then
      l_from_date := to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
    End If;
*/


    l_p_from_date    := to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');


    DetUpgDatesFromDate(p_operating_unit     => p_operating_unit,
                        p_from_date          => l_p_from_date,
                        x_from_date          => l_from_date,
                        x_upg_old_data       => l_upg_old_data,
                        x_old_from_date      => l_old_from_date,
                        x_old_to_date        => l_old_to_date);

    l_stmt_num := 30;
    debug('  l_stmt_num:'||l_stmt_num);




    IF (p_to_date IS NULL) THEN
      l_to_date := trunc(sysdate) + 0.99999;
    ELSE
      l_to_date := to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS');
    END IF;


    debug('  The from date is:' || to_char(l_from_date,'YYYY/MM/DD HH24:MI:SS'));
    debug('  The to date is  :' || to_char(l_to_date,'YYYY/MM/DD HH24:MI:SS'));

    l_stmt_num := 40;
    debug('  l_stmt_num:'||l_stmt_num);

    /* check the dates passed in and error out if p_to_date < p_from_date */

    IF l_from_date > l_to_date THEN


      IF l_p_from_date > l_to_date THEN
         l_error_message := 'CST_INVALID_TO_DATE';
         fnd_message.set_name('BOM','CST_INVALID_TO_DATE');
         RAISE fnd_api.g_exc_error;
      ELSE
        fnd_message.set_name('FND','FORM_TECHNICAL_ERROR');
        fnd_message.set_token('MESSAGE','Calculated from_date:'||
                                         TO_CHAR(l_from_date,'DD-MM-YYYY')||' > l_to_date:'||
                                         TO_CHAR(l_to_date,'DD-MM-YYYY'));
        RAISE stop_here;
      END IF;

    END IF;

    l_stmt_num := 45;
    debug('  l_stmt_num:'||l_stmt_num);
    debug('  l_upg_old_data :'||l_upg_old_data );

--    If l_build_count = 0 then

    IF  l_upg_old_data = 'Y' THEN

      -- make a call to the upgrade script handler

      upgrade_old_data(p_operating_unit  => p_operating_unit,
                       --BUG#7275286

                       p_upg_from_date   => l_old_from_date,
                       p_upg_to_date     => l_old_to_date,
                       --}
                       x_msg_count       => l_err_count,
                       x_msg_data        => l_err_data,
                       x_return_status   => l_err_status);

      If l_err_status <>  FND_API.G_RET_STS_SUCCESS then

        debug('  Upgrade_old_data API fails with ');
        debug('    x_msg_count     = '||l_err_count);
        debug('    x_msg_data      = '||l_err_data);
        debug('    x_return_status = '||l_err_status );
        RAISE fnd_api.g_exc_unexpected_error;

      END IF; --check of l_err_status


   END IF; -- l_upg_old_data = 'Y'


--    End If;/* l_build_count = 0 */

   l_stmt_num := 50;
   debug('  l_stmt_num:'||l_stmt_num);


    Insert_build_parameters(p_operating_unit => p_operating_unit,
                            p_from_date      => l_from_date,
                            p_to_date        => l_to_date,
                            x_msg_count      => l_err_count,
                            x_msg_data       => l_err_data,
                            x_return_status  => l_err_status
                            );

    IF l_err_status <>  FND_API.G_RET_STS_SUCCESS THEN
       IF l_exceptionLog THEN
          l_call_error := 'Insert_build_parameters API fails with '
                           ||'x_msg_count = '||to_char(l_err_count)
                           ||'x_msg_data = '||l_err_data
                           ||'x_return_status = '||l_err_status ;
       END IF;
       debug(l_call_error);
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    -- Added for bug 7528609 so that upgrade data is committed
    -- even if the request errors later while processing.
    -- This would prevent re-upgrade of old data in the next run
    -- and saves lot of time.
    IF l_upg_old_data = 'Y' THEN
       COMMIT;
       debug(' As upgrading of old data was successful,  Committed the upgrade data ');
    END IF;

    l_stmt_num := 60;
    debug('  l_stmt_num:'||l_stmt_num);


    /* pick up currency related stuff */

    SELECT NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
    INTO l_round_unit
    FROM fnd_currencies                   fc,
         gl_sets_of_books                gsb,
         financials_system_params_all    fsp
    WHERE fsp.org_id        = p_operating_unit
    AND fsp.set_of_books_id = gsb.set_of_books_id
    AND fc.currency_code    = gsb.currency_code;

    debug('  l_round_unit:'||l_round_unit);


    l_stmt_num := 70;
    debug('  l_stmt_num:'||l_stmt_num);

    Load_ap_po_data(p_operating_unit  => p_operating_unit,
                    p_from_date       => l_from_date,
                    p_to_date         => l_to_date,
                    p_round_unit      => l_round_unit,
                    x_msg_count       => l_err_count,
                    x_msg_data        => l_err_data,
                    x_return_status   => l_err_status
                    );

    IF l_err_status <>  FND_API.G_RET_STS_SUCCESS THEN

      debug('Load_ap_po_data API fails with ');
      debug('   x_msg_count     : '||l_err_count);
      debug('   x_msg_data      : '||l_err_data);
      debug('   x_return_status : '||l_err_status);
      RAISE fnd_api.g_exc_unexpected_error;

    END IF;


    l_stmt_num := 80;
    debug('   l_stmt_num:'||l_stmt_num);

    Load_ap_misc_data(p_operating_unit => p_operating_unit,
                      p_from_date      => l_from_date,
                      p_to_date        => l_to_date,
                      p_round_unit     => l_round_unit,
                      x_msg_count      => l_err_count,
                      x_msg_data       => l_err_data,
                      x_return_status  => l_err_status
                      );


    IF l_err_status <>  FND_API.G_RET_STS_SUCCESS THEN
      debug('Load_ap_misc_data API fails with ');
      debug('  x_msg_count :'||to_char(l_err_count));
      debug('  x_msg_data  :'||l_err_data);
      debug('  x_return_status :'||l_err_status);
      debug(l_call_error);
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;


    l_stmt_num := 90;
    debug('   l_stmt_num:'||l_stmt_num);


     --BUG#7384429
    OPEN c_chk_misc_inv(p_ou_id     => p_operating_unit,
                       p_from_date => l_from_date,
                       p_to_date   => l_to_date);
    FETCH c_chk_misc_inv INTO l_misc_inv;
    IF c_chk_misc_inv%NOTFOUND THEN
     l_misc_inv := 'N';
    END IF;
    CLOSE c_chk_misc_inv;

    debug('   l_misc_inv:'||l_misc_inv);

    IF l_misc_inv = 'Y' THEN

     Load_inv_misc_data(p_operating_unit  => p_operating_unit,
                       p_from_date       => l_from_date,
                       p_to_date         => l_to_date,
                       p_round_unit      => l_round_unit,
                       x_msg_count       => l_err_count,
                       x_msg_data        => l_err_data,
                       x_return_status   => l_err_status
                       );


      IF l_err_status <>  FND_API.G_RET_STS_SUCCESS THEN
        debug('Load_inv_misc_data API fails with ');
        debug('  x_msg_count     : '||l_err_count);
        debug('  x_msg_data      : '||l_err_data);
        debug('  x_return_status : '||l_err_status );
        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
   END IF;

    --- Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
       COMMIT WORK;
    END IF;

    debug('accrual_load-');

 EXCEPTION
 WHEN FND_API.g_exc_error THEN
   ROLLBACK;
   x_return_status := FND_API.g_ret_sts_error;
   debug('EXCEPTION FND_API.g_exc_error IN accrual_load');
   debug('l_stmt_num :'||l_stmt_num);
   FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );
   debug('x_msg_count:'||x_msg_count);
   debug('x_msg_data :'||SUBSTRB(x_msg_data,1,1000));

   l_conc_request := fnd_concurrent.set_completion_status('ERROR',SUBSTRB(x_msg_data,1,140)||' in accrual_load - statement:'||l_stmt_num);


 WHEN FND_API.g_exc_unexpected_error THEN
   ROLLBACK;
   x_return_status := FND_API.g_ret_sts_unexp_error ;
   debug('EXCEPTION FND_API.g_exc_unexpected_error IN accrual_load');
   debug('l_stmt_num :'||l_stmt_num);

   FND_MSG_PUB.count_and_get
               (  p_count => x_msg_count
                , p_data  => x_msg_data
                );
   debug('x_msg_count:'||x_msg_count);
   debug('x_msg_data :'||SUBSTRB(x_msg_data,1,1000));

   l_conc_request := fnd_concurrent.set_completion_status('ERROR',SUBSTRB(x_msg_data,1,140)||'accrual_load - statement:'||l_stmt_num);

 WHEN stop_here THEN

   ROLLBACK;
   x_return_status := FND_API.g_ret_sts_success;
   debug('Stop here IN accrual_load');
   debug('l_stmt_num :'||l_stmt_num);
   FND_MSG_PUB.count_and_get
             (  p_count => x_msg_count
              , p_data  => x_msg_data
              );

   l_conc_request := fnd_concurrent.set_completion_status('WARNING','STOP HERE in accrual_load at statement '||l_stmt_num);


 WHEN OTHERS THEN

    ROLLBACK;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    fnd_message.set_name('BOM','CST_UNEXPECTED');
    fnd_message.set_token('TOKEN',SUBSTRB(SQLERRM,1,180));
    debug('EXCEPTION OTHERS in accrual_load '||SUBSTRB(SQLERRM,1,180));
    debug('l_stmt_num:'||l_stmt_num);

    fnd_msg_pub.add;

    FND_MSG_PUB.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

    l_conc_request := fnd_concurrent.set_completion_status('ERROR',
           'EXCEPTION OTHERS in accrual_load '||SUBSTRB(SQLERRM,1,140)||' at statement '||l_stmt_num);

END accrual_load;

/*===========================================================================+
|                                                                            |
| Procedure Name : Upgrade_old_data                                          |
|                                                                            |
| Purpose        : This Procedure has all the necessary code to upgrade      |
|                  old write off data into the new tables.                   |
|                  This procedure upgrades PO,AP and Inventory Write off     |
|                  transactions from the old PO_ACCRUAL_WRITE_OFFS_ALL       |
|                  table into the new CST_WRITE_OFFS and                     |
|                  CST_WRITE_OFF_DETAILS table.This upgrade is done only     |
|                  for the very first run of the load program for the        |
|                  given OU.The old WIP write off data is not Upgraded.      |
|                                                                            |
| Called from    : Start_accrual_load Procedure                              |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_upg_from_date  IN   DATE      REQUIRED                 |
|                   p_upg_to_date    IN   DATE      REQUIRED                 |
|                                                                            |
| OUT            :  x_return_status  OUT  NOCOPY VARCHAR2                    |
|                   x_msg_count      OUT  NOCOPY NUMBER                      |
|                   x_msg_data       OUT  NOCOPY VARCHAR2                    |
|                                                                            |
| NOTES          :  None
|                   Modified multiple relevant queries to insert poh.vendor_id|
|                   from PO_Headers to make this process immune to vendor    |
|                   mismatch between AP, PO and Write_Offs. Bug 7213170      |
+===========================================================================*/

--BUG#7275286
PROCEDURE upgrade_old_data(p_operating_unit  IN  NUMBER,
                           p_upg_from_date   IN DATE,
                           p_upg_to_date     IN DATE,
                           x_msg_count       OUT NOCOPY NUMBER,
                           x_msg_data        OUT NOCOPY VARCHAR2,
                           x_return_status   OUT NOCOPY VARCHAR2)
IS

  l_stmt_num    NUMBER;
  l_old_ipv     VARCHAR2(100);
  l_old_erv     VARCHAR2(100);
  --{
  l_min_date    DATE;
  l_max_date    DATE;
  --}
  l_api_name    CONSTANT  VARCHAR2(30)  := 'Upgrade_old_data';
  l_full_name   CONSTANT  VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
  l_module      CONSTANT  VARCHAR2(60) := 'cst.plsql.'||l_full_name;

  l_uLog         CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog         CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);



BEGIN
   debug('upgrade_old_data+');
   debug('  p_operating_unit : ' || p_operating_unit);
   debug('  p_upg_from_date  : ' || TO_CHAR(p_upg_from_date,'YYYY/MM/DD HH24:MI:SS'));
   debug('  p_upg_to_date    : ' || TO_CHAR(p_upg_to_date,'YYYY/MM/DD HH24:MI:SS'));


   x_return_status := fnd_api.g_ret_sts_success;

   /* Upgrade PO data. We are joining on the sub ledger tables directly to get the entered amounts
      as data for pre 11.5.10 may not have the entered columns populated in the old write off table */

   l_stmt_num := 10;
   debug('  l_stmt_num:'||l_stmt_num);
   debug('  Upgrading WO Receiving data ');

   INSERT into cst_write_offs
   (write_off_id,
    transaction_date,
    accrual_account_id,
    offset_account_id,
    write_off_amount,
    entered_amount,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    transaction_type_code,
    po_distribution_id,
    inventory_transaction_id,
    invoice_distribution_id,
    reversal_id,
    reason_id,
    comments,
    inventory_item_id,
    vendor_id,
    destination_type_code,
    operating_unit_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date
    )
   SELECT DISTINCT pawo.write_off_id,
                   pawo.WRITE_OFF_GL_DATE,
                   pawo.accrual_account_id,
                   NULL,                     -- offset_account_id
                   -1 * pawo.TRANSACTION_AMOUNT,  -- Accounted_amount
                   -1 * NVL(pawo.entered_transaction_amount, sign(pawo.transaction_amount)* NVL(rrs.entered_dr,entered_cr)),
                   NVL(pawo.currency_code,rrs.currency_code),
                   NVL(pawo.currency_conversion_type,rrs.user_currency_conversion_type),
                   NVL(pawo.currency_conversion_rate,rrs.currency_conversion_rate),
                   NVL(pawo.currency_conversion_date,rrs.currency_conversion_date),
                   pawo.WRITE_OFF_CODE ,
                   pawo.PO_DISTRIBUTION_ID,
                   NULL,                    -- INV_TRANSACTION_ID
                   NULL,                    -- INVOICE_DISTRIBUTION_ID
                   null,
                   pawo.reason_id,
                   pawo.comments,
                   pawo.inventory_item_id,
                   poh.vendor_id,
                   nvl(pawo.destination_type_code,pod.destination_type_code),
                   pawo.org_id,
                   pawo.last_update_date,
                   pawo.last_updated_by,
                   pawo.last_update_login,
                   pawo.creation_date,
                   pawo.created_by,
                   pawo.request_id,
                   pawo.program_application_id,
                   pawo.program_id,
                   pawo.program_update_date
    FROM
          po_accrual_write_offs_all      pawo,
          rcv_receiving_sub_ledger       rrs,
          xla_distribution_links         xld, --BUG#7275286
          rcv_transactions               rt,
          po_headers_all                 poh
         ,cst_accrual_accounts           ca   --BUG#7528609
	 ,PO_distributions_all pod
    WHERE pawo.org_id                                 = p_operating_unit
    AND pawo.transaction_source_code                  = 'PO'
    AND pawo.po_transaction_id                        IS NOT NULL
    AND rrs.rcv_transaction_id                        = pawo.po_transaction_id
    AND rrs.rcv_transaction_id                        = rt.transaction_id
--{BUG#7528609
    AND rrs.code_combination_id                       = ca.accrual_account_id
    AND ca.operating_unit_id                          = p_operating_unit
--}
    AND poh.po_header_id                              = rt.po_header_id  /* Bug 7312170. Vendor mismatch fix */
    AND rt.transaction_date                     BETWEEN p_upg_from_date AND p_upg_to_date
    AND pawo.accrual_account_id                       = rrs.code_combination_id
    AND ABS(NVL(rrs.accounted_dr,rrs.accounted_cr))   = ABS(pawo.transaction_amount)
   --BUG#8666698: round precision limited to 20 in 11i po_accrual_reconciliation_temo
    AND ((ABS(ROUND(pawo.transaction_quantity,20))              = ABS(ROUND(rrs.source_doc_quantity,20)))
         OR pawo.transaction_quantity is NULL
        )
    AND xld.source_distribution_type                  = 'RCV_RECEIVING_SUB_LEDGER'
    AND xld.source_distribution_id_num_1              =  rrs.rcv_sub_ledger_id
    AND xld.application_id                            =  707
    and pod.po_distribution_id                        =rrs.reference3;

    debug('   Done upgrading Receiving data');


    l_stmt_num := 20;
    debug('  l_stmt_num :'||l_stmt_num);

    /* Upgrade old AP transactions */

    Select plu.displayed_field
    into l_old_ipv
    FROM   po_lookup_codes plu
    WHERE  plu.lookup_type  = 'ACCRUAL TYPE'
    AND    plu.lookup_code  = 'AP INVOICE PRICE VAR';

    l_stmt_num := 30;
    debug('  l_stmt_num :'||l_stmt_num);
    debug('  l_old_ipv :'||l_old_ipv);

    Select plu.displayed_field
    into   l_old_erv
    FROM   po_lookup_codes plu
    WHERE  plu.lookup_type  = 'ACCRUAL TYPE'
    AND    plu.lookup_code  = 'AP EXCHANGE RATE VAR';

    l_stmt_num := 40;
    debug('  l_stmt_num :'||l_stmt_num);
    debug('  l_old_erv :'||l_old_erv);
    debug('  Upgrading WO miscellenaous AP invoice 11i');

    INSERT into cst_write_offs
   (write_off_id,
    transaction_date,
    accrual_account_id,
    offset_account_id,
    write_off_amount,
    entered_amount,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    transaction_type_code,
    po_distribution_id,
    inventory_transaction_id,
    invoice_distribution_id,
    reversal_id,
    reason_id,
    comments,
    inventory_item_id,
    vendor_id,
    destination_type_code,
    operating_unit_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date
    )
    SELECT  pawo.write_off_id,
            pawo.write_off_gl_date,
            pawo.accrual_account_id,
            null,
            -1 * pawo.transaction_amount, /* Bug 6757017: In R12, the writeoff amount will have its sign reversed */
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /  /* Bug 6757017: In R12, the writeoff amount will have its sign reversed */
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            NULL,
            aida.invoice_distribution_id,
            null,
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            pawo.vendor_id,
            pawo.destination_type_code,
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date
      FROM
            po_accrual_write_offs_all      pawo,
            ap_invoice_distributions_all   aida,
            financials_system_params_all   fsp,
            gl_sets_of_books               gsob,
            fnd_currencies                 fc,
            ap_ae_lines_all                aal,
            xla_distribution_links         xld
           ,cst_accrual_accounts           ca
     WHERE  pawo.org_id                      = p_operating_unit
       AND  pawo.po_distribution_id          IS NULL        -- Misc Invoices
       AND  pawo.transaction_source_code     = 'AP'
       AND  pawo.invoice_id                  IS NOT NULL
       AND  aida.invoice_id                  = pawo.invoice_id
       AND  aida.accounting_date       BETWEEN p_upg_from_date AND p_upg_to_date
       AND  pawo.line_match_order            IS NOT NULL
       AND  aal.ae_line_id                   = pawo.line_match_order
      --{BUG#7528609
       AND  aal.code_combination_id          = ca.accrual_account_id
       AND  ca.operating_unit_id             = p_operating_unit
      --}
       AND  aida.invoice_distribution_id     = aal.source_id
       AND  fsp.org_id                       = pawo.org_id
       AND  fsp.set_of_books_id              = gsob.set_of_books_id
       AND  fc.currency_code                 = gsob.currency_code
       AND  xld.source_distribution_id_num_1 = aida.invoice_distribution_id
       AND  xld.source_distribution_type     = 'AP_INV_DIST'
       AND  xld.application_id               = 200
    GROUP BY pawo.write_off_id,
            pawo.write_off_gl_date,
            pawo.accrual_account_id,
            -1 * pawo.transaction_amount,
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            aida.invoice_distribution_id,
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            pawo.vendor_id,
            pawo.destination_type_code,
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date;


    debug('  Done with upgrading miscellenaous AP invoice 11i');


   /* Bug 6757017: The following query will upgrade write off date from 11.0 releases
      where the line_match_order would be null */

    l_stmt_num := 45;
    debug('  l_stmt_num :'||l_stmt_num);
    debug('  Upgrading WO miscellenaous AP invoice 11.0');

   INSERT into cst_write_offs
   (write_off_id,
    transaction_date,
    accrual_account_id,
    offset_account_id,
    write_off_amount,
    entered_amount,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    transaction_type_code,
    po_distribution_id,
    inventory_transaction_id,
    invoice_distribution_id,
    reversal_id,
    reason_id,
    comments,
    inventory_item_id,
    vendor_id,
    destination_type_code,
    operating_unit_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date
    )
    SELECT  --po_accrual_write_offs_s.nextval, --BUG#7950123
            pawo.write_off_id,
            pawo.write_off_gl_date,
            aal.code_combination_id, /* pawo.accrual_account_id,*/
            null,
            -1 * pawo.transaction_amount,
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            NULL,
            aida.invoice_distribution_id,
            null,
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            pawo.vendor_id,
            pawo.destination_type_code,
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date
      FROM
            po_accrual_write_offs_all     pawo,
            ap_invoice_distributions_all  aida,
            financials_system_params_all  fsp,
            gl_sets_of_books              gsob,
            fnd_currencies                fc,
            ap_ae_lines_all               aal,
            cst_accrual_accounts          caa,
            xla_distribution_links        xld
     WHERE  pawo.org_id                      = p_operating_unit
       AND  pawo.po_distribution_id          IS NULL        -- Misc Invoices
       AND  pawo.transaction_source_code     = 'AP'
       AND  pawo.invoice_id                  IS NOT NULL
       AND  aida.invoice_id                  = pawo.invoice_id
       AND  aida.invoice_line_number         = pawo.invoice_line_num
       AND  aida.accounting_date       BETWEEN p_upg_from_date AND p_upg_to_date
       AND  pawo.line_match_order            IS NULL
       AND  aal.code_combination_id          = caa.accrual_account_id
       AND  caa.operating_unit_id            = p_operating_unit
       AND  aida.invoice_distribution_id     = aal.source_id
       AND  aal.source_table                 = 'AP_INVOICE_DISTRIBUTIONS'
       AND  fsp.org_id                       = pawo.org_id
       AND  fsp.set_of_books_id              = gsob.set_of_books_id
       AND  fc.currency_code                 = gsob.currency_code
       AND  xld.source_distribution_id_num_1 = aida.invoice_distribution_id
       AND  xld.source_distribution_type     = 'AP_INV_DIST'
       AND  xld.application_id               = 200
       --{BUG#7950123
       GROUP BY    pawo.write_off_id,
            pawo.write_off_gl_date,
            aal.code_combination_id,
            -1 * pawo.transaction_amount,
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            aida.invoice_distribution_id,
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            pawo.vendor_id,
            pawo.destination_type_code,
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date;
            --}

    debug('  Done with upgrading miscellenaous AP Invoice 11.0');


    l_stmt_num := 50;
    debug('  l_stmt_num :'||l_stmt_num);
    debug('  Upgrading WO regular AP INVOICE data 11i');

   INSERT into cst_write_offs
   (write_off_id,
    transaction_date,
    accrual_account_id,
    offset_account_id,
    write_off_amount,
    entered_amount,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    transaction_type_code,
    po_distribution_id,
    inventory_transaction_id,
    invoice_distribution_id,
    reversal_id,
    reason_id,
    comments,
    inventory_item_id,
    vendor_id,
    destination_type_code,
    operating_unit_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date
    )
    SELECT  pawo.write_off_id,
            pawo.write_off_gl_date,
            pawo.accrual_account_id,
            null,
            -1 * pawo.transaction_amount, /* Bug 6757017: In R12, the writeoff amount will have its sign reversed */
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /  /* Bug 6757017: In R12, the writeoff amount will have its sign reversed */
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            NULL,
            Decode(pawo.accrual_code,
                   l_old_ipv,aida.invoice_distribution_id,
                   l_old_erv,aida.invoice_distribution_id,
                   decode(pod.po_release_id,
                          NULL,Decode(NVL(poh.consigned_consumption_flag,'N'),
                                      'Y',aida.invoice_distribution_id,
                                      NULL
                                     ),
                          Decode(NVL(pra.consigned_consumption_flag,'N'),
                                 'Y',aida.invoice_distribution_id,
                                 NULL
                                 )
                         )
                   ),
            null,
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            poh.vendor_id,
            nvl(pawo.destination_type_code,pod.destination_type_code),
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date
      FROM
            po_accrual_write_offs_all    pawo,
            po_distributions_all         pod,
            po_releases_all              pra,
            po_headers_all               poh,
            ap_invoice_distributions_all aida,
            financials_system_params_all  fsp,
            gl_sets_of_books             gsob,
            fnd_currencies                 fc,
            ap_ae_lines                   aal,
            cst_accrual_accounts          caa,
            xla_distribution_links        xld,
            xla_ae_lines                  xal
     WHERE  pawo.org_id                      = p_operating_unit
       AND  pawo.po_distribution_id          IS NOT NULL        -- Reg Invoices and consigned
       AND  pod.po_distribution_id           = pawo.po_distribution_id
       AND  pra.po_release_id(+)             = pod.po_release_id
       AND  poh.po_header_id                 = pod.po_header_id
       AND  pawo.transaction_source_code     = 'AP'
       AND  pawo.invoice_id                  IS NOT NULL
       AND  aida.invoice_id                  = pawo.invoice_id
       AND  pawo.line_match_order            IS NOT NULL
       AND  aal.ae_line_id                   = pawo.line_match_order
       AND  aida.invoice_distribution_id     = aal.source_id
       AND  aida.accounting_date       BETWEEN p_upg_from_date AND p_upg_to_date
       AND  fsp.org_id                       = pawo.org_id
       AND  fsp.set_of_books_id              = gsob.set_of_books_id
       AND  fc.currency_code                 = gsob.currency_code
       AND  xld.source_distribution_id_num_1 = aida.invoice_distribution_id
       AND  xld.source_distribution_type     = 'AP_INV_DIST'
       AND  xld.application_id               = 200
       AND  xld.ae_header_id                 = xal.ae_header_id
       AND  xld.ae_line_num                  = xal.ae_line_num
       AND  xal.application_id               = 200
       AND  caa.operating_unit_id            = p_operating_unit
       AND  xal.code_combination_id          = caa.accrual_account_id
       -- Bug 7528609. Added the Group by clause to prevent unique constraint error
       -- This could cause perf issue but is the best fix option available.
     GROUP BY pawo.write_off_id,
              pawo.write_off_gl_date,
              pawo.accrual_account_id,
              -1 * pawo.transaction_amount,
              -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /
                  NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
              aal.currency_code,
              aal.currency_conversion_type,
              aal.currency_conversion_rate,
              aal.currency_conversion_date,
              pawo.write_off_code,
              pawo.po_distribution_id,
              Decode(pawo.accrual_code,
                     l_old_ipv,aida.invoice_distribution_id,
                     l_old_erv,aida.invoice_distribution_id,
                     decode(pod.po_release_id,
                            NULL,Decode(NVL(poh.consigned_consumption_flag,'N'),
                                        'Y',aida.invoice_distribution_id,
                                        NULL
                                       ),
                            Decode(NVL(pra.consigned_consumption_flag,'N'),
                                   'Y',aida.invoice_distribution_id,
                                   NULL
                                   )
                           )
                     ),
               pawo.reason_id,
               pawo.comments,
               pawo.inventory_item_id,
               poh.vendor_id,
               nvl(pawo.destination_type_code,pod.destination_type_code),
               pawo.org_id,
               pawo.last_update_date,
               pawo.last_updated_by,
               pawo.last_update_login,
               pawo.creation_date,
               pawo.created_by,
               pawo.request_id,
               pawo.program_application_id,
               pawo.program_id,
               pawo.program_update_date;

   debug('  Done with regular AP INVOICE data 11i');

   l_stmt_num := 55;
   debug('  l_stmt_num :'||l_stmt_num);
   debug('  Upgrading WO AP INVOICE data 11.0');

   /* Bug 6757017: The following query will upgrade write off date from 11.0 releases
      where the line_match_order wouild be null */
   INSERT into cst_write_offs
   (write_off_id,
    transaction_date,
    accrual_account_id,
    offset_account_id,
    write_off_amount,
    entered_amount,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    transaction_type_code,
    po_distribution_id,
    inventory_transaction_id,
    invoice_distribution_id,
    reversal_id,
    reason_id,
    comments,
    inventory_item_id,
    vendor_id,
    destination_type_code,
    operating_unit_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date
    )
    SELECT  --po_accrual_write_offs_s.nextval, --BUG#7950123
            pawo.write_off_id,
            pawo.write_off_gl_date,
            aal.code_combination_id, /*pawo.accrual_account_id,*/
            null,
            -1 * pawo.transaction_amount,
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            NULL,
            Decode(aal.ae_line_type_code,
                   'IPV',aida.invoice_distribution_id,
                   'ERV',aida.invoice_distribution_id,
                   decode(pod.po_release_id,
                          NULL,Decode(NVL(poh.consigned_consumption_flag,'N'),
                                      'Y',aida.invoice_distribution_id,
                                      NULL
                                     ),
                          Decode(NVL(pra.consigned_consumption_flag,'N'),
                                 'Y',aida.invoice_distribution_id,
                                 NULL
                                 )
                         )
                   ),
            null,
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            poh.vendor_id,
            nvl(pawo.destination_type_code,pod.destination_type_code),
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date
      FROM
            po_accrual_write_offs_all    pawo,
            po_distributions_all         pod,
            po_releases_all              pra,
            po_headers_all               poh,
            ap_invoice_distributions_all aida,
            financials_system_params_all  fsp,
            gl_sets_of_books             gsob,
            fnd_currencies                 fc,
            ap_ae_lines                   aal,
            cst_accrual_accounts          caa,
            xla_distribution_links        xld
     WHERE  pawo.org_id                      = p_operating_unit
       AND  pawo.po_distribution_id          IS NOT NULL        -- Reg Invoices and consigned
       AND  pod.po_distribution_id           = pawo.po_distribution_id
       AND  pra.po_release_id(+)             = pod.po_release_id
       AND  poh.po_header_id                 = pod.po_header_id
       AND  pawo.transaction_source_code     = 'AP'
       AND  pawo.invoice_id                  IS NOT NULL
       AND  aida.invoice_id                  = pawo.invoice_id
       AND  aida.invoice_line_number         = pawo.invoice_line_num
       AND  aida.accounting_date       BETWEEN p_upg_from_date AND p_upg_to_date
       AND  pawo.line_match_order            IS NULL
       AND  aal.code_combination_id          = caa.accrual_account_id
       AND  caa.operating_unit_id            =  p_operating_unit
       AND  aida.invoice_distribution_id     = aal.source_id
       AND  aal.source_table                 = 'AP_INVOICE_DISTRIBUTIONS'
       AND  fsp.org_id                       = pawo.org_id
       AND  fsp.set_of_books_id              = gsob.set_of_books_id
       AND  fc.currency_code                 = gsob.currency_code
       AND  xld.source_distribution_id_num_1 = aida.invoice_distribution_id
       AND  xld.source_distribution_type     = 'AP_INV_DIST'
       AND  xld.application_id               = 200
--{BUG#7950123
    GROUP BY  pawo.write_off_id,
            pawo.write_off_gl_date,
            aal.code_combination_id,
            -1 * pawo.transaction_amount,
            -1 * Round((NVL(aal.entered_dr,0)- NVL(aal.entered_cr,0)) /
                NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0)))
                 ) * NVL(fc.minimum_accountable_unit,power(10,NVL(-fc.precision,0))),
            aal.currency_code,
            aal.currency_conversion_type,
            aal.currency_conversion_rate,
            aal.currency_conversion_date,
            pawo.write_off_code,
            pawo.po_distribution_id,
            Decode(aal.ae_line_type_code,
                   'IPV',aida.invoice_distribution_id,
                   'ERV',aida.invoice_distribution_id,
                   decode(pod.po_release_id,
                          NULL,Decode(NVL(poh.consigned_consumption_flag,'N'),
                                      'Y',aida.invoice_distribution_id,
                                      NULL
                                     ),
                          Decode(NVL(pra.consigned_consumption_flag,'N'),
                                 'Y',aida.invoice_distribution_id,
                                 NULL
                                 )
                         )
                   ),
            pawo.reason_id,
            pawo.comments,
            pawo.inventory_item_id,
            poh.vendor_id,
            nvl(pawo.destination_type_code,pod.destination_type_code),
            pawo.org_id,
            pawo.last_update_date,
            pawo.last_updated_by,
            pawo.last_update_login,
            pawo.creation_date,
            pawo.created_by,
            pawo.request_id,
            pawo.program_application_id,
            pawo.program_id,
            pawo.program_update_date;


     debug('  Done with regular AP INVOICE data 11.0');
     l_stmt_num := 60;
     debug('  l_stmt_num :'||l_stmt_num);
     debug('  Upgrading WO miscellenaous INV data');

    /* Upgrade MTA data */


       /* Now Insert these values into the new write off table. For MISC INV txns, we are not calculating the
          entered amount for pre 11.5.10 txns as it is not technically feasible because of the way
          we store the currency info in MTA for the txns.So we will be inserting NULL as entered amounts
          for pre 11.5.10 txns */

       INSERT into cst_write_offs
       (write_off_id,
        transaction_date,
        accrual_account_id,
        offset_account_id,
        write_off_amount,
        entered_amount,
        currency_code,
        currency_conversion_type,
        currency_conversion_rate,
        currency_conversion_date,
        transaction_type_code,
        po_distribution_id,
        inventory_transaction_id,
        reason_id,
        comments,
        inventory_item_id,
        vendor_id,
        destination_type_code,
        operating_unit_id,
        last_update_date,
        last_updated_by,
        last_update_login,
        creation_date,
        created_by,
        request_id,
        program_application_id,
        program_id,
        program_update_date
        )
       SELECT pawo.write_off_id,
              pawo.write_off_gl_date,
              pawo.accrual_account_id,
              NULL,
              -1 * pawo.transaction_amount,
              -1 * pawo.entered_transaction_amount,
              pawo.currency_code,
              pawo.currency_conversion_type,
              pawo.currency_conversion_rate,
              pawo.currency_conversion_date,
              pawo.write_off_code,
              pawo.po_distribution_id,
              pawo.inv_transaction_id,
              pawo.reason_id,
              pawo.comments,
              pawo.inventory_item_id,
              pawo.vendor_id,
              pawo.destination_type_code,
              pawo.org_id,
              pawo.last_update_date,
              pawo.last_updated_by,
              pawo.last_update_login,
              pawo.creation_date,
              pawo.created_by,
              pawo.request_id,
              pawo.program_application_id,
              pawo.program_id,
              pawo.program_update_date
        FROM  po_accrual_write_offs_all pawo,
              mtl_transaction_accounts  mta,
              xla_distribution_links    xld
             ,cst_accrual_accounts      ca   --BUG#7528609
       WHERE  pawo.transaction_source_code     = 'INV'
         AND  pawo.org_id                      = p_operating_unit
         AND  pawo.inv_transaction_id          = mta.transaction_id
         --{BUG#7528609
         AND  mta.reference_account            = ca.accrual_account_id
         AND  ca.operating_unit_id             = p_operating_unit
         --}
         AND  mta.transaction_date       BETWEEN p_upg_from_date AND p_upg_to_date
         AND  xld.source_distribution_id_num_1 = mta.inv_sub_ledger_id
         AND  xld.source_distribution_type     = 'MTL_TRANSACTION_ACCOUNTS'
         AND  xld.application_id               = 707
      GROUP BY  pawo.write_off_id,
              pawo.write_off_gl_date,
              pawo.accrual_account_id,
              pawo.transaction_amount,
              pawo.entered_transaction_amount,
              pawo.currency_code,
              pawo.currency_conversion_type,
              pawo.currency_conversion_rate,
              pawo.currency_conversion_date,
              pawo.write_off_code,
              pawo.po_distribution_id,
              pawo.inv_transaction_id,
              pawo.reason_id,
              pawo.comments,
              pawo.inventory_item_id,
              pawo.vendor_id,
              pawo.destination_type_code,
              pawo.org_id,
              pawo.last_update_date,
              pawo.last_updated_by,
              pawo.last_update_login,
              pawo.creation_date,
              pawo.created_by,
              pawo.request_id,
              pawo.program_application_id,
              pawo.program_id,
              pawo.program_update_date;

     debug('    Done upgrading Inventory Data' );


     l_stmt_num := 70;
     debug('   l_stmt_num :'||l_stmt_num);
     debug('  Upgrading miscellenaous INV WO detail data');


    /* Now insert into the cst_write_off details table */
    Insert into cst_write_off_details
    (
     write_off_id,
     rcv_transaction_id,
     inventory_transaction_id,
     invoice_distribution_id,
     transaction_type_code,
     transaction_date,
     amount,
     entered_amount,
     quantity,
     currency_code,
     currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     inventory_organization_id,
     operating_unit_id,
     last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     request_id,
     program_application_id,
     program_id,
     program_update_date
--{Need original XLA accounting entries
   , ae_header_id
   , ae_line_num
--}
     )
    Select cwo.write_off_id,
           pawo.po_transaction_id,
           cwo.inventory_transaction_id,
           cwo.invoice_distribution_id,
           to_char(pawo.inv_transaction_type_id),
           cwo.transaction_date,
           DECODE(cwo.transaction_type_code,
                'REVERSE WRITE OFF', cwo.write_off_amount,-1 * cwo.write_off_amount),
           DECODE(cwo.transaction_type_code,
                'REVERSE WRITE OFF', cwo.entered_amount, -1 * cwo.entered_amount),
           pawo.transaction_quantity,
           cwo.currency_code,
           cwo.currency_conversion_type,
           cwo.currency_conversion_rate,
           cwo.currency_conversion_date,
           pawo.transaction_organization_id,
           cwo.operating_unit_id,
           cwo.last_update_date,
           cwo.last_updated_by,
           cwo.last_update_login,
           cwo.creation_date,
           cwo.created_by,
           cwo.request_id,
           cwo.program_application_id,
           cwo.program_id,
           cwo.program_update_date
--{Need the original XLA entries
          ,xld.ae_header_id
          ,xld.ae_line_num
--}
     FROM  cst_write_offs               cwo,
           po_accrual_write_offs_all    pawo,
           mtl_transaction_accounts     mta,
           xla_distribution_links       xld,
           cst_accrual_accounts         ca    --BUG7528609
    WHERE  pawo.org_id                      = p_operating_unit
      AND  pawo.transaction_source_code     ='INV'
      AND  cwo.write_off_id                 = pawo.write_off_id
      AND  pawo.inv_transaction_id          = mta.transaction_id
      --{BUG#7528609
      AND  ca.operating_unit_id             = p_operating_unit
      AND  mta.reference_account            = ca.accrual_account_id
      --}
      AND  mta.transaction_date      BETWEEN p_upg_from_date AND p_upg_to_date
      AND  xld.source_distribution_id_num_1 = mta.inv_sub_ledger_id
      AND  xld.source_distribution_type     = 'MTL_TRANSACTION_ACCOUNTS'
      AND  xld.application_id               = 707;


    debug('   Done Updating the write off details for INV');

    l_stmt_num := 75;
    debug('   l_stmt_num :'||l_stmt_num);
    debug('   Updating the WO details for PO RCV');

    /* Insert details for PO data */
    Insert into cst_write_off_details
    (
     write_off_id,
     rcv_transaction_id,
     inventory_transaction_id,
     invoice_distribution_id,
     transaction_type_code,
     transaction_date,
     amount,
     entered_amount,
     quantity,
     currency_code,
     currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     inventory_organization_id,
     operating_unit_id,
     last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     request_id,
     program_application_id,
     program_id,
     program_update_date
--{Need original XLA accounting entries
   , ae_header_id
   , ae_line_num
--}
     )
    Select cwo.write_off_id,
           pawo.po_transaction_id,
           cwo.inventory_transaction_id,
           cwo.invoice_distribution_id,
           plc.lookup_code,
           cwo.transaction_date,
           DECODE(cwo.transaction_type_code,
                'REVERSE WRITE OFF', cwo.write_off_amount,-1 * cwo.write_off_amount),
           DECODE(cwo.transaction_type_code,
                'REVERSE WRITE OFF', cwo.entered_amount, -1 * cwo.entered_amount),
           pawo.transaction_quantity,
           cwo.currency_code,
           cwo.currency_conversion_type,
           cwo.currency_conversion_rate,
           cwo.currency_conversion_date,
           pawo.transaction_organization_id,
           cwo.operating_unit_id,
           cwo.last_update_date,
           cwo.last_updated_by,
           cwo.last_update_login,
           cwo.creation_date,
           cwo.created_by,
           cwo.request_id,
           cwo.program_application_id,
           cwo.program_id,
           cwo.program_update_date
--{Need the original XLA entries
          ,xld.ae_header_id
          ,xld.ae_line_num
--}
     FROM  cst_write_offs               cwo,
           po_accrual_write_offs_all    pawo,
           po_lookup_codes              plc,
           rcv_receiving_sub_ledger     rrs,
           rcv_transactions             rt,
           xla_distribution_links       xld,
           cst_accrual_accounts         ca   --BUG#7528609
    WHERE  pawo.org_id                         = p_operating_unit
      AND  pawo.transaction_source_code        = 'PO'
      AND  cwo.write_off_id                    = pawo.write_off_id
      AND  plc.displayed_field                 = pawo.accrual_code
      AND  plc.lookup_type                     = 'RCV TRANSACTION TYPE'
      AND  rrs.rcv_transaction_id              = pawo.po_transaction_id
      AND  rrs.rcv_transaction_id              = rt.transaction_id
      --{BUG#7528609
      AND  ca.operating_unit_id                = p_operating_unit
      AND  rrs.code_combination_id             = ca.accrual_account_id
      --}
      AND  rt.transaction_date          BETWEEN p_upg_from_date AND p_upg_to_date
      AND  xld.source_distribution_type        = 'RCV_RECEIVING_SUB_LEDGER'
      AND  xld.source_distribution_id_num_1    =  rrs.rcv_sub_ledger_id
      AND  xld.application_id                  =  707;

      debug('     Done Updating the write off details for PO RCV' );


    l_stmt_num := 80;
    debug('   l_stmt_num :'||l_stmt_num);
    debug('   Updating WO details for AP Invoice');


    Insert into cst_write_off_details
    (
     write_off_id,
     rcv_transaction_id,
     inventory_transaction_id,
     invoice_distribution_id,
     transaction_type_code,
     transaction_date,
     amount,
     entered_amount,
     quantity,
     currency_code,
     currency_conversion_type,
     currency_conversion_rate,
     currency_conversion_date,
     inventory_organization_id,
     operating_unit_id,
     last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by,
     request_id,
     program_application_id,
     program_id,
     program_update_date
--{Need original XLA accounting entries
   , ae_header_id
   , ae_line_num
--}
     )
    SELECT cwo.write_off_id,
           pawo.po_transaction_id,
           cwo.inventory_transaction_id,
           aida.invoice_distribution_id,
           plc.lookup_code,
           cwo.transaction_date,
           DECODE(cwo.transaction_type_code, 'REVERSE WRITE OFF',
		          cwo.write_off_amount,-1 * cwo.write_off_amount),
           DECODE(cwo.transaction_type_code, 'REVERSE WRITE OFF',
		          cwo.entered_amount, -1 * cwo.entered_amount),
           pawo.transaction_quantity,
           cwo.currency_code,
           cwo.currency_conversion_type,
           cwo.currency_conversion_rate,
           cwo.currency_conversion_date,
           pawo.transaction_organization_id,
           cwo.operating_unit_id,
           cwo.last_update_date,
           cwo.last_updated_by,
           cwo.last_update_login,
           cwo.creation_date,
           cwo.created_by,
           cwo.request_id,
           cwo.program_application_id,
           cwo.program_id,
           cwo.program_update_date
--{ Need the original XLA entries
          ,MAX(xld.ae_header_id)
          ,MAX(xld.ae_line_num)
--}
     FROM  cst_write_offs                cwo,
           po_accrual_write_offs_all     pawo,
           po_lookup_codes               plc,
           ap_invoice_distributions_all  aida,
           ap_ae_lines_all               aal,
           cst_accrual_accounts          ca,  --BUG#7528609
           xla_distribution_links        xld
          ,xla_ae_lines                  xlal  --XLD AP <=> n XLA AE line AP with different GL Accounts
    WHERE pawo.org_id                      = p_operating_unit
      AND pawo.transaction_source_code     = 'AP'
      AND cwo.write_off_id                 = pawo.write_off_id
      AND plc.lookup_type                  = 'ACCRUAL TYPE'
      AND plc.displayed_field              = pawo.accrual_code
      AND pawo.invoice_id                  IS NOT NULL
      AND aida.invoice_id                  = pawo.invoice_id
      AND aida.accounting_date       BETWEEN p_upg_from_date AND p_upg_to_date
      --{BUG#8533705
      -- AND aida.distribution_line_number    = pawo.invoice_line_num
      --}
      AND NVL(pawo.line_match_order,aal.ae_line_id)            IS NOT NULL
      AND aal.ae_line_id                   = NVL(pawo.line_match_order,aal.ae_line_id)
      AND cwo.invoice_distribution_id      = aida.invoice_distribution_id
      --{BUG#7528609
      AND ca.operating_unit_id             = p_operating_unit
      AND aal.code_combination_id          = ca.accrual_account_id
      --}
      AND aida.invoice_distribution_id     = aal.source_id
      AND xld.source_distribution_id_num_1 = aida.invoice_distribution_id
      AND xld.source_distribution_type     = 'AP_INV_DIST'
      AND xld.application_id               = 200
      AND xlal.application_id              = 200
      AND xlal.ae_header_id                = xld.ae_header_id
      AND xlal.ae_line_num                 = xld.ae_line_num
      AND xlal.accounting_class_code NOT IN ('LIABILITY')
      AND (   (aida.po_distribution_id IS NULL )
           OR (xlal.accounting_class_code in ('IPV','EXCHANGE_RATE_VARIANCE','TRV','TIPV','TERV'
                                             ,'ACCRUAL','ITEM EXPENSE'))
           OR EXISTS   (     SELECT  1
                               FROM  po_releases_all      pra,
                                     po_distributions_all pod
                              WHERE  pod.po_distribution_id                  = aida.po_distribution_id
                                AND  pod.po_release_id IS NOT NULL
                                AND  pra.po_release_id                       =  pod.po_release_id
                                AND  NVL(pra.consigned_consumption_flag,'N') = 'Y'
                        )
           OR EXISTS   (    SELECT 1
                              FROM po_headers_all       poh,
                                   po_distributions_all pod
                             WHERE pod.po_distribution_id                   = aida.po_distribution_id
                               AND pod.po_release_id IS NULL
                               AND poh.po_header_id                         = pod.po_header_id
                               AND NVL(poh.consigned_consumption_flag,'N')  = 'Y'
                        )
             )
     GROUP BY cwo.write_off_id,
           pawo.po_transaction_id,
           cwo.inventory_transaction_id,
           aida.invoice_distribution_id,
           plc.lookup_code,
           cwo.transaction_date,
           DECODE(cwo.transaction_type_code, 'REVERSE WRITE OFF',
		          cwo.write_off_amount,-1 * cwo.write_off_amount),
           DECODE(cwo.transaction_type_code, 'REVERSE WRITE OFF',
		          cwo.entered_amount, -1 * cwo.entered_amount),
           pawo.transaction_quantity,
           cwo.currency_code,
           cwo.currency_conversion_type,
           cwo.currency_conversion_rate,
           cwo.currency_conversion_date,
           pawo.transaction_organization_id,
           cwo.operating_unit_id,
           cwo.last_update_date,
           cwo.last_updated_by,
           cwo.last_update_login,
           cwo.creation_date,
           cwo.created_by,
           cwo.request_id,
           cwo.program_application_id,
           cwo.program_id,
           cwo.program_update_date;

      debug('   Done updating the Write of details table for AP data');

     debug('Upgrade_old_data -');

 EXCEPTION

 WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    debug('EXCEPTION OTHERS in Upgrade_old_data :'|| l_stmt_num || ' - ' || substrb(SQLERRM,1,180));
    fnd_message.set_name('BOM','CST_UNEXPECTED');
    fnd_message.set_token('TOKEN',substrb(SQLERRM,1,180));
    debug('l_stmt_num:'||l_stmt_num);

    fnd_msg_pub.add;

    FND_MSG_PUB.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );


END Upgrade_old_data;

/*===========================================================================+
|                                                                            |
| Procedure Name : Load_ap_misc_data                                         |
|                                                                            |
| Purpose        : This Procedure loads all the AP Miscellaneous Invoice     |
|                  data that hits the accrual account.This procedure also    |
|                  loads the IPV and ERV data and the Invoice data that is   |
|                  matched to the CONSIGNMENT PO. Only the Invoice data      |
|                  that has not been written off or for which the write offs |
|                  have been revered, is loaded into the reconciliation table|
|                                                                            |
| Called from    : Start_accrual_load Procedure                              |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_from_date      IN   VARCHAR2  can be NULL              |
|                   p_to_date        IN   VARCHAR2  can be NULL              |
|                   p_round_unit     IN   NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  x_return_status  OUT  NOCOPY VARCHAR2                    |
|                   x_msg_count      OUT  NOCOPY NUMBER                      |
|                   x_msg_data       OUT  NOCOPY VARCHAR2                    |
|                                                                            |
| NOTES          :  None                                                     |
+===========================================================================*/


Procedure Load_ap_misc_data(p_operating_unit   IN NUMBER,
                            p_from_date        IN DATE,
                            p_to_date          IN DATE,
                            p_round_unit       IN NUMBER,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data        OUT NOCOPY VARCHAR2,
                            x_return_status   OUT NOCOPY VARCHAR2
                            )

IS

  l_stmt_num NUMBER;
  l_build_id                NUMBER;
  l_last_update_date        DATE;
  l_last_updated_by         NUMBER;
  l_last_update_login       NUMBER;
  l_creation_date           DATE;
  l_created_by              NUMBER;
  l_request_id              NUMBER;
  l_program_application_id  NUMBER;
  l_program_id              NUMBER;
  l_program_update_date     DATE;

  l_api_name    CONSTANT  VARCHAR2(30)  := 'Load_ap_misc_data';
  l_full_name   CONSTANT  VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
  l_module      CONSTANT  VARCHAR2(60)  := 'cst.plsql.'||l_full_name;

  l_uLog         CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog         CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN
   debug('Load_ap_misc_data +');
   debug('  p_operating_unit : ' || p_operating_unit);
   debug('  p_from_date      : ' || to_char(p_from_date,'DD-MON-YYYY HH24:MI:SS'));
   debug('  p_to_date        : ' || to_char(p_to_date,'DD-MON-YYYY HH24:MI:SS'));
   debug('  p_round_unit     : ' || p_round_unit);


   l_stmt_num := 10;
   debug('  l_stmt_num :'||l_stmt_num );

    x_return_status := fnd_api.g_ret_sts_success;

   xla_security_pkg.set_security_context(p_application_id => 200);

   /* Get all the CONC WHO columns */

     SELECT crb.build_id,
            crb.last_update_date,
            crb.last_updated_by,
            crb.last_update_login,
            crb.creation_date,
            crb.created_by,
            crb.request_id,
            crb.program_application_id,
            crb.program_id,
            crb.program_update_date
       INTO l_build_id,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            l_creation_date,
            l_created_by,
            l_request_id,
            l_program_application_id,
            l_program_id,
            l_program_update_date
       FROM cst_reconciliation_build crb
      WHERE crb.request_id = FND_GLOBAL.CONC_REQUEST_ID;

   debug('   l_build_id:'||l_build_id);

   l_stmt_num := 15;
   debug('  l_stmt_num :'||l_stmt_num );


   /* Delete data from misc reconciliation table for the time range */
   DELETE from cst_misc_reconciliation
    WHERE transaction_date between p_from_date AND p_to_date
      AND operating_unit_id = p_operating_unit;

   debug('  Nb rows deleted from cst_misc_reconciliation '||SQL%ROWCOUNT);

   l_stmt_num := 25;
   debug('  l_stmt_num :'||l_stmt_num );


   /* For IPV and ERV lines, there will be a po_dist_id.So we have to handle them seperately. For Consigned AP invoices
      there will be a po_dist_id.So we need to handle them separetely by joing to poll and checking the consigned flag */

   /* When AP creates accounting, it is possible for the line types to be merged thereby creating a summarized
      line in XAL.So one line in XAL can point to one or more lines in XDL (i.e one or different invoice distributions.
      So we need to pick up the amount from XDL from the unrounded columns.But even though the columns are called unrounded,
      they are actually rounded amounts since AP always passes rounded amounts to SLA and no further rounding in SLA is
      possible. */


   debug('  Nb rows deleted from cst_misc_reconciliation '||SQL%ROWCOUNT);

   debug('  Inserting into cst_misc_reconciliation');
   Insert into cst_misc_reconciliation
   (
    transaction_date,
    amount,
    entered_amount,
    quantity,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    invoice_distribution_id,
    po_distribution_id,
    inventory_transaction_id,
    accrual_account_id,
    transaction_type_code,
    inventory_item_id,
    vendor_id,
    inventory_organization_id,
    operating_unit_id,
    build_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    Ae_header_id,
    Ae_line_num
   )
    SELECT /*+ LEADING(caa) */
            xal.accounting_date,
            ROUND((NVL(xdl.unrounded_accounted_dr,0) - NVL(xdl.unrounded_accounted_cr,0)) / p_round_unit) * p_round_unit,
            ROUND((NVL(xdl.unrounded_entered_dr,0) - NVL(xdl.unrounded_entered_cr,0)) / p_round_unit) * p_round_unit,
            decode(aida.corrected_invoice_dist_id,
                        NULL,round(NVL(aida.quantity_invoiced,0),20),
                        NULL
                    ),
            xal.currency_code,
            xal.currency_conversion_type,
            xal.currency_conversion_rate,
            xal.currency_conversion_date,
            aida.invoice_distribution_id,
            aida.po_distribution_id,
            NULL,            -- Inventory_transaction_id
            xal.code_combination_id,
            Decode (aida.line_type_lookup_code,
                    'IPV','AP INVOICE PRICE VAR',
                    'ERV','AP EXCHANGE RATE VAR',
                    'TERV','TERV',
                    'TIPV','TIPV',
                    'TRV','TRV',
                    Decode(aida.po_distribution_id,
                           NULL,'AP NO PO',
                           'CONSIGNMENT'
                           )
                    ),       -- transaction_type_code
            pol.item_id,            -- Inventory_item_id
--{BUG#7554120
--            apia.vendor_id,
            NVL(poh.vendor_id,apia.vendor_id),
--}
            NULL,            -- Inventory_organization_id
            p_operating_unit,
            l_build_id,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            l_creation_date,
            l_created_by,
            l_request_id,
            l_program_application_id,
            l_program_id,
            l_program_update_date,
            xal.ae_header_id,
            xal.ae_line_num
    FROM    ap_invoices_all                apia,
    --{BUG#8410174
    --            ap_invoice_distributions_all   aida,
            (SELECT 'APID'  tn
                   ,invoice_id
                   ,invoice_distribution_id
                   ,accounting_date
                   ,corrected_invoice_dist_id
                   ,quantity_invoiced
                   ,MATCHED_UOM_LOOKUP_CODE
                   ,po_distribution_id
                   ,rcv_transaction_id
                   ,LINE_TYPE_LOOKUP_CODE
                   ,org_id
               FROM ap_invoice_distributions_all
              UNION ALL
             SELECT 'APSTD' tn
                   ,invoice_id
                   ,invoice_distribution_id
                   ,accounting_date
                   ,corrected_invoice_dist_id
                   ,quantity_invoiced
                   ,MATCHED_UOM_LOOKUP_CODE
                   ,po_distribution_id
                   ,rcv_transaction_id
                   ,LINE_TYPE_LOOKUP_CODE
                   ,org_id
              FROM ap_self_assessed_tax_dist_all)  aida,
     --}
            xla_ae_headers                  xah,
            xla_ae_lines                    xal,
            xla_distribution_links          xdl,
            cst_accrual_accounts            caa,
            financials_system_params_all    fsp,
            po_distributions_all            pod,
            po_lines_all                    pol,
            --{BUG#7554120
            po_headers_all                  poh
            --}
    WHERE   fsp.org_id                       =  p_operating_unit
      AND   xal.code_combination_id          =  caa.accrual_account_id
      AND   caa.operating_unit_id            =  p_operating_unit
      AND   fsp.set_of_books_id              =  xah.ledger_id
      AND   xah.ae_header_id                 =  xal.ae_header_id
      AND   xah.accounting_date between p_from_date AND p_to_date
      AND   xah.application_id               =  200              -- AP
      AND   xal.application_id               =  200
      AND   xdl.application_id               =  200
      AND   xdl.ae_header_id                 =  xal.ae_header_id
      AND   xdl.source_distribution_id_num_1 =  aida.invoice_distribution_id
      AND   xdl.source_distribution_type     =  'AP_INV_DIST'
      AND   xdl.ae_line_num                  =  xal.ae_line_num
      AND   aida.org_id                      =  p_operating_unit
      AND   aida.invoice_id                  =  apia.invoice_id
      AND   xah.balance_type_code            = 'A'
      AND   aida.po_distribution_id          =  pod.po_distribution_id(+)
      AND   pod.po_line_id                   =  pol.po_line_id(+)
      AND   NVL(pod.lcm_flag,'N')            =  'N'                 --LCM uptake
      --{BUG#7554120
      AND   pod.po_header_id                 =  poh.po_header_id(+)
      --}
      AND   xal.accounting_class_code NOT IN ('LIABILITY')
      AND   ((aida.po_distribution_id IS NULL )
               OR (xal.accounting_class_code in ('IPV','EXCHANGE_RATE_VARIANCE','TRV','TIPV','TERV'))
               OR EXISTS   (
                             SELECT  1
                               FROM  po_releases_all      pra,
                                     po_distributions_all pod
                              WHERE  pod.po_distribution_id                  = aida.po_distribution_id
                                AND  pod.po_release_id is NOT NULL
                                AND  pra.po_release_id                       =  pod.po_release_id
                                AND  NVL(pra.consigned_consumption_flag,'N') = 'Y'
                            )
               OR EXISTS
                           (
                            SELECT 1
                              FROM po_headers_all       poh,
                                   po_distributions_all pod
                             WHERE pod.po_distribution_id                   = aida.po_distribution_id
                               AND pod.po_release_id is NULL
                               AND poh.po_header_id                         = pod.po_header_id
                               AND NVL(poh.consigned_consumption_flag,'N')  = 'Y'
                            )
             )
      AND xah.gl_transfer_status_code      =  'Y'
      AND NOT EXISTS (SELECT 1
                      FROM cst_write_offs cwo1
                      WHERE cwo1.transaction_type_code = 'WRITE OFF'
                        AND cwo1.invoice_distribution_id is NOT NULL
                        AND cwo1.accrual_account_id    = xal.code_combination_id
                        AND cwo1.invoice_distribution_id = aida.invoice_distribution_id
                        AND cwo1.write_off_id = ( SELECT MAX(write_off_id)
                                                    FROM cst_write_offs cwo2
                                                   WHERE cwo2.invoice_distribution_id is NOT NULL
                                                     AND cwo2.invoice_distribution_id = aida.invoice_distribution_id
                                                     AND cwo2.accrual_account_id      = xal.code_combination_id
                                                     AND EXISTS (Select 1 from cst_write_off_details cwod
                                                                  where cwod.write_off_id = cwo2.write_off_id
                                                                    and cwod.ae_header_id = xah.ae_header_id
                                                                    and cwod.ae_line_num  = xal.ae_line_num
                                                                 )
                                                 )
                      );

   debug('Load_ap_misc_data -');

 EXCEPTION

 WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    fnd_message.set_name('BOM','CST_UNEXPECTED');
    fnd_message.set_token('TOKEN',substrb(SQLERRM,1,180));
    debug('l_stmt_num :'||l_stmt_num);
    debug('EXCEPTION OTHERS in Load_ap_misc_data '||substrb(SQLERRM,1,180));
    fnd_msg_pub.add;
    FND_MSG_PUB.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );


END Load_ap_misc_data;

/*===========================================================================+
|                                                                            |
| Procedure Name : Load_inv_misc_data                                        |
|                                                                            |
| Purpose        : This Procedure loads all the Inventory Transaction data   |
|                  that hits the accrual account.Only Inventory Transactions |
|                  that have not been written off or for which the write offs|
|                  have been reversed,is loaded into the reconciliation table|
|                  This procedure also updates the Vendor information for    |
|                  Intercompany transactions and attempts to group the       |
|                  ownership transfer transactions with the Invoice that has |
|                  been matched to the Consignment PO by updating and then   |
|                  grouping these together by PO_DISTRIBUTION_ID.            |
|                                                                            |
| Called from    : Start_accrual_load Procedure                              |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_from_date      IN   VARCHAR2  can be NULL              |
|                   p_to_date        IN   VARCHAR2  can be NULL              |
|                   p_round_unit     IN   NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  x_return_status  OUT  NOCOPY VARCHAR2                    |
|                   x_msg_count      OUT  NOCOPY NUMBER                      |
|                   x_msg_data       OUT  NOCOPY VARCHAR2                    |
|                                                                            |
| NOTES          :  None                                                     |
| 11-Aug-2008 pmarada  Added code to insert OPM financials related inventory |
|                 data into cst_misc_reconciliation table,bug 6995413        |
+===========================================================================*/

Procedure Load_inv_misc_data(p_operating_unit  IN NUMBER,
                             p_from_date       IN DATE,
                             p_to_date         IN DATE,
                             p_round_unit      IN NUMBER,
                             x_msg_count       OUT NOCOPY NUMBER,
                             x_msg_data        OUT NOCOPY VARCHAR2,
                             x_return_status   OUT NOCOPY VARCHAR2
                             )

IS

  l_stmt_num   NUMBER;
  l_build_id                NUMBER;
  l_last_update_date        DATE;
  l_last_updated_by         NUMBER;
  l_last_update_login       NUMBER;
  l_creation_date           DATE;
  l_created_by              NUMBER;
  l_request_id              NUMBER;
  l_program_application_id  NUMBER;
  l_program_id              NUMBER;
  l_program_update_date     DATE;

  l_api_name    CONSTANT  VARCHAR2(30)  := 'Load_inv_misc_data';
  l_full_name   CONSTANT  VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
  l_module      CONSTANT  VARCHAR2(60)  := 'cst.plsql.'||l_full_name;

  l_uLog         CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog         CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  CURSOR c_opm_count IS
  SELECT 1 FROM gmf_rcv_accounting_txns
  WHERE org_id = p_operating_unit
    AND rownum < 2;
  l_opm_count NUMBER;

BEGIN
    debug('Load_inv_misc_data+');
    debug('   p_operating_unit : ' || p_operating_unit);
    debug('   p_from_date      : ' || to_char(p_from_date,'DD-MON-YYYY HH24:MI:SS'));
    debug('   p_to_date        : ' || to_char(p_to_date,'DD-MON-YYYY HH24:MI:SS'));
    debug('   p_round_unit     : ' || p_round_unit);
    l_stmt_num := 10;
    debug('  l_stmt_num :'|| l_stmt_num);
    x_return_status := fnd_api.g_ret_sts_success;


    xla_security_pkg.set_security_context(p_application_id => 707);

   /* Get all the CONC WHO columns */

     SELECT crb.build_id,
            crb.last_update_date,
            crb.last_updated_by,
            crb.last_update_login,
            crb.creation_date,
            crb.created_by,
            crb.request_id,
            crb.program_application_id,
            crb.program_id,
            crb.program_update_date
       INTO l_build_id,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            l_creation_date,
            l_created_by,
            l_request_id,
            l_program_application_id,
            l_program_id,
            l_program_update_date
       FROM cst_reconciliation_build crb
      WHERE crb.request_id = FND_GLOBAL.CONC_REQUEST_ID;

    debug('  l_build_id :'|| l_build_id);

    l_stmt_num := 20;
    debug('  l_stmt_num :'|| l_stmt_num);

   /* Insert INV data into the MISC details table. If there is a write off against the Txn, the txn will be
      inserted only if the write off has been reverse written off or the txn has never been written off. */

    debug('  Inserting into cst_misc_reconciliation' );

    Insert into cst_misc_reconciliation
    (
    transaction_date,
    amount,
    entered_amount,
    quantity,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    invoice_distribution_id,
    inventory_transaction_id,
    accrual_account_id,
    transaction_type_code,
    inventory_item_id,
    vendor_id,
    inventory_organization_id,
    operating_unit_id,
    build_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    Ae_header_id,
    Ae_line_num
   )
    SELECT mmt.transaction_date,
           round((NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0)) / p_round_unit) * p_round_unit,
           round((NVL(entered_dr,0) - NVL(entered_cr,0)) / p_round_unit) * p_round_unit,
           round(NVL(mmt.primary_quantity,0),20),
           xal.currency_code,
           xal.currency_conversion_type,
           xal.currency_conversion_rate,
           xal.currency_conversion_date,
           NULL,          -- Invoice_distribution_id
           mmt.transaction_id,
           xal.code_combination_id,
           Decode(mmt.transaction_action_id,
                  6,'CONSIGNMENT',
                  25,'CONSIGNMENT',               /*pick up retro active consigned price updates as consigned */
                  to_char(mmt.transaction_type_id)
                 ),
           mmt.inventory_item_id,
           NULL,          -- vendor ID will be updated later for I/C txns */
           mmt.organization_id,
           p_operating_unit,
           l_build_id,
           l_last_update_date,
           l_last_updated_by,
           l_last_update_login,
           l_creation_date,
           l_created_by,
           l_request_id,
           l_program_application_id,
           l_program_id,
           l_program_update_date,
           xal.ae_header_id,
           xal.ae_line_num
      FROM xla_ae_headers                  xah,
           xla_ae_lines                    xal,
           xla_transaction_entities_upg    xte,
           mtl_material_transactions       mmt,
           cst_accrual_accounts            caa,
           financials_system_params_all    fsp
     WHERE xal.code_combination_id     =  caa.accrual_account_id
       AND caa.operating_unit_id       =  p_operating_unit
       AND fsp.org_id                  =  p_operating_unit
       AND fsp.set_of_books_id         =  xah.ledger_id
       AND xah.ae_header_id            =  xal.ae_header_id
       AND xah.application_id          =  707              -- Oracle Cost management
       AND xal.application_id          =  707
       AND xte.ledger_id               =  fsp.set_of_books_id
       AND xte.application_id          =  707
       AND xte.entity_id               =  xah.entity_id
       AND xte.entity_code             =  'MTL_ACCOUNTING_EVENTS'
       AND xah.gl_transfer_status_code = 'Y'
       AND mmt.transaction_id          =  NVL(xte.source_id_int_1,(-99))
       AND NOT(      mmt.transaction_action_id  = 24               -- LCM Change
                AND  NVL(mmt.source_code,'XXX') = 'LCMADJ'         -- LCM Change
               )
       AND mmt.transaction_date between p_from_date AND p_to_date
       AND EXISTS (
                        SELECT 1
                        FROM hr_organization_information hoi
                        WHERE  --{BUG#8398114
                            -- hoi.organization_id                  = mmt.organization_id
                           (hoi.organization_id  = mmt.organization_id OR
                            hoi.organization_id  = mmt.transfer_organization_id)
                            --}
                        AND hoi.org_information_context            = 'Accounting Information'
                        AND hoi.org_information3        = to_char(p_operating_unit)
                   )
       AND NOT  EXISTS (
                           SELECT 1
                             FROM cst_write_offs cwo1
                             WHERE cwo1.transaction_type_code    = 'WRITE OFF'
                               AND cwo1.inventory_transaction_id is NOT NULL
                               AND cwo1.inventory_transaction_id = mmt.transaction_id
                               AND cwo1.accrual_account_id       = xal.code_combination_id
                               AND cwo1.write_off_id = ( SELECT MAX(write_off_id)
                                                           FROM cst_write_offs cwo2
                                                          WHERE cwo2.inventory_transaction_id is NOT NULL
                                                            AND cwo2.inventory_transaction_id = mmt.transaction_id
                                                            AND cwo2.accrual_account_id       = xal.code_combination_id
                                                            AND EXISTS ( Select 1 from cst_write_off_details cwod
                                                                         where cwod.write_off_id = cwo2.write_off_id
                                                                           and cwod.ae_header_id = xah.ae_header_id
                                                                           and cwod.ae_line_num  = xal.ae_line_num
                                                                       )
                                                        )
                        );


     debug('   Done Inserting the INV misc data into the accrual table');

    /* Start OPM financials data postng into cst_misc_reconcialiation, pmarada, bug 6995413 */
    OPEN c_opm_count;
    FETCH c_opm_count INTO l_opm_count;
    CLOSE c_opm_count;
    debug('  l_opm_count:'||l_opm_count);

    IF l_opm_count > 0 THEN
     /* Call the xla security package for OPM Financials application also, pmarada */
      xla_security_pkg.set_security_context(p_application_id => 555);

    l_stmt_num := 25;
    debug('  l_stmt_num :'|| l_stmt_num);
    debug('  OPM misc inventory insertion');

    Insert into cst_misc_reconciliation
    (
    transaction_date,
    amount,
    entered_amount,
    quantity,
    currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date,
    invoice_distribution_id,
    inventory_transaction_id,
    accrual_account_id,
    transaction_type_code,
    inventory_item_id,
    vendor_id,
    inventory_organization_id,
    operating_unit_id,
    build_id,
    last_update_date,
    last_updated_by,
    last_update_login,
    creation_date,
    created_by,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    Ae_header_id,
    Ae_line_num
   )
    SELECT mmt.transaction_date,
           round((NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0)) / p_round_unit) * p_round_unit,
           round((NVL(entered_dr,0) - NVL(entered_cr,0)) / p_round_unit) * p_round_unit,
           round(NVL(mmt.primary_quantity,0),20),
           xal.currency_code,
           xal.currency_conversion_type,
           xal.currency_conversion_rate,
           xal.currency_conversion_date,
           NULL,          -- Invoice_distribution_id
           mmt.transaction_id,
           xal.code_combination_id,
           Decode(mmt.transaction_action_id,
                  6,'CONSIGNMENT',     /* Ownership Transfer */
                  25,'CONSIGNMENT',   /* check pick up retro active consigned price updates as consigned */
                  to_char(mmt.transaction_type_id)
                 ),
           mmt.inventory_item_id,
           NULL,          -- vendor ID will be updated later for I/C txns */
           mmt.organization_id,
           p_operating_unit,
           l_build_id,
           l_last_update_date,
           l_last_updated_by,
           l_last_update_login,
           l_creation_date,
           l_created_by,
           l_request_id,
           l_program_application_id,
           l_program_id,
           l_program_update_date,
           xal.ae_header_id,
           xal.ae_line_num
      FROM xla_ae_headers                  xah,
           xla_ae_lines                    xal,
           xla_transaction_entities_upg    xte,
           mtl_material_transactions       mmt,
           cst_accrual_accounts            caa,
           financials_system_params_all    fsp
     WHERE xal.code_combination_id     =  caa.accrual_account_id
       AND caa.operating_unit_id       =  p_operating_unit
       AND fsp.org_id                  =  p_operating_unit
       AND fsp.set_of_books_id         =  xah.ledger_id
       AND xah.ae_header_id            =  xal.ae_header_id
       AND xah.application_id          =  555              -- OPM financials
       AND xal.application_id          =  555
       AND xte.ledger_id               =  fsp.set_of_books_id
       AND xte.application_id          =  555
       AND xte.entity_id               =  xah.entity_id
       AND xte.entity_code             IN ('PURCHASING','INVENTORY') --consignment and retro active price transactions types are under purchasing entity
       AND xah.gl_transfer_status_code = 'Y'
       AND mmt.transaction_id          =  NVL(xte.source_id_int_1,(-99))
       AND mmt.transaction_date between p_from_date AND p_to_date
       AND EXISTS (
                        SELECT 1
                        FROM hr_organization_information hoi
                        WHERE hoi.organization_id                  = mmt.organization_id
                        AND hoi.org_information_context            = 'Accounting Information'
                        AND to_number(hoi.org_information3)        = p_operating_unit
                   )
       AND NOT  EXISTS (
                           SELECT 1
                             FROM cst_write_offs cwo1
                             WHERE cwo1.transaction_type_code    = 'WRITE OFF'
                               AND cwo1.inventory_transaction_id is NOT NULL
                               AND cwo1.inventory_transaction_id = mmt.transaction_id
                               AND cwo1.accrual_account_id       = xal.code_combination_id
                               AND cwo1.write_off_id = ( SELECT MAX(write_off_id)
                                                           FROM cst_write_offs cwo2
                                                          WHERE cwo2.inventory_transaction_id is NOT NULL
                                                            AND cwo2.inventory_transaction_id = mmt.transaction_id
                                                            AND cwo2.accrual_account_id       = xal.code_combination_id
                                                            AND EXISTS ( Select 1 from cst_write_off_details cwod
                                                                         where cwod.write_off_id = cwo2.write_off_id
                                                                           and cwod.ae_header_id = xah.ae_header_id
                                                                           and cwod.ae_line_num  = xal.ae_line_num
                                                                       )
                                                        )
                        );


       debug('  Done Inserting the OPM Financials related INV misc data into the accrual table' );

    END IF;
    /*  End OPM financials data posting,pmarada */

    l_stmt_num := 30;
    debug('  l_stmt_num :'|| l_stmt_num);


     -- reset the SLA security back to discrete costing module
    IF l_opm_count > 0 THEN
      xla_security_pkg.set_security_context(p_application_id => 707);
      debug(' resetting the context to 707');
    END IF;

    /* Update Intercompany INV txns with the Vendor information */
    debug('  Inserting miscellenaous inventory for discrete');

    UPDATE cst_misc_reconciliation cmr
       SET cmr.vendor_id = (
                            SELECT mip.vendor_id
                              FROM mtl_material_transactions   mmt,
                                   mtl_intercompany_parameters mip,
                                   hr_organization_information hoi1,
                                   hr_organization_information hoi2
                             WHERE mmt.transaction_id           =  cmr.inventory_transaction_id
                               AND hoi1.org_information_context =  'Accounting Information'
                               AND hoi1.organization_id         =  decode(mmt.transaction_action_id,
                                                                          12,mmt.transfer_organization_id,
                                                                          mmt.organization_id
                                                                         )
                               AND mip.ship_organization_id     =  to_number(hoi1.org_information3)
                               AND hoi2.org_information_context =  'Accounting Information'
                               AND hoi2.organization_id         =  Decode(mmt.transaction_action_id,
                                                                          12,mmt.organization_id,
                                                                          mmt.transfer_organization_id
                                                                         )
                               AND mip.sell_organization_id     =  to_number(hoi2.org_information3)
                               AND mip.flow_type                =  1
                            )
        WHERE cmr.inventory_transaction_id is NOT NULL
        AND   cmr.operating_unit_id = p_operating_unit
        AND   cmr.transaction_type_code in ('61','62');


     debug('  Done Updating the Vendor information for Intercompany txns');


    l_stmt_num := 40;
    debug('  l_stmt_num :'|| l_stmt_num);

    /* Update PO_DISTRIBUTION_ID for consigned ownership transfer txns so that balancing txns can then be deleted */

    debug('   Updating the PO_DISTRIBUTION_ID for consigned INV transactions');

    Update CST_MISC_RECONCILIATION cmr
       Set po_distribution_id = (select mct.po_distribution_id
                                  from  mtl_consumption_transactions mct
                                  where mct.consumption_processed_flag = 'Y'
                                    AND mct.transaction_id in
                                             (select transaction_id
                                                from mtl_material_transactions mmt
                                               where mmt.transaction_id           = cmr.inventory_transaction_id
                                                  or mmt.transfer_transaction_id  = cmr.inventory_transaction_id
                                              )
                                 )
      WHERE cmr.inventory_transaction_id is NOT NULL
        AND cmr.po_distribution_id is NULL
        AND cmr.transaction_type_code = 'CONSIGNMENT'
        AND cmr.operating_unit_id     = p_operating_unit;

    l_stmt_num := 50;

    debug('  Deleting the Consigment transactions that balance out');

   /* Now delete all the Consigned matching txns after grouping them by po_distribution_id */

    DELETE FROM cst_misc_reconciliation cmr
     WHERE cmr.transaction_type_code = 'CONSIGNMENT'
       AND cmr.operating_unit_id     = p_operating_unit
       AND cmr.po_distribution_id is NOT NULL
       AND EXISTS ( SELECT 1
                      FROM cst_misc_reconciliation cmr2
                     WHERE cmr2.po_distribution_id = cmr.po_distribution_id
                       AND cmr2.accrual_account_id = cmr.accrual_account_id
                       AND cmr2.operating_unit_id  = p_operating_unit
                    HAVING SUM(cmr2.amount)        = 0
                    GROUP BY cmr2.po_distribution_id,
                             cmr2.accrual_account_id
                  );


    debug('Load_inv_misc_data -');

EXCEPTION

 WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    fnd_message.set_name('BOM','CST_UNEXPECTED');
    fnd_message.set_token('TOKEN',substrb(SQLERRM,1,180));
    debug('EXCEPTION OTHERS in Load_inv_misc_data '||substrb(SQLERRM,1,140));
    debug('l_stmt_num :'||l_stmt_num);
    fnd_msg_pub.add;
    FND_MSG_PUB.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

END Load_inv_misc_data;

/*===========================================================================+
|                                                                            |
| Procedure Name : Insert_build_parameters                                   |
|                                                                            |
| Purpose        : This Procedure inserts a row into the                     |
|                  CST_RECONCILIATION_BUILD table for every run of the load  |
|                                                                            |
| Called from    : Start_accrual_load Procedure                              |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_from_date      IN   VARCHAR2  can be NULL              |
|                   p_to_date        IN   VARCHAR2  can be NULL              |
|                                                                            |
| OUT            :  x_return_status  OUT  NOCOPY VARCHAR2                    |
|                   x_msg_count      OUT  NOCOPY NUMBER                      |
|                   x_msg_data       OUT  NOCOPY VARCHAR2                    |
|                                                                            |
| NOTES          :  None                                                     |
+===========================================================================*/


Procedure Insert_build_parameters(p_operating_unit IN NUMBER,
                                  p_from_date      IN DATE,
                                  p_to_date        IN DATE,
                                  x_msg_count       OUT NOCOPY NUMBER,
                                  x_msg_data        OUT NOCOPY VARCHAR2,
                                  x_return_status   OUT NOCOPY VARCHAR2
                                  )

IS

  l_stmt_num     NUMBER;

  l_api_name    CONSTANT  VARCHAR2(30)  := 'Insert_build_parameters';
  l_full_name   CONSTANT  VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
  l_module      CONSTANT  VARCHAR2(60)  := 'cst.plsql.'||l_full_name;

  l_uLog         CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog         CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

BEGIN
   debug('Insert_build_parameters+');
   debug('    p_operating_unit : ' || p_operating_unit);
   debug('    p_from_date      : ' || to_char(p_from_date,'DD-MON-YYYY HH24:MI:SS'));
   debug('    p_to_date        : ' || to_char(p_to_date,'DD-MON-YYYY HH24:MI:SS'));

   l_stmt_num := 10;
   debug('     l_stmt_num :'||l_stmt_num);
   x_return_status := fnd_api.g_ret_sts_success;


   INSERT into CST_RECONCILIATION_BUILD(
       build_id,
       operating_unit_id,
       -- HYU: at the from run this is the main xla upgrade date for the OU
       from_date,
       to_date,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by,
       request_id,
       program_id,
       program_application_id,
       program_update_date)
   values(
          cst_reconciliation_build_s.nextval,
          p_operating_unit,
          p_from_date,
          p_to_date,
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.CONC_REQUEST_ID,
          FND_GLOBAL.CONC_PROGRAM_ID,
          FND_GLOBAL.PROG_APPL_ID,
          sysdate);

   debug('Insert_build_parameters-');

EXCEPTION

 WHEN OTHERS THEN
    rollback;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    fnd_message.set_name('BOM','CST_UNEXPECTED');
    fnd_message.set_token('TOKEN',substr(SQLERRM,1,180));
    debug('EXCEPTION OTHERS in Insert_build_parameters '||substrb(SQLERRM,1,140));
    debug('l_stmt_num  :'||l_stmt_num);
    fnd_msg_pub.add;
    FND_MSG_PUB.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

END Insert_build_parameters;

/*===========================================================================+
|                                                                            |
| Procedure Name : Load_ap_po_data                                           |
|                                                                            |
| Purpose        : This Procedure loads all the PO, regular AP and write off |
|                  data into the reconciliation table by looking at the      |
|                  transaction table.                                        |
|                  All the effect PO_DISTRIBUTION_IDs are identified and then|
|                  the transaction information for this PO distribution is   |
|                  built all over.If the total transaction amount for the    |
|                  PO_DISTRIBUTION_ID balances out to zero, the txns         |
|                  against it are not inserted into the reconciliation table.|
|                                                                            |
| Called from    : Start_accrual_load Procedure                              |
|                                                                            |
| Parameters     :                                                           |
| IN             :  p_operating_unit IN   NUMBER    REQUIRED                 |
|                   p_from_date      IN   VARCHAR2  can be NULL              |
|                   p_to_date        IN   VARCHAR2  can be NULL              |
|                   p_round_unit     IN   NUMBER    REQUIRED                 |
|                                                                            |
| OUT            :  x_return_status  OUT  NOCOPY VARCHAR2                    |
|                   x_msg_count      OUT  NOCOPY NUMBER                      |
|                   x_msg_data       OUT  NOCOPY VARCHAR2                    |
|                                                                            |
| NOTES          :  None                                                     |
| 12-Aug-2008 Pmarada bug Added code for OPM Financials to support AP PO     |
|                reconciliation in R12, bug6995413                           |
| 21-nov-2008 pmarada, bug7516621, added nvl to the inventory_item_id in     |
|             insert cst_reconciliation_gtt where clause, for expanse PO     |
+===========================================================================*/

Procedure Load_ap_po_data(p_operating_unit  IN  VARCHAR2,
                          p_from_date       IN  DATE,
                          p_to_date         IN  DATE,
                          p_round_unit      IN  NUMBER,
                          x_msg_count       OUT NOCOPY NUMBER,
                          x_msg_data        OUT NOCOPY VARCHAR2,
                          x_return_status   OUT NOCOPY VARCHAR2
                          )

IS

  l_stmt_num                NUMBER;
  l_err_num                 NUMBER;
  l_err_code                VARCHAR2(200);
  l_err_msg                 VARCHAR2(2000);
  l_build_id                NUMBER;
  l_last_update_date        DATE;
  l_last_updated_by         NUMBER;
  l_last_update_login       NUMBER;
  l_creation_date           DATE;
  l_created_by              NUMBER;
  l_request_id              NUMBER;
  l_program_application_id  NUMBER;
  l_program_id              NUMBER;
  l_program_update_date     DATE;

  l_api_name     CONSTANT  VARCHAR2(30)  := 'Load_ap_po_data';
  l_full_name    CONSTANT  VARCHAR2(60)  := g_pkg_name || '.' || l_api_name;
  l_module       CONSTANT  VARCHAR2(60)  := 'cst.plsql.'||l_full_name;

  l_uLog         CONSTANT  BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
  l_errorLog     CONSTANT  BOOLEAN := l_uLog and (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
  l_exceptionLog CONSTANT  BOOLEAN := l_errorLog and (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
  l_pLog         CONSTANT  BOOLEAN := l_exceptionLog and (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
  l_sLog         CONSTANT  BOOLEAN := l_pLog and (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

  /* The following cursor picks up PO distributions IDs that have had any activity
     (receipts or Invoices) against them recorded between the supplied from and to dates.Exclude consigned POs*/
  /* This query has been hinted based on suggestion from lguitterez,skoka of the perf team to avoid the bind peeking issue*/

  CURSOR c_po_dists is
       SELECT /*+ LEADING(rt) USE_NL(rrs,pod) */
             DISTINCT pod.po_distribution_id
       FROM  po_distributions_all       pod,
             rcv_transactions            rt,
             rcv_receiving_sub_ledger   rrs
       WHERE pod.accrual_account_id is NOT NULL
         AND pod.accrue_on_receipt_flag   = 'Y'
         AND rt.transaction_date between p_from_date AND p_to_date
         AND pod.org_id                   = p_operating_unit
         AND rrs.rcv_transaction_id       = rt.transaction_id
         AND pod.po_distribution_id       = rrs.reference3
        /* start added below sql for OPM Receiving data to insert the AP PO data, pmarada, bug6995413 */
       UNION
         SELECT /*+ LEADING(rt) USE_NL(grat,pod) */
              DISTINCT pod.po_distribution_id
         FROM  po_distributions_all       pod,
               rcv_transactions           rt,
               gmf_rcv_accounting_txns    grat
         WHERE pod.accrual_account_id is NOT NULL
           AND pod.accrue_on_receipt_flag   = 'Y'
           AND rt.transaction_date between p_from_date AND p_to_date
           AND pod.org_id                   = p_operating_unit
           AND grat.rcv_transaction_id      = rt.transaction_id
           AND pod.po_distribution_id       = grat.po_distribution_id
           AND grat.org_id                  = p_operating_unit
         /* End OPM Financials  */
       UNION
       SELECT DISTINCT pod.po_distribution_id
        FROM  po_distributions_all      pod,
              rcv_accounting_events     rae,
              rcv_receiving_sub_ledger  rrs
       WHERE  pod.accrual_account_id is NOT NULL
         AND  pod.accrue_on_receipt_flag  = 'Y'
         AND  rae.transaction_date between p_from_date AND p_to_date
         AND  pod.org_id                  = p_operating_unit
         AND  rrs.accounting_event_id     = rae.accounting_event_id
         AND  rrs.reference3 = pod.po_distribution_id
         AND  rae.event_source_id = rrs.rcv_transaction_id
         AND  rae.event_type_id in (7,8,9,10)
----------------------
--7  ADJUST_RECEIVE
--8  ADJUST_DELIVER
--9  LOGICAL_RECEIVE
--10 LOGICAL_RETURN_TO_VENDOR
----------------------
       UNION
       SELECT DISTINCT aida.po_distribution_id
       FROM  ap_invoice_distributions_all   aida,
             po_distributions_all           pod
       WHERE pod.accrual_account_id is NOT NULL
         AND aida.accounting_date between p_from_date AND p_to_date
         AND aida.po_distribution_id is NOT NULL
         AND aida.po_distribution_id      = pod.po_distribution_id
         AND aida.org_id                  = p_operating_unit
         AND pod.org_id                   = p_operating_unit
         AND NOT EXISTS
                       (SELECT 1
                          FROM  po_releases_all  pra
                         WHERE  pod.po_release_id is NOT NULL
                           AND  pra.org_id                          =  p_operating_unit
                           AND  pra.po_release_id                   =  pod.po_release_id
                           AND  NVL(pra.consigned_consumption_flag,'N') = 'Y'
                        )
         AND NOT EXISTS
                       (
                        SELECT 1
                          FROM  po_headers_all  poh
                         WHERE  pod.po_release_id is NULL
                           AND  poh.org_id                           = p_operating_unit
                           AND  poh.po_header_id                     = pod.po_header_id
                           AND  NVL(poh.consigned_consumption_flag,'N')  = 'Y'
                       )
      --BUG#8666698
      --User can load WO in a period where there is a RCT or AP Invoice to a PO_DISTRBUTION_ID
       UNION
       SELECT DISTINCT cwo.po_distribution_id
       FROM  cst_write_offs                 cwo
       WHERE cwo.transaction_date between p_from_date AND p_to_date
         AND cwo.po_distribution_id  IS NOT NULL
         AND cwo.operating_unit_id   = p_operating_unit;


   TYPE dists_table is TABLE OF po_distributions_all.po_distribution_id%TYPE;

   po_dists_tab dists_table;

  CURSOR c_opm_count IS
  SELECT 1 FROM gmf_rcv_accounting_txns
  WHERE org_id = p_operating_unit
    AND rownum <2 ;
  l_opm_count NUMBER;

BEGIN
  debug('Load_ap_po_data+');
  debug('     p_operating_unit : ' || p_operating_unit);
  debug('     p_from_date      : ' || to_char(p_from_date,'DD-MON-YYYY HH24:MI:SS'));
  debug('     p_to_date        : ' || to_char(p_to_date,'DD-MON-YYYY HH24:MI:SS'));
  debug('     p_round_unit     : ' || p_round_unit);

      /* Start inserting PO data into the GTT */

   l_stmt_num := 40;
   debug('  l_stmt_num :' ||l_stmt_num);

     /* Get all the CONC WHO columns */

     SELECT crb.build_id,
            crb.last_update_date,
            crb.last_updated_by,
            crb.last_update_login,
            crb.creation_date,
            crb.created_by,
            crb.request_id,
            crb.program_application_id,
            crb.program_id,
            crb.program_update_date
       INTO l_build_id,
            l_last_update_date,
            l_last_updated_by,
            l_last_update_login,
            l_creation_date,
            l_created_by,
            l_request_id,
            l_program_application_id,
            l_program_id,
            l_program_update_date
       FROM cst_reconciliation_build crb
      WHERE crb.request_id = FND_GLOBAL.CONC_REQUEST_ID;
    debug('  l_build_id :'||l_build_id);

      OPEN c_po_dists;
      LOOP

        FETCH c_po_dists BULK COLLECT INTO po_dists_tab LIMIT 5000;

        l_stmt_num := 50;
        debug('  l_stmt_num :'||l_stmt_num);
        debug('   Inserting data from RRS into the global temp table' );
        xla_security_pkg.set_security_context(p_application_id => 707);

        FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST

         INSERT into cst_reconciliation_gtt
         (
          Transaction_date,
          Amount,
          Entered_amount,
          Quantity,
          Currency_code,
          Currency_conversion_type,
          Currency_conversion_rate,
          Currency_conversion_date,
          Po_distribution_id,
          Rcv_transaction_id,
          Invoice_distribution_id,
          Accrual_account_id,
          Transaction_type_code,
          Inventory_item_id,
          Vendor_id,
          Inventory_organization_id,
          Write_off_id,
          Destination_type_code,
          Operating_unit_id,
          Build_id,
          Request_id,
          Ae_header_id,
          Ae_line_num
          )
          SELECT rrs.transaction_date,
                 ROUND((NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0))
                        / p_round_unit) * p_round_unit,
                 ROUND((NVL(xal.entered_dr,0) - NVL(xal.entered_cr,0))
                       / p_round_unit) * p_round_unit,
                 DECODE(rae.event_type_id,
                        7,NULL,
                        8,NULL,
                        ABS(ROUND(NVL(rrs.source_doc_quantity,NVL(rct.source_doc_quantity,0)),20)) *
                        DECODE(xal.accounted_dr,NULL,-1 * sign(xal.accounted_cr),sign(xal.accounted_dr)) /* Bug 6913157: Pre-R12, In RRSL, sometimes accounted_dr / cr could be negative, in which case */
                        ),
                 xal.currency_code,
                 xal.currency_conversion_type,
                 xal.currency_conversion_rate,
                 xal.currency_conversion_date,
                 pod.po_distribution_id,
                 xte.source_id_int_1,
                 NULL, /* Invoice_distribution_id for PO receipts */
                 xal.code_combination_id,
                 DECODE(rae.event_type_id,
                        7,'ADJUST RECEIVE',
                        8,'ADJUST DELIVER',
                        rct.transaction_type
                        ),
                 pol.item_id,
                 poh.vendor_id,
                 NVL(rct.organization_id,p_operating_unit),
                 NULL,                  -- Write_off_id
                 pod.destination_type_code,
                 p_operating_unit,
                 l_build_id,
                 l_request_id,
                 xal.ae_header_id,
                 xal.ae_line_num
          FROM   rcv_transactions                rct,
                 rcv_accounting_events           rae,
                 rcv_receiving_sub_ledger        rrs,
                 xla_ae_headers                  xah,
                 xla_ae_lines                    xal,
                 xla_transaction_entities_upg        xte,
                 xla_distribution_links          xdl,
                 po_headers_all                  poh,
                 po_lines_all                    pol,
                 po_distributions_all            pod,
                 cst_accrual_accounts            caa,
                 financials_system_params_all    fsp
          WHERE  fsp.org_id                   =   p_operating_unit
            AND  xah.ledger_id                =   fsp.set_of_books_id
            AND  xah.application_id           =   707
            AND  xal.application_id           =   707
            AND  xte.application_id           =   707
            AND  xdl.application_id           =   707
            AND  xal.code_combination_id      =   caa.accrual_account_id
            AND  caa.operating_unit_id        =   p_operating_unit
            AND  xah.ae_header_id             =   xal.ae_header_id
            AND  xah.gl_transfer_status_code  =   'Y'
            AND  xte.entity_id                =   xah.entity_id
            AND  xte.ledger_id                =   fsp.set_of_books_id
            AND  xte.entity_code              =   'RCV_ACCOUNTING_EVENTS'
            AND  xdl.ae_header_id             =   xal.ae_header_id
            AND  xdl.ae_line_num              =   xal.ae_line_num
            AND  xdl.source_distribution_type =   'RCV_RECEIVING_SUB_LEDGER'
            AND  rct.transaction_id           =   NVL(xte.source_id_int_1,(-99))
            AND  rct.source_document_code    <>   'REQ'
            AND  rct.transaction_date <= p_to_date /* Added for bug 6913157 */
            AND  rct.transaction_id           =   rrs.rcv_transaction_id
            AND  rae.rcv_transaction_id(+)    =   rrs.rcv_transaction_id
            AND  rae.accounting_event_id(+)   =   rrs.accounting_event_id
            AND  rrs.rcv_sub_ledger_id        =   xdl.source_distribution_id_num_1
            AND  pod.org_id                   =   p_operating_unit
            AND  pod.po_distribution_id       =   rrs.reference3
            AND  pod.po_distribution_id       =   po_dists_tab(indx)
            AND  rrs.reference3               =   to_char(po_dists_tab(indx))
            AND  pol.po_line_id               =   pod.po_line_id
            AND  poh.po_header_id             =   pol.po_header_id
            AND  NVL(rrs.accounting_line_type,'Accrual') <> 'Landed Cost Absorption';  -- LCM Change

       debug('  Done Inserting the receipt information into the accrual table');

         /* Start inserting OPM Financials reconciliation data, pmarada, bug6995413 */
       OPEN c_opm_count;
       FETCH c_opm_count INTO l_opm_count;
       CLOSE c_opm_count;
       debug('  l_opm_count :'||l_opm_count);

       IF l_opm_count > 0 THEN
         l_stmt_num := 55;
         debug(' l_stmt_num :'||l_stmt_num);
         xla_security_pkg.set_security_context(p_application_id => 555);

         FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST

         INSERT into cst_reconciliation_gtt
         (
          Transaction_date,
          Amount,
          Entered_amount,
          Quantity,
          Currency_code,
          Currency_conversion_type,
          Currency_conversion_rate,
          Currency_conversion_date,
          Po_distribution_id,
          Rcv_transaction_id,
          Invoice_distribution_id,
          Accrual_account_id,
          Transaction_type_code,
          Inventory_item_id,
          Vendor_id,
          Inventory_organization_id,
          Write_off_id,
          Destination_type_code,
          Operating_unit_id,
          Build_id,
          Request_id,
          Ae_header_id,
          Ae_line_num
          )
          SELECT grat.transaction_date,
                 ROUND((NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0))
                        / p_round_unit) * p_round_unit,
                 ROUND((NVL(xal.entered_dr,0) - NVL(xal.entered_cr,0))
                       / p_round_unit) * p_round_unit,
                 DECODE(grat.event_type,
                        7,NULL,
                        8,NULL,
                        ABS(ROUND(NVL(grat.source_doc_quantity,NVL(rct.source_doc_quantity,0)),20)) *
                        DECODE(xal.accounted_dr,NULL,-1 * sign(xal.accounted_cr),sign(xal.accounted_dr))
                        ),
                 xal.currency_code,
                 xal.currency_conversion_type,
                 xal.currency_conversion_rate,
                 xal.currency_conversion_date,
                 pod.po_distribution_id,
                 grat.rcv_transaction_id,
                 NULL, /* Invoice_distribution_id for PO receipts */
                 xal.code_combination_id,
                 DECODE(grat.event_type,
                        7,'ADJUST RECEIVE',   /* RECEIVING_ADJUST_RECEIVE */
                        8,'ADJUST DELIVER',   /* RECEIVING_ADJUST_DELIVER */
                        rct.transaction_type
                        ),
                 pol.item_id,
                 poh.vendor_id,
                 NVL(rct.organization_id,p_operating_unit),
                 NULL,                  -- Write_off_id
                 pod.destination_type_code,
                 p_operating_unit,
                 l_build_id,
                 l_request_id,
                 xal.ae_header_id,
                 xal.ae_line_num
          FROM   rcv_transactions                rct,
                 gmf_rcv_accounting_txns         grat,
                 gmf_xla_extract_headers         geh,
                 gmf_xla_extract_lines           gel,
                 xla_ae_headers                  xah,
                 xla_ae_lines                    xal,
                 xla_transaction_entities_upg    xte,
                 xla_distribution_links          xdl,
                 po_headers_all                  poh,
                 po_lines_all                    pol,
                 po_distributions_all            pod,
                 cst_accrual_accounts            caa,
                 financials_system_params_all    fsp
          WHERE  fsp.org_id                   =   p_operating_unit
            AND  xah.ledger_id                =   fsp.set_of_books_id
            AND  xah.application_id           =   555
            AND  xal.application_id           =   555
            AND  xte.application_id           =   555
            AND  xdl.application_id           =   555
            AND  xal.code_combination_id      =   caa.accrual_account_id
            AND  caa.operating_unit_id        =   p_operating_unit
            AND  xah.ae_header_id             =   xal.ae_header_id
            AND  xah.gl_transfer_status_code  =   'Y'
            AND  xte.entity_id                =   xah.entity_id
            AND  xte.ledger_id                =   fsp.set_of_books_id
            AND  xte.entity_code              =   'PURCHASING'
            AND  xdl.ae_header_id             =   xah.ae_header_id
            AND  xdl.ae_line_num              =   xal.ae_line_num
            AND  xdl.source_distribution_type =   'PURCHASING'
            AND  grat.accounting_txn_id       =   NVL(xte.source_id_int_1,(-99))
            AND  rct.source_document_code    <>   'REQ'
            AND  rct.transaction_date        <=   p_to_date /* Added for bug 6913157 */
            AND  rct.transaction_id           =   grat.rcv_transaction_id
            AND  geh.transaction_id           =   grat.accounting_txn_id
            /*Commented this condition as a part of bug 7640489*/
	    --AND  geh.operating_unit           =   p_operating_unit
            AND  geh.source_line_id           =   grat.rcv_transaction_id
            AND  nvl(geh.inventory_item_id,0) =   nvl(grat.inventory_item_id,0) --for expanse item pos added nvl, bug 7516621
            AND  geh.organization_Id          =   grat.organization_Id
            AND  geh.header_id                =   gel.header_id
            AND  geh.event_id                 =   gel.event_id
            AND  gel.line_id                  =   xdl.source_distribution_id_num_1
            AND  gel.journal_line_type        =  'AAP'
            AND  pod.org_id                   =   p_operating_unit
            AND  pod.po_distribution_id       =   grat.po_distribution_id
            AND  pod.po_distribution_id       =   po_dists_tab(indx)
            AND  grat.po_distribution_id      =   to_char(po_dists_tab(indx))
            AND  pol.po_line_id               =   pod.po_line_id
            AND  poh.po_header_id             =   pol.po_header_id ;

           debug('  Done Inserting the OPM related receipt information into the accrual table');
         END IF;
         /* End OPM Financials code, pmarada */

         l_stmt_num := 60;
         debug('  l_stmt_num :'||l_stmt_num);
         xla_security_pkg.set_security_context(p_application_id => 200);

         /* Start Inserting AP Data */

         /* The IPV and ERV lines will have a po_dist_id against them in AIDA. SO we need to handle
            them seperately.*/
         /* When AP creates accounting, it is possible for the line types to be merged thereby creating a summarized
            line in XAL.So one line in XAL can point to one or more lines in XDL (i.e one or different invoice distributions.
            So we need to pick up the amount from XDL from the unrounded columns.But even though the columns are called unrounded,
            they are actually rounded amounts since AP always passes rounded amounts to SLA and no further rounding in SLA is
            possible. */

       debug('  Inserting the AP data into the accrual table');
       FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST

         Insert into cst_reconciliation_gtt
         (
          transaction_date,
          Amount,
          Entered_amount,
          Quantity,
          Currency_code,
          Currency_conversion_type,
          Currency_conversion_rate,
          Currency_conversion_date,
          po_distribution_id,
          rcv_transaction_id,
          invoice_distribution_id,
          accrual_account_id,
          transaction_type_code,
          Inventory_item_id,
          vendor_id,
          Inventory_organization_id,
          Write_off_id,
          destination_type_code,
          Operating_unit_id,
          build_id,
          request_id,
          Ae_header_id,
          Ae_line_num
         )
          SELECT  aida.accounting_date,
                  ROUND((NVL(xdl.unrounded_accounted_dr,0) - NVL(xdl.unrounded_accounted_cr,0)) / p_round_unit) * p_round_unit,
                  ROUND((NVL(xdl.unrounded_entered_dr,0) - NVL(xdl.unrounded_entered_cr,0)) / p_round_unit) * p_round_unit,
                  decode(aida.corrected_invoice_dist_id,
                         NULL, decode(aida.quantity_invoiced,
                                      NULL, NULL,
                                      inv_convert.inv_um_convert(
                                                                  pol.item_id,
                                                                  20,
                                                                  round(aida.quantity_invoiced,20),
                                                                   NULL,
                                                                   NULL,
                                                                   NVL(aida.MATCHED_UOM_LOOKUP_CODE,pol.unit_meas_lookup_code),
                                                                   pol.unit_meas_lookup_code
                                                                )
                                      ),
                         NULL
                        ),
                  xal.currency_code,
                  xal.currency_conversion_type,
                  xal.currency_conversion_rate,
                  xal.currency_conversion_date,
                  aida.po_distribution_id,
                  aida.rcv_transaction_id,
                  aida.invoice_distribution_id,
                  xal.code_combination_id,
                  Decode(aida.rcv_transaction_id,
                         NULL,'AP PO MATCH',
                        'AP RECEIPT MATCH'
                         ),
                  pol.item_id,
                  poh.vendor_id, /* -- Changed from apia.vendor_id to poh.vendor_id. Bug 7312170 */
                  NULL,                  --- Inventory_organization
                  NULL,                  --Write off ID
                  pod.destination_type_code,
                  p_operating_unit,
                  l_build_id,
                  l_request_id,
                  xal.ae_header_id,
                  xal.ae_line_num
          FROM
                  --{BUG#8410174
                  (SELECT 'APID'  tn
                         ,invoice_id
                         ,invoice_distribution_id
                         ,accounting_date
                         ,corrected_invoice_dist_id
                         ,quantity_invoiced
                         ,MATCHED_UOM_LOOKUP_CODE
                         ,po_distribution_id
                         ,rcv_transaction_id
                         ,LINE_TYPE_LOOKUP_CODE
                         ,org_id
                    FROM ap_invoice_distributions_all
                    WHERE po_distribution_id = po_dists_tab(indx)
                    UNION ALL
                    SELECT 'APSTD' tn
                          ,invoice_id
                          ,invoice_distribution_id
                          ,accounting_date
                          ,corrected_invoice_dist_id
                          ,quantity_invoiced
                          ,MATCHED_UOM_LOOKUP_CODE
                          ,po_distribution_id
                          ,rcv_transaction_id
                          ,LINE_TYPE_LOOKUP_CODE
                          ,org_id
                      FROM ap_self_assessed_tax_dist_all
                      WHERE po_distribution_id = po_dists_tab(indx)) aida,
--                  ap_invoice_distributions_all   aida,
                  --}
                  xla_ae_headers                  xah,
                  xla_ae_lines                    xal,
                  xla_distribution_links          xdl,
                  po_lines_all                    pol,
                  po_distributions_all            pod,
                  cst_accrual_accounts            caa,
                  financials_system_params_all    fsp,
                  xla_transaction_entities_upg    xte,
                  po_headers_all                  poh  /* -- Changes to pick Vendor from PO instead of APIA. Bug 7312170 */
          WHERE   xal.code_combination_id          =  caa.accrual_account_id
            AND   caa.operating_unit_id            =  p_operating_unit
            AND   fsp.org_id                       =  p_operating_unit
            AND   fsp.set_of_books_id              =  xah.ledger_id
            AND   xah.application_id               =  200
            AND   xal.application_id               =  200
            AND   xdl.application_id               =  200
            AND   xte.application_id               =  200
            AND   xah.ae_header_id                 =  xal.ae_header_id
            AND   xah.gl_transfer_status_code      =  'Y'
            AND   xdl.ae_header_id                 =  xal.ae_header_id
            AND   xdl.source_distribution_type     =  'AP_INV_DIST'
            AND   xdl.source_distribution_id_num_1 =  aida.invoice_distribution_id
            AND   xdl.ae_line_num                  =  xal.ae_line_num
            AND   aida.org_id                      =  p_operating_unit
            AND   aida.accounting_date <= p_to_date /* Added for bug 6913157 */
            AND   xte.entity_id                    =  xah.entity_id
            AND   xte.ledger_id                    =  fsp.set_of_books_id
            AND   NVL(xte.source_id_int_1,(-99))   =  aida.invoice_id
            AND   xte.entity_code                  =  'AP_INVOICES'
            AND   xal.accounting_class_code NOT IN ('IPV','EXCHANGE_RATE_VARIANCE','LIABILITY','TIPV','TRV','TERV')
            AND   xah.balance_type_code            = 'A'
--            AND   aida.invoice_id                  =  apia.invoice_id
            AND   aida.po_distribution_id          =  pod.po_distribution_id
            AND   pol.po_line_id                   =  pod.po_line_id
            AND   poh.po_header_id                 =  pol.po_header_ID;

        debug('  Done Inserting the AP data into the accrual table');


       l_stmt_num := 70;
       debug('  l_stmt_num :'||l_stmt_num);

       /* Insert Write Off data from Write Off tables */
       debug('  Inserting the write off data into the accrual table');

        FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST

          Insert into cst_reconciliation_gtt
          (
           transaction_date,
           amount,
           entered_amount,
           quantity,
           currency_code,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date,
           po_distribution_id,
           rcv_transaction_id,
           invoice_distribution_id,
           accrual_account_id,
           transaction_type_code,
           inventory_item_id,
           vendor_id,
           inventory_organization_id,
           write_off_id,
           destination_type_code,
           operating_unit_id,
           build_id,
           request_id
          )
          SELECT  cwo.transaction_date,
                  cwo.write_off_amount,
                  cwo.entered_amount,
                  NULL,               -- quantity for write off is NULL
                  cwo.currency_code,
                  cwo.currency_conversion_type,
                  cwo.currency_conversion_rate,
                  cwo.currency_conversion_date,
                  cwo.po_distribution_id,
                  NULL,               -- rcv_transaction_id
                  NULL,               -- invoice_distribution_id
                  cwo.accrual_account_id,
                  cwo.transaction_type_code,
                  cwo.inventory_item_id,
                  poh.vendor_id,      -- immunization for vendor
                  NULL,               -- Inventory Organization ID
                  cwo.write_off_id,
                  cwo.destination_type_code,
                  cwo.operating_unit_id,
                  l_build_id,
                  l_request_id
            FROM  cst_write_offs            cwo,
                  --{ Immunization for po_vendor merge
                  po_distributions_all      pod,
                  po_headers_all            poh
                  --}
           WHERE  cwo.po_distribution_id is NOT NULL
             AND  cwo.operating_unit_id  = p_operating_unit
             AND  cwo.inventory_transaction_id is NULL  -- do not pick up old deliver txns
             AND  cwo.transaction_date <= p_to_date /* Added for bug 6913157 */
             AND  cwo.po_distribution_id = po_dists_tab(indx)
--
-- BUG#9098164
-- The consignmnet transfer AP invoices are being shown in AP PO report
-- hence the AP consignmnet transfer balance write off needs to be considered in AP PO load
--
--         AND  cwo.invoice_distribution_id is NULL -- This will guarantee that we do not pick IPV/ERV/consigned stuff
--
             --{immunization for po_vendor
                 AND  cwo.po_distribution_id  = pod.po_distribution_id
                 AND  pod.po_header_id        = poh.po_header_id;
             --}
         debug('   Done Inserting the write off data into the accrual table');

         l_stmt_num := 70;
         debug('  l_stmt_num :'||l_stmt_num);

            /* Update the summary table now for each po_dist_id. First delete the current info from the table
               and then update it with the latest data */

         debug('  deletion from cst_reconciliation_summary');

         FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST
          DELETE from cst_reconciliation_summary crs
          WHERE  crs.operating_unit_id  = p_operating_unit
          AND    crs.po_distribution_id = po_dists_tab(indx);

         debug('  Done Deleting from CRS');


         l_stmt_num := 75;
         debug('  l_stmt_num :' ||l_stmt_num);

          /* There will be a hint added to force the GTT to use the index. This is required as the
          Temp table is a global temp table */

         debug('  populating CRS from cst_reconciliation_gtt');

         FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST

          Insert into CST_RECONCILIATION_SUMMARY
          (
           po_distribution_id,
           accrual_account_id,
           po_balance,
           ap_balance,
           write_off_balance,
           last_receipt_date,
           last_invoice_dist_date,
           last_write_off_date,
           inventory_item_id,
           vendor_id,
           destination_type_code,
           operating_unit_id,
           build_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           request_id,
           program_application_id,
           program_id,
           program_update_date
          )
          SELECT  /*+ INDEX(gtt, cst_reconciliation_gtt_n1) */
                  gtt.po_distribution_id,
                  gtt.accrual_account_id,
                  SUM(decode(gtt.invoice_distribution_id,
                             NULL,Decode(gtt.write_off_id,
                                         NULL,gtt.amount,
                                         0
                                        ),
                             0
                             )
                      ),
                  SUM(decode(gtt.invoice_distribution_id,
                             NULL,0,
                             gtt.amount
                             )
                      ),
                  SUM(decode(gtt.write_off_id,
                             NULL,0,
                             gtt.amount
                             )
                      ),
                  MAX(decode(gtt.invoice_distribution_id,
                             NULL,Decode(gtt.write_off_id,
                                         NULL,gtt.transaction_date,
                                         NULL
                                         ),
                             NULL
                             )
                      ),
                  MAX(decode(gtt.invoice_distribution_id,
                             NULL,NULL,
                             gtt.transaction_date
                             )
                      ),
                  MAX(decode(gtt.write_off_id,
                             NULL,NULL,
                             gtt.transaction_date
                             )
                      ),
                  gtt.inventory_item_id,
                  gtt.vendor_id,
                  gtt.destination_type_code,
                  gtt.operating_unit_id,
                  l_build_id,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_creation_date,
                  l_created_by,
                  l_request_id,
                  l_program_application_id,
                  l_program_id,
                  l_program_update_date
          FROM    cst_reconciliation_gtt      gtt
          WHERE   gtt.operating_unit_id    =  p_operating_unit
            AND   gtt.po_distribution_id   =  po_dists_tab(indx)
            AND   gtt.build_id             =  l_build_id
            AND   gtt.request_id           =  FND_GLOBAL.CONC_REQUEST_ID
       GROUP BY
                  gtt.po_distribution_id,
                  gtt.accrual_account_id,
                  gtt.inventory_item_id,
                  gtt.vendor_id,
                  gtt.destination_type_code,
                  gtt.operating_unit_id,
                  l_build_id,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_creation_date,
                  l_created_by,
                  l_request_id,
                  l_program_application_id,
                  l_program_id,
                  l_program_update_date
         HAVING
                  SUM(decode(gtt.invoice_distribution_id,
                             NULL,Decode(gtt.write_off_id,
                                         NULL,gtt.amount,
                                         0
                                        ),
                             0
                             )
                      ) +
                  SUM(decode(gtt.invoice_distribution_id,
                             NULL,0,
                             gtt.amount
                             )
                      ) +
                  SUM(decode(gtt.write_off_id,
                             NULL,0,
                             gtt.amount
                             )
                      ) <> 0 ;


         debug('   Done Inserting the new data into CRS from  cst_reconciliation_gtt');

         l_stmt_num := 80;
         debug('  l_stmt_num :' ||l_stmt_num);

          /* Delete all transactions details from the AP/PO details table for those rows that belong to
             the current po_dist_id */

         debug('  deleting into cst_ap_po_reconciliation');

         FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST
          DELETE from cst_ap_po_reconciliation   capr
           WHERE capr.operating_unit_id   = p_operating_unit
             AND capr.po_distribution_id  = po_dists_tab(indx);

          debug('  Done Deleting old data from CAPR');

           l_stmt_num := 90;

          /* insert into AP/PO table from GTT */

         debug('  deleting into cst_ap_po_reconciliation');

         FORALL indx in po_dists_tab.FIRST..po_dists_tab.LAST
          Insert into CST_AP_PO_RECONCILIATION
          (
           transaction_date,
           amount,
           entered_amount,
           quantity,
           currency_code,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date,
           po_distribution_id,
           rcv_transaction_id,
           invoice_distribution_id,
           accrual_account_id,
           transaction_type_code,
           inventory_organization_id,
           write_off_id,
           operating_unit_id,
           build_id,
           last_update_date,
           last_updated_by,
           last_update_login,
           creation_date,
           created_by,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           Ae_header_id,
           Ae_line_num
           )
          SELECT  gtt.transaction_date,
                  gtt.amount,
                  gtt.entered_amount,
                  gtt.quantity,
                  gtt.currency_code,
                  gtt.currency_conversion_type,
                  gtt.currency_conversion_rate,
                  gtt.currency_conversion_date,
                  gtt.po_distribution_id,
                  gtt.rcv_transaction_id,
                  gtt.invoice_distribution_id,
                  gtt.accrual_account_id,
                  gtt.transaction_type_code,
                  gtt.inventory_organization_id,
                  gtt.write_off_id,
                  gtt.operating_unit_id,
                  gtt.build_id,
                  l_last_update_date,
                  l_last_updated_by,
                  l_last_update_login,
                  l_creation_date,
                  l_created_by,
                  gtt.request_id,
                  l_program_application_id,
                  l_program_id,
                  l_program_update_date,
                  gtt.ae_header_id,
                  gtt.ae_line_num
             FROM
                  cst_reconciliation_gtt gtt
            WHERE gtt.operating_unit_id  =  p_operating_unit
              AND gtt.po_distribution_id =  po_dists_tab(indx)
              AND EXISTS (
                           SELECT 1
                             FROM cst_reconciliation_summary crs
                            WHERE crs.operating_unit_id  = p_operating_unit
                              AND crs.po_distribution_id = gtt.po_distribution_id
                              AND crs.accrual_account_id = gtt.accrual_account_id
                         );
          debug('   Done Inserting new data into CAPR');


         EXIT WHEN c_po_dists%notfound;

      END LOOP; /* looping through po_dist_id */
      CLOSE c_po_dists;

     debug('Load_ap_po_data-');

EXCEPTION

 WHEN OTHERS THEN
    debug('EXCEPTION OTHERS in Load_ap_po_data ' || l_stmt_num || '  ' || substrb(SQLERRM,1,140));
    CLOSE c_po_dists;
    x_return_status := FND_API.g_ret_sts_unexp_error ;
    fnd_message.set_name('BOM','CST_UNEXPECTED');
    fnd_message.set_token('TOKEN',substr(SQLERRM,1,180));
    ROLLBACK;
    fnd_msg_pub.add;

    FND_MSG_PUB.count_and_get
              (  p_count => x_msg_count
               , p_data  => x_msg_data
               );

END Load_ap_po_data;


END CST_ACCRUAL_LOAD;

/
