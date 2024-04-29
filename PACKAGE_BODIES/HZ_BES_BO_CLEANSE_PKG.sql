--------------------------------------------------------
--  DDL for Package Body HZ_BES_BO_CLEANSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_BES_BO_CLEANSE_PKG" AS
/* $Header: ARHBESCB.pls 120.2 2005/09/21 17:38:05 smattegu noship $ */

--forward declaration of private procedure and functions

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(
   SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2;

/**
 * PROCEDURE cleanse_main
 *
 * DESCRIPTION
 *   Cleanse Infrastructure Program
 *
 * Scope - Public
 *
 * ARGUMENTS
 *   IN:
 *     p_preserve_num_days    no of days bfr which the recs must be deleted
 *   OUT:
 *     Errbuf                   Error buffer
 *     Retcode                  Return code
 *
 */

PROCEDURE cleanse_main (
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2
) IS
  l_debug_prefix              VARCHAR2(30) := 'bot_cleanse';
  l_cutoff_dt  DATE := SYSDATE;
  l_preserve_num_days  NUMBER;
BEGIN
  --Standard start of API savepoint
  SAVEPOINT cleanse_main_pkg;

  FND_MSG_PUB.initialize;
  Retcode := 0; -- setting the return code to success

  -- Debug info.
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'cleanse_main (+)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

  log('Start Cleansing for BES Concurrent Program');
/*
 Goal
   Cleanse concurrent program identifies and deletes the records that
   were processed before the cutoff date.
 How to calculate the cutoff date
   Cutoff date is calculated based on number of days data that user wants
   to preserve.
 Logic
   . identify the cutoff date
   . delete records prior that were processed prior to cutoff date.
 Known Caveat
   There is a possibility that the cleanse concurrent program deletes recs
   before they are actually consumed by any subscription.
   Consider the following case:
    . On a customer instance, customer has Rule Based Subscriptions
      for Person Update Event.
    . Raise Concurrent Program Raised PersonBO.update Event On Sep 12th 2005.
    . WF Listeners were not scheduled, hence the event was deferred.
    . Cleanse Concurrent Program was scheduled to run at the end of each day
      with following parameter value:
       p_preserve_num_days = 0
      This means do not preserve any rows. Cocnurrent program will delete rows
      for whcih event is populated and date is < SYSDATE.
    . On Sept., 13th 2005, Clenase concurrent program would have deleted all
      records in BOT.
    . On Sept 30th 2005 WF Listeners were scheduled and all the information
      in BOT is lost. So, all the user subscriptions will fail as there is
      no data to select in BOT.
   This known issue was communicated to PM and as there is no other option,
   PM agreed to handle this through user documentation.


*/


  l_preserve_num_days := TO_NUMBER(FND_PROFILE.VALUE('HZ_BO_EVENTS_PRESERVE_DAYS'));

  l_cutoff_dt := l_cutoff_dt - NVL(l_preserve_num_days,0);

  HZ_BES_BO_UTIL_PKG.del_bot(l_cutoff_dt);
  log('Finish Cleansing for BES Concurrent Program');

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
    hz_utility_v2pub.debug(p_message=>'cleanse_main (-)',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    log('Expected error when cleansing');
    ROLLBACK TO cleanse_main_pkg;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    log('Unexpected error when cleansing');
    ROLLBACK TO cleanse_main_pkg;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
  WHEN OTHERS THEN
    log('Other unexpected error when cleansing');
    ROLLBACK TO cleanse_main_pkg;
    Retcode := 2;
    Errbuf := logerror(SQLERRM);
    FND_FILE.close;
END cleanse_main;

/**
  * Procedure to write a message to the log file
  **/
PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put_line(fnd_file.log,message);
  END IF;
END log;

/*-----------------------------------------------------------------------
 | Function to fetch messages of the stack and log the error
 | Also returns the error
 |-----------------------------------------------------------------------*/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

END HZ_BES_BO_CLEANSE_PKG;

/
