--------------------------------------------------------
--  DDL for Package Body INV_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_PURGE_PUB" AS
  /* $Header: INVTXPGB.pls 115.11 2004/04/29 11:08:55 gbhagra ship $ */

  /**
  * Global constant holding the package name
  **/
  g_pkg_name CONSTANT VARCHAR2(30)              := 'INV_PURGE_PUB';
  g_version_printed   BOOLEAN                   := FALSE;
  g_user_name         fnd_user.user_name%TYPE   := fnd_global.user_name;

  /**
  *  This Procedure is used to print the Debug Messages to log file.
  *  @param   p_message   Debug Message
  *  @param   p_module    Module
  *  @param   p_level     Debug Level
  **/
  PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2, p_level IN NUMBER) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.TRACE('$Header: INVTXPGB.pls 115.11 2004/04/29 11:08:55 gbhagra ship $', g_pkg_name || '.' || p_module, 1);
      g_version_printed  := TRUE;
    END IF;

    inv_log_util.TRACE(g_user_name || ':  ' || p_message, g_pkg_name || '.' || p_module, p_level);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END print_debug;

  PROCEDURE purge_transactions(
    x_errbuf     OUT NOCOPY    VARCHAR2
  , x_retcode    OUT NOCOPY    NUMBER
  , p_purge_date IN            VARCHAR2
  , p_orgid      IN            NUMBER
  , p_purge_name IN            VARCHAR2
  ) IS
    l_tempvar       NUMBER;
    l_login_id      NUMBER       := fnd_profile.VALUE('LOGIN_ID');
    l_user_id       NUMBER       := fnd_profile.VALUE('USER_ID');
    l_batch_size    NUMBER       := 1000;
    l_more          BOOLEAN      := TRUE;
    l_count         NUMBER;
    l_total_count   NUMBER;
    l_ret           BOOLEAN;
    l_debug         NUMBER       := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    --l_errbuf        VARCHAR2(20); Commented out as part of Bug# 3542452
    --l_retcode       NUMBER;  Commented out as part of Bug# 3542452
    l_purge_date    DATE;
    l_proc CONSTANT VARCHAR2(30) := 'PURGE_TRANSACTIONS';
  BEGIN
    SAVEPOINT purge_savepoint;

    IF (l_debug = 1) THEN
      print_debug(
           'The input parameters are: '
        || fnd_global.local_chr(10)
        || '   OrgId: '
        || p_orgid
        || fnd_global.local_chr(10)
        || ',  Date: '
        || p_purge_date
        || fnd_global.local_chr(10)
      , l_proc
      , 9
      );
    END IF;

    -- validate the Organization passed to ensure that it has no OPEN
    -- accounting periods for the date specified
    BEGIN
      SELECT 1
        INTO l_tempvar
        FROM org_acct_periods
       WHERE organization_id = p_orgid
         AND period_start_date <= inv_le_timezone_pub.get_le_day_for_inv_org(fnd_date.canonical_to_date(p_purge_date), p_orgid)
         AND schedule_close_date >= inv_le_timezone_pub.get_le_day_for_inv_org(fnd_date.canonical_to_date(p_purge_date), p_orgid)
         AND open_flag = 'N';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_msg_pub.initialize;
        fnd_message.set_name('INV','INV_NO_CLOSED_PERIOD');
        fnd_msg_pub.add;
        fnd_file.put_line(fnd_file.LOG,substrb(fnd_msg_pub.get(p_encoded =>FND_API.G_FALSE),1,250));
        RETURN;
    END;

    -- If a valid purge_name is specified, insert a record into mtl_purge_headers
    -- to serve as an audit-trail.
    IF (p_purge_name IS NOT NULL) THEN
      INSERT INTO mtl_purge_header
                  (
                   purge_id
                 , last_update_date
                 , last_updated_by
                 , last_update_login
                 , creation_date
                 , created_by
                 , purge_date
                 , purge_name
                 , organization_id
                  )
           VALUES (
                   mtl_material_transactions_s.NEXTVAL
                 , SYSDATE
                 , l_user_id
                 , l_login_id
                 , SYSDATE
                 , l_user_id
                 , fnd_date.canonical_to_date(p_purge_date)
                 , p_purge_name
                 , p_orgid
                  );
    END IF;

    /* Bug: 3145486*/
    l_purge_date  := fnd_date.canonical_to_date(p_purge_date) + 1 -(1 /(24 * 3600));

    /* Bug# 3542452 */
    inv_txn_purge_main.txn_purge_main(x_errbuf, x_retcode, p_orgid, l_purge_date);

    -- Commented out as part of Bug# 3542452
    /*IF l_retcode = 2 THEN
      fnd_file.put_line(fnd_file.LOG, 'Error from INV_TXN_PURGE_MAIN.TXN_PURGE_MAIN');
      l_ret      := fnd_concurrent.set_completion_status('ERROR', 'Error');
      x_retcode  := 2;
      x_errbuf   := 'Error';
    END IF;

    l_ret         := fnd_concurrent.set_completion_status('NORMAL', 'Success');
    x_retcode     := 0;
    x_errbuf      := 'Success';*/
  EXCEPTION
    WHEN OTHERS THEN
      IF (l_debug = 1) THEN
        print_debug('Error :' || SUBSTR(SQLERRM, 1, 100), l_proc, 1);
      END IF;

      ROLLBACK TO purge_savepoint;
      -- Commented out as part of Bug# 3542452
      --l_ret      := fnd_concurrent.set_completion_status('ERROR', 'Error');
      --x_errbuf   := 'Error';
      x_retcode  := 2;
      fnd_message.set_name('INV', 'INV_PURGE_TXN_ERR');
	   x_errbuf := fnd_message.get;
  END purge_transactions;
END inv_purge_pub;

/
