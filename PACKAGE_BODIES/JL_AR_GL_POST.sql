--------------------------------------------------------
--  DDL for Package Body JL_AR_GL_POST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_AR_GL_POST" AS
/* $Header: jlbrrgpb.pls 120.4 2005/04/07 18:42:49 appradha ship $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE gl_post(
                  p_posting_control_id          IN  NUMBER ,
                  p_start_gl_date               IN  VARCHAR2 ,
                  p_end_gl_date                 IN  VARCHAR2) IS

  l_req_id1  		     NUMBER(38);
  l_req_id2  		     NUMBER(38);

  call_status                BOOLEAN;
  rphase                     VARCHAR2(80);
  rstatus                    VARCHAR2(80);
  dphase                     VARCHAR2(80);
  dstatus                    VARCHAR2(80);
  message                    VARCHAR2(240);
  dbg_msg                    VARCHAR2(4000);

  country_code               VARCHAR2(5);

  err_num                    NUMBER;
  err_msg                    VARCHAR2(2000);
  GLPOST_ERROR               EXCEPTION;
  REPORT_ERROR               EXCEPTION;
  l_org_id                   NUMBER;

  BEGIN

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('gl_post: ' || 'Start Brazilian GL Transfer ');
   END IF;

   l_org_id := MO_GLOBAL.get_current_org_id;
   country_code := JG_ZZ_SHARED_PKG.get_country(l_org_id,null);

   --country_code := FND_PROFILE.VALUE('JGZZ_COUNTRY_CODE');

   IF country_code = 'BR' THEN

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('gl_post: ' || 'Submit Brazilian GL Transfer Program');
     END IF;

     l_req_id1 := FND_REQUEST.SUBMIT_REQUEST(
                            'JL' ,
                            'JLBRRPBO',
                            'Brazilian Receivables Bank Collection GL Interface Program',
                            SYSDATE ,
                            FALSE,
                            p_posting_control_id,
                            fnd_date.date_to_canonical(to_date(p_start_gl_date,'DD/MM/RRRR')) ,
                            fnd_date.date_to_canonical(to_date(p_end_gl_date,'DD/MM/RRRR'))
                            );

      COMMIT;

      if l_req_id1 = 0 then
        RAISE GLPOST_ERROR;
      end if;


     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('gl_post: ' || 'Wait Start for Brazilian GL Transfer Program ');
     END IF;
     call_status := fnd_concurrent.wait_for_request(l_req_id1,
                                                     5,
                                                     0,
                                                     rphase,
                                                     rstatus,
                                                     dphase,
                                                     dstatus,
                                                     message);



     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('gl_post: ' || 'Wait complete for Brazilian GL Transfer Program ');
     END IF;
     IF dphase = 'COMPLETE' THEN
       IF dstatus = 'NORMAL' THEN
         fnd_file.put_line( 1, 'Loader pgm completed successfully. '||dphase||'-
  '||dstatus);
         COMMIT;
       ELSE
         RAISE GLPOST_ERROR;
       END IF;
     ELSE
       RAISE GLPOST_ERROR;
     END IF;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('gl_post: ' || 'Submit Request for Brazilian GL Transfer Report ');
     END IF;

      l_req_id2 := FND_REQUEST.SUBMIT_REQUEST(
                            'JL' ,
                            'JLBRRTGL',
                            'Brazilian Receivables Bank Collection GL Interface Report',
                            SYSDATE ,
                            FALSE,
                                            'P_POSTING_CONTROL_ID='''||to_char(p_posting_control_id)||'''',
                  'P_START_DATE='''||fnd_date.date_to_canonical(
                                     to_date(
                                     p_start_gl_date,'DD/MM/RRRR'))||
  '''',
                  'P_END_DATE='''||fnd_date.date_to_canonical(
                                   to_date(
                                   p_end_gl_date,'DD/MM/RRRR'))||''''
  ,
                  fnd_global.local_chr(0),'', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '', '', '',
                  '', '', '', '', '', '', '', '');





      COMMIT;

      if l_req_id2 = 0 then
        RAISE REPORT_ERROR;
      end if;

     IF PG_DEBUG in ('Y', 'C') THEN
        arp_standard.debug('gl_post: ' || 'End Brazilian GL Transfer ');
     END IF;

    END IF;

    EXCEPTION

      WHEN GLPOST_ERROR THEN

        fnd_message.set_name('JL', 'JL_BR_AR_GLPOST_ERROR');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');


      WHEN REPORT_ERROR THEN

        fnd_message.set_name('JL', 'JL_BR_AR_REPORT_ERROR');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');

      WHEN OTHERS THEN

        ROLLBACK;
        fnd_message.set_name('JL', 'JL_BR_AR_GENERAL_ERROR');
        fnd_file.put_line( 1, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 200);
        RAISE_APPLICATION_ERROR( err_num, err_msg);



  END gl_post;


END JL_AR_GL_POST;

/
